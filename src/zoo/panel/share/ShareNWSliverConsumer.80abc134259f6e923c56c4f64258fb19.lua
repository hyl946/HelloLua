
require 'zoo.panel.share.ArmatureShareBasePanel'
ShareNWSliverConsumer = class(ArmatureShareBasePanel)

function ShareNWSliverConsumer:create(shareId)
	local panel = ShareNWSliverConsumer.new()
	panel:loadRequiredResource("ui/NewSharePanelEx.json")
	panel.shareId = shareId
	panel:init('skeleton/share_' .. shareId .. '_animation', 
			   'share_' .. shareId .. '_animation', 
			   'share_' .. shareId .. '_animation', 
			   'share_' .. shareId .. '_animation/animation')
	return panel
end

function ShareNWSliverConsumer:initShareTitle(titleName)
    local slot = self.node:getSlot('title')
    local text = BitmapText:create(titleName, 'fnt/share.fnt', 0)
    text:setAnchorPoint(ccp(0.5, 0.5))
    local sprite = Sprite:createEmpty()
    sprite:addChild(text)
    slot:setDisplayImage(sprite.refCocosObj)
end

function ShareNWSliverConsumer:getShareTitleName()
	local totalCost = self.achiManager:getData(self.achiManager.TOTAL_COIN_COST_NUM) / 10000
	return Localization:getInstance():getText(self.shareTitleKey,{num = math.floor(totalCost)})
end

function ShareNWSliverConsumer:screenshotShareImage( ... )
	local shareC = Sprite:createEmpty()
    local size = CCSizeMake(720, 720)
    if _G.__use_small_res then
    	size.width = size.width*0.625
		size.height = size.height*0.625
    end
	local bg = Sprite:create("share/share_230.jpg")
	if _G.__use_small_res then
		bg:setScale(0.625)
	end
	bg:setAnchorPoint(ccp(0, 0))
	shareC:addChildAt(bg, 1)

	local qrCodeRes = ShareUtil:getQRCodePath()
	local qrImg = Sprite:create(qrCodeRes)
	qrImg:setAnchorPoint(ccp(0, 0))
	if _G.__use_small_res then qrImg:setPositionXY(340, 20)
	else qrImg:setPositionXY(549, 31) end
	shareC:addChild(qrImg)
	local imageFilePath = HeResPathUtils:getResCachePath() .. "/share" .. self.shareId .. ".png"
	shareC:screenShot(imageFilePath, size, false)
	shareC:dispose()
	self.shareImagePath = imageFilePath
	self:sendShareImage()
end