return {
    Rig = {
        {
            Part0 = "Viewmodel/HumanoidRootPart",
            Part1 = "Weapon/Main",
            C0 = CFrame.new(1.174, 0.297, -4.025),
        },
        {
            Part0 = "Weapon/Main",
            Part1 = "Viewmodel/Left Arm",
            C0 = CFrame.new(-2.674, -0.476, 1.714) * CFrame.Angles(math.rad(90), 0, 0)
        },
        {
            Part0 = "Weapon/Main",
            Part1 = "Viewmodel/Right Arm",
            C0 = CFrame.new(0.298, -0.426, 1.755) * CFrame.Angles(math.rad(90), 0, 0)
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