print"Data2String test"
local D2S=require'Data2String'
local Lua_Version=tonumber(string.match(_VERSION,'%d+%.%d'))

do-- basic (without reference) pretty output
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
	local Output=D2S(t)
	--print(Output)
	assert(Output==(Lua_Version>=5.3 and [[--Generated using Data2String2.lua by RobertL
return {
	[7]="b",
	D={
		E={
			[false]=true,
			[true]=false,
			"e",
		},
	},
	"a",
	2,
	false,
	true,
	{--5
		[1/0]=-1/0,
		0/0,
		1/0,
		math.maxinteger,
		math.mininteger,
	},
}]] or [[--Generated using Data2String2.lua by RobertL
return {
	[7]="b",
	D={
		E={
			[false]=true,
			[true]=false,
			"e",
		},
	},
	"a",
	2,
	false,
	true,
	{--5
		0/0,
		1/0,
	},
}]]),Output)

	Output=D2S(t,'compress')--print(Output)
	assert(Output==(Lua_Version>=5.3 and [[--Generated using Data2String2.lua by RobertL
return {[7]="b",D={E={[false]=true,[true]=false,"e"}},"a",2,false,true,{[1/0]=-1/0,0/0,1/0,math.maxinteger,math.mininteger}}]]
	or [[--Generated using Data2String2.lua by RobertL
return {[7]="b",D={E={[false]=true,[true]=false,"e"}},"a",2,false,true,{[1]=0/0,[2]=1/0}}]]),Output)

	Output=D2S(t,'lazy')
	--print(Output)
	assert(string.find(Output,[=[--Generated using Data2String2.lua by RobertL
return {
	[7]="b",
	D={
		E={
			[false]=true,
			[true]=false,
			"e",
		},
	},
	"a",
	2,
	false,
	true,
	{--5
		[1/0]=-1/0,
		0/0,
		1/0,
		math.maxinteger,
		math.mininteger,
	},
}]=],1,true),Output)
end

do--long string reference
	local t={
		'string',
		'string',
		'long string','long string',
	}
	local Output=D2S(t)
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
end

do--self-reference
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
end

do--circle-reference
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
end

do
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
end

do--	string display
	local t={
		'str',
		'string',
		func='func',
		['function']={
			"C:\\",
			['"']="%\t'[[\t]=]",
		}
	}
	local Output=D2S(t)
	--print(Output)
	assert(Output==[===[--Generated using Data2String2.lua by RobertL
return {
	func="func",
	["function"]={
		[ [["]]]=[==[%	'[[	]=]]==],
		[[C:\]],
	},
	"str",
	"string",
}]===],Output)
end

do--register limit
	local t={
		1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,
		--                                  ^: migrate from register to heap every 50 index
		1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,{
		1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,{
		1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,{
		1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,{
		1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,{
			--                             ^: 49*5=245
			1,
			--	--2,
			--	or "function or expression needs too many registers near ','"
		},
		},
		},
		},
		},
	}
	table.insert(t[50+50][50][50][50][50],2)
	local Output=D2S(t)
--	print(Output)
	local R=assert(load(Output),Output)()
	assert(R[50+50][50][50][50][50][2]==2)
	
	local Output=D2S(t,'lazy')
--	print(Output)
	local R=assert(load(Output),Output)()
	assert(R[50+50][50][50][50][50][2]==2)
	
	local Output=D2S(t,'lazy compress')
--	print(Output)
	local R=assert(load(Output),Output)()
	assert(R[50+50][50][50][50][50][2]==2)
end

do--external reference
	local E1={}
	local function F()end
	local I={}
	local t={[E1]=E1,E=E1,[F]=F,I=I,[I]=I}
	local Output=D2S(t,{E1,F,
--		Lazy=true,--enable or disable
	})
--	print(Output)
	local R=assert(load(Output),Output)(){E1,F}
	assert(R.E==E1 and R[E1]==E1 and R[F]==F and R[R.I]==R.I,Output)
end

print"finish"