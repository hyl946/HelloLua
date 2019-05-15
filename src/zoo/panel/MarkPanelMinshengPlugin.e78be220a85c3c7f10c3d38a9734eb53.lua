--1810  连登面板 民生银行二期  

MarkPanelMinshengPlugin={}

MarkPanelMinshengPlugin.BANK_SCORE_ID = 990000
MarkPanelMinshengPlugin.BANK_SCORE_DAY = 28

local SuccessAlert = nil

function MarkPanelMinshengPlugin:isEnabled()
    -- do return true end
    
    if PlatformConfig:isPlatform(PlatformNameEnum.kOppo) then
        return false
    end
    local actInfo
    for k, v in pairs(UserManager:getInstance().actInfos or {}) do
        if v.actId == 5000 then
            actInfo = v
            break
        end
    end
    if not actInfo then return false end
    actInfo.extraData = table.deserialize(actInfo.extra)
    -- extra : "{"consumeReward":0,"checkInReward":true}"
    return actInfo.extraData.checkInReward
end

function MarkPanelMinshengPlugin:checkReward(v)
    return v.itemId ~= MarkPanelMinshengPlugin.BANK_SCORE_ID
end

local function defineHttp( name )
    local http = class(HttpBase)
    function http:load( params )
        if not kUserLogin then return self:onLoadingError(ZooErrorCode.kNotLoginError) end
        
        local context = self
        local loadCallback = function(endpoint, data, err)
            if err then
                he_log_info(name .. " error: " .. err)
                context:onLoadingError(err)
            else
                he_log_info(name .. " success !")
                
                context:onLoadingComplete(data)
            end
        end

        self.transponder:call(name, params or {}, loadCallback, rpc.SendingPriority.kHigh, false)
    end
    return http
end

function MarkPanelMinshengPlugin:onNewMark(panel,signDay)
    if not MarkPanelMinshengPlugin:isEnabled() then return end
    MarkPanelMinshengPlugin:_updateTxt(panel)
    print("MarkPanelMinshengPlugin:onNewMark()",signDay,signDay ~= MarkPanelMinshengPlugin.BANK_SCORE_DAY)
    if signDay ~= MarkPanelMinshengPlugin.BANK_SCORE_DAY then
        local params = {}
        params.category = params.category or "UI"
        params.sub_category = "ms_1810_login_start"
        params.signDay = signDay
        DcUtil:UserTrack(params)
        return
    end

    local function onSuccess()
        SuccessAlert:create()

        local params = {}
        params.category = params.category or "UI"
        params.sub_category = "ms_1810_login_get_reward"
        params.signDay = signDay
        DcUtil:UserTrack(params)
    end

    local GetReward = defineHttp("activityReward")
    local http = GetReward.new(true)
    http:ad(Events.kComplete, onSuccess)
    -- http:ad(Events.kError, onFail)
    -- http:ad(Events.kCancel, onCancel) 
    local data = {};
    data.actId = 5000
    data.rewardId = 4
    http:syncLoad( data )
end

function MarkPanelMinshengPlugin:_updateTxt(panel)
    panel.txtMinsheng = panel.ui:getChildByName("txtMinshengInfo")
    panel.txtMinsheng:setString("累计签到28天，领民生银行1万信用卡积分~")
end

function MarkPanelMinshengPlugin:init(panel)
    if not MarkPanelMinshengPlugin:isEnabled() then
        return 
    end
    MarkPanelMinshengPlugin:_updateTxt(panel)
    table.insert(panel.markRewards[MarkPanelMinshengPlugin.BANK_SCORE_DAY].rewards,{itemId=MarkPanelMinshengPlugin.BANK_SCORE_ID,num = 10000})

    -- setTimeOut(function()
    --     SuccessAlert:create()
    --     end,0.2
    --     )
end

function MarkPanelMinshengPlugin:needShowEnergyTip(signDay,curCycle)
    if not MarkPanelMinshengPlugin:isEnabled() then
        return 
    end
    local key = "MarkPanelMinshengEnergyTip"
    local index = CCUserDefault:sharedUserDefault():getIntegerForKey(key)
    print("MarkPanelMinshengPlugin:needShowEnergyTip",signDay,curCycle,index)
    if signDay~=0 then
        return
    end
    if index==curCycle+1 then
        return false
    end
    CCUserDefault:sharedUserDefault():setIntegerForKey(key, curCycle+1)
    CCUserDefault:sharedUserDefault():flush()
    return true
end


-- successAlert
SuccessAlert = class(BasePanel)

local STR_SUCCESS = "恭喜！已达成签到条件，可以获得民生银行信用卡10000积分奖励啦！\n\n"..
-- "奖励将由民生银行于72小时内通过短信为您发放，您可前往民生银行“全民生活”App查看及使用信用卡积分。（具体积分兑换及使用规则，以民生银行相关活动说明为准）"
"您可在3个工作日后，前往“‘民生信用卡’公众号—优惠—我的特权”或“民生银行‘全民生活‘App—福利社”领取积分。（具体积分兑换及使用规则，以民生银行相关活动说明为准）"

function SuccessAlert:create()
    print("MarkPanelMinsheng--SuccessAlert:create()")
    local a = SuccessAlert.new()
    a:init()
    a:popout()
    return a
end

function SuccessAlert:init(  )
    self:loadRequiredResource(PanelConfigFiles.panel_mark)
    self.ui = self:buildInterfaceGroup("MinshengScore")
    BasePanel.init(self, self.ui)

    local childs = {
        "txtInfo",
        "btnClose",
        "imgOK",
        "btnOK",
    }
    for i,v in ipairs(childs) do
        self[v] = self.ui:getChildByName(v)
    end

    local function setBtnOnClick(key,callback)
        local item = self[key]
        if not item or not callback then
            printx(0,"ERR!Can not reg btnClick:"..tostring(key).."-"..tostring(callback).."---"..debug.traceback())
            return
        end
        item:setTouchEnabled(true,0, false)
        item:setButtonMode(true)
        item:addEventListener(DisplayEvents.kTouchTap, callback)
    end

    -- self.txtInfo:setDimensions(CCSizeMake( 600 , 0))
    self.txtInfo:setString(STR_SUCCESS)

    local function onClose()
        self:onClose()
    end

    -- setBtnOnClick("btnOK",onClose)
    setBtnOnClick("btnClose",onClose)

    local tmpBtn = GroupButtonBase:create(self.imgOK)
    tmpBtn:setString("确定")
    tmpBtn:ad(DisplayEvents.kTouchTap, function () 
        self:onClose()
    end)
end

function SuccessAlert:onClose()
    self.allowBackKeyTap = false
    PopoutManager:sharedInstance():remove(self,true)
end

function SuccessAlert:closeBackKeyTap()
    self.allowBackKeyTap = false
end

function SuccessAlert:popout()
    self.allowBackKeyTap = true
    self:scaleAccordingToResolutionConfig()
    self:setPositionForPopoutManager()
    PopoutManager:sharedInstance():add( self, true)
end

function SuccessAlert:onKeyBackClicked(...)
    if self.allowBackKeyTap then
        self:onClose()
    end
end


