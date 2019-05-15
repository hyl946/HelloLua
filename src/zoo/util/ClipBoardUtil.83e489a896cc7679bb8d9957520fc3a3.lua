ClipBoardUtil = {}

-- local win32_clipboard = "happyanimal3://week_match_v2/redirect?uid=12345&pid=he&shareKey=testsharekey&inviteCode=123456789"
-- local win32_clipboard = localize("addfriend_copy_sms_pre") .. 288116495 .. localize("addfriend_copy_sms_tag")
-- local win32_clipboard = "打开周赛"
local win32_clipboard = ""

local function bakeText(str) --加工文本
	-- if str then str = string.gsub(str,"(.-)\\\"","%1\"") end --将转义 \" 变为 " 
	return str
end

function ClipBoardUtil.copyText(str)  --设置str到剪贴板
	if __ANDROID then
		luajava.bindClass("com.happyelements.android.utils.ClipBoardUtil"):copyString(str)
	elseif __IOS then
		local pasteboard = UIPasteboard:generalPasteboard()
		pasteboard:setPersistent(true)
		pasteboard:setString(str)
	elseif __WIN32 then
		win32_clipboard = str
	else
		-- CCDirector:sharedDirector():setClipboard(str)
	end
end

function ClipBoardUtil.getRawText()

	local rv = nil

	if __ANDROID then
		local succCallback = function(str)
			rv = str
		end
		local failCallback = function(str)
			print("ClipBoardUtil.getText: Clipboard Fail or Cancelled!")
			rv = nil
		end
		local tempCallback = luajava.createProxy("com.happyelements.android.InvokeCallback", {
			onSuccess = succCallback,
			onError = failCallback,
			onCancel = failCallback,
		})
		luajava.bindClass("com.happyelements.android.utils.ClipBoardUtil"):getPasteString(tempCallback)
	elseif __IOS then
		local pasteboard = UIPasteboard:generalPasteboard()
		local raw = pasteboard:string()
		if raw ~= nil and type(raw) == "string" then
			rv = raw
		else
			rv = nil
		end
	elseif __WIN32 then
		rv = win32_clipboard
	else
		print("ClipBoardUtil.getText: No Clipboard detected!")
		rv = nil
	end

	return rv

end

function ClipBoardUtil.getText()
	return bakeText(ClipBoardUtil.getRawText())
end

function ClipBoardUtil.callWithClipboardText(callback)
	if callback and type(callback)=="function" then callback(ClipBoardUtil.getText()) end
end

function ClipBoardUtil.copyTextByCC(str)
	CCDirector:sharedDirector():setClipboard(str)
end

function ClipBoardUtil.getRawTextByCC()
	return CCDirector:sharedDirector():getClipboard()
end

function ClipBoardUtil.getTextByCC()
	return bakeText(ClipBoardUtil.getRawTextByCC())
end
