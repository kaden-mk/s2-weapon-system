-- Handler for the weapon class, manages players and which weapons they have (maybe leave this to the player service?)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local StarterPlayer = game:GetService("StarterPlayer")

local CharmSync = require(ReplicatedStorage.Packages.CharmSync)
local atoms = require(ReplicatedStorage.Shared.Config.atoms)
local PlayerService = require(ServerScriptService.Server.Players["Player-Service"])
local WeaponClass = require(script.Parent["Weapon-Class"])
local World = require(ReplicatedStorage.Shared.World)
local Network = require(ReplicatedStorage.Shared.network.server)

local weapon_player_list = {}
local weapon_syncer_list = {}

local WeaponManager = { name = "WeaponService" }
WeaponManager.__index = WeaponManager

function WeaponManager.constructor(self: WeaponManager)
    self.player_service = World.import("PlayerService")
end

function WeaponManager.setupSyncerForState(self: WeaponManager, player: Player, state: typeof(atoms.weapon_data), name: string)
    local syncer = CharmSync.server({
        atoms = state
    })

    if not weapon_syncer_list[player] then
        weapon_syncer_list[player] = {}
    end

    weapon_syncer_list[player][name] = syncer

    syncer:connect(function(_, payload)
        Network.WeaponSessionSync.Fire(player, { name = name, payload = payload })
    end)
end

function WeaponManager.onStart(self: WeaponManager)
    Network.CreateWeapon.SetCallback(function(player, name)
        if not weapon_player_list[player] then
            weapon_player_list[player] = {}
        end

        if weapon_player_list[player][name] then return "fail" end

        local player_data = self.player_service:getPlayer(player)
        if not player_data then return "fail" end

        local weapons = player_data.replicated_player_state.weapons()
        
        -- should definitely improve this
        if weapons.primary() ~= name and weapons.secondary() ~= name then return "fail" end

        local weapon = WeaponClass.new(name, player_data)
        self:setupSyncerForState(player, weapon.state, name)
        weapon_syncer_list[player][name]:hydrate(player)

        if not weapon then return "fail" end

        weapon_player_list[player][name] = weapon

        return "success"
    end)

    Network.EquipWeapon.SetCallback(function(player, name)
        if not weapon_player_list[player] or not weapon_player_list[player][name] then return "fail" end

        local player_data = self.player_service:getPlayer(player)
        if not player_data then return "fail" end

        local weapon = weapon_player_list[player][name]
        local did_equip = weapon:equip()

        if not did_equip then return "fail" end

        return "success"
    end)

    Network.FireWeapon.On(function(player)
        local player_data = self.player_service:getPlayer(player)
        if not player_data then return end 

        local equipped_weapon = player_data.equipped_weapon
        local weapon = weapon_player_list[player][equipped_weapon]

        weapon:fire()
    end)

    Network.ReloadWeapon.On(function(player)
        local player_data = self.player_service:getPlayer(player)
        if not player_data then return end 

        local equipped_weapon = player_data.equipped_weapon
        local weapon = weapon_player_list[player][equipped_weapon]

        weapon:reload()
    end)
end

export type WeaponManager = typeof(WeaponManager) & {
    player_service: PlayerService.PlayerService
}

World.service(WeaponManager)
return WeaponManager