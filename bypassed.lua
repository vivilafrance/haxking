local Hooked = {}
local Detected, Kill
local FoundAC = false

-- Run in proper thread
setthreadidentity(2)

-- Quick scan through GC to detect Adonis
for i, v in getgc(true) do
    if typeof(v) == "table" then
        local DetectFunc = rawget(v, "Detected")
        local KillFunc = rawget(v, "Kill")

        if typeof(DetectFunc) == "function" and not Detected then
            Detected = DetectFunc
            FoundAC = true
            print("[Adonis Bypass] AntiCheat Detected! Bypass activated.")

            local Old
            Old = hookfunction(Detected, function(Action, Info, NoCrash)
                return true
            end)
            table.insert(Hooked, Detected)
        end

        if rawget(v, "Variables") and rawget(v, "Process") and typeof(KillFunc) == "function" and not Kill then
            Kill = KillFunc
            local Old
            Old = hookfunction(Kill, function(Info)
                -- optional: nothing here, just prevent kill
            end)
            table.insert(Hooked, Kill)
        end
    end
end

-- Hook debug.info to prevent crash checks
if Detected then
    local Old
    Old = hookfunction(getrenv().debug.info, newcclosure(function(...)
        local LevelOrFunc = ...
        if LevelOrFunc == Detected then
            return coroutine.yield(coroutine.running())
        end
        return Old(...)
    end))
else
    print("[Adonis Bypass] No AntiCheat detected. Nothing to bypass.")
end

-- Restore thread identity
setthreadidentity(7)
