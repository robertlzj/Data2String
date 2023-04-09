One for all, all for one.
May Lua world become better and better.

---

# Summary
Serialize noraml data in any struct to string.
- "Serialize": convert / store data ..
- "normal data": support 'number', 'bool', 'string', 'table' type.
- "in any struct": support table with nest, self-reference, circle-reference (circular-reference).
- "to string": the output is a normal lua code (string) which could be `load` to unserialize / restore to the data.

# Feature
- Support "**any struct**", described above.
- Should be very **fast** to `load`.
- Support pretty & human **readable** output.
  - Indent, organized in struct level.
    Then easy to fold / unfold (expand / collapse) by editor.
  - Index count.
  - String in format without escape, that is, what you get is what you see (display by `print`).
- Support output **configure**, see bellow.
- Short, write in pure Lua, support 5.3 (easy to migrate to all Lua version)

# Configure
All have default value.
- `true`: default, output chunk string which could be `load`.
- `false`: read only (can't `load`).
  Currently will fail if there is any self-reference.

`Configure` could be a table with fields:
- `String_Converter` (`SC`): user / custom string converter (wrapper).
- `Reference_String_If_Longer_Than_Length` (`RS`): number or `false`. If `false` won't reference / re-use any string.
- `Configure` (`C`): `nil` or `false`. If `false`, "read only" (see above).
- `Pairs` (`P`): user / custom `pairs` for iter key value from table.

# Demo
- basic (without reference) pretty output
  ```lua
  local t={
		'a',
		2,
		false,
		true,
		{'5'},--5
		nil,
		'b',
		D={'d',E={'e',[true]=false,}}
	}
	assert(Data2String(t)==[[--Generated using Data2String2.lua by RobertL
  return {
  	"a",
  	2,
  	false,
  	true,
  	{--5
  		"5",
  	},
  	[7]="b",
  	D={
  		"d",
  		E={
  			"e",
  			[true]=false,
  		},
  	},
  }]])
  ```
- string (key) display
  ```lua
	local t={
		'string',
		key={
			"C:\\",
			['string.']="%\t'[[\t]=]",
		}
	}
	print(Data2String(t))
	assert(Data2String(t)==[===[--Generated using Data2String2.lua by RobertL
  return {
  	"string",
  	key={
  		[[C:\]],
  		["string."]=[==[%	'[[	]=]]==],
  	},
  }]===])
  ``` 
- self-reference
  ```lua
  local t={}
	t[t]=t
	t.T=t
	local t2=load(Data2String(t))()
	assert(t2[t2]==t2 and t2.T==t2)
  ```
  circle-reference
  ```lua
  local t1={}
  local t2={}
  t1.T1=t2
  t2.T2=t1
  local t3=load(Data2String(t1))()
  assert(t3.T1.T2==t3)
  ```

# Miscellaneous
The document is not complete.   
The code has been write for years, comments is poor, I'm not sure every line.  
Feel free to comment.

Next, could add external data, so function, metatable could be supported.
