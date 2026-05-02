-- ==========================================
-- ULTIMATE VIP SCRIPT + AUTO CDK + RACE MASTER (NO KEY)
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
local VU = game:GetService("VirtualUser")
local GuiService = game:GetService("GuiService")
local VIM = game:GetService("VirtualInputManager")

local function CommF_(...)
    local remotes = ReplicatedStorage:FindFirstChild("Remotes")
    if remotes then
        local comm = remotes:FindFirstChild("CommF_")
        if comm then return comm:InvokeServer(...) end
    end
    return nil
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
    
    if char and char:FindFirstChild("RaceTransformed") then
        return "V4"
    end
    
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

-- =====================================================================
-- AUTO STORE FRUIT (TỰ CẤT TRÁI ÁC QUỶ) 🍎
-- =====================================================================
task.spawn(function()
    while task.wait(2) do
        pcall(function()
            local function storeFruit(tool)
                if tool:IsA("Tool") and (tool.ToolTip == "Blox Fruit" or string.find(tool.Name, "Fruit")) then
                    CommF_("StoreFruit", tool:GetAttribute("OriginalName") or tool.Name, tool)
                end
            end
            
            if plr.Backpack then
                for _, v in pairs(plr.Backpack:GetChildren()) do storeFruit(v) end
            end
            if plr.Character then
                for _, v in pairs(plr.Character:GetChildren()) do storeFruit(v) end
            end
        end)
    end
end)

-- =====================================================================
-- KIỂM TRA VŨ KHÍ (YAMA, TUSHITA, CDK)
-- =====================================================================
local function checkWeapon(weaponName)
    local bp = plr:FindFirstChild("Backpack")
    local char = plr.Character
    
    if bp and bp:FindFirstChild(weaponName) then return true end
    if char and char:FindFirstChild(weaponName) then return true end
    
    local inv = CommF_("getInventory")
    if type(inv) == "table" then
        for _, item in pairs(inv) do
            if item.Name == weaponName then return true end
        end
    end
    return false
end

local function hasYama() return checkWeapon("Yama") end
local function hasTushita() return checkWeapon("Tushita") end
local function hasCDK() return checkWeapon("Cursed Dual Katana") end

-- [⚡] BỘ NHỚ TẠM (CACHE) TÚI ĐỒ CHỐNG LAG SERVER (Dùng chung cho cả Kaitun và CDK)
local currentFrags = 0
local ym_mas_cache = 0
local ts_mas_cache = 0

task.spawn(function()
    while task.wait(2.5) do 
        pcall(function()
            local inv = CommF_("getInventory")
            if type(inv) == "table" then
                local f, ym, ts = 0, 0, 0
                for _, item in pairs(inv) do
                    if item.Name == "Alucard Fragment" then f = item.Count or 0 end
                    if item.Name == "Yama" then ym = item.Mastery or 0 end
                    if item.Name == "Tushita" then ts = item.Mastery or 0 end
                end
                currentFrags = f
                ym_mas_cache = ym
                ts_mas_cache = ts
            end
        end)
    end
end)

local function isDoingHazeQuest()
    if currentFrags == 4 or currentFrags == 5 then
        local progress = CommF_("CDKQuest", "Progress")
        if progress and progress.Evil then
            return true
        end
    end

    local questContainer = plr.PlayerGui:FindFirstChild("Main") 
        and plr.PlayerGui.Main:FindFirstChild("Quest") 
        and plr.PlayerGui.Main.Quest:FindFirstChild("Container")
    if questContainer then
        local titleFrame = questContainer:FindFirstChild("QuestTitle")
        if titleFrame then
            local textLabel = titleFrame:FindFirstChildOfClass("TextLabel") or titleFrame:FindFirstChild("Text")
            if textLabel and textLabel.Text then
                if textLabel.Text:find("Haze") then
                    return true
                end
            end
        end
    end

    return false
end

-- =====================================================================
-- CONFIG
-- =====================================================================
local config = _G.UltimateConfig or {}
local kaitunCfg = config.Kaitun or {}
local bananaCfg = config.BananaVIP or {}
local cdkCfg = config.AutoCDK or {}
local levelThreshold = config.LevelThreshold or 2500

-- =====================================================================
-- BIẾN TOÀN CỤC ĐIỀU KHIỂN
-- =====================================================================
_G.IsDoingAutoCDK = false   
_G.CDKPriority = false      

-- =====================================================================
-- HỆ THỐNG KAITUN 
-- =====================================================================
local KaitunLoaded = false
local function TryLoadKaitun()
    if not kaitunCfg.Enabled or KaitunLoaded then return end

    local doingHaze = isDoingHazeQuest()
    if not doingHaze and _G.IsDoingAutoCDK then
        return  
    end

    local currentLvl = getLevel()
    
    if currentLvl < levelThreshold then
        KaitunLoaded = true
        print("[Kaitun] Kích hoạt (Dưới level yêu cầu)")
        task.spawn(function()
            getgenv().Key = kaitunCfg.Key or ""
            getgenv().SettingFarm = kaitunCfg.SettingFarm or {}
            loadstring(game:HttpGet("https://raw.githubusercontent.com/obiiyeuem/vthangsitink/main/BananaCat-kaitunBF.lua"))()
        end)
        return
    end

    local requireV3 = (bananaCfg.AutoRaceV3 ~= false)

    if doingHaze or hasCDK() or ((not hasYama() or not hasTushita()) and not _G.IsDoingAutoCDK) then
        local raceStatus = checkRaceV3()
        if (raceStatus == "V3" or raceStatus == "V4") or not requireV3 then
            KaitunLoaded = true
            print("[Kaitun] Kích hoạt (Đủ điều kiện hoặc đã Skip Race V3)")
            task.spawn(function()
                getgenv().Key = kaitunCfg.Key or ""
                getgenv().SettingFarm = kaitunCfg.SettingFarm or {}
                loadstring(game:HttpGet("https://raw.githubusercontent.com/obiiyeuem/vthangsitink/main/BananaCat-kaitunBF.lua"))()
            end)
        else
            print("[Kaitun] Chưa có V3/V4, chờ Race Master...")
        end
    else
        print("[Kaitun] Tạm dừng (Đã có đủ Yama & Tushita hoặc Hệ thống AutoCDK đang xử lý)")
    end
end

task.spawn(function()
    while task.wait(5) do TryLoadKaitun() end
end)

-- =====================================================================
-- AUTO TEAM & CHỜ NHÂN VẬT
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

repeat task.wait(0.5) until plr and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")

-- =====================================================================
-- [⚡] TỰ ĐỘNG TẮT BẢNG LỖI TELEPORT 771 VÀ RESET HOP
-- =====================================================================
TeleportService.TeleportInitFailed:Connect(function()
    _G.IsHopping = false
end)

task.spawn(function()
    while task.wait(0.5) do
        pcall(function()
            local prompt = game:GetService("CoreGui"):FindFirstChild("RobloxPromptGui")
            if prompt then
                local overlay = prompt:FindFirstChild("promptOverlay")
                if overlay and overlay:FindFirstChild("ErrorPrompt") then
                    GuiService:ClearError() 
                    if _G.IsHopping then 
                        _G.IsHopping = false
                        print("🔄 Đã tắt bảng lỗi 771, chuẩn bị Hop server khác...")
                    end
                end
            end
        end)
    end
end)

-- =====================================================================
-- VIP BOSS TRACKER & HOPPER (NO KEY NEEDED)
-- =====================================================================
local AutoFindVIPBoss = bananaCfg.AutoFindVIPBoss or false
local AutoHopBoss = bananaCfg.AutoHopBoss or false
local hopAllowed = true -- Luôn cho phép Hop, đã gỡ Key

local request_func = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request

task.spawn(function()
    task.wait(5)

    local API_SAVE = "http://14.185.47.226:8080/save_boss.php"
    local API_INDRA = "http://14.185.47.226:8080/get_rip_indra.php"
    local API_DOUGH = "http://14.185.47.226:8080/get_doughking.php"

    local needDough = true
    local needIndra = true
    local lastInvCheck = 0

    local SEA3_IDS = { [100117331123089] = true, [7449423635] = true }
    local function GetCurrentSea() return SEA3_IDS[game.PlaceId] and 3 or 1 end

    local BossList = {
        "Stone", "Hydra Leader", "Kilo Admiral", "Captain Elephant", "Beautiful Pirate",
        "rip_indra True Form", "Dough King", "Soul Reaper", "Cake Queen", "Cake Prince",
        "Saber Expert", "Cursed Captain", "Longma", "Diamond", "Jeremy", "Orbitus"
    }
    local EliteList = {"Urban", "Deandre", "Diablo"}
    local PirateRaidMobs = {
        "Galley Pirate", "Galley Captain", "Raider", "Mercenary", "Vampire", "Zombie",
        "Snow Trooper", "Winter Warrior", "Lab Subordinate", "Horned Warrior",
        "Magma Ninja", "Lava Pirate", "Ship Deckhand", "Ship Engineer",
        "Ship Steward", "Ship Officer", "Arctic Warrior", "Snow Lurker",
        "Sea Soldier", "Water Fighter"
    }

    local Sec = 1
    local Boud = true
    local AutoAttack = true
    local AttackRange = 85
    local AttackSpeed = 0.006

    local Net
    pcall(function() Net = require(ReplicatedStorage:WaitForChild("Modules", 5):WaitForChild("Net", 5)) end)
    local RegisterAttack = Net and Net:RemoteEvent("RegisterAttack", true)
    local RegisterHit = Net and Net:RemoteEvent("RegisterHit", true)

    local HistoryFile = "BananaHopHistory.json"
    local VisitedServers = {}

    pcall(function()
        if isfile and isfile(HistoryFile) then
            local data = readfile(HistoryFile)
            local decoded = HttpService:JSONDecode(data)
            if type(decoded) == "table" then VisitedServers = decoded end
        end
    end)

    if not table.find(VisitedServers, tostring(game.JobId)) then
        table.insert(VisitedServers, tostring(game.JobId))
        if #VisitedServers > 50 then table.remove(VisitedServers, 1) end
        pcall(function() if writefile then writefile(HistoryFile, HttpService:JSONEncode(VisitedServers)) end end)
    end

    if SafeGuiParent:FindFirstChild("BananaProVIP_UI") then
        SafeGuiParent.BananaProVIP_UI:Destroy()
    end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "BananaProVIP_UI"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.DisplayOrder = 99990
    ScreenGui.Parent = SafeGuiParent

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
    Title.Text = "CONFIG BANANA PROVIP"
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

    local function CheckInventoryAndLevel()
        pcall(function()
            if getLevel() <= 2200 then needDough = false; needIndra = false; return end
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
        end)
    end

    local function IsMirageIsland()
        local map = workspace:FindFirstChild("Map")
        return map and map:FindFirstChild("MysticIsland") and "Có" or "Không"
    end

    local function CheckMoon()
        local sky = Lighting:FindFirstChild("Sky")
        if not sky then return "Không rõ" end
        local id = sky.MoonTextureId
        return id == "http://www.roblox.com/asset/?id=9709149431" and "Full Moon"
            or id == "http://www.roblox.com/asset/?id=9709149052" and "Next Night"
            or "Bad Moon"
    end

    local function CheckElite()
        local found = {}
        local function scan(folder)
            if not folder then return end
            for _, v in pairs(folder:GetChildren()) do
                if table.find(EliteList, v.Name) and v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") and v.Humanoid.Health > 0 then
                    if not table.find(found, v.Name) then table.insert(found, v.Name) end
                end
            end
        end
        scan(workspace:FindFirstChild("Enemies"))
        scan(workspace)
        return #found > 0 and table.concat(found, ", ") or "Không"
    end

    local function CheckPirateRaid()
        if GetCurrentSea() ~= 3 then return "Không" end
        for _, mob in pairs(PirateRaidMobs) do if ReplicatedStorage:FindFirstChild(mob) then return "Đang diễn ra" end end
        local center = Vector3.new(-5539.31, 313.80, -2972.37)
        local enemies = workspace:FindFirstChild("Enemies")
        if enemies then
            for _, v in pairs(enemies:GetChildren()) do
                if table.find(PirateRaidMobs, v.Name) and v:FindFirstChild("HumanoidRootPart") and v.Humanoid.Health > 0 then
                    if (v.HumanoidRootPart.Position - center).Magnitude <= 1000 then return "Đang diễn ra" end
                end
            end
        end
        return "Không"
    end

    task.spawn(function()
        while wait(Sec) do
            pcall(function()
                if Boud and plr.Character and not plr.Character:FindFirstChild("HasBuso") then
                    CommF_("Buso")
                end
            end)
        end
    end)

    local function EquipMeleeIfNeeded()
        if not plr.Character then return end
        local hum = plr.Character:FindFirstChildOfClass("Humanoid")
        if not hum then return end
        local cur = plr.Character:FindFirstChildOfClass("Tool")
        if cur and (cur:FindFirstChild("Handle") or cur.ToolTip:lower():find("sword") or cur.ToolTip:lower():find("melee")) then
            return true
        end
        local melee = nil
        for _, t in ipairs(plr.Backpack:GetChildren()) do
            if t:IsA("Tool") and (t:FindFirstChild("Handle") or t.ToolTip:lower():find("sword") or t.ToolTip:lower():find("melee")) then
                melee = t; break
            end
        end
        if melee then hum:EquipTool(melee); return true end
        for _, t in ipairs(plr.Backpack:GetChildren()) do
            if t:IsA("Tool") then hum:EquipTool(t); return true end
        end
        return false
    end

    local function Attack()
        if _G.IsDoingAutoCDK then return end  
        if not AutoAttack then return end
        
        local char = plr.Character
        if not char or char.Humanoid.Health <= 0 then return end
        
        EquipMeleeIfNeeded()
        
        local targets = {}
        local pos = char.HumanoidRootPart.Position
        for _, v in pairs(workspace.Enemies:GetChildren()) do
            if not game.Players:GetPlayerFromCharacter(v) and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 and v:FindFirstChild("HumanoidRootPart") then
                if (v.HumanoidRootPart.Position - pos).Magnitude <= AttackRange then
                    table.insert(targets, {v, v.HumanoidRootPart})
                end
            end
        end
        
        if #targets > 0 then
            if RegisterAttack then RegisterAttack:FireServer(0) end
            if RegisterHit then pcall(function() RegisterHit:FireServer(targets[1][1]:FindFirstChild("Head") or targets[1][2], targets) end) end
            
            local equippedTool = char:FindFirstChildOfClass("Tool")
            if equippedTool and equippedTool:FindFirstChild("LeftClick") then 
                equippedTool.LeftClick:FireServer() 
            end
        end
    end

    task.spawn(function()
        while true do if AutoAttack then pcall(Attack) end task.wait(AttackSpeed) end
    end)

    local isHopping = false

    local function performHop()
        if _G.IsDoingAutoCDK then
            HopLabel.Text = "HOP: Bị chặn (đang Auto CDK)"
            return
        end
        if isHopping then return end
        if tick() - (_G.LastHopTime or 0) < 15 then return end
        isHopping = true
        _G.LastHopTime = tick()

        if needIndra or needDough then
            HopLabel.Text = "HOP: Đang quét DB VIP..."
            local vip = {}
            local function fetch(url, bossName)
                local s, r = pcall(function() return game:HttpGet(url) end)
                if not s or r == "" then return end
                local successDecode, d = pcall(function() return HttpService:JSONDecode(r) end)
                if not successDecode or type(d) ~= "table" then return end
                for _, srv in pairs(d) do
                    local players = tonumber(string.match(tostring(srv.players or ""), "^(%d+)")) or 0
                    if tostring(srv.place_id) == tostring(game.PlaceId) and players <= 10 and not table.find(VisitedServers, tostring(srv.job_id)) then
                        table.insert(vip, tostring(srv.job_id))
                    end
                end
            end
            if needIndra then fetch(API_INDRA, "Rip Indra") end
            if needDough then fetch(API_DOUGH, "Dough King") end
            if #vip > 0 then
                local target = vip[math.random(1, #vip)]
                HopLabel.Text = "HOP: Đang vào phòng VIP..."
                pcall(function() ReplicatedStorage:FindFirstChild("__ServerBrowser"):InvokeServer("teleport", target) end)
                task.delay(5, function() isHopping = false end)
                return
            end
        end

        HopLabel.Text = "HOP: Đang đi dò Map Random..."
        task.spawn(function()
            local s, r = pcall(function()
                return request_func({
                    Url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Desc&limit=100",
                    Method = "GET"
                })
            end)
            if s and r and r.Body then
                local success, d = pcall(function() return HttpService:JSONDecode(r.Body) end)
                if success and d and d.data then
                    local valid = {}
                    for _, srv in pairs(d.data) do
                        if srv.playing and srv.playing <= 10 and tostring(srv.id) ~= tostring(game.JobId) and not table.find(VisitedServers, tostring(srv.id)) then
                            table.insert(valid, tostring(srv.id))
                        end
                    end
                    if #valid > 0 then
                        local target = valid[math.random(1, #valid)]
                        pcall(function() ReplicatedStorage:FindFirstChild("__ServerBrowser"):InvokeServer("teleport", target) end)
                    end
                end
            end
            task.delay(5, function() isHopping = false end)
        end)
    end

    local function HopToVIPBoss()
        if not (AutoFindVIPBoss or AutoHopBoss) then return end
        if hopAllowed then performHop() else HopLabel.Text = "HOP: Bị lỗi!" end
    end

    task.spawn(function()
        while true do
            task.wait(30)
            if plr and (not plr.Character or not plr.Character:FindFirstChild("HumanoidRootPart")) then
                pcall(function() CommF_("SetTeam", "Pirates") end)
                task.wait(5)
                if not plr.Character or not plr.Character:FindFirstChild("HumanoidRootPart") and AutoHopBoss then
                    if not _G.IsDoingAutoCDK then HopToVIPBoss() end
                end
            end
        end
    end)

    local AFK_TIMEOUT = 30000
    local lastPos = Vector3.zero
    local lastMoveTime = tick()

    task.spawn(function()
        while true do
            local ok = pcall(function()
                if tick() - lastInvCheck > 30 then
                    CheckInventoryAndLevel()
                    lastInvCheck = tick()
                end

                local foundBosses = {}
                local seen = {}
                local function scan(folder)
                    if not folder then return end
                    for _, v in pairs(folder:GetChildren()) do
                        if table.find(BossList, v.Name) and not seen[v.Name] and v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") and v.Humanoid.Health > 0 then
                            seen[v.Name] = true
                            table.insert(foundBosses, v.Name)
                        end
                    end
                end
                scan(workspace:FindFirstChild("Enemies"))
                scan(workspace)

                StatusLabel.Text = "FOUND: " .. #foundBosses .. " BOSS"

                local payload = {
                    boss_name = #foundBosses > 0 and table.concat(foundBosses, ", ") or "None",
                    elite = CheckElite(),
                    place_id = tostring(game.PlaceId),
                    job_id = tostring(game.JobId),
                    players = #Players:GetPlayers() .. "/" .. Players.MaxPlayers,
                    mirage = IsMirageIsland(),
                    full_moon = GetCurrentSea() == 3 and CheckMoon() or "Không",
                    pirate_raid = CheckPirateRaid()
                }

                pcall(function()
                    request_func({
                        Url = API_SAVE,
                        Method = "POST",
                        Headers = { ["Content-Type"] = "application/json", ["Bypass-Tunnel-Reminder"] = "true" },
                        Body = HttpService:JSONEncode(payload)
                    })
                end)

                if (AutoFindVIPBoss or AutoHopBoss) and game.PlaceId == 100117331123089 then
                    local hasVip = false
                    for _, b in pairs(foundBosses) do
                        if (b == "Dough King" and needDough) or (b == "rip_indra True Form" and needIndra) then
                            hasVip = true; break
                        end
                    end
                    if not hasVip and not isHopping and not _G.IsDoingAutoCDK then
                        HopToVIPBoss()
                        lastMoveTime = tick()
                    end
                end

                if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                    local pos = plr.Character.HumanoidRootPart.Position
                    if (pos - lastPos).Magnitude > 2 then
                        lastPos = pos
                        lastMoveTime = tick()
                    end
                else
                    lastMoveTime = tick()
                end

                if tick() - lastMoveTime > AFK_TIMEOUT and not isHopping and (AutoFindVIPBoss or AutoHopBoss) and not _G.IsDoingAutoCDK then
                    HopToVIPBoss()
                    lastMoveTime = tick()
                end
            end)
            if not ok then warn("[VIP Tracker] Lỗi vòng lặp: " .. tostring(ok)) end
            task.wait(1)
        end
    end)
    print("⚡ VIP TRACKER & HOPPER: Loaded without Key")
end)

-- =====================================================================
-- HỆ THỐNG ƯU TIÊN & AUTO CDK 
-- =====================================================================
if cdkCfg.Enabled then
    _G.Auto_DualKatana = false   
    _G.TargetMastery = cdkCfg.TargetMastery or 350
    _G.HeightFarm = 40
    _G.AutoFarm_Bone = false
    _G.BringMob = true
    _G.IsHopping = false
    _G.LastHopTime = 0
    _G.CurrentSword = "Tushita"
    _G.IsTakingDamage = false
    _G.IsResetting = false
    _G.IsWalkingBoss = false
    _G.HzIdx = 1
    _G.NeedResetFromSubmerged = false
    _G.BossDoorStep = 1
    _G.BossWaitTimer = nil
    _G.CQDeadTimer = nil
    _G.DealerStep = 1

    local Pos = CFrame.new(0, _G.HeightFarm, 0)
    local API_SOUL_REAPER = "http://14.185.47.226:8080/get_soulreaper.php"
    local API_CAKE_QUEEN = "http://14.185.47.226:8080/get_cakequeen.php"
    local API_PIRATE_RAID = "http://14.185.47.226:8080/get_pirateraid.php"

    local Net = require(ReplicatedStorage.Modules.Net)
    local RegisterAttack = Net:RemoteEvent("RegisterAttack", true)
    local RegisterHit = Net:RemoteEvent("RegisterHit", true)

    local function AttackNoCoolDown()
        pcall(function()
            local char = plr.Character
            if not char or char.Humanoid.Health <= 0 then return end
            
            local targets = {}
            for _, v in pairs(workspace.Enemies:GetChildren()) do
                if not game.Players:GetPlayerFromCharacter(v) and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 and v:FindFirstChild("HumanoidRootPart") then
                    if (v.HumanoidRootPart.Position - char.HumanoidRootPart.Position).Magnitude <= 100 then 
                        table.insert(targets, {v, v.HumanoidRootPart}) 
                    end
                end
            end
            
            if #targets > 0 then
                RegisterAttack:FireServer(0)
                RegisterHit:FireServer(targets[1][1]:FindFirstChild("Head") or targets[1][2], targets)
                
                local equippedTool = char:FindFirstChildOfClass("Tool")
                if equippedTool and equippedTool:FindFirstChild("LeftClick") then 
                    equippedTool.LeftClick:FireServer() 
                end
            end
        end)
    end

local function EquipSword(itemName)
    local char = plr.Character
    if not char or char.Humanoid.Health <= 0 then return end

    if _G.IsTakingDamage then
        char.Humanoid:UnequipTools()
        return
    end

    local toolInChar = char:FindFirstChild(itemName)
    local toolInBack = plr.Backpack:FindFirstChild(itemName)

    if not toolInChar and not toolInBack then
        pcall(function() CommF_("LoadItem", itemName) end)
        task.wait(0.2)
        toolInBack = plr.Backpack:FindFirstChild(itemName)
    end

    if toolInBack and not toolInChar then
        char.Humanoid:EquipTool(toolInBack)
    end
end

    local function Tween2(targetCFrame)
        pcall(function()
            local char = plr.Character
            if not char or not char:FindFirstChild("HumanoidRootPart") or char.Humanoid.Health <= 0 then return end
            local Root = char.HumanoidRootPart
            local dist = (targetCFrame.Position - Root.Position).Magnitude
            if dist < 5 then Root.CFrame = targetCFrame; return end
            if not Root:FindFirstChild("BodyVelocity") then
                local bv = Instance.new("BodyVelocity", Root)
                bv.MaxForce = Vector3.new(9e9, 9e9, 9e9); bv.Velocity = Vector3.zero
            end
            if _G.CurrentTween and _G.CurrentTweenTarget and (_G.CurrentTweenTarget.Position - targetCFrame.Position).Magnitude < 10 then
                if _G.CurrentTween.PlaybackState == Enum.PlaybackState.Playing then return end
            end
            if _G.CurrentTween then _G.CurrentTween:Cancel() end
            _G.CurrentTweenTarget = targetCFrame
            _G.CurrentTween = TS:Create(Root, TweenInfo.new(dist/315, Enum.EasingStyle.Linear), {CFrame = targetCFrame})
            _G.CurrentTween:Play()
        end)
    end

    local function BKP(targetCFrame)
        pcall(function()
            local char = plr.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                if _G.CurrentTween then _G.CurrentTween:Cancel() end
                char.HumanoidRootPart.CFrame = targetCFrame
                if not char.HumanoidRootPart:FindFirstChild("BodyVelocity") then
                    local bv = Instance.new("BodyVelocity", char.HumanoidRootPart)
                    bv.MaxForce = Vector3.new(9e9, 9e9, 9e9); bv.Velocity = Vector3.zero
                end
            end
        end)
    end

    local function SmartMove(targetCFrame)
        local char = plr.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") then return end
        local dist = (targetCFrame.Position - char.HumanoidRootPart.Position).Magnitude
        if dist > 50 then Tween2(targetCFrame) else BKP(targetCFrame) end
    end

    local function AutoHopCDK(apiUrl, reason)
        if _G.IsHopping then return end
        if tick() - (_G.LastHopTime or 0) < 15 then return end 
        _G.IsHopping = true; _G.LastHopTime = tick() 
        print("⏳ Đang gọi API Server: " .. reason)
        
        task.spawn(function()
            local targetJobId = nil
            local success, result = pcall(function() return game:HttpGet(apiUrl) end)
            if success and result and result ~= "" then
                local s2, data = pcall(function() return HttpService:JSONDecode(result) end)
                if s2 and type(data) == "table" then
                    for _, srv in pairs(data) do
                        local plrs = tonumber(string.match(tostring(srv.players or ""), "^(%d+)")) or 0
                        if srv.job_id and srv.job_id ~= game.JobId and not _G.BlacklistedServers[srv.job_id] and plrs <= 10 then
                            targetJobId = srv.job_id; break
                        end
                    end
                end
            end
            
            if not targetJobId then
                print("⚠️ API rỗng hoặc Server Full! Đang dò Random Server thay thế...")
                local s3, res3 = pcall(function() return HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100")) end)
                if s3 and res3 and res3.data then
                    for _, v in pairs(res3.data) do
                        if type(v) == "table" and v.playing and v.playing <= 10 and v.id ~= game.JobId and not _G.BlacklistedServers[v.id] then
                            targetJobId = v.id; break
                        end
                    end
                end
            end
            
            if targetJobId then
                local hasEssence = plr.Backpack:FindFirstChild("Hallow Essence") or (plr.Character and plr.Character:FindFirstChild("Hallow Essence"))
                if reason == "Tìm Soul Reaper" and hasEssence then
                    print("✅ Đã Roll ra Hallow Essence, Hủy Hop Server!")
                    _G.IsHopping = false
                    return
                end
                _G.BlacklistedServers = _G.BlacklistedServers or {}
                _G.BlacklistedServers[targetJobId] = true 
                print("✈️ Bay đến Server (Đảm bảo không Full): " .. targetJobId)
                pcall(function() ReplicatedStorage.__ServerBrowser:InvokeServer("teleport", targetJobId) end)
            end
            task.wait(5); _G.IsHopping = false
        end)
    end

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

    RS.Stepped:Connect(function()
        pcall(function()
            if (_G.Auto_DualKatana or _G.AutoFarm_Bone) and not _G.IsResetting and not _G.IsWalkingBoss then
                local char = plr.Character
                if char and char:FindFirstChild("HumanoidRootPart") then
                    local humanoid = char:FindFirstChild("Humanoid")
                    if humanoid and humanoid.Health > 0 then
                        for _, part in pairs(char:GetDescendants()) do
                            if part:IsA("BasePart") and part.CanCollide then part.CanCollide = false end
                        end
                        humanoid:ChangeState(11)
                    end
                end
            end
        end)
    end)

    local BoneMobs = {"Reborn Skeleton", "Living Zombie", "Demonic Soul", "Posessed Mummy"}
    local Auto_Quest_Yama_1, Auto_Quest_Yama_2, Auto_Quest_Yama_3 = false, false, false
    local Auto_Quest_Tushita_1, Auto_Quest_Tushita_2, Auto_Quest_Tushita_3 = false, false, false
    local Auto_Quest_Boss = false 

    -- ===== VÒNG LẶP MASTERY =====
    task.spawn(function()
        while task.wait(1) do
            if _G.Auto_DualKatana then
                pcall(function()
                    if currentFrags < 6 then
                        if _G.CurrentSword == "Tushita" then
                            if ts_mas_cache < _G.TargetMastery then _G.AutoFarm_Bone = true
                            else _G.CurrentSword = "Yama" end
                        elseif _G.CurrentSword == "Yama" then
                            if ym_mas_cache < _G.TargetMastery then _G.AutoFarm_Bone = true
                            else _G.AutoFarm_Bone = false end
                        end
                    else
                        _G.AutoFarm_Bone = false
                    end
                end)
            end
        end
    end)

    -- ===== LUỒNG FARM XƯƠNG =====
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

    -- ===== LUỒNG QUEST CHÍNH =====
    task.spawn(function()
        while task.wait(0.5) do
            if _G.Auto_DualKatana then
                if _G.AutoFarm_Bone then
                    Auto_Quest_Yama_1, Auto_Quest_Yama_2, Auto_Quest_Yama_3 = false, false, false
                    Auto_Quest_Tushita_1, Auto_Quest_Tushita_2, Auto_Quest_Tushita_3 = false, false, false
                    Auto_Quest_Boss = false
                else
                    pcall(function()
                        local frags = currentFrags
                        _G.IsTakingDamage = false
                        if frags == 3 then _G.IsTakingDamage = true end
                        if frags == 5 and not workspace.Map:FindFirstChild("HellDimension") then
                            if workspace.Enemies:FindFirstChild("Soul Reaper") then _G.IsTakingDamage = true end
                        end
                        if not _G.IsTakingDamage then
                            EquipSword(_G.CurrentSword)
                        end
                        
                        Auto_Quest_Yama_1, Auto_Quest_Yama_2, Auto_Quest_Yama_3 = false, false, false
                        Auto_Quest_Tushita_1, Auto_Quest_Tushita_2, Auto_Quest_Tushita_3 = false, false, false
                        Auto_Quest_Boss = false

                        if frags == 6 then
                            Auto_Quest_Boss = true 
                        elseif frags == 5 then Auto_Quest_Yama_3 = true; CommF_("CDKQuest", "StartTrial", "Evil")
                        elseif frags == 4 then Auto_Quest_Yama_2 = true; CommF_("CDKQuest", "StartTrial", "Evil")
                        elseif frags == 3 then Auto_Quest_Yama_1 = true; CommF_("CDKQuest", "StartTrial", "Evil")
                        elseif frags == 2 then Auto_Quest_Tushita_3 = true; CommF_("CDKQuest", "StartTrial", "Good")
                        elseif frags == 1 then Auto_Quest_Tushita_2 = true; CommF_("CDKQuest", "StartTrial", "Good")
                        elseif frags == 0 then 
                            if not isDoingHazeQuest() then
                                Auto_Quest_Tushita_1 = true; 
                                CommF_("CDKQuest", "StartTrial", "Good")
                            end
                        end
                    end)
                end
            end
        end
    end)

    -- ====================================================
    -- ⚡ CDK BOSS (TỰ ĐỘNG ĐI KÍCH HOẠT VÀ ĐÁNH BOSS)
    -- ====================================================
    task.spawn(function()
        while task.wait() do
            if Auto_Quest_Boss and not _G.AutoFarm_Bone then
                pcall(function()
                    local boss = workspace.Enemies:FindFirstChild("Cursed Skeleton Boss")
                    
                    if boss and boss.Humanoid.Health > 0 then 
                        _G.IsWalkingBoss = false 
                        EquipSword(_G.CurrentSword)
                        SmartMove(boss.HumanoidRootPart.CFrame * Pos)
                        AttackNoCoolDown()
                    else
                        local tushitaScroll = CFrame.new(-12391.3, 603.6, -6596.8)
                        local yamaScroll = CFrame.new(-12391.4, 603.6, -6502.5)
                        local stonePillar = CFrame.new(-12357.7, 603.6, -6551.8) 
                        local bossRoom = CFrame.new(-12264.8, 599.2, -6560.8)    

                        if (plr.Character.HumanoidRootPart.Position - stonePillar.Position).Magnitude > 150 then
                            _G.IsWalkingBoss = false
                            SmartMove(stonePillar)
                        else
                            _G.IsWalkingBoss = true 

                            local function clickToSkip()
                                pcall(function()
                                    local cam = workspace.CurrentCamera
                                    VIM:SendMouseButtonEvent(cam.ViewportSize.X/2, cam.ViewportSize.Y/2, 0, true, game, 0)
                                    task.wait(0.1)
                                    VIM:SendMouseButtonEvent(cam.ViewportSize.X/2, cam.ViewportSize.Y/2, 0, false, game, 0)
                                end)
                            end

                            if _G.CurrentTween then _G.CurrentTween:Cancel() end
                            pcall(function()
                                local bv = plr.Character.HumanoidRootPart:FindFirstChild("BodyVelocity")
                                if bv then bv:Destroy() end
                            end)

                            plr.Character.HumanoidRootPart.CFrame = tushitaScroll
                            task.wait(0.5); VIM:SendKeyEvent(true, Enum.KeyCode.E, false, game); task.wait(0.5); clickToSkip(); task.wait(0.5)
                            
                            plr.Character.HumanoidRootPart.CFrame = yamaScroll
                            task.wait(0.5); VIM:SendKeyEvent(true, Enum.KeyCode.E, false, game); task.wait(0.5); clickToSkip(); task.wait(0.5)
                            
                            plr.Character.HumanoidRootPart.CFrame = stonePillar
                            task.wait(0.5); VIM:SendKeyEvent(true, Enum.KeyCode.E, false, game); task.wait(0.5); clickToSkip(); task.wait(0.5)
                            
                            plr.Character.HumanoidRootPart.CFrame = bossRoom
                            task.wait(0.5) 
                            
                            for i = 1, 15 do 
                                task.wait(0.5) 
                                if workspace.Enemies:FindFirstChild("Cursed Skeleton Boss") or not plr.Character or plr.Character.Humanoid.Health <= 0 then
                                    pcall(function() plr.Character.Humanoid:MoveTo(plr.Character.HumanoidRootPart.Position) end) 
                                    break 
                                end
                                pcall(function() plr.Character.Humanoid:MoveTo(stonePillar.Position) end)
                            end
                            
                            CommF_("CDKQuest", "BuyCDK") 
                            _G.IsWalkingBoss = false 
                        end
                    end
                end)
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

-- Yama Q2 (Kaitun của Sếp)
task.spawn(function()
    while task.wait(3) do
        if Auto_Quest_Yama_2 and not _G.AutoFarm_Bone then
            pcall(function()
                if not _G.KaitunHazeLoaded then
                    _G.KaitunHazeLoaded = true
                    print("🎯 Yama Q2 (Haze): Đang load Kaitun Cá Nhân để làm Sương Mù...")
                    task.spawn(function()
                        getgenv().Key = kaitunCfg.Key or ""
                        getgenv().SettingFarm = kaitunCfg.SettingFarm or {}
                        loadstring(game:HttpGet("https://raw.githubusercontent.com/obiiyeuem/vthangsitink/main/BananaCat-kaitunBF.lua"))()
                    end)
                end
                _G.Auto_DualKatana = false 
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
                if hell and (plr.Character.HumanoidRootPart.Position - hell.Spawn.Position).Magnitude < 3000 then
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
                            local bv = plr.Character.HumanoidRootPart:FindFirstChild("BodyVelocity")
                            if bv then bv:Destroy() end
                            plr.Character.HumanoidRootPart.CFrame = exitP.CFrame
                        end
                    end
                else
                    local reaper = workspace.Enemies:FindFirstChild("Soul Reaper")
                    if reaper and reaper.Humanoid.Health > 0 then
                        print("Yama Q3: Hứng đòn từ Soul Reaper...")
                        SmartMove(reaper.HumanoidRootPart.CFrame * CFrame.new(0,0,-2))
                    else
                        if plr.Backpack:FindFirstChild("Hallow Essence") or plr.Character:FindFirstChild("Hallow Essence") then
                            print("Yama Q3: Đang đem Hallow Essence đi triệu hồi Boss...")
                            local altarPos = CFrame.new(-8932.32, 146.83, 6062.55)
                            Tween2(altarPos)
                            if (altarPos.Position - plr.Character.HumanoidRootPart.Position).Magnitude <= 10 then
                                EquipSword("Hallow Essence")
                            end
                        else
                            AutoHopCDK(API_SOUL_REAPER, "Tìm Soul Reaper")
                            
                            local bones = CommF_("Bones", "Check") or 0
                            if bones >= 50 then
                                print("Yama Q3: Đủ 50 Xương, Đang bay đi Random...")
                                Tween2(CFrame.new(-9570, 315, 6726))
                                if (plr.Character.HumanoidRootPart.Position - CFrame.new(-9570, 315, 6726).Position).Magnitude < 100 then
                                    CommF_("Bones", "Buy", 1, 1)
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
                                    if not _G.IsTakingDamage then
    EquipSword(_G.CurrentSword)
end
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
_G.DealerStep = _G.DealerStep or 1
task.spawn(function()
    while task.wait() do
        if Auto_Quest_Tushita_1 and not _G.AutoFarm_Bone then
            pcall(function()
                if isDoingHazeQuest() then
                    return
                end
                
                local progress = CommF_("CDKQuest", "Progress")
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
                    local char = plr.Character
                    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
                    local root = char.HumanoidRootPart
                    local dist = (root.Position - target.Position).Magnitude

                    if dist > 15 then
                        Tween2(target)
                    else
                        if root:FindFirstChild("BodyVelocity") then root.BodyVelocity:Destroy() end
                        root.CFrame = target
                        task.wait(1)
                        
                        local npc = workspace.NPCs:FindFirstChild("Luxury Boat Dealer")
                        if npc then
                            CommF_("CDKQuest", "BoatQuest", npc, "Check")
                            task.wait(0.5)
                            CommF_("CDKQuest", "BoatQuest", npc)
                        end
                        
                        task.wait(2)
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
    local lastHopCheck = 0
    while task.wait() do
        if Auto_Quest_Tushita_2 and not _G.AutoFarm_Bone then
            pcall(function()
                if (CFrame.new(-5539, 313, -2972).Position - plr.Character.HumanoidRootPart.Position).Magnitude > 500 then
                    Tween2(CFrame.new(-5545, 313, -2976))
                else
                    local p = nil
                    local PirateRaidMobs = {"Galley Pirate", "Galley Captain", "Raider", "Mercenary", "Vampire", "Zombie", "Snow Trooper", "Winter Warrior", "Lab Subordinate", "Horned Warrior", "Magma Ninja", "Lava Pirate", "Ship Deckhand", "Ship Engineer", "Ship Steward", "Ship Officer", "Arctic Warrior", "Snow Lurker", "Sea Soldier", "Water Fighter"}
                    
                    for _, v in pairs(workspace.Enemies:GetChildren()) do 
                        if v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 and (v.HumanoidRootPart.Position - plr.Character.HumanoidRootPart.Position).Magnitude < 1500 then 
                            if table.find(PirateRaidMobs, v.Name) or string.find(v.Name, "Raid") then
                                p = v; break 
                            end
                            if not p then p = v end
                        end 
                    end
                    
                    if p then 
                        EquipSword(_G.CurrentSword)
                        SmartMove(p.HumanoidRootPart.CFrame * Pos)
                        p.HumanoidRootPart.Size = Vector3.new(60, 60, 60)
                        _G.MonFarm = p.Name 
                        _G.FarmPos = p.HumanoidRootPart.CFrame
                        AttackNoCoolDown() 
                    else 
                        if tick() - lastHopCheck > 5 then
                            lastHopCheck = tick()
                            AutoHopCDK(API_PIRATE_RAID, "Tìm Pirate Raid") 
                        end
                    end
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
                if heav and (plr.Character.HumanoidRootPart.Position - heav.Spawn.Position).Magnitude < 3000 then
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
                                local bv = plr.Character.HumanoidRootPart:FindFirstChild("BodyVelocity")
                                if bv then bv:Destroy() end
                                plr.Character.HumanoidRootPart.CFrame = exitP.CFrame
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
                        if (plr.Character.HumanoidRootPart.Position - Vector3.new(-709, 381, -11011)).Magnitude < 200 then
                            if not _G.CQDeadTimer then _G.CQDeadTimer = tick() end
                            if tick() - _G.CQDeadTimer > 7 then AutoHopCDK(API_CAKE_QUEEN, "Tìm Cake Queen") end
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
                            sethiddenproperty(plr, "SimulationRadius", math.huge)
                        end
                    end
                end
            end
        end)
    end
end)

    -- ===== HỆ THỐNG QUYẾT ĐỊNH KHI NÀO BẬT AUTO CDK =====
    task.spawn(function()
        while task.wait(3) do
            pcall(function()
                if not cdkCfg.Enabled then return end
                local hasY = hasYama()
                local hasT = hasTushita()
                local hasC = hasCDK()
                local raceStatus = checkRaceV3()
                
                local requireV3 = (bananaCfg.AutoRaceV3 ~= false)

                if hasC then
                    if _G.Auto_DualKatana then
                        _G.Auto_DualKatana = false
                        _G.IsDoingAutoCDK = false
                        print("[Auto CDK] Đã sở hữu CDK, dừng Auto CDK.")
                    end
                    return
                end

                if hasY and hasT and not hasC then
                    if requireV3 and (raceStatus ~= "V3" and raceStatus ~= "V4") then
                        if _G.Auto_DualKatana then
                            _G.Auto_DualKatana = false
                            _G.IsDoingAutoCDK = false
                            print("[Auto CDK] Tạm dừng - Ưu tiên lấy V3 trước.")
                        end
                        return
                    else
                        if not _G.Auto_DualKatana then
                            _G.Auto_DualKatana = true
                            _G.IsDoingAutoCDK = true
                            print("[Auto CDK] Bắt đầu Auto CDK!")
                        end
                        return
                    end
                end

                if _G.Auto_DualKatana then
                    _G.Auto_DualKatana = false
                    _G.IsDoingAutoCDK = false
                    print("[Auto CDK] Chưa có đủ Yama + Tushita, dừng Auto CDK.")
                end
            end)
        end
    end)
end

-- =====================================================================
-- RACE MASTER
-- =====================================================================
task.spawn(function()
    while task.wait(2) do
        if getLevel() >= levelThreshold then
            local raceCfg = bananaCfg
            _G.AutoReroll = raceCfg.AutoReroll or { Enable = true, FragThreshold = 3000, StopAt = {"Human", "Mink"} }
            _G.AutoCyborgV1 = false
            _G.AutoRaceV2 = raceCfg.AutoRaceV2 ~= false
            _G.AutoRaceV3 = raceCfg.AutoRaceV3 ~= false
            _G.TweenSpeed = raceCfg.TweenSpeed or 300
            _G.BringMob = raceCfg.BringMob or false
            _G.MonFarm = raceCfg.MonFarm or ""
            _G.FarmPos = raceCfg.FarmPos
            _G.HumanBosses = raceCfg.HumanBosses or {
                {Name = "Diamond", Pos = CFrame.new(-1587.7, 198.9, -111.4), Killed = false},
                {Name = "Jeremy", Pos = CFrame.new(2335.8, 449.2, 700.2), Killed = false},
                {Name = "Fajita", AltName = "Orbitus", Pos = CFrame.new(-2138.8, 73.3, -4315.8), Killed = false}
            }
            _G.CurrentAttacking = nil

            local API_NIGHT = "http://14.185.47.226:8080/get_cursedcaptain.php"
            local API_MARK_V = "http://14.185.47.226:8080/mark_visited.php"

            local function TP(cf)
                pcall(function()
                    local char = plr.Character
                    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
                    local root = char.HumanoidRootPart
                    local dist = (cf.Position - root.Position).Magnitude
                    
                    if dist < 300 then
                        root.CFrame = cf
                        local bv = root:FindFirstChild("AntiFall_Race")
                        if not bv then
                            bv = Instance.new("BodyVelocity", root)
                            bv.Name = "AntiFall_Race"
                            bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
                            bv.Velocity = Vector3.zero
                        end
                        return
                    end
                    
                    local bv = root:FindFirstChild("AntiFall_Race")
                    if not bv then
                        bv = Instance.new("BodyVelocity", root)
                        bv.Name = "AntiFall_Race"
                        bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
                        bv.Velocity = Vector3.zero
                    end
                    local tween = TS:Create(root, TweenInfo.new(dist / _G.TweenSpeed, Enum.EasingStyle.Linear), {CFrame = cf})
                    local conn = RS.Stepped:Connect(function()
                        for _, v in pairs(char:GetDescendants()) do if v:IsA("BasePart") then v.CanCollide = false end end
                    end)
                    tween:Play()
                    tween.Completed:Wait()
                    conn:Disconnect()
                    if bv then bv:Destroy() end
                    task.wait(0.2)
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
                                ReplicatedStorage:FindFirstChild("__ServerBrowser"):InvokeServer("teleport", id)
                                task.wait(4)
                            end
                        end
                    end
                end
            end

            task.spawn(function()
                while task.wait(1.5) do
                    if _G.IsDoingAutoCDK then
                        _G.AutoRaceV2 = false
                        _G.AutoRaceV3 = false
                        return
                    end

                    pcall(function()
                        local currentStatus = checkRaceV3()
                        if currentStatus == "V3" or currentStatus == "V4" then
                            _G.AutoRaceV2 = false
                            _G.AutoRaceV3 = false
                            
                            local place = game.PlaceId
                            local isSea2 = (place == 4442272183 or place == 79091703265657)
                            if isSea2 then
                                print("[Race Master] Đã hoàn thành V3/V4, đang quay lại Sea 3...")
                                pcall(function()
                                    CommF_("TravelZou")
                                end)
                                task.wait(8)
                            end
                            return
                        end

                        local place = game.PlaceId
                        local isSea2 = (place == 4442272183 or place == 79091703265657)
                        if not isSea2 then
                            if _G.AutoRaceV2 or _G.AutoRaceV3 then
                                print("[Race Master] Chưa ở Sea 2, đang yêu cầu dịch chuyển...")
                                CommF_("TravelDressrosa")
                                local waited = 0
                                repeat
                                    task.wait(1)
                                    waited = waited + 1
                                    local newPlace = game.PlaceId
                                    local arrived = (newPlace == 4442272183 or newPlace == 79091703265657)
                                until arrived or waited > 30
                                if waited > 30 then
                                    print("[Race Master] Quá thời gian chờ về Sea 2, thử lại sau.")
                                    return
                                end
                                task.wait(3)
                                print("[Race Master] Đã đến Sea 2, bắt đầu tiến trình Race.")
                            else
                                return
                            end
                        end

                        local race = plr.Data.Race.Value

                        if _G.AutoReroll.Enable then
                            local isTarget = false
                            for _, t in ipairs(_G.AutoReroll.StopAt) do if race:find(t) then isTarget = true break end end
                            if not isTarget and plr.Data.Fragments.Value >= _G.AutoReroll.FragThreshold then
                                CommF_("BlackbeardReward", "Reroll", "1")
                                task.wait(0.5)
                                CommF_("BlackbeardReward", "Reroll", "2")
                                task.wait(2)
                                return
                            end
                        end

                        local v2S = CommF_("Alchemist", "1")
                        if _G.AutoRaceV2 and v2S ~= -2 then
                            if v2S == 0 then CommF_("Alchemist", "2")
                            elseif v2S == 1 then
                                local function Has(n)
                                    for _, v in pairs(plr.Backpack:GetChildren()) do if v.Name:find(n) then return true end end
                                    for _, v in pairs(plr.Character:GetChildren()) do if v.Name:find(n) then return true end end
                                    return false
                                end
                                if not Has("Flower 1") then
                                    if Lighting.ClockTime > 5 and Lighting.ClockTime < 17 then ServerHopNight()
                                    else local f = workspace:FindFirstChild("Flower1") or workspace:FindFirstChild("Blue Flower")
                                         if f then TP(f.CFrame) end end
                                elseif not Has("Flower 2") then
                                    local f = workspace:FindFirstChild("Flower2") or workspace:FindFirstChild("Red Flower")
                                    if f then TP(f.CFrame) end
                                elseif not Has("Flower 3") then
                                    _G.BringMob = true; _G.MonFarm = "Swan Pirate"; _G.FarmPos = CFrame.new(840, 122, 1240)
                                    TP(_G.FarmPos * CFrame.new(0, 30, 0))
                                end
                            elseif v2S == 2 then CommF_("Alchemist", "3") end
                            return
                        end

                        local v3S = CommF_("Wenlocktoad", "1")
                        if _G.AutoRaceV3 and v2S == -2 and v3S ~= -2 then
                            if v3S == 0 then CommF_("Wenlocktoad", "2")
                            elseif v3S == 2 then CommF_("Wenlocktoad", "3")
                            elseif v3S == 1 then
                                if race:find("Cyborg") then
                                    local hasF = false
                                    for _, t in pairs(plr.Character:GetChildren()) do if t:IsA("Tool") and (t.ToolTip == "Blox Fruit" or t.Name:find("Fruit")) then hasF = true break end end
                                    if not hasF then
                                        local inv = CommF_("getInventory")
                                        if type(inv) == "table" then
                                            for _, i in pairs(inv) do
                                                if i.Name:find("Rocket") or i.Name:find("Spin") or i.Name:find("Spring") then
                                                    CommF_("LoadFruit", i.Name) task.wait(1)
                                                    local tool = plr.Backpack:FindFirstChild(i.Name)
                                                    if tool then plr.Character.Humanoid:EquipTool(tool) end break
                                                end
                                            end
                                        end
                                    else CommF_("Wenlocktoad", "3") end
                                elseif race:find("Human") then
                                    local target = nil
                                    for _, b in ipairs(_G.HumanBosses) do if not b.Killed then target = b break end end
                                    if target then
                                        local bM = workspace.Enemies:FindFirstChild(target.Name) or workspace.Enemies:FindFirstChild(target.AltName or "")
                                        if bM and bM:FindFirstChild("Humanoid") and bM.Humanoid.Health > 0 then
                                            _G.CurrentAttacking = target.Name
                                            TP(bM.HumanoidRootPart.CFrame * CFrame.new(0, 30, 0))
                                        else
                                            if _G.CurrentAttacking == target.Name then target.Killed = true; _G.CurrentAttacking = nil
                                            else TP(target.Pos * CFrame.new(0, 30, 0)) end
                                        end
                                    else CommF_("Wenlocktoad", "3") end
                                elseif race:find("Mink") then
                                    local char = plr.Character
                                    if char and char:FindFirstChild("HumanoidRootPart") then
                                        local r = char.HumanoidRootPart; local nc, md = nil, math.huge
                                        for _, o in pairs(workspace:GetDescendants()) do
                                            if o:IsA("Part") and o.Name:lower():find("chest") and not o:GetAttribute("Collected") then
                                                local d = (o.Position - r.Position).Magnitude
                                                if d < md then md = d; nc = o end
                                            end
                                        end
                                        if nc then TP(nc.CFrame) task.wait(0.2); nc:SetAttribute("Collected", true); nc:Destroy() end
                                    end
                                end
                            end
                        end
                    end)
                end
            end)

            task.spawn(function()
                while task.wait() do
                    if _G.BringMob and _G.FarmPos then
                        pcall(function()
                            for _, v in pairs(workspace.Enemies:GetChildren()) do
                                if v.Name:find(_G.MonFarm) and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
                                    v.HumanoidRootPart.CFrame = _G.FarmPos
                                    v.HumanoidRootPart.CanCollide = false
                                    v.HumanoidRootPart.Size = Vector3.new(60, 60, 60)
                                    v.Humanoid:ChangeState(11)
                                end
                            end
                        end)
                    end
                end
            end)
            
            break 
        end
    end
end)

print("⚡ ULTIMATE VIP SCRIPT + AUTO CDK + RACE MASTER LOADED SUCCESS! ⚡")
