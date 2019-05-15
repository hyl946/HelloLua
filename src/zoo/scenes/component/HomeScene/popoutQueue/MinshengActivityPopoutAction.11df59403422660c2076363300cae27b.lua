MinshengActivityPopoutAction = class(HomeScenePopoutAction)

function MinshengActivityPopoutAction:ctor( ... )
	self.name = "MinshengActivityPopoutAction"
	self:setSource(AutoPopoutSource.kInitEnter, AutoPopoutSource.kEnterForeground)
end

function MinshengActivityPopoutAction:checkCanPop()
	-- print("----MinshengActivityPopoutAction:checkCanPop()")
	-- RemoteDebug:uploadLogWithTag('----MinshengActivityPopoutAction:checkCanPop()')

	local actInfo
    for kk, vv in pairs(UserManager:getInstance().actInfos or {}) do
        if vv.actId == 5000 then
            actInfo = vv
            break
        end
    end
	-- RemoteDebug:uploadLogWithTag('----MinshengActivityPopoutAction:ctor()',table.tostring(actInfo))
    if actInfo then
	    actInfo.extraData = table.deserialize(actInfo.extra)
	    -- extra : "{"consumeReward":0,"checkInReward":true}"
	    if actInfo.extraData and actInfo.extraData.consumeReward > 0 then
	    	actInfo.see = true
	    	self.needPop = true
		end
	end
	-- RemoteDebug:uploadLogWithTag('----MinshengActivityPopoutAction:ctor()',table.tostring(actInfo))
	self.actInfo = actInfo

	if not self.actInfo or not self.needPop then
		self:onCheckPopResult(false)
	end

	local once = false
	local function needNoPop()
		if not once then
			self:onCheckPopResult(true)
		end
		once = true
		return false
	end

	local function onError()
		self:onCheckPopResult(false)
	end

	local function onGetList(act)
		-- print("MinshengActivityPopoutAction:checkCanPop()onGetList(act)",act)
		if act then
			local data = ActivityData.new(act)
			data:start(false,false,nil,onError,onError, needNoPop)
		else
			self:onCheckPopResult(false)
		end
	end

	self:checkActivity(onGetList, true)
end

function MinshengActivityPopoutAction:popout( next_action )
	if not self.actInfo then
		next_action()
		return
	end

	local function onSuccess( ... )
		next_action()
	end

	local function onError( ... )
		next_action()
	end
	local function onEnd( ... )

	end

	local function onGetList(act)
		if act then
			local data = ActivityData.new(act)
			data:start(false,false,onSuccess,onError,onEnd)
		else
			next_action()
		end
	end

	self:checkActivity(onGetList)
end

function MinshengActivityPopoutAction:checkActivity(cb, notRecode)
	-- print("onGetList(list)000")
	-- RemoteDebug:uploadLogWithTag('onGetList(list)0')

	local function onGetList(list)
		-- print("onGetList(list)",table.tostring(list))
		for i,v in ipairs(list) do
            if v.actId == 5000 then
            	cb(v)
            end
		end
	end
	PushActivity:sharedInstance():getActivityListAsync(onGetList, notRecode)
end