local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local CombatService = Knit.CreateService({
    Name = "CombatService",
    Client = {
        EquipChanged = Knit.CreateSignal(),
        IgniteChanged = Knit.CreateSignal(),
    },
})

-- Player state: [Player] = { equipped: boolean, ignited: boolean }

local playerState = {}

function CombatService:EquipRequest(player: Player, equip: boolean)
    local state = playerState[player] or { equipped = false, ignited = false }
    state.equipped = equip 
    if not equip then
        state.ignited = false 
    end 
    playerState[player] = state

    -- Broadcast to ALL clients (including the requesting player)
    self.Client.EquipChanged:FireAll(player, equip)
end 

function CombatService:IgniteRequest(player: Player, ignite: boolean)
    local state = playerState[player]
    if not state or not state.equipped then return end 

    state.ignited = ignite
    playerState[player] = state 

    self.Client.IgniteChanged:FireAll(player, ignite)
end 

function CombatService:KnitInit()
    -- Wire up server-side handlers for client requests
    self.Server.EquipRequest:Connect(function(player)
        self:EquipRequest(player, true)
    end)
end 

return CombatService
