local XFMeta = {
	
}

-- XFMeta.HonorMeta = {
-- 	{kId = 50300, kMinRank = 1, kMaxRank = 1,},
-- 	{kId = 50301, kMinRank = 1, kMaxRank = 3,},
-- 	{kId = 50302, kMinRank = 4, kMaxRank = 6,},
-- 	{kId = 50400, kMinRank = 7, kMaxRank = 200, },
-- 	{kId = 50401, kMinRank = 201, kMaxRank = 500,},
-- }

XFMeta.honorType = {
	kType1 = 1,
	kType2 = 2,
}

XFMeta.RANK_SIZE = 5000
XFMeta.RANK_SHOW_SIZE = 500

XFMeta.ActId = 1026

function XFMeta:getHonorType( honorId )
	if honorId >= 50400 then 
		return XFMeta.honorType.kType2
	else
		return XFMeta.honorType.kType1 
	end
end

function XFMeta:getHonorMeta( ... )
	if not XFMeta.HonorMeta then
		XFMeta.HonorMeta = {}
		local cfg = MetaManager:getInstance():getCommonRankRewardsByActId(XFMeta.ActId)
		for _, v in ipairs(cfg) do

			local honorItem = table.find(v.rewards or {}, function ( rewardItem )
				return ItemType:isHonor(rewardItem.itemId)
			end)


			if honorItem then

				local score = 0

				local scoreItem = table.find(v.rewards or {}, function ( rewardItem )
					return rewardItem.itemId == 50299
				end)

				if scoreItem then
					score = scoreItem.num
				end

				table.insert(XFMeta.HonorMeta, {
					kId = honorItem.itemId,
					kMinRank = v.minRange,
					kMaxRank = v.maxRange,
					kScore = score,
				})
			end
		end

	end

	return XFMeta.HonorMeta
end

function XFMeta:getScoreMeta( ... )
	if not XFMeta.ScoreMeta then
		XFMeta.ScoreMeta = {}
		local cfg = MetaManager:getInstance():getCommonRankRewardsByActId(XFMeta.ActId)
		for _, v in ipairs(cfg) do

			local score = 0

			local scoreItem = table.find(v.rewards or {}, function ( rewardItem )
				return rewardItem.itemId == 50299
			end)

			if scoreItem then
				score = scoreItem.num
			end

			table.insert(XFMeta.ScoreMeta, {
				kMinRank = v.minRange,
				kMaxRank = v.maxRange,
				kScore = score,
			})
		end
	end
	return XFMeta.ScoreMeta
end

function XFMeta:findSimilarHornorId( honorId, rank)
	if table.find(XFMeta:getHonorMeta(), function ( v )
		return v.kId == honorId
	end) then
		return honorId
	end

	local similarHonor = table.find(XFMeta:getHonorMeta(), function ( v )
		return v.kMinRank <= rank and v.kMaxRank >= rank
	end)

	if similarHonor then
		return similarHonor.kId
	end
end


return XFMeta