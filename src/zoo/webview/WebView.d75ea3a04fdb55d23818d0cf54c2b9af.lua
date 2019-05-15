local WebView = class()

--http
function WebView:openUrl( url , useFrame, SCREEN_ORIENTATION_LANDSCAPE )
	if useFrame == nil then useFrame = true end
	if SCREEN_ORIENTATION_LANDSCAPE == nil then SCREEN_ORIENTATION_LANDSCAPE = false end

	pcall(function ( ... )
		print('WebView:openUrl')
		print('WebView:openUrl' .. tostring(url))
		
		if __ANDROID then
			local WebViewLogic = luajava.bindClass("com.happyelements.android.webview.WebViewLogic")
			WebViewLogic:open(url, useFrame, SCREEN_ORIENTATION_LANDSCAPE)
		elseif __IOS then
			if SCREEN_ORIENTATION_LANDSCAPE then
			    OpenUrlUtil:openUrl(url)
				-- HeWebViewBridge:openUrl2(url)
			else
				HeWebViewBridge:openUrl(url)
			end
		end

	end)

	
end

function WebView:openFile( fullPath , useFrame, SCREEN_ORIENTATION_LANDSCAPE )
	if useFrame == nil then useFrame = true end
	if SCREEN_ORIENTATION_LANDSCAPE == nil then SCREEN_ORIENTATION_LANDSCAPE = false end

	-- body
	pcall(function ( ... )
		if __ANDROID then
			local WebViewLogic = luajava.bindClass("com.happyelements.android.webview.WebViewLogic")
			--android需要这样写
			local path 
			if string.starts(fullPath, 'apk:/') then
				path = fullPath:gsub('apk:/', 'file:///android_asset/')
			else
				if string.sub(fullPath, 1, 1) == '/' then
					path = 'file://' .. fullPath
				else
					path = 'file:///' .. fullPath
				end
			end

			WebViewLogic:open(path, useFrame, SCREEN_ORIENTATION_LANDSCAPE)   
		elseif __IOS then
			HeWebViewBridge:openFile(fullPath)
		end
	end)
end

function WebView:openUserArgument( ... )

	local filename = require('zoo.webview.UserArgument')()
	if filename then
		local path = CCFileUtils:sharedFileUtils():fullPathForFilename(filename)
		WebView:openFile(path)
	end
end

function WebView:openPrivacyArgument( ... )

	local filename = require('zoo.webview.PrivacyArgument')()
	if filename then
		local path = CCFileUtils:sharedFileUtils():fullPathForFilename(filename)
		WebView:openFile(path)
	end
end

return WebView