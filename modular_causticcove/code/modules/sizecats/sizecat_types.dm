/datum/sizecat/none
	name = "None"
	desc = "You are extraordinarily ordinary!"

/datum/sizecat/giant
	name = "Giant"
	desc = "I've always been larger, stronger and hardier than the average person. I tend to lumber around a lot, and my immense size can break down frail, wooden doors."
	added_traits = list(TRAIT_BIGGUY)
	custom_text = "Increases your sprite size."

/datum/sizecat/giant/apply_to_human(mob/living/carbon/human/recipient)
	recipient.transform = recipient.transform.Scale(1.25, 1.25)
	recipient.transform = recipient.transform.Translate(0, (0.25 * 16))
	recipient.update_transform()

/datum/sizecat/macro
	name =  "Macro"
	desc = "Somehow, due to a freak accident or magical energies, my form is absolutely colossal. My strength and body are second to none. However, the ground beneath shifts, causing my speed to suffer greatly."
	added_traits = list(TRAIT_MACRO)
	custom_text = "Greatly increases your sprite size. Makes you very strong and durable but reduces your speed close to, if not to the minimum."

/datum/sizecat/macro/apply_to_human(mob/living/carbon/human/recipient)
	recipient.transform = recipient.transform.Scale(2, 2)
	recipient.transform = recipient.transform.Translate(0, (0.25 * 35))
	recipient.update_transform()
	recipient.change_stat(STATKEY_STR, 8)
	recipient.change_stat(STATKEY_WIL, 8)
	recipient.change_stat(STATKEY_CON, 8)
	recipient.change_stat(STATKEY_SPD, -14)

/datum/sizecat/small
	name = "Small"
	desc ="Somehow, due to a freak accident or magical energies, my form is below average in height.  My strength and body are impacted.  However, my smaller size allows me to slip blows that would hit others."
	added_traits = list(TRAIT_SMALL)
	custom_text = "Reduces your sprite size.  Makes you agile but slow.  In addition, your stealth will be strengthened.  Your strength and durability will be lower than average."

/datum/sizecat/small/apply_to_human(mob/living/carbon/human/recipient)
	recipient.transform = recipient.transform.Scale(0.5, 0.5)
	recipient.transform = recipient.transform.Translate(0, (0.5 * 8))
	recipient.update_transform()
	recipient.change_stat(STATKEY_STR, -5)
	recipient.change_stat(STATKEY_WIL, -2)
	recipient.change_stat(STATKEY_CON, -5)
	recipient.change_stat(STATKEY_SPD, -7)
	recipient.pass_flags = PASSTABLE | PASSMOB
	recipient.adjust_skillrank(/datum/skill/misc/sneaking, 1, TRUE)
	recipient.adjust_skillrank(/datum/skill/misc/stealing, 1, TRUE)

/datum/sizecat/micro
	name = "Micro"
	desc ="Somehow, due to a freak accident or magical energies, my form is absolutely tiny. My strength and body are lacking. However, my dimutive size allows me to dodge blows that would otherwise hit others."
	added_traits = list(TRAIT_MICRO)
	custom_text = "Greatly reduces your sprite size. Makes you very agile, but slow. In addition, your stealth will be strengthened greatly. Your strength and durability will be close to, if not the minimum however."

/datum/sizecat/micro/apply_to_human(mob/living/carbon/human/recipient)
	recipient.transform = recipient.transform.Scale(0.2, 0.2)
	recipient.transform = recipient.transform.Translate(0, (0.25 * 8))
	recipient.update_transform()
	recipient.change_stat(STATKEY_STR, -10)
	recipient.change_stat(STATKEY_WIL, -4)
	recipient.change_stat(STATKEY_CON, -10)
	recipient.change_stat(STATKEY_SPD, -14)
	recipient.pass_flags = PASSTABLE | PASSMOB
	recipient.adjust_skillrank(/datum/skill/misc/sneaking, 2, TRUE)
	recipient.adjust_skillrank(/datum/skill/misc/stealing, 2, TRUE)
