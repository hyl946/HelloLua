require "zoo.localActivity.PigYear.PigYearRankList"

PigYearStartGame = {}

PigYearStartGame.ACT_LEVEL_START = 330100

local RES_skeletonName = "pig_year_start_top" 
local RES_skeletonURI = "skeleton/" .. RES_skeletonName
local RES_TIP_UI = 'ui/pig_year_start_tip.json'


function PigYearStartGame:start(levelId,isActLevel)
    print("PigYearStartGame:start()",levelId,isActLevel)
    SpringFestival2019Manager:getInstance().lastLevelStar = nil
    local startGamePanel = nil

    local function afterCreate()
        -- 创建顶部 tip
        -- PigYearStartGame:decorateStart(startGamePanel,levelId)

        -- 弹出
        startGamePanel:popout(false)

        local function onClose()
            FrameLoader:unloadArmature(RES_skeletonURI, true)
        end

        startGamePanel:setOnClosePanelCallback(onClose)
    end
    
    local function showActStartGame()
        startGamePanel = StartGamePanel:create(levelId, GameLevelType.kSpring2019)

        self:initRankData(startGamePanel,levelId)

        afterCreate()
    end

    if isActLevel then
        levelId = levelId + PigYearStartGame.ACT_LEVEL_START
        PigYearStartGame:_requestPreStartLevel(levelId,showActStartGame)

    else
        startGamePanel = StartGamePanel:create(levelId, GameLevelType.kMainLevel)

        afterCreate()
    end
end

function PigYearStartGame:_requestPreStartLevel(levelId,callback)
    local function onFail(evt)
        local errcode = evt and evt.data or nil
        if errcode then
            CommonTip:showTip(Localization:getInstance():getText("error.tip."..tostring(errcode)), "negative")
        end
    end

    local function onSuccess(evt)
        if evt and evt.data and evt.data.result then
            SpringFestival2019Manager:getInstance().lastLevelStar = tonumber(evt.data.result)
            local _ = callback and callback()
        else
            onFail({data = -1})
        end
    end

    local function onCancel()
        onSuccess()
    end

    HttpBase:syncPost('preStartLevel', {
            actId = PigYearLogic:getActId(),
            extra = ""..levelId,
        }, onSuccess, onFail, onCancel)
end

function PigYearStartGame:_requestLevelRank(levelId,onSuccessCallback,panel)
    if NetworkUtil:getNetworkStatus() == NetworkUtil.NetworkStatus.kNoNetwork then 
        local msg = "请联网查看排行榜"
        CommonTip:showTip(msg,"negative")

        if panel and not panel.isDisposed then
            panel:getRankList():ShowNoNetWorkLabel()
        end

        return
    end
    -- 排行榜
    local function limit_rank( subType, rank )
        if rank > 1000 then
            return 0
        end
        return rank
    end

    local function onSuccess(evt)
        local data = evt and evt.data or {}

        local ret = {}
        local maxId = 0
        local hadMe = false

        local myData = nil

        for i, v in ipairs(data.rankList or {}) do
            local thisData = {
                id = i - 1,
                uid = v.uid,
                rank = v.rank,
                score = v.score,
                profile = table.find(data.profiles or {}, function ( vvv )
                    return tostring(vvv.uid) == tostring(v.uid)
                end) or FriendManager:getInstance():getFriendInfo(v.uid),
            }

            local name = '消消乐玩家'
            if thisData.profile then
                name = thisData.profile.name or name
            end
            thisData.name = name
            local headUrl = '消消乐玩家'
            if thisData.profile then
                headUrl = thisData.profile.headUrl or headUrl
            end
            thisData.headUrl = headUrl

            if not thisData.profile then
                thisData.profile = {
                    uid = v.uid,
                    headUrl = thisData.headUrl,
                }
            end
            
            thisData.isMe = thisData.profile.uid == UserManager:getInstance().user.uid

            if thisData.isMe then
                thisData.meRank = limit_rank(subType, thisData.rank or 0)
                thisData.score = data.value or thisData.score
                myData = thisData
            end

            maxId = math.max(maxId, tonumber(thisData.id))

            table.insert(ret,thisData)
            -- ret[thisData.id] = thisData
        end

        if not myData then
            local profile = ProfileRef.new()
            profile:fromLua(UserManager:getInstance().profile:encode())
            profile.uid = UserManager:getInstance().user.uid
            myData = {
                id = maxId + 1,
                isMe = true,
                profile = profile,
                uid = UserManager:getInstance().user.uid,
                rank = data.rank,
                score =  data.value,
                name = profile.name,
                headUrl = profile.headUrl,
            }
            -- ret[maxId + 1] = myData
            table.insert(ret,myData)
            maxId = maxId + 1
        end
        
        table.sort(ret,function ( a, b )
            return a.score > b.score
          end)

        local selfRank = data.value>=0 and table.indexOf(ret,myData) or nil
        UserManager:getInstance().selfOldNumberInFriendRank[levelId]    = selfRank
        UserManager:getInstance().selfNumberInFriendRank[levelId]    = selfRank

        onSuccessCallback(ret)
    end

    local function onFail(evt)
        -- onSuccess{data = {rankList = {}}}
        local errcode = evt and evt.data or 0

        if errcode == 730581 then
            if panel and not panel.isDisposed then
                panel:getRankList():ShowActIsOverLabel()
            end
        else
            if panel and not panel.isDisposed then
                panel:getRankList():ShowNoNetWorkLabel()
            end
        end
    end

    local function onCancel(evt)
        -- onSuccess{data = {rankList = {}}}
        if panel and not panel.isDisposed then
            panel:getRankList():ShowNoNetWorkLabel()
        end
    end

    local http = GetCommonRankListHttp.new(true)
    http:ad(Events.kComplete, onSuccess)
    http:ad(Events.kCancel, onCancel)
    http:ad(Events.kError, onFail)
    http:syncLoad(41, 5, levelId, 0, 100)
    -- http:syncLoad(40, 3, levelId, 0, 100)
end

function PigYearStartGame:initRankData(panel,levelId)
    print("PigYearStartGame:initRankData()",panel,levelId)
    if not LevelType:isSpringFestival2019Level(levelId) or panel.isInitedRankData then
        return
    end

    panel.isInitedRankData = true

    local function refreshLevelRank(data)
        if not panel or panel.isDisposed then return end
        
        local dataCache = panel:getRankList().rankListCache
        dataCache.friendRankList = data
        dataCache.onCachedDataChange(RankListCacheRankType.FRIEND)
    end

    PigYearStartGame:_requestLevelRank(levelId,refreshLevelRank,panel)
end

function PigYearStartGame:decorateStart(startGamePanel,levelId)
    print("PigYearStartGame:decorateStart()",startGamePanel,levelId)
    if LevelType:isSpringFestival2019Level( levelId ) then
        -- 移除代打和跳关区域
        startGamePanel:getTopPanel().initJumpLevelArea = function () end

        self:initRankData(startGamePanel,levelId)
    end

    -- 创建顶部 tip
    local node = CocosObject:create()
    node:setPositionY(-300)
    local order = startGamePanel:getTopPanel().ui:getChildByName('bg'):getZOrder()
    startGamePanel:getTopPanel().ui:addChildAt(node,order)

    local nodeBubble = CocosObject:create()
    nodeBubble:setPositionY(-300)
    startGamePanel:getTopPanel().tipNode:addChild(nodeBubble)

---- 超难关礼盒隐藏
--  if startGamePanel:getTopPanel().title_pur_gift then
--		startGamePanel:getTopPanel().title_pur_gift:setVisible( false )
--	end

    -- local data = PigYearLogic.datas.levelPlayedCount
    -- local isFirst = not data[levelId] or data[levelId]==0

    local levelPlayType = SpringFestival2019Manager:getInstance():getLevelPlayType( levelId )
    local isFirst = levelPlayType ~= 2

    local curLevelCanGet = SpringFestival2019Manager:getInstance():curLevelCanGet( levelId )
    local ticketLevel = curLevelCanGet.TicketType
    local ticketCount = curLevelCanGet.ticketNum
    local bagLevel = curLevelCanGet.luckyBagLevel
    local bagRate = curLevelCanGet.luckyBagDoubleNum

    local function callback()
        -- local anim = gAnimatedObject:createWithFilename('gaf/pig_year/pig_year_start_top.gaf')
        -- anim:setPosition(ccp(0, -80))
        -- anim:setLooped(false)
        -- anim:start()
        -- node:addChild(anim)

        FrameLoader:loadArmature(RES_skeletonURI, RES_skeletonName, RES_skeletonName)
        local ani = ArmatureNode:create('pigYearStartTop/main')
        ani:setPosition(ccp(250+45/0.7, -50-16/0.7))
        ani:update(0.001)
        ani:playByIndex(0, 1)
        node:addChild(ani)

        local ani = ArmatureNode:create('pigYearStartTop/bubble')
        ani:setPosition(ccp(250+45/0.7, -50-16/0.7))
        ani:update(0.001)
        ani:playByIndex(0, 1)
        nodeBubble:addChild(ani)
        
        -- local builder = InterfaceBuilder:createWithContentsOfFile(RES_TIP_UI)
        -- local ui = builder:buildGroup('PigYearItems/tip')
        local UIHelper = require "zoo.panel.UIHelper"

        local UIPath = ""
        local uiPos = ccp(0,0)
        local uiNodeOffset = ccp(0,0)
        if isFirst then
            if ticketLevel ~= 0 then 
                UIPath = 'PigYearItems/tip'
                uiPos = ccp(-304.3/2,76/2)
            else
                UIPath = 'PigYearItems/tip2'
                uiPos = ccp(-285/2,78/2)
                uiNodeOffset = ccp(-10/0.7,0)
            end
        else
            UIPath = 'PigYearItems/tipStar'
            uiPos = ccp(-349.55/2,103.1/2)
            uiNodeOffset = ccp(5/0.7,-5/0.7)
        end
        local ui = UIHelper:createUI(RES_TIP_UI, UIPath)

        UIHelper:setCenterText(ui:getChildByPath('txtBags'), bagRate.."倍", 'fnt/peg_year_chunjiejineng.fnt')
        if isFirst and ticketLevel ~= 0 then 
            UIHelper:setLeftText(ui:getChildByPath('txtTickets'), "x" .. ticketCount, 'fnt/peg_year_chunjiejineng.fnt')
        end

        if not isFirst then
            UIHelper:setCenterText(ui:getChildByPath('txtBags2'), bagRate.."倍", 'fnt/peg_year_chunjiejineng.fnt')
            UIHelper:setLeftText(ui:getChildByPath('txtTickets2'), "x" .. ticketCount, 'fnt/peg_year_chunjiejineng.fnt')
        end

        local uiNode = CocosObject:create()
        nodeBubble:addChild(uiNode)

        ui:setPosition(uiPos)
        uiNode:addChild(ui)

        uiNode:setPosition(ccp(220/0.7+uiNodeOffset.x, 20/0.7+uiNodeOffset.y))
        uiNode:setScale(0.01)
        uiNode:runAction(
            CCSequence:createWithTwoActions(
                CCDelayTime:create(0.4),
                CCScaleTo:create(0.3,1,1)
                )
        )
    end
    Notify:dispatch('PigYearStartGameCreate')
    node:runAction(
        CCSequence:createWithTwoActions(
            CCDelayTime:create(0.8),
            CCCallFunc:create(callback) 
            )
        )
end


function PigYearStartGame:decorateLevelEnd(panel,isPassLevel)
    local bEnabled = PigYearLogic:isActEnabled()
    if not bEnabled then return end

    if LevelType:isSpringFestival2019Level(panel.levelId) then
        PigYearStartGame:initRankData(panel,panel.levelId)

        -- 移除代打和跳关区域
        panel:getTopPanel().initJumpLevelArea = function () end
    end
    
    local canGetReward = SpringFestival2019Manager and SpringFestival2019Manager:getInstance():getCurIsAct()
    if canGetReward then
        local rewards = SpringFestival2019Manager:getInstance():getCurLevelPassCanGetInfo()
        print("PigYearStartGame:decorateLevelEnd",isPassLevel,table.tostring(rewards))

        local bDoubleBag = false
        local PicYearMeta = require 'zoo.localActivity.PigYear.PicYearMeta'
        for i,v in ipairs(rewards) do
            if v.itemId > PicYearMeta.ItemIDs.LUCKY_BAG_M_1 and v.itemId <= PicYearMeta.ItemIDs.LUCKY_BAG_M_4 then
                bDoubleBag = true
                break
            end
        end

        if isPassLevel and bDoubleBag then
            panel:getTopPanel().showPigYearEndPanel = function (doneCallback)
                local PigYearBuyBagPanel = require 'zoo.localActivity.PigYear.PigYearBuyBagPanel'
                local p = PigYearBuyBagPanel:create(1,rewards,panel)
                p:popout()

                p.closeCallback = doneCallback
            end
        else
            setTimeOut(function()
                local LuckyBagPanel = require 'zoo.localActivity.PigYear.PigYearView'
                local p = LuckyBagPanel:create(1)
                p:setNewRewards(rewards )
                p:popout()
            end,1)

        end
    end


    -- panel.onCloseBtnTapped = function()
    --     LevelSuccessPanel.onCloseBtnTapped(panle)
    -- end
end

function PigYearStartGame:onNextLevelBtnTapped(levelId)
    if LevelType:isSpringFestival2019Level(levelId) then
        PigYearLogic:setNeedShowNextLevel(true)
    end
end
