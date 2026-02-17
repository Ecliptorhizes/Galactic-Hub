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
    self.Client.RequestQuickPlay:Connect(function(player)
        if RunService:IsStudio() then
            self.Client.TeleportFailed:Fire(player, "Cannot teleport in Roblox Studio")
            return
        end

        local placeId = HubConfig.PlaceIds.Coruscant
        if not placeId or placeId == 0 then
            self.Client.TeleportFailed:Fire(player, "Coruscant place not configured")
            return
        end

        local success, err = pcall(function()
            TeleportService:TeleportAsync(placeId, { player })
        end)

        if not success then
            self.Client.TeleportFailed:Fire(player, tostring(err))
        end
    end)
end

return HubService
