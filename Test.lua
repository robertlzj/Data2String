local D2S=require'Data2String2'
local Lua_Version=tonumber(string.match(_VERSION,'%d+%.%d'))

-- basic (without reference) pretty output
local t={
	'a',
	2,
	false,
	true,
	{
		0/0,--NaN
		1/0,--math.huge
		math.maxinteger,
		math.mininteger,
	},--5
	nil,
	'b',
	D={E={'e',[true]=false,}}
}
assert(D2S(t)==(Lua_Version>=5.3 and [[--Generated using Data2String2.lua by RobertL
return {
	"a",
	2,
	false,
	true,
	{--5
		0/0,
		1/0,
		math.maxinteger,
		math.mininteger,
	},
	[7]="b",
	D={
		E={
			"e",
			[true]=false,
		},
	},
}]] or [[--Generated using Data2String2.lua by RobertL
return {
	"a",
	2,
	false,
	true,
	{--5
		0/0,
		1/0,
	},
	[7]="b",
	D={
		E={
			"e",
			[true]=false,
		},
	},
}]]))
assert(D2S(t,'compress')==(Lua_Version>=5.3 and [[--Generated using Data2String2.lua by RobertL
return {"a",2,false,true,{0/0,1/0,math.maxinteger,math.mininteger},[7]="b",D={E={"e",[true]=false}}}]]
or [[--Generated using Data2String2.lua by RobertL
return {"a",2,false,true,{0/0,1/0},[7]="b",D={E={"e",[true]=false}}}]]))

-- self-reference
local t={}
t[t]=t
t.T=t
local t2=load(D2S(t))()
assert(t2[t2]==t2 and t2.T==t2)

-- circle-reference
local t1={}
local t2={}
t1.T1=t2
t2.T2=t1
local t3=load(D2S(t1))()
assert(t3.T1.T2==t3)

--	string display
local t={
	'string',
	key={
		"C:\\",
		['function']="%\t'[[\t]=]",
	}
}
assert(D2S(t)==[===[--Generated using Data2String2.lua by RobertL
return {
	"string",
	key={
		[[C:\]],
		["function"]=[==[%	'[[	]=]]==],
	},
}]===])