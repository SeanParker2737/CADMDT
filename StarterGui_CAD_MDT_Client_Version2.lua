-- Place this LocalScript in StarterGui under the CAD_MDT_UI ScreenGui

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = ReplicatedStorage:WaitForChild("CAD_MDT_Remotes")
local Players = game:GetService("Players")
local player = Players.LocalPlayer

local gui = script.Parent

-- UI references (fill in with your UI names)
local loginFrame = gui:WaitForChild("LoginFrame")
local mainFrame = gui:WaitForChild("MainFrame")
local dispatcherFrame = gui:WaitForChild("DispatcherFrame")
local lookupFrame = gui:WaitForChild("LookupFrame")
local adminFrame = gui:WaitForChild("AdminFrame")

-- Login logic
loginFrame.LoginButton.MouseButton1Click:Connect(function()
    local callsign = loginFrame.CallsignInput.Text
    local rank = loginFrame.RankDropdown.Selected.Value
    if callsign ~= "" and rank ~= "" then
        Remotes.Login:FireServer(callsign, rank)
    end
end)

Remotes.LoginResult.OnClientEvent:Connect(function(success, role)
    if success then
        loginFrame.Visible = false
        if role == "Dispatcher" then
            dispatcherFrame.Visible = true
        elseif role == "Admin" then
            adminFrame.Visible = true
        else
            mainFrame.Visible = true
        end
    else
        loginFrame.ErrorLabel.Text = "Invalid login/callsign!"
    end
end)

-- Status update logic
mainFrame.StatusDropdown.Changed:Connect(function(selected)
    Remotes.UpdateStatus:FireServer(selected)
end)

-- Dispatcher creates call
dispatcherFrame.CreateCallButton.MouseButton1Click:Connect(function()
    local loc = dispatcherFrame.LocationBox.Text
    local desc = dispatcherFrame.DescriptionBox.Text
    local pri = dispatcherFrame.PriorityDropdown.Selected.Value
    Remotes.CreateCall:FireServer(loc, desc, pri)
end)

-- Officer receives call assignment
Remotes.AssignCall.OnClientEvent:Connect(function(callData)
    -- Display callData in officer's call panel
    mainFrame.CallPanel.Visible = true
    mainFrame.CallPanel.Location.Text = callData.location
    mainFrame.CallPanel.Description.Text = callData.description
    mainFrame.CallPanel.Priority.Text = callData.priority
end)

-- Dispatcher assigns call
dispatcherFrame.AssignButton.MouseButton1Click:Connect(function()
    local callID = dispatcherFrame.SelectedCallID.Value
    local targetCallsign = dispatcherFrame.AssignToDropdown.Selected.Value
    Remotes.AssignCall:FireServer(callID, targetCallsign)
end)

-- Lookup (PNC)
lookupFrame.PersonLookupButton.MouseButton1Click:Connect(function()
    local name = lookupFrame.PersonNameBox.Text
    Remotes.Lookup:FireServer("person", name)
end)

lookupFrame.VehicleLookupButton.MouseButton1Click:Connect(function()
    local plate = lookupFrame.VehiclePlateBox.Text
    Remotes.Lookup:FireServer("vehicle", plate)
end)

Remotes.LookupResult.OnClientEvent:Connect(function(result)
    -- Display result in lookupFrame
end)

-- Admin actions
adminFrame.KickButton.MouseButton1Click:Connect(function()
    local user = adminFrame.KickUserBox.Text
    Remotes.AdminActions:FireServer("kick", user)
end)