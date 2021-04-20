public with sharing class ASI_FOC_FreeGoodRequestDetailGenerator {
    
    public static final Integer DEF_VALUE_QUANTITY = 10;
    public static final String RT_Default = 'ASI_FOC_CN_Request_Item';
    public static final String RT_HK = 'ASI_FOC_HK_Request_Item';
    public static final String RT_CN_POSM = 'ASI_FOC_CN_POSM_Request_Item';

    private static Map<String, RecordType> RTMap {
        get {
            if (RTMap == null) {
                List<RecordType> RTList = [SELECT Id, Name, DeveloperName, IsActive, SobjectType, NamespacePrefix, BusinessProcessId FROM RecordType WHERE SobjectType = 'ASI_FOC_Request_Item__c'];
                RTMap = new Map<String, RecordType>();
                for (RecordType rt : RTList) {
                    RTMap.put(rt.DeveloperName, rt);
                }
            }
            return RTMap;
        }
        set;
    }

    public static RecordType getRecordTypeByDevName(String devName) { return RTMap.get(devName); }
    
    public ASI_FOC_Request_Item__c generateBasicFreeGoodRequestDetail(ASI_FOC_Free_Goods_Request__c req, ASI_MFM_SKU_Code__c sku) {
        return new ASI_FOC_Request_Item__c(
            ASI_FOC_Request_Order__c = req.Id
            , ASI_FOC_SKU__c = sku.Id
            , ASI_FOC_Request_Quantity_Bottle__c = DEF_VALUE_QUANTITY
        );
    }

    public ASI_FOC_Request_Item__c generateFreeGoodRequestDetail(ASI_FOC_Free_Goods_Request__c req, ASI_MFM_SKU_Code__c sku) {
        ASI_FOC_Request_Item__c result = generateBasicFreeGoodRequestDetail(req, sku);
        result.RecordTypeId = getRecordTypeByDevName(RT_Default).Id;
        return result;
    }
    
    public ASI_FOC_Request_Item__c generatePOSMDetail(ASI_FOC_Free_Goods_Request__c req, ASI_MFM_SKU_Code__c sku) {
        ASI_FOC_Request_Item__c result = generateBasicFreeGoodRequestDetail(req, sku);
        result.RecordTypeId = getRecordTypeByDevName(RT_CN_POSM).Id;
        return result;
    }
    
}