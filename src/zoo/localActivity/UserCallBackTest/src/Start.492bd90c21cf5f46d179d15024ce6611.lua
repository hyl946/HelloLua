local model = require("zoo/localActivity/UserCallBackTest/src/model/Model.lua"):getInstance()
local config = require("zoo/localActivity/UserCallBackTest/Config.lua")

local function actEnd(userClick, endCallback)
	-- model:onActEnd()--:isActEnd()
	if userClick then
		local text = Localization:getInstance():getText("3009.UserCallBack.has.ended")
		CommonTipWithBtn:showTip({tip = text, yes = "知道了"}, "negative", nil, nil, nil, true)
	end
	model:onActEnd()
	if endCallback then endCallback() end
end


return function(userClick, endCallback)
	
	if userClick then
		DcUtil:UserTrack({category='new_call_back_2', sub_category='icon_push_2', t1=0})
	else
		DcUtil:UserTrack({category='new_call_back_2', sub_category='icon_push_2', t1=1})
	end

	if model.mainPanel ~= nil then
	 	return 
	end

	if not config.isActEnd() then
		local function withNet()
			if _G.isLocalDevelopMode then printx(100, "UserCallBackPopoutAction withNet" ) end
			local function getInfoSucess()
				if _G.isLocalDevelopMode then printx(100, "UserCallBackPopoutAction getInfoSucess" ) end
				if config.isActEnd() or model:isActEnd() then --活动已结束
					if _G.isLocalDevelopMode then printx(100, "UserCallBackPopoutAction getInfoSucess isActEnd" ) end
					actEnd(userClick, endCallback)
					return
				end

				-- if model.group > 1 then -- 36以下版本不兼容高版本的奖励配置
				-- 	local ver = tonumber(string.split(_G.bundleVersion, ".")[2])
				-- 	if ver <= 36 then
				-- 		local upTip = Localization:getInstance():getText("UserCallBack.need.update")
				-- 		CommonTipWithBtn:showTip({tip = upTip, yes = "知道了"}, "negative", nil, nil, nil, true)
				-- 		return
				-- 	end
				-- end

				if not userClick then --强弹时候特殊处理
					local scene = Director:sharedDirector():run()
					if scene == nil or not scene:is(HomeScene) then
						return
					end
				end
				Localization:getInstance():removeFile('text/zh_CN/Text_3009.strings')
				Localization:getInstance():loadFile('text/zh_CN/Text_3009.strings')

				local Panel
				if not model.received and model:getTodayID() == 1 then
					Panel = require "zoo/localActivity/UserCallBackTest/src/view/FirstDayPanel.lua"
				else
					Panel = require "zoo/localActivity/UserCallBackTest/src/view/MainPanel.lua"
				end
				if _G.isLocalDevelopMode then printx(100, "UserCallBackPopoutAction do popout" ) end
				Panel:create():popout(endCallback)
			end
			local function getInfoFail()
				if _G.isLocalDevelopMode then printx(100, "UserCallBackPopoutAction getInfoFail" ) end
				if endCallback then endCallback() end
			end
			model:getInfoAsync(getInfoSucess, getInfoFail)
		end

		local function withoutNet()
			if endCallback then endCallback() end
		end
		RequireNetworkAlert:callFuncWithLogged(withNet, withoutNet)
	else
		actEnd(userClick, endCallback)
	end
end