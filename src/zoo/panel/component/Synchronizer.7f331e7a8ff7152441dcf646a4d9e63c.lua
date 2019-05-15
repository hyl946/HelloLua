Synchronizer = class()
function Synchronizer:ctor(panel)
    self.panel = panel
    self.observedObjects = {}
    self.waitingCount = 0
end

function Synchronizer:register(object)
    if object then
        self.observedObjects[object] = object
        object.synchronizer = self
    end
end

function Synchronizer:unregister(object)
    if object and self.observedObjects[object] then
        self.observedObjects[object] = nil
        object.synchronizer = nil
    end
end

function Synchronizer:onSendDispatched(object)
    self.panel:p()

    local canSendMore = FreegiftManager:sharedInstance():canSendMore()
    if not canSendMore then 
        for k, v in pairs(self.observedObjects) do
            v:refresh()
        end
    end 
    self.panel.canSendMore = canSendMore
end

function Synchronizer:onSendSucceeded(object)
    self.panel:v()
    self.panel:refresh()
end

function Synchronizer:onSendFailed(object)
    self.panel:v()

    local canSendMore = FreegiftManager:sharedInstance():canSendMore()
    if canSendMore then 
        for k, v in pairs(self.observedObjects) do
            if v and not v.isDisposed then
                v:refresh()
            end
        end
    end
    self.panel.canSendMore = canSendMore
end

