warn("Running...")
-- Service --
local rs = game:GetService("RunService")
print("Got RunService")
local ts = game:GetService("TweenService")
local uis = game:GetService("UserInputService")
print("Got UserInputService")
local vim = game:GetService("VirtualInputManager")
print("Got VirtualInputManage")
local tcs = game:GetService("TextChatService")

-- Local plr --
local Plrs = game.Players
local Plr = Plrs.LocalPlayer
local Char = Plr.Character or Plr.CharacterAdded:Wait()
print("Got char")
local Root = Char:WaitForChild("HumanoidRootPart")
print("Got root")
local Hum = Char:WaitForChild("Humanoid")
print("Got hum")
local Live = game.workspace.Live:WaitForChild(Plr.Name)
local Map = game.workspace.Map
local Hotbar = Plr:WaitForChild("PlayerGui"):FindFirstChild("Hotbar").Backpack.Hotbar

-- Dummy --
if game.workspace.Live:FindFirstChild("Weakest Dummy") then
    local Dummy = game.workspace.Live:WaitForChild("Weakest Dummy")
    local RootD = Dummy:WaitForChild("HumanoidRootPart")
    local HumD = Dummy:WaitForChild("Humanoid")
    print("Got dummy")
end

-- Boss & Target --
local PreviousBoss, Boss, PreviousTarget, Target, CharB, CharT, RootB, RootT, HumB, HumT, LiveB, LiveT, CharCPFB, RootCPFB, OldBoss
-- UI Variables --
local Gui, InputB, InputT
-- Event Variables --
local Work, DiedB, DiedT, FindTargetRS, HumDiedEvent, AttackEvent, ShowPlrEvent, TargetM1Event, TargetSkill1Event, TargetSkill2Event, TargetSkill3Event, TargetSkill4Event, BossSkill1Event, TargetInputM1Event, TargetInputSkill1Event, TargetInputSkill2Event, TargetInputSkill3Event, TargetInputSkill4Event, BossInputSkill1Event, CamEvent1
local HoldingM1Event, PackBEvent, FindingClosectPlayerEvent
-- Conditions --
local ConWork = false
local FindTargetCon = false
local AttackCon = false
local TrashCon = false
local TargetCon = false
local CloseCon = false
local ChoosenBossCon = false
local TargetInputM1Con = false
local Skilled = false

local OnCooldown = {
    Skill1 = {'1', false},
    Skill2 = {'2', false},
    Skill3 = {'3', false},
    Skill4 = {'4', false}
}
local M1ing = false
local Ragdoll = false
-- Other --
local cam = game.workspace.CurrentCamera
local Mouse = Plr:GetMouse()
local ChoosenHl, ChoosenChar, TargetHl, ShowPlrHl
local OrgCFrame = nil
local PreviousClosePlr = nil
local Flags = {}
for _, P in pairs(Plrs:GetPlayers()) do
    Flags[P] = {Stm = false, Dc = false}
end
local TrashHandle = false
local TrashLoop = false
local PackB
rs.Heartbeat:Connect(function()
    if Boss then
        local BossP = Boss.Backpack
        if BossP:FindFirstChild("Crushing Pull") or BossP:FindFirstChild("Cosmic Strike") then
            PackB = {
                Name = "Tatsumaki",
                NormalSkill = {"Crushing Pull", "Windstorm Fury", "Stone Coffin", "Expulsive Push"},
                UltSkill = {"Cosmic Strike", "Psychic Ricochet", "Terrible Tornado", "Sky Snatcher"}
            }
        elseif BossP:FindFirstChild("Normal Punch") or BossP:FindFirstChild("Death Counter") then
            PackB = {
                Name = "Saitama",
                NormalSkill = {"Normal Punch", "Consecutive Punches", "Shove", "Uppercut"},
                UltSkill = {"Death Counter", "Table Flip", "Serious Punch", "Omni Directional Punch"}
            }
        elseif BossP:FindFirstChild("Flowing Water") or BossP:FindFirstChild("The Final Hunt") then
            PackB = {
                Name = "Garou",
                NormalSkill = {"Flowing Water", "Lethal Whirlwind Stream", "Hunter's Grasp", "Prey's Peril"},
                UltSkill = {"Water Stream Cutting Fist", "The Final Hunt", "Rock Splitting Fist", "Crushed Rock"}
            }
        elseif BossP:FindFirstChild("Binding Cloth") or BossP:FindFirstChild("Hunter's Mark") then
            PackB = {
                Name = "DemonGarou",
                NormalSkill = {"Doom Dive", "Crowd Buster", "Hammer Heel", "Binding Cloth"},
                UltSkill = {"Hunter's Mark"}
            }
        elseif BossP:FindFirstChild("Head First") or BossP:FindFirstChild("Last Breath") then
            PackB = {
                Name = "Suiryu",
                NormalSkill = {"Bullet Barrage", "Vanishing Kick", "Whirlwind Drop", "Head First"},
                UltSkill = {"Grand Fissure", "Twin Fangs", "Earth Splitting Strike", "Last Breath"}
            }
        elseif BossP:FindFirstChild("Jet Dive") or BossP:FindFirstChild("Thunder Kick") then
            PackB = {
                Name = "Genos",
                NormalSkill = {"Machien Gun Blows", "Ignition Burst", "Blitz Shot", "Jet Dive"},
                UltSkill = {"Thunder Kick", "Speedblitz Dropkick", "Flamewave Cannon", "Incinerate"}
            }
        elseif BossP:FindFirstChild("Quick Slice") or BossP:FindFirstChild("Sunset") then
            PackB = {
                Name = "Atomic Samurai",
                NormalSkill = {"Quick Slice", "Atmos Cleave", "Pinpoint Cut", "Split Second Counter"},
                UltSkill = {"Sunset", "Solar Cleave", "Sunrise", "Atomic Slash"}
            }
        elseif BossP:FindFirstChild("Flash Strike") or BossP:FindFirstChild("Straight On") then
            PackB = {
                Name = "Sonic",
                NormalSkill = {"Flash Strike", "Whirlwind Kick", "Scatter", "Explosive Shuriken"},
                UltSkill = {"Twinblade Rush", "Straight On", "Carnage", "Fourfold Flashstrike"}
            }
        elseif BossP:FindFirstChild("Homerun") or BossP:FindFirstChild("Death Blow") then
            PackB = {
                Name = "Metal Bat",
                NormalSkill = {"Homerun", "Breakdown", "Grand Slam", "Foul Ball"},
                UltSkill = {"Savage Tornado", "Brutal Beatdown", "Strength Difference", "Death Blow"}
            }
        end
    end
end)

local ClosectPlrFromBoss
local function FindClosectPlayer()
    if TargetCon == true then return end
    print("Targetcon")
    if not RootB then return end
    print("Condition true")
    local MaxDir = 150
    local RangeAngle = 20
    local PreviousDistance = math.huge
    local ClosePlr = nil
    print("Variable")

    for _, P in pairs(game.workspace:FindFirstChild("Live"):GetChildren()) do
        if P ~= CharB and P ~= Char then
            RootP = P:FindFirstChild("HumanoidRootPart")
            if Root and RootP then
                local Distance = (RootP.Position - RootB.Position).Magnitude
                local Unit = (RootP.Position - RootB.Position).Unit
                local Dot = Root.CFrame.LookVector:Dot(Unit)
                local Angle = math.deg(math.acos(Dot))
                if Distance < PreviousDistance and Distance <= MaxDir and Angle <= RangeAngle then
                    PreviousDistance = Distance
                    ClosePlr = Plrs:GetPlayerFromCharacter(P)
                end
            end
        end
    end
    print("Loop yes")

    if ClosePlr and Flags[ClosePlr][Stm] == false then
        ClosectPlrFromBoss = ClosePlr
        CharCPFB = ClosectPlrFromBoss.Character
        RootCPFB = CharCPFB:WaitForChild("HumanoidRootPart")
        CloseCon = true
    elseif not ClosePlr or Flags[ClosePlr][Stm] == true then
        CloseCon = false
    end
    print("Find Closect")
    print("Done")
end

-------------- TweenInfo ---------------------------------------
local tsInfo1 = TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, 0)
local tsInfo2 = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, 0)

---------------------------- MAIN ------------------------------
-- Edit trees ----------
rs.Heartbeat:Connect(function()
    for _, tree in pairs(Map.Trees:GetChildren()) do
        tree.Tree:WaitForChild("TreeRoot").Transparency = 0.85
        tree.Tree:WaitForChild("TreeRoot").CanCollide = false
        tree.Tree:WaitForChild("TreeRoot").CanQuery = false
        for _, t in pairs(tree.Tree:GetChildren()) do
            if t.Name == "MeshPart" then
                t.Transparency = 1
                t.CanCollide = false
                t.CanQuery = false
                t.CanTouch = false
            end
        end
    end
end)

-- Target Highlight Update function --
local function TargetHlUpdate()
    if TargetHl and TargetHl:IsA("Highlight") then
        TargetHl:Destroy()
        TargetHl = nil
    end

    if Target:IsA("Player") then
        TargetHl = Instance.new("Highlight", CharT)
        TargetHl.Name = Target.Name .. "TargetHighlight"
        TargetHl.OutlineColor = Color3.fromRGB(255, 0, 0)
        TargetHl.FillColor = Color3.fromRGB(255, 0, 0)
        TargetHl.OutlineTransparency = 0
        TargetHl.FillTransparency = 0.5
        TargetHl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    end
end

-- > -- Find Boss & Target -- < -----------------------------------
-- Stop function --
local function Stop()
    if Work and typeof(Work) == "RBXScriptConnection" then
        Work:Disconnect()
    end
    Work = nil
    if AttackEvent and typeof(AttackEvent) == "RBXScriptConnection" then
        AttackEvent:Disconnect()
    end
    AttackEvent = nil
    if ShowPlrHl and ShowPlrHl:IsA("Highlight") then
        ShowPlrHl:Destroy()
    end
    ShowPlrHl = nil

    Hum:SetStateEnabled(Enum.HumanoidStateType.Freefall, true)
    Hum:SetStateEnabled(Enum.HumanoidStateType.Running, true)
    Hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, true)
    Hum:SetStateEnabled(Enum.HumanoidStateType.Climbing, true)
    game.workspace.Gravity = 196.2
    if CamEvent1 and typeof(CamEvent1) == "RBXScriptConnection" then
        CamEvent1:Disconnect()
    end
    cam.CameraType = Enum.CameraType.Custom   
    ConWork = false
    AttackCon = false
end

local function Working()
    Hum:SetStateEnabled(Enum.HumanoidStateType.Freefall, false)
    Hum:SetStateEnabled(Enum.HumanoidStateType.Running, false)
    Hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
    Hum:SetStateEnabled(Enum.HumanoidStateType.Climbing, false)
    game.workspace.Gravity = 0
    Hum.WalkSpeed = 0
    print("Hum")
    --cam.CameraType = Enum.CameraType.Scriptable
    print("Connection")
    Work = rs.RenderStepped:Connect(function()
        local look = RootB.CFrame.LookVector
        look = Vector3.new(look.X, 0, look.Z).Unit
        local orgcf = RootB.Position - look * 6 + Vector3.new(0, 5, 0) + RootB.CFrame.RightVector * 4
        local FrameB = CFrame.lookAt(orgcf, orgcf + look, Vector3.yAxis)
        Root.CFrame = Root.CFrame:Lerp(FrameB, 0.5)
        --local orgcam = RootB.Position - look * 50 + Vector3.new(0, 40, 0)
        --cam.CFrame = CFrame.lookAt(orgcam, RootB.Position)
        Hum.WalkSpeed = 0
    end)
    --cam.CameraSubject = Boss.Character or Boss.CharacterAdded:Wait()
    -- CamEvent1 = workspace.CurrentCamera:GetPropertyChangedSignal("CameraSubject"):Connect(function()
    --     cam.CameraSubject = Boss.Character or Boss.CharacterAdded:Wait()
    -- end)
    ConWork = true
    print("yes")
end

-- AttackEvent --
-- > Work
local function AttackEventWorking()
    AttackEvent = rs.RenderStepped:Connect(function()
        if ConWork == true and AttackCon == true then
            local MousePos = Mouse.Hit.Position
            local PreviousDistance = math.huge
            local ClosePlr = nil

            for _, P in pairs(Plrs:GetPlayers()) do
                if ChoosenBossCon == false then
                    if P ~= Boss and P ~= Plr then
                        CharP = P.Character or P.CharacterAdded:Wait()
                        RootP = CharP:FindFirstChild("HumanoidRootPart")
                        if Root and RootP then
                            local Distance = (Root.Position - RootP.Position).Magnitude
                            if Distance < PreviousDistance then
                                PreviousDistance = Distance
                                ClosePlr = P
                            end
                        end
                    end
                else
                    if P ~= Plr then
                        CharP = P.Character or P.CharacterAdded:Wait()
                        RootP = CharP:FindFirstChild("HumanoidRootPart")
                        if Root and RootP then
                            local Distance = (Root.Position - RootP.Position).Magnitude
                            if Distance < PreviousDistance then
                                PreviousDistance = Distance
                                ClosePlr = P
                            end
                        end
                    end
                end
            end

            local CharClosePlr = ClosePlr.Character or ClosePlr.CharacterAdded:Wait()
            local RootClosePlr = CharClosePlr:WaitForChild("HumanoidRootPart")
            -- Edit player dir --
            local dir = (RootClosePlr.Position - Root.Position).Unit
            local look = Vector3.new(dir.X, 0, dir.Z).Unit
            local OrgCF = MousePos - look + Vector3.new(0, 3, 0)
            Root.CFrame = CFrame.lookAt(OrgCF, OrgCF + look, Vector3.yAxis)
            -- Show Close Plr info --

            if ClosePlr ~= PreviousClosePlr then
                if ShowPlrHl and ShowPlrHl:IsA("Highlight") then
                    ShowPlrHl:Destroy()
                end
                
                if ClosePlr ~= Target then
                    ShowPlrHl = Instance.new("Highlight", CharClosePlr)
                    ShowPlrHl.Name = "ShowPlayerHighlight"
                    ShowPlrHl.OutlineColor = Color3.fromRGB(0, 255, 0)
                    ShowPlrHl.OutlineColor = Color3.fromRGB(0, 255, 0)
                    ShowPlrHl.OutlineTransparency = 0
                    ShowPlrHl.FillTransparency = 0.7
                    ShowPlrHl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    ShowPlrHl.Adornee = CharClosePlr

                    PreviousClosePlr = ClosePlr
                end
            end
        end
    end)
end

-- > Stop
local function AttackEventStop()
    if AttackEvent and typeof(AttackEvent) == "RBXScriptConnection" then
        AttackEvent:Disconnect()
    end
    if ShowPlrHl and ShowPlrHl:IsA("Highlight") then
        ShowPlrHl:Destroy()
    end
    if CamEvent1 and typeof(CamEvent1) == "RBXScriptConnection" then
        CamEvent1:Disconnect()
    end
    Working()
    Root.CFrame = OrgCFrame
    cam.CameraType = Enum.CameraType.Custom
end

-- Input from Boss --
local function InputFromBoss()
    repeat task.wait() until LiveB
    HoldingM1Event = LiveB:GetAttributeChangedSignal("HoldingM1"):Connect(function()
        FindClosectPlayer()
        if TrashLoop == false and CloseCon == true then
            if ClosectPlrFromBoss and ConWork == true and AttackCon == false and FindTargetCon == false then
                if TargetCon == false and TargetInputM1Con == false and Ragdoll == false and (LiveB:GetAttribute("Blocking") == true or LiveB:FindFirstChild("Ragdoll") or LiveB:FindFirstChild("Freeze")) and LiveB:GetAttribute("HoldingM1") == true then
                    TargetCon = true
                    TargetInputM1Con = true
                    if Work and typeof(Work) == "RBXScriptConnection" then
                        Work:Disconnect()
                    end
                    TargetInputM1Event = rs.RenderStepped:Connect(function()
                        local look = RootCPFB.CFrame.LookVector
                        look = Vector3.new(look.X, 0, look.Z).Unit
                        local orgcf = RootCPFB.Position - look * 1
                        local FrameB = CFrame.lookAt(orgcf, orgcf + look, Vector3.yAxis)
                        Root.CFrame = Root.CFrame:Lerp(FrameB, 0.5)
                    end)
                    local ScreenSize = cam.ViewportSize
                    local CenterX = ScreenSize.X / 2; local CenterY = ScreenSize.Y / 2
                    vim:SendMouseButtonEvent(CenterX, CenterY, 0, true, game, 0)
                elseif TargetInputM1Con == true and(LiveB:GetAttribute("Blocking") == false or LiveB:GetAttribute("HoldingM1") == false) then
                    local ScreenSize = cam.ViewportSize
                    local CenterX = ScreenSize.X / 2; local CenterY = ScreenSize.Y / 2
                    vim:SendMouseButtonEvent(CenterX, CenterY, 0, false, game, 0)
                    repeat task.wait() until M1ing == false
                    if TargetInputM1Event and typeof(TargetInputM1Event) == "RBXScriptConnection" then
                        TargetInputM1Event:Disconnect()
                    end
                    Working()
                    TargetCon = false
                    TargetInputM1Con = false
                end
            end
        end
    end)

    PackBEvent = Boss.Backpack.ChildAdded:Connect(function(Child)
        FindClosectPlayer()
        for i, Skill in ipairs(Boss.Backpack:GetChildren()) do
            if Child.Name == Skill.Name and (LiveB:GetAttribute("Blocking") == true or LiveB:FindFirstChild("Ragdoll") or LiveB:FindFirstChild("Freeze")) and CloseCon == true then
                if Skill.Name == PackB.NormalSkill[1] or Skill.Name == PackB.UltSkill[1] then
                    if TrashLoop == false and TargetCon == false and Ragdoll == false then
                        if ClosectPlrFromBoss and ConWork == true and AttackCon == false and FindTargetCon == false and OnCooldown.Skill1[2] == false then
                            TargetCon = true
                            if Work and typeof(Work) == "RBXScriptConnection" then
                                Work:Disconnect()
                            end
                            TargetInputSkill1Event = rs.RenderStepped:Connect(function()
                                local look = RootCPFB.CFrame.LookVector
                                look = Vector3.new(look.X, 0, look.Z).Unit
                                local orgcf = RootCPFB.Position - look * 12
                                local FrameB = CFrame.lookAt(orgcf, orgcf + look, Vector3.yAxis)
                                Root.CFrame = Root.CFrame:Lerp(FrameB, 0.5)
                            end)
                            task.wait(0.35)
                            vim:SendKeyEvent(true, Enum.KeyCode.One, false, game); vim:SendKeyEvent(false, Enum.KeyCode.One, false, game)
                            task.wait(0.2)
                            if TargetInputSkill1Event and typeof(TargetInputSkill1Event) == "RBXScriptConnection" then
                                TargetInputSkill1Event:Disconnect()
                                BossInputSkill1Event = rs.RenderStepped:Connect(function()
                                    local look = RootB.CFrame.LookVector
                                    look = Vector3.new(look.X, 0, look.Z).Unit
                                    local orgcf = RootB.Position - look * -25
                                    local FrameB = CFrame.lookAt(orgcf, orgcf + look, Vector3.yAxis)
                                    Root.CFrame = Root.CFrame:Lerp(FrameB, 0.5)
                                end)
                                task.wait(1)
                                if BossInputSkill1Event and typeof(BossInputSkill1Event) == "RBXScriptConnection" then
                                    BossInputSkill1Event:Disconnect()
                                end
                            end
                            Working()
                            TargetCon = false
                        end
                    end

                elseif Skill.Name == PackB.NormalSkill[2] or Skill.Name == PackB.UltSkill[2] then
                    if TrashLoop == false and TargetCon == false and Ragdoll == false then
                        if ClosectPlrFromBoss and ConWork == true and AttackCon == false and FindTargetCon == false and OnCooldown.Skill2[2] == false then
                            TargetCon = true
                            if Work and typeof(Work) == "RBXScriptConnection" then
                                Work:Disconnect()
                            end
                            TargetInputSkill2Event = rs.RenderStepped:Connect(function()
                                local look = RootCPFB.CFrame.LookVector
                                look = Vector3.new(look.X, 0, look.Z).Unit
                                local orgcf = RootCPFB.Position - look * 5
                                local FrameB = CFrame.lookAt(orgcf, orgcf + look, Vector3.yAxis)
                                Root.CFrame = Root.CFrame:Lerp(FrameB, 0.5)
                            end)
                            vim:SendKeyEvent(true, Enum.KeyCode.Two, false, game); vim:SendKeyEvent(false, Enum.KeyCode.Two, false, game)
                            task.wait(1)
                            if TargetInputSkill2Event and typeof(TargetInputSkill2Event) == "RBXScriptConnection" then
                                TargetInputSkill2Event:Disconnect()
                            end
                            Working()
                            TargetCon = false
                        end
                    end

                elseif Skill.Name == PackB.NormalSkill[3] or Skill.Name == PackB.UltSkill[3] then
                    if TrashLoop == false and TargetCon == false and Ragdoll == false then
                        if ClosectPlrFromBoss and ConWork == true and AttackCon == false and FindTargetCon == false and OnCooldown.Skill3[2] == false then
                            TargetCon = true
                            if Work and typeof(Work) == "RBXScriptConnection" then
                                Work:Disconnect()
                            end
                            TargetInputSkill3Event = rs.RenderStepped:Connect(function()
                                local look = RootCPFB.CFrame.LookVector
                                look = Vector3.new(look.X, 0, look.Z).Unit
                                local orgcf = RootCPFB.Position - look * 15
                                local FrameB = CFrame.lookAt(orgcf, orgcf + look, Vector3.yAxis)
                                Root.CFrame = Root.CFrame:Lerp(FrameB, 0.5)
                            end)
                            task.wait(0.2)
                            vim:SendKeyEvent(true, Enum.KeyCode.Three, false, game); vim:SendKeyEvent(false, Enum.KeyCode.Three, false, game)
                            task.wait(0.5)
                            if TargetInputSkill3Event and typeof(TargetInputSkill3Event) == "RBXScriptConnection" then
                                TargetInputSkill3Event:Disconnect()
                            end
                            Working()
                            TargetCon = false
                        end
                    end
            
                elseif Skill.Name == PackB.NormalSkill[4] or Skill.Name == PackB.UltSkill[4] then
                    if TrashLoop == false and TargetCon == false and Ragdoll == false then
                        if ClosectPlrFromBoss and ConWork == true and AttackCon == false and FindTargetCon == false and OnCooldown.Skill4[2] == false then
                            TargetCon = true
                            if Work and typeof(Work) == "RBXScriptConnection" then
                                Work:Disconnect()
                            end
                            vim:SendKeyEvent(true, Enum.KeyCode.Four, false, game); vim:SendKeyEvent(false, Enum.KeyCode.Four, false, game); task.wait(0.65); vim:SendKeyEvent(true, Enum.KeyCode.Four, false, game); vim:SendKeyEvent(false, Enum.KeyCode.Four, false, game); print("Key sended"); task.wait(0.35)
                            TargetInputSkill4Event = rs.RenderStepped:Connect(function()
                                local look = RootCPFB.CFrame.LookVector
                                look = Vector3.new(look.X, 0, look.Z).Unit
                                local orgcf = RootCPFB.Position - look * 3
                                local FrameB = CFrame.lookAt(orgcf, orgcf + look, Vector3.yAxis)
                                Root.CFrame = Root.CFrame:Lerp(FrameB, 0.5)
                            end)
                            task.wait(1)
                            if TargetInputSkill4Event and typeof(TargetInputSkill4Event) == "RBXScriptConnection" then
                                TargetInputSkill4Event:Disconnect()
                            end
                            Working()
                            TargetCon = false
                        end
                    end
                end
            end
        end
    end)
end

-- Player Removing Event --
Plrs.PlayerRemoving:Connect(function(P)
    if P == Boss then
        if InputB:IsA("TextBox") then
            InputB.Text = Boss.Name .. " lefts the game"
        else
            repeat task.wait(0.1) until InputB:IsA("TextBox")
            InputB.Text = Boss.Name .. " lefts the game"
        end
        if typeof(Work) == "RBXScriptConnection" then
            Work:Disconnect()
        end
        if TargetM1Event and typeof(TargetM1Event) == "RBXScriptConnection" then
            TargetM1Event:Disconnect()
        end
        TargetCon = false
        Stop()
        Boss = nil
        CharB = nil
        RootB = nil
        HumB = nil
        LiveB = nil
    elseif P == Target then
        if InputT:IsA("TextBox") then
            InputT.Text = Target.Name .. " lefts the game"
        else
            repeat task.wait(0.1) until InputT:IsA("TextBox")
            InputT.Text = Target.Name .. " lefts the game"
        end
        Target = nil
        CharT = nil
        RootT = nil
        HumT = nil
        LiveT = nil
    end
end)

-- Create Input Function --
local function CreateUI()
    Gui = Instance.new("ScreenGui", Plr:WaitForChild("PlayerGui"))
    InputB = Instance.new("TextBox", Gui)
    InputB.Name = "InputBoss"
    InputB.Size = UDim2.new(0.15, 0, 0.05, 0)
    InputB.Position = UDim2.new(0.275, 0, 0.1, 0)
    InputB.AnchorPoint = Vector2.new(0.5, 0.5)
    InputB.TextScaled = true
    InputB.PlaceholderText = "Boss Input"
    InputT = InputB:Clone()
    InputT.Name = "InputTarget"
    InputT.Parent = Gui
    InputT.Position = UDim2.new(0.11, 0, 0.1, 0)
    InputT.PlaceholderText = "Target Input"
    -- Input Event --
    InputT.FocusLost:Connect(function(ep)
        if ep then
            local match = {}
            for _, i in pairs(Plrs:GetPlayers()) do
                if i.Name:sub(1, #InputT.Text):lower() == InputT.Text:lower() then
                    table.insert(match, i)
                end
            end

            if #match == 1 then
                if match[1] ~= Boss then
                    warn("\n\nFinding Target")
                    Target = match[1]
                    CharT = Target.Character or Target.CharacterAdded:Wait()
                    print("Got CharT")
                    RootT = CharT:WaitForChild("HumanoidRootPart")
                    print("Got RootT")
                    HumT = CharT:WaitForChild("Humanoid")
                    print("Got HumT")
                    LiveT = game.workspace.Live:WaitForChild(Target.Name)
                    InputT.Text = Target.Name
                    print("Got LiveT")
                    warn("Success")
                    TargetHlUpdate()

                    -- Died Event --
                    Target.CharacterAdded:Connect(function()
                        CharT = Target.Character or Target.CharacterAdded:Wait()
                        RootT = CharT:WaitForChild("HumanoidRootPart")
                        HumT = CharT:WaitForChild("Humanoid")
                        LiveT = game.workspace.Live:WaitForChild(Target.Name)
                        InputT.Text = Target.Name
                        TargetHlUpdate()
                    end)

                else
                    InputT.Text = "Target cant same as Boss"
                end
            else
                InputT.Text = "Player doesn't invalid"
            end
        end
    end)

    InputB.FocusLost:Connect(function(ep)
        if ep then
            local match = {}
            for _, i in pairs(Plrs:GetPlayers()) do
                if i.Name:sub(1, #InputB.Text):lower() == InputB.Text:lower() then
                    table.insert(match, i)
                end
            end

            if #match == 1 then
                if match[1] ~= Target then
                    warn("\n\nFinding Boss")
                    Boss = match[1]
                    CharB = Boss.Character or Boss.CharacterAdded:Wait()
                    print("Got CharB")
                    RootB = CharB:WaitForChild("HumanoidRootPart")
                    print("Got RootB")
                    HumB = CharB:WaitForChild("Humanoid")
                    print("Got HumB")
                    LiveB = game.workspace.Live:WaitForChild(Boss.Name)
                    print("Got LiveB")
                    InputB.Text = Boss.Name
                    warn("Success")
                    OldBoss = CharB

                    -- CharacterAdded Event --
                    Boss.CharacterAdded:Connect(function()
                        CharB = Boss.Character or Boss.CharacterAdded:Wait()
                        RootB = CharB:WaitForChild("HumanoidRootPart")
                        HumB = CharB:WaitForChild("Humanoid")
                        LiveB = game.workspace.Live:WaitForChild(Boss.Name)
                        InputB.Text = Boss.Name
                        InputFromBoss()
                    end)
                else
                    InputB.Text = "Boss cant same as Target"
                end
            else
                InputB.Text = "Player doesn't invalid"
            end
        end
    end)
end
CreateUI()

-- Local Player Die Event --
Plr.CharacterAdded:Connect(function()
    if AttackEvent and typeof(AttackEvent) == "RBXScriptConnection" then
        AttackEvent:Disconnect()
    end
    
    Char = Plr.Character or Plr.CharacterAdded:Wait()
    Hum = Char:WaitForChild("Humanoid")
    Root = Char:WaitForChild("HumanoidRootPart")
    Hotbar = Plr:WaitForChild("PlayerGui"):FindFirstChild("Hotbar").Backpack.Hotbar
    CreateUI()
    if Boss and Boss:IsA("Player") then
        InputB.Text = Boss.Name
    end
    if Target and Target:IsA("Player") then
        InputT.Text = Target.Name
    end
    if not Work then
        Working()
    end
end)

-- Dummy Added Event --
-- game.workspace.Live.ChildAdded:Connect(function(child)
--     if child.Name == "Weakest Dummy" then
--         Dummy = game.workspace.Live:WaitForChild("Weakest Dummy")
--         RootD = Dummy:WaitForChild("HumanoidRootPart")
--         HumD = Dummy:WaitForChild("Humanoid")
--     end
-- end)

-- Check Saitama Ult --
local function CheckDeathCounter()
    for _, P in pairs(Plrs:GetPlayers()) do
        if not Flags[P] then
            Flags[P] = {Stm = false, Dc = false}
        end
        local State = Flags[P]

        local LiveP = game.workspace.Live:FindFirstChild(P.Name)
        if not LiveP then continue end
        local HeadP = LiveP:FindFirstChild("Head")
        if not HeadP then continue end

        if P.Backpack:FindFirstChild("Death Counter") and State.Stm == false then
            if not HeadP:FindFirstChild("SaitamaUltBillboardGui") then
                local SaitamaUltBBG = Instance.new("BillboardGui", HeadP)
                SaitamaUltBBG.Name = "SaitamaUltBillboardGui"
                SaitamaUltBBG.AlwaysOnTop = true
                SaitamaUltBBG.StudsOffset = Vector3.new(0, 2, 0)
                SaitamaUltBBG.Size = UDim2.new(0, 100, 0, 25)
                SaitamaUltBBG.Adornee = HeadP
                -------------------------------------------
                local SaitamaUltTL = Instance.new("TextLabel", SaitamaUltBBG)
                SaitamaUltTL.Name = "SaitamaUltTextLabel"
                SaitamaUltTL.Size = UDim2.new(1,0,1,0)
                SaitamaUltTL.Text = "SaitamaUlt"
                SaitamaUltTL.TextColor3 = Color3.fromRGB(255, 0, 0)
                SaitamaUltTL.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
                SaitamaUltTL.TextStrokeTransparency = 0
                SaitamaUltTL.TextScaled = true
                SaitamaUltTL.BackgroundTransparency = 1
                State.Stm = true
            end
        end

        if LiveP:FindFirstChild("Counter") and State.Stm == true and State.Dc == false then
            if HeadP:FindFirstChild("SaitamaUltBillboardGui") then
                local SaitamaUltBBG = HeadP:FindFirstChild("SaitamaUltBillboardGui")
                local SaitamaUltTL = SaitamaUltBBG:FindFirstChild("SaitamaUltTextLabel")
                SaitamaUltTL.Text = "Death Counter"
                State.Dc = true
            end
        end

        if not P.Backpack:FindFirstChild("Death Counter") and State.Stm == true and State.Dc == false then
            if HeadP:FindFirstChild("SaitamaUltBillboardGui") then
                HeadP:FindFirstChild("SaitamaUltBillboardGui"):FindFirstChild("SaitamaUltTextLabel"):Destroy(); HeadP:FindFirstChild("SaitamaUltBillboardGui"):Destroy()
                State.Stm = false; State.Dc = false
            end
        elseif not P.Backpack:FindFirstChild("Death Counter") and State.Stm == true and State.Dc == true then
            if not LiveP:FindFirstChild("Counter") then
                if HeadP:FindFirstChild("SaitamaUltBillboardGui") then
                    HeadP:FindFirstChild("SaitamaUltBillboardGui"):FindFirstChild("SaitamaUltTextLabel"):Destroy(); HeadP:FindFirstChild("SaitamaUltBillboardGui"):Destroy()
                    State.Stm = false; State.Dc = false
                end
            end
        end
    end
end

rs.RenderStepped:Connect(function()
    CheckDeathCounter()
end)

-- Player Trash Handle Checking --
rs.RenderStepped:Connect(function()
    if Live:FindFirstChild("Trash Can") and TrashHandle == false then
        TrashHandle = true
    elseif not Live:FindFirstChild("Trash Can") and TrashHandle == true then
        TrashHandle = false
    end
end)

-- Player Health Checking --
Hum.HealthChanged:Connect(function(N)
    if N <= Hum.Health * 0.25 then
        if ConWork == true then
            repeat task.wait() until TargetCon == false
            if Work and typeof(Work) == "RBXScriptConnection" then
                Stop()
            end
            if AttackEvent and typeof(AttackEvent) == "RBXScriptConnection" then
                AttackEventStop()
            end
            root.CFrame = CFrame.new(999999, -490, 99999)
        end
    end
end)

-- Other --
rs.RenderStepped:Connect(function()
    if Live:FindFirstChild("M1ing") and M1ing == false then
        M1ing = true
    elseif not Live:FindFirstChild("M1ing") and M1ing == true then
        M1ing = false
    end
end)
rs.RenderStepped:Connect(function()
    for i, Skill in pairs(OnCooldown) do
        repeat task.wait() until Hotbar
        if not Hotbar:FindFirstChild(Skill[1]).Base then return end
        local SN = Hotbar:FindFirstChild(Skill[1]).Base
        if SN then
            if Skill[2] == false and SN:FindFirstChild("Cooldown") then
                Skill[2] = true
            elseif Skill[2] == true and not SN:FindFirstChild("Cooldown") then
                Skill[2] = false
            end
        end
    end
end)
rs.RenderStepped:Connect(function()
    if Live:FindFirstChild("Ragdoll") or Live:FindFirstChild("RagdollSim") and Ragdoll == false then
        Ragdoll = true
    elseif not Live:FindFirstChild("Ragdoll") and not Live:FindFirstChild("RagdollSim") and Ragdoll == true then
        Ragdoll = false
    end
end)

--------------------- Working ---------------------------------------

-- THP Table --
local KeyDown = {
    Control = false,
    LeftShift = false,
}

-- Input Process --
uis.InputBegan:Connect(function(KC, GP)
    if GP then return end
    local input = KC.KeyCode

    -- THP Checking --
    if input == Enum.KeyCode.LeftControl then
        KeyDown.Control = true
    elseif input == Enum.KeyCode.LeftShift then
        KeyDown.LeftShift = true
    end

    if input == Enum.KeyCode.Y and AttackCon == false and TrashCon == false then
        FindTargetCon = not FindTargetCon
        if FindTargetCon == true then
            FindTargetRS = rs.RenderStepped:Connect(function()
                -- Get Mouse Vector3 Location --
                local MouseLocation = uis:GetMouseLocation()
                local Ray = cam:ViewportPointToRay(MouseLocation.X, MouseLocation.Y)
                local RayOrg = Ray.Origin
                local RayDir = Ray.Direction * 1000
                local RayParams = RaycastParams.new()
                RayParams.FilterType = Enum.RaycastFilterType.Exclude
                RayParams.FilterDescendantsInstances = {Char}
                local Result = workspace:Raycast(RayOrg, RayDir, RayParams)
                -- If Instance is a player --
                if (Result and Result.Instance) and (Result.Instance.Parent:FindFirstChild("Humanoid") and ChoosenHl == nil and Result.Instance.Parent ~= Char and Result.Instance.Parent.Name ~= "Weakest Dummy") then
                    ChoosenChar = Result.Instance.Parent
                    ChoosenHl = Instance.new("Highlight", ChoosenChar)
                    ChoosenHl.Name = ChoosenChar.Name .. "ChoosenHighlight"
                    ChoosenHl.OutlineColor = Color3.fromRGB(255, 255, 255)
                    ChoosenHl.FillColor = Color3.fromRGB(255, 255, 255)
                    ChoosenHl.OutlineTransparency = 0
                    ChoosenHl.FillTransparency = 0.7
                    ChoosenHl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                elseif (not Result and not Result.Instance) or (not Result.Instance.Parent:FindFirstChild("Humanoid") and ChoosenHl ~= nil) then
                    if ChoosenHl:IsA("Highlight") then
                        ChoosenHl:Destroy()
                        ChoosenHl = nil
                        ChoosenChar = nil
                    end
                end
            end)

        else
            FindTargetRS:Disconnect()
            if ChoosenHl:IsA("Highlight") then
                ChoosenHl:Destroy()
                ChoosenHl = nil
                ChoosenChar = nil
            end
        end
    end

    if KC.UserInputType == Enum.UserInputType.MouseButton1 and ChoosenHl ~= nil then
        if ChoosenChar ~= CharB then
            warn("\n\nFinding Target...")
            Target = Plrs:GetPlayerFromCharacter(ChoosenChar)
            print("Got Target")
            CharT = ChoosenChar
            print("Got CharT")
            RootT = CharT:WaitForChild("HumanoidRootPart")
            print("Got RootT")
            HumT = CharT:WaitForChild("Humanoid")
            print("Got HumT")
            LiveT = game.workspace.Live:WaitForChild(Target.Name)
            print("Got LiveT")
            warn("Success")
            if ChoosenHl:IsA("Highlight") then
                FindTargetCon = false
                FindTargetRS:Disconnect()
                ChoosenHl:Destroy()
                ChoosenHl = nil
                ChoosenChar = nil
            else
                warn("There's no highlight")
            end
            -- Edit Text Box --
            if InputT:IsA("TextBox") then
                InputT.Text = Target.Name
            end
            TargetHlUpdate()
        else
            InputT.Text = "Target cant same as Boss"
        end
    end

    -------------> Turn on <--------------------------------------------------
    if input == Enum.KeyCode.E and KeyDown.Control == true then
        print("Ctr e")
        ConWork = not ConWork
        -- Working --
        if ConWork == true then
            print("Conwork")
            InputFromBoss()
            print("Input")
            Working()
            print("Working")
        -- Not Working --
        else
            Stop()
            cam.CameraType = Enum.CameraType.Custom
        end
    end
    -- Normal Attack --
    if input == Enum.KeyCode.V and ConWork == true and KeyDown.Control == false and TrashCon == false then
        AttackCon = not AttackCon
        if AttackCon == true then
            if Work and typeof(Work) == "RBXScriptConnection" then
                Work:Disconnect()
            end
            cam.CameraSubject = Boss.Character or Boss.CharacterAdded:Wait()
            CamEvent1 = workspace.CurrentCamera:GetPropertyChangedSignal("CameraSubject"):Connect(function()
                cam.CameraSubject = Boss.Character or Boss.CharacterAdded:Wait()
            end)
            OrgCFrame = Root.CFrame
            AttackEventWorking()
        else
            AttackEventStop()
        end
    end

    if ConWork == true and AttackCon == true and input == Enum.KeyCode.V and KeyDown.Control == true and TrashCon == false then
        ChoosenBossCon = not ChoosenBossCon
    end

    -- Trashcan --
    -- if input == Enum.KeyCode.H then
    --     local OrgFrame = Root.CFrame
    --     for _, Child in pairs(Map.Trash:GetChildren()) do
    --         local Trash = Child.Trashcan
    --         if TrashCon == false and TrashHandle == false and Trash.CanCollide == true and TargetCon == false then
    --             TrashCon = true
    --             TrashLoop = true
    --             if AttackEvent and typeof(AttackEvent) == "RBXScriptConnection" then
    --                 AttackEvent:Disconnect()
    --             end
    --             if ChoosenHl and ChoosenHl:IsA("Highlight") then
    --                 ChoosenHl:Destroy()
    --             end
    --             if Work and typeof(Work) == "RBXScriptConnection" then
    --                 Work:Disconnect()
    --             end
    --             TargetCon = false
    --             if TargetM1Event and typeof(TargetM1Event) == "RBXScriptConnection" then
    --                 TargetM1Event:Disconnect()
    --             end

    --             task.spawn(function()
    --                 while TrashLoop == true do
    --                     Root.CFrame = CFrame.lookAt(Trash.CFrame.Position + Vector3.new(0, 0, -3), Trash.CFrame.Position)
    --                     task.wait(0.05)
    --                 end
    --             end)
    --             task.spawn(function()
    --                 while TrashLoop == true do   
    --                     task.wait(0.2)
    --                     vim:SendMouseButtonEvent(500, 300, 0, true, game, 0); task.wait(); vim:SendMouseButtonEvent(500, 300, 0, false, game, 0)
    --                     task.wait(0.3)
    --                 end
    --             end)
    --             repeat task.wait() until TrashHandle == true
    --             TrashLoop = false
                
    --             if AttackCon == true then
    --                 AttackEventWorking()
    --                 Root.CFrame = OrgFrame
    --             elseif ConWork == true and AttackCon == false then
    --                 Working()
    --             elseif ConWork == false then
    --                 Root.CFrame = OrgFrame
    --             end

    --             repeat task.wait() until not Live:FindFirstChild("M1ing")
    --             TrashCon = false
    --             break
    --         end
    --     end
    -- end

    ------> Target Input <-------
    if TrashLoop == false and TargetCon == false and Ragdoll == false then
        if Target and ConWork == true and AttackCon == false and FindTargetCon == false then

            if KC.UserInputType == Enum.UserInputType.MouseButton1 then
                TargetCon = true
                if Work and typeof(Work) == "RBXScriptConnection" then
                    Work:Disconnect()
                end
                TargetM1Event = rs.RenderStepped:Connect(function()
                    local look = RootT.CFrame.LookVector
                    look = Vector3.new(look.X, 0, look.Z).Unit
                    local orgcf = RootT.Position - look * 1
                    local FrameB = CFrame.lookAt(orgcf, orgcf + look, Vector3.yAxis)
                    Root.CFrame = Root.CFrame:Lerp(FrameB, 0.5)
                    if LiveT:FindFirstChild("Counter") then
                        TargetM1Event:Disconnect()
                    end
                end)
            
            elseif input == Enum.KeyCode.W and OnCooldown.Skill1[2] == false then
                TargetCon = true
                if Work and typeof(Work) == "RBXScriptConnection" then
                    Work:Disconnect()
                end
                TargetSkill1Event = rs.RenderStepped:Connect(function()
                    local look = RootT.CFrame.LookVector
                    look = Vector3.new(look.X, 0, look.Z).Unit
                    local orgcf = RootT.Position - look * 12
                    local FrameB = CFrame.lookAt(orgcf, orgcf + look, Vector3.yAxis)
                    Root.CFrame = Root.CFrame:Lerp(FrameB, 0.5)
                end)
                task.wait(0.35)
                vim:SendKeyEvent(true, Enum.KeyCode.One, false, game); vim:SendKeyEvent(false, Enum.KeyCode.One, false, game)
                task.wait(0.2)
                if TargetSkill1Event and typeof(TargetSkill1Event) == "RBXScriptConnection" then
                    TargetSkill1Event:Disconnect()
                    BossSkill1Event = rs.RenderStepped:Connect(function()
                        local look = RootB.CFrame.LookVector
                        look = Vector3.new(look.X, 0, look.Z).Unit
                        local orgcf = RootB.Position - look * -25
                        local FrameB = CFrame.lookAt(orgcf, orgcf + look, Vector3.yAxis)
                        Root.CFrame = Root.CFrame:Lerp(FrameB, 0.5)
                    end)
                    task.wait(1)
                    if BossSkill1Event and typeof(BossSkill1Event) == "RBXScriptConnection" then
                        BossSkill1Event:Disconnect()
                    end
                end
                Working()
                TargetCon = false
            
            elseif input == Enum.KeyCode.E and KeyDown.Control == false and OnCooldown.Skill2[2] == false then
                TargetCon = true
                if Work and typeof(Work) == "RBXScriptConnection" then
                    Work:Disconnect()
                end
                TargetSkill2Event = rs.RenderStepped:Connect(function()
                    local look = RootT.CFrame.LookVector
                    look = Vector3.new(look.X, 0, look.Z).Unit
                    local orgcf = RootT.Position - look * 5
                    local FrameB = CFrame.lookAt(orgcf, orgcf + look, Vector3.yAxis)
                    Root.CFrame = Root.CFrame:Lerp(FrameB, 0.5)
                end)
                vim:SendKeyEvent(true, Enum.KeyCode.Two, false, game); vim:SendKeyEvent(false, Enum.KeyCode.Two, false, game)
                task.wait(1)
                if TargetSkill2Event and typeof(TargetSkill2Event) == "RBXScriptConnection" then
                    TargetSkill2Event:Disconnect()
                end
                Working()
                TargetCon = false
            
            elseif input == Enum.KeyCode.R and KeyDown.Control == false and OnCooldown.Skill3[2] == false then
                TargetCon = true
                if Work and typeof(Work) == "RBXScriptConnection" then
                    Work:Disconnect()
                end
                TargetSkill3Event = rs.RenderStepped:Connect(function()
                    local look = RootT.CFrame.LookVector
                    look = Vector3.new(look.X, 0, look.Z).Unit
                    local orgcf = RootT.Position - look * 15
                    local FrameB = CFrame.lookAt(orgcf, orgcf + look, Vector3.yAxis)
                    Root.CFrame = Root.CFrame:Lerp(FrameB, 0.5)
                end)
                task.wait(0.2)
                vim:SendKeyEvent(true, Enum.KeyCode.Three, false, game); vim:SendKeyEvent(false, Enum.KeyCode.Three, false, game)
                task.wait(0.5)
                if TargetSkill3Event and typeof(TargetSkill3Event) == "RBXScriptConnection" then
                    TargetSkill3Event:Disconnect()
                end
                Working()
                TargetCon = false
            
            elseif input == Enum.KeyCode.T and KeyDown.Control == false and OnCooldown.Skill4[2] == false then
                TargetCon = true
                if Work and typeof(Work) == "RBXScriptConnection" then
                    Work:Disconnect()
                end
                vim:SendKeyEvent(true, Enum.KeyCode.Four, false, game); vim:SendKeyEvent(false, Enum.KeyCode.Four, false, game); task.wait(0.65); vim:SendKeyEvent(true, Enum.KeyCode.Four, false, game); vim:SendKeyEvent(false, Enum.KeyCode.Four, false, game); print("Key sended"); task.wait(0.35)
                TargetSkill4Event = rs.RenderStepped:Connect(function()
                    local look = RootT.CFrame.LookVector
                    look = Vector3.new(look.X, 0, look.Z).Unit
                    local orgcf = RootT.Position - look * 3
                    local FrameB = CFrame.lookAt(orgcf, orgcf + look, Vector3.yAxis)
                    Root.CFrame = Root.CFrame:Lerp(FrameB, 0.5)
                end)
                task.wait(1)
                if TargetSkill4Event and typeof(TargetSkill4Event) == "RBXScriptConnection" then
                    TargetSkill4Event:Disconnect()
                end
                Working()
                TargetCon = false
            end
        
        end
    end

end)

uis.InputEnded:Connect(function(KC, GP)
    if GP then return end
    local input = KC.KeyCode

    -- THP --
    if input == Enum.KeyCode.LeftControl then
        KeyDown.Control = false
    elseif input == Enum.KeyCode.LeftShift then
        KeyDown.LeftShift = false
    end

    if TrashLoop == false and TargetCon == true then
        if Target and ConWork == true and AttackCon == false and FindTargetCon == false then
            if KC.UserInputType == Enum.UserInputType.MouseButton1 then
                repeat task.wait() until M1ing == false
                if TargetM1Event and typeof(TargetM1Event) == "RBXScriptConnection" then
                    TargetM1Event:Disconnect()
                end
                Working()
                TargetCon = false
            end
        end
    end

end)

-- uis.InputChanged:Connect(function(input)
--     if input.UserInputType == Enum.UserInputType.MouseWheel then
--         if AttackCon == true then
--             local delta = input.Position.Z
--             local frame = Root.CFrame * CFrame.Angles(0, delta * 0.5, 0)
--             Root.CFrame = Root.CFrame:Lerp(frame, 0.5)
--         end
--     end
-- end)

-------------------------------------------------------------
warn("Finish!")
