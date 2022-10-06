---@class vec
vec = Object:extend()

--- @param x number
--- @param y number
function vec:new(x, y)
    self.x = x
    self.y = y
end

--- @param a vec
--- @param b vec
--- @return vec
function vec.__add(a, b)
    return vec(a.x + b.x, a.y + b.y)
end

--- @param a vec
--- @param b number
--- @return vec
function vec.__mul(a, b)
    local v, s = a, b
    return vec(v.x * s, v.y * s)
end

function vec:__tostring()
    return "vec(" .. self.x .. "," .. self.y .. ")"
end

--- @param a vec
--- @param b vec
--- @return boolean
function vec.__eq(a, b)
    return a.x == b.x and a.y == b.y
end

--- @param mn number
--- @param mx number
--- @return vec
function vec.rand_on_grid(mn, mx)
    return vec(
        util.rand_on_grid(mn, mx),
        util.rand_on_grid(mn, mx)
    )
end

--- @param x number
--- @param y number
--- @return vec
function vec.snap_to_grid(x, y)
    return vec(
        util.snap_to_grid(x),
        util.snap_to_grid(y)
    )
end
