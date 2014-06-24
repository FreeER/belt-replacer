module("hf", package.seeall)

function getboundingbox(position, radius) 
  return {{position.x-radius, position.y-radius}, {position.x+radius,position.y+radius}} 
end 

function writeDebug(message, conditions) 
  local conditionsMet = true 
  if conditions then 
    if type(conditions) == "boolean" then 
      conditionsMet = conditions 
    elseif type(conditions) == "table" then 
      for _, condition in pairs(conditions) do 
        if type(condition) == "boolean" and not condition then conditionsMet = false end 
      end 
    end 
  end 
  if not glob.release and conditionsMet then game.player.print(serpent.block(message)) end 
end 

function removeFromTable(fromtable, remove, preadjusted, mixed)
  if not remove or type(remove) ~= "table" then
    error("improper entries to remove!", 2)
  end
  if type(fromtable) ~= "table" then error("No table given!") end
  if preadjusted then preadjusted = 0 else preadjusted = 1 end
  if mixed then
    local arraysremoved = 0
    for i, index in ipairs(remove) do
      -- subtract i because the positions will be adjusted 'down' when an entry is removed
      -- if not preadusted for the fact that for loops start at 0 add 1
      if type(index) == number then -- array index
        table.remove(fromtable, index-arraysremoved+preadjusted)
        arraysremoved = arraysremoved + 1
      else -- hash index
        table.remove(fromtable, index)
      end
    end
  else
    if fromtable[1] then -- array type table
      for i, index in ipairs(remove) do
        -- subtract i because the positions will be adjusted 'down' when an entry is removed
        table.remove(fromtable, index-i+preadjusted)
      end
    else -- hash table
      table.remove(fromtable, index)
    end
  end
  return fromtable
end

function findfirstentityfiltered(typea, name, boundingbox)
  if not boundingbox then
    error("no bounding box provided!", 2)
  elseif type(boundingbox) ~= "table" then
    error("provided boundingbox is not a table!")
  elseif not typea then
    error("type parameter not provided!", 2)
  elseif type(typea) ~= "string" or typea ~= "type" or typea ~= "name" then
    error("The first (type) parameter must be 'type' or 'name'!", 2)
  elseif not name or not type(name) == "string" then
    error("You didn't give a string for the"..typea, 2)
  end
  
  local params = {}
  params[type] = name
  params["area"] = boundingbox
  
  return game.findentitiesfiltered(params)[1]
end

function escapeString(original)
  magicChars = {"%.", "%%", "%+", "%*", "%-", "%?"}
  local copy = original
  for _, char in ipairs(magicChars) do
    copy = copy:gsub(char, "%"..char)
  end
  return copy
end
