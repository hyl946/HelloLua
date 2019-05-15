--------------------------------------------
--测试Scene
--------------------------------------------
require "hecore.display.CocosObject"
require "hecore.display.Director"
require "hecore.ui.LayoutBuilder"
require "hecore.ui.Button"
require "hecore.ui.PopoutManager"
require "hecore.display.Sprite"
--panel
require "zoo.panel.PackageShopPanel"
require "zoo.panel.GiftingPanel"
--login and data
require "zoo.net.Http"
require "zoo.data.UserManager"

require "zoo.scenes.HomeScene"
require "zoo.scenes.GamePlayScene"
require "zoo.scenes.AnimationScene"
require "zoo.scenes.GameChoiceScene"

require "zoo.data.LevelMapManager"
require "zoo.data.MetaManager"
require "zoo.data.UserManager"
require "zoo.util.BigInt"
require "zoo.config.NetworkConfig"

require "zoo.config.LevelConfig"
-- require "zoo.gamePlay.GameBoardLogic"
require "zoo.gamePlay.GameBoardView"

require "zoo.util.ResUtils"

TestScene = class(Scene)
local visibleSize = CCDirector:sharedDirector():getVisibleSize();

function TestScene:ctor()
    self.targetInfoPanel = nil
	self.title = "Test Scene"
end

function TestScene:create()
  local s = TestScene.new()
  s:initScene()
  return s
end

function TestScene:login()
	local function onConnectionError( evt )
		evt.target:removeAllEventListeners()
		if _G.isLocalDevelopMode then printx(0, "Login Error!") end
	end
	local function onLoginFinish( evt )
		evt.target:removeAllEventListeners()
		if _G.isLocalDevelopMode then printx(0, "Login Completed!") end

        local function PreLoadAnimal()
            local time1 = os.clock()
            local items = {"bear","fox", "horse", "frog", "cat", "chicken"}
            for i,v in ipairs(items) do
                local preloadSprite = TileCharacter:create(v)
            end
            TileBird:create()

            local time2 = os.clock()
            if _G.isLocalDevelopMode then printx(0, "PreLoadAnimal time ", time2 - time1) end
        end
        
        PreLoadAnimal()

		SpriteUtil:addSpriteFramesWithFile("materials/animal_item.plist", "materials/animal_item.png")
        local levelId = 3

        local levelconfig = LevelDataManager.sharedLevelData():getLevelConfigByID(levelId);
        self.mygameboardlogic = GameBoardLogic:create();
        self.mygameboardlogic:initByConfig(levelId, levelconfig);

        --获取处理完之后的map，进行view的初始化
        self.mygameboardview = GameBoardView:createByGameBoardLogic(self.mygameboardlogic);
        self:addChild(self.mygameboardview)        
        
        -- local scene = GamePlayScene:create(levelId)
		-- Director:sharedDirector():pushScene(scene)
        --Director:sharedDirector():replaceScene(GameChoiceScene:create())
	end 

	local logic = LoginLogic.new()
	logic:addEventListener(Events.kComplete, onLoginFinish)
	logic:addEventListener(Events.kError, onConnectionError)
	logic:execute()
end

--游戏棋盘测试
function TestScene:onInit__()

	LevelMapManager.getInstance():initialize()
	MetaManager.getInstance():initialize()
	self:login()
    --[[
    local urls = {"http://img0.bdstatic.com/img/image/417d31b0ef41bd5ad6edcdb82d583cb39dbb6fd3cea.jpg"}    
    local function onCallBack(data)        
        local sprite = Sprite:create( data["realPath"] )
        sprite:setPosition(ccp(360,640))
        sprite:setScale(4)
        self:addChild(sprite)
    end
    ResUtils:getResFromUrls(urls,onCallBack)
    ]]
end

function TestScene:onInit()
    local game_bg = Sprite:create("flash/scenes/game/game_bg.png")
    game_bg:setPosition(ccp(visibleSize.width/2,visibleSize.height/2))
    self:addChild(game_bg)
    
    local tree_bg = Sprite:create("flash/scenes/game/tree_bg.png")
    tree_bg:setPosition(ccp(350,230))
    self:addChild(tree_bg)   
    
    local propUI = self:createPropList()
    propUI:setPosition(ccp(0,200))
    self:addChild(propUI)   
    propUI:reloadData()
end

function TestScene:createPropList( )
    --点击事件
    local function onListItemTouch(e) 
    end
    
    local PropCell = class(TableViewRenderer)
    function PropCell:ctor(width, height)
        for i=1,6 do
            self.list[i] = i
        end
    end
    function PropCell:buildCell(container)
        local layer = Layer:create()
        container:addChild(layer)
        layer:setTag(1024)
    end    
    function PropCell:setData( rawCocosObj, index )
        local cellLayer = self:getChildByTag(rawCocosObj,1024)
        cellLayer:removeAllChildrenWithCleanup(true)       
        local builder = LayoutBuilder:createWithContentsOfFile("flash/scenes/game/GamePlaySceneUI.json")
        local propUI = builder:build("bubble_item") 
		propUI:setPosition(ccp(0,165))
        cellLayer:addChild(propUI.refCocosObj)		
    end
    
    local renderer = PropCell.new(165, 165)
    local prop = TableView:create(renderer, 720, 165)
    prop:setDirection(kCCScrollViewDirectionHorizontal)
    prop:setPageEnabled(true)
    prop:addEventListener(DisplayEvents.kTouchItem, onListItemTouch , self)  
	return prop    
end

function TestScene:test()
    local game_bg = Sprite:create("flash/scenes/game/game_bg.png")
	local builder = LayoutBuilder:createWithContentsOfFile("flash/scenes/game/GameUIScene.json")
    self.mainUI = builder:build("gameWnd")
    self.mainUI:setPosition(ccp(0,visibleSize.height))
    game_bg:setPosition(ccp(visibleSize.width/2,visibleSize.height/2))
    self:addChild(game_bg)
    self:addChild(self.mainUI) 

    local function getFlipToFrontAction(timeInterval, angle, ...)
        local halfAngle = angle / 2
        local cameraAction1 = CCOrbitCamera:create(timeInterval, 1, 0, -halfAngle, halfAngle, 90, 0 )
        local easeElasticOut1	= CCEaseElasticOut:create(cameraAction1)
        
        local cameraAction2 = CCOrbitCamera:create(timeInterval, 1, 0, -halfAngle, halfAngle, 90, 0 )
        local easeElasticOut2	= CCEaseElasticOut:create(cameraAction2)
        local spawn = CCSpawn:createWithTwoActions(easeElasticOut1, easeElasticOut2)
        return spawn
    end        
    
    local props = self.mainUI:getChildByName("propsBar"):getChildByName("props_item5")
    local propAction = getFlipToFrontAction(6.5,90)
    
    props:runAction(propAction)
    
end

function TestScene:testPackageAndShop()

    local bg = Sprite:create("flash/scenes/shop/bg.jpg")
    bg:setPosition(ccp(visibleSize.width/2,visibleSize.height/2))
    self:addChild(bg)
    local btn_shop = Sprite:create("flash/scenes/shop/btn_shop.png") 
    btn_shop:setPosition(ccp(visibleSize.width*(1/3),50))
    local shop_button = Button:create(btn_shop)

    local btn_gift = Sprite:create("flash/scenes/gift/test_gift.png") 
    btn_gift:setPosition(ccp(visibleSize.width*(2/3),50))
    local gift_button = Button:create(btn_gift)
    
    local function onClickShop(e)
        self.targetInfoPanel = PackageShopPanel:create( self )
        PopoutManager:sharedInstance():add(self.targetInfoPanel, true, false , self)        
    end
    shop_button:addEventListener(Events.kStart,onClickShop)

    local function onClickGift(e)
        self.targetInfoPanel = GiftingPanel:create( self )
        PopoutManager:sharedInstance():add(self.targetInfoPanel, true, false ,self)        
    end
    gift_button:addEventListener(Events.kStart,onClickGift)    
    self:addChild(btn_shop)
    self:addChild(btn_gift)
    --login test
	local function onConnectionError( evt )
		evt.target:removeAllEventListeners()
		if _G.isLocalDevelopMode then printx(0, "Login Error!") end
	end
	local function onLoginFinish( evt )
		evt.target:removeAllEventListeners()
		if _G.isLocalDevelopMode then printx(0, "Login Completed!") end
        --if _G.isLocalDevelopMode then printx(0, table.tostring(UserManager.getInstance().props)) end
        --get meta infomation
        local function onGetMetaFinish(e)
            e.target:removeAllEventListeners()
            if _G.isLocalDevelopMode then printx(0, "getMeta ok!") end
            if _G.isLocalDevelopMode then printx(0, table.tostring(e)) end
        end
        local function onGetMetaError(e)
            e.target:removeAllEventListeners()
            if _G.isLocalDevelopMode then printx(0, "getMeta error!") end
        end
        local meta = getMeta.new()
        meta:addEventListener(Events.kComplete, onGetMetaFinish)
        meta:addEventListener(Events.kError, onGetMetaError)
        meta:load()
	end 
	local login = LoginLogic.new()
	login:addEventListener(Events.kComplete, onLoginFinish)
	login:addEventListener(Events.kError, onConnectionError)
	login:execute()
end

function TestScene:dispose()
  Scene.dispose(self)
end

