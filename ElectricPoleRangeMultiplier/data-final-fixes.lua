for _, prot in pairs(data.raw['electric-pole']) do
    prot.supply_area_distance = math.min(prot.supply_area_distance*settings.startup['ElectricPoleRangeMultiplier-range-factor'].value, 32)
    prot.maximum_wire_distance = math.min(math.floor(prot.maximum_wire_distance*settings.startup['ElectricPoleRangeMultiplier-range-factor'].value), 64)
end
