vec = Object:extend()
function vec:new(x, y)
    self.x = x
    self.y = y
end

function vec:__add(a, b)
    return vec:new(a.x + b.x, a.y + b.y)
end

function vec:__tostring()
    return "vec(" .. self.x .. "," .. self.y .. ")"
end
