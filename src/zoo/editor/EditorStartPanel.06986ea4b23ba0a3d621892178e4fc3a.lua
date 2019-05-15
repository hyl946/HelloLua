EditorStartPanel = class(LevelInfoPanel)

function EditorStartPanel:init(parentPanel, levelId, levelType, ...)
	LevelInfoPanel.init(self, parentPanel, levelId, levelType)

	self.helpIcon:setTouchEnabled(false)
	self.helpIcon:setButtonMode(false)

	for index = 1, #self.preGameTools do
		self.preGameTools[index]:setLocked(false)
		self.preGameTools[index]:setFreePrice()
		self.preGameTools[index]:updatePriceColor()
	end
end

function EditorStartPanel:startGame()
	self:startGamePlayScene()
end

function EditorStartPanel:onCloseBtnTapped(event, ...)

end

function EditorStartPanel:startGamePlayScene()
	local selectedItemsData = self:getSelectedItemsData()
	self:setSelectedItemAnimDestPos(selectedItemsData)
	self.selectedItemsData = selectedItemsData
	self.startFromEnergyPanel = false


	local levelConfig = LevelDataManager.sharedLevelData():getLevelConfigByID( self.levelId  , false )

	local fileList , featureMap = levelConfig:getDependingSpecialAssetsList(self.levelType)
	self.featureMap = featureMap
	GamePlayContext:getInstance().levelFeatureMap = self.featureMap

	--local devTestGPS = EditorGamePlayScene:create(self.levelId, self.levelType, selectedItemsData)
	GameInitBuffLogic:initWithSelectedPreItems(selectedItemsData)

	local devTestGPS = EditorGamePlayScene:create( levelConfig , selectedItemsData)
    self.devTestGPS = devTestGPS
    self.parentPanel:addChild(devTestGPS)
    self.parentPanel:removeChild(self)

    _G.currentEditorLevelScene = devTestGPS
end

function EditorStartPanel:create(parentPanel, levelId, levelType, ...)
	assert(parentPanel)
	assert(type(levelId) 			== "number")
	assert(#{...} == 0)
	local newPanel = EditorStartPanel.new()
	newPanel:init(parentPanel, levelId, levelType)
	return newPanel
end

function EditorStartPanel:initPreGameTools( initialProps )
	initialProps = initialProps or {}
	local hasRandomBird = false 
	if #initialProps > 0 then 
		for i,v in ipairs(initialProps) do
			if v.propId == ItemType.PRE_RANDOM_BIRD then 
				hasRandomBird = true
				break
			end
		end
	end
	if not hasRandomBird then 
		local info = {}
		info.propId = ItemType.PRE_RANDOM_BIRD
		table.insert(initialProps, 1, info)
	end

	LevelInfoPanel.initPreGameTools(self, initialProps)
end

