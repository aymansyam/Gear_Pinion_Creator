-- class.lua
-- Compatible with Lua 5.1 (not 5.0).
function class(base, init)
  local c = {}    -- a new class instance
  if not init and type(base) == 'function' then
     init = base
     base = nil
  elseif type(base) == 'table' then
   -- our new class is a shallow copy of the base class!
     for i,v in pairs(base) do
        c[i] = v
     end
     c._base = base
  end
  -- the class will be the metatable for all its objects,
  -- and they will look up their methods in it.
  c.__index = c

  -- expose a constructor which can be called by <classname>(<args>)
  local mt = {}
  mt.__call = function(class_tbl, ...)
  local obj = {}
  setmetatable(obj,c)
  if init then
     init(obj,...)
  else 
     -- make sure that any stuff from the base class is initialized!
     if base and base.init then
     base.init(obj, ...)
     end
  end
  return obj
  end
  c.init = init
  c.is_a = function(self, klass)
     local m = getmetatable(self)
     while m do 
        if m == klass then return true end
        m = m._base
     end
     return false
  end
  setmetatable(c, mt)
  return c
end


Point = class(function(pt,x,y,z)
   pt:set(x,y,z)
 end)

local function eq(x,y)
  return x == y
end

function Point.__eq(p1,p2)
  return eq(p1[1],p2[1]) and eq(p1[2],p2[2]) and eq(p1[3],p2[3])
end

function Point.get(p)
  return p[1],p[2],p[3]
end

-- vector addition is '+','-'
function Point.__add(p1,p2)
  return Point(p1[1]+p2[1], p1[2]+p2[2], p1[3]+p2[3])
end

function Point.__sub(p1,p2)
  return Point(p1[1]-p2[1], p1[2]-p2[2], p1[3]-p2[3])
end

-- unitary minus  (e.g in the expression f(-p))
function Point.__unm(p)
  return Point(-p[1], -p[2], -p[3])
end

-- scalar multiplication and division is '*' and '/' respectively
function Point.__mul(s,p)
  return Point( s*p[1], s*p[2], s*p[3] )
end

function Point.__div(p,s)
  return Point( p[1]/s, p[2]/s, p[3]/s )
end

-- dot product is '..'
function Point.__concat(p1,p2)
  return p1[1]*p2[1] + p1[2]*p2[2] + p1[3]*p2[3]
end

-- cross product is '^'
function Point.__pow(p1,p2)
   return Point(
     p1[2]*p2[3] - p1[3]*p2[2],
     p1[3]*p2[1] - p1[1]*p2[3],
     p1[1]*p2[2] - p1[2]*p2[1]
   )
end

function Point.normalize(p)
  local l = p:len()
  p[1] = p[1]/l
  p[2] = p[2]/l
  p[3] = p[3]/l
end

function Point.set(pt,x,y,z)
  if type(x) == 'table' and getmetatable(x) == Point then
     local po = x
     x = po[1]
     y = po[2]
     z = po[3]
  end
  pt[1] = x
  pt[2] = y
  pt[3] = z 
end

function Point.translate(pt,x,y,z)
   pt[1] = pt[1] + x
   pt[2] = pt[2] + y
   pt[3] = pt[3] + z 
end

function Point.__tostring(p)
  return string.format('(%f,%f,%f)',p[1],p[2],p[3])
end

local function sqr(x) return x*x end

function Point.len(p)
  return math.sqrt(sqr(p[1]) + sqr(p[2]) + sqr(p[3]))
end