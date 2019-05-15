
require 'zoo.quarterlyRankRace.plugins.BasePlugin'

local Page = class(BasePlugin)

function Page:onPluginInit( ... )

	if not BasePlugin.onPluginInit(self, ...) then return false end
	
	local sizeNode = self:getChildByPath('size')

	if not sizeNode then
		return false
	end

	local size = sizeNode:getContentSize()
	local sx, sy = sizeNode:getScaleX(), sizeNode:getScaleY()
	size = CCSizeMake(sx * size.width, sy * size.height)
	sizeNode:setVisible(false)

	local num = 0

	for i = 1, 999 do
		local page = self:getChildByPath('./page' .. i)
		if page then
			num = num + 1
		else
			break
		end
	end

	local useClip = true
	if string.find(self.symbolName, 'noClip') then
		useClip = false
	end


	self.pagedView = PagedView:create(size.width, size.height, num, self, useClip, true)
	self.pagedView:setIgnoreVerticalMove(false)
	self:addChild(self.pagedView)
	self.pagedView:setPositionY(-size.height)

	self.pageshowedRange = 0

	local context = self
	function context.pagedView:__shouldShowPage( pageIndex )
		return math.abs(pageIndex - self.pageIndex) <= context.pageshowedRange
	end

	for i = 1, 999 do
		local item = self:getChildByPath('./page' .. i)
		if item then
			item:removeFromParentAndCleanup(false)
			item:setPosition(ccp(0, 0))
			item:setRotation(0)
			item:setScaleX(1)
			item:setScaleY(1)
				
			self.pagedView:addPageAt(item, i)

		else
			break
		end
	end

	return true
end

function Page:prev( ... )
	if self.isDisposed then return end
	-- body
	local index = self.pagedView:getPageIndex()
	self:callAncestors('onPageTo', index)
end

function Page:next( ... )
	if self.isDisposed then return end
	local index = self.pagedView:getPageIndex()
	self:callAncestors('onPageTo', index)
end

function Page:goto( ... )
	if self.isDisposed then return end
	local index = self.pagedView:getPageIndex()
	self:callAncestors('onPageTo', index)
end

function Page:turnTo(index, duration)
	self.pagedView:gotoPage(index, duration)
end

function Page:setShowedRange( range )
	self.pageshowedRange = range
end

return Page