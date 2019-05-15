--[[
 * AutoPopoutTest
 * @date    2018-10-30 15:25:05
 * @authors zhou.ding
 * @email 	zhou.ding@happyelements.com
--]]

AutoPopoutTest = class(UnittestTask)

function AutoPopoutTest:ctor()
	
end

--finished_cb(success, msg)
function AutoPopoutTest:run( finished_cb )
	self.finished_cb = finished_cb
	self:runTest()
end

function AutoPopoutTest:runTest()
	require "hecore.notify.Notify"
	require "zoo.scenes.component.HomeScene.popoutQueue.new.AutoPopout"

	_G.isLocalDevelopMode = true

	GameLauncherContext = {
		getInstance = function ( ... )
			return {
			onStartInitPopoutQueue = function ( ... )
				-- body
			end,
			onInitPopoutQueueDone = function ( ... )
				-- body
			end}
		end
	}

	AutoPopout.isHomeScene = function ()
		return true
	end

	AutoPopout.getOriConfig = function ()
		return (require 'zoo.unittest.autopopout.MockConfigs')
	end

	AutoPopout.haveWindowOnScreen = function (  )
		return false
	end

	AutoPopout.checkRecallUser = function ()
		
	end

	AutoPopout.waitSomeAction = function ()
		-- body
	end

	ClipBoardUtil = {
		getPasteText = function ( ... )
			-- body
		end
	}

	BroadcastManager = {
		getInstance = function ( ... )
			return {
				unActive = function ( ... )
					-- body
				end,
				active = function ( ... )
					-- body
				end
			}
		end
	}

	local ret = {}

	AutoPopout.print = function (context, ... )
		table.insert(ret, {...})
	end

	AutoPopout.isDebug = function (  )
		return false
	end

	-- local homeScene = CCScene:create()
	-- CCDirector:sharedDirector():runWithScene(homeScene)
	local homeScene = CCDirector:sharedDirector():getRunningScene()
	Notify:dispatch("AutoPopoutInitEvent", homeScene)

	local sources = {}
	for k,source in pairs(AutoPopoutSource) do
		if type(source) ~= 'function' then 
			table.insert(sources, source)
		end
	end
	
	local index = 1
	local checkFinished
	checkFinished = function ()
		if not sources[index] then
			homeScene:runAction(CCCallFunc:create(function ( ... )
				local function onError( e )
					print(e)
					print(debug.traceback())
				end
				local r = xpcall(self.validate, onError, self, ret)
				print(r)
				self.finished_cb(r, "")	
			end))
			return
		end

		if AutoPopout:entryPreHandler(sources[index]) then
			AutoPopout:check(AutoPopout.action)
		else
			checkFinished()
		end
		
		index = index + 1
	end

	Notify:register('AutoPopoutCheckEnd', checkFinished)

	checkFinished()

	return ret
end

function AutoPopoutTest:get()
	local path = HeResPathUtils:getAppAssetsPath() .. '/src/zoo/unittest/autopopout/autopopout.test'
	local file = io.open(path, "r")
    if file then
        local content = file:read("*a") 
        file:close()
        if content then
            return table.deserialize(content) or {}
        end
    end
    return {}
end

function AutoPopoutTest:validate( ret )
	-- print(table.tostring(ret))
	if false then
		local path = HeResPathUtils:getUserDataPath()..'/autopopout.test'
		local file = io.open(path,"w")
	    if file then 
	        file:write(table.serialize(ret))
	        file:close()
	    end
	end

	local target = self:get()
	table.compare(ret, target)

	-- self.finished_cb(true, "")
end
