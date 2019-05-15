require("zoo.panel.component.friendsPanel.func.FriendsFullPanel")


local AutoAddFriendPanel = class(BasePanel)
local PanelCount = 0
local closeCallBack
function AutoAddFriendPanel:canAddPop()
    return PanelCount < 2
end

function AutoAddFriendPanel:create(rawUserData)
	local panel = AutoAddFriendPanel.new()
    PanelCount = PanelCount + 1
	panel:loadRequiredResource("ui/personal_center_panel.json")
	panel:init(rawUserData)
    return panel
end

--[[
        local self.toAddFriend = {userLevel = evt.data.user.topLevelId,
                            userName = evt.data.profile.name or "消消乐玩家", 
                            uid = evt.data.user.uid, 
                            headUrl = evt.data.profile.headUrl or evt.data.user.image,
                            friendNum = evt.data.friendNum,
                            isFriend = evt.data.isFriend}
]]
function AutoAddFriendPanel:init(rawUserData)
    self.rawUserData = rawUserData
    self.toAddFriend = {userLevel = rawUserData.user.topLevelId,
                        starNum = rawUserData.user.star + rawUserData.user.hideStar,
                        userName = rawUserData.profile.name or "消消乐玩家", 
                        uid = rawUserData.user.uid, 
                        headUrl = rawUserData.profile.headUrl or rawUserData.user.image,
                        friendNum = rawUserData.friendNum or "消消乐玩家",
                        isFriend = rawUserData.friend,
                        profile = rawUserData.profile,
                    }

	self.ui = self:buildInterfaceGroup("personal_center_auto_add_panel")
    BasePanel.init(self, self.ui)

    self.title = self.ui:getChildByName("title")
    self.title:setPreferredSize(282, 48)
    self.title:setString(localize("addfriend_auto_add_title"))
    self.title:setAnchorPoint(ccp(0.5, 0.5))
    self.title:setPositionXY(328, -48)

    self.text = self.ui:getChildByName("text")
    self.text:setString(localize("addfriend_auto_add_text"))

    self.levelTf = self.ui:getChildByName("levelTf")
    self.levelTf:setString("第" .. self.toAddFriend.userLevel .. "关")

    self.userName = self.ui:getChildByName("userName")
    if self.toAddFriend.userName == nil or #self.toAddFriend.userName == 0 then self.toAddFriend.userName = "消消乐玩家" end
    self.userName:setString(nameDecode(self.toAddFriend.userName))

    self.starNumTf = self.ui:getChildByName("starNumTf")
    self.starNumTf:setPreferredSize(82, 48)
    self.starNumTf:setString(self.toAddFriend.starNum)

    self.userImg = self.ui:getChildByName("headIcon")
    self.userImg:setOpacity(0)
    self.userHeadImg = HeadImageLoader:createWithFrame(self.toAddFriend.uid, self.toAddFriend.headUrl, nil, nil, self.toAddFriend.profile)
    if self.userHeadImg then
        local position = self.userImg:getPosition()
        self.userHeadImg:setAnchorPoint(ccp(-0.5, 0.5))
        self.userHeadImg:setPosition(ccp(position.x + 14, position.y - 14))
        self.userImg:getParent():addChild(self.userHeadImg)
        -- self.userImg:setVisible(false)
    end

    self:setPositionForPopoutManager()
    -- self:setPositionX(self:getPositionX() + 10)

    self.closeBtn = self.ui:getChildByName("closeBtn")
    self.closeBtn:setTouchEnabled(true, 0, true)
    self.closeBtn:setButtonMode(true)
    self.closeBtn:addEventListener(DisplayEvents.kTouchTap, 
        function()
        	if not self.closeBtn.clked then
                local dcData = {}
                dcData.category = "add_friend"
                dcData.sub_category = "auto_addfriend"
                dcData.t1 = 0
                DcUtil:log(AcType.kUserTrack, dcData, true)

        		self.closeBtn.clked = true
            	self:onCloseBtnTapped()
        	end
        end)

    self.okBtn = GroupButtonBase:create(self.ui:getChildByName("okBtn"))
    self.okBtn:setString(localize("addfriend_auto_add_button"))
    self.okBtn:addEventListener(DisplayEvents.kTouchTap,function() 
        if not self.okBtn.clked then
            self.okBtn.clked = true
            self:onClkOkBtn() 
        end
    end)

    if not AutoAddFriendManager.getInstance():getIsOpenBylink() then
        local dcData = {}
        dcData.category = "AddFriend"
        dcData.sub_category = "addfriend_by_wordkey"
        DcUtil:log(AcType.kUserTrack, dcData, true)
    end
    AutoAddFriendManager.getInstance():clearIsOpenBylink()

end

function AutoAddFriendPanel:onClkOkBtn()
    if self.toAddFriend.isFriend then --双方已经是好友
        local dcData = {}
        dcData.category = "add_friend"
        dcData.sub_category = "auto_eorre"
        dcData.t1 = 3
        DcUtil:log(AcType.kUserTrack, dcData, true)
        CommonTip:showTip(localize("addfriend_auto_add_hit3"), "negative")
    elseif FriendManager:getInstance():isFriendCountReachedMax() then --自己好友已达上限300
        local dcData = {}
        dcData.category = "add_friend"
        dcData.sub_category = "auto_eorre"
        dcData.t1 = 1
        DcUtil:log(AcType.kUserTrack, dcData, true)

        FriendsFullPanel:checkFullZombieShow()

        -- CommonTip:showTip(localize("addfriend_auto_add_hit1"), "negative")
    elseif self.toAddFriend.friendNum >= FriendManager:getInstance():getMaxFriendCount() then--对方好友已达上限300
        local dcData = {}
        dcData.category = "add_friend"
        dcData.sub_category = "auto_eorre"
        dcData.t1 = 2
        DcUtil:log(AcType.kUserTrack, dcData, true)
        CommonTip:showTip(localize("addfriend_auto_add_hit2"), "negative")
    else
        self:addFriend(self.toAddFriend.uid)
    end
    
    self:onCloseBtnTapped()
end

function AutoAddFriendPanel:addFriend(uid)
    local function onSuccess(evt)
        local scene = Director:sharedDirector():run()
        if scene == nil or not scene:is(HomeScene) then
            return
        end

        local result = evt.data.returnCode
        if  result ~= nil and type(result) == "number" then
            --"0:成功 1:自己的好友满了 2:对方的好友满了 3:已经是好友了"
                local ref = UserRef.new()
                if self.rawUserData.profile then
                ref.userHead = self.rawUserData.profile.userHead
                ref.headUrl = self.rawUserData.profile.headUrl
                ref.name = self.rawUserData.profile.name
                ref:fromLua(self.rawUserData.user)
                local dcData = {}
                dcData.category = "add_friend"
                dcData.sub_category = "auto_addfriend"
                dcData.t1 = 1
                DcUtil:log(AcType.kUserTrack, dcData, true)

                FriendManager:getInstance():addFriend(ref)
                CommonTip:showTip(localize("addfriend_auto_add_sucess"), "positive")
            elseif result == 3 then
                local dcData = {}
                dcData.category = "add_friend"
                dcData.sub_category = "auto_eorre"
                dcData.t1 = 3
                DcUtil:log(AcType.kUserTrack, dcData, true)

                CommonTip:showTip(localize("addfriend_auto_add_hit3"), "negative")
            elseif result == 1 then
                local dcData = {}
                dcData.category = "add_friend"
                dcData.sub_category = "auto_eorre"
                dcData.t1 = 1
                DcUtil:log(AcType.kUserTrack, dcData, true)

                FriendsFullPanel:checkFullZombieShow()

                -- CommonTip:showTip(localize("addfriend_auto_add_hit1"), "negative")
            elseif result == 2 then
                local dcData = {}
                dcData.category = "add_friend"
                dcData.sub_category = "auto_eorre"
                dcData.t1 = 2
                DcUtil:log(AcType.kUserTrack, dcData, true)

                CommonTip:showTip(localize("addfriend_auto_add_hit2"), "negative")
            end
        end
    end
    local function onFail(evt)
        CommonTip:showTip(localize("addfriend_auto_add_fail"), "negative")
    end

    local http = AddFriend.new(false)
    http:addEventListener(Events.kComplete, onSuccess)
    http:addEventListener(Events.kError, onFail)
    http:load(uid)

end


function AutoAddFriendPanel:onCloseBtnTapped()
    PopoutManager:sharedInstance():remove(self, true)
    PanelCount = PanelCount - 1
    if PanelCount <= 0 then closeCallBack() end
end

function AutoAddFriendPanel:popout(panelCloseCallBack)
    closeCallBack = panelCloseCallBack
    PopoutQueue:sharedInstance():push(self)
    return self
end


----面板此刻弹出
function AutoAddFriendPanel:popoutShowTransition()
   self.allowBackKeyTap = true
   ClipBoardUtil.copyText("")
end


return AutoAddFriendPanel