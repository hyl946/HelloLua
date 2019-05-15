local WDJRemovePanelOne = class(BasePanel)
function WDJRemovePanelOne:create( ... )
	local panel = WDJRemovePanelOne.new()
    panel:loadRequiredResource("ui/wdj_remove.json")
    panel:init()
    return panel
end

function WDJRemovePanelOne:init()
	local ui = self:buildInterfaceGroup("wdj_remove/WDJRemovePanel1")
	BasePanel.init(self, ui)

    self.desc1_tf = self.ui:getChildByName('desc1_tf')
    self.desc2_tf = self.ui:getChildByName('desc2_tf')
    --self.num_tf = self.ui:getChildByName('num_tf')
    self.desc1_tf:setString(localize('wdjremove.panel.text1', {n = '\n', s = ' '}))
    self.desc2_tf:setString(localize('wdjremove.panel.text2'))
    --self.num_tf:setString(localize('wdjremove.panel.text3'))

    self.close_btn = self.ui:getChildByName('close_btn')
    self.close_btn:setTouchEnabled(true, 0, true)
    self.close_btn:ad(DisplayEvents.kTouchTap, function () 
        self:onCloseBtnTapped() 
    end)

    self.ok_btn = GroupButtonBase:create(self.ui:getChildByName('ok_btn'))
    self.ok_btn:setString("手机登录")
    self.ok_btn:setColorMode(kGroupButtonColorMode.green)
    self.ok_btn:ad(DisplayEvents.kTouchTap, function( )
        self:onOKBtnTapped()
    end)
    self:scaleAccordingToResolutionConfig()
    self:setPositionForPopoutManager()
end

function WDJRemovePanelOne:popout(successCallback, failCallback)
    self.allowBackKeyTap = true
    self.successCallback = successCallback
    self.failCallback = failCallback
    PopoutManager:sharedInstance():add(self, true)
end

function WDJRemovePanelOne:onCloseBtnTapped( ... )
    if self.failCallback then self.failCallback() end
	PopoutManager:sharedInstance():remove(self)
end

function WDJRemovePanelOne:onOKBtnTapped( ... )
    local function onReturnCallback()
        if self.failCallback then self.failCallback() end
        PopoutManager:sharedInstance():remove(self)
    end
    local function onBindSuccessCallback()
        if self.successCallback then self.successCallback() end
        PopoutManager:sharedInstance():remove(self)
        BindPhoneBonus:receiveReward(false, 14) 
    end
    AccountBindingLogic:bindNewPhone(onReturnCallback, onBindSuccessCallback, AccountBindingSource.WDJ_REMOVE)
end

local WDJRemovePanelTwo = class(BasePanel)
function WDJRemovePanelTwo:create( ... )
	local panel = WDJRemovePanelTwo.new()
    panel:loadRequiredResource("ui/wdj_remove.json")
    panel:init()
    return panel
end

function WDJRemovePanelTwo:init()
	local ui = self:buildInterfaceGroup("wdj_remove/WDJRemovePanel2")
	BasePanel.init(self, ui)

    self.desc1_tf = self.ui:getChildByName('desc1_tf')
    self.desc2_tf = self.ui:getChildByName('desc2_tf')
    self.desc3_tf = self.ui:getChildByName('desc3_tf')
    self.desc1_tf:setString(localize('wdjremove.panel.text4', {n = '\n', s = ' '}))
    self.desc2_tf:setString(localize('wdjremove.panel.text5'))
    self.desc3_tf:setString(localize('wdjremove.panel.text6'))

    self.right_btn = self.ui:getChildByName('right_btn')
    self.isNoPop = self.right_btn:isVisible()
    self.check_btn = self.ui:getChildByName('check_btn')
    self.check_btn:setTouchEnabled(true, 0, true)
    self.check_btn:ad(DisplayEvents.kTouchTap, function () 
        self.right_btn:setVisible(not self.right_btn:isVisible())
        self.isNoPop = self.right_btn:isVisible()
    end)

    self.close_btn = self.ui:getChildByName('close_btn')
    self.close_btn:setTouchEnabled(true, 0, true)
    self.close_btn:ad(DisplayEvents.kTouchTap, function () 
        self:onCloseBtnTapped() 
    end)

    self.ok_btn = GroupButtonBase:create(self.ui:getChildByName('ok_btn'))
    self.ok_btn:setString("知道了")
    self.ok_btn:setColorMode(kGroupButtonColorMode.green)
    self.ok_btn:ad(DisplayEvents.kTouchTap, function( )
        self:onOKBtnTapped()
    end)
    self:scaleAccordingToResolutionConfig()
    self:setPositionForPopoutManager()
end

function WDJRemovePanelTwo:popout(callback, noPopCallback)
    self.allowBackKeyTap = true
    self.callback = callback
    self.noPopCallback = noPopCallback
    PopoutManager:sharedInstance():add(self, true)
end

function WDJRemovePanelTwo:onCloseBtnTapped( ... )
    if self.callback then self.callback() end
    if self.isNoPop then 
         if self.noPopCallback then self.noPopCallback() end
    end
	PopoutManager:sharedInstance():remove(self)
end

function WDJRemovePanelTwo:onOKBtnTapped( ... )
	self:onCloseBtnTapped()
end

local WDJRemovePanelThree = class(BasePanel)
function WDJRemovePanelThree:create( ... )
	local panel = WDJRemovePanelThree.new()
    panel:loadRequiredResource("ui/wdj_remove.json")
    panel:init()
    return panel
end

function WDJRemovePanelThree:init()
	local ui = self:buildInterfaceGroup("wdj_remove/WDJRemovePanel3")
	BasePanel.init(self, ui)

    self.desc_tf = self.ui:getChildByName('desc_tf')
    self.desc_tf:setString(localize('wdjremove.panel.text7', {n = '\n', s = ' '}))

    self.close_btn = self.ui:getChildByName('close_btn')
    self.close_btn:setTouchEnabled(true, 0, true)
    self.close_btn:ad(DisplayEvents.kTouchTap, function () 
        self:onCloseBtnTapped() 
    end)

    self.ok_btn = GroupButtonBase:create(self.ui:getChildByName('ok_btn'))
    self.ok_btn:setString("知道了")
    self.ok_btn:setColorMode(kGroupButtonColorMode.green)
    self.ok_btn:ad(DisplayEvents.kTouchTap, function( )
        self:onOKBtnTapped()
    end) 
    self:scaleAccordingToResolutionConfig()
    self:setPositionForPopoutManager()
end

function WDJRemovePanelThree:popout(callback)
    self.allowBackKeyTap = true
    self.callback = callback
    PopoutManager:sharedInstance():add(self, true)
end

function WDJRemovePanelThree:onCloseBtnTapped( ... )
    if self.callback then self.callback() end
	PopoutManager:sharedInstance():remove(self)
end

function WDJRemovePanelThree:onOKBtnTapped( ... )
	self:onCloseBtnTapped()
end

local WDJRemovePanel = class(BasePanel)
function WDJRemovePanel:create(ptype)
	local panel
	if ptype == 1 then 
		panel = WDJRemovePanelOne:create()
	elseif ptype == 2 then
		panel = WDJRemovePanelTwo:create()
	else
		panel = WDJRemovePanelThree:create()
	end
    return panel
end
return WDJRemovePanel
