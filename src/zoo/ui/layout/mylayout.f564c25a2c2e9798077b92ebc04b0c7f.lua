require 'hecore.class'

local function log(s)
	printx(-97, s)
end

myLayoutCtrl = {}
myLayoutCtrl.enabled = false
myLayoutCtrl.targets = {}

function myLayoutCtrl:add(target, factory)
	if target.refCocosObj then
		if not table.findItem(self.targets, target) then
			target._onDeviceResolutionChange = factory(target)
			self.targets[#self.targets + 1] = target
			log('add, count = ' .. #self.targets)
			-- target:setPositionY_(target:getPositionY())
		end
	else
		log('fail to add, lack refCocosObj')
	end
end

function myLayoutCtrl:del(target)
	if target._onDeviceResolutionChange then
		table.removeValue(self.targets, target)
		target._onDeviceResolutionChange = nil
		target:clearPositionY_()
		target:clearScaleX_()
		target:clearScaleY_()
		log('del, count = ' .. #self.targets)
	end
end

function myLayoutCtrl:notify2all()
	for i = 1, #self.targets do
		v = self.targets[i]
		v._onDeviceResolutionChange()
	end
end


local tickHandler = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(
	function ()
		myLayoutCtrl:notify2all()
	end, 0, false)


---------------------------------------------------------------
-- utils
---------------------------------------------------------------

local function getScreenParameter()
	local parameter = {
		win_height = CCDirector:sharedDirector():getWinSize().height,
		visible_height = CCDirector:sharedDirector():getVisibleSize().height,
	}
	return parameter
end

local function getItemParameter(item, p)
	local parameter = p or {}
	parameter.y = item:getPositionY()
	return parameter
end

---------------------------------------------------------------
-- factory
-- parameter:
-- item
---------------------------------------------------------------

-- function layout_factory_reposition(item)
-- 	local _screen = getScreenParameter()
-- 	local _target = getItemParameter(item)

-- 	local function worker()
-- 		local screen = getScreenParameter()
-- 		if screen.visible_height == _screen.visible_height then
-- 			getItemParameter(item, _target)
-- 			print('update y = ' .. tostring(_target.y))
-- 		end

-- 		local y = _target.y / _screen.win_height * screen.win_height
-- 		item:setPositionY(y)
-- 	end

-- 	return worker
-- end


function layout_factory_2bottom(item)

	local function worker()
		-- log('layout_factory_2bottom')
		
		local oh = CCDirector:sharedDirector():getVisibleSize().height
		local nh = CCDirector:sharedDirector():getVisibleSizeY_()

		local oy = item:getPositionY()
		local ny = oy / oh * nh
		item:setPositionY_(ny)
		-- log("layout_factory_reposition: "..tostring(oy)..','..tostring(ny)..','..tostring(oh)..','..tostring(nh))

	end

	return worker
end


function layout_factory_2top(item)

	local function worker()
		-- log('layout_factory_2top')

		local oh = CCDirector:sharedDirector():getVisibleSize().height
		local nh = CCDirector:sharedDirector():getVisibleSizeY_()

		local oy = item:getPositionY()
		local ny = nh - (oh - oy)
		item:setPositionY_(ny)
		-- log("layout_factory_reposition: "..tostring(oy)..','..tostring(ny)..','..tostring(oh)..','..tostring(nh))

	end

	return worker
end

function layout_factory_2center(item)

	local function worker()
		-- log('layout_factory_2center')

		local oh = CCDirector:sharedDirector():getVisibleSize().height
		local nh = CCDirector:sharedDirector():getVisibleSizeY_()

		local oy = item:getPositionY()
		local ny = oy - oh / 2 + nh / 2
		item:setPositionY_(ny)
		-- log("layout_factory_reposition: "..tostring(oy)..','..tostring(ny)..','..tostring(oh)..','..tostring(nh))

	end

	return worker
end


function layout_factory_widthscale(item)

	local function worker()
		-- log('layout_factory_widthscale')

		local oh = CCDirector:sharedDirector():getVisibleSize().height
		log(oh)
		local nh = CCDirector:sharedDirector():getVisibleSizeY_()
		log(nh)

		local scale = nh / oh
		log(scale)
		item:setScaleX_(scale)
		log(scale)
		item:setScaleY_(scale)
		log(scale)
		-- print(scale)
		-- debug.debug()
		log("layout_factory_widthscale: "..tostring(oh)..','..tostring(nh)..','..tostring(scale))

	end

	return worker
end

