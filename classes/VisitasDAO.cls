/********************************************************************************
*                         Copyright 2012 - Cloud2b
********************************************************************************
* Classe que realiza funções DML no objeto Visitas (Objeto customizado).
*
* NAME: VisitasDAO.cls
* AUTHOR: CARLOS CARVALHO                          DATE: 26/04/2012 
*
* MAINTENANCE: INSERIDO CLAUSULA "Status__c <>: 'Encerrada'" NO MÉTODO
* getListVisitasByPlanejamento.
* AUTHOR: CARLOS CARVALHO                          DATE: 24/09/2012
*
* MAINTENANCE 
* AUTHOR: CARLOS CARVALHO                               DATE: 08/01/2013
* DESC: INSERIDO FUNCIONALIDADE QUE VALIDA O ID DO TIPO DE REGISTRO DOS OBJETOS.
********************************************************************************/
public with sharing class VisitasDAO 
{
    private static final VisitasDAO instance = new VisitasDAO();
    private Set< Id > setRecType = getIds();
    
    private Set< Id > getIds(){
        Set< Id > lSet = new Set< Id >();
        //lSet.add( RecordTypeForTest.getRecType( 'Visitas__c', 'BRA_Standard' ));
        for(RecordType rt :[SELECT Id, IsActive, SobjectType, Name, DeveloperName FROM RecordType WHERE IsActive=True AND SobjectType='Visitas__c']){
            if(rt.DeveloperName=='BRA_Standard'){
              lSet.add(rt.Id);
            }else if(rt.DeveloperName=='VTS_Standard_AR'){
              lSet.add(rt.Id);  
            }else if(rt.DeveloperName=='VTS_Standard_UY'){
              lSet.add(rt.Id);
            }
        }
        return lSet;
    }
    //Construtor privado para impedir a criação de instâncias dessa classe.
    private VisitasDAO()
    {
    }
    
    //Método responsável por prover a instância dessa classe.
    public static VisitasDAO getInstance()
    {
        return instance;
    }
    
    //Método responsável por recuperar uma lista de visita de um determinado planejamento.
    //@param aPlanejamentos (Ids dos planejamentos que serão recuperados).
    public List<Visitas__c> getListVisitasByPlanejamento( List< String > aPlanejamentos ){
    
        return [ SELECT Id, Name, Conta__r.Channel__c, Conta__r.Name, Hora_da_Visita__c, 
                    Visita_n_o_realizada__c, Data_da_Visita__c, Resumo_da_Visita__c, 
                    Planejamento__r.OwnerId, Tipo_de_Visita__c, Conta__r.Channel_Type__c 
                    FROM Visitas__c WHERE Planejamento__c =: aPlanejamentos 
                    AND Status__c <>: 'Encerrada' AND RecordTypeId =: setRecType ];
    
    }
}