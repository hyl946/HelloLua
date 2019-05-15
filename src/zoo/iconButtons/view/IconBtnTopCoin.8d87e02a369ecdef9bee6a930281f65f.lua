
IconBtnTopCoin = class(IconBtnTopBase)

function IconBtnTopCoin:ctor()
	self.coinNumber = -1
end

function IconBtnTopCoin:init()
	self.ui	= ResourceManager:sharedInstance():buildGroup("home_top_bar/icon_btn_coin")
	IconBtnTopBase.init(self, self.ui)
	
	self:updateView()
end

function IconBtnTopCoin:updateView()
	local coinNumber = UserManager.getInstance().user:getCoin()
	if coinNumber ~= self.coinNumber then
		self.coinNumber = coinNumber
		self:showCoinNum(coinNumber) 
	end
end

function IconBtnTopCoin:showCoinNum(coinNumber)
	if coinNumber > 100000 then
		local intNum, floatNum = math.floor(coinNumber / 10000), math.floor((coinNumber % 10000) / 100) --小数部分取小数点后两位
		if floatNum > 0 then
			local floatPart = string.sub(tostring(floatNum / 100.0), 2)
			coinStr = intNum .. floatPart .. "万"
		else
			coinStr = intNum .. "万"
		end
	else
		coinStr = tostring(coinNumber)
	end
	self:setLabel(coinStr)
end

function IconBtnTopCoin:create()
	local btn = IconBtnTopCoin.new()
	btn:init()
	return btn
end