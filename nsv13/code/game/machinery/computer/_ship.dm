//Generic console base for consoles that interact with the overmap
//If you are looking for the Dradis console look in nsv13/modules/overmap/radar.dm
//If you're looking for the FTL navigation computer look in nsv13/modules/overmap/starmap.dm
GLOBAL_LIST_INIT(computer_beeps, list('nsv13/sound/effects/computer/beep.ogg','nsv13/sound/effects/computer/beep2.ogg','nsv13/sound/effects/computer/beep3.ogg','nsv13/sound/effects/computer/beep4.ogg','nsv13/sound/effects/computer/beep5.ogg','nsv13/sound/effects/computer/beep6.ogg','nsv13/sound/effects/computer/beep7.ogg','nsv13/sound/effects/computer/beep8.ogg','nsv13/sound/effects/computer/beep9.ogg','nsv13/sound/effects/computer/beep10.ogg','nsv13/sound/effects/computer/beep11.ogg','nsv13/sound/effects/computer/beep12.ogg'))
//Yes beeps are here because reasons

/obj/machinery/computer/ship
	name = "Ship console"
	icon_keyboard = "helm_key"
	var/obj/structure/overmap/linked
	var/datum/overmap/linked_js = null
	var/position = null
	var/can_sound = TRUE //Warning sound placeholder
	var/sound_cooldown = 10 SECONDS //For big warnings like enemies firing on you, that we don't want repeating over and over
	var/list/ui_users = list()
	//Override me to display different widgets.
	var/ui_type = "JSOvermap"
	var/position_type = /datum/component/overmap_piloting/pilot
	var/allow_ghosts = FALSE

/obj/machinery/computer/ship/Initialize(mapload)
	. = ..()
	return INITIALIZE_HINT_LATELOAD

/obj/machinery/computer/ship/LateInitialize()
	has_overmap()

/obj/machinery/computer/ship/proc/relay_sound(sound, message)
	if(!can_sound)
		return
	if(message)
		visible_message(message)
	if(sound)
		playsound(src, sound, 100, 1)
		can_sound = FALSE
		addtimer(CALLBACK(src, PROC_REF(reset_sound)), sound_cooldown)

/obj/machinery/computer/ship/proc/reset_sound()
	can_sound = TRUE

//This is such a stupid bandaid, but I can't be bothered undoing this spaghetti right now.
/obj/machinery/computer/ship/proc/has_overmap()
	linked_js = get_overmap()
	return linked_js

///Deprecated.
/obj/machinery/computer/ship/proc/set_position(obj/structure/overmap/OM)
	return

/obj/machinery/computer/ship/ui_interact(mob/user, datum/tgui/ui)
	if(!allow_ghosts && isobserver(user))
		return FALSE
	if(!has_overmap())
		if(!isobserver(user))
			var/sound = pick('nsv13/sound/effects/computer/error.ogg','nsv13/sound/effects/computer/error2.ogg','nsv13/sound/effects/computer/error3.ogg')
			playsound(src, sound, 100, 1)
		to_chat(user, "<span class='warning'>A warning flashes across [src]'s screen: Unable to locate thrust parameters, no registered ship stored in microprocessor.</span>")
		return FALSE

	//No controlling ai ships!
	if(linked_js.ai_skynet3)
		if(!isobserver(user))
			var/sound = pick('nsv13/sound/effects/computer/error.ogg','nsv13/sound/effects/computer/error2.ogg','nsv13/sound/effects/computer/error3.ogg')
			playsound(src, sound, 100, 1)
		to_chat(user, "<span class='warning'>A warning flashes across [src]'s screen: Automated flight protocols are still active. Unable to comply.</span>")
		return FALSE
	if(!isobserver(user) && !ui)
		playsound(src, 'nsv13/sound/effects/computer/startup.ogg', 75, 1)
	//to_chat(world, "Overmap: UI update...")
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		if(!isobserver(user))
			playsound(src, 'nsv13/sound/effects/computer/hum.ogg', 100, 1)
		ui = new(user, src, ui_type)
		user.AddComponent(position_type, linked_js, ui)
		ui.open()

/obj/machinery/computer/ship/ui_data(mob/user)
	. = SSJSOvermap.ui_data_for(user, linked_js)

/obj/machinery/computer/ship/ui_static_data(mob/user)
	. = SSJSOvermap.ui_static_data_for(user)

/obj/machinery/computer/ship/ui_act(action, list/params)
	. = ..()
	if (.)
		return
	return SSJSOvermap.ui_act_for(usr, action, params)

//Trust me, your ears will thank me for this.
/obj/machinery/computer/ship/play_click_sound(var/custom_clicksound)
	if((custom_clicksound ||= clicksound) && world.time > next_clicksound)
		next_clicksound = world.time + 1 SECONDS
		playsound(src, custom_clicksound, clickvol)

/obj/machinery/computer/ship/ui_close(mob/user)
	var/datum/component/overmap_piloting/C = user.GetComponent(/datum/component/overmap_piloting)
	C?.RemoveComponent()
	ui_users -= user
	return ..()

/obj/machinery/computer/ship/Destroy()
	. = ..()
	for(var/mob/living/M in ui_users)
		ui_close(M)


//Viewscreens for regular crew to watch combat
/obj/machinery/computer/ship/viewscreen
	name = "Seegson model M viewscreen"
	desc = "A large CRT monitor which shows an exterior view of the ship."
	icon = 'nsv13/icons/obj/computers.dmi'
	icon_state = "viewscreen"
	idle_power_usage = 15
	mouse_over_pointer = MOUSE_HAND_POINTER
	pixel_y = 26
	density = FALSE
	anchored = TRUE
	req_access = null
	position_type = /datum/component/overmap_piloting/observer
	allow_ghosts = TRUE
	var/obj/machinery/computer/ship/dradis/minor/internal_dradis

/obj/machinery/computer/ship/viewscreen/Initialize(mapload)
	. = ..()
	internal_dradis = new(src)

/obj/machinery/computer/ship/viewscreen/examine(mob/user)
	. = ..()
	if(!linked_js)
		return
	//if(isobserver(user))
		//var/mob/dead/observer/O = user
		//O.ManualFollow(linked)
		//return

	//linked.observe_ship(user)
	ui_interact(user)
	internal_dradis.attack_hand(user)
