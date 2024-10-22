for _, prot in pairs(data.raw['assembling-machine']) do
    prot.crafting_speed = prot.crafting_speed*settings.startup['MachineSpeedMultiplier-assembling-machine-speed-factor'].value
end

for _, prot in pairs(data.raw['furnace']) do
    prot.crafting_speed = prot.crafting_speed*settings.startup['MachineSpeedMultiplier-furnace-speed-factor'].value
end

for _, prot in pairs(data.raw['rocket-silo']) do
    prot.crafting_speed = prot.crafting_speed*settings.startup['MachineSpeedMultiplier-rocket-silo-speed-factor'].value
end

for _, prot in pairs(data.raw['lab']) do
    prot.researching_speed = prot.researching_speed*settings.startup['MachineSpeedMultiplier-lab-speed-factor'].value
end

for _, prot in pairs(data.raw['mining-drill']) do
    prot.mining_speed = prot.mining_speed*settings.startup['MachineSpeedMultiplier-mining-drill-speed-factor'].value
end