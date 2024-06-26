#include "protheus.ch"
#include "restful.ch"
#INCLUDE "TBICONN.CH"
#INCLUDE "TOPCONN.CH"

// REFERENCIAS: https://devforum.totvs.com.br/1910-utilizacao-de-execauto-para-axcadastro-personalizada

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
	Local cJson    := self:GetContent()
	Local oJson    := JsonObject():New()
	Local xRetJson := ''
	Local oModel

	Private lMsErroAuto    := .F.
	Private lMsHelpAuto    := .T.
	Private lAutoErrNoFile := .T.

	PREPARE ENVIRONMENT EMPRESA "99" FILIAL "01"

    // Verifica se é uma requisição OPTIONS (preflight)
    // If (self:getRequestMethod() == "OPTIONS")
    //     self:setHeader("Access-Control-Allow-Origin", "http://fluig.fsw.totvsip.com.br:9191")
    //     self:setHeader("Access-Control-Allow-Methods", "POST, GET, OPTIONS")
    //     self:setHeader("Access-Control-Allow-Headers", "Content-Type, Authorization")
    //     self:setHeader("Access-Control-Max-Age", "86400") // Cache da resposta preflight por 24 horas
    //     self:sendResponse(204, "") // Responde com status 204 No Content
    //     Return
    // EndIf

	If !Empty(cJson)
		xRetJson := oJson:FromJSON(cJson)

		If ValType(xRetJson) == "U"
			// Carrega o modelo usando o nome correto
			oModel := FwLoadModel("MVCZA1")

			If oModel == Nil
				SetRestFault(500, "Erro ao carregar o modelo! Modelo MVCZA1M não encontrado.")
				Return .F.
			EndIf

			oModel:SetOperation(3)
			oModel:Activate()

			oModel:SetValue("FORMZA1", "ZA1_COD", oJson['codigo'])
			oModel:SetValue("FORMZA1", "ZA1_CEP", oJson['cep'])
			oModel:SetValue("FORMZA1", "ZA1_LOGRA", oJson['logradouro'])
			oModel:SetValue("FORMZA1", "ZA1_COMPL", oJson['complemento'])
			oModel:SetValue("FORMZA1", "ZA1_BAIRRO", oJson['bairro'])
			oModel:SetValue("FORMZA1", "ZA1_LOCALI", oJson['localidade'])
			oModel:SetValue("FORMZA1", "ZA1_UF", oJson['uf'])

			If oModel:VldData()
				oModel:CommitData()
				Conout("Registro INCLUIDO!")
			Else
				SetRestFault(500, "Erro ao incluir: " + oModel:GetErrorMessage())
				lRet := .F.
			EndIf

			oModel:DeActivate()
			oModel:Destroy()
			oModel := Nil

		Else
			SetRestFault(400, "Falha na leitura do arquivo JSON")
			lRet := .F.
		EndIf

	Else
		SetRestFault(400, "Sem conteúdo")
		lRet := .F.
	EndIf

	::setHeader("Content-Type", "application/json")
	::setHeader("Access-Control-Allow-Origin", "http://fluig.fsw.totvsip.com.br:9191")
	::setHeader("Access-Control-Allow-Methods", "POST, GET, OPTIONS")

Return lRet
