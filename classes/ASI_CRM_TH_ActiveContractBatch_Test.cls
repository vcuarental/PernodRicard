@isTest
private class ASI_CRM_TH_ActiveContractBatch_Test {

    static testmethod void ASI_CRM_TH_ActiveContractBatch() {    
        user u = [SELECT id FROM user WHERE profile.Name like '%System Administrator%' and isactive = true LIMIT 1];
         
        ASI_TH_CRM_CustomSetting__c sdate = new ASI_TH_CRM_CustomSetting__c(ASI_CRM_TH_Snapshot_Date__c=date.today()) ;
        insert sdate;
        
        //Create Contract
        ASI_HK_CRM_Running_Number__c customerCodeRunningNumber = new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c = 'ASI_TH_CRM_Customer_Code', ASI_HK_CRM_Running_Number__c = 1,
        ASI_HK_CRM_First_Month_of_Fiscal_Year__c = 6 , ASI_HK_CRM_Format__c = 'TH_A{000000}' );        
        try{
            insert customerCodeRunningNumber;
        } catch (System.DmlException e) {
        }
    
        ASI_HK_CRM_Running_Number__c contractRunningNumber = new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c = 'ASI_TH_CRM_Contract__c', ASI_HK_CRM_Running_Number__c = 1,
        ASI_HK_CRM_First_Month_of_Fiscal_Year__c = 6 , ASI_HK_CRM_Format__c = '{YY/YY}{0000}' );        
        try{
            insert contractRunningNumber;    
        } catch (System.DmlException e) {
        }
        
        ASI_HK_CRM_Running_Number__c paymentRequestRunningNumber= new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c = 'ASI_TH_CRM_PaymentRequest__c', ASI_HK_CRM_Running_Number__c = 1,
        ASI_HK_CRM_First_Month_of_Fiscal_Year__c = 6 , ASI_HK_CRM_Format__c = '60{YY}{0000}' );        
        try{
            insert paymentRequestRunningNumber;                    
        } catch (System.DmlException e) {
        }

        Account Outlet = new Account(Name='Test Outlet', RecordTypeid = Global_RecordTypeCache.getRTId('AccountASI_TH_CRM_Outlet'), ownerid = u.id  );
        insert Outlet ;                            
        
        List<ASI_TH_CRM_Contract__c> listContract = new List<ASI_TH_CRM_Contract__c>();
        ASI_TH_CRM_Contract__c contract = new ASI_TH_CRM_Contract__c(Name = '-', ASI_TH_CRM_Outlet__c = Outlet.id, ASI_TH_CRM_Start_Date__c = date.newinstance(date.today().year()-2,06,01), 
        ASI_TH_CRM_End_Date__c = date.newinstance(date.today().year()+1,07,01), ASI_TH_CRM_Total_Fund_Advance__c = 10000, ASI_TH_CRM_Contract_Status__c='Editing',
        RecordTypeID = Global_RecordTypeCache.getRTId('ASI_TH_CRM_Contract__cASI_TH_CRM_Contract'));
        listContract.add(contract);
        
        contract = new ASI_TH_CRM_Contract__c(Name = '-', ASI_TH_CRM_Outlet__c = Outlet.id, ASI_TH_CRM_Start_Date__c =date.newinstance(date.today().year()-3,06,01), 
        ASI_TH_CRM_End_Date__c = date.newinstance(date.today().year()-2,07,01), ASI_TH_CRM_Total_Fund_Advance__c = 10000, ASI_TH_CRM_Contract_Status__c='Editing',
        RecordTypeID = Global_RecordTypeCache.getRTId('ASI_TH_CRM_Contract__cASI_TH_CRM_Contract'));
        listContract.add(contract);
        
        contract = new ASI_TH_CRM_Contract__c(Name = '-', ASI_TH_CRM_Outlet__c = Outlet.id, ASI_TH_CRM_Start_Date__c =date.newinstance(date.today().year()-1,06,01), 
        ASI_TH_CRM_End_Date__c = date.newinstance(date.today().year()+1,07,01), ASI_TH_CRM_Total_Fund_Advance__c = 10000, ASI_TH_CRM_Contract_Status__c='Editing',
        RecordTypeID = Global_RecordTypeCache.getRTId('ASI_TH_CRM_Contract__cASI_TH_CRM_Contract'));
        listContract.add(contract);
        
        contract = new ASI_TH_CRM_Contract__c(Name = '-', ASI_TH_CRM_Outlet__c = Outlet.id, ASI_TH_CRM_Start_Date__c =date.newinstance(date.today().year(),06,01), 
        ASI_TH_CRM_End_Date__c = date.newinstance(date.today().year()+1,07,01), ASI_TH_CRM_Total_Fund_Advance__c = 10000, ASI_TH_CRM_Contract_Status__c='Editing',
        RecordTypeID = Global_RecordTypeCache.getRTId('ASI_TH_CRM_Contract__cASI_TH_CRM_Contract'));
        listContract.add(contract);    
        
        insert listContract;
        
        ASI_CRM_No_of_Active_Contracts__c acontract = new ASI_CRM_No_of_Active_Contracts__c(ASI_CRM_Fiscal_Year__c = 'FY'+string.valueof(date.today().year()-1).subString(2,4)+string.valueof(date.today().year()).subString(2,4),
        ASI_CRM_Snapshot_Date__c=date.today(), ASI_CRM_No_of_Active_Contracts__c=1, ASI_CRM_No_of_Active_Contracts_YTD__c=1, ASI_CRM_Account__c=Outlet.id);
        insert acontract;
    
         Test.startTest();
         database.executebatch(new ASI_CRM_TH_ActiveContractBatch());
         Test.stopTest();
    }
    
}