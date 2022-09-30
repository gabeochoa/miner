Object = require "classic"
require "color"
require "vec"

TILE_SIZE = 10
WINDOW_W = 800
WINDOW_H = 600
WORLD_MAX = 800

require "util"
require "player"

-- types
Material = Base:extend()
function Material:new(x, y)
    Material.super.new(self, x, y)
end

Metal = Material:extend()
function Metal:readable_name()
    return "Metal"
end
function Metal:new(x, y)
    Metal.super.new(self, x, y)
end
function Metal:color()
    return color.metallic_blue
end

-- entities

IterationResp = {
    Continue = 0,
    Break = 1
}

entities = {}

function entities.add(entity)
    table.insert(entities, entity)
end

-- Runs a function for each entity,
-- function should return a Iteration response
function entities.forEach(cb)
    for _, entity in ipairs(entities) do
        local resp = cb(entity)
        if resp == IterationResp.Break then
            break
        end
        -- else continue
    end
end

function entities.load_world()
    local rand_on_grid = function(mn, mx)
        return util.snap_to_grid(love.math.random(mn, mx))
    end
    -- todo world generation
    for i = 1, 10, 1 do
        local x = rand_on_grid(0, WORLD_MAX)
        local y = rand_on_grid(0, WORLD_MAX)
        entities.add(Metal(x, y))
    end
end

function entities.update(dt)
    entities.forEach(
        function(entity)
            entity:update(dt)
        end
    )
end

function entities.draw()
    entities.forEach(
        function(entity)
            entity:draw()
        end
    )
end

-- returns the matching entity if one at location v
-- else nil
function entities.matching(v)
    for _, entity in ipairs(entities) do
        if entity:x() == v.x and entity:y() == v.y then
            return entity
        end
    end
    return nil
end

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
    player:move(dx, dy)
end

function love.update(dt)
    -- Probably only required for dev :)
    require("lurker").update()

    if love.keyboard.isDown("escape") then
        love.event.quit(0)
    end
    player_keypress(dt)
    entities.update(dt)
end

function love.draw()
    -- love.graphics.scale(2, 2)

    local c = (color.white:to01())
    love.graphics.setColor(c.r, c.g, c.b, c.a)
    love.graphics.translate(-player:px() + WINDOW_W / 2, -player:py() + WINDOW_H / 2)
    love.graphics.rectangle("fill", 100, 200, 50, 80)

    entities.draw()
    player:draw()

    -- this should be last
    love.ui()
end

function love.ui()
    love.graphics.origin()
    love.graphics.print(player:tile_underneath(), 10, 10)
end
