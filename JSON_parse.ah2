#SingleInstance force
ListLines 0
KeyHistory 0
SendMode "Input" ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir A_ScriptDir ; Ensures a consistent starting directory.

; #Include <Array>

JSON_parse(str) {

    c_:=1

    return JSON_value()

    JSON_value() {

        char_:=SubStr(str, c_, 1)
        Switch char_ {
            case "{":
                obj_:=Map()
                ;object
                c_++
                loop {
                    skip_s()
                    if (SubStr(str, c_, 1) == "}") {
                        c_++
                        return obj_
                    }

                    ; key_:=JSON_objKey()
                    ; a or "a"
                    if (SubStr(str, c_, 1) == "`"") {
                        RegExMatch(str, "(?:\\.|.)*?(?=`")", &OutputVar, c_ + 1)
                        key_:=RegExReplace(OutputVar.0, "\\(.)", "$1")
                        c_+=OutputVar.Len
                    } else {
                        RegExMatch(str, ".*?(?=[\s:])", &OutputVar, c_)
                        key_:=OutputVar.0
                        c_+=OutputVar.Len
                    }

                    c_:=InStr(str, ":", true, c_) + 1
                    skip_s()

                    value_:=JSON_value()
                    obj_[key_]:=value_
                    obj_.DefineProp(key_, {Value: value_})

                    skip_s()
                    if (SubStr(str, c_, 1) == ",") {
                        c_++, skip_s()
                    }
                }
            case "[":
                arr_:=[]
                ;array
                c_++
                loop {
                    skip_s()
                    if (SubStr(str, c_, 1) == "]") {
                        c_++
                        return arr_
                    }

                    value_:=JSON_value()
                    arr_.Push(value_)

                    skip_s()
                    char_:=SubStr(str, c_, 1)
                    if (char_ == ",") {
                        c_++, skip_s()
                    }
                }
            case "`"":
                RegExMatch(str, "(?:\\.|.)*?(?=`")", &OutputVar, c_ + 1)
                unquoted:=RegExReplace(OutputVar.0, "\\(.)", "$1")
                c_+=OutputVar.Len + 2
                return unquoted
            case "0", "1", "2", "3", "4", "5", "6", "7", "8", "9":
                ; -100
                ; 100.0
                ; 1.0E+2
                ; 1E-2
                RegExMatch(str, "[0-9.eE\-+]*", &OutputVar, c_)
                c_+=OutputVar.Len
                return Number(OutputVar.0)
            case "t":
                ;"true"
                c_+=4
                return {a:1}
            case "f":
                ;"false"
                c_+=5
                return {a:0}
            case "n":
                ;"null"
                c_+=4
                return {a:-1}


        }
    }

    skip_s() {
        RegExMatch(str, "\s*", &OutputVar, c_)
        c_+=OutputVar.Len
    }
}

; d JSON_parse("{`na:`"b`"}")
; d JSON_parse("{`n`"a`":`"b`"}")
; d JSON_parse("{`na:`"b`",`"c`":`"\`"}d`"}")
; d JSON_parse("[{`na:`"b`",`"c`":`"\`"}d`"}, {`na: true,`"c`": null},{a:0,b:1,c:314}]")
; d JSON_parse(FileRead("AutoHotkey_L releases.json"))[1].assets[1].browser_download_url
MsgBox JSON_parse(FileRead("AutoHotkey_L releases.json"))[1]["assets"][1]["browser_download_url"]
MsgBox JSON_parse(FileRead("AutoHotkey_L releases.json"))[1].assets[1].browser_download_url

return

f3::Exitapp