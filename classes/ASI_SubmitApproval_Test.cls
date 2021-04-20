@isTest
public class ASI_SubmitApproval_Test {
    @TestSetup
    public static void setupTestData(){
        Profile p = [SELECT id, Name FROM Profile where name = 'System Administrator' ].get(0);  
        User u= new User(ASI_MFM_Country__c ='TW', alias = 'test99', email='test99' + '@dev.com', emailencodingkey='UTF-8', firstname='test99', lastname='Testing', languagelocalekey='en_US', localesidkey='en_US', timezonesidkey='Europe/London', username='test99' + '@pernod-ricard.com',ProfileId = p.id, UserRoleId = UserInfo.getUserRoleId(), isActive=true);
        Insert u;
    }
    
    private static string getFiscalYear(){
         
        
        Integer orgFiscalMonth = [SELECT FiscalYearStartMonth FROM Organization].FiscalYearStartMonth;  //i.e. 7
        Date orgFiscalYear = Date.newinstance(system.today().year(), orgFiscalMonth, 1);    
        Datetime GMTdate = Datetime.now();
        String yearA1 = GMTdate.format('YY');
        Integer yearA0 = Integer.valueOf(yearA1) -1;
        Integer yearA2 = Integer.valueOf(yearA1) +1;
        String Current_Fiscal_year;

        if(system.today()< orgFiscalYear){
            Current_Fiscal_year = 'FY' + yearA0 + yearA1 ;
        }else{
            Current_Fiscal_year = 'FY' + yearA1 + yearA2 ;
        }       
        return Current_Fiscal_year;
    }
    
    static testMethod void testSubmitPlan(){
        ASI_MFM_CAP_TestClassHelper.createRoutePlanType();
        ASI_MFM_Plan__c plan = ASI_MFM_CAP_TestClassHelper.createPlan();
        ASI_MFM_Plan_Line_Item__c planLines = ASI_MFM_CAP_TestClassHelper.createPlanLines(plan);
        
        //Added by Introv @20170322 for TW PAF
        
        user u = [SELECT id, userRole.developerName FROM user WHERE profile.Name = 'System Administrator' and  isactive = true and userroleid <> null LIMIT 1];    
        //u.ASI_MFM_Country__c ='TW';
        //u.ProfileId = p.id;
        // update u;
        
        List<ASI_MFM_Plan__c> listPlan = new List<ASI_MFM_Plan__c>();
        
        System.runAs(u) {
            List<ASI_MFM_Prefix__c> prList = new List<ASI_MFM_Prefix__c> (); 
            ASI_MFM_Prefix__c pxp = new ASI_MFM_Prefix__c(name='Ftest', ASI_MFM_Module__c='Plan', Plan_Type__c='rade A&P Plan',ASI_MFM_Over_Spending_Checking__c=true,ASI_MFM_Tolerance__c=1, ASI_MFM_Fiscal_year__c = getFiscalYear());
            prList.add(pxp);
            ASI_MFM_Prefix__c pxo = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO', ASI_MFM_Fiscal_year__c = getFiscalYear());
            prList.add(pxo);
            ASI_MFM_Prefix__c pxy = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Payment', ASI_MFM_Fiscal_year__c = getFiscalYear());
            prList.add(pxy);
            insert prList;
            
            List<ASI_MFM_Role_Prefix_Relationship__c> rprList = new List<ASI_MFM_Role_Prefix_Relationship__c> (); 
            rprList.add(new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxp.id, ASI_MFM_Role_Name__c=u.userRole.developerName));
            rprList.add(new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Role_Name__c=u.userRole.developerName));
            rprList.add(new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxy.id, ASI_MFM_Role_Name__c=u.userRole.developerName));
            insert rprList;
            
            ASI_MFM_Sub_brand__c sub = new ASI_MFM_Sub_brand__c(
                name = 'testSubBrand',
                ASI_CRM_TW_Company__c = 'PRT', 
                ASI_CRM_Active__c = TRUE, 
                ASI_TH_CRM_Active__c = TRUE,
                ASI_MFM_Sub_brand_Code__c = 'SBC1',
                recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_MFM_TW_Sub_brand')
            );
            insert sub;
            
            ASI_CRM_CN_Channel__c channel = new ASI_CRM_CN_Channel__c(
                recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_CN_Channel__cASI_CRM_TW_Channel'), 
                Name = 'TOT (酒店)',
                ASI_CRM_CN_Channel_Code__c = 'TOT');
            insert channel;
            
            ASI_MFM_Sub_Channel__c subChannel = new ASI_MFM_Sub_Channel__c(
                Name = 'Piano Bar (PB)', 
                ASI_CRM_CN_Sub_Channel_Code__c = 'PB',
                ASI_CRM_CN_Channel__c = channel.id, 
                RecordTypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_Channel__cASI_CRM_TW_SubChannel'));
            insert subChannel;   
            
            ASI_TH_CRM_OutletType__c outletType = new ASI_TH_CRM_OutletType__c(
                RecordTypeid = Global_RecordTypeCache.getRtId('ASI_TH_CRM_OutletType__cASI_CRM_TW_Outlet_Type'),
                Name = 'PB (鋼琴酒吧)', 
                ASI_TH_CRM_Code__c = 'TW_PB',
                ASI_CRM_Sub_Channel__c = subChannel.id
            );
            insert outletType;
            
            List<Account> listOutlet = new List<Account>();
            listOutlet.add(new Account(
                RecordTypeid = Global_RecordTypeCache.getRtId('AccountASI_CRM_TW_Outlet'), 
                Name='Test Outlet',  
                ASI_TH_CRM_Region__c ='North')
            );  
            insert listOutlet;
            
            List<ASI_CRM_AccountsAdditionalField__c> listAccountAdditionalField = new List<ASI_CRM_AccountsAdditionalField__c>();
            listAccountAdditionalField.add(new ASI_CRM_AccountsAdditionalField__c(
                RecordTypeid = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_TW_Outlet'),
                Name = 'Test Outlet', 
                ASI_CRM_Account__c = listOutlet[0].id, 
                ASI_TH_CRM_OutletType__c = outletType.id, 
                ASI_CRM_Region__c = 'North',
                ASI_CRM_Channel__c = channel.id,
                ASI_CRM_CN_Sub_Channel__c = subChannel.id,
                ASI_CRM_City__c = 'Test City', 
                ASI_CRM_Town__c = 'Test Town', 
                ASI_CRM_TW_Street__c = 'Test Street', 
                ASI_CRM_TW_Number__c = '1', 
                ASI_CRM_TW_Floor__c = '12')
            );
            insert listAccountAdditionalField;
            
            listPlan.add(new ASI_MFM_Plan__c(
                recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_TW_Plan'), 
                name='test', 
                ASI_MFM_End_Date__c=Date.today().addMonths(1), 
                ASI_MFM_Prefix__c=pxp.id,
                ASI_MFM_Plan_Description__c='testPlanDescription', 
                ASI_MFM_Plan_Name__c='testPlan', 
                ASI_MFM_Start_Date__c=Date.today(), 
                ASI_MFM_Status__c = 'Draft')
            );
            insert listPlan;   
            
            List<ASI_HK_CRM_Pre_Approval_Form__c> listPAF = new List<ASI_HK_CRM_Pre_Approval_Form__c>();
            listPAF.add(new ASI_HK_CRM_Pre_Approval_Form__c(
                RecordTypeid = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Pre_Approval_Form__cASI_CRM_TW_Pre_Approval_Form'),
                ASI_HK_CRM_PAF_Customer__c = listOutlet[0].id,
                ASI_HK_CRM_PAF_Start_Date__c = system.Today(),
                ASI_HK_CRM_PAF_End_Date__c = system.Today().addMonths(3),
                ASI_HK_CRM_PAF_Status__c = 'Final',
                ASI_CRM_Commitment_No__c = listPlan[0].id)
            );
            insert listPAF;
        }
        //End by Introv @20170322 for TW PAF   
            
        Test.StartTest();
        
        PageReference testPage = Page.ASI_SubmitApprovalPage;
        Map<String, String> pageParams = testPage.getParameters();
        pageParams.put('id',plan.Id);
        pageParams.put('reason','test'); // added by laputa (Calvin) : 2019-01-11
        Test.setCurrentPageReference(testPage);
        
        ASI_SubmitApprovalController controller = new ASI_SubmitApprovalController();
        
        //Test Negative Scenario, wrong status
        plan.ASI_MFM_Status__c = 'DUMMY';
        controller.submit();
        
        //Test Positive Scenario
        plan.ASI_MFM_Status__c = 'Draft';
        controller.submit(); 
        
        //Added by Introv @20170322 for TW PAF   
        pageParams.put('id',listPlan[0].id);
        Test.setCurrentPageReference(testPage);
        
        ASI_SubmitApprovalController controller1 = new ASI_SubmitApprovalController();
        
        //Test Negative Scenario, wrong status
        plan.ASI_MFM_Status__c = 'DUMMY';
        controller1.submit();
        
        //Test Positive Scenario
        plan.ASI_MFM_Status__c = 'Draft';
        controller1.submit(); 
        //End by Introv @20170322 for TW PAF   
        
        Test.StopTest();
    }
    
    static testMethod void testSubmitTnE(){
        user u = [select userRole.developerName, ASI_MFM_Country__c from user where id = :userInfo.getUserId()]; 
        u.ASI_MFM_Country__c ='SG';
        update u;
        user u1 = [SELECT id, userRole.developerName FROM user WHERE profile.Name = 'System Administrator' and  isactive = true and userroleid <> null LIMIT 1];    
        ASI_MFM_Exchange_Rate__c xr = new ASI_MFM_Exchange_Rate__c(ASI_MFM_Application__c='MFM', ASI_MFM_Base_Currency__c='SGD',
                                                                   ASI_MFM_Counter_Currency__c='USD', ASI_MFM_Country__c='SG', ASI_MFM_Effective_Date__c=date.today(), ASI_MFM_Exchange_Rate__c=1.23);
        insert xr;         
        
        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', Plan_Type__c='test', ASI_MFM_Fiscal_year__c=getFiscalYear());
        insert px;
        
        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pr;
        
        
        ASI_MFM_Plan__c p1 = new ASI_MFM_Plan__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_SG_Plan'), ASI_MFM_Prefix__c=px.id, ASI_MFM_Start_Date__c=date.today(), ASI_MFM_End_Date__c=date.today(),
                                                 ASI_MFM_Plan_Description__c='planDescription', ASI_MFM_Plan_Name__c='testplanName', ASI_MFM_Status__c = 'Final');
        insert p1;
        
        px = new ASI_MFM_Prefix__c(name='test1', ASI_MFM_Module__c='PO', ASI_MFM_Fiscal_year__c=getFiscalYear());
        insert px;
        
        ASI_MFM_Prefix__c px2 = new ASI_MFM_Prefix__c(name='test2', ASI_MFM_Module__c='Payment', ASI_MFM_Fiscal_year__c=getFiscalYear(), ASI_MFM_Inactive__c = false);
        insert px2;
        
        pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pr;
        
        ASI_MFM_Role_Prefix_Relationship__c pr2 = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px2.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pr2;
        
        ASI_MFM_Route_Type__c rt = new ASI_MFM_Route_Type__c(name='teste', ASI_MFM_Module__c='PO');
        insert rt;
        
        ASI_MFM_Brand_Route_Type_Map__c rtm = new ASI_MFM_Brand_Route_Type_Map__c(ASI_MFM_Route_Type__c=rt.id, ASI_MFM_Prefix__c=px.id);
        insert rtm;
        
        List<ASI_MFM_Route_Rule_Detail__c> rrdlist = new List<ASI_MFM_Route_Rule_Detail__c>();
        rrdlist.add(new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt.id, ASI_MFM_Sequence__c=0));
        rrdlist.add(new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt.id, ASI_MFM_Sequence__c=1));
        rrdlist.add(new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt.id, ASI_MFM_Sequence__c=2));
        rrdlist.add(new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt.id, ASI_MFM_Sequence__c=3));
        rrdlist.add(new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt.id, ASI_MFM_Sequence__c=4));
        rrdlist.add(new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt.id, ASI_MFM_Sequence__c=5));
        rrdlist.add(new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt.id, ASI_MFM_Sequence__c=6));
        rrdlist.add(new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt.id, ASI_MFM_Sequence__c=7));
        rrdlist.add(new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt.id, ASI_MFM_Sequence__c=8));
        rrdlist.add(new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt.id, ASI_MFM_Sequence__c=9));        
        insert rrdlist;
                
        map<string, id> rt_map2 = ASI_MFM_Function.getRecordTypeId('ASI_MFM_PO__c');  //ASI_MFM_Plan__c
        rt_map2 = ASI_MFM_Function.getRecordTypeId('Account');   
        Account acc2 = new Account(recordTypeId=rt_map2.get('ASI_CRM_SG_Outlet'),Name='Name3');           
        insert acc2;
        
        map<string, id> rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_PO__c'); 
        rt_map = ASI_MFM_Function.getRecordTypeId('Account');
        Account acc1 = new Account(recordTypeId=rt_map.get('ASI_CRM_SG_Supplier'),Name='Name2');          
        insert acc1;
        
        System.debug(Limits.getDMLRows());
        
        
        ASI_MFM_PO__c po = new ASI_MFM_PO__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_SG_PO'), ASI_MFM_Prefix__c=px.id, ASI_MFM_Plan__c=p1.id, ASI_MFM_PO_Raised_Date__c=date.today(),
                                             ASI_MFM_Currency__c='SGD', ASI_MFM_PO_Start_Date__c=date.today(), ASI_MFM_PO_End_Date__c=date.today().addDays(1), ASI_MFM_Supplier_Name__c = acc1.id, ASI_MFM_Status__c='Final');
        insert po;
        
        ASI_MFM_A_C_Code__c ac = new ASI_MFM_A_C_Code__c(name='testAC');
        insert ac;
        
        ASI_MFM_Sub_brand__c sub = new ASI_MFM_Sub_brand__c(name='testSubBrand');
        insert sub;
        
        ASI_MFM_PO_Line_Item__c poi = new ASI_MFM_PO_Line_Item__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_SG_PO_Line_Item'), ASI_MFM_PO__c=po.id, ASI_MFM_Quantity__c=10, ASI_MFM_Unit_Price__c=10, ASI_MFM_Amount__c = 100,
                                                                  ASI_MFM_Spread_by_Months__c=true,ASI_MFM_A_C_Code__c=ac.id, ASI_MFM_Customer_Name__c=acc2.id, ASI_MFM_List_Item_Description__c='testDescription', ASI_MFM_Sub_brand_Code__c=sub.id, ASI_MFM_G_L_Date__c = Date.today());
        //insert poi;
        
        ASI_TnE_TestClassHelper.createTaxDateMapping();
        ASI_TnE_TestClassHelper.createRunningNumbers();
        
        ASI_TnE_ClaimHeader__c header = new ASI_TnE_ClaimHeader__c(
            ASI_TnE_Invoice_No__c = 'invoice', ASI_TnE_Status__c = 'Draft', ownerid=u1.id,
            ASI_TnE_Type__c = 'Out of Pocket', ASI_TnE_Start_Date__c = date.today().addDays(1), ASI_TnE_End_Date__c = date.today().addYears(1),
            recordTypeId = Global_RecordTypeCache.getRtId('ASI_TnE_ClaimHeader__cASI_TnE_SG_Claim_Header'),
            ASI_TnE_Sys_Approver_1__c = UserInfo.getUserId()
        );
        insert header;
        
        test.startTest();
        ASI_TnE_ClaimDetail__c detail = new ASI_TnE_ClaimDetail__c(
            ASI_TnE_ClaimHeader__c = header.id, ASI_TnE_Receipt_Date__c = date.today(),ASI_TnE_Description__c = 'test description',
            ASI_TnE_Currency__c = 'HKD',ASI_TnE_Receipt_Amount__c = 0,ASI_TnE_FX_Rate__c = 1,ASI_TnE_MFM_PO__c = po.id,
            recordTypeId = Global_RecordTypeCache.getRtId('ASI_TnE_ClaimDetail__cASI_TnE_SG_Claim_Detail'),
            ASI_TnE_Tax_Inclusive__c = true
        );
        insert detail;
        
        
        
        PageReference testPage = Page.ASI_SubmitApprovalPage;
        Map<String, String> pageParams = testPage.getParameters();
        pageParams.put('id',header.Id);
        pageParams.put('reason','test'); 
        Test.setCurrentPageReference(testPage);
        
        ASI_SubmitApprovalController controller = new ASI_SubmitApprovalController();
        controller.submit();
        
        Test.StopTest();
        
    }
}