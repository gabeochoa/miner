util = {}
function util.snap_to_grid(x)
    return TILE_SIZE * math.floor(x / TILE_SIZE)
end

Base = Object:extend()
function Base:new(x, y)
    self.raw = vec(x, y)
end
function Base:x()
    return self.raw.x
end
function Base:y()
    return self.raw.y
end
function Base:update(dt)
end
function Base:color()
    return color.acid_green
end
function Base:alpha()
    return 1
end
function Base:readable_name()
    return "__PLEASE_SET_READABLE_NAME__"
end
function Base:draw()
    local c = (self:color():to01())
    love.graphics.setColor(c.r, c.g, c.b, c.a)
    love.graphics.rectangle("fill", self:x(), self:y(), TILE_SIZE, TILE_SIZE)
end