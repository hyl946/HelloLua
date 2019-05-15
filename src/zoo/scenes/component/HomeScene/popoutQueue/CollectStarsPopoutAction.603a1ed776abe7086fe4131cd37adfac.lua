require "zoo.data.UserManager"
--CollectStarsManager
CollectStarsPopoutAction = class(HomeScenePopoutAction)

local function isHomeScene()
    return Director:sharedDirector():getRunningScene():is(HomeScene)
end

function CollectStarsPopoutAction:ctor()
    self.name = "CollectStarsPopoutAction"
    
    self:setSource( AutoPopoutSource.kTriggerPop )
    
end



function CollectStarsPopoutAction:checkCache(cache)

    local ret = false

    local isActivitySupport = CollectStarsManager:getInstance():isActivitySupport()
    if not isActivitySupport then
        ret = false
    end    

    self:onCheckCacheResult( ret ,ret )

end

function CollectStarsPopoutAction:popout( next_Action )

    
    local function closeCallBack( ... )
        if _G.isLocalDevelopMode then printx(100, "CollectStarsPopoutAction closeCallBack " ) end
        if next_Action then
             if _G.isLocalDevelopMode then printx(100, "CollectStarsPopoutAction closeCallBack next_Action" ) end
            next_Action()
        end
    end 

    CollectStarsManager:getInstance():setPopoutActionCloseCallBack( closeCallBack )
    

    local actSource = CollectStarsManager:getInstance():getActSource()
    local source = actSource
    local version = nil
    for k,v in pairs(ActivityUtil:getActivitys() or {}) do
        if v.source == source then
            version = v.version
            break
        end
    end

    if version then
        ActivityData.new({source=source,version=version}):start(true, false, nil, nil, closeCallBack)
    else
        closeCallBack()
    end


    
end