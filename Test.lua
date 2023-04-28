print"Data2String test"
local D2S=require'Data2String'
local Lua_Version=tonumber(string.match(_VERSION,'%d+%.%d'))

local Output

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
		[math.huge] = -math.huge,
	},--5
	nil,
	'b',
	D={E={'e',[true]=false,[false]=true}}
}
Output=D2S(t)
--print(Output)
assert(Output==(Lua_Version>=5.3 and [[--Generated using Data2String2.lua by RobertL
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
		[1/0]=-1/0,
	},
	[7]="b",
	D={
		E={
			"e",
			[false]=true,
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
			[false]=true,
			[true]=false,
		},
	},
}]]),Output)

Output=D2S(t,'compress')--print(Output)
assert(Output==(Lua_Version>=5.3 and [[--Generated using Data2String2.lua by RobertL
return {"a",2,false,true,{0/0,1/0,math.maxinteger,math.mininteger,[1/0]=-1/0},[7]="b",D={E={"e",[false]=true,[true]=false}}}]]
or [[--Generated using Data2String2.lua by RobertL
return {"a",2,false,true,{[1]=0/0,[2]=1/0},[7]="b",D={E={"e",[false]=true,[true]=false}}}]]),Output)

Output=D2S(t,'lazy')
--print(Output)
assert(string.find(Output,[=[--Generated using Data2String2.lua by RobertL
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
		[1/0]=-1/0,
	},
	[7]="b",
	D={
		E={
			"e",
			[false]=true,
			[true]=false,
		},
	},
}]=],1,true),Output)


--long string reference
t={
	'string',
	'string',
	'long string','long string',
}
Output=D2S(t)
--print(Output)
assert(string.find(Output,[=[{
	"string",
	"string",
	_(1,"long string"--[[2]]),
	_[1],
}]=],1,true),Output)
Output=D2S(t,'lazy')
--print(Output)
assert(string.find(Output,[=[--Generated using Data2String2.lua by RobertL
local _,Func=setmetatable({},{
	__call=function(R,id,t)
		R[id]=t
		return t
	end,
}),error
return {
	"string",
	"string",
	_(1,"long string"--[[2]]),
	_[1],
}]=],1,true),Output)

-- self-reference
local t={}
t[t]=t
t.T=t
local Output=D2S(t)
--print(Output)
local t2=assert(load(Output),Output)()
assert(t2[t2]==t2 and t2.T==t2)

Output=D2S(t,'lazy'
	..'compress'
)
--print(Output)
t2=assert(load(Output),Output)()
assert(t2[t2]==t2 and t2.T==t2)

-- circle-reference
local t1={}
local t2={}
t1.T1=t2
t2.T2=t1
t1[t1]='T1'
local Output=D2S(t1)
--print(Output)
local t3=assert(load(Output),Output)()
assert(t3.T1.T2==t3 and t3[t3]=='T1')

Output=D2S(t1,'lazy'
	..'compress'
)
--print(Output)
t3=assert(load(Output),Output)()
assert(t3.T1.T2==t3 and t3[t3]=='T1')

local t1={}
local t2={}
local t3={}
t1[t1]=t2
t2[t2]=t3
t3[t3]=t1
local Output=D2S(t1)
--print(Output)
local t4=assert(load(Output),Output)()
local t5=t4[t4]
local t6=t5[t5]
assert(t6[t6]==t4)

Output=D2S(t1,'lazy'
--	..'compress'
)
--print(Output)
t4=assert(load(Output),Output)()
t5=t4[t4]
t6=t5[t5]
assert(t6[t6]==t4)

--	string display
local t={
	'str',
	'string',
	func='func',
	['function']={
		"C:\\",
		['"']="%\t'[[\t]=]",
	}
}
Output=D2S(t)
--print(Output)
assert(Output==[===[--Generated using Data2String2.lua by RobertL
return {
	"str",
	"string",
	func="func",
	["function"]={
		[[C:\]],
		[ [["]]]=[==[%	'[[	]=]]==],
	},
}]===],Output)

print"finish"