require "zoo.eggs.EggsAnimal"
require "zoo.eggs.EggsPanel"

local eggsDataName = "eggs"

EggsAnimalType = {
	kChicken= 1,--黄鸡
	kHorse	= 2,--河马
	kFrog	= 3,--青蛙
	kBear	= 4,--小熊
	kFox	= 5,--狐狸
	kCat	= 6,--猫头
}


local eggsData = Localhost:readFromStorage(eggsDataName)
if not eggsData then
	eggsData = { time=0,lastShow={0,0},show={} }
end

EggsManager = {}
EggsManager.eggsData = eggsData
function EggsManager:initData( ... )
	local thisDate = os.date("*t",Localhost:time()/1000)
	thisDate.hour = 0
	thisDate.min = 0
	thisDate.sec = 0
	local thisTime = os.time(thisDate)

	if eggsData.time < thisTime then
		eggsData.time = thisTime
		eggsData.show = {}

		local order = {1,2,3,4,5,6}
		for i=1,2 do
			local index = math.random(1,#order)
			table.insert(eggsData.show,order[index])
			table.remove(order,index)
		end
		if eggsData.show[1] > eggsData.show[2] then
			eggsData.show[1],eggsData.show[2] = eggsData.show[2],eggsData.show[1]
		end
		if eggsData.lastShow[1] == eggsData.show[1] and eggsData.lastShow[2] == eggsData.show[2] then
			table.remove(eggsData.show,2)
			local index = math.random(1,#order)
			table.insert(eggsData.show,order[index])
			table.remove(order,index)
		end
		if eggsData.show[1] > eggsData.show[2] then
			eggsData.show[1],eggsData.show[2] = eggsData.show[2],eggsData.show[1]
		end

		eggsData.lastShow = eggsData.show
		Localhost:writeToStorage(eggsData,eggsDataName)
	end

	if _G.isLocalDevelopMode then printx(0, "eggsData.show",eggsData.show[1],eggsData.show[2]) end
	-- debug.debug()
end
-- EggsManager:initData()

function EggsManager:canShow( animalType )
	return false
end
function EggsManager:createAnimal( animalType,worldScene )
	return EggsAnimal:create(animalType,worldScene)
end

function EggsManager:hasClicked( animalType )
	local uiHasClickedEasterEggList = UserManager:getInstance().uiHasClickedEasterEggList
	return table.exist(uiHasClickedEasterEggList,animalType)	
end

function EggsManager:hasAllClicked( ... )
	for k,v in pairs(EggsAnimalType) do
		if not self:hasClicked(v) then
			return false
		end
	end
	return true
end

function EggsManager:setClicked( animalType )
	local uiHasClickedEasterEggList = UserManager:getInstance().uiHasClickedEasterEggList
	table.insertIfNotExist(uiHasClickedEasterEggList,animalType)
end

-- function EggsManager:showCatIfNecessary( ... )
-- end

function EggsManager:showBearIfNecessary( worldScene )

	if not self:canShow(EggsAnimalType.kBear) then
		return
	end	
	local scaleTreeLayer1 = worldScene.scaleTreeLayer1

	local animal = self:createAnimal(EggsAnimalType.kBear,worldScene)

	animal:setPositionX(320)
	animal:setPositionY(550)
	scaleTreeLayer1:addChild(animal)
end

function EggsManager:showChickenIfNecessary( worldScene )
	if not self:canShow(EggsAnimalType.kChicken) then
		return
	end

	local scaleTreeLayer1 = worldScene.scaleTreeLayer1
	local hiddenBranchArray = worldScene.hiddenBranchArray

	if #hiddenBranchArray <= 0 then
		return
	end

	local branch = hiddenBranchArray[math.random(1,#hiddenBranchArray)]
	if not branch then
		return
	end

	local animal = self:createAnimal(EggsAnimalType.kChicken,worldScene)
	if branch.direction == HiddenBranchDirection.LEFT then
		animal:setPositionX(branch:getPositionX() - 300)
	else
		animal:setPositionX(branch:getPositionX() + 150)
	end
	animal:setPositionY(branch:getPositionY() + 280)

	scaleTreeLayer1:addChild(animal)
end

function EggsManager:showFrogIfNecessary( worldScene )
	if not self:canShow(EggsAnimalType.kFrog) then
		return
	end
	local animal = self:createAnimal(EggsAnimalType.kFrog,worldScene)

	local function showAnimal()
		local lockedClouds = worldScene.lockedClouds
		local cloud = table.find(lockedClouds,function( v )
			return v.state == LockedCloudState.STATIC 
		end)
		if cloud then
			if animal.cloudId == cloud.id then
				return
			elseif animal:getParent() then
				animal:removeFromParentAndCleanup(false)
			end
			local lockedCloudLayer = worldScene.lockedCloudLayer
			local scaleTreeLayer2  = worldScene.scaleTreeLayer2
			animal:setPositionX(cloud:getPositionX() + 220)
			animal:setPositionY(cloud:getPositionY() - 210)
			scaleTreeLayer2:addChild(animal)

			animal.cloudId = cloud.id
		else
			GamePlayEvents.removePassLevelEvent(showAnimal)
			if animal:getParent() then
				animal:removeFromParentAndCleanup(false)
			end
			local topAreaCloud = worldScene.topAreaCloud
			animal:setPositionX(-120)
			animal:setPositionY(-50)
			animal:setScale(1/topAreaCloud.waitedCloud:getScale())
			topAreaCloud.waitedCloud:addChildAt(animal,3)

			animal.cloudId = "topAreaCloudId"
		end
	end

	GamePlayEvents.addPassLevelEvent(showAnimal)
	showAnimal()
end

function EggsManager:showHorseIfNecessary(ui, bottle, umbrella)
	if not self:canShow(EggsAnimalType.kHorse) then
		return
	end

	bottle:setVisible(false)
	umbrella:setVisible(false)
	local animal = self:createAnimal(EggsAnimalType.kHorse)
	animal:setPositionXY(umbrella:getPositionX() - 20, umbrella:getPositionY())
	ui:addChildAt(animal, ui:getChildIndex(bottle))
end

function EggsManager:showFoxIfNecessary( worldScene )
	if not self:canShow(EggsAnimalType.kFox) then
		return
	end

	local visibleSize = CCDirector:sharedDirector():getVisibleSize()
	local visibleOrigin = Director:sharedDirector():getVisibleOrigin()

	local posX = visibleSize.width/2
	local posY = visibleSize.height + 300

	local animal = self:createAnimal(EggsAnimalType.kFox,worldScene)
	local direction = -1

	local function showAnimal( ... )
		animal:setPositionX(posX)
		animal:setPositionY(posY)
		worldScene:addChild(animal)

		local lastPosX = animal:getPositionX()
		local lastPosY = animal:getPositionY()

		local width = 100
		local height = 300

		local function createSpline( ... )
			width = math.random(width,250)
			height = math.random(height,500)
			direction = direction * -1		
			local path = {
				ccp(lastPosX,lastPosY),
				ccp(lastPosX + width * direction,lastPosY - height/2),
				ccp(lastPosX,lastPosY - height)
			}
			return CardinalSpline.new(path, -3)
		end
		local spline = createSpline()

		animal:scheduleUpdateWithPriority(function( dt )

			animal:setPositionY(animal:getPositionY() - dt / (animal:isPlayTip() and 30 or 10) * visibleSize.height)

			if animal:getPositionY() < -300 then
				animal:unscheduleUpdate()
				animal:runAction(CCSequence:createWithTwoActions(
					CCDelayTime:create(10),
					CCCallFunc:create(showAnimal)
				))
				return
			end

			if lastPosY > animal:getPositionY() + height then
				lastPosY = lastPosY - height
				spline = createSpline()
			end

			local value = (lastPosY - animal:getPositionY()) / height
			animal:setPositionX(spline:calculatePosition(value).x)
		end,0)
	end

	showAnimal()
end


function EggsManager:showIfNecessary( worldScene )
	-- if not _G.kUserLogin then

	-- end
	self:showBearIfNecessary(worldScene)
	self:showChickenIfNecessary(worldScene)
	self:showFrogIfNecessary(worldScene)
	self:showFoxIfNecessary(worldScene)
end