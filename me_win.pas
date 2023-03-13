{*                               me_win
*                                ======
*
* Модуль для работы с ПК, взаимодействие c windosw.
* Создан: 18.04.2022
* (С) Кандауров Андрей (Сантиг)
*}

unit me_win;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, LazUTF8, LazFileUtils, FileUtil, ComCtrls, LConvEncoding
  {$IFDEF WINDOWS}, Windows, Winsock, JwaTlHelp32, me_my{$ENDIF}
  , Graphics, Dialogs, LCLProc
  {$IFDEF LINUX},process{$ENDIF}
  {$IFnDEF DEBUG}, LazLoggerDummy {отключить DebugLn} {$EndIf};
// JwaTlHelp32 is in fpc\packages\winunits-jedi\src\jwatlhelp32.pas


//-------------- Работа с окнами ---------------------
const
  //длинна строки заголовка окна
  windCaption = 100;

type

  TRNode = record
    Handle:    THandle;
    ClassName: string[windCaption];
    Caption:   string[windCaption];
    HandlMenu: HMenu;
    //можно сделать скрин окна?
    scrin:     Bool3;// Boolean;
    //проверка флогов
    flagBool:  boolean;
  end;
  PRNode = ^TRNode;

// Найти верхний уровень из всех handle
function windFindFirst(HNDL: THANDLE): THANDLE;
//поиск всех окон с изображением от текущего Handl, данные вставляются в Tree
//windName=True - окна бязательно имеющие заголовки;
//windBtm =True - окна в которых бязательно можно получить снимки
procedure windFindAll(Handl: THandle; ParentNode: TTreeNode; windName, windBtm: boolean;
  var Tree: TTreeView);
// Удалить узлы с пустым хендлем (в Data - Hendel=0)
procedure windFindDel0(var Tree: TTreeView);
//Удалить все Data из дерева и очистить его. Есть aTree.EndUpdate;
procedure windFindFreeTree(var aTree: TTreeView);

//-----------------------------------


// 0 - приложение не запущено
function meAppIsRunning(const ExeName: string): integer;
// Принудительно завершить приложение
procedure meKillApp(const ExeName: string);



implementation

// ============ Робота с окнами в Windows =============

// Найти верхний уровень из всех handle
function windFindFirst(HNDL: THANDLE): THANDLE;
var
  h: HWND;
begin
  Result := HNDL;
  h      := HNDL;
  while h <> 0 do
      try
      Result := h;
      h      := GetWindow(h, GW_OWNER);
      except
      Exit(0);
      end;
  Result := GetWindow(Result, GW_HWNDFIRST);
end;

//поиск всех окон с изображением от текущего Handl, данные вставляются в Tree
//windName=True - окна бязательно имеющие заголовки;
//windBtm =True - окна в которых бязательно можно получить снимки
//Дерево уничтожать: windFindFreeTree()
procedure windFindAll(Handl: THandle; ParentNode: TTreeNode; windName, windBtm: boolean;
  var Tree: TTreeView);
var
  Node:  TTreeNode = nil;
  pND:   PRNode;
  bmp:   TBitmap;
  DC:    HDC;
  H, h2: HWND;
  stat:  set of (stName, stBtm);
  windFindName: array[0..windCaption] of char = '';
begin
  H := Handl;
  repeat
    stat := [];
    //Получить имя окна
    GetWindowText(H, @windFindName, windCaption);
    New(pND);
    pND^.Handle  := H;
    pND^.Caption := CP1251ToUTF8(windFindName);
    GetClassName(H, @windFindName, windCaption);
    pND^.ClassName := CP1251ToUTF8(windFindName);
    pND^.HandlMenu := GetMenu(H);

    //если ДОЛЖНО быть имя у окна
    if windName then
      begin
      //if not (StrComp(windFindName, '') = 0) then
      if pND^.Caption <> '' then
        stat := stat + [stName];
      end
    else
      stat := stat + [stName];
    //windName может быть false
    //if (StrComp(windFindName, '') = 0) then
    if pND^.Caption = '' then
      windFindName := '---'
    else
      windFindName := pND^.Caption;

    //если должен быть снимок
    pND^.scrin := NaNe;
    if windBtm then
      if stName in stat then
        //заведомо не проверять скрины окон без имени
        begin
        bmp := Graphics.TBitmap.Create;
          try
            try
            pND^.scrin := Fals;
            DC := GetDC(H);
            bmp.LoadFromDevice(DC);
            stat := stat + [stBtm];
            pND^.scrin := Tru;
            finally
            ReleaseDC(0, DC);
            end;
          except;
          end;
        FreeAndNil(bmp);
        end
      else
        stat := stat + [stBtm]
    else
      stat   := stat + [stBtm];


    if ((stName in stat)) and (stBtm in stat) then
      pND^.flagBool := True
    else
      pND^.flagBool := False;

    if Assigned(ParentNode) then
      Node := Tree.Items.AddChildObject(ParentNode, windFindName, pND)
    else
      Node := Tree.Items.AddObject(ParentNode, windFindName, pND);

    h2 := GetWindow(H, GW_CHILD);
    if h2 > 0 then
      begin
      h2 := GetWindow(h2, GW_HWNDFIRST);
      windFindAll(h2, Node, windName, windBtm, Tree);
      end;
    H := GetWindow(H, GW_HWNDNext);
    //Dispose(pND);
  until H = 0;
end;

// Удалить узлы с пустым хендлем (в Data - Hendel=0)
procedure windFindDel0(var Tree: TTreeView);
var
  Node, nodChil: TTreeNode;
  pND: PRNode;

  function nodsDel(ND: TTreeNode): boolean;
  var
    nodPred, nodDel: TTreeNode;
    R: boolean;
  begin
    nodPred := ND;
    Result  := False;
    while nodPred <> nil do
      begin
      R := False;
      if nodPred.HasChildren then
        R := nodsDel(nodPred.GetLastChild);

      if not R then
        //if objDataRead(nodPred, 0) <> 0 then
        //R := True;
        R := TRNode(nodPred.Data^).flagBool;

      nodDel  := nodPred;
      nodPred := nodPred.GetPrevSibling;
      //можно удалить узел
      if not R then
          try
          //nodDel.Text := 'x. ' + nodDel.Text;//для отладки
          pND := nodDel.Data;
          Dispose(pND);
          nodDel.Data := nil;
          Tree.Items.Delete(nodDel);
          except;
          //ShowMessage('ош в удалении');
          end;
      Result := Result or R;
      end;
  end;

begin
  Node := Tree.TopItem.GetLastSibling;
  while Node <> nil do
      try
      //DebugLn('Уровень, индекс (hndl) нода: %d - %d (%d): %s', [Node.Level, Node.Index, objDataRead(Node, 0), Node.Text]);
      // копируем nodChil, если в подпрограмме удалится, то не от чего будет брать предыдущий нод
      nodChil := Node;
      Node    := Node.GetPrevSibling;
      if not nodsDel(nodChil.GetLastChild) then
        //if objDataRead(nodChil, 0) = 0 then
        if TRNode(nodChil.Data^).flagBool = False then
          begin
          pND := nodChil.Data;
          Dispose(pND);
          nodChil.Data := nil;
          Tree.Items.Delete(nodChil);
          end;
      except
      nodChil := nil;
      Break;
      end;
end;

//Удалить все Data из дерева и очистить его. Есть aTree.EndUpdate;
procedure windFindFreeTree(var aTree: TTreeView);
var
  i:   PtrInt;
  pND: PRNode;
begin
  aTree.BeginUpdate;
  for i := 0 to aTree.Items.Count - 1 do
      try
      pND := aTree.Items[i].Data;
      Dispose(pND);
      except;
      end;
  aTree.Items.Clear;
  aTree.EndUpdate;
end;

{-------------------------------------------}



{$IFDEF WINDOWS}
// 0 - приложение не запущено
function meAppIsRunning(const ExeName: string): Integer;
var
  ContinueLoop: BOOL;
  FSnapshotHandle: THandle;
  FProcessEntry32: TProcessEntry32;
begin
  Result := 0;
  FSnapshotHandle := CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
  FProcessEntry32.dwSize := SizeOf(FProcessEntry32);
  ContinueLoop := Process32First(FSnapshotHandle, FProcessEntry32);
  while integer(ContinueLoop) <> 0 do
    begin
    if ((UpperCase(ExtractFileName(FProcessEntry32.szExeFile)) =
      UpperCase(ExeName)) or (UpperCase(FProcessEntry32.szExeFile) =
      UpperCase(ExeName))) then
      begin
      Inc(Result);
      end;
    ContinueLoop := Process32Next(FSnapshotHandle, FProcessEntry32);
    end;
  CloseHandle(FSnapshotHandle);
end;

// Принудительно завершить приложение
Procedure meKillApp(const ExeName:String);
var
  ContinueLoop: BOOL;
  FSnapshotHandle: THandle;
  FProcessEntry32: TProcessEntry32;
  AHandle: THandle;
  ID: dword;
begin
  FSnapshotHandle := CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
  FProcessEntry32.dwSize := SizeOf(FProcessEntry32);
  ContinueLoop := Process32First(FSnapshotHandle, FProcessEntry32);
  while integer(ContinueLoop) <> 0 do
    begin
    if ((UpperCase(ExtractFileName(FProcessEntry32.szExeFile)) =
      UpperCase(ExeName)) or (UpperCase(FProcessEntry32.szExeFile) =
      UpperCase(ExeName))) then
      begin
       ID:=FProcessEntry32.th32ProcessID;
       AHandle := OpenProcess(PROCESS_ALL_ACCESS,False,ID); //uses windows
       TerminateProcess(AHandle,255);
      end;
    ContinueLoop := Process32Next(FSnapshotHandle, FProcessEntry32);
    end;
  CloseHandle(FSnapshotHandle);
end;
{$ENDIF}
{$IFDEF LINUX}
function GetComputerNetName: string;
begin
  Result:=GetEnvironmentVariableUTF8('USER');
end;
function meAppIsRunning(const ExeName: string): integer;
var
  t: TProcess;
  s: TStringList;
begin
  Result := 0;
  t := tprocess.Create(nil);
  t.CommandLine := 'ps -C ' + ExeName;
  t.Options := [poUsePipes, poWaitonexit];
    try
    t.Execute;
    s := TStringList.Create;
      try
      s.LoadFromStream(t.Output);
      Result := Pos(ExeName, s.Text);
      finally
      s.Free;
      end;
    finally
    t.Free;
    end;
end;
procedure meKillApp(const ExeName: string);
// killall -9 processname
// or pidof EXEName gives PID then kill PID
var
  t: TProcess;
  s: TStringList;
begin
  t := tprocess.Create(nil);
  t.CommandLine := 'killall -9 ' + ExeName;
  t.Options := [poUsePipes, poWaitonexit];
    try
    t.Execute;
    {
    s := TStringList.Create;
      try
      s.LoadFromStream(t.Output);
      Result := Pos(ExeName, s.Text);
      finally
      s.Free;
      end;
    }
    finally
    t.Free;
    end;
end;
{$ENDIF}



end.
