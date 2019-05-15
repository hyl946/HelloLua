local RankBar = require "zoo.quarterlyRankRace.component.RankBar"
local RankBoard = require "zoo.quarterlyRankRace.component.RankBoard"
local RankBoardTabBtnGroup = require "zoo.quarterlyRankRace.component.RankBoardTabBtnGroup"
local RankBoardTabBtnFriend = require "zoo.quarterlyRankRace.component.RankBoardTabBtnFriend"
local RankBoardTabShowGroup = require "zoo.quarterlyRankRace.component.RankBoardTabShowGroup"
local RankBoardTabShowFriend = require "zoo.quarterlyRankRace.component.RankBoardTabShowFriend"
local RankRaceLevelNode = require "zoo.quarterlyRankRace.component.RankRaceLevelNode"
local RankRaceTurnableButton = require "zoo.quarterlyRankRace.component.RankRaceTurnableButton"

local RankRaceMainPanel = class(BasePanel)

local winSize = Director:sharedDirector():getWinSize()
local visibleSize = CCDirector:sharedDirector():getVisibleSize()
local visibleOrigin = CCDirector:sharedDirector():getVisibleOrigin()
local zeroPosition
if winSize.height > 1280 then 
    zeroPosition = -visibleSize.height 
else
    zeroPosition = -1280
end

local UIPosState = {
    kRankBarAll = "rankbar_all",
    kBottomMaskAll = "bottom_mask_all",
    kBottomAll = "bottom_all",
    kBottomHalf = "bottom_half",
}
local UIPosConfig = {
    [UIPosState.kRankBarAll]        = {x = -160, y = zeroPosition + 94},
    [UIPosState.kBottomMaskAll]     = {x = -145, y = zeroPosition},
    [UIPosState.kBottomAll]         = {x = -120, y = zeroPosition + 749 + 75},
    [UIPosState.kBottomHalf]        = {x = -120, y = zeroPosition + 143},
}

local ScreenHeight = 1900
local FullScreenLayerSize = {
    width = 960,
    height = ScreenHeight,    
}

local FullScreenLayerPos = {
    x = -120,
    y = -ScreenHeight + 120,
}

function RankRaceMainPanel:ctor()
end

function RankRaceMainPanel:init()
	self.ui = self:buildInterfaceGroup("2018_s1_rank_race/MainPanel")
    BasePanel.init(self, self.ui)

    self.newSeasonPopOut = false
    self.newSeasonPrePopOut = false

	local scale = math.min(visibleSize.height / 1280, visibleSize.width / 720)
	local contentPosX = visibleOrigin.x + (visibleSize.width - 720 * scale) / 2
	local contentPosY = visibleOrigin.y + 1280 * scale
	self:setScale(scale)
	self:setPositionXY(contentPosX, 0)

    local bg = Sprite:create(SpriteUtil:getRealResourceName("ui/RankRace/mainPanelBg.jpg"))
    bg:setAnchorPoint(ccp(0, 1))
    bg:setPosition(ccp(-120, 120))
    self.ui:addChildAt(bg, 0)

    self:initTop()
    self:initTagPanel()
    self:initLevelNode()
    self:initBottom()
    self:initBottomMask()
    self:initSettlement()
    self:tryShowGuide()
    RankRaceMgr.getInstance():addObserver(self)
end

function RankRaceMainPanel:onStartLevelLogicSuccess()
    RankRaceMgr:getInstance():willEnterGamePlay()
    self:updateLevelNode()
end

function RankRaceMainPanel:lock()
    if self.isDisposed then return end
    if not self.blockLayer then 
        self.blockLayer = Layer:create()
        -- self.blockLayer:setColor(ccc3(255, 0, 0))
        -- self.blockLayer:setOpacity(100)
        self.blockLayer:setContentSize(CCSizeMake(FullScreenLayerSize.width, FullScreenLayerSize.height))
        self.blockLayer:setTouchEnabled(true, 0, true)
        self.blockLayer.hitTestPoint = function (_, worldPosition, useGroupTest)
            if (self.closeBtn and self.closeBtn:hitTestPoint(worldPosition, useGroupTest)) or
                (self.ruleBtn and self.ruleBtn:hitTestPoint(worldPosition, useGroupTest)) then 
                return false
            else
                return true
            end
        end
        self.ui:addChild(self.blockLayer)
        self.blockLayer:setPosition(ccp(FullScreenLayerPos.x, FullScreenLayerPos.y))
    end
    self.blockLayer:setVisible(true)
end

function RankRaceMainPanel:unlock()
    if self.isDisposed then return end
    if self.blockLayer then self.blockLayer:setVisible(false) end
end

function RankRaceMainPanel:initTop()
	self.closeBtn = self.ui:getChildByName('closeBtn')	
	self.closeBtn:setTouchEnabled(true, 0, false)
	self.closeBtn:setButtonMode(true)
	self.closeBtn:addEventListener(DisplayEvents.kTouchTap, function ()
		self:onCloseBtnTapped()
	end)

    self.topPartUI = self.ui:getChildByName("topPart")
    self.ruleBtn = self.topPartUI:getChildByName('ruleBtn')  
    self.ruleBtn:setTouchEnabled(true, 0, false)
    self.ruleBtn:setButtonMode(true)
    self.ruleBtn:addEventListener(DisplayEvents.kTouchTap, function ()
        self:onDescBtnTapped()
    end)

    self.countdownTip = BitmapText:create('', 'fnt/tutorial_white.fnt')
    self.countdownTip:setAlignment(kCCTextAlignmentCenter)
    self.countdownTip:setAnchorPoint(ccp(0.5, 0.5))
    self.countdownTip:setScale(0.7)
    self.topPartUI:addChild(self.countdownTip)
    local tSize = self.topPartUI:getChildByName("title"):getContentSize()
    local bPos = self.topPartUI:getChildByName("ruleBtn"):getPosition()
    self.countdownTip:setPosition(ccp(tSize.width/2, bPos.y + 1))
    self.SaveCountDownTipPosY = bPos.y + 1
    self.SaveCountDownTipPosX = tSize.width/2

    local SaijiIndex = RankRaceMgr.getInstance():getCurSaijiIndex()
    if SaijiIndex == 1 then
         self.ruleBtn:setPositionX( self.SaveCountDownTipPosX + 156 + 20  )
    end

    self.oneSecondTimer = OneSecondTimer:create()
    self.oneSecondTimer:setOneSecondCallback(function ()
        self:onTick()
    end)
    self:onTick()
end

function RankRaceMainPanel:onDescBtnTapped()
    local panel = require('zoo.quarterlyRankRace.view.RankRaceDescPanel'):create()
    panel:popout()
    panel:turnTo(1)
end

function RankRaceMainPanel:onTick()
    if self.isDisposed then return end
    local time, yoffset = RankRaceMgr.getInstance():getCountDownStr()
    yoffset = yoffset or 0
    self.countdownTip:setText(time)
    self.countdownTip:setPositionY( self.SaveCountDownTipPosY + yoffset )

    local SaijiIndex = RankRaceMgr.getInstance():getCurSaijiIndex()
    if SaijiIndex == 2 then
         self.ruleBtn:setPositionX( self.SaveCountDownTipPosX + 156 + 20  )
    end
end

function RankRaceMainPanel:initTagPanel()
    self.tagPanelUI = self.ui:getChildByName("tagPart")
    self.tagArrow = self.tagPanelUI:getChildByName("arrow")
    self.tagPanelUI:setVisible(false)

    self.tagPanelUI:setTouchEnabled(true, 0, true)
    self.tagPanelUI:addEventListener(DisplayEvents.kTouchTap, function ()
        local dan = RankRaceMgr.getInstance():getData():getSafeDan()
        local danName = localize('rank.race.dan.panel.title.' .. dan)
        CommonTip:showTip(localize("rank.race.main.17", {n = danName}), "positive", nil, 3)
    end)
end

function RankRaceMainPanel:updateTagPanel(forceHide)
    local rankIndexGroup = RankRaceMgr.getInstance().rankIndexGroup
    if not forceHide and rankIndexGroup and rankIndexGroup > 0 then 
        local dan = RankRaceMgr.getInstance():getData():getSafeDan()
        local sizeUI = self.tagPanelUI:getChildByName("bg"):getContentSize()
        local xDelta = -2
        if not self.tagTitle then 
            self.tagTitle = BitmapText:create('', 'fnt/newzhousai_rank1.fnt')
            self.tagTitle:setAnchorPoint(ccp(0.5, 0.5))
            self.tagPanelUI:addChild(self.tagTitle)
            self.tagTitle:setPosition(ccp(sizeUI.width/2 + xDelta, -43))
        end
        self.tagTitle:setText(localize('rank.race.dan.panel.title.' .. dan))
        if not self.tagLabelTip then 
            self.tagLabelTip = BitmapText:create('本周排行', 'fnt/register2.fnt')
            self.tagLabelTip:setColor((ccc3(0x72,0x41,0x21)))
            self.tagLabelTip:setAnchorPoint(ccp(0.5, 0.5))
            self.tagLabelTip:setScale(0.6)
            self.tagPanelUI:addChild(self.tagLabelTip)
            self.tagLabelTip:setPosition(ccp(sizeUI.width/2, -76))
        end
        if not self.tagLabelPrefix then 
            self.tagLabelPrefix = BitmapText:create('第', 'fnt/register2.fnt')
            self.tagLabelPrefix:setColor((ccc3(0x72,0x41,0x21)))
            self.tagLabelPrefix:setAnchorPoint(ccp(1, 0))
            self.tagLabelPrefix:setScale(0.6)
            self.tagPanelUI:addChild(self.tagLabelPrefix)
        end
        if not self.tagLabelPostfix then 
            self.tagLabelPostfix = BitmapText:create('名', 'fnt/register2.fnt')
            self.tagLabelPostfix:setColor((ccc3(0x72,0x41,0x21)))
            self.tagLabelPostfix:setAnchorPoint(ccp(0, 0))
            self.tagLabelPostfix:setScale(0.6)
            self.tagPanelUI:addChild(self.tagLabelPostfix)
        end
        if not self.tagLabelMid then 
            self.tagLabelMid = BitmapText:create('', 'fnt/register2.fnt')
            self.tagLabelMid:setColor((ccc3(0x72,0x41,0x21)))
            self.tagLabelMid:setAnchorPoint(ccp(0.5, 0))
            self.tagPanelUI:addChild(self.tagLabelMid)
            self.tagLabelMid:setScale(0.7)
            self.tagLabelMid:setPosition(ccp(sizeUI.width/2, -118))
        end
        local _, pro1Num = RankRaceMgr.getInstance():getProNum()
        if pro1Num and pro1Num > 0 and rankIndexGroup <= pro1Num then 
            self.tagArrow:setVisible(true)
        else
            self.tagArrow:setVisible(false)
        end

        self.tagLabelMid:setText(rankIndexGroup)
        local sizeMid = self.tagLabelMid:getContentSize()
        self.tagLabelPrefix:setPosition(ccp(sizeUI.width/2 - sizeMid.width/2 * 0.7, -115))
        self.tagLabelPostfix:setPosition(ccp(sizeUI.width/2 + sizeMid.width/2 * 0.7, -115))
        self.tagPanelUI:setVisible(true)
    else
        self.tagPanelUI:removeAllEventListeners()
        self.tagPanelUI:setVisible(false)
    end
end

function RankRaceMainPanel:initSettlement()
    self.settlementPanel = self.ui:getChildByName("settlementPanel")
    self.settlementPanel:setVisible(false)

    self:updateSettlement()
end

local function parseTime( str,default )
    local pattern = "(%d+)-(%d+)-(%d+) (%d+):(%d+):(%d+)"
    local year, month, day, hour, min, sec = string.match(str,pattern)
    if year and month and day and hour and min and sec then
        return {
            year=tonumber(year),
            month=tonumber(month),
            day=tonumber(day),
            hour=tonumber(hour),
            min=tonumber(min),
            sec=tonumber(sec),
        }
    else
        return default
    end
end

function RankRaceMainPanel:ShowJieSuanPanel()
    local calStatus = tonumber(RankRaceMgr.getInstance():getData():getStatus())
    if calStatus and (calStatus == 2 or calStatus == 3) then  
        local lastSettlementTip = BitmapText:create('', 'fnt/tutorial_white.fnt')
        lastSettlementTip:setAnchorPoint(ccp(0.5, 0.5))
        lastSettlementTip:setScale(0.8)
        lastSettlementTip:setRichTextWithWidth(localize('rank.race.main.16'), 18, '663300')
        self.settlementPanel:addChild(lastSettlementTip)
        local sizeTip = lastSettlementTip:getContentSize()
        local sizeUI = self.settlementPanel:getChildByName("bg"):getContentSize()
        lastSettlementTip:setPosition(ccp(sizeUI.width/2, -sizeUI.height + sizeTip.height))
        
        self.settlementPanel:setVisible(true)
        self:lock(true)

        local layer = LayerColor:create()
        layer:setOpacity(150)
        layer:setColor((ccc3(0,0,0)))
        layer:setContentSize(CCSizeMake(FullScreenLayerSize.width, FullScreenLayerSize.height))
        layer:setPosition(ccp(FullScreenLayerPos.x, FullScreenLayerPos.y))
        self.ui:addChildAt(layer, self.ui:getChildIndex(self.settlementPanel))

        self.countdownTip:setText(localize("rank.race.main.12"))
        if self.oneSecondTimer then 
            self.oneSecondTimer:stop()
            self.oneSecondTimer = nil
        end

        return true
    end

    return false
end

function RankRaceMainPanel:updateSettlement( bPassDay )
    if RankRaceMgr.getInstance():isNewestSeaonWeekIndex() then
        --说明是第二周第一周 10点前弹变更
        local now = Localhost:timeInSec()
        local startTime = RankRaceMgr.getInstance().newestSaijiStartTime

        if now < startTime then
            if bPassDay then
                self:onCloseBtnTapped()
            else
                self.newSeasonPopOut = true
                self:lock(true)
            end
        else
            self:ShowJieSuanPanel()
        end
    elseif RankRaceMgr.getInstance():isNewestSeasonComming() then
        if not self:ShowJieSuanPanel() and not RankRaceMgr.getInstance():getNewestPreShow() then
            self.newSeasonPrePopOut = true
        end
    else
        self:ShowJieSuanPanel()
    end
end

function RankRaceMainPanel:initLevelNode()
    self.levelNodePartUI = self.ui:getChildByName("levelNodePart")

    self.levelNodes = {}
    for i=1,6 do
        local nodeUI = self.levelNodePartUI:getChildByName("node"..i)
        local levelNode = RankRaceLevelNode:create(nodeUI, i)
        table.insert(self.levelNodes, levelNode)

        

        local index = i

        local function onConfirmPlay()
            require "zoo.quarterlyRankRace.view.RankRaceStartPanel"
            RankRaceStartPanel:create(index, nil, self):popout()
        end
        local function onCancelPlay()
        end
        levelNode:setNodeTapCallback(function ()
            -- DcUtil:UserTrack({category='weeklyrace2018', sub_category='weeklyrace2018_click_stage', t1 = index})
            onConfirmPlay()
        end)
    end
end

function RankRaceMainPanel:showLoading()
    if not self.animation then
        local scene = Director:sharedDirector():getRunningScene()
        self.animation = CountDownAnimation:createNetworkAnimationInHttp(scene)
        self.animation.onKeyBackClicked = function(self) end
    end
end

function RankRaceMainPanel:removeLoading()
    if self.animation then
        PopoutManager:sharedInstance():remove(self.animation)
    end
    self.animation = nil
end

function RankRaceMainPanel:onDidEnterPlayScene(gamePlayScene)
    if not self.isDisposed then 
        self:removeLoading()
    end
end

function RankRaceMainPanel:onStartLevelLogicFailed(err)
    if not self.isDisposed then 
        self:removeLoading()
        CommonTip:showTip(localize("error.tip."..err), "negative")
    end
end

function RankRaceMainPanel:showTimeNotEnoughWarningPanel(onConfirm, onCancel)
    CommonTipWithBtn:showTip({tip = localize("rank.race.main.13"), yes = "知道了"}, "negative", onConfirm, onConfirm, nil, true)
end

function RankRaceMainPanel:updateLevelNode()
    if self.levelNodes then 
        for i,v in ipairs(self.levelNodes) do
            v:update()
        end
    end
end

function RankRaceMainPanel:initBottom()
    self.rankBarUI = self.ui:getChildByName("rankBar")
    self.bottomPartUI = self.ui:getChildByName("bottomPart")
    --排行榜显示隐藏的touch层
    local touchIsolateLayer1 = Layer:create()
    -- touchIsolateLayer1:setOpacity(100)
    -- touchIsolateLayer1:setColor((ccc3(0,255,0)))
    touchIsolateLayer1:setPosition(ccp(135, -50))
    touchIsolateLayer1:setContentSize(CCSizeMake(420, 50))
    touchIsolateLayer1:setTouchEnabled(true, 0, true)
    touchIsolateLayer1:addEventListener(DisplayEvents.kTouchTap, function ()
        self:updateBottomPos(UIPosState.kBottomAll, true)
    end)
    self.bottomPartUI:addChildAt(touchIsolateLayer1, 0)

    local touchIsolateLayer2 = Layer:create()
    -- touchIsolateLayer2:setOpacity(100)
    -- touchIsolateLayer2:setColor((ccc3(255,0,0)))
    touchIsolateLayer2:setPosition(ccp(0, -650))
    touchIsolateLayer2:setContentSize(CCSizeMake(1060, 600))
    touchIsolateLayer2:setTouchEnabled(true, 0, true)
    self.bottomPartUI:addChildAt(touchIsolateLayer2, 0)

    --底部固定条
    self:initRankBar()
    --转盘界面按钮 段位界面按钮 分享额外获得按钮
    self:initOtherBtns()
    --排行榜
    self:initRankBoard()

    --排行榜自动缩起来
    self.ui:setTouchEnabled(true, 0, true)
    self.ui:ad(DisplayEvents.kTouchBegin, function ()
        self:updateBottomPos(UIPosState.kBottomHalf, true)
    end)
    self.ui.hitTestPoint = function ()
        return true
    end

    self:updateBottomPos(UIPosState.kBottomHalf)
end

function RankRaceMainPanel:initRankBar()
	local pos = UIPosConfig[UIPosState.kRankBarAll]
    self.rankBarUI:setPosition(ccp(pos.x, pos.y))
	self.rankBarUI:setTouchEnabled(true, 0, true)
    self.rankBarUI:addEventListener(DisplayEvents.kTouchTap, function ()
        if not self.uiStateBottom or self.uiStateBottom == UIPosState.kBottomHalf then 
            self:updateBottomPos(UIPosState.kBottomAll, true)
        else
            self:updateBottomPos(UIPosState.kBottomHalf, true)
        end
    end)

    self.rankBarLeft = RankBar:createBarA(self.rankBarUI:getChildByName("rankBar1"))
    -- self.targetFlyPos = self.rankBarLeft:getIconWorldPos()
    self.rankBarRight = RankBar:createBarB(self.rankBarUI:getChildByName("rankBar2"))
end

function RankRaceMainPanel:updateRankBar(tabIndex, spState)
	if self.isDisposed then return end
	if tabIndex == 1 then              --小组
        self.rankBarLeft:setVisible(true)
        self.rankBarRight:setVisible(false)
        self.rankBarLeft:setTargetNum(RankRaceMgr.getInstance():getData():getTC0())
        local rankIdx = RankRaceMgr.getInstance().rankIndexGroup
        local renderState = RankRaceMgr.getInstance():getRankRenderState(1, rankIdx)
        self.rankBarLeft:setBgShow(renderState)
        if rankIdx and rankIdx > 0 then 
            if spState == "rank_bar_calculate" then
                self.rankBarLeft:setLabelNormalShow(localize("rank.race.main.7"))
                self:updateTagPanel(true)
            elseif spState == "rank_bar_no_net" then 
                self.rankBarLeft:setNoNetShow()
            else
                local totalRankNum = RankRaceMgr.getInstance():getRankTatalNum(1)
                local rankStr = rankIdx.."/"..totalRankNum
                rankStr = localize("rank.race.main.8", {n = rankStr})
                local addStr = ""
                if renderState == 1 then 
                elseif renderState == 2 then 
                elseif renderState == 4 then 
                    addStr = localize("rank.race.main.10")
                else
                    local _, pro1Num = RankRaceMgr.getInstance():getProNum()
                    if pro1Num and pro1Num > 0 then 
                        addStr = localize("rank.race.main.11", {n = rankIdx - pro1Num})
                    else
                        addStr = localize("rank.race.main.15")
                    end
                end
                self.rankBarLeft:setLabelNormalShow(rankStr.."    "..addStr)
            end
        else
            if spState == "rank_bar_calculate" then
                self.rankBarLeft:setLabelNormalShow(localize("rank.race.main.7"))
                self:updateTagPanel(true)
            else
                self.rankBarLeft:setLabelNormalShow(localize("rank.race.main.8", {n = "未上榜"}))
            end
        end
	elseif tabIndex == 2 then          --好友
        self.rankBarLeft:setVisible(false)
        self.rankBarRight:setVisible(true)
        self.rankBarRight:setTargetNum(RankRaceMgr.getInstance():getData():getTC0())
        local rankIdx = RankRaceMgr.getInstance().rankIndexFriend or 0
        if rankIdx > 0 then 
            local totalRankNum = RankRaceMgr.getInstance():getRankTatalNum(2)
            local rankStr = rankIdx.."/"..totalRankNum
            self.rankBarRight:setLabelNormalShow(string.format("排行:%s", rankStr))
        else
            self.rankBarRight:setLabelNormalShow(localize("排行:未上榜"))
        end
	end
end

function RankRaceMainPanel:initOtherBtns()
    local turnableBtnUI = self.ui:getChildByName("btnTurnable")
    turnableBtnUI:setPositionY(UIPosConfig[UIPosState.kBottomHalf].y + 85)
    self.turnableBtn = RankRaceTurnableButton:create(turnableBtnUI)
    self.turnableBtn:setTouchEnabled(true, 0, true)
    self.turnableBtn:setButtonMode(true)
    self.turnableBtn:ad(DisplayEvents.kTouchTap, function ()
         self:onTurnableBtnTap()
    end)
    self:refreshRewardFlag()

    self.rankSysBtn = self.ui:getChildByName("btnRankSysm")
    self.rankSysBtn:setTouchEnabled(true, 0, true)
    self.rankSysBtn:setButtonMode(true)
    self.rankSysBtn:addEventListener(DisplayEvents.kTouchTap, function ()
         self:onSystemRankBtnTap()
    end)

    local bg = self.rankSysBtn:getChildByName('bg')
    bg:setAnchorPointCenterWhileStayOrigianlPosition()
    self.rankSysBtn:setPositionY(UIPosConfig[UIPosState.kBottomHalf].y + 95)
    
    self.recordBtn = self.ui:getChildByName("btnRecord")
    self.recordBtn:setPositionY(UIPosConfig[UIPosState.kBottomHalf].y - 18)
    self.recordRedDot = self.recordBtn:getChildByName("dot")
    self.recordBtn:setTouchEnabled(true, 0, true)
    self.recordBtn:setButtonMode(true)
    self.recordBtn:addEventListener(DisplayEvents.kTouchTap, function ()
         self:onRecordBtnTap()
    end)
    self:refreshGiftFlag()
end

function RankRaceMainPanel:refreshGiftFlag( ... )
    if self.isDisposed then return end
    self.recordRedDot:setVisible(RankRaceMgr:getInstance():hasAvailableGifts())
end

function RankRaceMainPanel:onTurnableBtnTap()
    require('zoo.quarterlyRankRace.view.RankRaceRewardPanel'):create():popout()

    local t1 = 2
    if RankRaceMgr:getInstance():hasAvailableBoxRewards() then
        t1 = 1
    end

    DcUtil:UserTrack({
        category='weeklyrace2018', 
        sub_category='weeklyrace2018_click_reward_icon',
        t1 = t1
    })
end

function RankRaceMainPanel:onSystemRankBtnTap()
    require('zoo.quarterlyRankRace.view.RankRaceDanPanel'):create():popout()
end

function RankRaceMainPanel:onRecordBtnTap()
    require('zoo.quarterlyRankRace.view.RankRaceGiftPanel'):create():popout()
end

function RankRaceMainPanel:initRankBoard()
	local rankPartUI = self.bottomPartUI:getChildByName('rankPart')
	local leftTabUI = rankPartUI:getChildByName('leftRankBtn')
	local rightTabUI = rankPartUI:getChildByName('rightRankBtn')
	local leftTabShowUI = rankPartUI:getChildByName('leftRankShow')
	local rightTabShowUI = rankPartUI:getChildByName('rightRankShow')
	local rankBoardConfig = {}
	table.insert(rankBoardConfig, {
		tabBtnUI = leftTabUI, tabBtnClass = RankBoardTabBtnGroup, 
		tabShowUI = leftTabShowUI, tabShowClass = RankBoardTabShowGroup, tabShowWidth = 720, tabShowHeight = 660,
	})
	table.insert(rankBoardConfig, {
		tabBtnUI = rightTabUI, tabBtnClass = RankBoardTabBtnFriend, 
		tabShowUI = rightTabShowUI, tabShowClass = RankBoardTabShowFriend, tabShowWidth = 720, tabShowHeight = 660,
	})

	local function onTabUpdateCallback(tabIndex, spState)
        if self.isDisposed then return end
        if tabIndex == 1 then 
            self:updateTagPanel()
        end
        if self.rankBoard then
            self.rankBoard:updateBtnFlag(tabIndex)
        end
		self:updateRankBar(tabIndex, spState)
	end
	self.rankBoard = RankBoard:create(rankBoardConfig, onTabUpdateCallback)
    local context = self
    self.rankBoard:setLockCallback(function (isLock)
        if context.isDisposed then return end
        if isLock then 
            context:lock()
        else
            context:unlock()
        end
    end)
    self.rankBoard:setUnfoldCallback(function (withAni)
        if context.isDisposed then return end
        context:updateBottomPos(UIPosState.kBottomAll, withAni) 
    end)
end

function RankRaceMainPanel:updateRankBoard(tabIndex, withSurpass)
    if self.rankBoard then 
        self.rankBoard:update(tabIndex, withSurpass) 
    end
end

function RankRaceMainPanel:updateBottomPos(stateBottom, withAni) 
    if self.uiStateBottom and self.uiStateBottom == stateBottom then 
        return 
    end 
    self.uiStateBottom = stateBottom 

    if stateBottom == UIPosState.kBottomHalf then
        if self.rankBoard and self.rankBoard.tabShows and self.rankBoard.tabShows[1] then
            self.rankBoard.tabShows[1]:hideAnyInfoPanel()
        end 
    end

    local pos = UIPosConfig[self.uiStateBottom]
    if withAni then 
        if self.bottomPartUI then 
            self.bottomPartUI:stopAllActions()
            self.bottomPartUI:runAction(CCEaseElasticOut:create(CCMoveTo:create(0.2, ccp(pos.x, pos.y)), 1))
        end
    else
        if self.bottomPartUI then self.bottomPartUI:setPosition(ccp(pos.x, pos.y)) end
    end
end

function RankRaceMainPanel:initBottomMask()
	self.bottomMaskUI = self.ui:getChildByName("bottomMask")

    if _G.__EDGE_INSETS.bottom > 0 then 
        local pos = UIPosConfig[UIPosState.kBottomMaskAll]
        self.bottomMaskUI:setPosition(ccp(pos.x, pos.y))
        self.bottomMaskUI:setVisible(true)
    else
        self.bottomMaskUI:setVisible(false)
    end
end

function RankRaceMainPanel:tryShowGuide()
    local calStatus = tonumber(RankRaceMgr.getInstance():getData():getStatus())
    if calStatus and (calStatus == 2 or calStatus == 3) then 
        --结算期无引导
        return 
    end

    if not UserManager:getInstance():hasGuideFlag(kGuideFlags.RankRace) then 
        UserLocalLogic:setGuideFlag(kGuideFlags.RankRace)

        self.guideLayer = LayerColor:create()
        self.guideLayer:setOpacity(150)
        self.guideLayer:setColor((ccc3(0,0,0)))
        self.guideLayer:setContentSize(CCSizeMake(FullScreenLayerSize.width, FullScreenLayerSize.height))
        self.guideLayer:setPosition(ccp(FullScreenLayerPos.x, FullScreenLayerPos.y))
        self.ui:addChild(self.guideLayer)

        self.guideTouchLayer = Layer:create()
        -- self.guideTouchLayer:setOpacity(100)
        -- self.guideTouchLayer:setColor((ccc3(255,0,0)))
        self.guideTouchLayer:setContentSize(CCSizeMake(FullScreenLayerSize.width, FullScreenLayerSize.height))
        self.guideLayer:addChild( self.guideTouchLayer)

        self.guideTouchLayer:setTouchEnabled(true, 0, true)

        local guideStep, revertFunc = self:showGuideStep(1)
         self.guideTouchLayer:addEventListener(DisplayEvents.kTouchTap, function ()
            if revertFunc then revertFunc() end
            guideStep, revertFunc = self:showGuideStep(guideStep)
        end)
    end
end

function RankRaceMainPanel:showGuideStep(stepIndex)
    local function changeParent(ui, newContainer, childIndex)
        local oldNodePos = ui:getPosition()
        local oldParent = ui:getParent()
        local oldIndex = oldParent:getChildIndex(ui)
        local wolrdPos = oldParent:convertToWorldSpace(oldNodePos)
        local newNodePos = newContainer:convertToNodeSpace(wolrdPos)
        ui:removeFromParentAndCleanup(false)
        if childIndex then 
            newContainer:addChildAt(ui, childIndex)
        else
            newContainer:addChild(ui)
        end
        ui:setPosition(ccp(newNodePos.x, newNodePos.y))
        return oldNodePos, oldParent, oldIndex
    end

    local function getTouchLayerIndex()
        return self.guideLayer:getChildIndex(self.guideTouchLayer)
    end

    if stepIndex == 1 then 
        local levelNode = self.levelNodes[1]
        local oldNodePos, oldParent, oldIndex = changeParent(levelNode, self.guideLayer, getTouchLayerIndex())
        local guidePanel = GameGuideUI:dialogue(nil, { panelName="guide_rank_race_main_1" }, true)
        self.guideLayer:addChild(guidePanel)
        guidePanel:setPosition(ccp(400, 500+300))
        return 2, function ()
            guidePanel:removeFromParentAndCleanup(true)
            changeParent(levelNode, oldParent, oldIndex)
        end
    elseif stepIndex == 2 then 
        local GuidePanelName = ""
        local SaijiIndex = RankRaceMgr.getInstance():getCurSaijiIndex()
        if SaijiIndex == 1 then
            GuidePanelName = "guide_rank_race_main_2"
        else
            GuidePanelName = "guide_rank_race_main_21"
        end

        local oldNodePos, oldParent, oldIndex = changeParent(self.turnableBtn, self.guideLayer, getTouchLayerIndex())
        local guidePanel = GameGuideUI:dialogue(nil, { panelName=GuidePanelName }, true)
        self.guideLayer:addChild(guidePanel)
        guidePanel:setPosition(ccp(300, ScreenHeight + zeroPosition + 120))
        return 3, function ()
            guidePanel:removeFromParentAndCleanup(true)
            changeParent(self.turnableBtn, oldParent, oldIndex)
        end
    elseif stepIndex == 3 then 
        local levelNode = self.levelNodes[6]

        local GuidePanelName = ""
        local SaijiIndex = RankRaceMgr.getInstance():getCurSaijiIndex()
        if SaijiIndex == 1 then
            GuidePanelName = "guide_rank_race_main_3"
        else
            GuidePanelName = "guide_rank_race_main_31"
        end
        local oldNodePos, oldParent, oldIndex = changeParent(levelNode, self.guideLayer, getTouchLayerIndex())
        local guidePanel = GameGuideUI:dialogue(nil, { panelName=GuidePanelName }, true)
        self.guideLayer:addChild(guidePanel)
        guidePanel:setPosition(ccp(400, 1145+300))
        return 4, function ()
            guidePanel:removeFromParentAndCleanup(true)
            changeParent(levelNode, oldParent, oldIndex)
        end
    elseif stepIndex == 4 then 
        local oldNodePos, oldParent, oldIndex = changeParent(self.bottomPartUI, self.guideLayer, getTouchLayerIndex())
        local oldNodePos1, oldParent1, oldIndex1 = changeParent(self.rankBarUI, self.guideLayer, getTouchLayerIndex())
        local oldNodePos2, oldParent2, oldIndex2 = changeParent(self.bottomMaskUI, self.guideLayer, getTouchLayerIndex())
        local guidePanel = GameGuideUI:dialogue(nil, { panelName="guide_rank_race_main_4" }, true)
        self.guideLayer:addChild(guidePanel)
        guidePanel:setPosition(ccp(300, ScreenHeight + zeroPosition + 20))
        return 5, function ()
            guidePanel:removeFromParentAndCleanup(true)
            changeParent(self.bottomPartUI, oldParent, oldIndex)
            changeParent(self.rankBarUI, oldParent1, oldIndex1+1)
            changeParent(self.bottomMaskUI, oldParent2, oldIndex2+2)
        end
    elseif stepIndex == 5 then 
        if self.guideLayer then 
            self.guideLayer:removeFromParentAndCleanup(true)
            self.guideLayer = nil
        end
    end
end

function RankRaceMainPanel:onNotify(obKey, ...)
	if obKey == RankRaceOBKey.kPassDay then 
		self:handlePassDay(...)
	elseif obKey == RankRaceOBKey.kTargetCountChange0 then 
        self:handleTargetIncrease(...)
        self:refreshRewardFlag()
    elseif obKey == RankRaceOBKey.kTargetCountChange1 then 
        self:refreshRewardFlag()
    elseif obKey == RankRaceOBKey.kRewardInfoChange then 
        self:refreshRewardFlag()
    elseif obKey == RankRaceOBKey.kUnlock then 
        self:handleUnlock(...)
    elseif obKey == RankRaceOBKey.kGiftInfo then 
        self:refreshGiftFlag(...)
	end
end

function RankRaceMainPanel:refreshRewardFlag( ... )
    if self.isDisposed then return end
    local hasReward = RankRaceMgr:getInstance():hasAvailableRewards()
    local btn = HomeScene.sharedInstance().rankRaceButton
    if btn then
        btn:update()
    end
    self.turnableBtn:update(hasReward)
end

function RankRaceMainPanel:handlePassDay(...)
	local params = {...}
    local isPassWeek = params[1]
    if isPassWeek then 
        self:updateSettlement( true )
        self:updateTagPanel(true)
        self:updateRankBar(1, "rank_bar_calculate")
    end
end

function RankRaceMainPanel:handleTargetIncrease(...)
    local params = {...}
    self:updateRankBoard(1, true)
end

function RankRaceMainPanel:handleUnlock(...)
    -- local params = {...}
    -- DcUtil:UserTrack({category='weeklyrace2018', 
    --                     sub_category='weeklyrace2018_unlock_stage', 
    --                     t1 = RankRaceMgr.getInstance():getData().unlockIndex, 
    --                     t2 = params[1]})
    --后端打
    self:updateLevelNode()
end

function RankRaceMainPanel:popout(close_cb)
    self.close_cb = close_cb
	PopoutQueue:sharedInstance():push(self, true, false)
    if self.oneSecondTimer then 
        self.oneSecondTimer:start()
    end
end

function RankRaceMainPanel:popoutShowTransition()

    self.allowBackKeyTap = true

    if self.newSeasonPopOut then
        local context = self
        local function CloseMainPanel()
            context:onCloseBtnTapped()
        end
	    local panel = require('zoo.quarterlyRankRace.view.RankRaceNewSaijiDeskPanel'):create( CloseMainPanel )
	    panel:popout()

        self:lock(true)

        return
    end

    if RankRaceMgr:getInstance():getData():isNormalStatus() then
        local Misc = require('zoo.quarterlyRankRace.utils.Misc')
        local asyncRunner = Misc.AsyncFuncRunner.new()
        asyncRunner:add(function ( done )
            RankRaceMgr.getInstance():tryPopoutOldRewardsPanel(done)
        end)
        asyncRunner:add(function ( done )
            RankRaceMgr.getInstance():tryPopoutLastWeekRewardsPanel(done)
        end)
        asyncRunner:add(function ( done )
            RankRaceMgr.getInstance():tryPopoutDanSharePanel(done)
        end)
        asyncRunner:add(function ( done )
            RankRaceMgr.getInstance():tryPopoutHeadFramePanel(done)
        end)
        asyncRunner:add(function ( done )
            RankRaceMgr.getInstance():tryPopoutSkillDescPanel(done)
        end)
        if self.newSeasonPrePopOut then
            asyncRunner:add(function ( done )
                RankRaceMgr.getInstance():setNewestPreShow()
                local panel = require('zoo.quarterlyRankRace.view.RankRaceNewSaijiDeskPanel'):create(done)
                panel:popout()
            end)
        end
        asyncRunner:run()
    end
end

function RankRaceMainPanel:onCloseBtnTapped()
	PopoutManager:sharedInstance():remove(self, true)
	self.allowBackKeyTap = false
    if self.close_cb then self.close_cb() end
end

function RankRaceMainPanel:dispose()
	BasePanel.dispose(self)
    if self.oneSecondTimer then
        self.oneSecondTimer:stop()
        self.oneSecondTimer = nil
    end
	if self.rankBoard then 
		self.rankBoard:dispose()
        self.rankBoard = nil
	end

    local armatures = {
        'skeleton/rank_race_flag',
        'skeleton/rank_race_reward_box',
    }
    for i,v in ipairs(armatures) do
        FrameLoader:unloadArmature(v, true)
    end
    
	RankRaceMgr.getInstance():removeObserver(self)
    RankRaceMgr.getInstance():resetTempData()
end

function RankRaceMainPanel:create()

    -- local FTWLocalLogic = require 'zoo.localActivity.FindingTheWay.FindingTheWayLocalLogic'
    -- FTWLocalLogic:onLevelEnd()

	local panel = RankRaceMainPanel.new()
	panel:loadRequiredResource("ui/RankRace/MainPanel.json")
	panel:init()
	return panel
end

return RankRaceMainPanel