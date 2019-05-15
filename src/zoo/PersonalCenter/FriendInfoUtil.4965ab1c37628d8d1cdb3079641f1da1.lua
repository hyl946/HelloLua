local DataTracking = require "zoo.panel.component.friendsPanel.misc.DataTracking"

local FriendInfoUtil = class()

local function defineHttp( name )
    local http = class(HttpBase)
    function http:load( params )
        if not kUserLogin then return self:onLoadingError(ZooErrorCode.kNotLoginError) end
        
        local context = self
        local loadCallback = function(endpoint, data, err)
            if err then
                he_log_info(name .. " error: " .. err)
                context:onLoadingError(err)
            else
                he_log_info(name .. " success !")
                
                context:onLoadingComplete(data)
            end
        end

        self.transponder:call(name, params or {}, loadCallback, rpc.SendingPriority.kHigh, false)
    end
    return http
end

function FriendInfoUtil:req_friendData( uid,onSuccessCB,onFailCB,onCancelCB )
    print("FriendInfoUtil:req_friendData",uid)
    local function onSuccess(evt)
        if not evt or not evt.data then
            return
        end
        local _ = onSuccessCB and onSuccessCB(evt.data)
    end

    local function onFail()
        local _ = onFailCB and onFailCB()
    end

    local function onCancel()
        local _ = onCancelCB and onCancelCB()
    end

    local http = defineHttp("getNamecard").new()
    http:ad(Events.kComplete, onSuccess)
    http:ad(Events.kError, onFail)
    http:ad(Events.kCancel, onCancel)

    http:syncLoad({uid = uid})
end

function FriendInfoUtil:sendFreeGift( uid,onSuccessCB,onFailCB,onCancelCB )
    local function onSuccess(evt)
        DataTracking:sendEnergy(true)
        local _ = onSuccessCB and onSuccessCB(evt.data)

        GlobalEventDispatcher:getInstance():dispatchEvent(Event.new("sendEnergySuccess"))
    end

    local function onFail(err)
        DataTracking:sendEnergy(false)
        local _ = onFailCB and onFailCB(err)
    end

    FreegiftManager:sharedInstance():sendGiftTo(uid, onSuccess, onFail, true)
end

function FriendInfoUtil:req_like( uid,onSuccessCB,onFailCB,onCancelCB )
    local function onSuccess(evt)
        if not evt or not evt.data then
            return
        end
        local _ = onSuccessCB and onSuccessCB(evt.data)
    end

    local function onFail()
        local _ = onFailCB and onFailCB()
    end

    local function onCancel()
        local _ = onCancelCB and onCancelCB()
    end

    local http = defineHttp("thumbsUpUser").new()
    http:ad(Events.kComplete, onSuccess)
    http:ad(Events.kError, onFail)
    http:ad(Events.kCancel, onCancel)

    http:syncLoad({uid = uid})
end

function FriendInfoUtil:req_delete( selectedIds,onSuccessCB,onFailCB,onCancelCB )
    local function onSuccess(evt)
        DataTracking:delFriend(true)

        for k, uid in pairs(selectedIds) do
            DcUtil:delete(uid)
            FriendManager:getInstance():removeFriend(uid)
        end

        local _ = onSuccessCB and onSuccessCB(evt.data)
    end

    local function onFail(evt)
        local err_code = tonumber(evt.data)
        if err_code then
            local msg = Localization:getInstance():getText('error.tip.'..err_code)
            CommonTip:showTip(msg, 'negative', nil)
        end
        local _ = onFailCB and onFailCB()
    end

    local http = DeleteFriendHttp.new()
    http:ad(Events.kComplete, onSuccess)
    http:ad(Events.kError, onFail)
    http:load(selectedIds)
end

function FriendInfoUtil:req_weekRaceHistory( uid,onSuccessCB,onFailCB,onCancelCB )
    local function onSuccess(evt)
        if not evt or not evt.data then
            return
        end
        local _ = onSuccessCB and onSuccessCB(evt.data)
    end

    local function onFail()
        local _ = onFailCB and onFailCB()
    end

    local function onCancel()
        local _ = onCancelCB and onCancelCB()
    end

    local http = defineHttp("getWeekMatchSeasonHistories").new()
    http:ad(Events.kComplete, onSuccess)
    http:ad(Events.kError, onFail)
    http:ad(Events.kCancel, onCancel)

    http:syncLoad({uid = uid})
end

function FriendInfoUtil:onEdit(owner, onRemove )
    local function finishCallback()
        local isClick = true
        local panel = require('zoo.PersonalCenter.EditInfoPanel'):create( isClick )
        panel:ad(PopoutEvents.kRemoveOnce, function ( ... )
            local _ = onRemove and onRemove()
        end)
        panel.onProfileUpdated = function ( ... )
            PersonalCenterManager:uploadUserProfile(true)
        end
        panel.parentPanel = owner
        panel:popout()
    end
    PrivateStrategy:sharedInstance():Alert_Location( finishCallback )
    -- DcUtil:UserTrack({category='my_card', sub_category="my_card_click_edit_profile"}, true)
end


local icon_achievement_ids = {}
local show_level_achievements = {}
local tipCreator = nil
local panelConfigFile = PanelConfigFiles.friends_panel

function FriendInfoUtil:_initAchiConfig()
    if tipCreator ~= nil then return end

    local achis = Achievement:getAchis()
    for id,achi in pairs(achis) do
        if achi.type ~= AchiType.SHARE then
            table.insert(icon_achievement_ids, id)
        end
        if achi.type == AchiType.PROGRESS then
            table.insert(show_level_achievements, id)
        end
    end

    table.insert(icon_achievement_ids, "q")

    tipCreator = {
        [AchiId.kNStarReward] = function(data)
                    local achi = Achievement:getAchi(AchiId.kNStarReward)
                    return localize("show_off_desc_"..data.id, {num = achi:getCurTarCount(data.level)})
                end,
        [AchiId.kFiveTimesFourStar] = function(data)
                    local starNum = data.level * 5
                    return localize("show_off_desc_70_1", {num = starNum})
                end,
        [AchiId.kUnlockNewObstacle] = function ( data )
                    local achi = Achievement:getAchi(AchiId.kUnlockNewObstacle)
                    return localize("show_off_desc_50_1", {num = achi:getCurTarCount(data.level)})
               end,
        [AchiId.kScorePassThousand] = function(data)
                    return localize("show_off_desc_10_1")
                end,
        [AchiId.kTotalGetLikeCount] = function ( data )
                -- local num = data.level * 100
                local achi = Achievement:getAchi(AchiId.kTotalGetLikeCount)
                return localize("show_off_desc_200",{num = achi:getCurTarCount(data.level)})
            end,
        [AchiId.kAreaFullStar] = function ( data )
                return localize("achievement_desc_220_2")
            end,
        [AchiId.kTotalUseCoinCount] = function ( data, item )
                local achi = Achievement:getAchi(AchiId.kTotalUseCoinCount)
                local num = achi:getCurTarCount(data.level) / 10000
                if num > 9999 then
                    num = tostring(num).."亿"
                else
                    num = tostring(num).."万"
                end
                return localize("show_off_desc_430",{num = num})
            end,
        [AchiId.kTotalGetFruitCount] = function ( data, item )
                local achi = Achievement:getAchi(AchiId.kTotalGetFruitCount)
                return localize("show_off_desc_240",{num = achi:getCurTarCount(data.level)})
            end,
        [AchiId.kTotalEntryWeeklyCount] = function ( data, item )
                local achi = Achievement:getAchi(AchiId.kTotalEntryWeeklyCount)
                return localize("show_off_desc_460",{n = achi:getCurTarDate(data.level),num = achi:getCurTarCount(data.level)})
            end,
    }
end

function FriendInfoUtil:createAchievementItems(achievementData)
    FriendInfoUtil:_initAchiConfig()

    local builder = InterfaceBuilder:createWithContentsOfFile(panelConfigFile)

    local filterd = achievementData or {}
    local achievements = {}
    local achiCategoryMap = {}

    for id,achi in pairs(filterd) do
        local node = Achievement:getAchi(achi.id)
        if node == nil then
            node = Achievement:getAchi(tonumber(achi.id))
        end
        if node and achi.level > 0 then
            -- table.insert(achievements, achi)
            if not achiCategoryMap[node.category] then
                achiCategoryMap[node.category] = {}
            end
            achi.priority = node.priority
            table.insert(achiCategoryMap[node.category], achi) 
        end
    end

    local function sort(a, b)
        if not a.priority or not b.priority then
            local achiA = Achievement:getAchi(a.id)
            a.priority = achiA.priority
            local achiB = Achievement:getAchi(b.id)
            b.priority = achiB.priority
        end
        if a.priority and b.priority and a.priority ~= b.priority then
            return a.priority < b.priority
        else
            return a.id < b.id
        end
    end

    for i,v in pairs(achiCategoryMap) do
        table.sort(v, sort)
        for ii,vv in ipairs(v) do
            if vv.level>0 then
                table.insert(achievements,vv)
            end
        end
    end

    -- print("FriendInfoUtil:createAchievementItems",table.tostring(achievements))

    -- if _G.isLocalDevelopMode then printx(0, table.tostring(achievements)) end
    local items = {}
    for i,v in ipairs(achievements) do
        local node = LayerColor:create()
        -- node:setColor(ccc3(0, 00, 0))
        node:setOpacity(0)
        node:setContentSize(CCSizeMake(140, 140))

        items[i] = node

        node:ad(DisplayEvents.kTouchTap, function() 
                -- if _G.isLocalDevelopMode then printx(0, "onItem touched!!!!!!!!!!!!!!, "..i) end
                local achi = Achievement:getAchi(tonumber(v.id))
                local config = achi:getShareConfig()
                local builder = InterfaceBuilder:create(PanelConfigFiles.bag_panel_ui)
                local content = builder:buildGroup('bagItemTipContent')
                local desc = content:getChildByName('desc')
                local title = content:getChildByName('title')
                local sellBtn = content:getChildByName('sellButton')
                local useBtn = content:getChildByName('useButton')

                sellBtn:removeFromParentAndCleanup(true)
                sellBtn:dispose()
                useBtn:removeFromParentAndCleanup(true)
                useBtn:dispose()
                title:setString(localize(config.keyName))

                local createFunc = tipCreator[achievements[i].id]
                if createFunc then
                    -- desc:setString(createFunc(achievements[i], self))
                    desc:setString(createFunc(achievements[i]))
                else
                    desc:setString(localize(config.shareTitle, {num = achi:getCurTarCount(achievements[i].level)}))
                end
                local tip = BubbleTip:create(content, 105)
                tip:show(node:getGroupBounds())
            end)
        

        for _,achiId in ipairs(icon_achievement_ids) do
            local tarId = achievements[i].id
            -- node:getChildByName("q"):setVisible(tarId == "q")
            if achiId == tarId then
                local level = achievements[i].level
                local icon_id = tarId
                
                local achi_icon = SpriteColorAdjust:createWithSpriteFrameName('achievement/icon/icon_'..icon_id..'0000')
                achi_icon:setPosition(ccp(62, -60))
                node:addChild(achi_icon)

                local achi = Achievement:getAchi(tarId)
                level = achi:checkLevel(level)

                if achi.type == AchiType.PROGRES then
                    local numText = BitmapText:create(level..'级', "fnt/register2.fnt")
                    numText:setScale(0.65)
                    numText:setPosition(ccp(70, 30))
                    achi_icon:addChild(numText)
                end

                if tarId == AchiId.kUnlockNewObstacle then
                    local count = achi:getCurTarCount(level)
                    local obstacleConfig = require "zoo.PersonalCenter.ObstacleIconConfig"
                    local name = "area_icon_"..obstacleConfig[count].."0000"
                    if CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(name) == nil then
                        FrameLoader:loadImageWithPlist("flash/quick_select_level.plist")
                    end
                    if CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(name) ~= nil then
                        local obstacle = Sprite:createWithSpriteFrameName(name)
                        achi_icon:addChild(obstacle)
                        obstacle:setScale(0.51)
                        local size = achi_icon:getContentSize()
                        obstacle:setAnchorPoint(ccp(0.5, 0.5))
                        obstacle:setPositionXY(72, 82)
                    end
                end
            end
        end
    end

    return items
end

function FriendInfoUtil:getAchiState(achievementData)
    local AchiLevelRights = (require "zoo.PersonalCenter.achi.AchiLevelRights")

    if not achievementData then
        return Achievement:getState()
    end

    local state = {
        level = 0,
        score = 0,
        nextLevelScore = 0,
        maxScore = AchiLevelRights.maxScore,
        maxLevel = AchiLevelRights.maxScore
    }

    FriendInfoUtil:_initAchiConfig()

    local filterd = achievementData
    local achievements = {}

    for id,achi in pairs(filterd) do
        local node = Achievement:getAchi(achi.id)
        if node == nil then
            node = Achievement:getAchi(tonumber(achi.id))
        end
        if node and achi.level > 0 then
            table.insert(achievements, achi)

            if achi.type ~= AchiType.SHARE then
                state.score = state.score + node:getScore(achi.level)
            end
        end
    end

    state.level = AchiLevelRights:getLevel(state.score)
    state.nextLevelScore = AchiLevelRights:getLevelScore(state.level+1)
    return state
end

function FriendInfoUtil:onPanelDispose()
    print("FriendInfoUtil:onPanelDispose()")
    InterfaceBuilder:unloadAsset(panelConfigFile)
end

return FriendInfoUtil