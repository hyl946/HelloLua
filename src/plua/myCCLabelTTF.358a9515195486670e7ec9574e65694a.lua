require "plua.myCCNode"


myCCLabelTTF = class(myCCNode)
function myCCLabelTTF.create()
	local ttf = myCCLabelTTF.new()
	return ttf
end

function myCCLabelTTF:setString( label)
	self.string = label
end
function myCCLabelTTF:getString()
	return self.string or ""
end

function myCCLabelTTF:getHorizontalAlignment()
	
end
function myCCLabelTTF:setHorizontalAlignment(alignment)
	
end

function myCCLabelTTF:getVerticalAlignment()
	
end
function myCCLabelTTF:setVerticalAlignment(verticalAlignment)
	
end

function myCCLabelTTF:getDimensions()
	return self.dimensions or CCSizeMake(10, 10)
end
function myCCLabelTTF:setDimensions(dim)
	self.dimensions = dim
end

function myCCLabelTTF:getFontSize()
	return self.fontSize or 5
end

function myCCLabelTTF:setFontSize(fontSize)
	self.fontSize = fontSize
end

function myCCLabelTTF:getFontName()
	return self.fontName or "asdf"
end
function myCCLabelTTF:setFontName(fontName)
	self.fontName = fontName
end

CCLabelTTF = myCCLabelTTF
