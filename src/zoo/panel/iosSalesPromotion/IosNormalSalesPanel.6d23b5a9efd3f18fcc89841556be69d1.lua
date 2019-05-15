require 'zoo.panel.iosSalesPromotion.IosSalesBasePanel'
require 'zoo.panel.IosAliCartoonPanel'

IosNormalSalesPanel = class(IosSalesBasePanel)

local coinShowConfigOne = {{posX = 130, posY = -330, delayTime = 0.5, scale = 1.2, rotation = -10}}
local itemShowConfigOne = {{posX = 420, posY = -350, delayTime = 0.71, scale = 1.2, rotation = 15}}

local coinShowConfigTwo = {{posX = 235, posY = -300, delayTime = 0.5, scale = 1, rotation = 0}}
local itemShowConfigTwo = {{posX = 60, posY = -400, delayTime = 0.71, scale = 1, rotation = -15},
						   {posX = 465, posY = -370, delayTime = 0.835, scale = 1.1, rotation = 20}}

function IosNormalSalesPanel:ctor()
	
end

function IosNormalSalesPanel:init()
	self.ui	= self:buildInterfaceGroup("IosNormalSalesPanel")
	IosSalesBasePanel.init(self, self.ui)

	self.panelTitle:setString(Localization:getInstance():getText("ios.special.offer.title1"))

	FrameLoader:loadArmature('skeleton/ios_promotion_normal', 'ios_promotion_normal', 'ios_promotion_normal')

	self.showLinkIosAli = IosAliGuideUtils:shouldShowIOSAliGuide()
	self.showAnimIosAli = self.showLinkIosAli and (not CCUserDefault:sharedUserDefault():getBoolForKey("ios.old.promotion.ali.guide.anim"))
	if self.showAnimIosAli then
		CCUserDefault:sharedUserDefault():setBoolForKey("ios.old.promotion.ali.guide.anim", true)
	end

	if self.showAnimIosAli then
		FrameLoader:loadArmature('skeleton/ios_ali_guide_normal', 'ios_ali_guide_normal', 'ios_ali_guide_normal')
	end

    local anim = ArmatureNode:create('ios_promotion_normal')
    anim:playByIndex(0,1)
    anim:setPosition(ccp(-26.5, 17))
    self.ui:addChild(anim)

    self.coinTable, self.itemTable = IosSalesManager:seperateItemTable(self.data.items)
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

    if self.showAnimIosAli then
    	self:runAction(CCSequence:createWithTwoActions(
    		CCDelayTime:create(1.2),
    		CCCallFunc:create(function()
   				self:playIosAliAnim()
    		end)
    	))
   	end

   	if self.showLinkIosAli then
   		self.ios_ali_link:setVisible(true)
   		self.ios_ali_link:setTouchEnabled(true)
		self.ios_ali_link:ad(DisplayEvents.kTouchTap, function()
			IosAliCartoonPanel:create():popout()
		end)
   	end
    return true
end

function IosNormalSalesPanel:showRewards()
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

function IosNormalSalesPanel:_calcPosition()
	local selfSizeWidth = 688
	local selfSizeHeight = 897
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

function IosNormalSalesPanel:create(data, cdSeconds, promoEndCallback)
	local panel = IosNormalSalesPanel.new()
	panel.data = data
	panel.cdSeconds = cdSeconds
	panel.promoEndCallback = promoEndCallback
	panel:loadRequiredResource("ui/IosSalesPromotion.json")
	if panel:init() then 
		return panel
	end
end

function IosNormalSalesPanel:dispose()
	IosSalesBasePanel.dispose(self)
	if self.showAnimIosAli then
		-- ArmatureFactory:remove('ios_ali_guide_normal', 'ios_ali_guide_normal')
        FrameLoader:unloadArmature('skeleton/ios_ali_guide_normal', true)
	end
	-- ArmatureFactory:remove('ios_promotion_normal', 'ios_promotion_normal')
    FrameLoader:unloadArmature('skeleton/ios_promotion_normal', true)
end

function IosNormalSalesPanel:playIosAliAnim()
	if self.isDisposed then return end
    local anim = ArmatureNode:create('ios_ali_guide_normal_dir/ios_ali_guide_normal')
    self:addChild(anim)
    anim:setPosition(ccp(490, -430))
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