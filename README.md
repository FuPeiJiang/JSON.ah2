https://www.autohotkey.com/boards/viewtopic.php?f=83&t=103652
___

true<br>
`{a:1}`<br>
false<br>
`{a:0}`<br>
null<br>
`{a:-1}`

these are the only types that is `Object()`

JSON object is `Map()` with properties assigned<br>
so JSON properties are defined Twice
```autohotkey
obj_[key_]:=value_
obj_.DefineProp(key_, {Value: value_})
```

```autohotkey
MsgBox JSON_parse(FileRead("AutoHotkey_L releases.json"))[1]["assets"][1]["browser_download_url"]
MsgBox JSON_parse(FileRead("AutoHotkey_L releases.json"))[1].assets[1].browser_download_url
```
both work
