
LevelAreaLocalLogic = class()

function LevelAreaLocalLogic:unlcokLevelAreaByStar()
	local user = UserService:getInstance().user
	local minLevelId = user:getTopLevelId() + 1
	local levelArea = MetaManager:getInstance():getLevelAreaRefByLevelId(minLevelId)
	if type(levelArea) == "table" then
		if user:getStar() + user:getHideStar() >= levelArea.star then
			user:setTopLevelId(minLevelId)
		end
	end
end

function LevelAreaLocalLogic:unlcokLevelAreaByGold()
	-- not implemented
end

function LevelAreaLocalLogic:unlcokLevelAreaBySendRequest(friendUids)
	-- not implemented
end

function LevelAreaLocalLogic:unlcokLevelAreaByFriendUids(friendUids)
	-- not implemented
end

function LevelAreaLocalLogic:unlcokLevelAreaByAnimals()
	-- not implemented
end

function LevelAreaLocalLogic:unlcokLevelAreaByTaskLevel()
	local user = UserService:getInstance().user
	local minLevelId = user:getTopLevelId() + 1
	local levelArea = MetaManager:getInstance():getLevelAreaRefByLevelId(minLevelId)
	if type(levelArea) == "table" then
		--if user:getStar() + user:getHideStar() >= levelArea.star then
			user:setTopLevelId(minLevelId)
		--end
	end
end
