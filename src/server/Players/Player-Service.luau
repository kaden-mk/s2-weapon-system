local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Charm = require(ReplicatedStorage.Packages.Charm)
local CharmSync = require(ReplicatedStorage.Packages.CharmSync)
local atoms = require(ReplicatedStorage.Shared.Config.atoms)
local PlayerClass = require(script.Parent["Player-Class"])
local World = require(ReplicatedStorage.Shared.World)
local Network = require(ReplicatedStorage.Shared.network.server)

local PlayerService = { name = "PlayerService" }
PlayerService.__index = PlayerService

function PlayerService.constructor(self: PlayerService)
    self.players = {}
    self.player_syncers = {}
end

function PlayerService.setupSyncerForState(self: PlayerService, player: Player, state: typeof(atoms.player_data))
    local syncer = CharmSync.server({
        atoms = state
    })

    self.player_syncers[player] = syncer

    syncer:connect(function(_, payload)
        Network.PlayerSessionSync.Fire(player, payload)
    end)
end

function PlayerService.onStart(self: PlayerService)
    Network.RequestSessionState.On(function(player)
        self.player_syncers[player]:hydrate(player)
    end)

    Players.PlayerAdded:Connect(function(player)
        local class = PlayerClass.new(player)
        self.players[player] = class
        self:setupSyncerForState(player, class.replicated_player_state)
    end)

    Players.PlayerRemoving:Connect(function(player)
        self.players[player]:destroy()
        self.players[player] = nil
    end)
end

function PlayerService.getPlayer(self: PlayerService, player: Player): PlayerClass.PlayerClass
    return self.players[player]
end

export type PlayerService = typeof(PlayerService) & {
    players: { [Player]: PlayerClass.PlayerClass },
    player_syncers: { [Player]: any }
}

World.service(PlayerService)
return PlayerService