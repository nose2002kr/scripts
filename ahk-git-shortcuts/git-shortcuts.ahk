#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

DllCall("AllocConsole")
WinHide % "ahk_id " DllCall("GetConsoleWindow", "ptr")

global GIT_REPO

IniRead, GIT_REPO, git-util.ini, Target, Path
if (GIT_REPO == "ERROR")
{
    GIT_REPO := LookUpGitRepo()
    IniWrite, %GIT_REPO%, git-util.ini, Target, Path
}
IfNotExist %GIT_REPO%
    MsgBox, Unknown Dir

GUIDE = 
(
What would you do?
target: %GIT_REPO%

)

Loop
{
    SectionName := "Command " . A_Index

    IniRead, descVal, git-util.ini, %SectionName%, Desc
    If (descVal == "ERROR") {
        Break
    }
    
    GUIDE := GUIDE . "`n " . A_Index . "." . descVal
}

ToolTipAtCenter(GUIDE)

; Wating for the Input
Input, Selection, L1

; Take Command from the Selection
Command := TakeCommand(Selection)

; you can get `ListSelection.number` and `ListSelection.value`, If it exists.
ListSelection := TakeChooseIfHasListingAction(Selection)

; Combine and complete for the single command line to be completed.
Command := CompleteCommand(Command, ListSelection)

; Finally
DoGitAction(Command) ;ToolTipAtCenter(Command)

Sleep 2000
ExitApp, 0





; -------------------
; Functions
; -------------------


RemoveToolTip:
    Tooltip
    return

TakeCommand(Selection) 
{
    ; Check if the selection is valid
    If (Selection == Chr(27))
    {
        ExitWithToolTip("Cancel", 0)
    }

    SectionName := "Command " . Selection

    IniRead, Command, git-util.ini, %SectionName%, Cmd
    ; If The Command doesn't exists by the Selection, then exit.
    If (Command == "ERROR") {
        ExitWithToolTip("Invalid option", -1)
    }

    return Command
}

TakeChooseIfHasListingAction(Selection)
{
    ; Check if the selection is valid
    If (Selection == Chr(27))
    {
        ExitWithToolTip("Cancel", 0)
    }

    SectionName := "Command " . Selection

    IniRead, Command, git-util.ini, %SectionName%, List
    ; If The Listing command doesn't exists, just return with empty value.
    If (Command == "ERROR") {
        return ""
    }
    
    IniRead, StartingFromZero, git-util.ini, %SectionName%, StartingFromZero

    queried := ExecScriptTakeCout(Command, GIT_REPO)
    if ErrorLevel != 0
    {
        msg:= % "Failed, `n" queried
        ExitWithToolTip(msg, ErrorLevel, 5000)
    }

    StartingAt := (StartingFromZero == "True") ? 0 : 1
    ToolTipAtCenter(MakeAsChooser(queried, StartingAt))
    
    ; Wating for the Input
    Input, Selection, L1
    If (Selection == Chr(27))
    {
        ExitWithToolTip("Cancel", 0)
    }

    queried := StrSplit(queried, "`n")

    Selection := Selection + (1 - StartingAt)
    If (Selection < StartingAt || queried.MaxIndex() <= Selection)
    {
        ExitWithToolTip("Invalid input, input is exceed", -1)
    }
    
    return { number: Selection, value: queried[Selection] }

}

MakeAsChooser(QueriedString, StartingAt)
{
    number := StartingAt
    for index, el in StrSplit(QueriedString, "`n")
    {
        if number > 9
            break
        if StrLen(el) = 0
            continue
        list = % list "`n" number ": " el
        number++
    }
    return list
}

CompleteCommand(Command, ListSelection)
{
    If not ListSelection {
        return Command
    }

    FoundPos := RegExMatch(Command, "O)\{VALUE(\[((-)?[0-9\-]*):((-)?[0-9]*)\])?\}", Rgx)
    If FoundPos >= 1 
    {
        length := StrLen(ListSelection.value)
        startPos := MakeAbsolutePositions(length, Rgx.Value(2))
        If (startPos < 1)
        {
            startPos := 1
        }
        endPos   := MakeAbsolutePositions(length, Rgx.Value(4))
        If (endPos > length || endPos == -1)
        {
            endPos := length + 1
        }
        ;MsgBox % Rgx.Value(2) . ":" . Rgx.Value(4)

        
        length := endPos - startPos
        CroppedValue := SubStr(ListSelection.value, startPos, length)

        StringReplace, Command, Command, % Rgx.Value(0), %CroppedValue%

        ;ToolTipAtCenter(value . ", " . startPos . ", " . length . ": " . value2, 5000)
        ;Sleep 5000
        ;MsgBox % ListSelection.value . ", " . startPos . ", " . length . "(" . endPos . ")(" . Rgx.Value(0) . "): " . CroppedValue 
    }

    StringReplace, Command, Command, {NUMBER}, % ListSelection.number

    return Command
}

MakeAbsolutePositions(length, position)
{
	If (position == "")
	{
		return -1
	}
	Else If position < 0
	{
		return length + position + 1
	}
	Else
	{
		return position + 1
	}
}

DoGitAction(Command)
{
    Tooltip
    cout := ExecScriptTakeCout(Command, GIT_REPO)
    if ErrorLevel = 0
        ToolTipAtCenter("Done")
    Else if ErrorLevel != 0
    {
        msg:= % "Failed, `n" cout
        ExitWithToolTip(msg, ErrorLevel, 5000)
    }
}

ExitWithToolTip(message, exitCode, presentTime = 1000)
{
    ToolTipAtCenter(message, presentTime)
    Sleep % presentTime
    ExitApp %exitCode%
    return
}

LookUpGitRepo()
{
    return "C:\_work\repos\sot\epage"
}

ExecScriptTakeCout(Script, WorkDir="")
{
    FileDelete C:\temp\build.log
    shell := ComObjCreate("WScript.Shell")
	if WorkDir
    	shell.CurrentDirectory := WorkDir
    exec := shell.Exec(A_ComSpec " /C bash -c '" Script "' 2>&1")
    ToolTipAtCenter(Script, 1000)
    Sleep 200
	cout := exec.StdOut.ReadAll()
    ErrorLevel := exec.exitCode
	return cout
}

ToolTipAtCenter(msg, presentTime = 0)
{
    Tooltip
    SetTimer, RemoveToolTip, Off

    lines := StrSplit(msg, "`n")
	row := lines.Length()
	column := 0
	for i, e in lines
	{
		column := Max(column, StrLen(e))
	}
	;MsgBox % row "," column
    ToolTip %msg%, A_ScreenWidth/2 - (column*3), A_ScreenHeight/2 - (row*5)
    if presentTime > 0
	{
		presentTime := presentTime * -1
        SetTimer, RemoveToolTip, %presentTime%
	}
}