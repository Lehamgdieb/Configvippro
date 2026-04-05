-- [[ MAIN SCRIPT: JOIN TEAM + SABER QUEST + API HOP + KAITUN ]]

repeat task.wait() until game:IsLoaded() and game.Players.LocalPlayer
local player = game.Players.LocalPlayer
local Services = setmetatable({}, {__index = function(t, k) return game:GetService(k) end})
local remote = Services.ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("CommF_")
local API_URL = "http://14.185.45.59:8080/get_boss.php"

-- Tọa độ chuẩn (đã được kiểm tra)
local POS_HANG_NUOC = CFrame.new(1396, 37, -1322)
local POS_SICK_MAN = CFrame.new(1460, 88, -1388)
local POS_RICH_SON = CFrame.new(-2270, 4, -2824)
local POS_MOB_LEADER = CFrame.new(-2850, 6, 5300)
local POS_SABER_EXPERT = CFrame.new(-1467, 24, -68)

-- ==========================================
-- 0. HÀM JOIN TEAM (MẶC ĐỊNH PIRATES)
-- ==========================================
local function JoinTeam()
    if player.Team == nil or player.Team.Name == "" then
        print("Đang chọn Team...")
        repeat task.wait(1)
            pcall(function()
                remote:InvokeServer("SetTeam", "Pirates")
            end)
        until player.Team ~= nil
    end
end

-- ==========================================
-- 1. MODULE ATTACK & UTILS
-- ==========================================
local NetModule = require(Services.ReplicatedStorage.Modules.Net)
local RegisterAttack = NetModule:RemoteEvent("RegisterAttack", true)
local RegisterHit = NetModule:RemoteEvent("RegisterHit", true)

function GetAllBladeHits()
    local hits = {}
    local char = player.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return hits end
    for _, v in pairs(Services.Workspace.Enemies:GetChildren()) do
        if v:FindFirstChild('Humanoid') and v:FindFirstChild('HumanoidRootPart') and v.Humanoid.Health > 0 then
            if (v.HumanoidRootPart.Position - char.HumanoidRootPart.Position).Magnitude <= 65 then
                table.insert(hits, v)
            end
        end
    end
    return hits
end

local function DoAttack()
    local targets = GetAllBladeHits()
    if #targets == 0 then return end
    local packet = {[1] = nil, [2] = {}, [4] = "078da5141"}
    for _, target in pairs(targets) do
        RegisterAttack:FireServer(0)
        if not packet[1] then packet[1] = target.Head end
        table.insert(packet[2], {[1] = target, [2] = target.HumanoidRootPart})
    end
    RegisterHit:FireServer(unpack(packet))
end

task.spawn(function()
    while task.wait(0.06) do 
        if _G.FastAttack == true then pcall(DoAttack) end 
    end
end)

local function topos(cf)
    local char = player.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local root = char.HumanoidRootPart
    local dist = (root.Position - cf.Position).Magnitude
    if dist < 5 then return end
    for _, v in pairs(char:GetChildren()) do if v:IsA("BasePart") then v.CanCollide = false end end
    local tween = Services.TweenService:Create(root, TweenInfo.new(dist/300, Enum.EasingStyle.Linear), {CFrame = cf})
    tween:Play()
    tween.Completed:Wait()
end

local function EquipTool(name)
    local tool = player.Backpack:FindFirstChild(name) or player.Character:FindFirstChild(name)
    if tool then player.Character.Humanoid:EquipTool(tool) return tool end
end

local function GrabEnemy(targetName)
    pcall(function() sethiddenproperty(player, 'SimulationRadius', math.huge) end)
    for _, v in pairs(Services.Workspace.Enemies:GetChildren()) do
        if v.Name == targetName and v:FindFirstChild("HumanoidRootPart") and v.Humanoid.Health > 0 then
            if isnetworkowner(v.PrimaryPart) then
                v.HumanoidRootPart.CFrame = player.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, -5)
            end
        end
    end
end

-- ==========================================
-- 2. HỆ THỐNG API HOP & CHECK SABER
-- ==========================================
local function hasSaber()
    if player.Character and player.Character:FindFirstChild("Saber") then return true end
    if player.Backpack:FindFirstChild("Saber") then return true end
    pcall(function() remote:InvokeServer("LoadItem", "Saber") end)
    task.wait(1.5)
    return player.Backpack:FindFirstChild("Saber") ~= nil
end

local function hopToSaberServer()
    local request_func = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request
    if not request_func then 
        print("Không tìm thấy HTTP request function. Bỏ qua hop.")
        return false 
    end
    local success, res = pcall(function()
        return request_func({
            Url = API_URL, Method = "GET", 
            Headers = {["Content-Type"] = "application/json", ["Bypass-Tunnel-Reminder"] = "true"}
        })
    end)
    if success and res and res.Body then
        local decodeSuccess, serverList = pcall(function() return Services.HttpService:JSONDecode(res.Body) end)
        if decodeSuccess and type(serverList) == "table" then
            for _, serverInfo in pairs(serverList) do
                if serverInfo.boss_name and string.find(serverInfo.boss_name, "Saber Expert") then
                    print("✓ Tìm thấy Saber Expert ở server khác. Đang Hop...")
                    Services.TeleportService:TeleportToPlaceInstance(tonumber(serverInfo.place_id), tostring(serverInfo.job_id), player)
                    task.wait(10)
                    return true
                end
            end
        end
    end
    print("Không tìm thấy server có Saber Expert, giữ nguyên server hiện tại.")
    return false
end

local function isBossExists(bossName)
    return Services.Workspace.Enemies:FindFirstChild(bossName) ~= nil
end

-- ==========================================
-- 3. LOGIC CHÍNH (SABER QUEST + HOP KHI ĐÁNH BOSS)
-- ==========================================
task.spawn(function()
    JoinTeam()
    repeat task.wait() until getgenv().SettingFarm
    player:WaitForChild("Data", 20)
    
    local currentLevel = player.Data.Level.Value
    
    if currentLevel >= 200 then
        print("Đang kiểm tra Saber Quest...")
        if not hasSaber() then
            print("Chưa có Saber. Bắt đầu Quest...")
            
            -- Hop lần đầu nếu muốn (tùy chọn, có thể bỏ comment dòng dưới)
            -- hopToSaberServer()
            
            while not hasSaber() do
                local progress = remote:InvokeServer('ProQuestProgress')
                local h = 0
                if not progress.UsedTorch then h = 2
                elseif not progress.UsedCup then h = 3
                elseif not progress.TalkedSon then h = 4
                elseif not progress.KilledMob then h = 5
                elseif not progress.UsedRelic then h = 6
                elseif not progress.KilledShanks then h = 7 end

                if h == 3 then
                    topos(CFrame.new(1114, 5, 4350))
                    remote:InvokeServer('ProQuestProgress', "GetCup")
                    task.wait(1)
                    topos(POS_HANG_NUOC)
                    local cup = EquipTool("Cup")
                    task.wait(1)
                    remote:InvokeServer("ProQuestProgress", 'FillCup', cup)
                    task.wait(1)
                    topos(POS_SICK_MAN)
                    EquipTool("Cup")
                    task.wait(0.5)
                    remote:InvokeServer("ProQuestProgress", 'SickMan')
                elseif h == 5 then
                    _G.FastAttack = true
                    for _, v in pairs(player.Backpack:GetChildren()) do 
                        if v:IsA("Tool") and v.ToolTip == "Melee" then 
                            player.Character.Humanoid:EquipTool(v) 
                            break
                        end 
                    end
                    topos(POS_MOB_LEADER)
                    repeat task.wait() GrabEnemy("Mob Leader") until not Services.Workspace.Enemies:FindFirstChild("Mob Leader")
                    remote:InvokeServer('ProQuestProgress', 'RichSon')
                elseif h == 6 then
                    topos(POS_RICH_SON)
                    remote:InvokeServer('ProQuestProgress', 'RichSon')
                    task.wait(1)
                    if EquipTool("Relic") then
                        topos(POS_SABER_EXPERT)
                        remote:InvokeServer("ProQuestProgress", "PlaceRelic")
                    end
                elseif h == 7 then
                    -- === PHẦN ĐÁNH BOSS SABER EXPERT CÓ HOP ===
                    _G.FastAttack = true
                    -- Trang bị vũ khí cận chiến
                    for _, v in pairs(player.Backpack:GetChildren()) do 
                        if v:IsA("Tool") and v.ToolTip == "Melee" then 
                            player.Character.Humanoid:EquipTool(v) 
                            break
                        end 
                    end
                    
                    -- Vòng lặp: kiểm tra boss, nếu không có thì hop, nếu có thì đánh
                    local bossKilled = false
                    while not bossKilled and not hasSaber() do
                        if not isBossExists("Saber Expert") then
                            print("Không tìm thấy Saber Expert trong server hiện tại. Tiến hành hop...")
                            hopToSaberServer()
                            task.wait(5) -- chờ load server mới
                        else
                            print("Đã tìm thấy Saber Expert. Bắt đầu đánh...")
                            topos(POS_SABER_EXPERT)
                            local startTime = tick()
                            repeat 
                                task.wait()
                                GrabEnemy("Saber Expert")
                                -- Nếu boss chết mà chưa nhận Saber thì thử đặt lại relic (phòng trường hợp)
                                if not isBossExists("Saber Expert") and (tick() - startTime > 15) then
                                    if EquipTool("Relic") then 
                                        remote:InvokeServer("ProQuestProgress", "PlaceRelic") 
                                    end
                                    startTime = tick()
                                end
                            until not isBossExists("Saber Expert") or hasSaber()
                            bossKilled = true
                        end
                    end
                    break
                else
                    if h == 2 then 
                        topos(CFrame.new(-1610, 11, 164)) 
                        remote:InvokeServer("ProQuestProgress", 'GetTorch')
                    elseif h == 4 then 
                        topos(POS_RICH_SON) 
                        remote:InvokeServer('ProQuestProgress', 'RichSon') 
                    end
                end
                task.wait(2)
            end
        end
    end

    -- KẾT THÚC QUEST SABER -> LOAD KAITUN
    print("--- CHUYỂN SANG KAITUN BANANA CAT ---")
    _G.FastAttack = false
    loadstring(game:HttpGet("https://raw.githubusercontent.com/obiiyeuem/vthangsitink/main/BananaCat-kaitunBF.lua"))()
end)
