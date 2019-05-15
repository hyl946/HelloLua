-- require 'zoo.panel.quickselect.QuickTableView2'
-- require 'zoo.panel.quickselect.QuickTableRender'
require("zoo/panel/quickselect/QuickTableRender_New.lua")
require("zoo/panel/quickselect/QuickTableView_New.lua")

---------------------------------------------------
---------------------------------------------------
-------------- TabLevelArea_New
---------------------------------------------------
---------------------------------------------------
local function levelIsPassed( levelIdNode )
	if levelIdNode==nil or levelIdNode == 0 then
		return false
	end
	local scoreOfLevel = UserManager:getInstance():getUserScore(levelIdNode)
	if scoreOfLevel then
		if scoreOfLevel.star ~= 0 or 
			JumpLevelManager:getLevelPawnNum(levelIdNode) > 0 or 
			UserManager:getInstance():hasAskForHelpInfo(levelIdNode) then 
			return true
		end
	end
	return false
end
TabLevelArea_New = class(BaseUI)

function TabLevelArea_New:create(ui,hostPanel ,heightNode)
	local panel = TabLevelArea_New.new()
	panel:init(ui,hostPanel,heightNode)
	return panel
end

function TabLevelArea_New:init(ui,hostPanel,heightNode)
	-- StarAchievenmentPanel
	self.hostPanel = hostPanel
	self.heightNode = heightNode - 20

	BaseUI.init(self, ui)

	self:initData()

	self:initUI()
end

function TabLevelArea_New:initData()
end

function TabLevelArea_New:initUI()
	FrameLoader:loadImageWithPlist("flash/quick_select_level.plist")
	-- FrameLoader:loadImageWithPlist("flash/quick_select_animation.plist")

	local wSize = Director:sharedDirector():getWinSize()
	
	-- local visibleRectSize = self.ui:getGroupBounds(self.ui:getParent()).size

	-- local visibleRectSize = self.ui:getGroupBounds().size

	local visibleRectSize = self.ui:getContentSize()

	
	-- local visibleRectSize = self.ui:getContentSize()
	-- local visibleRectSize = {width=584,height=540}
 	if _G.isLocalDevelopMode then printx(100, ">>>>>>> level area size",visibleRectSize.width , visibleRectSize.height) end
	self.visibleWidth = visibleRectSize.width
	self.visibleHeight = visibleRectSize.height

	self.visibleHeight = self.heightNode
end

function TabLevelArea_New:setVisible(value)
	BaseUI.setVisible(self,value)

	if (value == true) then 
		self:initContent()
	else
		self:removeContent()
	end
end

function TabLevelArea_New:initContent()
	self.ui:removeChildren()
	-- self.hostPanel.title_full_four_star:setVisible(false)
	-- self.hostPanel.title_full_hidden:setVisible(false)

	
	-- self.hostPanel.txtDesc:setString(Localization:getInstance():getText("mystar_tag_1.1"))
	-- self.hostPanel.txtDesc4:setString( " " )

	self:addTableView()

	DcUtil:UserTrack({
		category = "ui",
		sub_category = "click_level_chooselevel",
	},true)
end

function TabLevelArea_New:removeContent()
 	self.ui:removeChildren()
end

function TabLevelArea_New:addTableView( ... )
	-- body
	local wSize = Director:sharedDirector():getWinSize()
	local vSize = Director:sharedDirector():getVisibleSize()
	local origin = Director:sharedDirector():getVisibleOrigin()

	-- local tabWidth = 585
	-- local tabHeight = 538

	-- local tabWidth = self.visibleWidth / self.ui:getScaleX()
	-- local tabHeight = self.visibleHeight / self.ui:getScaleY()


	local tabWidth = self.visibleWidth 
	local tabHeight = self.visibleHeight 

	-- clipping 
	-- local rect = {size = {width = tabWidth, height = tabHeight}}
	-- local clipping = ClippingNode:create(rect)
	-- clipping:setPositionY(-tabHeight)
	-- self.ui:addChild(clipping)

	-- simple clipping

	-- 令ClippingNode比Content稍大一点
	local borderSize = 10

	local clipping = SimpleClippingNode:create()
	clipping:setContentSize(CCSizeMake(tabWidth,tabHeight + borderSize))
	-- clipping:setPositionX(9)
	-- clipping:setPositionY(-tabHeight-6)
	clipping:setPositionX(0)
	clipping:setPositionY(-tabHeight - borderSize/2)
	clipping:setRecalcPosition(true)
	self.ui:addChild(clipping)

	local tableView = QuickTableView_New:create( tabWidth,tabHeight  , QuickTableRender_New )
	tableView:setPositionX(0)
	tableView:setPositionY(borderSize/2)
	clipping:addChild(tableView)
	-- self.ui:addChild(tableView)

	local scores = UserManager:getInstance():getScoreRef()
	local areaStars = {}
	local max_unlock_area = math.ceil(UserManager.getInstance().user:getTopLevelId() / 15)

	-- local displayMaxLevel = kMaxLevels
	-- if (_G.isPrePackage) then
	-- 	displayMaxLevel = _G.prePackageMaxLevel
	-- end
	for k = 1, kMaxLevels/15 do 
		 areaStars[k] = 0
	end

	for k, v in ipairs(scores) do
		local levelId = tonumber(v.levelId)
		if levelId < 10000 and levelId <= kMaxLevels then
			local areaId = math.ceil(levelId / 15)
			areaStars[areaId] = areaStars[areaId] + v.star
		end 
	end

	local cur_areaId = HomeScene:sharedInstance().worldScene:getCurrentAreaId()

	local dataList = {}
	local insertNum = 0

	local moreArea = 0
	local countdownAreaId = NewAreaOpenMgr.getInstance():getNextCountdownArea()
	local countdownAreaId_Now = NewAreaOpenMgr.getInstance():getCurCountdownArea()
	
	local kMaxLevelsNode = NewAreaOpenMgr.getInstance():getCanPlayTopLevel()

	local topPassedLevelId = UserManager:getInstance():getTopPassedLevel()
	local lastAreaIsLock = false
	if countdownAreaId  then 
		local now = Localhost:timeInSec()
		local endTime = NewAreaOpenMgr.getInstance():getCountdownEndTime( countdownAreaId_Now or countdownAreaId )
		if endTime > now then
			if endTime > 0 and not _G.isPrePackage then 
				lastAreaIsLock = true
			end
		elseif countdownAreaId == (kMaxLevelsNode/15 + 40001) then
			lastAreaIsLock = true
		end
		if topPassedLevelId >= kMaxLevelsNode then
			moreArea = 1 
		end
	end

	if _G.isLocalDevelopMode then printx(100, "countdownAreaId_Now = ", countdownAreaId_Now) end
	if _G.isLocalDevelopMode then printx(100, "countdownAreaId = ", countdownAreaId) end
	if _G.isLocalDevelopMode then printx(100, "kMaxLevelsNode = ", kMaxLevelsNode) end
	if _G.isLocalDevelopMode then printx(100, "moreArea = ", moreArea) end
	if _G.isLocalDevelopMode then printx(100, "max_unlock_area = ", max_unlock_area) end
	if _G.isLocalDevelopMode then printx(100, "lastAreaIsLock = ", lastAreaIsLock) end

	for k = 1 , kMaxLevelsNode/15 + moreArea do 
		-- if max_unlock_area >= (k-1) then
			local data = {}
			data.index = k
			data.isTopLevelArea = k ==  (kMaxLevelsNode/15 + 1)
			if data.isTopLevelArea then
				-- if _G.isLocalDevelopMode then printx(100, "data.isTopLevelArea =  k = ",data.isTopLevelArea, k ) end
				data.star_amount = 0 
				data.total_amount = 1
			else
				data.star_amount = areaStars[k]
				data.total_amount = LevelMapManager.getInstance():getTotalStarNumberByAreaId(k)
			end

			data.isUnlock = k <= max_unlock_area
			data.lastAreaIsLock = false
			if data.isTopLevelArea then
				data.lastAreaIsLock = lastAreaIsLock
			end
			data.isBranchOpen = true --隐藏关专用
			data.hideStar_amount = 0
			data.hideStar_total_amount = 0

			dataList[k] = data
			insertNum = insertNum + 1
		-- end

	end

	-- 掩藏关卡星星数
	-- for k,v in pairs(dataList) do
	-- 	local endLevelId = k * 15
	-- 	local branchId = MetaModel:sharedInstance():getHiddenBranchIdByNormalLevelId(endLevelId)
	-- 	if branchId and not MetaModel:sharedInstance():isHiddenBranchDesign(branchId) then --已上线隐藏关
	-- 		local branchData = MetaModel:sharedInstance():getHiddenBranchDataByBranchId(branchId)
	-- 		if branchData and branchData.endNormalLevel == endLevelId then
	-- 			for levelId=branchData.startHiddenLevel,branchData.endHiddenLevel do
	-- 				local score = UserManager:getInstance():getUserScore(levelId)
	-- 				if score and score.star > 0 then
	-- 					v.hideStar_amount = v.hideStar_amount + score.star
	-- 				end 
	-- 			end
	-- 			v.hideStar_total_amount = 9
	-- 			-- v.total_amount = v.total_amount + v.hideStar_total_amount
	-- 			-- v.star_amount = v.star_amount + v.hideStar_amount
	-- 			if not MetaModel:sharedInstance():isHiddenBranchCanOpen(branchId) then 
	-- 				v.isBranchOpen = false 
	-- 			end
	-- 		end
	-- 	end
	-- end



	tableView:updateData(dataList)

	tableView:setTouchEnabled(true)

	
	tableView:initArea(self.areaId or cur_areaId)
	local function onTabTaped( evt )
		if self.isDisposed then return end
		local canTouch = false
		local index = evt.data.index

		-- 如果index == nil，则不关闭
		local jumplevel = 0
		if index then
			jumplevel = index  *  15 - 8
		end
		
		if index and dataList and dataList[index] then
			canTouch = true
			if dataList[index].isTopLevelArea then
				jumplevel = kMaxLevels
			end
		end
		
		-- if _G.isLocalDevelopMode then printx(100, ">>>>>>>>> quick table tap >>>>>>>>>>",index) end

		if index and canTouch then
			DcUtil:UserTrack({
				category = "ui",
				sub_category = "click_star_chooselevel",
			})

			DcUtil:clickFlowerNodeInStarAch( 0 , index  *  15 -14 )
			
			HomeScene:sharedInstance().worldScene:moveNodeToCenter( jumplevel , false)
			self:onCloseBtnTapped()
		end
		
	end
	tableView:ad(QuickTableViewEventType.kTapTableView, onTabTaped)

end


function TabLevelArea_New:onCloseBtnTapped()
	self.hostPanel:onCloseBtnTapped()
end

function TabLevelArea_New:dispose( ... )

	BaseUI.dispose(self)
	FrameLoader:unloadImageWithPlists(
		{
		-- "flash/quick_select_level.plist",
	 	-- "flash/quick_select_animation.plist"
	 	}, true)
end

