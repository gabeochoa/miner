require "util"

Player = Base:extend()
function Player:new(x, y)
    Player.super.new(self, x or WORLD_MAX / 2, y or WORLD_MAX / 2)
    self.p = vec(self.raw.x, self.raw.y)
end

function Player:px()
    return self.p.x
end
function Player:py()
    return self.p.y
end

function Player:color()
    return color.off_white
end

function Player:draw()
    local c = (self:color():to01())
    love.graphics.setColor(c.r, c.g, c.b, c.a)
    love.graphics.rectangle("fill", player:px(), player:py(), TILE_SIZE, TILE_SIZE)
end

function Player:move(dx, dy)
    local spd = 2
    self.raw =
        vec(
        self.raw.x + (dx * spd),
        self.raw.y + (dy * spd)
        --
    )
    self.p =
        vec(
        util.snap_to_grid(self.raw.x),
        util.snap_to_grid(self.raw.y)
        --
    )
    print(self.raw.x .. " ", self.p)
end

function Player:tile_underneath()
    local match = entities.matching(self.p)
    if match == nil then return "" end
    return match:readable_name();
end
