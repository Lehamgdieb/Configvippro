local SCRIPT_1 = "https://raw.githubusercontent.com/Lehamgdieb/Configvippro/refs/heads/main/ninghhubkey.lua"
local SCRIPT_2 = "https://raw.githubusercontent.com/Lehamgdieb/Configvippro/refs/heads/main/track.lua"
local function ExecuteScripts()
    print("--- [SYSTEM] STARTING SEQUENCE LOADER ---")
local success1, err1 = pcall(function()
        print("⏳ [1/2] Loading: ninghhubkey.lua")
        loadstring(game:HttpGet(SCRIPT_1))()
    end)
    if success1 then
        print("✅ [1/2] ninghhubkey.lua loaded successfully!")
    else
        warn("❌ [1/2] Failed to load SCRIPT 1: " .. tostring(err1))
    end
    task.wait(0.5)
    local success2, err2 = pcall(function()
        print("⏳ [2/2] Loading: track.lua")
        loadstring(game:HttpGet(SCRIPT_2))()
    end)
    if success2 then
        print("✅ [2/2] track.lua loaded successfully!")
    else
        warn("❌ [2/2] Failed to load SCRIPT 2: " .. tostring(err2))
    end
    print("--- [SYSTEM] SEQUENCE LOADER FINISHED ---")
end
ExecuteScripts()
