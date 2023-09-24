local Sprite = {
  all_sprites = {}
}

Sprite.__index = Sprite

function Sprite:new(quad, scale)
  scale = scale or 1
  local sprite = {
    quad  = quad,
    scale_x = scale,
    scale_y = scale,
    w     = quad:getWidth() * scale,
    h     = quad:getHeight() * scale,
    rot   = 0
  }
  setmetatable(sprite, Sprite)
  table.insert(Sprite.all_sprites, sprite)
  return sprite
end

function Sprite:draw(x, y)
  love.graphics.setColor(1, 1, 1)
  love.graphics.draw(
    self.quad,
    x - self.w / 2,
    y - self.h / 2,
    self.rot,
    self.scale_x,
    self.scale_y)
end

function Sprite:draw_reflection(x, y)
  love.graphics.setColor(1, 1, 1)
  love.graphics.draw(
    self.quad,
    x - self.w / 2,
    y + self.h * 1.5,
    self.rot,
    self.scale_x,
    -self.scale_y)
end

return Sprite
