local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CharmSync = require(ReplicatedStorage.Packages.CharmSync)
local atoms = require(ReplicatedStorage.Shared.Config.atoms)
local World = require(ReplicatedStorage.Shared.World)
local Network = require(ReplicatedStorage.Shared.network.client)

local PlayerController = { name = "PlayerController" }
PlayerController.__index = PlayerController

function PlayerController.constructor(self: PlayerController)
    self.replicated_player_state = table.clone(atoms.player_data)
end

function PlayerController.onStart(self: PlayerController)
    local syncer = CharmSync.client({
        atoms = self.replicated_player_state
    })

    Network.PlayerSessionSync.On(function(payload)
        syncer:sync(payload)
    end)

    Network.RequestSessionState.Fire()
end

export type PlayerController = typeof(PlayerController) & {
    replicated_player_state: typeof(atoms.player_data)
}

World.controller(PlayerController)
return PlayerController :: PlayerController