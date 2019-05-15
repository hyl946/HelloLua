
-- Copyright C2009-2013 www.happyelements.com, all rights reserved.
-- Create Date:	2013Äê12ÔÂ23ÈÕ 10:54:52
-- Author:	ZhangWan(diff)
-- Email:	wanwan.zhang@happyelements.com

require "zoo.common.FlashAnimBuilder"
require "zoo.scenes.component.HomeScene.iconButtons.IconButtonBase"

---------------------------------------------------
-------------- StarRewardButton
---------------------------------------------------

assert(not StarRewardButton)
assert(IconButtonBase)
StarRewardButton = class(IconButtonBase)

function StarRewardButton:ctor()
	self.id = "StarRewardButton"
	self.playTipPriority = 30
end
function StarRewardButton:playHasNotificationAnim()
end
function StarRewardButton:stopHasNotificationAnim()
end

function StarRewardButton:init()
	-- Get UI Resoruce
    self.ui = ResourceManager:sharedInstance():buildGroup('home_scene_icon/btns/btn_i_star_reward')
	--------------
	-- Init Base Class
	-- -------------
	IconButtonBase.init(self, self.ui)
	---------------
	-- Get UI Resource
	-- --------------
	self.numTip = self:addRedDotNum()

	local starRewardTipKey 		= "lady.bug.icon.rewards.tips"
	local starRewardTipValue	= Localization:getInstance():getText(starRewardTipKey, {})
	self:setTipString(starRewardTipValue)
	-----------------
	-- Data
	-- ----------
	self:updateView()
end

function StarRewardButton:updateView()
	if self.isDisposed then return end
	self:stopHasNumberAni()

	local starRewardNum = 0
	if StarRewardModel:getInstance():hasStarReward() then 
		starRewardNum = StarRewardModel:getInstance():getStarRewardNum()
	end	
	self.numTip:setNum(starRewardNum)
	if starRewardNum > 0 then 
		self:playHasNumberAni()
	end
end

function StarRewardButton:positionNumLabelCenter()
	local numLabelSize = self.numLabel:getGroupBounds().size
	local bgSize		= self.bg:getGroupBounds().size
	local deltaWidth	= bgSize.width - numLabelSize.width
	local bgPosX	= self.bg:getPositionX()
	self.numLabel:setPositionX(bgPosX + deltaWidth/2)
end

function StarRewardButton:playOnlyIconAnim()
	IconButtonBase.playOnlyIconAnim(self)
end

function StarRewardButton:stopOnlyIconAnim()
	IconButtonBase.stopOnlyIconAnim(self)
end

function StarRewardButton:create()
	local newStarRewardButton = StarRewardButton.new()
	newStarRewardButton:init()
	newStarRewardButton:initShowHideConfig(ManagedIconBtns.STAR_REWARD)
	return newStarRewardButton
end




StarRewardModel = class()
local instance = nil

function StarRewardModel:ctor()
	self.allMissionComplete = false
	self.currentPromptReward = nil
end

function StarRewardModel:getInstance()
	if not instance then 
		instance = StarRewardModel.new() 
	end
	return instance
end

function StarRewardModel:update()
	-- Get Current Star
	local curTotalStar = UserManager:getInstance().user:getTotalStar()
	local userExtend = UserManager:getInstance().userExtend

	--- Get Star Reward Level
	local nearestStarRewardLevelMeta = MetaManager.getInstance():starReward_getRewardLevel(curTotalStar)
	local nextRewardLevelMeta = MetaManager.getInstance():starReward_getNextRewardLevel(curTotalStar)
	local rewardLevelToPushMeta = nil

	if nearestStarRewardLevelMeta then
		rewardLevelToPush = userExtend:getFirstNotReceivedRewardLevel(nearestStarRewardLevelMeta.id)
		if rewardLevelToPush then
			-- Has Reward Level
			rewardLevelToPushMeta = MetaManager.getInstance():starReward_getStarRewardMetaById(rewardLevelToPush)
		else
			-- All Reward Level Has Received
		end
	end

	if not rewardLevelToPushMeta then
		if nextRewardLevelMeta then
			rewardLevelToPushMeta = nextRewardLevelMeta
		else
			self.allMissionComplete = true
		end
	end
	self.currentPromptReward = rewardLevelToPushMeta
	
	return self
end

-- 是否有可以领取的奖励
function StarRewardModel:hasStarReward()
	local curTotalStar 	= UserManager:getInstance().user:getTotalStar()

	local nearestStarRewardLevelMeta	= MetaManager.getInstance():starReward_getRewardLevel(curTotalStar)
	local nextRewardLevelMeta		= MetaManager.getInstance():starReward_getNextRewardLevel(curTotalStar)
	local rewardLevelToPushMeta 		= false
	local needStarNum = 0

	if nearestStarRewardLevelMeta then
		local rewardLevelToPush = UserManager:getInstance().userExtend:getFirstNotReceivedRewardLevel(nearestStarRewardLevelMeta.id)

		if rewardLevelToPush then
			-- Has Reward Level
			rewardLevelToPushMeta = MetaManager.getInstance():starReward_getStarRewardMetaById(rewardLevelToPush)
			needStarNum = rewardLevelToPushMeta.starNum
		else
			-- All Reward Level Has Received
		end
	end

	if not rewardLevelToPushMeta then
		-- If Has Next Reward Level, Show It
		if nextRewardLevelMeta then
			rewardLevelToPushMeta = nextRewardLevelMeta
			needStarNum = rewardLevelToPushMeta.starNum
		end
	end
	-- if _G.isLocalDevelopMode then printx(0, "[shine]",rewardLevelToPushMeta,self.curTotalStar,rewardLevelToPushMeta.starNum) end
	if rewardLevelToPushMeta and curTotalStar >= rewardLevelToPushMeta.starNum then
		return true, curTotalStar - needStarNum,rewardLevelToPushMeta
	end

	return false, curTotalStar - needStarNum,rewardLevelToPushMeta
end

function StarRewardModel:getStarRewardNum()
	local curTotalStar 	= UserManager:getInstance().user:getTotalStar()
	local userExtend 	= UserManager:getInstance().userExtend

	-- Get RewardLevelMeta 
	local nearestStarRewardLevelMeta 	= MetaManager.getInstance():starReward_getRewardLevel(curTotalStar)
	local nextRewardLevelMeta		= MetaManager.getInstance():starReward_getNextRewardLevel(curTotalStar)
	local rewardLevelToPushMeta 		= false

	if nearestStarRewardLevelMeta then
		local rewardLevelToPush = userExtend:getFirstNotReceivedRewardLevel(nearestStarRewardLevelMeta.id)
		if rewardLevelToPush then
			-- Has Reward Level
			rewardLevelToPushMeta = MetaManager.getInstance():starReward_getStarRewardMetaById(rewardLevelToPush)
		else
			-- All Reward Level Has Received
		end
	end

	if not rewardLevelToPushMeta then
		-- If Has Next Reward Level, Show It
		if nextRewardLevelMeta then
			rewardLevelToPushMeta = nextRewardLevelMeta
		end
	end	

	if not rewardLevelToPushMeta then
		-- if _G.isLocalDevelopMode then printx(99, "return starRewardNum = " , 0) end
		return 0
	end

	local user_starRewardID = rewardLevelToPushMeta.id 
	user_starRewardID =tonumber(user_starRewardID)

	local star_rewardMeta = MetaManager.getInstance().star_reward
	local starRewardNum = 0

	-- if _G.isLocalDevelopMode then printx(99, "user_starRewardID = " , user_starRewardID) end

	for k,v in ipairs( star_rewardMeta ) do
		if _G.isLocalDevelopMode then printx(99, " v.id= " ,  v.id ) end
		if curTotalStar >= v.starNum and user_starRewardID <= tonumber(v.id) then
			starRewardNum= starRewardNum + 1
		end
	end

	-- if _G.isLocalDevelopMode then printx(99, "starRewardNum = " , starRewardNum) end

	return starRewardNum
end
