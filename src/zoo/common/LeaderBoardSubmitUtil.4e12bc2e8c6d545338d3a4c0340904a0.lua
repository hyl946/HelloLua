LeaderBoardSubmitUtil = class()

function LeaderBoardSubmitUtil.submitPassedLevel(passedLevel)
	-- 上传最高关卡
	local topLevel = passedLevel or UserManager:getInstance().user:getTopLevelId()
	if PlatformConfig:isPlatform(PlatformNameEnum.kWDJ) then
		SnsProxy:submitScore(0, passedLevel)
	elseif PlatformConfig:isPlatform(PlatformNameEnum.kMiTalk) then
		SnsProxy:submitScore(1, passedLevel)
	end
end

function LeaderBoardSubmitUtil.submitTotalStars(totalStars)
	local totalStars = totalStars or UserManager:getInstance().user:getTotalStar()
	if PlatformConfig:isPlatform(PlatformNameEnum.kMiTalk) then
		SnsProxy:submitScore(2, totalStars)
	elseif PlatformConfig:isPlatform(PlatformNameEnum.k360) then
		--SnsProxy:submitScore(0, totalStars)
	end
end
