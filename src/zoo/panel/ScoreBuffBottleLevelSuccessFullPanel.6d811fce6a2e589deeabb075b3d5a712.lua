require "zoo.localActivity.CollectStars.CollectStarsManager"

local ScoreBuffBottleLevelSuccessFullPanel = class(BasePanel)

function ScoreBuffBottleLevelSuccessFullPanel:create(isFourStar, nextLevel, jumpCallBack)
	local panel = ScoreBuffBottleLevelSuccessFullPanel.new()
	panel:loadRequiredResource("tempFunctionRes/CollectStars2018/panel.json")
	panel:init(isFourStar, nextLevel, jumpCallBack)
	return panel
end

function ScoreBuffBottleLevelSuccessFullPanel:init(isFourStar, nextLevel, jumpCallBack)
	self.isFourStar = isFourStar
	self.nextLevel = nextLevel
	self.jumpCallBack = jumpCallBack

	self.ui = self:buildInterfaceGroup("CollectStars2018/scoreBuffBottle_LevelSuccessAnim")
	BasePanel.init(self, self.ui)
	self.panelLuaName = "ScoreBuffBottleLevelSuccessFullPanel"

    self.jumpBtn = GroupButtonBase:create(self.ui:getChildByName("jumpBtn"))
    if self.jumpBtn then
    	local jumpBtnTxt = Localization:getInstance():getText("activity.farmstar.button.skip", {})
		self.jumpBtn:setString(jumpBtnTxt)
		self.jumpBtn:addEventListener(DisplayEvents.kTouchTap, function ()
	        self:onCloseBtnTapped()
	        if self.jumpCallBack and type(self.jumpCallBack) == 'function' then
		    	self.jumpCallBack()
		    end
	    end)
		-- local label = self.jumpBtn:getLabel()
		-- local labelCurPos = label:getPosition()
		-- label:setPosition(ccp(labelCurPos.x - 3, labelCurPos.y - 10))
    end
	

	self.closeBtn = self.ui:getChildByName("close")
	self.closeBtn:addEventListener(DisplayEvents.kTouchTap, function ()
		self:onCloseBtnTapped()
	end)
	self.closeBtn:setTouchEnabled(true)

	self:initStatus()
	self:playAppearAnimation()
end

function ScoreBuffBottleLevelSuccessFullPanel:initStatus()
	local animNode = ArmatureNode:create("scoreBuffBottle_leveSuccessFull")
	animNode:playByIndex(0)
	animNode:update(0.001)
	animNode:stop()
	-- animNode:unscheduleUpdate()
	self.ui:addChild(animNode)
	animNode:setPosition(ccp(70, -300))
	self.animNode = animNode

	if self.nextLevel and self.nextLevel > 0 then
		if self.jumpBtn then
			self.jumpBtn:setVisible(true)
			self.jumpBtn:setPosition(ccp(360, -1000))
		end
		self:setSlotVisible("txt_end", false)
	else
		if self.jumpBtn then
			self.jumpBtn:setVisible(false)
		end
		self:setSlotVisible("txt_con", false)
	end

	if self.isFourStar then
		self:setSlotVisible("starTxt_3", false)
	else
		self:setSlotVisible("starTxt_4", false)
	end
end

function ScoreBuffBottleLevelSuccessFullPanel:setSlotVisible( slotName, visible )
	local slot = self.animNode:getSlot(slotName)
	if slot and not visible then
		local sprite = Sprite:createEmpty()
	    slot:setDisplayImage(sprite.refCocosObj)
	end
end

function ScoreBuffBottleLevelSuccessFullPanel:playAppearAnimation()
	if self.isDisposed then return end

	local function onAutoRemovePanel()
		if self.isDisposed then return end
		self:remove()
	end

	local function onAllAnimationFinished()
		if self.isDisposed then return end
		if self.animNode then
			self.animNode:removeEventListenerByName(ArmatureEvents.COMPLETE)
			self.animNode:stop()
		end
	end

	if self.animNode then
		self.animNode:play("appear")
		self.animNode:addEventListener(ArmatureEvents.COMPLETE, onAllAnimationFinished)
	end

	if not self.nextLevel or self.nextLevel <= 0 then
		setTimeOut(onAutoRemovePanel, 4)
	end
end

function ScoreBuffBottleLevelSuccessFullPanel:onCloseBtnTapped()
	self:remove()
end

function ScoreBuffBottleLevelSuccessFullPanel:remove()
	self.allowBackKeyTap = false
	PopoutManager:sharedInstance():remove(self, true)
end

function ScoreBuffBottleLevelSuccessFullPanel:layout()
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

function ScoreBuffBottleLevelSuccessFullPanel:popoutShowTransition()
    self.allowBackKeyTap = true
    self:layout()
end

function ScoreBuffBottleLevelSuccessFullPanel:popout()
	self.allowBackKeyTap = true

	
	if AutoPopout:isInNextLevelMode() then
		--进入下一关模式了 咱们就需要用add了 用push弹不出来是正常的
		PopoutManager:sharedInstance():add(self, true,false)
		self:popoutShowTransition()
	else
		PopoutQueue:sharedInstance():push(self, true, false)
	end

	
end

return ScoreBuffBottleLevelSuccessFullPanel