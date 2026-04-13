-- ==========================================
-- ĐỢI GAME LOAD XONG MỚI CHẠY
-- ==========================================
repeat task.wait() until game:IsLoaded()

-- ==========================================
-- CẤU HÌNH & BIẾN TOÀN CỤC
-- ==========================================
local Player = game:GetService("Players").LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local CommF = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("CommF_")
local VU = game:GetService("VirtualUser")
local Net = require(ReplicatedStorage.Modules.Net)
local RegisterAttack = Net:RemoteEvent("RegisterAttack", true)
local RegisterHit = Net:RemoteEvent("RegisterHit", true)

-- [ TOGGLES TÙY CHỈNH ]
_G.Auto_Cake_Prince = true
_G.AutoHopBoss = true -- Tính năng Bật/Tắt Hop Server
_G.AutoBuso = true 
_G.BlacklistedServers = {}
_G.IsHopping = false
_G.LastHopTime = 0

local function UpdateStatus(msg)
    print("[Auto Cake Prince]: " .. tostring(msg))
end
local SetStatus = UpdateStatus

-- ==========================================
-- [ 1. HÀM CHIẾN ĐẤU & DI CHUYỂN ]
-- ==========================================
local function AttackNoCoolDown()
    pcall(function()
        local char = Player.Character
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

local function EquipWeapon(weaponType)
    local char = Player.Character
    if not char or char.Humanoid.Health <= 0 then return end

    local currentWeapon = char:FindFirstChildOfClass("Tool")
    if currentWeapon and currentWeapon.ToolTip == weaponType then
        return 
    end

    for _, tool in pairs(Player.Backpack:GetChildren()) do
        if tool:IsA("Tool") and tool.ToolTip == weaponType then
            char.Humanoid:EquipTool(tool)
            break
        end
    end
end

local function Tween2(targetCFrame)
    pcall(function()
        local char = Player.Character
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
        local char = Player.Character
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
    local char = Player.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local dist = (targetCFrame.Position - char.HumanoidRootPart.Position).Magnitude
    if dist > 300 then Tween2(targetCFrame)
    elseif dist > 5 then BKP(targetCFrame) end
end

-- ==========================================
-- [ 2. HÀM AUTO HOP, AUTO TEAM & AUTO BUSO ]
-- ==========================================
local function AutoHop(apiUrl, reason)
    if _G.IsHopping then return end
    if tick() - _G.LastHopTime < 5 then return end 
    _G.IsHopping = true; _G.LastHopTime = tick() 
    SetStatus("⏳ Đang Hop qua API: " .. reason)
    
    task.spawn(function()
        local targetJobId = nil
        
        -- Gọi API
        local success, result = pcall(function() return game:HttpGet(apiUrl) end)
        
        if success and result and result ~= "" then
            local s2, data = pcall(function() return HttpService:JSONDecode(result) end)
            if s2 and type(data) == "table" then
                -- Nhận diện lớp bọc ngoài cùng (records, data, hoặc mảng trực tiếp)
                local serverList = data.records or data.data or data
                local currentPlaceId = tostring(game.PlaceId)
                
                if type(serverList) == "table" then
                    for _, srv in pairs(serverList) do
                        if type(srv) == "table" then
                            -- TỰ ĐỘNG BẮT CẢ 2 ĐỊNH DẠNG (Có gạch dưới hoặc không)
                            local jId = srv.jobId or srv.job_id
                            local pId = srv.placeId or srv.place_id
                            
                            -- Kiểm tra hợp lệ và xem có đúng Sea (PlaceId) đang đứng không
                            if jId and tostring(pId) == currentPlaceId then
                                if jId ~= game.JobId and not _G.BlacklistedServers[jId] then
                                    targetJobId = jId
                                    break
                                end
                            end
                        end
                    end
                end
            end
        end
        
        -- Dịch chuyển nếu có Server
        if targetJobId then
            _G.BlacklistedServers[targetJobId] = true 
            SetStatus("✈️ Tìm thấy Server từ API! Đang dịch chuyển...")
            pcall(function() ReplicatedStorage.__ServerBrowser:InvokeServer("teleport", targetJobId) end)
        else
            SetStatus("❌ API hiện không có server mới. Đợi 5 giây thử lại...")
        end
        
        task.wait(5); _G.IsHopping = false
    end)
end

local function AutoJoinTeam()
    local maxAttempts = 30
    local attempts = 0
    repeat 
        task.wait(0.5)
        attempts = attempts + 1
        if Player.Team == nil or Player.Team.Name == "ChooseTeam" then
            pcall(function() 
                CommF:InvokeServer("SetTeam", "Marines") 
                for _, gui in pairs(Player.PlayerGui:GetChildren()) do
                    pcall(function()
                        for _, obj in pairs(gui:GetDescendants()) do
                            local name = obj.Name:lower()
                            if (name:find("marine") and not name:find("pirate")) or (obj:IsA("TextButton") and obj.Text:lower():find("marine")) then
                                if getconnections then
                                    for _, v in pairs(getconnections(obj.MouseButton1Click)) do pcall(function() v:Fire() end) end
                                    for _, v in pairs(getconnections(obj.Activated)) do pcall(function() v:Fire() end) end
                                end
                                pcall(function() fireclickdetector(obj) end)
                            end
                        end
                    end)
                end
                local setTeam = ReplicatedStorage:FindFirstChild("SetTeam")
                if setTeam then pcall(function() setTeam:FireServer("Marines") end) end
            end)
        end
    until (Player.Team ~= nil and Player.Team.Name ~= "ChooseTeam") or attempts >= maxAttempts
end

task.spawn(function()
    while task.wait(0.5) do
        if _G.AutoBuso then
            pcall(function()
                local char = Player.Character
                if char and char:FindFirstChild("Humanoid") and char.Humanoid.Health > 0 then
                    if not char:FindFirstChild("HasBuso") then
                        CommF:InvokeServer("Buso")
                    end
                end
            end)
        end
    end
end)

-- ==========================================
-- [ 3. VÒNG LẶP LOGIC CHÍNH ]
-- ==========================================
task.spawn(function()
    while task.wait() do
        if _G.Auto_Cake_Prince then
            pcall(function()
                if Player.Team == nil or Player.Team.Name == "ChooseTeam" then
                    AutoJoinTeam()
                    task.wait(2)
                    return
                end

                local char = Player.Character
                if not char or not char:FindFirstChild("HumanoidRootPart") then return end

                local rootPart = char.HumanoidRootPart
                local enemies = workspace:FindFirstChild("Enemies")
                local map = workspace:FindFirstChild("Map")
                local cakeLoaf = map and map:FindFirstChild("CakeLoaf")
                local bigMirror = cakeLoaf and cakeLoaf:FindFirstChild("BigMirror")
                local cakeLoafCFrame = CFrame.new(-2151.82, 149.32, -12404.91) 

                local cakePrince = enemies and enemies:FindFirstChild("Cake Prince")

                -- TÌNH HUỐNG 1: THẤY BOSS -> Tới đánh luôn
                if cakePrince and cakePrince:FindFirstChild("Humanoid") and cakePrince.Humanoid.Health > 0 then
                    EquipWeapon("Melee")
                    
                    -- ĐÃ FIX: Bay trên đầu Boss 30 Stud để né đòn
                    -- Dùng CFrame.new(Position) để giữ cho nhân vật luôn đứng thẳng, không bị nghiêng theo Boss
                    local safePos = cakePrince.HumanoidRootPart.Position + Vector3.new(0, 30, 0)
                    SmartMove(CFrame.new(safePos))
                    
                    AttackNoCoolDown()
                    return 
                end

                -- TÌNH HUỐNG 2: GƯƠNG MỞ 
                if bigMirror and bigMirror.Other.Transparency == 0 then
                    if rootPart.Position.Y > 2000 or (rootPart.Position - cakeLoafCFrame.Position).Magnitude > 5000 then
                        return -- Đã trong phòng Boss, đợi quái ra
                    else
                        SmartMove(cakeLoafCFrame) -- Đang ở ngoài, bay vào gương
                        return
                    end
                end

                -- TÌNH HUỐNG 3: GƯƠNG ĐÓNG & KHÔNG CÓ BOSS
                if (rootPart.Position - cakeLoafCFrame.Position).Magnitude > 150 then
                    SmartMove(cakeLoafCFrame)
                    return
                end

                -- TÌNH HUỐNG 4: ĐÃ TỚI GƯƠNG, GƯƠNG ĐÓNG -> HOP
                if _G.AutoHopBoss then
                    AutoHop("http://14.174.63.243:8080/get_cakeprince.php", "Cake Prince")
                end
            end)
        end
    end
end)
