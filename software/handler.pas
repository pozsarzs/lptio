{ +--------------------------------------------------------------------------+ }
{ | Extended I/O interface for LPT port                                      | }
{ | Copyright (C) 2010 Pozsar Zsolt <info@pozsarzs.hu>                       | }
{ | handler.pas                                                              | }
{ | handler program                                                          | }
{ +--------------------------------------------------------------------------+ }
program handler;
uses crt, convert, lptio;
var
  b: byte;                                                  { general variable }
  pa: integer;                                                  { port address }
  eqid: byte;                                                   { equipment ID }
  selectlines: char;                                           { selector line }
  bb: byte;                                                 { general variable }
  i: integer;                                               { general variable }
  s: string;                                                { general variable }

procedure screen;                                                { base screen }
begin
  textbackground(blue);
  clrscr;
  textcolor(lightcyan);
  gotoxy(1,1);write('É');
  for b:=2 to 40 do write('Í');
  write('Ñ');
  for b:=2 to 39 do write('Í'); write('»');
  for b:=2 to 10 do
  begin
    gotoxy(1,b); write('º');
    gotoxy(41,b); write('³');
    gotoxy(80,b); write('º');
  end;
  gotoxy(1,10);
  write('Ç'); for b:=2 to 40 do write('Ä');
  write('Á');
  for b:=2 to 39 do write('Ä'); write('¶');
  gotoxy(1,11); write('º');
  gotoxy(15,11); write('³');
  gotoxy(26,11); write('³');
  gotoxy(80,11); write('º');
  gotoxy(1,12);
  write('È');for b:=1 to 78 do write('Í'); write('¼');
  gotoxy(15,12); write('Ï');
  gotoxy(26,12); write('Ï');
  gotoxy(15,10); write('Â');
  gotoxy(26,10); write('Â');
  gotoxy(3,1);write(' Read ');
  gotoxy(43,1);write(' Write ');
  gotoxy(4,11);write('Adr: 378H ');
  gotoxy(17,11);write('EqID: 0');
  gotoxy(28,11);write('(C)2010 Pozsar Zsolt <http://www.pozsarzs.hu>');
  for b:=2 to 9 do
  begin
    gotoxy(3,b); write('-slct',b-2); gotoxy(43,b); write('-slct',b-2);
    gotoxy(22,b); write('00H 000D 00000000B');
    gotoxy(61,b); write('00H 000D 00000000B');
  end;
  textbackground(lightgray);
  textcolor(black);
  gotoxy(1,25); clreol;
  write(' h help  i ID  p port  r read  w write  q quit');
  textcolor(lightred);
  gotoxy(2,25); write('h');  gotoxy(10,25); write('i');
  gotoxy(16,25); write('p'); gotoxy(24,25); write('r');
  gotoxy(32,25); write('w'); gotoxy(41,25); write('q');
  {parancsor}
  textbackground(black); textcolor(lightgray);
  window(1,13,80,24);
  clrscr;
  write('>');
end;

procedure writetotable(x,y:byte; txt: string);                { write to table }
var
  wy: byte;
begin
  wy:=wherey;
  window(1,1,80,25);
  textbackground(blue);
  textcolor(lightcyan);
  gotoxy(x,y);write(txt);
  textbackground(black);
  textcolor(lightgray);
  window(1,13,80,24);
  gotoxy(1,wy);
end;

procedure shell;                                                       { shell }
var
  parameter: string;
  goodparam: boolean;
  command: string;
const
  m1: string='Missing parameter!';
  m2: string='Bad parameter!';
  m3: string='Non-active equipment!';
label
  back;

  procedure h(cs: string);
  begin
    parameter:='';
    goodparam:=false;
    delete(cs,1,1);
    for b:=1 to length(cs) do
      if cs[b]<>' ' then parameter:=parameter+cs[b];
    if parameter=''then
    begin
      writeln('Usage: h i|p|r|w');
      goodparam:=true;
    end;
    if (parameter='i') and (goodparam=false) then
    begin
      writeln('Equipment ID (EqID):');
      writeln('   i 0..15 set');
      writeln('   i       get and set');
      goodparam:=true;
    end;
    if (parameter='p') and (goodparam=false) then
    begin
      writeln('Set port address:');
      writeln('   p 1    378H');
      writeln('   p 2    278H');
      writeln('   p 3    3BCH');
      goodparam:=true;
    end;
    if (parameter='r') and (goodparam=false) then
    begin
      writeln('Read data:');
      writeln('   r 0..7');
      goodparam:=true;
    end;
    if (parameter='w') and (goodparam=false) then
    begin
      writeln('Write data:');
      writeln('   w 0..7 00000000');
      goodparam:=true;
    end;
    if goodparam=false then writeln(m2);
  end;

  procedure ei(cs: string);
  begin
    parameter:='';
    goodparam:=false;
    delete(cs,1,1);
    for b:=1 to length(cs) do
      if cs[b]<>' ' then parameter:=parameter+cs[b];
    if parameter=''then
    begin
      b:=getpxeqid;
      goodparam:=true;
      if getpxresult=true then
      begin
        writeln('ID of the connected equipment: ',b);
        eqid:=b;
        str(b,s);
        writetotable(23,11,s);
      end else
            writeln(m3);
    end else
    begin
      val(parameter,bb,i);
      if (i>0) or (bb>15) then
      begin
        writeln(m2);
        exit;
      end;
      eqid:=bb;
      writetotable(23,11,parameter);
      goodparam:=true;
    end;
    if goodparam=false then writeln(m2);
  end;

  procedure p(cs: string);
  begin
    parameter:='';
    goodparam:=false;
    delete(cs,1,1);
    for b:=1 to length(cs) do
      if cs[b]<>' ' then parameter:=parameter+cs[b];
    if parameter=''then
    begin
      writeln('Usage: p 1|2|3');
      goodparam:=true;
    end;
    if (parameter='1') and (goodparam=false) then
    begin
      pa:=$378;
      setpxport(1);
      goodparam:=true;
      writetotable(9,11,'378H');
    end;
    if (parameter='2') and (goodparam=false) then
    begin
      pa:=$278;
      setpxport(2);
      goodparam:=true;
      writetotable(9,11,'278H');
    end;
    if (parameter='3') and (goodparam=false) then
    begin
      pa:=$3BC;
      setpxport(3);
      goodparam:=true;
      writetotable(9,11,'3BCH');
    end;
    if goodparam=false then writeln(m2);
  end;

  procedure r(cs: string);
  var
    databyte: byte;
    selectlines: char;
  begin
    parameter:='';
    delete(cs,1,1);
    for b:=1 to length(cs) do
      if cs[b]<>' ' then parameter:=parameter+cs[b];
    if parameter='' then
    begin
      writeln('Usage: r y');
      writeln('  - y: selector line number (0..7)');
    end else
    begin
      selectlines:=parameter[1];
      val(selectlines,bb,i);
      if (i>0) or (bb>7) then
      begin
        writeln(m2);
        exit;
      end;
      databyte:=pxread(eqid,bb);
      if getpxresult=false then
      begin
        writeln(m3);
        exit;
      end;
      str(databyte,s);
      writetotable(31,bb+2,'00000000');
      writetotable(39-length(deztobin(s)),bb+2,deztobin(s));
      writetotable(26,bb+2,'000');
      writetotable((29-length(s)),bb+2,s);
      writetotable(22,bb+2,'00');
      writetotable(24-length(deztohex(s)),bb+2,deztohex(s));
    end;
  end;

  procedure w(cs: string);
  var
    outdata: string[9];
    databits: string[8];
  begin
    parameter:='';
    delete(cs,1,1);
    for b:=1 to length(cs) do
      if cs[b]<>' ' then parameter:=parameter+cs[b];
    if parameter=''then
    begin
      writeln('Usage: w y xxxxxxxx');
      writeln('  - y: selector line number (0..7)');
      writeln('  - x: bits of the data (0|1)');
    end else
    begin
      outdata:=parameter;
      selectlines:=outdata[1];
      val(selectlines,bb,i);
      if (i>0) or (bb>7) then
      begin
        writeln(m2);
        exit;
      end;
      databits:='';
      for b:=2 to length(outdata) do
        databits:=databits+outdata[b];
      parameter:='00000000'+databits;
      for b:=1 to length(databits) do
        delete(parameter,1,1);
      databits:=parameter;
      for b:=1 to 8 do
        if (databits[b]<>'0') and (databits[b]<>'1') then
        begin
          writeln(m2);
          exit;
        end;
      val(bintodez(databits),b,i);
      pxwrite(eqid,bb,b);
      if getpxresult=false then
      begin
        writeln(m3);
        exit;
      end;
      writetotable(70,bb+2,databits);
      writetotable(65,bb+2,'000');
      writetotable((68-length(bintodez(databits))),bb+2,bintodez(databits));
      writetotable(61,bb+2,bintohex(databits));
    end;
  end;

begin
  repeat
    back:
    readln(command);
    if length(command)=0 then
    begin
      gotoxy(2,wherey-1);
      goto back;
    end;
    while command[1]=' ' do delete(command,1,1);
    case command[1] of
      'h': h(command);
      'i': ei(command);
      'p': p(command);
      'r': r(command);
      'w': w(command);
      else writeln('Bad command!');
    end;
    write('>');
  until command[1]='q';
end;

procedure exitproc;                                                     { exit }
begin
  window(1,1,80,25);
  textcolor(lightgray);
  textbackground(black);
  clrscr;
  halt(0);
end;

begin
  screen;
  pa:=$378;
  setpxport(1);
  eqid:=0;
  shell;
  exitproc;
end.