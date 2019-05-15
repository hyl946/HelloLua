
-- local __require = require

-- local function require( path )
-- 	package.loaded[path] = nil
-- 	return __require(path)
-- end


local UIHelper = require 'zoo.panel.UIHelper'
local XFLogic = require 'zoo.panel.xfRank.XFLogic'
local XFMeta = require 'zoo.panel.xfRank.XFMeta'
local XFHistoryPanel = require 'zoo.panel.xfRank.XFHistoryPanel'

local XFIdCardPanel = class(BasePanel)

function XFIdCardPanel:create(data)
    local panel = XFIdCardPanel.new()
    panel:init(data or XFLogic:getTestIdCardData())
    return panel
end

function XFIdCardPanel:init(data)
    local ui = UIHelper:createUI("ui/xf_panel.json", "xf/id_card")
	BasePanel.init(self, ui)

    UIUtils:setTouchHandler(self.ui:getChildByPath('closeBtn'), function()
        self:onCloseBtnTapped()
    end)

    -- self.ui:getChildByPath('top_label_1'):setDimensions(CCSizeMake(0, 0))
    -- self.ui:getChildByPath('top_label_2'):setDimensions(CCSizeMake(0, 0))
    -- self.ui:getChildByPath('top_label_3'):setDimensions(CCSizeMake(0, 0))

    self.data = data

    UIHelper:setUserName(self.ui:getChildByPath('nameLabel'), self.data.profile:getDisplayName())
    UIHelper:move(self.ui:getChildByPath('num'), 0, -2)

    UIHelper:setLeftText(self.ui:getChildByPath('num'), tostring(self.data.score), 'fnt/autumn2017.fnt')
    UIHelper:loadUserHeadIcon(self.ui:getChildByPath('headHolder'), self.data.profile, true)


    UIHelper:move(self.ui:getChildByPath('num'), 0, -3)

    if XFLogic:isValidRank(self.data.fullstar_rank) then

        UIHelper:setLeftText(
        	self.ui:getChildByPath('top_label_1'),
        	string.format('本轮满星时间：%s', os.date("%Y-%m-%d %H:%M:%S", self.data.fullstar_ts/1000)),
        	'fnt/tutorial_white.fnt'
        ):setColor(hex2ccc3('993300'))

        local txt = '5000+'

        if self.data.fullstar_rank <= 5000 then
            txt = tostring(self.data.fullstar_rank)
        end

        UIHelper:setLeftText(
        	self.ui:getChildByPath('top_label_2'),
        	string.format('本轮满星排名：满星榜全国第%d名', txt),
        	'fnt/tutorial_white.fnt'
        ):setColor(hex2ccc3('993300'))

    else

        if self.data.fullstar_ts and self.data.fullstar_ts > 0 then
            UIHelper:setLeftText(
                self.ui:getChildByPath('top_label_1'),
                string.format('本轮满星时间：%s', os.date("%Y-%m-%d %H:%M:%S", self.data.fullstar_ts/1000)),
                'fnt/tutorial_white.fnt'
            ):setColor(hex2ccc3('993300'))

            UIHelper:setLeftText(
                self.ui:getChildByPath('top_label_2'),
                string.format('本轮满星排名：%s', "5000+"),
                'fnt/tutorial_white.fnt'
            ):setColor(hex2ccc3('993300'))
        else
            UIHelper:setLeftText(
                self.ui:getChildByPath('top_label_1'),
                string.format('本轮满星时间：%s', '未满星'),
                'fnt/tutorial_white.fnt'
            ):setColor(hex2ccc3('993300'))

            UIHelper:setLeftText(
                self.ui:getChildByPath('top_label_2'),
                string.format('本轮满星排名：%s','未满星'),
                'fnt/tutorial_white.fnt'
            ):setColor(hex2ccc3('993300'))
        end
    end

    

    local arrow = self.ui:getChildByPath('top_arrow')
    local need_show_arrow = false
    self.up_rank = 0



    if self.data.fullstar_last_rank > 0 then
    	self.up_rank = self.data.fullstar_last_rank - self.data.fullstar_rank
    	if math.abs(self.up_rank) > 0.1 then
	    	need_show_arrow = true
    	end
    end

    if need_show_arrow then
    	if self.up_rank > 0 then
    	else
    		arrow:setFlipY(true)
    	end

	    UIHelper:setLeftText(
	    	self.ui:getChildByPath('top_label_3'),
	    	tostring(math.abs(self.up_rank)),
	    	'fnt/tutorial_white.fnt'
	    ):setColor(hex2ccc3('993300'))


    	local function align( node1, node2 )
    		node2:setPositionX(node1:getPositionX() + node1:getContentSize().width * node1:getScaleX()) 
    		node2:setPositionY(node1:getPositionY())
    	end

    	align(self.ui:getChildByPath('top_label_2'), arrow)
    	align(arrow, self.ui:getChildByPath('top_label_3'))
    	UIHelper:move(self.ui:getChildByPath('top_label_3'), 0, 4)

    else
    	arrow:setVisible(false)
    end

    arrow:setVisible(false)
    self.ui:getChildByPath('top_label_3'):setVisible(false)


	local bottom_rank = self.ui:getChildByPath('bottom_rank')
    bottom_rank:setColor(hex2ccc3('FF6600'))

	local topestRankEverGot = XFLogic:getHistoryTopRank(self.data)

	if topestRankEverGot > 0 then
	    UIHelper:setCenterText(bottom_rank, string.format('满星榜全国第%d名', topestRankEverGot), 'fnt/register2.fnt')
	else
	    UIHelper:setCenterText(bottom_rank, string.format('从未上榜'), 'fnt/register2.fnt')
	end

    local page1 = self.ui:getChildByPath('bottom_content/page1')
    local page2 = self.ui:getChildByPath('bottom_content/page2')

    local pages = {page1, page2}

   	local honorDataGrp = XFLogic:getHonorCfg(self.data)


    local notEmptyFlag = {}

   	for _pageIndex, _honorData in pairs(honorDataGrp) do
   		if pages[_pageIndex] then
   			local i = 1
   			while i <= #_honorData do
   				local itemUI, num = self:createItemUI(_honorData, i, #_honorData)
   				i = i + num
   				pages[_pageIndex]:addItem(itemUI)
                notEmptyFlag[_pageIndex] = true
   			end
   		end

   		pages[_pageIndex]:updateItemsHeight()
   		pages[_pageIndex]:pluginRefresh()

   	end

    local szs = {
        '还未获得星星奖杯呦~继续加油~',
        '还未获得星星奖牌呦~继续加油~'
    }

    for _pageIndex = 1, 2 do
        if not notEmptyFlag[_pageIndex] then
            local nothingUI = TextField:create(szs[_pageIndex], nil, 28)
            nothingUI:setColor(hex2ccc3('A75F0E'))
            nothingUI:setAnchorPoint(ccp(0, 0.5))
            nothingUI:setDimensions(CCSizeMake(544.05, 0))
            nothingUI:setHorizontalAlignment(kCCTextAlignmentCenter)
            local layer = Layer:create()
            layer:addChild(nothingUI)
            pages[_pageIndex]:addItem(layer)
            nothingUI:setPositionY(-312/2)
            pages[_pageIndex].scroll:setScrollEnabled(false)
        end
    end

    self.bottom_content = self.ui:getChildByPath('bottom_content')
    if self.bottom_content and not notEmptyFlag[1] and notEmptyFlag[2] then
        self.bottom_content:turnTo(2)
    end


end

function XFIdCardPanel:createItemUI( _data, _minIndex, _maxIndex )
	local itemUI = UIHelper:createUI('ui/xf_panel.json', 'xf/item')

	local counter = 0

	for i = 1, 3 do
		local data = _data[_minIndex + i - 1]
		local localHonorId = data and XFMeta:findSimilarHornorId(data.honorId, data.fullstar_rank) or nil

		if data and localHonorId then
			self:buildHonorUI(itemUI:getChildByPath(tostring(i)), data, localHonorId)
			counter = counter + 1
		else
			itemUI:getChildByPath(tostring(i)):setVisible(false)
		end
	end

	return itemUI, counter
end

function XFIdCardPanel:buildHonorUI( honorUI, data, localHonorId)
	honorUI:getChildByPath('label'):setString(os.date("%Y-%m-%d", data.fullstar_ts/1000))
	local sp = Sprite:createWithSpriteFrameName('xf/' .. localHonorId .. '0000')
	UIUtils:positionNode(honorUI:getChildByPath('holder'), sp, true)
end

function XFIdCardPanel:_close()
	self.allowBackKeyTap = false
	PopoutManager:sharedInstance():remove(self)
end

function XFIdCardPanel:popout()
    self:scaleAccordingToResolutionConfig()
    self:setPositionForPopoutManager()
    self:setPositionX(self:getPositionX() + 0)
	PopoutManager:sharedInstance():add(self, true)
	self.allowBackKeyTap = true
end

function XFIdCardPanel:onCloseBtnTapped( ... )
    self:_close()
end

function XFIdCardPanel:onButtonTap( buttonName )
	if buttonName == 'history_btn' then
		XFHistoryPanel:create(self.data):popout()
	end
end


-- package.loaded['zoo.panel.xfRank.XFIdCardPanel'] = nil
-- local XFIdCardPanel = require 'zoo.panel.xfRank.XFIdCardPanel'
-- XFIdCardPanel:create():popout()



return XFIdCardPanel
