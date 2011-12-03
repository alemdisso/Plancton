
introList = {}
introListRemove = {}

Intro = {}

IntroBuilder = createClass(Intro, Updatable, Drawable)


function Intro:new()
	introList[#introList+1] = self

	self.timeCounter = introConstants.INTRO_DELAY_TO_SHOW_1ST_UNIT

	return self
end


function Intro:destroy()
	self.active = false
	introListRemove[#introListRemove+1] = self
end


function Intro:draw()

end

function Intro:update(dt)
	self.timeCounter = self.timeCounter + dt
	if game.state == gameConstants.GAME_INTRO then
		if love.mouse.isDown("l") then
			self:checkForClickOnPlayButton()
		end
	end
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
