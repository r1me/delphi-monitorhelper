UNIT Vcl.Forms.MonitorHelper;
(*-------------------------------------------------------------------------------------------------------------
  MonitorHelper
  2019.02

  DisplayDevice can return:
     displayDevice.DeviceID     =>    'MONITOR\Default_Monitor\{4d36e96e-e325-11ce-bfc1-08002be10318}\0004'
     displayDevice.DeviceString =>    'Generic Non-PnP Monitor'
     displayDevice.DeviceKey    =>    '\Registry\Machine\System\CurrentControlSet\Control\Class\{4d36e96e-e325-11ce-bfc1-08002be10318}\0004'
     displayDevice.DeviceName   =>    '\\.\DISPLAY1\Monitor0'

  Home: https://github.com/r1me/delphi-monitorhelper
------------------------------------------------------------------------------------------------------------*)
INTERFACE

USES
  Winapi.Windows, system.StrUtils, Vcl.Forms;

CONST
  DM_DISPLAYQUERYORIENTATION = $01000000;
  DMDO_DEFAULT = 0;
  DMDO_90 = 1;
  DMDO_180 = 2;
  DMDO_270 = 3;
  ENUM_CURRENT_SETTINGS = DWORD(-1);

TYPE
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
    dmColor           : ShortInt;
    dmDuplex          : ShortInt;
    dmYResolution     : ShortInt;
    dmTTOption        : ShortInt;
    dmCollate         : ShortInt;
    dmFormName        : array [0..CCHFORMNAME-1] of {$IFDEF UNICODE}WideChar{$ELSE}AnsiChar{$ENDIF};
    dmLogPixels       : WORD;
    dmBitsPerPel      : DWORD;
    dmPelsWidth       : DWORD;
    dmPelsHeight      : DWORD;
    dmDiusplayFlags   : DWORD;
    dmDisplayFrequency: DWORD;
    dmICMMethod       : DWORD;
    dmICMIntent       : DWORD;
    dmMediaType       : DWORD;
    dmDitherType      : DWORD;
    dmReserved1       : DWORD;
    dmReserved2       : DWORD;
    dmPanningWidth    : DWORD;
    dmPanningHeight   : DWORD;
  end;

  devicemode  = _devicemode;
  Pdevicemode = ^devicemode;

  TMonitorOrientation = (
    moLandscape,
    moPortrait,
    moLandscapeFlipped,
    moPortraitFlipped);

  TMonitorHelper = class helper for TMonitor
  private
    function  GetFriendlyName: String;
    function  GetSupportsRotation: Boolean;
    function  GetOrientation: TMonitorOrientation;
    procedure SetOrientation(ANewOrientation: TMonitorOrientation);
    function  GetDeviceID: String;
  public
    property FriendlyName: String read GetFriendlyName;
    property DeviceID: String read GetDeviceID;
    property Orientation: TMonitorOrientation read GetOrientation write SetOrientation;
    property SupportsRotation: Boolean read GetSupportsRotation;
  end;


function MonitorOrientationToString(AMonitorOrientation: TMonitorOrientation): string;
function ExtractDeviceID(ID: String): string;


IMPLEMENTATION








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
    Result := displayDevice.DeviceName;
   end;
end;


function TMonitorHelper.GetDeviceID: String;
var
  displayDevice: TDisplayDevice;
  devName: String;
begin
  Result := '';
  ZeroMemory(@displayDevice, SizeOf(displayDevice));
  displayDevice.cb := SizeOf(displayDevice);

  if EnumDisplayDevices(nil, Self.MonitorNum, displayDevice, 0) then
   begin
    devName := displayDevice.DeviceName;
    EnumDisplayDevices(PChar(devName), 0, displayDevice, 0);
    Result := displayDevice.DeviceID;
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
        DMDO_DEFAULT: Result := moLandscape;
        DMDO_90:      Result := moPortrait;
        DMDO_180:     Result := moLandscapeFlipped;
        DMDO_270:     Result := moPortraitFlipped;
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









{-------------------------------------------------------------------------------------------------------------
   UTILS
-------------------------------------------------------------------------------------------------------------}

function CopyTo(CONST s: string; iFrom, iTo: integer): string;                                                { Copy the text between iFrom and ending at iTo. The char at iTo is also copied. }
begin
 Result:= system.COPY(s, iFrom, iTo-iFrom+1);                                                                 { +1 ca sa includa si valoarea de la potitia 'iFrom' }
end;


function ExtractTextBetween(CONST s, TagStart, TagEnd: string): string;                                       { Extract the text between sFrom and iTo. For example '<H>Title</H>' will return 'Title' is iFrom= '<H>' and iTo= '</H>'. The search of iTo starts at the position of iFrom+ length(iFrom) }
VAR iFrom, iTo: Integer;
begin
 iFrom:= Pos(TagStart, s);
 iTo:= PosEx(TagEnd, s, iFrom+ Length(TagStart));

 if (iFrom> 0) AND (iTo> 0)
 then Result:= CopyTo(s, ifrom+ Length(TagStart), iTo-1)
 else Result:= '';
end;


// Extracts the {} part from a valid ID like: 'MONITOR\Default_Monitor\{4d36e96e-e325-11ce-bfc1-08002be10318}\0004'
function ExtractDeviceID(ID: String): string;
begin
 if Pos('MONITOR\', ID) <> 1 then EXIT('');              // Invalid ID
 Result:= ExtractTextBetween(ID, '{', '}');
end;


function MonitorOrientationToString(AMonitorOrientation: TMonitorOrientation): String;
begin
  case AMonitorOrientation of
    moLandscape: Result := 'Landscape';
    moPortrait : Result := 'Portrait';
    moLandscapeFlipped: Result := 'Landscape (flipped)';
    moPortraitFlipped : Result := 'Portrait (flipped)';
  end;
end;



end.
