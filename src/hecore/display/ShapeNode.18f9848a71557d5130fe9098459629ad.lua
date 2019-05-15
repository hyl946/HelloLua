-------------------------------------------------------------------------
--  Class include: ShapeNode, SpriteUtil, Scale9Sprite
-------------------------------------------------------------------------

require "hecore.display.CocosObject"

--
-- ShapeNode ---------------------------------------------------------
--

ShapeNode = class(CocosObject);

function ShapeNode:toString()
	return string.format("ShapeNode [%s]", self.name and self.name or "nil");
end

--
-- public props ---------------------------------------------------------
--
function ShapeNode:getLineWidth() return self.refCocosObj:getLineWidth() end
function ShapeNode:setLineWidth(v) self.refCocosObj:setLineWidth(v) end	

--ccColor4F: [0,1], {ccc4f(0.5,0.5,0.5,1.0)}
function ShapeNode:getColor() return self.refCocosObj:getColor() end
function ShapeNode:setColor(v) self.refCocosObj:setColor(v) end

function ShapeNode:getLineStipple() return self.refCocosObj:getLineStipple() end
function ShapeNode:setLineStipple(v) self.refCocosObj:setLineStipple(v) end

function ShapeNode:isLineStippleEnabled(v) return self.refCocosObj:isLineStippleEnabled(v) end
function ShapeNode:setLineStippleEnabled(v) self.refCocosObj:setLineStippleEnabled(v) end


--
-- CircleShape ---------------------------------------------------------
--

CircleShape = class(ShapeNode);

--
-- public props ---------------------------------------------------------
--
function CircleShape:getRadius() return self.refCocosObj:getRadius() end
function CircleShape:setRadius(v) self.refCocosObj:setRadius(v) end 

function CircleShape:getAngle() return self.refCocosObj:getAngle() end
function CircleShape:setAngle(v) self.refCocosObj:setAngle(v) end 

function CircleShape:getSegments() return self.refCocosObj:getSegments() end
function CircleShape:setSegments(v) self.refCocosObj:setSegments(v) end 

function CircleShape:isDrawLineToCenter() return self.refCocosObj:isDrawLineToCenter() end
function CircleShape:setDrawLineToCenter(v) self.refCocosObj:setDrawLineToCenter(v) end 

--r, g, b, a: [0,255]
function CircleShape:create( radius, r, g, b, a )
  local node = CCCircleShape:create(radius)
  if r ~= nil and g ~= nil and b ~= nil and a ~= nil then node:setColor(ccc4f(r/255, g/255, b/255, a/255))
  else node:setColor(ccc4f(1,1,1,1)) end
  return CircleShape.new(node)
end

--
-- RectShape ---------------------------------------------------------
--

RectShape = class(ShapeNode);

--
-- public props ---------------------------------------------------------
--
--CCSize
function RectShape:getSize() return self.refCocosObj:getSize() end
function RectShape:setSize(v) self.refCocosObj:setSize(v) end 

function RectShape:isFill() return self.refCocosObj:isFill() end
function RectShape:setFill(v) self.refCocosObj:setFill(v) end 

function RectShape:create( size, r, g, b, a )
  local node = CCRectShape:create(size)
  if r ~= nil and g ~= nil and b ~= nil and a ~= nil then node:setColor(ccc4f(r/255, g/255, b/255, a/255))
  else node:setColor(ccc4f(1,1,1,1)) end
  return RectShape.new(node)
end

--
-- PointShape ---------------------------------------------------------
--

PointShape = class(ShapeNode);

--
-- public props ---------------------------------------------------------
--
function PointShape:create( r, g, b, a )
  local node = CCPointShape:create()
  if r ~= nil and g ~= nil and b ~= nil and a ~= nil then node:setColor(ccc4f(r/255, g/255, b/255, a/255))
  else node:setColor(ccc4f(1,1,1,1)) end
  return PointShape.new(node)
end

--
-- PolygonShape ---------------------------------------------------------
--

PolygonShape = class(ShapeNode);

--
-- public props ---------------------------------------------------------
--
function PolygonShape:isClose() return self.refCocosObj:isClose() end
function PolygonShape:setClose(v) self.refCocosObj:setClose(v) end 

function PolygonShape:isFill() return self.refCocosObj:isFill() end
function PolygonShape:setFill(v) self.refCocosObj:setFill(v) end 

--vertices: CCPointsArray
-- a = CCPointsArray:create(3)
-- a:add(ccp(1,1))
function PolygonShape:create( vertices, r, g, b, a )
  local node = CCPolygonShape:create(vertices)
  if r ~= nil and g ~= nil and b ~= nil and a ~= nil then node:setColor(ccc4f(r/255, g/255, b/255, a/255))
  else node:setColor(ccc4f(1,1,1,1)) end
  return PolygonShape.new(node)
end