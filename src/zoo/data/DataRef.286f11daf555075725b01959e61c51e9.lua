require "zoo.util.MemClass"
require "zoo.data.BitFlag"

local uuid = require "hecore.uuid"

local debugDataRef = false

--
-- DataRef ---------------------------------------------------------
--
DataRef = class()
function DataRef:dispose()
end
function DataRef:fromLua( src )
	if not src then
		if _G.isLocalDevelopMode then printx(0, "  [WARNING] lua data is nil") end
		return
	end

	for k,v in pairs(src) do
		if type(v) ~= "function" then self[k] = v end
		if debugDataRef then if _G.isLocalDevelopMode then printx(0, k, v) end end
	end
end

function DataRef:encode()
	local dst = {}
	for k,v in pairs(self) do
		if k ~="class" and v ~= nil and type(v) ~= "function" then dst[k] = v end
	end
	return dst
end
function DataRef:decode(src)
	self:fromLua(src)
end

--
-- ProfileRef ---------------------------------------------------------
--
ProfileRef = class(DataRef)
function ProfileRef:ctor(src)
	self.uid = ""
	self.name = ""
	self.headUrl = "0"
	self.snsId = ""
	self.snsMap = {}
	self.constellation = 0
	self.age = 0
	self.gender = 0
	self.secret = false
	self.customProfile = false
	self.headFrame = 0
	self.headFrameExpire = 0
	self.birthDate = ''
	self.location = ''
	self.headFrames = {}
	self.headFrameShowTime = 0
	self.communityUser = false

	if src ~= nil then self:fromLua(src) end
end
function ProfileRef:haveName()
	if self.name and self.name ~= "" then return true
	else return false end
end
function ProfileRef:setDisplayName( name )
	-- he_log_info('wenkan ProfileRef:setDisplayName '..name)
	self.name = HeDisplayUtil:urlEncode(name)
end
function ProfileRef:getDisplayName()
	if self:haveName() then return nameDecode(self.name)
	else return localize("game.setting.panel.use.device.name.default") end
end

function ProfileRef:getSnsInfo(authorizeType)
	if PlatformAuthDetail[authorizeType] then
		for k,v in pairs(self.snsMap) do
			if v.snsPlatform == PlatformAuthDetail[authorizeType].name then
				return v
			end
		end
	end
	return nil
end

function ProfileRef:setProfile( constellation, age, gender, birthDate, location )
	if constellation then
		self.constellation = constellation
	end

	if age then
		self.age = age
	end

	if gender then
		self.gender = gender
	end

	if birthDate then
		self.birthDate = birthDate
		self:checkAgeConstellation()
	end

	if location then
		self.location = location
	end
end

function ProfileRef:checkProfileAgeConstellation( profile )

	if profile.birthDate and profile.birthDate ~= '' then
		profile.birthDate = string.match(profile.birthDate or '', '^(%d%d%d%d%d%d%d%d)$') or '' 
	end

	if profile.birthDate and profile.birthDate ~= '' then

		local year, month, day = string.match(profile.birthDate, '(%d%d%d%d)(%d%d)(%d%d)')
		local birth = {
			year = tonumber(year),
			month = tonumber(month),
			day = tonumber(day),
		}

		local now = os.date("*t", Localhost:timeInSec())
		local toyear_birth = {year = now.year, month = birth.month, day = birth.day}


		local age = now.year - birth.year - 1
		if compareDate(toyear_birth, now) <= 0 then
			age = age + 1
		end 

		profile.age = age
		-- 9: "my.card.edit.panel.content.constellation1" = "白羊座";
	  --  10: "my.card.edit.panel.content.constellation10" = "摩羯座";
	  --  11: "my.card.edit.panel.content.constellation11" = "水瓶座";
	  --  12: "my.card.edit.panel.content.constellation12" = "双鱼座";
	  --  13: "my.card.edit.panel.content.constellation2" = "金牛座";
	  --  14: "my.card.edit.panel.content.constellation3" = "双子座";
	  --  15: "my.card.edit.panel.content.constellation4" = "巨蟹座";
	  --  16: "my.card.edit.panel.content.constellation5" = "狮子座";
	  --  17: "my.card.edit.panel.content.constellation6" = "处女座";
	  --  18: "my.card.edit.panel.content.constellation7" = "天秤座";
	  --  19: "my.card.edit.panel.content.constellation8" = "天蝎座";
	  --  20: "my.card.edit.panel.content.constellation9" = "射手座";
	  	local constellationDate = {
	  		'0120-0218',	--水瓶座	11
	  		'0219-0320',	--双鱼座	12
	  		'0321-0419',	--白羊座	1
	  		'0420-0520',	--金牛座	2
	  		'0521-0621',	--双子座	3
	  		'0622-0722',	--巨蟹座	4
	  		'0723-0822',	--狮子座	5
	  		'0823-0922',	--处女座	6
	  		'0923-1023',	--天秤座	7
	  		'1024-1122',	--天蝎座	8
	  		'1123-1221',	--射手座	9
	  		-- '1223-0122',	--摩羯座	10
	  	}
	  	local found = 12
	  	for i, v in ipairs(constellationDate) do
	  		local m1, d1, m2, d2 = string.match(v, '(%d%d)(%d%d)-(%d%d)(%d%d)')
	  		m1, d1, m2, d2 = tonumber(m1), tonumber(d1), tonumber(m2), tonumber(d2)

  			if compareDate({year = toyear_birth.year, month = m1, day = d1}, toyear_birth) <= 0 
  				and compareDate({year = toyear_birth.year, month = m2, day = d2}, toyear_birth) >= 0 then

  				found = i
  				break
  			end
	  	end
	  	found = found - 2
	  	if found < 1 then
	  		found = found + 12
	  	end
	  	profile.constellation = found
	end
end

function ProfileRef:checkAgeConstellation( ... )
	self:checkProfileAgeConstellation(self)
end

function ProfileRef:setSnsInfo( authorizeType,snsName, snsHeadUrl, name, headUrl)
	if PlatformAuthDetail[authorizeType] then
		local snsInfo = self:getSnsInfo(authorizeType)
		if not snsInfo then
			snsInfo = { snsPlatform = PlatformAuthDetail[authorizeType].name }
			table.insert(self.snsMap,snsInfo)
		end
		if snsName then 
			snsInfo.snsName = HeDisplayUtil:urlEncode(snsName)
		end
		if name then 
			snsInfo.name = HeDisplayUtil:urlEncode(name)
		end
		if snsHeadUrl then
			snsInfo.headUrl = snsHeadUrl
		end
  		if _G.sns_token and authorizeType == SnsProxy:getAuthorizeType() then
			if name then 
				-- he_log_info('wenkan ProfileRef:setSnsInfo '..name)
				self.name = HeDisplayUtil:urlEncode(name)
			end
			if headUrl then
				self.headUrl = headUrl
			end
        end
    end
end

function ProfileRef:getSnsUsername(authorizeType)
	if PlatformAuthDetail[authorizeType] then
		local snsInfo = self:getSnsInfo(authorizeType)
		if snsInfo then 
			return nameDecode(snsInfo.snsName or "") --认为snsName一定有
		else
			return nil
		end
	else
		return nil
	end
end
-- function ProfileRef:setSnsUsername(authorizeType,snsName)
-- 	if PlatformAuthDetail[authorizeType] then

-- 		-- self.snsMap[PlatformAuthDetail[authorizeType].name] = HeDisplayUtil:urlEncode(snsName)
-- 	end
-- end

function ProfileRef:is360Bound()
	for k,v in pairs(self.snsMap) do
		if v.snsPlatform == PlatformAuthDetail[PlatformAuthEnum.k360].name then
			return true
		end
	end

	return false
end

function ProfileRef:isPhoneBound()
	for k,v in pairs(self.snsMap) do
		if v.snsPlatform == PlatformAuthDetail[PlatformAuthEnum.kPhone].name then
			return true
		end
	end

	return false
end

function ProfileRef:isSNSBound()
	for k,v in pairs(self.snsMap) do
		if v.snsPlatform ~= PlatformAuthDetail[PlatformAuthEnum.kPhone].name then
			return true
		end
	end

	return false
end

function ProfileRef:isQQBound()
	for k, v in pairs(self.snsMap) do
		if v.snsPlatform == PlatformAuthDetail[PlatformAuthEnum.kQQ].name then
			return true
		end
	end
	return false
end

function ProfileRef:isWechatBound()
	for k, v in pairs(self.snsMap) do
		if v.snsPlatform == PlatformAuthDetail[PlatformAuthEnum.kWechat].name then
			return true
		end
	end
	return false
end

function ProfileRef:isBound( authorizeType )
	for k, v in pairs(self.snsMap) do
		if v.snsPlatform == PlatformAuthDetail[authorizeType].name then
			return true
		end
	end
	return false
end

function ProfileRef:fromLua( src )
	if not src then
		if _G.isLocalDevelopMode then printx(0, "  [WARNING] ProfileRef lua data is nil") end
		return
	end
	-- if _G.isLocalDevelopMode then printx(0, "ProfileRef"..tostring(src.headUrl)) end
	self.uid = src.uid
	self.name = src.name
	self.headUrl = src.headUrl
	self.snsId = src.snsId

	self.secret = src.secret or false

	self.snsMap = src.snsMap or {}

	self.fileId = src.fileId
	self.customProfile = src.customProfile

	self:setProfile(src.constellation or 0, src.age or 0, src.gender or 0, src.birthDate, src.location)

	if self.name == nil then self.name = "" end


	if self.headUrl == nil or self.headUrl == "" then self.headUrl = "" .. math.floor( (tonumber(self.uid or 0) or 0) % 11 ) end

	if string.find(self.headUrl, "ani://") ~= nil then
		self.headUrl = string.sub(self.headUrl, 7)
	end

	self.headFrame = src.headFrame
	self.headFrameExpire = src.headFrameExpire

	self.headFrames = table.clone(src.headFrames or {}, true)
	self.headFrameShowTime = src.headFrameShowTime or 0
	self.communityUser = src.communityUser or false
end

--
-- UserRef ---------------------------------------------------------
--
UserRef = class(DataRef) --用户信息
function UserRef:ctor()
	self.uid = 0
	self.inviteCode = 0
	
	self:setCoin(0) --游戏币
	self:setCash(0) --风车币
	self:setEnergy(0) --精力
	self:setStar(0) --总星级
	self:setHideStar(0) --隐藏区域总星级
	self:setTopLevelId(0) --待通过的关卡
	self:setUpdateTime(Localhost:time()) --精力更新时间

	self.point = 0 --积分
	self.image = 0 --玩家 形象

	self.isFriendInfo = false
	self.recoverDiscount = 100
	self.recoverDiscountEndTime = 0 
end
function UserRef:debugPrint(...)
	assert(#{...} == 0)

	if _G.isLocalDevelopMode then printx(0, "======= UserRef:debugPrint =========") end
	if _G.isLocalDevelopMode then printx(0, "uid: " .. self.uid) end
	if _G.isLocalDevelopMode then printx(0, "inviteCode: " .. self.inviteCode) end
	if _G.isLocalDevelopMode then printx(0, "star: " .. self:getStar()) end
	if _G.isLocalDevelopMode then printx(0, "hideStar: " .. self:getHideStar()) end
	if _G.isLocalDevelopMode then printx(0, "topLevelId: " .. self:getTopLevelId()) end
	if _G.isLocalDevelopMode then printx(0, "image: " .. self.image) end
end

function UserRef:fromLua( src )
	if not src then
		if _G.isLocalDevelopMode then printx(0, "  [WARNING] lua data is nil at UserRef:fromLua") end
		return
	end

	for k,v in pairs(src) do		
		if k == "coin" then self:setCoin(v)
		elseif k == "cash" then self:setCash(v)	
		elseif k == "topLevelId" then self:setTopLevelId(v)	
		elseif k == "star" then self:setStar(v)	
		elseif k == "hideStar" then self:setHideStar(v)	
		elseif k == "energy" then self:setEnergy(v)	
		elseif k == "updateTime" then self:setUpdateTime(v)
		elseif k == "recoverDiscount" then self.recoverDiscount = tonumber(v)	
		elseif k == "recoverDiscountEndTime" then self.recoverDiscountEndTime = tonumber(v)		
		elseif k == "inviteCode" then self.inviteCode = tonumber(v)		
		else 
			if type(v) ~= "function" then self[k] = v end
			if debugDataRef then if _G.isLocalDevelopMode then printx(0, k, v) end end
		end
	end
	local updateTime = tonumber(self.updateTime) or Localhost:time()
	-- if _G.isLocalDevelopMode then printx(0, "User->fromLua, updateTime: ", updateTime, os.date(nil, updateTime / 1000), " energy:", self.energy) end
end

function UserRef:getCoin()
	local key = "UserRef.coin"..tostring(self)
	return decrypt_integer(key)
end
function UserRef:setCoin(v)
	local key = "UserRef.coin"..tostring(self)
	self.coin = v --onlu used for encode
	encrypt_integer(key, v)
end

function UserRef:getCash()
	local key = "UserRef.cash"..tostring(self)
	return decrypt_integer(key)
end
function UserRef:setCash(v)
	local key = "UserRef.cash"..tostring(self)
	self.cash = v --onlu used for encode
	encrypt_integer(key, v)
end

function UserRef:getRealTopLevelId()--最高通过关卡而不是最高停留关卡
	local topLevel = self:getTopLevelId()	
	local levelScore = UserManager.getInstance():getUserScore(topLevel)
	if levelScore and levelScore.star > 0 then
		return topLevel 
	else
		return topLevel - 1
	end
end

function UserRef:getTopLevelId()
	local key = "UserRef.topLevelId"..tostring(self)
	local level = decrypt_integer_f(key)
	if level > kMaxLevels then level = kMaxLevels end
	return level
end
function UserRef:setTopLevelId(v)
	local key = "UserRef.topLevelId"..tostring(self)
	if v and self.topLevelId and v < self.topLevelId then
		assert(false, "topLevelId new="..tostring(v)..",old="..tostring(self.topLevelId))
	end
	self.topLevelId = v --onlu used for encode
	encrypt_integer_f(key, v)
end

function UserRef:getStar()
	local key = "UserRef.star"..tostring(self)
	return decrypt_integer(key)
end
function UserRef:setStar(v)
	local key = "UserRef.star"..tostring(self)
	self.star = v --onlu used for encode
	encrypt_integer(key, v)
end

function UserRef:getHideStar()
	local key = "UserRef.hideStar"..tostring(self)
	return decrypt_integer(key)
end
function UserRef:setHideStar(v)
	local key = "UserRef.hideStar"..tostring(self)
	self.hideStar = v --onlu used for encode
	encrypt_integer(key, v)
end

function UserRef:getEnergy()
	local key = "UserRef.energy"..tostring(self)
	return decrypt_integer_f(key)
end
function UserRef:setEnergy(v)
	local key = "UserRef.energy"..tostring(self)
	self.energy = v --onlu used for encode
	encrypt_integer_f(key, v)
end

function UserRef:getUpdateTime()
	local key = "UserRef.updateTime"..tostring(self)
	return decrypt_number(key)
end
function UserRef:setUpdateTime(v)
	local key = "UserRef.updateTime"..tostring(self)
	v = tonumber(v) or Localhost:time() --onlu used for encode
	self.updateTime = v
	encrypt_number(key, v)
end

function UserRef:encode()
	local dst = {}
	self.updateTime = self:getUpdateTime()
	self.energy = self:getEnergy()
	self.hideStar = self:getHideStar()
	self.star = self:getStar()
	self.topLevelId = self:getTopLevelId()
	self.cash = self:getCash()
	self.coin = self:getCoin()

	for k,v in pairs(self) do
		if k ~="class" and v ~= nil and type(v) ~= "function" then dst[k] = v end
	end
	return dst
end

function UserRef:getTotalStar( ...)
	assert(#{...} == 0)

	local usrTotalStar = tonumber(self:getStar()) + tonumber(self:getHideStar())
	return usrTotalStar
end

function UserRef:addEnergy(energyToAdd, ...)
	assert(energyToAdd)
	assert(type(energyToAdd) == "number")
	assert(#{...} == 0)

	--local newEnergy = self:getEnergy() + energyToAdd
	--he_log_warning("hard coded max energy value !")
	--if newEnergy > 30 then
	--	newEnergy = 30
	--end
	--self:setEnergy(newEnergy)

	if _G.isLocalDevelopMode then printx(0, "deprecated function, use UserEnergyRecoverManager:addEnergy instead !") end
	UserEnergyRecoverManager:sharedInstance():addEnergy(energyToAdd)
end

--
-- UserExtendRef ---------------------------------------------------------
--
UserExtendRef = class(DataRef) --用户相关扩展信息
function UserExtendRef:ctor( )
	self:setFruitTreeLevel(0) --金银果树级别
	self:setStarReward(0) --已领取的星级奖励
	self:setNewUserReward(0) --新手奖: 0未领,1领取无限精力,2领取所有奖励
	self:setEnergyPlusEffectTime(0) --精力值额外加值有效时间戳
	self:setNotConsumeEnergyBuff(0) --无限精力值buff 有效时间戳

	self.qqVipNewComeReward = false --qq 新手礼包领取标识
	self.appOnQQPanel = false -- 用户是否将应用图标添加到qq 主面板
	self.appOnQQPanelRewardMark = 0 --用户是否领取将应用图标添加到qq 主面板的奖励: 1,领过；0，未领
	self.ladyBugStart = 0 --是否开启瓢虫任务, 0:未开启, 1:已开启
	self.goldTicket = 0 --用户的金券余额
	self.energyPlusId = 0 --精力值临时额外加值 道具Id
	self.energyPlusPermanentId = 0 --精力值永久额外加值 道具Id
	self.activityMark = 0 --活动弹板mark
	self.scoreGameReward = 0 --评分领奖标识
	self.tutorialStep = 0 --新手引导步骤
	self.playStep = 0 --玩法引导步骤
	self.topLevelFailCount = 0 -- 最高关卡连续失败次数

	self.rewardedHideAreaIds = {} --掩藏关卡领奖标志

	self.achievementValue = {}

	self.latestAddIssueTime = 0 -- 最近一次客服提问时间（s）
	self.continuousLogonStartTime = 0 -- 本次连登开始时间
	self.continuousLogonUpdateTime = 0 -- local data
end

function UserExtendRef:getAchievementValue( achiId )
	for k,v in pairs(self.achievementValue) do
		if v.key == achiId then
			return v.value
		end
	end
	return nil
end

function UserExtendRef:setAchievementValue( achiId, value )
	for k,v in pairs(self.achievementValue) do
		if v.key == achiId then
			v.value = value
			return
		end
	end

	table.insert(self.achievementValue, {key = achiId, value = value})
end

function UserExtendRef:addAchievementValue( achiId, value )
	for k,v in pairs(self.achievementValue) do
		if v.key == achiId then
			v.value = (v.value or 0) + value
			return
		end
	end

	table.insert(self.achievementValue, {key = achiId, value = value})
end

function UserExtendRef:updateAchievementValue( achiValue )
	for _,v in pairs(achiValue) do
		local exist = false
		for _,v2 in pairs(self.achievementValue) do
			if v.key == v2.key then
				v2.value = v.value
				exist = true
				break
			end
		end
		if not exist then
			table.insert(self.achievementValue,v)
		end
	end
end

function UserExtendRef:getFruitTreeLevel()
	local key = "UserExtendRef.fruitTreeLevel"..tostring(self)
	return decrypt_integer(key)
end
function UserExtendRef:setFruitTreeLevel( v )
	local key = "UserExtendRef.fruitTreeLevel"..tostring(self)
	self.fruitTreeLevel = v --onlu used for encode
	encrypt_integer(key, v)
end

function UserExtendRef:getStarReward()
	local key = "UserExtendRef.starReward"..tostring(self)
	return decrypt_integer(key)
end
function UserExtendRef:setStarReward( v )
	local key = "UserExtendRef.starReward"..tostring(self)
	self.starReward = v --onlu used for encode
	encrypt_integer(key, v)
end

function UserExtendRef:getNewUserReward()
	local key = "UserExtendRef.newUserRewardAfter143"..tostring(self)
	return decrypt_integer(key)
end
function UserExtendRef:setNewUserReward( v )
	local key = "UserExtendRef.newUserRewardAfter143"..tostring(self)
	self.newUserReward = v --onlu used for encode
	encrypt_integer(key, v)
end

function UserExtendRef:setEnergyPlusEffectTime( v )
	if v == nil then v = 0 end
	v = tonumber(v)
	local key = "UserExtendRef.energyPlusEffectTime"..tostring(self)
	self.energyPlusEffectTime = v
	encrypt_number(key, v)
end
function UserExtendRef:getEnergyPlusEffectTime()
	local key = "UserExtendRef.energyPlusEffectTime"..tostring(self)
	return decrypt_number(key) or 0
end

function UserExtendRef:setNotConsumeEnergyBuff( v )
	if v == nil then v = 0 end
	v = tonumber(v)
	local key = "UserExtendRef.notConsumeEnergyBuff"..tostring(self)
	self.notConsumeEnergyBuff = v
	encrypt_number(key, v)
end
function UserExtendRef:getNotConsumeEnergyBuff()
	local key = "UserExtendRef.notConsumeEnergyBuff"..tostring(self)
	if PublishActUtil:isGroundPublish() or PlatformConfig:isPlayDemo() then
		oneMoreDay = math.floor(Localhost:time()) + 5*60*1000
		return oneMoreDay
	else
		return decrypt_number(key) or 0
	end
end

function UserExtendRef:isStarRewardReceived(rewardLevel, ...)
	assert(type(rewardLevel) == "number")
	assert(#{...} == 0)

	local mask = bit.lshift(1, rewardLevel)
	local result = bit.band(self:getStarReward(), mask)
	return result > 0 
end

function UserExtendRef:setRewardLevelReceived(rewardLevel, ...)
	assert(type(rewardLevel) == "number")
	assert(#{...} == 0)

	if self:isStarRewardReceived(rewardLevel) then assert(false) end
	local mask = bit.lshift(1, rewardLevel)
	self:setStarReward(bit.bor(self:getStarReward(), mask))
end

function UserExtendRef:getFirstNotReceivedRewardLevel(rewardLevel, ...)
	assert(#{...} == 0)
	for index = 1, rewardLevel do
		if not self:isStarRewardReceived(index) then return index end
	end
	return false
end

function UserExtendRef:hasEnteredInviteCode()
	if not self.flag then return false end
	local bit = require("bit")
	return 1 == bit.band(self.flag, 0x01)
end

function UserExtendRef:hasFirstThirdPay()
	if not self.flag then return true end
	local bit = require("bit")
	return 1 == bit.band(bit.rshift(self.flag, 8), 0x01)
end

function UserExtendRef:setEnteredInviteCode(isSet)
	if not self.flag then return end
	local bit = require("bit")
	if isSet then
		self.flag = bit.bor(self.flag, 0x01)
	else
		if 1 == bit.band(self.flag, 0x01) then 
			self.flag = self.flag - 1
		end
	end
end

function UserExtendRef:allowChangePhoneBinding()
	if not self.flag then return true end
	return not self:isFlagBitSet(8)
end

function UserExtendRef:isIosGuideRewardReceived()
	if not self.flag then return true end -- 未联网或没有flag值
	return self:isFlagBitSet(10)
end

function UserExtendRef:setIosGuideRewardReceived(value)
	if not self.flag then return end
	self:setFlagBit(10, (value == true))
end

function UserExtendRef:isInSmsBlacklist()
	if not self.flag then return false end -- 未联网或没有flag值
	return self:isFlagBitSet(20)
end


function UserExtendRef:isFlagBitSet(bitIndex)
	self.flag = self.flag or 0
	if bitIndex < 1 then bitIndex = 1 end
	local mask = math.pow(2, bitIndex - 1) -- e.g.: mask: 0010

	local bit = require("bit")
	return mask == bit.band(self.flag, mask) -- e.g.:1111 & 0010 = 0010
end

function UserExtendRef:setFlagBit(bitIndex, setToTrue)
	self.flag = self.flag or 0
	if bitIndex < 1 then bitIndex = 1 end
	local mask = math.pow(2, bitIndex - 1) -- e.g.: maks: 0010
	local bit = require("bit")
	if setToTrue == true or setToTrue == 1 then 
		self.flag = bit.bor(self.flag, mask) -- e.g. 1100 | 0010 = 1110
	else
		if mask == bit.band(self.flag, mask) then 
			self.flag = self.flag - mask -- e.g.: 1110 - 0010 = 1100
		end
	end
	return self.flag
end

function UserExtendRef:getLastPayTime()
	return self.lastPayTime or 0
end

function UserExtendRef:setLastPayTime(time)
	if type(time) == "number" then
		self.lastPayTime = time
	end
end

function UserExtendRef:getLastThirdPayTime()
	return self.lastThirdPayTime or 0
end

function UserExtendRef:setLastThirdPayTime(time)
	if type(time) == "number" then
		self.lastThirdPayTime = time
	end
end

function UserExtendRef:getLastApplePayTime()
	return self.lastApplePayTime or 0
end

function UserExtendRef:setLastApplePayTime(time)
	if type(time) == "number" then
		self.lastApplePayTime = time
	end
end


-- 在开始游戏时就记为失败，成功过关后清除
function UserExtendRef:incrTopLevelFailCount(count)
	count = count or 1
	self.topLevelFailCount = self.topLevelFailCount + count
end

function UserExtendRef:resetTopLevelFailCount()
	self.topLevelFailCount = 0
	--LevelDifficultyAdjustManager:updateFailCounts( 0 )
	--[[
	以下代码迁移到【UserTagManager:onTopLevelChanged】中
	UserTagManager:updateTopLevelFailCounts( 0 )

	UserTagAutomationManager:getInstance():checkTagHasChanged( UserTagDCSource.kPassLevel )
	]]
end

function UserExtendRef:isHideAreaRewardReceived( hideAreaId  )
	return table.exist(self.rewardedHideAreaIds,hideAreaId)
end
function UserExtendRef:setHideAreaRewardReceived( hideAreaId  )
	self.rewardedHideAreaIds[hideAreaId] = 1
end

function UserExtendRef:fromLua( src )
	if not src then
		if _G.isLocalDevelopMode then printx(0, "  [WARNING] lua data is nil at UserExtendRef:fromLua") end
		return
	end





	-- print(debug.traceback())
	-- debug.debug()


	for k,v in pairs(src) do
		if k == "fruitTreeLevel" then self:setFruitTreeLevel(v)		
		elseif k == "starReward" then self:setStarReward(v)
		elseif k == "energyPlusEffectTime" then self:setEnergyPlusEffectTime(v)
		elseif k == "newUserRewardAfter143" then -- do nothing
		elseif k == "notConsumeEnergyBuff" then self:setNotConsumeEnergyBuff(v)
		elseif k == "continuousLogonStartTime" then self.continuousLogonStartTime = tonumber(src.continuousLogonStartTime) or 0
		elseif k == "achievementValue" then
			local av = {}
			for k,v in pairs(src.achievementValue) do
				if type(v) == "table" then
					table.insert(av, v)
				end
			end
			self.achievementValue = table.clone(av)
		elseif k == "testInfo" then
			self[k] = v
			DiffAdjustQAToolManager:init(v)
		else 
			if type(v) ~= "function" then self[k] = v end
			if debugDataRef then if _G.isLocalDevelopMode then printx(0, k, v) end end
		end
	end

	-- src.newUserRewardAfter143 == 2 代表已经领取过新手礼包
	-- src.newUserReward == 1 代表 已经领取过 1.43版本之前的老的新手礼包
	if src.newUserRewardAfter143 then -- 服务器端返回
		if src.newUserReward == 1 then
			self:setNewUserReward(2) 
		else
			self:setNewUserReward(src.newUserRewardAfter143)
		end
	else -- 本地数据
		self:setNewUserReward(src.newUserReward or 0) 
	end


	if src.notConsumeEnergyBuff == nil then  self:setNotConsumeEnergyBuff(0) end
	if src.energyPlusEffectTime == nil then  self:setEnergyPlusEffectTime(0) end

	-- if src.newUserReward == nil then 
	-- 	print("function UserExtendRef:fromLua( src ) src.newUserReward == nil "  )
	--  	self:setNewUserReward(0)
	-- end
	if src.continuousLogonStartTime and src.continuousLogonUpdateTime then -- from local
		self:updateContinuousLogonData(Localhost:timeInSec())
		if _G.isLocalDevelopMode then printx(2, "fromLua[LOCAL]:", os.date("%Y/%m/%d %H:%M:%S",self.continuousLogonStartTime/1000),os.date("%Y/%m/%d %H:%M:%S",self.continuousLogonUpdateTime/1000)) end
	elseif src.continuousLogonStartTime then -- from server
		self.continuousLogonUpdateTime = Localhost:time()
		if _G.isLocalDevelopMode then printx(2, "fromLua[SERVER]:", os.date("%Y/%m/%d %H:%M:%S",self.continuousLogonStartTime/1000),os.date("%Y/%m/%d %H:%M:%S",self.continuousLogonUpdateTime/1000)) end
	else -- from local old version data
		self.continuousLogonStartTime = Localhost:time()
		self.continuousLogonUpdateTime = Localhost:time()
		if _G.isLocalDevelopMode then printx(2, "fromLua[LOCAL_OLD]:", os.date("%Y/%m/%d %H:%M:%S",self.continuousLogonStartTime/1000),os.date("%Y/%m/%d %H:%M:%S",self.continuousLogonUpdateTime/1000)) end
	end
end

function UserExtendRef:updateContinuousLogonData(updateTime)
	updateTime = updateTime and (updateTime * 1000) or Localhost:time()
	local diffDays = calcDateDiff(os.date("*t", updateTime/1000), os.date("*t", self.continuousLogonUpdateTime/1000))
	if diffDays == 1 then
		self.continuousLogonUpdateTime = updateTime
		if _G.isLocalDevelopMode then printx(2, "updateContinuousLogonData:", diffDays, os.date("%Y/%m/%d %H:%M:%S",self.continuousLogonStartTime/1000),os.date("%Y/%m/%d %H:%M:%S",self.continuousLogonUpdateTime/1000)) end
		return true
	elseif diffDays ~= 0 then
		if self.continuousLogonStartTime < updateTime then
			self.continuousLogonStartTime = updateTime
		end
		self.continuousLogonUpdateTime = updateTime
		if _G.isLocalDevelopMode then printx(2, "updateContinuousLogonData:", diffDays, os.date("%Y/%m/%d %H:%M:%S",self.continuousLogonStartTime/1000),os.date("%Y/%m/%d %H:%M:%S",self.continuousLogonUpdateTime/1000)) end
		return true
	end
	return false
end

function UserExtendRef:encode()
	local dst = {}
	self.fruitTreeLevel = self:getFruitTreeLevel()
	self.starReward = self:getStarReward()
	self.newUserReward = self:getNewUserReward()
	self.energyPlusEffectTime = self:getEnergyPlusEffectTime()
	self.notConsumeEnergyBuff = self:getNotConsumeEnergyBuff()
	for k,v in pairs(self) do
		if k ~="class" and v ~= nil and type(v) ~= "function" then dst[k] = v end
	end
	return dst
end

--
-- PropRef ---------------------------------------------------------
--
PropRef = class(DataRef) --道具
function PropRef:ctor()
	self.itemId = 0 --道具id
	self.num = 0 --道具数量
end
function PropRef:dispose()
	local key = "PropRef.num."..tostring(self.itemId)..tostring(self)
	HeMemDataHolder:deleteByKey(key)
end
function PropRef:getNum()
	local key = "PropRef.num."..tostring(self.itemId)..tostring(self)
	return decrypt_integer(key)
end
function PropRef:setNum( v )
	local key = "PropRef.num."..tostring(self.itemId)..tostring(self)
	self.num = v --onlu used for encode
	encrypt_integer(key, v)
end

function PropRef:fromLua( src )
	if not src then
		if _G.isLocalDevelopMode then printx(0, "  [WARNING] lua data is nil at PropRef:fromLua") end
		return
	end
	self.itemId = src.itemId
	self:setNum(src.num)
end

function PropRef:encode()
	local dst = {}
	dst.itemId = self.itemId
	dst.num = self:getNum()
	return dst
end

------------------------
-- 限时道具
------------------------
TimePropRef = class(DataRef)
function TimePropRef:ctor( ... )
	self.itemId = 0
	self.num = 0
	self.expireTime = 0
end

function TimePropRef:fromLua(src)
	self.itemId = src.itemId
	self.num = src.num or 1 -- 现在没有数量，默认1
	self.expireTime = tonumber(src.expireTime)
end

function TimePropRef:encode()
	local dst = {}
	dst.itemId = self.itemId
	dst.num = self.num
	dst.expireTime = self.expireTime
	return dst
end

--
-- FuncRef ---------------------------------------------------------
--
FuncRef = class(DataRef) --功能包
function FuncRef:ctor()
	self.itemId = 0 --功能包id
	self.num = 0 --功能包数量
end
function FuncRef:getNum()
	local key = "FuncRef.num."..tostring(self.itemId)..tostring(self)
	return decrypt_integer(key)
end
function FuncRef:setNum( v )
	local key = "FuncRef.num."..tostring(self.itemId)..tostring(self)
	self.num = v --onlu used for encode
	encrypt_integer(key, v)
end
function FuncRef:fromLua( src )
	if not src then
		if _G.isLocalDevelopMode then printx(0, "  [WARNING] lua data is nil at FuncRef:fromLua") end
		return
	end
	self.itemId = src.itemId
	self:setNum(src.num)
end

function FuncRef:encode()
	local dst = {}
	dst.itemId = self.itemId
	dst.num = self:getNum()
	return dst
end

--
-- DecoRef ---------------------------------------------------------
--
DecoRef = class(DataRef) --装扮
function DecoRef:ctor()
	self.itemId = 0 --装扮id
	self.num = 0 --装扮数量
end

function DecoRef:getNum()
	local key = "DecoRef.num."..tostring(self.itemId)..tostring(self)
	return decrypt_integer(key)
end
function DecoRef:setNum( v )
	local key = "DecoRef.num."..tostring(self.itemId)..tostring(self)
	self.num = v --onlu used for encode
	encrypt_integer(key, v)
end
function DecoRef:fromLua( src )
	if not src then
		if _G.isLocalDevelopMode then printx(0, "  [WARNING] lua data is nil at DecoRef:fromLua") end
		return
	end
	self.itemId = src.itemId
	self:setNum(src.num)
end

function DecoRef:encode()
	local dst = {}
	dst.itemId = self.itemId
	dst.num = self:getNum()
	return dst
end
--
-- ScoreRef ---------------------------------------------------------
--
ScoreRef = class(DataRef) --用户关卡得分
function ScoreRef:ctor()
	self.uid = 0 --uid
	self.levelId = 0 --关卡id
	self.score = 0 --最高得分
	self.star = 0 --最高星级
	self.updateTime = 0 --上次更新时间
end

JumpLevelRef = class(DataRef) -- 用户跳关信息
function JumpLevelRef:ctor()
	-- body
	self.levelId = 0
	self.pawnNum = 0
end

--
-- AchiRef ---------------------------------------------------------
--
AchiRef = class(DataRef) --成就
function AchiRef:ctor()
	self.achiId = 0 --成就id
	self.count = 0 --成就数量
end

function AchiRef:getCount()
	local key = "AchiRef.num."..tostring(self.achiId)..tostring(self)
	return decrypt_integer(key)
end
function AchiRef:setCount( v )
	local key = "AchiRef.num."..tostring(self.achiId)..tostring(self)
	self.count = v --onlu used for encode
	encrypt_integer(key, v)
end
function AchiRef:fromLua( src )
	if not src then
		if _G.isLocalDevelopMode then printx(0, "  [WARNING] lua data is nil at AchiRef:fromLua") end
		return
	end
	self.achiId = src.achiId
	self:setCount(src.count)
end

function AchiRef:encode()
	local dst = {}
	dst.achiId = self.achiId
	dst.count = self:getCount()
	return dst
end
--
-- RequestInfoRef ---------------------------------------------------------
--
RequestInfoRef = class(DataRef)
function RequestInfoRef:ctor( )
	self.senderUid = 0 --senderUid
	self.type = 0 --请求类系：1,赠送礼物;2,索要礼物;3,区域解锁的请求;4,索要精力值请求
	self.id = 0 --request消息的id
	self.itemId = 0 --请求物品的id
	self.itemNum = 0 --请求物品的数量
	self.extra = nil
end

--
-- UnLockFriendInfoRef ---------------------------------------------------------
--
UnLockFriendInfoRef = class(DataRef) --区域解锁请求消息
function UnLockFriendInfoRef:ctor( )
	self.id = 0 --区域id
	self.friendUids = {} --已同意请求的 好友id
end

--
-- LadyBugInfoRef ---------------------------------------------------------
--
LadyBugInfoRef = class(DataRef) --瓢虫任务-子任务具体内容
function LadyBugInfoRef:ctor()
	self.id = 0 --任务id
	self.startTime = 0 --任务开始时间，毫秒数
	self.reward = 0 --奖励是否领取 0：未领取，1：已领取
	self.canReward = 0 --是否可以领取奖励
	self.endTime	= 0	-- Task End Time In Unix Time, Unit Is Millisecond
end

function LadyBugInfoRef:debugPrint()

	if _G.isLocalDevelopMode then printx(0, "LadyBugInfoRef:debugPrint Called !") end
	if _G.isLocalDevelopMode then printx(0, "id: " 		.. self.id) end
	if _G.isLocalDevelopMode then printx(0, "startTime: " 	.. self.startTime) end
	if _G.isLocalDevelopMode then printx(0, "reward: " 	.. tostring(self.reward)) end
	if _G.isLocalDevelopMode then printx(0, "canReward: " 	.. tostring(self.canReward)) end
end

--
-- BagRef ---------------------------------------------------------
--
GoodsInfoRef = class(DataRef)
function GoodsInfoRef:ctor()
	self.goodsId = 0
	self.num = 0
end

--
-- BagRef ---------------------------------------------------------
--
BagRef = class(DataRef) --背包
function BagRef:ctor()
	self.uid = 0 --uid
	self.friendSize = 0 --好友方式开启的个数
	self.buyCount = 0 --Q点购买的次数
end

--
-- MarkRef ---------------------------------------------------------
--
MarkRef = class(DataRef) --签到信息
function MarkRef:ctor( )
	self.uid = 0 --用户id
	self.addNum = 0 --已补签次数
	self.markNum = 0 --签到次数
	self.markTime = 0 --上次签到时间
	self.createTime = 0 --用户创建当天的零点
end

--
-- DailyDataRef ---------------------------------------------------------
--
DailyDataRef = class(DataRef) --用户每日数据(每日重置)
function DailyDataRef:ctor( )
	self.sendGiftCount = 0 --当天已发送礼物数
	self.receiveGiftCount = 0 --当天已接收礼物数
	self.wantIds = {} --当天发送过索要的好友id列表
	self.unLockLevelAreaRequestCount = 0 --当天区域解锁已发送请求次数
	self.inviteFriend = false --当天是否已邀请过好友（通过分组邀请面板）
	self.mark = false --今天是否签到
	self.energyRequestCount = 0 --用户当天已索要精力次数
	self.qqVipDailyReward = false --黄钻、蓝钻每日普通奖励是否领取
	self.qqGameVipYearDailyReward = false --蓝钻年费每日奖励是否领取
	self.qqGameVipSuperDailyReward = false --蓝钻超级每日奖励是否领取
	self.pickFruitCount = 0 --当天已采摘金银果实数目
	self.buyedGoodsInfo = {} --当日已购买商品详情
	self.levelBuyedGoodsInfo = {} --当日在关卡中已购买商品详情 关卡id为索引
	self.diggerCount = 0 --挖宝大赛当天已挖宝次数
	self.sendIds = {}
	self.videoAdRewardLeft = 0  ---每日观看广告视频剩余次数
	self.videoAdReward = {}     --- 观看广告视频奖励
	self.videoAdCycle = {}      ---不同视频广告的循环规则

	self.wxPayRmb = 0
	self.wxPayCount = 0
	
	self.showOffRewardFlag = false
end
function DailyDataRef:resetAll()
	self.sendGiftCount = 0
	self.receiveGiftCount = 0
	self.wantIds = {}
	self.unLockLevelAreaRequestCount = 0
	self.inviteFriend = false
	self.mark = false
	self.energyRequestCount = 0
	self.qqVipDailyReward = false
	self.qqGameVipYearDailyReward = false
	self.qqGameVipSuperDailyReward = false
	self.pickFruitCount = 0
	self.buyedGoodsInfo = {}
	self.levelBuyedGoodsInfo = {} 
	self.diggerCount = 0
	self.sendIds = {}
	self.videoAdRewardLeft = 0 
	self.videoAdReward = {}
	self.videoAdCycle = {}

	self.wxPayRmb = 0
	self.wxPayCount = 0

	self.showOffRewardFlag = false
end
function DailyDataRef:fromLua( src )
	if not src then
		if _G.isLocalDevelopMode then printx(0, "  [WARNING] lua data is nil at DailyDataRef:fromLua") end
		return
	end

	self.buyedGoodsInfo = {}
	self.levelBuyedGoodsInfo = {} 

	for k,v in pairs(src) do
		if k == "buyedGoodsInfo" then
			if src.buyedGoodsInfo then
				for ib,vb in ipairs(src.buyedGoodsInfo) do
					local p = GoodsInfoRef.new()
					p:fromLua(vb)
					self.buyedGoodsInfo[ib] = p
				end
			end
		elseif k == "levelBuyedGoodsInfo" then
			if src.levelBuyedGoodsInfo then
				for kb,vb in ipairs(src.levelBuyedGoodsInfo) do
					local levelId = vb.levelId
					local goodsInfoTab = vb.goodsInfo
					if levelId and goodsInfoTab then 
						self.levelBuyedGoodsInfo[levelId] = {}
						for m,n in ipairs(goodsInfoTab) do
							local p = GoodsInfoRef.new()
							p:fromLua(n)
							table.insert(self.levelBuyedGoodsInfo[levelId], p)
						end
					end
				end
			end
		else 
			if type(v) ~= "function" then self[k] = v end
			if debugDataRef then if _G.isLocalDevelopMode then printx(0, k, v) end end
		end
	end
end
function DailyDataRef:encode()
	local dst = {}
	for k,v in pairs(self) do
		-- if k == "buyedGoodsInfo" then
		-- 	local buyedGoodsInfoEncoded = {}
		-- 	for idx,bvx in ipairs(self.buyedGoodsInfo) do
		-- 		buyedGoodsInfoEncoded[idx] = bvx:encode()
		-- 	end
		-- 	dst["buyedGoodsInfo"] = buyedGoodsInfoEncoded
		-- else
			if k ~="class" and v ~= nil and type(v) ~= "function" then dst[k] = v end
		-- end
	end
	return dst
end

function DailyDataRef:addBuyedGoods(iGoodsId, iNum)
	for __, v in ipairs(self.buyedGoodsInfo) do
		if v.goodsId == iGoodsId then
			v.num = v.num + iNum
			return
		end
	end
	table.insert(self.buyedGoodsInfo, {goodsId = iGoodsId, num = iNum})
end

function DailyDataRef:getBuyedGoodsById(goodsId)
	for __, v in ipairs(self.buyedGoodsInfo) do
		if v.goodsId == goodsId then return v.num end
	end
	return 0
end

function DailyDataRef:setBuyedGoodsByLevel(levelId, iGoodsId, iNum)
	for k,v in pairs(self.levelBuyedGoodsInfo) do
		if k == levelId then 
			for m,n in ipairs(v) do
				if n.goodsId == iGoodsId then 
					n.num = n.num + iNum
					return 
				end
			end
			table.insert(v, {goodsId = iGoodsId, num = iNum})
			return
		end
	end
	
	self.levelBuyedGoodsInfo[levelId] = {}
	table.insert(self.levelBuyedGoodsInfo[levelId], {goodsId = iGoodsId, num = iNum})
end

function DailyDataRef:getBuyedGoodsByLevel(levelId, goodsId)
	for k,v in pairs(self.levelBuyedGoodsInfo) do
		if k == levelId then 
			for m,n in ipairs(v) do
				if n.goodsId == goodsId then 
					return n.num
				end
			end
		end
	end
	return 0
end

function DailyDataRef:getWantIds()
	return self.wantIds
end

function DailyDataRef:addWantIds(ids)
	local function addWandId(id)
		for k, v in ipairs(self.wantIds) do
			if tonumber(v) == id then return end
		end
		table.insert(self.wantIds, id)
	end
	for k, v in ipairs(ids) do
		addWandId(v)
	end
end

function DailyDataRef:getSendGiftCount()
	if self.sendIds and type(self.sendIds) == 'table' then
		return #self.sendIds
	else 
		return 0 
	end
	-- return self.sendGiftCount
end

function DailyDataRef:incSendGiftCount()
	-- self.sendGiftCount = self.sendGiftCount + 1
end


function DailyDataRef:getReceiveGiftCount()
	return self.receiveGiftCount
end

function DailyDataRef:incReceiveGiftCount()
	self.receiveGiftCount = self.receiveGiftCount + 1
end

function DailyDataRef:decReceiveGiftCount()
	self.receiveGiftCount = self.receiveGiftCount - 1
end


function DailyDataRef:getSendIds()
	return self.sendIds
end

function DailyDataRef:addSendId(sendId)
	if self.sendIds and type(self.sendIds) == 'table' then
		table.insert(self.sendIds, sendId)
	end
end

function DailyDataRef:removeSendId(sendId)
	if self.sendIds and type(self.sendIds) == 'table' then 
		for i, v in pairs(self.sendIds) do 
			if v == sendId then
				table.remove(self.sendIds, i)
				return 
			end
		end
	end
end

function DailyDataRef:setWxPayRmb(v)
	if v == nil then v = 0 end
	v = tonumber(v)
	self.wxPayRmb = v
end

function DailyDataRef:getWxPayRmb()
	return self.wxPayRmb or 0
end

function DailyDataRef:setWxPayCount(v)
	if v == nil then v = 0 end
	v = tonumber(v)
	self.wxPayCount = v
end

function DailyDataRef:getWxPayCount()
	return self.wxPayCount or 0
end

---------------------------------------------------
-------------- LeaveArea
---------------------------------------------------

he_log_warning("used in code ?")
-- assert(not LeaveArea)
LeaveArea = class()

function LeaveArea:init(levelAreaId, ...)
	assert(type(levelAreaId) == "number")
	assert(#{...} == 0)

	self.levelAreaId = levelAreaId
	
end

function LeaveArea:create(levelAreaId, ...)
	assert(#{...} == 0)

	local newLeaveArea = LeaveArea.new()
	newLeaveArea:init(levelAreaId)
	return newLeaveArea
end


---------------------------------------------------
-------------- UnlockFriendInfo
---------------------------------------------------

UnlockFriendInfo = class(DataRef)

function UnLockFriendInfoRef:ctor(...)
	assert(#{...} == 0)
	
	self.id	= 0			-- Locked Area Id
	self.friendUids = {}
end

--
-- LevelDataInfo ---------------------------------------------------------
--
local kMaxComboStoreTime = 24 * 60 * 60
LevelDataInfo = class(DataRef)
function LevelDataInfo:ctor()
	self.maxConbo = 0
	self.comboStartTime = os.time()
	self.levels = {}
end
function LevelDataInfo:getLevelInfo( levelId )
	local key = tostring(levelId)
	local level = self.levels[key]
	if level == nil then
		local now = os.time()
		level = {playTimes = 0, win = 0, failTimes = 0, quitTimes = 0, lastUpdateTime = now, createTime = now}
		self.levels[key] = level
	end
	return level
end
--只保留24小时之内的数据
function LevelDataInfo:clearData(now)
	local removeT = {}
	for key,v in pairs(self.levels) do
		local id = tonumber(key)
		if now - v.lastUpdateTime > kMaxComboStoreTime then
			table.insert(removeT, key)
			if LevelType:isMainLevel( id ) then
				self.maxConbo = self.maxConbo - 1
			end
		end
	end

	for _,key in ipairs(removeT) do
		self.levels[key] = nil
	end
end

function LevelDataInfo:onLevelWin( levelId, score )
	local isNeedUpdateCombo = true

	if not LevelType:isMainLevel( levelId ) then
		isNeedUpdateCombo = false
	end
	
	local preScore = UserManager:getInstance():getOldUserScore(levelId)

	if preScore and preScore.star > 0 then
	 	isNeedUpdateCombo = false
	end

	local now = os.time()

	self:clearData(now)

	if self.maxConbo == nil or self.maxConbo < 0 then
		self.maxConbo = 0
	end

	local level = self:getLevelInfo(levelId)
	local winBefore = level.win
	
	if winBefore == 0 and isNeedUpdateCombo then
		if self.maxConbo == 0 then self.comboStartTime = now end
		self.maxConbo = self.maxConbo + 1
	end

	level.win = 1
	level.playTimes = level.playTimes + 1
	level.lastUpdateTime = now
end

function LevelDataInfo:onLevelFail( levelId, score )
	local now = os.time()
	self:clearData(now)
	local level = self:getLevelInfo(levelId)
	level.lastUpdateTime = now
	level.playTimes = level.playTimes + 1
	level.failTimes = level.failTimes + 1
end

function LevelDataInfo:onQuitLevel( levelId )
	local now = os.time()
	self:clearData(now)
	local level = self:getLevelInfo(levelId)
	level.lastUpdateTime = now
	level.playTimes = level.playTimes + 1
	level.quitTimes = (level.quitTimes or 0) + 1
end

--
-- HttpDataInfo ---------------------------------------------------------
--
HttpDataInfo = class(DataRef)
function HttpDataInfo:ctor()
	self.list = {}
end
local function updateHttpDataID( data )
	if data and data.endpoint and not data.id then
		data.id = uuid:getUUID()
		-- data.body.__id = data.id
	end
end
function HttpDataInfo:add( endpoint, body )
	local data = {endpoint=endpoint, body=body}
	self.list = self.list or {}
	table.insert(self.list, data)
	updateHttpDataID(data)
end
function HttpDataInfo:fromLua( src )
	if not src then return end
	self.list = src
	for i,v in ipairs(self.list) do updateHttpDataID(v) end
end

function HttpDataInfo:encode()
	return self.list
end
function HttpDataInfo:decode(src)
	self:fromLua(src)
end

DigJewelCount = class(DataRef)

function DigJewelCount:ctor()
	self:setValue(0)
end
function DigJewelCount:setValue(value)
	local key = "DigJewelCount.digJewelCount"..tostring(self)
	self.digJewelCount = value
	encrypt_integer(key, value)
end
function DigJewelCount:getValue()
	local key = "DigJewelCount.digJewelCount"..tostring(self)
	return decrypt_integer(key)
end

RabbitCount = class(DataRef)

function RabbitCount:ctor()
	self:setValue(0)
end
function RabbitCount:setValue(value)
	local key = "RabbitCount.rabbitCount"..tostring(self)
	self.rabbitCount = value
	encrypt_integer(key, value)
end
function RabbitCount:getValue()
	local key = "RabbitCount.rabbitCount"..tostring(self)
	return decrypt_integer(key)
end

YellowDiamondCount = class(DataRef)
function YellowDiamondCount:ctor()
	self:setValue(0)
end
function YellowDiamondCount:setValue(value)
	local key = "YellowDiamondCount.yellowDiamondCount"..tostring(self)
	self.yellowDiamondCount = value
	encrypt_integer(key, value)
end
function YellowDiamondCount:getValue()
	local key = "YellowDiamondCount.yellowDiamondCount"..tostring(self)
	return decrypt_integer(key)
end

AchievementRef = class(DataRef)

function AchievementRef:ctor()
	self.achievements = {}
	self.points = 0
	self.pctOfRank = 0
	self.uid = 0
	self.starGlobalRank = 0 --全服星星数排名
	self.spentCoins = 0 --花费的银币数
	self.pickedFruits = 0 --采摘的果实数
	self.weekMatch = {} --周赛次数
	self.effectiveAchievements = {}
	self.newAchi = false
end

function AchievementRef:fromLua( src )
	if not src then
		if _G.isLocalDevelopMode then printx(0, "  [WARNING] lua data is nil at AchievementRef:fromLua") end
		return
	end
	if src.achievements then
		self.achievements = table.clone(src.achievements)
	else
		self.achievements = {}
	end
	
	self.points = src.points or 0
	self.pctOfRank = src.pctOfRank or 0
	self.uid = src.uid or 0
	self.starGlobalRank = src.starGlobalRank or 0
	self.spentCoins = src.spentCoins or 0 --花费的银币数
	self.pickedFruits = src.pickedFruits or 0 --采摘的果实数

	if src.weekMatch then
		self.weekMatch = table.clone(src.weekMatch)
	else
		self.weekMatch = {}
	end

	if src.effectiveAchievements then
		self.effectiveAchievements = table.clone(src.effectiveAchievements)
	else
		self.effectiveAchievements = {}
	end

	self.newAchi = src.newAchi
end

function AchievementRef:encode()
	local dst = {}
	dst.achievements = self.achievements
	dst.weekMatch = self.weekMatch
	dst.points = self.points
	dst.pctOfRank = self.pctOfRank
	dst.uid = self.uid
	dst.starGlobalRank = self.starGlobalRank
	dst.pickedFruits = self.pickedFruits
	dst.spentCoins = self.spentCoins
	dst.effectiveAchievements = self.effectiveAchievements

	return dst
end

function AchievementRef:decode(src)
	self:fromLua(src)
end


NewLadyBugInfoRef = class(DataRef)

function NewLadyBugInfoRef:ctor()
	self.id = -1
	self.lastRewardTime = 0
	self.lastFinishTime = 0
	self.reward = 0
	self.canReward = false
	self.finishTime = 0
	self.extra = ''

	self.finishTimes = {}

	self.indexFrom1 = false
end

function NewLadyBugInfoRef:fromLua( src )

	local function ifNil( value, defaultValue )
		if value == nil then
			return defaultValue
		else
			return value
		end
	end

	if not src then
		if _G.isLocalDevelopMode then printx(0, "  [WARNING] lua data is nil at NewLadyBugInfoRef:fromLua") end
		return
	end

	self.indexFrom1 = ifNil(src.indexFrom1, false)

	self.id = src.id or -1
	self.lastRewardTime = src.lastRewardTime or 0
	self.lastFinishTime = src.lastFinishTime or 0
	self.reward = src.reward or 0
	self.canReward = ifNil(src.canReward, false)
	self.finishTime = src.finishTime or 0
	self.extra = src.extra or ''

	self.finishTimes = src.finishTimes or {}
	
	if tostring(self.lastRewardTime) == tostring(0) then
		self.lastRewardTime = self.lastFinishTime
	end

	if not self.indexFrom1 then
		self.indexFrom1 = true
		self.id = self.id + 1
	end

end

function NewLadyBugInfoRef:encode()
	local dst = {}
	dst.id = self.id
	dst.lastRewardTime = self.lastRewardTime
	dst.lastFinishTime = self.lastFinishTime
	dst.reward = self.reward
	dst.canReward = self.canReward
	dst.finishTime = self.finishTime
	dst.extra = self.extra
	dst.finishTimes = self.finishTimes
	dst.indexFrom1 = self.indexFrom1
	return dst
end

function NewLadyBugInfoRef:decode(src)
	self:fromLua(src)
end

IOSScoreGuideDataRef = class(DataRef)
function IOSScoreGuideDataRef:ctor()
	self.year = 0
	self.lastGuideVer = 0	-- 上次评分引导版本号
	self.lastGuideType = 0 -- 上次引导类型
	self.inAppReview = 0	-- 应用内评分次数
	self.guideReview = 0	-- 引导去评分次数
end

function IOSScoreGuideDataRef:fromLua( src )
	self.year = src.year
	self.lastGuideVer = src.lastGuideVer
	self.lastGuideType = src.lastGuideType
	self.inAppReview = src.inAppReview
	self.guideReview = src.guideReview
end

function IOSScoreGuideDataRef:resetViewData()
	self.inAppReview = 0
	self.guideReview = 0
end

-- {"counter":{},"lastType":1,"lastVer":"1.48.3850","year":2017}
function IOSScoreGuideDataRef:fromServer( dataStr )
	local guideReview = table.deserialize(dataStr)
	if guideReview then
		self.lastGuideVer = tonumber(string.split(guideReview.lastVer or "", ".")[2]) or 0
		self.lastGuideType = guideReview.lastType
		self.year = guideReview.year
		if type(guideReview.counter) == "table" then
			for k, v in pairs(guideReview.counter) do
				if tonumber(k) == 1 then
					self.inAppReview = tonumber(v)
				elseif tonumber(k) == 2 then
					self.guideReview = tonumber(v)
				end 
			end
		end
	end
end

PropGuideInfoRef = class(DataRef)
function PropGuideInfoRef:ctor()
	self.lastMatchDay = 0
	self.lastStrongGuideItems = {}
	self.lastMainLevelIdByItem = {}
	self.lastMatchDayByItem = {}
	self.lastMainLevelId = 0
	self.lastHideLevelId = 0
	self.lastHideLevelIdByItem = {}
	self.strongGuideNumByItem = {}
	self.lastExtraLevelIdByItem = {}
end
function PropGuideInfoRef:dispose()
end
function PropGuideInfoRef:fromLua( src )
	if not src then
		if _G.isLocalDevelopMode then printx(0, "  [WARNING] lua data is nil") end
		return
	end

	for k,v in pairs(src) do
		if type(v) ~= "function" then 
			self[k] = v 
			hasData = true
		end
		if debugDataRef then if _G.isLocalDevelopMode then printx(0, k, v) end end
	end

end

function PropGuideInfoRef:encode()
	local dst = {}
	for k,v in pairs(self) do
		if k ~="class" and v ~= nil and type(v) ~= "function" then dst[k] = v end
	end
	return dst
end
function PropGuideInfoRef:decode(src)
	self:fromLua(src)
end

HelpedInfoRef = class(DataRef)
function HelpedInfoRef:ctor()
	self.uid = '12345'
	self.profile = {}
	self.failCount = 0
	self.levelId = 1
	self.day = 0
	self.success = false
end

function HelpedInfoRef:fromLua( src )
	self.uid = src.uid or '12345'
	self.profile = src.profile or {}
	self.failCount = src.failCount or 0
	self.levelId = src.levelId or 1
	self.day = src.day or 0
	self.success = src.success or false
end

function HelpedInfoRef:encode()
	local dst = {}
	dst.uid = self.uid
	dst.profile = self.profile
	dst.failCount = self.failCount
	dst.levelId = self.levelId
	dst.day = self.day
	dst.success = self.success
	return dst
end

function HelpedInfoRef:decode(src)
	self:fromLua(src)
end

NotifiItemRef = class(DataRef)
function NotifiItemRef:ctor()
	self.first = 0
	self.second = 0
end

function NotifiItemRef:fromLua( src )
	self.first = src.first or 0
	self.second = src.second or 0
end

function NotifiItemRef:encode()
	local dst = {}
	dst.first = self.first
	dst.second = self.second
	return dst
end

function NotifiItemRef:decode(src)
	self:fromLua(src)
end

AreaTaskRef = class(DataRef)

function AreaTaskRef:ctor( ... )
	self:fromLua({
		-- maxTriggeredAreaId = 0x7FFFFFFF,
		coolDownBeginTime = 0,
		areaTasks = {}
	})
end

function AreaTaskRef:encode( ... )
	local dst = {}
	self:copy(dst, self)
	return dst
end

function AreaTaskRef:decode( src )
	self:fromLua(src)
end

function AreaTaskRef:fromLua( src )
	self:copy(self, src)
end

function AreaTaskRef:copy( to, from )
	from = from or {}
	-- to.maxTriggeredAreaId = from.maxTriggeredAreaId or 0x7FFFFFFF
	to.coolDownBeginTime = from.coolDownBeginTime or 0
	to.areaTasks = {}
	for _, v in ipairs(from.areaTasks or {}) do
		table.insert(to.areaTasks, {
			endTime = tonumber(v.endTime) or 0,
			levelId = tonumber(v.levelId) or 0,
			rewards = table.clone(v.rewards or {}, true) or {},
			index = tonumber(v.index) or 0,
			rewarded = v.rewarded,
			finished = v.finished,
			beginTime = tonumber(v.beginTime) or 0,
		})
	end
end

FullStarRankHistoryRef = class(DataRef)


function FullStarRankHistoryRef:ctor( ... )
	self:fromLua({
		fullStar = 0,
		rank = 0,
		time = 0,
		rewarded = true,
		rewards = {},
	})
end

function FullStarRankHistoryRef:encode( ... )
	local dst = {}
	self:copy(dst, self)
	return dst
end

function FullStarRankHistoryRef:decode( src )
	self:fromLua(src)
end

function FullStarRankHistoryRef:fromLua( src )
	self:copy(self, src)
end

function FullStarRankHistoryRef:copy( to, from )
	from = from or {}
	if to then
		to.fullStar = from.fullStar or 0
		to.rank = from.rank or 0
		to.time = from.time or 0
		to.rewarded = from.rewarded
		to.rewards = table.clone(from.rewards or {}) or {}
	end
end




QuestRecordRef = class(DataRef)


function QuestRecordRef:ctor( ... )
	self:fromLua({})
end

function QuestRecordRef:encode( ... )
	local dst = {}
	self:copy(dst, self)
	return dst
end

function QuestRecordRef:decode( src )
	self:fromLua(src)
end

function QuestRecordRef:fromLua( src )
	self:copy(self, src)
end

function QuestRecordRef:copy( to, from )
	from = from or {}
	if to then
		to.triggerTime = from.triggerTime or 0
		to.rewarded = table.clone(from.rewarded or {}, true)
		to.quests = {}
		for groupId, groupData in pairs(from.quests or {}) do
			to.quests[tonumber(groupId)] = {}
			for _, questData in ipairs(groupData) do
				table.insert(to.quests[tonumber(groupId)], {
					id = tonumber(questData.id),
					relTarget = tonumber(questData.relTarget),
					num = tonumber(questData.num),
					_type = tostring(questData._type),
					data = table.clone(questData.data or {}, true)
				})
			end
		end
	end
end