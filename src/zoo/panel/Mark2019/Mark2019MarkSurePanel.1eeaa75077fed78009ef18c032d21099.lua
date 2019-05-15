local UIHelper = require 'zoo.panel.UIHelper'
local Misc = require('zoo.quarterlyRankRace.utils.Misc')

Mark2019MarkSurePanel = class(BasePanel)
function Mark2019MarkSurePanel:create( mark2019Panel, day, itemId, num,done )
    local panel = Mark2019MarkSurePanel.new()
    panel:init(mark2019Panel,day,itemId, num,done)
    return panel
end

function Mark2019MarkSurePanel:init(mark2019Panel, day, itemId, num,done)
    self.mark2019Panel = mark2019Panel
    self.done = done

    local ui = UIHelper:createUI("flash/Mark2019/mark2019.json", "Mark2019/MarkSureTipPanel")
    BasePanel.init(self, ui)

    local itemName = ""
    if ItemType:isMergableItem( itemId ) then
        itemName = localize('prop.name.' .. itemId , {num = num} )
    else
        itemName = localize('prop.name.' .. itemId)
    end
    
    -----Tip
    local Str = "现在签到将会激活"..day.."天累计登录奖励中的"..itemName.."，是否现在签到？"
    local text2 = TextField:create( Str, nil, 30 , CCSizeMake( 490 , 160), kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
	text2:setColor(hex2ccc3("9F713B"))
	text2:setAnchorPoint(ccp(0, 0))
    text2:setPosition(ccp(61,-255))
    self.ui:addChildAt( text2,10 )

    -----Item
    local itemId = itemId
	if ItemType:isTimeProp(itemId) then
		itemId = ItemType:getRealIdByTimePropId(itemId)
	end
	local icon = ResourceManager:sharedInstance():buildItemSpriteWithDecorate(itemId, num)
	icon:setAnchorPoint(ccp(0.5, 0.5))
	icon:setPosition(ccp(303,-274))
	icon:setScale(1.3)
    self.ui:addChildAt( icon,10 )

	if ItemType:isTimeProp(itemId) then
		local time_prop_flag = ResourceManager:sharedInstance():createTimeLimitFlag(itemId)
		icon:addChild(time_prop_flag)
		local size = icon:getContentSize()
		time_prop_flag:setPosition(ccp(size.width/2, size.height/5))
		time_prop_flag:setScale(1 / math.max(icon:getScaleY(), icon:getScaleX()))
	end


    local okbtn = self.ui:getChildByName('btn')
    self.ok_btn = GroupButtonBase:create(okbtn)
    self.ok_btn:setString("稍后再签")
    self.ok_btn:setColorMode(kGroupButtonColorMode.orange)
    self.ok_btn:ad(DisplayEvents.kTouchTap, function( )
        self:onCloseBtnTapped()
    end) 

    local okbtn = self.ui:getChildByName('btn2')
    self.ok_btn = GroupButtonBase:create(okbtn)
    self.ok_btn:setString("现在签到")
    self.ok_btn:setColorMode(kGroupButtonColorMode.green)
    self.ok_btn:ad(DisplayEvents.kTouchTap, function( )
        -- body
        if self.mark2019Panel and not self.mark2019Panel.isDisposed then
            self.mark2019Panel:showSelectRewardPanel()
        end

        self:onCloseBtnTapped()
    end) 
end

function Mark2019MarkSurePanel:_close()

    if self.done then self.done() end
    self.allowBackKeyTap = false
    Mark2019Manager.getInstance():removeObserver(self)
    PopoutManager:sharedInstance():remove(self)
end

function Mark2019MarkSurePanel:popout()
    self:scaleAccordingToResolutionConfig()
    self:setPositionForPopoutManager()
    PopoutManager:sharedInstance():add(self, true, nil, nil, nil, 150)
    self.allowBackKeyTap = true

    self:popoutShowTransition()
end

function Mark2019MarkSurePanel:popoutShowTransition()
    Mark2019Manager.getInstance():addObserver(self)
end

function Mark2019MarkSurePanel:setPositionForPopoutManager()
    local vSize = CCDirector:sharedDirector():getVisibleSize()
    local posAdd =  CCDirector:sharedDirector():getVisibleOrigin().y
    self:setPosition(ccp(self:getHCenterInScreenX(), -(vSize.height - self:getVCenterInScreenY() + posAdd)))
end

function Mark2019MarkSurePanel:onCloseBtnTapped( ... )
    self:_close()
end

function Mark2019MarkSurePanel:onPassDay()
    self:_close()
end


return Mark2019MarkSurePanel