local NewYear2017GetMailAnim = class()

function NewYear2017GetMailAnim:create()
	local anim = NewYear2017GetMailAnim.new()
	anim:init()
	return anim
end

local timeSlice = 0.03


function NewYear2017GetMailAnim:getActivityIconButtonPos()
	local scene = HomeScene:sharedInstance()
	if scene.activityIconButtons then
		for _, v in pairs(scene.activityIconButtons) do
			if v.source == "NewYear2017/Config.lua" then
				local gb = CocosObject.getGroupBounds(v)
				local pos = ccp(gb:getMidX(), gb:getMidY())
				return pos
			end
		end
	end

	local visibleSize = CCDirector:sharedDirector():getVisibleSize()
    local visibleOrigin = CCDirector:sharedDirector():getVisibleOrigin()
	return ccp(visibleOrigin.x + visibleSize.width - 70, visibleOrigin.y + visibleSize.height / 2)
end

function NewYear2017GetMailAnim:startFlyMailAnim( ... )
	if self.ui ~= nil and not self.ui.isDisposed and not self.flyFlag then
		self.flyFlag = true
		self.mailAnim:update(0.001)
		self.mailAnim:stop()
		self.mailAnim:playByIndex(1, 1)
		local toPos = self:getActivityIconButtonPos()
		self.mailAnim:runAction(CCMoveTo:create(timeSlice * 10, toPos))
	end
end

function NewYear2017GetMailAnim:init()
	local scene = Director:sharedDirector():getRunningScene()
	if scene == nil then return end

	self.ui = LayerColor:createWithColor(ccc3(0, 0, 0), 960, 1280)
    self.ui:setOpacity(200)
    self.ui:setPosition(ccp(0, 0))
    self.ui:setTouchEnabled(true, 0, true)

	FrameLoader:loadArmature("tempFunctionRes/NewYear2017GainCard", "NewYear2017GainCard", "NewYear2017GainCard")
	self.bgAnim = ArmatureNode:create("NewYear2017GainCard/BGGLowAnim")
	self.mailAnim = ArmatureNode:create("NewYear2017GainCard/MailAnim2")
	self.mailAnim:addEventListener(ArmatureEvents.COMPLETE, function()
    	self:startFlyMailAnim()
    end)
	if not scene:is(HomeScene) then
		self.iconAnim = ArmatureNode:create("NewYear2017GainCard/IconAnim") 
	end
	self.gainCardFgAnim = ArmatureNode:create("NewYear2017GainCard/GainCard")

	local visibleSize = CCDirector:sharedDirector():getVisibleSize()
    local visibleOrigin = CCDirector:sharedDirector():getVisibleOrigin()
    local scale = math.min(visibleSize.height / 1280, visibleSize.width / 720)
    local visibleSize = CCDirector:sharedDirector():getVisibleSize()
    local pos = ccp(visibleOrigin.x + visibleSize.width/2, visibleOrigin.y + visibleSize.height/2)

	self:addAnim(self.bgAnim, scale, pos)
	if self.iconAnim ~= nil then 
		local iconPos = self:getActivityIconButtonPos()
		self:addAnim(self.iconAnim, scale, iconPos) 
	end
	self:addAnim(self.mailAnim, scale, pos)
    self:addAnim(self.gainCardFgAnim, scale, pos)

    self.gainCardFgAnim:addEventListener(ArmatureEvents.COMPLETE, function( ... )
    	setTimeOut(function( ... )
    		self:removeAndDispose()
    	end, 0.2)
    end)

    self.ui:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(timeSlice * 11), CCCallFunc:create(function( ... )
    	self:addFGAnim()
    end)))
    
    scene:addChild(self.ui, SceneLayerShowKey.TOP_LAYER)
    self.builder = InterfaceBuilder:createWithContentsOfFile("tempFunctionRes/NewYear2017AnimFG.json")
end

function NewYear2017GetMailAnim:addAnim(anim, scale, pos)
	anim:playByIndex(0, 1)
    anim:update(0.001)
    anim:stop()
    anim:setScale(scale)
    anim:setPosition(pos)
    anim:playByIndex(0, 1)
    self.ui:addChild(anim)
end

function NewYear2017GetMailAnim:addFGAnim()
	if self.ui ~= nil and not self.ui.isDisposed then
		local fgAnim = self:createPapersAnimation()
		local visibleSize = CCDirector:sharedDirector():getVisibleSize()
    	fgAnim:setPosition(ccp(visibleSize.width/2, visibleSize.height/2))
		self.ui:addChild(fgAnim)
	end
end

function NewYear2017GetMailAnim:removeAndDispose( ... )
	self.ui:removeFromParentAndCleanup(true)
	InterfaceBuilder:unloadAsset("tempFunctionRes/NewYear2017AnimFG.json")
	ArmatureFactory:remove("NewYear2017GainCard", "NewYear2017GainCard")
	gKeyBackEnableFlag = true
end

function NewYear2017GetMailAnim:createPapersAnimation()
	local paperPlistName = "tempFunctionRes/NewYear2017AnimFG.plist"
	local paperTextureName = "tempFunctionRes/NewYear2017AnimFG.png"
	if _G.__use_small_res then
		paperTextureName = "tempFunctionRes/NewYear2017AnimFG@2x.png"
	end
	self.paperPlistName = paperPlistName

	FrameLoader:loadImageWithPlist(paperPlistName)

	local function setPaperAnim(ui)
		ui:setPositionXY(-200 + math.random() * 400, 240)
		ui:setScale(math.random() * 0.4 + 0.6)
		ui:setOpacity(0)
		local arr = CCArray:create()
		arr:addObject(CCDelayTime:create(math.random() * 2))
		local time = math.random() * 0.8 + 1.7
		local arr2 = CCArray:create()
		arr2:addObject(CCSpawn:createWithTwoActions(CCFadeIn:create(time * 0.2), CCMoveBy:create(time, ccp(math.random() * 300 - 150, -630))))
		arr2:addObject(CCRotateBy:create(time, math.random(1000) - 500))
		arr2:addObject(CCSequence:createWithTwoActions(CCDelayTime:create(time * 0.4), 
			CCFadeOut:create(time * 0.2)))

		arr:addObject(CCSpawn:create(arr2))
		arr:addObject(CCCallFunc:create(function() setPaperAnim(ui) end))
		ui:stopAllActions()
		ui:runAction(CCSequence:create(arr))
	end
	local sprite = SpriteBatchNode:create(paperTextureName, 100)
	for i = 1, 30 do
		local paper = Sprite:createWithSpriteFrameName("NewYear2017AnimFG/part"..tostring(i % 5 + 1).."0000")
		setPaperAnim(paper)
		sprite:addChild(paper)
	end
	return sprite
end

return NewYear2017GetMailAnim