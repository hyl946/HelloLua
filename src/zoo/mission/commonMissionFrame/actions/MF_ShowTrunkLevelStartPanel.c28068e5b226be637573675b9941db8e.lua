MF_ShowTrunkLevelStartPanel = class()

function MF_ShowTrunkLevelStartPanel:doAction(action , context)

	local toplv = UserManager:getInstance():getUserRef():getTopLevelId()
	local score = UserManager:getInstance():getUserScore(toplv)
	local realTopLevel = toplv
	if not score then
		score = ScoreRef.new()
	end

	if action and action:getParameters() then
		local parameters = action:getParameters()

		if parameters and parameters[1] then
			local level = tonumber(parameters[1])

			--[[
			if score.star == 0 then
				realTopLevel = toplv
			else
				realTopLevel = toplv + 1
			end
			]]

			if level <= toplv then
				HomeScene:sharedInstance().worldScene:startLevel(level)
			end
		end	
	end
end

return MF_ShowTrunkLevelStartPanel