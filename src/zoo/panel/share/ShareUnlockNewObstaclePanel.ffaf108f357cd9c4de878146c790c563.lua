require 'zoo.panel.share.ArmatureShareBasePanel'
require 'zoo.panel.quickselect.QuickTableView2'

ShareUnlockNewObstaclePanel = class(ArmatureShareBasePanel)

function ShareUnlockNewObstaclePanel:ctor()

end

function ShareUnlockNewObstaclePanel:init(armatureSource, skeletonName, textureName, armatureName, playPaperGroup)
	FrameLoader:loadImageWithPlist("flash/quick_select_level.plist")
	FrameLoader:loadImageWithPlist("flash/quick_select_animation.plist")
	self.frameAnimScale = 0.7
	self.staticAnimScale = 0.9
	ArmatureShareBasePanel.init(self, armatureSource, skeletonName, textureName, armatureName, playPaperGroup)
	self.level = self.achiManager:get(AchiDataType.kLevelId)
end

-- function ShareUnlockNewObstaclePanel:initUI()
-- 	ArmatureShareBasePanel.initUI(self)
-- 	self:initObstacle()
-- end

function ShareUnlockNewObstaclePanel:createObstacle()
	local animateConfig = nil
	local obstacleConfig = require "zoo.PersonalCenter.ObstacleIconConfig"
    local index = obstacleConfig[self.level]
    
	for _,config in ipairs(QuickSelectAnimation) do
		if config.id == index then
			animateConfig = config
			break
		end
	end


	local wrapper = Sprite:createEmpty()
	local sprite 

	if animateConfig and CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("area_animation_"..index.."_0000") then
		sprite = Sprite:createWithSpriteFrameName("area_animation_"..index.."_0000")
		local frames = SpriteUtil:buildFrames("area_animation_"..index.."_%04d", 0, animateConfig.frameNum)
		local animate = SpriteUtil:buildAnimate(frames, 1/24)
		sprite:setAnchorPoint(ccp(0, 1))
		sprite:play(animate)
		sprite:setPositionX(8)
		sprite:setPositionY(-8)
		if index == 13 then
			sprite:setPositionX(15)
		elseif index == 8 or index == 3 or index == 57 or index == 17 or index == 23 then
			sprite:setPositionY(-12)
		end
		local scale = math.min(140/sprite:getContentSize().width, 140/sprite:getContentSize().height)
		sprite:setScale(self.frameAnimScale*scale) -- 因为骨骼换装后设置scale无效，因此必须在wrapper里面设置scale才有用
		self.isFrameAnim = true
	elseif CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("area_icon_"..index.."0000") then
		sprite = Sprite:createWithSpriteFrameName("area_icon_"..index.."0000")
		sprite:setAnchorPoint(ccp(0, 1))
		sprite:setPositionX(6)
		sprite:setPositionY(-8)
		sprite:setScale(self.staticAnimScale)
		self.isFrameAnim = false
	end
	wrapper:addChild(sprite)
	wrapper.sprite = sprite

	return wrapper, index
end

function ShareUnlockNewObstaclePanel:runAnimation( ... )
	self:initObstacle()
	ArmatureShareBasePanel.runAnimation(self)
end

function ShareUnlockNewObstaclePanel:initObstacle()


	self.obstacle = self:createObstacle()
	if self.obstacle then
		local slot = self.node:getSlot('zhangai')
		slot:setDisplayImage(self.obstacle.refCocosObj)
	end

end


function ShareUnlockNewObstaclePanel:getShareTitleName()
	local level = self.achiManager:get(AchiDataType.kLevelId)
	return Localization:getInstance():getText(self.shareTitleKey,{num = level})
end

function ShareUnlockNewObstaclePanel:dispose( ... )
	ArmatureShareBasePanel.dispose(self)
	FrameLoader:unloadImageWithPlists(
		{
	 	"flash/quick_select_animation.plist"
	 	}, true)

end

function ShareUnlockNewObstaclePanel:create(shareId)
	local panel = ShareUnlockNewObstaclePanel.new()
	panel:loadRequiredResource("ui/NewSharePanelEx.json")

	-- local panelRes = "ShareUnlockNewObstaclePanel"
	-- local size = Director:sharedDirector():getVisibleSize()
	-- if size.width / size.height > 0.6 then
	-- 	panelRes = "ShareUnlockNewObstaclePanel1"
	-- end

	-- panel.ui = panel:buildInterfaceGroup(panelRes)
	panel.shareId = shareId
	panel:init('skeleton/share_50_animation', 'share_50_animation', 'share_50_animation', 'ShareUnlockNewObstacle', false)
	return panel
end


function ShareUnlockNewObstaclePanel:beforeSrnShot(srnShot, afterSrnShot)
	-- debug.debug()
	if self.share_background ~= nil then
		return
	end
	local builder = InterfaceBuilder:createWithContentsOfFile('ui/ShareFeeds.json')
	local ui = builder:buildGroup('ShareFeed_50')

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

	local iconPh = ui:getChildByName('iconPh')
	iconPh:setVisible(false)
	local obstacleWidth = 110 * self.staticAnimScale
	if self.isFrameAnim then
		obstacleWidth = 150 * self.frameAnimScale
	end
	local obstacle, index = self:createObstacle()
	obstacle.sprite:setPositionX(0)
	if index == 13 then
		obstacle.sprite:setPositionX(8)
	end
	obstacle:setScale((iconPh:getContentSize().width*iconPh:getScaleX()) / obstacleWidth) -- todo
	obstacle:setPositionX(iconPh:getPositionX())
	obstacle:setPositionY(iconPh:getPositionY())
	ui:addChild(obstacle)
	obstacle:stopAllActions()


	local codePh = ui:getChildByName('codePh')
	codePh:setVisible(false)
	local size_2d = {width = codePh:getContentSize().width*codePh:getScaleX(), height = codePh:getContentSize().height*codePh:getScaleY()}
	self.share_background_2d:setPosition(ccp(codePh:getPositionX()+size_2d.width/2, codePh:getPositionY()-size_2d.height/2))


	ui:getChildByName('text'):getChildByName('t1'):setText(string.format('我在第%d关', self.level))
	ui:getChildByName('text'):getChildByName('t2'):setText('发现新玩法了！')


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

function ShareUnlockNewObstaclePanel:afterSrnShot()

	self.share_background:dispose()
	self.share_background_2d:dispose()
	self.feedUI:dispose()
	self.share_background = nil
	self.share_background_2d = nil
	self.feedUI = nil
	InterfaceBuilder:unloadAsset('ui/ShareFeeds.json')
end

function ShareUnlockNewObstaclePanel:srnShot()
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
