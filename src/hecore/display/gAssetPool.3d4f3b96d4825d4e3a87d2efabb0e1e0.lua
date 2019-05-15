--
-- gAnimatedObject ---------------------------------------------------------
--
local gAssetPool = {}
gAssetPool.library = {}


function gAssetPool:addAssetWithFileName(filename)
	local asset = self.library[filename]
	if(asset == nil) then
		local pkmz = StartupConfig:getInstance():getIsPkmSoftwareMode()
		asset = GAFAsset:create(filename, pkmz, 0);
		asset:retain()
		self.library[filename] = asset
	end

	return asset
end

function gAssetPool:delAssetWithFileName(filename)
	local asset = self.library[filename]
	if(not asset == nil) then
		asset:release()
		self.library[filename] = nil
	end
end


function gAssetPool:delAll()
	for filename, asset in pairs(self.library) do
		asset:release()
	end

	self.library = {}
end


return gAssetPool
