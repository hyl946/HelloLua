local layoutUtils =  require 'zoo.panel.happyCoinShop.utils'
local LotteryCtrl = require 'zoo.panel.endGameProp.lottery.LotteryCtrl'
local LotteryLogic = require 'zoo.panel.endGameProp.lottery.LotteryLogic'
local ExchangeBBSPanel = require 'zoo.panel.endGameProp.lottery.ExchangeBBSPanel'
local UIHelper = require 'zoo.panel.UIHelper'



local DCInfo = class()

function DCInfo:ctor( ... )
    self.click = nil
    self.result = -1
    self.items = {}
end

function DCInfo:onClick( ... )
    self.click = 1
end

function DCInfo:onRewardSuccess( itemId, num )
    self.result = 0
    table.insert(self.items, {itemId = itemId, num = num})
end

function DCInfo:onRewardFail( ... )
    if self.result ~= 0 then
        self.result = 1
    end
end

function DCInfo:sendDC(lotteryMode)
    
    local item_id_num = ''
    for _, v in ipairs(self.items) do
        item_id_num = item_id_num .. string.format('%s_%s;', v.itemId, v.num)
    end

    if lotteryMode == LotteryLogic.MODE.kNORMAL then
        DcUtil:UserTrack({
            category='add_5steps', 
            sub_category='lottery_close', 
            click = self.click, 
            result = self.result,
            item_id_num = item_id_num
        })
    elseif lotteryMode == LotteryLogic.MODE.kFREE then
        DcUtil:UserTrack({
            category='add_5steps', 
            sub_category='lottery_close_free', 
            click = self.click, 
            result = self.result,
            item_id_num = item_id_num
        })
    end
end



local LotteryPanel = class(BasePanel)

function LotteryPanel:create(lotteryMode)
    local panel = LotteryPanel.new()
    panel:init(lotteryMode)
    return panel
end

function LotteryPanel:init(lotteryMode)

    self.lotteryMode = lotteryMode or LotteryLogic.MODE.kFREE

    self.dcInfo = DCInfo.new()

    local ui = UIHelper:createUI('ui/lottery.json', "add.step.lottery/lottery")
    UIUtils:adjustUI(ui, 222, nil, nil, 1724)
	BasePanel.init(self, ui)
    self.closeBtn = self.ui:getChildByName('closeBtn')
    self.closeBtn:setTouchEnabled(true, 0, true)
    self.closeBtn:ad(DisplayEvents.kTouchTap, function () self:onCloseBtnTapped() end)

    self.lotteryCtrl = LotteryCtrl.new(self.ui, self.lotteryMode)
    self.lotteryCtrl:addObservers(self)
    self.lotteryCtrl:setGetRewardCallback(function ( rewardItem )
        -- body
        local LotteryServer = require 'zoo.panel.endGameProp.lottery.LotteryServer'
        if LotteryServer:isAddStep(rewardItem.itemId) then
            self:_close()
        end

        if self.getRewardCallback then
            self.getRewardCallback(rewardItem, LotteryServer:isAddStep(rewardItem.itemId))
        end

        if self.lotteryMode == LotteryLogic.MODE.kFREE and LotteryLogic:getLeftFreeDrawCount() <= 0 then
            self:_close()
        end

    end)
    self.lotteryCtrl:refresh()

    require('zoo.panel.endGameProp.lottery.BuyDiamondObserver'):addObserver(self)

    local LotteryServer = require 'zoo.panel.endGameProp.lottery.LotteryServer'
    LotteryServer:getInstance():reset()
end

function LotteryPanel:dispose( ... )
    -- body
    require('zoo.panel.endGameProp.lottery.BuyDiamondObserver'):removeObserver(self)

    BasePanel.dispose(self, ...)

end

function LotteryPanel:onDiamondChanged( ... )
    if self.isDisposed then return end
    self.lotteryCtrl:refresh()
end

function LotteryPanel:_close()
    if self.isDisposed then return end
    self.dcInfo:sendDC(self.lotteryMode)
	self.allowBackKeyTap = false
	PopoutManager:sharedInstance():remove(self)
end

function LotteryPanel:popout()
	PopoutManager:sharedInstance():add(self, true, nil, nil, nil, 200)
	self.allowBackKeyTap = true
	self:popoutShowTransition()
end


function LotteryPanel:onClickStartBtn( ... )
    -- body
    if self.isDisposed then return end
    self.dcInfo:onClick()

    if self._revertNewLotteryGuide_2 then
        self._revertNewLotteryGuide_2()
        self._revertNewLotteryGuide_2 = nil
    end
end

function LotteryPanel:onRewardSuccess(itemId, num )
    if self.isDisposed then return end
    self.dcInfo:onRewardSuccess(itemId, num)
end

function LotteryPanel:onRewardFail( ... )
    if self.isDisposed then return end
    self.dcInfo:onRewardFail()
end

function LotteryPanel:popoutShowTransition( ... )

    if self.isDisposed then return end


	layoutUtils.setNodeRelativePos(self.closeBtn, layoutUtils.MarginType.kTOP, 5)

    local vSize = Director:sharedDirector():ori_getVisibleSize()
    local wSize = Director:sharedDirector():getWinSize()
    local vOrigin = Director:sharedDirector():ori_getVisibleOrigin()

    local maskWidth = UIHelper:convert2NodeSpace(self.ui, vSize.width)
    local maskHeight = UIHelper:convert2NodeSpace(self.ui, vSize.height)

    local mask = LayerColor:create()


    mask:changeWidthAndHeight(maskWidth, maskHeight)
    mask:setColor(ccc3(0, 0, 0))
    mask:setOpacity(200)
    self.ui:addChildAt(mask, 0)

    local maskInputLayer = LayerColor:create()
    maskInputLayer:changeWidthAndHeight(maskWidth, maskHeight + 100)
    maskInputLayer:setColor(ccc3(0, 0, 0))
    maskInputLayer:setOpacity(0)
    self.ui:addChildAt(maskInputLayer, 0)
    maskInputLayer:setTouchEnabled(true, nil, true)
    maskInputLayer:ad(DisplayEvents.kTouchTap, function ( ... )
        if self.isDisposed then return end
        self:onTapMaskLayer()
    end)




    local layoutUtils =  require 'zoo.panel.happyCoinShop.utils'
    layoutUtils.setNodeOriginPos(mask, vOrigin)
    mask.name = 'maskLayer'
    self.maskLayer = mask
    self.maskLayer:setVisible(false)

    layoutUtils.setNodeOriginPos(maskInputLayer, vOrigin)
    maskInputLayer.name = 'maskInputLayer'
    self.maskInputLayer = maskInputLayer
    self.maskInputLayer:setVisible(false)


    if self.lotteryMode == LotteryLogic.MODE.kNEW then
        local hadExchange, diamondsNum, voucherNum = self:exchangeDiamondsHttp()
        if hadExchange then
            ExchangeBBSPanel:create(diamondsNum, voucherNum):popout()
            self.lotteryCtrl:refresh()

            DcUtil:activity({
                game_type = 'stage',
                game_name = 'fs_new_lottery',
                category = 'diamond_exchange',
                sub_category = 'diamond_exchange',
                playId = GamePlayContext:getInstance():getIdStr(),
                t1 = diamondsNum,
            })
        end
    end

end

function LotteryPanel:onCloseBtnTapped( ... )
    if self.lotteryCtrl.isBusy then
        CommonTip:showTip('正在摇奖，请稍后~')
        return
    end
    self:_close()
end

function LotteryPanel:setGetRewardCallback( callback )
    self.getRewardCallback = callback
end

function LotteryPanel:exchangeDiamondsHttp( ... )
    -- body
    local diamondsCount = UserManager:getInstance():getUserPropNumber(ItemType.DIAMONDS)
    if diamondsCount > 0 then
        UserManager:getInstance():addUserPropNumber(ItemType.DIAMONDS, -diamondsCount)
        UserService:getInstance():addUserPropNumber(ItemType.DIAMONDS, -diamondsCount)
        local multi = 4
        local voucherNum = diamondsCount * multi
        UserManager:getInstance():addUserPropNumber(ItemType.VOUCHER, voucherNum)
        UserService:getInstance():addUserPropNumber(ItemType.VOUCHER, voucherNum)
        GainAndConsumeMgr.getInstance():consumeItem(DcFeatureType.kAddFiveSteps, ItemType.DIAMONDS, diamondsCount, nil, nil, DcSourceType.kFSNewLottery)
        GainAndConsumeMgr.getInstance():gainItem(DcFeatureType.kAddFiveSteps, ItemType.VOUCHER, voucherNum, DcSourceType.kFSNewLottery)
        HttpBase:offlinePost(kHttpEndPoints.diamonds2Voucher, {diamondsCount = diamondsCount})
        return true, diamondsCount, voucherNum
    end
    return false
end

function LotteryPanel:onTapMaskLayer( ... )
    if self.isDisposed then return end
end

function LotteryPanel:popoutNewLotteryGuide_2( ... )
    local action = 
    {
        opacity = 0xCC, 
        panelName = 'guide_dialogue_lottery_2',
        panDelay = 0
    }
    local guidePanel = GameGuideUI:panelS(nil, action, '')
    guidePanel.name = 'guidePanel'


    local bounds = self.ui:getChildByPath('new_ui_group/lottery_btn_1'):getGroupBounds(self.ui)
    local anchorPos = ccp(bounds:getMidX() - bounds.size.width/2, bounds:getMidY())

    guidePanel:setPosition(anchorPos)
    self.ui:addChild(guidePanel)


    local vo = Director:sharedDirector():ori_getVisibleOrigin()
    layoutUtils.setNodeOriginPos(self.maskLayer, ccp(vo.x, vo.y))
    self.maskLayer:setVisible(true)
    self.maskInputLayer:setVisible(true)

    local r1 = UIHelper:moveToTop(self.ui, {'maskLayer', 'maskInputLayer', 'new_ui_group/lottery_btn_1', 'new_ui_group/lottery_btn_2' ,'guidePanel'})

   

    local function endGuide( ... )
        -- body
        if self.isDisposed then return end
        if r1 then 
            r1() 
            r1 = nil 
        end
        if guidePanel and (not guidePanel.isDisposed) then 
            guidePanel:removeFromParentAndCleanup(true) 
            guidePanel = nil
        end
        self.maskInputLayer:setVisible(false)
        self.maskLayer:setVisible(false)
        self._revertNewLotteryGuide_2 = nil

        if self.maskInputLayer.skinBtn then
            self.maskInputLayer.skinBtn:removeFromParentAndCleanup(true)
            self.maskInputLayer.skinBtn = nil
        end
        self.allowBackKeyTap = true
    end

    self._revertNewLotteryGuide_2 = endGuide


    local skinBtn = UIHelper:skipButton('跳过', endGuide)
    self.maskInputLayer:addChild(skinBtn)
    self.maskInputLayer.skinBtn = skinBtn

    layoutUtils.setNodeRelativePos(skinBtn, layoutUtils.MarginType.kLEFT, -35)
    layoutUtils.setNodeRelativePos(skinBtn, layoutUtils.MarginType.kTOP, -10)

    self.allowBackKeyTap = false

end

return LotteryPanel
