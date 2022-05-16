-- functions_array_manipulation: 
-- These functions allow different manipulation methods on arrays or tables (merging, mirroring,...etc)
require "functions_array_mathematic"

function linspaces(p1,p2,N)
-- Make linearly spaced array from (p1) to (p2) with (N) number of steps
  local V = {}
  diff = (p2-p1)/(N-1)
  for i=0, N-1 do
    V[i+1] = p1+i*diff
    --print("\noutput = "..V[i+1])
  end
  return V
end

function magnitude(v) 
	return math.sqrt(v[1]^2 + v[2]^2)
end

function arr_merge(t1,t2)
	local t3 = {unpack(t1)}
	for I = 1,#t2 do
		t3[#t1+I] = t2[I]
	end
	return t3
end

function merge_table(table1, table2)
	for _, value in ipairs(table2) do
		table1[#table1+1] = value
	end
	return table1
end

function arr_inv(arr)
-- Inv arr
  local ans = { }
  for i in ipairs(arr) do
    ans[i] = arr[i][1]
  end
  return ans
end


function arr_reverse(arr)
-- flip the elements in arr
    local reversed_arr = {}
    local itemCount = #arr
    for i=1, itemCount do
        reversed_arr[itemCount-i + 1] = arr[i]
    end
    return reversed_arr
end

function table_reverse(table)
-- flip the elements in table for all columns(x & y)
    local ans = {}
    ans.x = {}
    ans.y = {}
    local itemCount = #table.x
    for i=1, itemCount do
        ans.x[itemCount-i+1] = table.x[i]
        ans.y[itemCount-i+1] = table.y[i]
    end
    return ans
end

function table_mirror(table,x_factor,y_factor)
-- mirror the table around X or Y
-- Note: to mirror around X-Axis use x_factor = -1
    local ans = {}
    ans.x = {}
    ans.y = {}
    local itemCount = #table.x
    for i=1, itemCount do
        ans.x[i] = table.x[i]*x_factor
        ans.y[i] = table.y[i]*y_factor
    end
    return ans
end



function linear_extrude_arr(dirction,arr_x,arr_y,angle)
-- make linear extrude for array points
-- note: (angle) in [rad]
  local V = {}
  local th = angle*180/Pi
  for i in ipairs(arr_x) do
    V[i] = rotate( th,Z)*v(arr_x[i],arr_y[i])
    --print("\nX = "..V[i].x) print("\tY = "..V[i].y)
  end
  return linear_extrude(dirction, V)
end

function rot_table(Table,angle)
-- rotate vertices (X,Y) around Z-axis, as a table input and output
-- note: (angle) in [rad]
  local ans = {}
  local vec_x = {}
  local vec_y = {}
  local ang_deg = angle*180/Pi

  for i in ipairs(Table[1]) do
    vec = rotate(ang_deg,Z)*v(Table[1][i],Table[2][i])
    vec_x[i] = vec.x
    vec_y[i] = vec.y
  end

  ans[1] = vec_x
  ans[2] = vec_y
  return ans
end

function MatMul( m1, m2 )
-- print(tprint(m1))
-- print(tprint(m2))
-- print(tprint(#m1[1]))
-- print(tprint(#m2))
    if #m1[1] ~= #m2 then       -- inner matrix-dimensions must agree
        return nil
    end 
    local res = {}
 
    for i = 1, #m1 do
        res[i] = {}
        for j = 1, #m2[1] do
            res[i][j] = 0
            for k = 1, #m2 do
                res[i][j] = res[i][j] + m1[i][k] * m2[k][j]
            end
        end
    end
 
    return res
end

function rot_table_mat(a, mat)
	R_z = { { math.cos(a), -math.sin(a)}, { math.sin(a), math.cos(a) } }
	m_out = MatMul(R_z, mat)
	return m_out
end

function print_arr(input_arr)
-- print all input_arr values to the console:
  local arr = {}
  arr = input_arr
  --print("\narr = "..input_arr[1])
  for i=1, #arr do
    print("\narr = "..arr[i]) print(" ")
  end  
end

function arr_intersection(arr1,arr2)
-- find the intersection of 2 array sets in the table form (arr1.x, arr1.y, arr2.x, arr2.y)
-- return: key which contains the index of intersection for arr1 & arr2
  local dist = {}
  for i in ipairs(arr1.x) do
    dist[i] = {}
    for j in ipairs(arr2.x) do
      dist[i][j] = distance(arr1.x[i],arr1.y[i],arr2.x[j],arr2.y[j])
    end
  end
  --find the minimum distance
  local min_val = dist[1][1]
  local key = {-1,-1}
  for i in ipairs(arr1.x) do
      for j in ipairs(arr2.x) do 
        if dist[i][j] < min_val then
            min_val = dist[i][j]
            key = {i,j}
        end
      end    
  end
  return key
end


function distance(p1_x,p1_y,p2_x,p2_y)
-- calculate and return the distance between 2 points in X,Y coordinates
  dist = math.sqrt((p2_x-p1_x)^2+(p2_y-p1_y)^2)
  return dist
end


function arr_resize(arr,idx1,idx2)
-- remove some elements of table
-- new array will be from idx1 to idx2 only
-- note: idx2 = -1 will take the index of final element in arr
  local ans = {}
  ans.x = {}
  ans.y = {}
  if idx2 == -1 then
    idx2 = #arr.x
  end
  local range = idx2-idx1
  local j = 0
  for i=1, range+1 do
    ans.x[i] = arr.x[idx1+j]
    ans.y[i] = arr.y[idx1+j]
    j = j+1
  end
  return ans
end

--------------------------------------------------

-- Local Functions:
function print_inputs(input_arr, parameter)
-- print input values to the console:
  for key,value in pairs(input_arr) do
    print("\n") print(tostring(key)) print("\t\t")
	if (type(value) == "table" and parameter ~= "no tables") then
		print(tprint(value))
	else
		print(tostring(value))
	end
  end  
end

function tprint (tbl, indent)
  if (type(tbl) ~= "table") then
	return tostring(tbl)
  end
  if not indent then indent = 0 end
  local toprint = string.rep(" ", indent) .. "{\r\n"
  indent = indent + 2 
  for k, v in pairs(tbl) do
    toprint = toprint .. string.rep(" ", indent)
    if (type(k) == "number") then
      toprint = toprint .. "[" .. k .. "] = "
    elseif (type(k) == "string") then
      toprint = toprint  .. k ..  "= "   
    end
    if (type(v) == "number") then
      toprint = toprint .. v .. ",\r\n"
    elseif (type(v) == "string") then
      toprint = toprint .. "\"" .. v .. "\",\r\n"
    elseif (type(v) == "table") then
      toprint = toprint .. tprint(v, indent + 2) .. ",\r\n"
    else
      toprint = toprint .. "\"" .. tostring(v) .. "\",\r\n"
    end
  end
  toprint = toprint .. string.rep(" ", indent-2) .. "}"
  return toprint
end


function print_arr(input_arr)
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

function print_table(input_arr)
  local table = {}
  table = input_arr
  for i=1, #table.x do
    s = string.format("\nX[%d]: %f\tY[%d]: %f",i,table.x[i],i,table.y[i])
    print(s)
  end
end 