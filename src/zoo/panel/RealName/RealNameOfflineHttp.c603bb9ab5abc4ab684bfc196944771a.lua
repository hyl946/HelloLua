local RealNameOfflineHttp = {}

function RealNameOfflineHttp:trigger( onSuccess, onFail, onCancel )
	local now = Localhost:timeInSec()
	if onSuccess then
		onSuccess(now)
	end
end

function RealNameOfflineHttp:getReward(rewardId, onSuccess, onFail, onCancel )
	local http = GetRewardsOfflineHttp.new(true)
	http:addEventListener(Events.kComplete, onSuccess)
	http:addEventListener(Events.kError, onFail)
	http:addEventListener(Events.kCancel, onCancel)
	http:load(rewardId)
end

return RealNameOfflineHttp