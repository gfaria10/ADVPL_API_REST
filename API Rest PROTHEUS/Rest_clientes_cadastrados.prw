#include "protheus.ch"
#include "restful.ch"
#INCLUDE "TBICONN.CH"
#INCLUDE "TOPCONN.CH"

//WSRESTFUL ESPECIFICA PRO PROTHEUS QUE IREMOS TRABALHAR COM UMA API, AO INVÉS DE USER FUNCTION
WSRESTFUL CLIENTES_CADASTRADOS DESCRIPTION "WEBSERVICE REST PROTHEUS/ADVPL"
	WSMETHOD GET DESCRIPTION "Consulta com método GET ao PROTHEUS"
	WSMETHOD POST DESCRIPTION "Criação com método POST ao PROTHEUS"
END WSRESTFUL

WSMETHOD GET WSSERVICE CLIENTES_CADASTRADOS

	Local lRet     := .T.
	Local cQuery   := ""
	Local oJsonRet := JsonObject():New() //JSON DE RETORNO

	cQuery := "SELECT * "
	cQuery += "FROM SA1990"

	TcQuery cQuery New Alias "QRY"
	DbSelectArea("QRY")

	::setHeader("Content-Type", "application/json")
	//enquanto nao for final do arquivo
	WHILE !QRY->(eof())
		Conout("NOME DO CLIENTE: " + QRY->A1_NOME)

		//Retorno Json
		oJsonRet['nomeCliente'] := QRY->A1_NOME
		oJsonRet['cidade'] := QRY->A1_MUN
		oJsonRet['estado'] := QRY->A1_EST
		oJsonRet['tipoCliente'] := QRY->A1_TIPO
		cResponse := FWJsonSerialize(oJsonRet, .F., .F., .T.)
		::SetResponse(cResponse)

		QRY->(DBSKIP())
	end

	QRY->(DBCLOSEAREA())

	// ::setResponse('{"Clientes": ' + oJsonRet:GetJsonObject(QRY) + '}')
return lRet


WSMETHOD POST WSSERVICE CLIENTES_CADASTRADOS

	Local lRet     := .T.
	Local aLista   := {}
	Local cJson    := self:GetContent()
	Local oJson    := JsonObject():New()
	// Local oJsonRet := JsonObject():New() //JSON DE RETORNO

	::setHeader("Content-Type", "application/json")
	oJson:FromJson(cJson)

	Conout('01: ' + oJson:GetJsonObject('codigo'))
	Conout('02: ' + oJson['codigo'])

	//Obtendo os dados enviados via json no POST
	AADD(aLista, {'A1_COD', oJson['codigo'], NIL})
	AADD(aLista, {'A1_NOME', oJson['nome'], NIL})
	AADD(aLista, {'A1_LOJA', oJson['loja'], NIL})
	AADD(aLista, {'A1_PESSOA', oJson['pessoa'], NIL})
	AADD(aLista, {'A1_NREDUZ', oJson['nomeReduzido'], NIL})
	AADD(aLista, {'A1_TIPO', oJson['tipo'], NIL})
	AADD(aLista, {'A1_EST', oJson['estado'], NIL})
	AADD(aLista, {'A1_MUN', oJson['municipio'], NIL})

	// MATA030(aLista, 3)
	CRMA980(aLista, 3)

	// oJsonRet['codigo'] := SA1->A1_COD
	// oJsonRet['nome'] := SA1->A1_NOME
	// self:SetResponse(oJsonRet:toJson())

	// IF !Empty(cError)
	// 	SetRestFault(500,'Parser Json Error')
	// 	lRet := .F.
	// Else
	// 	CONOUT("Dados enviados: " + (AllTrim(oJson:GetJsonObject('nomeCliente'))))

	// 	QRY->A1_NOME = oJson:GetJsonObject('nomeCliente') // Altera o valor no banco de dados
	// 	QRY->(DbCommit()) // Salva as alterações no banco de dados
	// ENDIF

	// QRY->(DBCLOSEAREA())

	// ::setResponse('{"Clientes": ' + oJsonRet:GetJsonObject(QRY) + '}')
return lRet
