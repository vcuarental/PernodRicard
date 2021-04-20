@isTest
private class ASI_CTY_CN_Vendor_ComDashboardCtrlTest {
   
    @testSetup
    static void testDataPre() {
        UserRole r = [SELECT Id FROM UserRole WHERE DeveloperName = 'ASI_CN'];
        Profile admin_p = [SELECT Id FROM Profile WHERE Name='System Administrator'];//System Administrator
        User adminUser = new User(Alias = 'admin', Email='adminuser@testorg.com', UserRoleId= r.Id,
                            EmailEncodingKey='UTF-8', LastName='admin', LanguageLocaleKey='zh_CN', Autofollow__c = false,
                            LocaleSidKey='zh_CN', ProfileId = admin_p.Id,IsActive = true,
                            TimeZoneSidKey='Asia/Shanghai', UserName='test2@wholesaler.com',
                            CompanyName = 'Pernod Ricard China');
        insert adminUser;
        Account acc = null;
       
        System.runAs(adminUser) {
            Test.startTest();
            acc = new Account(Name = 'TestAccount', 
                                      RecordtypeId = Global_RecordTypeCache.getRtId('AccountASI_MFM_CN_Supplier'),
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
            Id strRTId = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_CN_Prefix');
            ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO', recordTypeId=strRTID,
                                                         ASI_MFM_Fiscal_year__c='FY1314', ASI_MFM_Next_Number__c=86);
            insert px;


            ASI_MFM_Role_Prefix_Relationship__c prefixRelationShip = new ASI_MFM_Role_Prefix_Relationship__c();
            prefixRelationShip.ASI_MFM_Prefix__c = px.Id;
            prefixRelationShip.ASI_MFM_Role_Name__c = 'ASI_CN';
            insert prefixRelationShip;

            ASI_MFM_Prefix__c px1 = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', recordTypeId=strRTID,
                                                         ASI_MFM_Fiscal_year__c='FY1314', ASI_MFM_Next_Number__c=86);
            insert px1;
        

            ASI_MFM_Role_Prefix_Relationship__c prefixRelationShip1 = new ASI_MFM_Role_Prefix_Relationship__c();
            prefixRelationShip1.ASI_MFM_Prefix__c = px1.Id;
            prefixRelationShip1.ASI_MFM_Role_Name__c = 'ASI_CN';
            insert prefixRelationShip1;

            System.debug(LoggingLevel.INFO, '*** px.OwnerId: ' + px.Owner.Name);
            ASI_MFM_Plan__c p = new ASI_MFM_Plan__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_HK_Plan'), name='test',
            ASI_MFM_End_Date__c = Date.today().addMonths(1), ASI_MFM_Plan_Description__c = 'testDescription', 
                ASI_MFM_Plan_Name__c = 'planName test', ASI_MFM_Start_Date__c = Date.today(),  ASI_MFM_Prefix__c=px1.id, ASI_MFM_Status__c = 'Final');
            insert p; 

            ASI_MFM_PO__c po = ASI_CRM_PH_Testfactory.createPO();
            po.recordTypeId = Global_RecordTypeCache.getRTId('ASI_MFM_PO__cASI_MFM_CN_PO');
            po.ASI_MFM_Supplier_Name__c = acc.Id;
            po.ASI_MFM_PO_Start_Date__c=Date.valueof('2014-04-01');
            po.ASI_MFM_PO_End_Date__c=Date.valueof('2014-04-30');
            po.ASI_MFM_PO_Type__c = 'eMarket';
            po.ASI_MFM_Prefix__c = px.id;
            po.ASI_MFM_Plan__c = p.Id;
            insert po;
        }

       
           
           
    }

    static testMethod void testSalesOrderEdit() {
        User adminUser = [select id from User where UserName='test2@wholesaler.com' limit 1];
        System.runAs(adminUser) {
            Test.startTest();
            ASI_CTY_CN_Vendor_ComDashboardCtrl.getPoDataCount('1');
            ASI_CTY_CN_Vendor_ComDashboardCtrl.getPoDataCount('2');
            Test.stopTest();
        }
    }
}