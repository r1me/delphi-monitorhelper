object MonitorOrientationDemoForm: TMonitorOrientationDemoForm
  Left = 0
  Top = 0
  Caption = 'Monitor Orientation'
  ClientHeight = 141
  ClientWidth = 460
  Color = clBtnFace
  Constraints.MinHeight = 120
  Constraints.MinWidth = 450
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  DesignSize = (
    460
    141)
  PixelsPerInch = 96
  TextHeight = 13
  object labInfo: TLabel
    Left = 8
    Top = 122
    Width = 260
    Height = 13
    Anchors = [akLeft, akBottom]
    Caption = 'Right click on any monitor entry that supports rotation'
    ExplicitTop = 177
  end
  object lvMonitors: TListView
    Left = 8
    Top = 8
    Width = 445
    Height = 106
    Anchors = [akLeft, akTop, akRight, akBottom]
    Columns = <
      item
        Caption = 'Name'
        Width = 150
      end
      item
        Caption = 'Orientation'
        Width = 130
      end
      item
        Caption = 'Supports Rotation'
        Width = 120
      end>
    GridLines = True
    ReadOnly = True
    RowSelect = True
    PopupMenu = pmOrientation
    TabOrder = 0
    ViewStyle = vsReport
  end
  object pmOrientation: TPopupMenu
    OnPopup = pmOrientationPopup
    Left = 344
    Top = 40
    object Landscape1: TMenuItem
      Caption = 'Landscape'
      OnClick = PopUpClick
    end
    object Portrait1: TMenuItem
      Tag = 1
      Caption = 'Portrait'
      OnClick = PopUpClick
    end
    object Landscapeflipped1: TMenuItem
      Tag = 2
      Caption = 'Landscape (flipped)'
      OnClick = PopUpClick
    end
    object Portraitflipped1: TMenuItem
      Tag = 3
      Caption = 'Portrait (flipped)'
      OnClick = PopUpClick
    end
  end
end
