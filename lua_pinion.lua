 -- Welcome to IceSL!
require "functions_array_manipulation"
require "functions_array_mathematic"
require "functions_gear3"


function create_pinion(counter, increment, z_p_in)

pi = 3.14159265

m = 3
z_w = 35
z_p = z_p_in
r_s = 3
input_fr_p = 0

error_limit = 0.000001

pitch = m * pi
u = z_w/z_p
d_w = m * z_w
r_w = d_w/2
d_p = m * z_p
r_p = d_p/2

hf_w = m * pi/2
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
	
	temp = arc_circle(angle_start, angle_end, 80, arc_center[1], arc_center[2], a_r_p)
	x_arc_p = temp.X
	y_arc_p = temp.Y
	
elseif round == 1 then
	arc_center = { 0, r_p }
	end_arc_p = { 0, ha_p_r }
	
	angle_start = math.atan2(dedendum_pt_p[2][2] - arc_center[2], dedendum_pt_p[1][2] - arc_center[1])
	angle_end = math.atan2(end_arc_p[2] - arc_center[2], end_arc_p[1] - arc_center[1])
	temp = arc_circle(angle_start, angle_end - 2*pi, 80, arc_center[1], arc_center[2], a_r_p)
	x_arc_p = temp.X
	y_arc_p = temp.Y
end


if input_fr_p == 1 then
	
	temp_x = arr_mult1(dedendum_pt_p[1], -1)
	temp_y = dedendum_pt_p[2]
	
	temp = { temp_x, temp_y}
	rot_angle = -2 * pi / z_p
	temp_ded = rot_table_mat(-rot_angle, temp)
	
	x0 = 0
	y0 = 0
	a_A = getSlope(x0, y0, dedendum_pt_p[1][1], dedendum_pt_p[2][1])
	b_A = y0 -- PROBLEMATIC CODE: this is assuming that x0 and y0 are == 0
	
	x1 = 0
	y1 = 0
	a_B = getSlope(x1, y1, temp_ded[1][1], temp_ded[2][1])
	b_B = y1 -- PROBLEMATIC CODE: this is assuming that x0 and y0 are == 0
	
	a_A_o = -1 / a_A
	b_A_o = dedendum_pt_p[2][1] - a_A_o * dedendum_pt_p[1][1]
	
	a_B_o = -1 / a_B
	b_B_o = temp_ded[2][1] - a_B_o * temp_ded[1][1]
	
	-- SOLVE FOR WHEN Y = 0
	fillet_circle_center_x = -(b_A_o - b_B_o) / (a_A_o - a_B_o) -- PROBLEMATIC CODE: this is assuming that we are representing a line function
	fillet_circle_center_y = a_A_o * fillet_circle_center_x + b_A_o
	
	fillet_radius = distance(dedendum_pt_p[1][1], dedendum_pt_p[2][1], fillet_circle_center_x, fillet_circle_center_y)
	
	angle_start = math.atan2(dedendum_pt_p[2][1] - fillet_circle_center_y, dedendum_pt_p[1][1] - fillet_circle_center_x)
	angle_end = math.atan2(temp_ded[2][1] - fillet_circle_center_y, temp_ded[1][1] - fillet_circle_center_x)
	
	
	
	temp = arc_circle(angle_start,  angle_end, 80, fillet_circle_center_x, fillet_circle_center_y, fillet_radius)
	fillet_x = temp.X
	fillet_y = temp.Y
	
	tooth_profile_left_x_p = arr_merge(arr_merge(arr_reverse(fillet_x), arr_reverse(dedendum_pt_p[1])), x_arc_p)
	tooth_profile_left_y_p = arr_merge(arr_merge(arr_reverse(fillet_y), arr_reverse(dedendum_pt_p[2])), y_arc_p)
	
	tooth_profile_right_x_p = arr_mult1(arr_merge(arr_reverse(dedendum_pt_p[1]), x_arc_p), -1)
	tooth_profile_right_y_p = arr_merge(arr_reverse(dedendum_pt_p[2]), y_arc_p)
end


if input_fr_p == 0 then

	pt_de_p = { { 0 }, { hf_p_r } }
	pt_de_p = rot_table_mat(2 * pi / ( 2 * z_p ), pt_de_p)
	
	angle_start_dd = math.atan2(dedendum_pt_p[2][1] - 0, dedendum_pt_p[1][1] - 0)
	angle_end_dd = math.atan2(pt_de_p[2][1] - 0, pt_de_p[1][1] - 0)
	temp = arc_circle(angle_start_dd, angle_end_dd, 70, 0, 0, hf_p_r)
	x_ded_p = temp.X
	y_ded_p = temp.Y
	
	tooth_profile_left_x_p = arr_merge(arr_merge(arr_reverse(x_ded_p), arr_reverse(dedendum_pt_p[1])), x_arc_p)
	tooth_profile_left_y_p = arr_merge(arr_merge(arr_reverse(y_ded_p), arr_reverse(dedendum_pt_p[2])), y_arc_p)
	
	tooth_profile_right_x_p = arr_mult1(tooth_profile_left_x_p, -1)
	tooth_profile_right_y_p = tooth_profile_left_y_p

end

tooth_profile_x_p = arr_merge(tooth_profile_left_x_p, arr_reverse(tooth_profile_right_x_p))
tooth_profile_y_p = arr_merge(tooth_profile_left_y_p, arr_reverse(tooth_profile_right_y_p))

tooth_profile_p = { tooth_profile_x_p, tooth_profile_y_p }

rot_angle = 2 * pi / z_p

x_pinion = {}
y_pinion = {}
for i=0, z_p - 1 do

	temp_wheel = rot_table_mat(-rot_angle * i, tooth_profile_p)
	       
	x_pinion = merge_table(x_pinion, temp_wheel[1])
	y_pinion = merge_table(y_pinion, temp_wheel[2])
end

points_v = make_vectors(x_pinion, y_pinion)
dir = v(0,0,10)

dist= r_w+r_p

emit(translate(0,dist+5,0) * rotate(0, 0, -counter * increment) *linear_extrude(dir, points_v))


print(tprint(tooth_profile_p))
end 


