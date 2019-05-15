require "zoo.animation.FlowerNode"
local UIHelper = require 'zoo.panel.UIHelper'
---------------------------------------------------
---------------------------------------------------
-------------- TabHiddenLevel_New
---------------------------------------------------
---------------------------------------------------
local function parseTime(str, default)
    local pattern = "(%d+)-(%d+)-(%d+) (%d+):(%d+):(%d+)"
    local year, month, day, hour, min, sec = string.match(str, pattern)
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
assert(BaseUI)
TabHiddenLevel_New = class(BaseUI)

function TabHiddenLevel_New:create(ui,hostPanel , heightNode )
	local panel = TabHiddenLevel_New.new()
	panel:init(ui,hostPanel , heightNode )
	return panel
end

function TabHiddenLevel_New:init(ui,hostPanel , heightNode )
	self.hostPanel = hostPanel
	self.heightNode = heightNode - 20

	BaseUI.init(self, ui)

	self:initData()

	self:initUI()
end

function TabHiddenLevel_New:initData()
end

function TabHiddenLevel_New:initUI()
	-- local visibleSize = Director:sharedDirector():getVisibleSize()
	-- local size = self:getGroupBounds().size
	-- self:setScale(visibleSize.height/size.height)
	-- self.ui:getChildByName("content"):setAlpha(0)

	self.contentSize = self.ui:getGroupBounds().size
	self.contentSize = CCSizeMake(self.contentSize.width, self.contentSize.height)
end

function TabHiddenLevel_New:setVisible(value)
	BaseUI.setVisible(self,value)

	if (value == true) then 
		self:initContent()
	else
		self:removeContent()
	end
end

function TabHiddenLevel_New:getTimeCycleHour()
	local timeCycleHour
    local maintenance = MaintenanceManager:getInstance():getMaintenanceByKey("offlineTimeUnlockArea")
    if maintenance ~= nil then
    	local cfgHour = tonumber(maintenance.extra) or 12
    	timeCycleHour = cfgHour
    end
    timeCycleHour = timeCycleHour or 12
    return timeCycleHour
end

function TabHiddenLevel_New:initContent()
	self.ui:removeChildren()
	-- self.hostPanel.title_full_four_star:setVisible(false)
	-- self.hostPanel.title_full_hidden:setVisible(false)

	-- self.contentUI = UIHelper:createUI('ui/StarAchievenmentPanel/StarAchievenmentPanel_New.json', 'StarAchievenmentPanel_New/tabHiddenLevel_NewContent')
	-- self.ui:addChild(self.contentUI)

	-- self.hiddenLevelDataList = FourStarManager:getInstance():getAllHiddenLevels()
	-- if _G.isLocalDevelopMode then printx(100, " self.hiddenLevelDataList  " , table.tostring(self.hiddenLevelDataList ) ) end
	self.hiddenLevelGroupData={}
	self.timeStr = nil

			-- local branchData = {}
			-- branchData.branchId = index
			-- branchData.startNormalLevel = startLevel
			-- branchData.endNormalLevel = endLevel
			-- branchData.dependHideAreaId = tonumber(metaInfo.hideAreaId)
			-- branchData.startHiddenLevel = LevelMapManager.getInstance().hiddenNodeRange + startHiddenLevel
			-- branchData.endHiddenLevel = LevelMapManager.getInstance().hiddenNodeRange + endHiddenLevel
			-- branchData.x = calculateBranchPosX(index)
			-- branchData.y = calculateBranchPosY(index)
			-- branchData.hideReward = metaInfo.hideReward
	local scores = UserManager:getInstance():getScoreRef()

	local function isFullStarWithLevelIDs( minLevel,maxLevel )

		for k, v in ipairs(scores) do
			local levelId = tonumber(v.levelId)
			if levelId < 10000 and levelId <= kMaxLevels then
				if levelId>=minLevel and levelId<=maxLevel then
					if v.star < 3 then
						return false
					end
				end

			end 
		end

		return true
	end 


	self.lastCanplayIndex = 1
	local kMaxLevelsNode = NewAreaOpenMgr.getInstance():getCanPlayTopLevel()
	local hideUnlockConfig = MetaManager.getInstance():getHideUnlockTimeInfo()
	for k = 1 , kMaxLevelsNode/15 + 1 do 

		local endLevelId = k * 15
		local branchId = MetaModel:sharedInstance():getHiddenBranchIdByNormalLevelId(endLevelId)
		if branchId and not MetaModel:sharedInstance():isHiddenBranchDesign(branchId) then --已上线隐藏关
			local branchData = MetaModel:sharedInstance():getHiddenBranchDataByBranchId(branchId)
			
			if not branchData then
				break
			end

			local data = {}
			data.id = branchData.branchId
			data.startNormalLevel = branchData.startNormalLevel 
			data.endNormalLevel = branchData.endNormalLevel
			data.startHiddenLevel = branchData.startHiddenLevel 
			data.endHiddenLevel = branchData.endHiddenLevel
			data.isLocked = false
			data.isFullStar = false
			data.mainLevelIsFull = isFullStarWithLevelIDs( branchData.startNormalLevel ,branchData.endNormalLevel )


			data.isTopLevelArea = false
			for i,v in ipairs(hideUnlockConfig) do
				-- local data = {}
				-- data.id = v.id
				-- data.startTime = v.startTime
				-- data.continueLevels = v.continueLevels
				-- data.hideLevelRange = v.hideLevelRange
				-- data.unlockTime = os.time2(parseTime(v.startTime))
				-- data.checkState = getCheckState(v.id)
				-- table.insert(self.hideUnlockData, data)
				if data.id == v.id and v.startTime then
					local unlockTime = os.time2(parseTime(v.startTime))
					local now = Localhost:timeInSec()
					if unlockTime>now then
						data.isTopLevelArea = true
						data.areaUnlockTime = unlockTime
					end
				end
			end


			local canPlay,isFirstFlowerInHiddenBranch = UserManager:getInstance():isHiddenLevelCanPlay( data.startHiddenLevel )
			data.isLocked = not canPlay

			if canPlay then
				self.lastCanplayIndex = k
			end

			local starNum_Area = 0

			for hideLevelID = data.startHiddenLevel ,data.endHiddenLevel do
				local score = UserManager:getInstance():getUserScore( hideLevelID )
				if score and score.star > 0 then
					starNum_Area = starNum_Area + score.star
				end
			end
			if starNum_Area >= 9 then
				data.isFullStar = true
				data.isLocked = false
			end

			local hasIt = table.find(self.hiddenLevelGroupData , function ( dataNode )
				return dataNode.id == branchData.branchId
			end)
			if not hasIt then
				table.insert( self.hiddenLevelGroupData ,  data )
			end
			

			-- if branchData and branchData.endNormalLevel == endLevelId then
			-- 	for levelId=branchData.startHiddenLevel,branchData.endHiddenLevel do
			-- 		local score = UserManager:getInstance():getUserScore(levelId)

			-- 	end
			-- 	v.hideStar_total_amount = 9
			-- 	if not MetaModel:sharedInstance():isHiddenBranchCanOpen(branchId) then 
			-- 		v.isBranchOpen = false 
			-- 	end
			-- end

		end
	end

--	if _G.isLocalDevelopMode then printx(100, " self.hiddenLevelGroupData =  " , table.tostring( self.hiddenLevelGroupData ) ) end

	self:initHiddenLevelArea2018()

	-- if #FourStarManager:getInstance():getAllNotPerfectHiddenLevels() > 0 then
	-- 	self:initHiddenLevelArea()
	-- else
	-- 	-- self.hostPanel.title_full_hidden:setVisible(true)
	-- 	-- self.hostPanel.txtDesc:setString("")
	-- 	-- self.hostPanel.txtDesc4:setString( " " )
	-- 	self:initShareArea()
	-- end
	
	-- self.shareImagePath = HeResPathUtils:getResCachePath() .. "/share_image.jpg"

	-- DcUtil:UserTrack({
	-- 	category = "ui",
	-- 	sub_category = "click_hidden_chooselevel",
	-- },true)

end

function TabHiddenLevel_New:removeContent()
	self:stopCountDown()
 	self.ui:removeChildren()

end

-- =======================================

function TabHiddenLevel_New:initShareArea( ... )
	-- body
	self.contentUI:getChildByName("level_rect"):setVisible(false)

	local shareArea = self.contentUI:getChildByName("share_area")
	local shareBtn = GroupButtonBase:create(shareArea:getChildByName("btn"))
	shareBtn:setString(Localization:getInstance():getText("share.feed.button.achive"))

	local function onShareBtnTap( evt )
		-- body
		DcUtil:shareAllFourStarClick()
		self:onShareBtnTap()
	end
	shareBtn:addEventListener( DisplayEvents.kTouchTap , onShareBtnTap )

end

function TabHiddenLevel_New:createHiddenLevelNodeWithData( data  ,level_vertical_scrollable )




	-- local data = {}
	-- data.id = branchData.branchId
	-- data.startNormalLevel = branchData.startNormalLevel 
	-- data.endNormalLevel = branchData.endNormalLevel
	-- data.startHiddenLevel = branchData.startHiddenLevel 
	-- data.endHiddenLevel = branchData.endHiddenLevel
	-- data.isLocked = true
	-- data.isFullStar = false
	local bgName = "StarAchievenmentPanel_New/itemnodemainbg30000"
	if data.isLocked then
		bgName = "StarAchievenmentPanel_New/itemnodemainbg0000"
	elseif data.isFullStar then
		bgName = "StarAchievenmentPanel_New/itemnodemainbg20000"
	end


	local mainBG = Scale9Sprite:createWithSpriteFrameName( bgName ,CCRectMake(24,24,24,24) )
	mainBG:setAnchorPoint(ccp( 0 , 0 ))
	local animaWidth = 650 
	local animaHeight = 220
	mainBG:setPreferredSize(CCSizeMake(animaWidth, animaHeight))

	local function create4BitmapText( minLevel , maxLevel ,posX , posY , panel ,_color,shouldShowOffsetLabelPosy)

		if shouldShowOffsetLabelPosy then
    		posY = posY - 50
    	end

    	local textTable = {}
    	textTable[1] = BitmapText:create(  "第" , "fnt/register2.fnt")
    	textTable[2] = BitmapText:create(  "+"..minLevel.."" , "fnt/hud.fnt")
    	textTable[3] = BitmapText:create(  " ~ " , "fnt/register2.fnt")
    	textTable[4] = BitmapText:create(  "+"..maxLevel.."" , "fnt/hud.fnt")
    	textTable[5] = BitmapText:create(  "关" , "fnt/register2.fnt")


    	textTable[2]:setScale(1.2)
    	textTable[4]:setScale(1.2)

    	local totalWidth = 0

    	for i=1,#textTable do
    		local textNode = textTable[i]
    		totalWidth = totalWidth + textNode:getContentSize().width * textNode:getScale()
    	end

    	local leftPosX = posX - totalWidth/2 

    	for i=1,#textTable do
    		local textNode = textTable[i]
    		local leftNode = textTable[i-1]
    		textNode:setAnchorPoint(ccp(0.5,0.5))
    		local myPosX = leftPosX + textNode:getContentSize().width/2 * textNode:getScale()
    		if leftNode then
    			myPosX = leftNode:getPositionX() + leftNode:getContentSize().width/2 *leftNode:getScale() + textNode:getContentSize().width/2*textNode:getScale()
    		end
    		textNode:setPositionXY( myPosX , posY )
    		panel:addChild( textNode )
    		textNode:setColor(_color)
    	end
    	return textTable
    end 

    local function create4BitmapTextLock( minLevel , maxLevel ,posX , posY , panel ,_color , shouldShowOffsetLabelPosy )

    	if shouldShowOffsetLabelPosy then
    		posY = posY - 50
    	end

    	local textTable = {}
    	textTable[1] = BitmapText:create(  "第" , "fnt/register2.fnt")
    	textTable[2] = BitmapText:create(  ""..minLevel.."" , "fnt/hud.fnt")
    	textTable[3] = BitmapText:create(  " ~ " , "fnt/register2.fnt")
    	textTable[4] = BitmapText:create(  ""..maxLevel.."" , "fnt/hud.fnt")
    	textTable[5] = BitmapText:create(  "关全3星可解锁" , "fnt/register2.fnt")


    	textTable[2]:setScale(1.2)
    	textTable[4]:setScale(1.2)

    	local totalWidth = 0

    	for i=1,#textTable do
    		local textNode = textTable[i]
    		totalWidth = totalWidth + textNode:getContentSize().width * textNode:getScale()
    	end

    	local leftPosX = posX - totalWidth/2 

    	for i=1,#textTable do
    		local textNode = textTable[i]
    		local leftNode = textTable[i-1]
    		textNode:setAnchorPoint(ccp(0.5,0.5))
    		local myPosX = leftPosX + textNode:getContentSize().width/2 * textNode:getScale()
    		if leftNode then
    			myPosX = leftNode:getPositionX() + leftNode:getContentSize().width/2 *leftNode:getScale() + textNode:getContentSize().width/2*textNode:getScale()
    		end
    		textNode:setPositionXY( myPosX , posY )
    		panel:addChild( textNode )
    		textNode:setColor(_color)
    	end
    	return textTable
    end 


	-- local levelString = "第".. (data.startHiddenLevel-10000 ).."-".. (data.endHiddenLevel-10000) .."关"
	-- local text = BitmapText:create(  levelString , "fnt/register2.fnt")
 --    text:setAnchorPoint(ccp(0.5,0.5))
 --    text:setPositionXY( 650/2, 180 )
 --    mainBG:addChild( text )
 --    text:setColor(hex2ccc3('406CCD'))

    if data.isFullStar then
		local starsbg1 = Sprite:createWithSpriteFrameName("StarAchievenmentPanel_New/starsbg10000")
		mainBG:addChild( starsbg1 )
		starsbg1:setAnchorPoint(ccp(0,1))
		starsbg1:setPositionXY( 0, 220 )
    end

	local shouldShowOffsetLabelPosy = false

 	local userTopLevel = UserManager.getInstance().user:getTopLevelId()
 	if data.startNormalLevel > userTopLevel and data.isLocked then
 		shouldShowOffsetLabelPosy = true
 	end

    local allLabel = create4BitmapText( data.startHiddenLevel-10000 , data.endHiddenLevel-10000 , 650/2 , 180 ,mainBG ,hex2ccc3('406CCD') ,shouldShowOffsetLabelPosy )
    
	if data.isLocked then

		 
	    --蓝色
    	

	 --    levelString = "第"..data.startNormalLevel .."-".. data.endNormalLevel .."关全3星可解锁"
		-- local text2 = BitmapText:create(  levelString , "fnt/register2.fnt")
	 --    text2:setAnchorPoint(ccp(0.5,0.5))
	 --    text2:setPositionXY( 650/2, 140 )
	 --    mainBG:addChild( text2 )
	 --    text2:setColor(hex2ccc3('406CCD'))


	 	local allLabel2 = create4BitmapTextLock( data.startNormalLevel , data.endNormalLevel , 650/2 , 140 ,mainBG ,hex2ccc3('406CCD') ,shouldShowOffsetLabelPosy )
	    

	    local lock = Sprite:createWithSpriteFrameName("StarAchievenmentPanel_New/lockicon0000")
	    lock:setAnchorPoint(ccp(0.5,0.5))
	    lock:setScale(0.7)
	    if  shouldShowOffsetLabelPosy then
	    	lock:setPositionXY( 650/2 + 150 , 180 -50)
	    else
	    	lock:setPositionXY( 650/2 + 150 , 180  )
	    end
	    
	    mainBG:addChild( lock )

	    local goBtnLayer = UIHelper:createUI('ui/StarAchievenmentPanel/StarAchievenmentPanel_New.json', 'StarAchievenmentPanel_New/buttonLayer')

	    goBtn = GroupButtonBase:create( goBtnLayer:getChildByName("smallbtn") )
	    -- goBtn:removeFromParentAndCleanup(false)
	    mainBG:addChild( goBtnLayer )
	    -- goBtnLayer:dispose()

	    goBtn:useBubbleAnimation()
	    goBtn:setString("去闯关")

	    goBtnLayer:setPositionX( 650/2  )
	    goBtnLayer:setPositionY( 70 )
    	
	    goBtn:setVisible( userTopLevel >= data.startNormalLevel )

    	local endLevel = data.endNormalLevel

		local function onTabTaped( evt  )
			if self.isDisposed then return end
			if endLevel then
				DcUtil:clickFlowerNodeInStarAch( 1 , endLevel - 14 )
				HomeScene:sharedInstance().worldScene:moveNodeToCenter( endLevel- 8, false)
				self:onCloseBtnTapped()
			end
		end
		goBtn:addEventListener(DisplayEvents.kTouchTap, onTabTaped )
		if data.isTopLevelArea  and data.mainLevelIsFull then

			if allLabel2 then
    			for i=1,#allLabel2 do
		    		local textNode = allLabel2[i]
		    		textNode:setVisible(false)
		    	end
    		end

			goBtn:setVisible(false)

			self.leftUnlockTime = data.areaUnlockTime - Localhost:timeInSec()

			local function onTick()
	    		if self.isDisposed then return end
				if self.leftUnlockTime <= 0 then return end
	    	    self.leftUnlockTime = data.areaUnlockTime - Localhost:timeInSec()
				-- self.timeBar:setRate(1 - self.leftUnlockTime / cycleSec)
	    	    if self.leftUnlockTime >= 0 then
	    	        -- local timeStr = convertSecondToHHMMSSFormat(self.leftUnlockTime)

	    	        -- if _G.isLocalDevelopMode then printx(100, "timeStr  ==" , timeStr) end
	    	        -- if _G.isLocalDevelopMode then printx(100, "timeStr  ==" , timeStr) end
	    	        -- if _G.isLocalDevelopMode then printx(100, "timeStr  ==" , timeStr) end

	    	        

	    	        -- self.timeUnlockTxt:setText(timeStr)
	    	    end

	    	    if self.leftUnlockTime <= 0 then 
	    	    	-- self.timeUnlockTxt:setText("00:00:00")
	    	    	self.leftUnlockTime = 0
	    	    	self:stopCountDown()
	    	    end
	    	    self:createStringForLastNode_1(self.leftUnlockTime , mainBG )


	    	end

	    	if not self.doNotOnTick then
				self.oneSecondTimer = OneSecondTimer:create()
			    self.oneSecondTimer:setOneSecondCallback(function ()
			    	if self.isDisposed then return end
			        onTick()
			    end)
			    self.oneSecondTimer:start()
			    onTick()
			end

		end


    else

    	-- create4BitmapText( data.startHiddenLevel-10000 , data.endHiddenLevel-10000 , 650/2 , 180 ,mainBG ,hex2ccc3('406CCD') )

    	local key_Index = 1
    	for hideLevelID = data.startHiddenLevel ,data.endHiddenLevel do

			local flowerType = kFlowerType.kHidden
	        if JumpLevelManager.getInstance():hasJumpedLevel( hideLevelID ) then
	        	flowerType = kFlowerType.kJumped
	        end

			local cell_size = CCSizeMake(120, 135)

			local score = UserManager:getInstance():getUserScore( hideLevelID )
			local user_star = 0
			if score and score.star > 0 then
				user_star = score.star
			end

			local node = FlowerNodeUtil:createWithSize(flowerType, hideLevelID, user_star , cell_size,true)
			node.levelId = hideLevelID
			node:setTouchEnabled(true, 0, true)

			--QA非说没有居中，只好手动调一下

			-- local flowerNode = node.flowerNode
			-- if flowerNode and flowerNode.label and (not flowerNode.label.isDisposed) then
			-- 	flowerNode.label:setPositionX(flowerNode.label:getPositionX() - 4)
			-- end
			local context = self
			local function onTapped( evt )	

				if _G.isLocalDevelopMode then printx(100, "----------onTapped---------") end
				local pos = evt.globalPosition
				
				if node.scrollable and node.scrollable.touchLayer:hitTestPoint(pos) then
					local levelId = node.levelId

					if _G.isLocalDevelopMode then printx(100, "----------onTapped--------- levelId = " , levelId ) end

					local canPlay,isFirstFlowerInHiddenBranch = UserManager:getInstance():isHiddenLevelCanPlay(levelId)
					local isOnlineCheckHideLevel, areaId = NewAreaOpenMgr.getInstance():isOnlineCheckHideAreaLevel(levelId)
					if _G.isLocalDevelopMode then printx(0, "hiddenlevelId",levelId,isFirstFlowerInHiddenBranch) end
					if canPlay then
						local function onUnlockSuccess()
							context:onShowLevelStartPanel()
							DcUtil:clickFlowerNodeInStarAch( 1 , levelId)
							local startGamePanel = StartGamePanel:create(levelId, GameLevelType.kHiddenLevel)
						    startGamePanel:popout(false)
						end

						if isOnlineCheckHideLevel then 
							NewAreaOpenMgr.getInstance():hideAreaUnlockCheck(areaId, onUnlockSuccess, nil)
						else
							onUnlockSuccess()
						end
					else
						if MetaModel:sharedInstance():isAllLevelsTreeStarForHideArea(areaId) and 
							NewAreaOpenMgr.getInstance():isHideAreaCountdownIng(areaId) then 
							CommonTip:showTip(localize('当前隐藏关未到解锁时间哦~请稍后再试吧~'), 'negative')
						elseif isFirstFlowerInHiddenBranch then
							 local hideAreaMeta = MetaManager.getInstance():getHideAreaByHideLevelId(levelId)
							 local areaRangeStr = ""
							 if hideAreaMeta ~= nil then
							 	areaRangeStr = hideAreaMeta.continueLevels[1] .. "-" .. hideAreaMeta.continueLevels[#hideAreaMeta.continueLevels]
							 end
							CommonTip:showTip(Localization:getInstance():getText("hidlevel_tips1", {n = areaRangeStr}), 1)
						else
							CommonTip:showTip(Localization:getInstance():getText("hidlevel_tips2"), 1)
						end
					end
					DcUtil:UserTrack({
						category = "ui",
						sub_category = "click_see_hidden",
					},true)
				else
					-- if _G.isLocalDevelopMode then printx(0, "-------------------") end
				end
			end
			node:ad(DisplayEvents.kTouchTap, onTapped)

			node.scrollable = level_vertical_scrollable

			node:setPositionX( 650/4 * key_Index - 60 )
			node:setPositionY( 170 )
			mainBG:addChild( node )

			key_Index = key_Index + 1

		end


    	if data.isFullStar then
    		--黄色
    		if allLabel then
    			for i=1,#allLabel do
		    		local textNode = allLabel[i]
		    		textNode:setColor( hex2ccc3('DD9A51') )
		    	end
    		end
    		
    		local full_jiaobiao = Sprite:createWithSpriteFrameName("StarAchievenmentPanel_New/full_jiaobiao0000")
			mainBG:addChild( full_jiaobiao )
			full_jiaobiao:setAnchorPoint(ccp(1,0))
			full_jiaobiao:setPositionXY( 650 , 0 )


    	end


	end
	




	return mainBG
end


function TabHiddenLevel_New:createStringForLastNode_1( endTime ,panel )
	

	-- local now = Localhost:timeInSec()
	local deltaInSec = endTime

	local d = math.floor(deltaInSec / (3600 * 24))
	local h = math.floor(deltaInSec % (3600 * 24) / 3600)
	local m = math.floor(deltaInSec % (3600 * 24) % 3600 / 60)
	local s = math.floor(deltaInSec % (3600 * 24) % 3600 % 60)

	local isOver = deltaInSec <= 0
	local timeStr 
	if d > 0 then 
		timeStr = localize(string.format("%d天%d小时后开启", d, h))
	else
		timeStr = localize(string.format("%02d:%02d:%02d后开启", h, m, s))
	end
	-- timeStr = "倒计时 " .. timeStr
--	if _G.isLocalDevelopMode then printx(100, "createStringForLastNode_1 timeStr = " ,timeStr ) end
	if self.timeStr == timeStr then
		return
	end
	if not self.labelTable then
		self.labelTable = {}
	end
	for i=1,#self.labelTable do
		local labelNode = self.labelTable[i]
		labelNode:removeFromParentAndCleanup(true)
	end

    local textTable = {}
	-- textTable[1] = BitmapText:create(  "倒计时 (" , "fnt/register2.fnt")

	if d > 0 then 
		textTable[1] = BitmapText:create(  d.."" , "fnt/hud.fnt")
		textTable[2] = BitmapText:create(  "天" , "fnt/register2.fnt")
		textTable[3] = BitmapText:create(  h.."" , "fnt/hud.fnt")
		textTable[4] = BitmapText:create(  "小时后开启" , "fnt/register2.fnt")
		textTable[1]:setScale(1.2)
		textTable[3]:setScale(1.2)
	else
		local hString = h<10 and "0"..h or h
		local mString = m<10 and "0"..m or m
		local sString = s<10 and "0"..s or s
		textTable[1] = BitmapText:create(  hString.."" , "fnt/hud.fnt")
		textTable[2] = BitmapText:create(  ":" , "fnt/register2.fnt")
		textTable[3] = BitmapText:create(  mString.."" , "fnt/hud.fnt")
		textTable[4] = BitmapText:create(  ":" , "fnt/register2.fnt")
		textTable[5] = BitmapText:create(  sString.."" , "fnt/hud.fnt")
		textTable[6] = BitmapText:create(  "后开启" , "fnt/register2.fnt")

		textTable[1]:setScale(1.2)
		textTable[3]:setScale(1.2)
		textTable[5]:setScale(1.2)

	end

	local _color = hex2ccc3('406CCD')
	local posX = 650/2
	local posY = 85

	local totalWidth = 0

	for i=1,#textTable do
		local textNode = textTable[i]
		totalWidth = totalWidth + textNode:getContentSize().width * textNode:getScale()
	end

	local leftPosX = posX - totalWidth/2 

	for i=1,#textTable do
		local textNode = textTable[i]
		local leftNode = textTable[i-1]
		textNode:setAnchorPoint(ccp(0.5,0.5))
		local myPosX = leftPosX + textNode:getContentSize().width/2 * textNode:getScale()
		if leftNode then
			myPosX = leftNode:getPositionX() + leftNode:getContentSize().width/2 *leftNode:getScale() + textNode:getContentSize().width/2*textNode:getScale()
		end
		textNode:setPositionXY( myPosX , posY )
		panel:addChild( textNode )
		table.insert( self.labelTable , textNode )
		textNode:setColor(_color)
	end
	self.timeStr = timeStr
--	create7BitmapText( unlockTimeData.month , unlockTimeData.day , unlockTimeData.hour ,650/2 , y ,self ,hex2ccc3('406CCD') )
end

function TabHiddenLevel_New:stopCountDown()
	if self.oneSecondTimer then 
		self.oneSecondTimer:stop()
		self.oneSecondTimer = nil
	end

end

function TabHiddenLevel_New:initHiddenLevelArea2018( ... )
	
	if self.contentUI and self.contentUI:getChildByName("share_area") then
		self.contentUI:getChildByName("share_area"):setVisible(false)
	end

	local _width =  650 
	local _height = self.heightNode
	

	local level_vertical_scrollable = VerticalScrollable:create(_width, 
		_height, true, false)


	local layer = Layer:create()
	layer:setTouchEnabled(true, 0, false)
	local offset_x = nil
	local x_index = 3
	local cell_size = CCSizeMake(120, 135)
	local dataList = self.hiddenLevelDataList
	local context = self

	local borderX = 40
	local manualAdjustX = 10

	offset_x = (_width - x_index*cell_size.width - borderX*2) / (x_index - 1)

	local posY2NodeMap = {}


	for i = 1 , #self.hiddenLevelGroupData do
		local data = self.hiddenLevelGroupData[ i ]
		local hideLevelNode = self:createHiddenLevelNodeWithData( data , level_vertical_scrollable )
		layer:addChild( hideLevelNode )

		hideLevelNode:setPositionY(  - #self.hiddenLevelGroupData*220 + (i-1)*220 )
		posY2NodeMap[i] = hideLevelNode

		if i == #self.hiddenLevelGroupData  then
			if _G.isLocalDevelopMode then printx(100, "hiddenLevelGroupData", table.tostring(data) ) end
		end

	end

	local nodeNum = #self.hiddenLevelGroupData

	layer.getHeight = function(  )
		return 220 *  nodeNum   
	end


	level_vertical_scrollable:setContent(layer)
	self.ui:addChild(level_vertical_scrollable)

	local scrollViewOffset = 0
	if self.lastCanplayIndex  then
		scrollViewOffset = #self.hiddenLevelGroupData*220 - self.lastCanplayIndex * 220
	end
	
	local panelScale = self.hostPanel:getScale()

	-- if _G.isLocalDevelopMode then printx( 100, " scrollViewOffset = ", scrollViewOffset ) end
	layer.getHeight = function( self )
		return 220 / panelScale - #dataList
	end

	layer.updateViewArea = function ( _, top, bottom )
		local showDistance = bottom - top
        for key, node in pairs( posY2NodeMap ) do
            local nodePosY = node:getPositionY()
            nodePosY = math.abs( nodePosY )
            if math.abs(nodePosY -bottom ) < showDistance then
            	node:setVisible(true)
            else
            	node:setVisible(false)
            end
        end
	end

	level_vertical_scrollable:gotoPositionY( scrollViewOffset ,0)  

end


function TabHiddenLevel_New:initHiddenLevelArea( ... )
	self.contentUI:getChildByName("share_area"):setVisible(false)
	-- self.hostPanel.txtDesc:setString(Localization:getInstance():getText("mystar_tag_1.3"))
	-- if self.hostPanel.txtDesc4 then
	-- 	self.hostPanel.txtDesc4:setString(" ")
	-- end
	local level_node_area = self.contentUI:getChildByName("level_rect")
	local rect_replace = level_node_area:getChildByName("level_rect")
	rect_replace:setVisible(false)
	local size = rect_replace:getGroupBounds().size

	-- if _G.isLocalDevelopMode then printx(0, "=====================>>>>>>>>>>>>",size.width,size.height) end
	-- local panelScale = self.hostPanel:getScale()
	local panelScale = self.hostPanel:getScale()
	local _width = size.width/panelScale	-- 缩放前，原始的宽高
	local _height = size.height/panelScale


	---星星面板换素材
	_width = self.contentSize.width / panelScale / level_node_area:getScaleX()
	_height = self.contentSize.height / panelScale / level_node_area:getScaleY()
	---星星面板换素材

	local pos = rect_replace:getPosition()
	local z_orde = self.contentUI:getChildIndex(rect_replace)
	local level_vertical_scrollable = VerticalScrollable:create(_width, 
		_height, true, false)
	-- local level_vertical_scrollable = VerticalScrollable:create(_width, 580, true, false)

	-- self.contentUI:addChildAt(level_vertical_scrollable, z_orde)
	level_node_area:addChild(level_vertical_scrollable)
	level_vertical_scrollable:setPosition(ccp(pos.x, pos.y))

	if _G.isLocalDevelopMode then printx(0, "~~VerticalScrollable~~",size.width,size.height,_width,_height,panelScale) end
	if _G.isLocalDevelopMode then printx(0, "VerticalScrollable pos",pos.x,pos.y,panelScale) end

	local layer = Layer:create()
	layer:setTouchEnabled(true, 0, false)
	local offset_x = nil
	local x_index = 3
	local cell_size = CCSizeMake(120, 135)
	local dataList = self.hiddenLevelDataList
	local context = self

	local borderX = 40
	local manualAdjustX = 10

	offset_x = (_width - x_index*cell_size.width - borderX*2) / (x_index - 1)

	local posY2NodeMap = {}



	-- 摆放节点
	for k = 1, #dataList do 
		local data = dataList[k]

        local flowerType = kFlowerType.kHidden
        if JumpLevelManager.getInstance():hasJumpedLevel( data.level ) then
        	flowerType = kFlowerType.kJumped
        end
		-- local ui = self.builder:buildGroup("more_star_flower_item")
		-- FourStarGuideLevelNode:create(ui, data.level, data.star, self)
		local node = FlowerNodeUtil:createWithSize(flowerType, data.level, data.star, cell_size,true)
		node.levelId = data.level
		node:setTouchEnabled(true, 0, true)

		--QA非说没有居中，只好手动调一下

		local flowerNode = node.flowerNode
		if flowerNode and flowerNode.label and (not flowerNode.label.isDisposed) then
			flowerNode.label:setPositionX(flowerNode.label:getPositionX() - 4)
		end
		
		local function onTapped( evt )	
			local pos = evt.globalPosition
			if node.scrollable and node.scrollable.touchLayer:hitTestPoint(pos) then
				local levelId = node.levelId

				local canPlay,isFirstFlowerInHiddenBranch = UserManager:getInstance():isHiddenLevelCanPlay(levelId)
				local isOnlineCheckHideLevel, areaId = NewAreaOpenMgr.getInstance():isOnlineCheckHideAreaLevel(levelId)
				if _G.isLocalDevelopMode then printx(0, "hiddenlevelId",levelId,isFirstFlowerInHiddenBranch) end
				if canPlay then
					local function onUnlockSuccess()
						context:onShowLevelStartPanel()
						local startGamePanel = StartGamePanel:create(levelId, GameLevelType.kHiddenLevel)
					    startGamePanel:popout(false)
					end

					if isOnlineCheckHideLevel then 
						NewAreaOpenMgr.getInstance():hideAreaUnlockCheck(areaId, onUnlockSuccess, nil)
					else
						onUnlockSuccess()
					end
				else
					if MetaModel:sharedInstance():isAllLevelsTreeStarForHideArea(areaId) and 
						NewAreaOpenMgr.getInstance():isHideAreaCountdownIng(areaId) then 
						CommonTip:showTip(localize('当前隐藏关未到解锁时间哦~请稍后再试吧~'), 'negative')
					elseif isFirstFlowerInHiddenBranch then
						 local hideAreaMeta = MetaManager.getInstance():getHideAreaByHideLevelId(levelId)
						 local areaRangeStr = ""
						 if hideAreaMeta ~= nil then
						 	areaRangeStr = hideAreaMeta.continueLevels[1] .. "-" .. hideAreaMeta.continueLevels[#hideAreaMeta.continueLevels]
						 end
						CommonTip:showTip(Localization:getInstance():getText("hidlevel_tips1", {n = areaRangeStr}), 1)
					else
						CommonTip:showTip(Localization:getInstance():getText("hidlevel_tips2"), 1)
					end
				end
				DcUtil:UserTrack({
					category = "ui",
					sub_category = "click_see_hidden",
				},true)
			else
				-- if _G.isLocalDevelopMode then printx(0, "-------------------") end
			end
		end
		node:ad(DisplayEvents.kTouchTap, onTapped)

		if not x_index then
			-- cell_size = node:getGroupBounds().size
			x_index = math.floor(_width/cell_size.width)
			offset_x = (_width - x_index*cell_size.width) / (x_index - 1)
		end
		local x_p = ((k- 1)%x_index ) * (cell_size.width + offset_x) -0
		node:setPositionX(manualAdjustX + borderX + x_p)
		local y_p = (-math.floor((k-1)/x_index)*cell_size.height)
		node:setPositionY(y_p)

		local y_index = math.floor(y_p + 0.5)
		posY2NodeMap[y_index] = posY2NodeMap[y_index] or {}
		table.insert(posY2NodeMap[y_index], node)

		node.scrollable = level_vertical_scrollable
		layer:addChild(node)

	end
	layer.getHeight = function( self )
		return self:getGroupBounds().size.height / panelScale - #dataList
	end
	layer.updateViewArea = function ( _, top, bottom )
		
		for y_index, nodeGrp in pairs(posY2NodeMap) do
			local v = true
			if -y_index >= top - cell_size.height - 20 and -y_index <= bottom + cell_size.height + 20 then
				v = true
			else
				v = false
			end

			for _, node in pairs(nodeGrp) do
				if node.isDisposed then return end
				node:setVisible(v)
			end
		end

	end
	level_vertical_scrollable:setContent(layer)

end

-- function TabHiddenLevel_New:popout( ... )
-- 	-- body
-- 	self.allowBackKeyTap = true
-- 	local curScene = Director:sharedDirector():getRunningScene()
-- 	local vSize = Director:sharedDirector():getVisibleSize()
-- 	local visibleOrigin = Director:sharedDirector():getVisibleOrigin()
-- 	local layer = LayerColor:create()
-- 	layer:setContentSize(vSize)
-- 	layer:setColor(ccc3(0,0,0))
-- 	layer:setOpacity(200)
-- 	layer:setPosition(visibleOrigin)
-- 	curScene:addChild(layer, SceneLayerShowKey.POP_OUT_LAYER)
-- 	self.bgLayer = layer
-- 	PopoutManager:sharedInstance():add(self, false, false)
-- end

function TabHiddenLevel_New:onShowLevelStartPanel( ... )
	-- body
	self:dispatchEvent(Event.new(FourStarGuideEvent.kCloseAllStarGuidePanel))
	self:onCloseBtnTapped()
end

function TabHiddenLevel_New:onCloseBtnTapped( ... )
	-- -- body
	-- PopoutManager:sharedInstance():remove(self, true)
	-- if self.bgLayer then 
	-- 	self.bgLayer:removeFromParentAndCleanup(true)
	-- end
	-- self.allowBackKeyTap = false
	self.hostPanel:onCloseBtnTapped()
end

function TabHiddenLevel_New:onShareBtnTap( ... )
	-- body
	self:screenShotShareImage()
	local thumb = CCFileUtils:sharedFileUtils():fullPathForFilename("materials/wechat_icon.png")
	local shareCallback = {
		onSuccess = function(result)
			self:onShareSucceed()
		end,
		onError = function(errCode, errMsg)
			self:onShareFailed()
		end,
		onCancel = function()
			self:onShareFailed()
		end,
	}
	local shareType, delayResume = SnsUtil.getShareType()
	SnsUtil.sendImageMessage( shareType, nil, nil, thumb, self.shareImagePath, shareCallback )
end

function TabHiddenLevel_New:screenShotShareImage( ... )
	-- body
	local ui = self.contentUI:getChildByName("share_area")
	if self.share_background ~= nil then
		return 
	end

	self.share_background = Sprite:create("share/share_background.png")
	local size = self.share_background:getContentSize()

	if _G.__use_small_res == true then
		self.share_background:setScale(0.625)
		size.width = size.width * 0.625
		size.height = size.height * 0.625
	end

	local btn = ui:getChildByName("btn")
	btn:setVisible(false)
	local branch = ui:getChildByName("branch")
	-- branch:setVisible(false)

	self.share_background:setAnchorPoint(ccp(0,0))
	self.share_background:setPosition(ccp(0, 0))
	ui:addChildAt(self.share_background, 0)

	local bg_2d = ShareUtil:getQRCodePath()
	self.share_background_2d = Sprite:create(bg_2d)
	ui:addChild(self.share_background_2d)
	local size_2d = self.share_background_2d:getContentSize()
	self.share_background_2d:setPosition(
		ccp(size.width - size_2d.width/2 - 5, size.height - size_2d.height/2 - 5))

	local pic = ui:getChildByName("pc")
	-- local pos_o = pic:getPosition()
	local pos_o =  ccp(pic:getPositionX(), pic:getPositionY())
	local pos_branch_o = ccp(branch:getPositionX(),branch:getPositionY())

	local size_pic = pic:getGroupBounds(pic:getParent()).size
	local x = size.width - size_pic.width
	local y = size.height - size_pic.height
	pic:setPosition(ccp(x/2, size.height -y/2 - 90))
	-- pic:setPosition(ccp(x/2, 150))

	branch:setPosition(ccp(0,pic:getPositionY()+220))


	local ui_o_pos = ccp(ui:getPositionX(), ui:getPositionY())
	-- if _G.isLocalDevelopMode then printx(0, ">>>>>>>>> save >>>>>>>>>>>>>>>",ui_o_pos.x,ui_o_pos.y,pos_o.x,pos_o.y,ui.anchorX,ui.anchorY,pic.anchorX,pic.anchorY) end
	ui:setPosition(ccp(0, 0))
	local renderTexture = CCRenderTexture:create(size.width, size.height)
	renderTexture:begin()
	ui:visit()
	renderTexture:endToLua()
	renderTexture:saveToFile(self.shareImagePath)
	--复原
	-- if _G.isLocalDevelopMode then printx(0, ">>>>>>>>> load >>>>>>>>>>>>>>>",ui_o_pos.x,ui_o_pos.y,pos_o.x,pos_o.y,ui.anchorX,ui.anchorY,pic.anchorX,pic.anchorY) end
	ui:setPosition(ui_o_pos)
	pic:setPosition(pos_o)
	branch:setPosition(pos_branch_o)

	self.share_background:setVisible(false)
	self.share_background_2d:setVisible(false)
	
	btn:setVisible(true)
	branch:setVisible(true)
end

function TabHiddenLevel_New:onShareFailed( ... )
	-- body
	local scene = Director:sharedDirector():getRunningScene()
	if scene then
		local shareFailedLocalKey = "share.feed.faild.tips"
		if PlatformConfig:isPlatform(PlatformNameEnum.kMiTalk) then
	 		shareFailedLocalKey = "share.feed.faild.tips.mitalk" 
	 	end
		CommonTip:showTip(Localization:getInstance():getText(shareFailedLocalKey), 'negative', nil, 2)
	end
end

function TabHiddenLevel_New:onShareSucceed( ... )
	-- body
	if PlatformConfig:isPlatform(PlatformNameEnum.kMiTalk) then
 		SnsUtil.showShareSuccessTip(PlatformShareEnum.kMiTalk) 
 	else
 		SnsUtil.showShareSuccessTip(PlatformShareEnum.kWechat)
 	end
end