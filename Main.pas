(*              Main.pas
*              ==========
* Простой пример работы с окнами в памяти ОС Windows.
* Открыт: февраль 2023 г.
* (С) Кандауров Андрей (Сантиг)
*)

unit Main;
{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

interface

uses
{$IFnDEF FPC}
  RXSplit, RxGrdCpt, RxMenus, SpeedBar, Placemnt,
{$ELSE}
  LCLIntf, LCLType, IniPropStorage, Buttons,
{$ENDIF}
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ImgList, ComCtrls, Grids, ExtCtrls, Menus, PairSplitter, LConvEncoding,
  TreeFilterEdit, LazFileUtils,
  me_my, me_win;

type

  { TfmMain }

  TfmMain = class(TForm)
    Chk_Name: TCheckBox;
    Chk_Scrin: TCheckBox;
    ImgScreen: TImage;
    IniPropStorage: TIniPropStorage;
    mnRDClick: TMenuItem;
    mnLDClick: TMenuItem;
    mnRClick: TMenuItem;
    mnLClick: TMenuItem;
    Separator4: TMenuItem;
    mnClose: TMenuItem;
    mnDeEnable: TMenuItem;
    Separator3: TMenuItem;
    mnNormal: TMenuItem;
    Separator2: TMenuItem;
    Separator1: TMenuItem;
    TreeFilterEdit1: TTreeFilterEdit;
    tree_razvern: TButton;
    tree_razvernOne: TButton;
    tree_svern: TButton;
    imNode: TImageList;
    PairSplitter: TPairSplitter;
    PairSplitterSide1: TPairSplitterSide;
    PairSplitterSide2: TPairSplitterSide;
    ToolButton2: TToolButton;
    tv:     TTreeView;
    grProp: TStringGrid;
    sbMain: TToolBar;
    stMain: TStatusBar;
    siRefresh: TSpeedButton;
    siExit: TSpeedButton;
    fsMain: TIniPropStorage;
    dlSave: TSaveDialog;
    mnMain: TMainMenu;
    mnFile: TMenuItem;
    mnRefresh: TMenuItem;
    mnSave: TMenuItem;
    N1:     TMenuItem;
    mnExit: TMenuItem;
    mnAction: TMenuItem;
    mnEnable: TMenuItem;
    mnHideWindow: TMenuItem;
    mnShowWindow: TMenuItem;
    mnMinimize: TMenuItem;
    mnDestroy: TMenuItem;
    procedure Chk_NameChange(Sender: TObject);
    procedure Chk_ScrinChange(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure mnLClickClick(Sender: TObject);
    procedure mnCloseClick(Sender: TObject);
    procedure mnDeEnableClick(Sender: TObject);
    procedure mnNormalClick(Sender: TObject);
    procedure mnRClickClick(Sender: TObject);
    procedure mnLDClickClick(Sender: TObject);
    procedure mnRDClickClick(Sender: TObject);
    procedure mnRefreshClick(Sender: TObject);
    procedure siRefreshClick(Sender: TObject);
    procedure siRefreshNameClick(Sender: TObject);
    procedure tree_razvernClick(Sender: TObject);
    procedure tree_razvernOneClick(Sender: TObject);
    procedure tree_svernClick(Sender: TObject);
    procedure mnExitClick(Sender: TObject);
    procedure mnSaveClick(Sender: TObject);
    procedure mnEnableClick(Sender: TObject);
    procedure mnHideWindowClick(Sender: TObject);
    procedure mnShowWindowClick(Sender: TObject);
    procedure mnMinimizeClick(Sender: TObject);
    procedure mnDestroyClick(Sender: TObject);
    procedure tvChange(Sender: TObject; Node: TTreeNode);
  private
    { Private declarations }
    procedure LoadWin();
  public
    { Public declarations }
  end;

var
  fmMain:   TfmMain;
  h, h1:    THandle;
  loadBool: boolean = False;

implementation

{$IFnDEF FPC}
  {$R *.dfm}

{$ELSE}
  {$R *.lfm}
{$ENDIF}


procedure TfmMain.FormActivate(Sender: TObject);
begin
  LoadWin();
  loadBool := True;
end;

procedure TfmMain.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  windFindFreeTree(tv);
end;

procedure TfmMain.FormCreate(Sender: TObject);
var
  s: string;
begin
  s := GetAppConfigFileUTF8(False, True, True);
  ForceDirectoriesUTF8(s);
  IniPropStorage.IniFileName := s + 'conf.ini';
end;

procedure TfmMain.Chk_NameChange(Sender: TObject);
begin
  if loadBool then
    LoadWin();
end;

procedure TfmMain.Chk_ScrinChange(Sender: TObject);
begin
  if loadBool then
    LoadWin();
end;

procedure TfmMain.LoadWin();
var
  cur: TCursor;
begin
  stMain.Panels[0].Text := 'Обновление ...';
  cur := fmMain.Cursor;
  fmMain.Cursor := crHourGlass;
  Application.ProcessMessages;
  tv.Items.BeginUpdate;
  windFindFreeTree(tv);

  // Найти верхний уровень handle
  h := me_win.windFindFirst(Handle);

  //поиск всех окон
  me_win.windFindAll(h, nil, Chk_Name.Checked, Chk_Scrin.Checked, tv);
  //удалить лишние окна
  me_win.windFindDel0(tv);
  tv.FullCollapse;
  tv.Items.EndUpdate;
  fmMain.Cursor := cur;

  grProp.Cells[1, 1] := '';
  grProp.Cells[1, 2] := '';
  grProp.Cells[1, 3] := '';
  grProp.Cells[1, 4] := '';

  stMain.Panels[0].Text := 'Найдено окон: ' + tv.Items.TopLvlCount.ToString;
end;

procedure TfmMain.mnLClickClick(Sender: TObject);
begin
  AttachThreadInput(GetCurrentThreadId, TRNode(tv.Selected.Data^).Handle, True);
  SetForegroundWindow(Application.Handle);
  sendMessage(TRNode(tv.Selected.Data^).Handle, WM_LBUTTONDOWN, 0, 0);
  sendMessage(TRNode(tv.Selected.Data^).Handle, WM_LBUTTONUP, 0, 0);
  AttachThreadInput(GetCurrentThreadId, TRNode(tv.Selected.Data^).Handle, False);
end;

procedure TfmMain.mnRefreshClick(Sender: TObject);
begin
  LoadWin();
end;

procedure TfmMain.siRefreshClick(Sender: TObject);
begin
  LoadWin();
end;

procedure TfmMain.siRefreshNameClick(Sender: TObject);
begin
  LoadWin();
end;

procedure TfmMain.tree_razvernClick(Sender: TObject);
begin
  tv.FullExpand;
end;

procedure TfmMain.tree_razvernOneClick(Sender: TObject);
begin
  if Assigned(tv.Selected) then
    tv.Selected.Expand(True);
end;

procedure TfmMain.tree_svernClick(Sender: TObject);
begin
  tv.FullCollapse;
end;

procedure TfmMain.mnExitClick(Sender: TObject);
begin
  Close;
end;

procedure TfmMain.mnSaveClick(Sender: TObject);
begin
  if dlSave.Execute then
    tv.SaveToFile(dlSave.FileName);
end;

procedure TfmMain.mnEnableClick(Sender: TObject);
begin
  EnableWindow(TRNode(tv.Selected.Data^).Handle, True);
end;

procedure TfmMain.mnDeEnableClick(Sender: TObject);
begin
  EnableWindow(TRNode(tv.Selected.Data^).Handle, False);
end;

procedure TfmMain.mnHideWindowClick(Sender: TObject);
begin
  ShowWindow(TRNode(tv.Selected.Data^).Handle, sw_Hide);
end;

procedure TfmMain.mnShowWindowClick(Sender: TObject);
begin
  ShowWindow(TRNode(tv.Selected.Data^).Handle, sw_Show);
end;

procedure TfmMain.mnMinimizeClick(Sender: TObject);
begin
  ShowWindow(TRNode(tv.Selected.Data^).Handle, sw_ShowMinimized);
end;

procedure TfmMain.mnNormalClick(Sender: TObject);
begin
  ShowWindow(TRNode(tv.Selected.Data^).Handle, SW_SHOWNORMAL);
end;

procedure TfmMain.mnRClickClick(Sender: TObject);
begin
  AttachThreadInput(GetCurrentThreadId, TRNode(tv.Selected.Data^).Handle, True);
  SetForegroundWindow(Application.Handle);
  sendMessage(TRNode(tv.Selected.Data^).Handle, WM_RBUTTONDOWN, 0, 0);
  sendMessage(TRNode(tv.Selected.Data^).Handle, WM_RBUTTONUP, 0, 0);
  AttachThreadInput(GetCurrentThreadId, TRNode(tv.Selected.Data^).Handle, False);
end;

procedure TfmMain.mnLDClickClick(Sender: TObject);
begin
  AttachThreadInput(GetCurrentThreadId, TRNode(tv.Selected.Data^).Handle, True);
  SetForegroundWindow(Application.Handle);
  sendMessage(TRNode(tv.Selected.Data^).Handle, WM_lBUTTONDBLCLK, 0, 0);
  sendMessage(TRNode(tv.Selected.Data^).Handle, WM_LBUTTONUP, 0, 0);
  AttachThreadInput(GetCurrentThreadId, TRNode(tv.Selected.Data^).Handle, False);
end;

procedure TfmMain.mnRDClickClick(Sender: TObject);
begin
  AttachThreadInput(GetCurrentThreadId, TRNode(tv.Selected.Data^).Handle, True);
  SetForegroundWindow(Application.Handle);
  sendMessage(TRNode(tv.Selected.Data^).Handle, WM_RBUTTONDBLCLK, 0, 0);
  sendMessage(TRNode(tv.Selected.Data^).Handle, WM_RBUTTONUP, 0, 0);
  AttachThreadInput(GetCurrentThreadId, TRNode(tv.Selected.Data^).Handle, False);
end;

procedure TfmMain.mnDestroyClick(Sender: TObject);
begin
  PostMessage(TRNode(tv.Selected.Data^).Handle, wm_Destroy, 0, 0);
end;

procedure TfmMain.tvChange(Sender: TObject; Node: TTreeNode);
begin
  if Assigned(Node) then
    if Node.Data <> nil then
      begin
      with grProp do
        begin
        Cells[1, 1] := IntToStr(TRNode(Node.Data^).Handle);
        Cells[1, 2] := TRNode(Node.Data^).Caption;
        Cells[1, 3] := TRNode(Node.Data^).ClassName;
        Cells[1, 4] := IntToStr(TRNode(Node.Data^).HandlMenu);
        end;

      if (TRNode(Node.Data^).scrin = Tru) or (TRNode(Node.Data^).scrin = NaNe) then
        screenShot(TRNode(Node.Data^).Handle, ImgScreen.Picture)
      else
        imgShax(ImgScreen);
      end;
  Node := nil;
end;

procedure TfmMain.mnCloseClick(Sender: TObject);
begin
  SendMessage(TRNode(tv.Selected.Data^).Handle, WM_SYSCOMMAND, SC_CLOSE, 0);
end;


end.
