require "hecore.display.Director"

ProgressBar = class(EventDispatcher)

function ProgressBar:ctor( display, direction )
	self.display = display
	self.progress = 100
	self.direction = direction or 0

	local bounds = display:getContentSize()
	self.originalWidth = bounds.width
	self.originalHeight = bounds.height
end
function ProgressBar:initProgressBar()
	local  display = self.display
	if display then
		
	else if _G.isLocalDevelopMode then printx(0, "no display assign to ProgressBar") end end
end

function ProgressBar:dispose()
	
end

local  function clamp( value, min, max )
	local  min = min or 0
	local  max = max or 100
	if min > max then min, max = max, min end

	if value < min then value = min end
	if value > max then value = max end
	return value
end

function ProgressBar:setPercentage( percent )
	self.progress = clamp(percent)
	self:updateProgress()
end
function ProgressBar:getPercentage( )
	return self.progress
end

function ProgressBar:updateProgress( )
	local display = self.display
	if display then
		local textureRect = display:getTextureRect()
		if self.direction == 0 then
			local transformedWidth = self.progress * self.originalWidth * 0.01
			textureRect.size.width = transformedWidth
		else
			local transformedHeight = self.progress * self.originalHeight * 0.01
			textureRect.size.height = transformedHeight
		end
		display:setTextureRect2(textureRect, false, textureRect.size);
	end
end

function ProgressBar:setVisible( v )
	local  display = self.display
	if display then display:setVisible(v) end
end

function ProgressBar:create(display, direction)
	local ret = ProgressBar.new(display, direction)
	ret:initProgressBar()
	return ret
end