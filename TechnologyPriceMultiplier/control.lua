--[[
This script adds a command to the game to find and list the top 5 most expensive technologies.
]]

local function format_compact_number(n)
  if n >= 1000000000000 then
    -- Trillions
    return string.format("%.1fT", n / 1000000000000)
  elseif n >= 1000000000 then
    -- Billions
    return string.format("%.1fG", n / 1000000000)
  elseif n >= 1000000 then
    -- Millions
    return string.format("%.1fM", n / 1000000)
  elseif n >= 1000 then
    -- Thousands
    return string.format("%.1fK", n / 1000)
  else
    -- Less than 1000
    return tostring(n)
  end
end

commands.add_command("top-expensive-techs", "Lists the top 5 most expensive technologies.", function(command)
  local player = game.players[command.player_index]

  if not player then
    game.print("Command can only be run by a player.")
    return
  end

  local force = player.force
  local technologies = force.technologies
  local tech_costs = {}

  -- Iterate through all technologies of the player's force
  for _, tech in pairs(technologies) do
    -- For multi-level technologies, we'll consider the cost of the next level
    local research_unit_count = tech.research_unit_count

    -- Store the technology name and its calculated cost
    if research_unit_count > 0 then
      table.insert(tech_costs, {name = tech.localised_name, cost = research_unit_count})
    end
  end

  -- Sort the technologies by cost in descending order
  table.sort(tech_costs, function(a, b)
    return a.cost > b.cost
  end)

  -- Print the top 5 most expensive technologies
  player.print("Top 5 Most Expensive Technologies:")
  for i = 1, 5 do
    if tech_costs[i] then
      player.print({"", i, ". ", tech_costs[i].name, ": ", format_compact_number(tech_costs[i].cost)})
    end
  end
end)