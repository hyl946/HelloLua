require "hecore.display.MultiLineTextField"
require "zoo.panel.ShowLogPanel"
require "zoo.UIConfigManager"

 -------------------------
-- Create Notification Node
-- -------------------------

if not __WP8 then
    local notificationLayer = Layer:create()
    CCDirector:sharedDirector():setNotificationNode(notificationLayer.refCocosObj)
    notificationLayer:dispose()
end