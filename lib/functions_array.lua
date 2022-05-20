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

function arr_div1(arr,factor)
-- divide all elements in arr over the factor
  local ans = {}
  for i in ipairs(arr) do
    ans[i] = arr[i]/factor
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

-- Array manipulations

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

  function distance(p1_x,p1_y,p2_x,p2_y)
  -- calculate and return the distance between 2 points in X,Y coordinates
    dist = math.sqrt((p2_x-p1_x)^2+(p2_y-p1_y)^2)
    return dist
  end

  --------------------------------------------------
  
  -- Local Functions:
  
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
  

