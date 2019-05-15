require "zoo.props.PropListController"

RightPropListController = class(PropListController)

function RightPropListController:ctor()

end

function RightPropListController:create(propList)
	local ctrl = RightPropListController.new()
	PropListController.init(ctrl, propList)
	ctrl:_init()
	return ctrl
end

function RightPropListController:_init()
end

function RightPropListController:onTouchBegin(evt)
	local propList = self.propList
	propList.isMoved = false
	propList.prev_position = evt.globalPosition
end

function RightPropListController:onTouchMove(evt)
	local propList = self.propList
	if evt.globalPosition and propList.prev_position then
		local dx = evt.globalPosition.x - propList.prev_position.x
		local dy = evt.globalPosition.y - propList.prev_position.y
		if dx * dx + dy * dy > 64 then propList.isMoved = true end
	end
	propList.prev_position = evt.globalPosition
end

function RightPropListController:onTouchEnd(evt)
	local propList = self.propList
	if propList.propListAnimation.focusItem then
	    propList.propListAnimation.focusItem:focus(false)
	    propList.propListAnimation.focusItem = nil
	    propList.propListAnimation:setItemDark(-1, false)
	else
		if propList.isMoved then return	end
		local hitItem = propList:foundHitItem(evt)
		if hitItem then
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
end