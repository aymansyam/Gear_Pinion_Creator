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


enable_variable_cache = true            -- to hold on parameters if UI is switched OFF

ui_mode = ui_bool('show UI',true)       -- Boolean variable to show/hide UI

------------------------
-- User Interface
------------------------

if (ui_mode == true) then 
    counter = ui_scalar('Animate/Rotate',2 ,1, 1000)                                       -- creating a scroll bar for rotating the gear/pinion

    m_in = ui_scalarBox('Module',3,0.1)                                                    -- Module user input
    resolution = ui_radio('Resolution', {  {60, "low"}, {80, "medium"}, {100, "high"} })   -- resolution user input 
    height = ui_scalarBox('Height', 10, 1)                                                 -- height user input 

    input_fr_w_UI = ui_bool('Show Wheel Fillet',false)                                     -- Show/Hide Wheel Fillet user input 
    show_cutouts = ui_bool('Show Cutouts',false)                                           -- Show/Hide Wheel cutouts user input 
    z_w = ui_numberBox('Number of Teeth, Wheel', 37)                                       -- Wheel number of teeth user input
    r_s_in = ui_numberBox ('Shaft Diameter wheel',4)                                       -- Wheel shaft diameter user input 

    input_fr_p_UI = ui_bool('Show Pinion Fillet',false)                                    -- Show/Hide pinion Fillet user input 
    z_p = ui_numberBox('Number of Teeth, Pinion', 9)                                       -- Pinion number of teeth user input
    r_s_p_in = ui_numberBox ('Shaft Diameter Pinion',4)                                    -- Pinion shaft diameter user input 
    pinion_offset = ui_scalarBox('Pinion Offset', 0, 1)                                    -- Pinion rotational offset user input
    pinion_translation_offset = ui_numberBox('Seperation Distance',50)                     -- Seperation Distance user input

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
create_pinion(counter, 1 , abs_z_p, abs_m_in, resolution, height, abs_z_w, r_s_p_in, input_fr_p_UI, pinion_offset, pinion_translation_offset)
create_gear(counter, ratio, abs_z_w, abs_m_in, resolution, height, input_fr_w_UI, show_cutouts, abs_z_p, abs_r_s_in, ratio)

else
    printing_mode = ui_bool('Printing Mode', false)         -- choosing Printing Mode user input
	
		if (printing_mode == true) then
	
--	show_system = ui_bool('Show System', false)

	--	if (show_system == true) then 
		
--	create_pinion(counter, 1 , abs_z_p, abs_m_in, resolution, height, abs_z_w, r_s_p_in, input_fr_p_UI, pinion_offset, pinion_translation_offset)
--	create_gear(counter, ratio, abs_z_w, abs_m_in, resolution, height, input_fr_w_UI, show_cutouts, abs_z_p, abs_r_s_in, ratio)
	
--		end 


	-- screenshot()
    show_pinion = ui_bool('Show Pinion', false)         -- Show/Hide pinion user choice
	
    if (show_pinion == true) then 
	create_pinion(counter, 1 , abs_z_p, abs_m_in, resolution, height, abs_z_w, r_s_p_in, input_fr_p_UI, pinion_offset, pinion_translation_offset)

    end 

    show_gear = ui_bool('Show Gear', false)             -- Show/Hide gear user choice

    if (show_gear == true) then 
	create_gear(counter, ratio, abs_z_w, abs_m_in, resolution, height, input_fr_w_UI, show_cutouts, abs_z_p, abs_r_s_in, ratio)

    end
	
    take_screenshot = ui_bool('Take screenshot', false)     -- Saving a screenshot of the workspace
	
	if (take_screenshot == true) then 
	
	screenshot()
	
	end 

end


end

