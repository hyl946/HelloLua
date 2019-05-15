local UIHelper = require 'zoo.panel.UIHelper'
local Misc = require 'zoo.quarterlyRankRace.utils.Misc'

local RankRaceDanHistory = require 'zoo.quarterlyRankRace.view.RankRaceDanHistory'

local rrMgr


local RankRaceDanPanel = class(BasePanel)

function RankRaceDanPanel:create()

    if not RankRaceMgr then
        require 'zoo.quarterlyRankRace.RankRaceMgr'
    end

    rrMgr = RankRaceMgr:getInstance()


    local panel = RankRaceDanPanel.new()
    panel:init()
    return panel
end

function RankRaceDanPanel:init()
    local ui = UIHelper:createUI('ui/RankRace/dan.json', 'rank.dan_/rank.dan')
	BasePanel.init(self, ui)

    self.page = self.ui:getChildByPath('pageView')
    self.page:setShowedRange(1)

    self.danRewardCfg = rrMgr:getMeta():getDanRewardConfig()
    self.dan = rrMgr:getData():getDan()
    self.prommotionCfg = rrMgr:getMeta():getPromotionRate()
    self.details = rrMgr:getMeta():getDanDetails()

    for i = 1, 10 do
        self:refreshPageView(self.page:findChildByName('page' .. i), i)
    end

    self.bar = self.ui:getChildByPath('bar')


    for i = 1, 999 do
        local btn = self.bar:getChildByPath(tostring(i))
        if btn then
            local pageIndex = i
            UIUtils:setTouchHandler(btn:getChildByPath('1'), function ( ... )
                if self.isDisposed then return end
                self.page:turnTo(pageIndex)
            end)
        else
            break
        end
    end

    self.page:turnTo(math.clamp(self.dan, 1, 10), 0)


    local SaijiIndex = RankRaceMgr.getInstance():getCurSaijiIndex()
    if SaijiIndex == 1 then
        --历史记录
        self.history = self.ui:getChildByPath('history')
        self.history:setVisible(false)
    else
        --历史记录
        self.history = self.ui:getChildByPath('history')
        self.history:setTouchEnabled(true, 0, true)
        self.history:ad(DisplayEvents.kTouchTap, function ( ... )
            local historyPanel = RankRaceDanHistory:create()
            historyPanel:popout()
        end)
    end


    rrMgr:addObserver(self)
end

function RankRaceDanPanel:dispose( ... )
    rrMgr:removeObserver(self)
    BasePanel.dispose(self, ...)
end


function RankRaceDanPanel:onNotify( obKey, ...)
    if self.isDisposed then return end
    if self['_handle_' .. obKey] then
        self['_handle_' .. obKey](self, ...)
        return
    end
end

function RankRaceDanPanel:_handle_kPassDay( ... )
    if self.isDisposed then return end
    self:onCloseBtnTapped()
end


function RankRaceDanPanel:refreshPageView( pageUI, dan )
    if self.isDisposed then return end

    local title = pageUI:getChildByPath('title')
    title:changeFntFile('fnt/newzhousai_title.fnt')
    title:setText(localize('rank.race.dan.panel.title.' .. dan))
    title:setAnchorPoint(ccp(0.5, 1))
    title:setPositionX(360)

    local hbox = pageUI:findChildByName('hbox')
    local rewardCfg = self.danRewardCfg[dan]
    local hasGotRewarded = false
    if dan <= 9 and rewardCfg then
        if dan+1 <= rrMgr:getData():getRewardedDan() then
            hasGotRewarded = true
            hbox:removeFromParentAndCleanup(true)
        else
            pageUI:getChildByPath('rewarded'):removeFromParentAndCleanup(true)
            for i = 1, 3 do
                v = rewardCfg[i]
                local item = hbox:findChildByName('item' .. i)
                if v then
                    item:setFlagOffset(0, -10)
                    item:setRewardItem(v, true)
                else
                    hbox:removeItem(item)
                end
            end
            -- local w = hbox:getWidth()
            -- local bgW = pageUI:getChildByPath('bg6'):getPreferredSize().width
            -- UIHelper:move(hbox, (bgW-w)/2)
        end
    end

    if dan <= 9 and not hasGotRewarded then
        local label = pageUI:getChildByPath('label')
        if self.dan == dan then
            label:setString(string.format('本周排行前%s即可升级，奖励：', self.prommotionCfg[dan][2]))
        else
            label:setString(string.format(localize('rank.race.dan.levelup.desc.' .. dan)))
        end
    end

    if dan == 10 then
        local friendNum = pageUI:getChildByPath('friendNum')
        friendNum:changeFntFile('fnt/register2.fnt')
        friendNum:setColor(hex2ccc3('FFCC33'))
        friendNum:setText(string.format('%3d好友', rrMgr:getData():getSendGiftNum()))
        friendNum:setScale(0.8)
        UIHelper:move(friendNum, 0, 0)

        --第一赛季以后红包显示介绍
        local SaijiIndex = RankRaceMgr.getInstance():getCurSaijiIndex()
        if SaijiIndex == 1 then
             --问号提示
            local newHeadIntroduce = pageUI:getChildByPath('newHeadIntroduce')
            newHeadIntroduce:setVisible(false)

            --问号
            local newHeadQuestion = pageUI:getChildByPath('newHead')
            newHeadQuestion:setVisible(false)
        else
            --问号提示
            local newHeadIntroduce = pageUI:getChildByPath('newHeadIntroduce')
            newHeadIntroduce:setVisible(false)
            newHeadIntroduce:setScale(0.1)

            local bRunAction = false

            --问号
            local newHeadQuestion = pageUI:getChildByPath('newHead')
            newHeadQuestion:setTouchEnabled(true, 0, true)
            newHeadQuestion:ad(DisplayEvents.kTouchTap, function ( ... )

                if bRunAction == false  then
                    bRunAction = true

                    local function MoveOut()
                        bRunAction = false
                        newHeadIntroduce:setVisible(false)
                    end

                    local array = CCArray:create()
	                array:addObject( CCScaleTo:create(0.2, 1.1) )
                    array:addObject( CCScaleTo:create(0.1, 0.9) )
                    array:addObject( CCScaleTo:create(0.1, 1) )
                    array:addObject( CCDelayTime:create(3) )
                    array:addObject( CCScaleTo:create(0.2, 0.1) )
                    array:addObject( CCCallFunc:create( MoveOut ) )

                    newHeadIntroduce:setScale(0.1)
                    newHeadIntroduce:stopAllActions()
                    newHeadIntroduce:runAction( CCSequence:create(array) )
                    newHeadIntroduce:setVisible(true)
                end
            end)
        end

        if rrMgr:isTaskFinished() then
            pageUI:getChildByPath('bottomText3'):setVisible(false)
            pageUI:getChildByPath('stone'):setVisible(false)
            pageUI:getChildByPath('stoneNum'):setVisible(false)

        else
            pageUI:getChildByPath('bottomText2'):setVisible(false)

            local stoneNum = pageUI:getChildByPath('stoneNum')
            stoneNum:changeFntFile('fnt/register2.fnt')
            stoneNum:setColor(hex2ccc3('FFCC33'))
            stoneNum:setText('x' .. (rrMgr:getMeta():getTaskTarget() - rrMgr:getData():getTodayTC0()))
            stoneNum:setScale(0.9)
            stoneNum:setAnchorPoint(ccp(0.5, 0.5))
            UIHelper:move(stoneNum, stoneNum.width/2, -stoneNum.height/2)
        end


        local button1 = GroupButtonBase:create(pageUI:getChildByPath('button1'))
        local button2 = GroupButtonBase:create(pageUI:getChildByPath('button2'))
        button1:setString('微信好友')
        button2:setString('游戏好友')

        button1:ad(DisplayEvents.kTouchTap, function ( ... )
            self:onButtonTap('button1')
        end)
        button2:ad(DisplayEvents.kTouchTap, function ( ... )
            self:onButtonTap('button2')
        end)

        button1:setEnabled(not (dan > self.dan))
        button2:setEnabled(not (dan > self.dan))

        if (not Misc:isSupportShare()) then
            button1:setVisible(false)
            local x = button2:getPositionX() + button1:getPositionX()
            button2:setPositionX(x/2)
        end


        if WXJPPackageUtil.getInstance():isWXJPPackage() then 
            local authorType = SnsProxy:getAuthorizeType()
            if authorType == PlatformAuthEnum.kJPQQ then
                button1:setString('QQ好友')
            end
        end


    end

    pageUI:getChildByPath('lock'):setVisible(dan > self.dan)
    pageUI:getChildByPath('darkLayer'):setVisible(dan > self.dan)

    



    local leftContent = pageUI:getChildByPath('leftContent')
    local infos = self.details[dan]
    self:setLeftInfo(leftContent:findChildByName('item1'), '● 大招伤害血量: ', '50%')
    self:setLeftInfo(leftContent:findChildByName('item2'), '● 大招提前充能: ', '' .. infos.preFillPercent .. '%')
    self:setLeftInfo(leftContent:findChildByName('item3'), '● 大招释放特效: ', '' .. infos._throwEffect .. "个")
    self:setLeftInfo(leftContent:findChildByName('item4'), '● 地鼠多掉宝石: ', '' .. infos._throwReward .. "个")
    self:setLeftInfo(leftContent:findChildByName('item5'), '● 加5步气球概率: ', '' .. infos.throwAddStepPercent .. "%")

    leftContent:updateItemsHeight()
    leftContent:pluginRefresh()


    local rightContent = pageUI:getChildByPath('rightContent')
    local infos = self.details[dan]
    for _, v in ipairs(infos.skills) do
        rightContent:addItem(self:createSkillInfo(v))
    end
end

function RankRaceDanPanel:createSkillInfo( skillName )
    if self.isDisposed then return end

    local ui = UIHelper:createUI('ui/RankRace/dan.json', 'rank.dan_/skillInfo')

    local skillNameMapRes = {
        s = 'skill_1',
        m = 'skill_2',
        f = 'skill_5',
        cA = 'skill_3',
        cB = 'skill_3',
        cC = 'skill_3',
        t = 'skill_4'
    }

    local sp = Sprite:createWithSpriteFrameName('rank.dan_/' .. skillNameMapRes[skillName] .. '0000')

    UIUtils:positionNode(ui:getChildByPath('icon'), sp, true)

    local label = ui:getChildByPath('label')
    local dimensions = label:getDimensions()
    label:setDimensions(CCSizeMake(dimensions.width, 0))

    label:setString(localize('rank.race.dan.panel.skill.desc.' .. skillName))

    return ui

end

function RankRaceDanPanel:setLeftInfo( itemUI, key, value )
    if self.isDisposed then return end
    itemUI:getChildByPath('key'):setString(key)
    local valueUI = itemUI:getChildByPath('value')
    valueUI:changeFntFile('fnt/register2.fnt')
    valueUI:setColor(hex2ccc3('CC6600'))
    valueUI:setText(' ' .. tostring(value))
end

function RankRaceDanPanel:_close()
	self.allowBackKeyTap = false
	PopoutManager:sharedInstance():remove(self)
end

function RankRaceDanPanel:popout()
    self:scaleAccordingToResolutionConfig()
    self:setPositionForPopoutManager()
    self:setPositionX(self:getPositionX() + 0)
	PopoutManager:sharedInstance():add(self, true, nil, nil, nil, 200)
	self.allowBackKeyTap = true


    -- local layoutUtils =  require 'zoo.panel.happyCoinShop.utils'
    -- layoutUtils.setNodeRelativePos(self.bar, layoutUtils.MarginType.kBOTTOM, 32)
end

function RankRaceDanPanel:onCloseBtnTapped( ... )
    self:_close()
end

function RankRaceDanPanel:onButtonTap( buttonName )
    if self.isDisposed then return end
    if buttonName == 'descBtn' then
        local panel = require('zoo.quarterlyRankRace.view.RankRaceDescPanel'):create()
        panel:popout()
        panel:turnTo(2, 0)
        return true
    elseif buttonName == 'button1' then
        self:onButtonTap_1()
        return true
    elseif buttonName == 'button2' then
        self:onButtonTap_2()
        return true
    end
end


function RankRaceDanPanel:onButtonTap_1( ... )
    if self.isDisposed then return end

    if not rrMgr:isTaskFinished() then 
        local SaijiIndex = RankRaceMgr.getInstance():getCurSaijiIndex()
        if SaijiIndex == 1 then
            CommonTip:showTip(localize('rank.race.task.unfinished'))
        else
            CommonTip:showTip(localize('rank.race.task.unfinished.s2'))
        end
        return
    end

    RankRaceHttp:getShareKey(2, function ( evt )
        -- body
        local shareKey = evt.data.shareKey or ''

        if self.isDisposed then return end

        local uid = UserManager.getInstance().user.uid

        local webpageUrl = Misc:buildURL(NetworkConfig:getShareHost(), 'week_packet.jsp', {
            pid = StartupConfig:getInstance():getPlatformName() or '',
            game_name = 'Rank_race_gem',
            aaf = 5,
            invitecode = UserManager:getInstance().inviteCode,
            shareKey = shareKey,
            uid = uid,
        })

        local eShareType = SnsUtil.getShareType()

        local title = ""
        local message = ""
        local SaijiIndex = RankRaceMgr.getInstance():getCurSaijiIndex()
        if SaijiIndex == 1 then
            title = localize('rank.race.dan.panel.share.title')
            message = localize('rank.race.dan.panel.share.message')
        else
            title = localize('rank.race.dan.panel.share.title.s2')

            local lastRank = RankRaceMgr.getInstance().data:getLastWeekRank()
            local lastDan = RankRaceMgr.getInstance().data:getLastWeekDan()

            if lastDan == 10 then
                if lastRank <= 3 then
                    message = localize('rank.race.dan.panel.share.message.s21')
                elseif lastRank <= 30 then
                    message = localize('rank.race.dan.panel.share.message.s22')
                else
                    message = localize('rank.race.dan.panel.share.message.s23')
                end
            else
                message = localize('rank.race.dan.panel.share.message.s23')
            end
        end

        local thumbUrl = CCFileUtils:sharedFileUtils():fullPathForFilename("materials/rank_race_gift.jpg")

        local shareCallback = {
            onSuccess = function(result)
                CommonTip:showTip('分享成功', 'positive')
                if successCallback then successCallback() end
            end,
            onError = function(errCode, msg)
                CommonTip:showTip('分享失败')
                if failCallback then failCallback(1) end
            end,
            onCancel = function()       
                CommonTip:showTip('分享取消')
                if cancelCallback then cancelCallback(2) end
            end
        }

        local isSend2FriendCircle = false
        SnsUtil.sendLinkMessage(eShareType, title, message, thumbUrl, webpageUrl, isSend2FriendCircle, shareCallback)

    end)

end

function RankRaceDanPanel:onButtonTap_2( ... )
    if self.isDisposed then return end
    if not rrMgr:isTaskFinished() then 
        local SaijiIndex = RankRaceMgr.getInstance():getCurSaijiIndex()
        if SaijiIndex == 1 then
            CommonTip:showTip(localize('rank.race.task.unfinished'))
        else
            CommonTip:showTip(localize('rank.race.task.unfinished.s2'))
        end

        return
    end

    local askeduids = rrMgr:getData():getSendedUids()

    if #ChooseFriendPanel:getFriendList(askeduids) <= 0 then
        CommonTip:showTip(localize('dan.panel.nofriend'))
        return
    end

    local panel 
    panel = ChooseFriendPanel:create(function ( uids )
        
        if self.isDisposed then return end

        if #uids > 0 then

            if not panel.isDisposed then
                panel:onKeyBackClicked()
            end

            rrMgr:sendInGameGift(uids or {}, function ( ... )

                local SaijiIndex = RankRaceMgr.getInstance():getCurSaijiIndex()
                if SaijiIndex == 1 then
                    CommonTip:showTip(localize('rank.race.dan.send.gift.success'), 'positive')
                else
                    CommonTip:showTip(localize('rank.race.dan.send.gift.success.s2'), 'positive')
                end
            end)
        end 

    end, askeduids, true)

    panel:setAllSentCallback(function ( ... )
        
    end)

    panel:popout()

end

function RankRaceDanPanel:onPageTo( index )
    if self.isDisposed then return end
    for i = 1, 999 do
        local btn = self.bar:getChildByPath(tostring(i))
        if btn then
            btn:getChildByPath('1'):setVisible(index ~= i)
            btn:getChildByPath('2'):setVisible(index == i)
        else
            break
        end
    end
end

return RankRaceDanPanel
