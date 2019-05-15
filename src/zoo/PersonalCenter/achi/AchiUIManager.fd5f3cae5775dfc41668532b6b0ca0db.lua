local AchiIcon  = require "zoo.PersonalCenter.achi.panel.AchiIcon"
local AchiCenterScene  = require "zoo.PersonalCenter.achi.panel.AchiCenterScene"

AchiUIManager = class()
local newAchis = {}
function AchiUIManager:isOpen()
	if PlatformConfig:isPlayDemo() then return false end
	-- printx(5, 'AchiUIManager:isOpen()', Achievement:isNetworkTrigger())
	if UserManager:getInstance().user:getTopLevelId() >= 60 and Achievement:isNetworkTrigger() then return true end
	return false
end

function AchiUIManager:setNewAchis(achis)
	newAchis = table.union(newAchis, achis)
end

function AchiUIManager:getNewAchis()
	return newAchis
end

function AchiUIManager:removeNewAchi(id)
	newAchis = table.removeValue(newAchis, id)
	if table.size(newAchis) == 0 then
		local scene = HomeScene:sharedInstance()
		if scene and scene.achiBtn then
			scene.achiBtn:stopAnimation()
		end
	end
end

function AchiUIManager:createHomeIcon()
	if not self:isOpen() then return end

	local scene = HomeScene:sharedInstance()
	if scene and not scene.achiBtn then
		local achiIcon = AchiIcon:create(self:hasGuide())
		scene:addIcon(achiIcon)
		scene.achiBtn = achiIcon
	end
end

function AchiUIManager:openMainPanel(tabIndex, showGuide)
	-- PopoutQueue:sharedInstance():removeAllInNextLevelModel(200)
	AchiCenterScene:createAchiPanel(tabIndex, showGuide)
end

function AchiUIManager:onEnterGame()
	self:createHomeIcon()
	--self:popGuide()
end

function AchiUIManager:hasGuide()
	if self:isOpen() then
		if UserManager:getInstance():hasGuideFlag(kGuideFlags.ACHIEVE) then
			return false
		end
		return true
	end
	return false
end

function AchiUIManager:createSkipButton(skipText, onTouch)
	local layer = LayerColor:create()
	layer:setOpacity(0)
	layer:changeWidthAndHeight(200, 80)
	layer:ignoreAnchorPointForPosition(false)
	-- layer:setPosition(ccp(0, vOrigin.y + vSize.height - 50))
	layer:setTouchEnabled(true, 0, true)
	layer:ad(DisplayEvents.kTouchTap, onTouch)
	layer:setOpacity(0)
	layer:setAnchorPoint(ccp(0, 0))
	layer:setColor(ccc3(136, 255, 136))


	local text = TextField:create(skipText, nil, 32)
	text:setPosition(ccp(50, 25))
	text:setColor(ccc3(136, 255, 136))
	text:setOpacity(0)
	text:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(0), CCFadeIn:create(0)))
	text:setAnchorPoint(ccp(0, 0))
	layer:addChild(text)

	return layer
end

function AchiUIManager:showGuide2(ui, callback)
	if ui.isDisposed then return end
	local action = {opacity = 0xCC, touchDelay = 1, panelName = 'guide_dialogue_achievement_2', panDelay = 0}
	local playUI = Director:sharedDirector():getRunningScene()
	local layer = LayerColor:create()
	local pos = ui.tabbar.tabbar:getPosition()
	pos = ui:convertToWorldSpace(ccp(pos.x + 4, pos.y - 231))
	local trueMask = GameGuideUI:mask(action.opacity, action.touchDelay, pos, false, true, 600, 147, false, false)
	trueMask:setTouchEnabled(true, 0, true)
	trueMask:ad(DisplayEvents.kTouchTap, function ( ... )
		layer:removeFromParentAndCleanup(true) 
		if callback then callback() end
	end)

	local panel = GameGuideUI:panelS(nil, action, true)
	panel:setPosition(ccp(pos.x + 330, pos.y + 180))

	local hand = GameGuideAnims:handclickAnim(0, 0)
	hand:setPosition(ccp(pos.x + 490, pos.y + 65))

	local skipBtn = self:createSkipButton('跳过', function ( ... )
		ui.showGuide = false
		layer:removeFromParentAndCleanup(true) 
    end)

	if layer then
		layer:addChild(trueMask)
		layer:addChild(panel)
		layer:addChild(hand)
		layer:addChild(skipBtn)
		ui:addChild(layer)

		local layoutUtils =  require 'zoo.panel.happyCoinShop.utils'
		layoutUtils.setNodeRelativePos(skipBtn, layoutUtils.MarginType.kLEFT, -35)
		layoutUtils.setNodeRelativePos(skipBtn, layoutUtils.MarginType.kTOP,  -10)
	end 
end

function AchiUIManager:showGuide2_2(ui, callback)
	if ui.isDisposed then return end
	local action = {opacity = 0xCC, touchDelay = 1, panelName = 'guide_dialogue_achievement_2_2', panDelay = 0}
	local playUI = Director:sharedDirector():getRunningScene()
	local layer = LayerColor:create()
	local pos = ui.tabbar.tabbar:getPosition()
	pos = ui:convertToWorldSpace(ccp(pos.x + 4, pos.y - 231))
	local trueMask = GameGuideUI:mask(action.opacity, action.touchDelay, pos, false, true, 600, 147, false, false)
	trueMask:setTouchEnabled(true, 0, true)
	trueMask:ad(DisplayEvents.kTouchTap, function ( ... )
		layer:removeFromParentAndCleanup(true) 
		if callback then callback() end
	end)

	local panel = GameGuideUI:panelS(nil, action, true)
	panel:setPosition(ccp(pos.x + 330, pos.y + 180))

	local skipBtn = self:createSkipButton('跳过', function ( ... )
		ui.showGuide = false
		layer:removeFromParentAndCleanup(true) 
    end)

	if layer then
		layer:addChild(trueMask)
		layer:addChild(panel)
		layer:addChild(skipBtn)
		ui:addChild(layer)

		local layoutUtils =  require 'zoo.panel.happyCoinShop.utils'
		layoutUtils.setNodeRelativePos(skipBtn, layoutUtils.MarginType.kLEFT, -35)
		layoutUtils.setNodeRelativePos(skipBtn, layoutUtils.MarginType.kTOP,  -10)
	end 
end

function AchiUIManager:showGuide3(ui, callback)
	if ui.isDisposed then return end
	local action = {opacity = 0xCC, touchDelay = 1, panelName = 'guide_dialogue_achievement_3', panDelay = 0}
	local playUI = Director:sharedDirector():getRunningScene()
	local layer = LayerColor:create()
	local pos = ui.user:getPosition()
	pos = ui:convertToWorldSpace(ccp(pos.x, pos.y - 146))
	local trueMask = GameGuideUI:mask(action.opacity, action.touchDelay, pos, false, true, 640, 150, false, false)
	-- trueMask:setPositionY(-vs.height)
	-- trueMask:setFadeIn(0.5, 0.3)
	trueMask:setTouchEnabled(true, 0, true)
	trueMask:ad(DisplayEvents.kTouchTap, function ( ... )
		layer:removeFromParentAndCleanup(true) 
		if callback then callback() end
	end)

	local panel = GameGuideUI:panelS(nil, action, true)
	panel:setPosition(ccp(pos.x + 600, pos.y))
	local help = Sprite:createWithSpriteFrameName('achievement/help0000')
	help:setPosition(ccp(-255, -202))
	panel:addChild(help)

	local skipBtn = self:createSkipButton('跳过', function ( ... )
		ui.showGuide = false
		layer:removeFromParentAndCleanup(true) 
    end)

	if layer then
		layer:addChild(trueMask)
		layer:addChild(panel)
		layer:addChild(skipBtn)
		ui:addChild(layer)

		local layoutUtils =  require 'zoo.panel.happyCoinShop.utils'
		layoutUtils.setNodeRelativePos(skipBtn, layoutUtils.MarginType.kLEFT, -35)
		layoutUtils.setNodeRelativePos(skipBtn, layoutUtils.MarginType.kTOP,  -10)
	end 
end