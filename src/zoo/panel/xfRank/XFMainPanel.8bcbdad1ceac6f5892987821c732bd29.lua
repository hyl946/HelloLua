local XFMeta = require 'zoo.panel.xfRank.XFMeta'
local XFIdCardPanel = require 'zoo.panel.xfRank.XFIdCardPanel'
local XFNoBodyPanel = require 'zoo.panel.xfRank.XFNoBodyPanel'

-- local __require = require

-- local function require( path )
-- 	package.loaded[path] = nil
-- 	return __require(path)
-- end

local ISMRR = true

local FPS = 24

local TOP_RANK_NUM = 6

local RANK_ITEM_HEIGHT = 75.7

local __black_magic_posY = {
    -- -614 - 4 + 79, -614 - 0 - RANK_ITEM_HEIGHT + 79
     -618 + 79  , -614 - 0 - RANK_ITEM_HEIGHT + 79  + 25
}

--	__black_magic_posY[2] 是上边界
local black_magic_posY = {
	__black_magic_posY[1], __black_magic_posY[2]
}


local layoutUtils =  require 'zoo.panel.happyCoinShop.utils'
local XFLogic = require 'zoo.panel.xfRank.XFLogic'

local UIHelper = require 'zoo.panel.UIHelper'

local XFMainPanel = class(BasePanel)

function XFMainPanel:create()
    local panel = XFMainPanel.new()
    panel:init()
    return panel
end

function XFMainPanel:init()

	self.scroll_view_height = 0

    local ui = UIHelper:createUI("ui/xf_panel.json", "xf/main")

    UIUtils:adjustUI(ui, 0, nil, nil, 1764, nil)

	BasePanel.init(self, ui)

	local jpgBG = Sprite:create('materials/xf_bg.jpg')
	jpgBG:setAnchorPoint(ccp(0, 0))
	ui:addChildAt(jpgBG, 0)
	jpgBG:setPosition(ccp(0, -1764 + 200 + 79 - (2000 - 1764)))

    UIUtils:setTouchHandler(self.ui:getChildByPath('closeBtn'), function()
        self:onCloseBtnTapped()
    end)

    -- self.full_star_label = self.ui:getChildByPath('full_star_label')
    -- self.full_person_label = self.ui:getChildByPath('full_person_label')

    UIHelper:setLeftText(self.ui:getChildByPath('full_star_label2'), '' .. tostring( XFLogic:getServerFullStarNum() ) , 'fnt/prop_name.fnt')
    UIHelper:setLeftText(self.ui:getChildByPath('full_person_label2'), '' .. tostring( XFLogic:getServerRankLength() ) , 'fnt/prop_name.fnt')

    self.ui:getChildByPath('full_star_label2'):setColor(hex2ccc3('9E0F55'))
    self.ui:getChildByPath('full_person_label2'):setColor(hex2ccc3('9E0F55'))
    -- self.ui:getChildByPath('full_star_label'):setString('当前满星数: ' .. XFLogic:getServerFullStarNum())
    -- self.ui:getChildByPath('full_person_label'):setString('当前满星人数: ' .. XFLogic:getServerRankLength())

    if self.ui:getChildByPath('jiaobiaonode') then
    	self.ui:getChildByPath('jiaobiaonode'):setVisible(false)
    end
    
    self.downbg = self.ui:getChildByName("downbg")
    self.downbg:removeFromParentAndCleanup(false)
    self.ui:addChildAt( self.downbg , 20 )
    self.downbg.name = "downbg"

    self.full_star_label = self.ui:getChildByName("full_star_label")
    self.full_star_label:removeFromParentAndCleanup(false)
    self.ui:addChildAt( self.full_star_label , 21 )
    self.full_star_label.name = "full_star_label"

    self.full_person_label = self.ui:getChildByName("full_person_label")
    self.full_person_label:removeFromParentAndCleanup(false)
    self.ui:addChildAt( self.full_person_label , 22 )
    self.full_person_label.name = "full_person_label"


    self.full_star_label2 = self.ui:getChildByName("full_star_label2")
    self.full_star_label2:removeFromParentAndCleanup(false)
    self.ui:addChildAt( self.full_star_label2 , 23 )
    self.full_star_label2.name = "full_star_label2"

    self.full_person_label2 = self.ui:getChildByName("full_person_label2")
    self.full_person_label2:removeFromParentAndCleanup(false)
    self.ui:addChildAt( self.full_person_label2 , 24 )
    self.full_person_label2.name = "full_person_label2"

    self.staricon = self.ui:getChildByName("staricon")
    self.staricon:removeFromParentAndCleanup(false)
    self.ui:addChildAt( self.staricon , 25 )
    self.staricon.name = "staricon"
    
    self.persionicon = self.ui:getChildByName("persionicon")
    self.persionicon:removeFromParentAndCleanup(false)
    self.ui:addChildAt( self.persionicon , 26 )
    self.persionicon.name = "persionicon"

    self.gototopbtn = self.ui:getChildByName("gototopbtn")
    self.gototopbtn:removeFromParentAndCleanup(false)
    self.ui:addChildAt( self.gototopbtn , 27 )
    self.gototopbtn.name = "gototopbtn"
    self.gototopbtn:setVisible(false)

    local function onOKTapped()
		self:scrollToTop( 0.3 )
	end
    UIUtils:setTouchHandler( self.gototopbtn , preventContinuousClick( onOKTapped , 1) )

    local rankData = XFLogic:getRankData()
    local frameIds = {
		HeadFrameType.kXFRank_1,
		HeadFrameType.kXFRank_2,
		HeadFrameType.kXFRank_2,
		HeadFrameType.kXFRank_3,
		HeadFrameType.kXFRank_3,
		HeadFrameType.kXFRank_3,
	}

    for i = 1, TOP_RANK_NUM do
    	self:buildLadderRankings(i, rankData[i], frameIds[i])
    end

    self.rankData = rankData
    self.maskLayer = LayerColor:create()
    self.maskLayer.name = 'maskLayer'
    self.maskLayer:changeWidthAndHeight(960, 1764 + 200)
    self.maskLayer:setColor(ccc3(0, 0, 0))
    self.maskLayer:setOpacity(150)
    self.maskLayer:ignoreAnchorPointForPosition(false)
    self.maskLayer:setAnchorPoint(ccp(0, 1))
    self.maskLayer:setPositionY(200)
    self.ui:addChildAt( self.maskLayer, 0)
 
	self.lockMode = true

    local blockLayer = Layer:create()
    self:addChild(blockLayer)

    UIUtils:setTouchHandler(blockLayer, function ( ... )
    	-- body
    end, function ( ... )
    	return self.blocking
    end)

end

function XFMainPanel:setBlockMode( b )
	self.blocking = b
end

function XFMainPanel:buildLadderRankings( index, xfData, frameId)
	if self.isDisposed then return end

	local pNode = self.ui:getChildByPath('食物链顶端')

	local headHolder = self.ui:getChildByPath('食物链顶端/' .. index)
	local descUI = self.ui:getChildByPath('食物链顶端/desc_' .. index)

    UIHelper:loadUserHeadIcon(headHolder, xfData.profile, true, frameId)



    UIHelper:setUserName(descUI:getChildByPath('name'), xfData.profile.name)

    -- UIHelper:setLeftText(descUI:getChildByPath('num'), '' .. tostring(XFLogic:getDefaultScore(xfData.fullstar_rank) or 0), 'fnt/prop_name.fnt')
    if descUI:getChildByPath('num') then
    	local timeleft = xfData.fullstar_ts - XFLogic:getServerStartTime() 
    	timeleft = timeleft / 1000
    	-- if _G.isLocalDevelopMode then printx(100, "timeleft = " , timeleft ) end
    	local strTime = getTimeFormatString( timeleft <= 0 and 0 or timeleft , 1)
    	descUI:getChildByPath('num'):setString( strTime )
    end
    -- UIHelper:setLeftText(descUI:getChildByPath('num'), '' .. tostring(XFLogic:getDefaultScore(xfData.fullstar_rank) or 0), 'fnt/piggybank.fnt')

    UIUtils:setTouchHandler(headHolder, function ( 	 )
    	self:onTapRankItem(xfData)
    end)

    UIUtils:setTouchHandler(descUI, function ( 	 )
    	self:onTapRankItem(xfData)
    end)

    local jiaobiaoUI = UIHelper:createUI("ui/xf_panel.json", "xf/jiaobiaoyuanjian")
    if jiaobiaoUI then
    	for i=1,6 do
    		if jiaobiaoUI:getChildByName("num"..i) then
    			jiaobiaoUI:getChildByName("num"..i):setVisible( i ==  index )
    		end
    	end
    	-- if _G.isLocalDevelopMode then printx(100, "buildLadderRankings index = " , index ) end
    	pNode:addChild( jiaobiaoUI )
    	jiaobiaoUI:setPositionX( headHolder:getPositionX() - 18 )
    	if index <= 3 then
    		jiaobiaoUI:setPositionY( headHolder:getPositionY() - 48 )
    	else
    		jiaobiaoUI:setPositionY( headHolder:getPositionY() - 40 )
    	end
    	

    	-- jiaobiaoUI:setScale(0.1)
    end

end

function XFMainPanel:onButtonTap( buttonName )
	if buttonName  == 'descBtn' then
		require('zoo.panel.xfRank.XFDescPanel'):create():popout()
	end
end

function XFMainPanel:_close()
	self.allowBackKeyTap = false
	PopoutManager:sharedInstance():remove(self)
end

function XFMainPanel:popout()
	local new_scene_mode = true
	if new_scene_mode then
		local scene = Scene:create()
		Director:sharedDirector():pushScene(scene)
		scene.name = 'Scene[XFMainPanel]'

		local panel = self
        panel:ad(PopoutEvents.kRemoveOnce, function ( ... )
        	local scene = Director:sharedDirector():getRunningScene()
        	if scene and scene.name == 'Scene[XFMainPanel]' then
        		Director:sharedDirector():popScene()
        	end
        end)
    end

	self.name = 'XFMainPanel'
	PopoutManager:sharedInstance():add(self, true)
	self:popoutShowTransition()
	
end

function XFMainPanel:onCloseBtnTapped( ... )
    self:_close()
end

function XFMainPanel:onKeyBackClicked( ... )
	if self.isDisposed then return end
	if self.blocking then return end
	BasePanel.onKeyBackClicked(self, ...)
end

function XFMainPanel:createStarAnim( ... )
	if self.isDisposed then return end
	local anim = UIHelper:createArmature2('skeleton/xf_anim', 'xf.anim/star')
	self.ui:addChild(anim)
	anim:setPosition(ccp(410, -160))
	anim:playByIndex(0, 0)
	self.starAnim = anim
end

function XFMainPanel:popoutShowTransition( ... )
	if self.isDisposed then return end

	self.allowBackKeyTap = true

	self:createRankList(self.rankData, TOP_RANK_NUM + 1, #self.rankData)

    self.rankView:setScrollEnabled(false)

	self.myXfData = table.find(self.rankData, function ( v )
		return tostring(v.profile.uid) == tostring(UserManager:getInstance():getInviteCode())
	end)

	self:createFloatMe(self.myXfData)

	if XFLogic:isEmptyRankData(self.rankData) and (not __WIN32) then
		local noBodyPanel = XFNoBodyPanel:create()
		noBodyPanel:ad(PopoutEvents.kRemoveOnce, function ( ... )
			if self.isDisposed then return end
			self:onCloseBtnTapped()
		end)
		noBodyPanel:popout()
	else
		self:createStarAnim()
	end

	local Misc = require('zoo.quarterlyRankRace.utils.Misc')
    local asyncRunner = Misc.AsyncFuncRunner.new()
    asyncRunner:add(function ( done )
    	if self.isDisposed then return end
		self:playPassAnim(self.myXfData, function ( ... )

    		self.rankView:setScrollEnabled(true)

    		if XFLogic:isValidRank(self.myXfData.fullstar_rank or 0) and self.myXfData.fullstar_rank <= XFMeta.RANK_SHOW_SIZE then
				self:scrollSbToCenter(self.myXfData, 0)
    		end

			if done then done() end
		end)
    end)
    asyncRunner:add(function ( done )
    	if self.isDisposed then return end

    	local historyInfo = XFLogic:hadAvailableRewards()
    	if historyInfo then
    		XFLogic:receiveRewards(historyInfo, function ( rewards )
    			local XFRewardsPanel = require 'zoo.panel.xfRank.XFRewardsPanel'
    			XFRewardsPanel:create(rewards or {}, historyInfo):popout()
    		end)
    	end

    	if done then done() end

    end)
    asyncRunner:run()

    XFLogic:showedLFLAlert()
end

function XFMainPanel:createFloatMe( xfData )
	local rankUI = UIHelper:createUI("ui/xf_panel.json", "xf/wrapper")

	rankUI = UIHelper:replaceLayer2LayerColor(rankUI)
	UIHelper:setCascadeOpacityEnabled(rankUI)

	rankUI:setPositionX(118)
	rankUI:setPositionY(1000)

	UIUtils:setTouchHandler(rankUI, function ( 	 )
    	self:onTapRankItem(xfData)
    end)

	local rankUIScaleLayer = rankUI:getChildByPath('content')
	local rankUIContentLayer = rankUIScaleLayer:getChildByPath('content')


    self.floatMeUI = rankUI
    self.floatMeUI.name = 'floatMeUI'
    self.floatMeUI.rankUIScaleLayer = rankUIScaleLayer
    self.floatMeUI.rankUIContentLayer = rankUIContentLayer

    UIHelper:move(self.floatMeUI.rankUIContentLayer:getChildByPath('score'), 13, -4)
	UIHelper:move(self.floatMeUI.rankUIContentLayer:getChildByPath('icon'), 13, 0)

	local deltaX = - 13
	UIHelper:move(self.floatMeUI.rankUIContentLayer:getChildByPath('icon'), deltaX,  0)
	UIHelper:move(self.floatMeUI.rankUIContentLayer:getChildByPath('score'), deltaX,  0)
	UIHelper:move(self.floatMeUI.rankUIContentLayer:getChildByPath('arrow'), deltaX,  0)
	UIHelper:move(self.floatMeUI.rankUIContentLayer:getChildByPath('label'), deltaX,  0)
	UIHelper:move(self.floatMeUI.rankUIContentLayer:getChildByPath('line'), deltaX,  0)


	self:buildRankItem(self.floatMeUI.rankUIContentLayer, xfData , true)

	-- local duration = 1/48
	-- local lastUpdateTime = 0
	-- local now = 0

    self.floatMeUI:scheduleUpdateWithPriority(function ( ... )

    	-- now = Localhost:timeInSec()
    	-- if now - lastUpdateTime > duration then
        	self:refreshFloatUIPos()
        	-- lastUpdateTime = now
        -- end
    end, 0)
   
	-- local scheduleScriptFuncID
	-- local time = 1/32
	-- local function onScheduleScriptFunc()
	-- 	self:refreshFloatUIPos()
	-- end
	-- scheduleScriptFuncID = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(onScheduleScriptFunc,time,false)
	-- self.scheduleScriptFuncID = scheduleScriptFuncID


    self.ui:addChild(self.floatMeUI)
    self.floatMeUI.rankUIContentLayer:getChildByPath('light'):setVisible(false)
    self:refreshFloatUIVisible()

end

function XFMainPanel:refreshFloatUIVisible( ... )
	if self.isDisposed then return end
	if not self.floatMeUI then return end
    self.floatMeUI:setVisible(self.myXfData.fullstar_rank >= TOP_RANK_NUM + 1)
end

function XFMainPanel:setFloatMeStyle(style, anim, callback)
	if self.isDisposed then return end
	if not self.floatMeUI then return end

	if not self.floatMeStyle then
		self.floatMeStyle = 'style1'
	end

	if self.floatMeStyle ~= style then

		self.floatMeStyle = style

		if style == 'style1' then
			if not anim then
				self.floatMeUI.rankUIContentLayer:getChildByPath('light'):setVisible(false)
				self.floatMeUI.rankUIScaleLayer:setScale(1)
				if callback then callback() end
				return
			else
				self.floatMeUI.rankUIContentLayer:getChildByPath('light'):setVisible(false)
				local array = CCArray:create()
				array:addObject(CCScaleTo:create(6/FPS, 1, 1))
				array:addObject(CCCallFunc:create(callback))
				local scaleAction = CCSequence:create(array)
				local pos = self:_refreshFloatUIPos()
				local moveAction = CCMoveTo:create(6/FPS, ccp(pos.x, pos.y))
				self.floatMeUI.rankUIScaleLayer:runAction(scaleAction)
				self.floatMeUI:runAction(moveAction)
				return
			end
		elseif style == 'style2' then
			self.floatMeUI.rankUIContentLayer:getChildByPath('light'):setVisible(true)
			if not anim then
				self.floatMeUI.rankUIScaleLayer:setScale(1.3)
				if callback then callback() end
				return
			else
				local array = CCArray:create()
				array:addObject(CCScaleTo:create(6/FPS, 1.21, 1.21))
				array:addObject(CCScaleTo:create(3/FPS, 1.11, 1.11))
				array:addObject(CCCallFunc:create(callback))
				local scaleAction = CCSequence:create(array)
				local moveAction = CCMoveBy:create(6/FPS, ccp(0, RANK_ITEM_HEIGHT/2))
				self.floatMeUI.rankUIScaleLayer:runAction(scaleAction)
				self.floatMeUI:runAction(moveAction)
				return
			end
		end
	end


	if callback then callback() end
 	
end


function XFMainPanel:refreshFloatUIPos( ... )
	if self.isDisposed then return end
	if not self.lockMode then return end

	local pos2 = self:_refreshFloatUIPos()
	if pos2 then
        self.floatMeUI:setPosition(pos2)
	end
end

function XFMainPanel:_refreshFloatUIPos( ... )
	if self.isDisposed then return end
	if self.followedRankUI and (not self.followedRankUI.isDisposed ) and self.followedRankUI:getParent() and self.followedRankUI:getParent():getParent() then
		local pos = self.followedRankUI:getGroupBounds().origin
        local pos = self.ui:convertToNodeSpace(pos)
        local py = math.clamp(pos.y, black_magic_posY[1], black_magic_posY[2])
        local pos2 = ccp(pos.x, py + RANK_ITEM_HEIGHT)
        return pos2
    elseif self.mySelfRankUI and (not self.mySelfRankUI.isDisposed ) and self.mySelfRankUI:getParent() and self.mySelfRankUI:getParent():getParent() then
        local pos = self.mySelfRankUI:getGroupBounds().origin
        local pos = self.ui:convertToNodeSpace(pos)
        local py = math.clamp(pos.y, black_magic_posY[1], black_magic_posY[2])
        local pos2 = ccp(pos.x, py + RANK_ITEM_HEIGHT)
        return pos2
    elseif self.lastBuiltRank then
    	local pos2 = self.floatMeUI:getGroupBounds().origin
        pos2 = self.ui:convertToNodeSpace(pos2)
    	if self.myXfData.fullstar_rank > self.lastBuiltRank then
    		pos2 = ccp(pos2.x, black_magic_posY[1] + RANK_ITEM_HEIGHT)
    	elseif self.myXfData.fullstar_rank < self.lastBuiltRank then
    		pos2 = ccp(pos2.x, black_magic_posY[2] + RANK_ITEM_HEIGHT)
    	end
        return pos2
    end

end

function XFMainPanel:dispose( ... )


	if self.floatMeUI and (not self.floatMeUI.isDisposed) then
        self.floatMeUI:unscheduleUpdate()
    end

    
	-- CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.scheduleScriptFuncID)

	BasePanel.dispose(self, ...)

	local textureTable = {
        "materials/xf_bg.jpg",
    }
    for i,v in ipairs(textureTable) do
        CCTextureCache:sharedTextureCache():removeTextureForKey(
            CCFileUtils:sharedFileUtils():fullPathForFilename(
                SpriteUtil:getRealResourceName(v)
            )
        )
    end

    if XFLogic:needShowPreheatButton() then
    	if not XFLogic:isPreheadEnabled() then
    		XFLogic.needHideAnim = true
    	end
    end

    if self.myXfData.fullstar_rank > 0 and self.myXfData.fullstar_rank <= XFMeta.RANK_SHOW_SIZE then
    	local headUrl = PersonalCenterManager:getData(PersonalCenterManager.HEAD_URL)
    	local name = PersonalCenterManager:getData(PersonalCenterManager.NAME)
    	if name == '消消乐玩家' or (not string.starts(headUrl, 'http')) then
    		XFLogic.needShowPersonalInfoPanel = true
    	end
    end

	for _i, _v in ipairs(self.viewsPools or {}) do
		if not _v.isDisposed then
			_v:dispose()
		end
	end

end

function XFMainPanel:showGoToTopBtn(  )


end


function XFMainPanel:createRankList( rankData, startIndex, endIndex )
	if self.isDisposed then return end
	
	local showWidth = 720

	local visibleOrigin	= CCDirector:sharedDirector():getVisibleOrigin()
	visibleOrigin = self.ui:convertToNodeSpace(ccp(visibleOrigin.x, visibleOrigin.y))

	local rankTopPH = self.ui:getChildByPath('rankTopPH')
	rankTopPH:setVisible(false)

	local showHeight = rankTopPH:getPositionY() - visibleOrigin.y - RANK_ITEM_HEIGHT

	black_magic_posY[1] = __black_magic_posY[1] - showHeight

	self.scroll_view_height = showHeight

	self.rankView = VerticalScrollable:create(showWidth, showHeight, true, nil, 2/60)

	self.downbg :setPositionY( rankTopPH:getPositionY() - showHeight - 25 )



	self.full_star_label:setPositionY( rankTopPH:getPositionY() - showHeight - 26 )
	self.full_person_label:setPositionY( rankTopPH:getPositionY() - showHeight - 26 )

    self.full_star_label2:setPositionY( rankTopPH:getPositionY() - showHeight - 26 )
    self.full_person_label2:setPositionY( rankTopPH:getPositionY() - showHeight - 26 )

	self.persionicon:setPositionY( rankTopPH:getPositionY() - showHeight - 33 )
	self.staricon:setPositionY( rankTopPH:getPositionY() - showHeight - 32 )

	self.gototopbtn:setPositionY( rankTopPH:getPositionY() - showHeight + RANK_ITEM_HEIGHT * 2 + 20  )

	function self.rankView:scrollToTop(duration, quickStopMode)
		if self.content and self.content.__layout then
			self.content:__layout()
		end
	    self:stopSlide()
	    if self.startScrollCallback then self.startScrollCallback() end

	    self:__moveTo(self.bottomMostOffset, duration or 0.3, quickStopMode)
	end

	function self.rankView:__moveTo( Y_Position, duration, quickStopMode )
		if not duration then
			duration = 0
		end

		local dY = Y_Position - self.yOffset

		if duration == 0 then 
			self.container:setPositionY(Y_Position)
			self:updateContentViewArea()
		else
			self:onStartMoving()

			local moveAction
			if quickStopMode then
				moveAction = CCSequence:createWithTwoActions(
			                    CCEaseExponentialIn:create(CCMoveTo:create(duration, ccp(0, Y_Position))), 		--CCEaseExponentialOut  CCEaseSineOut
			                    CCCallFunc:create(function() self:onEndMoving() end)
			                    )
			else
				moveAction = CCSequence:createWithTwoActions(
			                    CCEaseExponentialInOut:create(CCMoveTo:create(duration, ccp(0, Y_Position))), 		--CCEaseExponentialOut  CCEaseSineOut
			                    CCCallFunc:create(function() self:onEndMoving() end)
			                    )
			end

			self.container:runAction(moveAction)
		end

		self.yOffset = Y_Position
	end

    self.rankView.name = "list"
    self.rankView:setIgnoreHorizontalMove(false)
	self.rankView:ignoreAnchorPointForPosition(false)
	self.rankView:setAnchorPoint(ccp(0,1))
    self.rankView:setPosition(ccp(0, 0))
    self.ui:addChild(self.rankView)
    self.rankView:setPosition(ccp(120, rankTopPH:getPositionY()))

    local context = self

	local LayoutRender = class(DynamicLoadLayoutRender)
	function LayoutRender:getColumnNum()
		return 1
	end

	function LayoutRender:getPreloadRow()
		return 4
	end

	function LayoutRender:getItemSize()
		return CCSizeMake(720, RANK_ITEM_HEIGHT)
	end
	function LayoutRender:getVisibleHeight()
		return showWidth
	end
	function LayoutRender:buildItemView(itemData, index)
		local item = nil
		item = context:createRankItem(itemData)
		item:setParentView(context.rankView)
		return item
	end

	function LayoutRender:onItemViewDidAdd(itemView, itemData)

	end
--	gototopbtn
	local rankLayout = DynamicLoadLayout:create(LayoutRender.new())
	rankLayout.isMRR = ISMRR
  	rankLayout:setPosition(ccp(0, 0))

    self.rankView:setContent( rankLayout )
    self.rankLayout = rankLayout

    self.rankLayout.updateViewArea = function ( _, top, bottom )
  		self.rankLayout:onLayoutPositionChanged(top)
    	if top >= RANK_ITEM_HEIGHT * 8 then
    		--按钮显示
    		self.gototopbtn:setVisible(true)
    	--	self:scrollToTop( 0.3 )
    	else
    		--按钮隐藏
    		self.gototopbtn:setVisible(false)

    	end

	end

    local copyData = {}

    for i = startIndex, endIndex do
    	table.insert(copyData, rankData[i])
   	end

    self.rankLayout:initWithDatas(copyData)

    self.rankView:updateScrollableHeight()

end

function XFMainPanel:createRankItem( data )

	if ISMRR then
		if not self.viewsPools then
			self.viewsPools = {}
		end
	end

	local xfData = data.data

    local rankUI
    local item

    if ISMRR then
		for _i, _v in ipairs(self.viewsPools) do
			if not _v:getParent() then
				item = _v
				rankUI = item:getContent() 
				break
			end
		end
	end

	if item then

		if self.mySelfRankUI == rankUI then
			self.mySelfRankUI = nil
			rankUI:setVisible(true)
		end

		if self.followedRankUI == rankUI then
			self.followedRankUI = nil
			rankUI:setVisible(true)
		end

	else
		rankUI = UIHelper:createUI("ui/xf_panel.json", "xf/rank_2")

		local deltaX = -13

		UIHelper:move(rankUI:getChildByPath('score'), 13, -4)
    	UIHelper:move(rankUI:getChildByPath('icon'), 13,  0)

    	UIHelper:move(rankUI:getChildByPath('icon'), deltaX,  0)
    	UIHelper:move(rankUI:getChildByPath('score'), deltaX,  0)
    	UIHelper:move(rankUI:getChildByPath('arrow'), deltaX,  0)
    	UIHelper:move(rankUI:getChildByPath('label'), deltaX,  0)
    	UIHelper:move(rankUI:getChildByPath('line'), deltaX,  0)

		item = ItemInClippingNode:create()
    	item:setContent(rankUI)


    	if ISMRR then
			table.insert(self.viewsPools, item)
		end
	end

    if tostring(UserManager:getInstance():getInviteCode()) == tostring(xfData.profile.uid) then
    	self.mySelfRankUI = rankUI
		rankUI:setVisible(not self.__hide_my_rank_item)
    end


    UIUtils:setTouchHandler(rankUI, function ( 	 )
    	self:onTapRankItem(xfData)
    end)

    self:buildRankItem(rankUI, xfData)
    

    self.lastBuiltRank = xfData.fullstar_rank

    return item

end




function XFMainPanel:onTapRankItem( xfData )
	if self.isDisposed then return end

	if XFLogic:isUnknownData(xfData) then
		CommonTip:showTip('当前位置无人上榜')
		return
	end

	XFLogic:beforePopoutIdCard(xfData, function ( ... )
		if self.isDisposed then return end

		local newestXFData = XFLogic:getXFDataByInviteCode(xfData.profile.uid)
		XFIdCardPanel:create(newestXFData or xfData):popout()	
	end)

end

function XFMainPanel:formatRankStr( xfData )

	local rank = xfData.fullstar_rank

	if rank <= XFMeta.RANK_SIZE then
		return tostring(rank)
	else
		if self:isMe(xfData) then
			local totalStar = 0
			local userRef = UserManager:getInstance().user
			if userRef then
				totalStar = userRef:getTotalStar()
			end
			if totalStar < UserManager:getInstance():getCurRoundFullStar() then
				return '未上榜'
			end
		end
		return string.format('%d+', XFMeta.RANK_SIZE)
	end
end


function XFMainPanel:buildRankItem( rankUI, xfData ,isMe)
	if not isMe then
		isMe = false
	end
	-- body
	UIHelper:setCenterText(rankUI:getChildByPath('rank'), self:formatRankStr(xfData), 'fnt/hud.fnt')
    UIHelper:loadUserHeadIcon(rankUI:getChildByPath('holder'), xfData.profile, true)
    if isMe then
    	UIHelper:setUserName(rankUI:getChildByPath('name'), "我")
    	rankUI:getChildByPath('timeLeftTitle'):setString("用时:")
    else
    	UIHelper:setUserName(rankUI:getChildByPath('name'), xfData.profile.name)
    end
    
--  UIHelper:setLeftText(rankUI:getChildByPath('score'), tostring(XFLogic:getDefaultScore(xfData.fullstar_rank) ) )
--  UIHelper:setLeftText(rankUI:getChildByPath('score'), tostring(XFLogic:getDefaultScore(xfData.fullstar_rank)), 'fnt/autumn2017.fnt')
    
-- 	UIHelper:setLeftText( rankUI:getChildByPath('timeleft'), "10:11:12"  )
	local timeleft = xfData.fullstar_ts - XFLogic:getServerStartTime() 
    timeleft = timeleft / 1000
    if rankUI:getChildByPath('timeleft') then
    	-- if _G.isLocalDevelopMode then printx(100, "timeleft = " , timeleft ) end
    	local strTime = getTimeFormatString( timeleft <= 0 and 0 or timeleft , 1)
    	if timeleft <= 0 then
    		strTime = "--:--:--"
    		if isMe then
    			rankUI:getChildByPath('timeleft'):setVisible( true )
    			if rankUI:getChildByPath('clock') then
		    		rankUI:getChildByPath('clock'):setVisible( true )
		    	end
    		end
    	end
    	rankUI:getChildByPath('timeleft'):setColor(hex2ccc3('9A3401'))
    	local fntFile = "fnt/mark_tip_white.fnt"
    	UIHelper:setLeftText( rankUI:getChildByPath('timeleft'), strTime , fntFile )
    --	rankUI:getChildByPath('timeleft'):setString( strTime )
    end

    if  timeleft <= 0 and not isMe then
    	if rankUI:getChildByPath('clock') then
    		rankUI:getChildByPath('clock'):setVisible( false )
    	end
    	if rankUI:getChildByPath('timeleft') then
    		rankUI:getChildByPath('timeleft'):setVisible( false )
    	end
    elseif timeleft > 0 and not isMe then
    	if rankUI:getChildByPath('clock') then
    		rankUI:getChildByPath('clock'):setVisible( true )
    	end
    	if rankUI:getChildByPath('timeleft') then
    		rankUI:getChildByPath('timeleft'):setVisible( true )
    	end
    end

    local arrow = rankUI:getChildByPath('arrow')
    local line = rankUI:getChildByPath('line')
    local need_show_arrow = false
    local up_rank = 0

    if xfData.fullstar_last_rank > 0 then
    	up_rank = xfData.fullstar_last_rank - xfData.fullstar_rank
    	if math.abs(up_rank) > 0.1 then
	    	need_show_arrow = true
    	end
    end

    if not XFLogic:isValidRank(xfData.fullstar_rank) then
    	need_show_arrow = false
    end

	line:setVisible(true)

	local function flipY( b )
		if self.isDisposed then return end
		if arrow.isDisposed then return end
		arrow:getChildByPath('down'):setVisible(not b)
		arrow:getChildByPath('up'):setVisible(b)
	end
	flipY(false)

	
	UIHelper:setCenterText(rankUI:getChildByPath('label'), tostring('') ,'fnt/tutorial_white.fnt')

    if need_show_arrow then

    	line:setVisible(false)
    	if up_rank > 0 then
    		flipY(true)
    	else
    	end

    	local up_label = UIHelper:setCenterText(rankUI:getChildByPath('label'), tostring(math.abs(up_rank)) ,'fnt/tutorial_white.fnt')

    	if up_rank > 0 then
    		up_label:setColor(hex2ccc3('ED7867'))
    	else
    		up_label:setColor(hex2ccc3('80A806'))
    	end


    	local function align( node1, node2 )
    		node2:setPositionX(node1:getPositionX() + node1:getGroupBounds(rankUI).size.width)
    	end

    	align(arrow, rankUI:getChildByPath('label'))

    	arrow:setVisible(true)

    else
    	arrow:setVisible(false)
    end


    if UserManager:getInstance():getCurRoundFullStar() <= 5555 then
    	line:setVisible(false)
    end

end

function XFMainPanel:findRankItem( xfData, force )
	if self.isDisposed then return nil, 1 end
	if not self.rankLayout then return nil, 2 end
	if force then
		self:scrollSbToCenter(xfData)
	end

	local item = self.rankLayout:getItemView(xfData.fullstar_rank - TOP_RANK_NUM)
	if item then
		return item:getContent()
	end

	return nil, 3
end

function XFMainPanel:scrollSbToCenter( xfData, duration, callback)
	if self.isDisposed then return end
	local rank = xfData.fullstar_rank
	if rank <= TOP_RANK_NUM then
		return
	end
	duration = duration or 0

	local numPerPage = math.floor(self.scroll_view_height / RANK_ITEM_HEIGHT)
	local offsetNum = xfData.fullstar_rank - TOP_RANK_NUM - 1 - math.floor(numPerPage / 2)
	offsetNum = math.clamp(offsetNum, 0, XFMeta.RANK_SHOW_SIZE)
	self.rankView:gotoPositionY(RANK_ITEM_HEIGHT * offsetNum, duration)
	local action = CCSequence:createWithTwoActions(CCDelayTime:create(duration), CCCallFunc:create(function ( ... )
		if self.isDisposed then return end
		self.rankView:gotoPositionY(RANK_ITEM_HEIGHT * offsetNum, 0)
		if callback then callback() end
	end))
	action:setTag(50719)
	self:runAction(action)
end

function XFMainPanel:scrollToTop( duration, callback, quickStopMode )
	if self.isDisposed then return end
	duration = duration or 0

	self.rankView:scrollToTop(duration, quickStopMode)
	local action = CCSequence:createWithTwoActions(CCDelayTime:create(duration), CCCallFunc:create(function ( ... )
		if self.isDisposed then return end
		self.rankView:gotoPositionY(0, 0)
		if callback then callback() end
	end))
	action:setTag(50719)
	self:runAction(action)

end

function XFMainPanel:showMyRankItem( ... )
	if self.isDisposed then return end
	local myRankItem = self:findRankItem(self.myXfData)
	if myRankItem then
		myRankItem:setVisible(true)
	end
	self.__hide_my_rank_item = false


	local frameIds = {
		HeadFrameType.kXFRank_1,
		HeadFrameType.kXFRank_2,
		HeadFrameType.kXFRank_2,
		HeadFrameType.kXFRank_3,
		HeadFrameType.kXFRank_3,
		HeadFrameType.kXFRank_3,
	}

	for i = 1, TOP_RANK_NUM do
		if self:isMe(self.rankData[i]) then
			self:buildLadderRankings(i, self.rankData[i], frameIds[i])
			break
		end
	end

end

function XFMainPanel:isMe( xfData )
	return tostring(xfData.profile.uid) == tostring(UserManager:getInstance():getInviteCode())
end

function XFMainPanel:hideMyRankItem( ... )
	if self.isDisposed then return end
	local myRankItem = self:findRankItem(self.myXfData)
	if myRankItem then
		myRankItem:setVisible(false)
	end
	self.__hide_my_rank_item = true


	local frameIds = {
		HeadFrameType.kXFRank_1,
		HeadFrameType.kXFRank_2,
		HeadFrameType.kXFRank_2,
		HeadFrameType.kXFRank_3,
		HeadFrameType.kXFRank_3,
		HeadFrameType.kXFRank_3,
	}

	for i = 1, TOP_RANK_NUM do
		if self:isMe(self.rankData[i]) then
			self:buildLadderRankings(i, XFLogic:getEmptyData(), frameIds[i])
			break
		end
	end
end

function XFMainPanel:playPassAnim( xfData, onFinish )

	local function __finish( ... )
		if onFinish then onFinish() end
	end

	if xfData.fullstar_last_rank <= 0 then
		return __finish()
	end

	if xfData.fullstar_last_rank <= xfData.fullstar_rank then
		return __finish()
	end

	local key = 'playPassAnim' .. tostring(xfData.fullstar_last_rank) .. ',' .. tostring(xfData.fullstar_rank).. ',' .. tostring(xfData.fullstar_ts)

	if XFLogic:readCache(key) == true and (not __WIN32) then
		return __finish()
	end

	XFLogic:writeCache(key, true)


	if xfData.fullstar_last_rank > TOP_RANK_NUM then

		local function _findStartXfData( ... )
			local index = math.clamp(xfData.fullstar_last_rank, 1, #self.rankData)
			return self.rankData[index]
		end

		local start_xfData = _findStartXfData()
		local start_item, errCode = self:findRankItem(start_xfData, true)

		self:hideMyRankItem()

		local r1 = UIHelper:moveToTop(self.ui, {'maskLayer', 'floatMeUI'})


		self.followedRankUI = start_item
		self.lockMode = false
		local pos2 = self:_refreshFloatUIPos()
		self.floatMeUI:setPosition(pos2)
		self.floatMeUI:setVisible(true)

		self:setFloatMeStyle('style2', true, function ( ... )
			if self.isDisposed then return end

			if xfData.fullstar_rank > TOP_RANK_NUM then

				local delta = xfData.fullstar_last_rank - xfData.fullstar_rank
				local scrollDuration = math.min(2, delta * 1)

				self:scrollSbToCenter(xfData, scrollDuration, function ( ... )
					if self.isDisposed then return end

					self.followedRankUI = nil

					self:setFloatMeStyle('style1', true, function ( ... )
						if self.isDisposed then return end
						self.lockMode = true
						self:showMyRankItem()
						r1()
						self:refreshFloatUIVisible()
					end)

					__finish()

				end, true)
			else

				local delta = xfData.fullstar_last_rank - TOP_RANK_NUM - 1
				local scrollDuration = math.min(2, delta * 1)

				self:scrollToTop(scrollDuration, function ( ... )
					if self.isDisposed then return end

					local function flyToTop( ... )
						if self.isDisposed then return end

						r1()

						local EndPos = self:getTopRankPos(xfData.fullstar_rank)

						local parent = self.floatMeUI:getParent()

						EndPos = parent:convertToNodeSpace(EndPos)

						local finalScale = 1

						local EndPosAdjust = ccp(EndPos.x - (360 - (360 - 156) * finalScale) , EndPos.y + (75.7/2))

						local startPos = self.floatMeUI:getPosition()

						local p2 = ccp(0, 0)

						-- local bezierConfig = ccBezierConfig:new()
				        -- bezierConfig.controlPoint_1 = ccp(startPos.x +  p2.x, startPos.y +  p2.y)
			            -- bezierConfig.controlPoint_2 = ccp(startPos.x +  p2.x, startPos.y +  p2.y)
			            -- bezierConfig.endPosition = ccp(EndPosAdjust.x,EndPosAdjust.y)

			            local array1 = CCArray:create()
			            array1:addObject(CCMoveTo:create(5 / FPS, EndPosAdjust))
			            -- array1:addObject(CCBezierTo:create(10 / FPS, bezierConfig))
			            array1:addObject(CCCallFunc:create(function ( ... )
			            	if self.isDisposed then return end
			            	local anim = UIHelper:createArmature2('skeleton/xf_anim', 'xf.anim/show')
				            parent:addChild(anim)
				            anim:setPosition(EndPos)
				            anim:playByIndex(0, 1)
				            anim:addEventListener(ArmatureEvents.COMPLETE, function ( ... )
				            	if self.isDisposed then return end
				            	if anim.isDisposed then return end
				            	-- body
				            	anim:removeFromParentAndCleanup(true)
				            end)

				            self:playTopRankScaleAnim(xfData.fullstar_rank)

				            -- self.floatMeUI:setVisible(false)
				            
				            self.floatMeUI.rankUIScaleLayer:setScale(1)

				            for _, v in ipairs(self.floatMeUI.rankUIContentLayer:getChildrenList()) do
				            	if v.name ~= 'holder' then
				            		v:setOpacity(255)
				            	end
				            end


				            self:setFloatMeStyle('style1', false, function ( ... )
								if self.isDisposed then return end
								self.followedRankUI = nil
								self.lockMode = true
								self:showMyRankItem()
								self:refreshFloatUIVisible()
							end)

				            __finish()

			            end))
			            self.floatMeUI:runAction(CCSequence:create(array1))

			            self.floatMeUI.rankUIScaleLayer:runAction(CCScaleTo:create(10 /FPS, finalScale, finalScale))

			            for _, v in ipairs(self.floatMeUI.rankUIContentLayer:getChildrenList()) do
			            	if v.name ~= 'holder' then
			            		v:runAction(CCFadeOut:create(10/FPS))
			            	end
			            end
					end

					local array = CCArray:create()

					local rankTopPH = self.ui:getChildByPath('rankTopPH')
					local deltaY = rankTopPH:getPositionY() - self.floatMeUI:getPositionY()
					local duration = deltaY / 1400


					array:addObject(CCMoveBy:create(duration, ccp(0, deltaY)))
					array:addObject(CCCallFunc:create(flyToTop))
					self.floatMeUI:runAction(CCSequence:create(array))


				end, true)

			end
		end)

	else
		local EndPos = self:getTopRankPos(xfData.fullstar_rank)
		local parent = self.floatMeUI:getParent()
		EndPos = parent:convertToNodeSpace(EndPos)
		local anim = UIHelper:createArmature2('skeleton/xf_anim', 'xf.anim/show')
        parent:addChild(anim)
        anim:setPosition(EndPos)
        anim:playByIndex(0, 1)
        anim:addEventListener(ArmatureEvents.COMPLETE, function ( ... )
        	if self.isDisposed then return end
        	if anim.isDisposed then return end
        	anim:removeFromParentAndCleanup(true)
        	__finish()
        end)

        self:playTopRankScaleAnim(xfData.fullstar_rank)
	end


end

function XFMainPanel:getTopRankPos( rank )
	if self.isDisposed then return end
	local topRankUI = self.ui:getChildByPath('食物链顶端/' .. rank)
	if not topRankUI then
		return ccp(0, 0)
	end

	local pos = topRankUI:getPosition()
	local size = topRankUI:getContentSize()
	local sx = topRankUI:getScaleX()
	local sy = topRankUI:getScaleY()


	return  self.ui:getChildByPath('食物链顶端'):convertToWorldSpace(ccp(pos.x + size.width/2 * sx, pos.y - size.height/2 * sy))
end

function XFMainPanel:playTopRankScaleAnim( rank, callback )
	if self.isDisposed then return end
	local topRankUI = self.ui:getChildByPath('食物链顶端/' .. rank)
	if not topRankUI then
		if callback then callback() end
		return
	end

	topRankUI:setAnchorPointCenterWhileStayOrigianlPosition()

	local sx = topRankUI:getScaleX()
	local sy = topRankUI:getScaleY()

	local array = CCArray:create()
	array:addObject(CCScaleTo:create(0, 0.88 * sx, 0.88 * sx))
	array:addObject(CCScaleTo:create(4/FPS, 1.30 * sy, 1.30 * sy))
	array:addObject(CCScaleTo:create(5/FPS, 1.0 * sx, 1.0 * sy))
	array:addObject(CCCallFunc:create(function ( ... )
		if callback then callback() end
	end))

	topRankUI:runAction(CCSequence:create(array))
end




return XFMainPanel
