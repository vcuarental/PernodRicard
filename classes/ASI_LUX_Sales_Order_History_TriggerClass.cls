public without sharing class ASI_LUX_Sales_Order_History_TriggerClass {
    
    public static void routineBeforeUpsert(list<ASI_HK_CRM_Sales_Order_History__c> trigger_new, map<id, ASI_HK_CRM_Sales_Order_History__c> trigger_oldMap) {
        if(Global_RecordTypeCache.getRt(trigger_new[0].recordTypeId).developerName.startsWith('ASI_CRM_MY')) {
            set<string> PoName = new set<string>(); //Add By tony Ren
            Map<String,id> po=new map<String,id>();
            for (ASI_HK_CRM_Sales_Order_History__c so:trigger_new) {
                if(so.ASI_HK_CRM_Customer_PO__c!=null){
                    PoName.add(so.ASI_HK_CRM_Customer_PO__c);//Get Customer PO #(plan)
                }
            }
            List<ASI_MFM_Plan__c> pls=[select id,name,RecordType.DeveloperName from ASI_MFM_Plan__c where name in:PoName and RecordType.DeveloperName LIKE 'ASI_MFM_MY_Plan%'];// 
            if(pls.size()>0){
                for(ASI_MFM_Plan__c p:pls){
                    po.put(p.name,p.id);  //Get Plan id.and put in map
                }
            }
            for (ASI_HK_CRM_Sales_Order_History__c soh:trigger_new) { //Get corresponding plan from map with trigger_new 
                soh.ASI_MFM_Plan__c=po.get(soh.ASI_HK_CRM_Customer_PO__c);  //system.debug(po.get(soh.ASI_HK_CRM_Customer_PO__c)+'TestPO3:'+po);
            }
        }
    }
    
    
}