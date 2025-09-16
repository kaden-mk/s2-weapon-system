local ExperienceStateRecordingService = game:GetService("ExperienceStateRecordingService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Charm = require(ReplicatedStorage.Packages.Charm)
local atoms = require(ReplicatedStorage.Shared.Config.atoms)
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
        ammo_count = Charm.atom(0)
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

    return self
end 

function Weapon.equip(self: Weapon)
    if self.state.enabled() == false then return end
    if self.state.equipped() == true then return end 

    self.state.enabled(false)
    self.owner.equipped_weapon = self.name
    task.delay(self.data.EquipTime, function()
        self.state.enabled(true)
        self.state.equipped(true)
    end)

    return true
end

function Weapon.fire(self: Weapon)
    if self.state.enabled() == false then return end 
    if self.state.equipped() == false then return end
    if self.state.can_fire() == false then return end
    if self.state.ammo_count() == 0 then return end

    self.state.ammo_count(function(old)
        return old - 1
    end)
    self.state.can_fire(false)
    task.delay(self.firerate, function()
        self.state.can_fire(true)
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