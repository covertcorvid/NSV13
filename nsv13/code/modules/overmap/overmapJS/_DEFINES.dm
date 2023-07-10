#define COMSIG_JS_OVERMAP_UPDATE "js_overmap_mark_dirty"
#define COMSIG_JS_OVERMAP_STATIC_DATA_UPDATE "js_overmap_static_data_update"
#define OVERMAP_FACTION_NANOTRASEN 1 << 0
#define OVERMAP_FACTION_SOLGOV 1 << 1
#define OVERMAP_FACTION_CIVILIAN 1 << 2
#define OVERMAP_FACTION_SYNDICATE 1 << 3
#define OVERMAP_FACTION_PIRATE 1 << 4
#define OVERMAP_FACTION_PLAYER OVERMAP_FACTION_NANOTRASEN | OVERMAP_FACTION_SOLGOV | OVERMAP_FACTION_CIVILIAN
#define IS_OVERMAP_JS_COLLISION_RESPONSE_ELIGIBLE(O) !istype(O, /datum/overmap/projectile)
#define IS_OVERMAP_JS_PROJECTILE(O) istype(O, /datum/overmap/projectile)
#define IS_OVERMAP_JS_STELLAR_BODY(O) istype(O, /datum/overmap/grid_enabled/stellar_body)

#define OVERMAP_PROJECTILE_FLAGS_NONE 0
#define OVERMAP_PROJECTILE_FLAGS_CAN_BE_SHOT_DOWN 1 << 0

//Overmap damage types. Any kind of weapon you can think of goes here.
#define OVERMAP_DAMAGE_TYPE_KINETIC_SUBCAPITAL 1
#define OVERMAP_DAMAGE_TYPE_KINETIC_CAPITAL 2
#define OVERMAP_DAMAGE_TYPE_ENERGY 3
#define OVERMAP_DAMAGE_TYPE_EXPLOSIVE 4

#define THROW_NEW_NOTIMPLEMENTED_EXCEPTION CRASH("TODO: Not implemented!")

#define OVERMAP_INTERIOR_TYPE_CAPITAL 1
#define OVERMAP_INTERIOR_TYPE_TINY 2

//#define OVERMAP_INTERIOR_METRIC_MOBS "mobs"
#define OVERMAP_INTERIOR_METRIC_Z_LEVELS "Zs"
#define OVERMAP_INTERIOR_METRIC_AREAS "areas"

#define ARMOUR_QUADRANT_NORTH_EAST 4
#define ARMOUR_QUADRANT_NORTH_WEST 3
#define ARMOUR_QUADRANT_SOUTH_WEST 2
#define ARMOUR_QUADRANT_SOUTH_EAST 1
//This ship is assigned to a chosen map layout. No need to load any interior.
#define OVERMAP_ROLE_PRIMARY 1
//This ship needs its interior loading in manually.
#define OVERMAP_ROLE_SECONDARY 2

#define OVERMAP_ARMOUR_THICKNESS_NONE 0
#define OVERMAP_ARMOUR_THICKNESS_LIGHT 250
#define OVERMAP_ARMOUR_THICKNESS_MEDIUM 500
#define OVERMAP_ARMOUR_THICKNESS_HEAVY 1000
#define OVERMAP_ARMOUR_THICKNESS_SUPER_HEAVY 1500
#define OVERMAP_ARMOUR_THICKNESS_ABLATIVE 2000
#define OVERMAP_ARMOUR_THICKNESS_GIGA 2500
#define OVERMAP_ARMOUR_THICKNESS_STELLARBODY 9999999

//Signature defines //BEGIN

#define SIG_IR "SIG_IR"
#define SIG_GRAV "SIG_GRAV"
#define SIG_COMMS "SIG_COMMS" //Well, more like general signals.
#define SIG_THETA "SIG_THETA"

//~SIGNATURE_NONE is not really needed but here anyways because a 0 start point is nice. If you want a signature to be 0, just don't set it. - Delta

/*
Very basic (and likely temporary) signature defines to serve as a guideline.
Generally, objects should not have *too* strong of a signature as to not make detection trivial.
Very high signatures can however also serve to drown out weak ones, which is a neat trait especially on "passive" bodies like planets, stars, or minor oddities.
small but discernible spikes tend to do best for things-that-are-here-to-look-for, though many do not actively try to remain off your eyes either.
Play around with the ITS yourself and see what fits your vessel.
*/
#define THERMAL_SIGNATURE_NONE 0
#define THERMAL_SIGNATURE_MINISCULE 5 		//Very small things. Fighters, lifeboats in floaty mode, mothballed objects, things trying to sneak up on you.
#define THERMAL_SIGNATURE_SMALL 10	//100?	//Small ships, badly insulated lifeboats, minor objects.
#define THERMAL_SIGNATURE_MEDIUM 30 //150?	//Bigger ships, some stations and settled objectes.
#define THERMAL_SIGNATURE_LARGE 60 //200?	//Some planets or very big sapient-made objects
#define THERMAL_SIGNATURE_STAR 400 //400?	//Stars, or something actively trying to blind your sensors.
/*
Things that are actively generating lots of heat (anything with an active engine, especially high-yield ones), especially warships,
tend to class well above the thermal specs their mass would suggest. Especially when actively engaging, or venting heat.
*/

/*
The same, except for mass, aka gravimetric
Generally, there is a major discrepancy here between ships and big objects, as the mass differences are enormous.
Note that as with IR, "scaling" here is non-linear. Things with 2x the mass do not have 2x the signature, its scaling being below-linear.
*/
#define MASS_SIGNATURE_NONE 0 //Technically, none is not needed as not setting it in the list counts as it. However, I guess good for conclusiveness.
#define MASS_SIGNATURE_MINISCULE 5 //Fighters, escape pods, Potentially dropped cargo, very smol rocks and other fancy things.
#define MASS_SIGNATURE_SMALL 10 //Small ships, dense cargo, small asteroids.
#define MASS_SIGNATURE_MEDIUM 20 //Medium ships, asteroids, some small stationary objects
#define MASS_SIGNATURE_LARGE 40 //Large ships, bigger asteroids, stations
#define MASS_SIGNATURE_HUGE 80 //Very big ships, large asteroids, stations
#define MASS_SIGNATURE_MASSIVE 140 //Expansive stations, or very very large or dense asteroids.
#define MASS_SIGNATURE_PLANETOID 200 //Smol planets (like moons). Very massive stations can also fall under this.
#define MASS_SIGNATURE_PLANET 400 //Planets.
#define MASS_SIGNATURE_STAR 800 //Stars. Or ungodly things.
#define MASS_SIGNATURE_SINGULARITY 1600 //I sure wonder what should use this define...
/*
Gravimetric readings have some very loud signal types and a LOT of things that have signals, but in exchange are very difficult to mask in any way.
No matter how good your thermal insulation, your mass remains the same.
Some few things may however be able to affect gravimetric readings..
~(Wrecks should be one mass category lower than their respective vessel to emulate lost parts - more if very damaged)
*/

/*
Communications signature, which in reality is signals in general and not just communications. Lets hope central doesn't notice that little modification to the comms manager.
Usually, things that send this are objects constructed by someone, however this may vavery in some cases.
Note that they also need to be actively yelling. Colonised planets and stations tend to do this, warships not so much.
*/
#define COMMS_SIGNATURE_NONE 0
#define COMMS_SIGNATURE_SPOTTY 5 //Very weak signals, or ones being jammed.
#define COMMS_SIGNATURE_SPORADIC 10 //Sporadic signals.
#define COMMS_SIGNATURE_CASUAL 50 //Colonized things like stations or planets that do not try to hide tend to be like this
#define COMMS_SIGNATURE_BEACON 100 //Beacons tend to send wide-range signals as navigation assistance or to relay messages.
#define COMMS_SIGNATURE_DISTRESS 300 //Things calling for help, OR general wide-range transmissions to anyone that may want to listen
#define COMMS_SIGNATURE_PING 600 //Something with high-energetic pulses.
/*
Note that signature of repeated signals "should" be implemented to pulse in some sine-wave function style to emulate a cycling "signal".
Most common example for this are distress signals or other wide-range assistance requests.
*/

/*
Theta signature.
??????
*/
#define THETA_SIGNATURE_NONE 0
#define THETA_SIGNATURE_BLIP 3
#define THETA_SIGNATURE_WEAK 8
#define THETA_SIGNATURE_MEDIUM 12
#define THETA_SIGNATURE_HIGH 18
#define THETA_SIGNATURE_LARGE 30
#define THETA_SIGNATURE_HUGE 100
/*
01010010-01001001-01000110-01010100
*/

//Signature defines //END

#define COMSIG_JS_OVERMAP_SYSTEM_RELAY_SOUND "js_system_relay_sound"

#define COMSIG_JS_OVERMAP_SEND_SOUND "js_overmap_sound"
#define COMSIG_JS_OVERMAP_FTL "js_overmap_ftl"
#define COMSIG_JS_OVERMAP_STOP_SEND_SOUND "js_overmap_stop_sound"

/**
	Automatically subscribe mobs to these signals, as it affects them.
	Keep this up to date, please!
*/
#define COMSIG_JS_SIGNALS_TO_SUBSCRIBE_TO list(list(COMSIG_JS_OVERMAP_SEND_SOUND, (.proc/on_overmap_sound)), \
	list(COMSIG_JS_OVERMAP_FTL, (.proc/on_overmap_ftl)),\
	list(COMSIG_JS_OVERMAP_STOP_SEND_SOUND, (.proc/on_sound_cancelled))\
	)
