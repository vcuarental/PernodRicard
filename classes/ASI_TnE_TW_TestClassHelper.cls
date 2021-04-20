/*********************************************************************************
 * Name:ASI_TnE_TW_TestClassHelper
 * Description: For generating test data for ASI TnE TW
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------
 * 09/12/2015        IPC: DC                Created (Cloned from ASI_TnE_TestClassHelper)
*********************************************************************************/
@isTest
public class ASI_TnE_TW_TestClassHelper{
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
       Integer currentYear = null;
       Integer sMonth = Integer.valueOf(String.valueOf(Date.Today().Month()));
        if (sMonth >= 7) {
			currentYear = System.Today().year() + 1;
        } else {
			currentYear = System.Today().year();
        }

        List<ASI_HK_CRM_Running_Number__c> runningNoList = new List<ASI_HK_CRM_Running_Number__c>();
        runningNoList.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_First_Month_of_Fiscal_Year__c = 7, ASI_HK_CRM_Fiscal_Year__c = currentYear, ASI_HK_CRM_Object_Name__c = 'ASI_TnE_TH_Claim_Detail', ASI_HK_CRM_Format__c = 'TED-TH-{YY}-{00000}', ASI_HK_CRM_Running_Number__c = 1));
        runningNoList.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_First_Month_of_Fiscal_Year__c = 7, ASI_HK_CRM_Fiscal_Year__c = currentYear, ASI_HK_CRM_Object_Name__c = 'ASI_TnE_HK_Claim_Detail', ASI_HK_CRM_Format__c = 'TED-HK-{YY}-{00000}', ASI_HK_CRM_Running_Number__c = 1));
        runningNoList.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_First_Month_of_Fiscal_Year__c = 7, ASI_HK_CRM_Fiscal_Year__c = currentYear, ASI_HK_CRM_Object_Name__c = 'ASI_TnE_PH_Claim_Detail', ASI_HK_CRM_Format__c = 'TED-PH-{YY}-{00000}', ASI_HK_CRM_Running_Number__c = 1));
        runningNoList.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_First_Month_of_Fiscal_Year__c = 7, ASI_HK_CRM_Fiscal_Year__c = currentYear, ASI_HK_CRM_Object_Name__c = 'ASI_TnE_ID_Claim_Detail', ASI_HK_CRM_Format__c = 'TED-ID-{YY}-{00000}', ASI_HK_CRM_Running_Number__c = 1));
        runningNoList.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_First_Month_of_Fiscal_Year__c = 7, ASI_HK_CRM_Fiscal_Year__c = currentYear, ASI_HK_CRM_Object_Name__c = 'ASI_TnE_MY_Claim_Detail', ASI_HK_CRM_Format__c = 'TED-MY-{YY}-{00000}', ASI_HK_CRM_Running_Number__c = 1));
        runningNoList.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_First_Month_of_Fiscal_Year__c = 7, ASI_HK_CRM_Fiscal_Year__c = currentYear, ASI_HK_CRM_Object_Name__c = 'ASI_TnE_SG_Claim_Detail', ASI_HK_CRM_Format__c = 'TED-SG-{YY}-{00000}', ASI_HK_CRM_Running_Number__c = 1));
        runningNoList.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_First_Month_of_Fiscal_Year__c = 7, ASI_HK_CRM_Fiscal_Year__c = currentYear, ASI_HK_CRM_Object_Name__c = 'ASI_TnE_HK_Claim_Header', ASI_HK_CRM_Format__c = 'TE-HK-{YY}-{00000}', ASI_HK_CRM_Running_Number__c = 1));
        runningNoList.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_First_Month_of_Fiscal_Year__c = 7, ASI_HK_CRM_Fiscal_Year__c = currentYear, ASI_HK_CRM_Object_Name__c = 'ASI_TnE_PH_Claim_Header', ASI_HK_CRM_Format__c = 'TE-PH-{YY}-{00000}', ASI_HK_CRM_Running_Number__c = 1));
        runningNoList.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_First_Month_of_Fiscal_Year__c = 7, ASI_HK_CRM_Fiscal_Year__c = currentYear, ASI_HK_CRM_Object_Name__c = 'ASI_TnE_ID_Claim_Header', ASI_HK_CRM_Format__c = 'TE-ID-{YY}-{00000}', ASI_HK_CRM_Running_Number__c = 1));
        runningNoList.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_First_Month_of_Fiscal_Year__c = 7, ASI_HK_CRM_Fiscal_Year__c = currentYear, ASI_HK_CRM_Object_Name__c = 'ASI_TnE_MY_Claim_Header', ASI_HK_CRM_Format__c = 'TE-MY-{YY}-{00000}', ASI_HK_CRM_Running_Number__c = 1));
        runningNoList.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_First_Month_of_Fiscal_Year__c = 7, ASI_HK_CRM_Fiscal_Year__c = currentYear, ASI_HK_CRM_Object_Name__c = 'ASI_TnE_TH_Claim_Header', ASI_HK_CRM_Format__c = 'TE-TH-{YY}-{00000}', ASI_HK_CRM_Running_Number__c = 1));
        runningNoList.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_First_Month_of_Fiscal_Year__c = 7, ASI_HK_CRM_Fiscal_Year__c = currentYear, ASI_HK_CRM_Object_Name__c = 'ASI_TnE_SG_Claim_Header', ASI_HK_CRM_Format__c = 'TE-SG-{YY}-{00000}', ASI_HK_CRM_Running_Number__c = 1));
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
        route.recordtypeId = Global_RecordTypeCache.getRtId('ASI_TnE_Route_Type__cASI_TnE_TW_Route_Type');
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
        'ASI_TnE_TW_Claim_Header' LIMIT 1 ];
        ASI_TnE_ClaimHeader__c claimHeader1 = new ASI_TnE_ClaimHeader__c(CURRENCYISOCODE='TWD', 
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
    
    
    public static ASI_TnE_ClaimDetail__c newClaimDetail(String cHeader, String recordType){
        ASI_TnE_ClaimDetail__c header = new ASI_TnE_ClaimDetail__c(
            ASI_TnE_ClaimHeader__c = cHeader, ASI_TnE_Receipt_Date__c = date.today(),ASI_TnE_Description__c = 'test description',
            ASI_TnE_Currency__c = 'TWD',ASI_TnE_Receipt_Amount__c = 100,ASI_TnE_FX_Rate__c = 1,
            recordTypeId = Global_RecordTypeCache.getRtId(recordType)
        );
        return header;
    }
    
    public static ASI_TnE_ClaimDetail__c createClaimDetail(String cHeader, String recordType, ASI_JP_TnE_Expense_Classification__c cls){
        ASI_TnE_ClaimDetail__c header = new ASI_TnE_ClaimDetail__c(
            ASI_TnE_ClaimHeader__c = cHeader, ASI_TnE_Receipt_Date__c = date.today(),ASI_TnE_Description__c = 'test description',
            ASI_TnE_Currency__c = 'TWD',ASI_TnE_Receipt_Amount__c = 100,ASI_TnE_FX_Rate__c = 1,
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
    
    public static ASI_TnE_Employee_Code_Mapping__c createEmployeeCodeMapping(){
        ASI_TnE_Employee_Code_Mapping__c mcc = new ASI_TnE_Employee_Code_Mapping__c(
            ASI_TnE_Department_Code__c = 'TestDC1',
            ASI_TnE_Employee_Code__c = 'TestEC1',
            ASI_TnE_Employee_Name__c = UserInfo.getUserId(),
            ASI_TnE_Market__c = 'Taiwan',
            RecordTypeId = Global_RecordTypeCache.getRTId('ASI_TnE_Employee_Code_Mapping__cASI_TnE_TH_Employee_Code_Mapping')
        );
        insert mcc;
        return mcc;
    }
    
    public static ASI_MFM_Sub_brand__c createSubBrand(){
        ASI_MFM_Sub_brand__c mcc = new ASI_MFM_Sub_brand__c(
            Name = 'Test Brand',
            RecordTypeId = Global_RecordTypeCache.getRTId('ASI_MFM_Sub_brand__cASI_TH_CRM_Sub_brand')
        );
        insert mcc;
        return mcc;
    }
    
    public static ASI_MFM_Exchange_Rate__c createExchangeRate(Date effectiveDate){
        ASI_MFM_Exchange_Rate__c mcc = new ASI_MFM_Exchange_Rate__c(
            ASI_MFM_Base_Currency__c = 'TWD', 
            ASI_MFM_Country__c = 'TW',
            ASI_MFM_Counter_Currency__c = 'TWD',
            ASI_MFM_Effective_Date__c = effectiveDate,
            ASI_MFM_Exchange_Rate__c = 0.98,
            RecordTypeId = Global_RecordTypeCache.getRTId('ASI_MFM_Exchange_Rate__cASI_TnE_KR_Exchange_Rate')
        );
        insert mcc;
        return mcc;
    }
    
    //Create ASI_TnE_ClaimHeader__c
    public static ASI_TnE_ClaimHeader__c createClaimHeader(String invoice, String recordType){
        ASI_TnE_ClaimHeader__c header = new ASI_TnE_ClaimHeader__c(
            ASI_TnE_Invoice_No__c = invoice, ASI_TnE_Status__c = 'Draft',
            ASI_TnE_Type__c = 'Out of Pocket', ASI_TnE_Start_Date__c = date.today().addDays(1), ASI_TnE_End_Date__c = date.today().addYears(1),
            recordTypeId = Global_RecordTypeCache.getRtId(recordType)
        );
        return header;
    }
   
    //Create ASI_TnE_ClaimDetail__c 
    public static ASI_TnE_ClaimDetail__c createClaimDetail(Id pIdClaimHdr, String pRecordType, Id pPO_ID){
   
       ASI_TnE_ClaimDetail__c claimDtl = new ASI_TnE_ClaimDetail__c( ASI_TnE_ClaimHeader__c = pIdClaimHdr, 
                                                                     ASI_TnE_Receipt_Date__c = date.today(),
                                                                     ASI_TnE_Description__c = 'test description',
                                                                     ASI_TnE_Currency__c = 'TWD',
                                                                     ASI_TnE_Receipt_Amount__c = 100,
                                                                     ASI_TnE_FX_Rate__c = 1,
                                                                     ASI_TnE_MFM_PO__c = pPO_ID,
                                                                     recordTypeId = Global_RecordTypeCache.getRtId(pRecordType));

       return claimDtl;     
   }
   
   //2.0
    
    //Create Account
    public static Account createTestAccount(String name,String recordType){
    Account account = new Account(Name = name,RecordTypeId = Global_RecordTypeCache.getRtId(recordType), Billing_Address__c = 'TestAddress 123',ASI_HK_CRM_Address__c = 'abc',Shipping_Address__c = 'test',Revenue_Address__c = 'test');
        return account ;
    }
    
    // DC - 01/28/2016 - Migrated these methods from "ASI_TnE_ClaimsDetailValidatePOTest" class.
    public static ASI_MFM_PO__c createPO(){
	   Integer sTY =  Integer.valueOf(String.valueOf(Date.Today().Year()).right(2));
       Integer sLY =  Integer.valueOf(String.valueOf(Date.Today().Year()).right(2)) - 1;
       Integer sNY =  Integer.valueOf(String.valueOf(Date.Today().Year()).right(2)) + 1;
       String sFiscalYear = '';
	   System.debug('');
       Integer sMonth = Integer.valueOf(String.valueOf(Date.Today().Month()));
        if (sMonth >= 7) {
            sFiscalYear = 'FY' + String.ValueOf(sTY) + String.ValueOf(sNY);
        } else {
			sFiscalYear = 'FY' + String.ValueOf(sLY) + String.ValueOf(sTY);
        }
	   System.debug('sFiscalYear := ' + sFiscalYear);
       ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(Name = 'test', 
                                                    ASI_MFM_Module__c = 'Plan', 
                                                    Plan_Type__c = 'test', 
                                                    ASI_MFM_Fiscal_year__c = sFiscalYear);
       insert px;   
       
       User u = [select userRole.developerName, BypassTriggers__c  from user where id =: userInfo.getUserId()];  
       u.BypassTriggers__c ='ASI_MFM_SG_Check_PO_Balance';
       update u;
        
       ASI_MFM_Role_Prefix_Relationship__c pr = 
                            new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c = px.id, 
                                                                    ASI_MFM_Role_Name__c = u.userRole.developerName);
       insert pr;
       
       ASI_MFM_Plan__c p = 
                    new ASI_MFM_Plan__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_SG_Plan'), 
                                        Name= 'test', ASI_MFM_End_Date__c = Date.today().addMonths(1), 
                                        ASI_MFM_Plan_Description__c = 'testDescription', 
                                        ASI_MFM_Plan_Name__c = 'test', 
                                        ASI_MFM_Start_Date__c = Date.today().addMonths(1),  
                                        ASI_MFM_Prefix__c = px.id, ASI_MFM_Status__c = 'Final');
       insert p;
       
       Account acc = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_CRM_SG_Supplier'), 
                                 Name = 'Sample Account');           
       insert acc;
       
       ASI_MFM_Prefix__c pxo = new ASI_MFM_Prefix__c(Name='test', 
                                                  ASI_MFM_Module__c = 'PO');
       insert pxo;

       ASI_MFM_Role_Prefix_Relationship__c pro = 
                   new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c = pxo.id, 
                                                           ASI_MFM_Role_Name__c= u.userRole.developerName);
       insert pro;
    
       ASI_MFM_PO__c po = new ASI_MFM_PO__c(ASI_MFM_Status__c = 'Final', 
                                            recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_SG_PO'), 
                                            Name = 'test123', ASI_MFM_Plan__c = p.id, 
                                            ASI_MFM_Invoice_Amount_from_JDE__c = 1000, 
                                            ASI_MFM_T_E_Amount__c = 1500, 
                                            ASI_MFM_T_E_Amount_Posted__c = 1200, 
                                            ASI_MFM_Prefix__c= pxo.id, 
                                            ASI_MFM_Supplier_Name__c = acc.id, 
                                            ASI_MFM_PO_End_Date__c = Date.today(),
                                            ASI_MFM_Exchange_Rate__c = 1);
       
       insert po;
       return po;
   }//End createPO method

}