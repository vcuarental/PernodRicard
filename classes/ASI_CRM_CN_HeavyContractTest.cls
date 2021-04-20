@isTest

public class ASI_CRM_CN_HeavyContractTest {
    
    static testMethod void ASI_CRM_CN_HeavyRejectedCommentCtrlTest() {
        ASI_eForm_HR_MDM__c tempMDM = new ASI_eForm_HR_MDM__c(Name='1234567', ASI_eForm_MDM_Department__c='tempHR',ASI_eForm_Employee_Company_Code__c = '222', 
                                                              ASI_eForm_Employee_First_Name__c='ab', ASI_eForm_Employee_Last_Name__c='cd', ASI_eForm_Employee_Job_Title__c='none', 
                                                                ASI_eForm_Employee_Eligible_PD__c = true, ASI_eForm_Employee_Branch_Code__c='300-Management', ASI_eForm_Employee_Is_Salesman__c=True, ASI_eForm_Employee_Gender__c='M', 
                                                              ASI_eForm_Employee_Work_Email__c='123.345@email.com');
        
        insert tempMDM;
        
        
        User tempU = [select id,ASI_KOR_Commission_Code__c,ASI_CRM_Region__c from user where id = :userInfo.getUserId()];
        tempU.ASI_KOR_Commission_Code__c = '1234567';
        tempU.ASI_CRM_Region__c='CN-Admin';
        update tempU;
        
        Id rtOutlet = Global_RecordTypeCache.getRtId('ASI_eForm_Home_Appliance__cASI_eForm_KR_Home_Appliance');
        
        ASI_eForm_Home_Appliance__c a2 = new ASI_eForm_Home_Appliance__c(
            RecordTypeId=rtOutlet
            , ownerID=tempU.id
            , ASI_eForm_Status__c= 'draft');
        insert a2;
        
        test.startTest();
        
        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
        req1.setComments('Submitting request for approval.');
        req1.setObjectId(a2.Id);
        req1.setNextApproverIds(new Id[] {tempU.id});
        req1.setSubmitterID(tempU.id);
        req1.setSkipEntryCriteria(true);
        req1.setProcessDefinitionNameOrId('ASI_eForm_KR_HA_2');
        Approval.ProcessResult result =Approval.process(req1);
        
        Approval.ProcessWorkitemRequest req2 = new Approval.ProcessWorkitemRequest();
        req2.setComments('Reject request.');
        req2.setAction('Reject');//     
        req2.setNextApproverIds(new Id[] {UserInfo.getUserId()});
        
        if(result.getNewWorkitemIds().size()>0){
            req2.setWorkitemId(result.getNewWorkitemIds().get(0));
            Approval.process(req2);
        }
        
        
        ASI_CRM_CN_HeavyRejectedCommentCtrl con = new ASI_CRM_CN_HeavyRejectedCommentCtrl();
        con.currentHeaderId=a2.Id;
        con.init();
        test.stopTest();
    }
    
    static testMethod void ASI_CRM_CN_ViewHeavyContractCtrlTest4() {
        
        //Test Class for ASI_CRM_CN_ViewHeavyContractCtrl-----> Test restore
        ASI_CRM_Region__c region = new ASI_CRM_Region__c (Name='Central Region',recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Region__cASI_CRM_CN_Region'));
        insert region;
        
        ASI_CRM_Division__c division = new ASI_CRM_Division__c(Name='TEST', ASI_CRM_Region__c=region.Id);
        insert division;
        
        ASI_CRM_CN_Area__c area = new ASI_CRM_CN_Area__c(Name='TEST', ASI_CRM_English_Name__c='TEST', ASI_CRM_Division__c=division.Id);
        insert area;
        
        ASI_CRM_City__c city = new ASI_CRM_City__c(Name='TEST', ASI_CRM_CN_Area__c=area.Id);
        insert city;
        
        /*ASI_CRM_CN_Channel__c channel = new ASI_CRM_CN_Channel__c(Name='KTV',ASI_CRM_BC_Rate__c=98,ASI_CRM_CN_On_Off__c='ON',ASI_CRM_For_Outlet__c=true,RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CN_Channel__cASI_CRM_CN_New_Channel'),ASI_CRM_For_Contract__c=TRUE);
        insert channel;*/
        
        ASI_CRM_CN_Channel__c channel = new ASI_CRM_CN_Channel__c(ASI_CRM_CN_On_Off__c='ON');
        insert channel;
        
        ASI_MFM_Sub_Channel__c subChannel = new ASI_MFM_Sub_Channel__c(ASI_CRM_CN_Channel__c=channel.Id);
        insert subChannel;
        
        ASI_CRM_CN_Channel__c newChannel = new ASI_CRM_CN_Channel__c(ASI_CRM_For_Outlet__c = true, Name='Restaurant',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CN_Channel__cASI_CRM_CN_New_Channel'),ASI_CRM_CN_On_Off__c='OFF');
        insert newChannel;
        
        
        Id rtWS = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_CN_WS');
        Id rtOutlet = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN');
        
        list<ASI_CRM_AccountsAdditionalField__c> Customers = new list<ASI_CRM_AccountsAdditionalField__c>();
        Customers.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Eng_Name__c = 'b', ASI_CRM_CN_Chi_Name__c = 'b', ASI_CRM_CN_Commercial_Team__c = 'Premium', ASI_CRM_CN_Sub_Channel__c=subChannel.Id, ASI_CRM_CN_CCity__c=city.Id, ASI_CRM_Latest_Call_Plan_Date__c=system.today(), RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN'), ASI_CRM_CN_NewChannel__c = newChannel.Id, ASI_CRM_CN_Type_of_Restaurant__c = 'International',ASI_CRM_CN_Spending_per_head__c=1));
        Customers.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Eng_Name__c = 'c', ASI_CRM_CN_Chi_Name__c = 'c', ASI_CRM_CN_Commercial_Team__c = 'Premium', ASI_CRM_CN_Sub_Channel__c=subChannel.Id, ASI_CRM_CN_CCity__c=city.Id, ASI_CRM_Latest_Call_Plan_Date__c=system.today(), RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN'), ASI_CRM_CN_NewChannel__c = newChannel.Id, ASI_CRM_CN_Type_of_Restaurant__c = 'International',ASI_CRM_CN_Spending_per_head__c=1));
        insert Customers;
        
        /*
        //Covered_Outlet
        list<ASI_CRM_AccountsAdditionalField__c> ChildCustomers = new list<ASI_CRM_AccountsAdditionalField__c>();
        ChildCustomers.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Parent_Outlet__c=Customers[1].Id,ASI_CRM_CN_Eng_Name__c = 'a', ASI_CRM_CN_Chi_Name__c = 'a', ASI_CRM_CN_Commercial_Team__c = 'Premium', ASI_CRM_CN_Sub_Channel__c=subChannel.Id, ASI_CRM_CN_CCity__c=city.Id, ASI_CRM_Latest_Call_Plan_Date__c=system.today(), RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN'), ASI_CRM_CN_NewChannel__c = newChannel.Id, ASI_CRM_CN_Type_of_Restaurant__c = 'International',ASI_CRM_CN_Spending_per_head__c=1));
        insert ChildCustomers;
        
        
        // list<ASI_CRM_AccountsAdditionalField__c> ChildChildCustomers = new list<ASI_CRM_AccountsAdditionalField__c>();
        //ChildChildCustomers.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Parent_Outlet__c=ChildCustomers[0].Id,ASI_CRM_CN_Commercial_Team__c = 'Premium',RecordTypeId=rtOutlet,Name='TEST', ASI_CRM_CN_Image__c='Iconic',ASI_CRM_CN_CCity__c=city.Id,ASI_CRM_CN_NewChannel__c=channel.Id));
        //insert ChildChildCustomers;
        
        //ASI_CRM_CN_Parent_Outlet__c
        */
        User currentUser = [SELECT id, name, Managerid, ASI_CRM_CN_Prefix__c FROM USER WHERE id =:UserInfo.getUserId()];
        
        list<ASI_HK_CRM_Running_Number__c> rns = new list<ASI_HK_CRM_Running_Number__c>();
        rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_TH_CRM_Contract__c', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_TH_CRM_PaymentRequest__c', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        if(!String.isBlank(currentUser.ASI_CRM_CN_Prefix__c))
            rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_'+currentUser.ASI_CRM_CN_Prefix__c, recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        else{
            rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_NULL', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
            rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        }
        insert rns;
        
        //Sub Brand Grade
        //
        
        list<ASI_CRM_Sub_Brand_Grade__c> grades = new list<ASI_CRM_Sub_Brand_Grade__c>();
        grades.add(new ASI_CRM_Sub_Brand_Grade__c (Name='TEST1'));
        grades.add(new ASI_CRM_Sub_Brand_Grade__c (Name='TEST2'));
        grades.add(new ASI_CRM_Sub_Brand_Grade__c (Name='TEST3'));
        insert grades;
        
        
        list<ASI_MFM_Sub_brand__c> subBrands = new list<ASI_MFM_Sub_brand__c>();
        for(ASI_CRM_Sub_Brand_Grade__c grade :grades) {
            subBrands.add(new ASI_MFM_Sub_brand__c (Name='TEST1',ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,RecordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand'),
                                                    ASI_CRM_CN_Sub_brand_Grade__c=grade.Id));
            subBrands.add(new ASI_MFM_Sub_brand__c (Name='TEST2',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand'),
                                                    ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,
                                                    ASI_CRM_CN_Sub_brand_Grade__c=grade.Id));
            subBrands.add(new ASI_MFM_Sub_brand__c ( Name='TEST3',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand'),
                                                    ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,
                                                    ASI_CRM_CN_Sub_brand_Grade__c=grade.Id));
            subBrands.add(new ASI_MFM_Sub_brand__c ( Name='999',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand'),
                                                    ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,ASI_MFM_Sub_brand_Code__c = '999' ,ASI_MFM_Active_for_CRM__c = true ,
                                                    ASI_CRM_CN_Sub_brand_Grade__c=grade.Id));
        }
        insert subBrands;
        
        
        Date PO_Start_Date = date.newinstance(system.today().year(), system.today().month(), 1);
        Date PO_End_Date = PO_Start_Date.addMonths(1)-1;
        
        ASI_TH_CRM_Contract__c Contract2 = new ASI_TH_CRM_Contract__c(recordtypeid = Global_RecordTypeCache.getRTID('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract'),
                                                                      ASI_CRM_CN_Status__c = 'Archived',
                                                                      ASI_CRM_CN_PO_Start_Date__c = PO_Start_Date,
                                                                      ASI_CRM_CN_PO_End_Date__c =PO_End_Date,
                                                                      ASI_CRM_CN_PO_Version__c = '0.0',ASI_TH_CRM_Promotion_Type__c='Heavy Contract On',
                                                                      Name = 'Contract1',
                                                                      ASI_CRM_CN_Outlet_WS__c=Customers[1].Id,ASI_CRM_Volume_Option__c = 'Normal');
        insert Contract2;
        
        ASI_TH_CRM_Contract__c Contract = new ASI_TH_CRM_Contract__c(recordtypeid = Global_RecordTypeCache.getRTID('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract'),
                                                                     ASI_CRM_CN_Status__c = 'Draft',
                                                                     ASI_CRM_CN_PO_Start_Date__c = PO_Start_Date,
                                                                     ASI_CRM_CN_PO_End_Date__c =PO_End_Date,ASI_CRM_CN_V0_0_PO_version__c=Contract2.Id,ASI_CRM_CN_Last_PO_version__c=Contract2.Id,
                                                                     ASI_CRM_CN_PO_Version__c = '0.1',ASI_TH_CRM_Promotion_Type__c='Heavy Contract On',
                                                                     Name = 'Contract2',
                                                                     ASI_CRM_CN_Outlet_WS__c=Customers[1].Id,ASI_CRM_Volume_Option__c = 'Normal');
        insert Contract;
        
        
        List<ASI_CRM_Module__c> ModuleList = new List<ASI_CRM_Module__c>();
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Unit__c='Std. Btl.',ASI_CRM_Volume_Base__c='By Sub-Brand',ASI_CRM_Line_Type__c='BRSF'));
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Unit__c='CR12 Extra Eqv.',ASI_CRM_Volume_Base__c='By Total',ASI_CRM_Line_Type__c='PSF'));
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Unit__c='CR12 Extra Eqv.',ASI_CRM_Volume_Base__c='By Total',ASI_CRM_Line_Type__c='Variable Event Cost'));
        
        insert ModuleList;
        /*
        ASI_CRM_Contract_Cost__c contractCost = new ASI_CRM_Contract_Cost__c(ASI_CRM_CN_Contract__c = Contract.id,
                                                                             ASI_CRM_CN_Estimate_Amount__c = 100000,
                                                                             ASI_CRM_CN_Cost_Type__c = 'Variable',
                                                                             ASI_CRM_CN_Other_Cost_Payment_Request__c = true,
                                                                             recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_Contract_Cost__cASI_CRM_CN_Contract_Cost') );
        insert contractCost;
        */
        list<ASI_CRM_CN_Contract_BRSF_Line_Item__c> ContractLineList = new list<ASI_CRM_CN_Contract_BRSF_Line_Item__c>();
        list<ASI_CRM_CN_Covered_Outlet__c> cos = new list<ASI_CRM_CN_Covered_Outlet__c>();
        for(ASI_MFM_Sub_brand__c subBrand :subBrands) {
            ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract.Id,
                                                                           ASI_CRM_CN_Est_Monthly_Qty__c=1,ASI_CRM_Module__c=ModuleList[0].Id,
                                                                           ASI_CRM_CN_Contract_Monthly_Qty__c=1,
                                                                           ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,
                                                                           ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,ASI_CRM_Type__c='BRSF',
                                                                           ASI_CRM_CN_Sub_Brand__c=subBrand.Id,
                                                                           recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF')));
        }
        ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract.Id,ASI_CRM_Type__c='PSF',ASI_CRM_Volume_Base__c='By Total',
                                                                       ASI_CRM_CN_Est_Monthly_Qty__c=1,ASI_CRM_Module__c=ModuleList[1].Id,
                                                                       ASI_CRM_CN_Contract_Monthly_Qty__c=1,
                                                                       ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,
                                                                       ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,
                                                                       ASI_CRM_CN_Sub_Brand__c=null,
                                                                       recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF') ));
        ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract.Id,ASI_CRM_Type__c='Variable Event Cost',ASI_CRM_Volume_Base__c='By Total',
                                                                       ASI_CRM_CN_Est_Monthly_Qty__c=1,ASI_CRM_Module__c=ModuleList[2].Id,
                                                                       ASI_CRM_CN_Contract_Monthly_Qty__c=1,
                                                                       ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,
                                                                       ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,
                                                                       ASI_CRM_CN_Sub_Brand__c=null,
                                                                       recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF') ));
        insert ContractLineList;
        List<ASI_CRM_Methodology__c> MethodologyList= new List<ASI_CRM_Methodology__c> ();
        MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test1',ASI_CRM_Methodology_Code__c='01',ASI_CRM_Default__c=true,ASI_CRM_Chinese_Name__c='123',ASI_CRM_Type__c='BRSF',recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Methodology__cASI_CRM_CN_Methodology')));
        MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test2',ASI_CRM_Methodology_Code__c='01',ASI_CRM_Default__c=true,ASI_CRM_Chinese_Name__c='Test 123',ASI_CRM_Type__c='PSF',recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Methodology__cASI_CRM_CN_Methodology')));
        MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test3',ASI_CRM_Methodology_Code__c='01',ASI_CRM_Default__c=true,ASI_CRM_Chinese_Name__c='Test 123',ASI_CRM_Type__c='Variable Event Cost',recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Methodology__cASI_CRM_CN_Methodology')));
        
        
       // MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test1',ASI_CRM_Methodology_Code__c='01',ASI_CRM_Chinese_Name__c='123',ASI_CRM_Type__c='BRSF'));
       // MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test2',ASI_CRM_Methodology_Code__c='01',ASI_CRM_Chinese_Name__c='123',ASI_CRM_Type__c='PSF'));
       // MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test3',ASI_CRM_Methodology_Code__c='01',ASI_CRM_Chinese_Name__c='123',ASI_CRM_Type__c='Variable Event Cost'));
        insert MethodologyList;
        
        test.startTest();
        PageReference EnterPage = Page.ASI_CRM_CN_ViewHeavyContractPage;
        Test.setCurrentPage(EnterPage);
        ApexPages.currentPage().getParameters().put('id', Contract.id);
        
        
        ASI_CRM_CN_ViewHeavyContractCtrl con = new ASI_CRM_CN_ViewHeavyContractCtrl(new ApexPages.Standardcontroller(Contract));
        
        con.restorePO();
        con.POModification();
        con.ErrorHandling('Test');
        con.Calculation();
        test.stopTest(); 
    }
    
    static testMethod void HeavyProfitShuttleCtrlTest1() {
        //Test ASI_CRM_CN_HeavyProfitShuttleCtrl
          ASI_CRM_Region__c region = new ASI_CRM_Region__c (Name='Central Region',recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Region__cASI_CRM_CN_Region'));
        insert region;
        
        ASI_CRM_Division__c division = new ASI_CRM_Division__c(Name='TEST', ASI_CRM_Region__c=region.Id);
        insert division;
        
        ASI_CRM_CN_Area__c area = new ASI_CRM_CN_Area__c(Name='TEST', ASI_CRM_English_Name__c='TEST', ASI_CRM_Division__c=division.Id);
        insert area;
        
        ASI_CRM_City__c city = new ASI_CRM_City__c(Name='TEST', ASI_CRM_CN_Area__c=area.Id,ASI_CRM_CN_City_Tier__c='2');
        insert city;
        
        /*ASI_CRM_CN_Channel__c channel = new ASI_CRM_CN_Channel__c(Name='KTV',ASI_CRM_BC_Rate__c=98,ASI_CRM_CN_On_Off__c='ON',ASI_CRM_For_Outlet__c=true,RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CN_Channel__cASI_CRM_CN_New_Channel'),ASI_CRM_For_Contract__c=TRUE);
        insert channel;*/
        ASI_CRM_CN_Channel__c channel = new ASI_CRM_CN_Channel__c(ASI_CRM_CN_On_Off__c='ON');
        insert channel;
        
        ASI_CRM_SegmentationCriteria__c SegmentationCriteria= new ASI_CRM_SegmentationCriteria__c (Name='Test',ASI_CRM_Channel__c=channel.Id, ASI_CRM_Outlet_New_Image__c='Iconic',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_SegmentationCriteria__cASI_CRM_CN_Segmentation_Criteria'));
        INSERT SegmentationCriteria;

        Id rtWS = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_CN_WS');
        Id rtOutlet = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN');
        
        /*list<ASI_CRM_AccountsAdditionalField__c> Customers = new list<ASI_CRM_AccountsAdditionalField__c>();
        Customers.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Commercial_Team__c = 'Premium',ASI_CRM_CN_New_Image__c='Iconic',RecordTypeId=rtWS,Name='TEST', ASI_CRM_CN_Image__c='Iconic',ASI_CRM_CN_CCity__c=city.Id,ASI_CRM_CN_NewChannel__c=channel.Id));
        Customers.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Commercial_Team__c = 'Premium',ASI_CRM_CN_New_Image__c='Iconic',RecordTypeId=rtOutlet,Name='TEST', ASI_CRM_CN_Image__c='Iconic',ASI_CRM_CN_CCity__c=city.Id,ASI_CRM_CN_NewChannel__c=channel.Id));
        insert Customers;
        
        //Covered_Outlet
        list<ASI_CRM_AccountsAdditionalField__c> ChildCustomers = new list<ASI_CRM_AccountsAdditionalField__c>();
        ChildCustomers.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Parent_Outlet__c=Customers[1].Id,ASI_CRM_CN_Commercial_Team__c = 'Premium',RecordTypeId=rtOutlet,Name='TEST', ASI_CRM_CN_Image__c='Iconic',ASI_CRM_CN_CCity__c=city.Id,ASI_CRM_CN_NewChannel__c=channel.Id));
        insert ChildCustomers;*/
        
        ASI_MFM_Sub_Channel__c subChannel = new ASI_MFM_Sub_Channel__c(ASI_CRM_CN_Channel__c=channel.Id);
        insert subChannel;
        
        ASI_CRM_CN_Channel__c newChannel = new ASI_CRM_CN_Channel__c(ASI_CRM_For_Outlet__c = true, Name='Restaurant',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CN_Channel__cASI_CRM_CN_New_Channel'),ASI_CRM_CN_On_Off__c='OFF');
        insert newChannel;
        
        list<ASI_CRM_AccountsAdditionalField__c> Customers = new list<ASI_CRM_AccountsAdditionalField__c>();
        Customers.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Eng_Name__c = 'b', ASI_CRM_CN_Chi_Name__c = 'b', ASI_CRM_CN_Commercial_Team__c = 'Premium', ASI_CRM_CN_Sub_Channel__c=subChannel.Id, ASI_CRM_CN_CCity__c=city.Id, ASI_CRM_Latest_Call_Plan_Date__c=system.today(), RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN'), ASI_CRM_CN_NewChannel__c = newChannel.Id, ASI_CRM_CN_Type_of_Restaurant__c = 'International',ASI_CRM_CN_Spending_per_head__c=1));
        Customers.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Eng_Name__c = 'c', ASI_CRM_CN_Chi_Name__c = 'c', ASI_CRM_CN_Commercial_Team__c = 'Premium', ASI_CRM_CN_Sub_Channel__c=subChannel.Id, ASI_CRM_CN_CCity__c=city.Id, ASI_CRM_Latest_Call_Plan_Date__c=system.today(), RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN'), ASI_CRM_CN_NewChannel__c = newChannel.Id, ASI_CRM_CN_Type_of_Restaurant__c = 'International',ASI_CRM_CN_Spending_per_head__c=1));
        insert Customers;
  
  
        /*list<ASI_CRM_AccountsAdditionalField__c> ChildCustomers = new list<ASI_CRM_AccountsAdditionalField__c>();
        ChildCustomers.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Parent_Outlet__c=Customers[1].Id,ASI_CRM_CN_Eng_Name__c = 'a', ASI_CRM_CN_Chi_Name__c = 'a', ASI_CRM_CN_Commercial_Team__c = 'Premium', ASI_CRM_CN_Sub_Channel__c=subChannel.Id, ASI_CRM_CN_CCity__c=city.Id, ASI_CRM_Latest_Call_Plan_Date__c=system.today(), RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN'), ASI_CRM_CN_NewChannel__c = newChannel.Id, ASI_CRM_CN_Type_of_Restaurant__c = 'International',ASI_CRM_CN_Spending_per_head__c=1));
        insert ChildCustomers;
        */
        
        User currentUser = [SELECT id, name, Managerid, ASI_CRM_CN_Prefix__c,LanguageLocaleKey FROM USER WHERE id =:UserInfo.getUserId()];
        currentUser.LanguageLocaleKey='zh_CN';
        update currentUser;
        
        list<ASI_HK_CRM_Running_Number__c> rns = new list<ASI_HK_CRM_Running_Number__c>();
        rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_TH_CRM_Contract__c', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_TH_CRM_PaymentRequest__c', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        if(!String.isBlank(currentUser.ASI_CRM_CN_Prefix__c))
            rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_'+currentUser.ASI_CRM_CN_Prefix__c, recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        else{
            rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_NULL', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
            rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        }
        insert rns;
        
        
        
        
        
        List<ASI_HK_CRM_Product_Category__c> ProductCategoryList= new List<ASI_HK_CRM_Product_Category__c> ();
        ProductCategoryList.add(new ASI_HK_CRM_Product_Category__c(Name='Category1',ASI_CRM_CN_Chinese_Name__c='Category',ASI_HK_CRM_English_Name__c='Category',ASI_HK_CRM_Sequence__c=1,recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Product_Category__cASI_CRM_CN_Product_Category')));
        ProductCategoryList.add(new ASI_HK_CRM_Product_Category__c(Name='Category2',ASI_CRM_CN_Chinese_Name__c='Category2',ASI_HK_CRM_English_Name__c='Category',ASI_HK_CRM_Sequence__c=2,recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Product_Category__cASI_CRM_CN_Product_Category')));
        ProductCategoryList.add(new ASI_HK_CRM_Product_Category__c(Name='Category3',ASI_CRM_CN_Chinese_Name__c='Category1',ASI_HK_CRM_English_Name__c='Category',ASI_HK_CRM_Sequence__c=3,recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Product_Category__cASI_CRM_CN_Product_Category')));
        
        insert ProductCategoryList;
        
        
        
        
        List<ASI_TH_CRM_Sub_category__c> SubCategoryList= new List<ASI_TH_CRM_Sub_category__c>();
        SubCategoryList.add(new ASI_TH_CRM_Sub_category__c(Name='SubCategory1',ASI_CRM_CN_Product_Category__c=ProductCategoryList[0].Id,recordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_Sub_category__cASI_CRM_CN_Sub_Category')));
        SubCategoryList.add(new ASI_TH_CRM_Sub_category__c(Name='SubCategory2',ASI_CRM_CN_Product_Category__c=ProductCategoryList[1].Id,recordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_Sub_category__cASI_CRM_CN_Sub_Category')));
        SubCategoryList.add(new ASI_TH_CRM_Sub_category__c(Name='SubCategory3',ASI_CRM_CN_Product_Category__c=ProductCategoryList[2].Id,recordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_Sub_category__cASI_CRM_CN_Sub_Category')));
        
        insert SubCategoryList;
        
        
        List<ASI_MFM_Brand__c> BrandList = new List<ASI_MFM_Brand__c> ();
        BrandList.add(new ASI_MFM_Brand__c (Name='Test1',ASI_CRM_CN_Competitor__c=false,ASI_TH_CRM_Sub_category__c=SubCategoryList[0].Id,recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Brand__cASI_FOC_CN_Brand')));
        BrandList.add(new ASI_MFM_Brand__c (Name='Test2',ASI_CRM_CN_Competitor__c=false,ASI_TH_CRM_Sub_category__c=SubCategoryList[1].Id,recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Brand__cASI_FOC_CN_Brand')));
        BrandList.add(new ASI_MFM_Brand__c (Name='Test3',ASI_CRM_CN_Competitor__c=false,ASI_TH_CRM_Sub_category__c=SubCategoryList[2].Id,recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Brand__cASI_FOC_CN_Brand')));
        
        Insert BrandList;
        
        
        
        
        //Sub Brand Grade
        list<ASI_CRM_Sub_Brand_Grade__c> grades = new list<ASI_CRM_Sub_Brand_Grade__c>();
        grades.add(new ASI_CRM_Sub_Brand_Grade__c (Name='Premium',ASI_CRM_Chinese_Name__c='Test1',ASI_CRM_Chinese_Description__c='1. Standard + Premium ??? + ??',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_Sub_Brand_Grade__cASI_CRM_CN_Sub_brand_Grade')));
        grades.add(new ASI_CRM_Sub_Brand_Grade__c (Name='TEST2',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_Sub_Brand_Grade__cASI_CRM_CN_Sub_brand_Grade')));
        grades.add(new ASI_CRM_Sub_Brand_Grade__c (Name='TEST3',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_Sub_Brand_Grade__cASI_CRM_CN_Sub_brand_Grade')));
        insert grades;
        
        
        list<ASI_MFM_Sub_brand__c> subBrands = new list<ASI_MFM_Sub_brand__c>();
        for(ASI_CRM_Sub_Brand_Grade__c grade :grades) {
            subBrands.add(new ASI_MFM_Sub_brand__c (Name='TEST1',ASI_MFM_Active_for_CRM__c=true,ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,RecordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand'),
                                                    ASI_CRM_CN_Sub_brand_Grade__c=grade.Id,ASI_MFM_Brand__c=BrandList[0].Id));
            subBrands.add(new ASI_MFM_Sub_brand__c (Name='TEST2',ASI_MFM_Active_for_CRM__c=true,RecordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand'),
                                                    ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,
                                                    ASI_CRM_CN_Sub_brand_Grade__c=grade.Id,ASI_MFM_Brand__c=BrandList[1].Id));
            subBrands.add(new ASI_MFM_Sub_brand__c ( Name='TEST3',ASI_MFM_Active_for_CRM__c=true,RecordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand'),
                                                    ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,
                                                    ASI_CRM_CN_Sub_brand_Grade__c=grade.Id,ASI_MFM_Brand__c=BrandList[2].Id));
            subBrands.add(new ASI_MFM_Sub_brand__c ( Name='999',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand'),
                                                    ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,ASI_MFM_Sub_brand_Code__c = '999' ,ASI_MFM_Active_for_CRM__c = true ,
                                                    ASI_CRM_CN_Sub_brand_Grade__c=grade.Id,ASI_MFM_Brand__c=BrandList[0].Id));
        }
        
        insert subBrands;
        
        /*
        List<ASI_CRM_Sub_Brand_Assignment__c> SubBrandAssignmentList= new List<ASI_CRM_Sub_Brand_Assignment__c>();
        for(ASI_MFM_Sub_brand__c SubBrandItem:subBrands){
          SubBrandAssignmentList.add(new ASI_CRM_Sub_Brand_Assignment__c(ASI_CRM_Sub_Brand__c=SubBrandItem.Id,ASI_CRM_Segmentation_Criteria__c=SegmentationCriteria.Id));
        }
        
        insert SubBrandAssignmentList;


        List<ASI_MFM_A_C_Code__c> ACCodeList = new  List<ASI_MFM_A_C_Code__c>();
        ACCodeList.add(new ASI_MFM_A_C_Code__c( Name='0000000000000', ASI_MFM_A_C_Code__c='000010000',ASI_MFM_A_C_Description__c='ASI_CRM_CN_Variable_Cost_Contract',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_CN_A_C_Code') ));
        ACCodeList.add(new ASI_MFM_A_C_Code__c( Name='5275.010000 PRC - Bottle Return Service', ASI_MFM_A_C_Code__c='5275.010000',ASI_MFM_A_C_Description__c='Bottle Return Service',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_CN_A_C_Code') ));
        ACCodeList.add(new ASI_MFM_A_C_Code__c( Name='5275.020000 Promotion Service Fee', ASI_MFM_A_C_Code__c='5275.020000',ASI_MFM_A_C_Description__c='Promotion Service Fee',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_CN_A_C_Code') ));
        ACCodeList.add(new ASI_MFM_A_C_Code__c( Name='5275.030000 PRC - Variable Event Cost', ASI_MFM_A_C_Code__c='5275.030000',ASI_MFM_A_C_Description__c='Variable Event Cost',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_CN_A_C_Code') ));
        
        insert ACCodeList;
        
        
        List<ASI_CRM_Contract_Cost_Setting__c> ContractCostSettingList= new List<ASI_CRM_Contract_Cost_Setting__c>();
        
        ContractCostSettingList.add(new ASI_CRM_Contract_Cost_Setting__c(ASI_CRM_CN_Activity_Code__c=ACCodeList[0].Id,ASI_CRM_CN_Promotion_Type__c='Heavy Contract ON',
                                                                         ASI_CRM_CN_Fixed_Cost_Contract__c=true,ASI_CRM_CN_Variable_Cost_Contract__c=true));
        
        ContractCostSettingList.add(new ASI_CRM_Contract_Cost_Setting__c(ASI_CRM_CN_Activity_Code__c=ACCodeList[0].Id,ASI_CRM_CN_Promotion_Type__c='Heavy Contract ON',ASI_CRM_CN_Variable_Cost_Contract__c=true,
                                                                         ASI_CRM_CN_Fixed_Cost_Contract__c=false,ASI_CRM_CN_BRSF_Activity_Code_Default__c=true));
        
        ContractCostSettingList.add(new ASI_CRM_Contract_Cost_Setting__c(ASI_CRM_CN_Activity_Code__c=ACCodeList[0].Id,ASI_CRM_CN_Promotion_Type__c='Heavy Contract ON',ASI_CRM_CN_Variable_Cost_Contract__c=true,
                                                                         ASI_CRM_CN_Fixed_Cost_Contract__c=false,ASI_CRM_PSF_Activity_Code_Default__c=true));
        
        ContractCostSettingList.add(new ASI_CRM_Contract_Cost_Setting__c(ASI_CRM_CN_Activity_Code__c=ACCodeList[0].Id,ASI_CRM_CN_Promotion_Type__c='Heavy Contract ON',ASI_CRM_CN_Variable_Cost_Contract__c=true,
                                                                         ASI_CRM_CN_Fixed_Cost_Contract__c=false,ASI_CRM_VEC_Activity_Code_Defaul__c=true));
        
        insert ContractCostSettingList;
        
        ASI_CRM_SpecialPromotionTypeSetting__c oldspts = new ASI_CRM_SpecialPromotionTypeSetting__c( ASI_CRM_Promotion_Type__c = 'a');
        insert oldspts;
        
        ASI_CRM_SpecialPromotionTypeSetting__c newspts = new ASI_CRM_SpecialPromotionTypeSetting__c(ASI_CRM_Promotion_Type__c = 'Heavy Contract On',recordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_SpecialPromotionTypeSetting__cASI_CRM_CN_SpecialPromotionTypeSetting'));
        insert newspts;
        
        ASI_CRM_Special_Promotion_Type_Mapping__c sptm = new ASI_CRM_Special_Promotion_Type_Mapping__c(ASI_CRM_Mapping_of_New_Promotion_Type__c = newspts.Id,ASI_CRM_Mapping_of_Old_Promotion_Type__c = oldspts.Id,recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Special_Promotion_Type_Mapping__cASI_CRM_CN_Special_Promotion_Type_Mapping'));
        insert sptm;*/
        
        
        
        Date PO_Start_Date = date.newinstance(system.today().year(), system.today().month(), 1);
        Date PO_End_Date = PO_Start_Date.addMonths(1)-1;
        
        
        ASI_TH_CRM_Contract__c GroupContract = new ASI_TH_CRM_Contract__c(recordtypeid = Global_RecordTypeCache.getRTID('ASI_TH_CRM_Contract__cASI_CRM_CN_Group_Contract'),
                                                                          ASI_CRM_CN_PO_Start_Date__c = PO_Start_Date,
                                                                          ASI_CRM_CN_PO_End_Date__c =PO_End_Date,ASI_CRM_Martell_BC_Rate__c=0.95,
                                                                          Name = 'Noah C4',ASI_CRM_CN_Bottle_Collection_Rate__c=0.97,
                                                                          ASI_CRM_CN_Outlet_WS__c=Customers[1].Id);
        insert GroupContract;
        
        ASI_TH_CRM_Contract__c Contract = new ASI_TH_CRM_Contract__c(recordtypeid = Global_RecordTypeCache.getRTID('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract'),
                                                                     ASI_CRM_CN_Status__c = 'Final',ASI_CRM_CN_Group_Contract__c=GroupContract.Id,
                                                                     ASI_CRM_CN_PO_Start_Date__c = PO_Start_Date,ASI_CRM_Martell_BC_Rate__c=0.95,
                                                                     ASI_CRM_CN_PO_End_Date__c =PO_End_Date,ASI_CRM_CN_Bottle_Collection_Rate__c=0.97,
                                                                     ASI_CRM_CN_PO_Version__c = '0.0',ASI_TH_CRM_Promotion_Type__c='Heavy Contract On',
                                                                     Name = 'Contract1',
                                                                     ASI_CRM_CN_Outlet_WS__c=Customers[1].Id,ASI_CRM_Volume_Option__c = 'Normal');
        insert Contract;
        
        
        List<ASI_CRM_Methodology__c> MethodologyList= new List<ASI_CRM_Methodology__c> ();
        MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test1',ASI_CRM_Methodology_Code__c='01',ASI_CRM_Default__c=true,ASI_CRM_Chinese_Name__c='123',ASI_CRM_Type__c='BRSF',recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Methodology__cASI_CRM_CN_Methodology')));
        MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test2',ASI_CRM_Methodology_Code__c='01',ASI_CRM_Default__c=true,ASI_CRM_Chinese_Name__c='Test 123',ASI_CRM_Type__c='PSF',recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Methodology__cASI_CRM_CN_Methodology')));
        MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test3',ASI_CRM_Methodology_Code__c='01',ASI_CRM_Default__c=true,ASI_CRM_Chinese_Name__c='Test 123',ASI_CRM_Type__c='Variable Event Cost',recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Methodology__cASI_CRM_CN_Methodology')));
        
        
        MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test1',ASI_CRM_Methodology_Code__c='01',ASI_CRM_Chinese_Name__c='123',ASI_CRM_Type__c='BRSF'));
        MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test2',ASI_CRM_Methodology_Code__c='01',ASI_CRM_Chinese_Name__c='123',ASI_CRM_Type__c='PSF'));
        MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test3',ASI_CRM_Methodology_Code__c='01',ASI_CRM_Chinese_Name__c='123',ASI_CRM_Type__c='Variable Event Cost'));
        insert MethodologyList;
        /*
        
        //Methodology Assignment
        List<ASI_CRM_Methodology_Assignment__c> MethodologyAssignmentList = new List<ASI_CRM_Methodology_Assignment__c>();
        MethodologyAssignmentList.add(new ASI_CRM_Methodology_Assignment__c(ASI_CRM_Methodology__c=MethodologyList[0].Id,ASI_CRM_Key_Principle__c=true,ASI_CRM_Methodology_Commercial_Team__c='Premium',ASI_CRM_Region__c=region.Id));
        MethodologyAssignmentList.add(new ASI_CRM_Methodology_Assignment__c(ASI_CRM_Methodology__c=MethodologyList[1].Id,ASI_CRM_Key_Principle__c=true,ASI_CRM_Methodology_Commercial_Team__c='Premium',ASI_CRM_Region__c=region.Id));
        MethodologyAssignmentList.add(new ASI_CRM_Methodology_Assignment__c(ASI_CRM_Methodology__c=MethodologyList[2].Id,ASI_CRM_Key_Principle__c=true,ASI_CRM_Methodology_Commercial_Team__c='Premium',ASI_CRM_Region__c=region.Id));
        MethodologyAssignmentList.add(new ASI_CRM_Methodology_Assignment__c(ASI_CRM_Methodology__c=MethodologyList[3].Id,ASI_CRM_Key_Principle__c=true,ASI_CRM_Methodology_Commercial_Team__c='Premium',ASI_CRM_Region__c=region.Id));
        MethodologyAssignmentList.add(new ASI_CRM_Methodology_Assignment__c(ASI_CRM_Methodology__c=MethodologyList[4].Id,ASI_CRM_Key_Principle__c=true,ASI_CRM_Methodology_Commercial_Team__c='Premium',ASI_CRM_Region__c=region.Id));
        MethodologyAssignmentList.add(new ASI_CRM_Methodology_Assignment__c(ASI_CRM_Methodology__c=MethodologyList[5].Id,ASI_CRM_Key_Principle__c=true,ASI_CRM_Methodology_Commercial_Team__c='Premium',ASI_CRM_Region__c=region.Id));
        
        insert MethodologyAssignmentList ;
        
        */
        
        
        List<ASI_CRM_Module__c> ModuleList = new List<ASI_CRM_Module__c>();
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='Std. Btl.',ASI_CRM_Volume_Base__c='By Sub-Brand',ASI_CRM_Line_Type__c='BRSF',ASI_CRM_Methodology__c=MethodologyList[0].Id));
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='Std. Btl.',ASI_CRM_Volume_Base__c='By Sub-Brand',ASI_CRM_Line_Type__c='PSF',ASI_CRM_Methodology__c=MethodologyList[1].Id));
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='CR12 Extra Eqv.',ASI_CRM_Volume_Base__c='By Grade',ASI_CRM_Line_Type__c='PSF',ASI_CRM_Methodology__c=MethodologyList[1].Id));
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='CR12 Extra Eqv.',ASI_CRM_Volume_Base__c='By Category',ASI_CRM_Line_Type__c='PSF',ASI_CRM_Methodology__c=MethodologyList[1].Id));
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='CR12 Extra Eqv.',ASI_CRM_Volume_Base__c='By Total',ASI_CRM_Line_Type__c='PSF',ASI_CRM_Methodology__c=MethodologyList[1].Id));
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='CR12 Extra Eqv.',ASI_CRM_Volume_Base__c='By Sub-Brand',ASI_CRM_Line_Type__c='Variable Event Cost',ASI_CRM_Methodology__c=MethodologyList[2].Id));
        
        insert ModuleList;
        
        /*
        List<ASI_CRM_Contract_Cost__c> ContractCostList = new List<ASI_CRM_Contract_Cost__c>();
        ASI_CRM_Contract_Cost__c contractCost1 = new ASI_CRM_Contract_Cost__c(ASI_CRM_CN_Contract__c = Contract.id,ASI_CRM_CN_Activity_Code__c=ACCodeList[0].Id,
                                                                             ASI_CRM_CN_Estimate_Amount__c = 100000,ASI_CRM_CN_Chinese_Description__c='????',
                                                                             ASI_CRM_CN_Cost_Type__c = 'Fixed',ASI_CRM_CN_Contract_Amount__c=100,
                                                                             ASI_CRM_CN_Other_Cost_Payment_Request__c = true,
                                                                             recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_Contract_Cost__cASI_CRM_CN_Contract_Cost') );
        ContractCostList.add(contractCost1);
        ASI_CRM_Contract_Cost__c contractCost2 = new ASI_CRM_Contract_Cost__c(ASI_CRM_CN_Contract__c = Contract.id,
                                                                             ASI_CRM_CN_Estimate_Amount__c = 100000,ASI_CRM_CN_Chinese_Description__c='Test1',
                                                                             ASI_CRM_CN_Cost_Type__c = 'Fixed',ASI_CRM_CN_Contract_Amount__c=100,
                                                                             ASI_CRM_CN_Other_Cost_Payment_Request__c = true,
                                                                             recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_Contract_Cost__cASI_CRM_CN_Contract_Cost') );
        ContractCostList.add(contractCost2);
        
        insert ContractCostList;
        */
        
        list<ASI_CRM_CN_Contract_BRSF_Line_Item__c> ContractLineList = new list<ASI_CRM_CN_Contract_BRSF_Line_Item__c>();
        list<ASI_CRM_CN_Covered_Outlet__c> cos = new list<ASI_CRM_CN_Covered_Outlet__c>();
        for(ASI_MFM_Sub_brand__c subBrand :subBrands) {
            ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract.Id,
                                                                           ASI_CRM_CN_Est_Monthly_Qty__c=1,ASI_CRM_Module__c=ModuleList[0].Id,
                                                                           ASI_CRM_CN_Contract_Monthly_Qty__c=1,
                                                                           ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,ASI_CRM_CN_Contract_Total_Dummy__c=100,
                                                                           ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,ASI_CRM_Type__c='BRSF',
                                                                           ASI_CRM_CN_Sub_Brand__c=subBrand.Id,
                                                                           recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF')));
        }
        
         for(ASI_MFM_Sub_brand__c subBrand :subBrands) {
            ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract.Id,
                                                                           ASI_CRM_CN_Est_Monthly_Qty__c=1,ASI_CRM_Module__c=ModuleList[1].Id,
                                                                           ASI_CRM_CN_Contract_Monthly_Qty__c=1,ASI_CRM_Volume_Base__c='By Sub-Brand',
                                                                           ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,ASI_CRM_CN_Contract_Total_Dummy__c=100,
                                                                           ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,ASI_CRM_Type__c='PSF',
                                                                           ASI_CRM_CN_Sub_Brand__c=subBrand.Id,
                                                                           recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF')));
        }

        ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract.Id,ASI_CRM_Type__c='PSF',ASI_CRM_Volume_Base__c='By Grade',
                                                                       ASI_CRM_CN_Est_Monthly_Qty__c=4,ASI_CRM_Module__c=ModuleList[2].Id,
                                                                       ASI_CRM_CN_Contract_Monthly_Qty__c=4,ASI_CRM_Sub_Brand_Grade__c=grades[0].Id,
                                                                       ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,ASI_CRM_CN_Contract_Total_Dummy__c=100,
                                                                       ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,
                                                                       ASI_CRM_CN_Sub_Brand__c=null,
                                                                       recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF') ));
        ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract.Id,ASI_CRM_Type__c='PSF',ASI_CRM_Volume_Base__c='By Category',
                                                                       ASI_CRM_CN_Est_Monthly_Qty__c=4,ASI_CRM_Module__c=ModuleList[3].Id,
                                                                       ASI_CRM_CN_Contract_Monthly_Qty__c=4,ASI_CRM_Product_Category__c=ProductCategoryList[0].Id,
                                                                       ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,ASI_CRM_CN_Contract_Total_Dummy__c=100,
                                                                       ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,
                                                                       ASI_CRM_CN_Sub_Brand__c=null,
                                                                       recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF') ));
        ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract.Id,ASI_CRM_Type__c='PSF',ASI_CRM_Volume_Base__c='By Total',
                                                                       ASI_CRM_CN_Est_Monthly_Qty__c=4,ASI_CRM_Module__c=ModuleList[4].Id,
                                                                       ASI_CRM_CN_Contract_Monthly_Qty__c=4,ASI_CRM_CN_Contract_Total_Dummy__c=100,
                                                                       ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,
                                                                       ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,
                                                                       ASI_CRM_CN_Sub_Brand__c=null,
                                                                       recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF') ));
         for(ASI_MFM_Sub_brand__c subBrand :subBrands) {
            ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract.Id,
                                                                           ASI_CRM_CN_Est_Monthly_Qty__c=1,ASI_CRM_Module__c=ModuleList[5].Id,
                                                                           ASI_CRM_CN_Contract_Monthly_Qty__c=1,ASI_CRM_Volume_Base__c='By Sub-Brand',
                                                                           ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,ASI_CRM_CN_Contract_Total_Dummy__c=100,
                                                                           ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,ASI_CRM_Type__c='Variable Event Cost',
                                                                           ASI_CRM_CN_Sub_Brand__c=subBrand.Id,
                                                                           recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF')));
         }
        
        insert ContractLineList;
        
        
        List<ASI_Attachment__c> AttachmentList=new List<ASI_Attachment__c>();
        string str = '[{"Volumes":398.666664,"VariableExpensesMap":{},"VariableExpense":43700.00,"TradeExpenses":53700.00,"TradeExpenseBySubBrand":[{"volumeSTD":960,"volumeCR12":480.0000,"volume9L":74.6667,"VECTradeExpense":1333.0000,"VECGap":0,"VECAmount":1333.0000,"tradeExpensePerBottle":13.1322,"tradeExpenseByPSFModule":[{"tradeExpense":250.0000,"totalCTDPayableAmount":0,"moduleId":"aGuM0000000CfwVKAS","incentivePerCR12":0.0000,"historicalPaidAmount":0.00,"gap":0,"applicationPaymentAmount":0.00,"amount":250.0000,"actualPayment":0.00},{"tradeExpense":90.9000,"totalCTDPayableAmount":0,"moduleId":"aGuM0000000CfwWKAS","incentivePerCR12":0.0000,"historicalPaidAmount":0.00,"gap":0,"applicationPaymentAmount":0.00,"amount":90.9000,"actualPayment":0.00}],"totalTradeExpense":12606.9000,"subBrandName":"百龄坛特醇","subBrandId":"a7FM00000008eKoMAI","subBrandCode":"BAF","ROI":0.0000,"PSFTradeExpense":340.9000,"PSFGap":0,"PSFAmount":340.9000,"propByTotal":0.1333,"propByGrade":0.5000,"propByCategory":0.1818,"propByBRSFAmt":0.153846,"nonContract":false,"latestBudgetCMTotal":0.0000,"GSTotal":0.0000,"GSPercent":0,"gradeName":"Premium","gradeId":"a9tM00000008ON6IAM","fixCostTradeExpense":1333.000,"factor9L":0.70,"cr12Factor":0.50,"CMTotal":0.0000,"categoryId":"a79M00000008OdCIAU","BRSFTradeExpense":9600.0000,"BRSFIncentive":10.00,"BRSFGap":0,"BRSFAmount":9600.0000},{"volumeSTD":960,"volumeCR12":480.0000,"volume9L":74.6667,"VECTradeExpense":1333.0000,"VECGap":0,"VECAmount":1333.0000,"tradeExpensePerBottle":13.2979,"tradeExpenseByPSFModule":[{"tradeExpense":250.0000,"totalCTDPayableAmount":0,"moduleId":"aGuM0000000CfwVKAS","incentivePerCR12":0.0000,"historicalPaidAmount":0.00,"gap":0,"applicationPaymentAmount":0.00,"amount":250.0000,"actualPayment":0.00},{"tradeExpense":250.0000,"totalCTDPayableAmount":0,"moduleId":"aGuM0000000CfwWKAS","incentivePerCR12":0.0000,"historicalPaidAmount":0.00,"gap":0,"applicationPaymentAmount":0.00,"amount":250.0000,"actualPayment":0.00}],"totalTradeExpense":12766.0000,"subBrandName":"绝对伏特加(原味)","subBrandId":"a7FM00000008eKDMAY","subBrandCode":"AB1","ROI":0.0000,"PSFTradeExpense":500.0000,"PSFGap":0,"PSFAmount":500.0000,"propByTotal":0.1333,"propByGrade":0.5000,"propByCategory":0.5000,"propByBRSFAmt":0.153846,"nonContract":false,"latestBudgetCMTotal":0.0000,"GSTotal":0.0000,"GSPercent":0,"gradeName":"Premium","gradeId":"a9tM00000008ON6IAM","fixCostTradeExpense":1333.000,"factor9L":0.70,"cr12Factor":0.50,"CMTotal":0.0000,"categoryId":"a79M00000008OdDIAU","BRSFTradeExpense":9600.0000,"BRSFIncentive":10.00,"BRSFGap":0,"BRSFAmount":9600.0000},{"volumeSTD":960,"volumeCR12":480.0000,"volume9L":74.6667,"VECTradeExpense":1333.0000,"VECGap":0,"VECAmount":1333.0000,"tradeExpensePerBottle":3.5583,"tradeExpenseByPSFModule":[{"tradeExpense":500.0000,"totalCTDPayableAmount":0,"moduleId":"aGuM0000000CfwVKAS","incentivePerCR12":0.0000,"historicalPaidAmount":0.00,"gap":0,"applicationPaymentAmount":0.00,"amount":500.0000,"actualPayment":0.00},{"tradeExpense":250.0000,"totalCTDPayableAmount":0,"moduleId":"aGuM0000000CfwWKAS","incentivePerCR12":0.0000,"historicalPaidAmount":0.00,"gap":0,"applicationPaymentAmount":0.00,"amount":250.0000,"actualPayment":0.00}],"totalTradeExpense":3416.0000,"subBrandName":"维波罗瓦","subBrandId":"a7FM00000008eJZMAY","subBrandCode":"WYV","ROI":0.0000,"PSFTradeExpense":750.0000,"PSFGap":0,"PSFAmount":750.0000,"propByTotal":0.1333,"propByGrade":1.0000,"propByCategory":0.5000,"propByBRSFAmt":0.000000,"nonContract":false,"latestBudgetCMTotal":0.0000,"GSTotal":0.0000,"GSPercent":0,"gradeName":"Standard","gradeId":"a9tM00000008ONBIA2","fixCostTradeExpense":1333.000,"factor9L":0.70,"cr12Factor":0.50,"CMTotal":0.0000,"categoryId":"a79M00000008OdDIAU","BRSFTradeExpense":0.0000,"BRSFIncentive":0.00,"BRSFGap":0,"BRSFAmount":0.0000},{"volumeSTD":960,"volumeCR12":960.0000,"volume9L":74.6667,"VECTradeExpense":2667.0000,"VECGap":0,"VECAmount":2667.0000,"tradeExpensePerBottle":25.9771,"tradeExpenseByPSFModule":[{"tradeExpense":222.2000,"totalCTDPayableAmount":0,"moduleId":"aGuM0000000CfwVKAS","incentivePerCR12":0.0000,"historicalPaidAmount":0.00,"gap":0,"applicationPaymentAmount":0.00,"amount":222.2000,"actualPayment":0.00},{"tradeExpense":181.8000,"totalCTDPayableAmount":0,"moduleId":"aGuM0000000CfwWKAS","incentivePerCR12":0.0000,"historicalPaidAmount":0.00,"gap":0,"applicationPaymentAmount":0.00,"amount":181.8000,"actualPayment":0.00}],"totalTradeExpense":24938.0000,"subBrandName":"格兰威特单一麦芽创始人甄选","subBrandId":"a7FM00000000B8ZMAU","subBrandCode":"TGN","ROI":0.0000,"PSFTradeExpense":404.0000,"PSFGap":0,"PSFAmount":404.0000,"propByTotal":0.2667,"propByGrade":0.4444,"propByCategory":0.3636,"propByBRSFAmt":0.307692,"nonContract":false,"latestBudgetCMTotal":0.0000,"GSTotal":0.0000,"GSPercent":0,"gradeName":"Super Premium","gradeId":"a9tM00000008ON7IAM","fixCostTradeExpense":2667.000,"factor9L":0.70,"cr12Factor":1.00,"CMTotal":0.0000,"categoryId":"a79M00000008OdCIAU","BRSFTradeExpense":19200.0000,"BRSFIncentive":20.00,"BRSFGap":0,"BRSFAmount":19200.0000},{"volumeSTD":1200,"volumeCR12":1200.0000,"volume9L":93.3333,"VECTradeExpense":3333.0000,"VECGap":0,"VECAmount":3333.0000,"tradeExpensePerBottle":25.9759,"tradeExpenseByPSFModule":[{"tradeExpense":277.8000,"totalCTDPayableAmount":0,"moduleId":"aGuM0000000CfwVKAS","incentivePerCR12":0.0000,"historicalPaidAmount":0.00,"gap":0,"applicationPaymentAmount":0.00,"amount":277.8000,"actualPayment":0.00},{"tradeExpense":227.2500,"totalCTDPayableAmount":0,"moduleId":"aGuM0000000CfwWKAS","incentivePerCR12":0.0000,"historicalPaidAmount":0.00,"gap":0,"applicationPaymentAmount":0.00,"amount":227.2500,"actualPayment":0.00}],"totalTradeExpense":31171.0500,"subBrandName":"格兰威特12年","subBrandId":"a7FM00000008eKhMAI","subBrandCode":"GL5","ROI":0.0000,"PSFTradeExpense":505.0500,"PSFGap":0,"PSFAmount":505.0500,"propByTotal":0.3333,"propByGrade":0.5556,"propByCategory":0.4545,"propByBRSFAmt":0.384615,"nonContract":false,"latestBudgetCMTotal":0.0000,"GSTotal":0.0000,"GSPercent":0,"gradeName":"Super Premium","gradeId":"a9tM00000008ON7IAM","fixCostTradeExpense":3333.000,"factor9L":0.70,"cr12Factor":1.00,"CMTotal":0.0000,"categoryId":"a79M00000008OdCIAU","BRSFTradeExpense":24000.0000,"BRSFIncentive":20.00,"BRSFGap":0,"BRSFAmount":24000.0000}],"TotalMBCRate":97.00,"TotalBCRate":95.00,"SubBrandGradeMap":{"2. Super Premium 超高档":174.666672,"1. Standard + Premium 标准档 + 高档":223.999992},"SubBrandGradeGrouping":{"Super Premium":174.666672,"Standard":74.666664,"Premium":149.333328},"ROIProFormaExcl":0,"ROIProForma":0.0,"ROIIntakeExcl":0,"ROIIntake":0.0,"ROIActual":0.0,"PSFVolumeBase":"By Grade(按品牌档次);By Category(按产品类别);","PSFMethodologyName":"aGmM0000000002fKAA;","POStartDate":"2018-07-01","POEndDate":"2020-06-30","OutletSet":[],"NoOfMonths":24,"NetMBCRate":0.0,"NetBCRate":0.0,"MarginPerBottle":-10.65,"MarginAfterAnP":-53700.000000,"LatestBudgetCMTotal":0.0,"InvestmentCR12":14.92,"IntakeSTD":5040,"IntakeCR12":3600.00,"GSId":" ","GrossSalesTotal":0.000000,"GrossSalesRateExcl":0,"GrossSalesRate":0.0,"FixedExpensesMap":{},"FixedExpenseRate":18.62,"FixedExpense":10000.00,"DebugMap":{},"ContractLineMap":{},"ContractId":"a8cM00000004bZaIAI","CMTotal":0.0,"CMId":" ","CategoryMap":{"Whisky":249.333336,"White Spirit":149.333328},"BRSFMethodologyName":"aGmM0000000002BKAQ","BCRate":95.00,"AddOnString":""},{"Volumes":398.666664,"VariableExpensesMap":{},"VariableExpense":43700.00,"TradeExpenses":53700.00,"TradeExpenseBySubBrand":[{"volumeSTD":960,"volumeCR12":480.0000,"volume9L":74.6667,"VECTradeExpense":1333.0000,"VECGap":0,"VECAmount":1333.0000,"tradeExpensePerBottle":13.1322,"tradeExpenseByPSFModule":[{"tradeExpense":250.0000,"totalCTDPayableAmount":0,"moduleId":"aGuM0000000CfwVKAS","incentivePerCR12":0.0000,"historicalPaidAmount":0.00,"gap":0,"applicationPaymentAmount":0.00,"amount":250.0000,"actualPayment":0.00},{"tradeExpense":90.9000,"totalCTDPayableAmount":0,"moduleId":"aGuM0000000CfwWKAS","incentivePerCR12":0.0000,"historicalPaidAmount":0.00,"gap":0,"applicationPaymentAmount":0.00,"amount":90.9000,"actualPayment":0.00}],"totalTradeExpense":12606.9000,"subBrandName":"百龄坛特醇","subBrandId":"a7FM00000008eKoMAI","subBrandCode":"BAF","ROI":0.0000,"PSFTradeExpense":340.9000,"PSFGap":0,"PSFAmount":340.9000,"propByTotal":0.1333,"propByGrade":0.5000,"propByCategory":0.1818,"propByBRSFAmt":0.153846,"nonContract":false,"latestBudgetCMTotal":0.0000,"GSTotal":0.0000,"GSPercent":0,"gradeName":"Premium","gradeId":"a9tM00000008ON6IAM","fixCostTradeExpense":1333.000,"factor9L":0.70,"cr12Factor":0.50,"CMTotal":0.0000,"categoryId":"a79M00000008OdCIAU","BRSFTradeExpense":9600.0000,"BRSFIncentive":10.00,"BRSFGap":0,"BRSFAmount":9600.0000},{"volumeSTD":960,"volumeCR12":480.0000,"volume9L":74.6667,"VECTradeExpense":1333.0000,"VECGap":0,"VECAmount":1333.0000,"tradeExpensePerBottle":13.2979,"tradeExpenseByPSFModule":[{"tradeExpense":250.0000,"totalCTDPayableAmount":0,"moduleId":"aGuM0000000CfwVKAS","incentivePerCR12":0.0000,"historicalPaidAmount":0.00,"gap":0,"applicationPaymentAmount":0.00,"amount":250.0000,"actualPayment":0.00},{"tradeExpense":250.0000,"totalCTDPayableAmount":0,"moduleId":"aGuM0000000CfwWKAS","incentivePerCR12":0.0000,"historicalPaidAmount":0.00,"gap":0,"applicationPaymentAmount":0.00,"amount":250.0000,"actualPayment":0.00}],"totalTradeExpense":12766.0000,"subBrandName":"绝对伏特加(原味)","subBrandId":"a7FM00000008eKDMAY","subBrandCode":"AB1","ROI":0.0000,"PSFTradeExpense":500.0000,"PSFGap":0,"PSFAmount":500.0000,"propByTotal":0.1333,"propByGrade":0.5000,"propByCategory":0.5000,"propByBRSFAmt":0.153846,"nonContract":false,"latestBudgetCMTotal":0.0000,"GSTotal":0.0000,"GSPercent":0,"gradeName":"Premium","gradeId":"a9tM00000008ON6IAM","fixCostTradeExpense":1333.000,"factor9L":0.70,"cr12Factor":0.50,"CMTotal":0.0000,"categoryId":"a79M00000008OdDIAU","BRSFTradeExpense":9600.0000,"BRSFIncentive":10.00,"BRSFGap":0,"BRSFAmount":9600.0000},{"volumeSTD":960,"volumeCR12":480.0000,"volume9L":74.6667,"VECTradeExpense":1333.0000,"VECGap":0,"VECAmount":1333.0000,"tradeExpensePerBottle":3.5583,"tradeExpenseByPSFModule":[{"tradeExpense":500.0000,"totalCTDPayableAmount":0,"moduleId":"aGuM0000000CfwVKAS","incentivePerCR12":0.0000,"historicalPaidAmount":0.00,"gap":0,"applicationPaymentAmount":0.00,"amount":500.0000,"actualPayment":0.00},{"tradeExpense":250.0000,"totalCTDPayableAmount":0,"moduleId":"aGuM0000000CfwWKAS","incentivePerCR12":0.0000,"historicalPaidAmount":0.00,"gap":0,"applicationPaymentAmount":0.00,"amount":250.0000,"actualPayment":0.00}],"totalTradeExpense":3416.0000,"subBrandName":"维波罗瓦","subBrandId":"a7FM00000008eJZMAY","subBrandCode":"WYV","ROI":0.0000,"PSFTradeExpense":750.0000,"PSFGap":0,"PSFAmount":750.0000,"propByTotal":0.1333,"propByGrade":1.0000,"propByCategory":0.5000,"propByBRSFAmt":0.000000,"nonContract":false,"latestBudgetCMTotal":0.0000,"GSTotal":0.0000,"GSPercent":0,"gradeName":"Standard","gradeId":"a9tM00000008ONBIA2","fixCostTradeExpense":1333.000,"factor9L":0.70,"cr12Factor":0.50,"CMTotal":0.0000,"categoryId":"a79M00000008OdDIAU","BRSFTradeExpense":0.0000,"BRSFIncentive":0.00,"BRSFGap":0,"BRSFAmount":0.0000},{"volumeSTD":960,"volumeCR12":960.0000,"volume9L":74.6667,"VECTradeExpense":2667.0000,"VECGap":0,"VECAmount":2667.0000,"tradeExpensePerBottle":25.9771,"tradeExpenseByPSFModule":[{"tradeExpense":222.2000,"totalCTDPayableAmount":0,"moduleId":"aGuM0000000CfwVKAS","incentivePerCR12":0.0000,"historicalPaidAmount":0.00,"gap":0,"applicationPaymentAmount":0.00,"amount":222.2000,"actualPayment":0.00},{"tradeExpense":181.8000,"totalCTDPayableAmount":0,"moduleId":"aGuM0000000CfwWKAS","incentivePerCR12":0.0000,"historicalPaidAmount":0.00,"gap":0,"applicationPaymentAmount":0.00,"amount":181.8000,"actualPayment":0.00}],"totalTradeExpense":24938.0000,"subBrandName":"格兰威特单一麦芽创始人甄选","subBrandId":"a7FM00000000B8ZMAU","subBrandCode":"TGN","ROI":0.0000,"PSFTradeExpense":404.0000,"PSFGap":0,"PSFAmount":404.0000,"propByTotal":0.2667,"propByGrade":0.4444,"propByCategory":0.3636,"propByBRSFAmt":0.307692,"nonContract":false,"latestBudgetCMTotal":0.0000,"GSTotal":0.0000,"GSPercent":0,"gradeName":"Super Premium","gradeId":"a9tM00000008ON7IAM","fixCostTradeExpense":2667.000,"factor9L":0.70,"cr12Factor":1.00,"CMTotal":0.0000,"categoryId":"a79M00000008OdCIAU","BRSFTradeExpense":19200.0000,"BRSFIncentive":20.00,"BRSFGap":0,"BRSFAmount":19200.0000},{"volumeSTD":1200,"volumeCR12":1200.0000,"volume9L":93.3333,"VECTradeExpense":3333.0000,"VECGap":0,"VECAmount":3333.0000,"tradeExpensePerBottle":25.9759,"tradeExpenseByPSFModule":[{"tradeExpense":277.8000,"totalCTDPayableAmount":0,"moduleId":"aGuM0000000CfwVKAS","incentivePerCR12":0.0000,"historicalPaidAmount":0.00,"gap":0,"applicationPaymentAmount":0.00,"amount":277.8000,"actualPayment":0.00},{"tradeExpense":227.2500,"totalCTDPayableAmount":0,"moduleId":"aGuM0000000CfwWKAS","incentivePerCR12":0.0000,"historicalPaidAmount":0.00,"gap":0,"applicationPaymentAmount":0.00,"amount":227.2500,"actualPayment":0.00}],"totalTradeExpense":31171.0500,"subBrandName":"格兰威特12年","subBrandId":"a7FM00000008eKhMAI","subBrandCode":"GL5","ROI":0.0000,"PSFTradeExpense":505.0500,"PSFGap":0,"PSFAmount":505.0500,"propByTotal":0.3333,"propByGrade":0.5556,"propByCategory":0.4545,"propByBRSFAmt":0.384615,"nonContract":false,"latestBudgetCMTotal":0.0000,"GSTotal":0.0000,"GSPercent":0,"gradeName":"Super Premium","gradeId":"a9tM00000008ON7IAM","fixCostTradeExpense":3333.000,"factor9L":0.70,"cr12Factor":1.00,"CMTotal":0.0000,"categoryId":"a79M00000008OdCIAU","BRSFTradeExpense":24000.0000,"BRSFIncentive":20.00,"BRSFGap":0,"BRSFAmount":24000.0000}],"TotalMBCRate":97.00,"TotalBCRate":95.00,"SubBrandGradeMap":{"2. Super Premium 超高档":174.666672,"1. Standard + Premium 标准档 + 高档":223.999992},"SubBrandGradeGrouping":{"Super Premium":174.666672,"Standard":74.666664,"Premium":149.333328},"ROIProFormaExcl":0,"ROIProForma":0.0,"ROIIntakeExcl":0,"ROIIntake":0.0,"ROIActual":0.0,"PSFVolumeBase":"By Grade(按品牌档次);By Category(按产品类别);","PSFMethodologyName":"aGmM0000000002fKAA;","POStartDate":"2018-07-01","POEndDate":"2020-06-30","OutletSet":[],"NoOfMonths":24,"NetMBCRate":0.0,"NetBCRate":0.0,"MarginPerBottle":-10.65,"MarginAfterAnP":-53700.000000,"LatestBudgetCMTotal":0.0,"InvestmentCR12":14.92,"IntakeSTD":5040,"IntakeCR12":3600.00,"GSId":" ","GrossSalesTotal":0.000000,"GrossSalesRateExcl":0,"GrossSalesRate":0.0,"FixedExpensesMap":{"PRC - Fixed event cost - On Premise 夜店活动费用(固定)":{"VFinalVolume":0.0,"VFinalTotalFees":0.0,"VFinalFees":0.0,"VFinalBottles":0.0,"VFinalActualVolume":0.0,"SubBrandName":"","SubBrandGrade":"","SubBrandCategory":"","strSubBrand":"","HistoricalVolume":0.0,"HistoricalTotalFees":0.0,"HistoricalFees":0.0,"HistoricalBottles":0.0,"HistoricalActualVolume":0.0,"EstimateVolume":0.0,"EstimateTotalFees":0.0,"EstimateFees":5000.00,"EstimateBottles":0.0,"ContractVolume":0.0,"ContractTotalFees":0.0,"ContractFees":5000.00,"ContractBottles":0.0},"PRC - Store/Outlet Support 店家支持":{"VFinalVolume":0.0,"VFinalTotalFees":0.0,"VFinalFees":0.0,"VFinalBottles":0.0,"VFinalActualVolume":0.0,"SubBrandName":"","SubBrandGrade":"","SubBrandCategory":"","strSubBrand":"","HistoricalVolume":0.0,"HistoricalTotalFees":0.0,"HistoricalFees":0.0,"HistoricalBottles":0.0,"HistoricalActualVolume":0.0,"EstimateVolume":0.0,"EstimateTotalFees":0.0,"EstimateFees":5000.00,"EstimateBottles":0.0,"ContractVolume":0.0,"ContractTotalFees":0.0,"ContractFees":5000.00,"ContractBottles":0.0}},"FixedExpenseRate":18.62,"FixedExpense":10000.00,"DebugMap":{},"ContractLineMap":{"00004格兰威特12年 The Glenlivet 12YO-GL5":{"VFinalVolume":0.0,"VFinalTotalFees":0.0,"VFinalFees":0.0,"VFinalBottles":0.0,"VFinalActualVolume":0.0,"SubBrandName":"格兰威特12年 The Glenlivet 12YO-GL5","SubBrandGrade":"Super Premium","SubBrandCategory":"Whisky","strSubBrand":"","HistoricalVolume":0.0,"HistoricalTotalFees":0.0,"HistoricalFees":0.0,"HistoricalBottles":0.0,"HistoricalActualVolume":0.0,"EstimateVolume":1200,"EstimateTotalFees":24000.00,"EstimateFees":20.00,"EstimateBottles":50,"ContractVolume":1200,"ContractTotalFees":24000.00,"ContractFees":20.00,"ContractBottles":50},"00004TGL Founders Reserve-TGN":{"VFinalVolume":0.0,"VFinalTotalFees":0.0,"VFinalFees":0.0,"VFinalBottles":0.0,"VFinalActualVolume":0.0,"SubBrandName":"TGL Founders Reserve-TGN","SubBrandGrade":"Super Premium","SubBrandCategory":"Whisky","strSubBrand":"","HistoricalVolume":0.0,"HistoricalTotalFees":0.0,"HistoricalFees":0.0,"HistoricalBottles":0.0,"HistoricalActualVolume":0.0,"EstimateVolume":960,"EstimateTotalFees":19200.00,"EstimateFees":20.00,"EstimateBottles":40,"ContractVolume":960,"ContractTotalFees":19200.00,"ContractFees":20.00,"ContractBottles":40},"00006维波罗瓦 Wyborowa-WYV":{"VFinalVolume":0.0,"VFinalTotalFees":0.0,"VFinalFees":0.0,"VFinalBottles":0.0,"VFinalActualVolume":0.0,"SubBrandName":"维波罗瓦 Wyborowa-WYV","SubBrandGrade":"Standard","SubBrandCategory":"White Spirit","strSubBrand":"","HistoricalVolume":0.0,"HistoricalTotalFees":0.0,"HistoricalFees":0.0,"HistoricalBottles":0.0,"HistoricalActualVolume":0.0,"EstimateVolume":960,"EstimateTotalFees":0.00,"EstimateFees":0.00,"EstimateBottles":40,"ContractVolume":960,"ContractTotalFees":0.00,"ContractFees":0.00,"ContractBottles":40},"00005绝对伏特加(原味) Absolut Blue-AB1":{"VFinalVolume":0.0,"VFinalTotalFees":0.0,"VFinalFees":0.0,"VFinalBottles":0.0,"VFinalActualVolume":0.0,"SubBrandName":"绝对伏特加(原味) Absolut Blue-AB1","SubBrandGrade":"Premium","SubBrandCategory":"White Spirit","strSubBrand":"","HistoricalVolume":0.0,"HistoricalTotalFees":0.0,"HistoricalFees":0.0,"HistoricalBottles":0.0,"HistoricalActualVolume":0.0,"EstimateVolume":960,"EstimateTotalFees":9600.00,"EstimateFees":10.00,"EstimateBottles":40,"ContractVolume":960,"ContractTotalFees":9600.00,"ContractFees":10.00,"ContractBottles":40},"00005百龄坛特醇 Ballantines Finest-BAF":{"VFinalVolume":0.0,"VFinalTotalFees":0.0,"VFinalFees":0.0,"VFinalBottles":0.0,"VFinalActualVolume":0.0,"SubBrandName":"百龄坛特醇 Ballantines Finest-BAF","SubBrandGrade":"Premium","SubBrandCategory":"Whisky","strSubBrand":"","HistoricalVolume":0.0,"HistoricalTotalFees":0.0,"HistoricalFees":0.0,"HistoricalBottles":0.0,"HistoricalActualVolume":0.0,"EstimateVolume":960,"EstimateTotalFees":9600.00,"EstimateFees":10.00,"EstimateBottles":40,"ContractVolume":960,"ContractTotalFees":9600.00,"ContractFees":10.00,"ContractBottles":40}},"ContractId":"","CMTotal":0.0,"CMId":" ","CategoryMap":{"Whisky":249.333336,"White Spirit":149.333328},"BRSFMethodologyName":"aGmM0000000002BKAQ","BCRate":95.00,"AddOnString":""}]';

        ASI_Attachment__c Attachment1=new ASI_Attachment__c (ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Type__c='Historical Data',ASI_CRM_For_Contract_Use__c=true);
        Attachment1.ASI_CRM_Historical_Financial_Data__c=str;
       
         AttachmentList.add(Attachment1);
        
        ASI_Attachment__c Attachment2=new ASI_Attachment__c (ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Type__c='Contract Data',ASI_CRM_For_Contract_Use__c=true);    
        
        Attachment2.ASI_CRM_Historical_Financial_Data__c= str;
            
                    AttachmentList.add(Attachment2); 
        insert AttachmentList;
        
        
        test.startTest();
        
        ApexPages.currentPage().getParameters().put('id',Contract.Id);
        ApexPages.Standardcontroller stdController = new ApexPages.Standardcontroller(Contract);  
        ASI_CRM_CN_HeavyProfitShuttleCtrl con = new ASI_CRM_CN_HeavyProfitShuttleCtrl(stdController);
        //con.init();
        con.initPage();
        con.strPDF='1';
        con.checkLastRBAID();
        con.checkUserID();
        con.checkApprover();
        con.SplitLineIntoRow('Test', 2);
        List<ASI_CRM_Approval_Comment__c> ApprovalCommentList= new List<ASI_CRM_Approval_Comment__c>();
        ApprovalCommentList.add(new ASI_CRM_Approval_Comment__c(ASI_CRM_Contract__c=Contract.Id,recordtypeid = Global_RecordTypeCache.getRTId('ASI_CRM_Approval_Comment__cASI_CRM_CN_New_Contract_Comment'),ASI_CRM_Background_Objective__c='Test1',ASI_CRM_New_contract_Analsysis__c='Test2',ASI_CRM_Historical_Contract_Performance__c='Test3'));
        ApprovalCommentList.add(new ASI_CRM_Approval_Comment__c(ASI_CRM_Contract__c=Contract.Id,recordtypeid = Global_RecordTypeCache.getRTId('ASI_CRM_Approval_Comment__cASI_CRM_CN_PO_Contract_Comment'),ASI_CRM_Background_Objective__c='Test1',ASI_CRM_New_contract_Analsysis__c='Test2',ASI_CRM_Historical_Contract_Performance__c='Test3'));
        
        
        insert ApprovalCommentList;
        
        ApexPages.currentPage().getParameters().put('id',Contract.Id);
        ApexPages.Standardcontroller stdController2 = new ApexPages.Standardcontroller(Contract);  
        ASI_CRM_CN_HeavyProfitShuttleCtrl con2 = new ASI_CRM_CN_HeavyProfitShuttleCtrl(stdController2);
        con2.strPDF='3';
        //con2.init();
        con.initPage();


        test.stopTest(); 
        
    }

    static testMethod void HeavyContractGenerationTest1() {
        //Test ASI_CRM_CN_HeavyContractGenerationCtrl
        
        ASI_CRM_Region__c region = new ASI_CRM_Region__c (Name='Central Region',recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Region__cASI_CRM_CN_Region'));
        insert region;
        
        ASI_CRM_Division__c division = new ASI_CRM_Division__c(Name='TEST', ASI_CRM_Region__c=region.Id);
        insert division;
        
        ASI_CRM_CN_Area__c area = new ASI_CRM_CN_Area__c(Name='TEST', ASI_CRM_English_Name__c='TEST', ASI_CRM_Division__c=division.Id);
        insert area;
        
        ASI_CRM_City__c city = new ASI_CRM_City__c(Name='TEST', ASI_CRM_CN_Area__c=area.Id,ASI_CRM_CN_City_Tier__c='2');
        insert city;
        
        /*ASI_CRM_CN_Channel__c channel = new ASI_CRM_CN_Channel__c(Name='KTV',ASI_CRM_BC_Rate__c=98,ASI_CRM_CN_On_Off__c='ON',ASI_CRM_For_Outlet__c=true,RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CN_Channel__cASI_CRM_CN_New_Channel'),ASI_CRM_For_Contract__c=TRUE);
        insert channel;*/
        
        ASI_CRM_CN_Channel__c channel = new ASI_CRM_CN_Channel__c(ASI_CRM_CN_On_Off__c='ON');
        insert channel;
        /*
        ASI_CRM_SegmentationCriteria__c SegmentationCriteria= new ASI_CRM_SegmentationCriteria__c (Name='Test',ASI_CRM_Channel__c=channel.Id, ASI_CRM_Outlet_New_Image__c='Iconic',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_SegmentationCriteria__cASI_CRM_CN_Segmentation_Criteria'));
        INSERT SegmentationCriteria;
        
        Id rtWS = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_CN_WS');
        Id rtOutlet = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN');
        */
        /*list<ASI_CRM_AccountsAdditionalField__c> Customers = new list<ASI_CRM_AccountsAdditionalField__c>();
        Customers.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Commercial_Team__c = 'Premium',ASI_CRM_CN_New_Image__c='Iconic',RecordTypeId=rtWS,Name='TEST', ASI_CRM_CN_Image__c='Iconic',ASI_CRM_CN_CCity__c=city.Id,ASI_CRM_CN_NewChannel__c=channel.Id));
        Customers.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Commercial_Team__c = 'Premium',ASI_CRM_CN_New_Image__c='Iconic',RecordTypeId=rtOutlet,Name='TEST', ASI_CRM_CN_Image__c='Iconic',ASI_CRM_CN_CCity__c=city.Id,ASI_CRM_CN_NewChannel__c=channel.Id));
        insert Customers;

        //Covered_Outlet
        list<ASI_CRM_AccountsAdditionalField__c> ChildCustomers = new list<ASI_CRM_AccountsAdditionalField__c>();
        ChildCustomers.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Parent_Outlet__c=Customers[1].Id,ASI_CRM_CN_Commercial_Team__c = 'Premium',RecordTypeId=rtOutlet,Name='TEST', ASI_CRM_CN_Image__c='Iconic',ASI_CRM_CN_CCity__c=city.Id,ASI_CRM_CN_NewChannel__c=channel.Id));
        insert ChildCustomers;*/
        
        ASI_MFM_Sub_Channel__c subChannel = new ASI_MFM_Sub_Channel__c(ASI_CRM_CN_Channel__c=channel.Id);
        insert subChannel;
        
        ASI_CRM_CN_Channel__c newChannel = new ASI_CRM_CN_Channel__c(ASI_CRM_For_Outlet__c = true, Name='Restaurant',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CN_Channel__cASI_CRM_CN_New_Channel'),ASI_CRM_CN_On_Off__c='OFF');
        insert newChannel;
        
        list<ASI_CRM_AccountsAdditionalField__c> Customers = new list<ASI_CRM_AccountsAdditionalField__c>();
        Customers.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Eng_Name__c = 'b', ASI_CRM_CN_Chi_Name__c = 'b', ASI_CRM_CN_Commercial_Team__c = 'Premium', ASI_CRM_CN_Sub_Channel__c=subChannel.Id, ASI_CRM_CN_CCity__c=city.Id, ASI_CRM_Latest_Call_Plan_Date__c=system.today(), RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN'), ASI_CRM_CN_NewChannel__c = newChannel.Id, ASI_CRM_CN_Type_of_Restaurant__c = 'International',ASI_CRM_CN_Spending_per_head__c=1));
        Customers.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Eng_Name__c = 'c', ASI_CRM_CN_Chi_Name__c = 'c', ASI_CRM_CN_Commercial_Team__c = 'Premium', ASI_CRM_CN_Sub_Channel__c=subChannel.Id, ASI_CRM_CN_CCity__c=city.Id, ASI_CRM_Latest_Call_Plan_Date__c=system.today(), RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN'), ASI_CRM_CN_NewChannel__c = newChannel.Id, ASI_CRM_CN_Type_of_Restaurant__c = 'International',ASI_CRM_CN_Spending_per_head__c=1));
        insert Customers;
        
        /*
        list<ASI_CRM_AccountsAdditionalField__c> ChildCustomers = new list<ASI_CRM_AccountsAdditionalField__c>();
        ChildCustomers.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Parent_Outlet__c=Customers[1].Id,ASI_CRM_CN_Eng_Name__c = 'a', ASI_CRM_CN_Chi_Name__c = 'a', ASI_CRM_CN_Commercial_Team__c = 'Premium', ASI_CRM_CN_Sub_Channel__c=subChannel.Id, ASI_CRM_CN_CCity__c=city.Id, ASI_CRM_Latest_Call_Plan_Date__c=system.today(), RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN'), ASI_CRM_CN_NewChannel__c = newChannel.Id, ASI_CRM_CN_Type_of_Restaurant__c = 'International',ASI_CRM_CN_Spending_per_head__c=1));
        insert ChildCustomers;
        */
        User currentUser = [SELECT id, name, Managerid, ASI_CRM_CN_Prefix__c,LanguageLocaleKey FROM USER WHERE id =:UserInfo.getUserId()];
        currentUser.LanguageLocaleKey='zh_CN';
        update currentUser;
        
        list<ASI_HK_CRM_Running_Number__c> rns = new list<ASI_HK_CRM_Running_Number__c>();
        rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_TH_CRM_Contract__c', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_TH_CRM_PaymentRequest__c', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        if(!String.isBlank(currentUser.ASI_CRM_CN_Prefix__c))
            rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_'+currentUser.ASI_CRM_CN_Prefix__c, recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        else{
            rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_NULL', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
            rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        }
        insert rns;
        
        
        
        
        List<ASI_HK_CRM_Product_Category__c> ProductCategoryList= new List<ASI_HK_CRM_Product_Category__c> ();
        ProductCategoryList.add(new ASI_HK_CRM_Product_Category__c(Name='Category1',ASI_CRM_CN_Chinese_Name__c='Category',ASI_HK_CRM_English_Name__c='Category',ASI_HK_CRM_Sequence__c=1,recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Product_Category__cASI_CRM_CN_Product_Category')));
        ProductCategoryList.add(new ASI_HK_CRM_Product_Category__c(Name='Category2',ASI_CRM_CN_Chinese_Name__c='Category2',ASI_HK_CRM_English_Name__c='Category',ASI_HK_CRM_Sequence__c=2,recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Product_Category__cASI_CRM_CN_Product_Category')));
        ProductCategoryList.add(new ASI_HK_CRM_Product_Category__c(Name='Category3',ASI_CRM_CN_Chinese_Name__c='Category1',ASI_HK_CRM_English_Name__c='Category',ASI_HK_CRM_Sequence__c=3,recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Product_Category__cASI_CRM_CN_Product_Category')));
        
        insert ProductCategoryList;
        
          
        List<ASI_TH_CRM_Sub_category__c> SubCategoryList= new List<ASI_TH_CRM_Sub_category__c>();
        SubCategoryList.add(new ASI_TH_CRM_Sub_category__c(Name='SubCategory1',ASI_CRM_CN_Product_Category__c=ProductCategoryList[0].Id,recordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_Sub_category__cASI_CRM_CN_Sub_Category')));
        SubCategoryList.add(new ASI_TH_CRM_Sub_category__c(Name='SubCategory2',ASI_CRM_CN_Product_Category__c=ProductCategoryList[1].Id,recordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_Sub_category__cASI_CRM_CN_Sub_Category')));
        SubCategoryList.add(new ASI_TH_CRM_Sub_category__c(Name='SubCategory3',ASI_CRM_CN_Product_Category__c=ProductCategoryList[2].Id,recordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_Sub_category__cASI_CRM_CN_Sub_Category')));
        
        insert SubCategoryList;
        
        
        List<ASI_MFM_Brand__c> BrandList = new List<ASI_MFM_Brand__c> ();
        BrandList.add(new ASI_MFM_Brand__c (Name='Test1',ASI_CRM_CN_Competitor__c=false,ASI_TH_CRM_Sub_category__c=SubCategoryList[0].Id,recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Brand__cASI_FOC_CN_Brand')));
        BrandList.add(new ASI_MFM_Brand__c (Name='Test2',ASI_CRM_CN_Competitor__c=false,ASI_TH_CRM_Sub_category__c=SubCategoryList[1].Id,recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Brand__cASI_FOC_CN_Brand')));
        BrandList.add(new ASI_MFM_Brand__c (Name='Test3',ASI_CRM_CN_Competitor__c=false,ASI_TH_CRM_Sub_category__c=SubCategoryList[2].Id,recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Brand__cASI_FOC_CN_Brand')));
        
        Insert BrandList;
        
        
        
        //Sub Brand Grade
        list<ASI_CRM_Sub_Brand_Grade__c> grades = new list<ASI_CRM_Sub_Brand_Grade__c>();
        grades.add(new ASI_CRM_Sub_Brand_Grade__c (Name='Premium',ASI_CRM_Chinese_Name__c='Test1',ASI_CRM_Chinese_Description__c='1. Standard + Premium 标准档 + 高档',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_Sub_Brand_Grade__cASI_CRM_CN_Sub_brand_Grade')));
        grades.add(new ASI_CRM_Sub_Brand_Grade__c (Name='TEST2',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_Sub_Brand_Grade__cASI_CRM_CN_Sub_brand_Grade')));
        grades.add(new ASI_CRM_Sub_Brand_Grade__c (Name='TEST3',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_Sub_Brand_Grade__cASI_CRM_CN_Sub_brand_Grade')));
        insert grades;
        
        
        list<ASI_MFM_Sub_brand__c> subBrands = new list<ASI_MFM_Sub_brand__c>();
        for(ASI_CRM_Sub_Brand_Grade__c grade :grades) {
            subBrands.add(new ASI_MFM_Sub_brand__c (Name='TEST1',ASI_MFM_Active_for_CRM__c=true,ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,RecordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand'),
                                                    ASI_CRM_CN_Sub_brand_Grade__c=grade.Id,ASI_MFM_Brand__c=BrandList[0].Id));
            subBrands.add(new ASI_MFM_Sub_brand__c (Name='TEST2',ASI_MFM_Active_for_CRM__c=true,RecordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand'),
                                                    ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,
                                                    ASI_CRM_CN_Sub_brand_Grade__c=grade.Id,ASI_MFM_Brand__c=BrandList[1].Id));
            subBrands.add(new ASI_MFM_Sub_brand__c ( Name='TEST3',ASI_MFM_Active_for_CRM__c=true,RecordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand'),
                                                    ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,
                                                    ASI_CRM_CN_Sub_brand_Grade__c=grade.Id,ASI_MFM_Brand__c=BrandList[2].Id));
            subBrands.add(new ASI_MFM_Sub_brand__c ( Name='999',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand'),
                                                    ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,ASI_MFM_Sub_brand_Code__c = '999' ,ASI_MFM_Active_for_CRM__c = true ,
                                                    ASI_CRM_CN_Sub_brand_Grade__c=grade.Id,ASI_MFM_Brand__c=BrandList[0].Id));
        }
        
        insert subBrands;
        
        /*
        List<ASI_CRM_Sub_Brand_Assignment__c> SubBrandAssignmentList= new List<ASI_CRM_Sub_Brand_Assignment__c>();
        for(ASI_MFM_Sub_brand__c SubBrandItem:subBrands){
            SubBrandAssignmentList.add(new ASI_CRM_Sub_Brand_Assignment__c(ASI_CRM_Sub_Brand__c=SubBrandItem.Id,ASI_CRM_Segmentation_Criteria__c=SegmentationCriteria.Id));
        }
        
        insert SubBrandAssignmentList;
        */
        
        List<ASI_MFM_A_C_Code__c> ACCodeList = new  List<ASI_MFM_A_C_Code__c>();
        ACCodeList.add(new ASI_MFM_A_C_Code__c( Name='0000000000000', ASI_MFM_A_C_Code__c='000010000',ASI_MFM_A_C_Description__c='ASI_CRM_CN_Variable_Cost_Contract',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_CN_A_C_Code') ));
        ACCodeList.add(new ASI_MFM_A_C_Code__c( Name='5275.010000 PRC - Bottle Return Service', ASI_MFM_A_C_Code__c='5275.010000',ASI_MFM_A_C_Description__c='Bottle Return Service',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_CN_A_C_Code') ));
        ACCodeList.add(new ASI_MFM_A_C_Code__c( Name='5275.020000 Promotion Service Fee', ASI_MFM_A_C_Code__c='5275.020000',ASI_MFM_A_C_Description__c='Promotion Service Fee',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_CN_A_C_Code') ));
        ACCodeList.add(new ASI_MFM_A_C_Code__c( Name='5275.030000 PRC - Variable Event Cost', ASI_MFM_A_C_Code__c='5275.030000',ASI_MFM_A_C_Description__c='Variable Event Cost',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_CN_A_C_Code') ));
        
        insert ACCodeList;
        
        /*
        List<ASI_CRM_Contract_Cost_Setting__c> ContractCostSettingList= new List<ASI_CRM_Contract_Cost_Setting__c>();
        
        ContractCostSettingList.add(new ASI_CRM_Contract_Cost_Setting__c(ASI_CRM_CN_Activity_Code__c=ACCodeList[0].Id,ASI_CRM_CN_Promotion_Type__c='Heavy Contract ON',
                                                                         ASI_CRM_CN_Fixed_Cost_Contract__c=true,ASI_CRM_CN_Variable_Cost_Contract__c=true));
        
        ContractCostSettingList.add(new ASI_CRM_Contract_Cost_Setting__c(ASI_CRM_CN_Activity_Code__c=ACCodeList[0].Id,ASI_CRM_CN_Promotion_Type__c='Heavy Contract ON',ASI_CRM_CN_Variable_Cost_Contract__c=true,
                                                                         ASI_CRM_CN_Fixed_Cost_Contract__c=false,ASI_CRM_CN_BRSF_Activity_Code_Default__c=true));
        
        ContractCostSettingList.add(new ASI_CRM_Contract_Cost_Setting__c(ASI_CRM_CN_Activity_Code__c=ACCodeList[0].Id,ASI_CRM_CN_Promotion_Type__c='Heavy Contract ON',ASI_CRM_CN_Variable_Cost_Contract__c=true,
                                                                         ASI_CRM_CN_Fixed_Cost_Contract__c=false,ASI_CRM_PSF_Activity_Code_Default__c=true));
        
        ContractCostSettingList.add(new ASI_CRM_Contract_Cost_Setting__c(ASI_CRM_CN_Activity_Code__c=ACCodeList[0].Id,ASI_CRM_CN_Promotion_Type__c='Heavy Contract ON',ASI_CRM_CN_Variable_Cost_Contract__c=true,
                                                                         ASI_CRM_CN_Fixed_Cost_Contract__c=false,ASI_CRM_VEC_Activity_Code_Defaul__c=true));
        
        insert ContractCostSettingList;
        
        ASI_CRM_SpecialPromotionTypeSetting__c oldspts = new ASI_CRM_SpecialPromotionTypeSetting__c( ASI_CRM_Promotion_Type__c = 'a');
        insert oldspts;
        
        ASI_CRM_SpecialPromotionTypeSetting__c newspts = new ASI_CRM_SpecialPromotionTypeSetting__c(ASI_CRM_Promotion_Type__c = 'Heavy Contract On',recordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_SpecialPromotionTypeSetting__cASI_CRM_CN_SpecialPromotionTypeSetting'));
        insert newspts;
        
        ASI_CRM_Special_Promotion_Type_Mapping__c sptm = new ASI_CRM_Special_Promotion_Type_Mapping__c(ASI_CRM_Mapping_of_New_Promotion_Type__c = newspts.Id,ASI_CRM_Mapping_of_Old_Promotion_Type__c = oldspts.Id,recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Special_Promotion_Type_Mapping__cASI_CRM_CN_Special_Promotion_Type_Mapping'));
        insert sptm;
        
        */
        
        Date PO_Start_Date = date.newinstance(system.today().year(), system.today().month(), 1);
        Date PO_End_Date = PO_Start_Date.addMonths(1)-1;
        
        
        ASI_TH_CRM_Contract__c GroupContract = new ASI_TH_CRM_Contract__c(recordtypeid = Global_RecordTypeCache.getRTID('ASI_TH_CRM_Contract__cASI_CRM_CN_Group_Contract'),
                                                                          ASI_CRM_CN_PO_Start_Date__c = PO_Start_Date,
                                                                          ASI_CRM_CN_PO_End_Date__c =PO_End_Date,
                                                                          Name = 'Noah C4',ASI_CRM_CN_Bottle_Collection_Rate__c=0.97,
                                                                          ASI_CRM_CN_Outlet_WS__c=Customers[1].Id);
        insert GroupContract;
        
        ASI_TH_CRM_Contract__c Contract = new ASI_TH_CRM_Contract__c(recordtypeid = Global_RecordTypeCache.getRTID('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract'),
                                                                     ASI_CRM_CN_Status__c = 'Final',ASI_CRM_CN_Group_Contract__c=GroupContract.Id,
                                                                     ASI_CRM_CN_PO_Start_Date__c = PO_Start_Date,ASI_CRM_Martell_BC_Rate__c=0.97,
                                                                     ASI_CRM_CN_PO_End_Date__c =PO_End_Date,ASI_CRM_CN_Bottle_Collection_Rate__c=0.97,
                                                                     ASI_CRM_CN_PO_Version__c = '0.0',ASI_TH_CRM_Promotion_Type__c='Heavy Contract On',
                                                                     Name = 'Contract1',
                                                                     ASI_CRM_CN_Outlet_WS__c=Customers[1].Id,ASI_CRM_Volume_Option__c = 'Normal');
        insert Contract;
        
        
        List<ASI_CRM_Methodology__c> MethodologyList= new List<ASI_CRM_Methodology__c> ();
        MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test1',ASI_CRM_Methodology_Code__c='01',ASI_CRM_Default__c=true,ASI_CRM_Chinese_Name__c='123',ASI_CRM_Type__c='BRSF'));
        MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test2',ASI_CRM_Methodology_Code__c='01',ASI_CRM_Default__c=true,ASI_CRM_Chinese_Name__c='Test 123',ASI_CRM_Type__c='PSF'));
        MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test3',ASI_CRM_Methodology_Code__c='01',ASI_CRM_Default__c=true,ASI_CRM_Chinese_Name__c='Test 123',ASI_CRM_Type__c='Variable Event Cost'));
        
        
        MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test1',ASI_CRM_Methodology_Code__c='01',ASI_CRM_Chinese_Name__c='123',ASI_CRM_Type__c='BRSF'));
        MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test2',ASI_CRM_Methodology_Code__c='01',ASI_CRM_Chinese_Name__c='123',ASI_CRM_Type__c='PSF'));
        MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test3',ASI_CRM_Methodology_Code__c='01',ASI_CRM_Chinese_Name__c='123',ASI_CRM_Type__c='Variable Event Cost'));
        insert MethodologyList;
        
        /*
        //Methodology Assignment
        List<ASI_CRM_Methodology_Assignment__c> MethodologyAssignmentList = new List<ASI_CRM_Methodology_Assignment__c>();
        MethodologyAssignmentList.add(new ASI_CRM_Methodology_Assignment__c(ASI_CRM_Methodology__c=MethodologyList[0].Id,ASI_CRM_Key_Principle__c=true,ASI_CRM_Methodology_Commercial_Team__c='Premium',ASI_CRM_Region__c=region.Id));
        MethodologyAssignmentList.add(new ASI_CRM_Methodology_Assignment__c(ASI_CRM_Methodology__c=MethodologyList[1].Id,ASI_CRM_Key_Principle__c=true,ASI_CRM_Methodology_Commercial_Team__c='Premium',ASI_CRM_Region__c=region.Id));
        MethodologyAssignmentList.add(new ASI_CRM_Methodology_Assignment__c(ASI_CRM_Methodology__c=MethodologyList[2].Id,ASI_CRM_Key_Principle__c=true,ASI_CRM_Methodology_Commercial_Team__c='Premium',ASI_CRM_Region__c=region.Id));
        MethodologyAssignmentList.add(new ASI_CRM_Methodology_Assignment__c(ASI_CRM_Methodology__c=MethodologyList[3].Id,ASI_CRM_Key_Principle__c=true,ASI_CRM_Methodology_Commercial_Team__c='Premium',ASI_CRM_Region__c=region.Id));
        MethodologyAssignmentList.add(new ASI_CRM_Methodology_Assignment__c(ASI_CRM_Methodology__c=MethodologyList[4].Id,ASI_CRM_Key_Principle__c=true,ASI_CRM_Methodology_Commercial_Team__c='Premium',ASI_CRM_Region__c=region.Id));
        MethodologyAssignmentList.add(new ASI_CRM_Methodology_Assignment__c(ASI_CRM_Methodology__c=MethodologyList[5].Id,ASI_CRM_Key_Principle__c=true,ASI_CRM_Methodology_Commercial_Team__c='Premium',ASI_CRM_Region__c=region.Id));
        
        insert MethodologyAssignmentList ;
        
        
        */
        
        List<ASI_CRM_Module__c> ModuleList = new List<ASI_CRM_Module__c>();
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='Std. Btl.',ASI_CRM_Volume_Base__c='By Sub-Brand',ASI_CRM_Line_Type__c='BRSF',ASI_CRM_Methodology__c=MethodologyList[0].Id));
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='Std. Btl.',ASI_CRM_Volume_Base__c='By Sub-Brand',ASI_CRM_Line_Type__c='PSF',ASI_CRM_Methodology__c=MethodologyList[1].Id));
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='CR12 Extra Eqv.',ASI_CRM_Volume_Base__c='By Grade',ASI_CRM_Line_Type__c='PSF',ASI_CRM_Methodology__c=MethodologyList[1].Id));
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='CR12 Extra Eqv.',ASI_CRM_Volume_Base__c='By Category',ASI_CRM_Line_Type__c='PSF',ASI_CRM_Methodology__c=MethodologyList[1].Id));
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='CR12 Extra Eqv.',ASI_CRM_Volume_Base__c='By Total',ASI_CRM_Line_Type__c='PSF',ASI_CRM_Methodology__c=MethodologyList[1].Id));
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='CR12 Extra Eqv.',ASI_CRM_Volume_Base__c='By Sub-Brand',ASI_CRM_Line_Type__c='Variable Event Cost',ASI_CRM_Methodology__c=MethodologyList[2].Id));
        
        insert ModuleList;
        
        
        List<ASI_CRM_Contract_Cost__c> ContractCostList = new List<ASI_CRM_Contract_Cost__c>();
        ASI_CRM_Contract_Cost__c contractCost1 = new ASI_CRM_Contract_Cost__c(ASI_CRM_CN_Contract__c = Contract.id,ASI_CRM_CN_Activity_Code__c=ACCodeList[0].Id,
                                                                              ASI_CRM_CN_Estimate_Amount__c = 100000,ASI_CRM_CN_Chinese_Description__c='店家支持',
                                                                              ASI_CRM_CN_Cost_Type__c = 'Fixed',ASI_CRM_CN_Contract_Amount__c=100,
                                                                              ASI_CRM_CN_Other_Cost_Payment_Request__c = true,
                                                                              recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_Contract_Cost__cASI_CRM_CN_Contract_Cost') );
        ContractCostList.add(contractCost1);
        ASI_CRM_Contract_Cost__c contractCost2 = new ASI_CRM_Contract_Cost__c(ASI_CRM_CN_Contract__c = Contract.id,
                                                                              ASI_CRM_CN_Estimate_Amount__c = 100000,ASI_CRM_CN_Chinese_Description__c='Test1',
                                                                              ASI_CRM_CN_Cost_Type__c = 'Fixed',ASI_CRM_CN_Contract_Amount__c=100,
                                                                              ASI_CRM_CN_Other_Cost_Payment_Request__c = true,
                                                                              recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_Contract_Cost__cASI_CRM_CN_Contract_Cost') );
        ContractCostList.add(contractCost2);
        
        insert ContractCostList;

        String ContractCostLinesJson = '["'+contractCost1.Id+'// Test"]';
        
        
        
        list<ASI_CRM_CN_Contract_BRSF_Line_Item__c> ContractLineList = new list<ASI_CRM_CN_Contract_BRSF_Line_Item__c>();
        list<ASI_CRM_CN_Covered_Outlet__c> cos = new list<ASI_CRM_CN_Covered_Outlet__c>();
        for(ASI_MFM_Sub_brand__c subBrand :subBrands) {
            ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract.Id,
                                                                           ASI_CRM_CN_Est_Monthly_Qty__c=1,ASI_CRM_Module__c=ModuleList[0].Id,
                                                                           ASI_CRM_CN_Contract_Monthly_Qty__c=1,
                                                                           ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,ASI_CRM_CN_Contract_Total_Dummy__c=100,
                                                                           ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,ASI_CRM_Type__c='BRSF',
                                                                           ASI_CRM_CN_Sub_Brand__c=subBrand.Id,
                                                                           recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF')));
        }
        
        for(ASI_MFM_Sub_brand__c subBrand :subBrands) {
            ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract.Id,
                                                                           ASI_CRM_CN_Est_Monthly_Qty__c=1,ASI_CRM_Module__c=ModuleList[1].Id,
                                                                           ASI_CRM_CN_Contract_Monthly_Qty__c=1,ASI_CRM_Volume_Base__c='By Sub-Brand',
                                                                           ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,ASI_CRM_CN_Contract_Total_Dummy__c=100,
                                                                           ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,ASI_CRM_Type__c='PSF',
                                                                           ASI_CRM_CN_Sub_Brand__c=subBrand.Id,
                                                                           recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF')));
        }
        
        ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract.Id,ASI_CRM_Type__c='PSF',ASI_CRM_Volume_Base__c='By Grade',
                                                                       ASI_CRM_CN_Est_Monthly_Qty__c=4,ASI_CRM_Module__c=ModuleList[2].Id,
                                                                       ASI_CRM_CN_Contract_Monthly_Qty__c=4,ASI_CRM_Sub_Brand_Grade__c=grades[0].Id,
                                                                       ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,ASI_CRM_CN_Contract_Total_Dummy__c=100,
                                                                       ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,
                                                                       ASI_CRM_CN_Sub_Brand__c=null,
                                                                       recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF') ));
        ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract.Id,ASI_CRM_Type__c='PSF',ASI_CRM_Volume_Base__c='By Category',
                                                                       ASI_CRM_CN_Est_Monthly_Qty__c=4,ASI_CRM_Module__c=ModuleList[3].Id,
                                                                       ASI_CRM_CN_Contract_Monthly_Qty__c=4,ASI_CRM_Product_Category__c=ProductCategoryList[0].Id,
                                                                       ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,ASI_CRM_CN_Contract_Total_Dummy__c=100,
                                                                       ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,
                                                                       ASI_CRM_CN_Sub_Brand__c=null,
                                                                       recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF') ));
        ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract.Id,ASI_CRM_Type__c='PSF',ASI_CRM_Volume_Base__c='By Total',
                                                                       ASI_CRM_CN_Est_Monthly_Qty__c=4,ASI_CRM_Module__c=ModuleList[4].Id,
                                                                       ASI_CRM_CN_Contract_Monthly_Qty__c=4,ASI_CRM_CN_Contract_Total_Dummy__c=100,
                                                                       ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,
                                                                       ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,
                                                                       ASI_CRM_CN_Sub_Brand__c=null,
                                                                       recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF') ));
        for(ASI_MFM_Sub_brand__c subBrand :subBrands) {
            ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract.Id,
                                                                           ASI_CRM_CN_Est_Monthly_Qty__c=1,ASI_CRM_Module__c=ModuleList[5].Id,
                                                                           ASI_CRM_CN_Contract_Monthly_Qty__c=1,ASI_CRM_Volume_Base__c='By Sub-Brand',
                                                                           ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,ASI_CRM_CN_Contract_Total_Dummy__c=100,
                                                                           ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,ASI_CRM_Type__c='Variable Event Cost',
                                                                           ASI_CRM_CN_Sub_Brand__c=subBrand.Id,
                                                                           recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF')));
        }
        
        insert ContractLineList;

        folder f=[select id from folder where Type='Document' limit 1 ];
        
        
        
        String XMLTestString='<source> <header> <section name="Sales and Branding Promotion Agreement" displayNumber="" style="text-align: center;font-size: 20px;" class="" > <content>销售和品牌推广协议</content> <type>Read</type> </section> <section name="drink on the premises" displayNumber="" style="text-align: center;font-size: 18px;" class="" > <content>堂饮</content> <type>Read</type> </section> <section name="Party A" displayNumber="" style="" class="" > <content>甲方：{1}(店家名称) </content> <type>Read</type> </section> <section name="Party B" displayNumber="" style="" class="" > <content>乙方：保乐力加（中国）贸易有限公司 </content> <type>Read</type> </section> <section name="Party C" displayNumber="" style="" class="" > <content>丙方：{1}(批发商名称) </content> <type>Read</type> </section> </header> <body> <section name="Header with original contract" displayNumber="" style="font-weight: bold;" class="" > <content>鉴于：</content> <type>Read</type> </section> <section name="WhereasA" displayNumber="A" style="" class="" > <title></title> <content>甲方为堂饮服务类企业；乙方为保乐力加产品在中国的独家总经销商；丙方为保乐力加产品在甲方所在城市的批发商及甲方的供货商。</content> <type>Read</type> </section> <section name="WhereasB" displayNumber="B" style="" class="" > <content>乙方为在甲方所在地方推广保乐力加产品品牌、提高产品的知名度并打击假冒伪劣产品，愿意与甲方合作，由甲方配合其市场营销活动提供有关品牌推广服务。丙方作为甲方的直接供货商，愿意为甲方和乙方在品牌发展方面的合作提供物流等方面的协助。</content> <type>Read</type> </section> <section name="WhereasC" displayNumber="C" style="" class="" > <content>同时，为促进保乐力加产品在甲方渠道的销售，协议三方将在甲方渠道开展以打折让利等形式进行促销。</content> <type>Read</type> </section> <section name="Agreement" displayNumber="" style="" class="" > <content>现经友好协商，三方达成协议如下：</content> <type>Read</type> </section> <section name="TermsofthisAgreement" displayNumber="1" style="font-weight: bold;" class="" > <content>协议期限</content> <type>Read</type> </section> <section name="Terms of this Agreement" displayNumber="" style="" class="" > <content>本协议期限自{1}年{2}月{3}日 至{4}年{5}月{6}日。</content> <type>Read</type> </section> <section name="Products" displayNumber="1" style="font-weight: bold;" class="" > <content>产品</content> <type>Read</type> </section> <section name="All parties sell Products" displayNumber="" style="" class="" > <content>三方同意在甲方店内销售保乐力加产品，产品具体名称、规格等见产品清单 （下称“保乐力加产品”或“产品”）。</content> <type>Read</type> </section> <section name="All parties sell Products" displayNumber="3" style="font-weight: bold;" class="" > <content>订货和交付</content> <type>Read</type> </section> <section name="All parties sell Products" displayNumber="a" style="" class="" > <content>甲方应通过订单的形式向丙方订购产品，该订单中应明确订购产品的数量和要求的交货日期。产品的所有订单均须获得丙方的批准。丙方可对所订购产品的数量根据现有库存进行调整，同时不应就未经其接受的购买订单向该客户承担责任。 </content> <type>Read</type> </section> <section name="All parties sell Products" displayNumber="b" style="" class="" > <content>丙方应在订单约定的时间期限内，将货物交付到指定地点和接收人。订单发出后，未经丙方同意，不得对丙方已经收到的任何订单做出修改。</content> <type>Read</type> </section> <section name="All parties sell Products" displayNumber="c" style="" class="" > <content>甲方订购的所有产品均根据标准商业惯例进行包装以便运输和储存。订购产品的灭失和损害风险在指定的交货地点向甲方交付该等订购产品后转移给甲方。如有承运人的，则订购产品的灭失和损害风险自交由第一承运人起转移给甲方。甲方应在收到货物后对货物进行检验。如果货物有破损或包装货物发生短缺，则甲方应立即通知丙方，且在运输公司代表在场的情况下，甲方可拒收破损的货物。破损或短缺的问题应通过召回或调换的方式予以解决。</content> <type>Read</type> </section> <section name="Conditions for Payment" displayNumber="3" style="font-weight: bold;" class="" > <content>货款的付款条件</content> <type>Read</type> </section> <section name="The payment relating " displayNumber="" style="" class="" > <content>本协议项下有关订购产品货款的支付，甲方应以人民币通过银行转账或约定的其他付款方式支付给丙方。</content> <type>Read</type> </section> <section name="Promotion, sales target and sales discount" displayNumber="5" style="font-weight: bold;" class="" > <content>品牌推广服务、销量目标和销售折扣</content> <type>Read</type> </section> <section name="The payment relating " displayNumber="a" style="" class="" > <content>甲方的承诺和责任。 乙方致力于在甲方渠道提高保乐力加产品及品牌的知名度和形象，甲方同意在其店内向其提供如下品牌推广服务，并尽其最大努力完成约定的销量目标：</content> <type>Read</type> <subSection> <section name="" displayNumber="(1)" style="" class="" > <content>在店内外提供如下品牌的形象宣传服务(具体计划和安排，由双方另行协商确定）</content> <type>Read</type> </section> <section name=" " displayNumber="" style="" class="" > <content>• 陈列放有保乐力加产品广告的灯箱；</content> <type>Read</type> </section> <section name=" " displayNumber="" style="" class="" > <content>• 在店内电子LED上（如有）播放保乐力加产品信息或广告；</content> <type>Read</type> </section> <section name=" " displayNumber="" style="" class="" > <content>• 店内装饰装修上采用与保乐力加产品品牌相关的元素和装饰；</content> <type>Read</type> </section> <section name="" displayNumber="" style="" class="" > <content>• 在店内显著位置放置保乐力加产品陈列柜或在店内陈列柜及显著位置陈列保乐力加产品；</content> <type>Read</type> </section> <section name="" displayNumber="" style="" class="" > <content>• 在店内派送保乐力加产品的宣传品与物料；</content> <type>Read</type> </section> <section name="" displayNumber="" style="" class="" > <content>• 保乐力加产品信息出现在酒水单前列；</content> <type>Read</type> </section> <section name="" displayNumber="" style="" class="" > <content>• 在店内桌上放置含有保乐力加产品信息的台卡等。</content> <type>Read</type> </section> <section name="" displayNumber="(2)" style="" class="" > <content>授予保乐力加产品在店内的促销权，并配合乙方的促销活动提供如下服务：</content> <type>Read</type> </section> <section name="" displayNumber="" style="" class="" > <content>• 为乙方的促销服务提供场地；</content> <type>Read</type> </section> <section name="" displayNumber="" style="" class="" > <content>• 同意乙方向店内派驻促销代表以宣传、推广保乐力加产品。该促销代表的数量和来源由甲、乙双方协商确定；乙方促销员应遵守店内的规章制度；</content> <type>Read</type> </section> <section name="" displayNumber="" style="" class="" > <content>• 同意配合乙方的市场营销计划在店内开展保乐力加产品的促销活动（具体促销活动计划和安排，由双方另行协商确定）。</content> <type>Read</type> </section> <section name="" displayNumber="(3)" style="" class="" > <content>同意并配合乙方在各类节庆及其他时间开展各种品牌活动，包括各种派对、演出、晚宴或品酒会及品牌展示和促销活动（由乙方根据其具体的市场营销计划最终确定）等。</content> <type>Read</type> </section> <section name="" displayNumber="(4)" style="" class="" > <content>尽最大努力完成销量目标。</content> <type>Read</type> </section> </subSection> </section> <section name="" displayNumber="b" style="" class="" > <content>乙方的权利和义务。</content> <type>Read</type> <subSection> <section name="" displayNumber="(1)" style="" class="" > <content>因品牌推广计划尚未完全确定，乙方有权在具体履行协议时根据其最终确定的品牌推广计划对甲方提供的上述服务项目进行调整，包括增加、取消或变更部分服务项目等，并和甲方协商确定销量目标。</content> <type>Read</type> </section> <section name="" displayNumber="(2)" style="" class="" > <content>乙方同意：</content> <type>Read</type> </section> <section name="" displayNumber="" style="" class="" > <content>• 甲方可获得一定服务费用（具体金额和付款条件根据最终确定后的形象宣传活动细节、促销活动方案、甲方品牌活动计划另行约定）和在符合约定条件的前提下享受相应的销售折扣，甲乙双方必须将折扣如实入账；</content> <type>Read</type> </section> <section name="" displayNumber="" style="" class="" > <content>• 及时向甲方提供和品牌形象宣传有关的宣传品、酒具、物料等材料。</content> <type>Read</type> </section> <section name="" displayNumber="" style="" class="" > <content>• 根据甲方的需要向其员工提供一定酒类培训，具体培训的次数、地点和内容由双方协商确定。</content> <type>Read</type> </section> </subSection> </section> <section name="" displayNumber="c" style="" class="" > <content>丙方的义务。</content> <type>Read</type> <subSection> <section name="" displayNumber="(1)" style="" class="" > <content>本条所述品牌推广服务费和销售折扣的全部或部分由丙方支付给甲方。</content> <type>Read</type> </section> </subSection> </section> <section name="" displayNumber="d" style="" class="" > <content>服务费用及销售折扣的支付应以甲方在协议期限内遵守本协议之约定为前提。在付款方向甲方支付任何费用之前，甲方应开具符合中国法律、法规规定及中国税务部门要求的、由中国税务部门监制的记载相应款项的发票。各方对上述各项收付款应在其财务帐上真实明确记载。</content> <type>Read</type> </section> <section name="" displayNumber="6" style="font-weight: bold;" class="" > <content> 打假措施 </content> <type>Read</type> </section> <section name="" displayNumber="a" style="" class="" > <content> 为保护乙方的知识产权，防止制假者利用保乐力加产品的空瓶、瓶盖或瓶套等产品包装生产假冒伪劣产品,根据乙方要求，甲方应尽力将被要求回收的产品包装悉数退还乙方，由乙方统一回收和销毁。各产品具体的包装回收要求由乙方另行以函件形式通知甲方。为行文简便起见，非经特别说明下文所称“包装“指甲方从丙方进货的保乐力加产品的或乙方要求回收的保乐力加产品的包装。 </content> <type>Read</type> </section> <section name="" displayNumber="b" style="" class="" > <content> 规范的产品包装回收由乙方委托的人员或委托的第三方物流公司进行，并经乙方确认符合要求，具体回收频率和时间将根据本协议履行过程中甲方的实际的销量确定。 </content> <type>Read</type> </section> <section name="" displayNumber="c" style="" class="" > <content>包装回收率=包装回收的实际数/甲方从丙方的实际进货量。</content> <type>Read</type> </section> <section name="" displayNumber="d" style="" class="" > <content>乙方包装回收制度的目的是打击假冒伪劣产品，而非鼓励甲方通过从他处回收包装牟利。</content> <type>Read</type> </section> <section name="" displayNumber="e" style="" class="" > <content>虽然乙方不要求回收包装的所有组件，但甲方承诺不会将保乐力加回收产品包装后剩余的包装组件如空瓶、瓶塞、瓶口防回灌装置或外盒等其它产品包装直接或间接赠送、出售给制假者或者随意丢弃，或自行使用保乐力加产品包装的全部或部分制作伪劣的、假冒的保乐力加产品，否则乙方有权行使本协议第7条第j款下约定的权利。</content> <type>Read</type> </section> <section name="" displayNumber="7" style="font-weight: bold;" class="" > <content>保证</content> <type>Read</type> </section> <section name="" displayNumber="a" style="" class="" > <content>甲方承诺其为依法设立并有效存续的法人实体，在签订本协议时并确保在本协议有效期内拥有在其合法登记注册的经营场所内从事酒类销售及相关餐饮娱乐服务的合法有效的营业执照等所有必需的政府批准和许可。</content> <type>Read</type> </section> <section name="" displayNumber="b" style="" class="" > <content>甲方承诺只在乙方认可的销售渠道中购买保乐力加产品，拒绝销售任何伪劣产品、假货和走私货并且按乙方要求回收产品包装给乙方或其指定人员处理。</content> <type>Read</type> </section> <section name="" displayNumber="c" style="" class="" > <content>甲方同意，其所采购的保乐力加产品仅限于在自身经营的场所内销售，不得转售任何第三方，除非经乙方和丙方的事先书面同意</content> <type>Read</type> </section> <section name="" displayNumber="d" style="" class="" > <content>甲、丙两方须对其与乙方购销产品数量和价格保密，若因甲/丙方泄露相关信息而导致给乙方造成经济损失的，甲/丙方方须赔偿乙方由此产生的全部经济损失。</content> <type>Read</type> </section> <section name="" displayNumber="e" style="" class="" > <content>甲方声明并同意，未曾且将不会，在为乙方、丙方开展业务的过程中， </content> <type>Read</type> <subSection> <section name="" displayNumber="(1)" style="" class="" > <content>违反任何适用的反贿赂政策和反贿赂法；</content> <type>Read</type> </section> <section name="" displayNumber="(2)" style="" class="" > <content>提供、承诺给与、给予、同意接受或接受任何非法贿赂、回扣、回报、影响付款、返利或其他非法支付（包括疏通费）。</content> <type>Read</type> </section> </subSection> </section> <section name="" displayNumber="" style="" class="" > <content>应乙方的要求，甲方随时应将其向乙方提供服务的记录和会计账册提供，以供审查和/或审计使用。</content> <type>Read</type> </section> <section name="" displayNumber="" style="" class="" > <content>如果甲方或其关联方、雇员、集团公司、分包商、代理或代表违反陈述，且/或因涉及或从事任何可能构成反贿赂法下犯罪的行为被指控或被调查，乙方应有权单方面立即停止付款或终止本协议，或按照本协议的条款采取适当行为。</content> <type>Read</type> </section> <section name="" displayNumber="" style="" class="" > <content>为本条款之目的，“贿赂”是指某人向另一人提供、承诺提供或者给予某项利益，旨在使其（或另外之人）不适当地履行职责，或者将其用作对上述人员不当履行职责之酬劳。索取或者同意收受上述利益也属于贿赂行为。 通过第三方提供或者收受贿赂并不影响行为性质，仍应认定为贿赂行为。贿赂所涉及的利益可以采用财物或其他手段。财物是指现金和实物，包括现金和实物，任何包括假借促销费、宣传、赞助费、科研费、劳务费、咨询费、佣金等名义，或者以报销各种费用等方式，给付另一方的财物；任何其他手段包括提供国内外各种名义的旅游、考察等给付财物以外的其他利益的手段。</content> <type>Read</type> </section> <section name="" displayNumber="f" style="" class="" > <content>甲方同意向乙方提供保乐力加产品的销售信息（包括进货、存货、价格、销售情况、消费者反映等）以及与乙方业务相关的其它市场信息。甲方同意，乙方人员有权查看甲方账目和销售情况以核实甲方提供的销售信息，甲方工作人员应当予以积极配合，否则乙方有权决定甲方不予获得当期的品牌推广服务费以及A类销售折扣。 </content> <type>Read</type> </section> <section name="" displayNumber="g" style="" class="" > <content>甲方应遵守酒类销售相关法规并将对理性饮酒行动提供适当的支持，包括但不限于： </content> <type>Read</type> <subSection> <section name="" displayNumber="●" style="" class="" > <content>拒绝向疑似未成年人或孕妇出售酒精饮料；</content> <type>Read</type> </section> <section name="" displayNumber="●" style="" class="" > <content>在适当范围内努力避免向醉酒人员出售或推销酒精饮料；及</content> <type>Read</type> </section> <section name="" displayNumber="●" style="" class="" > <content>在适当范围内努力劝阻酒后驾车行为。</content> <type>Read</type> </section> </subSection> </section> <section name="" displayNumber="h" style="" class="" > <content>甲方保证，甲方及其关联方在任何时候均遵守所有适用的反洗钱法律法规，并且未曾涉及任何未决或潜在的反洗钱法律诉讼。如果有合理的理由怀疑甲方的任何交易涉及洗钱活动，甲方应当在知悉该等理由后三（3）个工作日以内，向乙方提交一份列明可疑理由的报告。甲方应当停止与涉及可疑交易的任何客户的所有活动，直至进一步的调查使得乙方断定客户并未涉及该等活动。甲方不得向其客户或任何第三方披露提交给乙方报告有关的任何信息，也不得披露正在、已经或将要执行的调查细节或事实。 </content> <type>Read</type> </section> <section name="" displayNumber="i" style="font-weight: bold;" class="" > <content>利益冲突</content> <type>Read</type> </section> <section name="" displayNumber="i" style="" class="" > <content>甲方在此承诺：</content> <type>Read</type> <subSection> <section name="" displayNumber="(1)" style="" class="" > <content>至本协议签署之日，在其最大的认知程度内保证没有导致利益冲突（定义如下）的情况出现，或保证已经就已存在的利益冲突向乙方批露了相关信息。</content> <type>Read</type> </section> <section name="" displayNumber="(2)" style="" class="" > <content>在本协议有效期内，如有任何确切或潜在的利益冲突情况发生或可能发生，自知道或应该知道之日起三日内，以书面形式通知乙方。乙方有权决定是否继续本协议。</content> <type>Read</type> </section> </subSection> </section> <section name="" displayNumber="" style="" class="" > <content>利益冲突的定义：当甲方或其雇员、代理或代表在履行本协议时，因自身利益或与乙方有竞争或有业务往来的任何组织存在义务、亲属关系或其他特殊利害关系，这些关系可能使得甲方在履行本协议时影响其的判断或评价，导致对乙方产生实际的或潜在的损害。</content> <type>Read</type> </section> <section name="" displayNumber="j" style="font-weight: bold;" class="" > <content>违反本条第a、b、c、d、e、f、g、h、i款的规定构成对本协议的根本违约，乙方有权停止支付本协议下的任何费用并有权随时终止本协议。</content> <type>Read</type> </section> <section name="" displayNumber="8" style="font-weight: bold;" class="" > <content>知识产权</content> <type>Read</type> </section> <section name="" displayNumber="a" style="" class="" > <content>甲方/丙方保证不论在本协议期间或终止后其不会生产或销售或恶意致使任何人或任何单位生产或销售假冒保乐力加产品或任何其名称、商标或包装、装潢与保乐力加产品相似并易引起混淆的产品。一旦发现存在侵犯或潜在侵犯乙方或其母公司或关联方的专利、商标、著作权、商业秘密以及其它知识产权权益的行为，甲方/丙方应立即通知乙方，并应与乙方通力合作制止此类侵权行为。</content> <type>Read</type> </section> <section name="" displayNumber="b" style="" class="" > <content>甲方/丙方不得变更、修改或移除任何保乐力加产品上的任何商标、专利声明、著作权声明及产品之上的任何其它标志，也不得在任何此类产品上附加任何其它的标志。甲方/丙方保证从本协议生效之日起，对产品的销售和使用均不会构成任何对乙方或其母公司或关联公司的专利、商标、著作权、商业秘密以及其它知识产权权益的侵犯。</content> <type>Read</type> </section> <section name="" displayNumber="c" style="" class="" > <content>甲方/丙方不得使用 "Pernod Ricard”，“保乐力加”或保乐力加任何产品的品牌（包括中英文） 作为其名称、简称的一部分。未经乙方明确的书面同意，亦不得用任何方式使用乙方或其母公司或关联公司的字号、任何标志、图形、文字、代号。 在任何情况下，甲方/丙方也不得使用乙方、其母公司及关联方的企业名称作为其企业名称。</content> <type>Read</type> </section> <section name="" displayNumber="9" style="font-weight: bold;" class="" > <content>违约责任</content> <type>Read</type> </section> <section name="" displayNumber="" style="" class="" > <content>本协议存续期间，如果一方未能履行本协议规定的义务和保证，除本协议明确约定的救济手段以外， 违约方还应向其它协议方承担损失赔偿责任。</content> <type>Read</type> </section> <section name="" displayNumber="10" style="font-weight: bold;" class="" > <content>协议的延长和终止 </content> <type>Read</type> </section> <section name="" displayNumber="a" style="" class="" > <content>如任何一方在协议期内严违约（如违反第7条和第8条）、有欺诈性行为、遇政府法令禁止经营活动或被申请破产、清算或解散的，协议其它方有权向该方发出书面要求终止协议，本协议即随即终止。丙方具有上述情况的，乙方有权通过一级分销商立即终止丙方二级分销商的资格，同时通知甲方与新的二级分销商签订本协议，甲/丙方对上述安排应积极配合。</content> <type>Read</type> </section> <section name="" displayNumber="b" style="" class="" > <content>除上述情况以外，如果甲/丙方未能履行本协议规定的其它义务和保证，乙方将给予违约方十五（15）个工作日的改正期，若期满后违约方行为未能得到改善和纠正，则视为严重违约，乙方有权立即终止本协议。</content> <type>Read</type> </section> <section name="" displayNumber="c" style="" class="" > <content>协议的终止不影响无过错方向违约方主张经济上的违约或损害赔偿的权利以及协议中有关保密义务和知识产权义务的继续。</content> <type>Read</type> </section> <section name="" displayNumber="11" style="font-weight: bold;" class="" > <content>其它</content> <type>Read</type> </section> <section name="" displayNumber="a" style="" class="" > <content>本协议期满后，在同等条件下，乙方有优先续约权。</content> <type>Read</type> </section> <section name="" displayNumber="b" style="" class="" > <content>在任何情况下，未经一方允许，协议其它方不得将本协议的签署、本协议的内容及在本协议履行过程中获悉的该方的机密信息（包括该方或其关联公司的任何非公开资料包括商业策略，客户信息，批发商信息，活动计划，销量，价格、生意模式及商业秘密等）泄漏给任何第三方或本方的无关人员或用于本协议以外的目的。</content> <type>Read</type> </section> <section name="" displayNumber="c" style="" class="" > <content>除非本协议另有约定，否则任何一方在征得另二方事先书面同意之前均不得转让本协议或其相关权益。但乙方有权在书面通知甲方和丙方后，将本协议或其相关权益转让给乙方的关联方。</content> <type>Read</type> </section> <section name="" displayNumber="d" style="" class="" > <content>若本协议规定一方不得作出某行为，则应当解释为该一方均不得以任何直接或间接的方式或通过任何第三方作出该行为。</content> <type>Read</type> </section> <section name="" displayNumber="e" style="" class="" > <content>凡因本协议引起的或与本协议有关的任何争议，应先协商解决；协商不成的，任何一方均有权向上海市黄浦区人民法院提起诉讼。</content> <type>Read</type> </section> <section name="" displayNumber="f" style="" class="" > <content>本协议一式三份，三方各持有一份。本协议自双方授权代表签字或盖章后生效。其它未尽事宜，由各方协商解决。</content> <type>Read</type> </section> </body> <BodySignature> <section name="BodySignature1" displayNumber="" style="font-weight: bold;font-size: 16px;" class="" > <content>甲方： {1}// 乙方：保乐力加（中国）贸易有限公司</content> <type>Read</type> </section> <section name="" displayNumber="" style="" class="" > <content></content> <type>Read</type> </section> <section name="ChopSignature" displayNumber="" style="" class="" description="Do Not change the name" > <content>签字盖章： // 签字盖章： </content> <type>Read</type> </section> <section name="" displayNumber="" style="" class="" > <content></content> <type>Read</type> </section> <section name="" displayNumber="" style="" class="" > <content>日 期： // 日 期： </content> <type>Read</type> </section> <section name="" displayNumber="" style="" class="" > <content></content> <type>Read</type> </section> <section name="BodySignature2" displayNumber="" style="font-weight: bold;font-size: 16px;" class="" > <content>丙 方：// </content> <type>Read</type> </section> <section name="" displayNumber="" style="" class="" > <content></content> <type>Read</type> </section> <section name="" displayNumber="" style="" class="" > <content>签字盖章： // </content> <type>Read</type> </section> <section name="" displayNumber="" style="" class="" > <content></content> <type>Read</type> </section> <section name="" displayNumber="" style="" class="" > <content>日 期： // </content> <type>Read</type> </section> </BodySignature> <appendix> <section name="Appendix 1" displayNumber="" style="font-size: 18px;" class="" > <content>附件一</content> <type>Read</type> </section> <section name="Brand promotion plan and target of sales" displayNumber="" style="text-align: center;font-size: 16px;" class="" > <content>品牌推广计划和销售目标</content> <section name="Party A" displayNumber="" style="" class="" ><content>{1}</content><type>Read</type></section><section name="Party C" displayNumber="" style="" class="" ><content>{1}</content><type>Read</type></section><section name="Terms of this Agreement" displayNumber="" style="" class="" ><content></content><type>Read</type></section><type>Read</type> </section> <section name="FixCostTableHeader" displayNumber="1" style="" class="AppendixLineHeader" > <content><b><u>品牌推广服务及费用明细 </u> </b></content> <type>Read</type> </section> <section name="FixCostTableLineHeader" displayNumber="" style="" class="" > <content>因品牌推广计划在签订协议时尚未完全确定，乙方有权在具体履行协议时根据其最终确定的品牌推广计划对甲方提供的下述服务项目进行调整，包括增加、取消或变更部分服务项目等。</content> <type>Read</type> </section> <section name="FixCostTable" displayNumber="" style="" class="" description="Do Not change the name" > <content></content> <type>Read</type> <subSection> <section name="" displayNumber="1" style="" class="" > <content> 形象推广服务//形象推广费用//金额//备注</content> <type>Read</type> </section> <section name="" displayNumber="2" style="" class="" description="Do Not change the {FixedCostACCode} {InputAmount} " > <content> {FixedCostACCode}// 1)灯箱、LED、电子屏幕、其它广告形式 <br/> 2)产品陈列、店内外装饰、酒水单、台卡等附加广告宣传<br/> 3)派送宣传物料、广告礼品等 // 1)灯箱、LED等广告租赁费 <br/> 2)陈列广告费 // {InputAmount} //该项费用在本协议签订后【 】个月后支付，甲方需要提供相应的形象宣传照片等支持文件。 </content> <type>Read</type> </section> <section name="" displayNumber="4" style="" class="" description="Do Not change the {FixedCostACCode} {InputAmount}" > <content> {FixedCostACCode}// 同意并协助乙方在店内举行品牌活动，如派对活动等 // N/A // {InputAmount} //该项费用在双方确定具体活动计划时确定具体支付时间和方式。</content> <type>Read</type> </section> <section name="" displayNumber="5" style="" class="" > <content> <br/> // <br/> // 总计： // {FXTotalAmount} //<br/></content> <type>Read</type> </section> <section name="FixCostTable_InputText" displayNumber="6" style="" class="colspan4" > <content> 备注：// {InputText}</content> <type>Read</type> </section> </subSection> </section> <section name="" displayNumber="2" style="" class="AppendixLineHeader" > <content><b><u>销量目标和销售折扣</u> </b></content> <type>Read</type> </section> <section name="SalesDiscount" displayNumber="" style="" class="AppendixLineHeader" > <content>为进一步推广保乐力加产品，乙方对其产品的经销企业实行销售折扣的政策。在符合约定前提条件的情况下，甲方可享受一定的销售折扣。具体要求如下：</content> <type>Read</type> <subSection> <section name="Sales_Discount_of_A_Class" displayNumber="2.1" style="font-weight: bold;" class="displayNumber" > <content>A类销售折扣: </content> <type>Read</type> </section> <section name="BRSFTable" displayNumber="" style="" class="" description="Do Not change the name" > <content>产品名称和规格// 单瓶月销量目标//单瓶销售折扣//合同总销量//合同总销售折扣</content> <type>Read</type> <subSection> <section name="BRSFTableA" displayNumber="" style="" class="2colspan4" > <content>季度A类销售折扣计算方式 //季度A类销售折扣=单瓶销售折扣X确认为甲方从丙方进货的且当季包装被规范回收的保乐力加产品数量单位：瓶）于下一季度内结算。 </content> <type>Read</type> </section> <section name="BRSFTableB" displayNumber="" style="" class="2colspan4 2InputText" description="Do Not change the name" > <content>备注//享受A类销售折扣的前提 1) 季度销量（或进货额）不低于XXX（可选项）;且2) 符合其他约定条件 </content> <type>Read</type> </section> </subSection> </section> <section name="Non_standard_Convert" displayNumber="" style="" class="" > <content>非标准规格折算：[&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;] </content> <type>Read</type> </section> <section name="PSFTableHeader" displayNumber="2.2" style="font-weight: bold;" class="displayNumber" > <content>B类销售折扣: </content> <type>Read</type> </section> <section name="PSFTable" displayNumber="" style="" class="" description="Do Not change the name" > <content>产品列表//月销量指标//月达标销售折扣//合同销量指标// 合同达标销售折扣 </content> <type>Read</type> <subSection> <section name="PSFTableA_HeaderTerm" displayNumber="2.2." style="" class="BySubBrand displayNumber" description="Do Not change the name and displayNumber format"> <content>甲方按品牌完成下述约定的销量指标是进一步享受B类销售折扣的前提条件。 </content> <type>Read</type> </section> <section name="PSFTableA_HeaderTerm" displayNumber="2.2." style="" class="ByGrade displayNumber" description="Do Not change the name and displayNumber format"> <content>甲方按品牌档次完成下述约定的销量指标是进一步享受B类销售折扣的前提条件。 </content> <type>Read</type> </section> <section name="PSFTableA_HeaderTerm" displayNumber="2.2." style="" class="ByCategory displayNumber" description="Do Not change the name and displayNumber format"> <content>甲方按产品类别完成下述约定的销量指标是进一步享受B类销售折扣的前提条件。 </content> <type>Read</type> </section> <section name="PSFTableA_HeaderTerm" displayNumber="2.2." style="" class="ByTotal displayNumber" description="Do Not change the name and displayNumber format"> <content>甲方按总销量完成下述约定的销量指标是进一步享受B类销售折扣的前提条件。 </content> <type>Read</type> </section> <section name="PSFTableA_In_total" displayNumber="" style="" class="" > <content>总计： </content> <type>Read</type> </section> <section name="PSFTableA" displayNumber="" style="" class="1rowspan1 2colspan4 2InputText BySubBrand" description="Do Not change the name format and the name should be unique" > <content>备注// </content> <type>Read</type> </section> <section name="PSFTableD" displayNumber="" style="" class="1rowspan1 2colspan2 2InputText ByGrade" description="Do Not change the name format" > <content>备注// </content> <type>Read</type> </section> <section name="PSFTableG" displayNumber="" style="" class="1rowspan1 2colspan2 2InputText ByCategory" description="Do Not change the name format" > <content>备注// </content> <type>Read</type> </section> <section name="PSFTableI" displayNumber="" style="" class="1rowspan1 2colspan2 2InputText ByTotal" description="Do Not change the name format" > <content>备注// </content> <type>Read</type> </section> </subSection> </section> <section name="Event_Support" displayNumber="2.3" style="font-weight: bold;" class="displayNumber" > <content>活动支持费用 </content> <type>Read</type> </section> <section name="Event_Support 1" displayNumber="" style="" class="" > <content>甲方完成下述约定的销量指标是进一步享受活动支持费用的前提条件。 </content> <type>Read</type> </section> <section name="VECTable" displayNumber="" style="" class="" description="Do Not change the name" > <content>产品列表//月销量指标//月达标销售折扣//合同销量指标 //合同达标销售折扣 </content> <type>Read</type> <subSection> <section name="VECTableA_In_total" displayNumber="" style="" class="" > <content>总计： </content> <type>Read</type> </section> <section name="VECTableA" displayNumber="" style="" class="2colspan4 2InputText BySubBrand" description="Do Not change the name" > <content>备注// </content> <type>Read</type> </section> <section name="VECTableB" displayNumber="" style="" class="2colspan4 2InputText ByGrade" description="Do Not change the name" > <content>备注// </content> <type>Read</type> </section> <section name="VECTableC" displayNumber="" style="" class="2colspan4 2InputText ByCategory" description="Do Not change the name" > <content>备注// </content> <type>Read</type> </section> <section name="VECTableD" displayNumber="" style="" class="2colspan4 2InputText ByTotal" description="Do Not change the name" > <content>备注// </content> <type>Read</type> </section> </subSection> </section> </subSection> </section> <section name="Payment Conditions" displayNumber="3" style="" class="AppendixLineHeader" > <content><b><u>品牌推广服务费及销售折扣的支付条件</u> </b></content> <type>Read</type> <subSection> <section name="" displayNumber="1)" style="" class="" > <content>甲方依据约定为乙方开展的各项品牌推广活动提供场地、便利和其他支持是甲方获得品牌推广服务费的前提条件。 </content> <type>Read</type> </section> <section name="Payment_Conditions_BC_Rate" displayNumber="2)" style="" class="" > <content>包装回收率不低于 {BCRate} ，系甲方享受各类销售折扣的前提条件之一。包装回收率超过100%时，按100%封顶计。 </content> <type>Read</type> </section> <section name="Payment_ConditionsC" displayNumber="3)" style="" class="" description="Do Not change the {1}-{6}" > <content>{0}年{1}月{2}日至{3}年{4}月{5}日期间，假设甲方100%完成销量目标，且包装回收率为100%，则预计A类销售折扣总计人民币{6}元。本条系预估，对乙方不具有约束力。 </content> <type>Selectable</type> </section> <section name="Selectable1" displayNumber="4)" style="" class="" description="Please Input Name Field" > <content>如果本协议期内，甲方未能完成约定的年度B类销量指标，则本协议自动延期直至B类销量指标完成为止。协议延续期间本协议各方的权利义务保持不变，品牌推广服务费除外(无自动延续)。 </content> <type>Selectable</type> </section> <section name="" displayNumber="5)" style="" class="" > <content>甲方同意上述各项品牌推广服务费可以现金或产品实物的形式支付。 </content> <type>Read</type> </section> <section name="" displayNumber="6)" style="" class="" > <content>甲方始终遵守以下第4条的各项承诺。 </content> <type>Read</type> </section> </subSection> </section> <section name="Party A undertakes" displayNumber="4" style="font-weight: bold;" class="AppendixLineHeader" > <content><b><u>甲方承诺</u> </b></content> <type>Read</type> <subSection> <section name="" displayNumber="a)" style="" class="" > <content>将在法律允许的范围内在甲方场地尽其最大商业努力推销乙方产品。 </content> <type>Read</type> </section> <section name="" displayNumber="b)" style="" class="" > <content>甲方场地内用于调制杯饮类的副酒将尽量使用乙方品类中相应品种的产品。 </content> <type>Read</type> </section> <section name="" displayNumber="c)" style="" class="" > <content>在甲方场地重点展示乙方产品及其品牌。 </content> <type>Read</type> </section> <section name="" displayNumber="d)" style="" class="" > <content>应乙方不时之请求，为乙方的品牌在场内举行促销活动提供场地和服务。 </content> <type>Read</type> </section> <section name="PartyAUndertakes_e" displayNumber="e)" style="" class="" > <content>{InputText} </content> <type>Selectable</type> </section> </subSection> </section> <section name="Affiliates_List" displayNumber="5" style="font-weight: bold;" class="AppendixLineHeader" description="Party A under the Agreement shall also include its affiliates " > <content> <b><u>为避免疑义，本协议项下的甲方亦指其关联公司</u> </b> ：{Outlet}</content> <type>Read</type> </section> </appendix> <AppendixSignature><section name="" displayNumber="" style=""   class=""  description="Do Not change the name"><content>{1}//{2} </content><type>Read</type></section><section name="ChopSignature" displayNumber="" style=""   class=""  description="Do Not change the name"><content>Sign // Here </content><type>Read</type></section></AppendixSignature> </source>';
            
            
            
            String XMLTestString2='<source> <header> <section name="Sales and Branding Promotion Agreement" displayNumber="" style="text-align: center;font-weight: bold;"> <content>销售和品牌推广协议</content> <type>Read</type> </section> <section name="drink on the premises" displayNumber="" style="text-align: center;font-weight: bold;"> <content>堂饮</content> <type>Read</type> </section> <section name="Party A" displayNumber="" style=""> <content>甲方：{InputWholesaler}(店家名称) </content> <type>Read</type> </section> <section name="Party B" displayNumber="" style=""> <content>乙方：保乐力加（中国）贸易有限公司 </content> <type>Read</type> </section> </header> <body> <section name="Header with original contract" displayNumber="" style="font-weight: bold;"> <content>鉴于：</content> <type>Read</type> </section> <section name="WhereasA" displayNumber="A" style=""> <title></title> <content>甲方为保乐力加产品在甲方所在市场的批发商，在传统堂饮渠道拥有丰富客户资源；乙方为保乐力加产品在中国的独家总经销商；</content> <type>Read</type> </section> <section name="WhereasB" displayNumber="B" style=""> <content>乙方为在甲方所在渠道推广保乐力加产品品牌、提高产品的知名度并打击假冒伪劣产品，愿意与甲方合作。</content> <type>Read</type> </section> <section name="Agreement" displayNumber="" style=""> <content>现经友好协商，双方达成协议如下：</content> <type>Read</type> </section> <section name="TermsofthisAgreement" displayNumber="1" style="font-weight: bold;"> <content>协议期限</content> <type>Read</type> </section> <section name="Terms of this Agreement" displayNumber="" style=""> <content>本协议期限自{1}年{2}月{3}日 至{4}年{5}月{6}日。</content> <type>Read</type> </section> <section name="ProductsPart" displayNumber="2" style="font-weight: bold;" class="" > <content>拓展堂饮门店及产品</content> <type>Read</type> <subSection> <section name="" displayNumber="a" style="" class="" > <content>双方同意在以下堂饮门店（以下简称“门店“）内推广并销售保乐力加产品：</content> <type>Read</type> </section> <section name="ProductsPart1" displayNumber="" style="" class="" > <content>{CoveredOutletTable}</content> <type>Read</type> </section> <section name="" displayNumber="b" style="" class="" > <content>甲方在上述堂饮渠道销售之保乐力加产品的具体名称、规格等见产品清单 （下称“保乐力加产品” 或“产品”）。</content> <type>Read</type> </section> </subSection> </section> <section name="All parties sell Products" displayNumber="3" style="font-weight: bold;"> <content>订货、交付与货款支付 </content> <type>Read</type> </section> <section name="All parties sell Products" displayNumber="a" style=""> <content>甲方应当通过乙方认可的销售渠道采购保乐力加产品。 </content> <type>Read</type> </section> <section name="All parties sell Products" displayNumber="b" style=""> <content>甲方向门店供应产品，具体订货、交付和货款支付细节由甲方与门店另行约定，与乙方无涉。</content> <type>Read</type> </section> <section name="Conditions for Payment" displayNumber="4" style="font-weight: bold;"> <content>货款的付款条件</content> <type>Read</type> </section> <section name="Promotion, sales target and sales discount" displayNumber="4" style="font-weight: bold;"> <content>品牌推广服务、销量目标和销售折扣</content> <type>Read</type> </section> <section name="The payment relating " displayNumber="a" style=""> <content>甲方的承诺和责任。 乙方致力于在甲方渠道提高保乐力加产品及品牌的知名度和形象，甲方同意在其店内向其提供如下品牌推广服务，并尽其最大努力完成约定的销量目标：</content> <type>Read</type> <subSection> <section name="" displayNumber="(1)" style=""> <content>在店内外提供如下品牌的形象宣传服务(具体计划和安排，由双方另行协商确定）</content> <type>Read</type> </section> <section name=" " displayNumber="" style=""> <content>• 陈列放有保乐力加产品广告的灯箱；</content> <type>Read</type> </section> <section name=" " displayNumber="" style=""> <content>• 在店内电子LED上（如有）播放保乐力加产品信息或广告；</content> <type>Read</type> </section> <section name=" " displayNumber="" style=""> <content>• 店内装饰装修上采用与保乐力加产品品牌相关的元素和装饰；</content> <type>Read</type> </section> <section name="" displayNumber="" style=""> <content>• 在店内显著位置放置保乐力加产品陈列柜或在店内陈列柜及显著位置陈列保乐力加产品；</content> <type>Read</type> </section> <section name="" displayNumber="" style=""> <content>• 在店内派送保乐力加产品的宣传品与物料；</content> <type>Read</type> </section> <section name="" displayNumber="" style=""> <content>• 保乐力加产品信息出现在酒水单前列；</content> <type>Read</type> </section> <section name="" displayNumber="" style=""> <content>• 在店内桌上放置含有保乐力加产品信息的台卡等。</content> <type>Read</type> </section> <section name="" displayNumber="(2)" style=""> <content>授予保乐力加产品在店内的促销权，并配合乙方的促销活动提供如下服务：</content> <type>Read</type> </section> <section name="" displayNumber="" style=""> <content>• 为乙方的促销服务提供场地；</content> <type>Read</type> </section> <section name="" displayNumber="" style=""> <content>• 同意乙方向店内派驻促销代表以宣传、推广保乐力加产品。该促销代表的数量和来源由甲、乙双方协商确定；乙方促销员应遵守店内的规章制度；</content> <type>Read</type> </section> <section name="" displayNumber="" style=""> <content>• 同意配合乙方的市场营销计划在店内开展保乐力加产品的促销活动（具体促销活动计划和安排，由双方另行协商确定）。</content> <type>Read</type> </section> <section name="" displayNumber="" style=""> <content>• 在店内桌上放置含有保乐力加产品信息的台卡等。</content> <type>Read</type> </section> <section name="" displayNumber="(3)" style=""> <content>同意并配合乙方在各类节庆及其他时间开展各种品牌活动，包括各种派对、演出、晚宴或品酒会及品牌展示和促销活动（由乙方根据其具体的市场营销计划最终确定）等。</content> <type>Read</type> </section> <section name="" displayNumber="(4)" style=""> <content>尽最大努力完成销量目标。</content> <type>Read</type> </section> </subSection> </section> <section name="" displayNumber="b" style=""> <content>乙方的权利和义务。</content> <type>Read</type> <subSection> <section name="" displayNumber="(1)" style=""> <content>因品牌推广计划尚未完全确定，乙方有权在具体履行协议时根据其最终确定的品牌推广计划对甲方提供的上述服务项目进行调整，包括增加、取消或变更部分服务项目等，并和甲方协商确定销量目标。</content> <type>Read</type> </section> <section name="" displayNumber="(2)" style=""> <content>乙方同意：</content> <type>Read</type> </section> <section name="" displayNumber="" style=""> <content>• 甲方可获得一定服务费用（具体金额和付款条件根据最终确定后的形象宣传活动细节、促销活动方案、甲方品牌活动计划另行约定）和在符合约定条件的前提下享受相应的销售折扣，甲乙双方必须将折扣如实入账；</content> <type>Read</type> </section> <section name="" displayNumber="" style=""> <content>• 及时向甲方提供和品牌形象宣传有关的宣传品、酒具、物料等材料。</content> <type>Read</type> </section> <section name="" displayNumber="" style=""> <content>• 根据甲方的需要向其员工提供一定酒类培训，具体培训的次数、地点和内容由双方协商确定。</content> <type>Read</type> </section> </subSection> </section> <section name="" displayNumber="c" style=""> <content>丙方的义务。</content> <type>Read</type> <subSection> <section name="" displayNumber="(1)" style=""> <content>本条所述品牌推广服务费和销售折扣的全部或部分由丙方支付给甲方。</content> <type>Read</type> </section> </subSection> </section> <section name="" displayNumber="d" style=""> <content>服务费用及销售折扣的支付应以甲方在协议期限内遵守本协议之约定为前提。在付款方向甲方支付任何费用之前，甲方应开具符合中国法律、法规规定及中国税务部门要求的、由中国税务部门监制的记载相应款项的发票。各方对上述各项收付款应在其财务帐上真实明确记载。</content> <type>Read</type> </section> <section name="" displayNumber="5" style="font-weight: bold;"> <content> 打假措施 </content> <type>Read</type> </section> <section name="" displayNumber="a" style=""> <content> 为保护乙方的知识产权，防止制假者利用保乐力加产品的空瓶、瓶盖或瓶套等产品包装生产假冒伪劣产品,根据乙方要求，甲方应尽力将被要求回收的产品包装悉数退还乙方，由乙方统一回收和销毁。各产品具体的包装回收要求由乙方另行以函件形式通知甲方。为行文简便起见，非经特别说明下文所称“包装“指甲方从丙方进货的保乐力加产品的或乙方要求回收的保乐力加产品的包装。 </content> <type>Read</type> </section> <section name="" displayNumber="b" style=""> <content> 规范的产品包装回收由乙方委托的人员或委托的第三方物流公司进行，并经乙方确认符合要求，具体回收频率和时间将根据本协议履行过程中甲方的实际的销量确定。 </content> <type>Read</type> </section> <section name="" displayNumber="c" style=""> <content>包装回收率=包装回收的实际数/甲方从丙方的实际进货量。</content> <type>Read</type> </section> <section name="" displayNumber="d" style=""> <content>乙方包装回收制度的目的是打击假冒伪劣产品，而非鼓励甲方通过从他处回收包装牟利。</content> <type>Read</type> </section> <section name="" displayNumber="e" style=""> <content>虽然乙方不要求回收包装的所有组件，但甲方承诺不会将保乐力加回收产品包装后剩余的包装组件如空瓶、瓶塞、瓶口防回灌装置或外盒等其它产品包装直接或间接赠送、出售给制假者或者随意丢弃，或自行使用保乐力加产品包装的全部或部分制作伪劣的、假冒的保乐力加产品，否则乙方有权行使本协议第7条第j款下约定的权利。</content> <type>Read</type> </section> <section name="" displayNumber="6" style="font-weight: bold;"> <content>保证</content> <type>Read</type> </section> <section name="" displayNumber="a" style=""> <content>甲方承诺其为依法设立并有效存续的法人实体，在签订本协议时并确保在本协议有效期内拥有在其合法登记注册的经营场所内从事酒类销售及相关餐饮娱乐服务的合法有效的营业执照等所有必需的政府批准和许可。</content> <type>Read</type> </section> <section name="" displayNumber="b" style=""> <content>甲方承诺只在乙方认可的销售渠道中购买保乐力加产品，拒绝销售任何伪劣产品、假货和走私货并且按乙方要求回收产品包装给乙方或其指定人员处理。</content> <type>Read</type> </section> <section name="" displayNumber="c" style=""> <content>甲方同意，其所采购的保乐力加产品仅限于在自身经营的场所内销售，不得转售任何第三方，除非经乙方和丙方的事先书面同意</content> <type>Read</type> </section> <section name="" displayNumber="d" style=""> <content>甲、丙两方须对其与乙方购销产品数量和价格保密，若因甲/丙方泄露相关信息而导致给乙方造成经济损失的，甲/丙方方须赔偿乙方由此产生的全部经济损失。</content> <type>Read</type> </section> <section name="" displayNumber="e" style=""> <content>甲方声明并同意，未曾且将不会，在为乙方、丙方开展业务的过程中， </content> <type>Read</type> <subSection> <section name="" displayNumber="(1)" style=""> <content>违反任何适用的反贿赂政策和反贿赂法；</content> <type>Read</type> </section> <section name="" displayNumber="(2)" style=""> <content>提供、承诺给与、给予、同意接受或接受任何非法贿赂、回扣、回报、影响付款、返利或其他非法支付（包括疏通费）。</content> <type>Read</type> </section> </subSection> </section> <section name="" displayNumber="" style=""> <content>应乙方的要求，甲方随时应将其向乙方提供服务的记录和会计账册提供，以供审查和/或审计使用。</content> <type>Read</type> </section> <section name="" displayNumber="" style=""> <content>如果甲方或其关联方、雇员、集团公司、分包商、代理或代表违反陈述，且/或因涉及或从事任何可能构成反贿赂法下犯罪的行为被指控或被调查，乙方应有权单方面立即停止付款或终止本协议，或按照本协议的条款采取适当行为。</content> <type>Read</type> </section> <section name="" displayNumber="" style=""> <content>为本条款之目的，“贿赂”是指某人向另一人提供、承诺提供或者给予某项利益，旨在使其（或另外之人）不适当地履行职责，或者将其用作对上述人员不当履行职责之酬劳。索取或者同意收受上述利益也属于贿赂行为。 通过第三方提供或者收受贿赂并不影响行为性质，仍应认定为贿赂行为。贿赂所涉及的利益可以采用财物或其他手段。财物是指现金和实物，包括现金和实物，任何包括假借促销费、宣传、赞助费、科研费、劳务费、咨询费、佣金等名义，或者以报销各种费用等方式，给付另一方的财物；任何其他手段包括提供国内外各种名义的旅游、考察等给付财物以外的其他利益的手段。</content> <type>Read</type> </section> <section name="" displayNumber="f" style=""> <content>甲方同意向乙方提供保乐力加产品的销售信息（包括进货、存货、价格、销售情况、消费者反映等）以及与乙方业务相关的其它市场信息。甲方同意，乙方人员有权查看甲方账目和销售情况以核实甲方提供的销售信息，甲方工作人员应当予以积极配合，否则乙方有权决定甲方不予获得当期的品牌推广服务费以及A类销售折扣。 </content> <type>Read</type> </section> <section name="" displayNumber="g" style=""> <content>甲方应遵守酒类销售相关法规并将对理性饮酒行动提供适当的支持，包括但不限于： </content> <type>Read</type> <subSection> <section name="" displayNumber="●" style=""> <content>在适当范围内努力避免向醉酒人员出售或推销酒精饮料；及</content> <type>Read</type> </section> <section name="" displayNumber="●" style=""> <content>在适当范围内努力劝阻酒后驾车行为。</content> <type>Read</type> </section> </subSection> </section> <section name="" displayNumber="h" style=""> <content>甲方保证，甲方及其关联方在任何时候均遵守所有适用的反洗钱法律法规，并且未曾涉及任何未决或潜在的反洗钱法律诉讼。如果有合理的理由怀疑甲方的任何交易涉及洗钱活动，甲方应当在知悉该等理由后三（3）个工作日以内，向乙方提交一份列明可疑理由的报告。甲方应当停止与涉及可疑交易的任何客户的所有活动，直至进一步的调查使得乙方断定客户并未涉及该等活动。甲方不得向其客户或任何第三方披露提交给乙方报告有关的任何信息，也不得披露正在、已经或将要执行的调查细节或事实。 </content> <type>Read</type> </section> <section name="" displayNumber="i" style="font-weight: bold;"> <content>利益冲突</content> <type>Read</type> </section> <section name="" displayNumber="i" style=""> <content>甲方在此承诺：</content> <type>Read</type> <subSection> <section name="" displayNumber="(1)" style=""> <content>至本协议签署之日，在其最大的认知程度内保证没有导致利益冲突（定义如下）的情况出现，或保证已经就已存在的利益冲突向乙方批露了相关信息。</content> <type>Read</type> </section> <section name="" displayNumber="(2)" style=""> <content>在本协议有效期内，如有任何确切或潜在的利益冲突情况发生或可能发生，自知道或应该知道之日起三日内，以书面形式通知乙方。乙方有权决定是否继续本协议。</content> <type>Read</type> </section> </subSection> </section> <section name="" displayNumber="" style=""> <content>利益冲突的定义：当甲方或其雇员、代理或代表在履行本协议时，因自身利益或与乙方有竞争或有业务往来的任何组织存在义务、亲属关系或其他特殊利害关系，这些关系可能使得甲方在履行本协议时影响其的判断或评价，导致对乙方产生实际的或潜在的损害。</content> <type>Read</type> </section> <section name="" displayNumber="j" style="font-weight: bold;"> <content>违反本条第a、b、c、d、e、f、g、h、i款的规定构成对本协议的根本违约，乙方有权停止支付本协议下的任何费用并有权随时终止本协议。</content> <type>Read</type> </section> <section name="" displayNumber="7" style="font-weight: bold;"> <content>知识产权</content> <type>Read</type> </section> <section name="" displayNumber="a" style=""> <content>甲方/丙方保证不论在本协议期间或终止后其不会生产或销售或恶意致使任何人或任何单位生产或销售假冒保乐力加产品或任何其名称、商标或包装、装潢与保乐力加产品相似并易引起混淆的产品。一旦发现存在侵犯或潜在侵犯乙方或其母公司或关联方的专利、商标、著作权、商业秘密以及其它知识产权权益的行为，甲方/丙方应立即通知乙方，并应与乙方通力合作制止此类侵权行为。</content> <type>Read</type> </section> <section name="" displayNumber="b" style=""> <content>甲方/丙方不得变更、修改或移除任何保乐力加产品上的任何商标、专利声明、著作权声明及产品之上的任何其它标志，也不得在任何此类产品上附加任何其它的标志。甲方/丙方保证从本协议生效之日起，对产品的销售和使用均不会构成任何对乙方或其母公司或关联公司的专利、商标、著作权、商业秘密以及其它知识产权权益的侵犯。</content> <type>Read</type> </section> <section name="" displayNumber="b" style=""> <content>甲方/丙方不得使用 "Pernod Ricard”，“保乐力加”或保乐力加任何产品的品牌（包括中英文） 作为其名称、简称的一部分。未经乙方明确的书面同意，亦不得用任何方式使用乙方或其母公司或关联公司的字号、任何标志、图形、文字、代号。 在任何情况下，甲方/丙方也不得使用乙方、其母公司及关联方的企业名称作为其企业名称。</content> <type>Read</type> </section> <section name="" displayNumber="8" style="font-weight: bold;"> <content>违约责任</content> <type>Read</type> </section> <section name="" displayNumber="" style=""> <content>本协议存续期间，如果一方未能履行本协议规定的义务和保证，除本协议明确约定的救济手段以外， 违约方还应向其它协议方承担损失赔偿责任。</content> <type>Read</type> </section> <section name="" displayNumber="9" style="font-weight: bold;"> <content>协议的延长和终止 </content> <type>Read</type> </section> <section name="" displayNumber="a" style=""> <content>如任何一方在协议期内严违约（如违反第7条和第8条）、有欺诈性行为、遇政府法令禁止经营活动或被申请破产、清算或解散的，协议其它方有权向该方发出书面要求终止协议，本协议即随即终止。丙方具有上述情况的，乙方有权通过一级分销商立即终止丙方二级分销商的资格，同时通知甲方与新的二级分销商签订本协议，甲/丙方对上述安排应积极配合。</content> <type>Read</type> </section> <section name="" displayNumber="b" style=""> <content>除上述情况以外，如果甲/丙方未能履行本协议规定的其它义务和保证，乙方将给予违约方十五（15）个工作日的改正期，若期满后违约方行为未能得到改善和纠正，则视为严重违约，乙方有权立即终止本协议。</content> <type>Read</type> </section> <section name="" displayNumber="c" style=""> <content>协议的终止不影响无过错方向违约方主张经济上的违约或损害赔偿的权利以及协议中有关保密义务和知识产权义务的继续。</content> <type>Read</type> </section> <section name="" displayNumber="10" style="font-weight: bold;"> <content>其它</content> <type>Read</type> </section> <section name="" displayNumber="a" style=""> <content>本协议期满后，在同等条件下，乙方有优先续约权。</content> <type>Read</type> </section> <section name="" displayNumber="b" style=""> <content>在任何情况下，未经一方允许，协议其它方不得将本协议的签署、本协议的内容及在本协议履行过程中获悉的该方的机密信息（包括该方或其关联公司的任何非公开资料包括商业策略，客户信息，批发商信息，活动计划，销量，价格、生意模式及商业秘密等）泄漏给任何第三方或本方的无关人员或用于本协议以外的目的。</content> <type>Read</type> </section> <section name="" displayNumber="c" style=""> <content>除非本协议另有约定，否则任何一方在征得另二方事先书面同意之前均不得转让本协议或其相关权益。但乙方有权在书面通知甲方和丙方后，将本协议或其相关权益转让给乙方的关联方。</content> <type>Read</type> </section> <section name="" displayNumber="d" style=""> <content>若本协议规定一方不得作出某行为，则应当解释为该一方均不得以任何直接或间接的方式或通过任何第三方作出该行为。</content> <type>Read</type> </section> <section name="" displayNumber="e" style=""> <content>凡因本协议引起的或与本协议有关的任何争议，应先协商解决；协商不成的，任何一方均有权向上海市黄浦区人民法院提起诉讼。</content> <type>Read</type> </section> <section name="" displayNumber="f" style=""> <content>本协议一式贰份，双方各持有一份。本协议自双方授权代表签字或盖章后生效。其它未尽事宜，由双方协商解决。</content> <type>Read</type> </section> </body> <BodySignature> <section name="BodySignature1" displayNumber="" style="font-weight: bold;"> <content>甲方： {InputWholesaler}// 乙方：保乐力加（中国）贸易有限公司</content> <type>Read</type> </section> <section name="" displayNumber="" style=""> <content></content> <type>Read</type> </section> <section name="" displayNumber="" style=""> <content>签字盖章： // 签字盖章： </content> <type>Read</type> </section> <section name="" displayNumber="" style=""> <content></content> <type>Read</type> </section> <section name="" displayNumber="" style=""> <content>日 期： // 日 期： </content> <type>Read</type> </section> <section name="" displayNumber="" style=""> <content></content> <type>Read</type> </section> </BodySignature> <appendix> <section name="Appendix 1" displayNumber="" style="font-size: 18px;" > <content>附件一</content> <type>Read</type> </section> <section name="Brand promotion plan and target of sales" displayNumber="" style="text-align: center;font-size: 16px;" class="" > <content>品牌推广计划和销售目标</content> <type>Read</type> </section> <section name="" displayNumber="1" style="" class="AppendixLineHeader" > <content><b><u>品牌推广服务及费用明细 </u> </b>因品牌推广计划在签订协议时尚未完全确定，乙方有权在具体履行协议时根据其最终确定的品牌推广计划对甲方提供的下述服务项目进行调整，包括增加、取消或变更部分服务项目等。</content> <type>Read</type> </section> <section name="FixCostTable" displayNumber="" style="" description="Do Not change the name" > <content></content> <type>Read</type> <subSection> <section name="" displayNumber="1" style="" class="" > <content> 形象推广服务//形象推广费用//金额//备注</content> <type>Read</type> </section> <section name="" displayNumber="2" style="" class="" description="Do Not change the {FixedCostACCode} {InputAmount} " > <content> {FixedCostACCode}// 1)灯箱、LED、电子屏幕、其它广告形式 2)产品陈列、店内外装饰、酒水单、台卡等附加广告宣传 3)派送宣传物料、广告礼品等 // 1)灯箱、LED等广告租赁费 2)陈列广告费 // {InputAmount} //该项费用在本协议签订后【 】个月后支付，甲方需要提供相应的形象宣传照片等支持文件。 </content> <type>Read</type> </section> <section name="" displayNumber="4" style="" class="" description="Do Not change the {FixedCostACCode} {InputAmount}" > <content> {FixedCostACCode}// 同意并协助乙方在店内举行品牌活动，如派对活动等 // N/A // {InputAmount} //该项费用在双方确定具体活动计划时确定具体支付时间和方式。</content> <type>Read</type> </section> <section name="" displayNumber="5" style="" class="" > <content> <br/> // <br/> // 总计： // {FXTotalAmount} //<br/></content> <type>Read</type> </section> <section name="FixCostTable_InputText" displayNumber="6" style="" class="colspan4" > <content> 备注：// {InputText}</content> <type>Read</type> </section> </subSection> </section> <section name="" displayNumber="2" style="" class="AppendixLineHeader" > <content><b><u>销量目标和销售折扣</u> </b></content> <type>Read</type> </section> <section name="SalesDiscount" displayNumber="" style="" class="AppendixLineHeader" > <content>为进一步推广保乐力加产品，乙方对其产品的经销企业实行销售折扣的政策。在符合约定前提条件的情况下，甲方可享受一定的销售折扣。具体要求如下：</content> <type>Read</type> <subSection> <section name="Sales_Discount_of_A_Class" displayNumber="2.1" style="font-weight: bold;" class="displayNumber" > <content>A类销售折扣: </content> <type>Read</type> </section> <section name="BRSFTable" displayNumber="" style="" class="" description="Do Not change the name" > <content>产品名称和规格// 单瓶月销量目标//单瓶销售折扣//合同总销量//合同总销售折扣</content> <type>Read</type> <subSection> <section name="BRSFTableB" displayNumber="" style="" class="2colspan4 2InputText" description="Do Not change the name" > <content>备注//享受A类销售折扣的前提 1) 季度销量（或进货额）不低于XXX（可选项）;且2) 符合其他约定条件 </content> <type>Read</type> </section> </subSection> </section> <section name="Non_standard_Convert" displayNumber="" style="" class="" > <content>非标准规格折算：[1L = 1.3x70cl; 1.5L = 2x70cl; 3L = 4x70cl; 4.5L = 6x70cl] </content> <type>Read</type> </section> <section name="" displayNumber="" style="" class="" > <content> A类销售折扣的支付条件: </content> <type>Read</type> </section> <section name="" displayNumber="" style="" class="" > <content>当各品牌包装回收率超过100%时，乙方根据超出的品牌实际进货量计算以支付店家A类销售折扣。 </content> <type>Read</type> </section> <section name="ContractLineAddOn" displayNumber="" style="" class="" > <content>在合同期间，假设甲方100%完成销量目标，且包装回收率为100%，则预计A类销售折扣总计{BRSFTotalEstAmount}元。本条为预估，对乙方不具有约束力。 </content> <type>Read</type> </section> <section name="" displayNumber="2.2" style="font-weight: bold;"> <content>B类销售折扣: </content> <type>Read</type> </section> <section name="Sales_Discount_of_B_Class" displayNumber="" style=""> <content>甲方完成下述约定的销量指标是进一步享受B类销售折扣的前提条件。 </content> <type>Read</type> </section> <section name="PSFTable" displayNumber="" style="" class="" description="Do Not change the name" > <content>产品列表//月销量指标//月达标销售折扣//合同销量指标// 合同达标销售折扣 </content> <type>Read</type> <subSection> <section name="PSFTableA_HeaderTerm" displayNumber="2.2." style="" class="BySubBrand displayNumber" description="Do Not change the name and displayNumber format"> <content>甲方按品牌完成下述约定的销量指标是进一步享受B类销售折扣的前提条件。 </content> <type>Read</type> </section> <section name="PSFTableA_HeaderTerm" displayNumber="2.2." style="" class="ByGrade displayNumber" description="Do Not change the name and displayNumber format"> <content>甲方按品牌档次完成下述约定的销量指标是进一步享受B类销售折扣的前提条件。 </content> <type>Read</type> </section> <section name="PSFTableA_HeaderTerm" displayNumber="2.2." style="" class="ByCategory displayNumber" description="Do Not change the name and displayNumber format"> <content>甲方按产品类别完成下述约定的销量指标是进一步享受B类销售折扣的前提条件。 </content> <type>Read</type> </section> <section name="PSFTableA_HeaderTerm" displayNumber="2.2." style="" class="ByTotal displayNumber" description="Do Not change the name and displayNumber format"> <content>甲方按总销量完成下述约定的销量指标是进一步享受B类销售折扣的前提条件。 </content> <type>Read</type> </section> <section name="PSFTableA_In_total" displayNumber="" style="" class="" > <content>总计： </content> <type>Read</type> </section> <section name="PSFTableA" displayNumber="" style="" class="1rowspan1 2colspan4 2InputText BySubBrand" description="Do Not change the name format and the name should be unique" > <content>备注// </content> <type>Read</type> </section> <section name="PSFTableD" displayNumber="" style="" class="1rowspan1 2colspan2 2InputText ByGrade" description="Do Not change the name format" > <content>备注// </content> <type>Read</type> </section> <section name="PSFTableG" displayNumber="" style="" class="1rowspan1 2colspan2 2InputText ByCategory" description="Do Not change the name format" > <content>备注// </content> <type>Read</type> </section> <section name="PSFTableI" displayNumber="" style="" class="1rowspan1 2colspan2 2InputText ByTotal" description="Do Not change the name format" > <content>备注// </content> <type>Read</type> </section> </subSection> </section> <section name="" displayNumber="" style="font-size: 14px; " description="Do Not change the name" > <content>B类销售折扣的支付条件: </content> <type>Read</type> </section> <section name="KeySubBrandPart" displayNumber="" style="" description="Do Not change the name" > <content>● 店家选择{Key-SubBrand}作为主要策略品牌，合同期内进货上述策略品牌达到其销量目标的100%（不能以其他品牌销量抵扣），是B类销售折扣支付的前提条件。</content> <type>Read</type> </section> <section name="ContractLineAddOn" displayNumber="" style="" description="Do Not change the name" > <content>● 每次申请支付的金额以上述策略品牌中最低的目标销量达成率乘以合同B类销售折扣总额为限。全年B类销售折扣总额不超过{OutputPSFTotalAmount}元。</content> <type>Read</type> </section> <section name="" displayNumber="" style="" description="Do Not change the name" > <content>● 芝华士12年以下级别产品不参加B类销售折扣。 </content> <type>Read</type> </section> <section name="" displayNumber="" style="" description="Do Not change the name" > <content>● B类销售折扣支付需要考核各品牌合同至今包装回收率，计算方式如下：</content> <type>Read</type> </section> <section name="" displayNumber="" style="" description="Do Not change the name" > <content> a) 若各品牌的合同至今包装回收率达到规定值，支付金额 = 各品牌B类单瓶销售折扣X各品牌确认为甲方拓展门店从甲方进货的保乐力加产品数量的加总之和；</content> <type>Read</type> </section> <section name="" displayNumber="" style="" description="Do Not change the name" > <content> b) 若各品牌的合同至今包装回收率未达到规定值，支付金额 = 各品牌B类单瓶销售折扣 X 确认为甲方拓展门店从甲方进货的且包装被规范回收的保乐力加产品数量的加总之和。</content> <type>Read</type> </section> <section name="Event_Support" displayNumber="2.3" style="font-weight: bold;"> <content>活动支持费用 </content> <type>Read</type> </section> <section name="Event_Support 1" displayNumber="" style=""> <content>甲方完成下述约定的销量指标是进一步享受活动支持费用的前提条件。 </content> <type>Read</type> </section> <section name="VECTable" displayNumber="" style="" class="" description="Do Not change the name" > <content>产品列表//月销量指标//月达标销售折扣//合同销量指标 //合同达标销售折扣 </content> <type>Read</type> <subSection> <section name="VECTableA_In_total" displayNumber="" style="" class="" > <content>总计： </content> <type>Read</type> </section> <section name="VECTableA" displayNumber="" style="" class="2colspan4 2InputText BySubBrand" description="Do Not change the name" > <content>备注// </content> <type>Read</type> </section> <section name="VECTableB" displayNumber="" style="" class="2colspan4 2InputText ByGrade" description="Do Not change the name" > <content>备注// </content> <type>Read</type> </section> <section name="VECTableC" displayNumber="" style="" class="2colspan4 2InputText ByCategory" description="Do Not change the name" > <content>备注// </content> <type>Read</type> </section> <section name="VECTableD" displayNumber="" style="" class="2colspan4 2InputText ByTotal" description="Do Not change the name" > <content>备注// </content> <type>Read</type> </section> </subSection> </section> <section name="" displayNumber="" style=""> <content>活动赞助费用的支付条件： </content> <type>Read</type> </section> <section name="Event_Support Remark" displayNumber="" style=""> <content>1) 合同期内进货策略品牌达到其销售目标的{InputPercent1}%，是活动赞助费用支付的前提条件。活动赞助费用按上述表格的总额封顶计，并按干邑类和非干邑类的实际销量达成率考核，每期申请支付的金额以上述策略品牌中最低的销量达成率乘以活动赞助费总额为限。 </content> <type>Read</type> </section> <section name="" displayNumber="" style=""> <content>2) 芝华士新境12年以下级别产品不参与活动赞助费用。 </content> <type>Read</type> </section> <section name="" displayNumber="" style=""> <content>3) 活动赞助费用支付需要考核马爹利产品和非马爹利产品各自的合同至今包装回收率， 计算方式如下： </content> <type>Read</type> </section> <section name="" displayNumber="" style=""> <content> a) 若马爹利系列产品和非马爹利系列产品的包装回收率达到规定值，支付金额 = 马爹利系列产品的活动赞助费X马爹利系列产品的销量达成率+非马爹利系列产品的活动赞助费X非马爹利系列产品的销量达成率； </content> <type>Read</type> </section> <section name="" displayNumber="" style=""> <content> b) 若马爹利系列产品和非马爹利系列产品的包装回收率未达到规定值，支付金额 = 马爹利系列产品的活动赞助费X马爹利系列产品的销量达成率X马爹利系列产品的包装回收率+非马爹利系列产品的活动赞助费X非马爹利系列产品的销量达成率X非马爹利系列产品的包装回收率 </content> <type>Read</type> </section> </subSection> </section> <section name="Payment Conditions" displayNumber="3" style="" class="AppendixLineHeader" > <content><b><u>品牌推广服务费及销售折扣的支付条件</u> </b></content> <type>Read</type> <subSection> <section name="" displayNumber="1)" style="" class="" > <content>甲方依据约定为乙方开展的各项品牌推广活动提供场地、便利和其他支持是甲方获得品牌推广服务费的前提条件。 </content> <type>Read</type> </section> <section name="Payment_Conditions_BC_Rate" displayNumber="2)" style="" class="" > <content>马爹利系列产品包装回收率不低于97%，非马爹利系列产品包装回收率不低于 {BCRate} ，系甲方享受各类销售折扣的前提条件之一。包装回收率超过100%时，按100%封顶计。 </content> <type>Read</type> </section> <section name="Payment_ConditionsC" displayNumber="3)" style="" class="" description="Do Not change the {1}-{6}" > <content>{0}年{1}月{2}日至{3}年{4}月{5}日期间，假设甲方100%完成销量目标，且包装回收率为100%，则预计A类销售折扣总计人民币{6}元。本条系预估，对乙方不具有约束力。 </content> <type>Selectable</type> </section> <section name="Selectable1" displayNumber="4)" style="" class="" description="Please Input Name Field" > <content>如果本协议期内，甲方未能完成约定的年度B类销量指标，则本协议自动延期直至B类销量指标完成为止。协议延续期间本协议各方的权利义务保持不变，品牌推广服务费除外(无自动延续)。 </content> <type>Selectable</type> </section> <section name="" displayNumber="5)" style="" class="" > <content>甲方同意上述各项品牌推广服务费可以现金或产品实物的形式支付。 </content> <type>Read</type> </section> <section name="" displayNumber="6)" style="" class="" > <content>甲方始终遵守以下第4条的各项承诺。 </content> <type>Read</type> </section> </subSection> </section> <section name="Party A undertakes" displayNumber="4" style="font-weight: bold;" class="AppendixLineHeader" > <content><b><u>甲方承诺</u> </b></content> <type>Read</type> <subSection> <section name="" displayNumber="a)" style="" class="" > <content>将在法律允许的范围内在甲方场地尽其最大商业努力推销乙方产品。 </content> <type>Read</type> </section> <section name="" displayNumber="b)" style="" class="" > <content>甲方场地内用于调制杯饮类的副酒将尽量使用乙方品类中相应品种的产品。 </content> <type>Read</type> </section> <section name="" displayNumber="c)" style="" class="" > <content>在甲方场地重点展示乙方产品及其品牌。 </content> <type>Read</type> </section> <section name="" displayNumber="d)" style="" class="" > <content>应乙方不时之请求，为乙方的品牌在场内举行促销活动提供场地和服务。 </content> <type>Read</type> </section> <section name="PartyAUndertakes_e" displayNumber="e)" style="" class="" > <content>{InputText} </content> <type>Selectable</type> </section> </subSection> </section> </appendix> <AppendixSignature> <section name="BodySignature1" displayNumber="" style="font-weight: bold;font-size: 16px;" > <content>甲方： {1} </content> <type>Read</type> </section> <section name="" displayNumber="" style="" class="" > <content></content> <type>Read</type> </section> <section name="ChopSignature" displayNumber="" style="" class="" description="Do Not change the name" > <content>签字盖章： </content> <type>Read</type> </section> <section name="" displayNumber="" style="" class="" > <content></content> <type>Read</type> </section> <section name="" displayNumber="" style="" class="" > <content>日 期： </content> <type>Read</type> </section> </AppendixSignature> </source>';
            String XMLTestString3='<source> <header> <section name="Sales and Branding Promotion Agreement" displayNumber="" style="text-align: center;font-size: 20px;" class="" > <content>销售和品牌推广协议</content> <type>Read</type> </section> <section name="drink on the premises" displayNumber="" style="text-align: center;font-size: 18px;" class="" > <content>堂饮</content> <type>Read</type> </section> <section name="Party A" displayNumber="" style="" class="" > <content>甲方：{1}(店家名称) </content> <type>Read</type> </section> <section name="Party B" displayNumber="" style="" class="" > <content>乙方：保乐力加（中国）贸易有限公司 </content> <type>Read</type> </section> <section name="Party C" displayNumber="" style="" class="" > <content>{1} </content> <type>Read</type> </section> </header> <body> <section name="Header with original contract" displayNumber="" style="font-weight: bold;" class="" > <content>鉴于：</content> <type>Read</type> </section> <section name="WhereasA" displayNumber="A" style="" class="" > <title></title> <content>甲方为堂饮服务类企业；乙方为保乐力加产品在中国的独家总经销商；丙方为保乐力加产品在甲方所在城市的批发商及甲方的供货商。</content> <type>Read</type> </section> <section name="WhereasB" displayNumber="B" style="" class="" > <content>乙方为在甲方所在地方推广保乐力加产品品牌、提高产品的知名度并打击假冒伪劣产品，愿意与甲方合作，由甲方配合其市场营销活动提供有关品牌推广服务。丙方作为甲方的直接供货商，愿意为甲方和乙方在品牌发展方面的合作提供物流等方面的协助。</content> <type>Read</type> </section> <section name="WhereasC" displayNumber="C" style="" class="" > <content>同时，为促进保乐力加产品在甲方渠道的销售，协议三方将在甲方渠道开展以打折让利等形式进行促销。</content> <type>Read</type> </section> <section name="Agreement" displayNumber="" style="" class="" > <content>现经友好协商，三方达成协议如下：</content> <type>Read</type> </section> <section name="TermsofthisAgreement" displayNumber="1" style="font-weight: bold;" class="" > <content>协议期限</content> <type>Read</type> </section> <section name="Terms of this Agreement" displayNumber="" style="" class="" > <content>本协议期限自{1}年{2}月{3}日 至{4}年{5}月{6}日。</content> <type>Read</type> </section> <section name="Products" displayNumber="2" style="font-weight: bold;" class="" > <content>产品</content> <type>Read</type> </section> <section name="All parties sell Products" displayNumber="" style="" class="" > <content>三方同意在甲方店内销售保乐力加产品，产品具体名称、规格等见产品清单 （下称“保乐力加产品”或“产品”）。</content> <type>Read</type> </section> <section name="All parties sell Products" displayNumber="3" style="font-weight: bold;" class="" > <content>订货和交付</content> <type>Read</type> </section> <section name="All parties sell Products" displayNumber="a" style="" class="" > <content>甲方应通过订单的形式向丙方订购产品，该订单中应明确订购产品的数量和要求的交货日期。产品的所有订单均须获得丙方的批准。丙方可对所订购产品的数量根据现有库存进行调整，同时不应就未经其接受的购买订单向该客户承担责任。 </content> <type>Read</type> </section> <section name="All parties sell Products" displayNumber="b" style="" class="" > <content>丙方应在订单约定的时间期限内，将货物交付到指定地点和接收人。订单发出后，未经丙方同意，不得对丙方已经收到的任何订单做出修改。</content> <type>Read</type> </section> <section name="All parties sell Products" displayNumber="c" style="" class="" > <content>甲方订购的所有产品均根据标准商业惯例进行包装以便运输和储存。订购产品的灭失和损害风险在指定的交货地点向甲方交付该等订购产品后转移给甲方。如有承运人的，则订购产品的灭失和损害风险自交由第一承运人起转移给甲方。甲方应在收到货物后对货物进行检验。如果货物有破损或包装货物发生短缺，则甲方应立即通知丙方，且在运输公司代表在场的情况下，甲方可拒收破损的货物。破损或短缺的问题应通过召回或调换的方式予以解决。</content> <type>Read</type> </section> <section name="Conditions for Payment" displayNumber="4" style="font-weight: bold;" class="" > <content>货款的付款条件</content> <type>Read</type> </section> <section name="The payment relating " displayNumber="" style="" class="" > <content>本协议项下有关订购产品货款的支付，甲方应以人民币通过银行转账或约定的其他付款方式支付给丙方。</content> <type>Read</type> </section> <section name="Promotion, sales target and sales discount" displayNumber="5" style="font-weight: bold;" class="" > <content>品牌推广服务、销量目标和销售折扣</content> <type>Read</type> </section> <section name="The payment relating " displayNumber="a" style="" class="" > <content>甲方的承诺和责任。 乙方致力于在甲方渠道提高保乐力加产品及品牌的知名度和形象，甲方同意在其店内向其提供如下品牌推广服务，并尽其最大努力完成约定的销量目标：</content> <type>Read</type> <subSection> <section name="" displayNumber="(1)" style="" class="" > <content>在店内外提供如下品牌的形象宣传服务(具体计划和安排，由双方另行协商确定）</content> <type>Read</type> </section> <section name=" " displayNumber="" style="" class="" > <content>• 陈列放有保乐力加产品广告的灯箱；</content> <type>Read</type> </section> <section name=" " displayNumber="" style="" class="" > <content>• 在店内电子LED上（如有）播放保乐力加产品信息或广告；</content> <type>Read</type> </section> <section name=" " displayNumber="" style="" class="" > <content>• 店内装饰装修上采用与保乐力加产品品牌相关的元素和装饰；</content> <type>Read</type> </section> <section name="" displayNumber="" style="" class="" > <content>• 在店内显著位置放置保乐力加产品陈列柜或在店内陈列柜及显著位置陈列保乐力加产品；</content> <type>Read</type> </section> <section name="" displayNumber="" style="" class="" > <content>• 在店内派送保乐力加产品的宣传品与物料；</content> <type>Read</type> </section> <section name="" displayNumber="" style="" class="" > <content>• 保乐力加产品信息出现在酒水单前列；</content> <type>Read</type> </section> <section name="" displayNumber="" style="" class="" > <content>• 在店内桌上放置含有保乐力加产品信息的台卡等。</content> <type>Read</type> </section> <section name="" displayNumber="(2)" style="" class="" > <content>授予保乐力加产品在店内的促销权，并配合乙方的促销活动提供如下服务：</content> <type>Read</type> </section> <section name="" displayNumber="" style="" class="" > <content>• 为乙方的促销服务提供场地；</content> <type>Read</type> </section> <section name="" displayNumber="" style="" class="" > <content>• 同意乙方向店内派驻促销代表以宣传、推广保乐力加产品。该促销代表的数量和来源由甲、乙双方协商确定；乙方促销员应遵守店内的规章制度；</content> <type>Read</type> </section> <section name="" displayNumber="" style="" class="" > <content>• 同意配合乙方的市场营销计划在店内开展保乐力加产品的促销活动（具体促销活动计划和安排，由双方另行协商确定）。</content> <type>Read</type> </section> <section name="" displayNumber="(3)" style="" class="" > <content>同意并配合乙方在各类节庆及其他时间开展各种品牌活动，包括各种派对、演出、晚宴或品酒会及品牌展示和促销活动（由乙方根据其具体的市场营销计划最终确定）等。</content> <type>Read</type> </section> <section name="" displayNumber="(4)" style="" class="" > <content>尽最大努力完成销量目标。</content> <type>Read</type> </section> </subSection> </section> <section name="" displayNumber="b" style="" class="" > <content>乙方的权利和义务。</content> <type>Read</type> <subSection> <section name="" displayNumber="(1)" style="" class="" > <content>因品牌推广计划尚未完全确定，乙方有权在具体履行协议时根据其最终确定的品牌推广计划对甲方提供的上述服务项目进行调整，包括增加、取消或变更部分服务项目等，并和甲方协商确定销量目标。</content> <type>Read</type> </section> <section name="" displayNumber="(2)" style="" class="" > <content>乙方同意：</content> <type>Read</type> </section> <section name="" displayNumber="" style="" class="" > <content>• 甲方可获得一定服务费用（具体金额和付款条件根据最终确定后的形象宣传活动细节、促销活动方案、甲方品牌活动计划另行约定）和在符合约定条件的前提下享受相应的销售折扣，甲乙双方必须将折扣如实入账；</content> <type>Read</type> </section> <section name="" displayNumber="" style="" class="" > <content>• 及时向甲方提供和品牌形象宣传有关的宣传品、酒具、物料等材料。</content> <type>Read</type> </section> <section name="" displayNumber="" style="" class="" > <content>• 根据甲方的需要向其员工提供一定酒类培训，具体培训的次数、地点和内容由双方协商确定。</content> <type>Read</type> </section> </subSection> </section> <section name="" displayNumber="c" style="" class="" > <content>丙方的义务。</content> <type>Read</type> <subSection> <section name="" displayNumber="(1)" style="" class="" > <content>本条所述品牌推广服务费和销售折扣的全部或部分由丙方支付给甲方。</content> <type>Read</type> </section> </subSection> </section> <section name="" displayNumber="d" style="" class="" > <content>服务费用及销售折扣的支付应以甲方在协议期限内遵守本协议之约定为前提。在付款方向甲方支付任何费用之前，甲方应开具符合中国法律、法规规定及中国税务部门要求的、由中国税务部门监制的记载相应款项的发票。各方对上述各项收付款应在其财务帐上真实明确记载。</content> <type>Read</type> </section> <section name="" displayNumber="6" style="font-weight: bold;" class="" > <content> 打假措施 </content> <type>Read</type> </section> <section name="" displayNumber="a" style="" class="" > <content> 为保护乙方的知识产权，防止制假者利用保乐力加产品的空瓶、瓶盖或瓶套等产品包装生产假冒伪劣产品,根据乙方要求，甲方应尽力将被要求回收的产品包装悉数退还乙方，由乙方统一回收和销毁。各产品具体的包装回收要求由乙方另行以函件形式通知甲方。为行文简便起见，非经特别说明下文所称“包装“指甲方从丙方进货的保乐力加产品的或乙方要求回收的保乐力加产品的包装。 </content> <type>Read</type> </section> <section name="" displayNumber="b" style="" class="" > <content> 规范的产品包装回收由甲方自己回收并快递至乙方指定的复核中心，并经乙方确认符合要求，具体回收频率和时间将根据本协议履行过程中门店的实际的销量确定。如甲方在回收过程中偷换、伪造乙方的瓶塞/瓶盖以获取折扣奖励，乙方有权取消或收回该相关折扣奖励，并向甲方主张损害赔偿责任。 </content> <type>Read</type> </section> <section name="" displayNumber="c" style="" class="" > <content>包装回收率=包装回收的实际数/甲方从丙方的实际进货量。</content> <type>Read</type> </section> <section name="" displayNumber="d" style="" class="" > <content>乙方包装回收制度的目的是打击假冒伪劣产品，而非鼓励甲方通过从他处回收包装牟利。</content> <type>Read</type> </section> <section name="" displayNumber="e" style="" class="" > <content>虽然乙方不要求回收包装的所有组件，但甲方承诺不会将保乐力加回收产品包装后剩余的包装组件如空瓶、瓶塞、瓶口防回灌装置或外盒等其它产品包装直接或间接赠送、出售给制假者或者随意丢弃，或自行使用保乐力加产品包装的全部或部分制作伪劣的、假冒的保乐力加产品，否则乙方有权行使本协议第7条第j款下约定的权利。</content> <type>Read</type> </section> <section name="" displayNumber="7" style="font-weight: bold;" class="" > <content>保证</content> <type>Read</type> </section> <section name="" displayNumber="a" style="" class="" > <content>甲方承诺其为依法设立并有效存续的法人实体，在签订本协议时并确保在本协议有效期内拥有在其合法登记注册的经营场所内从事酒类销售及相关餐饮娱乐服务的合法有效的营业执照等所有必需的政府批准和许可。</content> <type>Read</type> </section> <section name="" displayNumber="b" style="" class="" > <content>甲方承诺只在乙方认可的销售渠道中购买保乐力加产品，拒绝销售任何伪劣产品、假货和走私货并且按乙方要求回收产品包装给乙方或其指定人员处理。</content> <type>Read</type> </section> <section name="" displayNumber="c" style="" class="" > <content>甲方同意，其所采购的保乐力加产品仅限于在自身经营的场所内销售，不得转售任何第三方，除非经乙方和丙方的事先书面同意</content> <type>Read</type> </section> <section name="" displayNumber="d" style="" class="" > <content>甲、丙两方须对其与乙方购销产品数量和价格保密，若因甲/丙方泄露相关信息而导致给乙方造成经济损失的，甲/丙方方须赔偿乙方由此产生的全部经济损失。</content> <type>Read</type> </section> <section name="" displayNumber="e" style="" class="" > <content>甲方声明并同意，未曾且将不会，在为乙方、丙方开展业务的过程中， </content> <type>Read</type> <subSection> <section name="" displayNumber="(1)" style="" class="" > <content>违反任何适用的反贿赂政策和反贿赂法；</content> <type>Read</type> </section> <section name="" displayNumber="(2)" style="" class="" > <content>提供、承诺给与、给予、同意接受或接受任何非法贿赂、回扣、回报、影响付款、返利或其他非法支付（包括疏通费）。</content> <type>Read</type> </section> </subSection> </section> <section name="" displayNumber="" style="" class="" > <content>应乙方的要求，甲方随时应将其向乙方提供服务的记录和会计账册提供，以供审查和/或审计使用。</content> <type>Read</type> </section> <section name="" displayNumber="" style="" class="" > <content>如果甲方或其关联方、雇员、集团公司、分包商、代理或代表违反陈述，且/或因涉及或从事任何可能构成反贿赂法下犯罪的行为被指控或被调查，乙方应有权单方面立即停止付款或终止本协议，或按照本协议的条款采取适当行为。</content> <type>Read</type> </section> <section name="" displayNumber="" style="" class="" > <content>为本条款之目的，“贿赂”是指某人向另一人提供、承诺提供或者给予某项利益，旨在使其（或另外之人）不适当地履行职责，或者将其用作对上述人员不当履行职责之酬劳。索取或者同意收受上述利益也属于贿赂行为。 通过第三方提供或者收受贿赂并不影响行为性质，仍应认定为贿赂行为。贿赂所涉及的利益可以采用财物或其他手段。财物是指现金和实物，包括现金和实物，任何包括假借促销费、宣传、赞助费、科研费、劳务费、咨询费、佣金等名义，或者以报销各种费用等方式，给付另一方的财物；任何其他手段包括提供国内外各种名义的旅游、考察等给付财物以外的其他利益的手段。</content> <type>Read</type> </section> <section name="" displayNumber="f" style="" class="" > <content>甲方同意向乙方提供保乐力加产品的销售信息（包括进货、存货、价格、销售情况、消费者反映等）以及与乙方业务相关的其它市场信息。甲方同意，乙方人员有权查看甲方账目和销售情况以核实甲方提供的销售信息，甲方工作人员应当予以积极配合，否则乙方有权决定甲方不予获得当期的品牌推广服务费以及A类销售折扣。 </content> <type>Read</type> </section> <section name="" displayNumber="g" style="" class="" > <content>甲方应遵守酒类销售相关法规并将对理性饮酒行动提供适当的支持，包括但不限于： </content> <type>Read</type> <subSection> <section name="" displayNumber="●" style="" class="" > <content>拒绝向疑似未成年人或孕妇出售酒精饮料；</content> <type>Read</type> </section> <section name="" displayNumber="●" style="" class="" > <content>在适当范围内努力避免向醉酒人员出售或推销酒精饮料；及</content> <type>Read</type> </section> <section name="" displayNumber="●" style="" class="" > <content>在适当范围内努力劝阻酒后驾车行为。</content> <type>Read</type> </section> </subSection> </section> <section name="" displayNumber="h" style="" class="" > <content>甲方保证，甲方及其关联方在任何时候均遵守所有适用的反洗钱法律法规，并且未曾涉及任何未决或潜在的反洗钱法律诉讼。如果有合理的理由怀疑甲方的任何交易涉及洗钱活动，甲方应当在知悉该等理由后三（3）个工作日以内，向乙方提交一份列明可疑理由的报告。甲方应当停止与涉及可疑交易的任何客户的所有活动，直至进一步的调查使得乙方断定客户并未涉及该等活动。甲方不得向其客户或任何第三方披露提交给乙方报告有关的任何信息，也不得披露正在、已经或将要执行的调查细节或事实。 </content> <type>Read</type> </section> <section name="" displayNumber="i" style="font-weight: bold;" class="" > <content>利益冲突</content> <type>Read</type> </section> <section name="" displayNumber="i" style="" class="" > <content>甲方在此承诺：</content> <type>Read</type> <subSection> <section name="" displayNumber="(1)" style="" class="" > <content>至本协议签署之日，在其最大的认知程度内保证没有导致利益冲突（定义如下）的情况出现，或保证已经就已存在的利益冲突向乙方批露了相关信息。</content> <type>Read</type> </section> <section name="" displayNumber="(2)" style="" class="" > <content>在本协议有效期内，如有任何确切或潜在的利益冲突情况发生或可能发生，自知道或应该知道之日起三日内，以书面形式通知乙方。乙方有权决定是否继续本协议。</content> <type>Read</type> </section> </subSection> </section> <section name="" displayNumber="" style="" class="" > <content>利益冲突的定义：当甲方或其雇员、代理或代表在履行本协议时，因自身利益或与乙方有竞争或有业务往来的任何组织存在义务、亲属关系或其他特殊利害关系，这些关系可能使得甲方在履行本协议时影响其的判断或评价，导致对乙方产生实际的或潜在的损害。</content> <type>Read</type> </section> <section name="" displayNumber="j" style="font-weight: bold;" class="" > <content>违反本条第a、b、c、d、e、f、g、h、i款的规定构成对本协议的根本违约，乙方有权停止支付本协议下的任何费用并有权随时终止本协议。</content> <type>Read</type> </section> <section name="" displayNumber="8" style="font-weight: bold;" class="" > <content>知识产权</content> <type>Read</type> </section> <section name="" displayNumber="a" style="" class="" > <content>甲方/丙方保证不论在本协议期间或终止后其不会生产或销售或恶意致使任何人或任何单位生产或销售假冒保乐力加产品或任何其名称、商标或包装、装潢与保乐力加产品相似并易引起混淆的产品。一旦发现存在侵犯或潜在侵犯乙方或其母公司或关联方的专利、商标、著作权、商业秘密以及其它知识产权权益的行为，甲方/丙方应立即通知乙方，并应与乙方通力合作制止此类侵权行为。</content> <type>Read</type> </section> <section name="" displayNumber="b" style="" class="" > <content>甲方/丙方不得变更、修改或移除任何保乐力加产品上的任何商标、专利声明、著作权声明及产品之上的任何其它标志，也不得在任何此类产品上附加任何其它的标志。甲方/丙方保证从本协议生效之日起，对产品的销售和使用均不会构成任何对乙方或其母公司或关联公司的专利、商标、著作权、商业秘密以及其它知识产权权益的侵犯。</content> <type>Read</type> </section> <section name="" displayNumber="c" style="" class="" > <content>甲方/丙方不得使用 "Pernod Ricard”，“保乐力加”或保乐力加任何产品的品牌（包括中英文） 作为其名称、简称的一部分。未经乙方明确的书面同意，亦不得用任何方式使用乙方或其母公司或关联公司的字号、任何标志、图形、文字、代号。 在任何情况下，甲方/丙方也不得使用乙方、其母公司及关联方的企业名称作为其企业名称。</content> <type>Read</type> </section> <section name="" displayNumber="9" style="font-weight: bold;" class="" > <content>违约责任</content> <type>Read</type> </section> <section name="" displayNumber="" style="" class="" > <content>本协议存续期间，如果一方未能履行本协议规定的义务和保证，除本协议明确约定的救济手段以外， 违约方还应向其它协议方承担损失赔偿责任。</content> <type>Read</type> </section> <section name="" displayNumber="10" style="font-weight: bold;" class="" > <content>协议的延长和终止 </content> <type>Read</type> </section> <section name="" displayNumber="a" style="" class="" > <content>如任何一方在协议期内严违约（如违反第7条和第8条）、有欺诈性行为、遇政府法令禁止经营活动或被申请破产、清算或解散的，协议其它方有权向该方发出书面要求终止协议，本协议即随即终止。丙方具有上述情况的，乙方有权通过一级分销商立即终止丙方二级分销商的资格，同时通知甲方与新的二级分销商签订本协议，甲/丙方对上述安排应积极配合。</content> <type>Read</type> </section> <section name="" displayNumber="b" style="" class="" > <content>除上述情况以外，如果甲/丙方未能履行本协议规定的其它义务和保证，乙方将给予违约方十五（15）个工作日的改正期，若期满后违约方行为未能得到改善和纠正，则视为严重违约，乙方有权立即终止本协议。</content> <type>Read</type> </section> <section name="" displayNumber="c" style="" class="" > <content>协议的终止不影响无过错方向违约方主张经济上的违约或损害赔偿的权利以及协议中有关保密义务和知识产权义务的继续。</content> <type>Read</type> </section> <section name="" displayNumber="11" style="font-weight: bold;" class="" > <content>其它</content> <type>Read</type> </section> <section name="" displayNumber="a" style="" class="" > <content>本协议期满后，在同等条件下，乙方有优先续约权。</content> <type>Read</type> </section> <section name="" displayNumber="b" style="" class="" > <content>在任何情况下，未经一方允许，协议其它方不得将本协议的签署、本协议的内容及在本协议履行过程中获悉的该方的机密信息（包括该方或其关联公司的任何非公开资料包括商业策略，客户信息，批发商信息，活动计划，销量，价格、生意模式及商业秘密等）泄漏给任何第三方或本方的无关人员或用于本协议以外的目的。</content> <type>Read</type> </section> <section name="" displayNumber="c" style="" class="" > <content>除非本协议另有约定，否则任何一方在征得另二方事先书面同意之前均不得转让本协议或其相关权益。但乙方有权在书面通知甲方和丙方后，将本协议或其相关权益转让给乙方的关联方。</content> <type>Read</type> </section> <section name="" displayNumber="d" style="" class="" > <content>若本协议规定一方不得作出某行为，则应当解释为该一方均不得以任何直接或间接的方式或通过任何第三方作出该行为。</content> <type>Read</type> </section> <section name="" displayNumber="e" style="" class="" > <content>凡因本协议引起的或与本协议有关的任何争议，应先协商解决；协商不成的，任何一方均有权向上海市黄浦区人民法院提起诉讼。</content> <type>Read</type> </section> <section name="" displayNumber="f" style="" class="" > <content>本协议一式三份，三方各持有一份。本协议自双方授权代表签字或盖章后生效。其它未尽事宜，由各方协商解决。</content> <type>Read</type> </section> </body> <BodySignature> <section name="BodySignature1" displayNumber="" style="font-weight: bold;font-size: 16px;" class="" > <content>甲方： {1}// 乙方：保乐力加（中国）贸易有限公司</content> <type>Read</type> </section> <section name="" displayNumber="" style="" class="" > <content></content> <type>Read</type> </section> <section name="ChopSignature" displayNumber="" style="" class="" description="Do Not change the name" > <content>签字盖章： // 签字盖章： </content> <type>Read</type> </section> <section name="" displayNumber="" style="" class="" > <content></content> <type>Read</type> </section> <section name="" displayNumber="" style="" class="" > <content>日 期： // 日 期： </content> <type>Read</type> </section> <section name="" displayNumber="" style="" class="" > <content></content> <type>Read</type> </section> <section name="BodySignature2" displayNumber="" style="font-weight: bold;font-size: 16px;" class="" > <content>丙 方：// </content> <type>Read</type> </section> <section name="" displayNumber="" style="" class="" > <content></content> <type>Read</type> </section> <section name="" displayNumber="" style="" class="" > <content>签字盖章： // </content> <type>Read</type> </section> <section name="" displayNumber="" style="" class="" > <content></content> <type>Read</type> </section> <section name="" displayNumber="" style="" class="" > <content>日 期： // </content> <type>Read</type> </section> </BodySignature> <appendix> <section name="Appendix 1" displayNumber="" style="font-size: 18px;" class="" > <content>附件一</content> <type>Read</type> </section> <section name="Brand promotion plan and target of sales" displayNumber="" style="text-align: center;font-size: 16px;" class="" > <content>品牌推广计划和销售目标</content> <type>Read</type> </section> <section name="FixCostTableHeader" displayNumber="1" style="" class="AppendixLineHeader" > <content><b><u>品牌推广服务及费用明细 </u> </b></content> <type>Read</type> </section> <section name="FixCostTableLineHeader" displayNumber="" style="" class="" > <content>因品牌推广计划在签订协议时尚未完全确定，乙方有权在具体履行协议时根据其最终确定的品牌推广计划对甲方提供的下述服务项目进行调整，包括增加、取消或变更部分服务项目等。</content> <type>Read</type> </section> <section name="FixCostTable" displayNumber="" style="" class="" description="Do Not change the name" > <content></content> <type>Read</type> <subSection> <section name="" displayNumber="1" style="" class="" > <content> 形象推广服务//形象推广费用//金额//备注</content> <type>Read</type> </section> <section name="" displayNumber="2" style="" class="" description="Do Not change the {FixedCostACCode} {InputAmount} " > <content> {FixedCostACCode}// 1)灯箱、LED、电子屏幕、其它广告形式 2)产品陈列、店内外|装饰、酒水单、|台卡等附加广告宣传 3)派送宣传物料、广告礼品等 // 1)灯箱、LED等广告租赁费 2)陈列广告费 // {InputAmount} //该项费用在本协议签订后【 】个月后支付，甲方需要提供相应的形象宣传照片等支持文件。 </content> <type>Read</type> </section> <section name="" displayNumber="4" style="" class="" description="Do Not change the {FixedCostACCode} {InputAmount}" > <content> {FixedCostACCode}// 同意并协助乙方在店内举行品牌活动，如派对活动等 // N/A // {InputAmount} //该项费用在双方确定具体活动计划时确定具体支付时间和方式。</content> <type>Read</type> </section> <section name="" displayNumber="5" style="" class="" > <content> <br/> // <br/> // 总计： // {FXTotalAmount} //<br/></content> <type>Read</type> </section> <section name="FixCostTable_InputText" displayNumber="6" style="" class="colspan4" > <content> 备注：// {InputText}</content> <type>Read</type> </section> </subSection> </section> <section name="" displayNumber="2" style="" class="AppendixLineHeader" > <content><b><u>销量目标和销售折扣</u> </b></content> <type>Read</type> </section> <section name="SalesDiscount" displayNumber="" style="" class="AppendixLineHeader" > <content>为进一步推广保乐力加产品，乙方对其产品的经销企业实行销售折扣的政策。在符合约定前提条件的情况下，甲方可享受一定的销售折扣。具体要求如下：</content> <type>Read</type> <subSection> <section name="Sales_Discount_of_A_Class" displayNumber="2.1" style="font-weight: bold;" class="displayNumber" > <content>A类销售折扣: </content> <type>Read</type> </section> <section name="BRSFTable" displayNumber="" style="" class="" description="Do Not change the name" > <content>产品名称和规格// 单瓶月销量目标//单瓶销售折扣//合同总销量//合同总销售折扣</content> <type>Read</type> <subSection> <section name="BRSFTableA" displayNumber="" style="" class="2colspan4" > <content>季度A类销售折扣计算方式 //季度A类销售折扣=单瓶销售折扣X确认为甲方从丙方进货的且当季包装被规范回收的保乐力加产品数量单位：瓶）于下一季度内结算。 </content> <type>Read</type> </section> <section name="BRSFTableB" displayNumber="" style="" class="2colspan4 2InputText" description="Do Not change the name" > <content>备注//享受A类销售折扣的前提 1) 季度销量（或进货额）不低于XXX（可选项）;且2) 符合其他约定条件 </content> <type>Read</type> </section> </subSection> </section> <section name="Non_standard_Convert" displayNumber="" style="" class="" > <content>非标准规格折算：[&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;] </content> <type>Read</type> </section> <section name="PSFTableHeader" displayNumber="2.2" style="font-weight: bold;" class="displayNumber" > <content>B类销售折扣: </content> <type>Read</type> </section> <section name="PSFTable" displayNumber="" style="" class="" description="Do Not change the name" > <content>产品列表//月销量指标//月达标销售折扣//合同销量指标// 合同达标销售折扣 </content> <type>Read</type> <subSection> <section name="PSFTableA_HeaderTerm" displayNumber="2.2." style="" class="BySubBrand displayNumber" description="Do Not change the name and displayNumber format"> <content>甲方按品牌完成下述约定的销量指标是进一步享受B类销售折扣的前提条件。 </content> <type>Read</type> </section> <section name="PSFTableA_HeaderTerm" displayNumber="2.2." style="" class="ByGrade displayNumber" description="Do Not change the name and displayNumber format"> <content>甲方按品牌档次完成下述约定的销量指标是进一步享受B类销售折扣的前提条件。 </content> <type>Read</type> </section> <section name="PSFTableA_HeaderTerm" displayNumber="2.2." style="" class="ByCategory displayNumber" description="Do Not change the name and displayNumber format"> <content>甲方按产品类别完成下述约定的销量指标是进一步享受B类销售折扣的前提条件。 </content> <type>Read</type> </section> <section name="PSFTableA_HeaderTerm" displayNumber="2.2." style="" class="ByTotal displayNumber" description="Do Not change the name and displayNumber format"> <content>甲方按总销量完成下述约定的销量指标是进一步享受B类销售折扣的前提条件。 </content> <type>Read</type> </section> <section name="PSFTableA_In_total" displayNumber="" style="" class="" > <content>总计： </content> <type>Read</type> </section> <section name="PSFTableA" displayNumber="" style="" class="1rowspan1 2colspan4 2InputText BySubBrand" description="Do Not change the name format and the name should be unique" > <content>备注// </content> <type>Read</type> </section> <section name="PSFTableD" displayNumber="" style="" class="1rowspan1 2colspan2 2InputText ByGrade" description="Do Not change the name format" > <content>备注// </content> <type>Read</type> </section> <section name="PSFTableG" displayNumber="" style="" class="1rowspan1 2colspan2 2InputText ByCategory" description="Do Not change the name format" > <content>备注// </content> <type>Read</type> </section> <section name="PSFTableI" displayNumber="" style="" class="1rowspan1 2colspan2 2InputText ByTotal" description="Do Not change the name format" > <content>备注// </content> <type>Read</type> </section> </subSection> </section> <section name="Event_Support" displayNumber="2.3" style="font-weight: bold;" class="displayNumber" > <content>活动支持费用 </content> <type>Read</type> </section> <section name="Event_Support 1" displayNumber="" style="" class="" > <content>甲方完成下述约定的销量指标是进一步享受活动支持费用的前提条件。 </content> <type>Read</type> </section> <section name="VECTable" displayNumber="" style="" class="" description="Do Not change the name" > <content>产品列表//月销量指标//月达标销售折扣//合同销量指标 //合同达标销售折扣 </content> <type>Read</type> <subSection> <section name="VECTableA_In_total" displayNumber="" style="" class="" > <content>总计： </content> <type>Read</type> </section> <section name="VECTableA" displayNumber="" style="" class="2colspan4 2InputText BySubBrand" description="Do Not change the name" > <content>备注// </content> <type>Read</type> </section> <section name="VECTableB" displayNumber="" style="" class="2colspan4 2InputText ByGrade" description="Do Not change the name" > <content>备注// </content> <type>Read</type> </section> <section name="VECTableC" displayNumber="" style="" class="2colspan4 2InputText ByCategory" description="Do Not change the name" > <content>备注// </content> <type>Read</type> </section> <section name="VECTableD" displayNumber="" style="" class="2colspan4 2InputText ByTotal" description="Do Not change the name" > <content>备注// </content> <type>Read</type> </section> </subSection> </section> </subSection> </section> <section name="Payment Conditions" displayNumber="3" style="" class="AppendixLineHeader" > <content><b><u>品牌推广服务费及销售折扣的支付条件</u> </b></content> <type>Read</type> <subSection> <section name="" displayNumber="1)" style="" class="" > <content>甲方依据约定为乙方开展的各项品牌推广活动提供场地、便利和其他支持是甲方获得品牌推广服务费的前提条件。 </content> <type>Read</type> </section> <section name="Payment_Conditions_BC_Rate" displayNumber="2)" style="" class="" > <content>马爹利系列产品包装回收率不低于97%，非马爹利系列产品包装回收率不低于 {BCRate} ，系甲方享受各类销售折扣的前提条件之一。包装回收率超过100%时，按100%封顶计。 </content> <type>Read</type> </section> <section name="Payment_ConditionsC" displayNumber="3)" style="" class="" description="Do Not change the {1}-{6}" > <content>{0}年{1}月{2}日至{3}年{4}月{5}日期间，假设甲方100%完成销量目标，且包装回收率为100%，则预计A类销售折扣总计人民币{6}元。本条系预估，对乙方不具有约束力。 </content> <type>Selectable</type> </section> <section name="Selectable1" displayNumber="4)" style="" class="" description="Please Input Name Field" > <content>如果本协议期内，甲方未能完成约定的年度B类销量指标，则本协议自动延期直至B类销量指标完成为止。协议延续期间本协议各方的权利义务保持不变，品牌推广服务费除外(无自动延续)。 </content> <type>Selectable</type> </section> <section name="" displayNumber="5)" style="" class="" > <content>甲方同意上述各项品牌推广服务费可以现金或产品实物的形式支付。 </content> <type>Read</type> </section> <section name="" displayNumber="6)" style="" class="" > <content>甲方始终遵守以下第4条的各项承诺。 </content> <type>Read</type> </section> </subSection> </section> <section name="Party A undertakes" displayNumber="4" style="font-weight: bold;" class="AppendixLineHeader" > <content><b><u>甲方承诺</u> </b></content> <type>Read</type> <subSection> <section name="" displayNumber="a)" style="" class="" > <content>将在法律允许的范围内在甲方场地尽其最大商业努力推销乙方产品。 </content> <type>Read</type> </section> <section name="" displayNumber="b)" style="" class="" > <content>甲方场地内用于调制杯饮类的副酒将尽量使用乙方品类中相应品种的产品。 </content> <type>Read</type> </section> <section name="" displayNumber="c)" style="" class="" > <content>在甲方场地重点展示乙方产品及其品牌。 </content> <type>Read</type> </section> <section name="" displayNumber="d)" style="" class="" > <content>应乙方不时之请求，为乙方的品牌在场内举行促销活动提供场地和服务。 </content> <type>Read</type> </section> <section name="PartyAUndertakes_e" displayNumber="e)" style="" class="" > <content>{InputText} </content> <type>Selectable</type> </section> </subSection> </section> </appendix> <AppendixSignature> <section name="BodySignature1" displayNumber="" style="font-weight: bold;font-size: 16px;" class="" > <content>甲方： {1} </content> <type>Read</type> </section> <section name="" displayNumber="" style="" class="" > <content></content> <type>Read</type> </section> <section name="ChopSignature" displayNumber="" style="" class="" description="Do Not change the name" > <content>签字盖章： </content> <type>Read</type> </section> <section name="" displayNumber="" style="" class="" > <content></content> <type>Read</type> </section> <section name="" displayNumber="" style="" class="" > <content>日 期： </content> <type>Read</type> </section> </AppendixSignature> </source>';
            String XMLTestString4='<source> <header> <section name="Sales and Branding Promotion Agreement" displayNumber="" style="text-align: center;font-size: 20px;" class="" > <content>销售和品牌推广协议</content> <type>Read</type> </section> <section name="drink on the premises" displayNumber="" style="text-align: center;font-size: 18px;" class="" > <content>堂饮</content> <type>Read</type> </section> <section name="Party A" displayNumber="" style="" class="" > <content>甲方：{1}(店家名称) </content> <type>Read</type> </section> <section name="Party B" displayNumber="" style="" class="" > <content>乙方：保乐力加（中国）贸易有限公司 </content> <type>Read</type> </section> <section name="Party C" displayNumber="" style="" class="" > <content>{1} </content> <type>Read</type> </section> </header> <body> <section name="Header with original contract" displayNumber="" style="font-weight: bold;" class="" > <content>鉴于：</content> <type>Read</type> </section> <section name="WhereasA" displayNumber="A" style="" class="" > <title></title> <content>甲方为堂饮服务类企业；乙方为保乐力加产品在中国的独家总经销商；丙方为保乐力加产品在甲方所在城市的批发商及甲方的供货商。</content> <type>Read</type> </section> <section name="WhereasB" displayNumber="B" style="" class="" > <content>乙方为在甲方所在地方推广保乐力加产品品牌、提高产品的知名度并打击假冒伪劣产品，愿意与甲方合作，由甲方配合其市场营销活动提供有关品牌推广服务。丙方作为甲方的直接供货商，愿意为甲方和乙方在品牌发展方面的合作提供物流等方面的协助。</content> <type>Read</type> </section> <section name="WhereasC" displayNumber="C" style="" class="" > <content>同时，为促进保乐力加产品在甲方渠道的销售，协议三方将在甲方渠道开展以打折让利等形式进行促销。</content> <type>Read</type> </section> <section name="Agreement" displayNumber="" style="" class="" > <content>现经友好协商，三方达成协议如下：</content> <type>Read</type> </section> <section name="TermsofthisAgreement" displayNumber="1" style="font-weight: bold;" class="" > <content>协议期限</content> <type>Read</type> </section> <section name="Terms of this Agreement" displayNumber="" style="" class="" > <content>本协议期限自{1}年{2}月{3}日 至{4}年{5}月{6}日。</content> <type>Read</type> </section> <section name="Products" displayNumber="2" style="font-weight: bold;" class="" > <content>产品</content> <type>Read</type> </section> <section name="All parties sell Products" displayNumber="" style="" class="" > <content>三方同意在甲方店内销售保乐力加产品，产品具体名称、规格等见产品清单 （下称“保乐力加产品”或“产品”）。</content> <type>Read</type> </section> <section name="All parties sell Products" displayNumber="3" style="font-weight: bold;" class="" > <content>订货和交付</content> <type>Read</type> </section> <section name="All parties sell Products" displayNumber="a" style="" class="" > <content>甲方应通过订单的形式向丙方订购产品，该订单中应明确订购产品的数量和要求的交货日期。产品的所有订单均须获得丙方的批准。丙方可对所订购产品的数量根据现有库存进行调整，同时不应就未经其接受的购买订单向该客户承担责任。 </content> <type>Read</type> </section> <section name="All parties sell Products" displayNumber="b" style="" class="" > <content>丙方应在订单约定的时间期限内，将货物交付到指定地点和接收人。订单发出后，未经丙方同意，不得对丙方已经收到的任何订单做出修改。</content> <type>Read</type> </section> <section name="All parties sell Products" displayNumber="c" style="" class="" > <content>甲方订购的所有产品均根据标准商业惯例进行包装以便运输和储存。订购产品的灭失和损害风险在指定的交货地点向甲方交付该等订购产品后转移给甲方。如有承运人的，则订购产品的灭失和损害风险自交由第一承运人起转移给甲方。甲方应在收到货物后对货物进行检验。如果货物有破损或包装货物发生短缺，则甲方应立即通知丙方，且在运输公司代表在场的情况下，甲方可拒收破损的货物。破损或短缺的问题应通过召回或调换的方式予以解决。</content> <type>Read</type> </section> <section name="Conditions for Payment" displayNumber="4" style="font-weight: bold;" class="" > <content>货款的付款条件</content> <type>Read</type> </section> <section name="The payment relating " displayNumber="" style="" class="" > <content>本协议项下有关订购产品货款的支付，甲方应以人民币通过银行转账或约定的其他付款方式支付给丙方。</content> <type>Read</type> </section> <section name="Promotion, sales target and sales discount" displayNumber="5" style="font-weight: bold;" class="" > <content>品牌推广服务、销量目标和销售折扣</content> <type>Read</type> </section> <section name="The payment relating " displayNumber="a" style="" class="" > <content>甲方的承诺和责任。 乙方致力于在甲方渠道提高保乐力加产品及品牌的知名度和形象，甲方同意在其店内向其提供如下品牌推广服务，并尽其最大努力完成约定的销量目标：</content> <type>Read</type> <subSection> <section name="" displayNumber="(1)" style="" class="" > <content>在店内外提供如下品牌的形象宣传服务(具体计划和安排，由双方另行协商确定）</content> <type>Read</type> </section> <section name=" " displayNumber="" style="" class="" > <content>• 陈列放有保乐力加产品广告的灯箱；</content> <type>Read</type> </section> <section name=" " displayNumber="" style="" class="" > <content>• 在店内电子LED上（如有）播放保乐力加产品信息或广告；</content> <type>Read</type> </section> <section name=" " displayNumber="" style="" class="" > <content>• 店内装饰装修上采用与保乐力加产品品牌相关的元素和装饰；</content> <type>Read</type> </section> <section name="" displayNumber="" style="" class="" > <content>• 在店内显著位置放置保乐力加产品陈列柜或在店内陈列柜及显著位置陈列保乐力加产品；</content> <type>Read</type> </section> <section name="" displayNumber="" style="" class="" > <content>• 在店内派送保乐力加产品的宣传品与物料；</content> <type>Read</type> </section> <section name="" displayNumber="" style="" class="" > <content>• 保乐力加产品信息出现在酒水单前列；</content> <type>Read</type> </section> <section name="" displayNumber="" style="" class="" > <content>• 在店内桌上放置含有保乐力加产品信息的台卡等。</content> <type>Read</type> </section> <section name="" displayNumber="(2)" style="" class="" > <content>授予保乐力加产品在店内的促销权，并配合乙方的促销活动提供如下服务：</content> <type>Read</type> </section> <section name="" displayNumber="" style="" class="" > <content>• 为乙方的促销服务提供场地；</content> <type>Read</type> </section> <section name="" displayNumber="" style="" class="" > <content>• 同意乙方向店内派驻促销代表以宣传、推广保乐力加产品。该促销代表的数量和来源由甲、乙双方协商确定；乙方促销员应遵守店内的规章制度；</content> <type>Read</type> </section> <section name="" displayNumber="" style="" class="" > <content>• 同意配合乙方的市场营销计划在店内开展保乐力加产品的促销活动（具体促销活动计划和安排，由双方另行协商确定）。</content> <type>Read</type> </section> <section name="" displayNumber="(3)" style="" class="" > <content>同意并配合乙方在各类节庆及其他时间开展各种品牌活动，包括各种派对、演出、晚宴或品酒会及品牌展示和促销活动（由乙方根据其具体的市场营销计划最终确定）等。</content> <type>Read</type> </section> <section name="" displayNumber="(4)" style="" class="" > <content>尽最大努力完成销量目标。</content> <type>Read</type> </section> </subSection> </section> <section name="" displayNumber="b" style="" class="" > <content>乙方的权利和义务。</content> <type>Read</type> <subSection> <section name="" displayNumber="(1)" style="" class="" > <content>因品牌推广计划尚未完全确定，乙方有权在具体履行协议时根据其最终确定的品牌推广计划对甲方提供的上述服务项目进行调整，包括增加、取消或变更部分服务项目等，并和甲方协商确定销量目标。</content> <type>Read</type> </section> <section name="" displayNumber="(2)" style="" class="" > <content>乙方同意：</content> <type>Read</type> </section> <section name="" displayNumber="" style="" class="" > <content>• 甲方可获得一定服务费用（具体金额和付款条件根据最终确定后的形象宣传活动细节、促销活动方案、甲方品牌活动计划另行约定）和在符合约定条件的前提下享受相应的销售折扣，甲乙双方必须将折扣如实入账；</content> <type>Read</type> </section> <section name="" displayNumber="" style="" class="" > <content>• 及时向甲方提供和品牌形象宣传有关的宣传品、酒具、物料等材料。</content> <type>Read</type> </section> <section name="" displayNumber="" style="" class="" > <content>• 根据甲方的需要向其员工提供一定酒类培训，具体培训的次数、地点和内容由双方协商确定。</content> <type>Read</type> </section> </subSection> </section> <section name="" displayNumber="c" style="" class="" > <content>丙方的义务。</content> <type>Read</type> <subSection> <section name="" displayNumber="(1)" style="" class="" > <content>本条所述品牌推广服务费和销售折扣的全部或部分由丙方支付给甲方。</content> <type>Read</type> </section> </subSection> </section> <section name="" displayNumber="d" style="" class="" > <content>服务费用及销售折扣的支付应以甲方在协议期限内遵守本协议之约定为前提。在付款方向甲方支付任何费用之前，甲方应开具符合中国法律、法规规定及中国税务部门要求的、由中国税务部门监制的记载相应款项的发票。各方对上述各项收付款应在其财务帐上真实明确记载。</content> <type>Read</type> </section> <section name="" displayNumber="6" style="font-weight: bold;" class="" > <content> 打假措施 </content> <type>Read</type> </section> <section name="" displayNumber="a" style="" class="" > <content> 为保护乙方的知识产权，防止制假者利用保乐力加产品的空瓶、瓶盖或瓶套等产品包装生产假冒伪劣产品,根据乙方要求，甲方应尽力将被要求回收的产品包装悉数退还乙方，由乙方统一回收和销毁。各产品具体的包装回收要求由乙方另行以函件形式通知甲方。为行文简便起见，非经特别说明下文所称“包装“指甲方从丙方进货的保乐力加产品的或乙方要求回收的保乐力加产品的包装。 </content> <type>Read</type> </section> <section name="" displayNumber="b" style="" class="" > <content> 规范的产品包装回收由甲方自己回收并快递至乙方指定的复核中心，并经乙方确认符合要求，具体回收频率和时间将根据本协议履行过程中门店的实际的销量确定。如甲方在回收过程中偷换、伪造乙方的瓶塞/瓶盖以获取折扣奖励，乙方有权取消或收回该相关折扣奖励，并向甲方主张损害赔偿责任。 </content> <type>Read</type> </section> <section name="" displayNumber="c" style="" class="" > <content>包装回收率=包装回收的实际数/甲方从丙方的实际进货量。</content> <type>Read</type> </section> <section name="" displayNumber="d" style="" class="" > <content>乙方包装回收制度的目的是打击假冒伪劣产品，而非鼓励甲方通过从他处回收包装牟利。</content> <type>Read</type> </section> <section name="" displayNumber="e" style="" class="" > <content>虽然乙方不要求回收包装的所有组件，但甲方承诺不会将保乐力加回收产品包装后剩余的包装组件如空瓶、瓶塞、瓶口防回灌装置或外盒等其它产品包装直接或间接赠送、出售给制假者或者随意丢弃，或自行使用保乐力加产品包装的全部或部分制作伪劣的、假冒的保乐力加产品，否则乙方有权行使本协议第7条第j款下约定的权利。</content> <type>Read</type> </section> <section name="" displayNumber="7" style="font-weight: bold;" class="" > <content>保证</content> <type>Read</type> </section> <section name="" displayNumber="a" style="" class="" > <content>甲方承诺其为依法设立并有效存续的法人实体，在签订本协议时并确保在本协议有效期内拥有在其合法登记注册的经营场所内从事酒类销售及相关餐饮娱乐服务的合法有效的营业执照等所有必需的政府批准和许可。</content> <type>Read</type> </section> <section name="" displayNumber="b" style="" class="" > <content>甲方承诺只在乙方认可的销售渠道中购买保乐力加产品，拒绝销售任何伪劣产品、假货和走私货并且按乙方要求回收产品包装给乙方或其指定人员处理。</content> <type>Read</type> </section> <section name="" displayNumber="c" style="" class="" > <content>甲方同意，其所采购的保乐力加产品仅限于在自身经营的场所内销售，不得转售任何第三方，除非经乙方和丙方的事先书面同意</content> <type>Read</type> </section> <section name="" displayNumber="d" style="" class="" > <content>甲、丙两方须对其与乙方购销产品数量和价格保密，若因甲/丙方泄露相关信息而导致给乙方造成经济损失的，甲/丙方方须赔偿乙方由此产生的全部经济损失。</content> <type>Read</type> </section> <section name="" displayNumber="e" style="" class="" > <content>甲方声明并同意，未曾且将不会，在为乙方、丙方开展业务的过程中， </content> <type>Read</type> <subSection> <section name="" displayNumber="(1)" style="" class="" > <content>违反任何适用的反贿赂政策和反贿赂法；</content> <type>Read</type> </section> <section name="" displayNumber="(2)" style="" class="" > <content>提供、承诺给与、给予、同意接受或接受任何非法贿赂、回扣、回报、影响付款、返利或其他非法支付（包括疏通费）。</content> <type>Read</type> </section> </subSection> </section> <section name="" displayNumber="" style="" class="" > <content>应乙方的要求，甲方随时应将其向乙方提供服务的记录和会计账册提供，以供审查和/或审计使用。</content> <type>Read</type> </section> <section name="" displayNumber="" style="" class="" > <content>如果甲方或其关联方、雇员、集团公司、分包商、代理或代表违反陈述，且/或因涉及或从事任何可能构成反贿赂法下犯罪的行为被指控或被调查，乙方应有权单方面立即停止付款或终止本协议，或按照本协议的条款采取适当行为。</content> <type>Read</type> </section> <section name="" displayNumber="" style="" class="" > <content>为本条款之目的，“贿赂”是指某人向另一人提供、承诺提供或者给予某项利益，旨在使其（或另外之人）不适当地履行职责，或者将其用作对上述人员不当履行职责之酬劳。索取或者同意收受上述利益也属于贿赂行为。 通过第三方提供或者收受贿赂并不影响行为性质，仍应认定为贿赂行为。贿赂所涉及的利益可以采用财物或其他手段。财物是指现金和实物，包括现金和实物，任何包括假借促销费、宣传、赞助费、科研费、劳务费、咨询费、佣金等名义，或者以报销各种费用等方式，给付另一方的财物；任何其他手段包括提供国内外各种名义的旅游、考察等给付财物以外的其他利益的手段。</content> <type>Read</type> </section> <section name="" displayNumber="f" style="" class="" > <content>甲方同意向乙方提供保乐力加产品的销售信息（包括进货、存货、价格、销售情况、消费者反映等）以及与乙方业务相关的其它市场信息。甲方同意，乙方人员有权查看甲方账目和销售情况以核实甲方提供的销售信息，甲方工作人员应当予以积极配合，否则乙方有权决定甲方不予获得当期的品牌推广服务费以及A类销售折扣。 </content> <type>Read</type> </section> <section name="" displayNumber="g" style="" class="" > <content>甲方应遵守酒类销售相关法规并将对理性饮酒行动提供适当的支持，包括但不限于： </content> <type>Read</type> <subSection> <section name="" displayNumber="●" style="" class="" > <content>拒绝向疑似未成年人或孕妇出售酒精饮料；</content> <type>Read</type> </section> <section name="" displayNumber="●" style="" class="" > <content>在适当范围内努力避免向醉酒人员出售或推销酒精饮料；及</content> <type>Read</type> </section> <section name="" displayNumber="●" style="" class="" > <content>在适当范围内努力劝阻酒后驾车行为。</content> <type>Read</type> </section> </subSection> </section> <section name="" displayNumber="h" style="" class="" > <content>甲方保证，甲方及其关联方在任何时候均遵守所有适用的反洗钱法律法规，并且未曾涉及任何未决或潜在的反洗钱法律诉讼。如果有合理的理由怀疑甲方的任何交易涉及洗钱活动，甲方应当在知悉该等理由后三（3）个工作日以内，向乙方提交一份列明可疑理由的报告。甲方应当停止与涉及可疑交易的任何客户的所有活动，直至进一步的调查使得乙方断定客户并未涉及该等活动。甲方不得向其客户或任何第三方披露提交给乙方报告有关的任何信息，也不得披露正在、已经或将要执行的调查细节或事实。 </content> <type>Read</type> </section> <section name="" displayNumber="i" style="font-weight: bold;" class="" > <content>利益冲突</content> <type>Read</type> </section> <section name="" displayNumber="i" style="" class="" > <content>甲方在此承诺：</content> <type>Read</type> <subSection> <section name="" displayNumber="(1)" style="" class="" > <content>至本协议签署之日，在其最大的认知程度内保证没有导致利益冲突（定义如下）的情况出现，或保证已经就已存在的利益冲突向乙方批露了相关信息。</content> <type>Read</type> </section> <section name="" displayNumber="(2)" style="" class="" > <content>在本协议有效期内，如有任何确切或潜在的利益冲突情况发生或可能发生，自知道或应该知道之日起三日内，以书面形式通知乙方。乙方有权决定是否继续本协议。</content> <type>Read</type> </section> </subSection> </section> <section name="" displayNumber="" style="" class="" > <content>利益冲突的定义：当甲方或其雇员、代理或代表在履行本协议时，因自身利益或与乙方有竞争或有业务往来的任何组织存在义务、亲属关系或其他特殊利害关系，这些关系可能使得甲方在履行本协议时影响其的判断或评价，导致对乙方产生实际的或潜在的损害。</content> <type>Read</type> </section> <section name="" displayNumber="j" style="font-weight: bold;" class="" > <content>违反本条第a、b、c、d、e、f、g、h、i款的规定构成对本协议的根本违约，乙方有权停止支付本协议下的任何费用并有权随时终止本协议。</content> <type>Read</type> </section> <section name="" displayNumber="8" style="font-weight: bold;" class="" > <content>知识产权</content> <type>Read</type> </section> <section name="" displayNumber="a" style="" class="" > <content>甲方/丙方保证不论在本协议期间或终止后其不会生产或销售或恶意致使任何人或任何单位生产或销售假冒保乐力加产品或任何其名称、商标或包装、装潢与保乐力加产品相似并易引起混淆的产品。一旦发现存在侵犯或潜在侵犯乙方或其母公司或关联方的专利、商标、著作权、商业秘密以及其它知识产权权益的行为，甲方/丙方应立即通知乙方，并应与乙方通力合作制止此类侵权行为。</content> <type>Read</type> </section> <section name="" displayNumber="b" style="" class="" > <content>甲方/丙方不得变更、修改或移除任何保乐力加产品上的任何商标、专利声明、著作权声明及产品之上的任何其它标志，也不得在任何此类产品上附加任何其它的标志。甲方/丙方保证从本协议生效之日起，对产品的销售和使用均不会构成任何对乙方或其母公司或关联公司的专利、商标、著作权、商业秘密以及其它知识产权权益的侵犯。</content> <type>Read</type> </section> <section name="" displayNumber="c" style="" class="" > <content>甲方/丙方不得使用 "Pernod Ricard”，“保乐力加”或保乐力加任何产品的品牌（包括中英文） 作为其名称、简称的一部分。未经乙方明确的书面同意，亦不得用任何方式使用乙方或其母公司或关联公司的字号、任何标志、图形、文字、代号。 在任何情况下，甲方/丙方也不得使用乙方、其母公司及关联方的企业名称作为其企业名称。</content> <type>Read</type> </section> <section name="" displayNumber="9" style="font-weight: bold;" class="" > <content>违约责任</content> <type>Read</type> </section> <section name="" displayNumber="" style="" class="" > <content>本协议存续期间，如果一方未能履行本协议规定的义务和保证，除本协议明确约定的救济手段以外， 违约方还应向其它协议方承担损失赔偿责任。</content> <type>Read</type> </section> <section name="" displayNumber="10" style="font-weight: bold;" class="" > <content>协议的延长和终止 </content> <type>Read</type> </section> <section name="" displayNumber="a" style="" class="" > <content>如任何一方在协议期内严违约（如违反第7条和第8条）、有欺诈性行为、遇政府法令禁止经营活动或被申请破产、清算或解散的，协议其它方有权向该方发出书面要求终止协议，本协议即随即终止。丙方具有上述情况的，乙方有权通过一级分销商立即终止丙方二级分销商的资格，同时通知甲方与新的二级分销商签订本协议，甲/丙方对上述安排应积极配合。</content> <type>Read</type> </section> <section name="" displayNumber="b" style="" class="" > <content>除上述情况以外，如果甲/丙方未能履行本协议规定的其它义务和保证，乙方将给予违约方十五（15）个工作日的改正期，若期满后违约方行为未能得到改善和纠正，则视为严重违约，乙方有权立即终止本协议。</content> <type>Read</type> </section> <section name="" displayNumber="c" style="" class="" > <content>协议的终止不影响无过错方向违约方主张经济上的违约或损害赔偿的权利以及协议中有关保密义务和知识产权义务的继续。</content> <type>Read</type> </section> <section name="" displayNumber="11" style="font-weight: bold;" class="" > <content>其它</content> <type>Read</type> </section> <section name="" displayNumber="a" style="" class="" > <content>本协议期满后，在同等条件下，乙方有优先续约权。</content> <type>Read</type> </section> <section name="" displayNumber="b" style="" class="" > <content>在任何情况下，未经一方允许，协议其它方不得将本协议的签署、本协议的内容及在本协议履行过程中获悉的该方的机密信息（包括该方或其关联公司的任何非公开资料包括商业策略，客户信息，批发商信息，活动计划，销量，价格、生意模式及商业秘密等）泄漏给任何第三方或本方的无关人员或用于本协议以外的目的。</content> <type>Read</type> </section> <section name="" displayNumber="c" style="" class="" > <content>除非本协议另有约定，否则任何一方在征得另二方事先书面同意之前均不得转让本协议或其相关权益。但乙方有权在书面通知甲方和丙方后，将本协议或其相关权益转让给乙方的关联方。</content> <type>Read</type> </section> <section name="" displayNumber="d" style="" class="" > <content>若本协议规定一方不得作出某行为，则应当解释为该一方均不得以任何直接或间接的方式或通过任何第三方作出该行为。</content> <type>Read</type> </section> <section name="" displayNumber="e" style="" class="" > <content>凡因本协议引起的或与本协议有关的任何争议，应先协商解决；协商不成的，任何一方均有权向上海市黄浦区人民法院提起诉讼。</content> <type>Read</type> </section> <section name="" displayNumber="f" style="" class="" > <content>本协议一式三份，三方各持有一份。本协议自双方授权代表签字或盖章后生效。其它未尽事宜，由各方协商解决。</content> <type>Read</type> </section> </body> <BodySignature> <section name="BodySignature1" displayNumber="" style="font-weight: bold;font-size: 16px;" class="" > <content>甲方： {1}// 乙方：保乐力加（中国）贸易有限公司</content> <type>Read</type> </section> <section name="" displayNumber="" style="" class="" > <content></content> <type>Read</type> </section> <section name="ChopSignature" displayNumber="" style="" class="" description="Do Not change the name" > <content>签字盖章： // 签字盖章： </content> <type>Read</type> </section> <section name="" displayNumber="" style="" class="" > <content></content> <type>Read</type> </section> <section name="" displayNumber="" style="" class="" > <content>日 期： // 日 期： </content> <type>Read</type> </section> <section name="" displayNumber="" style="" class="" > <content></content> <type>Read</type> </section> <section name="BodySignature2" displayNumber="" style="font-weight: bold;font-size: 16px;" class="" > <content>丙 方：// </content> <type>Read</type> </section> <section name="" displayNumber="" style="" class="" > <content></content> <type>Read</type> </section> <section name="" displayNumber="" style="" class="" > <content>签字盖章： // </content> <type>Read</type> </section> <section name="" displayNumber="" style="" class="" > <content></content> <type>Read</type> </section> <section name="" displayNumber="" style="" class="" > <content>日 期： // </content> <type>Read</type> </section> </BodySignature> <appendix> <section name="Appendix 1" displayNumber="" style="font-size: 18px;" class="" > <content>附件一</content> <type>Read</type> </section> <section name="Brand promotion plan and target of sales" displayNumber="" style="text-align: center;font-size: 16px;" class="" > <content>品牌推广计划和销售目标</content> <type>Read</type> </section> <section name="FixCostTableHeader" displayNumber="1" style="" class="AppendixLineHeader" > <content><b><u>品牌推广服务及费用明细 </u> </b></content> <type>Read</type> </section> <section name="FixCostTableLineHeader" displayNumber="" style="" class="" > <content>因品牌推广计划在签订协议时尚未完全确定，乙方有权在具体履行协议时根据其最终确定的品牌推广计划对甲方提供的下述服务项目进行调整，包括增加、取消或变更部分服务项目等。</content> <type>Read</type> </section> <section name="FixCostTable" displayNumber="" style="" class="" description="Do Not change the name" > <content></content> <type>Read</type> <subSection> <section name="" displayNumber="1" style="" class="" > <content> 形象推广服务//形象推广费用//金额//备注</content> <type>Read</type> </section> <section name="" displayNumber="2" style="" class="" description="Do Not change the {FixedCostACCode} {InputAmount} " > <content> {FixedCostACCode}// 1)灯箱、LED、电子屏幕、其它广告形式 2)产品陈列、店内外装饰、酒水单、台卡等附加广告宣传 3)派送宣传物料、广告礼品等 // 1)灯箱、LED等广告租赁费 2)陈列广告费 // {InputAmount} //该项费用在本协议签订后【 】个月后支付，甲方需要提供相应的形象宣传照片等支持文件。 </content> <type>Read</type> </section> <section name="" displayNumber="4" style="" class="" description="Do Not change the {FixedCostACCode} {InputAmount}" > <content> {FixedCostACCode}// 同意并协助乙方在店内举行品牌活动，如派对活动等 // N/A // {InputAmount} //该项费用在双方确定具体活动计划时确定具体支付时间和方式。</content> <type>Read</type> </section> <section name="" displayNumber="5" style="" class="" > <content> <br/> // <br/> // 总计： // {FXTotalAmount} //<br/></content> <type>Read</type> </section> <section name="FixCostTable_InputText" displayNumber="6" style="" class="colspan4" > <content> 备注：// {InputText}</content> <type>Read</type> </section> </subSection> </section> <section name="" displayNumber="2" style="" class="AppendixLineHeader" > <content><b><u>销量目标和销售折扣</u> </b></content> <type>Read</type> </section> <section name="SalesDiscount" displayNumber="" style="" class="AppendixLineHeader" > <content>为进一步推广保乐力加产品，乙方对其产品的经销企业实行销售折扣的政策。在符合约定前提条件的情况下，甲方可享受一定的销售折扣。具体要求如下：</content> <type>Read</type> <subSection> <section name="Sales_Discount_of_A_Class" displayNumber="2.1" style="font-weight: bold;" class="displayNumber" > <content>A类销售折扣: </content> <type>Read</type> </section> <section name="BRSFTable" displayNumber="" style="" class="" description="Do Not change the name" > <content>产品名称和规格// 单瓶月销量目标//单瓶销售折扣//合同总销量//合同总销售折扣</content> <type>Read</type> <subSection> <section name="BRSFTableA" displayNumber="" style="" class="2colspan4" > <content>季度A类销售折扣计算方式 //季度A类销售折扣=单瓶销售折扣X确认为甲方从丙方进货的且当季包装被规范回收的保乐力加产品数量单位：瓶）于下一季度内结算。 </content> <type>Read</type> </section> <section name="BRSFTableB" displayNumber="" style="" class="2colspan4 2InputText" description="Do Not change the name" > <content>备注//享受A类销售折扣的前提 1) 季度销量（或进货额）不低于XXX（可选项）;且2) 符合其他约定条件 </content> <type>Read</type> </section> </subSection> </section> <section name="Non_standard_Convert" displayNumber="" style="" class="" > <content>非标准规格折算：[&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;] </content> <type>Read</type> </section> <section name="PSFTableHeader" displayNumber="2.2" style="font-weight: bold;" class="displayNumber" > <content>B类销售折扣: </content> <type>Read</type> </section> <section name="PSFTable" displayNumber="" style="" class="" description="Do Not change the name" > <content>产品列表//月销量指标//月达标销售折扣//合同销量指标// 合同达标销售折扣 </content> <type>Read</type> <subSection> <section name="PSFTableA_HeaderTerm" displayNumber="2.2." style="" class="BySubBrand displayNumber" description="Do Not change the name and displayNumber format"> <content>甲方按品牌完成下述约定的销量指标是进一步享受B类销售折扣的前提条件。 </content> <type>Read</type> </section> <section name="PSFTableA_HeaderTerm" displayNumber="2.2." style="" class="ByGrade displayNumber" description="Do Not change the name and displayNumber format"> <content>甲方按品牌档次完成下述约定的销量指标是进一步享受B类销售折扣的前提条件。 </content> <type>Read</type> </section> <section name="PSFTableA_HeaderTerm" displayNumber="2.2." style="" class="ByCategory displayNumber" description="Do Not change the name and displayNumber format"> <content>甲方按产品类别完成下述约定的销量指标是进一步享受B类销售折扣的前提条件。 </content> <type>Read</type> </section> <section name="PSFTableA_HeaderTerm" displayNumber="2.2." style="" class="ByTotal displayNumber" description="Do Not change the name and displayNumber format"> <content>甲方按总销量完成下述约定的销量指标是进一步享受B类销售折扣的前提条件。 </content> <type>Read</type> </section> <section name="PSFTableA_In_total" displayNumber="" style="" class="" > <content>总计： </content> <type>Read</type> </section> <section name="PSFTableA" displayNumber="" style="" class="1rowspan1 2colspan4 2InputText BySubBrand" description="Do Not change the name format and the name should be unique" > <content>备注// </content> <type>Read</type> </section> <section name="PSFTableD" displayNumber="" style="" class="1rowspan1 2colspan2 2InputText ByGrade" description="Do Not change the name format" > <content>备注// </content> <type>Read</type> </section> <section name="PSFTableG" displayNumber="" style="" class="1rowspan1 2colspan2 2InputText ByCategory" description="Do Not change the name format" > <content>备注// </content> <type>Read</type> </section> <section name="PSFTableI" displayNumber="" style="" class="1rowspan1 2colspan2 2InputText ByTotal" description="Do Not change the name format" > <content>备注// </content> <type>Read</type> </section> </subSection> </section> <section name="Event_Support" displayNumber="2.3" style="font-weight: bold;" class="displayNumber" > <content>活动支持费用 </content> <type>Read</type> </section> <section name="Event_Support 1" displayNumber="" style="" class="" > <content>甲方完成下述约定的销量指标是进一步享受活动支持费用的前提条件。 </content> <type>Read</type> </section> <section name="VECTable" displayNumber="" style="" class="" description="Do Not change the name" > <content>产品列表//月销量指标//月达标销售折扣//合同销量指标 //合同达标销售折扣 </content> <type>Read</type> <subSection> <section name="VECTableA_In_total" displayNumber="" style="" class="" > <content>总计： </content> <type>Read</type> </section> <section name="VECTableA" displayNumber="" style="" class="2colspan4 2InputText BySubBrand" description="Do Not change the name" > <content>备注// </content> <type>Read</type> </section> <section name="VECTableB" displayNumber="" style="" class="2colspan4 2InputText ByGrade" description="Do Not change the name" > <content>备注// </content> <type>Read</type> </section> <section name="VECTableC" displayNumber="" style="" class="2colspan4 2InputText ByCategory" description="Do Not change the name" > <content>备注// </content> <type>Read</type> </section> <section name="VECTableD" displayNumber="" style="" class="2colspan4 2InputText ByTotal" description="Do Not change the name" > <content>备注// </content> <type>Read</type> </section> </subSection> </section> </subSection> </section> <section name="Payment Conditions" displayNumber="3" style="" class="AppendixLineHeader" > <content><b><u>品牌推广服务费及销售折扣的支付条件</u> </b></content> <type>Read</type> <subSection> <section name="" displayNumber="1)" style="" class="" > <content>甲方依据约定为乙方开展的各项品牌推广活动提供场地、便利和其他支持是甲方获得品牌推广服务费的前提条件。 </content> <type>Read</type> </section> <section name="Payment_Conditions_BC_Rate" displayNumber="2)" style="" class="" > <content>马爹利系列产品包装回收率不低于97%，非马爹利系列产品包装回收率不低于 {BCRate} ，系甲方享受各类销售折扣的前提条件之一。包装回收率超过100%时，按100%封顶计。 </content> <type>Read</type> </section> <section name="Payment_ConditionsC" displayNumber="3)" style="" class="" description="Do Not change the {1}-{6}" > <content>{0}年{1}月{2}日至{3}年{4}月{5}日期间，假设甲方100%完成销量目标，且包装回收率为100%，则预计A类销售折扣总计人民币{6}元。本条系预估，对乙方不具有约束力。 </content> <type>Selectable</type> </section> <section name="Selectable1" displayNumber="4)" style="" class="" description="Please Input Name Field" > <content>如果本协议期内，甲方未能完成约定的年度B类销量指标，则本协议自动延期直至B类销量指标完成为止。协议延续期间本协议各方的权利义务保持不变，品牌推广服务费除外(无自动延续)。 </content> <type>Selectable</type> </section> <section name="" displayNumber="5)" style="" class="" > <content>甲方同意上述各项品牌推广服务费可以现金或产品实物的形式支付。 </content> <type>Read</type> </section> <section name="" displayNumber="6)" style="" class="" > <content>甲方始终遵守以下第4条的各项承诺。 </content> <type>Read</type> </section> </subSection> </section> <section name="Party A undertakes" displayNumber="4" style="font-weight: bold;" class="AppendixLineHeader" > <content><b><u>甲方承诺</u> </b></content> <type>Read</type> <subSection> <section name="" displayNumber="a)" style="" class="" > <content>将在法律允许的范围内在甲方场地尽其最大商业努力推销乙方产品。 </content> <type>Read</type> </section> <section name="" displayNumber="b)" style="" class="" > <content>甲方场地内用于调制杯饮类的副酒将尽量使用乙方品类中相应品种的产品。 </content> <type>Read</type> </section> <section name="" displayNumber="c)" style="" class="" > <content>在甲方场地重点展示乙方产品及其品牌。 </content> <type>Read</type> </section> <section name="" displayNumber="d)" style="" class="" > <content>应乙方不时之请求，为乙方的品牌在场内举行促销活动提供场地和服务。 </content> <type>Read</type> </section> <section name="PartyAUndertakes_e" displayNumber="e)" style="" class="" > <content>{InputText} </content> <type>Selectable</type> </section> </subSection> </section> </appendix> <AppendixSignature> <section name="BodySignature1" displayNumber="" style="font-weight: bold;font-size: 16px;" class="" > <content>甲方： {1} </content> <type>Read</type> </section> <section name="" displayNumber="" style="" class="" > <content></content> <type>Read</type> </section> <section name="ChopSignature" displayNumber="" style="" class="" description="Do Not change the name" > <content>签字盖章： </content> <type>Read</type> </section> <section name="" displayNumber="" style="" class="" > <content></content> <type>Read</type> </section> <section name="" displayNumber="" style="" class="" > <content>日 期： </content> <type>Read</type> </section> </AppendixSignature> </source>';
            
            
            String XMLTestString5='<source> <header> <section name="Sales and Branding Promotion Agreement" displayNumber="" style="text-align: center;font-size: 20px;" class="" > <content>销售和品牌推广协议</content> <type>Read</type> </section> <section name="drink on the premises" displayNumber="" style="text-align: center;font-size: 18px;" class="" > <content>堂饮</content> <type>Read</type> </section> <section name="Party A" displayNumber="" style="" class="" > <content>甲方：{InputWholesaler}(店家名称) </content> <type>Read</type> </section> <section name="Party B" displayNumber="" style="" class="" > <content>乙方：保乐力加（中国）贸易有限公司 </content> <type>Read</type> </section> </header> <body> <section name="Header with original contract" displayNumber="" style="font-weight: bold;" class="" > <content>鉴于：</content> <type>Read</type> </section> <section name="WhereasA" displayNumber="A" style="" class="" > <title></title> <content>甲方为保乐力加产品在甲方所在市场的批发商，在传统堂饮渠道拥有丰富客户资源；乙方为保乐力加产品在中国的独家总经销商；</content> <type>Read</type> </section> <section name="WhereasB" displayNumber="B" style="" class="" > <content>乙方为在甲方所在渠道推广保乐力加产品品牌、提高产品的知名度并打击假冒伪劣产品，愿意与甲方合作。</content> <type>Read</type> </section> <section name="Agreement" displayNumber="" style="" class="" > <content>现经友好协商，三方达成协议如下：</content> <type>Read</type> </section> <section name="TermsofthisAgreement" displayNumber="1" style="font-weight: bold;" class="" > <content>协议期限</content> <type>Read</type> </section> <section name="Terms of this Agreement" displayNumber="" style="" class="" > <content>本协议期限自{1}年{2}月{3}日 至{4}年{5}月{6}日。</content> <type>Read</type> </section> <section name="ProductsPart" displayNumber="2" style="font-weight: bold;" class="" > <content>拓展堂饮门店及产品</content> <type>Read</type> <subSection> <section name="" displayNumber="a" style="" class="" > <content>双方同意在以下堂饮门店（以下简称“门店“）内推广并销售保乐力加产品：</content> <type>Read</type> </section> <section name="ProductsPart1" displayNumber="" style="" class="" > <content>{CoveredOutletTable}</content> <type>Read</type> </section> <section name="" displayNumber="b" style="" class="" > <content>甲方在上述堂饮渠道销售之保乐力加产品的具体名称、规格等见产品清单 （下称“保乐力加产品” 或“产品”）。</content> <type>Read</type> </section> </subSection> </section> <section name="All parties sell Products" displayNumber="3" style="font-weight: bold;" class="" > <content>订货、交付与货款支付 </content> <type>Read</type> </section> <section name="All parties sell Products" displayNumber="a" style="" class="" > <content>甲方应当通过乙方认可的销售渠道采购保乐力加产品。 </content> <type>Read</type> </section> <section name="All parties sell Products" displayNumber="b" style="" class="" > <content>甲方向门店供应产品，具体订货、交付和货款支付细节由甲方与门店另行约定，与乙方无涉。</content> <type>Read</type> </section> <section name="Promotion, sales target and sales discount" displayNumber="4" style="font-weight: bold;" class="" > <content>销量目标和销售折扣</content> <type>Read</type> </section> <section name="The payment relating " displayNumber="a" style="" class="" > <content>甲方的承诺和责任。 乙方致力于在甲方渠道提高保乐力加产品及品牌的知名度和形象，甲方同意在其店内向其提供如下品牌推广服务，并尽其最大努力完成约定的销量目标：</content> <type>Read</type> </section> <section name="" displayNumber="b" style="" class="" > <content>乙方的义务：</content> <type>Read</type> <subSection> <section name="" displayNumber="" style="" class="" > <content>作为甲方全面履约的对价，乙方同意：</content> <type>Read</type> </section> <section name="" displayNumber="(2)" style="" class="" > <content>甲方能够享受一定的销售折扣（具体数额和支付条件由甲、乙双方另行约定）；</content> <type>Read</type> </section> </subSection> </section> <section name="" displayNumber="c" style="" class="" > <content>销售折扣的支付应以甲方在协议期限内遵守本协议之各项约定为前提。</content> <type>Read</type> </section> <section name="" displayNumber="d" style="" class="" > <content>d 各方对各项收付款应在其财务帐上真实明确记载。</content> <type>Read</type> </section> <section name="" displayNumber="5" style="font-weight: bold;" class="" > <content> 打假措施 </content> <type>Read</type> </section> <section name="" displayNumber="a" style="" class="" > <content> 为保护乙方的知识产权，防止制假者利用保乐力加产品的空瓶、瓶盖或瓶套等产品包装生产假冒伪劣产品,根据乙方要求，甲方应尽力将被要求回收的产品包装悉数退还乙方，由乙方统一回收和销毁。各产品具体的包装回收要求由乙方另行以函件形式通知甲方。为行文简便起见，非经特别说明下文所称“包装“指甲方从丙方进货的保乐力加产品的或乙方要求回收的保乐力加产品的包装。 </content> <type>Read</type> </section> <section name="" displayNumber="b" style="" class="" > <content> 规范的产品包装回收由乙方委托的人员或委托的第三方物流公司进行，并经乙方确认符合要求，具体回收频率和时间将根据本协议履行过程中甲方的实际的销量确定。 </content> <type>Read</type> </section> <section name="" displayNumber="c" style="" class="" > <content>包装回收率=包装回收的实际数/甲方从丙方的实际进货量。</content> <type>Read</type> </section> <section name="" displayNumber="d" style="" class="" > <content>乙方包装回收制度的目的是打击假冒伪劣产品，而非鼓励甲方通过从他处回收包装牟利。</content> <type>Read</type> </section> <section name="" displayNumber="e" style="" class="" > <content>虽然乙方不要求回收包装的所有组件，但甲方承诺不会将保乐力加回收产品包装后剩余的包装组件如空瓶、瓶塞、瓶口防回灌装置或外盒等其它产品包装直接或间接赠送、出售给制假者或者随意丢弃，或自行使用保乐力加产品包装的全部或部分制作伪劣的、假冒的保乐力加产品，否则乙方有权行使本协议第7条第j款下约定的权利。</content> <type>Read</type> </section> <section name="" displayNumber="6" style="font-weight: bold;" class="" > <content>保证</content> <type>Read</type> </section> <section name="" displayNumber="a" style="" class="" > <content>甲方承诺其为依法设立并有效存续的法人实体，在签订本协议时并确保在本协议有效期内拥有在其合法登记注册的经营场所内从事酒类销售及相关餐饮娱乐服务的合法有效的营业执照等所有必需的政府批准和许可。</content> <type>Read</type> </section> <section name="" displayNumber="b" style="" class="" > <content>甲方承诺只在乙方认可的销售渠道中购买保乐力加产品，拒绝销售任何伪劣产品、假货和走私货并且按乙方要求回收产品包装给乙方或其指定人员处理。</content> <type>Read</type> </section> <section name="" displayNumber="c" style="" class="" > <content>甲方同意，其所采购的保乐力加产品仅限于在自身经营的场所内销售，不得转售任何第三方，除非经乙方和丙方的事先书面同意</content> <type>Read</type> </section> <section name="" displayNumber="d" style="" class="" > <content>甲、丙两方须对其与乙方购销产品数量和价格保密，若因甲/丙方泄露相关信息而导致给乙方造成经济损失的，甲/丙方方须赔偿乙方由此产生的全部经济损失。</content> <type>Read</type> </section> <section name="" displayNumber="e" style="" class="" > <content>甲方声明并同意，未曾且将不会，在为乙方、丙方开展业务的过程中， </content> <type>Read</type> <subSection> <section name="" displayNumber="(1)" style="" class="" > <content>违反任何适用的反贿赂政策和反贿赂法；</content> <type>Read</type> </section> <section name="" displayNumber="(2)" style="" class="" > <content>提供、承诺给与、给予、同意接受或接受任何非法贿赂、回扣、回报、影响付款、返利或其他非法支付（包括疏通费）。</content> <type>Read</type> </section> </subSection> </section> <section name="" displayNumber="" style="" class="" > <content>应乙方的要求，甲方随时应将其向乙方提供服务的记录和会计账册提供，以供审查和/或审计使用。</content> <type>Read</type> </section> <section name="" displayNumber="" style="" class="" > <content>如果甲方或其关联方、雇员、集团公司、分包商、代理或代表违反陈述，且/或因涉及或从事任何可能构成反贿赂法下犯罪的行为被指控或被调查，乙方应有权单方面立即停止付款或终止本协议，或按照本协议的条款采取适当行为。</content> <type>Read</type> </section> <section name="" displayNumber="" style="" class="" > <content>为本条款之目的，“贿赂”是指某人向另一人提供、承诺提供或者给予某项利益，旨在使其（或另外之人）不适当地履行职责，或者将其用作对上述人员不当履行职责之酬劳。索取或者同意收受上述利益也属于贿赂行为。 通过第三方提供或者收受贿赂并不影响行为性质，仍应认定为贿赂行为。贿赂所涉及的利益可以采用财物或其他手段。财物是指现金和实物，包括现金和实物，任何包括假借促销费、宣传、赞助费、科研费、劳务费、咨询费、佣金等名义，或者以报销各种费用等方式，给付另一方的财物；任何其他手段包括提供国内外各种名义的旅游、考察等给付财物以外的其他利益的手段。</content> <type>Read</type> </section> <section name="" displayNumber="f" style="" class="" > <content>甲方同意向乙方提供保乐力加产品的销售信息（包括进货、存货、价格、销售情况、消费者反映等）以及与乙方业务相关的其它市场信息。甲方同意，乙方人员有权查看甲方账目和销售情况以核实甲方提供的销售信息，甲方工作人员应当予以积极配合，否则乙方有权决定甲方不予获得当期的品牌推广服务费以及A类销售折扣。 </content> <type>Read</type> </section> <section name="" displayNumber="g" style="" class="" > <content>甲方应遵守酒类销售相关法规并将对理性饮酒行动提供适当的支持，包括但不限于： </content> <type>Read</type> <subSection> <section name="" displayNumber="●" style="" class="" > <content>拒绝向疑似未成年人或孕妇出售酒精饮料；</content> <type>Read</type> </section> <section name="" displayNumber="●" style="" class="" > <content>在适当范围内努力避免向醉酒人员出售或推销酒精饮料；及</content> <type>Read</type> </section> <section name="" displayNumber="●" style="" class="" > <content>在适当范围内努力劝阻酒后驾车行为。</content> <type>Read</type> </section> </subSection> </section> <section name="" displayNumber="h" style="" class="" > <content>甲方保证，甲方及其关联方在任何时候均遵守所有适用的反洗钱法律法规，并且未曾涉及任何未决或潜在的反洗钱法律诉讼。如果有合理的理由怀疑甲方的任何交易涉及洗钱活动，甲方应当在知悉该等理由后三（3）个工作日以内，向乙方提交一份列明可疑理由的报告。甲方应当停止与涉及可疑交易的任何客户的所有活动，直至进一步的调查使得乙方断定客户并未涉及该等活动。甲方不得向其客户或任何第三方披露提交给乙方报告有关的任何信息，也不得披露正在、已经或将要执行的调查细节或事实。 </content> <type>Read</type> </section> <section name="" displayNumber="i" style="font-weight: bold;" class="" > <content>利益冲突</content> <type>Read</type> </section> <section name="" displayNumber="i" style="" class="" > <content>甲方在此承诺：</content> <type>Read</type> <subSection> <section name="" displayNumber="(1)" style="" class="" > <content>至本协议签署之日，在其最大的认知程度内保证没有导致利益冲突（定义如下）的情况出现，或保证已经就已存在的利益冲突向乙方批露了相关信息。</content> <type>Read</type> </section> <section name="" displayNumber="(2)" style="" class="" > <content>在本协议有效期内，如有任何确切或潜在的利益冲突情况发生或可能发生，自知道或应该知道之日起三日内，以书面形式通知乙方。乙方有权决定是否继续本协议。</content> <type>Read</type> </section> </subSection> </section> <section name="" displayNumber="" style="" class="" > <content>利益冲突的定义：当甲方或其雇员、代理或代表在履行本协议时，因自身利益或与乙方有竞争或有业务往来的任何组织存在义务、亲属关系或其他特殊利害关系，这些关系可能使得甲方在履行本协议时影响其的判断或评价，导致对乙方产生实际的或潜在的损害。</content> <type>Read</type> </section> <section name="" displayNumber="j" style="font-weight: bold;" class="" > <content>违反本条第a、b、c、d、e、f、g、h、i款的规定构成对本协议的根本违约，乙方有权停止支付本协议下的任何费用并有权随时终止本协议。</content> <type>Read</type> </section> <section name="" displayNumber="7" style="font-weight: bold;" class="" > <content>知识产权</content> <type>Read</type> </section> <section name="" displayNumber="a" style="" class="" > <content>甲方/丙方保证不论在本协议期间或终止后其不会生产或销售或恶意致使任何人或任何单位生产或销售假冒保乐力加产品或任何其名称、商标或包装、装潢与保乐力加产品相似并易引起混淆的产品。一旦发现存在侵犯或潜在侵犯乙方或其母公司或关联方的专利、商标、著作权、商业秘密以及其它知识产权权益的行为，甲方/丙方应立即通知乙方，并应与乙方通力合作制止此类侵权行为。</content> <type>Read</type> </section> <section name="" displayNumber="b" style="" class="" > <content>甲方/丙方不得变更、修改或移除任何保乐力加产品上的任何商标、专利声明、著作权声明及产品之上的任何其它标志，也不得在任何此类产品上附加任何其它的标志。甲方/丙方保证从本协议生效之日起，对产品的销售和使用均不会构成任何对乙方或其母公司或关联公司的专利、商标、著作权、商业秘密以及其它知识产权权益的侵犯。</content> <type>Read</type> </section> <section name="" displayNumber="c" style="" class="" > <content>甲方/丙方不得使用 "Pernod Ricard”，“保乐力加”或保乐力加任何产品的品牌（包括中英文） 作为其名称、简称的一部分。未经乙方明确的书面同意，亦不得用任何方式使用乙方或其母公司或关联公司的字号、任何标志、图形、文字、代号。 在任何情况下，甲方/丙方也不得使用乙方、其母公司及关联方的企业名称作为其企业名称。</content> <type>Read</type> </section> <section name="" displayNumber="8" style="font-weight: bold;" class="" > <content>违约责任</content> <type>Read</type> </section> <section name="" displayNumber="" style="" class="" > <content>本协议存续期间，如果一方未能履行本协议规定的义务和保证，除本协议明确约定的救济手段以外， 违约方还应向其它协议方承担损失赔偿责任。</content> <type>Read</type> </section> <section name="" displayNumber="9" style="font-weight: bold;" class="" > <content>协议的延长和终止 </content> <type>Read</type> </section> <section name="" displayNumber="a" style="" class="" > <content>如任何一方在协议期内严违约（如违反第7条和第8条）、有欺诈性行为、遇政府法令禁止经营活动或被申请破产、清算或解散的，协议其它方有权向该方发出书面要求终止协议，本协议即随即终止。丙方具有上述情况的，乙方有权通过一级分销商立即终止丙方二级分销商的资格，同时通知甲方与新的二级分销商签订本协议，甲/丙方对上述安排应积极配合。</content> <type>Read</type> </section> <section name="" displayNumber="b" style="" class="" > <content>除上述情况以外，如果甲/丙方未能履行本协议规定的其它义务和保证，乙方将给予违约方十五（15）个工作日的改正期，若期满后违约方行为未能得到改善和纠正，则视为严重违约，乙方有权立即终止本协议。</content> <type>Read</type> </section> <section name="" displayNumber="c" style="" class="" > <content>协议的终止不影响无过错方向违约方主张经济上的违约或损害赔偿的权利以及协议中有关保密义务和知识产权义务的继续。</content> <type>Read</type> </section> <section name="" displayNumber="10" style="font-weight: bold;" class="" > <content>其它</content> <type>Read</type> </section> <section name="" displayNumber="a" style="" class="" > <content>本协议期满后，在同等条件下，乙方有优先续约权。</content> <type>Read</type> </section> <section name="" displayNumber="b" style="" class="" > <content>在任何情况下，未经一方允许，协议其它方不得将本协议的签署、本协议的内容及在本协议履行过程中获悉的该方的机密信息（包括该方或其关联公司的任何非公开资料包括商业策略，客户信息，批发商信息，活动计划，销量，价格、生意模式及商业秘密等）泄漏给任何第三方或本方的无关人员或用于本协议以外的目的。</content> <type>Read</type> </section> <section name="" displayNumber="c" style="" class="" > <content>除非本协议另有约定，否则任何一方在征得另二方事先书面同意之前均不得转让本协议或其相关权益。但乙方有权在书面通知甲方和丙方后，将本协议或其相关权益转让给乙方的关联方。</content> <type>Read</type> </section> <section name="" displayNumber="d" style="" class="" > <content>若本协议规定一方不得作出某行为，则应当解释为该一方均不得以任何直接或间接的方式或通过任何第三方作出该行为。</content> <type>Read</type> </section> <section name="" displayNumber="e" style="" class="" > <content>凡因本协议引起的或与本协议有关的任何争议，应先协商解决；协商不成的，任何一方均有权向上海市黄浦区人民法院提起诉讼。</content> <type>Read</type> </section> <section name="" displayNumber="f" style="" class="" > <content>本协议一式贰份，双方各持有一份。本协议自双方授权代表签字或盖章后生效。其它未尽事宜，由双方协商解决。</content> <type>Read</type> </section> </body> <BodySignature> <section name="BodySignature1" displayNumber="" style="font-weight: bold;font-size: 16px;" class="" > <content>甲方： {InputWholesaler}// 乙方：保乐力加（中国）贸易有限公司</content> <type>Read</type> </section> <section name="" displayNumber="" style="" class="" > <content></content> <type>Read</type> </section> <section name="ChopSignature" displayNumber="" style="" class="" description="Do Not change the name" > <content>签字盖章： // 签字盖章： </content> <type>Read</type> </section> <section name="" displayNumber="" style="" class="" > <content></content> <type>Read</type> </section> <section name="" displayNumber="" style="" class="" > <content>日 期： // 日 期： </content> <type>Read</type> </section> <section name="" displayNumber="" style="" class="" > <content></content> <type>Read</type> </section> </BodySignature> <appendix> <section name="Appendix 1" displayNumber="" style="font-size: 18px;" class="" > <content>附件一</content> <type>Read</type> </section> <section name="Brand promotion plan and target of sales" displayNumber="" style="text-align: center;font-size: 16px;" class="" > <content>销售目标</content> <type>Read</type> </section> <section name="FixCostTableHeader" displayNumber="1" style="" class="AppendixLineHeader" description="Do Not change the name" > <content><b><u>销量目标和销售折扣 </u> </b></content> <type>Read</type> </section> <section name="" displayNumber="" style="" class="" description="Do Not change the name" > <content>为进一步推广保乐力加产品，乙方对其产品的经销企业实行销售折扣的政策。在符合约定前提条件的情况下，甲方可享受一定的销售折扣。具体要求如下：</content> <type>Read</type> </section> <section name="" displayNumber="" style="" class="" description="Do Not change the name" > <content>1.1 甲方拓展门店情况：</content> <type>Read</type> </section> <section name="CoveroutletTable" displayNumber="" style="" class="AppendixLineHeader ReplaceItem" > <content>{CoveredOutletTable} </content> <type>Read</type> </section> <section name="" displayNumber="" style="" class="" > <content>1.2 销售折扣</content> <type>Read</type> </section> <section name="SalesDiscount" displayNumber="" style="" class="" > <content></content> <type>Read</type> <subSection> <section name="BRSFTable_Incentive" displayNumber="" style="" class="" description="Do Not change the name" > <content>产品名称和规格// 单瓶销售折扣(元/瓶)</content> <type>Read</type> <subSection> <section name="BRSFTableB" displayNumber="" style="" class="2colspan2 2InputText" description="Do Not change the name" > <content>备注//以上产品皆为NCO产品，不收取回瓶。 </content> <type>Read</type> </section> </subSection> </section> </subSection> </section> <section name="Payment Conditions" displayNumber="2" style="" class="AppendixLineHeader" > <content>销售折扣的支付条件</content> <type>Read</type> <subSection> <section name="" displayNumber="a)" style="" class="" > <content>甲方完成约定条件是享受销售折扣的前提条件。 </content> <type>Read</type> </section> <section name="" displayNumber="b)" style="" class="" > <content> 甲方不回收包装，包含瓶盖上的二维码。 </content> <type>Read</type> </section> <section name="" displayNumber="c)" style="" class="" description=" " > <content>甲方按照实际进货量给予销售折扣。 </content> <type>Read</type> </section> <section name="" displayNumber="d)" style="" class="" description="Please Input Name Field" > <content> 甲方同意上述各项销售折扣可以从上一级经销商进货折让方式或产品实物的形式支付。 </content> <type>Read</type> </section> <section name="" displayNumber="e)" style="" class="" > <content>甲方始终遵守以下第3条的各项承诺。 </content> <type>Read</type> </section> </subSection> </section> <section name="Party A undertakes" displayNumber="3" style="font-weight: bold;" class="AppendixLineHeader" > <content>甲方承诺</content> <type>Read</type> <subSection> <section name="" displayNumber="a)" style="" class="" > <content>将在法律允许的范围内在甲方场地尽其最大商业努力推销乙方产品。 </content> <type>Read</type> </section> <section name="" displayNumber="b)" style="" class="" > <content>尽最大努力促使门店场地内用于调制杯饮类的副酒尽量使用乙方品类中相应品种的产品。 </content> <type>Read</type> </section> <section name="" displayNumber="c)" style="" class="" > <content>在门店场地重点展示乙方产品及其品牌。 </content> <type>Read</type> </section> <section name="" displayNumber="d)" style="" class="" > <content>应乙方不时之请求，促使门店为乙方的品牌在场内举行促销活动提供场地和服务 </content> <type>Read</type> </section> <section name="Editable12" displayNumber="e)" style="" class="" > <content>甲方承诺新开拓店点不少于XXX家，并保证协议期内每月新开店点不少于XXX家。 </content> <type>Editable</type> </section> </subSection> </section> </appendix> <AppendixSignature> </AppendixSignature> </source>';
            String XMLTestString6='<source> <header> <section name="Sales and Branding Promotion Agreement" displayNumber="" style="text-align: center;font-size: 20px;" class="" > <content>销售和品牌推广协议</content> <type>Read</type> </section> <section name="drink on the premises" displayNumber="" style="text-align: center;font-size: 18px;" class="" > <content>堂饮</content> <type>Read</type> </section> <section name="Party A" displayNumber="" style="" class="" > <content>甲方：{1} </content> <type>Read</type> </section> <section name="Party C" displayNumber="" style="" class="" > <content>{1} </content> <type>Read</type> </section>     <section name="Party B" displayNumber="" style="" class="" > <content>丙方：保乐力加（中国）贸易有限公司 </content> <type>Read</type> </section> </header> <body> <section name="Header with original contract" displayNumber="" style="font-weight: bold;" class="" > <content>鉴于：</content> <type>Read</type> </section> <section name="Terms of this Agreement" displayNumber="" style="" class="" > <content>本协议期限自{1}年{2}月{3}日 至{4}年{5}月{6}日。</content> <type>Read</type> </section> <section name="Products" displayNumber="2" style="font-weight: bold;" class="" > <content>产品</content> <type>Read</type> </section> <section name="All parties sell Products" displayNumber="" style="" class="" > <content>三方同意在甲方店内销售保乐力加产品，产品具体名称、规格等见产品清单 （下称“保乐力加产品”或“产品”）。</content> <type>Read</type> </section> <section name="All parties sell Products" displayNumber="3" style="font-weight: bold;" class="" > <content>订货和交付</content> <type>Read</type> </section> <section name="All parties sell Products" displayNumber="a" style="" class="" > <content>甲方应通过订单的形式向乙方订购产品，该订单中应明确订购产品的数量和要求的交货日期。产品的所有订单均须获得乙方的批准。乙方可对所订购产品的数量根据现有库存进行调整，同时不应就未经其接受的购买订单向该客户承担责任。 </content> <type>Read</type> </section> <section name="All parties sell Products" displayNumber="b" style="" class="" > <content>乙方应在订单约定的时间期限内，将货物交付到指定地点和接收人。订单发出后，未经乙方同意，不得对乙方已经收到的任何订单做出修改。</content> <type>Read</type> </section> <section name="All parties sell Products" displayNumber="c" style="" class="" > <content>甲方订购的所有产品均根据标准商业惯例进行包装以便运输和储存。订购产品的灭失和损害风险在指定的交货地点向甲方交付该等订购产品后转移给甲方。如有承运人的，则订购产品的灭失和损害风险自交由第一承运人起转移给甲方。甲方应在收到货物后对货物进行检验。如果货物有破损或包装货物发生短缺，则甲方应立即通知乙方，且在运输公司代表在场的情况下，甲方可拒收破损的货物。破损或短缺的问题应通过召回或调换的方式予以解决。</content> <type>Read</type> </section> <section name="Conditions for Payment" displayNumber="4" style="font-weight: bold;" class="" > <content>货款的付款条件</content> <type>Read</type> </section> <section name="The payment relating " displayNumber="" style="" class="" > <content>本协议项下有关订购产品货款的支付，甲方应以人民币通过银行转账或约定的其他付款方式支付给乙方。 </content> <type>Read</type> </section> <section name="Promotion, sales target and sales discount" displayNumber="5" style="font-weight: bold;" class="" > <content>品牌推广服务、销量目标和销售折扣</content> <type>Read</type> </section> <section name="The payment relating " displayNumber="a" style="" class="" > <content>甲方的承诺和责任。甲方同意以提高保乐力加产品及品牌的知名度和形象为目的在其店内提供如下品牌推广服务，并尽其最大努力完成约定的销量目标：</content> <type>Read</type> <subSection> <section name="" displayNumber="(1)" style="" class="" > <content>在店内外提供如下品牌的形象宣传服务(具体计划和安排，由双方另行协商确定）</content> <type>Read</type> </section> <section name=" " displayNumber="" style="" class="" > <content>• 陈列放有保乐力加产品广告的灯箱；</content> <type>Read</type> </section> <section name=" " displayNumber="" style="" class="" > <content>• 在店内电子LED上（如有）播放保乐力加产品信息或广告；</content> <type>Read</type> </section> <section name=" " displayNumber="" style="" class="" > <content>• 店内装饰装修上采用与保乐力加产品品牌相关的元素和装饰；</content> <type>Read</type> </section> <section name="" displayNumber="" style="" class="" > <content>• 在店内显著位置放置保乐力加产品陈列柜或在店内陈列柜及显著位置陈列保<br/>           乐力加产品；</content> <type>Read</type> </section> <section name="" displayNumber="" style="" class="" > <content>• 在店内派送保乐力加产品的宣传品与物料；</content> <type>Read</type> </section> <section name="" displayNumber="" style="" class="" > <content>• 保乐力加产品信息出现在酒水单前列；</content> <type>Read</type> </section> <section name="" displayNumber="" style="" class="" > <content>• 在店内桌上放置含有保乐力加产品信息的台卡等。</content> <type>Read</type> </section> <section name="" displayNumber="(2)" style="" class="" > <content>授予保乐力加产品在店内的促销权，并配合保乐力加品牌促销活动提供如下服务:</content> <type>Read</type> </section> <section name="" displayNumber="" style="" class="" > <content>• 为保乐力加品牌促销服务提供场地;</content> <type>Read</type> </section> <section name="" displayNumber="" style="" class="" > <content>• 同意向店内派驻促销代表以宣传、推广保乐力加产品。该促销代表的数<br/>            量和来源由各方协商确定，促销员应遵守店内的规章制度；</content> <type>Read</type> </section> <section name="" displayNumber="" style="" class="" > <content>• 同意配合保乐力加品牌市场营销计划在店内开展保乐力加产品的促销<br/>            活动（具体促销活动计划和安排，由各方另行协商确定）。</content> <type>Read</type> </section> <section name="" displayNumber="(3)" style="" class="" > <content>同意并配合在各类节庆及其他时间开展各种保乐力加品牌活动，包括各种派对、演出、晚宴或品酒会及品牌展示和促销活动（由各方根据其具体的市场营销计划最终确定）等。</content> <type>Read</type> </section> <section name="" displayNumber="(4)" style="" class="" > <content>尽最大努力完成销量目标。</content> <type>Read</type> </section> </subSection> </section> <section name="" displayNumber="b" style="" class="" > <content>乙方的义务。</content> <type>Read</type> <subSection> <section name="" displayNumber="(1)" style="" class="" > <content>乙方致力于在甲方渠道提高保乐力加产品及品牌的知名度和形象，乙方应向甲方支付一定服务费用（具体金额和付款条件根据最终确定后的形象宣传活动细节、促销活动方案、甲方品牌活动计划另行约定）在符合约定条件的前提下享受的相应的销售折扣，甲乙双方必须将折扣如实入账；</content> <type>Read</type> </section>         <section name="" displayNumber="(2)" style="" class="" >           <content>本条所述品牌推广服务费和销售折扣由乙方支付给甲方。</content>           <type>Read</type>         </section> </subSection> </section>     <section name="" displayNumber="c" style="" class="" > <content>丙方的权利和义务。</content> <type>Read</type> <subSection> <section name="" displayNumber="(1)" style="" class="" > <content>丙方同意：</content> <type>Read</type> </section> <section name="" displayNumber="" style="" class="" > <content>• 及时提供和品牌形象宣传有关的宣传品、酒具、物料等材料。</content> <type>Read</type> </section> <section name="" displayNumber="" style="" class="" > <content>• 根据甲方和乙方需要向其相关人员提供一定酒类培训，具体培训的次数、地点和内容由各方协商确定。</content> <type>Read</type> </section> </subSection> </section>     <section name="" displayNumber="d" style="" class="" > <content>因品牌推广计划尚未完全确定，三方应在具体履行协议时友好协商并就甲方提供的上述服务项目进行调整，包括增加、取消或变更部分服务项目以及确定目标。</content> <type>Read</type> </section>     <section name="" displayNumber="" style="" class="" > <content>服务费用及销售折扣的支付应以甲方在协议期限内遵守本协议之约定为前提。在乙方向甲方支付任何费用之前，甲方应开具符合中国法律、法规规定及中国税务部门要求的、由中国税务部门监制的记载相应款项的发票。各方对上述各项收付款应在其财务帐上真实明确记载。</content> <type>Read</type> </section> <section name="" displayNumber="6" style="font-weight: bold;" class="" > <content> 打假措施 </content> <type>Read</type> </section> <section name="" displayNumber="a" style="" class="" > <content> 为保护保乐力加的知识产权，防止制假者利用保乐力加产品的空瓶、瓶盖或瓶套等产品包装生产假冒伪劣产品,甲方应尽力将被要求回收的产品包装悉数退还，统一回收和销毁。各产品具体的包装回收要求由丙方另行以函件形式通知甲方。为行文简便起见，非经特别说明下文所称“包装“指甲方从乙方进货的保乐力加产品的或丙方要求回收的保乐力加产品的包装。 </content> <type>Read</type> </section> <section name="" displayNumber="b" style="" class="" > <content> 规范的产品包装回收由丙委托的人员或委托的第三方物流公司进行，并经丙方确认符合要求，具体回收频率和时间将根据本协议履行过程中甲方的实际的销量确定。 </content> <type>Read</type> </section> <section name="" displayNumber="c" style="" class="" > <content>本条所述包装回收制度的目的是打击假冒伪劣产品，而非鼓励甲方通过从他处回收包装牟利。</content> <type>Read</type> </section> <section name="" displayNumber="d" style="" class="" > <content>虽然不要求回收包装的所有组件，但甲方承诺不会将保乐力加回收产品包装后剩余的包装组件如空瓶、瓶塞、瓶口防回灌装置或外盒等其它产品包装直接或间接赠送、出售给制假者或者随意丢弃，或自行使用保乐力加产品包装的全部或部分制作伪劣的、假冒的保乐力加产品，否则丙方有权行使本协议第7条第j款下约定的权利。</content> <type>Read</type> </section> <section name="" displayNumber="7" style="font-weight: bold;" class="" > <content>保证</content> <type>Read</type> </section> <section name="" displayNumber="a" style="" class="" > <content>甲方承诺其为依法设立并有效存续的法人实体，在签订本协议时并确保在本协议有效期内拥有在其合法登记注册的经营场所内从事酒类销售及相关餐饮娱乐服务的合法有效的营业执照。</content> <type>Read</type> </section> <section name="" displayNumber="b" style="" class="" > <content>甲方承诺只在丙方认可的销售渠道中购买保乐力加产品，拒绝销售任何伪劣产品、假货和走私货并且按丙方要求回收产品包装交由丙方或其指定人员处理。</content> <type>Read</type> </section> <section name="" displayNumber="c" style="" class="" > <content>甲方同意，其所采购的保乐力加产品仅限于在自身经营的场所内销售，不得转售任何第三方，除非经乙方和丙方的事先书面同意</content> <type>Read</type> </section> <section name="" displayNumber="d" style="" class="" > <content>甲、乙两方须对其与丙方购销产品数量和价格保密，若因甲/乙方泄露相关信息而导致给丙方造成经济损失的，甲/乙方须赔偿丙方由此产生的全部经济损失。</content> <type>Read</type> </section> <section name="" displayNumber="e" style="" class="" > <content>甲方声明并同意，未曾且将不会，在为乙方、丙方开展业务的过程中， </content> <type>Read</type> <subSection> <section name="" displayNumber="(1)" style="" class="" > <content>违反任何适用的反贿赂政策和反贿赂法；</content> <type>Read</type> </section> <section name="" displayNumber="(2)" style="" class="" > <content>提供、承诺给与、给予、同意接受或接受任何非法贿赂、回扣、回报、影响付款、返利或其他非法支付（包括疏通费）。</content> <type>Read</type> </section> </subSection> </section> <section name="" displayNumber="" style="" class="" > <content>为此目的，应丙方的要求，甲方随时应将其向丙方提供服务的记录和会计账册提供，以供审查和/或审计使用。</content> <type>Read</type> </section> <section name="" displayNumber="" style="" class="" > <content>如果甲方或其关联方、雇员、集团公司、分包商、代理或代表违反陈述，且/或因涉及或从事任何可能构成反贿赂法下犯罪的行为被指控或被调查，丙方应有权单方面立即停止付款或终止本协议，或按照本协议的条款采取适当行为。</content> <type>Read</type> </section> <section name="" displayNumber="" style="" class="" > <content>为本条款之目的，“贿赂”是指某人向另一人提供、承诺提供或者给予某项利益，旨在使其（或另外之人）不适当地履行职责，或者将其用作对上述人员不当履行职责之酬劳。索取或者同意收受上述利益也属于贿赂行为。 通过第三方提供或者收受贿赂并不影响行为性质，仍应认定为贿赂行为。贿赂所涉及的利益可以采用财物或其他手段。财物是指现金和实物，包括现金和实物，任何包括假借促销费、宣传、赞助费、科研费、劳务费、咨询费、佣金等名义，或者以报销各种费用等方式，给付另一方的财物；任何其他手段包括提供国内外各种名义的旅游、考察等给付财物以外的其他利益的手段。 </content> <type>Read</type> </section> <section name="" displayNumber="f" style="" class="" > <content>各方知晓，销售和市场信息是丙方赖以作出经营决策，优化产品结构，施行管理方式的重要依据，为丙方更好地了解市场信息，更及时和准确地制定经营决策，更有效地针对市场情况管理销售策略的目的，甲方同意向丙方提供保乐力加产品的销售信息（包括进货、存货、销售情况、消费者反映等）以及与丙方业务相关的其它市场信息。甲方同意，丙方人员有权查看甲方账目和销售情况以核实甲方提供的销售信息，甲方工作人员应当予以积极配合。 </content> <type>Read</type> </section> <section name="" displayNumber="g" style="" class="" > <content>甲方应遵守酒类销售相关法规并将对理性饮酒行动提供适当的支持，包括但不限于： </content> <type>Read</type>      <subSection> <section name="" displayNumber="●" style="" class="" > <content>拒绝向疑似未成年人或孕妇出售酒精饮料；</content> <type>Read</type> </section> <section name="" displayNumber="●" style="" class="" > <content>在适当范围内努力避免向醉酒人员出售或推销酒精饮料；及</content> <type>Read</type> </section> <section name="" displayNumber="●" style="" class="" > <content>在适当范围内努力劝阻酒后驾车行为。</content> <type>Read</type> </section> </subSection> </section>   <section name="" displayNumber="h" style="" class="" > <content>甲方保证，甲方及其关联方在任何时候均遵守所有适用的反洗钱法律法规，并且未曾涉及任何未决或潜在的反洗钱法律诉讼。如果有合理的理由怀疑甲方的任何交易涉及洗钱活动，甲方应当在知悉该等理由后三（3）个工作日以内，向丙方提交一份列明可疑理由的报告。甲方应当停止与涉及可疑交易的任何客户的所有活动，直至进一步的调查使得丙方断定客户并未涉及该等活动。甲方不得向其客户或任何第三方披露提交给丙方报告有关的任何信息，也不得披露正在、已经或将要执行的调查细节或事实。 </content> <type>Read</type> </section>   <section name="" displayNumber="i" style="" class="" > <content>利益冲突</content> <type>Read</type> </section>     <section name="" displayNumber="" style="" class="" > <content>甲方在此承诺：</content> <type>Read</type>     <subSection> <section name="" displayNumber="(1)" style="" class="" > <content>至本协议签署之日，在其最大的认知程度内保证没有导致利益冲突（定义如下）的情况出现，或保证已经就已存在的利益冲突向丙方批露了相关信息。</content> <type>Read</type> </section> <section name="" displayNumber="(2)" style="" class="" > <content>在本协议有效期内，如有任何确切或潜在的利益冲突情况发生或可能发生，自知道或应该知道之日起三日内，以书面形式通知丙方。丙方有权决定是否继续本协议。</content> <type>Read</type> </section> </subSection> </section>         <section name="" displayNumber="" style="" class="" > <content>利益冲突的定义：当甲方或其雇员、代理或代表在履行本协议时，因自身利益或与丙方有竞争或有业务往来的任何组织存在义务、亲属关系或其他特殊利害关系，这些关系可能使得甲方在履行本协议时影响其的判断或评价，导致对丙方产生实际的或潜在的损害。</content> <type>Read</type> </section>   <section name="" displayNumber="j" style="font-weight: bold;" class="" > <content>违反本条第a、b、c、d、e、f、g、h、i款的规定构成对本协议的根本违约，丙方有权停止履行本协议下的任何义务并有权随时终止本协议。</content> <type>Read</type> </section>     <section name="" displayNumber="8" style="font-weight: bold;" class="" > <content>知识产权</content> <type>Read</type> </section>   <section name="" displayNumber="a" style="" class="" > <content>甲方/乙方保证不论在本协议期间或终止后其不会生产或销售或恶意致使任何人或任何单位生产或销售假冒保乐力加产品或任何其名称、商标或包装、装潢与保乐力加产品相似并易引起混淆的产品。一旦发现存在侵犯或潜在侵犯丙方其母公司或关联方的专利、商标、著作权、商业秘密以及其它知识产权权益的行为，甲方/乙方应立即通知丙方，并应与丙方通力合作制止此类侵权行为。 </content> <type>Read</type> </section>   <section name="" displayNumber="b" style="" class="" >     <content>甲方/乙方不得变更、修改或移除任何保乐力加产品上的任何商标、专利声明、著作权声明及产品之上的任何其它标志，也不得在任何此类产品上附加任何其它的标志。甲方/乙方保证从本协议生效之日起，对产品的销售和使用均不会构成任何对丙方或其母公司或关联公司的专利、商标、著作权、商业秘密以及其它知识产权权益的侵犯。</content>     <type>Read</type>   </section>   <section name="" displayNumber="c" style="" class="" >     <content>甲方/乙方不得使用"Pernod Ricard”，“保乐力加”或保乐力加任何产品的品牌（包括中英文） 作为其名称、简称的一部分。未经丙方明确的书面同意，亦不得用任何方式使用丙方或其母公司或关联公司的字号、任何标志、图形、文字、代号。 在任何情况下，甲方/乙方也不得使用丙方、其母公司及关联方的企业名称作为其企业名称。</content>     <type>Read</type>   </section>   <section name="" displayNumber="9" style="font-weight: bold;" class="" >     <content>违约责任</content>     <type>Read</type>   </section>     <section name="" displayNumber="" style="" class="" >     <content>本协议存续期间，如果一方未能履行本协议规定的义务和保证，除本协议明确约定的救济手段以外， 违约方还应向其它协议方承担损失赔偿责任。</content>     <type>Read</type>   </section>   <section name="" displayNumber="10" style="font-weight: bold;" class="" >     <content>协议的延长和终止 </content>     <type>Read</type>   </section>   <section name="" displayNumber="a" style="" class="" >     <content>如任何一方在协议期内严违约（如违反第7条和第8条）、有欺诈性行为、遇政府法令禁止经营活动或被申请破产、清算或解散的，协议其它方有权向该方发出书面要求终止协议，本协议即随即终止。乙方具有上述情况的，丙方有权通过一级分销商立即终止乙方二级分销商的资格，同时通知甲方与新的二级分销商签订本协议，甲/乙方对上述安排应积极配合。</content>     <type>Read</type>   </section>   <section name="" displayNumber="b" style="" class="" >     <content>除上述情况以外，如果甲/乙方未能履行本协议规定的其它义务和保证，丙方将给予违约方十五（15）个工作日的改正期，若期满后违约方行为未能得到改善和纠正，则视为严重违约，丙方有权立即终止本协议。</content>     <type>Read</type>   </section>     <section name="" displayNumber="c" style="" class="" >     <content>协议的终止不影响无过错方向违约方主张经济上的违约或损害赔偿的权利以及协议中有关保密义务和知识产权义务的继续。</content>     <type>Read</type>   </section>     <section name="" displayNumber="11" style="font-weight: bold;" class="" >     <content>其它</content>     <type>Read</type>   </section>   <section name="" displayNumber="a" style="" class="" >     <content>本协议期满后，在同等条件下，丙方有优先续约权。</content>     <type>Read</type>   </section>     <section name="" displayNumber="b" style="" class="" >     <content>在任何情况下，未经一方允许，协议其它方不得将本协议的签署、本协议的内容及在本协议履行过程中获悉的该方的机密信息（包括该方或其关联公司的任何非公开资料包括商业策略，客户信息，批发商信息，活动计划，销量，价格、生意模式及商业秘密等）泄漏给任何第三方或本方的无关人员或用于本协议以外的目的。</content>     <type>Read</type>   </section>     <section name="" displayNumber="c" style="" class="" >     <content>除非本协议另有约定，否则任何一方在征得另二方事先书面同意之前均不得转让本协议或其相关权益。但丙方有权在书面通知甲方和乙方后，将本协议或其相关权益转让给丙方的关联方。</content>     <type>Read</type>   </section>     <section name="" displayNumber="d" style="" class="" >     <content>若本协议规定一方不得作出某行为，则应当解释为该一方均不得以任何直接或间接的方式或通过任何第三方作出该行为。</content>     <type>Read</type>   </section>     <section name="" displayNumber="e" style="" class="" >     <content>凡因本协议引起的或与本协议有关的任何争议，应先协商解决；协商不成的，任何一方均有权向上海市黄浦区人民法院提起诉讼。</content>     <type>Read</type>   </section>   <section name="" displayNumber="f" style="" class="" >     <content>本协议一式三份，三方各持有一份。本协议自双方授权代表签字或盖章后生效。其它未尽事宜，由各方协商解决。</content>     <type>Read</type>   </section>   </body> <BodySignature> <section name="BodySignature1" displayNumber="" style="font-weight: bold;font-size: 16px;" class="" > <content>甲方： {1}// 乙方： {2}</content> <type>Read</type> </section> <section name="" displayNumber="" style="" class="" > <content></content> <type>Read</type> </section> <section name="ChopSignature" displayNumber="" style="" class="" description="Do Not change the name" > <content>签字盖章： // 签字盖章： </content> <type>Read</type> </section> <section name="" displayNumber="" style="" class="" > <content></content> <type>Read</type> </section> <section name="" displayNumber="" style="" class="" > <content>日 期： // 日 期： </content> <type>Read</type> </section> <section name="" displayNumber="" style="" class="" > <content></content> <type>Read</type> </section> <section name="BodySignature2" displayNumber="" style="font-weight: bold;font-size: 16px;" class="" > <content>丙 方：保乐力加（中国）贸易有限公司// </content> <type>Read</type> </section> <section name="" displayNumber="" style="" class="" > <content></content> <type>Read</type> </section> <section name="" displayNumber="" style="" class="" > <content>签字盖章： // </content> <type>Read</type> </section> <section name="" displayNumber="" style="" class="" > <content></content> <type>Read</type> </section> <section name="" displayNumber="" style="" class="" > <content>日 期： // </content> <type>Read</type> </section> </BodySignature> <appendix> <section name="Brand promotion plan and target of sales" displayNumber="" style="text-align: center;font-size: 16px;" class="" > <content>品牌推广计划和销售目标</content> <type>Read</type> </section>     <section name="Party A" displayNumber="" style="" class="" > <content>甲方：{1} </content> <type>Read</type> </section> <section name="Party C" displayNumber="" style="" class="" > <content>{1} </content> <type>Read</type> </section>     <section name="Header with original contract" displayNumber="" style="font-weight: bold;" class="" > <content>鉴于：</content> <type>Read</type> </section> <section name="WhereasA" displayNumber="A" style="" class="" > <title></title> <content>甲方为堂饮服务类企业；乙方为保乐力加产品在甲方所在城市的批发商及甲方的供货商。</content> <type>Read</type> </section> <section name="WhereasB" displayNumber="B" style="" class="" > <content>乙方作为甲方的直接供货商， 愿意与甲方合作，由甲方配合其市场营销活动、提高保乐力加产品知名度、打击假冒伪劣等提供有关品牌推广服务。</content> <type>Read</type> </section> <section name="WhereasC" displayNumber="C" style="" class="" > <content>同时，为促进保乐力加产品在甲方渠道的销售， 乙方将在甲方渠道开展以打折让利等形式进行促销。</content> <type>Read</type> </section> <section name="Agreement" displayNumber="" style="" class="" > <content>现经友好协商，双方达成协议如下：</content> <type>Read</type> </section> <section name="TermsofthisAgreement" displayNumber="1" style="" class="AppendixLineHeader" > <content><b><u>协议期限:</u> </b></content> <type>Read</type> </section> <section name="Terms of this Agreement2" displayNumber="" style="" class="" > <content>本协议期限自{1}年{2}月{3}日 至{4}年{5}月{6}日。</content> <type>Read</type> </section> <section name="" displayNumber="2" style="" class="AppendixLineHeader" > <content><b><u>品牌推广服务及费用明细 </u> </b></content> <type>Read</type> </section> <section name="" displayNumber="" style="" class="" > <content>因品牌推广计划在签订协议时尚未完全确定，乙方有权在具体履行协议时根据其最终确定的品牌推广计划对甲方提供的下述服务项目进行调整，包括增加、取消或变更部分服务项目等。</content> <type>Read</type> </section> <section name="FixCostTable" displayNumber="" style="" class="" description="Do Not change the name" > <content></content> <type>Read</type>       <subSection>         <section name="" displayNumber="1" style="" class="" >           <content> 形象推广服务//形象推广费用//金额//备注</content>           <type>Read</type>         </section>         <section name="" displayNumber="2" style="" class="" description="Do Not change the {FixedCostACCode} {InputAmount} " >           <content> {FixedCostACCode}// a. 形象活动<br/> 1)灯箱、LED、电子屏幕、其它广告形式<br/> 2)产品陈列、店内外装饰、酒水单、台卡等附加广告宣传<br/> 3)派送宣传物料、广告礼品等<br/> b. 店方活动<br/> 店方节庆活动中甲方产品或宣传材料、广告等的陈列、展示、促销等。（具体活动计划由各方另行确定）<br/> c. 其他 //1)灯箱、LED等广告租赁费用<br/> 2)陈列广告费// {InputAmount} //a.  形象活动<br/> 该项费用在本协议签订后【 】个月后支付，甲方需要提供相应的形象宣传照片等支持文件<br/> b. 店方活动<br/> 该项形式在双方确定具体活动计划时确定具体支付时间和方式<br/> c. 其他<br/> 该项费用在本协议签订后【 】天内支付</content>           <type>Read</type>         </section>         <section name="" displayNumber="4" style="" class="" description="Do Not change the {FixedCostACCode} {InputAmount}" >           <content> {FixedCostACCode}// 同意并协助在店内举行品牌活动，如派对活动等 // N/A // {InputAmount} //该项费用在双方确定具体活动计划时确定具体支付时间和方式</content>           <type>Read</type>         </section>         <section name="" displayNumber="5" style="" class="" >           <content> <br/> // <br/> // 总计： // {FXTotalAmount} //<br/></content>           <type>Read</type>         </section>                 <section name="FixCostTable_InputText" displayNumber="6" style="" class="colspan4" >           <content> 备注：// {InputText}根据甲方提供服务实际情况，乙方有权调整服务费用支付比例。</content>           <type>Read</type>         </section>       </subSection> </section>     <section name="" displayNumber="" style="" class="" >       <content> 备注： 根据甲方提供服务实际情况，乙方有权调整服务费用支付比例。 </content>       <type>Read</type>     </section> <section name="" displayNumber="3" style="" class="AppendixLineHeader" > <content><b><u>销量目标和销售折扣</u> </b></content> <type>Read</type> </section> <section name="SalesDiscount" displayNumber="" style="" class="" > <content>为进一步推广保乐力加产品，乙方对门店实行销售折扣的政策。在符合约定前提条件的情况下，甲方可享受一定的销售折扣。具体要求如下：</content> <type>Read</type>       <subSection> <section name="Sales_Discount_of_A_Class" displayNumber="2.1" style="" class="" > <content>A类销售折扣: </content> <type>Read</type> </section>          <section name="BRSFTable" displayNumber="" style="" class="" description="Do Not change the name" > <content>产品名称和规格// 单瓶销售折扣 //单瓶月销量<br/>目标（瓶）//合同总销量<br/>目标（瓶）//合同预估<br/>总销量折扣</content> <type>Read</type> </section> <section name="Non_standard_Convert" displayNumber="" style="" class="" > <content>非标准规格折算：[&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;] </content> <type>Read</type> </section>         <section name="Sales_Discount_of_A_Class" displayNumber="" style="" class="" > <content>a 季度A类销售折扣计算方式</content> <type>Read</type> </section>         <section name="" displayNumber="" style="" class="" > <content>季度A类销售折扣=单瓶销售折扣X确认为甲方从乙方进货的保乐力加产品数量（单位：瓶）×KPI达标率，于下一季度内结算。其中KPI指标包含：消费者口味、偏好等市场数据搜集情况，对消费者的服务质量，包装回收率、市场满意度情况，市场推广、新品开发方面提供的建议情况，促销活动的支持情况。 </content> <type>Read</type> </section>         <section name="" displayNumber="" style="" class="" > <content>b A类销售折扣的支付条件：</content> <type>Read</type> </section>         <section name="" displayNumber="" style="" class="" > <content>1)  当各品牌KPI达标率超过100%时，乙方根据品牌实际进货量计算以支付店家A类销售折扣；若KPI达标率未达到100%。则按照KPI达成量计算。 </content> <type>Read</type> </section>         <section name="ContractLineAddOn" displayNumber="" style="" class="" > <content>2)  在合同期间，假设甲方100%完成销量目标，且KPI达标率为100%，则预计A类销售折扣总计{BRSFTotalContractAmount}元。本条为预估，对乙方不具有约束力 </content> <type>Read</type> </section>          <section name="PSFTableHeader" displayNumber="2.2" style="" class="" > <content>B类销售折扣: </content> <type>Read</type> </section> <section name="PSFTable" displayNumber="" style="" class="" description="Do Not change the name" > <content>产品列表//月销量指标//月达标销售折扣//年销量指标// 年达标销售折扣 </content> <type>Read</type> <subSection>            <section name="PSFTableA_HeaderTerm" displayNumber="2.2." style="" class="BySubBrand" description="Do Not change the name and displayNumber format"> <content>甲方按品牌完成下述约定的销量指标是进一步享受B类销售折扣的前提条件。 </content> <type>Read</type> </section> <section name="PSFTableA_HeaderTerm" displayNumber="2.2." style="" class="ByGrade" description="Do Not change the name and displayNumber format"> <content>甲方按品牌档次完成下述约定的销量指标是进一步享受B类销售折扣的前提条件。 </content> <type>Read</type> </section> <section name="PSFTableA_HeaderTerm" displayNumber="2.2." style="" class="ByCategory" description="Do Not change the name and displayNumber format"> <content>甲方按产品类别完成下述约定的销量指标是进一步享受B类销售折扣的前提条件。 </content> <type>Read</type> </section> <section name="PSFTableA_HeaderTerm" displayNumber="2.2." style="" class="ByTotal" description="Do Not change the name and displayNumber format"> <content>甲方按总销量完成下述约定的销量指标是进一步享受B类销售折扣的前提条件。 </content> <type>Read</type> </section> <section name="PSFTableA_In_total" displayNumber="" style="" class="" > <content>总计： </content> <type>Read</type> </section> <section name="PSFTableA" displayNumber="" style="" class="1rowspan1 2colspan4 2InputText BySubBrand" description="Do Not change the name format and the name should be unique" > <content>备注// 为确保所有签约门店干邑的有效供货，合同约定的供货干邑销量等于合同目标销量，不能保证超额供货和支付相关A类销售折扣和B类销售折扣。 </content> <type>Read</type> </section> <section name="PSFTableD" displayNumber="" style="" class="1rowspan1 2colspan2 2InputText ByGrade" description="Do Not change the name format" > <content>备注//为确保所有签约门店干邑的有效供货，合同约定的供货干邑销量等于合同目标销量，不能保证超额供货和支付相关A类销售折扣和B类销售折扣。 </content> <type>Read</type> </section> <section name="PSFTableG" displayNumber="" style="" class="1rowspan1 2colspan2 2InputText ByCategory" description="Do Not change the name format" > <content>备注//为确保所有签约门店干邑的有效供货，合同约定的供货干邑销量等于合同目标销量，不能保证超额供货和支付相关A类销售折扣和B类销售折扣。 </content> <type>Read</type> </section> <section name="PSFTableI" displayNumber="" style="" class="1rowspan1 2colspan2 2InputText ByTotal" description="Do Not change the name format" > <content>备注// 为确保所有签约门店干邑的有效供货，合同约定的供货干邑销量等于合同目标销量，不能保证超额供货和支付相关A类销售折扣和B类销售折扣。 </content> <type>Read</type> </section> </subSection> </section> <section name="Event_Support" displayNumber="3.3" style="font-weight: bold;"> <content>特别活动折扣 </content> <type>Read</type> </section> <section name="Event_Support 1" displayNumber="" style=""> <content>甲方完成B类销售折扣约定的销量指标，是进一步享受特别活动折扣的前提条件。 </content> <type>Read</type> </section> <section name="VECTable" displayNumber="" style="text-align: center;" class="" description="Do Not change the name" > <content>产品列表//月销量指标<br/>(瓶)//单瓶活动赞助费用<br/>(元)//年销量指标<br/>(瓶)//年达标销售折扣<br/>(元) </content> <type>Read</type> <subSection> <section name="VECTableA_In_total" displayNumber="" style="" class="" > <content>总计： </content> <type>Read</type> </section> <section name="VECTableA" displayNumber="" style="" class="2colspan4 2InputText BySubBrand" description="Do Not change the name" > <content>备注// </content> <type>Read</type> </section> <section name="VECTableB" displayNumber="" style="" class="2colspan4 2InputText ByGrade" description="Do Not change the name" > <content>备注// </content> <type>Read</type> </section> <section name="VECTableC" displayNumber="" style="" class="2colspan4 2InputText ByCategory" description="Do Not change the name" > <content>备注// </content> <type>Read</type> </section> <section name="VECTableD" displayNumber="" style="" class="2colspan4 2InputText ByTotal" description="Do Not change the name" > <content>备注// </content> <type>Read</type> </section> </subSection> </section> </subSection> </section>     <section name="Payment Conditions" displayNumber="4" style="" class="AppendixLineHeader" > <content><b><u>品牌推广服务费及销售折扣的支付条件</u></b></content> <type>Read</type> <subSection> <section name="" displayNumber="1)" style="" class="" > <content>甲方依据约定为各项品牌推广活动提供场地、便利和其他支持是甲方获得品牌推广服务费的前提条件。 </content> <type>Read</type> </section>         <section name="KeySubBrandPart" displayNumber="2)" style="" description="Do Not change the name" > <content>店家选择{Key-SubBrand}作为主要策略品牌，合同期内进货上述策略品牌达到其销量目标的100%（不能以其他品牌销量换算），是合同期内B类销售折扣总金额及特别活动折扣总金额支付的前提条件。若未达到100%，乙方有权调整B类销售折扣及特别活动折扣甚至不予支付。</content> <type>Read</type> </section>         <section name="" displayNumber="3)" style="" class="" > <content>芝华士12年新境以下级别产品不参与B类销售折扣。 </content> <type>Read</type> </section>         <section name="" displayNumber="4)" style="" class="" > <content>合同期内，B类销售折扣及特别活动折扣的支付需同时参考KPI达成情况;           1) 若KPI达到约定值，支付金额=B类单瓶销售折扣*确认为甲方从乙方进货的保乐力加产品数量;<br/>           2) 若KPI未达到约定值，支付金额 = B类单瓶销售折扣X确认为甲方从乙方进货的保乐力加产品数量 X KPI达标率（最高100%）； </content> <type>Read</type> </section> <section name="Payment_Conditions_BC_Rate" displayNumber="5)" style="" class="" > <content>甲方享受各类销售折扣的前提条件为同时满足以下两项：KPI达标率达到{BCRate}<br/>马爹利系列产品KPI达标率不低于{MartellBCRate}。在以上两项指标中任意一项未达标的情况下，乙方有权调整合同项下的各类销售折扣。KPI达标率超过100%时，按100%封顶计。<br/>KPI指标包含：消费者口味、偏好等市场数据搜集情况，对消费者的服务质量，包装回收率、市场满意度情况，市场推广、新品开发方面提供的建议情况，促销活动的支持情况。 </content> <type>Read</type> </section>                   <section name="Payment_ConditionsC" displayNumber="6)" style="" class="" description="Do Not change the {1}-{6}" > <content>如果本协议期内，甲方未能完成约定的年度B类销量指标，则本协议自动延期直至B类销量指标完成为止。协议延续期间本协议各方的权利义务根据届时情况予以调整(如需要)。 </content> <type>Selectable</type> </section> <section name="" displayNumber="7)" style="" class="" > <content>甲方同意上述各项品牌推广服务费可以现金或产品实物的形式支付。 </content> <type>Read</type> </section> <section name="" displayNumber="8)" style="" class="" > <content>甲方始终遵守以下第5条的各项承诺。 </content> <type>Read</type> </section> </subSection> </section> <section name="Party A undertakes" displayNumber="5" style="" class="AppendixLineHeader" > <content><b><u>甲方承诺</u></b></content> <type>Read</type> <subSection> <section name="" displayNumber="a)" style="" class="" > <content>将在法律允许的范围内在甲方场地尽其最大商业努力推销保乐力加产品。 </content> <type>Read</type> </section> <section name="" displayNumber="b)" style="" class="" > <content>甲方场地内用于调制杯饮类的副酒将尽量使用保乐力加品类中相应品种的产品。 </content> <type>Read</type> </section> <section name="" displayNumber="c)" style="" class="" > <content>在甲方场地重点展示保乐力加产品及其品牌。 </content> <type>Read</type> </section> <section name="" displayNumber="d)" style="" class="" > <content>为保乐力加的品牌在场内举行促销活动提供场地和服务。 </content> <type>Read</type> </section> <section name="PartyAUndertakes_e" displayNumber="e)" style="" class="" > <content>{InputText} </content> <type>Selectable</type> </section> </subSection> </section> <section name="Affiliates_List" displayNumber="6" style="font-weight: bold;" class="" description="Party A under the Agreement shall also include its affiliates " > <content>为避免疑义，本协议项下的甲方亦指其关联公司：{Outlet}</content> <type>Read</type> </section> </appendix> <AppendixSignature> <section name="BodySignature1" displayNumber="" style="font-weight: bold;font-size: 16px;" class="" > <content>(甲方门店签字盖章)//(乙方经销商签字盖章)</content> <type>Read</type> </section> <section name="" displayNumber="" style="" class="" > <content></content> <type>Read</type> </section> <section name="ChopSignature" displayNumber="" style="" class="" description="Do Not change the name" > <content> // . </content> <type>Read</type> </section> <section name="" displayNumber="" style="" class="" > <content></content> <type>Read</type> </section> <section name="" displayNumber="" style="" class="" > <content>日 期： // 日 期： </content> <type>Read</type> </section> <section name="" displayNumber="" style="" class="" > <content></content> <type>Read</type> </section>   </AppendixSignature> </source>';     
            
            String TextUpdatedList ='["FixCostTable_2_5//该项费用在本协议签订后3个月后支付，甲方需要提供相应的形象宣传照片等支持文件。", "FixCostTable_3_5//该项费用在双方确定具体活动计划时确定具体支付时间和方式。", "BRSFTableB//享受A类销售折扣的前提 1) 季度销量（或进货额）不低于ddd（可选项）;且2) 符合其他约定条件", "PSFTableA//B类销售折扣B类销售折扣B类销售折扣", "PSFTableD//B类销售折扣2甲方按品牌档次完成下述约定的销量指标是进一步享受B类销售折扣的前提条件", "Payment_ConditionsC//true", "Selectable1//true", "PartyAUndertakes_e//true", "Party C//华盛贸易(WSSHA228):a8bM00000008P59IAE"]';
        String InputAmountUpdatedList='[]';
        
        
        String ModuleRefList='["'+ModuleList[0].Id+'//享受A类销售折扣的前提 1) 季度销量（或进货额）不低于ddd（可选项）;且2) 符合其他约定条件",'+
            ' "'+ModuleList[1].Id+'//B类销售折扣B类销售折扣B类销售折扣",'+
            ' "'+ModuleList[5].Id+'//B类销售折扣2甲方按品牌档次完成下述约定的销量指标是进一步享受B类销售折扣的前提条件"]';
        Document document;
        
        document = new Document();
        document.Body = Blob.valueOf('Some Text');
        document.ContentType = 'application/xml';
        document.DeveloperName = 'ASI_CRM_CN_Heavy_Test_document';
        document.IsPublic = true;
        document.Name = 'My Document';
        document.FolderId =f.Id;// [select id from folder limit 1].id;
        insert document;
        
        
        test.startTest();
        ASI_CRM_CN_HeavyContractGenerationCtrl con = new ASI_CRM_CN_HeavyContractGenerationCtrl();
        con.xmlStringTestClass=XMLTestString;
        con.contractId=Contract.Id;
        con.isEditable=true;
        con.HightLight=false;
        con.init();
        
        
        ASI_CRM_CN_HeavyContractGenerationCtrl con2 = new ASI_CRM_CN_HeavyContractGenerationCtrl();
        con2.xmlStringTestClass=XMLTestString;
        con2.contractId=Contract.Id;
        con2.isEditable=false;
        con2.HightLight=false;
        con2.init();
        
        List<sObject>  TempList = ASI_CRM_CN_HeavyContractGenerationCtrl.findList('ASI_CRM_AccountsAdditionalField__c','Id,Name,ASI_CRM_CN_Legal_Name__c, ASI_CRM_Account__c, ASI_CRM_Account__r.id','');
        String TestString = ASI_CRM_CN_HeavyContractGenerationCtrl.saveTemplate('back',Contract.Id,TextUpdatedList,InputAmountUpdatedList,ModuleRefList,ContractCostLinesJson);
        
        
        ASI_CRM_CN_HeavyContractGenerationCtrl con3 = new ASI_CRM_CN_HeavyContractGenerationCtrl();
        con3.xmlStringTestClass=XMLTestString;
        con3.contractId=Contract.Id;
        con3.isEditable=false;
        con3.HightLight=true;
        con3.init();
        
        
        ApexPages.currentPage().getParameters().put('id',Contract.Id);
        ApexPages.currentPage().getParameters().put('edit','1');
        ApexPages.currentPage().getParameters().put('external','1');
        ApexPages.currentPage().getParameters().put('ForHightLight', '1');
        
        
        ASI_CRM_CN_HeavyContractGenerationCtrl con4 = new ASI_CRM_CN_HeavyContractGenerationCtrl();
        con4.xmlStringTestClass=XMLTestString2;
        con4.contractId=Contract.Id;
        con4.isEditable=false;
        con4.HightLight=true;
        con4.init();
        
        
        ASI_CRM_CN_HeavyContractGenerationCtrl con5 = new ASI_CRM_CN_HeavyContractGenerationCtrl();
        con5.xmlStringTestClass=XMLTestString3;
        con5.contractId=Contract.Id;
        con5.isEditable=false;
        con5.HightLight=true;
        con5.init();
        
        
        
        ASI_CRM_CN_HeavyContractGenerationCtrl con6 = new ASI_CRM_CN_HeavyContractGenerationCtrl();
        con6.xmlStringTestClass=XMLTestString4;
        con6.contractId=Contract.Id;
        con6.isEditable=false;
        con6.HightLight=true;
        con6.init();
        con6.TableSplitLineRow('Test Test Test|', 2);
        con6.TableSplitLineRow('Test| Test| Test|', 1);
        con6.ContentReplace('{InputText}', 'InputName', 'ASI_CRM_CN_HeavyContractGenerationCtrl');
        
        ASI_CRM_CN_HeavyContractGenerationCtrl con7 = new ASI_CRM_CN_HeavyContractGenerationCtrl();
        con7.xmlStringTestClass=XMLTestString5;
        con7.contractId=Contract.Id;
        con7.isEditable=false;
        con7.HightLight=true;
        con7.init();
        con7.CheckingIsVisibleOrNot('PartyA');
        con7.LineBreakProcess('TestTestTestTestTestTest',3,1);
        
        ASI_CRM_CN_HeavyContractGenerationCtrl con8 = new ASI_CRM_CN_HeavyContractGenerationCtrl();
        con8.xmlStringTestClass=XMLTestString6;
        con8.contractId=Contract.Id;
        con8.isEditable=false;
        con8.HightLight=true;
        con8.init();
        con8.genSpace(1);
        
        string TempStr= ASI_CRM_CN_HeavyContractGenerationCtrl.ChangeTemplate(Contract, region.Name, false);
        
        TempStr= con7.StringCaseHandler('{TotalMonthlyVolume} Test {ContractTotal} Test {BCRate} Test {MartellBCRate} Test {Key-SubBrand}',20.0, 20.0);
        
        ApexPages.currentPage().getParameters().put('id',Contract.Id);
        ApexPages.currentPage().getParameters().put('edit','1');
        ApexPages.currentPage().getParameters().put('external','1');
        ApexPages.currentPage().getParameters().put('ForHightLight', '1');
        
        ASI_CRM_CN_HeavyContractGenPageCtrl con9= new ASI_CRM_CN_HeavyContractGenPageCtrl();
        
        test.stopTest();
        
    }
    
    static testMethod void EditHeavyContractDetailCtrlTest1() {
        //Test Class for ASI_CRM_CN_EditHeavyContractDetailCtrl
        
        ASI_CRM_Region__c region = new ASI_CRM_Region__c (Name='Central Region',recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Region__cASI_CRM_CN_Region'));
        insert region;
        
        ASI_CRM_Division__c division = new ASI_CRM_Division__c(Name='TEST', ASI_CRM_Region__c=region.Id);
        insert division;
        
        ASI_CRM_CN_Area__c area = new ASI_CRM_CN_Area__c(Name='TEST', ASI_CRM_English_Name__c='TEST', ASI_CRM_Division__c=division.Id);
        insert area;
        
        ASI_CRM_City__c city = new ASI_CRM_City__c(Name='TEST', ASI_CRM_CN_Area__c=area.Id,ASI_CRM_CN_City_Tier__c='2');
        insert city;
        
        /*ASI_CRM_CN_Channel__c channel = new ASI_CRM_CN_Channel__c(Name='KTV',ASI_CRM_BC_Rate__c=98,ASI_CRM_CN_On_Off__c='ON',ASI_CRM_For_Outlet__c=true,RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CN_Channel__cASI_CRM_CN_New_Channel'),ASI_CRM_For_Contract__c=TRUE);
        insert channel;*/
        
        ASI_CRM_CN_Channel__c channel = new ASI_CRM_CN_Channel__c(ASI_CRM_CN_On_Off__c='ON');
        insert channel;
        /*
        ASI_CRM_SegmentationCriteria__c SegmentationCriteria= new ASI_CRM_SegmentationCriteria__c (Name='Test',ASI_CRM_Channel__c=channel.Id, ASI_CRM_Outlet_New_Image__c='Iconic',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_SegmentationCriteria__cASI_CRM_CN_Segmentation_Criteria'));
        INSERT SegmentationCriteria;
        
        Id rtWS = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_CN_WS');
        Id rtOutlet = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN');
        */
        ASI_MFM_Sub_Channel__c subChannel = new ASI_MFM_Sub_Channel__c(ASI_CRM_CN_Channel__c=channel.Id);
        insert subChannel;
        
        ASI_CRM_CN_Channel__c newChannel = new ASI_CRM_CN_Channel__c(ASI_CRM_For_Outlet__c = true, Name='Restaurant',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CN_Channel__cASI_CRM_CN_New_Channel'),ASI_CRM_CN_On_Off__c='OFF');
        insert newChannel;
        
        list<ASI_CRM_AccountsAdditionalField__c> Customers = new list<ASI_CRM_AccountsAdditionalField__c>();
        Customers.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Eng_Name__c = 'b', ASI_CRM_CN_Chi_Name__c = 'b', ASI_CRM_CN_Commercial_Team__c = 'Premium', ASI_CRM_CN_Sub_Channel__c=subChannel.Id, ASI_CRM_CN_CCity__c=city.Id, ASI_CRM_Latest_Call_Plan_Date__c=system.today(), RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN'), ASI_CRM_CN_NewChannel__c = newChannel.Id, ASI_CRM_CN_Type_of_Restaurant__c = 'International',ASI_CRM_CN_Spending_per_head__c=1));
        Customers.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Eng_Name__c = 'c', ASI_CRM_CN_Chi_Name__c = 'c', ASI_CRM_CN_Commercial_Team__c = 'Premium', ASI_CRM_CN_Sub_Channel__c=subChannel.Id, ASI_CRM_CN_CCity__c=city.Id, ASI_CRM_Latest_Call_Plan_Date__c=system.today(), RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN'), ASI_CRM_CN_NewChannel__c = newChannel.Id, ASI_CRM_CN_Type_of_Restaurant__c = 'International',ASI_CRM_CN_Spending_per_head__c=1));
        insert Customers;
        /*
        
        list<ASI_CRM_AccountsAdditionalField__c> ChildCustomers = new list<ASI_CRM_AccountsAdditionalField__c>();
        ChildCustomers.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Parent_Outlet__c=Customers[1].Id,ASI_CRM_CN_Eng_Name__c = 'a', ASI_CRM_CN_Chi_Name__c = 'a', ASI_CRM_CN_Commercial_Team__c = 'Premium', ASI_CRM_CN_Sub_Channel__c=subChannel.Id, ASI_CRM_CN_CCity__c=city.Id, ASI_CRM_Latest_Call_Plan_Date__c=system.today(), RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN'), ASI_CRM_CN_NewChannel__c = newChannel.Id, ASI_CRM_CN_Type_of_Restaurant__c = 'International',ASI_CRM_CN_Spending_per_head__c=1));
        insert ChildCustomers;
        
        */
        
        User currentUser = [SELECT id, name, Managerid, ASI_CRM_CN_Prefix__c,LanguageLocaleKey FROM USER WHERE id =:UserInfo.getUserId()];
        currentUser.LanguageLocaleKey='zh_CN';
        update currentUser;
        
        list<ASI_HK_CRM_Running_Number__c> rns = new list<ASI_HK_CRM_Running_Number__c>();
        rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_TH_CRM_Contract__c', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_TH_CRM_PaymentRequest__c', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        if(!String.isBlank(currentUser.ASI_CRM_CN_Prefix__c))
            rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_'+currentUser.ASI_CRM_CN_Prefix__c, recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        else{
            rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_NULL', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
            rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        }
        insert rns;
        
        
        
        
        
        List<ASI_HK_CRM_Product_Category__c> ProductCategoryList= new List<ASI_HK_CRM_Product_Category__c> ();
        ProductCategoryList.add(new ASI_HK_CRM_Product_Category__c(Name='Category1',ASI_CRM_CN_Chinese_Name__c='Category',ASI_HK_CRM_English_Name__c='Category',ASI_HK_CRM_Sequence__c=1,recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Product_Category__cASI_CRM_CN_Product_Category')));
        ProductCategoryList.add(new ASI_HK_CRM_Product_Category__c(Name='Category2',ASI_CRM_CN_Chinese_Name__c='Category2',ASI_HK_CRM_English_Name__c='Category',ASI_HK_CRM_Sequence__c=2,recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Product_Category__cASI_CRM_CN_Product_Category')));
        ProductCategoryList.add(new ASI_HK_CRM_Product_Category__c(Name='Category3',ASI_CRM_CN_Chinese_Name__c='Category1',ASI_HK_CRM_English_Name__c='Category',ASI_HK_CRM_Sequence__c=3,recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Product_Category__cASI_CRM_CN_Product_Category')));
        
        insert ProductCategoryList;
        
        
        
        
        List<ASI_TH_CRM_Sub_category__c> SubCategoryList= new List<ASI_TH_CRM_Sub_category__c>();
        SubCategoryList.add(new ASI_TH_CRM_Sub_category__c(Name='SubCategory1',ASI_CRM_CN_Product_Category__c=ProductCategoryList[0].Id,recordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_Sub_category__cASI_CRM_CN_Sub_Category')));
        SubCategoryList.add(new ASI_TH_CRM_Sub_category__c(Name='SubCategory2',ASI_CRM_CN_Product_Category__c=ProductCategoryList[1].Id,recordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_Sub_category__cASI_CRM_CN_Sub_Category')));
        SubCategoryList.add(new ASI_TH_CRM_Sub_category__c(Name='SubCategory3',ASI_CRM_CN_Product_Category__c=ProductCategoryList[2].Id,recordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_Sub_category__cASI_CRM_CN_Sub_Category')));
        
        insert SubCategoryList;
        
        
        List<ASI_MFM_Brand__c> BrandList = new List<ASI_MFM_Brand__c> ();
        BrandList.add(new ASI_MFM_Brand__c (Name='Test1',ASI_CRM_CN_Competitor__c=false,ASI_TH_CRM_Sub_category__c=SubCategoryList[0].Id,recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Brand__cASI_FOC_CN_Brand')));
        BrandList.add(new ASI_MFM_Brand__c (Name='Test2',ASI_CRM_CN_Competitor__c=false,ASI_TH_CRM_Sub_category__c=SubCategoryList[1].Id,recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Brand__cASI_FOC_CN_Brand')));
        BrandList.add(new ASI_MFM_Brand__c (Name='Test3',ASI_CRM_CN_Competitor__c=false,ASI_TH_CRM_Sub_category__c=SubCategoryList[2].Id,recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Brand__cASI_FOC_CN_Brand')));
        
        Insert BrandList;
        
        
        
        
        //Sub Brand Grade
        list<ASI_CRM_Sub_Brand_Grade__c> grades = new list<ASI_CRM_Sub_Brand_Grade__c>();
        grades.add(new ASI_CRM_Sub_Brand_Grade__c (Name='Premium',ASI_CRM_Chinese_Name__c='Test1',ASI_CRM_Chinese_Description__c='1. Standard + Premium 标准档 + 高档',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_Sub_Brand_Grade__cASI_CRM_CN_Sub_brand_Grade')));
        grades.add(new ASI_CRM_Sub_Brand_Grade__c (Name='TEST2',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_Sub_Brand_Grade__cASI_CRM_CN_Sub_brand_Grade')));
        grades.add(new ASI_CRM_Sub_Brand_Grade__c (Name='TEST3',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_Sub_Brand_Grade__cASI_CRM_CN_Sub_brand_Grade')));
        insert grades;
        
        list<ASI_MFM_Sub_brand__c> subBrands = new list<ASI_MFM_Sub_brand__c>();
        for(ASI_CRM_Sub_Brand_Grade__c grade :grades) {
            subBrands.add(new ASI_MFM_Sub_brand__c (Name='TEST1',ASI_MFM_Active_for_CRM__c=true,ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,RecordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand'),
                                                    ASI_CRM_CN_Sub_brand_Grade__c=grade.Id,ASI_MFM_Brand__c=BrandList[0].Id));
            subBrands.add(new ASI_MFM_Sub_brand__c (Name='TEST2',ASI_MFM_Active_for_CRM__c=true,RecordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand'),
                                                    ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,
                                                    ASI_CRM_CN_Sub_brand_Grade__c=grade.Id,ASI_MFM_Brand__c=BrandList[1].Id));
            subBrands.add(new ASI_MFM_Sub_brand__c ( Name='TEST3',ASI_MFM_Active_for_CRM__c=true,RecordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand'),
                                                    ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,
                                                    ASI_CRM_CN_Sub_brand_Grade__c=grade.Id,ASI_MFM_Brand__c=BrandList[2].Id));
            subBrands.add(new ASI_MFM_Sub_brand__c ( Name='999',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand'),
                                                    ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,ASI_MFM_Sub_brand_Code__c = '999' ,ASI_MFM_Active_for_CRM__c = true ,
                                                    ASI_CRM_CN_Sub_brand_Grade__c=grade.Id,ASI_MFM_Brand__c=BrandList[0].Id));
        }
        
        insert subBrands;
        
        /*
        List<ASI_CRM_Sub_Brand_Assignment__c> SubBrandAssignmentList= new List<ASI_CRM_Sub_Brand_Assignment__c>();
        for(ASI_MFM_Sub_brand__c SubBrandItem:subBrands){
            SubBrandAssignmentList.add(new ASI_CRM_Sub_Brand_Assignment__c(ASI_CRM_Sub_Brand__c=SubBrandItem.Id,ASI_CRM_Segmentation_Criteria__c=SegmentationCriteria.Id));
        }
        
        insert SubBrandAssignmentList;
        */
        
        List<ASI_MFM_A_C_Code__c> ACCodeList = new  List<ASI_MFM_A_C_Code__c>();
        ACCodeList.add(new ASI_MFM_A_C_Code__c( Name='0000000000000', ASI_MFM_A_C_Code__c='000010000',ASI_MFM_A_C_Description__c='ASI_CRM_CN_Variable_Cost_Contract',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_CN_A_C_Code') ));
        ACCodeList.add(new ASI_MFM_A_C_Code__c( Name='5275.010000 PRC - Bottle Return Service', ASI_MFM_A_C_Code__c='5275.010000',ASI_MFM_A_C_Description__c='Bottle Return Service',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_CN_A_C_Code') ));
        ACCodeList.add(new ASI_MFM_A_C_Code__c( Name='5275.020000 Promotion Service Fee', ASI_MFM_A_C_Code__c='5275.020000',ASI_MFM_A_C_Description__c='Promotion Service Fee',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_CN_A_C_Code') ));
        ACCodeList.add(new ASI_MFM_A_C_Code__c( Name='5275.030000 PRC - Variable Event Cost', ASI_MFM_A_C_Code__c='5275.030000',ASI_MFM_A_C_Description__c='Variable Event Cost',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_CN_A_C_Code') ));
        
        insert ACCodeList;
        
        
        List<ASI_CRM_Contract_Cost_Setting__c> ContractCostSettingList= new List<ASI_CRM_Contract_Cost_Setting__c>();
        
        ContractCostSettingList.add(new ASI_CRM_Contract_Cost_Setting__c(ASI_CRM_CN_Activity_Code__c=ACCodeList[0].Id,ASI_CRM_CN_Promotion_Type__c='Heavy Contract ON',
                                                                         ASI_CRM_CN_Fixed_Cost_Contract__c=true,ASI_CRM_CN_Variable_Cost_Contract__c=true));
        
        ContractCostSettingList.add(new ASI_CRM_Contract_Cost_Setting__c(ASI_CRM_CN_Activity_Code__c=ACCodeList[0].Id,ASI_CRM_CN_Promotion_Type__c='Heavy Contract ON',ASI_CRM_CN_Variable_Cost_Contract__c=true,
                                                                         ASI_CRM_CN_Fixed_Cost_Contract__c=false,ASI_CRM_CN_BRSF_Activity_Code_Default__c=true));
        
        ContractCostSettingList.add(new ASI_CRM_Contract_Cost_Setting__c(ASI_CRM_CN_Activity_Code__c=ACCodeList[0].Id,ASI_CRM_CN_Promotion_Type__c='Heavy Contract ON',ASI_CRM_CN_Variable_Cost_Contract__c=true,
                                                                         ASI_CRM_CN_Fixed_Cost_Contract__c=false,ASI_CRM_PSF_Activity_Code_Default__c=true));
        
        ContractCostSettingList.add(new ASI_CRM_Contract_Cost_Setting__c(ASI_CRM_CN_Activity_Code__c=ACCodeList[0].Id,ASI_CRM_CN_Promotion_Type__c='Heavy Contract ON',ASI_CRM_CN_Variable_Cost_Contract__c=true,
                                                                         ASI_CRM_CN_Fixed_Cost_Contract__c=false,ASI_CRM_VEC_Activity_Code_Defaul__c=true));
        
        insert ContractCostSettingList;
        /*
        ASI_CRM_SpecialPromotionTypeSetting__c oldspts = new ASI_CRM_SpecialPromotionTypeSetting__c( ASI_CRM_Promotion_Type__c = 'a');
        insert oldspts;
        
        ASI_CRM_SpecialPromotionTypeSetting__c newspts = new ASI_CRM_SpecialPromotionTypeSetting__c(ASI_CRM_Promotion_Type__c = 'Heavy Contract On',recordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_SpecialPromotionTypeSetting__cASI_CRM_CN_SpecialPromotionTypeSetting'));
        insert newspts;
        
        ASI_CRM_Special_Promotion_Type_Mapping__c sptm = new ASI_CRM_Special_Promotion_Type_Mapping__c(ASI_CRM_Mapping_of_New_Promotion_Type__c = newspts.Id,ASI_CRM_Mapping_of_Old_Promotion_Type__c = oldspts.Id,recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Special_Promotion_Type_Mapping__cASI_CRM_CN_Special_Promotion_Type_Mapping'));
        insert sptm;
        
        */
        
        Date PO_Start_Date = date.newinstance(system.today().year(), system.today().month(), 1);
        Date PO_End_Date = PO_Start_Date.addMonths(1)-1;
        
        
        ASI_TH_CRM_Contract__c GroupContract = new ASI_TH_CRM_Contract__c(recordtypeid = Global_RecordTypeCache.getRTID('ASI_TH_CRM_Contract__cASI_CRM_CN_Group_Contract'),
                                                                          ASI_CRM_CN_PO_Start_Date__c = PO_Start_Date,
                                                                          ASI_CRM_CN_PO_End_Date__c =PO_End_Date,
                                                                          Name = 'Noah C4',
                                                                          ASI_CRM_CN_Outlet_WS__c=Customers[1].Id);
        insert GroupContract;
        
        ASI_TH_CRM_Contract__c Contract = new ASI_TH_CRM_Contract__c(recordtypeid = Global_RecordTypeCache.getRTID('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract'),
                                                                     ASI_CRM_CN_Status__c = 'Final',ASI_CRM_CN_Group_Contract__c=GroupContract.Id,
                                                                     ASI_CRM_CN_PO_Start_Date__c = PO_Start_Date,
                                                                     ASI_CRM_CN_PO_End_Date__c =PO_End_Date,
                                                                     ASI_CRM_CN_PO_Version__c = '0.0',ASI_TH_CRM_Promotion_Type__c='Heavy Contract On',
                                                                     Name = 'Contract1',
                                                                     ASI_CRM_CN_Outlet_WS__c=Customers[1].Id,ASI_CRM_Volume_Option__c = 'Normal');
        insert Contract;
        
        
        List<ASI_CRM_Methodology__c> MethodologyList= new List<ASI_CRM_Methodology__c> ();
        MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test1',ASI_CRM_Methodology_Code__c='01',ASI_CRM_Default__c=true,ASI_CRM_Chinese_Name__c='123',ASI_CRM_Type__c='BRSF',recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Methodology__cASI_CRM_CN_Methodology')));
        MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test2',ASI_CRM_Methodology_Code__c='01',ASI_CRM_Default__c=true,ASI_CRM_Chinese_Name__c='Test 123',ASI_CRM_Type__c='PSF',recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Methodology__cASI_CRM_CN_Methodology')));
        MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test3',ASI_CRM_Methodology_Code__c='01',ASI_CRM_Default__c=true,ASI_CRM_Chinese_Name__c='Test 123',ASI_CRM_Type__c='Variable Event Cost',recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Methodology__cASI_CRM_CN_Methodology')));
        
        
        MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test1',ASI_CRM_Methodology_Code__c='01',ASI_CRM_Chinese_Name__c='123',ASI_CRM_Type__c='BRSF',recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Methodology__cASI_CRM_CN_Methodology')));
        MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test2',ASI_CRM_Methodology_Code__c='01',ASI_CRM_Chinese_Name__c='123',ASI_CRM_Type__c='PSF',recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Methodology__cASI_CRM_CN_Methodology')));
        MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test3',ASI_CRM_Methodology_Code__c='01',ASI_CRM_Chinese_Name__c='123',ASI_CRM_Type__c='Variable Event Cost',recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Methodology__cASI_CRM_CN_Methodology')));
        insert MethodologyList;
        
        
        //Methodology Assignment
        List<ASI_CRM_Methodology_Assignment__c> MethodologyAssignmentList = new List<ASI_CRM_Methodology_Assignment__c>();
        MethodologyAssignmentList.add(new ASI_CRM_Methodology_Assignment__c(ASI_CRM_Methodology__c=MethodologyList[0].Id,ASI_CRM_Key_Principle__c=true,ASI_CRM_Methodology_Commercial_Team__c='Premium',ASI_CRM_Region__c=region.Id));
        MethodologyAssignmentList.add(new ASI_CRM_Methodology_Assignment__c(ASI_CRM_Methodology__c=MethodologyList[1].Id,ASI_CRM_Key_Principle__c=true,ASI_CRM_Methodology_Commercial_Team__c='Premium',ASI_CRM_Region__c=region.Id));
        MethodologyAssignmentList.add(new ASI_CRM_Methodology_Assignment__c(ASI_CRM_Methodology__c=MethodologyList[2].Id,ASI_CRM_Key_Principle__c=true,ASI_CRM_Methodology_Commercial_Team__c='Premium',ASI_CRM_Region__c=region.Id));
        MethodologyAssignmentList.add(new ASI_CRM_Methodology_Assignment__c(ASI_CRM_Methodology__c=MethodologyList[3].Id,ASI_CRM_Key_Principle__c=true,ASI_CRM_Methodology_Commercial_Team__c='Premium',ASI_CRM_Region__c=region.Id));
        MethodologyAssignmentList.add(new ASI_CRM_Methodology_Assignment__c(ASI_CRM_Methodology__c=MethodologyList[4].Id,ASI_CRM_Key_Principle__c=true,ASI_CRM_Methodology_Commercial_Team__c='Premium',ASI_CRM_Region__c=region.Id));
        MethodologyAssignmentList.add(new ASI_CRM_Methodology_Assignment__c(ASI_CRM_Methodology__c=MethodologyList[5].Id,ASI_CRM_Key_Principle__c=true,ASI_CRM_Methodology_Commercial_Team__c='Premium',ASI_CRM_Region__c=region.Id));
        
        insert MethodologyAssignmentList ;
        
        
        
        
        List<ASI_CRM_Module__c> ModuleList = new List<ASI_CRM_Module__c>();
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='Std. Btl.',ASI_CRM_Volume_Base__c='By Sub-Brand',ASI_CRM_Line_Type__c='BRSF',ASI_CRM_Methodology__c=MethodologyList[0].Id));
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='Std. Btl.',ASI_CRM_Volume_Base__c='By Sub-Brand',ASI_CRM_Line_Type__c='PSF',ASI_CRM_Methodology__c=MethodologyList[1].Id));
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='CR12 Extra Eqv.',ASI_CRM_Volume_Base__c='By Grade',ASI_CRM_Line_Type__c='PSF',ASI_CRM_Methodology__c=MethodologyList[1].Id));
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='CR12 Extra Eqv.',ASI_CRM_Volume_Base__c='By Category',ASI_CRM_Line_Type__c='PSF',ASI_CRM_Methodology__c=MethodologyList[1].Id));
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='CR12 Extra Eqv.',ASI_CRM_Volume_Base__c='By Total',ASI_CRM_Line_Type__c='PSF',ASI_CRM_Methodology__c=MethodologyList[1].Id));
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='CR12 Extra Eqv.',ASI_CRM_Volume_Base__c='By Sub-Brand',ASI_CRM_Line_Type__c='Variable Event Cost',ASI_CRM_Methodology__c=MethodologyList[2].Id));
        
        insert ModuleList;
        /*
        ASI_CRM_Contract_Cost__c contractCost = new ASI_CRM_Contract_Cost__c(ASI_CRM_CN_Contract__c = Contract.id,
                                                                             ASI_CRM_CN_Estimate_Amount__c = 100000,
                                                                             ASI_CRM_CN_Cost_Type__c = 'Fixed',
                                                                             ASI_CRM_CN_Other_Cost_Payment_Request__c = true,
                                                                             recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_Contract_Cost__cASI_CRM_CN_Contract_Cost') );
        insert contractCost;
        */
        list<ASI_CRM_CN_Contract_BRSF_Line_Item__c> ContractLineList = new list<ASI_CRM_CN_Contract_BRSF_Line_Item__c>();
        list<ASI_CRM_CN_Covered_Outlet__c> cos = new list<ASI_CRM_CN_Covered_Outlet__c>();
        for(ASI_MFM_Sub_brand__c subBrand :subBrands) {
            ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract.Id,
                                                                           ASI_CRM_CN_Est_Monthly_Qty__c=1,ASI_CRM_Module__c=ModuleList[0].Id,
                                                                           ASI_CRM_CN_Contract_Monthly_Qty__c=1,
                                                                           ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,
                                                                           ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,ASI_CRM_Type__c='BRSF',
                                                                           ASI_CRM_CN_Sub_Brand__c=subBrand.Id,
                                                                           recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF')));
        }
        
        for(ASI_MFM_Sub_brand__c subBrand :subBrands) {
            ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract.Id,
                                                                           ASI_CRM_CN_Est_Monthly_Qty__c=1,ASI_CRM_Module__c=ModuleList[1].Id,
                                                                           ASI_CRM_CN_Contract_Monthly_Qty__c=1,ASI_CRM_Volume_Base__c='By Sub-Brand',
                                                                           ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,
                                                                           ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,ASI_CRM_Type__c='PSF',
                                                                           ASI_CRM_CN_Sub_Brand__c=subBrand.Id,
                                                                           recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF')));
        }
        
        ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract.Id,ASI_CRM_Type__c='PSF',ASI_CRM_Volume_Base__c='By Grade',
                                                                       ASI_CRM_CN_Est_Monthly_Qty__c=4,ASI_CRM_Module__c=ModuleList[2].Id,
                                                                       ASI_CRM_CN_Contract_Monthly_Qty__c=4,ASI_CRM_Sub_Brand_Grade__c=grades[0].Id,
                                                                       ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,
                                                                       ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,
                                                                       ASI_CRM_CN_Sub_Brand__c=null,
                                                                       recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF') ));
        ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract.Id,ASI_CRM_Type__c='PSF',ASI_CRM_Volume_Base__c='By Category',
                                                                       ASI_CRM_CN_Est_Monthly_Qty__c=4,ASI_CRM_Module__c=ModuleList[3].Id,
                                                                       ASI_CRM_CN_Contract_Monthly_Qty__c=4,ASI_CRM_Product_Category__c=ProductCategoryList[0].Id,
                                                                       ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,
                                                                       ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,
                                                                       ASI_CRM_CN_Sub_Brand__c=null,
                                                                       recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF') ));
        ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract.Id,ASI_CRM_Type__c='PSF',ASI_CRM_Volume_Base__c='By Total',
                                                                       ASI_CRM_CN_Est_Monthly_Qty__c=4,ASI_CRM_Module__c=ModuleList[4].Id,
                                                                       ASI_CRM_CN_Contract_Monthly_Qty__c=4,
                                                                       ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,
                                                                       ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,
                                                                       ASI_CRM_CN_Sub_Brand__c=null,
                                                                       recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF') ));
        for(ASI_MFM_Sub_brand__c subBrand :subBrands) {
            ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract.Id,
                                                                           ASI_CRM_CN_Est_Monthly_Qty__c=1,ASI_CRM_Module__c=ModuleList[5].Id,
                                                                           ASI_CRM_CN_Contract_Monthly_Qty__c=1,ASI_CRM_Volume_Base__c='By Sub-Brand',
                                                                           ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,
                                                                           ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,ASI_CRM_Type__c='Variable Event Cost',
                                                                           ASI_CRM_CN_Sub_Brand__c=subBrand.Id,
                                                                           recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF')));
        }
        
        insert ContractLineList;
        
        
        test.startTest();
        
        
        Integer coun = 1;
        for(ASI_CRM_CN_Contract_BRSF_Line_Item__c ContractLine:ContractLineList){
            system.debug(coun+'ContractLineList: '+ContractLine);
            coun++;
        }  
        
        
        
        
        ASI_CRM_CN_EditHeavyContractDetailCtrl con2 = new ASI_CRM_CN_EditHeavyContractDetailCtrl(new ApexPages.Standardcontroller(Contract));
        
        
        ApexPages.currentPage().getParameters().put('PARAM_Line_ID', ContractLineList[17].id);
        ApexPages.currentPage().getParameters().put('PARAM_item_ID', ModuleList[1].id);
        ApexPages.currentPage().getParameters().put('PARAM_Unit_ID','Std. Btl.');
        con2.RemovePSFLine();
        
        
        ApexPages.currentPage().getParameters().put('PARAM_Line_ID', ContractLineList[17].id);
        ApexPages.currentPage().getParameters().put('PARAM_item_ID', ModuleList[1].id);
        con2.PSFChangingSB();
        
        
        
        
        PageReference EnterPage = Page.ASI_CRM_CN_ViewHeavyContractPage;
        
        Map<String, String> pageParams = EnterPage.getParameters();
        
        pageParams.put('id', Contract.id);
        ApexPages.StandardController sc = new ApexPages.standardController(new ASI_TH_CRM_Contract__c());
        
        ASI_CRM_CN_EditHeavyContractDetailCtrl con = new ASI_CRM_CN_EditHeavyContractDetailCtrl(new ApexPages.Standardcontroller(Contract));
        con.saveItems();
        //con.SizeOfPSFMap = 1;
        
        
        
        ApexPages.currentPage().getParameters().put('PARAM_Line_ID', ContractLineList[0].id);
        con.Clone_BRSF();
        
        
        ApexPages.currentPage().getParameters().put('PARAM_Line_ID', ContractLineList[1].id);
        con.Remove_BRSF();
        con.AddNew_BRSF();
        
        
        
        con.LoopingReCalculatePSF();
        
        con.PSFAddModule();
        ApexPages.currentPage().getParameters().put('PARAM_Line_ID', ModuleList[1].id);
        con.RefreshPSFModule();
        ApexPages.currentPage().getParameters().put('PARAM_Line_ID', ModuleList[2].id);
        con.RefreshPSFModule();
        ApexPages.currentPage().getParameters().put('PARAM_Line_ID', ModuleList[3].id);
        con.RefreshPSFModule();
        ApexPages.currentPage().getParameters().put('PARAM_Line_ID', ModuleList[4].id);
        con.RefreshPSFModule();
        
        ApexPages.currentPage().getParameters().put('PARAM_Line_ID', ModuleList[1].id);
        con.AddNewPSFLine();
        
        
        ApexPages.currentPage().getParameters().put('PARAM_Line_ID', ContractLineList[33].id);
        con.VECChangingSB();
        con.AddNewVECLine();
        ApexPages.currentPage().getParameters().put('PARAM_Line_ID', ContractLineList[34].id);
        con.CloneVECLine();
        ApexPages.currentPage().getParameters().put('PARAM_Line_ID', ContractLineList[35].id);
        con.RemoveVECLine();
        
        
        con.AddNew_CoveredOutlet();
        
        con.saveItems();
        
        
        ApexPages.currentPage().getParameters().put('PARAMID', ModuleList[1].id);
        con.DeletePSFModule();
        
        con.BRSFClearAll();
        con.ModuleChecking();
        con.RefreshVECModule();
        con.ResetVECDetails();
        con.CopyHistoricalV0Contract();
        con.ResetPSFDetails();
        List<sObject> TempList= ASI_CRM_CN_EditHeavyContractDetailCtrl.FindSubBrandList('ASI_MFM_Sub_brand__c',' WHERE RecordType.DeveloperName = \'ASI_FOC_CN_Sub_brand\' ','Premium',region.Name,'2');
        test.stopTest(); 
    }
    
    static testMethod void EditHeavyContractDetailCtrlTest2() {
        //Test Class for ASI_CRM_CN_EditHeavyContractDetailCtrl
        ASI_CRM_Region__c region = new ASI_CRM_Region__c (Name='TEST',recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Region__cASI_CRM_CN_Region'));
        insert region;
        
        ASI_CRM_Division__c division = new ASI_CRM_Division__c(Name='TEST', ASI_CRM_Region__c=region.Id);
        insert division;
        
        ASI_CRM_CN_Area__c area = new ASI_CRM_CN_Area__c(Name='TEST', ASI_CRM_English_Name__c='TEST', ASI_CRM_Division__c=division.Id);
        insert area;
        
        ASI_CRM_City__c city = new ASI_CRM_City__c(Name='TEST', ASI_CRM_CN_Area__c=area.Id,ASI_CRM_CN_City_Tier__c='2');
        insert city;
        
        /*ASI_CRM_CN_Channel__c channel = new ASI_CRM_CN_Channel__c(Name='KTV',ASI_CRM_BC_Rate__c=98,ASI_CRM_CN_On_Off__c='ON',ASI_CRM_For_Outlet__c=true,RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CN_Channel__cASI_CRM_CN_New_Channel'),ASI_CRM_For_Contract__c=TRUE);
        insert channel;*/
        
        ASI_CRM_CN_Channel__c channel = new ASI_CRM_CN_Channel__c(ASI_CRM_CN_On_Off__c='ON');
        insert channel;
        
        ASI_CRM_SegmentationCriteria__c SegmentationCriteria= new ASI_CRM_SegmentationCriteria__c (Name='Test',ASI_CRM_Channel__c=channel.Id, ASI_CRM_Outlet_New_Image__c='Iconic',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_SegmentationCriteria__cASI_CRM_CN_Segmentation_Criteria'));
        INSERT SegmentationCriteria;
        
        Id rtWS = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_CN_WS');
        Id rtOutlet = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN');
        
        /*list<ASI_CRM_AccountsAdditionalField__c> Customers = new list<ASI_CRM_AccountsAdditionalField__c>();
        Customers.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Commercial_Team__c = 'Premium',ASI_CRM_CN_New_Image__c='Iconic',RecordTypeId=rtWS,Name='TEST', ASI_CRM_CN_Image__c='Iconic',ASI_CRM_CN_CCity__c=city.Id,ASI_CRM_CN_NewChannel__c=channel.Id));
        Customers.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Commercial_Team__c = 'Premium',ASI_CRM_CN_New_Image__c='Iconic',RecordTypeId=rtOutlet,Name='TEST', ASI_CRM_CN_Image__c='Iconic',ASI_CRM_CN_CCity__c=city.Id,ASI_CRM_CN_NewChannel__c=channel.Id));
        insert Customers;

        //Covered_Outlet
        list<ASI_CRM_AccountsAdditionalField__c> ChildCustomers = new list<ASI_CRM_AccountsAdditionalField__c>();
        ChildCustomers.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Parent_Outlet__c=Customers[1].Id,ASI_CRM_CN_Commercial_Team__c = 'Premium',RecordTypeId=rtOutlet,Name='TEST', ASI_CRM_CN_Image__c='Iconic',ASI_CRM_CN_CCity__c=city.Id,ASI_CRM_CN_NewChannel__c=channel.Id));
        insert ChildCustomers;



        list<ASI_CRM_AccountsAdditionalField__c> ChildChildCustomers = new list<ASI_CRM_AccountsAdditionalField__c>();
        ChildChildCustomers.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Parent_Outlet__c=ChildCustomers[0].Id,ASI_CRM_CN_Commercial_Team__c = 'Premium',RecordTypeId=rtOutlet,Name='TEST', ASI_CRM_CN_Image__c='Iconic',ASI_CRM_CN_CCity__c=city.Id,ASI_CRM_CN_NewChannel__c=channel.Id));
        insert ChildChildCustomers;*/
        
        ASI_MFM_Sub_Channel__c subChannel = new ASI_MFM_Sub_Channel__c(ASI_CRM_CN_Channel__c=channel.Id);
        insert subChannel;
        
        ASI_CRM_CN_Channel__c newChannel = new ASI_CRM_CN_Channel__c(ASI_CRM_For_Outlet__c = true, Name='Restaurant',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CN_Channel__cASI_CRM_CN_New_Channel'),ASI_CRM_CN_On_Off__c='OFF');
        insert newChannel;
        
        list<ASI_CRM_AccountsAdditionalField__c> Customers = new list<ASI_CRM_AccountsAdditionalField__c>();
        Customers.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Eng_Name__c = 'b', ASI_CRM_CN_Chi_Name__c = 'b', ASI_CRM_CN_Commercial_Team__c = 'Premium', ASI_CRM_CN_Sub_Channel__c=subChannel.Id, ASI_CRM_CN_CCity__c=city.Id, ASI_CRM_Latest_Call_Plan_Date__c=system.today(), RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN'), ASI_CRM_CN_NewChannel__c = newChannel.Id, ASI_CRM_CN_Type_of_Restaurant__c = 'International',ASI_CRM_CN_Spending_per_head__c=1));
        Customers.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Eng_Name__c = 'c', ASI_CRM_CN_Chi_Name__c = 'c', ASI_CRM_CN_Commercial_Team__c = 'Premium', ASI_CRM_CN_Sub_Channel__c=subChannel.Id, ASI_CRM_CN_CCity__c=city.Id, ASI_CRM_Latest_Call_Plan_Date__c=system.today(), RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN'), ASI_CRM_CN_NewChannel__c = newChannel.Id, ASI_CRM_CN_Type_of_Restaurant__c = 'International',ASI_CRM_CN_Spending_per_head__c=1));
        insert Customers;
        
        
        list<ASI_CRM_AccountsAdditionalField__c> ChildCustomers = new list<ASI_CRM_AccountsAdditionalField__c>();
        ChildCustomers.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Parent_Outlet__c=Customers[1].Id,ASI_CRM_CN_Eng_Name__c = 'a', ASI_CRM_CN_Chi_Name__c = 'a', ASI_CRM_CN_Commercial_Team__c = 'Premium', ASI_CRM_CN_Sub_Channel__c=subChannel.Id, ASI_CRM_CN_CCity__c=city.Id, ASI_CRM_Latest_Call_Plan_Date__c=system.today(), RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN'), ASI_CRM_CN_NewChannel__c = newChannel.Id, ASI_CRM_CN_Type_of_Restaurant__c = 'International',ASI_CRM_CN_Spending_per_head__c=1));
        insert ChildCustomers;
        
        
        User currentUser = [SELECT id, name, Managerid, ASI_CRM_CN_Prefix__c,LanguageLocaleKey FROM USER WHERE id =:UserInfo.getUserId()];
        currentUser.LanguageLocaleKey='zh_CN';
        update currentUser;
        
        list<ASI_HK_CRM_Running_Number__c> rns = new list<ASI_HK_CRM_Running_Number__c>();
        rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_TH_CRM_Contract__c', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_TH_CRM_PaymentRequest__c', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        if(!String.isBlank(currentUser.ASI_CRM_CN_Prefix__c))
            rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_'+currentUser.ASI_CRM_CN_Prefix__c, recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        else{
            rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_NULL', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
            rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        }
        insert rns;
        
        
        
        
        
        List<ASI_HK_CRM_Product_Category__c> ProductCategoryList= new List<ASI_HK_CRM_Product_Category__c> ();
        ProductCategoryList.add(new ASI_HK_CRM_Product_Category__c(Name='Category1',ASI_CRM_CN_Chinese_Name__c='Category',ASI_HK_CRM_English_Name__c='Category',ASI_HK_CRM_Sequence__c=1,recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Product_Category__cASI_CRM_CN_Product_Category')));
        ProductCategoryList.add(new ASI_HK_CRM_Product_Category__c(Name='Category2',ASI_CRM_CN_Chinese_Name__c='Category2',ASI_HK_CRM_English_Name__c='Category',ASI_HK_CRM_Sequence__c=2,recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Product_Category__cASI_CRM_CN_Product_Category')));
        ProductCategoryList.add(new ASI_HK_CRM_Product_Category__c(Name='Category3',ASI_CRM_CN_Chinese_Name__c='Category1',ASI_HK_CRM_English_Name__c='Category',ASI_HK_CRM_Sequence__c=3,recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Product_Category__cASI_CRM_CN_Product_Category')));
        
        insert ProductCategoryList;
        
        
        
        
        List<ASI_TH_CRM_Sub_category__c> SubCategoryList= new List<ASI_TH_CRM_Sub_category__c>();
        SubCategoryList.add(new ASI_TH_CRM_Sub_category__c(Name='SubCategory1',ASI_CRM_CN_Product_Category__c=ProductCategoryList[0].Id,recordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_Sub_category__cASI_CRM_CN_Sub_Category')));
        SubCategoryList.add(new ASI_TH_CRM_Sub_category__c(Name='SubCategory2',ASI_CRM_CN_Product_Category__c=ProductCategoryList[1].Id,recordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_Sub_category__cASI_CRM_CN_Sub_Category')));
        SubCategoryList.add(new ASI_TH_CRM_Sub_category__c(Name='SubCategory3',ASI_CRM_CN_Product_Category__c=ProductCategoryList[2].Id,recordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_Sub_category__cASI_CRM_CN_Sub_Category')));
        
        insert SubCategoryList;
        
        
        List<ASI_MFM_Brand__c> BrandList = new List<ASI_MFM_Brand__c> ();
        BrandList.add(new ASI_MFM_Brand__c (Name='Test1',ASI_CRM_CN_Competitor__c=false,ASI_TH_CRM_Sub_category__c=SubCategoryList[0].Id,recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Brand__cASI_FOC_CN_Brand')));
        BrandList.add(new ASI_MFM_Brand__c (Name='Test2',ASI_CRM_CN_Competitor__c=false,ASI_TH_CRM_Sub_category__c=SubCategoryList[1].Id,recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Brand__cASI_FOC_CN_Brand')));
        BrandList.add(new ASI_MFM_Brand__c (Name='Test3',ASI_CRM_CN_Competitor__c=false,ASI_TH_CRM_Sub_category__c=SubCategoryList[2].Id,recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Brand__cASI_FOC_CN_Brand')));
        
        Insert BrandList;
        
        
        
        
        //Sub Brand Grade
        list<ASI_CRM_Sub_Brand_Grade__c> grades = new list<ASI_CRM_Sub_Brand_Grade__c>();
        grades.add(new ASI_CRM_Sub_Brand_Grade__c (Name='Premium',ASI_CRM_Chinese_Name__c='Test1',ASI_CRM_Chinese_Description__c='1. Standard + Premium 标准档 + 高档',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_Sub_Brand_Grade__cASI_CRM_CN_Sub_brand_Grade')));
        grades.add(new ASI_CRM_Sub_Brand_Grade__c (Name='TEST2',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_Sub_Brand_Grade__cASI_CRM_CN_Sub_brand_Grade')));
        grades.add(new ASI_CRM_Sub_Brand_Grade__c (Name='TEST3',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_Sub_Brand_Grade__cASI_CRM_CN_Sub_brand_Grade')));
        insert grades;
        
        
        list<ASI_MFM_Sub_brand__c> subBrands = new list<ASI_MFM_Sub_brand__c>();
        for(ASI_CRM_Sub_Brand_Grade__c grade :grades) {
            subBrands.add(new ASI_MFM_Sub_brand__c (Name='TEST1',ASI_MFM_Active_for_CRM__c=true,ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,RecordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand'),
                                                    ASI_CRM_CN_Sub_brand_Grade__c=grade.Id,ASI_MFM_Brand__c=BrandList[0].Id));
            subBrands.add(new ASI_MFM_Sub_brand__c (Name='TEST2',ASI_MFM_Active_for_CRM__c=true,RecordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand'),
                                                    ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,
                                                    ASI_CRM_CN_Sub_brand_Grade__c=grade.Id,ASI_MFM_Brand__c=BrandList[1].Id));
            subBrands.add(new ASI_MFM_Sub_brand__c ( Name='TEST3',ASI_MFM_Active_for_CRM__c=true,RecordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand'),
                                                    ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,
                                                    ASI_CRM_CN_Sub_brand_Grade__c=grade.Id,ASI_MFM_Brand__c=BrandList[2].Id));
            subBrands.add(new ASI_MFM_Sub_brand__c ( Name='999',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand'),
                                                    ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,ASI_MFM_Sub_brand_Code__c = '999' ,ASI_MFM_Active_for_CRM__c = true ,
                                                    ASI_CRM_CN_Sub_brand_Grade__c=grade.Id,ASI_MFM_Brand__c=BrandList[0].Id));
        }
        
        insert subBrands;
        
        
        List<ASI_CRM_Sub_Brand_Assignment__c> SubBrandAssignmentList= new List<ASI_CRM_Sub_Brand_Assignment__c>();
        for(ASI_MFM_Sub_brand__c SubBrandItem:subBrands){
            SubBrandAssignmentList.add(new ASI_CRM_Sub_Brand_Assignment__c(ASI_CRM_Sub_Brand__c=SubBrandItem.Id,ASI_CRM_Segmentation_Criteria__c=SegmentationCriteria.Id));
        }
        
        insert SubBrandAssignmentList;
        
        
        List<ASI_MFM_A_C_Code__c> ACCodeList = new  List<ASI_MFM_A_C_Code__c>();
        ACCodeList.add(new ASI_MFM_A_C_Code__c( Name='0000000000000', ASI_MFM_A_C_Code__c='000010000',ASI_MFM_A_C_Description__c='ASI_CRM_CN_Variable_Cost_Contract',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_CN_A_C_Code') ));
        ACCodeList.add(new ASI_MFM_A_C_Code__c( Name='5275.010000 PRC - Bottle Return Service', ASI_MFM_A_C_Code__c='5275.010000',ASI_MFM_A_C_Description__c='Bottle Return Service',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_CN_A_C_Code') ));
        ACCodeList.add(new ASI_MFM_A_C_Code__c( Name='5275.020000 Promotion Service Fee', ASI_MFM_A_C_Code__c='5275.020000',ASI_MFM_A_C_Description__c='Promotion Service Fee',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_CN_A_C_Code') ));
        ACCodeList.add(new ASI_MFM_A_C_Code__c( Name='5275.030000 PRC - Variable Event Cost', ASI_MFM_A_C_Code__c='5275.030000',ASI_MFM_A_C_Description__c='Variable Event Cost',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_CN_A_C_Code') ));
        
        insert ACCodeList;
        
        
        List<ASI_CRM_Contract_Cost_Setting__c> ContractCostSettingList= new List<ASI_CRM_Contract_Cost_Setting__c>();
        
        ContractCostSettingList.add(new ASI_CRM_Contract_Cost_Setting__c(ASI_CRM_CN_Activity_Code__c=ACCodeList[0].Id,ASI_CRM_CN_Promotion_Type__c='Heavy Contract ON',
                                                                         ASI_CRM_CN_Fixed_Cost_Contract__c=true,ASI_CRM_CN_Variable_Cost_Contract__c=true));
        
        ContractCostSettingList.add(new ASI_CRM_Contract_Cost_Setting__c(ASI_CRM_CN_Activity_Code__c=ACCodeList[0].Id,ASI_CRM_CN_Promotion_Type__c='Heavy Contract ON',ASI_CRM_CN_Variable_Cost_Contract__c=true,
                                                                         ASI_CRM_CN_Fixed_Cost_Contract__c=false,ASI_CRM_CN_BRSF_Activity_Code_Default__c=true));
        
        ContractCostSettingList.add(new ASI_CRM_Contract_Cost_Setting__c(ASI_CRM_CN_Activity_Code__c=ACCodeList[0].Id,ASI_CRM_CN_Promotion_Type__c='Heavy Contract ON',ASI_CRM_CN_Variable_Cost_Contract__c=true,
                                                                         ASI_CRM_CN_Fixed_Cost_Contract__c=false,ASI_CRM_PSF_Activity_Code_Default__c=true));
        
        ContractCostSettingList.add(new ASI_CRM_Contract_Cost_Setting__c(ASI_CRM_CN_Activity_Code__c=ACCodeList[0].Id,ASI_CRM_CN_Promotion_Type__c='Heavy Contract ON',ASI_CRM_CN_Variable_Cost_Contract__c=true,
                                                                         ASI_CRM_CN_Fixed_Cost_Contract__c=false,ASI_CRM_VEC_Activity_Code_Defaul__c=true));
        
        insert ContractCostSettingList;
        
        ASI_CRM_SpecialPromotionTypeSetting__c oldspts = new ASI_CRM_SpecialPromotionTypeSetting__c( ASI_CRM_Promotion_Type__c = 'a');
        insert oldspts;
        
        ASI_CRM_SpecialPromotionTypeSetting__c newspts = new ASI_CRM_SpecialPromotionTypeSetting__c(ASI_CRM_Promotion_Type__c = 'Heavy Contract On',recordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_SpecialPromotionTypeSetting__cASI_CRM_CN_SpecialPromotionTypeSetting'));
        insert newspts;
        
        ASI_CRM_Special_Promotion_Type_Mapping__c sptm = new ASI_CRM_Special_Promotion_Type_Mapping__c(ASI_CRM_Mapping_of_New_Promotion_Type__c = newspts.Id,ASI_CRM_Mapping_of_Old_Promotion_Type__c = oldspts.Id,recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Special_Promotion_Type_Mapping__cASI_CRM_CN_Special_Promotion_Type_Mapping'));
        insert sptm;
        
        
        
        Date PO_Start_Date = date.newinstance(system.today().year(), system.today().month(), 1);
        Date PO_End_Date = PO_Start_Date.addMonths(1)-1;
        
        
        ASI_TH_CRM_Contract__c GroupContract = new ASI_TH_CRM_Contract__c(recordtypeid = Global_RecordTypeCache.getRTID('ASI_TH_CRM_Contract__cASI_CRM_CN_Group_Contract'),
                                                                          ASI_CRM_CN_PO_Start_Date__c = PO_Start_Date,
                                                                          ASI_CRM_CN_PO_End_Date__c =PO_End_Date,
                                                                          Name = 'Noah C4',
                                                                          ASI_CRM_CN_Outlet_WS__c=Customers[1].Id);
        insert GroupContract;

        ASI_TH_CRM_Contract__c Contract = new ASI_TH_CRM_Contract__c(recordtypeid = Global_RecordTypeCache.getRTID('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract'),
            ASI_CRM_CN_Status__c = 'Final',ASI_CRM_CN_Group_Contract__c=GroupContract.Id,
            ASI_CRM_CN_PO_Start_Date__c = PO_Start_Date,
            ASI_CRM_CN_PO_End_Date__c =PO_End_Date,
            ASI_CRM_CN_PO_Version__c = '0.1',ASI_TH_CRM_Promotion_Type__c='Heavy Contract On',
            Name = 'Contract1',
            ASI_CRM_CN_Expected_BRSF_Est_Total__c = 1000,
            ASI_CRM_CN_Outlet_WS__c=Customers[1].Id,ASI_CRM_Volume_Option__c = 'Normal');
        insert Contract;
        
        test.startTest();
        
        List<ASI_CRM_Methodology__c> MethodologyList= new List<ASI_CRM_Methodology__c> ();
        MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test1',ASI_CRM_Methodology_Code__c='01',ASI_CRM_Default__c=true,ASI_CRM_Chinese_Name__c='123',ASI_CRM_Type__c='BRSF',recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Methodology__cASI_CRM_CN_Methodology')));
        MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test2',ASI_CRM_Methodology_Code__c='01',ASI_CRM_Default__c=true,ASI_CRM_Chinese_Name__c='Test 123',ASI_CRM_Type__c='PSF',recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Methodology__cASI_CRM_CN_Methodology')));
        MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test3',ASI_CRM_Methodology_Code__c='01',ASI_CRM_Default__c=true,ASI_CRM_Chinese_Name__c='Test 123',ASI_CRM_Type__c='Variable Event Cost',recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Methodology__cASI_CRM_CN_Methodology')));
        
        
        MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test1',ASI_CRM_Methodology_Code__c='01',ASI_CRM_Chinese_Name__c='123',ASI_CRM_Type__c='BRSF',recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Methodology__cASI_CRM_CN_Methodology')));
        MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test2',ASI_CRM_Methodology_Code__c='01',ASI_CRM_Chinese_Name__c='123',ASI_CRM_Type__c='PSF',recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Methodology__cASI_CRM_CN_Methodology')));
        MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test3',ASI_CRM_Methodology_Code__c='01',ASI_CRM_Chinese_Name__c='123',ASI_CRM_Type__c='Variable Event Cost',recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Methodology__cASI_CRM_CN_Methodology')));
        insert MethodologyList;
        
        
        //Methodology Assignment
        List<ASI_CRM_Methodology_Assignment__c> MethodologyAssignmentList = new List<ASI_CRM_Methodology_Assignment__c>();
        MethodologyAssignmentList.add(new ASI_CRM_Methodology_Assignment__c(ASI_CRM_Methodology__c=MethodologyList[0].Id,ASI_CRM_Key_Principle__c=true,ASI_CRM_Methodology_Commercial_Team__c='Premium',ASI_CRM_Region__c=region.Id));
        MethodologyAssignmentList.add(new ASI_CRM_Methodology_Assignment__c(ASI_CRM_Methodology__c=MethodologyList[1].Id,ASI_CRM_Key_Principle__c=true,ASI_CRM_Methodology_Commercial_Team__c='Premium',ASI_CRM_Region__c=region.Id));
        MethodologyAssignmentList.add(new ASI_CRM_Methodology_Assignment__c(ASI_CRM_Methodology__c=MethodologyList[2].Id,ASI_CRM_Key_Principle__c=true,ASI_CRM_Methodology_Commercial_Team__c='Premium',ASI_CRM_Region__c=region.Id));
        MethodologyAssignmentList.add(new ASI_CRM_Methodology_Assignment__c(ASI_CRM_Methodology__c=MethodologyList[3].Id,ASI_CRM_Key_Principle__c=true,ASI_CRM_Methodology_Commercial_Team__c='Premium',ASI_CRM_Region__c=region.Id));
        MethodologyAssignmentList.add(new ASI_CRM_Methodology_Assignment__c(ASI_CRM_Methodology__c=MethodologyList[4].Id,ASI_CRM_Key_Principle__c=true,ASI_CRM_Methodology_Commercial_Team__c='Premium',ASI_CRM_Region__c=region.Id));
        MethodologyAssignmentList.add(new ASI_CRM_Methodology_Assignment__c(ASI_CRM_Methodology__c=MethodologyList[5].Id,ASI_CRM_Key_Principle__c=true,ASI_CRM_Methodology_Commercial_Team__c='Premium',ASI_CRM_Region__c=region.Id));
        
        //insert MethodologyAssignmentList ;
        
        
        
        
        List<ASI_CRM_Module__c> ModuleList = new List<ASI_CRM_Module__c>();
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='Std. Btl.',ASI_CRM_Volume_Base__c='By Sub-Brand',ASI_CRM_Line_Type__c='BRSF',ASI_CRM_Methodology__c=MethodologyList[0].Id));
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='Std. Btl.',ASI_CRM_Volume_Base__c='By Sub-Brand',ASI_CRM_Line_Type__c='PSF',ASI_CRM_Methodology__c=MethodologyList[1].Id));
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='CR12 Extra Eqv.',ASI_CRM_Volume_Base__c='By Grade',ASI_CRM_Line_Type__c='PSF',ASI_CRM_Methodology__c=MethodologyList[1].Id));
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='CR12 Extra Eqv.',ASI_CRM_Volume_Base__c='By Category',ASI_CRM_Line_Type__c='PSF',ASI_CRM_Methodology__c=MethodologyList[1].Id));
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='CR12 Extra Eqv.',ASI_CRM_Volume_Base__c='By Total',ASI_CRM_Line_Type__c='PSF',ASI_CRM_Methodology__c=MethodologyList[1].Id));
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='CR12 Extra Eqv.',ASI_CRM_Volume_Base__c='By Sub-Brand',ASI_CRM_Line_Type__c='Variable Event Cost',ASI_CRM_Methodology__c=MethodologyList[2].Id));
        
        insert ModuleList;
        
        ASI_CRM_Contract_Cost__c contractCost = new ASI_CRM_Contract_Cost__c(ASI_CRM_CN_Contract__c = Contract.id,
                                                                             ASI_CRM_CN_Estimate_Amount__c = 100000,
                                                                             ASI_CRM_CN_Cost_Type__c = 'Fixed',
                                                                             ASI_CRM_CN_Other_Cost_Payment_Request__c = true,
                                                                             recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_Contract_Cost__cASI_CRM_CN_Contract_Cost') );
        insert contractCost;
        
        list<ASI_CRM_CN_Contract_BRSF_Line_Item__c> ContractLineList = new list<ASI_CRM_CN_Contract_BRSF_Line_Item__c>();
        list<ASI_CRM_CN_Covered_Outlet__c> cos = new list<ASI_CRM_CN_Covered_Outlet__c>();
        for(ASI_MFM_Sub_brand__c subBrand :subBrands) {
            ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract.Id,
                                                                           ASI_CRM_CN_Est_Monthly_Qty__c=1,ASI_CRM_Module__c=ModuleList[0].Id,
                                                                           ASI_CRM_CN_Contract_Monthly_Qty__c=1,
                                                                           ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,
                                                                           ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,ASI_CRM_Type__c='BRSF',
                                                                           ASI_CRM_CN_Sub_Brand__c=subBrand.Id,
                                                                           recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF')));
        }
        
        for(ASI_MFM_Sub_brand__c subBrand :subBrands) {
            ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract.Id,
                                                                           ASI_CRM_CN_Est_Monthly_Qty__c=1,ASI_CRM_Module__c=ModuleList[1].Id,
                                                                           ASI_CRM_CN_Contract_Monthly_Qty__c=1,ASI_CRM_Volume_Base__c='By Sub-Brand',
                                                                           ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,
                                                                           ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,ASI_CRM_Type__c='PSF',
                                                                           ASI_CRM_CN_Sub_Brand__c=subBrand.Id,
                                                                           recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF')));
        }
        
        ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract.Id,ASI_CRM_Type__c='PSF',ASI_CRM_Volume_Base__c='By Grade',
                                                                       ASI_CRM_CN_Est_Monthly_Qty__c=4,ASI_CRM_Module__c=ModuleList[2].Id,
                                                                       ASI_CRM_CN_Contract_Monthly_Qty__c=4,ASI_CRM_Sub_Brand_Grade__c=grades[0].Id,
                                                                       ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,
                                                                       ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,
                                                                       ASI_CRM_CN_Sub_Brand__c=null,
                                                                       recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF') ));
        ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract.Id,ASI_CRM_Type__c='PSF',ASI_CRM_Volume_Base__c='By Category',
                                                                       ASI_CRM_CN_Est_Monthly_Qty__c=4,ASI_CRM_Module__c=ModuleList[3].Id,
                                                                       ASI_CRM_CN_Contract_Monthly_Qty__c=4,ASI_CRM_Product_Category__c=ProductCategoryList[0].Id,
                                                                       ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,
                                                                       ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,
                                                                       ASI_CRM_CN_Sub_Brand__c=null,
                                                                       recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF') ));
        ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract.Id,ASI_CRM_Type__c='PSF',ASI_CRM_Volume_Base__c='By Total',
                                                                       ASI_CRM_CN_Est_Monthly_Qty__c=4,ASI_CRM_Module__c=ModuleList[4].Id,
                                                                       ASI_CRM_CN_Contract_Monthly_Qty__c=4,
                                                                       ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,
                                                                       ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,
                                                                       ASI_CRM_CN_Sub_Brand__c=null,
                                                                       recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF') ));
        for(ASI_MFM_Sub_brand__c subBrand :subBrands) {
            ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract.Id,
                                                                           ASI_CRM_CN_Est_Monthly_Qty__c=1,ASI_CRM_Module__c=ModuleList[5].Id,
                                                                           ASI_CRM_CN_Contract_Monthly_Qty__c=1,ASI_CRM_Volume_Base__c='By Sub-Brand',
                                                                           ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,
                                                                           ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,ASI_CRM_Type__c='Variable Event Cost',
                                                                           ASI_CRM_CN_Sub_Brand__c=subBrand.Id,
                                                                           recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF')));
        }
        
        
        
        
        
        
        PageReference EnterPage = Page.ASI_CRM_CN_ViewHeavyContractPage;
        
        Map<String, String> pageParams = EnterPage.getParameters();
        
        pageParams.put('id', Contract.id);
        ApexPages.StandardController sc = new ApexPages.standardController(new ASI_TH_CRM_Contract__c());
        
        ASI_CRM_CN_EditHeavyContractDetailCtrl con = new ASI_CRM_CN_EditHeavyContractDetailCtrl(new ApexPages.Standardcontroller(Contract));
        con.AddAllChildOutlets();
        
        con.saveItems();
        
        
        con.CancelProcess();
        test.stopTest(); 
    }
    
    static testMethod void ASI_CRM_CN_ContractTrigger() {
        
        
        ASI_CRM_Region__c region = new ASI_CRM_Region__c (Name='Central Region',recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Region__cASI_CRM_CN_Region'));
        insert region;
        
        ASI_CRM_Division__c division = new ASI_CRM_Division__c(Name='TEST', ASI_CRM_Region__c=region.Id);
        insert division;
        
        ASI_CRM_CN_Area__c area = new ASI_CRM_CN_Area__c(Name='TEST', ASI_CRM_English_Name__c='TEST', ASI_CRM_Division__c=division.Id);
        insert area;
        
        ASI_CRM_City__c city = new ASI_CRM_City__c(Name='TEST', ASI_CRM_CN_Area__c=area.Id);
        insert city;
        
        /*ASI_CRM_CN_Channel__c channel = new ASI_CRM_CN_Channel__c(Name='KTV',ASI_CRM_BC_Rate__c=98,ASI_CRM_CN_On_Off__c='ON',ASI_CRM_For_Outlet__c=true,RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CN_Channel__cASI_CRM_CN_New_Channel'),ASI_CRM_For_Contract__c=TRUE);
        insert channel;*/
        
        ASI_CRM_CN_Channel__c channel = new ASI_CRM_CN_Channel__c(ASI_CRM_CN_On_Off__c='ON');
        insert channel;
        /*
        Id rtWS = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_CN_WS');
        Id rtOutlet = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN');
        */
        /*list<ASI_CRM_AccountsAdditionalField__c> Customers = new list<ASI_CRM_AccountsAdditionalField__c>();
        Customers.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Commercial_Team__c = 'Premium',RecordTypeId=rtWS,Name='TEST', ASI_CRM_CN_Image__c='Iconic',ASI_CRM_CN_CCity__c=city.Id,ASI_CRM_CN_NewChannel__c=channel.Id));
        Customers.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Commercial_Team__c = 'Premium',RecordTypeId=rtOutlet,Name='TEST', ASI_CRM_CN_Image__c='Iconic',ASI_CRM_CN_CCity__c=city.Id,ASI_CRM_CN_NewChannel__c=channel.Id));
        insert Customers;*/
        
        ASI_MFM_Sub_Channel__c subChannel = new ASI_MFM_Sub_Channel__c(ASI_CRM_CN_Channel__c=channel.Id);
        insert subChannel;
        
        ASI_CRM_CN_Channel__c newChannel = new ASI_CRM_CN_Channel__c(ASI_CRM_For_Outlet__c = true, Name='Restaurant',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CN_Channel__cASI_CRM_CN_New_Channel'),ASI_CRM_CN_On_Off__c='OFF');
        insert newChannel;
        
        list<ASI_CRM_AccountsAdditionalField__c> Customers = new list<ASI_CRM_AccountsAdditionalField__c>();
        Customers.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Eng_Name__c = 'b', ASI_CRM_CN_Chi_Name__c = 'b', ASI_CRM_CN_Commercial_Team__c = 'Premium', ASI_CRM_CN_Sub_Channel__c=subChannel.Id, ASI_CRM_CN_CCity__c=city.Id, ASI_CRM_Latest_Call_Plan_Date__c=system.today(), RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN'), ASI_CRM_CN_NewChannel__c = newChannel.Id, ASI_CRM_CN_Type_of_Restaurant__c = 'International',ASI_CRM_CN_Spending_per_head__c=1));
        Customers.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Eng_Name__c = 'c', ASI_CRM_CN_Chi_Name__c = 'c', ASI_CRM_CN_Commercial_Team__c = 'Premium', ASI_CRM_CN_Sub_Channel__c=subChannel.Id, ASI_CRM_CN_CCity__c=city.Id, ASI_CRM_Latest_Call_Plan_Date__c=system.today(), RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN'), ASI_CRM_CN_NewChannel__c = newChannel.Id, ASI_CRM_CN_Type_of_Restaurant__c = 'International',ASI_CRM_CN_Spending_per_head__c=1));
        insert Customers;
        /*
        list<ASI_CRM_AccountsAdditionalField__c> ChildCustomers = new list<ASI_CRM_AccountsAdditionalField__c>();
        ChildCustomers.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Parent_Outlet__c=Customers[1].Id,ASI_CRM_CN_Eng_Name__c = 'a', ASI_CRM_CN_Chi_Name__c = 'a', ASI_CRM_CN_Commercial_Team__c = 'Premium', ASI_CRM_CN_Sub_Channel__c=subChannel.Id, ASI_CRM_CN_CCity__c=city.Id, ASI_CRM_Latest_Call_Plan_Date__c=system.today(), RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN'), ASI_CRM_CN_NewChannel__c = newChannel.Id, ASI_CRM_CN_Type_of_Restaurant__c = 'International',ASI_CRM_CN_Spending_per_head__c=1));
        insert ChildCustomers;
        */
        User currentUser = [SELECT id, name, Managerid, ASI_CRM_CN_Prefix__c FROM USER WHERE id =:UserInfo.getUserId()];
        
        list<ASI_HK_CRM_Running_Number__c> rns = new list<ASI_HK_CRM_Running_Number__c>();
        rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_TH_CRM_Contract__c', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_TH_CRM_PaymentRequest__c', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        if(!String.isBlank(currentUser.ASI_CRM_CN_Prefix__c))
            rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_'+currentUser.ASI_CRM_CN_Prefix__c, recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        else{
            rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_NULL', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
            rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        }
        insert rns;
        
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User' OR Name = '标准用户']; 
        List<User> LUser = new List<User>();
        LUser.add(new User(Alias = 'standt', Email='standarduser@testorg.com', 
                           EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', ManagerId=userInfo.getUserId(),
                           LocaleSidKey='en_US', ProfileId = p.Id, ASI_CRM_Sales_Team__c = 'a',
                           TimeZoneSidKey='America/Los_Angeles', UserName='standarduser_c1@testing123.com', CompanyName = 'Pernod Ricard China'));
        insert LUser[0];
        
        
        List<User> userList= new List<User> ();
        userList.add(new User(Alias = 'standt', Email='standarduser@testorg.com', 
                              EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                              LocaleSidKey='en_US', ProfileId = p.Id, ManagerID = LUser[0].id,
                              TimeZoneSidKey='America/Los_Angeles', UserName='standarduser_c2@testing123.com', CompanyName = 'Pernod Ricard China', ASI_CRM_Sales_Team__c = 'a'));
        userList.add(new User(Alias = 'standts', Email='standarduser@testorg.com', 
                              EmailEncodingKey='UTF-8', LastName='Testing3', LanguageLocaleKey='en_US', 
                              LocaleSidKey='en_US', ProfileId = p.Id, 
                              TimeZoneSidKey='America/Los_Angeles', UserName='standarduser_c3@testing123.com', CompanyName = 'Pernod Ricard China', ASI_CRM_Sales_Team__c = 'a'));
        
        insert userList;
        
        update new User(Id=LUser[0].id, BypassTriggers__c='');
        //update new User(Id=UserInfo.getUserId(), BypassTriggers__c='');
        /*
        
        List<ASI_CRM_Dynamic_Approval_Route__c> DynamicApprovalRouteList = new List<ASI_CRM_Dynamic_Approval_Route__c>();
        ASI_CRM_Dynamic_Approval_Route__c dar = new ASI_CRM_Dynamic_Approval_Route__c(ASI_CRM_Type__c='Contract',ASI_CRM_Approval_Limit__c=1,ASI_CRM_User__c=LUser[0].id);
        DynamicApprovalRouteList.add(dar);
        ASI_CRM_Dynamic_Approval_Route__c dar2 = new ASI_CRM_Dynamic_Approval_Route__c(ASI_CRM_Type__c='Contract',ASI_CRM_Approval_Limit__c=1,ASI_CRM_User__c=userInfo.getUserId(),ASI_CRM_End_of_Dynamic_Route__c=true);
        DynamicApprovalRouteList.add(dar2);
        
        insert DynamicApprovalRouteList;
        
        list<ASI_CRM_Fix_Approval_Route__c> fars = new list<ASI_CRM_Fix_Approval_Route__c>();
        fars.add(new ASI_CRM_Fix_Approval_Route__c(  ASI_CRM_Sales_Team__c = 'a', ASI_CRM_CN_Approver_1__c = userInfo.getUserId()
                                                   , ASI_CRM_CN_Approver_2__c = userInfo.getUserId()
                                                   , ASI_CRM_CN_Approver_3__c = userInfo.getUserId()
                                                   , ASI_CRM_CN_Approver_4__c = userInfo.getUserId()
                                                   , ASI_CRM_CN_Approver_5__c = userInfo.getUserId()
                                                   , ASI_CRM_CN_Approver_6__c = userInfo.getUserId(), ASI_CRM_CN_Approver_7__c = userInfo.getUserId()
                                                   , ASI_CRM_CN_Approver_8__c = userInfo.getUserId()
                                                   , ASI_CRM_CN_Approver_9__c = userInfo.getUserId()
                                                   , ASI_CRM_CN_Approver_10__c = userList[1].Id
                                                   ,ASI_CRM_RVP__c= userList[1].Id,
                                                   ASI_CRM_CN_Regional_BA__c= userInfo.getUserId()
                                                   , ASI_CRM_CN_Approval_Limit_1__c  = -999999
                                                   , ASI_CRM_CN_Approval_Limit_2__c  = -999999
                                                   , ASI_CRM_CN_Approval_Limit_3__c  = -999999
                                                   , ASI_CRM_CN_Approval_Limit_4__c  = -999999
                                                   , ASI_CRM_CN_Approval_Limit_5__c  = -999999
                                                   , ASI_CRM_CN_Approval_Limit_6__c  = -999999, ASI_CRM_CN_Approval_Limit_7__c = -999999
                                                   , ASI_CRM_CN_Approval_Limit_8__c  = -999999
                                                   , ASI_CRM_CN_Approval_Limit_9__c  = -999999
                                                   , ASI_CRM_CN_Approval_Limit_10__c = -999999
                                                   , ASI_CRM_CN_Approval_Limit_11__c = -999999
                                                   ,ASI_CRM_CN_Type__c = 'Heavy Contract On',ASI_CRM_CN_Region_Area_Channel__c='TEST',ASI_CRM_CN_Entry_Limit__c=-999999));
        
        
        insert fars;
        
        //Sub Brand Grade
        list<ASI_CRM_Sub_Brand_Grade__c> grades = new list<ASI_CRM_Sub_Brand_Grade__c>();
        grades.add(new ASI_CRM_Sub_Brand_Grade__c (Name='Premium',ASI_CRM_Chinese_Name__c='Test1',ASI_CRM_Chinese_Description__c='1. Standard + Premium 标准档 + 高档',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_Sub_Brand_Grade__cASI_CRM_CN_Sub_brand_Grade')));
        grades.add(new ASI_CRM_Sub_Brand_Grade__c (Name='TEST2',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_Sub_Brand_Grade__cASI_CRM_CN_Sub_brand_Grade')));
        grades.add(new ASI_CRM_Sub_Brand_Grade__c (Name='TEST3',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_Sub_Brand_Grade__cASI_CRM_CN_Sub_brand_Grade')));
        insert grades;
        
        
        list<ASI_MFM_Sub_brand__c> subBrands = new list<ASI_MFM_Sub_brand__c>();
        for(ASI_CRM_Sub_Brand_Grade__c grade :grades) {
            subBrands.add(new ASI_MFM_Sub_brand__c (Name='TEST1',ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,RecordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand'),
                                                    ASI_CRM_CN_Sub_brand_Grade__c=grade.Id));
            subBrands.add(new ASI_MFM_Sub_brand__c (Name='TEST2',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand'),
                                                    ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,
                                                    ASI_CRM_CN_Sub_brand_Grade__c=grade.Id));
            subBrands.add(new ASI_MFM_Sub_brand__c ( Name='TEST3',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand'),
                                                    ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,
                                                    ASI_CRM_CN_Sub_brand_Grade__c=grade.Id));
            subBrands.add(new ASI_MFM_Sub_brand__c ( Name='999',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand'),
                                                    ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,ASI_MFM_Sub_brand_Code__c = '999' ,ASI_MFM_Active_for_CRM__c = true ,
                                                    ASI_CRM_CN_Sub_brand_Grade__c=grade.Id));
        }
        insert subBrands;
        
        */
        Date PO_Start_Date = date.newinstance(system.today().year(), system.today().month(), 1);
        Date PO_End_Date = PO_Start_Date.addMonths(1)-1;
        
       
        List<ASI_TH_CRM_Contract__c> ContractList = new List<ASI_TH_CRM_Contract__c> ();
        ASI_TH_CRM_Contract__c Contract = new ASI_TH_CRM_Contract__c(recordtypeid = Global_RecordTypeCache.getRTID('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract'),
                                                                     ASI_CRM_CN_Status__c = 'Submitted',ownerId = userList[0].id,ASI_CRM_System_Debug__c=true,
                                                                     ASI_CRM_CN_PO_Start_Date__c = PO_Start_Date,
                                                                     ASI_CRM_RVP_Approval__c = true,
                                                                     ASI_CRM_CN_PO_End_Date__c =PO_End_Date,
                                                                     ASI_CRM_CN_PO_Version__c = '0.0',ASI_TH_CRM_Promotion_Type__c='Heavy Contract On',
                                                                     Name = 'Contract1',
                                                                     ASI_CRM_CN_Outlet_WS__c=Customers[1].Id,ASI_CRM_Volume_Option__c = 'Normal');
        ContractList.add(Contract);
        ASI_TH_CRM_Contract__c Contract2 = new ASI_TH_CRM_Contract__c(recordtypeid = Global_RecordTypeCache.getRTID('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract'),
                                                                      ASI_CRM_CN_Status__c = 'Draft',ownerId = LUser[0].id,ASI_CRM_System_Debug__c=true,
                                                                      ASI_CRM_CN_PO_Start_Date__c = PO_Start_Date.addYears(1),
                                                                      ASI_CRM_CN_PO_End_Date__c =PO_End_Date.addYears(1),
                                                                      ASI_CRM_CN_PO_Version__c = '0.0',ASI_TH_CRM_Promotion_Type__c='Heavy Contract On',
                                                                      Name = 'Contract2',
                                                                      ASI_CRM_CN_Outlet_WS__c=Customers[1].Id,ASI_CRM_Volume_Option__c = 'Normal');
        ContractList.add(Contract2);
        insert ContractList;
        /*
        List<ASI_CRM_Module__c> ModuleList = new List<ASI_CRM_Module__c>();
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='Std. Btl.',ASI_CRM_Volume_Base__c='By Sub-Brand',ASI_CRM_Line_Type__c='BRSF'));
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='Std. Btl.',ASI_CRM_Volume_Base__c='By Sub-Brand',ASI_CRM_Line_Type__c='PSF'));
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='CR12 Extra Eqv.',ASI_CRM_Volume_Base__c='By Grade',ASI_CRM_Line_Type__c='PSF'));
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='CR12 Extra Eqv.',ASI_CRM_Volume_Base__c='By Total',ASI_CRM_Line_Type__c='PSF'));
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='CR12 Extra Eqv.',ASI_CRM_Volume_Base__c='By Total',ASI_CRM_Line_Type__c='Variable Event Cost'));
        
        insert ModuleList;
        */
        ASI_CRM_Contract_Cost__c contractCost = new ASI_CRM_Contract_Cost__c(ASI_CRM_CN_Contract__c = Contract.id,
                                                                             ASI_CRM_CN_Estimate_Amount__c = 100000,
                                                                             ASI_CRM_CN_Cost_Type__c = 'Fixed',
                                                                             ASI_CRM_CN_Other_Cost_Payment_Request__c = true,
                                                                             recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_Contract_Cost__cASI_CRM_CN_Contract_Cost') );
        insert contractCost;
        /*
        list<ASI_CRM_CN_Contract_BRSF_Line_Item__c> ContractLineList = new list<ASI_CRM_CN_Contract_BRSF_Line_Item__c>();
        list<ASI_CRM_CN_Covered_Outlet__c> cos = new list<ASI_CRM_CN_Covered_Outlet__c>();
        for(ASI_MFM_Sub_brand__c subBrand :subBrands) {
            ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract.Id,
                                                                           ASI_CRM_CN_Est_Monthly_Qty__c=1,ASI_CRM_Module__c=ModuleList[0].Id,
                                                                           ASI_CRM_CN_Contract_Monthly_Qty__c=1,
                                                                           ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,ASI_CRM_CN_Est_Total_Dummy__c=100,ASI_CRM_CN_Contract_Total_Dummy__c=100,
                                                                           ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,ASI_CRM_Type__c='BRSF',
                                                                           ASI_CRM_CN_Sub_Brand__c=subBrand.Id,
                                                                           recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF')));
        }
        ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract.Id,ASI_CRM_Type__c='PSF',ASI_CRM_Volume_Base__c='By Sub-Brand',
                                                                       ASI_CRM_CN_Est_Monthly_Qty__c=1,ASI_CRM_Module__c=ModuleList[1].Id,
                                                                       ASI_CRM_CN_Contract_Monthly_Qty__c=1,
                                                                       ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,ASI_CRM_CN_Est_Total_Dummy__c=100,ASI_CRM_CN_Contract_Total_Dummy__c=100,
                                                                       ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,
                                                                       ASI_CRM_CN_Sub_Brand__c=subBrands[0].Id,
                                                                       recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF') ));
        ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract.Id,ASI_CRM_Type__c='PSF',ASI_CRM_Volume_Base__c='By Grade',
                                                                       ASI_CRM_CN_Est_Monthly_Qty__c=1,ASI_CRM_Module__c=ModuleList[2].Id,
                                                                       ASI_CRM_CN_Contract_Monthly_Qty__c=1,ASI_CRM_Sub_Brand_Grade__c=grades[0].Id,
                                                                       ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,ASI_CRM_CN_Est_Total_Dummy__c=100,ASI_CRM_CN_Contract_Total_Dummy__c=100,
                                                                       ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,
                                                                       ASI_CRM_CN_Sub_Brand__c=null,
                                                                       recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF') ));
        ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract.Id,ASI_CRM_Type__c='PSF',ASI_CRM_Volume_Base__c='By Total',
                                                                       ASI_CRM_CN_Est_Monthly_Qty__c=1,ASI_CRM_Module__c=ModuleList[3].Id,
                                                                       ASI_CRM_CN_Contract_Monthly_Qty__c=1,ASI_CRM_CN_Est_Total_Dummy__c=100,ASI_CRM_CN_Contract_Total_Dummy__c=100,
                                                                       ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,
                                                                       ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,
                                                                       ASI_CRM_CN_Sub_Brand__c=null,
                                                                       recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF') ));
        
        ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract.Id,ASI_CRM_Type__c='Variable Event Cost',ASI_CRM_Volume_Base__c='By Total',
                                                                       ASI_CRM_CN_Est_Monthly_Qty__c=1,ASI_CRM_Module__c=ModuleList[4].Id,
                                                                       ASI_CRM_CN_Contract_Monthly_Qty__c=1,ASI_CRM_CN_Est_Total_Dummy__c=100,ASI_CRM_CN_Contract_Total_Dummy__c=100,
                                                                       ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,
                                                                       ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,
                                                                       ASI_CRM_CN_Sub_Brand__c=null,
                                                                       recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF') ));
        insert ContractLineList;
        
        
        
        
        */      
         List<ASI_CRM_Contract_Cost_Setting__c> ContractCostSettingList= new List<ASI_CRM_Contract_Cost_Setting__c>();
        
        ContractCostSettingList.add(new ASI_CRM_Contract_Cost_Setting__c(ASI_CRM_CN_Promotion_Type__c='Heavy Contract ON',
                                                                         ASI_CRM_CN_Fixed_Cost_Contract__c=true,ASI_CRM_CN_Variable_Cost_Contract__c=true));
        
        ContractCostSettingList.add(new ASI_CRM_Contract_Cost_Setting__c(ASI_CRM_CN_Promotion_Type__c='Heavy Contract ON',ASI_CRM_CN_Variable_Cost_Contract__c=true,
                                                                         ASI_CRM_CN_Fixed_Cost_Contract__c=false,ASI_CRM_CN_BRSF_Activity_Code_Default__c=true));
        
        ContractCostSettingList.add(new ASI_CRM_Contract_Cost_Setting__c(ASI_CRM_CN_Promotion_Type__c='Heavy Contract ON',ASI_CRM_CN_Variable_Cost_Contract__c=true,
                                                                         ASI_CRM_CN_Fixed_Cost_Contract__c=false,ASI_CRM_PSF_Activity_Code_Default__c=true));
        
        ContractCostSettingList.add(new ASI_CRM_Contract_Cost_Setting__c(ASI_CRM_CN_Promotion_Type__c='Heavy Contract ON',ASI_CRM_CN_Variable_Cost_Contract__c=true,
                                                                         ASI_CRM_CN_Fixed_Cost_Contract__c=false,ASI_CRM_VEC_Activity_Code_Defaul__c=true));
        
        insert ContractCostSettingList;
        
        /*if([select count() from ProcessInstance where targetobjectid=:Contract.id] < 1)
        {       
            Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
            req.setComments('Approve.');
            req.setNextApproverIds(new Id[] {UserInfo.getUserId()});
            req.setObjectId(Contract.Id);

            //Submit the approval request
            Approval.ProcessResult result = Approval.process(req);

        }*/
        
        
        /*
        ProcessDefinition pd = [SELECT id FROM ProcessDefinition LIMIT 1];
        ProcessNode pn = [SELECT Id, Name, DeveloperName, ProcessDefinitionId FROM ProcessNode WHERE ProcessDefinitionId =: pd.Id LIMIT 1];
        
        ProcessInstance pi = new ProcessInstance();
        pi.TargetObjectId = Contract.Id;
        pi.ProcessDefinitionId = pd.Id;
        //pi.CurrentNodeId = pn.Id;
        pi.Status = 'Rejected';
        insert pi;
        
        ProcessInstanceStep pis = new ProcessInstanceStep();
        pis.ProcessInstanceId = pi.Id;
        pis.StepStatus = 'Rejected';
        insert pis;
        */
        test.startTest();
        //trigger: ASI_CRM_CN_HeavyContract_TriggerClass
        Contract.ASI_CRM_CN_Status__c='Submitted';
        update Contract;
        
        Contract.ASI_CRM_CN_Status__c='Draft';
        Contract.ASI_CRM_RVP_Approval__c=true;
        update Contract;
        
        Contract.ASI_CRM_CN_Return_Flag__c=true;
        update Contract;
        
        Contract.ASI_CRM_RVP_Approval__c=false;
        //Contract.CreatedDate=null;
        update Contract;
        
        
        test.stopTest(); 
        
    }
    
    static testMethod void ASI_CRM_CN_ViewHeavyContractCtrlTest1() {
        //Test Class for ASI_CRM_CN_ViewHeavyContractCtrl
        ASI_CRM_Region__c region = new ASI_CRM_Region__c (Name='Central Region',recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Region__cASI_CRM_CN_Region'));
        insert region;
        
        ASI_CRM_Division__c division = new ASI_CRM_Division__c(Name='TEST', ASI_CRM_Region__c=region.Id);
        insert division;
        
        ASI_CRM_CN_Area__c area = new ASI_CRM_CN_Area__c(Name='TEST', ASI_CRM_English_Name__c='TEST', ASI_CRM_Division__c=division.Id);
        insert area;
        
        ASI_CRM_City__c city = new ASI_CRM_City__c(Name='TEST', ASI_CRM_CN_Area__c=area.Id);
        insert city;
        
        /*ASI_CRM_CN_Channel__c channel = new ASI_CRM_CN_Channel__c(Name='KTV',ASI_CRM_BC_Rate__c=98,ASI_CRM_CN_On_Off__c='ON',ASI_CRM_For_Outlet__c=true,RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CN_Channel__cASI_CRM_CN_New_Channel'),ASI_CRM_For_Contract__c=TRUE);
        insert channel;*/
        
        ASI_CRM_CN_Channel__c channel = new ASI_CRM_CN_Channel__c(ASI_CRM_CN_On_Off__c='ON');
        insert channel;
        
        Id rtWS = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_CN_WS');
        Id rtOutlet = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN');
        
        /*list<ASI_CRM_AccountsAdditionalField__c> Customers = new list<ASI_CRM_AccountsAdditionalField__c>();
        Customers.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Commercial_Team__c = 'Premium',RecordTypeId=rtWS,Name='TEST', ASI_CRM_CN_Image__c='Iconic',ASI_CRM_CN_CCity__c=city.Id,ASI_CRM_CN_NewChannel__c=channel.Id));
        Customers.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Commercial_Team__c = 'Premium',RecordTypeId=rtOutlet,Name='TEST', ASI_CRM_CN_Image__c='Iconic',ASI_CRM_CN_CCity__c=city.Id,ASI_CRM_CN_NewChannel__c=channel.Id));
        insert Customers;

        //Covered_Outlet
        list<ASI_CRM_AccountsAdditionalField__c> ChildCustomers = new list<ASI_CRM_AccountsAdditionalField__c>();
        ChildCustomers.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Parent_Outlet__c=Customers[1].Id,ASI_CRM_CN_Commercial_Team__c = 'Premium',RecordTypeId=rtOutlet,Name='TEST', ASI_CRM_CN_Image__c='Iconic',ASI_CRM_CN_CCity__c=city.Id,ASI_CRM_CN_NewChannel__c=channel.Id));
        insert ChildCustomers;*/
        
        ASI_MFM_Sub_Channel__c subChannel = new ASI_MFM_Sub_Channel__c(ASI_CRM_CN_Channel__c=channel.Id);
        insert subChannel;
        
        ASI_CRM_CN_Channel__c newChannel = new ASI_CRM_CN_Channel__c(ASI_CRM_For_Outlet__c = true, Name='Restaurant',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CN_Channel__cASI_CRM_CN_New_Channel'),ASI_CRM_CN_On_Off__c='OFF');
        insert newChannel;
        
        list<ASI_CRM_AccountsAdditionalField__c> Customers = new list<ASI_CRM_AccountsAdditionalField__c>();
        Customers.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Eng_Name__c = 'b', ASI_CRM_CN_Chi_Name__c = 'b', ASI_CRM_CN_Commercial_Team__c = 'Premium', ASI_CRM_CN_Sub_Channel__c=subChannel.Id, ASI_CRM_CN_CCity__c=city.Id, ASI_CRM_Latest_Call_Plan_Date__c=system.today(), RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN'), ASI_CRM_CN_NewChannel__c = newChannel.Id, ASI_CRM_CN_Type_of_Restaurant__c = 'International',ASI_CRM_CN_Spending_per_head__c=1));
        Customers.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Eng_Name__c = 'c', ASI_CRM_CN_Chi_Name__c = 'c', ASI_CRM_CN_Commercial_Team__c = 'Premium', ASI_CRM_CN_Sub_Channel__c=subChannel.Id, ASI_CRM_CN_CCity__c=city.Id, ASI_CRM_Latest_Call_Plan_Date__c=system.today(), RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN'), ASI_CRM_CN_NewChannel__c = newChannel.Id, ASI_CRM_CN_Type_of_Restaurant__c = 'International',ASI_CRM_CN_Spending_per_head__c=1));
        insert Customers;
        
        
        list<ASI_CRM_AccountsAdditionalField__c> ChildCustomers = new list<ASI_CRM_AccountsAdditionalField__c>();
        ChildCustomers.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Parent_Outlet__c=Customers[1].Id,ASI_CRM_CN_Eng_Name__c = 'a', ASI_CRM_CN_Chi_Name__c = 'a', ASI_CRM_CN_Commercial_Team__c = 'Premium', ASI_CRM_CN_Sub_Channel__c=subChannel.Id, ASI_CRM_CN_CCity__c=city.Id, ASI_CRM_Latest_Call_Plan_Date__c=system.today(), RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN'), ASI_CRM_CN_NewChannel__c = newChannel.Id, ASI_CRM_CN_Type_of_Restaurant__c = 'International',ASI_CRM_CN_Spending_per_head__c=1));
        insert ChildCustomers;
        
        // list<ASI_CRM_AccountsAdditionalField__c> ChildChildCustomers = new list<ASI_CRM_AccountsAdditionalField__c>();
        //ChildChildCustomers.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Parent_Outlet__c=ChildCustomers[0].Id,ASI_CRM_CN_Commercial_Team__c = 'Premium',RecordTypeId=rtOutlet,Name='TEST', ASI_CRM_CN_Image__c='Iconic',ASI_CRM_CN_CCity__c=city.Id,ASI_CRM_CN_NewChannel__c=channel.Id));
        //insert ChildChildCustomers;
        
        //ASI_CRM_CN_Parent_Outlet__c
        
        User currentUser = [SELECT id, name, Managerid, ASI_CRM_CN_Prefix__c FROM USER WHERE id =:UserInfo.getUserId()];
        
        list<ASI_HK_CRM_Running_Number__c> rns = new list<ASI_HK_CRM_Running_Number__c>();
        rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_TH_CRM_Contract__c', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_TH_CRM_PaymentRequest__c', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        if(!String.isBlank(currentUser.ASI_CRM_CN_Prefix__c))
            rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_'+currentUser.ASI_CRM_CN_Prefix__c, recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        else{
            rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_NULL', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
            rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        }
        insert rns;
        
        //Sub Brand Grade
        //
        list<ASI_CRM_Sub_Brand_Grade__c> grades = new list<ASI_CRM_Sub_Brand_Grade__c>();
        grades.add(new ASI_CRM_Sub_Brand_Grade__c (Name='Premium',ASI_CRM_Chinese_Name__c='Test1',ASI_CRM_Chinese_Description__c='1. Standard + Premium 标准档 + 高档',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_Sub_Brand_Grade__cASI_CRM_CN_Sub_brand_Grade')));
        grades.add(new ASI_CRM_Sub_Brand_Grade__c (Name='TEST2',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_Sub_Brand_Grade__cASI_CRM_CN_Sub_brand_Grade')));
        grades.add(new ASI_CRM_Sub_Brand_Grade__c (Name='TEST3',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_Sub_Brand_Grade__cASI_CRM_CN_Sub_brand_Grade')));
        insert grades;
        
        
        list<ASI_MFM_Sub_brand__c> subBrands = new list<ASI_MFM_Sub_brand__c>();
        for(ASI_CRM_Sub_Brand_Grade__c grade :grades) {
            subBrands.add(new ASI_MFM_Sub_brand__c (Name='TEST1',ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,RecordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand'),
                                                    ASI_CRM_CN_Sub_brand_Grade__c=grade.Id));
            subBrands.add(new ASI_MFM_Sub_brand__c (Name='TEST2',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand'),
                                                    ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,
                                                    ASI_CRM_CN_Sub_brand_Grade__c=grade.Id));
            subBrands.add(new ASI_MFM_Sub_brand__c ( Name='TEST3',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand'),
                                                    ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,
                                                    ASI_CRM_CN_Sub_brand_Grade__c=grade.Id));
            subBrands.add(new ASI_MFM_Sub_brand__c ( Name='999',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand'),
                                                    ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,ASI_MFM_Sub_brand_Code__c = '999' ,ASI_MFM_Active_for_CRM__c = true ,
                                                    ASI_CRM_CN_Sub_brand_Grade__c=grade.Id));
        }
        insert subBrands;
        
        
        Date PO_Start_Date = date.newinstance(system.today().year(), system.today().month(), 1);
        Date PO_End_Date = PO_Start_Date.addMonths(1)-1;
        
        ASI_TH_CRM_Contract__c Contract = new ASI_TH_CRM_Contract__c(recordtypeid = Global_RecordTypeCache.getRTID('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract'),
                                                                     ASI_CRM_CN_Status__c = 'Final',
                                                                     ASI_CRM_CN_PO_Start_Date__c = PO_Start_Date,
                                                                     ASI_CRM_CN_PO_End_Date__c =PO_End_Date,
                                                                     ASI_CRM_CN_PO_Version__c = '0.0',ASI_TH_CRM_Promotion_Type__c='Heavy Contract On',
                                                                     Name = 'Contract1',
                                                                     ASI_CRM_CN_Outlet_WS__c=Customers[1].Id,ASI_CRM_Volume_Option__c = 'Normal');
        insert Contract;
        /*
        List<ASI_CRM_Module__c> ModuleList = new List<ASI_CRM_Module__c>();
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='Std. Btl.',ASI_CRM_Volume_Base__c='By Sub-Brand',ASI_CRM_Line_Type__c='BRSF'));
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='Std. Btl.',ASI_CRM_Volume_Base__c='By Sub-Brand',ASI_CRM_Line_Type__c='PSF'));
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='CR12 Extra Eqv.',ASI_CRM_Volume_Base__c='By Grade',ASI_CRM_Line_Type__c='PSF'));
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='CR12 Extra Eqv.',ASI_CRM_Volume_Base__c='By Total',ASI_CRM_Line_Type__c='PSF'));
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='CR12 Extra Eqv.',ASI_CRM_Volume_Base__c='By Total',ASI_CRM_Line_Type__c='Variable Event Cost'));
        
        insert ModuleList;
        */
        ASI_CRM_Contract_Cost__c contractCost = new ASI_CRM_Contract_Cost__c(ASI_CRM_CN_Contract__c = Contract.id,
                                                                             ASI_CRM_CN_Estimate_Amount__c = 100000,
                                                                             ASI_CRM_CN_Cost_Type__c = 'Fixed',
                                                                             ASI_CRM_CN_Other_Cost_Payment_Request__c = true,
                                                                             recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_Contract_Cost__cASI_CRM_CN_Contract_Cost') );
        insert contractCost;
        /*
        list<ASI_CRM_CN_Contract_BRSF_Line_Item__c> ContractLineList = new list<ASI_CRM_CN_Contract_BRSF_Line_Item__c>();
        list<ASI_CRM_CN_Covered_Outlet__c> cos = new list<ASI_CRM_CN_Covered_Outlet__c>();
        for(ASI_MFM_Sub_brand__c subBrand :subBrands) {
            ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract.Id,
                                                                           ASI_CRM_CN_Est_Monthly_Qty__c=1,ASI_CRM_Module__c=ModuleList[0].Id,
                                                                           ASI_CRM_CN_Contract_Monthly_Qty__c=1,
                                                                           ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,
                                                                           ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,ASI_CRM_Type__c='BRSF',
                                                                           ASI_CRM_CN_Sub_Brand__c=subBrand.Id,
                                                                           recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF')));
        }
        ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract.Id,ASI_CRM_Type__c='PSF',ASI_CRM_Volume_Base__c='By Sub-Brand',
                                                                       ASI_CRM_CN_Est_Monthly_Qty__c=1,ASI_CRM_Module__c=ModuleList[1].Id,
                                                                       ASI_CRM_CN_Contract_Monthly_Qty__c=1,
                                                                       ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,
                                                                       ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,
                                                                       ASI_CRM_CN_Sub_Brand__c=subBrands[0].Id,
                                                                       recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF') ));
        ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract.Id,ASI_CRM_Type__c='PSF',ASI_CRM_Volume_Base__c='By Grade',
                                                                       ASI_CRM_CN_Est_Monthly_Qty__c=1,ASI_CRM_Module__c=ModuleList[2].Id,
                                                                       ASI_CRM_CN_Contract_Monthly_Qty__c=1,ASI_CRM_Sub_Brand_Grade__c=grades[0].Id,
                                                                       ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,
                                                                       ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,
                                                                       ASI_CRM_CN_Sub_Brand__c=null,
                                                                       recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF') ));
        ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract.Id,ASI_CRM_Type__c='PSF',ASI_CRM_Volume_Base__c='By Total',
                                                                       ASI_CRM_CN_Est_Monthly_Qty__c=1,ASI_CRM_Module__c=ModuleList[3].Id,
                                                                       ASI_CRM_CN_Contract_Monthly_Qty__c=1,
                                                                       ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,
                                                                       ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,
                                                                       ASI_CRM_CN_Sub_Brand__c=null,
                                                                       recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF') ));
        
        ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract.Id,ASI_CRM_Type__c='Variable Event Cost',ASI_CRM_Volume_Base__c='By Total',
                                                                       
                                                                       ASI_CRM_CN_Contract_Monthly_Qty__c=1,
                                                                       ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,
                                                                       ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,
                                                                       ASI_CRM_CN_Sub_Brand__c=null,
                                                                       recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF') ));
        insert ContractLineList;
        */
        
        test.startTest();
        
        
        PageReference EnterPage = Page.ASI_CRM_CN_ViewHeavyContractPage;
        
        Map<String, String> pageParams = EnterPage.getParameters();
        
        pageParams.put('id', Contract.id);
        ApexPages.StandardController sc = new ApexPages.standardController(new ASI_TH_CRM_Contract__c());
        
        ASI_CRM_CN_ViewHeavyContractCtrl con = new ASI_CRM_CN_ViewHeavyContractCtrl(new ApexPages.Standardcontroller(Contract));
        con.ContractSelected.ASI_CRM_CN_Expected_BRSF_Est_Total__c=10;
        con.ContractSelected.ASI_CRM_EVC_Cost_Estimate_Total__c=100;
        con.AddAllChildOutlets();
        con.SaveItems();
        
        con.AddNew_CoveredOutlet();
        con.GoEditDetailPage();
        con.GoCheckPointPage();
        con.GoEditHeaderPage();
        con.ViewCheckPointPage();
        con.GoEditDetailPage();
        con.POModification();
        con.GoPayment();
        con.GoReturn();
        con.UploadCompletion();
        con.Calculation();
        con.UncheckContractUploading();
        con.SetToFinal();
        con.CancelProcess();
        con.restorePO();
        test.stopTest(); 
    }
    
    static testMethod void ASI_CRM_CN_ViewHeavyContractCtrlTest2() {
        //Test Class for ASI_CRM_CN_ViewHeavyContractCtrl
        ASI_CRM_Region__c region = new ASI_CRM_Region__c (Name='Central Region',recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Region__cASI_CRM_CN_Region'));
        insert region;
        
        ASI_CRM_Division__c division = new ASI_CRM_Division__c(Name='TEST', ASI_CRM_Region__c=region.Id);
        insert division;
        
        ASI_CRM_CN_Area__c area = new ASI_CRM_CN_Area__c(Name='TEST', ASI_CRM_English_Name__c='TEST', ASI_CRM_Division__c=division.Id);
        insert area;
        
        ASI_CRM_City__c city = new ASI_CRM_City__c(Name='TEST', ASI_CRM_CN_Area__c=area.Id);
        insert city;
        
        
        /*ASI_CRM_CN_Channel__c channel = new ASI_CRM_CN_Channel__c(Name='KTV',ASI_CRM_BC_Rate__c=98,ASI_CRM_CN_On_Off__c='ON',ASI_CRM_For_Outlet__c=true,RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CN_Channel__cASI_CRM_CN_New_Channel'),ASI_CRM_For_Contract__c=TRUE);
        insert channel;*/
        
        ASI_CRM_CN_Channel__c channel = new ASI_CRM_CN_Channel__c(ASI_CRM_CN_On_Off__c='ON');
        insert channel;
        
        Id rtWS = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_CN_WS');
        Id rtOutlet = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN');
        
        /*list<ASI_CRM_AccountsAdditionalField__c> Customers = new list<ASI_CRM_AccountsAdditionalField__c>();
        Customers.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Commercial_Team__c = 'Premium',RecordTypeId=rtWS,Name='TEST', ASI_CRM_CN_Image__c='Iconic',ASI_CRM_CN_CCity__c=city.Id,ASI_CRM_CN_NewChannel__c=channel.Id));
        Customers.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Commercial_Team__c = 'Premium',RecordTypeId=rtOutlet,Name='TEST', ASI_CRM_CN_Image__c='Iconic',ASI_CRM_CN_CCity__c=city.Id,ASI_CRM_CN_NewChannel__c=channel.Id));
        insert Customers;*/
        
        ASI_MFM_Sub_Channel__c subChannel = new ASI_MFM_Sub_Channel__c(ASI_CRM_CN_Channel__c=channel.Id);
        insert subChannel;
        
        ASI_CRM_CN_Channel__c newChannel = new ASI_CRM_CN_Channel__c(ASI_CRM_For_Outlet__c = true, Name='Restaurant',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CN_Channel__cASI_CRM_CN_New_Channel'),ASI_CRM_CN_On_Off__c='OFF');
        insert newChannel;
        
        list<ASI_CRM_AccountsAdditionalField__c> Customers = new list<ASI_CRM_AccountsAdditionalField__c>();
        Customers.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Eng_Name__c = 'b', ASI_CRM_CN_Chi_Name__c = 'b', ASI_CRM_CN_Commercial_Team__c = 'Premium', ASI_CRM_CN_Sub_Channel__c=subChannel.Id, ASI_CRM_CN_CCity__c=city.Id, ASI_CRM_Latest_Call_Plan_Date__c=system.today(), RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN'), ASI_CRM_CN_NewChannel__c = newChannel.Id, ASI_CRM_CN_Type_of_Restaurant__c = 'International',ASI_CRM_CN_Spending_per_head__c=1));
        Customers.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Eng_Name__c = 'c', ASI_CRM_CN_Chi_Name__c = 'c', ASI_CRM_CN_Commercial_Team__c = 'Premium', ASI_CRM_CN_Sub_Channel__c=subChannel.Id, ASI_CRM_CN_CCity__c=city.Id, ASI_CRM_Latest_Call_Plan_Date__c=system.today(), RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN'), ASI_CRM_CN_NewChannel__c = newChannel.Id, ASI_CRM_CN_Type_of_Restaurant__c = 'International',ASI_CRM_CN_Spending_per_head__c=1));
        insert Customers;
        
        list<ASI_CRM_AccountsAdditionalField__c> ChildCustomers = new list<ASI_CRM_AccountsAdditionalField__c>();
        ChildCustomers.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Parent_Outlet__c=Customers[1].Id,ASI_CRM_CN_Eng_Name__c = 'a', ASI_CRM_CN_Chi_Name__c = 'a', ASI_CRM_CN_Commercial_Team__c = 'Premium', ASI_CRM_CN_Sub_Channel__c=subChannel.Id, ASI_CRM_CN_CCity__c=city.Id, ASI_CRM_Latest_Call_Plan_Date__c=system.today(), RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN'), ASI_CRM_CN_NewChannel__c = newChannel.Id, ASI_CRM_CN_Type_of_Restaurant__c = 'International',ASI_CRM_CN_Spending_per_head__c=1));
        insert ChildCustomers;
        
        User currentUser = [SELECT id, name, Managerid, ASI_CRM_CN_Prefix__c FROM USER WHERE id =:UserInfo.getUserId()];
        
        list<ASI_HK_CRM_Running_Number__c> rns = new list<ASI_HK_CRM_Running_Number__c>();
        rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_TH_CRM_Contract__c', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_TH_CRM_PaymentRequest__c', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        if(!String.isBlank(currentUser.ASI_CRM_CN_Prefix__c))
            rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_'+currentUser.ASI_CRM_CN_Prefix__c, recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        else{
            rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_NULL', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
            rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        }
        insert rns;
        
        //Sub Brand Grade
        list<ASI_CRM_Sub_Brand_Grade__c> grades = new list<ASI_CRM_Sub_Brand_Grade__c>();
        grades.add(new ASI_CRM_Sub_Brand_Grade__c (Name='TEST1'));
        grades.add(new ASI_CRM_Sub_Brand_Grade__c (Name='TEST2'));
        grades.add(new ASI_CRM_Sub_Brand_Grade__c (Name='TEST3'));
        insert grades;
        
        
        list<ASI_MFM_Sub_brand__c> subBrands = new list<ASI_MFM_Sub_brand__c>();
        for(ASI_CRM_Sub_Brand_Grade__c grade :grades) {
            subBrands.add(new ASI_MFM_Sub_brand__c (Name='TEST1',ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,RecordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand'),
                                                    ASI_CRM_CN_Sub_brand_Grade__c=grade.Id));
            subBrands.add(new ASI_MFM_Sub_brand__c (Name='TEST2',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand'),
                                                    ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,
                                                    ASI_CRM_CN_Sub_brand_Grade__c=grade.Id));
            subBrands.add(new ASI_MFM_Sub_brand__c ( Name='TEST3',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand'),
                                                    ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,
                                                    ASI_CRM_CN_Sub_brand_Grade__c=grade.Id));
            subBrands.add(new ASI_MFM_Sub_brand__c ( Name='TEST4',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand'),
                                                    ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,
                                                    ASI_CRM_CN_Sub_brand_Grade__c=grade.Id));
        }
        insert subBrands;
        
        
        Date PO_Start_Date = date.newinstance(system.today().year(), system.today().month(), 1);
        Date PO_End_Date = PO_Start_Date.addMonths(1)-1;
        
        ASI_TH_CRM_Contract__c Contract = new ASI_TH_CRM_Contract__c(recordtypeid = Global_RecordTypeCache.getRTID('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract'),
                                                                     ASI_CRM_CN_Status__c = 'Final',ASI_CRM_System_Debug__c=true,
                                                                     ASI_CRM_CN_PO_Start_Date__c = PO_Start_Date,
                                                                     ASI_CRM_CN_PO_End_Date__c =PO_End_Date,
                                                                     ASI_CRM_CN_PO_Version__c = '0.0',ASI_TH_CRM_Promotion_Type__c='Heavy Contract On',
                                                                     Name = 'Contract1',
                                                                     ASI_CRM_CN_Outlet_WS__c=Customers[0].Id,ASI_CRM_Volume_Option__c = 'Normal'
                                                                    );
        insert Contract;
        
        ASI_CRM_Contract_Cost__c contractCost = new ASI_CRM_Contract_Cost__c(ASI_CRM_CN_Contract__c = Contract.id,
                                                                             ASI_CRM_CN_Estimate_Amount__c = 100000,
                                                                             ASI_CRM_CN_Cost_Type__c = 'Variable',
                                                                             ASI_CRM_CN_Other_Cost_Payment_Request__c = true,
                                                                             recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_Contract_Cost__cASI_CRM_CN_Contract_Cost') );
        insert contractCost;
        
        ASI_CRM_CN_Covered_Outlet__c co = new ASI_CRM_CN_Covered_Outlet__c();
        co.ASI_CRM_CN_Contract__c = Contract.Id;
        insert co;  
        
        List<ASI_CRM_Methodology__c> MethodologyList= new List<ASI_CRM_Methodology__c> ();
        MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test1',ASI_CRM_Methodology_Code__c='01',ASI_CRM_Default__c=true,ASI_CRM_Chinese_Name__c='123',ASI_CRM_Type__c='BRSF',recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Methodology__cASI_CRM_CN_Methodology')));
        MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test2',ASI_CRM_Methodology_Code__c='01',ASI_CRM_Default__c=true,ASI_CRM_Chinese_Name__c='Test 123',ASI_CRM_Type__c='PSF',recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Methodology__cASI_CRM_CN_Methodology')));
        MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test3',ASI_CRM_Methodology_Code__c='01',ASI_CRM_Default__c=true,ASI_CRM_Chinese_Name__c='Test 123',ASI_CRM_Type__c='Variable Event Cost',recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Methodology__cASI_CRM_CN_Methodology')));
        
        
       // MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test1',ASI_CRM_Methodology_Code__c='01',ASI_CRM_Chinese_Name__c='123',ASI_CRM_Type__c='BRSF'));
       // MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test2',ASI_CRM_Methodology_Code__c='01',ASI_CRM_Chinese_Name__c='123',ASI_CRM_Type__c='PSF'));
       // MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test3',ASI_CRM_Methodology_Code__c='01',ASI_CRM_Chinese_Name__c='123',ASI_CRM_Type__c='Variable Event Cost'));
        insert MethodologyList;
        
        test.startTest();
        
        
        PageReference EnterPage = Page.ASI_CRM_CN_ViewHeavyContractPage;
        Test.setCurrentPage(EnterPage);
        Map<String, String> pageParams = EnterPage.getParameters();
        
        pageParams.put('id', Contract.id);
        ApexPages.StandardController sc = new ApexPages.standardController(new ASI_TH_CRM_Contract__c());
        
        ASI_CRM_CN_ViewHeavyContractCtrl con = new ASI_CRM_CN_ViewHeavyContractCtrl(new ApexPages.Standardcontroller(Contract));
        
        con.Calculation();
        
        test.stopTest(); 
    }
    
    static testMethod void ASI_CRM_CN_ViewHeavyContractCtrlTest3() {
        //Test Class for ASI_CRM_CN_ViewHeavyContractCtrl
        ASI_CRM_Region__c region = new ASI_CRM_Region__c (Name='Central Region',recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Region__cASI_CRM_CN_Region'));
        insert region;
        
        ASI_CRM_Division__c division = new ASI_CRM_Division__c(Name='TEST', ASI_CRM_Region__c=region.Id);
        insert division;
        
        ASI_CRM_CN_Area__c area = new ASI_CRM_CN_Area__c(Name='TEST', ASI_CRM_English_Name__c='TEST', ASI_CRM_Division__c=division.Id);
        insert area;
        
        ASI_CRM_City__c city = new ASI_CRM_City__c(Name='TEST', ASI_CRM_CN_Area__c=area.Id);
        insert city;
        
        /*ASI_CRM_CN_Channel__c channel = new ASI_CRM_CN_Channel__c(Name='KTV',ASI_CRM_BC_Rate__c=98,ASI_CRM_CN_On_Off__c='ON',ASI_CRM_For_Outlet__c=true,RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CN_Channel__cASI_CRM_CN_New_Channel'),ASI_CRM_For_Contract__c=TRUE);
        insert channel;*/
        
        ASI_CRM_CN_Channel__c channel = new ASI_CRM_CN_Channel__c(ASI_CRM_CN_On_Off__c='ON');
        insert channel;
        
        Id rtWS = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_CN_WS');
        Id rtOutlet = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN');
        /*
        list<ASI_CRM_AccountsAdditionalField__c> Customers = new list<ASI_CRM_AccountsAdditionalField__c>();
        Customers.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Commercial_Team__c = 'Premium',RecordTypeId=rtWS,Name='TEST', ASI_CRM_CN_Image__c='Iconic',ASI_CRM_CN_CCity__c=city.Id,ASI_CRM_CN_NewChannel__c=channel.Id));
        Customers.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Commercial_Team__c = 'Premium',RecordTypeId=rtOutlet,Name='TEST', ASI_CRM_CN_Image__c='Iconic',ASI_CRM_CN_CCity__c=city.Id,ASI_CRM_CN_NewChannel__c=channel.Id));
        insert Customers;

        //Covered_Outlet
        list<ASI_CRM_AccountsAdditionalField__c> ChildCustomers = new list<ASI_CRM_AccountsAdditionalField__c>();
        ChildCustomers.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Parent_Outlet__c=Customers[1].Id,ASI_CRM_CN_Commercial_Team__c = 'Premium',RecordTypeId=rtOutlet,Name='TEST', ASI_CRM_CN_Image__c='Iconic',ASI_CRM_CN_CCity__c=city.Id,ASI_CRM_CN_NewChannel__c=channel.Id));
        insert ChildCustomers;*/
        
        ASI_MFM_Sub_Channel__c subChannel = new ASI_MFM_Sub_Channel__c(ASI_CRM_CN_Channel__c=channel.Id);
        insert subChannel;
        
        ASI_CRM_CN_Channel__c newChannel = new ASI_CRM_CN_Channel__c(ASI_CRM_For_Outlet__c = true, Name='Restaurant',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CN_Channel__cASI_CRM_CN_New_Channel'),ASI_CRM_CN_On_Off__c='OFF');
        insert newChannel;
        
        list<ASI_CRM_AccountsAdditionalField__c> Customers = new list<ASI_CRM_AccountsAdditionalField__c>();
        Customers.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Eng_Name__c = 'b', ASI_CRM_CN_Chi_Name__c = 'b', ASI_CRM_CN_Commercial_Team__c = 'Premium', ASI_CRM_CN_Sub_Channel__c=subChannel.Id, ASI_CRM_CN_CCity__c=city.Id, ASI_CRM_Latest_Call_Plan_Date__c=system.today(), RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN'), ASI_CRM_CN_NewChannel__c = newChannel.Id, ASI_CRM_CN_Type_of_Restaurant__c = 'International',ASI_CRM_CN_Spending_per_head__c=1));
        Customers.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Eng_Name__c = 'c', ASI_CRM_CN_Chi_Name__c = 'c', ASI_CRM_CN_Commercial_Team__c = 'Premium', ASI_CRM_CN_Sub_Channel__c=subChannel.Id, ASI_CRM_CN_CCity__c=city.Id, ASI_CRM_Latest_Call_Plan_Date__c=system.today(), RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN'), ASI_CRM_CN_NewChannel__c = newChannel.Id, ASI_CRM_CN_Type_of_Restaurant__c = 'International',ASI_CRM_CN_Spending_per_head__c=1));
        insert Customers;
        
        list<ASI_CRM_AccountsAdditionalField__c> ChildCustomers = new list<ASI_CRM_AccountsAdditionalField__c>();
        ChildCustomers.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Parent_Outlet__c=Customers[1].Id,ASI_CRM_CN_Eng_Name__c = 'a', ASI_CRM_CN_Chi_Name__c = 'a', ASI_CRM_CN_Commercial_Team__c = 'Premium', ASI_CRM_CN_Sub_Channel__c=subChannel.Id, ASI_CRM_CN_CCity__c=city.Id, ASI_CRM_Latest_Call_Plan_Date__c=system.today(), RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN'), ASI_CRM_CN_NewChannel__c = newChannel.Id, ASI_CRM_CN_Type_of_Restaurant__c = 'International',ASI_CRM_CN_Spending_per_head__c=1));
        insert ChildCustomers;
        
        /*list<ASI_CRM_AccountsAdditionalField__c> ChildCustomers = new list<ASI_CRM_AccountsAdditionalField__c>();
        ChildCustomers.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Parent_Outlet__c=Customers[1].Id,ASI_CRM_CN_Eng_Name__c = 'a', ASI_CRM_CN_Chi_Name__c = 'a', ASI_CRM_CN_Commercial_Team__c = 'Premium', ASI_CRM_CN_Sub_Channel__c=subChannel.Id, ASI_CRM_CN_CCity__c=city.Id, ASI_CRM_Latest_Call_Plan_Date__c=system.today(), RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN'), ASI_CRM_CN_NewChannel__c = newChannel.Id, ASI_CRM_CN_Type_of_Restaurant__c = 'International',ASI_CRM_CN_Spending_per_head__c=1));
        insert ChildCustomers;

        list<ASI_CRM_AccountsAdditionalField__c> ChildChildCustomers = new list<ASI_CRM_AccountsAdditionalField__c>();
        ChildChildCustomers.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Parent_Outlet__c=ChildCustomers[0].Id,ASI_CRM_CN_Commercial_Team__c = 'Premium',RecordTypeId=rtOutlet,Name='TEST', ASI_CRM_CN_Image__c='Iconic',ASI_CRM_CN_CCity__c=city.Id,ASI_CRM_CN_NewChannel__c=channel.Id));
        insert ChildChildCustomers;*/
        
        //ASI_CRM_CN_Parent_Outlet__c
        
        User currentUser = [SELECT id, name, Managerid, ASI_CRM_CN_Prefix__c FROM USER WHERE id =:UserInfo.getUserId()];
        
        list<ASI_HK_CRM_Running_Number__c> rns = new list<ASI_HK_CRM_Running_Number__c>();
        rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_TH_CRM_Contract__c', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_TH_CRM_PaymentRequest__c', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        if(!String.isBlank(currentUser.ASI_CRM_CN_Prefix__c))
            rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_'+currentUser.ASI_CRM_CN_Prefix__c, recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        else{
            rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_NULL', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
            rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        }
        insert rns;
        
        //Sub Brand Grade
        list<ASI_CRM_Sub_Brand_Grade__c> grades = new list<ASI_CRM_Sub_Brand_Grade__c>();
        grades.add(new ASI_CRM_Sub_Brand_Grade__c (Name='TEST1'));
        grades.add(new ASI_CRM_Sub_Brand_Grade__c (Name='TEST2'));
        grades.add(new ASI_CRM_Sub_Brand_Grade__c (Name='TEST3'));
        insert grades;
        
        
        list<ASI_MFM_Sub_brand__c> subBrands = new list<ASI_MFM_Sub_brand__c>();
        for(ASI_CRM_Sub_Brand_Grade__c grade :grades) {
            subBrands.add(new ASI_MFM_Sub_brand__c (Name='TEST1',ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,RecordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand'),
                                                    ASI_CRM_CN_Sub_brand_Grade__c=grade.Id));
            subBrands.add(new ASI_MFM_Sub_brand__c (Name='TEST2',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand'),
                                                    ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,
                                                    ASI_CRM_CN_Sub_brand_Grade__c=grade.Id));
            subBrands.add(new ASI_MFM_Sub_brand__c ( Name='TEST3',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand'),
                                                    ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,
                                                    ASI_CRM_CN_Sub_brand_Grade__c=grade.Id));
            subBrands.add(new ASI_MFM_Sub_brand__c ( Name='999',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand'),
                                                    ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,ASI_MFM_Sub_brand_Code__c = '999' ,ASI_MFM_Active_for_CRM__c = true ,
                                                    ASI_CRM_CN_Sub_brand_Grade__c=grade.Id));
        }
        insert subBrands;
        
        
        Date PO_Start_Date = date.newinstance(system.today().year(), system.today().month(), 1);
        Date PO_End_Date = PO_Start_Date.addMonths(1)-1;
        
        ASI_TH_CRM_Contract__c Contract = new ASI_TH_CRM_Contract__c(recordtypeid = Global_RecordTypeCache.getRTID('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract'),
                                                                     ASI_CRM_CN_Status__c = 'Final',
                                                                     ASI_CRM_CN_PO_Start_Date__c = PO_Start_Date,
                                                                     ASI_CRM_CN_PO_End_Date__c =PO_End_Date,
                                                                     ASI_CRM_CN_PO_Version__c = '0.0',ASI_TH_CRM_Promotion_Type__c='Heavy Contract On',
                                                                     Name = 'Contract1',
                                                                     ASI_CRM_CN_Outlet_WS__c=Customers[1].Id,ASI_CRM_Volume_Option__c = 'Normal');
        insert Contract;
        
        
        test.startTest();
        
        
        PageReference EnterPage = Page.ASI_CRM_CN_ViewHeavyContractPage;
        Test.setCurrentPage(EnterPage);
        Map<String, String> pageParams = EnterPage.getParameters();
        
        pageParams.put('id', Contract.id);
        ApexPages.StandardController sc = new ApexPages.standardController(new ASI_TH_CRM_Contract__c());
        
        ASI_CRM_CN_ViewHeavyContractCtrl con = new ASI_CRM_CN_ViewHeavyContractCtrl(new ApexPages.Standardcontroller(Contract));
        
        con.AddAllChildOutlets();
        con.SaveItems();
        
        test.stopTest(); 
    }  

    static testMethod void EditHeavyContractDetailCtrlTest11() {
        //Test Class for ASI_CRM_CN_EditHeavyContractDetailCtrl
        
        ASI_CRM_Region__c region = new ASI_CRM_Region__c (Name='Central Region',recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Region__cASI_CRM_CN_Region'));
        insert region;
        
        ASI_CRM_Division__c division = new ASI_CRM_Division__c(Name='TEST', ASI_CRM_Region__c=region.Id);
        insert division;
        
        ASI_CRM_CN_Area__c area = new ASI_CRM_CN_Area__c(Name='TEST', ASI_CRM_English_Name__c='TEST', ASI_CRM_Division__c=division.Id);
        insert area;
        
        ASI_CRM_City__c city = new ASI_CRM_City__c(Name='TEST', ASI_CRM_CN_Area__c=area.Id,ASI_CRM_CN_City_Tier__c='2');
        insert city;
        
        /*ASI_CRM_CN_Channel__c channel = new ASI_CRM_CN_Channel__c(Name='KTV',ASI_CRM_BC_Rate__c=98,ASI_CRM_CN_On_Off__c='ON',ASI_CRM_For_Outlet__c=true,RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CN_Channel__cASI_CRM_CN_New_Channel'),ASI_CRM_For_Contract__c=TRUE);
        insert channel;*/
        
        ASI_CRM_CN_Channel__c channel = new ASI_CRM_CN_Channel__c(ASI_CRM_CN_On_Off__c='ON');
        insert channel;
        /*
        ASI_CRM_SegmentationCriteria__c SegmentationCriteria= new ASI_CRM_SegmentationCriteria__c (Name='Test',ASI_CRM_Channel__c=channel.Id, ASI_CRM_Outlet_New_Image__c='Iconic',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_SegmentationCriteria__cASI_CRM_CN_Segmentation_Criteria'));
        INSERT SegmentationCriteria;
        
        Id rtWS = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_CN_WS');
        Id rtOutlet = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN');
        */
        ASI_MFM_Sub_Channel__c subChannel = new ASI_MFM_Sub_Channel__c(ASI_CRM_CN_Channel__c=channel.Id);
        insert subChannel;
        
        ASI_CRM_CN_Channel__c newChannel = new ASI_CRM_CN_Channel__c(ASI_CRM_For_Outlet__c = true, Name='Restaurant',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CN_Channel__cASI_CRM_CN_New_Channel'),ASI_CRM_CN_On_Off__c='OFF');
        insert newChannel;
        
        list<ASI_CRM_AccountsAdditionalField__c> Customers = new list<ASI_CRM_AccountsAdditionalField__c>();
        Customers.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Eng_Name__c = 'b', ASI_CRM_CN_Chi_Name__c = 'b', ASI_CRM_CN_Commercial_Team__c = 'Premium', ASI_CRM_CN_Sub_Channel__c=subChannel.Id, ASI_CRM_CN_CCity__c=city.Id, ASI_CRM_Latest_Call_Plan_Date__c=system.today(), RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN'), ASI_CRM_CN_NewChannel__c = newChannel.Id, ASI_CRM_CN_Type_of_Restaurant__c = 'International',ASI_CRM_CN_Spending_per_head__c=1));
        Customers.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Eng_Name__c = 'c', ASI_CRM_CN_Chi_Name__c = 'c', ASI_CRM_CN_Commercial_Team__c = 'Premium', ASI_CRM_CN_Sub_Channel__c=subChannel.Id, ASI_CRM_CN_CCity__c=city.Id, ASI_CRM_Latest_Call_Plan_Date__c=system.today(), RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN'), ASI_CRM_CN_NewChannel__c = newChannel.Id, ASI_CRM_CN_Type_of_Restaurant__c = 'International',ASI_CRM_CN_Spending_per_head__c=1));
        insert Customers;
        /*
        
        list<ASI_CRM_AccountsAdditionalField__c> ChildCustomers = new list<ASI_CRM_AccountsAdditionalField__c>();
        ChildCustomers.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Parent_Outlet__c=Customers[1].Id,ASI_CRM_CN_Eng_Name__c = 'a', ASI_CRM_CN_Chi_Name__c = 'a', ASI_CRM_CN_Commercial_Team__c = 'Premium', ASI_CRM_CN_Sub_Channel__c=subChannel.Id, ASI_CRM_CN_CCity__c=city.Id, ASI_CRM_Latest_Call_Plan_Date__c=system.today(), RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN'), ASI_CRM_CN_NewChannel__c = newChannel.Id, ASI_CRM_CN_Type_of_Restaurant__c = 'International',ASI_CRM_CN_Spending_per_head__c=1));
        insert ChildCustomers;
        
        */
        
        User currentUser = [SELECT id, name, Managerid, ASI_CRM_CN_Prefix__c,LanguageLocaleKey FROM USER WHERE id =:UserInfo.getUserId()];
        currentUser.LanguageLocaleKey='zh_CN';
        update currentUser;
        
        list<ASI_HK_CRM_Running_Number__c> rns = new list<ASI_HK_CRM_Running_Number__c>();
        rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_TH_CRM_Contract__c', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_TH_CRM_PaymentRequest__c', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        if(!String.isBlank(currentUser.ASI_CRM_CN_Prefix__c))
            rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_'+currentUser.ASI_CRM_CN_Prefix__c, recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        else{
            rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_NULL', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
            rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        }
        insert rns;
        
        
        
        
        
        List<ASI_HK_CRM_Product_Category__c> ProductCategoryList= new List<ASI_HK_CRM_Product_Category__c> ();
        ProductCategoryList.add(new ASI_HK_CRM_Product_Category__c(Name='Category1',ASI_CRM_CN_Chinese_Name__c='Category',ASI_HK_CRM_English_Name__c='Category',ASI_HK_CRM_Sequence__c=1,recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Product_Category__cASI_CRM_CN_Product_Category')));
        ProductCategoryList.add(new ASI_HK_CRM_Product_Category__c(Name='Category2',ASI_CRM_CN_Chinese_Name__c='Category2',ASI_HK_CRM_English_Name__c='Category',ASI_HK_CRM_Sequence__c=2,recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Product_Category__cASI_CRM_CN_Product_Category')));
        ProductCategoryList.add(new ASI_HK_CRM_Product_Category__c(Name='Category3',ASI_CRM_CN_Chinese_Name__c='Category1',ASI_HK_CRM_English_Name__c='Category',ASI_HK_CRM_Sequence__c=3,recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Product_Category__cASI_CRM_CN_Product_Category')));
        
        insert ProductCategoryList;
        
        
        
        
        List<ASI_TH_CRM_Sub_category__c> SubCategoryList= new List<ASI_TH_CRM_Sub_category__c>();
        SubCategoryList.add(new ASI_TH_CRM_Sub_category__c(Name='SubCategory1',ASI_CRM_CN_Product_Category__c=ProductCategoryList[0].Id,recordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_Sub_category__cASI_CRM_CN_Sub_Category')));
        SubCategoryList.add(new ASI_TH_CRM_Sub_category__c(Name='SubCategory2',ASI_CRM_CN_Product_Category__c=ProductCategoryList[1].Id,recordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_Sub_category__cASI_CRM_CN_Sub_Category')));
        SubCategoryList.add(new ASI_TH_CRM_Sub_category__c(Name='SubCategory3',ASI_CRM_CN_Product_Category__c=ProductCategoryList[2].Id,recordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_Sub_category__cASI_CRM_CN_Sub_Category')));
        
        insert SubCategoryList;
        
        
        List<ASI_MFM_Brand__c> BrandList = new List<ASI_MFM_Brand__c> ();
        BrandList.add(new ASI_MFM_Brand__c (Name='Test1',ASI_CRM_CN_Competitor__c=false,ASI_TH_CRM_Sub_category__c=SubCategoryList[0].Id,recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Brand__cASI_FOC_CN_Brand')));
        BrandList.add(new ASI_MFM_Brand__c (Name='Test2',ASI_CRM_CN_Competitor__c=false,ASI_TH_CRM_Sub_category__c=SubCategoryList[1].Id,recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Brand__cASI_FOC_CN_Brand')));
        BrandList.add(new ASI_MFM_Brand__c (Name='Test3',ASI_CRM_CN_Competitor__c=false,ASI_TH_CRM_Sub_category__c=SubCategoryList[2].Id,recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Brand__cASI_FOC_CN_Brand')));
        
        Insert BrandList;
        
        
        
        
        //Sub Brand Grade
        list<ASI_CRM_Sub_Brand_Grade__c> grades = new list<ASI_CRM_Sub_Brand_Grade__c>();
        grades.add(new ASI_CRM_Sub_Brand_Grade__c (Name='Premium',ASI_CRM_Chinese_Name__c='Test1',ASI_CRM_Chinese_Description__c='1. Standard + Premium 标准档 + 高档',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_Sub_Brand_Grade__cASI_CRM_CN_Sub_brand_Grade')));
        grades.add(new ASI_CRM_Sub_Brand_Grade__c (Name='TEST2',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_Sub_Brand_Grade__cASI_CRM_CN_Sub_brand_Grade')));
        grades.add(new ASI_CRM_Sub_Brand_Grade__c (Name='TEST3',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_Sub_Brand_Grade__cASI_CRM_CN_Sub_brand_Grade')));
        insert grades;
        
        list<ASI_MFM_Sub_brand__c> subBrands = new list<ASI_MFM_Sub_brand__c>();
        for(ASI_CRM_Sub_Brand_Grade__c grade :grades) {
            subBrands.add(new ASI_MFM_Sub_brand__c (Name='TEST1',ASI_MFM_Active_for_CRM__c=true,ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,RecordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand'),
                                                    ASI_CRM_CN_Sub_brand_Grade__c=grade.Id,ASI_MFM_Brand__c=BrandList[0].Id));
            subBrands.add(new ASI_MFM_Sub_brand__c (Name='TEST2',ASI_MFM_Active_for_CRM__c=true,RecordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand'),
                                                    ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,
                                                    ASI_CRM_CN_Sub_brand_Grade__c=grade.Id,ASI_MFM_Brand__c=BrandList[1].Id));
            subBrands.add(new ASI_MFM_Sub_brand__c ( Name='TEST3',ASI_MFM_Active_for_CRM__c=true,RecordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand'),
                                                    ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,
                                                    ASI_CRM_CN_Sub_brand_Grade__c=grade.Id,ASI_MFM_Brand__c=BrandList[2].Id));
            subBrands.add(new ASI_MFM_Sub_brand__c ( Name='999',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand'),
                                                    ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,ASI_MFM_Sub_brand_Code__c = '999' ,ASI_MFM_Active_for_CRM__c = true ,
                                                    ASI_CRM_CN_Sub_brand_Grade__c=grade.Id,ASI_MFM_Brand__c=BrandList[0].Id));
        }
        
        insert subBrands;
        
        /*
        List<ASI_CRM_Sub_Brand_Assignment__c> SubBrandAssignmentList= new List<ASI_CRM_Sub_Brand_Assignment__c>();
        for(ASI_MFM_Sub_brand__c SubBrandItem:subBrands){
            SubBrandAssignmentList.add(new ASI_CRM_Sub_Brand_Assignment__c(ASI_CRM_Sub_Brand__c=SubBrandItem.Id,ASI_CRM_Segmentation_Criteria__c=SegmentationCriteria.Id));
        }
        
        insert SubBrandAssignmentList;
        */
        
        List<ASI_MFM_A_C_Code__c> ACCodeList = new  List<ASI_MFM_A_C_Code__c>();
        ACCodeList.add(new ASI_MFM_A_C_Code__c( Name='0000000000000', ASI_MFM_A_C_Code__c='000010000',ASI_MFM_A_C_Description__c='ASI_CRM_CN_Variable_Cost_Contract',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_CN_A_C_Code') ));
        ACCodeList.add(new ASI_MFM_A_C_Code__c( Name='5275.010000 PRC - Bottle Return Service', ASI_MFM_A_C_Code__c='5275.010000',ASI_MFM_A_C_Description__c='Bottle Return Service',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_CN_A_C_Code') ));
        ACCodeList.add(new ASI_MFM_A_C_Code__c( Name='5275.020000 Promotion Service Fee', ASI_MFM_A_C_Code__c='5275.020000',ASI_MFM_A_C_Description__c='Promotion Service Fee',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_CN_A_C_Code') ));
        ACCodeList.add(new ASI_MFM_A_C_Code__c( Name='5275.030000 PRC - Variable Event Cost', ASI_MFM_A_C_Code__c='5275.030000',ASI_MFM_A_C_Description__c='Variable Event Cost',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_CN_A_C_Code') ));
        ACCodeList.add(new ASI_MFM_A_C_Code__c( Name='5275.040000 PRC - Fixed Event Cost',ASI_MFM_A_C_CN_Description__c='夜店活动费用(固定)', ASI_MFM_A_C_Code__c='5275.040000',ASI_MFM_A_C_Description__c='PRC - Fixed Event Cost',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_CN_A_C_Code') ));
        
        insert ACCodeList;
        // ASI_TH_CRM_Contract__c.ASI_CRM_CN_Fixed_Module_Est_Amount1__c
        // ASI_CRM_CN_FixedMappingSetting__c setting = new ASI_CRM_CN_FixedMappingSetting__c();
        // setting.ASI_CRM_CN_Activity_CodeId__c = ACCodeList[4].Id;
        // setting.ASI_CRM_CN_Contract_Mapping_Field__c = 'ASI_CRM_CN_Fixed_Module_Est_Amount1__c';
        // setting.Name = ACCodeList[4].Id;
        // insert setting;
        
        
        List<ASI_CRM_Contract_Cost_Setting__c> ContractCostSettingList= new List<ASI_CRM_Contract_Cost_Setting__c>();
        
        ContractCostSettingList.add(new ASI_CRM_Contract_Cost_Setting__c(ASI_CRM_CN_Activity_Code__c=ACCodeList[0].Id,ASI_CRM_CN_Promotion_Type__c='Heavy Contract ON',
                                                                         ASI_CRM_CN_Fixed_Cost_Contract__c=true,ASI_CRM_CN_Variable_Cost_Contract__c=true));
        
        ContractCostSettingList.add(new ASI_CRM_Contract_Cost_Setting__c(ASI_CRM_CN_Activity_Code__c=ACCodeList[0].Id,ASI_CRM_CN_Promotion_Type__c='Heavy Contract ON',ASI_CRM_CN_Variable_Cost_Contract__c=true,
                                                                         ASI_CRM_CN_Fixed_Cost_Contract__c=false,ASI_CRM_CN_BRSF_Activity_Code_Default__c=true));
        
        ContractCostSettingList.add(new ASI_CRM_Contract_Cost_Setting__c(ASI_CRM_CN_Activity_Code__c=ACCodeList[0].Id,ASI_CRM_CN_Promotion_Type__c='Heavy Contract ON',ASI_CRM_CN_Variable_Cost_Contract__c=true,
                                                                         ASI_CRM_CN_Fixed_Cost_Contract__c=false,ASI_CRM_PSF_Activity_Code_Default__c=true));
        
        ContractCostSettingList.add(new ASI_CRM_Contract_Cost_Setting__c(ASI_CRM_CN_Activity_Code__c=ACCodeList[0].Id,ASI_CRM_CN_Promotion_Type__c='Heavy Contract ON',ASI_CRM_CN_Variable_Cost_Contract__c=true,
                                                                         ASI_CRM_CN_Fixed_Cost_Contract__c=false,ASI_CRM_VEC_Activity_Code_Defaul__c=true));
        ContractCostSettingList.add(new ASI_CRM_Contract_Cost_Setting__c(ASI_CRM_CN_Activity_Code__c=ACCodeList[4].Id,ASI_CRM_CN_Promotion_Type__c='Heavy Contract ON',
                                                                         ASI_CRM_CN_Fixed_Cost_Contract__c=true,ASI_CRM_CN_Variable_Cost_Contract__c=false));
        
        insert ContractCostSettingList;
        /*
        ASI_CRM_SpecialPromotionTypeSetting__c oldspts = new ASI_CRM_SpecialPromotionTypeSetting__c( ASI_CRM_Promotion_Type__c = 'a');
        insert oldspts;
        
        ASI_CRM_SpecialPromotionTypeSetting__c newspts = new ASI_CRM_SpecialPromotionTypeSetting__c(ASI_CRM_Promotion_Type__c = 'Heavy Contract On',recordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_SpecialPromotionTypeSetting__cASI_CRM_CN_SpecialPromotionTypeSetting'));
        insert newspts;
        
        ASI_CRM_Special_Promotion_Type_Mapping__c sptm = new ASI_CRM_Special_Promotion_Type_Mapping__c(ASI_CRM_Mapping_of_New_Promotion_Type__c = newspts.Id,ASI_CRM_Mapping_of_Old_Promotion_Type__c = oldspts.Id,recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Special_Promotion_Type_Mapping__cASI_CRM_CN_Special_Promotion_Type_Mapping'));
        insert sptm;
        
        */
        
        Date today = Date.newInstance(2019,5 ,25);
        Date PO_Start_Date = date.newinstance(today.year(), today.month(), 1);
        Date PO_End_Date = Date.newInstance(2020,5 ,31);
        
        
        ASI_TH_CRM_Contract__c GroupContract = new ASI_TH_CRM_Contract__c(recordtypeid = Global_RecordTypeCache.getRTID('ASI_TH_CRM_Contract__cASI_CRM_CN_Group_Contract'),
                                                                          ASI_CRM_CN_PO_Start_Date__c = PO_Start_Date,
                                                                          ASI_CRM_CN_PO_End_Date__c =PO_End_Date,
                                                                          Name = 'Noah C4',
                                                                          ASI_CRM_CN_Outlet_WS__c=Customers[1].Id);
        insert GroupContract;
        
        ASI_TH_CRM_Contract__c Contract = new ASI_TH_CRM_Contract__c(recordtypeid = Global_RecordTypeCache.getRTID('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract'),ASI_CRM_CN_Is_2nd_KPI_PO__c=true,
                                                                     ASI_CRM_CN_Status__c = 'Final',ASI_CRM_CN_Group_Contract__c=GroupContract.Id,
                                                                     ASI_CRM_CN_PO_Start_Date__c = PO_Start_Date,
                                                                     ASI_CRM_CN_PO_End_Date__c =PO_End_Date,
                                                                     ASI_CRM_CN_PO_Version__c = '0.0',ASI_TH_CRM_Promotion_Type__c='Heavy Contract On',
                                                                     Name = 'Contract1',
                                                                     ASI_CRM_CN_Outlet_WS__c=Customers[1].Id,ASI_CRM_Volume_Option__c = 'Normal');
        insert Contract;
        
        
        List<ASI_CRM_Methodology__c> MethodologyList= new List<ASI_CRM_Methodology__c> ();
        MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test1',ASI_CRM_Methodology_Code__c='01',ASI_CRM_Default__c=true,ASI_CRM_Chinese_Name__c='123',ASI_CRM_Type__c='BRSF',recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Methodology__cASI_CRM_CN_Methodology')));
        MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test2',ASI_CRM_Methodology_Code__c='01',ASI_CRM_Default__c=true,ASI_CRM_Chinese_Name__c='Test 123',ASI_CRM_Type__c='PSF',recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Methodology__cASI_CRM_CN_Methodology')));
        MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test3',ASI_CRM_Methodology_Code__c='01',ASI_CRM_Default__c=true,ASI_CRM_Chinese_Name__c='Test 123',ASI_CRM_Type__c='Variable Event Cost',recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Methodology__cASI_CRM_CN_Methodology')));
        
        
        MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test1',ASI_CRM_Methodology_Code__c='01',ASI_CRM_Chinese_Name__c='123',ASI_CRM_Type__c='BRSF',recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Methodology__cASI_CRM_CN_Methodology')));
        MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test2',ASI_CRM_Methodology_Code__c='01',ASI_CRM_Chinese_Name__c='123',ASI_CRM_Type__c='PSF',recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Methodology__cASI_CRM_CN_Methodology')));
        MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test3',ASI_CRM_Methodology_Code__c='01',ASI_CRM_Chinese_Name__c='123',ASI_CRM_Type__c='Variable Event Cost',recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Methodology__cASI_CRM_CN_Methodology')));
        insert MethodologyList;
        
        
        //Methodology Assignment
        List<ASI_CRM_Methodology_Assignment__c> MethodologyAssignmentList = new List<ASI_CRM_Methodology_Assignment__c>();
        MethodologyAssignmentList.add(new ASI_CRM_Methodology_Assignment__c(ASI_CRM_Methodology__c=MethodologyList[0].Id,ASI_CRM_Key_Principle__c=true,ASI_CRM_Methodology_Commercial_Team__c='Premium',ASI_CRM_Region__c=region.Id));
        MethodologyAssignmentList.add(new ASI_CRM_Methodology_Assignment__c(ASI_CRM_Methodology__c=MethodologyList[1].Id,ASI_CRM_Key_Principle__c=true,ASI_CRM_Methodology_Commercial_Team__c='Premium',ASI_CRM_Region__c=region.Id));
        MethodologyAssignmentList.add(new ASI_CRM_Methodology_Assignment__c(ASI_CRM_Methodology__c=MethodologyList[2].Id,ASI_CRM_Key_Principle__c=true,ASI_CRM_Methodology_Commercial_Team__c='Premium',ASI_CRM_Region__c=region.Id));
        MethodologyAssignmentList.add(new ASI_CRM_Methodology_Assignment__c(ASI_CRM_Methodology__c=MethodologyList[3].Id,ASI_CRM_Key_Principle__c=true,ASI_CRM_Methodology_Commercial_Team__c='Premium',ASI_CRM_Region__c=region.Id));
        MethodologyAssignmentList.add(new ASI_CRM_Methodology_Assignment__c(ASI_CRM_Methodology__c=MethodologyList[4].Id,ASI_CRM_Key_Principle__c=true,ASI_CRM_Methodology_Commercial_Team__c='Premium',ASI_CRM_Region__c=region.Id));
        MethodologyAssignmentList.add(new ASI_CRM_Methodology_Assignment__c(ASI_CRM_Methodology__c=MethodologyList[5].Id,ASI_CRM_Key_Principle__c=true,ASI_CRM_Methodology_Commercial_Team__c='Premium',ASI_CRM_Region__c=region.Id));
        
        insert MethodologyAssignmentList ;
        
        
        
        
        List<ASI_CRM_Module__c> ModuleList = new List<ASI_CRM_Module__c>();
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='Std. Btl.',ASI_CRM_Volume_Base__c='By Sub-Brand',ASI_CRM_Line_Type__c='BRSF',ASI_CRM_Methodology__c=MethodologyList[0].Id));
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='Std. Btl.',ASI_CRM_Volume_Base__c='By Sub-Brand',ASI_CRM_Line_Type__c='PSF',ASI_CRM_Methodology__c=MethodologyList[1].Id));
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='CR12 Extra Eqv.',ASI_CRM_Volume_Base__c='By Grade',ASI_CRM_Line_Type__c='PSF',ASI_CRM_Methodology__c=MethodologyList[1].Id));
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='CR12 Extra Eqv.',ASI_CRM_Volume_Base__c='By Category',ASI_CRM_Line_Type__c='PSF',ASI_CRM_Methodology__c=MethodologyList[1].Id));
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='CR12 Extra Eqv.',ASI_CRM_Volume_Base__c='By Total',ASI_CRM_Line_Type__c='PSF',ASI_CRM_Methodology__c=MethodologyList[1].Id));
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='CR12 Extra Eqv.',ASI_CRM_Volume_Base__c='By Sub-Brand',ASI_CRM_Line_Type__c='Variable Event Cost',ASI_CRM_Methodology__c=MethodologyList[2].Id));

        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='Std. Btl.',ASI_CRM_Volume_Base__c='By Sub-Brand',ASI_CRM_Line_Type__c='Fixed',ASI_CRM_CN_AC_Code__c = ACCodeList[4].Id, ASI_CRM_CN_AC_Code__r = ACCodeList[4]));
        
        insert ModuleList;
        /*
        ASI_CRM_Contract_Cost__c contractCost = new ASI_CRM_Contract_Cost__c(ASI_CRM_CN_Contract__c = Contract.id,
                                                                             ASI_CRM_CN_Estimate_Amount__c = 100000,
                                                                             ASI_CRM_CN_Cost_Type__c = 'Fixed',
                                                                             ASI_CRM_CN_Other_Cost_Payment_Request__c = true,
                                                                             recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_Contract_Cost__cASI_CRM_CN_Contract_Cost') );
        insert contractCost;
        */
        list<ASI_CRM_CN_Contract_BRSF_Line_Item__c> ContractLineList = new list<ASI_CRM_CN_Contract_BRSF_Line_Item__c>();
        list<ASI_CRM_CN_Covered_Outlet__c> cos = new list<ASI_CRM_CN_Covered_Outlet__c>();
        for(ASI_MFM_Sub_brand__c subBrand :subBrands) {
            ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract.Id,
                                                                           ASI_CRM_CN_Est_Monthly_Qty__c=1,ASI_CRM_Module__c=ModuleList[0].Id,
                                                                           ASI_CRM_CN_Contract_Monthly_Qty__c=1,
                                                                           ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,
                                                                           ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,ASI_CRM_Type__c='BRSF',
                                                                           ASI_CRM_CN_Sub_Brand__c=subBrand.Id,
                                                                           recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF')));
        }
        
        for(ASI_MFM_Sub_brand__c subBrand :subBrands) {
            ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract.Id,
                                                                           ASI_CRM_CN_Est_Monthly_Qty__c=1,ASI_CRM_Module__c=ModuleList[1].Id,
                                                                           ASI_CRM_CN_Contract_Monthly_Qty__c=1,ASI_CRM_Volume_Base__c='By Sub-Brand',
                                                                           ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,
                                                                           ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,ASI_CRM_Type__c='PSF',
                                                                           ASI_CRM_CN_Sub_Brand__c=subBrand.Id,
                                                                           recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF')));
        }
        
        ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract.Id,ASI_CRM_Type__c='PSF',ASI_CRM_Volume_Base__c='By Grade',
                                                                       ASI_CRM_CN_Est_Monthly_Qty__c=4,ASI_CRM_Module__c=ModuleList[2].Id,
                                                                       ASI_CRM_CN_Contract_Monthly_Qty__c=4,ASI_CRM_Sub_Brand_Grade__c=grades[0].Id,
                                                                       ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,
                                                                       ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,
                                                                       ASI_CRM_CN_Sub_Brand__c=null,
                                                                       recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF') ));
        ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract.Id,ASI_CRM_Type__c='PSF',ASI_CRM_Volume_Base__c='By Category',
                                                                       ASI_CRM_CN_Est_Monthly_Qty__c=4,ASI_CRM_Module__c=ModuleList[3].Id,
                                                                       ASI_CRM_CN_Contract_Monthly_Qty__c=4,ASI_CRM_Product_Category__c=ProductCategoryList[0].Id,
                                                                       ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,
                                                                       ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,
                                                                       ASI_CRM_CN_Sub_Brand__c=null,
                                                                       recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF') ));
        ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract.Id,ASI_CRM_Type__c='PSF',ASI_CRM_Volume_Base__c='By Total',
                                                                       ASI_CRM_CN_Est_Monthly_Qty__c=4,ASI_CRM_Module__c=ModuleList[4].Id,
                                                                       ASI_CRM_CN_Contract_Monthly_Qty__c=4,
                                                                       ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,
                                                                       ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,
                                                                       ASI_CRM_CN_Sub_Brand__c=null,
                                                                       recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF') ));
        for(ASI_MFM_Sub_brand__c subBrand :subBrands) {
            ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract.Id,
                                                                           ASI_CRM_CN_Est_Monthly_Qty__c=1,ASI_CRM_Module__c=ModuleList[6].Id,
                                                                           ASI_CRM_CN_Contract_Monthly_Qty__c=1,ASI_CRM_Volume_Base__c='By Sub-Brand',
                                                                           ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,ASI_CRM_CN_Activity_Code__r=ACCodeList[4],ASI_CRM_CN_Activity_Code__c=ACCodeList[4].Id,
                                                                           ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,ASI_CRM_Type__c='Fixed',
                                                                           ASI_CRM_CN_Sub_Brand__c=subBrand.Id,
                                                                           recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF')));
        }
        for(ASI_MFM_Sub_brand__c subBrand :subBrands) {
            ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract.Id,
                                                                           ASI_CRM_CN_Est_Monthly_Qty__c=1,ASI_CRM_Module__c=ModuleList[5].Id,
                                                                           ASI_CRM_CN_Contract_Monthly_Qty__c=1,ASI_CRM_Volume_Base__c='By Sub-Brand',
                                                                           ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,
                                                                           ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,ASI_CRM_Type__c='Variable Event Cost',
                                                                           ASI_CRM_CN_Sub_Brand__c=subBrand.Id,
                                                                           recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF')));
        }
        
        insert ContractLineList;
        
        
        test.startTest();
        
        
        Integer coun = 1;
        for(ASI_CRM_CN_Contract_BRSF_Line_Item__c ContractLine:ContractLineList){
            system.debug(coun+'ContractLineList: '+ContractLine);
            coun++;
        }  
        
        
        
        
        ASI_CRM_CN_EditHeavyContractDetailCtrl con2 = new ASI_CRM_CN_EditHeavyContractDetailCtrl(new ApexPages.Standardcontroller(Contract));
        // System.debug(LoggingLevel.INFO, '*** ContractLineList: ' + ContractLineList);
        ApexPages.currentPage().getParameters().put('PARAM_Line_ID', ContractLineList[15].id);
        ApexPages.currentPage().getParameters().put('PARAM_item_ID', ModuleList[1].id);
        con2.PSFChangingSB();
        
        ApexPages.currentPage().getParameters().put('PARAM_Line_ID', ContractLineList[17].id);
        ApexPages.currentPage().getParameters().put('PARAM_item_ID', ModuleList[1].id);
        ApexPages.currentPage().getParameters().put('PARAM_Unit_ID','Std. Btl.');
        con2.RemovePSFLine();
        
        
        

        ApexPages.currentPage().getParameters().put('PARAM_Line_ID', ContractLineList[27].id);
        ApexPages.currentPage().getParameters().put('PARAM_item_ID', ContractLineList[27].ASI_CRM_CN_Activity_Code__r.ASI_MFM_A_C_CN_Description__c);
        ApexPages.currentPage().getParameters().put('PARAM_Unit_ID','Std. Btl.');
        con2.RemoveFCLine();



        ApexPages.currentPage().getParameters().put('SelectValue', 'CTD Monthly Volume');
        con2.refreshBrsfItem();

        ApexPages.currentPage().getParameters().put('SelectValue', 'V0.0');
        con2.refreshBrsfItem();
        
        
        
        PageReference EnterPage = Page.ASI_CRM_CN_ViewHeavyContractPage;
        
        Map<String, String> pageParams = EnterPage.getParameters();
        
        pageParams.put('id', Contract.id);
        ApexPages.StandardController sc = new ApexPages.standardController(new ASI_TH_CRM_Contract__c());
        
        ASI_CRM_CN_EditHeavyContractDetailCtrl con = new ASI_CRM_CN_EditHeavyContractDetailCtrl(new ApexPages.Standardcontroller(Contract));
        con.saveItems();
        //con.SizeOfPSFMap = 1;
        
        
        
        ApexPages.currentPage().getParameters().put('PARAM_Line_ID', ContractLineList[0].id);
        con.Clone_BRSF();
        
        
        ApexPages.currentPage().getParameters().put('PARAM_Line_ID', ContractLineList[1].id);
        con.Remove_BRSF();
        con.AddNew_BRSF();
        
        
        
        con.LoopingReCalculatePSF();
        
        con.PSFAddModule();
        ApexPages.currentPage().getParameters().put('PARAM_Line_ID', ModuleList[1].id);
        con.RefreshPSFModule();
        ApexPages.currentPage().getParameters().put('PARAM_Line_ID', ModuleList[2].id);
        con.RefreshPSFModule();
        ApexPages.currentPage().getParameters().put('PARAM_Line_ID', ModuleList[3].id);
        con.RefreshPSFModule();
        ApexPages.currentPage().getParameters().put('PARAM_Line_ID', ModuleList[4].id);
        con.RefreshPSFModule();
        
        ApexPages.currentPage().getParameters().put('PARAM_Line_ID', ModuleList[1].id);
        con.AddNewPSFLine();


        // con.PSFAddModule();
        ApexPages.currentPage().getParameters().put('PARAM_Line_ID', '夜店活动费用(固定)');
        con.ResetFCDetails();

        ApexPages.currentPage().getParameters().put('PARAM_Line_ID', '夜店活动费用(固定)');
        con.RefreshFCModule();

        ApexPages.currentPage().getParameters().put('PARAM_Line_ID', '夜店活动费用(固定)');
        con.ResetFCDetails();
        con.LFixCost2nd.get('夜店活动费用(固定)').Module.ASI_CRM_Volume_Base__c = 'By Sub-Brand';
        ApexPages.currentPage().getParameters().put('PARAM_Line_ID', '夜店活动费用(固定)');

        for (String key : con.BRSFItemMap.DetailLineMap.keySet()) {
            if (con.BRSFItemMap.DetailLineMap.get(key).ASI_CRM_CN_Sub_Brand__c == null) {
                con.BRSFItemMap.DetailLineMap.remove(key);
            }
        }

        // System.debug(LoggingLevel.INFO, '*** con.BRSFItemMap.DetailLineMap: ' + con.BRSFItemMap.DetailLineMap);
        con.RefreshFCModule();
        Map<String,ASI_CRM_Module__c> PSFModuleMap = new Map<String,ASI_CRM_Module__c>();
        Map<String,ASI_CRM_Module__c> FCModuleMap = new Map<String,ASI_CRM_Module__c>();
        con.GenContractLine(ModuleList[0], ModuleList[5], PSFModuleMap,FCModuleMap);

        ApexPages.currentPage().getParameters().put('PARAM_Line_ID', '夜店活动费用(固定)');
        con.ResetFCDetails();
        con.LFixCost2nd.get('夜店活动费用(固定)').Module.ASI_CRM_Volume_Base__c = 'By Grade';
        ApexPages.currentPage().getParameters().put('PARAM_Line_ID', '夜店活动费用(固定)');
        System.debug(LoggingLevel.INFO, '*** con.LFixCost2nd2: ' + con.LFixCost2nd);
        con.RefreshFCModule();

        ApexPages.currentPage().getParameters().put('PARAM_Line_ID', '夜店活动费用(固定)');
        con.ResetFCDetails();
        con.LFixCost2nd.get('夜店活动费用(固定)').Module.ASI_CRM_Volume_Base__c = 'By Category';
        ApexPages.currentPage().getParameters().put('PARAM_Line_ID', '夜店活动费用(固定)');
        System.debug(LoggingLevel.INFO, '*** con.LFixCost2nd3: ' + con.LFixCost2nd);
        con.RefreshFCModule();
        
        ApexPages.currentPage().getParameters().put('PARAM_Line_ID', '夜店活动费用(固定)');
        con.AddNewFCLine();
        
        
        ApexPages.currentPage().getParameters().put('PARAM_Line_ID', ContractLineList[33].id);
        con.VECChangingSB();
        con.AddNewVECLine();
        ApexPages.currentPage().getParameters().put('PARAM_Line_ID', ContractLineList[34].id);
        con.CloneVECLine();
        ApexPages.currentPage().getParameters().put('PARAM_Line_ID', ContractLineList[35].id);
        con.RemoveVECLine();
        
        
        con.AddNew_CoveredOutlet();
        ASI_CRM_CN_EditHeavyContractDetailCtrl.GenerateCutOffDate(Date.today());
        con.saveItems();
        
        
        ApexPages.currentPage().getParameters().put('PARAMID', ModuleList[1].id);
        con.DeletePSFModule();
        
        // con.BRSFClearAll();
        // con.ModuleChecking();
        // con.RefreshVECModule();
        // con.ResetVECDetails();
        // con.CopyHistoricalV0Contract();
        // con.ResetPSFDetails();
        // List<sObject> TempList= ASI_CRM_CN_EditHeavyContractDetailCtrl.FindSubBrandList2nd('ASI_MFM_Sub_brand__c',' WHERE RecordType.DeveloperName = \'ASI_FOC_CN_Sub_brand\' ','Premium','2',Contract.Id,region.Name);

        // ASI_CRM_CN_HeavyContractHeaderCtrl2nd con4 = new ASI_CRM_CN_HeavyContractHeaderCtrl2nd(new ApexPages.Standardcontroller(Contract));
        // con4.POModificationProcess12nd(Contract);
        // ASI_CRM_CN_EditHeavyContractDetailCtrl con3 = new ASI_CRM_CN_EditHeavyContractDetailCtrl(new ApexPages.Standardcontroller(Contract));

        // con3.updateLineData();

        // con3.v00UpdateLineData();

        // con3.updateModuleQty();


        test.stopTest(); 
    }

    static testMethod void EditHeavyContractDetailCtrlTest8() {
        //Test Class for ASI_CRM_CN_EditHeavyContractDetailCtrl
        
        ASI_CRM_Region__c region = new ASI_CRM_Region__c (Name='Central Region',recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Region__cASI_CRM_CN_Region'));
        insert region;
        
        ASI_CRM_Division__c division = new ASI_CRM_Division__c(Name='TEST', ASI_CRM_Region__c=region.Id);
        insert division;
        
        ASI_CRM_CN_Area__c area = new ASI_CRM_CN_Area__c(Name='TEST', ASI_CRM_English_Name__c='TEST', ASI_CRM_Division__c=division.Id);
        insert area;
        
        ASI_CRM_City__c city = new ASI_CRM_City__c(Name='TEST', ASI_CRM_CN_Area__c=area.Id,ASI_CRM_CN_City_Tier__c='2');
        insert city;
        
        /*ASI_CRM_CN_Channel__c channel = new ASI_CRM_CN_Channel__c(Name='KTV',ASI_CRM_BC_Rate__c=98,ASI_CRM_CN_On_Off__c='ON',ASI_CRM_For_Outlet__c=true,RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CN_Channel__cASI_CRM_CN_New_Channel'),ASI_CRM_For_Contract__c=TRUE);
        insert channel;*/
        
        ASI_CRM_CN_Channel__c channel = new ASI_CRM_CN_Channel__c(ASI_CRM_CN_On_Off__c='ON');
        insert channel;
        /*
        ASI_CRM_SegmentationCriteria__c SegmentationCriteria= new ASI_CRM_SegmentationCriteria__c (Name='Test',ASI_CRM_Channel__c=channel.Id, ASI_CRM_Outlet_New_Image__c='Iconic',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_SegmentationCriteria__cASI_CRM_CN_Segmentation_Criteria'));
        INSERT SegmentationCriteria;
        
        Id rtWS = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_CN_WS');
        Id rtOutlet = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN');
        */
        ASI_MFM_Sub_Channel__c subChannel = new ASI_MFM_Sub_Channel__c(ASI_CRM_CN_Channel__c=channel.Id);
        insert subChannel;
        
        ASI_CRM_CN_Channel__c newChannel = new ASI_CRM_CN_Channel__c(ASI_CRM_For_Outlet__c = true, Name='Restaurant',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CN_Channel__cASI_CRM_CN_New_Channel'),ASI_CRM_CN_On_Off__c='OFF');
        insert newChannel;
        
        list<ASI_CRM_AccountsAdditionalField__c> Customers = new list<ASI_CRM_AccountsAdditionalField__c>();
        Customers.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Eng_Name__c = 'b', ASI_CRM_CN_Chi_Name__c = 'b', ASI_CRM_CN_Commercial_Team__c = 'Premium', ASI_CRM_CN_Sub_Channel__c=subChannel.Id, ASI_CRM_CN_CCity__c=city.Id, ASI_CRM_Latest_Call_Plan_Date__c=system.today(), RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN'), ASI_CRM_CN_NewChannel__c = newChannel.Id, ASI_CRM_CN_Type_of_Restaurant__c = 'International',ASI_CRM_CN_Spending_per_head__c=1));
        Customers.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Eng_Name__c = 'c', ASI_CRM_CN_Chi_Name__c = 'c', ASI_CRM_CN_Commercial_Team__c = 'Premium', ASI_CRM_CN_Sub_Channel__c=subChannel.Id, ASI_CRM_CN_CCity__c=city.Id, ASI_CRM_Latest_Call_Plan_Date__c=system.today(), RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN'), ASI_CRM_CN_NewChannel__c = newChannel.Id, ASI_CRM_CN_Type_of_Restaurant__c = 'International',ASI_CRM_CN_Spending_per_head__c=1));
        insert Customers;
        /*
        
        list<ASI_CRM_AccountsAdditionalField__c> ChildCustomers = new list<ASI_CRM_AccountsAdditionalField__c>();
        ChildCustomers.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Parent_Outlet__c=Customers[1].Id,ASI_CRM_CN_Eng_Name__c = 'a', ASI_CRM_CN_Chi_Name__c = 'a', ASI_CRM_CN_Commercial_Team__c = 'Premium', ASI_CRM_CN_Sub_Channel__c=subChannel.Id, ASI_CRM_CN_CCity__c=city.Id, ASI_CRM_Latest_Call_Plan_Date__c=system.today(), RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN'), ASI_CRM_CN_NewChannel__c = newChannel.Id, ASI_CRM_CN_Type_of_Restaurant__c = 'International',ASI_CRM_CN_Spending_per_head__c=1));
        insert ChildCustomers;
        
        */
        
        User currentUser = [SELECT id, name, Managerid, ASI_CRM_CN_Prefix__c,LanguageLocaleKey FROM USER WHERE id =:UserInfo.getUserId()];
        currentUser.LanguageLocaleKey='zh_CN';
        update currentUser;
        
        list<ASI_HK_CRM_Running_Number__c> rns = new list<ASI_HK_CRM_Running_Number__c>();
        rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_TH_CRM_Contract__c', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_TH_CRM_PaymentRequest__c', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        if(!String.isBlank(currentUser.ASI_CRM_CN_Prefix__c))
            rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_'+currentUser.ASI_CRM_CN_Prefix__c, recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        else{
            rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_NULL', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
            rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        }
        insert rns;
        
        
        
        
        
        List<ASI_HK_CRM_Product_Category__c> ProductCategoryList= new List<ASI_HK_CRM_Product_Category__c> ();
        ProductCategoryList.add(new ASI_HK_CRM_Product_Category__c(Name='Category1',ASI_CRM_CN_Chinese_Name__c='Category',ASI_HK_CRM_English_Name__c='Category',ASI_HK_CRM_Sequence__c=1,recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Product_Category__cASI_CRM_CN_Product_Category')));
        ProductCategoryList.add(new ASI_HK_CRM_Product_Category__c(Name='Category2',ASI_CRM_CN_Chinese_Name__c='Category2',ASI_HK_CRM_English_Name__c='Category',ASI_HK_CRM_Sequence__c=2,recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Product_Category__cASI_CRM_CN_Product_Category')));
        ProductCategoryList.add(new ASI_HK_CRM_Product_Category__c(Name='Category3',ASI_CRM_CN_Chinese_Name__c='Category1',ASI_HK_CRM_English_Name__c='Category',ASI_HK_CRM_Sequence__c=3,recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Product_Category__cASI_CRM_CN_Product_Category')));
        
        insert ProductCategoryList;
        
        
        
        
        List<ASI_TH_CRM_Sub_category__c> SubCategoryList= new List<ASI_TH_CRM_Sub_category__c>();
        SubCategoryList.add(new ASI_TH_CRM_Sub_category__c(Name='SubCategory1',ASI_CRM_CN_Product_Category__c=ProductCategoryList[0].Id,recordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_Sub_category__cASI_CRM_CN_Sub_Category')));
        SubCategoryList.add(new ASI_TH_CRM_Sub_category__c(Name='SubCategory2',ASI_CRM_CN_Product_Category__c=ProductCategoryList[1].Id,recordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_Sub_category__cASI_CRM_CN_Sub_Category')));
        SubCategoryList.add(new ASI_TH_CRM_Sub_category__c(Name='SubCategory3',ASI_CRM_CN_Product_Category__c=ProductCategoryList[2].Id,recordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_Sub_category__cASI_CRM_CN_Sub_Category')));
        
        insert SubCategoryList;
        
        
        List<ASI_MFM_Brand__c> BrandList = new List<ASI_MFM_Brand__c> ();
        BrandList.add(new ASI_MFM_Brand__c (Name='Test1',ASI_CRM_CN_Competitor__c=false,ASI_TH_CRM_Sub_category__c=SubCategoryList[0].Id,recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Brand__cASI_FOC_CN_Brand')));
        BrandList.add(new ASI_MFM_Brand__c (Name='Test2',ASI_CRM_CN_Competitor__c=false,ASI_TH_CRM_Sub_category__c=SubCategoryList[1].Id,recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Brand__cASI_FOC_CN_Brand')));
        BrandList.add(new ASI_MFM_Brand__c (Name='Test3',ASI_CRM_CN_Competitor__c=false,ASI_TH_CRM_Sub_category__c=SubCategoryList[2].Id,recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Brand__cASI_FOC_CN_Brand')));
        
        Insert BrandList;
        
        
        
        
        //Sub Brand Grade
        list<ASI_CRM_Sub_Brand_Grade__c> grades = new list<ASI_CRM_Sub_Brand_Grade__c>();
        grades.add(new ASI_CRM_Sub_Brand_Grade__c (Name='Premium',ASI_CRM_Chinese_Name__c='Test1',ASI_CRM_Chinese_Description__c='1. Standard + Premium 标准档 + 高档',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_Sub_Brand_Grade__cASI_CRM_CN_Sub_brand_Grade')));
        grades.add(new ASI_CRM_Sub_Brand_Grade__c (Name='TEST2',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_Sub_Brand_Grade__cASI_CRM_CN_Sub_brand_Grade')));
        grades.add(new ASI_CRM_Sub_Brand_Grade__c (Name='TEST3',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_Sub_Brand_Grade__cASI_CRM_CN_Sub_brand_Grade')));
        insert grades;
        
        list<ASI_MFM_Sub_brand__c> subBrands = new list<ASI_MFM_Sub_brand__c>();
        for(ASI_CRM_Sub_Brand_Grade__c grade :grades) {
            subBrands.add(new ASI_MFM_Sub_brand__c (Name='TEST1',ASI_MFM_Active_for_CRM__c=true,ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,RecordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand'),
                                                    ASI_CRM_CN_Sub_brand_Grade__c=grade.Id,ASI_MFM_Brand__c=BrandList[0].Id));
            subBrands.add(new ASI_MFM_Sub_brand__c (Name='TEST2',ASI_MFM_Active_for_CRM__c=true,RecordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand'),
                                                    ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,
                                                    ASI_CRM_CN_Sub_brand_Grade__c=grade.Id,ASI_MFM_Brand__c=BrandList[1].Id));
            subBrands.add(new ASI_MFM_Sub_brand__c ( Name='TEST3',ASI_MFM_Active_for_CRM__c=true,RecordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand'),
                                                    ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,
                                                    ASI_CRM_CN_Sub_brand_Grade__c=grade.Id,ASI_MFM_Brand__c=BrandList[2].Id));
            subBrands.add(new ASI_MFM_Sub_brand__c ( Name='999',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand'),
                                                    ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,ASI_MFM_Sub_brand_Code__c = '999' ,ASI_MFM_Active_for_CRM__c = true ,
                                                    ASI_CRM_CN_Sub_brand_Grade__c=grade.Id,ASI_MFM_Brand__c=BrandList[0].Id));
        }
        
        insert subBrands;
        
        /*
        List<ASI_CRM_Sub_Brand_Assignment__c> SubBrandAssignmentList= new List<ASI_CRM_Sub_Brand_Assignment__c>();
        for(ASI_MFM_Sub_brand__c SubBrandItem:subBrands){
            SubBrandAssignmentList.add(new ASI_CRM_Sub_Brand_Assignment__c(ASI_CRM_Sub_Brand__c=SubBrandItem.Id,ASI_CRM_Segmentation_Criteria__c=SegmentationCriteria.Id));
        }
        
        insert SubBrandAssignmentList;
        */
        
        List<ASI_MFM_A_C_Code__c> ACCodeList = new  List<ASI_MFM_A_C_Code__c>();
        ACCodeList.add(new ASI_MFM_A_C_Code__c( Name='0000000000000', ASI_MFM_A_C_Code__c='000010000',ASI_MFM_A_C_Description__c='ASI_CRM_CN_Variable_Cost_Contract',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_CN_A_C_Code') ));
        ACCodeList.add(new ASI_MFM_A_C_Code__c( Name='5275.010000 PRC - Bottle Return Service', ASI_MFM_A_C_Code__c='5275.010000',ASI_MFM_A_C_Description__c='Bottle Return Service',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_CN_A_C_Code') ));
        ACCodeList.add(new ASI_MFM_A_C_Code__c( Name='5275.020000 Promotion Service Fee', ASI_MFM_A_C_Code__c='5275.020000',ASI_MFM_A_C_Description__c='Promotion Service Fee',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_CN_A_C_Code') ));
        ACCodeList.add(new ASI_MFM_A_C_Code__c( Name='5275.030000 PRC - Variable Event Cost', ASI_MFM_A_C_Code__c='5275.030000',ASI_MFM_A_C_Description__c='Variable Event Cost',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_CN_A_C_Code') ));
        ACCodeList.add(new ASI_MFM_A_C_Code__c( Name='5275.040000 PRC - Fixed Event Cost',ASI_MFM_A_C_CN_Description__c='夜店活动费用(固定)', ASI_MFM_A_C_Code__c='5275.040000',ASI_MFM_A_C_Description__c='PRC - Fixed Event Cost',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_CN_A_C_Code') ));
        
        insert ACCodeList;
        // ASI_TH_CRM_Contract__c.ASI_CRM_CN_Fixed_Module_Est_Amount1__c
        // ASI_CRM_CN_FixedMappingSetting__c setting = new ASI_CRM_CN_FixedMappingSetting__c();
        // setting.ASI_CRM_CN_Activity_CodeId__c = ACCodeList[4].Id;
        // setting.ASI_CRM_CN_Contract_Mapping_Field__c = 'ASI_CRM_CN_Fixed_Module_Est_Amount1__c';
        // setting.Name = ACCodeList[4].Id;
        // insert setting;
        
        
        List<ASI_CRM_Contract_Cost_Setting__c> ContractCostSettingList= new List<ASI_CRM_Contract_Cost_Setting__c>();
        
        ContractCostSettingList.add(new ASI_CRM_Contract_Cost_Setting__c(ASI_CRM_CN_Activity_Code__c=ACCodeList[0].Id,ASI_CRM_CN_Promotion_Type__c='Heavy Contract ON',
                                                                         ASI_CRM_CN_Fixed_Cost_Contract__c=true,ASI_CRM_CN_Variable_Cost_Contract__c=true));
        
        ContractCostSettingList.add(new ASI_CRM_Contract_Cost_Setting__c(ASI_CRM_CN_Activity_Code__c=ACCodeList[0].Id,ASI_CRM_CN_Promotion_Type__c='Heavy Contract ON',ASI_CRM_CN_Variable_Cost_Contract__c=true,
                                                                         ASI_CRM_CN_Fixed_Cost_Contract__c=false,ASI_CRM_CN_BRSF_Activity_Code_Default__c=true));
        
        ContractCostSettingList.add(new ASI_CRM_Contract_Cost_Setting__c(ASI_CRM_CN_Activity_Code__c=ACCodeList[0].Id,ASI_CRM_CN_Promotion_Type__c='Heavy Contract ON',ASI_CRM_CN_Variable_Cost_Contract__c=true,
                                                                         ASI_CRM_CN_Fixed_Cost_Contract__c=false,ASI_CRM_PSF_Activity_Code_Default__c=true));
        
        ContractCostSettingList.add(new ASI_CRM_Contract_Cost_Setting__c(ASI_CRM_CN_Activity_Code__c=ACCodeList[0].Id,ASI_CRM_CN_Promotion_Type__c='Heavy Contract ON',ASI_CRM_CN_Variable_Cost_Contract__c=true,
                                                                         ASI_CRM_CN_Fixed_Cost_Contract__c=false,ASI_CRM_VEC_Activity_Code_Defaul__c=true));
        ContractCostSettingList.add(new ASI_CRM_Contract_Cost_Setting__c(ASI_CRM_CN_Activity_Code__c=ACCodeList[4].Id,ASI_CRM_CN_Promotion_Type__c='Heavy Contract ON',
                                                                         ASI_CRM_CN_Fixed_Cost_Contract__c=true,ASI_CRM_CN_Variable_Cost_Contract__c=false));
        
        insert ContractCostSettingList;
        /*
        ASI_CRM_SpecialPromotionTypeSetting__c oldspts = new ASI_CRM_SpecialPromotionTypeSetting__c( ASI_CRM_Promotion_Type__c = 'a');
        insert oldspts;
        
        ASI_CRM_SpecialPromotionTypeSetting__c newspts = new ASI_CRM_SpecialPromotionTypeSetting__c(ASI_CRM_Promotion_Type__c = 'Heavy Contract On',recordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_SpecialPromotionTypeSetting__cASI_CRM_CN_SpecialPromotionTypeSetting'));
        insert newspts;
        
        ASI_CRM_Special_Promotion_Type_Mapping__c sptm = new ASI_CRM_Special_Promotion_Type_Mapping__c(ASI_CRM_Mapping_of_New_Promotion_Type__c = newspts.Id,ASI_CRM_Mapping_of_Old_Promotion_Type__c = oldspts.Id,recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Special_Promotion_Type_Mapping__cASI_CRM_CN_Special_Promotion_Type_Mapping'));
        insert sptm;
        
        */
        
        Date today = Date.newInstance(2019,5 ,25);
        Date PO_Start_Date = date.newinstance(today.year(), today.month(), 1);
        Date PO_End_Date = Date.newInstance(2020,5 ,31);
        
        
        ASI_TH_CRM_Contract__c GroupContract = new ASI_TH_CRM_Contract__c(recordtypeid = Global_RecordTypeCache.getRTID('ASI_TH_CRM_Contract__cASI_CRM_CN_Group_Contract'),
                                                                          ASI_CRM_CN_PO_Start_Date__c = PO_Start_Date,
                                                                          ASI_CRM_CN_PO_End_Date__c =PO_End_Date,
                                                                          Name = 'Noah C4',
                                                                          ASI_CRM_CN_Outlet_WS__c=Customers[1].Id);
        insert GroupContract;
        
        ASI_TH_CRM_Contract__c Contract = new ASI_TH_CRM_Contract__c(recordtypeid = Global_RecordTypeCache.getRTID('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract'),ASI_CRM_CN_Is_2nd_KPI_PO__c=true,
                                                                     ASI_CRM_CN_Status__c = 'Final',ASI_CRM_CN_Group_Contract__c=GroupContract.Id,
                                                                     ASI_CRM_CN_PO_Start_Date__c = PO_Start_Date,
                                                                     ASI_CRM_CN_PO_End_Date__c =PO_End_Date,
                                                                     ASI_CRM_CN_PO_Version__c = '0.0',ASI_TH_CRM_Promotion_Type__c='Heavy Contract On',
                                                                     Name = 'Contract1',
                                                                     ASI_CRM_CN_Outlet_WS__c=Customers[1].Id,ASI_CRM_Volume_Option__c = 'Normal');
        insert Contract;
        
        
        List<ASI_CRM_Methodology__c> MethodologyList= new List<ASI_CRM_Methodology__c> ();
        MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test1',ASI_CRM_Methodology_Code__c='01',ASI_CRM_Default__c=true,ASI_CRM_Chinese_Name__c='123',ASI_CRM_Type__c='BRSF',recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Methodology__cASI_CRM_CN_Methodology')));
        MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test2',ASI_CRM_Methodology_Code__c='01',ASI_CRM_Default__c=true,ASI_CRM_Chinese_Name__c='Test 123',ASI_CRM_Type__c='PSF',recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Methodology__cASI_CRM_CN_Methodology')));
        MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test3',ASI_CRM_Methodology_Code__c='01',ASI_CRM_Default__c=true,ASI_CRM_Chinese_Name__c='Test 123',ASI_CRM_Type__c='Variable Event Cost',recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Methodology__cASI_CRM_CN_Methodology')));
        
        
        MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test1',ASI_CRM_Methodology_Code__c='01',ASI_CRM_Chinese_Name__c='123',ASI_CRM_Type__c='BRSF',recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Methodology__cASI_CRM_CN_Methodology')));
        MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test2',ASI_CRM_Methodology_Code__c='01',ASI_CRM_Chinese_Name__c='123',ASI_CRM_Type__c='PSF',recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Methodology__cASI_CRM_CN_Methodology')));
        MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test3',ASI_CRM_Methodology_Code__c='01',ASI_CRM_Chinese_Name__c='123',ASI_CRM_Type__c='Variable Event Cost',recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Methodology__cASI_CRM_CN_Methodology')));
        insert MethodologyList;
        
        
        //Methodology Assignment
        List<ASI_CRM_Methodology_Assignment__c> MethodologyAssignmentList = new List<ASI_CRM_Methodology_Assignment__c>();
        MethodologyAssignmentList.add(new ASI_CRM_Methodology_Assignment__c(ASI_CRM_Methodology__c=MethodologyList[0].Id,ASI_CRM_Key_Principle__c=true,ASI_CRM_Methodology_Commercial_Team__c='Premium',ASI_CRM_Region__c=region.Id));
        MethodologyAssignmentList.add(new ASI_CRM_Methodology_Assignment__c(ASI_CRM_Methodology__c=MethodologyList[1].Id,ASI_CRM_Key_Principle__c=true,ASI_CRM_Methodology_Commercial_Team__c='Premium',ASI_CRM_Region__c=region.Id));
        MethodologyAssignmentList.add(new ASI_CRM_Methodology_Assignment__c(ASI_CRM_Methodology__c=MethodologyList[2].Id,ASI_CRM_Key_Principle__c=true,ASI_CRM_Methodology_Commercial_Team__c='Premium',ASI_CRM_Region__c=region.Id));
        MethodologyAssignmentList.add(new ASI_CRM_Methodology_Assignment__c(ASI_CRM_Methodology__c=MethodologyList[3].Id,ASI_CRM_Key_Principle__c=true,ASI_CRM_Methodology_Commercial_Team__c='Premium',ASI_CRM_Region__c=region.Id));
        MethodologyAssignmentList.add(new ASI_CRM_Methodology_Assignment__c(ASI_CRM_Methodology__c=MethodologyList[4].Id,ASI_CRM_Key_Principle__c=true,ASI_CRM_Methodology_Commercial_Team__c='Premium',ASI_CRM_Region__c=region.Id));
        MethodologyAssignmentList.add(new ASI_CRM_Methodology_Assignment__c(ASI_CRM_Methodology__c=MethodologyList[5].Id,ASI_CRM_Key_Principle__c=true,ASI_CRM_Methodology_Commercial_Team__c='Premium',ASI_CRM_Region__c=region.Id));
        
        insert MethodologyAssignmentList ;
        
        
        
        
        List<ASI_CRM_Module__c> ModuleList = new List<ASI_CRM_Module__c>();
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='Std. Btl.',ASI_CRM_Volume_Base__c='By Sub-Brand',ASI_CRM_Line_Type__c='BRSF',ASI_CRM_Methodology__c=MethodologyList[0].Id));
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='Std. Btl.',ASI_CRM_Volume_Base__c='By Sub-Brand',ASI_CRM_Line_Type__c='PSF',ASI_CRM_Methodology__c=MethodologyList[1].Id));
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='CR12 Extra Eqv.',ASI_CRM_Volume_Base__c='By Grade',ASI_CRM_Line_Type__c='PSF',ASI_CRM_Methodology__c=MethodologyList[1].Id));
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='CR12 Extra Eqv.',ASI_CRM_Volume_Base__c='By Category',ASI_CRM_Line_Type__c='PSF',ASI_CRM_Methodology__c=MethodologyList[1].Id));
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='CR12 Extra Eqv.',ASI_CRM_Volume_Base__c='By Total',ASI_CRM_Line_Type__c='PSF',ASI_CRM_Methodology__c=MethodologyList[1].Id));
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='CR12 Extra Eqv.',ASI_CRM_Volume_Base__c='By Sub-Brand',ASI_CRM_Line_Type__c='Variable Event Cost',ASI_CRM_Methodology__c=MethodologyList[2].Id));

        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='Std. Btl.',ASI_CRM_Volume_Base__c='By Sub-Brand',ASI_CRM_Line_Type__c='Fixed',ASI_CRM_CN_AC_Code__c = ACCodeList[4].Id, ASI_CRM_CN_AC_Code__r = ACCodeList[4]));
        
        insert ModuleList;
        /*
        ASI_CRM_Contract_Cost__c contractCost = new ASI_CRM_Contract_Cost__c(ASI_CRM_CN_Contract__c = Contract.id,
                                                                             ASI_CRM_CN_Estimate_Amount__c = 100000,
                                                                             ASI_CRM_CN_Cost_Type__c = 'Fixed',
                                                                             ASI_CRM_CN_Other_Cost_Payment_Request__c = true,
                                                                             recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_Contract_Cost__cASI_CRM_CN_Contract_Cost') );
        insert contractCost;
        */
        list<ASI_CRM_CN_Contract_BRSF_Line_Item__c> ContractLineList = new list<ASI_CRM_CN_Contract_BRSF_Line_Item__c>();
        list<ASI_CRM_CN_Covered_Outlet__c> cos = new list<ASI_CRM_CN_Covered_Outlet__c>();
        for(ASI_MFM_Sub_brand__c subBrand :subBrands) {
            ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract.Id,
                                                                           ASI_CRM_CN_Est_Monthly_Qty__c=1,ASI_CRM_Module__c=ModuleList[0].Id,
                                                                           ASI_CRM_CN_Contract_Monthly_Qty__c=1,
                                                                           ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,
                                                                           ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,ASI_CRM_Type__c='BRSF',
                                                                           ASI_CRM_CN_Sub_Brand__c=subBrand.Id,
                                                                           recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF')));
        }
        
        for(ASI_MFM_Sub_brand__c subBrand :subBrands) {
            ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract.Id,
                                                                           ASI_CRM_CN_Est_Monthly_Qty__c=1,ASI_CRM_Module__c=ModuleList[1].Id,
                                                                           ASI_CRM_CN_Contract_Monthly_Qty__c=1,ASI_CRM_Volume_Base__c='By Sub-Brand',
                                                                           ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,
                                                                           ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,ASI_CRM_Type__c='PSF',
                                                                           ASI_CRM_CN_Sub_Brand__c=subBrand.Id,
                                                                           recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF')));
        }
        
        ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract.Id,ASI_CRM_Type__c='PSF',ASI_CRM_Volume_Base__c='By Grade',
                                                                       ASI_CRM_CN_Est_Monthly_Qty__c=4,ASI_CRM_Module__c=ModuleList[2].Id,
                                                                       ASI_CRM_CN_Contract_Monthly_Qty__c=4,ASI_CRM_Sub_Brand_Grade__c=grades[0].Id,
                                                                       ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,
                                                                       ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,
                                                                       ASI_CRM_CN_Sub_Brand__c=null,
                                                                       recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF') ));
        ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract.Id,ASI_CRM_Type__c='PSF',ASI_CRM_Volume_Base__c='By Category',
                                                                       ASI_CRM_CN_Est_Monthly_Qty__c=4,ASI_CRM_Module__c=ModuleList[3].Id,
                                                                       ASI_CRM_CN_Contract_Monthly_Qty__c=4,ASI_CRM_Product_Category__c=ProductCategoryList[0].Id,
                                                                       ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,
                                                                       ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,
                                                                       ASI_CRM_CN_Sub_Brand__c=null,
                                                                       recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF') ));
        ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract.Id,ASI_CRM_Type__c='PSF',ASI_CRM_Volume_Base__c='By Total',
                                                                       ASI_CRM_CN_Est_Monthly_Qty__c=4,ASI_CRM_Module__c=ModuleList[4].Id,
                                                                       ASI_CRM_CN_Contract_Monthly_Qty__c=4,
                                                                       ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,
                                                                       ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,
                                                                       ASI_CRM_CN_Sub_Brand__c=null,
                                                                       recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF') ));
        for(ASI_MFM_Sub_brand__c subBrand :subBrands) {
            ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract.Id,
                                                                           ASI_CRM_CN_Est_Monthly_Qty__c=1,ASI_CRM_Module__c=ModuleList[6].Id,
                                                                           ASI_CRM_CN_Contract_Monthly_Qty__c=1,ASI_CRM_Volume_Base__c='By Sub-Brand',
                                                                           ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,ASI_CRM_CN_Activity_Code__r=ACCodeList[4],ASI_CRM_CN_Activity_Code__c=ACCodeList[4].Id,
                                                                           ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,ASI_CRM_Type__c='Fixed',
                                                                           ASI_CRM_CN_Sub_Brand__c=subBrand.Id,
                                                                           recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF')));
        }
        for(ASI_MFM_Sub_brand__c subBrand :subBrands) {
            ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract.Id,
                                                                           ASI_CRM_CN_Est_Monthly_Qty__c=1,ASI_CRM_Module__c=ModuleList[5].Id,
                                                                           ASI_CRM_CN_Contract_Monthly_Qty__c=1,ASI_CRM_Volume_Base__c='By Sub-Brand',
                                                                           ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,
                                                                           ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,ASI_CRM_Type__c='Variable Event Cost',
                                                                           ASI_CRM_CN_Sub_Brand__c=subBrand.Id,
                                                                           recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF')));
        }
        
        insert ContractLineList;
        
        
        test.startTest();
        
        
        // Integer coun = 1;
        // for(ASI_CRM_CN_Contract_BRSF_Line_Item__c ContractLine:ContractLineList){
        //     system.debug(coun+'ContractLineList: '+ContractLine);
        //     coun++;
        // }  
        
        
        
        
        // ASI_CRM_CN_EditHeavyContractDetailCtrl con2 = new ASI_CRM_CN_EditHeavyContractDetailCtrl(new ApexPages.Standardcontroller(Contract));
        // // System.debug(LoggingLevel.INFO, '*** ContractLineList: ' + ContractLineList);
        // ApexPages.currentPage().getParameters().put('PARAM_Line_ID', ContractLineList[15].id);
        // ApexPages.currentPage().getParameters().put('PARAM_item_ID', ModuleList[1].id);
        // con2.PSFChangingSB();
        
        // ApexPages.currentPage().getParameters().put('PARAM_Line_ID', ContractLineList[17].id);
        // ApexPages.currentPage().getParameters().put('PARAM_item_ID', ModuleList[1].id);
        // ApexPages.currentPage().getParameters().put('PARAM_Unit_ID','Std. Btl.');
        // con2.RemovePSFLine();
        
        
        

        // ApexPages.currentPage().getParameters().put('PARAM_Line_ID', ContractLineList[27].id);
        // ApexPages.currentPage().getParameters().put('PARAM_item_ID', ContractLineList[27].ASI_CRM_CN_Activity_Code__r.ASI_MFM_A_C_CN_Description__c);
        // ApexPages.currentPage().getParameters().put('PARAM_Unit_ID','Std. Btl.');
        // con2.RemoveFCLine();



        // ApexPages.currentPage().getParameters().put('SelectValue', 'CTD Monthly Volume');
        // con2.refreshBrsfItem();

        // ApexPages.currentPage().getParameters().put('SelectValue', 'V0.0');
        // con2.refreshBrsfItem();
        
        
        
        PageReference EnterPage = Page.ASI_CRM_CN_ViewHeavyContractPage;
        
        Map<String, String> pageParams = EnterPage.getParameters();
        
        pageParams.put('id', Contract.id);
        ApexPages.StandardController sc = new ApexPages.standardController(new ASI_TH_CRM_Contract__c());
        
        ASI_CRM_CN_EditHeavyContractDetailCtrl con = new ASI_CRM_CN_EditHeavyContractDetailCtrl(new ApexPages.Standardcontroller(Contract));
        // con.saveItems();
        // //con.SizeOfPSFMap = 1;
        
        
        
        // ApexPages.currentPage().getParameters().put('PARAM_Line_ID', ContractLineList[0].id);
        // con.Clone_BRSF();
        
        
        // ApexPages.currentPage().getParameters().put('PARAM_Line_ID', ContractLineList[1].id);
        // con.Remove_BRSF();
        // con.AddNew_BRSF();
        
        
        
        // con.LoopingReCalculatePSF();
        
        // con.PSFAddModule();
        // ApexPages.currentPage().getParameters().put('PARAM_Line_ID', ModuleList[1].id);
        // con.RefreshPSFModule();
        // ApexPages.currentPage().getParameters().put('PARAM_Line_ID', ModuleList[2].id);
        // con.RefreshPSFModule();
        // ApexPages.currentPage().getParameters().put('PARAM_Line_ID', ModuleList[3].id);
        // con.RefreshPSFModule();
        // ApexPages.currentPage().getParameters().put('PARAM_Line_ID', ModuleList[4].id);
        // con.RefreshPSFModule();
        
        // ApexPages.currentPage().getParameters().put('PARAM_Line_ID', ModuleList[1].id);
        // con.AddNewPSFLine();


        // // con.PSFAddModule();
        // ApexPages.currentPage().getParameters().put('PARAM_Line_ID', '夜店活动费用(固定)');
        // con.ResetFCDetails();

        // ApexPages.currentPage().getParameters().put('PARAM_Line_ID', '夜店活动费用(固定)');
        // con.RefreshFCModule();

        // ApexPages.currentPage().getParameters().put('PARAM_Line_ID', '夜店活动费用(固定)');
        // con.ResetFCDetails();
        // con.LFixCost2nd.get('夜店活动费用(固定)').Module.ASI_CRM_Volume_Base__c = 'By Sub-Brand';
        // ApexPages.currentPage().getParameters().put('PARAM_Line_ID', '夜店活动费用(固定)');

        // for (String key : con.BRSFItemMap.DetailLineMap.keySet()) {
        //     if (con.BRSFItemMap.DetailLineMap.get(key).ASI_CRM_CN_Sub_Brand__c == null) {
        //         con.BRSFItemMap.DetailLineMap.remove(key);
        //     }
        // }

        // System.debug(LoggingLevel.INFO, '*** con.BRSFItemMap.DetailLineMap: ' + con.BRSFItemMap.DetailLineMap);
        // con.RefreshFCModule();
        // Map<String,ASI_CRM_Module__c> PSFModuleMap = new Map<String,ASI_CRM_Module__c>();
        // Map<String,ASI_CRM_Module__c> FCModuleMap = new Map<String,ASI_CRM_Module__c>();
        // con.GenContractLine(ModuleList[0], ModuleList[5], PSFModuleMap,FCModuleMap);

        // ApexPages.currentPage().getParameters().put('PARAM_Line_ID', '夜店活动费用(固定)');
        // con.ResetFCDetails();
        // con.LFixCost2nd.get('夜店活动费用(固定)').Module.ASI_CRM_Volume_Base__c = 'By Grade';
        // ApexPages.currentPage().getParameters().put('PARAM_Line_ID', '夜店活动费用(固定)');
        // System.debug(LoggingLevel.INFO, '*** con.LFixCost2nd2: ' + con.LFixCost2nd);
        // con.RefreshFCModule();

        // ApexPages.currentPage().getParameters().put('PARAM_Line_ID', '夜店活动费用(固定)');
        // con.ResetFCDetails();
        // con.LFixCost2nd.get('夜店活动费用(固定)').Module.ASI_CRM_Volume_Base__c = 'By Category';
        // ApexPages.currentPage().getParameters().put('PARAM_Line_ID', '夜店活动费用(固定)');
        // System.debug(LoggingLevel.INFO, '*** con.LFixCost2nd3: ' + con.LFixCost2nd);
        // con.RefreshFCModule();
        
        // ApexPages.currentPage().getParameters().put('PARAM_Line_ID', '夜店活动费用(固定)');
        // con.AddNewFCLine();
        
        
        // ApexPages.currentPage().getParameters().put('PARAM_Line_ID', ContractLineList[33].id);
        // con.VECChangingSB();
        // con.AddNewVECLine();
        // ApexPages.currentPage().getParameters().put('PARAM_Line_ID', ContractLineList[34].id);
        // con.CloneVECLine();
        // ApexPages.currentPage().getParameters().put('PARAM_Line_ID', ContractLineList[35].id);
        // con.RemoveVECLine();
        
        
        // con.AddNew_CoveredOutlet();
        // ASI_CRM_CN_EditHeavyContractDetailCtrl.GenerateCutOffDate(Date.today());
        // con.saveItems();
        
        
        // ApexPages.currentPage().getParameters().put('PARAMID', ModuleList[1].id);
        // con.DeletePSFModule();
        
        con.BRSFClearAll();
        con.ModuleChecking();
        con.RefreshVECModule();
        con.ResetVECDetails();
        con.CopyHistoricalV0Contract();
        // con.ResetPSFDetails();
        List<sObject> TempList= ASI_CRM_CN_EditHeavyContractDetailCtrl.FindSubBrandList2nd('ASI_MFM_Sub_brand__c',' WHERE RecordType.DeveloperName = \'ASI_FOC_CN_Sub_brand\' ','Premium','2',Contract.Id,region.Name);

        // ASI_CRM_CN_HeavyContractHeaderCtrl2nd con4 = new ASI_CRM_CN_HeavyContractHeaderCtrl2nd(new ApexPages.Standardcontroller(Contract));
        // con4.POModificationProcess12nd(Contract);
        // ASI_CRM_CN_EditHeavyContractDetailCtrl con3 = new ASI_CRM_CN_EditHeavyContractDetailCtrl(new ApexPages.Standardcontroller(Contract));

        // con3.updateLineData();

        // con3.v00UpdateLineData();

        // con3.updateModuleQty();


        test.stopTest(); 
    }

    static testMethod void EditHeavyContractDetailCtrlTest7(){
        ASI_CRM_Region__c region = new ASI_CRM_Region__c (Name='Central Region',recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Region__cASI_CRM_CN_Region'));
        insert region;
        
        ASI_CRM_Division__c division = new ASI_CRM_Division__c(Name='TEST', ASI_CRM_Region__c=region.Id);
        insert division;
        
        ASI_CRM_CN_Area__c area = new ASI_CRM_CN_Area__c(Name='TEST', ASI_CRM_English_Name__c='TEST', ASI_CRM_Division__c=division.Id);
        insert area;
        
        ASI_CRM_City__c city = new ASI_CRM_City__c(Name='TEST', ASI_CRM_CN_Area__c=area.Id,ASI_CRM_CN_City_Tier__c='2');
        insert city;
        
        /*ASI_CRM_CN_Channel__c channel = new ASI_CRM_CN_Channel__c(Name='KTV',ASI_CRM_BC_Rate__c=98,ASI_CRM_CN_On_Off__c='ON',ASI_CRM_For_Outlet__c=true,RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CN_Channel__cASI_CRM_CN_New_Channel'),ASI_CRM_For_Contract__c=TRUE);
        insert channel;*/
        
        ASI_CRM_CN_Channel__c channel = new ASI_CRM_CN_Channel__c(ASI_CRM_CN_On_Off__c='ON');
        insert channel;
        /*
        ASI_CRM_SegmentationCriteria__c SegmentationCriteria= new ASI_CRM_SegmentationCriteria__c (Name='Test',ASI_CRM_Channel__c=channel.Id, ASI_CRM_Outlet_New_Image__c='Iconic',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_SegmentationCriteria__cASI_CRM_CN_Segmentation_Criteria'));
        INSERT SegmentationCriteria;
        
        Id rtWS = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_CN_WS');
        Id rtOutlet = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN');
        */
        ASI_MFM_Sub_Channel__c subChannel = new ASI_MFM_Sub_Channel__c(ASI_CRM_CN_Channel__c=channel.Id);
        insert subChannel;
        
        ASI_CRM_CN_Channel__c newChannel = new ASI_CRM_CN_Channel__c(ASI_CRM_For_Outlet__c = true, Name='Restaurant',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CN_Channel__cASI_CRM_CN_New_Channel'),ASI_CRM_CN_On_Off__c='OFF');
        insert newChannel;
        
        list<ASI_CRM_AccountsAdditionalField__c> Customers = new list<ASI_CRM_AccountsAdditionalField__c>();
        Customers.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Eng_Name__c = 'b', ASI_CRM_CN_Chi_Name__c = 'b', ASI_CRM_CN_Commercial_Team__c = 'Premium', ASI_CRM_CN_Sub_Channel__c=subChannel.Id, ASI_CRM_CN_CCity__c=city.Id, ASI_CRM_Latest_Call_Plan_Date__c=system.today(), RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN'), ASI_CRM_CN_NewChannel__c = newChannel.Id, ASI_CRM_CN_Type_of_Restaurant__c = 'International',ASI_CRM_CN_Spending_per_head__c=1));
        Customers.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Eng_Name__c = 'c', ASI_CRM_CN_Chi_Name__c = 'c', ASI_CRM_CN_Commercial_Team__c = 'Premium', ASI_CRM_CN_Sub_Channel__c=subChannel.Id, ASI_CRM_CN_CCity__c=city.Id, ASI_CRM_Latest_Call_Plan_Date__c=system.today(), RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN'), ASI_CRM_CN_NewChannel__c = newChannel.Id, ASI_CRM_CN_Type_of_Restaurant__c = 'International',ASI_CRM_CN_Spending_per_head__c=1));
        insert Customers;
        /*
        
        list<ASI_CRM_AccountsAdditionalField__c> ChildCustomers = new list<ASI_CRM_AccountsAdditionalField__c>();
        ChildCustomers.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Parent_Outlet__c=Customers[1].Id,ASI_CRM_CN_Eng_Name__c = 'a', ASI_CRM_CN_Chi_Name__c = 'a', ASI_CRM_CN_Commercial_Team__c = 'Premium', ASI_CRM_CN_Sub_Channel__c=subChannel.Id, ASI_CRM_CN_CCity__c=city.Id, ASI_CRM_Latest_Call_Plan_Date__c=system.today(), RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN'), ASI_CRM_CN_NewChannel__c = newChannel.Id, ASI_CRM_CN_Type_of_Restaurant__c = 'International',ASI_CRM_CN_Spending_per_head__c=1));
        insert ChildCustomers;
        
        */
        
        User currentUser = [SELECT id, name, Managerid, ASI_CRM_CN_Prefix__c,LanguageLocaleKey FROM USER WHERE id =:UserInfo.getUserId()];
        currentUser.LanguageLocaleKey='zh_CN';
        update currentUser;
        
        list<ASI_HK_CRM_Running_Number__c> rns = new list<ASI_HK_CRM_Running_Number__c>();
        rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_TH_CRM_Contract__c', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_TH_CRM_PaymentRequest__c', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        if(!String.isBlank(currentUser.ASI_CRM_CN_Prefix__c))
            rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_'+currentUser.ASI_CRM_CN_Prefix__c, recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        else{
            rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_NULL', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
            rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        }
        insert rns;
        
        
        
        
        
        List<ASI_HK_CRM_Product_Category__c> ProductCategoryList= new List<ASI_HK_CRM_Product_Category__c> ();
        ProductCategoryList.add(new ASI_HK_CRM_Product_Category__c(Name='Category1',ASI_CRM_CN_Chinese_Name__c='Category',ASI_HK_CRM_English_Name__c='Category',ASI_HK_CRM_Sequence__c=1,recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Product_Category__cASI_CRM_CN_Product_Category')));
        ProductCategoryList.add(new ASI_HK_CRM_Product_Category__c(Name='Category2',ASI_CRM_CN_Chinese_Name__c='Category2',ASI_HK_CRM_English_Name__c='Category',ASI_HK_CRM_Sequence__c=2,recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Product_Category__cASI_CRM_CN_Product_Category')));
        ProductCategoryList.add(new ASI_HK_CRM_Product_Category__c(Name='Category3',ASI_CRM_CN_Chinese_Name__c='Category1',ASI_HK_CRM_English_Name__c='Category',ASI_HK_CRM_Sequence__c=3,recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Product_Category__cASI_CRM_CN_Product_Category')));
        
        insert ProductCategoryList;
        
        
        
        
        List<ASI_TH_CRM_Sub_category__c> SubCategoryList= new List<ASI_TH_CRM_Sub_category__c>();
        SubCategoryList.add(new ASI_TH_CRM_Sub_category__c(Name='SubCategory1',ASI_CRM_CN_Product_Category__c=ProductCategoryList[0].Id,recordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_Sub_category__cASI_CRM_CN_Sub_Category')));
        SubCategoryList.add(new ASI_TH_CRM_Sub_category__c(Name='SubCategory2',ASI_CRM_CN_Product_Category__c=ProductCategoryList[1].Id,recordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_Sub_category__cASI_CRM_CN_Sub_Category')));
        SubCategoryList.add(new ASI_TH_CRM_Sub_category__c(Name='SubCategory3',ASI_CRM_CN_Product_Category__c=ProductCategoryList[2].Id,recordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_Sub_category__cASI_CRM_CN_Sub_Category')));
        
        insert SubCategoryList;
        
        
        List<ASI_MFM_Brand__c> BrandList = new List<ASI_MFM_Brand__c> ();
        BrandList.add(new ASI_MFM_Brand__c (Name='Test1',ASI_CRM_CN_Competitor__c=false,ASI_TH_CRM_Sub_category__c=SubCategoryList[0].Id,recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Brand__cASI_FOC_CN_Brand'),ASI_HK_CRM_Product_Category__c=ProductCategoryList[0].Id));
        BrandList.add(new ASI_MFM_Brand__c (Name='Test2',ASI_CRM_CN_Competitor__c=false,ASI_TH_CRM_Sub_category__c=SubCategoryList[1].Id,recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Brand__cASI_FOC_CN_Brand'),ASI_HK_CRM_Product_Category__c=ProductCategoryList[1].Id));
        BrandList.add(new ASI_MFM_Brand__c (Name='Test3',ASI_CRM_CN_Competitor__c=false,ASI_TH_CRM_Sub_category__c=SubCategoryList[2].Id,recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Brand__cASI_FOC_CN_Brand'),ASI_HK_CRM_Product_Category__c=ProductCategoryList[2].Id));
        
        Insert BrandList;
        
        
        
        
        //Sub Brand Grade
        list<ASI_CRM_Sub_Brand_Grade__c> grades = new list<ASI_CRM_Sub_Brand_Grade__c>();
        grades.add(new ASI_CRM_Sub_Brand_Grade__c (Name='Premium',ASI_CRM_Chinese_Name__c='Test1',ASI_CRM_Chinese_Description__c='1. Standard + Premium 标准档 + 高档',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_Sub_Brand_Grade__cASI_CRM_CN_Sub_brand_Grade')));
        grades.add(new ASI_CRM_Sub_Brand_Grade__c (Name='TEST2',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_Sub_Brand_Grade__cASI_CRM_CN_Sub_brand_Grade')));
        grades.add(new ASI_CRM_Sub_Brand_Grade__c (Name='TEST3',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_Sub_Brand_Grade__cASI_CRM_CN_Sub_brand_Grade')));
        insert grades;
        
        list<ASI_MFM_Sub_brand__c> subBrands = new list<ASI_MFM_Sub_brand__c>();
        for(ASI_CRM_Sub_Brand_Grade__c grade :grades) {
            subBrands.add(new ASI_MFM_Sub_brand__c (Name='TEST1',ASI_MFM_Active_for_CRM__c=true,ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,RecordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand'),
                                                    ASI_CRM_CN_Sub_brand_Grade__c=grade.Id,ASI_MFM_Brand__c=BrandList[0].Id));
            subBrands.add(new ASI_MFM_Sub_brand__c (Name='TEST2',ASI_MFM_Active_for_CRM__c=true,RecordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand'),
                                                    ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,
                                                    ASI_CRM_CN_Sub_brand_Grade__c=grade.Id,ASI_MFM_Brand__c=BrandList[1].Id));
            subBrands.add(new ASI_MFM_Sub_brand__c ( Name='TEST3',ASI_MFM_Active_for_CRM__c=true,RecordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand'),
                                                    ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,
                                                    ASI_CRM_CN_Sub_brand_Grade__c=grade.Id,ASI_MFM_Brand__c=BrandList[2].Id));
            subBrands.add(new ASI_MFM_Sub_brand__c ( Name='999',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand'),
                                                    ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,ASI_MFM_Sub_brand_Code__c = '999' ,ASI_MFM_Active_for_CRM__c = true ,
                                                    ASI_CRM_CN_Sub_brand_Grade__c=grade.Id,ASI_MFM_Brand__c=BrandList[0].Id));
        }
        
        insert subBrands;
        
        /*
        List<ASI_CRM_Sub_Brand_Assignment__c> SubBrandAssignmentList= new List<ASI_CRM_Sub_Brand_Assignment__c>();
        for(ASI_MFM_Sub_brand__c SubBrandItem:subBrands){
            SubBrandAssignmentList.add(new ASI_CRM_Sub_Brand_Assignment__c(ASI_CRM_Sub_Brand__c=SubBrandItem.Id,ASI_CRM_Segmentation_Criteria__c=SegmentationCriteria.Id));
        }
        
        insert SubBrandAssignmentList;
        */
        
        List<ASI_MFM_A_C_Code__c> ACCodeList = new  List<ASI_MFM_A_C_Code__c>();
        ACCodeList.add(new ASI_MFM_A_C_Code__c( Name='0000000000000', ASI_MFM_A_C_Code__c='000010000',ASI_MFM_A_C_Description__c='ASI_CRM_CN_Variable_Cost_Contract',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_CN_A_C_Code') ));
        ACCodeList.add(new ASI_MFM_A_C_Code__c( Name='5275.010000 PRC - Bottle Return Service', ASI_MFM_A_C_Code__c='5275.010000',ASI_MFM_A_C_Description__c='Bottle Return Service',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_CN_A_C_Code') ));
        ACCodeList.add(new ASI_MFM_A_C_Code__c( Name='5275.020000 Promotion Service Fee', ASI_MFM_A_C_Code__c='5275.020000',ASI_MFM_A_C_Description__c='Promotion Service Fee',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_CN_A_C_Code') ));
        ACCodeList.add(new ASI_MFM_A_C_Code__c( Name='5275.030000 PRC - Variable Event Cost', ASI_MFM_A_C_Code__c='5275.030000',ASI_MFM_A_C_Description__c='Variable Event Cost',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_CN_A_C_Code') ));
        ACCodeList.add(new ASI_MFM_A_C_Code__c( Name='5275.040000 PRC - Fixed Event Cost',ASI_MFM_A_C_CN_Description__c='夜店活动费用(固定)', ASI_MFM_A_C_Code__c='5275.040000',ASI_MFM_A_C_Description__c='PRC - Fixed Event Cost',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_CN_A_C_Code') ));

        ACCodeList.add(new ASI_MFM_A_C_Code__c( Name='5260.100000 PRC - Store/Outlet Support',ASI_MFM_A_C_CN_Description__c='店家支持', ASI_MFM_A_C_Code__c='5260.100000',ASI_MFM_A_C_Description__c='PRC - Store/Outlet Support',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_CN_A_C_Code') ));
        
        insert ACCodeList;
        // ASI_TH_CRM_Contract__c.ASI_CRM_CN_Fixed_Module_Est_Amount1__c
        ASI_CRM_CN_FixedMappingSetting__c setting = new ASI_CRM_CN_FixedMappingSetting__c();
        setting.ASI_CRM_CN_Activity_CodeId__c = ACCodeList[4].Id;
        setting.ASI_CRM_CN_Contract_Mapping_Field__c = 'ASI_CRM_CN_Fixed_Module_Est_Amount1__c';
        setting.Name = ACCodeList[4].Id;
        insert setting;

        ASI_CRM_CN_FixedMappingSetting__c setting1 = new ASI_CRM_CN_FixedMappingSetting__c();
        setting1.ASI_CRM_CN_Activity_CodeId__c = ACCodeList[5].Id;
        setting1.ASI_CRM_CN_Contract_Mapping_Field__c = 'ASI_CRM_CN_Fixed_Module_Est_Amount2__c';
        setting1.Name = ACCodeList[5].Id;
        insert setting1;
        
        
        List<ASI_CRM_Contract_Cost_Setting__c> ContractCostSettingList= new List<ASI_CRM_Contract_Cost_Setting__c>();
        
        ContractCostSettingList.add(new ASI_CRM_Contract_Cost_Setting__c(ASI_CRM_CN_Activity_Code__c=ACCodeList[0].Id,ASI_CRM_CN_Promotion_Type__c='Heavy Contract ON',
                                                                         ASI_CRM_CN_Fixed_Cost_Contract__c=true,ASI_CRM_CN_Variable_Cost_Contract__c=true));
        
        ContractCostSettingList.add(new ASI_CRM_Contract_Cost_Setting__c(ASI_CRM_CN_Activity_Code__c=ACCodeList[0].Id,ASI_CRM_CN_Promotion_Type__c='Heavy Contract ON',ASI_CRM_CN_Variable_Cost_Contract__c=true,
                                                                         ASI_CRM_CN_Fixed_Cost_Contract__c=false,ASI_CRM_CN_BRSF_Activity_Code_Default__c=true));
        
        ContractCostSettingList.add(new ASI_CRM_Contract_Cost_Setting__c(ASI_CRM_CN_Activity_Code__c=ACCodeList[0].Id,ASI_CRM_CN_Promotion_Type__c='Heavy Contract ON',ASI_CRM_CN_Variable_Cost_Contract__c=true,
                                                                         ASI_CRM_CN_Fixed_Cost_Contract__c=false,ASI_CRM_PSF_Activity_Code_Default__c=true));
        
        ContractCostSettingList.add(new ASI_CRM_Contract_Cost_Setting__c(ASI_CRM_CN_Activity_Code__c=ACCodeList[0].Id,ASI_CRM_CN_Promotion_Type__c='Heavy Contract ON',ASI_CRM_CN_Variable_Cost_Contract__c=true,
                                                                         ASI_CRM_CN_Fixed_Cost_Contract__c=false,ASI_CRM_VEC_Activity_Code_Defaul__c=true));
        ContractCostSettingList.add(new ASI_CRM_Contract_Cost_Setting__c(ASI_CRM_CN_Activity_Code__c=ACCodeList[4].Id,ASI_CRM_CN_Promotion_Type__c='Heavy Contract ON',
                                                                         ASI_CRM_CN_Fixed_Cost_Contract__c=true,ASI_CRM_CN_Variable_Cost_Contract__c=false));
        
        insert ContractCostSettingList;
        /*
        ASI_CRM_SpecialPromotionTypeSetting__c oldspts = new ASI_CRM_SpecialPromotionTypeSetting__c( ASI_CRM_Promotion_Type__c = 'a');
        insert oldspts;
        
        ASI_CRM_SpecialPromotionTypeSetting__c newspts = new ASI_CRM_SpecialPromotionTypeSetting__c(ASI_CRM_Promotion_Type__c = 'Heavy Contract On',recordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_SpecialPromotionTypeSetting__cASI_CRM_CN_SpecialPromotionTypeSetting'));
        insert newspts;
        
        ASI_CRM_Special_Promotion_Type_Mapping__c sptm = new ASI_CRM_Special_Promotion_Type_Mapping__c(ASI_CRM_Mapping_of_New_Promotion_Type__c = newspts.Id,ASI_CRM_Mapping_of_Old_Promotion_Type__c = oldspts.Id,recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Special_Promotion_Type_Mapping__cASI_CRM_CN_Special_Promotion_Type_Mapping'));
        insert sptm;
        
        */
        
        Date today = Date.newInstance(2020, 5, 25);
        Date PO_Start_Date = date.newinstance(today.year(), today.month(), 1);
        Date PO_End_Date = PO_Start_Date.addMonths(1)-1;
        
        
        ASI_TH_CRM_Contract__c GroupContract = new ASI_TH_CRM_Contract__c(recordtypeid = Global_RecordTypeCache.getRTID('ASI_TH_CRM_Contract__cASI_CRM_CN_Group_Contract'),ASI_CRM_CN_Is_2nd_KPI_PO__c=true,
                                                                          ASI_CRM_CN_PO_Start_Date__c = PO_Start_Date,
                                                                          ASI_CRM_CN_PO_End_Date__c =PO_End_Date,
                                                                          Name = 'Noah C4',
                                                                          ASI_CRM_CN_Outlet_WS__c=Customers[1].Id);
        insert GroupContract;
        
        ASI_TH_CRM_Contract__c Contract = new ASI_TH_CRM_Contract__c(recordtypeid = Global_RecordTypeCache.getRTID('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract'),ASI_CRM_CN_Is_2nd_KPI_PO__c=true,
                                                                     ASI_CRM_CN_Status__c = 'Final',ASI_CRM_CN_Group_Contract__c=GroupContract.Id,
                                                                     ASI_CRM_CN_PO_Start_Date__c = PO_Start_Date,
                                                                     ASI_CRM_CN_PO_End_Date__c =PO_End_Date,
                                                                     ASI_CRM_CN_PO_Version__c = '0.0',ASI_TH_CRM_Promotion_Type__c='Heavy Contract On',
                                                                     Name = 'Contract1',
                                                                     ASI_CRM_CN_Outlet_WS__c=Customers[1].Id,ASI_CRM_Volume_Option__c = 'Normal');
        insert Contract;
        
        
        List<ASI_CRM_Methodology__c> MethodologyList= new List<ASI_CRM_Methodology__c> ();
        MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test1',ASI_CRM_Methodology_Code__c='01',ASI_CRM_Default__c=true,ASI_CRM_Chinese_Name__c='123',ASI_CRM_Type__c='BRSF',recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Methodology__cASI_CRM_CN_Methodology')));
        MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test2',ASI_CRM_Methodology_Code__c='01',ASI_CRM_Default__c=true,ASI_CRM_Chinese_Name__c='Test 123',ASI_CRM_Type__c='PSF',recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Methodology__cASI_CRM_CN_Methodology')));
        MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test3',ASI_CRM_Methodology_Code__c='01',ASI_CRM_Default__c=true,ASI_CRM_Chinese_Name__c='Test 123',ASI_CRM_Type__c='Variable Event Cost',recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Methodology__cASI_CRM_CN_Methodology')));
        
        
        MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test1',ASI_CRM_Methodology_Code__c='01',ASI_CRM_Chinese_Name__c='123',ASI_CRM_Type__c='BRSF',recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Methodology__cASI_CRM_CN_Methodology')));
        MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test2',ASI_CRM_Methodology_Code__c='01',ASI_CRM_Chinese_Name__c='123',ASI_CRM_Type__c='PSF',recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Methodology__cASI_CRM_CN_Methodology')));
        MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test3',ASI_CRM_Methodology_Code__c='01',ASI_CRM_Chinese_Name__c='123',ASI_CRM_Type__c='Variable Event Cost',recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Methodology__cASI_CRM_CN_Methodology')));
        insert MethodologyList;
        
        
        //Methodology Assignment
        List<ASI_CRM_Methodology_Assignment__c> MethodologyAssignmentList = new List<ASI_CRM_Methodology_Assignment__c>();
        MethodologyAssignmentList.add(new ASI_CRM_Methodology_Assignment__c(ASI_CRM_Methodology__c=MethodologyList[0].Id,ASI_CRM_Key_Principle__c=true,ASI_CRM_Methodology_Commercial_Team__c='Premium',ASI_CRM_Region__c=region.Id));
        MethodologyAssignmentList.add(new ASI_CRM_Methodology_Assignment__c(ASI_CRM_Methodology__c=MethodologyList[1].Id,ASI_CRM_Key_Principle__c=true,ASI_CRM_Methodology_Commercial_Team__c='Premium',ASI_CRM_Region__c=region.Id));
        MethodologyAssignmentList.add(new ASI_CRM_Methodology_Assignment__c(ASI_CRM_Methodology__c=MethodologyList[2].Id,ASI_CRM_Key_Principle__c=true,ASI_CRM_Methodology_Commercial_Team__c='Premium',ASI_CRM_Region__c=region.Id));
        MethodologyAssignmentList.add(new ASI_CRM_Methodology_Assignment__c(ASI_CRM_Methodology__c=MethodologyList[3].Id,ASI_CRM_Key_Principle__c=true,ASI_CRM_Methodology_Commercial_Team__c='Premium',ASI_CRM_Region__c=region.Id));
        MethodologyAssignmentList.add(new ASI_CRM_Methodology_Assignment__c(ASI_CRM_Methodology__c=MethodologyList[4].Id,ASI_CRM_Key_Principle__c=true,ASI_CRM_Methodology_Commercial_Team__c='Premium',ASI_CRM_Region__c=region.Id));
        MethodologyAssignmentList.add(new ASI_CRM_Methodology_Assignment__c(ASI_CRM_Methodology__c=MethodologyList[5].Id,ASI_CRM_Key_Principle__c=true,ASI_CRM_Methodology_Commercial_Team__c='Premium',ASI_CRM_Region__c=region.Id));
        
        insert MethodologyAssignmentList ;
        
        
        
        
        List<ASI_CRM_Module__c> ModuleList = new List<ASI_CRM_Module__c>();
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='Std. Btl.',ASI_CRM_Volume_Base__c='By Sub-Brand',ASI_CRM_Line_Type__c='BRSF',ASI_CRM_Methodology__c=MethodologyList[0].Id));
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='Std. Btl.',ASI_CRM_Volume_Base__c='By Sub-Brand',ASI_CRM_Line_Type__c='PSF',ASI_CRM_Methodology__c=MethodologyList[1].Id));
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='CR12 Extra Eqv.',ASI_CRM_Volume_Base__c='By Grade',ASI_CRM_Line_Type__c='PSF',ASI_CRM_Methodology__c=MethodologyList[1].Id));
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='CR12 Extra Eqv.',ASI_CRM_Volume_Base__c='By Category',ASI_CRM_Line_Type__c='PSF',ASI_CRM_Methodology__c=MethodologyList[1].Id));
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='CR12 Extra Eqv.',ASI_CRM_Volume_Base__c='By Total',ASI_CRM_Line_Type__c='PSF',ASI_CRM_Methodology__c=MethodologyList[1].Id));
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='CR12 Extra Eqv.',ASI_CRM_Volume_Base__c='By Sub-Brand',ASI_CRM_Line_Type__c='Variable Event Cost',ASI_CRM_Methodology__c=MethodologyList[2].Id));

        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='Std. Btl.',ASI_CRM_Volume_Base__c='By Sub-Brand',ASI_CRM_Line_Type__c='Fixed',ASI_CRM_CN_AC_Code__c = ACCodeList[4].Id, ASI_CRM_CN_AC_Code__r = ACCodeList[4]));

        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='Std. Btl.',ASI_CRM_Volume_Base__c='By Sub-Brand',ASI_CRM_Line_Type__c='Fixed',ASI_CRM_CN_AC_Code__c = ACCodeList[5].Id, ASI_CRM_CN_AC_Code__r = ACCodeList[5]));
        
        insert ModuleList;
        /*
        ASI_CRM_Contract_Cost__c contractCost = new ASI_CRM_Contract_Cost__c(ASI_CRM_CN_Contract__c = Contract.id,
                                                                             ASI_CRM_CN_Estimate_Amount__c = 100000,
                                                                             ASI_CRM_CN_Cost_Type__c = 'Fixed',
                                                                             ASI_CRM_CN_Other_Cost_Payment_Request__c = true,
                                                                             recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_Contract_Cost__cASI_CRM_CN_Contract_Cost') );
        insert contractCost;
        */
        list<ASI_CRM_CN_Contract_BRSF_Line_Item__c> ContractLineList = new list<ASI_CRM_CN_Contract_BRSF_Line_Item__c>();
        list<ASI_CRM_CN_Covered_Outlet__c> cos = new list<ASI_CRM_CN_Covered_Outlet__c>();
        for(ASI_MFM_Sub_brand__c subBrand :subBrands) {
            ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract.Id,
                                                                           ASI_CRM_CN_Est_Monthly_Qty__c=1,ASI_CRM_Module__c=ModuleList[0].Id,
                                                                           ASI_CRM_CN_Contract_Monthly_Qty__c=1,
                                                                           ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,
                                                                           ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,ASI_CRM_Type__c='BRSF',
                                                                           ASI_CRM_CN_Sub_Brand__c=subBrand.Id,
                                                                           recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF')));
        }
        
        for(ASI_MFM_Sub_brand__c subBrand :subBrands) {
            ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract.Id,
                                                                           ASI_CRM_CN_Est_Monthly_Qty__c=1,ASI_CRM_Module__c=ModuleList[1].Id,
                                                                           ASI_CRM_CN_Contract_Monthly_Qty__c=1,ASI_CRM_Volume_Base__c='By Sub-Brand',
                                                                           ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,
                                                                           ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,ASI_CRM_Type__c='PSF',
                                                                           ASI_CRM_CN_Sub_Brand__c=subBrand.Id,
                                                                           recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF')));
        }
        
        ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract.Id,ASI_CRM_Type__c='PSF',ASI_CRM_Volume_Base__c='By Grade',
                                                                       ASI_CRM_CN_Est_Monthly_Qty__c=4,ASI_CRM_Module__c=ModuleList[2].Id,
                                                                       ASI_CRM_CN_Contract_Monthly_Qty__c=4,ASI_CRM_Sub_Brand_Grade__c=grades[0].Id,
                                                                       ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,
                                                                       ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,
                                                                       ASI_CRM_CN_Sub_Brand__c=null,
                                                                       recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF') ));
        ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract.Id,ASI_CRM_Type__c='PSF',ASI_CRM_Volume_Base__c='By Category',
                                                                       ASI_CRM_CN_Est_Monthly_Qty__c=4,ASI_CRM_Module__c=ModuleList[3].Id,
                                                                       ASI_CRM_CN_Contract_Monthly_Qty__c=4,ASI_CRM_Product_Category__c=ProductCategoryList[0].Id,
                                                                       ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,
                                                                       ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,
                                                                       ASI_CRM_CN_Sub_Brand__c=null,
                                                                       recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF') ));
        ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract.Id,ASI_CRM_Type__c='PSF',ASI_CRM_Volume_Base__c='By Total',
                                                                       ASI_CRM_CN_Est_Monthly_Qty__c=4,ASI_CRM_Module__c=ModuleList[4].Id,
                                                                       ASI_CRM_CN_Contract_Monthly_Qty__c=4,
                                                                       ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,
                                                                       ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,
                                                                       ASI_CRM_CN_Sub_Brand__c=null,
                                                                       recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF') ));
        ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract.Id,ASI_CRM_Type__c='Fixed',ASI_CRM_Volume_Base__c='By Category',
                                                                       ASI_CRM_CN_Est_Monthly_Qty__c=4,ASI_CRM_Module__c=ModuleList[7].Id,
                                                                       ASI_CRM_CN_Contract_Monthly_Qty__c=4,ASI_CRM_Product_Category__c=ProductCategoryList[0].Id,
                                                                       ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,
                                                                       ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,ASI_CRM_CN_Activity_Code__r=ACCodeList[4],ASI_CRM_CN_Activity_Code__c=ACCodeList[4].Id,
                                                                       ASI_CRM_CN_Sub_Brand__c=null,
                                                                       recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF') ));
        for(ASI_MFM_Sub_brand__c subBrand :subBrands) {
            ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract.Id,
                                                                           ASI_CRM_CN_Est_Monthly_Qty__c=1,ASI_CRM_Module__c=ModuleList[6].Id,
                                                                           ASI_CRM_CN_Contract_Monthly_Qty__c=1,ASI_CRM_Volume_Base__c='By Sub-Brand',
                                                                           ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,ASI_CRM_CN_Activity_Code__r=ACCodeList[4],ASI_CRM_CN_Activity_Code__c=ACCodeList[4].Id,
                                                                           ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,ASI_CRM_Type__c='Fixed',
                                                                           ASI_CRM_CN_Sub_Brand__c=subBrand.Id,
                                                                           recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF')));
        }
        for(ASI_MFM_Sub_brand__c subBrand :subBrands) {
            ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract.Id,
                                                                           ASI_CRM_CN_Est_Monthly_Qty__c=1,ASI_CRM_Module__c=ModuleList[5].Id,
                                                                           ASI_CRM_CN_Contract_Monthly_Qty__c=1,ASI_CRM_Volume_Base__c='By Sub-Brand',
                                                                           ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,
                                                                           ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,ASI_CRM_Type__c='Variable Event Cost',
                                                                           ASI_CRM_CN_Sub_Brand__c=subBrand.Id,
                                                                           recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF')));
        }
        
        insert ContractLineList;

        contract.ASI_CRM_CN_Status__c = 'Final';
        update Contract;
        Date PO_Start_Date2 = date.newinstance(today.year(), today.addMonths(-2).month(), 1);
        Contract.ASI_CRM_CN_PO_Start_Date__c = PO_Start_Date2;
        ASI_TH_CRM_Contract__c cloneCon = ASI_CRM_CN_HeavyContractUtilitiesClass.ArchivePO2nd(contract);
        contract.Name = 'TestContract002';
        contract.ASI_CRM_CN_Last_PO_version__c = cloneCon.Id;
        contract.ASI_CRM_CN_V0_0_PO_version__c = cloneCon.Id;
        contract.ASI_CRM_CN_PO_Version__c = '0.1';
        Contract.ASI_CRM_Copied_From__c=cloneCon.Id;

        Contract.ASI_CRM_CN_Status__c = 'Draft';
        Contract.ASI_TH_CRM_Start_Date__c = null;
        Contract.ASI_TH_CRM_End_Date__c = null;
        Contract.ASI_CRM_Reject_Return_Comments__c = '';
        Contract.ASI_CRM_CN_Return_Comments__c = '';
        Contract.ASI_CRM_CN_Last_Approved_By__c = NULL;
        Contract.ASI_CRM_CN_Last_Approved_Date__c = NULL;
        Contract.ASI_CRM_CN_Last_Recall_By__c = NULL;
        Contract.ASI_CRM_CN_Last_Recall_Date__c = NULL;
        Contract.ASI_CRM_CN_Last_Rejected_By__c = NULL;
        Contract.ASI_CRM_CN_Last_Rejected_Date__c = NULL;
        Contract.ASI_CRM_CN_Last_Submitted_By__c = NULL;
        Contract.ASI_CRM_CN_Last_Submitted_Date__c = NULL;
        Contract.ASI_CRM_CN_Contract_Upload__c=true;
        Contract.ASI_CRM_Auto_PO_Modification_Time__c=null;
        Contract.ASI_CRM_Auto_PO_Modification__c=false;

        Contract.ASI_CRM_CN_PO_Modification__c = true;
        Contract.ASI_CRM_CN_CTD_Monthly_Default_Date__c = Date.today();
        update Contract;

        ASI_TH_CRM_PaymentRequest__c paymentRequest = new ASI_TH_CRM_PaymentRequest__c();
        paymentRequest.ASI_CRM_CN_Payment_Raised_Date__c = System.today().addDays(-1);
        paymentRequest.ASI_TH_CRM_Contract__c = contract.Id;
        paymentRequest.ASI_CRM_Heap_Size_Large__c = true;
        paymentRequest.ASI_CRM_CN_Last_Payment__c = true;
        paymentRequest.ASI_CRM_CN_PO_Version__c = '0.1';
        paymentRequest.ASI_CRM_CN_Payment_Type__c = 'Cash';
        paymentRequest.ASI_CRM_CN_Overpayment_Reason__c = '消费者酒瓶外带';
        paymentRequest.ASI_CRM_CN_Other_Reason__c = 'Testing';
        paymentRequest.ASI_CRM_CN_Description__c = 'Testing'; 
        paymentRequest.ASI_CRM_CN_BRSF_End_Date__c = System.today().addDays(10);
        paymentRequest.ASI_CRM_CN_BRSF_Start_Date__c = System.today().addDays(-10);
        paymentRequest.ASI_CRM_CN_Bottle_Collection_Rate__c = 40;        
        paymentRequest.Name = 'Testing Payment Request';
        paymentRequest.ASI_CRM_New_FY_Payment__c = true;
        paymentRequest.ASI_CRM_CN_OutletWS__c = contract.ASI_CRM_CN_Outlet_WS__c;
        paymentRequest.recordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequest__cASI_CRM_CN_Payment_Request');
        insert paymentRequest;
        List<ASI_CRM_Module__c> paymentModules = new List<ASI_CRM_Module__c>();
        paymentModules.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c = contract.Id,ASI_CRM_Payment_Request__c=paymentRequest.Id,ASI_CRM_Parent_Module__c=ModuleList[0].Id, ASI_CRM_Unit__c='Std. Btl.',ASI_CRM_Volume_Base__c='By Sub-Brand',ASI_CRM_Line_Type__c='BRSF',ASI_CRM_Methodology__c=MethodologyList[0].Id));
        paymentModules.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c = contract.Id,ASI_CRM_Parent_Module__c=ModuleList[1].Id,ASI_CRM_Payment_Request__c=paymentRequest.Id,ASI_CRM_Unit__c='Std. Btl.',ASI_CRM_Volume_Base__c='By Sub-Brand',ASI_CRM_Line_Type__c='PSF',ASI_CRM_Methodology__c=MethodologyList[1].Id));
        paymentModules.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c = contract.Id,ASI_CRM_Parent_Module__c=ModuleList[5].Id,ASI_CRM_Payment_Request__c=paymentRequest.Id,ASI_CRM_Unit__c='CR12 Extra Eqv.',ASI_CRM_Volume_Base__c='By Sub-Brand',ASI_CRM_Line_Type__c='Variable Event Cost',ASI_CRM_Methodology__c=MethodologyList[2].Id));
        paymentModules.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c = contract.Id,ASI_CRM_Parent_Module__c=ModuleList[6].Id,ASI_CRM_Payment_Request__c=paymentRequest.Id,ASI_CRM_Unit__c='Std. Btl.',ASI_CRM_Volume_Base__c='By Sub-Brand',ASI_CRM_Line_Type__c='Fixed',ASI_CRM_CN_AC_Code__c = ACCodeList[4].Id, ASI_CRM_CN_AC_Code__r = ACCodeList[4]));
        insert paymentModules;

        List<ASI_TH_CRM_PaymentRequestLineItem__c> paymentLineItems = new List<ASI_TH_CRM_PaymentRequestLineItem__c>();
        for (ASI_MFM_Sub_brand__c subBrand :subBrands) {
            paymentLineItems.add(new ASI_TH_CRM_PaymentRequestLineItem__c(ASI_TH_CRM_Payment_Request__c = paymentRequest.Id,RecordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequestLineItem__cASI_CRM_CN_Payment_Request_Detail_BRSF'),ASI_CRM_CN_Incentive_BT__c = 1,ASI_CRM_CN_Target_BT__c=1,ASI_CRM_CN_Actual_Vol__c = 1,ASI_CRM_CN_Total_Payable__c = 1,ASI_CRM_CN_Bottle_Collected__c = 1,ASI_TH_CRM_Amount__c = 100,ASI_CRM_CN_Cost_Type__c = 'BRSF',ASI_CRM_Module__c = paymentModules[0].Id,ASI_CRM_CN_Sub_Brand__c =subBrand.Id ));
            paymentLineItems.add(new ASI_TH_CRM_PaymentRequestLineItem__c(ASI_TH_CRM_Payment_Request__c = paymentRequest.Id,RecordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequestLineItem__cASI_CRM_CN_Payment_Request_Detail_BRSF'),ASI_CRM_CN_Incentive_BT__c = 1,ASI_CRM_CN_Target_BT__c=1,ASI_CRM_CN_Actual_Vol__c = 1,ASI_CRM_CN_Total_Payable__c = 1,ASI_CRM_CN_Bottle_Collected__c = 1,ASI_TH_CRM_Amount__c = 100,ASI_CRM_CN_Cost_Type__c = 'PSF',ASI_CRM_Module__c = paymentModules[1].Id,ASI_CRM_CN_Sub_Brand__c =subBrand.Id));
            paymentLineItems.add(new ASI_TH_CRM_PaymentRequestLineItem__c(ASI_TH_CRM_Payment_Request__c = paymentRequest.Id,RecordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequestLineItem__cASI_CRM_CN_Payment_Request_Detail_BRSF'),ASI_CRM_CN_Incentive_BT__c = 1,ASI_CRM_CN_Target_BT__c=1,ASI_CRM_CN_Actual_Vol__c = 1,ASI_CRM_CN_Total_Payable__c = 1,ASI_CRM_CN_Bottle_Collected__c = 1,ASI_TH_CRM_Amount__c = 100,ASI_CRM_CN_Cost_Type__c = 'Variable Event Cost',ASI_CRM_Module__c = paymentModules[2].Id,ASI_CRM_CN_Sub_Brand__c =subBrand.Id));
            paymentLineItems.add(new ASI_TH_CRM_PaymentRequestLineItem__c(ASI_TH_CRM_Payment_Request__c = paymentRequest.Id,RecordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequestLineItem__cASI_CRM_CN_Payment_Request_Detail_BRSF'),ASI_CRM_CN_Incentive_BT__c = 1,ASI_CRM_CN_Target_BT__c=1,ASI_CRM_CN_Actual_Vol__c = 1,ASI_CRM_CN_Total_Payable__c = 1,ASI_CRM_CN_Bottle_Collected__c = 1,ASI_TH_CRM_Amount__c = 100,ASI_CRM_CN_Cost_Type__c = 'Fixed',ASI_CRM_Module__c = paymentModules[3].Id,ASI_CRM_CN_Sub_Brand__c =subBrand.Id));
        }

        insert paymentLineItems;
        test.startTest();

        ASI_MFM_Sub_brand__c subbrand989 = new ASI_MFM_Sub_brand__c ( Name='Test New',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand'),
                                                    ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,ASI_MFM_Sub_brand_Code__c = 'Test989' ,ASI_MFM_Active_for_CRM__c = true ,
                                                    ASI_CRM_CN_Sub_brand_Grade__c=grades[0].Id,ASI_MFM_Brand__c=BrandList[0].Id);
        insert subbrand989;

        List<ASI_CRM_Subbrand_Volume__c> volumeList = new List<ASI_CRM_Subbrand_Volume__c>();
        ASI_CRM_Subbrand_Volume__c volume1 = new ASI_CRM_Subbrand_Volume__c();
        volume1.ASI_CRM_End_Date__c = Contract.ASI_CRM_CN_PO_Start_Date__c.addDays(1);
        // volume1.ASI_CRM_End_Date__c = TillEnd;
        // volume1.ASI_CRM_CN_Competitor_Sub_brand__c = false;
        volume1.ASI_CRM_Account__c = Contract.ASI_CRM_CN_Outlet_WS__c;
        volume1.ASI_CRM_CN_Exclude_From_Payment_Volume__c = false;
        volume1.ASI_CRM_Subbrand__c = subBrands[0].Id;
        volume1.ASI_CRM_T1_Depletion_STD__c = 120;
        volume1.ASI_CRM_T2_Depletion_STD__c = 180;
        volume1.ASI_CRM_PR_Direct_STD__c = 300;
        volumeList.add(volume1);

        
        ASI_CRM_Subbrand_Volume__c volume2 = new ASI_CRM_Subbrand_Volume__c();
        volume2.ASI_CRM_End_Date__c = Contract.ASI_CRM_CN_PO_Start_Date__c.addDays(1);
        // volume2.ASI_CRM_End_Date__c = TillEnd;
        // volume2.ASI_CRM_CN_Competitor_Sub_brand__c = false;
        volume2.ASI_CRM_Account__c = Contract.ASI_CRM_CN_Outlet_WS__c;
        volume2.ASI_CRM_CN_Exclude_From_Payment_Volume__c = false;
        volume2.ASI_CRM_Subbrand__c = subbrand989.Id;
        volume2.ASI_CRM_T1_Depletion_STD__c = 120;
        volume2.ASI_CRM_T2_Depletion_STD__c = 180;
        volume2.ASI_CRM_PR_Direct_STD__c = 300;
        volumeList.add(volume2);
        insert volumeList;
        
        
        
        Integer coun = 1;
        for(ASI_CRM_CN_Contract_BRSF_Line_Item__c ContractLine:ContractLineList){
            system.debug(coun+'ContractLineList: '+ContractLine);
            coun++;
        }  

        
        ASI_CRM_CN_EditHeavyContractDetailCtrl con2 = new ASI_CRM_CN_EditHeavyContractDetailCtrl(new ApexPages.Standardcontroller(Contract));

        con2.ContractSelected.ASI_CRM_CN_Last_PO_version__c = cloneCon.Id;
        con2.ContractSelected.ASI_CRM_CN_Last_PO_version__r = cloneCon;
        con2.ContractSelected.ASI_CRM_CN_V0_0_PO_version__c = cloneCon.Id;
        con2.ContractSelected.ASI_CRM_CN_V0_0_PO_version__r = cloneCon;
        con2.ContractSelected.ASI_CRM_CN_PO_Version__c = '0.1';
        ApexPages.currentPage().getParameters().put('PARAM_Line_ID', '夜店活动费用(固定)');
        con2.LFixCost2nd.get('夜店活动费用(固定)').Module.ASI_CRM_Volume_Base__c = 'By Sub-Brand';
        con2.RefreshFCModule();
        con2.BySubBrandRefresh2nd('Variable Event Cost','');
        con2.BySubBrandRefresh2nd('PSF','');
        

        con2.updateLineData();

        con2.v00UpdateLineData();

        con2.updateModuleQty();

        con2.ResetVECDetails();
        con2.VariableEventCost.Module.ASI_CRM_Volume_Base__c = 'By Grade';
        con2.RefreshVECModule();
        con2.updateModuleQty();

        con2.ResetVECDetails();
        con2.VariableEventCost.Module.ASI_CRM_Volume_Base__c = 'By Category';
        con2.RefreshVECModule();
        con2.updateModuleQty();

        con2.ResetVECDetails();
        con2.VariableEventCost.Module.ASI_CRM_Volume_Base__c = 'By Total';
        con2.RefreshVECModule();
        con2.updateModuleQty();

        // ApexPages.currentPage().getParameters().put('PARAM_Line_ID', '夜店活动费用(固定)');
        con2.ResetFCDetails();
        con2.LFixCost2nd.get('夜店活动费用(固定)').Module.ASI_CRM_Volume_Base__c = 'By Grade';
        con2.RefreshFCModule();
        con2.updateModuleQty();

        con2.ResetFCDetails();
        con2.LFixCost2nd.get('夜店活动费用(固定)').Module.ASI_CRM_Volume_Base__c = 'By Category';
        con2.RefreshFCModule();
        con2.updateModuleQty();

        con2.ResetFCDetails();
        con2.LFixCost2nd.get('夜店活动费用(固定)').Module.ASI_CRM_Volume_Base__c = 'By Total';
        con2.RefreshFCModule();
        con2.updateModuleQty();

        ApexPages.currentPage().getParameters().put('PARAM_Line_ID',ModuleList[3].Id);
        con2.ResetPSFDetails();
        con2.PSF_Item_Map.get(ModuleList[3].Id).Module.ASI_CRM_Volume_Base__c = 'By Category';
        con2.RefreshPSFModule();
        con2.updateModuleQty();
    }

    static testMethod void EditHeavyContractDetailCtrlTest6() {
        //Test Class for ASI_CRM_CN_EditHeavyContractDetailCtrl
        
        ASI_CRM_Region__c region = new ASI_CRM_Region__c (Name='Central Region',recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Region__cASI_CRM_CN_Region'));
        insert region;
        
        ASI_CRM_Division__c division = new ASI_CRM_Division__c(Name='TEST', ASI_CRM_Region__c=region.Id);
        insert division;
        
        ASI_CRM_CN_Area__c area = new ASI_CRM_CN_Area__c(Name='TEST', ASI_CRM_English_Name__c='TEST', ASI_CRM_Division__c=division.Id);
        insert area;
        
        ASI_CRM_City__c city = new ASI_CRM_City__c(Name='TEST', ASI_CRM_CN_Area__c=area.Id,ASI_CRM_CN_City_Tier__c='2');
        insert city;
        
        /*ASI_CRM_CN_Channel__c channel = new ASI_CRM_CN_Channel__c(Name='KTV',ASI_CRM_BC_Rate__c=98,ASI_CRM_CN_On_Off__c='ON',ASI_CRM_For_Outlet__c=true,RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CN_Channel__cASI_CRM_CN_New_Channel'),ASI_CRM_For_Contract__c=TRUE);
        insert channel;*/
        
        ASI_CRM_CN_Channel__c channel = new ASI_CRM_CN_Channel__c(ASI_CRM_CN_On_Off__c='ON');
        insert channel;
        /*
        ASI_CRM_SegmentationCriteria__c SegmentationCriteria= new ASI_CRM_SegmentationCriteria__c (Name='Test',ASI_CRM_Channel__c=channel.Id, ASI_CRM_Outlet_New_Image__c='Iconic',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_SegmentationCriteria__cASI_CRM_CN_Segmentation_Criteria'));
        INSERT SegmentationCriteria;
        
        Id rtWS = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_CN_WS');
        Id rtOutlet = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN');
        */
        ASI_MFM_Sub_Channel__c subChannel = new ASI_MFM_Sub_Channel__c(ASI_CRM_CN_Channel__c=channel.Id);
        insert subChannel;
        
        ASI_CRM_CN_Channel__c newChannel = new ASI_CRM_CN_Channel__c(ASI_CRM_For_Outlet__c = true, Name='Restaurant',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CN_Channel__cASI_CRM_CN_New_Channel'),ASI_CRM_CN_On_Off__c='OFF');
        insert newChannel;
        
        list<ASI_CRM_AccountsAdditionalField__c> Customers = new list<ASI_CRM_AccountsAdditionalField__c>();
        Customers.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Eng_Name__c = 'b', ASI_CRM_CN_Chi_Name__c = 'b', ASI_CRM_CN_Commercial_Team__c = 'Premium', ASI_CRM_CN_Sub_Channel__c=subChannel.Id, ASI_CRM_CN_CCity__c=city.Id, ASI_CRM_Latest_Call_Plan_Date__c=system.today(), RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN'), ASI_CRM_CN_NewChannel__c = newChannel.Id, ASI_CRM_CN_Type_of_Restaurant__c = 'International',ASI_CRM_CN_Spending_per_head__c=1));
        Customers.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Eng_Name__c = 'c', ASI_CRM_CN_Chi_Name__c = 'c', ASI_CRM_CN_Commercial_Team__c = 'Premium', ASI_CRM_CN_Sub_Channel__c=subChannel.Id, ASI_CRM_CN_CCity__c=city.Id, ASI_CRM_Latest_Call_Plan_Date__c=system.today(), RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN'), ASI_CRM_CN_NewChannel__c = newChannel.Id, ASI_CRM_CN_Type_of_Restaurant__c = 'International',ASI_CRM_CN_Spending_per_head__c=1));
        insert Customers;
        /*
        
        list<ASI_CRM_AccountsAdditionalField__c> ChildCustomers = new list<ASI_CRM_AccountsAdditionalField__c>();
        ChildCustomers.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Parent_Outlet__c=Customers[1].Id,ASI_CRM_CN_Eng_Name__c = 'a', ASI_CRM_CN_Chi_Name__c = 'a', ASI_CRM_CN_Commercial_Team__c = 'Premium', ASI_CRM_CN_Sub_Channel__c=subChannel.Id, ASI_CRM_CN_CCity__c=city.Id, ASI_CRM_Latest_Call_Plan_Date__c=system.today(), RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN'), ASI_CRM_CN_NewChannel__c = newChannel.Id, ASI_CRM_CN_Type_of_Restaurant__c = 'International',ASI_CRM_CN_Spending_per_head__c=1));
        insert ChildCustomers;
        
        */
        
        User currentUser = [SELECT id, name, Managerid, ASI_CRM_CN_Prefix__c,LanguageLocaleKey FROM USER WHERE id =:UserInfo.getUserId()];
        currentUser.LanguageLocaleKey='en_US';
        update currentUser;
        
        list<ASI_HK_CRM_Running_Number__c> rns = new list<ASI_HK_CRM_Running_Number__c>();
        rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_TH_CRM_Contract__c', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_TH_CRM_PaymentRequest__c', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        if(!String.isBlank(currentUser.ASI_CRM_CN_Prefix__c))
            rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_'+currentUser.ASI_CRM_CN_Prefix__c, recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        else{
            rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_NULL', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
            rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        }
        insert rns;
        
        
        
        
        
        List<ASI_HK_CRM_Product_Category__c> ProductCategoryList= new List<ASI_HK_CRM_Product_Category__c> ();
        ProductCategoryList.add(new ASI_HK_CRM_Product_Category__c(Name='Category1',ASI_CRM_CN_Chinese_Name__c='Category',ASI_HK_CRM_English_Name__c='Category',ASI_HK_CRM_Sequence__c=1,recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Product_Category__cASI_CRM_CN_Product_Category')));
        ProductCategoryList.add(new ASI_HK_CRM_Product_Category__c(Name='Category2',ASI_CRM_CN_Chinese_Name__c='Category2',ASI_HK_CRM_English_Name__c='Category',ASI_HK_CRM_Sequence__c=2,recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Product_Category__cASI_CRM_CN_Product_Category')));
        ProductCategoryList.add(new ASI_HK_CRM_Product_Category__c(Name='Category3',ASI_CRM_CN_Chinese_Name__c='Category1',ASI_HK_CRM_English_Name__c='Category',ASI_HK_CRM_Sequence__c=3,recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Product_Category__cASI_CRM_CN_Product_Category')));
        
        insert ProductCategoryList;
        
        
        
        
        List<ASI_TH_CRM_Sub_category__c> SubCategoryList= new List<ASI_TH_CRM_Sub_category__c>();
        SubCategoryList.add(new ASI_TH_CRM_Sub_category__c(Name='SubCategory1',ASI_CRM_CN_Product_Category__c=ProductCategoryList[0].Id,recordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_Sub_category__cASI_CRM_CN_Sub_Category')));
        SubCategoryList.add(new ASI_TH_CRM_Sub_category__c(Name='SubCategory2',ASI_CRM_CN_Product_Category__c=ProductCategoryList[1].Id,recordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_Sub_category__cASI_CRM_CN_Sub_Category')));
        SubCategoryList.add(new ASI_TH_CRM_Sub_category__c(Name='SubCategory3',ASI_CRM_CN_Product_Category__c=ProductCategoryList[2].Id,recordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_Sub_category__cASI_CRM_CN_Sub_Category')));
        
        insert SubCategoryList;
        
        
        List<ASI_MFM_Brand__c> BrandList = new List<ASI_MFM_Brand__c> ();
        BrandList.add(new ASI_MFM_Brand__c (Name='Test1',ASI_CRM_CN_Competitor__c=false,ASI_TH_CRM_Sub_category__c=SubCategoryList[0].Id,recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Brand__cASI_FOC_CN_Brand')));
        BrandList.add(new ASI_MFM_Brand__c (Name='Test2',ASI_CRM_CN_Competitor__c=false,ASI_TH_CRM_Sub_category__c=SubCategoryList[1].Id,recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Brand__cASI_FOC_CN_Brand')));
        BrandList.add(new ASI_MFM_Brand__c (Name='Test3',ASI_CRM_CN_Competitor__c=false,ASI_TH_CRM_Sub_category__c=SubCategoryList[2].Id,recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Brand__cASI_FOC_CN_Brand')));
        
        Insert BrandList;
        
        
        
        
        //Sub Brand Grade
        list<ASI_CRM_Sub_Brand_Grade__c> grades = new list<ASI_CRM_Sub_Brand_Grade__c>();
        grades.add(new ASI_CRM_Sub_Brand_Grade__c (Name='Premium',ASI_CRM_Chinese_Name__c='Test1',ASI_CRM_Chinese_Description__c='1. Standard + Premium 标准档 + 高档',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_Sub_Brand_Grade__cASI_CRM_CN_Sub_brand_Grade')));
        grades.add(new ASI_CRM_Sub_Brand_Grade__c (Name='TEST2',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_Sub_Brand_Grade__cASI_CRM_CN_Sub_brand_Grade')));
        grades.add(new ASI_CRM_Sub_Brand_Grade__c (Name='TEST3',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_Sub_Brand_Grade__cASI_CRM_CN_Sub_brand_Grade')));
        insert grades;
        
        list<ASI_MFM_Sub_brand__c> subBrands = new list<ASI_MFM_Sub_brand__c>();
        for(ASI_CRM_Sub_Brand_Grade__c grade :grades) {
            subBrands.add(new ASI_MFM_Sub_brand__c (Name='TEST1',ASI_MFM_Active_for_CRM__c=true,ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,RecordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand'),
                                                    ASI_CRM_CN_Sub_brand_Grade__c=grade.Id,ASI_MFM_Brand__c=BrandList[0].Id));
            subBrands.add(new ASI_MFM_Sub_brand__c (Name='TEST2',ASI_MFM_Active_for_CRM__c=true,RecordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand'),
                                                    ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,
                                                    ASI_CRM_CN_Sub_brand_Grade__c=grade.Id,ASI_MFM_Brand__c=BrandList[1].Id));
            subBrands.add(new ASI_MFM_Sub_brand__c ( Name='TEST3',ASI_MFM_Active_for_CRM__c=true,RecordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand'),
                                                    ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,
                                                    ASI_CRM_CN_Sub_brand_Grade__c=grade.Id,ASI_MFM_Brand__c=BrandList[2].Id));
            subBrands.add(new ASI_MFM_Sub_brand__c ( Name='999',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand'),
                                                    ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,ASI_MFM_Sub_brand_Code__c = '999' ,ASI_MFM_Active_for_CRM__c = true ,
                                                    ASI_CRM_CN_Sub_brand_Grade__c=grade.Id,ASI_MFM_Brand__c=BrandList[0].Id));
        }
        
        insert subBrands;
        
        /*
        List<ASI_CRM_Sub_Brand_Assignment__c> SubBrandAssignmentList= new List<ASI_CRM_Sub_Brand_Assignment__c>();
        for(ASI_MFM_Sub_brand__c SubBrandItem:subBrands){
            SubBrandAssignmentList.add(new ASI_CRM_Sub_Brand_Assignment__c(ASI_CRM_Sub_Brand__c=SubBrandItem.Id,ASI_CRM_Segmentation_Criteria__c=SegmentationCriteria.Id));
        }
        
        insert SubBrandAssignmentList;
        */
        
        List<ASI_MFM_A_C_Code__c> ACCodeList = new  List<ASI_MFM_A_C_Code__c>();
        ACCodeList.add(new ASI_MFM_A_C_Code__c( Name='0000000000000', ASI_MFM_A_C_Code__c='000010000',ASI_MFM_A_C_Description__c='ASI_CRM_CN_Variable_Cost_Contract',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_CN_A_C_Code') ));
        ACCodeList.add(new ASI_MFM_A_C_Code__c( Name='5275.010000 PRC - Bottle Return Service', ASI_MFM_A_C_Code__c='5275.010000',ASI_MFM_A_C_Description__c='Bottle Return Service',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_CN_A_C_Code') ));
        ACCodeList.add(new ASI_MFM_A_C_Code__c( Name='5275.020000 Promotion Service Fee', ASI_MFM_A_C_Code__c='5275.020000',ASI_MFM_A_C_Description__c='Promotion Service Fee',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_CN_A_C_Code') ));
        ACCodeList.add(new ASI_MFM_A_C_Code__c( Name='5275.030000 PRC - Variable Event Cost', ASI_MFM_A_C_Code__c='5275.030000',ASI_MFM_A_C_Description__c='Variable Event Cost',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_CN_A_C_Code') ));
        ACCodeList.add(new ASI_MFM_A_C_Code__c( Name='5275.040000 PRC - Fixed Event Cost',ASI_MFM_A_C_CN_Description__c='夜店活动费用(固定)', ASI_MFM_A_C_Code__c='5275.040000',ASI_MFM_A_C_Description__c='PRC - Fixed Event Cost',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_CN_A_C_Code') ));
        
        insert ACCodeList;
        
        
        List<ASI_CRM_Contract_Cost_Setting__c> ContractCostSettingList= new List<ASI_CRM_Contract_Cost_Setting__c>();
        
        ContractCostSettingList.add(new ASI_CRM_Contract_Cost_Setting__c(ASI_CRM_CN_Activity_Code__c=ACCodeList[0].Id,ASI_CRM_CN_Promotion_Type__c='Heavy Contract ON',
                                                                         ASI_CRM_CN_Fixed_Cost_Contract__c=true,ASI_CRM_CN_Variable_Cost_Contract__c=true));
        
        ContractCostSettingList.add(new ASI_CRM_Contract_Cost_Setting__c(ASI_CRM_CN_Activity_Code__c=ACCodeList[0].Id,ASI_CRM_CN_Promotion_Type__c='Heavy Contract ON',ASI_CRM_CN_Variable_Cost_Contract__c=true,
                                                                         ASI_CRM_CN_Fixed_Cost_Contract__c=false,ASI_CRM_CN_BRSF_Activity_Code_Default__c=true));
        
        ContractCostSettingList.add(new ASI_CRM_Contract_Cost_Setting__c(ASI_CRM_CN_Activity_Code__c=ACCodeList[0].Id,ASI_CRM_CN_Promotion_Type__c='Heavy Contract ON',ASI_CRM_CN_Variable_Cost_Contract__c=true,
                                                                         ASI_CRM_CN_Fixed_Cost_Contract__c=false,ASI_CRM_PSF_Activity_Code_Default__c=true));
        
        ContractCostSettingList.add(new ASI_CRM_Contract_Cost_Setting__c(ASI_CRM_CN_Activity_Code__c=ACCodeList[0].Id,ASI_CRM_CN_Promotion_Type__c='Heavy Contract ON',ASI_CRM_CN_Variable_Cost_Contract__c=true,
                                                                         ASI_CRM_CN_Fixed_Cost_Contract__c=false,ASI_CRM_VEC_Activity_Code_Defaul__c=true));
        ContractCostSettingList.add(new ASI_CRM_Contract_Cost_Setting__c(ASI_CRM_CN_Activity_Code__c=ACCodeList[4].Id,ASI_CRM_CN_Promotion_Type__c='Heavy Contract ON',
                                                                         ASI_CRM_CN_Fixed_Cost_Contract__c=true,ASI_CRM_CN_Variable_Cost_Contract__c=false));
        
        insert ContractCostSettingList;
        
        ASI_CRM_SpecialPromotionTypeSetting__c oldspts = new ASI_CRM_SpecialPromotionTypeSetting__c( ASI_CRM_Promotion_Type__c = 'a');
        insert oldspts;
        
        ASI_CRM_SpecialPromotionTypeSetting__c newspts = new ASI_CRM_SpecialPromotionTypeSetting__c(ASI_CRM_Promotion_Type__c = 'Heavy Contract On',recordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_SpecialPromotionTypeSetting__cASI_CRM_CN_SpecialPromotionTypeSetting'));
        insert newspts;
        
        ASI_CRM_Special_Promotion_Type_Mapping__c sptm = new ASI_CRM_Special_Promotion_Type_Mapping__c(ASI_CRM_Mapping_of_New_Promotion_Type__c = newspts.Id,ASI_CRM_Mapping_of_Old_Promotion_Type__c = oldspts.Id,recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Special_Promotion_Type_Mapping__cASI_CRM_CN_Special_Promotion_Type_Mapping'));
        insert sptm;
        
        
        
        Date today = Date.newInstance(2020, 5, 25);
        Date PO_Start_Date = date.newinstance(today.year(), today.month(), 1);
        Date PO_End_Date = PO_Start_Date.addMonths(1)-1;
        
        
        ASI_TH_CRM_Contract__c GroupContract = new ASI_TH_CRM_Contract__c(recordtypeid = Global_RecordTypeCache.getRTID('ASI_TH_CRM_Contract__cASI_CRM_CN_Group_Contract'),ASI_CRM_CN_Is_2nd_KPI_PO__c=true,
                                                                          ASI_CRM_CN_PO_Start_Date__c = PO_Start_Date,
                                                                          ASI_CRM_CN_PO_End_Date__c =PO_End_Date,
                                                                          Name = 'Noah C4',
                                                                          ASI_CRM_CN_Outlet_WS__c=Customers[1].Id);
        insert GroupContract;
        
        ASI_TH_CRM_Contract__c Contract = new ASI_TH_CRM_Contract__c(recordtypeid = Global_RecordTypeCache.getRTID('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract'),ASI_CRM_CN_Is_2nd_KPI_PO__c=true,
                                                                     ASI_CRM_CN_Status__c = 'Final',ASI_CRM_CN_Group_Contract__c=GroupContract.Id,
                                                                     ASI_CRM_CN_PO_Start_Date__c = PO_Start_Date,
                                                                     ASI_CRM_CN_PO_End_Date__c =PO_End_Date,
                                                                     ASI_CRM_CN_PO_Version__c = '0.0',ASI_TH_CRM_Promotion_Type__c='Heavy Contract On',
                                                                     Name = 'Contract1',
                                                                     ASI_CRM_CN_Outlet_WS__c=Customers[1].Id,ASI_CRM_Volume_Option__c = 'Normal');
        insert Contract;
        
        
        List<ASI_CRM_Methodology__c> MethodologyList= new List<ASI_CRM_Methodology__c> ();
        MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test1',ASI_CRM_Methodology_Code__c='01',ASI_CRM_Default__c=true,ASI_CRM_Chinese_Name__c='123',ASI_CRM_Type__c='BRSF',recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Methodology__cASI_CRM_CN_Methodology')));
        MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test2',ASI_CRM_Methodology_Code__c='01',ASI_CRM_Default__c=true,ASI_CRM_Chinese_Name__c='Test 123',ASI_CRM_Type__c='PSF',recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Methodology__cASI_CRM_CN_Methodology')));
        MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test3',ASI_CRM_Methodology_Code__c='01',ASI_CRM_Default__c=true,ASI_CRM_Chinese_Name__c='Test 123',ASI_CRM_Type__c='Variable Event Cost',recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Methodology__cASI_CRM_CN_Methodology')));
        
        
        MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test1',ASI_CRM_Methodology_Code__c='01',ASI_CRM_Chinese_Name__c='123',ASI_CRM_Type__c='BRSF',recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Methodology__cASI_CRM_CN_Methodology')));
        MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test2',ASI_CRM_Methodology_Code__c='01',ASI_CRM_Chinese_Name__c='123',ASI_CRM_Type__c='PSF',recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Methodology__cASI_CRM_CN_Methodology')));
        MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test3',ASI_CRM_Methodology_Code__c='01',ASI_CRM_Chinese_Name__c='123',ASI_CRM_Type__c='Variable Event Cost',recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Methodology__cASI_CRM_CN_Methodology')));
        insert MethodologyList;
        
        
        //Methodology Assignment
        List<ASI_CRM_Methodology_Assignment__c> MethodologyAssignmentList = new List<ASI_CRM_Methodology_Assignment__c>();
        MethodologyAssignmentList.add(new ASI_CRM_Methodology_Assignment__c(ASI_CRM_Methodology__c=MethodologyList[0].Id,ASI_CRM_Key_Principle__c=true,ASI_CRM_Methodology_Commercial_Team__c='Premium',ASI_CRM_Region__c=region.Id));
        MethodologyAssignmentList.add(new ASI_CRM_Methodology_Assignment__c(ASI_CRM_Methodology__c=MethodologyList[1].Id,ASI_CRM_Key_Principle__c=true,ASI_CRM_Methodology_Commercial_Team__c='Premium',ASI_CRM_Region__c=region.Id));
        MethodologyAssignmentList.add(new ASI_CRM_Methodology_Assignment__c(ASI_CRM_Methodology__c=MethodologyList[2].Id,ASI_CRM_Key_Principle__c=true,ASI_CRM_Methodology_Commercial_Team__c='Premium',ASI_CRM_Region__c=region.Id));
        MethodologyAssignmentList.add(new ASI_CRM_Methodology_Assignment__c(ASI_CRM_Methodology__c=MethodologyList[3].Id,ASI_CRM_Key_Principle__c=true,ASI_CRM_Methodology_Commercial_Team__c='Premium',ASI_CRM_Region__c=region.Id));
        MethodologyAssignmentList.add(new ASI_CRM_Methodology_Assignment__c(ASI_CRM_Methodology__c=MethodologyList[4].Id,ASI_CRM_Key_Principle__c=true,ASI_CRM_Methodology_Commercial_Team__c='Premium',ASI_CRM_Region__c=region.Id));
        MethodologyAssignmentList.add(new ASI_CRM_Methodology_Assignment__c(ASI_CRM_Methodology__c=MethodologyList[5].Id,ASI_CRM_Key_Principle__c=true,ASI_CRM_Methodology_Commercial_Team__c='Premium',ASI_CRM_Region__c=region.Id));
        
        insert MethodologyAssignmentList ;
        
        
        
        
        List<ASI_CRM_Module__c> ModuleList = new List<ASI_CRM_Module__c>();
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='Std. Btl.',ASI_CRM_Volume_Base__c='By Sub-Brand',ASI_CRM_Line_Type__c='BRSF',ASI_CRM_Methodology__c=MethodologyList[0].Id));
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='Std. Btl.',ASI_CRM_Volume_Base__c='By Sub-Brand',ASI_CRM_Line_Type__c='PSF',ASI_CRM_Methodology__c=MethodologyList[1].Id));
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='CR12 Extra Eqv.',ASI_CRM_Volume_Base__c='By Grade',ASI_CRM_Line_Type__c='PSF',ASI_CRM_Methodology__c=MethodologyList[1].Id));
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='CR12 Extra Eqv.',ASI_CRM_Volume_Base__c='By Category',ASI_CRM_Line_Type__c='PSF',ASI_CRM_Methodology__c=MethodologyList[1].Id));
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='CR12 Extra Eqv.',ASI_CRM_Volume_Base__c='By Total',ASI_CRM_Line_Type__c='PSF',ASI_CRM_Methodology__c=MethodologyList[1].Id));
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='CR12 Extra Eqv.',ASI_CRM_Volume_Base__c='By Sub-Brand',ASI_CRM_Line_Type__c='Variable Event Cost',ASI_CRM_Methodology__c=MethodologyList[2].Id));

        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='Std. Btl.',ASI_CRM_Volume_Base__c='By Sub-Brand',ASI_CRM_Line_Type__c='Fixed',ASI_CRM_CN_AC_Code__c = ACCodeList[4].Id, ASI_CRM_CN_AC_Code__r = ACCodeList[4]));
        
        insert ModuleList;
        /*
        ASI_CRM_Contract_Cost__c contractCost = new ASI_CRM_Contract_Cost__c(ASI_CRM_CN_Contract__c = Contract.id,
                                                                             ASI_CRM_CN_Estimate_Amount__c = 100000,
                                                                             ASI_CRM_CN_Cost_Type__c = 'Fixed',
                                                                             ASI_CRM_CN_Other_Cost_Payment_Request__c = true,
                                                                             recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_Contract_Cost__cASI_CRM_CN_Contract_Cost') );
        insert contractCost;
        */
        list<ASI_CRM_CN_Contract_BRSF_Line_Item__c> ContractLineList = new list<ASI_CRM_CN_Contract_BRSF_Line_Item__c>();
        list<ASI_CRM_CN_Covered_Outlet__c> cos = new list<ASI_CRM_CN_Covered_Outlet__c>();
        for(ASI_MFM_Sub_brand__c subBrand :subBrands) {
            ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract.Id,
                                                                           ASI_CRM_CN_Est_Monthly_Qty__c=1,ASI_CRM_Module__c=ModuleList[0].Id,
                                                                           ASI_CRM_CN_Contract_Monthly_Qty__c=1,
                                                                           ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,
                                                                           ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,ASI_CRM_Type__c='BRSF',
                                                                           ASI_CRM_CN_Sub_Brand__c=subBrand.Id,
                                                                           recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF')));
        }
        
        for(ASI_MFM_Sub_brand__c subBrand :subBrands) {
            ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract.Id,
                                                                           ASI_CRM_CN_Est_Monthly_Qty__c=1,ASI_CRM_Module__c=ModuleList[1].Id,
                                                                           ASI_CRM_CN_Contract_Monthly_Qty__c=1,ASI_CRM_Volume_Base__c='By Sub-Brand',
                                                                           ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,
                                                                           ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,ASI_CRM_Type__c='PSF',
                                                                           ASI_CRM_CN_Sub_Brand__c=subBrand.Id,
                                                                           recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF')));
        }
        
        ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract.Id,ASI_CRM_Type__c='PSF',ASI_CRM_Volume_Base__c='By Grade',
                                                                       ASI_CRM_CN_Est_Monthly_Qty__c=4,ASI_CRM_Module__c=ModuleList[2].Id,
                                                                       ASI_CRM_CN_Contract_Monthly_Qty__c=4,ASI_CRM_Sub_Brand_Grade__c=grades[0].Id,
                                                                       ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,
                                                                       ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,
                                                                       ASI_CRM_CN_Sub_Brand__c=null,
                                                                       recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF') ));
        ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract.Id,ASI_CRM_Type__c='PSF',ASI_CRM_Volume_Base__c='By Category',
                                                                       ASI_CRM_CN_Est_Monthly_Qty__c=4,ASI_CRM_Module__c=ModuleList[3].Id,
                                                                       ASI_CRM_CN_Contract_Monthly_Qty__c=4,ASI_CRM_Product_Category__c=ProductCategoryList[0].Id,
                                                                       ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,
                                                                       ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,
                                                                       ASI_CRM_CN_Sub_Brand__c=null,
                                                                       recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF') ));
        ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract.Id,ASI_CRM_Type__c='PSF',ASI_CRM_Volume_Base__c='By Total',
                                                                       ASI_CRM_CN_Est_Monthly_Qty__c=4,ASI_CRM_Module__c=ModuleList[4].Id,
                                                                       ASI_CRM_CN_Contract_Monthly_Qty__c=4,
                                                                       ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,
                                                                       ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,
                                                                       ASI_CRM_CN_Sub_Brand__c=null,
                                                                       recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF') ));
        for(ASI_MFM_Sub_brand__c subBrand :subBrands) {
            ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract.Id,
                                                                           ASI_CRM_CN_Est_Monthly_Qty__c=1,ASI_CRM_Module__c=ModuleList[6].Id,
                                                                           ASI_CRM_CN_Contract_Monthly_Qty__c=1,ASI_CRM_Volume_Base__c='By Sub-Brand',
                                                                           ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,ASI_CRM_CN_Activity_Code__r=ACCodeList[4],ASI_CRM_CN_Activity_Code__c=ACCodeList[4].Id,
                                                                           ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,ASI_CRM_Type__c='Fixed',
                                                                           ASI_CRM_CN_Sub_Brand__c=subBrand.Id,
                                                                           recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF')));
        }
        for(ASI_MFM_Sub_brand__c subBrand :subBrands) {
            ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract.Id,
                                                                           ASI_CRM_CN_Est_Monthly_Qty__c=1,ASI_CRM_Module__c=ModuleList[5].Id,
                                                                           ASI_CRM_CN_Contract_Monthly_Qty__c=1,ASI_CRM_Volume_Base__c='By Sub-Brand',
                                                                           ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,
                                                                           ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,ASI_CRM_Type__c='Variable Event Cost',
                                                                           ASI_CRM_CN_Sub_Brand__c=subBrand.Id,
                                                                           recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF')));
        }
        
        insert ContractLineList;
        
        
        test.startTest();
        
        
        Integer coun = 1;
        for(ASI_CRM_CN_Contract_BRSF_Line_Item__c ContractLine:ContractLineList){
            system.debug(coun+'ContractLineList: '+ContractLine);
            coun++;
        }  
        
        
        
        
        ASI_CRM_CN_EditHeavyContractDetailCtrl con2 = new ASI_CRM_CN_EditHeavyContractDetailCtrl(new ApexPages.Standardcontroller(Contract));
        
        
        ApexPages.currentPage().getParameters().put('PARAM_Line_ID', ContractLineList[17].id);
        ApexPages.currentPage().getParameters().put('PARAM_item_ID', ModuleList[1].id);
        ApexPages.currentPage().getParameters().put('PARAM_Unit_ID','Std. Btl.');
        con2.RemovePSFLine();
        
        
        ApexPages.currentPage().getParameters().put('PARAM_Line_ID', ContractLineList[17].id);
        ApexPages.currentPage().getParameters().put('PARAM_item_ID', ModuleList[1].id);
        con2.PSFChangingSB();

        for (Integer i = 0; i < ContractLineList.size() ; i++) {
            if (ContractLineList.get(i).ASI_CRM_Type__c == 'Fixed') {
                System.debug(LoggingLevel.INFO, '*** i: ' + i);
            }
        }
        System.debug(LoggingLevel.INFO, '*** con2.LFixCost2nd: ' + con2.LFixCost2nd);
        System.debug(LoggingLevel.INFO, '*** ModuleList: ' + ModuleList[6].Id);
        System.debug(LoggingLevel.INFO, '*** ContractLineList: ' + ContractLineList[27].ASI_CRM_Module__c);
        ApexPages.currentPage().getParameters().put('PARAM_Line_ID', ContractLineList[27].id);
        ApexPages.currentPage().getParameters().put('PARAM_item_ID', ContractLineList[27].ASI_CRM_CN_Activity_Code__r.ASI_MFM_A_C_Description__c);
        ApexPages.currentPage().getParameters().put('PARAM_Unit_ID','Std. Btl.');
        con2.RemoveFCLine();



        ApexPages.currentPage().getParameters().put('SelectValue', 'CTD monthly value');
        con2.refreshBrsfItem();

        ApexPages.currentPage().getParameters().put('SelectValue', 'V0.0');
        con2.refreshBrsfItem();
        
        
        
        PageReference EnterPage = Page.ASI_CRM_CN_ViewHeavyContractPage;
        
        Map<String, String> pageParams = EnterPage.getParameters();
        
        pageParams.put('id', Contract.id);
        ApexPages.StandardController sc = new ApexPages.standardController(new ASI_TH_CRM_Contract__c());
        
        ASI_CRM_CN_EditHeavyContractDetailCtrl con = new ASI_CRM_CN_EditHeavyContractDetailCtrl(new ApexPages.Standardcontroller(Contract));
        con.saveItems();
        //con.SizeOfPSFMap = 1;
        
        
        
        ApexPages.currentPage().getParameters().put('PARAM_Line_ID', ContractLineList[0].id);
        con.Clone_BRSF();
        
        
        ApexPages.currentPage().getParameters().put('PARAM_Line_ID', ContractLineList[1].id);
        con.Remove_BRSF();
        con.AddNew_BRSF();
        
        
        
        con.LoopingReCalculatePSF();
        
        con.PSFAddModule();
        ApexPages.currentPage().getParameters().put('PARAM_Line_ID', ModuleList[1].id);
        con.RefreshPSFModule();
        ApexPages.currentPage().getParameters().put('PARAM_Line_ID', ModuleList[2].id);
        con.RefreshPSFModule();
        ApexPages.currentPage().getParameters().put('PARAM_Line_ID', ModuleList[3].id);
        con.RefreshPSFModule();
        ApexPages.currentPage().getParameters().put('PARAM_Line_ID', ModuleList[4].id);
        con.RefreshPSFModule();
        
        ApexPages.currentPage().getParameters().put('PARAM_Line_ID', ModuleList[1].id);
        con.AddNewPSFLine();


        // con.PSFAddModule();
        ApexPages.currentPage().getParameters().put('PARAM_Line_ID', ContractLineList[27].ASI_CRM_CN_Activity_Code__r.ASI_MFM_A_C_Description__c);
        con.ResetFCDetails();
        ApexPages.currentPage().getParameters().put('PARAM_Line_ID', ContractLineList[27].ASI_CRM_CN_Activity_Code__r.ASI_MFM_A_C_Description__c);
        con.RefreshFCModule();
        
        ApexPages.currentPage().getParameters().put('PARAM_Line_ID', ContractLineList[27].ASI_CRM_CN_Activity_Code__r.ASI_MFM_A_C_Description__c);
        con.AddNewFCLine();
        
        
        ApexPages.currentPage().getParameters().put('PARAM_Line_ID', ContractLineList[33].id);
        con.VECChangingSB();
        con.AddNewVECLine();
        ApexPages.currentPage().getParameters().put('PARAM_Line_ID', ContractLineList[34].id);
        con.CloneVECLine();
        ApexPages.currentPage().getParameters().put('PARAM_Line_ID', ContractLineList[35].id);
        con.RemoveVECLine();
        
        
        con.AddNew_CoveredOutlet();
        ASI_CRM_CN_EditHeavyContractDetailCtrl.GenerateCutOffDate(Date.today());
        con.saveItems();
        
        
        ApexPages.currentPage().getParameters().put('PARAMID', ModuleList[1].id);
        con.DeletePSFModule();
        
        con.BRSFClearAll();
        con.ModuleChecking();
        con.RefreshVECModule();
        con.ResetVECDetails();
        con.CopyHistoricalV0Contract();
        con.ResetPSFDetails();
        List<sObject> TempList= ASI_CRM_CN_EditHeavyContractDetailCtrl.FindSubBrandList2nd('ASI_MFM_Sub_brand__c',' WHERE RecordType.DeveloperName = \'ASI_FOC_CN_Sub_brand\' ','Premium','2',Contract.Id,region.Name);
        test.stopTest(); 
    }
    
    static testMethod void EditHeavyContractDetailCtrlTest22() {
        //Test Class for ASI_CRM_CN_EditHeavyContractDetailCtrl
        ASI_CRM_Region__c region = new ASI_CRM_Region__c (Name='TEST',recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Region__cASI_CRM_CN_Region'));
        insert region;
        
        ASI_CRM_Division__c division = new ASI_CRM_Division__c(Name='TEST', ASI_CRM_Region__c=region.Id);
        insert division;
        
        ASI_CRM_CN_Area__c area = new ASI_CRM_CN_Area__c(Name='TEST', ASI_CRM_English_Name__c='TEST', ASI_CRM_Division__c=division.Id);
        insert area;
        
        ASI_CRM_City__c city = new ASI_CRM_City__c(Name='TEST', ASI_CRM_CN_Area__c=area.Id,ASI_CRM_CN_City_Tier__c='2');
        insert city;
        
        /*ASI_CRM_CN_Channel__c channel = new ASI_CRM_CN_Channel__c(Name='KTV',ASI_CRM_BC_Rate__c=98,ASI_CRM_CN_On_Off__c='ON',ASI_CRM_For_Outlet__c=true,RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CN_Channel__cASI_CRM_CN_New_Channel'),ASI_CRM_For_Contract__c=TRUE);
              insert channel;*/
              
              ASI_CRM_CN_Channel__c channel = new ASI_CRM_CN_Channel__c(ASI_CRM_CN_On_Off__c='ON');
              insert channel;
              
              ASI_CRM_SegmentationCriteria__c SegmentationCriteria= new ASI_CRM_SegmentationCriteria__c (Name='Test',ASI_CRM_Channel__c=channel.Id, ASI_CRM_Outlet_New_Image__c='Iconic',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_SegmentationCriteria__cASI_CRM_CN_Segmentation_Criteria'));
              INSERT SegmentationCriteria;
              
              Id rtWS = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_CN_WS');
              Id rtOutlet = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN');
              
              /*list<ASI_CRM_AccountsAdditionalField__c> Customers = new list<ASI_CRM_AccountsAdditionalField__c>();
              Customers.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Commercial_Team__c = 'Premium',ASI_CRM_CN_New_Image__c='Iconic',RecordTypeId=rtWS,Name='TEST', ASI_CRM_CN_Image__c='Iconic',ASI_CRM_CN_CCity__c=city.Id,ASI_CRM_CN_NewChannel__c=channel.Id));
              Customers.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Commercial_Team__c = 'Premium',ASI_CRM_CN_New_Image__c='Iconic',RecordTypeId=rtOutlet,Name='TEST', ASI_CRM_CN_Image__c='Iconic',ASI_CRM_CN_CCity__c=city.Id,ASI_CRM_CN_NewChannel__c=channel.Id));
              insert Customers;

              //Covered_Outlet
              list<ASI_CRM_AccountsAdditionalField__c> ChildCustomers = new list<ASI_CRM_AccountsAdditionalField__c>();
              ChildCustomers.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Parent_Outlet__c=Customers[1].Id,ASI_CRM_CN_Commercial_Team__c = 'Premium',RecordTypeId=rtOutlet,Name='TEST', ASI_CRM_CN_Image__c='Iconic',ASI_CRM_CN_CCity__c=city.Id,ASI_CRM_CN_NewChannel__c=channel.Id));
              insert ChildCustomers;



          list<ASI_CRM_AccountsAdditionalField__c> ChildChildCustomers = new list<ASI_CRM_AccountsAdditionalField__c>();
          ChildChildCustomers.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Parent_Outlet__c=ChildCustomers[0].Id,ASI_CRM_CN_Commercial_Team__c = 'Premium',RecordTypeId=rtOutlet,Name='TEST', ASI_CRM_CN_Image__c='Iconic',ASI_CRM_CN_CCity__c=city.Id,ASI_CRM_CN_NewChannel__c=channel.Id));
          insert ChildChildCustomers;*/
        
        ASI_MFM_Sub_Channel__c subChannel = new ASI_MFM_Sub_Channel__c(ASI_CRM_CN_Channel__c=channel.Id);
        insert subChannel;
        
        ASI_CRM_CN_Channel__c newChannel = new ASI_CRM_CN_Channel__c(ASI_CRM_For_Outlet__c = true, Name='Restaurant',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CN_Channel__cASI_CRM_CN_New_Channel'),ASI_CRM_CN_On_Off__c='OFF');
        insert newChannel;
        
        list<ASI_CRM_AccountsAdditionalField__c> Customers = new list<ASI_CRM_AccountsAdditionalField__c>();
        Customers.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Eng_Name__c = 'b', ASI_CRM_CN_Chi_Name__c = 'b', ASI_CRM_CN_Commercial_Team__c = 'Premium', ASI_CRM_CN_Sub_Channel__c=subChannel.Id, ASI_CRM_CN_CCity__c=city.Id, ASI_CRM_Latest_Call_Plan_Date__c=system.today(), RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN'), ASI_CRM_CN_NewChannel__c = newChannel.Id, ASI_CRM_CN_Type_of_Restaurant__c = 'International',ASI_CRM_CN_Spending_per_head__c=1));
        Customers.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Eng_Name__c = 'c', ASI_CRM_CN_Chi_Name__c = 'c', ASI_CRM_CN_Commercial_Team__c = 'Premium', ASI_CRM_CN_Sub_Channel__c=subChannel.Id, ASI_CRM_CN_CCity__c=city.Id, ASI_CRM_Latest_Call_Plan_Date__c=system.today(), RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN'), ASI_CRM_CN_NewChannel__c = newChannel.Id, ASI_CRM_CN_Type_of_Restaurant__c = 'International',ASI_CRM_CN_Spending_per_head__c=1));
        insert Customers;
        
        
        list<ASI_CRM_AccountsAdditionalField__c> ChildCustomers = new list<ASI_CRM_AccountsAdditionalField__c>();
        ChildCustomers.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Parent_Outlet__c=Customers[1].Id,ASI_CRM_CN_Eng_Name__c = 'a', ASI_CRM_CN_Chi_Name__c = 'a', ASI_CRM_CN_Commercial_Team__c = 'Premium', ASI_CRM_CN_Sub_Channel__c=subChannel.Id, ASI_CRM_CN_CCity__c=city.Id, ASI_CRM_Latest_Call_Plan_Date__c=system.today(), RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN'), ASI_CRM_CN_NewChannel__c = newChannel.Id, ASI_CRM_CN_Type_of_Restaurant__c = 'International',ASI_CRM_CN_Spending_per_head__c=1));
        insert ChildCustomers;
        
        
        User currentUser = [SELECT id, name, Managerid, ASI_CRM_CN_Prefix__c,LanguageLocaleKey FROM USER WHERE id =:UserInfo.getUserId()];
        currentUser.LanguageLocaleKey='en_US';
        update currentUser;
        
        list<ASI_HK_CRM_Running_Number__c> rns = new list<ASI_HK_CRM_Running_Number__c>();
        rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_TH_CRM_Contract__c', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_TH_CRM_PaymentRequest__c', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        if(!String.isBlank(currentUser.ASI_CRM_CN_Prefix__c))
            rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_'+currentUser.ASI_CRM_CN_Prefix__c, recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        else{
            rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_NULL', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
            rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        }
        insert rns;
        
        
        
        
        
        List<ASI_HK_CRM_Product_Category__c> ProductCategoryList= new List<ASI_HK_CRM_Product_Category__c> ();
        ProductCategoryList.add(new ASI_HK_CRM_Product_Category__c(Name='Category1',ASI_CRM_CN_Chinese_Name__c='Category',ASI_HK_CRM_English_Name__c='Category',ASI_HK_CRM_Sequence__c=1,recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Product_Category__cASI_CRM_CN_Product_Category')));
        ProductCategoryList.add(new ASI_HK_CRM_Product_Category__c(Name='Category2',ASI_CRM_CN_Chinese_Name__c='Category2',ASI_HK_CRM_English_Name__c='Category',ASI_HK_CRM_Sequence__c=2,recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Product_Category__cASI_CRM_CN_Product_Category')));
        ProductCategoryList.add(new ASI_HK_CRM_Product_Category__c(Name='Category3',ASI_CRM_CN_Chinese_Name__c='Category1',ASI_HK_CRM_English_Name__c='Category',ASI_HK_CRM_Sequence__c=3,recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Product_Category__cASI_CRM_CN_Product_Category')));
        
        insert ProductCategoryList;
        
        
        
        
        List<ASI_TH_CRM_Sub_category__c> SubCategoryList= new List<ASI_TH_CRM_Sub_category__c>();
        SubCategoryList.add(new ASI_TH_CRM_Sub_category__c(Name='SubCategory1',ASI_CRM_CN_Product_Category__c=ProductCategoryList[0].Id,recordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_Sub_category__cASI_CRM_CN_Sub_Category')));
        SubCategoryList.add(new ASI_TH_CRM_Sub_category__c(Name='SubCategory2',ASI_CRM_CN_Product_Category__c=ProductCategoryList[1].Id,recordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_Sub_category__cASI_CRM_CN_Sub_Category')));
        SubCategoryList.add(new ASI_TH_CRM_Sub_category__c(Name='SubCategory3',ASI_CRM_CN_Product_Category__c=ProductCategoryList[2].Id,recordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_Sub_category__cASI_CRM_CN_Sub_Category')));
        
        insert SubCategoryList;
        
        
        List<ASI_MFM_Brand__c> BrandList = new List<ASI_MFM_Brand__c> ();
        BrandList.add(new ASI_MFM_Brand__c (Name='Test1',ASI_CRM_CN_Competitor__c=false,ASI_TH_CRM_Sub_category__c=SubCategoryList[0].Id,recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Brand__cASI_FOC_CN_Brand')));
        BrandList.add(new ASI_MFM_Brand__c (Name='Test2',ASI_CRM_CN_Competitor__c=false,ASI_TH_CRM_Sub_category__c=SubCategoryList[1].Id,recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Brand__cASI_FOC_CN_Brand')));
        BrandList.add(new ASI_MFM_Brand__c (Name='Test3',ASI_CRM_CN_Competitor__c=false,ASI_TH_CRM_Sub_category__c=SubCategoryList[2].Id,recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Brand__cASI_FOC_CN_Brand')));
        
        Insert BrandList;
        
        
        
        
        //Sub Brand Grade
        list<ASI_CRM_Sub_Brand_Grade__c> grades = new list<ASI_CRM_Sub_Brand_Grade__c>();
        grades.add(new ASI_CRM_Sub_Brand_Grade__c (Name='Premium',ASI_CRM_Chinese_Name__c='Test1',ASI_CRM_Chinese_Description__c='1. Standard + Premium 标准档 + 高档',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_Sub_Brand_Grade__cASI_CRM_CN_Sub_brand_Grade')));
        grades.add(new ASI_CRM_Sub_Brand_Grade__c (Name='TEST2',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_Sub_Brand_Grade__cASI_CRM_CN_Sub_brand_Grade')));
        grades.add(new ASI_CRM_Sub_Brand_Grade__c (Name='TEST3',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_Sub_Brand_Grade__cASI_CRM_CN_Sub_brand_Grade')));
        insert grades;
        
        
        list<ASI_MFM_Sub_brand__c> subBrands = new list<ASI_MFM_Sub_brand__c>();
        for(ASI_CRM_Sub_Brand_Grade__c grade :grades) {
            subBrands.add(new ASI_MFM_Sub_brand__c (Name='TEST1',ASI_MFM_Active_for_CRM__c=true,ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,RecordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand'),
                                                    ASI_CRM_CN_Sub_brand_Grade__c=grade.Id,ASI_MFM_Brand__c=BrandList[0].Id));
            subBrands.add(new ASI_MFM_Sub_brand__c (Name='TEST2',ASI_MFM_Active_for_CRM__c=true,RecordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand'),
                                                    ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,
                                                    ASI_CRM_CN_Sub_brand_Grade__c=grade.Id,ASI_MFM_Brand__c=BrandList[1].Id));
            subBrands.add(new ASI_MFM_Sub_brand__c ( Name='TEST3',ASI_MFM_Active_for_CRM__c=true,RecordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand'),
                                                    ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,
                                                    ASI_CRM_CN_Sub_brand_Grade__c=grade.Id,ASI_MFM_Brand__c=BrandList[2].Id));
            subBrands.add(new ASI_MFM_Sub_brand__c ( Name='999',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand'),
                                                    ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,ASI_MFM_Sub_brand_Code__c = '999' ,ASI_MFM_Active_for_CRM__c = true ,
                                                    ASI_CRM_CN_Sub_brand_Grade__c=grade.Id,ASI_MFM_Brand__c=BrandList[0].Id));
        }
        
        insert subBrands;
        
        
        List<ASI_CRM_Sub_Brand_Assignment__c> SubBrandAssignmentList= new List<ASI_CRM_Sub_Brand_Assignment__c>();
        for(ASI_MFM_Sub_brand__c SubBrandItem:subBrands){
            SubBrandAssignmentList.add(new ASI_CRM_Sub_Brand_Assignment__c(ASI_CRM_Sub_Brand__c=SubBrandItem.Id,ASI_CRM_Segmentation_Criteria__c=SegmentationCriteria.Id));
        }
        
        insert SubBrandAssignmentList;
        
        
        List<ASI_MFM_A_C_Code__c> ACCodeList = new  List<ASI_MFM_A_C_Code__c>();
        ACCodeList.add(new ASI_MFM_A_C_Code__c( Name='0000000000000', ASI_MFM_A_C_Code__c='000010000',ASI_MFM_A_C_Description__c='ASI_CRM_CN_Variable_Cost_Contract',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_CN_A_C_Code') ));
        ACCodeList.add(new ASI_MFM_A_C_Code__c( Name='5275.010000 PRC - Bottle Return Service', ASI_MFM_A_C_Code__c='5275.010000',ASI_MFM_A_C_Description__c='Bottle Return Service',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_CN_A_C_Code') ));
        ACCodeList.add(new ASI_MFM_A_C_Code__c( Name='5275.020000 Promotion Service Fee', ASI_MFM_A_C_Code__c='5275.020000',ASI_MFM_A_C_Description__c='Promotion Service Fee',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_CN_A_C_Code') ));
        ACCodeList.add(new ASI_MFM_A_C_Code__c( Name='5275.030000 PRC - Variable Event Cost', ASI_MFM_A_C_Code__c='5275.030000',ASI_MFM_A_C_Description__c='Variable Event Cost',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_CN_A_C_Code') ));
        ACCodeList.add(new ASI_MFM_A_C_Code__c( Name='5275.040000 PRC - Fixed Event Cost',ASI_MFM_A_C_CN_Description__c='夜店活动费用(固定)', ASI_MFM_A_C_Code__c='5275.040000',ASI_MFM_A_C_Description__c='PRC - Fixed Event Cost'  ,recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_CN_A_C_Code') ));
        insert ACCodeList;
        
        
        List<ASI_CRM_Contract_Cost_Setting__c> ContractCostSettingList= new List<ASI_CRM_Contract_Cost_Setting__c>();
        
        ContractCostSettingList.add(new ASI_CRM_Contract_Cost_Setting__c(ASI_CRM_CN_Activity_Code__c=ACCodeList[0].Id,ASI_CRM_CN_Promotion_Type__c='Heavy Contract ON',
                                                                         ASI_CRM_CN_Fixed_Cost_Contract__c=true,ASI_CRM_CN_Variable_Cost_Contract__c=true));
        
        ContractCostSettingList.add(new ASI_CRM_Contract_Cost_Setting__c(ASI_CRM_CN_Activity_Code__c=ACCodeList[0].Id,ASI_CRM_CN_Promotion_Type__c='Heavy Contract ON',ASI_CRM_CN_Variable_Cost_Contract__c=true,
                                                                         ASI_CRM_CN_Fixed_Cost_Contract__c=false,ASI_CRM_CN_BRSF_Activity_Code_Default__c=true));
        
        ContractCostSettingList.add(new ASI_CRM_Contract_Cost_Setting__c(ASI_CRM_CN_Activity_Code__c=ACCodeList[0].Id,ASI_CRM_CN_Promotion_Type__c='Heavy Contract ON',ASI_CRM_CN_Variable_Cost_Contract__c=true,
                                                                         ASI_CRM_CN_Fixed_Cost_Contract__c=false,ASI_CRM_PSF_Activity_Code_Default__c=true));
        
        ContractCostSettingList.add(new ASI_CRM_Contract_Cost_Setting__c(ASI_CRM_CN_Activity_Code__c=ACCodeList[0].Id,ASI_CRM_CN_Promotion_Type__c='Heavy Contract ON',ASI_CRM_CN_Variable_Cost_Contract__c=true,
                                                                         ASI_CRM_CN_Fixed_Cost_Contract__c=false,ASI_CRM_VEC_Activity_Code_Defaul__c=true));

        ContractCostSettingList.add(new ASI_CRM_Contract_Cost_Setting__c(ASI_CRM_CN_Activity_Code__c=ACCodeList[4].Id,ASI_CRM_CN_Promotion_Type__c='Heavy Contract ON',
                                                                         ASI_CRM_CN_Fixed_Cost_Contract__c=true,ASI_CRM_CN_Variable_Cost_Contract__c=false));
        
        insert ContractCostSettingList;
        
        ASI_CRM_SpecialPromotionTypeSetting__c oldspts = new ASI_CRM_SpecialPromotionTypeSetting__c( ASI_CRM_Promotion_Type__c = 'a');
        insert oldspts;
        
        ASI_CRM_SpecialPromotionTypeSetting__c newspts = new ASI_CRM_SpecialPromotionTypeSetting__c(ASI_CRM_Promotion_Type__c = 'Heavy Contract On',recordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_SpecialPromotionTypeSetting__cASI_CRM_CN_SpecialPromotionTypeSetting'));
        insert newspts;
        
        ASI_CRM_Special_Promotion_Type_Mapping__c sptm = new ASI_CRM_Special_Promotion_Type_Mapping__c(ASI_CRM_Mapping_of_New_Promotion_Type__c = newspts.Id,ASI_CRM_Mapping_of_Old_Promotion_Type__c = oldspts.Id,recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Special_Promotion_Type_Mapping__cASI_CRM_CN_Special_Promotion_Type_Mapping'));
        insert sptm;
        
        
        
        Date today = Date.newInstance(2020, 5, 25);
        Date PO_Start_Date = date.newinstance(today.year(), today.month(), 1);
        Date PO_End_Date = PO_Start_Date.addMonths(1)-1;
        
        
        ASI_TH_CRM_Contract__c GroupContract = new ASI_TH_CRM_Contract__c(recordtypeid = Global_RecordTypeCache.getRTID('ASI_TH_CRM_Contract__cASI_CRM_CN_Group_Contract'),
                                                                          ASI_CRM_CN_PO_Start_Date__c = PO_Start_Date,
                                                                          ASI_CRM_CN_PO_End_Date__c =PO_End_Date,
                                                                          Name = 'Noah C4',
                                                                          ASI_CRM_CN_Outlet_WS__c=Customers[1].Id);
        insert GroupContract;

        ASI_TH_CRM_Contract__c Contract = new ASI_TH_CRM_Contract__c(recordtypeid = Global_RecordTypeCache.getRTID('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract'),
            ASI_CRM_CN_Status__c = 'Final',ASI_CRM_CN_Group_Contract__c=GroupContract.Id,
            ASI_CRM_CN_PO_Start_Date__c = PO_Start_Date,
            ASI_CRM_CN_PO_End_Date__c =PO_End_Date,
            ASI_CRM_CN_PO_Version__c = '0.1',ASI_TH_CRM_Promotion_Type__c='Heavy Contract On',
            Name = 'Contract1',
            ASI_CRM_CN_Expected_BRSF_Est_Total__c = 1000,
            ASI_CRM_CN_Outlet_WS__c=Customers[1].Id,ASI_CRM_Volume_Option__c = 'Normal');
        insert Contract;
        
        test.startTest();
        
        List<ASI_CRM_Methodology__c> MethodologyList= new List<ASI_CRM_Methodology__c> ();
        MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test1',ASI_CRM_Methodology_Code__c='01',ASI_CRM_Default__c=true,ASI_CRM_Chinese_Name__c='123',ASI_CRM_Type__c='BRSF',recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Methodology__cASI_CRM_CN_Methodology')));
        MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test2',ASI_CRM_Methodology_Code__c='01',ASI_CRM_Default__c=true,ASI_CRM_Chinese_Name__c='Test 123',ASI_CRM_Type__c='PSF',recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Methodology__cASI_CRM_CN_Methodology')));
        MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test3',ASI_CRM_Methodology_Code__c='01',ASI_CRM_Default__c=true,ASI_CRM_Chinese_Name__c='Test 123',ASI_CRM_Type__c='Variable Event Cost',recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Methodology__cASI_CRM_CN_Methodology')));
        
        
        MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test1',ASI_CRM_Methodology_Code__c='01',ASI_CRM_Chinese_Name__c='123',ASI_CRM_Type__c='BRSF',recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Methodology__cASI_CRM_CN_Methodology')));
        MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test2',ASI_CRM_Methodology_Code__c='01',ASI_CRM_Chinese_Name__c='123',ASI_CRM_Type__c='PSF',recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Methodology__cASI_CRM_CN_Methodology')));
        MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test3',ASI_CRM_Methodology_Code__c='01',ASI_CRM_Chinese_Name__c='123',ASI_CRM_Type__c='Variable Event Cost',recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Methodology__cASI_CRM_CN_Methodology')));
        insert MethodologyList;
        
        
        //Methodology Assignment
        List<ASI_CRM_Methodology_Assignment__c> MethodologyAssignmentList = new List<ASI_CRM_Methodology_Assignment__c>();
        MethodologyAssignmentList.add(new ASI_CRM_Methodology_Assignment__c(ASI_CRM_Methodology__c=MethodologyList[0].Id,ASI_CRM_Key_Principle__c=true,ASI_CRM_Methodology_Commercial_Team__c='Premium',ASI_CRM_Region__c=region.Id));
        MethodologyAssignmentList.add(new ASI_CRM_Methodology_Assignment__c(ASI_CRM_Methodology__c=MethodologyList[1].Id,ASI_CRM_Key_Principle__c=true,ASI_CRM_Methodology_Commercial_Team__c='Premium',ASI_CRM_Region__c=region.Id));
        MethodologyAssignmentList.add(new ASI_CRM_Methodology_Assignment__c(ASI_CRM_Methodology__c=MethodologyList[2].Id,ASI_CRM_Key_Principle__c=true,ASI_CRM_Methodology_Commercial_Team__c='Premium',ASI_CRM_Region__c=region.Id));
        MethodologyAssignmentList.add(new ASI_CRM_Methodology_Assignment__c(ASI_CRM_Methodology__c=MethodologyList[3].Id,ASI_CRM_Key_Principle__c=true,ASI_CRM_Methodology_Commercial_Team__c='Premium',ASI_CRM_Region__c=region.Id));
        MethodologyAssignmentList.add(new ASI_CRM_Methodology_Assignment__c(ASI_CRM_Methodology__c=MethodologyList[4].Id,ASI_CRM_Key_Principle__c=true,ASI_CRM_Methodology_Commercial_Team__c='Premium',ASI_CRM_Region__c=region.Id));
        MethodologyAssignmentList.add(new ASI_CRM_Methodology_Assignment__c(ASI_CRM_Methodology__c=MethodologyList[5].Id,ASI_CRM_Key_Principle__c=true,ASI_CRM_Methodology_Commercial_Team__c='Premium',ASI_CRM_Region__c=region.Id));
        
        //insert MethodologyAssignmentList ;
        
        
        
        
        List<ASI_CRM_Module__c> ModuleList = new List<ASI_CRM_Module__c>();
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='Std. Btl.',ASI_CRM_Volume_Base__c='By Sub-Brand',ASI_CRM_Line_Type__c='BRSF',ASI_CRM_Methodology__c=MethodologyList[0].Id));
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='Std. Btl.',ASI_CRM_Volume_Base__c='By Sub-Brand',ASI_CRM_Line_Type__c='PSF',ASI_CRM_Methodology__c=MethodologyList[1].Id));
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='CR12 Extra Eqv.',ASI_CRM_Volume_Base__c='By Grade',ASI_CRM_Line_Type__c='PSF',ASI_CRM_Methodology__c=MethodologyList[1].Id));
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='CR12 Extra Eqv.',ASI_CRM_Volume_Base__c='By Category',ASI_CRM_Line_Type__c='PSF',ASI_CRM_Methodology__c=MethodologyList[1].Id));
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='CR12 Extra Eqv.',ASI_CRM_Volume_Base__c='By Total',ASI_CRM_Line_Type__c='PSF',ASI_CRM_Methodology__c=MethodologyList[1].Id));
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='CR12 Extra Eqv.',ASI_CRM_Volume_Base__c='By Sub-Brand',ASI_CRM_Line_Type__c='Variable Event Cost',ASI_CRM_Methodology__c=MethodologyList[2].Id));

        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='Std. Btl.',ASI_CRM_Volume_Base__c='By Sub-Brand',ASI_CRM_Line_Type__c='Fixed',ASI_CRM_CN_AC_Code__c = ACCodeList[4].Id));
        
        insert ModuleList;
        
        ASI_CRM_Contract_Cost__c contractCost = new ASI_CRM_Contract_Cost__c(ASI_CRM_CN_Contract__c = Contract.id,
                                                                             ASI_CRM_CN_Estimate_Amount__c = 100000,
                                                                             ASI_CRM_CN_Cost_Type__c = 'Fixed',
                                                                             ASI_CRM_CN_Other_Cost_Payment_Request__c = true,
                                                                             recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_Contract_Cost__cASI_CRM_CN_Contract_Cost') );
        insert contractCost;
        
        list<ASI_CRM_CN_Contract_BRSF_Line_Item__c> ContractLineList = new list<ASI_CRM_CN_Contract_BRSF_Line_Item__c>();
        list<ASI_CRM_CN_Covered_Outlet__c> cos = new list<ASI_CRM_CN_Covered_Outlet__c>();
        for(ASI_MFM_Sub_brand__c subBrand :subBrands) {
            ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract.Id,
                                                                           ASI_CRM_CN_Est_Monthly_Qty__c=1,ASI_CRM_Module__c=ModuleList[0].Id,
                                                                           ASI_CRM_CN_Contract_Monthly_Qty__c=1,
                                                                           ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,
                                                                           ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,ASI_CRM_Type__c='BRSF',
                                                                           ASI_CRM_CN_Sub_Brand__c=subBrand.Id,
                                                                           recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF')));
        }
        
        for(ASI_MFM_Sub_brand__c subBrand :subBrands) {
            ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract.Id,
                                                                           ASI_CRM_CN_Est_Monthly_Qty__c=1,ASI_CRM_Module__c=ModuleList[1].Id,
                                                                           ASI_CRM_CN_Contract_Monthly_Qty__c=1,ASI_CRM_Volume_Base__c='By Sub-Brand',
                                                                           ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,
                                                                           ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,ASI_CRM_Type__c='PSF',
                                                                           ASI_CRM_CN_Sub_Brand__c=subBrand.Id,
                                                                           recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF')));
        }

        for(ASI_MFM_Sub_brand__c subBrand :subBrands) {
            ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract.Id,
                                                                           ASI_CRM_CN_Est_Monthly_Qty__c=1,ASI_CRM_Module__c=ModuleList[6].Id,
                                                                           ASI_CRM_CN_Contract_Monthly_Qty__c=1,ASI_CRM_Volume_Base__c='By Sub-Brand',
                                                                           ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,
                                                                           ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,ASI_CRM_Type__c='Fixed',
                                                                           ASI_CRM_CN_Sub_Brand__c=subBrand.Id,
                                                                           recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF')));
        }
        
        ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract.Id,ASI_CRM_Type__c='PSF',ASI_CRM_Volume_Base__c='By Grade',
                                                                       ASI_CRM_CN_Est_Monthly_Qty__c=4,ASI_CRM_Module__c=ModuleList[2].Id,
                                                                       ASI_CRM_CN_Contract_Monthly_Qty__c=4,ASI_CRM_Sub_Brand_Grade__c=grades[0].Id,
                                                                       ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,
                                                                       ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,
                                                                       ASI_CRM_CN_Sub_Brand__c=null,
                                                                       recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF') ));
        ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract.Id,ASI_CRM_Type__c='PSF',ASI_CRM_Volume_Base__c='By Category',
                                                                       ASI_CRM_CN_Est_Monthly_Qty__c=4,ASI_CRM_Module__c=ModuleList[3].Id,
                                                                       ASI_CRM_CN_Contract_Monthly_Qty__c=4,ASI_CRM_Product_Category__c=ProductCategoryList[0].Id,
                                                                       ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,
                                                                       ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,
                                                                       ASI_CRM_CN_Sub_Brand__c=null,
                                                                       recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF') ));
        ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract.Id,ASI_CRM_Type__c='PSF',ASI_CRM_Volume_Base__c='By Total',
                                                                       ASI_CRM_CN_Est_Monthly_Qty__c=4,ASI_CRM_Module__c=ModuleList[4].Id,
                                                                       ASI_CRM_CN_Contract_Monthly_Qty__c=4,
                                                                       ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,
                                                                       ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,
                                                                       ASI_CRM_CN_Sub_Brand__c=null,
                                                                       recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF') ));
        for(ASI_MFM_Sub_brand__c subBrand :subBrands) {
            ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract.Id,
                                                                           ASI_CRM_CN_Est_Monthly_Qty__c=1,ASI_CRM_Module__c=ModuleList[5].Id,
                                                                           ASI_CRM_CN_Contract_Monthly_Qty__c=1,ASI_CRM_Volume_Base__c='By Sub-Brand',
                                                                           ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,
                                                                           ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,ASI_CRM_Type__c='Variable Event Cost',
                                                                           ASI_CRM_CN_Sub_Brand__c=subBrand.Id,
                                                                           recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF')));
        }
        
        
        
        
        
        
        PageReference EnterPage = Page.ASI_CRM_CN_ViewHeavyContractPage;
        
        Map<String, String> pageParams = EnterPage.getParameters();
        
        pageParams.put('id', Contract.id);
        ApexPages.StandardController sc = new ApexPages.standardController(new ASI_TH_CRM_Contract__c());
        
        ASI_CRM_CN_EditHeavyContractDetailCtrl con = new ASI_CRM_CN_EditHeavyContractDetailCtrl(new ApexPages.Standardcontroller(Contract));
        con.AddAllChildOutlets();
        
        con.saveItems();
        
        
        con.CancelProcess();
        test.stopTest(); 
    }


    static testMethod void EditHeavyContractDetailCtrlTest5() {
        //Test Class for ASI_CRM_CN_EditHeavyContractDetailCtrl
        //
        //
        List<ASI_CRM_CN_Channel_Group__c> channelGroupList = new List<ASI_CRM_CN_Channel_Group__c>();

        ASI_CRM_CN_Channel_Group__c channelGroup1 = new ASI_CRM_CN_Channel_Group__c(
                Name = 'OFF MOT',
                ASI_CRM_Channel_Group_Chi_Name__c = 'OFF MOT',
                ASI_CRM_Channel_Group_Eng_Name__c = 'OFF MOT',
                ASI_CRM_Channel_Group_Code__c = 'CN_WS Channel',
                ASI_CRM_External_ID__c = 'CN_OFF MOT',
                ASI_CRM_Sequence__c = 8
        );
        channelGroupList.add(channelGroup1);

        ASI_CRM_CN_Channel_Group__c channelGroup2 = new ASI_CRM_CN_Channel_Group__c(
                Name = 'KTV',
                ASI_CRM_Channel_Group_Chi_Name__c = 'KTV',
                ASI_CRM_Channel_Group_Eng_Name__c = 'KTV',
                ASI_CRM_Channel_Group_Code__c = 'CN_New_KTV_Group',
                ASI_CRM_External_ID__c = 'CN_New_KTV_Group',
                ASI_CRM_Sequence__c = 3
        );
        channelGroupList.add(channelGroup2);

        insert channelGroupList;

        List<ASI_CRM_CN_Channel__c> channelList = new List<ASI_CRM_CN_Channel__c>();

        ASI_CRM_CN_Channel__c channel1 = new ASI_CRM_CN_Channel__c(
                ASI_CRM_For_Outlet__c = true,
                Name='Restaurant',
                RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CN_Channel__cASI_CRM_CN_New_Channel'),
                ASI_CRM_CN_On_Off__c='OFF',
                ASI_CRM_CN_Channel_Group__c= channelGroup1.Id
        );
        channelList.add(channel1);

        ASI_CRM_CN_Channel__c channel2 = new ASI_CRM_CN_Channel__c(
                Name='KTV',
                ASI_CRM_BC_Rate__c=98,
                ASI_CRM_CN_On_Off__c='ON',
                ASI_CRM_For_Outlet__c=true,
                RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CN_Channel__cASI_CRM_CN_New_Channel'),
                ASI_CRM_For_Contract__c=TRUE,
                ASI_CRM_CN_Channel_Group__c=channelGroup2.Id
        );
        channelList.add(channel2);

        insert channelList;
        ASI_CRM_Region__c region = new ASI_CRM_Region__c (Name='Central Region',recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Region__cASI_CRM_CN_Region'));
        insert region;
        
        ASI_CRM_Division__c division = new ASI_CRM_Division__c(Name='TEST', ASI_CRM_Region__c=region.Id);
        insert division;
        
        ASI_CRM_CN_Area__c area = new ASI_CRM_CN_Area__c(Name='TEST', ASI_CRM_English_Name__c='TEST', ASI_CRM_Division__c=division.Id);
        insert area;
        
        ASI_CRM_City__c city = new ASI_CRM_City__c(Name='TEST', ASI_CRM_CN_Area__c=area.Id,ASI_CRM_CN_City_Tier__c='2');
        insert city;

        // 20190808 Wilson Chow start
        /*
        ASI_CRM_CN_Channel__c channel = new ASI_CRM_CN_Channel__c(Name='KTV',ASI_CRM_BC_Rate__c=98,ASI_CRM_CN_On_Off__c='ON',ASI_CRM_For_Outlet__c=true,RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CN_Channel__cASI_CRM_CN_New_Channel'),ASI_CRM_For_Contract__c=TRUE, ASI_CRM_CN_Channel_Group__c=channelGroup.Id);
        insert channel;
        */
        List<ASI_CRM_CN_Channel__c> channel = [SELECT Id FROM ASI_CRM_CN_Channel__c];
        // 20190808 Wilson Chow end

        ASI_CRM_SegmentationCriteria__c SegmentationCriteria= new ASI_CRM_SegmentationCriteria__c (Name='Test',ASI_CRM_Channel__c=channel[1].Id, ASI_CRM_Outlet_New_Image__c='Iconic',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_SegmentationCriteria__cASI_CRM_CN_Segmentation_Criteria'));
        INSERT SegmentationCriteria;

        Id rtWS = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_CN_WS');
        Id rtOutlet = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN');
        
        list<ASI_CRM_AccountsAdditionalField__c> Customers = new list<ASI_CRM_AccountsAdditionalField__c>();
        Customers.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Commercial_Team__c = 'Premium',ASI_CRM_CN_New_Image__c='Iconic',RecordTypeId=rtWS,Name='TEST', ASI_CRM_CN_Image__c='Iconic',ASI_CRM_CN_CCity__c=city.Id,ASI_CRM_CN_NewChannel__c=channel[0].Id));
        Customers.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Commercial_Team__c = 'Premium',ASI_CRM_CN_New_Image__c='Iconic',RecordTypeId=rtOutlet,Name='TEST', ASI_CRM_CN_Image__c='Iconic',ASI_CRM_CN_CCity__c=city.Id,ASI_CRM_CN_NewChannel__c=channel[1].Id));
        insert Customers;
        
        //Covered_Outlet
        list<ASI_CRM_AccountsAdditionalField__c> ChildCustomers = new list<ASI_CRM_AccountsAdditionalField__c>();
        ChildCustomers.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Parent_Outlet__c=Customers[1].Id,ASI_CRM_CN_Commercial_Team__c = 'Premium',RecordTypeId=rtOutlet,Name='TEST', ASI_CRM_CN_Image__c='Iconic',ASI_CRM_CN_CCity__c=city.Id,ASI_CRM_CN_NewChannel__c=channel[1].Id));
        insert ChildCustomers;
        

        
        User currentUser = [SELECT id, name, Managerid, ASI_CRM_CN_Prefix__c,LanguageLocaleKey FROM USER WHERE id =:UserInfo.getUserId()];
        currentUser.LanguageLocaleKey='zh_CN';
        update currentUser;
        
        list<ASI_HK_CRM_Running_Number__c> rns = new list<ASI_HK_CRM_Running_Number__c>();
        rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_TH_CRM_Contract__c', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_TH_CRM_PaymentRequest__c', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        if(!String.isBlank(currentUser.ASI_CRM_CN_Prefix__c))
            rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_'+currentUser.ASI_CRM_CN_Prefix__c, recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        else{
            rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_NULL', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
            rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        }
        insert rns;
        
        
        
        
        
        List<ASI_HK_CRM_Product_Category__c> ProductCategoryList= new List<ASI_HK_CRM_Product_Category__c> ();
        ProductCategoryList.add(new ASI_HK_CRM_Product_Category__c(Name='Category1',ASI_CRM_CN_Chinese_Name__c='Category',ASI_HK_CRM_English_Name__c='Category',ASI_HK_CRM_Sequence__c=1,recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Product_Category__cASI_CRM_CN_Product_Category')));
        ProductCategoryList.add(new ASI_HK_CRM_Product_Category__c(Name='Category2',ASI_CRM_CN_Chinese_Name__c='Category2',ASI_HK_CRM_English_Name__c='Category',ASI_HK_CRM_Sequence__c=2,recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Product_Category__cASI_CRM_CN_Product_Category')));
        ProductCategoryList.add(new ASI_HK_CRM_Product_Category__c(Name='Category3',ASI_CRM_CN_Chinese_Name__c='Category1',ASI_HK_CRM_English_Name__c='Category',ASI_HK_CRM_Sequence__c=3,recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Product_Category__cASI_CRM_CN_Product_Category')));
        
        insert ProductCategoryList;
        
        
        
        
        List<ASI_TH_CRM_Sub_category__c> SubCategoryList= new List<ASI_TH_CRM_Sub_category__c>();
        SubCategoryList.add(new ASI_TH_CRM_Sub_category__c(Name='SubCategory1',ASI_CRM_CN_Product_Category__c=ProductCategoryList[0].Id,recordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_Sub_category__cASI_CRM_CN_Sub_Category')));
        SubCategoryList.add(new ASI_TH_CRM_Sub_category__c(Name='SubCategory2',ASI_CRM_CN_Product_Category__c=ProductCategoryList[1].Id,recordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_Sub_category__cASI_CRM_CN_Sub_Category')));
        SubCategoryList.add(new ASI_TH_CRM_Sub_category__c(Name='SubCategory3',ASI_CRM_CN_Product_Category__c=ProductCategoryList[2].Id,recordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_Sub_category__cASI_CRM_CN_Sub_Category')));
        
        insert SubCategoryList;
        
        
        List<ASI_MFM_Brand__c> BrandList = new List<ASI_MFM_Brand__c> ();
        BrandList.add(new ASI_MFM_Brand__c (Name='Test1',ASI_CRM_CN_Competitor__c=false,ASI_TH_CRM_Sub_category__c=SubCategoryList[0].Id,recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Brand__cASI_FOC_CN_Brand')));
        BrandList.add(new ASI_MFM_Brand__c (Name='Test2',ASI_CRM_CN_Competitor__c=false,ASI_TH_CRM_Sub_category__c=SubCategoryList[1].Id,recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Brand__cASI_FOC_CN_Brand')));
        BrandList.add(new ASI_MFM_Brand__c (Name='Test3',ASI_CRM_CN_Competitor__c=false,ASI_TH_CRM_Sub_category__c=SubCategoryList[2].Id,recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Brand__cASI_FOC_CN_Brand')));
        
        Insert BrandList;
        
        
        
        
        //Sub Brand Grade
        list<ASI_CRM_Sub_Brand_Grade__c> grades = new list<ASI_CRM_Sub_Brand_Grade__c>();
        grades.add(new ASI_CRM_Sub_Brand_Grade__c (Name='Premium',ASI_CRM_Chinese_Name__c='Test1',ASI_CRM_Chinese_Description__c='1. Standard + Premium 标准档 + 高档',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_Sub_Brand_Grade__cASI_CRM_CN_Sub_brand_Grade')));
        grades.add(new ASI_CRM_Sub_Brand_Grade__c (Name='TEST2',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_Sub_Brand_Grade__cASI_CRM_CN_Sub_brand_Grade')));
        grades.add(new ASI_CRM_Sub_Brand_Grade__c (Name='TEST3',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_Sub_Brand_Grade__cASI_CRM_CN_Sub_brand_Grade')));
        insert grades;
        
        
        list<ASI_MFM_Sub_brand__c> subBrands = new list<ASI_MFM_Sub_brand__c>();
        for(ASI_CRM_Sub_Brand_Grade__c grade :grades) {
            subBrands.add(new ASI_MFM_Sub_brand__c (Name='TEST1',ASI_MFM_Active_for_CRM__c=true,ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,RecordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand'),
                                                    ASI_CRM_CN_Sub_brand_Grade__c=grade.Id,ASI_MFM_Brand__c=BrandList[0].Id));
            subBrands.add(new ASI_MFM_Sub_brand__c (Name='TEST2',ASI_MFM_Active_for_CRM__c=true,RecordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand'),
                                                    ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,
                                                    ASI_CRM_CN_Sub_brand_Grade__c=grade.Id,ASI_MFM_Brand__c=BrandList[1].Id));
            subBrands.add(new ASI_MFM_Sub_brand__c ( Name='TEST3',ASI_MFM_Active_for_CRM__c=true,RecordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand'),
                                                    ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,
                                                    ASI_CRM_CN_Sub_brand_Grade__c=grade.Id,ASI_MFM_Brand__c=BrandList[2].Id));
            subBrands.add(new ASI_MFM_Sub_brand__c ( Name='999',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand'),
                                                    ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,ASI_MFM_Sub_brand_Code__c = '999' ,ASI_MFM_Active_for_CRM__c = true ,
                                                    ASI_CRM_CN_Sub_brand_Grade__c=grade.Id,ASI_MFM_Brand__c=BrandList[0].Id));
        }
        
        insert subBrands;
        
        
        List<ASI_CRM_Sub_Brand_Assignment__c> SubBrandAssignmentList= new List<ASI_CRM_Sub_Brand_Assignment__c>();
        for(ASI_MFM_Sub_brand__c SubBrandItem:subBrands){
            SubBrandAssignmentList.add(new ASI_CRM_Sub_Brand_Assignment__c(ASI_CRM_Sub_Brand__c=SubBrandItem.Id,ASI_CRM_Segmentation_Criteria__c=SegmentationCriteria.Id));
        }
        
        insert SubBrandAssignmentList;


        List<ASI_MFM_A_C_Code__c> ACCodeList = new  List<ASI_MFM_A_C_Code__c>();
        ACCodeList.add(new ASI_MFM_A_C_Code__c( Name='0000000000000', ASI_MFM_A_C_Code__c='000010000',ASI_MFM_A_C_Description__c='ASI_CRM_CN_Variable_Cost_Contract',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_CN_A_C_Code') ));
        ACCodeList.add(new ASI_MFM_A_C_Code__c( Name='5275.010000 PRC - Bottle Return Service', ASI_MFM_A_C_Code__c='5275.010000',ASI_MFM_A_C_Description__c='Bottle Return Service',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_CN_A_C_Code') ));
        ACCodeList.add(new ASI_MFM_A_C_Code__c( Name='5275.020000 Promotion Service Fee', ASI_MFM_A_C_Code__c='5275.020000',ASI_MFM_A_C_Description__c='Promotion Service Fee',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_CN_A_C_Code') ));
        ACCodeList.add(new ASI_MFM_A_C_Code__c( Name='5275.030000 PRC - Variable Event Cost', ASI_MFM_A_C_Code__c='5275.030000',ASI_MFM_A_C_Description__c='Variable Event Cost',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_CN_A_C_Code') ));
        
        insert ACCodeList;
        
        
        List<ASI_CRM_Contract_Cost_Setting__c> ContractCostSettingList= new List<ASI_CRM_Contract_Cost_Setting__c>();
        
        ContractCostSettingList.add(new ASI_CRM_Contract_Cost_Setting__c(ASI_CRM_CN_Activity_Code__c=ACCodeList[0].Id,ASI_CRM_CN_Promotion_Type__c='Heavy Contract ON',
                                                                         ASI_CRM_CN_Fixed_Cost_Contract__c=true,ASI_CRM_CN_Variable_Cost_Contract__c=true));
        
        ContractCostSettingList.add(new ASI_CRM_Contract_Cost_Setting__c(ASI_CRM_CN_Activity_Code__c=ACCodeList[0].Id,ASI_CRM_CN_Promotion_Type__c='Heavy Contract ON',ASI_CRM_CN_Variable_Cost_Contract__c=true,
                                                                         ASI_CRM_CN_Fixed_Cost_Contract__c=false,ASI_CRM_CN_BRSF_Activity_Code_Default__c=true));
        
        ContractCostSettingList.add(new ASI_CRM_Contract_Cost_Setting__c(ASI_CRM_CN_Activity_Code__c=ACCodeList[0].Id,ASI_CRM_CN_Promotion_Type__c='Heavy Contract ON',ASI_CRM_CN_Variable_Cost_Contract__c=true,
                                                                         ASI_CRM_CN_Fixed_Cost_Contract__c=false,ASI_CRM_PSF_Activity_Code_Default__c=true));
        
        ContractCostSettingList.add(new ASI_CRM_Contract_Cost_Setting__c(ASI_CRM_CN_Activity_Code__c=ACCodeList[0].Id,ASI_CRM_CN_Promotion_Type__c='Heavy Contract ON',ASI_CRM_CN_Variable_Cost_Contract__c=true,
                                                                         ASI_CRM_CN_Fixed_Cost_Contract__c=false,ASI_CRM_VEC_Activity_Code_Defaul__c=true));
        
        insert ContractCostSettingList;
        
        ASI_CRM_SpecialPromotionTypeSetting__c oldspts = new ASI_CRM_SpecialPromotionTypeSetting__c( ASI_CRM_Promotion_Type__c = 'a');
        insert oldspts;
        
        ASI_CRM_SpecialPromotionTypeSetting__c newspts = new ASI_CRM_SpecialPromotionTypeSetting__c(ASI_CRM_Promotion_Type__c = 'Heavy Contract On',recordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_SpecialPromotionTypeSetting__cASI_CRM_CN_SpecialPromotionTypeSetting'));
        insert newspts;
        
        ASI_CRM_Special_Promotion_Type_Mapping__c sptm = new ASI_CRM_Special_Promotion_Type_Mapping__c(ASI_CRM_Mapping_of_New_Promotion_Type__c = newspts.Id,ASI_CRM_Mapping_of_Old_Promotion_Type__c = oldspts.Id,recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Special_Promotion_Type_Mapping__cASI_CRM_CN_Special_Promotion_Type_Mapping'));
        insert sptm;
        
        
        
        Date today = Date.newInstance(2020, 5, 25);
        Date PO_Start_Date = date.newinstance(today.year(), today.month(), 1);
        Date PO_End_Date = PO_Start_Date.addMonths(1)-1;
        
        
        ASI_TH_CRM_Contract__c GroupContract = new ASI_TH_CRM_Contract__c(recordtypeid = Global_RecordTypeCache.getRTID('ASI_TH_CRM_Contract__cASI_CRM_CN_Group_Contract'),
                                                                          ASI_CRM_CN_PO_Start_Date__c = PO_Start_Date,
                                                                          ASI_CRM_CN_PO_End_Date__c =PO_End_Date,
                                                                          Name = 'Noah C4',
                                                                          ASI_CRM_CN_Outlet_WS__c=Customers[1].Id);
        insert GroupContract;
        
        ASI_TH_CRM_Contract__c Contract = new ASI_TH_CRM_Contract__c(recordtypeid = Global_RecordTypeCache.getRTID('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract'),
                                                                     ASI_CRM_CN_Status__c = 'Final',ASI_CRM_CN_Group_Contract__c=GroupContract.Id,
                                                                     ASI_CRM_CN_PO_Start_Date__c = PO_Start_Date,
                                                                     ASI_CRM_CN_PO_End_Date__c =PO_End_Date,
                                                                     ASI_CRM_CN_PO_Version__c = '0.0',ASI_TH_CRM_Promotion_Type__c='Heavy Contract On',
                                                                     Name = 'Contract1',
                                                                     ASI_CRM_CN_Outlet_WS__c=Customers[1].Id,ASI_CRM_Volume_Option__c = 'Normal');
        insert Contract;
        
  
        List<ASI_CRM_Methodology__c> MethodologyList= new List<ASI_CRM_Methodology__c> ();
        MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test1',ASI_CRM_Methodology_Code__c='01',ASI_CRM_Default__c=true,ASI_CRM_Chinese_Name__c='123',ASI_CRM_Type__c='BRSF',recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Methodology__cASI_CRM_CN_Methodology')));
        MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test2',ASI_CRM_Methodology_Code__c='01',ASI_CRM_Default__c=true,ASI_CRM_Chinese_Name__c='Test 123',ASI_CRM_Type__c='PSF',recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Methodology__cASI_CRM_CN_Methodology')));
        MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test3',ASI_CRM_Methodology_Code__c='01',ASI_CRM_Default__c=true,ASI_CRM_Chinese_Name__c='Test 123',ASI_CRM_Type__c='Variable Event Cost',recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Methodology__cASI_CRM_CN_Methodology')));
        
        
        MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test1',ASI_CRM_Methodology_Code__c='01',ASI_CRM_Chinese_Name__c='123',ASI_CRM_Type__c='BRSF',recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Methodology__cASI_CRM_CN_Methodology')));
        MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test2',ASI_CRM_Methodology_Code__c='01',ASI_CRM_Chinese_Name__c='123',ASI_CRM_Type__c='PSF',recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Methodology__cASI_CRM_CN_Methodology')));
        MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test3',ASI_CRM_Methodology_Code__c='01',ASI_CRM_Chinese_Name__c='123',ASI_CRM_Type__c='Variable Event Cost',recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Methodology__cASI_CRM_CN_Methodology')));
        insert MethodologyList;
        
        
        //Methodology Assignment
        List<ASI_CRM_Methodology_Assignment__c> MethodologyAssignmentList = new List<ASI_CRM_Methodology_Assignment__c>();
        MethodologyAssignmentList.add(new ASI_CRM_Methodology_Assignment__c(ASI_CRM_Methodology__c=MethodologyList[0].Id,ASI_CRM_Key_Principle__c=true,ASI_CRM_Methodology_Commercial_Team__c='Premium',ASI_CRM_Region__c=region.Id));
        MethodologyAssignmentList.add(new ASI_CRM_Methodology_Assignment__c(ASI_CRM_Methodology__c=MethodologyList[1].Id,ASI_CRM_Key_Principle__c=true,ASI_CRM_Methodology_Commercial_Team__c='Premium',ASI_CRM_Region__c=region.Id));
        MethodologyAssignmentList.add(new ASI_CRM_Methodology_Assignment__c(ASI_CRM_Methodology__c=MethodologyList[2].Id,ASI_CRM_Key_Principle__c=true,ASI_CRM_Methodology_Commercial_Team__c='Premium',ASI_CRM_Region__c=region.Id));
        MethodologyAssignmentList.add(new ASI_CRM_Methodology_Assignment__c(ASI_CRM_Methodology__c=MethodologyList[3].Id,ASI_CRM_Key_Principle__c=true,ASI_CRM_Methodology_Commercial_Team__c='Premium',ASI_CRM_Region__c=region.Id));
        MethodologyAssignmentList.add(new ASI_CRM_Methodology_Assignment__c(ASI_CRM_Methodology__c=MethodologyList[4].Id,ASI_CRM_Key_Principle__c=true,ASI_CRM_Methodology_Commercial_Team__c='Premium',ASI_CRM_Region__c=region.Id));
        MethodologyAssignmentList.add(new ASI_CRM_Methodology_Assignment__c(ASI_CRM_Methodology__c=MethodologyList[5].Id,ASI_CRM_Key_Principle__c=true,ASI_CRM_Methodology_Commercial_Team__c='Premium',ASI_CRM_Region__c=region.Id));
        
        insert MethodologyAssignmentList ;
        
        
        
        
        List<ASI_CRM_Module__c> ModuleList = new List<ASI_CRM_Module__c>();
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='Std. Btl.',ASI_CRM_Volume_Base__c='By Sub-Brand',ASI_CRM_Line_Type__c='BRSF',ASI_CRM_Methodology__c=MethodologyList[0].Id,ASI_CRM_Group_Contract__c=true));
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='Std. Btl.',ASI_CRM_Volume_Base__c='By Sub-Brand',ASI_CRM_Line_Type__c='PSF',ASI_CRM_Methodology__c=MethodologyList[1].Id,ASI_CRM_Group_Contract__c=true));
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='CR12 Extra Eqv.',ASI_CRM_Volume_Base__c='By Grade',ASI_CRM_Line_Type__c='PSF',ASI_CRM_Methodology__c=MethodologyList[1].Id,ASI_CRM_Group_Contract__c=true));
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='CR12 Extra Eqv.',ASI_CRM_Volume_Base__c='By Category',ASI_CRM_Line_Type__c='PSF',ASI_CRM_Methodology__c=MethodologyList[1].Id,ASI_CRM_Group_Contract__c=true));
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='CR12 Extra Eqv.',ASI_CRM_Volume_Base__c='By Total',ASI_CRM_Line_Type__c='PSF',ASI_CRM_Methodology__c=MethodologyList[1].Id,ASI_CRM_Group_Contract__c=true));
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='CR12 Extra Eqv.',ASI_CRM_Volume_Base__c='By Sub-Brand',ASI_CRM_Line_Type__c='Variable Event Cost',ASI_CRM_Methodology__c=MethodologyList[2].Id,ASI_CRM_Group_Contract__c=true));
        
        insert ModuleList;
        
        
        test.startTest();
        
          
        
        
        
        ASI_CRM_CN_EditHeavyContractDetailCtrl con2 = new ASI_CRM_CN_EditHeavyContractDetailCtrl(new ApexPages.Standardcontroller(Contract));
        
        
        
        folder f=[select id from folder where Type='Document' limit 1 ];
        
        
        
        Document document = new Document();
        document.Body = Blob.valueOf('Some Text');
        document.ContentType = 'application/xml';
        document.DeveloperName = 'ASI_CRM_CN_Heavy_Test_document';
        document.IsPublic = true;
        document.Name = 'My Document';
        document.FolderId =f.Id;// [select id from folder limit 1].id;
        insert document;
        
        
        
        PageReference EnterPage = Page.ASI_CRM_CN_ViewHeavyContractPage;
        
        Map<String, String> pageParams = EnterPage.getParameters();
        
        pageParams.put('id', Contract.id);
        ApexPages.StandardController sc = new ApexPages.standardController(new ASI_TH_CRM_Contract__c());
        
        // ASI_CRM_CN_ViewHeavyContractCtrl con9 = new ASI_CRM_CN_ViewHeavyContractCtrl(new ApexPages.Standardcontroller(Contract));
        // con9.GoToContractGenerationPage();
        
        // con9.SetToDraft();
        
        test.stopTest(); 
    }

    static testMethod void EditHeavyContractDetailCtrlTest3() {
        //Test Class for ASI_CRM_CN_EditHeavyContractDetailCtrl
        List<ASI_CRM_CN_Channel_Group__c> channelGroupList = new List<ASI_CRM_CN_Channel_Group__c>();

        ASI_CRM_CN_Channel_Group__c channelGroup1 = new ASI_CRM_CN_Channel_Group__c(
                Name = 'OFF MOT',
                ASI_CRM_Channel_Group_Chi_Name__c = 'OFF MOT',
                ASI_CRM_Channel_Group_Eng_Name__c = 'OFF MOT',
                ASI_CRM_Channel_Group_Code__c = 'CN_WS Channel',
                ASI_CRM_External_ID__c = 'CN_OFF MOT',
                ASI_CRM_Sequence__c = 8
        );
        channelGroupList.add(channelGroup1);

        ASI_CRM_CN_Channel_Group__c channelGroup2 = new ASI_CRM_CN_Channel_Group__c(
                Name = 'KTV',
                ASI_CRM_Channel_Group_Chi_Name__c = 'KTV',
                ASI_CRM_Channel_Group_Eng_Name__c = 'KTV',
                ASI_CRM_Channel_Group_Code__c = 'CN_New_KTV_Group',
                ASI_CRM_External_ID__c = 'CN_New_KTV_Group',
                ASI_CRM_Sequence__c = 3
        );
        channelGroupList.add(channelGroup2);

        insert channelGroupList;

        List<ASI_CRM_CN_Channel__c> channelList = new List<ASI_CRM_CN_Channel__c>();

        ASI_CRM_CN_Channel__c channel1 = new ASI_CRM_CN_Channel__c(
                ASI_CRM_For_Outlet__c = true,
                Name='Restaurant',
                RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CN_Channel__cASI_CRM_CN_New_Channel'),
                ASI_CRM_CN_On_Off__c='OFF',
                ASI_CRM_CN_Channel_Group__c= channelGroup1.Id
        );
        channelList.add(channel1);

        ASI_CRM_CN_Channel__c channel2 = new ASI_CRM_CN_Channel__c(
                Name='KTV',
                ASI_CRM_BC_Rate__c=98,
                ASI_CRM_CN_On_Off__c='ON',
                ASI_CRM_For_Outlet__c=true,
                RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CN_Channel__cASI_CRM_CN_New_Channel'),
                ASI_CRM_For_Contract__c=TRUE,
                ASI_CRM_CN_Channel_Group__c=channelGroup2.Id
        );
        channelList.add(channel2);

        insert channelList;
        ASI_CRM_Region__c region = new ASI_CRM_Region__c (Name='Central Region',recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Region__cASI_CRM_CN_Region'));
        insert region;
        
        ASI_CRM_Division__c division = new ASI_CRM_Division__c(Name='TEST', ASI_CRM_Region__c=region.Id);
        insert division;
        
        ASI_CRM_CN_Area__c area = new ASI_CRM_CN_Area__c(Name='TEST', ASI_CRM_English_Name__c='TEST', ASI_CRM_Division__c=division.Id);
        insert area;
        
        ASI_CRM_City__c city = new ASI_CRM_City__c(Name='TEST', ASI_CRM_CN_Area__c=area.Id,ASI_CRM_CN_City_Tier__c='2');
        insert city;


        // 20190808 Wilson Chow start
        /*
        ASI_CRM_CN_Channel__c channel = new ASI_CRM_CN_Channel__c(Name='KTV',ASI_CRM_BC_Rate__c=98,ASI_CRM_CN_On_Off__c='ON',ASI_CRM_For_Outlet__c=true,RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CN_Channel__cASI_CRM_CN_New_Channel'),ASI_CRM_For_Contract__c=TRUE, ASI_CRM_CN_Channel_Group__c=channelGroup.Id);
        insert channel;
        */
        List<ASI_CRM_CN_Channel__c> channel = [SELECT Id FROM ASI_CRM_CN_Channel__c];
        // 20190808 Wilson Chow end
        
        
        ASI_CRM_SegmentationCriteria__c SegmentationCriteria= new ASI_CRM_SegmentationCriteria__c (Name='Test',ASI_CRM_Channel__c=channel[1].Id, ASI_CRM_Outlet_New_Image__c='Iconic',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_SegmentationCriteria__cASI_CRM_CN_Segmentation_Criteria'));
        INSERT SegmentationCriteria;

        Id rtWS = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_CN_WS');
        Id rtOutlet = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN');
        
        list<ASI_CRM_AccountsAdditionalField__c> Customers = new list<ASI_CRM_AccountsAdditionalField__c>();
        Customers.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Commercial_Team__c = 'Premium',ASI_CRM_CN_New_Image__c='Iconic',RecordTypeId=rtWS,Name='TEST', ASI_CRM_CN_Image__c='Iconic',ASI_CRM_CN_CCity__c=city.Id,ASI_CRM_CN_NewChannel__c=channel[0].Id));
        Customers.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Commercial_Team__c = 'Premium',ASI_CRM_CN_New_Image__c='Iconic',RecordTypeId=rtOutlet,Name='TEST', ASI_CRM_CN_Image__c='Iconic',ASI_CRM_CN_CCity__c=city.Id,ASI_CRM_CN_NewChannel__c=channel[1].Id));
        insert Customers;
        
        //Covered_Outlet
        list<ASI_CRM_AccountsAdditionalField__c> ChildCustomers = new list<ASI_CRM_AccountsAdditionalField__c>();
        ChildCustomers.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Parent_Outlet__c=Customers[1].Id,ASI_CRM_CN_Commercial_Team__c = 'Premium',RecordTypeId=rtOutlet,Name='TEST', ASI_CRM_CN_Image__c='Iconic',ASI_CRM_CN_CCity__c=city.Id,ASI_CRM_CN_NewChannel__c=channel[1].Id));
        insert ChildCustomers;
        

        
        User currentUser = [SELECT id, name, Managerid, ASI_CRM_CN_Prefix__c,LanguageLocaleKey FROM USER WHERE id =:UserInfo.getUserId()];
        currentUser.LanguageLocaleKey='zh_CN';
        update currentUser;
        
        list<ASI_HK_CRM_Running_Number__c> rns = new list<ASI_HK_CRM_Running_Number__c>();
        rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_TH_CRM_Contract__c', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_TH_CRM_PaymentRequest__c', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        if(!String.isBlank(currentUser.ASI_CRM_CN_Prefix__c))
            rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_'+currentUser.ASI_CRM_CN_Prefix__c, recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        else{
            rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_NULL', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
            rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        }
        insert rns;
        
        
        
        
        
        List<ASI_HK_CRM_Product_Category__c> ProductCategoryList= new List<ASI_HK_CRM_Product_Category__c> ();
        ProductCategoryList.add(new ASI_HK_CRM_Product_Category__c(Name='Category1',ASI_CRM_CN_Chinese_Name__c='Category',ASI_HK_CRM_English_Name__c='Category',ASI_HK_CRM_Sequence__c=1,recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Product_Category__cASI_CRM_CN_Product_Category')));
        ProductCategoryList.add(new ASI_HK_CRM_Product_Category__c(Name='Category2',ASI_CRM_CN_Chinese_Name__c='Category2',ASI_HK_CRM_English_Name__c='Category',ASI_HK_CRM_Sequence__c=2,recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Product_Category__cASI_CRM_CN_Product_Category')));
        ProductCategoryList.add(new ASI_HK_CRM_Product_Category__c(Name='Category3',ASI_CRM_CN_Chinese_Name__c='Category1',ASI_HK_CRM_English_Name__c='Category',ASI_HK_CRM_Sequence__c=3,recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Product_Category__cASI_CRM_CN_Product_Category')));
        
        insert ProductCategoryList;
        
        
        
        
        List<ASI_TH_CRM_Sub_category__c> SubCategoryList= new List<ASI_TH_CRM_Sub_category__c>();
        SubCategoryList.add(new ASI_TH_CRM_Sub_category__c(Name='SubCategory1',ASI_CRM_CN_Product_Category__c=ProductCategoryList[0].Id,recordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_Sub_category__cASI_CRM_CN_Sub_Category')));
        SubCategoryList.add(new ASI_TH_CRM_Sub_category__c(Name='SubCategory2',ASI_CRM_CN_Product_Category__c=ProductCategoryList[1].Id,recordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_Sub_category__cASI_CRM_CN_Sub_Category')));
        SubCategoryList.add(new ASI_TH_CRM_Sub_category__c(Name='SubCategory3',ASI_CRM_CN_Product_Category__c=ProductCategoryList[2].Id,recordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_Sub_category__cASI_CRM_CN_Sub_Category')));
        
        insert SubCategoryList;
        
        
        List<ASI_MFM_Brand__c> BrandList = new List<ASI_MFM_Brand__c> ();
        BrandList.add(new ASI_MFM_Brand__c (Name='Test1',ASI_CRM_CN_Competitor__c=false,ASI_TH_CRM_Sub_category__c=SubCategoryList[0].Id,recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Brand__cASI_FOC_CN_Brand')));
        BrandList.add(new ASI_MFM_Brand__c (Name='Test2',ASI_CRM_CN_Competitor__c=false,ASI_TH_CRM_Sub_category__c=SubCategoryList[1].Id,recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Brand__cASI_FOC_CN_Brand')));
        BrandList.add(new ASI_MFM_Brand__c (Name='Test3',ASI_CRM_CN_Competitor__c=false,ASI_TH_CRM_Sub_category__c=SubCategoryList[2].Id,recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Brand__cASI_FOC_CN_Brand')));
        
        Insert BrandList;
        
        
        
        
        //Sub Brand Grade
        list<ASI_CRM_Sub_Brand_Grade__c> grades = new list<ASI_CRM_Sub_Brand_Grade__c>();
        grades.add(new ASI_CRM_Sub_Brand_Grade__c (Name='Premium',ASI_CRM_Chinese_Name__c='Test1',ASI_CRM_Chinese_Description__c='1. Standard + Premium 标准档 + 高档',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_Sub_Brand_Grade__cASI_CRM_CN_Sub_brand_Grade')));
        grades.add(new ASI_CRM_Sub_Brand_Grade__c (Name='TEST2',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_Sub_Brand_Grade__cASI_CRM_CN_Sub_brand_Grade')));
        grades.add(new ASI_CRM_Sub_Brand_Grade__c (Name='TEST3',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_Sub_Brand_Grade__cASI_CRM_CN_Sub_brand_Grade')));
        insert grades;
        
        
        list<ASI_MFM_Sub_brand__c> subBrands = new list<ASI_MFM_Sub_brand__c>();
        for(ASI_CRM_Sub_Brand_Grade__c grade :grades) {
            subBrands.add(new ASI_MFM_Sub_brand__c (Name='TEST1',ASI_MFM_Active_for_CRM__c=true,ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,RecordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand'),
                                                    ASI_CRM_CN_Sub_brand_Grade__c=grade.Id,ASI_MFM_Brand__c=BrandList[0].Id));
            subBrands.add(new ASI_MFM_Sub_brand__c (Name='TEST2',ASI_MFM_Active_for_CRM__c=true,RecordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand'),
                                                    ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,
                                                    ASI_CRM_CN_Sub_brand_Grade__c=grade.Id,ASI_MFM_Brand__c=BrandList[1].Id));
            subBrands.add(new ASI_MFM_Sub_brand__c ( Name='TEST3',ASI_MFM_Active_for_CRM__c=true,RecordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand'),
                                                    ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,
                                                    ASI_CRM_CN_Sub_brand_Grade__c=grade.Id,ASI_MFM_Brand__c=BrandList[2].Id));
            subBrands.add(new ASI_MFM_Sub_brand__c ( Name='999',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand'),
                                                    ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,ASI_MFM_Sub_brand_Code__c = '999' ,ASI_MFM_Active_for_CRM__c = true ,
                                                    ASI_CRM_CN_Sub_brand_Grade__c=grade.Id,ASI_MFM_Brand__c=BrandList[0].Id));
        }
        
        insert subBrands;
        
        
        List<ASI_CRM_Sub_Brand_Assignment__c> SubBrandAssignmentList= new List<ASI_CRM_Sub_Brand_Assignment__c>();
        for(ASI_MFM_Sub_brand__c SubBrandItem:subBrands){
            SubBrandAssignmentList.add(new ASI_CRM_Sub_Brand_Assignment__c(ASI_CRM_Sub_Brand__c=SubBrandItem.Id,ASI_CRM_Segmentation_Criteria__c=SegmentationCriteria.Id));
        }
        
        insert SubBrandAssignmentList;


        List<ASI_MFM_A_C_Code__c> ACCodeList = new  List<ASI_MFM_A_C_Code__c>();
        ACCodeList.add(new ASI_MFM_A_C_Code__c( Name='0000000000000', ASI_MFM_A_C_Code__c='000010000',ASI_MFM_A_C_Description__c='ASI_CRM_CN_Variable_Cost_Contract',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_CN_A_C_Code') ));
        ACCodeList.add(new ASI_MFM_A_C_Code__c( Name='5275.010000 PRC - Bottle Return Service', ASI_MFM_A_C_Code__c='5275.010000',ASI_MFM_A_C_Description__c='Bottle Return Service',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_CN_A_C_Code') ));
        ACCodeList.add(new ASI_MFM_A_C_Code__c( Name='5275.020000 Promotion Service Fee', ASI_MFM_A_C_Code__c='5275.020000',ASI_MFM_A_C_Description__c='Promotion Service Fee',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_CN_A_C_Code') ));
        ACCodeList.add(new ASI_MFM_A_C_Code__c( Name='5275.030000 PRC - Variable Event Cost', ASI_MFM_A_C_Code__c='5275.030000',ASI_MFM_A_C_Description__c='Variable Event Cost',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_CN_A_C_Code') ));
        
        insert ACCodeList;
        
        
        List<ASI_CRM_Contract_Cost_Setting__c> ContractCostSettingList= new List<ASI_CRM_Contract_Cost_Setting__c>();
        
        ContractCostSettingList.add(new ASI_CRM_Contract_Cost_Setting__c(ASI_CRM_CN_Activity_Code__c=ACCodeList[0].Id,ASI_CRM_CN_Promotion_Type__c='Heavy Contract ON',
                                                                         ASI_CRM_CN_Fixed_Cost_Contract__c=true,ASI_CRM_CN_Variable_Cost_Contract__c=true));
        
        ContractCostSettingList.add(new ASI_CRM_Contract_Cost_Setting__c(ASI_CRM_CN_Activity_Code__c=ACCodeList[0].Id,ASI_CRM_CN_Promotion_Type__c='Heavy Contract ON',ASI_CRM_CN_Variable_Cost_Contract__c=true,
                                                                         ASI_CRM_CN_Fixed_Cost_Contract__c=false,ASI_CRM_CN_BRSF_Activity_Code_Default__c=true));
        
        ContractCostSettingList.add(new ASI_CRM_Contract_Cost_Setting__c(ASI_CRM_CN_Activity_Code__c=ACCodeList[0].Id,ASI_CRM_CN_Promotion_Type__c='Heavy Contract ON',ASI_CRM_CN_Variable_Cost_Contract__c=true,
                                                                         ASI_CRM_CN_Fixed_Cost_Contract__c=false,ASI_CRM_PSF_Activity_Code_Default__c=true));
        
        ContractCostSettingList.add(new ASI_CRM_Contract_Cost_Setting__c(ASI_CRM_CN_Activity_Code__c=ACCodeList[0].Id,ASI_CRM_CN_Promotion_Type__c='Heavy Contract ON',ASI_CRM_CN_Variable_Cost_Contract__c=true,
                                                                         ASI_CRM_CN_Fixed_Cost_Contract__c=false,ASI_CRM_VEC_Activity_Code_Defaul__c=true));
        
        insert ContractCostSettingList;
        
        ASI_CRM_SpecialPromotionTypeSetting__c oldspts = new ASI_CRM_SpecialPromotionTypeSetting__c( ASI_CRM_Promotion_Type__c = 'a');
        insert oldspts;
        
        ASI_CRM_SpecialPromotionTypeSetting__c newspts = new ASI_CRM_SpecialPromotionTypeSetting__c(ASI_CRM_Promotion_Type__c = 'Heavy Contract On',recordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_SpecialPromotionTypeSetting__cASI_CRM_CN_SpecialPromotionTypeSetting'));
        insert newspts;
        
        ASI_CRM_Special_Promotion_Type_Mapping__c sptm = new ASI_CRM_Special_Promotion_Type_Mapping__c(ASI_CRM_Mapping_of_New_Promotion_Type__c = newspts.Id,ASI_CRM_Mapping_of_Old_Promotion_Type__c = oldspts.Id,recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Special_Promotion_Type_Mapping__cASI_CRM_CN_Special_Promotion_Type_Mapping'));
        insert sptm;
        
        
        
        Date today = Date.newInstance(2020, 5, 25);
        Date PO_Start_Date = date.newinstance(today.year(), today.month(), 1);
        Date PO_End_Date = PO_Start_Date.addMonths(1)-1;
        
        
        ASI_TH_CRM_Contract__c Contract = new ASI_TH_CRM_Contract__c(recordtypeid = Global_RecordTypeCache.getRTID('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract'),
                                                                     ASI_CRM_CN_Status__c = 'Final',
                                                                     ASI_CRM_CN_PO_Start_Date__c = PO_Start_Date,
                                                                     ASI_CRM_CN_PO_End_Date__c =PO_End_Date,
                                                                     ASI_CRM_CN_PO_Version__c = '0.0',ASI_TH_CRM_Promotion_Type__c='Heavy Contract On',
                                                                     Name = 'Contract1',
                                                                     ASI_CRM_CN_Outlet_WS__c=Customers[1].Id,ASI_CRM_Volume_Option__c = 'Normal');
        insert Contract;
        
        
        List<ASI_CRM_Methodology__c> MethodologyList= new List<ASI_CRM_Methodology__c> ();
        MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test1',ASI_CRM_Methodology_Code__c='01',ASI_CRM_Default__c=true,ASI_CRM_Chinese_Name__c='123',ASI_CRM_Type__c='BRSF',recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Methodology__cASI_CRM_CN_Methodology')));
        MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test2',ASI_CRM_Methodology_Code__c='01',ASI_CRM_Default__c=true,ASI_CRM_Chinese_Name__c='Test 123',ASI_CRM_Type__c='PSF',recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Methodology__cASI_CRM_CN_Methodology')));
        MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test3',ASI_CRM_Methodology_Code__c='01',ASI_CRM_Default__c=true,ASI_CRM_Chinese_Name__c='Test 123',ASI_CRM_Type__c='Variable Event Cost',recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Methodology__cASI_CRM_CN_Methodology')));
        
        
        MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test1',ASI_CRM_Methodology_Code__c='01',ASI_CRM_Chinese_Name__c='123',ASI_CRM_Type__c='BRSF',recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Methodology__cASI_CRM_CN_Methodology')));
        MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test2',ASI_CRM_Methodology_Code__c='01',ASI_CRM_Chinese_Name__c='123',ASI_CRM_Type__c='PSF',recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Methodology__cASI_CRM_CN_Methodology')));
        MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test3',ASI_CRM_Methodology_Code__c='01',ASI_CRM_Chinese_Name__c='123',ASI_CRM_Type__c='Variable Event Cost',recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Methodology__cASI_CRM_CN_Methodology')));
        insert MethodologyList;
        
        
        //Methodology Assignment
        List<ASI_CRM_Methodology_Assignment__c> MethodologyAssignmentList = new List<ASI_CRM_Methodology_Assignment__c>();
        MethodologyAssignmentList.add(new ASI_CRM_Methodology_Assignment__c(ASI_CRM_Methodology__c=MethodologyList[0].Id,ASI_CRM_Key_Principle__c=true,ASI_CRM_Methodology_Commercial_Team__c='Premium',ASI_CRM_Region__c=region.Id));
        MethodologyAssignmentList.add(new ASI_CRM_Methodology_Assignment__c(ASI_CRM_Methodology__c=MethodologyList[1].Id,ASI_CRM_Key_Principle__c=true,ASI_CRM_Methodology_Commercial_Team__c='Premium',ASI_CRM_Region__c=region.Id));
        MethodologyAssignmentList.add(new ASI_CRM_Methodology_Assignment__c(ASI_CRM_Methodology__c=MethodologyList[2].Id,ASI_CRM_Key_Principle__c=true,ASI_CRM_Methodology_Commercial_Team__c='Premium',ASI_CRM_Region__c=region.Id));
        MethodologyAssignmentList.add(new ASI_CRM_Methodology_Assignment__c(ASI_CRM_Methodology__c=MethodologyList[3].Id,ASI_CRM_Key_Principle__c=true,ASI_CRM_Methodology_Commercial_Team__c='Premium',ASI_CRM_Region__c=region.Id));
        MethodologyAssignmentList.add(new ASI_CRM_Methodology_Assignment__c(ASI_CRM_Methodology__c=MethodologyList[4].Id,ASI_CRM_Key_Principle__c=true,ASI_CRM_Methodology_Commercial_Team__c='Premium',ASI_CRM_Region__c=region.Id));
        MethodologyAssignmentList.add(new ASI_CRM_Methodology_Assignment__c(ASI_CRM_Methodology__c=MethodologyList[5].Id,ASI_CRM_Key_Principle__c=true,ASI_CRM_Methodology_Commercial_Team__c='Premium',ASI_CRM_Region__c=region.Id));
        
        insert MethodologyAssignmentList ;
        
        
        
        
        List<ASI_CRM_Module__c> ModuleList = new List<ASI_CRM_Module__c>();
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='Std. Btl.',ASI_CRM_Volume_Base__c='By Sub-Brand',ASI_CRM_Line_Type__c='BRSF',ASI_CRM_Methodology__c=MethodologyList[0].Id));
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='Std. Btl.',ASI_CRM_Volume_Base__c='By Sub-Brand',ASI_CRM_Line_Type__c='PSF',ASI_CRM_Methodology__c=MethodologyList[1].Id));
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='CR12 Extra Eqv.',ASI_CRM_Volume_Base__c='By Grade',ASI_CRM_Line_Type__c='PSF',ASI_CRM_Methodology__c=MethodologyList[1].Id));
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='CR12 Extra Eqv.',ASI_CRM_Volume_Base__c='By Category',ASI_CRM_Line_Type__c='PSF',ASI_CRM_Methodology__c=MethodologyList[1].Id));
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='CR12 Extra Eqv.',ASI_CRM_Volume_Base__c='By Total',ASI_CRM_Line_Type__c='PSF',ASI_CRM_Methodology__c=MethodologyList[1].Id));
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='CR12 Extra Eqv.',ASI_CRM_Volume_Base__c='By Sub-Brand',ASI_CRM_Line_Type__c='Variable Event Cost',ASI_CRM_Methodology__c=MethodologyList[2].Id));
        
        insert ModuleList;
        
        
        
        ASI_CRM_Contract_Cost__c contractCost = new ASI_CRM_Contract_Cost__c(ASI_CRM_CN_Contract__c = Contract.id,
                                                                             ASI_CRM_CN_Estimate_Amount__c = 100000,
                                                                             ASI_CRM_CN_Cost_Type__c = 'Fixed',
                                                                             ASI_CRM_CN_Other_Cost_Payment_Request__c = true,
                                                                             recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_Contract_Cost__cASI_CRM_CN_Contract_Cost') );
        insert contractCost;
        
        list<ASI_CRM_CN_Contract_BRSF_Line_Item__c> ContractLineList = new list<ASI_CRM_CN_Contract_BRSF_Line_Item__c>();
        
        for(ASI_MFM_Sub_brand__c subBrand :subBrands) {
            ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract.Id,
                                                                           ASI_CRM_CN_Est_Monthly_Qty__c=1,ASI_CRM_Module__c=ModuleList[0].Id,
                                                                           ASI_CRM_CN_Contract_Monthly_Qty__c=1,
                                                                           ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,
                                                                           ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,ASI_CRM_Type__c='BRSF',
                                                                           ASI_CRM_CN_Sub_Brand__c=subBrand.Id,
                                                                           recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF')));
        }
        
         for(ASI_MFM_Sub_brand__c subBrand :subBrands) {
            ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract.Id,
                                                                           ASI_CRM_CN_Est_Monthly_Qty__c=1,ASI_CRM_Module__c=ModuleList[1].Id,
                                                                           ASI_CRM_CN_Contract_Monthly_Qty__c=1,ASI_CRM_Volume_Base__c='By Sub-Brand',
                                                                           ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,
                                                                           ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,ASI_CRM_Type__c='PSF',
                                                                           ASI_CRM_CN_Sub_Brand__c=subBrand.Id,
                                                                           recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF')));
        }

        ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract.Id,ASI_CRM_Type__c='PSF',ASI_CRM_Volume_Base__c='By Grade',
                                                                       ASI_CRM_CN_Est_Monthly_Qty__c=4,ASI_CRM_Module__c=ModuleList[2].Id,
                                                                       ASI_CRM_CN_Contract_Monthly_Qty__c=4,ASI_CRM_Sub_Brand_Grade__c=grades[0].Id,
                                                                       ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,
                                                                       ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,
                                                                       ASI_CRM_CN_Sub_Brand__c=null,
                                                                       recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF') ));
        ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract.Id,ASI_CRM_Type__c='PSF',ASI_CRM_Volume_Base__c='By Category',
                                                                       ASI_CRM_CN_Est_Monthly_Qty__c=4,ASI_CRM_Module__c=ModuleList[3].Id,
                                                                       ASI_CRM_CN_Contract_Monthly_Qty__c=4,ASI_CRM_Product_Category__c=ProductCategoryList[0].Id,
                                                                       ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,
                                                                       ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,
                                                                       ASI_CRM_CN_Sub_Brand__c=null,
                                                                       recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF') ));
        ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract.Id,ASI_CRM_Type__c='PSF',ASI_CRM_Volume_Base__c='By Total',
                                                                       ASI_CRM_CN_Est_Monthly_Qty__c=4,ASI_CRM_Module__c=ModuleList[4].Id,
                                                                       ASI_CRM_CN_Contract_Monthly_Qty__c=4,
                                                                       ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,
                                                                       ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,
                                                                       ASI_CRM_CN_Sub_Brand__c=null,
                                                                       recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF') ));
         for(ASI_MFM_Sub_brand__c subBrand :subBrands) {
            ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract.Id,
                                                                           ASI_CRM_CN_Est_Monthly_Qty__c=1,ASI_CRM_Module__c=ModuleList[5].Id,
                                                                           ASI_CRM_CN_Contract_Monthly_Qty__c=1,ASI_CRM_Volume_Base__c='By Sub-Brand',
                                                                           ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,
                                                                           ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,ASI_CRM_Type__c='Variable Event Cost',
                                                                           ASI_CRM_CN_Sub_Brand__c=subBrand.Id,
                                                                           recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF')));
        }
        
        insert ContractLineList;
        
        

        //No BRSF Line Case
        test.startTest();
        
        ASI_CRM_CN_EditHeavyContractDetailCtrl con2 = new ASI_CRM_CN_EditHeavyContractDetailCtrl(new ApexPages.Standardcontroller(Contract));
        
        
        
        
        
        test.stopTest(); 
    }
    
    static testMethod void EditHeavyContractDetailCtrlTest4() {
        //Test Class for ASI_CRM_CN_EditHeavyContractDetailCtrl
        //
        List<ASI_CRM_CN_Channel_Group__c> channelGroupList = new List<ASI_CRM_CN_Channel_Group__c>();

        ASI_CRM_CN_Channel_Group__c channelGroup1 = new ASI_CRM_CN_Channel_Group__c(
                Name = 'OFF MOT',
                ASI_CRM_Channel_Group_Chi_Name__c = 'OFF MOT',
                ASI_CRM_Channel_Group_Eng_Name__c = 'OFF MOT',
                ASI_CRM_Channel_Group_Code__c = 'CN_WS Channel',
                ASI_CRM_External_ID__c = 'CN_OFF MOT',
                ASI_CRM_Sequence__c = 8
        );
        channelGroupList.add(channelGroup1);

        ASI_CRM_CN_Channel_Group__c channelGroup2 = new ASI_CRM_CN_Channel_Group__c(
                Name = 'KTV',
                ASI_CRM_Channel_Group_Chi_Name__c = 'KTV',
                ASI_CRM_Channel_Group_Eng_Name__c = 'KTV',
                ASI_CRM_Channel_Group_Code__c = 'CN_New_KTV_Group',
                ASI_CRM_External_ID__c = 'CN_New_KTV_Group',
                ASI_CRM_Sequence__c = 3
        );
        channelGroupList.add(channelGroup2);

        insert channelGroupList;

        List<ASI_CRM_CN_Channel__c> channelList = new List<ASI_CRM_CN_Channel__c>();

        ASI_CRM_CN_Channel__c channel1 = new ASI_CRM_CN_Channel__c(
                ASI_CRM_For_Outlet__c = true,
                Name='Restaurant',
                RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CN_Channel__cASI_CRM_CN_New_Channel'),
                ASI_CRM_CN_On_Off__c='OFF',
                ASI_CRM_CN_Channel_Group__c= channelGroup1.Id
        );
        channelList.add(channel1);

        ASI_CRM_CN_Channel__c channel2 = new ASI_CRM_CN_Channel__c(
                Name='KTV',
                ASI_CRM_BC_Rate__c=98,
                ASI_CRM_CN_On_Off__c='ON',
                ASI_CRM_For_Outlet__c=true,
                RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CN_Channel__cASI_CRM_CN_New_Channel'),
                ASI_CRM_For_Contract__c=TRUE,
                ASI_CRM_CN_Channel_Group__c=channelGroup2.Id
        );
        channelList.add(channel2);

        insert channelList;
        ASI_CRM_Region__c region = new ASI_CRM_Region__c (Name='Central Region',recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Region__cASI_CRM_CN_Region'));
        insert region;
        
        ASI_CRM_Division__c division = new ASI_CRM_Division__c(Name='TEST', ASI_CRM_Region__c=region.Id);
        insert division;
        
        ASI_CRM_CN_Area__c area = new ASI_CRM_CN_Area__c(Name='TEST', ASI_CRM_English_Name__c='TEST', ASI_CRM_Division__c=division.Id);
        insert area;
        
        ASI_CRM_City__c city = new ASI_CRM_City__c(Name='TEST', ASI_CRM_CN_Area__c=area.Id,ASI_CRM_CN_City_Tier__c='2');
        insert city;

        // 20190808 Wilson Chow start
        /*
        ASI_CRM_CN_Channel__c channel = new ASI_CRM_CN_Channel__c(Name='KTV',ASI_CRM_BC_Rate__c=98,ASI_CRM_CN_On_Off__c='ON',ASI_CRM_For_Outlet__c=true,RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CN_Channel__cASI_CRM_CN_New_Channel'),ASI_CRM_For_Contract__c=TRUE, ASI_CRM_CN_Channel_Group__c=channelGroup.Id);
        insert channel;
        */
        List<ASI_CRM_CN_Channel__c> channel = [SELECT Id FROM ASI_CRM_CN_Channel__c];
        // 20190808 Wilson Chow end
        
        
        ASI_CRM_SegmentationCriteria__c SegmentationCriteria= new ASI_CRM_SegmentationCriteria__c (Name='Test',ASI_CRM_Channel__c=channel[1].Id, ASI_CRM_Outlet_New_Image__c='Iconic',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_SegmentationCriteria__cASI_CRM_CN_Segmentation_Criteria'));
        INSERT SegmentationCriteria;

        Id rtWS = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_CN_WS');
        Id rtOutlet = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN');
        
        list<ASI_CRM_AccountsAdditionalField__c> Customers = new list<ASI_CRM_AccountsAdditionalField__c>();
        Customers.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Commercial_Team__c = 'Premium',ASI_CRM_CN_New_Image__c='Iconic',RecordTypeId=rtWS,Name='TEST', ASI_CRM_CN_Image__c='Iconic',ASI_CRM_CN_CCity__c=city.Id,ASI_CRM_CN_NewChannel__c=channel[0].Id));
        Customers.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Commercial_Team__c = 'Premium',ASI_CRM_CN_New_Image__c='Iconic',RecordTypeId=rtOutlet,Name='TEST', ASI_CRM_CN_Image__c='Iconic',ASI_CRM_CN_CCity__c=city.Id,ASI_CRM_CN_NewChannel__c=channel[1].Id));
        insert Customers;
        
        //Covered_Outlet
        list<ASI_CRM_AccountsAdditionalField__c> ChildCustomers = new list<ASI_CRM_AccountsAdditionalField__c>();
        ChildCustomers.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Parent_Outlet__c=Customers[1].Id,ASI_CRM_CN_Commercial_Team__c = 'Premium',RecordTypeId=rtOutlet,Name='TEST', ASI_CRM_CN_Image__c='Iconic',ASI_CRM_CN_CCity__c=city.Id,ASI_CRM_CN_NewChannel__c=channel[1].Id));
        insert ChildCustomers;
        

        
        User currentUser = [SELECT id, name, Managerid, BypassTriggers__c, ASI_CRM_CN_Prefix__c,LanguageLocaleKey FROM USER WHERE id =:UserInfo.getUserId()];
        currentUser.LanguageLocaleKey='zh_CN';
        currentUser.BypassTriggers__c = currentUser.BypassTriggers__c==null? 'CN_POEndDate_ContractValidation;': currentUser.BypassTriggers__c+' CN_POEndDate_ContractValidation;';
        update currentUser;
        
        list<ASI_HK_CRM_Running_Number__c> rns = new list<ASI_HK_CRM_Running_Number__c>();
        rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_TH_CRM_Contract__c', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_TH_CRM_PaymentRequest__c', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        if(!String.isBlank(currentUser.ASI_CRM_CN_Prefix__c))
            rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_'+currentUser.ASI_CRM_CN_Prefix__c, recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        else{
            rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_NULL', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
            rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        }
        insert rns;
        
        
        
        
        
        List<ASI_HK_CRM_Product_Category__c> ProductCategoryList= new List<ASI_HK_CRM_Product_Category__c> ();
        ProductCategoryList.add(new ASI_HK_CRM_Product_Category__c(Name='Category1',ASI_CRM_CN_Chinese_Name__c='Category',ASI_HK_CRM_English_Name__c='Category',ASI_HK_CRM_Sequence__c=1,recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Product_Category__cASI_CRM_CN_Product_Category')));
        ProductCategoryList.add(new ASI_HK_CRM_Product_Category__c(Name='Category2',ASI_CRM_CN_Chinese_Name__c='Category2',ASI_HK_CRM_English_Name__c='Category',ASI_HK_CRM_Sequence__c=2,recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Product_Category__cASI_CRM_CN_Product_Category')));
        ProductCategoryList.add(new ASI_HK_CRM_Product_Category__c(Name='Category3',ASI_CRM_CN_Chinese_Name__c='Category1',ASI_HK_CRM_English_Name__c='Category',ASI_HK_CRM_Sequence__c=3,recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Product_Category__cASI_CRM_CN_Product_Category')));
        
        insert ProductCategoryList;
        
        
        
        
        List<ASI_TH_CRM_Sub_category__c> SubCategoryList= new List<ASI_TH_CRM_Sub_category__c>();
        SubCategoryList.add(new ASI_TH_CRM_Sub_category__c(Name='SubCategory1',ASI_CRM_CN_Product_Category__c=ProductCategoryList[0].Id,recordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_Sub_category__cASI_CRM_CN_Sub_Category')));
        SubCategoryList.add(new ASI_TH_CRM_Sub_category__c(Name='SubCategory2',ASI_CRM_CN_Product_Category__c=ProductCategoryList[1].Id,recordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_Sub_category__cASI_CRM_CN_Sub_Category')));
        SubCategoryList.add(new ASI_TH_CRM_Sub_category__c(Name='SubCategory3',ASI_CRM_CN_Product_Category__c=ProductCategoryList[2].Id,recordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_Sub_category__cASI_CRM_CN_Sub_Category')));
        
        insert SubCategoryList;
        
        
        List<ASI_MFM_Brand__c> BrandList = new List<ASI_MFM_Brand__c> ();
        BrandList.add(new ASI_MFM_Brand__c (Name='Test1',ASI_CRM_CN_Competitor__c=false,ASI_TH_CRM_Sub_category__c=SubCategoryList[0].Id,recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Brand__cASI_FOC_CN_Brand')));
        BrandList.add(new ASI_MFM_Brand__c (Name='Test2',ASI_CRM_CN_Competitor__c=false,ASI_TH_CRM_Sub_category__c=SubCategoryList[1].Id,recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Brand__cASI_FOC_CN_Brand')));
        BrandList.add(new ASI_MFM_Brand__c (Name='Test3',ASI_CRM_CN_Competitor__c=false,ASI_TH_CRM_Sub_category__c=SubCategoryList[2].Id,recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Brand__cASI_FOC_CN_Brand')));
        
        Insert BrandList;
        
        
        
        
        //Sub Brand Grade
        list<ASI_CRM_Sub_Brand_Grade__c> grades = new list<ASI_CRM_Sub_Brand_Grade__c>();
        grades.add(new ASI_CRM_Sub_Brand_Grade__c (Name='Premium',ASI_CRM_Chinese_Name__c='Test1',ASI_CRM_Chinese_Description__c='1. Standard + Premium 标准档 + 高档',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_Sub_Brand_Grade__cASI_CRM_CN_Sub_brand_Grade')));
        grades.add(new ASI_CRM_Sub_Brand_Grade__c (Name='TEST2',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_Sub_Brand_Grade__cASI_CRM_CN_Sub_brand_Grade')));
        grades.add(new ASI_CRM_Sub_Brand_Grade__c (Name='TEST3',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_Sub_Brand_Grade__cASI_CRM_CN_Sub_brand_Grade')));
        insert grades;
        
        
        list<ASI_MFM_Sub_brand__c> subBrands = new list<ASI_MFM_Sub_brand__c>();
        for(ASI_CRM_Sub_Brand_Grade__c grade :grades) {
            subBrands.add(new ASI_MFM_Sub_brand__c (Name='TEST1',ASI_MFM_Active_for_CRM__c=true,ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,RecordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand'),
                                                    ASI_CRM_CN_Sub_brand_Grade__c=grade.Id,ASI_MFM_Brand__c=BrandList[0].Id));
            subBrands.add(new ASI_MFM_Sub_brand__c (Name='TEST2',ASI_MFM_Active_for_CRM__c=true,RecordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand'),
                                                    ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,
                                                    ASI_CRM_CN_Sub_brand_Grade__c=grade.Id,ASI_MFM_Brand__c=BrandList[1].Id));
            subBrands.add(new ASI_MFM_Sub_brand__c ( Name='TEST3',ASI_MFM_Active_for_CRM__c=true,RecordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand'),
                                                    ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,
                                                    ASI_CRM_CN_Sub_brand_Grade__c=grade.Id,ASI_MFM_Brand__c=BrandList[2].Id));
            subBrands.add(new ASI_MFM_Sub_brand__c ( Name='999',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand'),
                                                    ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,ASI_MFM_Sub_brand_Code__c = '999' ,ASI_MFM_Active_for_CRM__c = true ,
                                                    ASI_CRM_CN_Sub_brand_Grade__c=grade.Id,ASI_MFM_Brand__c=BrandList[0].Id));
        }
        
        insert subBrands;
        
        
        List<ASI_CRM_Sub_Brand_Assignment__c> SubBrandAssignmentList= new List<ASI_CRM_Sub_Brand_Assignment__c>();
        for(ASI_MFM_Sub_brand__c SubBrandItem:subBrands){
            SubBrandAssignmentList.add(new ASI_CRM_Sub_Brand_Assignment__c(ASI_CRM_Sub_Brand__c=SubBrandItem.Id,ASI_CRM_Segmentation_Criteria__c=SegmentationCriteria.Id));
        }
        
        insert SubBrandAssignmentList;


        List<ASI_MFM_A_C_Code__c> ACCodeList = new  List<ASI_MFM_A_C_Code__c>();
        ACCodeList.add(new ASI_MFM_A_C_Code__c( Name='0000000000000', ASI_MFM_A_C_Code__c='000010000',ASI_MFM_A_C_Description__c='ASI_CRM_CN_Variable_Cost_Contract',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_CN_A_C_Code') ));
        ACCodeList.add(new ASI_MFM_A_C_Code__c( Name='5275.010000 PRC - Bottle Return Service', ASI_MFM_A_C_Code__c='5275.010000',ASI_MFM_A_C_Description__c='Bottle Return Service',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_CN_A_C_Code') ));
        ACCodeList.add(new ASI_MFM_A_C_Code__c( Name='5275.020000 Promotion Service Fee', ASI_MFM_A_C_Code__c='5275.020000',ASI_MFM_A_C_Description__c='Promotion Service Fee',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_CN_A_C_Code') ));
        ACCodeList.add(new ASI_MFM_A_C_Code__c( Name='5275.030000 PRC - Variable Event Cost', ASI_MFM_A_C_Code__c='5275.030000',ASI_MFM_A_C_Description__c='Variable Event Cost',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_CN_A_C_Code') ));
        
        insert ACCodeList;
        
        
        List<ASI_CRM_Contract_Cost_Setting__c> ContractCostSettingList= new List<ASI_CRM_Contract_Cost_Setting__c>();
        
        ContractCostSettingList.add(new ASI_CRM_Contract_Cost_Setting__c(ASI_CRM_CN_Activity_Code__c=ACCodeList[0].Id,ASI_CRM_CN_Promotion_Type__c='Heavy Contract ON',
                                                                         ASI_CRM_CN_Fixed_Cost_Contract__c=true,ASI_CRM_CN_Variable_Cost_Contract__c=true));
        
        ContractCostSettingList.add(new ASI_CRM_Contract_Cost_Setting__c(ASI_CRM_CN_Activity_Code__c=ACCodeList[0].Id,ASI_CRM_CN_Promotion_Type__c='Heavy Contract ON',ASI_CRM_CN_Variable_Cost_Contract__c=true,
                                                                         ASI_CRM_CN_Fixed_Cost_Contract__c=false,ASI_CRM_CN_BRSF_Activity_Code_Default__c=true));
        
        ContractCostSettingList.add(new ASI_CRM_Contract_Cost_Setting__c(ASI_CRM_CN_Activity_Code__c=ACCodeList[0].Id,ASI_CRM_CN_Promotion_Type__c='Heavy Contract ON',ASI_CRM_CN_Variable_Cost_Contract__c=true,
                                                                         ASI_CRM_CN_Fixed_Cost_Contract__c=false,ASI_CRM_PSF_Activity_Code_Default__c=true));
        
        ContractCostSettingList.add(new ASI_CRM_Contract_Cost_Setting__c(ASI_CRM_CN_Activity_Code__c=ACCodeList[0].Id,ASI_CRM_CN_Promotion_Type__c='Heavy Contract ON',ASI_CRM_CN_Variable_Cost_Contract__c=true,
                                                                         ASI_CRM_CN_Fixed_Cost_Contract__c=false,ASI_CRM_VEC_Activity_Code_Defaul__c=true));
        
        insert ContractCostSettingList;
        
        ASI_CRM_SpecialPromotionTypeSetting__c oldspts = new ASI_CRM_SpecialPromotionTypeSetting__c( ASI_CRM_Promotion_Type__c = 'a');
        insert oldspts;
        
        ASI_CRM_SpecialPromotionTypeSetting__c newspts = new ASI_CRM_SpecialPromotionTypeSetting__c(ASI_CRM_Promotion_Type__c = 'Heavy Contract On',recordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_SpecialPromotionTypeSetting__cASI_CRM_CN_SpecialPromotionTypeSetting'));
        insert newspts;
        
        ASI_CRM_Special_Promotion_Type_Mapping__c sptm = new ASI_CRM_Special_Promotion_Type_Mapping__c(ASI_CRM_Mapping_of_New_Promotion_Type__c = newspts.Id,ASI_CRM_Mapping_of_Old_Promotion_Type__c = oldspts.Id,recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Special_Promotion_Type_Mapping__cASI_CRM_CN_Special_Promotion_Type_Mapping'));
        insert sptm;
        
        
        Date today = Date.newInstance(2020, 5, 25);
        Date PO_Start_Date = date.newinstance(today.year(), today.month(), 1);
        Date PO_End_Date = PO_Start_Date.addMonths(1)-1;
        Date PO_Start_Date2 = date.newinstance(today.year(), today.addMonths(3).month(), 1);
        
        // Date PO_End_Date = PO_Start_Date.addMonths(1)-1;
        
        
        ASI_TH_CRM_Contract__c GroupContract = new ASI_TH_CRM_Contract__c(recordtypeid = Global_RecordTypeCache.getRTID('ASI_TH_CRM_Contract__cASI_CRM_CN_Group_Contract'),
                                                                          ASI_CRM_CN_PO_Start_Date__c = PO_Start_Date,
                                                                          ASI_CRM_CN_PO_End_Date__c =PO_End_Date,
                                                                          Name = 'Noah C4',
                                                                          ASI_CRM_CN_Outlet_WS__c=Customers[1].Id);
        insert GroupContract;
        
        
        List<ASI_TH_CRM_Contract__c> ContractList = new List<ASI_TH_CRM_Contract__c>();
        ASI_TH_CRM_Contract__c Contract = new ASI_TH_CRM_Contract__c(recordtypeid = Global_RecordTypeCache.getRTID('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract'),
                                                                     ASI_CRM_CN_Status__c = 'Final',ASI_CRM_CN_Group_Contract__c=GroupContract.Id,
                                                                     ASI_CRM_CN_PO_Start_Date__c = PO_Start_Date,
                                                                     ASI_CRM_CN_PO_End_Date__c =PO_End_Date,
                                                                     ASI_CRM_CN_PO_Version__c = '0.0',ASI_TH_CRM_Promotion_Type__c='Heavy Contract On',
                                                                     Name = 'Contract1',
                                                                     ASI_CRM_CN_Outlet_WS__c=Customers[1].Id,ASI_CRM_Volume_Option__c = 'Normal');
        ContractList.add(Contract);
        
         ASI_TH_CRM_Contract__c Contract2 = new ASI_TH_CRM_Contract__c(recordtypeid = Global_RecordTypeCache.getRTID('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract'),
                                                                     ASI_CRM_CN_Status__c = 'Final',
                                                                     ASI_CRM_CN_PO_Start_Date__c = PO_Start_Date2,
                                                                     ASI_CRM_CN_PO_End_Date__c =PO_Start_Date2.addMonths(4)-1,
                                                                     ASI_CRM_CN_PO_Version__c = '0.0',ASI_TH_CRM_Promotion_Type__c='Heavy Contract On',
                                                                     Name = 'Contract1',
                                                                     ASI_CRM_CN_Outlet_WS__c=Customers[1].Id,ASI_CRM_Volume_Option__c = 'Normal');
        ContractList.add(Contract2);
        
        insert ContractList;
        
        
        List<ASI_CRM_Methodology__c> MethodologyList= new List<ASI_CRM_Methodology__c> ();
        MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test1',ASI_CRM_Methodology_Code__c='01',ASI_CRM_Default__c=true,ASI_CRM_Chinese_Name__c='123',ASI_CRM_Type__c='BRSF',recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Methodology__cASI_CRM_CN_Methodology')));
        MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test2',ASI_CRM_Methodology_Code__c='01',ASI_CRM_Default__c=true,ASI_CRM_Chinese_Name__c='Test 123',ASI_CRM_Type__c='PSF',recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Methodology__cASI_CRM_CN_Methodology')));
        MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test3',ASI_CRM_Methodology_Code__c='01',ASI_CRM_Default__c=true,ASI_CRM_Chinese_Name__c='Test 123',ASI_CRM_Type__c='Variable Event Cost',recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Methodology__cASI_CRM_CN_Methodology')));
        
        
        MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test1',ASI_CRM_Methodology_Code__c='01',ASI_CRM_Chinese_Name__c='123',ASI_CRM_Type__c='BRSF',recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Methodology__cASI_CRM_CN_Methodology')));
        MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test2',ASI_CRM_Methodology_Code__c='01',ASI_CRM_Chinese_Name__c='123',ASI_CRM_Type__c='PSF',recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Methodology__cASI_CRM_CN_Methodology')));
        MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test3',ASI_CRM_Methodology_Code__c='01',ASI_CRM_Chinese_Name__c='123',ASI_CRM_Type__c='Variable Event Cost',recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Methodology__cASI_CRM_CN_Methodology')));
        insert MethodologyList;
        
        
        //Methodology Assignment
        List<ASI_CRM_Methodology_Assignment__c> MethodologyAssignmentList = new List<ASI_CRM_Methodology_Assignment__c>();
        MethodologyAssignmentList.add(new ASI_CRM_Methodology_Assignment__c(ASI_CRM_Methodology__c=MethodologyList[0].Id,ASI_CRM_Key_Principle__c=true,ASI_CRM_Methodology_Commercial_Team__c='Premium',ASI_CRM_Region__c=region.Id));
        MethodologyAssignmentList.add(new ASI_CRM_Methodology_Assignment__c(ASI_CRM_Methodology__c=MethodologyList[1].Id,ASI_CRM_Key_Principle__c=true,ASI_CRM_Methodology_Commercial_Team__c='Premium',ASI_CRM_Region__c=region.Id));
        MethodologyAssignmentList.add(new ASI_CRM_Methodology_Assignment__c(ASI_CRM_Methodology__c=MethodologyList[2].Id,ASI_CRM_Key_Principle__c=true,ASI_CRM_Methodology_Commercial_Team__c='Premium',ASI_CRM_Region__c=region.Id));
        MethodologyAssignmentList.add(new ASI_CRM_Methodology_Assignment__c(ASI_CRM_Methodology__c=MethodologyList[3].Id,ASI_CRM_Key_Principle__c=true,ASI_CRM_Methodology_Commercial_Team__c='Premium',ASI_CRM_Region__c=region.Id));
        MethodologyAssignmentList.add(new ASI_CRM_Methodology_Assignment__c(ASI_CRM_Methodology__c=MethodologyList[4].Id,ASI_CRM_Key_Principle__c=true,ASI_CRM_Methodology_Commercial_Team__c='Premium',ASI_CRM_Region__c=region.Id));
        MethodologyAssignmentList.add(new ASI_CRM_Methodology_Assignment__c(ASI_CRM_Methodology__c=MethodologyList[5].Id,ASI_CRM_Key_Principle__c=true,ASI_CRM_Methodology_Commercial_Team__c='Premium',ASI_CRM_Region__c=region.Id));
        
        insert MethodologyAssignmentList ;
        
        
        
        
        List<ASI_CRM_Module__c> ModuleList = new List<ASI_CRM_Module__c>();
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='Std. Btl.',ASI_CRM_Volume_Base__c='By Sub-Brand',ASI_CRM_Line_Type__c='BRSF',ASI_CRM_Methodology__c=MethodologyList[0].Id));
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='Std. Btl.',ASI_CRM_Volume_Base__c='By Sub-Brand',ASI_CRM_Line_Type__c='PSF',ASI_CRM_Methodology__c=MethodologyList[1].Id));
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='CR12 Extra Eqv.',ASI_CRM_Volume_Base__c='By Grade',ASI_CRM_Line_Type__c='PSF',ASI_CRM_Methodology__c=MethodologyList[1].Id));
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='CR12 Extra Eqv.',ASI_CRM_Volume_Base__c='By Category',ASI_CRM_Line_Type__c='PSF',ASI_CRM_Methodology__c=MethodologyList[1].Id));
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='CR12 Extra Eqv.',ASI_CRM_Volume_Base__c='By Total',ASI_CRM_Line_Type__c='PSF',ASI_CRM_Methodology__c=MethodologyList[1].Id));
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='CR12 Extra Eqv.',ASI_CRM_Volume_Base__c='By Sub-Brand',ASI_CRM_Line_Type__c='Variable Event Cost',ASI_CRM_Methodology__c=MethodologyList[2].Id));
         ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract2.Id,ASI_CRM_Unit__c='Std. Btl.',ASI_CRM_Volume_Base__c='By Sub-Brand',ASI_CRM_Line_Type__c='BRSF',ASI_CRM_Methodology__c=MethodologyList[0].Id));
        
        insert ModuleList;
        
        ASI_CRM_Contract_Cost__c contractCost = new ASI_CRM_Contract_Cost__c(ASI_CRM_CN_Contract__c = Contract.id,
                                                                             ASI_CRM_CN_Estimate_Amount__c = 100000,
                                                                             ASI_CRM_CN_Cost_Type__c = 'Fixed',
                                                                             ASI_CRM_CN_Other_Cost_Payment_Request__c = true,
                                                                             recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_Contract_Cost__cASI_CRM_CN_Contract_Cost') );
        insert contractCost;
        
        list<ASI_CRM_CN_Contract_BRSF_Line_Item__c> ContractLineList = new list<ASI_CRM_CN_Contract_BRSF_Line_Item__c>();
        
        for(ASI_MFM_Sub_brand__c subBrand :subBrands) {
            ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract.Id,
                                                                           ASI_CRM_CN_Est_Monthly_Qty__c=1,ASI_CRM_Module__c=ModuleList[0].Id,
                                                                           ASI_CRM_CN_Contract_Monthly_Qty__c=1,
                                                                           ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,
                                                                           ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,ASI_CRM_Type__c='BRSF',
                                                                           ASI_CRM_CN_Sub_Brand__c=subBrand.Id,
                                                                           recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF')));
        }
        
         for(ASI_MFM_Sub_brand__c subBrand :subBrands) {
            ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract.Id,
                                                                           ASI_CRM_CN_Est_Monthly_Qty__c=1,ASI_CRM_Module__c=ModuleList[1].Id,
                                                                           ASI_CRM_CN_Contract_Monthly_Qty__c=1,ASI_CRM_Volume_Base__c='By Sub-Brand',
                                                                           ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,
                                                                           ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,ASI_CRM_Type__c='PSF',
                                                                           ASI_CRM_CN_Sub_Brand__c=subBrand.Id,
                                                                           recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF')));
        }

        ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract.Id,ASI_CRM_Type__c='PSF',ASI_CRM_Volume_Base__c='By Grade',
                                                                       ASI_CRM_CN_Est_Monthly_Qty__c=4,ASI_CRM_Module__c=ModuleList[2].Id,
                                                                       ASI_CRM_CN_Contract_Monthly_Qty__c=4,ASI_CRM_Sub_Brand_Grade__c=grades[0].Id,
                                                                       ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,
                                                                       ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,
                                                                       ASI_CRM_CN_Sub_Brand__c=null,
                                                                       recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF') ));
        ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract.Id,ASI_CRM_Type__c='PSF',ASI_CRM_Volume_Base__c='By Category',
                                                                       ASI_CRM_CN_Est_Monthly_Qty__c=4,ASI_CRM_Module__c=ModuleList[3].Id,
                                                                       ASI_CRM_CN_Contract_Monthly_Qty__c=4,ASI_CRM_Product_Category__c=ProductCategoryList[0].Id,
                                                                       ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,
                                                                       ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,
                                                                       ASI_CRM_CN_Sub_Brand__c=null,
                                                                       recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF') ));
        ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract.Id,ASI_CRM_Type__c='PSF',ASI_CRM_Volume_Base__c='By Total',
                                                                       ASI_CRM_CN_Est_Monthly_Qty__c=4,ASI_CRM_Module__c=ModuleList[4].Id,
                                                                       ASI_CRM_CN_Contract_Monthly_Qty__c=4,
                                                                       ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,
                                                                       ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,
                                                                       ASI_CRM_CN_Sub_Brand__c=null,
                                                                       recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF') ));
         for(ASI_MFM_Sub_brand__c subBrand :subBrands) {
            ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract.Id,
                                                                           ASI_CRM_CN_Est_Monthly_Qty__c=1,ASI_CRM_Module__c=ModuleList[5].Id,
                                                                           ASI_CRM_CN_Contract_Monthly_Qty__c=1,ASI_CRM_Volume_Base__c='By Sub-Brand',
                                                                           ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,
                                                                           ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,ASI_CRM_Type__c='Variable Event Cost',
                                                                           ASI_CRM_CN_Sub_Brand__c=subBrand.Id,
                                                                           recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF')));
        }
        
        insert ContractLineList;
        
        
        
        
         
        test.startTest();
        
        
        
        

        
        PageReference EnterPage = Page.ASI_CRM_CN_ViewHeavyContractPage;
        
        Map<String, String> pageParams = EnterPage.getParameters();
        
        pageParams.put('id', Contract2.id);
        ApexPages.StandardController sc = new ApexPages.standardController(new ASI_TH_CRM_Contract__c());
        
        ASI_CRM_CN_EditHeavyContractDetailCtrl con = new ASI_CRM_CN_EditHeavyContractDetailCtrl(new ApexPages.Standardcontroller(Contract2));
        // con.CopyHistoricalV0Contract();
        // con.ResetPSFDetails();
        
        
        test.stopTest(); 
    }

    static testMethod void ASI_CRM_CN_ViewHeavyContractCtrl2ndTest4() {
        
        //Test Class for ASI_CRM_CN_ViewHeavyContractCtrl2nd-----> Test restore
        ASI_CRM_Region__c region = new ASI_CRM_Region__c (Name='Central Region',recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Region__cASI_CRM_CN_Region'));
        insert region;
        
        ASI_CRM_Division__c division = new ASI_CRM_Division__c(Name='TEST', ASI_CRM_Region__c=region.Id);
        insert division;
        
        ASI_CRM_CN_Area__c area = new ASI_CRM_CN_Area__c(Name='TEST', ASI_CRM_English_Name__c='TEST', ASI_CRM_Division__c=division.Id);
        insert area;
        
        ASI_CRM_City__c city = new ASI_CRM_City__c(Name='TEST', ASI_CRM_CN_Area__c=area.Id);
        insert city;
        
        /*ASI_CRM_CN_Channel__c channel = new ASI_CRM_CN_Channel__c(Name='KTV',ASI_CRM_BC_Rate__c=98,ASI_CRM_CN_On_Off__c='ON',ASI_CRM_For_Outlet__c=true,RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CN_Channel__cASI_CRM_CN_New_Channel'),ASI_CRM_For_Contract__c=TRUE);
        insert channel;*/
        
        ASI_CRM_CN_Channel__c channel = new ASI_CRM_CN_Channel__c(ASI_CRM_CN_On_Off__c='ON');
        insert channel;
        
        ASI_MFM_Sub_Channel__c subChannel = new ASI_MFM_Sub_Channel__c(ASI_CRM_CN_Channel__c=channel.Id);
        insert subChannel;
        
        ASI_CRM_CN_Channel__c newChannel = new ASI_CRM_CN_Channel__c(ASI_CRM_For_Outlet__c = true, Name='Restaurant',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CN_Channel__cASI_CRM_CN_New_Channel'),ASI_CRM_CN_On_Off__c='OFF');
        insert newChannel;
        
        
        Id rtWS = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_CN_WS');
        Id rtOutlet = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN');
        
        list<ASI_CRM_AccountsAdditionalField__c> Customers = new list<ASI_CRM_AccountsAdditionalField__c>();
        Customers.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Eng_Name__c = 'b', ASI_CRM_CN_Chi_Name__c = 'b', ASI_CRM_CN_Commercial_Team__c = 'Premium', ASI_CRM_CN_Sub_Channel__c=subChannel.Id, ASI_CRM_CN_CCity__c=city.Id, ASI_CRM_Latest_Call_Plan_Date__c=system.today(), RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN'), ASI_CRM_CN_NewChannel__c = newChannel.Id, ASI_CRM_CN_Type_of_Restaurant__c = 'International',ASI_CRM_CN_Spending_per_head__c=1));
        Customers.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Eng_Name__c = 'c', ASI_CRM_CN_Chi_Name__c = 'c', ASI_CRM_CN_Commercial_Team__c = 'Premium', ASI_CRM_CN_Sub_Channel__c=subChannel.Id, ASI_CRM_CN_CCity__c=city.Id, ASI_CRM_Latest_Call_Plan_Date__c=system.today(), RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN'), ASI_CRM_CN_NewChannel__c = newChannel.Id, ASI_CRM_CN_Type_of_Restaurant__c = 'International',ASI_CRM_CN_Spending_per_head__c=1));
        insert Customers;
        
        /*
        //Covered_Outlet
        list<ASI_CRM_AccountsAdditionalField__c> ChildCustomers = new list<ASI_CRM_AccountsAdditionalField__c>();
        ChildCustomers.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Parent_Outlet__c=Customers[1].Id,ASI_CRM_CN_Eng_Name__c = 'a', ASI_CRM_CN_Chi_Name__c = 'a', ASI_CRM_CN_Commercial_Team__c = 'Premium', ASI_CRM_CN_Sub_Channel__c=subChannel.Id, ASI_CRM_CN_CCity__c=city.Id, ASI_CRM_Latest_Call_Plan_Date__c=system.today(), RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN'), ASI_CRM_CN_NewChannel__c = newChannel.Id, ASI_CRM_CN_Type_of_Restaurant__c = 'International',ASI_CRM_CN_Spending_per_head__c=1));
        insert ChildCustomers;
        
        
        // list<ASI_CRM_AccountsAdditionalField__c> ChildChildCustomers = new list<ASI_CRM_AccountsAdditionalField__c>();
        //ChildChildCustomers.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Parent_Outlet__c=ChildCustomers[0].Id,ASI_CRM_CN_Commercial_Team__c = 'Premium',RecordTypeId=rtOutlet,Name='TEST', ASI_CRM_CN_Image__c='Iconic',ASI_CRM_CN_CCity__c=city.Id,ASI_CRM_CN_NewChannel__c=channel.Id));
        //insert ChildChildCustomers;
        
        //ASI_CRM_CN_Parent_Outlet__c
        */
        User currentUser = [SELECT id, name, Managerid, ASI_CRM_CN_Prefix__c FROM USER WHERE id =:UserInfo.getUserId()];
        
        list<ASI_HK_CRM_Running_Number__c> rns = new list<ASI_HK_CRM_Running_Number__c>();
        rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_TH_CRM_Contract__c', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_TH_CRM_PaymentRequest__c', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        if(!String.isBlank(currentUser.ASI_CRM_CN_Prefix__c))
            rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_'+currentUser.ASI_CRM_CN_Prefix__c, recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        else{
            rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_NULL', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
            rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        }
        insert rns;
        
        //Sub Brand Grade
        //
        
        list<ASI_CRM_Sub_Brand_Grade__c> grades = new list<ASI_CRM_Sub_Brand_Grade__c>();
        grades.add(new ASI_CRM_Sub_Brand_Grade__c (Name='TEST1'));
        grades.add(new ASI_CRM_Sub_Brand_Grade__c (Name='TEST2'));
        grades.add(new ASI_CRM_Sub_Brand_Grade__c (Name='TEST3'));
        insert grades;
        
        
        list<ASI_MFM_Sub_brand__c> subBrands = new list<ASI_MFM_Sub_brand__c>();
        for(ASI_CRM_Sub_Brand_Grade__c grade :grades) {
            subBrands.add(new ASI_MFM_Sub_brand__c (Name='TEST1',ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,RecordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand'),
                                                    ASI_CRM_CN_Sub_brand_Grade__c=grade.Id));
            subBrands.add(new ASI_MFM_Sub_brand__c (Name='TEST2',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand'),
                                                    ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,
                                                    ASI_CRM_CN_Sub_brand_Grade__c=grade.Id));
            subBrands.add(new ASI_MFM_Sub_brand__c ( Name='TEST3',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand'),
                                                    ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,
                                                    ASI_CRM_CN_Sub_brand_Grade__c=grade.Id));
            subBrands.add(new ASI_MFM_Sub_brand__c ( Name='999',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand'),
                                                    ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,ASI_MFM_Sub_brand_Code__c = '999' ,ASI_MFM_Active_for_CRM__c = true ,
                                                    ASI_CRM_CN_Sub_brand_Grade__c=grade.Id));
        }
        insert subBrands;
        
        
        Date PO_Start_Date = date.newinstance(system.today().year(), system.today().month(), 1);
        Date PO_End_Date = PO_Start_Date.addMonths(1)-1;
        
        ASI_TH_CRM_Contract__c Contract2 = new ASI_TH_CRM_Contract__c(recordtypeid = Global_RecordTypeCache.getRTID('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract'),ASI_CRM_CN_Is_2nd_KPI_PO__c=true,
                                                                      ASI_CRM_CN_Status__c = 'Archived',
                                                                      ASI_CRM_CN_PO_Start_Date__c = PO_Start_Date,
                                                                      ASI_CRM_CN_PO_End_Date__c =PO_End_Date,
                                                                      ASI_CRM_CN_PO_Version__c = '0.0',ASI_TH_CRM_Promotion_Type__c='Heavy Contract On',
                                                                      Name = 'Contract1',
                                                                      ASI_CRM_CN_Outlet_WS__c=Customers[1].Id,ASI_CRM_Volume_Option__c = 'Normal');
        insert Contract2;
        
        ASI_TH_CRM_Contract__c Contract = new ASI_TH_CRM_Contract__c(recordtypeid = Global_RecordTypeCache.getRTID('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract'),ASI_CRM_CN_Is_2nd_KPI_PO__c=true,
                                                                     ASI_CRM_CN_Status__c = 'Draft',
                                                                     ASI_CRM_CN_PO_Start_Date__c = PO_Start_Date,
                                                                     ASI_CRM_CN_PO_End_Date__c =PO_End_Date,ASI_CRM_CN_V0_0_PO_version__c=Contract2.Id,ASI_CRM_CN_Last_PO_version__c=Contract2.Id,
                                                                     ASI_CRM_CN_PO_Version__c = '0.1',ASI_TH_CRM_Promotion_Type__c='Heavy Contract On',
                                                                     Name = 'Contract2',
                                                                     ASI_CRM_CN_Outlet_WS__c=Customers[1].Id,ASI_CRM_Volume_Option__c = 'Normal');
        insert Contract;
        
        
        List<ASI_CRM_Module__c> ModuleList = new List<ASI_CRM_Module__c>();
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Unit__c='Std. Btl.',ASI_CRM_Volume_Base__c='By Sub-Brand',ASI_CRM_Line_Type__c='BRSF'));
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Unit__c='CR12 Extra Eqv.',ASI_CRM_Volume_Base__c='By Total',ASI_CRM_Line_Type__c='PSF'));
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Unit__c='CR12 Extra Eqv.',ASI_CRM_Volume_Base__c='By Total',ASI_CRM_Line_Type__c='Variable Event Cost'));
        
        insert ModuleList;
        /*
        ASI_CRM_Contract_Cost__c contractCost = new ASI_CRM_Contract_Cost__c(ASI_CRM_CN_Contract__c = Contract.id,
                                                                             ASI_CRM_CN_Estimate_Amount__c = 100000,
                                                                             ASI_CRM_CN_Cost_Type__c = 'Variable',
                                                                             ASI_CRM_CN_Other_Cost_Payment_Request__c = true,
                                                                             recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_Contract_Cost__cASI_CRM_CN_Contract_Cost') );
        insert contractCost;
        */
        list<ASI_CRM_CN_Contract_BRSF_Line_Item__c> ContractLineList = new list<ASI_CRM_CN_Contract_BRSF_Line_Item__c>();
        list<ASI_CRM_CN_Covered_Outlet__c> cos = new list<ASI_CRM_CN_Covered_Outlet__c>();
        for(ASI_MFM_Sub_brand__c subBrand :subBrands) {
            ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract.Id,
                                                                           ASI_CRM_CN_Est_Monthly_Qty__c=1,ASI_CRM_Module__c=ModuleList[0].Id,
                                                                           ASI_CRM_CN_Contract_Monthly_Qty__c=1,
                                                                           ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,
                                                                           ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,ASI_CRM_Type__c='BRSF',
                                                                           ASI_CRM_CN_Sub_Brand__c=subBrand.Id,
                                                                           recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF')));
        }
        ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract.Id,ASI_CRM_Type__c='PSF',ASI_CRM_Volume_Base__c='By Total',
                                                                       ASI_CRM_CN_Est_Monthly_Qty__c=1,ASI_CRM_Module__c=ModuleList[1].Id,
                                                                       ASI_CRM_CN_Contract_Monthly_Qty__c=1,
                                                                       ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,
                                                                       ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,
                                                                       ASI_CRM_CN_Sub_Brand__c=null,
                                                                       recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF') ));
        ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract.Id,ASI_CRM_Type__c='Variable Event Cost',ASI_CRM_Volume_Base__c='By Total',
                                                                       ASI_CRM_CN_Est_Monthly_Qty__c=1,ASI_CRM_Module__c=ModuleList[2].Id,
                                                                       ASI_CRM_CN_Contract_Monthly_Qty__c=1,
                                                                       ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,
                                                                       ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,
                                                                       ASI_CRM_CN_Sub_Brand__c=null,
                                                                       recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF') ));
        insert ContractLineList;
        List<ASI_CRM_Methodology__c> MethodologyList= new List<ASI_CRM_Methodology__c> ();
        MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test1',ASI_CRM_Methodology_Code__c='01',ASI_CRM_Default__c=true,ASI_CRM_Chinese_Name__c='123',ASI_CRM_Type__c='BRSF',recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Methodology__cASI_CRM_CN_Methodology')));
        MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test2',ASI_CRM_Methodology_Code__c='01',ASI_CRM_Default__c=true,ASI_CRM_Chinese_Name__c='Test 123',ASI_CRM_Type__c='PSF',recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Methodology__cASI_CRM_CN_Methodology')));
        MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test3',ASI_CRM_Methodology_Code__c='01',ASI_CRM_Default__c=true,ASI_CRM_Chinese_Name__c='Test 123',ASI_CRM_Type__c='Variable Event Cost',recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Methodology__cASI_CRM_CN_Methodology')));
        
        
       // MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test1',ASI_CRM_Methodology_Code__c='01',ASI_CRM_Chinese_Name__c='123',ASI_CRM_Type__c='BRSF'));
       // MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test2',ASI_CRM_Methodology_Code__c='01',ASI_CRM_Chinese_Name__c='123',ASI_CRM_Type__c='PSF'));
       // MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test3',ASI_CRM_Methodology_Code__c='01',ASI_CRM_Chinese_Name__c='123',ASI_CRM_Type__c='Variable Event Cost'));
        insert MethodologyList;
        
        test.startTest();
        PageReference EnterPage = Page.ASI_CRM_CN_ViewHeavyContractPage;
        Test.setCurrentPage(EnterPage);
        ApexPages.currentPage().getParameters().put('id', Contract.id);
        
        
        ASI_CRM_CN_ViewHeavyContractCtrl con = new ASI_CRM_CN_ViewHeavyContractCtrl(new ApexPages.Standardcontroller(Contract));
        
        con.restorePO();
        con.POModification();
        con.ErrorHandling('Test');
        con.Calculation2nd();
        test.stopTest(); 
    }

    static testMethod void ASI_CRM_CN_ViewHeavyContractCtrl2ndTest5() {
        
        //Test Class for ASI_CRM_CN_ViewHeavyContractCtrl2nd-----> Test restore
        ASI_CRM_Region__c region = new ASI_CRM_Region__c (Name='Central Region',recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Region__cASI_CRM_CN_Region'));
        insert region;
        
        ASI_CRM_Division__c division = new ASI_CRM_Division__c(Name='TEST', ASI_CRM_Region__c=region.Id);
        insert division;
        
        ASI_CRM_CN_Area__c area = new ASI_CRM_CN_Area__c(Name='TEST', ASI_CRM_English_Name__c='TEST', ASI_CRM_Division__c=division.Id);
        insert area;
        
        ASI_CRM_City__c city = new ASI_CRM_City__c(Name='TEST', ASI_CRM_CN_Area__c=area.Id);
        insert city;
        
        /*ASI_CRM_CN_Channel__c channel = new ASI_CRM_CN_Channel__c(Name='KTV',ASI_CRM_BC_Rate__c=98,ASI_CRM_CN_On_Off__c='ON',ASI_CRM_For_Outlet__c=true,RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CN_Channel__cASI_CRM_CN_New_Channel'),ASI_CRM_For_Contract__c=TRUE);
        insert channel;*/
        
        ASI_CRM_CN_Channel__c channel = new ASI_CRM_CN_Channel__c(ASI_CRM_CN_On_Off__c='ON');
        insert channel;
        
        ASI_MFM_Sub_Channel__c subChannel = new ASI_MFM_Sub_Channel__c(ASI_CRM_CN_Channel__c=channel.Id);
        insert subChannel;
        
        ASI_CRM_CN_Channel__c newChannel = new ASI_CRM_CN_Channel__c(ASI_CRM_For_Outlet__c = true, Name='Restaurant',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CN_Channel__cASI_CRM_CN_New_Channel'),ASI_CRM_CN_On_Off__c='OFF');
        insert newChannel;
        
        
        Id rtWS = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_CN_WS');
        Id rtOutlet = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN');
        
        list<ASI_CRM_AccountsAdditionalField__c> Customers = new list<ASI_CRM_AccountsAdditionalField__c>();
        Customers.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Eng_Name__c = 'b', ASI_CRM_CN_Chi_Name__c = 'b', ASI_CRM_CN_Commercial_Team__c = 'Premium', ASI_CRM_CN_Sub_Channel__c=subChannel.Id, ASI_CRM_CN_CCity__c=city.Id, ASI_CRM_Latest_Call_Plan_Date__c=system.today(), RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN'), ASI_CRM_CN_NewChannel__c = newChannel.Id, ASI_CRM_CN_Type_of_Restaurant__c = 'International',ASI_CRM_CN_Spending_per_head__c=1));
        Customers.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Eng_Name__c = 'c', ASI_CRM_CN_Chi_Name__c = 'c', ASI_CRM_CN_Commercial_Team__c = 'Premium', ASI_CRM_CN_Sub_Channel__c=subChannel.Id, ASI_CRM_CN_CCity__c=city.Id, ASI_CRM_Latest_Call_Plan_Date__c=system.today(), RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN'), ASI_CRM_CN_NewChannel__c = newChannel.Id, ASI_CRM_CN_Type_of_Restaurant__c = 'International',ASI_CRM_CN_Spending_per_head__c=1));
        insert Customers;
        
        /*
        //Covered_Outlet
        list<ASI_CRM_AccountsAdditionalField__c> ChildCustomers = new list<ASI_CRM_AccountsAdditionalField__c>();
        ChildCustomers.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Parent_Outlet__c=Customers[1].Id,ASI_CRM_CN_Eng_Name__c = 'a', ASI_CRM_CN_Chi_Name__c = 'a', ASI_CRM_CN_Commercial_Team__c = 'Premium', ASI_CRM_CN_Sub_Channel__c=subChannel.Id, ASI_CRM_CN_CCity__c=city.Id, ASI_CRM_Latest_Call_Plan_Date__c=system.today(), RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN'), ASI_CRM_CN_NewChannel__c = newChannel.Id, ASI_CRM_CN_Type_of_Restaurant__c = 'International',ASI_CRM_CN_Spending_per_head__c=1));
        insert ChildCustomers;
        
        
        // list<ASI_CRM_AccountsAdditionalField__c> ChildChildCustomers = new list<ASI_CRM_AccountsAdditionalField__c>();
        //ChildChildCustomers.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Parent_Outlet__c=ChildCustomers[0].Id,ASI_CRM_CN_Commercial_Team__c = 'Premium',RecordTypeId=rtOutlet,Name='TEST', ASI_CRM_CN_Image__c='Iconic',ASI_CRM_CN_CCity__c=city.Id,ASI_CRM_CN_NewChannel__c=channel.Id));
        //insert ChildChildCustomers;
        
        //ASI_CRM_CN_Parent_Outlet__c
        */
        User currentUser = [SELECT id, name, Managerid,LanguageLocaleKey, ASI_CRM_CN_Prefix__c FROM USER WHERE id =:UserInfo.getUserId()];
        currentUser.LanguageLocaleKey='zh_CN';
        update currentUser;
        
        list<ASI_HK_CRM_Running_Number__c> rns = new list<ASI_HK_CRM_Running_Number__c>();
        rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_TH_CRM_Contract__c', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_TH_CRM_PaymentRequest__c', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        if(!String.isBlank(currentUser.ASI_CRM_CN_Prefix__c))
            rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_'+currentUser.ASI_CRM_CN_Prefix__c, recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        else{
            rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_NULL', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
            rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        }
        insert rns;
        
        //Sub Brand Grade
        //
        
        list<ASI_CRM_Sub_Brand_Grade__c> grades = new list<ASI_CRM_Sub_Brand_Grade__c>();
        grades.add(new ASI_CRM_Sub_Brand_Grade__c (Name='TEST1'));
        grades.add(new ASI_CRM_Sub_Brand_Grade__c (Name='TEST2'));
        grades.add(new ASI_CRM_Sub_Brand_Grade__c (Name='TEST3'));
        insert grades;
        
        
        list<ASI_MFM_Sub_brand__c> subBrands = new list<ASI_MFM_Sub_brand__c>();
        for(ASI_CRM_Sub_Brand_Grade__c grade :grades) {
            subBrands.add(new ASI_MFM_Sub_brand__c (Name='TEST1',ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,RecordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand'),
                                                    ASI_CRM_CN_Sub_brand_Grade__c=grade.Id));
            subBrands.add(new ASI_MFM_Sub_brand__c (Name='TEST2',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand'),
                                                    ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,
                                                    ASI_CRM_CN_Sub_brand_Grade__c=grade.Id));
            subBrands.add(new ASI_MFM_Sub_brand__c ( Name='TEST3',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand'),
                                                    ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,
                                                    ASI_CRM_CN_Sub_brand_Grade__c=grade.Id));
            subBrands.add(new ASI_MFM_Sub_brand__c ( Name='999',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand'),
                                                    ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,ASI_MFM_Sub_brand_Code__c = '999' ,ASI_MFM_Active_for_CRM__c = true ,
                                                    ASI_CRM_CN_Sub_brand_Grade__c=grade.Id));
        }
        insert subBrands;

        List<ASI_MFM_A_C_Code__c> ACCodeList = new  List<ASI_MFM_A_C_Code__c>();
        ACCodeList.add(new ASI_MFM_A_C_Code__c( Name='0000000000000', ASI_MFM_A_C_Code__c='000010000',ASI_MFM_A_C_Description__c='ASI_CRM_CN_Variable_Cost_Contract',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_CN_A_C_Code') ));
        ACCodeList.add(new ASI_MFM_A_C_Code__c( Name='5275.010000 PRC - Bottle Return Service', ASI_MFM_A_C_Code__c='5275.010000',ASI_MFM_A_C_Description__c='Bottle Return Service',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_CN_A_C_Code') ));
        ACCodeList.add(new ASI_MFM_A_C_Code__c( Name='5275.020000 Promotion Service Fee', ASI_MFM_A_C_Code__c='5275.020000',ASI_MFM_A_C_Description__c='Promotion Service Fee',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_CN_A_C_Code') ));
        ACCodeList.add(new ASI_MFM_A_C_Code__c( Name='5275.030000 PRC - Variable Event Cost', ASI_MFM_A_C_Code__c='5275.030000',ASI_MFM_A_C_Description__c='Variable Event Cost',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_CN_A_C_Code') ));
        ACCodeList.add(new ASI_MFM_A_C_Code__c( Name='5275.040000 PRC - Fixed Event Cost',ASI_MFM_A_C_CN_Description__c='夜店活动费用(固定)', ASI_MFM_A_C_Code__c='5275.040000',ASI_MFM_A_C_Description__c='PRC - Fixed Event Cost',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_CN_A_C_Code') ));

        ACCodeList.add(new ASI_MFM_A_C_Code__c( Name='5260.100000 PRC - Store/Outlet Support',ASI_MFM_A_C_CN_Description__c='店家支持', ASI_MFM_A_C_Code__c='5260.100000',ASI_MFM_A_C_Description__c='PRC - Store/Outlet Support',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_CN_A_C_Code') ));
        
        insert ACCodeList;
        
        List<ASI_CRM_Contract_Cost_Setting__c> ContractCostSettingList= new List<ASI_CRM_Contract_Cost_Setting__c>();

        ContractCostSettingList.add(new ASI_CRM_Contract_Cost_Setting__c(ASI_CRM_CN_Activity_Code__c=ACCodeList[4].Id,ASI_CRM_CN_Promotion_Type__c='Heavy Contract ON',
                                                                         ASI_CRM_CN_Fixed_Cost_Contract__c=true,ASI_CRM_CN_Variable_Cost_Contract__c=false));

        ContractCostSettingList.add(new ASI_CRM_Contract_Cost_Setting__c(ASI_CRM_CN_Activity_Code__c=ACCodeList[5].Id,ASI_CRM_CN_Promotion_Type__c='Heavy Contract ON',
                                                                         ASI_CRM_CN_Fixed_Cost_Contract__c=true,ASI_CRM_CN_Variable_Cost_Contract__c=false));

        insert ContractCostSettingList;
        
        Date PO_Start_Date = date.newinstance(system.today().year(), system.today().month(), 1);
        Date PO_End_Date = PO_Start_Date.addMonths(1)-1;
        
        ASI_TH_CRM_Contract__c Contract2 = new ASI_TH_CRM_Contract__c(recordtypeid = Global_RecordTypeCache.getRTID('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract'),ASI_CRM_CN_Is_2nd_KPI_PO__c=true,
                                                                      ASI_CRM_CN_Status__c = 'Archived',
                                                                      ASI_CRM_CN_PO_Start_Date__c = PO_Start_Date,
                                                                      ASI_CRM_CN_PO_End_Date__c =PO_End_Date,
                                                                      ASI_CRM_CN_PO_Version__c = '0.0',ASI_TH_CRM_Promotion_Type__c='Heavy Contract On',
                                                                      Name = 'Contract1',
                                                                      ASI_CRM_CN_Outlet_WS__c=Customers[1].Id,ASI_CRM_Volume_Option__c = 'Normal');
        insert Contract2;
        
        ASI_TH_CRM_Contract__c Contract = new ASI_TH_CRM_Contract__c(recordtypeid = Global_RecordTypeCache.getRTID('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract'),ASI_CRM_CN_Is_2nd_KPI_PO__c=true,
                                                                     ASI_CRM_CN_Status__c = 'Draft',
                                                                     ASI_CRM_CN_PO_Start_Date__c = PO_Start_Date,
                                                                     ASI_CRM_CN_PO_End_Date__c =PO_End_Date,
                                                                     ASI_CRM_CN_CTD_Monthly_Default_Date__c=Date.today(),ASI_CRM_CN_V0_0_PO_version__c=Contract2.Id,ASI_CRM_CN_Last_PO_version__c=Contract2.Id,
                                                                     ASI_CRM_CN_PO_Version__c = '0.1',ASI_TH_CRM_Promotion_Type__c='Heavy Contract On',
                                                                     Name = 'Contract2',
                                                                     ASI_CRM_CN_Outlet_WS__c=Customers[1].Id,ASI_CRM_Volume_Option__c = 'Normal');
        insert Contract;
        
        
        List<ASI_CRM_Module__c> ModuleList = new List<ASI_CRM_Module__c>();
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='Std. Btl.',ASI_CRM_Volume_Base__c='By Sub-Brand',ASI_CRM_Line_Type__c='BRSF'));
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='Std. Btl.',ASI_CRM_Volume_Base__c='By Sub-Brand',ASI_CRM_Line_Type__c='PSF'));
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='CR12 Extra Eqv.',ASI_CRM_Volume_Base__c='By Grade',ASI_CRM_Line_Type__c='PSF'));
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='CR12 Extra Eqv.',ASI_CRM_Volume_Base__c='By Category',ASI_CRM_Line_Type__c='PSF'));
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='CR12 Extra Eqv.',ASI_CRM_Volume_Base__c='By Total',ASI_CRM_Line_Type__c='PSF'));
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='CR12 Extra Eqv.',ASI_CRM_Volume_Base__c='By Sub-Brand',ASI_CRM_Line_Type__c='Variable Event Cost'));

        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='Std. Btl.',ASI_CRM_Volume_Base__c='By Sub-Brand',ASI_CRM_Line_Type__c='Fixed',ASI_CRM_CN_AC_Code__c = ACCodeList[4].Id, ASI_CRM_CN_AC_Code__r = ACCodeList[4]));
        
        insert ModuleList;
        /*
        ASI_CRM_Contract_Cost__c contractCost = new ASI_CRM_Contract_Cost__c(ASI_CRM_CN_Contract__c = Contract.id,
                                                                             ASI_CRM_CN_Estimate_Amount__c = 100000,
                                                                             ASI_CRM_CN_Cost_Type__c = 'Variable',
                                                                             ASI_CRM_CN_Other_Cost_Payment_Request__c = true,
                                                                             recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_Contract_Cost__cASI_CRM_CN_Contract_Cost') );
        insert contractCost;
        */
        list<ASI_CRM_CN_Contract_BRSF_Line_Item__c> ContractLineList = new list<ASI_CRM_CN_Contract_BRSF_Line_Item__c>();
        list<ASI_CRM_CN_Covered_Outlet__c> cos = new list<ASI_CRM_CN_Covered_Outlet__c>();
        for(ASI_MFM_Sub_brand__c subBrand :subBrands) {
            ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract.Id,
                                                                           ASI_CRM_CN_Est_Monthly_Qty__c=1,ASI_CRM_Module__c=ModuleList[0].Id,
                                                                           ASI_CRM_CN_Contract_Monthly_Qty__c=1,
                                                                           ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,
                                                                           ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,ASI_CRM_Type__c='BRSF',
                                                                           ASI_CRM_CN_Sub_Brand__c=subBrand.Id,
                                                                           recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF')));
        }
        for(ASI_MFM_Sub_brand__c subBrand :subBrands) {
            ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract.Id,
                                                                           ASI_CRM_CN_Est_Monthly_Qty__c=1,ASI_CRM_Module__c=ModuleList[1].Id,
                                                                           ASI_CRM_CN_Contract_Monthly_Qty__c=1,ASI_CRM_Volume_Base__c='By Sub-Brand',
                                                                           ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,
                                                                           ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,ASI_CRM_Type__c='PSF',
                                                                           ASI_CRM_CN_Sub_Brand__c=subBrand.Id,
                                                                           recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF')));
        }
        ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract.Id,ASI_CRM_Type__c='PSF',ASI_CRM_Volume_Base__c='By Grade',
                                                                       ASI_CRM_CN_Est_Monthly_Qty__c=4,ASI_CRM_Module__c=ModuleList[2].Id,
                                                                       ASI_CRM_CN_Contract_Monthly_Qty__c=4,ASI_CRM_Sub_Brand_Grade__c=grades[0].Id,
                                                                       ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,
                                                                       ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,
                                                                       ASI_CRM_CN_Sub_Brand__c=null,
                                                                       recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF') ));
        ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract.Id,ASI_CRM_Type__c='PSF',ASI_CRM_Volume_Base__c='By Total',
                                                                       ASI_CRM_CN_Est_Monthly_Qty__c=4,ASI_CRM_Module__c=ModuleList[4].Id,
                                                                       ASI_CRM_CN_Contract_Monthly_Qty__c=4,
                                                                       ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,
                                                                       ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,
                                                                       ASI_CRM_CN_Sub_Brand__c=null,
                                                                       recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF') ));
        for(ASI_MFM_Sub_brand__c subBrand :subBrands) {
            ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract.Id,
                                                                           ASI_CRM_CN_Est_Monthly_Qty__c=1,ASI_CRM_Module__c=ModuleList[6].Id,
                                                                           ASI_CRM_CN_Contract_Monthly_Qty__c=1,ASI_CRM_Volume_Base__c='By Sub-Brand',
                                                                           ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,ASI_CRM_CN_Activity_Code__r=ACCodeList[4],ASI_CRM_CN_Activity_Code__c=ACCodeList[4].Id,
                                                                           ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,ASI_CRM_Type__c='Fixed',
                                                                           ASI_CRM_CN_Sub_Brand__c=subBrand.Id,
                                                                           recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF')));
            ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract2.Id,
                                                                           ASI_CRM_CN_Est_Monthly_Qty__c=1,ASI_CRM_Module__c=ModuleList[6].Id,
                                                                           ASI_CRM_CN_Contract_Monthly_Qty__c=1,ASI_CRM_Volume_Base__c='By Sub-Brand',
                                                                           ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,ASI_CRM_CN_Activity_Code__r=ACCodeList[4],ASI_CRM_CN_Activity_Code__c=ACCodeList[4].Id,
                                                                           ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,ASI_CRM_Type__c='Fixed',
                                                                           ASI_CRM_CN_Sub_Brand__c=subBrand.Id,
                                                                           recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF')));
        }
        for(ASI_MFM_Sub_brand__c subBrand :subBrands) {
            ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract.Id,
                                                                           ASI_CRM_CN_Est_Monthly_Qty__c=1,ASI_CRM_Module__c=ModuleList[5].Id,
                                                                           ASI_CRM_CN_Contract_Monthly_Qty__c=1,ASI_CRM_Volume_Base__c='By Sub-Brand',
                                                                           ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,
                                                                           ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,ASI_CRM_Type__c='Variable Event Cost',
                                                                           ASI_CRM_CN_Sub_Brand__c=subBrand.Id,
                                                                           recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF')));
        }
        
        insert ContractLineList;
        List<ASI_CRM_Methodology__c> MethodologyList= new List<ASI_CRM_Methodology__c> ();
        MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test1',ASI_CRM_Methodology_Code__c='01',ASI_CRM_Default__c=true,ASI_CRM_Chinese_Name__c='123',ASI_CRM_Type__c='BRSF',recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Methodology__cASI_CRM_CN_Methodology')));
        MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test2',ASI_CRM_Methodology_Code__c='01',ASI_CRM_Default__c=true,ASI_CRM_Chinese_Name__c='Test 123',ASI_CRM_Type__c='PSF',recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Methodology__cASI_CRM_CN_Methodology')));
        MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test3',ASI_CRM_Methodology_Code__c='01',ASI_CRM_Default__c=true,ASI_CRM_Chinese_Name__c='Test 123',ASI_CRM_Type__c='Variable Event Cost',recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Methodology__cASI_CRM_CN_Methodology')));
        
        
       // MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test1',ASI_CRM_Methodology_Code__c='01',ASI_CRM_Chinese_Name__c='123',ASI_CRM_Type__c='BRSF'));
       // MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test2',ASI_CRM_Methodology_Code__c='01',ASI_CRM_Chinese_Name__c='123',ASI_CRM_Type__c='PSF'));
       // MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test3',ASI_CRM_Methodology_Code__c='01',ASI_CRM_Chinese_Name__c='123',ASI_CRM_Type__c='Variable Event Cost'));
        insert MethodologyList;

        test.startTest();
        PageReference EnterPage = Page.ASI_CRM_CN_ViewHeavyContractPage2nd;
        Test.setCurrentPage(EnterPage);
        ApexPages.currentPage().getParameters().put('id', Contract2.id);
        ASI_CRM_CN_ViewHeavyContractCtrl con2 = new ASI_CRM_CN_ViewHeavyContractCtrl(new ApexPages.Standardcontroller(Contract2));

        ApexPages.currentPage().getParameters().put('id', Contract.id);
        
        
        ASI_CRM_CN_ViewHeavyContractCtrl con = new ASI_CRM_CN_ViewHeavyContractCtrl(new ApexPages.Standardcontroller(Contract));
        con.restorePO();
        con.POModification();
        con.ErrorHandling('Test');
        con.Calculation2nd();

        // User currentUser1 = [SELECT id, name, Managerid, ASI_CRM_CN_Prefix__c,LanguageLocaleKey FROM USER WHERE id =:UserInfo.getUserId()];
        // currentUser1.LanguageLocaleKey='en_US';
        // update currentUser1;
        // ASI_CRM_CN_ViewHeavyContractCtrl2nd con1 = new ASI_CRM_CN_ViewHeavyContractCtrl2nd(new ApexPages.Standardcontroller(Contract));


        test.stopTest(); 


    }

    static testMethod void ASI_CRM_CN_ViewHeavyContractCtrl2ndTest6() {
        
        //Test Class for ASI_CRM_CN_ViewHeavyContractCtrl-----> Test restore
        ASI_CRM_Region__c region = new ASI_CRM_Region__c (Name='Central Region',recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Region__cASI_CRM_CN_Region'));
        insert region;
        
        ASI_CRM_Division__c division = new ASI_CRM_Division__c(Name='TEST', ASI_CRM_Region__c=region.Id);
        insert division;
        
        ASI_CRM_CN_Area__c area = new ASI_CRM_CN_Area__c(Name='TEST', ASI_CRM_English_Name__c='TEST', ASI_CRM_Division__c=division.Id);
        insert area;
        
        ASI_CRM_City__c city = new ASI_CRM_City__c(Name='TEST', ASI_CRM_CN_Area__c=area.Id);
        insert city;
        
        /*ASI_CRM_CN_Channel__c channel = new ASI_CRM_CN_Channel__c(Name='KTV',ASI_CRM_BC_Rate__c=98,ASI_CRM_CN_On_Off__c='ON',ASI_CRM_For_Outlet__c=true,RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CN_Channel__cASI_CRM_CN_New_Channel'),ASI_CRM_For_Contract__c=TRUE);
        insert channel;*/
        
        ASI_CRM_CN_Channel__c channel = new ASI_CRM_CN_Channel__c(ASI_CRM_CN_On_Off__c='ON');
        insert channel;
        
        ASI_MFM_Sub_Channel__c subChannel = new ASI_MFM_Sub_Channel__c(ASI_CRM_CN_Channel__c=channel.Id);
        insert subChannel;
        
        ASI_CRM_CN_Channel__c newChannel = new ASI_CRM_CN_Channel__c(ASI_CRM_For_Outlet__c = true, Name='Restaurant',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CN_Channel__cASI_CRM_CN_New_Channel'),ASI_CRM_CN_On_Off__c='OFF');
        insert newChannel;
        
        
        Id rtWS = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_CN_WS');
        Id rtOutlet = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN');
        
        list<ASI_CRM_AccountsAdditionalField__c> Customers = new list<ASI_CRM_AccountsAdditionalField__c>();
        Customers.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Eng_Name__c = 'b', ASI_CRM_CN_Chi_Name__c = 'b', ASI_CRM_CN_Commercial_Team__c = 'Premium', ASI_CRM_CN_Sub_Channel__c=subChannel.Id, ASI_CRM_CN_CCity__c=city.Id, ASI_CRM_Latest_Call_Plan_Date__c=system.today(), RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN'), ASI_CRM_CN_NewChannel__c = newChannel.Id, ASI_CRM_CN_Type_of_Restaurant__c = 'International',ASI_CRM_CN_Spending_per_head__c=1));
        Customers.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Eng_Name__c = 'c', ASI_CRM_CN_Chi_Name__c = 'c', ASI_CRM_CN_Commercial_Team__c = 'Premium', ASI_CRM_CN_Sub_Channel__c=subChannel.Id, ASI_CRM_CN_CCity__c=city.Id, ASI_CRM_Latest_Call_Plan_Date__c=system.today(), RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN'), ASI_CRM_CN_NewChannel__c = newChannel.Id, ASI_CRM_CN_Type_of_Restaurant__c = 'International',ASI_CRM_CN_Spending_per_head__c=1));
        insert Customers;
        
        /*
        //Covered_Outlet
        list<ASI_CRM_AccountsAdditionalField__c> ChildCustomers = new list<ASI_CRM_AccountsAdditionalField__c>();
        ChildCustomers.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Parent_Outlet__c=Customers[1].Id,ASI_CRM_CN_Eng_Name__c = 'a', ASI_CRM_CN_Chi_Name__c = 'a', ASI_CRM_CN_Commercial_Team__c = 'Premium', ASI_CRM_CN_Sub_Channel__c=subChannel.Id, ASI_CRM_CN_CCity__c=city.Id, ASI_CRM_Latest_Call_Plan_Date__c=system.today(), RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN'), ASI_CRM_CN_NewChannel__c = newChannel.Id, ASI_CRM_CN_Type_of_Restaurant__c = 'International',ASI_CRM_CN_Spending_per_head__c=1));
        insert ChildCustomers;
        
        
        // list<ASI_CRM_AccountsAdditionalField__c> ChildChildCustomers = new list<ASI_CRM_AccountsAdditionalField__c>();
        //ChildChildCustomers.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Parent_Outlet__c=ChildCustomers[0].Id,ASI_CRM_CN_Commercial_Team__c = 'Premium',RecordTypeId=rtOutlet,Name='TEST', ASI_CRM_CN_Image__c='Iconic',ASI_CRM_CN_CCity__c=city.Id,ASI_CRM_CN_NewChannel__c=channel.Id));
        //insert ChildChildCustomers;
        
        //ASI_CRM_CN_Parent_Outlet__c
        */
        User currentUser = [SELECT id, name, Managerid, ASI_CRM_CN_Prefix__c FROM USER WHERE id =:UserInfo.getUserId()];

        
        list<ASI_HK_CRM_Running_Number__c> rns = new list<ASI_HK_CRM_Running_Number__c>();
        rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_TH_CRM_Contract__c', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_TH_CRM_PaymentRequest__c', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        if(!String.isBlank(currentUser.ASI_CRM_CN_Prefix__c))
            rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_'+currentUser.ASI_CRM_CN_Prefix__c, recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        else{
            rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_NULL', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
            rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        }
        insert rns;
        
        //Sub Brand Grade
        //
        
        list<ASI_CRM_Sub_Brand_Grade__c> grades = new list<ASI_CRM_Sub_Brand_Grade__c>();
        grades.add(new ASI_CRM_Sub_Brand_Grade__c (Name='TEST1'));
        grades.add(new ASI_CRM_Sub_Brand_Grade__c (Name='TEST2'));
        grades.add(new ASI_CRM_Sub_Brand_Grade__c (Name='TEST3'));
        insert grades;
        
        
        list<ASI_MFM_Sub_brand__c> subBrands = new list<ASI_MFM_Sub_brand__c>();
        for(ASI_CRM_Sub_Brand_Grade__c grade :grades) {
            subBrands.add(new ASI_MFM_Sub_brand__c (Name='TEST1',ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,RecordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand'),
                                                    ASI_CRM_CN_Sub_brand_Grade__c=grade.Id));
            subBrands.add(new ASI_MFM_Sub_brand__c (Name='TEST2',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand'),
                                                    ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,
                                                    ASI_CRM_CN_Sub_brand_Grade__c=grade.Id));
            subBrands.add(new ASI_MFM_Sub_brand__c ( Name='TEST3',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand'),
                                                    ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,
                                                    ASI_CRM_CN_Sub_brand_Grade__c=grade.Id));
            subBrands.add(new ASI_MFM_Sub_brand__c ( Name='999',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand'),
                                                    ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,ASI_MFM_Sub_brand_Code__c = '999' ,ASI_MFM_Active_for_CRM__c = true ,
                                                    ASI_CRM_CN_Sub_brand_Grade__c=grade.Id));
        }
        insert subBrands;

        List<ASI_MFM_A_C_Code__c> ACCodeList = new  List<ASI_MFM_A_C_Code__c>();
        ACCodeList.add(new ASI_MFM_A_C_Code__c( Name='0000000000000', ASI_MFM_A_C_Code__c='000010000',ASI_MFM_A_C_Description__c='ASI_CRM_CN_Variable_Cost_Contract',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_CN_A_C_Code') ));
        ACCodeList.add(new ASI_MFM_A_C_Code__c( Name='5275.010000 PRC - Bottle Return Service', ASI_MFM_A_C_Code__c='5275.010000',ASI_MFM_A_C_Description__c='Bottle Return Service',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_CN_A_C_Code') ));
        ACCodeList.add(new ASI_MFM_A_C_Code__c( Name='5275.020000 Promotion Service Fee', ASI_MFM_A_C_Code__c='5275.020000',ASI_MFM_A_C_Description__c='Promotion Service Fee',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_CN_A_C_Code') ));
        ACCodeList.add(new ASI_MFM_A_C_Code__c( Name='5275.030000 PRC - Variable Event Cost', ASI_MFM_A_C_Code__c='5275.030000',ASI_MFM_A_C_Description__c='Variable Event Cost',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_CN_A_C_Code') ));
        ACCodeList.add(new ASI_MFM_A_C_Code__c( Name='5275.040000 PRC - Fixed Event Cost',ASI_MFM_A_C_CN_Description__c='夜店活动费用(固定)', ASI_MFM_A_C_Code__c='5275.040000',ASI_MFM_A_C_Description__c='PRC - Fixed Event Cost',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_CN_A_C_Code') ));

        ACCodeList.add(new ASI_MFM_A_C_Code__c( Name='5260.100000 PRC - Store/Outlet Support',ASI_MFM_A_C_CN_Description__c='店家支持', ASI_MFM_A_C_Code__c='5260.100000',ASI_MFM_A_C_Description__c='PRC - Store/Outlet Support',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_CN_A_C_Code') ));
        
        insert ACCodeList;
        
        List<ASI_CRM_Contract_Cost_Setting__c> ContractCostSettingList= new List<ASI_CRM_Contract_Cost_Setting__c>();

        ContractCostSettingList.add(new ASI_CRM_Contract_Cost_Setting__c(ASI_CRM_CN_Activity_Code__c=ACCodeList[4].Id,ASI_CRM_CN_Promotion_Type__c='Heavy Contract ON',
                                                                         ASI_CRM_CN_Fixed_Cost_Contract__c=true,ASI_CRM_CN_Variable_Cost_Contract__c=false));

        ContractCostSettingList.add(new ASI_CRM_Contract_Cost_Setting__c(ASI_CRM_CN_Activity_Code__c=ACCodeList[5].Id,ASI_CRM_CN_Promotion_Type__c='Heavy Contract ON',
                                                                         ASI_CRM_CN_Fixed_Cost_Contract__c=true,ASI_CRM_CN_Variable_Cost_Contract__c=false));

        insert ContractCostSettingList;
        
        Date PO_Start_Date = date.newinstance(system.today().year(), system.today().month(), 1);
        Date PO_End_Date = PO_Start_Date.addMonths(1)-1;
        
        ASI_TH_CRM_Contract__c Contract2 = new ASI_TH_CRM_Contract__c(recordtypeid = Global_RecordTypeCache.getRTID('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract'),ASI_CRM_CN_Is_2nd_KPI_PO__c=true,
                                                                      ASI_CRM_CN_Status__c = 'Archived',
                                                                      ASI_CRM_CN_PO_Start_Date__c = PO_Start_Date,
                                                                      ASI_CRM_CN_PO_End_Date__c =PO_End_Date,
                                                                      ASI_CRM_CN_PO_Version__c = '0.0',ASI_TH_CRM_Promotion_Type__c='Heavy Contract On',
                                                                      Name = 'Contract1',
                                                                      ASI_CRM_CN_Outlet_WS__c=Customers[1].Id,ASI_CRM_Volume_Option__c = 'Normal');
        insert Contract2;
        
        ASI_TH_CRM_Contract__c Contract = new ASI_TH_CRM_Contract__c(recordtypeid = Global_RecordTypeCache.getRTID('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract'),ASI_CRM_CN_Is_2nd_KPI_PO__c=true,
                                                                     ASI_CRM_CN_Status__c = 'Draft',
                                                                     ASI_CRM_CN_PO_Start_Date__c = PO_Start_Date,
                                                                     ASI_CRM_CN_PO_End_Date__c =PO_End_Date,
                                                                     ASI_CRM_CN_CTD_Monthly_Default_Date__c=Date.today(),ASI_CRM_CN_V0_0_PO_version__c=Contract2.Id,ASI_CRM_CN_Last_PO_version__c=Contract2.Id,
                                                                     ASI_CRM_CN_PO_Version__c = '0.1',ASI_TH_CRM_Promotion_Type__c='Heavy Contract On',
                                                                     Name = 'Contract2',
                                                                     ASI_CRM_CN_Outlet_WS__c=Customers[1].Id,ASI_CRM_Volume_Option__c = 'Normal');
        insert Contract;
        
        
        List<ASI_CRM_Module__c> ModuleList = new List<ASI_CRM_Module__c>();
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='Std. Btl.',ASI_CRM_Volume_Base__c='By Sub-Brand',ASI_CRM_Line_Type__c='BRSF'));
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='Std. Btl.',ASI_CRM_Volume_Base__c='By Sub-Brand',ASI_CRM_Line_Type__c='PSF'));
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='CR12 Extra Eqv.',ASI_CRM_Volume_Base__c='By Grade',ASI_CRM_Line_Type__c='PSF'));
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='CR12 Extra Eqv.',ASI_CRM_Volume_Base__c='By Category',ASI_CRM_Line_Type__c='PSF'));
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='CR12 Extra Eqv.',ASI_CRM_Volume_Base__c='By Total',ASI_CRM_Line_Type__c='PSF'));
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='CR12 Extra Eqv.',ASI_CRM_Volume_Base__c='By Sub-Brand',ASI_CRM_Line_Type__c='Variable Event Cost'));

        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='Std. Btl.',ASI_CRM_Volume_Base__c='By Sub-Brand',ASI_CRM_Line_Type__c='Fixed',ASI_CRM_CN_AC_Code__c = ACCodeList[4].Id, ASI_CRM_CN_AC_Code__r = ACCodeList[4]));
        
        insert ModuleList;
        /*
        ASI_CRM_Contract_Cost__c contractCost = new ASI_CRM_Contract_Cost__c(ASI_CRM_CN_Contract__c = Contract.id,
                                                                             ASI_CRM_CN_Estimate_Amount__c = 100000,
                                                                             ASI_CRM_CN_Cost_Type__c = 'Variable',
                                                                             ASI_CRM_CN_Other_Cost_Payment_Request__c = true,
                                                                             recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_Contract_Cost__cASI_CRM_CN_Contract_Cost') );
        insert contractCost;
        */
        list<ASI_CRM_CN_Contract_BRSF_Line_Item__c> ContractLineList = new list<ASI_CRM_CN_Contract_BRSF_Line_Item__c>();
        list<ASI_CRM_CN_Covered_Outlet__c> cos = new list<ASI_CRM_CN_Covered_Outlet__c>();
        for(ASI_MFM_Sub_brand__c subBrand :subBrands) {
            ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract.Id,
                                                                           ASI_CRM_CN_Est_Monthly_Qty__c=1,ASI_CRM_Module__c=ModuleList[0].Id,
                                                                           ASI_CRM_CN_Contract_Monthly_Qty__c=1,
                                                                           ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,
                                                                           ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,ASI_CRM_Type__c='BRSF',
                                                                           ASI_CRM_CN_Sub_Brand__c=subBrand.Id,
                                                                           recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF')));
        }
        for(ASI_MFM_Sub_brand__c subBrand :subBrands) {
            ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract.Id,
                                                                           ASI_CRM_CN_Est_Monthly_Qty__c=1,ASI_CRM_Module__c=ModuleList[1].Id,
                                                                           ASI_CRM_CN_Contract_Monthly_Qty__c=1,ASI_CRM_Volume_Base__c='By Sub-Brand',
                                                                           ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,
                                                                           ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,ASI_CRM_Type__c='PSF',
                                                                           ASI_CRM_CN_Sub_Brand__c=subBrand.Id,
                                                                           recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF')));
        }
        ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract.Id,ASI_CRM_Type__c='PSF',ASI_CRM_Volume_Base__c='By Grade',
                                                                       ASI_CRM_CN_Est_Monthly_Qty__c=4,ASI_CRM_Module__c=ModuleList[2].Id,
                                                                       ASI_CRM_CN_Contract_Monthly_Qty__c=4,ASI_CRM_Sub_Brand_Grade__c=grades[0].Id,
                                                                       ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,
                                                                       ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,
                                                                       ASI_CRM_CN_Sub_Brand__c=null,
                                                                       recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF') ));
        ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract.Id,ASI_CRM_Type__c='PSF',ASI_CRM_Volume_Base__c='By Total',
                                                                       ASI_CRM_CN_Est_Monthly_Qty__c=4,ASI_CRM_Module__c=ModuleList[4].Id,
                                                                       ASI_CRM_CN_Contract_Monthly_Qty__c=4,
                                                                       ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,
                                                                       ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,
                                                                       ASI_CRM_CN_Sub_Brand__c=null,
                                                                       recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF') ));
        for(ASI_MFM_Sub_brand__c subBrand :subBrands) {
            ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract.Id,
                                                                           ASI_CRM_CN_Est_Monthly_Qty__c=1,ASI_CRM_Module__c=ModuleList[6].Id,
                                                                           ASI_CRM_CN_Contract_Monthly_Qty__c=1,ASI_CRM_Volume_Base__c='By Sub-Brand',
                                                                           ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,ASI_CRM_CN_Activity_Code__r=ACCodeList[4],ASI_CRM_CN_Activity_Code__c=ACCodeList[4].Id,
                                                                           ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,ASI_CRM_Type__c='Fixed',
                                                                           ASI_CRM_CN_Sub_Brand__c=subBrand.Id,
                                                                           recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF')));
            ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract2.Id,
                                                                           ASI_CRM_CN_Est_Monthly_Qty__c=1,ASI_CRM_Module__c=ModuleList[6].Id,
                                                                           ASI_CRM_CN_Contract_Monthly_Qty__c=1,ASI_CRM_Volume_Base__c='By Sub-Brand',
                                                                           ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,ASI_CRM_CN_Activity_Code__r=ACCodeList[4],ASI_CRM_CN_Activity_Code__c=ACCodeList[4].Id,
                                                                           ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,ASI_CRM_Type__c='Fixed',
                                                                           ASI_CRM_CN_Sub_Brand__c=subBrand.Id,
                                                                           recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF')));
        }
        for(ASI_MFM_Sub_brand__c subBrand :subBrands) {
            ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract.Id,
                                                                           ASI_CRM_CN_Est_Monthly_Qty__c=1,ASI_CRM_Module__c=ModuleList[5].Id,
                                                                           ASI_CRM_CN_Contract_Monthly_Qty__c=1,ASI_CRM_Volume_Base__c='By Sub-Brand',
                                                                           ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,
                                                                           ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,ASI_CRM_Type__c='Variable Event Cost',
                                                                           ASI_CRM_CN_Sub_Brand__c=subBrand.Id,
                                                                           recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF')));
        }
        
        insert ContractLineList;
        List<ASI_CRM_Methodology__c> MethodologyList= new List<ASI_CRM_Methodology__c> ();
        MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test1',ASI_CRM_Methodology_Code__c='01',ASI_CRM_Default__c=true,ASI_CRM_Chinese_Name__c='123',ASI_CRM_Type__c='BRSF',recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Methodology__cASI_CRM_CN_Methodology')));
        MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test2',ASI_CRM_Methodology_Code__c='01',ASI_CRM_Default__c=true,ASI_CRM_Chinese_Name__c='Test 123',ASI_CRM_Type__c='PSF',recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Methodology__cASI_CRM_CN_Methodology')));
        MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test3',ASI_CRM_Methodology_Code__c='01',ASI_CRM_Default__c=true,ASI_CRM_Chinese_Name__c='Test 123',ASI_CRM_Type__c='Variable Event Cost',recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Methodology__cASI_CRM_CN_Methodology')));
        
        
       // MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test1',ASI_CRM_Methodology_Code__c='01',ASI_CRM_Chinese_Name__c='123',ASI_CRM_Type__c='BRSF'));
       // MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test2',ASI_CRM_Methodology_Code__c='01',ASI_CRM_Chinese_Name__c='123',ASI_CRM_Type__c='PSF'));
       // MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test3',ASI_CRM_Methodology_Code__c='01',ASI_CRM_Chinese_Name__c='123',ASI_CRM_Type__c='Variable Event Cost'));
        insert MethodologyList;


        test.startTest();
        PageReference EnterPage1 = Page.ASI_CRM_CN_ViewHeavyContractPage2nd;
        Test.setCurrentPage(EnterPage1);
        User currentUser1 = [SELECT id, name, Managerid, ASI_CRM_CN_Prefix__c,LanguageLocaleKey FROM USER WHERE id =:UserInfo.getUserId()];
        currentUser1.LanguageLocaleKey='en_US';
        update currentUser1;
        ApexPages.currentPage().getParameters().put('id', Contract2.id);
        ASI_CRM_CN_ViewHeavyContractCtrl con2 = new ASI_CRM_CN_ViewHeavyContractCtrl(new ApexPages.Standardcontroller(Contract2));

        ApexPages.currentPage().getParameters().put('id', Contract.id);
        ASI_CRM_CN_ViewHeavyContractCtrl con1 = new ASI_CRM_CN_ViewHeavyContractCtrl(new ApexPages.Standardcontroller(Contract));


        test.stopTest();


    }


    static testMethod void ASI_CRM_CN_ViewHeavyContractCtrl2ndTest1() {
        //Test Class for ASI_CRM_CN_ViewHeavyContractCtrl
        ASI_CRM_Region__c region = new ASI_CRM_Region__c (Name='Central Region',recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Region__cASI_CRM_CN_Region'));
        insert region;
        
        ASI_CRM_Division__c division = new ASI_CRM_Division__c(Name='TEST', ASI_CRM_Region__c=region.Id);
        insert division;
        
        ASI_CRM_CN_Area__c area = new ASI_CRM_CN_Area__c(Name='TEST', ASI_CRM_English_Name__c='TEST', ASI_CRM_Division__c=division.Id);
        insert area;
        
        ASI_CRM_City__c city = new ASI_CRM_City__c(Name='TEST', ASI_CRM_CN_Area__c=area.Id);
        insert city;
        
        /*ASI_CRM_CN_Channel__c channel = new ASI_CRM_CN_Channel__c(Name='KTV',ASI_CRM_BC_Rate__c=98,ASI_CRM_CN_On_Off__c='ON',ASI_CRM_For_Outlet__c=true,RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CN_Channel__cASI_CRM_CN_New_Channel'),ASI_CRM_For_Contract__c=TRUE);
        insert channel;*/
                
                ASI_CRM_CN_Channel__c channel = new ASI_CRM_CN_Channel__c(ASI_CRM_CN_On_Off__c='ON');
                insert channel;
                
                Id rtWS = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_CN_WS');
                Id rtOutlet = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN');
                
                /*list<ASI_CRM_AccountsAdditionalField__c> Customers = new list<ASI_CRM_AccountsAdditionalField__c>();
        Customers.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Commercial_Team__c = 'Premium',RecordTypeId=rtWS,Name='TEST', ASI_CRM_CN_Image__c='Iconic',ASI_CRM_CN_CCity__c=city.Id,ASI_CRM_CN_NewChannel__c=channel.Id));
        Customers.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Commercial_Team__c = 'Premium',RecordTypeId=rtOutlet,Name='TEST', ASI_CRM_CN_Image__c='Iconic',ASI_CRM_CN_CCity__c=city.Id,ASI_CRM_CN_NewChannel__c=channel.Id));
        insert Customers;

        //Covered_Outlet
        list<ASI_CRM_AccountsAdditionalField__c> ChildCustomers = new list<ASI_CRM_AccountsAdditionalField__c>();
        ChildCustomers.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Parent_Outlet__c=Customers[1].Id,ASI_CRM_CN_Commercial_Team__c = 'Premium',RecordTypeId=rtOutlet,Name='TEST', ASI_CRM_CN_Image__c='Iconic',ASI_CRM_CN_CCity__c=city.Id,ASI_CRM_CN_NewChannel__c=channel.Id));
        insert ChildCustomers;*/
        
        ASI_MFM_Sub_Channel__c subChannel = new ASI_MFM_Sub_Channel__c(ASI_CRM_CN_Channel__c=channel.Id);
        insert subChannel;
        
        ASI_CRM_CN_Channel__c newChannel = new ASI_CRM_CN_Channel__c(ASI_CRM_For_Outlet__c = true, Name='Restaurant',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CN_Channel__cASI_CRM_CN_New_Channel'),ASI_CRM_CN_On_Off__c='OFF');
        insert newChannel;
        
        list<ASI_CRM_AccountsAdditionalField__c> Customers = new list<ASI_CRM_AccountsAdditionalField__c>();
        Customers.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Eng_Name__c = 'b', ASI_CRM_CN_Chi_Name__c = 'b', ASI_CRM_CN_Commercial_Team__c = 'Premium', ASI_CRM_CN_Sub_Channel__c=subChannel.Id, ASI_CRM_CN_CCity__c=city.Id, ASI_CRM_Latest_Call_Plan_Date__c=system.today(), RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN'), ASI_CRM_CN_NewChannel__c = newChannel.Id, ASI_CRM_CN_Type_of_Restaurant__c = 'International',ASI_CRM_CN_Spending_per_head__c=1));
        Customers.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Eng_Name__c = 'c', ASI_CRM_CN_Chi_Name__c = 'c', ASI_CRM_CN_Commercial_Team__c = 'Premium', ASI_CRM_CN_Sub_Channel__c=subChannel.Id, ASI_CRM_CN_CCity__c=city.Id, ASI_CRM_Latest_Call_Plan_Date__c=system.today(), RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN'), ASI_CRM_CN_NewChannel__c = newChannel.Id, ASI_CRM_CN_Type_of_Restaurant__c = 'International',ASI_CRM_CN_Spending_per_head__c=1));
        insert Customers;
        
        
        list<ASI_CRM_AccountsAdditionalField__c> ChildCustomers = new list<ASI_CRM_AccountsAdditionalField__c>();
        ChildCustomers.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Parent_Outlet__c=Customers[1].Id,ASI_CRM_CN_Eng_Name__c = 'a', ASI_CRM_CN_Chi_Name__c = 'a', ASI_CRM_CN_Commercial_Team__c = 'Premium', ASI_CRM_CN_Sub_Channel__c=subChannel.Id, ASI_CRM_CN_CCity__c=city.Id, ASI_CRM_Latest_Call_Plan_Date__c=system.today(), RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN'), ASI_CRM_CN_NewChannel__c = newChannel.Id, ASI_CRM_CN_Type_of_Restaurant__c = 'International',ASI_CRM_CN_Spending_per_head__c=1));
        insert ChildCustomers;
        
        // list<ASI_CRM_AccountsAdditionalField__c> ChildChildCustomers = new list<ASI_CRM_AccountsAdditionalField__c>();
        //ChildChildCustomers.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Parent_Outlet__c=ChildCustomers[0].Id,ASI_CRM_CN_Commercial_Team__c = 'Premium',RecordTypeId=rtOutlet,Name='TEST', ASI_CRM_CN_Image__c='Iconic',ASI_CRM_CN_CCity__c=city.Id,ASI_CRM_CN_NewChannel__c=channel.Id));
        //insert ChildChildCustomers;
        
        //ASI_CRM_CN_Parent_Outlet__c
        
        User currentUser = [SELECT id, name, Managerid, ASI_CRM_CN_Prefix__c FROM USER WHERE id =:UserInfo.getUserId()];
        
        list<ASI_HK_CRM_Running_Number__c> rns = new list<ASI_HK_CRM_Running_Number__c>();
        rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_TH_CRM_Contract__c', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_TH_CRM_PaymentRequest__c', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        if(!String.isBlank(currentUser.ASI_CRM_CN_Prefix__c))
            rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_'+currentUser.ASI_CRM_CN_Prefix__c, recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        else{
            rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_NULL', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
            rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        }
        insert rns;
        
        //Sub Brand Grade
        //
        list<ASI_CRM_Sub_Brand_Grade__c> grades = new list<ASI_CRM_Sub_Brand_Grade__c>();
        grades.add(new ASI_CRM_Sub_Brand_Grade__c (Name='Premium',ASI_CRM_Chinese_Name__c='Test1',ASI_CRM_Chinese_Description__c='1. Standard + Premium 标准档 + 高档',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_Sub_Brand_Grade__cASI_CRM_CN_Sub_brand_Grade')));
        grades.add(new ASI_CRM_Sub_Brand_Grade__c (Name='TEST2',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_Sub_Brand_Grade__cASI_CRM_CN_Sub_brand_Grade')));
        grades.add(new ASI_CRM_Sub_Brand_Grade__c (Name='TEST3',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_Sub_Brand_Grade__cASI_CRM_CN_Sub_brand_Grade')));
        insert grades;
        
        
        list<ASI_MFM_Sub_brand__c> subBrands = new list<ASI_MFM_Sub_brand__c>();
        for(ASI_CRM_Sub_Brand_Grade__c grade :grades) {
            subBrands.add(new ASI_MFM_Sub_brand__c (Name='TEST1',ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,RecordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand'),
                                                    ASI_CRM_CN_Sub_brand_Grade__c=grade.Id));
            subBrands.add(new ASI_MFM_Sub_brand__c (Name='TEST2',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand'),
                                                    ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,
                                                    ASI_CRM_CN_Sub_brand_Grade__c=grade.Id));
            subBrands.add(new ASI_MFM_Sub_brand__c ( Name='TEST3',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand'),
                                                    ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,
                                                    ASI_CRM_CN_Sub_brand_Grade__c=grade.Id));
            subBrands.add(new ASI_MFM_Sub_brand__c ( Name='999',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand'),
                                                    ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,ASI_MFM_Sub_brand_Code__c = '999' ,ASI_MFM_Active_for_CRM__c = true ,
                                                    ASI_CRM_CN_Sub_brand_Grade__c=grade.Id));
        }
        insert subBrands;
        
        
        Date PO_Start_Date = date.newinstance(system.today().year(), system.today().month(), 1);
        Date PO_End_Date = PO_Start_Date.addMonths(1)-1;
        
        ASI_TH_CRM_Contract__c Contract = new ASI_TH_CRM_Contract__c(recordtypeid = Global_RecordTypeCache.getRTID('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract'),ASI_CRM_CN_Is_2nd_KPI_PO__c=true,
                                                                     ASI_CRM_CN_Status__c = 'Final',
                                                                     ASI_CRM_CN_PO_Start_Date__c = PO_Start_Date,
                                                                     ASI_CRM_CN_PO_End_Date__c =PO_End_Date,
                                                                     ASI_CRM_CN_PO_Version__c = '0.0',ASI_TH_CRM_Promotion_Type__c='Heavy Contract On',
                                                                     Name = 'Contract1',
                                                                     ASI_CRM_CN_Outlet_WS__c=Customers[1].Id,ASI_CRM_Volume_Option__c = 'Normal');
        insert Contract;
        /*
        List<ASI_CRM_Module__c> ModuleList = new List<ASI_CRM_Module__c>();
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='Std. Btl.',ASI_CRM_Volume_Base__c='By Sub-Brand',ASI_CRM_Line_Type__c='BRSF'));
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='Std. Btl.',ASI_CRM_Volume_Base__c='By Sub-Brand',ASI_CRM_Line_Type__c='PSF'));
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='CR12 Extra Eqv.',ASI_CRM_Volume_Base__c='By Grade',ASI_CRM_Line_Type__c='PSF'));
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='CR12 Extra Eqv.',ASI_CRM_Volume_Base__c='By Total',ASI_CRM_Line_Type__c='PSF'));
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='CR12 Extra Eqv.',ASI_CRM_Volume_Base__c='By Total',ASI_CRM_Line_Type__c='Variable Event Cost'));
        
        insert ModuleList;
        */
        ASI_CRM_Contract_Cost__c contractCost = new ASI_CRM_Contract_Cost__c(ASI_CRM_CN_Contract__c = Contract.id,
                                                                             ASI_CRM_CN_Estimate_Amount__c = 100000,
                                                                             ASI_CRM_CN_Cost_Type__c = 'Fixed',
                                                                             ASI_CRM_CN_Other_Cost_Payment_Request__c = true,
                                                                             recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_Contract_Cost__cASI_CRM_CN_Contract_Cost') );
        insert contractCost;
        /*
        list<ASI_CRM_CN_Contract_BRSF_Line_Item__c> ContractLineList = new list<ASI_CRM_CN_Contract_BRSF_Line_Item__c>();
        list<ASI_CRM_CN_Covered_Outlet__c> cos = new list<ASI_CRM_CN_Covered_Outlet__c>();
        for(ASI_MFM_Sub_brand__c subBrand :subBrands) {
            ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract.Id,
                                                                           ASI_CRM_CN_Est_Monthly_Qty__c=1,ASI_CRM_Module__c=ModuleList[0].Id,
                                                                           ASI_CRM_CN_Contract_Monthly_Qty__c=1,
                                                                           ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,
                                                                           ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,ASI_CRM_Type__c='BRSF',
                                                                           ASI_CRM_CN_Sub_Brand__c=subBrand.Id,
                                                                           recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF')));
        }
        ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract.Id,ASI_CRM_Type__c='PSF',ASI_CRM_Volume_Base__c='By Sub-Brand',
                                                                       ASI_CRM_CN_Est_Monthly_Qty__c=1,ASI_CRM_Module__c=ModuleList[1].Id,
                                                                       ASI_CRM_CN_Contract_Monthly_Qty__c=1,
                                                                       ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,
                                                                       ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,
                                                                       ASI_CRM_CN_Sub_Brand__c=subBrands[0].Id,
                                                                       recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF') ));
        ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract.Id,ASI_CRM_Type__c='PSF',ASI_CRM_Volume_Base__c='By Grade',
                                                                       ASI_CRM_CN_Est_Monthly_Qty__c=1,ASI_CRM_Module__c=ModuleList[2].Id,
                                                                       ASI_CRM_CN_Contract_Monthly_Qty__c=1,ASI_CRM_Sub_Brand_Grade__c=grades[0].Id,
                                                                       ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,
                                                                       ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,
                                                                       ASI_CRM_CN_Sub_Brand__c=null,
                                                                       recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF') ));
        ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract.Id,ASI_CRM_Type__c='PSF',ASI_CRM_Volume_Base__c='By Total',
                                                                       ASI_CRM_CN_Est_Monthly_Qty__c=1,ASI_CRM_Module__c=ModuleList[3].Id,
                                                                       ASI_CRM_CN_Contract_Monthly_Qty__c=1,
                                                                       ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,
                                                                       ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,
                                                                       ASI_CRM_CN_Sub_Brand__c=null,
                                                                       recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF') ));
        
        ContractLineList.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=Contract.Id,ASI_CRM_Type__c='Variable Event Cost',ASI_CRM_Volume_Base__c='By Total',
                                                                       
                                                                       ASI_CRM_CN_Contract_Monthly_Qty__c=1,
                                                                       ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,
                                                                       ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,
                                                                       ASI_CRM_CN_Sub_Brand__c=null,
                                                                       recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF') ));
        insert ContractLineList;
        */
        
        test.startTest();
        
        
        PageReference EnterPage = Page.ASI_CRM_CN_ViewHeavyContractPage;
        
        Map<String, String> pageParams = EnterPage.getParameters();
        
        pageParams.put('id', Contract.id);
        ApexPages.StandardController sc = new ApexPages.standardController(new ASI_TH_CRM_Contract__c());
        
        ASI_CRM_CN_ViewHeavyContractCtrl con = new ASI_CRM_CN_ViewHeavyContractCtrl(new ApexPages.Standardcontroller(Contract));
        con.ContractSelected.ASI_CRM_Contract_Template_Id__c = '1111';
        con.ContractSelected.ASI_CRM_CN_Expected_BRSF_Est_Total__c=10;
        con.ContractSelected.ASI_CRM_EVC_Cost_Estimate_Total__c=100;
        con.AddAllChildOutlets();
        con.SaveItems();
        
        con.AddNew_CoveredOutlet();
        con.GoEditDetailPage();
        con.GoCheckPointPage();
        con.GoEditHeaderPage();
        con.ViewCheckPointPage();
        con.GoEditDetailPage();
        con.POModification();
        con.GoPayment();
        con.GoReturn();
        con.UploadCompletion();
        con.Calculation2nd();
        con.UncheckContractUploading();
        con.SetToFinal();
        con.CancelProcess();
        con.restorePO();
        con.GoToContractGenerationPage();
        con.SetToDraft();
        test.stopTest(); 
    }

    static testMethod void ASI_CRM_CN_ViewHeavyContractCtrl2ndTest2() {
        //Test Class for ASI_CRM_CN_ViewHeavyContractCtrl
        ASI_CRM_Region__c region = new ASI_CRM_Region__c (Name='Central Region',recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Region__cASI_CRM_CN_Region'));
        insert region;
        
        ASI_CRM_Division__c division = new ASI_CRM_Division__c(Name='TEST', ASI_CRM_Region__c=region.Id);
        insert division;
        
        ASI_CRM_CN_Area__c area = new ASI_CRM_CN_Area__c(Name='TEST', ASI_CRM_English_Name__c='TEST', ASI_CRM_Division__c=division.Id);
        insert area;
        
        ASI_CRM_City__c city = new ASI_CRM_City__c(Name='TEST', ASI_CRM_CN_Area__c=area.Id);
        insert city;
        
        
        /*ASI_CRM_CN_Channel__c channel = new ASI_CRM_CN_Channel__c(Name='KTV',ASI_CRM_BC_Rate__c=98,ASI_CRM_CN_On_Off__c='ON',ASI_CRM_For_Outlet__c=true,RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CN_Channel__cASI_CRM_CN_New_Channel'),ASI_CRM_For_Contract__c=TRUE);
        insert channel;*/
                
                ASI_CRM_CN_Channel__c channel = new ASI_CRM_CN_Channel__c(ASI_CRM_CN_On_Off__c='ON');
                insert channel;
                
                Id rtWS = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_CN_WS');
                Id rtOutlet = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN');
                
                /*list<ASI_CRM_AccountsAdditionalField__c> Customers = new list<ASI_CRM_AccountsAdditionalField__c>();
        Customers.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Commercial_Team__c = 'Premium',RecordTypeId=rtWS,Name='TEST', ASI_CRM_CN_Image__c='Iconic',ASI_CRM_CN_CCity__c=city.Id,ASI_CRM_CN_NewChannel__c=channel.Id));
        Customers.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Commercial_Team__c = 'Premium',RecordTypeId=rtOutlet,Name='TEST', ASI_CRM_CN_Image__c='Iconic',ASI_CRM_CN_CCity__c=city.Id,ASI_CRM_CN_NewChannel__c=channel.Id));
        insert Customers;*/
        
        ASI_MFM_Sub_Channel__c subChannel = new ASI_MFM_Sub_Channel__c(ASI_CRM_CN_Channel__c=channel.Id);
        insert subChannel;
        
        ASI_CRM_CN_Channel__c newChannel = new ASI_CRM_CN_Channel__c(ASI_CRM_For_Outlet__c = true, Name='Restaurant',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CN_Channel__cASI_CRM_CN_New_Channel'),ASI_CRM_CN_On_Off__c='OFF');
        insert newChannel;
        
        list<ASI_CRM_AccountsAdditionalField__c> Customers = new list<ASI_CRM_AccountsAdditionalField__c>();
        Customers.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Eng_Name__c = 'b', ASI_CRM_CN_Chi_Name__c = 'b', ASI_CRM_CN_Commercial_Team__c = 'Premium', ASI_CRM_CN_Sub_Channel__c=subChannel.Id, ASI_CRM_CN_CCity__c=city.Id, ASI_CRM_Latest_Call_Plan_Date__c=system.today(), RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN'), ASI_CRM_CN_NewChannel__c = newChannel.Id, ASI_CRM_CN_Type_of_Restaurant__c = 'International',ASI_CRM_CN_Spending_per_head__c=1));
        Customers.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Eng_Name__c = 'c', ASI_CRM_CN_Chi_Name__c = 'c', ASI_CRM_CN_Commercial_Team__c = 'Premium', ASI_CRM_CN_Sub_Channel__c=subChannel.Id, ASI_CRM_CN_CCity__c=city.Id, ASI_CRM_Latest_Call_Plan_Date__c=system.today(), RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN'), ASI_CRM_CN_NewChannel__c = newChannel.Id, ASI_CRM_CN_Type_of_Restaurant__c = 'International',ASI_CRM_CN_Spending_per_head__c=1));
        insert Customers;
        
        list<ASI_CRM_AccountsAdditionalField__c> ChildCustomers = new list<ASI_CRM_AccountsAdditionalField__c>();
        ChildCustomers.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Parent_Outlet__c=Customers[1].Id,ASI_CRM_CN_Eng_Name__c = 'a', ASI_CRM_CN_Chi_Name__c = 'a', ASI_CRM_CN_Commercial_Team__c = 'Premium', ASI_CRM_CN_Sub_Channel__c=subChannel.Id, ASI_CRM_CN_CCity__c=city.Id, ASI_CRM_Latest_Call_Plan_Date__c=system.today(), RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN'), ASI_CRM_CN_NewChannel__c = newChannel.Id, ASI_CRM_CN_Type_of_Restaurant__c = 'International',ASI_CRM_CN_Spending_per_head__c=1));
        insert ChildCustomers;
        
        User currentUser = [SELECT id, name, Managerid, ASI_CRM_CN_Prefix__c FROM USER WHERE id =:UserInfo.getUserId()];
        
        list<ASI_HK_CRM_Running_Number__c> rns = new list<ASI_HK_CRM_Running_Number__c>();
        rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_TH_CRM_Contract__c', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_TH_CRM_PaymentRequest__c', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        if(!String.isBlank(currentUser.ASI_CRM_CN_Prefix__c))
            rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_'+currentUser.ASI_CRM_CN_Prefix__c, recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        else{
            rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_NULL', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
            rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        }
        insert rns;
        
        //Sub Brand Grade
        list<ASI_CRM_Sub_Brand_Grade__c> grades = new list<ASI_CRM_Sub_Brand_Grade__c>();
        grades.add(new ASI_CRM_Sub_Brand_Grade__c (Name='TEST1'));
        grades.add(new ASI_CRM_Sub_Brand_Grade__c (Name='TEST2'));
        grades.add(new ASI_CRM_Sub_Brand_Grade__c (Name='TEST3'));
        insert grades;
        
        
        list<ASI_MFM_Sub_brand__c> subBrands = new list<ASI_MFM_Sub_brand__c>();
        for(ASI_CRM_Sub_Brand_Grade__c grade :grades) {
            subBrands.add(new ASI_MFM_Sub_brand__c (Name='TEST1',ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,RecordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand'),
                                                    ASI_CRM_CN_Sub_brand_Grade__c=grade.Id));
            subBrands.add(new ASI_MFM_Sub_brand__c (Name='TEST2',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand'),
                                                    ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,
                                                    ASI_CRM_CN_Sub_brand_Grade__c=grade.Id));
            subBrands.add(new ASI_MFM_Sub_brand__c ( Name='TEST3',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand'),
                                                    ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,
                                                    ASI_CRM_CN_Sub_brand_Grade__c=grade.Id));
            subBrands.add(new ASI_MFM_Sub_brand__c ( Name='TEST4',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand'),
                                                    ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,
                                                    ASI_CRM_CN_Sub_brand_Grade__c=grade.Id));
        }
        insert subBrands;
        
        
        Date PO_Start_Date = date.newinstance(system.today().year(), system.today().month(), 1);
        Date PO_End_Date = PO_Start_Date.addMonths(1)-1;
        
        ASI_TH_CRM_Contract__c Contract = new ASI_TH_CRM_Contract__c(recordtypeid = Global_RecordTypeCache.getRTID('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract'),ASI_CRM_CN_Is_2nd_KPI_PO__c=true,
                                                                     ASI_CRM_CN_Status__c = 'Final',ASI_CRM_System_Debug__c=true,
                                                                     ASI_CRM_CN_PO_Start_Date__c = PO_Start_Date,
                                                                     ASI_CRM_CN_PO_End_Date__c =PO_End_Date,
                                                                     ASI_CRM_CN_PO_Version__c = '0.0',ASI_TH_CRM_Promotion_Type__c='Heavy Contract On',
                                                                     Name = 'Contract1',
                                                                     ASI_CRM_CN_Outlet_WS__c=Customers[0].Id,ASI_CRM_Volume_Option__c = 'Normal'
                                                                    );
        insert Contract;
        
        ASI_CRM_Contract_Cost__c contractCost = new ASI_CRM_Contract_Cost__c(ASI_CRM_CN_Contract__c = Contract.id,
                                                                             ASI_CRM_CN_Estimate_Amount__c = 100000,
                                                                             ASI_CRM_CN_Cost_Type__c = 'Variable',
                                                                             ASI_CRM_CN_Other_Cost_Payment_Request__c = true,
                                                                             recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_Contract_Cost__cASI_CRM_CN_Contract_Cost') );
        insert contractCost;
        
        ASI_CRM_CN_Covered_Outlet__c co = new ASI_CRM_CN_Covered_Outlet__c();
        co.ASI_CRM_CN_Contract__c = Contract.Id;
        insert co;  
        
        List<ASI_CRM_Methodology__c> MethodologyList= new List<ASI_CRM_Methodology__c> ();
        MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test1',ASI_CRM_Methodology_Code__c='01',ASI_CRM_Default__c=true,ASI_CRM_Chinese_Name__c='123',ASI_CRM_Type__c='BRSF',recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Methodology__cASI_CRM_CN_Methodology')));
        MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test2',ASI_CRM_Methodology_Code__c='01',ASI_CRM_Default__c=true,ASI_CRM_Chinese_Name__c='Test 123',ASI_CRM_Type__c='PSF',recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Methodology__cASI_CRM_CN_Methodology')));
        MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test3',ASI_CRM_Methodology_Code__c='01',ASI_CRM_Default__c=true,ASI_CRM_Chinese_Name__c='Test 123',ASI_CRM_Type__c='Variable Event Cost',recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Methodology__cASI_CRM_CN_Methodology')));
        
        
       // MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test1',ASI_CRM_Methodology_Code__c='01',ASI_CRM_Chinese_Name__c='123',ASI_CRM_Type__c='BRSF'));
       // MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test2',ASI_CRM_Methodology_Code__c='01',ASI_CRM_Chinese_Name__c='123',ASI_CRM_Type__c='PSF'));
       // MethodologyList.add(new ASI_CRM_Methodology__c(Name='Test3',ASI_CRM_Methodology_Code__c='01',ASI_CRM_Chinese_Name__c='123',ASI_CRM_Type__c='Variable Event Cost'));
        insert MethodologyList;
        
        test.startTest();
        
        
        PageReference EnterPage = Page.ASI_CRM_CN_ViewHeavyContractPage;
        Test.setCurrentPage(EnterPage);
        Map<String, String> pageParams = EnterPage.getParameters();
        
        pageParams.put('id', Contract.id);
        ApexPages.StandardController sc = new ApexPages.standardController(new ASI_TH_CRM_Contract__c());
        
        ASI_CRM_CN_ViewHeavyContractCtrl con = new ASI_CRM_CN_ViewHeavyContractCtrl(new ApexPages.Standardcontroller(Contract));
        
        con.Calculation2nd();
        
        test.stopTest(); 
    }

    static testMethod void ASI_CRM_CN_ViewHeavyContractCtrl2ndTest3() {
        //Test Class for ASI_CRM_CN_ViewHeavyContractCtrl
        ASI_CRM_Region__c region = new ASI_CRM_Region__c (Name='Central Region',recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Region__cASI_CRM_CN_Region'));
        insert region;
        
        ASI_CRM_Division__c division = new ASI_CRM_Division__c(Name='TEST', ASI_CRM_Region__c=region.Id);
        insert division;
        
        ASI_CRM_CN_Area__c area = new ASI_CRM_CN_Area__c(Name='TEST', ASI_CRM_English_Name__c='TEST', ASI_CRM_Division__c=division.Id);
        insert area;
        
        ASI_CRM_City__c city = new ASI_CRM_City__c(Name='TEST', ASI_CRM_CN_Area__c=area.Id);
        insert city;
        
        /*ASI_CRM_CN_Channel__c channel = new ASI_CRM_CN_Channel__c(Name='KTV',ASI_CRM_BC_Rate__c=98,ASI_CRM_CN_On_Off__c='ON',ASI_CRM_For_Outlet__c=true,RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CN_Channel__cASI_CRM_CN_New_Channel'),ASI_CRM_For_Contract__c=TRUE);
        insert channel;*/
                
                ASI_CRM_CN_Channel__c channel = new ASI_CRM_CN_Channel__c(ASI_CRM_CN_On_Off__c='ON');
                insert channel;
                
                Id rtWS = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_CN_WS');
                Id rtOutlet = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN');
                /*
                list<ASI_CRM_AccountsAdditionalField__c> Customers = new list<ASI_CRM_AccountsAdditionalField__c>();
        Customers.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Commercial_Team__c = 'Premium',RecordTypeId=rtWS,Name='TEST', ASI_CRM_CN_Image__c='Iconic',ASI_CRM_CN_CCity__c=city.Id,ASI_CRM_CN_NewChannel__c=channel.Id));
        Customers.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Commercial_Team__c = 'Premium',RecordTypeId=rtOutlet,Name='TEST', ASI_CRM_CN_Image__c='Iconic',ASI_CRM_CN_CCity__c=city.Id,ASI_CRM_CN_NewChannel__c=channel.Id));
        insert Customers;

        //Covered_Outlet
        list<ASI_CRM_AccountsAdditionalField__c> ChildCustomers = new list<ASI_CRM_AccountsAdditionalField__c>();
        ChildCustomers.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Parent_Outlet__c=Customers[1].Id,ASI_CRM_CN_Commercial_Team__c = 'Premium',RecordTypeId=rtOutlet,Name='TEST', ASI_CRM_CN_Image__c='Iconic',ASI_CRM_CN_CCity__c=city.Id,ASI_CRM_CN_NewChannel__c=channel.Id));
        insert ChildCustomers;*/
        
        ASI_MFM_Sub_Channel__c subChannel = new ASI_MFM_Sub_Channel__c(ASI_CRM_CN_Channel__c=channel.Id);
        insert subChannel;
        
        ASI_CRM_CN_Channel__c newChannel = new ASI_CRM_CN_Channel__c(ASI_CRM_For_Outlet__c = true, Name='Restaurant',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CN_Channel__cASI_CRM_CN_New_Channel'),ASI_CRM_CN_On_Off__c='OFF');
        insert newChannel;
        
        list<ASI_CRM_AccountsAdditionalField__c> Customers = new list<ASI_CRM_AccountsAdditionalField__c>();
        Customers.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Eng_Name__c = 'b', ASI_CRM_CN_Chi_Name__c = 'b', ASI_CRM_CN_Commercial_Team__c = 'Premium', ASI_CRM_CN_Sub_Channel__c=subChannel.Id, ASI_CRM_CN_CCity__c=city.Id, ASI_CRM_Latest_Call_Plan_Date__c=system.today(), RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN'), ASI_CRM_CN_NewChannel__c = newChannel.Id, ASI_CRM_CN_Type_of_Restaurant__c = 'International',ASI_CRM_CN_Spending_per_head__c=1));
        Customers.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Eng_Name__c = 'c', ASI_CRM_CN_Chi_Name__c = 'c', ASI_CRM_CN_Commercial_Team__c = 'Premium', ASI_CRM_CN_Sub_Channel__c=subChannel.Id, ASI_CRM_CN_CCity__c=city.Id, ASI_CRM_Latest_Call_Plan_Date__c=system.today(), RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN'), ASI_CRM_CN_NewChannel__c = newChannel.Id, ASI_CRM_CN_Type_of_Restaurant__c = 'International',ASI_CRM_CN_Spending_per_head__c=1));
        insert Customers;
        
        list<ASI_CRM_AccountsAdditionalField__c> ChildCustomers = new list<ASI_CRM_AccountsAdditionalField__c>();
        ChildCustomers.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Parent_Outlet__c=Customers[1].Id,ASI_CRM_CN_Eng_Name__c = 'a', ASI_CRM_CN_Chi_Name__c = 'a', ASI_CRM_CN_Commercial_Team__c = 'Premium', ASI_CRM_CN_Sub_Channel__c=subChannel.Id, ASI_CRM_CN_CCity__c=city.Id, ASI_CRM_Latest_Call_Plan_Date__c=system.today(), RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN'), ASI_CRM_CN_NewChannel__c = newChannel.Id, ASI_CRM_CN_Type_of_Restaurant__c = 'International',ASI_CRM_CN_Spending_per_head__c=1));
        insert ChildCustomers;
        
        /*list<ASI_CRM_AccountsAdditionalField__c> ChildCustomers = new list<ASI_CRM_AccountsAdditionalField__c>();
        ChildCustomers.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Parent_Outlet__c=Customers[1].Id,ASI_CRM_CN_Eng_Name__c = 'a', ASI_CRM_CN_Chi_Name__c = 'a', ASI_CRM_CN_Commercial_Team__c = 'Premium', ASI_CRM_CN_Sub_Channel__c=subChannel.Id, ASI_CRM_CN_CCity__c=city.Id, ASI_CRM_Latest_Call_Plan_Date__c=system.today(), RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN'), ASI_CRM_CN_NewChannel__c = newChannel.Id, ASI_CRM_CN_Type_of_Restaurant__c = 'International',ASI_CRM_CN_Spending_per_head__c=1));
        insert ChildCustomers;

        list<ASI_CRM_AccountsAdditionalField__c> ChildChildCustomers = new list<ASI_CRM_AccountsAdditionalField__c>();
        ChildChildCustomers.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Parent_Outlet__c=ChildCustomers[0].Id,ASI_CRM_CN_Commercial_Team__c = 'Premium',RecordTypeId=rtOutlet,Name='TEST', ASI_CRM_CN_Image__c='Iconic',ASI_CRM_CN_CCity__c=city.Id,ASI_CRM_CN_NewChannel__c=channel.Id));
        insert ChildChildCustomers;*/
                
                //ASI_CRM_CN_Parent_Outlet__c
        
        User currentUser = [SELECT id, name, Managerid, ASI_CRM_CN_Prefix__c FROM USER WHERE id =:UserInfo.getUserId()];
        
        list<ASI_HK_CRM_Running_Number__c> rns = new list<ASI_HK_CRM_Running_Number__c>();
        rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_TH_CRM_Contract__c', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_TH_CRM_PaymentRequest__c', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        if(!String.isBlank(currentUser.ASI_CRM_CN_Prefix__c))
            rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_'+currentUser.ASI_CRM_CN_Prefix__c, recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        else{
            rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_NULL', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
            rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        }
        insert rns;
        
        //Sub Brand Grade
        list<ASI_CRM_Sub_Brand_Grade__c> grades = new list<ASI_CRM_Sub_Brand_Grade__c>();
        grades.add(new ASI_CRM_Sub_Brand_Grade__c (Name='TEST1'));
        grades.add(new ASI_CRM_Sub_Brand_Grade__c (Name='TEST2'));
        grades.add(new ASI_CRM_Sub_Brand_Grade__c (Name='TEST3'));
        insert grades;
        
        
        list<ASI_MFM_Sub_brand__c> subBrands = new list<ASI_MFM_Sub_brand__c>();
        for(ASI_CRM_Sub_Brand_Grade__c grade :grades) {
            subBrands.add(new ASI_MFM_Sub_brand__c (Name='TEST1',ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,RecordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand'),
                                                    ASI_CRM_CN_Sub_brand_Grade__c=grade.Id));
            subBrands.add(new ASI_MFM_Sub_brand__c (Name='TEST2',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand'),
                                                    ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,
                                                    ASI_CRM_CN_Sub_brand_Grade__c=grade.Id));
            subBrands.add(new ASI_MFM_Sub_brand__c ( Name='TEST3',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand'),
                                                    ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,
                                                    ASI_CRM_CN_Sub_brand_Grade__c=grade.Id));
            subBrands.add(new ASI_MFM_Sub_brand__c ( Name='999',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand'),
                                                    ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,ASI_MFM_Sub_brand_Code__c = '999' ,ASI_MFM_Active_for_CRM__c = true ,
                                                    ASI_CRM_CN_Sub_brand_Grade__c=grade.Id));
        }
        insert subBrands;
        
        
        Date PO_Start_Date = date.newinstance(system.today().year(), system.today().month(), 1);
        Date PO_End_Date = PO_Start_Date.addMonths(1)-1;
        
        ASI_TH_CRM_Contract__c Contract = new ASI_TH_CRM_Contract__c(recordtypeid = Global_RecordTypeCache.getRTID('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract'),ASI_CRM_CN_Is_2nd_KPI_PO__c=true,
                                                                     ASI_CRM_CN_Status__c = 'Final',
                                                                     ASI_CRM_CN_PO_Start_Date__c = PO_Start_Date,
                                                                     ASI_CRM_CN_PO_End_Date__c =PO_End_Date,
                                                                     ASI_CRM_CN_PO_Version__c = '0.0',ASI_TH_CRM_Promotion_Type__c='Heavy Contract On',
                                                                     Name = 'Contract1',
                                                                     ASI_CRM_CN_Outlet_WS__c=Customers[1].Id,ASI_CRM_Volume_Option__c = 'Normal');
        insert Contract;
        
        
        test.startTest();
        
        
        PageReference EnterPage = Page.ASI_CRM_CN_ViewHeavyContractPage;
        Test.setCurrentPage(EnterPage);
        Map<String, String> pageParams = EnterPage.getParameters();
        
        pageParams.put('id', Contract.id);
        ApexPages.StandardController sc = new ApexPages.standardController(new ASI_TH_CRM_Contract__c());
        
        ASI_CRM_CN_ViewHeavyContractCtrl con = new ASI_CRM_CN_ViewHeavyContractCtrl(new ApexPages.Standardcontroller(Contract));
        
        con.AddAllChildOutlets();
        con.SaveItems();
        
        test.stopTest(); 
    }  
}