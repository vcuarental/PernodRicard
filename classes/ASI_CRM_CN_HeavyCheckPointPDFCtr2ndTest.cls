/**
 * @File Name          : ASI_CRM_CN_HeavyCheckPointPDFCtr2ndTest.cls
 * @Description        : 
 * @Author             : pengchen@bluelinksys.com
 * @Group              : 
 * @Last Modified By   : pengchen@bluelinksys.com
 * @Last Modified On   : 5/17/2020, 2:24:04 PM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    5/17/2020   pengchen@bluelinksys.com     Initial Version
**/
@isTest
public class ASI_CRM_CN_HeavyCheckPointPDFCtr2ndTest {
    
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

    static testMethod void CheckPointPDFTest() {
        //Test ASI_CRM_CN_HeavyCheckPointPDFCon2nd 
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

        List<ASI_Attachment__c> AttachmentList=new List<ASI_Attachment__c>();
        
        ASI_Attachment__c Attachment1=new ASI_Attachment__c (ASI_CRM_Contract__c=ContractInserted.Id,ASI_CRM_Type__c='CheckPoint-Success');
        Attachment1.ASI_CRM_Historical_Financial_Data__c='[{"Type2ndName":"","Type1stName":"","SegmentationCriteria":{"attributes":{"type":"ASI_CRM_SegmentationCriteria__c","url":"/services/data/v41.0/sobjects/ASI_CRM_SegmentationCriteria__c/aATM00000006RcKOAU"},"Id":"aATM00000006RcKOAU","ASI_CRM_RVP_Special_Approval__c":false,"ASI_CRM_Operation__c":"Greater than or Equal to","ASI_CRM_Alignment_Percentage__c":-2,"ASI_CRM_1st_Dimension__c":"New Contract V0.0 Est.","ASI_CRM_2nd_Dimension__c":"Historical Vfinal","ASI_CRM_Region__c":"aA9M00000008OKKKA2","ASI_CRM_Channel__c":"a9dM00000008YS8IAM","ASI_CRM_Financial_Indicator__c":"Trade Expenses: ROI(Actual)","ASI_CRM_Chinese_Interpretation__c":"投资回报率：新合同V0.0预估版不得比旧合同最终版少2%","ASI_CRM_English_Interpretation__c":"ROI: New Contract est. >= Historical V Final *98%","RecordTypeId":"012M000000050fsIAA","CurrencyIsoCode":"HKD","ASI_CRM_Region__r":{"attributes":{"type":"ASI_CRM_Region__c","url":"/services/data/v41.0/sobjects/ASI_CRM_Region__c/aA9M00000008OKKKA2"},"Name":"North West Region","Id":"aA9M00000008OKKKA2","RecordTypeId":"012M00000000VhiIAE","CurrencyIsoCode":"EUR"}},"ReachTarget":"Yes","Period2ndResult":"2017-11-23","Period1stResult":"2017-11-23","DisplayToUser":false,"Display2ndResult":"旧合同最终版 = 1.74","Display1stResult":"新合同V0.0预估= 1.72","Dimension2ndResult":1.73760088211606633611224276870796,"Dimension1stResult":1.72},{"Type2ndName":"","Type1stName":"","SegmentationCriteria":{"attributes":{"type":"ASI_CRM_SegmentationCriteria__c","url":"/services/data/v41.0/sobjects/ASI_CRM_SegmentationCriteria__c/aATM00000006RXLOA2"},"Id":"aATM00000006RXLOA2","ASI_CRM_RVP_Special_Approval__c":false,"ASI_CRM_Operation__c":"Less than or Equal to","ASI_CRM_Alignment_Percentage__c":15,"ASI_CRM_1st_Dimension__c":"New Contract V0.0 Est.","ASI_CRM_2nd_Dimension__c":"Historical Vfinal","ASI_CRM_Region__c":"aA9M00000008OKKKA2","ASI_CRM_Channel__c":"a9dM00000008YS8IAM","ASI_CRM_Financial_Indicator__c":"Volume: Total","ASI_CRM_Chinese_Interpretation__c":"总销量(9L): 新合同V0.0预估版不得比旧合同最终版多15%","ASI_CRM_English_Interpretation__c":"Total Volume (9L): New Contract V0.0 Est. <= Historical V Final*115%","RecordTypeId":"012M000000050fsIAA","CurrencyIsoCode":"HKD","ASI_CRM_Region__r":{"attributes":{"type":"ASI_CRM_Region__c","url":"/services/data/v41.0/sobjects/ASI_CRM_Region__c/aA9M00000008OKKKA2"},"Name":"North West Region","Id":"aA9M00000008OKKKA2","RecordTypeId":"012M00000000VhiIAE","CurrencyIsoCode":"EUR"}},"ReachTarget":"Yes","Period2ndResult":"2017-11-23","Period1stResult":"2017-11-23","DisplayToUser":true,"Display2ndResult":"旧合同最终版 = 1455","Display1stResult":"新合同V0.0预估= 694","Dimension2ndResult":1455,"Dimension1stResult":694},{"Type2ndName":"aGmM0000000002BKAQ","Type1stName":"aGmM0000000002BKAQ","SegmentationCriteria":{"attributes":{"type":"ASI_CRM_SegmentationCriteria__c","url":"/services/data/v41.0/sobjects/ASI_CRM_SegmentationCriteria__c/aATM00000006RXEOA2"},"Id":"aATM00000006RXEOA2","ASI_CRM_RVP_Special_Approval__c":true,"ASI_CRM_Operation__c":"Equal to","AS_CRM_Predefined_Theoretical_Value__c":"PRC Default Methodology","ASI_CRM_1st_Dimension__c":"New Contract V0.0 Est.","ASI_CRM_Region__c":"aA9M00000008OKKKA2","ASI_CRM_Channel__c":"a9dM00000008YS8IAM","ASI_CRM_Financial_Indicator__c":"Methodology: BRSF Methodology","ASI_CRM_Chinese_Interpretation__c":"公司建议空瓶回收费(BRSF)计算方式：进货量与空瓶取小支付","ASI_CRM_English_Interpretation__c":"BRSF Default Methodology: Min (BC, Intake)","RecordTypeId":"012M000000050fsIAA","CurrencyIsoCode":"HKD","ASI_CRM_Region__r":{"attributes":{"type":"ASI_CRM_Region__c","url":"/services/data/v41.0/sobjects/ASI_CRM_Region__c/aA9M00000008OKKKA2"},"Name":"North West Region","Id":"aA9M00000008OKKKA2","RecordTypeId":"012M00000000VhiIAE","CurrencyIsoCode":"EUR"}},"ReachTarget":"Yes","Period2ndResult":"2017-11-23","Period1stResult":"2017-11-23","DisplayToUser":true,"Display2ndResult":"公司建议计算方式=Min (BC, Intake)(进货量与空瓶取小支付)","Display1stResult":"新合同V0.0预估=Min (BC, Intake)(进货量与空瓶取小支付)","Dimension2ndResult":0.0,"Dimension1stResult":0.0},{"Type2ndName":"aGmM0000000002fKAA","Type1stName":"aGmM0000000002fKAA;","SegmentationCriteria":{"attributes":{"type":"ASI_CRM_SegmentationCriteria__c","url":"/services/data/v41.0/sobjects/ASI_CRM_SegmentationCriteria__c/aATM00000006RXFOA2"},"Id":"aATM00000006RXFOA2","ASI_CRM_RVP_Special_Approval__c":true,"ASI_CRM_Operation__c":"Equal to","AS_CRM_Predefined_Theoretical_Value__c":"PRC Default Methodology","ASI_CRM_1st_Dimension__c":"New Contract V0.0 Est.","ASI_CRM_Region__c":"aA9M00000008OKKKA2","ASI_CRM_Channel__c":"a9dM00000008YS8IAM","ASI_CRM_Financial_Indicator__c":"Methodology: PSF Methodology","ASI_CRM_Chinese_Interpretation__c":"公司建议空瓶回收服务费(PSF)计算方式：若实际空瓶回收率>= V0.0空瓶回收率，进货量支付，反之，空瓶回收数支付","ASI_CRM_English_Interpretation__c":"PSF Default Methodology: BC%>=V0.0 BC%, Intake, otherwise BC","RecordTypeId":"012M000000050fsIAA","CurrencyIsoCode":"HKD","ASI_CRM_Region__r":{"attributes":{"type":"ASI_CRM_Region__c","url":"/services/data/v41.0/sobjects/ASI_CRM_Region__c/aA9M00000008OKKKA2"},"Name":"North West Region","Id":"aA9M00000008OKKKA2","RecordTypeId":"012M00000000VhiIAE","CurrencyIsoCode":"EUR"}},"ReachTarget":"Yes","Period2ndResult":"2017-11-23","Period1stResult":"2017-11-23","DisplayToUser":true,"Display2ndResult":"公司建议计算方式=BC%>=V0.0 BC%, Intake; BC%<V0.0 BC%, BC(若实际空瓶回收率>= V0.0空瓶回收率， 进货量支付，反之，空瓶数)","Display1stResult":"新合同V0.0预估=BC%>=V0.0 BC%, Intake; BC%<V0.0 BC%, BC(若实际空瓶回收率>= V0.0空瓶回收率， 进货量支付，反之，空瓶数);","Dimension2ndResult":0.0,"Dimension1stResult":0.0},{"Type2ndName":"","Type1stName":"","SegmentationCriteria":{"attributes":{"type":"ASI_CRM_SegmentationCriteria__c","url":"/services/data/v41.0/sobjects/ASI_CRM_SegmentationCriteria__c/aATM00000006RXHOA2"},"Id":"aATM00000006RXHOA2","ASI_CRM_RVP_Special_Approval__c":true,"ASI_CRM_Operation__c":"Greater than or Equal to","ASI_CRM_Alignment_Percentage__c":95,"ASI_CRM_1st_Dimension__c":"New Contract V0.0 Est.","ASI_CRM_Region__c":"aA9M00000008OKKKA2","ASI_CRM_Channel__c":"a9dM00000008YS8IAM","ASI_CRM_Financial_Indicator__c":"BC: BC%","ASI_CRM_Chinese_Interpretation__c":"空瓶回收率: 新合同需>=95%","ASI_CRM_English_Interpretation__c":"BC%: New Contract >=95%","RecordTypeId":"012M000000050fsIAA","CurrencyIsoCode":"HKD","ASI_CRM_Region__r":{"attributes":{"type":"ASI_CRM_Region__c","url":"/services/data/v41.0/sobjects/ASI_CRM_Region__c/aA9M00000008OKKKA2"},"Name":"North West Region","Id":"aA9M00000008OKKKA2","RecordTypeId":"012M00000000VhiIAE","CurrencyIsoCode":"EUR"}},"ReachTarget":"Yes","Period2ndResult":"2017-11-23","Period1stResult":"2017-11-23","DisplayToUser":true,"Display2ndResult":"建议值 = 95","Display1stResult":"新合同V0.0预估= 95","Dimension2ndResult":95,"Dimension1stResult":95}]';
        AttachmentList.add(Attachment1);
        
        ASI_Attachment__c Attachment2=new ASI_Attachment__c (ASI_CRM_Contract__c=ContractInserted.Id,ASI_CRM_Type__c='CheckPoint-Failed');
        Attachment2.ASI_CRM_Historical_Financial_Data__c='[{"Type2ndName":"By Sub Brand and By Grade.","Type1stName":"By Sub-Brand;By Grade;By Category;By Total;","SegmentationCriteria":{"attributes":{"type":"ASI_CRM_SegmentationCriteria__c","url":"/services/data/v41.0/sobjects/ASI_CRM_SegmentationCriteria__c/aATM00000006RXGOA2"},"Id":"aATM00000006RXGOA2","ASI_CRM_RVP_Special_Approval__c":true,"ASI_CRM_Operation__c":"Equal to","AS_CRM_Predefined_Theoretical_Value__c":"PRC Default Volume Base","ASI_CRM_1st_Dimension__c":"New Contract V0.0 Est.","ASI_CRM_Region__c":"aA9M00000008OKKKA2","ASI_CRM_Channel__c":"a9dM00000008YS8IAM","ASI_CRM_Financial_Indicator__c":"Methodology: PSF Volume Base","ASI_CRM_Chinese_Interpretation__c":"公司建议空瓶回收服务费(PSF)销量计算基础：按品牌或按品牌档次","ASI_CRM_English_Interpretation__c":"PSF Default Volume Base: By Sub-brand or By Grade","RecordTypeId":"012M000000050fsIAA","CurrencyIsoCode":"HKD","ASI_CRM_Region__r":{"attributes":{"type":"ASI_CRM_Region__c","url":"/services/data/v41.0/sobjects/ASI_CRM_Region__c/aA9M00000008OKKKA2"},"Name":"North West Region","Id":"aA9M00000008OKKKA2","RecordTypeId":"012M00000000VhiIAE","CurrencyIsoCode":"EUR"}},"ReachTarget":"No","Period2ndResult":"2017-11-23","Period1stResult":"2017-11-23","DisplayToUser":true,"Display2ndResult":"公司建议计算基础=By Sub-Brand (按品牌) or By Grade(按品牌档次).","Display1stResult":"新合同V0.0预估=By Sub-Brand;By Grade;By Category;By Total;","Dimension2ndResult":0.0,"Dimension1stResult":0.0},{"Type2ndName":"","Type1stName":"","SegmentationCriteria":{"attributes":{"type":"ASI_CRM_SegmentationCriteria__c","url":"/services/data/v41.0/sobjects/ASI_CRM_SegmentationCriteria__c/aATM00000006RXIOA2"},"Id":"aATM00000006RXIOA2","ASI_CRM_RVP_Special_Approval__c":false,"ASI_CRM_Operation__c":"Less than or Equal to","ASI_CRM_Alignment_Percentage__c":15,"ASI_CRM_1st_Dimension__c":"New Contract V0.0 Est.","ASI_CRM_Region__c":"aA9M00000008OKKKA2","ASI_CRM_Channel__c":"a9dM00000008YS8IAM","ASI_CRM_Financial_Indicator__c":"Trade Expenses: Fixed Expense %","ASI_CRM_Chinese_Interpretation__c":"固定费用比例：新合同V0.0预估版需 <=15%","ASI_CRM_English_Interpretation__c":"Fixed Expense%: New Contract V0.0 Est. <=15%","RecordTypeId":"012M000000050fsIAA","CurrencyIsoCode":"HKD","ASI_CRM_Region__r":{"attributes":{"type":"ASI_CRM_Region__c","url":"/services/data/v41.0/sobjects/ASI_CRM_Region__c/aA9M00000008OKKKA2"},"Name":"North West Region","Id":"aA9M00000008OKKKA2","RecordTypeId":"012M00000000VhiIAE","CurrencyIsoCode":"EUR"}},"ReachTarget":"No","Period2ndResult":"2017-11-23","Period1stResult":"2017-11-23","DisplayToUser":true,"Display2ndResult":"建议值 = 15","Display1stResult":"新合同V0.0预估= 46","Dimension2ndResult":15,"Dimension1stResult":46},{"Type2ndName":"","Type1stName":"","SegmentationCriteria":{"attributes":{"type":"ASI_CRM_SegmentationCriteria__c","url":"/services/data/v41.0/sobjects/ASI_CRM_SegmentationCriteria__c/aATM00000006RXJOA2"},"Id":"aATM00000006RXJOA2","ASI_CRM_RVP_Special_Approval__c":false,"ASI_CRM_Alignment_Value__c":-60.00,"ASI_CRM_Operation__c":"Less than","AS_CRM_Predefined_Theoretical_Value__c":"PO Submit Date","ASI_CRM_1st_Dimension__c":"New Contract V0.0 Est.","ASI_CRM_2nd_Dimension__c":"Predefined Theoretical Value","ASI_CRM_Region__c":"aA9M00000008OKKKA2","ASI_CRM_Channel__c":"a9dM00000008YS8IAM","ASI_CRM_Financial_Indicator__c":"Period: PO Start Date","ASI_CRM_Chinese_Interpretation__c":"合同提交日期： 需在合同开始日期60天内提交","ASI_CRM_English_Interpretation__c":"PO Submit Date: compared with PO Start Date, should submit within 60 days","RecordTypeId":"012M000000050fsIAA","CurrencyIsoCode":"HKD","ASI_CRM_Region__r":{"attributes":{"type":"ASI_CRM_Region__c","url":"/services/data/v41.0/sobjects/ASI_CRM_Region__c/aA9M00000008OKKKA2"},"Name":"North West Region","Id":"aA9M00000008OKKKA2","RecordTypeId":"012M00000000VhiIAE","CurrencyIsoCode":"EUR"}},"ReachTarget":"No","Period2ndResult":"2017-11-23","Period1stResult":"2017-07-01","DisplayToUser":true,"Display2ndResult":"PO提交日期=Today (今天)-60 day(s).","Display1stResult":"新合同V0.0预估 = 7/1/2017","Dimension2ndResult":0.0,"Dimension1stResult":0.0},{"Type2ndName":"","Type1stName":"","SegmentationCriteria":{"attributes":{"type":"ASI_CRM_SegmentationCriteria__c","url":"/services/data/v41.0/sobjects/ASI_CRM_SegmentationCriteria__c/aATM00000006RXKOA2"},"Id":"aATM00000006RXKOA2","ASI_CRM_RVP_Special_Approval__c":false,"ASI_CRM_Operation__c":"Greater than","ASI_CRM_Alignment_Percentage__c":-30,"ASI_CRM_1st_Dimension__c":"New Contract V0.0 Est.","ASI_CRM_2nd_Dimension__c":"Historical Vfinal","ASI_CRM_Region__c":"aA9M00000008OKKKA2","ASI_CRM_Channel__c":"a9dM00000008YS8IAM","ASI_CRM_Financial_Indicator__c":"Volume: Total","ASI_CRM_Chinese_Interpretation__c":"总销量(9L): 新合同V0.0预估版不得比旧合同最终版少30%","ASI_CRM_English_Interpretation__c":"Total Volume (9L): New Contract V0.0 Est. > Historical V Final*70%","RecordTypeId":"012M000000050fsIAA","CurrencyIsoCode":"HKD","ASI_CRM_Region__r":{"attributes":{"type":"ASI_CRM_Region__c","url":"/services/data/v41.0/sobjects/ASI_CRM_Region__c/aA9M00000008OKKKA2"},"Name":"North West Region","Id":"aA9M00000008OKKKA2","RecordTypeId":"012M00000000VhiIAE","CurrencyIsoCode":"EUR"}},"ReachTarget":"No","Period2ndResult":"2017-11-23","Period1stResult":"2017-11-23","DisplayToUser":true,"Display2ndResult":"旧合同最终版 = 1455","Display1stResult":"新合同V0.0预估= 694","Dimension2ndResult":1455,"Dimension1stResult":694}]';
        AttachmentList.add(Attachment2);
        insert AttachmentList;

        ApexPages.Standardcontroller stdController = new ApexPages.Standardcontroller(ContractInserted);  
        //ASI_CRM_CN_HeavyCheckPointPDFCon2nd con = new ASI_CRM_CN_HeavyCheckPointPDFCon2nd(stdController);
        ASI_CRM_CN_HeavyCheckPointPDFController con = new ASI_CRM_CN_HeavyCheckPointPDFController(stdController);

        con.currentHeaderId= ContractInserted.id;  
        con.strPDF = '0';
        //con.init();
        con.initPage();


        test.stopTest(); 
    }

    static testMethod void CheckPointPDFTest1() {
        //Test ASI_CRM_CN_HeavyCheckPointPDFCon2nd 
        //ASI_TH_CRM_Contract__c ContractInserted=  ASI_CRM_CN_HeavyContractTestClassHelper.CreateSimpleContract();

        test.startTest();
        
        List<ASI_CRM_AccountsAdditionalField__c> Customers = [SELECT Id,Name from ASI_CRM_AccountsAdditionalField__c WHERE ASI_CRM_CN_Parent_Outlet__c = null];
        System.debug(LoggingLevel.INFO, '*** Customers: ' + Customers);

        Date PO_Start_Date = date.newinstance(system.today().year(), system.today().month(), 1);
        Date PO_End_Date = PO_Start_Date.addMonths(1)-1;

        ASI_TH_CRM_Contract__c ContractInserted = new ASI_TH_CRM_Contract__c(recordtypeid = Global_RecordTypeCache.getRTID('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract'),
            ASI_CRM_CN_Status__c = 'Final',
            ASI_CRM_CN_PO_Start_Date__c = PO_Start_Date,
            ASI_CRM_CN_PO_End_Date__c =PO_End_Date,ASI_CRM_CN_Is_2nd_KPI_PO__c = true,
            ASI_CRM_CN_PO_Version__c = '0.0',ASI_TH_CRM_Promotion_Type__c='Heavy Contract On',
            Name = 'Contract1',
            ASI_CRM_CN_Outlet_WS__c=Customers[0].Id,ASI_CRM_Volume_Option__c = 'Normal');
        System.debug(LoggingLevel.INFO, '*** ContractInserted: ' + ContractInserted);
        insert ContractInserted;
        
        List<ASI_Attachment__c> AttachmentList=new List<ASI_Attachment__c>();
        
        ASI_Attachment__c Attachment1=new ASI_Attachment__c (ASI_CRM_Contract__c=ContractInserted.Id,ASI_CRM_Type__c='CheckPoint-Success');
        Attachment1.ASI_CRM_Historical_Financial_Data__c='[{"Type2ndName":"","Type1stName":"","SegmentationCriteria":{"attributes":{"type":"ASI_CRM_SegmentationCriteria__c","url":"/services/data/v41.0/sobjects/ASI_CRM_SegmentationCriteria__c/aATM00000006RcKOAU"},"Id":"aATM00000006RcKOAU","ASI_CRM_RVP_Special_Approval__c":false,"ASI_CRM_Operation__c":"Greater than or Equal to","ASI_CRM_Alignment_Percentage__c":-2,"ASI_CRM_1st_Dimension__c":"New Contract V0.0 Est.","ASI_CRM_2nd_Dimension__c":"Historical Vfinal","ASI_CRM_Region__c":"aA9M00000008OKKKA2","ASI_CRM_Channel__c":"a9dM00000008YS8IAM","ASI_CRM_Financial_Indicator__c":"Trade Expenses: ROI(Actual)","ASI_CRM_Chinese_Interpretation__c":"投资回报率：新合同V0.0预估版不得比旧合同最终版少2%","ASI_CRM_English_Interpretation__c":"ROI: New Contract est. >= Historical V Final *98%","RecordTypeId":"012M000000050fsIAA","CurrencyIsoCode":"HKD","ASI_CRM_Region__r":{"attributes":{"type":"ASI_CRM_Region__c","url":"/services/data/v41.0/sobjects/ASI_CRM_Region__c/aA9M00000008OKKKA2"},"Name":"North West Region","Id":"aA9M00000008OKKKA2","RecordTypeId":"012M00000000VhiIAE","CurrencyIsoCode":"EUR"}},"ReachTarget":"Yes","Period2ndResult":"2017-11-23","Period1stResult":"2017-11-23","DisplayToUser":false,"Display2ndResult":"旧合同最终版 = 1.74","Display1stResult":"新合同V0.0预估= 1.72","Dimension2ndResult":1.73760088211606633611224276870796,"Dimension1stResult":1.72},{"Type2ndName":"","Type1stName":"","SegmentationCriteria":{"attributes":{"type":"ASI_CRM_SegmentationCriteria__c","url":"/services/data/v41.0/sobjects/ASI_CRM_SegmentationCriteria__c/aATM00000006RXLOA2"},"Id":"aATM00000006RXLOA2","ASI_CRM_RVP_Special_Approval__c":false,"ASI_CRM_Operation__c":"Less than or Equal to","ASI_CRM_Alignment_Percentage__c":15,"ASI_CRM_1st_Dimension__c":"New Contract V0.0 Est.","ASI_CRM_2nd_Dimension__c":"Historical Vfinal","ASI_CRM_Region__c":"aA9M00000008OKKKA2","ASI_CRM_Channel__c":"a9dM00000008YS8IAM","ASI_CRM_Financial_Indicator__c":"Volume: Total","ASI_CRM_Chinese_Interpretation__c":"总销量(9L): 新合同V0.0预估版不得比旧合同最终版多15%","ASI_CRM_English_Interpretation__c":"Total Volume (9L): New Contract V0.0 Est. <= Historical V Final*115%","RecordTypeId":"012M000000050fsIAA","CurrencyIsoCode":"HKD","ASI_CRM_Region__r":{"attributes":{"type":"ASI_CRM_Region__c","url":"/services/data/v41.0/sobjects/ASI_CRM_Region__c/aA9M00000008OKKKA2"},"Name":"North West Region","Id":"aA9M00000008OKKKA2","RecordTypeId":"012M00000000VhiIAE","CurrencyIsoCode":"EUR"}},"ReachTarget":"Yes","Period2ndResult":"2017-11-23","Period1stResult":"2017-11-23","DisplayToUser":true,"Display2ndResult":"旧合同最终版 = 1455","Display1stResult":"新合同V0.0预估= 694","Dimension2ndResult":1455,"Dimension1stResult":694},{"Type2ndName":"aGmM0000000002BKAQ","Type1stName":"aGmM0000000002BKAQ","SegmentationCriteria":{"attributes":{"type":"ASI_CRM_SegmentationCriteria__c","url":"/services/data/v41.0/sobjects/ASI_CRM_SegmentationCriteria__c/aATM00000006RXEOA2"},"Id":"aATM00000006RXEOA2","ASI_CRM_RVP_Special_Approval__c":true,"ASI_CRM_Operation__c":"Equal to","AS_CRM_Predefined_Theoretical_Value__c":"PRC Default Methodology","ASI_CRM_1st_Dimension__c":"New Contract V0.0 Est.","ASI_CRM_Region__c":"aA9M00000008OKKKA2","ASI_CRM_Channel__c":"a9dM00000008YS8IAM","ASI_CRM_Financial_Indicator__c":"Methodology: BRSF Methodology","ASI_CRM_Chinese_Interpretation__c":"公司建议空瓶回收费(BRSF)计算方式：进货量与空瓶取小支付","ASI_CRM_English_Interpretation__c":"BRSF Default Methodology: Min (BC, Intake)","RecordTypeId":"012M000000050fsIAA","CurrencyIsoCode":"HKD","ASI_CRM_Region__r":{"attributes":{"type":"ASI_CRM_Region__c","url":"/services/data/v41.0/sobjects/ASI_CRM_Region__c/aA9M00000008OKKKA2"},"Name":"North West Region","Id":"aA9M00000008OKKKA2","RecordTypeId":"012M00000000VhiIAE","CurrencyIsoCode":"EUR"}},"ReachTarget":"Yes","Period2ndResult":"2017-11-23","Period1stResult":"2017-11-23","DisplayToUser":true,"Display2ndResult":"公司建议计算方式=Min (BC, Intake)(进货量与空瓶取小支付)","Display1stResult":"新合同V0.0预估=Min (BC, Intake)(进货量与空瓶取小支付)","Dimension2ndResult":0.0,"Dimension1stResult":0.0},{"Type2ndName":"aGmM0000000002fKAA","Type1stName":"aGmM0000000002fKAA;","SegmentationCriteria":{"attributes":{"type":"ASI_CRM_SegmentationCriteria__c","url":"/services/data/v41.0/sobjects/ASI_CRM_SegmentationCriteria__c/aATM00000006RXFOA2"},"Id":"aATM00000006RXFOA2","ASI_CRM_RVP_Special_Approval__c":true,"ASI_CRM_Operation__c":"Equal to","AS_CRM_Predefined_Theoretical_Value__c":"PRC Default Methodology","ASI_CRM_1st_Dimension__c":"New Contract V0.0 Est.","ASI_CRM_Region__c":"aA9M00000008OKKKA2","ASI_CRM_Channel__c":"a9dM00000008YS8IAM","ASI_CRM_Financial_Indicator__c":"Methodology: PSF Methodology","ASI_CRM_Chinese_Interpretation__c":"公司建议空瓶回收服务费(PSF)计算方式：若实际空瓶回收率>= V0.0空瓶回收率，进货量支付，反之，空瓶回收数支付","ASI_CRM_English_Interpretation__c":"PSF Default Methodology: BC%>=V0.0 BC%, Intake, otherwise BC","RecordTypeId":"012M000000050fsIAA","CurrencyIsoCode":"HKD","ASI_CRM_Region__r":{"attributes":{"type":"ASI_CRM_Region__c","url":"/services/data/v41.0/sobjects/ASI_CRM_Region__c/aA9M00000008OKKKA2"},"Name":"North West Region","Id":"aA9M00000008OKKKA2","RecordTypeId":"012M00000000VhiIAE","CurrencyIsoCode":"EUR"}},"ReachTarget":"Yes","Period2ndResult":"2017-11-23","Period1stResult":"2017-11-23","DisplayToUser":true,"Display2ndResult":"公司建议计算方式=BC%>=V0.0 BC%, Intake; BC%<V0.0 BC%, BC(若实际空瓶回收率>= V0.0空瓶回收率， 进货量支付，反之，空瓶数)","Display1stResult":"新合同V0.0预估=BC%>=V0.0 BC%, Intake; BC%<V0.0 BC%, BC(若实际空瓶回收率>= V0.0空瓶回收率， 进货量支付，反之，空瓶数);","Dimension2ndResult":0.0,"Dimension1stResult":0.0},{"Type2ndName":"","Type1stName":"","SegmentationCriteria":{"attributes":{"type":"ASI_CRM_SegmentationCriteria__c","url":"/services/data/v41.0/sobjects/ASI_CRM_SegmentationCriteria__c/aATM00000006RXHOA2"},"Id":"aATM00000006RXHOA2","ASI_CRM_RVP_Special_Approval__c":true,"ASI_CRM_Operation__c":"Greater than or Equal to","ASI_CRM_Alignment_Percentage__c":95,"ASI_CRM_1st_Dimension__c":"New Contract V0.0 Est.","ASI_CRM_Region__c":"aA9M00000008OKKKA2","ASI_CRM_Channel__c":"a9dM00000008YS8IAM","ASI_CRM_Financial_Indicator__c":"BC: BC%","ASI_CRM_Chinese_Interpretation__c":"空瓶回收率: 新合同需>=95%","ASI_CRM_English_Interpretation__c":"BC%: New Contract >=95%","RecordTypeId":"012M000000050fsIAA","CurrencyIsoCode":"HKD","ASI_CRM_Region__r":{"attributes":{"type":"ASI_CRM_Region__c","url":"/services/data/v41.0/sobjects/ASI_CRM_Region__c/aA9M00000008OKKKA2"},"Name":"North West Region","Id":"aA9M00000008OKKKA2","RecordTypeId":"012M00000000VhiIAE","CurrencyIsoCode":"EUR"}},"ReachTarget":"Yes","Period2ndResult":"2017-11-23","Period1stResult":"2017-11-23","DisplayToUser":true,"Display2ndResult":"建议值 = 95","Display1stResult":"新合同V0.0预估= 95","Dimension2ndResult":95,"Dimension1stResult":95}]';
        AttachmentList.add(Attachment1);
        
        ASI_Attachment__c Attachment2=new ASI_Attachment__c (ASI_CRM_Contract__c=ContractInserted.Id,ASI_CRM_Type__c='CheckPoint-Failed');
        Attachment2.ASI_CRM_Historical_Financial_Data__c='[{"Type2ndName":"By Sub Brand and By Grade.","Type1stName":"By Sub-Brand;By Grade;By Category;By Total;","SegmentationCriteria":{"attributes":{"type":"ASI_CRM_SegmentationCriteria__c","url":"/services/data/v41.0/sobjects/ASI_CRM_SegmentationCriteria__c/aATM00000006RXGOA2"},"Id":"aATM00000006RXGOA2","ASI_CRM_RVP_Special_Approval__c":true,"ASI_CRM_Operation__c":"Equal to","AS_CRM_Predefined_Theoretical_Value__c":"PRC Default Volume Base","ASI_CRM_1st_Dimension__c":"New Contract V0.0 Est.","ASI_CRM_Region__c":"aA9M00000008OKKKA2","ASI_CRM_Channel__c":"a9dM00000008YS8IAM","ASI_CRM_Financial_Indicator__c":"Methodology: PSF Volume Base","ASI_CRM_Chinese_Interpretation__c":"公司建议空瓶回收服务费(PSF)销量计算基础：按品牌或按品牌档次","ASI_CRM_English_Interpretation__c":"PSF Default Volume Base: By Sub-brand or By Grade","RecordTypeId":"012M000000050fsIAA","CurrencyIsoCode":"HKD","ASI_CRM_Region__r":{"attributes":{"type":"ASI_CRM_Region__c","url":"/services/data/v41.0/sobjects/ASI_CRM_Region__c/aA9M00000008OKKKA2"},"Name":"North West Region","Id":"aA9M00000008OKKKA2","RecordTypeId":"012M00000000VhiIAE","CurrencyIsoCode":"EUR"}},"ReachTarget":"No","Period2ndResult":"2017-11-23","Period1stResult":"2017-11-23","DisplayToUser":true,"Display2ndResult":"公司建议计算基础=By Sub-Brand (按品牌) or By Grade(按品牌档次).","Display1stResult":"新合同V0.0预估=By Sub-Brand;By Grade;By Category;By Total;","Dimension2ndResult":0.0,"Dimension1stResult":0.0},{"Type2ndName":"","Type1stName":"","SegmentationCriteria":{"attributes":{"type":"ASI_CRM_SegmentationCriteria__c","url":"/services/data/v41.0/sobjects/ASI_CRM_SegmentationCriteria__c/aATM00000006RXIOA2"},"Id":"aATM00000006RXIOA2","ASI_CRM_RVP_Special_Approval__c":false,"ASI_CRM_Operation__c":"Less than or Equal to","ASI_CRM_Alignment_Percentage__c":15,"ASI_CRM_1st_Dimension__c":"New Contract V0.0 Est.","ASI_CRM_Region__c":"aA9M00000008OKKKA2","ASI_CRM_Channel__c":"a9dM00000008YS8IAM","ASI_CRM_Financial_Indicator__c":"Trade Expenses: Fixed Expense %","ASI_CRM_Chinese_Interpretation__c":"固定费用比例：新合同V0.0预估版需 <=15%","ASI_CRM_English_Interpretation__c":"Fixed Expense%: New Contract V0.0 Est. <=15%","RecordTypeId":"012M000000050fsIAA","CurrencyIsoCode":"HKD","ASI_CRM_Region__r":{"attributes":{"type":"ASI_CRM_Region__c","url":"/services/data/v41.0/sobjects/ASI_CRM_Region__c/aA9M00000008OKKKA2"},"Name":"North West Region","Id":"aA9M00000008OKKKA2","RecordTypeId":"012M00000000VhiIAE","CurrencyIsoCode":"EUR"}},"ReachTarget":"No","Period2ndResult":"2017-11-23","Period1stResult":"2017-11-23","DisplayToUser":true,"Display2ndResult":"建议值 = 15","Display1stResult":"新合同V0.0预估= 46","Dimension2ndResult":15,"Dimension1stResult":46},{"Type2ndName":"","Type1stName":"","SegmentationCriteria":{"attributes":{"type":"ASI_CRM_SegmentationCriteria__c","url":"/services/data/v41.0/sobjects/ASI_CRM_SegmentationCriteria__c/aATM00000006RXJOA2"},"Id":"aATM00000006RXJOA2","ASI_CRM_RVP_Special_Approval__c":false,"ASI_CRM_Alignment_Value__c":-60.00,"ASI_CRM_Operation__c":"Less than","AS_CRM_Predefined_Theoretical_Value__c":"PO Submit Date","ASI_CRM_1st_Dimension__c":"New Contract V0.0 Est.","ASI_CRM_2nd_Dimension__c":"Predefined Theoretical Value","ASI_CRM_Region__c":"aA9M00000008OKKKA2","ASI_CRM_Channel__c":"a9dM00000008YS8IAM","ASI_CRM_Financial_Indicator__c":"Period: PO Start Date","ASI_CRM_Chinese_Interpretation__c":"合同提交日期： 需在合同开始日期60天内提交","ASI_CRM_English_Interpretation__c":"PO Submit Date: compared with PO Start Date, should submit within 60 days","RecordTypeId":"012M000000050fsIAA","CurrencyIsoCode":"HKD","ASI_CRM_Region__r":{"attributes":{"type":"ASI_CRM_Region__c","url":"/services/data/v41.0/sobjects/ASI_CRM_Region__c/aA9M00000008OKKKA2"},"Name":"North West Region","Id":"aA9M00000008OKKKA2","RecordTypeId":"012M00000000VhiIAE","CurrencyIsoCode":"EUR"}},"ReachTarget":"No","Period2ndResult":"2017-11-23","Period1stResult":"2017-07-01","DisplayToUser":true,"Display2ndResult":"PO提交日期=Today (今天)-60 day(s).","Display1stResult":"新合同V0.0预估 = 7/1/2017","Dimension2ndResult":0.0,"Dimension1stResult":0.0},{"Type2ndName":"","Type1stName":"","SegmentationCriteria":{"attributes":{"type":"ASI_CRM_SegmentationCriteria__c","url":"/services/data/v41.0/sobjects/ASI_CRM_SegmentationCriteria__c/aATM00000006RXKOA2"},"Id":"aATM00000006RXKOA2","ASI_CRM_RVP_Special_Approval__c":false,"ASI_CRM_Operation__c":"Greater than","ASI_CRM_Alignment_Percentage__c":-30,"ASI_CRM_1st_Dimension__c":"New Contract V0.0 Est.","ASI_CRM_2nd_Dimension__c":"Historical Vfinal","ASI_CRM_Region__c":"aA9M00000008OKKKA2","ASI_CRM_Channel__c":"a9dM00000008YS8IAM","ASI_CRM_Financial_Indicator__c":"Volume: Total","ASI_CRM_Chinese_Interpretation__c":"总销量(9L): 新合同V0.0预估版不得比旧合同最终版少30%","ASI_CRM_English_Interpretation__c":"Total Volume (9L): New Contract V0.0 Est. > Historical V Final*70%","RecordTypeId":"012M000000050fsIAA","CurrencyIsoCode":"HKD","ASI_CRM_Region__r":{"attributes":{"type":"ASI_CRM_Region__c","url":"/services/data/v41.0/sobjects/ASI_CRM_Region__c/aA9M00000008OKKKA2"},"Name":"North West Region","Id":"aA9M00000008OKKKA2","RecordTypeId":"012M00000000VhiIAE","CurrencyIsoCode":"EUR"}},"ReachTarget":"No","Period2ndResult":"2017-11-23","Period1stResult":"2017-11-23","DisplayToUser":true,"Display2ndResult":"旧合同最终版 = 1455","Display1stResult":"新合同V0.0预估= 694","Dimension2ndResult":1455,"Dimension1stResult":694}]';
        AttachmentList.add(Attachment2);
        
        insert AttachmentList;

        ApexPages.Standardcontroller stdController = new ApexPages.Standardcontroller(ContractInserted);  
        //ASI_CRM_CN_HeavyCheckPointPDFCon2nd con = new ASI_CRM_CN_HeavyCheckPointPDFCon2nd(stdController);
        ASI_CRM_CN_HeavyCheckPointPDFController con = new ASI_CRM_CN_HeavyCheckPointPDFController(stdController);

        con.currentHeaderId= ContractInserted.id;  
        con.strPDF = '2';
        con.initPage();

        con.strPDF = '0';
        con.initPage();

        test.stopTest(); 
    }
}