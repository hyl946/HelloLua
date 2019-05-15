local RankRaceHttp = {}

local RewardSaijiIndex = 4	--虽然名字带有“赛季”，其实似乎也并不是跟赛季严格相关。后端用其来判断逻辑变化。

function RankRaceHttp:getMiniInfo( onSuccess, onFail, onCancel )
	self:syncPost(kHttpEndPoints.RankRaceGetInfo, {
		stage = 1,
        version = RewardSaijiIndex
	}, onSuccess, onFail, onCancel)
end

function RankRaceHttp:getFullInfo( onSuccess, onFail, onCancel )
	self:syncPost(kHttpEndPoints.RankRaceGetInfo, {
		stage = 2,
        version = RewardSaijiIndex
	}, onSuccess, onFail, onCancel)
end

function RankRaceHttp:getUserInfo(_uid, onSuccess, onFail, onCancel)
	self:syncPost(kHttpEndPoints.queryUser, {
		uid = _uid,
	}, onSuccess, onFail, onCancel)
end

function RankRaceHttp:getCardInfo(_uid, onSuccess, onFail, onCancel)
	self:syncPost(kHttpEndPoints.RankRaceNamecard, {
		targetUid = _uid,
	}, onSuccess, onFail, onCancel)
end

function RankRaceHttp:getBoxReward(boxIndex, onSuccess, onFail, onCancel )
	self:syncPost(kHttpEndPoints.RankRaceGetReward, {
		type = 1,
		index = boxIndex,
        version = RewardSaijiIndex
	}, onSuccess, onFail, onCancel)
end

function RankRaceHttp:getLotteryReward( onSuccess, onFail, onCancel )
	self:syncPost(kHttpEndPoints.RankRaceGetReward, {type = 2, index = 1, version = RewardSaijiIndex}, onSuccess, onFail, onCancel)
end

function RankRaceHttp:getLastWeekReward( onSuccess, onFail, onCancel )
	self:syncPost(kHttpEndPoints.RankRaceGetReward, {type = 3, version = RewardSaijiIndex}, onSuccess, onFail, onCancel)
end

function RankRaceHttp:getDanReward( onSuccess, onFail, onCancel )
	self:syncPost(kHttpEndPoints.RankRaceGetReward, {type = 4, version = RewardSaijiIndex}, onSuccess, onFail, onCancel)
end

function RankRaceHttp:getDanReward2( saijiIndex, onSuccess, onFail, onCancel )
	self:syncPost(kHttpEndPoints.RankRaceGetReward, {type = 6, index = saijiIndex, version = RewardSaijiIndex}, onSuccess, onFail, onCancel)
end

function RankRaceHttp:getOldReward( onSuccess, onFail, onCancel )
	self:syncPost(kHttpEndPoints.RankRaceGetReward, {type = 5, version = RewardSaijiIndex}, onSuccess, onFail, onCancel)
end

function RankRaceHttp:sendGift( frdUids, onSuccess, onFail, onCancel )
	self:syncPost(kHttpEndPoints.RankRaceGetGift, {
		type = 1,
		frdUids = frdUids,
	}, onSuccess, onFail, onCancel)
end

function RankRaceHttp:recvGift(frdUids, onSuccess, onFail, onCancel )
	self:syncPost(kHttpEndPoints.RankRaceGetGift, {
		type = 2,
		frdUids = frdUids,
	}, onSuccess, onFail, onCancel)

end

function RankRaceHttp:getGiftInfo(onSuccess, onFail, onCancel )
	self:post(kHttpEndPoints.RankRaceGetGift, {
		type = 3,
		frdUids = {},
	}, onSuccess, onFail, onCancel)
end

function RankRaceHttp:getShareKey(extra, onSuccess, onFail, onCancel )
	self:post('share', {
		id = 7,
		extra = extra,
	}, onSuccess, onFail, onCancel)
end

function RankRaceHttp:getShareReward( shareKey, onSuccess, onFail, onCancel)
	self:syncPost('getShareRewards', {
		id = 7,
		shareKey = shareKey,
	}, onSuccess, onFail, onCancel)
end

function RankRaceHttp:unlock( onSuccess, onFail, onCancel )
	self:offlinePost(kHttpEndPoints.RankRaceUnlock, {}, onSuccess, onFail, onCancel)
end

function RankRaceHttp:getOldWeeklyRaceRewards( onSuccess, onFail, onCancel )
	
end

--这只是个尝试
function RankRaceHttp:post(endPoint, params, onSuccess, onFail, onCancel, sync)
	local rrMgr = RankRaceMgr:getExistedInstance()
	if rrMgr and (not rrMgr:isValid()) then
		if endPoint ~= kHttpEndPoints.RankRaceGetInfo then
			if onCancel then
				onCancel()
				return
			end
		end
	end

	HttpBase:post(endPoint, params, onSuccess, onFail, onCancel, sync)
end

--这只是个尝试
function RankRaceHttp:syncPost(endPoint, params, onSuccess, onFail, onCancel)
	self:post(endPoint, params, onSuccess, onFail, onCancel, true)
end

--这只是个尝试
function RankRaceHttp:offlinePost(endPoint, params, onSuccess, onFail, onCancel)
	
	HttpBase:offlinePost(endPoint, params, onSuccess, onFail, onCancel)

end


function RankRaceHttp:getShortUrl( url, onSuccess)
	local http = OpNotifyHttp.new()
	http:ad(Events.kComplete, function ( evt )
		local shortUrl = ''
		if evt and evt.data then
			shortUrl = evt.data.extra or ''
    	end
    	if onSuccess then
			onSuccess(shortUrl)
    	end
  	end)
 	http:ad(Events.kError, function ( ... )
  		if onSuccess then
			onSuccess(url)
    	end
  	end)
  	http:load(OpNotifyType.kGetShortUrl, url)
end

_G.RankRaceHttp = RankRaceHttp