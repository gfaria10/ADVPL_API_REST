#include "protheus.ch"
#include "restful.ch"


//WSRESTFUL ESPECIFICA PRO PROTHEUS QUE IREMOS TRABALHAR COM UMA API, AO INVÉS DE USER FUNCTION
WSRESTFUL helloworld DESCRIPTION "Meu Primeiro serviço REST!"
    WSMETHOD GET DESCRIPTION "Retornar um Hello, World" 
END WSRESTFUL

WSMETHOD GET WSSERVICE helloworld
    ::setHeader("Content-Type", "application/json")
    ::setResponse('[{"Status":"Hello, World"}]')
return .T.
