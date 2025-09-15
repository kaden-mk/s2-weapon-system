local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Charm = require(ReplicatedStorage.Packages.Charm)
local atoms = require(ReplicatedStorage.Shared.Config.atoms)

local PlayerClass = {}
PlayerClass.__index = PlayerClass

local function constructNewPlayerState()
    return {
        weapons = Charm.atom({
            primary = Charm.atom("M4A1"),
            secondary = Charm.atom("M4A2")
        })
    } :: typeof(atoms.player_data)
end

function PlayerClass.new(player: Player): PlayerClass
    local self = setmetatable({}, PlayerClass) :: any
    self.player = player
    self.equipped_weapon = nil
    self.replicated_player_state = constructNewPlayerState()

    return self
end

function PlayerClass.destroy(self: PlayerClass)
    -- t odo
end

export type PlayerClass = typeof(PlayerClass) & {
    player: Player,
    equipped_weapon: string,
    replicated_player_state: typeof(atoms.player_data)
}

return PlayerClass :: PlayerClass