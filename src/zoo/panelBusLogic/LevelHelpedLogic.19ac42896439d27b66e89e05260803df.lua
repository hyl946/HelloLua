require "zoo.panelBusLogic.AdvanceTopLevelLogic"
require "zoo.panelBusLogic.UpdateLevelScoreLogic"

local LevelHelpedLogic = class()
function LevelHelpedLogic:create(record, levelType, onSuccessCallback, onFailCallback )
	local logic = LevelHelpedLogic.new()
	logic:init(record, levelType, onSuccessCallback, onFailCallback)
	return logic
end

function LevelHelpedLogic:init(record, levelType, onSuccessCallback, onFailCallback )
	self.levelId = record.levelId or 0
	self.record = record
	self.levelType = levelType
	self.onSuccessCallback = onSuccessCallback
	self.onFailCallback = onFailCallback
end

function LevelHelpedLogic:start( ... )

	----------------------------------
    --update AskForHelpInfo info
    ------------------------------ -
    UserManager:getInstance():addAskForHelpInfo(self.record)

	local topLevel = UserManager:getInstance().user:getTopLevelId()
	if topLevel ~= self.levelId then return end

	UserManager:getInstance().lastPassedLevel = self.levelId

	-----------------------
	-- Update Level Score
	-- ---------------------
	local updateLevelScoreLogic = UpdateLevelScoreLogic:create(self.levelId, self.levelType, 0, 0 )
	updateLevelScoreLogic:start()
	
	-- ------------------------------------
	-- Check If It's A New Completed Level
	-- ----------------------------------
	local advanceTopLevelLogic = AdvanceTopLevelLogic:create(self.levelId)
	advanceTopLevelLogic:start()

	-- update toplevelid
	local topLevelID = UserManager:getInstance().user:getTopLevelId()
	UserService.getInstance().user:setTopLevelId(topLevelID) --server

	UserManager:getInstance().userExtend:resetTopLevelFailCount()
	UserService:getInstance().userExtend:resetTopLevelFailCount()
	UserTagManager:onTopLevelChanged()

	DcUtil:logLevelUp(topLevelID)

	--------------
	-- Callback 
	-- -----------
	if self.onSuccessCallback then
		self.onSuccessCallback()
	end

	if NetworkConfig.writeLocalDataStorage then Localhost:getInstance():flushCurrentUserData() end

	LocalNotificationManager.getInstance():setPassLevelFlag(self.levelId, 0, 0)

	FUUUManager:clearContinuousFailuresForGuide( self.levelId , true)

	local nextLevelId = self.levelId + 1
	if MetaManager.getInstance():getMaxNormalLevelByLevelArea() == self.levelId then
		nextLevelId = self.levelId
	end
	HomeScene:sharedInstance():setEnterFromGamePlay(nextLevelId)
	GamePlayEvents.dispatchPassLevelEvent({levelType=self.levelType, levelId=self.levelId, 
		rewardsIdAndPos={},
		isPlayNextLevel=false})

	HomeScene:sharedInstance().worldScene:buildFriendPicture(true)

	HomeScene:sharedInstance().worldScene:onEnterHandler("enter")
end

return LevelHelpedLogic