--
-- All function to hook and modify, or run prior/after
--


function create_UIBox_blind_choice(type, small_view)
   RF.open._init_GAME_settings()
   type = type or 'Small'

   G.GAME.round_resets.blind_ante = G.GAME.round_resets.blind_ante or G.GAME.round_resets.ante
   if not G.GAME.blind_on_deck then
      G.GAME.blind_on_deck = 'Small'
   end


   G.GAME.orbital_choices = G.GAME.orbital_choices or {}
   G.GAME.orbital_choices[G.GAME.round_resets.ante] = G.GAME.orbital_choices[G.GAME.round_resets.ante] or {}

   if not G.GAME.orbital_choices[G.GAME.round_resets.ante][type] then
      local _poker_hands = {}
      for k, v in pairs(G.GAME.hands) do
         if v.visible then _poker_hands[#_poker_hands + 1] = k end
      end

      G.GAME.orbital_choices[G.GAME.round_resets.ante][type] = pseudorandom_element(_poker_hands, pseudoseed('orbital'))
   end

   if type == 'Small' then
      return {
         n = G.UIT.R,
         config = { id = type, align = "tm", func = 'blind_choice_handler', minh = not small_view and 10 or nil, ref_table = { deck = nil, run_info = small_view }, r = 0.1, padding = 0.05 },
         nodes = {
            RF.open._create_Blind_UIBox('Small', small_view),
            {
               n = G.UIT.R,
               config = { id = 'blind_extras', align = "cm" },
               nodes = {
                  {
                     n = G.UIT.R,
                     config = { align = "cm" },
                     nodes = {
                        {
                           n = G.UIT.R,
                           config = { align = 'tm', minh = 0.65 },
                           nodes = {
                              { n = G.UIT.T, config = { text = localize('k_or'), scale = 0.55, colour = G.C.WHITE, shadow = true } },
                           }
                        },
                        RF.open._create_Blind_UIBox('Big', small_view)
                     }
                  },
               }
            }
         }
      }
   elseif type == 'Big' then
      return {
         n = G.UIT.R,
         config = { id = type, align = "tm", func = 'blind_choice_handler', minh = not small_view and 10 or nil, ref_table = { deck = nil, run_info = small_view }, r = 0.1, padding = 0.05 },
         nodes = {
            RF.open._create_Blind_UIBox('Roaming', small_view),
            {
               n = G.UIT.R,
               config = { id = 'blind_extras', align = "cm" },
               nodes = {
                  {
                     n = G.UIT.R,
                     config = { align = "cm" },
                     nodes = {
                        {
                           n = G.UIT.R,
                           config = { align = 'tm', minh = 0.65 },
                           nodes = {
                              { n = G.UIT.T, config = { text = localize('k_or'), scale = 0.55, colour = G.C.WHITE, shadow = true } },
                           }
                        },
                        RF.open._create_Blind_UIBox('Roaming2', small_view)
                     }
                  },
               }
            }
         }
      }
   else
      return {
         n = G.UIT.R,
         config = { id = type, align = "tm", func = 'blind_choice_handler', minh = not small_view and 10 or nil, ref_table = { deck = nil, run_info = small_view }, r = 0.1, padding = 0.05 },
         nodes = {
            RF.open._create_Blind_UIBox('Boss', small_view),
            {
               n = G.UIT.R,
               config = { id = 'blind_extras', align = "cm" },
               nodes = {
                  not small_view and RF.open._create_Ante_Up_notes() or nil,
               }
            }
         }
      }
   end
end

function RF.open._create_Blind_UIBox(type, small_view)
   local blind_choice = {}
   if type ~= 'Roaming' and type ~= 'Roaming2' then
      blind_choice.config = G.P_BLINDS[G.GAME.round_resets.blind_choices[type]]
   else
      blind_choice.config = G.P_BLINDS[G.GAME.round_resets.blind_choices['Boss']]
   end
   if G.GAME.round_resets.blind_states[type] ~= 'Current' then
      G.GAME.round_resets.blind_states[type] = 'Upcoming'
   end

   blind_choice.animation = AnimatedSprite(0, 0, 1.4, 1.4, G.ANIMATION_ATLAS['blind_chips'],
      type ~= 'Roaming' and type ~= 'Roaming2' and blind_choice.config.pos or { x = 0, y = 30 })
   blind_choice.animation:define_draw_steps({
      { shader = 'dissolve', shadow_height = 0.05 },
      { shader = 'dissolve' }
   })
   local stake_sprite = get_stake_sprite(G.GAME.stake or 1, 0.5)
   local blind_state = not small_view and "Select" or G.GAME.round_resets.blind_states[type] or 'Upcoming'
   local blind_colour = G.C.BLACK
   if type == 'Small' or type == 'Big' or type == 'Boss' then
      blind_colour = get_blind_main_colour(type)
   end
   local loc_name = localize('k_unknown')
   local text_table = { localize('k_unknown') }
   local blind_amt = 0
   if type ~= 'Roaming' and type ~= 'Roaming2' then
      loc_name = localize { type = 'name_text', key = blind_choice.config.key, set = 'Blind' }
      text_table = localize { type = 'raw_descriptions', key = blind_choice.config.key, set = 'Blind', vars = { localize(G.GAME.current_round.most_played_poker_hand, 'poker_hands') } }
      blind_amt = G.GAME.starting_params.ante_scaling
      if type == 'Small' then
         local new_mult = blind_choice.config.mult * math.floor(10 * math.pow(1.1, G.GAME.RFOD_SETTINGS.small_attempts)) / 10
         blind_amt = blind_amt * get_blind_amount(1) * new_mult
      elseif type == 'Big' then
         local new_mult = blind_choice.config.mult * math.floor(10 * math.pow(1.1, G.GAME.RFOD_SETTINGS.big_attempts)) / 10
         blind_amt = blind_amt * get_blind_amount(1) * new_mult
      else
         blind_amt = blind_amt * get_blind_amount(G.GAME.round_resets.blind_ante) * blind_choice.config.mult
      end
   else
      local new_ante = type == 'Roaming' and G.GAME.RFOD_SETTINGS.roaming_attempts or G.GAME.RFOD_SETTINGS.roaming2_attempts
      local base = get_blind_amount(new_ante) * G.GAME.starting_params.ante_scaling
      local max = 1
      local min = 10
      local score_options = {}
      for k, v in pairs(G.P_BLINDS) do
         local score = base * v.mult
         score_options[score] = 1 + (score_options[score] or 0)

         if v.mult > max then
            max = v.mult
         end
         if v.mult < min then
            min = v.mult
         end
      end
      blind_amt = base * max

      local ui_data = type == 'Roaming' and RF.open.ui_range or RF.open.ui_range2

      ui_data.options = {}
      ui_data.options.max = base * max
      ui_data.options.min = base * min
      for score, count in pairs(score_options) do
         local new_count = math.floor(math.sqrt(count))
         for i = 1, new_count do
            if type == 'Roaming' then
               table.insert(ui_data.options, score)
            else
               table.insert(ui_data.options, 1, score)
            end
         end
      end
   end
   local _reward = true
   if G.GAME.modifiers.no_blind_reward and G.GAME.modifiers.no_blind_reward[type] then _reward = false end

   local blind_desc_nodes = {}
   for k, v in ipairs(text_table) do
      blind_desc_nodes[#blind_desc_nodes + 1] = {
         n = G.UIT.R,
         config = { align = "cm", maxw = 2.8 },
         nodes = {
            { n = G.UIT.T, config = { text = v or '-', scale = 0.32, colour = G.C.WHITE, shadow = true } }
         }
      }
   end

   local key = type == 'Roaming' and 'e_negative' or 'e_negative_consumable'
   local temp_text = localize { type = 'raw_descriptions', set = 'Edition', vars = { 1 }, key = key }[1]

   local t = {
      n = G.UIT.R,
      config = { align = "cm", colour = mix_colours(G.C.BLACK, G.C.L_BLACK, 0.5), r = 0.1, outline = 1, outline_colour = G.C.L_BLACK },
      nodes = {
         {
            n = G.UIT.R,
            config = { align = "cm", padding = 0.2 },
            nodes = {
               {
                  n = G.UIT.R,
                  config = small_view and
                      {
                         id = 'select_blind_button',
                         align = "cm",
                         ref_table = blind_choice.config,
                         outline_colour =
                             blind_colour,
                         outline = 1,
                         colour = lighten(blind_colour, 0.3),
                         minh = 0.6,
                         minw = 2.7,
                         padding = 0.07,
                         r = 0.1,
                         emboss = 0.08
                      }
                      or
                      {
                         id = 'select_blind_button',
                         align = "cm",
                         ref_table = blind_choice.config,
                         outline_colour = blind_colour,
                         outline = 1,
                         colour = lighten(blind_colour, 0.3),
                         minh = 0.6,
                         minw = 2.7,
                         padding = 0.07,
                         r = 0.1,
                         shadow = true,
                         hover = true,
                         one_press = true,
                         button = 'select_blind',
                         blind_type = type
                      },
                  nodes = { { n = G.UIT.T, config = { text = localize(blind_state, 'blind_states'), scale = 0.45, colour = G.C.UI.TEXT_LIGHT, shadow = true } } }
               }
            }
         },
         {
            n = G.UIT.R,
            config = { id = 'blind_name', align = "cm", padding = 0.07 },
            nodes = {
               {
                  n = G.UIT.R,
                  config = { align = "cm", r = 0.1, outline = 1, outline_colour = blind_colour, colour = darken(blind_colour, 0.3), minw = 2.9, emboss = 0.1, padding = 0.07, line_emboss = 1 },
                  nodes = {
                     { n = G.UIT.O, config = { object = DynaText({ string = loc_name, colours = { G.C.WHITE }, shadow = true, float = true, y_offset = -4, scale = 0.45, maxw = 2.8 }) } },
                  }
               },
            }
         },
         {
            n = G.UIT.R,
            config = { align = "cm", padding = 0.05 },
            nodes = {
               {
                  n = G.UIT.R,
                  config = { id = 'blind_desc', align = "cm", padding = 0.05 },
                  nodes = {
                     {
                        n = G.UIT.R,
                        config = { align = "cm" },
                        nodes = {
                           type == 'Boss' and
                           {
                              n = G.UIT.R,
                              config = { align = "cm", minh = 1.5 },
                              nodes = {
                                 { n = G.UIT.O, config = { object = blind_choice.animation } },
                              }
                           } or nil,
                           type == 'Boss' and text_table[1] and
                           {
                              n = G.UIT.R,
                              config = { align = "cm", minh = 0.2, padding = 0.05, minw = 2.9 },
                              nodes =
                                  blind_desc_nodes
                           } or nil,
                        }
                     },
                     {
                        n = G.UIT.R,
                        config = { align = "cm", r = 0.1, padding = 0.05, minw = 3.1, colour = G.C.BLACK, emboss = 0.05 },
                        nodes = {
                           {
                              n = G.UIT.R,
                              config = { align = "cm", maxw = 3 },
                              nodes = {
                                 { n = G.UIT.T, config = { text = localize('ph_blind_score_at_least'), scale = 0.3, colour = G.C.WHITE, shadow = true } }
                              }
                           },
                           {
                              n = G.UIT.R,
                              config = { align = "cm", minh = 0.6 },
                              nodes = {
                                 { n = G.UIT.O, config = { w = 0.5, h = 0.5, colour = G.C.BLUE, object = stake_sprite, hover = true, can_collide = false } },
                                 { n = G.UIT.B, config = { h = 0.1, w = 0.1 } },
                                 type ~= 'Roaming' and type ~= 'Roaming2' and
                                 { n = G.UIT.T, config = { text = number_format(blind_amt), scale = score_number_scale(0.9, blind_amt), colour = G.C.RED, shadow = true } }
                                 or
                                 { n = G.UIT.T, config = { ref_table = RF.open, ref_value = type == 'Roaming' and 'display_value' or 'display_value2', scale = score_number_scale(0.9, blind_amt), colour = G.C.RED, shadow = true } }
                              }
                           },
                           _reward and {
                              n = G.UIT.R,
                              config = { align = "cm" },
                              nodes = {
                                 { n = G.UIT.T, config = { text = localize('ph_blind_reward'), scale = 0.35, colour = G.C.WHITE, shadow = true } },
                                 { n = G.UIT.T, config = { text = string.rep(localize("$"), blind_choice.config.dollars) .. '+', scale = 0.35, colour = G.C.MONEY, shadow = true } }
                              }
                           } or nil,
                           _reward and (type == 'Roaming' or type == 'Roaming2') and
                           { n = G.UIT.R, config = { align = "cm" }, nodes = { { n = G.UIT.T, config = { text = temp_text, scale = 0.35, colour = G.C.MONEY, shadow = true } } } }
                           or nil
                        }
                     },
                  }
               },
            }
         },
      }
   }
   return t
end

function RF.open._create_Ante_Up_notes()
   local dt1 = DynaText({string = {{string = localize('ph_up_ante_1'), colour = G.C.FILTER}}, colours = {G.C.BLACK}, scale = 0.55, silent = true, pop_delay = 4.5, shadow = true, bump = true, maxw = 3})
   local dt2 = DynaText({string = {{string = "Reset Shop Cost", colour = G.C.WHITE}},colours = {G.C.CHANCE}, scale = 0.35, silent = true, pop_delay = 4.5, shadow = true, maxw = 3})
   local dt3 = DynaText({string = {{string = "Reset Skip Cost", colour = G.C.WHITE}},colours = {G.C.CHANCE}, scale = 0.35, silent = true, pop_delay = 4.5, shadow = true, maxw = 3})
   local extras = {n=G.UIT.R, config={align = "cm"}, nodes={
       {n=G.UIT.R, config={align = "cm", padding = 0.07, r = 0.1, colour = {0,0,0,0.12}, minw = 2.9}, nodes={
         {n=G.UIT.R, config={align = "cm"}, nodes={
           {n=G.UIT.O, config={object = dt1}},
         }},
         {n=G.UIT.R, config={align = "cm"}, nodes={
           {n=G.UIT.O, config={object = dt2}},
         }},
       }},
     }}
   return extras
end

function RF.open._create_shop_option()
   RF.open.dynamic_values.shop_text = localize('$') .. G.GAME.RFOD_SETTINGS.shop_cost
   RF.open.dynamic_values.skip_text = localize('$') .. G.GAME.RFOD_SETTINGS.skip_cost
   G.GAME.round_resets.blind_tags = G.GAME.round_resets.blind_tags or {}
   local _tag = Tag(G.GAME.round_resets.blind_tags['Big'], nil, 'Big')
   local _tag_ui, _tag_sprite = _tag:generate_UI()
   local shop_color = G.C.GOLD
   return { n = G.UIT.R, config = { align = "cm", padding = 0.07 }, nodes = {
      {n = G.UIT.R, config = { align = "cm", colour = mix_colours(G.C.BLACK, G.C.L_BLACK, 0.5), r = 0.1, outline = 1, outline_colour = G.C.L_BLACK, padding = 0.2 }, nodes = {
         { n = G.UIT.R, config = { align = "cm" }, nodes = {
            { n = G.UIT.O, config = { object = DynaText({ string = "SHOP", colours = { G.C.WHITE }, shadow = true, float = true, y_offset = -4, scale = 0.45, maxw = 2.8 }) } },
         }},
         { n = G.UIT.R, config = { id = 'enter_shop_button', align = "cm", colour = shop_color, minh = 0.6, minw = 2.7, outline = 1, outline_colour = darken(shop_color, 0.3), 
                                    padding = 0.07, r = 0.1, shadow = true, hover = true, one_press = true, func = 'can_enter_shop', button = 'enter_shop', maxw = 2.7 }, nodes = {
            { n = G.UIT.C, config = { align = "cl", minw = 1.0 }, nodes = {
               { n = G.UIT.T, config = { text = localize('b_open'), scale = 0.45, colour = G.C.UI.TEXT_LIGHT, shadow = true } }
            }},
            { n = G.UIT.C, config = { align = "cr", minw = 1.0 }, nodes = {
               { n = G.UIT.T, config = { ref_table = RF.open.dynamic_values, ref_value = "shop_text", scale = 0.45, colour = G.C.UI.TEXT_LIGHT, shadow = true } }
            }},
         }},
      }},
      { n = G.UIT.R, config = { id = 'blind_extras', align = "cm" }, nodes = {
         { n = G.UIT.R, config = { align = "cm" }, nodes = {
            { n = G.UIT.R, config = { align = 'tm', minh = 0.65 }, nodes = {
               { n = G.UIT.T, config = { text = localize('k_or'), scale = 0.55, colour = G.C.WHITE, shadow = true } },
            }},
            {n = G.UIT.R, config = { align = "cm", colour = mix_colours(G.C.BLACK, G.C.L_BLACK, 0.5), r = 0.1, outline = 1, outline_colour = G.C.L_BLACK, padding = 0.2 }, nodes = {
               {n=G.UIT.R, config={id = 'tag_container', ref_table = _tag, align = "cm"}, nodes={
                  {n=G.UIT.R, config={id = 'tag_Big', align = "cm", r = 0.1, padding = 0.1, minw = 1, can_collide = true, ref_table = _tag_sprite}, nodes={
                     {n=G.UIT.C, config={id = 'tag_desc', align = "cm", minh = 1}, nodes={
                     _tag_ui
                     }},
                     {n=G.UIT.C, config={id = 'skip_blind_button', align = "cm", colour = G.C.UI.BACKGROUND_INACTIVE, minh = 1.0, minw = 2, maxw = 2, padding = 0.07, r = 0.1, shadow = true, hover = true, button = 'skip_blind', func = 'can_skip_blind', ref_table = _tag}, nodes={
                        {n=G.UIT.R, config={align = "cm", minw = 1, can_collide = true}, nodes={
                           { n = G.UIT.T, config = { text = localize('b_skip_blind'), scale = 0.45, colour = G.C.UI.TEXT_LIGHT, shadow = true } }
                        }},
                        {n=G.UIT.R, config={align = "cm", minw = 1, can_collide = true}, nodes={
                           { n = G.UIT.T, config = { ref_table = RF.open.dynamic_values, ref_value = "skip_text", scale = 0.45, colour = G.C.UI.TEXT_LIGHT, shadow = true } },
                        }},
                     }},
                  }},
               }},
            }},
         }},
      }},
   }}
end

-- blind_choice = "Big" or "Small"
function create_UIBox_blind_tag(blind_choice, small_view)
   G.GAME.round_resets.blind_tags = G.GAME.round_resets.blind_tags or {}
   if not G.GAME.round_resets.blind_tags[blind_choice] then return nil end
   local _tag = Tag(G.GAME.round_resets.blind_tags[blind_choice], nil, blind_choice)
   local _tag_ui, _tag_sprite = _tag:generate_UI()
   _tag_sprite.states.collide.can = not small_view
   return {
      n = G.UIT.C,
      config = { id = 'tag_' .. blind_choice, align = "cm", r = 0.1, padding = 0.1, minw = 1, can_collide = true, ref_table = _tag_sprite },
      nodes = {
         {
            n = G.UIT.C,
            config = { id = 'tag_desc', align = "cm", minh = 0.6 },
            nodes = {
               _tag_ui
            }
         }
      }
   }
end

function RF.open._add_reward_tag(config)
   if config.name == 'blind1' then
      if G.GAME.round_resets.blind_states.Roaming == 'Defeated' then
         -- joker slot
         G.GAME.round_resets.blind_states.Roaming = 'Upcoming'
         G.GAME.round_resets.blind_states.Roaming2 = 'Upcoming'
         local temp_text = localize { type = 'raw_descriptions', set = 'Edition', vars = { 1 }, key = 'e_negative' }
             [1]
         G.E_MANAGER:add_event(Event({
            trigger = 'before',
            delay = 0.38,
            func = function()
               G.round_eval:add_child(
                  {
                     n = G.UIT.R,
                     config = { align = "cm", id = 'dollar_row_boss_bonus_blind1', key = 'e_negative' },
                     nodes = {
                        { n = G.UIT.O, config = { object = DynaText({ string = temp_text, colours = { G.C.MONEY }, shadow = true, pop_in = 0, scale = 0.45, float = true }) } }
                     }
                  },
                  G.round_eval:get_UIE_by_ID('dollar_blind1'))
               return true
            end
         }))
      elseif G.GAME.round_resets.blind_states.Roaming2 == 'Defeated' then
         -- consumable slot
         G.GAME.round_resets.blind_states.Roaming = 'Upcoming'
         G.GAME.round_resets.blind_states.Roaming2 = 'Upcoming'
         local temp_text = localize { type = 'raw_descriptions', set = 'Edition', vars = { 1 }, key = 'e_negative_consumable' }
             [1]
         G.E_MANAGER:add_event(Event({
            trigger = 'before',
            delay = 0.38,
            func = function()
               G.round_eval:add_child(
                  {
                     n = G.UIT.R,
                     config = { align = "cm", id = 'dollar_row_boss_bonus_blind1', key = 'e_negative_consumable' },
                     nodes = {
                        { n = G.UIT.O, config = { object = DynaText({ string = temp_text, colours = { G.C.MONEY }, shadow = true, pop_in = 0, scale = 0.45, float = true }) } }
                     }
                  },
                  G.round_eval:get_UIE_by_ID('dollar_blind1'))
               return true
            end
         }))
      end
   end
end

function RF.open._create_shop_skip_options()
   RF.open._init_GAME_settings()
   local shop_skip = RF.open._create_shop_option()
   return {
      n = G.UIT.ROOT,
      config = { align = 'cl', minh = 4, r = 0.15, colour = G.C.CLEAR },
      nodes = {
         UIBox_dyn_container({ shop_skip }, true, mix_colours(G.C.GOLD, G.C.BLACK, 0.6))
      }
   }
end
