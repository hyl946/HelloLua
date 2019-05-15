
MoleWeeklyRaceManager = class()

local _instance = nil

function MoleWeeklyRaceManager:ctor()

end

function MoleWeeklyRaceManager:getInstance()
	if not _instance then
		_instance = MoleWeeklyRaceManager.new()
	end
	return _instance
end

function MoleWeeklyRaceManager:init()
	--RemoteDebug:uploadLog( "MoleWeeklyRaceManager:init	" , UserManager.getInstance().uid )
	self.uid = UserManager.getInstance().uid
    self.gotExtraTargetNum = 0

    self.mainLogic = GameBoardLogic:getCurrentLogic()
end

function MoleWeeklyRaceManager:getGotExtraTargetNum()
	return self.mainLogic.digJewelCount:getValue()
end

function MoleWeeklyRaceManager:getTotolTargetNum()
	return MoleWeeklyRaceConfig:getCollectTargetAmount()
end

function MoleWeeklyRaceManager:getIsBossAlive()

    if not self.mainLogic:getMoleWeeklyBossData() then
        return false
    else 
        return true
    end
	return false
end

function MoleWeeklyRaceManager:getIsTargetComplete(  )
    local instance = RankRaceMgr:getExistedInstance()
    if instance  then
        if instance:needShowTargetInfoInGamePlay() then

            local isTargetComplete = MoleWeeklyRaceLogic:fullfillStageExtraRequirements( self.mainLogic )
            return  isTargetComplete
        else
            return true
        end
    else
        return true
    end
end
