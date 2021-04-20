public with sharing class ASI_HK_CRM_AutoNumberAssignment {
    
    private static final String PATTERN_SHORT_YEAR = '{YY}';
    private static final String PATTERN_FULL_YEAR = '{YYYY}';
    // Start Update by Howard Au (Introv)@18 Mar 2014 to handle YY/YY Fiscal Year format genration
    private static final String PATTERN_FISCAL_YEAR = '{YY/YY}';
    // End Update by Howard Au (Introv)@18 Mar 2014 to handle YY/YY Fiscal Year format genration
    private String key;
    private ASI_HK_CRM_Running_Number__c autoNumObj;
    private Integer curFiscalYear;
    private String autoNumFormat;
    private Boolean hasUpdate;
    private Boolean alreadyChecked;
    
    public ASI_HK_CRM_AutoNumberAssignment(String key) {
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
            if (autoNumObj.ASI_HK_CRM_First_Month_of_Fiscal_Year__c != null)
                this.curFiscalYear = fiscalYearByStartMonth(DateTime.now().dateGMT(), autoNumObj.ASI_HK_CRM_First_Month_of_Fiscal_Year__c.intValue());
            this.autoNumFormat = String.isBlank(autoNumObj.ASI_HK_CRM_Format__c) ? '{0}' : autoNumObj.ASI_HK_CRM_Format__c;
        }
        
        this.hasUpdate = false;
        this.alreadyChecked = false;
    }
    
    public void checkIfNeedReset() {
        if (this.alreadyChecked != true) {
            Boolean needUpdate = false;
            if (autoNumObj == null) {
                throw new ASI_HK_CRM_CustomException('Missing setting in Running Number object. Please contact administrator.');
            }
            if (autoNumObj.ASI_HK_CRM_First_Month_of_Fiscal_Year__c == null && this.autoNumFormat.contains('{YY}')) {
                throw new ASI_HK_CRM_CustomException('Fiscal year definition is missing. Please contact administrator.');
            }
            if (autoNumObj.ASI_HK_CRM_First_Month_of_Fiscal_Year__c != null
                && (autoNumObj.ASI_HK_CRM_Fiscal_Year__c == null
                || autoNumObj.ASI_HK_CRM_Fiscal_Year__c != this.curFiscalYear)) {
                autoNumObj.ASI_HK_CRM_Fiscal_Year__c = this.curFiscalYear;
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
    
    public String nextAutoNumStr() {
        Integer autoNum = nextAutoNum();
        // Start Update by Howard Au (Introv)@13 May 2014 fix for hand code to 7 for month of fiscal year
        Integer month = 7;
        if (autoNumObj.ASI_HK_CRM_First_Month_of_Fiscal_Year__c != null) month = autoNumObj.ASI_HK_CRM_First_Month_of_Fiscal_Year__c.intValue();
        
        Integer fiscalYear = fiscalYearByStartMonth(DateTime.now().dateGMT(), month);
        //   End Update by Howard Au (Introv)@13 May 2014
        return customFormatToString(this.autoNumFormat, autoNum, this.curFiscalYear);
    }
    
    public Integer nextAutoNum() {
        checkIfNeedReset();
        this.autoNumObj.ASI_HK_CRM_Running_Number__c = this.autoNumObj.ASI_HK_CRM_Running_Number__c + 1;
        this.hasUpdate = true;
        return this.autoNumObj.ASI_HK_CRM_Running_Number__c.intValue();
    }
    
    public void writeToDB() {
        if (this.autoNumObj != null && this.hasUpdate)
            update this.autoNumObj;
    }
    
    private String customFormatToString(String customFormat, Integer autoNum, Integer fiscalYear) {
        String stdFormat = customFormat;
        Integer autoNumLength = 0;
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
            // Start Update by Howard Au (Introv)@18 Mar 2014 to handle YY/YY Fiscal Year format genration
            while (stdFormat.contains(PATTERN_FISCAL_YEAR)) {
                stdFormat = stdFormat.replace(PATTERN_FISCAL_YEAR, '{3}');
            }                       
            // End Update by Howard Au (Introv)@18 Mar 2014 to handle YY/YY Fiscal Year format genration
        }
        String autoNumStr = String.valueOf(autoNum);
        if (autoNumLength > 0) {
            autoNumStr = autoNumStr.leftPad(autoNumLength).replace(' ', '0');
        }
        List<String> formatParams = new List<String>();
        formatParams.add(autoNumStr);
        if (fiscalYear != null) {
            formatParams.add(String.valueOf(Math.mod(fiscalYear, 100)));
            formatParams.add(String.valueOf(fiscalYear));
            // Start Update by Howard Au (Introv)@18 Mar 2014 to handle YY/YY Fiscal Year format genration
            formatParams.add(String.valueOf(Math.mod(fiscalYear, 100)) +  String.valueOf(Math.mod(fiscalYear+1, 100)));
            // End Update by Howard Au (Introv)@18 Mar 2014 to handle YY/YY Fiscal Year format genration
        }
        return String.format(stdFormat, formatParams);
    }
    
    private Integer fiscalYearByStartMonth(Date theDate, Integer startMonth) {      
        Integer year = theDate.year();
        // Start Update by Howard Au (Introv)@13 May 2014 to handle TH CRM YY/YY Fiscal Year format generation
        if (UserInfo.getLocale() == 'th' || UserInfo.getLocale() == 'th_TH')
        	year -= 543;
        //   End Update by Howard Au (Introv)@13 May 2014        
        
        Integer month = theDate.month();        
        if (month < startMonth) {
            year -= 1;
        }
        return year;
    }
   
}