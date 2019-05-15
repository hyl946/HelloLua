require "zoo.config.GamePlayResourceConfig"

AudioFrameLoader = {}

AudioFrameLoader.loaded = false

function AudioFrameLoader:needLoadEffect()
	local config = CCUserDefault:sharedUserDefault()
	local IsMusicOpen = not config:getBoolForKey("game.disable.sound.effect")
--	local IsBackgroundMusicOPen = not CCUserDefault:sharedUserDefault():getBoolForKey("game.disable.background.music")
	local audioEnable = IsMusicOpen
	return audioEnable;
end

function AudioFrameLoader:startLoadEffect()
	-- if true then return end
	local audioEnable = self:needLoadEffect()
	if(not audioEnable) then return end

	if(self.loaded) then return end
	self.loaded = true

    local function onFrameLoadComplete( evt )
		self.frameLoader:removeAllEventListeners()
		self.frameLoader = nil
	end

	self.frameLoader = FrameLoader.new()

--	  SimpleAudioEngine doesn't cache preload music actually
--    for i, v in ipairs(ResourceConfig.mp3) do loader:add(v, kFrameLoaderType.mp3) end
    
    if _G.__use_low_audio then
        for i, v in ipairs(ResourceConfig.sfx_for_low_device) do self.frameLoader:add(v, kFrameLoaderType.sfx) end
    else
        for i, v in ipairs(ResourceConfig.sfx) do self.frameLoader:add(v, kFrameLoaderType.sfx) end
    end

    self.frameLoader:addEventListener(Events.kComplete, onFrameLoadComplete)
    self.frameLoader:load()


end

return AudioFrameLoader

