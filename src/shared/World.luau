-- unity like framework

local RunService = game:GetService("RunService")

local World = {}

local controllers = {}
local services = {}
local initialized = false

--[[
    Requires every module inside the specified folder location
    @param root - The beginning of where to start the search
    @param folder_location - A string set on where the location is, ex: "client/Classes/Weapons"
    @returns nil
]]
function World.add(root: Instance, folder_location: string)
    local locations = string.split(folder_location, "/")
    local folder = root

    for _, location in locations do
        folder = folder:WaitForChild(location)
    end

    for _, module in folder:GetChildren() do
        if not module:IsA("ModuleScript") then continue end

        require(module)
    end
end

--[[
    Adds the specified controller to a list which allows you to use functions such as "onInit" & "onRender"
    @param controller - The specified controller in question
    @returns nil
]]
function World.controller(controller: { any })
    if RunService:IsServer() then
        warn("Controllers can only be created on the client!")
        return
    end

    controllers[controller] = controller
end

--[[
    Adds the specified service to a list which allows you to use functions such as "onInit" & "onUpdate"
    @param service - The specified service in question
    @returns nil
]]
function World.service(service: { any })
    if RunService:IsClient() then
        warn("Services can only be created on the server!")
        return
    end


    services[service] = service
end

--[[
    Initializes the world and runs onInit on every service/controller
    @returns nil
]]
function World.init()
    if initialized then
        warn("World cannot be initialized more than once!")
        return
    end
    initialized = true

    local is_client = RunService:IsClient()
    local to_update = {}
    local module_list = is_client and controllers or services
    local connection = is_client and RunService.PreRender or RunService.PostSimulation
    local method = is_client and "onRender" or "onUpdate"
    
    for _, module in module_list do
        if module.onInit then
            module:onInit()
        end

        if module[method] then
            to_update[module] = true
        end
    end

    connection:Connect(function(deltaTime)
        for module in to_update do
            module[method](module, deltaTime)
        end
    end)
end

return World