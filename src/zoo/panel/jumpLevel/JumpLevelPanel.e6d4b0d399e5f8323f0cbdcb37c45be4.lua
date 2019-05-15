require "zoo.panelBusLogic.JumpLevelLogic"
require 'zoo.panel.jumpLevel.MoreIngredientPanel'

JumpLevelPanel = class(BasePanel)

function JumpLevelPanel:create(level, levelType, isFromStartGamePanel)
	-- body
	local s = JumpLevelPanel.new()
	s:loadRequiredResource(PanelConfigFiles.jump_level_panel)
	s:init(level, levelType, isFromStartGamePanel)
	return s
end

function JumpLevelPanel:init(level, levelType, isFromStartGamePanel)
	-- body
    FrameLoader:loadArmature( "skeleton/skip_level_animation")
	self.ui = self:buildInterfaceGroup("jump_level_panel")
	self.levelId = level
	self.levelType = levelType
	self.isFromStartGamePanel = isFromStartGamePanel
	BasePanel.init(self, self.ui)

    local npc = self.ui:getChildByName('npc')
    npc:setVisible(false)
    local armature = ArmatureNode:create('racoon')
    armature:playByIndex(0)
    armature:update(0.001)
    armature:stop()
    armature:setPosition(ccp(npc:getPositionX(), npc:getPositionY()))
    npc:getParent():addChildAt(armature, npc:getZOrder())
    self.armature = armature

	self:initButton()
	self:initText()
	local isEnough = JumpLevelManager:getInstance():isEnoughForJumpLevel(level)
	self:initTitle(isEnough)
	if isEnough then
		self:initJump()
	else
		self:initCommond()
	end
end

function JumpLevelPanel:initButton()
	-- body
	local function closeBtnTapped(evt)
		-- body
		self:onCloseBtnTapped()
	end
	self.closeBtn = self.ui:getChildByName("closeBtn")
	self.closeBtn:setTouchEnabled(true, 0, false)
	self.closeBtn:setButtonMode(true)
	self.closeBtn:addEventListener(DisplayEvents.kTouchTap, closeBtnTapped)

	self.okBtn = GroupButtonBase:create(self.ui:getChildByName("enoughBtn"))
	self.okBtn:useBubbleAnimation()

    self.notEnoughBtn = GroupButtonBase:create(self.ui:getChildByName("notEnoughBtn"))
    self.okBtn:useBubbleAnimation()
end

function JumpLevelPanel:initTitle(isEnough)
	local title = self.ui:getChildByName("title")
    local desc = self.ui:getChildByName('desc')
    desc:setString(localize('skipLevel.tips1', {n = '\n', s = ' '}))
	if isEnough then
		title:setText(localize('skipLevel.tips12'))
	else
		title:setText(localize('skipLevel.tips13'))
	end
	local bg = self.ui:getChildByName("bg")
	title:setPositionX((bg:getGroupBounds().size.width - title:getGroupBounds().size.width) / 2 + 30)
end

function JumpLevelPanel:initText()
	self.ui:getChildByName('t1'):setString('拥有')
	self.ui:getChildByName('t2'):setString('需要')
	self.total = self.ui:getChildByName('total')
	-- self.given = self.ui:getChildByName('given')
	self.need = self.ui:getChildByName('need')

	self.total:setString('x'..JumpLevelManager:getInstance():getOwndIngredientNum()..'个')
	-- self.given:setString('0')
	self.need:setString('x'..JumpLevelManager:getInstance():getJumpLevelCost(self.levelId)..'个')
end

function JumpLevelPanel:playTextAnim(total, count, duration)

	local function decreaseNumber(label, total, count, duration, x)
        local interval = 4/60
        local times = math.ceil(duration / interval)
        local endValue = total - count
        local diff = count / times
        local last = total 
        local schedId = nil
        local timesCount = 0
        local function __perFrame()
        	timesCount = timesCount + 1
            local new = last - diff
            if timesCount < times then 
                local ceilNew = math.ceil(new)
                if ceilNew ~= math.ceil(last) then
                    if not label.isDisposed then
                        if x then ceilNew = 'x'..ceilNew end
                        label:setString(ceilNew)
                    end
                end
                last = new
            else 
                if not label.isDisposed then
                    if x then endValue = 'x'..endValue end
                    label:setString(endValue)
                end
                if schedId then
                    CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(schedId)
                    schedId = nil
                end
            end
        end
        schedId = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(__perFrame,interval,false)
        return schedId
    end

    duration = duration or 1.5
    self.schedId1 = decreaseNumber(self.total, total, count, duration, true)
    self.schedId2 = decreaseNumber(self.given, 0, -count, duration, false)
end

function JumpLevelPanel:dispose()
	if self.schedId1 then
		CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.schedId1)
		self.schedId1 = nil
	end
	if self.schedId2 then
		CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.schedId2)
		self.schedId2 = nil
	end
	BasePanel.dispose(self)
end

function JumpLevelPanel:playIngredientFlyAnim(count, duration)
    self.armature:setAnimationScale(0.8)
    self.armature:playByIndex(0)
end

function JumpLevelPanel:initJump()

	local function onJumpBtnTapped(evt)
		self:onJumpBtnTapped()
	end
	local txt = Localization:getInstance():getText("skipLevel.Button3")
	self.okBtn:setString(txt)
	self.okBtn:addEventListener(DisplayEvents.kTouchTap, onJumpBtnTapped)
    self.notEnoughBtn:setVisible(false)
    self.notEnoughBtn:setEnabled(false)
end

function JumpLevelPanel:initCommond( ... )
	local function onJumpBtnTapped( evt )
		self:onCommondTapped()
	end
	local txt = Localization:getInstance():getText("skipLevel.Button4")
	self.notEnoughBtn:setString(txt)
	self.notEnoughBtn:addEventListener(DisplayEvents.kTouchTap, onJumpBtnTapped)
    self.notEnoughBtn:setColorMode(kGroupButtonColorMode.blue)

    self.okBtn:setVisible(false)
    self.okBtn:setEnabled(false)
end

function JumpLevelPanel:onJumpBtnTapped( ... )
    if self.disableClick then return end
    self.disableClick = true

    local originalTotal = JumpLevelManager:getInstance():getOwndIngredientNum()

	local function onSuccessCallback( pawnNum )
        self.disableClick = true
		self.succeeded = true
		local delay = 1 -- s
		local count = JumpLevelManager:getInstance():getJumpLevelCost(self.levelId)
		self:playIngredientFlyAnim(10, delay)

		local function callback()
            self.disableClick = false
            local runningScene = Director:sharedDirector():getRunningScene()
            if runningScene and runningScene:is(GamePlaySceneUI) then
                Director:sharedDirector():popScene()
            end

            local nextLevelId = self.levelId + 1
            if MetaManager.getInstance():getMaxNormalLevelByLevelArea() == self.levelId then
                nextLevelId = self.levelId
            end
			HomeScene:sharedInstance():setEnterFromGamePlay(nextLevelId)
			GamePlayEvents.dispatchPassLevelEvent({levelType=self.levelType, levelId=self.levelId, 
				rewardsIdAndPos={}, jumpLevelPawn = pawnNum,
				isPlayNextLevel=false})
            HomeScene:sharedInstance():runAction(CCCallFunc:create(function () CommonTip:showTip(localize('skipLevel.tips14', {replace1 = self.levelId}), 'positive') end))

			HomeScene:sharedInstance().worldScene:onEnterHandler("enter")
			PopoutManager:sharedInstance():removeAll()
		end
		setTimeOut(callback, delay + 1)	
	end

	local function onFailCallback(err)
		self.disableClick = false
	end

    setTimeOut(
        function() 
            if self.succeeded ~= true then
                self.disableClick = false 
            end
        end, 
        2)

	DcUtil:UserTrack({category = 'skipLevel', sub_category = 'skip_button', t1 = self.levelId, t2 = originalTotal, t3 = true})

	local jumpLevelLogic = JumpLevelLogic:create(
		self.levelId, self.levelType, onSuccessCallback, onFailCallback)
	jumpLevelLogic:start()
end

function JumpLevelPanel:onCommondTapped( ... )
    DcUtil:UserTrack({category = 'skipLevel', sub_category = 'skip_button', t1 = self.levelId, t2 = JumpLevelManager:getInstance():getOwndIngredientNum(), t3 = false})
    local jumpedLevels = JumpLevelManager:getInstance():getJumpedLevels()
    local moreIngredientLevels = JumpLevelManager:getMoreIngredientLevels()
    if #jumpedLevels == 0 and #moreIngredientLevels == 0 then
        CommonTip:showTip(localize('skipLevel.tips10', {n = '\n', s = ' '}))
        return 
    end

	DcUtil:UserTrack({category = 'skipLevel', sub_category = 'open_get_pod', t1 = self.levelId, t2 = JumpLevelManager:getInstance():getOwndIngredientNum(), t3 = 2})

	self:removeSelf()
	local function closeCallback()
		local s = JumpLevelPanel:create(self.levelId, self.levelType, self.isFromStartGamePanel)
    	s:popout()
	end
	local panel = MoreIngredientPanel:create(self.levelId, self.levelType)
	panel:popout(closeCallback)

end

function JumpLevelPanel:popout(closeCallback)
	PopoutManager:sharedInstance():addWithBgFadeIn(self, true, false, false)
	self.allowBackKeyTap = true
end

function JumpLevelPanel:removeSelf()
	PopoutManager:sharedInstance():remove(self, false)
	self.allowBackKeyTap = false
end

function JumpLevelPanel:onCloseBtnTapped()
	self:removeSelf()
	if self.isFromStartGamePanel and not self.succeeded then
		local startGamePanel = StartGamePanel:create(self.levelId, GameLevelType.kMainLevel)
		startGamePanel:revertCallback()
	    startGamePanel:popout(false)
	end
end

function JumpLevelPanel:onEnterHandler(event, ...)
    if event == "enter" then
        self.allowBackKeyTap = true
        self:runAction(self:createShowAnim())
    end
end

function JumpLevelPanel:createShowAnim()
    local centerPosX    = self:getHCenterInParentX()
    local centerPosY    = self:getVCenterInParentY()

    local function initActionFunc()
        local initPosX  = centerPosX
        local initPosY  = centerPosY + 100
        self:setPosition(ccp(initPosX, initPosY))
    end
    local initAction = CCCallFunc:create(initActionFunc)
    local moveToCenter      = CCMoveTo:create(0.5, ccp(centerPosX, centerPosY))
    local backOut           = CCEaseQuarticBackOut:create(moveToCenter, 33, -106, 126, -67, 15)
    local targetedMoveToCenter  = CCTargetedAction:create(self.refCocosObj, backOut)

    local function onEnterAnimationFinished( )self:onEnterAnimationFinished() end
    local actionArray = CCArray:create()
    actionArray:addObject(initAction)
    actionArray:addObject(targetedMoveToCenter)
    actionArray:addObject(CCCallFunc:create(onEnterAnimationFinished))
    return CCSequence:create(actionArray)
end

function JumpLevelPanel:onEnterAnimationFinished()

end