/********************************************************************************************
*  Company:Valuenet             Developers: Waldemar Mayo               Date:06/12/2013     *
********************************************************************************************/
/********************************************************************************
* 
* MIGRACION LICENCIAS 
* AUTHOR: ZIMMIC                     DATE: 02/11/2016
*
********************************************************************************/

public with sharing class LAT_AR_AP01_OpportunityLineItem {
    
    /*****************************************************************************************
    * Nombre del metodo: validateStatus
    * Descripcion: Validate that no item with status not null is edited, unless it comes from JDE
    * Desarrollador: Juan Pablo Cubo
    * Fecha: 
    * Modo: after update
    *****************************************************************************************/
    public static void validateStatus(List<OpportunityLineItem> triggerNew, map<Id, OpportunityLineItem> triggerOldMap){
        if (SalesOrderReturn.transactionOrigin == null || (SalesOrderReturn.transactionOrigin != null && SalesOrderReturn.transactionOrigin != 'JDE') ) {
            for (OpportunityLineItem oliNew : triggerNew) {
                OpportunityLineItem oliOld = triggerOldMap.get(oliNew.Id);
                if ((oliNew.cd_line_status__c != null && oliNew.cd_line_status__c != '') && ( oliNew.UOM_AR__c != oliOld.UOM_AR__c || oliNew.Quantity != oliOld.Quantity || oliNew.Discount != oliOld.Discount ) ) {
                    oliNew.addError(System.Label.VFP11_00026_AR);
                    //Label.VFP11_00026 = Opportunity line items with non empty status can't be edited, they only can be canceled.
                }
            }
        }
    }
 
    //MIGRATED 02/11/2016 
    public static void validateStatus(List<LAT_OpportunityLineItem__c> triggerNew, map<Id, LAT_OpportunityLineItem__c> triggerOldMap){
        if (SalesOrderReturn.transactionOrigin == null || (SalesOrderReturn.transactionOrigin != null && SalesOrderReturn.transactionOrigin != 'JDE') ) {
            for (LAT_OpportunityLineItem__c oliNew : triggerNew) {
                LAT_OpportunityLineItem__c oliOld = triggerOldMap.get(oliNew.Id);
                if ((oliNew.LAT_CdLineStatus__c != null && oliNew.LAT_CdLineStatus__c != '') && ( oliNew.LAT_AR_UOM__c != oliOld.LAT_AR_UOM__c || oliNew.LAT_Quantity__c != oliOld.LAT_Quantity__c || oliNew.LAT_Discount__c != oliOld.LAT_Discount__c ) ) {
                    oliNew.addError(System.Label.VFP11_00026_AR);
                    //Label.VFP11_00026 = Opportunity line items with non empty status can't be edited, they only can be canceled.
                }
            }
        }
    }
    
    /*****************************************************************************************
    * Nombre del metodo: existeItemEmBackOrder
    * Descripcion: Metodo que actualiza los campos Existe_item_em_backorder__c y Existe_item_em_backorder_pais__c
    * Desarrollador: Elena
    * Fecha: 26/12/13
    * Modo: after update
    *****************************************************************************************/
    public static void existeItemEmBackOrder(List<OpportunityLineItem> triggerNew){
    
        Set<String> setOppIds = new Set<String>();
        for(OpportunityLineItem oli: triggerNew){
            setOppIds.add(oli.OpportunityId);
        }
        
        List<Opportunity> listOppsToUpdate = new List<Opportunity>();
        for(Opportunity opp: [SELECT Id, RecordTypeId, Existe_item_em_backorder__c, Existe_item_em_backorder_pais__c, (SELECT Id, OpportunityId, Backorder__c FROM OpportunityLineItems) FROM Opportunity WHERE Id IN: setOppIds]){
            opp.Existe_item_em_backorder__c = null;
            opp.Existe_item_em_backorder_pais__c = null;
            for(OpportunityLineItem oli: opp.OpportunityLineItems){
                if(oli.Backorder__c == 1){
                    opp.Existe_item_em_backorder__c = 1;
                    opp.Existe_item_em_backorder_pais__c = 5; //5 is for the workflow in spanish: Order with items in backoder AR
                }
            }
            listOppsToUpdate.add(opp);
        }
        try{update listOppsToUpdate;}catch(DMLException e){}
    }
    
    //MIGRATED 02/11/2016 
    public static void existeItemEmBackOrder(List<LAT_OpportunityLineItem__c> triggerNew){
    
        Set<String> setOppIds = new Set<String>();
        for(LAT_OpportunityLineItem__c oli: triggerNew){
            setOppIds.add(oli.LAT_Opportunity__c);
        }
        
        List<LAT_Opportunity__c> listOppsToUpdate = new List<LAT_Opportunity__c>();
        for(LAT_Opportunity__c opp: [SELECT Id, RecordTypeId, LAT_BackorderItemExists__c, LAT_BackorderItemExistsCountry__c, 
                                        (SELECT Id, LAT_Opportunity__c, LAT_Backorder__c 
                                        FROM OpportunityLineItems__r) FROM LAT_Opportunity__c WHERE Id IN: setOppIds]){
            opp.LAT_BackorderItemExists__c = null;
            opp.LAT_BackorderItemExistsCountry__c = null;
            for(LAT_OpportunityLineItem__c oli: opp.OpportunityLineItems__r){
                if(oli.LAT_Backorder__c == 1){
                    opp.LAT_BackorderItemExists__c = 1;
                    opp.LAT_BackorderItemExistsCountry__c = 5; //5 is for the workflow in spanish: Order with items in backoder AR
                }
            }
            listOppsToUpdate.add(opp);
        }
        try{update listOppsToUpdate;}catch(DMLException e){}
    }

    /*****************************************************************************************
    * Nombre del metodo: updateStatusOpportunity
    * Descripcion: Metodo que actualiza el status de la oportunidad de acuerdo al status de los items
    * Desarrollador: Nicolas Javier Romero
    * Fecha: 12/12/2013
    * Modo: after insert, after update, after delete
    *****************************************************************************************/
    public static void updateStatusOpportunity(List<OpportunityLineItem> triggerNew, List<OpportunityLineItem> triggerOld, map<Id, OpportunityLineItem> triggerOldMap){
        LAT_BR_AP01_OpportunityLineItem.updateStatusOpportunity(triggerNew, triggerOld, triggerOldMap);
    }

    //MIGRATED 02/11/2016 
    public static void updateStatusOpportunity(List<LAT_OpportunityLineItem__c> triggerNew, List<LAT_OpportunityLineItem__c> triggerOld, map<Id, LAT_OpportunityLineItem__c> triggerOldMap){
        //LAT_BR_AP01_OpportunityLineItem.updateStatusOpportunity(triggerNew, triggerOld, triggerOldMap); DEjo de hacer este cálculo en la clase de BR, para hacerlo específicamente para ARG y UY.

        Set<Id> setIdOpp2 = new Set<Id>();
        if(trigger.isDelete){
            for(LAT_OpportunityLineItem__c oli :triggerOld){
                setIdOpp2.add(oli.LAT_Opportunity__c);
            }
        }else{
            for(LAT_OpportunityLineItem__c oli :triggerNew){
                setIdOpp2.add(oli.LAT_Opportunity__c);
            }
        }
        
        if(!setIdOpp2.isEmpty()){
            List<LAT_Opportunity__c> listOppToUpdate = new List<LAT_Opportunity__c>();
            Boolean tieneRetenciones;
            for(LAT_Opportunity__c opp : [SELECT Id, LAT_StageName__c, LAT_NROrderJDE__c, (SELECT Id, LAT_StatusDescription__c, LAT_CdLineStatus__c, LAT_Description__c FROM OpportunityLineItems__r) FROM LAT_Opportunity__c WHERE Id =: setIdOpp2]){
                if(opp.LAT_NROrderJDE__c != null){
                    Integer contCancel      = 0;
                    Integer contFacturado   = 0;
                    Integer contAprobacion  = 0;
                    Integer contAtendido    = 0;
                    tieneRetenciones = false;
                    String newStatus = opp.LAT_StageName__c;
                    for (LAT_OpportunityLineItem__c oli :opp.OpportunityLineItems__r) {
                        System.debug('%%% oli.LAT_StatusDescription__c : '+oli.LAT_StatusDescription__c);
                        System.debug('%%% oli.LAT_CdLineStatus__c : '+oli.LAT_CdLineStatus__c);
                        System.debug('%%% oli.LAT_Description__c : '+oli.LAT_Description__c);
                        if (oli.LAT_Description__c != null && oli.LAT_Description__c != '') {
                            tieneRetenciones = true;
                        }
                        if (oli.LAT_StatusDescription__c != null) {
                            if (oli.LAT_StatusDescription__c.startsWithIgnoreCase('Cancelado')) {
                                contCancel++;
                            } else if(oli.LAT_StatusDescription__c.startsWithIgnoreCase('Faturado') || oli.LAT_StatusDescription__c.startsWithIgnoreCase('Facturado') || oli.LAT_StatusDescription__c.startsWithIgnoreCase('Contabilizado')) {
                                contFacturado++;
                            } else if(oli.LAT_StatusDescription__c.contains('Aprovação')) {
                                contAprobacion++;
                            } 

                        }

                        if (oli.LAT_CdLineStatus__c == '520' || oli.LAT_CdLineStatus__c == '530') {
                            if (tieneRetenciones && oli.LAT_Description__c != null) {
                                if (oli.LAT_Description__c.contains('PA')) {
                                    newStatus = 'Pedido retenido en Cuota';
                                } else {
                                    newStatus = 'Pedido ingresado en JDE';
                                }
                            } else {
                                newStatus = 'Pedido ingresado en JDE';
                            }
                        }
                        if (oli.LAT_CdLineStatus__c == '540') {
                            if (tieneRetenciones) {
                                newStatus = 'Pedido retenido en Créditos';
                            } else {
                                newStatus = 'Pedido en Logística';
                            }
                        } 
                        if (oli.LAT_CdLineStatus__c == '560' || oli.LAT_CdLineStatus__c == '580') {
                            contAtendido++;
                        }
                    }
                    
                    


                    if (contFacturado != 0 && contFacturado != opp.OpportunityLineItems__r.size()){
                       newStatus = 'Partially billed';
                       opp.LAT_Probability__c = 90;
                    }
                    if (contFacturado == opp.OpportunityLineItems__r.size()){
                       newStatus = 'Totally billed';
                       opp.LAT_Probability__c = 100;
                    }
                    if (contCancel == opp.OpportunityLineItems__r.size()){
                       newStatus = 'Pedido cancelado no JDE';
                       opp.LAT_Probability__c = 0;
                    }
                    if (contAprobacion == opp.OpportunityLineItems__r.size()){
                       newStatus = 'Pedido em Aprovação';
                    }
                    if (contAtendido != 0 && contAtendido != opp.OpportunityLineItems__r.size()){
                       newStatus = 'Pedido parcialmente atendido';
                    }                    
                    if (contAtendido == opp.OpportunityLineItems__r.size()){
                       newStatus = 'Pedido totalmente atendido';
                    }


                    if(opp.LAT_StageName__c != newStatus){
                        opp.LAT_StageName__c = newStatus;
                        opp.LAT_Integration__c = true;
                        listOppToUpdate.add(opp);
                    }
                }
            }
            if(!listOppToUpdate.isEmpty()){
                update listOppToUpdate;
            }
        }
    }
}