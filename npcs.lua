require "util"
require "person"

NPC = Person:extend()
function NPC:new(x, y)
    NPC.super.new(self, x or WORLD_MAX / 2, y or WORLD_MAX / 2)
    self.target = nil
end

function NPC:speed() return 5 * TILE_SIZE end

function NPC:type() return "NPC" end

function NPC:color()
    return color.turquoise
end

function NPC:update(dt)
    self:ai(dt)
end


function NPC:ai(dt)
    if self.target == nil then
        self.target = vec.rand_on_grid(0, WORLD_MAX)
    end
    local dx = 0
    local dy = 0
    if self.target.x > self:px() then dx = 1 end
    if self.target.y > self:py() then dy = 1 end
    if self.target.x < self:px() then dx = -1 end
    if self.target.y < self:py() then dy = -1 end
    if dx == 0 and dy == 0 then self.target = nil end

    self:move(dx * dt, 0)
    self:move(0, dy * dt)
end

function NPC:draw()
    local c = (self:color():to01())
    love.graphics.setColor(c.r, c.g, c.b, c.a)
    love.graphics.rectangle("fill", self:x(), self:y(), TILE_SIZE, TILE_SIZE)
end
