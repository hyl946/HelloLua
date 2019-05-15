_G.__showHomeSceneCacheRef = 0
_G.homescene_last_freetexture_list = {}


function HomeScene_freeUnuseInGameTextureMinSize(minSize)
	if _G.isLocalDevelopMode then printx(0, "Free Texture MinSize ...") end

	_textureLib.hideMinSize(minSize)
	_textureLib.incGlobalTexUsingTicket()
end

function HomeScene_restoreUnuseInGameTexture(onlyPaint, excepts)
	if _G.isLocalDevelopMode then printx(0, "Restore Texture ... all") end

	if onlyPaint == nil then
		onlyPaint = true
	end
	if excepts == nil then
		excepts = {}
	end
	_textureLib.rollback(onlyPaint, excepts)

	_G.homescene_last_freetexture_list = table.filter(_G.homescene_last_freetexture_list or {}, function ( item )
		return table.exist(excepts, item)
	end)
end

function HomeScene_freeUnuseInGameTexture(additionalBlackList)
	if _G.isLocalDevelopMode then printx(0, "Free Texture ...") end

	local blist = {}

	if additionalBlackList then
		blist = table.union(blist, additionalBlackList)
	end

	_G.homescene_last_freetexture_list = blist
	_textureLib.hide(blist)
	_textureLib.incGlobalTexUsingTicket()
end

