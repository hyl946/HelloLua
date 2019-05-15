local UIHelper = require 'zoo.panel.UIHelper'
local Misc = require('zoo.quarterlyRankRace.utils.Misc')

Mark2019Panel = class(BasePanel)
function Mark2019Panel:create()
    local panel = Mark2019Panel.new()
    panel:init(initPage)
    return panel
end

function Mark2019Panel:init()
    UIHelper:loadArmature('skeleton/markAnim2019')
    UIHelper:loadArmature('skeleton/markAnim2019_2')
    UIHelper:loadArmature('skeleton/markAnim2019_3')
    
    local ui = UIHelper:createUI("flash/Mark2019/mark2019.json", "Mark2019/Mark2019panel")
    BasePanel.init(self, ui)

    self.bCanClickBtn = false

    self.upbg = self.ui:getChildByName('upbg')
    self.downbg = self.ui:getChildByName('downbg')

    --进度条
    local progressUI = self.upbg:getChildByName('progressUI')
    local progressbg = self.upbg:getChildByName('progressbg')
    
    local zOrder = progressUI:getZOrder()
	local size = progressUI:getGroupBounds(self.upbg).size
	local origin = progressUI:getGroupBounds(self.upbg).origin
	progressUI:removeFromParentAndCleanup(false)

    self.clippingWidth = size.width
	self.clippingHeight = size.height

    local maskSprite = Sprite:createWithSpriteFrameName("Mark2019/progressUI0000")
	maskSprite:setAnchorPoint(ccp(0, 0))
    maskSprite:ignoreAnchorPointForPosition(false)

    local waveClipping = ClippingNode.new(CCClippingNode:create(maskSprite.refCocosObj))
    maskSprite:dispose()
    waveClipping:setAnchorPoint(ccp(0.5, 0))
    waveClipping:setPosition(ccp(origin.x, origin.y))
    waveClipping:setInverted(false)
    waveClipping:setAlphaThreshold(0.1)
    self.upbg:addChildAt(waveClipping,zOrder)
    waveClipping:getStencil():setPosition(ccp(0, 0))

    waveClipping:addChild(progressUI)
    progressUI:setPosition(ccp(-self.clippingWidth, size.height))
    self.progressUI = progressUI

    --礼包
    self.dayBoxList = {}
    self.dayOpenBoxList = {}
    for i=1, 4 do
        local day = self.upbg:getChildByName('day'..Mark2019Manager.MarkGiftDay[i] )
        local dayopen = self.upbg:getChildByName('day'..Mark2019Manager.MarkGiftDay[i].."_open" )

        day:setVisible(false)
        dayopen:setVisible(false)

        self.dayBoxList[i] = day
        self.dayOpenBoxList[i] = dayopen

        UIUtils:setTouchHandler(self.dayBoxList[i], function ( ... )
            --道具TIP
            local rewards = table.clone( Mark2019Manager.getInstance().giftPackInfo[ tostring(Mark2019Manager.MarkGiftDay[i]) ] )

            local Mark2019ItemListTip = require "zoo.panel.Mark2019.Mark2019ItemListTip"
			local tipPanel = Mark2019ItemListTip:create(rewards, nil, -90 )
			tipPanel:setTipString(localize("newsignin.reward.tip.desc") )
			local scene = Director:sharedDirector():getRunningScene()
			scene:addChild(tipPanel , SceneLayerShowKey.TOP_LAYER)
			local bounds = self.dayBoxList[i]:getGroupBounds()
			tipPanel:scaleAccordingToResolutionConfig()
			tipPanel:setArrowPointPositionInWorldSpace( 30 , bounds:getMidX() , bounds:getMidY())
		end)
    end

    --创建日期 
    self:createScrollable()

    self.ok_btn = GroupButtonBase:create(self.downbg:getChildByName('btn_text'))
    self.ok_btn:setString("签到")
    self.ok_btn:setColorMode(kGroupButtonColorMode.green)
    self.ok_btn:ad(DisplayEvents.kTouchTap, function( )
        if not self.bCanClickBtn then return end
        self.bCanClickBtn = false

        local bCanPopTipPanel, itemInfo, MarkDay = self:checkIsCanPopMarkTipPanel()
        if bCanPopTipPanel then
            local function endCall()
                self.bCanClickBtn = true
            end

            --签到精力二次确认
            local Mark2019MarkSurePanel = require "zoo.panel.Mark2019.Mark2019MarkSurePanel"
            Mark2019MarkSurePanel:create( self, MarkDay, itemInfo.itemId, itemInfo.num, endCall ):popout()
        else
            self:showSelectRewardPanel()
        end
        
    end) 

    self.BuQian_btn = ButtonIconNumberBase:create(self.downbg:getChildByName('btn_icon_num_text'))
    self.BuQian_btn:setString("补签")
    self.BuQian_btn:setNumber("0")
    self.BuQian_btn:setIconByFrameName('ui_images/ui_image_coin_icon_small0000')
    self.BuQian_btn:setColorMode(kGroupButtonColorMode.blue)
    self.BuQian_btn:ad(DisplayEvents.kTouchTap, function( )
        if not self.bCanClickBtn then return end

        local function reMarkSure()
            local UsrCoin = UserManager.getInstance().user:getCash()
    
            local bGoldEnouth = false
            local BuQianCost = Mark2019Manager.getInstance():getReMarkCost()
            if UsrCoin >= BuQianCost then
                bGoldEnouth = true
            end

            if bGoldEnouth then
                -- body
                self.bCanClickBtn = false

                local day = Mark2019Manager.getInstance():getCanBuQian()
                if day then
                    self:showSelectRewardPanel( day, true, true )
                end
            else
                Mark2019Manager.getInstance():goldNotEnough()
            end
        end

        reMarkSure()
    end)

    local MarkDayLabel = self.upbg:getChildByName('MarkDay')
    MarkDayLabel:changeFntFile('fnt/qiandao4.fnt')
    MarkDayLabel:setAnchorPoint(ccp(0.5,0.5))
    MarkDayLabel:setScale(0.5)
    MarkDayLabel:setPositionY( MarkDayLabel:getPositionY() - 13/0.7 )
    MarkDayLabel:setPositionX( MarkDayLabel:getPositionX() + 11/0.7 )
    local month = self.downbg:getChildByName('month')
    month:setPositionX( month:getPositionX() + 10/0.7 )
    local noMarkDayLabel = self.downbg:getChildByName('noMarkDay')
    noMarkDayLabel:changeFntFile('fnt/qiandao2.fnt')
    noMarkDayLabel:setAnchorPoint(ccp(0.5,0.5))
    noMarkDayLabel:setPositionX( noMarkDayLabel:getPositionX() + 26/0.7 )
    noMarkDayLabel:setPositionY( noMarkDayLabel:getPositionY() - 15/0.7 )
    self.noMarkDayLabel = noMarkDayLabel

    local hasNoMardDay = self.downbg:getChildByName('hasNoMardDay')
    self.hasNoMardDay = hasNoMardDay
    
end

function Mark2019Panel:_close()

    Mark2019Manager.getInstance():removeObserver(self)

    if self.closeCallback then self.closeCallback() end
    self.allowBackKeyTap = false
    UIHelper:unloadArmature('skeleton/markAnim2019', true)
    UIHelper:unloadArmature('skeleton/markAnim2019_2', true)
    UIHelper:unloadArmature('skeleton/markAnim2019_3', true)
    PopoutManager:sharedInstance():remove(self)
end

function Mark2019Panel:popout()
    self:scaleAccordingToResolutionConfig()
    self:setPositionForPopoutManager()
    PopoutQueue:sharedInstance():push(self, true, nil, nil, nil, nil, 150)
    self.allowBackKeyTap = true

--    self:popoutShowTransition()
end

function Mark2019Panel:popoutShowTransition()

    self.bCanClickBtn = false

    Mark2019Manager.getInstance():addObserver(self)

    local asyncRunner = Misc.AsyncFuncRunner:create()

    asyncRunner:add(function ( done )
        if self.isDisposed then return end

        --更新显示 第一位
        self:PanelUpdate()

        if done then done() end
    end)

    asyncRunner:add(function ( done )
        if self.isDisposed then return end

        --展开界面 第二位
        self:PanelShow( done )
    end)


    for i,v in ipairs(Mark2019Manager.getInstance().complementCache) do
        asyncRunner:add(function ( done )
            if self.isDisposed then return end
            --漏补签
            local DayData = os.date("*t",v/1000 + 8*3600)
            local MarkDay = DayData.day
            self:showSelectRewardPanel( MarkDay, true, false, done )
        end)
    end

    asyncRunner:add(function ( done )
        if self.isDisposed then return end

        --补礼包奖励
        if Mark2019Manager.getInstance().canReward then

            local function GetGiftPackSucess()

                local function endCall()
                    self:PanelUpdateGiftBox()

                    if done then done() end
                end

                self:showPackGetAnim( endCall )
            end

            local function GetGiftPackError()
                if done then done() end
            end

            Mark2019Manager.getInstance():markV2GetGiftPack( GetGiftPackSucess,GetGiftPackError,GetGiftPackError )
        else
            if done then done() end
        end
    end)

    asyncRunner:add(function ( done )
        if self.isDisposed then return end

        --全部签到完成
        self:showMarkAllSharePanel( done )
    end)

    asyncRunner:add(function ( done )
        if self.isDisposed then return end

        --引导
        self:GuideShow()
        if done then done() end
    end)

    asyncRunner:run()
end

function Mark2019Panel:checkIsCanPopMarkTipPanel()
    if self.isDisposed then return false end

    local bTodayMark = Mark2019Manager.getInstance():getCurDayIsMark()
    local MarkDay = Mark2019Manager.getInstance():getMarkAllDay() + 1


    --是否在礼包日
    local inGiftDay = false
    for i,v in ipairs(Mark2019Manager.MarkGiftDay) do
        if MarkDay == v then
            inGiftDay = true
        end
    end

    --礼包是否有无限精力
    local bHaveEnergyItem = false
    local itemInfo = {}
    if inGiftDay then
        local rewardInfo = Mark2019Manager.getInstance().giftPackInfo[tostring(MarkDay)]
        if rewardInfo and rewardInfo.rewards then
            for i,v in ipairs(rewardInfo.rewards) do
                if v.itemId == ItemType.INFINITE_ENERGY_BOTTLE_ONE_MINUTE then
                    bHaveEnergyItem = true 
                    itemInfo = table.clone( v )
                    break
                end
            end
        end
    end

    if not bTodayMark and bHaveEnergyItem then
        return true, itemInfo, MarkDay
    else
        return false
    end
end


function Mark2019Panel:PanelShow( endCallBack )
    if self.isDisposed then return end

    -- up down
    self.upbg:setScaleX(0.175)
    self.upbg:setScaleY(0.93)

    self.downbg:setScaleY(0.01)
    self.downbg:setVisible(false)

    local function upDelayCall()
        self.downbg:setVisible(true)
    end

    local function endCall()
        self.bCanClickBtn = true
        if endCallBack then endCallBack() end
    end

    local upBGShowArray = CCArray:create()
    upBGShowArray:addObject( CCDelayTime:create(0.1)  )
    upBGShowArray:addObject( CCScaleTo:create(0.2, 1.1, 0.87) )
    upBGShowArray:addObject( CCScaleTo:create(0.1, 1, 1) )

    local downBGShowArray = CCArray:create()
    downBGShowArray:addObject( CCDelayTime:create(0.2)  )
    downBGShowArray:addObject( CCCallFunc:create(upDelayCall) )
    downBGShowArray:addObject( CCScaleTo:create(0.1, 1, 1.15) )
    downBGShowArray:addObject( CCScaleTo:create(0.2, 1, 1) )
    downBGShowArray:addObject( CCCallFunc:create(endCall) )

    self.upbg:runAction(CCSequence:create(upBGShowArray))
    self.downbg:runAction(CCSequence:create(downBGShowArray))

    --title chicken
    local title = self.upbg:getChildByName('title')
    title:setOpacity(0)

    local chickenAnim = self.ui:getChildByName('chickenAnim')
    chickenAnim:setOpacity(0)
    
    local title_show_anim = ArmatureNode:create('MarkAnim/title_show_anim')
    title_show_anim:playByIndex(0)
    title_show_anim:update(0.001)
    title_show_anim:stop()
    title_show_anim:setPosition( ccp(219,58) )
    title:addChildAt( title_show_anim,1 )

    local chiclen_anim = ArmatureNode:create('MarkAnim/chiclen_anim')
    chiclen_anim:playByIndex(0)
    chiclen_anim:update(0.001)
    chiclen_anim:stop()
    chiclen_anim:setPosition( ccp(0,95) )
    chickenAnim:addChildAt( chiclen_anim,1 )
    chiclen_anim:setVisible(false)

    local function titleShowCall()
        title_show_anim:play("a", 1)
        title_show_anim:addEventListener(ArmatureEvents.COMPLETE, function()
    	    title_show_anim:removeAllEventListeners()
        end)

        chiclen_anim:setVisible(true)
        chiclen_anim:play("b", 1)
        chiclen_anim:addEventListener(ArmatureEvents.COMPLETE, function()
    	    chiclen_anim:removeAllEventListeners()
            chiclen_anim:play("c")
        end)
    end

    local titleShowArray = CCArray:create()
    titleShowArray:addObject( CCDelayTime:create(0.3)  )
    titleShowArray:addObject( CCCallFunc:create(titleShowCall)  )

    title:runAction(CCSequence:create(titleShowArray))
end

function Mark2019Panel:PanelUpdate( endCallBack )
    if self.isDisposed then return end

    local MarkAllDay = Mark2019Manager.getInstance():getMarkAllDay()
    local MarkAllDayWithOutToday = Mark2019Manager.getInstance():getMarkAllDayWithoutToDay()
    local MarkDay = Mark2019Manager.getInstance().MarkDay
    local MarkMonth = Mark2019Manager.getInstance().month

    --month
    local month = self.downbg:getChildByName('month')
    month:changeFntFile('fnt/qiandao1.fnt')
    month:setText(""..MarkMonth.."月")

    --
    local bMark = Mark2019Manager.getInstance():getCurDayIsMark()
    if bMark then
        self.ok_btn:setString("明日再来")
        self.ok_btn:setEnabled( false )
    end

    --
    local BuQianDay = Mark2019Manager.getInstance():getCanBuQian()
    if not BuQianDay then
        self.hasNoMardDay:setVisible(false)
        self.noMarkDayLabel:setVisible(false)
        self.BuQian_btn:setVisible(false)
    end

    --updateview
    for i,v in ipairs(self.DayUIList) do
        local dayUI = v
        local day = v.DayData.day
        self:updateDayInfo( dayUI, day )
    end

    self:PanelUpdateMarkDay()
    self:PanelUpdateGiftBox()
end

function Mark2019Panel:PanelUpdateMarkDay( )
    local MarkAllDay = Mark2019Manager.getInstance():getMarkAllDay()
    local MarkAllDayWithOutToday = Mark2019Manager.getInstance():getMarkAllDayWithoutToDay()
    local MarkDay = Mark2019Manager.getInstance().MarkDay

    local MarkDayLabel = self.upbg:getChildByName('MarkDay')
    MarkDayLabel:setText(""..MarkAllDay)

    --percent 
    --1-6 0.0238 差值
    --7 0.2857
    --8-13 0.0178 差值
    --14 0.5357 
    --15 - 20 0.0238 差值
    --21 0.8214
    --22-28 0.0297
    local percentList = { 0, 0.0238, 0.0476, 0.0714, 0.0952, 0.119, 0.1328, 0.2368,
         0.2627, 0.2887, 0.3145, 0.3406, 0.3665, 0.3925, 0.5357 ,
         0.5595, 0.5833, 0.6017, 0.6309, 0.6547, 0.6785, 0.8014,
         0.8314, 0.8532, 0.8748, 0.8968, 0.9180, 0.9405, 1, 1, 1, 1 }
    local percent = percentList[MarkAllDay+1]
    self:setProgressPercent( percent )

    local BuQianCost = Mark2019Manager.getInstance():getReMarkCost()
    self.BuQian_btn:setNumber(""..BuQianCost)

    --updatedown
    local noMarkDayLabel = self.downbg:getChildByName('noMarkDay')
    local nMarkDay = MarkDay - 1 - MarkAllDayWithOutToday
    noMarkDayLabel:setText(""..nMarkDay)
end

function Mark2019Panel:PanelUpdateGiftBox( )
    --update up
    for i=1, 4 do
        local day = Mark2019Manager.MarkGiftDay[i]
        if Mark2019Manager.getInstance():getGiftPackIsOpen(day) then
            self.dayBoxList[i]:setVisible(false)
            self.dayOpenBoxList[i]:setVisible(true)
        else
            self.dayBoxList[i]:setVisible(true)
            self.dayOpenBoxList[i]:setVisible(false)
        end
    end
end

function Mark2019Panel:setProgressPercent( percent )
    if self.isDisposed then return end
    if percent == nil then percent = 1 end
    if percent < 0 then percent = 0 end
    if percent > 1 then percent = 1 end

    local endPosX = -self.clippingWidth+percent*self.clippingWidth
    local posy = self.progressUI:getPositionY()
    local array = CCArray:create()
    array:addObject( CCMoveTo:create(0.2, ccp(endPosX,posy))  )
    self.progressUI:stopAllActions()
    self.progressUI:runAction(CCSequence:create(array))
--    self.progressUI:setPositionX(-self.clippingWidth+percent*self.clippingWidth)
end

local itemWidth = 116
local itemHeight = 120
local offset = 6
function Mark2019Panel:createScrollable()

    local showWidth = (itemWidth+offset)*5-offset

	self.rankView = VerticalScrollable:create(showWidth, 456, true, nil, 2/60)
    self.rankView:setIgnoreHorizontalMove(false)
	self.rankView:ignoreAnchorPointForPosition(false)
	self.rankView:setAnchorPoint(ccp(0, 1))
    self.rankView:setPosition(ccp(45, -100))
    self.downbg:addChild(self.rankView)

    local scrollLayout = VerticalTileLayout:create(showWidth)
    self.rankView:setContent(scrollLayout)
    self.rankView:updateScrollableHeight()

    local function hitTestPoint( worldPosition, useGroupTest)
        if self.isDisposed then return end

        local size = self.rankView:getGroupBounds().size
	    local origin = self.rankView:getGroupBounds().origin

        if worldPosition.x < origin.x 
            or worldPosition.x > origin.x + size.width
            or worldPosition.y < origin.y 
            or worldPosition.y > origin.y + size.height
        then 
            return false
        end

        return true
    end
    self.rankView:setGlobalHitTestPoint( hitTestPoint, true)

    --日期
    local year = Mark2019Manager.getInstance().year
    local month = Mark2019Manager.getInstance().month
    local curMonthHasDay = Mark2019Manager.getInstance():getDayByYearMonth( year, month )
    curMonthHasDay = tonumber(curMonthHasDay)
    local maxLength = math.ceil( curMonthHasDay/5 )

    self.DayUIList = {}
    for i=1, maxLength do
        local DayUILayer = self:createDayItem( i, curMonthHasDay )

        local itemInLayout = ItemInLayout:create()
        itemInLayout:setContent(DayUILayer)
        itemInLayout:setHeight(itemInLayout:getHeight())
        scrollLayout:addItem(itemInLayout)

        for i,v in ipairs(DayUILayer.DayUIList) do
            table.insert( self.DayUIList, v )
        end
    end
    self.maxLine = maxLength

    self.rankView:updateScrollableHeight()

    self:MoveToDayLine( self.curDayInLine )
end

function Mark2019Panel:createDayItem( length, curMonthHasDay )
    local MarkDay = Mark2019Manager.getInstance().MarkDay
 
    local DayLineLayer = Layer:create()
    DayLineLayer.DayUIList = {}
    for i=1, 5 do
        local day = (length-1)*5 + i

        if day > curMonthHasDay then break end

	    local DayUI = UIHelper:createUI("flash/Mark2019/mark2019.json", "Mark2019/DayUI")
        DayUI.DayData = {}
        DayUI.DayData.day = day

        DayUI:setPositionX( (i-1)*(itemWidth+offset) )
        DayLineLayer:addChild( DayUI )
        table.insert( DayLineLayer.DayUIList,DayUI )

        if MarkDay == day then
            self.curDayInLine = length
        end

        local function ReMark( day )
            --补签
            self:showReMarkPanel( day )
        end

        local function Mark( day )
            --签到
            self:showSelectRewardPanel()
        end

        --按钮
        if MarkDay == day then
            local dayBg2 = DayUI:getChildByName('dayBg1') 
            UIUtils:setTouchHandler(dayBg2, function ( ... )
                if not self.bCanClickBtn then return end
                Mark( day )
            end)
        elseif day < MarkDay then
            local dayBg2 = DayUI:getChildByName('dayBg2') 
            UIUtils:setTouchHandler(dayBg2, function ( ... )
                if not self.bCanClickBtn then return end
                ReMark( day )
            end)
        end

        
        --child
        local dayLabel = DayUI:getChildByName('day') 
        dayLabel:setString(""..day)


        ---------------update
        self:updateDayInfo( DayUI, day )
        ---------------
        
    end

	return DayLineLayer
end

function Mark2019Panel:HideDayInfo( DayUI )
     if self.isDisposed then return end

    local markOK = DayUI:getChildByName('markOK') 
    markOK:setVisible(false)
    local nomark = DayUI:getChildByName('nomark') 
    nomark:setVisible(false)
    local bu = DayUI:getChildByName('bu') 
    bu:setVisible(false)
    local gift = DayUI:getChildByName('gift') 
    gift:setVisible(false)
    local dayBg1 = DayUI:getChildByName('dayBg1') 
    dayBg1:setVisible(true)
    local dayBg2 = DayUI:getChildByName('dayBg2') 
    dayBg2:setVisible(false)
    local curDayLight = DayUI:getChildByName('curDayLight') 
    curDayLight:setVisible(false)
end

function Mark2019Panel:updateDayInfo( DayUI, day )
     if self.isDisposed then return end

    local MarkDay = Mark2019Manager.getInstance().MarkDay
    local MardData = Mark2019Manager.getInstance():getMarkDataAllInfo()

    local markOK = DayUI:getChildByName('markOK') 
    markOK:setVisible(false)
    local nomark = DayUI:getChildByName('nomark') 
    nomark:setVisible(false)
    local bu = DayUI:getChildByName('bu') 
    bu:setVisible(false)
    local gift = DayUI:getChildByName('gift') 
    gift:setVisible(false)
    local dayBg1 = DayUI:getChildByName('dayBg1') 
    dayBg1:setVisible(false)
    local dayBg2 = DayUI:getChildByName('dayBg2') 
    dayBg2:setVisible(false)
    local curDayLight = DayUI:getChildByName('curDayLight') 
    curDayLight:setVisible(false)
        
    --签到
    local dayLabel = DayUI:getChildByName('day') 
    if MardData[day] then
        markOK:setVisible(true)
        dayBg1:setVisible(true)
        dayLabel:setColor( hex2ccc3('F3CF94') )
    elseif day < MarkDay then
        nomark:setVisible(true)
        bu:setVisible(true)
        dayBg2:setVisible(true)
        dayLabel:setColor( hex2ccc3('DCCC9F') )
    else
        gift:setVisible(true)
        dayBg1:setVisible(true)
        dayLabel:setColor( hex2ccc3('F3CF94') )
    end

    --当前天高亮
    if not MardData[day] and day == MarkDay then
        curDayLight:setVisible(true)
    end
end

--盖章动画
function Mark2019Panel:showMarkAnim( index, done )

    if not self.DayUIList[index]  then return end

    local DayUI = self.DayUIList[index]

    local function MarkOKAnim()
        local balloon_anim = ArmatureNode:create('MarkAnim/mark_ok_anim')
        balloon_anim:playByIndex(0)
        balloon_anim:update(0.001)
        balloon_anim:stop()
        balloon_anim:setPosition( ccp(57,-65) )
        DayUI:addChildAt( balloon_anim, 10 )

        balloon_anim:play("s", 1)
        balloon_anim:addEventListener(ArmatureEvents.COMPLETE, function()
            if self.isDisposed then return end

    	    balloon_anim:removeAllEventListeners()
            balloon_anim:removeFromParentAndCleanup(true)
            self:updateDayInfo( DayUI, DayUI.DayData.day )

            if done then done() end
        end)
    end

    MarkOKAnim()
    if self.boxopenAnim and not self.boxopenAnim.isDisposed then 
        self.boxopenAnim:removeFromParentAndCleanup(true) 
        self.boxopenAnim = nil
    end
--    self:HideDayInfo( DayUI )
end

--礼包领取动画
function Mark2019Panel:showPackGetAnim( AllDone )
    
    local vSize = CCDirector:sharedDirector():getVisibleSize()
    local vOrigin = CCDirector:sharedDirector():getVisibleOrigin()
    local gCenterPos = IntCoord:create(vOrigin.x + vSize.width / 2, vOrigin.y + vSize.height / 2)

    local CangetGiftBoxList = table.clone( Mark2019Manager.getInstance().showGiftBoxList )

    local function sortTable( a,b )
        return a<b
    end
    table.sort( CangetGiftBoxList, sortTable)

    if #CangetGiftBoxList > 0 then
        local asyncRunner = Misc.AsyncFuncRunner:create()

        local endNum = 0
        for i,v in ipairs(CangetGiftBoxList) do

            asyncRunner:add(function ( done )
                if self.isDisposed then return end
                local index = v

                local function PanelCloseCall()
                    if done then done() end

                    endNum = endNum + 1
                    if endNum == #CangetGiftBoxList then
                        Mark2019Manager.getInstance().showGiftBoxList = {}

                        if AllDone then AllDone() end
                    end
                end

                local Mark2019GiftBoxPanel = require "zoo.panel.Mark2019.Mark2019GiftBoxPanel"
                Mark2019GiftBoxPanel:create( self, PanelCloseCall, index):popout()
            end)
        end

        asyncRunner:run()
    else
        if AllDone then AllDone() end
    end
end

--全部签到完成
function Mark2019Panel:showMarkAllSharePanel( done )

     --日期
    local year = Mark2019Manager.getInstance().year
    local month = Mark2019Manager.getInstance().month
    local curMonthHasDay = Mark2019Manager.getInstance():getDayByYearMonth( year, month )
    curMonthHasDay = tonumber(curMonthHasDay)

    local MarkAllDay = Mark2019Manager.getInstance():getMarkAllDay()
    local bHasShareThisMonth = self:needShowShareTip()
    if MarkAllDay == curMonthHasDay and Mark2019Manager.getInstance():isSupportShare() and bHasShareThisMonth then
        local function PanelCloseCall()
            if done then done() end
        end
        local Mark2019FullMarkShare = require "zoo.panel.Mark2019.Mark2019FullMarkShare"
        Mark2019FullMarkShare:create(PanelCloseCall):popout()

        self:hadShowShareTip()
    else
        if done then done() end 
    end
end

function Mark2019Panel:showMarkEndAnim( CurMarkDay )
    if self.isDisposed then return end

    self.bCanClickBtn = false

    local asyncRunner = Misc.AsyncFuncRunner:create()
    local MardData = Mark2019Manager.getInstance():getMarkDataAllInfo()

    if MardData[CurMarkDay] then
        asyncRunner:add(function ( done )
            if self.isDisposed then return end

            --更新签到按钮
            local bMark = Mark2019Manager.getInstance():getCurDayIsMark()
            if bMark then
                self.ok_btn:setString("明日再来")
                self.ok_btn:setEnabled( false )
            end

            --移动到天
            self:MoveToDayLineByDay( CurMarkDay, done )
        end)

        asyncRunner:add(function ( done )
            if self.isDisposed then return end

            --延迟一下再下一步
            local function delayEndCall()
                if self.isDisposed then return end
                if done then done() end
            end

            setTimeOut( delayEndCall, 0.2 ) 
        end)

        asyncRunner:add(function ( done )
            if self.isDisposed then return end

            local function endCall()
                self:PanelUpdateMarkDay()

                if done then done() end
            end

            --盖章
            self:showMarkAnim( CurMarkDay, endCall )
        end)

        asyncRunner:add(function ( done )
            if self.isDisposed then return end

            local function endCall()
                self:PanelUpdateGiftBox()

                if done then done() end
            end

            --礼包领取
            self:showPackGetAnim( endCall )
        end)

        asyncRunner:add(function ( done )
            if self.isDisposed then return end

            --全部签到完成
            self:showMarkAllSharePanel( done )
        end)
    end

    asyncRunner:add(function ( done )
        if self.isDisposed then return end

        --更新显示
        self:PanelUpdate()

        if done then done() end
    end)

    asyncRunner:add(function ( done )
        if self.isDisposed then return end

        self.bCanClickBtn = true
        if done then done() end
    end)


    asyncRunner:run()
end

function Mark2019Panel:showSelectRewardPanel( day, bReMark, bNeedBuy, done )

    local MarkDay
    if day == nil then 
        MarkDay = Mark2019Manager.getInstance().MarkDay
    else
        MarkDay = day
    end
    if bReMark == nil then bReMark = false end
    if bNeedBuy == nil then bNeedBuy = true end

    local MardData = Mark2019Manager.getInstance():getMarkDataAllInfo()

    if MardData[MarkDay] then
        if done then done() end
        return
    end

    local function moveEndCall()
        local CurMarkDay = MarkDay

        local function SelectPanelCloseCall()
            if self.isDisposed then return end

            local BuQianDay = Mark2019Manager.getInstance():getCanBuQian()
            if not BuQianDay then
                self.hasNoMardDay:setVisible(false)
                self.noMarkDayLabel:setVisible(false)
                self.BuQian_btn:setVisible(false)
            end

--            local showMarkDay = Mark2019Manager.getInstance().showMarkDay
            self:showMarkEndAnim( MarkDay )

            if self.markCallback then self.markCallback() end
            if done then done() end 
        end

        local Mark2019SelectPanel = require "zoo.panel.Mark2019.Mark2019SelectPanel"

        Mark2019SelectPanel:create(SelectPanelCloseCall, bReMark, CurMarkDay, bNeedBuy ):popout()

        self:showPackOpenAnim( MarkDay )
    end
    self:MoveToDayLineByDay( MarkDay, moveEndCall, true )
end

function Mark2019Panel:showReMarkPanel( day )

    local function moveEndCall()
        local function BuQianCall()
            if self.isDisposed then return end

            local BuQianDay = Mark2019Manager.getInstance():getCanBuQian()
            if not BuQianDay then
                self.hasNoMardDay:setVisible(false)
                self.noMarkDayLabel:setVisible(false)
                self.BuQian_btn:setVisible(false)
            end
            self:showMarkEndAnim( day )
        end

        local function PackOpenAnim()
            if self.isDisposed then return end
            self:showPackOpenAnim( day )
        end

        local Mark2019BuQianPanel = require "zoo.panel.Mark2019.Mark2019BuQianPanel"
        Mark2019BuQianPanel:create(BuQianCall, day, PackOpenAnim ):popout()
    end
    self:MoveToDayLineByDay( day, moveEndCall, true  )
end

function Mark2019Panel:showPackOpenAnim( index )
    if self.isDisposed then return end
    if not self.DayUIList[index]  then return end

    local DayUI = self.DayUIList[index]
    self:HideDayInfo( DayUI )

    local boxopenAnim = ArmatureNode:create('MarkAnim/boxopenAnim')
    boxopenAnim:playByIndex(0)
    boxopenAnim:update(0.001)
    boxopenAnim:stop()
    boxopenAnim:setPosition( ccp(31,-31) )
    DayUI:addChildAt( boxopenAnim, 10 )

    boxopenAnim:play("B", 1)
    boxopenAnim:addEventListener(ArmatureEvents.COMPLETE, function()
        if self.isDisposed then return end
    	boxopenAnim:removeAllEventListeners()
--        boxopenAnim:removeFromParentAndCleanup(true)
    end)

    self.boxopenAnim = boxopenAnim
end

function Mark2019Panel:MoveToDayLineByDay( day,moveEndCall, bDelay )
    local DayInLine = math.ceil(day/5)

    self:MoveToDayLine( DayInLine, moveEndCall, bDelay )
end

function Mark2019Panel:MoveToDayLine( DayInLine, moveEndCall, bDelay )
    if not DayInLine or not self.maxLine then return end
    if bDelay == nil then bDelay = false end

    if DayInLine > 3 then
        if DayInLine > self.maxLine - 3 then
            self.rankView:__moveTo( itemHeight*(self.maxLine - 3.7), 0.1 )
        elseif DayInLine <= self.maxLine - 3 then
            self.rankView:__moveTo( (self.maxLine-DayInLine) * itemHeight, 0.1 )
        end
    else
        self.rankView:__moveTo( 0, 0.1 )
    end

    self.rankView:addEventListener(ScrollableEvents.kEndMoving, function()

        if self.isDisposed then return end

        self.rankView:updateContentViewArea()
        self.rankView:removeAllEventListeners()

        local function delayEnd()
            if moveEndCall then moveEndCall() end
        end
		
        if bDelay then
            setTimeOut( delayEnd, 0.2 )
        else
            delayEnd()
        end
	end)
end

function Mark2019Panel:setPositionForPopoutManager()
    local vSize = CCDirector:sharedDirector():getVisibleSize()
    local posAdd =  CCDirector:sharedDirector():getVisibleOrigin().y
    self:setPosition(ccp(self:getHCenterInScreenX(), -(vSize.height - self:getVCenterInScreenY() + posAdd)))
end

function Mark2019Panel:onCloseBtnTapped( ... )
    if self.bCanClickBtn then
        self:_close()
    end
end

function Mark2019Panel:setMarkCallback(callback)
	self.markCallback = callback
end

function Mark2019Panel:setCloseCallback(callback)
	self.closeCallback = callback
end

function Mark2019Panel:onPassDay()
    self:_close()
end

function Mark2019Panel:GuideShow()

    local bNeedShowGuide =  self:needShowTip()

    if bNeedShowGuide and Mark2019Manager.getInstance().newUser == false then
        local markGuidePanel = UIHelper:createUI("flash/Mark2019/mark2019.json", "Mark2019/markGuidePanel")
        markGuidePanel:setPosition(ccp(180,-40))
        markGuidePanel:setScale(0.95)
        self.ui:addChildAt(markGuidePanel,10)

        markGuidePanel:setScale(0.1)

        local function hidePanel()
            markGuidePanel:setVisible(false)
        end

        local function callend()
            local array = CCArray:create()
            array:addObject( CCScaleTo:create(0.3, 0.1)  )
            array:addObject(CCCallFunc:create(hidePanel))

            markGuidePanel:runAction( CCSequence:create(array) )
        end

        local array = CCArray:create()
        array:addObject( CCScaleTo:create(0.1, 1.1)  )
        array:addObject( CCScaleTo:create(0.2, 0.9)  )
        array:addObject( CCScaleTo:create(0.1, 1)  )
        array:addObject( CCDelayTime:create(4)  )
        array:addObject(CCCallFunc:create(callend))

        markGuidePanel:runAction( CCSequence:create(array) )

        self:hadShowTip()
    end
end

function Mark2019Panel:getTipkey( ... )
    local uid = UserManager:getInstance().user.uid or '12345'
    local key = 'Mark2019_GuideFlag.' .. uid
    return key
end

function Mark2019Panel:needShowTip( ... )
	return CCUserDefault:sharedUserDefault():getBoolForKey(self:getTipkey(), false) == false
end

function Mark2019Panel:hadShowTip( ... )
	CCUserDefault:sharedUserDefault():setBoolForKey(self:getTipkey(), true)
end

function Mark2019Panel:getShareTipkey( ... )
    local uid = UserManager:getInstance().user.uid or '12345'
    local year = Mark2019Manager.getInstance().year
    local month = Mark2019Manager.getInstance().month
    local key = 'Mark2019_FullMarkShare.'..year.."-"..month..".".. uid
    return key
end

function Mark2019Panel:needShowShareTip( ... )
	return CCUserDefault:sharedUserDefault():getBoolForKey(self:getShareTipkey(), false) == false
end

function Mark2019Panel:hadShowShareTip( ... )
	CCUserDefault:sharedUserDefault():setBoolForKey(self:getShareTipkey(), true)
end