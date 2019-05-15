
-- Copyright C2009-2013 www.happyelements.com, all rights reserved.
-- Create Date:	2013年11月14日 15:14:14
-- Author:	ZhangWan(diff)
-- Email:	wanwan.zhang@happyelements.com

---------------------------------------------------
-------------- LevelTarget
---------------------------------------------------

assert(not LevelTarget)
assert(BaseUI)
LevelTarget = class(BaseUI)

function LevelTarget:init(gameModeName, orderList, ...)
	assert(type(gameModeName) == "string")
	assert(#{...} == 0)

	if gameModeName == GameModeType.ORDER then
		assert(orderList)
	end

	-------------------
	-- Get Data
	-- -----------------
	local numberOfTarget = false
	local targetResNames = {}

	if gameModeName == GameModeType.ORDER or gameModeName == GameModeType.SEA_ORDER then
		for k,v in pairs(orderList) do
			if _G.editorMode and (v.k == "6_5" or v.k == "6_6" or v.k == "6_4" or v.k == "6_7") then
				local resName = "target.order6_4"
				if not table.exist(targetResNames, resName) then
					table.insert(targetResNames, resName)
				end
			else
				local resName = "target.order" .. v.k
				table.insert(targetResNames, resName)
			end
		end
	elseif gameModeName == GameModeType.LIGHT_UP then
		table.insert(targetResNames, "target.ice")
	elseif gameModeName == GameModeType.DROP_DOWN then
		table.insert(targetResNames, "target.drop")
	elseif gameModeName == GameModeType.CLASSIC then
		table.insert(targetResNames, "target.time")
	elseif gameModeName == GameModeType.CLASSIC_MOVES or gameModeName == GameModeType.DIG_MOVE_ENDLESS 
		or gameModeName == GameModeType.OLYMPIC_HORIZONTAL_ENDLESS or  gameModeName == GameModeType.SPRING_HORIZONTAL_ENDLESS 
		then
		table.insert(targetResNames, "target.score")
	elseif gameModeName == GameModeType.DIG_MOVE then
		table.insert(targetResNames, "target.dig_move")
	elseif gameModeName == GameModeType.TASK_UNLOCK_DROP_DOWN then 
		table.insert(targetResNames, "target.key")
	elseif gameModeName == GameModeType.LOTUS then
		table.insert(targetResNames, "target.order_lotus_1")
    elseif gameModeName == GameModeType.MOLE_WEEKLY_RACE then
		table.insert(targetResNames, "target.moleweek")
    elseif gameModeName == GameModeType.JAM_SPERAD then
		table.insert(targetResNames, "target.jamsperad")
	else
		assert(false, "Unexpected gameModeName:"..tostring(gameModeName))
	end

	if _G.isLocalDevelopMode then printx(0, table.tostring(targetResNames)) end

	numberOfTarget = #targetResNames

	------------------
	-- Create UI Component
	-- -------------------
	local resName = tostring(numberOfTarget) .. "Target"
	self.ui = ResourceManager:sharedInstance():buildGroup(resName)

	-----------------
	-- Init Base Class
	-- -----------------
	BaseUI.init(self, self.ui)

	----------------
	-- Get UI
	-- ----------------
	local targetContainer	= {}
	local placeholderSizes	= {}

	for index = 1,numberOfTarget do
		local target = self.ui:getChildByName("target" .. tostring(index))
		assert(target)
		table.insert(targetContainer, target)

		local placeholder = target:getChildByName("placeholder")
		assert(placeholder)
		local placeholderSize = placeholder:getGroupBounds().size
		table.insert(placeholderSizes, placeholderSize)
		placeholder:setVisible(false)
	end

	---------------------
	-- Init UI Component
	-- ------------------
	for index = 1, #targetResNames do
		local sprite = Sprite:createWithSpriteFrameName(targetResNames[index] .." instance 10000")
		sprite:setAnchorPoint(ccp(0,1))
		targetContainer[index]:addChild(sprite)

		local deltaScale = 0.65
		sprite:setScaleX(deltaScale)
		sprite:setScaleY(deltaScale)

		local placeholderSize	= placeholderSizes[index]
		local spriteSize	= sprite:getGroupBounds().size

		local deltaWidth	= -spriteSize.width + placeholderSize.width
		local deltaHeight	= -spriteSize.height + placeholderSize.height

		local halfDeltaWidth	= deltaWidth / 2
		local halfDeltaHeight	= deltaHeight / 2

		sprite:setPosition(ccp(halfDeltaWidth, -halfDeltaHeight))
		--sprite:setAnchorPointCenterWhileStayOrigianlPosition()

	end
end

function LevelTarget:create(gameModeName, orderList, ...)
	assert(type(gameModeName) == "string")
	assert(#{...} == 0)

	local newLevelTarget = LevelTarget.new()
	newLevelTarget:init(gameModeName, orderList)
	return newLevelTarget
end
