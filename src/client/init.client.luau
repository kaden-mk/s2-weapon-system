local ReplicatedStorage = game:GetService("ReplicatedStorage")

local World = require(ReplicatedStorage:WaitForChild("Shared").World)

World.add("src/client/Viewmodel")
World.add("src/client/Weapons")

World.init()