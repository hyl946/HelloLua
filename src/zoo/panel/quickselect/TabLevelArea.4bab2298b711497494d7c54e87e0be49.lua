require 'zoo.panel.quickselect.QuickTableView2'
require 'zoo.panel.quickselect.QuickTableRender2'

---------------------------------------------------
---------------------------------------------------
-------------- TabLevelArea
---------------------------------------------------
---------------------------------------------------

assert(not TabLevelArea)
assert(BaseUI)
TabLevelArea = class(BaseUI)

function TabLevelArea:create(ui,hostPanel)
	local panel = TabLevelArea.new()
	panel:init(ui,hostPanel)
	return panel
end

function TabLevelArea:init(ui,hostPanel)
	-- StarAchievenmentPanel
	self.hostPanel = hostPanel
	BaseUI.init(self, ui)

	self:initData()

	self:initUI()
end

function TabLevelArea:initData()
end

function TabLevelArea:initUI()
	FrameLoader:loadImageWithPlist("flash/quick_select_level.plist")
	-- FrameLoader:loadImageWithPlist("flash/quick_select_animation.plist")

	local wSize = Director:sharedDirector():getWinSize()
	
	local visibleRectSize = self.ui:getGroupBounds(self.ui:getParent()).size
	-- local visibleRectSize = self.ui:getContentSize()
	-- local visibleRectSize = {width=584,height=540}
	if _G.isLocalDevelopMode then printx(0, ">>>>>>> level area size",visibleRectSize.width , visibleRectSize.height) end
	self.visibleWidth = visibleRectSize.width
	self.visibleHeight = visibleRectSize.height
end

function TabLevelArea:setVisible(value)
	BaseUI.setVisible(self,value)

	if (value == true) then 
		self:initContent()
	else
		self:removeContent()
	end
end

function TabLevelArea:initContent()
	self.ui:removeChildren()
	self.hostPanel.title_full_four_star:setVisible(false)
	self.hostPanel.title_full_hidden:setVisible(false)

	
	self.hostPanel.txtDesc:setString(Localization:getInstance():getText("mystar_tag_1.1"))
	self.hostPanel.txtDesc4:setString( " " )
	self:addTableView()

	DcUtil:UserTrack({
		category = "ui",
		sub_category = "click_level_chooselevel",
	},true)
end

function TabLevelArea:removeContent()
 	self.ui:removeChildren()
end

function TabLevelArea:addTableView( ... )
	-- body
	local wSize = Director:sharedDirector():getWinSize()
	local vSize = Director:sharedDirector():getVisibleSize()
	local origin = Director:sharedDirector():getVisibleOrigin()

	-- local tabWidth = 585
	-- local tabHeight = 538

	local tabWidth = self.visibleWidth / self.ui:getScaleX()
	local tabHeight = self.visibleHeight / self.ui:getScaleY()

	-- clipping 
	-- local rect = {size = {width = tabWidth, height = tabHeight}}
	-- local clipping = ClippingNode:create(rect)
	-- clipping:setPositionY(-tabHeight)
	-- self.ui:addChild(clipping)

	-- simple clipping

	-- 令ClippingNode比Content稍大一点
	local borderSize = 8

	local clipping = SimpleClippingNode:create()
	clipping:setContentSize(CCSizeMake(tabWidth,tabHeight + borderSize))
	-- clipping:setPositionX(9)
	-- clipping:setPositionY(-tabHeight-6)
	clipping:setPositionX(0)
	clipping:setPositionY(-tabHeight - borderSize/2)
	clipping:setRecalcPosition(true)
	self.ui:addChild(clipping)

	local tableView = QuickTableView:create( tabWidth,tabHeight, QuickTableRender)
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

	local dataList = {}
	for k = 1 , kMaxLevels/15 do 
		local data = {}
		data.index = k
		data.star_amount = areaStars[k]
		data.total_amount = LevelMapManager.getInstance():getTotalStarNumberByAreaId(k)
		data.isUnlock = k <= max_unlock_area
		data.isBranchOpen = true --隐藏关专用
		data.hideStar_amount = 0
		data.hideStar_total_amount = 0
		dataList[k] = data
	end

	-- 掩藏关卡星星数
	for k,v in pairs(dataList) do
		local endLevelId = k * 15
		local branchId = MetaModel:sharedInstance():getHiddenBranchIdByNormalLevelId(endLevelId)
		if branchId and not MetaModel:sharedInstance():isHiddenBranchDesign(branchId) then --已上线隐藏关
			local branchData = MetaModel:sharedInstance():getHiddenBranchDataByBranchId(branchId)
			if branchData and branchData.endNormalLevel == endLevelId then
				for levelId=branchData.startHiddenLevel,branchData.endHiddenLevel do
					local score = UserManager:getInstance():getUserScore(levelId)
					if score and score.star > 0 then
						v.hideStar_amount = v.hideStar_amount + score.star
					end 
				end
				v.hideStar_total_amount = 9
				if not MetaModel:sharedInstance():isHiddenBranchCanOpen(branchId) then 
					v.isBranchOpen = false 
				end
			end
		end
	end
	tableView:updateData(dataList)
	
	-- if _G.isLocalDevelopMode then printx(0, "~~~~~~ setPositionY",wSize.width,wSize.height,origin.x,origin.y) end
	-- tableView:setPositionY(-wSize.height + origin.y) -- @TBD
	-- tableView:setPositionY(-tabHeight)
	tableView:setTouchEnabled(true)

	local cur_areaId = HomeScene:sharedInstance().worldScene:getCurrentAreaId()
	if _G.isLocalDevelopMode then printx(0, "cur_areaId--->",cur_areaId) end
	tableView:initArea(self.areaId or cur_areaId)

	local function onTabTaped( evt )
		DcUtil:UserTrack({
			category = "ui",
			sub_category = "click_star_chooselevel",
		})

		-- 如果index == nil，则不关闭
		local index = evt.data.index
		if _G.isLocalDevelopMode then printx(0, ">>>>>>>>> quick table tap >>>>>>>>>>",index) end
		if index then
			HomeScene:sharedInstance().worldScene:moveNodeToCenter(index  *  15 - 8, false)
			self:onCloseBtnTapped()
		end
		
	end
	tableView:ad(QuickTableViewEventType.kTapTableView, onTabTaped)

end


function TabLevelArea:onCloseBtnTapped()
	self.hostPanel:onCloseBtnTapped()
end

function TabLevelArea:dispose( ... )

	BaseUI.dispose(self)
	FrameLoader:unloadImageWithPlists(
		{
		-- "flash/quick_select_level.plist",
	 	-- "flash/quick_select_animation.plist"
	 	}, true)
end

