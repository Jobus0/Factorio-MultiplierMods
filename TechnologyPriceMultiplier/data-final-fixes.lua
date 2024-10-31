local technologies = data.raw.technology

local price_factor = settings.startup["TechnologyPriceMultiplier-price-factor"].value
local price_exponent = settings.startup["TechnologyPriceMultiplier-price-exponent-factor"].value

local exponent_base_pattern = "^%d*%.?%d+"

price_exponent = math.max(price_exponent, 0)

for _, technology in pairs(technologies) do
    if (technology.unit) then
        if (technology.unit.count ~= nil) then
            technology.unit.count = math.max(math.ceil(technology.unit.count*price_factor), 1)
        elseif (technology.unit.count_formula) then
            if (price_exponent ~= 1) then
                local base = string.match(technology.unit.count_formula, exponent_base_pattern)
                if (base ~= nil) then
                    local replacement = "((" .. base .. " - 1)*" .. price_exponent .. " + 1)"
                    technology.unit.count_formula = technology.unit.count_formula:gsub(exponent_base_pattern, replacement, 1)
                end
            end
            technology.unit.count_formula = '(' .. technology.unit.count_formula .. ')*' .. price_factor
        end
    end
end
