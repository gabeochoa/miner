require "util"

IterationResp = {
    Continue = 0,
    Break = 1
}

entity_helper = {}

npcs = {}
npcs.__entity_list = {}

entities = {}
entities.__entity_list = {}
function entities.load_world()
    -- todo world generation
    for i = 1, 100, 1 do
        local x = util.rand_on_grid(0, WORLD_MAX)
        local y = util.rand_on_grid(0, WORLD_MAX)
        entity_helper.add(entities, Metal(x, y))
    end
    for i = 1, 10, 1 do
        local x = util.rand_on_grid(0, WORLD_MAX)
        local y = util.rand_on_grid(0, WORLD_MAX)
        entity_helper.add(entities, Tractor(x, y))
    end
    for i = 1, 10, 1 do
        local x = util.rand_on_grid(0, WORLD_MAX)
        local y = util.rand_on_grid(0, WORLD_MAX)
        entity_helper.add(npcs, NPC(x, y))
    end

    for i = 60 * TILE_SIZE, 90 * TILE_SIZE, 3 * TILE_SIZE do
        for j = 50 * TILE_SIZE, 70 * TILE_SIZE, 2 * TILE_SIZE do
            entity_helper.add(entities, Wall(
                util.snap_to_grid(i),
                util.snap_to_grid(j)
            ))
        end
    end
end

function entity_helper.add(group, entity)
    table.insert(group.__entity_list, entity)
end

-- Runs a function for each entity,
-- function should return a Iteration response
function entity_helper.forEach(group, cb)
    for _, entity in ipairs(group.__entity_list) do
        local resp = cb(entity)
        if resp == IterationResp.Break then
            break
        end
        -- else continue
    end
end

function entity_helper.update(group, dt)
    entity_helper.forEach(
        group,
        function(entity)
            entity:update(dt)
        end
    )
end

function entity_helper.draw(group)
    local drawcmp = function(t, a, b)
        return t[a]:draw_index() > t[b]:draw_index()
    end
    for _, entity in util.spairs(group.__entity_list, drawcmp) do
        entity:draw()
    end
end

function entity_helper.remove(group, e)
    local index = -1
    for i, entity in ipairs(group.__entity_list) do
        if entity:x() == e:x() and entity:y() == e:y() then
            index = i
            break
        end
    end
    if index >= 0 then
        table.remove(group.__entity_list, index)
    end
end

-- returns the matching entity if one at location v
-- else nil
--- @return Base | nil
function entity_helper.matching(group, v, filter)
    for _, entity in ipairs(group.__entity_list) do
        local e = entity_helper._single_match(v, entity, filter)
        if e ~= nil then
            return e
        end
    end
    return nil
end

-- lua has no "continue" keyword, so this is kinda
-- the best way to do the filter, without not-ing the ifs
--- @return Base | nil
function entity_helper._single_match(v, entity, filter)
    if filter and filter.hide_held and entity.is_held then
        return nil
    end
    if filter and filter.impassible and entity:can_walk_on() then
        return nil
    end
    if entity:x() == v.x and entity:y() == v.y then
        return entity
    end
    return nil
end
