@isTest
public class ASI_CRM_JP_UtilityServiceTest {

    @isTest
    static void t1() {
        RecordType rt = [SELECT Id, Name, DeveloperName, SobjectType
        FROM RecordType
        WHERE DeveloperName = 'ASI_CRM_JP_Direct_Rebate_Contract'];
        RecordType rtrn = [SELECT Id, Name, DeveloperName, SobjectType
        FROM RecordType
        WHERE DeveloperName = 'ASI_CN_Running_Number'];

        ASI_HK_CRM_Running_Number__c rn = new ASI_HK_CRM_Running_Number__c();
        rn.ASI_HK_CRM_Object_Name__c = 'ASI_CRM_JP_PaymentInvoice_No';
        rn.ASI_HK_CRM_Running_Number__c = 100;
        rn.RecordTypeId = rtrn.Id;
        rn.ASI_HK_CRM_First_Month_of_Fiscal_Year__c = 1;
        rn.ASI_HK_CRM_Fiscal_Year__c = 2019;
        rn.ASI_HK_CRM_Format__c = '4{YY}{00000}';
        insert rn;
    }

    @isTest
    static void testGetObjectPropertySet() {
        final List<Account> accounts = new List<Account>();
        accounts.add(new Account (Name = 'Test 1'));
        accounts.add(new Account (Name = 'Test 2'));
        accounts.add(new Account (Name = 'Test 3'));
        
        final Set<String> accountNames = ASI_CRM_JP_UtilityService.getObjectPropertySet(accounts, Account.Name);
        
        System.assertNotEquals(null, accountNames);
        System.assertEquals(3, accountNames.size());
    }
    
    @isTest
    static void testGetObjectPropertyList() {
        final List<Account> accounts = new List<Account>();
        accounts.add(new Account (Name = 'Test 1'));
        accounts.add(new Account (Name = 'Test 2'));
        accounts.add(new Account (Name = 'Test 3'));
        
        final List<String> accountNames = ASI_CRM_JP_UtilityService.getObjectPropertyList(accounts, Account.Name);
        
        System.assertNotEquals(null, accountNames);
        System.assertEquals(3, accountNames.size());
        System.assertEquals('Test 1', accountNames.get(0));
    }
    
    @isTest
    static void testmethod1() {
        Account accountrec = new Account(name = 'Test');
        Schema.DescribeFieldResult F = Account.Industry.getDescribe();
        Schema.sObjectField T = F.getSObjectField();
        List<sObject> objects = new List<sObject>();
        objects.add(accountrec);
        insert objects;
        Set<String> setString = new Set<String>();
        User u = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id,
            LastName = 'last',
            Email = 'puser000@amamama.com',
            Username = 'puser000@amamama.com' + System.currentTimeMillis(),
            CompanyName = 'TEST',
            Title = 'title',
            Alias = 'alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
          ASI_TnE_Sub_Ledger__c = 'test'
        );
        insert u;
        setString.add(u.ASI_TnE_Sub_Ledger__c);
        
        RecordType rt = [SELECT Id, Name, DeveloperName, SobjectType 
                         FROM RecordType 
                         WHERE DeveloperName = 'ASI_CRM_JP_Direct_Rebate_Contract'];
    RecordType rtrn = [SELECT Id, Name, DeveloperName, SobjectType 
                           FROM RecordType 
                           WHERE DeveloperName = 'ASI_CN_Running_Number'];
        
        ASI_HK_CRM_Running_Number__c rn = new ASI_HK_CRM_Running_Number__c();
        rn.ASI_HK_CRM_Object_Name__c = 'ASI_CRM_JP_Contract_Rebate_No';
        rn.ASI_HK_CRM_Running_Number__c = 100;
        rn.RecordTypeId = rtrn.Id;
        rn.ASI_HK_CRM_First_Month_of_Fiscal_Year__c = 1;
        rn.ASI_HK_CRM_Fiscal_Year__c = 2019;
        rn.ASI_HK_CRM_Format__c = '4{YY}{00000}';
        insert rn;
        
        ASI_CRM_Purchase_Contract__c purchaseContract = new ASI_CRM_Purchase_Contract__c();
        purchaseContract.RecordTypeId = rt.Id;
        purchaseContract.ASI_CRM_Fixed_Spot__c = 'Spot';
        purchaseContract.ASI_CRM_End_Date__c = Date.newInstance(2019, 02, 05);
        insert purchaseContract;
        Set<Id> idsetpc = new Set<Id>();
        idsetpc.add(purchaseContract.Id);
        Schema.SObjectType accountType = Schema.Account.sObjectType;
        
        Set<Id> idset = new Set<Id>();
        List<ASI_CRM_JP_Item_Availability__c> lstit = new List<ASI_CRM_JP_Item_Availability__c>();
        ASI_CRM_JP_Item_Availability__c itrec = new ASI_CRM_JP_Item_Availability__c();
        insert itrec;
        lstit.add(itrec);
        idset.add(itrec.Id);
        
        ASI_CRM_JP_UtilityService.getObjectIdPropertySet(objects, T);
        ASI_CRM_JP_UtilityService.getObjectIdPropertyList(objects, T);
        ASI_CRM_JP_UtilityService.getObjectPropertyList(objects, T);
        ASI_CRM_JP_UtilityService.getCurrentFiscalYear();
        ASI_CRM_JP_UtilityService.getDateBasedOnFiscalYear(system.today(), system.today().addDays(30), true);
        ASI_CRM_JP_UtilityService.isLeapYear(system.today());
        ASI_CRM_JP_UtilityService.isLeapYear(2019);
        ASI_CRM_JP_UtilityService.isLeapYearDate(system.today());
    }
    
    @isTest
    static void method2() {
    Set<Id> idset = new Set<Id>();
        List<ASI_CRM_JP_Item_Availability__c> lstit = new List<ASI_CRM_JP_Item_Availability__c>();
        ASI_CRM_JP_Item_Availability__c itrec = new ASI_CRM_JP_Item_Availability__c();
        insert itrec;
        lstit.add(itrec);
        idset.add(itrec.Id);
        
        ASI_CRM_JP_UtilityService.getItemAvailabilityListByIds(idset);
        ASI_CRM_JP_UtilityService.getItemAvailabilityMap(lstit);
    }
    
    @isTest
    static void method3() {
        Set<String> setString = new Set<String>();
        User u = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id,
            LastName = 'last',
            Email = 'puser000@amamama.com',
            Username = 'puser000@amamama.com' + System.currentTimeMillis(),
            CompanyName = 'TEST',
            Title = 'title',
            Alias = 'alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
          ASI_TnE_Sub_Ledger__c = 'test'
        );
        insert u;
        setString.add(u.ASI_TnE_Sub_Ledger__c);
        
        ASI_CRM_JP_UtilityService.getStaffCodeUserMap(setString);
        ASI_CRM_JP_UtilityService.getUsersByStaffCodes(setString);
    }
    
    @isTest
    static void method4() {
        RecordType rt = [SELECT Id, Name, DeveloperName, SobjectType 
                         FROM RecordType 
                         WHERE DeveloperName = 'ASI_CRM_JP_Direct_Rebate_Contract'];
        
        ASI_HK_CRM_Running_Number__c contractAutoNumber = new ASI_HK_CRM_Running_Number__c(
            ASI_HK_CRM_Object_Name__c = 'ASI_CRM_JP_Contract_No',
            ASI_HK_CRM_Running_Number__c = 0,
            ASI_HK_CRM_Format__c = 'R{YY}{00000}'
        );

        ASI_HK_CRM_Running_Number__c contractAutoNumberRebate = new ASI_HK_CRM_Running_Number__c(
            ASI_HK_CRM_Object_Name__c = 'ASI_CRM_JP_Contract_Rebate_No',
            ASI_HK_CRM_Running_Number__c = 0,
            ASI_HK_CRM_Format__c = '4{YY}{00000}'
        );

        insert new List<ASI_HK_CRM_Running_Number__c> {contractAutoNumber, contractAutoNumberRebate};
        
        ASI_CRM_Purchase_Contract__c purchaseContract = new ASI_CRM_Purchase_Contract__c();
        purchaseContract.RecordTypeId = rt.Id;
        purchaseContract.ASI_CRM_Fixed_Spot__c = 'Spot';
        purchaseContract.ASI_CRM_End_Date__c = Date.newInstance(2019, 02, 05);
        insert purchaseContract;
        Set<Id> idsetpc = new Set<Id>();
        idsetpc.add(purchaseContract.Id);
        Schema.SObjectType accountType = Schema.Account.sObjectType;
        
        ASI_CRM_JP_UtilityService.generateQuerySelectFields(accountType);
        ASI_CRM_JP_UtilityService.findPurchaseContractByIds(idsetpc);
    }
}