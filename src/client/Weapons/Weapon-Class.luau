local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")
local UserInputService = game:GetService("UserInputService")

local Charm = require(ReplicatedStorage.Packages.Charm)
local Interface = require(StarterPlayer.StarterPlayerScripts.Client.Modules.Interface)
local CharmSync = require(ReplicatedStorage.Packages.CharmSync)
local atoms = require(ReplicatedStorage.Shared.Config.atoms)
local ViewmodelController = require(StarterPlayer.StarterPlayerScripts.Client.Viewmodel["Viewmodel-Controller"])
local Object = require(ReplicatedStorage.Shared.Modules.Object)
local WeaponChecks = require(ReplicatedStorage.Shared.Modules.WeaponChecks)
local Network = require(ReplicatedStorage.Shared.network.client)

local WeaponConfigsList = {}
for _, config in ReplicatedStorage.Shared.Config.Weapons:GetChildren() do
    if not config:IsA("ModuleScript") then continue end

    WeaponConfigsList[config.Name] = require(config)
end

local Weapons = {}
Weapons.__index = Weapons

function Weapons.new(name: string, viewmodel_controller: ViewmodelController.ViewmodelController): Weapon | nil
    if Network.CreateWeapon.Call(name) == "fail" then return end
    if not WeaponConfigsList[name] then return end

    local self = setmetatable({}, Weapons)
    self.name = name
    self.model = ReplicatedStorage.Assets.Weapons[name]:Clone()
    self.data = WeaponConfigsList[name]
    self.viewmodel_controller = viewmodel_controller
    self.animations = {}

    self.state = table.clone(atoms.weapon_data)

    self.syncer = CharmSync.client({
        atoms = self.state
    })

    Object.setPhysics(self.model, false, false)

    self:initializeRig()
    self:initializeAnimations()

    Charm.subscribe(self.state.ammo_count, function(state)
        Interface.updateAmmo(state, self.state.ammo_held())
    end)

    Charm.subscribe(self.state.ammo_held, function(state)
        Interface.updateAmmo(self.state.ammo_count(), state)
    end)

    return self
end

function Weapons.playAnimation(self: Weapon, name: string)
    if not self.animations[name] then return end

    self.animations[name]:Play()

    if name ~= "Inspect" and self.animations.Inspect.IsPlaying == true then
        self.animations.Inspect:Stop()
    end
end

function Weapons.initializeRig(self: Weapon)
    for _, rigData in self.data.Rig.Viewmodel do
        local prefix0, name0 = string.match(rigData.Part0, "([^/]+)/(.+)")
        local prefix1, name1 = string.match(rigData.Part1, "([^/]+)/(.+)")
        
        local part0 = (prefix0 == "Weapon" and self.model or self.viewmodel_controller.model):FindFirstChild(name0)
        local part1 = (prefix1 == "Weapon" and self.model or self.viewmodel_controller.model):FindFirstChild(name1)

        Object.rig(part0, part1, rigData.C0, rigData.C1)
    end
end

function Weapons.initializeAnimations(self: Weapon)
    -- should probably seperate this
    local priorities = {
        Fire = Enum.AnimationPriority.Action,
        TacticalReload = Enum.AnimationPriority.Action,
        EmptyReload = Enum.AnimationPriority.Action,
        Idle = Enum.AnimationPriority.Idle,
        Equip = Enum.AnimationPriority.Core
    }

    for _, animation in self.model.Animations:GetChildren() do
        if not animation:IsA("Animation") then continue end

        self.animations[animation.Name] = self.viewmodel_controller.animator:LoadAnimation(animation)

        if priorities[animation.Name] then
            self.animations[animation.Name].Priority = priorities[animation.Name]
        end
    end
end

function Weapons.equip(self: Weapon)
    if WeaponChecks.canEquip(self.state) == false then return end
    if Network.EquipWeapon.Call(self.name) == "fail" then return end

    self.model.Parent = self.viewmodel_controller.model

    self:playAnimation("Equip")
    self:playAnimation("Idle")

    self.viewmodel_controller.model:ScaleTo(0.2)
end

function Weapons.reload(self: Weapon)
    if self.state.ammo_count() >= self.data.Ammo.MagazineSize then return end
    if WeaponChecks.canReload(self.state) == false then return end

    self.state.reloading(true)
    Network.ReloadWeapon.Fire()

    local reload_empty = self.state.ammo_count() <= 0
    local animation = reload_empty and "EmptyReload" or "TacticalReload"

    self:playAnimation(animation)
end

function Weapons.fire(self: Weapon)
    if WeaponChecks.canFire(self.state) == false then return end

    local position = UserInputService:GetMouseLocation() -- TODO: make this the center of the screen due to console
    local new_ray = workspace.CurrentCamera:ViewportPointToRay(position.X, position.Y)

    self.state.can_fire(false)
    Network.FireWeapon.Fire({ unit = new_ray, fire_point = self.model.Main.GunFirePoint.WorldPosition })

    self:playAnimation("Fire")
end

function Weapons.inspect(self: Weapon)
    self.animations.Inspect.Looped = false -- too lazy to do this manually in studio
    self:playAnimation("Inspect")
end

export type Weapon = typeof(Weapons) & {
    name: string,
    model: Model & {
        Animations: Folder,
        Main: BasePart & {
            GunFirePoint: Attachment
        }
    },
    data: { [string]: any }, 
    viewmodel_controller: ViewmodelController.ViewmodelController,
    animations: { [string]: AnimationTrack },
    reloading: boolean,

    state: typeof(atoms.weapon_data),
    syncer: any
}

return Weapons :: Weapon
