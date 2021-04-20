/*********************************************************************************
 * Name: ASI_CRM_JP_ModifySO_Controller
 * Description: Controller class for so modification page (Code need to be improved in future)
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 15/02/2017       Hugo Cheung             Created          
*/
public class ASI_CRM_JP_ModifySO_Controller {

    //Inner class for displaying record in VF Page
    private class SalesOrderWrapper {
      private final String NORMAL_SO_RECORD_TYPE_ID = Global_RecordTypeCache.getRtId('ASI_CRM_JP_Sales_Order__c' + 'ASI_CRM_JP_Normal_SO');
        
      private ASI_CRM_JP_Sales_Order__c salesOrder {get; set;}
        private String shipToPhone {get; set;}
    private String shipToAddr  {get; set;}
        private String soldToPhone {get; set;}
        private String soldToAddr  {get; set;}
        
        private SalesOrderWrapper(ASI_CRM_JP_Sales_Order__c salesOrder) {
          this.salesOrder = salesOrder;
        }
        
       private void assignShipTo(ASI_CRM_AccountsAdditionalField__c shipTo, User salesman) {
            shipToPhone = shipTo.ASI_CRM_CN_Phone_Number__c;
            shipToAddr  = shipTo.ASI_CRM_CN_Address__c;
            
            salesOrder.ASI_CRM_Ship_To__c  = shipTo.id;
            salesOrder.ASI_CRM_Ship_To__r  = shipTo;
             if(salesman != null) {
              salesOrder.ASI_CRM_Salesman__c = salesman.id;
              salesOrder.ASI_CRM_Salesman__r = salesman;
                salesOrder.ASI_CRM_JP_Sales_Group__c = salesman.ASI_KOR_User_Branch_Code__c;
            } else {
              salesOrder.ASI_CRM_Salesman__c = null;
                salesOrder.ASI_CRM_Salesman__r = null;
                salesOrder.ASI_CRM_JP_Sales_Group__c = null;
            }
             
            salesOrder.ASI_CRM_Branch_Plant__c  = shipTo.ASI_CRM_SG_Business_Unit__c;
            salesOrder.ASI_CRM_Freight_Code__c  = shipTo.ASI_CRM_Shipping_Calendar__c;
            salesOrder.ASI_CRM_Route_Code__c    = shipTo.ASI_CRM_Shipping_Lead_Time__c;
            salesOrder.ASI_CRM_Salesman_Code__c = shipTo.ASI_CRM_KR_Salesman__c;
        }
        
        private void assignSoldTo(ASI_CRM_AccountsAdditionalField__c soldTo) {
            soldToPhone = soldTo.ASI_CRM_CN_Phone_Number__c;
            soldToAddr  = soldTo.ASI_CRM_CN_Address__c;
            
            salesOrder.ASI_CRM_Sold_To__c = soldTo.id;
            salesOrder.ASI_CRM_Sold_To__r = soldTo;
      salesOrder.ASI_CRM_Tax_Area__c = soldTo.ASI_CRM_SG_Tax_Rate_Area__c;
            salesOrder.ASI_CRM_Tax_Code__c = soldTo.ASI_CRM_SG_Tax_Expl_Code__c;
        }
        
        private void assignOwner(User u) {
          salesOrder.ASI_CRM_JP_Sales_Group__c = u.ASI_KOR_User_Branch_Code__c;
        }
    }
    
    //Field Map
  private final static Map<String, Schema.SObjectField> CUSTOMER_FIELD_MAP = Schema.SObjectType.ASI_CRM_AccountsAdditionalField__c.fields.getMap();
    
    //Object Prefix
  private final static String SALES_ORDER_OBJECT_PREFIX = ASI_CRM_JP_Sales_Order__c.sObjectType.getDescribe().getKeyPrefix();
    
    //Parameter from VF Page Name
    private final static String RECORD_TYPE      = 'recordType';
  private final static String SALES_ORDER_JSON = 'salesOrderJson';
    private final static String CUSTOMER_ID      = 'customerId';

    //Picklist
    private Map<String, String> branchPlantValueMap     {get; set;}
  private Map<String, String> deliveryTimeValueMap    {get; set;}
  private Map<String, String> taxAreaValueMap         {get; set;}
  private Map<String, String> taxCodeValueMap         {get; set;}
  private Map<String, String> reasonCodeValueMap      {get; set;}
  private Map<String, String> businessReasonValueMap  {get; set;}
  private Map<String, String> orderTypeValueMap       {get; set;}
  private Map<String, String> apCodeValueMap          {get; set;}
    private Map<String, String> freightCodeValueMap     {get; set;} 
    
    private Map<String, Id> fieldIdMap {get; set;}
    
  //Sales Order Record
  private SalesOrderWrapper salesOrderWrapper {get; set;} 
    
    public String salesOrderRecordTypeAPIName {get; set;}
    
    //Exception
    public String exceptionMsg {get; set;}
    
  //JSON String for VF Page
  public String salesOrderWrapperJson       {get {return toJsonString(salesOrderWrapper);}}
    public String fieldIdMapJson              {get {return toJsonString(fieldIdMap);}}
    
    //Picklist JSON
    public String branchPlantValueListJson    {get {return toJsonString(branchPlantValueMap);}}
  public String deliveryTimeValueListJson   {get {return toJsonString(deliveryTimeValueMap);}}
  public String taxAreaValueListJson        {get {return toJsonString(taxAreaValueMap);}}
  public String taxCodeValueListJson        {get {return toJsonString(taxCodeValueMap);}}
  public String reasonCodeValueListJson     {get {return toJsonString(reasonCodeValueMap);}}
  public String businessReasonValueListJson {get {return toJsonString(businessReasonValueMap);}}
  public String orderTypeValueListJson      {get {return toJsonString(orderTypeValueMap);}}
  public String apCodeValueListJson         {get {return toJsonString(apCodeValueMap);}}
    public String freightCodeValueMapJson     {get {return toJsonString(freightCodeValueMap);}}
    
    public ASI_CRM_JP_ModifySO_Controller(ApexPages.StandardController controller) {
        Map<String, String> params = ApexPages.currentPage().getParameters();
        
        salesOrderRecordTypeAPIName = params.get(RECORD_TYPE);
        
        ASI_CRM_JP_Sales_Order__c salesOrder = new ASI_CRM_JP_Sales_Order__c();
        salesOrder.ASI_CRM_Order_Date__c     = Date.today();
        salesOrder.ASI_CRM_Requested_Date__c = Date.today().addDays(1);
        salesOrder.ASI_CRM_JP_Price_Effective_Date__c = Date.today();
        salesOrder.RecordTypeId              = Global_RecordTypeCache.getRtId('ASI_CRM_JP_Sales_Order__c' + params.get(RECORD_TYPE));
        if(params.get(RECORD_TYPE) == 'ASI_CRM_JP_Normal_SO') {
          salesOrder.ASI_CRM_Order_Type__c = 'Normal Sales SO';
            salesOrder.ASI_CRM_AP_Code__c = 'SSSS';
        }
        
        if(params.get(RECORD_TYPE) == 'ASI_CRM_JP_Duty_Free_SO') {
          salesOrder.ASI_CRM_Order_Type__c = 'Normal SO';
        }
        
      salesOrderWrapper = new SalesOrderWrapper(salesOrder);
        
        if(params.containsKey('ASI_CRM_Ship_To__c')) {
          salesOrder.ASI_CRM_Ship_To__c = params.get('ASI_CRM_Ship_To__c');
            ASI_CRM_AccountsAdditionalField__c shipTo = retrieveCustomer(params.get('ASI_CRM_Ship_To__c'));
            User salesman = retrieveUserBySalesmanCode(shipTo.ASI_CRM_KR_Salesman__c);
          salesOrderWrapper.assignShipTo(shipTo, salesman);
        }
        
        fieldIdMap = retrieveFieldId();
        
        initPicklistValue();
    }
    
    private void initPicklistValue() {
      branchPlantValueMap    = retrievePicklistValues(ASI_CRM_JP_Sales_Order__c.ASI_CRM_Branch_Plant__c.getDescribe());
    deliveryTimeValueMap   = retrievePicklistValues(ASI_CRM_JP_Sales_Order__c.ASI_CRM_Delivery_Time__c.getDescribe());
    taxAreaValueMap        = retrievePicklistValues(ASI_CRM_JP_Sales_Order__c.ASI_CRM_Tax_Area__c.getDescribe());
    taxCodeValueMap        = retrievePicklistValues(ASI_CRM_JP_Sales_Order__c.ASI_CRM_Tax_Code__c.getDescribe());
    reasonCodeValueMap     = retrievePicklistValues(ASI_CRM_JP_Sales_Order__c.ASI_CRM_Reason_Code__c.getDescribe());
    businessReasonValueMap = retrievePicklistValues(ASI_CRM_JP_Sales_Order__c.ASI_CRM_Business_Reason__c.getDescribe());
    orderTypeValueMap      = retrievePicklistValues(ASI_CRM_JP_Sales_Order__c.ASI_CRM_Order_Type__c.getDescribe());
    apCodeValueMap         = retrievePicklistValues(ASI_CRM_JP_Sales_Order__c.ASI_CRM_AP_Code__c.getDescribe());
        freightCodeValueMap    = retrievePicklistValues(ASI_CRM_JP_Sales_Order__c.ASI_CRM_Freight_Code__c.getDescribe());
    }
    
    /***************
  View Action Handler
  ***************/
    public PageReference save() {
        exceptionMsg = '';
        
      Map<String, String> params   = ApexPages.currentPage().getParameters();
      String salesOrderWrapperJson = params.get(SALES_ORDER_JSON);
        
        try {
            //Convert Json String to Sales Order Record
            salesOrderWrapper.salesOrder = (ASI_CRM_JP_Sales_Order__c) fromJsonString(salesOrderWrapperJson, ASI_CRM_JP_Sales_Order__c.class);
            insert salesOrderWrapper.salesOrder;
        } catch(Exception e) {
            if(e.getTypeName() == 'System.DmlException') {
                DmlException dmlException = (DmlException) e;
              exceptionMsg = dmlException.getDmlMessage(0);
            } else {
              exceptionMsg = e.getMessage();
            }
            return null;
        }
       
        PageReference pageRef = new PageReference('/' + salesOrderWrapper.salesOrder.Id);
      pageRef.setRedirect(true);
      return pageRef;
    }
    
    public PageReference cancel() {
    PageReference pageRef;
    pageRef = new PageReference('/' + SALES_ORDER_OBJECT_PREFIX + '/o');
      pageRef.setRedirect(true);
      return pageRef;
    }
    
    public void assignShipToDefaultValue() {
        ASI_CRM_AccountsAdditionalField__c customer = retrieveCustomerFromParameter();
        User salesman = retrieveUserBySalesmanCode(customer.ASI_CRM_KR_Salesman__c);
        salesOrderWrapper.assignShipTo(customer, salesman);
        if(String.isNotBlank(salesOrderWrapper.salesOrder.ASI_CRM_Sold_To__c)) {
            ASI_CRM_AccountsAdditionalField__c soldToCustomer = retrieveCustomer(salesOrderWrapper.salesOrder.ASI_CRM_Sold_To__c);
            salesOrderWrapper.assignSoldTo(soldToCustomer);
        }
    }
    
    public void assignSoldToDefaultValue() {
        ASI_CRM_AccountsAdditionalField__c customer = retrieveCustomerFromParameter();
        salesOrderWrapper.assignSoldTo(customer);
        if(String.isNotBlank(salesOrderWrapper.salesOrder.ASI_CRM_Ship_To__c)) {
            ASI_CRM_AccountsAdditionalField__c shipToCustomer = retrieveCustomer(salesOrderWrapper.salesOrder.ASI_CRM_Ship_To__c);
          User salesman = retrieveUserBySalesmanCode(shipToCustomer.ASI_CRM_KR_Salesman__c);
            salesOrderWrapper.assignShipTo(shipToCustomer, salesman);
        }
    }
    
    private ASI_CRM_AccountsAdditionalField__c retrieveCustomerFromParameter() {
      //Retrieve data from Parameters
      Map<String, String> params = ApexPages.currentPage().getParameters();
        salesOrderWrapper.salesOrder = (ASI_CRM_JP_Sales_Order__c) fromJsonString(params.get(SALES_ORDER_JSON), ASI_CRM_JP_Sales_Order__c.class);
        return retrieveCustomer(params.get(CUSTOMER_ID));
    }
    
    /***************
  Data Retrievement Function
  ***************/
    private ASI_CRM_AccountsAdditionalField__c retrieveCustomer(Id customerId) {
    String query = 'SELECT ' + genQueryField(CUSTOMER_FIELD_MAP) + 
                       ', RecordType.DeveloperName ' + 
                       'FROM ASI_CRM_AccountsAdditionalField__c ' + 
                       'Where Id = :customerId';
    List<ASI_CRM_AccountsAdditionalField__c> customerList = (List<ASI_CRM_AccountsAdditionalField__c>) Database.query(query);
    return customerList.size() > 0 ? customerList.get(0) : null;
  }
    
    private User retrieveUser(Id userId) {
        String query = 'SELECT Id, ASI_KOR_User_Branch_Code__c ' + 
                       'FROM User ' + 
                       'WHERE Id = :userId';
        List<User> userList = (List<User>) Database.query(query);
        return userList.size() == 0 ? null : userList.get(0);
    }
    
    private User retrieveUserBySalesmanCode(String salesmanCode) {
      String query = 'SELECT Id, Name, Department, ASI_KOR_User_Branch_Code__c ' + 
                       'FROM User ' + 
                       'WHERE ASI_TnE_Sub_Ledger__c = :salesmanCode ' + 
                       'AND UserRole.Name LIKE \'JP%\'';
        List<User> userList = (List<User>) Database.query(query);
        return userList.size() == 0 ? null : userList.get(0);
    }
    
    private Map<String, String> retrievePicklistValues(Schema.DescribeFieldResult fieldResult) {
      Map<String, String> picklistValueMap = new Map<String, String>();

      List<Schema.PicklistEntry> picklistEntryList = fieldResult.getPicklistValues();
        for(Integer i = picklistEntryList.size() - 1; i >= 0 ; i --) {
          Schema.PicklistEntry picklistEntry = picklistEntryList.get(i);
        picklistValueMap.put(picklistEntry.getLabel(), picklistEntry.getValue());
        }
        
      return picklistValueMap;
    }
    
    private Map<String, Id> retrieveFieldId() {
      Map<String, String> tempFieldIdMap = new Map<String, String>();
      List<ASI_CRM_Field_ID_Mappings__c> fieldIdMappingList = ASI_CRM_Field_ID_Mappings__c.getAll().values();
      for(ASI_CRM_Field_ID_Mappings__c fieldIdMapping : fieldIdMappingList) {
        tempFieldIdMap.put(fieldIdMapping.ASI_CRM_Field_Name__c, fieldIdMapping.ASI_CRM_Field_ID__c.subString(0, 15));
      }
      return tempFieldIdMap;
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
    
    private String toJsonString(Object obj) {
      return System.JSON.serialize(obj);
  }

  private Object fromJsonString(String jsonString, System.Type apexType) {
    if(String.isBlank(jsonString)) {
    return null;
      }
      return (Object) System.JSON.deserialize(jsonString, apexType);
  }
}