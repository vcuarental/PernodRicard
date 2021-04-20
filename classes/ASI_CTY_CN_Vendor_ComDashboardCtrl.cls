/*********************************************************************************
 * Name: ASI_CTY_CN_Vendor_ComDashboardCtrl
 * Description: Statistics of Po report data
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 28/08/2020       wangzhiqiang             Created          
*/
public without sharing class ASI_CTY_CN_Vendor_ComDashboardCtrl {


     @AuraEnabled
     public static CountPoNums getPoDataCount(String typeName)
     {
        // type：1-By Quantity；2-By Amount
        Date endDate = Date.today();
        Date beginDate = endDate.addMonths(-24);
        System.debug(LoggingLevel.INFO, '*** beginDate: ' + beginDate);
        Date endMonthDate = Date.newInstance(endDate.year(),  endDate.month()+1, 1);
        Date beginMonthDate = Date.newInstance(endDate.year(),  endDate.month()-5, 1);
        CountPoNums poNum = new CountPoNums();

        //Get the supplier customer corresponding to the current user
        Id accountId = ASI_CTY_CN_Vendor_Util.getAccountId();
        if(typeName.equals('1'))
        {
            // Query Po statistics in the past 24 months
            poNum.poCounts = getNumsByYear(beginDate,endDate,accountId);
            poNum.pendingPayment = getPendingPaymentsByYear(beginDate,endDate,accountId);
            poNum.noFillSir = getNoFillSirsByYear(beginDate,endDate,accountId);

            // Statistics of the total contract data of each month in the past six months
            poNum.cuPoCounts =getNumsByMonths(beginMonthDate,endMonthDate,accountId);

            // Statistics of the total amount of payment applied for each month in the past six months
            poNum.pendingPaymentCounts =getPendingPaymentsByMonths(beginMonthDate,endMonthDate,accountId);
           
            // The total Sir data of each month in the past six months were counted
            poNum.noFillSirs =getNoFillSirsByMonths(beginMonthDate,endMonthDate,accountId);
        }
        else
        {
            // Query Po statistics in the past 24 months
            poNum.poCounts = getAmountByYear(beginDate,endDate,accountId);
            poNum.pendingPayment = getPendingPaymentsAmountByYear(beginDate,endDate,accountId);
            poNum.noFillSir = getNoFillSirsAmountByYear(beginDate,endDate,accountId);

            // The total contract amount of each month in the past six months shall be counted respectively
            poNum.cuPoCounts =getAmountByMonths(beginMonthDate,endMonthDate,accountId);

            // The total amount of contract with application for payment in each month in the past 6 months was counted respectively
            poNum.pendingPaymentCounts =getPendingPaymentsAmountByMonths(beginMonthDate,endMonthDate,accountId);

            // The total amount to be filled in the contract in each month in the past 6 months is counted respectively
            poNum.noFillSirs =getNoFillSirsAmountByMonths(beginMonthDate,endMonthDate,accountId);
        }


        poNum.months = getMonths();
        return poNum;
     }

     public static Decimal getNumsByYear(Date beginDate,Date endDate,Id accountId)
     {
        List<AggregateResult> pos= [SELECT count(Id) FROM ASI_MFM_PO__c WHERE  CreatedDate>=:beginDate AND CreatedDate<=:endDate
                                    AND (RecordType.Name ='CN PO' OR RecordType.Name='CN PO Read-Only') AND ASI_MFM_PO_Type__c='eMarket' AND
                                    ASI_MFM_Supplier_Name__c = :accountId ]; 
        AggregateResult aggr = pos.get(0);
        Decimal poCounts = (Decimal)aggr.get('expr0');
        return poCounts;
     }

     public static Decimal getPendingPaymentsByYear(Date beginDate,Date endDate,Id accountId)
     {
        List<AggregateResult> pos= [SELECT count(Id) FROM ASI_MFM_PO__c WHERE  CreatedDate>=:beginDate AND CreatedDate<=:endDate
                                    AND ASI_CTY_CN_Vendor_IsPayoff__c = false AND (RecordType.Name ='CN PO' OR RecordType.Name='CN PO Read-Only')
                                    AND ASI_MFM_PO_Type__c='eMarket' AND
                                    ASI_MFM_Supplier_Name__c = :accountId ];
        AggregateResult aggr = pos.get(0);
        Decimal pendingPayment = (Decimal)aggr.get('expr0');
        return pendingPayment;
     }

     public static Decimal getNoFillSirsByYear(Date beginDate,Date endDate,Id accountId)
     {
        List<AggregateResult> pos= [SELECT count(Id) FROM ASI_MFM_PO__c WHERE  CreatedDate>=:beginDate AND CreatedDate<=:endDate
                                    AND ASI_CTY_CN_Vendor_Fill_Sir__c  = false AND (RecordType.Name ='CN PO' OR RecordType.Name='CN PO Read-Only') 
                                    AND ASI_MFM_PO_Type__c='eMarket' AND
                                    ASI_MFM_Supplier_Name__c = :accountId];
        AggregateResult aggr = pos.get(0);
        Decimal noFillSir = (Decimal)aggr.get('expr0');
        return noFillSir;
     }

     public static List<Decimal> getNumsByMonths(Date beginDate,Date endDate,Id accountId)
     { 
        
        List<AggregateResult> pos= [SELECT  calendar_month(CreatedDate) m,count(Id) FROM ASI_MFM_PO__c WHERE  CreatedDate>=:beginDate AND CreatedDate<:endDate
                                    AND (RecordType.Name ='CN PO' OR RecordType.Name='CN PO Read-Only') 
                                    AND ASI_MFM_PO_Type__c='eMarket' AND ASI_MFM_Supplier_Name__c = :accountId  
                                    group by calendar_month(CreatedDate)];
        System.debug(LoggingLevel.INFO, '*** pos: ' + pos);
        return handleDate(pos,beginDate);
     }

     

     public static List<Decimal> getPendingPaymentsByMonths(Date beginDate,Date endDate,Id accountId)
     { 
        
        List<AggregateResult> pos= [SELECT calendar_month(CreatedDate) m,count(Id) FROM ASI_MFM_Payment__c WHERE  CreatedDate>=:beginDate AND CreatedDate<=:endDate
                                    AND (RecordType.Name ='CN Payment' OR RecordType.Name='CN Payment Read-Only') 
                                    AND ASI_MFM_Supplier_Name__c =:accountId 
                                    group by calendar_month(CreatedDate)
                                    ];
       return handleDate(pos,beginDate);
     }

     public static List<Decimal> getNoFillSirsByMonths(Date beginDate,Date endDate,Id accountId)
     { 
        
        List<AggregateResult> pos= [SELECT calendar_month(CreatedDate) m,count(Id) FROM ASI_MFM_Stock_In_Request__c WHERE  CreatedDate>=:beginDate AND CreatedDate<=:endDate
                                    AND ASI_MFM_PO_POSM_Line_Number__r.ASI_MFM_PO__r.ASI_MFM_Supplier_Name__c =:accountId 
                                    AND (ASI_MFM_PO_POSM_Line_Number__r.ASI_MFM_PO__r.RecordType.Name ='CN PO' OR ASI_MFM_PO_POSM_Line_Number__r.ASI_MFM_PO__r.RecordType.Name ='CN PO Read-Only')
                                    AND  ASI_MFM_PO_POSM_Line_Number__r.ASI_MFM_PO__r.ASI_MFM_PO_Type__c ='eMarket' 
                                    group by calendar_month(CreatedDate)];
        return handleDate(pos,beginDate);
     }


     // 获取金额
     public static Decimal getAmountByYear(Date beginDate,Date endDate,Id accountId)
     {
        List<AggregateResult> pos= [SELECT sum(ASI_MFM_PO_Amount__c) FROM ASI_MFM_PO__c WHERE  CreatedDate>=:beginDate AND CreatedDate<=:endDate
                                    AND (RecordType.Name ='CN PO' OR RecordType.Name='CN PO Read-Only') 
                                    AND ASI_MFM_PO_Type__c='eMarket' AND
                                    ASI_MFM_Supplier_Name__c = :accountId];
        AggregateResult aggr = pos.get(0);
        Decimal  poCounts = (Decimal)aggr.get('expr0');
        if(null == poCounts)
        {
            poCounts = 0;
        }
        poCounts = (poCounts/10000).setScale(2);
        return poCounts;
     }

     public static Decimal getPendingPaymentsAmountByYear(Date beginDate,Date endDate,Id accountId)
     {
        List<AggregateResult> pos= [SELECT sum(ASI_CTY_CN_Vendor_Pending_Amount__c) FROM ASI_MFM_PO__c WHERE  CreatedDate>=:beginDate AND CreatedDate<=:endDate
                                    AND ASI_CTY_CN_Vendor_IsPayoff__c = false AND (RecordType.Name ='CN PO' OR RecordType.Name='CN PO Read-Only') 
                                    AND ASI_MFM_PO_Type__c='eMarket' AND
                                    ASI_MFM_Supplier_Name__c = :accountId];
        AggregateResult aggr = pos.get(0);
        Decimal pendingPayment = (Decimal)aggr.get('expr0');
        if(null == pendingPayment)
        {
            pendingPayment = 0;
        }
        pendingPayment = (pendingPayment/10000).setScale(2);
        return pendingPayment;
     }

     public static Decimal getNoFillSirsAmountByYear(Date beginDate,Date endDate,Id accountId)
     {
        List<AggregateResult> pos= [SELECT sum(ASI_CTY_CN_Vendor_No_Fill_SirAmount__c ) FROM ASI_MFM_PO__c WHERE  CreatedDate>=:beginDate AND CreatedDate<=:endDate
                                    AND ASI_CTY_CN_Vendor_Fill_Sir__c  = false AND (RecordType.Name ='CN PO' OR RecordType.Name='CN PO Read-Only') 
                                    AND ASI_MFM_PO_Type__c='eMarket' AND
                                    ASI_MFM_Supplier_Name__c = :accountId];
        AggregateResult aggr = pos.get(0);
        Decimal noFillSir = (Decimal)aggr.get('expr0');
        if(null == noFillSir)
        {
            noFillSir = 0;
        }
        noFillSir = (noFillSir/10000).setScale(2);
        return noFillSir;
     }

     public static  List<Decimal> getAmountByMonths(Date beginDate,Date endDate,Id accountId)
     { 
        
        List<AggregateResult> pos= [SELECT calendar_month(CreatedDate) m,sum(ASI_MFM_PO_Amount__c) FROM ASI_MFM_PO__c WHERE  CreatedDate>=:beginDate AND CreatedDate<:endDate
                                    AND (RecordType.Name ='CN PO' OR RecordType.Name='CN PO Read-Only') 
                                    AND ASI_MFM_PO_Type__c='eMarket' AND
                                    ASI_MFM_Supplier_Name__c = :accountId group by calendar_month(CreatedDate)];
        return  handleAmountDate(pos,beginDate);
     }

     public static  List<Decimal> getPendingPaymentsAmountByMonths(Date beginDate,Date endDate,Id accountId)
     { 
        
        List<AggregateResult> pos= [SELECT calendar_month(CreatedDate) m,sum(ASI_MFM_Payment_Amount__c) FROM ASI_MFM_Payment__c WHERE  CreatedDate>=:beginDate AND CreatedDate<=:endDate
                                    AND (RecordType.Name ='CN Payment' OR RecordType.Name='CN Payment Read-Only') 
                                    AND ASI_MFM_Supplier_Name__c =:accountId 
                                    group by calendar_month(CreatedDate)];
        return  handleAmountDate(pos,beginDate);
     }

     public static  List<Decimal> getNoFillSirsAmountByMonths(Date beginDate,Date endDate,Id accountId)
     { 
        List<AggregateResult> pos= [SELECT calendar_month(CreatedDate) m,sum(ASI_CTY_CN_Vendor_Amount__c) FROM ASI_MFM_Stock_In_Request__c WHERE  CreatedDate>=:beginDate AND CreatedDate<=:endDate
                                    AND ASI_MFM_PO_POSM_Line_Number__r.ASI_MFM_PO__r.ASI_MFM_Supplier_Name__c =:accountId 
                                    AND (ASI_MFM_PO_POSM_Line_Number__r.ASI_MFM_PO__r.RecordType.Name ='CN PO' OR ASI_MFM_PO_POSM_Line_Number__r.ASI_MFM_PO__r.RecordType.Name ='CN PO Read-Only')
                                    AND  ASI_MFM_PO_POSM_Line_Number__r.ASI_MFM_PO__r.ASI_MFM_PO_Type__c ='eMarket'
                                    group by calendar_month(CreatedDate)
                                    ];
        System.debug(LoggingLevel.INFO, '*** pos: ' + pos);
        return  handleAmountDate(pos,beginDate);
     }

     public static  List<String> getMonths()
     {
        List<String> months = new List<String>();
        Date tempDate = Date.today();
        for(Integer i=5;i>=0;i--)
        {
            months.add(tempDate.addMonths(-i).month()+'月');
        }
       return months;
     }

     public static List<Decimal> handleDate(List<AggregateResult> pos,Date beginDate)
     {
        System.debug(LoggingLevel.INFO, '*** pos: ' + pos);
        Map<Integer,Decimal> monthValueMap = new Map<Integer,Decimal>();
        List<Decimal> summarydDate = new List<Decimal>();
        if(pos.size()>0)
        {
            for(AggregateResult po:pos)
            {
              monthValueMap.put((Integer)po.get('m'),(Decimal)po.get('expr0'));
            }
            System.debug(LoggingLevel.INFO, '*** monthValueMap: ' + monthValueMap);
            Date tempDate = Date.today();

            for(Integer i=5;i>=0;i--)
            {
               Integer newMonth = tempDate.addMonths(-i).month();
               if(null == monthValueMap.get(newMonth))
                {
                  summarydDate.add(0);
                }
                else
                {
                  summarydDate.add(monthValueMap.get(newMonth));
                }
            }
        }
        System.debug(LoggingLevel.INFO, '*** summarydDate: ' + summarydDate);
        
        return summarydDate;
      }

     public static List<Decimal> handleAmountDate(List<AggregateResult> pos,Date beginDate)
     {
        Map<Integer,Decimal> monthValueMap = new Map<Integer,Decimal>();
        List<Decimal> summarydDate = new List<Decimal>();
        if(pos.size()>0)
        {
            for(AggregateResult po:pos)
            {
              monthValueMap.put((Integer)po.get('m'),(Decimal)po.get('expr0'));
            }
            System.debug(LoggingLevel.INFO, '*** monthValueMap: ' + monthValueMap);
            Date tempDate = Date.today();
            for(Integer i=5;i>=0;i--)
            {
                Integer newMonth = tempDate.addMonths(-i).month();
                if(null == monthValueMap.get(newMonth))
                {
                  summarydDate.add(0);
                }
                else
                {
                  Decimal poCounts =  monthValueMap.get(newMonth);
                  poCounts = (poCounts/10000).setScale(2);
                  summarydDate.add(poCounts);
                }
            }
        }
        
        return summarydDate;
      }


     
     public class CountPoNums{
        @AuraEnabled
        public Decimal poCounts;
        @AuraEnabled
        public List<Decimal> cuPoCounts;
        @AuraEnabled
        public Decimal pendingPayment;
        @AuraEnabled
        public List<Decimal> pendingPaymentCounts;
        @AuraEnabled
        public Decimal noFillSir;
        @AuraEnabled
        public List<Decimal> noFillSirs;
        @AuraEnabled
        public List<String> months;
     }
    
}