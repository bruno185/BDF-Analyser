unit MyUtils;

interface
uses Sysutils;

function TextfileSize(const name: string): LongInt;
function countglyph(fname : string) : integer;
procedure GetDataInfo(fname : string; var minl,maxl,minline,maxline : integer);
function AddThousandSeparator(S: string; Chr: char): string;
function GetSubString(s,start : string) : string;
function GetBitValue(const AByte: Byte; const BitIndex: Integer): Boolean;

implementation

function GetSubString(s,start : string) : string;
begin
  GetSubString := trim(copy(s,length(start)+1,length(s)-length(start)));
end;

function GetBitValue(const AByte: Byte; const BitIndex: Integer): Boolean;
begin
  Result := (AByte and (1 shl BitIndex)) <> 0;
end;


function TextfileSize(const name: string): LongInt;
var
  SRec: TSearchRec;
begin
  if FindFirst(name, faAnyfile, SRec) = 0 then
  begin
    Result := SRec.Size;
    Sysutils.FindClose(SRec);
  end
  else
    Result := 0;
end;

function countglyph(fname : string) : integer;
var
  s : string;
  nbglyph : integer;
  f : TextFile;
begin
  nbglyph := 0;
  AssignFile(f,fname);
  reset(f);
  while not(eof(f)) do
  begin
    readln(f,s);
    if pos('BITMAP',s) =1 then nbglyph := nbglyph + 1;
  end;
  countglyph := nbglyph;
  CloseFile(f);
end;

procedure GetDataInfo(fname : string; var minl,maxl,minline,maxline : integer);
var
  s : string;
  f : TextFile;
  nbline, linenub, i : integer;

begin
  AssignFile(f,fname);
  reset(f);
  minl := 1000000000;
  maxl := 0;
  minline := 1000000000;
  maxline := 0;
  linenub := 0;

  repeat
    repeat
      readln(f,s);
      inc(linenub);
    until (s = 'BITMAP') or (eof(f));

    nbline := 0;

    while not(eof(f)) and (s<>'ENDCHAR') do
    begin
      readln(f,s);
      inc(linenub);

      if (s<>'ENDCHAR') then if minl > length(s) then minl := length(s);
      if (s<>'ENDCHAR') then if length(s) > maxl then maxl := length(s);
      if (s<>'ENDCHAR') then inc(nbline);
    end;

    if not(eof(f)) then
    begin
      if nbline > maxline then maxline := nbline;
      if nbline < minline then
      begin
      minline := nbline;
      end;

    end;
  until eof(f);
  CloseFile(f);
end;

function AddThousandSeparator(S: string; Chr: char): string;
var I: integer;
  begin
  Result := S;
  I := Length(S)-2;
  while I > 1 do
  begin
    Insert(Chr, Result, I);
    I := I - 3;
    end;
end;




end.
