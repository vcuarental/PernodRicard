public with sharing class ASI_MFM_CN_CatalogSecGenerator {
    
	public static final String RT_Default = 'ASI_MFM_CN_POSM';

    private static Map<String, RecordType> RTMap {
        get {
            if (RTMap == null) {
                List<RecordType> RTList = [SELECT Id, Name, DeveloperName, IsActive, SobjectType, NamespacePrefix, BusinessProcessId FROM RecordType WHERE SobjectType = 'ASI_MFM_POSMCatalogSecCtrl__c'];
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
    
    public ASI_MFM_POSMCatalogSecCtrl__c generateBasicReturnRequestDetail(ASI_MFM_Item_Group__c req, User userId) {
        return new ASI_MFM_POSMCatalogSecCtrl__c (
           // ASI_MFM_User__c = userId.Id, 
            ASI_MFM_ItemGroup__c = req.Id
        );
    }

    public ASI_MFM_POSMCatalogSecCtrl__c generateReturnRequestDetail(ASI_MFM_Item_Group__c req, User userId) {
        ASI_MFM_POSMCatalogSecCtrl__c result = generateBasicReturnRequestDetail(req, userId);
        result.RecordTypeId = getRecordTypeByDevName(RT_Default).Id;
        return result;
    }
}