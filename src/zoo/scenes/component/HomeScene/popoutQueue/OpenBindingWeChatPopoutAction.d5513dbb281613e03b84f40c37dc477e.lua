require "zoo.common.FAQ"

-- happyanimal3://wechat_mini_app/redirect?token=511480126d6aa76362a966a532cbdb0c&path=pages%2Factivity%2FkillLaiMeng%2FkillLaiMeng

OpenBindingWeChatPopoutAction = class(HomeScenePopoutAction)

local BindingWXAppAlert = class(BasePanel)
local BindingWXAppSuccessPanel = class(BindingWXAppAlert)

local path = nil

function OpenBindingWeChatPopoutAction:ctor()
    self.name = "OpenBindingWeChatPopoutAction"
    self.openUrlMethod = "wechat_mini_app"
    self:setSource(AutoPopoutSource.kInitEnter, AutoPopoutSource.kEnterForeground, AutoPopoutSource.kReturnFromFAQ)
end

function OpenBindingWeChatPopoutAction:checkCache(cache)
    local isOpen = MaintenanceManager:getInstance():isEnabled("bindingWeChatApp")
    if not isOpen then
        CommonTip:showTip("此平台暂不支持绑定。")
        self:onCheckCacheResult(false)
        return
    end

    local res = cache.para
    local ret = false

    self.token = res.para and res.para.token
    self.path = res.para and res.para.path
    if self.path then
        self.path = HeDisplayUtil:urlDecode(self.path)
    end
    path = self.path
    ret = self.token
    print("OpenBindingWeChatPopoutAction:checkCache()",self.token,self.path)
    self:onCheckCacheResult(ret)
end

function OpenBindingWeChatPopoutAction:popout( ... )
    if not self.token then
        self:next()
        return
    end

    local function onEnd(force)
        if force then
            self.justToBind = false
        elseif
            self.justToBind then
            return
        end

        self:next()
    end

    local function toBind()
        self.justToBind = true
        local function onSuccess(evt)
            -- BindingWXAppAlert:create("绑定微信小程序成功")
            BindingWXAppSuccessPanel:create()
            onEnd(true)
        end
        local function onFail(evt)
            print("OpenBindingWeChatPopoutAction:popout()onFail()",table.tostring(evt))
            -- BindingWXAppAlert:create("绑定微信小程序失败")
            CommonTip:showTip("绑定微信小程序失败", 'negative')
            onEnd(true)
        end
        local function onCancel(evt)
            -- BindingWXAppAlert:create("绑定微信小程序失败")
            CommonTip:showTip("绑定已取消", 'negative')
            onEnd(true)
        end

        local http = OpNotifyHttp.new()
        http:ad(Events.kComplete, onSuccess)
        http:ad(Events.kError, onFail)
        http:ad(Events.kCancel, onCancel) 

        local data = {token=self.token,xxlId=UserManager:getInstance().inviteCode}
        http:load( 74 , table.serialize(data) )
    end

    -- local params={}
    -- params.info = "是否绑定微信小程序?"
    -- params.okCallback = toBind
    -- params.isConfirm = true
    -- Alert:create(params)

    local function showAlert()
        local params={}
        params.token = self.token
        params.okCallback = toBind
        params.closeCallback = onEnd
        BindingWXAppAlert:create(params)
    end

    local function onRegFail()
        CommonTip:showTip("微信小程序绑定失败", 'negative')
        onEnd()
    end
    
    FAQ:openWechatAppReg(showAlert,onRegFail)
end

---------

local PANEL_UI =  "ui/wx_app.json"

local function createBtn(node,callback,label)
    local btn = node
    print("createBtn()",node,callback,label,node:getChildByName("labelSize"))
    node:setTouchEnabled(true, 0, true)
    if node:getChildByName("labelSize") then
        btn = GroupButtonBase:create( node )
        btn:setEnabled(true)
        local _ = label and btn:setString(label)
    end
    btn:ad(DisplayEvents.kTouchTap, callback)
    return btn
end

function BindingWXAppAlert:create(customData)
    print("BindingWXAppAlert:create",table.tostring(customData))
    local a = BindingWXAppAlert.new()
    a:init(customData)
    a:popout()
    return a
end

function BindingWXAppAlert:init( customData )
    self.customData = customData

    self:loadRequiredResource(PANEL_UI)
    self.ui = self:buildInterfaceGroup("bind_wx_app/Alert")
    BasePanel.init(self, self.ui)

    local childs = {
        "headSource",
        "headTarget",
        "btnClose",
        "btnOK",
        "txtBtm",
    }
    for i,v in ipairs(childs) do
        self[v] = self.ui:getChildByName(v)
    end

    self.txtBtm:setString("绑定后，小程序将获取您的游戏数据")

    local function onOK(event)
        self:onClose()
        local _ = customData.okCallback and xpcall(customData.okCallback, __G__TRACKBACK__)
    end

    local function onBtnClose()
        CommonTip:showTip("绑定已取消", 'negative')
        self:onClose()
    end

    createBtn(self.btnOK,onOK,"确认绑定")
    createBtn(self.btnClose,onBtnClose)
    self.allowBackKeyTap = true

    local function updateUserHead( target,profile )
        if self.isDisposed then return end
        if not target or target.isDisposed then return end

        target:getChildByName("txtName"):setString(nameDecode(profile.name))
        local UIHelper = require "zoo.panel.UIHelper"
        UIHelper:loadUserHeadIcon(target:getChildByName('head'), profile, true)
    end

    local profile = UserManager:getInstance().profile
    updateUserHead(self.headTarget,profile)

    local function onInfoSuccess( evt )
        print("onInfoSuccess",table.tostring(evt.data))
        if evt and evt.data then
            local data = table.deserialize(evt.data.extra)
            if data and data.nickName then
                updateUserHead(self.headSource,{uid = UserManager:getInstance().uid,name = data.nickName,headUrl = data.headUrl})
            end
        end
    end

    if self.customData.token then
        setTimeOut(function()
            local http = OpNotifyHttp.new()
            http:ad(Events.kComplete, onInfoSuccess)
            -- http:ad(Events.kError, onFail)
            -- http:ad(Events.kCancel, onCancel) 
            http:load( 75 , self.customData.token )
        end,0.1)
    end

end

function BindingWXAppAlert:onClose()
    local fn = self.customData and self.customData.closeCallback
    PopoutManager:sharedInstance():remove(self,true)
    local _ = fn and xpcall(fn, __G__TRACKBACK__)
end

function BindingWXAppAlert:closeBackKeyTap()
    self:onClose()
end

function BindingWXAppAlert:popout()
    self.allowBackKeyTap = true
    self:scaleAccordingToResolutionConfig()
    self:setPositionForPopoutManager()
    PopoutManager:sharedInstance():add(self, false)
end

function BindingWXAppAlert:onKeyBackClicked(...)
    if self.allowBackKeyTap then
        self:onClose()
    end
end

----------------

function BindingWXAppSuccessPanel:create(customData)
    local a = BindingWXAppSuccessPanel.new()
    a:init(customData)
    a:popout()
    return a
end

function BindingWXAppSuccessPanel:init( customData )
    self.customData = customData

    self:loadRequiredResource(PANEL_UI)
    self.ui = self:buildInterfaceGroup("bind_wx_app/SuccessPanel")
    BasePanel.init(self, self.ui)

    local childs = {
        "btnClose",
        "btnLeft",
        "btnRight",
        "txtInfo",
    }
    for i,v in ipairs(childs) do
        self[v] = self.ui:getChildByName(v)
    end

    self.txtInfo:setString("开心消消乐小程序已成功绑定您的游戏账号，快去看看吧~")

    local function onReturn()
        self:onClose()
        SnsUtil:launchMiniProgram(path or "pages/home/index/index")
    end

    createBtn(self.btnClose,handler(self,self.onClose))
    createBtn(self.btnRight,handler(self,self.onClose),"留在游戏")
    local btnLeft = createBtn(self.btnLeft,onReturn,"返回小程序")
    btnLeft:setColorMode(kGroupButtonColorMode.blue)

    self.btnClose:setVisible(false)
    self.allowBackKeyTap = true
end