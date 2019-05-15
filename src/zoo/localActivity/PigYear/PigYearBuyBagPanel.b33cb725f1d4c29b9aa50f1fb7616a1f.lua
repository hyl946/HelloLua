local PigYearLogic = require 'zoo.localActivity.PigYear.PigYearLogic'
local PicYearMeta = require 'zoo.localActivity.PigYear.PicYearMeta'
local LuckyBagGroup = require 'zoo.localActivity.PigYear.LuckyBagGroup'
local TickTaskMgr = require 'zoo.areaTask.TickTaskMgr'
local layoutUtils =  require 'zoo.panel.happyCoinShop.utils'
local Misc = require('zoo.quarterlyRankRace.utils.Misc')

local UIHelper = require 'zoo.panel.UIHelper'

local AnimationPlayer = require 'zoo.panel.endGameProp.anim.AnimationPlayer'
local PropertyTrack = require 'zoo.panel.endGameProp.anim.PropertyTrack'
local FuncTrack = require 'zoo.panel.endGameProp.anim.FuncTrack'
require "zoo.scenes.component.HomeScene.flyToAnimation.NewOpenBoxAnimation"

local PigYearBuyBagPanel = class(BasePanel)

function PigYearBuyBagPanel:create(style,rewards,sucess_toppanel)
    local panel = PigYearBuyBagPanel.new()
    panel:init(style,rewards,sucess_toppanel)
    return panel
end

function PigYearBuyBagPanel:init(style,rewards,sucess_toppanel)
    local ui = UIHelper:createUI("ui/FifthAnniversary/sucesstip.json", "FifthAnniversary_sucessTip/sucessTip")
	BasePanel.init(self, ui)
    UIUtils:adjustUI(ui, 251, nil, nil, 1764)

    self.style = style
    self.rewards = rewards

    self.LevelSucessPanel = sucess_toppanel

    --找出购买福袋信息
    local bagItem
    for i,v in ipairs(self.rewards) do
        if v.itemId >= PicYearMeta.ItemIDs.LUCKY_BAG_M_1 and v.itemId <= PicYearMeta.ItemIDs.LUCKY_BAG_M_4 then
            bagItem = table.clone(v)
            break
        end
    end


    local goodsId = 0 --616,617,618
    if bagItem.itemId == PicYearMeta.ItemIDs.LUCKY_BAG_M_2 then
        self.goodsId = 616
    elseif bagItem.itemId == PicYearMeta.ItemIDs.LUCKY_BAG_M_3 then
        self.goodsId = 617
    elseif bagItem.itemId == PicYearMeta.ItemIDs.LUCKY_BAG_M_4 then
        self.goodsId = 618
    end

    self.bagItem = bagItem

    local meta = MetaManager:getInstance():getGoodMeta(self.goodsId)
    self.buyDoublePrice = 30
    if meta then
        self.buyDoublePrice = meta.qCash
    end
    --------------

    self.bCanClickBtn = true
    self.Buy_btn = ButtonIconNumberBase:create(self.ui:getChildByName('btn'))
    self.Buy_btn:setString("蛋糕翻倍")
    self.Buy_btn:setNumber(""..self.buyDoublePrice)
    self.Buy_btn:setIconByFrameName('ui_images/ui_image_coin_icon_small0000')
    self.Buy_btn:setColorMode(kGroupButtonColorMode.green)
    self.Buy_btn:ad(DisplayEvents.kTouchTap, function( )
        if self.isDisposed then return end
        if not self.bCanClickBtn then return end

        self.bCanClickBtn = false
        self:BuyDoubleItemLogic()
    end)

    self.object1 = self.ui:getChildByName('object1')
    self.object2 = self.ui:getChildByName('object2')
    self.object3 = self.ui:getChildByName('object3')
    local object3Pos = self.object3:getPosition()
    self.object3SavePos = IntCoord:create( object3Pos.x, object3Pos.y )
    self.objecttip = self.ui:getChildByName('objecttip')

    self.bHaveTicket = false
    self.BagLevel = 1
    self.TicketNum = 0
    for i,v in ipairs(self.rewards) do
        if v.itemId == PicYearMeta.ItemIDs.GOLD and v.num > 0 then
            self.bHaveTicket = true
            self.TicketNum = v.num
        elseif v.itemId >= PicYearMeta.ItemIDs.LUCKY_BAG_M_1 and v.itemId <= PicYearMeta.ItemIDs.LUCKY_BAG_M_4 then
            self.BagLevel = v.itemId - PicYearMeta.ItemIDs.LUCKY_BAG_M_1 + 1
        end
    end

    self:addBagLevelToItem(self.object1)
    self:addBagLevelToItem(self.object3)
    self:addBagLevelToItemTip(self.objecttip)
    self:addTicketNum(self.object2,self.TicketNum )

    ---------------
    self.title = self.ui:getChildByName('title')
    

    self:updateShow()
end

function PigYearBuyBagPanel:updateShow()
    if self.bHaveTicket then
        self.object3:setVisible(false)
        self.object1:setVisible(true)
        self.object2:setVisible(true)
    else
        self.object3:setVisible(false)
        self.object1:setVisible(true)
        self.object2:setVisible(false)

        self.object1:setPositionX(self.object3SavePos.x)
    end
end

function PigYearBuyBagPanel:addTicketNum( item, num )
--    if num > 1 then
        local label = BitmapText:create( "x"..num ,"fnt/peg_year_chunjiejineng.fnt")
        label:setScale(1.5)
        label:setPosition( ccp(50+47,40-101/0.7) )
        label:setAnchorPoint(ccp(0, 0.5))
        item:addChild( label )
--    end
end

function PigYearBuyBagPanel:addBagLevelToItem( item )
    local label = BitmapText:create( self.BagLevel.."倍" ,"fnt/peg_year_chunjiejineng.fnt")
    label:setPosition( ccp(50,40) )
    label:setAnchorPoint(ccp(0.5, 0.5))
    label:setScale(0.6)
    label:setRotation( 15 )
    item:addChild( label )
end

function PigYearBuyBagPanel:addBagLevelToItemTip( item )
    local label = BitmapText:create( self.BagLevel.."倍" ,"fnt/peg_year_chunjiejineng.fnt")
    label:setPosition( ccp(50-15/0.7,40-16/0.7) )
    label:setAnchorPoint(ccp(0.5, 0.5))
    label:setScale(0.5)
    item:addChild( label )
end

function PigYearBuyBagPanel:BuyDoubleItemLogic( sucessCall )

    local function onSuccess(data)
        if self.isDisposed then return end
        
        if self.bagItem then
            table.insert(self.rewards,self.bagItem)
            PigYearLogic:addRewards({self.bagItem})
        end

        SpringFestival2019Manager.getInstance():DC( "stage", "5years_buy_cake", self.BagLevel )

--        self:onCloseBtnTapped()
        --播放送福袋动画 
        self:buyDoubleAnim()

        --隐藏其他
        self.ui:getChildByName('objecttip'):setVisible(false)
        self.ui:getChildByName('btn'):setVisible(false)
        self.ui:getChildByName('tip'):setVisible(false)
    end

    local function onFail(errorCode)
        if self.isDisposed then return end
        CommonTip:showTip(localize("网络连接失败！"))
        self:_close()
    end

    local function onProc()
		if self.isDisposed then return end
		local function startBuyLogic()
            if self.goodsId~= 0 then
                local logic = BuyLogic:create(self.goodsId, MoneyType.kGold, DcFeatureType.kActivity, DcSourceType.kLuckyBagDouble)
			    logic:getPrice()
			    logic:start(1, onSuccess, onFail, nil, self.buyDoublePrice )

                local homeScene = HomeScene:sharedInstance()
                if homeScene then
                    homeScene:checkDataChange()
                end
            else
                self:onCloseBtnTapped()
            end
		end

        local function failt()
            self:_close()
        end
		RequireNetworkAlert:callFuncWithLogged(startBuyLogic,failt)
	end


    ---检测金币是否足够
    local UsrCoin = UserManager.getInstance().user:getCash()
    local bGoldEnouth = false

    if UsrCoin >= self.buyDoublePrice then
        bGoldEnouth = true
    end

    if bGoldEnouth then
        onProc()
    else
        self:goldNotEnough()
    end
end

function PigYearBuyBagPanel:goldNotEnough()
	if _G.isLocalDevelopMode then printx(0, "PigYearBuyBagPanel:goldNotEnough") end
	local function createGoldPanel()
		if _G.isLocalDevelopMode then printx(0, "createGoldPanel") end
		local index = MarketManager:sharedInstance():getHappyCoinPageIndex()
		if index ~= 0 then
			local panel = createMarketPanel(index)
			panel:popout()
		end
	end
	local function askForGoldPanel()
		if _G.isLocalDevelopMode then printx(0, "ask for gold panel") end
		GoldlNotEnoughPanel:createWithTipOnly(createGoldPanel)
	end
	askForGoldPanel()
    self.bCanClickBtn = true
end

function PigYearBuyBagPanel:_close()
	self.allowBackKeyTap = false
	PopoutManager:sharedInstance():remove(self)
end

function PigYearBuyBagPanel:popout()
    PopoutManager:sharedInstance():add(self, false, nil, nil, nil, 200)

     --遮罩
    local wSize = CCDirector:sharedDirector():getWinSize()
    local trueMaskLayer = LayerColor:create()
    trueMaskLayer:setColor((ccc3(0, 0, 0)))
    trueMaskLayer:setOpacity(180)
    local width = wSize.width*2
    local height = wSize.height*2
    trueMaskLayer:setContentSize(CCSizeMake( width, height ))
    trueMaskLayer:setPosition(ccp(960/2-width/2,-1764/2-height/2))
	trueMaskLayer:setTouchEnabled(true, 0, true)
	local function onTouch() 
    end
    trueMaskLayer:ad(DisplayEvents.kTouchBegin, onTouch) 
    self.ui:addChildAt( trueMaskLayer, 1 )

    if not __isWildScreen then  
        if self.LevelSucessPanel and self.LevelSucessPanel.levelSuccessTopPanel and self.LevelSucessPanel.levelSuccessTopPanel.nextLevelBtnRes  then
            local oldPos = self.LevelSucessPanel.levelSuccessTopPanel.nextLevelBtnRes:getPosition()
            local worldPos = self.LevelSucessPanel.levelSuccessTopPanel.nextLevelBtnRes:getParent():convertToWorldSpace(ccp(oldPos.x,oldPos.y-110))
            local newPos = self.Buy_btn:getParent():convertToNodeSpace(ccp(worldPos.x,worldPos.y))

            self.Buy_btn:setPositionY(newPos.y)
        end
    end

    self.allowBackKeyTap = true
	self:popoutShowTransition()
end

function PigYearBuyBagPanel:popoutShowTransition( ... )
	if self.isDisposed then return end

    self.bCanClickBtn = false

    local asyncRunner = Misc.AsyncFuncRunner:create()

    if self.bHaveTicket  then
        self.object1:setScale(0.1)
        self.object2:setScale(0.1)

        asyncRunner:add(function ( done )
            --两个道具弹出
            local endNum = 0
            local function callend()
                endNum = endNum + 1

                if endNum == 2 then
                    if done then done() end
                end
            end

            for i=1, 2 do
                local array = CCArray:create()
                array:addObject( CCScaleTo:create(0.2, 1.1) )
                array:addObject( CCScaleTo:create(0.2, 1) )
                array:addObject(CCCallFunc:create(callend))
                self['object'..i]:runAction(CCSequence:create(array))
            end
        end)
    end

    asyncRunner:add(function ( done )
        self.bCanClickBtn = true
        if done then done() end
    end)

    asyncRunner:run()
end

function PigYearBuyBagPanel:buyDoubleAnim( ... )
    if self.isDisposed then return end

    local asyncRunner = Misc.AsyncFuncRunner:create()

    local yOffset =100
    self.object3:setVisible(true)
    self.object3:setScale(0.1)
    self.object3:setPositionY( self.object3SavePos.y + yOffset )


    local function object3AddLight()
        local anim = UIHelper:createArmature3('skeleton/FifthAnniversary_starBoom', 'FifthAnniversary_starBoom', 'FifthAnniversary_starBoom', 'FifthAnniversary_starBoom/starboom')
        if anim then
            self.object3:addChild(anim)
            anim:playByIndex(0)
            anim:update(0.001)
            anim:setPosition(ccp(-7/0.7,6/0.7))
        end
    end

    if self.bHaveTicket  then
        asyncRunner:add(function ( done )
            if self.isDisposed then return end

            -- 两个道具弹出
            local endNum = 0
            local function callend()
                if done then done() end
            end

            local array = CCArray:create()
            array:addObject( CCScaleTo:create(0.2, 1.1) )
            array:addObject( CCScaleTo:create(0.2, 1) )
            array:addObject( CCMoveBy:create(0.2, ccp(0,-yOffset) ) )
            array:addObject(CCCallFunc:create(callend))
            self.object3:runAction(CCSequence:create(array))

            object3AddLight()

            for i=1, 2 do
                local offsetX = 0
                if i == 1 then 
                    offsetX = -60
                else
                    offsetX = 60
                end
                local array = CCArray:create()
                array:addObject( CCMoveBy:create(0.2, ccp(offsetX,0)) )
                self['object'..i]:runAction(CCSequence:create(array))
            end
        end)
    else
        asyncRunner:add(function ( done )
            if self.isDisposed then return end

            -- 一个道具弹出
            local endNum = 0
            local function callend()
                if done then done() end
            end

            local array = CCArray:create()
            array:addObject( CCScaleTo:create(0.2, 1.1) )
            array:addObject( CCScaleTo:create(0.2, 1) )
            array:addObject( CCMoveBy:create(0.1, ccp(80,0) ) )
            array:addObject( CCMoveBy:create(0.1, ccp(0,-yOffset) ) )
            array:addObject(CCCallFunc:create(callend))
            self.object3:runAction(CCSequence:create(array))

            object3AddLight()

            local array = CCArray:create()
            array:addObject( CCMoveBy:create(0.2, ccp(-80,0)) )
            self.object1:runAction(CCSequence:create(array))
        end)
    end

    asyncRunner:add(function ( done )
        if self.isDisposed then return end

        self:showPigYearView( true )
        if done then done() end
    end)

    asyncRunner:run()
end

function PigYearBuyBagPanel:showPigYearView( bDouble )
    if self.isDisposed then return end

    --隐藏其他
    self.ui:getChildByName('objecttip'):setVisible(false)
    self.ui:getChildByName('btn'):setVisible(false)
    self.ui:getChildByName('tip'):setVisible(false)

    local LuckyBagPanel = require 'zoo.localActivity.PigYear.PigYearView'
    local p = LuckyBagPanel:create(self.style)
    p:setNewRewards( self.rewards )
--    p.closeCallback = self.closeCallback
    p:setPosition(ccp(102/0.7,-500/0.7))
    p:HideCloseBtn()
    self.ui:addChildAt( p,5 )
    self.LuckyBagPanel = p

    local itemList = {}
    if bDouble then
        if self.bHaveTicket  then
            itemList = {
                self.object1,
                self.object3,
                self.object2
            }
        else
            itemList = {
                self.object1,
                self.object3
            }
        end
    else
        if self.bHaveTicket  then
            itemList = {
                self.object1,
                self.object2
            }
        else
            itemList = {
                self.object1
            }
        end
    end

    local function endCallback()
        if self.isDisposed then return end
        self.ui:getChildByName('lightbg'):setVisible(false)
        self.ui:getChildByName('light'):setVisible(false)
        self.ui:getChildByName('title'):setVisible(false)
        self.ui:getChildByName('closeBtn'):setVisible(false)

        p:runAction( CCMoveTo:create( 0.3, ccp(102/0.7,-360/0.7) ) )

        local function NewCloseFunc()
            self:onCloseBtnTapped()
        end
        p.onCloseBtnTapped = NewCloseFunc 
        p:ShowCloseBtn()
    end

    p:ShowFlyAnim( itemList, bDouble, endCallback )
end

function PigYearBuyBagPanel:onCloseBtnTapped( ... )

    if not self.LuckyBagPanel then
        self:showPigYearView( false )
    else
        if self.closeCallback then self.closeCallback() end
        self:_close()
    end
end

function PigYearBuyBagPanel:dispose( ... )
	-- body
	BasePanel.dispose(self, ...)
end

return PigYearBuyBagPanel
