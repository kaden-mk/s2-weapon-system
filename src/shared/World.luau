-- unity like framework

local RunService = game:GetService("RunService")

local World = {}

local controllers = {}
local services = {}
local initialized = false

local map = require(script.Parent.Config.map)

-- TODO: make the somehow be automatic??? and just improve the overall way to resolve
--[[
    Get the actual file location using a map
    @param key - ex: "src/client"
    @returns Instance
]]
local function resolve(key: string)
    local config = map[key]
    if not config then
        error(`Unknown root: {key}`)
    end

    local service = game:GetService(config.service)
    local root = service

    for _, child_name in config.path do
        if child_name == "LocalPlayer" then
            root = game.Players.LocalPlayer
        else
            root = root:FindFirstChild(child_name)
        end
    end

    return root
end

--[[
    Requires every module inside the specified folder location
    @param folder_location - A string set on where the location is, ex: "src/client/Weapons"
    @returns nil
]]
function World.add(folder_location: string)
    local parts = string.split(folder_location, "/")
    local key = table.concat({parts[1], parts[2]}, "/")

    local folder = resolve(key)

    -- this should definitely be improved
    for i = 3, #parts do
        folder = folder:WaitForChild(parts[i])
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