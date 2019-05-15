local function process_lua( filepath, pathGrp)
	package.loaded[filepath] = nil

	local status, msg = xpcall(function ( ... )
		dofile(filepath)
	end , __G__TRACKBACK__)

	if not status then
	    if _G.isLocalDevelopMode then printx(61, msg) end
	end



end

local function __onDragFile(arg)

	local filepath = CCFileUtils:sharedFileUtils():fullPathForFilename(arg)
	local ret = string.split(filepath, '.')
	local ext = ret[#ret]
	if ext == 'png' or ext == 'jpg' then
		Director:sharedDirector():pushScene(AnimationScene:createWithFile(filepath))
		return
	end

	if ext == 'json' then
		
	end


	if ext == 'lua' then
		process_lua(filepath, ret)
	end
end

_G.__onDragFile = __onDragFile
