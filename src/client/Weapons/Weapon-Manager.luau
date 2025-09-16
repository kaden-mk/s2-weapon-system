local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")

local Input = require(StarterPlayer.StarterPlayerScripts.Client.Modules.Input)
local World = require(ReplicatedStorage.Shared.World)
local WeaponClass = require(script.Parent["Weapon-Class"])
local Network = require(ReplicatedStorage.Shared.network.client)

local ViewmodelType = require(script.Parent.Parent.Viewmodel["Viewmodel-Controller"])
local PlayerType = require(script.Parent.Parent.Player["Player-Controller"])

local WeaponManager = { name = "WeaponController" }
WeaponManager.__index = WeaponManager

function WeaponManager.constructor(self: WeaponManager)
    Input.create("Weapon")

    self.viewmodel_controller = World.import("ViewmodelController") :: ViewmodelType.ViewmodelController
    self.player_controller = World.import("PlayerController")

    local primary = self.player_controller.replicated_player_state.weapons().primary()

    self.weapons = {
        [primary] = WeaponClass.new(primary, self.viewmodel_controller) :: WeaponClass.Weapon
    }
    self.equipped_weapon = self.weapons[primary]
    self.is_firing = false

    Network.WeaponSessionSync.On(function(data)
        self.weapons[data.name].syncer:sync(data.payload)
    end)
end

function WeaponManager.onStart(self: WeaponManager)
    self.equipped_weapon:equip()

    Input.bind("Weapon", "Reload", Enum.KeyCode.R, function()
        if self.is_firing then return end

        self.equipped_weapon:reload()
    end, false)

    Input.bind("Weapon", "Fire", Enum.UserInputType.MouseButton1, function(_, ended) -- TODO: add support for semi autos
        self.is_firing = not ended
        if ended == false then
            self.equipped_weapon:fire()
        end
    end, true)

    Input.bind("Weapon", "Inspect", Enum.KeyCode.F, function()
        self.equipped_weapon:inspect()
    end, false)
end

function WeaponManager.onRender(self: WeaponManager)
    if self.is_firing == true and self.equipped_weapon.state.can_fire() then
        self.equipped_weapon:fire()
    end
end

export type WeaponManager = typeof(WeaponManager) & {
    weapons: { [string]: WeaponClass.Weapon },
    equipped_weapon: WeaponClass.Weapon,
    viewmodel_controller: ViewmodelType.ViewmodelController,
    player_controller: PlayerType.PlayerController,

    is_firing: boolean
}

World.controller(WeaponManager)
return WeaponManager