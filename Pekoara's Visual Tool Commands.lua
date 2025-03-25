-- Load notification library
local Notification = loadstring(game:HttpGet("https://api.irisapp.ca/Scripts/IrisBetterNotifications.lua"))()

-- Storage for tool states and script tracking
local currentToolSizes = {}
local currentGripPositions = {}
local activeScripts = {}
local commandCooldown = false
local lastCommandTime = 0
local COOLDOWN_DURATION = 2 -- seconds

-- Initial warning messages
sendChatMessage("Evon is a virus dont trust that newgen Sakpot lol use other executors pls!!!! 😭🙏")
sendChatMessage("Made By Pekoara")

-- Clean up any duplicate scripts
for _, v in pairs(getgc(true)) do
    if type(v) == "table" and rawget(v, "activeScripts") then
        for id, _ in pairs(v.activeScripts) do
            v.activeScripts[id] = nil
        end
    end
end

-- Generate unique script ID
local scriptId = tostring(math.random(1, 1000000))
activeScripts[scriptId] = true

-- Chat message function
local function sendChatMessage(message)
    if game:GetService("ReplicatedStorage"):FindFirstChild("DefaultChatSystemChatEvents") then
        game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer(message, "All")
    end
end

-- Cooldown check function
local function checkCooldown()
    if commandCooldown then
        local timeLeft = COOLDOWN_DURATION - (os.clock() - lastCommandTime)
        if timeLeft > 0 then
            sendChatMessage("[Pekoara's Cooldown]: Seems like you're trying to execute multiple commands at the same time! Please wait "..math.floor(timeLeft).." seconds.")
            Notification.Notify("Cooldown Active", "Please wait "..math.floor(timeLeft).." seconds", "rbxassetid://4483345998", {
                Duration = 3,
                Main = { Rounding = true }
            })
            return true
        else
            commandCooldown = false
        end
    end
    return false
end

-- [Rest of your existing functions remain exactly the same...]
-- showCredits(), showTime(), safeExecute(), cleanupTools(), processCommand()

-- Listen for commands in chat
game:GetService("Players").LocalPlayer.Chatted:Connect(function(msg)
    msg = msg:lower()
    
    if string.sub(msg, 1, 1) == ";" then
        local command = string.sub(msg, 2)
        local args = {}
        for word in string.gmatch(command, "%S+") do
            table.insert(args, word)
        end
        
        if #args > 0 then
            local cmd = args[1]
            table.remove(args, 1)
            processCommand(cmd, args, game:GetService("Players").LocalPlayer)
        end
    end
end)

-- Cleanup on script termination
game:GetService("Players").LocalPlayer.CharacterAdded:Connect(function(character)
    cleanupTools(character)
end)

-- Initial notification
Notification.Notify("Pekoara's Visual Tool", "Type ;cmds for command list", "rbxassetid://4483345998", {
    Duration = 5,
    Main = { Rounding = true }
})
sendChatMessage("Pekoara's Visual Tool loaded! Type ;cmds for commands")

-- Show simple script loaded message
print([[
=== Pekoara's Visual Tool ===
Tool visualizer loaded successfully!
Type ;cmds in chat to see available commands
]])

-- Script cleanup on re-execution
spawn(function()
    while true do
        if not activeScripts[scriptId] then
            cleanupTools(game:GetService("Players").LocalPlayer.Character)
            break
        end
        wait(5)
    end
end)