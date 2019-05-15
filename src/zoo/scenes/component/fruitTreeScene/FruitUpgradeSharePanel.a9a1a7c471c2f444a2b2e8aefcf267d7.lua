
require "zoo.scenes.component.fruitTreeScene.FruitShareSrnShot"

local fruitPos = {
	[-1] = { x=470, y=130 },
	[1] = { x=280, y=260 },
	[2] = { x=160, y=180 },
	[3] = { x=460, y=220 },
	[4] = { x=330, y=120 },
	[5] = { x=100, y=260 },
}

local fruitPosBefore = {
	[-1] = {x=550,y=440},
	[1] = {x=335.45,y=595.2},
	[2] = {x=209.5,y=511.2},
	[3] = {x=537.45,y=550},
	[4] = {x=399.45,y=430},
	[5] = { x=120, y=600 },
}

FruitUpgradeSharePanel = class(ShareBasePanel)

function FruitUpgradeSharePanel:create( tree,level6Ids )
	local sharePanel = FruitUpgradeSharePanel.new()
	sharePanel:loadRequiredResource("ui/NewSharePanelEx2.json")
	sharePanel:init(tree,level6Ids)
	return sharePanel
end

function FruitUpgradeSharePanel:dispose( ... )
	ShareBasePanel.dispose(self)

	-- ArmatureFactory:remove("skeleton", 'fruit_upgrade_animation')
	FrameLoader:unloadArmature('skeleton/fruit_upgrade_animation', true)

	if self.srnShotNode then
		self.srnShotNode:dispose()
		self.srnShotNode = nil
	end
end

function FruitUpgradeSharePanel:init( tree,level6Ids )
	self.tree = tree
	self.level6Ids = level6Ids

	self.ui = self:buildInterfaceGroup('NewSharePanelEx2')
	BasePanel.init(self,self.ui)

	self.ui:getChildByName("light"):setVisible(false)
	self.ui:getChildByName("shareTitle"):setVisible(false)
	self.ui:getChildByName("btnTag"):setVisible(false)

	FrameLoader:loadArmature('skeleton/fruit_upgrade_animation')

	self:runAction(CCCallFunc:create(function( ... )
		self:initBg()
		self:runAction(CCSequence:createWithTwoActions(
			CCDelayTime:create(0.1),
			CCCallFunc:create(function( ... )
				self:runSkeletonAnimation()
			end)
		))
	end))

	self.shareImagePath = HeResPathUtils:getResCachePath() .. "/share_image.jpg"
	self.shareThumbImagePath = HeResPathUtils:getResCachePath() .. "/share_thumb_image.jpg"

	local button = GroupButtonBase:create(self.ui:getChildByName("shareBtn"))
	button:setString("炫耀一下")
	button:addEventListener(DisplayEvents.kTouchTap,function( ... )
		self:screenshotShareImage()
	end)
end

function FruitUpgradeSharePanel:runSkeletonAnimation()
    self.animNode = ArmatureNode:create("vvnbnBg")

    local visibleSize =  Director:sharedDirector():getVisibleSize()

    self.animNode:setPosition(ccp(
    	visibleSize.width/2, 
    	self.ui:getChildByName("shareBtn"):getPositionY() + 150 
    ))

	self.animNode:playByIndex(0)
	self.animNode:update(0.001) 
	self.animNode:stop()
	self.animNode:playByIndex(0)
    self.ui:addChild(self.animNode)

	local treeSlot = self.animNode:getSlot("tree")
	local treeDisplay = tolua.cast(treeSlot:getCCDisplay(),"CCSprite")

	for id,v in pairs(self.tree.fruits) do
		local name = FruitModel:sharedInstance():getFruitName(id)
		if not name then 
			return 
		end

		-- name = "fruit/fruit6g"
		-- name = "fruit/fruit6s"
		-- name = "fruit/fruit6e"

		local builder = InterfaceBuilder:createWithContentsOfFile(PanelConfigFiles.fruitTreeScene)
		
		if table.exist(self.level6Ids,id) then
			local fruit = builder:buildGroup(name)
			local fruitAnim = ArmatureNode:create("vvnbn")
			fruitAnim:playByIndex(0)
			fruitAnim:update(0.001) 
			fruitAnim:stop()
			fruitAnim:playByIndex(0)

			if fruitPos[id] then
				fruitAnim:setPositionX(10 + -320 + fruitPos[id].x)
				fruitAnim:setPositionY(100 + treeDisplay:getContentSize().height - fruitPos[id].y)
			end

			local sprite = fruit:getChildByName("sprite")
			sprite:removeFromParentAndCleanup(false)
			fruit:dispose()

			local container = CCSprite:create()
			sprite:setPositionX(-60)
			sprite:setPositionY(100)
			if name == "fruit/fruit6s" then
				sprite:setScale(1.1)
			elseif name == "fruit/fruit6e" then
				sprite:setScale(1.15)
			elseif name == "fruit/fruit6g" then
				sprite:setScale(1.4)
			end
			container:addChild(sprite.refCocosObj)
			sprite:dispose()

			local slot = fruitAnim:getSlot("图层 13")
			container:retain()
			slot:setDisplayImage(container)

		    self.animNode:addChild(fruitAnim)
		else
			local fruit = builder:buildGroup(name)
			fruit:setAnchorPoint(ccp(0.5,0))
			if fruitPos[id] then
				fruit:setPositionX(fruitPos[id].x)
				fruit:setPositionY(10 + treeDisplay:getContentSize().height - fruitPos[id].y)
			end
			fruit:setScale(0.9)
			treeDisplay:addChild(fruit.refCocosObj)
			fruit:dispose()
		end
	end

end

function FruitUpgradeSharePanel:popout( ... )
	PopoutManager:sharedInstance():add(self, false, false)

	self:setToScreenCenterVertical()
	self:setToScreenCenterHorizontal()
end

function FruitUpgradeSharePanel:removePopout( ... )
	PopoutManager:sharedInstance():remove(self)
end

function FruitUpgradeSharePanel:beforeSrnShot(srnShot, afterSrnShot)
	if self.srnShotNode then
		return
	end
	self.srnShotNode = FruitShareSrnShot:create("share/fruit_share_background.png",function( ... )
		if self.isDisposed then
			return
		end

		self:runAction(CCCallFunc:create(function( ... )
			srnShot()
			afterSrnShot()
		end))
	end)


	for id,v in pairs(self.tree.fruits) do
		local name = FruitModel:sharedInstance():getFruitName(id)
		if not name then 
			return 
		end

		local builder = InterfaceBuilder:createWithContentsOfFile(PanelConfigFiles.fruitTreeScene)
		local fruit = builder:buildGroup(name)

		if fruitPosBefore[id] then
			fruit:setPosition(ccp(fruitPosBefore[id].x,1000 - fruitPosBefore[id].y))
		end

		self.srnShotNode:addChild(fruit)
	end

	-- self.srnShotNode:setPositionY(-1000)
	-- self:addChild(self.srnShotNode)
end

function FruitUpgradeSharePanel:afterSrnShot()
	if not self.srnShotNode then
		return
	end
	self.srnShotNode:dispose()
	self.srnShotNode = nil
end

function FruitUpgradeSharePanel:srnShot()
	if not self.srnShotNode then
		return
	end
	local size = self.srnShotNode:getContentSize()
	if _G.__use_small_res == true then
		size.width = size.width*0.625
		size.height = size.height*0.625
	end

	local renderTexture = CCRenderTexture:create(size.width, size.height)
	renderTexture:begin()
	self.srnShotNode:visit()
	renderTexture:endToLua()
	renderTexture:saveToFile(self.shareImagePath)

	local thumbScale = 250 / size.height
	self.srnShotNode:setScale(thumbScale)
	local renderTexture = CCRenderTexture:create(size.width * thumbScale, size.height * thumbScale)
	renderTexture:begin()
	self.srnShotNode:visit()
	renderTexture:endToLua()
	renderTexture:saveToFile(self.shareThumbImagePath)
end


function FruitUpgradeSharePanel:sendShareImage()
	DcUtil:UserTrack({
		category = "show", 
		sub_category = "push_fruit_button", 
	}, true)

	-- local thumb = CCFileUtils:sharedFileUtils():fullPathForFilename("share/fruit_share_thumb.png")
	local thumb = self.shareThumbImagePath
	local shareCallback = {
		onSuccess = function(result)
			self:onShareSucceed()

			DcUtil:UserTrack({
				category = "show", 
				sub_category = "push_fruit_success", 
			}, true)
		end,
		onError = function(errCode, errMsg)
			self:onShareFailed()
		end,
		onCancel = function()
			self:onShareFailed()
		end,
	}

	if __WIN32 then
		shareCallback.onSuccess()
		return
	end

	local shareType, delayResume = SnsUtil.getShareType()
	SnsUtil.sendImageMessage( shareType, self.shareTitleName, self.shareTitleName, thumb, self.shareImagePath, shareCallback )
end

function FruitUpgradeSharePanel:onShareSucceed()
	self:removePopout()
end

function FruitUpgradeSharePanel:onShareFailed()
	local scene = Director:sharedDirector():getRunningScene()
	if scene then
		local shareFailedLocalKey = "share.feed.faild.tips"
		if PlatformConfig:isPlatform(PlatformNameEnum.kMiTalk) then
			shareFailedLocalKey = "share.feed.faild.tips.mitalk"
		end
		CommonTip:showTip(Localization:getInstance():getText(shareFailedLocalKey), 'negative', nil, 2)
	end
end