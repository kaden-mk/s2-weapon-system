-- unity like framework

local RunService = game:GetService("RunService")

local World = {}

-- bruh
local controllers = {}
local services = {}
local singletons = {}
local singletons_ready = {}
local singletons_pending = {}
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
    if string.find(script:GetFullName(), "StarterPlayerScripts") then return end
        
    local parts = string.split(folder_location, "/")
    local key = table.concat({parts[1], parts[2]}, "/")

    local folder = resolve(key)

    -- this should definitely be improved
    for i = 3, #parts do
        folder = folder:FindFirstChild(parts[i])
    end

    for _, module in folder:GetChildren() do
        if not module:IsA("ModuleScript") then continue end

        require(module)
    end
end

--[[
    Adds the specified controller to a list which allows you to use functions such as "onStart" & "onRender"
    @param controller - The specified controller in question
    @returns nil
]]
function World.controller(controller: { name: string? })
    if RunService:IsServer() then
        warn("Controllers can only be created on the client!")
        return
    end

    if controllers[controller] then return end
    if controller.name and singletons[controller.name] then return end

    controllers[controller] = controller
    if controller.name then
        singletons[controller.name] = controller
    end
end

--[[
    Adds the specified service to a list which allows you to use functions such as "onStart" & "onUpdate"
    @param service - The specified service in question
    @returns nil
]]
function World.service(service: { name: string? })
    if RunService:IsClient() then
        warn("Services can only be created on the server!")
        return
    end

    services[service] = service
    if service.name then
        singletons[service.name] = service
    end
end

function World.import(name: string)
    if singletons_ready[name] then
        return singletons[name]
    end

    local thread = coroutine.running()
    if not singletons_pending[name] then
        singletons_pending[name] = {}
    end

    table.insert(singletons_pending[name], thread)
    return coroutine.yield()
end

--[[
    Initializes the world and runs onStart on every service/controller
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
        task.spawn(function()
            if module.constructor then
                module:constructor()
            end

            if module.onStart then
                module:onStart()
            end

            if module.name then
                singletons_ready[module.name] = true
                if singletons_pending[module.name] then
                    for _, thread in singletons_pending[module.name] do
                        coroutine.resume(thread, singletons[module.name])
                    end
                    singletons_pending[module.name] = nil
                end
            end
        end)

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