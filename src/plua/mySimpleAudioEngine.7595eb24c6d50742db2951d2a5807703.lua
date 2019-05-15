SimpleAudioEngine = class()
local instance = nil 
function SimpleAudioEngine:sharedEngine()
	if instance == nil then
		instance = SimpleAudioEngine.new()
	end
	return instance
end

function SimpleAudioEngine:preloadBackgroundMusic(k, v) end
function SimpleAudioEngine:playBackgroundMusic(k, v) end
function SimpleAudioEngine:stopBackgroundMusic(k, v) end
function SimpleAudioEngine:pauseBackgroundMusic(k, v) end
function SimpleAudioEngine:resumeBackgroundMusic(k, v) end
function SimpleAudioEngine:rewindBackgroundMusic(k, v) end
function SimpleAudioEngine:willPlayBackgroundMusic(k, v) end
function SimpleAudioEngine:isBackgroundMusicPlaying(k, v) return true end
function SimpleAudioEngine:getBackgroundMusicVolume(k, v) return 1 end
function SimpleAudioEngine:setBackgroundMusicVolume(k, v) end
function SimpleAudioEngine:getEffectsVolume(k, v) end
function SimpleAudioEngine:setEffectsVolume(k, v) end
function SimpleAudioEngine:playEffect(k, v) end
function SimpleAudioEngine:stopEffect(k, v) end
function SimpleAudioEngine:preloadEffect(k, v) end
function SimpleAudioEngine:isEffectPreloaded(k, v) return true end
function SimpleAudioEngine:unloadEffect(k, v) end
function SimpleAudioEngine:pauseEffect(k, v) end
function SimpleAudioEngine:resumeEffect(k, v) end
function SimpleAudioEngine:pauseAllEffects(k, v) end
function SimpleAudioEngine:resumeAllEffects(k, v) end
function SimpleAudioEngine:stopAllEffects(k, v) end

