object Form1: TForm1
  Left = 343
  Top = 164
  Caption = 'BDF Font Analyser'
  ClientHeight = 827
  ClientWidth = 1301
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -18
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poDesigned
  OnCreate = DoCreate
  PixelsPerInch = 144
  TextHeight = 25
  object CharImage: TImage
    Left = 420
    Top = 431
    Width = 224
    Height = 158
    Margins.Left = 5
    Margins.Top = 5
    Margins.Right = 5
    Margins.Bottom = 5
  end
  object Memo1: TRichEdit
    Left = 10
    Top = 10
    Width = 634
    Height = 411
    Margins.Left = 5
    Margins.Top = 5
    Margins.Right = 5
    Margins.Bottom = 5
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -18
    Font.Name = 'Segoe UI'
    Font.Style = []
    Lines.Strings = (
      'Memo1')
    ParentFont = False
    ScrollBars = ssVertical
    TabOrder = 0
  end
  object Memo2: TRichEdit
    Left = 654
    Top = 47
    Width = 637
    Height = 542
    Margins.Left = 5
    Margins.Top = 5
    Margins.Right = 5
    Margins.Bottom = 5
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -18
    Font.Name = 'Segoe UI'
    Font.Style = []
    HideSelection = False
    Lines.Strings = (
      'Memo1')
    ParentFont = False
    PlainText = True
    ScrollBars = ssVertical
    TabOrder = 1
  end
  object Button1: TButton
    Left = 654
    Top = 10
    Width = 113
    Height = 27
    Margins.Left = 5
    Margins.Top = 5
    Margins.Right = 5
    Margins.Bottom = 5
    Caption = 'Find'
    TabOrder = 2
    OnClick = Button1Click
  end
  object FindEdit: TEdit
    Left = 777
    Top = 10
    Width = 511
    Height = 33
    Margins.Left = 5
    Margins.Top = 5
    Margins.Right = 5
    Margins.Bottom = 5
    TabOrder = 3
    OnKeyPress = DoEditKey
  end
  object ScrollBox1: TScrollBox
    Left = 10
    Top = 599
    Width = 1281
    Height = 218
    Margins.Left = 5
    Margins.Top = 5
    Margins.Right = 5
    Margins.Bottom = 5
    TabOrder = 4
    OnMouseWheel = DoMouseWhell
    object Image1: TImage
      Left = 5
      Top = 5
      Width = 1245
      Height = 204
      Margins.Left = 5
      Margins.Top = 5
      Margins.Right = 5
      Margins.Bottom = 5
      OnMouseDown = DoImageDown
    end
  end
  object Memo3: TMemo
    Left = 10
    Top = 431
    Width = 400
    Height = 158
    Margins.Left = 5
    Margins.Top = 5
    Margins.Right = 5
    Margins.Bottom = 5
    Lines.Strings = (
      'Memo3')
    TabOrder = 5
  end
end
