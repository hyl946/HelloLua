
-- Copyright C2009-2013 www.happyelements.com, all rights reserved.
-- Create Date:	2013年11月13日 13:12:50
-- Author:	ZhangWan(diff)
-- Email:	wanwan.zhang@happyelements.com

---------------------------------------------------
-------------- AdvanceTopLevelLogic
---------------------------------------------------

assert(not AdvanceTopLevelLogic)
AdvanceTopLevelLogic = class()

function AdvanceTopLevelLogic:ctor()
end

function AdvanceTopLevelLogic:init(levelPassedId, ...)
	assert(type(levelPassedId) == "number")
	assert(#{...} == 0)

	self.levelPassedId = levelPassedId
end

function AdvanceTopLevelLogic:start(...)
	assert(#{...} == 0)
	local levelMapManager = LevelMapManager:getInstance()

	-- if is hidden level return
	--if not LevelTypeUtil:isNodeNormal(self.levelPassedId) then
	if not levelMapManager:isNormalNode(self.levelPassedId) then
		return
	end

	-- Check if really passed the level
	local score = UserManager:getInstance():getUserScore(self.levelPassedId)
	if UserManager.getInstance():hasPassedByTrick(self.levelPassedId) then   --跳关
	else
		if not score or not score.star or score.star < 1 then return end
	end

	-- -- Check if it's the top level
	local topLevel = UserManager:getInstance().user:getTopLevelId()
	if topLevel ~= self.levelPassedId then return end

	-- Check If Already Reached The Toppest
	local maxTopLevel = MetaManager.getInstance():getMaxNormalLevelByLevelArea()
	if self.levelPassedId == maxTopLevel then
		return
	end

	-- Check If There Is An Locked Cloud
	local nextLevelAreaRef = MetaManager.getInstance():getNextLevelAreaRefByLevelId(self.levelPassedId)

	if nextLevelAreaRef then
		if self.levelPassedId == tonumber(nextLevelAreaRef.minLevel) - 1 then
			-- An Level Area Needed To Open
			assert(nextLevelAreaRef.id)
			UserManager:getInstance().levelAreaOpenedId = nextLevelAreaRef.id
			return
		end
	end

	-- else
	local newTopLevel = self.levelPassedId + 1

	-- Update New TopLevelId
	UserManager:getInstance().user:setTopLevelId(newTopLevel)
	PrepackageUtil:ChangeIsShowNetworkDialog(newTopLevel)
end

function AdvanceTopLevelLogic:startWithoutCheckLockedCloud(...)
	assert(#{...} == 0)

	local newTopLevel = self:getNextTopLevelWithoutCheckLockedCloud()
	PrepackageUtil:ChangeIsShowNetworkDialog(newTopLevel)
	UserManager:getInstance().user:setTopLevelId(newTopLevel)
end

function AdvanceTopLevelLogic:getNextTopLevelWithoutCheckLockedCloud(...)
	assert(#{...} == 0)

	local levelMapManager = LevelMapManager:getInstance()

	-- if is hidden level return
	if not levelMapManager:isNormalNode(self.levelPassedId) then
		return
	end

	-- Check If Already Reached The Toppest
	local maxTopLevel = MetaManager.getInstance():getMaxNormalLevelByLevelArea()

	if self.levelPassedId == maxTopLevel then
		return
	end

	-- else
	local newTopLevel = self.levelPassedId + 1

	return newTopLevel
end

function AdvanceTopLevelLogic:create(levelPassedId, ...)
	assert(type(levelPassedId) == "number")
	assert(#{...} == 0)

	local newAdvanceTopLevelLogic = AdvanceTopLevelLogic.new()
	newAdvanceTopLevelLogic:init(levelPassedId)
	return newAdvanceTopLevelLogic
end
