---------------------------------------------------------------------------------------
-- @Author: dan.liang
-- @Date:   2016-07-29 11:18:32
-- @Email:  dan.liang@happyelements.com
-- @Last Modified by:   Administrator
-- @Last Modified time: 2016-08-24 16:23:28
---------------------------------------------------------------------------------------
require "zoo.modules.olympic.OlympicAnimalAnimation"
require "zoo.modules.olympic.OlympicPlaySceneDecorator"

OlympicResourceManager = class()

function OlympicResourceManager:loadGameResources()
	OlympicAnimalAnimation:init()
	--FrameLoader:loadArmature( 'skeleton/olympic_banana', "olympic_banana", "olympic_banana" )
	--FrameLoader:loadArmature( 'skeleton/olympic_medals', "olympic_medals", "olympic_medals" )
	FrameLoader:loadArmature( 'skeleton/SZN_Animation', "SZN_Animation", "SZN_Animation" )
	InterfaceBuilder:preloadAsset( ResourceManager:sharedInstance():getMappingFilePath("flash/olympic/olympic_ingame.json") )
end

function OlympicResourceManager:unloadGameResources()
	-- OlympicAnimalAnimation:unloadRes()
	-- ArmatureFactory:remove("olympic_banana", "olympic_banana")
	-- ArmatureFactory:remove("olympic_medals", "olympic_medals")
	-- InterfaceBuilder:unloadAsset("flash/olympic/olympic_ingame.json")
end
