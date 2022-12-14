util = {}
function util.sign(x)
    if x > 0 then return 1
    elseif x < 0 then return -1
    else return 0
    end
end
function util.snap_to_grid(x)
    return TILE_SIZE * math.floor(x / TILE_SIZE)
end

function util.rand_on_grid(mn, mx)
    return util.snap_to_grid(love.math.random(mn, mx))
end

function util.spairs(t, order)
    -- collect the keys
    local keys = {}
    for k in pairs(t) do keys[#keys + 1] = k end

    -- if order function given, sort by it by passing the table and keys a, b,
    -- otherwise just sort the keys
    if order then
        table.sort(keys, function(a, b) return order(t, a, b) end)
    else
        table.sort(keys)
    end

    -- return the iterator function
    local i = 0
    return function()
        i = i + 1
        if keys[i] then
            return keys[i], t[keys[i]]
        end
    end
end

--- @param a vec
---@param b vec 
---@return number
function util.dist(a, b)
    return util.dist_(a.x, a.y, b.x, b.y)
end

--- @param ax number
---@param bx number
---@param ay number
---@param by number
---@return number
function util.dist_(ax, bx, ay, by)
    return math.sqrt(math.pow(bx - ax, 2) + math.pow(by - ay, 2))
end

---@param inputstr string
---@param sep string
---@return string[]
function util.split(inputstr, sep)
    if sep == nil then sep = "%s" end
    local t={}
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
            table.insert(t, str)
    end
    return t
end

DrawIndexes = {
    BG = 0,
    Furniture = 1,
    Material = 2,
}

---@class Base
Base = Object:extend()
function Base:new(x, y)
    self.raw = vec(x, y)
    self.stack_size = 1
    self.max_stack = 1
    self.is_held = false
end

--- @param v vec
function Base:setPos(v) self.raw = v end

function Base:x() return self:pos().x end

function Base:y() return self:pos().y end

function Base:pos() return self.raw end

function Base:snap_pos() return vec.snap_to_grid(self.raw.x, self.raw.y) end

function Base:update(dt) end

function Base:draw_index(v) return DrawIndexes.BG end

function Base:color() return color.acid_green end

function Base:alpha() return 1 end

function Base:type() return "Base" end

function Base:inc_stack(amt) self.stack_size = self.stack_size + amt end

function Base:can_stack_more(amt) return self:amt_to_max() > amt end

function Base:amt_to_max() return self.max_stack - self.stack_size end

function Base:readable_name()
    return self:type() .. "(" .. self.stack_size .. " / " .. self.max_stack .. ")"
end

function Base:toggle_held() self.is_held = not self.is_held end

function Base:can_walk_on() return true end

function Base:draw()
    if self.is_held then
        return
    end
    local c = (self:color():to01())
    love.graphics.setColor(c.r, c.g, c.b, c.a)
    love.graphics.rectangle("fill", self:x(), self:y(), TILE_SIZE, TILE_SIZE)
end
