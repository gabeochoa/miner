Batteries = require "batteries"

astar = {}
astar.path_cache = {}

function astar.clear_cache()
    astar.path_cache = {}
end

---@param path table
---@param map table
---@param cur string
---@return table
function astar.reconstruct_path(path, map, cur)
    local parent = map[cur]
    print("reconstruct_path, ", cur, parent)
    -- has no parent, then we done
    if parent == nil then
        return path
    else
        -- has a parent, add node to path,
        -- and continue through its parent
        table.insert(path, 1, parent)
        return astar.reconstruct_path(path, map, parent)
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
    -- print("get_lowest_f")
    -- for k, v in pairs(scores) do
    --     print(k, v)
    -- end
    -- print("--- lowerst f")
    local lowest = -1
    local best = nil
    for _, v in pairs(set:values()) do
        -- print("scores v", v)
        local score = astar.get_score(scores, v)
        if lowest == -1 or score < lowest then
            lowest = score
            best = v
        end
    end
    -- print("best best", best, lowest)
    return best
end

---@param node vec
---@param is_walkable fun(node: vec): boolean
---@return vec[]
function astar.get_neighbors(node, is_walkable)
    local ns = {}
    local per_neighbor = function(i, j)
        if i == 0 and j == 0 then
            return
        end
        local n = vec.snap_to_grid(node.x + (i * TILE_SIZE), node.y + (j * TILE_SIZE))
        local m = entity_helper.matching(entities, n, { impassible = true })
        if m == nil then
            table.insert(ns, n)
        end
    end
    for i = -1, 1, 1 do
        for j = -1, 1, 1 do
            per_neighbor(i, j)
        end
    end
    -- print("neigh", #ns)
    return ns
end

function astar.get_score(score_table, node)
        local key = node:__tostring()
        local score = score_table[key]
        if score == nil then
            return 999999
        end
        return score
    end

function astar.write_score(score_table, node, score)
        local key = node:__tostring()
        score_table[key] = score
    end


---@param start vec
---@param goal vec
---@param is_walkable fun(node: vec): boolean
---@return string[]
function astar.__gen_path(start, goal, is_walkable)
    print("gen path", start, goal)
    local openset = Batteries.set()
    openset:add(start)

    local parent_map = {}
    local gscore = {}
    local fscore = {}

    if not is_walkable then
        is_walkable = function() return true end
    end

    astar.write_score(gscore, start, 0)
    local current_score = astar.get_score(gscore, start)
    local estimate = astar.estimate(start, goal)
    astar.write_score(fscore, start, current_score + estimate)

    while #openset:values() > 0 do
        -- print("iterate", #openset:values())
        if #openset:values() > 10000 then
            print("Hit loop exceed limit ")
            break
        end

        local cur = astar.get_lowest_f(openset, fscore)
        print("current: ", cur, " goal: ", goal, " ")
        -- TODO fix eq if cur == goal then
        if cur:__eq(goal) then
            print("found goal making path")
            local path = astar.reconstruct_path({}, parent_map, goal:__tostring())
            table.insert(path, goal:__tostring())
            return path
        end

        openset:remove(cur)
        local neighbors = astar.get_neighbors(cur, is_walkable)
        for _, neighbor in ipairs(neighbors) do
            local new_gscore = astar.get_score(gscore, cur) + astar.dist_between(cur, neighbor)
            local cur_gscore = astar.get_score(gscore, neighbor)
            if cur_gscore == nil or new_gscore < cur_gscore then
                parent_map[neighbor:__tostring()] = cur:__tostring()
                -- print("writing parent", neighbor:__tostring(), cur)
                astar.write_score(gscore, neighbor, new_gscore)
                astar.write_score(fscore, neighbor, new_gscore + astar.estimate(neighbor, goal))
                if not openset:has(neighbor) then
                    openset:add(neighbor)
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
---@return string[]
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
