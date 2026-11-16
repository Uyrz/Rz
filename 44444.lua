local G = getgenv()

local ok, err = pcall(function()
    if G.RaycityRemoteNameFilterInstalled then
        return
    end

    local mt = getrawmetatable(game)
    assert(type(mt) == "table", "No game metatable")

    local oldNamecall = mt.__namecall
    assert(
        type(oldNamecall) == "function",
        "__namecall  " .. type(oldNamecall)
            .. " Rejoin"
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

    assert(type(hook) == "function", "newcclosure")

    setreadonly(mt, false)
    local installed, installError = pcall(function()
        mt.__namecall = hook
    end)
    setreadonly(mt, true)

    assert(installed, tostring(installError))
    G.RaycityRemoteNameFilterInstalled = true
end)

if not ok then
    warn("[Raycity] " .. tostring(err))
end
