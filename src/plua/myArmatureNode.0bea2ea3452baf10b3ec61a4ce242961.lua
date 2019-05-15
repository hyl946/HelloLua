
Slot = class()
function Slot:ctor()
	self.display = myCCSprite.new()
end

function Slot:getCCDisplay()
	return self.display
end

function Slot:setDisplayImage(v)
	self.display = v
end

myArmatureNode = class(CocosObject)
arAnimation = class()

function myArmatureNode:ctor()
	self.ani = arAnimation.new()
	self.slotList = {}
end

function myArmatureNode:create( armatureName, setUpdateSchedule)
	local node = myArmatureNode.new(myCCSprite:create())
	return node
end

function myArmatureNode:getArmatureTexture()
	return self:getTexture()
end

function myArmatureNode:wrapWithBatchNode()
	local batchNode = myCCSprite:create()
	batchNode:addChild(self)
	self._batchNodeContainer = batchNode
	return batchNode
end

function myArmatureNode:getAnimationList()
	return {}
end

function myArmatureNode:getAnimation() 
	return self.ani
end

------------------------------------------------------------------------------------------------
-- params:
-- @animationName 	skeleton.xml中定义的animationName
-- @playTimes 		0: 循环播放; 大于1的数字: 具体的播放次数; 小于1的数字: 使用skeleton.xml中定义的播放次数
-- @duration		播放一次动画时长，单位为秒(s)，如果设置了循环播放，则每轮循环耗时均为duration
-- 剩下的几个参数存在感太低，其实是懒得写，详情参考Animation.cpp中的定义
------------------------------------------------------------------------------------------------
function myArmatureNode:play( animationName, playTimes, duration, fadeInTime, layer, group, fadeOutMode, displayControl, pauseFadeOut, pauseFadeIn )
	
end

function myArmatureNode:playByIndex( animationIndex, playTimes, duration, fadeInTime, layer, group, fadeOutMode, displayControl, pauseFadeOut, pauseFadeIn )
	
end

function myArmatureNode:gotoAndStop( animationName, time, normalizedTime, fadeInTime, duration )
	
end

function myArmatureNode:gotoAndStopByIndex( animationIndex, time, normalizedTime, fadeInTime, duration )
	
end

function myArmatureNode:setAnimationScale( animationScale )
	
end

function myArmatureNode:pause()
	
end

function myArmatureNode:resume()
	
end

function myArmatureNode:stop()
	
end

function myArmatureNode:update(passTime)
	
end

function myArmatureNode:getCurrentTime()
	return 0
end

function myArmatureNode:getTotalTime()
	return 0
end

function myArmatureNode:getSlot(slotName)
	local st = self.slotList[slotName]
	if st == nil then
		self.slotList[slotName] = Slot.new()
	end
	return st
end

function myArmatureNode:getCon( names )

	if type(names) ~= 'table' then
		names = {names}
	end

	local slot 

	for _, name in ipairs(names) do
		if not slot then
			slot = self.refCocosObj:getCCSlot(name)
		else
			slot = slot:getCCSlot(name)
		end
	    if not slot then
	        return 
	    end
	end
	
    return tolua.cast(slot:getCCDisplay(), "CCSprite")

end

myArmatureFactory = {}

function myArmatureFactory:ctor()
	self.displayList = {}
end

--------------------------------------------------------------------
function myArmatureFactory:add(path, skeletonName, textureName)

end

function myArmatureFactory:getTextureDisplay(frameName)
	local dp = self.displayList[frameName]
	if dp == nil then
		self.displayList[frameName] = myCCSprite.new()
	end
	return dp
end

function myArmatureFactory:remove(skeletonName, textureName)
	
end

ArmatureNode = myArmatureNode
ArmatureFactory = myArmatureFactory