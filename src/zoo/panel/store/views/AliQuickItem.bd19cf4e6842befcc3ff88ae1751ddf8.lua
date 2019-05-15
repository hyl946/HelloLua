local UIHelper = require 'zoo.panel.UIHelper'



local AliQuickItem = class(Layer)

function AliQuickItem:create( )
	-- body
	local v = AliQuickItem.new()
	v:initLayer()
	v:init()

	return v
end

function AliQuickItem:init( ... )
	local ui = UIHelper:createUI('ui/store.json', 'com.niu2x.store/ali-quick')
	self.ui = ui
	self:addChild(self.ui)
	self.check = self.ui:getChildByPath('check')

	_G.use_ali_quick_pay = UserManager:getInstance():isAliSigned()
	self:refresh()

	self:setTouchEnabled(true)
	self:ad(DisplayEvents.kTouchTap, preventContinuousClick(function ( ... )
		
		if self.isDisposed then return end

		if not _G.use_ali_quick_pay then
			_G.StoreTip:popAliQuickConfirm{
				onConfirm = function ( ... )
					_G.use_ali_quick_pay = true
					self:refresh()
            		DcUtil:UserTrack({category='new_store', sub_category='easy_pay_sign', type = 1})
					self:callAncestors('onNotifyCheckAliQuickPay')
				end,
				onCancel = function ( ... )
            		DcUtil:UserTrack({category='new_store', sub_category='easy_pay_sign', type = 2})
				end
			}
		else
			if UserManager:getInstance():isAliSigned() then
				local AliUnsignConfirmPanel = require "zoo.panel.alipay.AliUnsignConfirmPanel"
				local panel = AliUnsignConfirmPanel:create()
           		panel:popout(function() 
                    if self.isDisposed then return end
                    _G.use_ali_quick_pay = false
					self:refresh()
                end)
            else
            	_G.use_ali_quick_pay = false
				self:refresh()
            end
		end
	end))
end

function AliQuickItem:setVisible( bVisible )
	-- body
	Layer.setVisible(self, bVisible)

	if bVisible then
        self:setTag(0)
		_G.use_ali_quick_pay = UserManager:getInstance():isAliSigned()
		self:refresh()
	else
        self:setTag(HeDisplayUtil.kIgnoreGroupBounds)
		_G.use_ali_quick_pay = false
		self:refresh()
	end

	self:callAncestors('updateContentHeight')
end

function AliQuickItem:refresh( ... )
	if self.isDisposed then return end
	self.check:setVisible(_G.use_ali_quick_pay)
end

return AliQuickItem