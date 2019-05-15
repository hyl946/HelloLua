---------------------------------------------------
-------------- LadybugButton
---------------------------------------------------

assert(not LadybugButton)
LadybugButton = class(IconButtonBase)

function LadybugButton:ctor()
    self.idPre = "LadybugButton"
    self.playTipPriority = 30
end

function LadybugButton:playHasNotificationAnim()
	-- LadybugButton 每秒都会刷新 特殊处理
	if not self.isNotificationAnimPlayed then 
		IconButtonManager:getInstance():addPlayTipNormalIcon(self)
		self.isNotificationAnimPlayed = true
	end
end

function LadybugButton:stopHasNotificationAnim()
    IconButtonManager:getInstance():removePlayTipNormalIcon(self)
    self.isNotificationAnimPlayed = false
end

function LadybugButton:updateIconTipShow(tipState)
	if not tipState then return end
	if tipState ~= self.tipState then 
		self.isNotificationAnimPlayed = false
	end
	self.tipState = tipState
	self.id = self.idPre .. self.tipState

	local tips = self["tip"..self.tipState]
	if tips then 
		self:setTipString(tips)
	 	self:playHasNotificationAnim()
	end
end

function LadybugButton:init()
	self.isNotificationAnimPlayed = false

	--self["tip"..IconTipState.kNormal] = Localization:getInstance():getText("有新的瓢虫任务哦~", {}) 
	--self["tip"..IconTipState.kExtend] = ""
	self["tip"..IconTipState.kReward] = Localization:getInstance():getText("lady.bug.icon.rewards.tips", {})  

	-- ----------------
	-- Get UI Resource
	-- ---------------
    self.ui = ResourceManager:sharedInstance():buildGroup('home_scene_icon/btns/btn_i_ladybug')

	------------------
	-- Init Base Class
	-- --------------
	IconButtonBase.init(self, self.ui)

	-------------------
	-- Init UI Resource
	-- ------------------
	local ladybugRewardTipKey	= "lady.bug.icon.rewards.tips"
	local ladybugRewardTipValue	= Localization:getInstance():getText(ladybugRewardTipKey, {})
	self:setTipString(ladybugRewardTipValue)
end

function LadybugButton:setTimeLabelString(timeString)
	self:setCustomizedLabel(timeString)
end

function LadybugButton:create()
	local newLadybugButton = LadybugButton.new()
	newLadybugButton:init()
	newLadybugButton:initShowHideConfig(ManagedIconBtns.LADYBUG)
	return newLadybugButton
end
