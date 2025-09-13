local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")

local Input = require(StarterPlayer.StarterPlayerScripts.Client.Modules.Input)
local World = require(ReplicatedStorage.Shared.World)
local WeaponClass = require(script.Parent["Weapon-Class"])

local ViewmodelType = require(script.Parent.Parent.Viewmodel["Viewmodel-Controller"])

local WeaponManager = { name = "WeaponController" }
WeaponManager.__index = WeaponManager


function WeaponManager.constructor(self: WeaponManager)
    Input.create("Weapon")

    self.viewmodelController = World.import("ViewmodelController") :: ViewmodelType.ViewmodelController
    self.weapon = WeaponClass.new("M4A1", self.viewmodelController) :: WeaponClass.Weapon
end

function WeaponManager.onStart(self: WeaponManager)
    self.weapon.model.Parent = self.viewmodelController.model
    self.weapon.animations.Idle:Play()

    Input.bind("Weapon", "Reload", Enum.KeyCode.R, function()
        self.weapon.animations.TacticalReload:Play()
    end, false)
end

export type WeaponManager = typeof(WeaponManager) & {
    weapon: WeaponClass.Weapon,
    viewmodelController: ViewmodelType.ViewmodelController
}

World.controller(WeaponManager)
return WeaponManager