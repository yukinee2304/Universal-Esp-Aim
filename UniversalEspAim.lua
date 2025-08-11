local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/jensonhirst/Orion/main/source')))()
local players = game:GetService("Players")
local localPlayer = players.LocalPlayer
local runService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local FOV = 10
local SMOOTHNESS = 1

local Window = OrionLib:MakeWindow({Name = "Universal Esp & Aim", HidePremium = false, SaveConfig = true, ConfigFolder = "UniversalEspAim"})

local Tab = Window:MakeTab({
    Name = "Main",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

local espEnabled = false
local aimbotEnabled = false

local function createESP(player)
    if not espEnabled or player == localPlayer or not player.Character or (localPlayer.Team and player.Team == localPlayer.Team) then return end
    local character = player.Character
    local highlight = Instance.new("Highlight")
    highlight.Parent = character
    highlight.Adornee = character
    highlight.FillColor = Color3.new(1, 0, 0)
    highlight.OutlineColor = Color3.new(1, 1, 1)
    highlight.FillTransparency = 0.5
    highlight.OutlineTransparency = 0
end

local function updateESP()
    for _, player in ipairs(players:GetPlayers()) do
        if player ~= localPlayer and player.Character then
            for _, v in pairs(player.Character:GetChildren()) do
                if v:IsA("Highlight") then v:Destroy() end
            end
            createESP(player)
        end
    end
end

players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        createESP(player)
    end)
end)

for _, player in ipairs(players:GetPlayers()) do
    if player ~= localPlayer and player.Character then
        createESP(player)
    end
    player.CharacterAdded:Connect(function()
        createESP(player)
    end)
end

local function getNearestInFOV()
    local nearest = nil
    local minAngle = math.huge
    for _, player in pairs(players:GetPlayers()) do
        if player ~= localPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local root = player.Character.HumanoidRootPart
            local direction = (root.Position - Camera.CFrame.Position).unit
            local angle = math.deg(math.acos(direction:Dot(Camera.CFrame.LookVector)))
            if angle < FOV and angle < minAngle then
                minAngle = angle
                nearest = root
            end
        end
    end
    return nearest
end

local connection
Tab:AddToggle({
    Name = "ESP",
    Default = false,
    Flag = "esp_toggle",
    Save = true,
    Callback = function(Value)
        espEnabled = Value
        updateESP()
    end
})

Tab:AddToggle({
    Name = "Aimbot",
    Default = false,
    Flag = "aimbot_toggle",
    Save = true,
    Callback = function(Value)
        aimbotEnabled = Value
        if aimbotEnabled then
            connection = runService.RenderStepped:Connect(function(deltaTime)
                if aimbotEnabled then
                    local target = getNearestInFOV()
                    if target then
                        local targetCFrame = CFrame.lookAt(Camera.CFrame.Position, target.Position)
                        Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, SMOOTHNESS * deltaTime * 60)
                    end
                end
            end)
        else
            if connection then connection:Disconnect() end
        end
    end
})

OrionLib:Init()