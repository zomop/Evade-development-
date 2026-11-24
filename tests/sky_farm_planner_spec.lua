package.path = "./?.lua;" .. package.path

local planner = require("src.sky_farm_planner")

local function assert_equal(actual, expected, message)
    assert(actual == expected, (message or "values differ") .. ": expected "
        .. tostring(expected) .. ", got " .. tostring(actual))
end

local layout, err = planner.plan({
    map_top_y = 120,
    preferred_altitude = 280,
    minimum_clearance = 40,
    maximum_altitude = 500,
    platform_width = 48,
    platform_depth = 48,
})
assert(layout, err)
assert_equal(layout.platform_y, 280, "preferred elevation")
assert_equal(layout.clearance, 160, "calculated clearance")

layout, err = planner.plan({
    map_top_y = 120,
    preferred_altitude = 100,
    minimum_clearance = 40,
    maximum_altitude = 500,
    platform_width = 48,
    platform_depth = 32,
})
assert(layout, err)
assert_equal(layout.platform_y, 160, "clearance floor")
assert_equal(layout.width, 48, "platform width")
assert_equal(layout.depth, 32, "platform depth")

local rejected
rejected, err = planner.plan({
    map_top_y = 120,
    preferred_altitude = 490,
    minimum_clearance = 40,
    maximum_altitude = 150,
    platform_width = 48,
    platform_depth = 48,
})
assert(rejected == nil, "over-cap elevation should be rejected")
assert(type(err) == "string", "rejection should explain why")

rejected, err = planner.plan({
    map_top_y = 120,
    preferred_altitude = 200,
    minimum_clearance = 20,
    maximum_altitude = 300,
    platform_width = 0,
    platform_depth = 48,
})
assert(rejected == nil, "zero-width platform should be rejected")

layout, err = planner.plan_tall({
    map_top_y = 120,
    height_above_map = 600,
    maximum_altitude = 900,
})
assert(layout, err)
assert_equal(layout.platform_y, 720, "tall-profile elevation")
assert_equal(layout.clearance, 600, "tall-profile clearance")
assert_equal(layout.width, 80, "tall-profile default width")
assert_equal(layout.depth, 80, "tall-profile default depth")

rejected, err = planner.plan_tall({
    map_top_y = 120,
    height_above_map = 600,
    maximum_altitude = 700,
})
assert(rejected == nil, "tall profile must respect altitude cap")

print("sky_farm_planner_spec: all checks passed")
