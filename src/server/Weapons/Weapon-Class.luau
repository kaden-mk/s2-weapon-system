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

    return self
end 

export type Weapon = typeof(Weapon) & {
    owner: Player,
    name: string,
    data: { any },
    firerate: number,
}

return Weapon :: Weapon