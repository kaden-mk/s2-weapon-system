local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Charm = require(ReplicatedStorage.Packages.Charm)

return {
    player_data = {
        weapons = Charm.atom({
            primary = Charm.atom("M4A1"),
            secondary = Charm.atom("M4A2")
        })
    },

    weapon_data = {
        equipped = Charm.atom(false),
        enabled = Charm.atom(true),
        can_fire = Charm.atom(true),
        reloading = Charm.atom(false),
        ammo_count = Charm.atom(0),
        ammo_held = Charm.atom(0)
    }
}