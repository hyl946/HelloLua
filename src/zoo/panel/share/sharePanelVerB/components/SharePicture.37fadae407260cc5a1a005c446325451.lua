-- from "zoo.panel.Mark2019.Mark2019SharePicture" 

require "hecore.utils"

local SharePicture = class()

function SharePicture:ctor()
end

local function convertToRealPath(filename)
	local seperator = package.config:sub(1,1)
	local path = getShareImagePathPrefix() .. seperator .. filename

	if __ANDROID then
		pcall(function ( ... )
			path = luajava.bindClass("com.happyelements.android.utils.ScreenShotUtil"):getGamePictureExternalStorageDirectory() .. seperator ..filename
		end)
	end

	return path
end

function SharePicture:getSaveDestination(isCache, isThumb)
	if isCache then
		if not isThumb then
			return convertToRealPath("share_image.jpg")
		else
			return convertToRealPath("thumb_image.jpg")
		end
	else
		local date = os.date("%y-%m-%d-%H%M%S")
		return convertToRealPath("anipop"..tostring(date)..".jpg")
	end
end

function SharePicture:captureWithoutSave(ui, isCache)
	local scaleBefore = ui:getScale()
	local positionBefore = ui:getPosition()
	local anchorBefore = ui:getAnchorPoint()

	local capture =  self:__captureWithoutSave(ui, isCache) 
	
	ui:setAnchorPoint(anchorBefore)
    ui:setScale(scaleBefore)
	ui:setPosition(positionBefore)

	return capture
end

function SharePicture:captureShareAndThumb(ui, isCache)
	local shareImagePath = self:captureSharePicture(ui, isCache)
	local thumbImagePath = self:captureThumbPicture(ui, isCache)
	return shareImagePath, thumbImagePath
end

function SharePicture:captureSharePicture(ui, isCache)
	local path = self:getSaveDestination(isCache, false)

    local scaleBefore = ui:getScale()
	local positionBefore = ui:getPosition()
	local anchorBefore = ui:getAnchorPoint()
    
    local scale = 1.4
	ui:setScale(scale)
	-- ui:setAnchorPoint(ccp(0,1))
    self:__capture(path,ui,isCache)

	ui:setAnchorPoint(anchorBefore)
    ui:setScale(scaleBefore)
	ui:setPosition(positionBefore)
	
	return path
end

function SharePicture:captureSharePictureAndSaveToAlbum(ui, cb)
	local path

	local method = 0

	-- -- 已知小米MIX2不知因为什么原因没办法直接保存到path，对这种机型用先到cache然后转移到path的方法
	-- if MetaInfo:getInstance():getMachineType():lower():find("mix") then
	-- 	--
--

	-- 	method = 1
	-- end

	if method == 0 then
		path = self:captureSharePicture(ui, false)
		if __IOS then
			waxClass{"PhotoCallbackImplS",NSObject,protocols={"PhotoCallback"}}
			function PhotoCallbackImplS:onSuccess(path)
				if cb then cb.onSuccess(path) end
			end

			function PhotoCallbackImplS:onError_msg(code, errMsg)
				if cb then cb.onError(code, errMsg) end
			end

			function PhotoCallbackImplS:onCancel()
				if cb then cb.onCancel() end
			end
			PhotoController:savedToPhotosAlbum(path, PhotoCallbackImplS:init())
		elseif __ANDROID then
			local st,msg = pcall(function ()
				local ScreenShotUtil = luajava.bindClass('com.happyelements.android.utils.ScreenShotUtil')
				ScreenShotUtil:updateAlbumForImage(path)
			end)
			if st then
				if cb then cb.onSuccess(path) end
			else
				if cb then cb.onError(1, msg) end
			end
			cb.onSuccess(path)
		else
			cb.onSuccess(path)
		end
	-- elseif method == 1 then
	-- 	path = self:captureSharePicture(ui, true)
	-- 	local st,msg = pcall(function ()
	-- 		local ScreenShotUtil = luajava.bindClass('com.happyelements.android.utils.ScreenShotUtil')
	-- 		ScreenShotUtil:saveImageToAlbum(path)
	-- 	end)
	-- 	if st then
	-- 		if cb then cb.onSuccess(path) end
	-- 	else
	-- 		if cb then cb.onError(1, msg) end
	-- 	end
	end
	return path
end

function SharePicture:captureThumbPicture(ui, isCache)
	local path = self:getSaveDestination(isCache, true)

    local scaleBefore = ui:getScale()
	local positionBefore = ui:getPosition()
	local anchorBefore = ui:getAnchorPoint()

	ui:setScale(1)
	local panelSize = ui:getGroupBounds().size
	local scale = 200 / math.max(panelSize.width, panelSize.height)
	if _G.__use_small_res == true then
		scale = scale / 0.625
	end
    ui:setScale(scale)
    self:__capture(path,ui)
	
	ui:setAnchorPoint(anchorBefore)
    ui:setScale(scaleBefore)
	ui:setPosition(positionBefore)
	
	return path
end

function SharePicture:__captureWithoutSave(ui)
    local parentBefore = ui:getParent()
    ui:removeFromParentAndCleanup(false)
	
	-- 特别处理：如果面板上有关闭按钮，则隐藏关闭按钮
	local closeBtn = ui:getChildByName("closeBtn")
	if closeBtn then closeBtn:setVisible(false) end

	local size = ui:getGroupBounds().size
	local renderTexture = CCRenderTexture:create(size.width, size.height)

	renderTexture:begin()
	self.panel = Layer:create()
	local whiteBg = LayerColor:createWithColor(ccc3(255,255,255), size.width, size.height)
	self.panel:addChild(whiteBg)
	self.panel:addChild(ui)
	ui:setPositionXY(0,size.height - 1)
	self.panel:visit()
	renderTexture:endToLua()
	
	if closeBtn then closeBtn:setVisible(true) end
    ui:removeFromParentAndCleanup(false)
    parentBefore:addChild(ui)
	self.panel:dispose()

    return renderTexture
end

function SharePicture:__capture(path, ui, isCache)
	local renderTexture = self:__captureWithoutSave(ui)
    renderTexture:saveToFile(path)
    return renderTexture
end

function SharePicture:dispose()
	if self.panel and not self.panel.isDisposed then self.panel:dispose() end
	self.panel = nil
end

return SharePicture