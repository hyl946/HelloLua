local TickTaskMgr = class()

function TickTaskMgr:ctor( ... )
    
    self.oneSecondTimer = OneSecondTimer:create()
    self.oneSecondTimer:setOneSecondCallback(function ( ... )
        self:onTick()
    end)

    self.tasks = {}
end

function TickTaskMgr:onTick( ... )
    self:step()
end

function TickTaskMgr:start( ... )
    self.oneSecondTimer:start()
end

function TickTaskMgr:stop( ... )
    self.oneSecondTimer:stop()
end

function TickTaskMgr:setTickTask( taskId, worker )
    self.tasks[taskId] = worker
end

function TickTaskMgr:step( ... )
    for taskId, worker in pairs(self.tasks) do
        worker()
    end
end

return TickTaskMgr