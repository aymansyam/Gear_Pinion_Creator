-- functions_gear:
require "functions_array_mathematic"
--require "main"


function involute(orientation,input)
-- calculate X & Y vertices of involute curve 
-- orientation: -1: left involute, +1:right involute
-- rb: radius of base circule
  local inv = {}
  local inv_x = {}
  local inv_y = {}
  local t = {}
  local theta = {}
  local rb = input["rb"]
  t = arr_mult1(linspaces(0,85,input["Res"]),Pi/180)
  -- Make the invoulte curve (@ X, Y coordinates)
  -- formulas:
  -- theta = t-inv_alpha
  -- inv_X = rb*(sin(theta)-t.*cos(theta))
  -- inv_Y = rb*(cos(theta)+t.*sin(theta))

  theta = arr_subt1(t,input["inv_alpha"])
  inv_x = arr_mult2(t,arr_cos(theta))
  inv_x = arr_subt2(arr_sin(theta),inv_x)
  inv_x = arr_mult1(inv_x,rb)

  inv_y = arr_mult2(t,arr_sin(theta))
  inv_y = arr_add2(inv_y,arr_cos(theta))
  inv_y = arr_mult1(inv_y,rb)
  inv_y = arr_mult1(inv_y,orientation)
  --print("\narr = "..inv_y[3])
  inv.x = inv_x
  inv.y = inv_y
  return inv
end


function trochoid(input)
-- Generate trochoid curve as X and Y table.
  local rp = input["rp"]
  local module = input["m"]
  local alpha = input["alpha"]
  local T = {} --final value to be returned
  local T_x = {}
  local T_y = {}
  local u = {}

  local T1 = {}  --  rp*(u+2*C*tan(alpha)/z)
  local T2       -- x*m*tan(alpha)
  -- formulas for trochoid curves:
  --T_x = -(rd*sin(u)-T1.*cos(u)+T2*cos(u));

  --T_y = rd*cos(u)+T1.*sin(u)-T2*sin(u);

  u = linspaces(-0.1546,0.7923*1.1,input["Res"])
  T1 = arr_add1(u,2*input["h_f_coef"]*math.tan(input["alpha"])/input["z"])
  T1 = arr_mult1(T1,input["rp"])
  T2 = input["x"]*input["m"]*math.tan(input["alpha"])
  
  -- X vertices of trochoid:
  T_x = arr_mult1(arr_sin(u),input["rd"])
  T_x = arr_subt2(T_x,arr_mult2(T1,arr_cos(u)))
  T_x = arr_add2(T_x,arr_mult1(arr_cos(u),T2))
  T_x = arr_mult1(T_x,-1)

  -- Y vertices of trochoid:
  T_y = arr_mult1(arr_cos(u),input["rd"])
  T_y = arr_add2(T_y,arr_mult2(T1,arr_sin(u)))
  T_y = arr_subt2(T_y,arr_mult1(arr_sin(u),T2))
  
  -- Return vertices:
  T.x = T_x
  T.y = T_y
  -- finding the first intersection with root circle:
  T = troch_rem_min(T)
  return T
end


function troch_rem_min(Troch)
-- This function finds the point where trochoid intersect with root circle and remove all points below that point.
  local T = {}
  local min_val
  local idx
  min_val, idx = arr_min(Troch.y)
  T = arr_resize(Troch,idx,-1)
  return T
end


function make_gap(input,angle)
-- make the gap between two teeth
  local inv = {}
  local inv2 = {}
  local T = {}
  local T2 = {}
  local s1 = {}
  local dir = v(0,0,input["h"])
  local T1_shape

  -- get the right involute:
  inv = involute(1,input)
  
  -- rotate the involute by inv_alpha + s_alpha:
  inv = rot_table(inv,(input["Rt"]+input["s_alpha"]))
  
  -- make gap1 (left and right involutes):
  inv2 = table_reverse(inv)
  inv2 = table_mirror(inv2,-1,1)
  inv2 = rot_table(inv2,input["s_alpha"])
  gap1 = table_merge(inv,inv2)
  
  -- make the trochoid:
  T  = trochoid(input)
  --T1_shape = linear_extrude_arr(dir,T.x,T.y,angle)
  
  -- make gap2 (left and right trochoids):
  --T2 = table_reverse(T)
  T2 = table_mirror(T,-1,1)
  T2 = rot_table(T2,input["s_alpha"])
  --T2_shape = linear_extrude_arr(dir,T2.x,T2.y,angle)
  
  -- Merge both trochoids:
  s1 = troch_gap(T,T2,input)
  s1_shape = linear_extrude_arr(dir,s1.x,s1.y,angle)
  
  -- make the polygon shape of inv:
  inv_shape = linear_extrude_arr(dir,gap1.x,gap1.y,angle)
  --inv_shape = union(inv_shape,s1_shape)
  --emit(inv_shape)
  return inv_shape, s1_shape
end


function troch_gap(Troch1,Troch2,input)
-- merge both trochoids after removing the intersection:
	local T1 = {}
	T1.x = {}
    T1.y = {}
	local T2 = {}
	T2.x = {}
    T2.y = {}
	local ans = {}
	local idx
	
	T1.x = Troch1.x
	T1.y = Troch1.y
	
	T2.x = Troch2.x
	T2.y = Troch2.y
	
	idx = arr_intersection(T1,T2)
	T1 = arr_resize(T1,1,idx[1])
	T2 = arr_resize(T2,1,idx[2])
	
	ans.x = T1.x
    ans.y = T1.y
	
	T2 = table_reverse(T2)
	for i=1, #Troch2.x do
		ans.x[#ans.x+1] = T2.x[i]
		ans.y[#ans.y+1] = T2.y[i]
	end
	Troch_shape = linear_extrude_arr(v(0,0,input["h"]),ans.x,ans.y,0)
	--emit(Troch_shape,1)
	return ans
end


function make_gear(input)
-- This function makes the actual gear shape by subtracting the gap shape from the addendum cylinder
  local gear = cylinder(input["ra2"], input["h"])

  for i=0, input["z"]-1 do
    gap1, T = make_gap(input,2*Pi/input["z"]*i)
    gear = difference(gear,gap1)
	gear = difference(gear,T)
  end
  -- Add root circle and remove the hole:
  gear = union(gear,cylinder(input["rd"],input["h"]))
  gear = difference(gear,input["hole"])
  return gear
end


function get_params(input)
-- Calculate and return all necessary parameters:
  local params = input

  -- alpha deg to rad:
  params["alpha"] = input["alpha"]*Pi/180

  -- Radius of pitch circle (rp)
  params["rp"] = input["m"]*input["z"]/2

  -- Radius of base circle (rb)
  params["rb"] = input["rp"]*math.cos(input["alpha"])

  -- Radius of profile-shifted pitch circle (rX)
  params["rX"] = params["rp"]+input["x"]*input["m"]

  -- Radius of addendum circle (ra)
  params["ra"] = params["rX"]+input["m"]
  params["ra2"] = params["rp"]+input["m"]*(input["x"]+input["h_a_coef"])
	
  --% Radius of dedendum circle (rd)
  params["rd"] = params["rX"]-input["h_f_coef"]*input["m"]

  --Angle between the start of the inv (on the base circle) and its intersection with the pitch circle (inv_alpha)
  params["inv_alpha"] = math.tan(params["alpha"])-params["alpha"]

  -- % p0: Circular pitch 
  params["p0"] = Pi*input["m"]

  -- Tooth thickness on pitch circle after profile shifting (s0)
  params["s0"] = params["p0"]/2+2*input["m"]*input["x"]*math.tan(params["alpha"])

  -- Tooth thickness difference after profile shift (delta_s)
  params["delta_s"] = params["s0"] - params["p0"]/2
  -- Angle of delta_s measured from pitch circle (s_alpha)
  params["s_alpha"] = params["delta_s"]/params["rp"]

  -- Angle of involute from pitch point to middle of the tooth (Rt)
  params["Rt"] = -2*Pi/(4*input["z"])
  
  -- Make hole and key:
  key = translate((input["hole_r"]+input["key_l"])/2,0,0)*cube(input["hole_r"]+input["key_l"],input["key_w"],input["h"])
  params["hole"] = union(cylinder(input["hole_r"], input["h"]),key)
	
  params["beta"] = 0  --input["beta"]*Pi/180
  params["s_pr"] = 0
  params["k"] = 0

  --Res must be >= 10
  if input["Res"] < 10 then
	params["Res"] = 10
  end 
  
  return params
end