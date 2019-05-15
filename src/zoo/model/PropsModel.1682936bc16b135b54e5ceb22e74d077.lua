require "zoo.model.PropItemData"

PropsModel = class(EventDispatcher)

function PropsModel:ctor()
end

local __instance = nil

function PropsModel:instance()
	if not __instance then
		__instance = PropsModel.new()
	end

	return __instance
end

kSpringPropItemID = 9999

local kAddStepItems = {10004}
local kMaxItemIdAvailable = 10064
local kPreUsedPropItems = {10018, 10015, 10019}
-- local kCanNotBuyPropItems = {10086}

local kTempPropMapping = {}
kTempPropMapping["10025"] = 10001
kTempPropMapping["10015"] = 10001
kTempPropMapping["10016"] = 10002
kTempPropMapping["10028"] = 10003
kTempPropMapping["10017"] = 10003
kTempPropMapping["10027"] = 10005
kTempPropMapping["10019"] = 10005
kTempPropMapping["10026"] = 10010
kTempPropMapping["10024"] = 10010
kTempPropMapping["10018"] = 10004
kTempPropMapping["10053"] = 10052
kTempPropMapping["10057"] = 10056
kTempPropMapping["10065"] = 10002
kTempPropMapping["10069"] = 10007
kTempPropMapping["10070"] = 10015
kTempPropMapping["10071"] = 10018
kTempPropMapping["10108"] = 10105
kTempPropMapping["10112"] = 10109

PropsModel.kTempPropMapping = kTempPropMapping

local function isAddStepItem( item )
	local itemId = item.itemId
	for j, k in ipairs(kAddStepItems) do
		if k == itemId then return true end
	end


	return false
end

local function isValidItem( item )
	local itemID = item.itemId

	-- 因为不敢随便改kMaxItemIdAvailable，所以比这个值大的就单列吧
	local function isValidItemAboveMaxItemID(itemID)
		local targetItemID = tonumber(itemID)
		if targetItemID == ItemType.ADD_15_STEP 
			or targetItemID == ItemType.JAMSPEARD_HUMMER
			or targetItemID == kSpringPropItemID
			or targetItemID == ItemType.INGAME_ROW_EFFECT
			or targetItemID == ItemType.INGAME_COLUMN_EFFECT
			then
			return true
		end
		return false
	end

	if isValidItemAboveMaxItemID(itemID) then
		return true
	end

	if itemID > kMaxItemIdAvailable then return false end

	for i,v in ipairs(kPreUsedPropItems) do
		if v == itemID then return false end
	end
	return true
end

function PropsModel:init(levelId, levelType, selectedItemsData, hasOctopus, sectionData)
	self:_createPropsInGame(levelId, levelType, selectedItemsData, hasOctopus, sectionData)
	self:_separateProps()
end

function PropsModel:_createPropsInGame(levelId, levelType, selectedItemsData, hasOctopus, sectionData)
	-- printx(11, "=== PropsModel:_createPropsInGame", debug.traceback())
	local addToBarProps		= {}
	local notAddToBarPros		= {}
	self.addToBarProps 	= addToBarProps
	self.notAddToBarPros	= notAddToBarPros
	self.levelType = levelType

	for k,v in ipairs(selectedItemsData) do
		local tmpItem = PropItemData:create(tonumber(v.id))

		if PublishActUtil:isGroundPublish() then 
			if v.id==10007 then
				tmpItem.itemNum	= 1 
			else
				tmpItem.itemNum	= PublishActUtil:getTempPropNum()
			end
		else
			tmpItem.itemNum		= 1
		end
		if v.isPrivilegeFree then 
			tmpItem.isPrivilegeFree = v.isPrivilegeFree
		else
			tmpItem.temporary	= 1
		end
		
		local preGamePropType = ItemType:getPrePropType(tonumber(v.id))

		if PrePropType.ADD_TO_BAR == preGamePropType then
			table.insert(addToBarProps, tmpItem)
		elseif PrePropType.ADD_STEP == preGamePropType or
			PrePropType.REDUCE_TARGET == preGamePropType or
			PrePropType.TAKE_EFFECT_IN_BOARD == preGamePropType then

			table.insert(notAddToBarPros, tmpItem)
		end
	end
	-- ---------------
	-- In Game Props
	-- ---------------
	local levelModeTypeId 	= MetaModel:sharedInstance():getLevelModeTypeId(levelId)
	if LevelType:isSummerMatchLevel( levelId ) then
		levelModeTypeId = GameModeTypeId.SUMMER_WEEKLY_ID
	end
	
	local inGameProp = {}
	
	------------------ 做一份拷贝 --------------

	-- 如果从闪退恢复，需要依闪退时的道具配置为准，
	-- 否则在之后LeftPropList:revertBySectionData时，会因为道具列表长度不一致而赋错值，造成显示和数据的错位
	local sectionHasRowProp, sectionHasColumnProp = self:_checkSectionPropListHasLineEffectProps(sectionData)
	local newIndex = 1	--因为增加了是否插入的判断，可能会形成索引空格，继而影响后续table.exist,ipairs方法，故生成新的连续索引

	for k, v in pairs(MetaManager.getInstance().gamemode_prop[levelModeTypeId].ingameProps) do
		-- printx(11, "k, v", k, v)
		local addToList = true
		if v == ItemType.INGAME_ROW_EFFECT 
			or v == ItemType.TIMELIMIT_INGAME_ROW_EFFECT 
			or v == ItemType.TIMELIMIT_48_INGAME_ROW_EFFECT 
			or v == ItemType.INGAME_COLUMN_EFFECT 
			or v == ItemType.TIMELIMIT_INGAME_COLUMN_EFFECT 
			or v == ItemType.TIMELIMIT_48_INGAME_COLUMN_EFFECT 
			then
			if sectionData and sectionData.propListData then
				addToList = self:_checkLineEffectPropsAddToBarBySectionData(v, sectionHasRowProp, sectionHasColumnProp)
			else
				-- 开关关闭，不持有道具的话就不显示
				if not MaintenanceManager:getInstance():isEnabled("PropRocketsAvailable") then
					addToList = self:_checkLineEffectPropsAddToBar(v)
				end
			end
		end
		-- printx(11, "addToList:", addToList)

		if addToList then
			inGameProp[newIndex] = v
			newIndex = newIndex + 1
		end
	end
	-- printx(11, "inGameProp", table.tostring(inGameProp))

	-- 如果有章鱼就加入章鱼冰道具
	if hasOctopus then
		table.insert(inGameProp, ItemType.OCTOPUS_FORBID)
		table.insert(inGameProp,ItemType.TIMELIMIT_OCTOPUS_FORBID)
	end

	--把加15步加到最后
	if table.exist(inGameProp, ItemType.ADD_15_STEP) then
		table.removeValue(inGameProp, ItemType.ADD_15_STEP)
		table.insert(inGameProp, ItemType.ADD_15_STEP)
	end

	for k,v in ipairs(inGameProp) do
		local itemId = tonumber(v)
		if not ItemType:isTimeProp(itemId) then
			local inGameItem = PropItemData:create(itemId)
			inGameItem.itemNum	= UserManager.getInstance():getUserPropNumber(itemId)
			inGameItem.temporary	= 0
			table.insert(addToBarProps, inGameItem)
		end
	end

	-- timeProps
	local timeProps = UserManager:getInstance():getAndUpdateTimeProps()
	if #timeProps > 0 then
		for _,v in pairs(timeProps) do
			if table.exist(inGameProp, v.itemId) then
				local expireItem = PropItemData:create(v.itemId)
				expireItem.realItemId = ItemType:getRealIdByTimePropId( v.itemId )
				expireItem.itemNum = v.num 
				expireItem.expireTime = v.expireTime
				expireItem.temporary = 0
				expireItem.isTimeProp = true
				table.insert(addToBarProps, expireItem)
			end
		end
	end
	local levelMeta = LevelMapManager.getInstance():getMeta(levelId)
	self.levelModeType = levelMeta.gameData.gameModeName

	-- 春节爆竹必须要在第三个
	if self.levelModeType == GameModeType.MAYDAY_ENDLESS and self.levelType ~= GameLevelType.kSummerWeekly then
		local springItem = PropItemData:create(kSpringPropItemID)
		springItem.itemNum = 0
		springItem.temporary = 0
		table.insert(addToBarProps, 3, springItem)
	end
end

function PropsModel:_checkLineEffectPropsAddToBar(itemID)
	-- printx(11, "_checkLineEffectPropsAddToBar:", itemID)
	local rowGroup = {ItemType.INGAME_ROW_EFFECT, ItemType.TIMELIMIT_INGAME_ROW_EFFECT, ItemType.TIMELIMIT_48_INGAME_ROW_EFFECT}
	local colGroup = {ItemType.INGAME_COLUMN_EFFECT, ItemType.TIMELIMIT_INGAME_COLUMN_EFFECT, ItemType.TIMELIMIT_48_INGAME_COLUMN_EFFECT}
	local currGroup
	if table.exist(rowGroup, itemID) then
		currGroup = rowGroup
	elseif table.exist(colGroup, itemID) then
		currGroup = colGroup
	end
	-- printx(11, "currGroup:", table.tostring(currGroup))

	local needAddToBar = false
	if currGroup then
		for _, propID in pairs(currGroup) do
			local propNum = UserManager.getInstance():getUserPropNumber(propID)
			-- printx(11, "propID, propNum", propID, propNum)
			if propNum >= 1 then
				needAddToBar = true
				break
			end
		end
	end

	-- printx(11, "needAddToBar:", needAddToBar)
	return needAddToBar
end

function PropsModel:_checkSectionPropListHasLineEffectProps(sectionData)
	-- printx(11, "+ + + _checkSectionPropListHasLineEffectProps:")
	local hasRowLineEffect = false
	local hasColumnLineEffect = false

	if sectionData and sectionData.propListData then
		for _, v in pairs(sectionData.propListData) do
			local propData = v["prop"]
			-- printx(11, "propData", propData, propData["itemId"])
			if propData and propData["itemId"] then
				local propID = tonumber(propData["itemId"])
				if propID > 0 then
					if propID == ItemType.INGAME_ROW_EFFECT 
						or propID == ItemType.TIMELIMIT_INGAME_ROW_EFFECT 
						or propID == ItemType.TIMELIMIT_48_INGAME_ROW_EFFECT 
						then
						hasRowLineEffect = true
					else
						if propID == ItemType.INGAME_COLUMN_EFFECT 
							or propID == ItemType.TIMELIMIT_INGAME_COLUMN_EFFECT 
							or propID == ItemType.TIMELIMIT_48_INGAME_COLUMN_EFFECT 
							then
							hasColumnLineEffect = true
						end
					end
				end
			end
		end
	end

	return hasRowLineEffect, hasColumnLineEffect
end

function PropsModel:_checkLineEffectPropsAddToBarBySectionData(itemID, sectionHasRowProp, sectionHasColumnProp)
	-- printx(11, "_checkLineEffectPropsAddToBar BySectionData:", itemID, sectionHasRowProp, sectionHasColumnProp)
	local rowGroup = {ItemType.INGAME_ROW_EFFECT, ItemType.TIMELIMIT_INGAME_ROW_EFFECT, ItemType.TIMELIMIT_48_INGAME_ROW_EFFECT}
	local colGroup = {ItemType.INGAME_COLUMN_EFFECT, ItemType.TIMELIMIT_INGAME_COLUMN_EFFECT, ItemType.TIMELIMIT_48_INGAME_COLUMN_EFFECT}
	
	local needAddToBar = false
	if table.exist(rowGroup, itemID) then
		needAddToBar = sectionHasRowProp
	elseif table.exist(colGroup, itemID) then
		needAddToBar = sectionHasColumnProp
	end

	-- printx(11, "needAddToBar:", needAddToBar)
	return needAddToBar
end

---------------------------------------------------------------------------------------------------
function PropsModel:_separateProps()
	self.propItems = {}
	self.addStepItems = {}
	self.temporaryPops = {}
	self.fakeProps = {}
	self.timeProps = {}

	  --there is no temporary prop at the beginning of a round
	if self.addToBarProps and #self.addToBarProps > 0 then
	    for i, v in ipairs(self.addToBarProps) do
	    	if v.temporary == 1 then
	        	table.insert(self.temporaryPops, v)
	        elseif v.isPrivilegeFree then 
	        	table.insert(self.fakeProps, v)
	      	elseif v.isTimeProp then
	        	table.insert(self.timeProps, v)
	      	else 
	        	if isValidItem(v) then
	          		if isAddStepItem(v) then
	          			table.insert(self.addStepItems, v)
	          		else 
	          			table.insert(self.propItems, v) 
	          		end
	        	else 
	        		if _G.isLocalDevelopMode then printx(0, "item not supported or already uses as pre-prop, id:"..v.itemId) end 
	        	end
	      	end
	    end
	end
end

function PropsModel:getTimePropsByItemId(itemId)
	local ret = {}
	if self.timeProps and #self.timeProps > 0 then
		for _,v in pairs(self.timeProps) do
		  	if v.realItemId == itemId then
		  		table.insert(ret, v)
			end
		end
	end

	return ret
end

function PropsModel:findItemIndex( item )
	for i,v in ipairs(self.propItems) do
		if v == item then return i end
	end

	return -1
end

function PropsModel:removeItem( removedItem )
	local removedIndex = self:findItemIndex(removedItem.prop)
	if removedIndex > 0 then 
		table.remove(self.propItems, removedIndex) 
	end
end

function PropsModel:addItem(item)
	table.insert(self.propItems, item)
end

function PropsModel:addTimeProp(propId, num, expireTime)
	local expireItem = PropItemData:create(propId)
	expireItem.realItemId = ItemType:getRealIdByTimePropId( propId )
	expireItem.itemNum = num 
	expireItem.expireTime = expireTime
	expireItem.temporary = 0
	expireItem.isTimeProp = true
	
	table.insert(self.timeProps, expireItem)
end

function PropsModel:addStepItemExist()
	return	self.addStepItems and #self.addStepItems > 0
end

function PropsModel:addTemporary( item  )
	if not self.temporaryPops then
		self.temporaryPops = {}
	end
	table.insert(self.temporaryPops,item)
end
function PropsModel:temporaryPopsExist()
	return self.temporaryPops and #self.temporaryPops > 0 
end

function PropsModel:clearTemporaryPops()
	self.temporaryPops = nil
end

function PropsModel:fakePropsExist()
	return self.fakeProps and #self.fakeProps > 0 
end

function PropsModel:clearFakeProps()
	self.fakeProps = nil
end

function PropsModel:getAddStepItemData()
	return self.addStepItems and self.addStepItems[1] or nil
end

function PropsModel:isAddStepItemMaxUsed()
	local addStepItem = self:getAddStepItemData()
	if addStepItem then
		return addStepItem:isMaxUsed()
	end
	return false
end

function PropsModel:addAddStepItemUsedTime()
	local addStepItem = self:getAddStepItemData()
	if addStepItem then
		addStepItem.usedTimes = addStepItem.usedTimes + 1
	end
end
