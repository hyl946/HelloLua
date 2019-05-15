
_G.PluginConfig = {
	CloseBtn = 'CloseBtn',
	VScroll = 'VScroll',
	Button = 'Button',
	TabPanel = 'TabPanel',
	VBox = 'VBox',
	HBox = 'HBox',
	FBox = 'FBox',
	CenterHBox = 'CenterHBox',
	RewardItem = 'RewardItem',
	Mask = 'Mask',
	Page = 'Page',
	HScroll = 'HScroll',
}

function PluginConfig:loadPlugin( pluginName )
	if PluginConfig[pluginName] then
		return require('zoo.quarterlyRankRace.plugins.' .. PluginConfig[pluginName])
	end
end

function PluginConfig:getPluginName( path )
	local s, e = string.find(path, '@')
	if s and e then
		return string.sub(path, e + 1, -1)
	end
end