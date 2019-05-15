local IconProgressBar = require "zoo.iconButtons.view.IconProgressBar"

IconBtnTopStar = class(IconBtnTopBase)

function IconBtnTopStar:ctor()
	self.normalStar	= 0
	self.hiddenStar	= 0
	self.totalStar	= 0
end

function IconBtnTopStar:init()
	self.ui	= ResourceManager:sharedInstance():buildGroup("home_top_bar/icon_btn_star")
	IconBtnTopBase.init(self, self.ui)

	self:updateView()
end

function IconBtnTopStar:setNormalStar(normalStar)
	local changed = false
	if self.normalStar ~= normalStar then
		changed = true
	end 
	self.normalStar = normalStar
	return changed
end

function IconBtnTopStar:setHiddenStar(hiddenStar)
	local changed = false
	if self.hiddenStar ~= hiddenStar then
		changed = true
	end
	self.hiddenStar = hiddenStar
	return changed
end

function IconBtnTopStar:setTotalStar(totalStar)
	local changed = false
	if self.totalStar ~= totalStar then
		changed = true
	end
	self.totalStar = totalStar
	return changed
end

function IconBtnTopStar:updateView()
	local normalChange = self:setNormalStar(UserManager:getInstance().user:getStar())
	local hideChange = self:setHiddenStar(UserManager:getInstance().user:getHideStar())
	local totalChange = self:setTotalStar(UserManager:getInstance():getFullStarInOpenedRegionInclude4star() + MetaModel.sharedInstance():getFullStarInOpenedHiddenRegion())
	
	if normalChange or hideChange or totalChange then
		local curStarNum =  self.normalStar + self.hiddenStar
		if not self.progressBar then 
			self.progressBar = IconProgressBar:create(self.mainUI, curStarNum, self.totalStar)
		else
			if totalChange then 
				self.progressBar:setCurNumber(curStarNum, true)
				self.progressBar:setTotalNumber(self.totalStar)
			else
				self.progressBar:setCurNumber(curStarNum)
			end
		end

		self:setLabel(curStarNum .. "/" .. self.totalStar)
	end
end

function IconBtnTopStar:create()
	local btn = IconBtnTopStar.new()
	btn:init()
	return btn
end