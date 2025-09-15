local ReplicatedStorage = game:GetService("ReplicatedStorage")

local World = require(ReplicatedStorage.Shared.World)

World.add("src/server/Players")
World.add("src/server/Weapons")

World.init()