CollectInfoPopoutAction = class(HomeScenePopoutAction)

local hasPopout = false

function CollectInfoPopoutAction:ctor( ... )

end

function CollectInfoPopoutAction:popout( ... )

	local physicalReward = CDKeyManager:getInstance():getPhysicalReward()
	if not physicalReward then
        self:placeholder()
        self:next()
        return
	end

	if CDKeyManager:getInstance():isInfoFull() then
        self:placeholder()
        self:next()
        return
	end

	if hasPopout then
        self:placeholder()
        self:next()
        return	
	end


	hasPopout = true
	local panel = RewardCollectInfoPanel:create(physicalReward,function( ... )
		self:next()
		setTimeOut(function( ... )
			hasPopout = false
		end,0.1)
	end)
	panel:popout()
	
end

function CollectInfoPopoutAction:getConditions( ... )
	return {"enter","enterForground","preActionNext"}
end