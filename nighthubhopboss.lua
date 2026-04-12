-- [[ CONFIGURATION ]]
local SCRIPT_1 = "https://raw.githubusercontent.com/Lehamgdieb/Configvippro/refs/heads/main/ninghhubkey.lua"
local SCRIPT_2 = "https://raw.githubusercontent.com/Lehamgdieb/Configvippro/refs/heads/main/track.lua"

local function ExecuteScripts()
    print("--- [SYSTEM] STARTING ASYNC LOADER ---")

    task.spawn(function()
        local success1, err1 = pcall(function()
            print("⏳ [1/2] Loading: ninghhubkey.lua")
            loadstring(game:HttpGet(SCRIPT_1))()
        end)
        if success1 then
            print("✅ [1/2] ninghhubkey.lua is running!")
        else
            warn("❌ [1/2] SCRIPT 1 Error: " .. tostring(err1))
        end
    end)

    task.wait(1) 

    task.spawn(function()
        local success2, err2 = pcall(function()
            print("⏳ [2/2] Loading: track.lua")
            loadstring(game:HttpGet(SCRIPT_2))()
        end)
        if success2 then
            print("✅ [2/2] track.lua is running!")
        else
            warn("❌ [2/2] SCRIPT 2 Error: " .. tostring(err2))
        end
    end)
    print("--- [SYSTEM] BOTH SCRIPTS DISPATCHED ---")
end
ExecuteScripts()
