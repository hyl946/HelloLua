


-- Copyright C2009-2013 www.happyelements.com, all rights reserved.
-- Create Date:	2013年09月26日 13:22:57
-- Author:	ZhangWan(diff)
-- Email:	wanwan.zhang@happyelements.com

---------------------------------------------------
-------------- ExploreCloud
---------------------------------------------------

assert(not ExploreCloud)
assert(BaseUI)
ExploreCloud = class(BaseUI)

function ExploreCloud:ctor()
end

function ExploreCloud:init(branchId, ...)
	assert(branchId)
	assert(#{...} == 0)

	-- ---------------
	-- Get UI Resource
	self.ui = ResourceManager:sharedInstance():buildGroup("hiddenBranch/exploreCloud")
	
	-- ---------
	-- Init Base
	-- ----------
	BaseUI.init(self, self.ui)

	-- ---------------
	-- Get UI Resource
	-- ----------------
	self.label = self.ui:getChildByName("label")
	assert(self.label)

	-- -------
	-- Get Data
	-- ----------
	self.metaModel		= MetaModel:sharedInstance()
	self.branchDataList	= self.metaModel:getHiddenBranchDataList()
	self.branchId		= branchId

	-- Set Position Y
	local curBranchData = self.branchDataList[self.branchId]
	assert(curBranchData)
	local posY = curBranchData.y
	self:setPositionY(posY)

	-- Update View
	self.label:setString("探索")
end

function ExploreCloud:alignToSideBasedOnDirection(...)
	assert(#{...} == 0)

	local curBranchData = self.branchDataList[self.branchId]
	assert(curBranchData)

	-- Set Position X
	if tonumber(curBranchData.type) == 1 then
		-- Right
		-- Align TO Screen Right
		self:setAlignToScreenRight()

	elseif tonumber(curBranchData.type) == 2 then
		-- Left
		-- Align TO Screen Left
		self:setAlignToScreenLeft()
	else
		assert(false)
	end
end

function ExploreCloud:create(branchId, ...)
	assert(branchId)
	assert(#{...} == 0)

	local newExploreCloud = ExploreCloud.new()
	newExploreCloud:init(branchId)
	return newExploreCloud
end
