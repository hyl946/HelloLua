--[[
 * StarBankIcon
 * @date    2017-11-30 17:02:21
 * @authors zhou.ding
 * @email 	zhou.ding@happyelements.com
--]]

require "zoo.scenes.component.HomeScene.iconButtons.IconButtonBase"


StarBankIcon = class(IconButtonBase)

function StarBankIcon:create()
    local instance = StarBankIcon.new()
    instance:init()
    instance:initShowHideConfig(ManagedIconBtns.STAR_BANK)
    return instance
end

function StarBankIcon:init()
	self.ui = ResourceManager:sharedInstance():buildGroup('home_scene_icon/btns/btn_i_star_bank')
    IconButtonBase.init(self, self.ui)

	self.iconNotFull = self.wrapper:getChildByName("icon1")
	self.iconFull = self.wrapper:getChildByName("icon2")

	local flagUI = self.ui:getChildByName("flag")
	self.full = flagUI:getChildByName("full_label")
	self.wm = flagUI:getChildByName("gold_icon")
    self.wmNum = TextField:createWithUIAdjustment(flagUI:getChildByName("numph"), flagUI:getChildByName("num"))
    flagUI:addChild(self.wmNum)

    Notify:register("StarBankUpdateStateEvent", self.updateState, self)
	self:updateState()

    self.wrapper:addEventListener(DisplayEvents.kTouchTap, function()
    	Notify:dispatch("QuitNextLevelModeEvent")
		StarBank:showPanel(2)
	end)
end

local colors = {
	"blue",
	"green",
	"orange",
	"purple",
	"gold",
}

function StarBankIcon:updateState()
	if self.isDisposed then return end
	--[[
	1）风车币未攒满，显示当前收集的风车币数量，icon显示名称：星星储蓄罐。
	2）风车币已攒满，显示标签气泡为“已满”，icon显示倒计时。倒计时格式为“小时：分钟：秒”
	--]]
	local isFull = StarBank.state == StarBankState.kFullCanBuy
	self:setOriLabelVisible(not isFull)
	if isFull then 
		local now = Localhost:timeInSec()
		local t = StarBank.buyDeadline - now
		local left = t / 86400
		if left > 3.0 then
			self:setCustomizedLabel("")
			self:setOriLabelVisible(true)
		elseif left > 1.0 then
			self:setOriLabelVisible(false)
			self:setCustomizedLabel(string.format("还剩%d天", math.ceil(left)))
		else
			self:startCountdown(StarBank.buyDeadline)
		end
	else
		self.wmNum:setString(tostring(StarBank.curWm))
	end

	self.iconFull:setVisible(isFull)
	self.iconNotFull:setVisible(not isFull)
	self.full:setVisible(isFull)
	self.wm:setVisible(not isFull)
	self.wmNum:setVisible(not isFull)

	local config = StarBank:getConfig()
	if not config then
		config = {}
	end

	for _,c in ipairs(colors) do
		self.wrapper:getChildByName(c):setVisible(c == config.color)
	end
end

function StarBankIcon:_updateState()
	if self.isDisposed then return end
	--[[
	1）风车币未攒满，显示当前收集的风车币数量，icon显示名称：星星储蓄罐。
	2）风车币已攒满，显示标签气泡为“已满”，icon显示倒计时。倒计时格式为“小时：分钟：秒”
	--]]
	local isFull = StarBank.state == StarBankState.kFullCanBuy

	if isFull then
		local now = Localhost:timeInSec()
		local t = StarBank.buyDeadline - now
		local left = t / 86400
		if left > 1.0 then
			self.timeTxt:setString(string.format("还剩%d天", math.ceil(left)))
			self.timeTxt:setScale(0.98)
			self.timeTxt:setPositionX(self.timeTxt:getPositionX() + 5)
		else
			self.timeTxt:setScale(1)
			self.timeTxt:setString(convertSecondToHHMMSSFormat(t))
		end
		self.paomax:setVisible(false)
		self.paomin:setVisible(true)
	else
		--show wm
		local wm = StarBank.curWm
		self.wmNum:setString(tostring(wm))
		self.paomax:setVisible(wm > 99)
		self.paomin:setVisible(wm <= 99)
	end

	self.wrapper:getChildByName("full"):setVisible(isFull)
	self.wrapper:getChildByName("notfull"):setVisible(not isFull)
	self.full:setVisible(isFull)
	self.timeTxt:setVisible(isFull)
	self.txt:setVisible(not isFull)
	self.wm:setVisible(not isFull)
	self.wmNum:setVisible(not isFull)

	local config = StarBank:getConfig()
	if not config then
		config = {}
	end

	for _,c in ipairs(colors) do
		self.wrapper:getChildByName(c):setVisible(c == config.color)
	end
end

function StarBankIcon:dispose()
	Notify:unregister("StarBankUpdateStateEvent", self)
    IconButtonBase.dispose(self)
end