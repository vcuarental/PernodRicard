/*********************************************************************************
 * Name: ASI_CRM_JP_SORedirect_Controller
 * Description: Controller class for JP Sales Order Redirect Page
 * Test Class: ASI_CRM_JP_SORedirect_CtrlTest
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 27/03/2017       Hugo Cheung             Created          
 * 17/03/2020       Wilken Lee              [WL 1.0] Add try-catch exception handling for Sales Order insert
 * 27/03/2020       Wilken Lee              [WL 2.0] Insert Marketing FOC with normal record type (instead of Inactive) to avoid user did not click Cancel button and skipped creation
*/
public class ASI_CRM_JP_SORedirect_Controller {
    
    //Field Map
    private final static Map<String, Schema.SObjectField> SALES_ORDER_FIELD_MAP     = Schema.SObjectType.ASI_CRM_JP_Sales_Order__c.fields.getMap();
    private final static Map<String, Schema.SObjectField> BILL_TO_FIELD_MAP         = Schema.SObjectType.ASI_CRM_Bill_To__c.fields.getMap();
    private final static Map<String, Schema.SObjectField> ADVANCED_SEARCH_FIELD_MAP = Schema.SObjectType.ASI_CRM_JP_Advanced_Search__c.fields.getMap();
    private final static Map<String, Schema.SObjectField> CUSTOMER_FIELD_MAP        = Schema.SObjectType.ASI_CRM_AccountsAdditionalField__c.fields.getMap();
    
    //Parameter Name
    private final static String SALES_ORDER_ID  = 'salesOrderId';
    private final static String RECORD_TYPE_KEY = 'RecordType';
    private final static String SHIP_TO_KEY     = 'ASI_CRM_Ship_To__c';
    private final static String SOLD_TO_KEY     = 'ASI_CRM_Sold_To__c';
    private final static String TEMPLATE_ID     = 'templateId';
    
    //Default Value 
    private final static String EMPLOYEE_SO_SHIP_TO_CODE      = '99032001';
    private final static String ENTERTAINMENT_SO_SOLD_TO_CODE = '99999999';
    private final static String OFF_TRADE_OUTLET_RECORD_TYPE  = 'ASI_CRM_JP_Off_Trade_Outlet';
    
    //Object API Name
    private final static String SALES_ORDER_API_NAME = 'ASI_CRM_JP_Sales_Order__c';
    
    //Record Type API Name
    private final static String DIRECT_SALES_RECORD_TYPE        = 'ASI_CRM_JP_Direct_Sales';
    private final static String DUTY_FREE_SO_RECORD_TYPE        = 'ASI_CRM_JP_Duty_Free_SO';
    private final static String EMPLOYEE_SALES_RECORD_TYPE      = 'ASI_CRM_JP_Employee_Sales';
    private final static String ENTERTAINMENT_SALES_RECORD_TYPE = 'ASI_CRM_JP_Entertainment_Sales';
    private final static String MARKETING_FOC_RECORD_TYPE       = 'ASI_CRM_JP_Marketing_FOC';
    private final static String NORMLA_SO_RECORD_TYPE           = 'ASI_CRM_JP_Normal_SO';
    private final static String SAMPLE_SALES_RECORD_TYPE        = 'ASI_CRM_JP_Sample_Sales';
    private final static String INACTIVE_SO_RECORD_TYPE         = 'ASI_CRM_JP_Inactive_Sales_Order';
    
    //Record Type Order Type Map
    private final static Map<String, String> recordTypeOrderTypeMap = new Map<String, String> {
        SAMPLE_SALES_RECORD_TYPE        => 'Sample SO',
        ENTERTAINMENT_SALES_RECORD_TYPE => 'Entertainment Sales',
        EMPLOYEE_SALES_RECORD_TYPE      => 'Employee SO',
        MARKETING_FOC_RECORD_TYPE       => 'Marketing FOC',
        DIRECT_SALES_RECORD_TYPE        => 'Direct Sales SO',
        DUTY_FREE_SO_RECORD_TYPE        => 'Normal SO'
    };
    
    public ASI_CRM_JP_SORedirect_Controller() {
    }
    
    public PageReference redirectPage() {
        //Retrieve data from Parameters
        Map<String, String> params = ApexPages.currentPage().getParameters();
        
        if(params.containsKey(SALES_ORDER_ID)) {
            return deleteSalesOrder(params.get(SALES_ORDER_ID), params.get(RECORD_TYPE_KEY));
        } else {
            return createSalesOrder(params);
        }
        
    }
@TestVisible
    private PageReference deleteSalesOrder(String salesOrderId, String recordType) {
        ASI_CRM_JP_Sales_Order__c salesOrder = retrieveSalesOrder(salesOrderId);

        String returnCustomerId = '';
        if(recordType == MARKETING_FOC_RECORD_TYPE ||
           recordType == SAMPLE_SALES_RECORD_TYPE) {
            returnCustomerId = salesOrder.ASI_CRM_Ship_To__c;
        } else {
            returnCustomerId = salesOrder.ASI_CRM_Sold_To__c;
        }

        delete salesOrder;

        PageReference pageRef = new PageReference('/' + returnCustomerId);
        pageRef.setRedirect(true);
        return pageRef;
    }
    
@TestVisible
    private PageReference createSalesOrder(Map<String, String> params) {
        String recordType   = params.get(RECORD_TYPE_KEY);
        String shipToId     = params.get(SHIP_TO_KEY);
        String soldToId     = params.get(SOLD_TO_KEY);
        String templateId   = params.get(TEMPLATE_ID);
        
        ASI_CRM_JP_Sales_Order__c salesOrder;
        
       /* if(Test.isRunningTest()){
            salesOrder.ASI_CRM_Ship_To__r.ASI_CRM_CN_Inactive_Flag__c = true;
            salesOrder.ASI_CRM_Salesman__r.UserRole.Name = 'JP Accounting Manager';
            
        } */
        
        if(String.isBlank(templateId)) {
            salesOrder = createSalesOrder(recordType, shipToId, soldToId);
        } else {
            salesOrder = createSalesOrder(templateId);
        }
        
        if(recordType == NORMLA_SO_RECORD_TYPE) {
            salesOrder.ASI_CRM_Order_Type__c = 'Normal Sales SO';
            salesOrder.ASI_CRM_AP_Code__c = 'SSSS';
        }
        
        if(recordType == DUTY_FREE_SO_RECORD_TYPE) {
            salesOrder.ASI_CRM_Order_Type__c = 'Normal SO';
        }
        
        salesOrder = assignSalesman(salesOrder);
        
        /*[WL 1.0] BEGIN*/
        try {
            /*[WL 2.0] BEGIN*/
            if(recordType == MARKETING_FOC_RECORD_TYPE) {
                Id recordTypeId  = Global_RecordTypeCache.getRtId('ASI_CRM_JP_Sales_Order__c' + recordType);
                
                salesOrder.recordTypeId = recordTypeId;
                insert salesOrder;
                
                PageReference pageRef = new PageReference('/' + salesOrder.Id + '/e?retURL=' + salesOrder.Id);
                pageRef.setRedirect(true);
                return pageRef;
            }
            else {
                insert salesOrder;
        
                Id recordTypeId  = Global_RecordTypeCache.getRtId('ASI_CRM_JP_Sales_Order__c' + recordType);
                //String cancelURL = soldToId;
                String cancelURL = EncodingUtil.urlEncode('/apex/ASI_CRM_JP_SORedirect_Page?salesOrderId=' + salesOrder.Id + '&RecordType=' + recordType, 'UTF-8');
                String saveURL   = salesOrder.Id;
                
                PageReference pageRef = new PageReference('/' + salesOrder.Id + '/e?RecordType=' + recordTypeId + '&cancelURL=' + cancelURL + '&saveURL=' + saveURL);
                pageRef.setRedirect(true);
            
                return pageRef;
            }
            /*[WL 2.0] END*/
            
        } 
        catch(DmlException e) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,e.getMessage())); //WL 1.0
            return null; //WL 1.0
        }        
        /*[WL 1.0] BEGIN*/
    }
@TestVisible
    private ASI_CRM_JP_Sales_Order__c createSalesOrder(String templateId) {
        ASI_CRM_JP_Advanced_Search__c advancedSearch = retrieveAdvancedSearch(templateId);
        
        ASI_CRM_JP_Sales_Order__c salesOrder = new ASI_CRM_JP_Sales_Order__c();
        
        salesOrder.Name = '[Auto Number]';
        salesOrder.RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_JP_Sales_Order__c' + INACTIVE_SO_RECORD_TYPE);
        
        salesOrder.ASI_CRM_Ship_To__c                 = advancedSearch.ASI_Ship_To_Customer__c;
        salesOrder.ASI_CRM_Sold_To__c                 = advancedSearch.ASI_Sold_To_Customer__c;
        salesOrder.ASI_CRM_Sub_Wholesaler__c          = advancedSearch.ASI_Sub_Wholesaler__c;
        salesOrder.ASI_CRM_Order_Date__c              = advancedSearch.ASI_Transaction_Date__c;
        salesOrder.ASI_CRM_Branch_Plant__c            = advancedSearch.ASI_Business_Unit__c;
        salesOrder.ASI_CRM_Freight_Code__c            = advancedSearch.ASI_Freight_Code__c;
        salesOrder.ASI_CRM_Reason_Code__c             = advancedSearch.ASI_Reason_Code__c;
        salesOrder.ASI_CRM_Route_Code__c              = Decimal.valueOf(advancedSearch.ASI_Route_Code__c == null ? '0' : advancedSearch.ASI_Route_Code__c);
        salesOrder.ASI_CRM_Salesman_Code__c           = advancedSearch.ASI_Ship_To_Customer_Salesman_Code__c;
        salesOrder.ASI_CRM_Tax_Area__c                = advancedSearch.ASI_Tax_Area__c;
        salesOrder.ASI_CRM_Tax_Code__c                = advancedSearch.ASI_Tax_Code__c;
        
        salesOrder.ASI_CRM_Order_Date__c     = Date.today();
        salesOrder.ASI_CRM_Requested_Date__c = Date.today().addDays(1);
        
        return salesOrder;
    }
    
    private ASI_CRM_JP_Sales_Order__c createSalesOrder(String recordType, String shipToId, String soldToId) {
        //Get Ship To And Sold To Customer
        Set<Id> customerIdSet = new Set<Id>();
        if(String.isNotBlank(shipToId)) {
            customerIdSet.add(shipToId);
        }
        
        if(String.isNotBlank(soldToId)) {
            customerIdSet.add(soldToId);
        }
        
        Set<String> customerCodeSet = new Set<String>();
        customerCodeSet.add(EMPLOYEE_SO_SHIP_TO_CODE);
        customerCodeSet.add(ENTERTAINMENT_SO_SOLD_TO_CODE);
        
        Map<Id, ASI_CRM_AccountsAdditionalField__c> customerMap = new Map<Id, ASI_CRM_AccountsAdditionalField__c>(retrieveCustomerList(customerIdSet));
        Map<String, ASI_CRM_AccountsAdditionalField__c> customerCodeMap = new Map<String, ASI_CRM_AccountsAdditionalField__c>(retrieveCustomerFromCode(customerCodeSet));
        
        ASI_CRM_AccountsAdditionalField__c shipToCustomer;
        ASI_CRM_AccountsAdditionalField__c soldToCustomer;
        
        if(recordType == EMPLOYEE_SALES_RECORD_TYPE) {
            shipToCustomer = customerCodeMap.get(EMPLOYEE_SO_SHIP_TO_CODE);
            soldToCustomer = customerMap.get(soldToId);
        } else if(recordType == ENTERTAINMENT_SALES_RECORD_TYPE ||
                  recordType == MARKETING_FOC_RECORD_TYPE || 
                  recordType == SAMPLE_SALES_RECORD_TYPE) {
            shipToCustomer = customerMap.get(shipToId);
            soldToCustomer = customerCodeMap.get(ENTERTAINMENT_SO_SOLD_TO_CODE);
        } else {
            shipToCustomer = String.isNotBlank(shipToId) ? customerMap.get(shipToId) : null;
            soldToCustomer = String.isNotBlank(soldToId) ? customerMap.get(soldToId) : null;
        } 
        
        //Create Sales Order
        ASI_CRM_JP_Sales_Order__c salesOrder = new ASI_CRM_JP_Sales_Order__c();
        if(shipToCustomer != null) {
            salesOrder.ASI_CRM_Ship_To__c                = shipToCustomer.id;
            salesOrder.ASI_CRM_Branch_Plant__c           = shipToCustomer.ASI_CRM_SG_Business_Unit__c;
            salesOrder.ASI_CRM_Freight_Code__c           = String.valueOf(shipToCustomer.ASI_CRM_Shipping_Calendar__c);
            salesOrder.ASI_CRM_Route_Code__c             = shipToCustomer.ASI_CRM_Shipping_Lead_Time__c;
            
            if(recordType == DIRECT_SALES_RECORD_TYPE) {
                User owner = retrieveUser(UserInfo.getUserId());
                salesOrder.ASI_CRM_Salesman__c = owner.Id;
                salesOrder.ASI_CRM_Salesman_Code__c = owner.ASI_TnE_Sub_Ledger__c;
                salesOrder.ASI_CRM_JP_Sales_Group__c = owner.ASI_KOR_User_Branch_Code__c; 
            }
        }
        
        if(soldToCustomer != null) {
            salesOrder.ASI_CRM_Sold_To__c  = soldToCustomer.id;
            salesOrder.ASI_CRM_Tax_Area__c = soldToCustomer.ASI_CRM_SG_Tax_Rate_Area__c;
            salesOrder.ASI_CRM_Tax_Code__c = soldToCustomer.ASI_CRM_SG_Tax_Expl_Code__c;
            salesOrder.ASI_CRM_Payment_Option__c = soldToCustomer.ASI_HK_CRM_Payment_Method__c;
            salesOrder.ASI_CRM_Payment_Term__c = soldToCustomer.ASI_CRM_Dependent_Payment_Terms__c;
            
            if(recordType == EMPLOYEE_SALES_RECORD_TYPE) {
                salesOrder.ASI_CRM_AP_Code__c = soldToCustomer.ASI_CRM_JP_AP_Code__c;
            }
        }
         
       // if(recordType == EMPLOYEE_SALES_RECORD_TYPE) {
            //salesOrder.ASI_CRM_Salesman_Code__c = '9999';
            //salesOrder.ASI_CRM_AP_Code__c = 'SSSS';
      //  }
        
        if(recordType == DIRECT_SALES_RECORD_TYPE) {
            salesOrder.ASI_CRM_AP_Code__c = 'SSSS';
            
            ASI_CRM_Bill_To__c billTo = retrievePrimaryBillTo(soldToId);
            ASI_CRM_Pay_To__c payTo   = retrievePrimaryPayTo();
            
            if(billTo != null) {
                salesOrder.ASI_CRM_JP_Bill_To__c = billTo.Id;
            }
            if(payTo != null) {
                salesOrder.ASI_CRM_Bank_Account__c = payTo.Id;
            }
            
            if(soldToCustomer.ASI_CRM_CN_JDE_Code__c == '49999999') {
                salesOrder.ASI_CRM_Payment_Option__c = 'Advanced Payment';
            } else if(soldToCustomer.ASI_CRM_CN_JDE_Code__c == '49999998') {
                salesOrder.ASI_CRM_Payment_Option__c = 'COD';
                salesOrder.ASI_CRM_JP_Taxable_Service_Charge__c = '1000';
            }
        }
        
        if(recordTypeOrderTypeMap.containsKey(recordType)) {
            salesOrder.ASI_CRM_Order_Type__c = recordTypeOrderTypeMap.get(recordType);
        }
        
        if(recordType == MARKETING_FOC_RECORD_TYPE) {
            User owner = retrieveUser(UserInfo.getUserId());
            if(owner.ASI_Department__c != 'Marketing') {
                salesOrder.ASI_CRM_Order_Type__c = 'Marketing FOC - Sales';
            }
        }
        
        salesOrder.ASI_CRM_Order_Date__c     = Date.today();
        salesOrder.ASI_CRM_Requested_Date__c = Date.today().addDays(1);
        
        salesOrder.Name = '[Auto Number]';
        salesOrder.RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_JP_Sales_Order__c' + INACTIVE_SO_RECORD_TYPE);
        
        return salesOrder;
    }
 @TestVisible   
    private ASI_CRM_JP_Sales_Order__c assignSalesGroup(ASI_CRM_JP_Sales_Order__c salesOrder) {
        User u = retrieveUser(UserInfo.getUserId());
        salesOrder.ASI_CRM_JP_Sales_Group__c = u.ASI_KOR_User_Branch_Code__c;
        return salesOrder;
    }
    
    private ASI_CRM_JP_Sales_Order__c assignSalesman(ASI_CRM_JP_Sales_Order__c salesOrder) {
        if(String.isBlank(salesOrder.ASI_CRM_Salesman_Code__c)) {
            return salesOrder;
        }
        system.debug('salesOrder.ASI_CRM_Salesman_Code__c'+salesOrder.ASI_CRM_Salesman_Code__c);
        User salesman = retrieveUserBySalesmanCode(salesOrder.ASI_CRM_Salesman_Code__c);
        if(salesman == null) {
            return salesOrder;
        }
        
        salesOrder.ASI_CRM_Salesman__c = salesman.Id;
        salesOrder.ASI_CRM_JP_Sales_Group__c = salesman.ASI_KOR_User_Branch_Code__c;
        return salesOrder;
    }
    
    /***************
    Data Retrievement Function
    ***************/
    private ASI_CRM_JP_Sales_Order__c retrieveSalesOrder(Id salesOrderId) {
        String query = 'SELECT ' + genQueryField(SALES_ORDER_FIELD_MAP) + 
                       ', RecordType.DeveloperName ' + 
                       'FROM ASI_CRM_JP_Sales_Order__c ' + 
                       'WHERE Id = :salesOrderId';
        List<ASI_CRM_JP_Sales_Order__c> salesOrderList = (List<ASI_CRM_JP_Sales_Order__c>) Database.query(query);
        return salesOrderList.size() > 0 ? salesOrderList.get(0) : null;
    }

    private List<ASI_CRM_AccountsAdditionalField__c> retrieveCustomerList(Set<Id> customerIdSet) {
        String query = 'SELECT ' + genQueryField(CUSTOMER_FIELD_MAP) + 
                       ', RecordType.DeveloperName ' + 
                       'FROM ASI_CRM_AccountsAdditionalField__c ' + 
                       'Where Id in :customerIdSet';
        return (List<ASI_CRM_AccountsAdditionalField__c>) Database.query(query);
    }
    
    private Map<String, ASI_CRM_AccountsAdditionalField__c> retrieveCustomerFromCode(Set<String> customerCodeSet) {
        String query = 'SELECT ' + genQueryField(CUSTOMER_FIELD_MAP) + 
                       ', RecordType.DeveloperName ' + 
                       'FROM ASI_CRM_AccountsAdditionalField__c ' + 
                       'Where ASI_CRM_CN_JDE_Code__c in :customerCodeSet ' + 
                       'AND RecordType.DeveloperName = :OFF_TRADE_OUTLET_RECORD_TYPE ';
        List<ASI_CRM_AccountsAdditionalField__c> customerList = (List<ASI_CRM_AccountsAdditionalField__c>) Database.query(query);
        Map<String, ASI_CRM_AccountsAdditionalField__c> customerCodeMap = new Map<String, ASI_CRM_AccountsAdditionalField__c>();
        for(ASI_CRM_AccountsAdditionalField__c customer : customerList) {
            if(customer.RecordType.DeveloperName.contains('ASI_CRM_JP')) {
                customerCodeMap.put(customer.ASI_CRM_CN_JDE_Code__c, customer);
            }
        }
        return customerCodeMap;
    }
 @TestVisible 
    private ASI_CRM_Bill_To__c retrievePrimaryBillTo(Id customerId) {
        String query = 'SELECT ' + genQueryField(BILL_TO_FIELD_MAP) + 
                       ', ASI_CRM_Bank_Account__r.Name ' + 
                       'FROM ASI_CRM_Bill_To__c ' + 
                       'WHERE ASI_CRM_Customer__c = :customerId ' + 
                       'AND ASI_CRM_Primary__c = true ' + 
                       'AND ASI_CRM_JP_Active__c = true ';
        List<ASI_CRM_Bill_To__c> billToList = (List<ASI_CRM_Bill_To__c>) Database.query(query);
        return billToList.size() > 0 ? billToList.get(0) : null;
    }
  @TestVisible    
    private ASI_CRM_Pay_To__c retrievePrimaryPayTo() {
        String query = 'SELECT Id, Name ' + 
                       'FROM ASI_CRM_Pay_To__c ' + 
                       'WHERE ASI_CRM_JP_PRJ_Bank_Account__c = true';
        List<ASI_CRM_Pay_To__c> payToList = (List<ASI_CRM_Pay_To__c>) Database.query(query);
        return payToList.size() > 0 ? payToList.get(0) : null;
    }
    
    private ASI_CRM_JP_Advanced_Search__c retrieveAdvancedSearch(Id advancedSearchId) {
        String query = 'SELECT ' + genQueryField(ADVANCED_SEARCH_FIELD_MAP) + 
                       ', RecordType.DeveloperName, ASI_Ship_To_Customer__r.Name, ASI_Ship_To_Customer__r.ASI_CRM_CustomerCode__c' + 
                       ', ASI_Ship_To_Customer__r.ASI_CRM_CN_Phone_Number__c, ASI_Ship_To_Customer__r.ASI_CRM_CN_Address__c' +
                       ', ASI_Sold_To_Customer__r.ASI_CRM_CN_Phone_Number__c, ASI_Sold_To_Customer__r.ASI_CRM_CN_Address__c' +
                       ', ASI_Sold_To_Customer__r.Name, ASI_Sub_Wholesaler__r.Name ' + 
                       'FROM ASI_CRM_JP_Advanced_Search__c ' + 
                       'WHERE Id = :advancedSearchId';
        List<ASI_CRM_JP_Advanced_Search__c> advancedSearchList = (List<ASI_CRM_JP_Advanced_Search__c>) Database.query(query);
        return advancedSearchList.size() > 0 ? advancedSearchList.get(0) : null;
    }
    
    private User retrieveUser(Id userId) {
        String query = 'SELECT Id, Department, ASI_Department__c, ASI_TnE_Sub_Ledger__c, ASI_KOR_User_Branch_Code__c ' + 
                       'FROM User ' + 
                       'WHERE Id = :userId';
        List<User> userList = (List<User>) Database.query(query);
        return userList.size() == 0 ? null : userList.get(0);
    }
    
    private User retrieveUserBySalesmanCode(String salesmanCode) {
        String query = 'SELECT Id, Department, ASI_Department__c, ASI_TnE_Sub_Ledger__c, ASI_KOR_User_Branch_Code__c ' + 
                       'FROM User ' + 
                       'WHERE ASI_TnE_Sub_Ledger__c = :salesmanCode ' + 
                       'AND UserRole.Name LIKE \'JP%\'';
        List<User> userList = (List<User>) Database.query(query);
        return userList.size() == 0 ? null : userList.get(0);
    }
    
    /***************
    Tools Function
    ***************/
    private String genQueryField(Map<String, Schema.SObjectField> fieldMap) {
        String queryField = '';
        for(String fields : fieldMap.keySet()) {
          queryField += fields + ',';
        }
        return queryField.subString(0, queryField.length() - 1);
    }
}