local layoutUtils = require 'zoo.panel.happyCoinShop.utils'

local PromotionQuickPayConfirmPanel_New = class(BasePanel)

function PromotionQuickPayConfirmPanel_New:create(giftItems, price, payType)
	local goldItem = table.filter(giftItems, function(item) return item.itemId == ItemType.GOLD end)
	local propItems = table.filter(giftItems, function(item) return item.itemId ~= ItemType.GOLD end)
	local cash = 0
	if #goldItem > 0 then
		cash = goldItem[1].num
	end

	local panel = PromotionQuickPayConfirmPanel_New.new()
	panel:loadRequiredResource("ui/ali_payment.json")
	panel:init(cash, propItems, price, payType)
	return panel
end

function PromotionQuickPayConfirmPanel_New:init(goldNum, propItems, price, payType)
	self.ui = self:buildInterfaceGroup("NewAliQuickPayconfirmPanel_1_45_B")
    BasePanel.init(self, self.ui)

    self.btnSave = GroupButtonBase:create(self.ui:getChildByName("btn"))
    self.btnSave:setString(Localization:getInstance():getText("确定"))
    self.btnSave:addEventListener(DisplayEvents.kTouchTap, function ()
        if self.confirmCallback then
            self.confirmCallback()
        end
        self:removeSelf()
    end)

    self.panelTitle = TextField:createWithUIAdjustment(self.ui:getChildByName("panelTitleSize"), self.ui:getChildByName("panelTitle"))
    self.ui:addChild(self.panelTitle)

    if payType == Payments.WECHAT then
    	self.panelTitle:setString(Localization:getInstance():getText("wechat.kf.pay2.wc"))
    else
    	self.panelTitle:setString(Localization:getInstance():getText("alipay.pay.kf.confirm1"))
    end

    self.closeBtn = self.ui:getChildByName("closeBtn")
    self.closeBtn:setTouchEnabled(true, 0, true)
    self.closeBtn:setButtonMode(true)
    self.closeBtn:addEventListener(DisplayEvents.kTouchTap, 
        function() 
            self:onCloseBtnTapped()
        end)

    local price = string.format("%.2f", price)

    if payType == Payments.WECHAT then
    	self.ui:getChildByName("label"):setString(localize("wechat.kf.pay2.text")..":¥"..price)
    else
    	self.ui:getChildByName("label"):setString(localize("alipay.pay.kf.confirm")..":¥"..price)
    end


    self:initItems(goldNum, propItems)
end

function PromotionQuickPayConfirmPanel_New:initItems( goldNum, props )

	local container = self.ui:getChildByName('prop')

	local items = {}

	local goldItem = container:getChildByName('gold')
	goldItem:getChildByName('cash'):setText(tostring(goldNum))
	goldItem:getChildByName('cash'):setScale(0.7)

	local marginX = 10

	if #props + 1 < 4 then
		marginX = 15
	end

	table.insert(items, {
		node = goldItem,
		margin = {
			right = marginX,
			left = marginX
		}
	})

	local propItems = {}
	for i = 1, 3 do 
		propItems[i] = container:getChildByName('prop_'..tostring(i))
	end

	local propsNum = #props

	for i = 1, 3 do
		if i > propsNum then
			propItems[i]:removeFromParentAndCleanup(true)
		else
			local propItem = propItems[i]
			self:setPropItem(propItem, props[i])


			table.insert(items, {
				node = propItem,
				margin = {
					right = marginX,
					left = marginX
				}
			})

		end
	end


	layoutUtils.horizontalLayoutItems(items)
	layoutUtils.verticalCenterAlignNodes({container}, self.ui:getChildByName('bg'))
	container:setPositionX(container:getPositionX() - 9)
end



function PromotionQuickPayConfirmPanel_New:popout(confirmCallback, cancelCallback)
    self:setPositionForPopoutManager()
    self.confirmCallback = confirmCallback
    self.cancelCallback = cancelCallback
    PopoutManager:sharedInstance():add(self, true, false)
end

function PromotionQuickPayConfirmPanel_New:removeSelf()
    PopoutManager:sharedInstance():remove(self, true)
end

function PromotionQuickPayConfirmPanel_New:onCloseBtnTapped()
    self:removeSelf()
    if self.cancelCallback then
        self.cancelCallback()
    end
end




function PromotionQuickPayConfirmPanel_New:setPropItem( itemUI, propItem )


	local holder = itemUI:getChildByName('holder')
	holder:setVisible(false)
	holder:setAnchorPointCenterWhileStayOrigianlPosition()
	local holderPos = holder:getPosition()
	holderPos = ccp(holderPos.x, holderPos.y)
	local holderIndex = itemUI:getChildIndex(holder)

	local numUI = itemUI:getChildByName('num')

	local sp = ResourceManager:sharedInstance():buildItemSprite(propItem.itemId)
	sp:setAnchorPoint(ccp(0.5, 0.5))
	sp:setPosition(holderPos)

	-- if propItem.itemId == 10005 or propItem.itemId == 10010 then
		-- sp:setAnchorPoint(ccp(0.35, 0.62))
	-- end

	local targetWidth = holder:getContentSize().width * holder:getScaleX()
	local spWidth = sp:getContentSize().width
	sp:setScale(targetWidth/spWidth*1.1)

	numUI:changeFntFile('fnt/skip_level.fnt')
	numUI:setText('x'..tostring(propItem.num))
	numUI:setScale(0.8)
	itemUI:addChildAt(sp, holderIndex)


end

return PromotionQuickPayConfirmPanel_New