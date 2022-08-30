{ +--------------------------------------------------------------------------+ }
{ | Extended I/O interface for LPT port                                      | }
{ | Copyright (C) 2010 Pozsar Zsolt <info@pozsarzs.hu>                       | }
{ | lptio.pas                                                                | }
{ | handler routines                                                         | }
{ +--------------------------------------------------------------------------+ }
unit lptio;
interface
uses crt;
var
  PXResult: boolean;                                  { operation error result }
  PN: byte;                                                      { port number }
  b: byte;                                             { general byte variable }
const
  PA: array[1..3] of word=($378,$278,$3BC);                   { port addresses }

procedure SetPXPort(PortNum: byte);
function GetPXResult: boolean;
procedure PXWrite(EqID: byte; Select: byte; OutData: byte);
function PXRead(EqID, Select: byte): byte;
function GetPXEqID: byte;

implementation

procedure SetPXPort(PortNum: byte);                         { set port address }
begin
  PN:=PortNum;
  if (PN=0) or (PN>3) then PXResult:=false else PXResult:=true;
end;

function GetPXResult: boolean;                    { get operation error result }
begin
  GetPXResult:=PXResult;
end;

procedure PXWrite(EqID: byte; Select: byte; OutData: byte);  { write to equip. }
begin
  port[PA[PN]+2]:=$00;                                       { BA+2: 0000 0000 }
  if EqID>$F then begin PXResult:=false; exit; end;
  eqid:= eqid shl 4;
  if Select>$7 then begin PXResult:=false; exit; end;
  port[PA[PN]]:= EqID or Select;                             { BA:   IIII 0SSS }
  port[PA[PN]+2]:=$04;                                       { BA+2: 0000 1000 }
  delay(10);
  port[PA[PN]+2]:=$00;                                       { BA+2: 0000 0000 }
  delay(1);
  b:=port[PA[PN]+1];
  if (b and $08)=$08 then PXResult:=false else PXResult:=true;
  port[PA[PN]]:=OutData;                                     { BA:   DDDD DDDD }
  port[PA[PN]+2]:=$01;                                       { BA+2: 0000 0001 }
  delay(10);
  port[PA[PN]+2]:=$00;                                       { BA+2: 0000 0000 }
  port[PA[PN]]:=$00;                                         { BA:   0000 0000 }
end;

function PXRead(EqID, Select: byte): byte;               { read from equipment }
var
  lb, hb, inb: byte;
begin
  port[PA[PN]+2]:=$00;                                       { BA+2: 0000 0000 }
  if EqID>$F then begin PXResult:=false; exit; end;
  eqid:= eqid shl 4;
  if Select>$7 then begin PXResult:=false; exit; end;
  port[PA[PN]]:= EqID or Select;                             { BA:   IIII 0SSS }
  port[PA[PN]+2]:=$04;
  delay(10);
  port[PA[PN]+2]:=$00;                                       { BA+2: 0000 0000 }
  delay(1);
  b:=port[PA[PN]+1];
  if (b and $08)=$08 then PXResult:=false else PXResult:=true;
  port[PA[PN]]:= $00;                                        { BA:   0000 0000 }
  port[PA[PN]+2]:=$03;                                       { BA+2: 0000 0011 }
  delay(5);
  lb:=port[PA[PN]+1];
  lb:=lb shr 4;
  port[PA[PN]+2]:=$01;                                       { BA+2: 0000 0001 }
  delay(5);
  hb:=port[PA[PN]+1];
  hb:=hb shr 4;
  hb:=hb shl 4;
  port[PA[PN]+2]:=$00;                                       { BA+2: 0000 0000 }
  b:=lb or hb;
  PXRead:=b xor $88;
end;

function GetPXEqID: byte;                              { get equipment ID code }
var
  bb, ei: byte;
label
  break;
begin
  for bb:=0 to 16 do
  begin
    ei:=bb;
    port[PA[PN]+2]:=$00;                                     { BA+2: 0000 0000 }
    ei:= ei shl 4;
    port[PA[PN]]:= ei;
    port[PA[PN]+2]:=$04;                                     { BA+2: 0000 0100 }
    delay(1);
    port[PA[PN]+2]:=$00;                                     { BA+2: 0000 0000 }
    delay(1);
    b:=port[PA[PN]+1];
    if (b and $08)<>$08 then goto break;
  end;
break:
  if bb=16 then PXResult:=false else PXResult:=true;
  GetPXEqID:=bb;
end;

end.