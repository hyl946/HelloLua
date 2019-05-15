require "hecore.display.CocosObject"
require "hecore.EventDispatcher"

--
--




HaloBaseView = class(CocosObject)

function HaloBaseView:ctor()
	
	self._className = "src.zoo.ui.halo.haloCore.HaloBaseView"
	self._modMap = {}

end

--
--
--
--
--
--

function HaloBaseView:create( createData )
	local view = HaloBaseView.new()
	view:init( createData )
	return view
end

--
--
--

function HaloBaseView:init( createData )
	self:setRefCocosObj(CCNode:create())
	self:build( createData )
end

--
--
--
--

function HaloBaseView:build( createData )
	
end

--
--
--

function HaloBaseView:addMod( mod , modCreateData , modName )
	assert( mod )

	local modClassName = mod:getClassName()
	if self._modMap[ modClassName ] then
		assert( false , "has same type mod !" )
	end

	self._modMap[ modClassName ] = mod

	if modCreateData then
		mod:build( modCreateData )
	end

	if modName then
		self[ modName ] = mod
	end

	mod:setTargetHolder( self )
end


--
--
--

function HaloBaseView:addModByClass( modClassName , modCreateData , modName )
	assert( modClassName )

	local ModClass = nil

	local function requireModClass()
		local fixClassName = string.gsub( modClassName , "(%.)" , "%/" ) .. ".lua"
		ModClass = require( fixClassName )
	end
	
	xpcall( requireModClass , __G__TRACKBACK__ )

	if ModClass then

		local mod = ModClass:create()
		self:addMod( mod , modCreateData , modName )

	else
		assert( ModClass )
	end
end

--
--

function HaloBaseView:getModByName( modName )
	return self[ modName ]
end

--
--

function HaloBaseView:getModByClass( modClassName )
	return self._modMap[ modClassName ]
end

--
--

function HaloBaseView:getClassName()
	return self._className
end

--
--
--
--

function HaloBaseView:setName( name )
	self.name = name
end

function HaloBaseView:getName( ... )
	return self.name or 'noName'
end

--[[
function HaloBaseView:hasEventListener(eventName, listener)
	return self.eventDispatcher:hasEventListener(eventName, listener)
end

function HaloBaseView:hasEventListenerByName(eventName)
	return self.eventDispatcher:hasEventListenerByName(eventName)
end

function HaloBaseView:addEventListener(eventName, listener, context)
	self.eventDispatcher:addEventListener(eventName, listener, context)
end

function HaloBaseView:removeEventListener(eventName, listener, ...)
	self.eventDispatcher:removeEventListener(eventName, listener, ...)
end

function HaloBaseView:removeEventListenerByName(eventName)
	self.eventDispatcher:removeEventListenerByName(eventName)
end

function HaloBaseView:removeAllEventListeners()
	self.eventDispatcher:removeAllEventListeners()
end
]]