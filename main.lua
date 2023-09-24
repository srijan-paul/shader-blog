love.graphics.setLineStyle("rough")
love.graphics.setDefaultFilter("nearest", "nearest")

local const = require("constants")
local Water = require("water")
local Sprite = require("sprite")

local reflection_shader = love.graphics.newShader [[
uniform float time;
uniform float wave_height;
uniform float wave_speed;
uniform float wave_freq;


vec4 effect(vec4 color, Image texture, vec2 uv, vec2 pixel_coords) { 
  // Displace the `x` coordinate. 
  uv.x +=
    sin((uv.y + time * wave_speed) * wave_freq)
    * cos((uv.y + time * wave_speed) * wave_freq * 0.5)
    * wave_height;

  // Displacement in `y` is half that of `x`.
  // Displacing `x` and `y` equally looks unnatural
  uv.y +=
    sin((uv.x + time * wave_speed) * wave_freq)
    * cos((uv.x + time * wave_speed) * wave_freq * 0.5)
    * wave_height * 0.5;

  vec4 pixel = Texel(texture, uv);
  // apply a blue tint to the reflection
  pixel.b += 0.2;
  return pixel;
}
]]


-- dimensions of our world in tiles.
-- a square body of water in the center
local lake = {
  begin = { row = 4, col = 3 },
  width = 5,
  height = 3
}


local grid = {}
for i = 1, const.RowCount, 1 do
  grid[i] = {}
  for j = 1, const.ColCount, 1 do
    if i >= lake.begin.row and i < lake.begin.row + lake.height and
        j >= lake.begin.col and j < lake.begin.col + lake.width then
      grid[i][j] = const.TileWater
    else
      grid[i][j] = const.TileGround
    end
  end
end

local water_border_image = love.graphics.newImage("assets/tile.png")
local w, h = water_border_image:getDimensions()
local water_borders = {
  top_left = love.graphics.newQuad(0, 0, 16, 16, w, h),
  top = love.graphics.newQuad(16, 0, 16, 16, w, h),
  top_right = love.graphics.newQuad(32, 0, 16, 16, w, h),
  left = love.graphics.newQuad(0, 16, 16, 16, w, h),
  right = love.graphics.newQuad(32, 16, 16, 16, w, h),
  bottom_left = love.graphics.newQuad(0, 32, 16, 16, w, h),
  bottom = love.graphics.newQuad(16, 32, 16, 16, w, h),
  bottom_right = love.graphics.newQuad(32, 32, 16, 16, w, h)
}

local function draw_water_border(row, col)
  local scale = const.TileScale
  local x = (col - 1) * (const.TileSize * scale)
  local y = (row - 1) * (const.TileSize * scale)
  local tile_kind = grid[row][col]
  if tile_kind ~= const.TileWater then return end
  if row == lake.begin.row and col == lake.begin.col then
    love.graphics.draw(water_border_image, water_borders.top_left, x, y, 0, scale, scale)
  elseif row == lake.begin.row and col == lake.begin.col + lake.width - 1 then
    love.graphics.draw(water_border_image, water_borders.top_right, x, y, 0, scale, scale)
  elseif row == lake.begin.row + lake.height - 1 and col == lake.begin.col then
    love.graphics.draw(water_border_image, water_borders.bottom_left, x, y, 0, scale, scale)
  elseif row == lake.begin.row + lake.height - 1 and col == lake.begin.col + lake.width - 1 then
    love.graphics.draw(water_border_image, water_borders.bottom_right, x, y, 0, scale, scale)
  elseif row == lake.begin.row then
    love.graphics.draw(water_border_image, water_borders.top, x, y, 0, scale, scale)
  elseif row == lake.begin.row + lake.height - 1 then
    love.graphics.draw(water_border_image, water_borders.bottom, x, y, 0, scale, scale)
  elseif col == lake.begin.col then
    love.graphics.draw(water_border_image, water_borders.left, x, y, 0, scale, scale)
  elseif col == lake.begin.col + lake.width - 1 then
    love.graphics.draw(water_border_image, water_borders.right, x, y, 0, scale, scale)
  end
end

local function draw_water_borders()
  love.graphics.setColor(1, 1, 1)
  for i = lake.begin.row, lake.begin.row + lake.height do
    for j = lake.begin.col, lake.begin.col + lake.width do
      draw_water_border(i, j)
    end
  end
end

local function get_ground_tiles_layer(screen_width, screen_height)
  local canvas = love.graphics.newCanvas(screen_width, screen_height)
  local dirt_tile = love.graphics.newImage("assets/dirt-tile.png")

  canvas:renderTo(function()
    for i = 0, const.RowCount - 1, 1 do
      for j = 0, const.ColCount - 1, 1 do
        local x = j * (const.TileSize * const.TileScale)
        local y = i * (const.TileSize * const.TileScale)
        local tile_kind = grid[i + 1][j + 1]
        if tile_kind == const.TileGround then
          love.graphics.draw(dirt_tile, x, y, 0, const.TileScale, const.TileScale)
        end
        draw_water_borders()
      end
    end
  end)

  return canvas
end


local ground_tiles, water_tiles
function love.load()
  local screen_width  = love.graphics.getWidth()
  local screen_height = love.graphics.getHeight()
  ground_tiles        = get_ground_tiles_layer(screen_width, screen_height)
  water_tiles         = Water:new()
end

local tree_image = love.graphics.newImage("assets/tree.png")
local tree = {
  sprite = Sprite:new(tree_image, 4),
  x = 300,
  y = 135
}

reflection_shader:send("wave_height", 0.02)
reflection_shader:send("wave_speed", 0.1)
reflection_shader:send("wave_freq", 45.0)
function love.draw()
  water_tiles:draw()

  local time = love.timer.getTime()
  reflection_shader:send("time", time)

  love.graphics.setShader(reflection_shader)
  tree.sprite:draw_reflection(tree.x, tree.y)
  love.graphics.setShader()
  love.graphics.draw(ground_tiles)
  tree.sprite:draw(tree.x, tree.y)
end

function love.update(dt)
  water_tiles:update_water(dt)
end
