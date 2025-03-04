-- MeozLib.lua - Thư viện Lua cho Roblox với tính năng tùy biến cao
local MeozLib = {}
MeozLib.Version = "1.0.0"

-- Dịch vụ Roblox
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local workspace = game.Workspace
local camera = workspace.CurrentCamera
local player = Players.LocalPlayer

-- Biến toàn cục
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

-- Tải UI (Rayfield hoặc Kavo, tùy executor hỗ trợ)
local UI = nil
local function loadUI()
    if not UI then
        local success, rayfield = pcall(function() return loadstring(game:HttpGet('https://sirius.menu/rayfield'))() end)
        if success then
            UI = rayfield
        else
            local success, kavo = pcall(function() return loadstring(game:HttpGet('https://raw.githubusercontent.com/RegularVynixu/UI-Libs/main/KavoUI.lua'))() end)
            if success then
                UI = kavo
            else
                warn("[MeozLib] No UI library loaded (Rayfield or Kavo not supported)")
                UI = {CreateWindow = function() return {CreateTab = function() return {} end} end}
            end
        end
    end
    return UI
end

-- Khởi tạo Window UI
local Window = loadUI():CreateWindow({
    Name = "MeozLib",
    LoadingTitle = "MeozLib Loading",
    LoadingSubtitle = "by Grok 3",
    ConfigurationSaving = {Enabled = true, FolderName = "MeozLib", FileName = "MeozConfig"}
})

-- Tạo các tab
local MainTab = Window:CreateTab("Main", 4483362458)
local AttackTab = Window:CreateTab("Attack", 4483362458)
local MiscTab = Window:CreateTab("Misc", 4483362458)

-- Hàm thông báo
local function notify(title, content, duration)
    if UI.Notify then
        UI:Notify({
            Title = title,
            Content = content,
            Duration = duration or 6.5,
            Image = 4483362458
        })
    else
        warn("[MeozLib] Notification: " .. title .. " - " .. content)
    end
end

-- Hàm gửi Webhook (tùy chọn)
local function sendWebhook(message, url)
    url = url or "https://discord.com/api/webhooks/your_webhook_id/your_webhook_token" -- Thay bằng URL thật
    local data = {
        ["content"] = message,
        ["username"] = "MeozLib Bot",
        ["avatar_url"] = "https://www.roblox.com/asset-thumbnail/image?assetId=11575879600"
    }
    local success, err = pcall(function()
        game:HttpPost(url, HttpService:JSONEncode(data), "application/json")
    end)
    if not success then warn("[MeozLib] Webhook failed: " .. err) end
end

-- Tính năng ESP (Tùy biến cao)
MeozLib.ESP = {}
function MeozLib.ESP:Create(options)
    options = options or {}
    local espEnabled = false
    local espColor = options.Color or Color3.fromRGB(255, 0, 0)
    local espSize = options.Size or 14
    local espRange = options.Range or 200
    local espText = options.TextFormat or "{name} | HP: {hp} | Distance: {distance} studs"
    local espDrawings = {}

    local Drawing = Drawing or {}
    if not Drawing.new then Drawing.new = function() return {} end end

    local function createESPDrawing(target, text)
        local esp = Drawing.new("Text")
        esp.Text = text
        esp.Color = espColor
        esp.Size = espSize
        esp.Outline = true
        esp.Center = true
        esp.Visible = false
        return esp
    end

    local function updateESP()
        if not espEnabled or not character or not humanoidRootPart or not camera then return end
        local success, err = pcall(function()
            for _, plr in pairs(Players:GetPlayers()) do
                if plr ~= player and plr.Character then
                    local root = plr.Character:FindFirstChild("HumanoidRootPart")
                    local humanoid = plr.Character:FindFirstChildOfClass("Humanoid")
                    if root and humanoid and humanoid.Health > 0 then
                        local distance = (root.Position - humanoidRootPart.Position).Magnitude
                        if distance <= espRange then
                            local screenPos = camera:WorldToScreenPoint(root.Position)
                            if screenPos.Z > 0 then
                                local text = espText
                                    :gsub("{name}", plr.Name)
                                    :gsub("{hp}", math.floor(humanoid.Health))
                                    :gsub("{distance}", math.floor(distance))
                                local esp = espDrawings[plr]
                                if not esp then
                                    esp = createESPDrawing(root, text)
                                    espDrawings[plr] = esp
                                end
                                esp.Text = text
                                esp.Position = Vector2.new(screenPos.X, screenPos.Y - 20)
                                esp.Visible = true
                            else
                                if espDrawings[plr] then
                                    espDrawings[plr].Visible = false
                                end
                            end
                        else
                            if espDrawings[plr] then
                                espDrawings[plr].Visible = false
                            end
                        end
                    else
                        if espDrawings[plr] then
                            espDrawings[plr].Visible = false
                        end
                    end
                end
            end
            for plr, esp in pairs(espDrawings) do
                if not Players:FindFirstChild(plr.Name) or not plr.Character or not plr.Character:FindFirstChild("HumanoidRootPart") then
                    esp.Visible = false
                    esp:Remove()
                    espDrawings[plr] = nil
                end
            end
        end)
        if not success then warn("[MeozLib ESP] Error: " .. err) end
    end

    -- UI cho ESP
    local espToggle = MainTab:CreateToggle({
        Name = "Enable ESP",
        CurrentValue = false,
        Flag = "ESPToggle",
        Callback = function(value)
            espEnabled = value
            if espEnabled then
                task.spawn(function()
                    while espEnabled do
                        updateESP()
                        task.wait(0.2) -- Tốc độ cập nhật nhanh
                    end
                end)
                notify("ESP Enabled", "ESP activated successfully!", 6.5)
            else
                for _, esp in pairs(espDrawings) do esp:Remove() end
                espDrawings = {}
                notify("ESP Disabled", "ESP turned off!", 6.5)
            end
        end
    })

    MainTab:CreateColorPicker({
        Name = "ESP Color",
        Color = espColor,
        Flag = "ESPColor",
        Callback = function(value)
            espColor = value
            for _, esp in pairs(espDrawings) do esp.Color = espColor end
        end
    })

    MainTab:CreateSlider({
        Name = "ESP Range",
        Range = {50, 500},
        Increment = 50,
        Suffix = "Studs",
        CurrentValue = espRange,
        Flag = "ESPRange",
        Callback = function(value)
            espRange = value
            notify("ESP Range Updated", "Range set to " .. value .. " studs", 5)
        end
    })

    MainTab:CreateSlider({
        Name = "ESP Text Size",
        Range = {10, 20},
        Increment = 1,
        Suffix = "px",
        CurrentValue = espSize,
        Flag = "ESPSize",
        Callback = function(value)
            espSize = value
            for _, esp in pairs(espDrawings) do esp.Size = espSize end
            notify("ESP Size Updated", "Text size set to " .. value .. "px", 5)
        end
    })

    MainTab:CreateTextbox({
        Name = "ESP Text Format",
        Value = espText,
        Flag = "ESPText",
        Callback = function(value)
            espText = value
            notify("ESP Format Updated", "Text format set to: " .. value, 5)
        end
    })

    return {
        Enable = function() espToggle:Set(true) end,
        Disable = function() espToggle:Set(false) end,
        SetColor = function(color) MainTab:GetElement("ESPColor"):Set(color) end,
        SetRange = function(range) MainTab:GetElement("ESPRange"):Set(range) end,
        SetSize = function(size) MainTab:GetElement("ESPSize"):Set(size) end,
        SetTextFormat = function(format) MainTab:GetElement("ESPText"):Set(format) end
    }
end

-- Tính năng Aimbot (Tùy biến cao)
MeozLib.Aimbot = {}
function MeozLib.Aimbot:Create(options)
    options = options or {}
    local aimbotEnabled, aimheadEnabled = false, false
    local aimSpeed = options.Speed or 0.1
    local aimRange = options.Range or 100
    local aimTarget = options.Target or "Head"

    local function findNearestEnemy()
        if not character or not humanoidRootPart then return nil end
        local nearestEnemy, shortestDistance = nil, math.huge
        for _, plr in pairs(Players:GetPlayers()) do
            if plr ~= player and (not plr.Team or plr.Team ~= player.Team) and plr.Character then
                local root = plr.Character:FindFirstChild("HumanoidRootPart")
                local humanoid = plr.Character:FindFirstChildOfClass("Humanoid")
                if root and humanoid and humanoid.Health > 0 then
                    local distance = (root.Position - humanoidRootPart.Position).Magnitude
                    if distance < shortestDistance and distance <= aimRange then
                        shortestDistance = distance
                        nearestEnemy = plr
                    end
                end
            end
        end
        return nearestEnemy
    end

    local function aimbotLoop()
        while aimbotEnabled do
            if not camera or not humanoidRootPart then
                task.wait(1)
                continue
            end
            local target = findNearestEnemy()
            if target and target.Character then
                local targetPart = target.Character:FindFirstChild(aimTarget == "Head" and "Head" or "HumanoidRootPart")
                if targetPart then
                    camera.CFrame = CFrame.new(camera.CFrame.Position, targetPart.Position)
                end
            end
            task.wait(aimSpeed)
        end
    end

    local function aimheadLoop()
        while aimheadEnabled do
            if not camera or not humanoidRootPart then
                task.wait(1)
                continue
            end
            local target = findNearestEnemy()
            if target and target.Character then
                local targetHead = target.Character:FindFirstChild("Head")
                if targetHead then
                    local direction = (targetHead.Position - camera.CFrame.Position).Unit
                    local newLook = camera.CFrame.LookVector:Lerp(direction, 0.1)
                    camera.CFrame = CFrame.new(camera.CFrame.Position, camera.CFrame.Position + newLook)
                end
            end
            task.wait(aimSpeed)
        end
    end

    -- UI cho Aimbot
    local aimbotToggle = AttackTab:CreateToggle({
        Name = "Enable Aimbot",
        CurrentValue = false,
        Flag = "AimbotToggle",
        Callback = function(value)
            aimbotEnabled = value
            if aimbotEnabled then
                task.spawn(aimbotLoop)
                notify("Aimbot Enabled", "Aimbot activated!", 6.5)
            else
                notify("Aimbot Disabled", "Aimbot turned off!", 6.5)
            end
        end
    })

    local aimheadToggle = AttackTab:CreateToggle({
        Name = "Enable Aimhead",
        CurrentValue = false,
        Flag = "AimheadToggle",
        Callback = function(value)
            aimheadEnabled = value
            if aimheadEnabled then
                task.spawn(aimheadLoop)
                notify("Aimhead Enabled", "Aimhead activated!", 6.5)
            else
                notify("Aimhead Disabled", "Aimhead turned off!", 6.5)
            end
        end
    })

    AttackTab:CreateSlider({
        Name = "Aimbot Range",
        Range = {50, 500},
        Increment = 50,
        Suffix = "Studs",
        CurrentValue = aimRange,
        Flag = "AimbotRange",
        Callback = function(value)
            aimRange = value
            notify("Aimbot Range Updated", "Range set to " .. value .. " studs", 5)
        end
    })

    AttackTab:CreateSlider({
        Name = "Aimbot Speed",
        Range = {0.01, 1},
        Increment = 0.01,
        Suffix = "s",
        CurrentValue = aimSpeed,
        Flag = "AimbotSpeed",
        Callback = function(value)
            aimSpeed = value
            notify("Aimbot Speed Updated", "Speed set to " .. value .. " seconds", 5)
        end
    })

    AttackTab:CreateDropdown({
        Name = "Aimbot Target",
        Options = {"Head", "HumanoidRootPart"},
        CurrentOption = aimTarget,
        Flag = "AimbotTarget",
        Callback = function(value)
            aimTarget = value
            notify("Aimbot Target Updated", "Targeting " .. value, 5)
        end
    })

    return {
        EnableAimbot = function() aimbotToggle:Set(true) end,
        EnableAimhead = function() aimheadToggle:Set(true) end,
        DisableAimbot = function() aimbotToggle:Set(false) end,
        DisableAimhead = function() aimheadToggle:Set(false) end,
        SetRange = function(range) AttackTab:GetElement("AimbotRange"):Set(range) end,
        SetSpeed = function(speed) AttackTab:GetElement("AimbotSpeed"):Set(speed) end,
        SetTarget = function(target) AttackTab:GetElement("AimbotTarget"):Set(target) end
    }
end

-- Tính năng Misc (Tùy biến Fly, Noclip, Walkspeed, Jump Power)
MeozLib.Misc = {}
function MeozLib.Misc:Create()
    local flyEnabled, noclipEnabled = false, false
    local flySpeed = 50
    local walkSpeed, jumpPower = 16, 50

    local function enableFly()
        local bv = Instance.new("BodyVelocity")
        bv.Velocity = Vector3.new(0, 0, 0)
        bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        bv.Parent = humanoidRootPart

        local bg = Instance.new("BodyGyro")
        bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
        bg.P = 10000
        bg.Parent = humanoidRootPart

        humanoid.PlatformStand = true

        local noclipConnection = RunService.Stepped:Connect(function()
            if flyEnabled then
                for _, part in pairs(character:GetChildren()) do
                    if part:IsA("BasePart") then part.CanCollide = false end
                end
            end
        end)

        local function updateFly()
            if not flyEnabled then
                bv.Velocity = Vector3.new(0, 0, 0)
                return
            end
            local direction = Vector3.new()
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then direction += camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then direction -= camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then direction -= camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then direction += camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.E) then direction += Vector3.new(0, 1, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.Q) then direction -= Vector3.new(0, 1, 0) end

            if direction.Magnitude > 0 then
                bv.Velocity = direction.Unit * flySpeed
            else
                bv.Velocity = Vector3.new(0, 0, 0)
            end
            bg.CFrame = CFrame.lookAt(humanoidRootPart.Position, humanoidRootPart.Position + camera.CFrame.LookVector)
        end

        local flyConnection = RunService.RenderStepped:Connect(updateFly)
        return function()
            flyConnection:Disconnect()
            noclipConnection:Disconnect()
            bv:Destroy()
            bg:Destroy()
            humanoid.PlatformStand = false
            humanoidRootPart.Velocity = Vector3.new(0, 0, 0)
            for _, part in pairs(character:GetChildren()) do
                if part:IsA("BasePart") then part.CanCollide = true end
            end
        end
    end

    local function enableNoclip()
        local connection = RunService.Stepped:Connect(function()
            if noclipEnabled then
                for _, part in pairs(character:GetChildren()) do
                    if part:IsA("BasePart") then part.CanCollide = false end
                end
            end
        end)
        return function() connection:Disconnect() end
    end

    local flyDisable, noclipDisable = nil, nil

    -- UI cho Misc
    local flyToggle = MiscTab:CreateToggle({
        Name = "Enable Fly",
        CurrentValue = false,
        Flag = "FlyToggle",
        Callback = function(value)
            flyEnabled = value
            if flyEnabled then
                flyDisable = enableFly()
                notify("Fly Enabled", "Fly with noclip activated!", 6.5)
            else
                if flyDisable then flyDisable() end
                notify("Fly Disabled", "Fly turned off!", 6.5)
            end
        end
    })

    local noclipToggle = MiscTab:CreateToggle({
        Name = "Enable Noclip",
        CurrentValue = false,
        Flag = "NoclipToggle",
        Callback = function(value)
            noclipEnabled = value
            if noclipEnabled then
                noclipDisable = enableNoclip()
                notify("Noclip Enabled", "Noclip activated!", 6.5)
            else
                if noclipDisable then noclipDisable() end
                for _, part in pairs(character:GetChildren()) do
                    if part:IsA("BasePart") then part.CanCollide = true end
                end
                notify("Noclip Disabled", "Noclip turned off!", 6.5)
            end
        end
    })

    local flySpeedSlider = MiscTab:CreateSlider({
        Name = "Fly Speed",
        Range = {10, 200},
        Increment = 10,
        Suffix = "Studs/s",
        CurrentValue = flySpeed,
        Flag = "FlySpeed",
        Callback = function(value)
            flySpeed = value
            notify("Fly Speed Updated", "Speed set to " .. value .. " studs/s", 5)
        end
    })

    local walkSpeedSlider = MiscTab:CreateSlider({
        Name = "Walkspeed",
        Range = {0, 1000},
        Increment = 16,
        Suffix = "Speed",
        CurrentValue = walkSpeed,
        Flag = "WalkSpeed",
        Callback = function(value)
            walkSpeed = value
            humanoid.WalkSpeed = walkSpeed
            notify("Walkspeed Updated", "Walkspeed set to " .. value, 5)
        end
    })

    local jumpPowerSlider = MiscTab:CreateSlider({
        Name = "Jump Power",
        Range = {0, 1000},
        Increment = 16,
        Suffix = "Jump",
        CurrentValue = jumpPower,
        Flag = "JumpPower",
        Callback = function(value)
            jumpPower = value
            humanoid.JumpPower = jumpPower
            notify("Jump Power Updated", "Jump power set to " .. value, 5)
        end
    })

    return {
        EnableFly = function() flyToggle:Set(true) end,
        DisableFly = function() flyToggle:Set(false) end,
        EnableNoclip = function() noclipToggle:Set(true) end,
        DisableNoclip = function() noclipToggle:Set(false) end,
        SetFlySpeed = function(speed) flySpeedSlider:Set(speed) end,
        SetWalkSpeed = function(speed) walkSpeedSlider:Set(speed) end,
        SetJumpPower = function(power) jumpPowerSlider:Set(power) end
    }
end

-- Khởi tạo thư viện khi load
local executorName = identifyexecutor and identifyexecutor() or "Unknown Executor"
notify("MeozLib Loaded", "Library loaded on " .. executorName .. "!", 6.5)
sendWebhook("MeozLib loaded on " .. executorName .. " by " .. player.Name)

-- Tạo các tính năng mẫu
local esp = MeozLib.ESP:Create({
    Color = Color3.fromRGB(255, 0, 0),
    Size = 14,
    Range = 200,
    TextFormat = "{name} | HP: {hp} | Distance: {distance} studs"
})
local aimbot = MeozLib.Aimbot:Create({
    Speed = 0.1,
    Range = 100,
    Target = "Head"
})
local misc = MeozLib.Misc:Create()

-- Hàm mở rộng (có thể thêm vào MeozLib)
function MeozLib:AddCustomFeature(name, callback)
    MainTab:CreateButton({
        Name = name,
        Callback = callback
    })
    return true
end

return MeozLib
