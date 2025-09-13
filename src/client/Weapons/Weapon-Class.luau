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
    self.animations = {}

    Object.setPhysics(self.model, false, false)

    self:initializeRig()
    self:initializeAnimations()

    return self
end

function Weapons.initializeRig(self: Weapon)
    for _, rigData in self.data.Rig do
        local prefix0, name0 = string.match(rigData.Part0, "([^/]+)/(.+)")
        local prefix1, name1 = string.match(rigData.Part1, "([^/]+)/(.+)")
        
        local part0 = (prefix0 == "Weapon" and self.model or self.viewmodelController.model):FindFirstChild(name0, true)
        local part1 = (prefix1 == "Weapon" and self.model or self.viewmodelController.model):FindFirstChild(name1, true)

        Object.rig(part0, part1, rigData.C0, rigData.C1)
    end
end

function Weapons.initializeAnimations(self: Weapon)
    local priorities = {
        TacticalReload = Enum.AnimationPriority.Action,
        Idle = Enum.AnimationPriority.Idle
    }

    for _, animation in self.model.Animations:GetChildren() do
        if not animation:IsA("Animation") then continue end

        self.animations[animation.Name] = self.viewmodelController.animator:LoadAnimation(animation)

        if priorities[animation.Name] then
            self.animations[animation.Name].Priority = priorities[animation.Name]
        end
    end
end

export type Weapon = typeof(Weapons) & {
    name: string,
    model: Model & { Animations: Folder },
    data: { Rig: { any } },
    viewmodelController: ViewmodelController.ViewmodelController,
    animations: { [string]: AnimationTrack }
}

return Weapons :: Weapon
