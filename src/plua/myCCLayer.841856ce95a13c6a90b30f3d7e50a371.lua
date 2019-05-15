require "plua.myCCSprite"
myCCLayer = class(myCCSprite)

function myCCLayer.create()
	local layer = myCCLayer.new()
	return layer
end

function myCCLayer:registerScriptTouchHandler()
end

function myCCLayer:unregisterScriptTouchHandler()
end

function myCCLayer:setTouchEnabled()
end

function myCCLayer:isTouchEnabled()
end

function myCCLayer:setAccelerometerEnabled(v) end
function myCCLayer:isAccelerometerEnabled(v) return false end
function myCCLayer:setKeypadEnabled(v) end
function myCCLayer:isKeypadEnabled(v) return false end
function myCCLayer:setTouchMode(v) end
function myCCLayer:getTouchMode(v) return 0 end
function myCCLayer:setTouchPriority(v) end
function myCCLayer:getTouchPriority(v) end
function myCCLayer:registerScriptKeypadHandler(v) end
function myCCLayer:unregisterScriptKeypadHandler(v) end
function myCCLayer:registerScriptAccelerateHandler(v) end
function myCCLayer:unregisterScriptAccelerateHandler(v) end
function myCCLayer:getOpacity(v) 
	return 255
end
function myCCLayer:getDisplayedOpacity(v) end
function myCCLayer:setOpacity(v) 
	return 1
end
function myCCLayer:updateDisplayedOpacity(v) end
function myCCLayer:isCascadeOpacityEnabled(v) end
function myCCLayer:setCascadeOpacityEnabled(v) end
function myCCLayer:getColor(v) 
	return ccc3(1,1,1)
end
function myCCLayer:getDisplayedColor(v) 
	return ccc3(1,1,1)
end
function myCCLayer:setColor(v) end
function myCCLayer:updateDisplayedColor(v) end
function myCCLayer:isCascadeColorEnabled(v) end
function myCCLayer:setCascadeColorEnabled(v) end
function myCCLayer:changeWidth(v) end
function myCCLayer:changeHeight(v) end
function myCCLayer:changeWidthAndHeight(v) end
function myCCLayer:setContentSize(v) end
function myCCLayer:setBlendFunc(v) end
function myCCLayer:getBlendFunc(v) end
function myCCLayer:setOpacityModifyRGB(v) end
function myCCLayer:isOpacityModifyRGB(v) end



myCCLabelTTF = class(myCCLayer)
function myCCLabelTTF.create()
	local ttf = myCCLabelTTF.new()
end

CCLabelTTF = myCCLabelTTF
CCLayer = myCCLayer