local technologies = data.raw.technology

local price_factor = settings.startup["TechnologyPriceMultiplier-price-factor"].value
local price_exponent = settings.startup["TechnologyPriceMultiplier-price-exponent-factor"].value
local price_tier_scaling = settings.startup["TechnologyPriceMultiplier-price-tier-scaling-factor"].value
local price_tier_curve = settings.startup["TechnologyPriceMultiplier-price-tier-scaling-curve"].value
local price_tier_start = settings.startup["TechnologyPriceMultiplier-price-tier-scaling-start"].value

local tier_cache = {}

local function count_prerequisite_tier(technology, visiting)
    if tier_cache[technology.name] then
        return tier_cache[technology.name]
    end
    if visiting[technology.name] then
        return 0
    end
    visiting[technology.name] = true

    local max_prereq_count = 0
    if technology.prerequisites and #technology.prerequisites > 0 then
        for _, prereq_key in ipairs(technology.prerequisites) do
            local prereq_tech = technologies[prereq_key]
            if prereq_tech and prereq_tech ~= technology.name then
                local current_prereq_count = count_prerequisite_tier(prereq_tech, visiting)

                if prereq_tech.essential and prereq_tech.unit ~= nil then
                    current_prereq_count = current_prereq_count + 1
                end

                if current_prereq_count > max_prereq_count then
                    max_prereq_count = current_prereq_count
                end
            end
        end
    end
    
    visiting[technology.name] = nil
    tier_cache[technology.name] = max_prereq_count
    return max_prereq_count
end

-- Modifies an infinite technology's cost formula to scale its incremental growth.
local function modify_technology_formula(technology)
    -- Default to 7 as per the problem description
    local formula = technology.unit.count_formula
    
    local level_str = technology.name:match("-(%d+)$")
    local L_start = level_str and tonumber(level_str) or 1

    -- Case 1: Handle linear growth, e.g., "2500*(L-6)"
    -- Pattern captures: 1=constant, 2=offset
    local linear_pattern = "([%d.]+)[%s%*]*%s*%(L%s*-%s*([%d]+)%)"
    local const_str, offset_str = formula:match(linear_pattern)

    if const_str and offset_str then
        local constant = tonumber(const_str)
        local offset = tonumber(offset_str)
        
        -- Calculate the cost at the first infinite level to preserve it.
        -- For "2500*(L-6)" at L=7, initial_cost is 2500 * (7-6) = 2500.
        local initial_cost = constant * (L_start - offset)
        
        -- The original growth per level is 'constant'. We scale this growth.
        local new_growth = constant * price_exponent
        
        -- The new formula is: (initial cost) + (new growth) * (levels past start)
        local new_formula = initial_cost .. " + " .. new_growth .. "*(L-" .. L_start .. ")"
        technology.unit.count_formula = new_formula
        return -- This technology is done.
    end

    -- If not linear, it's exponential. We will first normalize the formula
    -- and then apply the growth multiplier.
    local normalized_formula = formula

    -- Case 2: Exponential with no offset, e.g., "1.5^L*1000"
    -- This implies the series starts at L=1. We convert it to a standard (L-1) form.
    -- Pattern captures: 1=base
    local no_offset_pattern = "([%d.]+)%s*%^%s*L"
    local base_no_offset = normalized_formula:match(no_offset_pattern)
    if base_no_offset then
        -- Replace "base^L" with "base^(L-1)*base" to normalize it.
        -- "1.5^L*1000" -> "1.5^(L-1)*1.5*1000"
        local replacement = base_no_offset .. "^(L-1)*" .. base_no_offset
        normalized_formula = normalized_formula:gsub(no_offset_pattern, replacement, 1)
    end

    -- Case 3: Exponential with an offset different from the start level, e.g., "2^(L-6)*1000"
    -- We normalize it to be relative to L_start (7).
    -- Pattern captures: 1=base, 2=offset
    local offset_pattern = "([%d.]+)%s*%^%s*%(L%s*-%s*([%d]+)%)"
    local base_off, offset_off = normalized_formula:match(offset_pattern)
    if base_off and offset_off then
        local offset = tonumber(offset_off)
        if offset < L_start then
            local base = tonumber(base_off)
            local diff = L_start - offset
            -- To change (L-6) to (L-7), we subtract 1 from the exponent.
            -- We must compensate by multiplying the whole term by `base^1`.
            local compensation_factor = base ^ diff
            
            -- Replace "base^(L-offset)" with "base^(L-L_start)*compensation_factor"
            -- "2^(L-6)" -> "2^(L-7)*2"
            local replacement = base_off .. "^(L-" .. L_start .. ")*" .. compensation_factor
            normalized_formula = normalized_formula:gsub(offset_pattern, replacement, 1)
        end
    end

    -- Final Step: Apply the growth multiplier to all exponential formulas.
    -- This pattern works on the original formulas ("2^(L-7)*1000") and the newly normalized ones.
    local exp_pattern = "([%d.]+)%s*%^"
    local base_to_modify = normalized_formula:match(exp_pattern)
    if base_to_modify then
        -- The core logic: base^x -> ((base - 1) * multiplier + 1)^x
        local replacement = "((" .. base_to_modify .. " - 1)*" .. price_exponent .. " + 1)^"
        technology.unit.count_formula = normalized_formula:gsub(exp_pattern, replacement, 1)
    end
end

local max_tier = 0
for _, technology in pairs(technologies) do
    if (technology.unit) then
        local tier = 0
        if (price_tier_scaling ~= 1) then
            tier = count_prerequisite_tier(technology, {})
            max_tier = math.max(max_tier, tier)
            tier = math.max(tier + 1 - price_tier_start, 0)
        end

        local individual_price_factor = price_factor

        if (technology.ignore_tech_cost_multiplier and individual_price_factor > 1.0) then
            individual_price_factor = 1.0
        end

        if (technology.unit.count ~= nil) then
            technology.unit.count = math.max(math.ceil(technology.unit.count*individual_price_factor*price_tier_scaling^tier^price_tier_curve), 1)
        elseif (technology.unit.count_formula ~= nil) then
            -- Modify the formula to use modified price growth for infinite technologies
            if (price_exponent ~= 1) then
                modify_technology_formula(technology)
            end

            -- Apply the price factor and tier scaling modifiers
            if (individual_price_factor ~= 1 or price_tier_scaling ~= 1) then
                technology.unit.count_formula = "(" .. technology.unit.count_formula .. ")"
            end
            if (individual_price_factor ~= 1) then
                technology.unit.count_formula = technology.unit.count_formula .. "*" .. individual_price_factor
            end
            if (price_tier_scaling ~= 1) then
                technology.unit.count_formula = technology.unit.count_formula .. "*" .. price_tier_scaling .. "^" .. tier

                if (price_tier_curve ~= 1) then
                    technology.unit.count_formula = technology.unit.count_formula .. "^" .. price_tier_curve
                end
            end
        end
    end
end

if (max_tier > 0) then
    log("Highest tech tier: " .. max_tier)
end