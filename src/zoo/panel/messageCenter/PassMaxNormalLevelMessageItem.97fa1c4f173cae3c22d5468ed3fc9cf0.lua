

function PassMaxNormalLevelMessageItem:init()
    self._isInRequest = false
    self._hasCompleted = false

    local ui = self.builder:buildGroup("request_message_panel/PassLastLevelCell")
    ItemInClippingNode.init(self)
    self:setContent(ui)
    self.ui = ui
    self.avatar_ico = ui:getChildByName("avatar"):getChildByName("icon")
    self.name_text = ui:getChildByName("name_text")
    self.msg_text = ui:getChildByName("msg_text")

    self.cancel = ui:getChildByName("cancel")
    self.cancel:setButtonMode(true)
    self.cancel:setTouchEnabled(true)
    self.cancel.setEnabled = self.cancel.setTouchEnabled
    self.confirm = ButtonIconsetBase:create(ui:getChildByName("confirm_button"))
    self.confirm:setColorMode(kGroupButtonColorMode.green)
    -- self.confirm:setString("答谢")

    self.selected = ui:getChildByName("selected")
    self.selected:setVisible(false)

    self.ignoredTxt = ui:getChildByName('ignoredTxt')
    self.ignoredTxt:setString(Localization:getInstance():getText('message.center.disagree.already.text'))
    self.ignoredTxt:setVisible(false)

    -- self:addChild(ui)
    -- local size = self.ui:getGroupBounds().size
    self:setHeight(180) 
    self:buildSyncAnimation()

    local function onTouchCancel(event) self:sendIgnore(false) end
    local function onTouchConfirm(event) 
        DcUtil:UserTrack({
            category = "message",
            sub_category = "message_center_challenge_flower",   
        },true)

        if self.panel then 
            self.panel:setFocusedItem(self)
        end 
        self:sendAccept(false)
    end
    self.cancel:ad(DisplayEvents.kTouchTap, onTouchCancel)
    self.confirm:ad(DisplayEvents.kTouchTap, onTouchConfirm)

end

function PassMaxNormalLevelMessageItem:dispose( ... )
    RequestMessageItemBase.dispose(self)

    if self.getFirstPassLevelUidComplete then
        GlobalEventDispatcher:getInstance():removeEventListener(
            MessageCenterPushEvents.kGetFirstPassLevelUidComplete,
            self.getFirstPassLevelUidComplete       
        )
    end
end

function PassMaxNormalLevelMessageItem:setData(requestInfo)
    RequestMessageItemBase.setData(self, requestInfo)
    self.senderUid = requestInfo.senderUid
    self.levelId = tonumber(requestInfo.itemId)
    -- self.confirm:setString(localize('message_flower_button'))
    self.confirm:setIconByFrameName("common_icon/sns/icon_zan0000")
    self.confirm:setString("赞")
    self.msg_text:setString(localize('request.message.panel.news.text4', {num = self.levelId}))
    
    local function setBg( isFirst )
        self.ui:getChildByName("bg"):setVisible(isFirst)
        self.ui:getChildByName("shine"):setVisible(isFirst)
        self.ui:getChildByName("bg2"):setVisible(not isFirst)
    end

    local firstPassLevelUid = FreegiftManager:sharedInstance():getFirstPassLevelUid(self.levelId)

    if firstPassLevelUid and firstPassLevelUid == self.senderUid then
        setBg(true)
    else
        setBg(false)
    end

    if not firstPassLevelUid then
        self.getFirstPassLevelUidComplete = function( evt )
            local uid = evt.data
            if self.senderUid and tostring(self.senderUid) == tostring(uid) then
                setBg(true)
            end
        end

        GlobalEventDispatcher:getInstance():addEventListener(
            MessageCenterPushEvents.kGetFirstPassLevelUidComplete,
            self.getFirstPassLevelUidComplete
        )
    end

end