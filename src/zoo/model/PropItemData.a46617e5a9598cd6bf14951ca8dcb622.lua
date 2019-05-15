local kRequireConfirmItems = {10010, 10026, 10005, 10019, 10027, 10003, 10028, 10055, 10056, 10057, 10103, 10105, 10108, 10109, 10112}

PropItemData = class()

function PropItemData:ctor(itemId)
	self.itemId = itemId
  self.isOnceUsed = false
  self.usedTimes = 0
  self.itemNum = 0
  self.timePropNum = 0
  self.fakePropList = {}
end

function PropItemData:create(itemId)
	local propItemData = PropItemData.new(itemId)

  return propItemData
end

function PropItemData:getCopy()
  local cp = {}
  for k,v in pairs(self) do
    if type(v) ~= "function" and type(v) ~= "userdata" and k ~= "class" then
      if type(v) == "table" then
        local cv = {}
        for k1,v1 in pairs(v) do
          if type(v1) ~= "function" and type(v1) ~= "userdata" and k1 ~= "class" then

            if type(v1) == "table" then
              cv[k1] = {}
              for k2,v2 in pairs(v1) do
                 if type(v2) ~= "function" and type(v2) ~= "userdata" and k2 ~= "class" then
                  cv[k1][k2] = v2
                 end
              end
            else
              cv[k1] = v1
            end
          end
        end
        cp[k] = cv
      else
        cp[k] = v
      end
    end
  end

  return cp
end

--{itemId=itemId, itemNum=itemNum, temporary=1}
function PropItemData:createWithData(data)
  	local item = self:create(data.itemId)
  	item.itemNum = data.itemNum
  	item.temporary = data.temporary

  	return item
end

function PropItemData:enableUnlimited(isUnlimited, maxUseTime)
    self.isUnlimited = isUnlimited
    if isUnlimited then
      self.maxUsetime = 4294967295
    else
      if tonumber(maxUseTime) then
        self.maxUsetime = maxUseTime
      else
        local meta = self:getPropMeta()
        self.maxUsetime = meta.maxUsetime or 0
      end
    end
end

function PropItemData:initTimeProps()
	local timeProps = PropsModel:instance():getTimePropsByItemId(self.itemId)
	self:setTimeProps(timeProps)
end


function PropItemData:sortTimePropList()
  if not self.timePropList then
    return
  end
  table.sort( self.timePropList, function( a, b )
      return a.expireTime < b.expireTime
    end )
end

function PropItemData:setTimeProps(props)
  if self:_isSpringItem() then
    return
  end

	self.timePropList = {}
	if props and #props > 0 then
		for _,v in pairs(props) do
		 	table.insert(self.timePropList, v)
		end
	end

	self:_updateTimePropNum()
end

function PropItemData:getPropMeta()
  if self:_isSpringItem() then
      return {}
  end

  return MetaManager:getInstance():getPropMeta(self.itemId)
end



function PropItemData:isFakePropExist()
   return self.fakePropList and #self.fakePropList>0
end

function PropItemData:isFakePropMode()
  if self:_isSpringItem() then
      return false
  end

  return self:isFakePropExist()
end

--[[
function PropItemData:useFakeProp()
  if self:_isSpringItem() then
    return
  end

  for i,v in ipairs(self.fakePropList) do
    if v.itemNum > 0 then 
      v.itemNum = v.itemNum - 1 
      return
    end
  end
end
]]


function PropItemData:isTemporaryExist()
   return self.temporaryItemList and #self.temporaryItemList>0
end

function PropItemData:isTemporaryMode()
  if self:_isSpringItem() then
      return false
  end

  return self.temporary == 1
end

function PropItemData:_updateTimePropNum()
  local num = 0
  if self.timePropList then
    for _,v in pairs(self.timePropList) do
      if v and v.itemNum then num = num + v.itemNum end
    end
  end
  self.timePropNum = num
end

function PropItemData:useTimeProp()
  if self:_isSpringItem() then
    return
  end

  for i,v in ipairs(self.timePropList) do
    if v.itemNum > 0 then 
      v.itemNum = v.itemNum - 1 
      self:_updateTimeProps()
      return
    end
  end
end

function PropItemData:getRecentTimePropLeftTime()
  if self.timePropList and #self.timePropList > 0 then
    local data = self:getFirstTimeProp()
    if data and data.expireTime and math.floor( data.expireTime / 1000 ) - Localhost:timeInSec() > 0 then
      return math.floor( data.expireTime / 1000 ) - Localhost:timeInSec()
    end
  end
  return 0
end

function PropItemData:getFirstTimeProp()
  if #self.timePropList > 0 then
    for i=1, #self.timePropList do
      local data = self.timePropList[i]
      if data and data.itemNum > 0 then
        return data
      end
    end
  end

  return nil
end

function PropItemData:_updateTimeProps()
  self:sortTimePropList()
  if self.timePropList then
    local newList = {}
    for i,v in ipairs(self.timePropList) do
      if v.itemNum > 0 then
        table.insert(newList, v)
      end
    end
    self.timePropList = newList
  end 
  self:_updateTimePropNum()
end

function PropItemData:getTimePropNum()
  if self:_isSpringItem() then
      return 0
  end

  return self.timePropNum
end

function PropItemData:isAddMoveProp(levelId)
  if self.itemId == 10004 then 
      return true 
  elseif self.itemId == 10057 and RecallManager.getInstance():getRecallLevelState(levelId) then--推送召回功能 三免费道具打关卡需求 10057 临时魔力扫把
      if self.isOnceUsed then 
        return true
      end
  end
  return false
end

function PropItemData:getDisplayItemNumber()
  if self:_isSpringItem() then
    return 0
  end

  local fakeNum = 0
  local fakePropList = self.fakePropList
  if fakePropList and #fakePropList > 0 then
    for i,v in ipairs(fakePropList) do
      local number = v.itemNum or 0
      fakeNum = fakeNum + number
    end
  end


  local tempNum = 0
  local temporaryItemList = self.temporaryItemList
  if temporaryItemList and #temporaryItemList > 0 then
    for i,v in ipairs(temporaryItemList) do
      local number = v.itemNum or 0
      tempNum = tempNum + number
    end
  end

  if fakeNum > 0 then
    return fakeNum
  elseif tempNum > 0 then
    return tempNum
  else
    local timePropNum = self:getTimePropNum()
    if timePropNum > 0 then
      return timePropNum
    else
      return self.itemNum
    end
  end
end

function PropItemData:getTotalItemNumber()
    if self:_isSpringItem() then
        return 0
    end

    local itemNum = self.itemNum or 0 

    local fakePropList = self.fakePropList
    if fakePropList and #fakePropList > 0 then
      for i,v in ipairs(fakePropList) do
        local number = v.itemNum or 0
        itemNum = itemNum + number
      end
    end

    local temporaryItemList = self.temporaryItemList
    if temporaryItemList and #temporaryItemList > 0 then
      for i,v in ipairs(temporaryItemList) do
        local number = v.itemNum or 0
        itemNum = itemNum + number
      end
    end

    return itemNum + self:getTimePropNum()
end

function PropItemData:isItemRequireConfirm()
  if self:_isSpringItem() then
      return false
  end

	for i,v in ipairs(kRequireConfirmItems) do
		if v == self.itemId then return true end
	end
	return false
end

function PropItemData:isFakeItem(itemId)
  if self:_isSpringItem() then
      return false
  end

  local fakePropList = self.fakePropList
  if fakePropList and #fakePropList > 0 then
    for i,v in ipairs(fakePropList) do
      if v.itemId == itemId then return true end
    end
  end
  
  return false
end


function PropItemData:isTempItem(itemId)
  if self:_isSpringItem() then
      return false
  end

  local temporaryItemList = self.temporaryItemList
  if temporaryItemList and #temporaryItemList > 0 then
    for i,v in ipairs(temporaryItemList) do
      if v.itemId == itemId then return true end
    end
  end
  
  return false
end

function PropItemData:isTimeItem( itemId )
  if self:_isSpringItem() then
      return false
  end

  if self.timePropList and #self.timePropList > 0 then
    for i,v in ipairs(self.timePropList) do
      if v.itemId == itemId then return true end
    end
  end
  return false
end

function PropItemData:verifyItemId( itemId )
  if self:_isSpringItem() then
      return false
  end

  if self:isFakeItem(itemId)
      or self:isTempItem(itemId) 
      or self:isTimeItem(itemId) 
      or itemId == self.itemId then 
    return true 
  end
  
  return false
end

function PropItemData:findItemID()
  if self:_isSpringItem() then
      return kSpringPropItemID
  end

  local fakePropList = self.fakePropList
  if fakePropList and #fakePropList > 0 then return fakePropList[1].itemId end

  local temporaryItemList = self.temporaryItemList
  if temporaryItemList and #temporaryItemList > 0 then return temporaryItemList[1].itemId end

  if self:getTimePropNum() > 0 then return self:findTimePropID() end

  return self.itemId
end

function PropItemData:findTimePropID()
  if self.timePropList then
    for i,v in ipairs(self.timePropList) do
        if v and v.itemNum > 0 then
          return v.itemId
        end
    end
  end

  return nil
end

function PropItemData:findTimePropExpireTime( ... )
  if self.timePropList then
    for i,v in ipairs(self.timePropList) do
        if v and v.itemNum > 0 then
          return v.expireTime
        end
    end
  end
  return nil
end

function PropItemData:getDefaultItemID()
  if self:_isSpringItem() then
      return kSpringPropItemID
  end

  if self.itemId then return self.itemId end
  local temporaryItemList = self.temporaryItemList
  if temporaryItemList and #temporaryItemList > 0 then return temporaryItemList[1].itemId end
  return 0
end

function PropItemData:increaseTimePropNumber(propId, itemNum, expireTime)
  if self:_isSpringItem() then
      return
  end

  if ItemType:getRealIdByTimePropId(propId) ~= self.itemId then
      return
  end

  itemNum = itemNum or 0
  self.timePropList = self.timePropList or {}
  local expireItem = PropItemData:create(propId)
  expireItem.realItemId = ItemType:getRealIdByTimePropId( propId )
  expireItem.itemNum = itemNum 
  expireItem.expireTime = expireTime
  expireItem.temporary = 0
  expireItem.isTimeProp = true

  table.insert(self.timePropList, expireItem)
  self:_updateTimeProps()
end

function PropItemData:increaseItemNumber( itemId, itemNum )
  --printx( 1 , "PropItemData:increaseItemNumber  itemId:" , itemId , " itemNum:" , itemNum  )
  itemNum = itemNum or 0
  if self.temporaryItemList then 
    self:updateTemporaryItemNumber(itemId, itemNum)
    return true
  else
    self.itemNum = self.itemNum + itemNum
    return false
  end
end

function PropItemData:updateTemporaryItemNumber( itemId, itemNum )
  --printx( 1 , "PropItemData:updateTemporaryItemNumber  itemId:" , itemId , " itemNum:" , itemNum  )
  --printx( 1, debug.traceback())
  if self:_isSpringItem() then
      return
  end

  itemNum = itemNum or 0
  self.temporaryItemList = self.temporaryItemList or {}
  self.temporary = 1

  local itemFound, oldNum = nil, 0
  for i,v in ipairs(self.temporaryItemList) do
    if v.itemId == itemId then itemFound = v end
  end
  if itemFound then 
    oldNum = itemFound.itemNum or 0 
  else 
    itemFound = {itemId = itemId}
    table.insert(self.temporaryItemList, itemFound) 
  end
  itemFound.itemNum = oldNum + itemNum
  if itemFound.itemNum <= 0 then 
    table.removeValue(self.temporaryItemList, itemFound)
  end

  if #self.temporaryItemList < 1 then 
      self:clearTemporary()
  end
end

function PropItemData:clearTemporary()
 	self.temporaryItemList = nil
  self.temporary = 0
end

function PropItemData:increaseFakeItemNumber( itemId, itemNum , usedTimesFix)
  --printx( 1 , "PropItemData:increaseFakeItemNumber  itemId:" , itemId , " itemNum:" , itemNum  )

  if not usedTimesFix then usedTimesFix = -1 end

  local itemFound, oldNum = nil, 0

  if not self.fakePropList then self.fakePropList = {} end

  local fakePropList = self.fakePropList

  if #fakePropList > 0 then
    
    for i,v in ipairs(fakePropList) do
      if v.itemId == itemId then 
        itemFound = v
        oldNum = itemFound.itemNum or 0 
        break
      end
    end
  end

  if not itemFound then
    itemFound = {itemId = itemId}
    table.insert(self.fakePropList, itemFound) 
    oldNum = itemFound.itemNum or 0 
  end

  itemFound.itemNum = oldNum + itemNum
  if itemFound.itemNum <= 0 then 
    table.removeValue(self.fakePropList, itemFound)
  end

  if itemNum > 0 and usedTimesFix and type(usedTimesFix) == "number" then
    --printx("PropItemData:increaseFakeItemNumber     usedTimesFix:" , usedTimesFix , "self.usedTimes:" , self.usedTimes , " fin = " , self.usedTimes + usedTimesFix)
    self.usedTimes = self.usedTimes + ( usedTimesFix * math.abs(itemNum) )
  end

  --printx( 1 , "PropItemData:increaseFakeItemNumber  self.usedTimes =" , self.usedTimes , " itemNum:" , itemNum  )
  if itemNum < 0 then
    self.usedTimes = self.usedTimes + math.abs(itemNum)
    --printx( 1 , "PropItemData:increaseFakeItemNumber  FINNNNNNNNNNNN  self.usedTimes =" , self.usedTimes  )
  end


end

function PropItemData:useWithType(itemId, propType)
  --printx( 1 , "PropItemData:useWithType  itemId:" , itemId , "  propType:" , propType)
  assert(type(itemId)=="number")
  assert(type(propType) == "number")

  if self:_isSpringItem() then
      return
  end

  if propType == UsePropsType.NORMAL then
    if  self.itemId == itemId then
      self.itemNum = self.itemNum - 1
    end
  elseif propType == UsePropsType.EXPIRE then
    for _,v in pairs(self.timePropList) do
      if v.itemId == itemId and v.itemNum > 0 then
        v.itemNum = v.itemNum - 1
        break
      end
    end
  elseif propType == UsePropsType.TEMP then
    local item = nil
    for _,v in pairs(self.temporaryItemList) do
      if v.itemId == itemId then 
        item = v 
        break
      end
    end
    if item then 
      self:updateTemporaryItemNumber(itemId, item.itemNum - 1)
    	return item 
    end
  elseif propType == UsePropsType.FAKE then
    local item = nil
    for _,v in pairs(self.fakePropList) do
      if v.itemId == itemId then 
        item = v 
        break
      end
    end
    if item then 
      self:increaseFakeItemNumber(itemId, -1)
      return item 
    end
  end

  return nil
end

function PropItemData:confirm(itemId, levelId)
  --printx( 1 , "PropItemData:confirm  itemId:" , itemId , "  levelId:" , levelId)
  --printx( 1 , debug.traceback() )
  local isFakeMode = self:isFakePropMode()
  local isTemporaryMode = self:isTemporaryMode()

  if isFakeMode then
    self:increaseFakeItemNumber(itemId, -1)
    return true
  elseif isTemporaryMode then
      --推送召回活动 
      if RecallManager.getInstance():getRecallLevelState(levelId) then
          -- if _G.isLocalDevelopMode then printx(0, "self.prop.itemId===================================",self.prop.itemId) end
          -- 临时魔力扫把特殊处理
          if self.itemId == 10057 then
              self.isOnceUsed = true
              DcUtil:UserTrack({category = "recall", sub_category = "use_molisaoba"})
          elseif self.itemId == 10010 then --10026
              DcUtil:UserTrack({category = "recall", sub_category = "use_xiaomuchui"}) 
          elseif self.itemId == 10005 then --10027
              DcUtil:UserTrack({category = "recall", sub_category = "use_mofabang"}) 
          end 
      end
      self:updateTemporaryItemNumber(itemId, -1)

      return true
  else
    if self:getTimePropNum() > 0 then
      self:useTimeProp()
    else
      self.itemNum = self.itemNum - 1
      if self.itemNum < 0 then self.itemNum = 0 end
    end
    self.usedTimes = self.usedTimes + 1
  end

  return false
end

function PropItemData:getPropType()
  local usePropType = nil
  if self:isFakePropMode() then 
    usePropType = UsePropsType.FAKE
  elseif self:isTemporaryMode() then 
    usePropType = UsePropsType.TEMP
  elseif self:getTimePropNum() > 0 then
    usePropType = UsePropsType.EXPIRE
  else
    usePropType = UsePropsType.NORMAL
  end

  return usePropType
end


function PropItemData:isMaxUsed()
  --printx( 1 , "PropItemData:isMaxUsed   self.maxUsetime=" , self.maxUsetime , self.usedTimes )
  if (GamePlaySceneSkinManager:getCurrLevelType() == GameLevelType.kFourYears
        or GamePlaySceneSkinManager:getCurrLevelType() == GameLevelType.kSummerFish ) and 
      (  self.itemId == GamePropsType.kLineBrush 
      or self.itemId == GamePropsType.kLineBrush_l 
      or self.itemId == GamePropsType.kLineBrush_b) then
      return false  
  end

  local isTempProperty  = self:isTemporaryMode()
  local maxUsetime = self.maxUsetime or 0
  
  return maxUsetime > 0 and self.usedTimes >= maxUsetime and not isTempProperty
end

-- since 1.40
function PropItemData:isMaxUseUnlimited()
  if self:isTemporaryMode() then return true end

  if self.isUnlimited or not self.maxUsetime or self.maxUsetime <= 0 then
    return true
  end
  return false
end

function PropItemData:setNumber(itemNum)
    self.itemNum = itemNum or 0
end

function PropItemData:addNumber(itemNum)
    self.itemNum = self.itemNum + (itemNum or 0)
end

function PropItemData:_isSpringItem()
    return self.itemId == kSpringPropItemID
end


function PropItemData:revertUsedTimes( ... )
    if self.usedTimes > 0 then
      self.usedTimes = self.usedTimes - 1
    end
end