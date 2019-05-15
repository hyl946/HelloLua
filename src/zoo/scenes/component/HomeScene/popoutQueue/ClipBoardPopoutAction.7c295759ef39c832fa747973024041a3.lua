--[[
 * ClipBoardPopoutAction
 * @authors zhigang.niu
--]]

ClipBoardPopoutAction = class(HomeScenePopoutAction)

function ClipBoardPopoutAction:ctor()
    self.name = "ClipBoardPopoutAction"
    self.recallUserNotPop = false
    self.isCanPop = true
    self:setSource(AutoPopoutSource.kInitEnter, AutoPopoutSource.kEnterForeground)
end

function ClipBoardPopoutAction:checkCanPop()
    if self.isCanPop then
        local bPop = false

        local fakeURL = ClipBoardUtil.getText() or ""

        -- CommonTip:showTip("copy="..fakeURL, "negative")
        --拆分数组
        local List = string.split(fakeURL, "*")
        --
        if List[2] and string.len(List[2]) >= 9 then
            local num = tonumber(List[2])
            if type(num) == "number" then
                --检测活动是否加载
                local isActCreate, version, source = self:checkActIsHaveCreate()
                if isActCreate then

                    local function needPopCb()
                        self:onCheckCacheResult(true)
                        return false
                    end

                    local function onError()
                        self:onCheckCacheResult(false)
                    end

                    ActivityData.new({source=source,version=version}):start(false, false, nil, onError,nil, needPopCb)

                    bPop = true
                end
            end
        end

        if bPop == false then
            self:onCheckPopResult(false)
        end
    else
        self:onCheckPopResult(false)
    end
end

function ClipBoardPopoutAction:checkActIsHaveCreate( )
    local version = nil
	local source = nil
	for k,v in pairs(ActivityUtil:getActivitys() or {}) do
		if v.source == "RecallB2019/Config.lua" then 
			version = v.version
			source = v.source
			break
		end
	end

    if version then 
        local config
        pcall(function ( ... )
	        config = require ('activity/'..source)
        end)

        local actEnabled = config and config.isSupport()
        if actEnabled then
            return true, version, source
        else
            return false
        end
    else
        return false
    end
end

function ClipBoardPopoutAction:popout( next_action )

    local isActCreate, version, source = self:checkActIsHaveCreate()
    if isActCreate then 
        local function onSucess( ... )
        end

        ActivityData.new({source=source,version=version}):start(false, false, onSucess, next_action, next_action)

        self.isCanPop = false
    else
        if next_action then next_action() end
    end
end