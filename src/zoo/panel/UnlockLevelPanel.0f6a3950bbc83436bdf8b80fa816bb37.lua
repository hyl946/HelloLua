
require "zoo.panel.basePanel.BasePanel"
require "zoo.baseUI.Progress"

---------------------------------------------------
-------------- UnlockLevelPanel
---------------------------------------------------


assert(not UnlockLevelPanel)
assert(BasePanel)
UnlockLevelPanel = class(BasePanel)

function UnlockLevelPanel:ctor()
end

function UnlockLevelPanel:init(usrTotalStar, neededStar, ...)
	assert(usrTotalStar)
	assert(neededStar)
	assert(#{...} == 0)

	-- ---------------
	-- Get UI Resource
	-- ----------------
	self.resourceManager	= ResourceManager:sharedInstance()
	--self.resourceManager:addJsonFile("flash/panels/panel-2.json")

	self.ui = self.resourceManager:buildGroup("unlockLevelPanel")

	-- ----------------
	-- Init Base Class
	-- ----------------
	BasePanel.init(self, self.ui)

	----------------
	-- Get UI Resource
	-- --------------
	self.title_text 		= self.ui:getChildByName("title_text")
	self.desc_text			= self.ui:getChildByName("desc_text")
	self.subtitle_text		= self.ui:getChildByName("subtitle_text")
	self.notify_text		= self.ui:getChildByName("notify_text")

	self.progress_text		= self.ui:getChildByName("progress_text")
	self.unlock_progress_bar	= self.ui:getChildByName("unlock_progress_bar")

	self.confirm_button		= self.ui:getChildByName("confirm_button")
	self.unlock_level_button	= self.ui:getChildByName("unlock_level_button")
	self.closeBtn			= self.ui:getChildByName("closeBtn")


	assert(self.title_text)
	assert(self.desc_text)
	assert(self.subtitle_text)
	assert(self.notify_text)

	assert(self.progress_text)
	assert(self.unlock_progress_bar)

	assert(self.confirm_button)
	assert(self.unlock_level_button)
	assert(self.closeBtn)

	------------------------
	---- Create UI Component
	------------------------
	-- Progress Bar
	self.progressBar	= Progress:create(self.unlock_progress_bar)

	------------------
	-- Data 
	-- ---------------
	self.neededStar = neededStar
	self.ownedStar	= usrTotalStar

	------------------
	---- Update View
	-----------------
	self.title_text:setString("解锁关卡")
	self.desc_text:setString("你需要收集" .. tostring(self.neededStar) .."颗星星才能解锁新的关卡！")
	self.subtitle_text:setString("当前拥有:")
	self.notify_text:setString("得到三个好友的帮助可提前解锁！")

	self.progress_text:setString(tostring(self.ownedStar) .. " / " .. tostring(self.neededStar))

	--------------------------
	---- Add Event Listener
	----------------------
	
	self.closeBtn:addEventListener(DisplayEvents.kTouchTap, self.onCloseBtnTapped)


	----------------------------------------------
	---- Below For Test Sending Message To Server
	--------------------------------------------

	self.testBtn = self.ui:getChildByName("testBtn")
	assert(self.testBtn)

	local function onTestBtnTapped(event)

		if _G.isLocalDevelopMode then printx(0, "onTestBtnTapped Called !") end

		self:sendUnlockLevelAreaMessage()
	end

	self.testBtn:addEventListener(DisplayEvents.kTouchTap, onTestBtnTapped)
end

function UnlockLevelPanel:sendUnlockLevelAreaMessage(...)
	assert(#{...} == 0)

	local function onSuccess(event)
		if _G.isLocalDevelopMode then printx(0, "unlock area callback success !") end

	end

	local function onFailed(event)
		if _G.isLocalDevelopMode then printx(0, "unlock area callback failed !") end

	end

	local http = UnLockLevelAreaHttp.new()
	http:addEventListener(Events.kComplete, onSuccess)
	http:addEventListener(Events.kError, onFailed)
	http:load()
end

function UnlockLevelPanel.onCloseBtnTapped(event, ...)
	assert(#{...} == 0)
	PopoutManager:sharedInstance():remove(self)
end

function UnlockLevelPanel:onEnterHandler(event, ...)
	assert(#{...} == 0)

	if event == "enter" then

		self:setToScreenCenterHorizontal()
		self:setToTopOutOfScreen()

		local selfPosX	= self:getPositionX()
		local centerPosYInParent = self:getVCenterInParentY()

		-- Action
		local moveToAction	= CCMoveTo:create(1.5, ccp(selfPosX, centerPosYInParent))
		local easeOut		= CCEaseOut:create(moveToAction, 1)
		self:runAction(easeOut)
	end
end

function UnlockLevelPanel:create(usrTotalStar, neededStar, ...)
	assert(usrTotalStar)
	assert(neededStar)

	assert(#{...} == 0)

	local newUnlockLevelPanel = UnlockLevelPanel.new()
	newUnlockLevelPanel:init(usrTotalStar, neededStar)
	return newUnlockLevelPanel
end
