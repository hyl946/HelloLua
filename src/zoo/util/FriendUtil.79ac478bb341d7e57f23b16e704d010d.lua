FriendUtil = class()

--------------------------------  大地图好友精简 ----------------------------------
function FriendUtil:getMaxDisplayAmountOnWorldScene()
	return 200
end

function FriendUtil:getTrimmedFriendsForWorldScene()
	local friendIds = UserManager:getInstance().friendIds

	if #friendIds <= FriendUtil:getMaxDisplayAmountOnWorldScene() then
		return friendIds
	else
		local friends = FriendManager.getInstance().friends
		local selfTopLevel = UserManager:getInstance().user.topLevelId
		local currDayCount = Localhost:time() / (24 * 3600 * 1000)	--目前自1970的时间，以天数计算
		-- printx(11, "currDayCount", currDayCount)

		local keepedIDs = {}
		local toFilterDatas = {}

		--比玩家小15级 & 30天未活跃的用户，考虑过滤
		for k,v in pairs(friendIds) do
			assert(type(v) == "string")
			if friends[v] then
				local friendTopLevel = friends[v].topLevelId
				local isInactiveUser = false
				-- printx(11, "friendID, TopLevel", friends[v].uid, friendTopLevel)

				if friendTopLevel < (selfTopLevel - 15) then
					isInactiveUser = true
					local friendLastLoginDay = friends[v].friendLastLoginDays
					-- printx(11, "friendLastLoginDay", friendLastLoginDay)
					if friendLastLoginDay and (friendLastLoginDay > 0) then
						if (currDayCount - friendLastLoginDay) < 30 then
							isInactiveUser = false
						end
					end
				end

				if isInactiveUser then
					table.insert(toFilterDatas, friends[v])
				else
					table.insert(keepedIDs, friends[v].uid)
				end
			end
		end

		-- printx(11, "keepedIDs", table.tostring(keepedIDs))
		-- local tmpForPrint = {}
		-- for _, v in ipairs(toFilterDatas) do
		-- 	table.insert(tmpForPrint, v.uid)
		-- end
		-- printx(11, "toFilterDatas", table.tostring(tmpForPrint))

		local trimmedFriendIDs = keepedIDs
		if (#keepedIDs < FriendUtil:getMaxDisplayAmountOnWorldScene()) and (#toFilterDatas > 0) then
			local toKeepAmount = #toFilterDatas
			local toCutAmount = #trimmedFriendIDs + toKeepAmount - FriendUtil:getMaxDisplayAmountOnWorldScene()
			if toCutAmount > 0 then
				--对可被删除的对象们进行优先级排序
				toKeepAmount = toKeepAmount - toCutAmount
				table.sort(toFilterDatas, FriendUtil.sortFriendDataByTopLevelInDescendingOrder)

				-- printx(11, "toFilterDatas after sorting")
				-- tmpForPrint = {}
				-- for _, v in ipairs(toFilterDatas) do
				-- 	table.insert(tmpForPrint, v.uid)
				-- end
				-- printx(11, table.tostring(tmpForPrint))
			end

			for i = 1, toKeepAmount do
				-- printx(11, "insert to keep ones: ", toFilterDatas[i].uid)
				table.insert(trimmedFriendIDs, toFilterDatas[i].uid) 
			end
		end

		-- printx(11, "trimmedFriendIDs", table.tostring(trimmedFriendIDs))
		return trimmedFriendIDs
	end
end

function FriendUtil.sortFriendDataByTopLevelInDescendingOrder(friendData1, friendData2)
	local level1, level2
	if friendData1 then
		level1 = friendData1.topLevelId
	end
	if friendData2 then
		level2 = friendData2.topLevelId
	end

	if level1 and level2 then 
		return level1 > level2
	else
		return false
	end
end

-----------------------------  大地图好友精简 END ----------------------------------