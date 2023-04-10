--	modified from [serpent](https://github.com/pkulchenko/serpent/blob/master/t/bench.lua).

local socket=require'socket'
local get_time=socket.gettime
	and os.clock

local ITERS = 1000

---------- test data  ---------
local b = {text="ha'ns", ['co\nl or']='bl"ue', str="\"\n'\\\001"}
local a = {
  x=1, y=2, z=3,
  ['function'] = b, -- keyword as a key
  list={'a',nil,nil, -- shared reference, embedded nils
        [9]='i','f',[5]='g',[7]={}}, -- empty table
  ['label 2'] = b, -- shared reference
  [math.huge] = -math.huge, -- huge as number value
}
a.c = a -- self-reference

---------- serialize  ----------
local Serializer = {
	serpent = function(...) return require("serpent").dump(...) end,
	penlight = function(...) return require("pl.pretty").write(...) end,
	D2S = function(...) return require'Data2String'(...) end,
	D2S_compress = function(...) return require'Data2String'(...,'compress') end,
	'serpent','penlight','D2S','D2S_compress',
}

for index, serializer_name in ipairs(Serializer) do
	--load require
	local serializer=Serializer[serializer_name]
	serializer()
end

for index, serializer_name in ipairs(Serializer) do
	local serializer=Serializer[serializer_name]
	local start, str = get_time()
	for _ = 1, ITERS do str = serializer(a) end
	print(("serializer %s (%d): %6.4fs"):format(serializer_name, ITERS, get_time() - start))
	collectgarbage'collect';collectgarbage'collect'
end

--------- deserialize  ---------
local Deserializers = {
  serpent = load,
	D2S = load,
	D2S_compress = load,
	'serpent','D2S','D2S_compress',
}

for index, Serializer_Name in ipairs(Deserializers) do
	local Serializer=Serializer[Serializer_Name]
	local str = Serializer(a)
	local copy
	local start = get_time()
	local Deserializer=Deserializers[Serializer_Name]
  for _ = 1, ITERS do
		copy=Deserializer(str)()
	end
  print(("deserializer %s (%d): %6.4fs"):format(Serializer_Name, ITERS, get_time() - start))
	collectgarbage'collect';collectgarbage'collect'
end