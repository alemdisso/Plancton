require ("lua.class")
require ("lua.drawable")
require ("lua.updatable")

spaceshipList = {}
spaceshipListRemove = {}

Spaceship = {}

SpaceshipBuilder = createClass(Spaceship, Updatable, Drawable)

function Spaceship:new()

	spaceshipList[#spaceshipList+1] = self

	self.signature="spaceship"
	self.active=true

	--local imgArray = {}
	--local imgSourceArray = self:loadImages()

	self:loadImages()
	local wCanvas = love.graphics.getWidth()
	local hCanvas = love.graphics.getHeight()

	self.wCanvas = wCanvas
	self.hCanvas = hCanvas

	self:setPoints()

	self.timesHitted = 0

	self.delayToPlaySound = 1

	self:chooseDirection()

--[[	local travelSound = love.audio.newSource("resources/audio/spaceshiptravel.wav", static)
	travelSound:setVolume(1)
	travelSound:setPitch(1)
	self.travelSound = travelSound

	local deathSound = love.audio.newSource("resources/audio/spaceshipdeath.wav", static)
	deathSound:setVolume(0.75)
	deathSound:setPitch(0.75)
	self.deathSound = deathSound
]]
	self.travelSound = game.sounds.spaceshipTravel
	self.deathSound = game.sounds.spaceshipDeath

	return self
end

function Spaceship:destroy()
	self.active = false
	spaceshipListRemove[#spaceshipListRemove+1] = self
end

function Spaceship:update(dt)

	local step = self.speed * dt
	if self.active  then

		if not self.showingPoints then

			local delayToPlaySound = self.delayToPlaySound

			if delayToPlaySound < 0 then
				self.travelSound:stop()
				self.travelSound:play()
				delayToPlaySound = 6
			else
				delayToPlaySound = delayToPlaySound - dt
			end

			self.delayToPlaySound = delayToPlaySound

			local posX = self.pos.x
			local posY = self.pos.y
			local newX = posX + step
			self.pos.x = newX

			local direction = self.direction
			local wCanvas = self.wCanvas
			local width = self.width
			if direction == "l" then
				if newX < 0 - width then
					SpaceshipBuilder:destroy(self)
				end
			else
				if newX > self.wCanvas then
					SpaceshipBuilder:destroy(self)
				end
			end
		else
			if self.timerShowPoints > 0 then
				self.timerShowPoints = self.timerShowPoints - dt
			else
				self.showingPoints = false
				self.travelSound:stop()
				SpaceshipBuilder:destroy(self)
			end
		end
	end
end

function Spaceship:draw()
	if not self.showingPoints then
		love.graphics.draw(self.img, self.pos.x, self.pos.y, 0, 1, 1, 0, 0)
	else
		love.graphics.setFont(game	.font)
		love.graphics.setColor(0, 255, 0, 255)
		love.graphics.print(self.pts,self.pos.x, self.pos.y)
		love.graphics.setColor(255, 255, 255, 255)
	end
end

function Spaceship:setPoints()

	local ptsArray = {50, 100, 100, 150, 150, 200, 200, 300}
	local seedPts = math.random(#ptsArray)
	self.pts = ptsArray[seedPts]
	self.showingPoints = false
	self.timerShowPoints = 2


end

function Spaceship:move(forX, forY)

end

function Spaceship:chooseDirection()

	local oddOrEven = math.random(2)
	local wCanvas = self.wCanvas

	if oddOrEven == 1 then
		self.direction="r"
		self.pos = {x=0-self.width, y=45, z=3}
		self.speed = 70
	else
		self.direction="l"
		self.pos = {x=wCanvas + self.width, y=45, z=3}
		self.speed = -70
	end

end


function Spaceship:death()

	self.travelSound:stop()
	self.deathSound:stop()
	self.deathSound:play()

end

function Spaceship:collide(obstacle)

	if not self.showingPoints then

		if obstacle.signature == "bullet" then
			local bullet = obstacle
			if bullet.bulletType ~= "invader" then
				local hitImpact = bullet.hitImpact
				self.deathSound:stop()
				self.deathSound:play()
				local timesHitted = self.timesHitted
				timesHitted = timesHitted + hitImpact
				self.timesHitted = timesHitted

				if (timesHitted >= 1) then
					game:addPointsToScore(self.pts)
					self:showPoints(self.pts)
				end
			end
		end
	end
end


function Spaceship:shoot()


end

function Spaceship:loadImages()

	self.img = game.images.spaceship
	self.width = self.img:getWidth()
	self.height = self.img:getHeight()

end

function Spaceship:showPoints()
	self.showingPoints = true
	self.timerShowPoints = 2
end
