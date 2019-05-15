local UIHelper = require 'zoo.panel.UIHelper'

local RankRaceLotteryLogPanel = require 'zoo.quarterlyRankRace.view.RankRaceLotteryLogPanel'

local RankRaceRewardPanel = class(BasePanel)
_G.RankRaceRewardPanel = RankRaceRewardPanel

local rrMgr


local TurnCtrl = require 'zoo.quarterlyRankRace.view.TurnCtrl'
local BoxCtrl = require 'zoo.quarterlyRankRace.view.BoxCtrl'



function RankRaceRewardPanel:create()

	if not RankRaceMgr then
		require 'zoo.quarterlyRankRace.RankRaceMgr'
	end

	rrMgr = RankRaceMgr:getInstance()

    local panel = RankRaceRewardPanel.new()
    panel:init()
    return panel
end

function RankRaceRewardPanel:init()
	FrameLoader:loadArmature('skeleton/rank_race_reward_box', 'rank_race_reward_box', 'rank_race_reward_box')
    local ui = UIHelper:createUI('ui/RankRace/reward.json', 'n.race.rank/panel')
	BasePanel.init(self, ui)
	UIUtils:adjustUI(ui, 222, nil, nil, 1724, true)

    UIUtils:setTouchHandler(self.ui:getChildByPath('closeBtn'), function ( ... )
    	self:onCloseBtnTapped()
    end)

    self.ruleBtn = self.ui:getChildByPath('descBtn')  
    self.ruleBtn:setTouchEnabled(true, 0, false)
    self.ruleBtn:setButtonMode(true)
    self.ruleBtn:addEventListener(DisplayEvents.kTouchTap, function ()
        local panel = require('zoo.quarterlyRankRace.view.RankRaceDescPanel'):create()
		panel:popout()
		panel:turnTo(3, 0)
    end)
    local pos = self.ruleBtn:getPosition()
    self.ruleBtnOldPos = ccp( pos.x , pos.y ) 

    self.countdownTip = BitmapText:create('', 'fnt/tutorial_white.fnt')
    self.countdownTip:setAnchorPoint(ccp(0.5, 0.5))
    self.countdownTip:setScale(0.8)
    self.countdownTip:setColor(ccc3(159, 97, 49))
    self.ui:addChild(self.countdownTip)
    local tSize = self.ui:getChildByName("title"):getContentSize()
    local tPos = self.ui:getChildByName("title"):getPosition()
    local bPos = self.ui:getChildByName("descBtn"):getPosition()
    self.countdownTip:setPosition(ccp(tPos.x + tSize.width/2, bPos.y-1))


    UIUtils:setTouchHandler(self.ui:getChildByPath('rightBG'), function ( ... )
    	if self.isDisposed then return end
    	RankRaceLotteryLogPanel:create():popout()
    end)

    UIUtils:setTouchHandler(self.ui:getChildByPath('leftBG'), function ( ... )
    	-- CommonTip:showTip('todo')
    end)

    --- 赛季宝石区分
    local icon1 = self.ui:getChildByPath('leftLabel/icon')
    local icon2 = self.ui:getChildByPath('leftLabel/icon2')

    local startlabel1 = self.ui:getChildByPath('turnTable/startBtn/startlabel')
    local startlabel2 = self.ui:getChildByPath('turnTable/startBtn/startlabel2')

    icon1:setVisible(false)
    startlabel1:setVisible(false)

    self:setLeftNum(rrMgr:getData():getTC1())

    self.turnCtrl = TurnCtrl.new({
    	model = rrMgr,
    	turnHolder = self.ui:getChildByPath('turnTable'),
    })

    local costLabel = self.ui:getChildByPath('turnTable/startBtn/text')
    costLabel:setText('x' .. tostring(rrMgr:getMeta():getLotteryCost()))

    --tip
    local tip1 = self.ui:getChildByName('tip1')
    tip1:setVisible(false)

    local refresh = function ( ... )
    	self:onTick()
	end

	self.oneSecondTimer	= OneSecondTimer:create()
	self.oneSecondTimer:setOneSecondCallback(refresh)

	self:onTick()
    self:buildBoxes()
    --监听合适的事件 --并处理刷新
    rrMgr:addObserver(self)
end

function RankRaceRewardPanel:onTick( ... )
	if self.isDisposed then return end
	local time = rrMgr:getCountDownStr( false )
	self.countdownTip:setText(time)
end

function RankRaceRewardPanel:buildBoxes( ... )
	if self.isDisposed then return end

	self.boxCtrls = {}

	local contentHolder = self.ui:getChildByPath('content')

	local contentSize = (function ( ... )
		local size = contentHolder:getContentSize()
		local sx = contentHolder:getScaleX()
		local sy = contentHolder:getScaleY()
		return CCSizeMake(size.width * sx, size.height * sy)
	end)()

	local contentPos = ccp(contentHolder:getPositionX(), contentHolder:getPositionY())

    local SaijiIndex = RankRaceMgr.getInstance():getCurSaijiIndex()
    local boxes = UIHelper:createUI('ui/RankRace/reward.json', 'n.race.rank/s'..SaijiIndex..'/boxes')
    
	local scrollView = HorizontalScrollable:create(contentSize.width, contentSize.height, true, false)
	scrollView:setContent(boxes)

	self.ui:addChild(scrollView)
	scrollView:setPosition(ccp(contentPos.x, contentPos.y))

	boxes:setPositionY(-13)

	contentHolder:setVisible(false)

	local respectiveInfos = rrMgr:getBoxesRespectiveInfos()
	for i = 1, #respectiveInfos do
        
        local boxCtrl
        local boxRes

        local Dan = RankRaceMgr.getInstance():getData():getSafeDan()
        if i==7 then
            for j=7, 10 do
                --先隐藏掉
                local boxRes = boxes:getChildByPath('box' .. j)
                boxRes:setVisible(false)
            end
            
            local index = i
            local bigDan = RankRaceMgr.getInstance():getCurBigDan()

            if bigDan == 1 then
                index = 8
            elseif bigDan == 2 then
                index = 9
            elseif bigDan == 3 then
                index = 10
            end

	        boxRes = boxes:getChildByPath('box' .. index)
            boxRes:setVisible(true)
	        boxCtrl = BoxCtrl.new(boxRes, i, index)
	        boxCtrl:setCanvas(self.ui)
        else
            boxRes = boxes:getChildByPath('box' .. i)
	        boxCtrl = BoxCtrl.new(boxRes, i)
	        boxCtrl:setCanvas(self.ui)
        end

		UIUtils:setTouchHandler(boxRes, function ( ... )
			if self.isDisposed then return end
			boxCtrl:onTap()
		end, function ( worldPos )
			if self.isDisposed then return false end
			if not contentHolder:hitTestPoint(worldPos, true) then
				return false
			end
			return boxRes:hitTestPoint(worldPos, true)
		end)

		table.insert(self.boxCtrls, boxCtrl)

		boxCtrl:setGoldBoxUI(self.ui:getChildByPath('leftBG'))
	end

	local showBoxIndex = 1
	for i = 1, 6 do
		if rrMgr:getBoxRewardState(i) ~= RankRaceMgr.BoxState.kRewarded then
			showBoxIndex = i
			break
		end
	end

	if not rrMgr:getData():getSawBoxAnim() then
		rrMgr:getData():setSawBoxAnim(true)
		scrollView:scrollToRightEnd(0)
		scrollView:scrollToLeftEnd(1)
    else

    if showBoxIndex > 3 then
			scrollView:scrollToOffset(90* (showBoxIndex - 1))
		end
    end
end

function RankRaceRewardPanel:dispose( ... )
	for _, v in ipairs(self.boxCtrls) do
		v:dispose()
	end
	self.boxCtrls = {}

	self.oneSecondTimer:stop()
	self.turnCtrl:dispose()
    rrMgr:removeObserver(self)
	BasePanel.dispose(self, ...)
end

function RankRaceRewardPanel:onNotify( obKey, ...)
	if self.isDisposed then return end
	if self['_handle_' .. obKey] then
		self['_handle_' .. obKey](self, ...)
		return
	end
end

function RankRaceRewardPanel:_handle_kTargetCountChange1( ... )
	if self.isDisposed then return end
	self:setLeftNum(rrMgr:getData():getTC1())
end

function RankRaceRewardPanel:_handle_kPassDay( ... )
	if self.isDisposed then return end

	self:setLeftNum(rrMgr:getData():getTC1())
	self.turnCtrl:refresh()
	self.turnCtrl:refreshLight()
	for _, v in ipairs(self.boxCtrls or {}) do
		v:refresh()
	end

end

function RankRaceRewardPanel:setLeftNum( num )
	if self.isDisposed then return end
	local label2 = self.ui:getChildByPath('leftLabel/label2')
    local icon1 = self.ui:getChildByPath('leftLabel/icon')
    local icon2 = self.ui:getChildByPath('leftLabel/icon2')

    local scale = 0.7
	label2:setScale(scale)
	label2:setText('x' .. tostring(num))

    local offset = 0
    local AllLength = offset
    local MiddlePos = ccp(60,-20)

    AllLength = AllLength + icon2:getContentSize().width
    AllLength = AllLength + label2:getContentSize().width*scale

    icon2:setPositionX( MiddlePos.x - AllLength/2 )
    label2:setPositionX( MiddlePos.x - AllLength/2 + icon2:getContentSize().width + offset )
end

function RankRaceRewardPanel:_close()
	if self.isDisposed then return end
	self.allowBackKeyTap = false
	PopoutManager:sharedInstance():remove(self)
end

function RankRaceRewardPanel:popout()
	if self.isDisposed then return end
	PopoutManager:sharedInstance():add(self, false)
	self.allowBackKeyTap = true
	self.oneSecondTimer:start()

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


	self:playHandAnim()
end

function RankRaceRewardPanel:onCloseBtnTapped( ... )
    if self.isDisposed then return end

    if self.turnCtrl:isBlock() then
    	CommonTip:showTip(localize('rank.race.lottery.busy'))
    	return
    end

    self:_close()
end


function RankRaceRewardPanel:playHandAnim( ... )
    if self.isDisposed then return end

    if self.handLayer then
    	if not self.handLayer.isDisposed then
    		return
    	end
    end

    if not rrMgr:canDrawLottery() then
        return
    end

    local pos = ccp(480, -800)

    local hand = GameGuideAnims:handcurveSlideAnim(ccp(pos.x+100, pos.y-100), ccp(pos.x+100, pos.y-400), 100, 0)
    local layer = Layer:create()
    layer:addChild(hand)
    self.ui:addChild(layer)

    local function onTouchCurrentLayer(eventType, x, y)
        if layer and (not layer.isDisposed) then
            layer:removeFromParentAndCleanup(true)
        end
    end
    layer:registerScriptTouchHandler(onTouchCurrentLayer, false, 0, true)
    layer.refCocosObj:setTouchEnabled(true)

    self.handLayer = layer
end

return RankRaceRewardPanel
