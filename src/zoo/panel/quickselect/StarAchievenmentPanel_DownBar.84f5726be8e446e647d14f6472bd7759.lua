require 'zoo.panel.basePanel.BasePanel'

require 'zoo.panel.quickselect.StarAchievenmentBasicInfo'

require 'zoo.panel.quickselect.TabFourStarLevel'
require 'zoo.panel.quickselect.TabHiddenLevel'
require 'zoo.panel.quickselect.TabAskForHelp'
require 'zoo.panel.quickselect.NewMoreStarPanel'
require 'zoo.panel.quickselect.FourStarGuideIcon'


require("zoo/panel/quickselect/TabLevelArea_New.lua")
require("zoo/panel/quickselect/StarAchievenmentPanel_Recommend.lua")
require("zoo/panel/quickselect/StarTip.lua")


local UIHelper = require 'zoo.panel.UIHelper'

local XFLogic = require 'zoo.panel.xfRank.XFLogic'

local winSize = Director:sharedDirector():getWinSize()
local visibleSize = CCDirector:sharedDirector():getVisibleSize()


local tipInstance = nil
local function disposeTip()
	if tipInstance then 
		tipInstance:hide()
		tipInstance:dispose()
		tipInstance = nil
	end
end
local function showTip(rect, content , delta )
	disposeTip()
	tipInstance = StarTip:create( nil, delta ,5)
	tipInstance:show(rect)
end


---------------------------------------------------
---------------------------------------------------
-------------- StarAchievenmentPanel_DownBar
---------------------------------------------------
---------------------------------------------------
local function getStarWithLevelId( levelIdNode )
    if levelIdNode ==nil or levelIdNode <=0  then
        return 0
    end

    local scoreOfLevel = UserManager:getInstance():getUserScore(levelIdNode)
    if scoreOfLevel then
        if scoreOfLevel.star ~= 0 or 
            JumpLevelManager:getLevelPawnNum(userTopLevel) > 0 or 
            UserManager:getInstance():hasAskForHelpInfo(userTopLevel) then 
            if scoreOfLevel.star ==nil then
                return 0
            else
                return scoreOfLevel.star
            end
        end
    else
        return 0 
    end
    return scoreOfLevel.star
end 

StarRewardItem3 = class(BaseUI)

function StarRewardItem3:create(ui, itemId, itemNumber, ...)


	local newStarRewardItem3 = StarRewardItem3.new()
	newStarRewardItem3:init(ui, itemId, itemNumber)
	return newStarRewardItem3
end

function StarRewardItem3:init(ui, itemId, itemNumber, ...)


	------------------
	-- Init Base Class
	-- ---------------
	BaseUI.init(self, ui)

	-----------------
	-- Get UI Resource
	-- ---------------
	self.numberLabel	= self.ui:getChildByName("numberLabel")
	self.numberLabelFontSize = self.ui:getChildByName("numberLabel_fontSize")
	self.numberLabel = TextField:createWithUIAdjustment(self.numberLabelFontSize, self.numberLabel)


	self.itemPh		= self.ui:getChildByName("itemPh")



	---------
	-- Data
	-- -------
	self.itemId	= itemId
	self.itemNumber	= itemNumber

	-----------------
	-- Get Data About itemPh
	-- -------------------
	self.itemPhPos	= self.itemPh:getPosition()
	self.itemPhSize	= self.itemPh:getGroupBounds().size
	self.itemPhSize = {width = self.itemPhSize.width, height = self.itemPhSize.height}

	if _G.isLocalDevelopMode then printx(100, " self.itemPhSize.width" , self.itemPhSize.width) end
	if _G.isLocalDevelopMode then printx(100, " self.itemPhSize.height" , self.itemPhSize.height) end

	self.itemPh:setVisible(false)

	-------------
	-- Create Item Icon
	-- -----------------
	--if not self.itemId or self.itemId <= 0 then
		--self.itemId = ItemType.COIN --itemId必须有值，否则会不创建self.itemRes，造成ui层会crash
		--正常情况下，如果没有itemId，则根本不会弹板
	--end
	self:rebuild(self.itemId,self.itemNumber)
end

function StarRewardItem3:rebuild(itemId, itemNumber, ...)
	self.itemId	= itemId
	self.itemNumber	= itemNumber

	if self.itemId > 0 then
		if self.itemRes then self.itemRes:removeFromParentAndCleanup(true) end

		local itemRes	= ResourceManager:sharedInstance():buildItemSprite(self.itemId)
		self.itemRes	= itemRes
		self.ui:addChild(itemRes)

		self.itemRes:setAnchorPoint(ccp(0.5,0.5))
		self.itemRes:setScale(1.4)
		self.itemRes:setPositionXY( 133/2 +43, -123/2 -42 )


		self.numberLabel:stopAllActions()
		self.numberLabel:removeFromParentAndCleanup(false)
		self.ui:addChild(self.numberLabel)

		self.numberLabel:setString("x" .. self.itemNumber)
	end
end

StarAchievenmentPanel_DownBar = class(BasePanel)
--__isQQ = PlatformConfig:isQQPlatform()
__isQQ = false
function StarAchievenmentPanel_DownBar:create( hostPanel )
	local panel = StarAchievenmentPanel_DownBar.new()
	panel.hostPanel = hostPanel
	panel:init()

	

	return panel
end

function StarAchievenmentPanel_DownBar:unloadRequiredResource()



end

function StarAchievenmentPanel_DownBar:init()

	self:initData()
	
	self:initUI()

end


function StarAchievenmentPanel_DownBar:initData()

	self:caculateStarInfo()



end

function StarAchievenmentPanel_DownBar:getStarRewardNum(  )
			

	local curTotalStar 	= UserManager:getInstance().user:getTotalStar()
	local userExtend 	= UserManager:getInstance().userExtend

	-- Get RewardLevelMeta 
	local nearestStarRewardLevelMeta 	= MetaManager.getInstance():starReward_getRewardLevel(curTotalStar)
	

	local nextRewardLevelMeta		= MetaManager.getInstance():starReward_getNextRewardLevel(curTotalStar)
	local rewardLevelToPushMeta 		= false

	if nearestStarRewardLevelMeta then
		local rewardLevelToPush = userExtend:getFirstNotReceivedRewardLevel(nearestStarRewardLevelMeta.id)

		if rewardLevelToPush then
			-- Has Reward Level
			rewardLevelToPushMeta = MetaManager.getInstance():starReward_getStarRewardMetaById(rewardLevelToPush)
		else
			-- All Reward Level Has Received
		end
	end

	if not rewardLevelToPushMeta then
		-- If Has Next Reward Level, Show It
		if nextRewardLevelMeta then
			rewardLevelToPushMeta = nextRewardLevelMeta
		end
	end	

	if not rewardLevelToPushMeta then
		if _G.isLocalDevelopMode then printx(99, "return starRewardNum = " , 0) end

		return 0
	end
	-- if _G.isLocalDevelopMode then printx(99, "rewardLevelToPushMeta = " ,  table.tostring(rewardLevelToPushMeta) ) end


	local user_starRewardID = rewardLevelToPushMeta.id 
	user_starRewardID =tonumber(user_starRewardID)

	local star_rewardMeta = MetaManager.getInstance().star_reward
	local starRewardNum = 0

	-- if _G.isLocalDevelopMode then printx(99, "user_starRewardID = " , user_starRewardID) end

	for k,v in ipairs( star_rewardMeta ) do
		if _G.isLocalDevelopMode then printx(99, " v.id= " ,  v.id ) end
		if curTotalStar >= v.starNum and user_starRewardID <= tonumber(v.id) then
			starRewardNum= starRewardNum + 1
		end
	end

	-- if _G.isLocalDevelopMode then printx(99, "starRewardNum = " , starRewardNum) end

	return starRewardNum

end


function StarAchievenmentPanel_DownBar:caculateStarInfo()
	-- Get Current Star
	self.curTotalStar 	= UserManager:getInstance().user:getTotalStar()
	local userExtend 	= UserManager:getInstance().userExtend

	-- Get RewardLevelMeta 
	local nearestStarRewardLevelMeta 	= MetaManager.getInstance():starReward_getRewardLevel(self.curTotalStar)
	

	local nextRewardLevelMeta		= MetaManager.getInstance():starReward_getNextRewardLevel(self.curTotalStar)
	local rewardLevelToPushMeta 		= false

	if nearestStarRewardLevelMeta then
		local rewardLevelToPush = userExtend:getFirstNotReceivedRewardLevel(nearestStarRewardLevelMeta.id)

		if rewardLevelToPush then
			-- Has Reward Level
			rewardLevelToPushMeta = MetaManager.getInstance():starReward_getStarRewardMetaById(rewardLevelToPush)
		else
			-- All Reward Level Has Received
		end
	end

	if not rewardLevelToPushMeta then
		-- If Has Next Reward Level, Show It
		if nextRewardLevelMeta then
			rewardLevelToPushMeta = nextRewardLevelMeta
		end
	end

	self.rewardLevelToPushMeta =  rewardLevelToPushMeta

	if _G.isLocalDevelopMode then printx(99, "rewardLevelToPushMeta = " , table.tostring(rewardLevelToPushMeta)) end

	local itemId		= 0
	local itemNumber	= 0

	if rewardLevelToPushMeta then
		if _G.isLocalDevelopMode then printx(99, rewardLevelToPushMeta.reward[1].num) end
		if _G.isLocalDevelopMode then printx(99, rewardLevelToPushMeta.reward[1].itemId) end

		self.rewardItemId		= rewardLevelToPushMeta.reward[1].itemId
		self.rewardItemCount	= rewardLevelToPushMeta.reward[1].num
	end


	self.starRewardNum = self:getStarRewardNum()

end

function StarAchievenmentPanel_DownBar:CreateScrollViewNode(  )

	-- for i=1,10 do
	-- 	local itemNode = UIHelper:createUI('ui/StarAchievenmentPanel/StarAchievenmentPanel_New.json', 'StarAchievenmentPanel_New/locknode')
	-- 	self.scroll1:addItem( itemNode )
	-- end

 --   	self.scroll1:updateScrollableHeight()


end


function StarAchievenmentPanel_DownBar:onCloseBtnTapped(  )
	if self.hostPanel then
		self.hostPanel:onCloseBtnTapped()
	end
	
end



function StarAchievenmentPanel_DownBar:afterPopout( nowScale )


	local vOrigin = Director:sharedDirector():getVisibleOrigin()
	local visibleWidth = visibleSize.width 

	if _G.isLocalDevelopMode  then printx(99 , " StarAchievenmentPanel_DownBar:initUI() visibleWidth = " , visibleWidth ) end

	if _G.isLocalDevelopMode  then printx(99 , " StarAchievenmentPanel_DownBar:initUI() visibleSize = " , visibleSize.width ,visibleSize.height ) end

	local centerNodeWidth = 226 

   	local nodeWidth_Left = 212
   	local nodeWidth_Right= 235

   	local world_LeftPosX = self.ui:convertToWorldSpace( ccp( 400 - centerNodeWidth/2 , 0 ) ).x
   	local world_RightPosX = self.ui:convertToWorldSpace( ccp( 400 + centerNodeWidth/2 , 0 ) ).x

   	local worldCenterLeftPosX = world_LeftPosX/2
   	local leftCenterPosX = self.ui:convertToNodeSpace(ccp( worldCenterLeftPosX , 0 ) ).x 

   	local worldCenterRightPosX = ( visibleWidth /2 - centerNodeWidth/2 ) /2 + world_RightPosX
   	local rightCenterPosX = self.ui:convertToNodeSpace(ccp( worldCenterRightPosX , 0 ) ).x 


   	self.leftNode:setPositionX( leftCenterPosX - nodeWidth_Left/2 )
   	self.rightnode:setPositionX( rightCenterPosX - nodeWidth_Right/2 )

   	

end

function StarAchievenmentPanel_DownBar:updateRightNode()

	self.progresslabelRight = self.ui:getChildByPath("rightnode/progresslabel")
	if not self.progresslabelRight then
		return
	end
	local areaInfo ,numOfFullStar= UserManager:getInstance():getAreaStarInfo()
	local allFullAreaNum = #areaInfo

	local areaInfoString = numOfFullStar .."/" .. allFullAreaNum
	UIHelper:setCenterText( self.progresslabelRight  ,  areaInfoString , 'fnt/hud.fnt')
	self.progresslabelRight:setAnchorPointCenterWhileStayOrigianlPosition()
	self.progresslabelRight:setScale(0.9)

end




function StarAchievenmentPanel_DownBar:updateMainProgress( leftNum,rightNum )

	if not leftNum then
		return
	end
	if not rightNum then
		return
	end
	local progressValue = leftNum / rightNum
	if progressValue >1 then
		progressValue =1 
	end
	if progressValue <0 then
		progressValue = 0
	end
	if _G.isLocalDevelopMode then printx(99, "  updateMainProgress progressValue = " ,progressValue ) end


	-- progressValue = 1

	local progresscirHalfcular2OffsetX = 0
	if progressValue < 0.3 then
		progresscirHalfcular2OffsetX = - 0.5
	end

	local rotation = -180 + progressValue*180
	self.spriteBar:setRotation( rotation )
	
	local posY = -5
	if progressValue < 0.04 then
		self.spriteBar:setPositionX( 102 )
		-- self.spriteBar:setPositionY( -102 -12  )
		-- posY = 7
		self.spriteBar:setVisible(false)
	else
		self.spriteBar:setPositionX( 102 )
		self.spriteBar:setPositionY( -102   )
		self.spriteBar:setVisible(true)
	end
	
	self.progresscirHalfcular2:setVisible(  false )
	if progressValue >0 and progressValue <1 then
		self.progresscirHalfcular2:setVisible(  true )
	end
	
	self.progresscirHalfcular2:setPositionXY( 12 +progresscirHalfcular2OffsetX ,-100 - 5 )

	self.fulleff:setVisible( progressValue >= 1 )

end


function StarAchievenmentPanel_DownBar:updateLeftNode( leftNum,rightNum )
	self.progresslabel = self.ui:getChildByPath("leftNode/progresslabel")
	if not self.progresslabel then
		return
	end
   	local starMine = 0
   	local allStar = 0
   	local scores = UserManager:getInstance():getScoreRef()
	local areaStars = {}
	local max_unlock_area = math.ceil(UserManager.getInstance().user:getTopLevelId() / 15)

	-- local displayMaxLevel = kMaxLevels
	-- if (_G.isPrePackage) then
	-- 	displayMaxLevel = _G.prePackageMaxLevel
	-- end
	local kMaxLevelsNode = NewAreaOpenMgr.getInstance():getCanPlayTopLevel()
	for k = 1, kMaxLevelsNode/15 do 
		 areaStars[k] = 0
	end
	for k, v in ipairs(scores) do
		local levelId = tonumber(v.levelId)
		if levelId < 10000 and levelId <= kMaxLevelsNode then
			local areaId = math.ceil(levelId / 15)
			areaStars[areaId] = areaStars[areaId] + v.star
		end 
	end

	for k = 1 , kMaxLevelsNode/15  do 
		starMine = starMine + areaStars[k]
		-- allStar = allStar + LevelMapManager.getInstance():getTotalStarNumberByAreaId(k)
	end

	-- 掩藏关卡星星数
	for k = 1 , kMaxLevelsNode/15  do 
		local endLevelId = k * 15
		local branchId = MetaModel:sharedInstance():getHiddenBranchIdByNormalLevelId(endLevelId)

		if branchId and not MetaModel:sharedInstance():isHiddenBranchDesign(branchId) then --已上线隐藏关
			local branchData = MetaModel:sharedInstance():getHiddenBranchDataByBranchId(branchId)
			if branchData and branchData.endNormalLevel == endLevelId then
				for levelId=branchData.startHiddenLevel,branchData.endHiddenLevel do
					local score = UserManager:getInstance():getUserScore(levelId)
					if score and score.star > 0 then
						starMine = starMine + score.star
					end 
				end
				-- allStar = allStar + 9 
			end
		end
	end
	allStar = UserManager:getInstance():getFullStarInOpenedRegionInclude4star() + MetaModel.sharedInstance():getFullStarInOpenedHiddenRegion()
	
	local starString = starMine .."/" .. allStar
	-- local starString = leftNum .."/" .. rightNum
	UIHelper:setCenterText( self.progresslabel  ,  starString , 'fnt/hud.fnt')
	self.progresslabel:setAnchorPointCenterWhileStayOrigianlPosition()
	self.progresslabel:setScale(0.9)



end

function StarAchievenmentPanel_DownBar:initUI()

	FrameLoader:loadArmature('skeleton/StarAchievenmentPanel_New/fulleff', 'StarAchievenmentPanel_New/fulleff',"StarAchievenmentPanel_New/fulleff")

	local ui = UIHelper:createUI('ui/StarAchievenmentPanel/StarAchievenmentPanel_New.json', 'StarAchievenmentPanel_New/downBar')
    self.ui = ui
	BasePanel.init(self, self.ui, "StarAchievenmentPanel_DownBar")

	self.mcOpenSoon = self.ui:getChildByName("mc_open_soon")

	self.downBarbg = self.ui:getChildByPath('downBarbg') 
	self.downBarbg:setAnchorPoint( ccp( 0.5 , 1 ) )
	self.downBarbg:setPositionXY( 400 , -50 )

	self.finishall = self.ui:getChildByName("finishall")


	UIUtils:setTouchHandler(  self.ui:getChildByPath('closebtn') , function ()
        self:onCloseBtnTapped(  )
     end)

	self.leftNode = self.ui:getChildByPath('leftNode')
   	self.rightnode = self.ui:getChildByPath('rightnode')



   	-- self:updateLeftNode()
   	self:updateRightNode()

   	self.centerNode = self.ui:getChildByPath('centerNode')

   	self.centernodebtn = self.ui:getChildByPath('centerNode/centernodebtn')
   	self.centernodebtn = GroupButtonBase:create( self.centernodebtn )

	self.centernodebtn:useBubbleAnimation()
    self.centernodebtn:setString("去补星")

    self.getRewardButton = self.centernodebtn

   	self.mcOpenSoon = GroupButtonBase:create( self.mcOpenSoon )

	self.mcOpenSoon:useBubbleAnimation()
    self.mcOpenSoon:setString("去补星")

    self.progresscirHalfcular = self.ui:getChildByPath('centerNode/progresscirHalfcular')
    self.progresscirHalfcular2 = self.ui:getChildByPath('centerNode/progresscirHalfcular2')
   	self.progresscircularbarbg = self.ui:getChildByPath('centerNode/progresscircularbarbg')

   	-- self.progresscirHalfcular:setVisible(false)
   	self.progresscircularbarbg:setVisible(false)


   	self:createMainProgressBar()

	local function onTabTaped( evt  )
		if self.isDisposed then return end
		self:popoutMoreStarPanel()
	end

	self.mcOpenSoon:addEventListener(DisplayEvents.kTouchTap, onTabTaped )

    self:updateUI()


    self.rewardHolder = self.ui:getChildByPath("centerNode/reward_holder")
    self.mcRewardFlashHolder = self.ui:getChildByPath('mc_reward_flash_holder')
    self:updateView()

    UIUtils:setTouchHandler(  self.rewardHolder , function ()
        self:showTips()
     end)
end

function StarAchievenmentPanel_DownBar:showTips(  )
	self.startipspos = self.ui:getChildByPath("startipspos")


	if self.rewardLevelToPushMeta then
		local delta = self.rewardLevelToPushMeta.starNum - self.curTotalStar
		if delta > 0 then
			-- local info = localize('star.reward.panel.reward.des.new', {num = delta })
			-- -- CommonTip:showTip( info , "negative")
			-- if _G.isLocalDevelopMode then printx(100, " delta = " , delta ) end
			-- local starDescpanel = UIHelper:createUI('ui/StarAchievenmentPanel/StarAchievenmentPanel_New.json', 'StarAchievenmentPanel_New/starDescpanel')

			-- local descPanel = starDescpanel:getChildByPath("desc")
			-- descPanel:setDimensions( CCSizeMake( 300 , 0) )
			-- descPanel:setString( info )
		--	showTip( self.rewardHolder :getGroupBounds(), starDescpanel )
			showTip( self.startipspos:getGroupBounds(), nil , delta )

		end
	end


end



function StarAchievenmentPanel_DownBar:createMainProgressBar(  )

	local fulleff = ArmatureNode:create( "StarAchievenmentPanel_New/fulleff" )
    fulleff:setPosition(ccp( 50, 0 ) )
    fulleff:playByIndex(0, 1)   
    fulleff:update(0.01)
    fulleff:playByIndex(0, 0)  
    fulleff:setVisible( true )

    self.fulleff = fulleff

	local spriteBarBG = Sprite:createWithSpriteFrameName("StarAchievenmentPanel_New/progresscircularbarbg0000")
	spriteBarBG:setAnchorPoint( ccp(0,1) )
	spriteBarBG:setPositionX( 0 )
	spriteBarBG:setPositionY( 3 )

 	
 	local spriteBar = self.ui:getChildByPath("centerNode/progresscirHalfcular")
 	spriteBar:removeFromParentAndCleanup(false)
 	local anchPoint = spriteBar:getAnchorPoint()
 		
 	spriteBar:setPositionX( 102 )
	spriteBar:setPositionY( -102 -12  )


	local clipNode = ClippingNode.new(CCClippingNode:create(spriteBarBG.refCocosObj))
	spriteBarBG:dispose()
	clipNode:setAlphaThreshold(0.1)
	clipNode:addChild(spriteBar)
	self.spriteBar = spriteBar



	local progress = 0.0
	local rotation = -180 + progress*180
	self.spriteBar:setRotation( rotation )



	self.clipNode = clipNode
	if progress < 0.5 then
		self.clipNode:setPosition( ccp( 8 , -5 ) )
	else
		self.clipNode:setPosition( ccp( 7 , -5 ) )
	end
	
	self.centerNode:addChild( self.clipNode )

	self.centerNode:addChild( fulleff )
	self.progresscirHalfcular2:removeFromParentAndCleanup(false)
	self.centerNode:addChildAt( self.progresscirHalfcular2 , self.centerNode:getChildIndex( self.clipNode ) + 1 )
end


-- 是否有足够星星数
function StarAchievenmentPanel_DownBar:isEnoughStar()
	if (not self.rewardLevelToPushMeta) then 
		if _G.isLocalDevelopMode then printx(99, "  isEnoughStar false 1") end
		return false
	end
	return self.curTotalStar >= self.rewardLevelToPushMeta.starNum
end

function StarAchievenmentPanel_DownBar:popoutMoreStarPanel()
	if self.isDisposed then return end

	if self.isOpenRecommend then return end

	DcUtil:clickMoreStarPanelBtn()
	
	self.isOpenRecommend = true

	local function closeCallBack( ... )
		if self.isDisposed then return end
		if _G.isLocalDevelopMode  then printx(99 , " closeCallBack  "  ) end
		self.isOpenRecommend = false
		self:onCloseBtnTapped()
	end 
	local function closeCallBack2( ... )
		if self.isDisposed then return end
		self.isOpenRecommend = false
	end 

	local panel = StarAchievenmentPanel_Recommend:create( closeCallBack )

	if panel:canPopout() then
		panel:setCloseCallBack2( closeCallBack2 )
		panel:popout()
	else
		self.isOpenRecommend = false
		panel:dispose()
		CommonTip:showTip(Localization:getInstance():getText("more.star.unlock.tip"), "negative")
	end
	
end

function  StarAchievenmentPanel_DownBar:createGetRewardFlashAnimation()

	local function seqCallback(sp)
		if _G.isLocalDevelopMode then printx(0, "seqCallback remove from parent ...----------") end
		sp:stopAllActions()
		sp:removeFromParentAndCleanup(true)
	end

	local a = CommonEffect:buildGetPropLightAnimWithoutBg()
	a:setCascadeOpacityEnabled(true)
	a:setScale(0.1)
	
	-- action1 is a sequence
	local delayAction = CCDelayTime:create(0.5)	
	local fadeAction = CCFadeOut:create(0.5)

	local s1Array = CCArray:create()
	s1Array:addObject(delayAction)
	s1Array:addObject(fadeAction)
	s1Array:addObject(CCCallFunc:create(
		    function()
			    return seqCallback(a)
			end
	))
	local s1Action = CCSequence:create(s1Array)

	-- action2
	local scaleToAction = CCScaleTo:create(0.2, 1)

	-- -------------- spawn -----------------
	local action = CCSpawn:createWithTwoActions(
		scaleToAction,
		s1Action)

	a:runAction(action)
	return a

	-- self.mcRewardFlashHolder:addChild(self:createGetRewardFlashAnimation())
end
function StarAchievenmentPanel_DownBar:getReward(...)
	if _G.isLocalDevelopMode then printx(99, "StarBasicInfoPanel:getReward") end

	-- local function onSendGetRewardMsgSuccess(event)
	-- 	self:caculateStarInfo()
	-- 	self:updateView(true)
	-- end

	local function onSendGetRewardMsgSuccess(event)
		-- @TBD delete
		if _G.isLocalDevelopMode then printx(99, "StarRewardPanel:ongetRewardButtonTapped Called ! onSendGetRewardMsgSuccess ") end
		if self.isDisposed then
			return
		end
		self.mcRewardFlashHolder:addChild(self:createGetRewardFlashAnimation())
		-- Play The Flying Reward Anim
		if _G.isLocalDevelopMode then printx(99, "StarRewardPanel:ongetRewardButtonTapped onSendGetRewardMsgSuccess Called !") end

		local function onAnimFinished()
			if self.isDisposed then return end
			local delay = CCDelayTime:create(0.5)
			local function removeSelf()
				self.getRewardButton:setEnabled(true)

				self:caculateStarInfo()
				self:updateView(true)

				-- 奖励领取变化，可能影响星星icon展现
				local scene = HomeScene:sharedInstance()
				if scene then
					if scene.starButton then 
						scene.starButton:updateView() 
					end
				end
			end
			local callAction = CCCallFunc:create(removeSelf)

			local seq = CCSequence:createWithTwoActions(delay, callAction)
			self:runAction(seq)
		end

		local anim = FlyItemsAnimation:create(event.data.rewardItems)
		local bounds = self.rewardItem.itemRes:getGroupBounds()
		anim:setWorldPosition(ccp(bounds:getMidX(),bounds:getMidY()))
		anim:setFinishCallback(onAnimFinished)
		local itemResScale = self.rewardItem.itemRes:getScale()
		itemResScale = 0.7
		anim:setScale(itemResScale)
		anim:play()

		--------------------------------------------------------
		-- number-decreasing animation
		--------------------------------------------------------
		local item = self.rewardItem
		local label = item.numberLabel
		local num = item.itemNumber
		local interval = 0.2 -- the same value from function HomeScene:createFlyToBagAnimation
		local function __decreaseNumber()
			if num >= 1 then
				num = num - 1
				if label and not label.isDisposed and label.refCocosObj then 
					label:setString('x'..num)
					if num == 0 then
						label:stopAllActions()
					end
				end
			end
		end
		local decrAction = CCSequence:createWithTwoActions(CCCallFunc:create(__decreaseNumber), CCDelayTime:create(interval))
		label:runAction(CCRepeat:create(decrAction, num))
	end

	local function onSendGetRewardMsgFail(evt)

		if self.isDisposed then
			return
		end

		self.getRewardButton:setEnabled(true)
		
		local code
		if evt and evt.data then code = tonumber(evt.data) end
		-- CommonTip, change error tip
		if code then 
			CommonTip:showTip(Localization:getInstance():getText("error.tip."..code), "negative")
			-- 已经领过奖，刷新到下一个			
			if (tonumber(code) == 730690) then
				self:caculateStarInfo()
				self:updateView(true)
			end
		else
			local networkType = MetaInfo:getInstance():getNetworkInfo();
			local errorCode = "-2";
			if networkType and networkType==-1 then 
				errorCode = "-6";
			end
			CommonTip:showTip(Localization:getInstance():getText("error.tip."..errorCode), "negative")
		end
		-- @TBD QQStarRewardPanel 224
		-- self:onSendGetRewardMsgFail(code) 
	end

	local function onSendGetRewardMsgCancel()
		if _G.isLocalDevelopMode then printx(99, "onSendGetRewardMsgCancel") end
		if self.isDisposed then
			return
		end

		self.getRewardButton:setEnabled(true)
	end

	if _G.isLocalDevelopMode then printx(99, "send SyncGetStarRewardLogic") end
	self.getRewardButton:setEnabled(false)
	if self.rewardLevelToPushMeta and self.rewardLevelToPushMeta.id then
		local rewardLevel = self.rewardLevelToPushMeta.id
		local metaValue = MetaManager.getInstance():starReward_getStarRewardMetaById( rewardLevel )
		if metaValue and metaValue.rewardString then
			DcUtil:clickGetStarRewardsLogic( metaValue.rewardString )
		end
		local logic	= GetStarRewardsLogic:create( rewardLevel )
		logic:setSuccessCallback(onSendGetRewardMsgSuccess)
		logic:setFailCallback(onSendGetRewardMsgFail)
		logic:setCancelCallback(onSendGetRewardMsgCancel)
		logic:start()	-- Default Show The Communicating Tip, And Block The Touch
	else


	end

end

function StarAchievenmentPanel_DownBar:ongetRewardButtonTapped(event)
	if _G.isLocalDevelopMode then printx(99, "StarBasicInfoPanel:ongetRewardButtonTapped") end

	if (__isQQ) then 
		return
	end

	if false == self.getRewardButton.isEnabled then
		return
	end

	if PrepackageUtil:isPreNoNetWork() then
		PrepackageUtil:showSettingNetWorkDialog()
		return 
	end

	-- if _G.isLocalDevelopMode then printx(99, "StarBasicInfoPanel:isEnoughStar = " ,self:isEnoughStar()) end

	if self.rewardLevelToPushMeta and not self:isEnoughStar() then
		-- self.getRewardButton:setEnabled(false)
		if _G.isLocalDevelopMode then printx(100, "ongetRewardButtonTapped: popoutMoreStarPanel " ) end
		self:popoutMoreStarPanel()
	else
		if _G.isLocalDevelopMode then printx(100, "ongetRewardButtonTapped: callFuncWithLogged " ) end
		RequireNetworkAlert:callFuncWithLogged(handler(self,self.getReward))
	end

end



function StarAchievenmentPanel_DownBar:passAllCheck()

	for level=1,kMaxLevels do
        local maxStar = 3

        local levelConfigData = MetaModel.sharedInstance():getLevelConfigData(level)
        if  levelConfigData  then
            local targetScores =  MetaModel.sharedInstance():getLevelTargetScores(level)
            if targetScores and #targetScores > 3 and targetScores[4] > 0 then
                maxStar = 4
            end
        else
            return false
        end
        local star = getStarWithLevelId( level )
        if star < maxStar then
            return false
        end
        
    end

    return true

end

function StarAchievenmentPanel_DownBar:updateView()

	local shouldShowFullLayer = true

	self.finishall:setVisible(false)

	if self.rewardLevelToPushMeta then
		-- 有奖励，但星星等级不够
		-- local delta = self.rewardLevelToPushMeta.starNum - self.curTotalStar
		-- if delta > 0 then
		-- 	-- self.getRewardButton:setString(Localization:getInstance():getText('mystar_getbutton_no',{num = delta}))
		-- 	self.getRewardButton:setString(Localization:getInstance():getText('more.star.btn.txt'))
		-- 	self.getRewardButton:setEnabled(true)
		-- 	self.getRewardButton.groupNode:stopAllActions()

		-- 	self:setStarLabelVisible(true)
		-- 	self.starLabel1:setString(Localization:getInstance():getText('再获得'))
		-- 	self.starLabel2:setString(delta)
		-- 	self.starLabel3:setString(Localization:getInstance():getText('颗星星可领取'))
		-- else
		-- 	self.getRewardButton:setString(Localization:getInstance():getText('mystar_getbutton_yes'))
		-- 	self.getRewardButton:setEnabled(true)
		-- 	self:setStarLabelVisible(false)
		-- end
		-- self.mcGetNone:setVisible(false)

		self.centerNode:setVisible(true)
		self.mcOpenSoon:setVisible(false)
		self.getRewardButton:addEventListener(DisplayEvents.kTouchTap, handler(self,self.ongetRewardButtonTapped))
	-- 没有奖励了
		shouldShowFullLayer = false
	else
		shouldShowFullLayer =true
		-- self.mcGetNone:setVisible(true)
		self.centerNode:setVisible(false)
		self.mcOpenSoon:setVisible(true)
		-- self.getRewardButton:setVisible(false)

		self.rewardHolder:getChildByName("itemPh"):setVisible(false)
		self.rewardHolder:getChildByName("numberLabel_fontSize"):setVisible(false)


		-- if (self.rewardItem) then 
		-- 	self.rewardItem.itemRes:setVisible(false)
		-- 	self.rewardItem.numberLabel:setVisible(false)
		-- end 
		
		-- self.getRewardButton:setString(Localization:getInstance():getText('mystar_getbutton_yes'))
		-- self.getRewardButton:setEnabled(false)
		-- self.getRewardButton.groupNode:stopAllActions()
		-- self:setStarLabelVisible(false)
	end

	if not self.starRewardNumTip then
		self.starRewardNumTip = getRedNumTip()
		self.starRewardNumTip:setPositionXY(140, 30)
		self.centernodebtn:getContainer():addChild( self.starRewardNumTip )
		local pScale = self.centernodebtn:getContainer():getScaleX()
		self.starRewardNumTip:setScale(1.0 / pScale )


	end

	self.starRewardNumTip:setNum(self.starRewardNum)
	
		-- 分子 
	local n = self.curTotalStar
	-- 分母
	local d = self.rewardLevelToPushMeta and self.rewardLevelToPushMeta.starNum or 0

	self.displayedN = n
	self.displayedD = d


	self:updateLeftNode( self.displayedN , self.displayedD )

	self:updateMainProgress( self.displayedN , self.displayedD )

	if self.rewardLevelToPushMeta then

		if (self.rewardItem) then 
			self.rewardItem:rebuild(self.rewardItemId, self.rewardItemCount)
		else
			self.rewardItem	= StarRewardItem3:create(self.rewardHolder, self.rewardItemId, self.rewardItemCount)
		end
	else

		
	end

	if self.rewardLevelToPushMeta and not self:isEnoughStar() then
		self.centernodebtn:setString("去补星")
	else
		self.centernodebtn:setString("领取")
	end

	if shouldShowFullLayer then
		shouldShowFullLayer = self:passAllCheck()
		if shouldShowFullLayer then
			self.finishall:setVisible(true)
			self.rightnode:setVisible(false)
			self.leftNode:setVisible(false)
			self.rightnode:setVisible(false)
			self.centerNode:setVisible(false)
			self.mcOpenSoon:setVisible(false)
			
		end

	end



end


function StarAchievenmentPanel_DownBar:updateUI()

	self.isgetReward = false
	if self.isgetReward == false then
		self.centernodebtn:setString("去补星")
	else
		self.centernodebtn:setString("领取")
	end

    

end



function StarAchievenmentPanel_DownBar:dispose( ... )

	FrameLoader:unloadArmature("skeleton/StarAchievenmentPanel_New/fulleff",true)

	BasePanel.dispose(self, ...)	-- body
end



