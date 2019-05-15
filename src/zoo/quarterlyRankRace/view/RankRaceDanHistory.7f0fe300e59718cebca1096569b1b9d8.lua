local UIHelper = require 'zoo.panel.UIHelper'
local Misc = require 'zoo.quarterlyRankRace.utils.Misc'

local rrMgr


local RankRaceDanHistory = class(BasePanel)

function RankRaceDanHistory:create(tempHistoryData)

    if not RankRaceMgr then
        require 'zoo.quarterlyRankRace.RankRaceMgr'
    end

    rrMgr = RankRaceMgr:getInstance()


    local panel = RankRaceDanHistory.new()
    panel.tempHistoryData = tempHistoryData
    panel:loadRequiredResource("ui/RankRace/history.json")
    panel:init()
    return panel
end

function RankRaceDanHistory:init()
    local ui = self:buildInterfaceGroup("moleWeeklyHistory/historyPanel")
	BasePanel.init(self, ui)
    rrMgr:addObserver(self)

    --close
    self.closeBtn = self.ui:getChildByName('closeBtn')
    self.closeBtn:setTouchEnabled(true, 0, true)
    self.closeBtn:ad(DisplayEvents.kTouchTap, function ( ... )
        self:onCloseBtnTapped()
    end)

    --裁剪区域
    local rect = self.ui:getChildByName('holder')
    rect:setVisible(false)
    local size = {
    	width = rect:getContentSize().width * rect:getScaleX(),
    	height = rect:getContentSize().height * rect:getScaleY()
	}
	self.rectsize = size

	local pos = ccp(rect:getPositionX(), rect:getPositionY())

	local container = VerticalScrollable:create(size.width, size.height, true, false)
	container:setPosition(pos)
	self.ui:addChild(container)
	self.container = container
    -----

    self.ui:getChildByName('item'):setVisible(false)

    
    self:InitSCroll()
end

function RankRaceDanHistory:dispose( ... )
    rrMgr:removeObserver(self)
    BasePanel.dispose(self, ...)
end

function RankRaceDanHistory:_close()
	self.allowBackKeyTap = false
	PopoutManager:sharedInstance():remove(self)
end

function RankRaceDanHistory:popout()
    self:scaleAccordingToResolutionConfig()
    self:setPositionForPopoutManager()
    self:setPositionX(self:getPositionX() + 0)
	PopoutManager:sharedInstance():add(self, true, nil, nil, nil, 200)
	self.allowBackKeyTap = true


    -- local layoutUtils =  require 'zoo.panel.happyCoinShop.utils'
    -- layoutUtils.setNodeRelativePos(self.bar, layoutUtils.MarginType.kBOTTOM, 32)
end

function RankRaceDanHistory:onCloseBtnTapped( ... )
    self:_close()
end

function RankRaceDanHistory:InitSCroll()

	local function buildItem( saijiInfo )
		local item = self:buildInterfaceGroup( self.ui:getChildByName('item').symbolName )

		local text1 = item:getChildByName('text1')
        text1:setPositionY( text1:getPositionY() - 5/0.7 )
        local text2 = item:getChildByName('text2')
        text2:setPositionY( text2:getPositionY() - 5/0.7 )
        local num1 = item:getChildByName('num1')
        num1:setPositionY( num1:getPositionY() - 5/0.7 )
        local num2 = item:getChildByName('num2')
        num2:setPositionY( num2:getPositionY() - 5/0.7 )

        local SaiJiIndex = saijiInfo.saijiIndex
        local YearName, SaijiName = rrMgr:getSaiJiName( SaiJiIndex )

        text1:setString(""..YearName)
        text2:setString(""..SaijiName)

        num1:setString(""..saijiInfo.maxWeekly)
        num2:setString(""..saijiInfo.maxOnce)

        local lvFlagUI = UIHelper:createUI('ui/RankRace/MainPanel.json', '2018_s1_rank_race/rank_level/rankLvBar')
        lvFlagUI:setPosition( ccp( 460-162/2,-40+54/2 ) )
        item:addChild( lvFlagUI )

	    local lvFlagLabel = lvFlagUI:getChildByName("label")
	    local lvFlagBg = lvFlagUI:getChildByName("bg")
	    local dan = math.clamp( saijiInfo.maxDan or 1, 1, 10)
	    for i=1,10 do
		    local label = lvFlagLabel:getChildByName(i.."")
		    label:setVisible(i == dan)
	    end
	    local bgIndex = math.floor((dan - 1) / 3) + 1
	    for i=1,4 do
		    local bg = lvFlagBg:getChildByName(i.."")
		    bg:setVisible(i == bgIndex)
	    end

        --裁剪节点
		local itemInLayout = ItemInClippingNode:create()
		itemInLayout:setContent( item )
		item:setAnchorPoint(ccp(0, 0))

		return itemInLayout
	end	

	--tab 1
	local layout = VerticalTileLayout:create(self.rectsize.width)
    local SeasonHistories = self.tempHistoryData and table.deserialize(self.tempHistoryData) or rrMgr.data:getSeasonHistories()
    if SeasonHistories then
	    for i,v in pairsByKeys(SeasonHistories) do
            local maxOnce = tonumber(v.maxOnce)
            local maxWeekly = tonumber(v.maxWeekly)
            if maxOnce and maxOnce > 0 and maxWeekly and maxWeekly > 0 then 
                local saijiInfo = {}
                saijiInfo.saijiIndex = tonumber(i)
                saijiInfo.maxDan = v.maxDan
                saijiInfo.maxOnce = v.maxOnce
                saijiInfo.maxWeekly = v.maxWeekly

    		    local item = buildItem( saijiInfo )
    		    item:setParentView(self.container)
    		    layout:addItem(item)
            end
	    end
    end
	self.container:setContent(layout)
	self.layout = layout
end

return RankRaceDanHistory
