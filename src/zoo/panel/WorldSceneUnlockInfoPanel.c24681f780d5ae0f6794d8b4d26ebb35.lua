WorldSceneUnlockInfoPanel = class(BasePanel)
WorldSceneUnlockInfoPanelType = {
    FRIENDS_HELP = 1,
    TIME_COUNT_DOWN = 2
}

function WorldSceneUnlockInfoPanel:init(panelType, friendIds)
    BasePanel.init(self, self.ui)
    self.panelType = panelType
    if panelType == WorldSceneUnlockInfoPanelType.FRIENDS_HELP then
        self.curAreaFriendIds   = friendIds or {}
        self.friendItem1Res     = self.ui:getChildByName("unlockCloudFriendItem_1")
        self.friendItem2Res     = self.ui:getChildByName("unlockCloudFriendItem_2")
        self.friendItem3Res     = self.ui:getChildByName("unlockCloudFriendItem_3")
        self.friendItem1    = FriendItem:create(self.friendItem1Res)
        self.friendItem2    = FriendItem:create(self.friendItem2Res)
        self.friendItem3    = FriendItem:create(self.friendItem3Res)
        self.npc1     = self.ui:getChildByName("little_frog")
        self.npc2     = self.ui:getChildByName("little_chiken")
        self.npc3     = self.ui:getChildByName("little_hippo")
        self.npc1:setVisible(false)
        self.npc2:setVisible(false)
        self.npc3:setVisible(false)
        self.friendItems = {self.friendItem1, self.friendItem2, self.friendItem3}
        self:updateFriendItem()
    end

    self.hand = GameGuideAnims:handclickAnim(0, 0)
    self.ui:addChild(self.hand)
    self.hand:setPosition(ccp(325, -247))
end

function WorldSceneUnlockInfoPanel:updateFriendItem()
    if self.panelType ~= WorldSceneUnlockInfoPanelType.FRIENDS_HELP then 
        return
    end

    local function getNpcName(index)
        if index == 1 then
            return "青蛙"
        elseif  index == 2 then
            return "小黄鸡"
        else
            return "河马"
        end
    end

    for index,friendId in ipairs(self.curAreaFriendIds) do
        if self.friendItems[index] then
            if tostring(friendId) == "-1" then
                local npcname = getNpcName(index)
                self["npc" .. index]:setVisible(true)
                self.friendItems[index]:setFriend(tostring(friendId) , {name = npcname})
            else
                self.friendItems[index]:setFriend(tostring(friendId))
            end
        end
    end
end

function WorldSceneUnlockInfoPanel:create(panelType, friendIds)
    local panel = WorldSceneUnlockInfoPanel.new()
    panel:loadRequiredResource(PanelConfigFiles.unlock_cloud_panel_new)
    if panelType == WorldSceneUnlockInfoPanelType.FRIENDS_HELP then
        panel.ui = panel:buildInterfaceGroup('area_unlock/WorldSceneUnlockInfoPanel')
    elseif panelType == WorldSceneUnlockInfoPanelType.TIME_COUNT_DOWN then
        panel.ui = panel:buildInterfaceGroup('area_unlock/WorldSceneUnlockInfoPanel2')
    end
    panel:init(panelType, friendIds)
    return panel
end

function WorldSceneUnlockInfoPanel:fadeOut(callBack)
    local timeSlice = 0.03
    local ary = CCArray:create()
    ary:addObject(CCDelayTime:create(timeSlice * 15))
    local subAry = CCArray:create()
    subAry:addObject(CCMoveBy:create(timeSlice * 10, ccp(0, -150)))
    subAry:addObject(CCCallFunc:create(function( ... )
        self:allFadeOut(self.ui, timeSlice * 9)
    end))
    ary:addObject(CCSpawn:create(subAry))
    ary:addObject(CCCallFunc:create(function()
        HomeScene:sharedInstance().worldScene:removeWorldSceneUnlockInfoPanel()
        self.disposeCallback = nil
        callBack()
    end))
    self.disposeCallback = callBack
    self.ui:runAction(CCSequence:create(ary))
end

function WorldSceneUnlockInfoPanel:allFadeOut(ui, time)
    if ui.isDisposed then return end

    ui:runAction(CCFadeOut:create(time))
    local childern = ui:getChildrenList()
    if childern ~= nil and #childern > 0 then
        for i = 1, #childern do
            self:allFadeOut(childern[i], time)
        end
    end
end

function WorldSceneUnlockInfoPanel:dispose()
    if self.disposeCallback ~= nil then 
        local callBack = self.disposeCallback
        self.disposeCallback = nil
        callBack() 
    end
    BasePanel.dispose(self)
end