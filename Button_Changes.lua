--
-- New button functions
--


RF.open.hooks._select_blind = G.FUNCS.select_blind
RF.open.hooks.new_select_blind = function(e)
   for k, _ in pairs(G.GAME.round_resets.blind_states) do
      G.GAME.round_resets.blind_states[k] = 'Upcoming'
   end
   G.GAME.blind_on_deck = e.config.blind_type
   if e.config.blind_type == 'Roaming' or e.config.blind_type == 'Roaming2' then
      local blind_info = RF.open._get_new_roaming(e.config.blind_type == 'Roaming2')
      e.config.ref_table = G.P_BLINDS[blind_info]
   elseif e.config.blind_type == 'Boss' then
      G.GAME.RFOD_SETTINGS.shop_cost = 5
   end
   G.GAME.round_resets.blind_states[G.GAME.blind_on_deck] = 'Current'
   RF.open.hooks._select_blind(e)
end
G.FUNCS.select_blind = RF.open.hooks.new_select_blind

function RF.open._get_new_roaming(roam2)
   local temp_perscribed_bosses = G.GAME.perscribed_bosses
   local temp_FORCE_BOSS = G.FORCE_BOSS
   local temp_ante = G.GAME.round_resets.ante
   G.GAME.perscribed_bosses = nil
   G.FORCE_BOSS = nil
   if roam2 then
      G.GAME.round_resets.ante = G.GAME.round_resets.ante + G.GAME.RFOD_SETTINGS.roaming2_attempts
   else
      G.GAME.round_resets.ante = G.GAME.round_resets.ante + G.GAME.RFOD_SETTINGS.roaming_attempts
   end
   local boss = get_new_boss()
   G.GAME.perscribed_bosses = temp_perscribed_bosses
   G.FORCE_BOSS = temp_FORCE_BOSS
   G.GAME.round_resets.ante = temp_ante
   return boss
end

G.FUNCS.enter_shop = function(e)
   if G.GAME.RFOD_SETTINGS.shop_cost > G.GAME.dollars - G.GAME.bankrupt_at then return false end
   G.GAME.current_round.used_packs = nil
   stop_use()
   if G.blind_select then
      G.GAME.facing_blind = true
      G.blind_prompt_box:get_UIE_by_ID('prompt_dynatext1').config.object.pop_delay = 0
      G.blind_prompt_box:get_UIE_by_ID('prompt_dynatext1').config.object:pop_out(5)
      G.blind_prompt_box:get_UIE_by_ID('prompt_dynatext2').config.object.pop_delay = 0
      G.blind_prompt_box:get_UIE_by_ID('prompt_dynatext2').config.object:pop_out(5)
      ease_dollars(-G.GAME.RFOD_SETTINGS.shop_cost)

      G.E_MANAGER:add_event(Event({
         trigger = 'before',
         delay = 0.2,
         func = function()
            G.blind_prompt_box.alignment.offset.y = -10
            G.blind_select.alignment.offset.y = 40
            G.blind_select.alignment.offset.x = 0
            G.extra_blind_options.alignment.offset.x = 75
            return true
         end
      }))
   end
   G.E_MANAGER:add_event(Event({
      trigger = 'immediate',
      func = function()
         G.GAME.RFOD_SETTINGS.shop_cost = 5 + G.GAME.RFOD_SETTINGS.shop_cost
         RF.open.dynamic_values.shop_text = localize('$') .. G.GAME.RFOD_SETTINGS.shop_cost
         G.STATE_COMPLETE = false
         G.STATE = G.STATES.SHOP
         return true
      end
   }))
end

G.FUNCS.can_enter_shop = function(e)
   if G.GAME.RFOD_SETTINGS.shop_cost > G.GAME.dollars - G.GAME.bankrupt_at then
      e.config.colour = G.C.UI.BACKGROUND_INACTIVE
      local config = e.config
      if config.button then
         G.E_MANAGER:add_event(Event({
            trigger = 'immediate',
            func = function()
               config.button = nil
               return true
            end
         }))
      end
   else
      e.config.colour = G.C.GOLD
      e.config.button = 'enter_shop'
   end
end

RF.open.hooks._skip_blind = G.FUNCS.skip_blind
RF.open.hooks.new_skip_blind = function(e)
   if G.GAME.RFOD_SETTINGS.skip_cost > G.GAME.dollars - G.GAME.bankrupt_at then return false end
   local _tag = e.UIBox:get_UIE_by_ID('tag_container')
   if _tag then
      ease_dollars(-G.GAME.RFOD_SETTINGS.skip_cost)
      G.GAME.RFOD_SETTINGS.skip_cost = 10 + G.GAME.RFOD_SETTINGS.skip_cost
      RF.open.dynamic_values.skip_text = localize('$') .. G.GAME.RFOD_SETTINGS.skip_cost
      RF.open.hooks._skip_blind(e)
      G.GAME.round_resets.blind_tags.Big = get_next_tag_key()
      local new_tag = Tag(G.GAME.round_resets.blind_tags['Big'], nil, 'Big')
      local new_tag_ui, new_tag_sprite = new_tag:generate_UI()
      _tag.config.ref_table = new_tag
      local tag_Big = e.UIBox:get_UIE_by_ID('tag_Big')
      tag_Big.config.ref_table = new_tag_sprite
      local tag_desc = e.UIBox:get_UIE_by_ID('tag_desc')
      tag_desc.children = {UIBox{
         definition = {n=G.UIT.ROOT, config={align = "cm",padding = 0.05, colour = G.C.CLEAR}, nodes={
            new_tag_ui
         }},
         config = {parent = tag_desc, align = "cm", offset = {x=0, y=0}}
      }}
      local skip_blind_button = e.UIBox:get_UIE_by_ID('skip_blind_button')
      skip_blind_button.config.ref_table = new_tag
   end
end
G.FUNCS.skip_blind = RF.open.hooks.new_skip_blind


G.FUNCS.can_skip_blind = function(e)
   if G.GAME.RFOD_SETTINGS.skip_cost > G.GAME.dollars - G.GAME.bankrupt_at then
      e.config.colour = G.C.UI.BACKGROUND_INACTIVE
      local config = e.config
      if config.button then
         G.E_MANAGER:add_event(Event({
            trigger = 'immediate',
            func = function()
               config.button = nil
               return true
            end
         }))
      end
   else
      e.config.colour = G.C.GOLD
      e.config.button = 'skip_blind'
   end
end

function RF.open._get_reward_tag()
   local _tag = G.round_eval:get_UIE_by_ID('reward_tag_blind1')
   if _tag then
      local _tag = G.round_eval:get_UIE_by_ID('reward_tag_blind1')
      add_tag(_tag.config.ref2_table)
   end

   local _bonus = G.round_eval:get_UIE_by_ID('dollar_row_boss_bonus_blind1')
   if _bonus then
      if _bonus.config.key == 'e_negative' then
         G.jokers.config.card_limit = G.jokers.config.card_limit + 1
      else
         G.consumeables.config.card_limit = G.consumeables.config.card_limit + 1
      end
      --G.GAME.RFOD_SETTINGS.small_attempts = 0
      --G.GAME.RFOD_SETTINGS.big_attempts = 0
      --G.GAME.RFOD_SETTINGS.skip_cost = 10
   end
end
