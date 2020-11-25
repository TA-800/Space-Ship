Enemy = Class{}

math.randomseed(os.time())

function Enemy:init()
    self.ENEMIES = {}
end

function Enemy:spawn(x, length, r1, r3)
    -- inserting object into table
    table.insert(self.ENEMIES, {x = x, y = 0 - length, dy = ENEMY_SPEED, length = length, r1 = r1, r3 = r3})
    -- r1 = 1 then square
    -- r1 = 2 then circle
end

-- updating enemies to come down the screen
function Enemy:update(dt)

    -- updating every enemy object in table
    for i, v in ipairs(self.ENEMIES) do
        v.y = v.y + (v.dy * dt)

        -- deleting enemy if it goes offscreen
        if v.y > VIRTUAL_HEIGHT + v.length then
            table.remove(self.ENEMIES, i)
        end
    end

end

-- render enemies/meterorites
function Enemy:render()
    for i, v in ipairs(self.ENEMIES) do
        love.graphics.setColor(1, 1, 1, 1)
        -- for square
        if v.r1 == 1 then
            -- for normal square
            if v.r3 == 2 then
                love.graphics.rectangle('fill', v.x, v.y, v.length, v.length)
            -- for rotated square
            else
                -- same as love.graphics.rectangle but created a new function for adding rotation
                rotateEnemy('fill', v.x, v.y, v.length, v.length, math.sin(45))
            end
        -- for circle
        else
            love.graphics.circle('fill', v.x, v.y, v.length)
        end
    end
end

-- reference from
-- https://love2d.org/forums/viewtopic.php?t=77310
function rotateEnemy( mode, x, y, w, h, a, ox, oy )
	-- if no ox or oy provided, rotation is around upper left corner
	-- if ox, oy = w/2, h/2 then rotation is around rectangle's center
	-- if no angle provided, no rotation
	ox = ox or 0
	oy = oy or 0
	a = a or 0
	love.graphics.push()
	love.graphics.translate(x, y)
	love.graphics.rotate(a)
	love.graphics.rectangle(mode,-ox, -oy, w, h)
	love.graphics.pop()
end