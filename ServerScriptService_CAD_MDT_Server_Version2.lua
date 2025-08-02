local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = ReplicatedStorage:WaitForChild("CAD_MDT_Remotes")
local Data = require(ReplicatedStorage:WaitForChild("CAD_MDT_Data"))
local HttpService = game:GetService("HttpService")

local officers = {}
local calls = {}
local callCounter = 0

local DISCORD_WEBHOOK = "YOUR_DISCORD_WEBHOOK_URL"

-- Login handler
Remotes.Login.OnServerEvent:Connect(function(player, callsign, rank)
    if Data.ValidCallsign(callsign) and Data.ValidRank(rank) then
        officers[player.UserId] = {callsign = callsign, rank = rank, status = "Available", role = Data.GetRole(rank)}
        Remotes.LoginResult:FireClient(player, true, officers[player.UserId].role)
    else
        Remotes.LoginResult:FireClient(player, false)
    end
end)

Remotes.UpdateStatus.OnServerEvent:Connect(function(player, newStatus)
    if officers[player.UserId] then
        officers[player.UserId].status = newStatus
        -- Optionally: Broadcast status update to all clients
    end
end)

Remotes.CreateCall.OnServerEvent:Connect(function(player, location, description, priority)
    callCounter += 1
    local callID = "CALL-" .. tostring(callCounter)
    local call = {
        id = callID,
        location = location,
        description = description,
        priority = priority,
        status = "Open",
        assigned = nil,
        creator = player.Name,
        timestamp = os.time()
    }
    table.insert(calls, call)
    -- Broadcast new call to all dispatcher clients
    Remotes.NewCall:FireAllClients(call)
    -- Send to Discord
    local data = {
        username = "UK CAD/MDT",
        embeds = {{
            title = "New Call Created",
            description = string.format("ID: %s\nLocation: %s\nDescription: %s\nPriority: %s", callID, location, description, priority),
            color = 3447003
        }}
    }
    HttpService:PostAsync(DISCORD_WEBHOOK, HttpService:JSONEncode(data))
end)

Remotes.AssignCall.OnServerEvent:Connect(function(player, callID, callsign)
    for _,call in ipairs(calls) do
        if call.id == callID then
            call.assigned = callsign
            call.status = "Assigned"
            -- Notify officer
            for uid, data in pairs(officers) do
                if data.callsign == callsign then
                    Remotes.AssignCall:FireClient(game.Players:GetPlayerByUserId(uid), call)
                end
            end
            -- Discord log
            local data = {
                username = "UK CAD/MDT",
                embeds = {{
                    title = "Call Assigned",
                    description = string.format("ID: %s assigned to %s", callID, callsign),
                    color = 3066993
                }}
            }
            HttpService:PostAsync(DISCORD_WEBHOOK, HttpService:JSONEncode(data))
            break
        end
    end
end)

Remotes.Lookup.OnServerEvent:Connect(function(player, type, query)
    local result = {}
    if type == "person" then
        result = Data.PersonLookup(query)
    elseif type == "vehicle" then
        result = Data.VehicleLookup(query)
    end
    Remotes.LookupResult:FireClient(player, result)
end)

Remotes.AdminActions.OnServerEvent:Connect(function(player, action, target)
    if Data.IsAdmin(player) then
        if action == "kick" then
            for _,plr in pairs(game.Players:GetPlayers()) do
                if plr.Name == target then
                    plr:Kick("Kicked by CAD/MDT Admin")
                end
            end
        end
    end
end)

game.Players.PlayerRemoving:Connect(function(player)
    officers[player.UserId] = nil
end)