-- ==========================================
-- ULTIMATE SCRIPT (NO KEY) - BẢN FULL HOÀN CHỈNH
-- AUTO KAITUN -> ELECTRIC CLAW -> RACE V3 -> AUTO CDK
-- ==========================================
if not game:IsLoaded() then game.Loaded:Wait() end

local Players = game:GetService("Players")
local plr = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local TS = game:GetService("TweenService")
local RS = game:GetService("RunService")
local SafeGuiParent = plr:WaitForChild("PlayerGui")
local CoreGui = (gethui and gethui()) or game:GetService("CoreGui") or SafeGuiParent

-- =====================================================================
-- CONFIG TỪ KHÁCH HÀNG CHUYỂN VÀO
-- =====================================================================
local config = _G.UltimateConfig or {}
local kaitunCfg = config.Kaitun or {}
local bananaCfg = config.BananaVIP or {}
local cdkCfg = config.AutoCDK or {}
local levelThreshold = config.LevelThreshold or 2500

_G.StoreF = config.AutoStoreFruit == nil and true or config.AutoStoreFruit
_G.BringMob = config.BringMob == nil and true or config.BringMob
_G.MonFarm = ""
_G.FarmPos = nil
_G.IsDoingAutoCDK = false   
_G.DoingElectricClaw = false 

local Link_AutoCDK = "https://raw.githubusercontent.com/Lehamgdieb/Configvippro/refs/heads/main/autocdk.lua"

-- =====================================================================
-- HÀM HỖ TRỢ CƠ BẢN
-- =====================================================================
local function CommF_(...)
    local remotes = ReplicatedStorage:FindFirstChild("Remotes")
    if remotes then
        local comm = remotes:FindFirstChild("CommF_")
        if comm then return comm:InvokeServer(...) end
    end
    return nil
end

local function Tween2(targetCFrame)
    pcall(function()
        local char = plr.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") then return end
        local Root = char.HumanoidRootPart
        local dist = (targetCFrame.Position - Root.Position).Magnitude
        if not Root:FindFirstChild("BodyVelocity") then
            local bv = Instance.new("BodyVelocity", Root)
            bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
            bv.Velocity = Vector3.zero
        end
        local tween = TS:Create(Root, TweenInfo.new(dist/300, Enum.EasingStyle.Linear), {CFrame = targetCFrame})
        tween:Play()
    end)
end

local function getLevel()
    local lvl = 0
    pcall(function()
        if plr:FindFirstChild("Data") and plr.Data:FindFirstChild("Level") then
            lvl = plr.Data.Level.Value
        end
    end)
    return lvl
end

local function checkRaceV3()
    local char = plr.Character
    local bp = plr:FindFirstChild("Backpack")
    
    if char and char:FindFirstChild("RaceTransformed") then return "V4" end
    
    local v3Skills = {"Last Resort", "Agility", "Water Body", "Heavenly Blood", "Heightened Senses", "Energy Core"}
    for _, skill in ipairs(v3Skills) do
        if (char and char:FindFirstChild(skill)) or (bp and bp:FindFirstChild(skill)) then
            return "V3"
        end
    end

    local v1 = CommF_("Wenlocktoad", "1")
    local v2 = CommF_("Alchemist", "1")
    return (v1 == -2 and "V3") or (v2 == -2 and "V2") or "V1"
end

local function checkWeapon(weaponName)
    local bp = plr:FindFirstChild("Backpack")
    local char = plr.Character
    if bp and bp:FindFirstChild(weaponName) then return true end
    if char and char:FindFirstChild(weaponName) then return true end
    
    local inv = CommF_("getInventory")
    if type(inv) == "table" then
        for _, item in pairs(inv) do
            if type(item) == "table" and item.Name == weaponName then return true end
        end
    end
    return false
end

local function hasYama() return checkWeapon("Yama") end
local function hasTushita() return checkWeapon("Tushita") end
local function hasCDK() return checkWeapon("Cursed Dual Katana") end

local function isDoingHazeQuest()
    local frags = 0
    pcall(function()
        local inv = CommF_("getInventory")
        if type(inv) == "table" then
            for _, item in pairs(inv) do
                if type(item) == "table" and item.Name == "Alucard Fragment" then frags = item.Count or 0; break end
            end
        end
    end)
    if frags == 4 or frags == 5 then
        local progress = CommF_("CDKQuest", "Progress")
        if progress and progress.Evil then return true end
    end
    return false
end

-- =====================================================================
-- HỆ THỐNG AUTO STORE FRUIT (>1M BELI, TẠI SEA 3)
-- =====================================================================
local TrashFruits = {
    "Rocket-Rocket", "Spin-Spin", "Blade-Blade", "Spring-Spring", "Bomb-Bomb",
    "Smoke-Smoke", "Spike-Spike", "Flame-Flame", "Ice-Ice", "Sand-Sand",
    "Dark-Dark", "Falcon-Falcon", "Diamond-Diamond", "Light-Light", "Rubber-Rubber",
    "Ghost-Ghost", "Magma-Magma", "Quake-Quake"
}

local function UpdStFruit()
    if game.PlaceId ~= 100117331123089 then return end
    local char = plr.Character
    local bp = plr:FindFirstChild("Backpack")
    if not char or not bp then return end

    local tools = {}
    for _, v in pairs(char:GetChildren()) do if v:IsA("Tool") then table.insert(tools, v) end end
    for _, v in pairs(bp:GetChildren()) do if v:IsA("Tool") then table.insert(tools, v) end end

    for _, tool in ipairs(tools) do
        if tool.ToolTip == "Blox Fruit" or string.find(tool.Name, "Fruit") then
            local isTrash = false
            for _, trashName in pairs(TrashFruits) do
                if string.find(tool.Name, trashName) then isTrash = true; break end
            end
            if not isTrash then
                print("[Auto Store] Đang cất trái có giá trị: " .. tool.Name)
                CommF_("StoreFruit", tool:GetAttribute("OriginalName") or tool.Name)
            end
        end
    end
end

task.spawn(function()
    while task.wait(1) do
        if _G.StoreF then pcall(function() UpdStFruit() end) end
    end
end)

-- =====================================================================
-- HỆ THỐNG BRING MOB (BẢN XỊN TỐI ƯU)
-- =====================================================================
task.spawn(function()
    while task.wait() do
        pcall(function()
            if _G.BringMob and _G.MonFarm ~= "" and _G.FarmPos then
                for _, v in pairs(workspace.Enemies:GetChildren()) do
                    if v.Name == _G.MonFarm and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
                        if v.Name == "Factory Staff" then
                            if (v.HumanoidRootPart.Position - _G.FarmPos.Position).Magnitude <= 1000000000 then
                                v.Head.CanCollide = false
                                v.HumanoidRootPart.CanCollide = false
                                v.HumanoidRootPart.Size = Vector3.new(60, 60, 60)
                                v.HumanoidRootPart.CFrame = _G.FarmPos
                                if v.Humanoid:FindFirstChild("Animator") then v.Humanoid.Animator:Destroy() end
                                sethiddenproperty(plr, "SimulationRadius", math.huge)
                            end
                        else
                            if (v.HumanoidRootPart.Position - _G.FarmPos.Position).Magnitude <= 1000000000 then
                                v.HumanoidRootPart.CFrame = _G.FarmPos
                                v.HumanoidRootPart.Size = Vector3.new(60, 60, 60)
                                v.HumanoidRootPart.Transparency = 1
                                v.Humanoid.JumpPower = 0
                                v.Humanoid.WalkSpeed = 0
                                if v.Humanoid:FindFirstChild("Animator") then v.Humanoid.Animator:Destroy() end
                                v.HumanoidRootPart.CanCollide = false
                                if v:FindFirstChild("Head") then v.Head.CanCollide = false end
                                v.Humanoid:ChangeState(11)
                                v.Humanoid:ChangeState(14)
                                sethiddenproperty(plr, "SimulationRadius", math.huge)
                            end
                        end
                    end
                end
            end
        end)
    end
end)

-- =====================================================================
-- AUTO LẤY ELECTRIC CLAW (HOP 1 LẦN, KHÔNG LỖI MULTI-ACC)
-- =====================================================================
local request_func = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request
local ElecHopFile = "Banana_ElecHop_" .. tostring(plr.Name) .. ".txt"

local function SafeIsFile(name)
    local res = false
    pcall(function() res = isfile(name) end)
    return res
end

local function checkElectricReady()
    local beli, frags = 0, 0
    pcall(function()
        beli = plr.Data.Beli.Value
        frags = plr.Data.Fragments.Value
    end)
    if beli < 3000000 or frags < 5000 then return false end
    
    local elec = plr.Backpack:FindFirstChild("Electric") or (plr.Character and plr.Character:FindFirstChild("Electric"))
    if elec and elec:FindFirstChild("Level") and elec.Level.Value >= 400 then
        return true
    end
    return false
end

local ElectricClawQuestStep = 1

task.spawn(function()
    while task.wait(1) do
        if game.PlaceId == 100117331123089 then
            local hasEC = checkWeapon("Electric Claw")
            local hasHopFile = SafeIsFile(ElecHopFile)
            
            if not hasEC and (hasHopFile or checkElectricReady()) then
                _G.DoingElectricClaw = true
                _G.IsDoingAutoCDK = true 
                
                if not hasHopFile then
                    pcall(function() writefile(ElecHopFile, "Đã_Hop_Nha") end)
                    print("⚡ Đủ 400 Mas Electric! Đang Hop Server 1 lần để né Kaitun...")
                    local s, r = pcall(function() return request_func({Url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Desc&limit=100", Method = "GET"}) end)
                    if s and r and r.Body then
                        local _, d = pcall(function() return HttpService:JSONDecode(r.Body) end)
                        if d and d.data then
                            local valid = {}
                            for _, srv in pairs(d.data) do
                                if srv.playing and srv.playing < (srv.maxPlayers or 12) - 1 and tostring(srv.id) ~= tostring(game.JobId) then
                                    table.insert(valid, tostring(srv.id))
                                end
                            end
                            if #valid > 0 then
                                pcall(function() ReplicatedStorage:FindFirstChild("__ServerBrowser"):InvokeServer("teleport", valid[math.random(1, #valid)]) end)
                            end
                        end
                    end
                    task.wait(20)
                else
                    local hero = CFrame.new(-10476, 330, -9669)
                    local mansion = CFrame.new(-12548.0, 332.378, -7617.0) 
                    local root = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
                    
                    if root then
                        if ElectricClawQuestStep == 1 then
                            if (root.Position - hero.Position).Magnitude > 15 then
                                Tween2(hero)
                            else
                                CommF_("BuyElectricClaw", "Start") 
                                task.wait(0.5)
                                CommF_("PreviousHero", "1")
                                task.wait(1)
                                ElectricClawQuestStep = 2
                            end
                        elseif ElectricClawQuestStep == 2 then
                            if (root.Position - mansion.Position).Magnitude > 15 then
                                Tween2(mansion)
                            else
                                CommF_("PreviousHero", "2")
                                task.wait(1)
                                CommF_("BuyElectricClaw")
                                task.wait(2)
                                pcall(function() delfile(ElecHopFile) end)
                                _G.DoingElectricClaw = false
                                _G.IsDoingAutoCDK = false
                                ElectricClawQuestStep = 3
                            end
                        elseif ElectricClawQuestStep == 3 then
                            if checkWeapon("Electric Claw") or not checkElectricReady() then
                                pcall(function() delfile(ElecHopFile) end)
                                _G.DoingElectricClaw = false
                            end
                        end
                    end
                end
            else
                if hasEC and hasHopFile then pcall(function() delfile(ElecHopFile) end) end
                _G.DoingElectricClaw = false
            end
        end
    end
end)

-- =====================================================================
-- BỘ NÃO ĐIỀU PHỐI (KAITUN / RACE MASTER / AUTO CDK)
-- =====================================================================
local KaitunLoaded = false
local AutoCDK_Loaded = false

local function CallKaitun()
    if not KaitunLoaded then
        KaitunLoaded = true
        task.spawn(function()
            if kaitunCfg.SettingFarm then getgenv().SettingFarm = kaitunCfg.SettingFarm end
            getgenv().Key = kaitunCfg.Key or ""
            loadstring(game:HttpGet("https://raw.githubusercontent.com/obiiyeuem/vthangsitink/main/BananaCat-kaitunBF.lua"))()
        end)
    end
end

local function TryLoadMainLogic()
    if _G.DoingElectricClaw then return end

    local currentLvl = getLevel()
    
    if currentLvl < levelThreshold then
        CallKaitun()
        return
    end

    local inv = CommF_("getInventory")
    if type(inv) ~= "table" then return end

    local hY = hasYama()
    local hT = hasTushita()
    local hC = hasCDK()
    local raceStatus = checkRaceV3()

    if bananaCfg.AutoRaceV3 then
        if raceStatus ~= "V3" and raceStatus ~= "V4" then return end
    end

    if hC then
        -- ĐÃ FIX: Lấy xong CDK tự động gọi Kaitun cày tiếp vĩnh viễn
        CallKaitun()
        return
    end

    if hY and hT then
        if not AutoCDK_Loaded then
            AutoCDK_Loaded = true
            _G.IsDoingAutoCDK = true
            task.spawn(function()
                pcall(function() loadstring(game:HttpGet(Link_AutoCDK))() end)
            end)
        end
    else
        CallKaitun()
    end
end

task.spawn(function()
    while task.wait(5) do TryLoadMainLogic() end
end)

-- =====================================================================
-- AUTO TEAM
-- =====================================================================
task.spawn(function()
    while task.wait(1) do
        if plr and not plr.Team then
            pcall(function() CommF_("SetTeam", "Pirates") end)
        elseif plr and plr:FindFirstChild("PlayerGui") and plr.PlayerGui:FindFirstChild("ChooseTeam") then
            plr.PlayerGui.ChooseTeam.Enabled = false
        end
        if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then break end
    end
end)

-- =====================================================================
-- UI VIPRO CONFIG & BANANA VIP HOP BOSS
-- =====================================================================
local AutoFindVIPBoss = bananaCfg.AutoFindVIPBoss or false
local AutoHopBoss = bananaCfg.AutoHopBoss or false

task.spawn(function()
    task.wait(5)
    local API_SAVE = "http://14.174.148.37:8080/save_boss.php"
    local API_INDRA = "http://14.174.148.37:8080/get_rip_indra.php"
    local API_DOUGH = "http://14.174.148.37:8080/get_doughking.php"
    
    local needDough = true
    local needIndra = true
    local lastInvCheck = 0
    local BossList = { "Stone", "Hydra Leader", "Kilo Admiral", "Captain Elephant", "Beautiful Pirate", "rip_indra True Form", "Dough King", "Soul Reaper", "Cake Queen", "Cake Prince", "Saber Expert", "Cursed Captain", "Longma", "Diamond", "Jeremy", "Orbitus"}

    -- TẠO UI BANANA PRO VIP
    if SafeGuiParent:FindFirstChild("BananaProVIP_UI") then SafeGuiParent.BananaProVIP_UI:Destroy() end
    local ScreenGui = Instance.new("ScreenGui", SafeGuiParent)
    ScreenGui.Name = "BananaProVIP_UI"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.DisplayOrder = 99990

    local MainFrame = Instance.new("Frame", ScreenGui)
    MainFrame.Size = UDim2.new(0, 240, 0, 80)
    MainFrame.Position = UDim2.new(0.5, -120, 0.1, 0)
    MainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
    MainFrame.BorderSizePixel = 0
    MainFrame.Active = true
    MainFrame.Draggable = true
    Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 6)
    local UIStroke = Instance.new("UIStroke", MainFrame)
    UIStroke.Color = Color3.fromRGB(255, 215, 0)
    UIStroke.Thickness = 1.8

    local Title = Instance.new("TextLabel", MainFrame)
    Title.Size = UDim2.new(1, 0, 0, 30)
    Title.BackgroundTransparency = 1
    Title.Text = "🍌 BANANA PRO VIP"
    Title.TextColor3 = Color3.new(1, 1, 1)
    Title.TextSize = 16
    Title.Font = Enum.Font.GothamBold

    local StatusLabel = Instance.new("TextLabel", MainFrame)
    StatusLabel.Size = UDim2.new(1, 0, 0, 25)
    StatusLabel.Position = UDim2.new(0, 0, 0, 30)
    StatusLabel.BackgroundTransparency = 1
    StatusLabel.Text = "FOUND: 0 BOSS"
    StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 127)
    StatusLabel.TextSize = 15
    StatusLabel.Font = Enum.Font.GothamBold

    local HopLabel = Instance.new("TextLabel", MainFrame)
    HopLabel.Size = UDim2.new(1, 0, 0, 25)
    HopLabel.Position = UDim2.new(0, 0, 0, 55)
    HopLabel.BackgroundTransparency = 1
    HopLabel.Text = "HOP: Standby"
    HopLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
    HopLabel.TextSize = 13
    HopLabel.Font = Enum.Font.Gotham

    local isHopping = false
    local function performHop()
        if _G.IsDoingAutoCDK or _G.DoingElectricClaw then return end
        if isHopping then return end
        isHopping = true
        HopLabel.Text = "HOP: Tìm Server..."

        if needIndra or needDough then
            local vip = {}
            local function fetch(url)
                local s, r = pcall(function() return game:HttpGet(url) end)
                if not s or r == "" then return end
                local _, d = pcall(function() return HttpService:JSONDecode(r) end)
                if type(d) == "table" then
                    for _, srv in pairs(d) do
                        if tostring(srv.place_id) == tostring(game.PlaceId) and (tonumber(string.match(tostring(srv.players or ""), "^(%d+)")) or 0) <= 12 then
                            table.insert(vip, tostring(srv.job_id))
                        end
                    end
                end
            end
            if needIndra then fetch(API_INDRA) end
            if needDough then fetch(API_DOUGH) end
            
            if #vip > 0 then
                HopLabel.Text = "HOP: Tới Boss VIP!"
                pcall(function() ReplicatedStorage:FindFirstChild("__ServerBrowser"):InvokeServer("teleport", vip[math.random(1, #vip)]) end)
                task.delay(15, function() isHopping = false end)
                return
            end
        end

        task.spawn(function()
            local s, r = pcall(function() return request_func({Url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Desc&limit=100", Method = "GET"}) end)
            if s and r and r.Body then
                local _, d = pcall(function() return HttpService:JSONDecode(r.Body) end)
                if d and d.data then
                    local valid = {}
                    for _, srv in pairs(d.data) do
                        if srv.playing and srv.playing < (srv.maxPlayers or 12) - 1 and tostring(srv.id) ~= tostring(game.JobId) then
                            table.insert(valid, tostring(srv.id))
                        end
                    end
                    if #valid > 0 then 
                        HopLabel.Text = "HOP: Map Random!"
                        pcall(function() ReplicatedStorage:FindFirstChild("__ServerBrowser"):InvokeServer("teleport", valid[math.random(1, #valid)]) end) 
                    end
                end
            end
            task.delay(15, function() isHopping = false end)
        end)
    end

    local lastPos = Vector3.zero
    local lastMoveTime = tick()

    task.spawn(function()
        while task.wait(1) do
            local ok = pcall(function()
                if tick() - lastInvCheck > 30 then 
                    local inv = CommF_("getInventory")
                    if type(inv) == "table" then
                        local hasMirror, hasTushita, hasValkyrie = false, false, false
                        for _, item in pairs(inv) do
                            if type(item) == "table" and item.Name then
                                if item.Name == "Mirror Fractal" then hasMirror = true end
                                if item.Name == "Tushita" then hasTushita = true end
                                if item.Name == "Valkyrie Helm" then hasValkyrie = true end
                            end
                        end
                        needDough = not hasMirror
                        needIndra = not (hasTushita and hasValkyrie)
                    end
                    lastInvCheck = tick() 
                end

                local foundBosses = {}
                local function scan(folder)
                    for _, v in pairs(folder:GetChildren()) do
                        if table.find(BossList, v.Name) and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then table.insert(foundBosses, v.Name) end
                    end
                end
                if workspace:FindFirstChild("Enemies") then scan(workspace.Enemies) end
                scan(workspace)
                StatusLabel.Text = "FOUND: " .. #foundBosses .. " BOSS"

                if (AutoFindVIPBoss or AutoHopBoss) and game.PlaceId == 100117331123089 then
                    local hasVip = false
                    for _, b in pairs(foundBosses) do
                        if (b == "Dough King" and needDough) or (b == "rip_indra True Form" and needIndra) then hasVip = true; break end
                    end
                    if not hasVip and not isHopping and not _G.IsDoingAutoCDK and not _G.DoingElectricClaw then performHop(); lastMoveTime = tick() end
                end

                if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                    local pos = plr.Character.HumanoidRootPart.Position
                    if (pos - lastPos).Magnitude > 2 then lastPos = pos; lastMoveTime = tick() end
                else lastMoveTime = tick() end

                if tick() - lastMoveTime > 30000 and not isHopping and (AutoFindVIPBoss or AutoHopBoss) and not _G.IsDoingAutoCDK and not _G.DoingElectricClaw then
                    performHop(); lastMoveTime = tick()
                end
            end)
            if not ok then task.wait(1) end
        end
    end)
end)

-- =====================================================================
-- RACE MASTER (HOÀN CHỈNH)
-- =====================================================================
task.spawn(function()
    while task.wait(2) do
        if getLevel() >= levelThreshold then
            local raceCfg = bananaCfg
            _G.AutoReroll = raceCfg.AutoReroll or { Enable = true, FragThreshold = 3000, StopAt = {"Human", "Mink"} }
            _G.AutoRaceV2 = raceCfg.AutoRaceV2 ~= false
            _G.AutoRaceV3 = raceCfg.AutoRaceV3 ~= false
            _G.TweenSpeed = raceCfg.TweenSpeed or 300
            _G.HumanBosses = raceCfg.HumanBosses or {{Name = "Diamond", Pos = CFrame.new(-1587.7, 198.9, -111.4), Killed = false},{Name = "Jeremy", Pos = CFrame.new(2335.8, 449.2, 700.2), Killed = false},{Name = "Fajita", AltName = "Orbitus", Pos = CFrame.new(-2138.8, 73.3, -4315.8), Killed = false}}
            _G.CurrentAttacking = nil
            local API_NIGHT = "http://14.174.148.37:8080/get_cursedcaptain.php"
            local API_MARK_V = "http://14.174.148.37:8080/mark_visited.php"

            local function TP(cf)
                pcall(function()
                    local char = plr.Character
                    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
                    local root = char.HumanoidRootPart
                    local dist = (cf.Position - root.Position).Magnitude
                    local bv = root:FindFirstChild("AntiFall_Race")
                    if not bv then bv = Instance.new("BodyVelocity", root); bv.Name = "AntiFall_Race"; bv.MaxForce = Vector3.new(9e9, 9e9, 9e9); bv.Velocity = Vector3.zero end
                    local tween = TS:Create(root, TweenInfo.new(dist / _G.TweenSpeed, Enum.EasingStyle.Linear), {CFrame = cf})
                    local conn = RS.Stepped:Connect(function() for _, v in pairs(char:GetDescendants()) do if v:IsA("BasePart") then v.CanCollide = false end end end)
                    tween:Play(); tween.Completed:Wait(); conn:Disconnect()
                    if bv then bv:Destroy() end; task.wait(0.2)
                end)
            end

            local function ServerHopNight()
                local s, r = pcall(function() return game:HttpGet(API_NIGHT) end)
                if s and r ~= "" then
                    local d = HttpService:JSONDecode(r)
                    if type(d) == "table" then
                        for _, item in ipairs(d) do
                            local id = type(item) == "table" and item.job_id or item
                            if type(id) == "string" and id ~= "" and id ~= game.JobId then
                                pcall(function() game:HttpGet(API_MARK_V .. "?job_id=" .. id) end)
                                ReplicatedStorage:FindFirstChild("__ServerBrowser"):InvokeServer("teleport", id); task.wait(4)
                            end
                        end
                    end
                end
            end

            task.spawn(function()
                while task.wait(1.5) do
                    if _G.IsDoingAutoCDK or _G.DoingElectricClaw then return end
                    pcall(function()
                        local currentStatus = checkRaceV3()
                        if currentStatus == "V3" or currentStatus == "V4" then
                            local place = game.PlaceId; if (place == 4442272183 or place == 79091703265657) then CommF_("TravelZou"); task.wait(8) end
                            return
                        end
                        if not _G.AutoRaceV2 and not _G.AutoRaceV3 then return end
                        
                        local place = game.PlaceId
                        if not (place == 4442272183 or place == 79091703265657) then
                            CommF_("TravelDressrosa"); local waited = 0
                            repeat task.wait(1); waited = waited + 1; local np = game.PlaceId until (np == 4442272183 or np == 79091703265657) or waited > 30
                            if waited > 30 then return end; task.wait(3)
                        end

                        local race = plr.Data.Race.Value
                        if _G.AutoReroll.Enable then
                            local isTarget = false
                            for _, t in ipairs(_G.AutoReroll.StopAt) do if race:find(t) then isTarget = true break end end
                            if not isTarget and plr.Data.Fragments.Value >= _G.AutoReroll.FragThreshold then CommF_("BlackbeardReward", "Reroll", "1"); task.wait(0.5); CommF_("BlackbeardReward", "Reroll", "2"); task.wait(2); return end
                        end

                        local v2S = CommF_("Alchemist", "1")
                        if _G.AutoRaceV2 and v2S ~= -2 then
                            if v2S == 0 then CommF_("Alchemist", "2")
                            elseif v2S == 1 then
                                local function Has(n) for _, v in pairs(plr.Backpack:GetChildren()) do if v.Name:find(n) then return true end end for _, v in pairs(plr.Character:GetChildren()) do if v.Name:find(n) then return true end end return false end
                                if not Has("Flower 1") then if Lighting.ClockTime > 5 and Lighting.ClockTime < 17 then ServerHopNight() else local f = workspace:FindFirstChild("Flower1") or workspace:FindFirstChild("Blue Flower") if f then TP(f.CFrame) end end
                                elseif not Has("Flower 2") then local f = workspace:FindFirstChild("Flower2") or workspace:FindFirstChild("Red Flower") if f then TP(f.CFrame) end
                                elseif not Has("Flower 3") then _G.BringMob = true; _G.MonFarm = "Swan Pirate"; _G.FarmPos = CFrame.new(840, 122, 1240); TP(_G.FarmPos * CFrame.new(0, 30, 0)) end
                            elseif v2S == 2 then CommF_("Alchemist", "3") end
                            return
                        end

                        local v3S = CommF_("Wenlocktoad", "1")
                        if _G.AutoRaceV3 and v2S == -2 and v3S ~= -2 then
                            if v3S == 0 then CommF_("Wenlocktoad", "2") elseif v3S == 2 then CommF_("Wenlocktoad", "3") elseif v3S == 1 then
                                if race:find("Cyborg") then
                                    local hasF = false for _, t in pairs(plr.Character:GetChildren()) do if t:IsA("Tool") and (t.ToolTip == "Blox Fruit" or t.Name:find("Fruit")) then hasF = true break end end
                                    if not hasF then local inv = CommF_("getInventory"); if type(inv) == "table" then for _, i in pairs(inv) do if i.Name:find("Rocket") or i.Name:find("Spin") or i.Name:find("Spring") then CommF_("LoadFruit", i.Name); task.wait(1); local tool = plr.Backpack:FindFirstChild(i.Name); if tool then plr.Character.Humanoid:EquipTool(tool) end break end end end else CommF_("Wenlocktoad", "3") end
                                elseif race:find("Human") then
                                    local target = nil for _, b in ipairs(_G.HumanBosses) do if not b.Killed then target = b break end end
                                    if target then local bM = workspace.Enemies:FindFirstChild(target.Name) or workspace.Enemies:FindFirstChild(target.AltName or ""); if bM and bM:FindFirstChild("Humanoid") and bM.Humanoid.Health > 0 then _G.CurrentAttacking = target.Name; TP(bM.HumanoidRootPart.CFrame * CFrame.new(0, 5, 0)) else if _G.CurrentAttacking == target.Name then target.Killed = true; _G.CurrentAttacking = nil else TP(target.Pos * CFrame.new(0, 30, 0)) end end else CommF_("Wenlocktoad", "3") end
                                elseif race:find("Mink") then
                                    local char = plr.Character; if char and char:FindFirstChild("HumanoidRootPart") then local r = char.HumanoidRootPart; local nc, md = nil, math.huge; for _, o in pairs(workspace:GetDescendants()) do if o:IsA("Part") and o.Name:lower():find("chest") and not o:GetAttribute("Collected") then local d = (o.Position - r.Position).Magnitude; if d < md then md = d; nc = o end end end; if nc then TP(nc.CFrame); task.wait(0.2); nc:SetAttribute("Collected", true); nc:Destroy() end end
                                end
                            end
                        end
                    end)
                end
            end)
            break 
        end
    end
end)

print("⚡ ULTIMATE SCRIPT LOADED SUCCESS! ⚡")
