require "util"
require "deepcopy"
require "classic"

Person = Base:extend()
function Person:new(x, y)
    Person.super.new(self, x or WORLD_MAX / 2, y or WORLD_MAX / 2)
    self.hand_size = 1
end

function Person:speed() return 2 end

function Person:type() return "Person" end

function Person:px() return self:snap_pos().x end

function Person:py() return self:snap_pos().y end

function Person:color() return color.off_white end

function Person:draw()
    local c = (self:color():to01())
    love.graphics.setColor(c.r, c.g, c.b, c.a)
    love.graphics.rectangle("fill", self:px(), self:py(), TILE_SIZE, TILE_SIZE)
end

--- @return Base|nil
function Person:tile_underneath()
    return entity_helper.matching(entities, self.p, { hide_held = true })
end

--- @param dx number
--- @param dy number
--- @return boolean
function Person:can_go(dx, dy)
    for i = 1, self:speed(), 1 do
        local step = vec.snap_to_grid(
            (self:x() + (dx * i)),
            (self:y() + (dy * i))
        )
        local possible_wall = entity_helper.matching(entities, step, { impassible = true })
        if possible_wall then
            return false
        end
    end
    return true
end

function Person:move(dx, dy, dt)
    local dt = dt or 1;
    if not self:can_go(dx, dy) then
        return
    end
    self.raw = vec(
        self.raw.x + (dx * dt * self:speed()),
        self.raw.y + (dy * dt * self:speed())
    )
    self.p = self:snap_pos()
end
