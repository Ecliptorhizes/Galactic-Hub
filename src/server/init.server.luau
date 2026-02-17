local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local PlaceIds = require(ReplicatedStorage.Shared.modules.Hub.Config).PlaceIds

local isHub = (game.PlaceId == PlaceIds.Hub)

-- Resolve services folder (works whether script is in Server folder or directly in ServerScriptService)
local serverFolder = script.Parent
local servicesFolder = serverFolder:FindFirstChild("services") or ServerScriptService:FindFirstChild("services")

if servicesFolder then
    if isHub then
        local hubService = servicesFolder:FindFirstChild("HubService")
        if hubService then
            Knit.AddServices(hubService)
        end
    else
        local combatService = servicesFolder:FindFirstChild("CombatService")
        if combatService then
            Knit.AddServices(combatService)
        end
    end
end

Knit.Start():catch(warn)


