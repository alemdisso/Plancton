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

	self:initCanvasAndImages()
	self:initPointsAndHits()
	self:initSound()
	self:chooseDirection()

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
			self:manageSound(dt)
			self:move(step)
		else
			self:manageShowingPointsAndDestroy(dt)
		end
	end
end

function Spaceship:draw()
	if not self.showingPoints then
		love.graphics.draw(self.img, self.pos.x, self.pos.y, 0, 1, 1, 0, 0)
	else
		love.graphics.setFont(game.font)
		love.graphics.setColor(0, 255, 0, 255)
		love.graphics.print(self.pts,self.pos.x, self.pos.y)
		love.graphics.setColor(255, 255, 255, 255)
	end
end

function Spaceship:initCanvasAndImages()

	self:loadImages()

	self.wCanvas = game.wCanvas
	self.hCanvas = game.hCanvas

end

function Spaceship:initPointsAndHits()

	self:setPoints()

	self.timesHitted = 0

end

function Spaceship:setPoints()

	local ptsArray = spaceshipConstants.SPACESHIP_POINTS_ARRAY
	local seedPts = math.random(#ptsArray)
	self.pts = ptsArray[seedPts]
	self.showingPoints = false
	self.timerShowPoints = spaceshipConstants.SPACESHIP_TIME_SHOWING_POINTS
end

function Spaceship:initSound()

	self.delayToPlaySound = spaceshipConstants.SPACESHIP_DELAY_TO_PLAY_SOUND
	self.travelSound = game.sounds.spaceshipTravel
	self.deathSound = game.sounds.spaceshipDeath

end

function Spaceship:manageSound(dt)

	local delayToPlaySound = self.delayToPlaySound

	if delayToPlaySound < 0 then
		self.travelSound:stop()
		self.travelSound:play()
		delayToPlaySound = spaceshipConstants.SPACESHIP_DELAY_TO_PLAY_SOUND
	else
		delayToPlaySound = delayToPlaySound - dt
	end

	self.delayToPlaySound = delayToPlaySound

end

function Spaceship:move(step)

	local posX = self.pos.x
	local posY = self.pos.y
	local newX = posX + step
	self.pos.x = newX

	if self:limitReached() then
		SpaceshipBuilder:destroy(self)
	end

end

function Spaceship:limitReached()

	local newX = self.pos.x
	local direction = self.direction
	local wCanvas = self.wCanvas
	local width = self.width
	local limitReached = false

	if direction == "l" then
		local spaceToBeOut =  0 - width
		if newX < spaceToBeOut then
			limitReached = true
		end
	else
		if newX > wCanvas then
			limitReached = true
		end
	end

	return limitReached

end

function Spaceship:chooseDirection()

	local oddOrEven = math.random(2)
	local wCanvas = self.wCanvas
	local orbit = spaceshipConstants.SPACESHIP_Y_ORBIT
	local speed = spaceshipConstants.SPACESHIP_TRAVEL_SPEED

	if oddOrEven == 1 then
		local initX = 0-self.width
		self.direction="r"
		self.pos = {x=initX, y=orbit, z=3}
		self.speed = speed
	else
		local initX = wCanvas + self.width
		self.direction="l"
		self.pos = {x=initX, y=orbit, z=3}
		self.speed = -speed
	end

end

function Spaceship:manageShowingPointsAndDestroy(dt)

	if self.timerShowPoints > 0 then
		self.timerShowPoints = self.timerShowPoints - dt
	else
		self.showingPoints = false
		self.travelSound:stop()
		SpaceshipBuilder:destroy(self)
	end


end


function Spaceship:dealWithImpact(bullet)

	local hitImpact = bullet.hitImpact
	local timesHitted = self.timesHitted

	timesHitted = timesHitted + hitImpact
	self.timesHitted = timesHitted

	if (timesHitted >= 1) then
		self:death()
	end

end

function Spaceship:death()
	self.travelSound:stop()
	self.deathSound:stop()
	self.deathSound:play()
	game:addPointsToScore(self.pts)
	self:showPoints(self.pts)

end


function Spaceship:collide(obstacle)

	if not self.showingPoints then

		if obstacle.signature == "bullet" then
			local bullet = obstacle
			if bullet.bulletType ~= "invader" then
				self:dealWithImpact(bullet)
			end
		end
	end
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
