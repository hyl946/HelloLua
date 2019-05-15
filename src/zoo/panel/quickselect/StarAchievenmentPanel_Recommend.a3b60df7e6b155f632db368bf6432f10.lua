require 'zoo.panel.basePanel.BasePanel'
local UIHelper = require 'zoo.panel.UIHelper'

local winSize = Director:sharedDirector():getWinSize()
local visibleSize = CCDirector:sharedDirector():getVisibleSize()

---------------------------------------------------
---------------------------------------------------
-------------- StarAchievenmentPanel_Recommend
---------------------------------------------------
---------------------------------------------------

local titleStringTable = {}
titleStringTable[1] = "好友代打及跳过关卡"
titleStringTable[2] = "本区域未满星"
titleStringTable[3] = "未满三星"
titleStringTable[4] = "未满四星"
	
local HIDE_LEVEL_ID_START = 10000
	

local function hasAskForHelpTab()
	local info = UserManager.getInstance():getAskForHelpInfo()
	if info and table.size(info) > 0 then
		return true
	end
	return false
end

StarAchievenmentPanel_Recommend = class(BasePanel)


function StarAchievenmentPanel_Recommend:canPopout()

	return self.levelNum > 0 
end

function StarAchievenmentPanel_Recommend:create( closeCallBack )
	local panel = StarAchievenmentPanel_Recommend.new()
	panel.closeCallBack = closeCallBack
	panel:init()
	return panel

end


function StarAchievenmentPanel_Recommend:setCloseCallBack2( closeCallBack2 )
	self.closeCallBack2 = closeCallBack2
end
function StarAchievenmentPanel_Recommend:init()
	
	local ui = UIHelper:createUI('ui/StarAchievenmentPanel/StarAchievenmentPanel_New.json', 'StarAchievenmentPanel_New/StarAchievenmentPanel_Recommend')
    self.ui = ui
	BasePanel.init(self, ui, "StarAchievenmentPanel_Recommend")

	self.levelnode1 = self.ui:getChildByPath('levelnode1')
	self.levelnode2 = self.ui:getChildByPath('levelnode2')

	self.levelnode1:setVisible(false)
	self.levelnode2:setVisible(false)



	UIUtils:setTouchHandler(  self.ui:getChildByName('closebtn2') , function ()
        self:onCloseBtnTapped(  )
     end)

	self.mainbg4 = self.ui:getChildByPath('mainbg4')
	self.mainbg3 = self.ui:getChildByPath('mainbg3')
	self.maindesc = self.ui:getChildByPath('maindesc')
	self.maintitle3 = self.ui:getChildByPath('maintitle3')


	self.maindesc:setString( "点击关卡花可去闯关哦~" )


	local askForHelpAndJumpLevels , areaLevels , star4Levels , normalLevels , kindOfLevels ,tableCopy ,titleIndex = self:getAllLevelsData()
	self:checkLevelData( askForHelpAndJumpLevels , areaLevels , star4Levels, normalLevels  )
	kindOfLevels = 0
	if #askForHelpAndJumpLevels > 0 then
		kindOfLevels = kindOfLevels + 1
		tableCopy = askForHelpAndJumpLevels
		titleIndex = 1 
	end
	if #areaLevels > 0 then
		kindOfLevels = kindOfLevels + 1
		tableCopy = areaLevels
		titleIndex = 2
	end

	if #normalLevels > 0 then
		kindOfLevels = kindOfLevels + 1
		tableCopy = normalLevels
		titleIndex = 3
	end

	if #star4Levels > 0 then
		kindOfLevels = kindOfLevels + 1
		tableCopy = star4Levels
		titleIndex = 4
	end

	self.levelNum = #askForHelpAndJumpLevels + #areaLevels + #star4Levels + #normalLevels

	if kindOfLevels == 1 then
		local isTen = false
		if #tableCopy >5 then
			isTen = true
		end
		local titleString = nil
		if titleIndex and titleStringTable[titleIndex] then
			titleString = titleStringTable[titleIndex]
		end

		local oneNode , height = self:createOneNodeWithData( tableCopy , true ,titleString )
		self.ui:addChild( oneNode )
		oneNode:setPositionY( -90 )

		self:updateUIWithInnerHeight( height )

	else

		local height_Total = 0

		local offsetY = -90

		if #askForHelpAndJumpLevels>0 then
			local oneNode , height = self:createOneNodeWithData( askForHelpAndJumpLevels , false , titleStringTable[1] )
			self.ui:addChild( oneNode )
			oneNode:setPositionY( -height_Total +offsetY )
			height_Total = height_Total + height
			
		end
		
		if #areaLevels>0 then
			local oneNode , height = self:createOneNodeWithData( areaLevels , false , titleStringTable[2] )
			self.ui:addChild( oneNode )
			oneNode:setPositionY( -height_Total +offsetY )
			height_Total = height_Total + height
			
		end
		if #normalLevels>0 then
			local oneNode , height = self:createOneNodeWithData( normalLevels , false , titleStringTable[3] )
			self.ui:addChild( oneNode )
			oneNode:setPositionY( -height_Total +offsetY )
			height_Total = height_Total + height
			
		end
		if #star4Levels>0 then
			local oneNode , height = self:createOneNodeWithData( star4Levels , false , titleStringTable[4] )
			self.ui:addChild( oneNode )
			oneNode:setPositionY( -height_Total +offsetY )
			height_Total = height_Total + height
			
		end

		self:updateUIWithInnerHeight( height_Total )

	end

	

end

function StarAchievenmentPanel_Recommend:getVCenterInScreenY(...)
	assert(#{...} == 0) 

	local visibleSize	= CCDirector:sharedDirector():getVisibleSize()
	local visibleOrigin	= CCDirector:sharedDirector():getVisibleOrigin()
	local selfHeight	= self.mainbgHeight  

	local deltaHeight	= visibleSize.height - selfHeight
	local halfDeltaHeight	= deltaHeight / 2

	return visibleOrigin.y + halfDeltaHeight + selfHeight
end

function StarAchievenmentPanel_Recommend:updateUIWithInnerHeight( innerHeight )
		
		
	local offsetY = 200

	if self.mainbg4 then
		self.mainbg4:setContentSize( CCSizeMake( self.mainbg4:getContentSize().width,  innerHeight + offsetY - 120 ) )
		self.mainbg4:setAnchor(ccp(0,1))
		self.mainbg4:setPositionX( 19 )
		self.mainbg4:setPositionY( -74 )
	end

	if self.mainbg3 then
		self.mainbg3:setAnchor(ccp(0,1))
		self.mainbg3:setContentSize( CCSizeMake( self.mainbg3:getContentSize().width ,  innerHeight + offsetY ) )
		self.mainbgHeight = innerHeight + offsetY
	end

	if self.maintitle3 then
		self.maintitle3:setAnchor(ccp(0,1))
		self.maintitle3:setPositionY( 0 )
	end
	if self.maindesc then
		self.maindesc:setPositionY( -innerHeight - offsetY + 45 )
	end
	-- self.hit_area = self.ui:getChildByPath('hit_area')
	-- if self.hit_area then
	-- 	self.hit_area:setAnchor(ccp(0,1))
	-- 	self.hit_area:setContentSize( CCSizeMake( self.mainbg3:getContentSize().width ,  innerHeight + offsetY ) )
	-- end

	self:scaleAccordingToResolutionConfig()
    self:setPositionForPopoutManager()

end


function StarAchievenmentPanel_Recommend:createFlowerOneLine( tableData )
	local flowerLine = Layer:create()
		
	local distanve = 600 / (#tableData + 1)

	for i=1,#tableData do

		local levelId = tableData[i]

		local levelStar = self:getStarWithLevelId( levelId )

		local shouldShowStar4 = self:shouldShowStar4( levelId )
		local flowerType = kFlowerType.kNormal
	    if JumpLevelManager.getInstance():hasJumpedLevel( levelId ) then
	        flowerType = kFlowerType.kJumped
	    end
	    if UserManager:getInstance():hasAskForHelpInfo( levelId ) then
	        flowerType = kFlowerType.kAskForHelp
	    end
	    if levelId > HIDE_LEVEL_ID_START then
	        flowerType = kFlowerType.kHidden
	    end
	    if shouldShowStar4 == true then
	        flowerType = kFlowerType.kFourStar
	    end
	    local cell_size = CCSizeMake(150, 160)

		local node = FlowerNodeUtil:createWithSize(flowerType, levelId , levelStar , cell_size,true)
	    node.levelId = levelId
	    node:setTouchEnabled(true, 0, true)

	    local function onTapped( evt )  

	        if self.isDisposed then return end
	        local levelIdNode = node.levelId
	            
	        -- if _G.isLocalDevelopMode  then printx(0 , " onTapped  levelIdNode = " , levelIdNode ) end
	        self:closeAll()
            HomeScene:sharedInstance().worldScene:moveNodeToCenter(levelIdNode, function ( ... )
	            local levelType = GameLevelType.kMainLevel
	            if levelIdNode > HIDE_LEVEL_ID_START then
	                levelType = GameLevelType.kHiddenLevel
	            end
	            if not PopoutManager:sharedInstance():haveWindowOnScreen() and not HomeScene:sharedInstance().ladyBugOnScreen then
	                if levelIdNode ~= nil and levelIdNode > 0 then
	                    local startGamePanel = StartGamePanel:create(levelIdNode, levelType)
	                    startGamePanel:popout(false)
	                end
	            end
            end)
	        
	    end

	    node:ad(DisplayEvents.kTouchTap, onTapped)

	    node:setPositionX( distanve + distanve*(i-1) )

	    flowerLine:addChild( node )
	end


	if _G.isLocalDevelopMode  then printx(0 , " createFlowerOneLine = " , table.tostring(tableData) ) end

	flowerLine:setPositionX(0)
	return flowerLine
end

function StarAchievenmentPanel_Recommend:updateProgress( )
	
	
	
end

function StarAchievenmentPanel_Recommend:createOneNodeWithData( tableData ,isTen ,titleString )
	if not isTen then
		isTen = false
	end
	local ui = UIHelper:createUI('ui/StarAchievenmentPanel/StarAchievenmentPanel_New.json', 'StarAchievenmentPanel_New/levelinfonode2')
	local height = 235
	if #tableData> 5 and isTen then
		ui = UIHelper:createUI('ui/StarAchievenmentPanel/StarAchievenmentPanel_New.json', 'StarAchievenmentPanel_New/levelinfonode2')

		local table1 = {}
		local table2 = {}

		for i=1,#tableData do

			local value = tableData[i]
			if #table1 <5 then
				table.insert(table1 ,value )
			elseif #table2 <5 then
				table.insert(table2 ,value )
			end
		end

		local oneLine = self:createFlowerOneLine( table1 )
		oneLine:setPositionX( -48 )
		oneLine:setPositionY( -40 )
		ui:addChild( oneLine )

		oneLine = self:createFlowerOneLine( table2 )
		oneLine:setPositionX( -48 )
		oneLine:setPositionY( -210 )
		ui:addChild( oneLine )

		height = 420
	else
		local table1 = {}
		for i=1,#tableData do
			local value = tableData[i]
			if i <=5 then
				table.insert(table1 ,value )
			end
		end

		ui = UIHelper:createUI('ui/StarAchievenmentPanel/StarAchievenmentPanel_New.json', 'StarAchievenmentPanel_New/levelinfonode1')
		local oneLine = self:createFlowerOneLine( table1 )
		oneLine:setPositionX( -48 )
		oneLine:setPositionY( -40 )
		ui:addChild( oneLine )
	end

	if titleString then
		ui:getChildByName("title"):setString( titleString )
	end

	return ui , height

end

function StarAchievenmentPanel_Recommend:popoutShowTransition()

	if self.isDisposed then return end
	 
	-- local winSize = CCDirector:sharedDirector():getVisibleSize()
	-- local w = 665
	-- local h = 1048
	-- local r = winSize.height / h
	-- if r < 1.0 then
	-- 	self:setScale(r)
	-- end

	-- local x = self:getHCenterInParentX()
	-- local y = self:getVCenterInParentY()
	-- self:setPosition(ccp(x, y))



end

function StarAchievenmentPanel_Recommend:closeAll(  )
	if self.isDisposed then return end

	PopoutManager:sharedInstance():remove( self , true )



	if self.closeCallBack then
		self.closeCallBack()
	end

	

end

function StarAchievenmentPanel_Recommend:onCloseBtnTapped(  )
	if self.isDisposed then return end

	if self.closeCallBack2 then
		self.closeCallBack2()
	end

	PopoutManager:sharedInstance():remove(self, true)
	
end

function StarAchievenmentPanel_Recommend:popout()

    self:scaleAccordingToResolutionConfig()
    self:setPositionForPopoutManager()
    self:setPositionX(self:getPositionX() + 0)
	PopoutManager:sharedInstance():add(self, true)
	self.allowBackKeyTap = true

end


function StarAchievenmentPanel_Recommend:dispose( ... )
	BasePanel.dispose(self, ...)	-- body
end


function StarAchievenmentPanel_Recommend:isMyArea( levelId )
	
	local max_unlock_area = math.ceil(UserManager.getInstance().user:getTopLevelId() / 15)
	local nowarea = math.ceil( levelId / 15)

	if max_unlock_area == nowarea and self:starIsNotEnough(levelId) then
		return true
	end
	return false

end

function StarAchievenmentPanel_Recommend:getLevelConfigData(levelId, ...)

	local levelMeta = LevelMapManager.getInstance():getMeta(levelId)
	if levelMeta then return levelMeta end
	return nil
end

function StarAchievenmentPanel_Recommend:getLevelTargetScores(levelId, ...)

	local levelConfigData = self:getLevelConfigData(levelId)

	if levelConfigData ==nil then
		if _G.isLocalDevelopMode  then printx(0 , "StarAchievenmentPanel_Recommend getLevelTargetScores levelConfigData is a nil value " , levelId ) end
		return nil
	end
	local targetScores = levelConfigData:getScoreTargets()

	return targetScores
end


function StarAchievenmentPanel_Recommend:getStarWithLevelId( levelIdNode )

	if levelIdNode==nil or levelIdNode == 0 then
		return 0
	end

	local scoreOfLevel = UserManager:getInstance():getUserScore(levelIdNode)
	if scoreOfLevel then
		if scoreOfLevel.star ~= 0 or 
			JumpLevelManager:getLevelPawnNum(levelIdNode) > 0 or 
			UserManager:getInstance():hasAskForHelpInfo(levelIdNode) then 
			if scoreOfLevel.star ==nil then
				return 0
			else
				return scoreOfLevel.star or 0
			end
		end
	else
		return 0 
	end
	return scoreOfLevel.star or 0 

end 

function StarAchievenmentPanel_Recommend:starIsNotEnough(levelId)

	local maxStar = 3
	local targetScores =  self:getLevelTargetScores( levelId )
	if targetScores and #targetScores > 3 and targetScores[4] > 0 then
		maxStar = 4
	end
	local star = self:getStarWithLevelId( levelId )
	return maxStar > star

end

function StarAchievenmentPanel_Recommend:shouldShowStar4(levelId)

	if levelId ==nil or levelId <= 0 then
		return false
	end
	local star = self:getStarWithLevelId( levelId )
	local isStar4Level = false
	local targetScores =  self:getLevelTargetScores( levelId )
	if targetScores and #targetScores > 3 and targetScores[4] > 0 then
		isStar4Level = true
	end
	if isStar4Level and star == 3 then
		return true
	end
	return false

end


function StarAchievenmentPanel_Recommend:checkLevelData( askForHelpAndJumpLevels2 , areaLevels2 , star4Levels2 , normalLevels2   )
	
	
	local askForHelpAndJumpLevels = {}
	local areaLevels = {}

	local star4Levels = {}
	local normalLevels = {}

	local function table_Insert( tableNode , levelID_Innset ,res1,res2,res3 )
		if not tableNode then
			return
		end
		if not levelID_Innset then
			return
		end
		local hasIt = table.find( tableNode ,function ( levelIdNode )
			return levelIdNode == levelID_Innset
		end)

		local hasIt1 = table.find( res1 ,function ( levelIdNode )
			return levelIdNode == levelID_Innset
		end)
		local hasIt2 = table.find( res2 ,function ( levelIdNode )
			return levelIdNode == levelID_Innset
		end)
		local hasIt3 = table.find( res3 ,function ( levelIdNode )
			return levelIdNode == levelID_Innset
		end)

		if hasIt then
			return
		end
		if hasIt1 then
			return
		end
		if hasIt2 then
			return
		end
		if hasIt3 then
			return
		end

		table.insert( tableNode , levelID_Innset )
		
	end 

	local function sortTable_Local( tableData )
		table.sort( tableData , function ( levelId1 , levelId2 )
			return levelId1 < levelId2
		end)
	end 


    for levelId=1,kMaxLevels do

		local topLevel = UserManager.getInstance().user:getTopLevelId()
		if levelId <= topLevel then
			if JumpLevelManager:getLevelPawnNum( levelId ) > 0 then
				table_Insert( askForHelpAndJumpLevels  , levelId ,areaLevels,star4Levels,normalLevels)
			elseif UserManager:getInstance():hasAskForHelpInfo( levelId ) then 
				table_Insert( askForHelpAndJumpLevels  , levelId ,areaLevels,star4Levels,normalLevels)
			elseif self:isMyArea( levelId ) then
				table_Insert( areaLevels  , levelId ,askForHelpAndJumpLevels ,star4Levels ,normalLevels )
			elseif self:starIsNotEnough( levelId ) and  not self:shouldShowStar4( levelId ) then
				table_Insert( normalLevels  , levelId ,askForHelpAndJumpLevels,areaLevels,star4Levels)
			elseif self:shouldShowStar4( levelId ) then
				table_Insert( star4Levels  , levelId ,askForHelpAndJumpLevels,areaLevels,normalLevels)
			else

			end

		end

	end


	local function updateTable_Local( table1 , table2  )
		local isDiff = false
		for i=1,#table1 do
			local levelId = table1[i]
			local hasIt = table.find( table2 ,function ( levelIdNode )
				return levelIdNode == levelId
			end)
			if not hasIt then
				table.insert( table2 , levelId )
				isDiff = true
			end

		end

		return isDiff
	end


	if updateTable_Local( askForHelpAndJumpLevels , askForHelpAndJumpLevels2 ) then
		sortTable_Local( askForHelpAndJumpLevels2 )
	end
	
	if updateTable_Local( areaLevels , areaLevels2 ) then
		sortTable_Local( areaLevels2 )
	end

	if updateTable_Local( star4Levels , star4Levels2 ) then
		sortTable_Local( star4Levels2 )
	end

	if updateTable_Local( normalLevels , normalLevels2 ) then
		sortTable_Local( normalLevels2 )
	end
	
end

function StarAchievenmentPanel_Recommend:canInsertLevelID( value )
	
	if 1 then
		return true
	end

	local levelTableData = {340,337,200,61}

	local hasIt = table.find( levelTableData ,function ( levelIdNode )
		return levelIdNode == value.id
	end)

	return not hasIt
end

function StarAchievenmentPanel_Recommend:getAllLevelsData(  )
		
	local askForHelpAndJumpLevels = {}
	local areaLevels = {}

	local star4Levels = {}
	local normalLevels = {}

	local metaData =  MetaManager:getInstance():getLevelFarmStar() 
	local allLevelData = {}
	for key,value in pairs(metaData) do
		if value.group~=6 then

			if self:canInsertLevelID( value ) then
				table.insert( allLevelData ,value)
			end
			
		end
	end

	table.sort( allLevelData,function ( a1 , a2 )
		if a1.times ~= a2.times then
			return a1.times < a2.times
		end
		return a1.id < a2.id
	end )

	for key,value in pairs(metaData) do
		if value.group==6 then
			if self:canInsertLevelID( value ) then
				table.insert( allLevelData ,value)
			end
		end
	end


	local function table_Insert( tableNode , levelID_Innset ,res1,res2,res3 )
		if not tableNode then
			return
		end
		if not levelID_Innset then
			return
		end
		local hasIt = table.find( tableNode ,function ( levelIdNode )
			return levelIdNode == levelID_Innset
		end)

		local hasIt1 = table.find( res1 ,function ( levelIdNode )
			return levelIdNode == levelID_Innset
		end)
		local hasIt2 = table.find( res2 ,function ( levelIdNode )
			return levelIdNode == levelID_Innset
		end)
		local hasIt3 = table.find( res3 ,function ( levelIdNode )
			return levelIdNode == levelID_Innset
		end)

		if hasIt then
			return
		end
		if hasIt1 then
			return
		end
		if hasIt2 then
			return
		end
		if hasIt3 then
			return
		end

		table.insert( tableNode , levelID_Innset )
		
	end 





	for key,value in pairs(allLevelData) do
		local levelId = value.id

		local topLevel = UserManager.getInstance().user:getTopLevelId()

		if levelId <= topLevel  then

			if JumpLevelManager:getLevelPawnNum( levelId ) > 0 then
				table_Insert( askForHelpAndJumpLevels  , levelId ,areaLevels,star4Levels,normalLevels)
			elseif UserManager:getInstance():hasAskForHelpInfo( levelId ) then 
				table_Insert( askForHelpAndJumpLevels  , levelId ,areaLevels,star4Levels,normalLevels)
			elseif self:isMyArea( levelId ) then
				table_Insert( areaLevels  , levelId ,askForHelpAndJumpLevels ,star4Levels ,normalLevels )
			elseif self:starIsNotEnough( levelId ) and value.group~=6 and not self:shouldShowStar4( levelId ) then
				table_Insert( normalLevels  , levelId ,askForHelpAndJumpLevels,areaLevels,star4Levels)
				
			elseif self:shouldShowStar4( levelId ) and value.group == 6  then

				table_Insert( star4Levels  , levelId ,askForHelpAndJumpLevels,areaLevels,normalLevels)
			else


			end

		end
	end

	if _G.isLocalDevelopMode  then printx(100 , " askForHelpAndJumpLevels= " ,table.tostring( askForHelpAndJumpLevels )) end
	if _G.isLocalDevelopMode  then printx(100 , " star4Levels= " ,table.tostring( star4Levels )) end
	if _G.isLocalDevelopMode  then printx(100 , " areaLevels= " ,table.tostring( areaLevels )) end
	-- if _G.isLocalDevelopMode  then printx(100 , " normalLevels= " ,table.tostring( normalLevels )) end


	if _G.isLocalDevelopMode  then printx(0 , " getAllLevelsData: 2" ) end
	local tableCopy = {}

	local titleIndex = 0

	local kindOfLevels = 0
	if #askForHelpAndJumpLevels > 0 then
		kindOfLevels = kindOfLevels + 1
		tableCopy = askForHelpAndJumpLevels
		titleIndex = 1 
	end
	if #areaLevels > 0 then
		kindOfLevels = kindOfLevels + 1
		tableCopy = areaLevels
		titleIndex = 2
	end
	if #normalLevels > 0 then
		kindOfLevels = kindOfLevels + 1
		tableCopy = normalLevels
		titleIndex = 3
	end
	if #star4Levels > 0 then
		kindOfLevels = kindOfLevels + 1
		tableCopy = star4Levels
		titleIndex = 4
	end



	return askForHelpAndJumpLevels , areaLevels , star4Levels , normalLevels , kindOfLevels ,tableCopy ,titleIndex

end


