
require "zoo.scenes.component.fruitTreeScene.FruitShareSrnShot"

FruitTreeUpgradeSharePanel = class(ShareBasePanel)

function FruitTreeUpgradeSharePanel:create( treeBg,level )
	local sharePanel = FruitTreeUpgradeSharePanel.new()
	sharePanel:loadRequiredResource("ui/NewSharePanelEx2.json")
	sharePanel:init(treeBg,level)
	return sharePanel
end

function FruitTreeUpgradeSharePanel:dispose( ... )
	ShareBasePanel.dispose(self)

	-- ArmatureFactory:remove("skeleton", 'fruit_tree_upgrade_animation')
    FrameLoader:unloadArmature('skeleton/fruit_tree_upgrade_animation', true)

	if self.srnShotNode then
		self.srnShotNode:dispose()
		self.srnShotNode = nil
	end
end

function FruitTreeUpgradeSharePanel:init( treeBg,level )
	self.treeBg = treeBg
	self.level = level

	self.ui = self:buildInterfaceGroup('NewSharePanelEx2')
	BasePanel.init(self,self.ui)

	self.ui:getChildByName("light"):setVisible(false)
	self.ui:getChildByName("shareTitle"):setVisible(false)
	self.ui:getChildByName("btnTag"):setVisible(false)
	self.ui:getChildByName('bg'):setVisible(false)
	self.ui:getChildByName("closeBtn"):setVisible(false)

	FrameLoader:loadArmature('skeleton/fruit_tree_upgrade_animation')
	self:runAction(CCSequence:createWithTwoActions(
		CCDelayTime:create(0.1),
		CCCallFunc:create(function( ... )
			self:runSkeletonAnimation()
		end)
	))

	self.shareTitleName = ""
	self.shareImagePath = HeResPathUtils:getResCachePath() .. "/share_image.jpg"
	self.shareThumbImagePath = HeResPathUtils:getResCachePath() .. "/share_thumb_image.jpg"

	local button = GroupButtonBase:create(self.ui:getChildByName("shareBtn"))
	button:setString("炫耀一下")
	button:addEventListener(DisplayEvents.kTouchTap,function( ... )
		self:screenshotShareImage()
	end)
	button:setVisible(false)
	self.button = button
end

function FruitTreeUpgradeSharePanel:initBg( ... )
	ShareBasePanel.initBg(self)

	self.ui:getChildByName("closeBtn"):setVisible(true)
	self.button:setVisible(true)
end


function FruitTreeUpgradeSharePanel:runSkeletonAnimation()
    self.animNode = ArmatureNode:create("anim")

    local function sequence( ... )
    	local actions = CCArray:create()
    	for k,v in pairs({...}) do
    		actions:addObject(v)
    	end
    	return CCSequence:create(actions)
    end

    local function delayTime( ... )
    	return CCDelayTime:create( ... )
    end

    local function skewTo( ... )
    	return CCSkewTo:create( ... )
    end

    local function scaleTo( ... )
    	return CCScaleTo:create( ... )
    end

    self.treeBg:setSkewX(0)
    self.treeBg:setSkewY(0)
    self.treeBg:setScale(1)
    self.treeBg:runAction(sequence(
    	delayTime(10/24),
    	skewTo(3/24,-2.5,0),
    	skewTo(3/24,2.5,0),
    	skewTo(3/24,-1,0),
    	skewTo(2/24,1,0),
    	skewTo(2/24,0,0),
    	delayTime(2/24),
    	scaleTo(3/24,1,0.954),
    	scaleTo(4/24,0.965,1.075),
    	scaleTo(5/24,1,1)
	))
	
	local scale = self.treeBg:getParent():getScale()
    self.animNode:setScale(scale)

   	local bounds = self.treeBg:boundingBox()
   	local worldPos = self.treeBg:getParent():convertToWorldSpace(
   		ccp(bounds:getMinX(),bounds:getMaxY())
	)
	local localPos = self.ui:convertToNodeSpace(worldPos)
   	self.animNode:setPosition(localPos)
   	-- 500是估算的animNode的高度
   	self.button:setPositionY(localPos.y - 500 * scale)

	self.animNode:playByIndex(0)
	self.animNode:update(0.001) 
	self.animNode:stop()
	self.animNode:playByIndex(0)
    self.ui:addChildAt(self.animNode,3)

    self.animNode:addEventListener(ArmatureEvents.COMPLETE,function( ... )
    	self.animNode:removeEventListenerByName(ArmatureEvents.COMPLETE)
    	
    	self:initBg()
    	self.animNode:playByIndex(1)
    end)

end

function FruitTreeUpgradeSharePanel:popout( ... )
	PopoutManager:sharedInstance():add(self, false, false)

	self:setToScreenCenterVertical()
	self:setToScreenCenterHorizontal()
end

function FruitTreeUpgradeSharePanel:removePopout( ... )
	PopoutManager:sharedInstance():remove(self)
end

function FruitTreeUpgradeSharePanel:beforeSrnShot(srnShot, afterSrnShot)
	if self.srnShotNode then
		return
	end
	self.srnShotNode = FruitShareSrnShot:create("share/fruit_tree_share_background.png",function( ... )
		if self.isDisposed then
			return
		end

		self:runAction(CCCallFunc:create(function( ... )
			srnShot()
			afterSrnShot()
		end))
	end)


	
	function buildLevel( n )
		CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("share/fruit_tree_share_level.plist")

		local num = Sprite:createWithSpriteFrameName("fruit_tree_share_level_" .. n .. "0000")
		if _G.__use_small_res == true then
			num:setScale(0.625)
		end
		num:setAnchorPoint(ccp(1,0.5))
		num:setPositionX(252)
		num:setPositionY(1000 - 222)
		self.srnShotNode:addChild(num)

		CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("share/fruit_tree_share_level.plist")
		CCTextureCache:sharedTextureCache():removeTextureForKey(
			CCFileUtils:sharedFileUtils():fullPathForFilename("share/fruit_tree_share_level.png")
		)
	end

	-- for i=1,6 do
	-- 	buildLevel(i)
	-- end
	buildLevel(self.level)
	
	-- self.srnShotNode:setPositionY(-1000)
	-- self:addChild(self.srnShotNode)
end

function FruitTreeUpgradeSharePanel:afterSrnShot()
	if not self.srnShotNode then
		return
	end
	self.srnShotNode:dispose()
	self.srnShotNode = nil
end

function FruitTreeUpgradeSharePanel:srnShot()
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


function FruitTreeUpgradeSharePanel:sendShareImage()
	DcUtil:UserTrack({
		category = "show", 
		sub_category = "push_fruiter_level_button", 
	}, true)

	-- local thumb = CCFileUtils:sharedFileUtils():fullPathForFilename("share/fruit_tree_share_thumb.jpg")
	local thumb = self.shareThumbImagePath
	local shareCallback = {
		onSuccess = function(result)
			self:onShareSucceed()

			DcUtil:UserTrack({
				category = "show", 
				sub_category = "push_fruiter_level_success", 
			}, true)
		end,
		onError = function(errCode, errMsg)
			self:onShareFailed()
		end,
		onCancel = function()
			self:onShareFailed()
		end,
	}

	local shareType, delayResume = SnsUtil.getShareType()
	SnsUtil.sendImageMessage( shareType, self.shareTitleName, self.shareTitleName, thumb, self.shareImagePath, shareCallback )
end

function FruitTreeUpgradeSharePanel:onShareSucceed()
	self:removePopout()
end

function FruitTreeUpgradeSharePanel:onShareFailed()
	local scene = Director:sharedDirector():getRunningScene()
	if scene then
		local shareFailedLocalKey = "share.feed.faild.tips"
		if PlatformConfig:isPlatform(PlatformNameEnum.kMiTalk) then
			shareFailedLocalKey = "share.feed.faild.tips.mitalk"
		end
		CommonTip:showTip(Localization:getInstance():getText(shareFailedLocalKey), 'negative', nil, 2)
	end
end