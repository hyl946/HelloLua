local Feed = require('zoo.panel.askForHelp.component.Feed')

local ITEMS_PER_PAGE = 5

local AFHLevelNoQuota = class(BasePanel)
function AFHLevelNoQuota:create(selectCallBack, panelforhide)
	local panel = AFHLevelNoQuota.new()
	panel:loadRequiredResource("ui/AskForHelp/panel_ask_for_help.json")
	panel:init(selectCallBack, panelforhide)
	return panel
end

function AFHLevelNoQuota:init(selectCallBack, panelforhide)
	self.ui = self:buildInterfaceGroup("AskForHelp/interface/NoLevelQuota")
	BasePanel.init(self, self.ui)

	self.panelforhide = panelforhide

	self.closeBtn = self.ui:getChildByName("closeBtn")
	self.closeBtn:setTouchEnabled(true,0,true)
	self.closeBtn:setButtonMode(true)
	self.closeBtn:addEventListener(DisplayEvents.kTouchTap, function() self:onKeyBackClicked() end)

	self.ui:getChildByName("lbInfo"):setString(localize("askforhelp.AFHLevelNoQuota.lbInfo"))

	----
	local info = UserManager:getInstance():getAskForHelpInfo()
	local levels = {}
	for k,v in pairs(info) do
		table.insertIfNotExist(levels, v.levelId or 1)
	end
	table.sort(levels)

	--levels = {100, 101, 102, 103, 104, 105, 106}
	local numberOfItems = table.size(levels)
	local ITEMS_PER_PAGE = 5

	self.levels = levels
	-------

    local scrollPanel = self.ui:getChildByName("scrollPanel")
    local contentHolder = scrollPanel:getChildByName('pageStub')
    local contentSize = contentHolder:getGroupBounds(scrollPanel).size
    local contentPos = contentHolder:getPosition()
    contentSize = CCSizeMake(contentSize.width, contentSize.height)
    contentPos = ccp(contentPos.x, contentPos.y)
	contentHolder:removeFromParentAndCleanup(true)
	
	self.pages = {}
    self.items = {}
    local nMaxPage = math.floor(numberOfItems / ITEMS_PER_PAGE)
    if numberOfItems % ITEMS_PER_PAGE > 0 then
        nMaxPage = nMaxPage + 1
    end
    self.pagedView = PagedView:create(contentSize.width, contentSize.height, nMaxPage, nil, true)
    self.pagedView:setIgnoreVerticalMove(true)

    local iMaxPage = nMaxPage - 1
    for iPage = 0, iMaxPage do
        local itemNum = ITEMS_PER_PAGE
        if iPage == iMaxPage then
            itemNum = numberOfItems % (ITEMS_PER_PAGE+1)
        end
        local page = self:buildPage(iPage, itemNum)

        local nPage = iPage + 1
        self.pages[nPage] = page
        self.pagedView:addPageAt(page, nPage)
    end

    self.pagedView:setPosition(ccp(contentPos.x, contentPos.y - contentSize.height))
    scrollPanel:addChildAt(self.pagedView, 0)

    -- CtrlBar
    self.btnL = scrollPanel:getChildByName("btnL")
    self.btnR = scrollPanel:getChildByName("btnR")
    self.btnL:setTouchEnabled(true)
    self.btnL:setButtonMode(true)
    self.btnL:addEventListener(DisplayEvents.kTouchTap, function () self:onLeft() end)
    self.btnR:setTouchEnabled(true)
    self.btnR:setButtonMode(true)
    self.btnR:addEventListener(DisplayEvents.kTouchTap, function () self:onRight() end)

    local function refreshCtrlBar()
        self.btnL:setVisible(self.pagedView:canPrevPage())
        self.btnR:setVisible(self.pagedView:canNextPage())
    end
    self.pagedView:setSwitchPageFinishCallback(refreshCtrlBar)
    refreshCtrlBar()

	self:refresh()
end

function AFHLevelNoQuota:buildPage(iPage, itemNum)
    local page = Layer:create()
    for i = 0, itemNum - 1 do
        local board = self:buildLevelFlour(iPage, i)
        page:addChild(board)
    end
    return page
end

function AFHLevelNoQuota:buildLevelFlour(iPage, idxInPage)
	local nIdx = iPage * ITEMS_PER_PAGE + (idxInPage+1)
	local levelId = self.levels[nIdx]
	
	local board = self:buildInterfaceGroup("AskForHelp/interface/levelItem")
    board.nIdx = nIdx
    board:setAnchorPoint(ccp(0,1))
    board:setPositionX(113 * idxInPage-3)
    board:setTouchEnabled(true)
    board:ad(DisplayEvents.kTouchTap, function (evt) self:onLevelFlourClicked(levelId) end)

    -- n99
    local lbInfo = board:getChildByName("lbInfo")
    lbInfo:setAnchorPoint(ccp(0.5, 0.5))
    lbInfo:setScale(1.1)
    lbInfo:setPosition(ccp(54, -40))
    lbInfo:changeFntFile("fnt/login_alert_level_num.fnt")
	lbInfo:setText(tostring(levelId))

    self.items[nIdx] = board

    return board
end

function AFHLevelNoQuota:onLevelFlourClicked(levelId)
	self:onKeyBackClicked()
	
	if self.panelforhide and type(self.panelforhide.remove) == "function" then
		local function onFinished()
			HomeScene:sharedInstance().worldScene:startLevel(levelId)
		end
		return self.panelforhide:remove(onFinished)
	end
end

function AFHLevelNoQuota:refresh( ... )
end

function AFHLevelNoQuota:onLeft()
    self.pagedView:prevPage()
end

function AFHLevelNoQuota:onRight()
    self.pagedView:nextPage()
end

function AFHLevelNoQuota:popout()
	PopoutManager:sharedInstance():addWithBgFadeIn(self, true, false, false)
	self.allowBackKeyTap = true

	local visibleSize = Director.sharedDirector():getVisibleSize()
	local visibleOrigin = Director:sharedDirector():getVisibleOrigin()

	local bounds = self.ui:getChildByName("_bg"):getGroupBounds()

	self:setPositionX((visibleSize.width - bounds.size.width) / 2)
	self:setPositionY(-visibleSize.height/2 + bounds.size.height/2)
end

function AFHLevelNoQuota:onKeyBackClicked()
	PopoutManager:sharedInstance():remove(self)
	self.allowBackKeyTap = false
end

function AFHLevelNoQuota:dispose( ... )
	BasePanel.dispose(self)
end

return AFHLevelNoQuota