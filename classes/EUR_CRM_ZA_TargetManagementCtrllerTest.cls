@isTest
private class EUR_CRM_ZA_TargetManagementCtrllerTest {
    
    static User eurSysUser;
    static EUR_CRM_Size__c bqs;
    
    static void setUser() {
        Profile p = [SELECT Id FROM Profile WHERE Name= 'EUR System Admin'];
        UserRole r = [select id from UserRole where Developername ='EMEA'];
        eurSysUser = new User(Alias = 'standt', Email='userEmail1234aoke@test.com', userroleid=r.id,
        EmailEncodingKey='UTF-8', LastName='userEmail1234aokelastName', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = p.Id, 
        TimeZoneSidKey='America/Los_Angeles', UserName='userEmail1234aoke@test.com');
        insert eurSysUser;
    }
    
    static testMethod void testManagePage() {
        setUser();
        System.runAs(eurSysUser) {
            Id ZAOnTradeAccountRecordTypeId = [SELECT Id FROM RecordType WHERE sObjectType = 'EUR_CRM_Account__c' AND DeveloperName = 'EUR_ZA_On_Trade_Direct'].Id;
            Id ZAOnObjPromoRecordTypeId = [SELECT Id FROM RecordType WHERE sObjectType = 'EUR_CRM_ObjPromo__c' AND DeveloperName = 'EUR_ZA_Off_Trade_Promotion'].Id;
            
            Id bqsRecordTypeId = EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_Size__c', 'EUR_ZA_Size');
            bqs = new EUR_CRM_Size__c(recordTypeId = bqsRecordTypeId, name = 'testBQS');
            insert bqs;
            
            //Id bqRecordTypeId = EUR_CRM_TestClassUtilityHelper.getRecordTypeId()
            
            EUR_CRM_DE_TestClassUtilityHelper.creaActionListTemplate('Test O/P Action List Template', 'ZA_OFF_ALT_Promo', 'ZA O/P Action List Template');
            
            EUR_CRM_ObjPromo__c op = new EUR_CRM_ObjPromo__c(
                recordTypeId = ZAOnObjPromoRecordTypeId,
                Name = 'Test OP',
                EUR_CRM_Active_End_Date__c = System.today(),
                EUR_CRM_Active_Start_Date__c = System.today(),
                EUR_CRM_Status__c = 'Draft'
            );
            insert op;
            
            Test.startTest();
            
            PageReference pageRef = Page.EUR_CRM_ZA_TargetManagementPage;
            pageRef.getParameters().put('Id', op.Id);
            Test.setCurrentPage(pageRef);
            
            ApexPages.StandardController sc = new ApexPages.StandardController(op);
            EUR_CRM_ZA_TargetManagementController con = new EUR_CRM_ZA_TargetManagementController(sc);
            
            op.EUR_CRM_Product_Hierarchy_Level__c = 'BQS';
            
            // Add BQS
            pageRef.getParameters().put('p1', bqs.Id);
            con.add();
            
            // Quicksave
            con.quicksave();
            List<EUR_CRM_ObjPromo_Target__c> savedTargets = [SELECT Id FROM EUR_CRM_ObjPromo_Target__c];
            System.assertEquals(con.targets.size(), savedTargets.size());
                        
            // Remove BQS
            pageRef.getParameters().put('rowIndex', '1');
            con.removeBQS();
            
            // quicksave + cancel operation
            con.save();
            
            Test.stopTest();
        }
    }
}