require "zoo.data.NotificationGuideManager"

NotificationGuidePanel = class(BasePanel)

function NotificationGuidePanel:create(guideTriggerType)
	local panel = NotificationGuidePanel.new()
	panel:loadRequiredResource("ui/AdviseOpenNotification.json")
	panel:init(guideTriggerType)
	return panel
end

function NotificationGuidePanel:init(guideTriggerType)
	self.guideTriggerType = guideTriggerType

	local vSize = CCDirector:sharedDirector():ori_getVisibleSize()

	local kDarkOpacity = 0
    local darkLayer = LayerColor:createWithColor(ccc3(0, 0, 0), 960, math.max(vSize.height, 1280))
    darkLayer:setAnchorPoint(ccp(0,0))
    darkLayer:setOpacity(kDarkOpacity)

	BasePanel.init(self, darkLayer)
	
	self:scaleAccordingToResolutionConfig()
    self:setPositionForPopoutManager()

	FrameLoader:loadArmature('skeleton/advise_open_notification', 'advise_open_notification', 'advise_open_notification')

	self.armatureName = 'AdviseOpenNotification/interface/Avatar'

	local anim = ArmatureNode:create(self.armatureName, true)
	anim:playByIndex(0, 1)
	anim:setPosition(ccp(155, -600))
	self.ui:addChild(anim)

    -- info
    local item = self:buildInterfaceGroup("AdviseOpenNotification/interface/item")
    local pt = anim:getPosition()
    item:setPosition(ccp(pt.x + 60, pt.y + 246))
    item:setVisible(false)
    self.ui:addChild(item)

	self.btn = GroupButtonBase:create(item:getChildByName("btnComfirm"))
	local caption = localize("remind.switch.btnComfirm" ..tostring(guideTriggerType), {endl='\n'})
	self.btn:setString(caption)

	local lbInfo = item:getChildByName("lbInfo")
	lbInfo:changeFntFile("fnt/register2.fnt")
	lbInfo:setScale(1.25)
	local caption = localize("remind.switch.text" ..tostring(guideTriggerType), {endl='\n'})
    lbInfo:setRichText(caption)

    self.btnComfirm = LayerColor:createWithColor(ccc3(255, 255, 255), 270, 100)
    local pt = anim:getPosition()
    self.btnComfirm:setOpacity(0)
    self.btnComfirm:setPosition(ccp(pt.x + 180, pt.y + 12))
    self.btnComfirm:setTouchEnabled(true)
    self.btnComfirm:addEventListener(DisplayEvents.kTouchTap, function() self:onComfirmBtnTapped() end)
    self.ui:addChild(self.btnComfirm)

    self.btnClose = LayerColor:createWithColor(ccc3(255, 255, 255), 50, 50)
    local pt = anim:getPosition()
    self.btnClose:setOpacity(0)
    self.btnClose:setPosition(ccp(pt.x + 580, pt.y + 210))
    self.btnClose:setTouchEnabled(true)
    self.btnClose:addEventListener(DisplayEvents.kTouchTap, function() self:onKeyBackClicked(false) end)
    self.ui:addChild(self.btnClose)

    local tm = anim:getTotalTime() - 0.6
    local seq = CCArray:create()
    seq:addObject(CCDelayTime:create(tm))
    seq:addObject(CCToggleVisibility:create())
	item:runAction(CCSequence:create(seq))
	
	DcUtil:UserTrack({
		category = "noti",
		sub_category = "noti_push",
		t1 = self.guideTriggerType
	})
end

function NotificationGuidePanel:onComfirmBtnTapped()
	if __ANDROID then
		local MainActivityHolder = luajava.bindClass('com.happyelements.android.MainActivityHolder')
		local context = MainActivityHolder.ACTIVITY:getContext()
		local NotificationsUtils = luajava.bindClass("com.happyelements.android.utils.NotificationsUtils")
		if NotificationsUtils:isNotificationEnabled(context) then return end

		NotificationsUtils:openNotificationSetting()
	elseif __IOS then
		AnimalIosUtil:openSystemSetting()
	else
		CommonTip:showTip("打开成功~", "positive")
	end

	DcUtil:UserTrack({
		category = "noti",
		sub_category = "noti_push_button",	
		t1 = self.guideTriggerType
	})

	-- 同时打开满精力通知
	if NotiGuideTriggerType.kEnergyZero == self.guideTriggerType then
    	if not CCUserDefault:sharedUserDefault():getBoolForKey("game.local.notification") then
    	    CCUserDefault:sharedUserDefault():setBoolForKey("game.local.notification", true)
    	    CCUserDefault:sharedUserDefault():flush()
		end
	end

	self:onKeyBackClicked()
end

function NotificationGuidePanel:onKeyBackClicked()
	PopoutManager:sharedInstance():remove(self)
	if self.close_cb then self.close_cb() end
end

function NotificationGuidePanel:popout(close_cb)
	self.close_cb = close_cb
	PopoutManager:sharedInstance():add(self, true, false)
end