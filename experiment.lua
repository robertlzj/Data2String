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

local _,Func=setmetatable({},{
	__index=function(R,id) R[id]={} return R[id] end,
	__call=function(R,id,t)
		if rawget(R,id) and assert(type(t)=='table') then
			for k,v in pairs(t) do--copy
				R[id][k]=v
			end
			t=R[id]
		end
		R[id]=t
		return t
	end,
}),error
return _(1,{
	[_--[[1]]]=nil--[[1]],
	T=nil--[[1]],
}--[[4]])
_[1][_[1]]=_[1]
_[1].T=_[1]