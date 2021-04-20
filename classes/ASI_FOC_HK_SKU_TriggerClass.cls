/*********************************************************************************
 * Name: ASI_FOC_HK_SKU_TriggerClass
 * Description: 
 * Test Class: 
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2018-12-23       Wilken Lee             [WL 1.0] Auto create SKU Mapping for EDI when new SKU is created
 */
public class ASI_FOC_HK_SKU_TriggerClass {

    public static void routineBeforeUpsert(list<ASI_MFM_SKU_Code__c> trigger_new, map<id, ASI_MFM_SKU_Code__c> trigger_oldMap) {
// Check for Is Premium Item
        RecordType hkExpRT = [select id from RecordType where DeveloperName = 'HK_FOC_Expensive_Items' and SobjectType = 'ASI_FOC_Expensive_Items__c' limit 1];
        List<ASI_FOC_Expensive_Items__c> expList = [select ASI_FOC_SRP0__c from ASI_FOC_Expensive_Items__c where RecordTypeId = :hkExpRT.Id];
        set<String> exp_set = new set<String>();
        
        for (ASI_FOC_Expensive_Items__c exp :expList){
            exp_set.add(exp.ASI_FOC_SRP0__c);
        }
        
        if (trigger_new != null) {
            for (ASI_MFM_SKU_Code__c sku:trigger_new) {
                if (exp_set.contains(sku.ASI_FOC_SRP0__c)){
                    sku.ASI_FOC_Is_Premium__c = true;
                }
            }
        }
    }

    /*[WL 1.0] BEGIN*/
    public static void routineAfterInsert(list<ASI_MFM_SKU_Code__c> trigger_new) {
        Set<Id> itemGroupId = new Set<Id>();
        for (ASI_MFM_SKU_Code__c sku:trigger_new) {
            if (sku.ASI_MFM_Item_Group__c != null)
                itemGroupId.add(sku.ASI_MFM_Item_Group__c);
        }

        List<ASI_CRM_SKU_Mapping__c> mappingList = [SELECT ASI_CRM_Account__c, ASI_CRM_Item_Number__c, ASI_CRM_Item_Group__c FROM ASI_CRM_SKU_Mapping__c 
                                                    WHERE recordType.DeveloperName = 'ASI_CRM_HK_EDI_Item_Group_Mapping'
                                                    AND ASI_CRM_Item_Group__c IN :itemGroupId];

        List<ASI_CRM_SKU_Mapping__c> skuMappingToInsert = new List<ASI_CRM_SKU_Mapping__c>();

        for (ASI_MFM_SKU_Code__c sku:trigger_new) {                    
            for (ASI_CRM_SKU_Mapping__c mapping:mappingList){
                ASI_CRM_SKU_Mapping__c newMapping = new ASI_CRM_SKU_Mapping__c();
                if (sku.ASI_MFM_Item_Group__c == mapping.ASI_CRM_Item_Group__c){
                    newMapping.RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_SKU_Mapping__cASI_CRM_HK_EDI_SKU_Mapping');
                    newMapping.ASI_CRM_Account__c = mapping.ASI_CRM_Account__c;
                    newMapping.ASI_CRM_Item_Group__c = mapping.ASI_CRM_Item_Group__c;
                    newMapping.ASI_CRM_Item_Number__c = mapping.ASI_CRM_Item_Number__c;
                    newMapping.ASI_CRM_SKU__c = sku.Id;
                    newMapping.ASI_CRM_Item_Group_Mapping__c = mapping.Id;

                    skuMappingToInsert.add(newMapping);
                }
            }
        }
        if (skuMappingToInsert.size() > 0)
            insert skuMappingToInsert;
    }
    /*[WL 1.0] END*/
}