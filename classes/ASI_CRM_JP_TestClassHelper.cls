/*********************************************************************************
 * Name:ASI_CRM_JP_TestClassHelper
 * Description: For generating test data for ASI CRM JP
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------
 * 9/1/2015       Laputa: Hank          Created
*********************************************************************************/
@isTest
public class ASI_CRM_JP_TestClassHelper {
    
    //Create custom settings: ASI_CRM_JP_Tax_Routing_Tbl__c
    public static void createTaxRoutingTbl(){
        insert new ASI_JP_TnE_Tax_Date_Mapping__c(Name = 'test', ASI_JP_TnE_Start_Date__c = system.today().addYears(-1), ASI_JP_TnE_End_Date__c = system.today().addYears(1), ASI_JP_TnE_Tax_Rate__c = 0.05);
        List<ASI_CRM_JP_Tax_Routing_Tbl__c> routTbl = new List<ASI_CRM_JP_Tax_Routing_Tbl__c>();
        routTbl.add(new ASI_CRM_JP_Tax_Routing_Tbl__c(Name = '1.1', ASI_CRM_JP_Brand__c = 'PERRIER JOUET', ASI_CRM_JP_Stage__c = 1, ASI_CRM_JP_Type__c = 'Integer', ASI_CRM_JP_Value__c = '5000'));
        routTbl.add(new ASI_CRM_JP_Tax_Routing_Tbl__c(Name = '1.2', ASI_CRM_JP_Brand__c = 'PERRIER JOUET', ASI_CRM_JP_Stage__c = 2, ASI_CRM_JP_Type__c = 'Integer', ASI_CRM_JP_Value__c = '2'));
        routTbl.add(new ASI_CRM_JP_Tax_Routing_Tbl__c(Name = '1.3', ASI_CRM_JP_Brand__c = 'PERRIER JOUET', ASI_CRM_JP_Stage__c = 3, ASI_CRM_JP_Type__c = 'Integer', ASI_CRM_JP_Value__c = '4'));
        routTbl.add(new ASI_CRM_JP_Tax_Routing_Tbl__c(Name = '1.4', ASI_CRM_JP_Brand__c = 'PERRIER JOUET', ASI_CRM_JP_Stage__c = 4, ASI_CRM_JP_Type__c = 'Integer', ASI_CRM_JP_Value__c = '3'));
        routTbl.add(new ASI_CRM_JP_Tax_Routing_Tbl__c(Name = '1.5', ASI_CRM_JP_Brand__c = 'PERRIER JOUET', ASI_CRM_JP_Stage__c = 5, ASI_CRM_JP_Type__c = 'Boolean', ASI_CRM_JP_Value__c = 'true'));
        routTbl.add(new ASI_CRM_JP_Tax_Routing_Tbl__c(Name = '1.6', ASI_CRM_JP_Brand__c = 'PERRIER JOUET', ASI_CRM_JP_Stage__c = 6, ASI_CRM_JP_Type__c = 'Integer', ASI_CRM_JP_Value__c = '8000'));
        routTbl.add(new ASI_CRM_JP_Tax_Routing_Tbl__c(Name = '1.7', ASI_CRM_JP_Brand__c = 'PERRIER JOUET', ASI_CRM_JP_Stage__c = 7, ASI_CRM_JP_Type__c = 'Integer', ASI_CRM_JP_Value__c = '3000'));
        routTbl.add(new ASI_CRM_JP_Tax_Routing_Tbl__c(Name = '2.1', ASI_CRM_JP_Brand__c = 'Dohan', ASI_CRM_JP_Stage__c = 1, ASI_CRM_JP_Type__c = 'Integer', ASI_CRM_JP_Value__c = '5000'));
        routTbl.add(new ASI_CRM_JP_Tax_Routing_Tbl__c(Name = '3.1', ASI_CRM_JP_Brand__c = 'CHIVAS REGAL;MARTELL', ASI_CRM_JP_Stage__c = 1, ASI_CRM_JP_Type__c = 'Integer', ASI_CRM_JP_Value__c = '5000'));
        routTbl.add(new ASI_CRM_JP_Tax_Routing_Tbl__c(Name = '3.2', ASI_CRM_JP_Brand__c = 'CHIVAS REGAL;MARTELL', ASI_CRM_JP_Stage__c = 2, ASI_CRM_JP_Type__c = 'Integer', ASI_CRM_JP_Value__c = '2'));
        routTbl.add(new ASI_CRM_JP_Tax_Routing_Tbl__c(Name = '3.3', ASI_CRM_JP_Brand__c = 'CHIVAS REGAL;MARTELL', ASI_CRM_JP_Stage__c = 3, ASI_CRM_JP_Type__c = 'Integer', ASI_CRM_JP_Value__c = '4'));
        routTbl.add(new ASI_CRM_JP_Tax_Routing_Tbl__c(Name = '3.4', ASI_CRM_JP_Brand__c = 'CHIVAS REGAL;MARTELL', ASI_CRM_JP_Stage__c = 4, ASI_CRM_JP_Type__c = 'Integer', ASI_CRM_JP_Value__c = '3'));
        routTbl.add(new ASI_CRM_JP_Tax_Routing_Tbl__c(Name = '3.5', ASI_CRM_JP_Brand__c = 'CHIVAS REGAL;MARTELL', ASI_CRM_JP_Stage__c = 5, ASI_CRM_JP_Type__c = 'String', ASI_CRM_JP_Value__c = '300;400;High;Middle'));
        routTbl.add(new ASI_CRM_JP_Tax_Routing_Tbl__c(Name = '3.6', ASI_CRM_JP_Brand__c = 'CHIVAS REGAL;MARTELL', ASI_CRM_JP_Stage__c = 6, ASI_CRM_JP_Type__c = 'Boolean', ASI_CRM_JP_Value__c = 'true'));
        routTbl.add(new ASI_CRM_JP_Tax_Routing_Tbl__c(Name = '3.7', ASI_CRM_JP_Brand__c = 'CHIVAS REGAL;MARTELL', ASI_CRM_JP_Stage__c = 7, ASI_CRM_JP_Type__c = 'Integer', ASI_CRM_JP_Value__c = '80000'));
        routTbl.add(new ASI_CRM_JP_Tax_Routing_Tbl__c(Name = '3.8', ASI_CRM_JP_Brand__c = 'CHIVAS REGAL;MARTELL', ASI_CRM_JP_Stage__c = 8, ASI_CRM_JP_Type__c = 'Integer', ASI_CRM_JP_Value__c = '30000'));
        routTbl.add(new ASI_CRM_JP_Tax_Routing_Tbl__c(Name = '3.9', ASI_CRM_JP_Brand__c = 'CHIVAS REGAL;MARTELL', ASI_CRM_JP_Stage__c = 9, ASI_CRM_JP_Type__c = 'Integer', ASI_CRM_JP_Value__c = '22000'));
        routTbl.add(new ASI_CRM_JP_Tax_Routing_Tbl__c(Name = '4.1', ASI_CRM_JP_Brand__c = 'MUMM;CAFE de PARIS;Others', ASI_CRM_JP_Stage__c = 1, ASI_CRM_JP_Type__c = 'Integer', ASI_CRM_JP_Value__c = '5000'));
        routTbl.add(new ASI_CRM_JP_Tax_Routing_Tbl__c(Name = '4.2', ASI_CRM_JP_Brand__c = 'MUMM;CAFE de PARIS;Others', ASI_CRM_JP_Stage__c = 2, ASI_CRM_JP_Type__c = 'Integer', ASI_CRM_JP_Value__c = '2'));
        routTbl.add(new ASI_CRM_JP_Tax_Routing_Tbl__c(Name = '4.3', ASI_CRM_JP_Brand__c = 'MUMM;CAFE de PARIS;Others', ASI_CRM_JP_Stage__c = 3, ASI_CRM_JP_Type__c = 'Integer', ASI_CRM_JP_Value__c = '4'));
        routTbl.add(new ASI_CRM_JP_Tax_Routing_Tbl__c(Name = '4.4', ASI_CRM_JP_Brand__c = 'MUMM;CAFE de PARIS;Others', ASI_CRM_JP_Stage__c = 4, ASI_CRM_JP_Type__c = 'Integer', ASI_CRM_JP_Value__c = '3'));
        routTbl.add(new ASI_CRM_JP_Tax_Routing_Tbl__c(Name = '4.5', ASI_CRM_JP_Brand__c = 'MUMM;CAFE de PARIS;Others', ASI_CRM_JP_Stage__c = 5, ASI_CRM_JP_Type__c = 'String', ASI_CRM_JP_Value__c = '300;400;High;Middle'));
        routTbl.add(new ASI_CRM_JP_Tax_Routing_Tbl__c(Name = '4.6', ASI_CRM_JP_Brand__c = 'MUMM;CAFE de PARIS;Others', ASI_CRM_JP_Stage__c = 6, ASI_CRM_JP_Type__c = 'Integer', ASI_CRM_JP_Value__c = '22000'));
        insert routTbl;
    }
    
    //Create Running numbers
    public static void createRunningNumbers(){
        List<ASI_HK_CRM_Running_Number__c> runingNumberList = new List<ASI_HK_CRM_Running_Number__c>();
        runingNumberList.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c = 'ASI_CRM_JP_PaymentInvoice_No', ASI_HK_CRM_First_Month_of_Fiscal_Year__c = 1, ASI_HK_CRM_Format__c = 'INV{YY}{00000}', ASI_HK_CRM_Running_Number__c = 2));
        runingNumberList.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c = 'ASI_CRM_JP_PaymentInvoice_Cash_No', ASI_HK_CRM_First_Month_of_Fiscal_Year__c = 1, ASI_HK_CRM_Format__c = 'W{YY}{00000}', ASI_HK_CRM_Running_Number__c = 2));
        runingNumberList.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c = 'ASI_CRM_JP_PaymentInvoice_JDE_Group_Name', ASI_HK_CRM_First_Month_of_Fiscal_Year__c = 1, ASI_HK_CRM_Format__c = 'G{YY}{00000}', ASI_HK_CRM_Running_Number__c = 2));
        runingNumberList.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c = 'ASI_CRM_JP_PaymentInvoice_Rebate_No', ASI_HK_CRM_First_Month_of_Fiscal_Year__c = 1, ASI_HK_CRM_Format__c = 'P{YY}{00000}', ASI_HK_CRM_Running_Number__c = 2));
        runingNumberList.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c = 'ASI_CRM_JP_Contract_No', ASI_HK_CRM_First_Month_of_Fiscal_Year__c = 1, ASI_HK_CRM_Format__c = 'R{YY}{00000}', ASI_HK_CRM_Running_Number__c = 2));
        runingNumberList.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c = 'ASI_CRM_JP_Customer_Code', ASI_HK_CRM_First_Month_of_Fiscal_Year__c = 12, ASI_HK_CRM_Format__c = '900{00000}', ASI_HK_CRM_Running_Number__c = 2));
        runingNumberList.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c = 'ASI_JP_TnE_Document_Number', ASI_HK_CRM_First_Month_of_Fiscal_Year__c = 1, ASI_HK_CRM_Format__c = '{YY}{MM}{000}', ASI_HK_CRM_Running_Number__c = 2));
        insert runingNumberList;
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
    
    
    public static ASI_TnE_ClaimHeader__c createClaimHeaderPaperRecordType()
    {
        //ADDED BY GDT TEAM
        Date GDT_Todays = Date.today();
        Date GDT_Date = GDT_Todays.addMonths(-1);
        //
        
        User user = createUser('forClaim');
        ASI_TnE_ClaimHeader__c claimHeader1 = new ASI_TnE_ClaimHeader__c(CURRENCYISOCODE='EUR', 
        RECORDTYPEID = Global_RecordTypeCache.getRtId('ASI_TnE_ClaimHeader__cASI_JP_TnE_Paper_Approval_Claim_Header'),
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
    
    //Create User with parameter
    public static User createUser(String userId){
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User u1 = new User(Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, ASI_JP_TnE_Department_Category_Code__c = '1',
            TimeZoneSidKey='America/Los_Angeles', UserName= userId + '@laputa.com');
        insert u1;
        return u1;
    }
    
    //Create Outlet Type
    public static ASI_TH_CRM_OutletType__c createOutletType(String OTName){
        ASI_TH_CRM_OutletType__c outletType = new ASI_TH_CRM_OutletType__c(Name = OTName);
        insert outletType;
        return outletType ;
    }
    
    //Create Postal Code
    public static ASI_CRM_Postal_Code__c createPostalCode(String postalCode){
        ASI_CRM_Postal_Code__c postal = new ASI_CRM_Postal_Code__c(Name = postalCode);
        insert postal;
        return postal;
    }
    
    //Create Customer without parameters
    public static ASI_CRM_AccountsAdditionalField__c createCustomer(){
        ASI_TH_CRM_OutletType__c outletType = createOutletType('Test0');
        ASI_CRM_Postal_Code__c postalCode = ASI_CRM_JP_TestClassHelper.createPostalCode('0000000');
        ASI_CRM_AccountsAdditionalField__c customer = new ASI_CRM_AccountsAdditionalField__c(Name='Test0', RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_JP_On_Trade_Outlet'), ASI_TH_CRM_OutletType__c = outletType.Id, ASI_CRM_PostalCode__c = postalCode.Name);
        insert customer;
        return customer;
    }
    
    //Create Due Date Mapping
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
        CURRENCYISOCODE='JPY', 
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
        CURRENCYISOCODE='JPY', 
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
        CURRENCYISOCODE='JPY', 
        ASI_JP_TNE_PAYMENT_OPTION__C='DC Card(Mgr.)', 
        ASI_JP_TNE_DEPARTMENT_CATEGORY_CODE__C='1', 
        ASI_JP_TNE_CLOSING_DATE__C=closingdate, 
        ASI_JP_TNE_PAYMENT_DATE__C=paymentdate, 
        ASI_JP_TNE_PERIOD_FROM__C=period_from, 
        ASI_JP_TNE_PERIOD_TO__C=period_to
        );

        dueDateMappingList.add(dueDateMapping3); 

        ASI_JP_TnE_Due_Date_Mapping__c dueDateMapping4 = new ASI_JP_TnE_Due_Date_Mapping__c(
        CURRENCYISOCODE='JPY', 
        ASI_JP_TNE_PAYMENT_OPTION__C='DC Card(Mgr.)', 
        ASI_JP_TNE_DEPARTMENT_CATEGORY_CODE__C='2', 
        ASI_JP_TNE_CLOSING_DATE__C=closingdate, 
        ASI_JP_TNE_PAYMENT_DATE__C=paymentdate, 
        ASI_JP_TNE_PERIOD_FROM__C=period_from, 
        ASI_JP_TNE_PERIOD_TO__C=period_to
        );

        dueDateMappingList.add(dueDateMapping4);
        
        ASI_JP_TnE_Due_Date_Mapping__c dueDateMapping5 = new ASI_JP_TnE_Due_Date_Mapping__c(
        CURRENCYISOCODE='JPY', 
        ASI_JP_TNE_PAYMENT_OPTION__C='Cash', 
        ASI_JP_TNE_DEPARTMENT_CATEGORY_CODE__C='1', 
        ASI_JP_TNE_CLOSING_DATE__C=closingdate, 
        ASI_JP_TNE_PAYMENT_DATE__C=paymentdate, 
        ASI_JP_TNE_PERIOD_FROM__C=period_from, 
        ASI_JP_TNE_PERIOD_TO__C=period_to
        );

        dueDateMappingList.add(dueDateMapping5); 

        ASI_JP_TnE_Due_Date_Mapping__c dueDateMapping6 = new ASI_JP_TnE_Due_Date_Mapping__c(
        CURRENCYISOCODE='JPY', 
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
    
    //Create Item Group with Representative SKU
    public static ASI_MFM_Item_Group__c createItemGroup(){
        ASI_MFM_SKU_Code__c sku = new ASI_MFM_SKU_Code__c(RecordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_SKU_Code__cASI_CRM_JP_SKU'));
        insert sku;
        return new ASI_MFM_Item_Group__c(RecordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Item_Group__cASI_CRM_JP_Item_Group'), ASI_CRM_Representative_SKU__c = sku.id);
    }
    
    //Create Test Date
    public static date createTestDate(){
        Integer year;
        if(system.today().month() > 6){
            year = system.today().year() + 1;
        }else{
            year = system.today().year();
        }
        return date.newInstance(year, 1, 1);
    }
}