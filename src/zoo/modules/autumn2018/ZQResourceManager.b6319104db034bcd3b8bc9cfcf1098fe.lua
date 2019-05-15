
require "zoo.modules.autumn2018.ZQPlaySceneDecorator"
require "zoo.modules.autumn2018.ZQAnimation"

ZQResourceManager = class()

function ZQResourceManager:loadGameResources()
	ZQAnimation:init()
	
	-- InterfaceBuilder:preloadAsset(ResourceManager:sharedInstance():getMappingFilePath("flash/autumn2018/olympic/olympic_ingame.json") )
end

function ZQResourceManager:unloadGameResources()
	-- OlympicAnimalAnimation:unloadRes()
	-- ArmatureFactory:remove("olympic_banana", "olympic_banana")
	-- ArmatureFactory:remove("olympic_medals", "olympic_medals")
	-- InterfaceBuilder:unloadAsset("flash/olympic/olympic_ingame.json")
end
