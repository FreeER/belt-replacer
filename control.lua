require "util"
require "defines"
require "helperfunctions" -- hf

game.oninit(function()
  glob.replacers = {}
  setupBelts()
  glob.release = false
  if not glob.release then
    game.player.insert{name="replacer", count=10}
    game.player.insert{name="basic-transport-belt", count=50}
    game.player.insert{name="fast-transport-belt", count=50}
    game.player.insert{name="express-transport-belt", count=50}
    game.player.insert{name="logistic-chest-passive-provider", count=5}
  end
end)

game.onload(function()
  glob.replacers = glob.replacers or {}
  glob.release = glob.release or true
  setupBelts()
end)

game.onevent(defines.events.onbuiltentity, function(event)
  if event.createdentity.name == "replacer" then
    if event.mod and event.mod == "replacer" then event.createdentity = game.findentitiesfiltered{name="replacer", area=hf.getboundingbox(event.createdentity.position, 1)}[1] end
    local chest = game.findentitiesfiltered{type="logistic-container", area=hf.getboundingbox(event.createdentity.position, 10)}
    if #chest < 1 then
      chest = game.findentitiesfiltered{type="container", area=hf.getboundingbox(event.createdentity.position, 10)}
      if #chest < 1 then
        game.player.print(game.gettext("outofrange"))
        chest = false
      end
    end
    if chest then
      for _, possiblechest in pairs(chest) do
        if not possiblechest.getinventory(defines.inventory.chest).isempty() then
          contents = possiblechest.getinventory(defines.inventory.chest).getcontents()
          for belt, speed in pairs(glob.belts) do
            if contents[belt] then
              chest = possiblechest
              break
            end
          end
          if chest.equals(possiblechest) then
            table.insert(glob.replacers, {entity = event.createdentity, chest=chest, lastbelt=nil})
            break
          end
        end
      end
      game.player.gui.center.add({type="flow", direction="vertical", name="replacer_flow"})
      game.player.gui.center.replacer_flow.add({type="flow", direction="horizontal", name="replacer_toolbar"})
      game.player.gui.center.replacer_flow.replacer_toolbar.add({type="label", name="replacer_label", caption=game.gettext("whatbelt")})
      for beltname, speed in pairs(glob.belts) do
        game.player.gui.center.replacer_flow.replacer_toolbar.add({type="button", name="replacermod-"..beltname, caption=game.getlocalisedentityname(beltname)})
      end
    else
      event.createdentity.destroy()
      game.player.insert{name="replacer", count=1}
    end
  end
end)

game.onevent(defines.events.onguiclick, function(event)
  if event.element.name:find("replacermod-") then -- bug with testmode!
    glob.replacers[#glob.replacers].replace_with = event.element.name:sub(13)
    if game.player.gui.center.replacer_flow then game.player.gui.center.replacer_flow.destroy() end
  end
end)

game.onevent(defines.events.ontick, function(event)
  if event.tick % 20 == 15 and #glob.replacers > 0 then
    for i, replacer in ipairs(glob.replacers) do
      if not replacer.entity.valid then
        replacerDone(i)
      else
        if not replacer.replace_with then
          replacer.entity.active = false
        else
          if replacer.entity.active == false then replacer.entity.active = true end
          local area = "placeholder"
          if replacer.lastbelt then
            area = hf.getboundingbox(replacer.lastbelt, 1.5)
          else
            area = hf.getboundingbox(replacer.entity.position, 4)
          end
          -- find nearby belts, remove belts that match the ones we shouldn't replace
          -- and sort the table based on the distance from the replacer
          local belts = removeMatchingBelts(game.findentitiesfiltered{type = "transport-belt", area=area}, replacer.replace_with)
          -- arg, why does table.sort not return the table it modified? lol It was annoying to figure out why belts was nil!
          table.sort(belts, function(a, b) return util.distance(replacer.entity.position, a.position)<util.distance(replacer.entity.position, b.position) end)
          if #belts > 0 then
            for _, belt in pairs(belts) do
              replacer.entity.setcommand{type=defines.command.gotolocation, destination=belt.position, Radius=1, Distraction=defines.distraction.none}
              if replacer.chest.valid then
                if replacer.chest.getitemcount(replacer.replace_with) > 0 then
                  replacer.chest.getinventory(defines.inventory.chest).remove{name=replacer.replace_with, count=1}
                  replacer.chest.insert{name=belt.name, count=1}
                  replacer.lastbelt = game.createentity{name=replacer.replace_with, position=belt.position, direction=belt.direction, force=game.player.force}.position
                  for _, item in ipairs(game.findentitiesfiltered{type="item-entity", area=hf.getboundingbox(replacer.lastbelt, 1)}) do
                    game.createentity{name=item.name, position=item.position, stack=item.stack}
                    item.destroy()
                  end
                  belt.destroy()
                else
                  replacer.entity.setcommand{type=defines.command.gotolocation, destination=replacer.chest.position, Radius=1, Distraction=defines.distraction.none}
                  -- prevent unit from wandering... actually that would probably stop it before it reaches the chest.
                  -- replacer.entity.active = false
                end
              else
                replacerDone(i, game.gettext("chestgone"))
              end
              break -- only do one belt at a time
            end
          elseif replacer.lastbelt == nil then
            replacerDone(i, game.gettext("done"))
            --if #glob.replacers == 0 then replacer.replace_with = nil end
          else
            replacer.lastbelt = nil
          end
        end
      end
    end
  end
end)

function replacerDone(index, message)
  if glob.replacers[index].chest.valid and glob.replacers[index].chest.caninsert{name="replacer", count=1} then
    glob.replacers[index].chest.insert{name="replacer", count=1}
    glob.replacers[index].entity.destroy()
  elseif glob.replacers[index].entity.valid then 
    if glob.replacers[index].chest.valid then
      glob.replacers[index].entity.setcommand{type=defines.command.gotolocation, destination=glob.replacers[index].chest.position, Radius=1, Distraction=defines.distraction.none}
    else
      glob.replacers[index].entity.setcommand{type=defines.command.gotolocation, destination=glob.replacers[index].lastbelt, Radius=1, Distraction=defines.distraction.none}
    --glob.replacers[index].entity.active = false -- prevent wandering while awaiting pickup
    end
  end
  if message then game.player.print(tostring(message)) end
  table.remove(glob.replacers, index)
end

function clearGUI(gui, parent) -- stolen, I mean borrowed, from testing mode mod :)
  if gui ~= nil then
    local name = gui.name
    gui.destroy()
    -- recreating and removing to make sure no invisible element is left behind.
    parent.add({type="flow", direction="horizontal", name=name}).destroy()
  end
end

function removeMatchingBelts(belts, removename)
  local remove = {}
  for i, belt in pairs(belts) do
    if belt.name == removename then
      table.insert(remove, i+1) -- add 1 to i because for loops apparently start at 0 even though lua tables are indexed with 1
    end
  end
  
  return hf.removeFromTable(belts, remove, true, false)
end

function setupBelts()
  glob.belts = {}
  local speed = "placeholder"
  for _, belt in pairs(game.entityprototypes) do
    if belt.type == "transport-belt" then 
      for _, recipe in pairs(game.player.force.recipes) do
        speed = recipe.name:match("replacermod%-%[%[.+%]%]"..hf.escapeString(belt.name))
        if speed then
          speed = tonumber(speed:sub(15, -#belt.name -3)) -- transform speed into a number
          break
        end
      end
      -- set speed (and undo multiplication from data.raw to remove decimal point)
      -- or default to slightly faster than express belt speed if no speed recipe found
      glob.belts[belt.name] = speed/1000000 or 0.094
    end
  end
end
