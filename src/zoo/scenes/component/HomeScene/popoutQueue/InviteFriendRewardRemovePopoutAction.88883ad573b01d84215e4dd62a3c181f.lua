--移除邀请有礼功能
InviteFriendRewardRemovePopoutAction = class(HomeScenePopoutAction)

function InviteFriendRewardRemovePopoutAction:ctor()
end

function InviteFriendRewardRemovePopoutAction:popout()
	local function onClose()
		self:next()
	end

	local function noPop()
		self:placeholder()
		self:next()
	end

	local function onSuccess(event)
		if event.data then
			local data = event.data
			
			local function invitedFriendsHttpSuccess()
				local invitedFriends = FriendManager.getInstance().invitedFriends or {}
				local invite_reward = MetaManager:getInstance().invite_reward
				local bFinish, rewardList = true, {}
				for _, v1 in pairs(data) do
					if v1.invite and v1.lastRewardId ~= 60 then
						bFinish = false
						local friendInfo = FriendManager.getInstance().invitedFriends[v1.friendUid]
						if friendInfo then
							local bitMask = 2
			            	for index = 1, 4 do
			            	    bitMask = bitMask * 2
			            	    if bit.band(v1.lastRewardId, bitMask) == 0 then
			            	        local rewardMeta = invite_reward[index + 1]
			            	        if friendInfo.topLevelId >= rewardMeta.condition[1].num then
			            	        	local rewards = rewardMeta.rewards
			            	        	for _, v2 in pairs(rewards) do
			            	        		if rewardList[v2.itemId] then 
			            	        			rewardList[v2.itemId] = rewardList[v2.itemId] + v2.num
			            	        		else
			            	        			rewardList[v2.itemId] = v2.num
			            	        		end
			            	        	end 
			            	    	end
			            	    end
							end
						end
					end
				end

				if not bFinish then 
					local panel = require("zoo.panel.InviteFriendRewardRemovePanel"):create(onClose, rewardList)
					panel:popout()
				else
					noPop()
				end
			end

			local invitedFriendsHttp = GetInvitedFriendsUserInfo.new()
			invitedFriendsHttp:addEventListener(Events.kComplete, invitedFriendsHttpSuccess)
			invitedFriendsHttp:load(data)
		else
			noPop()
		end 
	end

	local function onFailed(event)
		noPop()
	end
	local bPopout = UserManager:getInstance():hasBAFlag(kBAFlagsIdx.kInviteFriendRewardRemovePopout)
	if not bPopout then
		if _G.kUserLogin then
			if AccountBindingLogic.preconnectting then
				noPop()
				return
			end
			local http = GetInviteFriendsInfo.new(true)
			http:addEventListener(Events.kComplete, onSuccess)
			http:addEventListener(Events.kError, onFailed)
			http:load()
		else
			noPop()
		end
		-- PaymentNetworkCheck.getInstance():check(function ()
		-- 	if AccountBindingLogic.preconnectting then
		-- 		noPop()
		-- 		return
		-- 	end
		-- 	local http = GetInviteFriendsInfo.new(true)
		-- 	http:addEventListener(Events.kComplete, onSuccess)
		-- 	http:addEventListener(Events.kError, onFailed)
		-- 	http:load()
		-- end, function()
		-- 	noPop()
		-- end)
	else
		noPop()
	end
end


function InviteFriendRewardRemovePopoutAction:getConditions( ... )
    return {"enter","enterForground","preActionNext"}
end