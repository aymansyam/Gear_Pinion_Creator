require "functions_array_manipulation"
require "functions_array_mathematic"
require "functions_gear3"
-- User Inputs:


function create_gear(counter, increment, z_w_in)

pi = 3.14159265
input = {}

input["m"] = 3

input["z_w"] = z_w_in
input["z_p"] = 12
input["r_s"] = 20
input["error_limit"] = 0.000001
input["pitch"] = input["m"] * pi
input["u"] = input["z_w"] / input["z_p"]
input["d_w"] = input["m"] * input["z_w"]
input["r_w"] = input["d_w"] / 2
input["d_p"] = input["m"] * input["z_p"]
input["r_p"] = input["d_p"] / 2
input["hf_w"] = input["m"] * pi / 2
input["hf_w_r"] = input["r_w"] - input["hf_w"]
input["f_a"] = calc_addendum_factor(input["error_limit"], input["u"], input["z_p"])
input["h_a"] = 0.95 * input["f_a"] * input["m"]
input["ha_w_r"] = input["r_w"] + input["h_a"]
input["f_r"] = 1.4 * input["f_a"]
input["a_r"] = input["f_r"] * input["m"]
input["x_pitch_w"] = calc_circle_pt(input["r_w"], 200)["X"]
input["y_pitch_w"] = calc_circle_pt(input["r_w"], 200)["Y"]
input["x_ded_w"] = calc_circle_pt(input["hf_w_r"], 200)["X"]
input["y_ded_w"] = calc_circle_pt(input["hf_w_r"], 200)["Y"]
input["x_add_w"] = calc_circle_pt(input["ha_w_r"], 200)["X"]
input["y_add_w"] = calc_circle_pt(input["ha_w_r"], 200)["Y"]
input["l_x"] = {0, 0}
input["l_y"] = {0, input["ha_w_r"]}
input["dedendum_pt_st"] = {}
input["dedendum_pt_st"][1] = {0, 0}
input["dedendum_pt_st"][2] = { input["hf_w_r"], input["r_w"] }
input["rot_ded_deg"] = 360 / (4 * input["z_w"])
input["rot_ded"] = input["rot_ded_deg"] * pi/180;
input["dedendum_pt"] = rot_table(input["dedendum_pt_st"], input["rot_ded"])     
input["start_arc"] = { input["dedendum_pt"][1][2], input["dedendum_pt"][2][2] }
input["end_arc"] = { 0, input["ha_w_r"] }
input["dist_arc"] = distance(input["end_arc"][1], input["end_arc"][2], input["dedendum_pt"][1][2], input["dedendum_pt"][2][2])
input["vec_rhombus"] = {}
input["vec_rhombus"][1] = (input["dedendum_pt"][1][2]-input["end_arc"][1])
input["vec_rhombus"][2] = (input["dedendum_pt"][2][2]-input["end_arc"][2])
input["vec_rhombus"] = arr_div1(input["vec_rhombus"], magnitude(input["vec_rhombus"])) 
input["rhombus_cent"] = arr_subt2(input["start_arc"], arr_mult1(input["vec_rhombus"], input["dist_arc"] / 2))
input["b"] = math.sqrt((input["a_r"]^2) - (input["dist_arc"] / 2)^2)
input["vec_arc_center"] = { -input["vec_rhombus"][2], input["vec_rhombus"][1] }
input["arc_center"] = { arr_add2(input["rhombus_cent"], arr_mult1(input["vec_arc_center"], input["b"])) } 
input["angle_start"] = math.atan2(input["dedendum_pt"][2][2] - input["arc_center"][1][2], input["dedendum_pt"][1][2] - input["arc_center"][1][1])
input["angle_end"] = math.atan2(input["end_arc"][2] - input["arc_center"][1][2], input["end_arc"][1] - input["arc_center"][1][1])
-- 80??    
temp_arc = arc_circle(input["angle_start"], input["angle_end"], 80, input["arc_center"][1][1], input["arc_center"][1][2], input["a_r"])
input["x_arc"] = temp_arc["X"] 
input["y_arc"] = temp_arc["Y"]
input["pt_de_w"] = { 0, input["hf_w_r"] }
test = { { input["pt_de_w"][1] }, { input["pt_de_w"][2] } }
input["pt_de_w"] = rot_table_mat(2 * pi / (2 * input["z_w"]), test)
input["angle_start_dd"] = math.atan2(input["dedendum_pt"][2][1] - 0, input["dedendum_pt"][1][1] - 0)
input["angle_end_dd"] = math.atan2(input["pt_de_w"][2][1] - 0, input["pt_de_w"][1][1] - 0)
temp_c = arc_circle(input["angle_start_dd"], input["angle_end_dd"], 70, 0, 0, input["hf_w_r"])
input["x_ded"] = temp_c.X
input["y_ded"] = temp_c.Y
temptemp = arr_merge(arr_reverse(input["x_ded"]), arr_reverse(input["dedendum_pt"][1]))
input["tooth_profile_left_x"] = arr_merge(temptemp, input["x_arc"])

temptemp = arr_merge(arr_reverse(input["y_ded"]), arr_reverse(input["dedendum_pt"][2]))
input["tooth_profile_left_y"] = arr_merge(temptemp, input["y_arc"])
  
input["tooth_profile_right_x"] = arr_mult1(input["tooth_profile_left_x"], -1)
input["tooth_profile_right_y"] = input["tooth_profile_left_y"]
input["tooth_profile_x"] = arr_merge(input["tooth_profile_left_x"], arr_reverse(input["tooth_profile_right_x"]))
input["tooth_profile_y"] = arr_merge(input["tooth_profile_left_y"], arr_reverse(input["tooth_profile_right_y"]))
input["tooth_profile"] = { input["tooth_profile_x"], input["tooth_profile_y"] }

points_v = make_vectors(input["tooth_profile_x"], input["tooth_profile_y"])

dir = v(0,0,10)

input["rot_angle"] = 2 * pi / input["z_w"]

x_wheel = {}
y_wheel = {}
for i=0, input["z_w"] - 1 do

	temp_wheel = rot_table_mat(-input["rot_angle"]*i, input["tooth_profile"])
	       
	x_wheel = merge_table(x_wheel, temp_wheel[1])
	y_wheel = merge_table(y_wheel, temp_wheel[2])
end
  
points_v = make_vectors(x_wheel, y_wheel)



input["x_shaft"] = calc_circle_pt(input["r_s"], 100)["X"]
input["y_shaft"] = calc_circle_pt(input["r_s"], 100)["Y"]

shaft = make_vectors(input["x_shaft"], input["y_shaft"])



-- CUTOUTS

input["x_inner_circle"] = calc_circle_pt(input["r_s"] + input["r_s"]*0.45, 100)["X"]
input["y_inner_circle"] = calc_circle_pt(input["r_s"] + input["r_s"]*0.45, 100)["Y"]

input["x_outer_circle"] = calc_circle_pt(input["hf_w_r"] - input["hf_w_r"]*0.1, 100)["X"]
input["y_outer_circle"] = calc_circle_pt(input["hf_w_r"] - input["hf_w_r"]*0.1, 100)["Y"]


input["inner_arc_x"] = arc_circle(pi/3, 2*pi/3, 100, 0, 0, input["r_s"] + input["r_s"]*0.45)["X"]
input["inner_arc_y"] = arc_circle(pi/3, 2*pi/3, 100, 0, 0, input["r_s"] + input["r_s"]*0.45)["Y"]

input["outer_arc_x"] = arc_circle(pi/3, 2*pi/3, 100, 0, 0, input["hf_w_r"] - input["hf_w_r"]*0.1)["X"]
input["outer_arc_y"] = arc_circle(pi/3, 2*pi/3, 100, 0, 0, input["hf_w_r"] - input["hf_w_r"]*0.1)["Y"]
temp1 = merge_table(input["inner_arc_x"], arr_reverse(input["outer_arc_x"]))
temp2 = merge_table(input["inner_arc_y"], arr_reverse(input["outer_arc_y"]))

table.insert(temp1, input["inner_arc_x"][1])
table.insert(temp2, input["inner_arc_y"][1])
circular_segment = { temp1, temp2 }


input["rot_angle"] = 2 * pi / 4
FinalShape = { linear_extrude(dir, points_v), linear_extrude(dir, shaft) }
x_cutout = {}
y_cutout = {}
for i=0, 4 do

	temp_wheel = rot_table_mat(-input["rot_angle"]*i, circular_segment)
	       
	x_cutout = merge_table(x_cutout, temp_wheel[1])
	y_cutout = merge_table(y_cutout, temp_wheel[2])
	table.insert(x_cutout, x_cutout[1])
	table.insert(y_cutout, y_cutout[1])
	print(tprint({ x_cutout, y_cutout }))
	table.insert(FinalShape, linear_extrude(dir, make_vectors(x_cutout, y_cutout)))
end

cutouts = make_vectors(x_cutout, y_cutout)
diff = difference(FinalShape)

emit(rotate(0, 0, counter * increment) * diff)

end
-- print(FinalShape) 
