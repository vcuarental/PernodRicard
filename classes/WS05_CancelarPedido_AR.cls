/**********************************************
 Dev: Juan Pablo Cubo       Version: 1
**********************************************/
 /********************************************************************************
* 
* MIGRACION LICENCIAS 
* AUTHOR: ZIMMIC                     DATE: 16/11/2016
*
********************************************************************************/

global class WS05_CancelarPedido_AR {

    Webservice static boolean RealizarCancelamento(String idOportunidade){
        
        //Declaração de variáveis
        String mensagemRetorno = null;
        Set< Id > setRecTypeOpp = new Set< Id >();
        
        //Recupera os ids dos tipos de registro
        setRecTypeOpp.add( RecordTypeForTest.getRecType( 'Opportunity', 'OPP_1_NewOrder_ARG' ) );
        setRecTypeOpp.add( RecordTypeForTest.getRecType( 'Opportunity', 'OPP_2_NewOrder_URU' ) );
        setRecTypeOpp.add( RecordTypeForTest.getRecType( 'Opportunity', 'OPP_3_HeaderBlocked_ARG' ) );
        setRecTypeOpp.add( RecordTypeForTest.getRecType( 'Opportunity', 'OPP_4_HeaderBlocked_URU' ) );
        setRecTypeOpp.add( RecordTypeForTest.getRecType( 'Opportunity', 'OPP_5_OrderBlocked_ARG' ) );
        setRecTypeOpp.add( RecordTypeForTest.getRecType( 'Opportunity', 'OPP_6_OrderBlocked_URU' ) );
        
        Opportunity oportunidadeAtual = [ SELECT id, CD_Action__c, Cancelar_pedido__c 
                                                 FROM Opportunity WHERE id = :idOportunidade 
                                                 AND RecordTypeId =: setRecTypeOpp ];
                                                 
        
        List<OpportunityLineItem> oportunidadeLista = [ SELECT id, CD_Action__c, Remover__c, cd_line_status__c
                                                               FROM OpportunityLineItem 
                                                               WHERE OpportunityId = :idOportunidade];

        /*for(OpportunityLineItem item : oportunidadeLista){
            try {
              integer intStatus = Integer.valueOf(item.cd_line_status__c);
              if (intStatus > 540) {
                return false;
              }
            } catch (Exception ex) {
                return false;
            }
            
        }*/
        
        oportunidadeAtual.Cancelar_pedido__c = true;
        oportunidadeAtual.CD_Action__c = 'C';
        
        for(OpportunityLineItem item : oportunidadeLista){
            try {
                integer intStatus = Integer.valueOf(item.cd_line_status__c);
                if (intStatus <= 540) {
                    item.CD_Action__c = 'C';
                    item.Remover__c = true;
                }
            } catch (Exception ex) {
                
            }
        }
        update oportunidadeAtual;
        update oportunidadeLista;
        return true;
    }
    //MIGRATED 16/11/2016
    Webservice static boolean LAT_RealizarCancelamento(String idOportunidade){
        
        //Declaração de variáveis
        String mensagemRetorno = null;
        Set< Id > setRecTypeOpp = new Set< Id >();
        
        //Recupera os ids dos tipos de registro
        setRecTypeOpp.add( RecordTypeForTest.getRecType( 'LAT_Opportunity__c', 'OPP_1_NewOrder_ARG' ) );
        setRecTypeOpp.add( RecordTypeForTest.getRecType( 'LAT_Opportunity__c', 'OPP_2_NewOrder_URU' ) );
        setRecTypeOpp.add( RecordTypeForTest.getRecType( 'LAT_Opportunity__c', 'OPP_3_HeaderBlocked_ARG' ) );
        setRecTypeOpp.add( RecordTypeForTest.getRecType( 'LAT_Opportunity__c', 'OPP_4_HeaderBlocked_URU' ) );
        setRecTypeOpp.add( RecordTypeForTest.getRecType( 'LAT_Opportunity__c', 'OPP_5_OrderBlocked_ARG' ) );
        setRecTypeOpp.add( RecordTypeForTest.getRecType( 'LAT_Opportunity__c', 'OPP_6_OrderBlocked_URU' ) );
        
        LAT_Opportunity__c oportunidadeAtual = [ SELECT id, LAT_CDAction__c, LAT_CancelOrder__c 
                                                 FROM LAT_Opportunity__c WHERE id = :idOportunidade 
                                                 AND RecordTypeId =: setRecTypeOpp ];
                                                 
        
        List<LAT_OpportunityLineItem__c> oportunidadeLista = [ SELECT id, LAT_CDAction__c, LAT_Remover__c, LAT_CdLineStatus__c
                                                               FROM LAT_OpportunityLineItem__c 
                                                               WHERE LAT_Opportunity__c = :idOportunidade];

        /*for(OpportunityLineItem item : oportunidadeLista){
            try {
              integer intStatus = Integer.valueOf(item.cd_line_status__c);
              if (intStatus > 540) {
                return false;
              }
            } catch (Exception ex) {
                return false;
            }
            
        }*/
        
        oportunidadeAtual.LAT_CancelOrder__c = true;
        oportunidadeAtual.LAT_CDAction__c = 'C';
        
        for(LAT_OpportunityLineItem__c item : oportunidadeLista){
            try {
                integer intStatus = Integer.valueOf(item.LAT_CdLineStatus__c);
                if (intStatus <= 540) {
                    item.LAT_CDAction__c = 'C';
                    item.LAT_Remover__c = true;
                }
            } catch (Exception ex) {
                
            }
        }
        update oportunidadeAtual;
        update oportunidadeLista;
        return true;
    }

    
}