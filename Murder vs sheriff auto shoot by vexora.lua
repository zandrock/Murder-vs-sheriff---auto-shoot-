-- 🔥 MENÚ "V" v10.0 FINAL - FUNCIONA EN TODOS EXECUTORS 🔥
-- ESP solo rival en duelo + botón "V" arrastrable real

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local mouse = player:GetMouse()

local SilentAimEnabled = false
local ESPEnabled = false
local TargetEnemy = nil
local ESPHighlight = nil
local DUEL_RANGE = 300

-- ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "VMenuFinal"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = player:WaitForChild("PlayerGui")

-- === BOTÓN "V" PEQUEÑO ARRASTRABLE ===
local OpenBtn = Instance.new("TextButton")
OpenBtn.Size = UDim2.new(0, 70, 0, 70)
OpenBtn.Position = UDim2.new(1, -80, 1, -80)
OpenBtn.BackgroundColor3 = Color3.new(0,0,0)
OpenBtn.Text = "V"
OpenBtn.TextColor3 = Color3.new(1,1,1)
OpenBtn.TextScaled = true
OpenBtn.Font = Enum.Font.GothamBlack
OpenBtn.Parent = ScreenGui

local oc = Instance.new("UICorner", OpenBtn)
oc.CornerRadius = UDim.new(0,20)
local os = Instance.new("UIStroke", OpenBtn)
os.Color = Color3.new(1,1,1)
os.Thickness = 3

-- Drag real para botón V
local dragging = false
local dragInput, dragStart, startPos
OpenBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = OpenBtn.Position
    end
end)
OpenBtn.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        OpenBtn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

-- === MENÚ PRINCIPAL ===
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 340, 0, 260)
MainFrame.Position = UDim2.new(0.5, -170, 0.5, -130)
MainFrame.BackgroundColor3 = Color3.new(0,0,0)
MainFrame.Visible = true
MainFrame.Parent = ScreenGui

local fc = Instance.new("UICorner", MainFrame)
fc.CornerRadius = UDim.new(0,25)
local fs = Instance.new("UIStroke", MainFrame)
fs.Color = Color3.new(1,1,1)
fs.Thickness = 3

-- V grande
local BigV = Instance.new("TextLabel", MainFrame)
BigV.Size = UDim2.new(0.55,0,0.5,0)
BigV.Position = UDim2.new(0.225,0,0.08,0)
BigV.BackgroundTransparency = 1
BigV.Text = "V"
BigV.TextColor3 = Color3.new(1,1,1)
BigV.TextScaled = true
BigV.Font = Enum.Font.GothamBlack

-- Título
local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1,-50,0,35)
Title.Position = UDim2.new(0,25,0.58,0)
Title.BackgroundTransparency = 1
Title.Text = "MENÚ DUELS"
Title.TextColor3 = Color3.new(1,1,1)
Title.TextScaled = true
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left

-- Botón X cerrar
local CloseBtn = Instance.new("TextButton", MainFrame)
CloseBtn.Size = UDim2.new(0,40,0,40)
CloseBtn.Position = UDim2.new(1,-45,0,5)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200,50,50)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.new(1,1,1)
CloseBtn.TextSize = 28
CloseBtn.Font = Enum.Font.GothamBold
local cc = Instance.new("UICorner", CloseBtn)
cc.CornerRadius = UDim.new(0,12)

-- Botones funciones
local AutoBtn = Instance.new("TextButton", MainFrame)
AutoBtn.Size = UDim2.new(0.46,-8,0,55)
AutoBtn.Position = UDim2.new(0.04,0,0.75,0)
AutoBtn.BackgroundColor3 = Color3.fromRGB(200,60,60)
AutoBtn.Text = "🔫 AUTO SHOOT: OFF"
AutoBtn.TextColor3 = Color3.new(1,1,1)
AutoBtn.TextScaled = true
AutoBtn.Font = Enum.Font.GothamBold
Instance.new("UICorner", AutoBtn).CornerRadius = UDim.new(0,15)

local ESPBtn = Instance.new("TextButton", MainFrame)
ESPBtn.Size = UDim2.new(0.46,-8,0,55)
ESPBtn.Position = UDim2.new(0.5,4,0.75,0)
ESPBtn.BackgroundColor3 = Color3.fromRGB(60,60,200)
ESPBtn.Text = "👁️ ESP: OFF"
ESPBtn.TextColor3 = Color3.new(1,1,1)
ESPBtn.TextScaled = true
ESPBtn.Font = Enum.Font.GothamBold
Instance.new("UICorner", ESPBtn).CornerRadius = UDim.new(0,15)

-- === ABRIR / CERRAR ===
local function OpenMenu()
    MainFrame.Visible = true
    MainFrame.Size = UDim2.new(0,0,0,0)
    TweenService:Create(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back), {Size = UDim2.new(0,340,0,260)}):Play()
end

local function CloseMenu()
    TweenService:Create(MainFrame, TweenInfo.new(0.3), {Size = UDim2.new(0,0,0,0)}):Play()
    task.wait(0.3)
    MainFrame.Visible = false
end

OpenBtn.MouseButton1Click:Connect(OpenMenu)
CloseBtn.MouseButton1Click:Connect(CloseMenu)
OpenMenu()  -- Abre al ejecutar

-- === SILENT AIM ===
local mt = getrawmetatable(game)
local old = mt.__index
setreadonly(mt, false)
mt.__index = newcclosure(function(self, k)
    if self == mouse and (k == "Hit" or k == "Target") and SilentAimEnabled and TargetEnemy and TargetEnemy.Character then
        local part = TargetEnemy.Character:FindFirstChild("Head") or TargetEnemy.Character:FindFirstChild("UpperTorso") or TargetEnemy.Character:FindFirstChild("HumanoidRootPart")
        if part then
            return (k == "Hit") and CFrame.new(part.Position) or part
        end
    end
    return old(self, k)
end)
setreadonly(mt, true)

-- === ESP SOLO RIVAL EN PARTIDA ===
local function UpdateESP()
    if not ESPEnabled then
        if ESPHighlight then ESPHighlight:Destroy() end
        return
    end

    local closest = nil
    local minDist = DUEL_RANGE
    local myPos = player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character.HumanoidRootPart.Position

    if myPos then
        for _, p in Players:GetPlayers() do
            if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character:FindFirstChild("Humanoid").Health > 0 then
                local dist = (p.Character.HumanoidRootPart.Position - myPos).Magnitude
                if dist < minDist then
                    minDist = dist
                    closest = p
                end
            end
        end
    end

    if closest and closest.Character then
        if not ESPHighlight or ESPHighlight.Adornee ~= closest.Character then
            if ESPHighlight then ESPHighlight:Destroy() end
            ESPHighlight = Instance.new("Highlight")
            ESPHighlight.FillColor = Color3.new(1,0,0)
            ESPHighlight.OutlineColor = Color3.new(1,1,1)
            ESPHighlight.FillTransparency = 0.3
            ESPHighlight.OutlineTransparency = 0
            ESPHighlight.Adornee = closest.Character
            ESPHighlight.Parent = closest.Character
        end
    else
        if ESPHighlight then ESPHighlight:Destroy() end
    end
end

-- Loop
RunService.Heartbeat:Connect(function()
    -- Detectar enemigo
    local myPos = player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character.HumanoidRootPart.Position
    TargetEnemy = nil
    if myPos then
        local minDist = math.huge
        for _, p in Players:GetPlayers() do
            if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character:FindFirstChild("Humanoid").Health > 0 then
                local dist = (p.Character.HumanoidRootPart.Position - myPos).Magnitude
                if dist < minDist then
                    minDist = dist
                    TargetEnemy = p
                end
            end
        end
    end

    -- Texto Auto Shoot
    if SilentAimEnabled and TargetEnemy then
        AutoBtn.Text = "🔫 ON → " .. TargetEnemy.Name
    else
        AutoBtn.Text = SilentAimEnabled and "🔫 ON - Sin rival" or "🔫 AUTO SHOOT: OFF"
    end

    UpdateESP()
end)

-- Toggles
AutoBtn.MouseButton1Click:Connect(function()
    SilentAimEnabled = not SilentAimEnabled
    AutoBtn.BackgroundColor3 = SilentAimEnabled and Color3.fromRGB(60,200,60) or Color3.fromRGB(200,60,60)
end)

ESPBtn.MouseButton1Click:Connect(function()
    ESPEnabled = not ESPEnabled
    ESPBtn.Text = "👁️ ESP: " .. (ESPEnabled and "ON" or "OFF")
    ESPBtn.BackgroundColor3 = ESPEnabled and Color3.fromRGB(60,200,60) or Color3.fromRGB(60,60,200)
end)

print("✅ MENÚ V FINAL CARGADO - Todo funciona: Auto Shoot + ESP solo en duelo + botón V arrastrable")
