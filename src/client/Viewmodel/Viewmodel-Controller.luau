local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Assets = ReplicatedStorage.Assets

local Object = require(ReplicatedStorage.Shared.Modules.Object)
local World = require(ReplicatedStorage.Shared.World)

local ViewmodelController = { name = "ViewmodelController" }
ViewmodelController.__index = ViewmodelController

function ViewmodelController.onInit(self: ViewmodelController)
    self.model = Assets.Viewmodels.Default:Clone()
end

function ViewmodelController.onStart(self: ViewmodelController)
    Object.setPhysics(self.model, false, false)
    self.model.Parent = workspace.CurrentCamera
end

function ViewmodelController.onRender(self: ViewmodelController)
    self.model:PivotTo(workspace.CurrentCamera.CFrame)
end

export type ViewmodelController = typeof(ViewmodelController) & {
    model: Model
}

World.controller(ViewmodelController)
return ViewmodelController