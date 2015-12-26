unit uMonitorOrientationDemo;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ComCtrls, Vcl.Forms.MonitorHelper,
  Vcl.Menus;

type
  TMonitorOrientationDemoForm = class(TForm)
    lvMonitors: TListView;
    pmOrientation: TPopupMenu;
    Landscape1: TMenuItem;
    Portrait1: TMenuItem;
    Landscapeflipped1: TMenuItem;
    Portraitflipped1: TMenuItem;
    labInfo: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure pmOrientationPopup(Sender: TObject);
    procedure PopUpClick(Sender: TObject);
  private
    procedure SetSelectedMonitorOrientation(AMonitorOrientation: TMonitorOrientation);
  public
    function MonitorOrientationToString(AMonitorOrientation: TMonitorOrientation): String;
    procedure RefreshMonitorsList;
  end;

var
  MonitorOrientationDemoForm: TMonitorOrientationDemoForm;

implementation

{$R *.dfm}

procedure TMonitorOrientationDemoForm.FormCreate(Sender: TObject);
begin
  RefreshMonitorsList;
end;

function TMonitorOrientationDemoForm.MonitorOrientationToString(
  AMonitorOrientation: TMonitorOrientation): String;
begin
  case AMonitorOrientation of
    moLandscape:
      Result := 'Landscape';
    moPortrait:
      Result := 'Portrait';
    moLandscapeFlipped:
      Result := 'Landscape (flipped)';
    moPortraitFlipped:
      Result := 'Portrait (flipped)';
  end;
end;

procedure TMonitorOrientationDemoForm.pmOrientationPopup(Sender: TObject);
begin
  if Assigned(lvMonitors.Selected) then
  begin
    if lvMonitors.Selected.SubItems[1] <> 'Yes' then Abort;
  end else
    Abort;
end;

procedure TMonitorOrientationDemoForm.PopUpClick(Sender: TObject);
begin
  SetSelectedMonitorOrientation(TMonitorOrientation(TMenuItem(Sender).Tag));
end;

procedure TMonitorOrientationDemoForm.SetSelectedMonitorOrientation(AMonitorOrientation: TMonitorOrientation);
begin
  if Assigned(lvMonitors.Selected) then
  begin
    Screen.Monitors[lvMonitors.Selected.Index].Orientation := AMonitorOrientation;
    lvMonitors.Selected.SubItems[0] := MonitorOrientationToString(AMonitorOrientation);
  end;
end;

procedure TMonitorOrientationDemoForm.RefreshMonitorsList;
var
  i: Integer;
  li: TListItem;
begin
  lvMonitors.Items.BeginUpdate;
  try
    lvMonitors.Items.Clear;
    for i := 0 to Screen.MonitorCount-1 do
    begin
      li := lvMonitors.Items.Add;
      li.Caption := Screen.Monitors[i].FriendlyName;
      li.SubItems.Add(MonitorOrientationToString(Screen.Monitors[i].Orientation));
      if Screen.Monitors[i].SupportsRotation then
        li.SubItems.Add('Yes')
      else
        li.SubItems.Add('No');
    end;
  finally
    lvMonitors.Items.EndUpdate;
  end;
end;

end.
