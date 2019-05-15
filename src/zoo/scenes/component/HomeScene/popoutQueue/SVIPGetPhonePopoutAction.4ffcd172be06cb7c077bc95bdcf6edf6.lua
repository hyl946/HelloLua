SVIPGetPhonePopoutAction = class(HomeScenePopoutAction)

function SVIPGetPhonePopoutAction:ctor()
    self.name = "SVIPGetPhonePopoutAction"
    self.recallUserNotPop = true
    self:setSource(AutoPopoutSource.kInitEnter, AutoPopoutSource.kEnterForeground)
end

function SVIPGetPhonePopoutAction:checkCanPop()
    if self.debug then
        UserManager:getInstance().endTimeOfBindPhoneIcon = 1534389480000
        SVIPGetPhoneManager:getInstance().NeedPopOut = 1
        UserManager:getInstance().lastLoginTime = 1
        if not PushBindingLogic.isDataInit then
            PushBindingLogic:initData()
        end
        SVIPGetPhoneManager:getInstance():InitSVIPInfo()
    end

    local lastLoginTime = UserManager:getInstance().lastLoginTime

    local ret = lastLoginTime ~= nil and lastLoginTime >= 0
    ret = ret and SVIPGetPhoneManager:getInstance():getNeedPopOut() == 1

    if not ret then
        return self:onCheckPopResult(false)
    end

    SVIPGetPhoneManager:getInstance():canForcePop(function ( canPop )
        self:onCheckPopResult(canPop)
    end)
end

function SVIPGetPhonePopoutAction:popout(next_action)
    local source = "SVIPGetPhone/Config.lua"

    local version = nil
    for k,v in pairs(ActivityUtil:getActivitys() or {}) do
        if v.source == source then 
            version = v.version
            break
        end
    end

    if version then 
        local function onSucess( ... )
        end

        ActivityData.new({source=source,version=version}):start(false, false, onSucess, next_action, next_action)

        SVIPGetPhoneManager:getInstance():setNeedPopOut()
    else
        next_action()
    end
end