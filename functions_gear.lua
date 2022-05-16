function calc_addendum_factor(error, ratio, z_p)
	t0 = 1
    t1 = 0
	
	while (math.abs(t1 - t0) > error) do
		t0 = t1
		beta = math.atan(math.sin(t0)/(1 + 2*ratio - math.cos(t0)))
		t1 = Pi/z_p + 2*ratio*beta
    end
	
	k = 1 + 2*ratio
	result_addendum_factor= 0.25 * z_p * (1 - k + math.sqrt(1 + k * k - 2*k*math.cos(t1)))
	return result_addendum_factor
end

function calc_circle_pt(radius, number_points)
	theta = linspaces(0, 2*Pi, number_points)
	Output = {}
	Output["X"] = arr_mult1(arr_cos(theta), radius)
	Output["Y"] = arr_mult1(arr_sin(theta), radius)
	return Output
end

function getSlope(x1, y1, x2, y2)
  local xDif, yDif = (x1 - x2), (y1 - y2)
  local slope = yDif/xDif
  return slope, yDif, xDif
end

function make_vectors(arr, arr2)
	
	output = {}
	for i = 1, #arr do
		output[i] = v(arr[i], arr2[i])
	end
	
	return output
end