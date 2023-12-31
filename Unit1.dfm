object Form1: TForm1
  Left = 325
  Top = 145
  BorderStyle = bsSingle
  Caption = 'BDF Font Analyser'
  ClientHeight = 825
  ClientWidth = 1303
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
    Left = 456
    Top = 431
    Width = 188
    Height = 159
    Margins.Left = 5
    Margins.Top = 5
    Margins.Right = 5
    Margins.Bottom = 5
  end
  object Label1: TLabel
    Left = 335
    Top = 477
    Width = 105
    Height = 25
    Margins.Left = 5
    Margins.Top = 5
    Margins.Right = 5
    Margins.Bottom = 5
    Caption = 'Glyph range :'
  end
  object Memo1: TRichEdit
    Left = 11
    Top = 11
    Width = 633
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
    Left = 655
    Top = 48
    Width = 638
    Height = 543
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
    Top = 11
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
    Top = 11
    Width = 515
    Height = 33
    Margins.Left = 5
    Margins.Top = 5
    Margins.Right = 5
    Margins.Bottom = 5
    TabOrder = 3
    OnKeyPress = DoEditKey
  end
  object ScrollBox1: TScrollBox
    Left = 11
    Top = 599
    Width = 1281
    Height = 219
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
    Left = 11
    Top = 431
    Width = 315
    Height = 159
    Margins.Left = 5
    Margins.Top = 5
    Margins.Right = 5
    Margins.Bottom = 5
    Lines.Strings = (
      'Memo3')
    TabOrder = 5
  end
  object ExportBtn: TButton
    Left = 335
    Top = 431
    Width = 112
    Height = 37
    Margins.Left = 5
    Margins.Top = 5
    Margins.Right = 5
    Margins.Bottom = 5
    Caption = 'Export'
    Enabled = False
    TabOrder = 6
    OnClick = ExportBtnClick
  end
  object Range1: TEdit
    Left = 335
    Top = 512
    Width = 112
    Height = 33
    Margins.Left = 5
    Margins.Top = 5
    Margins.Right = 5
    Margins.Bottom = 5
    TabOrder = 7
    Text = '0'
  end
  object Range2: TEdit
    Left = 335
    Top = 555
    Width = 112
    Height = 33
    Margins.Left = 5
    Margins.Top = 5
    Margins.Right = 5
    Margins.Bottom = 5
    TabOrder = 8
    Text = '255'
  end
  object SaveDialog1: TSaveDialog
    Filter = 'binary|*.bin|source|*.s'
    Title = 'Export glyph data for Appple II :'
    Left = 727
    Top = 431
  end
end
