# Evade Development

This repository contains a safe, standalone sky-farm **layout planner** for developers building their own Roblox experiences. It does not interact with a live game, move a player, collect tickets, automate input, inspect another game's objects, or load remote code.

## Reference-source review

The linked `evadeopenscr.lua` is a client-side game automation/exploit script, not an ordinary game extension. The visible source includes remote `loadstring`/`HttpGet` loading, client-side ESP, player-character repositioning, ticket collection automation, anti-bot movement, and revive automation. Those behaviors can undermine a multiplayer game's rules and depend on executor-only capabilities. This project does not copy or extend those mechanisms.

For a legitimate project you own, keep gameplay placement and rewards server-authoritative. Use the planner below only to derive a proposed platform layout; your own server code must decide whether, where, and when anything is created.

## Sky-farm layout planner

`src/sky_farm_planner.lua` is a pure Lua module. It selects a platform elevation high enough to meet a requested clearance above the map, enforces a maximum altitude, and validates the platform footprint. It has no Roblox or executor dependencies.

```lua
local planner = require("src.sky_farm_planner")

local layout, err = planner.plan({
    map_top_y = 120,
    preferred_altitude = 280,
    minimum_clearance = 40,
    maximum_altitude = 500,
    platform_width = 48,
    platform_depth = 48,
})

if not layout then
    error(err)
end

print(layout.platform_y) -- 280
```

If a preferred elevation is too low, the planner raises it to `map_top_y + minimum_clearance`; it returns an error rather than exceeding the configured altitude cap. For a larger layout, `plan_tall` defaults to 600 studs above the map top and an 80-by-80 footprint, while still requiring an explicit maximum altitude:

```lua
local tall_layout, err = planner.plan_tall({
    map_top_y = 120,
    maximum_altitude = 900,
})
```

Run the plain-Lua checks with:

```sh
lua tests/sky_farm_planner_spec.lua
```
