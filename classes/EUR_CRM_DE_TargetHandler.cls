/*
  @Company:     IP-Converge Data Services, Inc.
  @Description: Aggregate Actual Volume (Bottles) - EUR_CRM_DE_Trigger Handler
  @Author:      IPC
  @History:     JUN.27.2014 - Created
*/
public without sharing class EUR_CRM_DE_TargetHandler{
    public static Map<Id, RecordType> opRtMap = new Map<Id, RecordType>([Select Id, DeveloperName 
            From RecordType 
            Where SObjectType = 'EUR_CRM_ObjPromo_Target__c']);
    
    public static void aggregateActualVolume_AIAU(List<EUR_CRM_ObjPromo_Target__c> OPTarget){
        Set<Id> opTargetSRId = new Set<Id>();
        Set<Id> opTargetRId = new Set<Id>();
        
        for(EUR_CRM_ObjPromo_Target__c op: OPTarget){
            if(opRtMap.get(op.RecordTypeId).DeveloperName == 'EUR_DE_SR_Volume_Target' && op.EUR_CRM_O_P_Target__c != null){
                opTargetSRId.add(op.EUR_CRM_O_P_Target__c);
            }
            if((opRtMap.get(op.RecordTypeId).DeveloperName == 'EUR_DE_Sales_Agency_Managed_Target' 
            || opRtMap.get(op.RecordTypeId).DeveloperName == 'EUR_DE_Regional_Volume_Target')
              && op.EUR_CRM_O_P_Target__c != null){
                opTargetRId.add(op.EUR_CRM_O_P_Target__c);
            }
            system.debug('***opTargetSRId: ' + opTargetSRId);
            system.debug('***opTargetRId: ' + opTargetRId);
        }
        
        //update Regional records
        if(opTargetSRId.size() > 0){
            AggregateResult[] actualVolReg = [Select EUR_CRM_O_P_Target__c Id, SUM(EUR_CRM_Actual_Volume_Bottles__c) actVol
                                                From EUR_CRM_ObjPromo_Target__c 
                                                Where EUR_CRM_O_P_Target__c IN: opTargetSRId 
                                                Group by EUR_CRM_O_P_Target__c];
            
            List<EUR_CRM_ObjPromo_Target__c> updateRegionalVol = new List<EUR_CRM_ObjPromo_Target__c>();
            for(AggregateResult av: actualVolReg){
                EUR_CRM_ObjPromo_Target__c objpro = new EUR_CRM_ObjPromo_Target__c();
                objpro.Id = av.Id;
                objpro.EUR_CRM_Actual_Volume_Bottles__c = (Decimal) av.get('actVol');
                
                updateRegionalVol.add(objpro);
            }
            
            if(updateRegionalVol.size() > 0){
                update updateRegionalVol;
            }
        }
        
        //update National records
        if(opTargetRId.size() > 0){
            List<EUR_CRM_ObjPromo_Target__c> nationalOPList = new List<EUR_CRM_ObjPromo_Target__c>();
            nationalOPList = [Select EUR_CRM_O_P_Target__c from EUR_CRM_ObjPromo_Target__c Where Id IN: opTargetRId];
            
            Set<Id> nationalId = new Set<Id>();
            for(EUR_CRM_ObjPromo_Target__c nop :nationalOPList){
                nationalId.add(nop.Id);
            }
            
            //update National records
            if(nationalId.size() > 0){
                AggregateResult[] actualVolNat = [Select EUR_CRM_O_P_Target__c Id, SUM(EUR_CRM_Actual_Volume_Bottles__c) actVol
                                                    From EUR_CRM_ObjPromo_Target__c 
                                                    Where EUR_CRM_O_P_Target__c IN: nationalId 
                                                    Group by EUR_CRM_O_P_Target__c];
                
                List<EUR_CRM_ObjPromo_Target__c> updateNationalVol = new List<EUR_CRM_ObjPromo_Target__c>();
                for(AggregateResult av: actualVolNat){
                    EUR_CRM_ObjPromo_Target__c objpro = new EUR_CRM_ObjPromo_Target__c();
                    objpro.Id = av.Id;
                    objpro.EUR_CRM_Actual_Volume_Bottles__c = (Decimal) av.get('actVol');
                    
                    updateNationalVol.add(objpro);
                }
                
                if(updateNationalVol.size() > 0){
                    update updateNationalVol;
                }
            }
        }
        
    }
    
    //Other Methods and actions
}