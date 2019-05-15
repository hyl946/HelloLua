require 'zoo.panel.basePanel.BasePanel'
require "zoo.util.NewVersionUtil"
-- require "zoo.panel.UpdateSJSuccessPanel"

-- local UpdatePackageLogic = require 'zoo.panel.UpdatePackageLogic'
-- local UIUtils = require 'zoo.panel.UIHelper'
-- local AsyncSkinLoader = require 'zoo.panel.AsyncSkinLoader'
-- local updateTargetVersion = ''


local list_Width = 700
local list_Height = 1070

local userDefaultKey_Update = "UpdateMainPanel_18_12_27"

local panelConfigFile = "ui/UpdateMainPanel/UpdateMainPanel.json"


local textureTable = {
    -- "ui/UpdateMainPanel/UpdateMainPanel_1.png",
    -- "ui/UpdateMainPanel/UpdateMainPanel_2.png",
    -- "ui/UpdateMainPanel/UpdateMainPanel_3.png",
    -- "ui/UpdateMainPanel/UpdateMainPanel_4.png",
}
--小版本好 每次 + 1
local bundleVersion_2 = 2

local UpdatePanelConfig = {
	pageNum = #textureTable,
	showVersionKey = bundleVersion_2 + tonumber(  _G.bundleVersion:split(".")[2] ) * 100
}



local UpdatePagePanel = class(BaseUI)
-- 新版本更新界面 2018年6月19日
local UpdateMainPanel = class(BasePanel)

function UpdatePagePanel:create( ui, rewards ,closeCallback)
	local panel = UpdatePagePanel.new()
    panel:init( ui , rewards ,closeCallback )
	return panel
end
function UpdatePagePanel:init( ui , rewards ,closeCallback )

	-- self.panelConfigFile = panelConfigFile
	-- self.builder = InterfaceBuilder:createWithContentsOfFile( panelConfigFile )
	-- local ui = self.builder.buildGroup("panel2")
	BaseUI.init(self, ui)
	-- self.rewards = rewards
	self.items = {}
	for k, v in ipairs( rewards ) do
		local item = {}
		item.itemId = v.itemId
		item.num = v.num
		table.insert(self.items, item)
	end

	self.closeCallback = closeCallback

	self.getrewbtn = self.ui:getChildByName('getrewbtn')
	self.getrewbtn = GroupButtonBase:create( self.getrewbtn )
    self.getrewbtn:setString("领取奖励")

    local function onOkTapped(  )
    	if self.isDisposed then return end
    	self:onOkTapped()
    end 
    self.getrewbtn:ad(DisplayEvents.kTouchTap, onOkTapped )
    
    self.getrewbtn:useBubbleAnimation()
    self.confirm = self.getrewbtn

    self:buildRewardItem()
end


function UpdateMainPanel:doFinish(  )
	if UpdatePanelConfig.pageNum > 0 then
		CCUserDefault:sharedUserDefault():setIntegerForKey( userDefaultKey_Update , UpdatePanelConfig.showVersionKey )
   	 	CCUserDefault:sharedUserDefault():flush()
	end
end
	


function UpdateMainPanel:canPopout(  )


	local userKey = CCUserDefault:sharedUserDefault():getIntegerForKey( userDefaultKey_Update , 0) or 0
	local canPopout = false

	local numVersion  = tonumber(_G.bundleVersion:split(".")[2]) * 100
	if userKey  >= numVersion + bundleVersion_2 then
		canPopout = false
	else
		if #textureTable > 0 then
			canPopout = true
		end
	end

	if not self:levelIsSupport() then
		canPopout = false
	end

	if _G.isLocalDevelopMode  then printx(102 , "UpdateMainPanel:canPopout=" , canPopout) end
	-- if _G.isLocalDevelopMode  then printx(102 , "UpdateMainPanel:hasReward=" , hasReward) end

	return canPopout 

end
function UpdatePagePanel:onCloseBtnTapped()



	if self.closeCallback then
		self.closeCallback()
		self.closeCallback = nil 
	end

end



function UpdatePagePanel:onOkTapped()

	if self.isDisposed then return end
	if self.isCLickOk == true then
		return
	end
	self.isCLickOk = true
	self.confirm:setEnabled(false)

	local function onSuccess( evt )
		
        DcUtil:UserTrack({ category='update', sub_category='get_update_reward' })
        DcUtil:UserTrack({ category='Update', sub_category='update_over', t1 = 0})


	    UserManager.getInstance().updateRewards = nil
	    UserManager.getInstance().preRewards = nil
	    UserManager.getInstance().preRewardsFlag = true

	    if self.isDisposed then
	    	return
	    end

	    UserManager:getInstance():addRewards(self.items, true)
	    UserService:getInstance():addRewards(self.items)
	    GainAndConsumeMgr.getInstance():gainMultiItems(DcFeatureType.kTrunk, self.items, DcSourceType.kUpdate)

	    local function flyAction(  )
	    	local anim = OpenBoxAnimation:create( self.items )
			anim:play()
	    end 

	    setTimeOut(flyAction , 0.1)

	  --   for k,v in ipairs(self.items) do
	  --   	local anim = FlyItemsAnimation:create({v})
			-- local name = "itembg"..k 
			-- local worldPos = ccp(0,0)
			-- local itembg = self.ui:getChildByName(name)
			-- if itembg then
			-- 	local contentSize = itembg:getContentSize()
			-- 	worldPos = itembg:convertToWorldSpace(ccp(0,0))
			-- 	worldPos = ccpAdd(worldPos , ccp( contentSize.width/2, contentSize.height/2) )
			-- end

		 --    anim:setWorldPosition(ccp( worldPos.x , worldPos.y ))
		 --    anim:play()
	  --   end
	  	self.isCLickOk = false
		self:onCloseBtnTapped(true)
	end

	local function onFail( evt ) 

        DcUtil:UserTrack({ category='Update', sub_category='update_over', t1 = 1})

		
		CommonTip:showTip(Localization:getInstance():getText("error.tip."..tostring(evt.data)), "negative")
	   	UserManager.getInstance().updateRewards = nil
	   	UserManager.getInstance().preRewards = nil
	    UserManager.getInstance().preRewardsFlag = true

	    if self.isDisposed then
	    	return
	    end
	    self.isCLickOk = false
		self:onCloseBtnTapped(true)
	end

	local function onCancel(evt)
	  	UserManager.getInstance().updateRewards = nil
	  	UserManager.getInstance().preRewards = nil
	    UserManager.getInstance().preRewardsFlag = true

	    if self.isDisposed then
	    	return
	    end
	    self.isCLickOk = false
		self.confirm:setEnabled(true)
	end

	local http = GetUpdateRewardHttp.new(true)
	http:ad(Events.kComplete, onSuccess)
	http:ad(Events.kError, onFail)
	http:ad(Events.kCancel, onCancel)
	http:load()
end

function UpdatePagePanel:buildRewardItem()

	

	for i=1,3 do
		local name = "itembg"..i 
		local itembg = self.ui:getChildByName(name)
		if itembg then
			itembg:setVisible(false)
		end
	end


	local function fixNum(num)
		if not num then
			return 0
		end
		if num >100000000 then
			return math.floor(num*0.00000001).."亿"
		elseif num > 10000 then
			return math.floor(num*0.0001).."万"
		elseif num > 1000 then
			return math.floor(num*0.001).."千"
		end
		return num
	end

	for index,rewardItem in ipairs(self.items) do
		local sp = ResourceManager:sharedInstance():buildItemSprite(rewardItem.itemId)
		local num = BitmapText:create('', 'fnt/event_default_digits.fnt')
		num:setText('x'..fixNum(rewardItem.num))
		num:setAnchorPoint(ccp(0, 0))
		sp:setAnchorPoint(ccp(0.5, 0.5))
		sp:addChild(num)
		num:setPositionX(70)

		local name = "itembg"..index 
		local itembg = self.ui:getChildByName(name)
		if itembg then
			itembg:setVisible(true)
			itembg:addChild(sp)
			local name = "itemicon"..index
			self[name] = sp
			local contentSize = itembg:getContentSize()
			sp:setPosition(ccp(contentSize.width/2, contentSize.height/2))
		end
	end

	local item1_PosX = self.ui:getChildByName("itembg1"):getPositionX()
	local item1_PosY = self.ui:getChildByName("itembg1"):getPositionY()

	local item2_PosX = self.ui:getChildByName("itembg2"):getPositionX()
	local item2_PosY = self.ui:getChildByName("itembg2"):getPositionY()

	local item3_PosX = self.ui:getChildByName("itembg3"):getPositionX()
	local item3_PosY = self.ui:getChildByName("itembg3"):getPositionY()

	if #self.items == 1 then
		-- 130 -21 27 0
		item1_PosX = item1_PosX - 100 
		item1_PosY = item1_PosY - 21 
		self.ui:getChildByName("itembg1"):setPosition( ccp( item1_PosX , item1_PosY ) )
	elseif #self.items == 2 then

		item1_PosX = item1_PosX - 60 
		item1_PosY = item1_PosY + 8 
		-- 	122 225    137 281
		item2_PosX = item2_PosX + 15 
		item2_PosY = item2_PosY - 56 
		self.ui:getChildByName("itembg1"):setPosition( ccp( item1_PosX , item1_PosY ) )
		self.ui:getChildByName("itembg2"):setPosition( ccp( item2_PosX , item2_PosY ) )
	else

		item2_PosX = item2_PosX + 0 
		item2_PosY = item2_PosY - 50 

		item3_PosX = item3_PosX + 50 
		item3_PosY = item3_PosY - 80 

		self.ui:getChildByName("itembg2"):setPosition( ccp( item2_PosX , item2_PosY ) )
		self.ui:getChildByName("itembg3"):setPosition( ccp( item3_PosX , item3_PosY ) )
	end



	




end



function UpdateMainPanel:create( closeCallback )
	local panel = UpdateMainPanel.new()
    panel:loadRequiredResource( panelConfigFile )
    panel:init( closeCallback )
	return panel
end

function UpdateMainPanel:init( closeCallback )
 --    self.rewards = Meta.rewards
 	DcUtil:UserTrack({ category='update', sub_category='UI_updatecompleted_popout' })


	local ui = self:buildInterfaceGroup("panel1")
	BasePanel.init(self, ui)
--	self.hasReward = NewVersionUtil:hasUpdateReward()

	if not self:levelIsSupport() then
		UpdatePanelConfig.pageNum = 0
		textureTable = {}
	end

	self.pngNum = UpdatePanelConfig.pageNum
	self.pageNum = UpdatePanelConfig.pageNum




	self.closeCallback = closeCallback

	self.pageIndex = 1
	self.curIndex = self.pageIndex

	self.mainbg = self.ui:getChildByName('mainbg')
	if self.mainbg then 
		self.mainbg:setVisible(false) 
	end

--    if self.hasReward then
--		self.pageNum = UpdatePanelConfig.pageNum + 1 	
--	end

    self.leftbtn = self.ui:getChildByName('leftbtn')
    if self.leftbtn then
		self.leftbtn:setTouchEnabled(true)
	    self.leftbtn:ad(DisplayEvents.kTouchTap, function ()
	    	if self.isDisposed then return end
	       self:onLeftBtnTapped()
	    end)
	end
	self.leftbtn:setVisible(false)
	self.rightbtn = self.ui:getChildByName('rightbtn')
    if self.rightbtn then
		self.rightbtn:setTouchEnabled(true)
	    self.rightbtn:ad(DisplayEvents.kTouchTap, function ()
	    	if self.isDisposed then return end
	       self:onRightBtnTapped()
	    end)
	end

	self.rightbtnBig = Sprite:createWithSpriteFrameName("rightbtn20000")
	local childIndex = self.ui:getChildIndex( self.rightbtn )
	self.ui:addChildAt( self.rightbtnBig ,childIndex )
	self.rightbtnBig:setPositionX( self.rightbtn:getPositionX() )
	self.rightbtnBig:setPositionY( self.rightbtn:getPositionY() - 65 )

	self.rightbtnSmall = Sprite:createWithSpriteFrameName("rightbtn20000")
	self.rightbtnSmall:setScale(0.65)
	childIndex = self.ui:getChildIndex( self.rightbtn )
	self.ui:addChildAt( self.rightbtnSmall ,childIndex )
	self.rightbtnSmall:setPositionX( self.rightbtn:getPositionX() )
	self.rightbtnSmall:setPositionY( self.rightbtn:getPositionY() - 65 )


	self.rightbtnBig:setAnchorPoint(ccp( 0.5, 0.5 ))
	self.rightbtnSmall:setAnchorPoint(ccp( 0.5, 0.5 ))

    self.emptynode = self.ui:getChildByName('emptynode')
    self.selectednode = self.ui:getChildByName('selectednode')
    if self.emptynode then 
		self.emptynode:setVisible(false) 
	end
	if self.selectednode then 
		self.selectednode:setVisible(false) 
	end



    self.items = {} 

--    if self.hasReward then
--    	local rewards = UserManager.getInstance().updateRewards
--		if (not UserManager.getInstance().preRewardsFlag and UserManager.getInstance().preRewards) then
--			rewards = UserManager.getInstance().preRewards
--		end

--		local sjRewards = UserManager.getInstance().sjRewards
--		if sjRewards and #sjRewards > 0 then
--			rewards = sjRewards
--		end

--		for k, v in ipairs(rewards) do
--			local item = {}
--			item.itemId = v.itemId
--			item.num = v.num
--			table.insert(self.items, item)
--		end

--    end

    self:createMainTab()
    self:createPngPage()
    



    
end

function UpdateMainPanel:onLeftBtnTapped()
	if self.isDisposed then return end
	if self.isMoveing then return end
    if self.pageIndex <= 1 then return end

    

    self.pageIndex = self.pageIndex - 1
    self.pagedView:gotoPage( self.pageIndex )
end

function UpdateMainPanel:onRightBtnTapped()
	if self.isDisposed then return end
	if self.isMoveing then return end
    if self.pageIndex >= self.pageNum then return end

    

    self.pageIndex = self.pageIndex + 1
    self.pagedView:gotoPage( self.pageIndex )
end


function UpdateMainPanel:next()
	if self.isDisposed then return end
    if self.curIndex >= self.pageNum then return end
    self:goto(self.curIndex + 1)
end


function UpdateMainPanel:prev()
	if self.isDisposed then return end
    if self.curIndex <= 1 then return end
    self:goto(self.curIndex - 1)
end


function UpdateMainPanel:goto( curIndex )
	if self.isDisposed then return end

	if curIndex > self.curIndex  then
		DcUtil:UserTrack({ category='update', sub_category='UI_updatecompleted_clickforward' })
		if _G.isLocalDevelopMode  then printx(100 , "UI_updatecompleted_clickforward" ) end
	end
	if curIndex < self.curIndex  then
		DcUtil:UserTrack({ category='update', sub_category='UI_updatecompleted_clickback' })
		if _G.isLocalDevelopMode  then printx(100 , "UI_updatecompleted_clickback" ) end
	end

	self.curIndex = curIndex
	self:updateTab()
	self:updateLeftRightVisable()
	
end

function UpdateMainPanel:updateTab(  )
	
	self.pageIndex = self.pagedView:getPageIndex()

	if self.pageNum <=1 then
		self.leftbtn:setVisible(false)
		self.rightbtn:setVisible(false)
		self.rightbtnSmall:setVisible(false)
		self.rightbtnBig:setVisible(false)

		local tabNormal = self.tabTable_Normal[1]
		local tabSelected = self.tabTable_Selected[1]
		if tabNormal then
			tabNormal:setVisible( false)
		end
		if tabSelected then
			tabSelected:setVisible( false )
		end
		if self.pageNum == 0 then
			self:onCloseBtnTapped(true)
		end
		return
	end

	for i=1,self.pageNum do

		local tabNormal = self.tabTable_Normal[i]
		local tabSelected = self.tabTable_Selected[i]

		if i == self.curIndex then
			if tabNormal then
				tabNormal:setVisible( false)
			end
			if tabSelected then
				tabSelected:setVisible( true )
			end
		else
			if tabNormal then
				tabNormal:setVisible( true )
			end
			if tabSelected then
				tabSelected:setVisible( false )
			end
		end

	end



end

function UpdateMainPanel:createMainTab(  )

	self.tabTable_Normal = {}
	self.tabTable_Selected = {}

	local tabPosY = - list_Height - 10 

	local distace = 100
	
	local nodeWidth = 40
	-- local nodeWidth_Sel = 22

	local visibleRectSize = self.ui:getGroupBounds(self.ui:getParent()).size

	print("visibleRectSize = " , visibleRectSize.width , visibleRectSize.height )

	local totalWith = (self.pageNum - 1 ) * distace 

	local leftPosX = visibleRectSize.width /2 - totalWith/2 

	for i=1,self.pageNum do
		local tabNode = Sprite:createWithSpriteFrameName( "emptynode0000")
		tabNode:setAnchorPoint(ccp( 0.5 , 0.5 ))
		tabNode:setPosition(ccp( leftPosX + ( i - 1 ) * distace  , tabPosY ))
		self.ui:addChild( tabNode )
		self.tabTable_Normal[i] = tabNode
	end

	for i=1,self.pageNum do
		local tabNode = Sprite:createWithSpriteFrameName( "selectednode0000")
		tabNode:setAnchorPoint(ccp( 0.5 , 0.5 ))
		tabNode:setPosition(ccp( leftPosX + ( i - 1 ) * distace  , tabPosY ))
		self.ui:addChild( tabNode )
		self.tabTable_Selected[i] = tabNode
	end

	-- local tabNode = Sprite:createWithSpriteFrameName( "selectednode0000")
	-- tabNode:setAnchorPoint(ccp( 0 , 0.5 ))
	-- tabNode:setPosition(ccp( 0 , 0  ))
	-- self.ui:addChild( tabNode )

--	selectednode0000
--	emptynode0000
		
end




function UpdateMainPanel:levelIsSupport(  )
	if UserManager.getInstance().user:getTopLevelId() < 30 then
		return false
	end
	return true
end


function UpdateMainPanel:onEnterHandler(event, ...)
    BasePanel.onEnterHandler(self , event)

    if event == "enter" then
    	if self.pagedView then
    		self.pagedView:gotoPage( self.pageIndex  )
    	end

	    if #self.items > 3 and _G.isLocalDevelopMode  then

	    	local text = "rewards = " .. table.tostring( self.items )
	    	local params={}
		    params.isConfirm = false
		    params.isLeft = true
		    params.isAutoSize = true
		    params.title = "奖励信息大于3个"
		    params.info = text
		    params.strOK = "继续"
		    params.okCallback = finishCallback
		    Alert:create(params)

	    end

	    self:updateLeftRightVisable()



    end


end

function UpdateMainPanel:updateLeftRightVisable()

--	self.leftbtn:setVisible(true)
	self.rightbtn:setVisible(true)
	self.rightbtnSmall:setVisible(true)
	self.rightbtnBig:setVisible(true)
--	self.rightbtn:setVisible(false)
		

	if self.pageNum <= 1 then

		self.leftbtn:setVisible( false )
		self.rightbtn:setVisible( false )
		self.rightbtnSmall:setVisible(false)
		self.rightbtnBig:setVisible(false)

	elseif self.pageIndex <= 1 then

		self.leftbtn:setVisible( false )

	elseif self.pageIndex >= self.pageNum then

		self.rightbtn:setVisible( false )
		self.rightbtnSmall:setVisible(false)
		self.rightbtnBig:setVisible(false)

	end




end

function UpdateMainPanel:popoutShowTransition()
    self.allowBackKeyTap = true

    local winSize = CCDirector:sharedDirector():getVisibleSize()

	local w = list_Width
	local h = 1100

	local r = winSize.height / h
	if r < 1.0 then
		self:setScale(r)
	end

	local x = self:getHCenterInParentX()
	local y = self:getVCenterInParentY()
	self:setPosition(ccp(x, y))

	self.leftbtn:setPositionX( -x + 10 )


	local rightPosX = 608+x
	self.rightbtnBig:setPositionX( rightPosX  )
	self.rightbtnSmall:setPositionX( rightPosX - 30 )
	self.rightbtnSmall:setPositionY( self.rightbtnBig:getPositionY() )

	local timeSlice = 1.0
	

	local function resetRightBtnsPos()
		self.rightbtnBig:setPositionX( rightPosX   )
		self.rightbtnSmall:setPositionX( rightPosX - 30 )
	end

	local loopAction = CCArray:create()

	loopAction:addObject(CCCallFunc:create(function ( ... )
			resetRightBtnsPos()
		end))



	local secondFrame = 1/60

	local delayTime1 = 50 * secondFrame
	local delayTime2 = 10 * secondFrame


	local actionArrayNode_Spa1 = CCArray:create()
	actionArrayNode_Spa1:addObject( CCFadeIn:create( 10 * secondFrame) )
	actionArrayNode_Spa1:addObject( CCMoveBy:create( 30 * secondFrame , ccp( 20 , 0) ) )
	local actionArrayNode_Spa2 = CCArray:create()
	actionArrayNode_Spa2:addObject( CCFadeOut:create( 10 * secondFrame) )
	actionArrayNode_Spa2:addObject( CCMoveBy:create( 5 * secondFrame , ccp( 5 , 0) ) )
	local seq = CCSequence:createWithTwoActions( CCSpawn:create( actionArrayNode_Spa1 ) , CCSpawn:create( actionArrayNode_Spa2 ))
	loopAction:addObject( seq )
	loopAction:addObject( CCDelayTime:create( delayTime1) )
	loopAction:addObject( CCDelayTime:create( delayTime2) )

	local loopAction2 = CCArray:create()
	loopAction2:addObject( CCDelayTime:create( delayTime2 ) )
	local actionArrayNode_Spa3 = CCArray:create()
	actionArrayNode_Spa3:addObject( CCFadeIn:create( 10 * secondFrame) )
	actionArrayNode_Spa3:addObject( CCMoveBy:create( 30 * secondFrame , ccp( 20 , 0) ) )
	local actionArrayNode_Spa4 = CCArray:create()
	actionArrayNode_Spa4:addObject( CCFadeOut:create( 10 * secondFrame) )
	actionArrayNode_Spa4:addObject( CCMoveBy:create( 5 * secondFrame , ccp( 5 , 0) ) )
	local seq = CCSequence:createWithTwoActions( CCSpawn:create( actionArrayNode_Spa3 ) , CCSpawn:create( actionArrayNode_Spa4 ))
	loopAction2:addObject( seq )
	loopAction2:addObject( CCDelayTime:create( delayTime1 ) )

	self.rightbtnBig:runAction( CCRepeatForever:create( CCSequence:create(loopAction) ) )
	self.rightbtnSmall:runAction( CCRepeatForever:create( CCSequence:create(loopAction2) ) )

	local rightbtnDisplay = self.rightbtn:getChildByName("rightbtn")
	if rightbtnDisplay then
		rightbtnDisplay:setVisible(false)
	end


end

function UpdateMainPanel:popout()

--	PopoutQueue.sharedInstance():push(self,true,false,function( ... )end)
	PopoutQueue.sharedInstance():push(self, true,nil,nil,nil,nil,180)

end


function UpdateMainPanel:onTextBtnClock(  )
	self:onCloseBtnTapped(false)
end


function UpdateMainPanel:onCloseBtnTapped( isBySelf )
	if self.isDisposed then return end

	if not isBySelf then
		DcUtil:UserTrack({ category='update', sub_category='UI_updatecompleted_Androidback' })
--		if self.hasReward and self.getRewardsPanel then
--			self.getRewardsPanel:onOkTapped()
--			return
--		end
	end

	PopoutManager:sharedInstance():remove(self)
	self:doFinish()
	if self.closeCallback then
		self.closeCallback()
		self.closeCallback = nil 
	end
end

function UpdateMainPanel:dispose()

	if self.closeCallback then
		self.closeCallback()
		self.closeCallback = nil 
	end
	BasePanel.dispose(self)
    for i,v in ipairs(textureTable) do
        CCTextureCache:sharedTextureCache():removeTextureForKey(
            CCFileUtils:sharedFileUtils():fullPathForFilename(
                SpriteUtil:getRealResourceName(v)
            )
        )
    end
	
end


function UpdateMainPanel:createPngPage(  )
	local winSize = CCDirector:sharedDirector():getWinSize()

	local pagedView = PagedView:create( list_Width , list_Height , self.pageNum, self, true, false)
    -- pagedView.pageMargin = 35
    pagedView:setIgnoreVerticalMove(false) -- important!
    -- tab:setView(pagedView)
    pagedView:setPosition(ccp( 0 , -list_Height ))
    local function switchCallback()
    	self.isMoveing = true
 	end
    local function switchFinishCallback() 
    	self.isMoveing = false
    end

    pagedView:setSwitchPageCallback(switchCallback)
    pagedView:setSwitchPageFinishCallback(switchFinishCallback)

    local index = self.ui:getChildIndex( self.mainbg )
    self.ui:addChildAt( pagedView ,index )
    self.pagedView = pagedView


    self.okbtn = self.ui:getChildByName('okbtn')
    self.okbtn:setVisible(false)

    self.closeBtn = self.ui:getChildByName('closeBtn')
    self.closeBtn:setVisible(false)

    local btnPos = self.okbtn:getPosition()
    local closePos = self.closeBtn:getPosition()

    local function onCLickokbtn()
    	if self.isDisposed then return end
    	DcUtil:UserTrack({ category='update', sub_category='UI_updatecompleted_clickstart' })
      	self:onCloseBtnTapped(true)
	end

	local function onTextBtnClock()
    	if self.isDisposed then return end
      	self:onTextBtnClock()
	end


	local centerPos_X = list_Width/2 
	local centerPos_Y = - list_Height/2 

	if self:levelIsSupport() then
		for i=1,#textureTable do
		
			-- local addWidth = winSize.width * (i - 1)
			
			local emptyLayer =  Layer:create()
			emptyLayer:changeWidthAndHeight( list_Width , list_Height )

			local bg = Sprite:create(textureTable[ i ])
	    	bg:setAnchorPoint(ccp( 0.5 , 0.5 ))
	    	bg:setPosition(ccp( centerPos_X  , centerPos_Y ))
	    	emptyLayer:addChild( bg )

	    	if i == self.pngNum then

	    		self.okbtn:removeFromParentAndCleanup(false)
	    		emptyLayer:addChild(self.okbtn)
	    		self.okbtn:setVisible(true)

	    	    self.okbtn = GroupButtonBase:create( self.okbtn )
			    self.okbtn:setString("立即体验")
			    self.okbtn:ad(DisplayEvents.kTouchTap, onCLickokbtn )
			    self.okbtn:useBubbleAnimation()
			    self.okbtn:setPosition( ccp (btnPos.x,btnPos.y) )
	    	end

            --add close btn
            local UIHelper = require 'zoo.panel.UIHelper'
            local closeBtn = UIHelper:createUI("ui/UpdateMainPanel/UpdateMainPanel.json", "updateMainPanelRes/closeres/myclose")
	    	emptyLayer:addChild(closeBtn)

            local function closeCallBack()
                self:onCloseBtnTapped(true)
            end
            closeBtn:setTouchEnabled(true)
            closeBtn:ad(DisplayEvents.kTouchTap, closeCallBack )
            closeBtn:setPosition( ccp (closePos.x,closePos.y) )

	    	self.pagedView:addPageAt( emptyLayer , i )
	    	
		end


	end

--	if self.hasReward then
--		local UpdatePagePanelUi = self:buildInterfaceGroup("panel2")
--		print("self.items = " , table.tostring(self.items))

--		local panel  = UpdatePagePanel:create( UpdatePagePanelUi ,self.items , onCLickokbtn )
--		panel:setAnchorPoint(ccp( 0 , 0 ))
--     	panel:setPosition(ccp( -125  , 50 ))

--    	local emptyLayer =  Layer:create()
--		emptyLayer:changeWidthAndHeight( list_Width , list_Height )
--		emptyLayer:addChild( panel )
--		self.pagedView:addPageAt( emptyLayer , self.pageNum )

--		self.getRewardsPanel = panel

--	end


	


end




return UpdateMainPanel