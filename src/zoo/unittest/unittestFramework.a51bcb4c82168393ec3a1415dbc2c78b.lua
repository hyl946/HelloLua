require 'zoo.unittest.unittestTask'
require 'hecore.class'

UnittestFramework = class()

function UnittestFramework:getInstance()
	if not UnittestFramework._instance then
		UnittestFramework._instance = UnittestFramework.new()
	end
	return UnittestFramework._instance
end

function UnittestFramework:ctor()
	-- self.taskQueue = {}
	-- self.globalVariablesNamesStack = {}
end

-- function UnittestFramework:addTask(task)
-- 	if task then
-- 		table.insert(self.taskQueue, task)
-- 	end
-- end

function UnittestFramework:run( filename )
	self.success = false
	self.message = ''
	self.filename = filename

	self.scene = create_scene()
	CCDirector:sharedDirector():runWithScene(self.scene)

	self.scene:runAction(CCCallFunc:create(function ()
		self:testing()
	end))

	local context = self
	local function interrupt()
		print('=======================================================')
		print('unittest timeout ( 60 sec )')
		print('interruptted incorrectly')
		print(filename)
		print('=======================================================')
		context.success = false
		context.message = 'unittest timeout ( 60 sec )'
		context:complete()
	end
	self.hwndOnTimeout = setTimeOut(interrupt, 60)
end

function UnittestFramework:testing()
	local stack = ''
	local errorMsg = ""
	local function onError( e )
		stack = debug.traceback()
		errorMsg = e
	end

	if false then
		self:_testing()
	else
		local r = xpcall(self._testing, onError, self)
		if not r then
			local m = errorMsg .. '\n' .. stack
			self.success = false
			self.message = m
			self:complete()
		end
	end
end

function UnittestFramework:_testing()
	print('testing case : ' .. self.filename)
	require ('zoo.unittest.heai.' .. self.filename)
	local t = _G[self.filename].new()

	local context = self
	local function on_success_message(success, msg)
		context.success = success
		context.message = msg
		context:complete()
	end

	t:run(on_success_message)
end

function UnittestFramework:complete()
	if not self.success then
		print(self.message)
		print('UNIT_TEST_FAILED, filename = ' .. self.filename)
		print('\n')
	else
		print('success')
		print('\n')
	end
	CCDirector:sharedDirector():endToLua()
end



