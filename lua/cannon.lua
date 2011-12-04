require ("lua.class")
require ("lua.drawable")
require ("lua.updatable")

cannonList = {}
cannonListRemove = {}

Cannon = {}

CannonBuilder = createClass(Cannon, Updatable, Drawable)



function Cannon:new()

	cannonList[#cannonList+1] = self

	self.signature="cannon"
	self.active=true

	local imgArray = {}
	local imgSourceArray = self:getImages()

	self:setMovementParameters()

	self:manageKeyboard()

	self:manageWeaponry()

--[[
	self.delayToShoot = 0
	self.fireDelay = cannonConstants.CANNON_INTERVAL_FIRE
	self.missileFired = nil
	self.readyToShoot = true
	self.exploding = false

	self.bullets = {}
	--self.bulletImgSource = self:loadBulletImage()

	local shotSound = love.audio.newSource("resources/audio/cannonshot.wav", static)
	shotSound:setVolume(0.4)
	shotSound:setPitch(1)
	self.shotSound = shotSound

	local deathSound = love.audio.newSource("resources/audio/cannondeath.wav", static)
	deathSound:setVolume(1)
	deathSound:setPitch(1)


	self.deathSound = deathSound
]]

	self:manageParticles()

	--particles


	return self
end



function Cannon:destroy()
	self.active = false
	cannonListRemove[#cannonListRemove+1] = self


end


function Cannon:update(dt)


	if not self.exploding then
		local new_x = self.pos.x
		local new_y = self.pos.y

		if game.state == gameConstants.GAME_PLAY_KEYBOARD then
			if love.keyboard.isDown(self.keys.right) then
				new_x = self.pos.x + self.speed*dt
			elseif love.keyboard.isDown(self.keys.left) then
				new_x = self.pos.x - self.speed*dt
			end
		elseif game.state == gameConstants.GAME_PLAY_MOUSE then
			local x,y = love.mouse.getPosition()

			if x > (self.pos.x + self.width) then
				new_x = self.pos.x + self.speed*dt
			elseif x < self.pos.x then
				new_x = self.pos.x - self.speed*dt
			end
		end

		if self.delayToShoot > 0 then
			self.delayToShoot = self.delayToShoot - dt
			--print ("delay... " .. self.delayToShoot)
		else
			self.readyToShoot = true
		end

		self:move(new_x, new_y)

	else
		self.part:setPosition(self.pos.x, self.pos.y)
		self.part:update(dt)
		if self.part:isEmpty() then
			print ("end of explosion")
			self.part:reset()
			CannonBuilder:destroy(self)
		end
	end



end


function Cannon:draw()

	if not self.exploding then
		love.graphics.draw(self.img, self.pos.x, self.pos.y, 0, 1, 1, 0, 0)

	else
		love.graphics.setColorMode("modulate")
		love.graphics.setBlendMode("additive")
		love.graphics.draw(self.part, self.width/2, self.height/2)
	end

end

function Cannon:setMovementParameters()

	local wCanvas = love.graphics.getWidth()
	local hCanvas = love.graphics.getHeight()

	local marginLeft, marginRight = gameConstants.GAME_LEFT_MARGIN, gameConstants.GAME_RIGHT_MARGIN

	local leftLimit = marginLeft
	local rightLimit = (wCanvas - self.width - marginRight)

	self.wCanvas = wCanvas
	self.hCanvas = hCanvas

	self.pos = {x=(wCanvas - self.width)/ 2, y=hCanvas-self.height-8, z=3}
	self.leftLimit = leftLimit
	self.rightLimit = rightLimit
	self.speed = 250


end

function Cannon:manageKeyboard()

	self.keys={}

	self.keys.right="right"
	self.keys.left="left"
	self.keys.up="up"
	self.keys.down="down"
	self.keys.fire=" "

end

function Cannon:manageWeaponry()

	self.delayToShoot = 0
	self.fireDelay = cannonConstants.CANNON_INTERVAL_FIRE
	self.missileFired = nil
	self.readyToShoot = true
	self.exploding = false

	self.bullets = {}

	self.shotSound = game.sounds.cannonShot
	self.deathSound = game.sounds.cannonDeath

end

function Cannon:manageParticles()

	local partimg = love.graphics.newImage("resources/images/part.png")
	self.part = love.graphics.newParticleSystem(partimg, 200)

	self.part:setEmissionRate(1000) -- 1000
	self.part:setSpeed(0, 120) -- 0, 120
	self.part:setSize(0.3, 0.7, 0.9) --0.3, 0.7, 0.9
	self.part:setSizeVariation(0.9)  --0.9
	self.part:setColor(170, 190, 30, 255, 144, 165, 28, 0)
	self.part:setLifetime(0.2) --0.2
	self.part:setParticleLife(1) --1
	self.part:setDirection(3*math.pi/2)
	self.part:setSpread(1*math.pi) -- 1*math.pi
	self.part:setTangentialAcceleration(0)
	self.part:setRadialAcceleration(-7) -- -7
	self.part:stop()

end


function Cannon:move(forX, forY)

	local forX = forX or self.pos.x
	local forY = forY or self.pos.y

	local leftLimit = self.leftLimit
	local rightLimit = self.rightLimit

	if forX < leftLimit then
		self.pos.x = leftLimit
	elseif forX > rightLimit then
		self.pos.x = rightLimit
	else
		self.pos.x = forX
	end

	local x = math.floor((self.pos.x % cannonConstants.CANNON_MOTION_STEPS) + 1)
	self.img = self.imgArray[x]

end

function Cannon:fire()

end


function Cannon:death()

	self.deathSound:stop()
	self.deathSound:play()

	self.exploding = true
	self.part:start()

end

function Cannon:collide(obstacle)

	if obstacle.signature == "invader" then
		game.state = gameConstants.GAME_OVER
	end

	self:death()
end


function Cannon:shoot()

	if self.active then
		if self.readyToShoot then
			local newBullet = BulletBuilder:new(
								{
									shooter=self,
									}
								)
			self.delayToShoot = self.fireDelay
			self.readyToShoot = false
			self.shotSound:stop()
			self.shotSound:play()
		end
	end

end


function Cannon:getImages()

	self.imgArray = game.images.cannon
	self.img = self.imgArray[1]

	self.width = self.img:getWidth()
	self.height = self.img:getHeight()

end
