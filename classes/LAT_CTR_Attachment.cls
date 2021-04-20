/**********************************************************************************
*                           Company: ValueNet
*----------------------------------------------------------------------------------
*   Clase que distribuye los registros por pais del objeto Attachment
***********************************************************************************/

public with sharing class LAT_CTR_Attachment{

    private static String VisitPrefix = Schema.SObjectType.Visitas__c.getKeyPrefix();

    public static void runTriggers(){
        
        /*TRIGGERS BR VISITAS*/
        List<Attachment> triggerNewVisitasBR = new List<Attachment>();
        List<Attachment> triggerOldVisitasBR = new List<Attachment>();
        
        if(trigger.isInsert){
            Set<Id> setVisitasId = new Set<Id>();
            for(Attachment attach: (List<Attachment>)trigger.New){
                String parentIdStr = String.valueOf(attach.ParentId);
                if (parentIdStr.indexOf(VisitPrefix) == 0) {
                    setVisitasId.add(attach.ParentId);
                }        
            }
            if(!setVisitasId.isEmpty()){
                Map<Id,Visitas__c> mapVisitas = new Map<Id,Visitas__c>([SELECT Id FROM Visitas__c WHERE RecordTypeId =: Global_RecordTypeCache.getRtId('Visitas__c' + 'BRA_Standard') AND Id IN: setVisitasId]);                
                for(Attachment attach: (List<Attachment>)trigger.New){
                    if(mapVisitas.containsKey(attach.ParentId)){
                        triggerNewVisitasBR.add(attach);
                    }
                }
            }
        }
        
        if(trigger.isDelete){
            Set<Id> setVisitasId = new Set<Id>();
            for(Attachment attach: (List<Attachment>)trigger.Old){
                String parentIdStr = String.valueOf(attach.ParentId);
                if (parentIdStr.indexOf(VisitPrefix) == 0) {
                    setVisitasId.add(attach.ParentId);
                }        
            }
            if(!setVisitasId.isEmpty()){
                Map<Id,Visitas__c> mapVisitas = new Map<Id,Visitas__c>([SELECT Id FROM Visitas__c WHERE RecordTypeId =: Global_RecordTypeCache.getRtId('Visitas__c' + 'BRA_Standard') AND Id IN: setVisitasId]);
                for(Attachment attach: (List<Attachment>)trigger.Old){
                    if(mapVisitas.containsKey(attach.ParentId)){
                        triggerOldVisitasBR.add(attach);
                    }
                }
            }
        }
        
        if(triggerNewVisitasBR != null && !triggerNewVisitasBR.isEmpty()){
            LAT_BR_AP01_Attachment.updateHasAttachment(triggerNewVisitasBR);
        }
        if(triggerOldVisitasBR != null && !triggerOldVisitasBR.isEmpty()){
             LAT_BR_AP01_Attachment.updateHasAttachment(triggerOldVisitasBR);
        }        
    }

    public static void processContractAttachment(list<Attachment> latamAttachments){
        List<Id> contractIds = new List<Id>();
        for (Attachment attachment : latamAttachments) {
            if (attachment.Name.contains('Acordo Comercial') && attachment.ParentId.getSobjectType().getDescribe().getName() == 'LAT_Contract2__c') {
                contractIds.add(attachment.ParentId);
            }
        } 

        if(!contractIds.isEmpty()) {
            List<LAT_Contract2__c> contracts = new LAT_ContractRepository().findByIds(contractIds);
 
            for (LAT_Contract2__c contract : contracts) {
                    contract.Status__c = 'Ativo';
                    contract.ProcessStatus__c = 'Processo Finalizado';
            }
            if (contracts.size() > 0) update contracts;
        }
    }

}