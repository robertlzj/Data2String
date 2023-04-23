--experiment.lua
local Order={}
local function Count_Order(ID)
	table.insert(Order,ID)
	return false
end
_={
	Count_Order'1',
	[Count_Order'2']=Count_Order'3',
	[Count_Order'4']={
		Count_Order'5',
		[Count_Order'6']=Count_Order'7',
	},
	Count_Order'8',
}
assert(table.concat(Order)=='12345678')

local t={}
t[t]=t
t.T=t
local Output=require("serpent").dump(t)
print(Output)
local t2=assert(load(Output),Output)()
assert(t2[t2]==t2 and t2.T==t2)

local t1={}
local t2={}
t1.T1=t2
t2.T2=t1
t1[t1]='T1'
local Output=require("serpent").dump(t1)--print(Output)
print(Output)
local t3=assert(load(Output),Output)()
assert(t3.T1.T2==t3 and t3[t3]=='T1')

local t1={}
local t2={}
local t3={}
t1[t1]=t2
t2[t2]=t3
t3[t3]=t1
local Output=require("serpent").dump(t1)
print(Output)
local t4=assert(load(Output),Output)()
local t5=t4[t4]
local t6=t5[t5]
assert(t6[t6]==t4)

--Generated using Data2String2.lua by RobertL
local _,Func=setmetatable({},{
	__call=function(R,id,t)
		R[id]=t
		return t
	end,
}),error
_(2,{
	[_--[[2]]]=_(1,{
		[_--[[1]]]=_(3,{
			[_--[[3]]]=nil--[[2]],
		}--[[2]]),
	}--[[2]]),
}--[[3]])
_[2][_[2]]_[1][_[1]]_[3][_[3]]=_[2]
_[1][_]=nil
_[2][_]=nil
return _[1]