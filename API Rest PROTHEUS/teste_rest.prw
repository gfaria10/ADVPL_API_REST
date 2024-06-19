#include "protheus.ch"
#include "restful.ch"
#INCLUDE "TBICONN.CH"
#INCLUDE "TOPCONN.CH"


//WSRESTFUL ESPECIFICA PRO PROTHEUS QUE IREMOS TRABALHAR COM UMA API, AO INVÉS DE USER FUNCTION
WSRESTFUL TESTE_NOVO_ENDPOINT_CLIENTES DESCRIPTION "WEBSERVICE REST PROTHEUS/ADVPL"
	WSMETHOD GET DESCRIPTION "Consulta com método GET ao PROTHEUS"
	WSMETHOD POST DESCRIPTION "Criação com método POST ao PROTHEUS"
END WSRESTFUL

WSMETHOD GET WSSERVICE TESTE_NOVO_ENDPOINT_CLIENTES
	Local lRet := .T.
	Local cQuery := ""
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
// ::setResponse('{"Clientes": ' + oJsonRet:GetJsonObject(QRY) +'}')

return lRet
