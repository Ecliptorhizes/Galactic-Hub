local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local HubConfig = require(ReplicatedStorage.Shared.modules.Hub.Config)

local HubService = Knit.CreateService({
    Name = "HubService",
    Client = {
        RequestQuickPlay = Knit.CreateSignal(),
        TeleportFailed = Knit.CreateSignal(),
    },
})

function HubService:KnitInit()
    self.Client.RequestQuickPlay:Connect(function(player, placeKey)
        if RunService:IsStudio() then
            self.Client.TeleportFailed:Fire(player, "Cannot teleport in Roblox Studio")
            return
        end

        if placeKey ~= "Coruscant" and placeKey ~= "Ilum" then 
            self.Client.TeleportFailed:Fire(player, "Invalid place: " .. tostring(placeKey))
            return
        end

        if placeKey == "Ilum" and not HubConfig.IlumEnabled then
            self.Client.TeleportFailed:Fire(player, "Ilum is not ready yet")
            return
        end

        local placeId = HubConfig.PlaceIds[placeKey]
        if not placeId or placeId == 0 then
            self.Client.TeleportFailed:Fire(player, placeKey .. " place not configured")
            return
        end

        print("[HubService] QuickPlay: " .. placeKey .. " -> PlaceId " .. tostring(placeId) .. " (player: " .. player.Name .. ")")

        local success, err = pcall(function()
            TeleportService:TeleportAsync(placeId, { player })
        end)

        if success then
            print("[HubService] Teleport initiated to " .. placeKey)
        else
            warn("[HubService] Teleport failed:", err)
            self.Client.TeleportFailed:Fire(player, tostring(err))
        end
    end)
end

return HubService
