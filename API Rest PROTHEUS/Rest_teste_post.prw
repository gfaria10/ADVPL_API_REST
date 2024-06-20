#include 'protheus.ch'
#include 'restful.ch'

/*
______________________________________________________________________________
|_____________________________________________________________________________|
|Programa  -     Autor  Fabricio Antunes      Data   07/04/2020 	          |
|_____________________________________________________________________________|
|Descricao|Aula 6 WebService Rest/Json                                        |
|         |                                                                   |
|_________|___________________________________________________________________|
|Uso      |                                                                   | 
|_________|___________________________________________________________________|
|_____________________________________________________________________________|
*/

// Exemplos com status HTTP
WsRestful ReceberJson Description "Exemplos com JSON na requisicao" Format APPLICATION_JSON
    WsMethod POST Root Description "Recebe um JSON e mostra alguns dados no console" Path "/"
End WsRestful

WsMethod POST Root WsRestful ReceberJson
    // `::GetContent()` retorna o corpo da requisicao em bytes
    Local cCorpo := ::GetContent()
    // Objeto que ira guardar o JSON de entrada
    Local oJson := JsonObject():New()

    // Parsing da entrada
    oJson:FromJson( cCorpo )

    // Para fins didaticos, apenas exibimos os valores de "nome" e "idade"
    // no terminal
    ConOut( oJson[ "nome" ] )
    ConOut( oJson[ "idade" ] )

    // Hora de limpar a bagunca
    FreeObj( oJson )
Return .T.
