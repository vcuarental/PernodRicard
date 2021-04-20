public with sharing class ASI_HK_CRM_CustomSettingGenerator {
    
    public static final Map<String, Integer> acctGradeToVisitCountMap = new Map<String, Integer>{
        'A' => 5
        , 'B' => 4
        , 'C' => 3
        , 'D' => 1
    };
    public static final String FIELD_ID_DUMMY = 'dummyId';
    public static final String KEY_FIELD_PREFIX_1 = 'Setting1';
    public static final String WEB_SERVICE_ERROR_NAME = 'WebServiceAlertEmail';
    public static final String WEB_SERVICE_REPEAT = 'ASI_HK_CRM_WSRepeatControlDataSet';
    
    public static void initAcctGradeVisitCountMapping() {
        if ([SELECT COUNT() FROM ASI_HK_CRM_AcctGradeVisitCountMapping__c] == 0) {
            List<ASI_HK_CRM_AcctGradeVisitCountMapping__c> settings = new List<ASI_HK_CRM_AcctGradeVisitCountMapping__c>();
            Set<String> grades = acctGradeToVisitCountMap.keySet();
            for (String grade : grades) {
                settings.add(new ASI_HK_CRM_AcctGradeVisitCountMapping__c(
                    Name = grade
                    , ASI_HK_CRM_No_of_Required_Visitation__c = acctGradeToVisitCountMap.get(grade)
                ));
            }
            insert settings;
        }
    }
    
    public static void initFieldPrefix() {
        if ([SELECT COUNT() FROM ASI_HK_CRM_Field_Prefix__c] == 0) {
            insert new ASI_HK_CRM_Field_Prefix__c(
                Name = KEY_FIELD_PREFIX_1
                , SalesOrderNewDAID__c = FIELD_ID_DUMMY
                , SalesOrderNewDANameID__c = FIELD_ID_DUMMY
                , SalesOrderNewPAID__c = FIELD_ID_DUMMY
                , SalesOrderNewPANameID__c = FIELD_ID_DUMMY
            );
        }
    }
    
    public static void initMassCreateAndUpdateSetting() {
    }
    
    public static void initThresholdValues() {
        if ([SELECT COUNT() FROM ASI_HK_CRM_ThresholdValues__c] == 0) {
            insert new ASI_HK_CRM_ThresholdValues__c(
                SetupOwnerId = UserInfo.getOrganizationId()
                , ASI_HK_CRM_PAF_FOC_Bulk_Min_Buy__c = 360
                , ASI_HK_CRM_PAF_Investment_Percent__c = 15
                , ASI_HK_CRM_PAF_Investment_Amount__c = 10000
                , ASI_HK_CRM_SO_Amount_Level_1__c = null
                , ASI_HK_CRM_SO_Amount_Level_2__c = null
                , ASI_HK_CRM_SO_Max_Num_of_Urgent_Order__c = 50
                , ASI_HK_CRM_SO_Min_Order_Amount__c = null
                , ASI_HK_CRM_SO_Urgent_Cutoff_Time_1__c = '10:00'
                , ASI_HK_CRM_SO_Urgent_Cutoff_Time_2__c = '16:30'
            );
        }
    }

    public static void initThresholdValues(String thresold1, String thresold2) {
        if ([SELECT COUNT() FROM ASI_HK_CRM_ThresholdValues__c] == 0) {
            insert new ASI_HK_CRM_ThresholdValues__c(
                SetupOwnerId = UserInfo.getOrganizationId()
                , ASI_HK_CRM_PAF_FOC_Bulk_Min_Buy__c = 360
                , ASI_HK_CRM_PAF_Investment_Percent__c = 15
                , ASI_HK_CRM_PAF_Investment_Amount__c = 10000
                , ASI_HK_CRM_SO_Amount_Level_1__c = null
                , ASI_HK_CRM_SO_Amount_Level_2__c = null
                , ASI_HK_CRM_SO_Max_Num_of_Urgent_Order__c = 50
                , ASI_HK_CRM_SO_Min_Order_Amount__c = null
                , ASI_HK_CRM_SO_Urgent_Cutoff_Time_1__c = thresold1
                , ASI_HK_CRM_SO_Urgent_Cutoff_Time_2__c = thresold2
            );
        }
    }
    
    public static void initWebServiceErrorAddress(){
        if ([SELECT COUNT() FROM ASI_HK_CRM_WebServiceErrorAddress__c] == 0) {
            insert new ASI_HK_CRM_WebServiceErrorAddress__c(
                Name = WEB_SERVICE_ERROR_NAME
                , ASI_HK_CRM_Email_1__c = 'email1@google.com'
                , ASI_HK_CRM_Email_2__c = 'email2@google.com'
                , ASI_HK_CRM_Email_3__c = 'email3@google.com'
                , ASI_HK_CRM_Email_4__c = 'email4@google.com'
                , ASI_HK_CRM_Email_5__c = 'email5@google.com'
                , ASI_HK_CRM_Email_6__c = 'email6@google.com'
            );
        }       
    }
    
    public static void initRepeatWebService(){
        if ([SELECT COUNT() FROM ASI_HK_CRM_WebServiceRepeatControl__c] == 0) {
            insert new ASI_HK_CRM_WebServiceRepeatControl__c(
                Name = WEB_SERVICE_REPEAT
                , ASI_HK_CRM_isRepeatWebService__c = true
            );
        }       
    }
    
    
}