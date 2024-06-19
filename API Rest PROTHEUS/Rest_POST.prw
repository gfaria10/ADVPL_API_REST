#include "protheus.ch"
#include "restful.ch"
#INCLUDE "TBICONN.CH"
#INCLUDE "TOPCONN.CH"


//WSRESTFUL ESPECIFICA PRO PROTHEUS QUE IREMOS TRABALHAR COM UMA API, AO INVÉS DE USER FUNCTION
WSRESTFUL PEDIDO_VENDA DESCRIPTION "WEBSERVICE REST PROTHEUS/ADVPL"
	WSMETHOD POST V1 DESCRIPTION "Pedido de venda - POST ao PROTHEUS" PATH "/v1" WSSYNTAX "/V1" TTALK "V1"
END WSRESTFUL


WSMETHOD POST V1 WSSERVICE PEDIDO_VENDA

	Local lRet     := .T.
	Local cJson    := self:GetContent()
	Local oJson    := JsonObject():New()
	Local oJsonRet := JsonObject():New()
	Local aCab     := {}
	Local aItem    := {}
	Local aItens   := {}
	Local i        := 0

	Private lMsErroAuto    := .F.
	Private lMsHelpAuto    := .F.
	Private lAutoErrNoFile := .F.

	::setHeader("Content-Type", "application/json")
	oJson:FromJson(cJson)

	//Obtendo os dados enviados via json no POST
	AADD(aCab, {'C5_FILIAL', cFilAnt, NIL})
	AADD(aCab, {'C5_TIPO', 'N', NIL})
	AADD(aCab, {'C5_CLIENTE', oJson['codigoCliente'], NIL})
	AADD(aCab, {'C5_LOJAENT', oJson['lojaCliente'], NIL})
	AADD(aCab, {'C5_LOJACLI', oJson['lojaCliente'], NIL})
	AADD(aCab, {'C5_P_TPMOV', 'V', NIL})
	AADD(aCab, {'C5_CONDPAG', oJson['condPagto'], NIL})
	AADD(aCab, {'C5_TRANSP', oJson['transportadora'], NIL})

	for i := 1 to LEN(oJson['itens'])

		aItem := {}

		AADD(aItem, {'C6_FILIAL', cFilAnt, NIL})
		AADD(aItem, {'C6_ITEM', oJson['itens'][i]['item'], NIL})
		AADD(aItem, {'C6_PRODUTO', oJson['itens'][i]['codigo'], NIL})
		AADD(aItem, {'C6_UM', Posicione('SB1', 1, xFilial('SB1') + oJson['itens'][i]['codigo'], 'B1_UM' ), NIL})
		AADD(aItem, {'C6_DESCRI', Posicione('SB1', 1, xFilial('SB1') + oJson['itens'][i]['codigo'], 'B1_DESC' ), NIL})
		AADD(aItem, {'C6_TES', '501', NIL})
		AADD(aItem, {'C6_QTDVEN', oJson['itens'][i]['quantidade'], NIL})
		AADD(aItem, {'C6_PRCVEN', oJson['itens'][i]['precoUnitario'], NIL})
		AADD(aItem, {'C6_VALOR', oJson['itens'][i]['quantidade'] * oJson['itens'][i]['precoUnitario'], NIL})
		AADD(aItem, {'C6_LOCAL', '01', NIL})
		AADD(aItem, {'C6_ENTREG', dDataBase, NIL})

		AADD(aItens, aItem)

	next i

	lMsErroAuto := .F.
	lMsHelpAuto := .T.
	lAutoErrNoFile := .T.

	MATA410(aCab, aItens, 3)

	CONOUT('aCab: ' + aCab)
	CONOUT('aItens: ' + aItens)

	if !lMsErroAuto

		oJsonRet['filial'] := SC5->C5_FILIAL
		oJsonRet['numeroPedido'] := SC5->C5_NUM

		lRet := .T.
		self:SetResponse(oJsonRet:toJson())

	else
		CONOUT('MSERRO: ' + lMsErroAuto)
		
		lRet := .F.

		SetRestFault(2,;
					'Falha na inclusão do pedido de venda',;
					.T.,;
					400,;
					'Houve uma falha na leitura dos dados no Json, efetue a correção')

	endif

return lRet
