local function getClassName(obj)
	for k, v in pairs(_G) do
		if v == obj.class then
			return k
		end
	end;
end


local BtnCtrl = class()

BtnCtrl.State = {
	kGoing = 1,
	kFinishAllowReward = 2,
	kFinishNotAllowReward = 3
}

function BtnCtrl:ctor( playBtn, getRewardBtn )


	self.playBtn = playBtn
	self.getRewardBtn = getRewardBtn


	self.playBtn:setColorMode(kGroupButtonColorMode.blue)
	self.playBtn:setString('去闯关')

	self.getRewardBtn:setColorMode(kGroupButtonColorMode.orange)
	self.getRewardBtn:setString('领取奖励')


	self.playBtn:ad(DisplayEvents.kTouchTap, preventContinuousClick(function ( ... )
		self:onClickPlay()
	end))

	self.getRewardBtn:ad(DisplayEvents.kTouchTap, preventContinuousClick(function ( ... )
		self:onClickGetReward()
	end))

	self.state = BtnCtrl.State.kGoing

	self:refresh()
	self:playAnim()
end

function BtnCtrl:playAnim( ... )

 --  	local function createAction( ... )
 --  		local deltaTime = 0.9
	--     local scale = 1
	--     local animations = CCArray:create()
	--     animations:addObject(CCScaleTo:create(deltaTime, 0.98/scale, 1.03*scale))
	--     animations:addObject(CCScaleTo:create(deltaTime, 1.01*scale, 0.96/scale))
	--     animations:addObject(CCScaleTo:create(deltaTime, 0.98/scale,1.03*scale))
	--     animations:addObject(CCScaleTo:create(deltaTime, 1.01*scale, 0.96/scale))
	--     local action = CCRepeatForever:create(CCSequence:create(animations))
	--     return action
	-- end

    self.playBtn:useBubbleAnimation()
    self.getRewardBtn:useBubbleAnimation()
end

function BtnCtrl:onClickPlay( ... )

    local LadybugDataManager = require 'zoo.panel.newLadybug.LadybugDataManager'

	local taskId = LadybugDataManager:getInstance():getCurTaskId()
	local target = nil

	if taskId then
		target = LadybugDataManager:getInstance():getTaskTarget(taskId)
	end

	if not target then return end

	if target.taskType == LadybugDataManager.TaskTargetType.kSeasonWeekly then
		if RankRaceMgr:getInstance():isEnabled() then
			RankRaceMgr:getInstance():openMainPanel()
		else
			SeasonWeeklyRaceManager:getInstance():pocessSeasonWeeklyDecision()
		end
		
	else
		local topLevel = math.min(UserManager.getInstance().user:getTopLevelId(), target.level)

		local star = 0
		local score = UserManager.getInstance():getUserScore(target.level)
		if score then
			star = score.star
		end


	    local passed = UserManager.getInstance():hasPassedLevelEx(topLevel)

	    local function __popoutTip( ... )
	    end

	    HomeScene:sharedInstance().worldScene:moveNodeToCenter(topLevel, function ( ... )
	        if (not passed) or (target.level == topLevel and star < target.star) then
	            local startGamePanel = StartGamePanel:create(topLevel, GameLevelType.kMainLevel)
	            startGamePanel:popout(function ( ... )
	                __popoutTip()
	            end)
	        else
	            __popoutTip()
	        end
	    end)
	end

	

    if self.playBtnCallback then
    	self.playBtnCallback()
    end

end

function BtnCtrl:onClickGetReward( ... )
	if self.state == BtnCtrl.State.kFinishNotAllowReward then
		CommonTip:showTip('现在还不能领奖')
		return
	end

	if self.getRewardCallback then
		self.getRewardCallback()
	end
end

function BtnCtrl:refresh( ... )

	if self.state == BtnCtrl.State.kGoing then
		self.playBtn:setVisible(true)
		self.getRewardBtn:setVisible(false)
	elseif self.state == BtnCtrl.State.kFinishAllowReward then
		self.playBtn:setVisible(false)
		self.getRewardBtn:setVisible(true)
		self.getRewardBtn:setEnabled(true)
		self.getRewardBtn:setString('领取奖励')
	elseif self.state == BtnCtrl.State.kFinishNotAllowReward then
		self.playBtn:setVisible(true)
		self.getRewardBtn:setVisible(false)
	end
end

function BtnCtrl:setState( newState )
	if self.state ~= newState then
		self.state = newState
		self:refresh()
	end
end

function BtnCtrl:getState( ... )
	return self.state
end

function BtnCtrl:setPlayBtnCallback( playBtnCallback )
	self.playBtnCallback = playBtnCallback
end

function BtnCtrl:setGetRewardCallback( getRewardCallback )
	self.getRewardCallback = getRewardCallback
end

return BtnCtrl