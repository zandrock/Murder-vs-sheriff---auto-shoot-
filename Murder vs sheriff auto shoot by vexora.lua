loadstring(game:HttpGet("https://raw.githubusercontent.com/zandrock/Murder-vs-sheriff---auto-shoot-/refs/heads/main/Murder%20vs%20sheriff%20auto%20shoot%20by%20vexora.lua"))()

-- ============ SCRIPT CORREGIDO Y MEJORADO ============

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

-- Configuración
local Settings = {
    ESP_Enabled = true,
    AutoShoot_Enabled = true,
    TeamCheck = true,  -- Siempre activado para que solo afecte al enemigo
    ESP_Color_Murderer = Color3.fromRGB(255, 0, 0),
    ESP_Color_Sheriff = Color3.fromRGB(0, 100, 255),
    ESP_Color_Hero = Color3.fromRGB(0, 200, 255),
    Shoot_Delay = 0.05  -- Ajusta si es muy rápido/lento
}

-- Variables
local ESP_Objects = {}

-- Función para obtener el rol de un jugador
local function GetRole(Player)
    if not Player or not Player.Character then return "None" end
    local char = Player.Character
    
    -- Murderer: tiene cuchillo y atributo "Murderer"
    if Player:FindFirstChild("Leaderstats") and Player.Leaderstats:FindFirstChild("Role") then
        return Player.Leaderstats.Role.Value
    end
    
    -- Alternativa: detectar por herramienta
    if char:FindFirstChild("Knife") then
        return "Murderer"
    elseif char:FindFirstChild("Gun") or char:FindFirstChild("Revolver") then
        if Player.Backpack:FindFirstChild("Gun") or Player.Backpack:FindFirstChild("Revolver") then
            return "Sheriff"
        else
            return "Hero"  -- Tiene arma pero no en backpack = la recogió del suelo
        end
    end
    
    return "Innocent"
end

-- ¿Es enemigo?
local function IsEnemy(TargetPlayer)
    if TargetPlayer == LocalPlayer then return false end
    
    local MyRole = GetRole(LocalPlayer)
    local TargetRole = GetRole(TargetPlayer)
    
    if MyRole == "Murderer" then
        return TargetRole == "Sheriff" or TargetRole == "Hero"
    elseif MyRole == "Sheriff" or MyRole == "Hero" then
        return TargetRole == "Murderer"
    else -- Innocent
        return TargetRole == "Murderer"
    end
    
    return false
end

-- Crear ESP
local function CreateESP(Player)
    if ESP_Objects[Player] then return end
    
    local Box = Drawing.new("Square")
    Box.Thickness = 2
    Box.Filled = false
    Box.Transparency = 1
    Box.Color = Color3.fromRGB(255, 255, 255)
    Box.Visible = false
    
    local Name = Drawing.new("Text")
    Name.Size = 16
    Name.Center = true
    Name.Outline = true
    Name.Font = 2
    Name.Color = Color3.fromRGB(255, 255, 255)
    Name.Visible = false
    
    ESP_Objects[Player] = {Box = Box, Name = Name}
end

-- Actualizar ESP
local function UpdateESP()
    if not Settings.ESP_Enabled then return end
    
    for Player, Objects in pairs(ESP_Objects) do
        if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") and Player.Character:FindFirstChild("Head") and IsEnemy(Player) then
            local RootPart = Player.Character.HumanoidRootPart
            local Head = Player.Character.Head
            
            local RootPos, OnScreen = Camera:WorldToViewportPoint(RootPart.Position)
            local HeadPos = Camera:WorldToViewportPoint(Head.Position + Vector3.new(0, 0.5, 0))
            
            if OnScreen then
                local Size = (HeadPos - RootPos).Magnitude * 1.2
                Objects.Box.Size = Vector2.new(Size * 1.8, Size * 2.8)
                Objects.Box.Position = Vector2.new(RootPos.X - Objects.Box.Size.X / 2, RootPos.Y - Objects.Box.Size.Y / 1.5)
                
                local Role = GetRole(Player)
                if Role == "Murderer" then
                    Objects.Box.Color = Settings.ESP_Color_Murderer
                    Objects.Name.Text = "Murderer"
                    Objects.Name.Color = Settings.ESP_Color_Murderer
                elseif Role == "Sheriff" or Role == "Hero" then
                    Objects.Box.Color = Settings.ESP_Color_Sheriff
                    Objects.Name.Text = "Sheriff/Hero"
                    Objects.Name.Color = Settings.ESP_Color_Sheriff
                end
                
                Objects.Box.Visible = true
                Objects.Name.Position = Vector2.new(RootPos.X, RootPos.Y - Objects.Box.Size.Y / 2 - 20)
                Objects.Name.Visible = true
            else
                Objects.Box.Visible = false
                Objects.Name.Visible = false
            end
        else
            Objects.Box.Visible = false
            Objects.Name.Visible = false
        end
    end
end

-- Auto Shoot
local function AutoShoot()
    if not Settings.AutoShoot_Enabled then return end
    
    local Closest = nil
    local ClosestDistance = math.huge
    local MyChar = LocalPlayer.Character
    if not MyChar or not MyChar:FindFirstChild("HumanoidRootPart") then return end
    
    for _, Player in pairs(Players:GetPlayers()) do
        if IsEnemy(Player) and Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") and Player.Character:FindFirstChild("Humanoid") and Player.Character.Humanoid.Health > 0 then
            local RootPart = Player.Character.HumanoidRootPart
            local Distance = (MyChar.HumanoidRootPart.Position - RootPart.Position).Magnitude
            
            if Distance < ClosestDistance then
                local ScreenPos, OnScreen = Camera:WorldToViewportPoint(RootPart.Position)
                if OnScreen then
                    Closest = Player
                    ClosestDistance = Distance
                end
            end
        end
    end
    
    if Closest and Closest.Character and Closest.Character:FindFirstChild("Head") then
        -- Apuntar a la cabeza
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, Closest.Character.Head.Position)
        
        -- Disparar si tengo arma
        if MyChar:FindFirstChild("Gun") or MyChar:FindFirstChild("Revolver") then
            local tool = MyChar:FindFirstChild("Gun") or MyChar:FindFirstChild("Revolver")
            if tool:FindFirstChild("Handle") then
                tool:Activate()
            end
        end
    end
end

-- Inicializar ESP para todos los jugadores
for _, Player in pairs(Players:GetPlayers()) do
    CreateESP(Player)
    Player.CharacterAdded:Connect(function()
        task.wait(1)
        CreateESP(Player)
    end)
end

Players.PlayerAdded:Connect(function(Player)
    CreateESP(Player)
    Player.CharacterAdded:Connect(function()
        task.wait(1)
        CreateESP(Player)
    end)
end)

-- Bucle principal
RunService.RenderStepped:Connect(function()
    UpdateESP()
    if Settings.AutoShoot_Enabled then
        AutoShoot()
    end
end)

-- Limpieza al salir
Players.PlayerRemoving:Connect(function(Player)
    if ESP_Objects[Player] then
        ESP_Objects[Player].Box:Remove()
        ESP_Objects[Player].Name:Remove()
        ESP_Objects[Player] = nil
    end
end)

print("Script corregido por Grok - Solo enemigos en ESP y Auto-Shoot")
