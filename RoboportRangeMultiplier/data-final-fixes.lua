for _, prot in pairs(data.raw['roboport']) do
    prot.logistics_radius = math.max(math.floor(prot.logistics_radius*settings.startup['RoboportRangeMultiplier-logistics-range-factor'].value + 0.5), 0)
    prot.construction_radius = math.max(math.floor(prot.construction_radius*settings.startup['RoboportRangeMultiplier-construction-range-factor'].value + 0.5), 0)
end

for _, prot in pairs(data.raw['roboport-equipment']) do
    prot.construction_radius = math.max(math.floor(prot.construction_radius*settings.startup['RoboportRangeMultiplier-personal-construction-range-factor'].value + 0.5), 0)
end
