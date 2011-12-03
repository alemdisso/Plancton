require ("lua.class")
require ("lua.drawable")
require ("lua.updatable")

bulletList = {}
bulletListRemove = {}

Bullet = {}

BulletBuilder = createClass(Bullet, Updatable, Drawable)


function Bullet:new()

	bulletList[#bulletList+1] = self

	self.signature="bullet"

	local shooter = self.shooter

	--local imgSource
	self.imgSource = self:loadBulletImage()
	img = love.graphics.newImage(self.imgSource)

	--self.imgSource = imgSource
	self.img = img

	self.width = self.img:getWidth()
	self.height = self.img:getHeight()

	local wCanvas = love.graphics.getWidth()
	local hCanvas = love.graphics.getHeight()

	self.wCanvas = wCanvas
	self.hCanvas = hCanvas


	if shooter.signature == "cannon" then
		self.bulletType = "cannon"
		self.directionY = -225
		self.pos = {x=shooter.pos.x + (math.floor(shooter.width/2)) - (math.floor(self.width/2)), y=shooter.pos.y - self.height - 1, z= 10,}
		self.hitImpact = cannonConstants.CANNON_BULLET_HIT_IMPACT

	elseif shooter.signature == "invader" then
		self.directionY = 150
		self.bulletType = "invader"
		self.pos = {x=shooter.pos.x + (math.floor(shooter.width/2)) - (math.floor(self.width/2)), y=shooter.pos.y + self.height - 1, z= 10,}
		self.hitImpact = cannonConstants.INVADER_BULLET_HIT_IMPACT
	end


	self.directionX = 0

	self.active = true


	return self
end

function Bullet:destroy()
	self.active = false
	bulletListRemove[#bulletListRemove+1] = self
end


function Bullet:update(dt)
	self.pos.x = self.pos.x + self.directionX*dt
	self.pos.y = self.pos.y + self.directionY*dt

	if not self:isOnScreen() then
		BulletBuilder:destroy(self)
	end
end

function Bullet:collide(obstacle)

	local friendlyFire = false

	if obstacle.signature == "invader" and self.bulletType == "invader" then
		friendlyFire = true
	end

	if obstacle.signature == "cannon" and self.bulletType == "cannon" then
		friendlyFire = true
	end

	if not friendlyFire then
		BulletBuilder:destroy(self)
	end

end


function Bullet:testCollision(obstaclesSet)

	for k=1,#obstaclesSet do
		local obstacle = obstaclesSet[k]

		if not (self.pos.x >= obstacle.pos.x + obstacle.img:getWidth() or
		   self.pos.y >= obstacle.pos.y + obstacle.img:getHeight() or
		   obstacle.pos.x >= self.pos.x + self.img:getWidth() or
		   obstacle.pos.y >= self.pos.y + self.img:getHeight())
		then
			if self.collide ~= nil then self:collide(obstacle) end
			if obstacle.collide ~= nil then obstacle:collide(self) end
			break
		end
	end
end

function Bullet:loadBulletImage()

	local shooter = self.shooter
	local bulletRegion
	local bulletImgSource
	local spriteBatch = self.spriteBatch

	if shooter.signature == "cannon" then
		bulletRegion = RegionClass.new(220, 0, 3, 10)
	elseif shooter.signature == "invader" then
		bulletRegion = RegionClass.new(225, 0, 3, 10)
	end

	bulletImgSource = game.spriteBatch:cutRegionIntoImage(bulletRegion)

	local img = love.graphics.newImage(bulletImgSource)

	--self.imgSource = imgSource
	self.img = img

	self.width = self.img:getWidth()
	self.height = self.img:getHeight()

	return bulletImgSource


end
