--[[
 * VideoAdRewardPanel
 * @date    2018-09-07 17:05:11
 * @authors zhou.ding
 * @email 	zhou.ding@happyelements.com
--]]

local layoutUtils =  require 'zoo.panel.happyCoinShop.utils'
local UIHelper = require 'zoo.panel.UIHelper'
local Misc = require('zoo.quarterlyRankRace.utils.Misc')
local UIHelper = require 'zoo.panel.UIHelper'
local rrMgr

local function positionNode( holder, icon, isUniformScale)

    if (not holder) or holder.isDisposed then return end
    if (not icon) or icon.isDisposed then return end


    local layoutUtils = require 'zoo.panel.happyCoinShop.utils'

    local parent = holder:getParent()

    if (not parent) or parent.isDisposed then return end


    local iconIndex = parent:getChildIndex(holder)
    parent:addChildAt(icon, iconIndex)

    local size = holder:getContentSize()
    local sx, sy = holder:getScaleX(), holder:getScaleY()

    local realSize = {
        width = sx * size.width,
        height = sy * size.height,
    }

    layoutUtils.scaleNodeToSize(icon, realSize, parent, isUniformScale)
    layoutUtils.verticalCenterAlignNodes({icon}, holder, parent)
    layoutUtils.horizontalCenterAlignNodes({icon}, holder, parent)

    holder:setVisible(false)

end


local function setRewardItem( ui, itemId, num )

    if (not ui) or ui.isDisposed then return end


    local iconHolder = ui:getChildByName('icon')
    local icon = ResourceManager:sharedInstance():buildItemSprite(itemId)
    positionNode(iconHolder, icon, true)

    local flagHolder = ui:getChildByName('flag')


    local flagSpriteFrameName

    if flagSpriteFrameName then
        local flag = UIHelper:safeCreateSpriteByFrameName(flagSpriteFrameName .. '0000')
        positionNode(flagHolder, flag, true)
    end

    flagHolder:setVisible(false)
    iconHolder:setVisible(false)

    local numUI = BitmapText:create('x' .. tostring(num), 'fnt/event_default_digits.fnt')
    positionNode(ui:getChildByName('num'), numUI, true)



    local time_prop_flag = ResourceManager:sharedInstance():createTimeLimitFlag(itemId, true)
    if time_prop_flag then
        icon:addChild(time_prop_flag)
        local size = icon:getContentSize()
        time_prop_flag:setPosition(ccp(size.width/2, size.height/9))
        time_prop_flag:setScale(0.7 / math.max(icon:getScaleY(), icon:getScaleX()))
    end
end



local VideoAdRewardPanel = class(BasePanel)

function VideoAdRewardPanel:create(rewardItem, done, builder)
    local panel = VideoAdRewardPanel.new()
    panel:init(rewardItem, done, builder)
    return panel
end

function VideoAdRewardPanel:init(rewardItem, done, builder)
    self.builder = builder
    local ui = builder:buildGroup("VideoAd/RewardPanel")
    UIUtils:adjustUI(ui, 222, nil, nil, 1724)
    BasePanel.init(self, ui)
    self.done = done

    local function onTap( ... )
        if self.isDisposed then
            return
        end

        local bounds = self.reward:getGroupBounds()
        local function copyItems( tbl )
            local ret = {}
            for index, v in ipairs(tbl) do
                ret[index] = {itemId = v.itemId, num = v.num}
            end
            return ret
        end
        local items = Misc:clampRewardsNum({rewardItem})
        local anim = FlyItemsAnimation:create(items)
        anim:setWorldPosition(ccp(bounds:getMidX(),bounds:getMidY()))
        anim:play()
        self:_close()

    end

    self.closeBtn = self.ui:getChildByName('closeBtn')
    self.closeBtn:setTouchEnabled(true, 0, true)
    self.closeBtn:ad(DisplayEvents.kTouchTap, onTap)

    self.btn = self.ui:getChildByName('btn')
    self.btn =  GroupButtonBase:create(self.btn)
    self.btn:ad(DisplayEvents.kTouchTap, onTap)

    self.btn:setString(localize('领取奖励'))

    self.label = self.ui:getChildByName('label')
    self.label:setString(localize('five.steps.lottery.reward.title'))
    self.label:setVisible(false)

    self.reward = self.ui:getChildByName('reward')
    self.reward:setPositionY( self.reward:getPositionY() - 100)
    setRewardItem(self.reward, rewardItem.itemId, rewardItem.num)
    self.reward:setScale(1.3)

    local eff = CommonEffect:buildGetPropLightAnimWithoutBg()
    self.ui:addChildAt(eff, 0)
    eff:setPosition(ccp(self.reward:getPositionX(), self.reward:getPositionY()))

end

function VideoAdRewardPanel:popoutShowTransition( ... )
    local layoutUtils =  require 'zoo.panel.happyCoinShop.utils'
    layoutUtils.setNodeRelativePos(self.closeBtn, layoutUtils.MarginType.kTOP, 5)

    local vSize = Director:sharedDirector():getVisibleSize()
    local wSize = Director:sharedDirector():getWinSize()
    local vOrigin = Director:sharedDirector():getVisibleOrigin()
    local mask = LayerColor:create()
    mask:changeWidthAndHeight(wSize.width/self.ui:getScaleX(), wSize.height/self.ui:getScaleY())
    mask:setColor(ccc3(0, 0, 0))
    mask:setOpacity(200)
    self.ui:addChildAt(mask, 0)
    local layoutUtils =  require 'zoo.panel.happyCoinShop.utils'
    layoutUtils.setNodeRelativePos(mask, layoutUtils.MarginType.kLEFT, 0)
    layoutUtils.setNodeRelativePos(mask, layoutUtils.MarginType.kBOTTOM,  -vOrigin.y)
    self.maskLayer = mask

end

function VideoAdRewardPanel:_close()
    self.allowBackKeyTap = false
    PopoutManager:sharedInstance():remove(self)
    if self.done then
        self.done()
    end


    if self.callback then
        self.callback()
        self.callback = nil
    end
end

function VideoAdRewardPanel:popout(callback)
    PopoutManager:sharedInstance():add(self, false)
    self.allowBackKeyTap = true
    self:popoutShowTransition()
    self.callback = callback
end

function VideoAdRewardPanel:onCloseBtnTapped( ... )
    self.closeBtn:dispatchEvent(DisplayEvent.new(DisplayEvents.kTouchTap))
end

return VideoAdRewardPanel
