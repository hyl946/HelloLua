IllegalWordFilterUtil = {}

-- illegalwords.txt 有两份，android版本的在assets目录下，打包时copy进去
-- 非android平台的在resource/extensions目录下,直接读取

-- 打在包里的文件(路径形如apk:/)，在安卓平台上不能用 fopen fin io.open 等标准函数读取。因为apk是个压缩文件，不是一个文件夹，不能根据路径直接读。
-- 应该用CCFileUtils、或AssetManager读

local instance
local wordsFilter
function IllegalWordFilterUtil.getInstance()
	if not instance then
		instance = IllegalWordFilterUtil
		if __ANDROID then -- 词库在apk包中
			wordsFilter = luajava.bindClass("com.happyelements.android.utils.IllegalWordFilter"):getInstance()
			
			local filePath = CCFileUtils:sharedFileUtils():fullPathForFilename("extensions/illegalwords.txt")

			if filePath:match("^apk:/") then
				filePath = filePath:sub(6)
				wordsFilter:loadWordsWithAssetsFile(filePath)
			else
				wordsFilter:loadWordsWithFullPath(filePath)
			end
			-- if _G.isLocalDevelopMode then printx(0, "filePath:", filePath) end
		else
			instance.illegalwordsLibPath = CCFileUtils:sharedFileUtils():fullPathForFilename("extensions/illegalwords.txt")
		end
	end
	return instance
end

function IllegalWordFilterUtil:isIllegalWord(word)
	if not word or type(word) ~= "string" then return false end

	if __ANDROID then 
		if not wordsFilter then return false end
		return wordsFilter:isIllegalWord(word)
	else
		local function isIllegalWord(word)
			return HeDisplayUtil:isIllegalWord(instance.illegalwordsLibPath, word)
		end
		local succ, ret = pcall(isIllegalWord, word)
		return succ and ret or false
	end
	return false
end

return IllegalWordFilterUtil