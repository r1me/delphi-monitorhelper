program MonitorOrientationDemo;

uses
  Vcl.Forms,
  uMonitorOrientationDemo in 'uMonitorOrientationDemo.pas' {MonitorOrientationDemoForm},
  Vcl.Forms.MonitorHelper in '..\Vcl.Forms.MonitorHelper.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMonitorOrientationDemoForm, MonitorOrientationDemoForm);
  Application.Run;
end.
