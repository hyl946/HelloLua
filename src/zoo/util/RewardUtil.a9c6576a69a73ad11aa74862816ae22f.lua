require "zoo.common.ItemType"

local function isRewardsHasEnergyBottle(rewards)
	if _G.isLocalDevelopMode then printx(0, ">>>>>>>>>",rewards) end
	if _G.isLocalDevelopMode then printx(0, ">>>>>", table.tostring(rewards)) end
	if rewards ~= nil and #rewards > 0 then
		for i=1, #rewards do
			if _G.isLocalDevelopMode then printx(0, ">>>>>>>>>", rewards[i].itemId) end
			if ItemType:isEnergyBottle(rewards[i].itemId) then
				return true
			end
		end
	end

	return false
end

RewardUtil = {hasEnergyBottle = isRewardsHasEnergyBottle}