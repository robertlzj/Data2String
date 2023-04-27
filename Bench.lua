print"Data2String performance bench"
--	modified from [serpent](https://github.com/pkulchenko/serpent/blob/master/t/bench.lua).

local socket=require'socket'
local get_time=socket.gettime
	and os.clock

local ITERS = ... or 50000
print("ITERS",ITERS)

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
	leopard = function(...) return require("leopard").Serialize(...) end,
	D2S = function(...) return require'Data2String'(...) end,
	D2S_compress = function(...) return require'Data2String'(...,'compress') end,
	D2S_lazy = function(...) return require'Data2String'(...,'lazy') end,
	D2S_lazy_compress = function(...) return require'Data2String'(...,'lazy compress') end,
	D2S_original = function(...) return require'Data2String-c996c5e6'(...) end,
	D2S_compress_original = function(...) return require'Data2String-c996c5e6'(...,'compress') end,
	D2S_lazy_original = function(...) return require'Data2String-c996c5e6'(...,'lazy') end,
	D2S_lazy_compress_original = function(...) return require'Data2String-c996c5e6'(...,'lazy compress') end,
	--'penlight','leopard',
	'serpent','D2S','D2S_compress','D2S_lazy','D2S_lazy_compress',
	'D2S_original','D2S_compress_original','D2S_lazy_original','D2S_lazy_compress_original',
}

for index, serializer_name in ipairs(Serializer) do
	--load require
	local serializer=Serializer[serializer_name]
	print(serializer_name,'\n',serializer(a))
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
	penlight = load,
	D2S = load,
	D2S_compress = load,
	D2S_lazy = load,
	D2S_lazy_compress = load,
	D2S_original = load,
	D2S_compress_original = load,
	D2S_lazy_original = load,
	D2S_lazy_compress_original = load,
	'serpent','D2S','D2S_compress','D2S_lazy','D2S_lazy_compress',
	'D2S_original','D2S_compress_original','D2S_lazy_original','D2S_lazy_compress_original',
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

print"finish"