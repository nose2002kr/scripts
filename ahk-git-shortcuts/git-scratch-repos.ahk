#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

#include JSON.ahk

repoList := []

currentDir := GetActiveExplorerPath()
if IsGitRepo(currentDir)
    repoList.Push(currentDir)

FileRead, b, % TakeForkSettingsPath()
json := Json.Load(b)
repositories := json.RepositoryManager.Repositories
len := repositories.Length()
Loop, %len%
{
    repo := ObjRawGet(repositories, A_Index).Path
    if (currentDir = repo)
        continue
    
    repoList.Push(repo)
    if repoList.Length() >= 9
        break
}

len := repoList.Length()
msg := "choice repo work on`n"
Loop, %len%
{
    repo := ObjRawGet(repoList, A_Index)
    msg := % msg "`n" A_Index ". " repo
}

ToolTipAtCenter(msg)
Input, Selection, L1
ToolTip
if (Selection = Chr(27))
    ExitWithToolTip("Cancel", 0)

selectedRepo := ObjRawGet(repoList, Selection)
if StrLen(selectedRepo) = 0
    ExitWithToolTip("Invalid Option", -1)

IniWrite, %selectedRepo%, git-util.ini, Target, Path
ExitWithToolTip("Repository selected to:`n" selectedRepo, 0)

; unreachable code
ExitApp -1


; -------------------
; Functions
; -------------------

GetActiveExplorerPath()
{
	explorerHwnd := WinActive("ahk_class CabinetWClass")
	if (explorerHwnd)
	{
		for window in ComObjCreate("Shell.Application").Windows
		{
			if (window.hwnd==explorerHwnd)
			{
				return window.Document.Folder.Self.Path
			}
		}
	}
}

IsGitRepo(path)
{
    RunWait, git config --get remote.origin.url, %path%, Hide UseErrorLevel
    if ErrorLevel = 0
        return true
    
    RunWait, git status, %path%, Hide UseErrorLevel
    if ErrorLevel = 0
        return true

    return false
}

TakeForkSettingsPath()
{
    EnvGet, LocalAppData, LOCALAPPDATA
    return % LocalAppData "\Fork\settings.json"
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

RemoveToolTip:
    Tooltip
    return


ExitWithToolTip(message, exitCode)
{
    ToolTipAtCenter(message, 1000)
    Sleep 1000
    ExitApp %exitCode%
    return
}