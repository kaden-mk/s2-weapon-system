local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Assets = ReplicatedStorage.Assets

local Object = require(ReplicatedStorage.Shared.Modules.Object)
local World = require(ReplicatedStorage.Shared.World)

local camera = workspace.CurrentCamera

local ViewmodelController = { name = "ViewmodelController" }
ViewmodelController.__index = ViewmodelController

function ViewmodelController.constructor(self: ViewmodelController)
    self.model = Assets.Viewmodels.Default:Clone()
    self.old_camera_cframe = CFrame.identity
    self.fake_camera = self.model:FindFirstChild("FakeCamera") :: BasePart

    local animation_controller = self.model:FindFirstChildOfClass("AnimationController") :: AnimationController
    local animator = animation_controller:FindFirstChildOfClass("Animator") :: Animator

    self.animator = animator
end

function ViewmodelController.onStart(self: ViewmodelController)
    Object.setPhysics(self.model, false, false)
    self.model.Parent = camera
    if self.model.PrimaryPart then
        self.model.PrimaryPart.Anchored = true
    end
end

function ViewmodelController.updateCamera(self: ViewmodelController)
    local primary_part = self.model.PrimaryPart :: BasePart

    local new_camera_cframe = self.fake_camera.CFrame:ToObjectSpace(primary_part.CFrame)
    camera.CFrame = camera.CFrame * new_camera_cframe:ToObjectSpace(self.old_camera_cframe)
    self.old_camera_cframe = new_camera_cframe
end

function ViewmodelController.onRender(self: ViewmodelController)
    if not self.model.PrimaryPart then return end

    self:updateCamera()
    self.model.PrimaryPart.CFrame = camera.CFrame
end

export type ViewmodelController = typeof(ViewmodelController) & {
    model: Model,
    animator: Animator,
    old_camera_cframe: CFrame,
    fake_camera: BasePart
}

World.controller(ViewmodelController)
return ViewmodelController