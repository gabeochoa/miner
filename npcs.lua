require "util"
require "person"
require "astar"

NPC = Person:extend()

function NPC:new(x, y)
    NPC.super.new(self, x or WORLD_MAX / 2, y or WORLD_MAX / 2)
    self.target = nil
    self.path = nil
    self.local_target = nil

    self.reset_timer = 1
    self.reset_location = nil
end

function NPC:speed() return 5 * TILE_SIZE end

function NPC:type() return "NPC" end

function NPC:color()
    return color.turquoise
end

function NPC:update(dt)
    self:ai(dt)
end

function NPC:ensure_active_target()
    -- make sure that we always have a valid target
    local ensure_global_target = function()
        while self.target == nil do
            self.target = (player:snap_pos())
            -- local target = vec.rand_on_grid(0, WORLD_MAX)
            -- local target_cell = entity_helper.matching(entities, target, { impassible = true })
            -- if target_cell == nil then
            --     self.target = target
            -- end
        end
    end

    -- make sure that given a valid target,
    -- we have a path to follow
    local ensure_has_path = function()
        if not self.target then return end
        if self.path then
            if #self.path == 0 then
                self.path = nil
            end
            return
        end

        local can_pass = function(node)
            local match = entity_helper.matching(entities, node, { impassible = true })
            if match then return false end
            return true
        end
        print("fetching new path")
        local string_path = astar.find_path(self:snap_pos(), self.target, can_pass)
        local path = {}
        for _, value in ipairs(string_path) do
            -- vec(0, 0)
            local rhs = util.split(value, "(")[2] -- [ "vec(", "0,0)"]
            local x = util.split(rhs, ",")[1]
            local y_with_paren = util.split(rhs, ",")[2]
            local y = util.split(y_with_paren, ")")[1]
            local postition = vec(x, y)
            table.insert(path, postition)
        end
        self.path = path
        print("got path")
        if self.path then
            print('results path')
            for index, value in ipairs(self.path) do
                print(index, value)
            end
            print('end path---')
        else
            self.target = nil
        end
    end


    ensure_global_target()
    ensure_has_path()

    if self.path and #self.path and self.local_target == nil then
        self.local_target = table.remove(self.path, 1)
    end


end

function NPC:ensure_not_stuck(dt)
    if not self.reset_location then
        self.reset_location = self:snap_pos()
        return
    end

    if self.reset_location == self:snap_pos() then
        self.reset_timer = self.reset_timer - dt
    end
    if self.reset_timer <= 0 then
        self.path = nil
        self.local_target = nil
        self.reset_timer = 1
    end

    self.reset_location = self:snap_pos()
end

function NPC:ai(dt)
    -- self:ensure_not_stuck(dt)

    self:ensure_active_target()

    if not self.local_target then
        return
    end

    print("snap, local", 
        self:snap_pos(), 
        self.local_target
    )


    local diff = vec(
        self.local_target.x - self:px(),
        self.local_target.y - self:py()
    )
    local dx = 0
    local dy = 0
    if math.abs(diff.x) >= 1 then dx = util.sign(diff.x) end
    if math.abs(diff.y) >= 1 then dy = util.sign(diff.y) end
    print('Diffs', diff.x, diff.y, dx, dy)

    if dx == 0 and dy == 0 then
        print("got to local target")
        self.local_target = nil
    end

    self:move(dx, 0, dt)
    self:move(0, dy, dt)

    -- love.event.quit(0)
end

function NPC:draw()
    local c = (self:color():to01())
    love.graphics.setColor(c.r, c.g, c.b, c.a)
    love.graphics.rectangle("fill", self:x(), self:y(), TILE_SIZE, TILE_SIZE)
end
