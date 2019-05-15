require "zoo.util.NewVersionUtil"
require "zoo.panel.component.common.LayoutItem"
require "zoo.data.FreegiftManager"

EnergyRequestItemMode = {kAcceptRequest = 1, kReceive = 2, kSendBack = 3}

require 'zoo.panel.component.friendsPanel.FriendsPanelTab'
require 'zoo.panel.component.friendsPanel.items.FriendZeroItem'
require 'zoo.panel.component.friendsPanel.items.FriendAddItem'
require 'zoo.panel.component.friendsPanel.pages.AddFriendPage'

require("zoo.panel.component.friendsPanel.func.FriendsFullPanel")


FriendsPanel = class(LayerGradient)
function FriendsPanel:create(pageName)
    local winSize = CCDirector:sharedDirector():getWinSize()
    local ret = FriendsPanel.new()
    ret.panelName = "friendsPanel"
    ret:loadRequiredResource(PanelConfigFiles.friends_panel)
    ret:initLayer()
    ret:init()
    ret:changeWidthAndHeight(winSize.width, winSize.height)

    -- ret:setStartColor(ccc3(255, 216, 119))
    -- ret:setEndColor(ccc3(247, 187, 129))
    -- ret:setStartOpacity(255)
    -- ret:setEndOpacity(255)
    ret:buildUI()
    ret:switchPageFinish()


-- ret:setScale(0.5)
-- ret:setPositionXY(200,1100)

    return ret
end

function FriendsPanel:init()
    self.pendingRequestCount = 0 
    self.processableMessageCount = 0 -- 未处理完的消息数量（回赠时，可回赠算未处理完；不可回赠算处理完）
    self.listAnimPlayItemCount = 0
    self.pageMessageCount = {}

    self:runAction(CCSequence:createWithTwoActions(
        CCDelayTime:create(0.01),
        CCCallFunc:create(function()
            local idx = self.pagedView:getPageIndex()
            local curPage = self.layers[idx]
            if curPage ~= self.friendRankingPage then
                return
            end

            local count = self.friendRankingPage and self.friendRankingPage.friendCount or 0
            if FAQ:isPersonalCenterEnabled() and count>0 then
                local curGuide = GameGuide:sharedInstance():onPopup(self)
                self.__guide_popup_called = true
                if curGuide then
                    self.friendRankingPage:refreshForGuide()
                end
            end
        -- local achiValue = UserManager:getInstance().userExtend:getAchievementValue(AchievementManager.shareId.GET_POPULARITY) or 0
        -- AchievementManager:onDataUpdate(AchievementManager.GET_POPULARITY,achiValue)
    end)
    ))
end

function FriendsPanel:buildInterfaceGroup(groupName)
    if self.builder then return self.builder:buildGroup(groupName)
    else return nil end
end

function FriendsPanel:loadRequiredResource(panelConfigFile)
    self.panelConfigFile = panelConfigFile
    self.builder = InterfaceBuilder:createWithContentsOfFile(panelConfigFile)
end

function FriendsPanel:unloadRequiredResource()
    if self.panelConfigFile then
        InterfaceBuilder:unloadAsset(self.panelConfigFile)
    end
end

function FriendsPanel:dispose()
    if self.__guide_popup_called then
        GameGuide:sharedInstance():onPopdown(self)
    end
    LayerColor.dispose(self)
    if type(self.unloadRequiredResource) == "function" then self:unloadRequiredResource() end
end

function FriendsPanel:buildUI()

    local ui = self:buildInterfaceGroup("interface/request_panel")
    ui:getChildByName("item"):removeFromParentAndCleanup(true)
    self.ui = ui
    self:addChild(ui)

    local winSize = CCDirector:sharedDirector():getVisibleSize()
    local origin = CCDirector:sharedDirector():getVisibleOrigin()

    local realSize = CCDirector:sharedDirector():ori_getVisibleSize()
    local realOrigin = CCDirector:sharedDirector():ori_getVisibleOrigin()
    self:setPosition(ccp(origin.x, winSize.height+origin.y))

    local topHeight = 170
 --    local top = ui:getChildByName("top")

 --    local title = TextField:createWithUIAdjustment(top:getChildByName("panelTitleSize"), top:getChildByName("panelTitle"))
	-- top:addChild(title)
 --    title:setString(localize("friend.ranking.panel.title"))
    
    -- local titleSize = title:getContentSize()
    -- local titleScale = 66 / titleSize.height
    -- title:setScale(titleScale)
    -- title:setPositionX((realSize.width - titleSize.width * titleScale) / 2)
    -- title:setPositionY(title:getPositionY() - _G.__EDGE_INSETS.top * 0.4)


    self.childs = {
        "bg",
        "bg_pic1",
        "bg_pic2",
        "bg_pic3",
        "bg_pic0",
        "tab",
        "bg_inner",
        "tabHover",
        "closeBtn",
        "item",
        "bottom",
        "btnSortList",
        "sortList",
    }
    for i,v in ipairs(self.childs) do
        self[v] = ui:getChildByName(v)
    end

    local size = self.bg:getContentSize()
    local scaleX = realSize.width/size.width*1.4
    self.bg:setPositionXY(-(scaleX*size.width-realSize.width)*0.5,(realSize.height - winSize.height)-origin.y )
    -- self.bg:setPositionXY(-(scaleX*size.width-realSize.width)*0.5,0)
    self.bg:setScaleX(scaleX)
    -- self.bg:setScaleY((realSize.height+origin.y*2)/size.height)
    self.bg:setScaleY((realSize.height)/size.height)

    -- local background = self.closeBtn:getChildByName("_bg")
    -- background:adjustColor(kColorBlueConfig[1],kColorBlueConfig[2],kColorBlueConfig[3],kColorBlueConfig[4])
    -- background:applyAdjustColorShader()
    -- -- self.closeBtn:setPositionY(self.closeBtn:getPositionY() - _G.__EDGE_INSETS.top * 0.6)

    local bottomHeight = 130
    self.bottom:setPositionY(bottomHeight-winSize.height)
    
    self.bottoms = {}

    -- local ty = self.bg_inner:getPositionY()
    local size = self.bg_inner:getContentSize()
    local scaleX = realSize.width/size.width*1.4
    self.bg_inner:setPositionX(-(scaleX*size.width-realSize.width)*0.5)
    self.bg_inner:setScaleX(scaleX)
    self.bg_inner:setScaleY((winSize.height - bottomHeight + self.bg_inner:getPositionY())/size.height)

    local PanelConfig = require 'zoo.panel.component.friendsPanel.PanelConfig'
    local tabConfig, pageConfig = PanelConfig:getConfig()
    self.tabConfig = tabConfig
    self.pageConfig = pageConfig
    
    local listHeight = winSize.height - bottomHeight - topHeight

    local pos = self.tab:getPosition()
    local order = self.tab:getZOrder()
    self.tab:removeFromParentAndCleanup(false)
    local tab = FriendsPanelTab:create(tabConfig,self.tab,self.tabHover)
    self.ui:addChildAt(tab,order)
    self.tabs = tab

    local pagedView = PagedView:create(winSize.width - 36, listHeight - 80, #pageConfig, tab, true, false)
    pagedView.pageMargin = 35
    pagedView:setIgnoreVerticalMove(false) -- important!
    tab:setView(pagedView)

    pagedView:setPosition(ccp(36/2, bottomHeight + 30 - winSize.height))
    local function switchCallback() self:switchPage() end
    local function switchFinishCallback() self:switchPageFinish(listHeight - 70) end
    pagedView:setSwitchPageCallback(switchCallback)
    pagedView:setSwitchPageFinishCallback(switchFinishCallback)
    self.ui:addChild(pagedView)
    self.pagedView = pagedView

    self:createPages(pageConfig, winSize.width - 36, listHeight - 70)

    local function onCloseTapped()
        Director:sharedDirector():popScene()
        if self.closeCallback then
            self.closeCallback()
        end
    end
    self.closeBtn:setTouchEnabled(true)
    self.closeBtn:setButtonMode(true)
    self.closeBtn:ad(DisplayEvents.kTouchTap, onCloseTapped)


    self.friendRankingPage:initSortList(self.sortList,self.btnSortList,pos,self)
    return true
end

function FriendsPanel:shareRequest()
end

function FriendsPanel:gotoPageIndex(index)
    self.pagedView:gotoPage(index)
end

function FriendsPanel:gotoPage(pageName)
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

function FriendsPanel:createPages(pageConfig, width, height)
    -- bottom
    for i=1, 3 do
        self.bottoms[i] = self.bottom:getChildByName(tostring(i))
        if self.bottoms[i] then
            self.bottoms[i]:setVisible(false)
        end
    end

    self.layers = {}
    for k, v in ipairs(pageConfig) do
        local content = {
            normalMessages = FreegiftManager:sharedInstance():getMessages(v.msgType),
            pushMessages = FreegiftManager:sharedInstance():getPushMessages(v.msgType),
        }

        local layer = nil
        if v.type==1 then
            require 'zoo.panel.component.friendsPanel.pages.FriendRankingPage'
            layer = FriendRankingPage:create(self, v, content, width, height)
            self.friendRankingPage = layer
        elseif v.type==2 then
            require 'zoo.panel.component.friendsPanel.pages.FriendRecommendPage'
            layer = FriendRecommendPage:create(self, v, content, width, height)
        else
            layer = AddFriendPage:create(self, v, content, width, height)
        end
        
        self.layers[k] = layer
        self.pagedView:addPageAt(layer, k)
        layer:initBottom(self.bottoms[k])
        
        if layer.refresh then
            layer:refresh()
        end
    end
end

function FriendsPanel:getPageCount()
    return table.size(self.layers)
end

function FriendsPanel:removeCurrentPage(playAnimation)
    self:removePageAt(self.pagedView:getPageIndex(), playAnimation)
end

function FriendsPanel:removePageAt(index, playAnimation)
    if self.layers[index] == nil then return end
    self.pagedView:removePageAt(index, playAnimation)
    table.remove(self.layers, index)
end

function FriendsPanel:switchPage()
    local idx = self.pagedView:getPageIndex()
    if self.bottoms[idx] then
        self.bottoms[idx]:setVisible(false)
    end


    self:runAction(
        CCSequence:createWithTwoActions(
            CCDelayTime:create(0.05),
            CCCallFunc:create(
                function()
                    local idx = self.pagedView:getPageIndex()
                    self.friendRankingPage:onSwitchPage(idx==1)
                end
            )
        )
    )
end

function FriendsPanel:switchPageFinish()
    local index = self.pagedView:getPageIndex()
    self.listAnimPlayItemCount = 0
    self:setButtonsVisibleEnable(index)

    local idx = self.pagedView:getPageIndex()
    local curPage = self.layers[idx]

    for i, v in ipairs(self.bottoms) do
        if i ~= idx then
            v:setVisible(false)
            v:setTouchEnabled(false)
        end
    end

    if self.bottoms[idx] then
        if type(curPage.onSwitchPageFinished) == "function" then
            curPage:onSwitchPageFinished(self.bottoms[idx])
            self.bottoms[idx]:setVisible(true)
            self.bottoms[idx]:setTouchEnabled(true, 0, true)
 
            self.bottoms[idx]:removeFromParentAndCleanup(false) 
            self.bottom:addChild(self.bottoms[idx])
        end
    end

    self.friendRankingPage:onSwitchPage(idx==1)
end

function FriendsPanel:updateBottomCloseBtn(index)
    if self.isDisposed then return end
end

function FriendsPanel:setButtonsVisibleEnable(index)
end

function FriendsPanel:checkShareRequestGuide()
    local uid = UserManager:getInstance():getUID()
    if not CCUserDefault:sharedUserDefault():getBoolForKey("share.weixin.request.gift" .. uid, false) then
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
        return true
    end

    return false
end

function FriendsPanel:hideShareRequestGuide()
    if self.shareToWXGuide ~= nil and not self.shareToWXGuide.isDisposed then
        self.shareToWXGuide:removeFromParentAndCleanup(true)
        self.shareToWXGuide = nil
    end

    if self.shareToWXGuideMask ~= nil and not self.shareToWXGuideMask.isDisposed then
        self.shareToWXGuideMask:removeFromParentAndCleanup(true)
        self.shareToWXGuideMask = nil
    end
end

function FriendsPanel:setFocusedItem(item)
    self._focusedItem = item
end

function FriendsPanel:getListItemsByPageIdx(pageIndex)
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

function FriendsPanel:isBusy()
    return self.pendingRequestCount > 0 
end

function FriendsPanel:onKeyBackClicked()
    if self.friendRankingPage:checkKeyBack() then
        return
    end
    Director:sharedDirector():popScene()
end
