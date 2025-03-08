local Meozlib = {}
Meozlib.__index = Meozlib
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local Themes = {
    Dark = {
        Background = Color3.fromRGB(30, 30, 30),
        Text = Color3.fromRGB(255, 255, 255),
        Bar = Color3.fromRGB(0, 170, 255),
        Blur = Color3.fromRGB(50, 50, 50),
        Shadow = Color3.fromRGB(20, 20, 20)
    },
    Light = {
        Background = Color3.fromRGB(245, 245, 245),
        Text = Color3.fromRGB(0, 0, 0),
        Bar = Color3.fromRGB(0, 120, 255),
        Blur = Color3.fromRGB(200, 200, 200),
        Shadow = Color3.fromRGB(150, 150, 150)
    },
    Pink = {
        Background = Color3.fromRGB(240, 150, 200),
        Text = Color3.fromRGB(255, 255, 255),
        Bar = Color3.fromRGB(255, 100, 150),
        Blur = Color3.fromRGB(220, 130, 180),
        Shadow = Color3.fromRGB(200, 100, 150)
    }
}
local UIVersion = "1.2.0"
function Meozlib.new()
    local self = setmetatable({}, Meozlib)
    self.ScreenGui = Instance.new("ScreenGui")
    self.ScreenGui.Name = "MeozlibUI"
    self.ScreenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
    self.ScreenGui.ResetOnSpawn = false
    self.ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    self.Blur = Instance.new("BlurEffect")
    self.Blur.Size = 0
    self.Blur.Parent = game.Lighting
    self.Blur.Enabled = true
    self.MainFrame = Instance.new("Frame")
    self.MainFrame.Size = UDim2.new(0, 300, 0, 180)
    self.MainFrame.Position = UDim2.new(0.5, -150, 0.5, -90)
    self.MainFrame.BackgroundColor3 = Themes.Dark.Background
    self.MainFrame.BorderSizePixel = 0
    self.MainFrame.BackgroundTransparency = 0
    self.MainFrame.Parent = self.ScreenGui
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 12)
    UICorner.Parent = self.MainFrame
    self.Shadow = Instance.new("ImageLabel")
    self.Shadow.Name = "Shadow"
    self.Shadow.BackgroundTransparency = 1
    self.Shadow.Image = "rbxassetid://1316045217"
    self.Shadow.ImageColor3 = Themes.Dark.Shadow
    self.Shadow.ImageTransparency = 0.6
    self.Shadow.Size = UDim2.new(1, 40, 1, 40)
    self.Shadow.Position = UDim2.new(0, -20, 0, -20)
    self.Shadow.ZIndex = -1
    self.Shadow.Parent = self.MainFrame
    self.Title = Instance.new("TextLabel")
    self.Title.Size = UDim2.new(0.7, 0, 0, 40)
    self.Title.Position = UDim2.new(0.15, 0, 0, 10)
    self.Title.BackgroundTransparency = 1
    self.Title.Text = "Meozhub"
    self.Title.TextColor3 = Themes.Dark.Text
    self.Title.TextSize = 24
    self.Title.Font = Enum.Font.GothamBold
    self.Title.TextXAlignment = Enum.TextXAlignment.Center
    self.Title.Parent = self.MainFrame
    self.VersionText = Instance.new("TextLabel")
    self.VersionText.Size = UDim2.new(0.3, 0, 0, 20)
    self.VersionText.Position = UDim2.new(0.7, 0, 0, 20)
    self.VersionText.BackgroundTransparency = 1
    self.VersionText.Text = "v" .. UIVersion
    self.VersionText.TextColor3 = Themes.Dark.Text
    self.VersionText.TextSize = 14
    self.VersionText.Font = Enum.Font.Gotham
    self.VersionText.TextXAlignment = Enum.TextXAlignment.Right
    self.VersionText.Visible = false
    self.VersionText.Parent = self.MainFrame
    self.ProgressBar = Instance.new("Frame")
    self.ProgressBar.Size = UDim2.new(0.9, 0, 0, 10)
    self.ProgressBar.Position = UDim2.new(0.05, 0, 0.5, 0)
    self.ProgressBar.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    self.ProgressBar.Parent = self.MainFrame
    local ProgressCorner = Instance.new("UICorner")
    ProgressCorner.CornerRadius = UDim.new(1, 0)
    ProgressCorner.Parent = self.ProgressBar
    self.ProgressFill = Instance.new("Frame")
    self.ProgressFill.Size = UDim2.new(0, 0, 1, 0)
    self.ProgressFill.BackgroundColor3 = Themes.Dark.Bar
    self.ProgressFill.BorderSizePixel = 0
    self.ProgressFill.Parent = self.ProgressBar
    local FillCorner = Instance.new("UICorner")
    FillCorner.CornerRadius = UDim.new(1, 0)
    FillCorner.Parent = self.ProgressFill
    self.LoadingText = Instance.new("TextLabel")
    self.LoadingText.Size = UDim2.new(1, 0, 0, 30)
    self.LoadingText.Position = UDim2.new(0, 0, 0.65, 0)
    self.LoadingText.BackgroundTransparency = 1
    self.LoadingText.Text = "Loading..."
    self.LoadingText.TextColor3 = Themes.Dark.Text
    self.LoadingText.TextSize = 16
    self.LoadingText.Font = Enum.Font.Gotham
    self.LoadingText.TextXAlignment = Enum.TextXAlignment.Center
    self.LoadingText.Parent = self.MainFrame
    self.CountryText = Instance.new("TextLabel")
    self.CountryText.Size = UDim2.new(1, 0, 0, 20)
    self.CountryText.Position = UDim2.new(0, 0, 0.85, 0)
    self.CountryText.BackgroundTransparency = 1
    self.CountryText.Text = ""
    self.CountryText.TextColor3 = Themes.Dark.Text
    self.CountryText.TextSize = 14
    self.CountryText.Font = Enum.Font.Gotham
    self.CountryText.TextXAlignment = Enum.TextXAlignment.Center
    self.CountryText.Visible = false
    self.CountryText.Parent = self.MainFrame
    self.CurrentTheme = "Dark"
    self.Messages = {}
    return self
end
function Meozlib:SetTitle(titleText)
    self.Title.Text = titleText or "Meozhub"
end
function Meozlib:ToggleTransparency(enabled)
    local tweenInfo = TweenInfo.new(0.3)
    local goal = enabled and {BackgroundTransparency = 0.5} or {BackgroundTransparency = 0}
    TweenService:Create(self.MainFrame, tweenInfo, goal):Play()
end
function Meozlib:ToggleBlur(enabled)
    local tweenInfo = TweenInfo.new(0.5)
    local goal = enabled and {Size = 15} or {Size = 0}
    TweenService:Create(self.Blur, tweenInfo, goal):Play()
end
function Meozlib:SetTheme(themeName)
    local theme = Themes[themeName] or Themes.Dark
    self.CurrentTheme = themeName
    self.MainFrame.BackgroundColor3 = theme.Background
    self.Title.TextColor3 = theme.Text
    self.VersionText.TextColor3 = theme.Text
    self.LoadingText.TextColor3 = theme.Text
    self.CountryText.TextColor3 = theme.Text
    self.ProgressFill.BackgroundColor3 = theme.Bar
    self.Shadow.ImageColor3 = theme.Shadow
    if self.ColorCorrection then
        self.ColorCorrection.TintColor = theme.Blur
    else
        self.ColorCorrection = Instance.new("ColorCorrectionEffect")
        self.ColorCorrection.TintColor = theme.Blur
        self.ColorCorrection.Parent = game.Lighting
    end
end
function Meozlib:ToggleVersion(enabled)
    self.VersionText.Visible = enabled
end
function Meozlib:ToggleCountry(enabled)
    if enabled then
        local success, result = pcall(function()
            local ip = game:HttpGet("https://api.ipify.org")
            local country = HttpService:JSONDecode(game:HttpGet("http://ip-api.com/json/" .. ip)).country
            self.CountryText.Text = "Country: " .. country
            self.CountryText.Visible = true
        end)
        if not success then
            self.CountryText.Text = "Country: Unavailable"
            self.CountryText.Visible = true
        end
    else
        self.CountryText.Visible = false
    end
end
function Meozlib:StartLoading(messages, durationPerMessage)
    self.Messages = messages or {}
    durationPerMessage = durationPerMessage or 2
    local totalDuration = #self.Messages > 0 and (#self.Messages * durationPerMessage) or 3
    
    local tweenInfo = TweenInfo.new(totalDuration)
    local tween = TweenService:Create(self.ProgressFill, tweenInfo, {Size = UDim2.new(1, 0, 1, 0)})
    self.MainFrame.BackgroundTransparency = 1
    self.MainFrame:TweenSizeAndPosition(
        UDim2.new(0, 350, 0, 200),
        UDim2.new(0.5, -175, 0.5, -100),
        "Out",
        "Quad",
        0.3,
        true
    )
    TweenService:Create(self.MainFrame, TweenInfo.new(0.3), {BackgroundTransparency = 0}):Play()
    spawn(function()
        if #self.Messages > 0 then
            for i, msg in ipairs(self.Messages) do
                self.LoadingText.Text = msg
                wait(durationPerMessage)
            end
        end
        local dots = 0
        while wait(0.3) do
            dots = (dots + 1) % 4
            self.LoadingText.Text = "Loading" .. string.rep(".", dots)
            if self.ProgressFill.Size.X.Scale >= 1 then
                break
            end
        end
    end)
    tween:Play()
end
function Meozlib:Destroy()
    self:ToggleBlur(false)
    TweenService:Create(self.MainFrame, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
    self.MainFrame:TweenSize(UDim2.new(0, 0, 0, 0), "In", "Quad", 0.3, true, function()
        self.ScreenGui:Destroy()
        self.Blur:Destroy()
        if self.ColorCorrection then
            self.ColorCorrection:Destroy()
        end
    end)
end
