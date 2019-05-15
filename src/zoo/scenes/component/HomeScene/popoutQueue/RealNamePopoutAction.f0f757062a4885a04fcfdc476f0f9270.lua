RealNamePopoutAction = class(HomeScenePopoutAction)

function RealNamePopoutAction:ctor()
	self.name = "RealNamePopoutAction"
	self.recallUserNotPop = true
	self:setSource(AutoPopoutSource.kInitEnter, AutoPopoutSource.kEnterForeground)
end

function RealNamePopoutAction:checkCanPop()
	if self.debug then
		RealNameManager:setLocalSwitch(true)
	end

	local realNameStatus, realNameFlag = RealNameManager:getRealNameStatus()
	local realRewardPop = not realNameFlag and table.exist({1, 2}, realNameStatus)
	local myTopLevel = UserManager:getInstance().user:getTopLevelId()
	local authPop = RealNameManager:isHomeSceneOpen() 
				and (not RealNameManager.isCallSDK) 
				and (not RealNameManager:getAuthing()) 
				and RealNameManager:getLocalSwitch() 
				and RealNameManager:canHomeSceneForcePopout() 
				and myTopLevel >= 16

	self:onCheckPopResult(realRewardPop or authPop)
end

function RealNamePopoutAction:popout(next_action)
	local myTopLevel = UserManager:getInstance().user:getTopLevelId()
	
	local function authCallback()
		if RealNameManager:isHomeSceneOpen() and (not RealNameManager.isCallSDK) and (not RealNameManager:getAuthing()) and 
			RealNameManager:getLocalSwitch() and RealNameManager:canHomeSceneForcePopout() and myTopLevel>= 16 then
			RealNameManager:onEnterHomeScene()

			RealNameManager:popoutEntryPanel(RealNameEntryType.forcePopout, next_action)
			RealNameManager:refreshHomeScenePopoutDate()
			RealNameManager:incHomeScenePopoutCounter()
		else
			next_action()
		end
	end

	local realNameStatus, realNameFlag = RealNameManager:getRealNameStatus()
	if not realNameFlag and table.exist({1, 2}, realNameStatus) then 
		RealNameManager:getRealNameReward(realNameStatus, false, RealNameRewardType.idcard, authCallback)
	else
		authCallback()
	end	
end