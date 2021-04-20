/********************************************************************************
*                         Copyright 2012 - Cloud2b
********************************************************************************
* Classe que cancelará um pedido e marcará seus itens como cancelados.
* NAME: CancelarPedido.CLS
* AUTHOR: RICARDO GONÇALVES DIAS                     DATE: 28/03/2012
*
* MAINTENANCE: INSERIDO FUNCIONALIDADE QUE VALIDA O ID DO TIPO DE REGISTRO DOS 
* OBJETOS.
* AUTHOR: CARLOS CARVALHO                               DATE: 09/01/2013 
********************************************************************************/
/********************************************************************************
* 
* MIGRACION LICENCIAS 
* AUTHOR: ZIMMIC                     DATE: 02/11/2016
*
********************************************************************************/
global class CancelarPedido {
    
    //MIGRATED 02/11/2016 
    Webservice static void RealizarCancelamento(String idOportunidade){
        
        if(!Utils.wasMigrationDone('1')){
                //Declaração de variáveis
            String mensagemRetorno = null;
            Set< Id > setRecTypeOpp = new Set< Id >();
            
            //Recupera os ids dos tipos de registro
            setRecTypeOpp.add( RecordTypeForTest.getRecType('Opportunity', 'Bloqueia_alteracao'));
            setRecTypeOpp.add( RecordTypeForTest.getRecType('Opportunity', 'Bloqueia_alteracao_do_cabecalho'));
            setRecTypeOpp.add( RecordTypeForTest.getRecType('Opportunity', 'Nova_oportunidade'));
            
            Opportunity oportunidadeAtual = [ SELECT id, CD_Action__c, Cancelar_pedido__c 
                                                     FROM Opportunity WHERE id = :idOportunidade 
                                                     AND RecordTypeId =: setRecTypeOpp ];
                                                     
            oportunidadeAtual.Cancelar_pedido__c = true;
            oportunidadeAtual.CD_Action__c = 'C';
            update oportunidadeAtual;
            
            List<OpportunityLineItem> oportunidadeLista = [ SELECT id, CD_Action__c, Remover__c 
                                                                   FROM OpportunityLineItem 
                                                                   WHERE OpportunityId = :idOportunidade];
            
            for(OpportunityLineItem item : oportunidadeLista){
                item.CD_Action__c = 'C';
                item.Remover__c = true;
            }
                
            update oportunidadeLista;

        } else
           {
                //Declaração de variáveis
            String mensagemRetorno = null;
            Set< Id > setRecTypeOpp = new Set< Id >();
            
            //Recupera os ids dos tipos de registro
            setRecTypeOpp.add( RecordTypeForTest.getRecType('LAT_Opportunity__c', 'Bloqueia_alteracao'));
            setRecTypeOpp.add( RecordTypeForTest.getRecType('LAT_Opportunity__c', 'Bloqueia_alteracao_do_cabecalho'));
            setRecTypeOpp.add( RecordTypeForTest.getRecType('LAT_Opportunity__c', 'Nova_oportunidade'));
            
            LAT_Opportunity__c oportunidadeAtual = [ SELECT id, LAT_CDAction__c, LAT_CancelOrder__c 
                                                     FROM LAT_Opportunity__c WHERE id = :idOportunidade 
                                                     AND RecordTypeId =: setRecTypeOpp ];
                                                     
            oportunidadeAtual.LAT_CancelOrder__c = true;
            oportunidadeAtual.LAT_CDAction__c = 'C';
            update oportunidadeAtual;
            
            List<LAT_OpportunityLineItem__c> oportunidadeLista = [ SELECT id, LAT_CDAction__c, LAT_Remover__c 
                                                                   FROM LAT_OpportunityLineItem__c 
                                                                   WHERE LAT_Opportunity__c = :idOportunidade];
            
            for(LAT_OpportunityLineItem__c item : oportunidadeLista){
                item.LAT_CDAction__c = 'C';
                item.LAT_Remover__c = true;
            }
                    
            update oportunidadeLista;

        }
        
    }
}