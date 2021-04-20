public with sharing class ASI_CRM_CN_Brand_T1_Gp_Item_TriggerClass {
    public ASI_CRM_CN_Brand_T1_Gp_Item_TriggerClass(){}
    
    public void check_duplication(List<ASI_CRM_CN_Brand_T1_Group_Item__c > trigger_new){
        
        /*
        //List<ASI_CRM_CN_Brand_T1_Group_Item__c> Brand_T1_Group_Item_list = [Select id,Name,ASI_CRM_CN_Brand__c,ASI_CRM_CN_Brand_T1_Group__c,ASI_CRM_CN_External_ID__c from ASI_CRM_CN_Brand_T1_Group_Item__c];
        
        //2014-07-29 Stella Sing (add CN_recordTypid filter)
        id CN_RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_CN_Brand_T1_Group_Item__cASI_CRM_CN_Brand_T1_Group_Item');
        List<ASI_CRM_CN_Brand_T1_Group_Item__c> Brand_T1_Group_Item_list = [Select id,Name,ASI_CRM_CN_Brand__c,ASI_CRM_CN_Brand_T1_Group__c,ASI_CRM_CN_External_ID__c from ASI_CRM_CN_Brand_T1_Group_Item__c WHERE RecordTypeid = :CN_RecordTypeId];
        
        for(ASI_CRM_CN_Brand_T1_Group_Item__c temp_brand_t1_group_item :trigger_new){
            if(Brand_T1_Group_Item_list .size()>0){
                for(ASI_CRM_CN_Brand_T1_Group_Item__c temp_compare_brand_t1_group_item :Brand_T1_Group_Item_list ){
                    
                    if((temp_compare_brand_t1_group_item .ASI_CRM_CN_Brand_T1_Group__c==temp_brand_t1_group_item .ASI_CRM_CN_Brand_T1_Group__c)&&(temp_compare_brand_t1_group_item .ASI_CRM_CN_Brand__c==temp_brand_t1_group_item .ASI_CRM_CN_Brand__c)) {
                        temp_brand_t1_group_item.addError('Duplicated Brand T1 Group Item found! object id:'+temp_compare_brand_t1_group_item.id);
                        
                    }
                }
                
            }   
        }*/
        
        id CN_RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_CN_Brand_T1_Group_Item__cASI_CRM_CN_Brand_T1_Group_Item');
        set<Id> brandIds = new set<Id>();
        set<Id> groupIds = new set<Id>();
        for(ASI_CRM_CN_Brand_T1_Group_Item__c newItem :trigger_new){
            if(newItem.ASI_CRM_CN_Brand_T1_Group__c!=null)
                groupIds.add(newItem.ASI_CRM_CN_Brand_T1_Group__c);
            if(newItem.ASI_CRM_CN_Brand__c!=null)
                brandIds.add(newItem.ASI_CRM_CN_Brand__c);
        }
        
        for(ASI_CRM_CN_Brand_T1_Group_Item__c existingItem
            :[SELECT Id, ASI_CRM_CN_Brand__c, ASI_CRM_CN_Brand_T1_Group__c
              FROM ASI_CRM_CN_Brand_T1_Group_Item__c 
              WHERE ASI_CRM_CN_Brand__c IN :brandIds AND ASI_CRM_CN_Brand_T1_Group__c IN :groupIds AND RecordTypeid =:CN_RecordTypeId]) {
                  for(ASI_CRM_CN_Brand_T1_Group_Item__c newItem :trigger_new){
                      if(newItem.Id==existingItem.Id) continue;
                      if(newItem.ASI_CRM_CN_Brand_T1_Group__c==existingItem.ASI_CRM_CN_Brand_T1_Group__c && newItem.ASI_CRM_CN_Brand__c==existingItem.ASI_CRM_CN_Brand__c) {
                          newItem.addError('Duplicated Brand T1 Group Item found! object id:'+existingItem.id);
                      }
                  }     
              }

    }
}