local ReplicatedStorage = game:GetService("ReplicatedStorage")

local World = require(ReplicatedStorage.Shared.World)

local ViewmodelController = {}
ViewmodelController.__index = ViewmodelController

function ViewmodelController.onInit(self: ViewmodelController)
    
end

export type ViewmodelController = typeof(ViewmodelController) & {
}

World.controller(ViewmodelController)
return ViewmodelController