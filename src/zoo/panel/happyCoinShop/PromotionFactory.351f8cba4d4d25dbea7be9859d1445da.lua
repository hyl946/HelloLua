require 'zoo.panel.happyCoinShop.HappyCoinShopFactory'

local PromotionFactory = class()

function PromotionFactory:createPromotionManager( ... )
	_G.PromotionManager = require 'zoo.panel.happyCoinShop.PromotionManager'
	if _G.PromotionManager then
		_G.PromotionManager:createInstance()
	end
end

function PromotionFactory:__getQuickPayConfirmPanel( ... )
	require "zoo.panel.happyCoinShop.PromotionQuickPayConfirmPanel_1_45_B"
end

function PromotionFactory:getQuickPayConfirmPanel( ... )
	if not self.quickPayConfirmPanel then
		self.quickPayConfirmPanel = self:__getQuickPayConfirmPanel()
	end

	return self.quickPayConfirmPanel
end

PromotionFactory:createPromotionManager()

return PromotionFactory