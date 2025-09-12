local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")

local ViewmodelController = require(StarterPlayer.StarterPlayerScripts.Client.Viewmodel["Viewmodel-Controller"])
local Object = require(ReplicatedStorage.Shared.Modules.Object)

local WeaponConfigsList = {}
for _, config in ReplicatedStorage.Shared.Config.Weapons:GetChildren() do
    if not config:IsA("ModuleScript") then continue end

    WeaponConfigsList[config.Name] = require(config)
end

local Weapons = {}
Weapons.__index = Weapons

function Weapons.new(name: string, viewmodelController: ViewmodelController.ViewmodelController): Weapon | nil
    if not WeaponConfigsList[name] then return nil end

    local self = setmetatable({}, Weapons)
    self.name = name
    self.model = ReplicatedStorage.Assets.Weapons[name]:Clone()
    self.data = WeaponConfigsList[name]
    self.viewmodelController = viewmodelController

    Object.setPhysics(self.model, false, false)

    return self
end

function Weapons.rig(self: Weapon)
    for _, rig_data in self.data.Rig do
        local part0 = self.model:FindFirstChild(rig_data.Part0, true)
        local part1 = self.viewmodelController.model:FindFirstChild(rig_data.Part1)

        Object.rig(part0, part1, rig_data.C0, rig_data.C1)
    end
end

export type Weapon = typeof(Weapons) & {
    name: string,
    model: Model,
    data: { Rig: { any } },
    viewmodelController: ViewmodelController.ViewmodelController
}

return Weapons :: Weapon
