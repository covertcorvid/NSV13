/*
These datums serve as the sensor modes for an ITS console. Which of them a console has access to determines what the console's capabilities are.
They also decide a variety of base variables for the sensors (such as the color)
*/

//All possible datums will be managed in this one global list and then referenced on the actual sensor consoles - please don't delete them kthank.
GLOBAL_LIST_EMPTY(its_sensor_datums)

/datum/its_sensor_datum
	///The name this sensor type appears wth on the selection.
	var/name = "Sensor basetype (why can you see this?)"
	///The key tgui uses to associate this with potential special stuff
	var/spec_key = "none" // normal (renders) / none (doesn't render)
	///The name the signature has (in the assoc list of ships), aka what this scans for
	var/signature_key = "error"
	///The color the ITS circle of this sensor mode has.
	var/sig_color = "#000000"
	///The base interference value.
	var/interference_impact = 30
	///Random multiplier from 0 to this value applied to interference.
	var/interference_resolution = 31
	///Multiplies the above to reduce it to a relatively small but granular multiplier to interference.
	var/interference_cut = 0.01
	///This determines how interference is generated. Usually, it it fully random, but this may vary between sensor modes...
	var/interference_mode = "normal" //ITS-TODO - actually implement this!

	///Signatures lower than this post-angle-spread are ignored (initial signatures with a lower value are still used).
	var/signature_cutoff = 10
	///A hard cap on angular direcional spread a signature can have.
	var/max_angular_spread = 15
	///Signatures are multiplied by this when they propagate to a new angle.
	var/signature_propagation_multiplier = 0.8 //The todo below effectively replaces this

	///ITS-TODO - values to handle possible decay for range, or different angular decay values!
	/*
	///Scaling by distance. Usually does not reduce by distance, but some signal types might!
	var/dist_scaling = "none" //none / linear-flat / linear-percent / inverse / inverse-exponential / log-curve / hyperbolic-curve
	///Modifier for the above - Applies differently to each type.
	var/dist_scaling_mod = 0
	/*
	Effects:
	none: none.
	linear-flat: (sig - dist * mod)
	linear-percent: (sig - dist * (mod% of sig))
	inverse: (sig * (1 / (dist * mod))
	inverse-exponential: (sig * (( 1/ dist) ^ mod))
	log-curve: ???
	hyperbolic-curve: ???????
	*/


	///Scaling by angle distance. Instead of a flat reduction multiplier, supports alternate options
	var/angular_dist_scaling = "multiplier" //none / multiplier / linear-flat / log-curve / hyperbolic-curve / inverse / inverse-exponential
	///Modifier for the above. - Applies differently to each type.
	var/angular_dist_scaling_mod = 0.8#
	/*
	Effects:
	none: none.
	multiplier: current sig * mod
	linear-flat: current sig - mod
	log-curve: ???? lmao
	hyperbolic-curve: ???????
	.. I still have to actually think about these two oops!
	inverse: current sig * (1 / mod)
	inverse-exponential: current sig * ((1 / [magicnumber]) ^ mod)
	*/

	*/

//Actual sensor datum implementations.

//Disabled
/datum/its_sensor_datum/off
	name = "Offline"

//IR. Hot things.
/datum/its_sensor_datum/ir
	name = "IR"
	spec_key = "normal"
	signature_key = SIG_IR
	sig_color = "#e96f0c"

//Gravimetric. Heavy things.
/datum/its_sensor_datum/grav
	name = "Gravimetric"
	spec_key = "normal"
	signature_key = SIG_GRAV
	sig_color = "#1c55d1"

//Comms / signals. Yelling things.
/datum/its_sensor_datum/comms
	name = "Communications"
	spec_key = "normal"
	signature_key = SIG_COMMS
	sig_color = "#137e10"

//Theta. ??????
/datum/its_sensor_datum/theta
	name = "Theta signature"
	spec_key = "normal"
	signature_key = SIG_THETA
	sig_color = "#810fdf"
	interference_impact = 60 //Preliminary - I probably want some kind of "ordered chaos" for this one's interference, so probably a function - ITS-TODO
	interference_resolution = 45
