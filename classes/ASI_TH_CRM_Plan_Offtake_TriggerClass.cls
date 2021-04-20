public with sharing class ASI_TH_CRM_Plan_Offtake_TriggerClass {
    public static void routineAfterAll(list<ASI_TH_CRM_Plan_Offtake_Sub_brand_Total__c> trigger_new, Map<id, ASI_TH_CRM_Plan_Offtake_Sub_brand_Total__c> trigger_oldMap){
        Set<Id> planOfftakeSubBrandTotalIds = new Set<Id>();        
        List<ASI_TH_CRM_PlanOfftake__c> insertPlanOfftakeList = new List<ASI_TH_CRM_PlanOfftake__c>();       
        
        for(ASI_TH_CRM_Plan_Offtake_Sub_brand_Total__c newRecord: trigger_new)
        {            
             if (newRecord.ASI_TH_CRM_Sub_brand__c != null && newRecord.ASI_TH_CRM_Total_Quantity__c != null){
                planOfftakeSubBrandTotalIds.add(newRecord.id);
             }     
        }    
        
         List<ASI_TH_CRM_PlanOfftake__c> deletePlanOfftakeList = [SELECT id FROM ASI_TH_CRM_PlanOfftake__c 
            WHERE ASI_TH_CRM_Plan_Offtake_Sub_brand_Total__c in : planOfftakeSubBrandTotalIds];
        
        for(ASI_TH_CRM_Plan_Offtake_Sub_brand_Total__c planOfftakeSubbrandTotal : [SELECT id, ASI_TH_CRM_Total_Quantity__c, ASI_TH_CRM_Average_Quantity__c,
            ASI_TH_CRM_Sub_brand__c, ASI_TH_CRM_Contract__r.ASI_TH_CRM_No_Of_Months__c, 
            ASI_TH_CRM_Contract__r.ASI_TH_CRM_Start_Date__c, ASI_TH_CRM_Contract__r.ASI_TH_CRM_End_Date__c
            FROM ASI_TH_CRM_Plan_Offtake_Sub_brand_Total__c WHERE id in :planOfftakeSubBrandTotalIds ]){        
                    
            Decimal avgQuantity = planOfftakeSubbrandTotal.ASI_TH_CRM_Average_Quantity__c;
                
            Integer i = 0;
            do{
                ASI_TH_CRM_PlanOfftake__c planOfftake = new ASI_TH_CRM_PlanOfftake__c();
                DateTime planOfftakeDateTime =  planOfftakeSubbrandTotal.ASI_TH_CRM_Contract__r.ASI_TH_CRM_Start_Date__c.addMonths(i);
                Date planOfftakeDate =  planOfftakeSubbrandTotal.ASI_TH_CRM_Contract__r.ASI_TH_CRM_Start_Date__c.addMonths(i);
                
                planOfftake.ASI_TH_CRM_Plan_Offtake_Sub_brand_Total__c = planOfftakeSubbrandTotal.id;
                planOfftake.Name = planOfftakeDate.year() + ' - ' + planOfftakeDateTime.format('MMM'); 
                planOfftake.ASI_TH_CRM_Date__c = planOfftakeDate;             
                planOfftake.ASI_TH_CRM_Subbrand__c = planOfftakeSubbrandTotal.ASI_TH_CRM_Sub_brand__c;      
                
                if (planOfftakeSubbrandTotal.ASI_TH_CRM_Contract__r.ASI_TH_CRM_No_Of_Months__c == i + 1){               
                    planOfftake.ASI_TH_CRM_Quantity__c = planOfftakeSubbrandTotal.ASI_TH_CRM_Total_Quantity__c - (avgQuantity * i);             
                }else{
                    planOfftake.ASI_TH_CRM_Quantity__c = avgQuantity;               
                }
                
                i++;
                //System.debug('Debug i: ' + i);
                insertPlanOfftakeList.add(planOfftake);
            }while(i < planOfftakeSubbrandTotal.ASI_TH_CRM_Contract__r.ASI_TH_CRM_No_Of_Months__c);
        }
           
        if(deletePlanOfftakeList!=null && deletePlanOfftakeList.size()>0) delete deletePlanOfftakeList;
        
        if(insertPlanOfftakeList!=null && insertPlanOfftakeList.size()>0) insert insertPlanOfftakeList;
    }
}