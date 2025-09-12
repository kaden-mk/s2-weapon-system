local ReplicatedStorage = game:GetService("ReplicatedStorage")

local World = require(ReplicatedStorage.Shared.World)

local Manager = {}
World.controller(Manager)

function Manager.onInit(self: TestManager)
    self.thing = "hi"
    print(self.thing)
end

function Manager.onRender(self: TestManager)
    print(self.thing)
end

export type TestManager = typeof(Manager) & {
    thing: string
}

return Manager