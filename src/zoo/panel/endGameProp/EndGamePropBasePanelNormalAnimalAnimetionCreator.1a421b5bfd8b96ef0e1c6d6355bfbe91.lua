EndGamePropBasePanelNormalAnimalAnimetionCreator = {}

function EndGamePropBasePanelNormalAnimalAnimetionCreator:createAnime(itemId)
	local cryingAnimation 
	if itemId == ItemType.THIRD_ANNIVERSARY_ADD_FIVE then
		local container = CocosObject:create()
		local node = ArmatureNode:create("autumn_2018_add5/add5animal")
		node:playByIndex(0)
		node:setAnimationScale(1.25)
		container.animNode = node
		container:addChild(node:wrapWithBatchNode())
		node:setScale(0.6)
		cryingAnimation = container
		return cryingAnimation , 0 , 10 , false
	else
		cryingAnimation = AddFiveStepAnimation:create()
		return cryingAnimation , -30 , 2 , true
	end
end