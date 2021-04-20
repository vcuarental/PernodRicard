@isTest(SeeAllData=true)
private class ASI_TH_CRM_TestClass2{    

    static Id checkRecordType(string strsobject, string rt_name){
        id RT_id;
        List<recordType> sobjectlist = Global_RecordTypeCache.getRtList(strsobject);
            for (recordtype pl : sobjectlist ){
                if (pl.developername == rt_name)
                RT_id = pl.id;
            }
            system.debug('RT_id: ' + RT_id);
            return RT_id;
            
    }
    static void submitAndProcessApprovalRequest(string id, string approverid) {        
        
        // Create an approval request for the account
        Approval.ProcessSubmitRequest req1 = 
            new Approval.ProcessSubmitRequest();
        req1.setComments('Submitting request for approval.');
        req1.setObjectId(id);
        
        // Submit the approval request for the account
        Approval.ProcessResult result = Approval.process(req1);
        
        // Verify the result
        System.assert(result.isSuccess());
        
        System.assertEquals(
            'Pending', result.getInstanceStatus(), 
            'Instance Status'+result.getInstanceStatus());
        
        // Approve the submitted request
        // First, get the ID of the newly created item
        List<Id> newWorkItemIds = result.getNewWorkitemIds();
        
        // Instantiate the new ProcessWorkitemRequest object and populate it
        Approval.ProcessWorkitemRequest req2 = 
            new Approval.ProcessWorkitemRequest();
        req2.setComments('Approving request.');
        req2.setAction('Approve');
        req2.setNextApproverIds(new Id[] {approverid});
        
        // Use the ID from the newly created item to specify the item to be worked
        req2.setWorkitemId(newWorkItemIds.get(0));
        
        // Submit the request for approval
        Approval.ProcessResult result2 =  Approval.process(req2);
        
        // Verify the results
        System.assert(result2.isSuccess(), 'Result Status:'+result2.isSuccess());
        
        /*System.assertEquals(
            'Approved', result2.getInstanceStatus(), 
            'Instance Status'+result2.getInstanceStatus());*/
    }
    
    static testMethod void CreateAccountTest(){
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
                        
    List<Account> listAccount = new List<Account>();
    String recordTypeid = checkRecordType('Account','ASI_TH_CRM_Potential_Outlet');
    
    listAccount.add(new Account(Name='Test Potential Outlet', RecordTypeid = recordTypeid));
    listAccount.add(new Account(Name='Test Potential Outlet 2'));

    insert listAccount;
    
    recordTypeid = checkRecordType('ASI_CRM_AccountsAdditionalField__c','ASI_TH_CRM_Potential_Outlet');
    ASI_CRM_AccountsAdditionalField__c accountAdditionalField = new ASI_CRM_AccountsAdditionalField__c(
      ASI_CRM_Account__c = listAccount[0].id, RecordTypeid = recordTypeid
    );
    insert accountAdditionalField;
    
    ASI_MFM_Sub_Channel__c subChannel = new ASI_MFM_Sub_Channel__c();
    insert(subChannel);
    
    recordTypeid = checkRecordType('ASI_CRM_Pros_Segmentation__c','ASI_CRM_TH_Pros_Segmentation');
    ASI_CRM_Pros_Segmentation__c prosSeg = new ASI_CRM_Pros_Segmentation__c(
      ASI_CRM_SG_Customer__c = accountAdditionalField.id, RecordTypeid = recordTypeid
    );
    insert prosSeg;
    
    accountAdditionalField.ASI_CRM_CN_Sub_Channel__c = subChannel.id;
    update accountAdditionalField;
        
    }
    
    static testMethod void CreateAccountTest1(){
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

    List<Account> listAccount = new List<Account>();
    String recordTypeid = checkRecordType('Account','ASI_TH_CRM_Potential_Outlet');
    
    listAccount.add(new Account(Name='Test Potential Outlet', RecordTypeid = recordTypeid));
    insert listAccount;
    
    ApexPages.Standardcontroller stdController = new ApexPages.Standardcontroller(listAccount[0]);
    ASI_TH_CRM_AccountEdit_Controller controller = new ASI_TH_CRM_AccountEdit_Controller(stdController); 
    controller.save();
        
    }
    
    static testMethod void CreateAccountTest2(){
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
                        
    List<Account> listAccount = new List<Account>();
    String recordTypeid = checkRecordType('Account','ASI_TH_CRM_Modern_Trade');
    listAccount.add(new Account(Name='Test Modern Trade', RecordTypeid = recordTypeid, status__c = 'Novo cadastro'));

    recordTypeid = checkRecordType('Account','ASI_TH_CRM_Wholesaler');                
    listAccount.add(new Account(Name='Test Whole Saler', RecordTypeid = recordTypeid, status__c = 'Novo cadastro'));

    insert listAccount;
    
    ApexPages.Standardcontroller stdController = new ApexPages.Standardcontroller(listAccount[0]);
    ASI_TH_CRM_AccountEdit_Controller controller = new ASI_TH_CRM_AccountEdit_Controller(stdController);
    stdController = new ApexPages.Standardcontroller(listAccount[1]);
    controller = new ASI_TH_CRM_AccountEdit_Controller(stdController);
    }

    static testMethod void CreateContractTest(){
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
                        
    String recordTypeid = checkRecordType('Account','ASI_TH_CRM_Potential_Outlet');
    id rtIDContract = checkRecordType('ASI_TH_CRM_Contract__c', 'ASI_TH_CRM_Contract');

    Account potentialOutlet = new Account(Name='Test Potential Outlet', RecordTypeid = recordTypeid);
    insert potentialOutlet ;                            
    
    ASI_TH_CRM_Contract__c contract = new ASI_TH_CRM_Contract__c(Name = '-', ASI_TH_CRM_Outlet__c = potentialOutlet.id, ASI_TH_CRM_Start_Date__c = date.today(), 
    ASI_TH_CRM_End_Date__c = date.today().addMonths(12), ASI_TH_CRM_Total_Fund_Advance__c = 10000,
    RecordTypeID = rtIDContract);
    insert contract;                                      
    
    contract.ASI_TH_CRM_Contract_Status__c = 'Final';
    update contract;
    
    contract.ASI_TH_CRM_End_Date__c = contract.ASI_TH_CRM_End_Date__c.addMonths(1);
    update contract;
    
    /*contract.ASI_TH_CRM_Contract_Status__c = 'Freeze';
    update contract;                
    
    ApexPages.Standardcontroller stdController = new ApexPages.Standardcontroller(contract);
    ApexPages.currentPage().getParameters().put('id', contract.id);
    ASI_TH_CRM_ContractSummary_Controller controller3 = new ASI_TH_CRM_ContractSummary_Controller(stdController);  */          
        
    }
    
    static testMethod void UpdateContractinDraftStatusTest(){
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
                        
    String recordTypeid = checkRecordType('Account','ASI_TH_CRM_Potential_Outlet');
    id rtIDContract = checkRecordType('ASI_TH_CRM_Contract__c', 'ASI_TH_CRM_Contract');

    Account potentialOutlet = new Account(Name='Test Potential Outlet', RecordTypeid = recordTypeid);
    insert potentialOutlet ;                            
    
    ASI_TH_CRM_Contract__c contract = new ASI_TH_CRM_Contract__c(Name = '-', ASI_TH_CRM_Outlet__c = potentialOutlet.id, ASI_TH_CRM_Start_Date__c = date.today(), 
      ASI_TH_CRM_End_Date__c = date.today().addMonths(12),
      RecordTypeID = rtIDContract
    );
    insert contract;  
    
    contract.ASI_TH_CRM_Total_Fund_Advance__c = 10000;
    update contract;
    }
    
    static testMethod void ContractEstimatedSpendingMassEditTest(){
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
                        
    String recordTypeid = checkRecordType('Account','ASI_TH_CRM_Potential_Outlet');
    id rtIDContract = checkRecordType('ASI_TH_CRM_Contract__c', 'ASI_TH_CRM_Contract');

    Account potentialOutlet = new Account(Name='Test Potential Outlet', RecordTypeid = recordTypeid);
    insert potentialOutlet ;                            
    
    ASI_TH_CRM_Contract__c contract = new ASI_TH_CRM_Contract__c(Name = '-', ASI_TH_CRM_Outlet__c = potentialOutlet.id, ASI_TH_CRM_Start_Date__c = date.today(), 
      ASI_TH_CRM_End_Date__c = date.today().addMonths(12), ASI_TH_CRM_Total_Fund_Advance__c = 1000,
      RecordTypeID = rtIDContract
    );
    insert contract;                          
    
    ApexPages.Standardcontroller stdController = new ApexPages.Standardcontroller(contract);
    ASI_TH_CRM_Estimated_Spending_MassEdit controller2 = new ASI_TH_CRM_Estimated_Spending_MassEdit(stdController);  
    controller2.getEstimatedSpendingList();
    controller2.save();
    }
    
    static testMethod void ContractSummaryTest(){
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

    String recordTypeid = checkRecordType('Account','ASI_TH_CRM_Potential_Outlet');
    id rtIDContract = checkRecordType('ASI_TH_CRM_Contract__c', 'ASI_TH_CRM_Contract');

    Account potentialOutlet = new Account(Name='Test Potential Outlet', RecordTypeid = recordTypeid);
    insert potentialOutlet ;                            
    
    ASI_TH_CRM_Contract__c contract = new ASI_TH_CRM_Contract__c(Name = '-', ASI_TH_CRM_Outlet__c = potentialOutlet.id, ASI_TH_CRM_Start_Date__c = date.today(), 
      ASI_TH_CRM_End_Date__c = date.today().addMonths(12), ASI_TH_CRM_Total_Fund_Advance__c = 10000,
      RecordTypeID = rtIDContract
    );
    insert contract;                                      
    
    contract.ASI_TH_CRM_Contract_Status__c = 'Final';
    update contract;                        
    
    contract.ASI_TH_CRM_Contract_Status__c = 'Freeze';
    update contract;                
    
    ApexPages.Standardcontroller stdController = new ApexPages.Standardcontroller(contract);
    ApexPages.currentPage().getParameters().put('id', contract.id);
    ASI_TH_CRM_ContractSummary_Controller controller3 = new ASI_TH_CRM_ContractSummary_Controller(stdController);            
    }
    
    static testMethod void PaymentRequestTest(){
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
        
        //Wilken 20161017: Should not query production user as test data
        /*List<user> userList = [SELECT id, ASI_CN_NPL_Receive_Approval_Request__c, DelegatedApproverId, Managerid, userroleid
        from user where profile.Name = 'System Administrator' and isactive = true and Managerid <> null and userroleid <> null Limit 1];*/
    
    Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 

        User uManager = new User(Alias = 'standt', Email='testUserManager@praTHCRMTest.com', 
              EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
              LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='America/Los_Angeles', UserName='testUserManager@praTHCRMTest.com');

    insert uManager;
    
        User u = new User(Alias = 'standt', Email='testUser@praTHCRMTest.com', 
              EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
              LocaleSidKey='en_US', ProfileId = p.Id, Managerid = uManager.id, 
              TimeZoneSidKey='America/Los_Angeles', UserName='testUser@praTHCRMTest.com');
        
    insert u;
    
        System.runAs(u) {
            String recordTypeid = checkRecordType('Account','ASI_TH_CRM_Potential_Outlet');
            id rtIDContract = checkRecordType('ASI_TH_CRM_Contract__c', 'ASI_TH_CRM_Contract');
            id rtIDPR = checkRecordType('ASI_TH_CRM_PaymentRequest__c','ASI_TH_CRM_Payment_Request');
            id rtIDPRitm = checkRecordType('ASI_TH_CRM_PaymentRequestLineItem__c','ASI_TH_CRM_Payment_Request_Detail');
            
            Account potentialOutlet = new Account(Name='Test Potential Outlet', RecordTypeid = recordTypeid);
            insert potentialOutlet ;
        
            ASI_TH_CRM_Contract__c contract = new ASI_TH_CRM_Contract__c(Name = '-', ASI_TH_CRM_Outlet__c = potentialOutlet.id, ASI_TH_CRM_Start_Date__c = date.today(), 
                ASI_TH_CRM_End_Date__c = date.today().addMonths(12),
                RecordTypeId = rtIDContract
            );
            insert contract; 
            
            contract.ASI_TH_CRM_Contract_Status__c = 'Final';
            update contract;
            contract.ASI_TH_CRM_Contract_Status__c = 'Freeze';
            update contract;
        
            ASI_TH_CRM_PaymentRequest__c paymentRequest = new ASI_TH_CRM_PaymentRequest__c(
                ASI_TH_CRM_Contract__c = contract.id, RecordTypeID = rtIDPR
            );
            insert paymentRequest;        
            
            List<ASI_TH_CRM_PaymentRequestLineItem__c> listpaymentRequestLineitem = new List<ASI_TH_CRM_PaymentRequestLineItem__c>();
            listpaymentRequestLineitem.add(new ASI_TH_CRM_PaymentRequestLineItem__c(
                ASI_TH_CRM_Payment_Request__c = paymentRequest.id, ASI_TH_CRM_Quantity__c = 1, ASI_TH_CRM_UnitCost__c = 200, 
                ASI_TH_CRM_Amount__c = 300, ASI_TH_CRM_COA__c = 'Fund - Cash'
            ));
            listpaymentRequestLineitem.add(new ASI_TH_CRM_PaymentRequestLineItem__c(
                ASI_TH_CRM_Payment_Request__c = paymentRequest.id, ASI_TH_CRM_Quantity__c = 1, ASI_TH_CRM_UnitCost__c = 200, 
                ASI_TH_CRM_Invoice_No__c = '123', ASI_TH_CRM_Amount__c = 300, ASI_TH_CRM_COA__c = 'Fund - Cash', RecordTypeID = rtIDPRitm
            ));
            listpaymentRequestLineitem.add(new ASI_TH_CRM_PaymentRequestLineItem__c(
                ASI_TH_CRM_Payment_Request__c = paymentRequest.id, ASI_TH_CRM_Quantity__c = 1, ASI_TH_CRM_UnitCost__c = 200, 
                ASI_TH_CRM_Invoice_No__c = '123', ASI_TH_CRM_Amount__c = 300, ASI_TH_CRM_COA__c = 'Fund - Cash', RecordTypeID = rtIDPRitm
            ));
            insert listpaymentRequestLineitem;
                    
            paymentRequest.ASI_TH_CRM_Status__c = 'Ready for Approval';        
            update paymentRequest;
            submitAndProcessApprovalRequest(paymentRequest.id, u.ManagerId);
            
            ApexPages.Standardcontroller stdController = new ApexPages.Standardcontroller(paymentRequest);
            ApexPages.currentPage().getParameters().put('id', paymentRequest.id);
            ASI_TH_CRM_POSummaryReport_Controller controller4 = new ASI_TH_CRM_POSummaryReport_Controller(stdController);  
            
            //Added by Twinkle #20160602 - for testing ASI_CRM_TH_Edit_Approved_PR_Ctrl     
            paymentRequest.ASI_TH_CRM_Status__c = 'Approved';        
            update paymentRequest;
            
            stdController = new ApexPages.Standardcontroller(paymentRequest);
            ApexPages.currentPage().getParameters().put('id', paymentRequest.id);
            ASI_CRM_TH_Edit_Approved_PR_Ctrl controller5 = new ASI_CRM_TH_Edit_Approved_PR_Ctrl(stdController);   
            
            paymentRequest.ASI_TH_CRM_Status__c = 'Rejected';        
            update paymentRequest; 
            controller5 = new ASI_CRM_TH_Edit_Approved_PR_Ctrl(stdController); 
            controller5.rejectAction();   
            controller5.redirectPage();                           
        }
    }
    
    static testMethod void PlanOfftakeTest(){
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
        
    String recordTypeid = checkRecordType('Account','ASI_TH_CRM_Potential_Outlet');
    id rtIDContract = checkRecordType('ASI_TH_CRM_Contract__c', 'ASI_TH_CRM_Contract');
    id rtIDOT = checkRecordType('ASI_TH_CRM_Plan_Offtake_Sub_brand_Total__c','ASI_TH_CRM_Plan_Offtake_Total');
    
    Account potentialOutlet = new Account(Name='Test Potential Outlet', RecordTypeid = recordTypeid);
    insert potentialOutlet ;
  
    ASI_TH_CRM_Contract__c contract = new ASI_TH_CRM_Contract__c(Name = '-', ASI_TH_CRM_Outlet__c = potentialOutlet.id, ASI_TH_CRM_Start_Date__c = date.today(), 
    ASI_TH_CRM_End_Date__c = date.today().addMonths(12), RecordTypeID = rtIDContract );
    insert contract; 
  
    ASI_MFM_Sub_brand__c  subBrand = new ASI_MFM_Sub_brand__c(Name='testSubBrand');
    insert subBrand;
    
    
    ASI_TH_CRM_Plan_Offtake_Sub_brand_Total__c planOfftake = new ASI_TH_CRM_Plan_Offtake_Sub_brand_Total__c(
      ASI_TH_CRM_Contract__c = contract.id, ASI_TH_CRM_Sub_brand__c = subBrand.id, ASI_TH_CRM_Total_Quantity__c = 100,
      RecordTypeID = rtIDOT
    );
    insert planOfftake;
    
    planOfftake.ASI_TH_CRM_Total_Quantity__c = 200;
    update planOfftake; 
    }
    
    static testMethod void VisitationPlanTest(){
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

    String recordTypeid = checkRecordType('Account','ASI_TH_CRM_Potential_Outlet');
    Account potentialOutlet = new Account(Name='Test Potential Outlet', RecordTypeid = recordTypeid);
    insert potentialOutlet ;
  
    recordTypeid = checkRecordType('ASI_HK_CRM_Visitation_Plan__c','ASI_TH_CRM_Visitation_Plan');
    ASI_HK_CRM_Visitation_Plan__c visitationPlan = new ASI_HK_CRM_Visitation_Plan__c(Name = 'Test Visitation Plan', RecordTypeid = recordTypeid,
      ASI_HK_CRM_Year__c = '2015', ASI_HK_CRM_Month__c = 'May');
      
    insert visitationPlan;
    
    ASI_HK_CRM_Visitation_Plan_Detail__c vpDetail = new ASI_HK_CRM_Visitation_Plan_Detail__c(
      ASI_HK_CRM_Account__c = potentialOutlet.id, ASI_HK_CRM_Visit_Date__c = Date.newInstance(2015,5,21), ASI_HK_CRM_Visitation_Plan__c = visitationPlan.id,
      ASI_TH_CRM_Visit_Date_Time_From__c = datetime.valueOf('2015-05-21 11:00:00'), ASI_TH_CRM_Visit_Date_Time_To__c = datetime.valueOf('2015-05-21 12:00:00')
    );
    insert vpDetail;
    
    List<ASI_HK_CRM_Visitation_Plan_Detail__c> visitationPlanDetailList = [Select id from ASI_HK_CRM_Visitation_Plan_Detail__c limit 1];
    
    ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(visitationPlanDetailList);
    ApexPages.currentPage().getParameters().put('id', visitationPlan.id);    
    ASI_TH_CRM_VisitationPlanEditController controller5 = new ASI_TH_CRM_VisitationPlanEditController(stdSetController);                          
    
    controller5.initPage();                 
    
    controller5.searchAccountName = 'XXXXXX';
    controller5.ViewData();
    controller5.quickSaveChanges();
    controller5.saveChanges();
    
    controller5.getSortDirection();
    controller5.NameSearch();
    controller5.ResetNameSearch();
    controller5.sortExpression = 'ASC';
    controller5.sortExpression = 'ASI_HK_CRM_Grade__c';        
    controller5.setSortDirection('ASC');
        //String s = controller5.getCustomTypeByRTDevName('test');
    
    ApexPages.currentPage().getParameters().put('id', null);    
    controller5 = new ASI_TH_CRM_VisitationPlanEditController(stdSetController); 
    }
    
    //added by Twinkle @02/06/2016 - for ASI_CRM_TH_ComponentControllerBase
    public static testmethod void testBase_Controller() {
        ASI_CRM_TH_ComponentControllerBase compCont = new ASI_CRM_TH_ComponentControllerBase();
        ASI_CRM_TH_PageControllerBase pageCont = new ASI_CRM_TH_PageControllerBase();
        compCont.pageController = pageCont;
        compCont.key = 'test';
        compCont.pageController = pageCont;
        Map<String, ASI_CRM_TH_ComponentControllerBase> testMap = pageCont.getComponentControllerMap();
        
        pageCont.setComponentControllerMap('keyTest', null);
        ASI_CRM_TH_PageControllerBase testTemp2 = pageCont.getThis();
        
        ASI_CRM_TH_PageControllerBase testPageControllerBase2 = compCont.pageController;
    }
    
    //added by Twinkle @30/06/2016 - for ASI_CRM_TH_MT_MarketVisitPDF_Ctrl
    /*public static testmethod void MT_MarketVisitPDF_Ctrl() {
        //Market Visit
        Id RecordTypeId = Global_RecordTypeCache.getRTId('ASI_CRM_Market_Visit__cASI_CRM_TH_MarketVisit');   
        ASI_CRM_Market_Visit__c mv = new ASI_CRM_Market_Visit__c(RecordTypeId=RecordTypeId);
        insert mv;
        
        //Sales Movements
        RecordTypeId = Global_RecordTypeCache.getRTId('ASI_CRM_Sales_Movement__cASI_CRM_TH_SalesMovement');   
        ASI_CRM_Sales_Movement__c sm = new ASI_CRM_Sales_Movement__c(RecordTypeId=RecordTypeId, ASI_CRM_Market_Visit__c=mv.id, ASI_CRM_Promotion_Type__c='1;2;3');
        insert sm;
        
        //Attachments
        List<Attachment> listAttch = new List<Attachment>();
        listAttch.add(new Attachment(ParentId = mv.id, Name = 'General_0001', Body = EncodingUtil.base64Decode('Test Data1')));
        listAttch.add(new Attachment(ParentId = mv.id, Name = 'General_0002', Body = EncodingUtil.base64Decode('Test Data2')));
        listAttch.add(new Attachment(ParentId = mv.id, Name = 'General_0003', Body = EncodingUtil.base64Decode('Test Data3')));
        listAttch.add(new Attachment(ParentId = mv.id, Name = 'General_0004', Body = EncodingUtil.base64Decode('Test Data4')));
        listAttch.add(new Attachment(ParentId = mv.id, Name = 'General_0005', Body = EncodingUtil.base64Decode('Test Data5')));
        insert listAttch;
        
        ApexPages.StandardController stdController = new ApexPages.StandardController(mv);
        ApexPages.currentPage().getParameters().put('id', mv.id);    
        ASI_CRM_TH_MT_MarketVisitPDF_Ctrl compCont = new ASI_CRM_TH_MT_MarketVisitPDF_Ctrl(stdController);
    }*/       
}