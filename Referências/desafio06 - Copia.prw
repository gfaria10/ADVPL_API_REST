#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"

USER FUNCTION tdesa07()
    LOCAL cQuery := ""
    LOCAL cAlias := ""
    LOCAL cMsg := ""
    Local cCod := ""

    PREPARE ENVIRONMENT EMPRESA "99" FILIAL "01" MODULO "COM" TABLES "SB1", "SC6"

    cCod := FWINPUTBOX("Informe o código do produto: ", " ")
    cAlias := GETNEXTALIAS()

    cQuery := "SELECT B1_DESC, C6_NUM "
    cQuery += "FROM "+ RETSQLNAME("SB1") + " AS SB1 "
    cQuery += "INNER JOIN SC6990 ON B1_COD = C6_PRODUTO "
    cQuery += "WHERE B1_COD = '" + cCod + "' "

    TCQUERY cQuery ALIAS &(cAlias) new

    //enquanto nao for final do arquivo
    WHILE !(&(cAlias)->(EOF()))
        cMsg += &(cAlias)->(C6_NUM) + ", " 
        &(cAlias)->(DBSKIP())
    ENDDO
    
    &(cAlias)->(DBCLOSEAREA())
    FWALERTINFO(cMsg)
RETURN
