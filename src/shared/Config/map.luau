return {
    ["src/client"] = { service = "Players", path = {"LocalPlayer", "PlayerScripts", "Client"} },
    ["src/server"] = { service = "ServerScriptService", path = {"Server"} },
    ["src/shared"] = { service = "ReplicatedStorage", path = {"Shared"} }
}