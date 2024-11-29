for _, prot in pairs(data.raw['roboport']) do
    prot.logistics_radius = math.max(math.floor(prot.logistics_radius*settings.startup['RoboportRangeMultiplier-logistics-range-factor'].value + 0.5), 0)
    prot.construction_radius = math.max(math.floor(prot.construction_radius*settings.startup['RoboportRangeMultiplier-construction-range-factor'].value + 0.5), 0)
    if prot.logistics_connection_distance then
        prot.logistics_connection_distance = math.max(math.floor(prot.logistics_connection_distance*settings.startup['RoboportRangeMultiplier-logistics-range-factor'].value + 0.5), 0)

        -- connection distance must be at least the logistics radius
        if prot.logistics_connection_distance < prot.logistics_radius then
            prot.logistics_connection_distance = prot.logistics_radius
        end
    end
end

for _, prot in pairs(data.raw['roboport-equipment']) do
    prot.construction_radius = math.max(math.floor(prot.construction_radius*settings.startup['RoboportRangeMultiplier-personal-construction-range-factor'].value + 0.5), 0)
end
