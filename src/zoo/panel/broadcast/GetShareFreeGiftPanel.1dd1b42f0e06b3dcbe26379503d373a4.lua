require 'zoo.panel.broadcast.AutoClosePanel'
GetShareFreeGiftPanel = class(AutoClosePanel)

if GetShareFreeGiftPanel.panelData == nil then
	GetShareFreeGiftPanel.panelData = {Pre_Game_Gift_Num = 0, 
							  		   In_Game_Gift_Num = 0}
end


function GetShareFreeGiftPanel:setPreGameGiftNum(num)
	GetShareFreeGiftPanel.panelData.Pre_Game_Gift_Num = num
end

function GetShareFreeGiftPanel:addInGameGiftNum(num)
	GetShareFreeGiftPanel.panelData.In_Game_Gift_Num = GetShareFreeGiftPanel.panelData.In_Game_Gift_Num + num
end

function GetShareFreeGiftPanel:create(afterClose)
	local instance = GetShareFreeGiftPanel.new()
	instance:loadRequiredResource(PanelConfigFiles.common_message)
	instance:init(afterClose)
	return instance
end

function GetShareFreeGiftPanel:init(afterClose)
	BasePanel.init(self, self:buildInterfaceGroup('broadcast/panel'))
	self.afterClose = afterClose
	self.text = self.ui:getChildByName('text')
	self.text:setPreferredSize(self.text:getPreferredSize().width, 0)
	self.ui:getChildByName("link"):setVisible(false)
	self.ui:getChildByName("icon1"):setVisible(false)
end

function GetShareFreeGiftPanel:popout()
	self.preGameGiftNum = GetShareFreeGiftPanel.panelData.Pre_Game_Gift_Num
	self.inGameGiftNum = GetShareFreeGiftPanel.panelData.In_Game_Gift_Num
	GetShareFreeGiftPanel.panelData.Pre_Game_Gift_Num = 0
	GetShareFreeGiftPanel.panelData.In_Game_Gift_Num = 0
	self.giftNum = self.preGameGiftNum + self.inGameGiftNum
	self.text:setString(localize("broadcast.get.share.gift", {n = self.giftNum, m = self.giftNum}))
	self.text:setPositionY(self.text:getPositionY() - 8)
	local reward = {itemId = ItemType.SMALL_ENERGY_BOTTLE, num = self.inGameGiftNum}
	UserManager:getInstance():addReward(reward)
	UserService:getInstance():addReward(reward)
	GainAndConsumeMgr.getInstance():gainItem(DcFeatureType.kShow, reward.itemId, reward.num, DcSourceType.kShareFreeGift)
	AutoClosePanel.popout(self)
end

function GetShareFreeGiftPanel:isNeedShow()
	local preGfitNum = GetShareFreeGiftPanel.panelData.Pre_Game_Gift_Num
	local inGameGiftNum = GetShareFreeGiftPanel.panelData.In_Game_Gift_Num
	if preGfitNum == nil then preGfitNum = 0 end
	if inGameGiftNum == nil then inGameGiftNum = 0 end
	return preGfitNum + inGameGiftNum > 0
end

function GetShareFreeGiftPanel:getPriority()
	return 2002
end