
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
			local introImages = self.introImages
			local playImage = game.images.play
			local xPlay = introConstants.INTRO_PLAY_BUTTON_COORD.x
			local yPlay = introConstants.INTRO_PLAY_BUTTON_COORD.y
			local x,y = love.mouse.getPosition()
			if x >= xPlay and x <= xPlay + playImage:getWidth()
				and y >= yPlay and y <= yPlay + playImage:getHeight() then
				game.state = gameConstants.GAME_PLAY_KEYBOARD
			end
		end
	end
end

function Intro:loadImages()

	local introImages = {
		["title"] = {img={}, x=0, y=0,},
		["play"] = {img={}, x=0, y=0,},
		["mouse"] = {img={}, x=0, y=0,},
		}

	introImages.play.img = game.images.play
	introImages.play.x = introConstants.INTRO_PLAY_BUTTON_COORD.x
	introImages.play.y = introConstants.INTRO_PLAY_BUTTON_COORD.y

	return introImages
end

