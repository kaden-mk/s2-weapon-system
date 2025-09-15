local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")

local Input = require(StarterPlayer.StarterPlayerScripts.Client.Modules.Input)
local World = require(ReplicatedStorage.Shared.World)
local WeaponClass = require(script.Parent["Weapon-Class"])

local ViewmodelType = require(script.Parent.Parent.Viewmodel["Viewmodel-Controller"])
local PlayerType = require(script.Parent.Parent.Player["Player-Controller"])

local WeaponManager = { name = "WeaponController" }
WeaponManager.__index = WeaponManager

function WeaponManager.constructor(self: WeaponManager)
    Input.create("Weapon")

    self.viewmodel_controller = World.import("ViewmodelController") :: ViewmodelType.ViewmodelController
    self.player_controller = World.import("PlayerController")

    self.weapon = WeaponClass.new(self.player_controller.replicated_player_state.weapons().primary(), self.viewmodel_controller) :: WeaponClass.Weapon
    self.is_firing = false
end

function WeaponManager.onStart(self: WeaponManager)
    self.weapon:equip()

    Input.bind("Weapon", "Reload", Enum.KeyCode.R, function()
        self.weapon:reload()
    end, false)

    Input.bind("Weapon", "Fire", Enum.UserInputType.MouseButton1, function(_, ended) -- TODO: add support for semi autos
        self.is_firing = not ended
        if ended == false then
            self.weapon:fire()
        end
    end, true)
end

function WeaponManager.onRender(self: WeaponManager)
    if self.is_firing == true and self.weapon.state.can_fire then
        self.weapon:fire()
    end
end

export type WeaponManager = typeof(WeaponManager) & {
    weapon: WeaponClass.Weapon,
    viewmodel_controller: ViewmodelType.ViewmodelController,
    player_controller: PlayerType.PlayerController,

    is_firing: boolean
}

World.controller(WeaponManager)
return WeaponManager