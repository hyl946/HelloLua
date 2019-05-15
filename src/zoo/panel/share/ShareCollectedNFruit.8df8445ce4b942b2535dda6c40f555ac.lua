require 'zoo.panel.share.ArmatureShareBasePanel'
ShareCollectedNFruit = class(ArmatureShareBasePanel)

function ShareCollectedNFruit:create(shareId)
	local panel = ShareCollectedNFruit.new()
	panel:loadRequiredResource("ui/NewSharePanelEx.json")
	panel.shareId = shareId
	panel:init('skeleton/share_' .. shareId .. '_animation', 
			   'share_' .. shareId .. '_animation', 
			   'share_' .. shareId .. '_animation', 
			   'share_' .. shareId .. '_animation/animation')
	return panel
end

function ShareCollectedNFruit:initShareTitle(titleName)
    local slot = self.node:getSlot('txt')
    local text = BitmapText:create(titleName, 'fnt/share.fnt', 0)
    text:setAnchorPoint(ccp(0.5, 0.5))
    local sprite = Sprite:createEmpty()
    sprite:addChild(text)
    slot:setDisplayImage(sprite.refCocosObj)
end

function ShareCollectedNFruit:getShareTitleName()
	self.totalFruitNum = self.achi:getTargetValue()
	return Localization:getInstance():getText(self.shareTitleKey,{num = self.totalFruitNum})
end

function ShareCollectedNFruit:screenshotShareImage( ... )
	local shareC = Sprite:createEmpty()
    local size = CCSizeMake(720, 720)
    if _G.__use_small_res then
    	size.width = size.width*0.625
		size.height = size.height*0.625
    end
	local bg = Sprite:create("share/share_240.jpg")
	if _G.__use_small_res then
		bg:setScale(0.625)
	end
	bg:setAnchorPoint(ccp(0, 0))
	shareC:addChildAt(bg, 1)

	local qrCodeRes = ShareUtil:getQRCodePath()
	local qrImg = Sprite:create(qrCodeRes)
	qrImg:setAnchorPoint(ccp(0, 0))
	if _G.__use_small_res then 
		qrImg:setScale(1.2)
		qrImg:setPositionXY(9, 8)
	else 
		qrImg:setScale(1.29)
		qrImg:setPositionXY(14, 12) 
	end

	local fntFile = "fnt/race_rank.fnt"
	local pickFruitNum = BitmapText:create('', fntFile)
	pickFruitNum:setAnchorPoint(ccp(0.5, 0.5))
	if _G.__use_small_res then 
		pickFruitNum:setPreferredSize(160, 50)
		pickFruitNum:setPositionXY(286, 347)
	else 
		pickFruitNum:setPreferredSize(160, 90) 
		pickFruitNum:setPositionXY(457, 555)
	end
	pickFruitNum:setString(tostring(self.totalFruitNum))
	pickFruitNum:setRotation(15)
	shareC:addChild(pickFruitNum)

	shareC:addChild(qrImg)
	local imageFilePath = HeResPathUtils:getResCachePath() .. "/share" .. self.shareId .. ".png"
	shareC:screenShot(imageFilePath, size, false)
	shareC:dispose()
	self.shareImagePath = imageFilePath
	self:sendShareImage()
end