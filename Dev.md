## 改动

- 分离得`Expand`、`List_Pairs`
- 细分`Is_Normal`分支。
- 细分`Bool_Key_List,Number_Key_List,String_Key_List,Table_Key_Set`处理。

## 性能

有提升。

![image-20230428084232309](Dev.assets/image-20230428084232309.png)

![image-20230428084243293](Dev.assets/image-20230428084243293.png)

## 负面影响

compress时，未细分/无索引部分（全/仅键值对）。

有待考察性能影响。