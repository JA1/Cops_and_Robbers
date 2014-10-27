#===============================================================================
#
#   Sample external MethodScript include
#
#===============================================================================

######## _dooropen procedure open the door on each maps each 5 minutes for 10 seconds#################################
######## _dooropen procedure open the door on each maps each 5 minutes for 10 seconds#################################
proc(_startdooropentimer,
	set_interval(300000, closure(
		set_timeout(60000, closure(
			_dooropentimer(get_value('ident.jail.a'))))
		set_timeout(120000, closure(
			_dooropentimer(get_value('ident.jail.b'))))
		set_timeout(180000, closure(
			_dooropentimer(get_value('ident.jail.c'))))
	))
)
proc(_dooropentimer, @whatlist,
		if(equals(get_value('timer.cops.'.@whatlist), 'off')) {
			if(equals(get_value('timer.resetmap'), 'off')) {
				broadcast(color(4).'A robber in game 'color(6).'#'.@whatlist color(4)' must type '.color(6).'"/open cell"'.color(4)' quickly')
					export('opendoor.number', @whatlist)
					export('opendoor.opentime', 'on')
					set_timeout(5000, closure(
					export('opendoor.opentime', 'off')
					))
			}
		}
)
proc(_dooropen, @whatlist,
		if(equals(get_value('timer.cops.'.@whatlist), 'off')) {
			if(equals(get_value('timer.resetmap'), 'off')) {
			sudo('/region select jail'.@whatlist)
			sudo('//replace irondoor air')
			broadcast(color(4)'['.color(6).'WARNING'.color(4).']'.color(2).'Problem detected with doors on jail #'.@whatlist color(1).'Robbers'.color(2).', This is your chance!')
			set_timeout(5000, closure(
				sudo('//undo')
				export('opendoor.wetimer', 'off')
			))
			}
		}
)

##### _randomcop() Procedure will randomly select a cops at start of a game #####
proc(_randomcop, @whatlist,
	@randomcop = get_value('random.cops.'.@whatlist)
	@jailcops = get_value('jail.cops.'.@whatlist)
	@jaillist = get_value('jail.list.'.@whatlist)
	@jail = 'jail'.@whatlist
		if(array_size(@randomcop) <= 0) {
			broadcast(color(1).'There is still no cop! type /cops to become the new cop!')
			die()
		}
		@cops1 = array_rand(@randomcop, 1, false)[0]
		array_remove_values(@randomcop, @cops1)
		array_push(@jailcops, @cops1)
			if(array_size(@randomcop) <= 0 || array_size(@jaillist) < 8) {
				foreach(@jailcops, @name) {
					sudo('/ewarp' @jail @name)
					sudo('/kit cops' @name)
					set_pmode(@name, 'SURVIVAL')
					team_add_player('cops', @name)
				}
				store_value('jail.cops.'.@whatlist, @jailcops)
				store_value('random.cops.'.@whatlist, array())
				broadcast(color(4).@cops1.color(2).', Is now the new Cop in game #'.@whatlist' Let the game Begin!!')
				broadcast(color(1).'Please listen to the cops orders! Do not abuse of anything, have fun!')
				die('You are alone as cop for now')
			} else {
					@cops2 = array_rand(@randomcop, 1, false)[0]
					array_push(@jailcops, @cops2)
					store_value('jail.cops.'.@whatlist, @jailcops)
						foreach(@jailcops, @name) {
							sudo('/ewarp' @jail @name)
							sudo('/kit cops' @name)
							set_pmode(@copsname, 'SURVIVAL')
							team_add_player('cops', @copsname)
					}
				store_value('random.cops.'.@whatlist, array())
				broadcast(color(4).@cops1 'and' @cops2.color(2).', Are now the new Cops in game #'.@whatlist' Let the game Begin!!')
				broadcast(color(1).'Please listen to the cops orders! Do not abuse of anything, have fun!')
					}
)


##### _newcop() Procedure to promote a user to cop in his respective jail #####
proc(_newcop, @copsname, @num,
	@jailcops = get_value('jail.cops.'.@num)
	array_push(@jailcops, @copsname)
	#export('doorid.'.@num, @doorid)
	store_value('jail.cops.'.@num, @jailcops)
	sudo('/ewarp jail'.@num @copsname)
	sudo('/kit cops' @copsname)
	set_pmode(@copsname, 'SURVIVAL')
	team_add_player('cops', @copsname)
	broadcast(color(4).@copsname.color(2).', Is now the new Cop in game #'.@num'! Let the game Begin/Continue!!')
	broadcast(color(1).'Please listen to the cops orders! Do not abuse of anything, have fun!')
	die(color(2).'Please be a nice cop and act nice so we can have a fun time on cops and robbers!')
)

##### _remove_player() Procedure that remove a player from his jail list #####
proc(_remove_player, @removename, @whatlist,
	@playerlist = get_value('jail.list.'.@whatlist)
	array_remove_values(@playerlist, @removename)
	store_value('jail.list.'.@whatlist, @playerlist)
)

##### _remove_cops() Procedure that remove a player from his jail list #####
proc(_remove_cops, @removecops, @whatlist, @playerlist,
	array_remove_values(@playerlist, @removecops)
	team_remove_player('cops', @removecops)
	_emptyinv(@removecops)
	store_value('jail.cops.'.@whatlist, @playerlist)
)




##### _combinelist() Procedure to combine the jail list arrays into one big array.
proc(_combinelist,
	@combine1 = get_value('jail.list.'.get_value('ident.jail.a'))
	@combine2 = get_value('jail.list.'.get_value('ident.jail.b'))
	@combine3 = get_value('jail.list.'.get_value('ident.jail.c'))
##the returned array##
	@combinelist = array_merge(@combine1, @combine2, @combine3)
		return(@combinelist)
)

##### _whatlist(player()) Procedure return on which jail.list.* the player is, returns none if not in any list#####
proc(_whatlist, @whatname,
	@whatlist1 = get_value('jail.list.'.get_value('ident.jail.a'))
	@whatlist2 = get_value('jail.list.'.get_value('ident.jail.b'))
	@whatlist3 = get_value('jail.list.'.get_value('ident.jail.c'))
		if(array_contains(@whatlist1, @whatname)) {
			return(get_value('ident.jail.a'))
		}
		if(array_contains(@whatlist2, @whatname)) {
			return(get_value('ident.jail.b'))
		}
		if(array_contains(@whatlist3, @whatname)) {
			return(get_value('ident.jail.c'))
		} else {
			return('none')
		}
) 

##### _crjoin() Procedure when a player join a game (/cr join *) #####
proc(_crjoin, @joinname, @jailnum,
	@verify = _combinelist()
	@playerlist = get_value('jail.list.'.@jailnum)
		if(array_contains(@verify, @joinname)) {
		die(color(4).'You are listed like already in game.')
		}
##### If the game is already full #####
	@timerjail = get_value('timer.nojoin.'.@jailnum)
		if(@timerjail == 'on') {
			die(color(4).'Map is reseting, please wait..')
		} 
		if(array_size(@playerlist) >= 16) {
##### If a donator join a fullgame ######
		if(has_permission(@joinname, 'donator.vip')) {
			if(!array_contains(@verify, @joinname)) {
				@crjointp = array_rand(get_value('jail.tp.'.@jailnum), 1, false)[0]
				array_push(@playerlist, @joinname)
				store_value('jail.list.'.@jailnum, @playerlist)
				set_ploc(@joinname, @crjointp)
				set_pmode(@joinname, 'ADVENTURE')
				set_pbed_location(@joinname, @crjointp)
				_emptyinv(@joinname)
				_kick4donator(@playerlist, @jailnum)
				die(color(2).'You just joined the cops and robbers game! if there is no cop yet, type /cops. Respect the rules and have fun!!')
			}
		} 
##### End of donator full game parts #####
			die(color(4).'This game is already full, type /donate to learn how to join full games!')
		}
##### If he meets the requirments ---> join the game #####
		if(!array_contains(@verify, @joinname)) {
			@crjointp = array_rand(get_value('jail.tp.'.@jailnum), 1, false)[0]
			array_push(@playerlist, @joinname)
			store_value('jail.list.'.@jailnum, @playerlist)
#'<<- just to set color back to normal.####
			set_ploc(@joinname, @crjointp)
			set_pmode(@joinname, 'ADVENTURE')
			set_pbed_location(@joinname, @crjointp)
			_emptyinv(@joinname)
			die(color(2).'You just joined the cops and robbers game! if there is no cop yet, type /cops. Respect the rules and have fun!!')
		}
)

##### _kick4donator procedure kick a random player to make room for donators #####
proc(_kick4donator, @playerlist, @whatlist,
	@randnum = rand(0,15)
	@kickedname = array_get(@playerlist, @randnum)
		if(has_permission(@kickedname, 'donator.vip')) {
			_kick4donator(@playerlist, @whatlist)
		}
		if(!has_permission(@kickedname, 'donator.vip')) {
			_remove_player(@kickedname, @whatlist)
			set_ploc(@kickedname, get_value('ident.jail.spawn'))
			team_remove_player('cops', @kickedname)
			tmsg(@kickedname, color(4).'You have been randomly removed from game #'.@whatlist 'To make room for Donators') 
			@coplist = get_value('jail.cops.'.@whatlist)
			if(array_contains(@coplist, @kickedname)) {
				_remove_cops(@kickedname, @whatlist, @coplist)
			}
		}
)


##### _endgame Procedure is when someone hit the right block to end a game. #####
proc(_endgame, @winname, @whatlist,
	@jaillist = get_value('jail.list.'.@whatlist)
	@jailcops = get_value('jail.cops.'.@whatlist)
	store_value('jail.cops.'.@whatlist, array())
	store_value('jail.list.'.@whatlist, array())
		if(equals(@winname, 'none')) {
			broadcast(color(5).'No one won the game #'.@whatlist.', was the cops too Boring? or too good ?')
		}
		if(!equals(@winname, 'none')) {
			broadcast(color(5).'Congratulation' color(4).@winname.color(5).'!!! You just won the 'color(4).'Cops and Robbers' color(5).'on map #'.@whatlist'!!')
		}
####### PART THAT ADD INFORMATION FOR /cr top (ranks) #######
		if(array_size(@jaillist) > '7') {
###part for money when games end###
			foreach(@jaillist, @name) {
				acc_add(@name, '10')
			}
				if(!equals(@winname, 'none')) {
### more money for winner
					acc_add(@winname, '20')
##end of money part
					tmsg(@winname, color(2).'You Won 20 more $$ for winning the game!')
					@winstats = get_value('win.'.@winname)
					@winjailstats = get_value('jwin.'.@whatlist.'.'.@winname)
						if(!equals(@winstats, 'null')) {
							store_value('win.'.@winname, add(@winstats, 1))
						}
						if(!equals(@winjailstats, 'null')) {
							store_value('jwin.'.@whatlist.'.'.@winname, add(@winjailstats, 1))
						}
						if(equals(@winstats, 'null')) {
							store_value('win.'.@winname, 1)
						}
						if(equals(@winjailstats, 'null')) {
							store_value('jwin.'.@whatlist.'.'.@winname, 1)
						}
				}
		}
##### END OF CR TOP FUNCTION ########

		store_value('timer.nojoin.'.@whatlist, 'on')
		store_value('timer.cops.'.@whatlist, 'on')
		set_timeout(15000, closure(

		store_value('timer.nojoin.'.@whatlist, 'off')))
		set_timeout(40000, closure(
		store_value('timer.cops.'.@whatlist, 'off')
		_randomcop(@whatlist)))
			foreach(@jailcops, @cops) {
				_emptyinv(@cops)
				team_remove_player('cops', @cops)
			}
			foreach(@jaillist, @name) {
				set_ploc(@name, get_value('ident.jail.spawn')) 
				set_pbed_location(@name, get_value('ident.jail.spawn')) 
			}
			_resetmap(@whatlist)
			clear_task(get_value('reset.time.'.@whatlist))
				@id = set_timeout(1180000, closure(
					broadcast(color(1).'Game #'.@whatlist' will restart in 1 minutes!')
						set_timeout(60000, closure(
							_endgame('none', @whatlist)
						))
					))
		store_value('reset.time.'.@whatlist, @id)
)

##### _resetmap Procedure will resets all lever that are in the jail region#####
proc(_resetmap, @whatlist,
	if(equals(get_value('timer.resetmap'), 'on') || equals(import('opendoor.wetimer'), 'on')) {
		set_timeout(10000, closure(
			store_value('timer.resetmap', 'on')
			sudo('/region select jail'.@whatlist)
			sudo('//replace lever air')
			set_timeout(800, closure(
			sudo('//undo')))
			set_timeout(6000, closure(
			store_value('timer.resetmap', 'off')))
		))
	} else {
		store_value('timer.resetmap', 'on')
		sudo('/region select jail'.@whatlist)
		sudo('//replace lever air')
		set_timeout(800, closure(
		sudo('//undo')))
		set_timeout(6000, closure(
		store_value('timer.resetmap', 'off')))
	}
)

##### _kickcop Procedure will return to robbers the kicked cop#####
proc(_kickcop, @copname, @whatlist,
	@coplist = get_value('jail.cops.'.@whatlist)
	array_remove_values(@coplist, @copname)
	store_value('jail.cops.'.@whatlist, @coplist)
	broadcast(color(2).'A cop was kicked in game #'.@whatlist.'! type /cops to be a Cop!!')
	team_remove_player('cops', @copname)
	_emptyinv(@copname)
	sudo('/kill' @copname)
)
##### _modkickcop Procedure will return to robbers the kicked cop#####
proc(_modkickcop, @copname, @whatlist,
	@coplist = get_value('jail.cops.'.@whatlist)
	array_remove_values(@coplist, @copname)
	store_value('jail.cops.'.@whatlist, @coplist)
	broadcast(color(2).'A cop was randomly removed to force a new cop.')
	set_ploc(@copname, get_value('ident.jail.spawn')) 
	team_remove_player('cops', @copname)
	_emptyinv(@copname)
)

################################################
###_emptyinv(player()) 
###   Procedure that emtpy inventory
###   and armor of designated player
################################################
proc(_emptyinv, @player,

	@empty = array(
				null, null, null, null, null, null, null, null, null, null, 
				null, null, null, null, null, null, null, null, null, null,
				null, null, null, null, null, null, null, null, null, null,
				null, null, null, null, null, 100:null, 101:null, 102:null, 103:null
			)

	if(@player == '',
		return(@empty),
		set_pinv(@player, @empty)
		sudo('/give'@player'364 10')
		return(true)
	)
	)
	
	
##### _noncopareaclear Procedure that run every X minutes to teleport back Camping cops
proc(_noncopareaclear,
	@jaila = get_value('jail.cops.'.get_value('ident.jail.a'))
	@jailb = get_value('jail.cops.'.get_value('ident.jail.b'))
	@jailc = get_value('jail.cops.'.get_value('ident.jail.c'))
	@allcops = array_merge(@jaila, @jailb, @jailc)
		foreach(@allcops, @name) { 
			@skregion = sk_current_regions(@name) 
				foreach(@skregion, @region) {
					if(reg_count('protect', @region) < '1') {
						die()
					}
					@whatlist = _whatlist(@name)
					set_ploc(@name, get_value('cop.spawn.'.@whatlist)) 
					tmsg(@name, color(4).'You are not allowed to be in this area!')
				}
		}
)

##### _updatestats Procedure is run every X time to update the robbers stats. #####
proc(_updatestats, 
	@fulllist = get_values('win')
	@keys = array_keys(@fulllist)
	@number = array_normalize(@fulllist)
		for(@i = 1, @i < 13, @i++) {
			@max = max(@number)
			@index = array_indexes(@number, @max)[0]
			@winname = array_get(@keys, @index)
			store_value('top.win.'.@i, @winname @max)
			array_remove(@number, @index)
			array_remove(@keys, @index)
		}
)