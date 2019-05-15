VivoPlatform = {}

function VivoPlatform:onStart()
	if not __ANDROID then return end

	local function onGameStart()
		local VivoSocialPlatform = luajava.bindClass("com.happyelements.android.platform.vivo.VivoSocialPlatform")
		if VivoSocialPlatform then
			VivoSocialPlatform:onGameStart()
			self.isStart = true
		end
	end
	pcall(onGameStart)
end

function VivoPlatform:onEnd()
	if not __ANDROID then return end

	local function onGameEnd()
		local VivoSocialPlatform = luajava.bindClass("com.happyelements.android.platform.vivo.VivoSocialPlatform")
		if VivoSocialPlatform then
			VivoSocialPlatform:onGameEnd()
		end
	end
	if self.isStart == true then
		pcall(onGameEnd)
	end
end