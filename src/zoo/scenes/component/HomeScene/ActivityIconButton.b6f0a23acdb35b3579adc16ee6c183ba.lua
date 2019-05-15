require "zoo.scenes.component.HomeScene.iconButtons.IconButtonBase"
require "zoo.util.ActivityUtil"

ActivityIconButton = class(IconButtonBase)

function ActivityIconButton:create( source,version )
	local button = ActivityIconButton.new()
	button:init( source,version )
	return button
end

function ActivityIconButton:ctor( ... )
	self.playTipPriority = 0
end
function ActivityIconButton:playHasNotificationAnim(...)
	IconButtonManager:getInstance():addPlayTipActivityIcon(self)
end
function ActivityIconButton:stopHasNotificationAnim(...)
	IconButtonManager:getInstance():removePlayTipActivityIcon(self)
end

function ActivityIconButton:dispose( ... )

	for i,v in ipairs(ActivityUtil.onActivityStatusChangeCallbacks) do
		if v.obj == self and v.func == self.onActivityStatusChange then 
			table.remove(ActivityUtil.onActivityStatusChangeCallbacks,i)
			break
		end
	end

	if self.onUserLogin then
		GlobalEventDispatcher:getInstance():removeEventListener(
			kGlobalEvents.kUserLogin,
			self.onUserLogin
		)
	end

	IconButtonBase.dispose(self)
end

function ActivityIconButton:init( source,version )
	self.idPre = "ActivityIconButton_" .. source
	self.id = self.idPre .. self.tipState

	self.source = source
	self.version = version

	local config = require("activity/" .. source)

	self["tip"..IconTipState.kNormal] = config.tips 
	self["tip"..IconTipState.kExtend] = config.tipsExtend 
	self["tip"..IconTipState.kReward] = config.tipsReward 

	self.leftRegionLayoutBar = config.leftRegionLayoutBar

	local region = IconButtonBasePos.RIGHT
	if self.leftRegionLayoutBar then
		region = IconButtonBasePos.LEFT
	end

	self.homeSceneRegion = config.iconHomeSceneRegion or region
	self.indexKey = config.iconIndexKey or source
	self.showHideOption = config.iconShowHideOption or ShowHideOptions.DO_NOTHING
	self.showPriority = config.iconShowPriority or 96

	self.playTipPriority = config.actPriority or 999
	self.tipShowCount = config.tipShowCount or 999

	self.clickReplaceScene = config.clickReplaceScene
	self.playIconAnim = config.playIconAnim
	self.notLoginPlayIconAnim = config.notLoginPlayIconAnim

	self.ui = ResourceManager:sharedInstance():buildGroup("home_scene_icon/btns/btn_i_activity_icon")

	IconButtonBase.init(self, self.ui)

	self.icon = self:buildIcon()
	local iconPh = self.wrapper:getChildByName("iconPh")
	iconPh:addChild(self.icon)

	self.rewardIcon = self:addRedDotReward()
    self.numTip = self:addRedDotNum()

    local label = self:buildLabel()
    if label then
    	self.ui:addChild(label) 
    	label:setPosition(ccp(0 ,-51))
    end

	if self.homeSceneRegion == IconButtonBasePos.LEFT then
		self:setTipPosition(IconButtonBasePos.RIGHT)
	else
		self:setTipPosition(IconButtonBasePos.LEFT)
	end

	self.wrapper:addEventListener(DisplayEvents.kTouchTap,function( ... )
		if PopoutManager:sharedInstance():haveWindowOnScreen() then 
			return 
		end
		local hasPopCenter = ActivityCenter:tryPopoutCenter( config.actId )
		if not hasPopCenter then
			ActivityData.new(self):start(true,true)
		end
	end)

	table.insert(ActivityUtil.onActivityStatusChangeCallbacks,{
		obj = self,
		func = self.onActivityStatusChange
	})

	if not _G.kUserLogin then
		self.onUserLogin = function( ... )
			self:onActivityStatusChange(self.source)
		end
		GlobalEventDispatcher:getInstance():addEventListener(
			kGlobalEvents.kUserLogin,
			self.onUserLogin
		)
	end

	self:onActivityStatusChange(self.source)
end

function ActivityIconButton:buildIcon( ... )
	local config = require("activity/" .. self.source)

	local image = Sprite:create("activity/" .. config.icon)
	image:setAnchorPoint(ccp(0.5,0.5))

	return image
end

function ActivityIconButton:buildLabel()
end

function ActivityIconButton:onActivityStatusChange( source )
	if self.source ~= source then 
		return 
	end

    self:stopHasNumberAni()
    self:stopHasRewardAni()
    self:stopRedDotJumpAni(self.rewardIcon)

	local function setMsgNum( num )
		self.msgNum = num
		self.numTip:setNum(num)
		self.numTip:setVisible(true)
		if num > 0 then
            self:playHasNumberAni()
        end
	end

	local function showRewardIcon( ... )
		self.numTip:setVisible(false)
		self.rewardIcon:setVisible(true)
        self:playRedDotJumpAni(self.rewardIcon)
        self:playHasRewardAni()
	end

	local function hideRewardIcon( ... )
		setMsgNum(self.msgNum or 0)
		self.rewardIcon:setVisible(false)
	end

	local function needPlayIconAnim( ... )
		return self:__needPlayIconAnim()
	end

	setMsgNum(ActivityUtil:getMsgNum( self.source ))
	if ActivityUtil:noTip(self.source) then --在ActInfo 的rewardFlag = 3情况下不显示tip
		self.tipState = nil
	elseif ActivityUtil:hasRewardMark( self.source ) then 
		self.tipState = IconTipState.kReward
		self.id = self.idPre .. self.tipState
		showRewardIcon()
	else
		self.tipState = IconTipState.kNormal
		self.id = self.idPre .. self.tipState
		hideRewardIcon()
	end

	if self.tipState then 
		local tips = self["tip"..self.tipState]
		if tips then 
			self:setTipString(tips)
		 	self:playHasNotificationAnim()
		end
	end

	if needPlayIconAnim() then
		self:playOnlyIconAnim()
	else
		self:stopOnlyIconAnim()
	end
end

function ActivityIconButton:__needPlayIconAnim()
	if self.tip then --有tip动画
		return true
	elseif not _G.kUserLogin and self.notLoginPlayIconAnim then
		return true
	elseif ActivityUtil:getMsgNum(self.source) > 0 and self.playIconAnim then
		return true
	elseif ActivityUtil:hasRewardMark(self.source) and self.playIconAnim then
		return true
	else
		return false
	end
end

function ActivityIconButton:addToUi( homeScene )
	HomeScene:sharedInstance():addIcon(self)
end

function ActivityIconButton:removeFromUi( homeScene )
	HomeScene:sharedInstance():removeIcon(self, true)
end

function ActivityIconButton:getGroupBounds()
	local wrapperSize
	if self.ui ~= nil then
		wrapperSize = self.ui:getChildByName("wrapperSize")
	end

	if wrapperSize then
		return wrapperSize:getGroupBounds()
	else
		return self.icon:getGroupBounds()
	end
end