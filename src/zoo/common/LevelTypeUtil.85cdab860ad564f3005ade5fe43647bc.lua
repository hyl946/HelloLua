
-- Copyright C2009-2013 www.happyelements.com, all rights reserved.
-- Create Date:	2013年08月22日 15:19:11
-- Author:	ZhangWan(diff)
-- Email:	wanwan.zhang@happyelements.com

require "hecore.class"


he_log_warning("should implemented in UserManager Or LevelManager Or Other Like ...")

---------------------------------------------------
--
--
--	Note: This Function Is Copy From Flash.
--	This Should Implemented In Data Model, Not There
--
--
----------------------------------------------------

---------------------------------------------------
-------------- LevelTypeUtil
---------------------------------------------------

LevelTypeUtil = class()

LevelTypeUtil.NORMAL_NODE_TYPE	= 1
LevelTypeUtil.HIDDEN_NODE_TYPE	= 2
LevelTypeUtil.HIDDEN_NODE_RANGE	= 10000

function LevelTypeUtil:ctor()
end

function LevelTypeUtil:getHiddenNodeLevelById(id, ...)
	assert(id)
	assert(#{...} == 0)

	return id % self.HIDDEN_NODE_RANGE
end


function LevelTypeUtil:getNodeIDByLevelAndType(level, levelType, ...)
	assert(level)
	assert(levelType)
	assert(#{...} == 0)

	if levelType == self.NORMAL_NODE_TYPE then
		return level
	elseif levelType == self.HIDDEN_NODE_TYPE then
		return self:getHiddenNodeIdByLevel(level)
	else
		assert(false)
	end

	assert(false)
end

function LevelTypeUtil:getHiddenNodeIdByLevel(level, ...)
	assert(level)
	assert(#{...} == 0)

	return self.HIDDEN_NODE_RANGE + level
end

function LevelTypeUtil:isNodeNormal(nodeId, ...)
	assert(nodeId)
	assert(type(nodeId) == "number")
	assert(#{...} == 0)

	return tonumber(nodeId) < self.HIDDEN_NODE_RANGE
end

function LevelTypeUtil:getNodeDisplayName(nodeId, ...)
	assert(nodeid)
	assert(#{...} == 0)

	if self:isNodeNormal(nodeId) then
		return nodeId
	else
		return " + " .. self:getHiddenNodeLevelById(nodeId)
	end

	assert(false)
end


