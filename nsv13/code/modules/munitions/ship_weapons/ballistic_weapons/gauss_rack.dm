//Rack loading

/obj/structure/gauss_rack
	name = "Deck gun loading rack"
	icon = 'nsv13/icons/obj/munitions_large.dmi'
	icon_state = "loading_rack"
	desc = "A large rack used as an ammunition feed for deck guns. The rack will automatically feed the deck gun above it with ammunition. You can load a crate with ammo and click+drag it onto the rack to speedload, or manually load it with rounds by hand."
	anchored = TRUE
	density = TRUE
	layer = 3
	var/capacity = 0
	var/max_capacity = 6//Maximum number of munitions we can load at once
	var/loading = FALSE //stop you loading the same torp over and over
	var/obj/machinery/ship_weapon/gauss_gun/gun

/obj/structure/gauss_rack/attackby(obj/item/I, mob/user)
	if(istype(I, gun.ammo_type))
		if(loading)
			to_chat(user, "<span class='notice'>You're already loading something onto [src]!.</span>")
			return FALSE
		if(capacity < max_capacity)
			to_chat(user, "<span class='notice'>You start to load [I] onto [src]...</span>")
			loading = TRUE
			if(do_after(user,10, target = src))
				load(I, src)
				to_chat(user, "<span class='notice'>You load [I] onto [src].</span>")
				loading = FALSE
			loading = FALSE
			return FALSE
		else
			to_chat(user, "<span class='warning'>[src] is fully loaded!</span>")
	. = ..()

/obj/structure/gauss_rack/MouseDrop_T(obj/structure/A, mob/user)
	. = ..()
	if(istype(A, /obj/structure/closet))
		if(!LAZYFIND(A.contents, /obj/item/ship_weapon/ammunition/gauss))
			to_chat(user, "<span class='warning'>There's nothing in [A] that can be loaded into [src]...</span>")
			return FALSE
		to_chat(user, "<span class='notice'>You start to load [src] with the contents of [A]...</span>")
		if(do_after(user, 6 SECONDS , target = src))
			for(var/obj/item/ship_weapon/ammunition/gauss/G in A)
				if(load(G, user))
					continue
				else
					break

/obj/structure/gauss_rack/proc/load(atom/movable/A, mob/user)
	playsound(src, 'nsv13/sound/effects/ship/mac_load.ogg', 100, 1)
	if(capacity >= max_capacity)
		to_chat(user, "<span class='warning'>[src] is full!</span>")
		loading = FALSE
		return FALSE
	if(istype(A, gun.ammo_type))
		A.forceMove(src)
		A.pixel_y = 10+(capacity*10)
		vis_contents += A
		capacity ++
		A.layer = ABOVE_MOB_LAYER
		A.mouse_opacity = FALSE //Nope, not letting you pick this up :)
		loading = FALSE
		return TRUE
	else
		loading = FALSE
		return FALSE


/obj/structure/gauss_rack/proc/unload(atom/movable/A)
	vis_contents -= A
	A.forceMove(get_turf(src))
	A.pixel_y = initial(A.pixel_y) //Remove our offset
	A.layer = initial(A.layer)
	A.mouse_opacity = TRUE
	if(istype(A, gun.ammo_type)) //If a munition, allow them to load other munitions onto us.
		capacity --
	if(contents.len)
		var/count = capacity
		for(var/X in contents)
			var/atom/movable/AM = X
			if(istype(AM, gun.ammo_type))
				AM.pixel_y = count*10
				count --

/obj/structure/gauss_rack/attack_hand(mob/user)
	. = ..()
	if(.)
		return
	if(capacity <= 0)
		return
	user.set_machine(src)
	var/dat
	dat += "<a href='?src=[REF(src)];sendup=1'>Load rack into gun.</a><br>"
	if(contents.len)
		for(var/X in contents) //Allows you to remove things individually
			var/atom/content = X
			dat += "<a href='?src=[REF(src)];removeitem=\ref[content]'>[content.name]</a><br>"
	dat += "<a href='?src=[REF(src)];unloadall=1'>Unload All</a>"
	var/datum/browser/popup = new(user, "loading rack", name, 300, 200)
	popup.set_content(dat)
	popup.open()

/obj/structure/gauss_rack/Topic(href, href_list)
	if(!in_range(src, usr))
		return
	var/atom/whattoremove = locate(href_list["removeitem"])
	if(whattoremove && whattoremove.loc == src)
		unload(whattoremove)
	if(href_list["unloadall"])
		for(var/atom/movable/A in src)
			unload(A)
	if(href_list["sendup"] && !loading)
		gun.raise_rack()
	attack_hand(usr)