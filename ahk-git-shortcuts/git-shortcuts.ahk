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

1. discard all changes
2. stash current changes
3. apply stash
4. switch branch
)
ToolTipAtCenter(GUIDE)

Input, Selection, L1
Switch Selection
{
    case 1       : doGitReset()
    case 2       : doGitStashSave()
    case 3       : doGitStashListAndApply()
    case 4       : doGitShowBrancheAndCheckout()
    case Chr(27) : ExitWithToolTip("Cancel", 0)
    default      : ExitWithToolTip("Invalid option", -1)
}

Sleep 2000
ExitApp, 0



; -------------------
; Functions
; -------------------


RemoveToolTip:
    Tooltip
    return

doGitReset()
{
    Tooltip
    ExecScriptTakeCout("git reset --hard", GIT_REPO)
    if ErrorLevel = 0
        ToolTipAtCenter("Done")
}

doGitStashSave()
{
    Tooltip
    ExecScriptTakeCout("git stash --include-untracked", GIT_REPO)
    if ErrorLevel = 0
        ToolTipAtCenter("Done")
}

getGitStashs()
{
    queried := ExecScriptTakeCout("git stash list", GIT_REPO)
    list:=""
    number:=1
    for index, el in StrSplit(queried, "`n")
    {
        if number > 9
            break
        if StrLen(el) = 0
            continue

        list := % list "`n" number ": " RegExReplace(el, "stash@\{([0-9])+\}: ([^:]+): (?:[a-z0-9]+ )?(.*)", "$3")
        number++
    }
    return list
}

doGitStashListAndApply()
{
    Tooltip
    list := getGitStashs()
    SetTimer, RemoveToolTip, Off
    ToolTipAtCenter(list)
    Input, Selection, L1
    if Selection = Chr(27)
    {
        ToolTipAtCenter("Cancel")
        return
    }
    Tooltip

    stashStr := StrSplit(list, "`n")[Selection + 1]
    StringLeft, stashNo, stashStr, 1
    stashNo--
    cout := ExecScriptTakeCout("git stash apply " stashNo, GIT_REPO)
    if ErrorLevel != 0
    {
        msg:= % "Failed, `n" cout
        ToolTipAtCenter(msg, 5000)
        Sleep 5000
        return
    }
    ToolTipAtCenter("Done")
}

getGitBranches()
{
    queried := ExecScriptTakeCout("git branch --sort=-committerdate", GIT_REPO)
    current := ExecScriptTakeCout("git rev-parse --abbrev-ref HEAD", GIT_REPO)

    list := % "0: * " Trim(current, "`n")
    number := 1
    for index, el in StrSplit(queried, "`n")
    {
        if number > 9
            break
        if StrLen(el) = 0
            continue
        if InStr(Trim(el, "`n"), Trim(current,"`n")) > 0
            continue
        list = % list "`n" number ": " el
        number++
    }
    return list
}

doGitShowBrancheAndCheckout()
{
    Tooltip
    list := getGitBranches()
    SetTimer, RemoveToolTip, Off
    ToolTipAtCenter(list)
    Input, Selection, L1
    if (Selection = Chr(27))
    {
        ToolTipAtCenter("Cancel")
        return
    }
    Tooltip

    branch := SubStr(StrSplit(list, "`n")[Selection + 1], 6)
    cout := ExecScriptTakeCout("git checkout " branch, GIT_REPO)
    if ErrorLevel != 0
    {
        msg:= % "Failed, `n" cout
        ToolTipAtCenter(msg, 5000)
        Sleep 5000
        return
    }
    ToolTipAtCenter("Done")
}

ExitWithToolTip(message, exitCode)
{
    ToolTipAtCenter(message, 1000)
    Sleep 1000
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
    exec := shell.Exec(A_ComSpec " /C " Script " 2>&1")
    ToolTipAtCenter(Script, 1000)
    Sleep 200
	cout := exec.StdOut.ReadAll()
    ErrorLevel := exec.exitCode
	return cout
}

ToolTipAtCenter(msg, presentTime = 0)
{
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