function love.conf(t)
  t.identity = "touch test"
  t.window.title = "touch test"
  t.window.icon = "/icon.png"
  t.version = "11.5"
  t.window.fullscreen = true
  t.window.resizable = true

  t.modules.physics = false
end
