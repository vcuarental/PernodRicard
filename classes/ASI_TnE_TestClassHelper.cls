/*********************************************************************************
 * Name:ASI_TnE_TestClassHelper
 * Description: For generating test data for ASI TnE
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------
 * 16/4/2015        Laputa: Hank            Created
 * 21/4/2015        Dandelo                 Added methods for creating User
*********************************************************************************/
@isTest
public class ASI_TnE_TestClassHelper{
    //Create Custom Settings for ASI TnE Tax Date Mapping
    public static void createTaxDateMapping(){
        List<ASI_TnE_Tax_Date_Mapping__c> mappingList = new List<ASI_TnE_Tax_Date_Mapping__c>();
        mappingList.add(new ASI_TnE_Tax_Date_Mapping__c(Name='SG', ASI_TnE_Tax_Rate__c = 7, ASI_TnE_Record_Type__c = 'ASI_TnE_SG_Claim_Detail', ASI_TnE_Start_Date__c = system.today().addYears(-1), ASI_TnE_End_Date__c = system.today().addYears(1)));
        mappingList.add(new ASI_TnE_Tax_Date_Mapping__c(Name='ID', ASI_TnE_Tax_Rate__c = 7, ASI_TnE_Record_Type__c = 'ASI_TnE_ID_Claim_Detail', ASI_TnE_Start_Date__c = system.today().addYears(-1), ASI_TnE_End_Date__c = system.today().addYears(1)));
        mappingList.add(new ASI_TnE_Tax_Date_Mapping__c(Name='MY', ASI_TnE_Tax_Rate__c = 7, ASI_TnE_Record_Type__c = 'ASI_TnE_MY_Claim_Detail', ASI_TnE_Start_Date__c = system.today().addYears(-1), ASI_TnE_End_Date__c = system.today().addYears(1)));
        mappingList.add(new ASI_TnE_Tax_Date_Mapping__c(Name='TH', ASI_TnE_Tax_Rate__c = 7, ASI_TnE_Record_Type__c = 'ASI_TnE_TH_Claim_Detail', ASI_TnE_Start_Date__c = system.today().addYears(-1), ASI_TnE_End_Date__c = system.today().addYears(1)));
        mappingList.add(new ASI_TnE_Tax_Date_Mapping__c(Name='PH', ASI_TnE_Tax_Rate__c = 7, ASI_TnE_Record_Type__c = 'ASI_TnE_PH_Claim_Detail', ASI_TnE_Start_Date__c = system.today().addYears(-1), ASI_TnE_End_Date__c = system.today().addYears(1)));
        mappingList.add(new ASI_TnE_Tax_Date_Mapping__c(Name='HK', ASI_TnE_Tax_Rate__c = 7, ASI_TnE_Record_Type__c = 'ASI_TnE_HK_Claim_Detail', ASI_TnE_Start_Date__c = system.today().addYears(-1), ASI_TnE_End_Date__c = system.today().addYears(1)));
        insert mappingList;    
    }
    //Create Running numbers for TnE Header&Detail
    public static void createRunningNumbers(){
        List<ASI_HK_CRM_Running_Number__c> runningNoList = new List<ASI_HK_CRM_Running_Number__c>();
        runningNoList.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_First_Month_of_Fiscal_Year__c = 7, ASI_HK_CRM_Fiscal_Year__c = 2015, ASI_HK_CRM_Object_Name__c = 'ASI_TnE_TH_Claim_Detail', ASI_HK_CRM_Format__c = 'TED-TH-{YY}-{00000}', ASI_HK_CRM_Running_Number__c = 1));
        runningNoList.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_First_Month_of_Fiscal_Year__c = 7, ASI_HK_CRM_Fiscal_Year__c = 2015, ASI_HK_CRM_Object_Name__c = 'ASI_TnE_HK_Claim_Detail', ASI_HK_CRM_Format__c = 'TED-HK-{YY}-{00000}', ASI_HK_CRM_Running_Number__c = 1));
        runningNoList.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_First_Month_of_Fiscal_Year__c = 7, ASI_HK_CRM_Fiscal_Year__c = 2015, ASI_HK_CRM_Object_Name__c = 'ASI_TnE_PH_Claim_Detail', ASI_HK_CRM_Format__c = 'TED-PH-{YY}-{00000}', ASI_HK_CRM_Running_Number__c = 1));
        runningNoList.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_First_Month_of_Fiscal_Year__c = 7, ASI_HK_CRM_Fiscal_Year__c = 2015, ASI_HK_CRM_Object_Name__c = 'ASI_TnE_ID_Claim_Detail', ASI_HK_CRM_Format__c = 'TED-ID-{YY}-{00000}', ASI_HK_CRM_Running_Number__c = 1));
        runningNoList.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_First_Month_of_Fiscal_Year__c = 7, ASI_HK_CRM_Fiscal_Year__c = 2015, ASI_HK_CRM_Object_Name__c = 'ASI_TnE_MY_Claim_Detail', ASI_HK_CRM_Format__c = 'TED-MY-{YY}-{00000}', ASI_HK_CRM_Running_Number__c = 1));
        runningNoList.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_First_Month_of_Fiscal_Year__c = 7, ASI_HK_CRM_Fiscal_Year__c = 2015, ASI_HK_CRM_Object_Name__c = 'ASI_TnE_SG_Claim_Detail', ASI_HK_CRM_Format__c = 'TED-SG-{YY}-{00000}', ASI_HK_CRM_Running_Number__c = 1));
        runningNoList.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_First_Month_of_Fiscal_Year__c = 7, ASI_HK_CRM_Fiscal_Year__c = 2015, ASI_HK_CRM_Object_Name__c = 'ASI_TnE_HK_Claim_Header', ASI_HK_CRM_Format__c = 'TE-HK-{YY}-{00000}', ASI_HK_CRM_Running_Number__c = 1));
        runningNoList.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_First_Month_of_Fiscal_Year__c = 7, ASI_HK_CRM_Fiscal_Year__c = 2015, ASI_HK_CRM_Object_Name__c = 'ASI_TnE_PH_Claim_Header', ASI_HK_CRM_Format__c = 'TE-PH-{YY}-{00000}', ASI_HK_CRM_Running_Number__c = 1));
        runningNoList.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_First_Month_of_Fiscal_Year__c = 7, ASI_HK_CRM_Fiscal_Year__c = 2015, ASI_HK_CRM_Object_Name__c = 'ASI_TnE_ID_Claim_Header', ASI_HK_CRM_Format__c = 'TE-ID-{YY}-{00000}', ASI_HK_CRM_Running_Number__c = 1));
        runningNoList.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_First_Month_of_Fiscal_Year__c = 7, ASI_HK_CRM_Fiscal_Year__c = 2015, ASI_HK_CRM_Object_Name__c = 'ASI_TnE_MY_Claim_Header', ASI_HK_CRM_Format__c = 'TE-MY-{YY}-{00000}', ASI_HK_CRM_Running_Number__c = 1));
        runningNoList.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_First_Month_of_Fiscal_Year__c = 7, ASI_HK_CRM_Fiscal_Year__c = 2015, ASI_HK_CRM_Object_Name__c = 'ASI_TnE_TH_Claim_Header', ASI_HK_CRM_Format__c = 'TE-TH-{YY}-{00000}', ASI_HK_CRM_Running_Number__c = 1));
        runningNoList.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_First_Month_of_Fiscal_Year__c = 7, ASI_HK_CRM_Fiscal_Year__c = 2015, ASI_HK_CRM_Object_Name__c = 'ASI_TnE_SG_Claim_Header', ASI_HK_CRM_Format__c = 'TE-SG-{YY}-{00000}', ASI_HK_CRM_Running_Number__c = 1));
        insert runningNoList;
    }
    
    //Create Account Mapping
    public static ASI_TnE_Account_Mapping__c createAccMap(String recordType){
        ASI_TnE_Account_Mapping__c accMap = new ASI_TnE_Account_Mapping__c(RecordTypeId = Global_RecordTypeCache.getRtId(recordType), ASI_TnE_Account_Number__c = '123456');
        insert accMap;
        return accMap;
    }
    
    //Create Expense Category
    public static ASI_JP_TnE_Expense_Category__c createExpenseCategory(String recordType){
        ASI_JP_TnE_Expense_Category__c category = new ASI_JP_TnE_Expense_Category__c(Name = 'test', RecordTypeId = Global_RecordTypeCache.getRtId(recordType));
        insert category;
        return category;
    }
    
    //Create Expense Classification
    public static ASI_JP_TnE_Expense_Classification__c createExpenseCls(String recordType, ASI_JP_TnE_Expense_Category__c category, ASI_TnE_Account_Mapping__c accMap){
        ASI_JP_TnE_Expense_Classification__c cls = new ASI_JP_TnE_Expense_Classification__c(Name = 'test', RecordTypeId = Global_RecordTypeCache.getRtId(recordType), ASI_JP_TnE_Expense_Category__c = category.Id, ASI_JP_TnE_Account_Mapping__c = accMap.Id);
        List<User> userList = new List<User>();
        User u1 = newUser('test011');
        User u2 = newUser('test012');
        User u3 = newUser('test013');
        User u4 = newUser('test014');
        userList.add(u1);userList.add(u2);userList.add(u3);userList.add(u4);
        insert userList;
        cls.ASI_TnE_Notification_Email__c = u1.Id;
        cls.ASI_TnE_Notification_Email_2__c = u2.Id;
        cls.ASI_TnE_Notification_Email_3__c = u3.Id;
        cls.ASI_TnE_Notification_Email_4__c = u3.Id;
        insert cls;
        return cls;
    }

    //Create route type
    public static ASI_TnE_Route_Type__c createRouteType(User u, Integer type){
        ASI_TnE_Route_Type__c route = new ASI_TnE_Route_Type__c();
        List<User> userList = new List<User>();
        User u1 = newUser('test001');
        User u2 = newUser('test002');
        User u3 = newUser('test003');
        User u4 = newUser('test004');
        User u5 = newUser('test005');
        userList.add(u1);userList.add(u2);userList.add(u3);userList.add(u4);userList.add(u5);
        insert userList;
        if(type == 1){
            route.ASI_TnE_Company__c = u.CompanyName;
            route.ASI_TnE_Department__c = u.Department;
        }else if(type == 2){
            route.ASI_TnE_User__c= u.Id;
        }
        route.recordtypeId = Global_RecordTypeCache.getRtId('ASI_TnE_Route_Type__cASI_TnE_SG_Route_Type');
        insert route;
        List<ASI_TnE_Route_Rule_Detail__c> detailList = new List <ASI_TnE_Route_Rule_Detail__c>(); 
        detailList.add(new ASI_TnE_Route_Rule_Detail__c(ASI_TnE_Route_Type__c = route.Id, ASI_TnE_Approver_Type__c = 'Line Manager')); 
        detailList.add(new ASI_TnE_Route_Rule_Detail__c(ASI_TnE_Route_Type__c = route.Id, ASI_TnE_Approver_Type__c = 'User', ASI_TnE_Approver_Name__c = u1.Id));
        detailList.add(new ASI_TnE_Route_Rule_Detail__c(ASI_TnE_Route_Type__c = route.Id, ASI_TnE_Approver_Type__c = 'User', ASI_TnE_Approver_Name__c = u2.Id));
        detailList.add(new ASI_TnE_Route_Rule_Detail__c(ASI_TnE_Route_Type__c = route.Id, ASI_TnE_Approver_Type__c = 'User', ASI_TnE_Approver_Name__c = u3.Id)); 
        detailList.add(new ASI_TnE_Route_Rule_Detail__c(ASI_TnE_Route_Type__c = route.Id, ASI_TnE_Approver_Type__c = 'User', ASI_TnE_Approver_Name__c = u4.Id));
        detailList.add(new ASI_TnE_Route_Rule_Detail__c(ASI_TnE_Route_Type__c = route.Id, ASI_TnE_Approver_Type__c = 'User', ASI_TnE_Approver_Name__c = u5.Id));
        detailList.add(new ASI_TnE_Route_Rule_Detail__c(ASI_TnE_Route_Type__c = route.Id, ASI_TnE_Approver_Type__c = 'User', ASI_TnE_Approver_Name__c = u5.Id));
        detailList.add(new ASI_TnE_Route_Rule_Detail__c(ASI_TnE_Route_Type__c = route.Id, ASI_TnE_Approver_Type__c = 'User', ASI_TnE_Approver_Name__c = u4.Id));
        detailList.add(new ASI_TnE_Route_Rule_Detail__c(ASI_TnE_Route_Type__c = route.Id, ASI_TnE_Approver_Type__c = 'User', ASI_TnE_Approver_Name__c = u3.Id));
        detailList.add(new ASI_TnE_Route_Rule_Detail__c(ASI_TnE_Route_Type__c = route.Id, ASI_TnE_Approver_Type__c = 'User', ASI_TnE_Approver_Name__c = u2.Id));
        detailList.add(new ASI_TnE_Route_Rule_Detail__c(ASI_TnE_Route_Type__c = route.Id, ASI_TnE_Approver_Type__c = 'User', ASI_TnE_Approver_Name__c = u1.Id));
        insert detailList;  
        return route;
    }
    
    //Create ASI_TnE_ClaimHeader__c
    public static ASI_TnE_ClaimHeader__c createClaimHeader()
    {
        //ADDED BY GDT TEAM
        Date GDT_Todays = Date.today();
        Date GDT_Date = GDT_Todays.addMonths(-1);
        //
        
        RecordType rct = [SELECT Id from RecordType where DeveloperName = 
        'ASI_TnE_HK_Claim_Header_Finance' LIMIT 1 ];
        ASI_TnE_ClaimHeader__c claimHeader1 = new ASI_TnE_ClaimHeader__c(CURRENCYISOCODE='HKD', 
        RECORDTYPEID=rct.Id, 
        ASI_TNE_3RD_PARTY__C=false, 
        ASI_TNE_DATE__C= GDT_Date,
        ASI_TNE_PAYMENT_OPTION__C='Cash', 
        ASI_TNE_STATUS__C='Draft');

        claimHeader1.ownerId = UserInfo.getUserId();
        
        insert claimHeader1;
        return claimHeader1;
    
    }
    
    //Create User
    public static User createUser(){
    
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        
        User u1 = new User(Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id,
            TimeZoneSidKey='America/Los_Angeles', UserName='test1@laputa.com');
            
        insert u1;
        return u1;
    }
    
    //Create User with parameter
    public static User createUser(String userName, String country){
    
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        
        User u1 = new User(Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, Country = country,
            TimeZoneSidKey='America/Los_Angeles', UserName= userName + '@laputa.com');
            
        insert u1;
        return u1;
    }
    
    public static User newUser(String userName){
    
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        
        User u1 = new User(Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id,
            TimeZoneSidKey='America/Los_Angeles', UserName= userName + '@laputa.com');

        return u1;
    }
    
    public static ASI_TnE_Corp_Card_Statement_Upload__c createStatement(String cNumber, Date sDate){
        ASI_TnE_Corp_Card_Statement_Upload__c stmnt = new ASI_TnE_Corp_Card_Statement_Upload__c(
            ASI_TnE_Card_Number__c = cNumber, ASI_TnE_Statement_Date__c = sDate,
            ASI_TnE_Charge_Date__c = sDate, ASI_TnE_Full_Name__c = 'FULL Name',
            ASI_TnE_MCC_Group__c = 'RESTAURANT'
        );
        insert stmnt;
        return stmnt;
    }
    
    public static Account createAccount(String recTypeDevName){
        Account acc = new Account(recordTypeId = Global_RecordTypeCache.getRtId(recTypeDevName), Name='Test name');
        insert acc;
        return acc;
    }
    
    public static ASI_TnE_Corp_Card_Employee_Mapping__c createEmployeeMapping(String cNumber1, String cNumber2, Id cIssuer1, Id cIssuer2){
        ASI_TnE_Corp_Card_Employee_Mapping__c empMap = new ASI_TnE_Corp_Card_Employee_Mapping__c(
            ASI_TnE_Card_Number_1__c = cNumber1, ASI_TnE_Card_Number_2__c = cNumber2, 
            ASI_TnE_Card_Issuer_1__c = cIssuer1, ASI_TnE_Card_Issuer_2__c = cIssuer2,
            ASI_TnE_Employee_Name__c = UserInfo.getUserId(),
            ASI_TnE_Assistant_Name__c = UserInfo.getUserId()
        );
        insert empMap;
        return empMap;
    }
    
    public static ASI_TnE_ClaimHeader__c createTestClaimHeader(String invoice, String recordType){
        ASI_TnE_ClaimHeader__c header = new ASI_TnE_ClaimHeader__c(
            ASI_TnE_Invoice_No__c = invoice, ASI_TnE_Status__c = 'Draft',
            ASI_TnE_Type__c = 'Out of Pocket', ASI_TnE_Start_Date__c = date.today().addDays(1), ASI_TnE_End_Date__c = date.today().addYears(1),
            recordTypeId = Global_RecordTypeCache.getRtId(recordType),
            ASI_TnE_Sys_Approver_1__c = UserInfo.getUserId()
        );
        insert header;
        return header;
    }
    
    public static ASI_TnE_ClaimHeader__c newTestClaimHeader(String invoice, String recordType){
        ASI_TnE_ClaimHeader__c header = new ASI_TnE_ClaimHeader__c(
            ASI_TnE_Invoice_No__c = invoice, ASI_TnE_Status__c = 'Draft',
            ASI_TnE_Type__c = 'Out of Pocket', ASI_TnE_Start_Date__c = date.today().addDays(1), ASI_TnE_End_Date__c = date.today().addYears(1),
            recordTypeId = Global_RecordTypeCache.getRtId(recordType)
        );
        return header;
    }
    
    public static ASI_TnE_ClaimDetail__c createClaimDetail(String cHeader, String recordType){
        ASI_TnE_ClaimDetail__c header = new ASI_TnE_ClaimDetail__c(
            ASI_TnE_ClaimHeader__c = cHeader, ASI_TnE_Receipt_Date__c = date.today(),ASI_TnE_Description__c = 'test description',
            ASI_TnE_Currency__c = 'HKD',ASI_TnE_Receipt_Amount__c = 100,ASI_TnE_FX_Rate__c = 1,
            recordTypeId = Global_RecordTypeCache.getRtId(recordType),
            ASI_TnE_Tax_Inclusive__c = true
        );
        insert header;
        return header;
    }
    
    public static ASI_TnE_ClaimDetail__c createClaimDetail(String cHeader, String recordType, Id poid, Integer amount){
        ASI_TnE_ClaimDetail__c header = new ASI_TnE_ClaimDetail__c(
            ASI_TnE_ClaimHeader__c = cHeader, ASI_TnE_Receipt_Date__c = date.today(),ASI_TnE_Description__c = 'test description',
            ASI_TnE_Currency__c = 'HKD',ASI_TnE_FX_Rate__c = 1,
            recordTypeId = Global_RecordTypeCache.getRtId(recordType),
            ASI_TnE_Tax_Inclusive__c = true,
            ASI_TnE_MFM_PO__c = poid, ASI_TnE_Receipt_Amount__c = amount
        );
        insert header;
        return header;
    }
    
    public static ASI_TnE_ClaimDetail__c newClaimDetail(String cHeader, String recordType){
        ASI_TnE_ClaimDetail__c header = new ASI_TnE_ClaimDetail__c(
            ASI_TnE_ClaimHeader__c = cHeader, ASI_TnE_Receipt_Date__c = date.today(),ASI_TnE_Description__c = 'test description',
            ASI_TnE_Currency__c = 'HKD',ASI_TnE_Receipt_Amount__c = 100,ASI_TnE_FX_Rate__c = 1,
            recordTypeId = Global_RecordTypeCache.getRtId(recordType)
        );
        return header;
    }
    
    public static ASI_TnE_ClaimDetail__c createClaimDetail(String cHeader, String recordType, ASI_JP_TnE_Expense_Classification__c cls){
        ASI_TnE_ClaimDetail__c header = new ASI_TnE_ClaimDetail__c(
            ASI_TnE_ClaimHeader__c = cHeader, ASI_TnE_Receipt_Date__c = date.today(),ASI_TnE_Description__c = 'test description',
            ASI_TnE_Currency__c = 'HKD',ASI_TnE_Receipt_Amount__c = 100,ASI_TnE_FX_Rate__c = 1,
            recordTypeId = Global_RecordTypeCache.getRtId(recordType),
            ASI_TnE_Expense_Classification__c = cls.Id
        );
        insert header;
        return header;
    }
    
    public static ASI_TnE_Corp_Card_MCC_Account_Mapping__c createMCCGroupMapping(String mccGroup, String recordType){
        ASI_TnE_Corp_Card_MCC_Account_Mapping__c mcc = new ASI_TnE_Corp_Card_MCC_Account_Mapping__c(
            ASI_TnE_MCC_Group__c = mccGroup,
            ASI_TnE_Account_Number__c = '123456',
            RecordTypeId = Global_RecordTypeCache.getRtId('ASI_TnE_Corp_Card_MCC_Account_Mapping__cASI_TnE_HK_Corp_Card_Merchant_Category_Account_Mapping')
        );
        insert mcc;
        return mcc;
    }
}