ExchangePrePropPanel = class(BasePanel)

local DEBUG = false

local DebugNumber = 2
local DebugRefrashNumber = 0

function ExchangePrePropPanel:create(isDebug)
    if isDebug then
        DEBUG = true
        DebugNumber = 2
        DebugRefrashNumber = 0
    end
    local instance = ExchangePrePropPanel.new()
    instance:loadRequiredResource('ui/pre_prop_exchange_panel.json')
    instance:init()
    return instance
end

function ExchangePrePropPanel:init()
    self.hasBomb = self:getMixBombNum() > 0
    self.hasRefresh = self:getRefreshNum() > 0 and PrePropImproveLogic:isNewItemLogic()

    if DEBUG then self.hasRefresh = self:getRefreshNum() > 0 end

    if self.hasBomb then
        FrameLoader:loadArmature('skeleton/pre_prop_mix_animation', 'pre_prop_mix_animation', 'pre_prop_mix_animation')
    end

    if self.hasRefresh then
        FrameLoader:loadArmature('skeleton/pre_prop_exchange_animation', 'pre_prop_exchange_animation', 'pre_prop_exchange_animation')
    end

    local ui = self.builder:buildGroup('pre_prop_exchange/main_panel')
    BasePanel.init(self, ui)
    UIUtils:autoProperty(ui)

    self.btn = GroupButtonBase:create(self.ui.btn)
    self.btn:setString('领取')
    self.btn:ad(DisplayEvents.kTouchTap, function () self:onBtnTapped() end)

    if not self.hasBomb and not self.hasRefresh then
        self.state = "finish"
        self.btn:setString('关闭')
        return
    end

    -- self.ui.closeBtn:setTouchEnabled(true, 0, true)
    -- self.ui.closeBtn:ad(DisplayEvents.kTouchTap, function ()  self:onCloseBtnTapped() end )

    self:initAnims()

    self:changeTips(self.hasBomb)

    self:setScale(1)
    self:setPositionXY(0, 0)
    UIUtils:adjustUI(self.ui, 100)
end

function ExchangePrePropPanel:changeTips(isBomb)
    if self.owl then
        self.owl:removeFromParentAndCleanup(true)
    end

    if isBomb then
        self.owl = ArmatureNode:create('pre_prop_mix_animation_tips')
    else
        self.owl = ArmatureNode:create('pre_prop_exchange/owl')
    end

    self.ui:addChild(self.owl)

    self.owl:setPosition(UIUtils:getPosition(self.ui.owl_ph))
    self.ui.owl_ph:setVisible(false)
    self.owl:playByIndex(0, 0)
end

local function GetPreWrapBombNum()
    local user = UserManager:getInstance()
    if DEBUG then return DebugNumber end
    return user:getUserPropNumber(ItemType.PRE_WRAP_BOMB)
end

local function GetPreLineBombNum()
    local user = UserManager:getInstance()
    if DEBUG then return DebugNumber end
    return user:getUserPropNumber(ItemType.PRE_LINE_BOMB)
end

local function GetTimePreWrapBombNum()
    local user = UserManager:getInstance()
    if DEBUG then return DebugNumber end
    return user:getUserPropNumber(ItemType.TIMELIMIT_PRE_WRAP_BOMB)
end

local function GetTimePreLineBombNum()
    local user = UserManager:getInstance()
    if DEBUG then return DebugNumber end
    return user:getUserPropNumber(ItemType.TIMELIMIT_PRE_LINE_BOMB)
end

function ExchangePrePropPanel:getMixBombNum()
    local user = UserManager:getInstance()

    local wbomb_num = GetPreWrapBombNum()
    local lbomb_num = GetPreLineBombNum()

    local t_wbomb_num = GetTimePreWrapBombNum()
    local t_lbomb_num = GetTimePreLineBombNum()

    return wbomb_num + lbomb_num + t_wbomb_num + t_lbomb_num
end

function ExchangePrePropPanel:getBombNum()
    local user = UserManager:getInstance()
    local num = user:getUserPropNumber(ItemType.INITIAL_2_SPECIAL_EFFECT) + user:getUserPropNumber(ItemType.TIMELIMIT_INITIAL_2_SPECIAL_EFFECT)
    return num
end

function ExchangePrePropPanel:showMixBomb()
    self.state = 'exchange_bomb'
    if self.change then
        self.change:removeFromParentAndCleanup(true)
        self.change = nil
    end
    self.change = ArmatureNode:create('pre_prop_mix_animation')
    self.ui:addChild(self.change)
    self.change:setPosition(UIUtils:getPosition(self.ui.change_ph))
    self.ui.change_ph:setVisible(false)

    self.change:playByIndex(0)

    local wbomb_num = GetPreWrapBombNum()
    local lbomb_num = GetPreLineBombNum()

    local t_wbomb_num = GetTimePreWrapBombNum()
    local t_lbomb_num = GetTimePreLineBombNum()

    local wbomb = wbomb_num + t_wbomb_num
    local lbomb = lbomb_num + t_lbomb_num
    local num = wbomb > lbomb and wbomb or lbomb

    local function SetNumber(index, number )
        local slot = self.change:getSlot(tostring(index))
        if slot then
            local text = BitmapText:create("x"..tostring(number), 'fnt/star_entrance.fnt', 0)
            text:setAnchorPoint(ccp(0.5, 0.5))
            local sprite = Sprite:createEmpty()
            sprite:addChild(text)
            slot:setDisplayImage(sprite.refCocosObj)
        end
    end

    SetNumber(2, lbomb_num + t_lbomb_num)
    SetNumber(3, wbomb_num + t_wbomb_num)
    SetNumber(1, num)
end

function ExchangePrePropPanel:showBomb()
    self.state = 'exchange_bomb'
    if self.change then
        self.change:removeFromParentAndCleanup(true)
        self.change = nil
    end
    self.change = ArmatureNode:create('pre_prop_exchange/change')
    self.ui:addChild(self.change)
    self.change:setPosition(UIUtils:getPosition(self.ui.change_ph))
    self.ui.change_ph:setVisible(false)

    local num = self:getBombNum()
    for i = 1, 3 do
        local slot = self.change:getSlot(tostring(i))
        if slot then
            local text = BitmapText:create("x"..tostring(num), 'fnt/star_entrance.fnt', 0)
            text:setAnchorPoint(ccp(0.5, 0.5))
            local sprite = Sprite:createEmpty()
            sprite:addChild(text)
            slot:setDisplayImage(sprite.refCocosObj)
        end
    end
end

function ExchangePrePropPanel:getRefreshNum()
    local user = UserManager:getInstance()
    local num = user:getUserPropNumber(ItemType.INGAME_PRE_REFRESH) + user:getUserPropNumber(ItemType.TIMELIMIT_INGAME_PRE_REFRESH)
    if DEBUG then return DebugRefrashNumber end
    --do not exchange refresh
    return 0
end

function ExchangePrePropPanel:showRefresh(fromShowBomb)
    self.state = 'exchange_refresh'
    if self.change then
        self.change:removeFromParentAndCleanup(true)
        self.change = nil
    end

    self:changeTips()

    if fromShowBomb then
        local function cb()
            self.owl:playByIndex(2, 0)
        end
        self.owl:playByIndex(1, 1)
        self.owl:ad(ArmatureEvents.COMPLETE,cb)
    else
        self.owl:playByIndex(2, 0)
    end
    self.change = ArmatureNode:create('refresh/refresh123')
    self.ui:addChild(self.change)
    self.change:setPosition(UIUtils:getPosition(self.ui.change_ph))
    self.ui.change_ph:setVisible(false)
    
    local num = self:getRefreshNum()
    local names = {'1_0', 2}
    for i = 1, 2 do
        local slot = self.change:getSlot(names[i])
        if slot then
            local text = BitmapText:create("x"..tostring(num), 'fnt/star_entrance.fnt', 0)
            text:setAnchorPoint(ccp(0.5, 0.5))
            local sprite = Sprite:createEmpty()
            sprite:addChild(text)
            slot:setDisplayImage(sprite.refCocosObj)
        end
    end
end

function ExchangePrePropPanel:mixBomb( finishCallback )
    local function onSuccess(evt)
        local user = UserManager:getInstance()
        local service = UserService:getInstance()

        local wbomb_num = GetPreWrapBombNum()
        local lbomb_num = GetPreLineBombNum()

        local t_wbomb_num = GetTimePreWrapBombNum()
        local t_lbomb_num = GetTimePreLineBombNum()

        local wbomb = wbomb_num + t_wbomb_num
        local lbomb = lbomb_num + t_lbomb_num
        local num = wbomb > lbomb and wbomb or lbomb

        user:addUserPropNumber(ItemType.PRE_WRAP_BOMB, -wbomb_num)
        user:addUserPropNumber(ItemType.PRE_LINE_BOMB, -lbomb_num)
        user:addUserPropNumber(ItemType.INITIAL_2_SPECIAL_EFFECT, num)

        service:addUserPropNumber(ItemType.PRE_WRAP_BOMB, -wbomb_num)
        service:addUserPropNumber(ItemType.PRE_LINE_BOMB, -lbomb_num)
        service:addUserPropNumber(ItemType.INITIAL_2_SPECIAL_EFFECT, num)

        for i=1, t_wbomb_num do
            user:useTimeProp(ItemType.TIMELIMIT_PRE_WRAP_BOMB)
            service:useTimeProp(ItemType.TIMELIMIT_PRE_WRAP_BOMB)
        end

         for i=1, t_lbomb_num do
            user:useTimeProp(ItemType.TIMELIMIT_PRE_LINE_BOMB)
            service:useTimeProp(ItemType.TIMELIMIT_PRE_LINE_BOMB)
        end

        Localhost:flushCurrentUserData()

        local function finish( ... )
            if finishCallback then finishCallback() end

            local itemSlot = self.change:getSlot("1")
            if not itemSlot then
                return 
            end

            local number = tolua.cast(itemSlot:getCCDisplay(), "CCSprite")
            local posx = number:getPositionX()
            local posy = number:getPositionY()
            local pos = number:getParent():convertToWorldSpace(ccp(posx, posy))

            local anim = FlyItemsAnimation:create({{itemId = ItemType.INITIAL_2_SPECIAL_EFFECT, num = 1}})
            anim:setScale(1.8)
            anim:setWorldPosition(ccp(pos.x+18, pos.y+65))
            anim:setFinishCallback(function()
            end)
            anim:play()
        end
        self.change:playByIndex(1, 1)
        self.change:ad(ArmatureEvents.COMPLETE, finish)

        if DEBUG then DebugNumber = 0 end
    end

    local function onFail(evt)
    end

    self.state = nil

    if DEBUG then
        return onSuccess()
    end

    local http = OpNotifyOffline.new()
    http:ad(Events.kComplete, onSuccess)
    http:ad(Events.kError, onFail)
    http:load(OpNotifyOfflineType.kMixPreBombLine)
end

function ExchangePrePropPanel:exchangeBomb(finishCallback)
    local function onSuccess(evt)
        self.change:playByIndex(1, 1)
        if finishCallback then
            self.change:ad(ArmatureEvents.COMPLETE, finishCallback)
        end
        local user = UserManager:getInstance()
        local service = UserService:getInstance()
        local bomb_line_num = user:getUserPropNumber(ItemType.INITIAL_2_SPECIAL_EFFECT)
        user:addUserPropNumber(ItemType.INITIAL_2_SPECIAL_EFFECT, -bomb_line_num)
        user:addUserPropNumber(ItemType.PRE_WRAP_BOMB, bomb_line_num)
        user:addUserPropNumber(ItemType.PRE_LINE_BOMB, bomb_line_num)
        service:addUserPropNumber(ItemType.INITIAL_2_SPECIAL_EFFECT, -bomb_line_num)
        service:addUserPropNumber(ItemType.PRE_WRAP_BOMB, bomb_line_num)
        service:addUserPropNumber(ItemType.PRE_LINE_BOMB, bomb_line_num)

        local time_bomb_line_num = user:getUserPropNumber(ItemType.TIMELIMIT_INITIAL_2_SPECIAL_EFFECT)
        user:addUserPropNumber(ItemType.TIMELIMIT_PRE_WRAP_BOMB, time_bomb_line_num)
        user:addUserPropNumber(ItemType.TIMELIMIT_PRE_LINE_BOMB, time_bomb_line_num)
        service:addUserPropNumber(ItemType.TIMELIMIT_PRE_WRAP_BOMB, time_bomb_line_num)
        service:addUserPropNumber(ItemType.TIMELIMIT_PRE_LINE_BOMB, time_bomb_line_num)

        for i=1, time_bomb_line_num do
            user:useTimeProp(ItemType.TIMELIMIT_INITIAL_2_SPECIAL_EFFECT)
            service:useTimeProp(ItemType.TIMELIMIT_INITIAL_2_SPECIAL_EFFECT)
        end

        Localhost:flushCurrentUserData()

    end
    local function onFail(evt)
    end
    self.state = nil
    local http = OpNotifyOffline.new()
    http:ad(Events.kComplete, onSuccess)
    http:ad(Events.kError, onFail)
    http:load(OpNotifyOfflineType.kExchangePreBombLine)
end

function ExchangePrePropPanel:exchangeRefresh(finishCallback)
    
    local function onSuccess(evt)
        if DEBUG then DebugRefrashNumber = 0 end

        self.change:playByIndex(1, 1)
        if finishCallback then
            self.change:ad(ArmatureEvents.COMPLETE, finishCallback)
        end
        local user = UserManager:getInstance()
        local service = UserService:getInstance()
        local refresh_num = user:getUserPropNumber(ItemType.INGAME_PRE_REFRESH)
        user:addUserPropNumber(ItemType.INGAME_PRE_REFRESH, -refresh_num)
        user:addUserPropNumber(ItemType.INGAME_REFRESH, refresh_num)
        service:addUserPropNumber(ItemType.INGAME_PRE_REFRESH, -refresh_num)
        service:addUserPropNumber(ItemType.INGAME_REFRESH, refresh_num)


        local time_refresh_num = user:getUserPropNumber(ItemType.TIMELIMIT_INGAME_PRE_REFRESH)
        user:addUserPropNumber(ItemType.TIMELIMIT_REFRESH, time_refresh_num)
        service:addUserPropNumber(ItemType.TIMELIMIT_REFRESH, time_refresh_num)
        for i=1, time_refresh_num do
            user:useTimeProp(ItemType.TIMELIMIT_INGAME_PRE_REFRESH)
            service:useTimeProp(ItemType.TIMELIMIT_INGAME_PRE_REFRESH)
        end
        Localhost:flushCurrentUserData()

        self.btn:setString('关闭')

    end
    local function onFail(evt)
    end
    self.state = nil

    if DEBUG then return onSuccess() end

    local http = OpNotifyOffline.new()
    http:ad(Events.kComplete, onSuccess)
    http:ad(Events.kError, onFail)
    http:load(OpNotifyOfflineType.kExchangePreRefresh)
end

function ExchangePrePropPanel:initAnims(fromShowBomb)
    if self:getMixBombNum() > 0 then
        self:showMixBomb()
    elseif self:getRefreshNum() > 0 and (PrePropImproveLogic:isNewItemLogic() or DEBUG) then
        self:showRefresh(fromShowBomb)
    else
        self.state = 'finish'
        self.btn:setString('关闭')
    end
end

function ExchangePrePropPanel:onBtnTapped()
    if self.state == 'exchange_refresh' then
        self:exchangeRefresh(function() self:initAnims() end)
    elseif self.state == 'exchange_bomb' then
        self:mixBomb(function() self:initAnims(true) end)
    elseif self.state == 'finish' then
        self:onCloseBtnTapped()
    else
        
    end
end

function ExchangePrePropPanel:popout(closeCallback)
    PopoutManager:sharedInstance():add(self, true)
    self.closeCallback = closeCallback
    -- local vs = Director:sharedDirector():getVisibleSize()
    -- local vo = Director:sharedDirector():getVisibleOrigin()
    -- local pos = ccp(vo.x + vs.width - 50, vo.y + vs.height - 50)
    -- self.ui.closeBtn:setPosition(self.ui:convertToNodeSpace(pos))
end

function ExchangePrePropPanel:onCloseBtnTapped()
    PopoutManager:sharedInstance():remove(self)
    if self.hasRefresh then
        FrameLoader:unloadArmature('skeleton/pre_prop_exchange_animation', true)
    end
    if self.hasBomb then
        FrameLoader:unloadArmature('skeleton/pre_prop_mix_animation', true)
    end
    if self.closeCallback then
        self.closeCallback()
    end
end

