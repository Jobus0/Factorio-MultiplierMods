local factor = settings.startup['ElectricPoleRangeMultiplier-range-factor'].value
for _, prot in pairs(data.raw['electric-pole']) do
    prot.supply_area_distance = math.min(math.floor(prot.supply_area_distance*factor + 0.5), 64)
    prot.maximum_wire_distance = math.min(math.floor(prot.maximum_wire_distance*factor + 0.5), 64)
end
