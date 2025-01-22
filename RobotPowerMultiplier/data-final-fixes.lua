-- Function to parse and multiply an energy value with extended units
local function multiply_energy(energy_str, factor, suffix)
    if energy_str == nil then
        return nil
    end
    
    if factor == 1 then
        return energy_str
    end

    -- Extract the numeric part and the unit part
    local value, unit = energy_str:match("([%d%.]+)(%a+)")

    value = tonumber(value)

    -- Define unit multipliers in ascending order of size
    local unit_multipliers = {
        { unit = suffix, multiplier = 1 },
        { unit = "k"..suffix, multiplier = 1e3 },
        { unit = "M"..suffix, multiplier = 1e6 },
        { unit = "G"..suffix, multiplier = 1e9 },
        { unit = "T"..suffix, multiplier = 1e12 },
        { unit = "P"..suffix, multiplier = 1e15 },
        { unit = "E"..suffix, multiplier = 1e18 },
        { unit = "Z"..suffix, multiplier = 1e21 },
        { unit = "Y"..suffix, multiplier = 1e24 },
        { unit = "R"..suffix, multiplier = 1e27 },
        { unit = "Q"..suffix, multiplier = 1e30 }
    }

    -- Find the multiplier for the input unit
    local input_multiplier = 1
    for _, entry in ipairs(unit_multipliers) do
        if entry.unit == unit then
            input_multiplier = entry.multiplier
            break
        end
    end

    local result_value = value * input_multiplier * factor
    local result_unit = suffix

    -- Loop through units in ascending order to find the best unit for result_value
    for i = #unit_multipliers, 1, -1 do
        local entry = unit_multipliers[i]
        if result_value >= entry.multiplier then
            result_value = result_value / entry.multiplier
            result_unit = entry.unit
            break
        end
    end

    return string.format("%g%s", result_value, result_unit)
end

for _, type_name in pairs({'logistic-robot', 'construction-robot'}) do
    for _, prot in pairs(data.raw[type_name]) do
        prot.max_energy = multiply_energy(prot.max_energy, math.max(settings.startup['RobotPowerMultiplier-robot-max-energy-factor'].value, 0), "J")
        prot.speed = math.max(prot.speed*settings.startup['RobotPowerMultiplier-robot-speed-factor'].value, 0)
        if (prot.energy_per_move ~= nil) then
            prot.energy_per_move = multiply_energy(prot.energy_per_move, math.max(settings.startup['RobotPowerMultiplier-robot-movement-energy-consumption-factor'].value, 0), "J")
        end
    end
end

for _, type_name in pairs({'roboport', 'roboport-equipment'}) do
    for _, prot in pairs(data.raw[type_name]) do
        prot.charge_approach_distance = math.max(prot.charge_approach_distance*settings.startup['RobotPowerMultiplier-robot-approach-distance-factor'].value, 0)
        prot.charging_energy = multiply_energy(prot.charging_energy, math.max(settings.startup['RobotPowerMultiplier-robot-charging-energy-factor'].value, 0), "W")
        
        if prot.energy_source.input_flow_limit then
            prot.energy_source.input_flow_limit = multiply_energy(prot.energy_source.input_flow_limit, math.max(settings.startup['RobotPowerMultiplier-robot-charging-energy-factor'].value, 0), "W")
        end
    end
end