local factor = settings.startup['ElectricPoleRangeMultiplier-range-factor'].value

for _, prot in pairs(data.raw['electric-pole']) do
    prot.supply_area_distance = math.min(math.floor(prot.supply_area_distance*factor*2)/2, 64)
    
    maximum_wire_distance = math.min(math.floor(prot.maximum_wire_distance*factor*2)/2, 64)
    if (prot.supply_area_distance*2)/maximum_wire_distance > 0.5 then
        maximum_wire_distance = math.min(maximum_wire_distance, prot.supply_area_distance*2 + settings.startup['ElectricPoleRangeMultiplier-maximum-gap'].value)
    end
    prot.maximum_wire_distance = math.min(maximum_wire_distance, 64)
end
