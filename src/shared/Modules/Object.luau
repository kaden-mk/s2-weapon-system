local function setPhysics(object: BasePart | Model, anchored: boolean, collision: boolean)
    if object:IsA("BasePart") then
        object.Anchored = anchored
        object.CanCollide = collision
    end

    for _, descendant in object:GetDescendants() do
        if not descendant:IsA("BasePart") then continue end

        descendant.Anchored = anchored
        descendant.CanCollide = collision
    end
end

local function rig(part0: BasePart, part1: BasePart, c0: CFrame?, c1: CFrame?)
    local motor = Instance.new("Motor6D")
    motor.Part0 = part0
    motor.Part1 = part1
    motor.Name = part1.Name
    motor.Parent = part0

    if c0 then
        motor.C0 = c0
    end
    if c1 then
        motor.C1 = c1
    end
    
    return motor
end

return {
    setPhysics = setPhysics,
    rig = rig
}