Bullet = Class{}

function Bullet:init()
    self.BULLETS = {}
end

-- when bullet has to be spawned or fired from the ship
function Bullet:fire(x, y)
    table.insert(self.BULLETS, {x = x, y = y, dy = BULLET_SPEED, length = 2})
end

function Bullet:update(dt)
    -- updating bullet to go to top of screen
    for i, v in ipairs(self.BULLETS) do
        v.y = v.y - (v.dy * dt)
    
        -- deleting bullet if it goes offscreen
        if v.y < 0 then
            table.remove(self.BULLETS, i)
        end
    end
end


-- render bullets
function Bullet:render()
    for i, v in ipairs(self.BULLETS) do
        love.graphics.setColor(0.5, 1, 0, 1)
        love.graphics.rectangle('fill', v.x, v.y, v.length, v.length)
        love.graphics.setColor(0.5, 1, 0, 0.75)
        love.graphics.rectangle('fill', v.x, v.y + v.length, v.length, v.length)
        love.graphics.setColor(0.5, 1, 0, 0.5)
        love.graphics.rectangle('fill', v.x, v.y + (v.length * 2), v.length, v.length)
    end
end

function Bullet:muzzleFlashRender()
    -- a muzzle flash color
    love.graphics.setColor(249/255, 207/255, 87/255, 1)
    -- horizontal flash
    love.graphics.ellipse('fill', Player.x + Player.width / 2, Player.y - 4, 4, 1)

    love.graphics.setColor(249/255, 207/255, 87/255, 1)
    -- vertical flash
    love.graphics.ellipse('fill', Player.x + Player.width / 2, Player.y - 6, 1, 3)
end