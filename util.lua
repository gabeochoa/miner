util = {}
function util.snap_to_grid(x)
    return TILE_SIZE * math.floor(x / TILE_SIZE)
end

Base = Object:extend()
function Base:new(x, y)
    self.raw = vec(x, y)
    self.stack_size = 1
    self.max_stack = 1
    self.is_held = false
end
function Base:setPos(v)
    self.raw = v
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
function Base:type()
    return "Base"
end
function Base:inc_stack(amt)
    self.stack_size = self.stack_size + amt
end
function Base:can_stack_more(amt)
    if self.stack_size + amt > self.max_stack then
        return false
    end
    return true
end
function Base:readable_name()
    return self:type() .. "(" .. self.stack_size .. " / " .. self.max_stack .. ")"
end
function Base:toggle_held()
    self.is_held = not self.is_held
end
function Base:draw()
    if self.is_held then
        return
    end
    local c = (self:color():to01())
    love.graphics.setColor(c.r, c.g, c.b, c.a)
    love.graphics.rectangle("fill", self:x(), self:y(), TILE_SIZE, TILE_SIZE)
end
