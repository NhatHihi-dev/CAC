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

-- XOÁ GUI CŨ
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
mainFrame.Position=UDim2.new(0.5,-57,0.4,0)
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
