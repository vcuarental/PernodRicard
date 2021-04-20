/*********************************************************************************
 * Name: ASI_CRM_JP_SODFDeliveryNote_ComCtrl
 * Description: Controller class for ASI_CRM_JP_SODFDeliveryNote_Com
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 30/06/2017       Hugo Cheung             Created          
*/
public class ASI_CRM_JP_SODFDeliveryNote_ComCtrl {
    
    //Inner class for storing the data
    public class DetailWrapper {
        public String soldToSalutation {get; set;}
        public String soldToName       {get; set;}
        public String soldToCRMCode    {get; set;}
        
        public String shipToSalutation {get; set;}
        public String shipToName       {get; set;}
        public String shipToCRMCode    {get; set;}
        
        public String targetCustomerSalutation {get; set;}
        public String targetCustomerName       {get; set;}
        public String targetCustomerCRMCode    {get; set;}
        
        public String ownerName        {get; set;}
        public String ownerAddrOne     {get; set;}
        public String ownerAddrTwo     {get; set;}
    }
    
    //Field Schema Map
    private final static Map<String, Schema.SObjectField> SALES_ORDER_FIELD_MAP      = Schema.SObjectType.ASI_CRM_JP_Sales_Order__c.fields.getMap();
    private final static Map<String, Schema.SObjectField> SALES_ORDER_ITEM_FIELD_MAP = Schema.SObjectType.ASI_CRM_JP_Sales_Order_Item__c.fields.getMap();
    
    //Page Parameters
    public Boolean isPageInit {get { if(isPageInit != true) {isPageInit = init();} return isPageInit;} set;}
    
    public String salesOrderId {get; set;}
    public String pdfLanguage  {get; set;}
    
    //Sales Order & Child Data
    public ASI_CRM_JP_Sales_Order__c salesOrder                    {get; set;}
    public List<ASI_CRM_JP_Sales_Order_Item__c> salesOrderItemList {get; set;}
    public User salesOrderOwner                                    {get; set;}
    
    public DetailWrapper pageDetail {get; set;}
    
    public Boolean showShipTo {get; set;}
    
    public ASI_CRM_JP_SODFDeliveryNote_ComCtrl() {
    }
    
    private Boolean init() {
        pageDetail = new DetailWrapper();
    	salesOrder         = retrieveSalesOrder(salesOrderId);
    	salesOrderOwner    = retrieveUser(salesOrder.OwnerId);
        salesOrderItemList = retrieveSalesOrderItemList(salesOrderId);
        initPageParameters();
        return true;
    }
    
    private void initPageParameters() {
    	if(pdfLanguage == 'ja') {
        	pageDetail.soldToName         = salesOrder.ASI_CRM_Sold_To__r.ASI_CRM_Customer_Name_Kanji__c;
            pageDetail.shipToName         = salesOrder.ASI_CRM_Ship_To__r.ASI_CRM_Customer_Name_Kanji__c;
            pageDetail.targetCustomerName = salesOrder.ASI_CRM_JP_Target_Customer__r.ASI_CRM_Customer_Name_Kanji__c;
            
            pageDetail.ownerName = salesOrderOwner.ASI_CRM_JP_Name_Local__c;
            if(String.isNotBlank(salesOrderOwner.ASI_CRM_JP_Address_Local__c)) {
                String tempAddress = salesOrderOwner.ASI_CRM_JP_Address_Local__c;
                Integer firstSpaceIndex = tempAddress.indexOf('　');
                if(firstSpaceIndex == -1) {
                    firstSpaceIndex = tempAddress.indexOf(' ');
                }
                pageDetail.ownerAddrOne = '〒' + salesOrderOwner.PostalCode + ' ' + tempAddress.left(firstSpaceIndex);
                pageDetail.ownerAddrTwo = tempAddress.right(tempAddress.length() - firstSpaceIndex - 1);
            }
        } else {
            if(String.isBlank(salesOrder.ASI_CRM_Sold_To__r.ASI_CRM_VN_EnglishName__c)) {
        		pageDetail.soldToName = salesOrder.ASI_CRM_Sold_To__r.ASI_CRM_Customer_Name_Kanji__c;
            } else {
        		pageDetail.soldToName = salesOrder.ASI_CRM_Sold_To__r.ASI_CRM_VN_EnglishName__c;
            }
            
            if(String.isBlank(salesOrder.ASI_CRM_Ship_To__r.ASI_CRM_VN_EnglishName__c)) {
        		pageDetail.shipToName = salesOrder.ASI_CRM_Ship_To__r.ASI_CRM_Customer_Name_Kanji__c;
            } else {
        		pageDetail.shipToName = salesOrder.ASI_CRM_Ship_To__r.ASI_CRM_VN_EnglishName__c;
            }
            
            if(String.isBlank(salesOrder.ASI_CRM_JP_Target_Customer__r.ASI_CRM_VN_EnglishName__c)) {
        		pageDetail.targetCustomerName = salesOrder.ASI_CRM_JP_Target_Customer__r.ASI_CRM_Customer_Name_Kanji__c;
            } else {
        		pageDetail.targetCustomerName = salesOrder.ASI_CRM_JP_Target_Customer__r.ASI_CRM_VN_EnglishName__c;
            }
            
        	if(String.isBlank(salesOrderOwner.Name)) {
                pageDetail.ownerName = salesOrderOwner.ASI_CRM_JP_Name_Local__c;
            } else {
                pageDetail.ownerName = salesOrderOwner.Name;
            }
            
            if(String.isBlank(salesOrderOwner.Street)) {
                if(String.isNotBlank(salesOrderOwner.ASI_CRM_JP_Address_Local__c)) {
                    String tempAddress = salesOrderOwner.ASI_CRM_JP_Address_Local__c;
                    Integer firstSpaceIndex = tempAddress.indexOf('　');
                    if(firstSpaceIndex == -1) {
                        firstSpaceIndex = tempAddress.indexOf(' ');
                    }
                    pageDetail.ownerAddrOne = tempAddress.left(firstSpaceIndex);
                    pageDetail.ownerAddrTwo = tempAddress.right(tempAddress.length() - firstSpaceIndex - 1);
                }
            } else {
                String tempAddress = salesOrderOwner.Street;
                List<String> addrList = tempAddress.split('\r\n');
                if(addrList.size() > 0) {
                    pageDetail.ownerAddrOne = addrList.get(0);
                    pageDetail.ownerAddrTwo = '';
                    for(integer i = 1 ; i < addrList.size() ; i++) {
                        if(String.isNotBlank(addrList.get(i))) {
                        	pageDetail.ownerAddrTwo += addrList.get(i) + ' ';
                        }
                    }
                    pageDetail.ownerAddrTwo += (String.isNotBlank(salesOrderOwner.City) ? salesOrderOwner.City + ' ' : '')
                                             + (String.isNotBlank(salesOrderOwner.State) ? salesOrderOwner.State + ' ' : '')
                                             + (String.isNotBlank(salesOrderOwner.PostalCode) ? salesOrderOwner.PostalCode + ' ' : '')
                                             + (String.isNotBlank(salesOrderOwner.Country) ? salesOrderOwner.Country : '');
                }
            }
        }
        
        pageDetail.soldToCRMCode    = salesOrder.ASI_CRM_Sold_To__r.ASI_CRM_CN_CRM_Code__c;
        pageDetail.soldToSalutation = salesOrder.ASI_CRM_Sold_To__r.ASI_CRM_JP_Salutation__c;
        
        pageDetail.shipToCRMCode    = salesOrder.ASI_CRM_Ship_To__r.ASI_CRM_CN_CRM_Code__c;
        pageDetail.shipToSalutation = salesOrder.ASI_CRM_Ship_To__r.ASI_CRM_JP_Salutation__c;
        
		//Vincent Kwok@2018/01/12 Put default value = 様 for all non-Direct Sales Japanese delivery note
		if (!salesOrder.RecordType.DeveloperName.contains('ASI_CRM_JP_Direct_Sales')) {
			pageDetail.soldToSalutation = '様';
            pageDetail.shipToSalutation = '様';
		}
        
        pageDetail.targetCustomerCRMCode    = salesOrder.ASI_CRM_JP_Target_Customer__r.ASI_CRM_CN_CRM_Code__c;
        pageDetail.targetCustomerSalutation = salesOrder.ASI_CRM_JP_Target_Customer__r.ASI_CRM_JP_Salutation__c;
        
        if(salesOrder.ASI_CRM_JP_Target_Customer__c == null) {
        	showShipTo = true;
        } else {
        	showShipTo = false;
        }
    }
    
    /***************
  	Data Retrievement Function
  	***************/
    private ASI_CRM_JP_Sales_Order__c retrieveSalesOrder(Id salesOrderId) {
    	String query = 'SELECT ' + genQueryField(SALES_ORDER_FIELD_MAP) +
                       ', RecordType.DeveloperName ' + 
                       ', ASI_CRM_JP_Target_Customer__r.Name, ASI_CRM_JP_Target_Customer__r.ASI_CRM_Customer_Name_Kanji__c, ASI_CRM_JP_Target_Customer__r.ASI_CRM_VN_EnglishName__c ' + 
                       ', toLabel(ASI_CRM_JP_Target_Customer__r.ASI_CRM_JP_Salutation__c), ASI_CRM_JP_Target_Customer__r.ASI_CRM_CN_CRM_Code__c ' + 
                       ', ASI_CRM_Ship_To__r.Name, ASI_CRM_Ship_To__r.ASI_CRM_Customer_Name_Kanji__c, ASI_CRM_Ship_To__r.ASI_CRM_VN_EnglishName__c, ASI_CRM_Ship_To__r.ASI_CRM_JP_Address_English__c, toLabel(ASI_CRM_Ship_To__r.ASI_CRM_JP_Salutation__c) ' + 
                       ', ASI_CRM_Ship_To__r.ASI_CRM_PostalCode__c, ASI_CRM_Sold_To__r.ASI_CRM_Customer_Name_Kanji__c, ASI_CRM_Sold_To__r.ASI_CRM_VN_EnglishName__c, toLabel(ASI_CRM_Sold_To__r.ASI_CRM_JP_Salutation__c) ' + 
                       ', ASI_CRM_Ship_To__r.ASI_CRM_CN_CRM_Code__c, ASI_CRM_Sold_To__r.ASI_CRM_CN_CRM_Code__c, ASI_CRM_JP_Bill_To__r.ASI_CRM_Bill_To_Customer__r.ASI_CRM_CN_CRM_Code__c' + 
                       ', ASI_CRM_Bank_Account__r.ASI_CRM_Pay_to_Name__c, ASI_CRM_Bank_Account__r.ASI_CRM_Account_Number__c, toLabel(ASI_CRM_Bank_Account__r.ASI_CRM_JP_Account_Type__c) ' +
                       ', ASI_CRM_Bank_Account__r.ASI_CRM_Pay_to_Eng_Name__c, ASI_CRM_JP_Bill_To__r.ASI_CRM_Bill_To_Customer__r.ASI_CRM_JP_Remittance_Fee_By_Bill_To__c ' + 
                       ', ASI_CRM_JP_Bill_To__r.ASI_CRM_JP_Address__c, ASI_CRM_JP_Bill_To__r.ASI_CRM_JP_Customer_Name_Kanji__c, ASI_CRM_JP_Bill_To__r.ASI_CRM_JP_Phone_Number__c ' +
                       ', ASI_CRM_JP_Bill_To__r.ASI_CRM_Bill_To_Customer__r.ASI_CRM_JP_Address_English__c, ASI_CRM_JP_Bill_To__r.ASI_CRM_JP_Customer_English_Name_Kanji__c ' + 
                       ', ASI_CRM_JP_Bill_To__r.ASI_CRM_Bill_To_Customer__r.ASI_CRM_PostalCode__c ' + 
                       'FROM ASI_CRM_JP_Sales_Order__c ' + 
                       'WHERE Id = :salesOrderId ';
        List<ASI_CRM_JP_Sales_Order__c> salesOrderList = (List<ASI_CRM_JP_Sales_Order__c>) Database.query(query);
        return salesOrderList.size() > 0 ? salesOrderList.get(0) : null;
    }
    
    private List<ASI_CRM_JP_Sales_Order_Item__c> retrieveSalesOrderItemList(Id salesOrderId) {
    	String query = 'SELECT ' + genQueryField(SALES_ORDER_ITEM_FIELD_MAP) + 
                       ', ASI_CRM_SKU__r.Name, ASI_CRM_SKU__r.ASI_CRM_JP_English_Name__c, ASI_CRM_SKU__r.ASI_HK_CRM_Packaging_Size__c ' + 
                       'FROM ASI_CRM_JP_Sales_Order_Item__c ' + 
                       'WHERE ASI_CRM_Sales_Order__c = :salesOrderId ' + 
                       'AND ASI_CRM_Status__c != \'980-Cancelled\'';
        return (List<ASI_CRM_JP_Sales_Order_Item__c>) Database.query(query);
    }
    
    private User retrieveUser(Id userId) {
        String query = 'SELECT Id, Name, State, PostalCode, City, Street, Country, CompanyName, Department, Phone, Email ' +
                       ', ASI_CRM_JP_Department_Local__c, ASI_CRM_JP_Address_Local__c, ASI_CRM_JP_Phone_Local__c, ASI_CRM_JP_Name_Local__c ' + 
                       'FROM User ' + 
                       'WHERE id = :userId ';
        List<User> userList = (List<User>) Database.query(query);
        return userList.size() > 0 ? userList.get(0) : null;
    }
    
    /***************
  	Tools Function
  	***************/
    public String genQueryField(Map<String, Schema.SObjectField> fieldMap) {
      String queryField = '';
      for(String fields : fieldMap.keySet()) {
      	queryField += fields + ',';
      }
      return queryField.subString(0, queryField.length() - 1);
    }
}