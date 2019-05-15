local LadybugHttp = {}

function LadybugHttp:trigger( onSuccess, onFail, onCancel)
	local http = StartNewLadyBugTaskHttp.new(false)
	http:addEventListener(Events.kComplete, function ( ... )
		if onSuccess then onSuccess(...) end
	end)
	http:addEventListener(Events.kError, function ( ... )
		if onFail then onFail(...) end
	end)
	http:addEventListener(Events.kCancel, function ( ... )
		if onCancel then onCancel(...) end
	end)
	http:load()
end

function LadybugHttp:getReward(taskId, onSuccess, onFail, onCancel)
	local http = NewGetLadyBugRewards.new(true)
	http:addEventListener(Events.kComplete, function ( evt )
		if onSuccess then onSuccess(evt) end
	end)
	http:addEventListener(Events.kError, function ( evt )
		if onFail then onFail(evt) end
		CommonTip:showTip(Localization:getInstance():getText("error.tip."..tostring(evt.data)), "negative")
	end)
	http:addEventListener(Events.kCancel, function ( ... )
		if onCancel then onCancel(...) end
	end)

	--server index from 0
	http:syncLoad(taskId - 1, 1)
end

function LadybugHttp:getAllOldReward( onSuccess, onFail, onCancel )
	local http = NewGetLadyBugRewards.new(false)

	http:addEventListener(Events.kComplete, function ( ... )
		if onSuccess then 
			-- onSuccess({
			-- 	data = {rewardItems = {{itemId=14, num=1}}}
			-- }) 
			onSuccess(...)
		end
	end)
	http:addEventListener(Events.kError, function ( ... )
		if onFail then onFail(...) end
	end)
	http:addEventListener(Events.kCancel, function ( ... )
		if onCancel then onCancel(...) end
	end)
	http:syncLoad(-1, 0)
end

return LadybugHttp