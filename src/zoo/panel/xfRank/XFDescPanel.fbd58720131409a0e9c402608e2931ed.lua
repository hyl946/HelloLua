
local UIHelper = require 'zoo.panel.UIHelper'
local XFMeta = require 'zoo.panel.xfRank.XFMeta'
local XFDescPanel = class(BasePanel)

function XFDescPanel:create()
    local panel = XFDescPanel.new()
    panel:init()
    return panel
end

function XFDescPanel:init()
    local ui = UIHelper:createUI("ui/xf_panel.json", "xf/desc")
	BasePanel.init(self, ui)

    UIUtils:setTouchHandler(self.ui:getChildByPath('closeBtn'), function()
        self:onCloseBtnTapped()
    end)

    self.tab1_nor = self.ui:getChildByPath('tab1_nor')
    self.tab2_nor = self.ui:getChildByPath('tab2_nor')
    self.tab1_sel = self.ui:getChildByPath('tab1_sel')
    self.tab2_sel = self.ui:getChildByPath('tab2_sel')

    self.content  = self.ui:getChildByPath('content')
    self.content2 = self.ui:getChildByPath('content2')

    -- local btn = GroupButtonBase:create(self.ui:getChildByPath('btn'))
    -- btn:setString('知道了')
    -- btn:ad(DisplayEvents.kTouchTap, function ( ... )
    -- 	if self.isDisposed then return end
    -- 	self:onCloseBtnTapped()
    -- end)

    UIUtils:setTouchHandler(self.ui:getChildByPath('tab1_sel'), function()
        self:updateTabUIWithType(1)
    end)
    UIUtils:setTouchHandler(self.ui:getChildByPath('tab1_nor'), function()
        self:updateTabUIWithType(1)
    end)


    UIUtils:setTouchHandler(self.ui:getChildByPath('tab2_sel'), function()
        self:updateTabUIWithType(2)
    end)
    UIUtils:setTouchHandler(self.ui:getChildByPath('tab2_nor'), function()
        self:updateTabUIWithType(2)
    end)

    local content = self.ui:getChildByPath('content')
    for i = 1, 32 do

    	if localize('xf.desc.panel.label.' .. i) == 'xf.desc.panel.label.' .. i then
    		break
    	end

    	local item = UIHelper:createUI("ui/xf_panel.json", "xf/desc_item")
    	content:addItem(item)

        local textUI = item:getChildByPath('label')

        local size = textUI:getDimensions()
        textUI:setDimensions(CCSizeMake(size.width, 0))

    	textUI:setString(localize('xf.desc.panel.label.' .. i))
        
    end

    content:updateItemsHeight()
    content:pluginRefresh()

    local content2 = self.ui:getChildByPath('content2')

    local cfg = MetaManager:getInstance():getCommonRankRewardsByActId(XFMeta.ActId)

    local indexNode = 1
    for _k, value in ipairs(cfg) do

        local maxRange = value.maxRange
        local minRange = value.minRange
        local label_String = "第"..minRange .."-"..maxRange.."名"
        if minRange == maxRange then
            label_String = "第"..minRange.."名"
        end

        local item = UIHelper:createUI("ui/xf_panel.json", "xf/desc_item2")
        content2:addItem(item)
        local textUI = item:getChildByPath('rankLabel')
        local size = textUI:getDimensions()
        textUI:setDimensions(CCSizeMake(size.width, 0))
        textUI:setString( label_String )


        local scoreItem = table.find(value.rewards or {}, function ( rewardItem )
            return rewardItem.itemId == 50299
        end)

        local score = 0
        if scoreItem then
            score = scoreItem.num
        end
        UIHelper:setLeftText(item:getChildByPath('num'), tostring( "X"..score ), 'fnt/autumn2017.fnt')


        local honorItem = table.find(value.rewards or {}, function ( rewardItem )
                return ItemType:isHonor(rewardItem.itemId)
            end)
        if honorItem then
            local sp = Sprite:createWithSpriteFrameName('xf/' .. honorItem.itemId .. '0000')
            sp:setScale(0.5)
            item:addChild( sp )
            sp:setPositionX( 360 + 30 )
            sp:setPositionY( -37 )

            --针对性缩放
            if indexNode == 5 then
                sp:setScale(0.6)
                sp:setPositionY( -35 )
            end

        end


        local headFrameItem = table.find(value.rewards or {}, function ( rewardItem )
                return ItemType:isHeadFrame(rewardItem.itemId)
            end)
        
        if headFrameItem then
            local headFrameUI = HeadFrameType:buildUI(ItemType:convertToHeadFrameId( headFrameItem.itemId ), 1, '')
            headFrameUI:getChildByName('head'):removeFromParentAndCleanup(true)
            item:addChild( headFrameUI )
            headFrameUI:setPositionX( 460 + 25 )
            headFrameUI:setPositionY( -37 )
            headFrameUI:setScale(0.5)

        end


        indexNode = indexNode + 1
    end

    content2:updateItemsHeight()
    content2:pluginRefresh()

    self:updateTabUIWithType(1)

end


function XFDescPanel:updateTabUIWithType( typeID )

    self.tab1_sel:setVisible(false)
    self.tab2_sel:setVisible(false)

    self.content:setVisible(false)
    self.content2:setVisible(false)


    if 1 == typeID then

        self.tab1_sel:setVisible( true )
        self.content:setVisible( true )

    else

        self.tab2_sel:setVisible( true )
        self.content2:setVisible( true )

    end



end

function XFDescPanel:_close()
	self.allowBackKeyTap = false
	PopoutManager:sharedInstance():remove(self)
end

function XFDescPanel:popout()
    self:scaleAccordingToResolutionConfig()
    self:setPositionForPopoutManager()
    self:setPositionX(self:getPositionX() + 0)
	PopoutManager:sharedInstance():add(self, true)
	self.allowBackKeyTap = true
end

function XFDescPanel:onCloseBtnTapped( ... )
    self:_close()
end


return XFDescPanel
