require "zoo.localActivity.CollectStars.CollectStarsManager"

local ScoreBuffBottleLevelSuccessPanel = class(BasePanel)

function ScoreBuffBottleLevelSuccessPanel:create(oldBottleAmount)
	local panel = ScoreBuffBottleLevelSuccessPanel.new()
	panel:loadRequiredResource("tempFunctionRes/CollectStars2018/panel.json")
	panel:init(oldBottleAmount)
	return panel
end

function ScoreBuffBottleLevelSuccessPanel:init(oldBottleAmount)
	self.oldBottleAmount = math.min(oldBottleAmount, 5)
	self.newBottleAmount = math.min(oldBottleAmount + 1, 5)

	self.ui = self:buildInterfaceGroup("CollectStars2018/scoreBuffBottle_LevelSuccessAnim")
	BasePanel.init(self, self.ui)
	self.panelLuaName = "ScoreBuffBottleLevelSuccessPanel"

	self.closeBtn = self.ui:getChildByName("close")
	self.closeBtn:addEventListener(DisplayEvents.kTouchTap, function ()
		self:onCloseBtnTapped()
	end)
	self.closeBtn:setTouchEnabled(true)

	self.jumpBtn = ButtonWithShadow:create(self.ui:getChildByName("jumpBtn"))	--别的面板用的
    if self.jumpBtn then
		self.jumpBtn:setVisible(false)
	end

	self:initStatus()
	self:playAppearAnimation()
end

function ScoreBuffBottleLevelSuccessPanel:initStatus()
	-- LevelSuccessTopPanel 中已经进行了加载
	-- FrameLoader:loadArmature('tempFunctionRes/CollectStars2018/levelSuccessAnim', 'ScoreBuffBottleLevelSuccess', 'ScoreBuffBottleLevelSuccess')
	-- FrameLoader:loadArmature('tempFunctionRes/CollectStars2018/skeleton/bottle5', 'bottle5', 'bottle5')

	local bottleNode = ArmatureNode:create("CollectStars2018_sk/allbottle")
	bottleNode:playByIndex(tostring(self.oldBottleAmount))
	-- bottleNode:play("0"..tostring(self.oldBottleAmount))
	bottleNode:update(0.001)
	bottleNode:stop()
	-- bottleNode:unscheduleUpdate()
	self.ui:addChild(bottleNode)
	bottleNode:setPosition(ccp(40, -300))
	self.bottleNode = bottleNode

	local animNode = ArmatureNode:create("scoreBuffBottle_leveSuccessNPC")
	animNode:playByIndex(0)
	animNode:update(0.001)
	animNode:stop()
	-- animNode:unscheduleUpdate()
	self.ui:addChild(animNode)
	animNode:setPosition(ccp(300, -500))
	self.animNode = animNode

	for index = 1, 5 do
		self:setSlotVisible("btlNum"..index, index == self.newBottleAmount)
	end

	local effectPercent = CollectStarsManager:getInstance():getScoreBuffBottleEffectPercent()
	local totalEffectVal = effectPercent * 100 * self.newBottleAmount
	local percentStr = tostring(totalEffectVal)

    local percentNum = BitmapText:create(percentStr.."%", 'fnt/prop_name.fnt', 0)
    percentNum:setAnchorPoint(ccp(0.5, 0.5))
    percentNum:setColor(ccc3(255, 113, 44))
    percentNum:setScale(0.75)
    local sprite = Sprite:createEmpty()
    sprite:addChild(percentNum)
    percentNum:setPosition(ccp(32, -18))

	local slot = self.animNode:getSlot("percentNum")
    slot:setDisplayImage(sprite.refCocosObj)
end

function ScoreBuffBottleLevelSuccessPanel:setSlotVisible( slotName, visible )
	local slot = self.animNode:getSlot(slotName)
	if slot and not visible then
		local sprite = Sprite:createEmpty()
	    slot:setDisplayImage(sprite.refCocosObj)
	end
end

function ScoreBuffBottleLevelSuccessPanel:playAppearAnimation()
	if self.isDisposed then return end

	local function onAutoRemovePanel()
		if self.isDisposed then return end
		self:remove()
	end

	local function onDialogueAppearFinished()
		if self.isDisposed then return end
		if self.animNode then
			self.animNode:removeEventListenerByName(ArmatureEvents.COMPLETE)
			self.animNode:stop()
		end

		setTimeOut(onAutoRemovePanel, 3)
	end

	local function onNPCAppearFinished()
		if self.isDisposed then return end
		if self.bottleNode and (self.newBottleAmount > self.oldBottleAmount) then
			self.bottleNode:playByIndex(tostring(self.oldBottleAmount))
			-- self.bottleNode:play("0"..tostring(self.oldBottleAmount))
		end

		if self.animNode then
			self.animNode:removeEventListenerByName(ArmatureEvents.COMPLETE)
			self.animNode:play("dialogueAppear")
			self.animNode:addEventListener(ArmatureEvents.COMPLETE, onDialogueAppearFinished)
		end
	end

	if self.animNode then
		self.animNode:play("appear")
		self.animNode:addEventListener(ArmatureEvents.COMPLETE, onNPCAppearFinished)
	end
end

function ScoreBuffBottleLevelSuccessPanel:onCloseBtnTapped()
	self:remove()
end

function ScoreBuffBottleLevelSuccessPanel:remove()
	self.allowBackKeyTap = false
	PopoutManager:sharedInstance():remove(self, true)

	-- LevelSuccessTopPanel 中已经进行了卸载
	-- FrameLoader:unloadArmature('tempFunctionRes/CollectStars2018/levelSuccessAnim', true)
	-- FrameLoader:unloadArmature('tempFunctionRes/CollectStars2018/skeleton/bottle5', true)
end

function ScoreBuffBottleLevelSuccessPanel:layout()
	local winSize = CCDirector:sharedDirector():getVisibleSize()

	local w = 720
	local h = 1280

	local r = winSize.height / h
	if r < 1.0 then
		self:setScale(r)
	end

	local x = self:getHCenterInParentX()
	local y = self:getVCenterInParentY()
	self:setPosition(ccp(x, y))

	local container = self:getParent()
	if container then
		container = container:getParent()
	end
	if container and container.darkLayer then
		container.darkLayer:setOpacity(200)
	end
end

function ScoreBuffBottleLevelSuccessPanel:popoutShowTransition()
    self.allowBackKeyTap = true
    self:layout()
end

function ScoreBuffBottleLevelSuccessPanel:popout()
	self.allowBackKeyTap = true
	if AutoPopout:isInNextLevelMode() then
		--进入下一关模式了 咱们就需要用add了 用push弹不出来是正常的
		PopoutManager:sharedInstance():add(self, true,false)
		self:popoutShowTransition()
	else
		PopoutQueue:sharedInstance():push(self, true, false)
	end

end

return ScoreBuffBottleLevelSuccessPanel