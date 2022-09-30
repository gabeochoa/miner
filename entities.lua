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