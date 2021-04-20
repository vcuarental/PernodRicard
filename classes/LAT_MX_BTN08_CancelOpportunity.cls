/**********************************************************************************************************************************
*   Company:  Valuenet           Developers:  Elena J. Schwarzböck                                                                *
*      Date:  03/12/2013        Descripcion:  Cancels the Opportunity if the conditions are ok                                    *  
***********************************************************************************************************************************/
/********************************************************************************
*                       
* MIGRACION LICENCIAS 
* AUTHOR: ZIMMIC                     DATE: 04/11/2016
*
********************************************************************************/
global without sharing class LAT_MX_BTN08_CancelOpportunity{
   
    webService static String CancelsOpportunity(String idOpp){
        if(!Utils.wasMigrationDone('12')) {     
            Opportunity opp = [SELECT Id, LAT_MX_OppCancellationReason__c, RecordTypeId, StageName, NR_order_JDE__c FROM Opportunity WHERE Id =: idOpp];
            
            if(opp.RecordTypeId != Global_RecordTypeCache.getRtId('Opportunity' + 'LAT_MX_OPP_HeaderBlocked')){
                return 'Error: ' + label.LAT_MX_BTN08_00001;
                //LAT_MX_BTN08_00001: Solo pedidos con tipo de registro Cabecera bloqueada pueden ser cancelados.
            }
            if(opp.StageName != 'Pedido processado no JDE'){
                return 'Error: ' + label.LAT_MX_BTN08_00002;
                //LAT_MX_BTN08_00002: Solo se puede cancelar pedidos con Estado = Pedido generado.
            }
            if(opp.NR_order_JDE__c == null){
                return 'Error: ' + label.LAT_MX_BTN08_00003;
                //LAT_MX_BTN08_00003: No se pueden cancelar pedidos que no fueron enviados a JDE.';
            }
            if(opp.LAT_MX_OppCancellationReason__c == null){
                return 'Error: ' + label.LAT_MX_BTN08_00004; 
                //LAT_MX_BTN08_00004: No es posible cancelar un pedido si no se ha especificado el motivo de cancelación.';
            }
            
            List<OpportunityLineItem> listOlis = [SELECT Id, cd_line_status__c, LAT_MX_CancellationReason__c FROM OpportunityLineItem WHERE OpportunityId =: opp.Id];
            
            for(OpportunityLineItem oli: listOlis){
                if(oli.cd_line_status__c != null && integer.valueOf(oli.cd_line_status__c) > 560){
                    return 'Error: ' + label.LAT_MX_BTN08_00005;
                    //LAT_MX_BTN08_00005: No es posible cancelar un pedido que posee líneas en picking (status mayor a 560).';
                }
            }
            List<OpportunityLineItem> listOlisUpdate = new List<OpportunityLineItem>();
            for(OpportunityLineItem oli: listOlis){
                if(oli.LAT_MX_CancellationReason__c == null){
                    oli.LAT_MX_CancellationReason__c = opp.LAT_MX_OppCancellationReason__c;
                    listOlisUpdate.add(oli);   
                }
            }        
            opp.RecordTypeId = Global_RecordTypeCache.getRtId('Opportunity' + 'LAT_MX_OPP_OrderBlocked');
            opp.StageName = 'Pedido cancelado no JDE';
            
            try{
                update opp;
                update listOlisUpdate;
            }catch(DMLException e){
                return e.getMessage();
            }
            return 'ok';
        } 
        //MIGRATED 04/11/2016
        else {
            LAT_Opportunity__c opp = [SELECT Id, LAT_MX_OppCancellationReason__c, RecordTypeId, LAT_StageName__c, LAT_NROrderJDE__c FROM LAT_Opportunity__c WHERE Id =: idOpp];
            
            if(opp.RecordTypeId != Global_RecordTypeCache.getRtId('LAT_Opportunity__c' + 'LAT_MX_OPP_HeaderBlocked')){
                return 'Error: ' + label.LAT_MX_BTN08_00001;
                //LAT_MX_BTN08_00001: Solo pedidos con tipo de registro Cabecera bloqueada pueden ser cancelados.
            }
            if(opp.LAT_StageName__c != 'Pedido processado no JDE'){
                return 'Error: ' + label.LAT_MX_BTN08_00002;
                //LAT_MX_BTN08_00002: Solo se puede cancelar pedidos con Estado = Pedido generado.
            }
            if(opp.LAT_NROrderJDE__c == null){
                return 'Error: ' + label.LAT_MX_BTN08_00003;
                //LAT_MX_BTN08_00003: No se pueden cancelar pedidos que no fueron enviados a JDE.';
            }
            if(opp.LAT_MX_OppCancellationReason__c == null){
                return 'Error: ' + label.LAT_MX_BTN08_00004; 
                //LAT_MX_BTN08_00004: No es posible cancelar un pedido si no se ha especificado el motivo de cancelación.';
            }
            
            List<LAT_OpportunityLineItem__c> listOlis = [SELECT Id, LAT_CdLineStatus__c, LAT_MX_CancellationReason__c FROM LAT_OpportunityLineItem__c WHERE LAT_Opportunity__c =: opp.Id];
            
            for(LAT_OpportunityLineItem__c oli: listOlis){
                if(oli.LAT_CdLineStatus__c != null && integer.valueOf(oli.LAT_CdLineStatus__c) > 560){
                    return 'Error: ' + label.LAT_MX_BTN08_00005;
                    //LAT_MX_BTN08_00005: No es posible cancelar un pedido que posee líneas en picking (status mayor a 560).';
                }
            }
            List<LAT_OpportunityLineItem__c> listOlisUpdate = new List<LAT_OpportunityLineItem__c>();
            for(LAT_OpportunityLineItem__c oli: listOlis){
                if(oli.LAT_MX_CancellationReason__c == null){
                    oli.LAT_MX_CancellationReason__c = opp.LAT_MX_OppCancellationReason__c;
                    oli.lat_remover__c = true;
                    listOlisUpdate.add(oli);   
                }
            }        
            opp.RecordTypeId = Global_RecordTypeCache.getRtId('LAT_Opportunity__c' + 'LAT_MX_OPP_OrderBlocked');
            opp.LAT_StageName__c = 'Pedido cancelado no JDE';
            
            try{
                update opp;
                update listOlisUpdate;
            }catch(DMLException e){
                return e.getMessage();
            }
            return 'ok';            
        }
    }
}