local CoreGui=game:GetService("CoreGui")
local Players=game:GetService("Players")
local UserInputService=game:GetService("UserInputService")
local RunService=game:GetService("RunService")
local Workspace=game:GetService("Workspace")

local LocalPlayer=Players.LocalPlayer
local PlayerGui=LocalPlayer:WaitForChild("PlayerGui")
local guiName="KillAuraFullGuiUI"

_G.KillAuraFull=false

local Range=500
local Delay=1

if CoreGui:FindFirstChild(guiName) then
    CoreGui[guiName]:Destroy()
end

if PlayerGui:FindFirstChild(guiName) then
    PlayerGui[guiName]:Destroy()
end

local screenGui=Instance.new("ScreenGui")
screenGui.Name=guiName
screenGui.ResetOnSpawn=false

local success=pcall(function()
    screenGui.Parent=CoreGui
end)

if not success or not screenGui.Parent then
    screenGui.Parent=PlayerGui
end

local mainFrame=Instance.new("Frame")
mainFrame.Size=UDim2.new(0,115,0,30)
mainFrame.Position=UDim2.new(0.5,-57,0.3,0)
mainFrame.BackgroundColor3=Color3.fromRGB(18,18,24)
mainFrame.BorderSizePixel=0
mainFrame.Active=true
mainFrame.Parent=screenGui

local uiCorner=Instance.new("UICorner")
uiCorner.CornerRadius=UDim.new(0,8)
uiCorner.Parent=mainFrame

local uiStroke=Instance.new("UIStroke")
uiStroke.Thickness=1.5
uiStroke.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
uiStroke.LineJoinMode=Enum.LineJoinMode.Round
uiStroke.Color=Color3.fromRGB(255,255,255)
uiStroke.Parent=mainFrame

local uiGradient=Instance.new("UIGradient")
uiGradient.Color=ColorSequence.new({
    ColorSequenceKeypoint.new(0,Color3.fromRGB(0,170,255)),
    ColorSequenceKeypoint.new(0.25,Color3.fromRGB(255,255,255)),
    ColorSequenceKeypoint.new(0.5,Color3.fromRGB(0,30,90)),
    ColorSequenceKeypoint.new(0.75,Color3.fromRGB(255,255,255)),
    ColorSequenceKeypoint.new(1,Color3.fromRGB(0,170,255))
})
uiGradient.Parent=uiStroke

RunService.RenderStepped:Connect(function(delta)
    if uiGradient and uiGradient.Parent then
        uiGradient.Rotation=(uiGradient.Rotation+delta*180)%360
    end
end)

local auraButton=Instance.new("TextButton")
auraButton.Size=UDim2.new(0,70,1,0)
auraButton.Position=UDim2.new(0,0,0,0)
auraButton.BackgroundTransparency=1
auraButton.Text="Kill Aura"
auraButton.TextColor3=Color3.fromRGB(255,255,255)
auraButton.TextSize=14
auraButton.Font=Enum.Font.Cartoon
auraButton.AutoButtonColor=false
auraButton.Parent=mainFrame

local toggleFrame=Instance.new("Frame")
toggleFrame.Size=UDim2.new(0,32,0,16)
toggleFrame.Position=UDim2.new(1,-37,0.5,-8)
toggleFrame.BackgroundColor3=Color3.fromRGB(80,80,85)
toggleFrame.BorderSizePixel=0
toggleFrame.Parent=mainFrame

local toggleCorner=Instance.new("UICorner")
toggleCorner.CornerRadius=UDim.new(1,0)
toggleCorner.Parent=toggleFrame

local toggleCircle=Instance.new("Frame")
toggleCircle.Size=UDim2.new(0,12,0,12)
toggleCircle.Position=UDim2.new(0,2,0.5,-6)
toggleCircle.BackgroundColor3=Color3.fromRGB(255,255,255)
toggleCircle.BorderSizePixel=0
toggleCircle.Parent=toggleFrame

local circleCorner=Instance.new("UICorner")
circleCorner.CornerRadius=UDim.new(1,0)
circleCorner.Parent=toggleCircle

local toggleClickBtn=Instance.new("TextButton")
toggleClickBtn.Size=UDim2.new(1,0,1,0)
toggleClickBtn.BackgroundTransparency=1
toggleClickBtn.Text=""
toggleClickBtn.AutoButtonColor=false
toggleClickBtn.Parent=toggleFrame

local function updateToggle()
    if _G.KillAuraFull then
        toggleFrame.BackgroundColor3=Color3.fromRGB(0,140,230)
        toggleCircle.Position=UDim2.new(1,-14,0.5,-6)
    else
        toggleFrame.BackgroundColor3=Color3.fromRGB(80,80,85)
        toggleCircle.Position=UDim2.new(0,2,0.5,-6)
    end
end

local function toggleAura()
    _G.KillAuraFull=not _G.KillAuraFull
    updateToggle()
end

toggleClickBtn.MouseButton1Click:Connect(function()
    toggleAura()
end)

auraButton.MouseButton1Click:Connect(function()
    toggleAura()
end)

updateToggle()

task.spawn(function()
    while task.wait(Delay) do
        if _G.KillAuraFull then
            pcall(function()
                local plr=Players.LocalPlayer
                local char=plr.Character
                local hrp=char and char:FindFirstChild("HumanoidRootPart")

                if not hrp then
                    return
                end

                sethiddenproperty(plr,"SimulationRadius",math.huge)

                local Enemies=Workspace:FindFirstChild("Enemies")

                if not Enemies then
                    return
                end

                for _,enemy in pairs(Enemies:GetChildren()) do
                    local Humanoid=enemy:FindFirstChild("Humanoid")
                    local RootPart=enemy:FindFirstChild("HumanoidRootPart")

                    if Humanoid and RootPart then
                        local dist=(RootPart.Position-hrp.Position).Magnitude

                        if dist<=Range and Humanoid.Health>0 then
                            Humanoid.Health=0
                            RootPart.CanCollide=false
                            enemy:BreakJoints()
                        end
                    end
                end
            end)
        end
    end
end)

local dragging=false
local dragStart
local startPos

auraButton.InputBegan:Connect(function(input)
    if input.UserInputType==Enum.UserInputType.MouseButton1
        or input.UserInputType==Enum.UserInputType.Touch then

        dragging=true
        dragStart=input.Position
        startPos=mainFrame.Position

        input.Changed:Connect(function()
            if input.UserInputState==Enum.UserInputState.End then
                dragging=false
            end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging
        and (input.UserInputType==Enum.UserInputType.MouseMovement
        or input.UserInputType==Enum.UserInputType.Touch) then

        local delta=input.Position-dragStart

        mainFrame.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+delta.X,startPos.Y.Scale,startPos.Y.Offset+delta.Y)
    end
end)

repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local VirtualUser = game:GetService("VirtualUser")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

LocalPlayer.Idled:Connect(function()
    VirtualUser:Button2Down(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
    task.wait(1)
    VirtualUser:Button2Up(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
end)

pcall(function()
    local Old = CoreGui:FindFirstChild("AntiAFKNotify")
    if Old then Old:Destroy() end
end)

local Gui = Instance.new("ScreenGui")
Gui.Name = "AntiAFKNotify"
Gui.ResetOnSpawn = false

pcall(function()
    Gui.Parent = CoreGui
end)

if not Gui.Parent then
    Gui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

local LeftLabel = Instance.new("TextLabel",Gui)
LeftLabel.Size = UDim2.new(0.5,0,0,100)
LeftLabel.Position = UDim2.new(0,0,0.4,0)
LeftLabel.BackgroundTransparency = 1
LeftLabel.Text = "KILL AURA BLF"
LeftLabel.TextColor3 = Color3.fromRGB(255,0,0)
LeftLabel.Font = Enum.Font.GothamBold
LeftLabel.TextSize = 24
LeftLabel.TextXAlignment = Enum.TextXAlignment.Right
LeftLabel.TextStrokeTransparency = 1

local RightLabel = Instance.new("TextLabel",Gui)
RightLabel.Size = UDim2.new(0.5,0,0,100)
RightLabel.Position = UDim2.new(0.5,0,0.4,0)
RightLabel.BackgroundTransparency = 1
RightLabel.Text = " | NHAT HIHI"
RightLabel.TextColor3 = Color3.fromRGB(255,0,0)
RightLabel.Font = Enum.Font.GothamBold
RightLabel.TextSize = 24
RightLabel.TextXAlignment = Enum.TextXAlignment.Left
RightLabel.TextStrokeTransparency = 1

local LeftIntro = TweenService:Create(LeftLabel,TweenInfo.new(0.8,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{
    Position = UDim2.new(0,0,-0.1,0)
})

local RightIntro = TweenService:Create(RightLabel,TweenInfo.new(0.8,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{
    Position = UDim2.new(0.5,0,-0.1,0)
})

LeftIntro:Play()
RightIntro:Play()

task.wait(5)

local LeftTween = TweenService:Create(LeftLabel,TweenInfo.new(1,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{
    Position = UDim2.new(0,-300,0,0),
    TextTransparency = 1
})

local RightTween = TweenService:Create(RightLabel,TweenInfo.new(1,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{
    Position = UDim2.new(0.5,300,0,0),
    TextTransparency = 1
})

LeftTween:Play()
RightTween:Play()

RightTween.Completed:Wait()
Gui:Destroy()

local Players=game:GetService("Players")
local LocalPlayer=Players.LocalPlayer

local ANIMATIONS={
 Idle="rbxassetid://112914164223755",
 Walk="rbxassetid://110663261566562",
 Jump="rbxassetid://121775742501117"
}

local CurrentTracks={}
local Connections={}

local function Clear()
 for _,Track in pairs(CurrentTracks) do
  pcall(function()
   Track:Stop(0.15)
   Track:Destroy()
  end)
 end
 table.clear(CurrentTracks)

 for _,Connection in pairs(Connections) do
  Connection:Disconnect()
 end
 table.clear(Connections)
end

local function SetupCharacter(Character)
 Clear()

 local Humanoid=Character:WaitForChild("Humanoid")
 local Animator=Humanoid:WaitForChild("Animator")

 local function CreateTrack(Name,Id,Priority,Looped)
  local Animation=Instance.new("Animation")
  Animation.AnimationId=Id

  local Track=Animator:LoadAnimation(Animation)
  Track.Priority=Priority
  Track.Looped=Looped

  CurrentTracks[Name]=Track
 end

 CreateTrack("Idle",ANIMATIONS.Idle,Enum.AnimationPriority.Idle,true)
 CreateTrack("Walk",ANIMATIONS.Walk,Enum.AnimationPriority.Movement,true)
 CreateTrack("Jump",ANIMATIONS.Jump,Enum.AnimationPriority.Action,false)

 local CurrentState=""

 local function Play(Name)
  if CurrentState==Name then return end
  CurrentState=Name

  for TrackName,Track in pairs(CurrentTracks) do
   if TrackName~=Name and Track.IsPlaying then
    Track:Stop(0.15)
   end
  end

  local Track=CurrentTracks[Name]
  if Track and not Track.IsPlaying then
   Track:Play(0.15)
  end
 end

 local function Update()
  if Humanoid.Health<=0 then return end

  local State=Humanoid:GetState()

  if State==Enum.HumanoidStateType.Jumping then
   Play("Jump")
  elseif State==Enum.HumanoidStateType.Freefall then
   return
  elseif Humanoid.MoveDirection.Magnitude>0.05 then
   Play("Walk")
  else
   Play("Idle")
  end
 end

 table.insert(Connections,Humanoid.Running:Connect(Update))
 table.insert(Connections,Humanoid.StateChanged:Connect(function(_,NewState)
  if NewState==Enum.HumanoidStateType.Jumping then
   Play("Jump")
  elseif NewState==Enum.HumanoidStateType.Landed or NewState==Enum.HumanoidStateType.Running or NewState==Enum.HumanoidStateType.RunningNoPhysics then
   Update()
  end
 end))

 Play("Idle")
end

LocalPlayer.CharacterAdded:Connect(SetupCharacter)

if LocalPlayer.Character then
 SetupCharacter(LocalPlayer.Character)
end


local RunService=game:GetService("RunService")
local CoreGui=game:GetService("CoreGui")
local TweenService=game:GetService("TweenService")

local Old=CoreGui:FindFirstChild("FPSMiniGui")
if Old then Old:Destroy() end

local Gui=Instance.new("ScreenGui")
Gui.Name="FPSMiniGui"
Gui.ResetOnSpawn=false
Gui.IgnoreGuiInset=true
Gui.Parent=CoreGui

local Frame=Instance.new("Frame")
Frame.Size=UDim2.new(0,60,0,25)
Frame.Position=UDim2.new(0,0,0,0)
Frame.BackgroundColor3=Color3.fromRGB(18,18,24)
Frame.BorderSizePixel=0
Frame.Parent=Gui

local Corner=Instance.new("UICorner")
Corner.CornerRadius=UDim.new(0,6)
Corner.Parent=Frame

local Label=Instance.new("TextLabel")
Label.Size=UDim2.new(1,0,1,0)
Label.BackgroundTransparency=1
Label.Text="FPS: --"
Label.TextColor3=Color3.fromRGB(80,255,100)
Label.TextSize=11
Label.Font=Enum.Font.GothamBold
Label.Parent=Frame

local Colors={
    {FPS=40,Color=Color3.fromRGB(80,255,100)},
    {FPS=30,Color=Color3.fromRGB(255,235,150)},
    {FPS=20,Color=Color3.fromRGB(255,170,100)},
    {FPS=10,Color=Color3.fromRGB(255,70,70)},
    {FPS=5,Color=Color3.fromRGB(230,90,200)},
    {FPS=0,Color=Color3.fromRGB(190,100,255)}
}

local Frames=0
local Last=os.clock()
local CurrentTween=nil

local function GetColor(FPS)
    for i=1,#Colors-1 do
        local A=Colors[i]
        local B=Colors[i+1]

        if FPS<=A.FPS and FPS>=B.FPS then
            local Alpha=(A.FPS-FPS)/(A.FPS-B.FPS)
            return A.Color:Lerp(B.Color,Alpha)
        end
    end

    return FPS>40 and Colors[1].Color or Colors[#Colors].Color
end

RunService.RenderStepped:Connect(function()
    Frames+=1
    local Now=os.clock()

    if Now-Last>=1 then
        local FPS=math.floor(Frames/(Now-Last))
        Label.Text="FPS: "..FPS

        if CurrentTween then
            CurrentTween:Cancel()
        end

        CurrentTween=TweenService:Create(
            Label,
            TweenInfo.new(0.8,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),
            {TextColor3=GetColor(FPS)}
        )
        CurrentTween:Play()

        Frames=0
        Last=Now
    end
end)


local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local plr = Players.LocalPlayer

pcall(function()
    local old = CoreGui:FindFirstChild("AimControlGui")
    if old then old:Destroy() end
    local old2 = plr.PlayerGui:FindFirstChild("AimControlGui")
    if old2 then old2:Destroy() end
end)

-- Biến cục bộ
local AimMethod = false
local AimMonster = false
local AimCam = false
local CurrentCamTarget = nil
local ABmethod = "Aim Player"
local MousePos = Vector3.zero
local SelectedPlayerName = nil

local Gui = Instance.new("ScreenGui")
Gui.Name = "AimControlGui"
Gui.ResetOnSpawn = false
Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

pcall(function()
    Gui.Parent = CoreGui
end)
if not Gui.Parent then Gui.Parent = plr:WaitForChild("PlayerGui") end

local function Corner(obj, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 8)
    c.Parent = obj
end

local function Stroke(obj)
    local s = Instance.new("UIStroke")
    s.Color = Color3.fromRGB(0, 140, 230)
    s.Thickness = 1.5
    s.Parent = obj
end

local function MakeButton(parent, text)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, -5, 0, 30)
    b.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    b.TextColor3 = Color3.fromRGB(240, 240, 245)
    b.Font = Enum.Font.Cartoon
    b.TextSize = 11
    b.Text = text
    b.AutoButtonColor = true
    b.Parent = parent
    Corner(b, 7)
    return b
end

-- Nút AIM ngoài màn hình để mở/đóng menu
local ToggleMenu = Instance.new("TextButton")
ToggleMenu.Size = UDim2.new(0, 65, 0, 30)
ToggleMenu.Position = UDim2.new(0,0, 0.1, 0)
ToggleMenu.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
ToggleMenu.TextColor3 = Color3.fromRGB(240, 240, 245)
ToggleMenu.Font = Enum.Font.Cartoon
ToggleMenu.TextSize = 11
ToggleMenu.Text = "AIM"
ToggleMenu.Parent = Gui
Corner(ToggleMenu, 7)
Stroke(ToggleMenu)

-- Bảng chính (Main Frame) - Đã tăng chiều cao để chứa đủ nút Camera
local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.new(0, 225, 0, 225)
Main.AnchorPoint = Vector2.new(0.5, 0.5)
Main.Position = UDim2.new(0.5, 0, 0.5, 0)
Main.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
Main.Visible = false
Main.Active = true
Main.Draggable = true
Main.Parent = Gui
Corner(Main, 10)
Stroke(Main)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -15, 0, 30)
Title.Position = UDim2.new(0, 10, 0, 3)
Title.BackgroundTransparency = 1
Title.Text = "SILENT AIM"
Title.TextColor3 = Color3.fromRGB(0, 170, 255)
Title.Font = Enum.Font.Cartoon
Title.TextSize = 13
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Main

local MainScroll = Instance.new("ScrollingFrame")
MainScroll.Position = UDim2.new(0, 5, 0, 35)
MainScroll.Size = UDim2.new(1, -10, 1, -40)
MainScroll.BackgroundTransparency = 1
MainScroll.BorderSizePixel = 0
MainScroll.ScrollBarThickness = 3
MainScroll.ScrollBarImageColor3 = Color3.fromRGB(0, 140, 230)
MainScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
MainScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
MainScroll.Parent = Main

local MainLayout = Instance.new("UIListLayout")
MainLayout.Padding = UDim.new(0, 6)
MainLayout.Parent = MainScroll

-- Bảng chọn người chơi (Nằm sát bên phải bảng Main)
local PlayerPanel = Instance.new("Frame")
PlayerPanel.Name = "PlayerPanel"
PlayerPanel.Size = UDim2.new(0, 175, 0, 190)
PlayerPanel.Position = UDim2.new(0, Main.Position.X.Offset + Main.Size.X.Offset + 3, Main.Position.Y.Scale, Main.Position.Y.Offset)
PlayerPanel.BackgroundColor3 = Color3.fromRGB(18,18,24)
PlayerPanel.Visible = false
PlayerPanel.Active = true
PlayerPanel.Draggable = true
PlayerPanel.Parent = Gui

Instance.new("UICorner", PlayerPanel).CornerRadius = UDim.new(0, 10)

local PlayerStroke = Instance.new("UIStroke", PlayerPanel)
PlayerStroke.Color = Color3.fromRGB(0,140,230)
PlayerStroke.Thickness = 1.5

Main:GetPropertyChangedSignal("Position"):Connect(function()
    PlayerPanel.Position = UDim2.new(0, Main.AbsolutePosition.X + Main.AbsoluteSize.X + 3, 0, Main.AbsolutePosition.Y)
end)

local PlayerTitle = Instance.new("TextLabel")
PlayerTitle.Size = UDim2.new(1, -10, 0, 28)
PlayerTitle.Position = UDim2.new(0, 5, 0, 2)
PlayerTitle.BackgroundTransparency = 1
PlayerTitle.Text = "CHỌN TÊN NGƯỜI CHƠI"
PlayerTitle.TextColor3 = Color3.fromRGB(0, 170, 255)
PlayerTitle.Font = Enum.Font.Cartoon
PlayerTitle.TextSize = 12
PlayerTitle.Parent = PlayerPanel

local PlayerScroll = Instance.new("ScrollingFrame")
PlayerScroll.Position = UDim2.new(0, 5, 0, 32)
PlayerScroll.Size = UDim2.new(1, -10, 1, -38)
PlayerScroll.BackgroundTransparency = 1
PlayerScroll.BorderSizePixel = 0
PlayerScroll.ScrollBarThickness = 3
PlayerScroll.ScrollBarImageColor3 = Color3.fromRGB(0, 140, 230)
PlayerScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
PlayerScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
PlayerScroll.Parent = PlayerPanel

local PlayerLayout = Instance.new("UIListLayout")
PlayerLayout.Padding = UDim.new(0, 5)
PlayerLayout.Parent = PlayerScroll

local PlayerButtons = {}
local UpdatePlayerList

UpdatePlayerList = function()
    pcall(function()
        for _, v in ipairs(PlayerButtons) do
            if v then v:Destroy() end
        end
        table.clear(PlayerButtons)

        for _, target in ipairs(Players:GetPlayers()) do
            if target ~= plr and target.Team ~= plr.Team then
                local b = Instance.new("TextButton")
                b.Size = UDim2.new(1, -5, 0, 29)
                b.BackgroundColor3 = SelectedPlayerName == target.Name and Color3.fromRGB(0, 105, 180) or Color3.fromRGB(30, 30, 40)
                b.TextColor3 = Color3.new(1, 1, 1)
                b.Font = Enum.Font.Cartoon
                b.TextSize = 11
                b.Text = "" .. target.Name
                b.Parent = PlayerScroll
                Instance.new("UICorner", b).CornerRadius = UDim.new(0, 7)

                b.MouseButton1Click:Connect(function()
                    SelectedPlayerName = target.Name
                    UpdatePlayerList()
                end)

                table.insert(PlayerButtons, b)
            end
        end
    end)
end

task.spawn(function()
    while true do
        task.wait(1)
        UpdatePlayerList()
    end
end)

UpdatePlayerList()

local MethodBtn = MakeButton(MainScroll, "Phương Pháp: Aim Người Chơi")
local PlayerBtn = MakeButton(MainScroll, "Người Chơi: Không Có")
local SkillsBtn = MakeButton(MainScroll, "Aim Người Chơi")
local MonsterBtn = MakeButton(MainScroll, "Aim Quái")
local CameraBtn = MakeButton(MainScroll, "AIM CAMERA: OFF")

-- Hàm đồng bộ trạng thái bật/tắt của Aim Camera
local function SetAimCamState(state)
    AimCam = state
    if not state then
        CurrentCamTarget = nil
    end
    CameraBtn.Text = "AIM CAMERA: " .. (AimCam and "ON" or "OFF")
    CameraBtn.BackgroundColor3 = AimCam and Color3.fromRGB(0, 110, 190) or Color3.fromRGB(30, 30, 40)
end

MethodBtn.MouseButton1Click:Connect(function()
    ABmethod = ABmethod == "Aim Player" and "Nearest Aim" or "Aim Player"
    MethodBtn.Text = "Phương Pháp: " .. (ABmethod == "Aim Player" and "Aim Người Chơi" or "AIM GẦN")
end)

PlayerBtn.MouseButton1Click:Connect(function()
    PlayerPanel.Visible = not PlayerPanel.Visible
    UpdatePlayerList()
end)

SkillsBtn.MouseButton1Click:Connect(function()
    AimMethod = not AimMethod
    SkillsBtn.Text = "Aim Người Chơi: " .. (AimMethod and "ON" or "OFF")
    SkillsBtn.BackgroundColor3 = AimMethod and Color3.fromRGB(0, 110, 190) or Color3.fromRGB(30, 30, 40)
end)

MonsterBtn.MouseButton1Click:Connect(function()
    AimMonster = not AimMonster
    MonsterBtn.Text = "Aim Quái: " .. (AimMonster and "ON" or "OFF")
    MonsterBtn.BackgroundColor3 = AimMonster and Color3.fromRGB(0, 110, 190) or Color3.fromRGB(30, 30, 40)
end)

CameraBtn.MouseButton1Click:Connect(function()
    SetAimCamState(not AimCam)
end)

ToggleMenu.MouseButton1Click:Connect(function()
    Main.Visible = not Main.Visible
    if not Main.Visible then
        PlayerPanel.Visible = false
    end
end)

UIS.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.LeftControl then
        Gui.Enabled = not Gui.Enabled
    end
end)

local function GetBodyPart(char)
    if not char then return nil end
    return char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso") or char:FindFirstChild("HumanoidRootPart")
end

local function GetNearestEnemy()
    local enemiesFolder = workspace:FindFirstChild("Enemies")
    if not enemiesFolder then return nil end
    local myChar = plr.Character
    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if not myRoot then return nil end

    local nearestPart, minDistance = nil, math.huge
    for _, enemy in ipairs(enemiesFolder:GetChildren()) do
        local hum = enemy:FindFirstChildOfClass("Humanoid")
        local targetPart = GetBodyPart(enemy)
        if hum and hum.Health > 0 and targetPart then
            local distance = (targetPart.Position - myRoot.Position).Magnitude
            if distance < minDistance then
                minDistance = distance
                nearestPart = targetPart
            end
        end
    end
    return nearestPart
end

-- Cập nhật tọa độ thực tế liên tục
task.spawn(function()
    while true do
        task.wait(0.00)
        pcall(function()
            if SelectedPlayerName then
                PlayerBtn.Text = "Người Chơi: " .. SelectedPlayerName
            else
                PlayerBtn.Text = "Người Chơi: Không Có"
            end

            if AimMonster then
                local monsterPart = GetNearestEnemy()
                if monsterPart then
                    MousePos = monsterPart.Position
                end
            elseif AimMethod and ABmethod == "Aim Player" then
                local target = Players:FindFirstChild(SelectedPlayerName or "")
                if target and target.Character and target.Team ~= plr.Team then
                    local targetPart = GetBodyPart(target.Character)
                    if targetPart then MousePos = targetPart.Position end
                end
            elseif AimMethod and ABmethod == "Nearest Aim" then
                local myChar = plr.Character
                local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
                if myRoot then
                    local maxDistance = math.huge
                    
                    for _, v in ipairs(Players:GetPlayers()) do
                        if v ~= plr and v.Team ~= plr.Team and v.Character then
                            local targetPart = GetBodyPart(v.Character)
                            local hum = v.Character:FindFirstChildOfClass("Humanoid")
                            if targetPart and hum and hum.Health > 0 then
                                local distance = (targetPart.Position - myRoot.Position).Magnitude
                                if distance < maxDistance then
                                    maxDistance = distance
                                    MousePos = targetPart.Position
                                end
                            end
                        end
                    end
                end
            end
        end)
    end
end)

-- AIM CAMERA 360: Tự tắt khi mục tiêu chết
local function IsMarine(Team)
    if not Team then return false end
    local Name = Team.Name:lower()
    return Name:find("marine") ~= nil or Name:find("hải quân") ~= nil or Name:find("navy") ~= nil
end

local function IsValidCamTarget(Player)
    if not Player or Player == plr or not Player.Character then return false end

    local Humanoid = Player.Character:FindFirstChildOfClass("Humanoid")
    local Root = Player.Character:FindFirstChild("HumanoidRootPart")

    if not Humanoid or Humanoid.Health <= 0 or not Root then return false end

    if IsMarine(plr.Team) then
        if Player.Team == plr.Team then return false end
        if not Player.Team or IsMarine(Player.Team) then return false end
    end

    return true
end

local function GetNearestCamTarget()
    local Character = plr.Character
    local MyRoot = Character and Character:FindFirstChild("HumanoidRootPart")
    if not MyRoot then return nil end

    local Nearest = nil
    local MinDistance = math.huge

    for _, Player in ipairs(Players:GetPlayers()) do
        if IsValidCamTarget(Player) then
            local Root = Player.Character:FindFirstChild("HumanoidRootPart")
            local Distance = (Root.Position - MyRoot.Position).Magnitude

            if Distance < MinDistance then
                MinDistance = Distance
                Nearest = Player
            end
        end
    end

    return Nearest
end

RunService.RenderStepped:Connect(function()
    if not AimCam then return end

    local Character = plr.Character
    if not Character then return end

    if not CurrentCamTarget then
        CurrentCamTarget = GetNearestCamTarget()
        if not CurrentCamTarget then
            SetAimCamState(false)
            return
        end
    end

    if not IsValidCamTarget(CurrentCamTarget) then
        SetAimCamState(false)
        return
    end

    local TargetCharacter = CurrentCamTarget.Character
    local Root = TargetCharacter and TargetCharacter:FindFirstChild("HumanoidRootPart")
    if Root then
        local Camera = workspace.CurrentCamera
        local CameraPosition = Camera.CFrame.Position
        Camera.CFrame = CFrame.lookAt(CameraPosition, Root.Position)
    else
        SetAimCamState(false)
    end
end)

-- ========================================================
-- METATABLE HOOK TƯƠNG THÍCH SHOOTGUN EVENT & BẢO VỆ REQUEST ENTRANCE
-- ========================================================
pcall(function()
    local gg = getrawmetatable(game)
    local old = gg.__namecall
    setreadonly(gg, false)
    
    gg.__namecall = newcclosure(function(self, ...)
        local method = getnamecallmethod()
        local args = {...}    
        
        -- Chỉ can thiệp khi bật Aim Monster hoặc Aim Skills
        if AimMonster or AimMethod then
            if method == "FireServer" or method == "InvokeServer" then
                
                -- BỘ LỌC AN TOÀN: Bỏ qua requestEntrance của CommF_
                local remoteName = tostring(self)
                local firstArg = tostring(args[1])
                
                if remoteName == "CommF_" and (firstArg == "requestEntrance" or args[1] == "requestEntrance") then
                    return old(self, unpack(args))
                end

                for i = 1, #args do
                    if typeof(args[i]) == "Vector3" then
                        args[i] = MousePos
                    end
                end
                
                return old(self, unpack(args))
            end
        end
        
        return old(self, ...)
    end)
end)

