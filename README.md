One for all, all for one.
May Lua world become better and better.

---

## Summary
Serialize noraml data in any struct to string.
- "Serialize": convert / store data ..
- "normal data": support 'nil', 'NaN', 'number' (`math.huge`), 'bool', 'string', 'table', 'funtion' type.
- "in any struct": support table with nest, self-reference, circle-reference (circular-reference).
- "to string": the output is a normal lua code (string) which could be `load` to unserialize / restore to the data.

## Feature
- Support "**any struct**", described above.
- **Very fast**, see [Performance](#Performance) bellow.
  Should be fast to `load` too.
- Support **pretty print** & human **readable** output.
  - Indent, organized in struct level.
    Then easy to fold / unfold (expand / collapse) by editor.
  - Index count.
  - Reference count.
    After source at defination.
  - String in format without escape, that is, what you get is what you see as display by `print`.
  - Numerical keys are listed first.
  - Array part skips keys (`{'a', 'b'}` instead of `{[1] = 'a', [2] = 'b'}`).
  - Keys use short notation (`{foo = 'foo'}` instead of `{['foo'] = 'foo'}`).
- Support output **configure**, see bellow.
- Short, write in pure Lua, easy to read, support 5.1, 5.3.

## Configure
All have default value.
- `nil`: default, readable, `load`-able.
- `'fast'`: will compose (un-readable), `load`-able.
- `false`: read only (can't `load`).
  Limitation: currently will fail if there is any self-reference.

`Configure` could be a table with fields:
- `String_Converter` (`SC`): user / custom string converter (wrapper).
- `Reference_String_If_Longer_Than_Length` (`RS`): number or `false`. If `false` won't reference / re-use any string.
- `Configure` (`C`): `nil` or `false`. If `false`, "read only" (see above).
- `Pairs` (`P`): user / custom `pairs` for iter key value from table.

## Performance
| serializer   | time cost (sec) |
| :----------- | :-------------- |
| serpent      | 0.4070          |
| penlight     | 0.3010          |
| D2S          | 0.2350          |
| D2S_compress | 0.1840          |

| deserializer | time cost (sec) |
| :----------- | :-------------- |
| serpent      | 0.0380          |
| D2S          | 0.0730          |
| D2S_compress | 0.0730          |

'penlight' can't restore (`load`) correctly.

Test under windows CMD, test case borrowed from [pkulchenko](https://github.com/pkulchenko)/[serpent](https://github.com/pkulchenko/serpent), iters for 1000.

## Demo
- basic (without reference) pretty output
  ```lua
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
	assert(Data2String(t)==[[--Generated using Data2String2.lua by RobertL
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
  }]])
  ```
- compressed:
  ```lua
  assert(Data2String(t,'compress')==[[--Generated using Data2String2.lua by RobertL
  return {[1]="a",[2]=2,[3]=false,[4]=true,[5]={[1]=0/0,[2]=1/0,[3]=math.maxinteger,[4]=math.mininteger},[7]="b",D={E={[1]="e",[true]=false}}}]])
  ```
- string display
  ```lua
	local t={
		'string',
		key={
			"C:\\",
			['function']="%\t'[[\t]=]",
		}
	}
	print(Data2String(t))
	assert(Data2String(t)==[===[--Generated using Data2String2.lua by RobertL
  return {
  	"string",
  	key={
  		[[C:\]],
  		["function"]=[==[%	'[[	]=]]==],
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

## Limitations/TODO
- doesn't support metatable, could be done.
- doesn't support external data, could be done.
- Lua 5.2 test didn't all pass, not sure why.


## Miscellaneous
The document is not complete. 
The code has been write for years, comments is poor, I'm not sure every line.
Feel free to comment.

Get improved from [pkulchenko/serpent: Lua serializer and pretty printer. (github.com)](https://github.com/pkulchenko/serpent).