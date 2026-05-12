unit U_XMLUtils;

interface

uses
  System.SysUtils,
  System.Variants,
  System.Generics.Collections;

type
  TImpostoInfo = record
    TipoImposto: string;

    OrigemImposto: string;

    CST: string;
    CBenef: string;

    BaseCalculo: Double;
    BaseCalculoReduzida: Double;

    Aliquota: Double;
    PercentualReducao: Double;

    ValorImposto: Double;
    ValorIsento: Double;

    { REFORMA TRIBUTÁRIA }

    BaseIBS: Double;
    AliquotaIBS: Double;
    ValorIBS: Double;

    BaseCBS: Double;
    AliquotaCBS: Double;
    ValorCBS: Double;

    Observacao: string;
  end;

function ExtrairChave(const XML: string): string;
function ExtrairData(const XML: string): TDateTime;
function ExtrairDataISO(const Valor: string): TDateTime;

function ExtrairEmitenteCNPJ(const XML: string): string;
function ExtrairEmitenteNome(const XML: string): string;

function ExtrairDestCNPJ(const XML: string): string;
function ExtrairDestNome(const XML: string): string;

function ExtrairValorTotal(const XML: string): Double;

function ExtrairNumeroNFe(const XML: string): string;
function ExtrairSerieNFe(const XML: string): string;
function ExtrairModeloNFe(const XML: string): string;

function ExtrairDataEmissao(const XML: string): TDateTime;
function ExtrairDataAutorizacao(const XML: string): TDateTime;

function ExtrairUF(const XML: string): string;
function ExtrairCFOPPrincipal(const XML: string): string;
function ExtrairNaturezaOperacao(const XML: string): string;

function ExtrairTipoEvento(const XML: string): string;
function ExtrairDescricaoEvento(const XML: string): string;
function ExtrairDataEvento(const XML: string): TDateTime;

function ExtrairManifestacao(const XML: string): string;

function ExtrairImpostos(const XML: string): TList<TImpostoInfo>;

implementation

uses
  System.DateUtils,
  Xml.XMLDoc,
  Xml.XMLIntf;

{ =======================================================
  HELPERS
  ======================================================= }

function CarregarXML(const XML: string): IXMLDocument;
begin
  Result := TXMLDocument.Create(nil);
  Result.LoadFromXML(XML);
  Result.Active := True;
end;

function FindNodeSafe(Parent: IXMLNode; const NodeName: string): IXMLNode;
begin
  Result := nil;

  if Assigned(Parent) then
    Result := Parent.ChildNodes.FindNode(NodeName);
end;

function GetNodeTextSafe(Parent: IXMLNode; const NodeName: string): string;
var
  Node: IXMLNode;
begin
  Result := '';

  Node := FindNodeSafe(Parent, NodeName);

  if Assigned(Node) then
    Result := Trim(Node.Text);
end;

function StrToFloatNFe(const Valor: string): Double;
begin
  Result := 0;

  if Trim(Valor) <> '' then
    Result := StrToFloatDef(
      StringReplace(Valor, '.', ',', [rfReplaceAll]),
      0
    );
end;

function GetInfNFeNode(Doc: IXMLDocument): IXMLNode;
var
  Node: IXMLNode;
begin
  Result := nil;

  Node := Doc.DocumentElement;

  if not Assigned(Node) then
    Exit;

  if Node.NodeName = 'nfeProc' then
  begin
    Node := FindNodeSafe(Node, 'NFe');
    Node := FindNodeSafe(Node, 'infNFe');

    Result := Node;
  end;
end;

function GetIdeNode(const XML: string): IXMLNode;
var
  Doc: IXMLDocument;
begin
  Result := nil;

  Doc := CarregarXML(XML);

  Result := GetInfNFeNode(Doc);

  if Assigned(Result) then
    Result := FindNodeSafe(Result, 'ide');
end;

function GetEmitNode(const XML: string): IXMLNode;
var
  Doc: IXMLDocument;
begin
  Result := nil;

  Doc := CarregarXML(XML);

  Result := GetInfNFeNode(Doc);

  if Assigned(Result) then
    Result := FindNodeSafe(Result, 'emit');
end;

function GetDestNode(const XML: string): IXMLNode;
var
  Doc: IXMLDocument;
begin
  Result := nil;

  Doc := CarregarXML(XML);

  Result := GetInfNFeNode(Doc);

  if Assigned(Result) then
    Result := FindNodeSafe(Result, 'dest');
end;

function GetICMSTotNode(const XML: string): IXMLNode;
var
  Doc: IXMLDocument;
  Node: IXMLNode;
begin
  Result := nil;

  Doc := CarregarXML(XML);

  Node := GetInfNFeNode(Doc);

  Node := FindNodeSafe(Node, 'total');
  Node := FindNodeSafe(Node, 'ICMSTot');

  Result := Node;
end;

{ =======================================================
  CHAVE / DATAS
  ======================================================= }

function ExtrairChave(const XML: string): string;
var
  Doc: IXMLDocument;
  Node: IXMLNode;
begin
  Result := '';

  Doc := CarregarXML(XML);

  Node := Doc.DocumentElement;

  if not Assigned(Node) then
    Exit;

  // RESUMO
  if Node.NodeName = 'resNFe' then
  begin
    Result := GetNodeTextSafe(Node, 'chNFe');
    Exit;
  end;

  // XML COMPLETO
  if Node.NodeName = 'nfeProc' then
  begin
    Node := GetInfNFeNode(Doc);

    if Assigned(Node) then
      Result := VarToStr(Node.Attributes['Id']);

    if Pos('NFe', Result) = 1 then
      Delete(Result, 1, 3);

    Exit;
  end;

  // EVENTO
  if Node.NodeName = 'procEventoNFe' then
  begin
    Node := FindNodeSafe(Node, 'evento');
    Node := FindNodeSafe(Node, 'infEvento');

    Result := GetNodeTextSafe(Node, 'chNFe');
  end;
end;

function ExtrairDataISO(const Valor: string): TDateTime;
begin
  Result := 0;

  if Trim(Valor) <> '' then
    Result := ISO8601ToDate(Valor, False);
end;

function ExtrairData(const XML: string): TDateTime;
begin
  Result := ExtrairDataEmissao(XML);
end;

function ExtrairDataEmissao(const XML: string): TDateTime;
var
  Node: IXMLNode;
  S: string;
begin
  Result := 0;

  Node := GetIdeNode(XML);

  if not Assigned(Node) then
    Exit;

  S := GetNodeTextSafe(Node, 'dhEmi');

  if S = '' then
    S := GetNodeTextSafe(Node, 'dEmi');

  Result := ExtrairDataISO(S);
end;

function ExtrairDataAutorizacao(const XML: string): TDateTime;
var
  Doc: IXMLDocument;
  Node: IXMLNode;
begin
  Result := 0;

  Doc := CarregarXML(XML);

  Node := FindNodeSafe(Doc.DocumentElement, 'protNFe');
  Node := FindNodeSafe(Node, 'infProt');

  Result := ExtrairDataISO(
    GetNodeTextSafe(Node, 'dhRecbto')
  );
end;

{ =======================================================
  IDENTIFICAÇÃO NF-E
  ======================================================= }

function ExtrairNumeroNFe(const XML: string): string;
var
  Node: IXMLNode;
begin
  Result := '';

  Node := GetIdeNode(XML);

  if Assigned(Node) then
    Result := GetNodeTextSafe(Node, 'nNF');
end;

function ExtrairSerieNFe(const XML: string): string;
var
  Node: IXMLNode;
begin
  Result := '';

  Node := GetIdeNode(XML);

  if Assigned(Node) then
    Result := GetNodeTextSafe(Node, 'serie');
end;

function ExtrairModeloNFe(const XML: string): string;
var
  Node: IXMLNode;
begin
  Result := '';

  Node := GetIdeNode(XML);

  if Assigned(Node) then
    Result := GetNodeTextSafe(Node, 'mod');
end;

{ =======================================================
  EMITENTE
  ======================================================= }

function ExtrairEmitenteCNPJ(const XML: string): string;
var
  Node: IXMLNode;
begin
  Result := '';

  Node := GetEmitNode(XML);

  if Assigned(Node) then
  begin
    Result := GetNodeTextSafe(Node, 'CNPJ');

    if Result = '' then
      Result := GetNodeTextSafe(Node, 'CPF');
  end;
end;

function ExtrairEmitenteNome(const XML: string): string;
var
  Node: IXMLNode;
begin
  Result := '';

  Node := GetEmitNode(XML);

  if Assigned(Node) then
    Result := GetNodeTextSafe(Node, 'xNome');
end;

{ =======================================================
  DESTINATÁRIO
  ======================================================= }

function ExtrairDestCNPJ(const XML: string): string;
var
  Node: IXMLNode;
begin
  Result := '';

  Node := GetDestNode(XML);

  if Assigned(Node) then
  begin
    Result := GetNodeTextSafe(Node, 'CNPJ');

    if Result = '' then
      Result := GetNodeTextSafe(Node, 'CPF');
  end;
end;

function ExtrairDestNome(const XML: string): string;
var
  Node: IXMLNode;
begin
  Result := '';

  Node := GetDestNode(XML);

  if Assigned(Node) then
    Result := GetNodeTextSafe(Node, 'xNome');
end;

{ =======================================================
  TOTAIS
  ======================================================= }

function ExtrairValorTotal(const XML: string): Double;
var
  Node: IXMLNode;
begin
  Result := 0;

  Node := GetICMSTotNode(XML);

  if Assigned(Node) then
    Result := StrToFloatNFe(
      GetNodeTextSafe(Node, 'vNF')
    );
end;

{ =======================================================
  DADOS GERAIS
  ======================================================= }

function ExtrairUF(const XML: string): string;
var
  Emit: IXMLNode;
begin
  Result := '';

  Emit := GetEmitNode(XML);

  Emit := FindNodeSafe(Emit, 'enderEmit');

  if Assigned(Emit) then
    Result := GetNodeTextSafe(Emit, 'UF');
end;

function ExtrairCFOPPrincipal(const XML: string): string;
var
  Doc: IXMLDocument;
  Node: IXMLNode;
begin
  Result := '';

  Doc := CarregarXML(XML);

  Node := GetInfNFeNode(Doc);

  Node := FindNodeSafe(Node, 'det');

  if Assigned(Node) then
  begin
    Node := FindNodeSafe(Node, 'prod');

    Result := GetNodeTextSafe(Node, 'CFOP');
  end;
end;

function ExtrairNaturezaOperacao(const XML: string): string;
var
  Node: IXMLNode;
begin
  Result := '';

  Node := GetIdeNode(XML);

  if Assigned(Node) then
    Result := GetNodeTextSafe(Node, 'natOp');
end;

{ =======================================================
  EVENTOS
  ======================================================= }

function ExtrairTipoEvento(const XML: string): string;
var
  Doc: IXMLDocument;
  Node: IXMLNode;
begin
  Result := '';

  Doc := CarregarXML(XML);

  Node := Doc.DocumentElement;

  if Node.NodeName <> 'procEventoNFe' then
    Exit;

  Node := FindNodeSafe(Node, 'evento');
  Node := FindNodeSafe(Node, 'infEvento');

  Result := GetNodeTextSafe(Node, 'tpEvento');
end;

function ExtrairDescricaoEvento(const XML: string): string;
var
  Doc: IXMLDocument;
  Node: IXMLNode;
begin
  Result := '';

  Doc := CarregarXML(XML);

  Node := Doc.DocumentElement;

  Node := FindNodeSafe(Node, 'evento');
  Node := FindNodeSafe(Node, 'infEvento');
  Node := FindNodeSafe(Node, 'detEvento');

  Result := GetNodeTextSafe(Node, 'descEvento');
end;

function ExtrairDataEvento(const XML: string): TDateTime;
var
  Doc: IXMLDocument;
  Node: IXMLNode;
begin
  Result := 0;

  Doc := CarregarXML(XML);

  Node := Doc.DocumentElement;

  Node := FindNodeSafe(Node, 'evento');
  Node := FindNodeSafe(Node, 'infEvento');

  Result := ExtrairDataISO(
    GetNodeTextSafe(Node, 'dhEvento')
  );
end;

function ExtrairManifestacao(const XML: string): string;
begin
  Result := ExtrairDescricaoEvento(XML);
end;

{ =======================================================
  EXTRAÇÃO DE IMPOSTOS
  ======================================================= }

function ExtrairImpostos(const XML: string): TList<TImpostoInfo>;
var
  Doc: IXMLDocument;
  InfNFe: IXMLNode;
  DetNode: IXMLNode;
  ImpNode: IXMLNode;
  ICMSNode: IXMLNode;

  I: Integer;

  Imposto: TImpostoInfo;
begin
  Result := TList<TImpostoInfo>.Create;

  Doc := CarregarXML(XML);

  InfNFe := GetInfNFeNode(Doc);

  if not Assigned(InfNFe) then
    Exit;

  for I := 0 to InfNFe.ChildNodes.Count - 1 do
  begin
    DetNode := InfNFe.ChildNodes[I];

    if DetNode.NodeName <> 'det' then
      Continue;

    ImpNode := FindNodeSafe(DetNode, 'imposto');

    if not Assigned(ImpNode) then
      Continue;

    FillChar(Imposto, SizeOf(Imposto), 0);

    { =========================
      ICMS
      ========================= }

    ICMSNode := FindNodeSafe(ImpNode, 'ICMS');

    if Assigned(ICMSNode) and (ICMSNode.ChildNodes.Count > 0) then
    begin
      ICMSNode := ICMSNode.ChildNodes[0];

      Imposto.TipoImposto := 'ICMS';

      Imposto.CST :=
        GetNodeTextSafe(ICMSNode, 'CST');

      if Imposto.CST = '' then
        Imposto.CST :=
          GetNodeTextSafe(ICMSNode, 'CSOSN');

      Imposto.CBenef :=
        GetNodeTextSafe(ICMSNode, 'cBenef');

      Imposto.BaseCalculo :=
        StrToFloatNFe(
          GetNodeTextSafe(ICMSNode, 'vBC')
        );

      Imposto.Aliquota :=
        StrToFloatNFe(
          GetNodeTextSafe(ICMSNode, 'pICMS')
        );

      Imposto.PercentualReducao :=
        StrToFloatNFe(
          GetNodeTextSafe(ICMSNode, 'pRedBC')
        );

      Imposto.ValorImposto :=
        StrToFloatNFe(
          GetNodeTextSafe(ICMSNode, 'vICMS')
        );

      Result.Add(Imposto);
    end;

    { =========================
      PIS
      ========================= }

    FillChar(Imposto, SizeOf(Imposto), 0);

    Imposto.TipoImposto := 'PIS';

    Imposto.BaseCalculo :=
      StrToFloatNFe(
        GetNodeTextSafe(ImpNode, 'vBC')
      );

    Imposto.Aliquota :=
      StrToFloatNFe(
        GetNodeTextSafe(ImpNode, 'pPIS')
      );

    Imposto.ValorImposto :=
      StrToFloatNFe(
        GetNodeTextSafe(ImpNode, 'vPIS')
      );

    if Imposto.ValorImposto > 0 then
      Result.Add(Imposto);

    { =========================
      COFINS
      ========================= }

    FillChar(Imposto, SizeOf(Imposto), 0);

    Imposto.TipoImposto := 'COFINS';

    Imposto.BaseCalculo :=
      StrToFloatNFe(
        GetNodeTextSafe(ImpNode, 'vBC')
      );

    Imposto.Aliquota :=
      StrToFloatNFe(
        GetNodeTextSafe(ImpNode, 'pCOFINS')
      );

    Imposto.ValorImposto :=
      StrToFloatNFe(
        GetNodeTextSafe(ImpNode, 'vCOFINS')
      );

    if Imposto.ValorImposto > 0 then
      Result.Add(Imposto);

    { =========================
      IBS (Reforma Tributária)
      =========================  }

    FillChar(Imposto, SizeOf(Imposto), 0);

    Imposto.TipoImposto := 'IBS';

    Imposto.BaseIBS :=
      StrToFloatNFe(
        GetNodeTextSafe(ImpNode, 'vBCIBS')
      );

    Imposto.AliquotaIBS :=
      StrToFloatNFe(
        GetNodeTextSafe(ImpNode, 'pIBS')
      );

    Imposto.ValorIBS :=
      StrToFloatNFe(
        GetNodeTextSafe(ImpNode, 'vIBS')
      );

    if Imposto.ValorIBS > 0 then
      Result.Add(Imposto);

    { =========================
      CBS (Reforma Tributária)
      ========================= }

    FillChar(Imposto, SizeOf(Imposto), 0);

    Imposto.TipoImposto := 'CBS';

    Imposto.BaseCBS :=
      StrToFloatNFe(
        GetNodeTextSafe(ImpNode, 'vBCCBS')
      );

    Imposto.AliquotaCBS :=
      StrToFloatNFe(
        GetNodeTextSafe(ImpNode, 'pCBS')
      );

    Imposto.ValorCBS :=
      StrToFloatNFe(
        GetNodeTextSafe(ImpNode, 'vCBS')
      );

    if Imposto.ValorCBS > 0 then
      Result.Add(Imposto);
  end;
end;

end.
