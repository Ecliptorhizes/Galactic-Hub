local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(game.ReplicatedStorage.Packages.Knit)

local HubConfig = require(ReplicatedStorage.Shared.modules.Hub.Config)

local TWEEN_INFO = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut, 0, false, 0)

local HubController = Knit.CreateController({
	Name = "HubController",
})

local function getPlaceKeyFromAncestor(instance: Instance)
	local current = instance
	while current do
		local nameLower = current.Name:lower()
		if nameLower:find("coruscant") then
			return "Coruscant"
		end
		if nameLower:find("ilum") or nameLower:find("crystalgathering") then
			return "Ilum"
		end
		current = current.Parent
	end
	return nil
end

local function setupHoverEffect(hoverTarget, frameToTween, textLabel, label)
	hoverTarget.MouseEnter:Connect(function()
		if frameToTween then
			TweenService:Create(frameToTween, TWEEN_INFO, { BackgroundTransparency = 0 }):Play()
		end
		if textLabel and (textLabel:IsA("TextLabel") or textLabel:IsA("TextButton")) then
			TweenService:Create(textLabel, TWEEN_INFO, { TextColor3 = Color3.new(0, 0, 0) }):Play()
		end
		if hoverTarget:IsA("TextButton") then
			TweenService:Create(hoverTarget, TWEEN_INFO, { TextColor3 = Color3.new(0, 0, 0) }):Play()
		end
	end)
	hoverTarget.MouseLeave:Connect(function()
		if frameToTween then
			TweenService:Create(frameToTween, TWEEN_INFO, { BackgroundTransparency = 1 }):Play()
		end
		if textLabel and (textLabel:IsA("TextLabel") or textLabel:IsA("TextButton")) then
			TweenService:Create(textLabel, TWEEN_INFO, { TextColor3 = Color3.new(1, 1, 1) }):Play()
		end
		if hoverTarget:IsA("TextButton") then
			TweenService:Create(hoverTarget, TWEEN_INFO, { TextColor3 = Color3.new(1, 1, 1) }):Play()
		end
	end)
end

function HubController:KnitStart()
	local HubService = Knit.GetService("HubService")
	local player = Players.LocalPlayer
	local playerGui = player:WaitForChild("PlayerGui")

	HubService.TeleportFailed:Connect(function(err)
		warn("[HubController] Teleport failed:", err)
	end)

	local mainUi = playerGui:WaitForChild("MainUi")

	local maps = mainUi:FindFirstChild("MapList") and mainUi.MapList:FindFirstChild("Maps")
	if not maps then
		local holder = mainUi:FindFirstChild("Holder")
		if holder then
			local backdrop = holder:FindFirstChild("Backdrop")
			if backdrop then
				local frame = backdrop:FindFirstChild("Frame")
				if frame then
					local mapSelect = frame:FindFirstChild("MapSelect")
					if mapSelect then
						local mapList = mapSelect:FindFirstChild("MapList")
						if mapList then
							maps = mapList:FindFirstChild("Maps")
						end
					end
				end
			end
		end
	end
	if not maps then
		maps = mainUi:FindFirstDescendant("Maps")
	end

	-- Hide top bar (PLANET: ILUM, PLAYERS, SELECT SERVER) when in Hub
	local function hasTopBarText(inst: Instance): boolean
		if inst:IsA("TextLabel") or inst:IsA("TextButton") then
			local t = inst.Text and inst.Text:upper() or ""
			return t:find("PLANET:") or t:find("PLAYERS:") or t:find("SELECT SERVER")
		end
		return false
	end

	local function containsMapSelect(inst: Instance): boolean
		return inst:FindFirstChild("MapSelect") ~= nil
			or inst:FindFirstChild("MapList") ~= nil
			or inst:FindFirstChild("Maps") ~= nil
			or inst:FindFirstDescendant("MapSelect") ~= nil
	end

	local function hideTopBarIn(gui: Instance)
		for _, descendant in gui:GetDescendants() do
			if hasTopBarText(descendant) then
				-- Find smallest ancestor that has top bar text but NOT map selection (never disable MainUi)
				local current = descendant.Parent
				while current and current ~= gui do
					if current:IsA("GuiObject") and not containsMapSelect(current) then
						current.Visible = false
						return
					end
					current = current.Parent
				end
				return
			end
		end
	end

	local function runHideTopBar()
		if not HubConfig.HideTopBarInHub then
			return
		end
		-- Top bar is often a sibling of Backdrop under Holder
		local holder = mainUi:FindFirstChild("Holder")
		if holder then
			for _, child in holder:GetChildren() do
				if child:IsA("GuiObject") and child.Name ~= "Backdrop" then
					for _, d in child:GetDescendants() do
						if hasTopBarText(d) then
							child.Visible = false
							break
						end
					end
				end
			end
		end
		hideTopBarIn(mainUi)
		for _, child in playerGui:GetChildren() do
			if child:IsA("ScreenGui") then
				hideTopBarIn(child)
			end
		end
	end

	runHideTopBar()
	task.defer(runHideTopBar)
	playerGui.ChildAdded:Connect(function(child)
		if child:IsA("ScreenGui") then
			task.defer(function()
				hideTopBarIn(child)
			end)
		end
	end)

	if not maps then
		warn("[HubController] ERROR: Maps container not found! Check MainUi hierarchy (MapList.Maps or Holder.Backdrop.Frame.MapSelect.MapList.Maps)")
		return
	end

	for _, mapCard in maps:GetChildren() do
		if not mapCard:IsA("GuiObject") then
			-- skip non-GuiObject children
		else
			local isIlum = mapCard.Name:lower():find("ilum") or mapCard.Name:lower():find("crystalgathering")
			if isIlum and not HubConfig.IlumEnabled then
				mapCard.Visible = false
			else
				local quickPlay = mapCard:FindFirstChild("QuickPlay") or mapCard:FindFirstDescendant("QuickPlay")
				local selectServer = mapCard:FindFirstChild("SelectServer") or mapCard:FindFirstDescendant("SelectServer")

				if quickPlay then
					local button = quickPlay:FindFirstChild("ButtonQuickPlay") or quickPlay:FindFirstChild("Button")
						or quickPlay:FindFirstChild("ILUM-QUICKPLAY")
						or quickPlay:FindFirstChildWhichIsA("TextButton") or quickPlay:FindFirstChildWhichIsA("ImageButton")
					local textLabel = quickPlay:FindFirstChild("Text") or quickPlay:FindFirstChildWhichIsA("TextLabel")
					local isButton = button and (button:IsA("TextButton") or button:IsA("ImageButton"))
					local clickTarget = isButton and button or quickPlay
					local placeLabel = getPlaceKeyFromAncestor(quickPlay) or mapCard.Name
					-- Frame to tween: use QuickPlay if it's a GuiObject, else the button (for BackgroundTransparency)
					local frameToTween = (quickPlay:IsA("GuiObject") and quickPlay) or (button and button:IsA("GuiObject") and button) or nil

					-- Hover: connect to QuickPlay Frame (if GuiObject) and always to ButtonQuickPlay when present
					if quickPlay:IsA("GuiObject") then
						setupHoverEffect(quickPlay :: GuiObject, frameToTween, textLabel, "QuickPlay-" .. placeLabel)
					end
					if isButton then
						setupHoverEffect(button :: GuiObject, frameToTween, textLabel, "Button-" .. placeLabel)
					end

					-- Click: ButtonQuickPlay.MouseButton1Click
					local function onQuickPlayClick()
						local ok, err = pcall(function()
							local placeKey = getPlaceKeyFromAncestor(quickPlay)
							if placeKey then
								if placeKey == "Ilum" and not HubConfig.IlumEnabled then
									warn("Ilum Quick Play is disabled (place not ready)")
									return
								end
								HubService.RequestQuickPlay:Fire(placeKey)
							else
								warn("[HubController] ERROR: Could not determine place for QuickPlay button")
							end
						end)
						if not ok then
							warn("[HubController] ERROR on QuickPlay click:", err)
						end
					end

					if isButton then
						button.MouseButton1Click:Connect(onQuickPlayClick)
					else
						clickTarget.MouseButton1Click:Connect(onQuickPlayClick)
					end
				end

				if selectServer and selectServer:IsA("GuiObject") then
					local textLabel = selectServer:FindFirstChild("Text") or selectServer:FindFirstChildWhichIsA("TextLabel")
					local selectButton = selectServer:FindFirstChild("ButtonSelectServer") or selectServer:FindFirstChild("Button")
					local placeLabel = getPlaceKeyFromAncestor(mapCard) or mapCard.Name
					setupHoverEffect(selectServer, selectServer, textLabel, "SelectServer-" .. placeLabel)
					if selectButton and (selectButton:IsA("TextButton") or selectButton:IsA("ImageButton")) then
						setupHoverEffect(selectButton :: GuiObject, selectServer, textLabel, "SelectServerBtn-" .. placeLabel)
					end
				end
			end
		end
	end
end

return HubController
