local Players = game:GetService("Players")

local player = Players.LocalPlayer
local player_gui = player:WaitForChild("PlayerGui") :: PlayerGui

local function updateAmmo(ammo_count: number, ammo_held: number)
    player_gui:WaitForChild("GameGui").Frame.TextLabel.Text = `Ammo: {ammo_count}/{ammo_held}`
end

return {
    updateAmmo = updateAmmo
}