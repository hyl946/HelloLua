
IconBtnTopGold = class(IconBtnTopBase)

function IconBtnTopGold:ctor()
	self.goldNumber = -1
end

function IconBtnTopGold:init()
	self.ui	= ResourceManager:sharedInstance():buildGroup("home_top_bar/icon_btn_gold")
	IconBtnTopBase.init(self, self.ui)
	
	self:updateView()
end

function IconBtnTopGold:updateView()
	local goldNumber = UserManager:getInstance().user:getCash()
	if goldNumber ~= self.goldNumber then
		self.goldNumber = goldNumber
		self:setLabel(goldNumber) 
	end
end

function IconBtnTopGold:getPlusIconWidth()
	return 22
end

function IconBtnTopGold:create()
	local btn = IconBtnTopGold.new()
	btn:init()
	return btn
end