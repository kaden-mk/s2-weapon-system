local ExperienceStateRecordingService = game:GetService("ExperienceStateRecordingService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Caster = require(ServerScriptService.Server.Modules.Caster)
local Charm = require(ReplicatedStorage.Packages.Charm)
local atoms = require(ReplicatedStorage.Shared.Config.atoms)
local WeaponChecks = require(ReplicatedStorage.Shared.Modules.WeaponChecks)
local PlayerClass = require(ServerScriptService.Server.Players["Player-Class"])

local WeaponConfigsList = {}
for _, config in ReplicatedStorage.Shared.Config.Weapons:GetChildren() do
    if not config:IsA("ModuleScript") then continue end

    WeaponConfigsList[config.Name] = require(config)
end

local Weapon = {}
Weapon.__index = Weapon

local function createWeaponState()
    return {
        enabled = Charm.atom(true),
        can_fire = Charm.atom(true),
        equipped = Charm.atom(false),
        reloading = Charm.atom(false),
        ammo_count = Charm.atom(0),
        ammo_held = Charm.atom(0)
    } :: typeof(atoms.weapon_data)
end

function Weapon.new(name: string, player: PlayerClass.PlayerClass): Weapon | nil
    if not WeaponConfigsList[name] then return end

    local self = setmetatable({}, Weapon)
    self.owner = player
    self.name = name
    self.data = WeaponConfigsList[name]
    self.firerate = 1 / (self.data.RPM / 60)

    self.state = createWeaponState()
    self.state.ammo_count(self.data.Ammo.MagazineSize) 
    self.state.ammo_held(self.data.Ammo.MagazineSize * self.data.Ammo.MaxMagazineCount)

    return self
end 

function Weapon.equip(self: Weapon)
    if WeaponChecks.canEquip(self.state) == false then return end

    self.state.enabled(false)
    self.owner.equipped_weapon = self.name
    task.delay(self.data.EquipTime, function()
        self.state.enabled(true)
        self.state.equipped(true)
    end)

    return true
end

function Weapon.fire(self: Weapon, unit_ray: Ray, fire_point: Vector3)
    if WeaponChecks.canFire(self.state) == false then return end

    self.state.ammo_count(function(old)
        return old - 1
    end)

    self.state.can_fire(false)
    task.delay(self.firerate, function()
        self.state.can_fire(true)
    end)

    -- basic raycast test
    local params = RaycastParams.new() -- this shouldnt be created here due to lag
    params.FilterDescendantsInstances = { self.owner.player.Character }
    params.FilterType = Enum.RaycastFilterType.Exclude

    local distance = 500
    local direction = (unit_ray.Direction.Unit * distance)

    local result = workspace:Raycast(fire_point, direction, params)
    local endPoint = result and result.Position or (fire_point + direction)

    local part = Instance.new("Part")
    part.Anchored = true
    part.CanCollide = false
    part.Material = Enum.Material.Neon
    part.Color = Color3.fromRGB(255, 0, 0)
    part.Size = Vector3.new(0.1, 0.1, (endPoint - fire_point).Magnitude)
    part.CFrame = CFrame.new(fire_point, endPoint) * CFrame.new(0, 0, -part.Size.Z/2)
    part.Parent = workspace

    --game:GetService("Debris"):AddItem(part, 0.1)
end

function Weapon.reload(self: Weapon)
    if WeaponChecks.canReload(self.state) == false then return end

    self.state.reloading(true)

    local reload_empty = self.state.ammo_count() <= 0
    local time: number = reload_empty and self.data.ReloadEmptyTime or self.data.ReloadTime

    task.delay(time, function()
        self.state.reloading(false)

        local ammo_needed = self.data.Ammo.MagazineSize - self.state.ammo_count()

        if self.state.ammo_held() >= ammo_needed then
            self.state.ammo_count(self.data.Ammo.MagazineSize)
            self.state.ammo_held(function(state)
                return state - ammo_needed
            end)
        else
            self.state.ammo_count(function(state)
                return state + self.state.ammo_held()
            end)
            self.state.ammo_held(0)
        end
    end)
end

export type Weapon = typeof(Weapon) & {
    owner: PlayerClass.PlayerClass,
    name: string,
    data: { [string]: any },
    firerate: number,
    state: typeof(atoms.weapon_data)
}

return Weapon :: Weapon