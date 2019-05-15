require "hecore.debug.AdvancedLoggerPad"

AdvancedLogger = {}

AdvancedLogger.logCache = {}
AdvancedLogger.logId = 1
AdvancedLogger.currPad = nil


function AdvancedLogger:init()

end

function AdvancedLogger:log( ... )
	if AdvancedLogger.currPad then
		local arr = {...}
		local str = ""
		if #arr == 0 then
			return
		elseif #arr == 1 then
			str = tostring(arr[1])
		else
			for k,v in ipairs(arr) do
				str = str .. " " .. tostring(v)
			end
		end

		if str == "" then
			return
		end

		local log = { id = AdvancedLogger.logId , str = str , time = Localhost:timeInSec() }
		AdvancedLogger.logId = AdvancedLogger.logId + 1
		table.insert( AdvancedLogger.logCache , log )

		if #AdvancedLogger.logCache > 500 then
			table.remove(AdvancedLogger.logCache , 1)
		end

		local bigStr = ""
		for i = 1 , #AdvancedLogger.logCache  do
			bigStr = bigStr .. AdvancedLogger.logCache[i].str .. "\n"
		end

		AdvancedLogger.currPad:updateText( bigStr )
	end
end

function AdvancedLogger:logInViewOnly( ... )

end

function AdvancedLogger:logInFiddlerOnly( ... )

end

function AdvancedLogger:logInViewAndFiddlerOnly( ... )

end

function AdvancedLogger:toggleAdvancedLoggerPad()

	local _func = function ()
		if AdvancedLogger.currPad then
			self:hideAdvancedLoggerPad()
		else
			self:showAdvancedLoggerPad()
		end
	end

	local message
    local traceback
	local success = xpcall( _func , function(err)
	    message = err
	    traceback = debug.traceback("", 2)
	    if _G.isLocalDevelopMode then printx(-99, message) end
	    if _G.isLocalDevelopMode then printx(-99, traceback) end
  	end)
end

function AdvancedLogger:showAdvancedLoggerPad()
	printx( 1 , "  AdvancedLogger:showAdvancedLoggerPad")
	if not AdvancedLogger.currPad then
		printx( 1 , "  AdvancedLogger:showAdvancedLoggerPad   create")
		AdvancedLogger.currPad = AdvancedLoggerPad:create( AdvancedLogger.logCache )
		printx( 1 , "  AdvancedLogger:showAdvancedLoggerPad   AdvancedLogger.currPad = " , AdvancedLogger.currPad)
		--AdvancedLogger.currPad:setPosition( ccp( 350 , -500 ) )

		Director:sharedDirector():getRunningScene():addChild( AdvancedLogger.currPad )
		
	end
end

function AdvancedLogger:hideAdvancedLoggerPad()
	printx( 1 , "  AdvancedLogger:hideAdvancedLoggerPad")
	if AdvancedLogger.currPad then
		AdvancedLogger.currPad:removeFromParentAndCleanup(true)
		AdvancedLogger.currPad = nil
	end
end
-----------------------------------------------
if not isLocalDevelopMode then 
	AdvancedLogger.log = function() end 
end