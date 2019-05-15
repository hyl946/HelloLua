local AreaTaskInfoPanel = class(BasePanel)
local layoutUtils =  require 'zoo.panel.happyCoinShop.utils'
local UIHelper = require 'zoo.panel.UIHelper'
local TickTaskMgr = require 'zoo.areaTask.TickTaskMgr'



local k1 = 0.95
local k2 = 0.81
local k3 = 0.53
local k4 = 0.18


function AreaTaskInfoPanel:create(areaId)
    local panel = AreaTaskInfoPanel.new()
    panel:init(areaId)
    return panel

end

local progress_params = {
    213.7, 445.55, 721.6
}


function AreaTaskInfoPanel:init(areaId)

    self.areaId = areaId
    self.panelLuaName = "AreaTaskInfoPanel"
    local model = AreaTaskMgr:getInstance():getModel()

    local taskInfos = model:getTaskInfosByAreaId(self.areaId)

    local indexMapTaskInfo = {}
    for i, taskInfo in ipairs(taskInfos) do
        indexMapTaskInfo[taskInfo.index] = taskInfo
    end

    local ui = UIHelper:createUI("ui/area_task.json", "area_task.panel/area_task")
    self.ui = ui

    BasePanel.init(self, ui)

    self:setScale(1)
    self:setPositionXY(0, 0)
    UIUtils:adjustUI(ui, (1724 - 1560)/2, nil, nil, 1724)

    local label = self.ui:getChildByPath('label')
    label:changeFntFile('fnt/timelimit_gift.fnt')
    label:setAnchorPoint(ccp(0.5, 0.5))
    UIHelper:move(label, label.width/2, -label.height/2)
    label:setText(localize('area.goal.context '))


    local btn = GroupButtonBase:create(self.ui:getChildByPath('btn'))
    btn:setString(localize('area.goal.btn'))
    btn:ad(DisplayEvents.kTouchTap,     preventContinuousClick(function ( ... )
        self:onTapPlay()
    end))


    self:initProgress()

    -- self:setProgress(0)

    -- local bbb = 0.0

    -- ____BBBB = function ( ... )
    --     printx(61, bbb)
    --     self:setProgress(bbb)
    --     bbb = bbb + 0.01
    -- end
    -- ____CCCC = function ( ... )
    --     printx(61, bbb)
    --     self:setProgress(bbb)
    --     bbb = bbb - 0.01
    -- end


    for taskIndex, taskInfo in pairs(indexMapTaskInfo) do
        if not model:isTaskFinished(taskInfo) then
            local timeout = taskInfo.endTime - Localhost:time()
            if timeout > 0 then
                timeout = math.floor(timeout / 1000)
                local txt = self:getTimeTxt(timeout)
                self.ui:getChildByPath('target_label_' .. taskIndex):setText(txt)
            end
        end
    end

    local liushaIndex = self.ui:getChildIndex(self.ui:getChildByPath('fg2')) - 1
    local liushaAnim = UIHelper:createArmature2('skeleton/area_task_liusha', 'area_task.liusha/anim')
    self.ui:addChildAt(liushaAnim, liushaIndex)
    liushaAnim:setPosition(ccp(460 - 3, -1249 + 225))
    liushaAnim:setScale(1.2)
    
    local fg2 = self.ui:getChildByPath('fg2')
    fg2:removeFromParentAndCleanup(false)
    self.ui:addChild(fg2)
    

    liushaAnim:playByIndex(0, 1)



    self.tickTaskMgr = TickTaskMgr.new()
    local REFRESH_UI_ID = 1
    self.tickTaskMgr:setTickTask(REFRESH_UI_ID, function ( ... )
        self:refreshUI()
    end)
    self.tickTaskMgr:step()
    self.tickTaskMgr:start()


    for i = 1, 3 do
        local target_label = self.ui:getChildByPath('target_label_' .. i)
        target_label:changeFntFile('fnt/timelimit_gift_2.fnt')
        target_label:setAnchorPoint(ccp(0.5, 0.5))
        UIHelper:move(target_label, target_label.width/2, -target_label.height/2)
    end

end

function AreaTaskInfoPanel:initProgress( ... )
    if self.isDisposed then return end
    local progressFGMask = self.ui:getChildByPath('progressFGMask')
    progressFGMask:setMaskAnchorPoint(ccp(0.5, 0))
    progressFGMask:setMaskValue(1, 0.4)

    self.progressFGMask = progressFGMask
end

function AreaTaskInfoPanel:setProgress( p )
    if self.isDisposed then return end

    self.progressFGMask:setMaskValue(1, p)
    local pos = self.progressFGMask:getScarphPos()[1]

    pos = self.ui:convertToNodeSpace(pos)

    local lh = self.ui:getChildByPath('lh')
    lh:setPositionXY(pos.x + 1.6, pos.y-1.5)


    local lh2 = self.ui:getChildByPath('lh2')
    lh2:setPositionXY(pos.x - 0.7, pos.y-2)

    lh2:setVisible(p > (k1 + k2) / 2)
    lh:setVisible(p <= (k1 + k2) / 2)

    local maxScale = 1
    local minScale = 0.2

    local b = 0.19
    local a = 0.07

    local scale = 1

    if p < a then
        scale = minScale
    elseif p > b then
        scale = maxScale
    else
        scale = (p - a)/(b - a) * (maxScale - minScale) + minScale
    end
    lh:setScale(scale)

end


function AreaTaskInfoPanel:refreshUI( ... )
    if self.isDisposed then return end
    
    local model = AreaTaskMgr:getInstance():getModel()
    local taskInfos = model:getTaskInfosByAreaId(self.areaId)
    local indexMapTaskInfo = {}
    for i, taskInfo in ipairs(taskInfos) do
        indexMapTaskInfo[taskInfo.index] = taskInfo
    end


    local allTaskInfos = model:getAllTaskInfosByAreaId(self.areaId)

    local allIndexMapTaskInfo = {}
    for i, taskInfo in ipairs(allTaskInfos) do
        allIndexMapTaskInfo[taskInfo.index] = taskInfo
    end


    for i = 1, 3 do
        local _taskInfo = allIndexMapTaskInfo[i]

        if not _taskInfo then
            self:onCloseBtnTapped()
            return
        end

        local rewardUI = self.ui:getChildByPath('reward_' .. i)
        local rewardLabel = self.ui:getChildByPath('reward_label_' .. i)
        self:setRewardUI(rewardUI, rewardLabel, _taskInfo)
        UIUtils:setTouchHandler(rewardUI, function ( ... )
            self:onTapRewardItem(rewardUI, _taskInfo)
        end)
    end


    for taskIndex, taskInfo in pairs(indexMapTaskInfo) do
        if not model:isTaskFinished(taskInfo) then
            local timeout = taskInfo.endTime - Localhost:time()
            if timeout > 0 then
                timeout = math.floor(timeout / 1000)
                local txt = self:getTimeTxt(timeout)
                self.ui:getChildByPath('target_label_' .. taskIndex):setText(txt)
            else
                self.ui:getChildByPath('target_label_' .. taskIndex):setText('')
            end
        end
    end


    self:refreshProgress()

end

function AreaTaskInfoPanel:refreshProgress( ... )
    if self.isDisposed then return end
    local model = AreaTaskMgr:getInstance():getModel()

    local allTaskInfos = model:getAllTaskInfosByAreaId(self.areaId)

    local allIndexMapTaskInfo = {}
    for i, taskInfo in ipairs(allTaskInfos) do
        allIndexMapTaskInfo[taskInfo.index] = taskInfo
    end
    
    local endTimeList = {}
    local beginTime = 0

    for taskIndex, taskInfo in pairs(allIndexMapTaskInfo) do
        table.insert(endTimeList, taskInfo.endTime)
        beginTime = taskInfo.beginTime
    end

    -- beginTime 0.9
    -- endTimeList[1] 0.53
    -- endTimeList[2] 0.18
    -- endTimeList[3] 0.0


    while #endTimeList < 3 do
        table.insert(endTimeList, 1, Localhost:time())
    end

    table.sort(endTimeList)


    local function lerp( a, b, aa, bb, k )
        return (k - aa) / (bb - aa) * (b - a) + a
    end

    local now = Localhost:time()
    local progress = 0

    

    if now < beginTime then
        progress = k1
    elseif now < endTimeList[1] then
        progress = lerp(k1, k2, beginTime, endTimeList[1], now)
    elseif now < endTimeList[2] then
        progress = lerp(k2, k3, endTimeList[1], endTimeList[2], now)
    elseif now < endTimeList[3] then
        progress = lerp(k3, k4, endTimeList[2], endTimeList[3], now)
    else
        progress = 0
    end

    self:setProgress(progress)
end

function AreaTaskInfoPanel:onTapRewardItem( rewardUI, taskInfo )
    if self.isDisposed then return end

    if taskInfo then
        if AreaTaskMgr:getInstance():getModel():isTaskFinished(taskInfo) or AreaTaskMgr:getInstance():getModel():isExpired(taskInfo) then
        else
            local rewards = table.clone(taskInfo.rewards or {}, true)

            local tipPanel = BoxRewardTipPanel:create({ rewards=rewards}, nil, nil, true)
            tipPanel:setTipString('奖励: ')
            self.ui:addChild(tipPanel)
            local bounds = rewardUI:getGroupBounds()
            tipPanel:setArrowPointPositionInWorldSpace(70,bounds:getMidX(),bounds:getMidY())

            tipPanel.name = 'tipPanel' .. taskInfo.levelId
        end
    end
end

function AreaTaskInfoPanel:setRewardUI( rewardUI, rewardLabel, taskInfo )
    if self.isDisposed then return end
    if rewardUI.isDisposed then return end
    if rewardLabel.isDisposed then return end

    if not rewardUI.initedLight then
        rewardUI.initedLight = true
        rewardUI:getChildByPath('light'):runAction(CCRepeatForever:create(CCSequence:createWithTwoActions(
            CCSequence:createWithTwoActions(
                CCFadeIn:create(18/30),
                CCFadeOut:create(18/30)
            ),
            CCDelayTime:create(1.4)
        )))
    end

    if not rewardUI.initedStar then
        rewardUI.initedStar = true
        for i = 1, 3 do
            local star = rewardUI:getChildByPath('star' .. i)
            local array = CCArray:create()
            array:addObject(CCDelayTime:create( i * 5 / 30))
            array:addObject(CCCallFunc:create(function ( ... )
                if star.isDisposed then return end
                star:setScale(0.298)
            end))
            array:addObject(CCScaleTo:create(10/30, 1.239, 1.239))
            array:addObject(CCScaleTo:create(13/30, 0.001, 0.001))
            array:addObject(CCDelayTime:create( (4-i) * 5 / 30))
            star:runAction(CCRepeatForever:create(CCSequence:create(array)))
        end

        rewardUI.setStarVisible = function ( _, bVisible )
            for i = 1, 3 do
                rewardUI:getChildByPath('star' .. i):setVisible(bVisible)
            end
        end
    end

    if not rewardUI.initedTimerLabel then
        rewardUI.initedTimerLabel = true
        local label = rewardUI:getChildByPath('label')
        -- label:changeFntFile('fnt/timelimit_gift.fnt')
        -- label:setAnchorPoint(ccp(0.5, 0.5))
        -- UIHelper:move(label, label.width/2, -label.height/2)

    end

    if not rewardLabel.initedFnt then
        rewardLabel.initedFnt = true
        rewardLabel:changeFntFile('fnt/timelimit_gift.fnt')
        local label = rewardLabel
        label:setAnchorPoint(ccp(0.5, 0.5))
        UIHelper:move(label, label.width/2, -label.height/2)
    end

    if not rewardUI.rewardInited then
        local iconContainer = rewardUI:getChildByPath('icon/icon')
        for i = 1, 3 do


            local iconHolder = iconContainer:getChildByPath(tostring(i))
            local rewardItem = taskInfo and taskInfo.rewards[i] or nil
            if rewardItem then
                local sp = ResourceManager:sharedInstance():buildItemSpriteWithDecorate(rewardItem.itemId)
                iconHolder:setOpacity(0)
                iconHolder:addChild(sp)
                sp:setAnchorPoint(ccp(0.5, 0.5))
                sp:setPosition(ccp(137/2, 137/2))
                sp.name = 'sp niu2x' .. i
            else
                iconHolder:setVisible(false)
            end
        end
        rewardUI.rewardInited = true
    end

    if taskInfo.rewarded then

        rewardUI:getChildByPath('labelBG'):setVisible(false)
        rewardUI:getChildByPath('label'):setVisible(false)
        rewardUI:getChildByPath('light'):setVisible(false)
        rewardUI:setStarVisible(false)
        rewardLabel:setText('已获得')
        rewardUI:getChildByPath('checked'):setVisible(true)

        return
    end

    rewardLabel:setText(localize('area.goal.desc1', {num = taskInfo.levelId}))


    local timeout = taskInfo.endTime - Localhost:time()


    if timeout <= 0 then

        rewardUI:getChildByPath('labelBG'):setVisible(false)
        rewardUI:getChildByPath('label'):setVisible(false)
        rewardUI:getChildByPath('light'):setVisible(false)
        rewardUI:setStarVisible(false)

        rewardUI:getChildByPath('checked'):setVisible(false)

        rewardUI:getChildByPath('normal'):adjustColor(0, -1, 0, 0)
        rewardUI:getChildByPath('normal'):applyAdjustColorShader()

        -- rewardUI:getChildByPath('icon'):adjustColor(0, -1, 0, 0)
        -- rewardUI:getChildByPath('icon'):applyAdjustColorShader()

        rewardLabel:setText('已过期')


        local function walk_node( node, func )
            if not node then return end
            if node.isDisposed then return end

            func(node)

            for _, v in pairs(node:getChildrenList()) do
                walk_node(v, func)
            end

        end

        walk_node(rewardUI:getChildByPath('icon'), function ( node )
            if node.adjustColor and node.applyAdjustColorShader then
                node:adjustColor(0, -1, 0, 0)
                node:applyAdjustColorShader()
            end
        end)


        if rewardUI:getChildByPath('timerLabel') then
            rewardUI:getChildByPath('timerLabel'):setText('')
        end

        local tipPanel = self.ui:getChildByPath('tipPanel' .. taskInfo.levelId)
        if tipPanel then
            tipPanel:removeFromParentAndCleanup(true)
        end
    else
        rewardUI:getChildByPath('checked'):setVisible(false)

        timeout = math.floor(timeout / 1000)
        if timeout <= 3600 * 24 then
            if not rewardUI:getChildByPath('timerLabel') then
                local label = BitmapText:create("","fnt/timelimit_gift.fnt")
                label.name = 'timerLabel'
                local labelHolder = rewardUI:getChildByPath('label')
                local leftUpPos = labelHolder:getPosition()
                local centerPos = ccp(
                        leftUpPos.x + labelHolder.width/2,
                        leftUpPos.y - labelHolder.height/2 - 3
                    )
                label:setAnchorPoint(ccp(0.5, 0.5))
                label:setPosition(centerPos)
                label:setColor(hex2ccc3('990000'))
                label:setScale(1.0)
                rewardUI:addChild(label)
            end
            rewardUI:getChildByPath('timerLabel'):setText(self:getTimeTxt(timeout))
            rewardUI:getChildByPath('labelBG'):setVisible(true)
        else
            rewardUI:getChildByPath('labelBG'):setVisible(false)
            rewardUI:getChildByPath('label'):setVisible(false)

        end
    end
end

function AreaTaskInfoPanel:getTimeTxt( timeout )
    if timeout <= 3600 * 24 then
        return convertSecondToHHMMSSFormat(timeout)
    else
        return localize('area.goal.desc2', {num = math.floor(timeout / (3600 * 24))})
    end
end

function AreaTaskInfoPanel:onTapPlay( ... )
    if self.isDisposed then return end
    self:_close()

    local myTopLevel = UserManager:getInstance().user:getTopLevelId()
    local playLevelId = myTopLevel

    local model = AreaTaskMgr:getInstance():getModel()
    local taskInfos = model:getTaskInfosByAreaId(self.areaId)
    local indexMapTaskInfo = {}
    for i, taskInfo in ipairs(taskInfos) do
        indexMapTaskInfo[taskInfo.index] = taskInfo
    end

    for i = 1, 3 do
        if indexMapTaskInfo[i] then
            local levelId = indexMapTaskInfo[i].levelId
            if levelId <= myTopLevel and (not model:isExpired(indexMapTaskInfo[i])) then
                playLevelId = levelId
                break
            end
        end
    end

    HomeScene:sharedInstance().worldScene:moveNodeToCenter(playLevelId, function ( ... )
        if not PopoutManager:sharedInstance():haveWindowOnScreen() and not HomeScene:sharedInstance().ladyBugOnScreen then
            local panel = StartGamePanel:create(playLevelId, GameLevelType.kMainLevel)
            panel:popout(false)
        end
    end)
end

function AreaTaskInfoPanel:popoutPush(close_cb)
    self.close_cb = close_cb
    PopoutQueue:sharedInstance():push(self, false)
end

function AreaTaskInfoPanel:popout()
    PopoutManager:sharedInstance():add(self, false)
    self:popoutShowTransition()
end

local instance = nil

function AreaTaskInfoPanel:createSingletonAndPush( ... )
    if (not instance) or instance.isDisposed then
        local EmptyPanel = require 'zoo.areaTask.EmptyPanel'
        instance = EmptyPanel:create(function ( ... )
            local taskInfos = AreaTaskMgr:getInstance():getModel():getCurTaskInfos()
            if #taskInfos > 0 then
                local levelId = taskInfos[#taskInfos].levelId
                local areaId = math.floor((levelId - 1) / 15) + 40001
                local panel = AreaTaskInfoPanel:create(areaId)
                panel:ad(PopoutEvents.kRemoveOnce, function ( ... )
                    if instance.isDisposed then return end
                    instance:runAction(CCCallFunc:create(function ( ... )
                        if instance.isDisposed then return end
                        instance:_close()
                    end))
                end)
                panel:popout()
            else
                instance:_close()
            end
        end)
        instance:popout()
    end
end

function AreaTaskInfoPanel:onButtonTap( buttonName )
    if self.isDisposed then return end
    if buttonName == 'descBtn' then
        local AreaTaskDescPanel = require 'zoo.areaTask.AreaTaskDescPanel'
        AreaTaskDescPanel:create():popout()
    end
end

function AreaTaskInfoPanel:onCloseBtnTapped( ... )
    self:_close()
end

function AreaTaskInfoPanel:_close()
    if self.close_cb then self.close_cb() end
    if self.isDisposed then return end
    self.allowBackKeyTap = false
    PopoutManager:sharedInstance():remove(self)
end

function AreaTaskInfoPanel:dispose()
    BasePanel.dispose(self)
    self.tickTaskMgr:stop()

end

function AreaTaskInfoPanel:popoutShowTransition()
    if self.isDisposed then return end
    self.allowBackKeyTap = true

    local layoutUtils =  require 'zoo.panel.happyCoinShop.utils'
    local vSize = Director:sharedDirector():getVisibleSize()
    local wSize = Director:sharedDirector():getWinSize()
    local vOrigin = Director:sharedDirector():getVisibleOrigin()
    local mask = LayerColor:create()
    mask:changeWidthAndHeight(wSize.width/self.ui:getScaleX(), wSize.height/self.ui:getScaleY())
    mask:setColor(ccc3(0, 0, 0))
    mask:setOpacity(200)
    self.ui:addChildAt(mask, 0)
    local layoutUtils =  require 'zoo.panel.happyCoinShop.utils'
    layoutUtils.setNodeRelativePos(mask, layoutUtils.MarginType.kLEFT, 0)
    layoutUtils.setNodeRelativePos(mask, layoutUtils.MarginType.kBOTTOM,  -vOrigin.y)
    self.maskLayer = mask

end

return AreaTaskInfoPanel