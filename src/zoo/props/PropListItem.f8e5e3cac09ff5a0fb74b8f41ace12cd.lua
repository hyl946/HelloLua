require "hecore.display.Director"
require "zoo.props.PropItemAnimator"

local showLabelTime24 = 24 * 60 * 60
local showLabelTime48 = 48 * 60 * 60
PropListItem = class(EventDispatcher)

PropListItem.Events = table.const{
  kFocusChange = "focusChange",
  kUpdateView = "updateView",
}

function PropListItem:ctor()
  self.direction = 1
  self.visible = true
  self.disabled = false
  self.usedTimes = 0
  self.maxUsetime = 0
  self.onTemporaryItemUsed = nil --function
  self.isTouchEnabled = true
  self.isExplodeing = false --正在播放使用动画
  self.timePropNum = 0 -- 限时道具数量
  self.timePropList = nil
  self.canNotUseThisSkillCD = 0 --道具不可使用CD 如果在wait前设置改为2， wait后改为1 

  self.animator = PropItemAnimator:create(self)
end

function PropListItem:getSectionData()
  local cp = {}
  cp.direction = self.direction
  cp.visible = self.visible
  cp.disabled = self.disabled
  cp.usedTimes = self.usedTimes
  cp.maxUsetime = self.maxUsetime
  cp.onTemporaryItemUsed = self.onTemporaryItemUsed
  cp.isTouchEnabled = self.isTouchEnabled
  cp.isExplodeing = self.isExplodeing
  cp.timePropNum = self.timePropNum
  cp.reasonType = self.reasonType
  cp.canNotUseThisSkillCD = self.canNotUseThisSkillCD or 0
  --cp.reasonType = self.reasonType or "nil"

  --printx( 1 , "PropListItem:getSectionData   " , table.tostring(cp) )
  return cp
end

function PropListItem:revertBySectionData(datas)
  --printx( 1 , "PropListItem:revertBySectionData   " , table.tostring(datas))
  self.direction = datas.direction
  self.visible = datas.visible
  self.disabled = datas.disabled
  self.usedTimes = datas.usedTimes
  self.maxUsetime = datas.maxUsetime
  self.onTemporaryItemUsed = datas.onTemporaryItemUsed
  self.isTouchEnabled = datas.isTouchEnabled
  self.isExplodeing = datas.isExplodeing
  self.timePropNum = datas.timePropNum
  self.reasonType = datas.reasonType
  self.canNotUseThisSkillCD = datas.canNotUseThisSkillCD or 0

  if self.prop and self.prop.itemId == GamePropsType.kBack then
    self.disabled = true
    self.reasonType = 1
  end

  if self.disabled then
    self.disabled = false
    self:lock( true )
    self.isPlayShowAnimation = false
  else
    self.disabled = true
    self:lock( false )
    self.isPlayShowAnimation = false
  end

  self:updateItemNumber()

  --[[
  if datas.reasonType == "nil" then
    self:setEnable()
    --self.reasonType = nil
  else
    self.reasonType = datas.reasonType
  end
  --]]

end

function PropListItem:create(index, pedicle, item, propListAnimation)
	local ret = PropListItem.new()
  ret.propListAnimation = propListAnimation
	ret:buildUI(index, pedicle, item)
  ret.controller = propListAnimation.controller
	return ret
end

function PropListItem:setItemTouchEnabled( v )
  self.isTouchEnabled = v
end

function PropListItem:dispose()
  if self.animateID then CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.animateID) end
  self.animateID = nil
  self.propListAnimation = nil
  if self.countdownTimer then
    TimerUtil.removeAlarm(self.countdownTimer)
    self.countdownTimer = nil
  end
end

function PropListItem:buildUI(index, pedicle, item)
	self.index = index
	self.pedicle = pedicle
	self.item = item
  if self.propListAnimation and self.propListAnimation.replayMode then 
    self.replayMode = self.propListAnimation.replayMode
  else
    self.replayMode = ReplayMode.kNone
  end

  local contentSize = item:getGroupBounds().size
  item:setContentSize(CCSizeMake(contentSize.width, contentSize.height))
  
  self.beginRotation = item:getRotation()
  local itemPosition = item:getPosition()
  self.beginPosition = {x=itemPosition.x, y=itemPosition.y}

	pedicle:setVisible(false)
  item:setVisible(false)

  local bg_normal = item:getChildByName("bg_normal")
  local bg_selected = item:getChildByName("bg_selected")
  local bg_hint = item:getChildByName("bg_hint")
  local icon_add = item:getChildByName("icon_add")
  local prop_disable_icon = item:getChildByName("prop_disable_icon")
  local bg_hint2 = item:getChildByName("bg_hint2")
  bg_hint2:setVisible(false)

  local prop_disable_size = prop_disable_icon:getContentSize()
  local prop_disable_pos = prop_disable_icon:getPosition()
  prop_disable_icon:setVisible(false)
  prop_disable_icon:setCascadeOpacityEnabled(false)
  prop_disable_icon:setAnchorPoint(ccp(0.5, 0.5))
  prop_disable_icon:setPosition(ccp(prop_disable_pos.x + prop_disable_size.width/2, prop_disable_pos.y - prop_disable_size.height/2))

  item:getChildByName("name_label"):setVisible(false)
  item:getChildByName("time_limit_flag"):setVisible(false)
  item:getChildByName("free_flag"):setVisible(false)
  self.timeLimitLabelPosition = ccp(item:getChildByName("time_limit_label"):getPosition().x , item:getChildByName("time_limit_label"):getPosition().y)

  local normalSize = bg_normal:getContentSize()
  local normalPos = bg_normal:getPosition()
  bg_normal:setAnchorPoint(ccp(0.5, 0.5))
  bg_normal:setPosition(ccp(normalPos.x + normalSize.width/2, normalPos.y - normalSize.height/2))

  bg_selected:setVisible(false)
  bg_hint:setVisible(false)
  icon_add:setVisible(false)

  self:initIconSize()

  self.center = {x = self.iconSize.x + self.iconSize.width/2, y = self.iconSize.y - self.iconSize.height /2, r = normalSize.width/2}

  local sprite = CCSprite:createWithSpriteFrameName("prop_bubble10000")
  local batch = SpriteBatchNode:createWithTexture(sprite:getTexture())
  item:addChild(batch)
  self.batch = batch
end

function PropListItem:initIconSize()
  local content = self.item:getChildByName("content")
  local contentPos = content:getPosition()
  local contentSize = content:getContentSize()
  local contentScale = content:getScale()
  self.iconSize = {x = contentPos.x, y = contentPos.y, width = contentSize.width*contentScale, height = contentSize.height*contentScale}
  content:removeFromParentAndCleanup(true)
end

function PropListItem:getItemCenterPosition()
  local item = self.item
  local iconSize = self.iconSize
  local x = iconSize.x + iconSize.width/2
  local y = iconSize.y - iconSize.height/2
  local position = ccp(x, y)
  if self.isPlayShowAnimation then -- show动画时是从scale0开始的,转换后的位置不正确,直接计算
    local itemPos = item:getPosition()
    position = ccp(itemPos.x + x, itemPos.y + y)
    position = item:getParent():convertToWorldSpace(position)
  else
    position = item:convertToWorldSpace(position)
  end
  return position
  -- return item:getParent():convertToNodeSpace(position)
end

function PropListItem:hide(forbidMoveListView)
  --printx( 1 ,  "PropListItem:hide")
  self.visible = false
  
  self.pedicle:setVisible(false)

  self.item:setVisible(false)
  self.item:stopAllActions()
  self.prop = nil
  
  if self.icon then self.icon:removeFromParentAndCleanup(true) end
  self.icon = nil
  
  self.isAnimateHint = false
  self.isAnimating = false
  self.isHintMode = false
  self.isPlayShowAnimation = false
  self.darked = false
  self.focused = false
  if self.animateID then CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.animateID) end
  self.animateID = nil

  if not forbidMoveListView then
    if self.onHideCallback ~= nil then self.onHideCallback(self) end
  end
end

function PropListItem:updateItemNumber()
  ----printx( 1 , "PropListItem:updateItemNumber   111 " , self.prop.itemId)
  local prop = self.prop
  if self.item.isDisposed then
      return
  end
  local itemNum = self.prop:getTotalItemNumber()
  local displayNum = self.prop:getDisplayItemNumber()
  local item = self.item
  local icon_add = item:getChildByName("icon_add")
  local timeLimitFlag = item:getChildByName("time_limit_flag")
  

  if self.timeLimitLabel == nil then
    local timeLimitLabel = item:getChildByName("time_limit_label")
    self.timeLimitLabel = BitmapText:create('', 'fnt/white_yahei.fnt')
    self.timeLimitLabel:setAnchorPoint(ccp(0,1))
    self.timeLimitLabel:setPositionX( timeLimitLabel:getPositionX() )
    self.timeLimitLabel:setPositionY( timeLimitLabel:getPositionY() )
    item:addChildAt( self.timeLimitLabel , item:getChildIndex( timeLimitLabel ) )
    timeLimitLabel:removeFromParentAndCleanup( true )
    self.timeLimitLabel.name = "time_limit_label2"
  end

  local timeLimitLabel = self.timeLimitLabel 

  local freeFlag = item:getChildByName("free_flag")

  icon_add:setVisible(false)
  timeLimitFlag:setVisible(false)
  freeFlag:setVisible(false)
  timeLimitLabel:setText("")

  if self.countdownTimer then 
    TimerUtil.removeAlarm( self.countdownTimer )
    self.countdownTimer = nil
  end


  local function onPropTimer()

    local lefttime = self.prop:getRecentTimePropLeftTime()
    
    if lefttime <= 0 then
      timeLimitLabel:setText("仅本关")
      timeLimitLabel:setScale(1.4)
      timeLimitLabel:setPositionX( self.timeLimitLabelPosition.x + 5 )
      timeLimitLabel:setPositionY( self.timeLimitLabelPosition.y + 5 )
      if self.countdownTimer then 
        TimerUtil.removeAlarm( self.countdownTimer )
        self.countdownTimer = nil
      end
    else

      if lefttime < showLabelTime48 then
        timeLimitLabel:setScale(1)
        timeLimitLabel:setPositionX( self.timeLimitLabelPosition.x + 3 )
        timeLimitLabel:setPositionY( self.timeLimitLabelPosition.y )
        timeLimitLabel:setText( getTimeFormatString( lefttime ) )

        

        --换背景 
        local cIdx = 100
        if lefttime < showLabelTime24  then
          cIdx = 101
          timeLimitLabel:setColor(ccc3(255,255,0))
        else
          cIdx = 100
          timeLimitLabel:setColor(ccc3(255,255,255))
        end
        if timeLimitFlag then
          timeLimitFlag:adjustColor  ( _G.LvlFlagColor[cIdx][1] ,_G.LvlFlagColor[cIdx][2] ,_G.LvlFlagColor[cIdx][3] ,_G.LvlFlagColor[cIdx][4] )
          timeLimitFlag:applyAdjustColorShader()
        end
      else
        timeLimitLabel:setColor(ccc3(255,255,0))
        timeLimitLabel:setText("限时")
        timeLimitLabel:setScale(1.5)
        timeLimitLabel:setPositionX( self.timeLimitLabelPosition.x + 15 )
        timeLimitLabel:setPositionY( self.timeLimitLabelPosition.y + 5 )
      end
      -- if lefttime > 24 * 60 * 60 then
      --   timeLimitLabel:setText("限时")
      --   timeLimitLabel:setScale(1.5)
      --   timeLimitLabel:setPositionX( self.timeLimitLabelPosition.x + 15 )
      --   timeLimitLabel:setPositionY( self.timeLimitLabelPosition.y + 5 )
      -- else
      --   timeLimitLabel:setScale(1)
      --   timeLimitLabel:setPositionX( self.timeLimitLabelPosition.x + 3 )
      --   timeLimitLabel:setPositionY( self.timeLimitLabelPosition.y )
      --   timeLimitLabel:setText( getTimeFormatString( lefttime ) )
      -- end
    end

    self:dispatchEvent(Event.new(PropListItem.Events.kUpdateView))
  end
  ----printx( 1 , "PropListItem:updateItemNumber   222 ")
  if itemNum < 1 then
    ----printx( 1 , "PropListItem:updateItemNumber   333 ")
  	icon_add:setVisible(true)
    self:hideNumTip()
    timeLimitLabel:setText("")
  else
    ----printx( 1 , "PropListItem:updateItemNumber   444 ")
    if self.prop:isFakePropMode() then
      self:showNumTip(NumTipType.ORANGE, displayNum)
      freeFlag:setVisible(true)
      timeLimitFlag:setVisible(false)
      timeLimitLabel:setText("")
    elseif self.prop:isTemporaryMode() then
      self:showNumTip(NumTipType.ORANGE, displayNum)
      freeFlag:setVisible(true)
      timeLimitFlag:setVisible(false)
      timeLimitLabel:setText("")
    elseif self.prop:getTimePropNum() > 0 then
      if self.replayMode == ReplayMode.kStrategy then 
          self:hideNumTip()
      else
          self:showNumTip(NumTipType.RED, displayNum)
          
          if self.prop:getRecentTimePropLeftTime() == 0 then
            timeLimitFlag:setVisible(true)
            timeLimitLabel:setText("")
            freeFlag:setVisible(false)
            onPropTimer()
          else
            timeLimitFlag:setVisible(true)
            timeLimitLabel:setText("")
            freeFlag:setVisible(false)
            onPropTimer()

            self.countdownTimer = TimerUtil.addAlarm(onPropTimer, 1 , 0 )
          end      
      end
    else
      ----printx( 1 , "PropListItem:updateItemNumber   555 ")
      if self.replayMode == ReplayMode.kStrategy then 
          self:hideNumTip()
      else
          self:showNumTip(NumTipType.GREEN, displayNum)
      end
    end
  end
  ----printx( 1 , "PropListItem:updateItemNumber   666  self.prop:isMaxUsed() = " , self.prop:isMaxUsed())
  if self.prop:isMaxUsed() then
    ----printx( 1 , "PropListItem:updateItemNumber   777")
    if not self.disabled then 
      ----printx( 1 , "PropListItem:updateItemNumber   888")
      self:lock(true) 
    end
  end
  ----printx( 1 , "PropListItem:updateItemNumber   999")
  self:dispatchEvent(Event.new(PropListItem.Events.kUpdateView))
end

function PropListItem:showNumTip(tipType, num)
    if num == nil then num = self.prop:getDisplayItemNumber() end
    if self.numTip ~= nil and self.numTip.tipType ~= tipType and not self.numTip.isDisposed then
        self.numTip:removeFromParentAndCleanup(true)
        self.numTip = nil
    end
    if self.numTip == nil then
        self.numTip = getNumTip(tipType)
        local pos = self.item:getChildByName("icon_add"):getPosition()
        self.numTip:setPositionXY(pos.x + 18, pos.y - 18)
        self.item:addChild(self.numTip)
    end
    self.numTip:setVisible(true)
    self.numTip:setNum(num)
end

function PropListItem:hideNumTip()
    if self.numTip ~= nil and not self.numTip.isDisposed then
        self.numTip:setVisible(false)
    end
end

function PropListItem:getDefaultItemID()
    return self.prop:getDefaultItemID()
end

function PropListItem:setPropItemData(propItemData, isUnlimited, maxUseTime)
  self.prop = propItemData
  self.prop:initTimeProps()

  --if __WIN32 then
    --isUnlimited = true
  --end

  self.prop:enableUnlimited(isUnlimited, maxUseTime)
end

function PropListItem:isAddMoveProp()
  --推送召回功能 三免费道具打关卡需求 10057 临时魔力扫把
  return self.prop and self.prop:isAddMoveProp(self.propListAnimation.levelId) 
end

function PropListItem:setTemporaryMode(v)
  local item = self.item
  local itemNum = self.prop:getTotalItemNumber()
  if itemNum > 0 then---------animation
    if v then
        self:showNumTip(NumTipType.ORANGE)
        if self.disabled then self:lock(false) end
        local bg = self.numTip:getTipBg()
        if bg ~= nil then
            bg:runAction(CCRepeatForever:create(CCSequence:createWithTwoActions(CCTintTo:create(0.8, 220,220,220), 
                                                                                CCTintTo:create(0.8, 255,255,255))))
        end
    else
        self:showNumTip(NumTipType.RED)
    end
    if v and self.disabled then self:lock(false) end
  end   
end

function PropListItem:setFakeMode(v)
  local item = self.item
  local itemNum = self.prop:getTotalItemNumber()
  if itemNum > 0 then---------animation
    if v then
        self:showNumTip(NumTipType.ORANGE)
        if self.disabled then 
          self:lock(false) 
          self.isPlayShowAnimation = false
        end
        local bg = self.numTip:getTipBg()
        if bg ~= nil then
            bg:runAction(CCRepeatForever:create(CCSequence:createWithTwoActions(CCTintTo:create(0.8, 220,220,220), 
                                                                                CCTintTo:create(0.8, 255,255,255))))
        end
    else
        self:showNumTip(NumTipType.RED)
    end
    if v and self.disabled then self:lock(false) end
  end   
end

function PropListItem:hintTemporaryMode()
  if self.prop:isTemporaryMode() and not self.isHintMode then
    self.isHintMode = true
  end
end

function PropListItem:useWithType(itemId, propType)
  assert(type(itemId)=="number")
  assert(type(propType) == "number")

  local tempItem = self.prop:useWithType(itemId, propType)
  if tempItem then 
      self:_updateTemporaryMode() 
  end

  self:updateItemNumber()
end

function PropListItem:resetNumTipShow()
    if self.numTip ~= nil and not self.numTip.isDisposed then
        local numUI = self.numTip:getNumUI()
        if numUI ~= nil and not numUI.isDisposed then
            AnimationUtil.groupFadeAnimStop(numUI)
            LogicUtil.setLayerAlpha(numUI, 1)
        end
        self.numTip.bg1:stopAllActions()
        self.numTip.bg1:setAlpha(1)
        self.numTip.bg2:stopAllActions()
        self.numTip.bg2:setAlpha(1)
    end
end

function PropListItem:show(delayTime, newIcon, initDisable)
  --printx( 1, "PropListItem:show  -----------  delayTime:" , delayTime , "newIcon:" , newIcon , "initDisable:" , initDisable)
  self.visible = true
  self.isPlayShowAnimation = true
  
	local delay = delayTime + self.index * 0.1
	local item = self.item
  local bg_normal = item:getChildByName("bg_normal")
  local icon_add = item:getChildByName("icon_add")

  local prop = self.prop
  assert(prop, "prop should not be nil!!!!!!!")
  local itemId = prop and prop.itemId or 0

  self.itemName = Localization:getInstance():getText("prop.name."..itemId)
  item:getChildByName("name_label"):setString(self.itemName)

  self:setTemporaryMode(self.prop:isTemporaryMode())
  self:updateItemNumber()

  self:resetNumTipShow()
  icon_add:stopAllActions()
  icon_add:setOpacity(255)

  bg_normal:stopAllActions()
  bg_normal:setScale(1)
  bg_normal:setRotation(0)
  bg_normal:setOpacity(255)

  self.startAngle = self.beginRotation

  self.animator:show(newIcon)

  if newIcon then
    if self.icon then self.icon:removeFromParentAndCleanup(true) end
    local icon = PropListAnimation:createIcon(itemId)
    if icon then
    	icon:setCascadeOpacityEnabled(true)
  		icon:setCascadeColorEnabled(true)
    	icon:setPosition(ccp(self.iconSize.x + self.iconSize.width/2, self.iconSize.y - self.iconSize.height/2))
    	item:addChildAt(icon, 4)
      if initDisable then
        item:setOpacity(130)
        self.disabled = true
        ----printx( 1 , "PropListItem:show  !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!" , debug.traceback())
        self.reasonType = 1
      end
    end
    self.icon = icon
  else
    local icon = self.icon
    if icon then
      icon:stopAllActions() -- If some times icon hide, can fix by stopAllActions
      icon:setVisible(true)
      icon:setOpacity(255)
      icon:setPosition(ccp(self.iconSize.x + self.iconSize.width/2, self.iconSize.y - self.iconSize.height/2))
    end    
  end
end

function PropListItem:isItemRequireConfirm()
    return self.prop:isItemRequireConfirm()
end

function PropListItem:verifyItemId( itemId )
    return self.prop:verifyItemId(itemId)
end

function PropListItem:confirm(itemId, usedPositionGlobal)
	local prop = self.prop
	if not prop then return end

	self.isAnimating = true

	local function onClearAnimate()
		self.isAnimating = false
		if self.animateID then CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.animateID) end
		self.animateID = nil
	end
	self.animateID = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(onClearAnimate,1,false);

  local isTemporaryMode = self.prop:confirm(itemId, self.propListAnimation.levelId)
  if isTemporaryMode then
    self:_updateTemporaryMode()  	
  end

	self:updateItemNumber()

	self:bubble(0.3)
	self:explode(0.4, usedPositionGlobal)
end

function PropListItem:playMaxUsedAnimation(tipDesc)
  self.animator:shake()
  self.animator:playMaxUsedAnimation(tipDesc)
end

function PropListItem:use(isGuideRefresh, noGuide)
	local prop = self.prop
  local meta = self.prop:getPropMeta()
  if not prop or not meta then return false end
  
	--avoid use prop multy times
	if self.isAnimating then return false end

	if not prop or self.prop:getTotalItemNumber() < 1 then 
        if prop.itemId == ItemType.RANDOM_BIRD or prop.itemId == ItemType.TIMELIMIT_RANDOM_BIRD then
          CommonTip:showTip( Localization:getInstance():getText("prop.disabled.tip10") , "negative")
          return false
        end

        if prop.itemId == ItemType.INGAME_ROW_EFFECT 
          or prop.itemId == ItemType.TIMELIMIT_INGAME_ROW_EFFECT 
          or prop.itemId == ItemType.TIMELIMIT_48_INGAME_ROW_EFFECT 
          or prop.itemId == ItemType.INGAME_COLUMN_EFFECT 
          or prop.itemId == ItemType.TIMELIMIT_INGAME_COLUMN_EFFECT 
          or prop.itemId == ItemType.TIMELIMIT_48_INGAME_COLUMN_EFFECT 
          then
          if not MaintenanceManager:getInstance():isEnabled("PropRocketsAvailable") then
            -- CommonTip:showTip( Localization:getInstance():getText("prop.disabled.tip11") , "negative")
            self:playMaxUsedAnimation(Localization:getInstance():getText("prop.disabled.tip11"))
            return false
          end
        end

		    self.animator:shake()
		    if self.controller.buyPropCallback then
			    self.controller:callBuyPropCallback(prop.itemId)
		    end

		return false
	end

  --printx( 1 , "PropListItem:use =======================================   self.reasonType = " , self.reasonType )

  if self.prop:isMaxUsed() or self.canNotUseThisSkillCD > 0 then

    if self.canNotUseThisSkillCD > 0 then
        tip = Localization:getInstance():getText("prop.disabled.tip3", {num=self.prop.maxUsetime})
    else
        tip = Localization:getInstance():getText("prop.disabled.tip2", {num=self.prop.maxUsetime})
    end

    if self.prop.itemId == GamePropsType.kOctopusForbid or self.prop.itemId == GamePropsType.kOctopusForbid_l then
      tip = Localization:getInstance():getText("prop.disabled.tip6")
    end
    self:playMaxUsedAnimation(tip)
    return false
  elseif self.reasonType then
    if self.reasonType == 1 then
      local tip = Localization:getInstance():getText("prop.disabled.tip3", {num=self.prop.maxUsetime})
      self:playMaxUsedAnimation(tip)
    elseif self.reasonType == 2 then
      local tip = Localization:getInstance():getText("prop.disabled.tip4", {num=self.prop.maxUsetime})
      self:playMaxUsedAnimation(tip)
    elseif self.reasonType == 3 then
      local tip = Localization:getInstance():getText("prop.disabled.tip8")
      self:playMaxUsedAnimation(tip)
    elseif self.reasonType == 4 then
      local tip = Localization:getInstance():getText("prop.disabled.tip7")
      self:playMaxUsedAnimation(tip)
    elseif self.reasonType == 5 then
      local tip = Localization:getInstance():getText("prop.disabled.tip9")
      self:playMaxUsedAnimation(tip)
    end 
    return false
  end

  local usePropType = self.prop:getPropType()

	-- Use Prop Callback
	if self.controller.usePropCallback then

		local itemId 		= self.prop:findItemID()		
		local isRequireConfirm	= self.prop:isItemRequireConfirm()
    local expireTime = nil
    if usePropType == UsePropsType.EXPIRE then
      expireTime = self.prop:findTimePropExpireTime()
    end

    if _G.isLocalDevelopMode then printx(0, "use prop:", itemId, usePropType, isRequireConfirm) end
		return self.controller:callUsePropCallback(self, itemId, usePropType, expireTime, isRequireConfirm, isGuideRefresh, noGuide)
	end
  return true
end

function PropListItem:focus( enabled, confirm )
	local prop = self.prop
	if not prop then return end

  if self.disabled then return end

	if self.isPlayShowAnimation then
		if _G.isLocalDevelopMode then printx(0, "ERROR!!! focus item can not executed before display animation finished") end
		return
	end

  self.animator:focus(enabled, confirm)

  self:dispatchEvent(Event.new(PropListItem.Events.kFocusChange,enabled))
end

function PropListItem:lock(v)
  --printx( 1 , "PropListItem:lock   index =" , self.index , "v =" , v , "self.disabled =" , self.disabled , debug.traceback())
  if v == self.disabled then return end
  local item = self.item
  if v then
      local darkAnimationTime = 0.3
      item:stopAllActions()
      item:setVisible(true)
      item:setScale(1)
      item:setRotation(self.startAngle or 0)
      item:setPosition(ccp(self.beginPosition.x, self.beginPosition.y))
      --item:runAction(CCSpawn:createWithTwoActions(CCFadeTo:create(darkAnimationTime, 130), CCEaseElasticOut:create(CCScaleTo:create(darkAnimationTime, 1))))
      item:setOpacity(130)
      item:setScale(1)
  else
      item:stopAllActions()
      item:setVisible(true)
      item:setRotation(self.startAngle or 0)
      item:setOpacity(255)
      item:setScale(1)
  end
  self.disabled = v
end

function PropListItem:dark( enabled )
	if self.isPlayShowAnimation then
		if _G.isLocalDevelopMode then printx(0, "ERROR!!! dark item can not executed before display animation finished") end
		return
	end
  if self.disabled then return end

  self.animator:dark(enabled)
end

function PropListItem:stopHint()
	self.isAnimateHint = false
	self.isHintMode = false
  self.item:stopAllActions()
end

function PropListItem:increaseTimePropNumber(propId, itemNum, expireTime)
  if ItemType:isTimeProp(propId) then
    self.prop:increaseTimePropNumber(propId, itemNum, expireTime)
    self:_updateTemporaryMode()
    self.animator:playIncreaseAnimation()
    self:hintTemporaryMode()
  end
end

function PropListItem:increaseItemNumber( itemId, itemNum )
  local isTemp  = self.prop:increaseItemNumber(itemId, itemNum)

  if isTemp then
    self:_updateTemporaryMode()
    self.animator:playIncreaseAnimation()
    self:hintTemporaryMode()
  else
    self.animator:playIncreaseAnimation()
  end
end

function PropListItem:_updateTemporaryMode()
  --self.prop:updateTemporaryItemNumber(itemId, itemNum)

  if self.prop:isTemporaryExist() then 
    self:setTemporaryMode(true) 
  else 
    self:setTemporaryMode(false)
  end
end

function PropListItem:increaseTemporaryItemNumber( itemId, itemNum )
  self.prop:updateTemporaryItemNumber(itemId, itemNum)
  self:_updateTemporaryMode()
  self.animator:playIncreaseAnimation()
  self:hintTemporaryMode()
end

function PropListItem:_updateFakeMode()
  --self.prop:updateTemporaryItemNumber(itemId, itemNum)

  if self.prop:isFakePropExist() then 
    self:setFakeMode(true) 
  else 
    self:setFakeMode(false)
  end
end

function PropListItem:increaseFakeItemNumber( itemId, itemNum , usedTimesFix )
  self.prop:increaseFakeItemNumber(itemId , itemNum , usedTimesFix)
  self:_updateFakeMode()
  self.animator:playIncreaseAnimation()
end

function PropListItem:explode( animationTime, usedPositionGlobal )
  self.isPlayExplodeAnimation = true
  local function onAnimationFinished()
    self.isPlayExplodeAnimation = false
    if self.isAnimateHint then 
      self:stopHint() 
    end
    if self:isAddMoveProp() then 
      self:hide() 
      self.isExplodeing = false
    else 
      self:show(0)
    end
    if self.prop and self.prop:isTemporaryMode() and self.onTemporaryItemUsed ~= nil then 
      self:onTemporaryItemUsed(self) 
    end 


    if self.onUsedCallback then self.onUsedCallback() end
  end

  self.animator:explode(animationTime, usedPositionGlobal, onAnimationFinished)
end

function PropListItem:isPlayingAnimation()
  ----printx( 1 , "PropListItem:isPlayingAnimation  1  self.index =" , self.index , "  self.disabled = " , self.disabled)
  if self.disabled then 
   ----printx( 1 , "PropListItem:isPlayingAnimation  2  false")
    return false 
  end
  ----printx( 1 , "PropListItem:isPlayingAnimation  3  self.isPlayShowAnimation:" , self.isPlayShowAnimation , "  self.isPlayExplodeAnimation:" , self.isPlayExplodeAnimation)
  return self.isPlayShowAnimation or self.isPlayExplodeAnimation
end

function PropListItem:bubble(delayTime)
   self.animator:bubble(delayTime)
end

function PropListItem:hitTest( position )
  --printx( 1 , "PropListItem:hitTest   position =" , position.x , position.y , "self.darked =" , self.darked , "self.isPlayShowAnimation" , self.isPlayShowAnimation , "self.isTouchEnabled" , self.isTouchEnabled)
  local isTouchDisaable = self.darked or self.isPlayShowAnimation or not self.isTouchEnabled 
	if isTouchDisaable then return false end

	local center = self.center
  
  local offsetY = _G.clickOffsetY or 0
  position = ccp(position.x,position.y + offsetY / 2)
	position = self.item:convertToNodeSpace(position)
	local dx = position.x - center.x
	local dy = position.y - center.y
  --printx( 1 , "PropListItem:hitTest   dx" , dx , "dy" , dy , "center.r" , center.r)
	return (dx * dx + dy * dy) < center.r * center.r
end

function PropListItem:setDisableReason(reasonType)
  --printx( 1 , "PropListItem:setDisableReason !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!   reasonType =" , self.reasonType , " self.isPlayShowAnimation =" , self.isPlayShowAnimation)
  if self.isPlayShowAnimation then
    self.isPlayShowAnimation = false
  end
  self.reasonType = reasonType
  self:lock(true)
end

function PropListItem:addNumber(itemNum)
    self.prop:addNumber(itemNum)
    self:updateItemNumber()
end

function PropListItem:setNumber(itemNum)
    self.prop:setNumber(itemNum)
    self:updateItemNumber()
end

function PropListItem:setEnable()
  self.reasonType = nil
  if self.prop:isMaxUsed() or self.canNotUseThisSkillCD > 0 then
    self:lock(true)
  else
    self:lock(false)
  end
end

function PropListItem:revertUsedTimes( ... )
  self.prop:revertUsedTimes()
  if self.disabled then 
      self:lock(false)
  end
  self:updateItemNumber()
end