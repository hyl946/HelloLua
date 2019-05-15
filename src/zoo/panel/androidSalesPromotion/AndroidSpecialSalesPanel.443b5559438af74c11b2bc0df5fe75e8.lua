require 'zoo.panel.androidSalesPromotion.AndroidSalesBasePanel'

AndroidSpecialSalesPanel = class(AndroidSalesBasePanel)

local coinShowConfig = {{posX = 135, posY = -355, delayTime = 1.3, scale = 1, rotation = 0}}
local itemShowConfig = {{posX = 400, posY = -375, delayTime = 1.5, scale = 1, rotation = 0}}

function AndroidSpecialSalesPanel:ctor()
	
end

function AndroidSpecialSalesPanel:init()
	self.ui	= self:buildInterfaceGroup("AndroidSpecialSalesPanel")
	AndroidSalesBasePanel.init(self, self.ui)

	self.panelTitle:setString(Localization:getInstance():getText("ios.special.offer.title2"))

	self.cloudUI = self.ui:getChildByName("cloud")
	local childIndex = self.ui:getChildIndex(self.cloudUI)
	self.cloudUI:setVisible(false)

	FrameLoader:loadArmature('skeleton/ios_promotion_special', 'ios_promotion_special', 'ios_promotion_special')
    local anim = ArmatureNode:create('ios_promotion_special')
    anim:playByIndex(0,1)
    anim:setPosition(ccp(-26.5, 13))
    self.ui:addChild(anim)

    self.coinTable, self.itemTable = AndroidSalesManager:seperateItemTable(self.data.items)
    if #self.coinTable == 0 or self.itemTable == 0 then 
    	return false
    end
   	
   	self:setButtonDelayEnable(1)

	self.coinShowConfig = coinShowConfig
	self.itemShowConfig = itemShowConfig

   	self:showCloud()
    self:showRewards()
    return true
end

function AndroidSpecialSalesPanel:showCloud()
	self.cloudUI:setVisible(true)
	local cloudBg = self.cloudUI:getChildByName("bg")
	cloudBg:setVisible(false)
	cloudBg:setAnchorPointWhileStayOriginalPosition(ccp(0.5, 0.5))
	local dot1 = self.cloudUI:getChildByName("dot1")
	dot1:setVisible(false)
	local dot2 = self.cloudUI:getChildByName("dot2")
	dot2:setVisible(false)
	local add = self.cloudUI:getChildByName("add")
	add:setVisible(false)
	add:setAnchorPointWhileStayOriginalPosition(ccp(0.5, 0.5))

	dot1:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(0.8), CCShow:create()))
	dot2:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(1), CCShow:create()))
	local arr1 = CCArray:create()
	arr1:addObject(CCDelayTime:create(1.1))
	arr1:addObject(CCShow:create())
	arr1:addObject(CCScaleTo:create(1/12, 1.2, 1))
	arr1:addObject(CCScaleTo:create(1/12, 1))
	cloudBg:runAction(CCSequence:create(arr1))

	local arr2 = CCArray:create()
	arr2:addObject(CCDelayTime:create(1.4))
	arr2:addObject(CCShow:create())
	arr2:addObject(CCScaleTo:create(1/12, 1.4))
	arr2:addObject(CCScaleTo:create(1/12, 0.8))
	arr2:addObject(CCScaleTo:create(1/12, 1))
	add:runAction(CCSequence:create(arr2))
end

function AndroidSpecialSalesPanel:showRewards()
	for i,v in ipairs(self.coinTable) do
		local showConfig = self.coinShowConfig[i]
		if showConfig then 
			local coin = IosSalesItemCoin:create(v.num, showConfig.delayTime)
			self:pushSingleReward(coin:getIcon(), ItemType.GOLD, v.num)
			coin:setScale(showConfig.scale)
			coin:setRotation(showConfig.rotation)
			self:addChild(coin)
			coin:setPosition(ccp(showConfig.posX, showConfig.posY))
			coin:play()
		end
	end

	for i,v in ipairs(self.itemTable) do
		local showConfig = self.itemShowConfig[i]
		if showConfig then 
			local itemBubble = IosSalesItemBubble:create(v.itemId, v.num, showConfig.delayTime, false)
			self:pushSingleReward(itemBubble:getIcon(), v.itemId, v.num)
			itemBubble:setScale(showConfig.scale)
			itemBubble:setRotation(showConfig.rotation)
			self:addChild(itemBubble)
			itemBubble:setPosition(ccp(showConfig.posX, showConfig.posY))
			itemBubble:play()
		end
	end
end

function AndroidSpecialSalesPanel:_calcPosition()
	local selfSizeWidth = 688
	local selfSizeHeight = 960
	local vOrigin = CCDirector:sharedDirector():getVisibleOrigin()
	local vSize = CCDirector:sharedDirector():getVisibleSize()
	local deltaWidth = vSize.width - selfSizeWidth
	local deltaHeight = vSize.height - selfSizeHeight
	local selfParent = self:getParent()

	if selfParent then
		local pos = selfParent:convertToNodeSpace(ccp(vOrigin.x + deltaWidth / 2, vOrigin.y + selfSizeHeight + deltaHeight / 2))
		self:setPosition(ccp(pos.x, pos.y))
	end
end

function AndroidSpecialSalesPanel:create(data, cdSeconds, salesEndCallback)
	local mainPayment = PaymentManager.getInstance():getDefaultThirdPartPayment()
	local otherThirdPartPayment = PaymentManager.getInstance():getOtherThirdPartPayment(true)
	local repayChooseTable = table.union({mainPayment}, otherThirdPartPayment)

	local panel = AndroidSpecialSalesPanel.new()
	panel.data = data
	panel.cdSeconds = cdSeconds
	panel.salesEndCallback = salesEndCallback

	panel.mainPayment = mainPayment
	panel.otherPaymentTable = otherThirdPartPayment
	panel.repayChooseTable = repayChooseTable

	panel:loadRequiredResource("ui/IosSalesPromotion.json")
	if panel:init() then 
		return panel
	end
end