local technologies = data.raw.technology

local price_factor = settings.startup["TechnologyPriceMultiplier-price-factor"].value
local price_exponent = settings.startup["TechnologyPriceMultiplier-price-exponent-factor"].value
local price_tier_scaling = settings.startup["TechnologyPriceMultiplier-price-tier-scaling-factor"].value

local exponent_base_pattern = "^%d*%.?%d+"
local tier_cache = {}

function count_prerequisite_tier(technology)
    if tier_cache[technology.name] then
        return tier_cache[technology.name]
    end

    local max_prereq_count = 0
    if technology.prerequisites and #technology.prerequisites > 0 then
        for _, prereq_key in ipairs(technology.prerequisites) do
            local prereq_tech = technologies[prereq_key]
            if prereq_tech and prereq_tech ~= technology.name then
                local current_prereq_count = count_prerequisite_tier(prereq_tech)

                if prereq_tech.essential and prereq_tech.unit ~= nil then
                    current_prereq_count = current_prereq_count + 1
                end

                if current_prereq_count > max_prereq_count then
                    max_prereq_count = current_prereq_count
                end
            end
        end
    end
    
    tier_cache[technology.name] = max_prereq_count
    return max_prereq_count
end

for _, technology in pairs(technologies) do
    if (technology.unit) then
        local tier = 0
        if (price_tier_scaling ~= 1) then
            tier = count_prerequisite_tier(technology)
        end

        if (technology.unit.count ~= nil) then
            technology.unit.count = math.max(math.ceil(technology.unit.count*price_factor*price_tier_scaling^tier), 1)
        elseif (technology.unit.count_formula ~= nil) then
            if (price_exponent ~= 1) then
                local base = string.match(technology.unit.count_formula, exponent_base_pattern)
                if (base ~= nil) then
                    local replacement = "((" .. base .. " - 1)*" .. price_exponent .. " + 1)"
                    technology.unit.count_formula = technology.unit.count_formula:gsub(exponent_base_pattern, replacement, 1)
                end
            end
            technology.unit.count_formula = '(' .. technology.unit.count_formula .. ')*' .. price_factor .. "*" .. price_tier_scaling .. "^" .. tier
        end
    end
end