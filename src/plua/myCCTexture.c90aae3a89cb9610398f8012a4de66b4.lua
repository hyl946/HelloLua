
myCCTexture2D = class()
function myCCTexture2D.create()
	local tex = myCCTexture2D.new()
	return tex
end

function myCCTexture2D:releaseData(v) end
function myCCTexture2D:keepData(v) end
function myCCTexture2D:getPixelFormat(v) return 1 end
function myCCTexture2D:getPixelsWide(v) return 1 end
function myCCTexture2D:getPixelsHigh(v) return 1 end
function myCCTexture2D:getName(v) return self.name or 1 end
function myCCTexture2D:getContentSizeInPixels(v) return CCSizeMake(10, 10) end
function myCCTexture2D:setMaxS(v) self.maxS = v end
function myCCTexture2D:getMaxS(v) return self.maxS or 0 end
function myCCTexture2D:getMaxT(v) end
function myCCTexture2D:setMaxT(v) end
function myCCTexture2D:hasPremultipliedAlpha(v) end
function myCCTexture2D:hasMipmaps(v) end
function myCCTexture2D:drawAtPoint(v) end
function myCCTexture2D:drawInRect(v) end
function myCCTexture2D:getContentSize(v) return CCSizeMake(10,10) end
function myCCTexture2D:setTexParameters(v) end
function myCCTexture2D:setAntiAliasTexParameters(v) end
function myCCTexture2D:setAliasTexParameters(v) end
function myCCTexture2D:generateMipmap(v) end
function myCCTexture2D:stringForFormat(v) end
function myCCTexture2D:bitsPerPixelForFormat(v) end
function myCCTexture2D:setDefaultAlphaPixelFormat(v) end
function myCCTexture2D:defaultAlphaPixelFormat(v) end
function myCCTexture2D:setLowDevice(v) end
function myCCTexture2D:setScaledBounds(v) end
function myCCTexture2D:addSensitiveRes(v) end
function myCCTexture2D:enableScaleFeature(v) end
function myCCTexture2D:enableAnalyzeTextureChannel(v) end



CCTexture2D = myCCTexture2D
globalTexture = CCTexture2D:create()


CCTextureCache = class()
local TexCacheIns = nil
function CCTextureCache:sharedTextureCache()
	if TexCacheIns == nil then
		TexCacheIns = CCTextureCache.new()
	end
	return TexCacheIns
end

function CCTextureCache:addImage(k, v)  return globalTexture end
function CCTextureCache:addUIImage(k, v) return globalTexture  end
function CCTextureCache:textureForKey(k, v)   return globalTexture end
function CCTextureCache:addPVRImage(k, v) return globalTexture  end
function CCTextureCache:removeAllTextures(k, v)   end
function CCTextureCache:removeUnusedTextures(k, v)   end
function CCTextureCache:removeTexture(k, v)   end
function CCTextureCache:removeTextureForKey(k, v)   end
function CCTextureCache:dumpCachedTextureInfo(k, v)   end
function CCTextureCache:reloadAllTextures(k, v)   end


