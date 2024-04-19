local function IsCovered(ent, surface, radius)
  local x = math.floor(ent.position.x)
  local y = math.floor(ent.position.y)
  
  for tx = x-radius, x+radius do
    for ty = y-radius, y+radius do
      if surface.get_tile(tx,ty).prototype.mineable_properties.minable then
        return true
      end
    end
  end
  
  return false
end

local function RemoveOres(surface, x, y)
  local radius = settings.global["coverup-radius"].value - 1
  if radius < 0 then radius = 0 end
  if radius > 10 then radius = 10 end
  
  local ents = surface.find_entities_filtered{area = {{x + 0.1 - radius, y + 0.1 - radius},{x + 0.9 + radius, y + 0.9 + radius}}, type = "resource"}
  if #ents > 0 then
    if settings.global["coverup-permanent"].value then
      for _,res in pairs(ents) do
        if IsCovered(res, surface, radius) then
          res.destroy()
        end
      end
    else
      local surface2 = game.surfaces[surface.name.."__hiddenores__"]
      if not surface2 then
        surface2 = game.create_surface(surface.name.."__hiddenores__")
      end
      for _,res in pairs(ents) do
        if IsCovered(res, surface, radius) then
          local res2 = surface2.create_entity{name = res.name, position = {res.position.x, res.position.y}, amount = res.amount}
          if res.initial_amount then res2.initial_amount = res.initial_amount end
          res.destroy()
        end
      end
    end
  end
end

local function RestoreOres(surface, surface2, x, y)
  local radius = settings.global["coverup-radius"].value - 1
  if radius < 0 then radius = 0 end
  if radius > 10 then radius = 10 end
  
  local ents = surface2.find_entities_filtered{area = {{x + 0.1 - radius, y + 0.1 - radius},{x + 0.9 + radius, y + 0.9 + radius}}, type = "resource"}
  if #ents > 0 then
    for _,res in pairs(ents) do
      if not IsCovered(res, surface, radius) then
        local res2 = surface.create_entity{name = res.name, position = {res.position.x, res.position.y}, amount = res.amount}
        if res.initial_amount then res2.initial_amount = res.initial_amount end
        res.destroy()
      end
    end
  end
end

script.on_event(defines.events.on_player_built_tile, function(event)
  local tile = event.tile
  
  if tile.mineable_properties.minable then
    local surface = game.surfaces[event.surface_index]
    for _,tilepos in pairs(event.tiles) do
      RemoveOres(surface, tilepos.position.x, tilepos.position.y)
    end
  end
end)

script.on_event(defines.events.on_player_mined_tile, function(event)
  if settings.global["coverup-permanent"].value then return end
  
  local surface = game.surfaces[event.surface_index]
  local surface2 = game.surfaces[surface.name.."__hiddenores__"]
  if surface2 then
    for _,tilepos in pairs(event.tiles) do
      RestoreOres(surface, surface2, tilepos.position.x, tilepos.position.y)
    end
  end
end)


script.on_event(defines.events.on_robot_built_tile, function(event)
  local tile = event.tile
  local robot = event.robot
  
  if tile.mineable_properties.minable then
    local surface = robot.surface
    for _,tilepos in pairs(event.tiles) do
      RemoveOres(surface, tilepos.position.x, tilepos.position.y)
    end
  end
end)

script.on_event(defines.events.on_robot_mined_tile, function(event)
  if settings.global["coverup-permanent"].value then return end
  local robot = event.robot
  
  local surface = robot.surface
  local surface2 = game.surfaces[surface.name.."__hiddenores__"]
  if surface2 then
    for _,tilepos in pairs(event.tiles) do
      RestoreOres(surface, surface2, tilepos.position.x, tilepos.position.y)
    end
  end
end)

