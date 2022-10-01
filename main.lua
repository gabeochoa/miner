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
    self.max_stack = 10
end

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
    player:move(dx, dy)
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
    local c = (color.white:to01())
    love.graphics.setColor(c.r, c.g, c.b, c.a)
    love.graphics.origin()
    local tile = player:tile_underneath()
    if tile ~= nil then
        love.graphics.print(tile:readable_name(), 10, 10)
    end
    tile = player.holding
    if tile ~= nil then
        love.graphics.print("holding ".. tile:readable_name(), 10, 20)
    end
end
