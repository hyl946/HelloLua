NumTipType = {
	GREEN = 1,
	ORANGE = 2,
	RED = 3
}

local UIHelper = require 'zoo.panel.UIHelper'

NumTip = class(BaseUI)

local NUM_RES_WIDTH = 12

function NumTip:create(tipType)
	local tip = NumTip.new()
	tip:init(tipType)
	return tip
end

function NumTip:init(tipType)
	local ui
	if tipType == NumTipType.GREEN then
		ui = ResourceManager:sharedInstance():buildGroup("numTip/greeNumTip")
		self.numResPath = "numTip/numTipRes/g"
	elseif tipType == NumTipType.ORANGE then
		ui = ResourceManager:sharedInstance():buildGroup("numTip/orangeNumTip")
		self.numResPath = "numTip/numTipRes/o"
	else
		tipType = NumTipType.RED
		ui = ResourceManager:sharedInstance():buildGroup("numTip/redNumTip")
		self.numResPath = "numTip/numTipRes/r"
	end
	self.tipType = tipType


	ui = UIHelper:replaceLayer2LayerColor(ui)

	BaseUI.init(self, ui)

	self.bg1 = ui:getChildByName("bg1")
	self.bg2 = ui:getChildByName("bg2")

	self.numContainer = Sprite:createEmpty() --播点点动画
	self.numContainer:setTexture(self.bg1:getTexture())
	self.ui:addChild(self.numContainer)
	self:setNum(0)

	UIHelper:setCascadeOpacityEnabled(ui)
	
end

function NumTip:getTipBg()
	if self.bg2:isVisible() then
		return self.bg2
	end

	return self.bg1
end

function NumTip:getShowNum()
	return self.num
end

function NumTip:getNumUI()
	return self.numContainer
end

function NumTip:setNum(num)

	if self.isDisposed then return end
	self.ui:setVisible(num > 0)
    self:setVisible(num > 0)

	self.bg1:setVisible(false)
	self.bg2:setVisible(false)
	self.numContainer:removeChildren(true)
	self.num = num

	if num > 99 then
		self.bg2:setVisible(true)
		local num9Res = Sprite:createWithSpriteFrameName(self.numResPath .. "90000")
		local num9Res_ = Sprite:createWithSpriteFrameName(self.numResPath .. "90000")
		local numAddRes = Sprite:createWithSpriteFrameName(self.numResPath .. "add0000")
		num9Res:setAnchorPoint(ccp(0.4, 0.57))
		num9Res:setPositionX(-NUM_RES_WIDTH - 2)
		num9Res_:setAnchorPoint(ccp(0.4, 0.57))
		num9Res_:setPositionX(0)
		numAddRes:setAnchorPoint(ccp(0.4, 0.61))
		numAddRes:setPositionX(NUM_RES_WIDTH + 2)
		self.numContainer:addChild(num9Res)
		self.numContainer:addChild(num9Res_)
		self.numContainer:addChild(numAddRes)
	elseif num > 0 then
		self.bg1:setVisible(true)
		if num > 9 then
			local num1 = math.floor(num / 10)
			local num2 = math.floor(num % 10)
			local num1Res = Sprite:createWithSpriteFrameName(self.numResPath .. num1 .. "0000")
			local num2Res = Sprite:createWithSpriteFrameName(self.numResPath .. num2 .. "0000")
			num1Res:setAnchorPoint(ccp(0.4, 0.57))
			num2Res:setAnchorPoint(ccp(0.4, 0.57))
			num1Res:setPositionX(-NUM_RES_WIDTH / 2 - 1)
			num2Res:setPositionX(NUM_RES_WIDTH / 2 - 1)
			self.numContainer:addChild(num1Res)
			self.numContainer:addChild(num2Res)
		else
			num = math.floor(num)
			local numRes = Sprite:createWithSpriteFrameName(self.numResPath .. num .. "0000")
			numRes:setAnchorPoint(ccp(0.4, 0.57))
			numRes:setPositionX(-1)
			self.numContainer:addChild(numRes)
		end
	end
end

function getNumTip(numTipType)
	return NumTip:create(numTipType)
end

function getGreenNumTip()
	return getNumTip(NumTipType.GREEN)
end

function getOrangeNumTip()
	return getNumTip(NumTipType.ORANGE)
end

function getRedNumTip()
	return getNumTip(NumTipType.RED)
end

function getRedDot()
	local atlasBtnRedDot = Sprite:createWithSpriteFrameName("accountTipDot__uk__3" .. "0000")
	atlasBtnRedDot:setScale(0.8)
	return atlasBtnRedDot
end

function getRedDotReward()
	local atlasBtnRedDot = Sprite:createWithSpriteFrameName("gameMisc_reward/reward" .. "0000")
	atlasBtnRedDot:setScale(1)
	return atlasBtnRedDot
end

