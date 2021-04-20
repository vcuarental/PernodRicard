public with sharing class ASI_LUX_AccountCalcScoreController
{
    
    private ApexPages.StandardController standardController;
    private Account account;
    public ASI_LUX_AccountCalcScoreController(ApexPages.StandardController standardController)
    { 
        account = (Account) standardController.getRecord();
        Id xx = account.id;
        list<Account> accList = [select id, recordtype.developername, ASI_LUX_Well_conn_within_social_circle__c,ASI_LUX_Has_media_interest__c,ASI_LUX_Recognized_within_their_industry__c
        from Account where id =:xx limit 1];
        if (!accList.isEmpty())
            account = accList.get(0);
        else
            account = null;
    } 

    public PageReference calculateScore()
    {
        
        if (account == null)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Account does not exist'));
            return null;
        }
    
        List<ASI_HK_CRM_Running_Number__c> runningNumberList = [select ASI_HK_CRM_First_Month_of_Fiscal_Year__c from ASI_HK_CRM_Running_Number__c where ASI_HK_CRM_Object_Name__c = 'ASI_HK_CRM_Sales_Order__c'];
        ASI_HK_CRM_Running_Number__c runningNumber = new ASI_HK_CRM_Running_Number__c();
        if (!runningNumberList.isEmpty())
            runningNumber = runningNumberList.get(0);
        else
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Score calculation failed because the record ASI_HK_CRM_Sales_Order__c for the Object ASI_HK_CRM_Running_Number__c is missing. Please contact the System Administrator to verify that this Running Number record is deployed'));
            return null;
        }
        Integer month = (Integer) runningNumber.ASI_HK_CRM_First_Month_of_Fiscal_Year__c;

        Integer year = Datetime.now().year();
        //Hardcode year for testing
        //Integer year = 2015;

        Decimal totalScore = 0;
        Decimal conversionFactor = 1;
        Datetime endFiscal = Datetime.newInstance(year, month,1);
        Datetime startFiscal = Datetime.newInstance(year, month,1);
        endFiscal = endFiscal.addDays(1);
        Date startFiscalDate = startFiscal.Date();
        Date endFiscalDate = endFiscal.Date();

        // if the startfiscaldate is in the future, change the year to the last year 
        if (startFiscalDate > date.today())
            startFiscalDate = startFiscalDate.addyears(-1);
        //AggregateResult[] groupedResults2 = [select sum(ASI_HK_CRM_Total_Amount__c), count(id) from ASI_HK_CRM_Sales_Order_History__c where ASI_HK_CRM_Account_PA__c =:account.id
        //and createdDate >=:startFiscal  and createdDate <=:endFiscal];
        system.debug('doto2 ' + startFiscalDate);
        List<ASI_HK_CRM_Sales_Order_History__c > list2 = [select ASI_HK_CRM_Total_Amount__c from ASI_HK_CRM_Sales_Order_History__c where ASI_HK_CRM_Account_PA__c =:account.id
        and ASI_HK_CRM_Order_Date__c >=:startFiscalDate ];


        List<ASI_LUX_FX_Conversion_Rate__c> conversionRateList = [select name, ASI_LUX_Local_Currency_To_EUR__c from ASI_LUX_FX_Conversion_Rate__c where name = 'HKD' OR name = 'TWD'];
        Map<String, ASI_LUX_FX_Conversion_Rate__c> conversionRateMap = new Map<String, ASI_LUX_FX_Conversion_Rate__c>();
        for (ASI_LUX_FX_Conversion_Rate__c conversionRate : conversionRateList)
        {
             conversionRateMap.put(conversionRate.name, conversionRate);
        }
        
        try
        {
        if(!conversionRateList.isEmpty()){
            if (account.recordtype.developername.contains('Account_TW'))
            {
                conversionFactor = conversionRateMap.get('TWD').ASI_LUX_Local_Currency_To_EUR__c;
            }
            else
            {
                conversionFactor = conversionRateMap.get('HKD').ASI_LUX_Local_Currency_To_EUR__c;
            }
        }
        else
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Score calculation failed because there is no ASI LUX FX Conversion Rate linked to this Luxury Account record type. Please contact the System Administrator to verify that there is a ASI LUX FX Conversion Rate record for each country\'s set of Luxury Account record types.'));
            return null;
        }
        }
        catch (Exception e)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Score calculation failed because there is no ASI LUX FX Conversion Rate linked to this Luxury Account record type. Please contact the System Administrator to verify that there is a ASI LUX FX Conversion Rate record for each country\'s set of Luxury Account record types.'));
            return null;
        }
        
        //Decimal total = (Decimal) (groupedResults[0].get('expr1'));
        Decimal total = 0;
 
        //Decimal sumFiscal = (Decimal)(groupedResults2[0].get('expr0'));
        //Decimal totalFiscal = (Decimal) (groupedResults2[0].get('expr1'));
        //Decimal freq = 0;

        Decimal sumFiscal = 0;
        Decimal totalFiscal = 0;
        Decimal freq = 0;

        for(ASI_HK_CRM_Sales_Order_History__c a : list2){
            sumFiscal = sumFiscal + (a.ASI_HK_CRM_Total_Amount__c == null ? 0.0 : a.ASI_HK_CRM_Total_Amount__c);
            totalFiscal = totalFiscal + 1;
        }

        freq = totalFiscal;

        sumFiscal = sumFiscal * conversionFactor;

        system.debug('radcliffe ' + sumFiscal);
        system.debug('radcliffer ' + totalFiscal);
        system.debug('radcliffest ' + list2);
        system.debug('radcliffest fiscakl' + startFiscalDate);

        if(sumFiscal >= 0 && sumFiscal <= 2400){
            account.ASI_LUX_Purchase_Behavior_Spend_YTD__c = 'Score 1: EUR 0 - 2,400';
            totalScore = totalScore + 1;
        }else if(sumFiscal >2400&& sumFiscal <= 4800){
            account.ASI_LUX_Purchase_Behavior_Spend_YTD__c = 'Score 2: EUR 2,401 - 4,800';
            totalScore = totalScore + 2;
        }else if(sumFiscal >4800&& sumFiscal <= 7300){
            account.ASI_LUX_Purchase_Behavior_Spend_YTD__c = 'Score 3: EUR 4,801 – 7,300';
            totalScore = totalScore + 3;
        }else if(sumFiscal >7300&& sumFiscal <= 9700){
            account.ASI_LUX_Purchase_Behavior_Spend_YTD__c = 'Score 4: EUR 7,301 – 9,700';
            totalScore = totalScore + 4;
        }else if(sumFiscal >9700&& sumFiscal <= 19400){
            account.ASI_LUX_Purchase_Behavior_Spend_YTD__c = 'Score 5: EUR 9,701 – 19,400';
            totalScore = totalScore + 5;
        }else if(sumFiscal >19400&& sumFiscal <= 29200){
            account.ASI_LUX_Purchase_Behavior_Spend_YTD__c = 'Score 6: EUR 19,401– 29,200';
            totalScore = totalScore + 6;
        }else if(sumFiscal >29200&& sumFiscal <= 38900){
            account.ASI_LUX_Purchase_Behavior_Spend_YTD__c = 'Score 7: EUR 29,201 – 38,900';
            totalScore = totalScore + 7;
        }else if(sumFiscal >38900&& sumFiscal <= 48700){
            account.ASI_LUX_Purchase_Behavior_Spend_YTD__c = 'Score 8: EUR 38,901 – 48,700';
            totalScore = totalScore + 8;
        }else if(sumFiscal >48700){
            account.ASI_LUX_Purchase_Behavior_Spend_YTD__c = 'Score 9: EUR 48,701 and / or above';
            totalScore = totalScore + 9;
        }

        if(freq == 0){
            account.ASI_LUX_Purchase_Behavior_Freq_YTD__c = 'Score = 0 -> PF = 0';
        } else if(freq > 0 && freq <= 1){
            totalScore = totalScore + 1;
            account.ASI_LUX_Purchase_Behavior_Freq_YTD__c = 'Score = 1 -> PF = once a year';
        } else if(freq > 1 && freq <4){
            totalScore = totalScore + 2;
            account.ASI_LUX_Purchase_Behavior_Freq_YTD__c = 'Score = 2 -> PF = once every 6 months';
        } else if(freq >=4 && freq <12){
            totalScore = totalScore + 3;
            account.ASI_LUX_Purchase_Behavior_Freq_YTD__c = 'Score = 3 -> PF = once every 3 months';
        } else if(freq >=12 && freq <= 26){
            totalScore = totalScore + 4;
            account.ASI_LUX_Purchase_Behavior_Freq_YTD__c = 'Score = 4 -> PF = once a month';
        } else if(freq > 26){
            totalScore = totalScore + 5;
            account.ASI_LUX_Purchase_Behavior_Freq_YTD__c = 'Score = 5 -> PF = once every 2 weeks';
        }

        system.debug('XXXX: ' + account.ASI_LUX_Well_conn_within_social_circle__c);
        if ('1 Low'.equals (account.ASI_LUX_Well_conn_within_social_circle__c)){
            totalScore = totalScore + 1;
        }else if ('3 Medium'.equals (account.ASI_LUX_Well_conn_within_social_circle__c)){
            totalScore = totalScore + 3;
        } else if ('5 High'.equals (account.ASI_LUX_Well_conn_within_social_circle__c)){
            totalScore = totalScore + 5;
        }

        if ('1 Low'.equals (account.ASI_LUX_Recognized_within_their_industry__c)){
            totalScore = totalScore + 1;
        }else if ('3 Medium'.equals (account.ASI_LUX_Recognized_within_their_industry__c)){
            totalScore = totalScore + 3;
        }else if ('5 High'.equals (account.ASI_LUX_Recognized_within_their_industry__c)){
            totalScore = totalScore + 5;
        }

        if ('1 Low'.equals (account.ASI_LUX_Has_media_interest__c)){
            totalScore = totalScore + 1;
        }else if ('3 Medium'.equals (account.ASI_LUX_Has_media_interest__c)){
            totalScore = totalScore + 3;
        }else if ('5 High'.equals (account.ASI_LUX_Has_media_interest__c)){
            totalScore = totalScore + 5;
        }
        account.ASI_LUX_Total_Score__c = totalScore;
        update(account);
        return new PageReference('/' + account.Id);
    }

    public PageReference calculateSegmentation()
    {
        if (account == null)
            return null;
    
        List<ASI_HK_CRM_Running_Number__c> runningNumberList = [select ASI_HK_CRM_First_Month_of_Fiscal_Year__c from ASI_HK_CRM_Running_Number__c where ASI_HK_CRM_Object_Name__c = 'ASI_HK_CRM_Sales_Order__c'];
        ASI_HK_CRM_Running_Number__c runningNumber = new ASI_HK_CRM_Running_Number__c();
        if (!runningNumberList.isEmpty())
            runningNumber = runningNumberList.get(0);
        else
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Score calculation failed because the record ASI_HK_CRM_Sales_Order__c for the Object ASI_HK_CRM_Running_Number__c is missing. Please contact the System Administrator to verify that this Running Number record is deployed'));
            return null;
        }

        Integer month = (Integer) runningNumber.ASI_HK_CRM_First_Month_of_Fiscal_Year__c;

        Integer year = Datetime.now().year();
        //Integer year = 2015;

        Datetime endFiscal = Datetime.newInstance(year, month,1);
        Datetime startFiscal = Datetime.newInstance(year, month,1);
        endFiscal = endFiscal.addDays(1);
        Date startFiscalDate = startFiscal.Date();

        //not in use
        Date endFiscalDate = endFiscal.Date();

        // if the startfiscaldate is in the future, change the year to the last year 
        if (startFiscalDate > date.today())
            startFiscalDate = startFiscalDate.addyears(-1);
        system.debug('doto2 ' + startFiscalDate);
        //AggregateResult[] groupedResults2 = [select sum(ASI_HK_CRM_Total_Amount__c) from ASI_HK_CRM_Sales_Order_History__c where ASI_HK_CRM_Account_PA__c =:account.id
        //and createdDate >=:startFiscal  and createdDate <=:endFiscal];
        List<ASI_HK_CRM_Sales_Order_History__c > list2 = [select ASI_HK_CRM_Total_Amount__c from ASI_HK_CRM_Sales_Order_History__c where ASI_HK_CRM_Account_PA__c =:account.id
        and ASI_HK_CRM_Order_Date__c >=:startFiscalDate];

        List<CampaignMember> campaignmemberList = [SELECT ID, CampaignID, ContactID FROM CampaignMember WHERE Contact.AccountID =: account.id AND Status = : 'Attended'];

        set<id> campaignSet = new set<ID>();
        for (CampaignMember i : campaignmemberList)
            campaignset.add(i.CampaignID);
    
        List<Campaign> campaignList = [SELECT StartDate, EndDate, Status From Campaign WHERE ID IN : campaignset AND StartDate != NULL AND EndDate != NULL];

        Decimal sumCampaignAttended = 0;
        for (Campaign i : campaignList)
        {
            if (i.EndDate >= startFiscalDate)
            {
                sumCampaignAttended += 1;
            }
        }

        if (sumCampaignAttended < 5)
        {
            account.ASI_LUX_Segment_Involvement_YTD__c = 'Low < 5 Physically attended events';
        }
        else
        {
            account.ASI_LUX_Segment_Involvement_YTD__c = 'High ≥ 5 Physically attended events';
        }

        //Decimal sumFiscal = (Decimal)(groupedResults2[0].get('expr0'));
        Decimal sumFiscal = 0;

        for(ASI_HK_CRM_Sales_Order_History__c a : list2){
            sumFiscal = sumFiscal + (a.ASI_HK_CRM_Total_Amount__c == null ? 0.0 : a.ASI_HK_CRM_Total_Amount__c);
        }
        
        if (account.recordtype.developername.contains('Account_TW'))
        {
            if(sumFiscal < 290000){
                account.ASI_LUX_Segmentation_Value_YTD__c = 'Low < TWD 290K';
            }else{
                account.ASI_LUX_Segmentation_Value_YTD__c = 'High ≥ TWD 290K';
            }
        }
        else
        {
            if(sumFiscal < 75000){
                account.ASI_LUX_Segmentation_Value_YTD__c = 'Low < HKD 75K';
            }else{
                account.ASI_LUX_Segmentation_Value_YTD__c = 'High ≥ HKD 75K';
            }
        }
        
        update(account);
        return new PageReference('/' + account.Id);
    }

}