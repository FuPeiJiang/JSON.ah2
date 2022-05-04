#SingleInstance force
ListLines 0
KeyHistory 0
SendMode "Input" ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir A_ScriptDir ; Ensures a consistent starting directory.

#Include <Array>

JSON_parse(str) {

    c_:=1

    return JSON_value()

    JSON_value() {
        obj_:=Map()

        Switch SubStr(str, c_, 1) {
            case "{":
                ;object
                c_++
                loop {
                    skip_s()
                    if (SubStr(str, c_, 1) == "}") {
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

                    skip_s()
                    if (SubStr(str, c_, 1) == ",") {
                        c_++, skip_s()
                    }
                }
            case "`"":
                RegExMatch(str, "(?:\\.|.)*?(?=`")", &OutputVar, c_ + 1)
                unquoted:=RegExReplace(OutputVar.0, "\\(.)", "$1")
                c_+=OutputVar.Len + 2
                return unquoted


        }
    }

    skip_s() {
        RegExMatch(str, "\s*", &OutputVar, c_)
        c_+=OutputVar.Len
    }
}

; d JSON_parse("{`na:`"b`"}")
; d JSON_parse("{`n`"a`":`"b`"}")
d JSON_parse("{`na:`"b`",`"c`":`"\`"}d`"}")

return

f3::Exitapp