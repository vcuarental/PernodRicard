/*
* Custom AutoNumber Assignment for ASI JP TnE Doc no
*/
public with sharing class ASI_JP_TnE_AutoNumberAssignment {

    private static final String PATTERN_SHORT_YEAR = '{YY}';
    private static final String PATTERN_MONTH = '{MM}';
    private static final String PATTERN_FULL_YEAR = '{YYYY}';
    private String key;
    private ASI_HK_CRM_Running_Number__c autoNumObj;
    private String autoNumFormat;
    private Boolean hasUpdate;
    private Boolean alreadyChecked;

    public ASI_JP_TnE_AutoNumberAssignment(String key) {
        this.key = key;
        List<ASI_HK_CRM_Running_Number__c> autoNumObjs = null;
        try {
            autoNumObjs = [
                SELECT Id, ASI_HK_CRM_Object_Name__c, ASI_HK_CRM_Running_Number__c
                    , ASI_HK_CRM_Format__c, ASI_HK_CRM_First_Month_of_Fiscal_Year__c, ASI_HK_CRM_Fiscal_Year__c
                FROM ASI_HK_CRM_Running_Number__c
                WHERE ASI_HK_CRM_Object_Name__c = :key
                FOR UPDATE
            ];
        } catch (QueryException qe) {
            throw new ASI_HK_CRM_CustomException('Race condition occurs. Please try saving again.');
        }
        if (autoNumObjs != null && autoNumObjs.size() > 0) {
            this.autoNumObj = autoNumObjs[0];
            this.autoNumFormat = String.isBlank(autoNumObj.ASI_HK_CRM_Format__c) ? '{0}' : autoNumObj.ASI_HK_CRM_Format__c;
        }
        this.hasUpdate = false;
        this.alreadyChecked = false;
    }
    
    public String nextAutoNumStr() {
        Integer autoNum = nextAutoNum();
        return customFormatToString(this.autoNumFormat, autoNum);
    }
    
    public Integer nextAutoNum() {
        checkIfNeedReset();
        this.autoNumObj.ASI_HK_CRM_Running_Number__c = this.autoNumObj.ASI_HK_CRM_Running_Number__c + 1;
        this.hasUpdate = true;
        return this.autoNumObj.ASI_HK_CRM_Running_Number__c.intValue();
    }
    
    private String customFormatToString(String customFormat, Integer autoNum) {
        String stdFormat = customFormat;
        Integer autoNumLength = 0;
        boolean isShortYear = false;
        boolean isLongYear = false;
        boolean isMonth = false;
        
        if (String.isBlank(stdFormat)) {
            stdFormat = '{0}';
        } else {
            // TODO: Support auto number appears more than 1 time
            if (stdFormat.contains('{0') && stdFormat.contains('0}')) {
                Integer startIndex = stdFormat.indexOf('{0');
                Integer endIndex = stdFormat.indexOf('0}');
                autoNumLength = endIndex - startIndex;
                if (autoNumLength > 0) {
                    stdFormat = stdFormat.substringBefore('{0') + '{0}' + stdFormat.substringAfter('0}');
                }
            }
            while (stdFormat.contains(PATTERN_SHORT_YEAR)) {
                stdFormat = stdFormat.replace(PATTERN_SHORT_YEAR, '{1}');
            }
            while (stdFormat.contains(PATTERN_FULL_YEAR)) {
                stdFormat = stdFormat.replace(PATTERN_FULL_YEAR, '{2}');
            }
            while (stdFormat.contains(PATTERN_MONTH)) {
                stdFormat = stdFormat.replace(PATTERN_MONTH, '{3}');
            }
        }
        String autoNumStr = String.valueOf(autoNum);
        if (autoNumLength > 0) {
            autoNumStr = autoNumStr.leftPad(autoNumLength).replace(' ', '0');
        }
        List<String> formatParams = new List<String>();
        formatParams.add(autoNumStr);
        formatParams.add(String.valueOf(Math.mod(date.today().year(), 100)));
        formatParams.add(String.valueOf(date.today().year()));
        String leadingZeroMonth = String.valueOf(date.today().month()).length() == 1 ? ('0' + String.valueOf(date.today().month())) : (String.valueOf(date.today().month()));
        formatParams.add(leadingZeroMonth);
        return String.format(stdFormat, formatParams);
    }

    public void checkIfNeedReset() {
        if (this.alreadyChecked != true) {
            Boolean needUpdate = false; 
            //Check if the running number has to be reset for a new month
            Integer currentMonth = date.today().month();
            
            if (autoNumObj == null) {
                throw new ASI_HK_CRM_CustomException('Missing setting in Running Number object. Please contact administrator.');
            }
            
            // Fiscal month here is used as current month
            if (autoNumObj.ASI_HK_CRM_First_Month_of_Fiscal_Year__c != currentMonth)
            {
                autoNumObj.ASI_HK_CRM_First_Month_of_Fiscal_Year__c = currentMonth;
                autoNumObj.ASI_HK_CRM_Running_Number__c = 0;
                needUpdate = true;
            }
            
            if (autoNumObj.ASI_HK_CRM_Running_Number__c == null) {
                autoNumObj.ASI_HK_CRM_Running_Number__c = 0;
                needUpdate = true;
            }
            if (needUpdate)
                update autoNumObj;
            this.alreadyChecked = true;
        }
    }

    public void writeToDB() 
    {
        if (this.autoNumObj != null && this.hasUpdate)
          update this.autoNumObj;
    }

}