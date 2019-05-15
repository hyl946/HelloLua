local OneGoodsFailTop_VerA = require 'zoo.panel.happyCoinShop.failTop.OneGoodsFailTop_VerA'
local OneGoodsFailTop_Penny = require 'zoo.panel.happyCoinShop.failTop.OneGoodsFailTop_Penny'
local ThreeGoodsFailTop_VerA = require 'zoo.panel.happyCoinShop.failTop.ThreeGoodsFailTop_VerA'
local FourGoodsFailTop_VerA = require 'zoo.panel.happyCoinShop.failTop.FourGoodsFailTop_VerA'

local OneGoodsFailTop_VerB = require 'zoo.panel.happyCoinShop.failTop.OneGoodsFailTop_VerB'
local ThreeGoodsFailTop_VerB = require 'zoo.panel.happyCoinShop.failTop.ThreeGoodsFailTop_VerB'
local FourGoodsFailTop_VerB = require 'zoo.panel.happyCoinShop.failTop.FourGoodsFailTop_VerB'

require 'zoo.panel.happyCoinShop.HappyCoinShopFactory'

local FailTopPanel = class(BasePanel)

function FailTopPanel:create(TopItemClass, config, onBuySuccess, onTimeOut)
    local panel = FailTopPanel.new()
    panel:loadRequiredResource("ui/newWindShop.json")
    panel:init(TopItemClass, config, onBuySuccess, onTimeOut)
    return panel
end

function FailTopPanel:init(TopItemClass, config, onBuySuccess, onTimeOut)
	local ui = TopItemClass:create(config, self.builder, onBuySuccess, onTimeOut)
	BasePanel.init(self, ui)
end

function FailTopPanel:createWithConfig( config, onBuySuccess, onTimeOut )
		
	local gifts = self:getGiftItems(config.goodsId)
	if PromotionManager and config.goodsId == PromotionManager:getPennyPayGoodsId() then
		return FailTopPanel:create(OneGoodsFailTop_Penny, config, onBuySuccess, onTimeOut)
	end

	if HappyCoinShopFactory:getInstance():shouldUse_1_45_A() then
		if #gifts == 3 then
			return FailTopPanel:create(ThreeGoodsFailTop_VerA, config, onBuySuccess, onTimeOut)
		elseif #gifts == 4 then
			return FailTopPanel:create(FourGoodsFailTop_VerA, config, onBuySuccess, onTimeOut)
		else
			return FailTopPanel:create(OneGoodsFailTop_VerA, config, onBuySuccess, onTimeOut)
		end
	else
		if #gifts == 3 then
			return FailTopPanel:create(ThreeGoodsFailTop_VerB, config, onBuySuccess, onTimeOut)
		elseif #gifts == 4 then
			return FailTopPanel:create(FourGoodsFailTop_VerB, config, onBuySuccess, onTimeOut)
		else
			return FailTopPanel:create(OneGoodsFailTop_VerB, config, onBuySuccess, onTimeOut)
		end
	end
end

function FailTopPanel:getGiftItems(goodsId)
	return MetaManager.getInstance():getGoodMeta(goodsId).items
end


function FailTopPanel:popout()
    self:scaleAccordingToResolutionConfig()
    self:setPositionForPopoutManager()
    self:setPositionX(self:getPositionX() + 0)
	PopoutManager:sharedInstance():add(self, true)
	self.allowBackKeyTap = true
end

return FailTopPanel