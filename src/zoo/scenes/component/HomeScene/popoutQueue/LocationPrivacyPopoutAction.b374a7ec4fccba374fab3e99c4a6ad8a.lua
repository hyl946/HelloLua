---------------------------------------------------------------------------------------
-- @Author: dan.liang
-- @Date:   2018-07-16 14:14:57
-- @Email:  dan.liang@happyelements.com
-- @Last Modified by:   Administrator
-- @Last Modified time: 2018-07-16 19:23:21
---------------------------------------------------------------------------------------
LocationPrivacyPopoutAction = class(HomeScenePopoutAction)

function LocationPrivacyPopoutAction:ctor()
	self.ignorePopCount = true
	self.name = "LocationPrivacyPopoutAction"
	self:setSource(AutoPopoutSource.kInitEnter, AutoPopoutSource.kEnterForeground)
end

function LocationPrivacyPopoutAction:checkCanPop()
	if self.debug then
		UserManager:getInstance():clearBAFlag(kBAFlagsIdx.kLocationDCFlag)
	end

	local PrivateStrategy = require 'zoo.data.PrivateStrategy'
	local params = PrivateStrategy:sharedInstance().alertLocationParams
	self:onCheckPopResult(params ~= nil)
end

function LocationPrivacyPopoutAction:popout(next_action)
	local PrivateStrategy = require 'zoo.data.PrivateStrategy'
	local params = PrivateStrategy:sharedInstance().alertLocationParams
	if params then
		local originCloseCallback = params.closeCallback
		params.closeCallback = function()
			if originCloseCallback then originCloseCallback() end
			next_action()
		end
		local Alert = require "zoo.panel.Alert"
		local alertPanel = Alert:create(params)
	    alertPanel:closeBackKeyTap()
		
   		local alertTimeKey = PrivateStrategy:sharedInstance():getKeyWithUid("Alert_Location_DC_Time")
   		PrivateStrategy:sharedInstance():updateAlertShowTime(alertTimeKey)
   		
		PrivateStrategy:sharedInstance().alertLocationParams = nil
	else
		next_action()
	end
end