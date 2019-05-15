require "hecore.class"

CCPoint = class()
function CCPoint:ctor(x, y)
	self.x = x
	self.y = y
end

function CCPoint:equals(p)
	return (self.x == p.x and self.y == p.y)
end

function CCPointMake(x, y) return ccp(x,y) end

function ccp(x, y)
	local p = CCPoint.new(x,y)
	return p
end

function ccc3(r, g, b) return {r=r, g=g, b=b} end
function ccc4(r, g, b, a) return {r=r, g=g, b=b, a=a} end

function ccpAdd(p1, p2)
	return ccp(p1.x + p2.x, p1.y + p2.y)
end

function ccpLength(p)
	return math.sqrt((p.x * p.x) + (p.y * p.y) )
end

function ccpSub(p1, p2)
	return ccp(p1.x-p2.x, p1.y-p2.y)
end

function ccpDistance(p1, p2)
	return math.sqrt((p1.x-p2.x)*(p1.x-p2.x) + (p1.y-p2.y)*(p1.y-p2.y))
end



CCSize = class()
function CCSize:ctor(width, height)
	self.width = width
	self.height = height
end



function CCSize:equals(size)
	return (self.width == size.width and self.height == size.height)
end

function CCSizeMake(width, height)
	return CCSize.new(width, height)
end

CCRect = class()
function CCRect:ctor(x, y, width, height)
	self.x=x
	self.y=y
	self.width=width
	self.height = height
	self.size = CCSizeMake(self.width, self.height)
	self.origin = ccp(self.x, self.y)
end

function CCRect:equals(rect)
    return (self.origin.equals(rect.origin) and self.size.equals(rect.size))
end

function CCRect:getMaxX()
    return (self.origin.x + self.size.width)
end

function CCRect:getMidX()
    return (self.origin.x + self.size.width / 2.0)
end

function CCRect:getMinX()
    return self.origin.x
end

function CCRect:getMaxY()
    return self.origin.y + self.size.height;
end

function CCRect:getMidY()
    return (self.origin.y + self.size.height / 2.0)
end

function CCRect:getMinY()
    return self.origin.y
end

function CCRect:containsPoint(point)
    local bRet = false
    if self.point.x >= getMinX() and point.x <= getMaxX() and point.y >= getMinY() and point.y <= getMaxY() then
        bRet = true;
    end
    return bRet
end

function CCRectMake(x, y, width, height)
	local rc = CCRect.new(x, y, width, height)
	return rc
end

HeMemDataHolder = class()
HeMemDataHolder.member = {}
function HeMemDataHolder:setInteger(key, value)
	HeMemDataHolder.member[key] = value
end

function HeMemDataHolder:getInteger(key)
	return HeMemDataHolder.member[key]
end

function HeMemDataHolder:setNumber(key, value)
	HeMemDataHolder.member[key] = value
end

function HeMemDataHolder:getNumber(key)
	return HeMemDataHolder.member[key]
end

function HeMemDataHolder:setString(key, value)
	HeMemDataHolder.member[key] = value
end

function HeMemDataHolder:getString(key)
	return HeMemDataHolder.member[key]
end

function HeMemDataHolder:deleteByKey(key)
	HeMemDataHolder.member[key] = nil
end

CCNotificationCenter = class()
function CCNotificationCenter:sharedNotificationCenter() return CCNotificationCenter.new() end
function CCNotificationCenter:registerScriptObserver(aaa) end


require "plua.myActionManager"
require "plua.myDirect"
require "plua.myCCNode"
require "plua.myCCLayer"
require "plua.myCCLayerColor"
require "plua.myCCScene"
require "plua.myCCDirect"
require "plua.myCCSprite"
require "plua.myCCLabelTTF"
require "plua.myCCAction"
require "plua.myCCSequence"
require "plua.myHeCore"
require "plua.myHttp"
require "plua.myCCUserDefault"
require "plua.myCCSpriteFrameCache"
require "plua.mySimpleAudioEngine"
