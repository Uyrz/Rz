local G = getgenv()

local function getMemoryMb()
    local Stats = game:GetService("Stats")

    if not Stats.MemoryTrackingEnabled then
        return nil
    end

    local ok, value = pcall(function()
        return Stats:GetTotalMemoryUsageMb()
    end)

    if ok and type(value) == "number" then
        return value
    end

    return nil
end

local ok, err = pcall(function()
    if G.RaycityRemoteNameFilterInstalled then
        print("[Raycity] ติดตั้งไว้แล้ว ต้องเข้าเกมใหม่ก่อนเปลี่ยนตัวกรอง")
        return
    end

    assert(
        type(getrawmetatable) == "function"
            and type(setreadonly) == "function"
            and type(newcclosure) == "function"
            and type(getnamecallmethod) == "function",
        "Executor ไม่รองรับ API ที่ต้องใช้"
    )

    local mt = getrawmetatable(game)
    assert(type(mt) == "table", "ไม่พบ game metatable")

    local oldNamecall = mt.__namecall
    assert(
        type(oldNamecall) == "function",
        "__namecall ไม่ใช่ฟังก์ชัน กรุณาเข้าเกมใหม่"
    )

    local hook = newcclosure(function(self, ...)
        local method = getnamecallmethod()

        if (method == "FireServer" or method == "InvokeServer")
            and typeof(self) == "Instance"
        then
            local name = self.Name:lower()

            -- ยกเว้นรีโมตนี้ ให้ส่งได้ตามปกติ
            if name ~= "raycityplatformreport" then
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

    assert(type(hook) == "function", "newcclosure ไม่คืนฟังก์ชัน")

    setreadonly(mt, false)
    local installed, installError = pcall(function()
        mt.__namecall = hook
    end)
    setreadonly(mt, true)

    assert(installed, tostring(installError))

    G.RaycityRemoteNameFilterInstalled = true
    print("[Raycity] ติดตั้งแล้ว ยกเว้น RaycityPlatformReport")
end)

if not ok then
    warn("[Raycity] ติดตั้งไม่สำเร็จ: " .. tostring(err))
end

local memoryMb = getMemoryMb()
if memoryMb then
    print(string.format("[Raycity] RAM: %.2f MB", memoryMb))
end
