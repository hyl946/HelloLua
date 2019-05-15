require "plua.myCCNode"
myCCLayerColor = class(myCCLayer)


function myCCLayerColor:ctor()

end

function myCCLayerColor.create()
	local layer = myCCLayerColor.new()
	return layer
end

CCLayerColor = myCCLayerColor

CCLayerGradient = class(myCCLayerColor)
function CCLayerGradient.create()
	local layer = CCLayerGradient.new()
	return layer
end

function CCLayerGradient:setStartColor(v)
	self.StartColor = v
end

function CCLayerGradient:getStartColor()
	return self.StartColor or {r=1, g=1, b=1}
end

function CCLayerGradient:setEndColor(v)
	self.EndColor = v
end

function CCLayerGradient:getEndColor(v) return self.EndColor or {r=1, g=1, b=1} end

function CCLayerGradient:setStartOpacity(v) self.StartOpacity = v end
function CCLayerGradient:getStartOpacity(v) return self.StartOpacity or 1 end

function CCLayerGradient:setEndOpacity(v) self.EndOpacity = v end
function CCLayerGradient:getEndOpacity(v) return self.EndOpacity or 1 end

