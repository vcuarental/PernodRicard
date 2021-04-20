@isTest
private class ASI_CTY_CN_Vendor_UtilTest {
   
     @testSetup
    static void testDataPre() {
        UserRole r = new UserRole(DeveloperName = 'MyCustomRole', Name = 'My Role');
        insert r;
        Profile admin_p = [SELECT Id FROM Profile WHERE Name='System Administrator'];//System Administrator
        User adminUser = new User(Alias = 'admin', Email='adminuser@testorg.com', UserRoleId= r.Id,
                            EmailEncodingKey='UTF-8', LastName='admin', LanguageLocaleKey='zh_CN', Autofollow__c = false,
                            LocaleSidKey='zh_CN', ProfileId = admin_p.Id,IsActive = true,
                            TimeZoneSidKey='Asia/Shanghai', UserName='test2@wholesaler.com',
                            CompanyName = 'Pernod Ricard China');
        insert adminUser;
       
        System.runAs(adminUser) {
            Test.startTest();
            Account acc = new Account(Name = 'TestAccount', 
                                      RecordtypeId = Global_RecordTypeCache.getRtId('AccountASI_CRM_CN_Wholesales_CN'),
                                      ASI_KOR_Addr_Region__c = 'Central Region');
            insert acc;

            Contact con = new Contact(LastName = 'TestContact', 
                                    RecordtypeId = Global_RecordTypeCache.getRtId('ContactASI_CRM_CN_Wholesaler_Contact'),
                                    AccountId = acc.Id);
            insert con;

            Profile p2 = [SELECT Id FROM Profile WHERE Name='ASI_CTY_Wholesaler_CN_User'];//ASI_CTY_Wholesaler_CN_User
            User usr2 = new User(Alias = '经销商', Email='standarduser@testorg.com', 
                                EmailEncodingKey='UTF-8', LastName='经销商', LanguageLocaleKey='zh_CN', Autofollow__c = false,
                                LocaleSidKey='zh_CN', ProfileId = p2.Id, ContactId = con.Id,IsActive = true,
                                TimeZoneSidKey='Asia/Shanghai', UserName='test1@wholesaler.com',
                                CompanyName = 'Pernod Ricard China');
            insert usr2;
        }
           
    }

    static testMethod void testSalesOrderEdit() {
        User adminUser = [select id from User where UserName='test2@wholesaler.com' limit 1];
        System.runAs(adminUser) {
            Test.startTest();
            ASI_CTY_CN_Vendor_Util.getAccountId();
            Id recordTypeId = ASI_CTY_CN_Vendor_Util.quotationRecordId;
            recordTypeId = ASI_CTY_CN_Vendor_Util.mergeQuotationRecordId;
            recordTypeId = ASI_CTY_CN_Vendor_Util.quotationLineItemRecordId;
            recordTypeId = ASI_CTY_CN_Vendor_Util.prLineRecordId;
            recordTypeId = ASI_CTY_CN_Vendor_Util.buyerRecordId;
            recordTypeId = ASI_CTY_CN_Vendor_Util.supplierRecordId;
            recordTypeId = ASI_CTY_CN_Vendor_Util.poLineItemRecordId;
            recordTypeId = ASI_CTY_CN_Vendor_Util.itemGroupPhotoRecordId;
            recordTypeId = ASI_CTY_CN_Vendor_Util.itemGroupRecordId;
            String status = ASI_CTY_CN_Vendor_Util.PRLINE_STATUS_IN_DISTRIBUTION;
            status = ASI_CTY_CN_Vendor_Util.PRLINE_STATUS_ALLOCATED;
            status = ASI_CTY_CN_Vendor_Util.PRLINE_STATUS_REJECT;
            status = ASI_CTY_CN_Vendor_Util.PRLINE_STATUS_DRAFT;
            status = ASI_CTY_CN_Vendor_Util.PRLINE_STATUS_APPROVED;
            status = ASI_CTY_CN_Vendor_Util.PRLINE_STATUS_RECALL;
            status = ASI_CTY_CN_Vendor_Util.PRLINE_STATUS_SUBMITTED;
            status = ASI_CTY_CN_Vendor_Util.QUOTATION_STATUS_PENDING;
            status = ASI_CTY_CN_Vendor_Util.QUOTATION_STATUS_COMPLETED;
            status = ASI_CTY_CN_Vendor_Util.QUOTATION_STATUS_REJECTED;
            status = ASI_CTY_CN_Vendor_Util.QUOTATION_RESULT_STATUS_WIN_BID;
            status = ASI_CTY_CN_Vendor_Util.QUOTATION_RESULT_STATUS_FAIL_BID;
            status = ASI_CTY_CN_Vendor_Util.QUOTATION_RESULT_STATUS_ABANDON_BID;
            status = ASI_CTY_CN_Vendor_Util.QUOTATION_RESULT_STATUS_PENDING_CONFIRM;
            Test.stopTest();
        }
    }

}