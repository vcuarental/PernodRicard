public with sharing class ASI_HK_CRM_VisitationPlanGenerator {
    public static final String DEF_VALUE_NAME = 'Test Visitation';
    public static final String DEF_VALUE_YEAR = String.valueOf(System.today().year());
    public static final String DEF_VALUE_MONTH = 'December';
    private static Map<String, Integer> monthPLValueToIntMap;
    private static List<String> monthPLValueList;
    
    public static Integer convertMonthPLValueToInteger(String plValue) {
        return getMonthPLValueToIntegerMap().get(plValue);
    }
    public static Map<String, Integer> getMonthPLValueToIntegerMap() {
        if (monthPLValueToIntMap == null) {
            monthPLValueToIntMap = new Map<String, Integer>();
            List<Schema.PicklistEntry> monthPLEntryList = ASI_HK_CRM_Visitation_Plan__c.ASI_HK_CRM_Month__c.getDescribe().getPicklistValues();
            Integer month = 0;
            for (Schema.PicklistEntry plEntry : monthPLEntryList) {
                if (plEntry.isActive() && plEntry.getLabel() != null && plEntry.getLabel().trim() != '') {
                    month++;
                    monthPLValueToIntMap.put(plEntry.getValue(), month);
                }
            }
        }
        return monthPLValueToIntMap;
    }
    
    public ASI_HK_CRM_Visitation_Plan__c generateBasicVisitationPlan(String name, String theYear, String theMonth) {
        return new ASI_HK_CRM_Visitation_Plan__c(
            Name = name
            , ASI_HK_CRM_Year__c = theYear
            , ASI_HK_CRM_Month__c = theMonth
            , RecordTypeID = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Visitation_Plan__cASI_HK_CRM_Visitation_Plan')
        );
    }

    public ASI_HK_CRM_Visitation_Plan__c generateVisitationPlan() {
        ASI_HK_CRM_Visitation_Plan__c result = generateBasicVisitationPlan(DEF_VALUE_NAME, DEF_VALUE_YEAR, DEF_VALUE_MONTH);
        return result;
    }

}