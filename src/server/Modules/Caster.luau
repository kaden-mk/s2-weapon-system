local function cast(origin: Vector3, direction: Vector3, distance: number, visualize: boolean?)
    visualize = visualize or false

    local ray = workspace:Raycast(origin, direction * distance)

    print(ray)

    if ray and visualize then
        local part = Instance.new("Part")
        part.Anchored = true
        part.CanCollide = false
        part.CFrame = CFrame.new(origin + direction.Unit * distance)
        part.Size = Vector3.new(distance, 0.2, 0.2)
        part.Parent = workspace
    end
end

return {
    cast = cast
}