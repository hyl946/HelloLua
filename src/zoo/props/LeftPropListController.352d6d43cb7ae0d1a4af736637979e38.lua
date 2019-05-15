require "zoo.props.PropListController"

LeftPropListController = class(PropListController)

function LeftPropListController:ctor()

end

function LeftPropListController:create(propList,gameBoardView)
	local ctrl = LeftPropListController.new()
	PropListController.init(ctrl, propList)
	ctrl:_init(gameBoardView)
	return ctrl
end

function LeftPropListController:_init(gameBoardView)
	self.gameBoardView = gameBoardView
end

function LeftPropListController:onTouchBegin(evt)

	local propList = self.propList

	propList.isMoved = false
	propList.prev_position = evt.globalPosition
	propList.begin_index = propList:findHitItemIndex(evt)
	propList:updateVisibleMinX()

	if propList.isTouchEnabled then propList.helpButton:onTouchBegin(evt) end
end

function LeftPropListController:onTouchMove(evt)
	local propList = self.propList

	if propList.propListAnimation.focusItem then
	else   
		if evt.globalPosition and propList.prev_position then
		  local dx = evt.globalPosition.x - propList.prev_position.x
		  local dy = evt.globalPosition.y - propList.prev_position.y
		  if dx < 0 then propList.directionWind = -1 
		  else propList.directionWind = 1 end
		  if dx * dx + dy * dy > 64 then propList.isMoved = true end
		end
		propList:updateContentPosition(evt)
	end  
end

function LeftPropListController:onTouchEnd(evt)
	local propList = self.propList

  	propList.helpButton:onTouchEnd(evt)

	if propList.propListAnimation.focusItem then
	    propList.propListAnimation.focusItem:focus(false)
	    propList.propListAnimation.focusItem = nil
	    propList.propListAnimation:setItemDark(-1, false)
	else
	    propList:updateContentPosition(evt)
	    if propList.isMoved then return propList:windover(propList.directionWind) end

	    if not propList.isTouchEnabled then return end

	    if propList.helpButton:use(evt.globalPosition) then return end

	    if not propList:hasAllItemAnimationFinished() then return end

	    local hitItemID = propList:findHitItemIndex(evt)
	    if hitItemID > 0 and hitItemID == propList.begin_index then 
	      local hitItem = propList["item"..hitItemID]
	      if hitItem:isItemRequireConfirm() then
	          if hitItem:use() then 
	            propList.propListAnimation.focusItem = hitItem
	            hitItem:focus(true) 
	            propList.propListAnimation:setItemDark(hitItemID, true)
	         end
	      else 
	      	hitItem:use() 
	      end
	    end
	end

	propList.begin_index = 0
end


function LeftPropListController:hitTestPoint( worldPosition, useGroupTest )
	local propList = self.propList
	if propList.propListAnimation.focusItem then
		local touchPos = self.gameBoardView:TouchAt(worldPosition.x,worldPosition.y)
		return not self.gameBoardView.gameBoardLogic:isItemInTile(touchPos.x,touchPos.y)
	else
		-- 原来统一处理
	end
end