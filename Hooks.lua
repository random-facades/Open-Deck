--
-- All function to hook and modify, or run prior/after
--

RF.open.hooks._set_blind = Blind.set_blind
RF.open.hooks.new_set_blind = function(self, blind, reset, silent)
   RF.open.hooks._set_blind(self, blind, reset, silent)
   if blind then
      if G.GAME.blind_on_deck == 'Small' then
         local new_mult = self.mult * math.floor(10 * math.pow(1.1, G.GAME.RFOD_SETTINGS.small_attempts)) / 10
         self.chips = get_blind_amount(G.GAME.round_resets.ante) * new_mult * G.GAME.starting_params.ante_scaling
         self.chip_text = number_format(self.chips)
         G.GAME.RFOD_SETTINGS.small_attempts = G.GAME.RFOD_SETTINGS.small_attempts + 1
      elseif G.GAME.blind_on_deck == 'Big' then
         local new_mult = self.mult * math.floor(10 * math.pow(1.1, G.GAME.RFOD_SETTINGS.big_attempts)) / 10
         self.chips = get_blind_amount(G.GAME.round_resets.ante) * new_mult * G.GAME.starting_params.ante_scaling
         self.chip_text = number_format(self.chips)
         G.GAME.RFOD_SETTINGS.big_attempts = G.GAME.RFOD_SETTINGS.big_attempts + 1
      elseif G.GAME.blind_on_deck == 'Roaming' then
         G.GAME.blind.dollars = 0
         local temp_ante = G.GAME.round_resets.ante + G.GAME.RFOD_SETTINGS.roaming_attempts
         self.chips = get_blind_amount(temp_ante) * self.mult * G.GAME.starting_params.ante_scaling
         self.chip_text = number_format(self.chips)
         G.GAME.RFOD_SETTINGS.roaming_attempts = G.GAME.RFOD_SETTINGS.roaming_attempts + 1
      end
   end
end
Blind.set_blind = RF.open.hooks.new_set_blind
