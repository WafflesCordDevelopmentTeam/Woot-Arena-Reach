-- Woot Reach Script by fault | discord: nnatsukawa

-- Services
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

-- Variables
local player = Players.LocalPlayer
local mouse = player:GetMouse()
local reachDistance = 10
local reachShape = "Sphere"
local reachColor = Color3.fromRGB(255, 0, 0) -- Default red
local swordEquipped = false
local reachBox = nil
local infiniteReach = false
local useGUI = false -- Default to commands

-- GUI Setup
local screenGui = Instance.new("ScreenGui")
screenGui.Parent = player.PlayerGui
screenGui.Name = "WootReachGUI"

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0.2, 0, 0.3, 0)
mainFrame.Position = UDim2.new(0.02, 0, 0.5, -mainFrame.Size.Y.Offset / 2)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainFrame.BackgroundTransparency = 0.7 -- More transparent
mainFrame.BorderSizePixel = 0
mainFrame.Visible = false -- Hidden by default
mainFrame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0.1, 0)
corner.Parent = mainFrame

-- Animated Border
local borderFrame = Instance.new("Frame")
borderFrame.Size = UDim2.new(1, 0, 0.01, 0)
borderFrame.Position = UDim2.new(0, 0, 0, 0)
borderFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
borderFrame.BorderSizePixel = 0
borderFrame.Parent = mainFrame

local borderTween = TweenService:Create(
    borderFrame,
    TweenInfo.new(2, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1),
    { Position = UDim2.new(0, 0, 1, 0) }
)
borderTween:Play()

local titleLabel = Instance.new("TextLabel")
titleLabel.Text = "Woot Reach"
titleLabel.Size = UDim2.new(1, 0, 0.15, 0)
titleLabel.Position = UDim2.new(0, 0, 0, 0)
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 14
titleLabel.BackgroundTransparency = 1
titleLabel.Parent = mainFrame

local distanceInput = Instance.new("TextBox")
distanceInput.PlaceholderText = "Reach Distance (e.g., 50 or inf)"
distanceInput.Size = UDim2.new(0.9, 0, 0.15, 0)
distanceInput.Position = UDim2.new(0.05, 0, 0.2, 0)
distanceInput.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
distanceInput.BackgroundTransparency = 0.5
distanceInput.TextColor3 = Color3.fromRGB(255, 255, 255)
distanceInput.Font = Enum.Font.Gotham
distanceInput.TextSize = 12
distanceInput.Parent = mainFrame

local shapeInput = Instance.new("TextBox")
shapeInput.PlaceholderText = "Shape (Sphere/Line)"
shapeInput.Size = UDim2.new(0.9, 0, 0.15, 0)
shapeInput.Position = UDim2.new(0.05, 0, 0.4, 0)
shapeInput.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
shapeInput.BackgroundTransparency = 0.5
shapeInput.TextColor3 = Color3.fromRGB(255, 255, 255)
shapeInput.Font = Enum.Font.Gotham
shapeInput.TextSize = 12
shapeInput.Parent = mainFrame

local colorInput = Instance.new("TextBox")
colorInput.PlaceholderText = "Color (Hex or Name)"
colorInput.Size = UDim2.new(0.9, 0, 0.15, 0)
colorInput.Position = UDim2.new(0.05, 0, 0.6, 0)
colorInput.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
colorInput.BackgroundTransparency = 0.5
colorInput.TextColor3 = Color3.fromRGB(255, 255, 255)
colorInput.Font = Enum.Font.Gotham
colorInput.TextSize = 12
colorInput.Parent = mainFrame

local creditsLabel = Instance.new("TextLabel")
creditsLabel.Text = "Made by fault | discord: nnatsukawa"
creditsLabel.Size = UDim2.new(1, 0, 0.1, 0)
creditsLabel.Position = UDim2.new(0, 0, 0.9, 0)
creditsLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
creditsLabel.Font = Enum.Font.Gotham
creditsLabel.TextSize = 12
creditsLabel.BackgroundTransparency = 1
creditsLabel.Parent = mainFrame

-- Startup Message
local function sendStartupMessage()
    player.Chatted:Wait() -- Wait for the player to be able to chat
    game:GetService("TextChatService").TextChannels.RBXGeneral:SendAsync(
        "What Option Do U Wanna Use Player For Woot's Reach GUI, Please Type !gui For the GUI Or !universal To Use Commands Like !reach to configure the distance by adding a number infront of it Like this for example! !reach '56' Like that! And Also Thanks For Using Woot's Reach GUI Made By Natsukawa/Wood!"
    )
end

sendStartupMessage()

-- Command Handling
local function onChatted(message)
    if message:sub(1, 5) == "!gui" then
        useGUI = true
        mainFrame.Visible = true
        print("GUI enabled. Use the GUI to configure reach.")
    elseif message:sub(1, 10) == "!universal" then
        useGUI = false
        mainFrame.Visible = false
        print("Commands enabled. Use !reach <distance> to configure reach.")
    elseif not useGUI and message:sub(1, 6) == "!reach" then
        local distance = message:sub(7):gsub("%s+", "") -- Remove spaces
        if distance:lower() == "inf" then
            infiniteReach = true
            reachDistance = math.huge
            print("Reach set to infinite")
        else
            distance = tonumber(distance)
            if distance then
                infiniteReach = false
                reachDistance = distance
                print("Reach distance set to " .. reachDistance)
            else
                print("Invalid distance. Use a number or 'inf'.")
            end
        end
    end
end

player.Chatted:Connect(onChatted)

-- Sword Equip/Unequip Handling
local function onEquipped()
    swordEquipped = true
    createReachBox()
end

local function onUnequipped()
    swordEquipped = false
    if reachBox then
        reachBox:Destroy()
        reachBox = nil
    end
end

local function createReachBox()
    if reachBox then
        reachBox:Destroy()
    end

    reachBox = Instance.new("Part")
    reachBox.Size = Vector3.new(reachDistance, reachDistance, reachDistance)
    reachBox.Shape = reachShape == "Sphere" and Enum.PartType.Ball or Enum.PartType.Block
    reachBox.Transparency = 1
    reachBox.CanCollide = false
    reachBox.Anchored = true
    reachBox.Parent = workspace

    local boxColor = Instance.new("BoxHandleAdornment")
    boxColor.Size = reachBox.Size
    boxColor.Transparency = 0.5
    boxColor.Color3 = reachColor
    boxColor.Adornee = reachBox
    boxColor.AlwaysOnTop = true
    boxColor.ZIndex = 10
    boxColor.Parent = reachBox
end

-- Hit Detection
local function onSwordHit(hit)
    if swordEquipped and reachBox and hit.Parent ~= player.Character then
        local humanoid = hit.Parent:FindFirstChild("Humanoid")
        if humanoid then
            humanoid:TakeDamage(10) -- Adjust damage as needed
            print("Hit " .. hit.Parent.Name .. " with reach!")
        end
    end
end

-- Connect hit detection to the sword
local function connectSwordHit(sword)
    local touchConnection
    touchConnection = sword.Touched:Connect(onSwordHit)
    sword.Unequipped:Connect(function()
        touchConnection:Disconnect()
    end)
end

-- GUI Input Handling
distanceInput.FocusLost:Connect(function()
    if useGUI then
        local distance = distanceInput.Text:gsub("%s+", "")
        if distance:lower() == "inf" then
            infiniteReach = true
            reachDistance = math.huge
            print("Reach set to infinite")
        else
            distance = tonumber(distance)
            if distance then
                infiniteReach = false
                reachDistance = distance
                print("Reach distance set to " .. reachDistance)
            else
                distanceInput.Text = "Invalid Distance"
                task.wait(1)
                distanceInput.Text = ""
            end
        end
    end
end)

shapeInput.FocusLost:Connect(function()
    if useGUI then
        local shape = shapeInput.Text
        if shape == "Sphere" or shape == "Line" then
            reachShape = shape
            if reachBox then
                reachBox.Shape = reachShape == "Sphere" and Enum.PartType.Ball or Enum.PartType.Block
            end
        else
            shapeInput.Text = "Invalid Shape"
            task.wait(1)
            shapeInput.Text = ""
        end
    end
end)

colorInput.FocusLost:Connect(function()
    if useGUI then
        local color = colorInput.Text
        if color:sub(1, 1) == "#" then
            local success, result = pcall(function()
                return Color3.fromHex(color)
            end)
            if success then
                reachColor = result
            else
                colorInput.Text = "Invalid Hex"
                task.wait(1)
                colorInput.Text = ""
            end
        else
            local success, result = pcall(function()
                return Color3.new(color)
            end)
            if success then
                reachColor = result
            else
                colorInput.Text = "Invalid Color"
                task.wait(1)
                colorInput.Text = ""
            end
        end
        if reachBox then
            reachBox.BoxHandleAdornment.Color3 = reachColor
        end
    end
end)

-- Main Loop
RunService.RenderStepped:Connect(function()
    if swordEquipped and reachBox then
        if infiniteReach then
            reachBox.Size = Vector3.new(10000, 10000, 10000) -- Simulate infinite reach
        else
            reachBox.Size = Vector3.new(reachDistance, reachDistance, reachDistance)
        end
        reachBox.Position = mouse.Hit.p
    end
end)

-- Initialization
player.CharacterAdded:Connect(function()
    local sword = player.Character:WaitForChild("Sword")
    sword.Equipped:Connect(onEquipped)
    sword.Unequipped:Connect(onUnequipped)
    connectSwordHit(sword)
end)