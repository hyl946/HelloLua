local CashObserver = {}

local observers = {}

function CashObserver:addObserver( obs )
	table.insertIfNotExist(observers, obs)
end

function CashObserver:removeObserver( obs )
	table.removeValue(observers, obs)
end

function CashObserver:update( ... )
	-- body
	for _, obs in ipairs(observers) do
		if obs and obs.onCashNumChange then
			obs:onCashNumChange()
		end
	end
end

return CashObserver