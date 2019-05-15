PropListAnimationController = class()

function PropListAnimationController:ctor(propList)
	self.propList = propList
end

function PropListAnimationController:create(propList)
	local controller = PropListAnimationController.new(propList)
	controller:init()

	return controller
end

function PropListAnimationController:init()

end

function PropListAnimationController:registerUsePropCallback(usePropCallback, ...)
	assert(type(usePropCallback) == "function")
	assert(#{...} == 0)

	if _G.isLocalDevelopMode then printx(0, "PropListAnimation:registerUsePropCallback Called !") end
	self.usePropCallback = usePropCallback
end

function PropListAnimationController:registerCancelPropUseCallback(callbackFunc, ...)
	assert(type(callbackFunc) == "function")
	assert(#{...} == 0)

	self.cancelPropUseCallback = callbackFunc
end

function PropListAnimationController:registerBuyPropCallback(callbackFunc, ...)
	assert(type(callbackFunc) == "function")
	assert(#{...} == 0)

	self.buyPropCallback = callbackFunc
end

function PropListAnimationController:callBuyPropCallback(itemId, ...)
	assert(type(itemId) == "number")
	assert(#{...} == 0)

	self.buyPropCallback(itemId)
end

function PropListAnimationController:callUsePropCallback(propItemUsed, itemId, usePropType, expireTime, isRequireConfirm, isGuideRefresh, noGuide, ...)
	assert(propItemUsed)
	assert(type(itemId) == "number")
	assert(type(usePropType) == "number")
	assert(type(isRequireConfirm) == "boolean")
	assert(#{...} == 0)
	self.propList.propItemUsed = propItemUsed

	if self.usePropCallback then
		return self.usePropCallback(itemId, usePropType, expireTime, isRequireConfirm, isGuideRefresh, noGuide)
	end
	return true
end

function PropListAnimationController:callCancelPropUseCallback(itemId,confirm, ...)
	assert(#{...} == 0);

	if self.cancelPropUseCallback then
		self.cancelPropUseCallback(itemId, confirm)
	end
end

function PropListAnimationController:registerSpringItemCallback(callback)
  	self.springItemCallback = callback
end

function PropListAnimationController:callHelpCallback( ... )
	if self.helpCallback then
		self.helpCallback()
	end
end
function PropListAnimationController:registerHelpCallback(callback)
	self.helpCallback = callback
end