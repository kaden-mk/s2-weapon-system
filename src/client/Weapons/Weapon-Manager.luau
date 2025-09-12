local ReplicatedStorage = game:GetService("ReplicatedStorage")

local World = require(ReplicatedStorage.Shared.World)

local WeaponManager = {}
WeaponManager.__index = WeaponManager

local function constructor()
    local self = setmetatable({}, WeaponManager)
    return self
end

function WeaponManager.onInit(self: WeaponManager)
    self.hi = "hi"
    print(self.hi)
end

export type WeaponManager = typeof(WeaponManager) & {
    hi: string
}

World.controller(constructor())
return WeaponManager