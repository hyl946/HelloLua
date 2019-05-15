require 'zoo.panel.iosSalesPromotion.IosSalesBasePanel'
require 'zoo.panel.IosAliCartoonPanel'

IosSpecialSalesPanel = class(IosSalesBasePanel)
local coinShowConfig = {{posX = 135, posY = -355, delayTime = 1.3, scale = 1, rotation = 0}}
local itemShowConfig = {{posX = 400, posY = -375, delayTime = 1.5, scale = 1, rotation = 0}}

function IosSpecialSalesPanel:ctor()
	
end

function IosSpecialSalesPanel:init()
	self.ui	= self:buildInterfaceGroup("IosSpecialSalesPanel")
	IosSalesBasePanel.init(self, self.ui)

	self.panelTitle:setString(Localization:getInstance():getText("ios.special.offer.title2"))

	self.cloudUI = self.ui:getChildByName("cloud")
	local childIndex = self.ui:getChildIndex(self.cloudUI)
	self.cloudUI:setVisible(false)

	FrameLoader:loadArmature('skeleton/ios_promotion_special', 'ios_promotion_special', 'ios_promotion_special')

	self.showLinkIosAli = IosAliGuideUtils:shouldShowIOSAliGuide()
	self.showAnimIosAli = self.showLinkIosAli and (not CCUserDefault:sharedUserDefault():getBoolForKey("ios.old.promotion.ali.guide.anim"))
	if self.showAnimIosAli then
		CCUserDefault:sharedUserDefault():setBoolForKey("ios.old.promotion.ali.guide.anim", true)
	end

	if self.showAnimIosAli then
		FrameLoader:loadArmature('skeleton/ios_ali_guide_special', 'ios_ali_guide_special', 'ios_ali_guide_special')
	end



    local anim = ArmatureNode:create('ios_promotion_special')
    anim:playByIndex(0,1)
    anim:setPosition(ccp(-26.5, 17))
    self.ui:addChildAt(anim, childIndex)

    self.coinTable, self.itemTable = IosSalesManager:seperateItemTable(self.data.items)
    if #self.coinTable == 0 or self.itemTable == 0 then 
    	return false
    end

   	self:setButtonDelayEnable(2)

   	self:showCloud()
    self:showRewards()

     if self.showAnimIosAli then
    	self:runAction(CCSequence:createWithTwoActions(
    		CCDelayTime:create(1.2),
    		CCCallFunc:create(function()
   				self:playIosAliAnim()
    		end)
    	))
   	end

   	if self.showLinkIosAli and self.ios_ali_link then
   		self.ios_ali_link:setVisible(true)
   		self.ios_ali_link:setTouchEnabled(true)
		self.ios_ali_link:ad(DisplayEvents.kTouchTap, function()
			IosAliCartoonPanel:create():popout()
		end)
   	end

    return true
end

function IosSpecialSalesPanel:showCloud()
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

function IosSpecialSalesPanel:showRewards()
	for i,v in ipairs(self.coinTable) do
		local showConfig = coinShowConfig[i]
		if showConfig then 
			local coin = IosSalesItemCoin:create(v.num, showConfig.delayTime)
			self:pushSingleReward(coin:getIcon(), ItemType.GOLD, v.num)
			self:addChild(coin)
			coin:setPosition(ccp(showConfig.posX, showConfig.posY))
			coin:play()
		end
	end

	for i,v in ipairs(self.itemTable) do
		local showConfig = itemShowConfig[i]
		if showConfig then 
			local itemBubble = IosSalesItemBubble:create(v.itemId, v.num, showConfig.delayTime, true)
			self:pushSingleReward(itemBubble:getIcon(), v.itemId, v.num)
			self:addChild(itemBubble)
			itemBubble:setPosition(ccp(showConfig.posX, showConfig.posY))
			itemBubble:play()
		end
	end
end

function IosSpecialSalesPanel:_calcPosition()
	local selfSizeWidth = 688
	local selfSizeHeight = 950
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

function IosSpecialSalesPanel:create(data, cdSeconds, promoEndCallback)
	local panel = IosSpecialSalesPanel.new()
	panel.data = data
	panel.cdSeconds = cdSeconds
	panel.promoEndCallback = promoEndCallback
	panel:loadRequiredResource("ui/IosSalesPromotion.json")
	if panel:init() then 
		return panel
	end
end

function IosSpecialSalesPanel:dispose()
	IosSalesBasePanel.dispose(self)
	if self.showAnimIosAli then
		-- ArmatureFactory:remove('ios_ali_guide_special', 'ios_ali_guide_special')
        FrameLoader:unloadArmature('skeleton/ios_ali_guide_special', true)
	end
	-- ArmatureFactory:remove('ios_promotion_special', 'ios_promotion_special')
    FrameLoader:unloadArmature('skeleton/ios_promotion_special', true)
end

function IosSpecialSalesPanel:playIosAliAnim()
	if self.isDisposed then return end
    local anim = ArmatureNode:create('ios_ali_guide_special_dir/ios_ali_guide_special')
    self:addChild(anim)
    anim:setPosition(ccp(250, -510))
    anim:play('start', 1)
    anim:addEventListener(ArmatureEvents.COMPLETE, function()
    	anim:removeAllEventListeners()
    	self:runAction(CCSequence:createWithTwoActions(
    		CCDelayTime:create(3),
    		CCCallFunc:create(function()
   				anim:play('fly', 1)
    		end)
    	))
    end)
end