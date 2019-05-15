local MiTalkRemovePanelOne = class(BasePanel)
function MiTalkRemovePanelOne:create( ... )
	local panel = MiTalkRemovePanelOne.new()
    panel:loadRequiredResource("ui/wdj_remove.json")
    panel:init()
    return panel
end

function MiTalkRemovePanelOne:init()
	local ui = self:buildInterfaceGroup("wdj_remove/WDJRemovePanel1")
	BasePanel.init(self, ui)

    self.desc1_tf = self.ui:getChildByName('desc1_tf')
    --self.desc2_tf = self.ui:getChildByName('desc2_tf')
    --self.num_tf = self.ui:getChildByName('num_tf')
    self.desc1_tf:setString(localize('mitalk.remove.panel.text1', {n = '\n', s = ' '}))
    --self.desc2_tf:setString(localize('mitalk.remove.panel.text2'))
    --self.num_tf:setString(localize('mitalk.remove.panel.text3'))

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

    self.title = self.ui:getChildByName("title")
    self.title:setVisible(false)
    local texture = CCTextureCache:sharedTextureCache():addImage(SpriteUtil:getRealResourceName("materials/mitalk_remove.png"))
    local mitalkTitle = Sprite:createWithTexture(texture)
    mitalkTitle:setPosition(ccp(352, -132))
    self.ui:addChild(mitalkTitle)
end

function MiTalkRemovePanelOne:popout(successCallback, failCallback)
    self.allowBackKeyTap = true
    self.successCallback = successCallback
    self.failCallback = failCallback
    PopoutQueue:sharedInstance():push(self, true)
end

function MiTalkRemovePanelOne:onCloseBtnTapped( ... )
    if self.failCallback then self.failCallback() end
	PopoutManager:sharedInstance():remove(self)
    CCTextureCache:sharedTextureCache():removeTextureForKey("materials/mitalk_remove.png")
end

function MiTalkRemovePanelOne:onOKBtnTapped( ... )
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

local MiTalkRemovePanelTwo = class(BasePanel)
function MiTalkRemovePanelTwo:create( ... )
	local panel = MiTalkRemovePanelTwo.new()
    panel:loadRequiredResource("ui/wdj_remove.json")
    panel:init()
    return panel
end

function MiTalkRemovePanelTwo:init()
	local ui = self:buildInterfaceGroup("wdj_remove/WDJRemovePanel2")
	BasePanel.init(self, ui)

    self.desc1_tf = self.ui:getChildByName('desc1_tf')
    --self.desc2_tf = self.ui:getChildByName('desc2_tf')
    self.desc3_tf = self.ui:getChildByName('desc3_tf')
    self.desc1_tf:setString(localize('mitalk.remove.panel.text4', {n = '\n', s = ' '}))
    --self.desc2_tf:setString(localize('mitalk.remove.panel.text5'))
    self.desc3_tf:setString(localize('mitalk.remove.panel.text6'))

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

    self.title = self.ui:getChildByName("title")
    self.title:setVisible(false)
    local texture = CCTextureCache:sharedTextureCache():addImage(SpriteUtil:getRealResourceName("materials/mitalk_remove.png"))
    local mitalkTitle = Sprite:createWithTexture(texture)
    mitalkTitle:setPosition(ccp(352, -132))
    self.ui:addChild(mitalkTitle)
end

function MiTalkRemovePanelTwo:popout(callback, noPopCallback)
    self.allowBackKeyTap = true
    self.callback = callback
    self.noPopCallback = noPopCallback
    PopoutQueue:sharedInstance():push(self, true)
end

function MiTalkRemovePanelTwo:onCloseBtnTapped( ... )
    if self.callback then self.callback() end
    if self.isNoPop then 
         if self.noPopCallback then self.noPopCallback() end
    end
	PopoutManager:sharedInstance():remove(self)
    CCTextureCache:sharedTextureCache():removeTextureForKey("materials/mitalk_remove.png")
end

function MiTalkRemovePanelTwo:onOKBtnTapped( ... )
	self:onCloseBtnTapped()
end

local MiTalkRemovePanelThree = class(BasePanel)
function MiTalkRemovePanelThree:create( ... )
	local panel = MiTalkRemovePanelThree.new()
    panel:loadRequiredResource("ui/wdj_remove.json")
    panel:init()
    return panel
end

function MiTalkRemovePanelThree:init()
	local ui = self:buildInterfaceGroup("wdj_remove/WDJRemovePanel3")
	BasePanel.init(self, ui)

    self.desc_tf = self.ui:getChildByName('desc_tf')
    self.desc_tf:setString(localize('mitalk.remove.panel.text7', {n = '\n', s = ' '}))

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

    self.title = self.ui:getChildByName("title")
    self.title:setVisible(false)
    local texture = CCTextureCache:sharedTextureCache():addImage(SpriteUtil:getRealResourceName("materials/mitalk_remove.png"))
    local mitalkTitle = Sprite:createWithTexture(texture)
    mitalkTitle:setPosition(ccp(352, -132))
    self.ui:addChild(mitalkTitle)
end

function MiTalkRemovePanelThree:popout(callback)
    self.allowBackKeyTap = true
    self.callback = callback
    PopoutQueue:sharedInstance():push(self, true)
end

function MiTalkRemovePanelThree:onCloseBtnTapped( ... )
    if self.callback then self.callback() end
	PopoutManager:sharedInstance():remove(self)
    CCTextureCache:sharedTextureCache():removeTextureForKey("materials/mitalk_remove.png")
end

function MiTalkRemovePanelThree:onOKBtnTapped( ... )
	self:onCloseBtnTapped()
end

local MiTalkRemovePanel = class(BasePanel)
function MiTalkRemovePanel:create(ptype)
	local panel
	if ptype == 1 then 
		panel = MiTalkRemovePanelOne:create()
	elseif ptype == 2 then
		panel = MiTalkRemovePanelTwo:create()
	else
		panel = MiTalkRemovePanelThree:create()
	end
    return panel
end
return MiTalkRemovePanel
