@isTest
public class ASI_CRM_JP_PurchaseContractServiceTest {
    
    //   @testSetup
    //   static void setup() {
    /*
final ASI_CRM_Purchase_Contract__c purchaseContract = new ASI_CRM_Purchase_Contract__c();

final List<ASI_CRM_Purchase_Contract__c> purchaseContracts = new List<ASI_CRM_Purchase_Contract__c>();
purchaseContracts.add(purchaseContract);

insert purchaseContracts;

final List<ASI_CRM_Purchase_Contract_Line_Item__c> purhcaseContractItems = 
new List<ASI_CRM_Purchase_Contract_Line_Item__c>();

purhcaseContractItems.add(new ASI_CRM_Purchase_Contract_Line_Item__c (

));

insert purhcaseContractItems;
*/
    //   }
    
    @isTest
    static void testCloneAll() {
        /*
final ASI_CRM_Purchase_Contract_Line_Item__c reportSearchForm = new ASI_CRM_Purchase_Contract_Line_Item__c();
final ASI_CRM_JP_PurchaseContractService.ReportParameters reportParameters =
new ASI_CRM_JP_PurchaseContractService.ReportParameters();
final String batchId = '';

ASI_CRM_JP_PurchaseContractService.cloneAll(reportSearchForm, reportParameters, batchId);
*/
    }
    
    @isTest
    static void testGetOldNewPurchaseContractIdMap() {
        final List<ASI_CRM_Purchase_Contract__c> clonedPurchaseContracts
            = new List<ASI_CRM_Purchase_Contract__c>();
        final Map<Id, Id> oldNewPurchaseContractIdMap = 
            ASI_CRM_JP_PurchaseContractService.getOldNewPurchaseContractIdMap(
                clonedPurchaseContracts
            );
    }
    
    @isTest
    static void testGetPurchaseContractsToClone1() {
        final Set<Id> purchaseContractIds = new Set<Id>();
        
        final List<ASI_CRM_Purchase_Contract__c> purchaseContractsToClone = 
            ASI_CRM_JP_PurchaseContractService.getPurchaseContractsToClone(purchaseContractIds);
    }
    
    @isTest
    static void testGetPurchaseContractLineItemsToClone() {
        final Set<Id> allPurchaseContractLineIds = new Set<Id>();
        final List<ASI_CRM_Purchase_Contract_Line_Item__c> purchaseContractLineItemsToClone = 
            ASI_CRM_JP_PurchaseContractService.getPurchaseContractLineItemsToClone(allPurchaseContractLineIds);
    }
    
    @isTest
    static void testUpdateContractLineItems() {
        final List<List<String>> csvRows = new List<List<String>>();
        /*list<String> csvrows1 = new List<String>();
String csvstring = 'Test';
csvrows1.add(csvstring);
csvRows.add(csvRows1);
//Map<String, Integer> mapstst= new Map<String, Integer>{HEADER_PURCHASE_CONTRACT_LINE_ITEM_NAME => 1};
// ASI_CRM_JP_PurchaseContractService.csvColumnHeaderIndexMap.put();*/
        final List<Database.SaveResult> results = ASI_CRM_JP_PurchaseContractService.updateContractLineItems(
            csvRows
        );
    }
    
    @isTest
    static void testGetPurchaseContractRecordTypesToExclude() {
        ASI_CRM_JP_PurchaseContractService.getPurchaseContractRecordTypesToExclude();
    }
    
    @isTest
    static void testUpdatePurchaseContractStatusOwner() {
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
        
        ASI_CRM_Pay_To__c customer = new ASI_CRM_Pay_To__c(Name = 'test', RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Pay_To__cASI_CRM_JP_Pay_To'),ASI_CRM_Active__c=true);
        insert customer;
        ASI_MFM_Item_Group__c itemGroup = new ASI_MFM_Item_Group__c(Name = 'Test', ASI_CRM_Lowest_1__c = 100, ASI_CRM_Lowest_2__c = 100, recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Item_Group__cASI_CRM_JP_Item_Group'));
        insert itemGroup;
        ASI_CRM_Purchase_Contract__c purchaseContract = new ASI_CRM_Purchase_Contract__c();
        purchaseContract.RecordTypeId = rt.Id;
        purchaseContract.ASI_CRM_Fixed_Spot__c = 'Spot';
        purchaseContract.ASI_CRM_End_Date__c = Date.newInstance(2019, 02, 05);
        insert purchaseContract;
        Set<Id> idsetpc = new Set<Id>();
        idsetpc.add(purchaseContract.Id);
        
        final List<ASI_CRM_Purchase_Contract_Line_Item__c> purchaseContractItems = 
            new List<ASI_CRM_Purchase_Contract_Line_Item__c>();
        
        ASI_CRM_Purchase_Contract_Line_Item__c line1 = new ASI_CRM_Purchase_Contract_Line_Item__c(ASI_CRM_Purchase_Contract__c = purchaseContract.Id, ASI_CRM_Item_Group__c = itemGroup.Id, ASI_CRM_Pay_To__c = customer.Id, RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Purchase_Contract_Line_Item__cASI_CRM_JP_Direct_Rebate_Contract_Line_Item'), ASI_CRM_Unit_Price__c  = 100, ASI_CRM_Rebate_Type__c = '08 - Direct Supporting', ASI_CRM_Quantity__c = 100, ASI_CRM_Target_Volume__c = 10000,ASI_CRM_Cancel__c = true);
        
        purchaseContractItems.add(line1);
        insert purchaseContractItems;
        
        
        
        ASI_CRM_JP_PurchaseContractService.updatePurchaseContractStatusOwner(
            purchaseContractItems
        );
    }
    
    @isTest
    static void testGetCanceledPurchaseContractIds() {
        final List<ASI_CRM_Purchase_Contract_Line_Item__c> purchaseContractItems = 
            new List<ASI_CRM_Purchase_Contract_Line_Item__c>();
        
        final Set<Id> canceledPurchaseContractIds = 
            ASI_CRM_JP_PurchaseContractService.getCanceledPurchaseContractIds(purchaseContractItems);
    }
    
    @isTest 
    static void testGetPurchaseContractOwnerIdMap() {
        final List<ASI_CRM_Purchase_Contract_Line_Item__c> purchaseContractItems = 
            new List<ASI_CRM_Purchase_Contract_Line_Item__c>();
        
        final Map<Id, Id> purchaseContractOwnerIdMap = 
            ASI_CRM_JP_PurchaseContractService.getPurchaseContractOwnerIdMap(purchaseContractItems);
    }
    
    @isTest (seeAllData=true)
    static void testGetContractLineItemIdsFromReport() {
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
        system.debug('----rn---'+rn);
        //  insert rn;
        
        RecordType rtap = [SELECT Id, Name, DeveloperName, SobjectType FROM RecordType WHERE DeveloperName = 'ASI_CRM_JP_AP_Code'];
        
        ASI_MFM_AP_Code__c apcode = new ASI_MFM_AP_Code__c();
        apcode.RecordTypeId = rtap.Id;
        insert apcode;
        
        RecordType rtig = [SELECT Id, Name, DeveloperName, SobjectType FROM RecordType WHERE Name = 'JP CRM Item Group'];
        
        ASI_MFM_Item_Group__c ig = new ASI_MFM_Item_Group__c();
        ig.name = 'Test';
        ig.RecordTypeId = rtig.Id;
        insert ig;
        
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
         ASI_TH_CRM_OutletType__c outletType = ASI_CRM_JP_TestClassHelper.createOutletType('Test0');
        ASI_CRM_Postal_Code__c postalCode = ASI_CRM_JP_TestClassHelper.createPostalCode('0000000');
        ASI_CRM_AccountsAdditionalField__c customer2 = new ASI_CRM_AccountsAdditionalField__c(Name='Test0', RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_JP_Off_Trade_Outlet'), ASI_TH_CRM_OutletType__c = outletType.Id, ASI_CRM_PostalCode__c = postalCode.Name);
        insert customer2;
        
        delete [select id from ASI_HK_CRM_Running_Number__c where ASI_HK_CRM_Object_Name__c='ASI_CRM_JP_Contract_No' or ASI_HK_CRM_Object_Name__c='ASI_CRM_JP_Contract_Rebate_No'];
        
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
        purchaseContract.ASI_CRM_BS_Retailer_Ship_To__c = customer2.Id;
        purchaseContract.OwnerId = u.Id;
        insert purchaseContract;
        
        ASI_CRM_Pay_To__c pay2C = 
            new ASI_CRM_Pay_To__c(
                Name = 'test', 
                RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Pay_To__cASI_CRM_JP_Pay_To'),
                ASI_CRM_Active__c=true);
        insert pay2C;
        
        ASI_CRM_Purchase_Contract_Line_Item__c purchaseContractLineItem = new ASI_CRM_Purchase_Contract_Line_Item__c();
        purchaseContractLineItem.ASI_CRM_AP_Code__c = apcode.Id;
        purchaseContractLineItem.ASI_CRM_Item_Group__c = ig.Id;
        purchaseContractLineItem.ASI_CRM_Payment_Method__c = 'Gift Coupon';
        purchaseContractLineItem.ASI_CRM_Condition_Of__c = 2;
        purchaseContractLineItem.ASI_CRM_Condition_To__c = 2;
        purchaseContractLineItem.ASI_CRM_Target_Volume__c = 5;
        purchaseContractLineItem.ASI_CRM_Unit_Price__c = 100;
        purchaseContractLineItem.ASI_CRM_Rebate_Type__c = '  04 - Indirect Special Spot';
        purchaseContractLineItem.ASI_CRM_Quantity__c = 2;
        //purchaseContractLineItem.ASI_CRM_Pay_To__c = purchaseContractItems[0].id;
        purchaseContractLineItem.ASI_CRM_Purchase_Contract__c = purchaseContract.Id;
        purchaseContractLineItem.ASI_CRM_Condition_To__c = 2;
        purchaseContractLineItem.ASI_CRM_Condition_Of__c = 2;
        purchaseContractLineItem.RecordTypeId = 
            Global_RecordTypeCache.getRtId('ASI_CRM_Purchase_Contract_Line_Item__cASI_CRM_JP_Direct_Rebate_Contract_Line_Item');
        purchaseContractLineItem.ASI_CRM_Pay_To__c = pay2C.Id;
        insert purchaseContractLineItem;
        
        List<ASI_CRM_Purchase_Contract_Line_Item__c> lst = new List<ASI_CRM_Purchase_Contract_Line_Item__c>();
        for(integer i = 0; i < 71; i++)
        {
            ASI_CRM_Purchase_Contract_Line_Item__c purchaseContractLineItem2 = new ASI_CRM_Purchase_Contract_Line_Item__c();
            purchaseContractLineItem2.ASI_CRM_AP_Code__c = apcode.Id;
            purchaseContractLineItem2.ASI_CRM_Item_Group__c = ig.Id;
            purchaseContractLineItem2.ASI_CRM_Payment_Method__c = 'Gift Coupon';
            purchaseContractLineItem2.ASI_CRM_Condition_Of__c = 2;
            purchaseContractLineItem2.ASI_CRM_Condition_To__c = 2;
            purchaseContractLineItem2.ASI_CRM_Target_Volume__c = 5;
            purchaseContractLineItem2.ASI_CRM_Unit_Price__c = 100;
            purchaseContractLineItem2.ASI_CRM_Rebate_Type__c = '  04 - Indirect Special Spot';
            purchaseContractLineItem2.ASI_CRM_Quantity__c = 2;
            //purchaseContractLineItem.ASI_CRM_Pay_To__c = purchaseContractItems[0].id;
            purchaseContractLineItem2.ASI_CRM_Purchase_Contract__c = purchaseContract.Id;
            purchaseContractLineItem2.ASI_CRM_Condition_To__c = 2;
            purchaseContractLineItem2.ASI_CRM_Condition_Of__c = 2;
            purchaseContractLineItem2.RecordTypeId = 
              Global_RecordTypeCache.getRtId('ASI_CRM_Purchase_Contract_Line_Item__cASI_CRM_JP_Direct_Rebate_Contract_Line_Item');
            purchaseContractLineItem2.ASI_CRM_Pay_To__c = pay2C.Id;
            lst.add(purchaseContractLineItem2);
        }
        insert lst;
            
        final ASI_CRM_JP_PurchaseContractService.ReportParameters reportParameters = 
            new ASI_CRM_JP_PurchaseContractService.ReportParameters();
        reportParameters.itemGroupName = ig.name;
        reportParameters.shipToName = 'Test';
        reportParameters.startDate = system.today();
        reportParameters.endToDate = system.today().adddays(30);
        reportParameters.endDate = system.today().adddays(30);
        reportParameters.recordTypeName = 'Test';
        reportParameters.salesGroup = 'Test';
        reportParameters.status = 'Test';
        reportParameters.isEffective = true;
        reportParameters.ownerName = 'Test';
        
        
        
        
        System.debug('---reportParameters---'+reportParameters);
        ASI_CRM_JP_PurchaseContractService.cloneAll(purchaseContractLineItem, reportParameters, 'batchId');
        
    }
    
    @isTest (seeAllData=true)
    static void testGetContractLineItemIdsFromReport1() {
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
        system.debug('----rn---'+rn);
        //  insert rn;
        
        RecordType rtap = [SELECT Id, Name, DeveloperName, SobjectType FROM RecordType WHERE DeveloperName = 'ASI_CRM_JP_AP_Code'];
        
        ASI_MFM_AP_Code__c apcode = new ASI_MFM_AP_Code__c();
        apcode.RecordTypeId = rtap.Id;
        insert apcode;
        
        RecordType rtig = [SELECT Id, Name, DeveloperName, SobjectType FROM RecordType WHERE Name = 'JP CRM Item Group'];
        
        ASI_MFM_Item_Group__c ig = new ASI_MFM_Item_Group__c();
        ig.name = 'Test';
        ig.RecordTypeId = rtig.Id;
        insert ig;
        
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
         ASI_TH_CRM_OutletType__c outletType = ASI_CRM_JP_TestClassHelper.createOutletType('Test0');
        ASI_CRM_Postal_Code__c postalCode = ASI_CRM_JP_TestClassHelper.createPostalCode('0000000');
        ASI_CRM_AccountsAdditionalField__c customer2 = new ASI_CRM_AccountsAdditionalField__c(Name='Test0', RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_JP_Off_Trade_Outlet'), ASI_TH_CRM_OutletType__c = outletType.Id, ASI_CRM_PostalCode__c = postalCode.Name);
        insert customer2;
        
        delete [select id from ASI_HK_CRM_Running_Number__c where ASI_HK_CRM_Object_Name__c='ASI_CRM_JP_Contract_No' or ASI_HK_CRM_Object_Name__c='ASI_CRM_JP_Contract_Rebate_No'];
        
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
        purchaseContract.ASI_CRM_BS_Retailer_Ship_To__c = customer2.Id;
        purchaseContract.OwnerId = u.Id;
        insert purchaseContract;
        
        ASI_CRM_Pay_To__c pay2C = 
            new ASI_CRM_Pay_To__c(
                Name = 'test', 
                RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Pay_To__cASI_CRM_JP_Pay_To'),
                ASI_CRM_Active__c=true);
        insert pay2C;
        
        ASI_CRM_Purchase_Contract_Line_Item__c purchaseContractLineItem = new ASI_CRM_Purchase_Contract_Line_Item__c();
        purchaseContractLineItem.ASI_CRM_AP_Code__c = apcode.Id;
        purchaseContractLineItem.ASI_CRM_Item_Group__c = ig.Id;
        purchaseContractLineItem.ASI_CRM_Payment_Method__c = 'Gift Coupon';
        purchaseContractLineItem.ASI_CRM_Condition_Of__c = 2;
        purchaseContractLineItem.ASI_CRM_Condition_To__c = 2;
        purchaseContractLineItem.ASI_CRM_Target_Volume__c = 5;
        purchaseContractLineItem.ASI_CRM_Unit_Price__c = 100;
        purchaseContractLineItem.ASI_CRM_Rebate_Type__c = '  04 - Indirect Special Spot';
        purchaseContractLineItem.ASI_CRM_Quantity__c = 2;
        //purchaseContractLineItem.ASI_CRM_Pay_To__c = purchaseContractItems[0].id;
        purchaseContractLineItem.ASI_CRM_Purchase_Contract__c = purchaseContract.Id;
        purchaseContractLineItem.ASI_CRM_Condition_To__c = 2;
        purchaseContractLineItem.ASI_CRM_Condition_Of__c = 2;
        purchaseContractLineItem.RecordTypeId = 
            Global_RecordTypeCache.getRtId('ASI_CRM_Purchase_Contract_Line_Item__cASI_CRM_JP_Direct_Rebate_Contract_Line_Item');
        purchaseContractLineItem.ASI_CRM_Pay_To__c = pay2C.Id;
        insert purchaseContractLineItem;
        
        List<ASI_CRM_Purchase_Contract_Line_Item__c> lst = new List<ASI_CRM_Purchase_Contract_Line_Item__c>();
        for(integer i = 0; i < 71; i++)
        {
            ASI_CRM_Purchase_Contract_Line_Item__c purchaseContractLineItem2 = new ASI_CRM_Purchase_Contract_Line_Item__c();
            purchaseContractLineItem2.ASI_CRM_AP_Code__c = apcode.Id;
            purchaseContractLineItem2.ASI_CRM_Item_Group__c = ig.Id;
            purchaseContractLineItem2.ASI_CRM_Payment_Method__c = 'Gift Coupon';
            purchaseContractLineItem2.ASI_CRM_Condition_Of__c = 2;
            purchaseContractLineItem2.ASI_CRM_Condition_To__c = 2;
            purchaseContractLineItem2.ASI_CRM_Target_Volume__c = 5;
            purchaseContractLineItem2.ASI_CRM_Unit_Price__c = 100;
            purchaseContractLineItem2.ASI_CRM_Rebate_Type__c = '  04 - Indirect Special Spot';
            purchaseContractLineItem2.ASI_CRM_Quantity__c = 2;
            //purchaseContractLineItem.ASI_CRM_Pay_To__c = purchaseContractItems[0].id;
            purchaseContractLineItem2.ASI_CRM_Purchase_Contract__c = purchaseContract.Id;
            purchaseContractLineItem2.ASI_CRM_Condition_To__c = 2;
            purchaseContractLineItem2.ASI_CRM_Condition_Of__c = 2;
            purchaseContractLineItem2.RecordTypeId = 
              Global_RecordTypeCache.getRtId('ASI_CRM_Purchase_Contract_Line_Item__cASI_CRM_JP_Direct_Rebate_Contract_Line_Item');
            purchaseContractLineItem2.ASI_CRM_Pay_To__c = pay2C.Id;
            lst.add(purchaseContractLineItem2);
        }
        insert lst;
            
        final ASI_CRM_JP_PurchaseContractService.ReportParameters reportParameters = 
            new ASI_CRM_JP_PurchaseContractService.ReportParameters();
        reportParameters.itemGroupName = ig.name;
        reportParameters.shipToName = 'Test';
        reportParameters.startDate = system.today();
        reportParameters.endToDate = system.today().adddays(30);
        reportParameters.endDate = system.today().adddays(30);
        reportParameters.recordTypeName = 'Test';
        reportParameters.salesGroup = 'Test';
        reportParameters.status = 'Test';
        reportParameters.isEffective = false;
        reportParameters.ownerName = 'Test';
        
        
        
        
        System.debug('---reportParameters---'+reportParameters);
        ASI_CRM_JP_PurchaseContractService.cloneAll(purchaseContractLineItem, reportParameters, 'batchId');
        
    }
    
    
    @isTest
    static void testmethodforpageref(){
        RecordType rtig = [SELECT Id, Name, DeveloperName, SobjectType FROM RecordType WHERE Name = 'JP CRM Item Group'];
        
        ASI_MFM_Item_Group__c ig = new ASI_MFM_Item_Group__c();
        ig.name = 'Test';
        ig.RecordTypeId = rtig.Id;
        insert ig;
        
         final ASI_CRM_JP_PurchaseContractService.ReportParameters reportParameters = 
            new ASI_CRM_JP_PurchaseContractService.ReportParameters();
        reportParameters.itemGroupName = ig.name;
        reportParameters.shipToName = 'Test';
        reportParameters.startDate = system.today();
        reportParameters.endToDate = system.today().adddays(30);
        reportParameters.endDate = system.today().adddays(30);
        reportParameters.recordTypeName = 'Test';
        reportParameters.salesGroup = 'Test';
        reportParameters.status = 'Test';
        reportParameters.isEffective = false;
        reportParameters.ownerName = 'Test';
    }
    
    @isTest
    static void testGetPurchaseContractLineItemNameObjectMap() {
        final Set<String> lineItemNames = new Set<String>();
        final Map<String, ASI_CRM_Purchase_Contract_Line_Item__c> purchaseContractLineItemNameObjectMap = 
            ASI_CRM_JP_PurchaseContractService.getPurchaseContractLineItemNameObjectMap(lineItemNames);
    }
    
    @isTest
    static void testGetPayToNameObjectMap() {
        final Set<String> payToNames = new Set<String>();
        final Map<String, ASI_CRM_Pay_To__c> payToNameObjectMap = 
            ASI_CRM_JP_PurchaseContractService.getPayToNameObjectMap(payToNames);
    }
    
    @isTest
    static void testGetPayToNumberObjectMap() {
        final Set<String> payToNames = new Set<String>();
        final Map<String, ASI_CRM_Pay_To__c> itemGroupNameObjectMap = 
            ASI_CRM_JP_PurchaseContractService.getPayToNumberObjectMap(payToNames);
    }
    
    @isTest
    static void testGetItemGroupNameObjectMap() {
        final Set<String> payToNames = new Set<String>();
        final Map<String, ASI_MFM_Item_Group__c> itemGroupNameObjectMap = 
            ASI_CRM_JP_PurchaseContractService.getItemGroupNameObjectMap(payToNames);
    }
    
    @isTest
    static void test() {
        final Set<String> payToNames = new Set<String>();
        final Map<String, ASI_MFM_Item_Group__c> itemGroupCodeObjectMap = 
            ASI_CRM_JP_PurchaseContractService.getItemGroupCodeObjectMap(payToNames);
    }
    
    @isTest
    static void testGetPurchaseContractNameObjectMap() {
        final Set<String> lineItemNames = new Set<String>();
        final Map<String, ASI_CRM_Purchase_Contract__c> purchaseContractNameObjectMap = 
            ASI_CRM_JP_PurchaseContractService.getPurchaseContractNameObjectMap(lineItemNames);
    }
    
    @isTest
    static void testClonePurchaseContractLineItems() {
        Map<Id, Id> oldNewPurchaseContractIdMap = new Map<Id, Id>();
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
        system.debug('----rn---'+rn);
         insert rn;
        
        RecordType rtap = [SELECT Id, Name, DeveloperName, SobjectType FROM RecordType WHERE DeveloperName = 'ASI_CRM_JP_AP_Code'];
        
        ASI_MFM_AP_Code__c apcode = new ASI_MFM_AP_Code__c();
        apcode.RecordTypeId = rtap.Id;
        insert apcode;
        
        RecordType rtig = [SELECT Id, Name, DeveloperName, SobjectType FROM RecordType WHERE Name = 'JP CRM Item Group'];
        
        ASI_MFM_Item_Group__c ig = new ASI_MFM_Item_Group__c();
        ig.name = 'Test';
        ig.RecordTypeId = rtig.Id;
        insert ig;
        
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
         ASI_TH_CRM_OutletType__c outletType = ASI_CRM_JP_TestClassHelper.createOutletType('Test0');
        ASI_CRM_Postal_Code__c postalCode = ASI_CRM_JP_TestClassHelper.createPostalCode('0000000');
        ASI_CRM_AccountsAdditionalField__c customer2 = new ASI_CRM_AccountsAdditionalField__c(Name='Test0', RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_JP_Off_Trade_Outlet'), ASI_TH_CRM_OutletType__c = outletType.Id, ASI_CRM_PostalCode__c = postalCode.Name);
        insert customer2;
        ASI_CRM_Purchase_Contract__c purchaseContract = new ASI_CRM_Purchase_Contract__c();
        purchaseContract.RecordTypeId = rt.Id;
        purchaseContract.ASI_CRM_Fixed_Spot__c = 'Spot';
        purchaseContract.ASI_CRM_End_Date__c = Date.newInstance(2019, 02, 05);
        purchaseContract.ASI_CRM_BS_Retailer_Ship_To__c = customer2.Id;
        purchaseContract.OwnerId = u.Id;
        insert purchaseContract;
        
        ASI_CRM_Pay_To__c pay2C = 
            new ASI_CRM_Pay_To__c(
                Name = 'test', 
                RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Pay_To__cASI_CRM_JP_Pay_To'),
                ASI_CRM_Active__c=true);
        insert pay2C;
        
        ASI_CRM_Purchase_Contract_Line_Item__c purchaseContractLineItem = new ASI_CRM_Purchase_Contract_Line_Item__c();
        purchaseContractLineItem.ASI_CRM_AP_Code__c = apcode.Id;
        purchaseContractLineItem.ASI_CRM_Item_Group__c = ig.Id;
        purchaseContractLineItem.ASI_CRM_Payment_Method__c = 'Gift Coupon';
        purchaseContractLineItem.ASI_CRM_Condition_Of__c = 2;
        purchaseContractLineItem.ASI_CRM_Condition_To__c = 2;
        purchaseContractLineItem.ASI_CRM_Target_Volume__c = 5;
        purchaseContractLineItem.ASI_CRM_Unit_Price__c = 100;
        purchaseContractLineItem.ASI_CRM_Rebate_Type__c = '  04 - Indirect Special Spot';
        purchaseContractLineItem.ASI_CRM_Quantity__c = 2;
        //purchaseContractLineItem.ASI_CRM_Pay_To__c = purchaseContractItems[0].id;
        purchaseContractLineItem.ASI_CRM_Purchase_Contract__c = purchaseContract.Id;
        purchaseContractLineItem.ASI_CRM_Condition_To__c = 2;
        purchaseContractLineItem.ASI_CRM_Condition_Of__c = 2;
        purchaseContractLineItem.RecordTypeId = 
            Global_RecordTypeCache.getRtId('ASI_CRM_Purchase_Contract_Line_Item__cASI_CRM_JP_Direct_Rebate_Contract_Line_Item');
        purchaseContractLineItem.ASI_CRM_Pay_To__c = pay2C.Id;
        insert purchaseContractLineItem;
        
        
        List<ASI_CRM_Purchase_Contract_Line_Item__c> purchaseContractLineItemsToClone = 
            new List<ASI_CRM_Purchase_Contract_Line_Item__c>();
        purchaseContractLineItemsToClone.add(purchaseContractLineItem);
        ASI_CRM_JP_PurchaseContractService.clonePurchaseContractLineItems(
            oldNewPurchaseContractIdMap,
            purchaseContractLineItemsToClone
        );
    }
    
    @isTest
    static void testIsUserSalesAdmin() {
        final User u = new User();
        u.ASI_MFM_CN_Staff_No__c = ASI_CRM_JP_PurchaseContractService.SALES_STAFF_NO;
        final Boolean result = ASI_CRM_JP_PurchaseContractService.isUserSalesAdmin(u);
        
        System.assertEquals(true, result);
    }
    
    @isTest
    static void testGetDoubleValue() {
        final Double doubleValue = ASI_CRM_JP_PurchaseContractService.getDoubleValue('1.1');
        System.assertEquals(1.1, doubleValue);
    }
    
    
    @isTest
    static void testCreateBatchId() {
        final String batchId =  ASI_CRM_JP_PurchaseContractService.createBatchId();
        System.assertNotEquals(null, batchId);
    }
    
    @isTest
    static void testGetRowDetail() {
        final String rowDetail = ASI_CRM_JP_PurchaseContractService.getRowDetail(1);
        System.assertEquals('Row 1', rowDetail);
    }
    
    @isTest
    static void testClonePurchaseContracts() {
        final List<ASI_CRM_Purchase_Contract__c> purchaseContractsToClone = new List<ASI_CRM_Purchase_Contract__c>();
        final String batchId = 'abc-123';
        
        final List<ASI_CRM_Purchase_Contract__c> clonedPruchaseContracts = 
            ASI_CRM_JP_PurchaseContractService.clonePurchaseContracts(purchaseContractsToClone, batchId);
    }
    
    @isTest
    static void testGetPurchaseContractIdItemsIdSetMap() {
        final Set<Id> purchaseContractLineItemIds = new Set<Id>();
        final Map<Id, Set<Id>> purchaseContractIdItemsIdSetMap = ASI_CRM_JP_PurchaseContractService.getPurchaseContractIdItemsIdSetMap(purchaseContractLineItemIds);
        
        System.assertNotEquals(null, purchaseContractIdItemsIdSetMap);
    }
    
    @isTest
    static void testGetItemGroupCodeFromName() {
        final Set<String> itemGroupNames = new Set<String>();
        itemGroupNames.add('abc-123');
        itemGroupNames.add('def');
        final Set<String> itemGroupCodes = ASI_CRM_JP_PurchaseContractService.getItemGroupCodeFromName(itemGroupNames);
        
        System.assertNotEquals(null, itemGroupCodes);
    }
    
    @isTest
    static void testPrintReportParameters() {
        Reports.ReportMetadata reportMetaData = new Reports.ReportMetadata();
        ASI_CRM_JP_PurchaseContractService.printReportParameters(reportMetaData);
    }
    
    @isTest
    static void testFilterPurchaseContractItemsByValidRecordTypes() {
        final Set<Id> purchaseContractLineItemIds = new Set<Id>();
        final Set<Id> filteredPurchaseContractLineItemIds = ASI_CRM_JP_PurchaseContractService.filterPurchaseContractItemsByValidRecordTypes(purchaseContractLineItemIds);
        
        System.assertNotEquals(null, filteredPurchaseContractLineItemIds);
    }
    
    @isTest
    static void testClonePurchaseContract() {
        final String batchId = '1234';
        final ASI_CRM_Purchase_Contract__c purchaseContract = new ASI_CRM_Purchase_Contract__c();
        purchaseContract.ASI_CRM_Start_Date__c = Date.today();
        purchaseContract.ASI_CRM_End_Date__c = purchaseContract.ASI_CRM_Start_Date__c.addYears(1);
        
        final ASI_CRM_Purchase_Contract__c clonedPurchaseContract = ASI_CRM_JP_PurchaseContractService.clonePurchaseContract(batchId, purchaseContract);
        
        System.assertNotEquals(null, clonedPurchaseContract);
    }
    
    @isTest
    static void testGetFiscalYear() {
        
        Date currentDate = Date.newInstance(2015, 10, 10);
        Date dateForMonth = Date.newInstance(2015, 10, 10);
        
        Integer fiscalYear = ASI_CRM_JP_PurchaseContractService.getFiscalYear(currentDate, dateForMonth);
        
        System.assertEquals(2015, fiscalYear);
        
        dateForMonth = Date.newInstance(2015, 1, 10);
        fiscalYear = ASI_CRM_JP_PurchaseContractService.getFiscalYear(currentDate, dateForMonth);
        System.assertEquals(2014, fiscalYear);
        
        fiscalYear = ASI_CRM_JP_PurchaseContractService.getFiscalYear(null, null);
        System.assertEquals(null, fiscalYear);
    }
    
    @isTest
    static void testUpdateDateBasedOnFiscalYear() {
        final Date baseDate = Date.today();
        final Integer fiscalYear = 2015;
        
        final Date updatedDate = ASI_CRM_JP_PurchaseContractService.updateDateBasedOnFiscalYear(baseDate, fiscalYear);
        
        System.assertEquals(2015, updatedDate.year());
    }
    
    @isTest
    static void testReportParameters() {
        final ASI_CRM_JP_PurchaseContractService.ReportParameters reportParameters = 
            new ASI_CRM_JP_PurchaseContractService.ReportParameters();
        
        System.assertEquals(null, reportParameters.endDate);
        System.assertEquals(null, reportParameters.endToDate);
        System.assertEquals(null, reportParameters.isEffective);
        System.assertEquals(null, reportParameters.itemGroupName);
        System.assertEquals(null, reportParameters.ownerName);
        System.assertEquals(null, reportParameters.recordTypeName);
        System.assertEquals(null, reportParameters.salesGroup);
        System.assertEquals(null, reportParameters.shipToName);
        System.assertEquals(null, reportParameters.startDate);
        System.assertEquals(null, reportParameters.status);
        
    }
}