require 'zoo.panel.androidSalesPromotion.AndroidSalesBasePanel'

AndroidNormalSalesPanel = class(AndroidSalesBasePanel)

local coinShowConfigOne = {{posX = 130, posY = -330, delayTime = 0.5, scale = 1.2, rotation = -10}}
local itemShowConfigOne = {{posX = 420, posY = -350, delayTime = 0.71, scale = 1.2, rotation = 15}}

local coinShowConfigTwo = {{posX = 235, posY = -300, delayTime = 0.5, scale = 1, rotation = 0}}
local itemShowConfigTwo = {{posX = 60, posY = -400, delayTime = 0.71, scale = 1, rotation = -15},
						   {posX = 465, posY = -370, delayTime = 0.835, scale = 1.1, rotation = 20}}

function AndroidNormalSalesPanel:ctor()
	
end

function AndroidNormalSalesPanel:init()
	self.ui	= self:buildInterfaceGroup("AndroidNormalSalesPanel")
	AndroidSalesBasePanel.init(self, self.ui)

	self.panelTitle:setString(Localization:getInstance():getText("ios.special.offer.title1"))

	FrameLoader:loadArmature('skeleton/ios_promotion_normal', 'ios_promotion_normal', 'ios_promotion_normal')
    local anim = ArmatureNode:create('ios_promotion_normal')
    anim:playByIndex(0,1)
    anim:setPosition(ccp(-26.5, 13))
    self.ui:addChild(anim)

    self.coinTable, self.itemTable = AndroidSalesManager:seperateItemTable(self.data.items)
    if #self.coinTable == 0 or self.itemTable == 0 then 
    	return false
    end
   	
   	self:setButtonDelayEnable(1)

    if #self.itemTable == 1 then 
    	self.coinShowConfig = coinShowConfigOne
    	self.itemShowConfig = itemShowConfigOne
    else
    	self.coinShowConfig = coinShowConfigTwo
    	self.itemShowConfig = itemShowConfigTwo
    end 

    self:showRewards()
    return true
end

function AndroidNormalSalesPanel:showRewards()
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

function AndroidNormalSalesPanel:_calcPosition()
	local selfSizeWidth = 688
	local selfSizeHeight = 937
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

function AndroidNormalSalesPanel:create(data, cdSeconds, salesEndCallback)
	local mainPayment = PaymentManager.getInstance():getDefaultThirdPartPayment()
	local otherThirdPartPayment = PaymentManager.getInstance():getOtherThirdPartPayment(true)
	local repayChooseTable = table.union({mainPayment}, otherThirdPartPayment)

	local panel = AndroidNormalSalesPanel.new()
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