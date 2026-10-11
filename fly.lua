
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local flying = false
local speed = 60
local velocity, gyro
local connection

local function stopFly()
    flying = false
    if connection then
        connection:Disconnect()
        connection = nil
    end
    if velocity then velocity:Destroy() end
    if gyro then gyro:Destroy() end
    velocity, gyro = nil, nil
end

local function startFly()
    local char = player.Character
    if not char then return end

    local root = char:FindFirstChild("HumanoidRootPart")
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not root or not humanoid then return end

    flying = true

    velocity = Instance.new("BodyVelocity")
    velocity.MaxForce = Vector3.new(1e9, 1e9, 1e9)
    velocity.Velocity = Vector3.zero
    velocity.Parent = root

    gyro = Instance.new("BodyGyro")
    gyro.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
    gyro.P = 10000
    gyro.CFrame = root.CFrame
    gyro.Parent = root

    connection = RunService.RenderStepped:Connect(function()
        if not root.Parent then
            stopFly()
            return
        end

        local cam = workspace.CurrentCamera
        local move = Vector3.zero

        if UIS:IsKeyDown(Enum.KeyCode.W) then
            move += cam.CFrame.LookVector
        end
        if UIS:IsKeyDown(Enum.KeyCode.S) then
            move -= cam.CFrame.LookVector
        end
        if UIS:IsKeyDown(Enum.KeyCode.A) then
            move -= cam.CFrame.RightVector
        end
        if UIS:IsKeyDown(Enum.KeyCode.D) then
            move += cam.CFrame.RightVector
        end
        if UIS:IsKeyDown(Enum.KeyCode.Space) then
            move += Vector3.yAxis
        end
        if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then
            move -= Vector3.yAxis
        end

        velocity.Velocity =
            move.Magnitude > 0 and move.Unit * speed
            or Vector3.zero

        gyro.CFrame = cam.CFrame
    end)
end

UIS.InputBegan:Connect(function(input, processed)
    if processed then return end

    if input.KeyCode == Enum.KeyCode.F then
        if flying then stopFly() else startFly() end
    elseif input.KeyCode == Enum.KeyCode.Equals then
        speed += 20
    elseif input.KeyCode == Enum.KeyCode.Minus then
        speed = math.max(20, speed - 20)
    end
end)

player.CharacterAdded:Connect(stopFly)

