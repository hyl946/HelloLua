GivebackPopoutAction = class(HomeScenePopoutAction)
function GivebackPopoutAction:ctor()
    self.name = "GivebackPopoutAction"
    self:setSource(AutoPopoutSource.kInitEnter, AutoPopoutSource.kEnterForeground)
end

function GivebackPopoutAction:checkCanPop()
    if self.debug then
        UserManager:getInstance().compenList = { 
            {compenTitle = "测试",
            compenText = "测试",
            rewards = {{num = 1,itemId = 2}},
            id = 52}
        }
    end
    local indexes = GiveBackPanelModel:getCompenIndexes()
    self:onCheckPopResult(#indexes > 0)
end

function GivebackPopoutAction:popout(next_action)
    local indexes = GiveBackPanelModel:getCompenIndexes()
    local count = 0
    local total = #indexes

    local function panelCloseCallback() 
        count = count + 1
        if count >= total then
            next_action()
        end
    end

    for k, v in ipairs(indexes) do
        local panel = GiveBackPanel:create(v)
        if panel then panel:popout(panelCloseCallback) end
    end
end