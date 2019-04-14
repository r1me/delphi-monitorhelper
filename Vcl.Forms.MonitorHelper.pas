unit Vcl.Forms.MonitorHelper;

interface

uses
  Winapi.Windows, Vcl.Forms;

const
  DM_DISPLAYQUERYORIENTATION = $01000000;

const
  DMDO_DEFAULT = 0;
  DMDO_90 = 1;
  DMDO_180 = 2;
  DMDO_270 = 3;

const
  ENUM_CURRENT_SETTINGS = DWORD(-1);

type
  _devicemode = record
    dmDeviceName: array [0..CCHDEVICENAME-1] of {$IFDEF UNICODE}WideChar{$ELSE}AnsiChar{$ENDIF};
    dmSpecVersion: WORD;
    dmDriverVersion: WORD;
    dmSize: WORD;
    dmDriverExtra: WORD;
    dmFields: DWORD;
    union1: record
    case Integer of
      0: (
        dmOrientation: SmallInt;
        dmPaperSize: SmallInt;
        dmPaperLength: SmallInt;
        dmPaperWidth: SmallInt;
        dmScale: SmallInt;
        dmCopies: SmallInt;
        dmDefaultSource: SmallInt;
        dmPrintQuality: SmallInt);
      1: (
        dmPosition: TPointL;
        dmDisplayOrientation: DWORD;
        dmDisplayFixedOutput: DWORD);
    end;
    dmColor: ShortInt;
    dmDuplex: ShortInt;
    dmYResolution: ShortInt;
    dmTTOption: ShortInt;
    dmCollate: ShortInt;
    dmFormName: array [0..CCHFORMNAME-1] of {$IFDEF UNICODE}WideChar{$ELSE}AnsiChar{$ENDIF};
    dmLogPixels: WORD;
    dmBitsPerPel: DWORD;
    dmPelsWidth: DWORD;
    dmPelsHeight: DWORD;
    dmDiusplayFlags: DWORD;
    dmDisplayFrequency: DWORD;
    dmICMMethod: DWORD;
    dmICMIntent: DWORD;
    dmMediaType: DWORD;
    dmDitherType: DWORD;
    dmReserved1: DWORD;
    dmReserved2: DWORD;
    dmPanningWidth: DWORD;
    dmPanningHeight: DWORD;
  end;
  devicemode  = _devicemode;
  Pdevicemode = ^devicemode;

type
  TMonitorOrientation = (
    moLandscape,
    moPortrait,
    moLandscapeFlipped,
    moPortraitFlipped);

type
  TMonitorHelper = class helper for TMonitor
  private
    function GetFriendlyName: String;
    function GetSupportsRotation: Boolean;
    function GetOrientation: TMonitorOrientation;
    procedure SetOrientation(ANewOrientation: TMonitorOrientation);
  public
    property FriendlyName: String read GetFriendlyName;
    property Orientation: TMonitorOrientation read GetOrientation write SetOrientation;
    property SupportsRotation: Boolean read GetSupportsRotation;
  end;

implementation

{ TMonitorHelper }

function TMonitorHelper.GetFriendlyName: String;
var
  displayDevice: TDisplayDevice;
  devName: String;
begin
  // todo: get friendly name from EDID

  Result := '';

  ZeroMemory(@displayDevice, SizeOf(displayDevice));
  displayDevice.cb := SizeOf(displayDevice);

  if EnumDisplayDevices(nil, Self.MonitorNum, displayDevice, 0) then
  begin
    devName := displayDevice.DeviceName;
    EnumDisplayDevices(PChar(devName), 0, displayDevice, 0);
    Result := displayDevice.DeviceString;
  end;
end;

function TMonitorHelper.GetSupportsRotation: Boolean;
var
  devMode: TDevMode;
  displayDevice: TDisplayDevice;
begin
  Result := False;

  ZeroMemory(@displayDevice, SizeOf(displayDevice));
  displayDevice.cb := SizeOf(displayDevice);

  if EnumDisplayDevices(nil, Self.MonitorNum, displayDevice, 0) then
  begin
    ZeroMemory(@devMode, SizeOf(devMode));
    devMode.dmSize := SizeOf(devMode);
    devMode.dmFields := DM_DISPLAYQUERYORIENTATION;

    Result := (ChangeDisplaySettingsEx(@displayDevice.DeviceName, devMode, 0, CDS_TEST, nil) = DISP_CHANGE_SUCCESSFUL);
  end;
end;

function TMonitorHelper.GetOrientation: TMonitorOrientation;
var
  devMode: TDeviceMode;
  displayDevice: TDisplayDevice;
begin
  Result := moLandscape;

  ZeroMemory(@displayDevice, SizeOf(displayDevice));
  displayDevice.cb := SizeOf(displayDevice);

  if EnumDisplayDevices(nil, Self.MonitorNum, displayDevice, 0) then
  begin
    ZeroMemory(@devMode, SizeOf(devMode));
    devMode.dmSize := SizeOf(devMode);

    if EnumDisplaySettings(@displayDevice.DeviceName, ENUM_CURRENT_SETTINGS, devMode) then
    begin
      case Pdevicemode(@devMode)^.union1.dmDisplayOrientation of
        DMDO_DEFAULT:
          Result := moLandscape;
        DMDO_90:
          Result := moPortrait;
        DMDO_180:
          Result := moLandscapeFlipped;
        DMDO_270:
          Result := moPortraitFlipped;
        else
          Result := moLandscape;
      end;
    end;
  end;
end;

procedure TMonitorHelper.SetOrientation(ANewOrientation: TMonitorOrientation);
var
  devMode: TDevMode;
  displayDevice: TDisplayDevice;
  dwTemp: DWORD;
begin
  ZeroMemory(@displayDevice, SizeOf(displayDevice));
  displayDevice.cb := SizeOf(displayDevice);

  if EnumDisplayDevices(nil, Self.MonitorNum, displayDevice, 0) then
  begin
    ZeroMemory(@devMode, SizeOf(devMode));
    devMode.dmSize := SizeOf(devMode);

    if EnumDisplaySettings(@displayDevice.DeviceName, ENUM_CURRENT_SETTINGS, devMode) then
    begin
      if Odd(Pdevicemode(@devMode)^.union1.dmDisplayOrientation) <> Odd(Ord(ANewOrientation)) then
      begin
        dwTemp := devMode.dmPelsHeight;
        devMode.dmPelsHeight:= devMode.dmPelsWidth;
        devMode.dmPelsWidth := dwTemp;
      end;

      if Pdevicemode(@devMode)^.union1.dmDisplayOrientation <> DWORD(Ord(ANewOrientation)) then
      begin
        Pdevicemode(@devMode)^.union1.dmDisplayOrientation := DWORD(Ord(ANewOrientation));
        ChangeDisplaySettingsEx(@displayDevice.DeviceName, devMode, 0, 0, nil);
      end;
    end;
  end;
end;

end.