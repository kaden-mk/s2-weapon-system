return {
    Rig = {
        {
            Part0 = "Viewmodel/HumanoidRootPart",
            Part1 = "Weapon/Handle",
            C0 = CFrame.new(-1.107, -0.875, 0.565) * CFrame.Angles(math.rad(-1.345), math.rad(-175.111), math.rad(0.084))
        }
    },

    RPM = 600,
    
    Ammo = {
        MagazineSize = 30,
        MaxMagazineCount = 5,
        Type = "5.56x45mm"
    },

    -- uses the first firemode
    Firemodes = { "Auto", "Semi" },

    EquipTime = 1,
    UnequipTime = 1
}