local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = game:GetService("Workspace").CurrentCamera
local LocalPlayer = Players.LocalPlayer

local aimbotEnabled = false
local espEnabled = false
local tracerEnabled = false
local tracerColor = Color3.fromRGB(255, 0, 132)
local maxLockOnDistance = 200
local maxLockOnAngle = 180
local fireCooldown = 0.1
local lastFireTime = 0
local espBoxes = {}
local tracers = {}

local function createMainUI()
    local playerGui = LocalPlayer:WaitForChild("PlayerGui")

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "AimbotUI"
    screenGui.Parent = playerGui

    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 300, 0, 200)
    mainFrame.Position = UDim2.new(0.5, -250, 0.5, -150)
    mainFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    mainFrame.BorderSizePixel = 1
    mainFrame.Active = true
    mainFrame.Draggable = true
    mainFrame.Parent = screenGui

    local function createButton(name, posY, toggleFunc)
        local button = Instance.new("TextButton")
        button.Name = name
        button.Size = UDim2.new(1, -100, 0, 30)
        button.Position = UDim2.new(0, 10, 0, posY)
        button.BackgroundColor3 = Color3.fromRGB(255, 0, 115)
        button.TextColor3 = Color3.fromRGB(0, 0, 0)
        button.Text = name
        button.Font = Enum.Font.SourceSansBold
        button.TextSize = 24
        button.Parent = mainFrame

        local buttonCorner = Instance.new("UICorner")
        buttonCorner.CornerRadius = UDim.new(0, 3)
        buttonCorner.Parent = button

        button.MouseButton1Click:Connect(function()
            toggleFunc(button)
        end)
    end

    local function createColorButton(colorName, color, posY)
        local button = Instance.new("TextButton")
        button.Name = colorName
        button.Size = UDim2.new(0, 25, 0, 20)
        button.Position = UDim2.new(0.78, xPos, -0.51, posY)
        button.BackgroundColor3 = color
        button.Text = ""
        button.Parent = mainFrame

        local buttonCorner = Instance.new("UICorner")
        buttonCorner.CornerRadius = UDim.new(0, 3)
        buttonCorner.Parent = button

        local function createTracerButton(posY)
            local button = Instance.new("TextButton")
            button.Name = "TracerColoursButton"
            button.Size = UDim2.new(0, 80, 0, 40)
            button.Position = UDim2.new(0.76, -13, 0, posY)
            button.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
            button.Text = "Tracer Colours"
            button.TextColor3 = Color3.fromRGB(255, 255, 255)
            button.Font = Enum.Font.SourceSansBold
            button.TextSize = 12
            button.Parent = mainFrame

            local border = Instance.new("UIStroke")
            border.Color = Color3.fromRGB(255, 0, 132)
            border.Thickness = 2
            border.Parent = button
        end

        local titleBar = Instance.new("TextLabel")
        titleBar.Name = "TitleBar"
        titleBar.Size = UDim2.new(1, 0, 0, 40)
        titleBar.Position = UDim2.new(0, 0, -0.2)
        titleBar.BackgroundColor3 = Color3.fromRGB(252, 3, 127)
        titleBar.BorderSizePixel = 0
        titleBar.Text = "DioHubs Aimbot"
        titleBar.Font = Enum.Font.SourceSansBold
        titleBar.TextColor3 = Color3.fromRGB(0, 0, 0)
        titleBar.TextSize = 20
        titleBar.Parent = mainFrame

        local titleBarCorner = Instance.new("UICorner")
        titleBarCorner.CornerRadius = UDim.new(0, 3)
        titleBarCorner.Parent = titleBar

        createTracerButton(10)

        button.MouseButton1Click:Connect(function()
            tracerColor = color
        end)
    end

    local function toggleAimbot(button)
        aimbotEnabled = not aimbotEnabled
        button.TextColor3 = aimbotEnabled and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(0, 0, 0)
    end

    local function toggleESP(button)
        espEnabled = not espEnabled
        button.TextColor3 = espEnabled and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(0, 0, 0)

        if not espEnabled then
            for _, box in pairs(espBoxes) do
                if box then
                    box:Destroy()
                end
            end
            espBoxes = {}
        end
    end

    local function toggleTracer(button)
        tracerEnabled = not tracerEnabled
        button.TextColor3 = tracerEnabled and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(0, 0, 0)

        if not tracerEnabled then
            for _, tracer in pairs(tracers) do
                if tracer then
                    tracer:Remove()
                end
            end
            tracers = {}
        end
    end

    createButton("Aimbot", 20, toggleAimbot)
    createButton("ESP", 60, toggleESP)
    createButton("Tracer", 100, toggleTracer)

    createColorButton("Pink", Color3.fromRGB(255, 0, 132), 155, 450)
    createColorButton("Red", Color3.fromRGB(255, 0, 0), 175, 450)
    createColorButton("Blue", Color3.fromRGB(0, 0, 255), 195, 450)
    createColorButton("Green", Color3.fromRGB(0, 255, 0), 215, 550)
    createColorButton("Yellow", Color3.fromRGB(255, 255, 0), 235, 550)
    createColorButton("Purple", Color3.fromRGB(128, 0, 128), 255, 550)
end

local function createESP(player)
    if not espEnabled or not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
        return
    end

    local humanoidRootPart = player.Character.HumanoidRootPart
    local espBox = Instance.new("BoxHandleAdornment")
    espBox.Size = Vector3.new(5, 5, 5)
    espBox.Adornee = humanoidRootPart
    espBox.AlwaysOnTop = true
    espBox.ZIndex = 10
    espBox.Color3 = Color3.fromRGB(255, 0, 132)
    espBox.Transparency = 0.5
    espBox.Parent = humanoidRootPart

    espBoxes[player] = espBox
end

local function removeESP(player)
    if espBoxes[player] then
        espBoxes[player]:Destroy()
        espBoxes[player] = nil
    end
end

local function createTracer(player)
    if not tracerEnabled or not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
        return
    end

    local tracer = Drawing.new("Line")
    tracer.Color = tracerColor
    tracer.Thickness = 2
    tracer.Transparency = 1
    tracer.Visible = true

    tracers[player] = tracer
end

local function updateTracer(player)
    if tracers[player] and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        local screenPoint = Camera:WorldToViewportPoint(player.Character.HumanoidRootPart.Position)
        local from = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
        local to = Vector2.new(screenPoint.X, screenPoint.Y)

        tracers[player].From = from
        tracers[player].To = to
    end
end

local function removeTracer(player)
    if tracers[player] then
        tracers[player]:Remove()
        tracers[player] = nil
    end
end

local function getClosestPlayerToCrosshair()
    local closestPlayer = nil
    local shortestDistance = math.huge

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Team ~= LocalPlayer.Team and player.Character and player.Character:FindFirstChild("Head") then
            local head = player.Character.Head
            local screenPoint = Camera:WorldToViewportPoint(head.Position)
            local distanceToCrosshair = (Vector2.new(screenPoint.X, screenPoint.Y) - Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)).Magnitude
            local distanceToPlayer = (LocalPlayer.Character.Head.Position - head.Position).Magnitude

            local directionToPlayer = (head.Position - Camera.CFrame.Position).Unit
            local cameraDirection = Camera.CFrame.LookVector
            local angle = math.deg(math.acos(cameraDirection:Dot(directionToPlayer)))

            local ray = Ray.new(Camera.CFrame.Position, directionToPlayer * distanceToPlayer)
            local hit, _ = workspace:FindPartOnRayWithIgnoreList(ray, {LocalPlayer.Character, player.Character})

            if distanceToCrosshair < shortestDistance and distanceToCrosshair < 500 and distanceToPlayer <= maxLockOnDistance and angle <= maxLockOnAngle and not hit then
                shortestDistance = distanceToCrosshair
                closestPlayer = player
            end
        end
    end

    return closestPlayer
end

local function lockOnTargetAndShoot()
    local newTargetPlayer = getClosestPlayerToCrosshair()
    if newTargetPlayer and newTargetPlayer.Character and newTargetPlayer.Character:FindFirstChild("Head") then
        local head = newTargetPlayer.Character.Head
        local targetPosition = head.Position
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetPosition)

        if tick() - lastFireTime > fireCooldown then
            lastFireTime = tick()
        end
    end
end

createMainUI()

RunService.RenderStepped:Connect(function()
    if aimbotEnabled then
        lockOnTargetAndShoot()
    end

    if espEnabled then
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Team ~= LocalPlayer.Team then
                if not espBoxes[player] then
                    createESP(player)
                end
            else
                removeESP(player)
            end
        end
    end

    if tracerEnabled then
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Team ~= LocalPlayer.Team then
                if not tracers[player] then
                    createTracer(player)
                end
                updateTracer(player)
            else
                removeTracer(player)
            end
        end
    end
end)
