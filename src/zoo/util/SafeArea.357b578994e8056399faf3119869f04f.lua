---------------------------------------------------------------------------------------
-- @Author: dan.liang
-- @Date:   2017-11-22 18:03:24
-- @Email:  dan.liang@happyelements.com
-- @Last Modified by:   Administrator
-- @Last Modified time: 2017-12-25 18:32:53
---------------------------------------------------------------------------------------

if not CCDirector:sharedDirector().ori_getVisibleOrigin then
	CCDirector:sharedDirector().ori_getVisibleOrigin = CCDirector:sharedDirector().getVisibleOrigin
end
if not CCDirector:sharedDirector().ori_getVisibleSize then
	CCDirector:sharedDirector().ori_getVisibleSize = CCDirector:sharedDirector().getVisibleSize
end

-- 不要换地方，不明白问丹丹
local vOrigin = CCDirector:sharedDirector():ori_getVisibleOrigin()
local vSize	= CCDirector:sharedDirector():ori_getVisibleSize()

if not CCDirector:sharedDirector().ori_getVisibleSizeY_ then
	CCDirector:sharedDirector().ori_getVisibleSizeY_ = CCDirector:sharedDirector().getVisibleSizeY_
	CCDirector:sharedDirector().getVisibleSizeY_ = function()
		local ny = CCDirector:sharedDirector():ori_getVisibleSizeY_()
		local y = ny - vSize.height + CCDirector:sharedDirector():getVisibleSize().height
		return y
	end
end

-- 设置默认值
_G.__HAS_SAFE_AREA = false
pcall(function()
	local rect = nil
	if __IOS or __ANDROID then
		rect = HeDisplayUtil:getSafeAreaRect() -- 屏幕坐标系
	end
	local frameSize = CCDirector:sharedDirector():getOpenGLView():getFrameSize()
	if __WIN32 and (frameSize.height / frameSize.width > 2.1) then -- iphonex
		rect = {
			origin = {x = 0, y = 132},
			size = {width = 1125, height = 2202}
		}	
	end
	--浮点数精确度容错
	if rect and (math.abs(rect.size.width - frameSize.width)>1 or math.abs(rect.size.height - frameSize.height)>1) then
		local winSize = CCDirector:sharedDirector():getWinSize()
		local screenScale = winSize.width / frameSize.width
		local top = math.floor(rect.origin.y * screenScale)
		local left = math.floor(rect.origin.x * screenScale)
		local bottom = math.floor((frameSize.height - (rect.size.height+rect.origin.y)) * screenScale)
		local right = math.floor((frameSize.width - (rect.size.width+rect.origin.x)) * screenScale)
		if __IPHONE_WITH_EDGE then
			top = top - 25
		end
		if top > 0 or left > 0 or bottom > 0 or right > 0 then
		    _G.__EDGE_INSETS = {
				top = top,
				left = left,
				bottom = bottom,
				right = right,
		    }
		    _G.__SAFE_AREA = {
				x = vOrigin.x + left,
				y = vOrigin.y + bottom,
				width = vSize.width - left - right,
				height = vSize.height - top - bottom,
			}
		    _G.__HAS_SAFE_AREA = true
		end
	end
end)

if _G.__HAS_SAFE_AREA then
	CCDirector:sharedDirector().getVisibleSize = function()
		return CCSizeMake(_G.__SAFE_AREA.width, _G.__SAFE_AREA.height)
	end
	CCDirector:sharedDirector().getVisibleOrigin = function()
		return ccp(_G.__SAFE_AREA.x, _G.__SAFE_AREA.y)
	end
else
	_G.__EDGE_INSETS = {
	  top = 0,
	  left = 0,
	  bottom = 0,
	  right = 0,
	}
	_G.__SAFE_AREA = {
		x = vOrigin.x,
		y = vOrigin.y,
		width = vSize.width,
		height = vSize.height,
	}
end

-- if _G.isLocalDevelopMode then
-- 	require("hecore.debug.remote")
-- 	print("safe_area", "__EDGE_INSETS=", table.tostring(_G.__EDGE_INSETS), "__SAFE_AREA=", table.tostring(_G.__SAFE_AREA), __SAFE_AREA.width, __SAFE_AREA.height)
-- end

