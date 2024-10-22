local technologies = data.raw.technology

local price_factor = settings.startup["TechnologyPriceMultiplier-price-factor"].value

for _, technology in pairs(technologies) do
    if (technology.unit) then
        if (technology.unit.count ~= nil) then
            technology.unit.count = math.max(math.ceil(technology.unit.count*price_factor), 1)
        elseif (technology.unit.count_formula) then
            technology.unit.count_formula = '(' .. technology.unit.count_formula .. ')*' .. price_factor
        end
    end
end
