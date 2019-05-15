require "plua.myCCNode"
myCCScene = class(myCCNode)


function myCCScene:ctor()

end


function myCCScene.create()
	local scene = myCCScene.new()
	return scene
end

CCScene = myCCScene

HeDisplayUtil = class()

function HeDisplayUtil:setRotationX()
	
end

function HeDisplayUtil:setRotationY()
	
end

function HeDisplayUtil:getNodeGroupBounds()
	return CCRectMake(0, 0, 1, 1)
end

function HeDisplayUtil:getNodeBounds()
	return CCRectMake(0, 0, 1, 1)
end

function HeDisplayUtil:getRotationX()
	return 1
end

function HeDisplayUtil:getRotationY()
	return 1
end

function HeDisplayUtil:getBoundingBox()
	return CCRectMake(0, 0, 1, 1)
end

function HeDisplayUtil:enableShadow()
end

function HeDisplayUtil:disableShadow()
end

function HeDisplayUtil:setFontFillColor()
end

function HeDisplayUtil:getNodePosition()
	return ccp(0,0)
end

function HeDisplayUtil:ccc3FromUInt()
	return {r=1, g=1, b=1}
end

function HeDisplayUtil:ccc4FromUInt()
	return {r=1, g=1, b=1, a=1}
end

function HeDisplayUtil:uintFromCCC4()
	return 1
end

function HeDisplayUtil:uintFromCCC3()
	return 1
end


