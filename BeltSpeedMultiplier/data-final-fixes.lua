for _, type_name in pairs({'transport-belt', 'underground-belt', 'splitter'}) do

    local type = data.raw[type_name]

    for _, prot in pairs(type) do
        prot.speed = prot.speed*settings.startup['BeltSpeedMultiplier-speed-factor'].value
    end
end
