######################################################
#
#   Sample Main file. This file is run when the server
#   starts up, or the plugin is reloaded. It can be used
#   as an opportunity to register events or do other things
#   when the server initially starts. Variables defined here
#   will go out of scope, so you can't assign() something and
#   then use it in a command, for instance.
#
######################################################

set_timeout(6000, closure(
))
######################################################
### open doors timer at start  #######################
######################################################
set_timeout(10000, closure(
	_startdooropentimer()
))
######################################################
### open doors timer at start  #######################
######################################################
set_interval(15000, closure(
	_noncopareaclear()
))
######################################################
### Set all default values at server start############
######################################################
set_timeout(9000, closure(
	_restartarray() 
	) )
######################################################
### Update /cr top every hour  #######################
######################################################
set_timeout(1800000, closure(
	_updatestats() 
	) )

######################################################
### If a player leave the game #######################
######################################################
bind(player_quit, null, null, @event,
	@verify = _combinelist()
	@quitname = @event['player']
		if(!array_contains(@verify, @quitname)) {
			die()
		}
		@whatlist = _whatlist(@quitname)
		@copslist = get_value('jail.cops.'.@whatlist)
		_remove_player(@quitname, @whatlist)
			if(array_contains(@copslist, @quitname)) {
				_remove_cops(@quitname, @whatlist, @copslist)
				broadcast(color(2).'A cop left the game #'.@whatlist'! type /cops to be a Cop!!')
				die()
			}
)

#######################################################
### When any player join the server ###################
#######################################################

bind(player_join, null, null, @playerjoinevent,
	set_timeout(2000, closure(
		set_ploc(@playerjoinevent['player'], get_value('ident.jail.spawn')) 
		sudo('/l')
	))
)

#######################################################
### When any player Respawn (From dying) ###################
#######################################################

bind(player_spawn, null, null, @playerspawnevent,
	@verify = _combinelist()
	@respawnname = @playerspawnevent['player']
		if(!array_contains(@verify, @respawnname)) {
			modify_event('location', import('ident.jail.spawn'))
		}
)


#######################################################
### Hit the block to win and finish the game ##########
#######################################################

bind(player_interact, null, null, @winblock,
		if(equals(@winblock['action'], 'right_click_block') && (equals(@winblock['block'], '19'))) {
			@winname = @winblock['player']
			@verify = _combinelist()
				if(array_contains(@verify, @winname)) {
					@whatlist = _whatlist(@winname)
						if(equals(get_value('timer.nojoin.'.@whatlist), 'on')) {
							die('The game is restarting')
						}
					@copslist = get_value('jail.cops.'.@whatlist)
						if(array_contains(@copslist, @winname)) {
							die(color(4).'You cannot escape as the Cop!')
						}
					_endgame(@winname, @whatlist)
					die(color(6).'Congratulation for winning the round!')
				}
				die(color(4).'You are not in any game, type /cr join # to join a game')
		}
)

#######################################################
###   Kill Bind, protect cops for abusing    ##########
#######################################################
#bind(player_death, null, array(player: array_merge(get_value('jail.cops.'.get_value('ident.jail.a')),get_value('jail.cops.'.get_value('ident.jail.b')),get_value('jail.cops.'.get_value('ident.jail.c')))), @kill,
#	@killer = @kill['killer']
#	@whatlist = _whatlist(@killer)
#	@coplist = array_merge(get_value('jail.cops.'.get_value('ident.jail.a')),get_value('jail.cops.'.get_value('ident.jail.b')),get_value('jail.cops.'.get_value('ident.jail.c')))
#		if(array_contains(@coplist, @killer)) {
#			sudo('/ekick' @killer 'You cant kill the cop as a cop!')
#		}
#)