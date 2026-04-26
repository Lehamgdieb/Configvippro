-- ==========================================
-- [0. HỆ THỐNG ANTI AFK & AUTO KHẮC PHỤC LỖI ROBLOX]
-- ==========================================
if not game:IsLoaded() then 
    game.Loaded:Wait() 
end

local Players = game:GetService("Players")
local player = Players.LocalPlayer
local VU = game:GetService("VirtualUser")
local GuiService = game:GetService("GuiService")
local CoreGui = game:GetService("CoreGui")

-- HÀM ANTI AFK CHÍNH CHỦ
player.Idled:Connect(function()
    VU:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    task.wait(1)
    VU:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
end)

-- TỰ ĐỘNG TẮT BẢNG LỖI TELEPORT FAILED (CHỐNG KẸT PHÍM E)
task.spawn(function()
    while task.wait(0.5) do
        pcall(function()
            local promptOverlay = CoreGui:FindFirstChild("RobloxPromptGui") and CoreGui.RobloxPromptGui:FindFirstChild("promptOverlay")
            if promptOverlay and promptOverlay:FindFirstChild("ErrorPrompt") then
                GuiService:ClearError()
            end
        end)
    end
end)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CommF = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("CommF_")

local function AutoJoinTeam()
    repeat task.wait(0.5)
        if player.Team == nil or player.Team.Name == "ChooseTeam" then
            pcall(function() 
                CommF:InvokeServer("SetTeam", "Marines") 
            end)
        end
    until player.Team ~= nil and player.Team.Name ~= "ChooseTeam"
end
AutoJoinTeam()

task.spawn(function()
    pcall(function() 
        local lod1 = player.PlayerScripts:WaitForChild('NewIslandLOD', 10)
        if lod1 then lod1:Destroy() end
        local lod2 = player.PlayerScripts:WaitForChild('IslandLOD', 10)
        if lod2 then lod2:Destroy() end
    end)
end)

repeat task.wait() until player.Character and player.Character:FindFirstChild("HumanoidRootPart")

-- ==========================================
-- [1. BIẾN HỆ THỐNG & TỌA ĐỘ]
-- ==========================================
_G.Auto_DualKatana = true
_G.TargetMastery = 350
_G.HeightFarm = 40
_G.AutoFarm_Bone = false
_G.BringMob = true
_G.IsHopping = false
_G.LastHopTime = 0 
_G.CurrentSword = "Tushita" -- Chuyển ưu tiên sang Tushita
_G.IsTakingDamage = false 
_G.IsResetting = false

local Pos = CFrame.new(0, _G.HeightFarm, 0)

local API_SOUL_REAPER = "http://14.174.145.113:8080/get_soulreaper.php"
local API_CAKE_QUEEN = "http://14.174.145.113:8080/get_cakequeen.php"
local API_PIRATE_RAID = "http://14.174.145.113:8080/get_pirateraid.php"

local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local VIM = game:GetService("VirtualInputManager")

_G.BlacklistedServers = _G.BlacklistedServers or {}
_G.BlacklistedServers[game.JobId] = true

-- ==========================================
-- [3. HÀM CHIẾN ĐẤU & DI CHUYỂN]
-- ==========================================
local Net = require(ReplicatedStorage.Modules.Net)
local RegisterAttack = Net:RemoteEvent("RegisterAttack", true)
local RegisterHit = Net:RemoteEvent("RegisterHit", true)

local function AttackNoCoolDown()
    pcall(function()
        local char = player.Character
        if not char or char.Humanoid.Health <= 0 then return end
        
        local targets = {}
        for _, v in pairs(workspace.Enemies:GetChildren()) do
            if v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 and v:FindFirstChild("HumanoidRootPart") then
                if (v.HumanoidRootPart.Position - char.HumanoidRootPart.Position).Magnitude <= 100 then
                    table.insert(targets, {v, v.HumanoidRootPart})
                end
            end
        end
        
        if #targets > 0 then
            RegisterAttack:FireServer(0)
            RegisterHit:FireServer(targets[1][1]:FindFirstChild("Head") or targets[1][2], targets)
            VU:CaptureController()
            VU:ClickButton1(Vector2.new())
            
            local equippedTool = char:FindFirstChildOfClass("Tool")
            if equippedTool and equippedTool:FindFirstChild("LeftClick") then
                equippedTool.LeftClick:FireServer()
            end
        end
    end)
end

local function EquipSword(itemName)
    local char = player.Character
    if not char or char.Humanoid.Health <= 0 then return end
    
    if _G.IsTakingDamage and not _G.AutoFarm_Bone then 
        char.Humanoid:UnequipTools() 
        return 
    end

    local toolInChar = char:FindFirstChild(itemName)
    local toolInBack = player.Backpack:FindFirstChild(itemName)

    if not toolInChar and not toolInBack then
        pcall(function() CommF:InvokeServer("LoadItem", itemName) end)
        task.wait(0.2)
        toolInBack = player.Backpack:FindFirstChild(itemName)
    end

    if toolInBack and not toolInChar then
        char.Humanoid:EquipTool(toolInBack)
    end
end

local function GetMaterial(matName)
    local inv = CommF:InvokeServer("getInventory")
    for _, item in pairs(inv) do
        if item.Name == matName then return item.Count or 1 end
    end
    return 0
end

local function Tween2(targetCFrame)
    pcall(function()
        local char = player.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") or char.Humanoid.Health <= 0 then return end
        local Root = char.HumanoidRootPart
        local dist = (targetCFrame.Position - Root.Position).Magnitude
        if dist < 5 then Root.CFrame = targetCFrame; return end
        if not Root:FindFirstChild("BodyVelocity") then
            local bv = Instance.new("BodyVelocity", Root)
            bv.MaxForce = Vector3.new(9e9, 9e9, 9e9); bv.Velocity = Vector3.new(0, 0, 0)
        end
        if _G.CurrentTween and _G.CurrentTweenTarget and (_G.CurrentTweenTarget.Position - targetCFrame.Position).Magnitude < 10 then
            if _G.CurrentTween.PlaybackState == Enum.PlaybackState.Playing then return end
        end
        if _G.CurrentTween then _G.CurrentTween:Cancel() end
        _G.CurrentTweenTarget = targetCFrame
        _G.CurrentTween = TweenService:Create(Root, TweenInfo.new(dist/315, Enum.EasingStyle.Linear), {CFrame = targetCFrame})
        _G.CurrentTween:Play()
    end)
end

local function BKP(targetCFrame)
    pcall(function()
        local char = player.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            if _G.CurrentTween then _G.CurrentTween:Cancel() end
            char.HumanoidRootPart.CFrame = targetCFrame
            if not char.HumanoidRootPart:FindFirstChild("BodyVelocity") then
                local bv = Instance.new("BodyVelocity", char.HumanoidRootPart)
                bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
                bv.Velocity = Vector3.new(0, 0, 0)
            end
        end
    end)
end

local function SmartMove(targetCFrame)
    local char = player.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local dist = (targetCFrame.Position - char.HumanoidRootPart.Position).Magnitude
    if dist > 300 then Tween2(targetCFrame)
    elseif dist > 5 then BKP(targetCFrame) end
end

local function AutoHop(apiUrl, reason)
    if _G.IsHopping then return end
    if tick() - _G.LastHopTime < 30 then return end 
    _G.IsHopping = true; _G.LastHopTime = tick() 
    print("⏳ Đang gọi API Server: " .. reason)
    
    task.spawn(function()
        local targetJobId = nil
        
        local success, result = pcall(function() return game:HttpGet(apiUrl) end)
        if success and result and result ~= "" then
            local s2, data = pcall(function() return HttpService:JSONDecode(result) end)
            if s2 and type(data) == "table" then
                for _, srv in pairs(data) do
                    if srv.job_id and srv.job_id ~= game.JobId and not _G.BlacklistedServers[srv.job_id] then
                        targetJobId = srv.job_id; break
                    end
                end
            end
        end
        
        if not targetJobId then
            print("⚠️ API sập/rỗng! Đang dò Random Server...")
            local s3, res3 = pcall(function()
                return HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100"))
            end)
            if s3 and res3 and res3.data then
                for _, v in pairs(res3.data) do
                    if type(v) == "table" and v.playing and v.playing < v.maxPlayers - 1 and v.id ~= game.JobId and not _G.BlacklistedServers[v.id] then
                        targetJobId = v.id
                        break
                    end
                end
            end
        end
        
        if targetJobId then
            local hasEssence = player.Backpack:FindFirstChild("Hallow Essence") or (player.Character and player.Character:FindFirstChild("Hallow Essence"))
            if reason == "Tìm Soul Reaper" and hasEssence then
                print("✅ Đã Roll ra Hallow Essence, Hủy Hop Server!")
            else
                _G.BlacklistedServers[targetJobId] = true 
                print("✈️ Tìm thấy Server mới! Đang dịch chuyển...")
                pcall(function() 
                    ReplicatedStorage.__ServerBrowser:InvokeServer("teleport", targetJobId) 
                end)
            end
        else
            print("❌ Hết Server để nhảy! Thử lại sau...")
        end
        
        task.wait(15); _G.IsHopping = false
    end)
end

-- HÀM SPAM CLICK TẮT HỘI THOẠI SAU KHI BẤM E
local function CloseDialog()
    pcall(function()
        local camera = workspace.CurrentCamera
        local centerPos = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
        for i = 1, 5 do
            VU:CaptureController()
            VU:ClickButton1(centerPos)
            task.wait(0.1)
        end
    end)
end

-- FIX LỖI ĐƠ NHÂN VẬT KHI RESET
RunService.Stepped:Connect(function()
    pcall(function()
        if (_G.Auto_DualKatana or _G.AutoFarm_Bone) and not _G.IsResetting then
            local char = player.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                local humanoid = char:FindFirstChild("Humanoid")
                if humanoid and humanoid.Health > 0 then
                    for _, part in pairs(char:GetDescendants()) do
                        if part:IsA("BasePart") and part.CanCollide then 
                            part.CanCollide = false 
                        end
                    end
                    humanoid:ChangeState(11)
                end
            end
        end
    end)
end)

-- ==========================================
-- [4. VÒNG LẶP MASTERY ĐỘC LẬP]
-- ==========================================
task.spawn(function()
    while task.wait(1) do
        if _G.Auto_DualKatana then
            pcall(function()
                local inv = CommF:InvokeServer("getInventory")
                local ym_mas, ts_mas = 0, 0
                for _, item in pairs(inv) do
                    if item.Name == "Yama" then ym_mas = item.Mastery or 0
                    elseif item.Name == "Tushita" then ts_mas = item.Mastery or 0 end
                end

                if _G.CurrentSword == "Tushita" then
                    if ts_mas < _G.TargetMastery then 
                        _G.AutoFarm_Bone = true
                        print("⚔️ Cày Tushita: "..ts_mas.."/".._G.TargetMastery)
                    else 
                        _G.CurrentSword = "Yama" 
                    end
                elseif _G.CurrentSword == "Yama" then
                    if ym_mas < _G.TargetMastery then 
                        _G.AutoFarm_Bone = true
                        print("⚔️ Cày Yama: "..ym_mas.."/".._G.TargetMastery)
                    else 
                        _G.AutoFarm_Bone = false 
                    end
                end
            end)
        end
    end
end)

-- ==========================================
-- [5. LUỒNG FARM XƯƠNG (CHUNG)]
-- ==========================================
local BoneMobs = {"Reborn Skeleton", "Living Zombie", "Demonic Soul", "Posessed Mummy"}
task.spawn(function()
    while task.wait() do
        if _G.Auto_DualKatana and _G.AutoFarm_Bone then
            pcall(function()
                local target = nil
                for _, v in pairs(workspace.Enemies:GetChildren()) do
                    if table.find(BoneMobs, v.Name) and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
                        target = v; break
                    end
                end
                if target then
                    EquipSword(_G.CurrentSword)
                    SmartMove(target.HumanoidRootPart.CFrame * Pos)
                    target.HumanoidRootPart.Size = Vector3.new(60, 60, 60)
                    _G.MonFarm = target.Name; _G.FarmPos = target.HumanoidRootPart.CFrame
                    AttackNoCoolDown()
                else
                    Tween2(CFrame.new(-9495, 450, 5977)) 
                end
            end)
        end
    end
end)

-- ==========================================
-- [6. LUỒNG NHIỆM VỤ CDK GỐC - ĐẢO NGƯỢC TUSHITA/YAMA]
-- ==========================================
local Auto_Quest_Yama_1 = false
local Auto_Quest_Yama_2 = false
local Auto_Quest_Yama_3 = false
local Auto_Quest_Tushita_1 = false
local Auto_Quest_Tushita_2 = false
local Auto_Quest_Tushita_3 = false

task.spawn(function()
    while task.wait() do
        if _G.Auto_DualKatana then
            if _G.AutoFarm_Bone then
                Auto_Quest_Yama_1 = false; Auto_Quest_Yama_2 = false; Auto_Quest_Yama_3 = false
                Auto_Quest_Tushita_1 = false; Auto_Quest_Tushita_2 = false; Auto_Quest_Tushita_3 = false
            else
                pcall(function()
                    local frags = GetMaterial("Alucard Fragment")
                    
                    _G.IsTakingDamage = false
                    if frags == 3 then _G.IsTakingDamage = true end
                    if frags == 5 and not workspace.Map:FindFirstChild("HellDimension") then
                        if workspace.Enemies:FindFirstChild("Soul Reaper") then _G.IsTakingDamage = true end
                    end
                    
                    EquipSword(_G.CurrentSword)

                    Auto_Quest_Yama_1 = false; Auto_Quest_Yama_2 = false; Auto_Quest_Yama_3 = false
                    Auto_Quest_Tushita_1 = false; Auto_Quest_Tushita_2 = false; Auto_Quest_Tushita_3 = false

                    if frags == 6 then
                        local boss = workspace.Enemies:FindFirstChild("Cursed Skeleton Boss")
                        if boss and boss.Humanoid.Health > 0 then
                            print("🎯 Đang đánh Boss Cuối CDK!")
                            SmartMove(boss.HumanoidRootPart.CFrame * Pos)
                            AttackNoCoolDown()
                            _G.BossDoorStep = 1 
                            _G.BossWaitTimer = nil
                        else
                            _G.BossDoorStep = _G.BossDoorStep or 1
                            
                            if _G.BossDoorStep == 1 then
                                print("🎯 Đang bay tới cuộn giấy Yama...")
                                local scroll1 = CFrame.new(-12391.1, 603.4, -6506.0)
                                if (player.Character.HumanoidRootPart.Position - scroll1.Position).Magnitude > 3 then
                                    Tween2(scroll1)
                                else
                                    BKP(scroll1)
                                    task.wait(0.5) 
                                    print("🎯 Đang tương tác cuộn giấy Yama...")
                                    VIM:SendKeyEvent(true, Enum.KeyCode.E, false, game)
                                    task.wait(3)
                                    VIM:SendKeyEvent(false, Enum.KeyCode.E, false, game)
                                    task.wait(0.5)
                                    CloseDialog() 
                                    task.wait(0.5)
                                    _G.BossDoorStep = 2
                                end
                                
                            elseif _G.BossDoorStep == 2 then
                                print("🎯 Đang bay tới cuộn giấy Tushita...")
                                local scroll2 = CFrame.new(-12391.7, 603.3, -6596.5)
                                if (player.Character.HumanoidRootPart.Position - scroll2.Position).Magnitude > 3 then
                                    Tween2(scroll2)
                                else
                                    BKP(scroll2)
                                    task.wait(0.5) 
                                    print("🎯 Đang tương tác cuộn giấy Tushita...")
                                    VIM:SendKeyEvent(true, Enum.KeyCode.E, false, game)
                                    task.wait(3)
                                    VIM:SendKeyEvent(false, Enum.KeyCode.E, false, game)
                                    task.wait(0.5)
                                    CloseDialog() 
                                    task.wait(0.5)
                                    _G.BossDoorStep = 3
                                end
                                
                            elseif _G.BossDoorStep == 3 then
                                print("🎯 Đang bay tới cổng bệ đá...")
                                local doorPos = CFrame.new(-12361, 603, -6550)
                                if (player.Character.HumanoidRootPart.Position - doorPos.Position).Magnitude > 3 then
                                    Tween2(doorPos)
                                else
                                    BKP(doorPos)
                                    task.wait(0.5) 
                                    print("🎯 Đang bấm E mở cổng đợi Boss...")
                                    VIM:SendKeyEvent(true, Enum.KeyCode.E, false, game)
                                    task.wait(3)
                                    VIM:SendKeyEvent(false, Enum.KeyCode.E, false, game)
                                    task.wait(0.5)
                                    CloseDialog() 
                                    
                                    pcall(function()
                                        CommF:InvokeServer("CDKQuest", "OpenDoor")
                                        task.wait(0.3)
                                        CommF:InvokeServer("CDKQuest", "OpenDoor", true)
                                    end)
                                    
                                    task.wait(0.5)
                                    _G.BossDoorStep = 4 
                                end
                                
                            elseif _G.BossDoorStep == 4 then
                                print("🎯 Đang tiến vào phòng gọi Boss...")
                                local spawnPos = CFrame.new(-12275.1, 598.9, -6552.4)
                                if (player.Character.HumanoidRootPart.Position - spawnPos.Position).Magnitude > 3 then
                                    Tween2(spawnPos)
                                else
                                    BKP(spawnPos)
                                    if not _G.BossWaitTimer then _G.BossWaitTimer = tick() end
                                    
                                    if tick() - _G.BossWaitTimer > 5 then 
                                        print("⚠️ Boss chưa ra! Bắt đầu vòng lặp tương tác lại...")
                                        _G.BossWaitTimer = nil
                                        _G.BossDoorStep = 1 
                                    end
                                end
                            end
                        end
                    -- SỬ DỤNG LẠI LỆNH REQUEST GỐC CỦA BÁC
                    elseif frags == 5 then Auto_Quest_Yama_3 = true; print("🎯 Yama Q3"); CommF:InvokeServer("CDKQuest", "StartTrial", "Evil")
                    elseif frags == 4 then Auto_Quest_Yama_2 = true; print("🎯 Yama Q2"); CommF:InvokeServer("CDKQuest", "StartTrial", "Evil")
                    elseif frags == 3 then Auto_Quest_Yama_1 = true; print("🎯 Yama Q1"); CommF:InvokeServer("CDKQuest", "StartTrial", "Evil")
                    elseif frags == 2 then Auto_Quest_Tushita_3 = true; print("🎯 Tushita Q3"); CommF:InvokeServer("CDKQuest", "StartTrial", "Good")
                    elseif frags == 1 then Auto_Quest_Tushita_2 = true; print("🎯 Tushita Q2"); CommF:InvokeServer("CDKQuest", "StartTrial", "Good")
                    elseif frags == 0 then Auto_Quest_Tushita_1 = true; print("🎯 Tushita Q1"); CommF:InvokeServer("CDKQuest", "StartTrial", "Good")
                    end
                end)
            end
        end
    end
end)

-- Yama Q1
task.spawn(function()
    while task.wait() do
        if Auto_Quest_Yama_1 and not _G.AutoFarm_Bone then
            pcall(function()
                local pirate = workspace.Enemies:FindFirstChild("Mythological Pirate")
                if pirate then 
                    SmartMove(pirate.HumanoidRootPart.CFrame * CFrame.new(0, 0, -2))
                else 
                    Tween2(CFrame.new(-13451, 543, -6961)) 
                end
            end)
        end
    end
end)

-- Yama Q2 (Haze) 
_G.HzIdx = _G.HzIdx or 1
_G.NeedResetFromSubmerged = _G.NeedResetFromSubmerged or false

task.spawn(function()
    while task.wait() do
        if Auto_Quest_Yama_2 and not _G.AutoFarm_Bone then
            pcall(function()
                local foundHaze = false
                local questHaze = player:FindFirstChild("QuestHaze")
                
                if questHaze then
                    for _, hitMon in pairs(questHaze:GetChildren()) do
                        if hitMon:IsA("IntValue") and hitMon.Value > 0 then
                            for _, v in pairs(workspace.Enemies:GetChildren()) do
                                if string.find(v.Name, hitMon.Name) and v:FindFirstChild("HazeESP") and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
                                    foundHaze = true
                                    SmartMove(v.HumanoidRootPart.CFrame * Pos)
                                    AttackNoCoolDown()
                                    break
                                end
                            end
                        end
                        if foundHaze then break end
                    end
                end
                
                if not foundHaze then
                    for _, v in pairs(workspace.Enemies:GetChildren()) do
                        if v:FindFirstChild("HazeESP") and v.Humanoid.Health > 0 then 
                            foundHaze = true
                            SmartMove(v.HumanoidRootPart.CFrame * Pos)
                            AttackNoCoolDown()
                            break 
                        end
                    end
                end
                
                if not foundHaze then
                    for _, v in pairs(ReplicatedStorage:GetChildren()) do
                        if v:FindFirstChild("HazeESP") then
                            foundHaze = true
                            SmartMove(v.HumanoidRootPart.CFrame * Pos)
                            break
                        end
                    end
                end
                
                if not foundHaze then
                    local HazeIslands = {
                        CFrame.new(3399.3, 72.4, 1573.0),   CFrame.new(-2131.0, 38.0, -10106.0),
                        CFrame.new(-950.0, 59.0, -10907.0), CFrame.new(5138.2, 12.3, 431.6),
                        CFrame.new(-16204.1, 9.1, 479.2),   CFrame.new(-9509.3, 142.1, 5535.2),
                        CFrame.new(-12548.0, 337.0, -7481.0),CFrame.new(-247.1, 20.7, 5562.0),
                        CFrame.new(2443.1, 21.7, -6573.4),  CFrame.new(-10016.0, 332.0, -8326.0),
                        CFrame.new(-1762.0, 37.8, -11878.0),CFrame.new(127.2, 24.8, -12098.7),
                        CFrame.new(5319.0, 1005.4, 360.8),  
                        CFrame.new(-16270.0, 25.2, 1373.8)  
                    }
                    
                    if _G.NeedResetFromSubmerged then
                        print("Yama Q2: Đang tự sát để thoát khỏi Tàu Ngầm...")
                        Tween2(HazeIslands[_G.HzIdx])
                        if (player.Character.HumanoidRootPart.Position - HazeIslands[_G.HzIdx].Position).Magnitude < 1500 then
                            
                            _G.IsResetting = true 
                            task.wait(0.2)
                            
                            pcall(function()
                                local char = player.Character
                                for _,v in pairs(char.HumanoidRootPart:GetChildren()) do
                                    if v:IsA("BodyVelocity") or v:IsA("BodyGyro") then v:Destroy() end
                                end
                                char.Humanoid:ChangeState(Enum.HumanoidStateType.Dead)
                                char.Humanoid.Health = 0
                                char:BreakJoints()
                            end)
                            
                            task.wait(6) 
                            _G.IsResetting = false 
                            _G.NeedResetFromSubmerged = false
                        end
                        
                    elseif _G.HzIdx == 14 then
                        print("Yama Q2: Tương tác NPC SubmarineWorkerSpeak...")
                        Tween2(HazeIslands[14])
                        if (player.Character.HumanoidRootPart.Position - HazeIslands[14].Position).Magnitude < 15 then
                            pcall(function()
                                game:GetService("ReplicatedStorage").Modules.Net["RF/SubmarineWorkerSpeak"]:InvokeServer("TravelToSubmergedIsland")
                            end)
                            task.wait(5) 
                            _G.HzIdx = 1
                            _G.NeedResetFromSubmerged = true
                        end
                        
                    else
                        print("Yama Q2: Tuần tra đảo " .. _G.HzIdx .. "/14 (Đợi 5s load quái)")
                        Tween2(HazeIslands[_G.HzIdx])
                        if (player.Character.HumanoidRootPart.Position - HazeIslands[_G.HzIdx].Position).Magnitude < 300 then
                            task.wait(5) 
                            _G.HzIdx = _G.HzIdx + 1
                            if _G.HzIdx > 14 then _G.HzIdx = 1 end
                        end
                    end
                end
            end)
        end
    end
end)

-- Yama Q3
task.spawn(function()
    while task.wait() do
        if Auto_Quest_Yama_3 and not _G.AutoFarm_Bone then
            pcall(function()
                local hell = workspace.Map:FindFirstChild("HellDimension")
                if hell and (player.Character.HumanoidRootPart.Position - hell.Spawn.Position).Magnitude < 3000 then
                    local foundMob = false
                    for _, v in pairs(workspace.Enemies:GetChildren()) do
                        if (string.find(v.Name, "Cursed Skeleton") or string.find(v.Name, "Hell's Messenger")) and v.Humanoid.Health > 0 then
                            foundMob = true; 
                            SmartMove(v.HumanoidRootPart.CFrame * Pos); AttackNoCoolDown()
                        end
                    end
                    if not foundMob then
                        for i = 1, 3 do
                            local t = hell:FindFirstChild("Torch"..i)
                            if t and t:FindFirstChildOfClass("ProximityPrompt") and t.ProximityPrompt.Enabled then
                                Tween2(t.CFrame); task.wait(1.5)
                                VIM:SendKeyEvent(true, Enum.KeyCode.E, false, game); task.wait(3); VIM:SendKeyEvent(false, Enum.KeyCode.E, false, game)
                            end
                        end
                        local exitP = hell:FindFirstChild("Exit")
                        if exitP then
                            local bv = player.Character.HumanoidRootPart:FindFirstChild("BodyVelocity")
                            if bv then bv:Destroy() end
                            player.Character.HumanoidRootPart.CFrame = exitP.CFrame
                        end
                    end
                else
                    local reaper = workspace.Enemies:FindFirstChild("Soul Reaper")
                    if reaper and reaper.Humanoid.Health > 0 then
                        print("Yama Q3: Hứng đòn từ Soul Reaper...")
                        SmartMove(reaper.HumanoidRootPart.CFrame * CFrame.new(0,0,-2))
                    else
                        if player.Backpack:FindFirstChild("Hallow Essence") or player.Character:FindFirstChild("Hallow Essence") then
                            print("Yama Q3: Đang đem Hallow Essence đi triệu hồi Boss...")
                            local altarPos = CFrame.new(-8932.32, 146.83, 6062.55)
                            Tween2(altarPos)
                            if (altarPos.Position - player.Character.HumanoidRootPart.Position).Magnitude <= 10 then
                                EquipSword("Hallow Essence")
                            end
                        else
                            AutoHop(API_SOUL_REAPER, "Tìm Soul Reaper")
                            
                            local bones = CommF:InvokeServer("Bones", "Check") or 0
                            if bones >= 50 then
                                print("Yama Q3: Đủ 50 Xương, Đang bay đi Random...")
                                Tween2(CFrame.new(-9570, 315, 6726))
                                if (player.Character.HumanoidRootPart.Position - CFrame.new(-9570, 315, 6726).Position).Magnitude < 100 then
                                    CommF:InvokeServer("Bones", "Buy", 1, 1)
                                end
                            else
                                print("Yama Q3: Đang Farm Xương kiếm Essence ("..bones.."/50)...")
                                local target = nil
                                for _, v in pairs(workspace.Enemies:GetChildren()) do
                                    if table.find(BoneMobs, v.Name) and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
                                        target = v; break
                                    end
                                end
                                if target then
                                    EquipSword(_G.CurrentSword)
                                    SmartMove(target.HumanoidRootPart.CFrame * Pos)
                                    target.HumanoidRootPart.Size = Vector3.new(60, 60, 60)
                                    _G.MonFarm = target.Name; _G.FarmPos = target.HumanoidRootPart.CFrame
                                    AttackNoCoolDown()
                                else
                                    Tween2(CFrame.new(-9495, 450, 5977)) 
                                end
                            end
                        end
                    end
                end
            end)
        end
    end
end)

-- Tushita Q1
_G.DealerStep = 1
task.spawn(function()
    while task.wait() do
        if Auto_Quest_Tushita_1 and not _G.AutoFarm_Bone then
            pcall(function()
                local progress = CommF:InvokeServer("CDKQuest", "Progress")
                if progress and tonumber(progress.Good) == 1 then
                    return 
                end
                
                local dealers = {
                    CFrame.new(-4602.51, 16.44, -2880.99),
                    CFrame.new(4001.18, 10.08, -2654.86),
                    CFrame.new(-9530.76, 7.24, -8375.50)
                }
                
                local target = dealers[_G.DealerStep]
                if target then
                    print("🎯 Tushita Q1: Bay tới Boat Dealer " .. _G.DealerStep .. "/3")
                    Tween2(target)
                    
                    if (player.Character.HumanoidRootPart.Position - target.Position).Magnitude <= 10 then
                        task.wait(0.7)
                        CommF:InvokeServer("CDKQuest", "BoatQuest", workspace.NPCs:FindFirstChild("Luxury Boat Dealer"), "Check")
                        task.wait(0.5)
                        CommF:InvokeServer("CDKQuest", "BoatQuest", workspace.NPCs:FindFirstChild("Luxury Boat Dealer"))
                        task.wait(1)
                        
                        _G.DealerStep = _G.DealerStep + 1
                        if _G.DealerStep > 3 then _G.DealerStep = 1 end
                    end
                end
            end)
        end
    end
end)

-- Tushita Q2
task.spawn(function()
    while task.wait() do
        if Auto_Quest_Tushita_2 and not _G.AutoFarm_Bone then
            pcall(function()
                if (CFrame.new(-5539, 313, -2972).Position - player.Character.HumanoidRootPart.Position).Magnitude > 500 then
                    Tween2(CFrame.new(-5545, 313, -2976))
                else
                    local p = nil
                    for _, v in pairs(workspace.Enemies:GetChildren()) do
                        if v.Humanoid.Health > 0 and (v.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude < 2000 then
                            p = v; break
                        end
                    end
                    if p then 
                        SmartMove(p.HumanoidRootPart.CFrame * Pos); AttackNoCoolDown()
                    else AutoHop(API_PIRATE_RAID, "Tìm Pirate Raid") end
                end
            end)
        end
    end
end)

-- Tushita Q3
task.spawn(function()
    while task.wait() do
        if Auto_Quest_Tushita_3 and not _G.AutoFarm_Bone then
            pcall(function()
                local heav = workspace.Map:FindFirstChild("HeavenlyDimension")
                if heav and (player.Character.HumanoidRootPart.Position - heav.Spawn.Position).Magnitude < 3000 then
                    local foundMob = false
                    for _, v in pairs(workspace.Enemies:GetChildren()) do
                        if (string.find(v.Name, "Cursed Skeleton") or string.find(v.Name, "Heaven's Guardian")) and v.Humanoid.Health > 0 then
                            foundMob = true; 
                            EquipSword(_G.CurrentSword)
                            SmartMove(v.HumanoidRootPart.CFrame * Pos); AttackNoCoolDown()
                        end
                    end
                    
                    if not foundMob then
                        local allLit = true 
                        for i = 1, 3 do
                            local t = heav:FindFirstChild("Torch"..i)
                            if t and t:FindFirstChildOfClass("ProximityPrompt") and t.ProximityPrompt.Enabled then
                                allLit = false 
                                Tween2(t.CFrame); task.wait(1.5)
                                VIM:SendKeyEvent(true, Enum.KeyCode.E, false, game); 
                                task.wait(3); 
                                VIM:SendKeyEvent(false, Enum.KeyCode.E, false, game)
                                task.wait(0.5)
                            end
                        end
                        
                        if allLit then
                            local exitP = heav:FindFirstChild("Exit")
                            if exitP then
                                local bv = player.Character.HumanoidRootPart:FindFirstChild("BodyVelocity")
                                if bv then bv:Destroy() end
                                player.Character.HumanoidRootPart.CFrame = exitP.CFrame
                            end
                        end
                    end
                else
                    local cq = nil
                    for _, v in pairs(workspace.Enemies:GetChildren()) do
                        if string.find(v.Name, "Cake Queen") and v.Humanoid.Health > 0 then cq = v; break end
                    end
                    if cq then 
                        EquipSword(_G.CurrentSword)
                        SmartMove(cq.HumanoidRootPart.CFrame * Pos); AttackNoCoolDown()
                    else
                        Tween2(CFrame.new(-709, 381, -11011))
                        if (player.Character.HumanoidRootPart.Position - Vector3.new(-709, 381, -11011)).Magnitude < 200 then
                            if not _G.CQDeadTimer then _G.CQDeadTimer = tick() end
                            if tick() - _G.CQDeadTimer > 7 then AutoHop(API_CAKE_QUEEN, "Tìm Cake Queen") end
                        end
                    end
                end
            end)
        end
    end
end)

-- ==========================================
-- GOM QUÁI (BRING MOB) VÀ DỌN XÁC GHOST MOB
-- ==========================================
task.spawn(function()
    while task.wait(0.5) do
        pcall(function()
            if _G.BringMob and _G.MonFarm then
                for _, v in pairs(workspace.Enemies:GetChildren()) do
                    if v.Name == _G.MonFarm and v:FindFirstChild("Humanoid") and v.Humanoid.Health <= 0 then
                        if v:FindFirstChild("HumanoidRootPart") then
                            v.HumanoidRootPart.CFrame = CFrame.new(0, -9999, 0)
                        end
                        game:GetService("Debris"):AddItem(v, 1)
                    end
                end
            end
        end)
    end
end)

spawn(function()
    while wait() do
        pcall(function()
            if _G.BringMob and _G.FarmPos and _G.MonFarm then
                for _, v in pairs(workspace.Enemies:GetChildren()) do
                    if v.Name == _G.MonFarm and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
                        if v:FindFirstChild("HumanoidRootPart") and (v.HumanoidRootPart.Position - _G.FarmPos.Position).Magnitude <= 1500 then
                            v.HumanoidRootPart.CFrame = _G.FarmPos
                            v.HumanoidRootPart.Size = Vector3.new(60, 60, 60)
                            v.HumanoidRootPart.Transparency = 1
                            v.HumanoidRootPart.CanCollide = false
                            v.Humanoid.JumpPower = 0
                            v.Humanoid.WalkSpeed = 0
                            if v:FindFirstChild("Head") then v.Head.CanCollide = false end
                            if v.Humanoid:FindFirstChild("Animator") then v.Humanoid.Animator:Destroy() end
                            v.Humanoid:ChangeState(11)
                            v.Humanoid:ChangeState(14)
                            sethiddenproperty(player, "SimulationRadius", math.huge)
                        end
                    end
                end
            end
        end)
    end
end)
