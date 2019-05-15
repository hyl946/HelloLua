ExchangePrePropPopoutAction = class(HomeScenePopoutAction)

function ExchangePrePropPopoutAction:ctor( ... )

end

function ExchangePrePropPopoutAction:popout( ... )
    local function finish()
        self:next()
    end
    -- if __WIN32 then
    --     return finish()
    -- end
    require 'zoo.panel.ExchangePrePropPanel'

    local user = UserManager:getInstance()

    local refresh_num = ExchangePrePropPanel:getRefreshNum()
    local bombNum = ExchangePrePropPanel:getMixBombNum()

    if  bombNum > 0 or (refresh_num > 0 and PrePropImproveLogic:isNewItemLogic() ) then
        ExchangePrePropPanel:create():popout(finish)
    else
        self:placeholder()
        self:next()
    end
end

function ExchangePrePropPopoutAction:getConditions( ... )
    return {"enter","enterForground","preActionNext"}
end