/**************************************************************************************************
 * Name: ASI_CTY_CN_WS_ChooseOrderTypeController
 * Object: ASI_CRM_AccountsAdditionalField__c
 * Purpose: Create order information
 * Author:  (jack yuan)
 * Create Date: 2019-11-19
 * Modify History:
 * 2019-05-07        Create this class
 **************************************************************************************************/
public without sharing class ASI_CTY_CN_WS_ChooseOrderTypeController {
    private static final String SOR_RECORDTYPE = Global_RecordTypeCache.getRtId('ASI_KOR_Sales_Order_Request__cASI_CRM_CN_SalesOrder');

    @AuraEnabled
    public static String saveSaleOrder(String contactJson) {
        ContactInfo conInfo = (ContactInfo)JSON.deserialize(contactJson, ContactInfo.class);
        Contact con = getContact();
        System.debug(LoggingLevel.INFO, '*** con: ' + con);
        // Query the customer information 
        List<ASI_CRM_AccountsAdditionalField__c> customers = [SELECT Name, ASI_CRM_Account__c, ASI_CRM_CN_Address__c,
                                                                ASI_CRM_CN_Commercial_Team__c,
                                                                ASI_CRM_Account__r.Regional_Manager__c
                                                            FROM ASI_CRM_AccountsAdditionalField__c
                                                            WHERE ASI_CRM_Account__c = :con.AccountId];
        ASI_KOR_Sales_Order_Request__c sor = new ASI_KOR_Sales_Order_Request__c();
        sor.ASI_CRM_CN_Contact_Person__c = conInfo.name;
        sor.ASI_CRM_CN_Tel_Mobile__c = conInfo.phone;
        sor.ASI_CRM_CN_Customer__c = conInfo.accountId;
        // the customer team is premium
        if (!customers.isEmpty()) {
            if (customers[0].ASI_CRM_CN_Commercial_Team__c == ASI_CTY_CN_WS_Utils.TYPE_PREMIUM) {
                sor.ASI_CRM_CN_Premium__c = true;
            }
            if (customers[0].ASI_CRM_Account__r.Regional_Manager__c != null) {
                // sor.OwnerId = customers[0].ASI_CRM_Account__r.Regional_Manager__c;
            }
            if (customers[0].ASI_CRM_Account__r.Regional_Manager__c == null) {
                return 'noTeamLeader';
            }
        }
        sor.ASI_CRM_SG_Order_Date__c = System.today();
        sor.ASI_CRM_CN_Address__c = conInfo.address;
        sor.ASI_CRM_CN_Other_Requirement__c = conInfo.otherRequirement;
        sor.ASI_KOR_Order_Status__c = ASI_CTY_CN_WS_Utils.STATUS_SOROPEN;
        sor.RecordTypeId = SOR_RECORDTYPE;
        if (String.isNotBlank(conInfo.orderId)) {
            sor.Id = conInfo.orderId;
        }
        upsert sor;
        return sor.Id;
    }
    
    @AuraEnabled
    public static ContactInfo getContactInfo() {

        ContactInfo conInfo = new ContactInfo();
        Contact con = getContact();
        if (con != null) {
            conInfo.name = con.Name;
            conInfo.phone = con.Phone;
            
            conInfo.currentDate = System.today().year() + '-' 
                                  + System.today().month() + '-'
                                  + System.today().day();
            // query current user customer
            List<ASI_CRM_AccountsAdditionalField__c> customers = [SELECT Name, ASI_CRM_Account__c, ASI_CRM_CN_Address__c,
                                                                        ASI_CRM_CN_Commercial_Team__c
                                                                  FROM ASI_CRM_AccountsAdditionalField__c
                                                                  WHERE ASI_CRM_Account__c = :con.AccountId];
            System.debug(LoggingLevel.INFO, '*** customers: ' + customers);
            if (!customers.isEmpty()) {
                ASI_CRM_AccountsAdditionalField__c customer = customers[0];
                conInfo.accountName = customer.Name;
                conInfo.accountId = customer.Id;
                // query order that stauts is open
                List<ASI_KOR_Sales_Order_Request__c> openOrderList  = [SELECT ASI_CRM_CN_Customer__c, ASI_CRM_CN_Address__c, ASI_CRM_CN_Contact_Person__c,
                                                                              ASI_CRM_CN_Other_Requirement__c,Name,ASI_CRM_CN_Tel_Mobile__c,
                                                                              ASI_CRM_SG_Order_Date__c,ASI_CTY_CN_WS_Status__c,
                                                                              (SELECT Id FROM ASI_KOR_Sales_Order_Transactions__r)
                                                                        FROM ASI_KOR_Sales_Order_Request__c
                                                                        WHERE ASI_CRM_CN_Customer__c = :customer.Id
                                                                        AND ASI_KOR_Order_Status__c = :ASI_CTY_CN_WS_Utils.STATUS_SOROPEN
                                                                        AND RecordTypeId = :SOR_RECORDTYPE
                                                                        AND CreatedById = :UserInfo.getUserId()
                                                                        ORDER BY Name DESC];
                System.debug(LoggingLevel.INFO, '*** UserInfo.getUserId(): ' + UserInfo.getUserId());
                if (openOrderList.size() >= 2) {
                    conInfo.hasMultipleOrders = true;
                }
                if (!openOrderList.isEmpty()) {
                    conInfo.orderId = openOrderList[0].Id;
                    conInfo.orderName = openOrderList[0].Name;
                    conInfo.name = openOrderList[0].ASI_CRM_CN_Contact_Person__c;
                    conInfo.phone = openOrderList[0].ASI_CRM_CN_Tel_Mobile__c;
                    conInfo.currentDate = String.valueOf(openOrderList[0].ASI_CRM_SG_Order_Date__c);
                    conInfo.address = openOrderList[0].ASI_CRM_CN_Address__c;
                    conInfo.otherRequirement = openOrderList[0].ASI_CRM_CN_Other_Requirement__c;
                    conInfo.orderStatus = openOrderList[0].ASI_CTY_CN_WS_Status__c;
                    if (!openOrderList[0].ASI_KOR_Sales_Order_Transactions__r.isEmpty()) {
                        conInfo.hasOrderItems = true;
                    }
                } else {

                    // query the latest order
                    List<ASI_KOR_Sales_Order_Request__c> salesOrderList  = [SELECT ASI_CRM_CN_Customer__c,ASI_CRM_CN_Address__c,ASI_CTY_CN_WS_Status__c,
                                                                                  ASI_CRM_CN_Other_Requirement__c,ASI_CRM_CN_Tel_Mobile__c
                                                                            FROM ASI_KOR_Sales_Order_Request__c
                                                                            WHERE ASI_CRM_CN_Customer__c = :customer.Id
                                                                            AND CreatedById = :UserInfo.getUserId()
                                                                            ORDER BY CreatedDate DESC
                                                                            LIMIT 1];
                    System.debug(LoggingLevel.INFO, '*** salesOrderList: ' + salesOrderList);
                    if (!salesOrderList.isEmpty()) {
                        conInfo.address = salesOrderList[0].ASI_CRM_CN_Address__c;
                        conInfo.otherRequirement = salesOrderList[0].ASI_CRM_CN_Other_Requirement__c;
                        conInfo.phone = salesOrderList[0].ASI_CRM_CN_Tel_Mobile__c;
                        // conInfo.orderStatus = ASI_CTY_CN_WS_Utils.STATUS_SOROPEN;
                    } else {
                        conInfo.address = customer.ASI_CRM_CN_Address__c;
                        conInfo.otherRequirement = null;
                    }
                }
                
            }
        }
        System.debug(LoggingLevel.INFO, '*** conInfo: ' + conInfo);
        return conInfo;

    }

    // Get contact id of current user
    public static Contact getContact() {
        final String userId = UserInfo.getUserId();
        final List <User> users = [SELECT Id, ContactId FROM User WHERE Id = :userId];
        System.debug(LoggingLevel.INFO, '*** users: ' + users);
        
        if (!users.isEmpty()) {
            List<Contact> contactList = [SELECT Name, Phone, Account.Name, AccountId
                                     FROM Contact 
                                     WHERE Id = :users[0].ContactId];
            System.debug(LoggingLevel.INFO, '*** contactList: ' + contactList);
            if (!contactList.isEmpty()) {
                return contactList[0];
            }
        }
        return null;
    }

    public class ContactInfo {
        @AuraEnabled
        public String orderId {get; set;}
        @AuraEnabled
        public String orderName {get; set;}
        @AuraEnabled
        public String orderStatus {get; set;}
        @AuraEnabled
        public Boolean hasOrderItems {get; set;}
        @AuraEnabled
        public Boolean hasMultipleOrders {get; set;}
        @AuraEnabled
        public String name {get; set;}
        @AuraEnabled
        public String phone {get; set;}
        @AuraEnabled
        public String address {get; set;}
        @AuraEnabled
        public String otherRequirement {get; set;}
        @AuraEnabled
        public String accountId;
        @AuraEnabled
        public String accountName {get; set;}
        @AuraEnabled
        public String currentDate {get; set;}
    }
}