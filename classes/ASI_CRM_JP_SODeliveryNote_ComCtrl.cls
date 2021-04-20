/*********************************************************************************
 * Name: ASI_CRM_JP_SODeliveryNote_ComCtrl
 * Description: Controller class for ASI_CRM_JP_SODeliveryNote_Com
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 11/04/2017       Hugo Cheung             Created          
*/
public class ASI_CRM_JP_SODeliveryNote_ComCtrl {

    //Inner class for storing the data
    public class DetailWrapper {
        public String remark     {get; set;}
        public String remarkTwo  {get; set;}
        public String customerPO {get; set;}
        
        public String orderDate            {get; set;}
        public String paymentRequestedDate {get; set;}
        public String paymentDueDate       {get; set;}
        public String deliveryTime         {get; set;}
        public String weekdayName          {get; set;}
        
        public String soldToSalutation {get; set;}
    	public String soldToName       {get; set;}
        public String soldToCRMCode    {get; set;}
        public String shipToSalutation {get; set;}
        public String shipToName       {get; set;}
        public String shipToAddrOne    {get; set;}
        public String shipToAddrTwo    {get; set;}
        public String shipToPhone      {get; set;}
        public String shipToCRMCode    {get; set;}
        
        public String billToName     {get; set;}
        public String billToAddrOne  {get; set;}
        public String billToAddrTwo  {get; set;}
        public String billToPhone    {get; set;}
        public String billToCRMCode  {get; set;}
        
        public String bankAccountPayToName {get; set;}
        public String bankAccountType      {get; set;}
        public String bankAccountNumber    {get; set;}
        
        public String ownerName        {get; set;}
        public String ownerPhone       {get; set;}
        public String ownerEmail       {get; set;}
        public String ownerAddrOne     {get; set;}
        public String ownerAddrTwo     {get; set;}
        public String ownerDepartment  {get; set;}
        
        public String shipToContactTitle {get; set;}
        public String shipToContactName  {get; set;}
        
        public String paymentTerm {get; set;}
        
        public Boolean isRemittance {get; set;}
        
        public Decimal currentTax         {get; set;}
        public Integer totalQty           {get; set;}
        public Integer totalAmount        {get; set;}
        public Integer totalTax           {get; set;}
        public Integer totalAmountWithTax {get; set;}
    }
    
    //Field Schema Map
    private final static Map<String, Schema.SObjectField> SALES_ORDER_FIELD_MAP      = Schema.SObjectType.ASI_CRM_JP_Sales_Order__c.fields.getMap();
    private final static Map<String, Schema.SObjectField> SALES_ORDER_ITEM_FIELD_MAP = Schema.SObjectType.ASI_CRM_JP_Sales_Order_Item__c.fields.getMap();
    private final static Map<String, Schema.SObjectField> PROCESS_INSTANCE_FIELD_MAP = Schema.SObjectType.ProcessInstance.fields.getMap();
    private final static Map<String, Schema.SObjectField> PROCESS_HISTORY_FIELD_MAP  = Schema.SObjectType.ProcessInstanceHistory.fields.getMap();
    
    //Weekday Map
    private final static Map<String, String> weekdayMap = new Map<String, String> {
    	'Sun' => '日',
        'Mon' => '月',
        'Tue' => '火',
        'Wed' => '水',
        'Thu' => '木',
        'Fri' => '金',
        'Sat' => '土'
    };
   
    //Page Parameters
    public Boolean isPageInit {get { if(isPageInit != true) {isPageInit = init();} return isPageInit;} set;}
    
    public String salesOrderId {get; set;}
    public String pdfLanguage  {get; set;}
    
    //Sales Order & Child Data
    public ASI_CRM_JP_Sales_Order__c salesOrder                    {get; set;}
    public List<ASI_CRM_JP_Sales_Order_Item__c> salesOrderItemList {get; set;}
    public User salesOrderOwner                                    {get; set;}
    public Contact shipToContact                                   {get; set;}
    
    public DetailWrapper pageDetail {get; set;}
    
    //Page Control Parameters
    
    public ASI_CRM_JP_SODeliveryNote_ComCtrl() {
    }
    
    private Boolean init() {
        pageDetail         = new DetailWrapper();
    	salesOrder         = retrieveSalesOrder(salesOrderId);
    	salesOrderOwner    = retrieveUser(salesOrder.OwnerId);
        salesOrderItemList = retrieveSalesOrderItemList(salesOrderId);
        shipToContact      = retrieveContact(salesOrder.ASI_CRM_Ship_To__c);
        mapValue();
        retrieveTax();
        calculateSalesOrder();
        initPageParameters();
    	return true;
    }
    
    private void mapValue() {
        if(pdfLanguage == 'ja') {
            if(salesOrder.ASI_CRM_Requested_Date__c != null) {
                System.debug(((DateTime) salesOrder.ASI_CRM_Requested_Date__c).format('EEE'));
                pageDetail.weekdayName = weekdayMap.get(((DateTime) salesOrder.ASI_CRM_Requested_Date__c).format('EEE'));
            }
        } else {
            if(salesOrder.ASI_CRM_Requested_Date__c != null) {
        		pageDetail.weekdayName = ((DateTime) salesOrder.ASI_CRM_Requested_Date__c).format('EEE');
            }
        }
    }
    
    private void retrieveTax() {
        if(String.isNotBlank(salesOrder.ASI_CRM_Tax_Area__c) && 
           salesOrder.ASI_CRM_Tax_Area__c.equalsIgnoreCase('CR8')) {
        	pageDetail.currentTax = 0.08;
        } else if(String.isNotBlank(salesOrder.ASI_CRM_Tax_Area__c) && 
                  salesOrder.ASI_CRM_Tax_Area__c.equalsIgnoreCase('CR0')) {
        	pageDetail.currentTax = 0.00;
        }
        
        if(pageDetail.currentTax == null) {
        	pageDetail.currentTax = 0.08;
        }
    }
    
    private void calculateSalesOrder() {
        pageDetail.totalTax = Integer.valueOf((salesOrder.ASI_CRM_Total_Amount__c == null ? 0 : salesOrder.ASI_CRM_Total_Amount__c) 
                            * pageDetail.currentTax);
        pageDetail.totalAmount = Integer.valueOf((salesOrder.ASI_CRM_Total_Amount__c == null ? 0 : salesOrder.ASI_CRM_Total_Amount__c) 
                              + pageDetail.totalTax);
    	pageDetail.totalQty = 0;
        for(ASI_CRM_JP_Sales_Order_Item__c salesOrderItem : salesOrderItemList) {
            pageDetail.totalQty += Integer.valueOf(salesOrderItem.ASI_CRM_Quantity__c == null ? 0 : salesOrderItem.ASI_CRM_Quantity__c);
        }
    }
    
    private void initPageParameters() {
        if(pdfLanguage == 'ja') {
            pageDetail.soldToName = salesOrder.ASI_CRM_Sold_To__r.ASI_CRM_Customer_Name_Kanji__c;
            pageDetail.shipToName = salesOrder.ASI_CRM_Ship_To__r.ASI_CRM_Customer_Name_Kanji__c;
            if(String.isNotBlank(salesOrder.ASI_CRM_JP_Ship_To_Address__c)) {
                String tempAddress = salesOrder.ASI_CRM_JP_Ship_To_Address__c;
                Integer firstSpaceIndex = tempAddress.indexOf('　');
                if(firstSpaceIndex == -1) {
                    firstSpaceIndex = tempAddress.indexOf(' ');
                }
                pageDetail.shipToAddrOne = tempAddress.left(firstSpaceIndex);
                pageDetail.shipToAddrTwo = tempAddress.right(tempAddress.length() - firstSpaceIndex - 1);
            }
            
            pageDetail.billToName = salesOrder.ASI_CRM_JP_Bill_To__r.ASI_CRM_JP_Customer_Name_Kanji__c;
            if(String.isNotBlank(salesOrder.ASI_CRM_JP_Bill_To__r.ASI_CRM_JP_Address__c)) {
                String tempAddress = salesOrder.ASI_CRM_JP_Bill_To__r.ASI_CRM_JP_Address__c;
                Integer firstSpaceIndex = tempAddress.indexOf('　');
                if(firstSpaceIndex == -1) {
                    firstSpaceIndex = tempAddress.indexOf(' ');
                }
                pageDetail.billToAddrOne = tempAddress.left(firstSpaceIndex);
                pageDetail.billToAddrTwo = tempAddress.right(tempAddress.length() - firstSpaceIndex - 1);
            }
           	
            pageDetail.bankAccountPayToName = salesOrder.ASI_CRM_Bank_Account__r.ASI_CRM_Pay_to_Name__c;
            pageDetail.bankAccountType      = salesOrder.ASI_CRM_Bank_Account__r.ASI_CRM_JP_Account_Type__c;
            pageDetail.bankAccountNumber    = salesOrder.ASI_CRM_Bank_Account__r.ASI_CRM_Account_Number__c;
                
            pageDetail.ownerName        = salesOrderOwner.ASI_CRM_JP_Name_Local__c;
            if(String.isNotBlank(salesOrderOwner.ASI_CRM_JP_Address_Local__c)) {
                String tempAddress = salesOrderOwner.ASI_CRM_JP_Address_Local__c;
                Integer firstSpaceIndex = tempAddress.indexOf('　');
                if(firstSpaceIndex == -1) {
                    firstSpaceIndex = tempAddress.indexOf(' ');
                }
                pageDetail.ownerAddrOne = '〒' + salesOrderOwner.PostalCode + ' ' + tempAddress.left(firstSpaceIndex);
                pageDetail.ownerAddrTwo = tempAddress.right(tempAddress.length() - firstSpaceIndex - 1);
            }
            pageDetail.ownerDepartment  = salesOrderOwner.ASI_CRM_JP_Department_Local__c;
            pageDetail.ownerPhone       = salesOrderOwner.ASI_CRM_JP_Phone_Local__c;
            
            pageDetail.shipToContactTitle = shipToContact.Title;
            pageDetail.shipToContactName  = (String.isNotBlank(shipToContact.ASI_LUX_Last_Name_Kanji__c) ? shipToContact.ASI_LUX_Last_Name_Kanji__c : '') 
                                          + (String.isNotBlank(shipToContact.ASI_LUX_First_Name_Kanji__c) ? shipToContact.ASI_LUX_First_Name_Kanji__c : '');
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
            
            if(String.isBlank(salesOrder.ASI_CRM_Ship_To__r.ASI_CRM_JP_Address_English__c)) {
            	if(String.isNotBlank(salesOrder.ASI_CRM_JP_Ship_To_Address__c)) {
                    String shipToTempAddress = salesOrder.ASI_CRM_JP_Ship_To_Address__c;
                    Integer firstSpaceIndex = shipToTempAddress.indexOf('　');
                    if(firstSpaceIndex == -1) {
                        firstSpaceIndex = shipToTempAddress.indexOf(' ');
                    }
                    pageDetail.shipToAddrOne = shipToTempAddress.left(firstSpaceIndex);
                    pageDetail.shipToAddrTwo = shipToTempAddress.right(shipToTempAddress.length() - firstSpaceIndex - 1);
                }
            } else {
                String shipToTempAddress = salesOrder.ASI_CRM_Ship_To__r.ASI_CRM_JP_Address_English__c;
                List<String> shipToAddrList = shipToTempAddress.split('\r\n');
                if(shipToAddrList.size() > 0) {
                    pageDetail.shipToAddrOne = shipToAddrList.get(0);
                    pageDetail.shipToAddrTwo = '';
                    for(integer i = 1 ; i < shipToAddrList.size() ; i++) {
                        pageDetail.shipToAddrTwo += shipToAddrList.get(i) + ' ';
                    }
                    pageDetail.shipToAddrTwo += salesOrder.ASI_CRM_Ship_To__r.ASI_CRM_PostalCode__c;
                }
            }
            
            if(String.isBlank(salesOrder.ASI_CRM_JP_Bill_To__r.ASI_CRM_JP_Customer_English_Name_Kanji__c)) {
            	pageDetail.billToName = salesOrder.ASI_CRM_JP_Bill_To__r.ASI_CRM_JP_Customer_Name_Kanji__c;
            } else {
            	pageDetail.billToName = salesOrder.ASI_CRM_JP_Bill_To__r.ASI_CRM_JP_Customer_English_Name_Kanji__c;
            }
            
            if(String.isBlank(salesOrder.ASI_CRM_JP_Bill_To__r.ASI_CRM_Bill_To_Customer__r.ASI_CRM_JP_Address_English__c)) {
           		if(String.isNotBlank(salesOrder.ASI_CRM_JP_Bill_To__r.ASI_CRM_JP_Address__c)) {
                    String billToTempAddress = salesOrder.ASI_CRM_JP_Bill_To__r.ASI_CRM_JP_Address__c;
                    Integer firstSpaceIndex = billToTempAddress.indexOf('　');
                    if(firstSpaceIndex == -1) {
                        firstSpaceIndex = billToTempAddress.indexOf(' ');
                    }
                    pageDetail.billToAddrOne = billToTempAddress.left(firstSpaceIndex);
                    pageDetail.billToAddrTwo = billToTempAddress.right(billToTempAddress.length() - firstSpaceIndex - 1);
                }
            } else {
                String billToTempAddress = salesOrder.ASI_CRM_JP_Bill_To__r.ASI_CRM_Bill_To_Customer__r.ASI_CRM_JP_Address_English__c;
                List<String> billToAddrList = billToTempAddress.split('\r\n');
                if(billToAddrList.size() > 0) {
                    pageDetail.billToAddrOne = billToAddrList.get(0);
                    pageDetail.billToAddrTwo = '';
                    for(integer i = 1 ; i < billToAddrList.size() ; i++) {
                        pageDetail.billToAddrTwo += billToAddrList.get(i) + ' ';
                    }
                    pageDetail.billToAddrTwo += salesOrder.ASI_CRM_JP_Bill_To__r.ASI_CRM_Bill_To_Customer__r.ASI_CRM_PostalCode__c;
                }
            }
        
            if(String.isBlank(salesOrder.ASI_CRM_Bank_Account__r.ASI_CRM_Pay_to_Eng_Name__c)) {
            	pageDetail.bankAccountPayToName = salesOrder.ASI_CRM_Bank_Account__r.ASI_CRM_Pay_to_Name__c;
            } else {
            	pageDetail.bankAccountPayToName = salesOrder.ASI_CRM_Bank_Account__r.ASI_CRM_Pay_to_Eng_Name__c;
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
            
            if(String.isBlank(salesOrderOwner.Department)) {
                pageDetail.ownerDepartment  = salesOrderOwner.ASI_CRM_JP_Department_Local__c;
            } else {
                pageDetail.ownerDepartment  = salesOrderOwner.Department;
            }

            if(String.isBlank(salesOrderOwner.Phone)) {
                pageDetail.ownerPhone = salesOrderOwner.ASI_CRM_JP_Phone_Local__c;
            } else {
                pageDetail.ownerPhone = salesOrderOwner.Phone;
            }
            
            if(String.isBlank(shipToContact.Description)) {
            	pageDetail.shipToContactTitle = shipToContact.Title;
            } else {
            	pageDetail.shipToContactTitle = shipToContact.Description;
            }
            
            if(String.isBlank(shipToContact.Name)) {
                pageDetail.shipToContactName  = (String.isNotBlank(shipToContact.ASI_LUX_Last_Name_Kanji__c) ? shipToContact.ASI_LUX_Last_Name_Kanji__c : '') 
                                              + (String.isNotBlank(shipToContact.ASI_LUX_First_Name_Kanji__c) ? shipToContact.ASI_LUX_First_Name_Kanji__c : '');
            } else {
                pageDetail.shipToContactName = shipToContact.Name;
            }
            
        }
        
        pageDetail.shipToCRMCode = salesOrder.ASI_CRM_Ship_To__r.ASI_CRM_CN_CRM_Code__c; 
        pageDetail.soldToCRMCode = salesOrder.ASI_CRM_Sold_To__r.ASI_CRM_CN_CRM_Code__c;
        pageDetail.billToCRMCode = salesOrder.ASI_CRM_JP_Bill_To__r.ASI_CRM_Bill_To_Customer__r.ASI_CRM_CN_CRM_Code__c;

       	pageDetail.orderDate = ((DateTime)salesOrder.ASI_CRM_Order_Date__c).format('YYYY/MM/dd');
            
        if(salesOrder.ASI_CRM_Payment_Request_Date__c != null) {
       		pageDetail.paymentRequestedDate = ((DateTime)salesOrder.ASI_CRM_Payment_Request_Date__c).format('YYYY/MM/dd');
        	pageDetail.paymentDueDate = ((DateTime)salesOrder.ASI_CRM_Payment_Request_Date__c).format('YYYY/MM/dd');
        }
        
        pageDetail.paymentTerm = salesOrder.ASI_CRM_Payment_Term__c;
        
        pageDetail.shipToSalutation = salesOrder.ASI_CRM_Ship_To__r.ASI_CRM_JP_Salutation__c;
        pageDetail.soldToSalutation = salesOrder.ASI_CRM_Sold_To__r.ASI_CRM_JP_Salutation__c;
        
        pageDetail.shipToPhone = salesOrder.ASI_CRM_JP_Ship_To_Phone_Number__c;
        
        pageDetail.billToPhone = salesOrder.ASI_CRM_JP_Bill_To__r.ASI_CRM_JP_Phone_Number__c;
        
        pageDetail.bankAccountType      = salesOrder.ASI_CRM_Bank_Account__r.ASI_CRM_JP_Account_Type__c;
        pageDetail.bankAccountNumber    = salesOrder.ASI_CRM_Bank_Account__r.ASI_CRM_Account_Number__c;
        
        pageDetail.ownerEmail      = salesOrderOwner.Email;
        
        pageDetail.deliveryTime = salesOrder.ASI_CRM_Delivery_Time__c;
        
        pageDetail.isRemittance = salesOrder.ASI_CRM_JP_Bill_To__r.ASI_CRM_Bill_To_Customer__r.ASI_CRM_JP_Remittance_Fee_By_Bill_To__c;
        
        pageDetail.customerPO = salesOrder.ASI_CRM_Customer_PO_No__c;
        
        pageDetail.remark = '';
        pageDetail.remarkTwo = salesOrder.ASI_CRM_JP_Remark_2__c;
        if(String.isNotBlank(salesOrder.ASI_CRM_Remark__c)) {
            List<String> remarkCharList = salesOrder.ASI_CRM_Remark__c.split('');
            for(Integer i = 0 ; i < remarkCharList.size() ; i ++) {
                String remarkChar = remarkCharList.get(i);
                pageDetail.remark += remarkChar;
                if(i > 0 && math.mod(i,20) == 0 && remarkCharList.size() > i + 1) {
                    pageDetail.remark += '<br />';
                }
            }
        }
        
        /*
        if(String.isNotBlank(salesOrder.ASI_CRM_JP_Remark_2__c)) {
            List<String> remark2CharList = salesOrder.ASI_CRM_JP_Remark_2__c.split('');
            for(Integer i = 0 ; i < remark2CharList.size() ; i ++) {
                String remarkChar = remark2CharList.get(i);
                pageDetail.remarkTwo += remarkChar;
                if(i > 0 && math.mod(i,20) == 0 && remark2CharList.size() > i + 1) {
                    pageDetail.remarkTwo += '<br />';
                }
            }
        }
        */
    }
    
    /***************
  	Data Retrievement Function
  	***************/
    private ASI_CRM_JP_Sales_Order__c retrieveSalesOrder(Id salesOrderId) {
    	String query = 'SELECT ' + genQueryField(SALES_ORDER_FIELD_MAP) + ', toLabel(ASI_CRM_Delivery_Time__c) ' + 
                       ', RecordType.DeveloperName ' + 
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
                       ', ASI_CRM_SKU__r.Name, ASI_CRM_SKU__r.ASI_CRM_JP_English_Name__c ' + 
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
    
    private Contact retrieveContact(Id customerId) {
        String query = 'SELECT Id, Name, Title , ASI_LUX_First_Name_Kanji__c, ASI_LUX_Last_Name_Kanji__c, Description, ASI_HK_CRM_Main_Contact__c ' + 
                       'FROM Contact ' + 
                       'WHERE ASI_CRM_AccountAdditionalField__c = :customerId '; 
        
        List<Contact> contactList = (List<Contact>) Database.query(query);
        Contact mainContact = contactList.size() > 0 ? contactList.get(0) : null;
        for(Contact con : contactList) {
            if(con.ASI_HK_CRM_Main_Contact__c == true) {
            	mainContact = con;
            }
        }
        
        return mainContact == null ? new Contact() : mainContact;
    }
    
    private List<User> retrieveUser(List<Id> userIdList) {
    	String query = 'SELECT Id, Name, Title ' + 
                       'FROM User ' + 
                       'WHERE id in :userIdList ';
        return (List<User>) Database.query(query);
    }
    
    /***************
  	Tools Function
  	***************/
    public String genQueryField(Map<String, Schema.SObjectField> fieldMap) {
      String queryField = '';
      for(String fields : fieldMap.keySet()) {
          if(fields != 'ASI_CRM_Delivery_Time__c') {
          	queryField += fields + ',';
          }
      }
      return queryField.subString(0, queryField.length() - 1);
    }
}