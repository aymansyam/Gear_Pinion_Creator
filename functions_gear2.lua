-- functions_gear2: this file contains calculation for the gear using method 2
require "functions_array_mathematic"
require "functions_array_manipulation"

function make_gear2(input)
-- make a spur gear using method 2 (make the teeth profile)
	local r_p
	local r_f
	local gear
	local teeth = {}
	
	-- calculate root radius:
	r_p = input["z"]*input["m"]/(2*math.cos(input["beta"]))
	print("\nPitch Radius = \t"..r_p)
	r_f= r_p - input["m"]*(input["h_f_coef"] - input["x"])
	--print("r_p"..input["rb"])
	-- make the gear:
	gear = cylinder(r_f, input["h"])

	for i=0, input["z"]-1 do
		teeth[i+1] = make_teeth(input,2*Pi/input["z"]*i)
		gear = union(gear,teeth[i+1])
	end
	gear = difference(gear,input["hole"])
	rp_cir = cylinder(r_p,input["h"]/2)
	
	-----test pitch circle:
	--pitch_cir = cylinder(r_p, input["h"]/2)
	--emit(pitch_cir,1)
	----------------------
	return gear
end

function make_teeth(input,angle)
-- make one teeth profile (right & left profiles of teeth)
	local inv = {}
	local tro = {}
	local prof_R = {}
	local prof_L = {}
	local tooth_v = {}
	local tooth = {}
	local dir = v(0,0,input["h"])
	
	inv.x, inv.y, tro.x, tro.y = tooth_profile_inv(input)
	
	-- rearange involute and tables & create right profile:
	--tro = table_reverse(tro)			-- reverse trochoid curve
	prof_R = table_merge(tro,inv)		-- create right profile by merging inv & tro
	s_alpha = input["delta_s"]/input["r_p"]
	th = 2*Pi/(2*input["z"])
	prof_L = table_mirror(prof_R,-1,1)
	prof_L = table_reverse(prof_L)
	-- Rotate right profile with the correct angle (standard tooth thickness + profile shift angle)
	prof_R = rot_table(prof_R,-(th+s_alpha))
	
	--emit(linear_extrude_arr(dir,prof_R.x,prof_R.y,angle),1)
	--emit(linear_extrude_arr(dir,prof_L.x,prof_L.y,angle),3)
	--print_table(prof_L)
	
	-- make the tooth as a polygon shape:
	tooth_v = table_merge(prof_R,prof_L)
	tooth = linear_extrude_arr(dir,tooth_v.x,tooth_v.y,angle)
	return tooth
end

function tooth_profile_inv(input)
	local alpha_t= input["alpha"]/math.cos(input["beta"])
	local r_p= input["z"]*input["m"]/(2*math.cos(input["beta"]))
	input["r_p"] = r_p
	local r_b= r_p*math.cos(alpha_t)
	local r_a= r_p + input["m"]*(input["h_a_coef"] + input["x"] + input["k"])
	
	local B_SOI= B_func(input["alpha"],input)
	local phi_SOI = 0
	local xi_SOI = 0
	local xi_a = 0
	local r_SOI = 0
	
	--local dt = eta_delta(input["alpha"],input,r_p, r_b, alpha_t) 

	if ((r_p - B_SOI >= r_b*math.cos(alpha_t)) and (input["s_pr"]==0)) then 
		-- no undercut:
		-- trochoid fillet: phi for connecting point to involtue  
		phi_SOI= input["alpha"];
		
		-- involute: xi for start and end of involute 
        r_SOI= r_tro_func(input["alpha"],input,r_p)
		xi_SOI= math.sqrt(math.pow((r_SOI/r_b),2) - 1)
        xi_a=   math.sqrt(math.pow(( r_a /r_b),2) - 1)
		--print("\n xi_a = \t"..xi_a)
	else
		-- undercut  
		-- trochoid fillet: phi for connecting point to involtue
        --local phi_SOI = Secant_method(@(phi) (eta_delta(phi, m_n, r_p, r_b, alpha_n, alpha_t, beta, x_coef, h_a0_coef, rho_fP_coef, s_pr)),0.1,-0.01,0.0000001, 30);
        
		phi_SOI = Secant_method(eta_delta,input,r_p, r_b, alpha_t,0.1,-0.01,0.0000001, 30)
		--involute: xi for start and end of involute
		xi_a = math.sqrt(math.pow(( r_a /r_b),2) - 1)
		r_tro_SOI= r_tro_func(phi_SOI,input,r_p)
		xi_SOI = math.sqrt(math.max(0,(math.pow((r_tro_SOI/r_b),2)-1)))				-- sqrt(max(0,(r_tro_SOI/r_b)^2 - 1));

		--print("\n phi_SOI = \t"..phi_SOI)
	end
	
	local gamma = math.sqrt(math.pow((r_a/r_b),2)-1) - math.atan(math.sqrt(math.pow((r_a/r_b),2)-1)) + 0.25*Pi/input["z"]
	local phi = {}
	--phi = linspaces(0.24274524353055,Pi/2,input["Res"])
	phi = linspaces(Pi/2,phi_SOI,30)
	
	local tau_tro = {}
	tau_tro = eta_tro_func2(phi, input, r_p, alpha_t)			--eta_tro_func2(phi, input, r_p, alpha_t) - gamma;
	tau_tro = arr_subt1(tau_tro,0)  --arr_subt1(tau_tro,gamma)
    
	local r_tro = {}
	r_tro = r_tro_func2(phi,input,r_p);
	
	-- solution for tooth thickness:----------------------------
	-- find the point of inv on pitch circle
	xi_a2 = math.sqrt(( r_p /r_b)^2 - 1)
	local xi2={}
	xi2 = linspaces(xi_SOI,xi_a2,60)
	
	r_inv2 = arr_add1(arr_square(xi2),1)			-- (1+xi2.^2)
	r_inv2 = arr_sqrt(r_inv2)						-- sqrt(1+xi2.^2)
	r_inv2 = arr_mult1(r_inv2,r_b)				-- r_b*sqrt(1+xi2.^2)
	
	tau_inv2 = arr_subt2(xi2,arr_atan(xi2))
	
	inv_x0 = arr_mult1(arr_sin(arr_subt1(tau_inv2,tau_inv2[1])),-1)
	inv_x0 = arr_mult2(inv_x0,r_inv2)
	
	inv_y0 = arr_mult2(arr_cos(arr_subt1(tau_inv2,tau_inv2[1])),r_inv2)
	
	-- Angle to get inv on zero x-axis
	length = #inv_x0
	th_corr = Pi/2-math.acos(inv_x0[length]/inv_y0[length]);
	
	----%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	xi = linspaces(xi_SOI,xi_a,input["Res"])
	tau_inv = arr_subt2(xi,arr_atan(xi))
	tau_inv = arr_subt1(tau_inv,0)  --arr_subt1(tau_inv,gamma)
	----%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	th_troch = arr_add1(tau_tro,th_corr-tau_inv[1])
	th_inv = th_corr-tau_inv[1]
	
	
	------------------------------------------------------------
	
	-- make X&Y vertices of Trochoid:
	local x_tro = {}
	local y_tro = {} 
	x_tro = get_xTroch(th_troch,r_tro)
	y_tro = get_yTroch(th_troch,r_tro)
	
	-- make X&Y vertices of Involute:
	x_inv, y_inv = get_inv(xi_SOI,xi_a,r_b,0,th_inv)  --get_inv(xi_SOI,xi_a,r_b,gamma,th_inv)
	
	--print_arr(y_inv)
	--print("\ntau_inv\t"..tau_inv[1])
	return x_inv, y_inv, x_tro, y_tro
end

function get_inv(xi_SOI,xi_a,r_b,gamma,th)
	-- make vertices of involute (X&Y)
	local inv_x = {}							-- x_inv = -sin(tau_inv).*r_inv
	local inv_y = {}							-- y_inv=  cos(tau_inv).*r_inv;
	local r_inv = {}							-- = r_b*sqrt(1+xi.^2);
	local tau_inv = {}							-- = xi - atan(xi) - gamma
	local xi = {}
	
	xi = linspaces(xi_SOI,xi_a,input["Res"])
	
	r_inv = arr_add1(arr_square(xi),1)			-- (1+xi.^2)
	r_inv = arr_sqrt(r_inv)						-- sqrt(1+xi.^2)
	r_inv = arr_mult1(r_inv,r_b)				-- r_b*sqrt(1+xi.^2)
	
    tau_inv = arr_subt2(xi,arr_atan(xi))
	tau_inv = arr_subt1(tau_inv,gamma)
	
	inv_x = arr_mult1(arr_sin(arr_add1(tau_inv,th)),-1)
	inv_x = arr_mult2(inv_x,r_inv)
	
	inv_y = arr_mult2(arr_cos(tau_inv),r_inv)
	--print_arr(xi)
	--print("\n xi_SOI = \t"..th)
	--print_arr(r_inv)
	return inv_x, inv_y
end

function get_xTroch(tau,r)
	-- x_tro= -sin(tau_tro).*r_tro;
	local ans = {}
	ans = arr_sin(tau)
	ans = arr_mult1(ans,-1)
	ans = arr_mult2(ans,r)
	return ans
end

function get_yTroch(tau,r)
	-- y_tro=  cos(tau_tro).*r_tro;
	local ans = {}
	ans = arr_cos(tau)
	ans = arr_mult2(ans,r)
	
	return ans
end

function Secant_method(func,input,r_p, r_b, alpha_t, x0,delta_x ,tol, maxIter)
	local iter = 0
    local x = x0
    local f = func(x,input,r_p, r_b, alpha_t)  
	--print("\n f = \t"..f)
	local dfdx = (f - func((x + delta_x),input,r_p, r_b, alpha_t))/delta_x
	
	while (math.abs(f) > tol and iter < maxIter) do
        x = x + f/dfdx; 
        f = func(x,input,r_p, r_b, alpha_t)
		dfdx = (f - func((x + delta_x),input,r_p, r_b, alpha_t))/delta_x
        iter= iter + 1;
    end
	
	return x
end


function eta_delta(phi,input,r_p, r_b, alpha_t) 
	local r_tro = r_tro_func(phi,input,r_p)
	local xi = math.sqrt(math.max(0, math.pow((r_tro/r_b),2) - 1))
	local eta = eta_tro_func(phi, input, r_p, alpha_t)
	local delta = eta - xi + math.atan(xi)
	
	
	--print("\n r_tro = \t"..r_tro)
	--print("\n xi = \t"..xi)
	--print("\n eta = \t"..eta)
	
	return delta
end

function eta_tro_func(phi, input, r_p, alpha_t)
	local m = input["m"]
	local alpha = input["alpha"]
	local beta = input["beta"]
	local rho_fP_c = input["rho_fP_c"]
	local x = input["x"]
	local h_a_coef = input["h_a_coef"]
	local h_a0_coef = input["h_f_coef"]
	local s_pr = input["s_pr"]

	
	local A= (m*rho_fP_c - s_pr)/(math.cos(alpha)*math.cos(beta)) + m*(h_a0_coef - x - rho_fP_c)*math.tan(alpha_t)
	local B = B_func(phi,input)
	local epsilon = math.atan((B*math.cos(beta))/((r_p - B)*math.tan(phi)))
	local theta =  math.tan(alpha_t) + (m*rho_fP_c*math.cos(phi)/math.cos(beta) - A - B*math.cos(beta)/math.tan(phi))/r_p
	local eta_tro = theta + epsilon - alpha_t + s_pr/(r_p*math.cos(alpha*math.cos(beta)))
	
	--print("\n theta = \t"..eta_tro)
	
	return eta_tro
	--print("\n eta_tro = \t"..eta_tro)
end

function eta_tro_func2(phi, input, r_p, alpha_t)
	local m = input["m"]
	local alpha = input["alpha"]
	local beta = input["beta"]
	local rho_fP_c = input["rho_fP_c"]
	local x = input["x"]
	local h_a_coef = input["h_a_coef"]
	local h_a0_coef = input["h_f_coef"]
	local s_pr = input["s_pr"]
	local epsilon = {}  									-- *
	local theta = {}
	local eta_tro = {}
	
	local A= (m*rho_fP_c - s_pr)/(math.cos(alpha)*math.cos(beta)) + m*(h_a0_coef - x - rho_fP_c)*math.tan(alpha_t)
	local B = B_func2(phi,input)
	
	-- Calculate epsilon:		-- atan((B*cos(beta))./((r_p - B).*tan(phi)))
	local num = {}
	local den = {}
	num = arr_mult1(B,math.cos(beta))						-- ((B*math.cos(beta))
	den = arr_add1(arr_mult1(B,-1),r_p)						-- (r_p - B)
	den = arr_mult2(den,arr_tan(phi))						-- ((r_p - B)*math.tan(phi)))
	epsilon = arr_div2(num,den)								-- (B*math.cos(beta))/((r_p - B)*math.tan(phi))
	epsilon = arr_atan(epsilon)								-- math.atan((B*math.cos(beta))/((r_p - B)*math.tan(phi)))
	
	-- Calculate theta:		-- math.tan(alpha_t) + (m*rho_fP_c*math.cos(phi)/math.cos(beta) - A - B*math.cos(beta)/math.tan(phi))/r_p
	local p1 = {}
	local p2 = {}
	p1 = arr_mult1(B,-math.cos(beta))						-- -B*math.cos(beta)
	p1 = arr_div2(p1,arr_tan(phi))							-- -B*math.cos(beta)/math.tan(phi)
	p2 = arr_mult1(arr_cos(phi),m*rho_fP_c)					-- m*rho_fP_c*math.cos(phi)
	p2 = arr_mult1(p2,1/math.cos(beta))						-- m*rho_fP_c*math.cos(phi)/math.cos(beta)
	p2 = arr_subt1(p2,A)									-- m*rho_fP_c*math.cos(phi)/math.cos(beta) - A
	theta = arr_add2(p1,p2)
	theta = arr_div1(theta,r_p)								-- (m*rho_fP_c*math.cos(phi)/math.cos(beta) - A - B*math.cos(beta)/math.tan(phi))/r_p
	theta = arr_add1(theta,math.tan(alpha_t))
	
	-- Calculate eta_tro:
	local const = {}
	const = - alpha_t + s_pr/(r_p*math.cos(alpha*math.cos(beta)))
	eta_tro = arr_add2(theta,epsilon)
	eta_tro = arr_add1(eta_tro,const)
	
	--print_arr(eta_tro)									-- for debuging
	
	return eta_tro
end




function r_tro_func(phi,input,r_p)
	B= B_func(phi,input)
	local r_tro= math.sqrt(math.pow((r_p-B),2) + math.pow((B*math.cos(input["beta"])/math.tan(phi)),2))
	return r_tro
end

function r_tro_func2(phi,input,r_p)
	B = B_func2(phi,input)
	local r_tro = {}
	local p1 = {}
	local p2 = {}
	p1 = arr_mult1(B,math.cos(input["beta"]))				-- B*math.cos(input["beta"])
	p1 = arr_div2(p1,arr_tan(phi))							-- (B*math.cos(input["beta"])/math.tan(phi))
	p1 = arr_square(p1)										-- math.pow((B*math.cos(input["beta"])/math.tan(phi)),2)
	
	p2 = arr_add1(arr_mult1(B,-1),r_p)						-- (r_p-B)
	p2 = arr_square(p2)										-- math.pow((r_p-B),2)
	
	r_tro = arr_sqrt(arr_add2(p1,p2))						-- math.sqrt(math.pow((r_p-B),2) + math.pow((B*math.cos(input["beta"])/math.tan(phi)),2))
	return r_tro
end

function B_func(phi,input)
	local B = input["m"]*(input["h_f_coef"] - input["x"] - input["rho_fP_c"]*(1-math.sin(phi)))
	return B
end

function B_func2(phi,input)
	--same as B_func but this takes arrays
	-- B = input["m"]*(input["h_f_coef"] - input["x"] - input["rho_fP_c"]*(1-math.sin(phi)))
	local B = {}
	B = arr_mult1(arr_sin(phi),-1)
	B = arr_add1(B,1)								-- (1-math.sin(phi))
	B = arr_mult1(B,-input["rho_fP_c"])				-- -input["rho_fP_c"]*(1-math.sin(phi))
	B = arr_add1(B,input["h_f_coef"] - input["x"])	-- input["h_f_coef"] - input["x"] - input["rho_fP_c"]*(1-math.sin(phi))
	B = arr_mult1(B,input["m"])
	
	--print_arr(B)
	
	return B
end


  
local function print_arr(input_arr)
-- print input values to the console:
  --print(type(input_arr))
  local arr = {}
  arr = input_arr
  --print("\narr = "..input_arr[1])
    for i=1, #arr do
      s = string.format("\nA[%d]\t %f", i,arr[i])
      print(s)
    end
end

local function print_table(input_table)
-- print all elements in the input_table
  local table = {}
  table = input_arr
  for i=1, #table.x do
    s = string.format("\nX[%d]: %f\tY[%d]: %f",i,table.x[i],i,table.y[i])
    print(s)
  end
end 