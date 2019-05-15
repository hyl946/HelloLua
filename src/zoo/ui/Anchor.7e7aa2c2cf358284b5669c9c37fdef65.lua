

ANCHOR_ALIGN_NONE = 0
ANCHOR_ALIGN_CENTER = 1
ANCHOR_ALIGN_TOP = 2
ANCHOR_ALIGN_BOTTOM = 3
ANCHOR_ALIGN_LEFT = 4
ANCHOR_ALIGN_RIGHT = 5
ANCHOR_ALIGN_LEFTTOP = 6
ANCHOR_ALIGN_RIGHTTOP = 7
ANCHOR_ALIGN_LEFTBOTTOM = 8
ANCHOR_ALIGN_RIGHTBOTTOM = 9


local anchor = {}
anchor.__index = anchor

--[[
owner:
	target node to be controlled
align:
	align mode, used to calculate anchor point
param:
	parent: if nil, use owner.parent
	ox: offset x
	oy: offset y 
	parentGroup: use group size for parent 
	ownerGroup: use group size for owner
]]
function anchor:new(owner, align, param)
	param = param or {}

	local p = {}
	setmetatable(p, anchor)

	p.owner = owner
	p.align = align or ANCHOR_ALIGN_NONE
	p.parent = param.parent
	p.offsetX = param.ox or 0
	p.offsetY = param.oy or 0
	p.parentUseGroupSize = param.parentGroup or false
	p.ownerUseGroupSize = param.ownerGroup or false
	p:adjust()

	return p
end

function anchor:getParent()
	local parent = self.parent or self.owner.parent
	if parent == nil or parent.isDisposed then
		return nil
	end
	return parent
end

function anchor:adjust()
	if self:getParent() == nil then
		return
	end

	if self.align == ANCHOR_ALIGN_NONE then
		self:adjust_none()
	elseif self.align == ANCHOR_ALIGN_CENTER then
		self:adjust_center()
	elseif self.align == ANCHOR_ALIGN_TOP then
		self:adjust_top()
	elseif self.align == ANCHOR_ALIGN_BOTTOM then
		self:adjust_bottom()
	elseif self.align == ANCHOR_ALIGN_LEFT then
		self:adjust_left()
	elseif self.align == ANCHOR_ALIGN_RIGHT then
		self:adjust_right()
	elseif self.align == ANCHOR_ALIGN_LEFTTOP then
		self:adjust_lefttop()
	elseif self.align == ANCHOR_ALIGN_RIGHTTOP then
		self:adjust_righttop()
	elseif self.align == ANCHOR_ALIGN_LEFTBOTTOM then
		self:adjust_leftbottom()
	elseif self.align == ANCHOR_ALIGN_RIGHTBOTTOM then
		self:adjust_rightbottom()
	end

end

function anchor:getSize()
	local contentSize
	if self.ownerUseGroupSize then
		contentSize = self.owner:getGroupBounds()
	else
		contentSize = self.owner:getContentSize()
	end

	local parent = self:getParent()
	local parentBounding
	if self.parentUseGroupSize then
		parentBounding = parent:getGroupBounds()
	else
		parentBounding = parent:boundingBox()
	end

	return contentSize, parentBounding
end

function anchor:adjust_none()

end

function anchor:adjust_center()
	local contentSize, parentBounding = self:getSize()

	local x = (parentBounding:getMaxX() + parentBounding:getMinX() - contentSize.width) / 2
	local y = (parentBounding:getMaxY() + parentBounding:getMinY() - contentSize.height) / 2
	self.owner:setPositionX(x + self.offsetX)
	self.owner:setPositionY(y + self.offsetY)

end

function anchor:adjust_top()
	local contentSize, parentBounding = self:getSize()

	local x = (parentBounding:getMaxX() + parentBounding:getMinX() - contentSize.width) / 2
	local y = (parentBounding:getMaxY() - contentSize.height)
	self.owner:setPositionX(x + self.offsetX)
	self.owner:setPositionY(y + self.offsetY)

end

function anchor:adjust_bottom()
	local contentSize, parentBounding = self:getSize()

	local x = (parentBounding:getMaxX() + parentBounding:getMinX() - contentSize.width) / 2
	local y = parentBounding:getMinY()
	self.owner:setPositionX(x + self.offsetX)
	self.owner:setPositionY(y + self.offsetY)

end

function anchor:adjust_left()
	local contentSize, parentBounding = self:getSize()

	local x = parentBounding:getMinX()
	local y = (parentBounding:getMaxY() + parentBounding:getMinY() - contentSize.height) / 2
	self.owner:setPositionX(x + self.offsetX)
	self.owner:setPositionY(y + self.offsetY)

end

function anchor:adjust_right()
	local contentSize, parentBounding = self:getSize()

	local x = (parentBounding:getMaxX() - contentSize.width)
	local y = (parentBounding:getMaxY() + parentBounding:getMinY() - contentSize.height) / 2
	self.owner:setPositionX(x + self.offsetX)
	self.owner:setPositionY(y + self.offsetY)

end


function anchor:adjust_lefttop()
	local contentSize, parentBounding = self:getSize()

	local x = parentBounding:getMinX()
	local y = (parentBounding:getMaxY() - contentSize.height)
	self.owner:setPositionX(x + self.offsetX)
	self.owner:setPositionY(y + self.offsetY)

end

function anchor:adjust_rightbottom()
	local contentSize, parentBounding = self:getSize()

	local x = (parentBounding:getMaxX() - contentSize.width)
	local y = parentBounding:getMinY()
	self.owner:setPositionX(x + self.offsetX)
	self.owner:setPositionY(y + self.offsetY)

end

function anchor:adjust_righttop()
	local contentSize, parentBounding = self:getSize()

	local x = (parentBounding:getMaxX() - contentSize.width)
	local y = (parentBounding:getMaxY() - contentSize.height)
	self.owner:setPositionX(x + self.offsetX)
	self.owner:setPositionY(y + self.offsetY)

end

function anchor:adjust_leftbottom()
	local contentSize, parentBounding = self:getSize()

	local x = parentBounding:getMinX()
	local y = parentBounding:getMinY()
	self.owner:setPositionX(x + self.offsetX)
	self.owner:setPositionY(y + self.offsetY)

end


return anchor

