
-- Copyright C2009-2013 www.happyelements.com, all rights reserved.
-- Create Date:	2013年10月19日 13:48:24
-- Author:	ZhangWan(diff)
-- Email:	wanwan.zhang@happyelements.com

require "hecore.class"
---------------------------------------------------
-------------- CallbackChain
---------------------------------------------------

CallbackChain = class()

function CallbackChain:ctor()
end

function CallbackChain:init(...)
	assert(#{...} == 0)

	self.functions = {}
end

function CallbackChain:appendFunc(funcAcceptCallback, ...)
	assert(type(funcAcceptCallback) == "function")
	assert(#{...} == 0)

	table.insert(self.functions, funcAcceptCallback)
end

function CallbackChain:call(...)
	assert(#{...} == 0)

	self.curFuncIndex = 1

	local function callback()
		self.curFuncIndex = self.curFuncIndex + 1

		local nextFunc = self.functions[self.curFuncIndex]

		if nextFunc then

			if self.curFuncIndex == #self.functions then
				nextFunc()
			else
				nextFunc(callback)
			end
		end
	end

	local firstFunc = self.functions[1]
	assert(firstFunc)

	firstFunc(callback)
end

function CallbackChain:create(...)
	assert(#{...} == 0)

	local newCallbackChain = CallbackChain.new()
	newCallbackChain:init()
	return newCallbackChain
end

-------------------------------------
------ For How To Use See Below Test 
-------------------------------------
--
--local function c()
--	if _G.isLocalDevelopMode then printx(0, "Func c is Called !") end
--end
--
--local function a(ap1, ap2, aFinishCallback, ...)
--	assert(ap1)
--	assert(ap2)
--	assert(type(aFinishCallback) == "function")
--	assert(#{...} == 0)
--
--	if _G.isLocalDevelopMode then printx(0, "Func a is called ! ") end
--	if _G.isLocalDevelopMode then printx(0, "\t" .. "ap1:" .. ap1) end
--	if _G.isLocalDevelopMode then printx(0, "\t" .. "ap2:" .. ap2) end
--	if _G.isLocalDevelopMode then printx(0, "Func a is Finished !") end
--
--	aFinishCallback()
--end
--
--local function b(bp1, bp2, bFinishCallback, ...)
--	assert(bp1)
--	assert(bp2)
--	assert(type(bFinishCallback) == "function")
--	assert(#{...} == 0)
--
--	if _G.isLocalDevelopMode then printx(0, "Func b is called !") end
--	if _G.isLocalDevelopMode then printx(0, "\t" .. "bp1:" .. bp1) end
--	if _G.isLocalDevelopMode then printx(0, "\t" .. "bp2:" .. bp2) end
--	if _G.isLocalDevelopMode then printx(0, "Func b is Finished !") end
--
--	bFinishCallback()
--end
--
--
--local chain = CallbackChain:create()
--
--local function funcAWrapper(callback)
--	a(1, 2, callback)
--end
--
--local function funcBWrapper(callback)
--	b(3, 4, callback)
--end
--
--chain:appendFunc(funcAWrapper)
--chain:appendFunc(funcBWrapper)
--chain:appendFunc(c)
--chain:call()
--debug.debug()
