Object = require "classic"
require "color"
require "vec"

Batteries = require("batteries")

TILE_SIZE = 10
WINDOW_W = 800
WINDOW_H = 600
WORLD_MAX = 600

require "util"
require "player"
require "npcs"

function __newindex(t, k, v)
    print("*update of element " .. tostring(k) ..
        " to " .. tostring(v))
end

-- types
Material = Base:extend()
function Material:new(x, y)
    Material.super.new(self, x, y)
    self.max_stack = 10
end

function Material:draw_index()
    return DrawIndexes.Material
end

-- metal
Metal = Material:extend()
function Metal:type()
    return "Metal"
end

function Metal:new(x, y)
    Metal.super.new(self, x, y)
end

function Metal:color()
    return color.metallic_blue
end

-- ...

-- wall
Wall = Material:extend()
function Wall:type() return "Wall" end

function Wall:new(x, y) Wall.super.new(self, x, y) end

function Wall:color() return color.hot_pink end

function Wall:can_walk_on() return false; end

-- end wall

Dir = {
    Right = 0,
    Down = 1,
    Left = 2,
    Up = 3,
};

Tractor = Base:extend()
function Tractor:type()
    return "Tractor"
end

function Tractor:draw_index()
    return DrawIndexes.Furniture
end

function Tractor:new(x, y)
    Tractor.super.new(self, x, y)
    self.max_stack = 1
    self.facing = Dir.Right
    self.reach = 10

    self.on_track = {}

    self.anim_timer = 0
    self.anim_step_r = 0.1;
    self.anim_step = self.anim_step_r;
end

function Tractor:color()
    return color.lavender
end

function Tractor:beamcolor()
    return color.pale_lavender
end

function Tractor:can_take()
    return #self.on_track < self.reach
end

function Tractor:place_on_track(e, location)
    -- todo items should either not spawn on beam or beam should pick them automatically
    -- todo support dropping items anywhere on track
    -- todo validate can place
    table.insert(self.on_track, e);
end

--- @return vec
function Tractor:dropoff_loc()
    -- todo support other directions
    return vec(self:x() + ((self.reach + 1) * TILE_SIZE), self:y())
end

function Tractor:shuffle_items()
    -- interate backwards
    for i = #self.on_track, 1, -1 do
        self:shuffle_item(i)
    end
end

function Tractor:shuffle_item(i)
    local item = self.on_track[i]
    if item:pos() == self:dropoff_loc() then return end

    -- todo find new location with direction
    local new_location = vec(item:x() + 1, item:y())

    local at_new = entity_helper.matching(entities, new_location)
    if at_new == nil then -- empty, just move it over
        item:setPos(new_location)
        return
    end
    -- has item in new, but types dont match so no merge
    if at_new ~= nil and at_new:type() ~= item:type() then
        return
    end
    -- we should merge,
    local amt_can_fit = at_new:amt_to_max();
    local amt_to_move = math.min(amt_can_fit, item.stack_size)
    at_new:inc_stack(amt_to_move)
    item:inc_stack(-amt_to_move)
    -- delete old item if empty
    if item.stack_size == 0 then
        table.remove(self.on_track, i)
        entity_helper.remove(entities, item)
    end
end

function Tractor:update(dt)
    Tractor.super.update(self, dt);
    self.anim_step = self.anim_step - dt
    if self.anim_step <= 0 then
        self.anim_timer = (self.anim_timer + 1) % self.reach
        self.anim_step = self.anim_step_r
        --
        self:shuffle_items()
    end
end

function Tractor:draw()
    Tractor.super.draw(self);
    for i = 1, self.reach, 1 do
        local c = (self:beamcolor():to01())
        love.graphics.setColor(c.r, c.g, c.b, c.a / ((i - self.anim_timer) % self.reach))
        love.graphics.rectangle("fill", self:x() + (i * TILE_SIZE), self:y(), TILE_SIZE, TILE_SIZE)
    end
end

require "entities"

-- main

function love.load()
    player = Player()
    entities.load_world()
end

function player_keypress(dt)
    local dx = 0
    local dy = 0
    if love.keyboard.isDown("d") then
        dx = 1
    elseif love.keyboard.isDown("a") then
        dx = -1
    end
    if love.keyboard.isDown("s") then
        dy = 1
    elseif love.keyboard.isDown("w") then
        dy = -1
    end
    player:move(dx, 0)
    player:move(0, dy)
end

function love.keyreleased(key)
    if key == "space" then
        player:pickup()
    end
end

function love.update(dt)
    -- Probably only required for dev :)
    require("lurker").update()

    if love.keyboard.isDown("escape") then
        love.event.quit(0)
    end
    player_keypress(dt)
    entity_helper.update(entities, dt)
    entity_helper.update(npcs, dt)
end

function love.draw()
    -- love.graphics.scale(2, 2)

    local c = (color.white:to01())
    love.graphics.setColor(c.r, c.g, c.b, c.a)
    love.graphics.translate(-player:px() + WINDOW_W / 2, -player:py() + WINDOW_H / 2)

    entity_helper.draw(entities)
    entity_helper.draw(npcs)
    player:draw()

    -- this should be last
    love.ui()
end

function love.ui()
    local c = (color.white:to01())
    love.graphics.setColor(c.r, c.g, c.b, c.a)
    love.graphics.origin()
    local tile = player:tile_underneath()
    if tile ~= nil then
        love.graphics.print("on top: " .. tile:readable_name(), 10, 10)
    end
    tile = player.holding
    if tile ~= nil then
        love.graphics.print("holding " .. tile:readable_name(), 10, 20)
    end
end
