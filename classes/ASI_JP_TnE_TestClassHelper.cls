@isTest
public class ASI_JP_TnE_TestClassHelper
{

    public static List<ASI_JP_TnE_Expense_Category__c> createExpenseCategoryTestData()
    {
        List<ASI_JP_TnE_Expense_Category__c> expenseCatList = new List<ASI_JP_TnE_Expense_Category__c>();      
      
        ASI_JP_TnE_Expense_Category__c expenseCat1 = new ASI_JP_TnE_Expense_Category__c(NAME='交通費', CURRENCYISOCODE='JPY', ASI_JP_TNE_EXPENSE_CATEGORY_ORDER__C=10.0, NAME_EN_US__C='Fare');
        expenseCatList.add(expenseCat1); 

        ASI_JP_TnE_Expense_Category__c expenseCat2 = 
        new ASI_JP_TnE_Expense_Category__c(NAME='車輌関係', CURRENCYISOCODE='JPY', ASI_JP_TNE_EXPENSE_CATEGORY_ORDER__C=20.0, NAME_EN_US__C='Car Expense');
        expenseCatList.add(expenseCat2); 

        ASI_JP_TnE_Expense_Category__c expenseCat3 = 
        new ASI_JP_TnE_Expense_Category__c(NAME='出張宿泊費', CURRENCYISOCODE='JPY', ASI_JP_TNE_EXPENSE_CATEGORY_ORDER__C=30.0, NAME_EN_US__C='Business Trip');
  
        expenseCatList.add(expenseCat3);   

        insert expenseCatList;        
    
        return expenseCatList;

    }
    
    public static List<ASI_TnE_Account_Mapping__c> createAccountMappingTestData()
    {   
        List<ASI_TnE_Account_Mapping__c> accountMappingList = new List<ASI_TnE_Account_Mapping__c>();
        ASI_TnE_Account_Mapping__c accountMapping1 = new ASI_TnE_Account_Mapping__c(CURRENCYISOCODE='JPY', ASI_TNE_ACCOUNT_NUMBER__C='6130.GENER', ASI_TNE_COUNTRY__C='JP', ASI_TNE_EXPENSE_TYPE__C='', ASI_JP_TNE_ACCOUNT_NAME__C='Travel');
        accountMappingList.add(accountMapping1); 
        ASI_TnE_Account_Mapping__c accountMapping2 = new ASI_TnE_Account_Mapping__c(CURRENCYISOCODE='JPY', ASI_TNE_ACCOUNT_NUMBER__C='6145.OTHER', ASI_TNE_COUNTRY__C='JP', ASI_TNE_EXPENSE_TYPE__C='', ASI_JP_TNE_ACCOUNT_NAME__C='Car Expense (Park)');
        accountMappingList.add(accountMapping2); 
        ASI_TnE_Account_Mapping__c accountMapping3 = new ASI_TnE_Account_Mapping__c(CURRENCYISOCODE='JPY', ASI_TNE_ACCOUNT_NUMBER__C='6120.MEAL', ASI_TNE_COUNTRY__C='JP', ASI_TNE_EXPENSE_TYPE__C='', ASI_JP_TNE_ACCOUNT_NAME__C='Meal Allowance');
        accountMappingList.add(accountMapping3); 
        insert accountMappingList;
        return accountMappingList;
    }
    
    public static List<ASI_JP_TnE_Expense_Classification__c> createExpenseClassTestData()
    {
        
        List<ASI_JP_TnE_Expense_Category__c > expenseCategoryList = createExpenseCategoryTestData();
        List<ASI_TnE_Account_Mapping__c> accountMappingList = createAccountMappingTestData();
        
        ASI_JP_TnE_Expense_Category__c category = expenseCategoryList.get(0);
        //[Select Id from ASI_JP_TnE_Expense_Category__c LIMIT 1];
        ASI_TnE_Account_Mapping__c  accountMapping =  accountMappingList.get(0);
        //[Select Id from ASI_TnE_Account_Mapping__c LIMIT 1];
        
        
        List<ASI_JP_TnE_Expense_Classification__c> expenseClassificationList = new
        List<ASI_JP_TnE_Expense_Classification__c>();
        
        ASI_JP_TnE_Expense_Classification__c expenseClassification1 = 
        new ASI_JP_TnE_Expense_Classification__c(NAME='Airplance', CURRENCYISOCODE='JPY', ASI_JP_TNE_EXPENSE_CATEGORY__C=category.Id , 
                                                    ASI_JP_TNE_ACCOUNT_MAPPING__C=accountMapping.Id, ASI_JP_TNE_TAX_FLAG__C=false, 
                                                    ASI_JP_TNE_MAXIMUM_AMOUNT__C=999999999, NAME_EN_US__C='Testing Japanese (Dont Select)', 
                                                    ASI_TNE_BC_CODE__C='N',ASI_Tne_JP_VAT_Rate__c='CP8',
                                                    ASI_TnE_Auto_Receipt_No__c = true);
        expenseClassificationList.add(expenseClassification1);
        
        ASI_JP_TnE_Expense_Classification__c expenseClassification2 = 
        new ASI_JP_TnE_Expense_Classification__c(NAME='Taxi', CURRENCYISOCODE='JPY', ASI_JP_TNE_EXPENSE_CATEGORY__C=category.Id , 
                                                ASI_JP_TNE_ACCOUNT_MAPPING__C=accountMapping.Id, ASI_JP_TNE_TAX_FLAG__C=true, 
                                                ASI_JP_TNE_MAXIMUM_AMOUNT__C=999999999, NAME_EN_US__C='Testing Japanese (Dont Select)', 
                                                ASI_TNE_BC_CODE__C='N');
        expenseClassificationList.add(expenseClassification2);     
        
        insert expenseClassificationList;
        
        return expenseClassificationList;
    }
    
    public static void createDueDateMapping()
    {
    

        Date todays = Date.today();
        Date period_from = todays.addMonths(-3);
        Date period_to = todays.addMonths(10);
        Date paymentdate = todays.addMonths(10);
        date closingdate = todays.addMonths(11);
        
        Date period_toToYear = todays.addMonths(10);
        Date paymentdateToYear = todays.addMonths(10);
        date closingDateToYear = todays.addMonths(11);
        while (closingDateToYear.year() != date.today().year() || paymentdateToYear.year() != date.today().year() || period_toToYear.year() != date.today().year())
        {
            paymentdateToYear = todays.addMonths(-1);
            closingDateToYear = todays.addMonths(-1);
            period_toToYear = todays.addMonths(-1);
        }
    
        List<ASI_JP_TnE_Due_Date_Mapping__c> dueDateMappingList = new List<ASI_JP_TnE_Due_Date_Mapping__c>();
        ASI_JP_TnE_Due_Date_Mapping__c dueDateMapping1 = new ASI_JP_TnE_Due_Date_Mapping__c(
        CURRENCYISOCODE='EUR', 
        ASI_JP_TNE_PAYMENT_OPTION__C='Cash', 
        ASI_JP_TNE_DEPARTMENT_CATEGORY_CODE__C='1', 
        //Updated by Wilken
        ASI_JP_TNE_CLOSING_DATE__C=closingDateToYear, 
        ASI_JP_TNE_PAYMENT_DATE__C=paymentdateToYear, 
        ASI_JP_TNE_PERIOD_FROM__C=period_from, 
        ASI_JP_TNE_PERIOD_TO__C=period_toToYear
        
        /*ASI_JP_TNE_CLOSING_DATE__C=Date.newInstance(2014,02,04), 
        ASI_JP_TNE_PAYMENT_DATE__C=Date.newInstance(2014,02,13), 
        ASI_JP_TNE_PERIOD_FROM__C=Date.newInstance(2014,01,12), 
        ASI_JP_TNE_PERIOD_TO__C=Date.newInstance(2014,02,01)
        */
        );
     
        dueDateMappingList.add(dueDateMapping1); 
     
        ASI_JP_TnE_Due_Date_Mapping__c dueDateMapping2 = new ASI_JP_TnE_Due_Date_Mapping__c(
        CURRENCYISOCODE='EUR', 
        ASI_JP_TNE_PAYMENT_OPTION__C='Invoice', 
        ASI_JP_TNE_DEPARTMENT_CATEGORY_CODE__C='1', 
        //Updated by Wilken
        ASI_JP_TNE_CLOSING_DATE__C=closingdate, 
        ASI_JP_TNE_PAYMENT_DATE__C=paymentdate, 
        ASI_JP_TNE_PERIOD_FROM__C=period_from, 
        ASI_JP_TNE_PERIOD_TO__C=period_to
        /*
        ASI_JP_TNE_CLOSING_DATE__C=Date.newInstance(2014,02,04), 
        ASI_JP_TNE_PAYMENT_DATE__C=Date.newInstance(2014,02,13), 
        ASI_JP_TNE_PERIOD_FROM__C=Date.newInstance(2014,01,12), 
        ASI_JP_TNE_PERIOD_TO__C=Date.newInstance(2014,02,01)*/
        );
 
        dueDateMappingList.add(dueDateMapping2); 
        
        ASI_JP_TnE_Due_Date_Mapping__c dueDateMapping3 = new ASI_JP_TnE_Due_Date_Mapping__c(
        CURRENCYISOCODE='EUR', 
        ASI_JP_TNE_PAYMENT_OPTION__C='DC Card(Mgr.)', 
        ASI_JP_TNE_DEPARTMENT_CATEGORY_CODE__C='1', 
        ASI_JP_TNE_CLOSING_DATE__C=closingdate, 
        ASI_JP_TNE_PAYMENT_DATE__C=paymentdate, 
        ASI_JP_TNE_PERIOD_FROM__C=period_from, 
        ASI_JP_TNE_PERIOD_TO__C=period_to
        );

        dueDateMappingList.add(dueDateMapping3); 

        ASI_JP_TnE_Due_Date_Mapping__c dueDateMapping4 = new ASI_JP_TnE_Due_Date_Mapping__c(
        CURRENCYISOCODE='EUR', 
        ASI_JP_TNE_PAYMENT_OPTION__C='DC Card(Mgr.)', 
        ASI_JP_TNE_DEPARTMENT_CATEGORY_CODE__C='2', 
        ASI_JP_TNE_CLOSING_DATE__C=closingdate, 
        ASI_JP_TNE_PAYMENT_DATE__C=paymentdate, 
        ASI_JP_TNE_PERIOD_FROM__C=period_from, 
        ASI_JP_TNE_PERIOD_TO__C=period_to
        );

        dueDateMappingList.add(dueDateMapping4);
        
        ASI_JP_TnE_Due_Date_Mapping__c dueDateMapping5 = new ASI_JP_TnE_Due_Date_Mapping__c(
        CURRENCYISOCODE='EUR', 
        ASI_JP_TNE_PAYMENT_OPTION__C='Cash', 
        ASI_JP_TNE_DEPARTMENT_CATEGORY_CODE__C='1', 
        ASI_JP_TNE_CLOSING_DATE__C=closingdate, 
        ASI_JP_TNE_PAYMENT_DATE__C=paymentdate, 
        ASI_JP_TNE_PERIOD_FROM__C=period_from, 
        ASI_JP_TNE_PERIOD_TO__C=period_to
        );

        dueDateMappingList.add(dueDateMapping5); 

        ASI_JP_TnE_Due_Date_Mapping__c dueDateMapping6 = new ASI_JP_TnE_Due_Date_Mapping__c(
        CURRENCYISOCODE='EUR', 
        ASI_JP_TNE_PAYMENT_OPTION__C='Cash', 
        ASI_JP_TNE_DEPARTMENT_CATEGORY_CODE__C='1', 
        ASI_JP_TNE_CLOSING_DATE__C=closingdate, 
        ASI_JP_TNE_PAYMENT_DATE__C=paymentdate, 
        ASI_JP_TNE_PERIOD_FROM__C=period_from, 
        ASI_JP_TNE_PERIOD_TO__C=period_to
        );

        dueDateMappingList.add(dueDateMapping6); 
     
        insert(dueDateMappingList); 
    }
    
    public static ASI_TnE_ClaimHeader__c createClaimHeaderPaperRecordType()
    {
        //ADDED BY GDT TEAM
        Date GDT_Todays = Date.today();
        Date GDT_Date = GDT_Todays.addMonths(-1);
        //
        
        RecordType paperRecordType = [SELECT Id from RecordType where DeveloperName = 
        'ASI_JP_TnE_Paper_Approval_Claim_Header' LIMIT 1 ];
        User user = createUser();
        ASI_TnE_ClaimHeader__c claimHeader1 = new ASI_TnE_ClaimHeader__c(CURRENCYISOCODE='EUR', 
        RECORDTYPEID=paperRecordType.Id, 
        ASI_TNE_3RD_PARTY__C=false, 
        
        //MODIFIED BY GDT TEAM
        //ASI_TNE_DATE__C= Date.newInstance(2014,2,4), 
        ASI_TNE_DATE__C= GDT_Date,
        
        ASI_TNE_PAYMENT_OPTION__C='Cash', 
        ASI_TNE_STATUS__C='Draft');

        claimHeader1.ownerId = user.Id;
        
        insert claimHeader1;
        
        return claimHeader1;
    
    }
    
    public static ASI_TnE_ClaimHeader__c createClaimHeaderPaperRecordTypeWithDcManager()
    {
        
        RecordType paperRecordType = [SELECT Id from RecordType where DeveloperName = 
        'ASI_JP_TnE_Paper_Approval_Claim_Header' LIMIT 1 ];
        User user = createUser('test@testing123132423455.com');
        ASI_TnE_ClaimHeader__c claimHeader1 = new ASI_TnE_ClaimHeader__c(CURRENCYISOCODE='EUR', 
        RECORDTYPEID=paperRecordType.Id, 
        ASI_TNE_3RD_PARTY__C=false, 
        //Updated by Wilken
        ASI_TNE_DATE__C= Date.today().addMonths(-1),
        //ASI_TNE_DATE__C= Date.newInstance(2014,2,4), 
        ASI_TnE_Payment_Option__c = 'DC Card(Mgr.)', 
        ASI_TNE_STATUS__C='Draft');

        claimHeader1.ownerId = user.Id;
        
        insert claimHeader1;
        
        return claimHeader1;
    
    }
    
    public static ASI_TnE_ClaimHeader__c createClaimHeaderPaperRecordType(Date customDate)
    {
        
        RecordType paperRecordType = [SELECT Id from RecordType where DeveloperName = 
        'ASI_JP_TnE_Paper_Approval_Claim_Header' LIMIT 1 ];
        User user = createUser('test@testing1231324234.com');
        ASI_TnE_ClaimHeader__c claimHeader1 = new ASI_TnE_ClaimHeader__c(CURRENCYISOCODE='EUR', 
        RECORDTYPEID=paperRecordType.Id, 
        ASI_TNE_3RD_PARTY__C=false, 
        ASI_TNE_DATE__C= customDate, 
        ASI_TNE_STATUS__C='Draft',
        ASI_TNE_PAYMENT_OPTION__C='Cash'
        );

        claimHeader1.ownerId = user.Id;
        
        insert claimHeader1;
        
        return claimHeader1;
    
    }
    
    public static List<ASI_TnE_ClaimDetail__c> createClaimDetails(ASI_TnE_ClaimHeader__c claimHeader)
    {
      
      List<ASI_JP_TnE_Expense_Classification__c> expenseClassification = createExpenseClassTestData();
      ASI_JP_TnE_Expense_Classification__c expenseClass = expenseClassification.get(0);
      
      RecordType claimDetailRecordType = [Select Id from RecordType where DeveloperName = 'ASI_JP_TnE_Claim_Detail'];
      
      List<ASI_TnE_ClaimDetail__c> claimDetails = new List<ASI_TnE_ClaimDetail__c>();
      ASI_TnE_ClaimDetail__c claimDetail = new ASI_TnE_ClaimDetail__c(
      //Updated by Wilken
      ASI_TnE_Receipt_Date__c = Date.today().addMonths(-1),
      //ASI_TnE_Receipt_Date__c=Date.newInstance(2014,2,1), 
      ASI_TnE_Expense_Category__c=expenseClass.ASI_JP_TnE_Expense_Category__c, 
      ASI_TnE_Expense_Classification__c=expenseClass.Id,                     
      ASI_TnE_Currency__c='HKD',
      ASI_TnE_Receipt_Amount__c=5000,
      ASI_TnE_FX_Rate__c=10,
      ASI_TnE_Receipt_Number__c=1,                                
      ASI_TnE_Total_Number_Pax__c=1,
      ASI_TnE_Attendee_Name__c='me',
      ASI_TnE_Details_of_Expense__c='details', 
      ASI_TnE_ClaimHeader__c = claimHeader.Id,
      ASI_TnE_Taxable_Amount__c = 1000,
      RecordTypeId = claimDetailRecordType.Id     
      );
          
      claimDetails.add(claimDetail);
      
      ASI_TnE_ClaimDetail__c claimDetail1 = new ASI_TnE_ClaimDetail__c(
      //Updated by Wilken
      ASI_TnE_Receipt_Date__c = Date.today().addMonths(-1),
      //ASI_TnE_Receipt_Date__c=Date.newInstance(2014,2,1), 
      ASI_TnE_Expense_Category__c=expenseClass.ASI_JP_TnE_Expense_Category__c, 
      ASI_TnE_Expense_Classification__c=expenseClassification.get(1).id,                     
      ASI_TnE_Currency__c='JPY',
      ASI_TnE_Receipt_Amount__c=5000,
      ASI_TnE_FX_Rate__c=1,
      ASI_TnE_Receipt_Number__c=1,                                
      ASI_TnE_Total_Number_Pax__c=1,
      ASI_TnE_Attendee_Name__c='me',
      ASI_TnE_Details_of_Expense__c='details', 
      ASI_TnE_ClaimHeader__c = claimHeader.Id,
      ASI_TnE_Taxable_Amount__c = 1000,
      RecordTypeId = claimDetailRecordType.Id     
      );
          
      claimDetails.add(claimDetail1);
      
      insert claimDetails;    
      
      return claimDetails;
    }
    
    public static ASI_TnE_ClaimHeader__c createClaimHeadereApproval()
    {
        
        RecordType eApprovalRecordType = [SELECT Id from RecordType where DeveloperName = 
        'ASI_JP_TnE_eApproval_Claim_Header' LIMIT 1 ];
        User user = createUser();
        ASI_TnE_ClaimHeader__c claimHeader1 = new ASI_TnE_ClaimHeader__c(CURRENCYISOCODE='EUR', 
        RECORDTYPEID=eApprovalRecordType.Id, 
        ASI_TNE_3RD_PARTY__C=false, 
        //Updated by Wilken
        ASI_TNE_DATE__C = Date.today(),
        //ASI_TNE_DATE__C= Date.newInstance(2014,2,4), 
        ASI_TNE_PAYMENT_OPTION__C='Cash', 
        ASI_TNE_STATUS__C='Draft');

        claimHeader1.ownerId = user.Id;
        
        insert claimHeader1;
        
        return claimHeader1;    
    }
    
    public static User createUser()
    {
                    
        Profile profile = [SELECT Id 
                         FROM profile WHERE name = 'ASI JP Standard User'];   
         
        User normalUser = new User(
        username = 'testqwe12390nsd@test123.com',
        Email = 'test1234nsd@test123.com',
        lastName = 'normalUser',
        firstName = 'nomalUser',
        alias  = 'nrmUsr12',
        languagelocalekey = 'en_US',
        localesidkey = 'en_US',
        emailEncodingKey = 'UTF-8',
        timeZoneSidKey = 'America/Los_Angeles',
        ASI_JP_TnE_Department_Category_Code__c = '1',
        ASI_TnE_Department_Code__c = 'DptCode',
        ASI_TnE_Sub_Ledger__c = 'SUBLEDGE',
        profileId = profile.id
        );
        
        insert normalUser;
        
        /*
        Group currentGroup = [SELECT Id from Group where DeveloperName = 'ASI_JP_TnE_All_Users' LIMIT 1];
        GroupMember groupMember = new GroupMember(
         GroupId = currentGroup.Id,
         UserOrGroupId = normalUser.Id
        );*/
        
        return normalUser;
        //insert groupMember;
        
    }
    
    public static User createUser(String customUserName)
    {
                    
        Profile profile = [SELECT Id 
                         FROM profile WHERE name = 'System Administrator'];   
         
        User normalUser = new User(
        username = customUserName,
        companyName = 'Pernod Ricard Japan',
        Email = customUserName,
        lastName = 'normalUser' + customUserName,
        firstName = 'nomalUser' + customUserName,
        alias  = 'nrmUsr13',
        languagelocalekey = 'en_US',
        localesidkey = 'en_US',
        emailEncodingKey = 'UTF-8',
        timeZoneSidKey = 'America/Los_Angeles',
        ASI_JP_TnE_Department_Category_Code__c = '1',
        ASI_TnE_Department_Code__c = 'DptCode',
        ASI_TnE_Sub_Ledger__c = 'SUBLEDGE',
        profileId = profile.id
        );
        
        insert normalUser;
        
        /*
        Group currentGroup = [SELECT Id from Group where DeveloperName = 'ASI_JP_TnE_All_Users' LIMIT 1];
        GroupMember groupMember = new GroupMember(
         GroupId = currentGroup.Id,
         UserOrGroupId = normalUser.Id
        );*/
        
        return normalUser;
        //insert groupMember;
        
    }



}