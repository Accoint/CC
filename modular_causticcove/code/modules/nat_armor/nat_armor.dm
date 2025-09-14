/obj/item/clothing/suit/roguetown/armor/skin_armor/natural_armor
	slot_flags = null
	name = "natural armor"
	desc = ""
	icon_state = null
	body_parts_covered = FULL_BODY
	body_parts_inherent = FULL_BODY
	armor = ARMOR_NATURAL
	prevent_crits = list(BCLASS_CUT, BCLASS_CHOP, BCLASS_STAB, BCLASS_BLUNT, BCLASS_TWIST)
	blocksound = SOFTHIT
	blade_dulling = DULLING_BASHCHOP
	sewrepair = FALSE
	max_integrity = 600
	item_flags = DROPDEL
	var/next_regen
	var/mob/living/carbon/human/skin_haver


/obj/item/clothing/suit/roguetown/armor/skin_armor/natural_armor/Initialize(mapload)
	. = ..()
	skin_haver = loc
	trait_add(skin_haver)
	START_PROCESSING(SSobj, src)
	return

/obj/item/clothing/suit/roguetown/armor/skin_armor/natural_armor/Destroy()
	trait_remove(skin_haver)
	STOP_PROCESSING(SSobj, src)
	. = ..()

/obj/item/clothing/suit/roguetown/armor/skin_armor/natural_armor/process()
	if(next_regen > world.time)
		return
	regenerate(skin_haver)
	next_regen = world.time + 30 SECONDS

/obj/item/clothing/suit/roguetown/armor/skin_armor/natural_armor/proc/trait_add(mob/living/user)
	skin_haver = user
	ADD_TRAIT(skin_haver, TRAIT_NATURAL_ARMOR, TRAIT_GENERIC)
	return

/obj/item/clothing/suit/roguetown/armor/skin_armor/natural_armor/proc/trait_remove(mob/living/user)
	skin_haver = user
	REMOVE_TRAIT(skin_haver, TRAIT_NATURAL_ARMOR, TRAIT_GENERIC)
	return

/obj/item/clothing/suit/roguetown/armor/skin_armor/natural_armor/proc/regenerate(mob/living/user)
	//mob wearing the natural armor
	skin_haver = user

	//making sure that the thing wearing the armor is human
	if(!istype(skin_haver))
		return

	//no need to regenerate if armor is already full
	if(obj_integrity >= max_integrity)
		return
	
	//we can't regenerate if we have no nutrition to do it with
	if(skin_haver.nutrition <=0)
		return

	//we can only regenerate 100 points of integrity at a time
	var/regen_amt = min(100, max_integrity - obj_integrity)
	obj_integrity += regen_amt

	 //Every 1 point of integrity is 2 points of hunger
	skin_haver.adjust_nutrition(-regen_amt * 2)

	//some user feed back for regeneration
	if(obj_integrity < max_integrity)
		to_chat(skin_haver, span_smallgreen("You feel your natural protection knitting itself back together..."))
		return
	//letting the owner know it's fully restored
	else
		to_chat(skin_haver, span_green("You feel your natural protection has fully healed!"))
		return
