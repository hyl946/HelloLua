local function getNpcName(index)
    if index == 1 then
        return "青蛙"
    elseif  index == 2 then
        return "小黄鸡"
    else
        return "河马"
    end
end


FriendUnlockPanel = class(BasePanel)

function FriendUnlockPanel:create(lockedCloudId, finishCallback)
    local instance = FriendUnlockPanel.new()
    instance:loadRequiredResource(PanelConfigFiles.unlock_cloud_panel_new)
    instance.lockedCloudId = lockedCloudId
    instance.finishCallback = finishCallback
    instance:init()
    return instance
end

function FriendUnlockPanel:init()
    local ui = self.builder:buildGroup('area_unlock/friend_unlock_panel')
    BasePanel.init(self, ui)

    self.curAreaFriendIds   = UserManager:getInstance():getUnlockFriendUidsWithNPC(self.lockedCloudId)
    self.friendItem1Res = self.ui:getChildByName("friendItem1")
    self.friendItem2Res = self.ui:getChildByName("friendItem2")
    self.friendItem3Res = self.ui:getChildByName("friendItem3")
    self.friendItem1 = FriendItem:create(self.friendItem1Res)
    self.friendItem2 = FriendItem:create(self.friendItem2Res)
    self.friendItem3 = FriendItem:create(self.friendItem3Res)
    self.npc1 = self.ui:getChildByName("little_frog")
    self.npc2 = self.ui:getChildByName("little_chiken")
    self.npc3 = self.ui:getChildByName("little_hippo")
    self.npc1:setVisible(false)
    self.npc2:setVisible(false)
    self.npc3:setVisible(false)
    self.friendItems = {self.friendItem1, self.friendItem2, self.friendItem3}
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

    self.btn = GroupButtonBase:create(self.ui:getChildByName('btn'))
    self.btn:setString('解锁')
    self.btn:ad(DisplayEvents.kTouchTap, function() self:onBtnTapped() end)
end

function FriendUnlockPanel:onBtnTapped()
    self:onCloseBtnTapped()
    if self.finishCallback then
        self.finishCallback()
    end
end

function FriendUnlockPanel:popout()
    PopoutQueue:sharedInstance():push(self)
end

function FriendUnlockPanel:onCloseBtnTapped()
    PopoutManager:sharedInstance():remove(self)
end

function FriendUnlockPanel:popoutShowTransition()
    self:setPositionForPopoutManager()
end