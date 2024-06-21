#include "tbiconn.ch"
#include "PROTHEUS.CH"
#include "FWMVCDEF.CH"
// ****************************************************************************
// *************** ATENÇÃO: ESTA FUNÇÃO NÃO PODE SER OMSA090¹ *****************
// ****************************************************************************
// ¹ O nome User Function OMSA090 é reservado para o PE padrão do MVC
User Function OMSA090I()
	Local oModel, oModelcab, oModelCli

	Local _cEmpresa := "99" // Código da Empresa que deseja manipular
	Local _cFilial  := "01" // Código da Filial que deseja manipular

	PREPARE ENVIRONMENT EMPRESA _cEmpresa FILIAL _cFilial MODULO "OMS"

	SetFunName("OMSA090")

	oModel    := FwLoadModel("OMSA090")
	oModelCab := oModel:GetModel("MdFieldCDA7")
	oModelCli := oModel:GetModel("MdGridDA7F1")

	oModel:SetOperation(MODEL_OPERATION_INSERT) // Seta operação de inclusão
	oModel:Activate() // Ativa o Modelo

	oModelCab:SetValue("DA7_PERCUR","ZONTST")
	oModelCab:SetValue("DA7_ROTA"  ,"SET002")

	oModelCli:SetValue("DA7_SEQUEN","000001")
	oModelCli:SetValue("DA7_CLIENT","L00001")
	oModelCli:SetValue("DA7_LOJA","01")

	oModelCli:AddLine()
	oModelCli:SetValue("DA7_SEQUEN","000002")
	oModelCli:SetValue("DA7_CLIENT","L00001")
	oModelCli:SetValue("DA7_LOJA","02")

	oModelCli:AddLine()
	oModelCli:SetValue("DA7_SEQUEN","000003")
	oModelCli:SetValue("DA7_CLIENT","L00001")
	oModelCli:SetValue("DA7_LOJA","03")

	//Validação e Gravação do Modelo
	If oModel:VldData()
		oModel:CommitData()
	Else
		VarInfo("Erro",oModel:GetErrorMessage())
	EndIf

	RESET ENVIRONMENT
Return


Static Function IncluirRegistroMVCZA1()
    Local oModel := Nil
    Local cCampo1 := "Valor1"  // Exemplo de valor para CAMPO1
    Local nCampo2 := 1234      // Exemplo de valor para CAMPO2
    Local dCampo3 := Date()    // Exemplo de valor para CAMPO3

    // Carrega o modelo MVCZA1
    oModel := FwLoadModel("MVCZA1")

    // Verifica se o modelo foi carregado corretamente
    If oModel == Nil
        MsgStop("Erro ao carregar o modelo!")
        Return Nil
    EndIf

    // Define a operação como INSERT
    oModel:SetOperation(MODEL_OPERATION_INSERT)
    oModel:Activate()

    // Define os valores dos campos
    oModel:SetValue("NOMETABELA", "CAMPO1", cCampo1)
    oModel:SetValue("NOMETABELA", "CAMPO2", nCampo2)
    oModel:SetValue("NOMETABELA", "CAMPO3", dCampo3)

    // Valida e comita os dados
    If oModel:VldData()
        oModel:CommitData()
        conout("Registro INCLUIDO!")
    Else
        VarInfo("Erro ao incluir", oModel:GetErrorMessage())
    EndIf

    // Desativa e destrói o modelo
    oModel:DeActivate()
    oModel:Destroy()
    oModel := Nil

    Return Nil
