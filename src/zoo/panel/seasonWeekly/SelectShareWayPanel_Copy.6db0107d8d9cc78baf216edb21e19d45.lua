
local BaseBottomPanel_Copy = class(BasePanel)

function BaseBottomPanel_Copy:_close()

	if self.isDisposed then return end

	self.allowBackKeyTap = false

	local panelSize = self.ui:getGroupBounds(self).size
	local panelWidth = panelSize.width
	local panelHeight = panelSize.height

	self:runAction(CCSequence:createWithTwoActions(
		CCEaseSineIn:create(CCMoveBy:create(0.3, ccp(0, 10-panelHeight))),
		CCCallFunc:create(function ( ... )
			PopoutManager:sharedInstance():remove(self)
		end)
	))

end

function BaseBottomPanel_Copy:isWxShare(eType)
    if eType == PlatformShareEnum.kWechat or
        eType == PlatformShareEnum.kSYS_WECHAT then
            return true
        end
    return false
end

function BaseBottomPanel_Copy:wxInstallAlter(eType)
    if self:isWxShare(eType) and not SnsProxy:isWXAppInstalled() then
        return true
    end
    return false
end

function BaseBottomPanel_Copy:share2Persion(webpageUrl, thumbUrl, successCallback, failCallback, cancelCallback)
    local function noShareJustReturn()
        -- if __WIN32 and successCallback then return successCallback() end
        if failCallback then failCallback() end return
    end

    if __WIN32 then
        noShareJustReturn()
    end

    local share2TimeLine = false
    local eShareType = SnsUtil.getShareType()

    webpageUrl = webpageUrl or ""
    local title = localize('SpringFestival2019.share.for.freeplay.title')
    local message = localize('SpringFestival2019.share.for.freeplay.message')
    local amILowDev = Misc:isLowDevice()

    local shareCallback = {
        onSuccess = function(result)
            -- CommonTip:showTip(localize('SpringFestival2019.share.for.freeplay.success'), 'positive')
            if amILowDev then return end
            if successCallback then successCallback() end
        end,
        onError = function(errCode, msg)
            -- CommonTip:showTip('分享失败')
            if amILowDev then return end
            if failCallback then failCallback(1) end
        end,
        onCancel = function()       
            -- CommonTip:showTip('分享取消')
            if amILowDev then return end
            if cancelCallback then cancelCallback(2) end
        end
    }

    if amILowDev then
        if successCallback then successCallback() end
        return
    end

    if self:wxInstallAlter(eShareType) then
        setTimeOut(function ( ... ) CommonTip:showTip('未安装微信，分享失败了~', 'negative') end, 0.001)
        if failCallback then failCallback(1) end
        return
    end

    local isSend2FriendCircle = false
    SnsUtil.sendLinkMessage(eShareType, title, message, thumbUrl, webpageUrl, isSend2FriendCircle, shareCallback)
end
function BaseBottomPanel_Copy:popout()

	local visibleSize = CCDirector:sharedDirector():getVisibleSize()
	local visibleOrigin = CCDirector:sharedDirector():getVisibleOrigin()

	local panelSize = self.ui:getGroupBounds(self).size
	local panelWidth = panelSize.width
	local panelHeight = panelSize.height

	self:setPositionX(visibleOrigin.x + (visibleSize.width - panelWidth)/2)
	self:setPositionY(- visibleSize.height)
	-- self:setPositionY(panelHeight - visibleSize.height)

	self:runAction(CCEaseSineOut:create(CCMoveBy:create(0.3, ccp(0, panelHeight - 10))))

	PopoutManager:sharedInstance():add(self, true)
	self.allowBackKeyTap = true
end

function BaseBottomPanel_Copy:onCloseBtnTapped( ... )
    self:_close()
end


local SelectShareWayPanel_Copy = class(BaseBottomPanel_Copy)

function SelectShareWayPanel_Copy:create()
    local panel = SelectShareWayPanel_Copy.new()
	panel:loadRequiredResource("ui/SelectShareWayPanel2.json")
    panel:init()
    return panel
end

function SelectShareWayPanel_Copy:init()
    local ui = self:buildInterfaceGroup("SelectShareWayPanel2/select/select")

	BaseBottomPanel_Copy.init(self, ui)


    self.closeBtn = self.ui:getChildByName('closeBtn')
    self.closeBtn:setTouchEnabled(true, 0, true)
    self.closeBtn:ad(DisplayEvents.kTouchTap, function () self:onCloseBtnTapped() end)

    self.btn1 = self.ui:getChildByName('btn1')
    self.btn2 = self.ui:getChildByName('btn2')
    self.btn3 = self.ui:getChildByName('btn3')
    -- self.friendsBtn.label = self.friendsBtn:getChildByName('label')
    -- self.feedsBtn.label = self.feedsBtn:getChildByName('label')

    local uid = UserManager.getInstance().user.uid or "00"
	local uidGroup = tonumber(string.sub(tostring(uid), -2)) or 0
	local useGroup1 = true
	if uidGroup >= 0 and uidGroup < 50 then 
		useGroup1 = false
	end

	-- if useGroup1 then 
		-- self.friendsBtn.label:setString("微信好友")
		-- self.feedsBtn.label:setString("朋友圈")
	-- else
	-- 	self.friendsBtn.label:setString("分享给好友")
	-- 	self.feedsBtn.label:setString("更多人可见")
	-- end

	-- self.friendsBtn:setTouchEnabled(true)
	-- self.feedsBtn:setTouchEnabled(true)

	-- self.friendsBtn:ad(DisplayEvents.kTouchTap, function ( ... )
	-- 	self:_close()
		-- if self.btn1_cb then
		-- 	self.btn1_cb()
		-- end
	-- end)
	-- self.feedsBtn:ad(DisplayEvents.kTouchTap, function ( ... )
	-- 	self:_close()
		-- if self.btn2_cb then
		-- 	self.btn2_cb()
		-- end
	-- end)


	UIUtils:setTouchHandler(  self.ui:getChildByPath('btn1') , function ()

        local dcData = {}
        dcData.category = "AddFriend"
        dcData.sub_category = "addfriend_click_copy"
        DcUtil:log(AcType.kUserTrack, dcData, true)
        if self.btn1_cb then
			self.btn1_cb()
		end
        self:_close()
     end)

	UIUtils:setTouchHandler(  self.ui:getChildByPath('btn2') , function ()
        if self.btn2_cb then
			self.btn2_cb()
		end
        local dcData = {}
        dcData.category = "AddFriend"
        dcData.sub_category = "addfriend_click_wx"
        DcUtil:log(AcType.kUserTrack, dcData, true)
        self:_close()
     end)

	UIUtils:setTouchHandler(  self.ui:getChildByPath('btn3') , function ()
        if self.btn3_cb then
			self.btn3_cb()
		end
        local dcData = {}
        dcData.category = "AddFriend"
        dcData.sub_category = "addfriend_click_qq"
        DcUtil:log(AcType.kUserTrack, dcData, true)
        self:_close()
     end)

end


function SelectShareWayPanel_Copy:popout(btn1_cb, btn2_cb , btn3_cb )
	self.btn1_cb = btn1_cb
	self.btn2_cb = btn2_cb
	self.btn3_cb = btn3_cb
    BaseBottomPanel_Copy.popout(self)
end

return SelectShareWayPanel_Copy
