﻿unit Unit1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs,ShellApi, Vcl.StdCtrls, System.RegularExpressions, MyUtils,
  Vcl.ComCtrls, Vcl.ExtCtrls, Math;

type
  TForm1 = class(TForm)
    Memo1: TRichEdit;
    Memo2: TRichEdit;
    Button1: TButton;
    FindEdit: TEdit;
    ScrollBox1: TScrollBox;
    Image1: TImage;
    Memo3: TMemo;
    CharImage: TImage;
    ExportBtn: TButton;
    Range1: TEdit;
    Range2: TEdit;
    Label1: TLabel;
    SaveDialog1: TSaveDialog;
    procedure DoCreate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure DoEditKey(Sender: TObject; var Key: Char);
    procedure DoMouseWhell(Sender: TObject; Shift: TShiftState;
      WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
    procedure DoImageDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure ExportBtnClick(Sender: TObject);
  private
    { D�clarations priv�es }
    procedure WMDropFiles(var msg : TMessage); message WM_DROPFILES;

  public
    { D�clarations publiques }
  end;

type
  a_char = record                     // array holding data of a BDF file
       name : string;
       encoding : integer;
       swidth : string;
       dwidth : string;
       brx : string;
       r : Trect;
       bitmap : array of byte;
  end;

const
  Version = '1.4';
  InvalidMsg = 'Invalid file.';
  margin = 10;
  topmargin = 5;

var
  Form1: TForm1;
  // my global vars
  a : array of a_char;                // data of a BDF file loaded in this array
  numglyph : integer;                 // number of glyphs in BDP file
  bitmapw : integer;                  // width (in byte) of glyphs (*8 to get maximum width in pixel)
  bitmaph : integer;                  // height of glyphs in pixel
  bitmapsize : integer;               // size in byte of glyphs (= width * height)
  usedpix : integer;                  // real maximum width in pixels of glyphs
  glyphsperline : integer;            // number of glyphs diplayed per line in Timage
  glyphlines : integer;               // number of lines of glyphs displayed in Timage
  curglyph : integer;                 // index of clicked glyph
  prevglyph : integer;                // index of previously clicked glyph

implementation
{$R *.dfm}

function OraBitmap : byte;
var
  i, j : integer;
  b : byte;
begin
  b := 0;
  for i := 0 to numglyph - 1 do
  begin
    j := bitmapw-1;
    repeat
      b := b or a[i].bitmap[j];
      j := j + bitmapw;
    until j >= bitmapsize;
  end;

  result := b;
end;

// Display zoomed glyph in CharImage (TImage) with black squares
procedure BigGlyph(i : integer);
var
  side : integer;
  k, l, z : integer;
  b : byte;
  r : TRect;
  hmargin, vmargin : integer;
begin
  if i >= numglyph then exit;

  // clear image
  ImageClear(Form1.CharImage);
  // get side of a square
  side := Min (Form1.CharImage.Height div bitmaph, Form1.CharImage.Width div bitmapw);
  hmargin := (Form1.CharImage.Width - (side * bitmapw*8)) div 2;
  vmargin := (Form1.CharImage.Height - (side * bitmaph)) div 2;

  // loop on each bit of the glyph bitmap
  for k := 0 to  bitmaph -1 do
  for l := 0 to  bitmapw -1 do
  begin
    b := a[i].bitmap[k * bitmapw + l];
    for z := 0 to 7 do
    begin
      if GetBitValue(b,7-z) then
      Form1.CharImage.Canvas.Brush.Color := clRed    // black square if bit  = 1
      else
      Form1.CharImage.Canvas.Brush.Color := clWhite;   // white square if bit  = 0

      r.Top := k * side + vmargin;
      r.Left := (l * 8 + z) * side + hmargin;
      r.Bottom := r.Top + side;
      r.Right := r.Left + side;

      Form1.CharImage.Canvas.FillRect(r);  // draw square
    end;
  end;
end;

// hilight clicked glyph
procedure DoInvert2(i : integer);
var
  k, l : integer;
  r : TRect;
  c : TColor;
begin
  // reset previous glyph (red pixels ==> white)
  if prevglyph <> - 1 then
  begin
    r := a[prevglyph].r;
    for k := r.Top to r.Bottom do
    for l := r.Left to r.Right do
    begin
       c := form1.Image1.Picture.Bitmap.Canvas.Pixels[l,k];
       if c = clRed then
        form1.Image1.Picture.Bitmap.Canvas.Pixels[l,k] := clWhite;
    end;
  end;

  // set to red clicked glyph
  if i < numglyph then
  begin
    r := a[i].r;
    for k := r.Top to r.Bottom do
    for l := r.Left to r.Right do
    begin
     c := form1.Image1.Picture.Bitmap.Canvas.Pixels[l,k];
     if c = clWhite then form1.Image1.Picture.Bitmap.Canvas.Pixels[l,k] := clRed;
     prevglyph := curglyph;
    end;
  end
    else
    prevglyph := -1;
end;


// Display chars on Image1
procedure PrintChars(img : TImage; gheight,gwidth : integer);
var
  i, index : integer;
  Bitmap : TBitmap;
  ScanLinePtr : PRGBQuad;
  x, y, z : Integer;
  CouleurRGB: TRGBQuad;
  b : byte;
  leftmargin, tmargin : integer;

begin
  leftmargin := margin;   // init. margins with const
  tmargin := topmargin;
  //index := numglyph;

  Bitmap := TBitmap.Create;
  Bitmap.PixelFormat := pf32bit;
  //
  glyphsperline := (img.Width - margin*2) div ((bitmapw * 8)+1) ;  // nb glyph /line
  glyphlines := numglyph div glyphsperline + 2;  // nb of line needed
                                    // +2 : due to the truncation effected by
                                    // both integer division
                                    // (bitmap may be not enought high otherwise)
  img.Height := topmargin + glyphlines * (bitmaph+1);
  Bitmap.SetSize(img.Width, img.Height);

  CouleurRGB := ColorToRGBQuad(clBlack);

  // erase existing image with white background
  Bitmap.Canvas.Brush.Color := clWhite;
  Bitmap.Canvas.FillRect(Rect(0, 0, Bitmap.Width, Bitmap.Height));
  // black color

  for i := 0 to numglyph-1 do            // chars loop
  begin
    index := 0;
    a[i].r.Top := tmargin;
    a[i].r.Left := leftmargin - 1;
    a[i].r.Bottom := tmargin + gheight + 1;
    // rect is 1 pixel higher (to the bottom), to take account 1 pixel margin between lines
    a[i].r.Right := leftmargin + (gwidth) * 8;  // instead of  (gwidth) * 8 +1
    // rect is 1 pixel wider (to the right), to take account 1 pixel margin between chars

    for y := 0 to gheight-1 do    // line loop
      for x := 0 to gwidth-1 do   // col loop
        begin
          b :=  a[i].bitmap[index];
          for z := 0 to 7  do     // bit loop
            begin
              if GetBitValue(b,7-z) then    // most significant bits first
              begin
                ScanLinePtr := Bitmap.ScanLine[tmargin + y];
                Inc(ScanLinePtr,leftmargin);
                Inc(ScanLinePtr, x * 8 + z);
                ScanLinePtr^ := CouleurRGB;
              end;
            end;
          inc(index);
        end;
    inc(leftmargin,gwidth*8+1);             // +1 for 1 pixel margin between glyphs
    if leftmargin > bitmap.Width - margin * 2 then   // next line of glyphs
    begin
      inc(tmargin,gheight+1);             // +1 for 1 pixel between lines of glyphs
      leftmargin := margin;                 // reset leftmargin
    end;
    // frame each glyph
    bitmap.Canvas.Brush.Color := clMoneyGreen;
    bitmap.Canvas.FrameRect(a[i].r);
  end;
  img.Picture.Bitmap.Assign(Bitmap);

  Bitmap.Free;
end;

// populate array of chars
procedure ReadChars(const name: string );
var
  f : TextFile;
  s : string;
  i, j : integer;
  cnt, bytecnt, linecnt : integer;
  found : Boolean;
  regex : TRegEx;
  match : TMatch;
  matches : TMatchCollection;
begin
    // init a array
    SetLength(a,numglyph);
    for i := 0 to numglyph-1 do SetLength(a[i].bitmap,bitmapsize);

    for i := 0 to numglyph-1 do
      for j := 0 to bitmapsize-1 do
      begin
        a[i].bitmap[j] := 0;
      end;

    // read font information
    cnt := 0;
    AssignFile(f,name);
    reset(f);
    while not(eof(f)) do
    begin
      repeat
        readln(f,s);
        found := pos('STARTCHAR',s) > 0;
      until found or (eof(f));
      if found then a[cnt].name := GetSubString(s,'STARTCHAR');
      
      repeat
        readln(f,s);
        found := pos('ENCODING',s) > 0;
      until found or (eof(f));
      if found then a[cnt].encoding := StrToInt(GetSubString(s,'ENCODING'));  

      // populate bitmap arrays
      repeat
        readln(f,s);
        found := pos('BITMAP',s) > 0;
      until found or (eof(f));
      if found then
      begin
      // reading of a glyph's bytes starts here
        bytecnt := 0;
        linecnt := 0;
        repeat 
          readln(f,s);
          inc (linecnt);
          if s<> 'ENDCHAR' then
          begin
            matches :=  regex.Matches(s,'([0-9A-Fa-f]{2})');
            for i := 0 to matches.Count - 1  do
            begin
              a[cnt].bitmap[bytecnt] := StrToInt('$' + matches.Item[i].Value);
              inc(bytecnt)
            end;
            // explaniations needed here :
            // some BDF files don't have their full glyph data.
            // Missing width and height bytes are implicitly 0.

            // pad with 0 here for missing columns (width)
            if bitmapw > matches.Count then
            for i := 1 to  bitmapw- matches.Count do
            begin
              a[cnt].bitmap[bytecnt] := 0;
              inc(bytecnt)
            end;
          end;
        until s = 'ENDCHAR';
        //same explanation, for lines (height)
        // pad with 0 here for missing lines
        if bitmaph > linecnt then
        begin
          a[cnt].bitmap[bytecnt] := 0;
          inc(bytecnt)
        end;
        inc(cnt);
      end;
    end;
    CloseFile(f);
end;

procedure put(out : string);
begin
  Form1.Memo1.Lines.Add(out);
end;

procedure put3(out : string);
begin
  Form1.Memo3.Lines.Add(out);
end;

// read BDF file, display info
procedure Dofile(fname : string);
var
  filin: TextFile;
  s, bytestr : string;
  minl,maxl,minline,maxline,i : integer;
  regex : TRegEx;
  match : TMatch;
  matches : TMatchCollection;

begin
  form1.Memo1.Clear;
  AssignFile(filin,fname);
  reset(filin);

  readln(filin,s);
  if not(s.Contains('STARTFONT')) then
  begin
    put(InvalidMsg);
    CloseFile(filin);
    exit;
  end;
  put('File name : ' + fname);
  put('File size : ' + AddThousandSeparator(IntToStr(TextfileSize(fname)),' ')+ ' bytes');
  put('BDF version : ' + copy(s,length('STARTFONT')+2,length(s)-length('STARTFONT')+2) );
  repeat
    readln(filin,s);
    if regex.IsMatch(s,'^SIZE') then
    begin
        matches :=  regex.Matches(s,'([0-9A-Fa-f]{2})');
        put('Size : '+ matches.Item[0].Value);
        s := '';
        for i := 1 to matches.Count - 1 do s := s + matches.Item[i].Value + ' ';
        s := StringReplace(s,' ',' x ',[rfIgnoreCase]);
        put('Resolution : ' + trim(s));
    end;
    if regex.IsMatch(s,'^FONTBOUNDINGBOX') then
    begin
        matches :=  regex.Matches(s,'(-?\d*)');
        if (matches.Item[0].Value  <> '') and (matches.Item[1].Value  <> '') then
        put('Bounding box : '+ matches.Item[0].Value +' pixels x ' + matches.Item[1].Value + ' pixels');
        if (matches.Item[2].Value  <> '') and (matches.Item[3].Value  <> '') then
        put('Base line offset from bottom left corner : '+ matches.Item[2].Value +' pixels x ' + matches.Item[3].Value + ' pixels');
    end;
  until (eof(filin));
  CloseFile(filin);
  put('');

  // * * * * * * * * *
  numglyph := countglyph(fname);
  put('Number of glyphs : ' + AddThousandSeparator(IntToStr(numglyph),' '));

  // read all file and set vars
  GetDataInfo(fname, minl,maxl,minline,maxline);

  bitmapsize :=  (maxl div 2) * maxline;    // set max size to reserve for each char
                                            // (2 chars for a byte in hex representation)
  bitmapw := maxl div 2;                    // set max width of each char (in bytes)
                                            // (2 chars for a byte in hex representation)
  bitmaph := maxline;                       // set max height of each char (in pixels)

  if minl div 2 > 1  then bytestr := ' bytes' else bytestr :=  ' byte';
  put('Min row size : ' + IntToStr(minl div 2) + bytestr);
  if bitmapw > 1  then bytestr := ' bytes' else bytestr :=  ' byte';
  put('Max row size : ' + IntToStr(bitmapw) + bytestr);
  put('Min height : ' + IntToStr(bitmaph)+' lines');
  put('Max height : ' + IntToStr(bitmaph)+' lines');

  // populate array of chars
  ReadChars(fname);
  usedpix := (bitmapw-1) * 8 + Count1Bits(OraBitmap);
  put('Horizontal pixels used per row : ' + IntToStr(usedpix)
  + ' (or check sum = '+IntToStr(OraBitmap)+')');

  s := ' bytes per line are required on the Apple II screen, at least.';
  if usedpix mod 7 = 0 then
  put('==> ' + IntToStr(usedpix div 7) + s)
  else
  put('==> ' + IntToStr(usedpix div 7 + 1) + s);

  // display glyphs
  PrintChars(Form1.Image1,maxline,maxl div 2);
end;

// Drag and Drop
procedure TForm1.WMDropFiles(var msg : TMessage);
var hand: THandle;
nbFich : integer;
buf:array[0..254] of Char;
begin
    hand:=msg.wParam;
    nbFich:= DragQueryFile(hand, 4294967295, buf, 254);
    DragQueryFile(hand, 0, buf, 254);
    Memo1.Lines.Clear;
    Memo2.Lines.Clear;
    Memo3.Lines.Clear;
      // clear image
    ImageClear(CharImage);
    curglyph := -1;
    prevglyph := -1;
    ExportBtn.Enabled := true;
    DoFile(buf);
    if Memo1.Lines[0] <> InvalidMsg then
    begin
      Memo2.Lines.LoadFromFile(buf);
      Range1.Text := '0';
      Range2.Text := '255';
      if numglyph < 256 then  Range2.Text := IntToStr(numglyph-1);
    end;
    DragFinish(hand);
end;

// Find text in BDF file
procedure TForm1.Button1Click(Sender: TObject);
var
   FoundAt : LongInt;
   s : string;
begin
  s := FindEdit.Text;
  // find text, strating from the caret position (= memo2.SelStart)
  FoundAt :=  Memo2.FindText(s,memo2.SelStart+length(s),length(Memo2.Text),[]);
  if FoundAt <> -1 then
  begin
    // Memo2.SetFocus;
    // TRichEdit has a property HideSelection which is True by default. 
    // If set to False then the selection will still be visible 
    // even when the TRichEdit does not have focus.
    Memo2.SelStart := FoundAt;
    Memo2.SelLength := Length(s);
    FindEdit.SetFocus;
  end;
end;


// Export data in Apple II binary screen format
procedure SaveBinary(fname : string ; r1,r2 : smallint);
var
  f : file of byte;
  b : byte;
  i, j, k, l, aa, zz, delta, range : integer;
  bitval : Boolean;
  outbyte : array of byte;
  bitindexin, byteindexin, bitindexout, byteindexout : byte;
begin
    if pos('.bin', LowerCase(fname)) <> length(fname) - length('.bin') + 1 then
    fname := fname + '.bin';

    AssignFile(f,fname);
    rewrite(f);
    range := r2-r1+1;

    b := lo(range);                     // range of glyph  (2 bytes)
    write(f,b);
    b := hi(range);
    write(f,b);

    if usedpix mod 7 = 0  then                // width (in bytes) of glyph
    SetLength(outbyte,usedpix div 7)
    else  SetLength(outbyte,(usedpix div 7)+1);
    b := lo(length(outbyte));
    write(f,b);
    b := lo(bitmaph);                         // height of glyph
    write(f,b);

    aa := r1;
    zz := r2;
    for i := aa to zz do                      // glyph loop
    for j := 0 to bitmaph - 1 do              // line loop
    begin
      for k := 0 to Length(outbyte) - 1 do outbyte[k] := 0;
      bitindexin := 0;
      byteindexin := 0;
      bitindexout := 0;
      byteindexout := 0;
      for l := 0 to usedpix - 1 do
      begin
        b := a[i].bitmap[j * bitmapw + byteindexin];
        // invert bits order to match Apple II screen
        if GetBitValue(b,7-bitindexin) then
        outbyte[byteindexout] := SetBitValue(outbyte[byteindexout],bitindexout);

        inc(bitindexin);
        if bitindexin = 8 then          // end of input byte ?
        begin
          inc(byteindexin);             // yes : next byte
          bitindexin := 0               // and reset bit counter to 0
        end;

        inc(bitindexout);              // same with ouput byte
        if bitindexout = 7 then        // only 7 bit per screen byte on Apple II
        begin
          inc(byteindexout);
          bitindexout := 0
        end;
      end;
      // write data to file
      for k := 0 to Length(outbyte) - 1 do write(f,outbyte[k]);
    end;
    closefile(f);
end;

procedure SaveSource(fname : string ; r1,r2 : smallint);
var
  f : TextFile;
  b : byte;
  i, j, k, l, aa, zz, delta, range : integer;
  bitval : Boolean;
  outbyte : array of byte;
  bitindexin, byteindexin, bitindexout, byteindexout : byte;
begin
    if (fname[length(fname)] <> 's') or (fname[length(fname)-1] <> '.') then
    fname := fname + '.s';

    AssignFile(f,fname);
    rewrite(f);
    range := r2-r1+1;

    write(f,'numglyph hex ');    // range of glyph  (2 bytes)
    b := lo(range);
    write(f, ByteToHex(b));
    b := hi(range);
    writeln(f, ByteToHex(b));

    write(f,'gwidth hex ');
    if usedpix mod 7 = 0  then                // width (in bytes) of glyph
    SetLength(outbyte,usedpix div 7)
    else  SetLength(outbyte,(usedpix div 7)+1);
    b := lo(length(outbyte));
    writeln(f, ByteToHex(b));

    write(f,'gheight hex ');
    b := lo(bitmaph);                         // height of glyph
    writeln(f, ByteToHex(b));

    writeln(f,'font');

    aa := r1;
    zz := r2;
    for i := aa to zz do                      // glyph loop
    begin
      writeln(f,'glyph'+IntToStr(a[i].encoding)); // print label for curent glyph
      for j := 0 to bitmaph - 1 do              // line loop
      begin
        for k := 0 to Length(outbyte) - 1 do outbyte[k] := 0;
        bitindexin := 0;
        byteindexin := 0;
        bitindexout := 0;
        byteindexout := 0;
        for l := 0 to usedpix - 1 do
        begin
          b := a[i].bitmap[j * bitmapw + byteindexin];
          // invert bits order to match Apple II screen
          if GetBitValue(b,7-bitindexin) then
          outbyte[byteindexout] := SetBitValue(outbyte[byteindexout],bitindexout);

          inc(bitindexin);
          if bitindexin = 8 then          // end of input byte ?
          begin
            inc(byteindexin);             // yes : next byte
            bitindexin := 0               // and reset bit counter to 0
          end;

          inc(bitindexout);              // same with ouput byte
          if bitindexout = 7 then        // only 7 bit per screen byte on Apple II
          begin
            inc(byteindexout);
            bitindexout := 0
          end;
        end;
        // write data to file
        write(f,' hex ');
        for k := 0 to Length(outbyte) - 1 do write(f,ByteToHex(outbyte[k]));
        writeln(f);
      end;
    end;
    closefile(f);
end;

// init vars at program start
procedure TForm1.ExportBtnClick(Sender: TObject);
var
  range : SmallInt;

begin
  range := TestRange(Range1.Text, Range2.Text, numglyph);
  if  range > 0  then
  if SaveDialog1.Execute then
  if SaveDialog1.FilterIndex = 1 then
  begin
    SaveBinary(SaveDialog1.FileName, StrToInt(Range1.Text), StrToInt(Range2.Text));
  end  // if FilterIndex = 1
  else
  if SaveDialog1.FilterIndex = 2 then
  begin
    SaveSource(SaveDialog1.FileName, StrToInt(Range1.Text), StrToInt(Range2.Text));
  end;

end;

procedure TForm1.DoCreate(Sender: TObject);
begin
  DragAcceptFiles(Form1.Handle , true);
  Memo1.Lines.Clear;
  Memo1.Lines.Add('Drag a BDF font file over this application...');
  Memo2.Lines.Clear;
  Memo3.Lines.Clear;
  ImageClear(CharImage);  // clear image
  curglyph := -1;
  prevglyph := -1;
  Form1.Caption := Form1.Caption + ' v.' + Version;
end;

// return key in FindEdit
procedure TForm1.DoEditKey(Sender: TObject; var Key: Char);
begin
  if Key = #13 then begin
    Button1.Click;
    Key := #0;
  end;
end;


// when mouse donw on image
procedure TForm1.DoImageDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  pt : tPoint;
  i : integer;
  found : Boolean;
begin
  pt :=  TImage(Sender).ScreenToClient(Mouse.CursorPos);
  i := 0;
  found := false;
  repeat
    if PtInRect(a[i].r,pt) then found := true
    else inc(i)
  until (found) or (i = numglyph);

  if found then
  begin
    curglyph := i;
  end
  else
  curglyph :=  numglyph ;
  if curglyph < numglyph then
  begin
    memo3.Clear;
    put3('Glyph# : '+ IntToStr(curglyph) + ' ($' + IntToHex(curglyph,2)+')');
    put3('Name : '+ a[curglyph].name);
    put3('Encoding : ' + IntToStr(a[curglyph].encoding));
    // sync with glyph text file
    FindEdit.Text := a[curglyph].name;    // set search question
    Memo2.SelStart := 0;                  // reset glyph text to beginning
    Button1.Click;                        // perform search
    Memo2.perform(em_linescroll, 0, 18) ; // scroll up
  end
  else
  begin
    memo3.Clear;
    put3('NO CHAR');
    ImageClear(CharImage);
  end;

  DoInvert2(curglyph);
  BigGlyph(curglyph);

  // if shift pressed : set range to this glyph
  if ssShift in Shift then
  begin
    Range1.Text := IntToStr(curglyph);
    Range2.Text := IntToStr(curglyph);
  end;

end;

procedure TForm1.DoMouseWhell(Sender: TObject; Shift: TShiftState;
  WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
var
  aPos: SmallInt;
begin
  aPos:= ScrollBox1.VertScrollBar.Position - WheelDelta ;
  aPos:= Max(aPos, 0);
  aPos:= Min(aPos, ScrollBox1.VertScrollBar.Range);
  ScrollBox1.VertScrollBar.Position := aPos;
  Handled := True;
end;

end.
