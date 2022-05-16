require "main3"
require "lua_pinion"

counter = ui_scalarBox('Animate/Rotate',0 ,1) 

m_in = ui_scalarBox('Module',3,0.1)
height = ui_scalarBox('Height', 10, 1) 


z_p = 9
z_w = 35
ratio = z_p/z_w 
create_pinion(counter, ratio * z_w , z_p, m_in, height)
create_gear(counter, ratio * z_p, z_w, m_in, height)