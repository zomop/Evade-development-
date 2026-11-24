-- Offline layout planning for a sky-farm area in an experience you own.
-- This module deliberately has no Roblox, networking, input, or player APIs.

local Planner = {}

local function finite_number(value)
    return type(value) == "number"
        and value == value -- reject NaN
        and value ~= math.huge
        and value ~= -math.huge
end

local function required_number(options, key)
    local value = options[key]
    if not finite_number(value) then
        return nil, "'" .. key .. "' must be a finite number"
    end
    return value
end

function Planner.plan(options)
    if type(options) ~= "table" then
        return nil, "options must be a table"
    end

    local map_top_y, err = required_number(options, "map_top_y")
    if not map_top_y then return nil, err end

    local preferred_altitude
    preferred_altitude, err = required_number(options, "preferred_altitude")
    if not preferred_altitude then return nil, err end

    local minimum_clearance
    minimum_clearance, err = required_number(options, "minimum_clearance")
    if not minimum_clearance then return nil, err end

    local maximum_altitude
    maximum_altitude, err = required_number(options, "maximum_altitude")
    if not maximum_altitude then return nil, err end

    local width
    width, err = required_number(options, "platform_width")
    if not width then return nil, err end

    local depth
    depth, err = required_number(options, "platform_depth")
    if not depth then return nil, err end

    if minimum_clearance < 0 then
        return nil, "minimum_clearance cannot be negative"
    end
    if width <= 0 or depth <= 0 then
        return nil, "platform dimensions must be greater than zero"
    end
    if maximum_altitude <= map_top_y then
        return nil, "maximum_altitude must be above map_top_y"
    end

    local platform_y = math.max(preferred_altitude, map_top_y + minimum_clearance)
    if platform_y > maximum_altitude then
        return nil, "required platform altitude exceeds maximum_altitude"
    end

    return {
        platform_y = platform_y,
        clearance = platform_y - map_top_y,
        width = width,
        depth = depth,
    }
end

-- Convenience profile for an extra-tall, wider layout. The altitude cap remains
-- mandatory so a large requested height cannot silently exceed the map budget.
function Planner.plan_tall(options)
    if type(options) ~= "table" then
        return nil, "options must be a table"
    end

    local map_top_y, err = required_number(options, "map_top_y")
    if not map_top_y then return nil, err end

    local maximum_altitude
    maximum_altitude, err = required_number(options, "maximum_altitude")
    if not maximum_altitude then return nil, err end

    local height_above_map = options.height_above_map
    if height_above_map == nil then height_above_map = 600 end
    if not finite_number(height_above_map) or height_above_map <= 0 then
        return nil, "'height_above_map' must be a positive finite number"
    end

    local minimum_clearance = options.minimum_clearance
    if minimum_clearance == nil then minimum_clearance = 60 end

    local width = options.platform_width
    if width == nil then width = 80 end

    local depth = options.platform_depth
    if depth == nil then depth = 80 end

    return Planner.plan({
        map_top_y = map_top_y,
        preferred_altitude = map_top_y + height_above_map,
        minimum_clearance = minimum_clearance,
        maximum_altitude = maximum_altitude,
        platform_width = width,
        platform_depth = depth,
    })
end

return Planner
