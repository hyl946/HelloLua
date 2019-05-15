require 'hecore.display.ShapeNode'
local Misc = require 'zoo.quarterlyRankRace.utils.Misc'
local UIHelper = require 'zoo.panel.UIHelper'
local SharePicture = require 'zoo.quarterlyRankRace.utils.SharePicture'

local XFRewardsPanel = class(BasePanel)

function XFRewardsPanel:create(rewards, historyInfo)
    local panel = XFRewardsPanel.new()
    panel:init(rewards, historyInfo)
    return panel
end

function XFRewardsPanel:popoutShowTransition( ... )
    if self.isDisposed then return end
    self.allowBackKeyTap = true
    local layoutUtils =  require 'zoo.panel.happyCoinShop.utils'
    layoutUtils.setNodeRelativePos(self.ui:getChildByPath('closeBtn'), layoutUtils.MarginType.kTOP, 5)
end

function XFRewardsPanel:init(rewards, historyInfo)
    local ui = UIHelper:createUI("ui/xf_share.json", "xf_share_panel/panel")

    UIUtils:adjustUI(ui, 222, nil, nil, 1724)


	BasePanel.init(self, ui)

    UIUtils:setTouchHandler(self.ui:getChildByPath('closeBtn'), function()
        self:onCloseBtnTapped()
    end)

    local anim
    if #rewards > 2 then
    	anim = UIHelper:createArmature2('skeleton/xf_reward_anim', 'xf_reward_anim/reward_anim_3')
    elseif #rewards > 1 then
    	anim = UIHelper:createArmature2('skeleton/xf_reward_anim', 'xf_reward_anim/reward_anim_2')
    else
    	anim = UIHelper:createArmature2('skeleton/xf_reward_anim', 'xf_reward_anim/reward_anim_1')
    end
    self.ui:addChild(anim)

    anim:setPosition(ccp(480, - 1024))


    local fullstar_rank = historyInfo and historyInfo.fullstar_rank or 1


    local titleHolder = UIHelper:getCon(anim, 'title')
    local title = UIHelper:createUI('ui/xf_share.json', 'xf_share_panel/title')
    title:setPositionY(86)

    if fullstar_rank > 500 then
        title:getChildByPath('title2'):setVisible(false)
    else
        title:getChildByPath('title1'):setVisible(false)
    end

    titleHolder:addChild(title.refCocosObj)
    title:dispose()



    anim:playByIndex(0, 1)


    local i = 1

    for _k, _v in ipairs(rewards) do
    	if i <= 3 then

    		local rewardItem = UIHelper:createUI("ui/xf_share.json", "xf_share_panel/1@RewardItem")
    		rewardItem:setRewardItem(_v)
    		rewardItem:setScale(1.4)
    		rewardItem:setPosition(ccp(20, 246))

    		if rewardItem.num then
    			UIHelper:move(rewardItem.num, 20, 0)
    		end

    		local con = anim:getCon('reward' .. i .. ' 复制')
    		if con then
    			rewardItem.refCocosObj:setZOrder(-3)
    			con:addChild(rewardItem.refCocosObj)
    			rewardItem:dispose()
    		end
    	end
    	i = i + 1
    end

    local btn = GroupButtonBase:create(self.ui:getChildByName('btn') )
    btn:setString('知道了')
    btn:ad(DisplayEvents.kTouchTap, preventContinuousClick(function ( ... )
    	if self.isDisposed then return end
    	self:onCloseBtnTapped()
    end))
end

function XFRewardsPanel:_close()
	self.allowBackKeyTap = false
	PopoutManager:sharedInstance():remove(self)

    HeadFrameType:checkShowHeadFrameGotPanel()
end

function XFRewardsPanel:popout()
	PopoutManager:sharedInstance():add(self, false)
	self:popoutShowTransition()

    local vSize = Director:sharedDirector():getVisibleSize()
    local wSize = Director:sharedDirector():getWinSize()
    local vOrigin = Director:sharedDirector():getVisibleOrigin()
    local mask = LayerColor:create()
    mask:changeWidthAndHeight(wSize.width/self.ui:getScaleX(), wSize.height/self.ui:getScaleY())
    mask:setColor(ccc3(0, 0, 0))
    mask:setOpacity(210)
    self.ui:addChildAt(mask, 0)
    local layoutUtils =  require 'zoo.panel.happyCoinShop.utils'
    layoutUtils.setNodeRelativePos(mask, layoutUtils.MarginType.kLEFT, 0)
    layoutUtils.setNodeRelativePos(mask, layoutUtils.MarginType.kBOTTOM,  -vOrigin.y)
    self.maskLayer = mask

end

function XFRewardsPanel:onCloseBtnTapped( ... )
    self:_close()
end


return XFRewardsPanel
