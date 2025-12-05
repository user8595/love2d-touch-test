local touches = love.touch.getTouches()
local wWidth, wHeight = love.graphics.getWidth(), love.graphics.getHeight()
local circRad = 20 * 1.5
local textYOff = 0
local tCCol = { 1, 1, 1, 0.5 }
local trailObj, trailCount = {}, 0
local exitCount, exitTime = -1, 0
local next = next
local osGet = love.system.getOS()
local tableClear = require("table.clear")

function love.load()
  if osGet == "Android" or osGet == "iOS" then
    love.window.setMode(720, 1280, { resizable = false })
  end

  love.mouse.setVisible(false)

  love.graphics.setLineStyle("rough")
  fonts = {
    love.graphics.setNewFont("/monogram.ttf", 22)
  }
  textYOff = fonts[1]:getHeight()

  touchCount, maxTouches = 0, 0
  textInfo = {}
  table.insert(textInfo, { "press anywhere to show touches", 0, 1 })
end

function love.mousepressed(x, y, b, isTouch)
  if b == 1 and not isTouch then
    tableClear(textInfo)
    table.insert(textInfo, { "touchscreen is only supported", 0, 1 })
  end
end

function love.keypressed(k)
  if k == "escape" then
    if exitCount == -1 then
      exitCount = 0
      tableClear(textInfo)
      if osGet == "Android" or osGet == "iOS" then
        table.insert(textInfo, { "press back to exit", 0, 1 })
      else
        table.insert(textInfo, { "press escape to exit", 0, 1 })
      end
    else
      exitCount = exitCount + 1
    end
  end

  if osGet ~= "Android" or osGet ~= "iOS" then
    if k == "f11" then
      if not love.window.getFullscreen() then
        love.window.setFullscreen(true)
      else
        love.window.setFullscreen(false)
      end
    end
  end
end

function love.resize(w, h)
  wWidth, wHeight = w, h
end

function love.update(dt)
  wWidth, wHeight = love.graphics.getWidth(), love.graphics.getHeight()
  touches = love.touch.getTouches()

  if exitCount == 0 then
    exitTime = exitTime + dt
  elseif exitCount >= 1 then
    love.event.quit(0)
  end

  if touchCount == 0 then
    tCCol = { 1, 1, 1, 0.5 }
  else
    if touchCount % 2 == 0 then
      tCCol = { 0.5, 0.6, 0.9, 1 }
    elseif touchCount % 3 == 0 then
      tCCol = { 0.5, 0.9, 0.7, 1 }
    else
      tCCol = { 1, 0.75, 0.5, 1 }
    end
  end

  if exitTime > 2.25 then
    exitCount = -1
    exitTime = 0
  end

  for i, id in ipairs(touches) do
    local x, y = love.touch.getPosition(id)
    if next(touches) ~= nil then
      table.insert(trailObj, { x = x, y = y, alpha = 0.15, id = i })
    end
    touchCount = i
    if touchCount > maxTouches then
      maxTouches = touchCount
    end
  end

  for i, trl in ipairs(trailObj) do
    -- trl.alpha = trl.alpha - dt * 0.44
    trl.alpha = trl.alpha - dt * 0.55
    trailCount = i
    if trl.alpha < 0 then
      table.remove(trailObj, i)
    end
  end

  if next(trailObj) == nil then
    trailCount = 0
  end

  if next(touches) == nil then
    touchCount = 0
  end

  for i, txt in ipairs(textInfo) do
    txt[2] = txt[2] + dt
    if txt[2] > 2.25 then
      txt[3] = txt[3] - dt
    end

    if next(touches) ~= nil then
      txt[2] = 3
      exitTime = 0
      exitCount = -1
    end

    if txt[3] < 0 then
      table.remove(textInfo, i)
    end
  end
end

function love.draw()
  love.graphics.setColor(1, 1, 1, 1)
  for _, trl in ipairs(trailObj) do
    if trl.id % 2 == 0 then
      love.graphics.setColor(0.5, 0.6, 0.9, trl.alpha)
    elseif trl.id % 3 == 0 then
      love.graphics.setColor(0.5, 0.9, 0.7, trl.alpha)
    else
      love.graphics.setColor(1, 0.75, 0.5, trl.alpha)
    end
    love.graphics.circle("line", trl.x, trl.y, circRad + 10)
    love.graphics.circle("fill", trl.x, trl.y, circRad)
  end

  love.graphics.setColor(1, 1, 1, 1)
  for i, id in ipairs(touches) do
    local x, y = love.touch.getPosition(id)
    if i % 2 == 0 then
      love.graphics.setColor(0.5, 0.6, 0.9)
    elseif i % 3 == 0 then
      love.graphics.setColor(0.5, 0.9, 0.7)
    else
      love.graphics.setColor(1, 0.75, 0.5)
    end
    love.graphics.line(0, y, wWidth, y)
    love.graphics.line(x, 0, x, wHeight)
    love.graphics.circle("line", x, y, circRad + 10)
    love.graphics.circle("fill", x, y, circRad)
    love.graphics.setColor(1, 1, 1)
    if i % 2 == 0 then
      love.graphics.printf({ { 1, 1, 1, 0.5 }, math.floor(x) .. ", " .. math.floor(y), { 0.5, 0.6, 0.9, 1 }, " #" .. i },
        fonts[1], 0, 20 + textYOff * (i - 1), love.graphics.getWidth() - 20, "right")
    elseif i % 3 == 0 then
      love.graphics.printf({ { 1, 1, 1, 0.5 }, math.floor(x) .. ", " .. math.floor(y), { 0.5, 0.9, 0.7, 1 }, " #" .. i },
        fonts[1], 0, 20 + textYOff * (i - 1), love.graphics.getWidth() - 20, "right")
    else
      love.graphics.printf({ { 1, 1, 1, 0.5 }, math.floor(x) .. ", " .. math.floor(y), { 1, 0.75, 0.5, 1 }, " #" .. i },
        fonts[1], 0, 20 + textYOff * (i - 1), love.graphics.getWidth() - 20, "right")
    end
  end

  for i, txt in ipairs(textInfo) do
    love.graphics.setColor(1, 1, 1, txt[3])
    love.graphics.printf(txt[1], fonts[1], 0, wHeight - 60 - textYOff * (i - 1), wWidth, "center")
  end
  love.graphics.setColor(1, 1, 1)
  love.graphics.print({ tCCol,
      touchCount, { 1, 1, 1, 0.5 },
      " presses (max " ..
      maxTouches .. ")\n" .. love.timer.getFPS() .. " FPS\n" .. wWidth .. "x" .. wHeight .. "\n" .. trailCount },
    fonts[1],
    20,
    20)
end
