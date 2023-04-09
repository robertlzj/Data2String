--Data2String2.lua by RobertL
local T,P,IP,I,F,String_Format,Concat_Table,Repeat_String,next=type,pairs,ipairs,table.insert,math.floor,string.format,table.concat,string.rep,next
local function Wrap_String(String)
	local String_Wrapped_By_Format_Q=String_Format('%q',String)
	--	[[\"...\"]]
	local Converted_String
	if string.sub(String_Wrapped_By_Format_Q,2,-2)~=String then
		;	local Literal_String_Level=0
		;	local Literal_String_Start,Literal_String_End
		repeat
			Literal_String_Start='['..string.rep('=',Literal_String_Level)..'['
			Literal_String_End=']'..string.rep('=',Literal_String_Level)..']'
			Literal_String_Level=Literal_String_Level+1
		until not string.find(String,Literal_String_Start,1,true) and not string.find(String,Literal_String_End,1,true)
		Converted_String=Literal_String_Start..String..Literal_String_End
	else
		Converted_String=String_Wrapped_By_Format_Q
	end
	return Converted_String
end
local function Data2String(Data,Configure)
	--[[
		Configure: default true
			true
			false, for read only (can't load) result after 'return'
				equal {C=false}
				will failed, if self-reference exist
			table={P=pairs,Paris=pairs,String_Converter=Wrap_String,SC=Wrap_String,Reference_String_If_Longer_Than_Length=10,RS=10}
	]]
	local Pairs,String_Converter,CO=P,Wrap_String,','--pairs,string convert,comma
	local RS=10
	--	Reference_String_If_Longer_Than_Length
	local SO
	--	scan only, use internally?
	
	if Configure==nil then
		Configure=true
	else
		if T(Configure)=='table' then
			Pairs=Configure.P or Configure.Pairs or Pairs
			String_Converter=Configure.CS or Configure.String_Converter or String_Converter
			CO=Configure.CO or CO
			SO=Configure.SO
			Configure.RS=Configure.RS or Configure.Reference_String_If_Longer_Than_Length
			Configure.C=Configure.C or Configure.Configure
			if Configure.RS==false then
				RS=Configure.RS
			elseif Configure.RS then
				RS=assert(tonumber(Configure.RS),'should be number or false')
			end
			if Configure.C==false then
				Configure=nil
			end
		else
			SO=false
			CO=''
			String_Converter=assert
			Configure=nil
		end
	end
	local ts={--[[tables
		[t]=false/1/2,--reference
		--then
		[id]=true/flase,--could refer (or define at first time)
	]]}
	local t
	local function Scan(input)
		t=T(input)
		if t=='table' or (t=='string' and RS and input:len()>RS) then
			ts[input]=(ts[input] or 0)+1
			if ts[input]>1 then return end
			if t=='table' then for k,v in Pairs(input) do
				Scan(k);Scan(v)
			end end
		end
	end
	Scan(Data)
	if SO then
		return ts
	end
	
	--generate id, clean single instance
	local id=1
	local tc={--[[
		[id]=count
	]]}
	for t,c in P(ts) do
		if c>1 then
			ts[t]=id
			tc[id]=c
			id=id+1
		else
			ts[t]=nil
		end
	end

	local o={--output list
		'--Generated using Data2String2.lua by RobertL\n',
		Configure and next(ts) and [[local _,Func=setmetatable({},{
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
return ]] or 'return '}
	local LE--append on line end (comment of index)
	local Need_Break_Sequent_Open_Bracket
	local function W(text)
		text=text or '\n'
		if text=='\n' and LE then
			text=LE..text
			LE=nil
		end
		I(o,text)
		Need_Break_Sequent_Open_Bracket=false
	end
	local function indent(Level)
		W(Repeat_String('\t',Level))
	end
	local function R(i,n)--reference(input,config,indent number)
		t=T(i)
		local id=Configure and t~='number' and ts[i]
		if id then
			W'_'
			if ts[id] then
				W'['W(id)W']'
				return
			else
				W'('W(id)W','
				ts[id]=id
			end
		end
		if t=='string' then
			local Wrapped_String=String_Converter(i)
			if Need_Break_Sequent_Open_Bracket and string.sub(Wrapped_String,1,1)=='[' then
				W' '--break `[[..]]` to `[ [..]]`.
			end
			W(Wrapped_String)
		elseif t=='number' then
			if i==F(i) then
				i=F(i)--convert to integer
			end
			W(i)
		elseif t=='boolean' then
			W(i and 'true' or 'false')
		elseif t=='nil' then
			W'nil'
		elseif t=='function' then
			W'Func'
		elseif t=='table' then
			W'{'
			if next(i)==nil then
				W'}'
			else
				local is={}
				for k,v in Pairs(i) do--simulate ipairs
					if T(k)=='number' then
						is[k]=v
					end
				end
				for ix,v in IP(is) do
					W()indent(n+1)
					if math.fmod(ix,5)==0 then
						LE='--'..ix
					end
					R(v,n+1)W(CO)
					is[ix]=is
				end
				for k,v in Pairs(i) do
					if is[k]~=is then
						W()indent(n+1)
						if not (T(k)=='string' and (k:find'^[%a_][%w_]*$' or not Configure) and (W(k) or true)) then
							W'['
							Need_Break_Sequent_Open_Bracket=true
							R(k,n+1)
							W']'
						end
						W'='R(v,n+1)W(CO)
					end
				end
				W()indent(n)W'}'
			end
		end
		if id then
			W'--[['W(tc[id])W']]'--reference cout
			W')'
		end
	end
	R(Data,0)
	
	return Concat_Table(o)
end--Data2String
return Data2String
