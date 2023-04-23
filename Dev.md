- 定义：`_(ID,Table)`
- 引用：`_[ID]`

---

1. 若引用了未完成的定义，则推迟引用。
2. 存在引用则存在定义。
3. 加载是按代码顺序——从上到下，从左到右（从键到值）。
4. 引用所作为的键/值所在的对象可能无定义。
5. 为以上（#4）提及的对象补充定义。
6. 嵌套引用可能发生于键或值。
   若为值，可以保留键转换为定义，赋值`nil`，避免回退`Output_List`。
7. 经测试，合并`Output_List`与`Delay_Output_List`或者不合并，而是`..`连接其结果，几乎不影响速度。

## Performance

RobertWork:

```
serializer serpent (50000): 8.8510s
serializer penlight (50000): 3.1070s
serializer D2S (50000): 5.7340s
serializer D2S_compress (50000): 4.8790s
serializer D2S_lazy (50000): 6.4340s
serializer D2S_lazy_compress (50000): 5.3630s
deserializer serpent (50000): 0.6650s
deserializer D2S (50000): 1.4990s
deserializer D2S_compress (50000): 1.4870s
deserializer D2S_lazy (50000): 1.4740s
deserializer D2S_lazy_compress (50000): 0.8840s
```

