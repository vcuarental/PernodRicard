global class ASI_LUX_AccountCalcScoreLastYrBatch implements Database.Batchable<sObject>{

    global final String query;

    global ASI_LUX_AccountCalcScoreLastYrBatch (String q)
    {
        query = q;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) 
    {
        return Database.getQueryLocator(query);
    }

    global void execute (Database.Batchablecontext BC, List<sObject> scope)
    {
        List<Account> luxAccountList = (List<Account>)scope;
        List<Account> luxAccountToUpdateList = new List<Account>();
        
        ASI_LUX_PastFiscalYear__c pastCalculation = [select Name, ASI_LUX_Number_of_Past_Days__c, ASI_LUX_Months_Interval__c from ASI_LUX_PastFiscalYear__c limit 1];
        
        ASI_HK_CRM_Running_Number__c runningNumber = [select ASI_HK_CRM_First_Month_of_Fiscal_Year__c from ASI_HK_CRM_Running_Number__c where ASI_HK_CRM_Object_Name__c = 'ASI_HK_CRM_Sales_Order__c']; 
        
        List<ASI_LUX_FX_Conversion_Rate__c> conversionRateList = [select name, ASI_LUX_Local_Currency_To_EUR__c from ASI_LUX_FX_Conversion_Rate__c where name = 'HKD' OR name = 'TWD' OR name = 'SGD'];
        Map<String, ASI_LUX_FX_Conversion_Rate__c> conversionRateMap = new Map<String, ASI_LUX_FX_Conversion_Rate__c>();
        for (ASI_LUX_FX_Conversion_Rate__c conversionRate : conversionRateList)
        {
             conversionRateMap.put(conversionRate.name, conversionRate);
        }
        
        ASI_LUX_FX_Conversion_Rate__c conversionRate = null;
        
        for (Account luxAcct : luxAccountList)
        {
            List<ASI_HK_CRM_Sales_Order_History__c> tempSOList = luxAcct.ASI_HK_CRM_Sales_Order_Histories__r == null ? new List<ASI_HK_CRM_Sales_Order_History__c>()
                                                                    : luxAcct.ASI_HK_CRM_Sales_Order_Histories__r;
            
            if(luxAcct.recordtype.developername.contains('Account_TW'))
            {
                conversionRate = conversionRateMap.get('TWD'); 
            }
            else if(luxAcct.recordtype.developername.contains('SG_Account'))
            {
                conversionRate = conversionRateMap.get('SGD'); 
            }
            else
            {
                conversionRate = conversionRateMap.get('HKD');
            }
            
            Account tempLuxAcct = luxAcct;
            tempLuxAcct = calculateScore(luxAcct, tempSOList, runningNumber, conversionRate, pastCalculation);
            tempLuxAcct = calculateSegmentation(tempLuxAcct, tempSOList, runningNumber, pastCalculation);
            luxAccountToUpdateList.add(tempLuxAcct);
        }
        
        if (luxAccountToUpdateList.size() > 0)
            update luxAccountToUpdateList;
    }
    
    global void finish(Database.BatchableContext BC) 
    {   
        
    }
    
    public Account calculateScore(Account account, List<ASI_HK_CRM_Sales_Order_History__c> soHistListParam, ASI_HK_CRM_Running_Number__c runningNumber,
                                    ASI_LUX_FX_Conversion_Rate__c conversionRate, ASI_LUX_PastFiscalYear__c pastYearPARAM)
    {
        
        Integer pastDays = pastYearPARAM.ASI_LUX_Number_of_Past_Days__c.intValue();  
        Integer monthsInterval = pastYearPARAM.ASI_LUX_Months_Interval__c.intValue();
        
        Integer month = (Integer) runningNumber.ASI_HK_CRM_First_Month_of_Fiscal_Year__c;
       Integer year = Datetime.now().year();
        //Integer year = 2015;
        
        Decimal conversionFactor = 1;
        Datetime startFiscal = Datetime.newInstance(year, month,1);
        if (startFiscal > DateTime.now() )
            startFiscal = startFiscal.addYears(-1);
        Date startFiscalDate = startFiscal.Date().addDays(-pastDays);
        Date endFiscalDate = startFiscalDate.addmonths(monthsInterval);
        
        system.debug('ratdoto ' + pastDays);
        system.debug('bestdoto ' + month);
        system.debug('doto ' + startFiscalDate);
        system.debug('doto ' + endFiscalDate);
        if(conversionRate != null)
            conversionFactor = conversionRate.ASI_LUX_Local_Currency_To_EUR__c;

        Decimal total = 0;

        Decimal sumFiscal = 0;
        Decimal totalFiscal = 0;
        Decimal freq = 0;

        for(ASI_HK_CRM_Sales_Order_History__c a : soHistListParam){ 
            if (a.ASI_HK_CRM_Order_Date__c >= startFiscalDate && a.ASI_HK_CRM_Order_Date__c <= endFiscalDate)
            {
                sumFiscal = sumFiscal + (a.ASI_HK_CRM_Total_Amount__c == null ? 0.0 : a.ASI_HK_CRM_Total_Amount__c);
                totalFiscal = totalFiscal + 1;
            }
        }

        freq = totalFiscal;

        sumFiscal = sumFiscal * conversionFactor;

        if(sumFiscal >= 0 && sumFiscal <= 2400){
            account.ASI_LUX_Purchase_Behavior_Spend_LastYear__c = 'Score 1: EUR 0 - 2,400';
        }else if(sumFiscal >2400&& sumFiscal <= 4800){
            account.ASI_LUX_Purchase_Behavior_Spend_LastYear__c = 'Score 2: EUR 2,401 - 4,800';
        }else if(sumFiscal >4800&& sumFiscal <= 7300){
            account.ASI_LUX_Purchase_Behavior_Spend_LastYear__c = 'Score 3: EUR 4,801 – 7,300';
        }else if(sumFiscal >7300&& sumFiscal <= 9700){
            account.ASI_LUX_Purchase_Behavior_Spend_LastYear__c = 'Score 4: EUR 7,301 – 9,700';
        }else if(sumFiscal >9700&& sumFiscal <= 19400){
            account.ASI_LUX_Purchase_Behavior_Spend_LastYear__c = 'Score 5: EUR 9,701 – 19,400';
        }else if(sumFiscal >19400&& sumFiscal <= 29200){
            account.ASI_LUX_Purchase_Behavior_Spend_LastYear__c = 'Score 6: EUR 19,401– 29,200';
        }else if(sumFiscal >29200&& sumFiscal <= 38900){
            account.ASI_LUX_Purchase_Behavior_Spend_LastYear__c = 'Score 7: EUR 29,201 – 38,900';
        }else if(sumFiscal >38900&& sumFiscal <= 48700){
            account.ASI_LUX_Purchase_Behavior_Spend_LastYear__c = 'Score 8: EUR 38,901 – 48,700';
        }else if(sumFiscal >48700){
            account.ASI_LUX_Purchase_Behavior_Spend_LastYear__c = 'Score 9: EUR 48,701 and / or above';
        }

        if(freq == 0){
            account.ASI_LUX_Purchase_Behavior_Freq_Last_Year__c = 'Score = 0 -> PF = 0';
        } else if(freq > 0 && freq <= 1){
            account.ASI_LUX_Purchase_Behavior_Freq_Last_Year__c = 'Score = 1 -> PF = once a year';
        } else if(freq > 1 && freq <4){
            account.ASI_LUX_Purchase_Behavior_Freq_Last_Year__c = 'Score = 2 -> PF = once every 6 months';
        } else if(freq >=4 && freq <12){
            account.ASI_LUX_Purchase_Behavior_Freq_Last_Year__c = 'Score = 3 -> PF = once every 3 months';
        } else if(freq >=12 && freq <= 26){
            account.ASI_LUX_Purchase_Behavior_Freq_Last_Year__c = 'Score = 4 -> PF = once a month';
        } else if(freq > 26){
            account.ASI_LUX_Purchase_Behavior_Freq_Last_Year__c = 'Score = 5 -> PF = once every 2 weeks';
        }

        return account;
    }
    
    public Account calculateSegmentation(Account account, List<ASI_HK_CRM_Sales_Order_History__c> tempSOList, ASI_HK_CRM_Running_Number__c runningNumber, 
                                            ASI_LUX_PastFiscalYear__c pastYearPARAM)
    {
        
        Integer pastDays = pastYearPARAM.ASI_LUX_Number_of_Past_Days__c.intValue();  
        Integer monthsInterval = pastYearPARAM.ASI_LUX_Months_Interval__c.intValue();
        
        Integer month = (Integer) runningNumber.ASI_HK_CRM_First_Month_of_Fiscal_Year__c;
        Integer year = Datetime.now().year();
        //Integer year = 2015;

        Datetime startFiscal = Datetime.newInstance(year, month,1);
        if (startFiscal > DateTime.now() )
            startFiscal = startFiscal.addYears(-1);
        Date startFiscalDate = startFiscal.Date().addDays(-pastDays);
        Date endFiscalDate = startFiscalDate.addMonths(monthsInterval);
        system.debug('volvo ' + startFiscalDate);
        system.debug('volvo ' + endFiscalDate);
        List<CampaignMember> campaignmemberList = [SELECT ID, CampaignID, ContactID FROM CampaignMember WHERE Contact.AccountID =: account.id AND Status = : 'Attended'];

        set<id> campaignSet = new set<ID>();
        for (CampaignMember i : campaignmemberList)
            campaignset.add(i.CampaignID);
    
        List<Campaign> campaignList = [SELECT StartDate, EndDate, Status From Campaign WHERE ID IN : campaignset AND StartDate != NULL AND EndDate != NULL];

        Decimal sumCampaignAttended = 0;
        for (Campaign i : campaignList)
        {
            if (i.EndDate >= startFiscalDate && i.EndDate <= endFiscalDate)
                sumCampaignAttended += 1;
        }

        if (sumCampaignAttended < 5)
            account.ASI_LUX_Segment_Involvement_LastYear__c = 'Low < 5 Physically attended events';
        else
            account.ASI_LUX_Segment_Involvement_LastYear__c = 'High ≥ 5 Physically attended events';

        Decimal sumFiscal = 0;

        for(ASI_HK_CRM_Sales_Order_History__c a : tempSOList){
            if (a.ASI_HK_CRM_Order_Date__c >= startFiscalDate && a.ASI_HK_CRM_Order_Date__c <= endFiscalDate)
                sumFiscal = sumFiscal + (a.ASI_HK_CRM_Total_Amount__c == null ? 0.0 : a.ASI_HK_CRM_Total_Amount__c);
        }

        if (account.recordtype.developername.contains('Account_TW'))
        {
            if(sumFiscal < 290000){
                account.ASI_LUX_Segmentation_Value_LastYear__c = 'Low < TWD 290K';
            }else{
                account.ASI_LUX_Segmentation_Value_LastYear__c = 'High ≥ TWD 290K';
            }
        }
        else if (account.recordtype.developername.contains('SG_Account')) {
            if(sumFiscal < 10000){
                account.ASI_LUX_Segmentation_Value_LastYear__c = 'Low < SGD 10K';
            }else{
                account.ASI_LUX_Segmentation_Value_LastYear__c = 'High ≥ SGD 10K';
            }
        }
        else
        {
            if(sumFiscal < 75000){
                account.ASI_LUX_Segmentation_Value_LastYear__c = 'Low < HKD 75K';
            }else{
                account.ASI_LUX_Segmentation_Value_LastYear__c = 'High ≥ HKD 75K';
            }
        }
        
        return account;
    }

}