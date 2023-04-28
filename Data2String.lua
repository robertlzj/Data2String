--Data2String2.lua by RobertL

local Get_Type,P,IP,Table_Insert,Table_Remove,F,String_Format,Concat_Table,Repeat_String,Next,String_Length,String_Dump,String_Sub,String_Find,String_Replace,String_Lower,Table_Sort,Math_Fmod,Tonumber=type,pairs,ipairs,table.insert,table.remove,math.floor,string.format,table.concat,string.rep,next,string.len,string.dump,string.sub,string.find,string.gsub,string.lower,table.sort,math.fmod,tonumber

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

local function List_Pairs(Key_Order_List_Set,Table)
	local Index,Length,Key,Value=0,#Table
	return function()
		Index=Index+1
		Key=Key_Order_List_Set[Index]
		if Key~=nil then
			Value=Table[Key]
			if Value~=nil then
				return Key,Value
			end
		end
	end
end--List_Pairs

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
	
	local Is_Delay_Assign
	Is_Normal,Is_Compress=true,false

	if Configure==nil then
		Configure=true
	elseif Get_Type(Configure)=='string' then
		local Configure=String_Lower(Configure)
		if String_Find(Configure,'compress',1,true) then
			Is_Normal=false
			Is_Compress=true
		end
		if String_Find(Configure,'lazy',1,true) then
			Is_Delay_Assign=true
		end
	else
		if Get_Type(Configure)=='table' then
			Pairs=Configure.P or Configure.Pairs or Pairs
			String_Converter=Configure.CS or Configure.String_Converter or String_Converter
			Comma=Configure.CO or Comma
			SO=Configure.SO
			Configure.RS=Configure.RS or Configure.Reference_String_If_Longer_Than_Length
			Configure.C=Configure.C or Configure.Configure
			if Configure.Compress then
				Is_Normal=false
				Is_Compress=true
			end
			if Configure.Lazy then
				Is_Delay_Assign=true
			end
			if Configure.RS==false then
				RS=Configure.RS
			elseif Configure.RS then
				RS=assert(Tonumber(Configure.RS),'should be number or false')
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
		[Object]=..,
		--	<number>: Object_Reference_Count.
		--	`nil`.
		[ID]=..,
		--	`false`: defining, nest reference.
		--	ID.
	]]}
	local Type
	local function Is_Could_Define_Reference(Target,Target_Type)
		Target_Type=Target_Type or Get_Type(Target)
		return Target_Type=='table' or (Is_Normal and Target_Type=='string' and RS and String_Length(Target)>RS)
	end
	local Scan do
		local Parent_Tables=Is_Delay_Assign and {--[[
			[Table]=Count,
		]]}
		function Scan(Input,Parent_Table,Is_Nest_Reference)
			Type=Get_Type(Input)
			if Is_Could_Define_Reference(Input,Type) then
				if Objects[Input] then
					if Is_Nest_Reference then
						Objects[Input]=Objects[Input]+1
					end
					assert(Configure or Type~='table',"can't use `false` for configure since there is circle-reference")
					Objects[Input]=Objects[Input]+1
					if Is_Delay_Assign and Parent_Tables[Input] and Parent_Tables[Input]>0 then
						Objects[Parent_Table]=Objects[Parent_Table]+1
						return 'nest reference'
					end
				else
					Objects[Input]=Is_Nest_Reference and 2 or 1
					if Type=='table' then
						if Is_Delay_Assign then
							Parent_Tables[Input]=(Parent_Tables[Input] or 0)+1
						end
						for k,v in Pairs(Input) do
							local Is_Nest_Reference=Scan(k,Input)
							Scan(v,Input,Is_Nest_Reference)
						end
						if Is_Delay_Assign then
							Parent_Tables[Input]=Parent_Tables and Parent_Tables[Input]-1
						end
					end
				end
			end
		end
		Scan(Data)
	end--scan
	if SO then
		return Objects
	end
	if Is_Delay_Assign and not Objects[Data] then
		Objects[Data]=2
	end
	
	--generate ID, clean single instance
	local Assign_ID do
		local Candidate_ID=1
		function Assign_ID(Object)
			local ID=Candidate_ID
			Candidate_ID=Candidate_ID+1
			Objects[Object]=ID
			return ID
		end
	end
	local Object_ID_Count={--[[
		[ID]=Count
	]]}
	for Object,Count in P(Objects) do
		if Count>1 then
			local ID=Assign_ID(Object)
			Object_ID_Count[ID]=Count
		else
			Objects[Object]=nil
		end
	end

	local Output_List={
		'--Generated using Data2String2.lua by RobertL\n',
	}
	local LE--append on line end (comment of index)
	local Newline='\n'
	local Write_Newline=Is_Compress and N or function()
		if LE then
			Table_Insert(Output_List,LE)
			LE=nil
		end
		return Table_Insert(Output_List,Newline)
	end
	local Delay_Write_Separator=Is_Compress and ';' or Newline
	local function Write(Text)
		return Table_Insert(Output_List,Text)
	end
	
	local Delay_Assign_Return_Index
	if Configure and Next(Objects) then
		if Is_Delay_Assign then
			Write[[local _,Func=setmetatable({},{
	__call=function(R,id,t)
		R[id]=t
		return t
	end,
}),error
]]
			Write''
			Delay_Assign_Return_Index=#Output_List
		else
			Write[[local _,Func=setmetatable({},{
	__index=function(R,id) R[id]={} return R[id] end,
	__call=function(R,id,t)
		if rawget(R,id) and assert(type(t)=='table') then
			for k,v in pairs(t) do
				R[id][k]=v
			end
			t=R[id]
		end
		R[id]=t
		return t
	end,
}),error
return ]]
		end
	else
		Write'return '
	end
	local Delay_Output_List={--[[
		Table_ID,Key,Value,
		...
	]]}
	
	local function Delay_Write(Text)
		return Table_Insert(Delay_Output_List,Text)
	end
	
	local Indent=Is_Compress and N or function(Level)
		return Write(Repeat_String('\t',Level))
	end
	local Need_Break_Sequent_Open_Bracket
	
	local Key_Start_Index,Key_End_Index
	
	local Tables_Has_Delay_Key={--[[
		[Table]=Table_ID/false,
	]]}
	local Reference
	local function Expand(Table,Indent_Level,Key_Order_List_Set,Max_Index)
		if Table~=Key_Order_List_Set and Get_Type(Key_Order_List_Set[1])=='number' then
			for Index,Number_Key in ipairs(Key_Order_List_Set--[[Number_Key_List]]) do
				Write_Newline()Indent(Indent_Level+1)
				Write'[';Key_Start_Index=#Output_List
--				Write(Number_Key)
				Reference(Number_Key,Indent_Level)
				Write']';Key_End_Index=Key_Start_Index+3
				local Value=Table[Number_Key]
				Write'='Reference(Value,Indent_Level+1,Table,Number_Key)Write(Comma)
			end
		else--general
			for Key,Value in (Table~=Key_Order_List_Set and #Key_Order_List_Set>0 and List_Pairs or Pairs)(Key_Order_List_Set,Table) do
				Type=Get_Type(Key)
				if Max_Index and Type=='number' and Key==Key//1 and Key>0 and Key<=Max_Index then else
					Write_Newline()Indent(Indent_Level+1)
					Key_Start_Index=#Output_List+1
					local Is_Key_Delay_Write
					if not (Type=='string' and (not Configure or (not Keywords[Key] and String_Find(Key,'^[%a_][%w_]*$')))
						and (Write(Key) or true)) then
						Write'['
						Need_Break_Sequent_Open_Bracket=true
						Is_Key_Delay_Write=Reference(Key,Indent_Level+1,Table)
						Write']'
					end
					Key_End_Index=#Output_List
					Write'='Reference(Value,Indent_Level+1,Table,Key,Is_Key_Delay_Write)Write(Comma)
				end
			end
		end
	end--Expand
	function Reference(Input,Indent_Level,Table,Key,Is_Key_Delay_Write)
		Type=Get_Type(Input)
		local ID_Enable=Configure and Type~='number'
		local ID=ID_Enable and Objects[Input]
		local Output_List_Index_To_Synchronize
		if ID then
			Write'_'
			if Objects[ID] then
				Write'['Write(ID)Write']'
				if Is_Key_Delay_Write then
					Delay_Write'=['Delay_Write(ID--[[Value]])Delay_Write']'Delay_Write(Delay_Write_Separator)
				end
				return
			elseif Objects[ID]==false--[[defining]]and Is_Delay_Assign then
				if Is_Normal and not Object_ID_Count[ID] then
					error'wont execute'
					Object_ID_Count[ID]='?'
				end
				local Table_ID
				if not Is_Key_Delay_Write then
					Table_ID=Objects[Table]
					Delay_Write'_['Delay_Write(Table_ID)Delay_Write']'
				end
				if Key~=nil then--value is nest reference
					--assert(Output_List[#Output_List]=='_')
					Output_List[#Output_List]=Is_Normal and ('nil--[['..ID..']]') or 'nil'
					if not Is_Key_Delay_Write then
						local Key_Type=Get_Type(Key)
						local Key_ID=Key_Type~='number' and Objects[Key]
						if Key_ID then
							Delay_Write'[_['Delay_Write(Key_ID)Delay_Write']]'
						elseif Is_Could_Define_Reference(Key,Key_Type) then
							Key_ID=Assign_ID(Key)
							Objects[Key_ID]=Key_ID
							Delay_Write'[_['Delay_Write(Key_ID)Delay_Write']]'
						elseif not Key_Start_Index--[[index key]] then
							Delay_Write'['Delay_Write(Key)Delay_Write']'
						else--key in pairs
							local content=Output_List[Key_Start_Index]
							if String_Sub(content,1,1)~='[' then
								assert(Key_End_Index==Key_Start_Index)
								Delay_Write'.'--Table.Key=Value
							end
							for Index=Key_Start_Index,Key_End_Index do
								content=Output_List[Index]
								Delay_Write(content)
							end
						end
					end
					Delay_Write'=_['Delay_Write(ID--[[Value]])Delay_Write']'Delay_Write(Delay_Write_Separator)
					return
				else--key is nest reference
					if Is_Normal then
						Write'--[['Write(ID)Write']]'--Key
					end
					Delay_Write'[_['Delay_Write(ID)Delay_Write']]'--Key_ID
					if Tables_Has_Delay_Key[Table]==nil then
						Tables_Has_Delay_Key[Table]=Table_ID
					end
					return 'Key_Is_Delay_Write_And_Value_May_Need_Reference_Then_Delay_Write'
				end
			else--defining
				Objects[ID]=not Is_Delay_Assign and ID or false
				Write'('Write(ID)Write','
				if Is_Key_Delay_Write then
					Delay_Write'=_['Delay_Write(ID--[[Value]])Delay_Write']'Delay_Write(Delay_Write_Separator)
				end
			end
		elseif Is_Key_Delay_Write--[[and value is not defined]] then
			local Value=Input
			if Is_Could_Define_Reference(Value) then
				local Value_ID=Assign_ID(Value)
				Objects[Value_ID]=false
				Write'_('Write(Value_ID)Write','
				Delay_Write'=_['Delay_Write(Value_ID)Delay_Write']'Delay_Write(Delay_Write_Separator)
			else
				Output_List_Index_To_Synchronize=#Output_List
			end
		end
		local Converted_Input=Input_Converter[Input]
		if Converted_Input then
			Write(Converted_Input)
		elseif Type=='string' then
			local Converted_String,Prefix,Postfix=String_Converter(Input)
			if Need_Break_Sequent_Open_Bracket then
				Need_Break_Sequent_Open_Bracket=false
				if Output_List[#Output_List]=='[' and String_Sub(Prefix or Converted_String,1,1)=='[' then
					Write' '--Break_Between_Key_And_String_Open_Bracket
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
				local Max_Index do
					local Length=#Input
					for Index=1,Length do
						local Value=Input[Index]
						if Value==nil then
							Max_Index=Index-1
							break
						end
					end
					if not Max_Index then
						Max_Index=Length
					end
				end
				Key_Start_Index,Key_End_Index=nil
				for Index,Value in IP(Input--[[Index_Key_List]]) do
					Write_Newline()Indent(Indent_Level+1)
					if Is_Normal and Math_Fmod(Index,5)==0 then
						LE='--'..Index
					end
					Reference(Value,Indent_Level+1,Input,Index)Write(Comma)
				end
				if Is_Normal then
					local Bool_Key_List,Number_Key_List,String_Key_List,Table_Key_Set do
						Bool_Key_List,Number_Key_List,String_Key_List,Table_Key_Set={},{},{},{}
						if Input[false]~=nil then
							Table_Insert(Bool_Key_List,false)
						end
						if Input[true]~=nil then
							Table_Insert(Bool_Key_List,true)
						end
						for Key,Value in Pairs(Input) do--simulate ipairs
							Type=Get_Type(Key)
							if Type=='number' then
								if not Max_Index or Key~=Key//1 or Key<1 or Key>Max_Index then
									Table_Insert(Number_Key_List,Key)
								end
							elseif Type=='string' then
								Table_Insert(String_Key_List,Key)
							elseif Type=='table' then
								Table_Key_Set[Key]=Value
							else assert(Type=='boolean','unhandle type '..Type)
							end
						end
					end
					Expand(Input,Indent_Level,Bool_Key_List)
					Table_Sort(Number_Key_List);Expand(Input,Indent_Level,Number_Key_List)
					Table_Sort(String_Key_List);Expand(Input,Indent_Level,String_Key_List)
					Expand(Input,Indent_Level,Table_Key_Set)
				else--Is_Compress
					Expand(Input,Indent_Level,Input,Max_Index)
					Table_Remove(Output_List)--remove last comma
				end
				Write_Newline()Indent(Indent_Level)Write'}'
			end
		else error("unhandle type: "..Type)
		end
		if Output_List_Index_To_Synchronize then
			for Index=Output_List_Index_To_Synchronize,#Output_List do
				local Content=Output_List[Index]
				Delay_Write(Content)
			end
			Delay_Write(Delay_Write_Separator)
		end
		local ID=ID or (ID_Enable and Objects[Input])
		--	`Input` may be referenced as `Table`, when exist nest reference (from child to parent)
		if ID then
			if Is_Normal then
				Write'--[['Write(Object_ID_Count[ID])Write']]'--Reference Count
			end
			Write')'
			Objects[ID]=ID
		end
		if not Is_Compress then
			local Table_ID=Tables_Has_Delay_Key[Table]
			if Table_ID then
				Delay_Write'_['Delay_Write(Table_ID)Delay_Write'][_]=nil'Delay_Write(Delay_Write_Separator)
				Tables_Has_Delay_Key[Table_ID]=false
			end
		end
	end--Reference
	Reference(Data,0)
	
	if Is_Compress then
		Output_List[2]=String_Replace(Output_List[2],'[\r\n]+\t*',' ')
		if next(Tables_Has_Delay_Key) then
			for Table,Table_ID in pairs(Tables_Has_Delay_Key) do
				Delay_Write'_['Delay_Write(Table_ID)Delay_Write'][_],'
			end
			Delay_Output_List[#Delay_Output_List]='][_]=nil'
			Delay_Write(Delay_Write_Separator)
		end
	end
	if #Delay_Output_List>0 then
		Write(Delay_Write_Separator)
		Delay_Write'return _[1]'
	elseif Is_Delay_Assign and Delay_Assign_Return_Index then
		Output_List[Delay_Assign_Return_Index]='return '
	end
	for Index,Content in ipairs(Delay_Output_List) do
		Table_Insert(Output_List,Content)
	end
	return Concat_Table(Output_List)
end--Data2String

return Data2String
