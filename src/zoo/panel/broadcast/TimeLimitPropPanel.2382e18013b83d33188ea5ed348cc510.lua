require 'zoo.util.OpenUrlUtil'
require 'zoo.panel.broadcast.AutoClosePanel'
require "zoo.panel.WechatFriendPanel"
require "zoo.panel.ConsumeHistoryPanel"

local function is_valid_itemId( v )
	return table.exist(ItemType or {}, v.itemId)
end

local function version_filter( props )
	return table.filter(props, is_valid_itemId)
end

TimeLimitPropPanel = class(AutoClosePanel)

function TimeLimitPropPanel:create(afterClose)
	local instance = TimeLimitPropPanel.new()
	instance:loadRequiredResource(PanelConfigFiles.common_message)
	instance:init(afterClose)
	return instance
end

function TimeLimitPropPanel:init(afterClose)
	BasePanel.init(self, self:buildInterfaceGroup('broadcast/overTime'))

	self.afterClose = afterClose

	self.bg = self.ui:getChildByName('bg')
	self.text = self.ui:getChildByName('text')
	self.text:setPreferredSize(
		self.text:getPreferredSize().width,
		0
	)
	self.iconHolder = self.ui:getChildByName('placeHolder')
	self.iconHolder.size = self.iconHolder:getContentSize()

	self.item = self:getItemToShow()
	local itemId = self.item.itemId
	if ItemType:isTimeProp(itemId) then
		itemId = ItemType:getRealIdByTimePropId(itemId)
	end
	
	self.itemIcon = ResourceManager:sharedInstance():buildItemSprite(itemId)
	self.itemIcon.size = self.itemIcon:getContentSize()
	if _G.isLocalDevelopMode then printx(0, self.itemIcon.size.width, self.iconHolder.size.width) end
	self.itemIcon:setScale(self.iconHolder.size.width / self.itemIcon.size.width)

	self.itemIcon:setAnchorPoint(ccp(0.5, 0.5))
	local bounds = self.iconHolder:getGroupBounds(self.ui)
	self.itemIcon:setPosition(
		ccp(self.iconHolder.size.width/2, self.iconHolder.size.height/2)
	)

	self.iconHolder:addChild(self.itemIcon)
	self.iconHolder:setOpacity(0)

	-- self.num = self.ui:getChildByName('num')
	-- self.numRect = self.ui:getChildByName('numRect')
	-- self.num = TextField:createWithUIAdjustment(self.numRect, self.num)
	-- self.ui:addChild(self.num)
	-- self.num:setString('x'..tostring(self.item.num))

	self.text:setString(localize('broadcast.prop.limit.tip', {
		item = Localization:getInstance():getText("prop.name."..itemId)
	}))

	self.countText = self.ui:getChildByName('countText')
	self.rect = self.ui:getChildByName('rect')
	self.countText = TextField:createWithUIAdjustment(self.rect, self.countText)
	self.ui:addChild(self.countText)
	self.countText:setColor(ccc4(255, 255, 0, 255))

	local hour, min, sec = self:getRestTime(self.item)
	self.countText:setString(string.format('%s:%s:%s', hour, min, sec))

	self.timerId = nil
	self.timerId = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(function()
		if not self.isDisposed then
			sec = sec - 1
			if sec < 0 then
				sec = 59
				min = min - 1
			end
			if min < 0 then
				min = 59
				hour = hour - 1
			end
			if hour < 0 then
				hour = 0
				min = 0
				sec = 0
			end
			self.countText:setString(string.format('%s:%s:%s', hour, min, sec))
		end
	end, 1, false)


	-- 强行垂直居中文本
	self.text:setAnchorPoint(ccp(0, 1))
	self.text:setPositionY(- (self.bg:getPreferredSize().height - self.text:getContentSize().height)/2)

	self:enableAutoClose(function() self:closeRightNow() end)

end

function TimeLimitPropPanel:popout()
	AutoClosePanel.popout(self)
	self:setTodayShow()
end

function TimeLimitPropPanel:getPriority()
	return 2000
end

function TimeLimitPropPanel:loadIconByGoodsIdInfo(goodsIdInfo)
	local goodsId = getRealOriGoodsId(goodsIdInfo:getOriginalGoodsId())
	local goodsType = goodsIdInfo:getGoodsType()
	local iconBuilder = InterfaceBuilder:create(PanelConfigFiles.properties)
	FrameLoader:loadImageWithPlist("ui/BuyConfirmPanel.plist")

	local goodsName = self:getGoodsName(goodsIdInfo)
	local itemIcon = nil
	if goodsType == 2 then -- 购买金币
		itemIcon = iconBuilder:buildGroup("Prop_14")
	elseif goodsType == 1 then
		if string.find(goodsName, "新区域解锁") then
			itemIcon = Sprite:createWithSpriteFrameName("buy_confirm_panel/cells/unlockIcon0000")
			itemIcon:setAnchorPoint(ccp(0,1))
		elseif string.find(goodsName, "签到礼包") then
			itemIcon = Sprite:createWithSpriteFrameName("buy_confirm_panel/cells/checkinIcon0000")
			itemIcon:setAnchorPoint(ccp(0,1))
		else
			if string.find(goodsName, "加5步") then
				goodsId = 4
			elseif string.find(goodsName, "追踪导弹") then
				goodsId = 45
			end
			itemIcon = iconBuilder:buildGroup('Goods_'..goodsId)
		end
	end
	return itemIcon
end

function TimeLimitPropPanel:getNum(goodsIdInfo)
	local goodsId = getRealOriGoodsId(goodsIdInfo:getOriginalGoodsId())
	local goodsType = goodsIdInfo:getGoodsType()
	if goodsType == 1 then
		return 'x1'
	else
		local cashNum = WechatFriendLogic:getCashByGoodsId(tonumber(goodsId) + 10000)
		return 'x'..tostring(cashNum)
	end 
end


function TimeLimitPropPanel:isHaveItemToShow()
	local props = UserManager:getInstance():getAndUpdateTimeProps()
	props = version_filter(props)
	table.sort(props, function(a,b) return a.expireTime < b.expireTime end)
	if #props <= 0 then
		return false
	end
	local hour, min, sec = self:getRestTime(props[1])
	if hour >= 4 then
		return false
	end
	return true
end

function TimeLimitPropPanel:getItemToShow()
	local prioritys = {
		ItemType.TIMELIMIT_ADD_FIVE_STEP,
		ItemType.TIMELIMIT_HAMMER,
		ItemType.TIMELIMIT_48_HAMMER,
		ItemType.TIMELIMIT_INGAME_ROW_EFFECT,
		ItemType.TIMELIMIT_48_INGAME_ROW_EFFECT,
		ItemType.TIMELIMIT_INGAME_COLUMN_EFFECT,
		ItemType.TIMELIMIT_48_INGAME_COLUMN_EFFECT,
		ItemType.TIMELIMIT_BRUSH,
		ItemType.TIMELIMIT_48_BRUSH,
		ItemType.TIMELIMIT_SWAP,
		ItemType.TIMELIMIT_RANDOM_BIRD,
		ItemType.TIMELIMIT_BROOM,
		ItemType.TIMELIMIT_REFRESH,
		ItemType.TIMELIMIT_BACK,
		ItemType.TIMELIMIT_OCTOPUS_FORBID,
		ItemType.TIMELIMIT_ADD_THREE_STEP,
		ItemType.TIMELIMIT_INITIAL_2_SPECIAL_EFFECT,
		ItemType.TIMELIMIT_INGAME_PRE_REFRESH,
		ItemType.TIMELIMIT_48_BACK,
		ItemType.TIMELIMIT_48_INITIAL_2_SPECIAL_EFFECT
	}
	local props = UserManager:getInstance():getAndUpdateTimeProps()
	props = version_filter(props)
	table.sort(props, function(a,b) 
		if a.expireTime ~= b.expireTime then
			return a.expireTime < b.expireTime
		else
			return (table.indexOf(prioritys, a.itemId) or 0) < (table.indexOf(prioritys, b.itemId) or 0)
		end
	end)
	return props[1]
end

function TimeLimitPropPanel:getRestTime(item)
	local restTime = item.expireTime/1000 - Localhost:timeInSec()
	return math.floor(restTime/3600), math.floor(restTime%3600/60), math.floor(restTime%3600%60)
end

function TimeLimitPropPanel:isNeedShow(sceneType)

	if not Director:sharedDirector():getRunningSceneLua():is(HomeScene) then
		return false
	end


	if sceneType ~= 1 then return false end
	if not self:isHaveItemToShow() then return false end
	if self:isTodayHadShow() then return false end
	return true
end

function TimeLimitPropPanel:isTodayHadShow()
	local kLastShowDateKey = 'kLastShowDateKey'
	local lastDate = CCUserDefault:sharedUserDefault():getStringForKey(kLastShowDateKey)
	if lastDate == '' or lastDate == nil then return false end
	lastDate = tonumber(lastDate)
	local nowDate = Localhost:timeInSec()
	if nowDate - lastDate >= 24*60*60 then return false end
	return true
end

function TimeLimitPropPanel:setTodayShow()
	local kLastShowDateKey = 'kLastShowDateKey'
	local nowDate = Localhost:timeInSec()
	CCUserDefault:sharedUserDefault():setStringForKey(kLastShowDateKey, tostring(nowDate))
end

function TimeLimitPropPanel:close()
	if self.timerId then
		CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.timerId)
	end
	AutoClosePanel.close(self)
end