local function reconnect_roboports_command()
    if not (game.player and game.player.admin) then
        game.player.print("You must be an admin to use this command.")
        return
    end

    for _, surface in pairs(game.surfaces) do
        for _, roboport in pairs(surface.find_entities_filtered{type = "roboport"}) do
            if roboport.valid and roboport.logistic_network then
                roboport.teleport(roboport.position)
            end
        end
    end

    game.print("Recalculated roboport connections.")
end

commands.add_command("reconnectroboports", "Recalculate all roboport logistics network connections.", reconnect_roboports_command)