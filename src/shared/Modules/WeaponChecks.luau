local ReplicatedStorage = game:GetService("ReplicatedStorage")
local atoms = require(ReplicatedStorage.Shared.Config.atoms)

local function canEquip(state: typeof(atoms.weapon_data))
    if state.enabled() == false then return false end
    if state.equipped() == true then return false end
    
    return true
end

local function canUnequip(state: typeof(atoms.weapon_data))
    if state.can_fire() == false then return false end 
    if state.reloading() == true then return false end
    if state.enabled() == false then return false end
    if state.equipped() == false then return false end

    return true
end

local function canFire(state: typeof(atoms.weapon_data))
    if state.enabled() == false then return false end
    if state.equipped() == false then return false end
    if state.can_fire() == false then return false end
    if state.reloading() == true then return false end
    if state.ammo_count() == 0 then return false end

    return true
end

local function canReload(state: typeof(atoms.weapon_data))
    if state.ammo_held() == 0 then return false end
    if state.enabled() == false then return false end
    if state.equipped() == false then return false end
    if state.can_fire() == false then return false end -- assuming that the user is firing the weapon
    if state.reloading() == true then return false end

    return true
end

return {
    canEquip = canEquip,
    canUnequip = canUnequip,
    canFire = canFire,
    canReload = canReload
}