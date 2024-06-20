#include 'protheus.ch'
#include 'Restful.ch'
#include 'tbiconn.ch'

WSRESTFUL CLIENTES_CADASTRADOS_02 DESCRIPTION "Crud para cadastro de clientes" FORMAT "application/json"
	
	WSDATA A1_COD  as String Optional
	WSDATA A1_LOJA as String Optional

	WSMETHOD GET  DESCRIPTION 'Lista de Clientes'    WSSYNTAX '/clientes/{}'
	WSMETHOD POST DESCRIPTION 'Inclusão de Clientes' WSSYNTAX '/clientes/{}'
	WSMETHOD PUT  DESCRIPTION 'Alteração de Clientes'WSSYNTAX '/clientes/{A1_COD,A1_LOJA}'
	WSMETHOD DELETE DESCRIPTION 'Deleção de Clientes'WSSYNTAX '/clientes/{A1_COD,A1_LOJA}'	

END WSRESTFUL

WSMETHOD GET WSSERVICE CLIENTES_CADASTRADOS_02
	Local lRet 		:= .T.
	Local oResponse	:= JsonObject():New()
	
	::SetContentType('application/json')
	
	oResponse['status'] := 200
	oResponse['dados']	:= {}

	SA1->(DbSetOrder(1))
	SA1->(DbGoTop())
	While SA1->(!Eof())

		oJsonSA1			:= JsonObject():New()
		
		oJsonSA1['A1_COD']	:= SA1->A1_COD
		oJsonSA1['A1_LOJA'] := SA1->A1_LOJA
		oJsonSA1['A1_NOME']	:= Alltrim(SA1->A1_NOME)
		oJsonSA1['A1_NREDUZ']:= Alltrim(SA1->A1_NREDUZ)
		oJsonSA1['A1_TIPO']	:= SA1->A1_TIPO
		oJsonSA1['A1_END']	:= Alltrim(SA1->A1_END)
		oJsonSA1['A1_EST']	:= SA1->A1_EST
		oJsonSA1['A1_MUN']	:= Alltrim(SA1->A1_MUN)
		
		aAdd(oResponse['dados'], oJsonSA1)
		
		SA1->(DbSkip())
	EndDo
	
	::SetResponse(oResponse:ToJson())


Return lRet 

WSMETHOD POST WSSERVICE CLIENTES_CADASTRADOS_02
	Local lRet := .T.
	Local cJson:= ::getContent()
	Local aRet := {}
	Local oResponse, oJson
	
	::SetContentType()
	
	conout(cJson)
	
	oResponse	:= JsonObject():New()
	oJson		:= JsonObject():New()
	
	oJson:FromJson(cJson)
	
	aRet		:= restCliente(oJson, 3)
	
	If aRet[1]
		oResponse['status'] := 201
		oResponse['message']:= aRet[2]
		::SetResponse(oResponse:toJson())
	Else
		lRet := .F.
		SetRestFault(400, aRet[2])
	EndIf
	

Return lRet

Static Function restCliente(oJson, nOpc, cCodCli, cLoja)
	Local aRet 		:= {}
	Local aDados	:= {}
	Local cArqErro	:= 'erroauto.txt'
	Local cMsg
	
	Private lMsErroAuto := .F.
	
	If nOpc == 4 .OR. nOpc == 5
		aAdd(aDados,{'A1_COD'	, cCodCli	, nil})	
		aAdd(aDados,{'A1_LOJA'	, cLoja		, nil})
	EndIf
	
	If nOpc <> 5
		aAdd(aDados,{'A1_NOME'	, oJson['A1_NOME']	, nil})
		aAdd(aDados,{'A1_NREDUZ', oJson['A1_NREDUZ'], nil})	
		aAdd(aDados,{'A1_TIPO'	, oJson['A1_TIPO']	, nil})
		aAdd(aDados,{'A1_END'	, oJson['A1_END']	, nil})
		aAdd(aDados,{'A1_EST'	, oJson['A1_EST']	, nil})	
		aAdd(aDados,{'A1_MUN'	, oJson['A1_MUN']	, nil})
	EndIf

	MSExecAuto({|x,y| Mata030(x,y)},aDados,nOpc)

	If lMsErroAuto
		MostraErro('\system\', cArqErro)
		cMsg := MemoRead('\system\' + cArqErro)
		aRet := {.F., cMsg}
	Else

		If nOpc == 3
			cMsgRet := 'incluido'
		ElseIf nOpc == 4
			cMsgRet := 'alterado'		
		ElseIf nOpc == 5
			cMsgRet := 'excluido'
		EndIf
	
		aRet := {.T., 'Cliente '+cMsgRet+' com sucesso.'}

	EndIf
	
Return aRet
