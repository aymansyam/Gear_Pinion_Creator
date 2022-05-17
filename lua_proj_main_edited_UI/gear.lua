------------------------------------------------
-- CIRCULAR ARC GEARS - WHEEL
------------------------------------------------

-- This file calculates all the neccessary values and points 
-- for desingning the wheel for a circular arc gear pair 

-- Lunar 3D AG

------------------------------------------------
-- CALL REQUIERED FUNCTIONS & LIBARIES
------------------------------------------------

require "lib/functions_array"
require "lib/functions_gear"
require "lib/functions_vector"
-- User Inputs:


function create_gear(counter, increment, z_w_in, m_in, resolution, height, input_fr_w_UI, show_cutouts, z_p_in, r_s_in)

------------------------------------------------
-- USER INPUTS
------------------------------------------------

input = {}

m = m_in						-- Module

z_w = z_w_in					-- Number of teeth wheel
z_p = z_p_in					-- Number of teeth pinion
r_s = r_s_in					-- shaft radius wheel

input_fr_w = input_fr_w_UI		-- 0 = No fillet radius	1 = Fillet radius
cutout = show_cutouts			-- 0 = No cutouts in the wheel 1 = Cutouts in the wheel

error_limit = 0.000001			-- Error Limit for later used numerical search 

------------------------------------------------
-- BASIC CALCULATIONS
------------------------------------------------



pi = 3.14159265

pitch = m* pi		-- Reference pitch
u = z_w / z_p		-- Gear ratio
d_w = m * z_w		-- Pitch diameter wheel
r_w = d_w / 2		-- Pitch radius wheel
d_p = m * z_p		-- Pitch diameter pinion
r_p = d_p / 2		-- Pitch radius pinion

hf_w = m * pi / 2									-- Dedendum height wheel
hf_w_r = r_w - hf_w									-- Dedendum radius wheel

f_a = calc_addendum_factor(error_limit, u, z_p)		-- Addendum factor (via numerical search)
h_a = 0.95 * f_a * m								-- Addendum height
ha_w_r = r_w + h_a									-- Addendum radius wheel

f_r = 1.4 * f_a										-- Addendum radius factor
a_r = f_r * m										-- Addendum arc radius 


------------------------------------------------
-- DESIGN OF TEETH PROFILE --
------------------------------------------------


-- Pitch circle wheel
x_pitch_w = calc_circle_pt(r_w, 200)["X"]
y_pitch_w = calc_circle_pt(r_w, 200)["Y"]

-- Dedendum circle wheel
x_ded_w = calc_circle_pt(hf_w_r, 200)["X"]
y_ded_w = calc_circle_pt(hf_w_r, 200)["Y"]

-- Addendum circle wheel
x_add_w = calc_circle_pt(ha_w_r, 200)["X"]
y_add_w = calc_circle_pt(ha_w_r, 200)["Y"]

------------------------------------------------
-- DEDENDUM PROFILE

-- DELETE, NOT NEEDED
--l_x = {0, 0}
--l_y = {0, ha_w_r}

-- Create line from dedendum circle to pitch circle on y-axis
dedendum_pt_st = {}
dedendum_pt_st[1] = {0, 0}
dedendum_pt_st[2] = { hf_w_r, r_w }

-- Rotate the line to the left to get the left dedendum part of one tooth
rot_ded_deg = 360 / (4 * z_w)
rot_ded = rot_ded_deg * math.pi/180;
dedendum_pt = rot_table(dedendum_pt_st, rot_ded)  
------------------------------------------------
-- ADDENDUM PROFILE

-- Find the center point for the addendum radius by using a rhombus-approach, see:
-- https://math.stackexchange.com/questions/1781438/finding-the-center-of-a-circle-given-two-points-and-a-radius-algebraically)

-- Distance between the start of the arc on the pitch circle to the end of the arc on the addendum circle at x=0
   
start_arc = { dedendum_pt[1][2], dedendum_pt[2][2] }
end_arc = { 0, ha_w_r }
dist_arc = distance(end_arc[1], end_arc[2], dedendum_pt[1][2], dedendum_pt[2][2])

-- Finding the middlepoint if the rhombus


vec_rhombus = {}
vec_rhombus[1] = (dedendum_pt[1][2]-end_arc[1])
vec_rhombus[2] = (dedendum_pt[2][2]-end_arc[2])
vec_rhombus = arr_div1(vec_rhombus, magnitude(vec_rhombus)) 
rhombus_cent = arr_subt2(start_arc, arr_mult1(vec_rhombus, dist_arc / 2))


-- Calculate the distance from the rhombus center to the center on the arc

b = math.sqrt((a_r^2) - (dist_arc / 2)^2)

-- Draw a vector prependicular to the vec_rhombus with the length of b starting at the rhombus center to find the center of the addendum arc


vec_arc_center = { -vec_rhombus[2], vec_rhombus[1] }
arc_center = { arr_add2(rhombus_cent, arr_mult1(vec_arc_center, b)) } 

-- Calculate the points on the addendum arc

angle_start = math.atan2(dedendum_pt[2][2] - arc_center[1][2], dedendum_pt[1][2] - arc_center[1][1])
angle_end = math.atan2(end_arc[2] - arc_center[1][2], end_arc[1] - arc_center[1][1])

temp_arc = arc_circle(math.abs(angle_start), angle_end, resolution, arc_center[1][1], arc_center[1][2], a_r)
x_arc = temp_arc["X"]
y_arc = temp_arc["Y"]

------------------------------------------------
-- FILLET FPROFILE

-- input_fr_w (0 = No fillet curve	1 = Fillet curve)


if input_fr_w == true then

	-- Calculate the point on the dedendum circle which is exactly centered between two teeth

	pt_de_w = { 0, hf_w_r }
	test = { { pt_de_w[1] }, { pt_de_w[2] } }
	pt_de_w = rot_table_mat(2 * math.pi / (2 * z_w), test)
	
	-- Calculate the disance from (0,0) to pt_de_w


	dist_ded_middle = distance(pt_de_w[1][1], pt_de_w[2][1], 0, 0)
	
	-- Calculate the angle between line A (from (0,0) to pt_de_w) and line B (from (0,0) going trough the dedendum line)

	A = Point(pt_de_w[1][1], pt_de_w[2][1], 0)
	B = Point(dedendum_pt[1][1], dedendum_pt[2][1], 0)
	
	crossProduct = A ^ B
	dotProduct = A..B
	normalProduct = math.sqrt(crossProduct[1]^2 + crossProduct[2]^2 + crossProduct[3]^2)
	theta_ded = math.atan2(normalProduct, dotProduct)
	
	-- Calculate the radius of the maximum possible fillet circle

	fillet_radius = (dist_ded_middle * math.sin(theta_ded)) / (1 - math.sin(theta_ded))
	
	-- Calculate the fillet circle center

	unit_A = arr_div1(A, math.sqrt(A[1]^2 + A[2]^2 + A[3]^2))
	
	-- POTENTIALLY PROBLEMATIC CODE: We are assuming pt_de_w has 2 elements in its array. If not, then we have to find a way to flatten the array. I don't have time to deal with it
	
	fillet_circle_center = arr_add2({ pt_de_w[1][1], pt_de_w[2][1] }, arr_mult1({ unit_A[1], unit_A[2] }, fillet_radius))
	fillet_circle_center_x = fillet_circle_center[1]
	fillet_circle_center_y = fillet_circle_center[2]
	
	-- Calculate the starting point of the fillet circle on the dedendum profile
	
	-- Distance from (0,0) to the fillet start
	dist_ded_fillet_start = (dist_ded_middle + fillet_radius) * math.cos(theta_ded)
	unit_B = arr_div1(B, math.sqrt(B[1]^2 + B[2]^2 + B[3]^2))
	start_fillet_ded = arr_mult1(unit_B, dist_ded_fillet_start)
	dedendum_pt[1][1] = start_fillet_ded[1]
	dedendum_pt[2][1] = start_fillet_ded[2]
	
	-- For drawing the fillet circle we need to know where to end
	-- therefore the dedendum of one neighbouring left tooth is calculated to get the points and the angles
	
	temp_x = arr_mult1(dedendum_pt[1], -1)
	temp_y = dedendum_pt[2]
	temp = arr_merge({ temp_x }, { temp_y })
	
	-- Rotate the profile to the right

	rot_angle = -2 * math.pi / z_w
	temp_ded = rot_table_mat(-rot_angle, temp)
	
	-- Calculate the addendum arc

	angle_start_dd = math.atan2(dedendum_pt[2][1] - fillet_circle_center_y, dedendum_pt[1][1] - fillet_circle_center_x )
	angle_end_dd = math.atan2(temp_ded[2][1] - fillet_circle_center_y, temp_ded[1][1] - fillet_circle_center_x)
	
	temp_c = arc_circle(angle_start_dd, angle_end_dd, resolution, fillet_circle_center_x, fillet_circle_center_y, fillet_radius)
	fillet_x = temp_c.X
	fillet_y = temp_c.Y
	
	-- Combine all the points of the left tooth profile into one matrix
	
	temptemp = arr_merge(arr_reverse(fillet_x), arr_reverse(dedendum_pt[1]))
	tooth_profile_left_x = arr_merge(temptemp, x_arc)

	temptemp = arr_merge(arr_reverse(fillet_y), arr_reverse(dedendum_pt[2]))
	tooth_profile_left_y = arr_merge(temptemp, y_arc)
  
  	-- Mirror the left x-tooth profile and create the right tooth profile

	tooth_profile_right_x = arr_mult1(arr_merge(arr_reverse(dedendum_pt[1]), x_arc), -1)
	tooth_profile_right_y = arr_merge(arr_reverse(dedendum_pt[2]), y_arc)
		-- print(tprint(input["angle_end_dd"])) 


end

-- input_fr_w (0 = No fillet curve	1 = Fillet curve)
if input_fr_w == false then

	-- Calculate the dedendum arc in the pitch range of one tooth

	pt_de_w = { 0, hf_w_r }
	test = { { pt_de_w[1] }, { pt_de_w[2] } }
	pt_de_w = rot_table_mat(2 * math.pi / (2 * z_w), test)
	
	angle_start_dd = math.atan2(dedendum_pt[2][1] - 0, dedendum_pt[1][1] - 0)
	angle_end_dd = math.atan2(pt_de_w[2][1] - 0, pt_de_w[1][1] - 0)
	
	temp_c = arc_circle(angle_start_dd, angle_end_dd, resolution, 0, 0, hf_w_r)
	
	x_ded = temp_c.X
	y_ded = temp_c.Y
	
	-- Combine all the points of the left tooth profile into one matrix

	temptemp = arr_merge(arr_reverse(x_ded), arr_reverse(dedendum_pt[1]))
	tooth_profile_left_x = arr_merge(temptemp, x_arc)

	temptemp = arr_merge(arr_reverse(y_ded), arr_reverse(dedendum_pt[2]))
	tooth_profile_left_y = arr_merge(temptemp, y_arc)
  
  	-- Mirror the left x-tooth profile and create the right tooth profile

	tooth_profile_right_x = arr_mult1(tooth_profile_left_x, -1)
	tooth_profile_right_y = tooth_profile_left_y

end


------------------------------------------------
-- DESIGN OF GEAR PROFILE --
------------------------------------------------

-- Combine left and right side of the teeth into one profile

tooth_profile_x = arr_merge(tooth_profile_left_x, arr_reverse(tooth_profile_right_x))
tooth_profile_y = arr_merge(tooth_profile_left_y, arr_reverse(tooth_profile_right_y))
tooth_profile = { tooth_profile_x, tooth_profile_y }

points_v = make_vectors(tooth_profile_x, tooth_profile_y)

dir = v(0,0,height)

rot_angle = 2 * math.pi / z_w

x_wheel = {}
y_wheel = {}

-- Rotate the tooth profile as often as z_w -1 to create the gear profile

for i=0, z_w - 1 do

	temp_wheel = rot_table_mat(-rot_angle*i, tooth_profile)
	       
	x_wheel = merge_table(x_wheel, temp_wheel[1])
	y_wheel = merge_table(y_wheel, temp_wheel[2])
end
  
points_v = make_vectors(x_wheel, y_wheel)


------------------------------------------------
-- DESIGN OF SHAFT --
------------------------------------------------


x_shaft = calc_circle_pt(r_s, 100)["X"]
y_shaft = calc_circle_pt(r_s, 100)["Y"]

shaft = make_vectors(x_shaft, y_shaft)


------------------------------------------------
-- DESIGN OF CUTOUTS --
------------------------------------------------

-- Define the start of the coutouts on the inner side
--x_inner_circle = calc_circle_pt(r_s + r_s*0.45, 100)["X"]
--y_inner_circle = calc_circle_pt(r_s + r_s*0.45, 100)["Y"]

-- Define the end of the coutouts on the outer side
--x_outer_circle = calc_circle_pt(hf_w_r - hf_w_r*0.1, 100)["X"]
--y_outer_circle = calc_circle_pt(hf_w_r - hf_w_r*0.1, 100)["Y"]

-- Calculate the cutout arc on the inner side

x_inner_circle = calc_circle_pt(r_s + r_s*0.45, 100)["X"]
y_inner_circle = calc_circle_pt(r_s + r_s*0.45, 100)["Y"]

-- Calculate the cutout arc on the outer side

x_outer_circle = calc_circle_pt(hf_w_r - hf_w_r*0.1, 100)["X"]
y_outer_circle = calc_circle_pt(hf_w_r - hf_w_r*0.1, 100)["Y"]


inner_arc_x = arc_circle(math.pi/3, 2*math.pi/3, 100, 0, 0, r_s + r_s*0.45)["X"]
inner_arc_y = arc_circle(math.pi/3, 2*math.pi/3, 100, 0, 0, r_s + r_s*0.45)["Y"]

outer_arc_x = arc_circle(math.pi/3, 2*math.pi/3, 100, 0, 0, hf_w_r - hf_w_r*0.1)["X"]
outer_arc_y = arc_circle(math.pi/3, 2*math.pi/3, 100, 0, 0, hf_w_r - hf_w_r*0.1)["Y"]

-- Connect the inner and outer arc

temp1 = merge_table(inner_arc_x, arr_reverse(outer_arc_x))
temp2 = merge_table(inner_arc_y, arr_reverse(outer_arc_y))

-- Creat the first cutout segment

table.insert(temp1, inner_arc_x[1])
table.insert(temp2, inner_arc_y[1])
circular_segment = { temp1, temp2 }


-- Create more circular arc segments by rotating

rot_angle = 2 * math.pi / 4
FinalShape = { linear_extrude(dir, points_v), linear_extrude(dir, shaft) }
x_cutout = {}
y_cutout = {}
for i=0, 4 do

	temp_wheel = rot_table_mat(-rot_angle*i, circular_segment)
	       
	x_cutout = merge_table(x_cutout, temp_wheel[1])
	y_cutout = merge_table(y_cutout, temp_wheel[2])
	table.insert(x_cutout, x_cutout[1])
	table.insert(y_cutout, y_cutout[1])
		-- print(tprint({ x_cutout, y_cutout }))

	if cutout == true then
	table.insert(FinalShape, linear_extrude(dir, make_vectors(x_cutout, y_cutout)))
	end
end

------------------------------------------------
-- PRINT FINAL GEAR--
------------------------------------------------

cutouts = make_vectors(x_cutout, y_cutout)
diff = difference(FinalShape)


emit(rotate(0, 0, counter * increment) * diff)
-- print(FinalShape) 

end 

