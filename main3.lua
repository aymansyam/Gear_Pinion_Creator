require "functions_array_manipulation"
require "functions_array_mathematic"
require "functions_gear3"
require "point"
-- User Inputs:


function create_gear(counter, increment, z_w_in, m_in, height)

pi = 3.14159265
input = {}

m = m_in

cutout = 1
z_w = z_w_in
z_p = 12
r_s = 20
input_fr_w = 1
error_limit = 0.000001
pitch = m * pi
u = z_w / z_p
d_w = m * z_w
r_w = d_w / 2
d_p = m * z_p
r_p = d_p / 2
hf_w = m * pi / 2
hf_w_r = r_w - hf_w
f_a = calc_addendum_factor(error_limit, u, z_p)
h_a = 0.95 * f_a * m
ha_w_r = r_w + h_a
f_r = 1.4 * f_a
a_r = f_r * m
x_pitch_w = calc_circle_pt(r_w, 200)["X"]
y_pitch_w = calc_circle_pt(r_w, 200)["Y"]
x_ded_w = calc_circle_pt(hf_w_r, 200)["X"]
y_ded_w = calc_circle_pt(hf_w_r, 200)["Y"]
x_add_w = calc_circle_pt(ha_w_r, 200)["X"]
y_add_w = calc_circle_pt(ha_w_r, 200)["Y"]
l_x = {0, 0}
l_y = {0, ha_w_r}
dedendum_pt_st = {}
dedendum_pt_st[1] = {0, 0}
dedendum_pt_st[2] = { hf_w_r, r_w }
rot_ded_deg = 360 / (4 * z_w)
rot_ded = rot_ded_deg * pi/180;
dedendum_pt = rot_table(dedendum_pt_st, rot_ded)     
start_arc = { dedendum_pt[1][2], dedendum_pt[2][2] }
end_arc = { 0, ha_w_r }
dist_arc = distance(end_arc[1], end_arc[2], dedendum_pt[1][2], dedendum_pt[2][2])
vec_rhombus = {}
vec_rhombus[1] = (dedendum_pt[1][2]-end_arc[1])
vec_rhombus[2] = (dedendum_pt[2][2]-end_arc[2])
vec_rhombus = arr_div1(vec_rhombus, magnitude(vec_rhombus)) 
rhombus_cent = arr_subt2(start_arc, arr_mult1(vec_rhombus, dist_arc / 2))
b = math.sqrt((a_r^2) - (dist_arc / 2)^2)
vec_arc_center = { -vec_rhombus[2], vec_rhombus[1] }
arc_center = { arr_add2(rhombus_cent, arr_mult1(vec_arc_center, b)) } 
angle_start = math.atan2(dedendum_pt[2][2] - arc_center[1][2], dedendum_pt[1][2] - arc_center[1][1])
angle_end = math.atan2(end_arc[2] - arc_center[1][2], end_arc[1] - arc_center[1][1])
-- 80??    
temp_arc = arc_circle(angle_start, angle_end, 80, arc_center[1][1], arc_center[1][2], a_r)
x_arc = temp_arc["X"]
y_arc = temp_arc["Y"]


if input_fr_w == 1 then

	pt_de_w = { 0, hf_w_r }
	test = { { pt_de_w[1] }, { pt_de_w[2] } }
	pt_de_w = rot_table_mat(2 * pi / (2 * z_w), test)
	
	dist_ded_middle = distance(pt_de_w[1][1], pt_de_w[2][1], 0, 0)
	A = Point(pt_de_w[1][1], pt_de_w[2][1], 0)
	B = Point(dedendum_pt[1][1], dedendum_pt[2][1], 0)
	crossProduct = A ^ B
	dotProduct = A..B
	normalProduct = math.sqrt(crossProduct[1]^2 + crossProduct[2]^2 + crossProduct[3]^2)
	theta_ded = math.atan2(normalProduct, dotProduct)
	fillet_radius = (dist_ded_middle * math.sin(theta_ded)) / (1 - math.sin(theta_ded))
	unit_A = arr_div1(A, math.sqrt(A[1]^2 + A[2]^2 + A[3]^2))
	-- POTENTIALLY PROBLEMATIC CODE: We are assuming pt_de_w has 2 elements in its array. If not, then we have to find a way to flatten the array. I don't have time to deal with it
	fillet_circle_center = arr_add2({ pt_de_w[1][1], pt_de_w[2][1] }, arr_mult1({ unit_A[1], unit_A[2] }, fillet_radius))
	fillet_circle_center_x = fillet_circle_center[1]
	fillet_circle_center_y = fillet_circle_center[2]
	dist_ded_fillet_start = (dist_ded_middle + fillet_radius) * math.cos(theta_ded)
	unit_B = arr_div1(B, math.sqrt(B[1]^2 + B[2]^2 + B[3]^2))
	start_fillet_ded = arr_mult1(unit_B, dist_ded_fillet_start)
	dedendum_pt[1][1] = start_fillet_ded[1]
	dedendum_pt[2][1] = start_fillet_ded[2]
	temp_x = arr_mult1(dedendum_pt[1], -1)
	temp_y = dedendum_pt[2]
	temp = arr_merge({ temp_x }, { temp_y })
	rot_angle = -2 * pi / z_w
	temp_ded = rot_table_mat(-rot_angle, temp)
	
	angle_start_dd = math.atan2(dedendum_pt[2][1] - fillet_circle_center_y, dedendum_pt[1][1] - fillet_circle_center_x )
	angle_end_dd = math.atan2(temp_ded[2][1] - fillet_circle_center_y, temp_ded[1][1] - fillet_circle_center_x)
	
	temp_c = arc_circle(angle_start_dd, angle_end_dd, 80, fillet_circle_center_x, fillet_circle_center_y, fillet_radius)
	fillet_x = temp_c.X
	fillet_y = temp_c.Y
	
	temptemp = arr_merge(arr_reverse(fillet_x), arr_reverse(dedendum_pt[1]))
	tooth_profile_left_x = arr_merge(temptemp, x_arc)

	temptemp = arr_merge(arr_reverse(fillet_y), arr_reverse(dedendum_pt[2]))
	tooth_profile_left_y = arr_merge(temptemp, y_arc)
  
	tooth_profile_right_x = arr_mult1(arr_merge(arr_reverse(dedendum_pt[1]), x_arc), -1)
	tooth_profile_right_y = arr_merge(arr_reverse(dedendum_pt[2]), y_arc)
	
	-- print(tprint(angle_end_dd)) 

end

if input_fr_w == 0 then

	pt_de_w = { 0, hf_w_r }
	test = { { pt_de_w[1] }, { pt_de_w[2] } }
	pt_de_w = rot_table_mat(2 * pi / (2 * z_w), test)
	angle_start_dd = math.atan2(dedendum_pt[2][1] - 0, dedendum_pt[1][1] - 0)
	angle_end_dd = math.atan2(pt_de_w[2][1] - 0, pt_de_w[1][1] - 0)
	temp_c = arc_circle(angle_start_dd, angle_end_dd, 70, 0, 0, hf_w_r)
	x_ded = temp_c.X
	y_ded = temp_c.Y
	temptemp = arr_merge(arr_reverse(x_ded), arr_reverse(dedendum_pt[1]))
	tooth_profile_left_x = arr_merge(temptemp, x_arc)

	temptemp = arr_merge(arr_reverse(y_ded), arr_reverse(dedendum_pt[2]))
	tooth_profile_left_y = arr_merge(temptemp, y_arc)
  
	tooth_profile_right_x = arr_mult1(tooth_profile_left_x, -1)
	tooth_profile_right_y = tooth_profile_left_y

end

tooth_profile_x = arr_merge(tooth_profile_left_x, arr_reverse(tooth_profile_right_x))
tooth_profile_y = arr_merge(tooth_profile_left_y, arr_reverse(tooth_profile_right_y))
tooth_profile = { tooth_profile_x, tooth_profile_y }

points_v = make_vectors(tooth_profile_x, tooth_profile_y)

dir = v(0,0,10)

rot_angle = 2 * pi / z_w

x_wheel = {}
y_wheel = {}
for i=0, z_w - 1 do

	temp_wheel = rot_table_mat(-rot_angle*i, tooth_profile)
	       
	x_wheel = merge_table(x_wheel, temp_wheel[1])
	y_wheel = merge_table(y_wheel, temp_wheel[2])
end
  
points_v = make_vectors(x_wheel, y_wheel)



x_shaft = calc_circle_pt(r_s, 100)["X"]
y_shaft = calc_circle_pt(r_s, 100)["Y"]

shaft = make_vectors(x_shaft, y_shaft)



-- CUTOUTS
x_inner_circle = calc_circle_pt(r_s + r_s*0.45, 100)["X"]
y_inner_circle = calc_circle_pt(r_s + r_s*0.45, 100)["Y"]

x_outer_circle = calc_circle_pt(hf_w_r - hf_w_r*0.1, 100)["X"]
y_outer_circle = calc_circle_pt(hf_w_r - hf_w_r*0.1, 100)["Y"]


inner_arc_x = arc_circle(pi/3, 2*pi/3, 100, 0, 0, r_s + r_s*0.45)["X"]
inner_arc_y = arc_circle(pi/3, 2*pi/3, 100, 0, 0, r_s + r_s*0.45)["Y"]

outer_arc_x = arc_circle(pi/3, 2*pi/3, 100, 0, 0, hf_w_r - hf_w_r*0.1)["X"]
outer_arc_y = arc_circle(pi/3, 2*pi/3, 100, 0, 0, hf_w_r - hf_w_r*0.1)["Y"]
temp1 = merge_table(inner_arc_x, arr_reverse(outer_arc_x))
temp2 = merge_table(inner_arc_y, arr_reverse(outer_arc_y))

table.insert(temp1, inner_arc_x[1])
table.insert(temp2, inner_arc_y[1])
circular_segment = { temp1, temp2 }


rot_angle = 2 * pi / 4
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
	
	if cutout == 1 then
	table.insert(FinalShape, linear_extrude(dir, make_vectors(x_cutout, y_cutout)))
	end
end


cutouts = make_vectors(x_cutout, y_cutout)
diff = difference(FinalShape)

emit(rotate(0, 0, counter * increment) * diff)

end 
-- print(FinalShape) 

