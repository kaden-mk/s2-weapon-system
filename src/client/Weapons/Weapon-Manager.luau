local ReplicatedStorage = game:GetService("ReplicatedStorage")

local World = require(ReplicatedStorage.Shared.World)
local WeaponClass = require(script.Parent["Weapon-Class"])

local ViewmodelType = require(script.Parent.Parent.Viewmodel["Viewmodel-Controller"])

local WeaponManager = { name = "WeaponController" }
WeaponManager.__index = WeaponManager

function WeaponManager.onInit(self: WeaponManager)
end

function WeaponManager.onStart(self: WeaponManager)
    local viewmodelController = World.import("ViewmodelController") :: ViewmodelType.ViewmodelController

    self.Weapon = WeaponClass.new("M4A1", viewmodelController) :: WeaponClass.Weapon
    self.Weapon:rig()
    self.Weapon.model.Parent = viewmodelController.model
end

export type WeaponManager = typeof(WeaponManager) & {
    Weapon: WeaponClass.Weapon
}

World.controller(WeaponManager)
return WeaponManager