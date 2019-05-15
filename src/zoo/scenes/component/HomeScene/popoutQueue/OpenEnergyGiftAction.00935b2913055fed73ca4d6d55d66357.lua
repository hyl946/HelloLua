--[[
 * OpenEnergyGiftAction
 * @date    2018-08-07 14:39:39
 * @authors zhou.ding
 * @email 	zhou.ding@happyelements.com
--]]

OpenEnergyGiftAction = class(HomeScenePopoutAction)

function OpenEnergyGiftAction:ctor()
    self.name = "OpenEnergyGiftAction"
    self.openUrlMethod = "activity_wxshare"
    self:setSource(AutoPopoutSource.kInitEnter, AutoPopoutSource.kEnterForeground, AutoPopoutSource.kReturnFromFAQ)
end

function OpenEnergyGiftAction:checkCache(cache)
    local res = cache.para
    local ret = false

    local para = res.para
    if type(para) == "table" then
        local paraData = {}
		for k, v in pairs(res.para) do
			paraData[k] = v
		end
        ret = tonumber(paraData.actId) == 160
        if ret then self.para = paraData end
    end

    self:onCheckCacheResult(ret, ret)
end

local RespEnergyShare = class(HttpBase)
function RespEnergyShare:load(pageId)
    if not kUserLogin then return self:onLoadingError(ZooErrorCode.kNotLoginError) end
    local context = self
    local loadCallback = function(endpoint, data, err)
    	if err then
	    	context:onLoadingError(err)
	    else
	    	context:onLoadingComplete(data)
	    end
    end
    self.transponder:call("askEnergyRespShare", {pageId = pageId}, loadCallback, rpc.SendingPriority.kHigh, false)
end

local err_txts = {
	["731540"] = "此条求助链接已经无效了哦~",
	["731541"] = "自己不能赠送给自己精力哦~",
	["731542"] = "今天已经赠送给该好友精力了~",
	["731543"] = "今天赠送次数已达上限，明天再来赠送吧！",
	["731544"] = "好友今日接收精力已达上限了~",
    ["-6"]     = "需要联网才能赠送精力哦~",
}

function OpenEnergyGiftAction:popout( next_action )
	local function onSuccess( evt )
		AutoPopout:showNotifyPanel("成功送给好友一个精力瓶～", next_action)
        local game_name = self.para.game_name
        if game_name ~= nil and #game_name > 0 and type(game_name) == "string" then
            local nameAry = string.split(game_name, "_")
            if nameAry ~= nil and #nameAry > 2 then
                local t1, t2
                if nameAry[#nameAry - 1] == "ewm" then t1 = 1
                else t1 = 2 end
                if nameAry[#nameAry] == "1" then t2 = 1
                else t2 = 2 end
                DcUtil:UserTrack({category = "energy", sub_category = "in_game_help_energy", t1 = t1, t2 = t2})
            end
        end
	end

	local function onFail( evt )
		local scene = Director:sharedDirector():run()
        local err = tostring(evt.data)
        if scene ~= nil and scene:is(HomeScene) then
        	if err_txts[err] then
            	AutoPopout:showNotifyPanel( err_txts[err], next_action)
            else
            	next_action()
            end
        else
        	--TODO:cache?
        end
	end

    local function withNet()
        local http = RespEnergyShare.new(true)
        http:addEventListener(Events.kComplete, onSuccess)
		http:addEventListener(Events.kError, onFail)
        http:load(self.para.pageId)
    end

    local function noNet()
        onFail({data = -6})
    end
    --TODO:no network,show message?
    RequireNetworkAlert:callFuncWithLogged(withNet, noNet)
end