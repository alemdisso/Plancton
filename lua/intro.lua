
introList = {}
introListRemove = {}

Intro = {}

IntroBuilder = createClass(Intro, Updatable, Drawable)


function Intro:new()
	introList[#introList+1] = self

	self:initCounterAndStep()

	local myCounter = CounterBuilder:new()
	myCounter:time(introConstants.INTRO_DELAY_TO_SHOW_1ST_UNIT)

	myCounter:start()

	self.show1stUnitCounter = myCounter

	self.currentStep = 0

	self:initLines()


	local xTitle = (game.wCanvas - introConstants.INTRO_TITLE_COORD.w) / 2
	local xUnits = xTitle + 100
	local xPts = xUnits + 40
	self.xUnits = xUnits
	self.xPts = xPts

	local lines = {
		data1stUnit = {
			unit= {
				step = 1,
				x=xUnits,
				y=180,
				showFunction = function(x,y) self:show1stUnit(x,y) end,
			},
			pts={
				step=2,
				x=xPts,
				y=189,
				showFunction = function(x,y) self:show1stUnitPts(x,y) end,
			}
		},
		data2ndUnit = {
			unit= {
				step = 3,
				x=xUnits,
				y=230,
				showFunction = function(x,y) self:show2ndUnit(x,y) end,
			},
			pts={
				step=4,
				x=xPts,
				y=239,
				showFunction = function(x,y) self:show2ndUnitPts(x,y) end,
			}
		},
		data3rdUnit = {
			unit= {
				step = 5,
				x=xUnits,
				y=280,
				showFunction = function(x,y) self:show3rdUnit(x,y) end,
			},
			pts={
				step=6,
				x=xPts,
				y=289,
				showFunction = function(x,y) self:show3rdUnitPts(x,y) end,
			}
		},
		dataSpaceshipUnit = {
			unit= {
				step = 7,
				x=xUnits,
				y=330,
				showFunction = function(x,y) self:showSpaceshipUnit(x,y) end,
			},
			pts={
				step=8,
				x=xPts,
				y=335,
				showFunction = function(x,y) self:showSpaceshipUnitPts(x,y) end,
			}
		},
	}

	self.lines = lines

	return self
end


function Intro:destroy()
	self.active = false
	introListRemove[#introListRemove+1] = self
end

function Intro:draw()

end

function Intro:update(dt)
	local counter = self.show1stUnitCounter
	counter:update(dt)

	if game.state == gameConstants.GAME_INTRO then
		if love.mouse.isDown("l") then
			self:checkForClickOnPlayButton()
		end
	end
end

function Intro:initCounterAndStep()

	local myCounter = CounterBuilder:new()
	myCounter:time(introConstants.INTRO_DELAY_TO_SHOW_1ST_UNIT)

	myCounter:start()

	self.show1stUnitCounter = myCounter

	self.currentStep = 0
end


function Intro:initLines()


end



function Intro:checkForClickOnPlayButton()

	local playImage = game.images.play
	local xPlay = introConstants.INTRO_PLAY_BUTTON_COORD.x
	local yPlay = introConstants.INTRO_PLAY_BUTTON_COORD.y
	local x,y = love.mouse.getPosition()
	local w = playImage:getWidth()
	local h = playImage:getHeight()

	if x >= xPlay and x <= xPlay + w
		and y >= yPlay and y <= yPlay + h then
		game.state = gameConstants.GAME_PLAY_KEYBOARD
	end

end

function Intro:showTitle()
	local xTitle = (game.wCanvas - introConstants.INTRO_TITLE_COORD.w) / 2
	love.graphics.draw(game.images.title, xTitle, 32)

end

function Intro:showPlayButton()
	local xTitle = (game.wCanvas - introConstants.INTRO_TITLE_COORD.w) / 2
	local xPlay = (game.wCanvas - introConstants.INTRO_PLAY_COORD.w) / 2
	love.graphics.draw(game.images.play, xTitle, game.hCanvas - 80)
end

function Intro:showUnitsAndPoints()

	local xTitle = (game.wCanvas - introConstants.INTRO_TITLE_COORD.w) / 2
	local stepIntro = 0.6
	local xUnits = xTitle + 100
	local xPts = xUnits + 40

	local timeCounter = self.show1stUnitCounter
	local currentTime = timeCounter:time()
	local remainder = (currentTime % stepIntro)
	local whichStep = math.floor(currentTime /stepIntro)
	self.xUnits = xUnits
	self.xPts = xPts

	self.currentStep = whichStep

	self:show1stUnitLine()
	self:show2ndUnitLine()
	self:show3rdUnitLine()
	self:showSpaceshipLine()

end

function Intro:show1stUnitLine()
	self:showLine(self.lines.data1stUnit)
end

function Intro:show1stUnit(x,y)
	love.graphics.draw(game.images.unitC, x, y)
end

function Intro:show1stUnitPts(x,y)
	love.graphics.draw(game.images.unitCPts, x, y)

end

function Intro:show2ndUnitLine()
	self:showLine(self.lines.data2ndUnit)
end

function Intro:show2ndUnit(x,y)
	love.graphics.draw(game.images.unitB, x, y)
end

function Intro:show2ndUnitPts(x,y)
	love.graphics.draw(game.images.unitBPts, x, y)
end

function Intro:show3rdUnitLine()
	self:showLine(self.lines.data3rdUnit)
end

function Intro:show3rdUnit(x,y)
	love.graphics.draw(game.images.unitA, x, y)

end

function Intro:show3rdUnitPts(x,y)
	love.graphics.draw(game.images.unitAPts, x, y)
end

function Intro:showSpaceshipLine()
	self:showLine(self.lines.dataSpaceshipUnit)
end

function Intro:showSpaceship(x,y)
	love.graphics.draw(game.images.spaceship, x, y)
end

function Intro:showSpaceshipPts(x,y)
	love.graphics.draw(game.images.spaceshipPts, x, y)

end

function Intro:showLine(lineData)

	local currentStep = self.currentStep
	local unitStep = lineData.unit.step
	local ptsStep = lineData.pts.step

	if (currentStep >= unitStep) then
		local showFunction = lineData.unit.showFunction
		showFunction(lineData.unit.x,lineData.unit.y)
		if (currentStep>= ptsStep) then
			local showFunction = lineData.pts.showFunction
			showFunction(lineData.pts.x,lineData.pts.y)
		end
	end
end
