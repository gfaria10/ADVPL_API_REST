#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"
//p
USER FUNCTION tdesa05()
    Local cDataInicial:= ""
    Local cDataFinal:= ""
    LOCAL cQuery := ""
    LOCAL cAlias := ""
    LOCAL amsg:= ARRAY(3)
    //LOCAL nCont := 0

    PREPARE ENVIRONMENT EMPRESA "99" FILIAL "01" MODULO "COM" TABLES "SB1", "SC6"

    cAlias := GETNEXTALIAS()

    cDataInicial := FWINPUTBOX("Insira uma data inicial: AAAA/MM/DD ", " ")
    cDataFinal := FWINPUTBOX("Insira uma data final: AAAA/MM/DD ", " ")

    cQuery := "SELECT B1_DESC "
    cQuery += "FROM "+ RETSQLNAME("SB1") + " B1 "

    TCQUERY cQuery ALIAS &(cAlias) new

    //enquanto nao for final do arquivo
    WHILE !&(cAlias)->(eof())
        &(cAlias)->(DBSKIP())
        amsg := &(cAlias)->(B1_DESC) //B1_DESC -> 'nome do produto'
        FWALERTINFO(amsg)
    end
    
    &(cAlias)->(DBCLOSEAREA())
RETURN
