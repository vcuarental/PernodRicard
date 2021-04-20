/*
    Developed by Kendy Tam: 07/04/2014
    Batch to init the Stock-In-Trade Detail
*/
global with sharing class ASI_TH_CRM_SITDetail_Init_Batch implements Database.Batchable<sObject> ,Database.Stateful{
    private List<ASI_TH_CRM_Offtake_Stock_In_Trade_Detail__c> lastMonthStockInTrades;
        
    private List<AggregateResult> sellInSumUps;
    
    private List<AggregateResult> actualOfftakes;
     
    global Database.QueryLocator start(Database.BatchableContext BC){
      
        String soqlQuery = 'SELECT ASI_TH_CRM_Account__c, ASI_TH_CRM_Account__r.ASI_KOR_Customer_Code__c, ASI_TH_CRM_Sub_brand__c, RecordType.DeveloperName, ASI_TH_CRM_Date__c,ASI_TH_CRM_Beginning_Stock__c, ASI_TH_CRM_Total_Offtake_Final__c, ASI_TH_CRM_Others__c, ASI_TH_CRM_Ending_Stock_Final__c, ASI_TH_CRM_Sell_In__c,ASI_TH_CRM_On_premise_Offtake__c,ASI_TH_CRM_Year__c,ASI_TH_CRM_Month__c FROM ASI_TH_CRM_Offtake_Stock_In_Trade_Detail__c WHERE RecordType.DeveloperName IN (\'ASI_TH_CRM_MT_Stock_In_Trade_Detail\',\'ASI_TH_CRM_WS_Stock_In_Trade_Detail\')  AND ASI_TH_CRM_Date__c = LAST_MONTH AND ASI_TH_CRM_Bypass_Calculation__c= false AND ASI_TH_CRM_SIT__r.ASI_TH_CRM_Status__c != \'Locked\'';
   
        System.debug('soqlQuery:' + soqlQuery);
   
        return Database.getQueryLocator(soqlQuery);
   }

    global void execute(Database.BatchableContext BC,  List<sObject> scope){
        if (scope == null) return;
       
        List<String> accounts = new List<String>();
        List<String> subBrands = new List<String>();
        Map<id,String> mapTrustedOfftakeSIT = new Map<id,String>();
       
        for(sObject sObj : scope){
           ASI_TH_CRM_Offtake_Stock_In_Trade_Detail__c stockInTradeDetail = (ASI_TH_CRM_Offtake_Stock_In_Trade_Detail__c) sObj;
           //System.debug('stockInTradeDetail:' + stockInTradeDetail);
           
           accounts.add(stockInTradeDetail.ASI_TH_CRM_Account__c);
           subBrands.add(stockInTradeDetail.ASI_TH_CRM_Sub_brand__c);
        }
        
        Date last2month = Date.today().addMonths(-2);
        Datetime dt = Datetime.newInstance(last2month.year(), last2month.month(),last2month.day());
        String year = String.valueOf(last2month.year());
        String month = dt.format('MMM');       
        //System.debug('Month:' + month);     
        
        //Retrieve Ending Stock
        lastMonthStockInTrades = [SELECT ASI_TH_CRM_Account__c, ASI_TH_CRM_Sub_brand__c, RecordType.DeveloperName, ASI_TH_CRM_Year__c,ASI_TH_CRM_Month__c,ASI_TH_CRM_Others__c, ASI_TH_CRM_Ending_Stock_Final__c FROM ASI_TH_CRM_Offtake_Stock_In_Trade_Detail__c WHERE ASI_TH_CRM_Account__c IN :accounts AND ASI_TH_CRM_Sub_brand__c IN :subBrands AND ASI_TH_CRM_Year__c = :year AND ASI_TH_CRM_Month__c = :month];                       
        System.debug('lastMonthStockInTrades :' + lastMonthStockInTrades );  
        
        //Added by William Yang(Introv) @2016-4-25
        //Retrieve Customer records
        for(ASI_CRM_AccountsAdditionalField__c customer:[SELECT id, ASI_CRM_Account__c, ASI_CRM_Trusted_Offtake_SIT__c FROM ASI_CRM_AccountsAdditionalField__c WHERE ASI_CRM_Account__c IN :accounts])
            if(!mapTrustedOfftakeSIT.containsKey(customer.ASI_CRM_Account__c))
                mapTrustedOfftakeSIT.put(customer.ASI_CRM_Account__c, customer.ASI_CRM_Trusted_Offtake_SIT__c);
        
        //Retrieve Sell-in 
        sellInSumUps = [SELECT ASI_TH_CRM_Customer__c customer, ASI_TH_CRM_Sub_brand__c subBrand,CALENDAR_YEAR(ASI_TH_CRM_GL_Date__c) year,CALENDAR_MONTH(ASI_TH_CRM_GL_Date__c) month,SUM(ASI_TH_CRM_Qty__c) sellIn FROM ASI_TH_CRM_Sell_in__c WHERE ASI_TH_CRM_Customer__c IN :accounts AND ASI_TH_CRM_Sub_brand__c IN :subBrands AND ASI_TH_CRM_GL_Date__c = LAST_MONTH GROUP BY ASI_TH_CRM_Customer__c, ASI_TH_CRM_Sub_brand__c,CALENDAR_YEAR(ASI_TH_CRM_GL_Date__c),CALENDAR_MONTH(ASI_TH_CRM_GL_Date__c)];
      
        //Modified by William Yang 20140416
        //Retrieve Actual Offtake
        actualOfftakes = [SELECT ASI_TH_CRM_From_Wholesaler__c wholesaler, ASI_TH_CRM_Sub_brand__c subBrand,CALENDAR_YEAR(ASI_TH_CRM_Offtake_G_L_Date__c) year,  CALENDAR_MONTH(ASI_TH_CRM_Offtake_G_L_Date__c) month,SUM(ASI_TH_CRM_Quantity__c) offtake FROM ASI_TH_CRM_Actual_Offtake__c WHERE ASI_TH_CRM_Offtake_G_L_Date__c = LAST_MONTH AND ASI_TH_CRM_From_Wholesaler__c IN :accounts AND ASI_TH_CRM_Sub_brand__c IN :subBrands AND ASI_TH_CRM_Delete__c = FALSE AND ASI_TH_CRM_Quantity__c != null GROUP BY ASI_TH_CRM_From_Wholesaler__c, ASI_TH_CRM_Sub_brand__c, CALENDAR_YEAR(ASI_TH_CRM_Offtake_G_L_Date__c), CALENDAR_MONTH(ASI_TH_CRM_Offtake_G_L_Date__c) ];
             
  
        for(sObject sObj : scope){
            ASI_TH_CRM_Offtake_Stock_In_Trade_Detail__c stockInTradeDetail = (ASI_TH_CRM_Offtake_Stock_In_Trade_Detail__c) sObj;
                     
            if(lastMonthStockInTrades != null){
                for(ASI_TH_CRM_Offtake_Stock_In_Trade_Detail__c lastStockInTradeDetail :lastMonthStockInTrades){
                   if(stockInTradeDetail.ASI_TH_CRM_Account__c == lastStockInTradeDetail.ASI_TH_CRM_Account__c  && stockInTradeDetail.ASI_TH_CRM_Sub_brand__c == lastStockInTradeDetail.ASI_TH_CRM_Sub_brand__c &&  stockInTradeDetail.RecordType.DeveloperName == lastStockInTradeDetail.RecordType.DeveloperName){
                       stockInTradeDetail.ASI_TH_CRM_Beginning_Stock__c = lastStockInTradeDetail.ASI_TH_CRM_Ending_Stock_Final__c;
                       break;
                    }
                }
            }
            //System.debug('ASI_TH_CRM_Sell_In__c:' + stockInTradeDetail.ASI_TH_CRM_Sell_In__c );
            if(sellInSumUps != null){
                for(AggregateResult sellInSumUp : sellInSumUps){             
                    if(stockInTradeDetail.ASI_TH_CRM_Account__c == String.valueOf(sellInSumUp.get('customer')) && stockInTradeDetail.ASI_TH_CRM_Sub_brand__c == String.valueOf(sellInSumUp.get('subBrand')) && stockInTradeDetail.ASI_TH_CRM_Date__c.month() == Integer.valueOf(sellInSumUp.get('month'))){
                        stockInTradeDetail.ASI_TH_CRM_Sell_In__c = Decimal.valueOf(String.valueOf(sellInSumUp.get('sellIn')));                          
                        break;
                    }                 
                }
            }
           
            if(stockInTradeDetail.RecordType.DeveloperName == 'ASI_TH_CRM_WS_Stock_In_Trade_Detail' && actualOfftakes != null){
                //Modified by William Yang 20140416
                for(AggregateResult actualOfftake : actualOfftakes){             
                   if(stockInTradeDetail.ASI_TH_CRM_Account__c == String.valueOf(actualOfftake.get('wholesaler')) && stockInTradeDetail.ASI_TH_CRM_Sub_brand__c == String.valueOf(actualOfftake.get('subBrand')) && stockInTradeDetail.ASI_TH_CRM_Date__c.month() == Integer.valueOf(actualOfftake.get('month'))){
                        stockInTradeDetail.ASI_TH_CRM_On_premise_Offtake__c = Decimal.valueOf(String.valueOf(actualOfftake.get('offtake')));                          
                        break;
                   }                 
                }
            }
            
            //Revised by William Yang(Introv) @2016-4-25
            if(stockInTradeDetail.RecordType.DeveloperName == 'ASI_TH_CRM_MT_Stock_In_Trade_Detail') {
                if(mapTrustedOfftakeSIT.get(stockInTradeDetail.ASI_TH_CRM_Account__c) == 'Ending Stock' && stockInTradeDetail.ASI_TH_CRM_Ending_Stock_Final__c != null) {
                    stockInTradeDetail.ASI_TH_CRM_Total_Offtake_Final__c = (stockInTradeDetail.ASI_TH_CRM_Beginning_Stock__c != null? stockInTradeDetail.ASI_TH_CRM_Beginning_Stock__c:0) + (stockInTradeDetail.ASI_TH_CRM_Sell_In__c !=null?stockInTradeDetail.ASI_TH_CRM_Sell_In__c :0) + (stockInTradeDetail.ASI_TH_CRM_Others__c !=null?stockInTradeDetail.ASI_TH_CRM_Others__c :0) - stockInTradeDetail.ASI_TH_CRM_Ending_Stock_Final__c;
                }
                else if(mapTrustedOfftakeSIT.get(stockInTradeDetail.ASI_TH_CRM_Account__c) == 'Total Offtake' && stockInTradeDetail.ASI_TH_CRM_Total_Offtake_Final__c != null) {
                    stockInTradeDetail.ASI_TH_CRM_Ending_Stock_Final__c = (stockInTradeDetail.ASI_TH_CRM_Beginning_Stock__c != null? stockInTradeDetail.ASI_TH_CRM_Beginning_Stock__c:0) + (stockInTradeDetail.ASI_TH_CRM_Sell_In__c !=null?stockInTradeDetail.ASI_TH_CRM_Sell_In__c :0) + (stockInTradeDetail.ASI_TH_CRM_Others__c !=null?stockInTradeDetail.ASI_TH_CRM_Others__c :0) - stockInTradeDetail.ASI_TH_CRM_Total_Offtake_Final__c;
                }
            } 
           
            if(stockInTradeDetail.RecordType.DeveloperName == 'ASI_TH_CRM_WS_Stock_In_Trade_Detail' && stockInTradeDetail.ASI_TH_CRM_Ending_Stock_Final__c != null)
            { 
                stockInTradeDetail.ASI_TH_CRM_Total_Offtake_Final__c = (stockInTradeDetail.ASI_TH_CRM_Beginning_Stock__c != null? stockInTradeDetail.ASI_TH_CRM_Beginning_Stock__c:0) 
               + (stockInTradeDetail.ASI_TH_CRM_Sell_In__c !=null?stockInTradeDetail.ASI_TH_CRM_Sell_In__c :0)
               + (stockInTradeDetail.ASI_TH_CRM_Others__c!=null?stockInTradeDetail.ASI_TH_CRM_Others__c:0)
               - stockInTradeDetail.ASI_TH_CRM_Ending_Stock_Final__c;
               
                stockInTradeDetail.ASI_TH_CRM_Off_premise_Offtake__c = (stockInTradeDetail.ASI_TH_CRM_Total_Offtake_Final__c!=null?stockInTradeDetail.ASI_TH_CRM_Total_Offtake_Final__c:0)
               - (stockInTradeDetail.ASI_TH_CRM_On_premise_Offtake__c!=null?stockInTradeDetail.ASI_TH_CRM_On_premise_Offtake__c:0);
            }
        }
       
        update scope;
    }

    global void finish(Database.BatchableContext BC){

    }
}