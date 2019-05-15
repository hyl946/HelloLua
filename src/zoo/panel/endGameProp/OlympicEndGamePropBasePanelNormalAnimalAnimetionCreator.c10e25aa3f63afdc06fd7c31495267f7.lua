OlympicEndGamePropBasePanelNormalAnimalAnimetionCreator = {}

function OlympicEndGamePropBasePanelNormalAnimalAnimetionCreator:createAnime()

	local gameBoardLogic = GameBoardLogic:getCurrentLogic()
	local animalId = gameBoardLogic.frontAnimalId

	local skeletonName = nil
	local armatureName = nil
	local nameHead = "skeleton/"

	local offX = 0
	local offY = 0
	
	if animalId == 1 then
		skeletonName = "hippo_cry"
		armatureName = "hippo_sad"
		offX = 120
		offY = -220
	elseif animalId == 2 then
		skeletonName = "frog_cry"
		armatureName = "frog_sad"
		offX = 120
		offY = -220
	elseif animalId == 3 then
		skeletonName = "bear_cry"
		armatureName = "bear_sad"
		offX = 120
		offY = -220
	elseif animalId == 4 then
		skeletonName = "owl_cry"
		armatureName = "owl_sad"
		offX = 120
		offY = -160
	elseif animalId == 5 then
		skeletonName = "fox_cry"
		armatureName = "fox_sad"
		offX = 120
		offY = -220
	elseif animalId == 6 then
		skeletonName = "chicken_cry"
		armatureName = "chicken_sad"
		offX = 120
		offY = -160
	end
	
	if not ThirdAnniversaryMisc then
		FrameLoader:loadArmature( nameHead .. skeletonName )
	end
	
	local node = ArmatureNode:create(armatureName)
    node:setScale(1.8)
    node:playByIndex(0,0)
	
	return node , offX , offY , false
end