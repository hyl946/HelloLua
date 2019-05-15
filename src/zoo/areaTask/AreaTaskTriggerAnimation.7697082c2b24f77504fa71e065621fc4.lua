local AreaTaskTriggerAnimation = {}

function AreaTaskTriggerAnimation:playAnimation( _taskFlowerIcons, callback )

	local taskFlowerIcons = {}

	for _, v in pairs(_taskFlowerIcons) do
		table.insert(taskFlowerIcons, v)
		v:setOpacity(0)
		local y = v:getPositionY()
		v:setPositionY(y + 100)
	end

	table.sort(taskFlowerIcons, function ( a, b )
		if a and b then
			local dataA = a:getData() or {}
			local dataB = b:getData() or {}
			local levelA = dataA.levelId or 0
			local levelB = dataB.levelId or 0
			return levelA < levelB
		end
		return false
	end)


	if #taskFlowerIcons <= 0 then
		return
	end

	local startLevelId = taskFlowerIcons[1]:getData().levelId
	local endLevelId = taskFlowerIcons[#taskFlowerIcons]:getData().levelId

	HomeScene:sharedInstance().worldScene:moveNodeToCenter(startLevelId, function ( ... )
		HomeScene:sharedInstance().worldScene:moveNodeToCenter(endLevelId, function ( ... )
			for index, v in ipairs(taskFlowerIcons) do
				if v.isDisposed then return end
				local array = CCArray:create()
				array:addObject(CCFadeIn:create(0.1))
				array:addObject(CCMoveBy:create(6/24, ccp(0, -100)))
				local seqArray = CCArray:create()
				seqArray:addObject(CCScaleTo:create(6/24, 0.87204, 0.87204))
				seqArray:addObject(CCScaleTo:create(3/24, 1.112152, 1.112152))
				seqArray:addObject(CCScaleTo:create(3/24, 1, 1))
				array:addObject(CCSequence:create(seqArray))
				local levelId = v:getData().levelId

				local array2 = CCArray:create()
				array2:addObject(CCDelayTime:create((levelId - startLevelId) * 0.1))
				array2:addObject(CCSpawn:create(array))

				if index == #taskFlowerIcons then
					array2:addObject(CCCallFunc:create(function ( ... )
						if callback then callback() end
					end))
				end
				v:runAction(CCSequence:create(array2))
			end
    	end)
    end, 0.1)
end

return AreaTaskTriggerAnimation