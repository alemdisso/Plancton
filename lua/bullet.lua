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

	self.bulletType = shooter.signature

	if self.bulletType == "invader" then
		self:initInvaderBullet()
	elseif self.bulletType == "cannon" then
		self:initCannonBullet()
	end

	self.active = true

	return self
end

function Bullet:destroy()
	self.active = false
	bulletListRemove[#bulletListRemove+1] = self
end


function Bullet:update(dt)
	self.pos.x = self.pos.x + self.speedX*dt
	self.pos.y = self.pos.y + self.speedY*dt

	if not self:isOnScreen() then
		BulletBuilder:destroy(self)
	end

	self:doTheMotion()


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

function Bullet:initInvaderBullet()
	local shooter = self.shooter

	self:chooseInvaderBulletType()
	self:loadInvaderBulletImages()

	self.bulletType = "invader"
	self.hitImpact = cannonConstants.INVADER_BULLET_HIT_IMPACT

	self.pos = {x=shooter.pos.x + (math.floor(shooter.width/2)) - (math.floor(self.width/2)), y=shooter.pos.y + self.height - 1, z= 10,}
	self.directionX = 0
	self.speedX = 0
	self.lastY = self.pos.y


end

function Bullet:initCannonBullet()

	local shooter = self.shooter

	self.bulletType = "cannon"
	self.hitImpact = cannonConstants.CANNON_BULLET_HIT_IMPACT

	self:loadCannonBulletImages()

	self.directionY = -1
	self.speedY = 225  * self.directionY
	self.pos = {x=shooter.pos.x + (math.floor(shooter.width/2)) - (math.floor(self.width/2)), y=shooter.pos.y - self.height - 1, z= 10,}
	self.directionX = 0
	self.speedX = 0
	self.lastY = self.pos.y

end


function Bullet:chooseInvaderBulletType()

		local bulletTypesArray = invaderConstants.INVADER_BULLETS_ARRAY
		local seedType = math.random(#bulletTypesArray)

		self.bulletTypeIndex = seedType
		self.directionY = 1

		local bulletSpeedArray = invaderConstants.INVADER_BULLETS_SPEED_ARRAY
		local seedSpeed = math.random(#bulletSpeedArray)
		local speedY = bulletSpeedArray[seedSpeed]
		self.speedY = speedY * self.directionY
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

function Bullet:loadCannonBulletImages()

	local imgArray
	local indexImgArray = 1

	imgArray = game.images.cannonBullet
	self.img = imgArray[indexImgArray]
	self.howManySteps = 1
	self.imgArray = imgArray

	self.width = self.img:getWidth()
	self.height = self.img:getHeight()

	self.stepMotionIndex = 1

end

function Bullet:loadInvaderBulletImages()

	local imgArray
	local indexImgArray = 1

	local seedType = self.bulletTypeIndex
	local bulletTypesArray = invaderConstants.INVADER_BULLETS_ARRAY

	indexImgArray = bulletTypesArray[seedType]
	imgArray = {}

	local howManySteps = invaderConstants.INVADER_BULLET_MOTION_STEPS
	for i=1, howManySteps do
		imgArray[i] = game.images.invaderBullet[(indexImgArray -1) * 2 + i ]
	end

	self.imgArray = imgArray
	self.img = imgArray[1]

	self.width = self.img:getWidth()
	self.height = self.img:getHeight()

	self.stepMotionIndex = 1

end

function Bullet:doTheMotion()

	local distanceTravelled = math.abs(self.lastY - self.pos.y)

	if distanceTravelled > self.height  then
		self.stepMotionIndex = self.stepMotionIndex + 1
		if self.stepMotionIndex > #self.imgArray then self.stepMotionIndex = 1 end

		local img = self.imgArray[self.stepMotionIndex]
		self.img = img
		self.lastX = self.pos.x
		self.lastY = self.pos.y
	end



end
