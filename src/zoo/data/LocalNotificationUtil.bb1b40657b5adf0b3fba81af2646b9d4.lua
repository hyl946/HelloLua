
local bit = require("bit")
LocalNotificationUtil = class()
local instance = nil

function LocalNotificationUtil.getInstance()
	if not instance then
		instance = LocalNotificationUtil.new()
		instance:init()
	end
	return instance
end

function LocalNotificationUtil:init()
end

function LocalNotificationUtil:convertStr(str)
    if type(str)~="string" then
        return str
    end
    local splitStrTab = string.split(str, "*")
    if #splitStrTab > 1 then 
        local resultStr = ""
        for i,v in ipairs(splitStrTab) do
            if string.sub(v, 1, 2) == "\\u" then 
                local unicode = tonumber("0x"..string.sub(v,3,7))
                local tempStr = LocalNotificationUtil:unicode_to_utf8(unicode)
                resultStr = resultStr .. tempStr
            else
                resultStr = resultStr .. v
            end
        end
        return resultStr
    else
        return str
    end
end

-- Unicode(16进制)      UTF-8(二进制)
-- 0000 - 007F          0xxxxxxx 
-- 0080 - 07FF          110xxxxx 10xxxxxx 
-- 0800 - FFFF          1110xxxx 10xxxxxx 10xxxxxx 
function LocalNotificationUtil:unicode_to_utf8(unicode)
    local resultStr=""
    if unicode <= 0x007f then
        resultStr = string.char(bit.band(unicode,0x7f))
    elseif unicode >= 0x0080 and unicode <= 0x07ff then
        resultStr = string.char(bit.bor(0xc0,bit.band(bit.rshift(unicode,6),0x1f)))
        resultStr = resultStr..string.char(bit.bor(0x80,bit.band(unicode,0x3f)))
    elseif unicode >= 0x0800 and unicode <= 0xffff then
        resultStr = string.char(bit.bor(0xe0,bit.band(bit.rshift(unicode,12),0x0f)))
        resultStr = resultStr..string.char(bit.bor(0x80,bit.band(bit.rshift(unicode,6),0x3f)))
        resultStr = resultStr..string.char(bit.bor(0x80,bit.band(unicode,0x3f)))
    end
    return resultStr
end

function LocalNotificationUtil:testFunc()
    local testStr = "我是*\\u2600*表情*\\u2600*测试啊*\\u2708"

	-- local notificationUtil = luajava.bindClass("com.happyelements.hellolua.share.NotificationUtil")
	-- local function addLocal()
	-- -- 	-- local originalStr = "太阳：\\u2600 笑脸：\\ud83d\\ude04"
	-- 	-- local originalStr = "emoji-"..notificationUtil:newString(0x1f602)..notificationUtil:newString(0x1f684)..notificationUtil:newString(0x2708).."--over"
	-- 	local originalStr = "emoji-"..unicode_to_utf8("\\u2600").."测试"..unicode_to_utf8("\\u1f684")..unicode_to_utf8("\\u2708").."--over"
	-- 	if _G.isLocalDevelopMode then printx(0, "originalStr===============",originalStr) end
	-- 	notificationUtil:testNotify(originalStr)
	-- end
	-- pcall(addLocal)
    local str = LocalNotificationUtil:convertStr(testStr)
end