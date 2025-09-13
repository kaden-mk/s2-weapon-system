local UserInputService = game:GetService("UserInputService")

type InputValue = Enum.KeyCode | Enum.UserInputType

type Binding = {
    code: InputValue | { InputValue },
    ends: boolean,
    callback: (input: InputObject, ended: boolean?) -> ()
} 

local inputs = {}

local function create(name: string)
    if inputs[name] then return end

    inputs[name] = {
        bindings = {},
        activeInputs = {},
        enabled = true
    }
end

local function bind(name: string, binding_name: string, code: InputValue | { InputValue }, callback: (input: InputObject, ended: boolean?) -> (), ends: boolean)
    if not inputs[name] then return end
    if inputs[name].bindings[binding_name] then return end

    inputs[name].bindings[binding_name] = {
        code = code,
        ends = ends,
        callback = callback
    }
end 

local function unbind(name: string, binding_name: string)
   if not inputs[name] or not inputs[name][binding_name] then return end

   inputs[name][binding_name] = nil 
end

local function matchesInput(code: InputValue | { InputValue }, input: InputValue): boolean
    if type(code) == "table" then
        for i = 0, #code - 1 do
            if code[i + 1] == input then
                return true
            end
        end

        return false
    end

    return code :: InputValue == input
end

local function findBinding(bindings: { Binding } , input: InputValue): Binding | false
    for _, data in bindings do
        if matchesInput(data.code, input) then
            return data
        end
    end

    return false
end

UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end

    local input_type = input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode or input.UserInputType
    
    for _, data in inputs do
        if data.enabled == false then continue end

        local binding = findBinding(data.bindings, input_type) :: Binding
        if binding == false then continue end

        data.activeInputs[input_type] = input
        binding.callback(input, false)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    local input_type = input.UserInputType == Enum.UserInputType.Keyboard and input.UserInputType or input.KeyCode

    for _, data in inputs do
        if data.enabled == false then continue end

        local binding = findBinding(data.bindings, input_type) :: Binding
        if binding == false then continue end
        if binding.ends == false then continue end

        data.activeInputs[input_type] = nil
        binding.callback(input, true)
    end
end)   

UserInputService.WindowFocusReleased:Connect(function()
    for _, data in inputs do
        for input, input_type in data.activeInputs do
            local binding = findBinding(data.bindings, input_type) :: Binding

            if binding and binding.ends then
                binding.callback(input, true)
            end
        end

        data.activeInputs = {}
    end
end)

return {
    create = create,
    bind = bind,
    unbind = unbind
}