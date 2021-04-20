@isTest
public class ASI_KR_SubmitApprovalController_Test {
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
        user u = [SELECT id, userRole.developerName FROM user WHERE profile.Name = 'ASI System Administrator' and isactive = true and userroleid <> null LIMIT 1];    
        u.ASI_MFM_Country__c ='TW';
        update u;
        
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
        
        PageReference testPage = Page.ASI_KR_SubmitApprovalPage;
        Map<String, String> pageParams = testPage.getParameters();
        pageParams.put('id',plan.Id);
        Test.setCurrentPageReference(testPage);
        
        ASI_KR_SubmitApprovalController controller = new ASI_KR_SubmitApprovalController();
        
        //Test Negative Scenario, wrong status
        plan.ASI_MFM_Status__c = 'DUMMY';
        controller.submit();
        
        //Test Positive Scenario
        plan.ASI_MFM_Status__c = 'Draft';
        controller.submit(); 
        
        //Added by Introv @20170322 for TW PAF   
        pageParams.put('id',listPlan[0].id);
        Test.setCurrentPageReference(testPage);
        
        ASI_KR_SubmitApprovalController controller1 = new ASI_KR_SubmitApprovalController();
        
        //Test Negative Scenario, wrong status
        plan.ASI_MFM_Status__c = 'DUMMY';
        controller1.submit();
        
        //Test Positive Scenario
        plan.ASI_MFM_Status__c = 'Draft';
        controller1.submit(); 
        //End by Introv @20170322 for TW PAF   
        
        Test.StopTest();
    }
}