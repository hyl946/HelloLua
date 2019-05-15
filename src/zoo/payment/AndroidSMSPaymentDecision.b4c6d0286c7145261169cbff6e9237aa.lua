local function func()
local smsBanConfig =[[{
	"cmmmBanList": {
		"测试": {},
		"四川": {},
		"贵州": {},
		"云南": {},
		"湖南": {},
		"北京": {}
	},
	"cmgameBanList": {
		"辽宁": {},
		"河南": {},
		"贵州": {},
		"云南": {},
		"安徽": {},
		"广东": {},
		"山东": {}
	},
	"cuBanList": {
		"江苏": {},
		"广西": {}
	},
	"ctBanList": {
		"河北": {},
		"河南": {},
		"山西": {},
		"江西": {},
		"云南": {},
		"甘肃": {},
		"辽宁": {},
		"广西": {},
		"宁夏": {},
		"广东": {},
		"重庆": {},
		"吉林": {},
		"江苏": {}
	},
	"umBanList": {
		"江西": {},
		"上海": {},
		"河北": {},
		"海南": {},
		"安徽": {},
		"重庆": {},
		"河南": {},
		"内蒙古": {},
		"天津": {},
		"宁夏": {},
		"西藏": {},
		"新疆": {},
		"青海": {},
		"广东": {},
		"广西": {},
		"贵州": {},
		"陕西": {},
		"山西": {},
		"吉林": {},
		"湖南": {},
		"山东": {},
		"浙江": {},
		"云南": {},
		"湖北": {},
		"甘肃": {},
		"辽宁": {},
		"福建": {}
	}
}]]
 local cmmmOptimalConfig=[[{
	"湖北": {
		"default": {
			"thirdPart": 0,
			"cmmm": 100,
			"useMobileNoNet": false
		}
	},
	"北京": {
		"default": {
			"thirdPart": 0,
			"cmmm": 100,
			"useMobileNoNet": false
		}
	},
	"重庆": {
		"default": {
			"thirdPart": 0,
			"cmmm": 100,
			"useMobileNoNet": false
		}
	},
	"福建": {
		"default": {
			"thirdPart": 0,
			"cmmm": 100,
			"useMobileNoNet": false
		}
	},
	"广东": {
		"default": {
			"thirdPart": 0,
			"cmmm": 100,
			"useMobileNoNet": false
		}
	},
	"广西": {
		"default": {
			"thirdPart": 0,
			"cmmm": 100,
			"useMobileNoNet": false
		}
	},
	"贵州": {
		"default": {
			"thirdPart": 0,
			"cmmm": 100,
			"useMobileNoNet": false
		}
	},
	"海南": {
		"default": {
			"thirdPart": 0,
			"cmmm": 100,
			"useMobileNoNet": false
		}
	},
	"河北": {
		"default": {
			"thirdPart": 0,
			"cmmm": 100,
			"useMobileNoNet": false
		}
	},
	"河南": {
		"default": {
			"thirdPart": 0,
			"cmmm": 100,
			"useMobileNoNet": false
		}
	},
	"江苏": {
		"default": {
			"thirdPart": 0,
			"cmmm": 100,
			"useMobileNoNet": false
		}
	},
	"辽宁": {
		"default": {
			"thirdPart": 0,
			"cmmm": 100,
			"useMobileNoNet": false
		}
	},
	"内蒙古": {
		"default": {
			"thirdPart": 0,
			"cmmm": 100,
			"useMobileNoNet": false
		}
	},
	"青海": {
		"default": {
			"thirdPart": 0,
			"cmmm": 100,
			"useMobileNoNet": false
		}
	},
	"山东": {
		"default": {
			"thirdPart": 0,
			"cmmm": 100,
			"useMobileNoNet": false
		}
	},
	"上海": {
		"default": {
			"thirdPart": 0,
			"cmmm": 100,
			"useMobileNoNet": false
		}
	},
	"天津": {
		"default": {
			"thirdPart": 0,
			"cmmm": 100,
			"useMobileNoNet": false
		}
	},
	"西藏": {
		"default": {
			"thirdPart": 0,
			"cmmm": 100,
			"useMobileNoNet": false
		}
	},
	"浙江": {
		"default": {
			"thirdPart": 0,
			"cmmm": 100,
			"useMobileNoNet": false
		}
	},
	"测试": {
		"default": {
			"thirdPart": 0,
			"cmmm": 100,
			"useMobileNoNet": false
		}
	},
	"湖南": {
		"default": {
			"thirdPart": 0,
			"cmmm": 100,
			"useMobileNoNet": false
		}
	},
	"黑龙江": {
		"default": {
			"thirdPart": 0,
			"cmmm": 100,
			"useMobileNoNet": false
		}
	},
	"宁夏": {
		"default": {
			"thirdPart": 0,
			"cmmm": 100,
			"useMobileNoNet": false
		}
	},
	"山西": {
		"default": {
			"thirdPart": 0,
			"cmmm": 100,
			"useMobileNoNet": false
		}
	},
	"四川": {
		"default": {
			"thirdPart": 0,
			"cmmm": 100,
			"useMobileNoNet": false
		}
	},
	"安徽": {
		"default": {
			"thirdPart": 0,
			"cmmm": 100,
			"useMobileNoNet": false
		}
	},
	"甘肃": {
		"default": {
			"thirdPart": 0,
			"cmmm": 100,
			"useMobileNoNet": false
		}
	},
	"云南": {
		"default": {
			"thirdPart": 0,
			"cmmm": 100,
			"useMobileNoNet": false
		}
	},
	"吉林": {
		"default": {
			"thirdPart": 0,
			"cmmm": 100,
			"useMobileNoNet": false
		}
	},
	"江西": {
		"default": {
			"thirdPart": 0,
			"cmmm": 100,
			"useMobileNoNet": false
		}
	},
	"新疆": {
		"default": {
			"thirdPart": 0,
			"cmmm": 100,
			"useMobileNoNet": false
		}
	},
	"陕西": {
		"default": {
			"thirdPart": 0,
			"cmmm": 100,
			"useMobileNoNet": false
		}
	}
}]]
local kBanConfig = type(smsBanConfig) == "string" and table.deserialize(smsBanConfig) or {}
	-- 移动MM支付优先的省份,{...}中指定的平台基地优先
	local cmOptimalList = type(cmmmOptimalConfig) == "string" and table.deserialize(cmmmOptimalConfig) or {}

	local function getRemainder(baseNum)
	  local udid = MetaInfo:getInstance():getUdid()
	  if udid then
	    local subStr = string.sub(udid, -5)
	    if subStr then
	      local numUid = tonumber(subStr, 16) or 0
	      return numUid % baseNum
	    end
	  end
	  return 0
	end

	local udidRemainder = getRemainder(100)

	local function checkSupportThirdParty()
	  local isSupportThirdParty = false 
	  local thirdPartyPayment = PlatformConfig.paymentConfig.thirdPartyPayment
	  if type(thirdPartyPayment) == "table" then
	    if #thirdPartyPayment > 1 then
	      isSupportThirdParty = true
	    elseif #thirdPartyPayment == 1 then
	      if not table.includes(thirdPartyPayment, Payments.UNSUPPORT) then
	        isSupportThirdParty = true
	      end
	    end
	  elseif type(thirdPartyPayment) == "string" then
	    if thirdPartyPayment ~= Payments.UNSUPPORT then
	      isSupportThirdParty = true
	    end
	  end
	  return isSupportThirdParty
	end

	local function checkInRange(rangeStr)
		if type(rangeStr) == "string" then
			local numbers = string.split(rangeStr, '-')
			local startNum = tonumber(numbers[1]) or 0
			local endNum = tonumber(numbers[2]) or 100
			if udidRemainder < startNum or udidRemainder > endNum then
				return false
			end 
		end
		return true
	end

	local function getBanProvinceListByPlatform(banConfig, platform)
		local result = {}
		if banConfig then
			for p, cfg in pairs(banConfig) do
				table.insert(result, p)
				-- if cfg[platform] or cfg['default'] then
				-- 	table.insert(result, p)
				-- end
			end
		end
		return result
	end

	local function isProvinceInBanList(banProvinceList, province)
		if banProvinceList and #banProvinceList > 0 then
			-- if table.includes(banProvinceList, "全部") then return true end
			if table.includes(banProvinceList, province) then
				return true
			end
		end
		return false
	end

	local function getOptimalConfig(optimalList, province, platform)
		if not province or not platform then return nil end
			
		if type(optimalList) == "table" then
			local defaultCfg = nil
			for p, cfg in pairs(optimalList) do
				if p == province then
					if type(cfg) == "table" then
						local matchPlatform = platform
						local optimalCfg = cfg[platform]
						if not optimalCfg then
							matchPlatform = 'default'
							optimalCfg = cfg['default']
						end
						if type(optimalCfg) == "table" then
							return optimalCfg, matchPlatform
						end
					end
					return nil
				end
			end
		end
		return nil
	end

	local function getCMOptimalResultA(cmList, optimalCfg)
		local thirdPartPercent = 0
		if type(optimalCfg) == "table" and checkSupportThirdParty() then -- 短代切换至第三方的比例
			thirdPartPercent = tonumber(optimalCfg.thirdPart) or 0
		end
		if udidRemainder < thirdPartPercent then -- 第三方支付优先
			return {}
		end

		local result = cmList
		if table.indexOf(cmList, Payments.CHINA_MOBILE) and table.indexOf(cmList, Payments.CHINA_MOBILE_GAME) then
			result = {Payments.CHINA_MOBILE_GAME, Payments.CHINA_MOBILE}
			if type(optimalCfg) == "table" then
				local cmmmPercent = tonumber(optimalCfg.cmmm) or 0
				-- local cmgamePercent = tonumber(optimalCfg.cmgame) or 0 剩下都算基地的
				local cmmmRemainderStart = thirdPartPercent
				local cmmmRemainderEnd = thirdPartPercent + (100 - thirdPartPercent) * cmmmPercent / 100

				if udidRemainder >= cmmmRemainderStart and udidRemainder < cmmmRemainderEnd then -- MM优先
					result = {Payments.CHINA_MOBILE, Payments.CHINA_MOBILE_GAME}
				else  -- 基地优先
					result = {Payments.CHINA_MOBILE_GAME, Payments.CHINA_MOBILE}
				end
			end
		end
		return result
	end

	local function getCMOptimalResultB(cmList, optimalCfg)
		local result = cmList
		local thirdPartPercent = 0
		if checkSupportThirdParty() then -- 短代切换至第三方的比例
			thirdPartPercent = tonumber(optimalCfg.thirdPart) or 0
		end
		local cmmmPercent = tonumber(optimalCfg.cmmm) or 0
		local cmgamePercent = 100 - cmmmPercent
		if table.indexOf(cmList, Payments.CHINA_MOBILE) and table.indexOf(cmList, Payments.CHINA_MOBILE_GAME) then
			result = {Payments.CHINA_MOBILE_GAME, Payments.CHINA_MOBILE}
			if udidRemainder >= 0 and udidRemainder < cmmmPercent then -- MM优先
				result = {Payments.CHINA_MOBILE, Payments.CHINA_MOBILE_GAME}
			else  -- 基地优先
				result = {Payments.CHINA_MOBILE_GAME, Payments.CHINA_MOBILE}
			end
			local oType = nil
			if thirdPartPercent > 0 then
				-- CMMM优先中强制三方部分
				if udidRemainder < cmmmPercent then
					if udidRemainder < (0 + math.floor(cmmmPercent * thirdPartPercent / 100)) then
						oType = CMOptimalType.kThirdPart_CMMM
					end
				end
				-- CMGame优先中强制三方部分
				if udidRemainder >= cmmmPercent then
					if udidRemainder < (cmmmPercent + math.floor(cmgamePercent * thirdPartPercent / 100)) then
						oType = CMOptimalType.kThirdPart_CMGame
					end
				end
			end
			if not oType then
				if result[1] == Payments.CHINA_MOBILE then
					oType = CMOptimalType.kCMMM
				else
					oType = CMOptimalType.kCMGame
				end
			end
			AndroidPayment:getInstance():setCMOptimalType(oType)
		else
			local oType = nil
			if thirdPartPercent > 0 and udidRemainder < thirdPartPercent then
				if table.indexOf(cmList, Payments.CHINA_MOBILE) then
					oType = CMOptimalType.kThirdPart_CMMM
				elseif table.indexOf(cmList, Payments.CHINA_MOBILE_GAME) then
					oType = CMOptimalType.kThirdPart_CMGame
				end
			end
			if not oType then
				if table.indexOf(cmList, Payments.CHINA_MOBILE) then
					oType = CMOptimalType.kCMMM
				elseif table.indexOf(cmList, Payments.CHINA_MOBILE_GAME) then
					oType = CMOptimalType.kCMGame
				end
			end
			AndroidPayment:getInstance():setCMOptimalType(oType)
		end
		return result
	end

	local function getCMOptimalResult(cmList, optimalCfg)
		if type(cmList) ~= "table" or table.size(cmList) == 0 then return {} end
		if type(optimalCfg) == "table" and optimalCfg.useMobileNoNet and CMOptimalType then
			return getCMOptimalResultB(cmList, optimalCfg)
		else
			return getCMOptimalResultA(cmList, optimalCfg)
		end
	end

    local function isForbidChinaMobileGame(osVersion, numVersion, platformName)
		-- android5.0系统以下不使用基地计费，he平台5.0以下开启测试
		if osVersion < 4.0 then
			return true
		end
		-- 1.43-1.44基地计费全部关停26005,1.42 升级到26005的平台关停基地计费
		if numVersion < 39 or numVersion == 43 or numVersion == 44 
				or (numVersion == 42 and (platformName == "he" or platformName=="4399")) 
				then
			return true
		end
		-- 1.43 jinli_pre基地是测试计费文件，关停之 / 改为jinli和jinli_pre全部关停
		if (platformName == "jinli_pre" or platformName == "jinli" or platformName == "haixin") then
			return true
		end
		local deviceType = MetaInfo:getInstance():getMachineType() or ""
		if string.sub(deviceType,1,8) == "GT-I9500" then
			return true
		end
		return false
	end

	local function smsPaymentDecision(platformName, province, numVersion, smsChangeToThirdParty, banSmsTypes)
		-- 1.36-1.42乐视是自己的微信支付id，避险关停之
		if numVersion >= 36 and numVersion <= 46 and platformName == "leshop" then
			local thirdPartyPayment = PlatformConfig.paymentConfig.thirdPartyPayment
			if type(thirdPartyPayment) == "table" then
				local wxIndex = table.indexOf(thirdPartyPayment, Payments.WECHAT)
				if wxIndex then 
					local payment = PaymentBase:getPayment(Payments.WECHAT)
					payment:setEnabled(false)
					-- table.remove(thirdPartyPayment, wxIndex) 
				end
			end
		end
		-- 1.47及以下豌豆荚支付关停
		if platformName == "wandoujia" then
			if numVersion <= 47 then
				local thirdPartyPayment = PlatformConfig.paymentConfig.thirdPartyPayment
				if type(thirdPartyPayment) == "table" and Payments.WDJ then
					local wdjIndex = table.indexOf(thirdPartyPayment, Payments.WDJ)
					if wdjIndex then 
						local payment = PaymentBase:getPayment(Payments.WDJ)
						payment:setEnabled(false)
						table.remove(thirdPartyPayment, wdjIndex) 
					end
				end
			end
		end
		-- 默认的短代计费方式配置
		local cm = table.clone(PlatformConfig.paymentConfig.chinaMobilePayment)
		-- local cm = table.clone(PlatformConfig:getPaymentConfig(platformName).chinaMobilePayment)
		local cu = {Payments.CHINA_UNICOM}
		local ct = {Payments.CHINA_TELECOM}
		-- 禁掉支付的省份
		local cmmmBanlist = getBanProvinceListByPlatform(kBanConfig.cmmmBanList, platformName)
		local cmgameBanlist = getBanProvinceListByPlatform(kBanConfig.cmgameBanList, platformName)
		local cuBanList = getBanProvinceListByPlatform(kBanConfig.cuBanList, platformName)
		local ctBanList = getBanProvinceListByPlatform(kBanConfig.ctBanList, platformName)
                local umBanList = getBanProvinceListByPlatform(kBanConfig.umBanList, platformName)

		if platformName == "mi" then
		    if numVersion >= 28 and numVersion <= 30 then
		        cmmmBanlist = {"测试","河北", "辽宁", "江苏", "宁夏", "浙江", "河南", "江西", "广西", "上海", "福建", "新疆", "甘肃", "湖南"}
		        cmgameBanlist = {"北京", "上海", "天津", "重庆", "云南", "内蒙古", "吉林", "四川", "宁夏", "安徽", "山东", "山西", "广东", "广西", "新疆", "江苏", "江西", "河北", "河南", "浙江", "海南", "湖北", "湖南", "甘肃", "福建", "西藏", "贵州", "辽宁", "陕西", "青海", "黑龙江"}
		        cuBanList = {}
		        ctBanList = {} 
		    elseif numVersion > 30 and numVersion <= 33 and not __CMGAME then
		        cmgameBanlist = {"北京", "上海", "天津", "重庆", "云南", "内蒙古", "吉林", "四川", "宁夏", "安徽", "山东", "山西", "广东", "广西", "新疆", "江苏", "江西", "河北", "河南", "浙江", "海南", "湖北", "湖南", "甘肃", "福建", "西藏", "贵州", "辽宁", "陕西", "青海", "黑龙江",}
		    end
		end

		local baiduPlatforms = {"91","baiduapp","duoku","tieba","baiduwifi","baidule","baidulemon"}
		if table.exist(baiduPlatforms, platformName) then
		   table.insert(cmgameBanlist, "浙江")
		end

		if province=="江苏" and platformName=="cmgame" then
			cmgameBanlist = {}
		end

		local osVersion = MetaInfo:getInstance():getOsVersion() or ""
		local vs = osVersion:split(".")
		osVersion = tonumber(tostring(vs[1]).."."..tostring(vs[2] or 0)) or 1
		if platformName == "cuccwo" then 
			-- cuccwo三方计费移动支付在Android7.0会导致crash
			if osVersion >= 7.0 and type(AndroidPayment.getOperator) == "function" 
					and AndroidPayment.getInstance():getOperator() == TelecomOperators.CHINA_MOBILE then
				cu = {}
			end
			if PlatformConfig then
				PlatformConfig.paymentConfig.thirdPartyPayment = {}
			end
		end

		-- 更新短代计费方式配置
		if isProvinceInBanList(cuBanList, province) then
		  cu = {}
		end
		cu = {} -- 20181212联通内部督查影响支付效率，关闭联通支付

		if isProvinceInBanList(ctBanList, province) then
		  ct = {}
		end
		-- 短代黑名单处理
		if type(banSmsTypes) == "table" and #banSmsTypes > 0 then
			if table.indexOf(banSmsTypes, Payments.CHINA_MOBILE) then
				table.removeValue(cm, Payments.CHINA_MOBILE)
			end
			if table.indexOf(banSmsTypes, Payments.CHINA_MOBILE_GAME) then
				table.removeValue(cm, Payments.CHINA_MOBILE_GAME)
			end
			if table.indexOf(banSmsTypes, Payments.CHINA_UNICOM) then
				table.removeValue(cu, Payments.CHINA_UNICOM)
			end
			if table.indexOf(banSmsTypes, Payments.CHINA_TELECOM) then
				table.removeValue(ct, Payments.CHINA_TELECOM)
			end
		end

		if platformName == "tf" and DcUtil and DcUtil.getSubPlatform and DcUtil:getSubPlatform() == "Cp" then
		    cm = {}
		    cu = {}
		    ct = {} 
		end

		if platformName == "leshop" then
			ct = {}
		end

		local cmmmIndex = table.indexOf(cm, Payments.CHINA_MOBILE)
		local mmSdkVer = 0
		if cmmmIndex and numVersion > 60 then
			pcall(function()
				local fullSdkVer = luajava.bindClass("com.happyelements.android.operatorpayment.iap.IAPPayment"):getSdkVersion()
				if fullSdkVer then
					local sdkVerCodes = string.split(fullSdkVer, '.')
					for i = 1, 4 do
						local num = sdkVerCodes[i] and tonumber(sdkVerCodes[i]) or 0
						mmSdkVer = mmSdkVer * 100 + num
					end
				end
			end)
		end

		if cmmmIndex and (numVersion <= 36 or (platformName == "huawei" and numVersion == 50) or isProvinceInBanList(cmmmBanlist, province)) then
		  table.remove(cm, cmmmIndex)
		  cmmmIndex = nil
		end

		if cmmmIndex and platformName == "anzhi" then
			table.remove(cm, cmmmIndex)
		  	cmmmIndex = nil
		end

		if cmmmIndex and platformName == "mz" and numVersion < 60 and udidRemainder >= 50 then
			table.remove(cm, cmmmIndex)
		  	cmmmIndex = nil
		end

		if cmmmIndex and platformName == "coolpad" then
			table.remove(cm, cmmmIndex)
		  	cmmmIndex = nil
		end

		if cmmmIndex and numVersion == 56 and platformName == "he" and osVersion>=8.0 then
			table.remove(cm, cmmmIndex)
		  	cmmmIndex = nil
		end

		if cmmmIndex and osVersion >= 8.0 and mmSdkVer < 4000202 then
			table.remove(cm, cmmmIndex)
		  	cmmmIndex = nil
		end

		if cmmmIndex and platformName == "tf" and DcUtil and DcUtil.getSubPlatform and DcUtil:getSubPlatform() == "B8" then
			table.remove(cm, cmmmIndex)
		  	cmmmIndex = nil
		end
		if cmmmIndex and platformName == "mz" and numVersion == 65 then -- mz支付失败，待问题解决后去掉
			table.remove(cm, cmmmIndex)
		  	cmmmIndex = nil
		end

		if numVersion < 52 then
			local deviceType = MetaInfo:getInstance():getMachineType()
			local isFlyme6 =  deviceType and string.starts(deviceType, "MX") and osVersion >= 7.1
			if cmmmIndex and (not (platformName == "mz" and numVersion > 49)) and (isFlyme6 or osVersion>=8.0) then
			  table.remove(cm, cmmmIndex)
			  cmmmIndex = nil
			end
		end

		local cmgameIndex = table.indexOf(cm, Payments.CHINA_MOBILE_GAME)
		if cmgameIndex then -- 26009sdk关停计费，migu计费全部关停
			table.remove(cm, cmgameIndex)
		  	cmgameIndex = nil
		end
		if cmgameIndex and (platformName == "he" or platformName == "tf") then
			table.remove(cm, cmgameIndex)
		  	cmgameIndex = nil
		end
		if cmgameIndex and (isForbidChinaMobileGame(osVersion, numVersion, platformName) or isProvinceInBanList(cmgameBanlist, province)) then
		  table.remove(cm, cmgameIndex)
		  cmgameIndex = nil
		end
		-- 咪咕计费测试
		if cmgameIndex and not (platformName == "mz" or table.exist({"天津","江西","测试"}, province)) then
			table.remove(cm, cmgameIndex)
			cmgameIndex = nil
		end
		if cmgameIndex and platformName == "lenovo" then
			table.remove(cm, cmgameIndex)
			cmgameIndex = nil
		end
		-- 去掉联动优势计费
		local umpayIndex = table.indexOf(cm, Payments.UMPAY)
		if umpayIndex then
		  table.remove(cm, umpayIndex)
		end
		-- 移动计费MM和基地的优先级判断
		local cmOptimalCfg, matchPlatform = getOptimalConfig(cmOptimalList, province, platformName)
		local javaModifyVer = 0
	    	pcall(function()
	    		local MainActivityHolder = luajava.bindClass("com.happyelements.android.MainActivityHolder")
			javaModifyVer = MainActivityHolder.ACTIVITY:getLatestModify()
		end)
		-- 1.52及以上he&tf默认咪咕计费优先
		if cmOptimalCfg and numVersion >= 52 and numVersion < 56
				and (javaModifyVer < 6 and (platformName == "he" or platformName == "tf")) 
				and matchPlatform == "default" 
				and StartupConfig:getInstance().getServer and StartupConfig:getInstance():getServer() ~= "CT" then
			cmOptimalCfg.cmmm = 0
		end
		if cmOptimalCfg and numVersion == 56 
				and matchPlatform == "default"
				and table.exist({"baiduapp","360"}, platformName) then
			cmOptimalCfg.thirdPart = 0
			cmOptimalCfg.cmmm = 0
		end
		cm = getCMOptimalResult(cm, cmOptimalCfg, udidRemainder)

		if "e45b301a20f82c90" == MetaInfo:getInstance():getUdid() then -- 强制基地白名单
                        if AndroidPayment and AndroidPayment.getInstance() then AndroidPayment.getInstance().getOperator = function() return 1 end end
			cm = {Payments.CHINA_MOBILE_GAME}
		end
		-- 关停22版本的一切支付，或者短代切换为三方时关停一切短代支付
		if numVersion == 22 or smsChangeToThirdParty or (osVersion>= 9.0 and numVersion < 59) then
		    cm = {}
		    cu = {}
		    ct = {} 
		end

		if not AndroidPayment.miguTestUdids then
			AndroidPayment.miguTestUdids = {"83a8a078ad1091dd","7546f258d26e15e0","be11545e15ab3016","d5fde3a2cf0d5e20","4936c3234c590ea7","adad14286a6ad703","d1c74a433b2e0ded"}
		end

		-- 构造返回结果
		local result = {}
		for _, v in ipairs(cm) do table.insert(result, v) end
		for _, v in ipairs(cu) do table.insert(result, v) end
		for _, v in ipairs(ct) do table.insert(result, v) end

		local mobileBanList = {}
		mobileBanList["cmmm"] = cmmmBanlist
		mobileBanList["cmgame"] = cmgameBanlist
		mobileBanList["cu"] = cuBanList
		mobileBanList["ct"] = ctBanList

		return result, mobileBanList
	end

	local androidPlatformName = StartupConfig:getInstance():getPlatformName() 
	local province = Cookie.getInstance():read(CookieKey.kLocationProvince)
	local numVersion = tonumber(_G.bundleVersion:split(".")[2])
	local smsChangeToThirdParty = false
	local banSmsTypes = {}
	return smsPaymentDecision(androidPlatformName, province, numVersion, smsChangeToThirdParty, banSmsTypes)
end
return func, "f303ba87b29fd7aad2399ba66a46e995"