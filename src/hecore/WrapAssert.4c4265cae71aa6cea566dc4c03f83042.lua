
-- Copyright C2009-2013 www.happyelements.com, all rights reserved.
-- Create Date:	2013年11月26日 10:19:13
-- Author:	ZhangWan(diff)
-- Email:	wanwan.zhang@happyelements.com

if not ori_assert then
    ori_assert = assert
end

if not __WP8 then
    ----------------------------------------
    ---- Replace Old Assert With New Assert
    -----------------------------------------
    local old_assert = ori_assert
    local assertFalseNumber = 0

    local function new_assert(cond, msg)
        if not cond then
            assertFalseNumber = assertFalseNumber + 1
            local breakLine = "\n========== index: " .. assertFalseNumber .. " =============\n"
            if msg then if _G.isLocalDevelopMode then printx(0, "assert false message: " .. msg) end end
            local log = breakLine .. "msg:" .. tostring(msg) .. "\n" .. tostring(debug.traceback())
            he_log_error(log)
        end

        return cond
    end

    assert = new_assert

else -- else of wp8
    local old_assert = ori_assert

    local function new_assert(cond, msg)
        if not cond then
            if msg then
                msg = "assert false, message: " .. msg
            else
                msg = "assert false"
            end
            local trace = tostring(debug.traceback())
            local log = msg .. "\n" .. trace
            he_log_error(msg)
            if __DEBUG then Wp8Utils:ShowMessageBox(log) end
        end

        return cond
    end

    assert = new_assert

end -- end of __WP8
