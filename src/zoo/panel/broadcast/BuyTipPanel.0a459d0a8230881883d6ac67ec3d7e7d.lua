require 'zoo.util.OpenUrlUtil'
require 'zoo.panel.broadcast.AutoClosePanel'
require "zoo.panel.WechatFriendPanel"
require "zoo.panel.ConsumeHistoryPanel"

local function getRealOriGoodsId(oriGoodsId)
	local realOriGoodsId = oriGoodsId 
	if oriGoodsId == 33 then --这里是加五步面板打折道具的特殊处理 打折道具的名字这里不可以带打折。产品需求。
		realOriGoodsId = 24
	elseif oriGoodsId == 47 then 
		realOriGoodsId = 46
	elseif oriGoodsId == 148 then 
		realOriGoodsId = 147
	end

	return realOriGoodsId
end


BuyTipPanel = class(AutoClosePanel)

function BuyTipPanel:create(goodsIdInfo, props, afterClose)
	local instance = BuyTipPanel.new()
	instance:loadRequiredResource(PanelConfigFiles.common_message)
	instance:init(goodsIdInfo, props, afterClose)
	return instance
end

function BuyTipPanel:init(goodsIdInfo, props, afterClose)
	BasePanel.init(self, self:buildInterfaceGroup('broadcast/rmb'))
	self.afterClose = afterClose

	self.bg = self.ui:getChildByName('bg')
	self.text = self.ui:getChildByName('text')
	self.link = self.ui:getChildByName('link')
	self.iconHolder = self.ui:getChildByName('iconHolder')
	self.iconHolder.size = self.iconHolder:getContentSize()

	local itemNum
	self.itemIcon, itemNum = self:loadIconByGoodsIdInfo(goodsIdInfo)
	self.iconHolder:addChild(self.itemIcon)
	self.iconHolder:setOpacity(0)

	local size = self.itemIcon:getGroupBounds(self.iconHolder).size
	self.itemIcon:setScale((3 + self.iconHolder.size.width) / size.width)
	self.itemIcon:setPositionX(0)
	self.itemIcon:setPositionY(0)

	self.itemIcon.size = self.itemIcon:getGroupBounds(self.iconHolder).size
	local dx = (self.itemIcon.size.width - self.iconHolder.size.width)/2
	local dy = (self.itemIcon.size.height - self.iconHolder.size.height)/2
	self.itemIcon.origin = self.itemIcon:getGroupBounds(self.iconHolder).origin
	self.itemIcon:setPosition(ccp(
		self.itemIcon:getPositionX() - self.itemIcon.origin.x - dx,
		self.itemIcon:getPositionY() - self.itemIcon.origin.y - dy
	))

	self.num = self.ui:getChildByName('num')
	self.numRect = self.ui:getChildByName('numRect')
	self.num = TextField:createWithUIAdjustment(self.numRect, self.num)
	self.ui:addChild(self.num)
	-- self.num:setString(self:getNum(goodsIdInfo))
	self:setNumberDisplay(goodsIdInfo, itemNum)

	local goodsId = getRealOriGoodsId(goodsIdInfo:getOriginalGoodsId())
	self.text:setString(localize('consume.tip.panel.text.1', {
		n = props
	}))

	self.link:setDimensions(CCSizeMake(0, 0))
	self.link:setString('人民币支付记录')
	local underLine = LayerColor:createWithColor(
		ccc4(0x36, 0x9e, 0x1a), 
		self.link:getContentSize().width,
		2
	)
	-- underLine:ignoreAnchorPointForPosition(false)
	-- underLine:setAnchorPoint(ccp(0, 1))
	self.link:addChild(underLine)
	self.link:setPositionX(self.link:getPositionX() - 24)

	local linkInput = Layer:create()
	self.link:removeFromParentAndCleanup(false)
	linkInput:setPosition(ccp(self.link:getPositionX(), self.link:getPositionY()))
	self.link:setPosition(ccp(0, 0))
	self.ui:addChild(linkInput)
	linkInput:addChild(self.link)
	linkInput:setTouchEnabled(true)
	linkInput:addEventListener(DisplayEvents.kTouchBegin,function()
		ConsumeHistoryPanel:create():popout()
	end, self)

	self:enableAutoClose(function() self:closeRightNow() end)

	self.text:setPositionY(self.text:getPositionY() + 2)
	self.link:setPositionY(self.link:getPositionY() + 3)
end



function BuyTipPanel:getPriority()
	return 1000
end





local function getGoodsNameById(goodsId)
	local key = "goods.name.text"..tostring(goodsId)
	local goodsName = Localization.getInstance():getText(key)
	if key == goodsName then
		goodsName = "goodsId_"..tostring(goodsId)
	end
	return goodsName
end

function BuyTipPanel:getGoodsName(goodsIdInfo)
	local goodsId = getRealOriGoodsId(goodsIdInfo:getOriginalGoodsId())
	local goodsType = goodsIdInfo:getGoodsType()
	if goodsType == 2 then 
		return '风车币' 
	else
		return getGoodsNameById(goodsId)
	end
end

function BuyTipPanel:loadIconByGoodsIdInfo(goodsIdInfo)
	local goodsId = getRealOriGoodsId(goodsIdInfo:getOriginalGoodsId())
	local goodsType = goodsIdInfo:getGoodsType()
	local iconBuilder = InterfaceBuilder:create(PanelConfigFiles.properties)
	FrameLoader:loadImageWithPlist("ui/BuyConfirmPanel.plist")

	local goodsMeta = MetaManager.getInstance():getGoodMeta(goodsId)
	local goodsItems = goodsMeta.items or {}

	local goodsName = self:getGoodsName(goodsIdInfo)
	local itemIcon = nil
	local itemNum = nil
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
			if table.size(goodsItems) == 1 then
				pcall(function ( ... )
					itemIcon = ResourceManager:sharedInstance():buildItemSprite(goodsItems[1].itemId)
				end)
				if itemIcon then
					itemNum = goodsItems[1].num
				end
			end

			if not itemIcon then
				if string.find(goodsName, "加5步") then
					goodsId = 4
				elseif string.find(goodsName, "追踪导弹") then
					goodsId = 45
				end

				-- IOS 的goodsid 没有对应Icon 强行转换一下

				if goodsId == 159 then
					goodsId = 17
				elseif goodsId == 160 then
					goodsId = 24
				elseif goodsId == 161 then
					goodsId = 150
				elseif goodsId >= 213 and goodsId <= 240 then
					goodsId = 251
				elseif goodsId == 356 then
					goodsId = 294
				elseif goodsId == 355 then
					goodsId = 295
				elseif goodsId == 371 then
					goodsId = 362
				elseif goodsId == 370 then
					goodsId = 362
				elseif goodsId == 369 then
					goodsId = 362
				elseif goodsId == 478 then
					goodsId = 362
				elseif goodsId == 278 then
					goodsId = 4
				elseif goodsId == 493 then
					goodsId = 362
				elseif goodsId == 494 then
					goodsId = 362
				elseif goodsId >= 497 and goodsId <= 502 then
					goodsId = 294
				end

				if goodsId >= 513 and goodsId <= 536 then
					goodsId = 362
				end

				if goodsId >= 559 and goodsId <= 566 then
					goodsId = 362
				end

				if goodsId == 614 then
					goodsId = 484
				elseif goodsId == 615 then
					goodsId = 510
				end


				if goodsId >= 668 and goodsId <= 671 then
					goodsId = 640
				end

				itemIcon = iconBuilder:buildGroup('Goods_'..goodsId)
				if not itemIcon then
					itemIcon = Sprite:createEmpty()
				end
			end
		end
	end
	return itemIcon, itemNum
end

-- function BuyTipPanel:getNum(goodsIdInfo)
-- 	local goodsId = getRealOriGoodsId(goodsIdInfo:getOriginalGoodsId())
-- 	local goodsType = goodsIdInfo:getGoodsType()
-- 	if goodsType == 1 then
-- 		return 'x1'
-- 	else
-- 		local cashNum = self:getCashByGoodsId(tonumber(goodsId) + 10000)
-- 		return 'x'..tostring(cashNum)
-- 	end 
-- end

-- 因为可能购买的是有多个该物品的礼包，所以获得物品时不显示“x几”了
function BuyTipPanel:setNumberDisplay(goodsIdInfo, itemNum)
	local goodsId = getRealOriGoodsId(goodsIdInfo:getOriginalGoodsId())
	local goodsType = goodsIdInfo:getGoodsType()
	if goodsType == 1 then
		if itemNum then
			local numDisplay = 'x'..tostring(itemNum)
			self.num:setString(numDisplay)
			self.num:setVisible(true)
		else
			self.num:setVisible(false)
		end
	else
		local cashNum = self:getCashByGoodsId(tonumber(goodsId) + 10000)
		local numDisplay = 'x'..tostring(cashNum)
		self.num:setString(numDisplay)
		self.num:setVisible(true)
	end
end

function BuyTipPanel:getCashByGoodsId(goodsId)
	if __ANDROID then
		return self:getCashByGoodsId_Android(goodsId)
	else
		return self:getCashByGoodsId_IOS(goodsId)
	end
end

function BuyTipPanel:getCashByGoodsId_Android(goodsId)
	return WechatFriendLogic:getCashByGoodsId(goodsId)
end

function BuyTipPanel:getCashByGoodsId_IOS(goodsId)
	local goldItemIndex = tonumber(goodsId) - 10000  
	local metaConfig = MetaManager:getInstance().product
	local cash = 0
	if metaConfig and metaConfig[goldItemIndex] then
		cash = metaConfig[goldItemIndex].cash
	end
	return cash
end

function BuyTipPanel:isCareGuide()
    return false
end

function BuyTipPanel:isCarePanel()
    return false
end

function BuyTipPanel:isCareHomeQueue()
	return false
end