local SuperCls = require('zoo.ui.edit.BaseInterface')

local BaseEditCtrl = class(SuperCls)

function BaseEditCtrl:ctor( ... )
	self.displayView = nil
	self.editView = nil
end

function BaseEditCtrl:create()
	local instance = BaseEditCtrl.new()
	instance:init()
	return instance
end

function BaseEditCtrl:init( ... )
	SuperCls.init(self, ...)

	if self.isDisposed then return end

	self:setTouchEnabled(true)
	self:ad(DisplayEvents.kTouchTap, preventContinuousClick( function ( ... )
		self:onEditClick()
	end))
end

function BaseEditCtrl:onEditClick( ... )
	if self.isDisposed then return end

	if self:isEditing() then
		return
	end

	if self.editView then
		self:addChild(self.editView)
		if self.onEditBeginCallback then
			self.onEditBeginCallback(function ( ... )
				if self.isDisposed then return end
				if self.editView then
					self.editView:hide()
				end
			end)
		end

		self:signal('begin_edit')
	else
		CommonTip:showTip('不可编辑')
	end
end

function BaseEditCtrl:isEditing( ... )
	if self.isDisposed then return end
	return self.editView and self.editView:getParent() ~= nil
end

function BaseEditCtrl:setDisplayView( displayView )
	if self.isDisposed then return end

	if self.displayView then
		self.displayView:removeFromParentAndCleanup(true)
		self.displayView = nil
	end

	self.displayView = displayView

	if self.displayView then
		self:addChild(self.displayView)
		self.displayView:setAnchorPoint(ccp(0, 0))
	end

	self:onDisplayViewChange()

	self:onViewChange()
end

function BaseEditCtrl:onDisplayViewChange( ... )
	if self.isDisposed then return end

	local w, h = 0, 0

	if self.displayView then
		local size = self.displayView:getContentSize()
		local sx, sy = self.displayView:getScaleX(), self.displayView:getScaleY()
		w, h = size.width * sx, size.height * sy
	end

	
	self:setContentSize(CCSizeMake(w, h))
	-- self:setColor(ccc3(255, 0, 0))
	-- self:setOpacity(255)
end

function BaseEditCtrl:setEditView( editView )
	if self.isDisposed then return end

	if self.editView then
		self.editView:removeFromParentAndCleanup(true)
		self.editView = nil
	end

	self.editView = editView

	if self.editView then
		self:addChild(self.editView)
	end

	-- self.editView:setVisible(false)
	self.editView:removeFromParentAndCleanup(false)
	self:onViewChange()
end

function BaseEditCtrl:openEditor( ... )
	if self.isDisposed then return end
	self:onEditClick()
end

function BaseEditCtrl:onViewChange( ... )
	if self.isDisposed then return end
	if self.editView and self.displayView then
		if not self.editView:is_connect('value_change', self.displayView, self.displayView.setValue) then
			self.editView:connect('value_change', self.displayView, self.displayView.setValue)
		end


		if not self.editView:is_connect('edit_hide', self, self.onEditViewHide) then
			self.editView:connect('edit_hide', self, self.onEditViewHide)
		end

		if not self:is_connect('begin_edit', self.editView, self.editView.onPopout) then
			self:connect('begin_edit', self.editView, self.editView.onPopout)
		end
	end
end

function BaseEditCtrl:onEditViewHide( ... )
	if self.isDisposed then return end
	if self.onEditEndCallback then
		self.onEditEndCallback()
	end

	self:signal('end_edit')
end

function BaseEditCtrl:dispose( ... )
	-- body
	SuperCls.dispose(self)

	if self.editView and (not self.editView.isDisposed) then
		self.editView:dispose()
	end
end

function BaseEditCtrl:setValue( v )
	if self.isDisposed then return end
	if self.displayView then
		self.displayView:setValue(v)
	end
	if self.editView then
		self.editView:setValue(v)
	end

end

function BaseEditCtrl:getValue( ... )
	if self.isDisposed then return end
	if self.displayView then
		return self.displayView:getValue()
	end
end
return BaseEditCtrl