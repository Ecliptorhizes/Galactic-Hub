local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Get UI references (from StarterGui)
local loadingScreen = playerGui:WaitForChild("LoadingScreen")
local mainUi = playerGui:WaitForChild("MainUi")

-- Initial state: show loading, hide main menu
loadingScreen.Enabled = true
mainUi.Enabled = false

-- Get loading bar with path fallback
local holder = loadingScreen:FindFirstChild("Background")
    and loadingScreen.Background:FindFirstChild("Dark")
    and loadingScreen.Background.Dark:FindFirstChild("Holder")

local barHolder = holder and holder:FindFirstChild("barHolder")
local loadingBar = (barHolder and barHolder:FindFirstChild("loadingBar")) or (holder and holder:FindFirstChild("loadingBar"))
local loadingNumber = holder and holder:FindFirstChild("LoadingNumber")

-- Smooth loading bar animation (size only: 0.001 -> 1.003 on X scale)
local targetProgress = 0
local currentProgress = 0
local minLoadDuration = 1.5

local function setProgress(percent: number)
    targetProgress = math.max(targetProgress, math.clamp(percent, 0, 100))
end

local function updateBar()
    local scale = 0.001 + (currentProgress / 100) * 1.002
    if loadingBar and loadingBar:IsA("Frame") then
        loadingBar.Size = UDim2.new(scale, 0, 1, 0)
    end
    if loadingNumber and loadingNumber:IsA("TextLabel") then
        loadingNumber.Text = "Loading (" .. math.floor(currentProgress) .. "/100)"
    end
end

-- Spawn smooth animation thread
task.spawn(function()
    local startTime = os.clock()
    while currentProgress < 100 do
        local elapsed = os.clock() - startTime
        local timeBasedProgress = math.min(100, (elapsed / minLoadDuration) * 100)
        targetProgress = math.max(targetProgress, timeBasedProgress)
        if targetProgress > currentProgress then
            currentProgress = math.min(targetProgress, currentProgress + 4)
        end
        updateBar()
        if currentProgress >= 100 then
            break
        end
        task.wait(0.05)
    end
    updateBar()
end)

-- Loading Sequence
local function run()
    setProgress(10)

    ReplicatedStorage:WaitForChild("Shared")
    ReplicatedStorage:WaitForChild("Packages")
    setProgress(30)

    local Knit = require(ReplicatedStorage.Packages.Knit)
    local PlaceIds = require(ReplicatedStorage.Shared.modules.Hub.Config).PlaceIds

    setProgress(50)

    local isHub = (game.PlaceId == PlaceIds.Hub)

    local clientFolder = script.Parent
    local controllersFolder = clientFolder:FindFirstChild("controllers") or player.PlayerScripts:FindFirstChild("controllers")

    if controllersFolder then
        if isHub then
            local hubController = controllersFolder:FindFirstChild("HubController")
            if hubController then
                Knit.AddControllers(hubController)
            end
        else
            local combatController = controllersFolder:FindFirstChild("CombatController")
            if combatController then
                Knit.AddControllers(combatController)
            end
        end
    end

    setProgress(70)

    Knit.Start():await()
    setProgress(90)

    if not player.Character then
        player.CharacterAdded:Wait()
    end

    setProgress(100)

    while currentProgress < 100 do
        task.wait(0.05)
    end

    task.wait(0.5)

    loadingScreen.Enabled = false
    mainUi.Enabled = true
end

task.spawn(function()
    local ok, err = pcall(run)
    if not ok then
        warn(err)
    end
end)
