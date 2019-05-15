local UIHelper = require 'zoo.panel.UIHelper'
local Misc = require 'zoo.quarterlyRankRace.utils.Misc'

local rrMgr


local RankRaceGiftPanel = class(BasePanel)

function RankRaceGiftPanel:create()

    if not RankRaceMgr then
        require 'zoo.quarterlyRankRace.RankRaceMgr'
    end

    rrMgr = RankRaceMgr:getInstance()

    local panel = RankRaceGiftPanel.new()
    panel:init()
    return panel
end

function RankRaceGiftPanel:init()
    local ui = UIHelper:createUI('ui/RankRace/small_panel.json', 'rank.smallpan/gift')
	BasePanel.init(self, ui)

    RankRaceHttp:getGiftInfo(function ( evt )
        if self.isDisposed then return end
        local gifts = evt.data.gifts or {}

        rrMgr:setHasGifts(#gifts > 0)

        local receiveLogs = evt.data.receiveLogs or {}
        self:buildPage_1(gifts)
        self:buildPage_2(receiveLogs)


    end, function ( ... )
        CommonTip:showNetworkAlert()
    end)

    self.ui:getChildByPath('tab'):turnTo(2)
end

function RankRaceGiftPanel:buildPage_1( gifts )
    if self.isDisposed then return end
    -- body

    local page1 = self.ui:findChildByName('page1')

    self:removeZeroItem(page1)

    local num = rrMgr:getMeta():getInGameGiftNum()

    local SaijiIndex = RankRaceMgr.getInstance():getCurSaijiIndex()


    local num = rrMgr:getMeta():getInGameGiftNum()
    local function sortReceive( a, b )
        local infoa = Misc:parse(a, ',')
        local infob = Misc:parse(b, ',')

        local GetNumA = tonumber(infoa[3]) or 5
        local GetNumB = tonumber(infob[3]) or 5

        local sendTimeA = tonumber(infoa[2] or '0') or 0
        local sendTimeB = tonumber(infob[2] or '0') or 0

        if GetNumA ~= GetNumB then
            return GetNumA > GetNumB
        elseif GetNumA == GetNumB then
            return sendTimeA < sendTimeB
        end
    end
    table.sort( gifts, sortReceive )

    for i = 1, 10 do 
        if not gifts[i] then
            break
        end

        local info = Misc:parse(gifts[i], ',')
        local uid = info[1] or '12345'
        local sendTime = tonumber(info[2] or '0') or 0
        local name = FriendManager.getInstance():getFriendName(uid)
        local getNum = info[3] or 5

        name = Misc:truncat(name, 5)
        local data = {index = i, uid = uid}

        local itemUI = UIHelper:createUI('ui/RankRace/small_panel.json', 'rank.smallpan/item1')
        if SaijiIndex == 1 then
            itemUI:getChildByPath('label'):setString(string.format('好友%s送你%d个金宝石', name, getNum))
        else
            itemUI:getChildByPath('label'):setString(string.format('好友%s送你%d个黄金地鼠', name, getNum))
        end
        local button = GroupButtonBase:create(itemUI:getChildByPath('btn'))
        button:setString('领取')
        button:ad(DisplayEvents.kTouchTap, function ( ... )
            if self.isDisposed then return end
            self:onGiftTap(itemUI, getNum) 
        end)
        itemUI.userData = data
        -- itemUI.onButtonTap = function ( ... )
        --    self:onGiftTap(itemUI, getNum) 
        --    return true
        -- end
        page1:addItem(itemUI)

    end


    if page1:getItemNum() <= 0 then
        self:setPageZero(page1)
    end
end

function RankRaceGiftPanel:setPageZero( page )
    if self.isDisposed then return end
    local itemUI = UIHelper:createUI('ui/RankRace/small_panel.json', 'rank.smallpan/item2')
    itemUI:getChildByPath('label'):setString('暂无记录')
    page:addItem(itemUI)
    page.zeroItem = itemUI
end


local function time2day(ts)
    local utc8TimeOffset = 57600 -- (24 - 8) * 3600
    local oneDaySeconds = 86400 -- 24 * 3600
    local dayStart = ts - ((ts - utc8TimeOffset) % oneDaySeconds)
    return (dayStart + 8*3600)/24/3600
end


function RankRaceGiftPanel:onGiftTap( itemUI, friendGiveNum )

    if self.isDisposed then return end
    if itemUI.isDisposed then return end
    local page1 = self.ui:findChildByName('page1')
    rrMgr:receiveInGameGift({itemUI.userData.uid}, function ( ... )
        CommonTip:showTip('领取成功', 'positive')
        self:remove(itemUI, page1)
        self:buildPage_2({string.format('false,%s,%d,%s,%d', time2day(Localhost:timeInSec()), 3, FriendManager.getInstance():getFriendName(itemUI.userData.uid) or '消消乐玩家', friendGiveNum) }, true)
        self:buildPage_1{}
    end, function ( evt )
        local errcode = evt and evt.data
        if errcode then
            CommonTip:showTip(localize('error.tip.' .. errcode))
            -- self:remove(itemUI, page1)
            -- self:buildPage_1{}
        else
            CommonTip:showNetworkAlert()
        end

    end, function ( evt )
    end, friendGiveNum )
end

function RankRaceGiftPanel:remove( itemUI, page )
    -- body
    if self.isDisposed then return end
    if itemUI.isDisposed then return end
    page:removeItem(itemUI)
end

function RankRaceGiftPanel:removeZeroItem( page )
    -- body
    if self.isDisposed then return end
    if page.zeroItem then
        page:removeItem(page.zeroItem)
        page.zeroItem = nil
    end
end

function RankRaceGiftPanel:buildPage_2( receiveLogs , reverse)
    if self.isDisposed then return end
    -- body

    local page2 = self.ui:findChildByName('page2')

    self:removeZeroItem(page2)

    local num = rrMgr:getMeta():getInGameGiftNum()

    for i, v in ipairs(receiveLogs) do 

        local info = Misc:parse(v, ',')

        local isMySelf = info[1] or ''
        local day = info[2] or '12345'
        local _type = info[3] or '1'
        local nickname = info[4] or '消消乐玩家'
        local GetNum = tonumber(info[5]) or 5

        nickname = nameDecode(nickname)
        nickname = Misc:truncat(nickname, 5)

        local ts = (tonumber(day) or 1) * 3600 * 24 - 8 * 3600
        local date = os.date('*t', ts)

        local SaijiIndex = RankRaceMgr.getInstance():getCurSaijiIndex()
        local key = ""
        if SaijiIndex == 1 then
            key = 'rank.race.gift.history.' .. _type
        else
            key = 'rank.race.gift.history.' .. _type .. ".s2"
        end

        if string.lower(isMySelf) == 'true' then

            local SaijiIndex = RankRaceMgr.getInstance():getCurSaijiIndex()
            local key = ""
            if SaijiIndex == 1 then
                key = 'rank.race.gift.myself.history.' .. _type
            else
                key = 'rank.race.gift.myself.history.' .. _type .. ".s2"
            end
        end

        local text = localize(key, {
            nickname = nickname,
            year = date.year,
            month = date.month,
            day = date.day,
            num1 = rrMgr:getMeta():getShareTargetNum(),
            num2 = GetNum,
        })

        local data = {index = i, uid = uid}
        local itemUI = UIHelper:createUI('ui/RankRace/small_panel.json', 'rank.smallpan/item2')
        local label = itemUI:getChildByPath('label')
        local dimensions = label:getDimensions()
        label:setDimensions(CCSizeMake(dimensions.width, 0))
        label:setString(text)
        local line = itemUI:getChildByPath('line')
        line:setPositionY(36 - label:getContentSize().height + line:getPositionY())

        if reverse then
            page2:addItem(itemUI, 1)
        else
            page2:addItem(itemUI)
        end
    end


    if page2:getItemNum() <= 0 then
        self:setPageZero(page2)
    end

end

function RankRaceGiftPanel:_close()
	self.allowBackKeyTap = false
	PopoutManager:sharedInstance():remove(self)
end

function RankRaceGiftPanel:popout()
    self:scaleAccordingToResolutionConfig()
    self:setPositionForPopoutManager()
    self:setPositionX(self:getPositionX() + 0)
	PopoutManager:sharedInstance():add(self, true)
	self.allowBackKeyTap = true

end

function RankRaceGiftPanel:onCloseBtnTapped( ... )
    self:_close()
end

return RankRaceGiftPanel
