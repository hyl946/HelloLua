local PanelOne = class(BasePanel)

function PanelOne:create(callback)
    local panel = PanelOne.new()
    panel:loadRequiredResource("ui/InviteFriendRewardRemovePanel.json")
    panel:init(callback)
    return panel
end

function PanelOne:init(callback)
	self.callback = callback

	local ui = self:buildInterfaceGroup("InviteFriendRewardRemovePanel/panel1")
	BasePanel.init(self, ui)

    self.close_btn = self.ui:getChildByName('close_btn')
    self.close_btn:setTouchEnabled(true, 0, true)
    self.close_btn:ad(DisplayEvents.kTouchTap, function () 
        self:onCloseBtnTapped() 
    end)

    self.ok_btn = GroupButtonBase:create(self.ui:getChildByName('ok_btn'))
    self.ok_btn:setString("知道了")
    self.ok_btn:setColorMode(kGroupButtonColorMode.green)
    self.ok_btn:ad(DisplayEvents.kTouchTap, function( )
        self:onOKBtnTapped()
    end)

    self:scaleAccordingToResolutionConfig()
    self:setPositionForPopoutManager()
end

function PanelOne:popout()
    self.allowBackKeyTap = true
    PopoutManager:sharedInstance():add(self, true)
    --local key = "invite.friend.reward.remove.force.pop." .. (UserManager:getInstance().user.uid or '12345')
    --CCUserDefault:sharedUserDefault():setBoolForKey(key, true)
end

function PanelOne:onCloseBtnTapped( ... )
    if self.callback then self.callback() end
    UserLocalLogic:setBAFlag(kBAFlagsIdx.kInviteFriendRewardRemovePopout)
	PopoutManager:sharedInstance():remove(self)
end

function PanelOne:onOKBtnTapped( ... )
	self:onCloseBtnTapped()
end

local RewardRender = class(BaseUI)
function RewardRender:create()
    local render = RewardRender.new()
    render:init()
    return render
end

function RewardRender:init()
    -- body
end


local PanelTwo = class(BasePanel)
function PanelTwo:create(callback)
    local panel = PanelTwo.new()
    panel:loadRequiredResource("ui/InviteFriendRewardRemovePanel.json")
    panel:init(callback)
    return panel
end

function PanelTwo:init(callback)
    self.callback = callback

    local ui = self:buildInterfaceGroup("InviteFriendRewardRemovePanel/panel2")
    BasePanel.init(self, ui)

    self.info_tf = self.ui:getChildByName('info_tf')
    self.info_tf:setString("     您有未领取奖励如下,现一起发放：")
    self.reward1 = self.ui:getChildByName('reward1')
    self.reward2 = self.ui:getChildByName('reward2')
    self.reward3 = self.ui:getChildByName('reward3')

    for i=1, 3 do 
        local item = self["reward"..i]
        local num_tf = item:getChildByName("num_tf")
        num_tf:changeFntFile('fnt/event_default_digits.fnt')
        num_tf:setAnchorPoint(ccp(1,0))
        local pos = num_tf:getPosition()
        num_tf:setPosition(ccp(pos.x + 30, pos.y -45))
    end

    self.arrow_left = self.ui:getChildByName('arrow_left')
    self.arrow_left:setTouchEnabled(true, 0, true)
    self.arrow_left:ad(DisplayEvents.kTouchTap, function () 
        self.page = self.page - 1
        self:renders()
    end)

    self.arrow_right = self.ui:getChildByName('arrow_right')
    self.arrow_right:setTouchEnabled(true, 0, true)
    self.arrow_right:ad(DisplayEvents.kTouchTap, function () 
        self.page = self.page + 1
        self:renders()
    end)

    self.close_btn = self.ui:getChildByName('close_btn')
    self.close_btn:setTouchEnabled(true, 0, true)
    self.close_btn:ad(DisplayEvents.kTouchTap, function () 
        self:onCloseBtnTapped() 
    end)

    self.ok_btn = GroupButtonBase:create(self.ui:getChildByName('ok_btn'))
    self.ok_btn:setString("领取")
    self.ok_btn:setColorMode(kGroupButtonColorMode.green)
    self.ok_btn:ad(DisplayEvents.kTouchTap, function( )
        self:onOKBtnTapped()
    end)

    self:scaleAccordingToResolutionConfig()
    self:setPositionForPopoutManager()
end

function PanelTwo:setData(data)
    self.data = data
    self.page = 1
    self.pageSize = 3
    self.totalPage = math.modf((table.size(data) + self.pageSize - 1) / self.pageSize)
    self:renders()
end

function PanelTwo:renders()
    local data = self:getPageData()
    for i = 1, self.pageSize do
        local item = self["reward"..i]
        if #data >= i then
            item:setVisible(true)
            local reward = data[i]
            local num_tf = item:getChildByName("num_tf")
            if item.icon then  item.icon:removeFromParentAndCleanup(true) end
            item.icon = ResourceManager:sharedInstance():buildItemSprite(reward.id)
            item.icon:setPosition(ccp(50, -50))
            item:addChild(item.icon)
            num_tf:setText("x"..reward.num)
        else
            item:setVisible(false)
        end
    end

    local enable = self.page ~= 1 and true or false
    self.arrow_left:setVisible(enable)
    self.arrow_left:setTouchEnabled(enable)

    enable = self.page ~= self.totalPage and true or false
    self.arrow_right:setVisible(enable)
    self.arrow_right:setTouchEnabled(enable)
end

function PanelTwo:getPageData()
    local data = {}
    local i = 1
    local beginIndex = self.page * self.pageSize + 1
    for k, v in pairs(self.data) do 
        if i >= ((self.page - 1) * self.pageSize + 1) and i <= ((self.page - 1) * self.pageSize + 3) then
            table.insert(data, {id = k, num = v}) 
        end
        i = i + 1
    end

    return data
end

function PanelTwo:popout()
    self.allowBackKeyTap = true
    PopoutManager:sharedInstance():add(self, true)
end

function PanelTwo:onCloseBtnTapped( ... )
    if self.callback then self.callback() end
    PopoutManager:sharedInstance():remove(self)
end

function PanelTwo:onOKBtnTapped( ... )
    self.ok_btn:setEnabled(false)

    local function onSuccess(event)
        if self.isDisposed then return end

        UserLocalLogic:setBAFlag(kBAFlagsIdx.kInviteFriendRewardRemovePopout)
        HomeScene:sharedInstance():checkDataChange()

        local function onFlyFinished()
            self:onCloseBtnTapped()
        end

        local rewards = self.data or {}
        local animArray = {}
        local idx = 1
        for k,v in pairs(rewards) do
            local item = self["reward2"]
            if idx <= 3 then
                item = self["reward"..idx]
            end
            local bounds = item:getGroupBounds()
            local startPos = ccp(bounds:getMidX(), bounds:getMidY())

            local anim = FlyItemsAnimation:create({{itemId = k, num = math.min(v,10)}})
            anim:setWorldPosition(startPos)
            table.insert(animArray, anim)
            idx = idx + 1
        end

        local counter = 0
        local function callback( ... )
            counter = counter + 1
            if counter >= #animArray then
                onFlyFinished()
            end 
        end

        for _, anim in ipairs(animArray) do
            anim:setFinishCallback(callback)
            anim:play()
        end
    end

    local function onFail()
        if self.isDisposed then return end
        self.ok_btn:setEnabled(true)
    end

    local http = GetInviteFriendsReward.new(true)
    http:addEventListener(Events.kComplete, onSuccess)
    http:addEventListener(Events.kError, onFail)
    http:load('0')
end

local InviteFriendRewardRemovePanel = class()

function InviteFriendRewardRemovePanel:create(callback, data)
    local panel
    if table.size(data) > 0 then
        panel = PanelTwo:create(callback)
        panel:setData(data)
    else
        panel = PanelOne:create(callback)
    end
    return panel
end

return InviteFriendRewardRemovePanel