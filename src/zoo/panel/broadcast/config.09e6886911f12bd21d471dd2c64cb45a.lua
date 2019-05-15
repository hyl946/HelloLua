require 'zoo.scenes.HomeScene'
require 'zoo.scenes.GamePlaySceneUI'
require 'zoo.scenes.NewGamePlaySceneUI'
require 'zoo.panel.MarketPanel'
require 'zoo.scenes.ActivityScene'
require "zoo.scenes.ActivityCenterScene"

local SceneConfig = {
	scenes = {
		[1] = HomeScene,
		[2] = GamePlaySceneUI,
		[3] = MarketPanel,
		[4] = ActivityScene,
		[5] = NewGamePlaySceneUI,
		[6] = ActivityCenterScene,
	}
}

function SceneConfig:getSceneType(scene)
	for sceneType, sceneClass in pairs(self.scenes) do
		if scene:is(sceneClass) then
			return sceneType
		end 
	end
end

return SceneConfig