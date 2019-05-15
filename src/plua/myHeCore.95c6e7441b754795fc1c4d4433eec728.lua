IAnimatable = class()
function IAnimatable:advanceTime(v) end

DBCCArmatureNode = class(myCCSprite)

function DBCCArmatureNode:registerArmatureEventListener(eventHandler, v)
	
end

function DBCCArmatureNode:advanceTime(v) 
	
end

DBCCFactory = class()
local DBCCFactoryIns = nil
function DBCCFactory:getInstance()
	if DBCCFactoryIns == nil then
		DBCCFactoryIns = DBCCFactory.new()
	end
	return DBCCFactoryIns
end

function DBCCFactory:destroyInstance(v)  end
function DBCCFactory:buildArmature(v)  end
function DBCCFactory:buildArmatureNode(v)  
	return DBCCArmatureNode.new() 
end
function DBCCFactory:loadDragonBonesData(v)  end
function DBCCFactory:loadTextureAtlas(v)  end
function DBCCFactory:refreshTextureAtlasTexture(v)  end
function DBCCFactory:hasDragonBones(v)  return false end

