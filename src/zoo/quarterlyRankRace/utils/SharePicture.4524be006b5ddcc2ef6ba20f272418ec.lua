local SharePicture = class()

function SharePicture:ctor()
	self.panel = Layer:create()
end

function SharePicture:dispose()
	self.panel:dispose()
	self.panel = nil

	self:unloadRequiredResource()

	if self.bgPathname then
    	CCTextureCache:sharedTextureCache():removeTextureForKey(CCFileUtils:sharedFileUtils():fullPathForFilename(self.bgPathname))
    end
end

function SharePicture:setBackground(bg)
	self.bg = bg
	bg:setAnchorPoint(ccp(0, 1))
	self.panel:addChild(self.bg)
end

function SharePicture:setBackgroundByPathname(bgPathname)
	local bg = Sprite:create(bgPathname)
	if _G.__use_small_res == true then
		bg:setScale(0.625)
	end
	self:setBackground(bg)
	self.bgPathname = bgPathname
end

function SharePicture:capture()
	local shareImagePath = self:captureSharePicture()
	local thumbImagePath = self:captureThumbPicture()
	return shareImagePath, thumbImagePath
end

function SharePicture:captureSharePicture()
	local path = HeResPathUtils:getResCachePath() .. "/share_image.jpg"

	if __ANDROID then
		pcall(function ( ... )
			path = luajava.bindClass("com.happyelements.android.utils.ScreenShotUtil"):getGamePictureExternalStorageDirectory() .. "/share_image.jpg"
		end)
	end

	local scale = 1

	if _G.__use_small_res == true then
		scale = scale / 0.625
	end

	self.panel:setScale(scale)

	

	self:__capture(path)
	return path
end

function SharePicture:captureThumbPicture()
	local path = HeResPathUtils:getResCachePath() .. "/thumb_image.jpg"

	if __ANDROID then
		pcall(function ( ... )
			path = luajava.bindClass("com.happyelements.android.utils.ScreenShotUtil"):getGamePictureExternalStorageDirectory() .. "/thumb_image.jpg"
		end)
	end

	self.panel:setScale(1)
	local panelSize = self.panel:getGroupBounds().size
	local scale = 200 / math.max(panelSize.width, panelSize.height)

	if _G.__use_small_res == true then
		scale = scale / 0.625
	end

	if _G.__use_small_res == true then
		scale = scale / 0.625
	end

	self.panel:setScale(scale)
	self:__capture(path)
	return path
end

function SharePicture:__capture(path)
	local panelSize = self.panel:getGroupBounds().size

	local bgSize = self.bg:getGroupBounds().size

	local renderTexture = CCRenderTexture:create(bgSize.width, bgSize.height)
	self.panel:setPosition(ccp(0, bgSize.height))
	renderTexture:begin()
	self.panel:visit()
	renderTexture:endToLua()
	renderTexture:saveToFile(path)
end

function SharePicture:addChild(node)
	self.panel:addChild(node)
end



function SharePicture:share(shareImagePath, thumbPath, isFeeds, onSuccessCallback, onFailCallback, onCancelCallback)
	local shareCallback = {
		onSuccess = function(result)
			if onSuccessCallback then
				onSuccessCallback()
			end
			CommonTip:showTip('分享成功', 'positive')
		end,
		onError = function(errCode, errMsg)
			if onFailCallback then
				onFailCallback()
			end
			CommonTip:showTip('分享失败', 'negative')
		end,
		onCancel = function()
			if onCancelCallback then
				onCancelCallback()
			end
			CommonTip:showTip('分享取消', 'negative')
		end,
	}

	if __WIN32 then
		shareCallback.onSuccess()
		return
	end
	
	local title = ''
	local message = ''
	if shareImagePath then
		if PlatformConfig:isPlatform(PlatformNameEnum.kMiTalk) then
			SnsUtil.sendImageMessage(PlatformShareEnum.kMiTalk, title, message, thumbPath, shareImagePath, shareCallback, isFeeds)
		else
			SnsUtil.sendImageMessage(PlatformShareEnum.kWechat, title, message, thumbPath, shareImagePath, shareCallback, isFeeds)
		end
	end
end

--只有 全家福实物奖励 才需要传 eggType
function SharePicture:generateUrl(t, eggType)
	local uid = UserManager.getInstance().user.uid
	local url = string.format(
		'%sspring_2017.jsp?t=%d&uid=%s',
		NetworkConfig.dynamicHost, 
		t,
		tostring(uid)
	)

	if eggType then
		url = url .. '&eggType=' .. tostring(eggType)
	end

	return url
end

function SharePicture:buildQRCode( url, width, pos, angle)
	local sprite = CocosObject.new(QRManager:generatorQRNode(url, width, 1, ccc4(0, 0, 0, 255)))
	sprite:setAnchorPoint(ccp(0.5, 0.5))
	sprite:setPosition(ccp(0, 0))
	sprite:setRotation(angle or 0)
	local container = Layer:create()
	container:addChild(sprite)

	container:setPosition(ccp(pos.x, pos.y))
	container:setScale(width / container:getGroupBounds().size.width)
	self:addChild(container)


	local iconPath = CCFileUtils:sharedFileUtils():fullPathForFilename("materials/wechat_icon.png")
	local icon = Sprite:create(iconPath)
	icon:setAnchorPoint(ccp(0.5, 0.5))
	icon:setRotation(angle or 0)
	container:addChild(icon)

	icon:setScale(width*0.16 / icon:getContentSize().width)
end


function SharePicture:build( ui, rewardItem, callback )
	local feedNode = ui
	local profile = UserManager:getInstance().profile
	local headerUi = feedNode:getChildByName("head")
	local nameLabel = headerUi:getChildByName("nick_name")
	local nickName = profile and profile:getDisplayName() or nil
	if nickName and string.len(nickName) > 0 then
		nickName = TextUtil:ensureTextWidth( nickName, nameLabel:getFontSize(), nameLabel:getDimensions())
		nameLabel:setString(nickName)
	end



	local rewardUI = feedNode:getChildByName('reward')
	self:buildReward(rewardUI, rewardItem)

	self:buildHeader(headerUi:getChildByName('header'), profile.uid, profile.headUrl, callback)
end


function SharePicture:buildHeader(ui, friendId, headUrl, callback)
	local header = ui
	local ph = header:getChildByName("ph")
	local phGb = ph:getGroupBounds(header)
	local posX, posY = phGb.origin.x, phGb.origin.y
	local width, height = phGb.size.width, phGb.size.height
	local phZOrder = ph:getZOrder()
	ph:removeFromParentAndCleanup(true)

	local function onImageLoadFinishCallback(clipping)
		if not header or header.isDisposed then return end
		local clippingSize = clipping:getContentSize()
        local scale = width/clippingSize.width
        clipping:setScale(scale)
        clipping:setPosition(ccp(posX+width/2,posY+height/2))
        header:addChildAt(clipping, phZOrder)

        if callback then callback() end
	end
	HeadImageLoader:create(friendId, headUrl, onImageLoadFinishCallback)
end

function SharePicture:buildReward( rewardUI, rewardItem  )

    local itemUI = rewardUI

    local holder = itemUI:getChildByName('holder')
    local num = itemUI:getChildByName('num')
    num:changeFntFile('fnt/target_amount.fnt')
    num:setScale(num:getScale()*1.3)

    local rewardSP = ResourceManager:sharedInstance():buildItemSprite(rewardItem.itemId)
    rewardSP:setAnchorPoint(ccp(0.5, 0.5))

    holder:setAnchorPointCenterWhileStayOrigianlPosition()
    local pos = holder:getPosition()
    rewardSP:setPosition(ccp(pos.x, pos.y))

    local holderIndex = itemUI:getChildIndex(holder)
    itemUI:addChildAt(rewardSP, holderIndex)

    local text = tostring('x'..rewardItem.num)

    num:setText(text)
    num:setPositionX(num:getPositionX() + 135 - num:getContentSize().width)
    holder:removeFromParentAndCleanup(true)

end


function SharePicture:loadRequiredResource( panelConfigFile )
	self.panelConfigFile = panelConfigFile
	self.builder = InterfaceBuilder:createWithContentsOfFile(panelConfigFile)
end

function SharePicture:unloadRequiredResource()
	if self.panelConfigFile then
		InterfaceBuilder:unloadAsset(self.panelConfigFile)
	end
end

function SharePicture:buildInterfaceGroup( groupName )
	if self.builder then return self.builder:buildGroup(groupName)
	else return nil end
end


return SharePicture