if not RF then RF = {} end

RF.open = {
   hooks = {},
   metatable = {},
   ui_range = { options = {min = nil, max = nil}, time = 0, speed = 5, cache = nil, cache_formatted = nil },
   dynamic_values = {skip_text = "$10"}
}

RF.open.metatable.__index = function(tbl, key)
   if key == 'display_value' then
      local curr = love.timer.getTime()
      if curr > RF.open.ui_range.time + 1 / RF.open.ui_range.speed then
         RF.open.ui_range.time = curr

         local index = math.random(#RF.open.ui_range.options)
         local attempts = 3
         while RF.open.ui_range.cache == RF.open.ui_range.options[index] and attempts > 0 do
            attempts = attempts - 1
            index = math.random(#RF.open.ui_range.options)
         end

         RF.open.ui_range.cache = RF.open.ui_range.options[index]
         G.E_SWITCH_POINT = G.E_SWITCH_POINT or 100000000000
         local switch_point = G.E_SWITCH_POINT
         if RF.open.ui_range.options.max > G.E_SWITCH_POINT then
            switch_point = RF.open.ui_range.options.min - 1
         end
         RF.open.ui_range.cache_formatted = number_format(RF.open.ui_range.cache, switch_point)
      end
      return RF.open.ui_range.cache_formatted
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
   G.GAME.RFOD_SETTINGS.roaming_attempts = G.GAME.RFOD_SETTINGS.roaming_attempts or 0
end
