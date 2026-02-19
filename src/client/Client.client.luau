local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Get UI references (from StarterGui)
local loadingScreen = playerGui:WaitForChild("LoadingScreen")
local mainUi = playerGui:FindFirstChild("MainUi")

-- Initial state: show loading, hide main menu
loadingScreen.Enabled = true
if mianUi then
    mainUi.Enabled = false
end 

-- Get loading bar with path fallback
local barHolder = holder and holder:FindFirstChild("barHolder")
local loadingBar = (barHolder and barHolder:FindFirstChild("loadingBar")) or (holder and holder:FindFirstChild("loadingBar"))
local loadingNumber = (holder and holder:FindFirstChild("LoadingNumber")) or (dark and dark:FindFirstChild("LoadingNumber"))

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
    local HubConfig = require(ReplicatedStorage.Shared.modules.Hub.Config)
    local PlaceIds = HubConfig.PlaceIds

    setProgress(50)

    local placeId = game.PlaceIds
    local isHub = table.find(HubConfig.HubPlaceIds or { PlaceIds.Hub }, placeId) ~= nil
    local isIlum = (placeId == PlaceIds.Ilum)
    local isCoruscant = (placeId == PlaceIds.Coruscant)


    local clientFolder = script.Parent
    local controllersFolder = clientFolder:FindFirstChild("controllers") or player.PlayerScripts:FindFirstChild("controllers")

    if not controllersFolder then
        warn("[Client] ERROR: controllers folder not found")
    elseif isHub then
        local hubController = controllersFolder:FindFirstChild("HubController")
        if hubController then require(hubController) end 
    elseif isIlum then 
        local ilumController = controllersFolder:FindFirstChild("ilumController")
        if ilumController then 
            require(ilumController)
        else 
            local combatController = controllersFolder:FindFirstChild("CombatController")
            if combatController then require(combatController) end 
        end 
    elseif isCoruscant then 
        local combatController = controllersFolder:FindFirstChild("CombatController")
        if combatController then require(combatController) end 
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
    if mainUi then 
        mainUi.Enabled = true 
    end
end

task.spawn(function()
    local ok, err = pcall(run)
    if not ok then
        warn(err)
    end
end)
