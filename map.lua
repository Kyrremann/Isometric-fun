local isoengine = {}
local TILES = {}
local MAP = {}
local SCALEMODE = false
local SCROLLMODE = false
local TILESCALE = 1
local FOLDER = nil
local SORT_FOLDER = false
local DEFAULT_TILE = nil
local CAMERA = {
   x = gr.getWidth() / 2,
   y = 0
}
local TILE_WIDTH_HALF = nil
local TILE_HEIGHT_HALF = nil

local index = 1
local scrollIndex = 0
local rotateIndex = 0

local function drawTile(tile, map)
   screen = isoengine:mapToScreen(map)
   screen.y = screen.y - (tile:getHeight() - 83)
   gr.draw(tile, -- drawable
      screen.x * TILESCALE, screen.y * TILESCALE, -- cords
      0, -- rotation
      TILESCALE, TILESCALE -- scale
   )
end

function isoengine:draw()
   local screen = {}
   local map = isoengine:getMouseAsMap()
   gr.push()
   gr.translate(CAMERA.x, CAMERA.y)
   for y, vy in ipairs(MAP) do
      for x, shape in ipairs(vy) do
	 local tile = shape.tile
	 if map.x == x and map.y == y then
	    tile = TILES[index]
	 elseif not tile then
	    tile = TILES[202]
	 end
	 drawTile(tile, shape.map)
      end
   end
   gr.pop()
end

function isoengine:mapToScreen(map)
   local screen = {}
   screen.x = (map.x - map.y) * TILE_WIDTH_HALF
   screen.y = (map.x + map.y) * TILE_HEIGHT_HALF
   return screen
end

function isoengine:screenToMap(screen)
   local map = {}
   screen.x = (screen.x - CAMERA.x) / TILESCALE
   screen.y = (screen.y - CAMERA.y) / TILESCALE
   map.x = math.floor(math.floor(screen.x / TILE_WIDTH_HALF + screen.y / TILE_HEIGHT_HALF) / 2)
   map.y = math.floor(math.floor(screen.y / TILE_HEIGHT_HALF -(screen.x / TILE_WIDTH_HALF)) / 2)
   return map
end

function isoengine:getMouseAsMap()
   return isoengine:screenToMap({ x = mo.getX(), y = mo.getY() })
end

local function validateTileScale()
   if TILESCALE < .2 then
      TILESCALE = .2
   elseif TILESCALE > 2 then
      TILESCALE = 2
   end
end

local function validateIndex()
   if index < 1 then
      index = #TILES
   elseif index > #TILES then
      index = 1
   end
end

function isoengine:keypressed(key)
   if key == '1' then
      index = 1
   elseif key == '+' then
      if SCALEMODE then
	 TILESCALE = TILESCALE + .2
      else
	 index = index + 1
      end
   elseif key == "-" then
      if SCALEMODE then
	 TILESCALE = TILESCALE - .2
      else
	 index = index - 1
      end
   elseif key == "lshift" then
      SCALEMODE = true
   elseif key == "w" then
      CAMERA.y = CAMERA.y + 10
   elseif key == "s" then
      CAMERA.y = CAMERA.y - 10
   elseif key == "a" then
      CAMERA.x = CAMERA.x + 10
   elseif key == "d" then
      CAMERA.x = CAMERA.x - 10
   end

   validateIndex()
   validateTileScale()
end

function isoengine:keyreleased(key)
   if key == "lshift" then
      SCALEMODE = false
   end
end

local function createTile(tile, map)
   return {
      tile = tile,
      map = map,
      locked = false
   }
end

function isoengine:mousepressed(x, y, button)
   if button == "l" then
      local map = isoengine:getMouseAsMap()
      MAP[map.y][map.x] = createTile(TILES[index], map)
   elseif button == "r" then
      rotateIndex = rotateIndex + 1
      if rotateIndex > 4 then
	 rotateIndex = 1
      end
   elseif button == "wu" then
      if SCALEMODE then
	 TILESCALE = TILESCALE + .2
      else
	 index = index + 1
      end
   elseif button == "wd" then
      if SCALEMODE then
	 TILESCALE = TILESCALE - .2
      else
	 index = index - 1
      end
   end

   validateIndex()
   validateTileScale()
end

local function initTiles()
   local function formatId(n)
      if n < 10 then
	 return "00" .. n
      elseif n < 100 then
	 return "0" .. n
      end
      return n
   end

   local files = love.filesystem.getDirectoryItems(FOLDER)
   for k, file in ipairs(files) do
      table.insert(TILES, gr.newImage(FOLDER .. "/" .. file))
   end
   if SORT_FOLDER then
      table.sort(TILES)
   end

   if not DEFAULT_TILE then
      DEFAULT_TILE = #TILES
   end
end

local function initMap(width, height)
   for y=1, height do
      MAP[y] = {}
      for x=1, width do
	 MAP[y][x] = createTile(TILES[DEFAULT_TILE], { x = x, y = y })
      end
   end
end

function isoengine:getTile(index)
   return TILES[index]
end

function isoengine:getTileCount()
   return #TILES
end

function isoengine:getScale()
   return TILESCALE
end

function isoengine:getTileIndex()
   return index
end

function isoengine:setup(config)
   TILE_WIDTH_HALF = config.TILEWIDTH / 2
   TILE_HEIGHT_HALF = config.TILEHEIGHT / 2
   FOLDER = config.folder
   SORT_FOLDER = config.sortFolder
   DEFAULT_TILE = config.defaultTile or nil

   initTiles()
   initMap(30, 30)
end

return isoengine
