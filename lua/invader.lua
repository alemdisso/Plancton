invaderList = {}
invaderListRemove = {}

Invader = {}

InvaderBuilder = createClass(Invader, Updatable, Drawable)


function Invader:new()

	invaderList[#invaderList+1] = self

	self.signature="invader"
	self:loadImages()
	self:loadSounds()
	self:calculatePosition()
	self:engageInFormation()
	return self
end


function Invader:destroy()
	self.active = false
	invaderListRemove[#invaderListRemove+1] = self
end



function Invader:draw()

	love.graphics.draw(self.img, self.pos.x, self.pos.y)

end

function Invader:update(dt)

	local delayToShoot = self.delayToShoot
	local allowedToShoot = false

	if self.delayToShoot <= 0  then

		if self:allowedToShoot() then
			self:shoot()
		end

		--print ("wave# " .. #waveList .. " min " .. self.unitType.minDelay .. " max " .. self.unitType.maxDelay .. " speed " .. self.wave.speedX)

		self.delayToShoot = math.random(self.unitType.minDelay, self.unitType.maxDelay)

	else

		self.delayToShoot = self.delayToShoot - dt

	end

end

function Invader:allowedToShoot()

	local haveFriendsAhead = self:haveFriendsAhead()
	local haltShooting = self:haltShooting()
	local allowedToShoot = false

	if not haveFriendsAhead and not haltShooting then
		allowedToShoot = true
	end

	return allowedToShoot

end

function Invader:haveFriendsAhead()

	local line = self.line
	local haveFriendsAhead = true
	local myColumnSpearHead = self.wave.spearHeads[self.column]
	if line == myColumnSpearHead then
		haveFriendsAhead = false
	end

	return haveFriendsAhead

end

function Invader:haltShooting()

	local wave = self.wave
	local haltShooting = false

	if wave.haltCommand == true then
		haltShooting = true
	end

	return haltShooting

end

function Invader:shoot()
			BulletBuilder:new(
						{
							shooter=self,
							}
						)
			self.shotSound:stop()
			self.shotSound:play()
end

function Invader:loadImages()

	local imgArray = {}
	local imgSourceArray = self.imgSourceArray
	local indexImgArray = 1

	for i = 1, #imgSourceArray do
		imgArray[i] = love.graphics.newImage(imgSourceArray[i])
	end

	self.imgArray = imgArray
	self.img = self.imgArray[indexImgArray]
	self.indexImgArray = indexImgArray

	self.width = self.img:getWidth()
	self.height = self.img:getHeight()

end


function Invader:loadSounds()

	self.shotSound = self:loadBulletSound()
	self.deathSound = self:loadDeathSound()

end

function Invader:loadBulletSound()

	local filePath = invaderConstants.INVADER_BULLET_SOUND
	local volume = invaderConstants.INVADER_BULLET_SOUND_VOLUME
	local pitch = invaderConstants.INVADER_BULLET_SOUND_PITCH
	local sound = self:loadSound(filePath, volume, pitch)

	return sound

end

function Invader:loadDeathSound()

	local filePath = invaderConstants.INVADER_DEATH_SOUND
	local volume = invaderConstants.INVADER_DEATH_SOUND_VOLUME
	local pitch = invaderConstants.INVADER_DEATH_SOUND_PITCH
	local sound = self:loadSound(filePath, volume, pitch)

	return sound

end


function Invader:loadSound(filePath, volume, pitch)

	local sound = love.audio.newSource(filePath, static)
	sound:setVolume(volume)
	sound:setPitch(pitch)
	return sound

end

function Invader:calculatePosition()

	self.wCanvas = game.wCanvas
	self.hCanvas = game.hCanvas

	local invaderW = self.wave.width + waveConstants.WAVE_SPACE_BETWEEN_COLUMNS
	local invaderH = self.height +  waveConstants.WAVE_SPACE_BETWEEN_LINES
	local invaderX = self.wave.pos.x + ((self.column - 1) * invaderW) + (self.wave.width - self.width)/2
	local invaderY = self.wave.pos.y + ((self.line - 1) * invaderH)
	invaderX = math.ceil(invaderX)
	invaderY = math.ceil(invaderY)
	self.pos = {x=invaderX, y=invaderY, z=3}
	self.lastX = self.pos.x
	self.lastY = self.pos.y

end


function Invader:engageInFormation()

	self.timesHitted = 0
	local wave = self.wave or false

	if wave then
		wave.formation[self.line][self.column] = true
	end

	self.delayToShoot = math.random(waveConstants.WAVE_MIN_DELAY, waveConstants.WAVE_MAX_DELAY)
	self.active = true
	self.wave = wave

end


function Invader:collide(obstacle)

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
				game:addPointsToScore(self.unitType.pts)
				InvaderBuilder:destroy(self)
			end

		end
	end
end


function Invader:move(forX, forY)

	local c = self
	local forX = forX or c.pos.x
	local forY = forY or c.pos.y

	local marginLeft, marginRight = waveConstants.WAVE_INITIAL_X, 12

	local leftLimit = marginLeft
	local rightLimit = (c.wCanvas - c.width - marginRight)
	local bottomLimit = (c.hCanvas - c.height - marginRight)

	if forX < leftLimit then
		c.pos.x = leftLimit
	elseif forX > rightLimit then
		c.pos.x = rightLimit
	else
		c.pos.x = forX
	end

	if forY > bottomLimit then
		c.pos.y = bottomLimit
	else
		c.pos.y = forY
	end

	local distanceWalked = math.abs(self.lastX - self.pos.x)
	local distanceAdvanced = math.abs(self.lastY - self.pos.y)

	if distanceWalked > self.width/2  or distanceAdvanced > 0 then
		self.indexImgArray = self.indexImgArray + 1
		if self.indexImgArray > #self.imgArray then self.indexImgArray = 1 end
		local img = self.imgArray[self.indexImgArray]
		self.img = img
		self.lastX = self.pos.x
		self.lastY = self.pos.y
	end

end

