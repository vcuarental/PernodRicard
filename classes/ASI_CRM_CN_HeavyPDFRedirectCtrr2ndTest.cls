/**
 * @File Name          : ASI_CRM_CN_HeavyPDFRedirectCtrr2ndTest.cls
 * @Description        : 
 * @Author             : pengchen@bluelinksys.com
 * @Group              : 
 * @Last Modified By   : pengchen@bluelinksys.com
 * @Last Modified On   : 5/17/2020, 2:07:17 PM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    5/17/2020   pengchen@bluelinksys.com     Initial Version
**/
@isTest
public class ASI_CRM_CN_HeavyPDFRedirectCtrr2ndTest {

    @TestSetup
    public static void initData() {
        ASI_CRM_Region__c region = new ASI_CRM_Region__c (Name='Central Region',recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Region__cASI_CRM_CN_Region'));
        insert region;

        ASI_CRM_Division__c division = new ASI_CRM_Division__c(Name='TEST', ASI_CRM_Region__c=region.Id);
        insert division;

        ASI_CRM_CN_Area__c area = new ASI_CRM_CN_Area__c(Name='TEST', ASI_CRM_English_Name__c='TEST', ASI_CRM_Division__c=division.Id);
        insert area;

        ASI_CRM_City__c city = new ASI_CRM_City__c(Name='TEST', ASI_CRM_CN_Area__c=area.Id);
        insert city;

        ASI_CRM_CN_Channel__c channel = new ASI_CRM_CN_Channel__c(Name='KTV',ASI_CRM_BC_Rate__c=98,ASI_CRM_CN_On_Off__c='ON',ASI_CRM_For_Outlet__c=true,RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CN_Channel__cASI_CRM_CN_New_Channel'),ASI_CRM_For_Contract__c=TRUE);
        insert channel;



        List<ASI_CRM_SegmentationCriteria__c>  SegmentationCriteriaList = new List<ASI_CRM_SegmentationCriteria__c> ();
        SegmentationCriteriaList.add(new ASI_CRM_SegmentationCriteria__c(ASI_CRM_Region__c=region.Id,ASI_CRM_Channel__c=channel.Id,ASI_CRM_English_Interpretation__c='Test 1 ',ASI_CRM_Chinese_Interpretation__c='Test2',
            ASI_CRM_Financial_Indicator__c='Volume: Total',ASI_CRM_Operation__c='Greater than',
            ASI_CRM_1st_Dimension__c='New Contract V0.0 Est.',ASI_CRM_2nd_Dimension__c='Historical V0.0',
            Name='Test1',recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_SegmentationCriteria__cASI_CRM_CN_PO_Open_Checkpoint_Criteria')) );

        SegmentationCriteriaList.add(new ASI_CRM_SegmentationCriteria__c(ASI_CRM_Region__c=region.Id,ASI_CRM_Channel__c=channel.Id,ASI_CRM_English_Interpretation__c='Test 1 ',ASI_CRM_Chinese_Interpretation__c='Test2',
            ASI_CRM_Financial_Indicator__c='Methodology: BRSF Methodology',ASI_CRM_Operation__c='Equal to',ASI_CRM_2nd_Dimension__c='Predefined Theoretical Value',
            ASI_CRM_1st_Dimension__c='New Contract V0.0 Est.',AS_CRM_Predefined_Theoretical_Value__c='PRC Default Methodology',
            Name='Test2',recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_SegmentationCriteria__cASI_CRM_CN_PO_Open_Checkpoint_Criteria')) );

        SegmentationCriteriaList.add(new ASI_CRM_SegmentationCriteria__c(ASI_CRM_Region__c=region.Id,ASI_CRM_Channel__c=channel.Id,ASI_CRM_English_Interpretation__c='Test 1 ',ASI_CRM_Chinese_Interpretation__c='Test2',
            ASI_CRM_Financial_Indicator__c='Methodology: PSF Methodology',ASI_CRM_Operation__c='Equal to',ASI_CRM_2nd_Dimension__c='Predefined Theoretical Value',
            ASI_CRM_1st_Dimension__c='New Contract V0.0 Est.',AS_CRM_Predefined_Theoretical_Value__c='PRC Default Methodology',
            Name='Test3',recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_SegmentationCriteria__cASI_CRM_CN_PO_Open_Checkpoint_Criteria')) );


        SegmentationCriteriaList.add(new ASI_CRM_SegmentationCriteria__c(ASI_CRM_Region__c=region.Id,ASI_CRM_Channel__c=channel.Id,ASI_CRM_English_Interpretation__c='Test 1 ',ASI_CRM_Chinese_Interpretation__c='Test2',
            ASI_CRM_Financial_Indicator__c='Period: PO Start Date',ASI_CRM_Operation__c='Less than',AS_CRM_Predefined_Theoretical_Value__c='PRC Default Methodology',
            ASI_CRM_1st_Dimension__c='New Contract V0.0 Est.',ASI_CRM_2nd_Dimension__c='Predefined Theoretical Value',ASI_CRM_Alignment_Value__c=-50,
            Name='Test4',recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_SegmentationCriteria__cASI_CRM_CN_PO_Open_Checkpoint_Criteria')) );

        SegmentationCriteriaList.add(new ASI_CRM_SegmentationCriteria__c(ASI_CRM_Region__c=region.Id,ASI_CRM_Channel__c=channel.Id,ASI_CRM_English_Interpretation__c='Test 1 ',ASI_CRM_Chinese_Interpretation__c='Test2',
            ASI_CRM_Financial_Indicator__c='Trade Expenses: ROI(Actual)',ASI_CRM_Operation__c='Greater than or Equal to',
            ASI_CRM_1st_Dimension__c='New Contract V0.0 Est.',ASI_CRM_Alignment_Percentage__c=0.95,
            Name='Test5',recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_SegmentationCriteria__cASI_CRM_CN_PO_Open_Checkpoint_Criteria')) );


        SegmentationCriteriaList.add(new ASI_CRM_SegmentationCriteria__c(ASI_CRM_Region__c=region.Id,ASI_CRM_Channel__c=channel.Id,ASI_CRM_English_Interpretation__c='Test 1 ',ASI_CRM_Chinese_Interpretation__c='Test2',
            ASI_CRM_Financial_Indicator__c='BC: BC%',ASI_CRM_Operation__c='Greater than or Equal to',
            ASI_CRM_1st_Dimension__c='New Contract V0.0 Est.',ASI_CRM_Alignment_Percentage__c=0.95,
            Name='Test6',recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_SegmentationCriteria__cASI_CRM_CN_PO_Open_Checkpoint_Criteria')) );

        SegmentationCriteriaList.add(new ASI_CRM_SegmentationCriteria__c(ASI_CRM_Region__c=region.Id,ASI_CRM_Channel__c=channel.Id,ASI_CRM_English_Interpretation__c='Test 1 ',ASI_CRM_Chinese_Interpretation__c='Test2',
            ASI_CRM_Financial_Indicator__c='Volume: By Grade - Premium',ASI_CRM_Operation__c='Greater than or Equal to',
            ASI_CRM_1st_Dimension__c='Historical Vfinal',ASI_CRM_2nd_Dimension__c='Historical V0.0',
            Name='Test7',recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_SegmentationCriteria__cASI_CRM_CN_PO_Open_Checkpoint_Criteria')) );


        SegmentationCriteriaList.add(new ASI_CRM_SegmentationCriteria__c(ASI_CRM_Region__c=region.Id,ASI_CRM_Channel__c=channel.Id,ASI_CRM_English_Interpretation__c='Test 1 ',ASI_CRM_Chinese_Interpretation__c='Test2',
            ASI_CRM_Financial_Indicator__c='Methodology: PSF Volume Base',ASI_CRM_Operation__c='Equal to',ASI_CRM_2nd_Dimension__c='Predefined Theoretical Value',
            ASI_CRM_1st_Dimension__c='New Contract V0.0 Est.',AS_CRM_Predefined_Theoretical_Value__c='PRC Default Volume Base',
            Name='Test8',recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_SegmentationCriteria__cASI_CRM_CN_PO_Open_Checkpoint_Criteria')) );

        SegmentationCriteriaList.add(new ASI_CRM_SegmentationCriteria__c(ASI_CRM_Region__c=region.Id,ASI_CRM_Channel__c=channel.Id,ASI_CRM_English_Interpretation__c='Test 1 ',ASI_CRM_Chinese_Interpretation__c='Test2',
            ASI_CRM_Financial_Indicator__c='Trade Expenses: ROI(Actual)',ASI_CRM_Operation__c='Greater than or Equal to',
            ASI_CRM_1st_Dimension__c='New Contract V Final',ASI_CRM_2nd_Dimension__c='New Contact V0.0 Contract',
            Name='Test9',recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_SegmentationCriteria__cASI_CRM_CN_PO_Modi_Checkpoint_Criteria')) );
        SegmentationCriteriaList.add(new ASI_CRM_SegmentationCriteria__c(ASI_CRM_Region__c=region.Id,ASI_CRM_Channel__c=channel.Id,ASI_CRM_English_Interpretation__c='Test 1 ',ASI_CRM_Chinese_Interpretation__c='Test2',
            ASI_CRM_Financial_Indicator__c='Trade Expenses: ROI(Actual)',ASI_CRM_Operation__c='Greater than or Equal to',
            ASI_CRM_1st_Dimension__c='New Contact V0.0 Contract',ASI_CRM_2nd_Dimension__c='New Contract V0.0 Est.',
            Name='Test10',recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_SegmentationCriteria__cASI_CRM_CN_PO_Open_Checkpoint_Criteria')) );
        SegmentationCriteriaList.add(new ASI_CRM_SegmentationCriteria__c(ASI_CRM_Region__c=region.Id,ASI_CRM_Channel__c=channel.Id,ASI_CRM_English_Interpretation__c='Test 1 ',ASI_CRM_Chinese_Interpretation__c='Test2',
            ASI_CRM_Financial_Indicator__c='Trade Expenses: ROI(Actual)',ASI_CRM_Operation__c='Greater than or Equal to',
            ASI_CRM_1st_Dimension__c='New Contract V Final',ASI_CRM_2nd_Dimension__c='New Contract V Final',
            Name='Test11',recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_SegmentationCriteria__cASI_CRM_CN_PO_Modi_Checkpoint_Criteria')) );


        SegmentationCriteriaList.add(new ASI_CRM_SegmentationCriteria__c(ASI_CRM_Region__c=region.Id,ASI_CRM_Channel__c=channel.Id,ASI_CRM_English_Interpretation__c='Test 1 ',ASI_CRM_Chinese_Interpretation__c='Test2',
            ASI_CRM_Financial_Indicator__c='Volume: By Category - Whisky',ASI_CRM_Operation__c='Greater than or Equal to',
            ASI_CRM_1st_Dimension__c='New Contact V0.0 Contract',ASI_CRM_2nd_Dimension__c='Historical Vfinal',
            Name='Test11',recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_SegmentationCriteria__cASI_CRM_CN_PO_Open_Checkpoint_Criteria')) );

        SegmentationCriteriaList.add(new ASI_CRM_SegmentationCriteria__c(ASI_CRM_Region__c=region.Id,ASI_CRM_Channel__c=channel.Id,ASI_CRM_English_Interpretation__c='Test 1 ',ASI_CRM_Chinese_Interpretation__c='Test2',
            ASI_CRM_Financial_Indicator__c='Trade Expenses: ROI(Actual)',ASI_CRM_Operation__c='Greater than or Equal to',
            ASI_CRM_1st_Dimension__c='New Contact V0.0 Contract',ASI_CRM_2nd_Dimension__c='New Contract V0.0 Est.',
            Name='Test10',recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_SegmentationCriteria__cASI_CRM_CN_PO_Open_Checkpoint_Criteria')) );

        SegmentationCriteriaList.add(new ASI_CRM_SegmentationCriteria__c(ASI_CRM_Region__c=region.Id,ASI_CRM_Channel__c=channel.Id,ASI_CRM_English_Interpretation__c='Test 1 ',ASI_CRM_Chinese_Interpretation__c='Test2',
            ASI_CRM_Financial_Indicator__c='Period: PO Start Date',ASI_CRM_Operation__c='Less than',AS_CRM_Predefined_Theoretical_Value__c='PO Submit Date',
            ASI_CRM_1st_Dimension__c='New Contract V0.0 Est.',ASI_CRM_2nd_Dimension__c='Predefined Theoretical Value',ASI_CRM_Alignment_Value__c=-50,
            Name='Test11',recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_SegmentationCriteria__cASI_CRM_CN_PO_Open_Checkpoint_Criteria')) );

        insert SegmentationCriteriaList;



        Id rtOutlet = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN');

        list<ASI_CRM_AccountsAdditionalField__c> Customers = new list<ASI_CRM_AccountsAdditionalField__c>();
        Customers.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Commercial_Team__c = 'Premium',RecordTypeId=rtOutlet,Name='TEST', ASI_CRM_CN_Image__c='Iconic',ASI_CRM_CN_CCity__c=city.Id,ASI_CRM_CN_NewChannel__c=channel.Id));
        insert Customers;

        List<ASI_CRM_AccountsAdditionalField__c> customerList = [select id,name,ASI_CRM_CN_Commercial_Team__c,ASI_CRM_CN_Image__c,ASI_CRM_CN_CCity__c,ASI_CRM_CN_NewChannel__c from ASI_CRM_AccountsAdditionalField__c];

        System.debug(LoggingLevel.INFO, '*** customerList: ' + customerList);

        //Covered_Outlet
        list<ASI_CRM_AccountsAdditionalField__c> ChildCustomers = new list<ASI_CRM_AccountsAdditionalField__c>();
        ChildCustomers.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Parent_Outlet__c=Customers[0].Id,ASI_CRM_CN_Commercial_Team__c = 'Premium',RecordTypeId=rtOutlet,Name='TEST', ASI_CRM_CN_Image__c='Iconic',ASI_CRM_CN_CCity__c=city.Id,ASI_CRM_CN_NewChannel__c=channel.Id));
        insert ChildCustomers;


        list<ASI_CRM_AccountsAdditionalField__c> ChildChildCustomers = new list<ASI_CRM_AccountsAdditionalField__c>();
        ChildChildCustomers.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Parent_Outlet__c=ChildCustomers[0].Id,ASI_CRM_CN_Commercial_Team__c = 'Premium',RecordTypeId=rtOutlet,Name='TEST', ASI_CRM_CN_Image__c='Iconic',ASI_CRM_CN_CCity__c=city.Id,ASI_CRM_CN_NewChannel__c=channel.Id));
        insert ChildChildCustomers;

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

        System.debug(LoggingLevel.INFO, '*** subBrands: ' + subBrands);
        System.debug(LoggingLevel.INFO, '*** Customers: ' + Customers);
        System.debug(LoggingLevel.INFO, '*** ChildCustomers: ' + ChildCustomers);
        System.debug(LoggingLevel.INFO, '*** ChildChildCustomers: ' + ChildChildCustomers);

        ASI_CRM_CN_CustomSetting__c CustomSetting = new ASI_CRM_CN_CustomSetting__c(ASI_CRM_CN_Fixed_Cost_Acmount_Checking__c=1000000,ASI_CRM_Total_Amount_Checking__c=50000);
        insert CustomSetting ;

    }

    static testMethod void HeavyPDFRedirectControllerTest1() {
        //Test ASI_CRM_CN_HeavyPDFRedirectController2nd

        //ASI_TH_CRM_Contract__c ContractInserted=  ASI_CRM_CN_HeavyContractTestClassHelper.CreateSimpleContract();

        test.startTest();

        List<ASI_CRM_AccountsAdditionalField__c> Customers = [SELECT Id,Name from ASI_CRM_AccountsAdditionalField__c WHERE ASI_CRM_CN_Parent_Outlet__c = null];
        System.debug(LoggingLevel.INFO, '*** Customers: ' + Customers);

        Date PO_Start_Date = date.newinstance(system.today().year(), system.today().month(), 1);
        Date PO_End_Date = PO_Start_Date.addMonths(1)-1;

        ASI_TH_CRM_Contract__c ContractInserted = new ASI_TH_CRM_Contract__c(recordtypeid = Global_RecordTypeCache.getRTID('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract'),
            ASI_CRM_CN_Status__c = 'Final',
            ASI_CRM_CN_PO_Start_Date__c = PO_Start_Date,
            ASI_CRM_CN_PO_End_Date__c =PO_End_Date,
            ASI_CRM_CN_PO_Version__c = '0.0',ASI_TH_CRM_Promotion_Type__c='Heavy Contract On',
            Name = 'Contract1',
            ASI_CRM_CN_Outlet_WS__c=Customers[0].Id,ASI_CRM_Volume_Option__c = 'Normal');
        System.debug(LoggingLevel.INFO, '*** ContractInserted: ' + ContractInserted);
        insert ContractInserted;

        ApexPages.Standardcontroller stdController1 = new ApexPages.Standardcontroller(ContractInserted);
        //ASI_CRM_CN_HeavyPDFRedirectController2nd con1 = new ASI_CRM_CN_HeavyPDFRedirectController2nd(stdController1);
        ASI_CRM_CN_HeavyPDFRedirectController con1 = new ASI_CRM_CN_HeavyPDFRedirectController(stdController1);


        ApexPages.CurrentPage().getparameters().put('Type', 'PDF');
        con1.CalculationRedirect();


        ApexPages.CurrentPage().getparameters().put('Type', 'POModificationPDF');
        con1.CalculationRedirect();


        ApexPages.CurrentPage().getparameters().put('Type', 'SubmitApproval');
        con1.CalculationRedirect();

        ApexPages.CurrentPage().getparameters().put('Type', 'ViewCheckPoint');
        con1.CalculationRedirect();

        test.stopTest();
    }

    static testMethod void HeavyPDFRedirectControllerTest2() {
        //Test ASI_CRM_CN_HeavyPDFRedirectController2nd
        //ASI_TH_CRM_Contract__c ContractInserted=  ASI_CRM_CN_HeavyContractTestClassHelper.CreateSimpleContract();

        /*User u = new User();
        u.id = UserInfo.getUserId();
        u.BypassTriggers__c = 'ASI_CRM_CN_Contract_TriggerClass';
        update u;*/
        test.startTest();

        List<ASI_CRM_AccountsAdditionalField__c> Customers = [SELECT Id,Name from ASI_CRM_AccountsAdditionalField__c WHERE ASI_CRM_CN_Parent_Outlet__c = null];
        System.debug(LoggingLevel.INFO, '*** Customers: ' + Customers);

        Date PO_Start_Date = date.newinstance(system.today().year(), system.today().month(), 1);
        Date PO_End_Date = PO_Start_Date.addMonths(1)-1;

        ASI_TH_CRM_Contract__c ContractInserted = new ASI_TH_CRM_Contract__c(recordtypeid = Global_RecordTypeCache.getRTID('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract'),
            ASI_CRM_CN_Status__c = 'Final',
            ASI_CRM_CN_PO_Start_Date__c = PO_Start_Date,
            ASI_CRM_CN_PO_End_Date__c =PO_End_Date,
            ASI_CRM_CN_PO_Version__c = '0.1',ASI_TH_CRM_Promotion_Type__c='Heavy Contract On',
            Name = 'Contract1',ASI_CRM_CN_Is_2nd_KPI_PO__c = true,
            ASI_CRM_CN_Outlet_WS__c=Customers[0].Id,ASI_CRM_Volume_Option__c = 'Normal');
        System.debug(LoggingLevel.INFO, '*** ContractInserted: ' + ContractInserted);
        insert ContractInserted;

        /*ASI_TH_CRM_Contract__c cloneContract = ASI_CRM_CN_HeavyContractUtilitiesClass.ArchivePO2nd(ContractInserted);
        ContractInserted.ASI_CRM_CN_PO_Version__c = '0.1';
        ContractInserted.ASI_CRM_CN_V0_0_PO_version__c = cloneContract.Id;
        ContractInserted.ASI_CRM_Auto_PO_Modification__c = true;
        update ContractInserted;*/

        ApexPages.Standardcontroller stdController1 = new ApexPages.Standardcontroller(ContractInserted);
        //ASI_CRM_CN_HeavyPDFRedirectController2nd con1 = new ASI_CRM_CN_HeavyPDFRedirectController2nd(stdController1);
        ASI_CRM_CN_HeavyPDFRedirectController con1 = new ASI_CRM_CN_HeavyPDFRedirectController(stdController1);

        ApexPages.CurrentPage().getparameters().put('Type', 'SubmitApproval');
        con1.CalculationRedirect();

        ApexPages.CurrentPage().getparameters().put('Type', 'ViewCheckPoint');
        con1.CalculationRedirect();

        ApexPages.CurrentPage().getparameters().put('Type', 'PDF');
        con1.CalculationRedirect();

        ApexPages.CurrentPage().getparameters().put('Type', 'POModificationPDF');
        con1.CalculationRedirect();

        test.stopTest();
    }
}