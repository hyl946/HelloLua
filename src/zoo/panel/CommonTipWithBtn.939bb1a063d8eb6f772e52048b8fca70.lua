
require "zoo.panel.basePanel.BasePanel"
require "zoo.baseUI.ButtonWithShadow"

CommonTipWithBtn = class(BasePanel)

local tType = {
	["negative"] = 1,
	["positive"] = 2,
}
local panels = {}
-- text = {
-- 	tip = "",
-- 	yes = "",
-- 	no = "",
-- }
local showFreeFCash = false
function CommonTipWithBtn:setShowFreeFCash(enable)
	showFreeFCash = enable 
	if __WP8 then showFreeFCash = false end
end

function CommonTipWithBtn:showTip(text, panType, yesCallback, noCallback, position, isHideCancelBtn)
	local panel = CommonTipWithBtn:create(text, tType[panType], yesCallback, noCallback, position)
	if not panel then
		return nil
	end

	if isHideCancelBtn then 
		panel:hideCancelBtn()
	end

	if not position then 
		panel:centerPosition()
	end

	table.insert(panels, panel)
	while #panels > 2 do
		panels[1]:removeSelf()
		table.remove(panels, 1)
	end

	PopoutManager:sharedInstance():add(panel, false, false)
	if showFreeFCash then
        FreeFCashPanel:showWithOwnerCheck(panel)
    end

    return panel
end

function CommonTipWithBtn:loadRequiredResource( panelConfigFile )
	self.panelConfigFile = panelConfigFile
	self.builder = InterfaceBuilder:create(panelConfigFile)
end
function CommonTipWithBtn:create(textList, panType, yesCallback, noCallback, position)
	local panel = CommonTipWithBtn.new()
	panel:loadRequiredResource(PanelConfigFiles.common_ui)
	if panel:init(textList, panType, yesCallback, noCallback, position) then
		return panel
	else
		panel = nil
		return nil
	end
end

function CommonTipWithBtn:hideCancelBtn()
	if self.orangeBtn then self.orangeBtn:setVisible(false) end
	local pos1 = self.greenBtn:getPosition()
	local pos2 = self.orangeBtn:getPosition()
	pos = ccp((pos1.x + pos2.x)/2, (pos1.y + pos2.y)/2)
	self.greenBtn:setPosition(pos)
end

function CommonTipWithBtn:centerPosition()
	self:setPositionForPopoutManager()
end

function CommonTipWithBtn:dispose()
	BaseUI.dispose(self)
end

function CommonTipWithBtn:init(text, panType, yesCallback, noCallback, position)
	text = text or {tip = "", yes = "", no = "", noFadeOut = false}
	self.noFadeOut = text.noFadeOut
	panType = panType or 2

	self.ui = self.builder:buildGroup("ui_groups/ui_group_tip_b") --ResourceManager:sharedInstance():buildGroup("commontipwithbtn")
	BasePanel.init(self, self.ui)
	local originSize = self.ui:getGroupBounds().size
	local wSize = Director:sharedDirector():getWinSize()
	local vSize = Director:sharedDirector():getVisibleSize()
	local vOrigin = Director:sharedDirector():getVisibleOrigin()

	self.text = self.ui:getChildByName("text")
	self.anim1 = self.ui:getChildByName("anim1")
	self.anim2 = self.ui:getChildByName("anim2")
	self.background = self.ui:getChildByName("bg")
	self.background2 = self.ui:getChildByName("bg2")
	self.orangeBtn = self.ui:getChildByName("orangeBtn")
	self.greenBtn = self.ui:getChildByName("greenBtn")
	if not text then return false end
	if panType == 1 then
		self.anim1:removeFromParentAndCleanup(true)
		self.anim1 = nil
	elseif panType == 2 then
		self.anim2:removeFromParentAndCleanup(true)
		self.anim2 = nil
	end
	self.orangeBtn = GroupButtonBase:create(self.orangeBtn)
	self.greenBtn = GroupButtonBase:create(self.greenBtn)
	self.orangeBtn:setColorMode(kGroupButtonColorMode.orange)

	local dim = self.text:getDimensions()
	self.text:setDimensions(CCSizeMake(dim.width, 0))
	self.text:setString(text.tip or "")
	self.orangeBtn:setString(text.no or "")
	self.greenBtn:setString(text.yes or "")
	local bgSize = self.background:getGroupBounds().size
	local bgSize2 = self.background2:getGroupBounds().size
	local bgPos = self.background:getPosition()
	local bgPos2 = self.background2:getPosition()
	local txPos = self.text:getPosition()
	local add = self.text:getContentSize().height - dim.height
	self.background:setPreferredSize(CCSizeMake(bgSize.width, bgSize.height + add))
	self.background2:setPreferredSize(CCSizeMake(bgSize2.width, bgSize2.height + add))
	self.text:setPosition(ccp(txPos.x, txPos.y + add))
	self.background:setPosition(ccp(bgPos.x, bgPos.y + add))
	self.background2:setPosition(ccp(bgPos2.x, bgPos2.y + add))
	local size = self.ui:getGroupBounds().size
	position = position or {}
	if position.x then position.x = position.x + size.width / 2
	else position.x = vSize.width / 2 end
	position.x = position.x + 3
	if position.y then position.y = position.y - size.height / 2
	else position.y = -(vSize.height - size.height) / 2 - vOrigin.y - originSize.height / 3 end
	self:setPosition(ccp(position.x, position.y))
	self:setScale(0)
	self.noCallback = noCallback

	local function onScaled()
		if _G.isLocalDevelopMode then printx(0, "onScaled") end
		self.allowBackKeyTap = true
		local function onNo()
			self.orangeBtn:removeAllEventListeners()
			if self.noFadeOut then 
				self:removeSelf()
			else
				self:fadeOut()
			end
			if noCallback then noCallback() end
		end
		self.orangeBtn:ad(DisplayEvents.kTouchTap, onNo)
		local function onYes()
			self.greenBtn:removeAllEventListeners()
			if self.noFadeOut then 
				self:removeSelf()
			else
				self:fadeOut()
			end
			if yesCallback then yesCallback() end
		end
		self.greenBtn:ad(DisplayEvents.kTouchTap, onYes)

		if self.afterScaledCallback then
			self.afterScaledCallback()
		end
	end
	self:runAction(CCSequence:createWithTwoActions(CCEaseBackOut:create(CCScaleTo:create(0.2, 1)), CCCallFunc:create(onScaled)))

	return true
end

function CommonTipWithBtn:setAfterScaledCallback(afterScaledCallback)
	self.afterScaledCallback = afterScaledCallback
end

function CommonTipWithBtn:onCloseBtnTapped()
	if self.noCallback then self.noCallback() end
	self:fadeOut()
end


function CommonTipWithBtn:fadeOut()
	if _G.isLocalDevelopMode then printx(0, "CommonTipWithBtn:fadeOut") end

	showFreeFCash = false
	FreeFCashPanel:hideWithOwnerCheck(self)

	self.allowBackKeyTap = false
	local function doFade()
		self.background:runAction(CCFadeOut:create(0.2))
		self.background2:runAction(CCFadeOut:create(0.2))
		self.text:runAction(CCFadeOut:create(0.2))
		self.orangeBtn.groupNode:getChildByName("background"):runAction(CCFadeOut:create(0.2))
		self.greenBtn.groupNode:getChildByName("background"):runAction(CCFadeOut:create(0.2))
		self.orangeBtn.groupNode:getChildByName("_shadow"):runAction(CCFadeOut:create(0.2))
		self.greenBtn.groupNode:getChildByName("_shadow"):runAction(CCFadeOut:create(0.2))
		if self.anim1 then self.anim1:runAction(CCFadeOut:create(0.2)) end
		if self.anim2 then self.anim2:runAction(CCFadeOut:create(0.2)) end
	end
	self:stopAllActions()
	local fade = CCSpawn:createWithTwoActions(CCMoveBy:create(0.2, ccp(0, 100)), CCCallFunc:create(doFade))
	local function removeSelf() self:removeSelf() end
	self:runAction(CCSequence:createWithTwoActions(fade, CCCallFunc:create(removeSelf)))

end

function CommonTipWithBtn:removeSelf()
	-- self:removeFromParentAndCleanup(true)
	if self.isDisposed then return end
	PopoutManager:sharedInstance():remove(self)
end

function CommonTipWithBtn:onEnterHandler(event)
	-- 什么也不做，仅为了覆盖原方法
end