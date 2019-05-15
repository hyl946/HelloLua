require "zoo.util.ResUtils"
require "zoo.common.HeadFrameType"

local HEAD_SIZE = 100

HeadImageLoader = class(CocosObject)

function HeadImageLoader:ctor()
	self.list = {}
	self.itemLoadCompleteCallback = nil
end

function HeadImageLoader:create(userId, headImageUrl,onImageLoadFinishCallback)
	local container = HeadImageLoader.new(CCNode:create())
	container:addUnknownHeadImage()
	container:initialize(userId, headImageUrl, onImageLoadFinishCallback)
	return container
end

function HeadImageLoader:createWithFrame(userId, headImageUrl,onImageLoadFinishCallback, style, _profile)
	local container = HeadImageLoader.new(CCNode:create())
	container:addUnknownHeadImage()
	container:attachHeadFrame(userId, style, _profile)
	container:initialize(userId, headImageUrl, function ( ... )
		if onImageLoadFinishCallback then
			onImageLoadFinishCallback(container)
		end
	end)
	return container
end

function HeadImageLoader:createWithDesignatedFrame(userId, headImageUrl,onImageLoadFinishCallback, frameId, style)
	-- if _G.isLocalDevelopMode then printx(0, "HeadImageLoader:create") end
	local container = HeadImageLoader.new(CCNode:create())
	container:addUnknownHeadImage()
	container:attachHeadFrame(userId, style, _profile)
	container:initialize(userId, headImageUrl, function ( ... )
		if onImageLoadFinishCallback then
			onImageLoadFinishCallback(container)
		end
	end)
	return container
end


function HeadImageLoader:createWithFrameId(userId, headImageUrl,onImageLoadFinishCallback, frameId, style)
	local container = HeadImageLoader.new(CCNode:create())
	container:addUnknownHeadImage()
	container:attachDesignatedHeadFrame(userId, frameId, style)
	container:initialize(userId, headImageUrl, function ( ... )
		if onImageLoadFinishCallback then
			onImageLoadFinishCallback(container)
		end
	end)
	return container
end



local function getProfileByUID( userId )
	-- body
	local myUID = tostring(UserManager:getInstance().user.uid or 0)

	if myUID == tostring(userId) then
		return UserManager:getInstance().profile or {}
	end

	local profile = FriendManager:getInstance():getFriendInfo(userId)
	return profile or {}
end	

function HeadImageLoader:attachDesignatedHeadFrame( userId, frameId, style )
	local function __addHeadFrame( ... )
		if self.isDisposed then return end
		local frameUI = HeadFrameType:buildUI(frameId, style, userId)
		local headHolder = frameUI:getChildByPath('head')
		local bounds = headHolder:getGroupBounds()
		local w, h = bounds.size.width, bounds.size.height
		local targetW, targetH = HEAD_SIZE, HEAD_SIZE
		local sx = targetW / w
		local sy = targetH / h
		frameUI:setScaleX(sx)
		frameUI:setScaleY(sy)
		self:addChild(frameUI)

		local bounds = headHolder:getGroupBounds(self)
		local px, py = bounds:getMidX(), bounds:getMidY()
		local offsetX = -px
		local offsetY = -py

		frameUI:setPositionX(offsetX)
		frameUI:setPositionY(offsetY)
		headHolder:removeFromParentAndCleanup(true)
		frameUI:setTag(HeDisplayUtil.kIgnoreGroupBounds)
		self.frameUI = frameUI
	end
	__addHeadFrame()

end

function HeadImageLoader:attachHeadFrame( userId, style, _profile)

	local function __addHeadFrame( ... )
		if self.isDisposed then return end

		local profile = _profile or getProfileByUID(userId)
		local frameId = HeadFrameType:setProfileContext(profile):getCurHeadFrame()
		local frameUI = HeadFrameType:buildUI(frameId, style, userId)
		local headHolder = frameUI:getChildByPath('head')
		local bounds = headHolder:getGroupBounds()
		local w, h = bounds.size.width, bounds.size.height
		local targetW, targetH = HEAD_SIZE, HEAD_SIZE
		local sx = targetW / w
		local sy = targetH / h
		frameUI:setScaleX(sx)
		frameUI:setScaleY(sy)
		self:addChild(frameUI)

		local bounds = headHolder:getGroupBounds(self)
		local px, py = bounds:getMidX(), bounds:getMidY()

		local offsetX = -px
		local offsetY = -py

		frameUI:setPositionX(offsetX)
		frameUI:setPositionY(offsetY)

		headHolder:removeFromParentAndCleanup(true)

		frameUI:setTag(HeDisplayUtil.kIgnoreGroupBounds)

		self.frameUI = frameUI

	end

	local function __removeHeadFrame( ... )
		if self.isDisposed then return end
		if self.frameUI then
			self.frameUI:removeFromParentAndCleanup(true)
		end
		self.frameUI = nil
	end

	__addHeadFrame()


	local myUID = tostring(UserManager:getInstance().user.uid or 0)

	if myUID == tostring(userId) then


		local refresh = function ( ... )
			__removeHeadFrame()
			__addHeadFrame()
		end

		self.__refreshHeadFrame = refresh
		
		HeadFrameType:register(self)
	end

end

function HeadImageLoader:dispose( ... )
	HeadFrameType:unregister(self)
	CocosObject.dispose(self, ...)
end

function HeadImageLoader:refreshHeadFrame( ... )
	if self.isDisposed then return end
	if self.__refreshHeadFrame then
		self.__refreshHeadFrame()
	end
end

function HeadImageLoader:initialize(userId, headImageUrl, onImageLoadFinishCallback)

	local imageID

	headImageUrl = headImageUrl or "0"
	self.headImageUrl = tostring(headImageUrl)
	self.userId = userId
	if string.find(self.headImageUrl, "http://") ~= nil or string.find(self.headImageUrl, "https://") ~= nil then   
	    local function onCallBack(data)        
	    	if self.isDisposed then return end
	        local sprite = Sprite:create( data["realPath"] )

	        if sprite:isFake() then
	        	
	        	sprite:dispose()

				self.headPath = self.headImageUrl
				imageID = (tonumber(userId) or 0) % 11
				local kMaxHeadImages = UserManager.getInstance().kMaxHeadImages
				local headImage = tonumber(imageID)
				if headImage == nil then headImage = 0 end
				if headImage < 0 then headImage = 0 end
				if headImage > kMaxHeadImages then headImage = kMaxHeadImages end
				sprite = Sprite:createWithSpriteFrameName("h"..tostring(headImage))
				sprite:setContentSize(CCSizeMake(HEAD_SIZE, HEAD_SIZE))
				self:createHeadWithSprite(sprite)
				if onImageLoadFinishCallback then onImageLoadFinishCallback(self) end
			else
		        if sprite.refCocosObj then
			        local size = sprite:getContentSize()
			        sprite:setScaleX(HEAD_SIZE / size.width)
			        sprite:setScaleY(HEAD_SIZE / size.height)
		        end
		        local container = Sprite:createEmpty()
		        container:addChild(sprite)
		        container:setAnchorPoint(ccp(0, 0))
		        container:setContentSize(CCSizeMake(HEAD_SIZE, HEAD_SIZE))
		        self:createHeadWithSprite(container)
		        self.headSprite = sprite
		        self.headPath = data["realPath"]
		        self.isSns = true
		    	if onImageLoadFinishCallback then onImageLoadFinishCallback(self) end
	        end

	    end
	    ResUtils:getResFromUrls({self.headImageUrl},onCallBack)
	elseif string.find(self.headImageUrl, "head") ~= nil then
		if self.isDisposed then return end
        local sprite = Sprite:create( self.headImageUrl )
        if sprite.refCocosObj then
	        local size = sprite:getContentSize()
	        sprite:setScaleX(HEAD_SIZE / size.width)
	        sprite:setScaleY(HEAD_SIZE / size.height)
        end
        local container = Sprite:createEmpty()
        container:addChild(sprite)
        container:setAnchorPoint(ccp(0, 0))
        container:setContentSize(CCSizeMake(HEAD_SIZE, HEAD_SIZE))
        self:createHeadWithSprite(container)
        self.headSprite = sprite
        self.headPath = self.headImageUrl
        if onImageLoadFinishCallback then onImageLoadFinishCallback(self) end
    elseif string.starts(self.headImageUrl, "[Unknown]") then
    	self.headPath = self.headImageUrl
		if onImageLoadFinishCallback then onImageLoadFinishCallback(self) end
	else
		self.headPath = self.headImageUrl
		imageID = self.headImageUrl
		local kMaxHeadImages = UserManager.getInstance().kMaxHeadImages
		local headImage = tonumber(imageID)
		if headImage == nil then headImage = 0 end
		if headImage < 0 then headImage = 0 end
		if headImage > kMaxHeadImages then headImage = kMaxHeadImages end
		local sprite = Sprite:createWithSpriteFrameName("h"..tostring(headImage))
		sprite:setContentSize(CCSizeMake(HEAD_SIZE, HEAD_SIZE))
		self:createHeadWithSprite(sprite)
		if onImageLoadFinishCallback then onImageLoadFinishCallback(self) end
	end
end

function HeadImageLoader:addUnknownHeadImage( ... )
	self:createHeadWithSprite(Sprite:createWithSpriteFrameName("jHeadUI/default_head0000"))
end

function HeadImageLoader:createHeadWithSprite(sprite)
	if self.isDisposed then return end

	if self.headSprite then
		self.headSprite:removeFromParentAndCleanup(true)
		self.headSprite = nil
	end

	if self.headBackground then
		self.headBackground:removeFromParentAndCleanup(true)
		self.headBackground = nil
	end

	local contentSize = sprite:getContentSize()
    local layer = LayerColor:create()
    layer:setColor(ccc3(255,255,255))
    layer:setContentSize(CCSizeMake(contentSize.width, contentSize.height))
    layer:setAnchorPoint(ccp(0.5,0.5))
    layer:ignoreAnchorPointForPosition(false)

    self:addChild(layer)
	self.headBackground = layer
	self:addChild(sprite)
	self.headSprite = sprite
	self:setContentSize(CCSizeMake(contentSize.width, contentSize.height))

	--令frameUI回到最上层
	if self.frameUI then
		self.frameUI:removeFromParentAndCleanup(false)
		self:addChild(self.frameUI)
	end
end

function HeadImageLoader:getHeadTextureAndRect()
	return self.headSprite:getTexture(), self.headSprite:getTextureRect()
end

--take head photo
HeadPhotoTaker = {}

local win32_test_index = 0

local function GetWin32Path()
	win32_test_index = win32_test_index + 1
	return "F:\\picTest\\"..win32_test_index..".png"
end

function HeadPhotoTaker:takePicture(cb)
	local function _takePicture()
		if __ANDROID then
			self:androidTakePicture(cb)
		elseif __IOS then
			self:iosTakePicture(cb)
		elseif __WIN32 then
			cb.onSuccess(GetWin32Path())
		end
	end
	
	local function doTakePicture()
		pcall(_takePicture)
	end

	local function onPermissionDeny()
		if cb then cb.onError() end
	end

    PermissionManager.getInstance():requestEach(PermissionsConfig.CAMERA, doTakePicture, onPermissionDeny)
end

function HeadPhotoTaker:close( ... )
	-- body
	if __ANDROID then
		pcall(function ( ... )
			local photoManager = luajava.bindClass("com.happyelements.android.photo.PhotoManager"):get()
			photoManager:onKeyBackClicked()
		end)
	end

end

function HeadPhotoTaker:iosTakePicture( cb )
	waxClass{"PhotoCallbackImpl",NSObject,protocols={"PhotoCallback"}}
	function PhotoCallbackImpl:onSuccess(path)
		if cb then cb.onSuccess(path) end
	end

	function PhotoCallbackImpl:onError_msg(code, errMsg)
		if cb then cb.onError(code, errMsg) end
	end

	function PhotoCallbackImpl:onCancel()
		if cb then cb.onCancel() end
	end

	PhotoController:takePicture(PhotoCallbackImpl:init())
end

function HeadPhotoTaker:androidTakePicture( cb )
	local photoManager = luajava.bindClass("com.happyelements.android.photo.PhotoManager"):get()
    
    local callback = luajava.createProxy("com.happyelements.android.InvokeCallback", {
            onSuccess = function (result)
                if cb then cb.onSuccess(result) end
            end,
            onError = function (code, errMsg)
               if cb then cb.onError(code, errMsg) end
            end,
            onCancel = function ()
               if cb then cb.onCancel() end
            end
        });

	local origin = Director:sharedDirector():getVisibleOrigin()
	local ori_origin = Director:sharedDirector():ori_getVisibleOrigin()
	local offsetY = origin.y - ori_origin.y
    photoManager:setOffsetY(math.floor(offsetY * CCDirector:sharedDirector():getOpenGLView():getScaleY()))
    photoManager:takePicture(callback)
end

function HeadPhotoTaker:selectPicture( cb )
	local function _selectPicture()
		if __ANDROID then
			self:androidSelectPicture(cb)
		elseif __IOS then
			self:iosSelectPicture(cb)
		elseif __WIN32 then
			cb.onSuccess(GetWin32Path())
		end
	end
	
	local function doSelectPicture()
		pcall(_selectPicture)
	end

	local function onPermissionDeny()
		if cb then cb.onError() end
	end
	
    PermissionManager.getInstance():requestEach(PermissionsConfig.READ_EXTERNAL_STORAGE, doSelectPicture, onPermissionDeny)
end

function HeadPhotoTaker:iosSelectPicture( cb )
	waxClass{"PhotoCallbackImpl",NSObject,protocols={"PhotoCallback"}}
	function PhotoCallbackImpl:onSuccess(path)
		if cb then cb.onSuccess(path) end
	end

	function PhotoCallbackImpl:onError_msg(code, errMsg)
		if cb then cb.onError(code, errMsg) end
	end

	function PhotoCallbackImpl:onCancel()
		if cb then cb.onCancel() end
	end

	PhotoController:selectPicture(PhotoCallbackImpl:init())
end

function HeadPhotoTaker:androidSelectPicture( cb )
	local photoManager = luajava.bindClass("com.happyelements.android.photo.PhotoManager"):get()
    
    local callback = luajava.createProxy("com.happyelements.android.InvokeCallback", {
            onSuccess = function (result)
                if cb then cb.onSuccess(result) end
            end,
            onError = function (code, errMsg)
               if cb then cb.onError(code, errMsg) end
            end,
            onCancel = function ()
               if cb then cb.onCancel() end
            end
        });	

	local origin = Director:sharedDirector():getVisibleOrigin()
	local ori_origin = Director:sharedDirector():ori_getVisibleOrigin()
	local offsetY = origin.y - ori_origin.y
    photoManager:setOffsetY(math.floor(offsetY * CCDirector:sharedDirector():getOpenGLView():getScaleY()))
    photoManager:selectPicture(callback)
end

-- function HeadImageLoader:createFrameImage( imageID )
-- 	local kMaxHeadImages = UserManager.getInstance().kMaxHeadImages
-- 	local headImage = tonumber(imageID)
-- 	if headImage == nil then headImage = 0 end
-- 	if headImage < 0 then headImage = 0 end
-- 	if headImage > kMaxHeadImages then headImage = kMaxHeadImages end

-- 	if __ANDROID then -- for some andorid devices can't display right while nested clipping node exists
-- 		local sprite = Sprite:createWithSpriteFrameName("h"..tostring(headImage))
-- 		sprite:setScale(1.02)
-- 		local contentSize = sprite:getContentSize()
-- 		sprite:setPosition(ccp(contentSize.width / 2, contentSize.height / 2))
-- 		local headMask = CCSprite:createWithSpriteFrameName("head_image_mask0000")
-- 		headMask:setPosition(ccp(contentSize.width / 2, contentSize.height / 2))
-- 		local blend = ccBlendFunc()
-- 		blend.src = GL_ZERO
-- 		blend.dst = GL_SRC_ALPHA
-- 		headMask:setBlendFunc(blend)
-- 		local mix = CCRenderTexture:create(contentSize.width, contentSize.height)
-- 		mix:begin()
-- 		sprite:visit()
-- 		headMask:visit()
-- 		mix:endToLua()

-- 		sprite:dispose()

-- 		local obj = CocosObject.new(mix)
-- 		local finalLayer = Layer:create()
-- 		finalLayer:ignoreAnchorPointForPosition(false)
-- 		finalLayer:setAnchorPoint(ccp(0, 1))
-- 		finalLayer:addChild(obj)
-- 		self:addChild(finalLayer)
-- 		self:setContentSize(CCSizeMake(contentSize.width, contentSize.height))
-- 	else -- else, IOS and PC
-- 		local sprite = Sprite:createWithSpriteFrameName("h"..tostring(headImage))
-- 		sprite:setScale(1.02)
-- 		local contentSize = sprite:getContentSize()
-- 		local clipping = ClippingNode.new(CCClippingNode:create(CCSprite:createWithSpriteFrameName("head_image_mask0000")))
-- 		clipping:setAlphaThreshold(0.1)
-- 		if sprite then 
-- 			clipping:addChild(sprite) 
-- 			sprite:dispose()
-- 		end
-- 		self:addChild(clipping)
-- 		self:setContentSize(CCSizeMake(contentSize.width, contentSize.height))
-- 	end
-- end
