public with sharing class ASI_MFM_CN_ReturnRequestDetailGenerator {

    public static final String RT_Default = 'ASI_MFM_CN_POSM_Request_Item';

    private static Map<String, RecordType> RTMap {
        get {
            if (RTMap == null) {
                List<RecordType> RTList = [SELECT Id, Name, DeveloperName, IsActive, SobjectType, NamespacePrefix, BusinessProcessId FROM RecordType WHERE SobjectType = 'ASI_MFM_POSM_Return_Request_Item__c'];
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
    
    public ASI_MFM_POSM_Return_Request_Item__c generateBasicReturnRequestDetail(ASI_MFM_POSM_Return_Request__c req, ASI_MFM_SKU_Code__c sku) {
        return new ASI_MFM_POSM_Return_Request_Item__c(
            ASI_MFM_Request_Order__c = req.Id
            , ASI_MFM_SKU__c = sku.Id
        );
    }

    public ASI_MFM_POSM_Return_Request_Item__c generateReturnRequestDetail(ASI_MFM_POSM_Return_Request__c req, ASI_MFM_SKU_Code__c sku) {
        ASI_MFM_POSM_Return_Request_Item__c result = generateBasicReturnRequestDetail(req, sku);
        result.RecordTypeId = getRecordTypeByDevName(RT_Default).Id;
        return result;
    }

}