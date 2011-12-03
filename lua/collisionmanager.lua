require "lua.updatable"

CollisionManager =
{
	collisionTables = {}
}

CollisionManagerBuilder = createClass(CollisionManager, Updatable)

function CollisionManager:addCollisionTables(firstSet, secondSet)
	table.insert(self.collisionTables, {firstSet=firstSet, secondSet=secondSet})
end

function CollisionManager:update()
	for i=1,#self.collisionTables do
		for j=1,#self.collisionTables[i].firstSet do

			local firstObject = self.collisionTables[i].firstSet[j]

			for k=1,#self.collisionTables[i].secondSet do

				local secondObject = self.collisionTables[i].secondSet[k]


				if not (firstObject.pos.x >= secondObject.pos.x + secondObject.img:getWidth() or
				   firstObject.pos.y >= secondObject.pos.y + secondObject.img:getHeight() or
				   secondObject.pos.x >= firstObject.pos.x + firstObject.img:getWidth() or
				   secondObject.pos.y >= firstObject.pos.y + firstObject.img:getHeight())
				then
					--print("collide")
					if firstObject.collide ~= nil then firstObject:collide(secondObject) end
					if secondObject.collide ~= nil then secondObject:collide(firstObject) end
				end
			end
		end
	end
end















function CollisionManager:updateWhenIAsk()
	for i=1,#self.collisionTables do
		for j=1,#self.collisionTables[i].firstSet do

			local firstObject = self.collisionTables[i].firstSet[j]
				--print (firstObject.signature .. ": " .. firstObject.pos.x .. " " .. firstObject.pos.y .. " " .. firstObject.img:getWidth() .. " " .. firstObject.img:getHeight())

			for k=1,#self.collisionTables[i].secondSet do

				local secondObject = self.collisionTables[i].secondSet[k]
				if secondObject.signature == "invaderBullet" then

					print (secondObject.signature .. ": " .. secondObject.pos.x .. " " .. secondObject.pos.y .. " " .. secondObject.img:getWidth() .. " " .. secondObject.img:getHeight())
				end

				if not (firstObject.pos.x >= secondObject.pos.x + secondObject.img:getWidth() or
				   firstObject.pos.y >= secondObject.pos.y + secondObject.img:getHeight() or
				   secondObject.pos.x >= firstObject.pos.x + firstObject.img:getWidth() or
				   secondObject.pos.y >= firstObject.pos.y + firstObject.img:getHeight())
				then
					print("collide")
					if firstObject.collide ~= nil then firstObject:collide(secondObject) end
					if secondObject.collide ~= nil then secondObject:collide(firstObject) end
				end




			end
		end
	end
end
