


local VideoPlayer = class()

function VideoPlayer:openAndPlay(playConfig)
	-- body
	local videoUrl = playConfig.videoUrl
	local videoFile = playConfig.videoFile or ""
	local width = playConfig.width or 720
	local height = playConfig.height or 360

	local vs = Director:sharedDirector():getWinSize()

	local x = playConfig.x or 0
	local y = playConfig.y or (vs.height/2)

	local forceFullWindow = playConfig.forceFullWindow or false
	local portrait = playConfig.portrait or false

	local showController = playConfig.showController == nil and true or false
	local showGestureController = playConfig.showGestureController == nil and true or false

	local contentScale = Director:sharedDirector():getContentScaleFactor()	

	local p = Director:sharedDirector():convertToUI(ccp(x, y))


	local winSize = CCDirector:sharedDirector():getWinSize()
	local frameSize = CCDirector:sharedDirector():getOpenGLView():getFrameSize()
	local scaleX = CCDirector:sharedDirector():getOpenGLView():getScaleX()
	local scaleY = CCDirector:sharedDirector():getOpenGLView():getScaleY()

	local uiLeft = frameSize.width/2 - (winSize.width/2 - x) * scaleX
	local uiTop = frameSize.height/2 + (winSize.height/2 - y) * scaleY
	local uiWidth = width * scaleX
	local uiHeight = height * scaleY


	if __ANDROID then
		videoFile = CCFileUtils:sharedFileUtils():fullPathForFilename(videoFile)
		if string.starts(videoFile, 'apk:/') then
			videoFile = videoFile:gsub('apk:/', 'file:///android_asset/')
		else
			if string.sub(videoFile, 1, 1) == '/' then
				videoFile = 'file://' .. videoFile
			else
				videoFile = 'file:///' .. videoFile
			end
		end
		local VideoPlayerManager = luajava.bindClass("com.happyelements.video.player.VideoPlayerManager")

		VideoPlayerManager:getInstance():openVideoPlayer(videoUrl or videoFile, uiLeft, uiTop, uiWidth, uiHeight, forceFullWindow, portrait, showController, showGestureController)

		local videoPlayerLogic = VideoPlayerManager:getInstance():getVideoPlayerLogic()

		local IsBackgroundMusicOPen = false
		local defaultDelegate = luajava.createProxy("com.happyelements.video.player.VideoPlayerDelegate", {
		    onPopout = function ()
		    	CommonTip:showTip("onPopout")
		    	IsBackgroundMusicOPen = GamePlayMusicPlayer:getInstance().IsBackgroundMusicOPen
		    	if IsBackgroundMusicOPen then
		    		GamePlayMusicPlayer:getInstance():pauseBackgroundMusic()
		    	end
		    end,
		    onDispose = function ()
		    	CommonTip:showTip("onDispose")
		    	if IsBackgroundMusicOPen then
		    		GamePlayMusicPlayer:getInstance():resumeBackgroundMusic()
		    	end
		    end,
		    onWindowBackPress = function ()
		    	CommonTip:showTip("onWindowBackPress")
		    	self:close()
		    end
		})
		videoPlayerLogic:setDelegate(defaultDelegate)
	end

end

function VideoPlayer:close( ... )
	if __ANDROID then
		local VideoPlayerManager = luajava.bindClass("com.happyelements.video.player.VideoPlayerManager")
		VideoPlayerManager:getInstance():closeVideoPlayer()
	end
end

return VideoPlayer