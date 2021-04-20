/*********************************************************************************
 * Name: ASI_CRM_JP_SOInvoice_ComCtrl
 * Description: Controller class for ASI_CRM_JP_SOInvoice_Com
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 11/04/2017       Hugo Cheung             Created          
*/
public class ASI_CRM_JP_SOInvoice_ComCtrl {
    
    //Inner class for storing the data
    public class DetailWrapper {
        public String advPaymentStatement           {get; set;}
        
        public String billToAddrOne                 {get; set;}
        public String billToAddrTwo                 {get; set;}
        public String billingName                   {get; set;}
        public String billingSalutation             {get; set;}
        public String invoiceDate                   {get; set;}
        public String invoiceNumber                 {get; set;}
        public String paymentDueDate                {get; set;}
        public String paymentOption                 {get; set;}
        
        public String soldToCode {get; set;}
        
        public String bankAccountName   {get; set;}
        public String bankAccountType   {get; set;}
        public String bankAccountNumber {get; set;}
        
        public String ownerName        {get; set;}
        public String ownerPhone       {get; set;}
        public String ownerEmail       {get; set;}
        public String ownerAddrOne     {get; set;}
        public String ownerAddrTwo     {get; set;}
        public String ownerDepartment  {get; set;}
        
        public Boolean isRemittance     {get; set;}
        public String taxableServiceFee {get; set;}
        public String remarkTwo         {get; set;}
        
        public Decimal currentTax {get; set;}
        public Integer totalTax   {get; set;}
        public Integer totalPrice {get; set;}
        public Integer subPrice   {get; set;}
    }
    
    public class SalesOrderWrapper {
        public Decimal currentTax {get; set;}
        public Integer totalQty   {get; set;}
        public Integer totalTax   {get; set;}
        public Integer totalPrice {get; set;}
        public Integer subPrice   {get; set;}
        
        public ASI_CRM_JP_Sales_Order__c salesOrder {get; set;}
        public List<ASI_CRM_JP_Sales_Order_Item__c> salesOrderItemList {get; set;}
        public Integer salesOrderItemSize {get {return salesOrderItemList.size();}}
        
        public SalesOrderWrapper(ASI_CRM_JP_Sales_Order__c salesOrder) {
            this.salesOrder         = salesOrder;
            this.currentTax         = currentTax;
            this.salesOrderItemList = new List<ASI_CRM_JP_Sales_Order_Item__c>();
            this.totalQty = 0;
            
            //Mark NG 2020-11-20
            this.currentTax = 0.1;
            if(String.isNotBlank(salesOrder.ASI_CRM_Tax_Area__c) ){
                try{
 System.debug(Integer.valueOf(salesOrder.ASI_CRM_Tax_Area__c.substring(2)));               
                    Decimal r=(Integer.valueOf(salesOrder.ASI_CRM_Tax_Area__c.substring(2)))/100.0;
                    this.currentTax=r;
                }catch (Exception e){}
            }
            
 /*          
            if(String.isNotBlank(salesOrder.ASI_CRM_Tax_Area__c) && 
               salesOrder.ASI_CRM_Tax_Area__c.equalsIgnoreCase('CR8')) {
                this.currentTax = 0.08;
            } else if(String.isNotBlank(salesOrder.ASI_CRM_Tax_Area__c) && 
                      salesOrder.ASI_CRM_Tax_Area__c.equalsIgnoreCase('CR0')) {
                this.currentTax = 0.00;
            }

            if(this.currentTax == null) {
                this.currentTax = 0.08;
            }
 */           
            calculateSalesOrder();
        }
        
        public void addSalesOrderItem(ASI_CRM_JP_Sales_Order_Item__c salesOrderItem) {
            salesOrderItemList.add(salesOrderItem);
            totalQty += Integer.valueOf(salesOrderItem.ASI_CRM_Quantity__c);
        }
        
        private void calculateSalesOrder() {
            totalTax   = 0;
            subPrice   = 0;
            totalPrice = 0;
            
            totalTax += Integer.valueOf((salesOrder.ASI_CRM_Total_Amount__c == null ? 0 : salesOrder.ASI_CRM_Total_Amount__c) * currentTax);
            subPrice += Integer.valueOf((salesOrder.ASI_CRM_Total_Amount__c == null ? 0 : salesOrder.ASI_CRM_Total_Amount__c));
            totalPrice = subPrice + totalTax;
        }
        
    }
    
    //Field Schema Map
    private final static Map<String, Schema.SObjectField> SALES_ORDER_FIELD_MAP      = Schema.SObjectType.ASI_CRM_JP_Sales_Order__c.fields.getMap();
    private final static Map<String, Schema.SObjectField> SALES_ORDER_ITEM_FIELD_MAP = Schema.SObjectType.ASI_CRM_JP_Sales_Order_Item__c.fields.getMap();
    
    //Page Parameters
    public Boolean isPageInit {get { if(isPageInit != true) {isPageInit = init();} return isPageInit;} set;}
    
    public String salesOrderIdListStr {get; set;}
    public String pdfLanguage  {get; set;}
    
    //Sales Order & Child Data
    public List<ASI_CRM_JP_Sales_Order__c> salesOrderList  {get; set;}
    public Map<Id, SalesOrderWrapper> salesOrderWrapperMap {get; set;}
    public User salesOrderOwner                            {get; set;}
    
    public DetailWrapper pageDetail {get; set;}
    
    public ASI_CRM_JP_SOInvoice_ComCtrl() {
    }
    
    private Boolean init() {
        pageDetail = new DetailWrapper();
        List<String> salesOrderIdList = salesOrderIdListStr.split(',');
        salesOrderList     = retrieveSalesOrder(salesOrderIdList);
        salesOrderOwner    = retrieveUser(salesOrderList[0].OwnerId);
        
        createSalesOrderWrapper(salesOrderList);
        calculateTotalSalesOrder();
        initPageParameters();
        
        return true;
    }
    
    private void createSalesOrderWrapper(List<ASI_CRM_JP_Sales_Order__c> salesOrderList) {
        Map<Id, ASI_CRM_JP_Sales_Order__c> salesOrderMap = new Map<Id, ASI_CRM_JP_Sales_Order__c>(salesOrderList);
        
        salesOrderWrapperMap = new Map<Id, SalesOrderWrapper>();
        
        for(ASI_CRM_JP_Sales_Order_Item__c salesOrderItem : retrieveSalesOrderItemList(salesOrderMap.keySet())) {
            SalesOrderWrapper salesOrderWrapper;
            if(salesOrderWrapperMap.containsKey(salesOrderItem.ASI_CRM_Sales_Order__c)) {
                salesOrderWrapper = salesOrderWrapperMap.get(salesOrderItem.ASI_CRM_Sales_Order__c);
            } else {
                salesOrderWrapper = new SalesOrderWrapper(salesOrderMap.get(salesOrderItem.ASI_CRM_Sales_Order__c));
            }
            SalesOrderWrapper.addSalesOrderItem(salesOrderItem);
            salesOrderWrapperMap.put(salesOrderItem.ASI_CRM_Sales_Order__c, SalesOrderWrapper);
        }
    }
    
    private void calculateTotalSalesOrder() {
        pageDetail.totalTax = 0;
        pageDetail.subPrice = 0;
        for(SalesOrderWrapper salesOrderWrapper : salesOrderWrapperMap.values()) {
            pageDetail.totalTax += salesOrderWrapper.totalTax;
            pageDetail.subPrice += salesOrderWrapper.subPrice;
        }
        pageDetail.totalPrice = pageDetail.subPrice + pageDetail.totalTax;
    }
    
    private void initPageParameters() {
        if(pdfLanguage == 'ja') {
            if(String.isNotBlank(salesOrderList[0].ASI_CRM_JP_Bill_To__r.ASI_CRM_JP_Address__c)) {
                String tempAddress = salesOrderList[0].ASI_CRM_JP_Bill_To__r.ASI_CRM_JP_Address__c;
                Integer firstSpaceIndex = tempAddress.indexOf('　');
                if(firstSpaceIndex == -1) {
                    firstSpaceIndex = tempAddress.indexOf(' ');
                }
                pageDetail.billToAddrOne = tempAddress.left(firstSpaceIndex);
                pageDetail.billToAddrTwo = tempAddress.right(tempAddress.length() - firstSpaceIndex - 1);
            }
            pageDetail.billingName = salesOrderList[0].ASI_CRM_JP_Bill_To__r.ASI_CRM_JP_Customer_Name_Kanji__c;
            pageDetail.billingSalutation = salesOrderList[0].ASI_CRM_JP_Bill_To__r.ASI_CRM_Bill_To_Customer__r.ASI_CRM_JP_Salutation__c;
            
            pageDetail.bankAccountName = salesOrderList[0].ASI_CRM_Bank_Account__r.ASI_CRM_Pay_to_Name__c;
            
            pageDetail.ownerName        = salesOrderOwner.ASI_CRM_JP_Name_Local__c;
            pageDetail.ownerPhone       = salesOrderOwner.ASI_CRM_JP_Phone_Local__c; 
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
        } else {
            if(String.isBlank(salesOrderList[0].ASI_CRM_JP_Bill_To__r.ASI_CRM_Bill_To_Customer__r.ASI_CRM_JP_Address_English__c)) {
                if(String.isNotBlank(salesOrderList[0].ASI_CRM_JP_Bill_To__r.ASI_CRM_JP_Address__c)) {
                    String billToTempAddress = salesOrderList[0].ASI_CRM_JP_Bill_To__r.ASI_CRM_JP_Address__c;
                    Integer firstSpaceIndex = billToTempAddress.indexOf('　');
                    if(firstSpaceIndex == -1) {
                        firstSpaceIndex = billToTempAddress.indexOf(' ');
                    }
                    pageDetail.billToAddrOne = billToTempAddress.left(firstSpaceIndex);
                    pageDetail.billToAddrTwo = billToTempAddress.right(billToTempAddress.length() - firstSpaceIndex - 1);
                }
            } else {
                String billToTempAddress = salesOrderList[0].ASI_CRM_JP_Bill_To__r.ASI_CRM_Bill_To_Customer__r.ASI_CRM_JP_Address_English__c;
                List<String> billToAddrList = billToTempAddress.split('\r\n');
                if(billToAddrList.size() > 0) {
                    pageDetail.billToAddrOne = billToAddrList.get(0);
                    for(integer i = 1 ; i < billToAddrList.size() ; i++) {
                        pageDetail.billToAddrTwo += billToAddrList.get(i) + ' ';
                    }
                }
            }
            
            if(String.isBlank(salesOrderList[0].ASI_CRM_JP_Bill_To__r.ASI_CRM_JP_Customer_English_Name_Kanji__c)) {
                pageDetail.billingName = salesOrderList[0].ASI_CRM_JP_Bill_To__r.ASI_CRM_JP_Customer_Name_Kanji__c;
            } else {
                pageDetail.billingName = salesOrderList[0].ASI_CRM_JP_Bill_To__r.ASI_CRM_JP_Customer_English_Name_Kanji__c;
            }
            
            if(String.isBlank(salesOrderList[0].ASI_CRM_Bank_Account__r.ASI_CRM_Pay_to_Eng_Name__c)) {
                pageDetail.bankAccountName = salesOrderList[0].ASI_CRM_Bank_Account__r.ASI_CRM_Pay_to_Name__c;
            } else {
                pageDetail.bankAccountName = salesOrderList[0].ASI_CRM_Bank_Account__r.ASI_CRM_Pay_to_Eng_Name__c;
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
        }
        
        if(salesOrderList.size() > 1) {
            pageDetail.invoiceNumber = salesOrderList[0].AS_CRM_Invoice_Number__c;
        }
        pageDetail.invoiceDate = ((DateTime)salesOrderList[0].ASI_CRM_Invoice_Date__c).format('YYYY/MM/dd');
        if(salesOrderList[0].ASI_CRM_Payment_Request_Date__c != null) {
            pageDetail.paymentDueDate = ((DateTime)salesOrderList[0].ASI_CRM_Payment_Request_Date__c).format('YYYY/MM/dd');
        }
        
        pageDetail.soldToCode = salesOrderList[0].ASI_CRM_Sold_To__r.ASI_CRM_CN_CRM_Code__c;
        
        pageDetail.paymentOption = salesOrderList[0].ASI_CRM_Payment_Option__c; 
        
        pageDetail.ownerEmail      = salesOrderOwner.Email;
        
        pageDetail.bankAccountType      = (salesOrderList[0].ASI_CRM_Bank_Account__r.ASI_CRM_JP_Account_Type__c==null?'普通':salesOrderList[0].ASI_CRM_Bank_Account__r.ASI_CRM_JP_Account_Type__c);
        pageDetail.bankAccountNumber    = salesOrderList[0].ASI_CRM_Bank_Account__r.ASI_CRM_Account_Number__c;
        pageDetail.isRemittance         = salesOrderList[0].ASI_CRM_JP_Bill_To__r.ASI_CRM_Bill_To_Customer__r.ASI_CRM_JP_Remittance_Fee_By_Bill_To__c;
        
        if(pageDetail.paymentOption == 'Advanced Payment' || pageDetail.paymentOption == '事前お振込') {
            String soNumber = salesOrderList[0].Name.substring(3);
            pageDetail.advPaymentStatement = String.format(Label.ASI_CRM_JP_SO_Advance_Payment, new String[] {soNumber});
        }
        
        pageDetail.taxableServiceFee = salesOrderList[0].ASI_CRM_JP_Taxable_Service_Charge__c;
        
        pageDetail.remarkTwo = salesOrderList[0].ASI_CRM_JP_Remark_2__c;
    }
    
    /***************
    Data Retrievement Function
    ***************/
    private List<ASI_CRM_JP_Sales_Order__c> retrieveSalesOrder(List<String> salesOrderIdList) {
        String query = 'SELECT ' + genQueryField(SALES_ORDER_FIELD_MAP) + ', toLabel(ASI_CRM_Payment_Option__c) ' + 
                       ', RecordType.DeveloperName ' + 
                       ', ASI_CRM_Ship_To__r.Name, ASI_CRM_Ship_To__r.ASI_CRM_Customer_Name_Kanji__c, ASI_CRM_Ship_To__r.ASI_CRM_VN_EnglishName__c ' + 
                       ', ASI_CRM_Sold_To__r.ASI_CRM_CN_CRM_Code__c ' + 
                       ', ASI_CRM_Sold_To__r.ASI_CRM_Customer_Name_Kanji__c, ASI_CRM_JP_Bill_To__r.ASI_CRM_JP_Customer_English_Name_Kanji__c ' + 
                       ', ASI_CRM_Bank_Account__r.ASI_CRM_Pay_to_Name__c ' + 
                       ', ASI_CRM_Bank_Account__r.ASI_CRM_Pay_to_Eng_Name__c, ASI_CRM_Bank_Account__r.ASI_CRM_Account_Number__c, toLabel(ASI_CRM_Bank_Account__r.ASI_CRM_JP_Account_Type__c) ' + 
                       ', ASI_CRM_JP_Bill_To__r.ASI_CRM_Bill_To_Customer__r.ASI_CRM_JP_Address_English__c, ASI_CRM_JP_Bill_To__r.ASI_CRM_Bill_To_Customer__r.ASI_CRM_JP_Remittance_Fee_By_Bill_To__c ' + 
                       ', ASI_CRM_JP_Bill_To__r.ASI_CRM_JP_Address__c, ASI_CRM_JP_Bill_To__r.ASI_CRM_JP_Customer_Name_Kanji__c, ASI_CRM_JP_Bill_To__r.ASI_CRM_JP_Phone_Number__c ' + 
                       ', ASI_CRM_JP_Bill_To__r.ASI_CRM_Bill_To_Customer__r.ASI_CRM_JP_Salutation__c ' + 
                       'FROM ASI_CRM_JP_Sales_Order__c ' + 
                       'WHERE Id in :salesOrderIdList ';
        return (List<ASI_CRM_JP_Sales_Order__c>) Database.query(query);
    }
    
    private List<ASI_CRM_JP_Sales_Order_Item__c> retrieveSalesOrderItemList(Set<Id> salesOrderIdList) {
        String query = 'SELECT ' + genQueryField(SALES_ORDER_ITEM_FIELD_MAP) + 
                       ', ASI_CRM_SKU__r.Name, ASI_CRM_Sales_Order__r.Name, ASI_CRM_Sales_Order__r.ASI_CRM_Customer_PO_No__c ' + 
                       ', ASI_CRM_Sales_Order__r.ASI_CRM_Remark__c, ASI_CRM_Sales_Order__r.ASI_CRM_JP_Remark_2__c, ASI_CRM_SKU__r.ASI_CRM_JP_English_Name__c ' + 
                       'FROM ASI_CRM_JP_Sales_Order_Item__c ' + 
                       'WHERE ASI_CRM_Sales_Order__c in :salesOrderIdList ' + 
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
        if(fields != 'ASI_CRM_Payment_Option__c') {
            queryField += fields + ',';
          }
      }
      return queryField.subString(0, queryField.length() - 1);
    }
}