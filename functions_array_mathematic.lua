-- functions_array_mathematic:
-- Perform mathematical operations on arrays as element wise operations or a factor with array

function arr_mult1(arr,factor)
-- multiply all elements in arr by the factor
  local ans = {}
  for i in ipairs(arr) do
    ans[i] = arr[i]*factor
  end
  return ans
end

function arr_mult2(arr1,arr2)
-- element wise multiplication of arr1 & arr2
  local ans = {}
  for i in ipairs(arr1) do
    ans[i] = arr1[i]*arr2[i]
  end
  return ans
end

function arr_div1(arr,factor)
-- divide all elements in arr over the factor
  local ans = {}
  for i in ipairs(arr) do
    ans[i] = arr[i]/factor
  end
  return ans
end

function arr_div2(arr1,arr2)
-- element wise division of arr1 / arr2
  local ans = {}
  for i in ipairs(arr1) do
    ans[i] = arr1[i]/arr2[i]
  end
  return ans
end

function arr_pow(arr,power)
-- elements in arr to a power: (power)
  local ans = {}
  for i in ipairs(arr) do
    ans[i] = math.pow(arr[i],power)
  end
  return ans
end

function arr_square(arr)
-- elements in arr to a power = 2:
  local ans = {}
  for i in ipairs(arr) do
    ans[i] = math.pow(arr[i],2)
  end
  return ans
end

function arr_sqrt(arr)
-- square root of all elements in arr
  local ans = {}
  for i in ipairs(arr) do
    ans[i] = math.sqrt(arr[i])
  end
  return ans
end


function arr_cos(arr)
-- find the cos values for all arr elements
  local ans = {}
  for i in ipairs(arr) do
    ans[i] = math.cos(arr[i])
  end
  return ans
end

function arr_sin(arr)
-- find the sin values for all arr elements
  local ans = {}
  for i in ipairs(arr) do
    ans[i] = math.sin(arr[i])
  end
  return ans
end

function arr_tan(arr)
-- find the tan values for all arr elements
  local ans = {}
  for i in ipairs(arr) do
    ans[i] = math.tan(arr[i])
  end
  return ans
end

function arr_atan(arr)
-- find the atan values for all arr elements
  local ans = {}
  for i in ipairs(arr) do
    ans[i] = math.atan(arr[i])
  end
  return ans
end

function arr_add1(arr,factor)
-- add the factor to all arr elements
  local ans = {}
  for i in ipairs(arr) do
    ans[i] = arr[i]+factor
  end
  return ans
end

function arr_add2(arr1,arr2)
-- element wise addition of arr1 & arr2
  local ans = {}
  for i in ipairs(arr1) do
    ans[i] = arr1[i]+arr2[i]
  end
  return ans
end

function arr_subt1(arr,factor)
-- Subtract the factor from all arr elements
  local ans = {}
  for i in ipairs(arr) do
    ans[i] = arr[i]-factor
  end
  return ans
end

function arr_subt2(arr1,arr2)
-- element wise subtraction of arr1 & arr2
  local ans = {}
  for i in ipairs(arr1) do
    ans[i] = arr1[i]-arr2[i]
  end
  return ans
end

function arc_circle(startang, endang, number_points, circle_center_x, circle_center_y, radius)
circ_vec = linspaces( startang, endang,number_points)
out = {}
out["X"] = arr_add1(arr_mult1(arr_cos(circ_vec), radius), circle_center_x)
out["Y"] = arr_add1(arr_mult1(arr_sin(circ_vec), radius), circle_center_y)

return out

end

function arr_min(arr)
-- find the minimum value from arr elements
  local min = arr[1]
  local idx = 1
  for i in ipairs(arr) do
    if arr[i] < min then
        min = arr[i]
        idx = i
    end
  end
  return min,idx
end

function arr_below(arr,val)
-- find the index of first array element below a specific value
  local idx = 1
  --print("\nInv   "..val)
  for i in ipairs(arr) do
    if arr[i] < val then
        idx = i
    end
  end
  return idx
end
