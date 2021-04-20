/*********************************************************************************
 * Name:ASI_LUX_CalculateScoreTrigger
 * Description: Calculate Lux Account score whenever a Sales Order is inserted/Updated
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 09/10/2014       Laputa: Conrad          Created
 * 09/02/2015       Laputa: Conrad          Added SGD Logic
*********************************************************************************/

public with sharing class ASI_LUX_CalculateScoreTrigger extends ASI_HK_CRM_TriggerAbstract {

    // Variable to Add Currency Exchange Against Euros
    private final Set<String> CURRENCY_EXCHANGE = new Set<String>{'HKD', 'TWD', 'JPY', 'SGD'};

    public ASI_LUX_CalculateScoreTrigger() {
        super('ASI_LUX_CalculateScoreTrigger');
    }
    
    public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap) {
    
        List<ASI_HK_CRM_Sales_Order_History__c> validSalesOrderHistoryList = new List<ASI_HK_CRM_Sales_Order_History__c>();
        
        
        if(oldMap == null) {
            for(ASI_HK_CRM_Sales_Order_History__c soHistory : (List<ASI_HK_CRM_Sales_Order_History__c>)sObjList) {
                // Only filter out the sales order where the Amount or Order Date has been updated: only applies for after update
                if(soHistory.ASI_HK_CRM_Order_Date__c != null ) {
                        validSalesOrderHistoryList.add(soHistory);
                    }
            }
        } 
        else {
            
            Map<ID, ASI_HK_CRM_Sales_Order_History__c> soHistoryMap = (Map<ID, ASI_HK_CRM_Sales_Order_History__c>) oldmap;
            
            for(ASI_HK_CRM_Sales_Order_History__c soHistory : (List<ASI_HK_CRM_Sales_Order_History__c>)sObjList) {
                // Only filter out the sales order where the Amount or Order Date has been updated: only applies for after update
                if((soHistory.ASI_HK_CRM_Order_Date__c != soHistoryMap.get(soHistory.id).ASI_HK_CRM_Order_Date__c
                    && soHistory.ASI_HK_CRM_Order_Date__c != null )
                    || soHistory.ASI_HK_CRM_Total_Amount__c != soHistoryMap.get(soHistory.id).ASI_HK_CRM_Total_Amount__c) {
                        validSalesOrderHistoryList.add(soHistory);
                    }
            }
            
        }

        //Calculate Score for the related Account
        if (validSalesOrderHistoryList.size() > 0)
        {
            // Related Accounts to be Updated
            Set<ID> accIDSet = new Set<ID>();
            
            //************************************************* OLD CODE: determine the current start of the fiscal year date
            List<ASI_HK_CRM_Running_Number__c> runningNumberList = [select ASI_HK_CRM_First_Month_of_Fiscal_Year__c from ASI_HK_CRM_Running_Number__c where ASI_HK_CRM_Object_Name__c = 'ASI_HK_CRM_Sales_Order__c'];
            ASI_HK_CRM_Running_Number__c runningNumber = new ASI_HK_CRM_Running_Number__c();
            if (!runningNumberList.isEmpty())
                runningNumber = runningNumberList.get(0);
            
            // loop through the trigger new items to output error if there is no existing running number for Sales Order History
            for(ASI_HK_CRM_Sales_Order_History__c soHistory : validSalesOrderHistoryList) {
                if (runningNumberList.isEmpty()) {
                    soHistory.adderror('Score calculation failed because the record ASI_HK_CRM_Sales_Order__c for the Object ASI_HK_CRM_Running_Number__c is missing. Please contact the System Administrator to verify that this Running Number record is deployed');
                }
                
                if(soHistory.ASI_HK_CRM_Account_PA__c != null) {
                    accIDSet.add(soHistory.ASI_HK_CRM_Account_PA__c);
                }
            }
            
            Integer month = (Integer) runningNumber.ASI_HK_CRM_First_Month_of_Fiscal_Year__c;
            Integer year = Datetime.now().year();

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
            //************************************************* OLD CODE: END
            
            // Retrieve the related account accordingly
            Map<ID, Account> accountMap = new Map<ID, Account>([
                                                                SELECT ID, firstname, lastname, ASI_LUX_Purchase_Behavior_Spend_YTD__c,
                                                                ASI_LUX_Purchase_Behavior_Freq_YTD__c, ASI_LUX_Well_conn_within_social_circle__c,
                                                                ASI_LUX_Recognized_within_their_industry__c, ASI_LUX_Has_media_interest__c, 
                                                                ASI_LUX_Total_Score__c, recordtypeid,
                                                                    (
                                                                        SELECT ID, Name, ASI_HK_CRM_Account_PA__c, ASI_HK_CRM_Total_Amount__c,
                                                                        ASI_HK_CRM_Order_Date__c
                                                                        FROM ASI_HK_CRM_Sales_Order_Histories__r
                                                                        WHERE ASI_HK_CRM_Order_Date__c >=:startFiscalDate
                                                                    )
                                                                FROM account WHERE ID IN : accIDSet
                                                                ]);
            
            // Map the conversion Rate
            List<ASI_LUX_FX_Conversion_Rate__c> conversionRateList = [select name, ASI_LUX_Local_Currency_To_EUR__c from ASI_LUX_FX_Conversion_Rate__c where name IN : CURRENCY_EXCHANGE];
            Map<String, ASI_LUX_FX_Conversion_Rate__c> conversionRateMap = new Map<String, ASI_LUX_FX_Conversion_Rate__c>();
            for (ASI_LUX_FX_Conversion_Rate__c conversionRate : conversionRateList){
                conversionRateMap.put(conversionRate.name, conversionRate);
            }
            
            List<Account> accToUpdateList = new List<Account>();
            
            // Core Logic: Calculate the score and other variables
            for (Account acc : accountMap.values()) {
                totalScore = 0;
                List<ASI_HK_CRM_Sales_Order_History__c> salesOrderHistoryList = acc.ASI_HK_CRM_Sales_Order_Histories__r;
                Decimal sumFiscal = 0;
                Decimal freq = 0;
                
                for(ASI_HK_CRM_Sales_Order_History__c sohistory : salesOrderHistoryList) {
                    
                    sumFiscal += (sohistory.ASI_HK_CRM_Total_Amount__c == null ? 0.0 : sohistory.ASI_HK_CRM_Total_Amount__c);
                    freq += 1;
                }
                
                acc.ASI_LUX_Segmentation_Value_YTD__c = calcSegmentationValue(acc, sumFiscal);
                
                sumFiscal = currencyDependentCalcScore(acc, sumFiscal, conversionRateMap);
                
                if(sumFiscal >= 0 && sumFiscal <= 2400){
                    acc.ASI_LUX_Purchase_Behavior_Spend_YTD__c = 'Score 1: EUR 0 - 2,400';
                    totalScore = totalScore + 1;
                }else if(sumFiscal >2400&& sumFiscal <= 4800){
                    acc.ASI_LUX_Purchase_Behavior_Spend_YTD__c = 'Score 2: EUR 2,401 - 4,800';
                    totalScore = totalScore + 2;
                }else if(sumFiscal >4800&& sumFiscal <= 7300){
                    acc.ASI_LUX_Purchase_Behavior_Spend_YTD__c = 'Score 3: EUR 4,801 – 7,300';
                    totalScore = totalScore + 3;
                }else if(sumFiscal >7300&& sumFiscal <= 9700){
                    acc.ASI_LUX_Purchase_Behavior_Spend_YTD__c = 'Score 4: EUR 7,301 – 9,700';
                    totalScore = totalScore + 4;
                }else if(sumFiscal >9700&& sumFiscal <= 19400){
                    acc.ASI_LUX_Purchase_Behavior_Spend_YTD__c = 'Score 5: EUR 9,701 – 19,400';
                    totalScore = totalScore + 5;
                }else if(sumFiscal >19400&& sumFiscal <= 29200){
                    acc.ASI_LUX_Purchase_Behavior_Spend_YTD__c = 'Score 6: EUR 19,401– 29,200';
                    totalScore = totalScore + 6;
                }else if(sumFiscal >29200&& sumFiscal <= 38900){
                    acc.ASI_LUX_Purchase_Behavior_Spend_YTD__c = 'Score 7: EUR 29,201 – 38,900';
                    totalScore = totalScore + 7;
                }else if(sumFiscal >38900&& sumFiscal <= 48700){
                    acc.ASI_LUX_Purchase_Behavior_Spend_YTD__c = 'Score 8: EUR 38,901 – 48,700';
                    totalScore = totalScore + 8;
                }else if(sumFiscal >48700){
                    acc.ASI_LUX_Purchase_Behavior_Spend_YTD__c = 'Score 9: EUR 48,701 and / or above';
                    totalScore = totalScore + 9;
                }
                
                if(freq == 0){
                    acc.ASI_LUX_Purchase_Behavior_Freq_YTD__c = 'Score = 0 -> PF = 0';
                } else if(freq > 0 && freq <= 1){
                    totalScore = totalScore + 1;
                    acc.ASI_LUX_Purchase_Behavior_Freq_YTD__c = 'Score = 1 -> PF = once a year';
                } else if(freq > 1 && freq <4){
                    totalScore = totalScore + 2;
                    acc.ASI_LUX_Purchase_Behavior_Freq_YTD__c = 'Score = 2 -> PF = once every 6 months';
                } else if(freq >=4 && freq <12){
                    totalScore = totalScore + 3;
                    acc.ASI_LUX_Purchase_Behavior_Freq_YTD__c = 'Score = 3 -> PF = once every 3 months';
                } else if(freq >=12 && freq <= 26){
                    totalScore = totalScore + 4;
                    acc.ASI_LUX_Purchase_Behavior_Freq_YTD__c = 'Score = 4 -> PF = once a month';
                } else if(freq > 26){
                    totalScore = totalScore + 5;
                    acc.ASI_LUX_Purchase_Behavior_Freq_YTD__c = 'Score = 5 -> PF = once every 2 weeks';
                }
                
                if ('1 Low'.equals (acc.ASI_LUX_Well_conn_within_social_circle__c)){
                    totalScore = totalScore + 1;
                }else if ('3 Medium'.equals (acc.ASI_LUX_Well_conn_within_social_circle__c)){
                    totalScore = totalScore + 3;
                } else if ('5 High'.equals (acc.ASI_LUX_Well_conn_within_social_circle__c)){
                    totalScore = totalScore + 5;
                }

                if ('1 Low'.equals (acc.ASI_LUX_Recognized_within_their_industry__c)){
                    totalScore = totalScore + 1;
                }else if ('3 Medium'.equals (acc.ASI_LUX_Recognized_within_their_industry__c)){
                    totalScore = totalScore + 3;
                }else if ('5 High'.equals (acc.ASI_LUX_Recognized_within_their_industry__c)){
                    totalScore = totalScore + 5;
                }

                if ('1 Low'.equals (acc.ASI_LUX_Has_media_interest__c)){
                    totalScore = totalScore + 1;
                }else if ('3 Medium'.equals (acc.ASI_LUX_Has_media_interest__c)){
                    totalScore = totalScore + 3;
                }else if ('5 High'.equals (acc.ASI_LUX_Has_media_interest__c)){
                    totalScore = totalScore + 5;
                }
                acc.ASI_LUX_Total_Score__c = totalScore;
                
                accToUpdateList.add(acc);
            }
            
            if (accToUpdateList.size() > 0) {
                update accToUpdateList;
            }
            
        }
    
    }
    
    /*********************************************************************************
     * Description: Currency Dependent Calculation: return Account Score Segmentation Depending on Account recordtype
     *
     * Parameters:  acc_PARAM: Account to be Changed
     *              totalAmount: amount calculated
     *
     * Return: decimal
    *********************************************************************************/
    private String calcSegmentationValue (Account acc_PARAM, decimal totalAmount) {
    
        String developerName = Global_RecordTypeCache.getRt(acc_PARAM.recordTypeId).developerName;
        String segmentationValue = '';
        
        // Base case is 1
        if (developername.contains('Account_TW')) {
            if(totalAmount < 290000){
                segmentationValue = 'Low < TWD 290K';
            }else{
                segmentationValue = 'High ≥ TWD 290K';
            }
        } else if (developername.contains('Account_JP')) {
            if(totalAmount < 1050000){
                segmentationValue = 'Low < JPY 1000K';
            }else{
                segmentationValue = 'High ≥ JPY 1000K';
            }
        } else if (developername.contains('Account_HK')){
            if(totalAmount < 75000){
                segmentationValue = 'Low < HKD 75K';
            }else{
                segmentationValue = 'High ≥ HKD 75K';
            }
        } else if (developername.contains('SG_Account')){
            if(totalAmount < 10000){
                segmentationValue = 'Low < SGD 10K';
            }else{
                segmentationValue = 'High ≥ SGD 10K';
            }
        }
        
        return segmentationValue;
    }
    
    /*********************************************************************************
     * Description: Currency Dependent Calculation: return Account Score Calculation Depending on Currency exchange
     *
     * Parameters:  acc_PARAM: Account to be Changed
     *              totalAmount: amount calculated
     *              conversionRateMap_PARAM : conversion rate map
     *
     * Return: decimal
    *********************************************************************************/
    private decimal currencyDependentCalcScore (Account acc_PARAM, decimal totalAmount, Map<String, ASI_LUX_FX_Conversion_Rate__c> conversionRateMap_PARAM) {
    
        String developerName = Global_RecordTypeCache.getRt(acc_PARAM.recordTypeId).developerName;
        Decimal conversionFactor = 1;
        
        // Base case is 1
        if (developername.contains('Account_TW')) {
            conversionFactor = conversionRateMap_PARAM.get('TWD') != null ? conversionRateMap_PARAM.get('TWD').ASI_LUX_Local_Currency_To_EUR__c : 1;
        } else if (developername.contains('Account_JP')) {
            conversionFactor = conversionRateMap_PARAM.get('JPY') != null ? conversionRateMap_PARAM.get('JPY').ASI_LUX_Local_Currency_To_EUR__c : 1;
        } else if (developername.contains('Account_HK')){
            conversionFactor = conversionRateMap_PARAM.get('HKD') != null ? conversionRateMap_PARAM.get('HKD').ASI_LUX_Local_Currency_To_EUR__c : 1;
        } else if (developername.contains('SG_Account')){
            conversionFactor = conversionRateMap_PARAM.get('SGD') != null ? conversionRateMap_PARAM.get('SGD').ASI_LUX_Local_Currency_To_EUR__c : 1;
        }
        
        totalAmount = totalAmount * conversionFactor;
        
        return totalamount;
    }
}