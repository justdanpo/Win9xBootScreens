uses dos,crt;
var screen:array[0..399,0..79] of byte absolute $a000:0;

{-------------------------init video-----------------------------}
procedure initvideo;
var i:byte;
    regs: Registers;
    w:word;
    x,y:integer;
begin
  regs.ax := $13; intr($10,regs);
  portw[$3d4]:=9;
  portw[$3c4]:=$604;
  portw[$3d4]:=$e317;
  portw[$3d4]:=$14;
  port[$3c8]:=0;
  for i:=0 to 255 do begin
      port[$3c9]:=0;
      port[$3c9]:=0;
      port[$3c9]:=0;
  end;
  portw[$3c4]:=$f02;
{  FillChar(screen,sizeof(screen),0);}
end;
{-------------------------init video-----------------------------}

{-----------------------------main-------------------------------}
type pal=array[0..3]of byte;
var f:file;
    p:array[0..255]of pal;

    xx:array[0..319]of byte;
    y,x:integer;

var lastp:integer;
    s:string;
begin
  {$I-}
  if paramcount>=1 then s:=paramstr(1) else s:='logo.sys';
  writeln(MaxAvail);
  assign(f,s);reset(f,1);
  if ioresult<>0 then begin
    writeln('cant open ',s);
  end;
  seek(f,50);blockread(f,lastp,2);if lastp=0 then lastp:=256;
  seek(f,54);
  initvideo;
  blockread(f,p,sizeof(p));
  seek(f,1078);
  for y:=399 downto 0 do begin
    blockread(f,xx,320);
    for x:=0 to 320 shr 2-1 do begin
      portw[$3c4]:=$102; screen[y,x]:=xx[x*4];
      portw[$3c4]:=$202; screen[y,x]:=xx[x*4+1];
      portw[$3c4]:=$402; screen[y,x]:=xx[x*4+2];
      portw[$3c4]:=$802; screen[y,x]:=xx[x*4+3];
    end;
  end;
  close(f);
  for x:=0 to lastp-1 do begin
    port[$3c8]:=x;
    port[$3c9]:=p[x][2] shr 2;
    port[$3c9]:=p[x][1] shr 2;
    port[$3c9]:=p[x][0] shr 2;
  end;
  repeat
    for x:=lastp to 255 do begin
      while (y>255) do y:=y-256+lastp;
      while (y<lastp) do y:=y+256-lastp;
      port[$3c8]:=x;
      port[$3c9]:=p[y][2] shr 2;
      port[$3c9]:=p[y][1] shr 2;
      port[$3c9]:=p[y][0] shr 2;
      inc(y);
    end;
    inc(y);
    if lastp<>256 then begin
      for x:=0 to 48 div (256-lastp) do begin
        while ( port[$3da] and 8<>0 )do;
        while ( port[$3da] and 8= 0 )do;
      end;
    end;
  until keypressed;
  readkey;
  TextMode(3);
end.