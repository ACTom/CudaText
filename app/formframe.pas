(*
This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.

Copyright (c) Alexey Torgashin
*)
unit FormFrame;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Graphics, Forms, Controls, Dialogs,
  ExtCtrls, Menus, StdCtrls, StrUtils, ComCtrls,
  LCLIntf, LCLProc, LCLType, LazUTF8, LazFileUtils, FileUtil,
  ATTabs,
  ATGroups,
  ATSynEdit,
  ATSynEdit_Finder,
  ATSynEdit_Keymap_Init,
  ATSynEdit_Adapters,
  ATSynEdit_Adapter_EControl,
  ATSynEdit_Adapter_LiteLexer,
  ATSynEdit_Carets,
  ATSynEdit_Gaps,
  ATSynEdit_Markers,
  ATSynEdit_CanvasProc,
  ATSynEdit_Commands,
  ATSynEdit_Bookmarks,
  ATStrings,
  ATStringProc,
  ATStringProc_HtmlColor,
  ATFileNotif,
  ATButtons,
  ATPanelSimple,
  ATBinHex,
  ATStreamSearch,
  ATImageBox,
  proc_globdata,
  proc_editor,
  proc_cmd,
  proc_colors,
  proc_files,
  proc_msg,
  proc_str,
  proc_py,
  proc_py_const,
  proc_miscutils,
  ec_SyntAnal,
  ec_proc_lexer,
  formlexerstylemap,
  at__jsonconf,
  math,
  LazUTF8Classes;

type
  TEditorFramePyEvent = function(AEd: TATSynEdit; AEvent: TAppPyEvent; const AParams: array of string): string of object;

type
  TAppOpenMode = (
    cOpenModeEditor,
    cOpenModeViewText,
    cOpenModeViewBinary,
    cOpenModeViewHex,
    cOpenModeViewUnicode
    );

type
  { TEditorFrame }

  TEditorFrame = class(TFrame)
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    Splitter: TSplitter;
    TimerChange: TTimer;
    procedure FrameResize(Sender: TObject);
    procedure SplitterMoved(Sender: TObject);
    procedure TimerChangeTimer(Sender: TObject);
  private
    { private declarations }
    FTabCaption: string;
    FTabCaptionFromApi: boolean;
    FTabImageIndex: integer;
    FTabId: integer;
    FFileName: string;
    FFileWasBig: boolean;
    FModified: boolean;
    FNotif: TATFileNotif;
    FTextCharsTyped: integer;
    FActivationTime: QWord;
    FCodetreeFilter: string;
    FCodetreeFilterHistory: TStringList;
    FEnabledCodeTree: boolean;
    FOnChangeCaption: TNotifyEvent;
    FOnProgress: TATFinderProgress;
    FOnUpdateStatus: TNotifyEvent;
    FOnEditorClickMoveCaret: TATSynEditClickMoveCaretEvent;
    FOnEditorClickEndSelect: TATSynEditClickMoveCaretEvent;
    FOnFocusEditor: TNotifyEvent;
    FOnEditorCommand: TATSynEditCommandEvent;
    FOnEditorChangeCaretPos: TNotifyEvent;
    FOnSaveFile: TNotifyEvent;
    FOnAddRecent: TNotifyEvent;
    FOnPyEvent: TEditorFramePyEvent;
    FSplitted: boolean;
    FSplitHorz: boolean;
    FSplitPos: double;
    FActiveSecondaryEd: boolean;
    FLocked: boolean;
    FTabColor: TColor;
    FTabSizeChanged: boolean;
    FFoldTodo: string;
    FTopLineTodo: integer;
    FTabKeyCollectMarkers: boolean;
    FTagString: string;
    FNotInRecents: boolean;
    FMacroRecord: boolean;
    FMacroString: string;
    FImageBox: TATImageBox;
    FBin: TATBinHex;
    FBinStream: TFileStreamUTF8;
    FImageFilename: string;
    FCheckFilenameOpened: TStrFunction;
    FOnMsgStatus: TStrEvent;
    FSaveDialog: TSaveDialog;
    FReadOnlyFromFile: boolean;

    procedure BinaryOnKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure BinaryOnScroll(Sender: TObject);
    procedure BinaryOnProgress(const ACurrentPos, AMaximalPos: Int64;
      var AContinueSearching: Boolean);
    procedure DoDeactivatePictureMode;
    procedure DoDeactivateViewerMode;
    procedure DoFileOpen_AsBinary(const fn: string; AMode: TATBinHexMode);
    procedure DoFileOpen_AsPicture(const fn: string);
    procedure DoImageboxScroll(Sender: TObject);
    procedure DoOnChangeCaption;
    procedure DoOnChangeCaretPos;
    procedure DoOnUpdateStatus;
    procedure EditorClickEndSelect(Sender: TObject; APrevPnt, ANewPnt: TPoint);
    procedure EditorClickMoveCaret(Sender: TObject; APrevPnt, ANewPnt: TPoint);
    procedure EditorDrawMicromap(Sender: TObject; C: TCanvas; const ARect: TRect);
    procedure EditorOnChangeCommon(Sender: TObject);
    procedure EditorOnChange1(Sender: TObject);
    procedure EditorOnChange2(Sender: TObject);
    procedure EditorOnClick(Sender: TObject);
    procedure EditorOnClickGap(Sender: TObject; AGapItem: TATSynGapItem; APos: TPoint);
    procedure EditorOnClickGutter(Sender: TObject; ABand, ALine: integer);
    procedure EditorOnClickDouble(Sender: TObject; var AHandled: boolean);
    procedure EditorOnClickMicroMap(Sender: TObject; AX, AY: integer);
    procedure EditorOnClickMiddle(Sender: TObject; var AHandled: boolean);
    procedure EditorOnCommand(Sender: TObject; ACmd: integer; const AText: string; var AHandled: boolean);
    procedure EditorOnCommandAfter(Sender: TObject; ACommand: integer; const AText: string);
    procedure EditorOnDrawBookmarkIcon(Sender: TObject; C: TCanvas; ALineNum: integer; const ARect: TRect);
    procedure EditorOnEnter(Sender: TObject);
    procedure EditorOnDrawLine(Sender: TObject; C: TCanvas; AX, AY: integer;
      const AStr: atString; ACharSize: TPoint; const AExtent: TATIntArray);
    procedure EditorOnCalcBookmarkColor(Sender: TObject; ABookmarkKind: integer; out AColor: TColor);
    procedure EditorOnChangeCaretPos(Sender: TObject);
    procedure EditorOnHotspotEnter(Sender: TObject; AHotspotIndex: integer);
    procedure EditorOnHotspotExit(Sender: TObject; AHotspotIndex: integer);
    procedure EditorOnKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure EditorOnPaste(Sender: TObject; var AHandled: boolean; AKeepCaret,
      ASelectThen: boolean);
    procedure EditorOnScroll(Sender: TObject);
    function GetCommentString: string;
    function GetEnabledFolding: boolean;
    function GetEncodingName: string;
    function GetLineEnds: TATLineEnds;
    function GetNotifEnabled: boolean;
    function GetNotifTime: integer;
    function GetPictureScale: integer;
    function GetReadOnly: boolean;
    function GetTabKeyCollectMarkers: boolean;
    function GetUnprintedEnds: boolean;
    function GetUnprintedEndsDetails: boolean;
    function GetUnprintedShow: boolean;
    function GetUnprintedSpaces: boolean;
    procedure InitEditor(var ed: TATSynEdit);
    procedure NotifChanged(Sender: TObject);
    procedure SetEnabledCodeTree(AValue: boolean);
    procedure SetEnabledFolding(AValue: boolean);
    procedure SetEncodingName(const Str: string);
    procedure SetFileName(const AValue: string);
    procedure SetFileWasBig(AValue: boolean);
    procedure SetLocked(AValue: boolean);
    procedure SetModified(AValue: boolean);
    procedure SetNotifEnabled(AValue: boolean);
    procedure SetNotifTime(AValue: integer);
    procedure SetPictureScale(AValue: integer);
    procedure SetReadOnly(AValue: boolean);
    procedure SetTabColor(AColor: TColor);
    procedure SetTabImageIndex(AValue: integer);
    procedure SetUnprintedEnds(AValue: boolean);
    procedure SetUnprintedEndsDetails(AValue: boolean);
    procedure SetUnprintedShow(AValue: boolean);
    procedure SetSplitHorz(AValue: boolean);
    procedure SetSplitPos(AValue: double);
    procedure SetSplitted(AValue: boolean);
    procedure SetTabCaption(const AValue: string);
    procedure SetLineEnds(Value: TATLineEnds);
    procedure SetUnprintedSpaces(AValue: boolean);
    procedure UpdateEds(AUpdateWrapInfo: boolean=false);
    function GetLexer: TecSyntAnalyzer;
    function GetLexerLite: TATLiteLexer;
    procedure SetLexer(an: TecSyntAnalyzer);
    procedure SetLexerLite(an: TATLiteLexer);
    function GetLexerName: string;
    procedure SetLexerName(const AValue: string);
  protected
    procedure DoOnResize; override;
  public
    { public declarations }
    Ed1: TATSynEdit;
    Ed2: TATSynEdit;
    Adapter: TATAdapterEControl;
    Groups: TATGroups;
    CachedTreeview: TTreeView;

    constructor Create(AOwner: TComponent; AApplyCentering: boolean); reintroduce;
    destructor Destroy; override;
    function Editor: TATSynEdit;
    function Editor2: TATSynEdit;
    procedure EditorOnKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    property ReadOnly: boolean read GetReadOnly write SetReadOnly;
    property ReadOnlyFromFile: boolean read FReadOnlyFromFile write FReadOnlyFromFile;
    property FileName: string read FFileName write SetFileName;
    property FileWasBig: boolean read FFileWasBig write SetFileWasBig;
    property TabCaption: string read FTabCaption write SetTabCaption;
    property TabImageIndex: integer read FTabImageIndex write SetTabImageIndex;
    property TabCaptionFromApi: boolean read FTabCaptionFromApi write FTabCaptionFromApi;
    property TabId: integer read FTabId;
    property Modified: boolean read FModified write SetModified;
    procedure UpdateModifiedState(AWithEvent: boolean= true);
    procedure UpdateReadOnlyFromFile;
    property NotifEnabled: boolean read GetNotifEnabled write SetNotifEnabled;
    property NotifTime: integer read GetNotifTime write SetNotifTime;
    property Lexer: TecSyntAnalyzer read GetLexer write SetLexer;
    property LexerLite: TATLiteLexer read GetLexerLite write SetLexerLite;
    property LexerName: string read GetLexerName write SetLexerName;
    function LexerNameAtPos(APos: TPoint): string;
    property Locked: boolean read FLocked write SetLocked;
    property CommentString: string read GetCommentString;
    property TabColor: TColor read FTabColor write SetTabColor;
    property TabSizeChanged: boolean read FTabSizeChanged write FTabSizeChanged;
    property TabKeyCollectMarkers: boolean read GetTabKeyCollectMarkers write FTabKeyCollectMarkers;
    property TagString: string read FTagString write FTagString;
    property NotInRecents: boolean read FNotInRecents write FNotInRecents;
    property TopLineTodo: integer read FTopLineTodo write FTopLineTodo; //always use it instead of Ed.LineTop
    property TextCharsTyped: integer read FTextCharsTyped write FTextCharsTyped;
    property EnabledCodeTree: boolean read FEnabledCodeTree write SetEnabledCodeTree;
    property CodetreeFilter: string read FCodetreeFilter write FCodetreeFilter;
    property CodetreeFilterHistory: TStringList read FCodetreeFilterHistory;
    property ActivationTime: QWord read FActivationTime write FActivationTime;
    function IsEmpty: boolean;
    procedure ApplyTheme;
    procedure SetFocus; reintroduce;
    function IsText: boolean;
    function IsPicture: boolean;
    function IsBinary: boolean;
    property PictureFileName: string read FImageFilename;
    function PictureSizes: TPoint;
    property PictureScale: integer read GetPictureScale write SetPictureScale;
    property Binary: TATBinHex read FBin;
    function BinaryFindFirst(AFinder: TATEditorFinder; AShowAll: boolean): boolean;
    function BinaryFindNext(ABack: boolean): boolean;
    //
    property LineEnds: TATLineEnds read GetLineEnds write SetLineEnds;
    property EncodingName: string read GetEncodingName write SetEncodingName;
    property UnprintedShow: boolean read GetUnprintedShow write SetUnprintedShow;
    property UnprintedSpaces: boolean read GetUnprintedSpaces write SetUnprintedSpaces;
    property UnprintedEnds: boolean read GetUnprintedEnds write SetUnprintedEnds;
    property UnprintedEndsDetails: boolean read GetUnprintedEndsDetails write SetUnprintedEndsDetails;
    property Splitted: boolean read FSplitted write SetSplitted;
    property SplitHorz: boolean read FSplitHorz write SetSplitHorz;
    property SplitPos: double read FSplitPos write SetSplitPos;
    property EnabledFolding: boolean read GetEnabledFolding write SetEnabledFolding;
    property SaveDialog: TSaveDialog read FSaveDialog write FSaveDialog;
    //file
    procedure DoFileClose;
    procedure DoFileOpen(const fn: string; AAllowLoadHistory,
      AAllowErrorMsgBox: boolean; AOpenMode: TAppOpenMode);
    function DoFileSave(ASaveAs: boolean): boolean;
    procedure DoFileReload_DisableDetectEncoding;
    procedure DoFileReload;
    procedure DoLexerFromFilename(const AFilename: string);
    procedure DoSaveHistory;
    procedure DoSaveHistoryEx(c: TJsonConfig; const path: string);
    procedure DoLoadHistory;
    procedure DoLoadHistoryEx(c: TJsonConfig; const path: string);
    //misc
    function DoPyEvent(AEd: TATSynEdit; AEvent: TAppPyEvent; const AParams: array of string): string;
    procedure DoGotoPos(APosX, APosY: integer);
    procedure DoRestoreFolding;
    procedure DoClearPreviewTabState;
    procedure DoToggleFocusSplitEditors;
    //macro
    procedure DoMacroStart;
    procedure DoMacroStop(ACancel: boolean);
    property MacroRecord: boolean read FMacroRecord;
    property MacroString: string read FMacroString write FMacroString;

    //events
    property OnProgress: TATFinderProgress read FOnProgress write FOnProgress;
    property OnCheckFilenameOpened: TStrFunction read FCheckFilenameOpened write FCheckFilenameOpened;
    property OnMsgStatus: TStrEvent read FOnMsgStatus write FOnMsgStatus;
    property OnFocusEditor: TNotifyEvent read FOnFocusEditor write FOnFocusEditor;
    property OnChangeCaption: TNotifyEvent read FOnChangeCaption write FOnChangeCaption;
    property OnUpdateStatus: TNotifyEvent read FOnUpdateStatus write FOnUpdateStatus;
    property OnEditorClickMoveCaret: TATSynEditClickMoveCaretEvent read FOnEditorClickMoveCaret write FOnEditorClickMoveCaret;
    property OnEditorClickEndSelect: TATSynEditClickMoveCaretEvent read FOnEditorClickEndSelect write FOnEditorClickEndSelect;
    property OnEditorCommand: TATSynEditCommandEvent read FOnEditorCommand write FOnEditorCommand;
    property OnEditorChangeCaretPos: TNotifyEvent read FOnEditorChangeCaretPos write FOnEditorChangeCaretPos;
    property OnSaveFile: TNotifyEvent read FOnSaveFile write FOnSaveFile;
    property OnAddRecent: TNotifyEvent read FOnAddRecent write FOnAddRecent;
    property OnPyEvent: TEditorFramePyEvent read FOnPyEvent write FOnPyEvent;
  end;

procedure GetFrameLocation(Frame: TEditorFrame;
  out AGroups: TATGroups; out APages: TATPages;
  out ALocalGroupIndex, AGlobalGroupIndex, ATabIndex: integer);


implementation

{$R *.lfm}

const
  cHistory_Lexer       = '/lexer';
  cHistory_Enc         = '/enc';
  cHistory_Top         = '/top';
  cHistory_Wrap        = '/wrap_mode';
  cHistory_RO          = '/ro';
  cHistory_Ruler       = '/ruler';
  cHistory_Minimap     = '/minimap';
  cHistory_Micromap    = '/micromap';
  cHistory_TabSize     = '/tab_size';
  cHistory_TabSpace    = '/tab_spaces';
  cHistory_Nums        = '/nums';
  cHistory_Unpri        = '/unprinted_show';
  cHistory_Unpri_Spaces = '/unprinted_spaces';
  cHistory_Unpri_Ends   = '/unprinted_ends';
  cHistory_Unpri_Detail = '/unprinted_end_details';
  cHistory_Caret       = '/caret';
  cHistory_TabColor    = '/color';
  cHistory_Bookmark    = '/bm';
  cHistory_BookmarkKind = '/bm_kind';
  cHistory_Fold        = '/folded';

var
  FLastTabId: integer = 0;


procedure GetFrameLocation(Frame: TEditorFrame;
  out AGroups: TATGroups; out APages: TATPages;
  out ALocalGroupIndex, AGlobalGroupIndex, ATabIndex: integer);
var
  C: TWinControl;
begin
  APages:= Frame.Parent as TATPages;

  C:= APages;
  repeat
    C:= C.Parent;
  until C is TATGroups;

  AGroups:= C as TATGroups;
  AGroups.PagesAndTabIndexOfControl(Frame, ALocalGroupIndex, ATabIndex);

  AGlobalGroupIndex:= ALocalGroupIndex;
  if AGroups.Tag<>0 then
    Inc(AGlobalGroupIndex, High(TATGroupsNums) + AGroups.Tag);
end;


{ TEditorFrame }

procedure TEditorFrame.SetTabCaption(const AValue: string);
var
  Upd: boolean;
begin
  if AValue='?' then Exit;
  Upd:= FTabCaption<>AValue;

  FTabCaption:= AValue; //don't check Upd here (for Win32)

  if Upd then
    DoPyEvent(Editor, cEventOnState, [IntToStr(EDSTATE_TAB_TITLE)]);
  DoOnChangeCaption;
end;

procedure TEditorFrame.EditorOnClick(Sender: TObject);
var
  NewAlt: boolean;
  State: TShiftState;
  StateString: string;
begin
  NewAlt:= Sender=Ed2;
  if NewAlt<>FActiveSecondaryEd then
  begin
    FActiveSecondaryEd:= NewAlt;
    DoOnUpdateStatus;
  end;

  State:= KeyboardStateToShiftState;
  StateString:= ConvertShiftStateToString(State);

  if UiOps.MouseGotoDefinition<>'' then
    if StateString=UiOps.MouseGotoDefinition then
    begin
      DoPyEvent(Sender as TATSynEdit, cEventOnGotoDef, []);
      exit;
    end;

  DoPyEvent(Sender as TATSynEdit, cEventOnClick, ['"'+StateString+'"']);
end;

procedure TEditorFrame.SplitterMoved(Sender: TObject);
begin
  if FSplitted then
    if FSplitHorz then
      FSplitPos:= Ed2.height/height
    else
      FSplitPos:= Ed2.width/width;
end;

procedure TEditorFrame.FrameResize(Sender: TObject);
begin
end;

procedure TEditorFrame.EditorOnKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  //res=False: block key
  if DoPyEvent(Sender as TATSynEdit,
    cEventOnKey,
    [
      IntToStr(Key),
      '"'+ConvertShiftStateToString(Shift)+'"'
    ]) = cPyFalse then
    begin
      Key:= 0;
      Exit
    end;
end;

procedure TEditorFrame.EditorOnPaste(Sender: TObject; var AHandled: boolean;
  AKeepCaret, ASelectThen: boolean);
const
  cBool: array[boolean] of string = (cPyFalse, cPyTrue);
begin
  if DoPyEvent(Sender as TATSynEdit,
    cEventOnPaste,
    [
      cBool[AKeepCaret],
      cBool[ASelectThen]
    ]) = cPyFalse then
    AHandled:= true;
end;

procedure TEditorFrame.EditorOnScroll(Sender: TObject);
begin
  DoPyEvent(Sender as TATSynEdit, cEventOnScroll, []);
end;

procedure TEditorFrame.EditorOnKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  //keyup: only for Ctrl/Shift/Alt
  //no res.
  case Key of
    VK_CONTROL,
    VK_MENU,
    VK_SHIFT,
    VK_RSHIFT:
      DoPyEvent(Sender as TATSynEdit,
        cEventOnKeyUp,
        [
          IntToStr(Key),
          '"'+ConvertShiftStateToString(Shift)+'"'
        ]);
  end;
end;


procedure TEditorFrame.TimerChangeTimer(Sender: TObject);
begin
  TimerChange.Enabled:= false;
  DoPyEvent(Editor, cEventOnChangeSlow, []);
end;

procedure TEditorFrame.EditorOnCalcBookmarkColor(Sender: TObject;
  ABookmarkKind: integer; out AColor: TColor);
begin
  if ABookmarkKind<=1 then
    AColor:= (Sender as TATSynEdit).Colors.BookmarkBG
  else
    AColor:= AppBookmarkSetup[ABookmarkKind].Color;
end;

procedure TEditorFrame.EditorOnChangeCaretPos(Sender: TObject);
begin
  DoOnChangeCaretPos;
  DoOnUpdateStatus;
  DoPyEvent(Sender as TATSynEdit, cEventOnCaret, []);
end;

procedure TEditorFrame.EditorOnHotspotEnter(Sender: TObject; AHotspotIndex: integer);
begin
  DoPyEvent(Sender as TATSynEdit, cEventOnHotspot, [
    cPyTrue, //hotspot enter
    IntToStr(AHotspotIndex)
    ]);
end;

procedure TEditorFrame.EditorOnHotspotExit(Sender: TObject; AHotspotIndex: integer);
begin
  DoPyEvent(Sender as TATSynEdit, cEventOnHotspot, [
    cPyFalse, //hotspot exit
    IntToStr(AHotspotIndex)
    ]);
end;

procedure TEditorFrame.EditorOnDrawLine(Sender: TObject; C: TCanvas; AX,
  AY: integer; const AStr: atString; ACharSize: TPoint;
  const AExtent: TATIntArray);
const
  cRegexRGB = 'rgba?\(\s*(\d{1,3})\s*,\s*(\d{1,3})\s*,\s*(\d{1,3})\s*(,\s*[\.\d]+\s*)?\)';
var
  X1, X2, Y, NLen: integer;
  NColor: TColor;
  Parts: TRegexParts;
  Ch: atChar;
  ValueR, ValueG, ValueB: byte;
  i: integer;
begin
  if AStr='' then Exit;
  if not IsFilenameListedInExtensionList(FileName, EditorOps.OpUnderlineColorFiles)
    then exit;

  for i:= 1 to Length(AStr) do
  begin
    Ch:= AStr[i];

    //find #rgb, #rrggbb
    if Ch='#' then
    begin
      NColor:= SHtmlColorToColor(Copy(AStr, i+1, 7), NLen, clNone);
      if NColor=clNone then Continue;

      if i-2>=0 then
        X1:= AX+AExtent[i-2]
      else
        X1:= AX;
      X2:= AX+AExtent[i-1+NLen];
      Y:= AY+ACharSize.Y;

      C.Brush.Color:= NColor;
      C.FillRect(X1, Y-EditorOps.OpUnderlineColorSize, X2, Y);
    end
    else
    //find "rgb(...)"
    if (Ch='r') and //fast check
       (Copy(AStr, i, 3)='rgb') and //slow check
       (i>1) and not IsCharWord(AStr[i-1], '') //word boundary
    then
    begin
      if SRegexFindParts(cRegexRGB, Copy(AStr, i, MaxInt), Parts) then
        if Parts[0].Pos=1 then //need at i-th char
        begin
          ValueR:= Max(0, Min(255, StrToIntDef(Parts[1].Str, 0)));
          ValueG:= Max(0, Min(255, StrToIntDef(Parts[2].Str, 0)));
          ValueB:= Max(0, Min(255, StrToIntDef(Parts[3].Str, 0)));

          NColor:= RGB(ValueR, ValueG, ValueB);
          NLen:= Parts[0].Len;

          if i-2>=0 then
            X1:= AX+AExtent[i-2]
          else
            X1:= AX;
          X2:= AX+AExtent[i-2+NLen];
          Y:= AY+ACharSize.Y;

          C.Brush.Color:= NColor;
          C.FillRect(X1, Y-EditorOps.OpUnderlineColorSize, X2, Y);
        end;
    end;
  end;
end;

function TEditorFrame.GetEncodingName: string;
begin
  case Editor.Strings.Encoding of
    cEncAnsi:
      begin
        Result:= Editor.Strings.EncodingCodepage;
        if Result='' then Result:= cEncNameAnsi;
      end;
    cEncUTF8:
      begin
        if Editor.Strings.SaveSignUtf8 then
          Result:= cEncNameUtf8_WithBom
        else
          Result:= cEncNameUtf8_NoBom;
      end;
    cEncWideLE:
      begin
        if Editor.Strings.SaveSignWide then
          Result:= cEncNameUtf16LE_WithBom
        else
          Result:= cEncNameUtf16LE_NoBom;
      end;
    cEncWideBE:
      begin
        if Editor.Strings.SaveSignWide then
          Result:= cEncNameUtf16BE_WithBom
        else
          Result:= cEncNameUtf16BE_NoBom;
      end;
    else
      Result:= '?';
  end;
end;

function TEditorFrame.GetLineEnds: TATLineEnds;
begin
  Result:= Ed1.Strings.Endings;
end;

function TEditorFrame.GetNotifEnabled: boolean;
begin
  Result:= FNotif.Timer.Enabled;
end;

function TEditorFrame.GetNotifTime: integer;
begin
  Result:= FNotif.Timer.Interval;
end;

function TEditorFrame.GetPictureScale: integer;
begin
  if Assigned(FImageBox) then
    Result:= FImageBox.ImageZoom
  else
    Result:= 100;
end;

function TEditorFrame.GetReadOnly: boolean;
begin
  Result:= Ed1.ModeReadOnly;
end;

function TEditorFrame.GetTabKeyCollectMarkers: boolean;
begin
  Result:= FTabKeyCollectMarkers and (Editor.Markers.Count>0);
end;

function TEditorFrame.GetUnprintedEnds: boolean;
begin
  Result:= Ed1.OptUnprintedEnds;
end;

function TEditorFrame.GetUnprintedEndsDetails: boolean;
begin
  Result:= Ed1.OptUnprintedEndsDetails;
end;

function TEditorFrame.GetUnprintedShow: boolean;
begin
  Result:= Ed1.OptUnprintedVisible;
end;

function TEditorFrame.GetUnprintedSpaces: boolean;
begin
  Result:= Ed1.OptUnprintedSpaces;
end;

procedure TEditorFrame.SetEncodingName(const Str: string);
begin
  if Str='' then exit;
  if SameText(Str, GetEncodingName) then exit;

  if SameText(Str, cEncNameUtf8_WithBom) then begin Editor.Strings.Encoding:= cEncUTF8; Editor.Strings.SaveSignUtf8:= true; end else
   if SameText(Str, cEncNameUtf8_NoBom) then begin Editor.Strings.Encoding:= cEncUTF8; Editor.Strings.SaveSignUtf8:= false; end else
    if SameText(Str, cEncNameUtf16LE_WithBom) then begin Editor.Strings.Encoding:= cEncWideLE; Editor.Strings.SaveSignWide:= true; end else
     if SameText(Str, cEncNameUtf16LE_NoBom) then begin Editor.Strings.Encoding:= cEncWideLE; Editor.Strings.SaveSignWide:= false; end else
      if SameText(Str, cEncNameUtf16BE_WithBom) then begin Editor.Strings.Encoding:= cEncWideBE; Editor.Strings.SaveSignWide:= true; end else
       if SameText(Str, cEncNameUtf16BE_NoBom) then begin Editor.Strings.Encoding:= cEncWideBE; Editor.Strings.SaveSignWide:= false; end else
        if SameText(Str, cEncNameAnsi) then begin Editor.Strings.Encoding:= cEncAnsi; Editor.Strings.EncodingCodepage:= ''; end else
         if SameText(Str, cEncNameOem) then begin Editor.Strings.Encoding:= cEncAnsi; Editor.Strings.EncodingCodepage:= AppEncodingOem; end else
         begin
           Editor.Strings.Encoding:= cEncAnsi;
           Editor.Strings.EncodingCodepage:= Str;
         end;
end;

procedure TEditorFrame.SetFileName(const AValue: string);
begin
  if SameFileName(FFileName, AValue) then Exit;
  FFileName:= AValue;

  //update Notif obj
  NotifEnabled:= NotifEnabled;
end;

procedure TEditorFrame.SetFileWasBig(AValue: boolean);
begin
  FFileWasBig:= AValue;
  if AValue then
  begin
    Ed1.OptWrapMode:= cWrapOff;
    Ed2.OptWrapMode:= cWrapOff;
    Ed1.OptMicromapVisible:= false;
    Ed2.OptMicromapVisible:= false;
    Ed1.OptMinimapVisible:= false;
    Ed2.OptMinimapVisible:= false;
  end;
end;

procedure TEditorFrame.SetLocked(AValue: boolean);
begin
  if AValue=FLocked then exit;
  FLocked:= AValue;

  if FLocked then
  begin
    Ed1.BeginUpdate;
    Ed2.BeginUpdate;
  end
  else
  begin
    Ed1.EndUpdate;
    Ed2.EndUpdate;
  end;
end;

procedure TEditorFrame.SetModified(AValue: boolean);
begin
  Ed1.Modified:= AValue;
  UpdateModifiedState(false);
end;

procedure TEditorFrame.SetNotifEnabled(AValue: boolean);
begin
  FNotif.Timer.Enabled:= false;
  FNotif.FileName:= '';

  if IsText and AValue and FileExistsUTF8(FileName) then
  begin
    FNotif.FileName:= FileName;
    FNotif.Timer.Enabled:= true;
  end;
end;

procedure TEditorFrame.SetNotifTime(AValue: integer);
begin
  FNotif.Timer.Interval:= AValue;
end;

procedure TEditorFrame.SetPictureScale(AValue: integer);
begin
  if Assigned(FImageBox) then
  begin
    if AValue>0 then
      FImageBox.ImageZoom:= AValue
    else
    if AValue=-1 then
      FImageBox.OptFitToWindow:= true;
  end;
end;

procedure TEditorFrame.SetReadOnly(AValue: boolean);
begin
  Ed1.ModeReadOnly:= AValue;
  Ed2.ModeReadOnly:= AValue;
end;

procedure TEditorFrame.UpdateEds(AUpdateWrapInfo: boolean = false);
begin
  Ed2.OptUnprintedVisible:= Ed1.OptUnprintedVisible;
  Ed2.OptUnprintedSpaces:= Ed1.OptUnprintedSpaces;
  Ed2.OptUnprintedEnds:= Ed1.OptUnprintedEnds;
  Ed2.OptUnprintedEndsDetails:= Ed1.OptUnprintedEndsDetails;

  Ed1.Update(AUpdateWrapInfo);
  Ed2.Update(AUpdateWrapInfo);
end;

function TEditorFrame.GetLexer: TecSyntAnalyzer;
begin
  if Ed1.AdapterForHilite is TATAdapterEControl then
    Result:= Adapter.Lexer
  else
    Result:= nil;
end;

function TEditorFrame.GetLexerLite: TATLiteLexer;
begin
  if Ed1.AdapterForHilite is TATLiteLexer then
    Result:= Ed1.AdapterForHilite as TATLiteLexer
  else
    Result:= nil;
end;

function TEditorFrame.GetLexerName: string;
var
  CurAdapter: TATAdapterHilite;
  an: TecSyntAnalyzer;
begin
  Result:= '';
  CurAdapter:= Ed1.AdapterForHilite;
  if CurAdapter=nil then exit;

  if CurAdapter is TATAdapterEControl then
  begin
    if Adapter=nil then exit;
    an:= Adapter.Lexer;
    if Assigned(an) then
      Result:= an.LexerName;
  end
  else
  if CurAdapter is TATLiteLexer then
  begin
    Result:= (CurAdapter as TATLiteLexer).LexerName+msgLiteLexerSuffix;
  end;
end;

procedure TEditorFrame.SetLexerName(const AValue: string);
var
  SName: string;
  anLite: TATLiteLexer;
begin
  if SEndsWith(AValue, msgLiteLexerSuffix) then
  begin
    SName:= Copy(AValue, 1, Length(AValue)-Length(msgLiteLexerSuffix));
    anLite:= AppManagerLite.FindLexerByName(SName);
    if Assigned(anLite) then
      LexerLite:= anLite
    else
      Lexer:= nil;
  end
  else
  begin
    Lexer:= AppManager.FindLexerByName(AValue);
  end;
end;


function TEditorFrame.LexerNameAtPos(APos: TPoint): string;
var
  CurAdapter: TATAdapterHilite;
  an: TecSyntAnalyzer;
begin
  Result:= '';
  CurAdapter:= Ed1.AdapterForHilite;
  if CurAdapter=nil then exit;

  if CurAdapter is TATAdapterEControl then
  begin
    an:= Adapter.LexerAtPos(APos);
    if Assigned(an) then
      Result:= an.LexerName;
  end
  else
  if CurAdapter is TATLiteLexer then
    Result:= LexerName;
end;

procedure TEditorFrame.SetSplitHorz(AValue: boolean);
var
  al: TAlign;
begin
  if not IsText then exit;
  FSplitHorz:= AValue;

  if FSplitHorz then al:= alBottom else al:= alRight;
  Splitter.Align:= al;
  Ed2.Align:= al;

  SplitPos:= SplitPos;
end;

procedure TEditorFrame.SetSplitPos(AValue: double);
const
  cMin = 10;
begin
  if not IsText then exit;
  FSplitPos:= AValue;

  if FSplitHorz then
  begin
    Ed2.Height:= Max(cMin, trunc(FSplitPos*Height));
    Splitter.Top:= 0;
  end
  else
  begin
    Ed2.Width:= Max(cMin, trunc(FSplitPos*Width));
    Splitter.Left:= 0;
  end;
end;

procedure TEditorFrame.SetSplitted(AValue: boolean);
begin
  if not IsText then exit;

  FSplitted:= AValue;
  Ed2.Visible:= AValue;
  Splitter.Visible:= AValue;

  if AValue then
  begin
    SplitPos:= SplitPos;
    Ed2.Strings:= Ed1.Strings;
  end
  else
  begin
    Ed2.Strings:= nil;
  end;

  Ed2.Update(true);
end;

procedure TEditorFrame.EditorOnChange1(Sender: TObject);
begin
  EditorOnChangeCommon(Sender);

  if Splitted then
  begin
    Ed2.UpdateIncorrectCaretPositions;
    Ed2.Update(true);
  end;

  DoPyEvent(Editor, cEventOnChange, []);

  TimerChange.Enabled:= false;
  TimerChange.Interval:= UiOps.PyChangeSlow;
  TimerChange.Enabled:= true;
end;

procedure TEditorFrame.EditorOnChange2(Sender: TObject);
begin
  EditorOnChangeCommon(Sender);

  Ed1.UpdateIncorrectCaretPositions;
  Ed1.Update(true);
end;

procedure TEditorFrame.UpdateModifiedState(AWithEvent: boolean=true);
begin
  if FModified<>Ed1.Modified then
  begin
    FModified:= Ed1.Modified;
    if FModified then
      DoClearPreviewTabState;
    DoOnChangeCaption;

    if AWithEvent then
      DoPyEvent(Editor, cEventOnState, [IntToStr(EDSTATE_MODIFIED)]);
  end;

  DoOnUpdateStatus;
end;

procedure TEditorFrame.EditorOnChangeCommon(Sender: TObject);
begin
  UpdateModifiedState;
end;

procedure TEditorFrame.EditorOnEnter(Sender: TObject);
begin
  if Assigned(FOnFocusEditor) then
    FOnFocusEditor(Editor);

  DoPyEvent(Sender as TATSynEdit, cEventOnFocus, []);

  FActivationTime:= GetTickCount64;
end;

function _GetPairForCloseBracket(ch: char): char;
begin
  case ch of
    ')': Result:= '(';
    ']': Result:= '[';
    '}': Result:= '{';
    '"': Result:= '"';
    '''': Result:= '''';
    '`': Result:= '`';
    else Result:= #0;
  end;
end;

procedure TEditorFrame.EditorOnCommand(Sender: TObject; ACmd: integer;
  const AText: string; var AHandled: boolean);
var
  Ed: TATSynEdit;
  Caret: TATCaretItem;
  Str: atString;
  ch: char;
begin
  Ed:= Sender as TATSynEdit;
  if Ed.Carets.Count=0 then exit;
  Caret:= Ed.Carets[0];

  case ACmd of
    cCommand_TextInsert:
      begin
        //improve auto-closing brackets, avoid duplicate ')' after '('
        if Ed.Strings.IsIndexValid(Caret.PosY) then
          if Length(AText)=1 then
          begin
            ch:= _GetPairForCloseBracket(AText[1]);
            if (ch<>#0) and (Pos(ch, UiOps.AutoCloseBrackets)>0) then
            begin
              Str:= Ed.Strings.Lines[Caret.PosY];
              if (Caret.PosX>0) and (Caret.PosX<Length(Str)) then
                if Copy(Str, Caret.PosX, 2) = ch+AText then
                begin
                  Ed.DoCommand(cCommand_KeyRight);
                  AHandled:= true;
                  exit;
                end;
            end;
          end;
      end;

    cCommand_KeyTab,
    cCommand_KeyEnter,
    cCommand_TextDeleteLine,
    cCommand_TextDeleteToLineBegin,
    cCommand_KeyUp,
    cCommand_KeyUp_Sel,
    cCommand_KeyDown,
    cCommand_KeyDown_Sel,
    cCommand_KeyLeft,
    cCommand_KeyLeft_Sel,
    cCommand_KeyRight,
    cCommand_KeyRight_Sel,
    cCommand_KeyHome,
    cCommand_KeyHome_Sel,
    cCommand_KeyEnd,
    cCommand_KeyEnd_Sel,
    cCommand_TextDeleteWordNext,
    cCommand_TextDeleteWordPrev:
      begin
        FTextCharsTyped:= 0;
      end;
  end;

  if Assigned(FOnEditorCommand) then
    FOnEditorCommand(Sender, ACmd, AText, AHandled);
end;

procedure TEditorFrame.EditorOnCommandAfter(Sender: TObject; ACommand: integer;
  const AText: string);
var
  Ed: TATSynEdit;
  Caret: TATCaretItem;
  SLexerName: string;
  bWordChar, bIdentChar: boolean;
begin
  Ed:= Sender as TATSynEdit;
  if Ed.Carets.Count<>1 then exit;
  Caret:= Ed.Carets[0];
  if not Ed.Strings.IsIndexValid(Caret.PosY) then exit;

// try
  //some commands affect FTextCharsTyped
  if (ACommand=cCommand_KeyBackspace) then
  begin
    if FTextCharsTyped>0 then
      Dec(FTextCharsTyped);
    exit;
  end;

  //autoshow autocompletion
  if (ACommand=cCommand_TextInsert) and
    (Length(AText)=1) then
  begin
    //autoshow by trigger chars
    if (UiOps.AutocompleteTriggerChars<>'') and
      (Pos(AText[1], UiOps.AutocompleteTriggerChars)>0) then
    begin
      FTextCharsTyped:= 0;
      Ed.DoCommand(cmd_AutoComplete);
      exit;
    end;

    //other conditions need word-char
    bWordChar:= IsCharWordInIdentifier(AText[1]);
    if not bWordChar then
    begin
      FTextCharsTyped:= 0;
      exit;
    end;

    SLexerName:= LexerNameAtPos(Point(Caret.PosX, Caret.PosY));

    //autoshow for HTML
    if UiOps.AutocompleteHtml and (Pos('HTML', SLexerName)>0) then
    begin
      if Ed.Strings.LineSub(Caret.PosY, Caret.PosX-1, 1)='<' then
        Ed.DoCommand(cmd_AutoComplete);
      exit;
    end;

    //autoshow for CSS
    if UiOps.AutocompleteCss and (SLexerName='CSS') then
    begin
      if EditorIsAutocompleteCssPosition(Ed, Caret.PosX-1, Caret.PosY) then
        Ed.DoCommand(cmd_AutoComplete);
      exit;
    end;

    //autoshow for others, when typed N chars
    if (UiOps.AutocompleteAutoshowCharCount>0) then
    begin
      //ignore if number typed
      bIdentChar:= bWordChar and not IsCharDigit(AText[1]);
      if (FTextCharsTyped=0) and (not bIdentChar) then exit;

      Inc(FTextCharsTyped);
      if FTextCharsTyped=UiOps.AutocompleteAutoshowCharCount then
      begin
        FTextCharsTyped:= 0;
        Ed.DoCommand(cmd_AutoComplete);
        exit;
      end;
    end
    else
      FTextCharsTyped:= 0;
  end;
 //finally
 // Application.MainForm.Caption:=
 //   'char: '+IfThen(AText<>'', AText[1])+
 //   ', count: '+Inttostr(FTextCharsTyped);
 //end;

  if Ed.LastCommandChangedLines>0 then
    if Assigned(FOnMsgStatus) then
      FOnMsgStatus(Self, Format(msgStatusChangedLinesCount, [Ed.LastCommandChangedLines]));
end;

procedure TEditorFrame.EditorOnClickDouble(Sender: TObject; var AHandled: boolean);
var
  Str: string;
begin
  Str:= DoPyEvent(Sender as TATSynEdit, cEventOnClickDbl,
          ['"'+ConvertShiftStateToString(KeyboardStateToShiftState)+'"']);
  AHandled:= Str=cPyFalse;
end;

procedure TEditorFrame.EditorOnClickMicroMap(Sender: TObject; AX, AY: integer);
var
  Ed: TATSynEdit;
begin
  Ed:= Sender as TATSynEdit;

  AY:= AY * Ed.Strings.Count div Ed.ClientHeight;

  Ed.DoGotoPos(
    Point(0, AY),
    Point(-1, -1),
    UiOps.FindIndentHorz,
    UiOps.FindIndentVert,
    true,
    true
    );
end;

procedure TEditorFrame.EditorOnClickMiddle(Sender: TObject; var AHandled: boolean);
begin
  AHandled:= false;
  if EditorOps.OpMouseMiddleClickPaste then
  begin
    AHandled:= true;
    (Sender as TATSynEdit).DoCommand(cmd_MouseClickAtCursor);
    (Sender as TATSynEdit).DoCommand(cCommand_ClipboardAltPaste); //uses PrimarySelection:TClipboard
    exit;
  end;
end;

procedure TEditorFrame.EditorOnClickGap(Sender: TObject;
  AGapItem: TATSynGapItem; APos: TPoint);
var
  Ed: TATSynEdit;
begin
  if not Assigned(AGapItem) then exit;
  Ed:= Sender as TATSynEdit;

  //Str:=
  DoPyEvent(Ed, cEventOnClickGap, [
    '"'+ConvertShiftStateToString(KeyboardStateToShiftState)+'"',
    IntToStr(AGapItem.LineIndex),
    IntToStr(AGapItem.Tag),
    IntToStr(AGapItem.Bitmap.Width),
    IntToStr(AGapItem.Bitmap.Height),
    IntToStr(APos.X),
    IntToStr(APos.Y)
    ]);
  //AHandled:= Str=cPyFalse;
end;


procedure TEditorFrame.DoOnResize;
begin
  inherited;
  SplitPos:= SplitPos;
end;

procedure TEditorFrame.InitEditor(var ed: TATSynEdit);
begin
  ed:= TATSynEdit.Create(Self);
  ed.Parent:= Self;

  ed.DoubleBuffered:= UiOps.DoubleBuffered;
  ed.AutoAdjustLayout(lapDefault, 100, UiOps.ScreenScale, 1, 1);

  ed.Font.Name:= EditorOps.OpFontName;
  ed.FontItalic.Name:= EditorOps.OpFontName_i;
  ed.FontBold.Name:= EditorOps.OpFontName_b;
  ed.FontBoldItalic.Name:= EditorOps.OpFontName_bi;

  ed.Font.Size:= EditorOps.OpFontSize;
  ed.FontItalic.Size:= EditorOps.OpFontSize_i;
  ed.FontBold.Size:= EditorOps.OpFontSize_b;
  ed.FontBoldItalic.Size:= EditorOps.OpFontSize_bi;

  ed.Font.Quality:= EditorOps.OpFontQuality;

  ed.BorderStyle:= bsNone;
  ed.Keymap:= AppKeymap;
  ed.TabStop:= false;
  ed.OptUnprintedVisible:= EditorOps.OpUnprintedShow;
  ed.OptRulerVisible:= EditorOps.OpRulerShow;
  ed.OptScrollbarsNew:= true;

  ed.OnClick:= @EditorOnClick;
  ed.OnClickDouble:= @EditorOnClickDouble;
  ed.OnClickMiddle:= @EditorOnClickMiddle;
  ed.OnClickMoveCaret:= @EditorClickMoveCaret;
  ed.OnClickEndSelect:= @EditorClickEndSelect;
  ed.OnClickGap:= @EditorOnClickGap;
  ed.OnClickMicromap:= @EditorOnClickMicroMap;
  ed.OnEnter:= @EditorOnEnter;
  ed.OnChangeState:= @EditorOnChangeCommon;
  ed.OnChangeCaretPos:= @EditorOnChangeCaretPos;
  ed.OnCommand:= @EditorOnCommand;
  ed.OnCommandAfter:= @EditorOnCommandAfter;
  ed.OnClickGutter:= @EditorOnClickGutter;
  ed.OnCalcBookmarkColor:= @EditorOnCalcBookmarkColor;
  ed.OnDrawBookmarkIcon:= @EditorOnDrawBookmarkIcon;
  ed.OnDrawLine:= @EditorOnDrawLine;
  ed.OnKeyDown:= @EditorOnKeyDown;
  ed.OnKeyUp:= @EditorOnKeyUp;
  ed.OnDrawMicromap:= @EditorDrawMicromap;
  ed.OnPaste:=@EditorOnPaste;
  ed.OnScroll:=@EditorOnScroll;
  ed.OnHotspotEnter:=@EditorOnHotspotEnter;
  ed.OnHotspotExit:=@EditorOnHotspotExit;
end;

constructor TEditorFrame.Create(AOwner: TComponent; AApplyCentering: boolean);
begin
  inherited Create(AOwner);

  FFileName:= '';
  FModified:= false;
  FActiveSecondaryEd:= false;
  FTabColor:= clNone;
  Inc(FLastTabId);
  FTabId:= FLastTabId;
  FTabImageIndex:= -1;
  FNotInRecents:= false;
  FEnabledCodeTree:= true;
  FCodetreeFilterHistory:= TStringList.Create;
  CachedTreeview:= TTreeView.Create(Self);

  InitEditor(Ed1);
  InitEditor(Ed2);

  Ed2.Visible:= false;
  Splitter.Visible:= false;
  Ed1.Align:= alClient;
  Ed2.Align:= alBottom;

  Ed1.OnChange:= @EditorOnChange1;
  Ed2.OnChange:= @EditorOnChange2;
  Ed1.EditorIndex:= 0;
  Ed2.EditorIndex:= 1;

  FSplitHorz:= true;
  FSplitPos:= 0.5;
  Splitted:= false;

  Adapter:= TATAdapterEControl.Create(Self);
  Adapter.DynamicHiliteEnabled:= EditorOps.OpLexerDynamicHiliteEnabled;
  Adapter.DynamicHiliteMaxLines:= EditorOps.OpLexerDynamicHiliteMaxLines;
  Adapter.EnabledLineSeparators:= EditorOps.OpLexerLineSeparators;

  Adapter.AddEditor(Ed1);
  Adapter.AddEditor(Ed2);

  //load options
  EditorApplyOps(Ed1, EditorOps, true, true, AApplyCentering);
  EditorApplyOps(Ed2, EditorOps, true, true, AApplyCentering);
  EditorApplyTheme(Ed1);
  EditorApplyTheme(Ed2);

  //newdoc props
  Ed1.Strings.Endings:= TATLineEnds(UiOps.NewdocEnds);
  Ed1.Strings.DoClearUndo;
  Ed1.Strings.Modified:= false;
  Ed1.Strings.EncodingDetectDefaultUtf8:= UiOps.DefaultEncUtf8;

  EncodingName:= AppEncodingShortnameToFullname(UiOps.NewdocEnc);

  //passing lite lexer - crashes (can't solve), so disabled
  if not SEndsWith(UiOps.NewdocLexer, msgLiteLexerSuffix) then
    LexerName:= UiOps.NewdocLexer;

  FNotif:= TATFileNotif.Create(Self);
  FNotif.Timer.Interval:= 1000;
  FNotif.Timer.Enabled:= false;
  FNotif.OnChanged:= @NotifChanged;
end;

destructor TEditorFrame.Destroy;
begin
  if Assigned(FBin) then
  begin
    FBin.OpenStream(nil);
    FreeAndNil(FBinStream);
    FreeAndNil(FBin);
  end;

  Ed1.AdapterForHilite:= nil;
  Ed2.AdapterForHilite:= nil;

  if not Application.Terminated then //prevent crash on exit
    DoPyEvent(Editor, cEventOnClose, []);

  FreeAndNil(FCodetreeFilterHistory);

  inherited;
end;

function TEditorFrame.Editor: TATSynEdit;
begin
  if FActiveSecondaryEd then
    Result:= Ed2
  else
    Result:= Ed1;
end;

function TEditorFrame.Editor2: TATSynEdit;
begin
  if not FActiveSecondaryEd then
    Result:= Ed2
  else
    Result:= Ed1;
end;

function TEditorFrame.IsEmpty: boolean;
var
  Str: TATStrings;
begin
  //dont check Modified here better
  Str:= Ed1.Strings;
  Result:=
    (FileName='') and
    ((Str.Count=0) or ((Str.Count=1) and (Str.Lines[0]='')));
end;

procedure TEditorFrame.ApplyTheme;
begin
  EditorApplyTheme(Editor);
  EditorApplyTheme(Editor2);
  Ed1.Update;
  Ed2.Update;

  if Assigned(FBin) then
  begin
    ViewerApplyTheme(FBin);
    FBin.Redraw();
  end;
end;

function TEditorFrame.IsText: boolean;
begin
  Result:=
    not IsPicture and
    not IsBinary;
end;

function TEditorFrame.IsPicture: boolean;
begin
  Result:= Assigned(FImageBox);
end;

function TEditorFrame.IsBinary: boolean;
begin
  Result:= Assigned(FBin);
end;


procedure TEditorFrame.SetLexer(an: TecSyntAnalyzer);
var
  an2: TecSyntAnalyzer;
begin
  if IsFileTooBigForLexer(FileName) then
  begin
    Adapter.Lexer:= nil;
    exit
  end;

  if Assigned(an) then
  begin
    Ed1.AdapterForHilite:= Adapter;
    Ed2.AdapterForHilite:= Adapter;
    if not DoApplyLexerStylesMap(an, an2) then
      DoDialogLexerStylesMap(an2);
  end
  else
  begin
    Ed1.Fold.Clear;
    Ed2.Fold.Clear;
    Ed1.Update;
    Ed2.Update;
  end;

  Adapter.Lexer:= an;
end;

procedure TEditorFrame.SetLexerLite(an: TATLiteLexer);
begin
  Adapter.Lexer:= nil;

  Ed1.AdapterForHilite:= an;
  Ed2.AdapterForHilite:= an;
  Ed1.Update;
  Ed2.Update;

  //py event on_lexer
  Adapter.OnLexerChange(Adapter);
end;

procedure TEditorFrame.DoFileOpen_AsBinary(const fn: string; AMode: TATBinHexMode);
begin
  TabCaption:= ExtractFileName(fn);
  FFileName:= fn;

  Ed1.Hide;
  Ed2.Hide;
  Splitter.Hide;
  ReadOnly:= true;

  if Assigned(FBin) then
    FBin.OpenStream(nil);
  if Assigned(FBinStream) then
    FreeAndNil(FBinStream);
  FBinStream:= TFileStreamUTF8.Create(fn, fmOpenRead or fmShareDenyWrite);

  if not Assigned(FBin) then
  begin
    FBin:= TATBinHex.Create(Self);
    FBin.OnKeyDown:= @BinaryOnKeyDown;
    FBin.OnScroll:= @BinaryOnScroll;
    FBin.OnOptionsChange:= @BinaryOnScroll;
    FBin.OnSearchProgress:= @BinaryOnProgress;
    FBin.Parent:= Self;
    FBin.Align:= alClient;
    FBin.BorderStyle:= bsNone;
    FBin.TextGutter:= true;
    FBin.TextWidth:= UiOps.ViewerBinaryWidth;
    FBin.TextPopupCommands:= [vpCmdCopy, vpCmdCopyHex, vpCmdSelectAll];
    FBin.TextPopupCaption[vpCmdCopy]:= msgEditCopy;
    FBin.TextPopupCaption[vpCmdCopyHex]:= msgEditCopy+' (hex)';
    FBin.TextPopupCaption[vpCmdSelectAll]:= msgEditSelectAll;
  end;

  ViewerApplyTheme(FBin);
  FBin.Mode:= AMode;
  FBin.OpenStream(FBinStream);

  if Visible and FBin.Visible then
    FBin.SetFocus;

  FrameResize(Self);
  DoOnChangeCaption;
end;


procedure TEditorFrame.DoFileOpen_AsPicture(const fn: string);
begin
  TabCaption:= ExtractFileName(fn);
  FFileName:= '?';

  Ed1.Hide;
  Ed2.Hide;
  Splitter.Hide;
  ReadOnly:= true;

  FImageBox:= TATImageBox.Create(Self);
  FImageBox.Parent:= Self;
  FImageBox.Align:= alClient;
  FImageBox.BorderStyle:= bsNone;
  FImageBox.OptFitToWindow:= true;
  FImageBox.OnScroll:= @DoImageboxScroll;
  try
    FImageBox.LoadFromFile(fn);
    FImageFilename:= fn;
  except
    FImageFilename:= '';
  end;

  FrameResize(Self);
  DoOnChangeCaption;
end;

procedure TEditorFrame.DoImageboxScroll(Sender: TObject);
begin
  DoOnUpdateStatus;
end;


procedure TEditorFrame.DoDeactivatePictureMode;
begin
  if Assigned(FImageBox) then
  begin
    FreeAndNil(FImageBox);
    Ed1.Show;
    ReadOnly:= false;
  end;
end;

procedure TEditorFrame.DoDeactivateViewerMode;
begin
  if Assigned(FBin) then
  begin
    FBin.OpenStream(nil);
    FreeAndNil(FBin);
    Ed1.Show;
    ReadOnly:= false;
  end;
end;

procedure TEditorFrame.DoFileOpen(const fn: string; AAllowLoadHistory, AAllowErrorMsgBox: boolean;
  AOpenMode: TAppOpenMode);
begin
  if not FileExistsUTF8(fn) then Exit;
  SetLexer(nil);

  case AOpenMode of
    cOpenModeViewText:
      begin
        DoFileOpen_AsBinary(fn, vbmodeText);
        exit;
      end;
    cOpenModeViewBinary:
      begin
        DoFileOpen_AsBinary(fn, vbmodeBinary);
        exit;
      end;
    cOpenModeViewHex:
      begin
        DoFileOpen_AsBinary(fn, vbmodeHex);
        exit;
      end;
    cOpenModeViewUnicode:
      begin
        DoFileOpen_AsBinary(fn, vbmodeUnicode);
        exit;
      end;
  end;

  if IsFilenameListedInExtensionList(fn, UiOps.PictureTypes) then
  begin
    DoFileOpen_AsPicture(fn);
    exit;
  end;

  DoDeactivatePictureMode;
  DoDeactivateViewerMode;

  try
    Editor.LoadFromFile(fn);
    FFileName:= fn;
    TabCaption:= ExtractFileName_Fixed(FFileName);
      //_fixed to show ":streamname" at end
  except
    if AAllowErrorMsgBox then
      MsgBox(msgCannotOpenFile+#13+fn, MB_OK or MB_ICONERROR);

    EditorClear(Editor);
    TabCaption:= GetUntitledCaption;
    exit
  end;

  //turn off opts for huge files
  FileWasBig:= Editor.Strings.Count>EditorOps.OpWrapEnabledMaxLines;

  DoLexerFromFilename(fn);
  if AAllowLoadHistory then
    DoLoadHistory;
  UpdateReadOnlyFromFile;

  NotifEnabled:= UiOps.NotifEnabled;
end;

procedure TEditorFrame.UpdateReadOnlyFromFile;
begin
  if IsFileReadonly(FileName) then
  begin
    ReadOnly:= true;
    ReadOnlyFromFile:= true;
  end;
end;

function TEditorFrame.DoFileSave(ASaveAs: boolean): boolean;
var
  an: TecSyntAnalyzer;
  attr: integer;
  PrevEnabled: boolean;
  NameCounter: integer;
  NameTemp: string;
begin
  Result:= false;
  if not IsText then exit(true); //disable saving, but close
  if DoPyEvent(Editor, cEventOnSaveBefore, [])=cPyFalse then exit(true); //disable saving, but close

  if ASaveAs or (FFileName='') then
  begin
    an:= Lexer;
    if Assigned(an) then
    begin
      SaveDialog.DefaultExt:= DoGetLexerDefaultExt(an);
      SaveDialog.Filter:= DoGetLexerFileFilter(an, msgAllFiles);
    end
    else
    begin
      SaveDialog.DefaultExt:= '.txt';
      SaveDialog.Filter:= '';
    end;

    if FFileName='' then
    begin
      //get first free filename: new.txt, new1.txt, new2.txt, ...
      NameCounter:= 0;
      repeat
        NameTemp:= SaveDialog.InitialDir+DirectorySeparator+
                   'new'+IfThen(NameCounter>0, IntToStr(NameCounter))+
                   SaveDialog.DefaultExt; //DefaultExt with dot
        if not FileExistsUTF8(NameTemp) then
        begin
          SaveDialog.FileName:= ExtractFileName(NameTemp);
          Break
        end;
        Inc(NameCounter);
      until false;
    end
    else
    begin
      SaveDialog.FileName:= ExtractFileName(FFileName);
      SaveDialog.InitialDir:= ExtractFileDir(FFileName);
    end;

    if not SaveDialog.Execute then
      exit(false);

    if OnCheckFilenameOpened(SaveDialog.FileName) then
    begin
      MsgBox(
        msgStatusFilenameAlreadyOpened+#10+
        ExtractFileName(SaveDialog.FileName)+#10#10+
        msgStatusNeedToCloseTabSavedOrDup, MB_OK or MB_ICONWARNING);
      exit;
    end;

    FFileName:= SaveDialog.FileName;
    DoLexerFromFilename(FFileName);

    //add to recents saved-as file:
    if Assigned(FOnAddRecent) then
      FOnAddRecent(Self);
  end;

  PrevEnabled:= NotifEnabled;
  NotifEnabled:= false;

  while true do
  try
    FFileAttrPrepare(FFileName, attr);
    Editor.BeginUpdate;
    try
      Editor.SaveToFile(FFileName);
    finally
      Editor.EndUpdate;
    end;
    FFileAttrRestore(FFileName, attr);
    Break;
  except
    if MsgBox(msgCannotSaveFile+#10+FFileName,
      MB_RETRYCANCEL or MB_ICONERROR) = IDCANCEL then
      Exit(false);
  end;

  NotifEnabled:= PrevEnabled;

  Editor.OnChange(Editor); //modified
  if not TabCaptionFromApi then
    TabCaption:= ExtractFileName(FFileName);

  DoPyEvent(Editor, cEventOnSaveAfter, []);
  if Assigned(FOnSaveFile) then
    FOnSaveFile(Self);
  Result:= true;
end;

procedure TEditorFrame.DoFileReload_DisableDetectEncoding;
begin
  if FileName='' then exit;
  if Modified then
    if MsgBox(
      Format(msgConfirmReopenModifiedTab, [ExtractFileName(FileName)]),
      MB_OKCANCEL or MB_ICONWARNING
      ) <> ID_OK then exit;

  Editor.Strings.EncodingDetect:= false;
  Editor.Strings.LoadFromFile(FileName);
  Editor.Strings.EncodingDetect:= true;
  UpdateEds(true);
end;

procedure TEditorFrame.DoFileReload;
var
  PrevCaretX, PrevCaretY: integer;
  PrevTail: boolean;
  Mode: TAppOpenMode;
begin
  if FileName='' then exit;

  //remember props
  //PrevLexer:= LexerName;
  PrevCaretX:= 0;
  PrevCaretY:= 0;

  if Editor.Carets.Count>0 then
    with Editor.Carets[0] do
      begin
        PrevCaretX:= PosX;
        PrevCaretY:= PosY;
      end;

  PrevTail:= UiOps.ReloadFollowTail and
    (Editor.Strings.Count>0) and
    (PrevCaretY=Editor.Strings.Count-1);

  Mode:= cOpenModeEditor;
  if IsBinary then
    case FBin.Mode of
      vbmodeText:
        Mode:= cOpenModeViewText;
      vbmodeBinary:
        Mode:= cOpenModeViewBinary;
      vbmodeHex:
        Mode:= cOpenModeViewHex;
      vbmodeUnicode:
        Mode:= cOpenModeViewUnicode;
      else
        Mode:= cOpenModeViewHex;
    end;

  //reopen
  DoSaveHistory;
  DoFileOpen(FileName, true{AllowLoadHistory}, false, Mode);
  if Editor.Strings.Count=0 then exit;

  //restore props
  //LexerName:= PrevLexer;
  PrevCaretY:= Min(PrevCaretY, Editor.Strings.Count-1);
  if PrevTail then
  begin
    PrevCaretX:= 0;
    PrevCaretY:= Editor.Strings.Count-1;
  end;

  Application.ProcessMessages; //for DoGotoPos

  Editor.DoGotoPos(
    Point(PrevCaretX, PrevCaretY),
    Point(-1, -1),
    1,
    1, //indentVert must be >0
    true,
    false
    );

  OnUpdateStatus(Self);
end;

procedure TEditorFrame.SetLineEnds(Value: TATLineEnds);
begin
  if GetLineEnds=Value then Exit;
  Ed1.Strings.Endings:= Value;
  Ed1.Update;
  Ed2.Update;

  EditorOnChangeCommon(Self);
end;

procedure TEditorFrame.SetUnprintedShow(AValue: boolean);
begin
  Ed1.OptUnprintedVisible:= AValue;
  UpdateEds;
end;

procedure TEditorFrame.SetUnprintedSpaces(AValue: boolean);
begin
  Ed1.OptUnprintedSpaces:= AValue;
  UpdateEds;
end;

procedure TEditorFrame.SetUnprintedEnds(AValue: boolean);
begin
  Ed1.OptUnprintedEnds:= AValue;
  UpdateEds;
end;

procedure TEditorFrame.SetUnprintedEndsDetails(AValue: boolean);
begin
  Ed1.OptUnprintedEndsDetails:= AValue;
  UpdateEds;
end;

procedure TEditorFrame.EditorOnClickGutter(Sender: TObject; ABand, ALine: integer);
var
  Ed: TATSynEdit;
  State: TShiftState;
  StateString: string;
begin
  Ed:= Sender as TATSynEdit;
  State:= KeyboardStateToShiftState;
  StateString:= ConvertShiftStateToString(State);

  if DoPyEvent(Ed, cEventOnClickGutter, [
    '"'+StateString+'"',
    IntToStr(ALine),
    IntToStr(ABand)
    ]) = cPyFalse then exit;

  if ABand=Ed.GutterBandBm then
    ed.BookmarkToggleForLine(ALine, 1, '', false, true, 0);
end;

procedure TEditorFrame.EditorOnDrawBookmarkIcon(Sender: TObject; C: TCanvas; ALineNum: integer;
  const ARect: TRect);
var
  Ed: TATSynEdit;
  r: TRect;
  dx: integer;
  index, kind: integer;
begin
  r:= ARect;
  if r.Left>=r.Right then exit;

  Ed:= Sender as TATSynEdit;
  index:= Ed.Strings.Bookmarks.Find(ALineNum);
  if index<0 then exit;

  kind:= Ed.Strings.Bookmarks[index].Kind;
  if kind<=1 then
  begin
    c.brush.color:= GetAppColor('EdBookmarkIcon');
    c.pen.color:= c.brush.color;
    inc(r.top, 1);
    inc(r.left, 4);
    dx:= (r.bottom-r.top) div 2-1;
    c.Polygon([Point(r.left, r.top), Point(r.left+dx, r.top+dx), Point(r.left, r.top+2*dx)]);
  end
  else
  if (kind>=Low(AppBookmarkSetup)) and (kind<=High(AppBookmarkSetup)) then
  begin
    AppBookmarkImagelist.Draw(c, r.left, r.top,
      AppBookmarkSetup[kind].ImageIndex);
  end;
end;


function TEditorFrame.GetCommentString: string;
var
  an: TecSyntAnalyzer;
begin
  Result:= '';
  an:= Adapter.Lexer;
  if Assigned(an) then
    Result:= an.LineComment;
end;

function TEditorFrame.GetEnabledFolding: boolean;
begin
  Result:= Editor.OptFoldEnabled;
end;

procedure TEditorFrame.DoOnChangeCaption;
begin
  if Assigned(FOnChangeCaption) then
    FOnChangeCaption(Self);
end;

procedure TEditorFrame.DoRestoreFolding;
var
  S: string;
begin
  if FFoldTodo<>'' then
  begin
    S:= FFoldTodo;
    FFoldTodo:= '';
    EditorSetFoldString(Editor, S);
  end;

  if FTopLineTodo>0 then
  begin
    Editor.LineTop:= FTopLineTodo;
    FTopLineTodo:= 0;
  end;
end;

procedure TEditorFrame.DoMacroStart;
begin
  FMacroRecord:= true;
  FMacroString:= '';
end;

procedure TEditorFrame.DoMacroStop(ACancel: boolean);
begin
  FMacroRecord:= false;
  if ACancel then
    FMacroString:= '';
end;

procedure TEditorFrame.DoOnUpdateStatus;
begin
  if Assigned(FOnUpdateStatus) then
    FOnUpdateStatus(Self);
end;

procedure TEditorFrame.EditorClickMoveCaret(Sender: TObject; APrevPnt,
  ANewPnt: TPoint);
begin
  if Assigned(FOnEditorClickMoveCaret) then
    FOnEditorClickMoveCaret(Self, APrevPnt, ANewPnt);
end;

procedure TEditorFrame.EditorDrawMicromap(Sender: TObject; C: TCanvas;
  const ARect: TRect);
const
  cTagOccurrences = 101; //see plugin Hilite Occurrences
  cTagSpellChecker = 105; //see plugin SpellChecker
var
  NScale: double;
//
  function GetItemRect(NLine1, NLine2: integer; ALeft: boolean): TRect;
  begin
    if ALeft then
    begin
      Result.Left:= ARect.Left;
      Result.Right:= Result.Left + EditorOps.OpMicromapWidthSmall;
    end
    else
    begin
      Result.Right:= ARect.Right;
      Result.Left:= Result.Right - EditorOps.OpMicromapWidthSmall;
    end;
    Result.Top:= ARect.Top+Trunc(NLine1*NScale);
    Result.Bottom:= Max(Result.Top+2, ARect.Top+Trunc((NLine2+1)*NScale));
  end;
//
var
  Ed: TATSynEdit;
  NColor: TColor;
  Caret: TATCaretItem;
  State: TATLineState;
  Mark: TATMarkerItem;
  NColorSelected, NColorOccur, NColorSpell: TColor;
  R1: TRect;
  NLine1, NLine2, i: integer;
  Obj: TATLinePartClass;
begin
  Ed:= Sender as TATSynEdit;
  if Ed.Strings.Count=0 then exit;
  NScale:= (ARect.Bottom-ARect.Top) / Ed.Strings.Count;

  C.Brush.Color:= GetAppColor('EdMicromapBg');
  C.FillRect(ARect);

  R1:= GetItemRect(Ed.LineTop, Ed.LineBottom, true);
  R1.Right:= ARect.Right;

  C.Brush.Color:= GetAppColor('EdMicromapViewBg');
  C.FillRect(R1);

  NColorSelected:= Ed.Colors.TextSelBG;
  NColorOccur:= GetAppColor('EdMicromapOccur');
  NColorSpell:= GetAppColor('EdMicromapSpell');

  //paint line states
  for i:= 0 to Ed.Strings.Count-1 do
  begin
    State:= Ed.Strings.LinesState[i];
    case State of
      cLineStateNone: Continue;
      cLineStateAdded: NColor:= Ed.Colors.StateAdded;
      cLineStateChanged: NColor:= Ed.Colors.StateChanged;
      cLineStateSaved: NColor:= Ed.Colors.StateSaved;
      else Continue;
    end;
    C.Brush.Color:= NColor;
    C.FillRect(GetItemRect(i, i, true));
  end;

  //paint selections
  C.Brush.Color:= NColorSelected;
  for i:= 0 to Ed.Carets.Count-1 do
  begin
    Caret:= Ed.Carets[i];
    Caret.GetSelLines(NLine1, NLine2, false);
    if NLine1<0 then Continue;
    R1:= GetItemRect(NLine1, NLine2, false);
    C.FillRect(R1);
  end;

  //paint marks for plugins
  for i:= 0 to Ed.Attribs.Count-1 do
  begin
    Mark:= Ed.Attribs[i];
    Obj:= TATLinePartClass(Mark.Ptr);

    case Mark.Tag of
      cTagSpellChecker:
        begin
          C.Brush.Color:= NColorSpell;
          C.FillRect(GetItemRect(Mark.PosY, Mark.PosY, false));
        end;
      cTagOccurrences:
        begin
          C.Brush.Color:= NColorOccur;
          C.FillRect(GetItemRect(Mark.PosY, Mark.PosY, false));
        end;
      else
        begin
          if Obj.ShowOnMap then
          begin
            C.Brush.Color:= Obj.Data.ColorBG;
            C.FillRect(GetItemRect(Mark.PosY, Mark.PosY, false));
          end;
        end;
      end;
  end;
end;

procedure TEditorFrame.EditorClickEndSelect(Sender: TObject; APrevPnt,
  ANewPnt: TPoint);
begin
  if Assigned(FOnEditorClickEndSelect) then
    FOnEditorClickEndSelect(Self, APrevPnt, ANewPnt);
end;


procedure TEditorFrame.DoOnChangeCaretPos;
begin
  if Assigned(FOnEditorChangeCaretPos) then
    FOnEditorChangeCaretPos(Self);
end;


procedure TEditorFrame.DoSaveHistory;
var
  c: TJSONConfig;
  path: string;
  items: TStringlist;
begin
  if FileName='' then exit;
  if UiOps.MaxHistoryFiles<2 then exit;

  c:= TJsonConfig.Create(nil);
  try
    try
      c.Formatted:= true;
      c.Filename:= GetAppPath(cFileOptionsHistoryFiles);
    except
      Showmessage(msgCannotReadConf+#13+c.Filename);
      exit
    end;

    path:= SMaskFilenameSlashes(FileName);
    items:= TStringlist.Create;
    try
      c.DeletePath(path);
      c.EnumSubKeys('/', items);
      while items.Count>=UiOps.MaxHistoryFiles do
      begin
        c.DeletePath('/'+items[0]);
        items.Delete(0);
      end;
    finally
      FreeAndNil(items);
    end;

    DoSaveHistoryEx(c, path);
  finally
    c.Free;
  end;
end;

procedure TEditorFrame.DoSaveHistoryEx(c: TJsonConfig; const path: string);
var
  caret: TATCaretItem;
  items, items2: TStringList;
  bookmark: TATBookmarkItem;
  i: integer;
begin
  c.SetValue(path+cHistory_Lexer, LexerName);
  c.SetValue(path+cHistory_Enc, EncodingName);
  c.SetValue(path+cHistory_Top, Editor.LineTop);
  c.SetValue(path+cHistory_Wrap, Ord(Editor.OptWrapMode));
  if not ReadOnlyFromFile then
    c.SetValue(path+cHistory_RO, ReadOnly);
  c.SetValue(path+cHistory_Ruler, Editor.OptRulerVisible);
  c.SetValue(path+cHistory_Minimap, Editor.OptMinimapVisible);
  c.SetValue(path+cHistory_Micromap, Editor.OptMicromapVisible);
  c.SetValue(path+cHistory_TabSize, Editor.OptTabSize);
  c.SetValue(path+cHistory_TabSpace, Editor.OptTabSpaces);
  c.SetValue(path+cHistory_Unpri, Editor.OptUnprintedVisible);
  c.SetValue(path+cHistory_Unpri_Spaces, Editor.OptUnprintedSpaces);
  c.SetValue(path+cHistory_Unpri_Ends, Editor.OptUnprintedEnds);
  c.SetValue(path+cHistory_Unpri_Detail, Editor.OptUnprintedEndsDetails);
  c.SetValue(path+cHistory_Nums, Editor.Gutter[Editor.GutterBandNum].Visible);
  c.SetValue(path+cHistory_Fold, EditorGetFoldString(Editor));

  if TabColor=clNone then
    c.SetValue(path+cHistory_TabColor, '')
  else
    c.SetValue(path+cHistory_TabColor, ColorToString(TabColor));

  if Editor.Carets.Count>0 then
  begin
    caret:= Editor.Carets[0];
    c.SetValue(path+cHistory_Caret+'/x', caret.PosX);
    c.SetValue(path+cHistory_Caret+'/y', caret.PosY);
    c.SetValue(path+cHistory_Caret+'/x2', caret.EndX);
    c.SetValue(path+cHistory_Caret+'/y2', caret.EndY);
  end;

  items:= TStringList.Create;
  items2:= TStringList.Create;
  try
    for i:= 0 to Editor.Strings.Bookmarks.Count-1 do
    begin
      bookmark:= Editor.Strings.Bookmarks[i];
      //save usual bookmarks and numbered bookmarks (kind=1..10)
      if (bookmark.Kind>10) then Continue;
      items.Add(IntToStr(bookmark.LineNum));
      items2.Add(IntToStr(bookmark.Kind));
    end;
    c.SetValue(path+cHistory_Bookmark, items);
    c.SetValue(path+cHistory_BookmarkKind, items2);
  finally
    FreeAndNil(items2);
    FreeAndNil(items);
  end;
end;

procedure TEditorFrame.DoLoadHistory;
var
  c: TJSONConfig;
begin
  if FileName='' then exit;
  if UiOps.MaxHistoryFiles<2 then exit;

  c:= TJsonConfig.Create(nil);
  try
    try
      c.Formatted:= true;
      c.Filename:= GetAppPath(cFileOptionsHistoryFiles);
    except
      Showmessage(msgCannotReadConf+#13+c.Filename);
      exit
    end;

    DoLoadHistoryEx(c, SMaskFilenameSlashes(FileName));
  finally
    c.Free;
  end;
end;


procedure TEditorFrame.DoLoadHistoryEx(c: TJsonConfig; const path: string);
var
  str, str0: string;
  Caret: TATCaretItem;
  nTop, nKind, i: integer;
  items, items2: TStringlist;
begin
  //file not listed?
  if c.GetValue(path+cHistory_Top, -1)<0 then exit;

  //lexer
  if Lexer=nil then str0:= '' else str0:= Lexer.LexerName;
  str:= c.GetValue(path+cHistory_Lexer, str0);
  if (str<>'') and (str<>str0) then
    LexerName:= str;

  //enc
  str0:= EncodingName;
  str:= c.GetValue(path+cHistory_Enc, str0);
  if str<>str0 then
  begin
    EncodingName:= str;
    //reread in enc
    //but only if not modified (modified means other text is loaded)
    if FileName<>'' then
      if not Editor.Modified then
        Editor.LoadFromFile(FileName);
  end;

  TabColor:= StringToColorDef(c.GetValue(path+cHistory_TabColor, ''), clNone);

  ReadOnly:= c.GetValue(path+cHistory_RO, ReadOnly);
  if not FileWasBig then
  begin
    Editor.OptWrapMode:= TATSynWrapMode(c.GetValue(path+cHistory_Wrap, Ord(Editor.OptWrapMode)));
    Editor.OptMinimapVisible:= c.GetValue(path+cHistory_Minimap, Editor.OptMinimapVisible);
    Editor.OptMicromapVisible:= c.GetValue(path+cHistory_Micromap, Editor.OptMicromapVisible);
  end;
  Editor.OptRulerVisible:= c.GetValue(path+cHistory_Ruler, Editor.OptRulerVisible);
  Editor.OptTabSize:= c.GetValue(path+cHistory_TabSize, Editor.OptTabSize);
  Editor.OptTabSpaces:= c.GetValue(path+cHistory_TabSpace, Editor.OptTabSpaces);
  Editor.OptUnprintedVisible:= c.GetValue(path+cHistory_Unpri, Editor.OptUnprintedVisible);
  Editor.OptUnprintedSpaces:= c.GetValue(path+cHistory_Unpri_Spaces, Editor.OptUnprintedSpaces);
  Editor.OptUnprintedEnds:= c.GetValue(path+cHistory_Unpri_Ends, Editor.OptUnprintedEnds);
  Editor.OptUnprintedEndsDetails:= c.GetValue(path+cHistory_Unpri_Detail, Editor.OptUnprintedEndsDetails);

  nTop:= c.GetValue(path+cHistory_Top, 0);

  if Assigned(Lexer) then
  begin
    //this seems ok: works even for open-file via cmdline
    FFoldTodo:= c.GetValue(path+cHistory_Fold, '');
    //linetop
    FTopLineTodo:= nTop; //restore LineTop after analize done
    Editor.LineTop:= nTop; //scroll immediately
  end
  else
  begin
    //for open-file from app: ok
    //for open via cmdline: not ok (maybe need to do it after form shown? how?)
    Editor.Update(true);
    Application.ProcessMessages;
    Editor.LineTop:= nTop;
  end;

  with Editor.Gutter[Editor.GutterBandNum] do
    Visible:= c.GetValue(path+cHistory_Nums, Visible);

  //caret
  if Editor.Carets.Count>0 then
  begin
    caret:= Editor.Carets[0];
    caret.PosX:= c.GetValue(path+cHistory_Caret+'/x', 0);
    caret.PosY:= c.GetValue(path+cHistory_Caret+'/y', 0);
    caret.EndX:= c.GetValue(path+cHistory_Caret+'/x2', -1);
    caret.EndY:= c.GetValue(path+cHistory_Caret+'/y2', -1);
    Editor.UpdateIncorrectCaretPositions;
    Editor.DoEventCarets;
  end;

  //bookmarks
  items:= TStringList.create;
  items2:= TStringList.create;
  try
    c.GetValue(path+cHistory_Bookmark, items, '');
    c.GetValue(path+cHistory_BookmarkKind, items2, '');
    for i:= 0 to items.Count-1 do
    begin
      nTop:= StrToIntDef(items[i], -1);
      if i<items2.Count then
        nKind:= StrToIntDef(items2[i], 1)
      else
        nKind:= 1;
      if Editor.Strings.IsIndexValid(nTop) then
        Editor.Strings.Bookmarks.Add(nTop, nKind, '', false);
    end;
  finally
    FreeAndNil(items2);
    FreeAndNil(items);
  end;

  Editor.Update;
  if Splitted then
    Editor2.Update;
end;

function TEditorFrame.DoPyEvent(AEd: TATSynEdit; AEvent: TAppPyEvent;
  const AParams: array of string): string;
begin
  Result:= '';
  if Assigned(FOnPyEvent) then
    Result:= FOnPyEvent(AEd, AEvent, AParams);
end;


procedure TEditorFrame.SetTabColor(AColor: TColor);
var
  Gr: TATGroups;
  Pages: TATPages;
  NLocalGroups, NGlobalGroup, NTab: integer;
  D: TATTabData;
begin
  FTabColor:= AColor;
  GetFrameLocation(Self, Gr, Pages, NLocalGroups, NGlobalGroup, NTab);
  D:= Pages.Tabs.GetTabData(NTab);
  if Assigned(D) then
  begin
    D.TabColor:= AColor;
    Pages.Tabs.Invalidate;
  end;
end;

procedure TEditorFrame.DoClearPreviewTabState;
var
  Gr: TATGroups;
  Pages: TATPages;
  NLocalGroup, NGlobalGroup, NTab: integer;
  D: TATTabData;
begin
  GetFrameLocation(Self, Gr, Pages, NLocalGroup, NGlobalGroup, NTab);
  D:= Pages.Tabs.GetTabData(NTab);
  if Assigned(D) then
  begin
    D.TabSpecial:= false;
    D.TabFontStyle:= [];
    Pages.Tabs.Invalidate;
  end;
end;

procedure TEditorFrame.SetTabImageIndex(AValue: integer);
var
  Gr: TATGroups;
  Pages: TATPages;
  NLocalGroup, NGlobalGroup, NTab: integer;
  D: TATTabData;
begin
  if FTabImageIndex=AValue then exit;
  FTabImageIndex:= AValue;

  GetFrameLocation(Self, Gr, Pages, NLocalGroup, NGlobalGroup, NTab);
  D:= Pages.Tabs.GetTabData(NTab);
  if Assigned(D) then
  begin
    D.TabImageIndex:= AValue;
    Pages.Tabs.Invalidate;
  end;
end;

procedure TEditorFrame.NotifChanged(Sender: TObject);
begin
  //silent reload if: not modified, and undo empty
  if (not Modified) and (Ed1.UndoCount<=1) then
  begin
    DoFileReload;
    exit
  end;

  case MsgBox(msgConfirmFileChangedOutside+#10+FileName+
         #10#10+msgConfirmReloadIt+#10+msgConfirmReloadItHotkeys,
         MB_YESNOCANCEL or MB_ICONQUESTION) of
    ID_YES:
      DoFileReload;
    ID_CANCEL:
      NotifEnabled:= false;
  end;
end;

procedure TEditorFrame.SetEnabledCodeTree(AValue: boolean);
begin
  if FEnabledCodeTree=AValue then Exit;
  FEnabledCodeTree:= AValue;
  if not AValue then
    ClearTreeviewWithData(CachedTreeview);
end;

procedure TEditorFrame.SetEnabledFolding(AValue: boolean);
begin
  Ed1.OptFoldEnabled:= AValue;
  Ed2.OptFoldEnabled:= AValue;
end;

function TEditorFrame.PictureSizes: TPoint;
begin
  if Assigned(FImageBox) then
    Result:= Point(FImageBox.ImageWidth, FImageBox.ImageHeight)
  else
    Result:= Point(0, 0);
end;


procedure TEditorFrame.DoGotoPos(APosX, APosY: integer);
begin
  if APosY<0 then exit;
  if APosX<0 then APosX:= 0; //allow x<0

  Editor.LineTop:= APosY;
  TopLineTodo:= APosY; //check is it still needed
  Editor.DoGotoPos(
    Point(APosX, APosY),
    Point(-1, -1),
    UiOps.FindIndentHorz,
    UiOps.FindIndentVert,
    true,
    true
    );
  Editor.Update;
end;

procedure TEditorFrame.DoLexerFromFilename(const AFilename: string);
var
  TempLexer: TecSyntAnalyzer;
  TempLexerLite: TATLiteLexer;
  SName: string;
begin
  DoLexerDetect(AFilename, TempLexer, TempLexerLite, SName);
  if Assigned(TempLexer) then
    Lexer:= TempLexer
  else
  if Assigned(TempLexerLite) then
    LexerLite:= TempLexerLite;
end;

procedure TEditorFrame.SetFocus;
begin
  DoOnChangeCaption;

  if Assigned(FBin) then
  begin
    EditorFocus(FBin);
    exit;
  end;

  if Assigned(FImageBox) then
  begin
    exit;
  end;

  EditorFocus(Editor);
end;

type
  TATSynEdit_Hack = class(TATSynEdit);

procedure TEditorFrame.BinaryOnKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (Shift=[]) then
    if (Key=VK_UP) or
       (Key=VK_DOWN) or
       (Key=VK_LEFT) or
       (Key=VK_RIGHT) or
       (Key=VK_HOME) or
       (Key=VK_END) then
    exit;

  TATSynEdit_Hack(Editor).KeyDown(Key, Shift);
end;

procedure TEditorFrame.BinaryOnScroll(Sender: TObject);
begin
  DoOnUpdateStatus;
end;

procedure TEditorFrame.BinaryOnProgress(const ACurrentPos,
  AMaximalPos: Int64; var AContinueSearching: Boolean);
begin
  if Assigned(FOnProgress) then
    FOnProgress(nil, ACurrentPos, AMaximalPos, AContinueSearching);
end;

function TEditorFrame.BinaryFindFirst(AFinder: TATEditorFinder; AShowAll: boolean): boolean;
var
  Ops: TATStreamSearchOptions;
begin
  Ops:= [];
  if AFinder.OptCase then Include(Ops, asoCaseSens);
  if AFinder.OptWords then Include(Ops, asoWholeWords);
  if AShowAll then Include(Ops, asoShowAll);

  Result:= FBin.FindFirst(
    UTF8Encode(AFinder.StrFind), Ops, 0);
end;

function TEditorFrame.BinaryFindNext(ABack: boolean): boolean;
begin
  if FBinStream=nil then exit;
  Result:= FBin.FindNext(ABack);
end;

procedure TEditorFrame.DoFileClose;
begin
  SetLexer(nil);
  FileName:= '';
  TabCaption:= GetUntitledCaption;

  if Assigned(FBin) then
  begin
    FBin.OpenStream(nil);
    FreeAndNil(FBin);
    Ed1.Show;
  end;

  EditorClear(Editor);
  UpdateModifiedState;
end;

procedure TEditorFrame.DoToggleFocusSplitEditors;
var
  Ed: TATSynEdit;
begin
  if Splitted then
  begin
    Ed:= Editor2;
    if Ed.Enabled and Ed.Visible then
    begin
      FActiveSecondaryEd:= Ed=Ed2;
      Ed.SetFocus;
    end;
  end;
end;


end.

