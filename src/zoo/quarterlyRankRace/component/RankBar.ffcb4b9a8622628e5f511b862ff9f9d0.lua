local UIHelper = require 'zoo.panel.UIHelper'

local RankBar = {}

local RankBarA = class(BaseUI) 
local winSize = Director:sharedDirector():getWinSize()
function RankBarA:ctor()
	
end

function RankBarA:init(ui)
	self.ui = ui
	BaseUI.init(self, self.ui)

    local uid = UserManager:getInstance().user.uid
    local headUrl = UserManager:getInstance().profile.headUrl
    local headIcon = self.ui:getChildByName("head")
    LogicUtil.loadUserHeadIcon(uid, headIcon, headUrl)

    local targetNum = BitmapText:create("", 'fnt/mark_tip.fnt')
    targetNum:setAnchorPoint(ccp(0, 0))
    self.ui:addChild(targetNum)
    targetNum:setPosition(ccp(300, -70))
    self.targetNum = targetNum

    local labelNormal = BitmapText:create("", 'fnt/tutorial_white.fnt')
    labelNormal:setColor((ccc3(148, 73, 1)))
    labelNormal:setAnchorPoint(ccp(0, 0))
    self.ui:addChild(labelNormal)
    labelNormal:setPosition(ccp(410, -70))
    labelNormal:setScale(0.8)
    self.labelNormal = labelNormal

    self.labelNoNet = self.ui:getChildByName('labelNet')
    self.labelNoNet:setVisible(false)

    self.rewardBtn = self.ui:getChildByName('rewardBtn')
    self.rewardBtn:setButtonMode(true)
    self.rewardBtn:setTouchEnabled(true, 0, true, nil, true)
    self.rewardBtn:ad(DisplayEvents.kTouchTap, function()
        self:onRewardBtnTap()
    end)

    local SaijiIndex = RankRaceMgr.getInstance():getCurSaijiIndex()
    if SaijiIndex == 1 then
    else
        --打开分享tip
        local headTipUI = UIHelper:createUI('ui/RankRace/dan.json', 'rank.dan_/headTipUI')
        headTipUI:setPosition( ccp( 0,0 ) )
        self.rewardBtn:addChild( headTipUI )
        self.headTipUI = headTipUI

        self.bRunAction = false
        self.headTipUI:setScale(0.1)
        self.headTipUI:setVisible(false)
    end


    self.bg = self.ui:getChildByName("bg")
    local proFlagUI = self.ui:getChildByName("flag")
    self.ui:runAction(CCCallFunc:create(function ()
        local pos = self.bg:convertToNodeSpace(ccp(winSize.width, 0))
        if proFlagUI then proFlagUI:setPositionX(pos.x - 95) end
    end))

    self.proFlag1 = proFlagUI:getChildByName("1")
    self.proFlag1:setVisible(false)
    self.proFlag2 = proFlagUI:getChildByName("2")
    self.proFlag2:setVisible(false)


    self.ui:runAction(CCCallFunc:create(function ()
        local pos = proFlagUI:convertToNodeSpace(ccp(winSize.width, 0))
        self.proFlag1:setPosition(ccp(pos.x - 180, 35))
        self.proFlag2:setPosition(ccp(pos.x - 200, 48 - 2))
    end))
end

function RankBarA:updateRewardBtnShow(showLv)
    
    local SaijiIndex = RankRaceMgr.getInstance():getCurSaijiIndex()
    if SaijiIndex == 1 then
        local dan = RankRaceMgr.getInstance():getData():getSafeDan()
        if dan < 10 then 
            local pos = self.bg:convertToNodeSpace(ccp(winSize.width, 0))
            self.rewardBtn:setPositionX(pos.x - 50)
        else
            self.rewardBtn:setVisible(false)
        end
    else
        local pos = self.bg:convertToNodeSpace(ccp(winSize.width, 0))
        self.rewardBtn:setPositionX(pos.x - 50)
    end
end

function RankBarA:setTargetNum(num)
	num = "："..num
	self.targetNum:setText(num)
end

function RankBarA:setLabelNormalShow(str)
    self.labelNormal:setText(str)
    self.labelNormal:setVisible(true)
    self.labelNoNet:setVisible(false)
end

function RankBarA:setNoNetShow()
    self.labelNormal:setVisible(false)
    self.labelNoNet:setVisible(true)
end

function RankBarA:setBgShow(showLv)
    local promotionRange = 1
    if showLv == 1 then 
        promotionRange = 2
    end
    self.tipConfig = RankRaceMgr.getInstance():getPromotionReward(promotionRange)

    if showLv == 1 then 
        self.proFlag1:setVisible(false)
        self.proFlag2:setVisible(true)
    elseif showLv == 2 then 
        self.proFlag1:setVisible(true)
        self.proFlag2:setVisible(false)
    else
        self.proFlag1:setVisible(false)
        self.proFlag2:setVisible(false)
    end
    self:updateRewardBtnShow(showLv)
end

function RankBarA:showTip(reward)
    local ipt = {}
    for k, v in ipairs(reward) do
        local itemId = v.itemId
        if ItemType:isTimeProp(itemId) then
            -- itemId = ItemType:getRealIdByTimePropId(itemId)
        end
        local num = v.num 
        if ItemType:isHeadFrame(itemId) then
            num = 1
        end
        table.insert(ipt, {itemId = itemId, num = num})
    end

    local tipPanel = BoxRewardTipPanel:create({rewards=ipt})
    tipPanel:setTipString(localize("rank.race.main.1"))
    
    local scene = Director:sharedDirector():getRunningScene()
    scene:addChild(tipPanel , SceneLayerShowKey.TOP_LAYER)
    local touchRect = self.rewardBtn
    local bounds = touchRect:getGroupBounds()
    tipPanel:scaleAccordingToResolutionConfig()
    tipPanel:setArrowPointPositionInWorldSpace( bounds.size.width/2 , bounds:getMidX() , bounds:getMidY())
end

function RankBarA:onRewardBtnTap()
    if self.isDisposed then return end

    local dan = RankRaceMgr.getInstance():getData():getSafeDan()
    if dan== 10 then
        local SaijiIndex = RankRaceMgr.getInstance():getCurSaijiIndex()
        if SaijiIndex == 1 then
        else
            if self.bRunAction == false  then
                self.bRunAction = true

                local function MoveOut()
                    self.bRunAction = false
                    self.headTipUI:setVisible(false)
                end

                local array = CCArray:create()
	            array:addObject( CCScaleTo:create(0.2, 1.1) )
                array:addObject( CCScaleTo:create(0.1, 0.9) )
                array:addObject( CCScaleTo:create(0.1, 1) )
                array:addObject( CCDelayTime:create(3) )
                array:addObject( CCScaleTo:create(0.2, 0.1) )
                array:addObject( CCCallFunc:create( MoveOut ) )

                self.headTipUI:setScale(0.1)
                self.headTipUI:stopAllActions()
                self.headTipUI:runAction( CCSequence:create(array) )
                self.headTipUI:setVisible(true)
            end
        end
    else
        if self.tipConfig and #self.tipConfig > 0 then 
            self:showTip(self.tipConfig)
        end
    end

    if self.rewardBtnTapCallback then 
        self.rewardBtnTapCallback()
    end
end

function RankBarA:setRewardBtnCallback(callback)
    self.rewardBtnTapCallback = callback
end

function RankBarA:getIconWorldPos()
    local iconUI = self.ui:getChildByName("icon")
    local itemIconPos = iconUI:getPosition()
    return self.ui:convertToWorldSpace(ccp(itemIconPos.x, itemIconPos.y))
end

function RankBarA:create(ui)
	local bar = RankBarA.new()
	bar:init(ui)
	return bar
end



local RankBarB = class(BaseUI) 
function RankBarB:ctor()
	
end

function RankBarB:init(ui)
	self.ui = ui
	BaseUI.init(self, self.ui)

    local uid = UserManager:getInstance().user.uid
    local headUrl = UserManager:getInstance().profile.headUrl
    local headIcon = self.ui:getChildByName("head")
    LogicUtil.loadUserHeadIcon(uid, headIcon, headUrl)

    local targetNum = BitmapText:create("", 'fnt/mark_tip.fnt')
    targetNum:setAnchorPoint(ccp(0, 0))
    self.ui:addChild(targetNum)
    targetNum:setPosition(ccp(310, -70))
    self.targetNum = targetNum

    local labelNormal = BitmapText:create("", 'fnt/tutorial_white.fnt')
    labelNormal:setColor((ccc3(148, 73, 1)))
    labelNormal:setAnchorPoint(ccp(0.5, 0))
    self.ui:addChild(labelNormal)
    labelNormal:setPosition(ccp(640, -70))
    labelNormal:setScale(0.8)
    self.labelNormal = labelNormal
end

function RankBarB:setTargetNum(num)
	num = "："..num
    self.targetNum:setText(num)
end

function RankBarB:setLabelNormalShow(str)
    self.labelNormal:setText(str)
end

function RankBarB:create(ui)
	local bar = RankBarB.new()
	bar:init(ui)
	return bar
end


function RankBar:createBarA(ui)
	return RankBarA:create(ui)
end

function RankBar:createBarB(ui)
	return RankBarB:create(ui)
end

return RankBar