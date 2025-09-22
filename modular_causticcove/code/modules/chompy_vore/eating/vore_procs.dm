//Vore procs! Can be delayed or instant.
//If delayed, the chain is: perform_the_nom -> begin_delayed_nom -> vore_sanity_checks -> attempt_to_devour_prey -> devour_and_move_prey
//If instant, the chain is: perform_the_nom -> begin_instant_nom -> vore_sanity_checks -> devour_and_move_prey



/**
 * Vore proc that actually does the main part of eating
 * Written to be compatible with instant or delayed noms. Alternatively, call begin_instant_nom if the vore is going to be instant.
 * Params: user, prey, pred, belly, delay_time
 */
/mob/living/proc/perform_the_nom(mob/living/user, mob/living/prey, mob/living/pred, obj/belly/belly, delay_time)
	if(!delay_time || delay_time > 0)
		return begin_delayed_nom(user, prey, pred, belly, delay_time)
	else //This is here to catch when delay_time is set to a negative number, aka, 'we want this to be instant.' Any uses of this should be replaced by begin_instant_nom
		return begin_instant_nom(user, prey, pred, belly)

/**
 * Vore proc that actually does the main part of eating
 * Params: user, prey, pred, belly, delay_time
 */
/proc/begin_delayed_nom(mob/living/user, mob/living/prey, mob/living/pred, obj/belly/belly, delay_time)
	if(vore_sanity_checks(user, prey, pred, belly))
		return attempt_to_devour_prey(user, prey, pred, belly, delay_time)
	else
		return FALSE

/**
 * Vore proc that actually tries to instantly eat the preey
 * Params: user, prey, pred, belly
 * NOTE: THIS MUST NOT SLEEP, THIS IS CALLED BY THINGS THAT USE SIGNAL_HANDLER
 */
/mob/living/proc/begin_instant_nom(mob/living/user, mob/living/prey, mob/living/pred, obj/belly/belly)
	SHOULD_NOT_SLEEP(TRUE)
	if(vore_sanity_checks(user, prey, pred, belly))
		return devour_and_move_prey(user, prey, pred, belly)
	else
		return FALSE //We failed

/proc/attempt_to_devour_prey(mob/living/user, mob/living/prey, mob/living/pred, obj/belly/belly, delay_time)
	var/message_range = get_vore_message_range(user, pred, prey, belly)
	var/attempt_msg = generate_vore_attempt_message(user, prey, pred, belly)
	// Announce that we start the attempt!
	user.visible_message(attempt_msg, vision_distance = message_range)
	// Now give the prey time to escape... return if they did
	var/swallow_time
	if(delay_time < 0) //Shouldn't happen, but let's just be sane..
		swallow_time = 0
	else if(delay_time)
		swallow_time = delay_time
	else
		swallow_time = ishuman(prey) ? belly.human_prey_swallow_time : belly.nonhuman_prey_swallow_time

	//Timer and progress bar
	if(!do_after(user, swallow_time, target = prey))
		return FALSE // Prey escaped (or user disabled) before timer expired.

	// If we got this far, nom successful! Announce it and move the prey!
	return devour_and_move_prey(user, prey, pred, belly, message_range)

/proc/devour_and_move_prey(mob/living/user, mob/living/prey, mob/living/pred, obj/belly/belly, message_range)
	var/success_msg = generate_vore_success_message(user, prey, pred, belly)
	if(!message_range)
		message_range = get_vore_message_range(user, pred, prey, belly)
	user.visible_message(success_msg, vision_distance = message_range)
	// Actually shove prey into the belly.
	if(istype(prey.loc, /obj/item/micro))
		var/obj/item/micro/H = prey.loc
		for(var/mob/living/M in H.contents)
			belly.nom_mob(M, user)
			if(M.loc == H) // In case nom_mob failed somehow.
				M.forceMove(get_turf(user))
		H.held_mob = null
		qdel(H)
	else
		belly.nom_mob(prey, user)

	user.update_icon()
	return TRUE

///VORE HELPER PROCS UNDER HERE

/**
 * Vore helper proc that creates the vore success message we'll be using
 * Params: user, prey, pred, belly, delay_time
 * Returns: success_msg
 */
/proc/generate_vore_success_message(mob/living/user, mob/living/prey, mob/living/pred, obj/belly/belly)
	//Determining vore attempt privacy
	var/success_msg = "ERROR: Vore message couldn't be created. Notify a dev. (sc)"

	if(prey.is_slipping)
		success_msg = span_warning("[prey] suddenly slides into [pred]'s [lowertext(belly.name)]!")
	else if(pred.is_slipping)
		success_msg = span_warning("[prey] suddenly slips inside of [pred]'s [lowertext(belly.name)] as [pred] slides into them!")
	else if(user == pred) //Feeding someone to yourself
		success_msg = span_warning("[pred] manages to [lowertext(belly.vore_verb)] [prey] into their [lowertext(belly.name)]!")
	else //Feeding someone to another person
		success_msg = span_warning("[user] manages to make [pred] [lowertext(belly.vore_verb)] [prey] into their [lowertext(belly.name)]!")
	return success_msg

/**
 * Vore proc helper that creates the vore attempt message we'll be using
 * Params: user, prey, pred, belly, delay_time
 * Returns: attempt_msg
 */
/proc/generate_vore_attempt_message(mob/living/user, mob/living/prey, mob/living/pred, obj/belly/belly)
	//Determining vore attempt privacy
	var/attempt_msg = "ERROR: Vore message couldn't be created. Notify a dev. (sc)"

	if(prey.is_slipping)
		attempt_msg = span_warning("It seems like [prey] is about to slide into [pred]'s [lowertext(belly.name)]!")
	else if(pred.is_slipping)
		attempt_msg = span_warning("It seems like [prey] is gonna end up inside [pred]'s [lowertext(belly.name)] as [pred] comes sliding over!")
	else if(user == pred) //Feeding someone to yourself
		attempt_msg = span_warning("[pred] is attempting to [lowertext(belly.vore_verb)] [prey] into their [lowertext(belly.name)]!")
	else //Feeding someone to another person
		attempt_msg = span_warning("[user] is attempting to make [pred] [lowertext(belly.vore_verb)] [prey] into their [lowertext(belly.name)]!")
	return attempt_msg

/**
 * Vore proc helper that finds what range our message should be
 * Params: user, prey, pred, belly, delay_time
 * Returns: attempt_msg
 */
/proc/get_vore_message_range(mob/living/user, mob/living/prey, mob/living/pred, obj/belly/belly)
	var/message_range = world.view
	if(!pred.is_slipping && !prey.is_slipping) //We only care about privacy preference if it's NOT a spontaneous vore.
		switch(belly.eating_privacy_local) //if("loud") case not added, as it would not modify message_range
			if("default")
				if(pred.eating_privacy_global)
					message_range = 1
			if("subtle")
				message_range = 1
	return message_range

/**
 * Vore proc helper that sees if we can actually do the vore attempt
 * Params: user, prey, pred, belly
 * Returns: TRUE/FALSE
 * FALSE: Can not eat.
 * TRUE: Can eat.
 */
/proc/vore_sanity_checks(mob/living/user, mob/living/prey, mob/living/pred, obj/belly/belly)
	//Sanity
	if(!user || !prey || !pred || !istype(belly) || !(belly in pred.vore_organs))
		return FALSE
	if(pred == prey)
		return FALSE

	//Final distance check. Time has passed, menus have come and gone. Can't use do_after adjacent because doesn't behave for held micros
	var/user_to_pred = get_dist(get_turf(user),get_turf(pred))
	var/user_to_prey = get_dist(get_turf(user),get_turf(prey))

	if(user_to_pred > 1 || user_to_prey > 1)
		return FALSE

	if(!prey.devourable)
		to_chat(user, span_notice("They aren't able to be devoured."))
		log_and_message_admins("attempted to devour [key_name_admin(prey)] against their prefs ([prey ? ADMIN_JMP(prey) : "null"])", user)
		return FALSE
	if(prey.absorbed || pred.absorbed)
		to_chat(user, span_warning("They aren't aren't in a state to be devoured."))
		return FALSE
	return TRUE
