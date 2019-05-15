require 'zoo.net.OnlineSetterHttp'


SellLogic = class()

function SellLogic:create(propsId, amount)
	assert(type(propsId) == 'number')
	assert(amount > 0)

	local instance = SellLogic.new(propsId, amount)
	return instance
end

function SellLogic:start(sucessCallback, failCallback, showLoading)

	local http = SellPropsHttp.new(showLoading)

	local function onSuccess(event)
		local propsData = MetaManager:getInstance():getPropMeta(self.propsId)
		local sellPrice = tonumber(propsData.sell) * self.amount
		local user = UserManager:getInstance():getUserRef()
		user:setCoin(user:getCoin() + sellPrice)
		UserManager:getInstance():addUserPropNumber(self.propsId, 0 - self.amount)
		if _G.isLocalDevelopMode then printx(0, string.format('sell item %d success for %d coins', self.propsId, sellPrice)) end
		local home = HomeScene:sharedInstance()
		home:checkDataChange()
		local button = home.coinButton
		if button then button:updateView() end
		if sucessCallback then sucessCallback() end
	end

	local function onFail(event)
		if _G.isLocalDevelopMode then printx(0, 'sell props ', self.propsId, 'failed') end
		if failCallback then failCallback() end
	end

	http:ad(Events.kComplete, onSuccess)
	http:ad(Events.kError, onFail)
	http:load(self.propsId, self.amount)

end

function SellLogic:ctor(propsId, amount)
	self.propsId = propsId
	self.amount = amount
end