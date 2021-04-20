public with sharing class ASI_CRM_SpecialPromotionTypeSettingCache {
    private static map<String, ASI_CRM_SpecialPromotionTypeSetting__c> mapRTPromotionType = new map<String, ASI_CRM_SpecialPromotionTypeSetting__c>();
    private static map<Id, ASI_CRM_SpecialPromotionTypeSetting__c> mapIdPromotionType = new map<Id, ASI_CRM_SpecialPromotionTypeSetting__c>();

    static{
        mapIdPromotionType = new map<Id, ASI_CRM_SpecialPromotionTypeSetting__c>([SELECT Id, Name, RecordTypeId, ASI_CRM_Bypass_Contract_Upload_Checking__c, ASI_CRM_Override_BC_Rate__c, ASI_CRM_Promotion_Type__c, ASI_CRM_Add_RBA_As_Final_Approver_V0_0__c FROM ASI_CRM_SpecialPromotionTypeSetting__c]);

        for(ASI_CRM_SpecialPromotionTypeSetting__c obj: mapIdPromotionType.values()){
            mapRTPromotionType.put(obj.ASI_CRM_Promotion_Type__c + '_' + obj.RecordTypeId, obj);
        }
    }

    public static boolean getPromotionTypeRBA(String PromotionType, String rtId){
        boolean boolReturn;

        boolReturn = false;

        if(mapRTPromotionType.containsKey(PromotionType + '_' + rtId))
        {
            ASI_CRM_SpecialPromotionTypeSetting__c tmpObj = mapRTPromotionType.get(PromotionType + '_' + rtId);

            if(tmpObj.ASI_CRM_Add_RBA_As_Final_Approver_V0_0__c != null && tmpObj.ASI_CRM_Add_RBA_As_Final_Approver_V0_0__c == true)
                boolReturn = true;
        }

        return boolReturn;
    }
}