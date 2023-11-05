# SUER-DART

## Examples

```powershell
欢迎使用 SUER-DART ，使用 Dart 语言编写的 SUER-Injector ！
-f, --files          指定一个或多个文件的路径
-s, --[no-]silent    是否开启安静模式
```

```powershell
./main.exe -f "C:\Users\huang\Documents\blog\.eslintignore" -f "C:\Users\huang\Documents\dart\src\pubspec.yaml"             
(SUER-DART 已启动)
2个文件已被指定：
  1: C:\Users\huang\Documents\blog\.eslintignore
  2: C:\Users\huang\Documents\dart\news\src\pubspec.yaml
  按下'n'以继续
```

```powershell
./main.exe -f "C:\Users\huang\Documents\blog\.eslintignore" -f "C:\Users\huang\Documents\dart\news\src\pubspec.yam!" # <-- ('yaml' -> 'yam!')
(SUER-DART 已启动)
1个文件无法访问：
  1: C:\Users\huang\Documents\dart\news\src\pubspec.yam!
1个文件已被指定：
  1: C:\Users\huang\Documents\blog\.eslintignore
  按下'n'以继续
```

```powershell
正在处理：
  C:\Users\huang\Documents\blog\.eslintignore
  1/2  [##########          ]
  按下'e'以正确退出本程序
  按下'n'以处理下一个文件
```
