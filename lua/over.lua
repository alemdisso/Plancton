require ("lua.counter")

overList = {}
overListRemove = {}

Over = {}

OverBuilder = createClass(Over)


function Over:new()

	overList[#overList+1] = self
	--self.overImages = self:loadImages()
	self:initTimeline()

	return self
end


function Over:destroy()
	self.active = false
	overListRemove[#overListRemove+1] = self
end


function Over:draw()
	if game.state == gameConstants.GAME_OVER then
		self:showPlayAgain()
		self:showGameOver()
	end
end

function Over:update(dt)
	if game.state == gameConstants.GAME_OVER then


		local counter = self.timelineCounter

		if not counter.running then
			counter:start()
		else
			counter:update(dt)
		end

		if love.mouse.isDown("l") then

			local overImages = self.overImages
			local x,y = love.mouse.getPosition()
			if x >= 160 and x <= 400
				and y >= 150 and y <= 300 then

				updatableList = {}
				drawableList = {}
				waveList={}
				invaderList = {}
				cannonList = {}
				shieldList = {}
				blockList = {}
				bulletList={}

				game.score = 0
				game.lives = 3
				game.state = 1

				cannon = CannonBuilder:new()
				shields = game:placeShields()
				wave = WaveBuilder:new(
					{
						numLines = waveConstants.WAVE_LINES,
						numColumns = waveConstants.WAVE_COLUMNS,
					}
				)

				collisionManager = prepareCollisionTables()

			elseif x >= 160 and x <= 400
				and y >= 320 and y <= 500 then

				love.event.push("q")
			end
		end

	end
end

function Over:initTimeline()

	local myCounter = CounterBuilder:new()
	myCounter:time(0)

	self.timelineCounter = myCounter
	self.currentStep = 0
end


function Over:showPlayAgain()
	local xImage = (game.wCanvas - overConstants.OVER_PLAY_AGAIN_COORD.w) / 2
	local yImage = 30 + (game.hCanvas - overConstants.OVER_PLAY_AGAIN_COORD.h) / 2
	love.graphics.draw(game.images.playAgain, xImage, yImage)

end

function Over:showGameOver()

	local letters = game.images.gameOver
	local stepIntro = 0.5
	local timeCounter = self.timelineCounter
	local currentTime = timeCounter:time()
	local step
	local currentStep = self.currentStep

	if currentStep < #letters then
		step = math.floor(currentTime /stepIntro)
	else
		step = #letters
	end
	self.currentStep = step

	local xImage = (game.wCanvas - overConstants.OVER_GAME_OVER_COORD.w) / 2
	local yImage = ((game.hCanvas - overConstants.OVER_GAME_OVER_COORD.h) / 2) -30

	for i = 1, step do
		local letterImage = game.images.gameOver[i]

		love.graphics.draw(letterImage, xImage, yImage)
		xImage = xImage + letterImage:getWidth()
	end

end




