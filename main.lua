
-- User Inputs:
input = {}


--1) number of teeth:
input["z"] = 30

--2) pressure angle [deg]:
input["alpha"] = 20

--3) module:
input["m"] = 5

--4) Profile shift factor [-1.0 to 1.0]:
input["x"] = -0.3

--5) Gear height:
input["h"] = 8

--6) Dedendum coefficient [standard h_f_coef = 1.25] = 1 + c (c=0.25) 
input["h_f_coef"] = 1.25

--7) Addendum Coefficient:
input["h_a_coef"] = 1

--8) Root fillet coefficient:
input["rho_fP_c"] = 0.25

------------------------------------------------
-- Inputs: Control design behaviour: (For both methods)
-- a) Resolution: number of points to make tooth/gap
-- Note: Higher value gives better resolution and a smooth shape (minimum = 10) 
-- Recommended: [30 to 100]
input["Res"] = 60

-- b) Color: [0,1,2,3,...]
-- note: White:0, Red:21 , Yellow:8, Blue:7
input["color"] = 8

-- c) Hole dimentions
--[radius, key height, key widht]:
input["hole_r"] = 4
input["key_w"] = 3
input["key_l"] = 3
-------------------------------------------------
-------------------------------------------------
-- Use external functions from other files:
require "functions_array_manipulation"
require "functions_array_mathematic"
require "functions_gear"
require "functions_gear2"
-------------------------------------------------
-------------------------------------------------
-- main function:
function main()
-- call desired method as user select and emit
	input = get_params(input)
	
    gear = make_gear2(input)
    emit(gear,input["color"])
end
--------------------------------------------------
-- call main function and print inputs:
print_inputs(input)
main()
--------------------------------------------------