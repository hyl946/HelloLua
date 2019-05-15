--IOS前置更新面板
require "zoo.util.NewVersionUtil"
require "zoo.util.ReachabilityUtil"
require "zoo.net.Localhost"

local iosShortVersionKey = "animal_apple_short_ver_9"
local alertNumKey = "animal_apple_update_alert_num_8"
local alertVersionKey = "animal_apple_update_alert_verion_6"
local iosReleaseNotesKey = "animal_apple_update_note_41"
local preAlertDateKey = "animal_apple_update_date_90"
local instance = nil

UpdateCheckUtils = class()
local m = UpdateCheckUtils
local userDefault = CCUserDefault:sharedUserDefault()
local ver
local alertNum = userDefault:getIntegerForKey(alertNumKey, 0)
local currVer = userDefault:getStringForKey(iosShortVersionKey, "")
local lvs
local releaseNote = userDefault:getStringForKey(iosReleaseNotesKey, "")
local preAlertDate = userDefault:getIntegerForKey(preAlertDateKey, 0)
local today = tonumber(os.date("%y%m%d", Localhost:timeInSec()))

function m:getInstance()
	if not instance then instance = UpdateCheckUtils.new() end
	return instance
end

function m:ctor()
	if _G.isLocalDevelopMode then printx(0, "=========== ucu init ===========") end
end

function m:run()
    -- local isAlerted = today <= preAlertDate
    local isAlerted = false
	if __IOS and not __IOS_FB and not isAlerted then
        ver = AppController:getBundleShortVersion()
        lvs = ver:split(".")

		if MaintenanceManager:getInstance():isEnabled("NewVersionNotice") then
			if currVer and currVer ~= "" and currVer ~= "nil" then -- read from cache
		        if self:checkVersion(currVer) then
		            if _G.isLocalDevelopMode then printx(0, "check local Version>>>>>>>>>>>>>>") end
		            -- if self:checkAlertNum() then
		                self:showUpdateConfirm()
		                return
		            -- end
		        end
		    end
		    self:requestNewVersion()
		end
	end
end

function m:checkVersion(v)
	if _G.isLocalDevelopMode then printx(0, "checkVersion>>>>>>>>>>>>>>", ver, v) end
    local nvs = v:split(".")

    if #lvs == #nvs then
        for i = 1, #lvs do
            if tonumber(nvs[i]) > tonumber(lvs[i]) then return true end
        end
    end
    return false
end

function m:checkAlertNum()
    local checkver = userDefault:getStringForKey(alertVersionKey, "")
    if checkver ~= "" then
        if checkver == currVer then
            if alertNum < 3 then
                if _G.isLocalDevelopMode then printx(0, "check alert num>>>>>>>>>>>>>", alertNum) end
                userDefault:setIntegerForKey(alertNumKey, alertNum + 1)
                userDefault:flush()
                return true
            else
                if _G.isLocalDevelopMode then printx(0, "check alert num over 3 time>>>>>>>>>") end
                return false
            end
        end
    end
    userDefault:setStringForKey(alertVersionKey, currVer)
    userDefault:setIntegerForKey(alertNumKey, 1)
    userDefault:flush()
    if _G.isLocalDevelopMode then printx(0, "check alert num>>>>>>>>>>>>>new version") end
    return true
end

function m:dc(subCategory, dcData )
    if type(dcData) ~= "table" then
        dcData = {}
    end
    dcData.category = "update"
    dcData.sub_category = subCategory

    -- DcUtil:log(AcType.kExpire30Days, dcData)
    DcUtil:UserTrack(dcData)
end

function m:showUpdateHelp()
    local res = 'ui/appleStoreGuide.json'

    local function onClose()
        if self.helpPanel then
            self.helpPanel:removeFromParentAndCleanup(true)
        end
        self.helpPanel = nil
    end

    local function popoutHelp(panel)
        local size = panel:getGroupBounds().size
        local posAdd = _G.__EDGE_INSETS.top
        local vSize = CCDirector:sharedDirector():getVisibleSize()
        -- local tx,ty = (vSize.width-size.width)*0.5 ,(vSize.height-size.height )*0.5+posAdd
        local tx,ty = (vSize.width-size.width)*0.5 ,(vSize.height+size.height )*0.5+posAdd
        print(vSize.height,size.height ,posAdd,ty)
        panel:setPositionXY(tx, ty)
        self.helpPanel = panel
        panel.onClose = onClose
        panel.onKeyBackClicked = onClose
        local playUI = Director:sharedDirector():getRunningScene()
        if playUI and playUI:is(HomeScene) then
            playUI:addChild(panel, "topLayer")
        else
            playUI:addChildAt(panel,99)
        end

        local darkLayer = LayerColor:create()
        darkLayer:setOpacity( 10 )
        darkLayer:setContentSize(vSize)
        darkLayer:setPositionXY(-tx,-ty)
        darkLayer:setTouchEnabled(true, 0, true)
        panel:addChildAt(darkLayer,-1)
        panel.darkLayer = darkLayer
    end

    local builder = InterfaceBuilder:createWithContentsOfFile(res)
    local ui = builder:buildGroup('AppleStoreGuide')
    local size = ui:getGroupBounds().size

    local CFG_TXT = {
        "txtTitle","版本更新",
        "leftBtnLabel","以后",
        "rightBtnLabel","去更新",
        "txt1","第一步：打开手机中的【App Store】",
        "txt2","第二步：点击【App Store】右下 【更新】按钮。",
        "txt3","第三步：【手动下拉】待更新列表，刷新完成、圈圈消失后，查看【待更新列表项目】。\n\n"..
            "第四步：在待更列表中找到【开心消消乐】。\n\n"..
            "第五步：找到游戏，点击【更新】。更新完进入游戏就可以领取奖励啦~",v
    }
    for i,v in ipairs(CFG_TXT) do
        if i%2 == 1 then
            ui:getChildByName(v):setString(CFG_TXT[i+1])
        end
    end

    local function setBtnOnClick(key,callback)
        local item = ui:getChildByName(key)
        item:setTouchEnabled(true,0, false)
        item:setButtonMode(true)
        item:addEventListener(DisplayEvents.kTouchTap, callback)
    end

    local net = ReachabilityUtil.getInstance():isEnableWIFI() and 1 or 2

    local function onAppleStore( ... )
        ui.onClose()

        self:dc("update_tutorial_panel",{t1=1,t2=net})

        if __IOS then
            NewVersionUtil:gotoAppleStore()
        else
            local url = "itms-apps://itunes.apple.com/app/id791532221"
            OpenUrlUtil:openUrl(url)
        end
    end

    local function onCancel()
        ui.onClose()
        InterfaceBuilder:unloadAsset(res)

        self:dc("update_tutorial_panel",{t1=2,t2=net})
    end

    setBtnOnClick("leftHotArea",onCancel)
    setBtnOnClick("rightHotArea",onAppleStore)

    popoutHelp(ui)

    return ui
end

function m:showUpdateConfirm()
	-- if ReachabilityUtil.getInstance():isEnableWIFI() then 
	    local function onUIAlertViewCallback( alertView, buttonIndex )
            local net = ReachabilityUtil.getInstance():isEnableWIFI() and 1 or 2
	        if buttonIndex == 1 then
                self:dc("confirm_alert", {t1 = "1",t2 = net})
	            NewVersionUtil:gotoAppleStore()

                self:showUpdateHelp()
            else
                self:dc("confirm_alert", {t1 = "2",t2 = net})
	        end
	    end
	    local title = Localization:getInstance():getText("new.version.dynamic.title")
	    local okLabel = Localization:getInstance():getText("new.version.ios.notice.confirm")
	    local cancelLabel = Localization:getInstance():getText("new.version.ios.notice.later")
	    local UIAlertViewClass = require "zoo.util.UIAlertViewDelegateImpl"
	    local alert = UIAlertViewClass:buildUI(title, releaseNote, cancelLabel, onUIAlertViewCallback)
	    alert:addButtonWithTitle(okLabel)
	    alert:show()

        self:dc("show_alert")

        preAlertDate = today
        userDefault:setIntegerForKey(preAlertDateKey, today)
        userDefault:flush()
	-- end
end

function m:requestNewVersion()
    if _G.isLocalDevelopMode then printx(0, "requestNewVersion>>>>>>>>>>>>>>") end
    -- if ReachabilityUtil.getInstance():isEnableWIFI() then  
        if _G.isLocalDevelopMode then printx(0, "start check, local:", ver) end
        local function onCheckResponse( response )
            if response.httpCode == 200 then
                local message = response.body
                if _G.isLocalDevelopMode then printx(0, "check response:", message) end
                
                local json  = table.deserialize(message)
                if json and json.results and #json.results > 0 then
                    currVer = json.results[1].version or "0.0.0"
                    releaseNote = json.results[1].releaseNotes or ""
                    local s = string.find(releaseNote, "\n")
                    if s then
                        releaseNote = string.sub(releaseNote, 1, s)
                    end

                    --currVer = "1.1.13"
                    if _G.isLocalDevelopMode then printx(0, "requestNewVersion>>>>>>>>>>>>>>", currVer) end
                    userDefault:setStringForKey(iosShortVersionKey, currVer)
                    userDefault:setStringForKey(iosReleaseNotesKey, releaseNote)
                    userDefault:flush()

                    if self:checkVersion(currVer) then
                        -- if self:checkAlertNum() then
                            self:showUpdateConfirm()
                        -- end
                    end
                end
            end
        end

        local url = "http://itunes.apple.com/cn/lookup?id=791532221&t="..os.time()
        local timeout = 2000
        local request = HttpRequest:createGet(url)

        if __WP8 then
            request:setConnectionTimeoutMs(5 * 1000)
            timeout = 3000
        else
            request:setConnectionTimeoutMs(timeout)
        end

        request:setTimeoutMs(timeout * 10)
        HttpClient:getInstance():sendRequest(onCheckResponse, request)
    -- end
end

