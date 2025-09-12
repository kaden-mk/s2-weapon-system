local ReplicatedStorage = game:GetService("ReplicatedStorage")

local World = require(ReplicatedStorage.Shared.World)

local WeaponManager = {}
WeaponManager.__index = WeaponManager

function WeaponManager.onInit(self: WeaponManager)
end

export type WeaponManager = typeof(WeaponManager) & {
}

World.controller(WeaponManager)
return WeaponManager