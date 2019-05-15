
local RankRacePrePanel = class(BasePanel)

local visibleSize = CCDirector:sharedDirector():getVisibleSize()
local visibleOrigin = CCDirector:sharedDirector():getVisibleOrigin()

function RankRacePrePanel:ctor()
end

function RankRacePrePanel:init()

	RankRaceMgr:getInstance():addObserver(self)

	self.ui = self:buildInterfaceGroup("2018_s1_rank_race/PrePanel")
    BasePanel.init(self, self.ui)

    local scale = math.min(visibleSize.height / 1280, visibleSize.width / 720)
	local contentPosX = visibleOrigin.x + (visibleSize.width - 720 * scale) / 2
	local contentPosY = visibleOrigin.y + 1280 * scale
	self:setScale(scale)
	self:setPositionXY(contentPosX, 0)

    local bg = Sprite:create(SpriteUtil:getRealResourceName("ui/RankRace/prePanelBg.jpg"))
    bg:setAnchorPoint(ccp(0, 1))
    bg:setPosition(ccp(-120, 120))
    self.ui:addChildAt(bg, 0)

	self.closeBtn = self.ui:getChildByName('closeBtn')	
	self.closeBtn:setTouchEnabled(true, 0, false)
	self.closeBtn:setButtonMode(true)
	self.closeBtn:addEventListener(DisplayEvents.kTouchTap, function ()
		self:onCloseBtnTapped()
	end)

	self.ruleBtn = self.ui:getChildByName('ruleBtn')  
    self.ruleBtn:setTouchEnabled(true, 0, false)
    self.ruleBtn:setButtonMode(true)
    self.ruleBtn:addEventListener(DisplayEvents.kTouchTap, function ()
        self:onDescBtnTapped()
    end)

    self.oneSecondTimer = OneSecondTimer:create()
    self.oneSecondTimer:setOneSecondCallback(function ()
        self:onTick()
    end)
    self:onTick()

    self.tipLabel = BitmapText:create('', 'fnt/tutorial_white.fnt')
    self.tipLabel:setAnchorPoint(ccp(0, 0))
    
    self.tipLabel:setRichTextWithWidth(localize("rank.race.main.14"), 16, 'FFF29A')
    local size = self.tipLabel:getContentSize()
    self.tipLabel:setPosition(ccp((720 - size.width)/2, -(985 + size.height)))
    self.ui:addChild(self.tipLabel)

    local linkBtn = Sprite:create('materials/linkBtn.png')
    self.ui:addChild(linkBtn)

    linkBtn:setPosition(ccp(545, -1108))

    UIUtils:setTouchHandler(linkBtn, function ( ... )
        if self.isDisposed then return end

        local url = "http://fansclub.happyelements.com/fans/ff.php?cb="..HeDisplayUtil:urlEncode('http://ff.happyelements.com/mobile/page/topic.html?tid=2792055&app=1001&ct=1528273800')
        FAQ:openFAQClient(url, 1, true)
        if __WIN32 then
            CommonTip:showTip('xxxxx')
        end
    end)

end

function RankRacePrePanel:onCloseBtnTapped()
	PopoutManager:sharedInstance():remove(self, true)
	self.allowBackKeyTap = false
    if self.close_cb then self.close_cb() end
end

function RankRacePrePanel:onDescBtnTapped()
	local panel = require('zoo.quarterlyRankRace.view.RankRaceDescPanel'):create()
    panel:popout()
    panel:turnTo(1)
end

function RankRacePrePanel:onTick()
	local countdown, isOver = RankRaceMgr.getInstance():getPreheatCountdownStr()
	if not self.countdownLabel then
		self.countdownLabel = BitmapText:create('', 'fnt/steps_cd.fnt')
		self.countdownLabel:setAnchorPoint(ccp(0.5 ,0))
		self.ui:addChild(self.countdownLabel)
		self.countdownLabel:setPosition(ccp(360, -990))
	end
	self.countdownLabel:setText(countdown)
	if isOver then 
		if self.oneSecondTimer then
	        self.oneSecondTimer:stop()
	        self.oneSecondTimer = nil
	    end
	    self:onCloseBtnTapped()
	end
end

function RankRacePrePanel:popout(close_cb)
    self.close_cb = close_cb
	PopoutQueue:sharedInstance():push(self, true, false)
	self.allowBackKeyTap = true
    if self.oneSecondTimer then 
        self.oneSecondTimer:start()
    end
end

function RankRacePrePanel:onNotify( obKey, ...)
    if self.isDisposed then return end
    if self['_handle_' .. obKey] then
        self['_handle_' .. obKey](self, ...)
        return
    end
end

function RankRacePrePanel:_handle_kPassDay( ... )
    if self.isDisposed then return end
    if RankRaceMgr:getInstance():isEnabled() then
    	-- self:onCloseBtnTapped()
    end
end


function RankRacePrePanel:dispose()

	RankRaceMgr:getInstance():removeObserver(self)


	BasePanel.dispose(self)
    if self.oneSecondTimer then
        self.oneSecondTimer:stop()
        self.oneSecondTimer = nil
    end
end

function RankRacePrePanel:create()
	local panel = RankRacePrePanel.new()
	panel:loadRequiredResource("ui/RankRace/MainPanel.json")
	panel:init()
	return panel
end

return RankRacePrePanel