local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(game.ReplicatedStorage.Packages.Knit)

local CombatConfig = require(ReplicatedStorage.Shared.modules.Combat.Config)

local CombatController = Knit.CreateController({
    Name = "CombatController",
})

function CombatController:KnitStart()
    local CombatService = Knit.GetService("CombatService")
    local _player = game.Players.LocalPlayer

    -- Listen for server broadcasts (everyone sees these)
    CombatService.EquipChanged:Connect(function(targetPlayer, equipped)
        -- Play equip/unequip animation on targetPlayer's character
        -- If targetPlayer == player, play local anim; else play on their model
        self:PlayEquipAnimation(targetPlayer, equipped)
    end)

    CombatService.IgniteChanged:Connect(function(targetPlayer, ignited)
        -- Show/Hide saber blade, play ignite sound, etc.
        self:UpdateSaberVisual(targetPlayer, ignited)
    end) 

    -- Input 
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end 
        if input.Keycode == CombatConfig.Keybinds.EquipSaber then 
            CombatService.Server.EquipRequest:Fire()
        elseif input.KeyCode == CombatConfig.Keybinds.IgniteSaber then 
            CombatService.Server.IgniteRequest:Fire()
        end 
    end)
end 


function CombatController:PlayEquipAnimation(targetPlayer, equipped)
    -- Load and play animation on targetPlayer's Humanoid
    -- Use CombatConfig.Animation.Equip / Unequip 
end 

function CombatController:UpdateSaberVisual(targetPlayer, ignited)
    -- Later on we use blade visibility, particles, sounds, etc 
end 

return CombatController 
