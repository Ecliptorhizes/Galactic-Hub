local Players = game:GetService("Players")
local Knit = require(game.ReplicatedStorage.Packages.Knit)

local HubController = Knit.CreateController({
    Name = "HubController",
})

local function findQuickPlayButtons(container: Instance): { Instance }
    local buttons = {}
    for _, descendant in container:GetDescendants() do
        if descendant:IsA("GuiButton") and (descendant.Name == "QuickPlay" or descendant.Name:lower():find("quickplay")) then
            table.insert(buttons, descendant)
        end
    end
    return buttons
end

function HubController:KnitStart()
    local HubService = Knit.GetService("HubService")
    local player = Players.LocalPlayer
    local playerGui = player:WaitForChild("PlayerGui")

    HubService.TeleportFailed:Connect(function(err)
        warn("Teleport failed:", err)
    end)

    local mainUi = playerGui:WaitForChild("MainUi")
    local mapSelect = mainUi:FindFirstChild("Holder")
        and mainUi.Holder:FindFirstChild("Backdrop")
        and mainUi.Holder.Backdrop:FindFirstChild("Frame")
        and mainUi.Holder.Backdrop.Frame:FindFirstChild("MapSelect")

    if not mapSelect then
        mapSelect = mainUi:FindFirstDescendant("MapSelect") or mainUi
    end

    local quickPlayButtons = findQuickPlayButtons(mapSelect or mainUi)

    for _, button in quickPlayButtons do
        button.Activated:Connect(function()
            HubService.RequestQuickPlay:Fire()
        end)
    end
end

return HubController
