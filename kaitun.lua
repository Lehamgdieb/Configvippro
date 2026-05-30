if not game:IsLoaded() then game.Loaded:Wait() end

local Players = game:GetService("Players")
local plr = Players.LocalPlayer
local RunService = game:GetService("RunService")

local sg = Instance.new("ScreenGui")
sg.Name = "Banana_FPS_Counter"
sg.Parent = (gethui and gethui()) or game:GetService("CoreGui") or plr:WaitForChild("PlayerGui")

local txt = Instance.new("TextLabel", sg)
txt.Size = UDim2.new(0, 80, 0, 20)
txt.Position = UDim2.new(1, -90, 0, 10)
txt.BackgroundTransparency = 1
txt.TextColor3 = Color3.new(0, 1, 0)
txt.TextStrokeTransparency = 0.5
txt.Font = Enum.Font.GothamBold
txt.TextSize = 14
txt.TextXAlignment = Enum.TextXAlignment.Right

RunService.RenderStepped:Connect(function(dt)
    txt.Text = "FPS: " .. math.floor(1 / dt)
end)

task.spawn(function()
    while task.wait(1) do
        if plr and not plr.Team then
            pcall(function()
                game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("SetTeam", "Pirates")
            end)
        elseif plr and plr:FindFirstChild("PlayerGui") and plr.PlayerGui:FindFirstChild("ChooseTeam") then
            plr.PlayerGui.ChooseTeam.Enabled = false
        end
        if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then break end
    end
end)

repeat task.wait(0.5) until plr and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")

pcall(function()
    local rs = game:GetService("ReplicatedStorage")
    if rs:FindFirstChild("Remotes") and rs.Remotes:FindFirstChild("CommF_") then
        rs.Remotes.CommF_:InvokeServer("ClaimQuest")
    end
end)

task.spawn(function()
    pcall(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/obiiyeuem/vthangsitink/main/BananaCat-kaitunBF.lua"))()
    end)
end)

local db_config = getgenv().BananaDB_Config or {}
local AutoFindVIPBoss = db_config.AutoFindVIPBoss == nil and false or db_config.AutoFindVIPBoss
local AutoHopBoss = db_config.AutoHopBoss == nil and false or db_config.AutoHopBoss

local HOST_IP = "14.233.25.228:8000"
local API_SAVE  = "http://14.233.25.228:8000/"/save_boss.php"
local API_INDRA = "http://14.233.25.228:8000/"/get_rip_indra.php"
local API_DOUGH = "http://14.233.25.228:8000/"/get_doughking.php"

local Lighting = game:GetService("Lighting")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")
local request_func = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request

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
    pcall(function()
        if writefile then writefile(HistoryFile, HttpService:JSONEncode(VisitedServers)) end
    end)
end

local needDough = true
local needIndra = true
local lastInvCheck = 0
local SEA3_IDS = { [100117331123089] = true, [7449423635] = true }

local function GetCurrentSea() return SEA3_IDS[game.PlaceId] and 3 or 1 end

local BossList = {"Stone", "Hydra Leader", "Kilo Admiral", "Captain Elephant", "Beautiful Pirate", "rip_indra True Form", "Dough King", "Soul Reaper", "Cake Queen", "Cake Prince", "Darkbeard", "Cursed Captain", "Longma"}
local EliteList = {"Urban", "Deandre", "Diablo"}
local PirateRaidMobs = {"Galley Pirate", "Galley Captain", "Raider", "Mercenary", "Vampire", "Zombie", "Snow Trooper", "Winter Warrior", "Lab Subordinate", "Horned Warrior", "Magma Ninja", "Lava Pirate", "Ship Deckhand", "Ship Engineer", "Ship Steward", "Ship Officer", "Arctic Warrior", "Snow Lurker", "Sea Soldier", "Water Fighter"}

local function CheckInventoryAndLevel()
    pcall(function()
        local playerLevel = plr:FindFirstChild("Data") and plr.Data:FindFirstChild("Level") and plr.Data.Level.Value or 0
        if playerLevel <= 2200 then
            needDough, needIndra = false, false
            return
        end
        local inv = ReplicatedStorage.Remotes.CommF_:InvokeServer("getInventory")
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
    local mapFolder = workspace:FindFirstChild("Map")
    return (mapFolder and mapFolder:FindFirstChild("MysticIsland")) and "Có" or "Không"
end

local function CheckMoon()
    local sky = Lighting:FindFirstChild("Sky")
    if not sky then return "Không rõ" end
    if sky.MoonTextureId == "http://www.roblox.com/asset/?id=9709149431" then return "Full Moon"
    elseif sky.MoonTextureId == "http://www.roblox.com/asset/?id=9709149052" then return "Next Night"
    else return "Bad Moon" end
end

local function CheckElite(currentSea)
    local found = {}
    local function ScanEliteIn(folder)
        if not folder then return end
        for _, v in pairs(folder:GetChildren()) do
            if table.find(EliteList, v.Name) and v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") and v.Humanoid.Health > 0 then
                if not table.find(found, v.Name) then table.insert(found, v.Name) end
            end
        end
    end
    ScanEliteIn(workspace:FindFirstChild("Enemies"))
    ScanEliteIn(workspace)
    return #found > 0 and table.concat(found, ", ") or "Không"
end

local function CheckPirateRaid(currentSea)
    if currentSea ~= 3 then return "Không" end
    for _, mobName in pairs(PirateRaidMobs) do
        if ReplicatedStorage:FindFirstChild(mobName) then return "Đang diễn ra" end
    end
    return "Không"
end

local isHopping = false
local function HopToVIPBoss()
    if isHopping then return end
    if not needIndra and not needDough then return end

    isHopping = true
    local vipServers = {}

    local function fetchVip(url)
        local s, r = pcall(function() return game:HttpGet(url) end)
        if s and r ~= "" then
            local o, d = pcall(function() return HttpService:JSONDecode(r) end)
            if o and type(d) == "table" then
                for _, server in pairs(d) do
                    local currentPlayers = tonumber(string.match(tostring(server.players or ""), "^(%d+)")) or 0
                    local sPlaceId = tostring(server.place_id)
                    local sJobId = tostring(server.job_id)
                    if sPlaceId == tostring(game.PlaceId) and currentPlayers <= 12 and not table.find(VisitedServers, sJobId) then
                        table.insert(vipServers, sJobId)
                    end
                end
            end
        end
    end

    if needIndra then fetchVip(API_INDRA) end
    if needDough then fetchVip(API_DOUGH) end

    if #vipServers > 0 then
        local targetId = vipServers[math.random(1, #vipServers)]
        local sbSuccess = pcall(function()
            ReplicatedStorage:FindFirstChild("__ServerBrowser"):InvokeServer("teleport", targetId)
        end)
        if not sbSuccess then
            pcall(function() TeleportService:TeleportToPlaceInstance(game.PlaceId, targetId, plr) end)
        end
        task.delay(15, function() isHopping = false end)
    else
        isHopping = false 
    end
end

local AFK_TIMEOUT = 30000
local lastPos = Vector3.new(0, 0, 0)
local lastMoveTime = tick()

task.spawn(function()
    while true do
        pcall(function()
            if tick() - lastInvCheck > 30 then
                CheckInventoryAndLevel()
                lastInvCheck = tick()
            end

            local foundBosses = {}
            local seenBoss = {}
            local function ScanBossesIn(folder)
                if not folder then return end
                for _, v in pairs(folder:GetChildren()) do
                    if table.find(BossList, v.Name) and not seenBoss[v.Name] then
                        if v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") and v.Humanoid.Health > 0 then
                            seenBoss[v.Name] = true
                            table.insert(foundBosses, v.Name)
                        end
                    end
                end
            end

            ScanBossesIn(workspace:FindFirstChild("Enemies"))
            ScanBossesIn(workspace)

            local currentSea = GetCurrentSea()
            local payload = {
                boss_name   = #foundBosses > 0 and table.concat(foundBosses, ", ") or "None",
                elite       = CheckElite(currentSea),
                place_id    = tostring(game.PlaceId),
                job_id      = tostring(game.JobId),
                players     = #game.Players:GetPlayers() .. "/" .. game.Players.MaxPlayers,
                mirage      = IsMirageIsland(),
                full_moon   = currentSea == 3 and CheckMoon() or "Không",
                pirate_raid = CheckPirateRaid(currentSea)
            }

            pcall(function()
                request_func({
                    Url = API_SAVE,
                    Method = "POST",
                    Headers = { ["Content-Type"] = "application/json", ["Bypass-Tunnel-Reminder"] = "true" },
                    Body = HttpService:JSONEncode(payload)
                })
            end)

            if AutoFindVIPBoss and AutoHopBoss and game.PlaceId == 100117331123089 then
                if needDough or needIndra then
                    local hasVipBoss = false
                    for _, b in pairs(foundBosses) do
                        if (b == "Dough King" and needDough) or (b == "rip_indra True Form" and needIndra) then
                            hasVipBoss = true break
                        end
                    end
                    if not hasVipBoss and not isHopping then
                        HopToVIPBoss()
                        lastMoveTime = tick()
                    end
                end
            end

            if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                local currentPos = plr.Character.HumanoidRootPart.Position
                if (currentPos - lastPos).Magnitude > 2 then
                    lastPos = currentPos
                    lastMoveTime = tick()
                end
            else
                lastMoveTime = tick()
            end

            if tick() - lastMoveTime > AFK_TIMEOUT and not isHopping and AutoHopBoss then
                HopToVIPBoss()
                lastMoveTime = tick()
            end
        end)
        task.wait(1)
    end
end)
