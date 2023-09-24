local const = require("constants")

local function load_water_tile(index)
  assert(index >= 1 and index <= 4)
  local file_path = "assets/water-tile" .. index .. ".png"
  local water_tile = love.graphics.newImage(file_path)
  return water_tile
end

local water_tile_imgs = {
  load_water_tile(1),
  load_water_tile(2),
  load_water_tile(3),
  load_water_tile(4)
}

local function make_water_layer(tile_img, n_rows, n_cols)
  local canvas = love.graphics.newCanvas(800, 600)
  love.graphics.setColor(1, 1, 1)
  canvas:renderTo(function()
    for i = 1, n_rows do
      for j = 1, n_cols do
        local x = (j - 1) * (const.TileSize * const.TileScale)
        local y = (i - 1) * (const.TileSize * const.TileScale)
        love.graphics.draw(tile_img, x, y, 0, const.TileScale, const.TileScale)
      end
    end
  end)
  return canvas
end

local function make_water_layers()
  local water_layers = {}
  for i = 1, 4 do
    water_layers[i] = make_water_layer(water_tile_imgs[i], const.RowCount, const.ColCount)
  end
  return water_layers
end

local Water = {}

function Water:new()
  local w =  {}
  setmetatable(w, self)
  self.__index = self
  self.frames = make_water_layers()
  self.current_frame = 1
  self.frame_duration = 0.15
  self.current_frame_time = 0
  return w
end

function Water:draw()
  local frame = self.frames[self.current_frame]
  love.graphics.draw(frame)
  --love.graphics.setColor(44 / 255, 182 / 255, 210 /255)
  --love.graphics.rectangle("fill", 0, 0, 800, 600)
end

function Water:update_water(dt)
  self.current_frame_time = self.current_frame_time + dt
  if self.current_frame_time >= self.frame_duration then
    self.current_frame_time = 0
    self.current_frame = (self.current_frame + 1)
    if self.current_frame > #self.frames then
      self.current_frame = 1
    end
  end
end

return Water
