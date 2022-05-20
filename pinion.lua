
------------------------------------------------
-- CIRCULAR ARC GEARS - PINION
------------------------------------------------

-- This file calculates all the neccessary values and points 
-- for desingning the pinion for a circular arc gear pair 

-- Lunar 3D AG

------------------------------------------------
-- CALL REQUIERED FUNCTIONS & LIBARIES
------------------------------------------------

require "lib/functions_array"
require "lib/functions_gear"



function create_pinion(counter, increment, z_p_in, m_in, resolution, height, z_w_in, r_s_p_in, input_fr_p_UI, offset)



------------------------------------------------
-- USER INPUTS
------------------------------------------------


m = m_in						-- Module
z_w = z_w_in					-- Number of teeth wheel
z_p = z_p_in					-- Number of teeth pinion

r_s = r_s_p_in					-- pinion shaft diameter

input_fr_p = input_fr_p_UI		-- 0 = No fillet radius	1 = Fillet radius

error_limit = 0.000001			-- Error Limit for later used numerical search

------------------------------------------------
-- BASIC CALCULATIONS
------------------------------------------------

pi = 3.14159265					-- pi

pitch = m* pi					-- Reference pitch
u = z_w / z_p					-- Gear ratio
d_w = m * z_w					-- Pitch diameter wheel
r_w = d_w / 2					-- Pitch radius wheel
d_p = m * z_p					-- Pitch diameter pinion
r_p = d_p / 2					-- Pitch radius pinion

hf_w = m * math.pi/2
hf_w_r = r_w - hf_w

hf_w = m * pi / 2									-- Dedendum height wheel
hf_w_r = r_w - hf_w									-- Dedendum radius wheel

f_a = calc_addendum_factor(error_limit, u, z_p)		-- Addendum factor (via numerical search)
h_a = 0.95 * f_a * m								-- Addendum height
ha_w_r = r_w + h_a									-- Addendum radius wheel

f_r = 1.4 * f_a										-- Addendum radius factor
a_r = f_r * m										-- Addendum arc radius 


hf_p = (f_a * 0.95 + 0.4) * m						-- Dedendum height pinion
hf_p_r = r_p - hf_p									-- Dedendum radius pinion

------------------------------------------------
-- DESIGN OF TEETH PROFILE --
------------------------------------------------

-- Pitch circle pinion
temp = calc_circle_pt(hf_p_r, 200)
x_ded_w = temp["X"]
y_ded_w = temp["Y"]

-- Determine the tooth width (according to https://www.csparks.com/watchmaking/CycloidalGears/index.jxl)
if z_p <= 10 then 
	t_w = 1.05
else
	t_w = 1.25
end

------------------------------------------------
-- Determine the addendum style (according to British Standard 978: Part 2)
if z_p <= 7 then			-- high ogvial
	f_a_p = 0.855
	f_r_p = 1.050
	round = 0
elseif z_p == 8 then 		-- medium ogvial
	f_a_p = 0.670
	f_r_p = 0.700
	round = 0
elseif z_p == 9 then		-- medium ogvial
	f_a_p = 0.670
    f_r_p = 0.700
    round = 0
elseif z_p == 10 then		-- round top
    f_a_p = 0.525
    f_r_p = 0.525
    round = 1
elseif z_p >= 11 then		-- round top
    f_a_p = 0.625
    f_r_p = 0.625
    round = 1
end
------------------------------------------------

-- Calculate the addendum circle radius and the addendum arc radius
h_a_p = 0.95 * f_a_p * m		-- Addendum height
ha_p_r = r_p + h_a_p			-- Addendum radius

a_r_p = f_r_p * m				-- Addendum arc radius

------------------------------------------------

-- DEDENDUM PROFILE

-- Calculate half of the angle the tooth is using
theta = t_w/2 * m / r_p

-- Draw a rotated Dedendum profile from the dedendum circle to the pitch circle
dedendum_pt_st = { {0,0} , { hf_p_r, r_p } }

rot_ded = theta

dedendum_pt_p = rot_table_mat(rot_ded, dedendum_pt_st)


------------------------------------------------

-- ADDENDUM PROFILE

-- high ogvial or medium ogvial

if round == 0 then

	--Find center point for addendum radius (using a rhombus-approach, see
	--https://math.stackexchange.com/questions/1781438/finding-the-center-of-a-circle-given-two-points-and-a-radius-algebraically)
    
	-- Distance between the start of the arc on the pitch circle to end of
    -- the arc at the addendum circle at x = 0
	
	start_arc_p = { { dedendum_pt_p[1][2] } , { dedendum_pt_p[2][2] } }
	end_arc_p = { { 0 }, { ha_p_r } }
	dist_arc = distance(end_arc_p[1][1], end_arc_p[2][1], dedendum_pt_p[1][2], dedendum_pt_p[2][2])
	
	-- Finding the middle point of the rhombus
	vec_rhombus = { { dedendum_pt_p[1][2] - end_arc_p[1][1] }, { dedendum_pt_p[2][2] - end_arc_p[2][1] } }
	
	vec_rhombus = arr_div1(arr_inv(vec_rhombus), math.sqrt(vec_rhombus[1][1]^2 + vec_rhombus[2][1]^2)) 
	rhombus_cent = arr_subt2(arr_inv(start_arc_p), arr_mult1(vec_rhombus, dist_arc/2))
	
	-- Calculate distance from rhombus center to the center of the arc
	b = math.sqrt(a_r_p^2 - (dist_arc / 2)^2)
	
	-- Draw vector, perpenicular to the vec_rhombus, with length of b starting
    -- from the rhombus_center
	vec_arc_center = { -vec_rhombus[2], vec_rhombus[1] }
	
	arc_center = arr_add2(rhombus_cent, arr_mult1(vec_arc_center, b))
	
	-- Calculate the arc
	angle_start = math.atan2(dedendum_pt_p[2][2] - arc_center[2], dedendum_pt_p[1][2] - arc_center[1])
	angle_end = math.atan2(end_arc_p[2][1] - arc_center[2], end_arc_p[1][1] - arc_center[1])
	
	-- Create array for the addendum arc points
	
	temp = arc_circle(angle_start, angle_end, resolution, arc_center[1], arc_center[2], a_r_p)
	x_arc_p = temp.X
	y_arc_p = temp.Y
	
	-- Round Top / Semicircle
elseif round == 1 then
	arc_center = { 0, r_p }
	end_arc_p = { 0, ha_p_r }
	
	-- Calculate the arc
	angle_start = math.atan2(dedendum_pt_p[2][2] - arc_center[2], dedendum_pt_p[1][2] - arc_center[1])
	angle_end = math.atan2(end_arc_p[2] - arc_center[2], end_arc_p[1] - arc_center[1])
	
	-- Create arry for the addendum arc points
	temp = arc_circle(angle_start, angle_end - 2*math.pi, resolution, arc_center[1], arc_center[2], a_r_p)
	x_arc_p = temp.X
	y_arc_p = temp.Y
end

------------------------------------------------
-- FILLET FPROFILE
------------------------------------------------
-- input_fr_w (false = No fillet curve	true = Fillet curve)

if input_fr_p == true then

	pt_de_p = { 0, hf_p_r }
	test = { { pt_de_p[1] }, { pt_de_p[2] } }
	
	pt_de_p = rot_table_mat(2 * math.pi / (2 * z_p), test)
	
	
	dist_ded_middle = distance(pt_de_p[1][1], pt_de_p[2][1], 0, 0)
	A = Point(pt_de_p[1][1], pt_de_p[2][1], 0)
	B = Point(dedendum_pt_p[1][1], dedendum_pt_p[2][1], 0)
	
	crossProduct = A ^ B
	dotProduct = A..B
	
	normalProduct = math.sqrt(crossProduct[1]^2 + crossProduct[2]^2 + crossProduct[3]^2)
	theta_ded = math.atan2(normalProduct, dotProduct)
	
	fillet_radius = (dist_ded_middle * math.sin(theta_ded)) / (1 - math.sin(theta_ded))
	unit_A = arr_div1(A, math.sqrt(A[1]^2 + A[2]^2 + A[3]^2))
	
	
	
	-- SOLVE FOR WHEN Y = 0
	fillet_circle_center = arr_add2({ pt_de_p[1][1], pt_de_p[2][1] }, arr_mult1({ unit_A[1], unit_A[2] }, fillet_radius))
	fillet_circle_center_x = fillet_circle_center[1]
	fillet_circle_center_y = fillet_circle_center[2]
	
	dist_ded_fillet_start = (dist_ded_middle + fillet_radius) * math.cos(theta_ded)
	
	unit_B = arr_div1(B, math.sqrt(B[1]^2 + B[2]^2 + B[3]^2))
	start_fillet_ded = arr_mult1(unit_B, dist_ded_fillet_start)
	
	dedendum_pt_p[1][1] = start_fillet_ded[1]
	dedendum_pt_p[2][1] = start_fillet_ded[2]
	
	temp_x = arr_mult1(dedendum_pt_p[1], -1)
	temp_y = dedendum_pt_p[2]
	temp = arr_merge({ temp_x }, { temp_y })
	
	rot_angle = -2 * math.pi / z_p
	temp_ded = rot_table_mat(-rot_angle, temp)
	
	angle_start_dd = math.atan2(dedendum_pt_p[2][1] - fillet_circle_center_y, dedendum_pt_p[1][1] - fillet_circle_center_x )
	angle_end_dd = math.atan2(temp_ded[2][1] - fillet_circle_center_y, temp_ded[1][1] - fillet_circle_center_x)

	
	
	temp_c = arc_circle(angle_start_dd, angle_end_dd, resolution, fillet_circle_center_x, fillet_circle_center_y, fillet_radius)

	fillet_x = temp_c.X
	fillet_y = temp_c.Y
	temptemp = arr_merge(arr_reverse(fillet_x), arr_reverse(dedendum_pt_p[1]))
	
	-- Combine all the points of the left tooth profile into one matrix

	tooth_profile_left_x = arr_merge(temptemp, x_arc_p)
	temptemp = arr_merge(arr_reverse(fillet_y), arr_reverse(dedendum_pt_p[2]))
	tooth_profile_left_y = arr_merge(temptemp, y_arc_p)
  
  	-- Mirror the left x-tooth profile and create the right tooth profile

	tooth_profile_right_x = arr_mult1(arr_merge(arr_reverse(dedendum_pt_p[1]), x_arc_p), -1)
	tooth_profile_right_y = arr_merge(arr_reverse(dedendum_pt_p[2]), y_arc_p)
	


end

-- input_fr_w (false = No fillet curve	true = Fillet curve)

if input_fr_p == false then

	pt_de_p = { 0, hf_p_r }
	test = { { pt_de_p[1] }, { pt_de_p[2] } }
	pt_de_p = rot_table_mat(2 * math.pi / (2 * z_p), test)

	angle_start_dd = math.atan2(dedendum_pt_p[2][1] - 0, dedendum_pt_p[1][1] - 0 )
	angle_end_dd = math.atan2(pt_de_p[2][1] - 0, pt_de_p[1][1] - 0)
	
	temp_c = arc_circle(angle_start_dd, angle_end_dd, resolution, 0, 0, hf_p_r)
	x_ded_p = temp_c.X
	y_ded_p = temp_c.Y
	
	-- Combine all the points of the left tooth profile into one matrix

	temptemp = arr_merge(arr_reverse(x_ded_p), arr_reverse(dedendum_pt_p[1]))
	tooth_profile_left_x = arr_merge(temptemp, x_arc_p)

	temptemp = arr_merge(arr_reverse(y_ded_p), arr_reverse(dedendum_pt_p[2]))
	tooth_profile_left_y = arr_merge(temptemp, y_arc_p)
	
  	-- Mirror the left x-tooth profile and create the right tooth profile

	tooth_profile_right_x = arr_mult1(tooth_profile_left_x, -1)
	tooth_profile_right_y = tooth_profile_left_y

end

------------------------------------------------
-- DESIGN OF GEAR PROFILE --
------------------------------------------------

-- Combine left and right side of the teeth into one profile
tooth_profile_x_p = arr_merge(tooth_profile_left_x, arr_reverse(tooth_profile_right_x))
tooth_profile_y_p = arr_merge(tooth_profile_left_y, arr_reverse(tooth_profile_right_y))

tooth_profile_p = { tooth_profile_x_p, tooth_profile_y_p }


-- Rotate the tooth profile as often as z_p -1 to create the gear profile
rot_angle = 2 * math.pi / z_p

x_pinion = {}
y_pinion = {}
for i=0, z_p - 1 do

	temp_wheel = rot_table_mat(-rot_angle * i, tooth_profile_p)
	       
	x_pinion = merge_table(x_pinion, temp_wheel[1])
	y_pinion = merge_table(y_pinion, temp_wheel[2])
end

points_v = make_vectors(x_pinion, y_pinion)

------------------------------------------------
-- DESIGN OF SHAFT --
------------------------------------------------

x_shaft = calc_circle_pt(r_s, 100)["X"]
y_shaft = calc_circle_pt(r_s, 100)["Y"]

shaft = make_vectors(x_shaft, y_shaft)


------------------------------------------------
-- PRINT FINAL GEAR--
------------------------------------------------


dir = v(0,0,height)

FinalShape = { linear_extrude(dir, points_v), linear_extrude(dir, shaft) }
diff = difference(FinalShape)


dist= r_w+r_p+offset
emit(translate(0,dist,0) * rotate(0, 0, -counter * increment) * diff)

end