------------------------------------------------
-- User Interface of LUNAR 3D AG software package
------------------------------------------------
-- Lunar 3D AG

-- This file allows the user to input all neccessary parameters to get the wished ircular arc gear/pinion 


------------------------------------------------
-- CALL LIBARIES
------------------------------------------------

require "gear"
require "pinion"
require "res/language_resources"


--enable_variable_cache = true            -- to hold on parameters if UI is switched OFF


language_choice = ui_radio('Language/Sprache', {  {1, "English"}, {2, "Deutsch"} })

lang_res = get_translations()

ui_mode = ui_bool(lang_res["res_show_UI"][language_choice],true)       -- Boolean variable to show/hide UI

------------------------
-- User Interface
------------------------

if (ui_mode == true) then 
    counter = ui_scalar(lang_res["res_animate"][language_choice],2 ,1, 1000)                                       -- creating a scroll bar for rotating the gear/pinion

    m_in = ui_scalarBox(lang_res["res_module"][language_choice], 3,0.1)                                                    -- Module user input
    resolution = ui_radio(lang_res["res_resolution"][language_choice], {  
        {60, lang_res["res_resolution_low"][language_choice]}, 
        {80, lang_res["res_resolution_medium"][language_choice]}, 
        {100, lang_res["res_resolution_high"][language_choice]} })   -- resolution user input 
    height = ui_scalarBox(lang_res["res_height"][language_choice], 10, 1)                                                 -- height user input 

    input_fr_w_UI = ui_bool(lang_res["res_show_wheel_fillet"][language_choice],false)                                     -- Show/Hide Wheel Fillet user input 
    show_cutouts = ui_bool(lang_res["res_show_cutouts"][language_choice],false)                                           -- Show/Hide Wheel cutouts user input 
    z_w = ui_numberBox(lang_res["res_number_teeth_wheel"][language_choice], 37)                                       -- Wheel number of teeth user input
    r_s_in = ui_numberBox (lang_res["res_shaft_diameter_wheel"][language_choice],4)                                       -- Wheel shaft diameter user input 

    input_fr_p_UI = ui_bool(lang_res["res_show_pinion_fillet"][language_choice],false)                                    -- Show/Hide pinion Fillet user input 
    z_p = ui_numberBox(lang_res["res_number_teeth_pinion"][language_choice], 9)                                       -- Pinion number of teeth user input
    r_s_p_in = ui_numberBox (lang_res["res_shaft_diameter_pinion"][language_choice],4)                                    -- Pinion shaft diameter user input 


------------------------
-- Absolute Values
------------------------
-- making sure that all inputs are positive

    abs_m_in = math.abs(m_in)
    abs_z_w = math.abs(z_w)
    abs_z_p = math.abs(z_p)
    abs_r_s_in = math.abs(r_s_in) 


    ratio = abs_z_p/abs_z_w -- gear ratio
	


------------------------
-- Calling Gear and Pinion Functions
------------------------
create_pinion(counter, 1 , abs_z_p, abs_m_in, resolution, height, abs_z_w, r_s_p_in, input_fr_p_UI, 0)
create_gear(counter, ratio, abs_z_w, abs_m_in, resolution, height, input_fr_w_UI, show_cutouts, abs_z_p, abs_r_s_in, ratio)


else
    printing_mode = ui_bool(lang_res["res_printing_mode"][language_choice], false)
	
		if (printing_mode == true) then

--	show_system = ui_bool('Show System', false)

	--	if (show_system == true) then 
		
--	create_pinion(counter, 1 , abs_z_p, abs_m_in, resolution, height, abs_z_w, r_s_p_in, input_fr_p_UI, pinion_offset, pinion_translation_offset)
--	create_gear(counter, ratio, abs_z_w, abs_m_in, resolution, height, input_fr_w_UI, show_cutouts, abs_z_p, abs_r_s_in, ratio)
	
--		end 


	-- screenshot()
    show_pinion = ui_bool(lang_res["res_show_pinion"][language_choice], false)
	
    if (show_pinion == true) then 
	create_pinion(counter, 1 , abs_z_p, abs_m_in, resolution, height, abs_z_w, r_s_p_in, input_fr_p_UI, 30)



    end 

    show_gear = ui_bool(lang_res["res_show_gear"][language_choice], false)

    if (show_gear == true) then 
	create_gear(counter, ratio, abs_z_w, abs_m_in, resolution, height, input_fr_w_UI, show_cutouts, abs_z_p, abs_r_s_in, ratio)

    end
		 -- pinion_translation_offset = ui_numberBox('Seperation Distance',50) 

    take_screenshot = ui_bool(lang_res["res_take_screenshot"][language_choice], false)
	
	if (take_screenshot == true) then 
	
	screenshot()
	
	end 

end


end











balance_cube_1 = ccube(1)
new_cube = translate (100,100,0) * balance_cube_1 
emit(new_cube)


balance_cube_2 = ccube(1)
new_cube2 = translate (-100,-100,0) * balance_cube_2
emit(new_cube2)


