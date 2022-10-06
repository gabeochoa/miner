Batteries = require "batteries"

astar = {}
astar.path_cache = {}

function astar.clear_cache()
    astar.path_cache = {}
end

---@param path table
---@param map table
---@param cur vec
---@return table
function astar.reconstruct_path(path, map, cur)
    -- has no parent, then we done
    if map[cur] == nil then
        return path
    else
        -- has a parent, add node to path,
        -- and continue through its parent
        table.insert(path, 1, map[cur])
        return astar.reconstruct_path(path, map, map[cur])
    end
end

---@param start vec
---@param goal vec
---@return number
function astar.estimate(start, goal)
    return util.dist(start, goal)
end

function astar.dist_between(a, b)
    return util.dist(a, b)
end

---@param set Set
---@param scores table
---@return vec
function astar.get_lowest_f(set, scores)
    print("get_lowest_f")
    for k, v in pairs(scores) do
        print(k, v)
    end
    print("--- lowerst f")
    local lowest = -1
    local best = nil
    for _, v in pairs(set:values()) do
        print("scores v", v)
        local score = scores[v]
        if lowest == -1 or score < lowest then
            lowest = score
            best = v
        end
    end
    print("best best", best)
    return best
end

---@param node vec
---@param is_walkable fun(node: vec): boolean
---@return vec[]
function astar.get_neighbors(node, is_walkable)
    local ns = {}
    for i = -1, 1, 1 do
        for j = -1, 1, 1 do
            local n = vec.snap_to_grid(node.x + (i * TILE_SIZE), node.y + (j * TILE_SIZE))
            local m = entity_helper.matching(entities, n, { walkable = true })
            if m ~= nil then
                table.insert(ns, m)
            end
        end
    end
    print("neigh", #ns)
    return ns
end

---@param start vec
---@param goal vec
---@param is_walkable fun(node: vec): boolean
---@return vec[]
function astar.__gen_path(start, goal, is_walkable)
    print("gen path", start, goal)
    local openset = Batteries.set()
    openset:add(start)
    local closedset = Batteries.set()

    local parent_map = {}
    local gscore = {}
    local fscore = {}

    if not is_walkable then
        is_walkable = function() return true end
    end

    gscore[start] = 0
    local current_score = gscore[start]
    local estimate = astar.estimate(start, goal)
    fscore[start] = current_score + estimate

    while #openset:values() > 0 do
        print("iterate", #openset:values())
        local cur = astar.get_lowest_f(openset, fscore)
        if cur == goal then
            print("found goal making path")
            local path = astar.reconstruct_path({}, parent_map, goal)
            table.insert(path, goal)
            return path
        end

        openset:remove(cur)
        closedset:add(cur)

        print("sizeout", #openset:values(),#closedset:values())

        local neighbors = astar.get_neighbors(cur, is_walkable)
        for index, neighbor in ipairs(neighbors) do
            print("sizein", #openset:values(),#closedset:values())
            if not closedset:has(neighbor) then
                local tentative_g_score = gscore[cur] + astar.dist_between(cur, neighbor)
                if not openset:has(neighbor) or tentative_g_score < gscore[neighbor] then
                    parent_map[neighbor] = cur
                    gscore[neighbor] = tentative_g_score
                    fscore[neighbor] = gscore[neighbor] + astar.estimate(neighbor, goal)
                    if not openset:has(neighbor) then
                        openset:add(neighbor)
                    end
                end
            end

        end
    end
    print("ran out of options")
    return {}
end

---@param start vec
---@param goal vec
---@param is_walkable fun(node: vec): boolean
---@return vec[]
function astar.find_path(start, goal, is_walkable)
    -- if astar.path_cache[start] == nil then
    --     astar.path_cache[start] = {}
    -- elseif astar.path_cache[start][goal] ~= nil then
    --     return astar.path_cache[start][goal]
    -- end
    local path = astar.__gen_path(start, goal, is_walkable)
    -- if astar.path_cache[start][goal] == nil then
    --     astar.path_cache[start][goal] = path
    -- end
    print("findpath", path)
    return path
end
