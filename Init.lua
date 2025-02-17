if not RF then RF = {} end

RF.open = {
   hooks = {},
   metatable = {},
   ui_range = { options = {min = nil, max = nil}, time = 0, speed = 5, cache = nil, cache_formatted = nil },
   ui_range2 = { options = {min = nil, max = nil}, time = 0, speed = 5, cache = nil, cache_formatted = nil },
   dynamic_values = {skip_text = "$10"}
}

RF.open.metatable.__index = function(tbl, key)
   if key == 'display_value' or key == 'display_value2' then
      local curr = love.timer.getTime()
      local ui_data = key == 'display_value' and RF.open.ui_range or RF.open.ui_range2
      if curr > ui_data.time + 1 / ui_data.speed then
         ui_data.time = curr

         local index = math.random(#ui_data.options)
         local attempts = 3
         while ui_data.cache == ui_data.options[index] and attempts > 0 do
            attempts = attempts - 1
            index = math.random(#ui_data.options)
         end

         ui_data.cache = ui_data.options[index]
         G.E_SWITCH_POINT = G.E_SWITCH_POINT or 100000000000
         local switch_point = G.E_SWITCH_POINT
         if ui_data.options.max > G.E_SWITCH_POINT then
            switch_point = ui_data.options.min - 1
         end
         ui_data.cache_formatted = number_format(ui_data.cache, switch_point)
      end
      return ui_data.cache_formatted
   end
   return nil
end
setmetatable(RF.open, RF.open.metatable)

RF.open._init_GAME_settings = function()
   G.GAME.RFOD_SETTINGS = G.GAME.RFOD_SETTINGS or {}
   G.GAME.RFOD_SETTINGS.shop_cost = G.GAME.RFOD_SETTINGS.shop_cost or 5
   G.GAME.RFOD_SETTINGS.skip_cost = G.GAME.RFOD_SETTINGS.skip_cost or 10
   G.GAME.RFOD_SETTINGS.small_attempts = G.GAME.RFOD_SETTINGS.small_attempts or 0
   G.GAME.RFOD_SETTINGS.big_attempts = G.GAME.RFOD_SETTINGS.big_attempts or 0
   G.GAME.RFOD_SETTINGS.roaming_attempts = G.GAME.RFOD_SETTINGS.roaming_attempts or 1
   G.GAME.RFOD_SETTINGS.roaming2_attempts = G.GAME.RFOD_SETTINGS.roaming2_attempts or 2
end
