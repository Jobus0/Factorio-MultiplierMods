local multiplier = settings.startup['BeltSpeedMultiplier-speed-factor'].value

for _, type_name in pairs({'transport-belt', 'underground-belt', 'splitter'}) do

    local type = data.raw[type_name]

    for _, prot in pairs(type) do
        prot.speed = prot.speed*multiplier
    end
end

if (mods["aai-loaders"]) then
    local type = data.raw['loader-1x1']

    for _, prot in pairs(type) do
        prot.speed = prot.speed*multiplier
    end
end