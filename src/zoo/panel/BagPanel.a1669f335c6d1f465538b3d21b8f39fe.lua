require 'zoo.panel.basePanel.BasePanel'
require 'zoo.panel.component.pagedView.PagedView'
require 'zoo.panel.component.pagedView.PageRenderer'
require 'zoo.panel.component.pagedView.Pager'
require 'zoo.data.BagManager'


-- local STACK_SIZE = 10
-- local PAGE_SIZE = 18
local PAGE_SIZE = 20


local bagPanelInstance = nil

local function buyUnlockCallback(success)
	if success then 
		local bagData = BagManager:getInstance():getUserBagData()
		
		-- setBagPanelDataWithUpdate(bagData)
		-- bagPanelInstance.pagedView:gotoPage(bagPanelInstance.pagedView.numOfPages)
		-- local pageSize = PAGE_SIZE
		-- local showUnlockBtn = true
		-- local pageRenderer = PageRenderer:create('bagPanel_items', pageSize, showUnlockBtn)
		-- bagPanelInstance.pagedView:appendPage(pageRenderer)
		setBagPanelDataWithUpdate(bagData)
		bagPanelInstance.pagedView:gotoPage(bagPanelInstance.pagedView.numOfPages)
		-- bagPanelInstance.pagedView:gotoPage(bagPanelInstance.pagedView.numOfPages)
	end
end

local function setBagData(items)
	local pages = bagPanelInstance.pagedView.pageRenderers
	local numOfItems = #items
	local pageSize = PAGE_SIZE	
	-- local stackSize = STACK_SIZE -- 堆叠大小
	local stackSize = BagManager:getInstance():getStackSize()
	local numOfPages = bagPanelInstance.pagedView.numOfPages

	for _page=1, numOfPages do 
		local data = {}
		for j=(_page-1)*pageSize+1, _page*pageSize do
			if items[j] then 
				table.insert(data, items[j])
			end
		end 

		local p = pages[_page]
		if p then
			p:setItems(data)
		end
	end
end

local function sellPropsCallback(success)
	if success then
		local bagData = BagManager:getInstance():getUserBagData()
		setBagData(bagData)
	end
end

local function usePropsCallback(success)
	if success then
		local bagData = BagManager:getInstance():getUserBagData()
		setBagData(bagData)
	end
end

local function setBagPanelDataWithUpdate(items)

	bagPanelInstance:removeAllChildren()

	local numOfItems = #items
	local maxPageSize = PAGE_SIZE	
	local stackSize = STACK_SIZE -- 堆叠大小
	local bagSize = BagManager:getInstance():getUserBagSize()
	local numOfPages = math.ceil(bagSize / maxPageSize)
	if numOfPages == 0 then numOfPages = 1 end

	local pager = Pager:create(numOfPages, 'img/bagPanel_pagerIcon')
	pager:setAnchorPoint(ccp(.5, .5))

	local pvContainerSize = bagPanelInstance:getPagedViewContainerRect().size
	if _G.isLocalDevelopMode then printx(0, pvContainerSize.width, pvContainerSize.height) end
	local pagedView = PagedView:create(pvContainerSize.width, pvContainerSize.height, numOfPages, pager)
	-- local pagedView = PagedView:create(529, 689, numOfPages, pager)
	-- pagedView:setPosition(ccp(0, 0))

	local function addPager(index)
		local realPageSize =  0 
		if bagSize - (index - 1) * maxPageSize < maxPageSize then 
			realPageSize = bagSize - (index - 1) * maxPageSize
		else 
			realPageSize = maxPageSize
		end

		local data = {}
		-- for j=(index-1)*maxPageSize+1, index*maxPageSize do
		-- 	if items[j] then 
		-- 		table.insert(data, items[j])
		-- 	end
		-- end 
		for j=(index-1)*maxPageSize+1, (index-1)*maxPageSize+realPageSize do
			if items[j] then 
				table.insert(data, items[j])
			end
		end 

		-- local showUnlockBtn = true
		local showUnlockBtn = false

		local p = PageRenderer:create('bagPanel_items', realPageSize, showUnlockBtn)
		p:setItems(data)
		p:setBuyUnlockCallbackFunc(buyUnlockCallback)
		p:setSellCallbackFunc(sellPropsCallback)
		p:setUseCallbackFunc(usePropsCallback)
		pagedView:addPageAt(p, index)
	end

	local n= math.min(numOfPages,2)
	for index=1,n  do
		addPager(index)
	end

	local function onPageSwipe()
		local curPageIndex = pagedView.pageIndex
		if pagedView.pageRenderers[curPageIndex+1] == nil then
			addPager(curPageIndex+1)
		end
	end
	pagedView:setSwitchPageFinishCallback(onPageSwipe)

	bagPanelInstance:addPager(pager)
	bagPanelInstance:addPagedView(pagedView)

	-- if gotoPageOne then pagedView:gotoPage(1) end

end

BagPanel = class(BasePanel)

function BagPanel:createBagPanel(bagBtnPosInWorldSpace)
	if bagPanelInstance then bagPanelInstance:dispose() end

	bagPanelInstance = BagPanel:create(bagBtnPosInWorldSpace)

	local bagData = BagManager:getInstance():getUserBagData()
	
	setBagPanelDataWithUpdate(bagData)

	return bagPanelInstance
end

function BagPanel:create(bagBtnPosInWorldSpace)
	local panel = BagPanel.new()
	panel:loadRequiredResource(PanelConfigFiles.bag_panel_ui)
	panel:init(bagBtnPosInWorldSpace)
	return panel
end

function BagPanel:ctor()
	-- STACK_SIZE =  MetaManager:getInstance():getBagCapacity()
end

function BagPanel:init(bagBtnPosInWorldSpace,  ...)

	assert(bagBtnPosInWorldSpace)
	-- self.ui = ResourceManager:sharedInstance():buildGroup('bagPanel')
	self.ui = self:buildInterfaceGroup('bagPanel')
	BasePanel.init(self, self.ui)

	self.items = {}
	self.pageSize = PAGE_SIZE
	self.bagSize = BagManager:getInstance():getUserBagSize()


	self.closeBtn = self.ui:getChildByName('closeBtn')
	self.closeBtn:setTouchEnabled(true, 0, false)
	self.closeBtn:setButtonMode(true)
	self.closeBtn:addEventListener(DisplayEvents.kTouchTap, 
	                               function (event) 
	                               		self:onCloseBtnTapped(event) 
	                               end)

	self.bagBtnPosInWorldSpace = bagBtnPosInWorldSpace
	self.showHideAnim = IconPanelShowHideAnim:create(self, self.bagBtnPosInWorldSpace)

	self.pagedView = nil
	self.pager = nil
	self.pagedViewContainer = self.ui:getChildByName('items')
	self.pagerContainer = self.ui:getChildByName('pager')

	self.pagedViewContainer:setOpacity(0)
	self.pagerContainer:setOpacity(0)
	self.pagerContainer:setAnchorPoint(ccp(0,0))

	self.titleTxt = self.ui:getChildByName('title')
	self.titleTxt:setText(Localization:getInstance():getText('bag.panel.title', {}))
	local size = self.titleTxt:getContentSize()
	local scale = 65 / size.height
	self.titleTxt:setScale(scale)
	self.bg = self.ui:getChildByName("panelBg")
	self.titleTxt:setPositionX((self.bg:getGroupBounds().size.width - size.width * scale) / 2)
end

function BagPanel:addPagedView(pagedView)
	self.pagedViewContainer:addChild(pagedView)
	self.pagedView = pagedView
end

function BagPanel:addPager(pager)
	local pagerSize = pager:getGroupBounds().size
	local containerSize = self.pagerContainer:getGroupBounds().size
	local x = (containerSize.width - pagerSize.width) / 2 + pagerSize.width/(pager.numOfPages*2)
	local y = (containerSize.height - pagerSize.height) / 2 + pagerSize.height/2
	pager:setPosition(ccp(x, -y))
	self.pagerContainer:addChild(pager)
	self.pager = pager
end

function BagPanel:removeAllChildren()
	if self.pagedView then
		self.pagedView:removeFromParentAndCleanup(true)
		self.pagedView = nil
	end
	if self.pager then
		self.pager:removeFromParentAndCleanup(true)
		self.pager = nil
	end
end

function BagPanel:getPagedViewContainerRect()
	return self.pagedViewContainer:getGroupBounds()
end

function BagPanel:getPagerContainerRect()
	return self.pagerContainer:getGroupBounds()
end


function BagPanel:popout()
	PopoutManager:sharedInstance():addWithBgFadeIn(self, true, false, false)
	local function onFinish() self.allowBackKeyTap = true end
	self.showHideAnim:playShowAnim(onFinish)
end

function BagPanel:onCloseBtnTapped()
	local function hidePanelCompleted()
		PopoutManager:sharedInstance():removeWithBgFadeOut(self, false)
	end
	self.allowBackKeyTap = false
	self.showHideAnim:playHideAnim(hidePanelCompleted)
	self.pagedView:dispose()
end

function BagPanel:getHCenterInScreenX(...)
	assert(#{...} == 0)

	local visibleSize	= CCDirector:sharedDirector():getVisibleSize()
	local visibleOrigin	= CCDirector:sharedDirector():getVisibleOrigin()
	local selfWidth		= 636

	local deltaWidth	= visibleSize.width - selfWidth
	local halfDeltaWidth	= deltaWidth / 2

	return visibleOrigin.x + halfDeltaWidth
end