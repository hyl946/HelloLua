kGamePlayEvents = table.const {
	kPassLevel	= "gameplay.events.passlevel",
	kFailLevel  = "gameplay.events.faillevel", 
	kAreaOpenIdChange	= "gameplay.events.areaopenidchange",
	kTopLevelChange		= "gameplay.events.toplevelchange",
}

GamePlayEvents = {}

local CATEGORY = 'GamePlayEvents'

local DEFERRAL = false
GamePlayEvents.setPause = function(pause)
	DEFERRAL = pause
	if(not pause) then
		GlobalEventDispatcher:getInstance():flush(CATEGORY)
	end
end


GamePlayEvents.removePassLevelEvent = function(func)
	GlobalEventDispatcher:getInstance():removeEventListener(kGamePlayEvents.kPassLevel, func)
end

GamePlayEvents.addPassLevelEvent = function(func, context) 
	-- if _G.isLocalDevelopMode then printx(0, ">>>>>>>>>>>>> GamePlayEvents.addPassLevelEvent") end
	GlobalEventDispatcher:getInstance():addEventListener(kGamePlayEvents.kPassLevel, func, context)
end

GamePlayEvents.dispatchPassLevelEvent = function(levelResult)
	-- if _G.isLocalDevelopMode then printx(0, ">>>>>>>>>>>>> GamePlayEvents.dispatchPassLevelEvent:", table.tostring(levelResult)) end
	local e = Event.new(kGamePlayEvents.kPassLevel, levelResult)
	if(DEFERRAL) then
		GlobalEventDispatcher:getInstance():dispatchEventDeferral(e, CATEGORY)
	else
		GlobalEventDispatcher:getInstance():dispatchEvent(e)
	end	
end

GamePlayEvents.removeFailLevelEvent = function(func)
	GlobalEventDispatcher:getInstance():removeEventListener(kGamePlayEvents.kFailLevel, func)
end
GamePlayEvents.addFailLevelEvent = function(func, context) 
	GlobalEventDispatcher:getInstance():addEventListener(kGamePlayEvents.kFailLevel, func, context)
end
GamePlayEvents.dispatchFailLevelEvent = function(levelResult)
	local e = Event.new(kGamePlayEvents.kFailLevel, levelResult)
	if(DEFERRAL) then
		GlobalEventDispatcher:getInstance():dispatchEventDeferral(e, CATEGORY)
	else
		GlobalEventDispatcher:getInstance():dispatchEvent(e)
	end	
end

GamePlayEvents.addTopLevelChangeEvent = function(func) 
	-- if _G.isLocalDevelopMode then printx(0, ">>>>>>>>>>>>> GamePlayEvents.addTopLevelChangeEvent") end
	GlobalEventDispatcher:getInstance():addEventListener(kGamePlayEvents.kTopLevelChange, func)
end

GamePlayEvents.dispatchTopLevelChangeEvent = function(topLevelId)
	-- if _G.isLocalDevelopMode then printx(0, ">>>>>>>>>>>>> GamePlayEvents.dispatchTopLevelChangeEvent:", topLevelId) end
	local e = Event.new(kGamePlayEvents.kTopLevelChange, topLevelId)
	if(DEFERRAL) then
		GlobalEventDispatcher:getInstance():dispatchEventDeferral(e, CATEGORY)
	else
		GlobalEventDispatcher:getInstance():dispatchEvent(e)
	end	
end

GamePlayEvents.addAreaOpenIdChangeEvent = function(func) 
	-- if _G.isLocalDevelopMode then printx(0, ">>>>>>>>>>>>> GamePlayEvents.addAreaOpenIdChangeEvent") end
	GlobalEventDispatcher:getInstance():addEventListener(kGamePlayEvents.kAreaOpenIdChange, func)
end

GamePlayEvents.dispatchAreaOpenIdChangeEvent = function(areaId) 
	-- if _G.isLocalDevelopMode then printx(0, ">>>>>>>>>>>>> GamePlayEvents.dispatchAreaOpenIdChangeEvent") end
	local e = Event.new(kGamePlayEvents.kAreaOpenIdChange, areaId)
	if(DEFERRAL) then
		GlobalEventDispatcher:getInstance():dispatchEventDeferral(e, CATEGORY)
	else
		GlobalEventDispatcher:getInstance():dispatchEvent(e)
	end	
end
