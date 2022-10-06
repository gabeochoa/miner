---@diagnostic disable: undefined-field
require "util"
require "deepcopy"

Person = Base:extend()
function Person:new(x, y)
    Person.super.new(self, x or WORLD_MAX / 2, y or WORLD_MAX / 2)
    self.p = vec(self.raw.x, self.raw.y)
    self.hand_size = 1
end

function Person:px() return self.p.x end

function Person:py() return self.p.y end

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

Player = Person:extend()
function Player:new(x, y)
    Player.super.new(self, x or WORLD_MAX / 2, y or WORLD_MAX / 2)
    self.speed = 2;
end

function Player:can_go(dx, dy)
    for i = 1, self.speed, 1 do
        local step = vec(
            util.snap_to_grid(self.raw.x + (dx * i)),
            util.snap_to_grid(self.raw.y + (dy * i))
        )
        local possible_wall = entity_helper.matching(entities, step, { impassible = true })
        if possible_wall then
            return false
        end
    end
    return true
end

function Player:move(dx, dy)
    if not self:can_go(dx, dy) then
        return
    end

    self.raw =
    vec(
        self.raw.x + (dx * self.speed),
        self.raw.y + (dy * self.speed)
    --
    )
    self.p =
    vec(
        util.snap_to_grid(self.raw.x),
        util.snap_to_grid(self.raw.y)
    --
    )
    -- print(self.raw.x .. " ", self.p)
end

-- todo show a toast - "picked up metal"
-- todo doesnt check grid bounds

-- Logic
--     are we holding?
--         -> standing on empty spot?
--             -> drop it
--         -> standing on matching type?
--             -> cell has space?
--                 -> store as much as possible
--     -> anything where we are standing?
--         -> pick up hand size
function Player:pickup()
    local standing_cell = self:tile_underneath()

    if self.holding ~= nil then
        -- empty spot, no worry to merge
        if standing_cell == nil then
            local entity = table.deepcopy(self.holding)
            entity:setPos(self.p)
            entity:toggle_held()
            entity_helper.add(entities, entity)
            self.holding = nil
            return
        end
        -- matching
        if standing_cell:type() == self.holding:type() then
            local amt = self.holding.stack_size
            while standing_cell:can_stack_more(1) and amt >= 0 do
                standing_cell:inc_stack(1)
                amt = amt - 1
            end
            if amt == 0 then
                self.holding = nil
            end
            return
        end

        if standing_cell:is(Tractor) and standing_cell:can_take(self.holding) then
            -- todo handle when holding more than 1
            local entity = table.deepcopy(self.holding)
            entity:setPos(self.p)
            entity:toggle_held()
            entity_helper.add(entities, entity)

            standing_cell:place_on_track(entity)
            self.holding = nil;
        end
        -- todo show toast, cant drop, not empty and no match
        return
    end

    -- cant pick up if nothing there
    if standing_cell == nil then
        return
    end

    -- pick up cell
    self.holding = table.deepcopy(standing_cell)
    self.holding.stack_size = 0
    self.holding:toggle_held()

    local amount = math.min(standing_cell.stack_size, self.hand_size)
    self.holding:inc_stack(amount)
    standing_cell:inc_stack(-amount)
    if standing_cell.stack_size == 0 then
        entity_helper.remove(entities, standing_cell)
    end
end
