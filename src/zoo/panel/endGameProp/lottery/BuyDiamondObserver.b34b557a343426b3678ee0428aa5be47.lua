local BuyDiamondObserver = {}

local observers = {}

function BuyDiamondObserver:addObserver( obs )
	table.insertIfNotExist(observers, obs)
end

function BuyDiamondObserver:removeObserver( obs )
	table.removeValue(observers, obs)
end

function BuyDiamondObserver:update( ... )
	-- body
	for _, obs in ipairs(observers) do
		if obs and obs.onDiamondChanged then
			obs:onDiamondChanged()
		end
	end
end

return BuyDiamondObserver