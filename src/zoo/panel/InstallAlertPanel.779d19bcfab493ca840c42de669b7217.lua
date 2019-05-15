
local InstallAlertPanel = class(BasePanel)


local Cur_Pop_Panel = nil


function InstallAlertPanel:create(onExitCallBack, onCancelCallBack)
	local panel = InstallAlertPanel.new()
	panel:loadRequiredResource('ui/update_new_version_panel_ver_47.json')
	panel:init(onExitCallBack, onCancelCallBack)
	Cur_Pop_Panel = panel
	return panel
end

function InstallAlertPanel:init(onExitCallBack, onCancelCallBack)

	self.onExitCallBack = onExitCallBack
	self.onCancelCallBack = onCancelCallBack

	local rewards = {}
	if UserManager:getInstance().updateInfo then
		rewards = UserManager:getInstance().updateInfo.rewards or {}
	end

	self.ui = self:buildInterfaceGroup('update_version_panel_47_1518/download_sucess_panel')
	BasePanel.init(self, self.ui)

	local closeBtn = self.ui:getChildByName('closeBtn')
	closeBtn:setPosition(ccp(613.3, -228))
	closeBtn:setTouchEnabled(true)
	closeBtn:ad(DisplayEvents.kTouchTap, function ( ... )
		self:onOkTapped()
	end)

	self.ui:addChild(closeBtn)

	local wSize = CCDirector:sharedDirector():getWinSize()
	local winSize = CCDirector:sharedDirector():getVisibleSize()

	local label = self.ui:getChildByName("label")
	local confirm = GroupButtonBase:create(self.ui:getChildByName("okBtn"))
	local cancel = GroupButtonBase:create(self.ui:getChildByName("cancelBtn"))
	local label1 = self.ui:getChildByName("label1")
	local item1 = self.ui:getChildByName("item1")
	local bg = self.ui:getChildByName("bg")
	local bg1 = self.ui:getChildByName("bg1")
	local tip = self.ui:getChildByName("tip")

	local itemY = item1:getPositionY()

	self.label = label
	self.confirm = confirm
	self.items = {}

	if type(rewards) ~= "table" then rewards = {} end

	local successLabelKey = "wifi.update.success.panel.desc1"
	
	local dimension = label:getDimensions()
	label:setDimensions(CCSizeMake(dimension.width, 0))
	label:setString(Localization:getInstance():getText(successLabelKey))
	local iSize = item1:getGroupBounds().size

	local items = {}
	for k, v in ipairs(rewards) do
		local item = self:buildItem(v)
		item.itemId = v.itemId
		item.num = v.num
		table.insert(items, item)
		table.insert(self.items, item)
	end

	local bgSize = bg:getGroupBounds().size
	local bgSize1 = bg1:getGroupBounds().size
	local boxWidth = bgSize1.width / (#rewards + 1)
	local extraX = 80 * (4-#rewards)
	local spacing = (bgSize1.width - iSize.width*#rewards - extraX) / (#rewards + 1)

	for k, v in ipairs(items) do

		v:setPositionXY(12 + extraX/2 + (bgSize.width-bgSize1.width)/2 + (spacing + iSize.width) * k - iSize.width, itemY)
		self.ui:addChildAt(v, self.ui:getChildIndex(item1))

	end
	item1:removeFromParentAndCleanup(true)

	self:scaleAccordingToResolutionConfig()
	self:setPositionForPopoutManager()

	confirm:ad(DisplayEvents.kTouchTap, function()
		self:onOkTapped()
	end)
	confirm:setString(Localization:getInstance():getText("wifi.update.success.panel.btn"))
	cancel:setColorMode(kGroupButtonColorMode.grey)
	cancel:ad(DisplayEvents.kTouchTap, function()
		DcUtil:UserTrack({category = 'ui', sub_category = 'quit_panel', choose = 0})
		self:onCloseBtnTapped()
	end)
	cancel:setString(Localization:getInstance():getText("wifi.update.success.panel.btn.cancel"))
	tip:setString(Localization:getInstance():getText("wifi.update.success.panel.desc2"))
end

function InstallAlertPanel:popout()
	PopoutManager.sharedInstance():add(self, true, false, Director:sharedDirector():getRunningScene(), "topLayer")
	self.allowBackKeyTap = true
end

function InstallAlertPanel:onCloseBtnTapped()

	if self.onCancelCallBack then
		self.onCancelCallBack(5)
	end


	PopoutManager:sharedInstance():removeWithBgFadeOut(self, false)
	self.allowBackKeyTap = false
end

function InstallAlertPanel:onOkTapped()


	DcUtil:UserTrack({category = 'ui', sub_category = 'quit_panel', choose = 1})

	if UpdatePackageManager:enabled() then
		UpdatePackageManager:getInstance():onExitInstall()
	else
		local apkPath = nil
		local UpdatePackageLogic = require 'zoo.panel.UpdatePackageLogic'
		apkPath = UpdatePackageLogic:getInstance():getData().apkPath

		local PackageUtils = luajava.bindClass("com.happyelements.android.utils.PackageUtils")
		local MainActivityHolder = luajava.bindClass('com.happyelements.android.MainActivityHolder')
		PackageUtils:installApk(
			MainActivityHolder.ACTIVITY:getContext(), 
			apkPath
		)
	end


	if self.onExitCallBack then
		self.onExitCallBack(5)
	end

end

function InstallAlertPanel:buildItem( rewardItem )
	local itemUI = self:buildInterfaceGroup('update_version_panel_47_1518/update_new_version_panel_item')
	local sp = ResourceManager:sharedInstance():buildItemSprite(rewardItem.itemId)
	local itemHolder = itemUI:getChildByName('item')
	local itemHolderIndex = itemUI:getChildIndex(itemHolder)
	sp:setAnchorPoint(ccp(0.5, 0.5))
	itemHolder:setAnchorPointCenterWhileStayOrigianlPosition()
	local pos = itemHolder:getPosition()
	sp:setPosition(ccp(pos.x - 6, pos.y))
	itemUI:addChildAt(sp, itemHolderIndex)
	itemHolder:removeFromParentAndCleanup(true)
	sp:setScale(1.2)

	local newLabel = BitmapText:create('', 'fnt/target_amount.fnt')
	newLabel:setAnchorPoint(ccp(0, 1))
	newLabel:setText('x'..tostring(rewardItem.num))
	newLabel:setScale(1.4)
	local numPos = itemUI:getChildByName('num'):getPosition()

	itemUI:addChild(newLabel)
	newLabel:setPosition(ccp(numPos.x, numPos.y))
	return itemUI
end


function InstallAlertPanel:removeExitAlert()
	if Cur_Pop_Panel ~= nil then
		Cur_Pop_Panel:onCloseBtnTapped()
		Cur_Pop_Panel = nil
	end
end

return InstallAlertPanel