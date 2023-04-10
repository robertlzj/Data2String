--Data2String2.lua by RobertL
local Get_Type,P,IP,I,TR,F,String_Format,Concat_Table,Repeat_String,Next,String_Length,String_Dump,String_Sub,String_Find=type,pairs,ipairs,table.insert,table.remove,math.floor,string.format,table.concat,string.rep,next,string.len,string.dump,string.sub,string.find

local Keywords={}
for _,Keyword in ipairs({'and', 'break', 'do', 'else', 'elseif', 'end', 'false',
  'for', 'function', 'goto', 'if', 'in', 'local', 'nil', 'not', 'or', 'repeat',
  'return', 'then', 'true', 'until', 'while'}) do
	Keywords[Keyword] = true
end

local function N() end

local Is_Normal,Is_Compress=true,false
--	Is_Normal: won't compress
--	Is_Compress: compressed, a little faster

local function String_Converter(String)
	local String_Wrapped_By_Format_Q=String_Format('%q',String)
	--	[[\"...\"]]
	local Prefix,Converted_String,Postfix
	if Is_Normal and String_Sub(String_Wrapped_By_Format_Q,2,-2)~=String then
		;	local Literal_String_Level=0
		;	local Literal_String_Start,Literal_String_End
		repeat
			Literal_String_Start='['..Repeat_String('=',Literal_String_Level)..'['
			Literal_String_End=']'..Repeat_String('=',Literal_String_Level)..']'
			Literal_String_Level=Literal_String_Level+1
		until not String_Find(String,Literal_String_Start,1,true) and not String_Find(String,Literal_String_End,1,true)
		Prefix=Literal_String_Start
		Converted_String=String
		Postfix=Literal_String_End
	else
		Converted_String=String_Wrapped_By_Format_Q
	end
	return Converted_String,Prefix,Postfix
end--String_Converter

local Input_Converter={
	[math.huge]='1/0',[-math.huge]='-1/0',
	[true]='true',[false]='false',
}
if math.mininteger then
	Input_Converter[math.maxinteger]='math.maxinteger'
	Input_Converter[math.mininteger]='math.mininteger'
end

local function Data2String(Data,Configure)
	--[[
		Configure: default true
			true
			'compress', could `load`, no format
			false, format for read only (can't load)
				equal {C=false}
				will failed, if self-reference exist
			table={P=pairs,Paris=pairs,String_Converter=Wrap_String,SC=Wrap_String,Reference_String_If_Longer_Than_Length=10,RS=10}
	]]
	local Pairs,String_Converter,Comma=P,String_Converter,','--pairs,string convert,comma
	local RS=10
	--	Reference_String_If_Longer_Than_Length
	local SO
	--	scan only, use internally?
	
	Is_Normal,Is_Compress=true,false

	if Configure==nil then
		Configure=true
	elseif Configure=='compress' then
		Is_Normal=false
		Is_Compress=true
	else
		if Get_Type(Configure)=='table' then
			Pairs=Configure.P or Configure.Pairs or Pairs
			String_Converter=Configure.CS or Configure.String_Converter or String_Converter
			Comma=Configure.CO or Comma
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
		else assert(Configure==false,'unhandle Configure')
			SO=false
			Comma=''
			String_Converter=assert
			Configure=nil
		end
	end
	local Objects={--[[Objects
		[Object]=Object_Reference_Count,
		--	'nil' or 'number'.
	]]}
	local Type
	local function Scan(Input)
		Type=Get_Type(Input)
		if Type=='table' or (Is_Normal and Type=='string' and RS and String_Length(Input)>RS) then
			if Objects[Input] then
				Objects[Input]=Objects[Input]+1
				assert(Configure or type(Input)~='table',"can't use `false` for configure since there is circle-reference")
			else
				Objects[Input]=1
				if Type=='table' then for k,v in Pairs(Input) do
					Scan(k);Scan(v)
				end end
			end
		end
	end
	Scan(Data)
	if SO then
		return Objects
	end
	
	--generate ID, clean single instance
	local ID=1
	local tc={--[[
		[id]=count
	]]}
	for t,c in P(Objects) do
		if c>1 then
			Objects[t]=ID
			tc[ID]=c
			ID=ID+1
		else
			Objects[t]=nil
		end
	end

	local o={--output list
		'--Generated using Data2String2.lua by RobertL\n',
		Configure and Next(Objects) and [[local _,Func=setmetatable({},{
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
	local Write_Newline=Is_Compress and N or function()
		if LE then
			I(o,LE)
			LE=nil
		end
		return I(o,'\n')
	end
	local function Write(text)
		return I(o,text)
	end
	
	local Indent=Is_Compress and N or function(Level)
		return Write(Repeat_String('\t',Level))
	end
	local Need_Break_Sequent_Open_Bracket
	local function Reference(Input,Indent_Level)
		Type=Get_Type(Input)
		local ID=Configure and Type~='number' and Objects[Input]
		if ID then
			Write'_'
			if Objects[ID] then
				Write'['Write(ID)Write']'
				return
			else
				Write'('Write(ID)Write','
				Objects[ID]=ID
			end
		end
		local Converted_Input=Input_Converter[Input]
		if Converted_Input then
			Write(Converted_Input)
		elseif Type=='string' then
			local Converted_String,Prefix,Postfix=String_Converter(Input)
			if Need_Break_Sequent_Open_Bracket then
				Need_Break_Sequent_Open_Bracket=false
				if o[#o]=='[' and String_Sub(Prefix or Converted_String,1,1)=='[' then
					Write' '
				end
			end
			if Prefix then
				Write(Prefix)
			end
			Write(Converted_String)
			if Postfix then
				Write(Postfix)
			end
		elseif Type=='number' then
			if Input~=Input--[[NaN eg `0/0` ]] then
				Converted_Input='0/0'
			elseif Input==F(Input) then
				Converted_Input=F(Input)
			end
			Write(Converted_Input or Input)
		elseif Type=='nil' then
			Write'nil'
		elseif Type=='function' then
			Write(String_Dump(Input))
		elseif Type=='table' then
			Write'{'
			if Next(Input)==nil then
				Write'}'
			else
				local is={}
				for k,v in Pairs(Input) do--simulate ipairs
					if Get_Type(k)=='number' then
						is[k]=v
					end
				end
				for ix,v in IP(is) do
					Write_Newline()Indent(Indent_Level+1)
					if Is_Normal and math.fmod(ix,5)==0 then
						LE='--'..ix
					end
					Reference(v,Indent_Level+1)Write(Comma)
					is[ix]=is
				end
				for k,v in Pairs(Input) do
					if is[k]~=is then
						Write_Newline()Indent(Indent_Level+1)
						if not (Get_Type(k)=='string' and (not Configure or (not Keywords[k] and String_Find(k,'^[%a_][%w_]*$'))) and (Write(k) or true)) then
							Write'['
							Need_Break_Sequent_Open_Bracket=true
							Reference(k,Indent_Level+1)
							Write']'
						end
						Write'='Reference(v,Indent_Level+1)Write(Comma)
					end
				end
				if Is_Compress then
					TR(o)--remove last comma
				end
				Write_Newline()Indent(Indent_Level)Write'}'
			end
		else error("unhandle type: "..Type)
		end
		if ID then
			if Is_Normal then
				Write'--[['Write(tc[ID])Write']]'--reference cout
			end
			Write')'
		end
	end
	Reference(Data,0)
	
	return Concat_Table(o)
end--Data2String

return Data2String
