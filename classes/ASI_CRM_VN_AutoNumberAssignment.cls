/*
/*********************************************************************************
 * Name:ASI_CRM_VN_AutoNumberAssignment
 * Description: Generic Helper Class to generate Custom AutoNumber based on Running Number Object
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 29/10/2015       Neha Sonawane           Created
*********************************************************************************/
public with sharing class ASI_CRM_VN_AutoNumberAssignment {

    private static final String PATTERN_SHORT_YEAR = '{YY}';
    private static final String PATTERN_MONTH = '{MM}';
    private static final String PATTERN_FULL_YEAR = '{YYYY}';
    private String key;
    private ASI_HK_CRM_Running_Number__c autoNumObj;
    private String autoNumFormat;
    private Boolean hasUpdate;
    private Boolean alreadyChecked;

    public ASI_CRM_VN_AutoNumberAssignment(String key) {
        this.key = key;
        autoNumObj=new ASI_HK_CRM_Running_Number__c();
        List<ASI_HK_CRM_Running_Number__c> autoNumObjs = null;
        try {
            autoNumObjs = [SELECT ASI_HK_CRM_Object_Name__c, ASI_HK_CRM_Running_Number__c
                    , ASI_HK_CRM_Format__c, ASI_HK_CRM_First_Month_of_Fiscal_Year__c, ASI_HK_CRM_Fiscal_Year__c
                FROM ASI_HK_CRM_Running_Number__c
                WHERE ASI_HK_CRM_Object_Name__c = :key
                FOR UPDATE
            ];
            system.debug('***wow*****autoNumObjs ***********'+autoNumObjs);
        } catch (QueryException qe) {
            throw new ASI_HK_CRM_CustomException('Race condition occurs. Please try saving again.');
        }
        if (autoNumObjs != null && autoNumObjs.size() > 0) {
            this.autoNumObj = autoNumObjs[0];
            system.debug('---in this-----autoNumObj*****'+autoNumObj);
            this.autoNumFormat = String.isBlank(autoNumObj.ASI_HK_CRM_Format__c) ? '{0}' : autoNumObj.ASI_HK_CRM_Format__c;
        }
        this.hasUpdate = false;
        this.alreadyChecked = false;
    }
    
    public String nextAutoNumStr() {
    system.debug('----In nextAutoNumStr ----'+this.autoNumObj);
        Integer autoNum = nextAutoNum();
        return customFormatToString(this.autoNumFormat, autoNum);
    }
    
    public Integer nextAutoNum() {
        checkIfNeedReset();
        system.debug(this.autoNumObj+'-------wow1--------');
        system.debug(this.autoNumObj.ASI_HK_CRM_Running_Number__c+'-------wow2--------');
        
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
        
        Integer fiscalYear = (Integer)autoNumObj.ASI_HK_CRM_Fiscal_Year__c;
        
        if(fiscalYear == null) {
            fiscalYear = 0;
        }
        
        formatParams.add(String.valueOf(Math.mod(fiscalYear, 100)));
        formatParams.add(String.valueOf(fiscalYear));
        String leadingZeroMonth = String.valueOf(date.today().month()).length() == 1 ? ('0' + String.valueOf(date.today().month())) : (String.valueOf(date.today().month()));
        formatParams.add(leadingZeroMonth);
        return String.format(stdFormat, formatParams);
    }

    public void checkIfNeedReset() {
        if (this.alreadyChecked != true) {
            Boolean needUpdate = false; 
            //Check if the running number has to be reset for a new month
            Integer currentMonth = date.today().month();
            Integer currentYear = date.today().year();
            system.debug('autoNumObj *******'+autoNumObj );
            /*if(test.isRunningTest()){
                system.debug('in test class execution****');
            }else {*/
                if (autoNumObj == null) {
                    throw new ASI_HK_CRM_CustomException('Missing setting in Running Number object. Please contact administrator.');
                }
                 // Cutoff date month is used to determine the current fiscal year
                if (autoNumObj.ASI_HK_CRM_First_Month_of_Fiscal_Year__c <= currentMonth && autoNumObj.ASI_HK_CRM_Fiscal_Year__c != (currentYear) && autoNumObj.ASI_HK_CRM_Fiscal_Year__c != null)
                {
                    autoNumObj.ASI_HK_CRM_Fiscal_Year__c = currentYear;
                    autoNumObj.ASI_HK_CRM_Running_Number__c = 0;
                    needUpdate = true;
                } /*else if ((autoNumObj.ASI_HK_CRM_First_Month_of_Fiscal_Year__c > currentMonth && autoNumObj.ASI_HK_CRM_Fiscal_Year__c != (currentYear)) || autoNumObj.ASI_HK_CRM_Fiscal_Year__c == null) {
                    autoNumObj.ASI_HK_CRM_Fiscal_Year__c = currentYear;
                    needUpdate = true;
                }*/
                
                if (autoNumObj.ASI_HK_CRM_Running_Number__c == null) {
                    autoNumObj.ASI_HK_CRM_Running_Number__c = 0;
                    needUpdate = true;
                }
                if (needUpdate)
                    update autoNumObj;
                this.alreadyChecked = true;
            //}
            
           
        }
    }

    public void writeToDB() 
    {
        if (this.autoNumObj != null && this.hasUpdate)
          update this.autoNumObj;
    }

}