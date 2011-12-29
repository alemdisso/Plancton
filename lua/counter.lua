require ("lua.class")
require ("lua.updatable")

counterList = {}
counterListRemove = {}

Counter = {}

CounterBuilder = createClass(Counter, Updatable)


function Counter:new()


	local countMode = self.countMode or "up"
	local currentTime = self.currentTime   or 0
	local goalTime = self.goalTime   or 0
	local reachedGoal = self.reachedGoal   or false
	local timeToCount = self.timeToCount   or 0
	local running = self.running   or false

	counterList[#counterList+1] = self

	self.signature="counter"

	self.countMode = countMode
	self.currentTime = currentTime
	self.goalTime = goalTime
	self.reachedGoal = reachedGoal
	self.timeToCount = timeToCount
	self.running = running

	self.active = true

	return self
end

function Counter:destroy()
	self.active = false
	counterListRemove[#counterListRemove+1] = self
end


function Counter:update(dt)

	local running = self.running

	if running == true then
		local currentTime = self.currentTime
		local countMode = self.countMode
		local goalTime = self.goalTime

		if countMode == "up" then
			currentTime = currentTime + dt
			if currentTime >= goalTime then
				self:alarm()
			end

		elseif countMode == "down" then
			currentTime = currentTime - dt
			if currentTime <= goalTime then
				self:alarm()
			end
		end
		self.currentTime = currentTime
	end



end

function Counter:start()
	self.running = true
end


function Counter:stop()
	self.running = false
end


function Counter:reset()
	self.currentTime = self.timeToCount
	self.reachedGoal = false

end


function Counter:time(timeToCount)

	if type(timeToCount) == "number" then
		self.timeToCount = timeToCount
		self.currentTime = timeToCount
	end

	return self.currentTime

end

function Counter:direction(countMode)

	if type(countMode) == "up" or type(countMode) == "down" then
		self.countMode = countMode
		if type(countMode) == "up" then
			self.currentTime = 0
			self.goalTime = self.timeToCount

		else
			self.currentTime = self.timeToCount
			self.goalTime = 0
		end

		self.reachedGoal = false
	end

	return self.timeToCount

end

function Counter:alarm()
	self.reachedGoal = true


end

