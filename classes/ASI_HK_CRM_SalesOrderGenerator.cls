public with sharing class ASI_HK_CRM_SalesOrderGenerator {

    public static final Date DEF_VALUE_ORDER_DATE = System.today();
    //public static final Date DEF_VALUE_DELIVERY_DATE = DEF_VALUE_ORDER_DATE.addDays(1);
    public static final String DEF_VALUE_PAYMENT_METHOD = 'N/A';
    public static final String RT_Default = 'ASI_HK_CRM_Sales_Order_Normal';
    public static final String RT_Paused = 'ASI_HK_CRM_Sales_Order_Paused';

    private static Map<String, RecordType> RTMap {
        get {
            if (RTMap == null) {
                List<RecordType> RTList = [SELECT Id, Name, DeveloperName, IsActive, SobjectType, NamespacePrefix, BusinessProcessId FROM RecordType WHERE SobjectType = 'ASI_HK_CRM_Sales_Order__c'];
                RTMap = new Map<String, RecordType>();
                for (RecordType rt : RTList) {
                    RTMap.put(rt.DeveloperName, rt);
                }
            }
            return RTMap;
        }
        set;
    }

    public static RecordType getRecordTypeByDevName(String devName) { return RTMap.get(devName); }
    public static Set<String> allRecordTypeDevNames() {
        return new Set<String> {
            ASI_HK_CRM_SalesOrderGenerator.RT_Default
            , ASI_HK_CRM_SalesOrderGenerator.RT_Paused
        };
    }
    
    public ASI_HK_CRM_Sales_Order__c generateBasicSalesOrder(Account pAcct, Account dAcct) {
        return new ASI_HK_CRM_Sales_Order__c(
            ASI_HK_CRM_Account_PA__c = pAcct.Id
            , ASI_HK_CRM_Customer_DA__c = dAcct.Id
            , ASI_HK_CRM_Order_Date__c = DEF_VALUE_ORDER_DATE
            , ASI_HK_CRM_Payment_Method__c = DEF_VALUE_PAYMENT_METHOD
        );
    }   

    public ASI_HK_CRM_Sales_Order__c generateSalesOrder(Account pAcct, Account dAcct, ID rtID) {
        ASI_HK_CRM_Sales_Order__c result = generateBasicSalesOrder(pAcct, dAcct);
        result.RecordTypeId = rtID;
        result.ASI_HK_CRM_Order_Type__c='Sales Order - HK';
        return result;
    }

    public ASI_HK_CRM_Sales_Order__c generateSalesOrder(Account pAcct, Account dAcct, String rtDevName) {
        return generateSalesOrder(pAcct, dAcct, getRecordTypeByDevName(rtDevName).Id);
    }

    
    
    // Jeffrey add for only DA test - start
    public ASI_HK_CRM_Sales_Order__c generateDASalesOrder(Account dAcct) {
        return new ASI_HK_CRM_Sales_Order__c(
            ASI_HK_CRM_Customer_DA__c = dAcct.Id
            , ASI_HK_CRM_Order_Date__c = DEF_VALUE_ORDER_DATE
            , ASI_HK_CRM_Payment_Method__c = DEF_VALUE_PAYMENT_METHOD
        );
    }
    public ASI_HK_CRM_Sales_Order__c generateOnlyDASalesOrder(Account dAcct, ID rtID) {
        ASI_HK_CRM_Sales_Order__c result = generateDASalesOrder(dAcct);
        result.RecordTypeId = rtID;
        result.ASI_HK_CRM_Order_Type__c='Sales Order - HK';
        result.ASI_HK_CRM_Delivery_Date__c = System.today().addDays(2);
        return result;
    }
    
    public ASI_HK_CRM_Sales_Order__c generateOnlyDASalesOrder(Account dAcct, String rtDevName) {
        return generateOnlyDASalesOrder(dAcct, getRecordTypeByDevName(rtDevName).Id);
    }


}
    // Jeffrey add for only DA test - end