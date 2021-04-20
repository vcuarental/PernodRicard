public with sharing class ASI_HK_CRM_PreApprovalFormItemGenerator {
    
    public static final String RT_NO_MECHANIC = 'ASI_HK_CRM_PAF_Item_Default';
    public static final String RT_FOC = 'ASI_HK_CRM_PAF_Item_FOC';
    public static final String RT_FOC_BULK = 'ASI_HK_CRM_PAF_Item_FOC_Bulk';
    public static final String RT_VARIABLE = 'ASI_HK_CRM_PAF_Item_Variable';
    public static final String RT_FIXED = 'ASI_HK_CRM_PAF_Item_Fixed_Amount';
	public static final String RT_FIXED_BOTTLE = 'ASI_HK_CRM_PAF_Item_Fixed_Bottle';
    
    public static final Integer MAX_NUM_OF_FOC_PAIR = 4;
    public static final String FIELD_NAME_FOC_BUY = 'ASI_HK_CRM_FOC_Buy_Bottle_Option_{0}__c';
    public static final String FIELD_NAME_FOC_FREE = 'ASI_HK_CRM_FOC_Free_Bottle_Option_{0}__c';

    private static Map<String, RecordType> RTMap {
        get {
            if (RTMap == null) {
                List<RecordType> RTList = [SELECT Id, Name, DeveloperName, IsActive, SobjectType, NamespacePrefix, BusinessProcessId FROM RecordType WHERE SobjectType = 'ASI_HK_CRM_Pre_Approval_Form_Item__c'];
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
    
    public ASI_HK_CRM_Pre_Approval_Form_Item__c generateBasicPreApprovalFormItem(ASI_HK_CRM_Pre_Approval_Form__c paf, ASI_MFM_SKU_Code__c sku) {
        return new ASI_HK_CRM_Pre_Approval_Form_Item__c(
            ASI_HK_CRM_Pre_Approval_Form_Lookup__c = paf.Id
            , ASI_HK_CRM_SKU_Lookup__c = sku.Id
        );
    }

    public ASI_HK_CRM_Pre_Approval_Form_Item__c generatePreApprovalFormItem(ASI_HK_CRM_Pre_Approval_Form__c paf, ASI_MFM_SKU_Code__c sku, ID rtID) {
        ASI_HK_CRM_Pre_Approval_Form_Item__c result = generateBasicPreApprovalFormItem(paf, sku);
        result.RecordTypeId = rtID;
        return result;
    }

    public ASI_HK_CRM_Pre_Approval_Form_Item__c generatePreApprovalFormItem(ASI_HK_CRM_Pre_Approval_Form__c paf, ASI_MFM_SKU_Code__c sku, String rtDevName) {
        return generatePreApprovalFormItem(paf, sku, getRecordTypeByDevName(rtDevName).Id);
    }
    
    public static String buyField(Integer index) { return String.format(FIELD_NAME_FOC_BUY, new String[] {String.valueOf(index)}); }
    public static String freeField(Integer index) { return String.format(FIELD_NAME_FOC_FREE, new String[] {String.valueOf(index)}); }

}