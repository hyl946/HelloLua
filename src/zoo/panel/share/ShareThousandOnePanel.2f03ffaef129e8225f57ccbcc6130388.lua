require 'zoo.panel.share.ArmatureShareBasePanel'
ShareThousandOnePanel = class(ArmatureShareBasePanel)

function ShareThousandOnePanel:ctor()

end

function ShareThousandOnePanel:init(armatureSource, skeletonName, textureName, armatureName, playPaperGroup)

	ArmatureShareBasePanel.init(self, armatureSource, skeletonName, textureName, armatureName, playPaperGroup)
	self.level = self.achiManager:get(AchiDataType.kLevelId)
	self.shareRank = self.achiManager:get(AchiDataType.kAllScoreRank) or 0
end

function ShareThousandOnePanel:getShareLinkTitleMessage( ... )	
	local levelText = tostring(LevelMapManager.getInstance():getLevelDisplayName(self.level))

	local title = Localization:getInstance():getText("show_new_title10")
	local message = Localization:getInstance():getText("show_new_text10",{ num1=levelText,num2=self.shareRank})

	return title,message
end

function ShareThousandOnePanel:getShareTitleName()
	local level = self.achiManager:get(AchiDataType.kLevelId)
	local levelText = tostring(LevelMapManager.getInstance():getLevelDisplayName(level))
	local shareRank = self.achiManager:get(AchiDataType.kAllScoreRank)
	return Localization:getInstance():getText(self.shareTitleKey,{num = levelText, num1 = shareRank})
end

function ShareThousandOnePanel:create(shareId)
	local panel = ShareThousandOnePanel.new()
	panel:loadRequiredResource("ui/NewSharePanelEx.json")
	-- panel.ui = panel:buildInterfaceGroup('ArmatureAnimSharePanel')
	panel.shareId = shareId
	panel:init('skeleton/share_10_animation', 'share_10_animation', 'share_10_animation', 'ShareThousandOne', false)
	return panel
end

function ShareThousandOnePanel:beforeSrnShot(srnShot, afterSrnShot)
	-- debug.debug()
	if self.share_background ~= nil then
		return
	end
	local builder = InterfaceBuilder:createWithContentsOfFile('ui/ShareFeeds.json')
	local ui = builder:buildGroup('ShareFeed_10')

	share_background_img = "share/share_background_new.png"
	self.share_background = Sprite:create(share_background_img)
	self.share_background:setAnchorPoint(ccp(0,1))

	local size = self.share_background:getContentSize()

	if _G.__use_small_res == true then
		self.share_background:setScale(0.625)
		size.width = size.width * 0.625
		size.height = size.height * 0.625
	end

	local bgPh = ui:getChildByName('bg')
	ui:addChildAt(self.share_background, bgPh:getZOrder())
	bgPh:setVisible(false)

	local bg_2d_img = ShareUtil:getQRCodePath()
	self.share_background_2d = Sprite:create(bg_2d_img)

	ui:addChild(self.share_background_2d)

	local codePh = ui:getChildByName('codePh')
	codePh:setVisible(false)
	local size_2d = {width = codePh:getContentSize().width*codePh:getScaleX(), height = codePh:getContentSize().height*codePh:getScaleY()}
	self.share_background_2d:setPosition(ccp(codePh:getPositionX()+size_2d.width/2, codePh:getPositionY()-size_2d.height/2))

	local level = self.level
	if LevelType:isHideLevel(self.level) then
		level = level % 10000
		level = '+' .. tostring(level)
	end
	ui:getChildByName('text'):getChildByName('t1'):setText(string.format('我在第%s关', tostring(level)))
	ui:getChildByName('text'):getChildByName('t2'):setText(string.format('排名全国第%d', self.shareRank))

	ui:setPositionX(0)
	ui:setPositionY(720)

	self.feedUI = ui

	if srnShot then
		srnShot()
	end
	if afterSrnShot then
   		afterSrnShot()
   	end

   	CCTextureCache:sharedTextureCache():removeTextureForKey(
		CCFileUtils:sharedFileUtils():fullPathForFilename(bg_2d_img)
	)
	CCTextureCache:sharedTextureCache():removeTextureForKey(
		CCFileUtils:sharedFileUtils():fullPathForFilename(share_background_img)
	)
end

function ShareThousandOnePanel:afterSrnShot()

	self.share_background:dispose()
	self.share_background = nil
	self.share_background_2d:dispose()
	self.share_background_2d = nil
	InterfaceBuilder:unloadAsset('ui/ShareFeeds.json')
end

function ShareThousandOnePanel:srnShot()
	local size = self.share_background:getContentSize()
	if _G.__use_small_res == true then
		size.width = size.width*0.625
		size.height = size.height*0.625
	end
	local renderTexture = CCRenderTexture:create(size.width, size.height)
	renderTexture:begin()
	self.feedUI:visit()
	renderTexture:endToLua()
	renderTexture:saveToFile(self.shareImagePath)
end
