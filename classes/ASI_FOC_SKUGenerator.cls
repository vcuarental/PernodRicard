public with sharing class ASI_FOC_SKUGenerator {
    
    public static final String DEF_VALUE_NAME = 'Test SKU';
    public static final String DEF_VALUE_WHOLE_NAME_FORMAT = '{0} - {1}';
    public static final Boolean DEF_VALUE_IS_ACTIVE = true;
    public static final Decimal DEF_VALUE_STOCK_PRICE = 100;
    public static final Decimal DEF_VALUE_LIST_PRICE = 100;
    public static final Decimal DEF_VALUE_INVENTORY = 2000;
    public static final Decimal DEF_VALUE_UNIT_COST = 50;
    public static final String RT_Default = 'ASI_FOC_CN_SKU';
    public static final String RT_HK = 'ASI_HK_CRM_SKU';
    public static final String RT_CN_POSM = 'ASI_FOC_CN_POSM_SKU';
    
    private static Integer AUTO_NUM = 1;

    private static Map<String, RecordType> RTMap {
        get {
            if (RTMap == null) {
                List<RecordType> RTList = [SELECT Id, Name, DeveloperName, IsActive, SobjectType, NamespacePrefix, BusinessProcessId FROM RecordType WHERE SobjectType = 'ASI_MFM_SKU_Code__c'];
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
    
    public ASI_MFM_SKU_Code__c generateBasicSKU(String name, ASI_MFM_Item_Group__c itemGroup) {
        String code = nextCode();
        return new ASI_MFM_SKU_Code__c(
            Name = String.format(DEF_VALUE_WHOLE_NAME_FORMAT, new String[] {name, code})
            , ASI_MFM_SKU_Code__c = code
            , ASI_MFM_SKU_Description__c = name
            , ASI_MFM_Item_Group__c = itemGroup != null ? itemGroup.Id : null
            , ASI_MFM_Sub_brand__c = itemGroup != null ? itemGroup.ASI_MFM_Sub_brand__c : null
            , ASI_FOC_Active__c = DEF_VALUE_IS_ACTIVE
            , ASI_FOC_Stock_Price__c = DEF_VALUE_STOCK_PRICE
            , ASI_FOC_List_Price__c  = DEF_VALUE_LIST_PRICE
            , ASI_FOC_Inventory__c = DEF_VALUE_INVENTORY
            , ASI_FOC_Unit_Cost__c = DEF_VALUE_UNIT_COST
        );
    }

    public ASI_MFM_SKU_Code__c generateSKU(ASI_MFM_Item_Group__c itemGroup) {
        ASI_MFM_SKU_Code__c result = generateBasicSKU(DEF_VALUE_NAME, itemGroup);
        result.RecordTypeId = getRecordTypeByDevName(RT_Default).Id;
        return result;
    }
    
    public ASI_MFM_SKU_Code__c generatePOSMSKU(ASI_MFM_Item_Group__c itemGroup) {
        ASI_MFM_SKU_Code__c result = generateBasicSKU(DEF_VALUE_NAME, itemGroup);
        result.RecordTypeId = getRecordTypeByDevName(RT_CN_POSM).Id;
        result.ASI_FOC_Location_Item_Owner__c = userinfo.getuserid();
        result.ASI_HK_CRM_Available_Quantity__c = 10;
        return result;
    }
    
    private static String nextCode() {
        Integer autoNum = nextAutoNum();
        return 'SKU' + autoNum;
    }
    
    private static Integer nextAutoNum() {
        return AUTO_NUM++;
    }
    
}