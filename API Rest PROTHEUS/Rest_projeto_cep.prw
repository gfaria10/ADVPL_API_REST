#include "protheus.ch"
#include "restful.ch"
#INCLUDE "TBICONN.CH"
#INCLUDE "TOPCONN.CH"

//WSRESTFUL ESPECIFICA PRO PROTHEUS QUE IREMOS TRABALHAR COM UMA API, AO INVÉS DE USER FUNCTION
WSRESTFUL cadastro_cep DESCRIPTION "WEBSERVICE REST PROTHEUS/ADVPL"
	WSMETHOD GET DESCRIPTION "Consulta com método GET ao PROTHEUS"
	WSMETHOD POST DESCRIPTION "Criação com método POST ao PROTHEUS" Path "/"
END WSRESTFUL

WSMETHOD GET WSSERVICE cadastro_cep

	Local lRet     := .T.
	Local cQuery   := ""
	Local oJsonRet := JsonObject():New() //JSON DE RETORNO

	cQuery := "SELECT * "
	cQuery += "FROM ZA1990"

	TcQuery cQuery New Alias "QRY"
	DbSelectArea("QRY")

	::setHeader("Content-Type", "application/json")
	//enquanto nao for final do arquivo
	WHILE !QRY->(eof())
		Conout("CEP DO CLIENTE: " + QRY->ZA1_CEP)

		//Retorno Json
		oJsonRet['codigo'] := QRY->ZA1_COD
		oJsonRet['cep'] := QRY->ZA1_CEP
		oJsonRet['logradouro'] := QRY->ZA1_LOGRA
		oJsonRet['complemento'] := QRY->ZA1_COMPL
		oJsonRet['bairro'] := QRY->ZA1_BAIRRO
		oJsonRet['localidade'] := QRY->ZA1_LOCALI
		oJsonRet['uf'] := QRY->ZA1_UF
		cResponse := FWJsonSerialize(oJsonRet, .F., .F., .T.)
		::SetResponse(cResponse)

		QRY->(DBSKIP())
	end

	QRY->(DBCLOSEAREA())

return lRet


WSMETHOD POST WSSERVICE cadastro_cep

	Local lRet     := .T.
	Local aLista   := {}
	Local cJson    := self:GetContent()
	Local oJson    := JsonObject():New()
	Local xRetJson := '' //Usado para validar se o conteúdo é JSON

	Private lMsErroAuto    := .F.
	Private lMsHelpAuto    := .T.
	Private lAutoErrNoFile := .T.

	// Validando se não é vazio
	If !Empty(cJson)

		xRetJson := oJson:FromJSON(cJson) // Convertendo para obj Json

		//Validando se o formato recebido é válido
		If ValType(xRetJson) == "U"

			//Obtendo os dados enviados via json no POST
			AADD(aLista, {'ZA1_COD', oJson['codigo'], NIL})
			AADD(aLista, {'ZA1_CEP', oJson['cep'], NIL})
			AADD(aLista, {'ZA1_LOGRA', oJson['logradouro'], NIL})
			AADD(aLista, {'ZA1_COMPL', oJson['complemento'], NIL})
			AADD(aLista, {'ZA1_BAIRRO', oJson['bairro'], NIL})
			AADD(aLista, {'ZA1_LOCALI', oJson['localidade'], NIL})
			AADD(aLista, {'ZA1_UF', oJson['uf'], NIL})

		Else
			SetRestFault(400, "Falha na leitura do arquivo JSON")
			lRet := .F.
		Endif

	Else
		SetRestFault(400, "Sem conteúdo")
		lRet := .F.
	Endif

	::setHeader("Content-Type", "application/json")
	oJson:FromJson(cJson)

	Conout('CEP INFORMADO: ' + oJson:GetJsonObject('cep'))


	// MATA030(aLista, 3)
	CRMA980(aLista, 3)

return lRet
