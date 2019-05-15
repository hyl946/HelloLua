CCSpriteFrame = class()

function CCSpriteFrame:getTexture(k, v) return globalTexture end
function CCSpriteFrame:setOffset(k, v) end
function CCSpriteFrame:create(k, v) return CCSpriteFrame.new() end
function CCSpriteFrame:createWithTexture(k, v) return CCSpriteFrame.new() end

local gCCSpriteFrame = CCSpriteFrame:create()

CCSpriteFrameCache = class()
local instance = nil
function CCSpriteFrameCache:sharedSpriteFrameCache()
	if instance == nil then
		instance = CCSpriteFrameCache.new()
	end
	return instance
end



function CCSpriteFrameCache:addSpriteFramesWithFile(k, v) end
function CCSpriteFrameCache:addSpriteFrame(k, v) end
function CCSpriteFrameCache:removeSpriteFrames(k, v) end
function CCSpriteFrameCache:removeUnusedSpriteFrames(k, v) end
function CCSpriteFrameCache:removeSpriteFrameByName(k, v) end
function CCSpriteFrameCache:removeSpriteFramesFromFile(k, v) end
function CCSpriteFrameCache:removeSpriteFramesFromTexture(k, v) end
function CCSpriteFrameCache:spriteFrameByName(k, v) return gCCSpriteFrame end
function CCSpriteFrameCache:purgeSharedSpriteFrameCache(k, v) end

