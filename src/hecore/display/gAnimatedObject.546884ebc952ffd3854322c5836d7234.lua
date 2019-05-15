--
-- gAnimatedObject ---------------------------------------------------------
--
gAnimatedObject = class(CocosObject)

function gAnimatedObject:createWithAsset(anAsset)
	local object = anAsset:createObject()
	local instance = gAnimatedObject.new(object)
	return instance
end

--[[
local function getRealFileName(filename)
	local groups = filename:split(".")
	if groups[2] == "gaf" then
		if __use_small_res then
			filename = groups[1].."@2x"..".gaf"
		end
	else
		assert(false, "file name can not contain '.' ")
	end
	return filename
end
]]


function gAnimatedObject:loadRes(filename)
	local pkmz = StartupConfig:getInstance():getIsPkmSoftwareMode()
	local asset = GAFAsset:create(filename, pkmz, 0)

    return asset
end

function gAnimatedObject:createWithFilename(filename)
--	local pkmz = StartupConfig:getInstance():getIsPkmSoftwareMode()
----	local asset = GAFAsset:create(getRealFileName(filename), pkmz, 0)
--	local asset = GAFAsset:create(filename, pkmz, 0)

    local asset = self:loadRes(filename)
	return gAnimatedObject:createWithAsset(asset)
end



function gAnimatedObject:start()
	self.refCocosObj:start()
end

function gAnimatedObject:stop()
	self.refCocosObj:stop()
end

function gAnimatedObject:pause()
	self.refCocosObj:pause()
end
function gAnimatedObject:resume()
	self.refCocosObj:resume()
end

function gAnimatedObject:step()
	self.refCocosObj:step()
end

function gAnimatedObject:isDone()
	return self.refCocosObj:isDone()
end

function gAnimatedObject:isAnimationRunning()
	return self.refCocosObj:isAnimationRunning()
end

function gAnimatedObject:isLooped()
	return self.refCocosObj:isLooped()
end

function gAnimatedObject:setLooped(looped)
	self.refCocosObj:setLooped(looped)
end

function gAnimatedObject:isReversed()
	return self.refCocosObj:isReversed()
end

function gAnimatedObject:setReversed(reversed)
	self.refCocosObj:setReversed(reversed)
end

function gAnimatedObject:totalFrameCount()
	return self.refCocosObj:totalFrameCount()
end

function gAnimatedObject:currentFrameIndex()
	return self.refCocosObj:currentFrameIndex()
end


function gAnimatedObject:setFrame(index)
	return self.refCocosObj:setFrame(index)
end

function gAnimatedObject:gotoAndStop(frameLabel)
	return self.refCocosObj:gotoAndStop(frameLabel)
end
function gAnimatedObject:gotoAndStopFrame(frameNumber)
	return self.refCocosObj:gotoAndStop(frameNumber)
end

function gAnimatedObject:gotoAndPlay(frameLabel)
	return self.refCocosObj:gotoAndPlay(frameLabel)
end
function gAnimatedObject:gotoAndPlayFrame(frameNumber)
	return self.refCocosObj:gotoAndPlay(frameNumber)
end

function gAnimatedObject:getStartFrame(frameLabel)
	return self.refCocosObj:getStartFrame(frameLabel)
end
function gAnimatedObject:getEndFrame(frameLabel)
	return self.refCocosObj:getEndFrame(frameLabel)
end


function gAnimatedObject:playSequence(name, looped, resume, hint)
	return self.refCocosObj:playSequence(name, looped, resume, hint)
end
function gAnimatedObject:clearSequence()
	return self.refCocosObj:clearSequence()
end

function gAnimatedObject:enableBatching(value)
	return self.refCocosObj:enableBatching(value)
end

function gAnimatedObject:setSequenceDelegate(sequenceName, _cbFinishSequence, isLoop)
	local function cb(obj, seqName)
		if seqName == sequenceName then 
			if not isLoop and self.refCocosObj then 
				self.refCocosObj:setSequenceDelegate(nil)
			end
			if _cbFinishSequence then _cbFinishSequence(obj, seqName) end
		end
	end
	return self.refCocosObj:setSequenceDelegate(cb)
end


function gAnimatedObject:setAnimationPlaybackDelegate(_cbAnimationFinishedPlay, _cbAnimationStartedNextLoop)
	return self.refCocosObj:setAnimationPlaybackDelegate(_cbAnimationFinishedPlay, _cbAnimationStartedNextLoop)
end
