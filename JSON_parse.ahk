#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#SingleInstance force
ListLines Off
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
SetBatchLines -1
#KeyHistory 0

; #Include <Array>

JSON_parse(str) {

    c_:=1
    objectStack:=[]
    doWhatStack:=["ret"]

    iterate:
    loop {

        doWhat:=doWhatStack[doWhatStack.Length()]

        breakSwitch:
        loop 1 {
            Switch doWhat {
                case "notElement":
                    doWhatStack.Pop()
                    RegExMatch(str, "\s*", OutputVar, c_), c_+=StrLen(OutputVar) ;skip_s()
                    if (SubStr(str, c_, 1) == "]") {
                        c_++
                        current:=objectStack.Pop()
                        break breakSwitch
                    }

                    doWhatStack.Push("element")
                    continue iterate
                case "key":
                    doWhatStack.Pop()
                    RegExMatch(str, "\s*", OutputVar, c_), c_+=StrLen(OutputVar) ;skip_s()
                    if (SubStr(str, c_, 1) == "}") {
                        c_++
                        current:=objectStack.Pop()
                        break breakSwitch
                    }

                    ; key_:=JSON_objKey()
                    ; a or "a"
                    if (SubStr(str, c_, 1) == """") {
                        RegExMatch(str, "(?:\\.|.)*?(?="")", OutputVar, c_ + 1)
                        objectStack.Push(RegExReplace(OutputVar, "\\(.)", "$1"))
                        c_+=StrLen(OutputVar)
                    } else {
                        RegExMatch(str, ".*?(?=[\s:])", OutputVar, c_)
                        objectStack.Push(OutputVar)
                        c_+=StrLen(OutputVar)
                    }

                    c_:=InStr(str, ":", true, c_) + 1
                    RegExMatch(str, "\s*", OutputVar, c_), c_+=StrLen(OutputVar) ;skip_s()

                    doWhatStack.Push("value")
                    continue iterate

                Default:
                    char_:=SubStr(str, c_, 1)
                    Switch char_ {
                        case "{":
                            objectStack.Push({})
                            ;object
                            c_++

                            doWhatStack.Push("key")
                            continue iterate

                        case "[":
                            objectStack.Push([])
                            ;array
                            c_++
                            doWhatStack.Push("notElement")
                            continue iterate

                        case """":
                            RegExMatch(str, "(?:\\.|.)*?(?="")", OutputVar, c_ + 1)
                            unquoted:=RegExReplace(OutputVar, "\\(.)", "$1")
                            c_+=StrLen(OutputVar) + 2
                            current:=unquoted
                        case "0", "1", "2", "3", "4", "5", "6", "7", "8", "9":
                              ; -100
                            ; 100.0
                            ; 1.0E+2
                            ; 1E-2
                            RegExMatch(str, "[0-9.eE\-+]*", OutputVar, c_)
                            c_+=StrLen(OutputVar)
                            current:=OutputVar + 0 ;string to number
                        case "t":
                            ;"true"
                            c_+=4
                            current:=1 ;there is no `true` in autohotkey, it's an alias
                        case "f":
                            ;"false"
                            c_+=5
                            current:=0 ;there is no `false` in autohotkey, it's an alias
                        case "n":
                            ;"null"
                            c_+=4
                            current:=0 ;there is certainly no `null` in autohotkey


                }
            }
        }

        doWhat:=doWhatStack[doWhatStack.Length()]
        Switch doWhat {
            case "ret":
                return current
            case "value":
                doWhatStack.Pop()
                key_:=objectStack.Pop()
                objectStack[objectStack.Length()][key_] := current

                RegExMatch(str, "\s*", OutputVar, c_), c_+=StrLen(OutputVar) ;skip_s()
                if (SubStr(str, c_, 1) == ",") {
                    c_++, RegExMatch(str, "\s*", OutputVar, c_), c_+=StrLen(OutputVar) ;skip_s()
                }

                doWhatStack.Push("key")
                continue iterate
            case "element":
                doWhatStack.Pop()
                objectStack[objectStack.Length()].Push(current)

                RegExMatch(str, "\s*", OutputVar, c_), c_+=StrLen(OutputVar) ;skip_s()
                char_:=SubStr(str, c_, 1)
                if (char_ == ",") {
                    c_++, RegExMatch(str, "\s*", OutputVar, c_), c_+=StrLen(OutputVar) ;skip_s()
                }

                doWhatStack.Push("notElement")
                continue iterate
        }

    }

}

; d(JSON_parse("""b"""))
; d(JSON_parse("{`na:""b""}"))
; d(JSON_parse("{`n""a"":""b""}"))
; d(JSON_parse("{`na:""b"",""c"":""\""}d""}"))
; d(JSON_parse("[{`na:""b"",""c"":""\""}d""}, {`na: true,""c"": null},{a:0,b:1,c:314}]"))
; d(JSON_parse(FileRead("AutoHotkey_L releases.json"))[1].assets[1].browser_download_url)
MsgBox % JSON_parse(FileRead("AutoHotkey_L releases.json"))[1]["assets"][1]["browser_download_url"]
MsgBox % JSON_parse(FileRead("AutoHotkey_L releases.json"))[1].assets[1].browser_download_url

return

FileRead(fileName) {
    FileRead, OutputVar, % fileName
    return OutputVar
}

f3::Exitapp