require "plua.myCCNode"
require "plua.myCCTexture"
myCCSprite = class(myCCNode)


function myCCSprite:ctor()
	self.texture = myCCTexture2D.create()
end

function myCCSprite:create()
	local spt = myCCSprite.new()
	return spt
end

function myCCSprite:createWithTexture(tex)
	return myCCSprite.new()
end

function myCCSprite:createWithSpriteFrameName()
	return myCCSprite.new()
end

function myCCSprite:createWithSpriteFrame()
	return myCCSprite.new()
end

function myCCSprite:setDirty(v) end
function myCCSprite:isDirty(v) return false end
function myCCSprite:getQuad(v) end
function myCCSprite:getTextureRect(v) return CCRectMake(0, 0, 1, 1) end
function myCCSprite:isTextureRectRotated(v) end
function myCCSprite:setAtlasIndex(v) self.atlasIndex = v end
function myCCSprite:getAtlasIndex(v) return self.atlasIndex or 0 end
function myCCSprite:setBlendFunc(v) end
function myCCSprite:getOffsetPosition(v) return ccp(0,0) end
function myCCSprite:ignoreAnchorPointForPosition(v) end
function myCCSprite:setFlipX(v) end
function myCCSprite:setFlipY(v) end
function myCCSprite:isFlipX(v) end
function myCCSprite:isFlipY(v) end
function myCCSprite:setOpacityModifyRGB(v) end
function myCCSprite:isOpacityModifyRGB(v) end
function myCCSprite:setTexture(v) self.texture = v end
function myCCSprite:getTexture(v) return self.texture end
function myCCSprite:updateTransform(v) end
function myCCSprite:setTextureRect(v) end
function myCCSprite:setVertexRect(v) end
function myCCSprite:setDisplayFrame(v) end
function myCCSprite:isFrameDisplayed(v) return true end
function myCCSprite:setBatchNode(v) self.batchNode = v end
function myCCSprite:getBatchNode(v) return self.batchNode or self end
function myCCSprite:setDisplayFrameWithAnimationName(v) end


myCCSpriteBatchNode = class(myCCSprite)
function myCCSpriteBatchNode:create()
	return myCCSpriteBatchNode.new()
end

CCSpriteBatchNode = myCCSpriteBatchNode
CCSprite = myCCSprite