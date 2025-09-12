local ReplicatedStorage = game:GetService("ReplicatedStorage")

local World = require(ReplicatedStorage:WaitForChild("Shared").World)

World.add(script.Parent, "Client/Test")

World.init()