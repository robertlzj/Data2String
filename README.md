## Summary
Serialize data Fast in any struct to string. Clear view through complex reference.
- "serialize": a serializer support convert / store ..
- "data": include 'nil', 'NaN', 'number' (also number from `math`), 'bool', 'string', 'table', 'funtion' type.
- "external": support refer/link external data - 'table', 'function', 'userdata'.
- "in any struct": support table with nest, self-reference, circle-reference (circular-reference).
- "to string": the output is a normal lua code (string) which could be `load` to deserialize / restore to the data.
- "clear view": keep the original structure, easy to navigate between references. Expanded bellow.

## Feature
- Support "**any struct**", described above.
- **Very fast**, see [Performance](#Performance) bellow.
- Easy to deserialize / restore / load.
- Support **pretty print** & human **readable** output.
  - Indent, comments, organized in struct level.  
    Easy to fold / unfold (expand / collapse) by editor.  
    Less and minimal jump on references in 'normal' mode.
  - Could reuse long string (like other reference object).
    ```lua
    --data:
    {
    	'string','string',
    	'long string','long string',
    }
    --will get string:
    {
    	"string",
    	"string",
    	_(1,"long string"--[[2]]),
    	_[1],
    }
    ```
    The threshold value could be specified in [Configure](#Configure).
  - Count for long index.
  - Count for reference.  
    `--[[2]]` above means there are "2" reference of id "1".
  - Output struct maintain the same with input data.  
    All reference are in right place directly, even when nest.
  - String in format without escape, that is, what you get is what you see as display by `print`.  
    When escape character exist, will use `[[C:\]]` instead of `"C:\\"`. So, you can copy-paste then search in output.
  - Numerical and alphabet keys are sorted in 'normal' (not 'compress') model (`{key=value, item1, item2}`).
  - Keep array format instead of index-value pairs (`{'data',2,'string'}`).
  - Use short keys if possible (`{key = 'value', ['do'] = 'end'}`).
- Support refer/link to **external data**, which won't be serialized internally to the file.
  These data could easily be declared by configure, then they should be stored and restored from outside.
- Support output **configure**, see bellow.
- Short, write in pure Lua, easy to read, support 5.1, 5.3.
- Workaround registers max count limitation used in function or expression when load.   
  See [Limitations/TODO](#Limitations/TODO).

## Configure
### Mode

- `nil`: normal/default, most readable, content sorted, load-able.  
  Could combine with ‘compress' bellow.
- `'lazy'`: readable, load-able, faster to deserialize.  
  Could combine with ‘compress' bellow.
- `false`: read only (can't load).
  Support output 'userdata', 'thread' string using `tostring`.
  Limitation: currently will fail if there is any self-reference.

---

- `'compress'`: will compose (un-readable), load-able, fastest on serialize and deserialize.

| mode          | readable | serialize speed | deserialize speed |
| ------------- | -------- | --------------- | ----------------- |
| default       | 5/5      | 4/5             | 2/5               |
| compress      | 0/5      | 5/5             | 3/5               |
| lazy          | 3/5      | 3/5             | 4/5               |
| lazy compress | 0/5      | 4/5             | 5/5               |

Check [Performance](#Performance).

---

`Configure` could be a table with more fields:

- `Lazy`, `Compress`: set [mode](#mode) if true.
- `String_Converter` (`SC`): user / custom string converter (wrapper).
- `Reference_String_If_Longer_Than_Length` (`RS`): number or `false`. If `false` won't reference / re-use any string.
- `Configure` (`C`): `nil` or `false`. If `false`, "read only" (see above).
- `Pairs` (`P`): user / custom `pairs` for iter key value from table.

## Performance
| serializer                                       | time cost (sec) |
| :----------------------------------------------- | :-------------- |
| [serpent](https://github.com/pkulchenko/serpent) | 8.02            |
| D2S                                              | 5.54            |
| D2S_compress                                     | 4.11            |
| D2S_lazy                                         | 6.20            |
| D2S_lazy_compress                                | 4.49            |

| deserializer      | time cost (sec) |
| :---------------- | :-------------- |
| serpent           | 0.64            |
| D2S               | 1.42            |
| D2S_compress      | 1.29            |
| D2S_lazy          | 0.88            |
| D2S_lazy_compress | 0.84            |

Test under windows CMD, lua53, process with high priority. Test case borrowed from [pkulchenko](https://github.com/pkulchenko)/[serpent](https://github.com/pkulchenko/serpent), iters for 20000.  
Also test: 

- [Penlight](https://github.com/lunarmodules/Penlight) can't handle self-reference.
- [NotDSF/leopard](https://github.com/NotDSF/leopard), slow.

## Install

- copy file '[Data2String.lua](https://github.com/robertlzj/Data2String/blob/main/Data2String.lua)' to lua libs.
- `luarocks install data2string`.

## Demo

see 'Test.lua'

- basic (without reference) pretty output
  ```lua
  t={
		'a',2,false,true,
		{--5
  		0/0,--NaN
			1/0,--math.huge
			math.maxinteger,math.mininteger,
		},
		nil,'b',
		D={E={'e',[true]=false,}}
	}
	assert(Data2String(t)==[[--Generated using Data2String2.lua by RobertL
  return {
  	[7]="b",
  	D={
  		E={
  			"e",
  			[true]=false,
  		},
  	},
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
  }]])
  ```
- compressed:
  ```lua
  assert(Data2String(t,'compress')==[[--Generated using Data2String2.lua by RobertL
  return {[7]="b",D={E={"e",[true]=false}},"a",2,false,true,{0/0,1/0,math.maxinteger,math.mininteger}}]])
  ```
- string display
  ```lua
	t={
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
  t={}
	t[t]=t
	t.T=t
	Output=D2S(t)
	--print(Output)
  t2=assert(load(Output),Output)()
  assert(t2[t2]==t2 and t2.T==t2)
  ```
  circle-reference
  ```lua
  t1={}
  t2={}
  t1.T1=t2
  t2.T2=t1
  t1[t1]='T1'
  Output=D2S(t1)
  --print(Output)
  t3=assert(load(Output),Output)()
  assert(t3.T1.T2==t3 and t3[t3]=='T1')
  ```
- external refer
  ```lua
  e={}
  function f()end
  t={[e]=e,F=f}
  Output=D2S(t,{e,f})
  --print(Output)
  R=assert(load(Output),Output)(){e,f}
  assert(R[e]==e and R.F==f)
  ```

## Limitations/TODO
- doesn't support metatable, could be done.
- [x] doesn't support external data import, could be done.
- Lua 5.2 test didn't all pass, not sure why.

### Done

- interpreter compile error when `load`, if too many table member in nest table.

  - "function or expression needs too many registers near '..'", in lua5.34
    there are 248 registers in stack.

  - "function or expression too complex near '...'", in lua5.14

  see [Everything You Didn’t Want to Know About Lua’s Multi-Values - Benaiah Mischenko](https://benaiah.me/posts/everything-you-didnt-want-to-know-about-lua-multivals/).


## Miscellaneous
The code has been write for years, document is not complete.
Feel free to comment.

Get improved from [pkulchenko/serpent: Lua serializer and pretty printer. (github.com)](https://github.com/pkulchenko/serpent).
