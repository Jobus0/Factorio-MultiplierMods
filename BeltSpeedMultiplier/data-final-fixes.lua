local multiplier = settings.startup['BeltSpeedMultiplier-speed-factor'].value

local transport_belt_connectables = {
    "transport-belt",
    "underground-belt",
    "splitter",
    "loader",
    "loader-1x1",
    "linked-belt",
    "lane-splitter",
}

for _, type_name in pairs(transport_belt_connectables) do

    local type = data.raw[type_name]

    for _, prot in pairs(type) do
        prot.speed = prot.speed*multiplier
    end
end