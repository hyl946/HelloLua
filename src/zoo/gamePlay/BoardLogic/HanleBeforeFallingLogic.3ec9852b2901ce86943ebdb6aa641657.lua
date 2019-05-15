--在棋盘刚从falling&match stable进入到falling&match时执行一帧 目前用于过滤器（鸡窝蹦鸡时）
HanleBeforeFallingLogic = {}

function HanleBeforeFallingLogic:handle(mainLogic)
	local shouldFilter = false
	if self.needHandle then 
		self.needHandle = false
		for r = 1, #mainLogic.gameItemMap do 
	        for c = 1, #mainLogic.gameItemMap[r] do
	        	local item = mainLogic.gameItemMap[r][c]
			    if (item.ItemStatus ~= GameItemStatusType.kIsMatch 	----被合成或者特效消除
				and item.ItemStatus ~= GameItemStatusType.kIsSpecialCover
				and item.ItemStatus ~= GameItemStatusType.kDestroy) then 
		       		if ColorFilterLogic:handleFilter(r, c) then 
		       			shouldFilter = true 
		       		end
		        end
	        end
	    end
	end
	return shouldFilter
end

function HanleBeforeFallingLogic:setNeedHanle(needHandle)
	self.needHandle = needHandle
end