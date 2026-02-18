local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local HubConfig = require(ReplicatedStorage.Shared.modules.Hub.Config)
local PlaceIds = HubConfig.PlaceIds

local isHub = table.find(HubConfig.HubPlaceIds or { PlaceIds.Hub }, game.PlaceId) ~= nil

-- Resolve services folder (works whether script is in Server folder or directly in ServerScriptService)
local serverFolder = script.Parent
local servicesFolder = serverFolder:FindFirstChild("services") or ServerScriptService:FindFirstChild("services")

if servicesFolder then
    if isHub then
        local hubFolder = servicesFolder:FindFirstChild("Hub")
        if hubFolder then
            Knit.AddServices(hubFolder)
        end
    else
        local combatFolder = servicesFolder:FindFirstChild("Combat")
        if combatFolder then
            Knit.AddServices(combatFolder)
        end
    end
end

Knit.Start():catch(warn)
