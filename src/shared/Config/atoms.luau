local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Charm = require(ReplicatedStorage.Packages.Charm)

return {
    player_data = {
        weapons = Charm.atom({
            primary = Charm.atom("M4A1"),
            secondary = Charm.atom("M4A2")
        })
    }
}