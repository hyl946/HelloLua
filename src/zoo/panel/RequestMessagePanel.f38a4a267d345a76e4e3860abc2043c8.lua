require "zoo.util.NewVersionUtil"
require "zoo.panel.component.common.LayoutItem"
require "zoo.data.FreegiftManager"

EnergyRequestItemMode = {kAcceptRequest = 1, kReceive = 2, kSendBack = 3}

require 'zoo.panel.messageCenter.RequestMessageItems'
require 'zoo.panel.messageCenter.PassMaxNormalLevelMessageItem'
require 'zoo.panel.messageCenter.ThanksMessageItem'

require 'zoo.panel.messageCenter.RequestMessageZeroItem'
require 'zoo.panel.messageCenter.RequestMessagePanelTab'
require 'zoo.panel.messageCenter.RequestMessagePage'

require 'zoo.panel.messageCenter.AskForHelpPanel'

local PanelConfig = require 'zoo.panel.messageCenter.PanelConfig'
--------------------------------------------------------------------------------
-- RequestMessagePanel ---------------------------------------------------------
--------------------------------------------------------------------------------
RequestMessagePanel = class(LayerGradient)

function RequestMessagePanel:create()
    local winSize = CCDirector:sharedDirector():getWinSize()
    local ret = RequestMessagePanel.new()
    ret:loadRequiredResource(PanelConfigFiles.request_message_panel)
    ret:initLayer()
    ret:init()
    ret:changeWidthAndHeight(winSize.width, winSize.height)
    -- ret:setColor(ccc3(255,255,205)) --#FFFFCD
    ret:setStartColor(ccc3(255, 216, 119))
    ret:setEndColor(ccc3(247, 187, 129))
    ret:setStartOpacity(255)
    ret:setEndOpacity(255)
    ret:buildUI()

    ret:switchPage(true)
    
    return ret
end

function RequestMessagePanel:init()
    self.pendingRequestCount = 0 
    self.processableMessageCount = 0 -- 未处理完的消息数量（回赠时，可回赠算未处理完；不可回赠算处理完）
    self.listAnimPlayItemCount = 0
    self.pageMessageCount = {}

    kDailyMaxReceiveGiftCount = MetaManager:getInstance():getDailyMaxReceiveGiftCount() or 10
    kDailyMaxSendGiftCount = MetaManager:getInstance():getDailyMaxSendGiftCount() or 20
    local newestCfg = Localhost.getInstance():getUpdatedGlobalConfig()
    if newestCfg and newestCfg.dailyMaxSendGiftCount then
        kDailyMaxSendGiftCount = newestCfg.dailyMaxSendGiftCount
    end
    if newestCfg and newestCfg.dailyMaxReceiveGiftCount then
        kDailyMaxReceiveGiftCount = newestCfg.dailyMaxReceiveGiftCount
    end

    self.hasRunGuide = CCUserDefault:sharedUserDefault():getBoolForKey('panel.request.message.hasRunGuide')
    self.hasRunRewardGuide = CCUserDefault:sharedUserDefault():getBoolForKey('panel.request.message.hasRunRewardGuide')

    self:runAction(CCCallFunc:create(function()
        -- local achiValue = UserManager:getInstance().userExtend
        --             :getAchievementValue(AchievementManager.shareId.GET_POPULARITY) or 0
        -- AchievementManager:onDataUpdate(AchievementManager.GET_POPULARITY,achiValue)
    end))
end

function RequestMessagePanel:buildInterfaceGroup(groupName)
    if self.builder then return self.builder:buildGroup(groupName)
    else return nil end
end

function RequestMessagePanel:loadRequiredResource(panelConfigFile)
    self.panelConfigFile = panelConfigFile
    self.builder = InterfaceBuilder:createWithContentsOfFile(panelConfigFile)
end

function RequestMessagePanel:unloadRequiredResource()
    if self.panelConfigFile then
        InterfaceBuilder:unloadAsset(self.panelConfigFile)
    end
end

function RequestMessagePanel:dispose()
    LayerColor.dispose(self)
    if type(self.unloadRequiredResource) == "function" then self:unloadRequiredResource() end
end

function RequestMessagePanel:buildUI()
    local ui = self:buildInterfaceGroup("request_panel")
    ui:getChildByName("item"):removeFromParentAndCleanup(true)

    local winSize = CCDirector:sharedDirector():getVisibleSize()
    local origin = CCDirector:sharedDirector():getVisibleOrigin()

    local realSize = CCDirector:sharedDirector():ori_getVisibleSize()
    local realOrigin = CCDirector:sharedDirector():ori_getVisibleOrigin()
    self:setPosition(ccp(realOrigin.x, realOrigin.y))

    local topHeight = 170
    local top = ui:getChildByName("top")
    top:setPositionY(realSize.height)
    local title = top:getChildByName("title")
    title:setText(localize("message.center.tittle"))
    local titleSize = title:getContentSize()
    local titleScale = 65 / titleSize.height
    title:setScale(titleScale)
    title:setPositionX((realSize.width - titleSize.width * titleScale) / 2)
    title:setPositionY(title:getPositionY() - _G.__EDGE_INSETS.top * 0.4)
    self.closeBtn = top:getChildByName("close")
    self.closeBtn:setPositionY(self.closeBtn:getPositionY() - _G.__EDGE_INSETS.top * 0.6)
    local paramObj = {send = kDailyMaxSendGiftCount, receive = kDailyMaxReceiveGiftCount}
    local bottom = ui:getChildByName("bottom")
    local bottomHeight = 130 + _G.__EDGE_INSETS.bottom
    bottom:setPositionY(bottomHeight)
    local acceptAllButton = GroupButtonBase:create(bottom:getChildByName("confirm")) 
    acceptAllButton:setString(localize("message.center.agree.all.btn"))
    acceptAllButton:setColorMode(kGroupButtonColorMode.blue)
    self.acceptAllButton = acceptAllButton
    local rejectAllButton = GroupButtonBase:create(bottom:getChildByName("cancel"))
    rejectAllButton:setString(localize("message.center.disagree.all.btn"))
    rejectAllButton:setColorMode(kGroupButtonColorMode.orange)
    self.rejectAllButton = rejectAllButton
    local shareRequestButton = GroupButtonBase:create(bottom:getChildByName("share"))
    shareRequestButton:setString(localize("message.center.share.request.btn"))
    self.shareRequestButton = shareRequestButton

    self.bottomCloseBtn = GroupButtonBase:create(bottom:getChildByName("close"))
    self.bottomCloseBtn:setString('关闭') -- TODO
    self.bottomCloseBtn:setVisible(false)
    self.bottomCloseBtn:setEnabled(false)

    local addBg = ui:getChildByName("viewRect")
    local size = addBg:getPreferredSize()
    addBg:setPreferredSize(CCSizeMake(size.width, realSize.height - bottomHeight - topHeight + 20))
    addBg:setPositionY(addBg:getPositionY() + realSize.height)

    self.requestTip = bottom:getChildByName("requestTip")
    self.requestTip:setString(FreegiftManager:sharedInstance():getHelpRequestTip())
    self.requestTip:setVisible(false)

    self.customTip = bottom:getChildByName("customTip")
    self.customTip:setVisible(false)

    self:addChild(ui)

    local tabConfig, pageConfig = PanelConfig:getConfig()
    self.tabConfig = tabConfig
    self.pageConfig = pageConfig
    
    local listHeight = realSize.height - bottomHeight - topHeight

    local tab = RequestMessagePanelTab:create(tabConfig)
    tab:setPositionXY(0, realSize.height - topHeight - 0)
    self:addChild(tab)
    self.tabs = tab

    local pagedView = PagedView:create(realSize.width - 36, listHeight - 80, #pageConfig, tab, true, false)
    pagedView.pageMargin = 35
    pagedView:setIgnoreVerticalMove(false) -- important!
    tab:setView(pagedView)
    pagedView:setPosition(ccp(36/2, bottomHeight + 10))
    local function switchCallback() self:switchPage() end
    local function switchFinishCallback() self:switchPageFinish(listHeight - 70) end
    pagedView:setSwitchPageCallback(switchCallback)
    pagedView:setSwitchPageFinishCallback(switchFinishCallback)
    self:addChild(pagedView)
    self.pagedView = pagedView

    self:createPages(pageConfig, realSize.width - 36, listHeight - 70)
    if not self:switchToFirstNonZeroPage() then
        self:setButtonsVisibleEnable(1)
    end
    -- self:switchPageFinish(listHeight - 70)

    local function onCloseTapped()
        local canSend, remainSend = FreegiftManager:sharedInstance():canSendMore()
        DcUtil:UserTrack({category='add_friend', sub_category='left_send_free_num', num = remainSend})
        
        Director:sharedDirector():popScene()
        if self.closeCallback then
            self.closeCallback()
        end
    end
    self.closeBtn:setTouchEnabled(true)
    self.closeBtn:setButtonMode(true)
    self.closeBtn:ad(DisplayEvents.kTouchTap, onCloseTapped)

    local function onTouchCancel( evt )
        rejectAllButton:setEnabled(false)
        self:cancelAll()
    end
    local function onTouchConfirm( evt )
        acceptAllButton:setEnabled(false)
        self:acceptAll()
    end
    local function onTouchShareRequest(evt)
        self:shareRequest()
    end
    local function onTouchClose( evt )
        onCloseTapped()
    end

    rejectAllButton:ad(DisplayEvents.kTouchTap, onTouchCancel)
    acceptAllButton:ad(DisplayEvents.kTouchTap, onTouchConfirm)
    shareRequestButton:ad(DisplayEvents.kTouchTap, onTouchShareRequest)
    self.bottomCloseBtn:ad(DisplayEvents.kTouchTap, onTouchClose)




    return true
end

function RequestMessagePanel:shareRequest()
    if self.shareRequestButton.inClk then
        return
    end

    self.shareRequestButton.inClk = true
    local panel = GoToAddFriendPanel:create({GoToAddFriendPanel.FUNC_TYPE.ENERGY, GoToAddFriendPanel.ACTION_TYPE.SHARE})
    panel:popout()
    self.shareRequestButton.inClk = false
end

function RequestMessagePanel:switchToFirstNonZeroPage()
    for k, v in ipairs(self.layers) do
        local list = v:getChildByName("list")
        if list and not list.isDisposed then
            local layout = list:getContent()
            local toDelete = {}
            local content = layout:getItems()
            if type(content) == "table" and #content > 0 then
                self.pagedView:gotoPage(k)
                -- 防止进入按钮闪一下，提前设置
                self:setButtonsVisibleEnable(k)
                return true
            end
        end
    end
    return false
end

function RequestMessagePanel:gotoUnlockPage()
    local pageIndex = 0
    for k, v in pairs(self.tabConfig) do
        if v.pageName == 'unlock' then
            pageIndex = v.pageIndex
            break
        end
    end
    if pageIndex > 0 then
        self.pagedView:gotoPage(pageIndex)
    end
end

function RequestMessagePanel:gotoPage(pageName)
    if not pageName then return end
    local pageIndex = 0
    for k, v in pairs(self.tabConfig) do
        if v.pageName == pageName then
            pageIndex = v.pageIndex
            break
        end
    end
    if pageIndex > 0 then
        self.pagedView:gotoPage(pageIndex)
    end
end

function RequestMessagePanel:createPages(pageConfig, width, height)
    self.layers = {}
    for k, v in ipairs(pageConfig) do
        local content = {
            normalMessages = FreegiftManager:sharedInstance():getMessages(v.msgType),
            pushMessages = FreegiftManager:sharedInstance():getPushMessages(v.msgType),
        }

        


        for _, mergedType in ipairs(MergedMessageType) do
            local mergedMsgs = table.filter(content.normalMessages, function ( v )
                return v.type == mergedType
            end)
            if #mergedMsgs >= 3 then
                content.normalMessages = table.filter(content.normalMessages, function ( v )
                    return v.type ~= mergedType
                end)
                table.insert(content.normalMessages, {requestInfoGrp = mergedMsgs, type = -mergedType})
            end
        end


        if v.pageName == 'askforhelp' then
            table.sort(content.normalMessages, function (a, b)
		    	if a.itemId == b.itemId then
                    local friends = FriendManager.getInstance().friends or {}
			        local lProfile = friends[tostring(a.senderUid)] or {}
                    local lhs = lProfile.updateTime or 0
                    local rProfile = friends[tostring(b.senderUid)] or {}
                    local rhs = rProfile.updateTime or 0
                    if lhs == rhs then
                        return tostring(a.senderUid) > tostring(b.senderUid)
                    else
                        return lhs > rhs
                    end
		    	else
		    	 	return a.itemId < b.itemId
		    	end
		    end)
        end
        local layer = RequestMessagePage:create(self, v, content, width, height)
        if v.pageName == 'energy' then
            self.energyItems = layer:getItems()
        end
        self.pagedView:addPageAt(layer, k)
        self.layers[k] = layer

        -- 统计所有消息数
        self.pageMessageCount[v.pageIndex] = 0
        for k1, v1 in pairs(content.normalMessages) do
            self.processableMessageCount = self.processableMessageCount + 1
            self.pageMessageCount[v.pageIndex] = self.pageMessageCount[v.pageIndex] + 1
        end
        for k, v1 in pairs(content.pushMessages) do
            self.processableMessageCount = self.processableMessageCount + 1
            self.pageMessageCount[v.pageIndex] = self.pageMessageCount[v.pageIndex] + 1
        end

    end
end

function RequestMessagePanel:removeCurrentPage(playAnimation)
    self:removePageAt(self.pagedView:getPageIndex(), playAnimation)
end

function RequestMessagePanel:removePageAt(index, playAnimation)
    if self.layers[index] == nil then return end
    self.pagedview:removePageAt(index, playAnimation)
    table.remove(self.layers, index)
end

function RequestMessagePanel:switchPage(refreshCurPage)
    self.rejectAllButton:setVisible(false)
    self.acceptAllButton:setVisible(false)
    self.shareRequestButton:setVisible(false)
    self.shareRequestButton:setEnabled(false)
    self.requestTip:setVisible(false)
    self.customTip:setVisible(false)

    local index = self.pagedView:getPageIndex()
    for k, v in ipairs(self.layers) do
        if refreshCurPage or k ~= index then
            local left = 0
            local content = FreegiftManager:sharedInstance():getMessages(self.pageConfig[k].msgType)
            local list = v:getChildByName("list")
            local zero = v:getChildByName("zero")
            if list and not list.isDisposed then
                local layout = list:getContent()
                local toDelete = {}
                for k2, v2 in ipairs(layout:getItems()) do
                    left = left + 1
                    v2:stopAllActions()
                    if v2:hasCompleted() then
                        left = left - 1
                        table.insert(toDelete, v2)
                    end
                    if v2:is(AskForHelpTopItem) then
                        left = left - 1
                    end
                end
                for k2, v2 in ipairs(toDelete) do
                    layout:removeItemAt(v2:getArrayIndex())
                    if v2:is(EnergyRequestItem) then
                        self.energyItems = self.energyItems or {}
                        for k3, v3 in ipairs(self.energyItems) do
                            if v3 == v2 then
                                table.remove(self.energyItems, k3)
                                break
                            end
                        end
                    end
                end
                list:updateScrollableHeight()
                list:scrollToTop()

                if left <= 0 then
                    list:setVisible(false)
                    zero:setVisible(true)
                    self.tabs:setNumber(k, 0)
                else
                    self.tabs:setNumber(k, left)
                end
            end
        end
    end
end

function RequestMessagePanel:switchPageFinish(height)
    local index = self.pagedView:getPageIndex()
    self.listAnimPlayItemCount = 0
    if self.tabConfig[index].pageName == 'unlock' and not self.hasRunGuide and UserManager:getInstance().user:getTopLevelId() <= 60 then -- 解锁
        local items = self.layers[index]:getChildByName('list'):getContent():getItems()
        if #items > 0 then
            self:tryRunGuide(items[1])
        end
    elseif self.tabConfig[index].pageName == 'news' and not self.hasRunRewardGuide and  NewVersionUtil:hasUpdateReward() then -- 解锁
        local items = self.layers[index]:getChildByName('list'):getContent():getItems()
        if #items > 0 then
            self:tryRunRewardGuide(items[1])
        end
    end

    self:setButtonsVisibleEnable(index)
end

function RequestMessagePanel:tryRunRewardGuide(item)
    if self.hasRunRewardGuide then return end
    local visibleSize   = CCDirector:sharedDirector():getVisibleSize()
    local visibleOrigin = CCDirector:sharedDirector():getVisibleOrigin()
    local panelY =  visibleOrigin.y + visibleSize.height / 2

    local panelPos = ccp(0,0)
    local maskPos = ccp(0,0)
    if item and item.confirm then
        local btn = item.confirm
        local pos = btn:getParent():convertToWorldSpace(btn:getPosition())
        panelPos = ccp(pos.x-385/0.7,pos.y-90)
        maskPos = ccp(pos.x-388/0.7,pos.y-75)
    end

    local panel = GameGuideUI:dialogue(nil, {panelName = 'guide_dialogue_updatereward', align = 'winYU', pos = 300},"点击任意处继续" )
    panel:setPosition(panelPos)
    local pos = ccp(0, 0)
    local trueMask = GameGuideUI:mask(204, 1, maskPos, 0, true, 445/0.7, 131/0.7, false)
    trueMask:removeEventListenerByName(DisplayEvents.kTouchTap)
    trueMask:ad(DisplayEvents.kTouchTap, function () self:tryRemoveReawrdGuide() end)
    trueMask:setFadeIn(0.5, 0.3)
    local layer = Layer:create()
    layer:addChildAt(trueMask,4)
    layer:addChildAt(panel,4)
    self.guideLayer = layer
    local scene = Director:sharedDirector():getRunningScene()
    if scene then
        scene:addChild(layer, SceneLayerShowKey.POP_OUT_LAYER)
    end
end

function RequestMessagePanel:tryRemoveReawrdGuide()
    if self.guideLayer and not self.guideLayer.isDisposed then
        self.guideLayer:removeFromParentAndCleanup(true)
        CCUserDefault:sharedUserDefault():setBoolForKey('panel.request.message.hasRunRewardGuide', true)
        self.hasRunRewardGuide = true
    end
end

function RequestMessagePanel:tryRunGuide(item)
    if self.hasRunGuide then return end
    local visibleSize   = CCDirector:sharedDirector():getVisibleSize()
    local visibleOrigin = CCDirector:sharedDirector():getVisibleOrigin()
    local panelY =  visibleOrigin.y + visibleSize.height / 2

    local panel = GameGuideUI:dialogue(nil, {panelName = 'guide_dialogue_request_message_panel', align = 'winYU', pos = 300} )
    panel:setPositionY(panelY)
    local pos = ccp(0, 0)
    local trueMask = GameGuideUI:mask(204, 1, pos, 0, false, nil, nil, false)
    trueMask:removeEventListenerByName(DisplayEvents.kTouchTap)
    trueMask:ad(DisplayEvents.kTouchTap, function () self:tryRemoveGuide() end)
    trueMask:setFadeIn(0.5, 0.3)
    local layer = Layer:create()
    layer:addChild(trueMask)
    layer:addChild(panel)
    self.guideLayer = layer
    local scene = Director:sharedDirector():getRunningScene()
    if scene then
        scene:addChild(layer, SceneLayerShowKey.POP_OUT_LAYER)
    end

    if item and item.confirm then
        -- local btn = item.confirm.groupNode or item.confirm
        local btn = item.confirm
        local pos = btn:getParent():convertToWorldSpace(btn:getPosition())
        btn.basePosX,btn.basePosY = btn:getPositionX(),btn:getPositionY()
        btn.baseParent = btn:getParent()
        btn:removeFromParentAndCleanup(false)
        btn.groupNode:setPositionXY(pos.x,pos.y)
        btn:setEnabled(false,true)
        layer:addChild(btn.groupNode)
        layer.btn = btn

        panel:setPositionY(pos.y-150)
    end
end

function RequestMessagePanel:tryRemoveGuide()
    if self.guideLayer and not self.guideLayer.isDisposed then
        if self.guideLayer.btn then
            local btn = self.guideLayer.btn
            btn.groupNode:setPositionXY(btn.basePosX,btn.basePosY)
            btn:removeFromParentAndCleanup(false)
            btn.baseParent:addChild(btn.groupNode)
            btn:setEnabled(true)
        end

        self.guideLayer:removeFromParentAndCleanup(true)
        CCUserDefault:sharedUserDefault():setBoolForKey('panel.request.message.hasRunGuide', true)
        self.hasRunGuide = true
    end
end

function RequestMessagePanel:updateBottomCloseBtn(index)
    if self.isDisposed then return end
    if not index then index = self.pagedView:getPageIndex() end
    if self.processableMessageCount == 0 or self:countMessageItems() == 0 then
        local curPage = self.layers[index]
        if curPage then
            local zero = curPage.zero
            if zero:showBottomCloseButton() then
                self.bottomCloseBtn:setVisible(true)
                self.bottomCloseBtn:setEnabled(true)
            else
                self.bottomCloseBtn:setVisible(false)
                self.bottomCloseBtn:setEnabled(false)
            end
        end
    end
end

function RequestMessagePanel:setButtonsVisibleEnable(index)
    self.customTip:setVisible(false)
    if self.pageConfig[index].showCustomTip then
        self.customTip:setVisible(true)
        self.customTip:getChildByName("tip"):setString(self.pageConfig[index].getCustomTip())
        self.customTip:setTouchEnabled(true)
        self.customTip:ad(DisplayEvents.kTouchTap, function()
            local function onSuccess(evt)
                local data = evt.data or {}
                local panel = AskForHelpRecord:create()
                panel:setData(data)
                panel:popout()
            end

            local function onFail(errCode)
                --CommonTip:showTip(localize("error.tip."..tostring(errCode)), "negative")
            end
            
            PaymentNetworkCheck.getInstance():check(function ()
                local http = AskForHelpGetInfoHttp.new()
                http:addEventListener(Events.kComplete, onSuccess)
                http:addEventListener(Events.kError, onFail)
                http:load()
            end, function ()
                CommonTip:showTip(localize("forcepop.tip3"))
            end)
        end)
    end

    self:updateBottomCloseBtn(index)
    local content = FreegiftManager:sharedInstance():getMessages(self.pageConfig[index].msgType)
    self.shareRequestButton:setVisible(false)
    self.shareRequestButton:setEnabled(false)
    if #content <= 0 then
        self.acceptAllButton:setVisible(false)
        self.acceptAllButton:setEnabled(false)
        self.rejectAllButton:setVisible(false)
        self.rejectAllButton:setEnabled(false)
        return 
    end

    self.rejectAllButton:setVisible(self.pageConfig[index].rejectAll())
    self.acceptAllButton:setVisible(self.pageConfig[index].acceptAll())
    self.requestTip:setVisible(self.pageConfig[index].showTip)
    self.rejectAllButton:setEnabled(true)
    self.acceptAllButton:setEnabled(true)

    local function getItems()
        local list = self.layers[index]:getChildByName("list")
        if list then
            local layout = list:getContent()
            if layout then
                return layout:getItems()
            end
        end
        return {}
    end

    -- 同意次数达到今日上限，左下角显示【全部关闭】点击后清除有信息
    if self.tabConfig[index].pageName == 'energy' then
        for k,v in pairs(getItems()) do
            if v:is(EnergyRequestItem) then
                if v.enabled == true then
                    self.rejectAllButton:setEnabled(false)
                    self.rejectAllButton:setVisible(false)
                    break
                end
            end
        end
    end


    local typeUpdate = false
    for k, v in ipairs(self.pageConfig[index].msgType) do
        if v == RequestType.kNeedUpdate then
            typeUpdate = true
            break
        end
    end
    if typeUpdate then self.acceptAllButton:setString(localize("new.version.download.text"))
    else self.acceptAllButton:setString(localize("message.center.agree.all.btn")) end
    local content = FreegiftManager:sharedInstance():getMessages(self.pageConfig[index].msgType)
    if self.layers[index] then
        local list = self.layers[index]:getChildByName("list")
        if list then
            local layout = list:getContent()
            if layout then
                local items = layout:getItems()
                local allProcessing = true
                for k, v in ipairs(items) do
                    if not v.processing then
                        allProcessing = false
                        break
                    end
                end
                if allProcessing then
                    self.rejectAllButton:setEnabled(false)
                    self.acceptAllButton:setEnabled(false)
                    return
                end
            end
        end
    end  
    self.rejectAllButton:setEnabled(self.rejectAllButton:getEnabled() and #content > 0)
    local typeEnergy = false
    for k, v in ipairs(self.pageConfig[index].msgType) do
        if v == RequestType.kSendFreeGift or v == RequestType.kReceiveFreeGift then
            typeEnergy = true
            break
        end
    end
    if typeEnergy then
        local list = self.layers[index]:getChildByName("list")
        local allMsgDisable = false
        if list then
            local layout = list:getContent()
            if layout then
                local items = layout:getItems()
                for k, v in ipairs(items) do
                    if v.type == RequestType.kSendFreeGift and (FreegiftManager:sharedInstance():canSendMore()) or
                       v.type == RequestType.kReceiveFreeGift and (v.mode == EnergyRequestItemMode.kReceive and
                                                                   v:canReceiveMore() or v.mode == EnergyRequestItemMode.kSendBack and
                                                                   v:canSendBackToReceiver()) then
                        self.acceptAllButton:setEnabled(#content > 0)
                        return
                    end
                end
                if items ~= nil and #items > 0 then 
                    allMsgDisable = true 
                end
            end
        end

        

        local curPageIdx = self.pagedView:getPageIndex()--闭包回调逻辑走进来时，当前的index很有可能已经是老的了
    -- RemoteDebug:log("pre check guide--------------------------------------0  listAnimPlayItemCount:" .. self.listAnimPlayItemCount .. "  pageName:" .. self.tabConfig[curPageIdx].pageName)

        if self.listAnimPlayItemCount <= 0 and self.tabConfig[curPageIdx].pageName == 'energy' then
            self.acceptAllButton:setEnabled(false)
            self.acceptAllButton:setVisible(false)
            if allMsgDisable and GoToAddFriendPanel:hasSharePlatform() then
                self.shareRequestButton:setVisible(true)
                self.shareRequestButton:setEnabled(true)
                if self:checkShareRequestGuide() then
                    local rawPos = self.shareRequestButton:getPosition()
                    local btnCurPos = ccp(rawPos.x, rawPos.y)
                    local btnP = self.shareRequestButton.groupNode:getParent()
                    local btnNewPos = self:convertToNodeSpace(btnP:convertToWorldSpace(btnCurPos))
                    self.shareRequestButton:removeFromParentAndCleanup(false)
                    self.shareRequestButton.groupNode:setPosition(btnNewPos)
                    self:addChild(self.shareRequestButton.groupNode)
                end
            end
        end
    else 
        self.acceptAllButton:setEnabled(self.acceptAllButton:getEnabled() and #content > 0) 
    end
    -- RemoteDebug:uploadLog()
end

function RequestMessagePanel:checkShareRequestGuide()
    -- RemoteDebug:log("check guide--------------------------------------3")
    local uid = UserManager:getInstance():getUID()
    if not CCUserDefault:sharedUserDefault():getBoolForKey("share.weixin.request.gift" .. uid, false) then
    -- RemoteDebug:log("check guide--------------------------------------4")
        CCUserDefault:sharedUserDefault():setBoolForKey("share.weixin.request.gift" .. uid, true)
        local action = {panelName = 'guide_dialogue_share_request_gift', panDelay = 0, panFade = 1}
        local panel = GameGuideUI:dialogue( nil , action )
        panel.ui:getChildByName('keepname_lable1'):setString("今日")
        panel.ui:getChildByName('keepname_lable2'):setString("通过")
        panel.ui:getChildByName('keepname_lable3'):setString("微信求助好友")
        panel.ui:getChildByName('keepname_lable4'):setString("还可")
        panel.ui:getChildByName('keepname_lable5'):setString("继续")
        panel.ui:getChildByName('keepname_lable6'):setString("获得更多精力哦！")
        panel:setPosition(ccp(580, 170))
        self.shareToWXGuide = panel

        local mask = LayerColor:create()
        mask:setContentSize(CCSizeMake(2000, 2000))
        mask:setOpacity(200)
        mask:ignoreAnchorPointForPosition(false)
        mask:setAnchorPoint(ccp(0, 1))
        local vs = Director:sharedDirector():getWinSize()
        local vo = Director:sharedDirector():getVisibleOrigin()
        mask:setPosition(self:convertToNodeSpace(ccp(vo.x, vo.y+vs.height)))
        mask:setTouchEnabled(true, 0, true)
        mask:ad(DisplayEvents.kTouchTap, function () 
            if not self.isDisposed then
                self:hideShareRequestGuide()
            end
        end)
        self.shareToWXGuideMask = mask

        self:addChild(mask)
        self:addChild(panel)
    -- RemoteDebug:uploadLog()
        return true
    end

    return false
end

function RequestMessagePanel:hideShareRequestGuide()
    -- RemoteDebug:log("hide guide--------------------------------------0")
    if self.shareToWXGuide ~= nil and not self.shareToWXGuide.isDisposed then
    -- RemoteDebug:log("hide guide--------------------------------------1")
        self.shareToWXGuide:removeFromParentAndCleanup(true)
        self.shareToWXGuide = nil
    end

    -- RemoteDebug:log("hide guide--------------------------------------2")
    if self.shareToWXGuideMask ~= nil and not self.shareToWXGuideMask.isDisposed then
        self.shareToWXGuideMask:removeFromParentAndCleanup(true)
        self.shareToWXGuideMask = nil
    end
    -- RemoteDebug:uploadLog()
end

function RequestMessagePanel:setFocusedItem(item)
    self._focusedItem = item
end

function RequestMessagePanel:cancelAllThanksItem()--忽略全部
    local index = self.pagedView:getPageIndex()
    if self.pageConfig[index].pageName == "needUpdate" then
        self:__cancelAllNeedUpdate(self.pageConfig[index], index ,isTanksCell)
    else
        self:__cancelAllThanksCell(self.pageConfig[index], index)
    end
end

function RequestMessagePanel:cancelAll()--忽略全部
    local index = self.pagedView:getPageIndex()
    if self.pageConfig[index].pageName == "needUpdate" then
        self:__cancelAllNeedUpdate(self.pageConfig[index], index)
    elseif self.pageConfig[index].rejectAllType ~= nil and #self.pageConfig[index].rejectAllType > 0 then
        self:__cancelAllByType(self.pageConfig[index], index)
    else
        self:__cancelAll()
    end
end
function RequestMessagePanel:__cancelAllInvalidGift()
    local invalidGiftRequest = FreegiftManager:sharedInstance().invalidGiftRequest
    if invalidGiftRequest ~= nil and #invalidGiftRequest > 0 then
        ConnectionManager:block()
        for i=1, #invalidGiftRequest do
            if i >= 200 then break end
            local action = 2
            local http = RespRequest.new()
            http:load(invalidGiftRequest[i].id, action)
        end
        ConnectionManager:flush()
    end
end

function RequestMessagePanel:__cancelAllNeedUpdate(thePageConfig, pageIndex,isTanksCell)
    self:__cancelAllInvalidGift()--不管视图，全取消掉，视图在下个函数统一处理
    if not isTanksCell then
        self:__cancelAllByType(thePageConfig, pageIndex)
    else
        self:__cancelAllThanksCell(thePageConfig, pageIndex)
    end
    
end


function RequestMessagePanel:__cancelAllThanksCell(thePageConfig, pageIndex)
    local tabItems = self:getListItemsByPageIdx(pageIndex)
    if tabItems == nil then return end
    if type(tabItems) ~= "table" or table.isEmpty(tabItems) then return end
    if thePageConfig.inHandleIgnoreAll then return end
    thePageConfig.inHandleIgnoreAll = true
    for i=1, #tabItems do
        if  tabItems[i].isThanksCell and tabItems[i]:isThanksCell() then
            printx(103 , "thePageConfig.sendIgnore ")
            tabItems[i]:sendIgnore(true, true)
        end
    end
    local function onSuccess(event)
        thePageConfig.inHandleIgnoreAll = false
        FreegiftManager:sharedInstance():removeMessageByTypes({RequestType.kThanks})
        GlobalEventDispatcher:getInstance():dispatchEvent(Event.new(kGlobalEvents.kMessageCenterUpdate))
        for i=1, #tabItems do
            if  tabItems[i].isThanksCell and tabItems[i]:isThanksCell() then
                printx(103 , "thePageConfig.onSendIgnoreSuccess ")
                tabItems[i]:onSendIgnoreSuccess(event, true)
            end
        end
    end
    local function onFail(event)
        thePageConfig.inHandleIgnoreAll = false
        for i=1, #tabItems do
            if  tabItems[i].isThanksCell and tabItems[i]:isThanksCell() then
                printx(103 , "thePageConfig.onSendIgnoreFail = ")
                tabItems[i]:onSendIgnoreFail(event, true)
            end
        end
    end
    local http = RespRequest.new()
    http:addEventListener(Events.kComplete, onSuccess)
    http:addEventListener(Events.kError, onFail)
    http:addEventListener(Events.kCancel, onFail)
    http:load(nil, 4, {RequestType.kThanks}, FreegiftManager:sharedInstance().maxMessageID)
end

function RequestMessagePanel:__cancelAllByType(thePageConfig, pageIndex)
    local tabItems = self:getListItemsByPageIdx(pageIndex)
    if tabItems == nil then return end
    if type(tabItems) ~= "table" or table.isEmpty(tabItems) then return end
    if thePageConfig.inHandleIgnoreAll then return end
    thePageConfig.inHandleIgnoreAll = true

    for i=1, #tabItems do
        if tabItems[i]:canIgnoreAll() then
            tabItems[i]:sendIgnore(true, true)
        end
    end

    local function onSuccess(event)
        thePageConfig.inHandleIgnoreAll = false
        FreegiftManager:sharedInstance():removeMessageByTypes(thePageConfig.rejectAllType)
        GlobalEventDispatcher:getInstance():dispatchEvent(Event.new(kGlobalEvents.kMessageCenterUpdate))
        for i=1, #tabItems do
            if tabItems[i]:canIgnoreAll() then
                tabItems[i]:onSendIgnoreSuccess(event, true)
            end
        end
    end

    local function onFail(event)
        thePageConfig.inHandleIgnoreAll = false
        for i=1, #tabItems do
            if tabItems[i]:canIgnoreAll() then
                tabItems[i]:onSendIgnoreFail(event, true)
            end
        end
    end

    local http = RespRequest.new()
    http:addEventListener(Events.kComplete, onSuccess)
    http:addEventListener(Events.kError, onFail)
    http:addEventListener(Events.kCancel, onFail)
    if _G.isLocalDevelopMode then printx(0, "type________ary:") end
    if _G.isLocalDevelopMode then printx(0, table.tostring(thePageConfig.rejectAllType)) end
    http:load(nil, 4, thePageConfig.rejectAllType, FreegiftManager:sharedInstance().maxMessageID)
end

function RequestMessagePanel:__acceptAllByType(thePageConfig, pageIndex)
    local tabItems = self:getListItemsByPageIdx(pageIndex)
    if tabItems == nil then return end
    if type(tabItems) ~= "table" or table.isEmpty(tabItems) then return end
    if thePageConfig.inHandleIgnoreAll then return end
    thePageConfig.inHandleIgnoreAll = true

    for i=1, #tabItems do
        tabItems[i]:sendAccept(true, true)
    end

    local function onSuccess(event)
        thePageConfig.inHandleIgnoreAll = false
        FreegiftManager:sharedInstance():removeMessageByTypes(thePageConfig.acceptAllType)
        GlobalEventDispatcher:getInstance():dispatchEvent(Event.new(kGlobalEvents.kMessageCenterUpdate))
        for i=1, #tabItems do
            tabItems[i]:onSendAcceptSuccess(event, true)
        end
    end

    local function onFail(event)
        thePageConfig.inHandleIgnoreAll = false
        for i=1, #tabItems do
            tabItems[i]:onSendAcceptFail(event, true)
        end
    end

    local http = RespRequest.new()
    http:addEventListener(Events.kComplete, onSuccess)
    http:addEventListener(Events.kError, onFail)
    http:addEventListener(Events.kCancel, onFail)
    http:load(nil, 3, thePageConfig.acceptAllType, FreegiftManager:sharedInstance().maxMessageID)
end

function RequestMessagePanel:getListItemsByPageIdx(pageIndex)
    local curLayer = self.layers[pageIndex]
    if curLayer and not curLayer.isDisposed then
        local list = self.layers[pageIndex]:getChildByName("list")
        if list then
            local layout = list:getContent()
            if layout then
                local items = layout:getItems()
                return items
            end
        end
    end

    return nil
end

function RequestMessagePanel:__cancelAll()
    self._focusedItem = nil
    self.batchSend = false
    self.batchReceive = false
    ConnectionManager:block()
    local index = self.pagedView:getPageIndex()
    if self.layers[index] then
        local list = self.layers[index]:getChildByName("list")
        if list then
            local layout = list:getContent()
            if layout then
                local items = layout:getItems()
                for k, v in ipairs(items) do
                    if not v.processing then 
                        if v:canIgnoreAll() then
                            v:sendIgnore(true) 
                        end
                    end
                end
            end
        end
    end
    self:setButtonsVisibleEnable(index)
    ConnectionManager:flush()

    if self.pageConfig[index].pageName == 'clover' then
        DcUtil:UserTrack({category = "link_to_xx2", sub_category = "xx2_jump", t1 = 4})
    end
end

function RequestMessagePanel:acceptAll()--同意全部
    local index = self.pagedView:getPageIndex()
    if self.pageConfig[index].pageName == 'energy' then
        self.listAnimPlayItemCount = 0
        local send, receive, request = {}, {}, {}
        local index = self.pagedView:getPageIndex()
        if self.layers[index] then
            local list = self.layers[index]:getChildByName("list")
            if list then
                local layout = list:getContent()
                if layout then
                    local items = layout:getItems()
                    for k, v in ipairs(items) do
                        if v:canAcceptAll() then
                            if v:isSend() then
                                if not v:hasCompleted() and v:canAcceptAll() then 
                                    table.insert(send, v) 
                                end
                            elseif v:isReceive() then
                                if not v:hasCompleted() and v:canAcceptAll() then 
                                    table.insert(receive, v) 
                                end
                            end
                        end
                    end
                end
            end
        end
        local canSend, remainSend = FreegiftManager:sharedInstance():canSendMore()
        local canReceive, remainReceive = FreegiftManager:sharedInstance():canReceiveMore()
        if canReceive and #receive > 0 then
            self.batchReceive = true
            for k, v in ipairs(receive) do table.insert(request, v) end
        end
        if canSend then
            local function doYes()
                self.batchSend = true
                for k, v in ipairs(send) do table.insert(request, v) end
                ConnectionManager:block()
                local messageids = {}
                local hasOther = false
                for k, v in ipairs(request) do 
                    if remainSend > #messageids then
                        if v.requestInfo.type == 2 then
                            table.insert( messageids ,  v.requestInfo.id) 
                        end
                    end
                    --  RequestType = {kAcceptRequest = 1, kReceive = 2, kSendBack = 3}
                    if v.requestInfo.type ~= 2 then
                        hasOther = true
                    end
                end

                local function isThisID( messageid )
                    local hasIt = table.find(messageids , function ( value )
                        return messageid == value
                    end)
                    if hasIt then
                        return true
                    end
                    return false
                end 

                 local function onSuccess( event )

                    for k, v in ipairs(request) do 
                        if v:canAcceptAll() and isThisID(v.requestInfo.id)  then
                            v:onSendAcceptSuccess(event , true)         
                        end
                    end

                    for k, v in ipairs(request) do 
                        if v:canAcceptAll() and isThisID(v.requestInfo.id)  then
                        elseif hasOther and v:canAcceptAll()  then
                            v:sendAccept(true) 
                        end
                    end

                end
                local function onFail()
                    for k, v in ipairs(request) do 
                        if v:canAcceptAll() then
                            v:onSendAcceptFail(event , true) 
                        end
                    end
                end
                if #messageids > 0 then
                    local mgr = FreegiftManager:sharedInstance()
                    mgr:doSendGifts(messageids, onSuccess, onFail, true)
                else
                    onSuccess()
                end
                

                ConnectionManager:flush()
            end

            local function doNo()
                if #request > 0 then
                    ConnectionManager:block()
                    for k, v in ipairs(request) do 
                        if v:canAcceptAll() then
                            v:sendAccept(true) 
                        end
                    end
                    ConnectionManager:flush()
                end
                self:setButtonsVisibleEnable(index)
            end
            if #send > 0 and remainSend < #send then
                local tip = {
                    tip = localize("request.message.panel.batch.energy.tip", {total = #send, quota = remainSend}),
                    yes = localize("request.message.panel.batch.energy.yes"),
                    no = localize("request.message.panel.batch.energy.no"),
                }
                CommonTipWithBtn:showTip(tip, "positive", doYes, doNo)
            else doYes() end
        else
            if #request > 0 then
                ConnectionManager:block()
                for k, v in ipairs(request) do 
                    if v:canAcceptAll() then
                        v:sendAccept(true)
                    end
                end
                ConnectionManager:flush()
            end
        end
    elseif self.pageConfig[index].pageName == 'unlock' then
        self:__acceptAllByType(self.pageConfig[index], index)
    elseif self.pageConfig[index].pageName == 'addFriend' then
        -- do nothing
    elseif self.pageConfig[index].pageName == 'clover' then
        local totalAccept = 0
        local acceptSuccess = false
        local function acceptCallback(success, requestInfo)
            totalAccept = totalAccept - 1
            local inviteUid = nil
            if success then 
                acceptSuccess = true 
                if not inviteUid or string.len(inviteUid) < 1 then inviteUid = requestInfo and requestInfo.extra end
            end
            if totalAccept <= 0 and acceptSuccess then
                if CloverUtil:isAppInstall() then
                    CloverUtil:openApp("accept_invite")
                    DcUtil:UserTrack({category = "link_to_xx2", sub_category = "xx2_jump", t1 = 3, t2 = 1})
                else
                    local pfName = StartupConfig:getInstance():getPlatformName()
                    CloverUtil:downloadApk({platform=pfName,source=inviteUid})
                    DcUtil:UserTrack({category = "link_to_xx2", sub_category = "xx2_jump", t1 = 3, t2 = 2})
                end
            end
        end
        ConnectionManager:block()
        local index = self.pagedView:getPageIndex()
        if self.layers[index] then
            local list = self.layers[index]:getChildByName("list")
            if list then
                local layout = list:getContent()
                if layout then
                    local items = layout:getItems()
                    for k, v in ipairs(items) do 
                        if v:canAcceptAll() then
                            if v:sendAccept(true, acceptCallback) then
                                totalAccept = totalAccept + 1
                            end
                        end
                    end
                end
            end
        end
        ConnectionManager:flush()
        DcUtil:UserTrack({category = "link_to_xx2", sub_category = "xx2_jump", t1 = 3})
    elseif self.pageConfig[index].pageName == 'needUpdate' then
        if __IOS then
            NewVersionUtil:gotoMarket()
        else
            --
            if NewVersionUtil:hasPackageUpdate() then 
                -- local panel = PrePackageUpdatePanel:create(
                --     ccp(0,0),
                --     localize("new.version.tip.message")
                -- )

                local panel = nil

                if (_G.isPrePackage ) then
                    panel = PrePackageUpdatePanel:create(
                        ccp(0,0),
                        localize("new.version.tip.message")
                    ) 
                    panel:popout()
                
                elseif UpdatePackageManager:enabled() then
                    UpdatePackageManager:getInstance():startDownload()
                    
                else
                    local AsyncSkinLoader = require 'zoo.panel.AsyncSkinLoader'
                    AsyncSkinLoader:create(UpdatePageagePanel, {
                        ccp(0,0),
                        localize("new.version.tip.message")
                    }, UpdatePageagePanel.getSkin, function ( panel )
                        if (panel) then
                            panel:popout()
                end
                    end)

                end


            end
        end
    end
    self:setButtonsVisibleEnable(index)
end

function RequestMessagePanel:onRequestSent(isBatch)
    self.pendingRequestCount = self.pendingRequestCount + 1
    self.energyItems = self.energyItems or {}
    for k, v in pairs(self.energyItems) do
        v:updateSelf()
    end
end

function RequestMessagePanel:onRequestCompleted(isBatch)
    local index = self.pagedView:getPageIndex()
    self:setButtonsVisibleEnable(index)

    self.pendingRequestCount = self.pendingRequestCount - 1

    if isBatch and self.pendingRequestCount <= 0
    or (not isBatch) then
        self.energyItems = self.energyItems or {}
        for k, v in pairs(self.energyItems) do
            if v == self._focusedItem then
                v:gainFocus()
            else
                v:looseFocus()
            end
            v:updateSelf()
        end
    end
    if isBatch and self.pendingRequestCount <= 0 then
        self:onBatchRequestCompleted()
    end
end

function RequestMessagePanel:countMessageItems(pageIndex)
    local left = 0

    local function calcMsgItemInPage(page)
        local counter = 0
        if page and not page.isDisposed then
            local list = page:getChildByName("list")
            local zero = page:getChildByName("zero")
            if list and not list.isDisposed then
                local layout = list:getContent()
                for k2, v2 in ipairs(layout:getItems()) do
                    if (not v2:is(AskForHelpTopItem)) and (not v2:hasCompleted()) then
                        counter = counter + 1
                    end
                end
            end
        end
        return counter
    end

    if type(pageIndex) == "number" then
        local page = self.layers[pageIndex]
        left = calcMsgItemInPage(page)
    else
        for k, v in ipairs(self.pageConfig) do
            local page = self.layers[v.pageIndex]
            left = left + calcMsgItemInPage(page)
        end
    end

    return left
end

function RequestMessagePanel:onMessageLifeFinished(pageIndex)
    self.processableMessageCount = self.processableMessageCount - 1
    self.listAnimPlayItemCount = self.listAnimPlayItemCount - 1
    if self.pageMessageCount[pageIndex] then
        self.pageMessageCount[pageIndex] = self.pageMessageCount[pageIndex] - 1
    end

    self.tabs:setNumber(pageIndex, self:countMessageItems(pageIndex))

    local page = self.layers[pageIndex]
    if self.pageMessageCount[pageIndex] <= 0 then   -- 当前面板的消息处理完毕
        if page then
            local list = page:getChildByName("list")
            local zero = page:getChildByName("zero")

            if type(zero.onShow) == "function" then
                zero:onShow()
                list:runAction(CCSequence:createWithTwoActions(CCFadeOut:create(0.9), CCHide:create()))
            else
                zero:setVisible(true)
                list:setVisible(false)
            end

            -- bugfix: 老司机的topItem没有走正常流程先在这里处理一下
            if list and not list.isDisposed then
                local layout = list:getContent()
                for k2, v2 in ipairs(layout:getItems()) do
                    if (v2:is(AskForHelpTopItem)) then
                        v2:onSendIgnoreSuccess()
                    end
                end
            end
            -- 
        end
    else
        if page then
            page.scrollable:updateScrollableHeight()
        end
    end

    if self.processableMessageCount <= 0 or self:countMessageItems() == 0 then --所有消息都处理完,显示关闭按钮
        self.acceptAllButton:setVisible(false)
        self.acceptAllButton:setEnabled(false)
        self.rejectAllButton:setVisible(false)
        self.rejectAllButton:setEnabled(false)
        self.shareRequestButton:setVisible(false)
        self.shareRequestButton:setEnabled(false)
        self:updateBottomCloseBtn()
    end

    if self.listAnimPlayItemCount <= 0 and self.tabConfig[pageIndex].pageName == 'energy' then
        self:setButtonsVisibleEnable(pageIndex)
    end
end

local _MILISEC_DAY = 24*3600*1000
local function _getDay()
	return math.ceil(Localhost:time() / _MILISEC_DAY)
end
local _today = _getDay()

local _tipShown1 = false
local _tipShown2 = false
local _tipShown3 = false
function RequestMessagePanel:onBatchRequestCompleted()
    local index = self.pagedView:getPageIndex()
    for k, v in ipairs(self.pageConfig) do
        if v.pageName == 'energy' then
            if v.pageIndex ~= index then 
                self:setButtonsVisibleEnable(index)
                return 
            end
        end
    end
    local canSendMore, leftSendMore = FreegiftManager:sharedInstance():canSendMore()
    local canReceiveMore, leftReceiveMore = FreegiftManager:sharedInstance():canReceiveMore()
    local txt = nil

    -- reset
    if _getDay() ~= _today then
    	_today = _getDay()
    	_tipShown1 = false
    	_tipShown2 = false
    	_tipShown3 = false
    end

    local paramObj = {send = kDailyMaxSendGiftCount, receive = kDailyMaxReceiveGiftCount} 
    if self.batchReceive and self.batchSend then
        if not _tipShown3 and not canSendMore and not canReceiveMore then
            CommonTip:showTip(localize("message.center.panel.commontip.sentreceivedall", paramObj), 'positive', nil, 3)
            _tipShown3 = true
        end
    elseif self.batchReceive then
        if not _tipShown1 and not canReceiveMore then
            CommonTip:showTip(localize("message.center.panel.commontip.receivedall", paramObj), 'positive', nil, 3)
            _tipShown1 = true
        end
    elseif batchSend then
        if not _tipShown2 and not canSendMore then
            CommonTip:showTip(localize("message.center.panel.commontip.sentall", paramObj), 'positive', nil, 3)
            _tipShown2 = true
        end
    end
    self.batchSend = false
    self.batchReceive = false
    self:setButtonsVisibleEnable(index)
end

function RequestMessagePanel:isBusy()
    return self.pendingRequestCount > 0 
end
