Power = Class{}

function Power:init(power_charges, wave_speed)
    self.POWERS = {}
    self.power_charges = power_charges
    self.wave_speed = wave_speed
end

function Power:spawn(x, y)
    if self.power_charges > 0 then
        self.power_charges = self.power_charges - 1
        table.insert(self.POWERS, {x = x, y = y, r = 10})
    end
end

function Power:update(dt)
    -- increase wave radius by the second
    for i, v in ipairs(self.POWERS) do
        v.r = v.r + (self.wave_speed * dt)

        -- check if wave has become too big
        if v.r > VIRTUAL_WIDTH + 15 then
            table.remove(self.POWERS, i)
        end
    end
end

function Power:render()
    for i, v in ipairs(self.POWERS) do
        love.graphics.setColor(0.5, 1, 0, 1)
        love.graphics.circle('line', v.x, v.y, v.r)
    end
end

function Power:HUDrender()
    -- square
    love.graphics.setColor(1, 1, 1, power_timer / 2)
    love.graphics.rectangle('fill', 10, 20, 20, 20)

    -- text
    if power_timer >= 2 then
        love.graphics.setColor(0, 0, 0, 1)
        love.graphics.setFont(largeFont)
        love.graphics.printf("Q", -195, 22, VIRTUAL_WIDTH, 'center')
    end
end