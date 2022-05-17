require "gear"
require "pinion"

counter = ui_scalar('Animate/Rotate',2 ,1, 1000) 

m_in = ui_scalarBox('Module',3,0.1)
resolution = ui_radio('Resolution', {  {60, "low"}, {80, "medium"}, {100, "high"} })
height = ui_scalarBox('Height', 10, 1)

input_fr_w_UI = ui_bool('Show Wheel Fillet',false)
show_cutouts = ui_bool('Show Cutouts',false)
z_w = ui_numberBox('Number of Teeth, Wheel', 37)
r_s_in = ui_numberBox ('Shaft Diameter wheel',4)

input_fr_p_UI = ui_bool('Show Pinion Fillet',false)
z_p = ui_numberBox('Number of Teeth, Pinion', 9)
r_s_p_in = ui_numberBox ('Shaft Diameter Pinion',4)
pinion_offset = ui_scalarBox('Pinion Offset', 0, 1)

abs_m_in = math.abs(m_in)
abs_z_w = math.abs(z_w)
abs_z_p = math.abs(z_p)
abs_r_s_in = math.abs(r_s_in) 

ratio = abs_z_p/abs_z_w 
create_pinion(counter, 1 , abs_z_p, abs_m_in, resolution, height, abs_z_w, r_s_p_in, input_fr_p_UI, pinion_offset)
create_gear(counter, ratio, abs_z_w, abs_m_in, resolution, height, input_fr_w_UI, show_cutouts, abs_z_p, abs_r_s_in, ratio)

