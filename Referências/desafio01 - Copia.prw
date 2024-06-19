//Includes são os dicinonários do Framework da Linguagem ADVPL para "tradução" do fonte que criamos, no momento da compilação
#INCLUDE "TOTVS.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"

//Funcaoo principal, chamada para a execução da rotina de notas dos alunos
User Function testeSelect()

//Variaveis locais
Local nConsulta
PREPARE ENVIRONMENT EMPRESA "99" FILIAL "01"

nConsulta := u_Consulta()
Return

User Function Consulta()

Local cQry :=" "
Local lRet := .T.
Local cProd:= M->C2_PRODUTO
Local cTipo := SB1->B1_TIPO // a tabela de produto j� deve estar posicionada

     if cTipo == 'PI'
          if SELECT("SG10") > 0
               SG10->(dbclosearea())
          endif

          // VERIFICA SE O PRODUTO EXISTE NA SG1
          cQry:= " SELECT G1_COD "
          cQry+= " FROM "+RetSQLName("SG1")
          cQry+= " WHERE G1_FILIAL = '"+xFilial("SG1")+"' AND D_E_L_E_T_= ' ' "
          cQry+= " AND G1_COD = '"+cProd+"' "

          dbUseArea(.T.,"TOPCONN", TCGenQry(,,cQry),"SG10", .F., .T.)

          lRet := !SG10->(EOF())

          if !lRet // se for fim de arquivo
               MsgStop("Produto sem estrutura - Verifique !")
          endif

          SG10->(dbclosearea())

     endif

Return(lRet)
