 -- Welcome to IceSL!
require "lib/functions_array"
require "lib/functions_gear"


function create_pinion(counter, increment, z_p_in, m_in, resolution, height, z_w_in, r_s_p_in, input_fr_p_UI, offset)


m = m_in
z_w = z_w_in
z_p = z_p_in
r_s = r_s_p_in
input_fr_p = input_fr_p_UI

error_limit = 0.000001

pitch = m * math.pi
u = z_w/z_p
d_w = m * z_w
r_w = d_w/2
d_p = m * z_p
r_p = d_p/2

hf_w = m * math.pi/2
hf_w_r = r_w - hf_w

f_a = calc_addendum_factor(error_limit, u, z_w)
h_a = 0.95 * f_a * m
ha_w_r = r_w + h_a
f_r = 1.4 * f_a
a_r = f_r * m
hf_p = (f_a * 0.95 + 0.4) * m
hf_p_r = r_p - hf_p
temp = calc_circle_pt(r_p, 200)
x_pitch_w = temp["X"]
y_pitch_w = temp["Y"]
temp = calc_circle_pt(hf_p_r, 200)
x_ded_w = temp["X"]
y_ded_w = temp["Y"]

if z_p <= 10 then 
	t_w = 1.05
else
	t_w = 1.25
end

if z_p <= 7 then
	f_a_p = 0.855
	f_r_p = 1.050
	round = 0
elseif z_p == 8 then 
	f_a_p = 0.670
	f_r_p = 0.700
	round = 0
elseif z_p == 9 then
	f_a_p = 0.670
    f_r_p = 0.700
    round = 0
elseif z_p == 10 then
    f_a_p = 0.525
    f_r_p = 0.525
    round = 1
elseif z_p >= 11 then
    f_a_p = 0.625
    f_r_p = 0.625
    round = 1
end

h_a_p = 0.95 * f_a_p * m
ha_p_r = r_p + h_a_p

a_r_p = f_r_p * m

theta = t_w/2 * m / r_p


dedendum_pt_st = { {0,0} , { hf_p_r, r_p } }

rot_ded = theta

dedendum_pt_p = rot_table_mat(rot_ded, dedendum_pt_st)


if round == 0 then
	start_arc_p = { { dedendum_pt_p[1][2] } , { dedendum_pt_p[2][2] } }
	end_arc_p = { { 0 }, { ha_p_r } }
	dist_arc = distance(end_arc_p[1][1], end_arc_p[2][1], dedendum_pt_p[1][2], dedendum_pt_p[2][2])
	vec_rhombus = { { dedendum_pt_p[1][2] - end_arc_p[1][1] }, { dedendum_pt_p[2][2] - end_arc_p[2][1] } }
	
	vec_rhombus = arr_div1(arr_inv(vec_rhombus), math.sqrt(vec_rhombus[1][1]^2 + vec_rhombus[2][1]^2)) 
	rhombus_cent = arr_subt2(arr_inv(start_arc_p), arr_mult1(vec_rhombus, dist_arc/2))
	
	b = math.sqrt(a_r_p^2 - (dist_arc / 2)^2)
	
	vec_arc_center = { -vec_rhombus[2], vec_rhombus[1] }
	
	arc_center = arr_add2(rhombus_cent, arr_mult1(vec_arc_center, b))
	
	angle_start = math.atan2(dedendum_pt_p[2][2] - arc_center[2], dedendum_pt_p[1][2] - arc_center[1])
	angle_end = math.atan2(end_arc_p[2][1] - arc_center[2], end_arc_p[1][1] - arc_center[1])
	
	temp = arc_circle(angle_start, angle_end, resolution, arc_center[1], arc_center[2], a_r_p)
	x_arc_p = temp.X
	y_arc_p = temp.Y
	
elseif round == 1 then
	arc_center = { 0, r_p }
	end_arc_p = { 0, ha_p_r }
	
	angle_start = math.atan2(dedendum_pt_p[2][2] - arc_center[2], dedendum_pt_p[1][2] - arc_center[1])
	angle_end = math.atan2(end_arc_p[2] - arc_center[2], end_arc_p[1] - arc_center[1])
	temp = arc_circle(angle_start, angle_end - 2*math.pi, resolution, arc_center[1], arc_center[2], a_r_p)
	x_arc_p = temp.X
	y_arc_p = temp.Y
end


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
	-- POTENTIALLY PROBLEMATIC CODE: We are assuming pt_de_p has 2 elements in its array. If not, then we have to find a way to flatten the array. I don't have time to deal with it
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
	
	tooth_profile_left_x = arr_merge(temptemp, x_arc_p)
	
	temptemp = arr_merge(arr_reverse(fillet_y), arr_reverse(dedendum_pt_p[2]))
	tooth_profile_left_y = arr_merge(temptemp, y_arc_p)
  
	tooth_profile_right_x = arr_mult1(arr_merge(arr_reverse(dedendum_pt_p[1]), x_arc_p), -1)
	tooth_profile_right_y = arr_merge(arr_reverse(dedendum_pt_p[2]), y_arc_p)
	


end


if input_fr_p == false then

	pt_de_p = { 0, hf_p_r }
	test = { { pt_de_p[1] }, { pt_de_p[2] } }
	pt_de_p = rot_table_mat(2 * math.pi / (2 * z_p), test)

	angle_start_dd = math.atan2(dedendum_pt_p[2][1] - 0, dedendum_pt_p[1][1] - 0 )
	angle_end_dd = math.atan2(pt_de_p[2][1] - 0, pt_de_p[1][1] - 0)
	
	temp_c = arc_circle(angle_start_dd, angle_end_dd, resolution, 0, 0, hf_p_r)
	x_ded_p = temp_c.X
	y_ded_p = temp_c.Y
	
	temptemp = arr_merge(arr_reverse(x_ded_p), arr_reverse(dedendum_pt_p[1]))
	tooth_profile_left_x = arr_merge(temptemp, x_arc_p)

	temptemp = arr_merge(arr_reverse(y_ded_p), arr_reverse(dedendum_pt_p[2]))
	tooth_profile_left_y = arr_merge(temptemp, y_arc_p)
  
	tooth_profile_right_x = arr_mult1(tooth_profile_left_x, -1)
	tooth_profile_right_y = tooth_profile_left_y

end

tooth_profile_x_p = arr_merge(tooth_profile_left_x, arr_reverse(tooth_profile_right_x))
tooth_profile_y_p = arr_merge(tooth_profile_left_y, arr_reverse(tooth_profile_right_y))

tooth_profile_p = { tooth_profile_x_p, tooth_profile_y_p }

rot_angle = 2 * math.pi / z_p

x_pinion = {}
y_pinion = {}
for i=0, z_p - 1 do

	temp_wheel = rot_table_mat(-rot_angle * i, tooth_profile_p)
	       
	x_pinion = merge_table(x_pinion, temp_wheel[1])
	y_pinion = merge_table(y_pinion, temp_wheel[2])
end

points_v = make_vectors(x_pinion, y_pinion)

x_shaft = calc_circle_pt(r_s, 100)["X"]
y_shaft = calc_circle_pt(r_s, 100)["Y"]

shaft = make_vectors(x_shaft, y_shaft)

dir = v(0,0,height)

FinalShape = { linear_extrude(dir, points_v), linear_extrude(dir, shaft) }
diff = difference(FinalShape)
diff = rotate(0, 0, offset) * diff

dist= r_w+r_p
emit(translate(0,dist,0) * rotate(0, 0, -counter * increment) * diff)

end