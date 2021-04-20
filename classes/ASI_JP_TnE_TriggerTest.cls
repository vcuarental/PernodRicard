@isTest
private class ASI_JP_TnE_TriggerTest
{
    @isTest
    public static void testASI_JP_TnE_Trigger()
    {   
        ASI_HK_CRM_Running_Number__c runnNumber = new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c = 'ASI_JP_TnE_Document_Number', 
                                                                                   ASI_HK_CRM_Format__c = '{YY}{MM}{000}', 
                                                                                   ASI_HK_CRM_Running_Number__c = 0);
        insert runnNumber;
        
        user userTest = ASI_JP_TnE_TestClassHelper.createUser('TESTNAME@TESDOMAIN.TESTCOM');
        
        map<string, id> rt_map = getRecordTypeId('Account');
        ASI_JP_TnE_TestClassHelper.createDueDateMapping();   
        
        List<ASI_JP_TnE_Tax_Date_Mapping__c> taxDateL=new List<ASI_JP_TnE_Tax_Date_Mapping__c>();
        
        ASI_JP_TnE_Tax_Date_Mapping__c customSettingsTax = new ASI_JP_TnE_Tax_Date_Mapping__c(Name = '201X_CP10', ASI_JP_TnE_Start_Date__c = Date.newInstance(date.today().year(),1,1),
                                                                                                ASI_JP_TnE_End_Date__c = Date.newInstance(date.today().year(),12,31),
                                                                                                ASI_TnE_Tax_Area__c = 'CP10',
                                                                                                ASI_JP_TnE_Tax_Rate__c = 0.1,
                                                                                                ASI_JP_TnE_IsDefault_Tax_Rate__c=true);

        taxDateL.add(customSettingsTax);
        
        customSettingsTax = new ASI_JP_TnE_Tax_Date_Mapping__c(Name = '201X_CP8', ASI_JP_TnE_Start_Date__c = Date.newInstance(date.today().year(),1,1),
                                                                                                ASI_JP_TnE_End_Date__c = Date.newInstance(date.today().year(),12,31),
                                                                                                ASI_TnE_Tax_Area__c = 'CP8',
                                                                                                ASI_JP_TnE_Tax_Rate__c = 0.08);

        
        taxDateL.add(customSettingsTax);
        insert taxDateL;
        
        ASI_MFM_Exchange_Rate__c exchangeTests = new ASI_MFM_Exchange_Rate__c( ASI_MFM_Application__c = 'MFM', ASI_MFM_Base_Currency__c ='JPY',
                                                                                ASI_MFM_Counter_Currency__c = 'HKD', ASI_MFM_Country__c = 'JP',
                                                                                ASI_MFM_Effective_Date__c = date.today().addMonths(-2),
                                                                                ASI_MFM_Exchange_Rate__c = 3.14
                                                                                );
                                                                                
        insert exchangeTests ;

        Account supplier86 = new Account(recordtypeid = rt_map.get('ASI_JP_Supplier'), name='testAcc', ASI_MFM_Customer_Supplier_Number__c = '86506');
        insert supplier86;
                
        ASI_JP_TnE_Expense_Classification__c expenseClassification3 = new ASI_JP_TnE_Expense_Classification__c(NAME='Taxi', CURRENCYISOCODE='JPY', 
                                                ASI_JP_TNE_TAX_FLAG__C=true, 
                                                ASI_JP_TNE_MAXIMUM_AMOUNT__C=999999999, NAME_EN_US__C='Testing Japanese (Dont Select)', 
                                                ASI_TNE_BC_CODE__C='N');   
        
        insert expenseClassification3;
        
        system.runAs(userTest)
        {
            test.startTest();
            ASI_TnE_ClaimHeader__c  claimHeader = ASI_JP_TnE_TestClassHelper.createClaimHeaderPaperRecordType();
            ASI_TnE_ClaimHeader__c  claimHeaderWithCustomdate = ASI_JP_TnE_TestClassHelper.createClaimHeaderPaperRecordType(Date.today()); 
            ASI_TnE_ClaimHeader__c  claimHeader1 = ASI_JP_TnE_TestClassHelper.createClaimHeaderPaperRecordTypeWithDcManager();
            List<ASI_TnE_ClaimDetail__c> claimDetails = ASI_JP_TnE_TestClassHelper.createClaimDetails(claimHeader);
            //user u = ASI_JP_TnE_TestClassHelper.createuser('lieuyekseng@yekseng.yekseng');
            //claimHeader.ownerid = u.id;
            //claimHeader.ASI_TnE_Payee_Employee__c = u.id;
            test.stopTest();
            update claimHeader;
            update claimDetails; 
            claimDetails.get(0).ASI_TnE_Tax_Area__c='CP8';
            update claimDetails;
            delete claimDetails; 
            delete claimHeader;
        }    
    
    }

    public static map<string, id> getRecordTypeId(string object_type) {
        map<string, id> rt_map = new map<string, id>();
        for (recordType rt:[select id, DeveloperName from recordType where SobjectType = :object_type]) {
            rt_map.put(rt.DeveloperName, rt.id);            
        }
        return rt_map;
    }
 
}