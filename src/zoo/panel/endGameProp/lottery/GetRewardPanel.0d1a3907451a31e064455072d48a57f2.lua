local layoutUtils =  require 'zoo.panel.happyCoinShop.utils'
local UIHelper = require 'zoo.panel.UIHelper'

local function positionNode( holder, icon, isUniformScale)

	if (not holder) or holder.isDisposed then return end
	if (not icon) or icon.isDisposed then return end


	local layoutUtils = require 'zoo.panel.happyCoinShop.utils'

	local parent = holder:getParent()

	if (not parent) or parent.isDisposed then return end



	local iconIndex = parent:getChildIndex(holder)
	parent:addChildAt(icon, iconIndex)

	local size = holder:getContentSize()
	local sx, sy = holder:getScaleX(), holder:getScaleY()

	local realSize = {
		width = sx * size.width,
		height = sy * size.height,
	}

	layoutUtils.scaleNodeToSize(icon, realSize, parent, isUniformScale)
	layoutUtils.verticalCenterAlignNodes({icon}, holder, parent)
	layoutUtils.horizontalCenterAlignNodes({icon}, holder, parent)

	holder:setVisible(false)



end


local function setRewardItem( ui, itemId, num )

	if (not ui) or ui.isDisposed then return end


	local iconHolder = ui:getChildByName('icon')
	local icon = ResourceManager:sharedInstance():buildItemSprite(itemId)
	positionNode(iconHolder, icon, true)

	local flagHolder = ui:getChildByName('flag')


	local flagSpriteFrameName

	if ItemType:isTimeProp(itemId) then
		flagSpriteFrameName = 'add.step.lottery/res/bag_time_limit_flag'
	elseif ItemType:inPreProp(itemId) then
		flagSpriteFrameName = 'add.step.lottery/res/bag_pre_prop_flag'
	elseif ItemType:inTimePreProp(itemId) then
		flagSpriteFrameName = 'add.step.lottery/res/bag_time_pre_prop_flag'
	end

	if flagSpriteFrameName then
		local flag = require('zoo.panel.UIHelper'):safeCreateSpriteByFrameName(flagSpriteFrameName .. '0000')
		positionNode(flagHolder, flag, true)
	end

	flagHolder:setVisible(false)
	iconHolder:setVisible(false)

	ui:getChildByName('num'):setVisible(false)
end



local GetRewardPanel = class(BasePanel)

function GetRewardPanel:create(rewardItem)
    local panel = GetRewardPanel.new()
    panel:init(rewardItem)
    return panel
end

function GetRewardPanel:init(rewardItem)
    local ui = UIHelper:createUI('ui/lottery.json', 'add.step.lottery/panel')
    UIUtils:adjustUI(ui, 222, nil, nil, 1724)
	BasePanel.init(self, ui)

	local function onTap( ... )
		if self.isDisposed then
    		return
    	end
		local LotteryServer = require 'zoo.panel.endGameProp.lottery.LotteryServer'
		if LotteryServer:isAddStep(rewardItem.itemId) then
			self:_close()
		else
			local bounds = self.reward:getGroupBounds()
			local function copyItems( tbl )
				local ret = {}
				for index, v in ipairs(tbl) do
					ret[index] = {itemId = v.itemId, num = v.num}
				end
				return ret
			end
			local items = copyItems({rewardItem})
			local anim = FlyItemsAnimation:create(items)
			anim:setWorldPosition(ccp(bounds:getMidX(),bounds:getMidY()))
			anim:play()
			self:_close()
		end
	end

    self.closeBtn = self.ui:getChildByName('closeBtn')
    self.closeBtn:setTouchEnabled(true, 0, true)
    self.closeBtn:ad(DisplayEvents.kTouchTap, onTap)

    self.btn = self.ui:getChildByName('btn')
    self.btn = 	GroupButtonBase:create(self.btn)
    self.btn:ad(DisplayEvents.kTouchTap, onTap)

    self.btn:setString(localize('确定'))

    self.label = self.ui:getChildByName('label')
    self.label:setString(localize('five.steps.lottery.reward.title'))

    self.reward = self.ui:getChildByName('reward')
	self.reward:setPositionY( self.reward:getPositionY() - 150)
    setRewardItem(self.reward, rewardItem.itemId, rewardItem.num)
    self.reward:setScale(1.3)

    local eff = CommonEffect:buildGetPropLightAnimWithoutBg()
	self.ui:addChildAt(eff, 0)
	eff:setPosition(ccp(self.reward:getPositionX(), self.reward:getPositionY()))
end

function GetRewardPanel:setCloseCallback( callback )
	self.closeCallback = callback
end

function GetRewardPanel:popoutShowTransition( ... )
	layoutUtils.setNodeRelativePos(self.closeBtn, layoutUtils.MarginType.kTOP, 5)
end

function GetRewardPanel:_close()
	self.allowBackKeyTap = false
	PopoutManager:sharedInstance():remove(self)
	if self.closeCallback then
		self.closeCallback()
	end
end

function GetRewardPanel:popout()
	PopoutManager:sharedInstance():add(self, true)
	self.allowBackKeyTap = true
	self:popoutShowTransition()

end

function GetRewardPanel:onCloseBtnTapped( ... )
    self.closeBtn:dispatchEvent(DisplayEvent.new(DisplayEvents.kTouchTap))
end

return GetRewardPanel
