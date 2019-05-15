
-- Copyright C2009-2013 www.happyelements.com, all rights reserved.
-- Create Date:	2013年10月21日 19:38:25
-- Author:	ZhangWan(diff)
-- Email:	wanwan.zhang@happyelements.com

---------------------------------------------------
-------------- RankListButton
---------------------------------------------------

assert(not RankListButtonCheckState)
RankListButtonCheckState =
{
	SERVER_RANK_CHECKED	= 1,
	FRIEND_RANK_CHECKED	= 2
}

assert(not RankListButton)
assert(BaseUI)
RankListButton = class(BaseUI)

function RankListButton:init(uiResource, tappedCallback,levelFlag, ...)
	assert(uiResource)
	assert(tappedCallback == false or type(tappedCallback) == "function")
	assert(#{...} == 0)

	self.levelFlag = levelFlag
	-- ---------
	-- Init Base
	-- -----------
	BaseUI.init(self, uiResource)

	-- --------------
	-- Get UI Resource
	-- ----------------
	--self.label		= self.ui:getChildByName("label")
	self.showLabel		= self.ui:getChildByName("showLabel")
	self.hideLabel		= self.ui:getChildByName("hideLabel")


	self.tappedBg		= self.ui:getChildByName("tappedBg")
	self.notTappedBg	= self.ui:getChildByName("notTappedBg")

	--assert(self.label)
	assert(self.showLabel)
	assert(self.hideLabel)
	assert(self.tappedBg)
	assert(self.notTappedBg)

	-----------------
	--- Data
	---------------
	self.tappedCallback	= tappedCallback

	self.BUTTON_STATE_TAPPED	= 1
	self.BUTTON_STATE_NOT_TAPPED	= 2
	self.btnTapState		= self.BUTTON_STATE_TAPPED

	--------------------
	---- Init View
	-----------------
	self.notTappedBg:setOpacity(255*0.5)
	self.notTappedBg:setVisible(false)
	self.hideLabel:setVisible(false)

	-------------------------
	---- Add Event Listener
	------------------------
	self.ui:setTouchEnabled(true, 0, true)

	local function onButtonTapped(event)
		self:onButtonTapped(event)
	end
	self.ui:addEventListener(DisplayEvents.kTouchTap, onButtonTapped)


	if self.levelFlag == LevelDiffcultFlag.kExceedinglyDifficult then 
		self.showLabel:setColor((ccc3(134,87,205)))
	end

end

function RankListButton:setString(str, ignoreHorizontalCenter)
	assert(type(str) == "string")
	
	self.showLabel:setString(str)
	if not ignoreHorizontalCenter then 
		self.showLabel:setToParentCenterHorizontal()
	end
	self.showLabel:setToParentCenterVertical()

	self.hideLabel:setString(str)
	self.hideLabel:setToParentCenterHorizontal()
	self.hideLabel:setToParentCenterVertical()
end

function RankListButton:onButtonTapped(event, ...)
	assert(event)
	assert(event.name == DisplayEvents.kTouchTap)
	assert(event.globalPosition)
	assert(#{...} == 0)

	if _G.isLocalDevelopMode then printx(0, "RankListButton:onButtonTapped Called !") end

	if self.btnTapState == self.BUTTON_STATE_NOT_TAPPED then
		self.btnTapState = self.BUTTON_STATE_TAPPED

		self.tappedBg:setVisible(true)
		self.notTappedBg:setVisible(false)

		self.showLabel:setVisible(true)
		self.hideLabel:setVisible(false)

		if self.tappedCallback then
			self.tappedCallback()
		end
	end
end

function RankListButton:setToUntappedState(...)
	assert(#{...} == 0)

	self.btnTapState = self.BUTTON_STATE_NOT_TAPPED
	self.tappedBg:setVisible(false)
	self.notTappedBg:setVisible(true)

	self.showLabel:setVisible(false)
	self.hideLabel:setVisible(true)
end

function RankListButton:create(uiResource, tappedCallback,levelFlag, ...)
	assert(uiResource)
	assert(tappedCallback == false or type(tappedCallback) == "function")
	assert(#{...} == 0)

	local newRankListButton = RankListButton.new()
	newRankListButton:init(uiResource, tappedCallback , levelFlag )
	return newRankListButton
end
