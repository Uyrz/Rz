local G = getgenv()


local function getMemoryMb()
    local Stats = game:GetService("Stats")

    if Stats.MemoryTrackingEnabled then
        return nil
    end

    local ok, value = pcall(function()
        return Stats:GetTotalMemoryUsageMb()
    end)

    return ok and value or nil
end

-- ติดตั้งตัวกรองชื่อรีโมต
local ok, err = pcall(function()
    if G.RaycityRemoteNameFilterInstalled then
        print("[Raycity] ")
        return
    end

    assert(
        type(getrawmetatable) == "function"
            and type(setreadonly) == "function"
            and type(newcclosure) == "function"
            and type(getnamecallmethod) == "function",
        "Executor   "
    )

    local mt = getrawmetatable(game)
    assert(type(mt) == "table", " game metatable")

    local oldNamecall = mt.__namecall
    assert(
        type(oldNamecall) == "function",
        "__namecall เป็น " .. type(oldNamecall)
            .. " "
    )

    local hook = newcclosure(function(self, ...)
        local method = getnamecallmethod()

        if method == "FireServer" or method == "InvokeServer" then
            if typeof(self) == "Instance" then
                local name = self.Name:lower()

                if name:find("log", 1, true)
                    or name:find("report", 1, true)
                    or name:find("blackbox", 1, true)
                    or name:find("acmove", 1, true)
                    or name:find("cheat", 1, true)
                    or name:find("wallguard", 1, true)
                then
                    return nil
                end
            end
        end

        return oldNamecall(self, ...)
    end)

    assert(type(hook) == "function", "newcclosure ")

    setreadonly(mt, false)
    local installed, installError = pcall(function()
        mt.__namecall = hook
    end)
    setreadonly(mt, true)

    assert(installed, tostring(installError))

    G.RaycityRemoteNameFilterInstalled = true
    print("[Raycity] Done")
end)

if not ok then
    warn("[Raycity] Error: " .. tostring(err))
end

local memoryMb = getMemoryMb()
if memoryMb then
    print(string.format("[Raycity] RAM: %.2f MB", memoryMb))
end
