local ReplicatedStorage = game:GetService("ReplicatedStorage")

local World = require(ReplicatedStorage.Shared.World)

local ViewmodelController = {}
ViewmodelController.__index = ViewmodelController

local function constructor()
    local self = setmetatable({}, ViewmodelController)
    self.dude = "print"

    return self
end

function ViewmodelController.onInit(self: ViewmodelController)
    print(self.dude)
end

export type ViewmodelController = typeof(ViewmodelController) & {
    dude: string
}

World.controller(constructor())
return ViewmodelController