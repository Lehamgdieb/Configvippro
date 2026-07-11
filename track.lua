
if not game:IsLoaded() then game.Loaded:Wait() end

local Players = game:GetService("Players")
local plr = Players.LocalPlayer

-- Hàng rào check an toàn: Chỉ đợi dữ liệu cấp độ nhân vật load xong (Tránh kẹt UI)
if plr then
    pcall(function()
        repeat task.wait(0.5) until plr:FindFirstChild("Data") and plr.Data:FindFirstChild("Level")
    end)
end

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService('HttpService')

print("[Blox Kid Event Monitor]: Khởi động luồng quét độc lập thành công!")


local findMob = function(mobName)
    local mobObj = nil
    pcall(function()
        local enemiesFolder = workspace:FindFirstChild("Enemies")
        local storageFolder = ReplicatedStorage
        mobObj = (enemiesFolder and enemiesFolder:FindFirstChild(mobName)) or (storageFolder and storageFolder:FindFirstChild(mobName))
    end)
    return mobObj
end

local function GetPirateRaidMob(x)
    local Mob = nil
    pcall(function()
        local castlePos = Vector3.new(-5545.9873046875, 314.0802307128906, -2964.34912109375)
        local enemiesFolder = workspace:FindFirstChild("Enemies")
        local targetFolder = x and enemiesFolder or ReplicatedStorage
        
        if targetFolder and targetFolder.GetChildren then
            local children = targetFolder:GetChildren()
            if children then
                for _, v in ipairs(children) do
                    if v and v:IsA('Model') and v:FindFirstChild("HumanoidRootPart") then
                        if (v.HumanoidRootPart.Position - castlePos).magnitude <= 1000 and not v:GetAttribute('IsBoss') then
                            Mob = v
                            break
                        end
                    end
                end
            end
        end
    end)
    return Mob
end

local function checkSea3()
    local isSea3 = false
    pcall(function()
        local mapAttr = workspace:GetAttribute("MAP")
        if mapAttr and tonumber(mapAttr:match("%d+")) == 3 then isSea3 = true end
    end)
    return isSea3
end

local getMoon = function()
    local res = "nil"
    pcall(function()
        if not checkSea3() then return end
        local lighting = game.Lighting
        local sky = lighting:FindFirstChild("Sky") or lighting:FindFirstChild("Space_Skybox")
        local tex = sky and sky.MoonTextureId or ""
        tex = tex:gsub("rbxassetid://", "http://www.roblox.com/asset/?id=")
        res = ({
            ["http://www.roblox.com/asset/?id=15493317929"] = "Blue Moon",
            ["http://www.roblox.com/asset/?id=9709149431"] = "8/8",
            ["http://www.roblox.com/asset/?id=9709149052"] = "7/8",
            ["http://www.roblox.com/asset/?id=9709143733"] = "6/8"
        })[tex] or "nil"
    end)
    return res
end

local function getMoonPhase()
    local phase = "Unknown"
    pcall(function()
        local moonphase = game.Lighting:GetAttribute("MoonPhase")
        if moonphase then
            if moonphase == 5 and not getgenv().isfmended then phase = "Full Moon" else phase = "Normal Moon" end
        end
    end)
    return phase
end

local scanAndPostEvents = function()
    local bodyData = {}
    
    local playerCount = 1
    local maxPlayers = 12
    pcall(function()
        local playersTable = game.Players:GetPlayers()
        if type(playersTable) == "table" then playerCount = #playersTable end
        if game.Players.MaxPlayers then maxPlayers = game.Players.MaxPlayers end
    end)
    local playerMax = string.format("%d/%d", playerCount, maxPlayers)
    
    local EliteList = {'Diablo', 'Urban', 'Deandre'}
    local RareBossList = {
        'rip_indra True Form', 'Dough King', 'Cake Prince', 'Soul Reaper', 'Cursed Captain',
        'Darkbeard', 'Stone', 'Island Empress', 'Beautiful Pirate', 'Kilo Admiral', 'Captain Elephant'
    }

    pcall(function()
        -- Quét Elite
        for _, name in pairs(EliteList) do
            if findMob(name) then table.insert(bodyData, {['Players'] = playerMax, ['Type'] = 'Elite', ['JobId'] = game.JobId, ['PlaceId'] = game.PlaceId, ['Elite'] = name}) end
        end
        -- Quét Rare Boss
        for _, name in pairs(RareBossList) do
            if findMob(name) then table.insert(bodyData, {['Players'] = playerMax, ['Type'] = 'Rare Boss', ['JobId'] = game.JobId, ['PlaceId'] = game.PlaceId, ['Rare Boss'] = name}) end
        end
        -- Quét Pirate Raid
        if GetPirateRaidMob(rawget(getgenv(), "scanStorage") or false) or GetPirateRaidMob(true) then
            table.insert(bodyData, {['Players'] = playerMax, ['Type'] = 'Castle', ['JobId'] = game.JobId, ['PlaceId'] = game.PlaceId})
        end
        -- Quét Mirage
        if workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild('MysticIsland') then
            table.insert(bodyData, {['Players'] = playerMax, ['Type'] = 'Mirage', ['JobId'] = game.JobId, ['PlaceId'] = game.PlaceId})
        end
        -- Quét Full Moon
        if getMoon() == "8/8" and getMoonPhase() == "Full Moon" then
            table.insert(bodyData, {['Players'] = playerMax, ['Type'] = 'Moon', ['JobId'] = game.JobId, ['PlaceId'] = game.PlaceId, ['ClockTime'] = game.Lighting.ClockTime, ['MoonPhase'] = "Full Moon up"})
        end
    end)

    -- ĐÃ THÊM: Nếu server trống không có event gì, ép tạo 1 bản ghi "Normal" để báo cáo server sống
    if #bodyData == 0 then
        table.insert(bodyData, {
            ['Players'] = playerMax, 
            ['Type'] = 'Normal', 
            ['JobId'] = game.JobId, 
            ['PlaceId'] = game.PlaceId
        })
    end

    local reqFunction = request or http_request or (syn and syn.request)
    if reqFunction then
        pcall(function()
            reqFunction({
                Url = "http://14.233.28.141:8000/handle_event.php",
                Method = "POST",
                Headers = { ["Content-Type"] = "application/json" },
                Body = HttpService:JSONEncode(bodyData)
            })
        end)
    end
end

task.spawn(function()
    while true do
        pcall(scanAndPostEvents)
        task.wait(10)
    end
end)

print("[Hệ Thống]: Dữ liệu đang được đồng bộ thời gian thực lên XAMPP...")
