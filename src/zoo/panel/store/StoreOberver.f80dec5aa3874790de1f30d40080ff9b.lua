local StoreOberver = class()

local observer

function StoreOberver:setObserver( pObserver )
	observer = pObserver
end

function StoreOberver:afterGoldChange( ... )
	if not observer then return end
	observer:notify()
end


return StoreOberver