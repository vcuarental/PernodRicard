@isTest
private class EUR_CRM_FI_TestUtilClass {
    static User eurSysUser;
    static EUR_CRM_Size__c bqs;
    static void setUser(){
        Profile p = [SELECT Id FROM Profile WHERE Name ='EUR System Admin']; 
        UserRole r = [select id from UserRole where Developername ='EMEA'];
        eurSysUser = new User(Alias = 'standt', Email='userEmail1234aoke@test.com', userroleid=r.id,
        EmailEncodingKey='UTF-8', LastName='userEmail1234aokelastName', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = p.Id, 
        TimeZoneSidKey='America/Los_Angeles', UserName='userEmail1234aoke@test.com');
        insert eurSysUser;
    }    
    /**
       EUR_CRM_FI_PublishObjectivePageCtrl
    */
    @IsTest
    private static void testFIUtilClass(){
        setUser();
        System.runAs(eurSysUser){
            Test.startTest();
             Id fiOnAccountRecordTypeId = [select id from RecordType where sobjecttype='eur_crm_account__C' and developername ='EUR_FI_Direct_On_Trade'].id;
            Id fiOnObjPromoRecordTypeId = [select id from RecordType where sobjecttype='EUR_CRM_ObjPromo__c' and developername ='EUR_FI_On_Trade_O_P'].id;
            Id fiCustomerTaxonomyRecordTypeId= EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_Customer_Taxonomy__c','EUR_FI_ON_Trade_Customer_Taxonomy');
            
            Id bqsRecordTypeId= EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_Size__c','EUR_FI_Size');
            
            EUR_CRM_Customer_Taxonomy__c custTax= new EUR_CRM_Customer_Taxonomy__c(recordtypeid = fiCustomerTaxonomyRecordTypeId,
            name = 'test');
            insert custTax;
            EUR_CRM_Account__c account = new EUR_CRM_Account__c(recordtypeid = fiOnAccountRecordTypeId,
            name = 'test',
            EUR_JB_Customer_Taxonomy__c = custTax.id, EUR_CRM_Postal_Code__c = '112233');
            insert account;
            bqs = new EUR_CRM_Size__c(recordtypeid=bqsRecordTypeId,name = 'testBQS');
            insert bqs;

            EUR_CRM_OP_Action_List_Template__c actionListTemplate = new EUR_CRM_OP_Action_List_Template__c(
                EUR_CRM_External_ID__c = 'FI_Type_02'
            );
            insert actionListTemplate;
            Test.stopTest();

            EUR_CRM_ObjPromo__c op = new EUR_CRM_ObjPromo__c(
                recordtypeid = fiOnObjPromoRecordTypeId,
                name = 'test op',
                EUR_CRM_Active_End_Date__c = system.today(),
                EUR_CRM_Active_Start_Date__c = system.today(),
                EUR_CRM_Status__c = 'Draft',
                eur_crm_product_hierarchy_Level__c = 'BQS',
                EUR_CRM_O_P_Type__c= 'Type 2',
                EUR_CRM_Account_Selection_Type__c = 'Customer Taxonomy'
            );
            insert op;
            EUR_CRM_OP_Customer_Taxonomy_Mapping__c mapping = new EUR_CRM_OP_Customer_Taxonomy_Mapping__c(
                EUR_CRM_Customer_Taxonomy__c = custTax.id,
                EUR_CRM_ObjPromo__c = op.id
            );
            
            insert mapping;
            
           
           List<EUR_CRM_Account__c> opAccounts = EUR_CRM_FI_UtilClass.retrieveOPAccounts(op, null, 'Name', 'ASC');
           
           system.assert(opAccounts != null);
           system.assert(opAccounts.get(0).id == account.id);
            
        }
    }

    @IsTest
    private static void retrieveOPAccountsTest(){
        setUser();
        System.runAs(eurSysUser){
            List<EUR_CRM_Account__c> opAccounts = EUR_CRM_FI_UtilClass.retrieveOPAccounts(null, null, 'Name', 'ASC');
            System.assertEquals(null, opAccounts);
        }
    }

    @IsTest
    private static void retrieveOPAccountsPROSTest(){
        setUser();
        System.runAs(eurSysUser){
            Test.startTest();
            Id fiOnAccountRecordTypeId = [select id from RecordType where sobjecttype='eur_crm_account__C' and developername ='EUR_FI_Direct_On_Trade'].id;
            Id fiOnObjPromoRecordTypeId = [select id from RecordType where sobjecttype='EUR_CRM_ObjPromo__c' and developername ='EUR_FI_On_Trade_O_P'].id;
            Id fiCustomerTaxonomyRecordTypeId= EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_Customer_Taxonomy__c','EUR_FI_ON_Trade_Customer_Taxonomy');

            Id bqsRecordTypeId= EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_Size__c','EUR_FI_Size');

            EUR_CRM_Customer_Taxonomy__c custTax= new EUR_CRM_Customer_Taxonomy__c(recordtypeid = fiCustomerTaxonomyRecordTypeId,
                name = 'test');
            insert custTax;
            EUR_CRM_Account__c account = new EUR_CRM_Account__c(recordtypeid = fiOnAccountRecordTypeId,
                name = 'test',
                EUR_JB_Customer_Taxonomy__c = custTax.id, EUR_CRM_Postal_Code__c = '112233');
            insert account;
            bqs = new EUR_CRM_Size__c(recordtypeid=bqsRecordTypeId,name = 'testBQS');
            insert bqs;

            EUR_CRM_OP_Action_List_Template__c actionListTemplate = new EUR_CRM_OP_Action_List_Template__c(
                EUR_CRM_External_ID__c = 'FI_Type_02'
            );
            insert actionListTemplate;
            Test.stopTest();

            EUR_CRM_ObjPromo__c op = new EUR_CRM_ObjPromo__c(
                recordtypeid = fiOnObjPromoRecordTypeId,
                name = 'test op',
                EUR_CRM_Active_End_Date__c = system.today(),
                EUR_CRM_Active_Start_Date__c = system.today(),
                EUR_CRM_Status__c = 'Draft',
                eur_crm_product_hierarchy_Level__c = 'BQS',
                EUR_CRM_O_P_Type__c= 'Type 2',
                EUR_CRM_Account_Selection_Type__c = 'PROS'
            );
            insert op;
            EUR_CRM_OP_Customer_Taxonomy_Mapping__c mapping = new EUR_CRM_OP_Customer_Taxonomy_Mapping__c(
                EUR_CRM_Customer_Taxonomy__c = custTax.id,
                EUR_CRM_ObjPromo__c = op.id
            );

            insert mapping;


            List<EUR_CRM_Account__c> opAccounts = EUR_CRM_FI_UtilClass.retrieveOPAccounts(op, null, 'Name', 'ASC');

            System.assertEquals(0, opAccounts.size());

        }
    }

    @IsTest
    private static void retrieveContractProductLineItemsTest() {
        EUR_CRM_Account__c account = new EUR_CRM_Account__c(Name = 'Account', EUR_CRM_Postal_Code__c = '112233');
        insert account;

        EUR_CRM_Contract__c contract = new EUR_CRM_Contract__c(EUR_CRM_Account__c = account.Id);
        insert contract;

        EUR_CRM_Mechanic_Type__c mechanicType = new EUR_CRM_Mechanic_Type__c(Name = 'MT');
        insert mechanicType;

        EUR_CRM_Contract_Activity_Item__c contractActivityItem = new EUR_CRM_Contract_Activity_Item__c(EUR_CRM_Contract__c = contract.Id, EUR_CRM_Mechanic_Type__c = mechanicType.Id);
        insert contractActivityItem;

        EUR_CRM_Contract_Product_Item__c contractProductItem = new EUR_CRM_Contract_Product_Item__c(EUR_CRM_Contract_Activity_Item__c = contractActivityItem.Id);
        insert contractProductItem;

        Test.startTest();
        Map<Id, List<EUR_CRM_Contract_Product_Item__c>> productItemByMechanicTypeId = EUR_CRM_FI_UtilClass.retrieveContractProductLineItems(contract.Id);
        Test.stopTest();

        System.assertNotEquals(0, productItemByMechanicTypeId.size());
    }

    @IsTest
    private static void retrieveOwnersTest() {
        EUR_CRM_Account__c account = new EUR_CRM_Account__c(Name = 'Account', EUR_CRM_Postal_Code__c = '112233');
        insert account;

        List<EUR_CRM_Account__c> accounts = [SELECT Id, OwnerId FROM EUR_CRM_Account__c];
        Test.startTest();
        List<User> owners = EUR_CRM_FI_UtilClass.retrieveOwners(accounts);
        Test.stopTest();

        System.assertNotEquals(0, owners.size());
    }

    @IsTest
    private static void getThousandSepTest() {
        Test.startTest();
        String result = EUR_CRM_FI_UtilClass.getThousandSep();
        Test.stopTest();

        System.assertNotEquals(null, result);
    }

    @IsTest
    private static void getDecimalSepTest() {
        Test.startTest();
        String result = EUR_CRM_FI_UtilClass.getDecimalSep();
        Test.stopTest();

        System.assertNotEquals(null, result);
    }
    
}