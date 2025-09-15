local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local PlayerClass = require(ServerScriptService.Server.Players["Player-Class"])

local WeaponConfigsList = {}
for _, config in ReplicatedStorage.Shared.Config.Weapons:GetChildren() do
    if not config:IsA("ModuleScript") then continue end

    WeaponConfigsList[config.Name] = require(config)
end

local Weapon = {}
Weapon.__index = Weapon

function Weapon.new(name: string, player: PlayerClass.PlayerClass): Weapon | nil
    if not WeaponConfigsList[name] then return end

    local self = setmetatable({}, Weapon)
    self.owner = player
    self.name = name
    self.data = WeaponConfigsList[name]
    self.firerate = 1 / (self.data.RPM / 60)

    return self
end 

export type Weapon = typeof(Weapon) & {
    owner: Player,
    name: string,
    data: { any },
    firerate: number,
}

return Weapon :: Weapon