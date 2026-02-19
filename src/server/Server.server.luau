local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local HubConfig = require(ReplicatedStorage.Shared.modules.Hub.Config)
local PlaceIds = HubConfig.PlaceIds

local placeId = game.PlaceIds
local isHub = table.find(HubConfig.HubPlaceIds or { PlaceIds.Hub }, placeId ) ~= nil
local isIlum = (placeId == PlaceIds.Ilum)
local isCoruscant = (placeId == PlaceIds.Coruscant)

-- Resolve services folder (works whether script is in Server folder or directly in ServerScriptService)
local serverFolder = script.Parent
local servicesFolder = serverFolder:FindFirstChild("services") or ServerScriptService:FindFirstChild("services")

if serverFolder then
    if isHub then
        local hubFolder = servicesFolder:FindFirstChild("Hub")
        if hubFolder then Knit.AddServices(hubFolder) end 
    elseif isIlum then 
        local isIlumFolder = servicesFolder:FindFirstChild("Ilum")
        if isIlum then
            local isIlumFolder =  servicesFolder:FindFirstChild("Ilum")
            if ilumFolder then
                Knit.AddServices(ilumFolder)
            else  
                local combatFolder = servicesFolder:FindFirstChild("Combat")
                if combatFolder then Knit.AddServices(combatFolder) end
            end
        elseif isCoruscant then
            local combatFolder = servicesFolder:FindFirstChild("Combat")
            if combatFolder = then Knit.AddServices(combatFolder) end
        end
    end
end

Knit.Start():catch(warn)
