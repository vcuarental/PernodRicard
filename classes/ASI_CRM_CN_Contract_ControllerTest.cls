/**
 * @File Name          : ASI_CRM_CN_Contract_ControllerTest.cls
 * @Description        : 
 * @Author             : pengchen@bluelinksys.com
 * @Group              : 
 * @Last Modified By   : pengchen@bluelinksys.com
 * @Last Modified On   : 5/21/2020, 6:25:33 PM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    5/18/2020   pengchen@bluelinksys.com     Initial Version
**/
@isTest
public class ASI_CRM_CN_Contract_ControllerTest {
    static testMethod void ASI_CRM_CN_Contract_Controller_TEST_1() {

        Id rtContract = Global_RecordTypeCache.getRtId('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract');
        Id rtOutlet = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN');
        Id rtWS = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_CN_WS');
        ASI_CRM_Region__c region = new ASI_CRM_Region__c (Name='Central Region',recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Region__cASI_CRM_CN_Region'),ASI_CRM_Create_Heavy_Contract_On__c=true,ASI_CRM_CN_Is_2nd_KPI_PO__c=true,ASI_CRM_CN_Create_TOT_MOT_Contract__c=true);
        insert region;
        
        ASI_CRM_Division__c division = new ASI_CRM_Division__c(Name='TEST', ASI_CRM_Region__c=region.Id);
        insert division;
        
        ASI_CRM_CN_Area__c area = new ASI_CRM_CN_Area__c(Name='TEST', ASI_CRM_English_Name__c='TEST', ASI_CRM_Division__c=division.Id);
        insert area;
        
        ASI_CRM_City__c city = new ASI_CRM_City__c(Name='TEST', ASI_CRM_CN_Area__c=area.Id,ASI_CRM_CN_City_Tier__c='2');
        insert city;

        ASI_CRM_CN_Channel__c channel = new ASI_CRM_CN_Channel__c(ASI_CRM_CN_On_Off__c='ON');
        insert channel;

        ASI_MFM_Sub_Channel__c subChannel = new ASI_MFM_Sub_Channel__c(ASI_CRM_CN_Channel__c=channel.Id);
        insert subChannel;
        
        ASI_CRM_CN_Channel__c newChannel = new ASI_CRM_CN_Channel__c(ASI_CRM_For_Outlet__c = true, Name='Restaurant',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CN_Channel__cASI_CRM_CN_New_Channel'),ASI_CRM_CN_On_Off__c='OFF');
        insert newChannel;

        list<ASI_CRM_AccountsAdditionalField__c> a2s = new list<ASI_CRM_AccountsAdditionalField__c>();
        a2s.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Commercial_Team__c = 'Premium',
            RecordTypeId=rtWS,
            Name='TEST', 
            ASI_CRM_CN_Image__c='Iconic',
            ASI_CRM_CN_CCity__c=city.Id,
            ASI_CRM_CN_Sub_Channel__c=subChannel.Id,ASI_CRM_CN_NewChannel__c=newChannel.Id));
        a2s.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Commercial_Team__c = 'Premium',
            RecordTypeId=rtOutlet,
            Name='TEST', 
            ASI_CRM_CN_Image__c='Iconic',
            ASI_CRM_CN_CCity__c=city.Id,
            ASI_CRM_CN_Sub_Channel__c=subChannel.Id,ASI_CRM_CN_NewChannel__c=newChannel.Id));
        insert a2s;

        a2s = [SELECT Id, ASI_CRM_Account__c FROM ASI_CRM_AccountsAdditionalField__c WHERE Id=:a2s[0].Id OR Id=:a2s[1].Id];

        User currentUser = [SELECT id, name, Managerid, ASI_CRM_CN_Prefix__c FROM USER WHERE id =:UserInfo.getUserId()];

        list<ASI_HK_CRM_Running_Number__c> rns = new list<ASI_HK_CRM_Running_Number__c>();
        rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_TH_CRM_Contract__c', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        if(!String.isBlank(currentUser.ASI_CRM_CN_Prefix__c))
            rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_'+currentUser.ASI_CRM_CN_Prefix__c, recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        else{
            rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_NULL', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
            rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        }
        rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_TH_CRM_PaymentRequest__c', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        insert rns;

        ASI_MFM_Brand__c brand = new ASI_MFM_Brand__c (
            ASI_CRM_CN_Competitor__c=false);
        insert brand;

        list<ASI_MFM_Sub_brand__c> subBrands = new list<ASI_MFM_Sub_brand__c>();
        subBrands.add(new ASI_MFM_Sub_brand__c (ASI_MFM_Brand__c=brand.Id, ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1, ASI_MFM_Active_for_CRM__c=true, ASI_MFM_Sub_brand_Code__c='999',
            RecordTypeId=Global_RecordTypeCache.getRTid('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand')));
        subBrands.add(new ASI_MFM_Sub_brand__c (ASI_MFM_Brand__c=brand.Id, ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1));
        insert subBrands;

        list<ASI_TH_CRM_Contract__c> cts = new list<ASI_TH_CRM_Contract__c>();
        cts.add(new ASI_TH_CRM_Contract__c(
            RecordTypeId=rtContract,
            ASI_TH_CRM_Outlet__c=a2s[1].ASI_CRM_Account__c,
            ASI_CRM_CN_PO_Start_Date__c=system.today().addMonths(-4),
            ASI_CRM_CN_PO_End_Date__c=system.today().addMonths(-3),
            ASI_CRM_CN_Outlet_WS__c=a2s[0].Id,
            ASI_TH_CRM_Promotion_Type__c='New Contract ON',
            ASI_CRM_CN_PO_Version__c = '0.0',
            Name = 'Contract1',
            ASI_CRM_CN_PO_Modification__c=false,
            ASI_CRM_CN_Status__c='Final'));
        insert cts[0];
        cts.add(new ASI_TH_CRM_Contract__c(
            RecordTypeId=rtContract,
            ASI_TH_CRM_Outlet__c=a2s[1].ASI_CRM_Account__c,
            ASI_CRM_CN_PO_Start_Date__c=system.today().addMonths(-2),
            ASI_CRM_CN_PO_End_Date__c=system.today().addMonths(-1),
            ASI_CRM_CN_Outlet_WS__c=a2s[0].Id,
            ASI_TH_CRM_Promotion_Type__c='New Contract ON',
            ASI_CRM_CN_PO_Version__c = '0.1',
            Name = 'Contract2',
            ASI_CRM_CN_PO_Modification__c=true,
            ASI_CRM_CN_V0_0_PO_version__c=cts[0].Id,
            ASI_CRM_CN_Status__c='Draft'
        ));
        insert cts[1];

        list<FeedItem> feedItems = new list<FeedItem>();
        list<Attachment> atts = new list<Attachment>();
        list<ASI_CRM_CN_Covered_Outlet__c> cos = new list<ASI_CRM_CN_Covered_Outlet__c>();
        list<ASI_CRM_CN_Contract_BRSF_Line_Item__c> ctis = new list<ASI_CRM_CN_Contract_BRSF_Line_Item__c>();
        list<ASI_TH_CRM_PaymentRequest__c> prs = new list<ASI_TH_CRM_PaymentRequest__c>();
        list<ASI_CRM_Contract_Cost__c> ccs = new list<ASI_CRM_Contract_Cost__c>();
        for(ASI_TH_CRM_Contract__c ct :cts) {
            ctis.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(
                ASI_CRM_CN_Contract__c=ct.Id,
                ASI_CRM_CN_Est_Monthly_Qty__c=1,
                ASI_CRM_CN_Est_BRSF_Per_Bottle__c=1,
                ASI_CRM_CN_Contract_Monthly_Qty__c=1,
                ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=1,
                ASI_CRM_CN_Est_Total_Dummy__c=1,
                ASI_CRM_CN_Contract_Total_Dummy__c=1,
                ASI_CRM_CN_Sub_Brand__c=subBrands[1].Id,
                recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CN_Contract_BRSF_Line_Item')
            ));
            prs.add(new ASI_TH_CRM_PaymentRequest__c(ASI_TH_CRM_Contract__c=ct.Id, ASI_TH_CRM_Status__c='Draft',ASI_CRM_CN_Paid_In_Progress__c=1, recordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequest__cASI_CRM_CN_Payment_Request')));
            prs.add(new ASI_TH_CRM_PaymentRequest__c(ASI_TH_CRM_Contract__c=ct.Id, ASI_TH_CRM_Status__c='Approved', ASI_CRM_CN_Last_Payment__c=true,ASI_CRM_CN_Paid_In_Progress__c=1, recordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequest__cASI_CRM_CN_Payment_Request')));
            ccs.add(new ASI_CRM_Contract_Cost__c(
                Name='TEST',
                ASI_CRM_CN_Cost_Type__c='Variable',
                ASI_CRM_CN_Contract_Amount__c=1,
                ASI_CRM_CN_Estimate_Amount__c=1,
                ASI_CRM_CN_Contract__c=ct.Id));
            ccs.add(new ASI_CRM_Contract_Cost__c(
                Name='TEST',
                ASI_CRM_CN_Cost_Type__c='Fixed',
                ASI_CRM_CN_Contract_Amount__c=1,
                ASI_CRM_CN_Estimate_Amount__c=1,
                ASI_CRM_CN_Contract__c=ct.Id));
            cos.add(new ASI_CRM_CN_Covered_Outlet__c(ASI_CRM_CN_Contract__c=ct.Id,
                recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Covered_Outlet__cASI_CRM_CN_Covered_Outlet')));
            atts.add(new Attachment(Name='TEST',Body=Blob.valueOf(''),Parentid=ct.Id));
            //feedItems.add(new FeedItem(Body='TEST',ParentId=ct.Id,ContentData=Blob.valueOf('TEST'),ContentFileName='TEST.txt'));
        }
        test.startTest();
        insert ctis;
        insert prs;
        insert ccs;
        insert cos;
        insert atts;
        //insert feedItems;

        list<ApexPages.StandardController> scons = new list<ApexPages.StandardController>();
        for(ASI_TH_CRM_Contract__c ct: cts)
            scons.add(new ApexPages.StandardController(ct));

        //test.startTest();

        ASI_CRM_CN_Contract_Controller con;

        con = new ASI_CRM_CN_Contract_Controller(new ApexPages.StandardController(new ASI_TH_CRM_Contract__c()));

        ApexPages.currentPage().getParameters().put('ASI_CRM_CN_Outlet_WS__c',a2s[1].Id);
        ApexPages.currentPage().getParameters().put('ASI_TH_CRM_Promotion_Type__c','New Contract ON');
        con = new ASI_CRM_CN_Contract_Controller(new ApexPages.StandardController(new ASI_TH_CRM_Contract__c()));

        //Laputa remove  ApexPages.currentPage().getParameters().put('RecordType', Global_RecordTypeCache.getRtId('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract'));
        //Laputa remove  con = new ASI_CRM_CN_Contract_Controller(new ApexPages.StandardController(new ASI_TH_CRM_Contract__c()));

        //Laputa remove  con = new ASI_CRM_CN_Contract_Controller(scons[1]);

        /*con.POModification();
        con.UpdateContractRecord();
        con.changeContractUpload();*/
        //Laputa remove  con.changeBusinessLicense();
        //Laputa remove  con.UpdateContractDetailRecord();
        //Laputa remove  con.GoURL();
        //Laputa remove  con.checkLaterThenThisFY(date.newInstance(system.today().year(),1,1), system.today());

        /*con.GoPayment();
        con.GoEdit();
        con.GoEditDetails();
        con.GoEditOutlet();
        con.saveRedirect();
        con.submitApproval();
//        con.restorePO();
        con.AddNew_BRSF();
        con.rowidCoveredOutlet = 0;
        con.Clone_CoveredOutlet();
        for(integer j :con.BRSF_Item_Map.keySet()) {
            con.rowidBRSF = j;
            break;
        }
        con.RemoveRow_BRSF();
        con.RemoveRow_CoveredOutlet();
        con.AddNew_CoveredOutlet();
        con.ContractShuttle();
                
        insert new ASI_TH_CRM_PaymentRequest__c(ASI_TH_CRM_Contract__c=cts[1].Id, ASI_TH_CRM_Status__c='Submitted',ASI_CRM_CN_Paid_In_Progress__c=1);
        con.POModification();

        con.Total_Payments_Amount=100000000;
        con.POModification();

        con.PageId = null;
        con.UpdateContractRecord();
        
        for(integer j :con.BRSF_Item_Map.keySet()) {
            con.rowidBRSF = j;
            break;
        }
        con.Clone_BRSF();
        
        ASI_CRM_CN_Contract_Controller.findSObjects('Account',' NOT ISNULL(Id)','');
        */
        test.stopTest();
    }

    static testMethod void ASI_CRM_CN_Contract_Controller_TEST_2() {

        Id rtContract = Global_RecordTypeCache.getRtId('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract');
        Id rtWS = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_CN_WS');
        ASI_CRM_Region__c region = new ASI_CRM_Region__c (Name='Central Region',recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Region__cASI_CRM_CN_Region'),ASI_CRM_Create_Heavy_Contract_On__c=true,ASI_CRM_CN_Is_2nd_KPI_PO__c=true,ASI_CRM_CN_Create_TOT_MOT_Contract__c=true);
        insert region;
        
        ASI_CRM_Division__c division = new ASI_CRM_Division__c(Name='TEST', ASI_CRM_Region__c=region.Id);
        insert division;
        
        ASI_CRM_CN_Area__c area = new ASI_CRM_CN_Area__c(Name='TEST', ASI_CRM_English_Name__c='TEST', ASI_CRM_Division__c=division.Id);
        insert area;
        
        ASI_CRM_City__c city = new ASI_CRM_City__c(Name='TEST', ASI_CRM_CN_Area__c=area.Id,ASI_CRM_CN_City_Tier__c='2');
        insert city;

        ASI_CRM_CN_Channel__c channel = new ASI_CRM_CN_Channel__c(ASI_CRM_CN_On_Off__c='ON');
        insert channel;

        ASI_MFM_Sub_Channel__c subChannel = new ASI_MFM_Sub_Channel__c(ASI_CRM_CN_Channel__c=channel.Id);
        insert subChannel;
        
        ASI_CRM_CN_Channel__c newChannel = new ASI_CRM_CN_Channel__c(ASI_CRM_For_Outlet__c = true, Name='Restaurant',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CN_Channel__cASI_CRM_CN_New_Channel'),ASI_CRM_CN_On_Off__c='OFF');
        insert newChannel;
        Id rtOutlet = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN');
        list<ASI_CRM_AccountsAdditionalField__c> a2s = new list<ASI_CRM_AccountsAdditionalField__c>();
        a2s.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Commercial_Team__c = 'Premium',
            RecordTypeId=rtWS,
            Name='TEST', 
            ASI_CRM_CN_Image__c='Iconic',
            ASI_CRM_CN_CCity__c=city.Id,
            ASI_CRM_CN_Sub_Channel__c=subChannel.Id,ASI_CRM_CN_NewChannel__c=newChannel.Id));
        a2s.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Commercial_Team__c = 'Premium',
            RecordTypeId=rtOutlet,
            Name='TEST', 
            ASI_CRM_CN_Image__c='Iconic',
            ASI_CRM_CN_CCity__c=city.Id,
            ASI_CRM_CN_Sub_Channel__c=subChannel.Id,ASI_CRM_CN_NewChannel__c=newChannel.Id));
        insert a2s;

        a2s = [SELECT Id, ASI_CRM_Account__c FROM ASI_CRM_AccountsAdditionalField__c WHERE Id=:a2s[0].Id OR Id=:a2s[1].Id];

        User currentUser = [SELECT id, name, Managerid, ASI_CRM_CN_Prefix__c FROM USER WHERE id =:UserInfo.getUserId()];
        currentUser.BypassTriggers__c = 'ASI_CRM_CN_Contract_TriggerClass';
        update currentUser;

        list<ASI_HK_CRM_Running_Number__c> rns = new list<ASI_HK_CRM_Running_Number__c>();
        rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_TH_CRM_Contract__c', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        if(!String.isBlank(currentUser.ASI_CRM_CN_Prefix__c))
            rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_'+currentUser.ASI_CRM_CN_Prefix__c, recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        else{
            rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_NULL', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
            rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        }
        rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_TH_CRM_PaymentRequest__c', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        insert rns;

        ASI_MFM_Brand__c brand = new ASI_MFM_Brand__c (
            ASI_CRM_CN_Competitor__c=false);
        insert brand;

        list<ASI_MFM_Sub_brand__c> subBrands = new list<ASI_MFM_Sub_brand__c>();
        subBrands.add(new ASI_MFM_Sub_brand__c (ASI_MFM_Brand__c=brand.Id, ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1, ASI_MFM_Active_for_CRM__c=true, ASI_MFM_Sub_brand_Code__c='999',
            RecordTypeId=Global_RecordTypeCache.getRTid('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand')));
        subBrands.add(new ASI_MFM_Sub_brand__c (ASI_MFM_Brand__c=brand.Id, ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1));
        insert subBrands;

        list<ASI_TH_CRM_Contract__c> cts = new list<ASI_TH_CRM_Contract__c>();
        cts.add(new ASI_TH_CRM_Contract__c(
            RecordTypeId=rtContract,
            ASI_TH_CRM_Outlet__c=a2s[1].ASI_CRM_Account__c,
            ASI_CRM_CN_PO_Start_Date__c=system.today().addMonths(-4),
            ASI_CRM_CN_PO_End_Date__c=system.today().addMonths(-3),
            ASI_CRM_CN_Outlet_WS__c=a2s[0].Id,
            ASI_TH_CRM_Promotion_Type__c='New Contract ON',
            ASI_CRM_CN_PO_Version__c = '0.0',
            Name = 'Contract1',
            ASI_CRM_CN_PO_Modification__c=false,
            ASI_CRM_CN_Status__c='Final'));
        insert cts[0];
        cts.add(new ASI_TH_CRM_Contract__c(
            RecordTypeId=rtContract,
            ASI_TH_CRM_Outlet__c=a2s[1].ASI_CRM_Account__c,
            ASI_CRM_CN_PO_Start_Date__c=system.today().addMonths(-2),
            ASI_CRM_CN_PO_End_Date__c=system.today().addMonths(-1),
            ASI_CRM_CN_Outlet_WS__c=a2s[0].Id,
            ASI_TH_CRM_Promotion_Type__c='New Contract ON',
            ASI_CRM_CN_PO_Version__c = '0.1',
            Name = 'Contract2',
            ASI_CRM_CN_PO_Modification__c=true,
            ASI_CRM_CN_V0_0_PO_version__c=cts[0].Id,
            ASI_CRM_CN_Status__c='Draft'
        ));
        insert cts[1];

        //list<FeedItem> feedItems = new list<FeedItem>();
        list<Attachment> atts = new list<Attachment>();
        list<ASI_CRM_CN_Covered_Outlet__c> cos = new list<ASI_CRM_CN_Covered_Outlet__c>();
        list<ASI_CRM_CN_Contract_BRSF_Line_Item__c> ctis = new list<ASI_CRM_CN_Contract_BRSF_Line_Item__c>();
        list<ASI_TH_CRM_PaymentRequest__c> prs = new list<ASI_TH_CRM_PaymentRequest__c>();
        list<ASI_CRM_Contract_Cost__c> ccs = new list<ASI_CRM_Contract_Cost__c>();
        for(ASI_TH_CRM_Contract__c ct :cts) {
            ctis.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(
                ASI_CRM_CN_Contract__c=ct.Id,
                ASI_CRM_CN_Est_Monthly_Qty__c=1,
                ASI_CRM_CN_Est_BRSF_Per_Bottle__c=1,
                ASI_CRM_CN_Contract_Monthly_Qty__c=1,
                ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=1,
                ASI_CRM_CN_Est_Total_Dummy__c=1,
                ASI_CRM_CN_Contract_Total_Dummy__c=1,
                ASI_CRM_CN_Sub_Brand__c=subBrands[1].Id,
                recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CN_Contract_BRSF_Line_Item')
            ));
            prs.add(new ASI_TH_CRM_PaymentRequest__c(ASI_TH_CRM_Contract__c=ct.Id, ASI_TH_CRM_Status__c='Draft',ASI_CRM_CN_Paid_In_Progress__c=1, recordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequest__cASI_CRM_CN_Payment_Request')));
            prs.add(new ASI_TH_CRM_PaymentRequest__c(ASI_TH_CRM_Contract__c=ct.Id, ASI_TH_CRM_Status__c='Approved', ASI_CRM_CN_Last_Payment__c=true,ASI_CRM_CN_Paid_In_Progress__c=1, recordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequest__cASI_CRM_CN_Payment_Request')));
            ccs.add(new ASI_CRM_Contract_Cost__c(
                Name='TEST',
                ASI_CRM_CN_Cost_Type__c='Variable',
                ASI_CRM_CN_Contract_Amount__c=1,
                ASI_CRM_CN_Estimate_Amount__c=1,
                ASI_CRM_CN_Contract__c=ct.Id));
            ccs.add(new ASI_CRM_Contract_Cost__c(
                Name='TEST',
                ASI_CRM_CN_Cost_Type__c='Fixed',
                ASI_CRM_CN_Contract_Amount__c=1,
                ASI_CRM_CN_Estimate_Amount__c=1,
                ASI_CRM_CN_Contract__c=ct.Id));
            cos.add(new ASI_CRM_CN_Covered_Outlet__c(ASI_CRM_CN_Contract__c=ct.Id,
                recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Covered_Outlet__cASI_CRM_CN_Covered_Outlet')));
            atts.add(new Attachment(Name='TEST',Body=Blob.valueOf(''),Parentid=ct.Id));
            //feedItems.add(new FeedItem(Body='TEST',ParentId=ct.Id,ContentData=Blob.valueOf('TEST'),ContentFileName='TEST.txt'));
        }

        test.startTest();
        insert ctis;
        insert prs;
        insert ccs;
        insert cos;
        insert atts;
        //insert feedItems;
        //20160920
        List<ASI_CRM_SpecialPromotionTypeSetting__c> tmpSPList1 = new List<ASI_CRM_SpecialPromotionTypeSetting__c>();

        ASI_CRM_SpecialPromotionTypeSetting__c tmpSPList = new ASI_CRM_SpecialPromotionTypeSetting__c(ASI_CRM_Validate_TotalSuggestedAmount__c = TRUE
            , ASI_CRM_Bypass_Contract_Upload_Checking__c = TRUE
            , ASI_CRM_Override_BC_Rate__c = 1
            , ASI_CRM_SuggestedAmount_And_TargetVolume__c = TRUE
            , ASI_CRM_Promotion_Type__c = 'Heavy Contract On'
            , ASI_CRM_New_FY_Promotion_Type__c = TRUE
            , recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_SpecialPromotionTypeSetting__cASI_CRM_CN_SpecialPromotionTypeSetting')//20160920 Ben @ Elufa
        );

        ASI_CRM_SpecialPromotionTypeSetting__c tmpSPList2 = new ASI_CRM_SpecialPromotionTypeSetting__c(ASI_CRM_Validate_TotalSuggestedAmount__c = TRUE
            , ASI_CRM_Bypass_Contract_Upload_Checking__c = TRUE
            , ASI_CRM_Override_BC_Rate__c = 1
            , ASI_CRM_SuggestedAmount_And_TargetVolume__c = TRUE
            , ASI_CRM_Promotion_Type__c = 'New Contract On'
            , ASI_CRM_New_FY_Promotion_Type__c = FALSE
            , recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_SpecialPromotionTypeSetting__cASI_CRM_CN_SpecialPromotionTypeSetting')//20160920 Ben @ Elufa
        );

        tmpSPList1.add(tmpSPList);
        tmpSPList1.add(tmpSPList2);

        insert tmpSPList1;

        list<ApexPages.StandardController> scons = new list<ApexPages.StandardController>();
        for(ASI_TH_CRM_Contract__c ct: cts)
            scons.add(new ApexPages.StandardController(ct));
        
        

        ASI_CRM_CN_Contract_Controller con;

        //con = new ASI_CRM_CN_Contract_Controller(new ApexPages.StandardController(new ASI_TH_CRM_Contract__c()));

        ApexPages.currentPage().getParameters().put('ASI_CRM_CN_Outlet_WS__c',a2s[1].Id);
        ApexPages.currentPage().getParameters().put('ASI_TH_CRM_Promotion_Type__c','Heavy Contract On');
        //con = new ASI_CRM_CN_Contract_Controller(new ApexPages.StandardController(new ASI_TH_CRM_Contract__c()));

        ApexPages.currentPage().getParameters().put('RecordType', Global_RecordTypeCache.getRtId('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract'));
        //con = new ASI_CRM_CN_Contract_Controller(new ApexPages.StandardController(new ASI_TH_CRM_Contract__c()));
        //test.startTest();
        con = new ASI_CRM_CN_Contract_Controller(scons[1]);

        /*con.POModification();
        con.UpdateContractRecord();
        con.changeContractUpload();
        con.changeBusinessLicense();*/

        con.ContractOutletListCopy = NULL;
        con.showReturn = FALSE;
        con.Selected = FALSE;
        con.BRSF_Item = NULL;
        con.recordtypeSelected = NULL;
        con.CoveredOutlet_Item = NULL;
        con.SelectOption = NULL;
        con.num = NULL;
        con.SChildCustomersIds = NULL;
        con.isNewFY = TRUE;
        con.DefaultBCRate = NULL;
        con.showSuggestedAmountAndTargetVolume = TRUE;
        con.showCN = TRUE;

        con.UpdateContractDetailRecord();
        con.GoURL();
        con.GoEdit();
        con.GoEditDetails();
        con.GoEditOutlet();
        // con.saveRedirect();
        // con.submitApproval();
        // //        con.restorePO();
        // con.AddNew_BRSF();
        // con.rowidCoveredOutlet = 0;
        // con.Clone_CoveredOutlet();
        // for(integer j :con.BRSF_Item_Map.keySet()) {
        //     con.rowidBRSF = j;
        //     break;
        // }
        // con.RemoveRow_BRSF();
        // con.RemoveRow_CoveredOutlet();
        // con.AddNew_CoveredOutlet();
        // con.ContractShuttle();
        // con.getTotalAmount();
        // ASI_CRM_CN_Contract_Controller.findCitySObjects('ASI_CRM_City__c');
        /* 
              
        insert new ASI_TH_CRM_PaymentRequest__c(ASI_TH_CRM_Contract__c=cts[1].Id, ASI_TH_CRM_Status__c='Submitted',ASI_CRM_CN_Paid_In_Progress__c=1);
        
        con.POModification();

        con.Total_Payments_Amount=100000000;
        con.POModification();

        con.PageId = null;
        con.UpdateContractRecord();
        
        for(integer j :con.BRSF_Item_Map.keySet()) {
            con.rowidBRSF = j;
            break;
        }
        con.Clone_BRSF();
        
        ASI_CRM_CN_Contract_Controller.findSObjects('Account',' NOT ISNULL(Id)','');
        */
        test.stopTest();
    }

    static testMethod void ASI_CRM_CN_Contract_Controller_TEST_2_1() {

        Id rtContract = Global_RecordTypeCache.getRtId('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract');
        Id rtWS = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_CN_WS');
        ASI_CRM_Region__c region = new ASI_CRM_Region__c (Name='Central Region',recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Region__cASI_CRM_CN_Region'),ASI_CRM_Create_Heavy_Contract_On__c=true,ASI_CRM_CN_Is_2nd_KPI_PO__c=true,ASI_CRM_CN_Create_TOT_MOT_Contract__c=true);
        insert region;
        
        ASI_CRM_Division__c division = new ASI_CRM_Division__c(Name='TEST', ASI_CRM_Region__c=region.Id);
        insert division;
        
        ASI_CRM_CN_Area__c area = new ASI_CRM_CN_Area__c(Name='TEST', ASI_CRM_English_Name__c='TEST', ASI_CRM_Division__c=division.Id);
        insert area;
        
        ASI_CRM_City__c city = new ASI_CRM_City__c(Name='TEST', ASI_CRM_CN_Area__c=area.Id,ASI_CRM_CN_City_Tier__c='2');
        insert city;

        ASI_CRM_CN_Channel__c channel = new ASI_CRM_CN_Channel__c(ASI_CRM_CN_On_Off__c='ON');
        insert channel;

        ASI_MFM_Sub_Channel__c subChannel = new ASI_MFM_Sub_Channel__c(ASI_CRM_CN_Channel__c=channel.Id);
        insert subChannel;
        
        ASI_CRM_CN_Channel__c newChannel = new ASI_CRM_CN_Channel__c(ASI_CRM_For_Outlet__c = true, Name='Restaurant',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CN_Channel__cASI_CRM_CN_New_Channel'),ASI_CRM_CN_On_Off__c='OFF');
        insert newChannel;
        Id rtOutlet = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN');
        list<ASI_CRM_AccountsAdditionalField__c> a2s = new list<ASI_CRM_AccountsAdditionalField__c>();
        a2s.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Commercial_Team__c = 'Premium',
            RecordTypeId=rtWS,
            Name='TEST', 
            ASI_CRM_CN_Image__c='Iconic',
            ASI_CRM_CN_CCity__c=city.Id,
            ASI_CRM_CN_Sub_Channel__c=subChannel.Id,ASI_CRM_CN_NewChannel__c=newChannel.Id));
        a2s.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Commercial_Team__c = 'Premium',
            RecordTypeId=rtOutlet,
            Name='TEST', 
            ASI_CRM_CN_Image__c='Iconic',
            ASI_CRM_CN_CCity__c=city.Id,
            ASI_CRM_CN_Sub_Channel__c=subChannel.Id,ASI_CRM_CN_NewChannel__c=newChannel.Id));
        insert a2s;

        a2s = [SELECT Id, ASI_CRM_Account__c FROM ASI_CRM_AccountsAdditionalField__c WHERE Id=:a2s[0].Id OR Id=:a2s[1].Id];

        User currentUser = [SELECT id, name, Managerid, ASI_CRM_CN_Prefix__c FROM USER WHERE id =:UserInfo.getUserId()];

        list<ASI_HK_CRM_Running_Number__c> rns = new list<ASI_HK_CRM_Running_Number__c>();
        rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_TH_CRM_Contract__c', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        if(!String.isBlank(currentUser.ASI_CRM_CN_Prefix__c))
            rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_'+currentUser.ASI_CRM_CN_Prefix__c, recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        else{
            rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_NULL', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
            rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        }
        rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_TH_CRM_PaymentRequest__c', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        insert rns;

        ASI_MFM_Brand__c brand = new ASI_MFM_Brand__c (
            ASI_CRM_CN_Competitor__c=false);
        insert brand;

        list<ASI_MFM_Sub_brand__c> subBrands = new list<ASI_MFM_Sub_brand__c>();
        subBrands.add(new ASI_MFM_Sub_brand__c (ASI_MFM_Brand__c=brand.Id, ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1, ASI_MFM_Active_for_CRM__c=true, ASI_MFM_Sub_brand_Code__c='999',
            RecordTypeId=Global_RecordTypeCache.getRTid('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand')));
        subBrands.add(new ASI_MFM_Sub_brand__c (ASI_MFM_Brand__c=brand.Id, ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1));
        insert subBrands;

        list<ASI_TH_CRM_Contract__c> cts = new list<ASI_TH_CRM_Contract__c>();
        cts.add(new ASI_TH_CRM_Contract__c(
            RecordTypeId=rtContract,
            ASI_TH_CRM_Outlet__c=a2s[1].ASI_CRM_Account__c,
            ASI_CRM_CN_PO_Start_Date__c=system.today().addMonths(-4),
            ASI_CRM_CN_PO_End_Date__c=system.today().addMonths(-3),
            ASI_CRM_CN_Outlet_WS__c=a2s[0].Id,
            ASI_TH_CRM_Promotion_Type__c='New Contract ON',
            ASI_CRM_CN_PO_Version__c = '0.0',
            Name = 'Contract1',
            ASI_CRM_CN_PO_Modification__c=false,
            ASI_CRM_CN_Status__c='Final'));
        insert cts[0];
        cts.add(new ASI_TH_CRM_Contract__c(
            RecordTypeId=rtContract,
            ASI_TH_CRM_Outlet__c=a2s[1].ASI_CRM_Account__c,
            ASI_CRM_CN_PO_Start_Date__c=system.today().addMonths(-2),
            ASI_CRM_CN_PO_End_Date__c=system.today().addMonths(-1),
            ASI_CRM_CN_Outlet_WS__c=a2s[0].Id,
            ASI_TH_CRM_Promotion_Type__c='New Contract ON',
            ASI_CRM_CN_PO_Version__c = '0.1',
            Name = 'Contract2',
            ASI_CRM_CN_PO_Modification__c=true,
            ASI_CRM_CN_V0_0_PO_version__c=cts[0].Id,
            ASI_CRM_CN_Status__c='Draft'
        ));
        insert cts[1];

        //list<FeedItem> feedItems = new list<FeedItem>();
        list<Attachment> atts = new list<Attachment>();
        list<ASI_CRM_CN_Covered_Outlet__c> cos = new list<ASI_CRM_CN_Covered_Outlet__c>();
        list<ASI_CRM_CN_Contract_BRSF_Line_Item__c> ctis = new list<ASI_CRM_CN_Contract_BRSF_Line_Item__c>();
        list<ASI_TH_CRM_PaymentRequest__c> prs = new list<ASI_TH_CRM_PaymentRequest__c>();
        list<ASI_CRM_Contract_Cost__c> ccs = new list<ASI_CRM_Contract_Cost__c>();
        for(ASI_TH_CRM_Contract__c ct :cts) {
            ctis.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(
                ASI_CRM_CN_Contract__c=ct.Id,
                ASI_CRM_CN_Est_Monthly_Qty__c=1,
                ASI_CRM_CN_Est_BRSF_Per_Bottle__c=1,
                ASI_CRM_CN_Contract_Monthly_Qty__c=1,
                ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=1,
                ASI_CRM_CN_Est_Total_Dummy__c=1,
                ASI_CRM_CN_Contract_Total_Dummy__c=1,
                ASI_CRM_CN_Sub_Brand__c=subBrands[1].Id,
                recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CN_Contract_BRSF_Line_Item')
            ));
            prs.add(new ASI_TH_CRM_PaymentRequest__c(ASI_TH_CRM_Contract__c=ct.Id, ASI_TH_CRM_Status__c='Draft',ASI_CRM_CN_Paid_In_Progress__c=1, recordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequest__cASI_CRM_CN_Payment_Request')));
            prs.add(new ASI_TH_CRM_PaymentRequest__c(ASI_TH_CRM_Contract__c=ct.Id, ASI_TH_CRM_Status__c='Approved', ASI_CRM_CN_Last_Payment__c=true,ASI_CRM_CN_Paid_In_Progress__c=1, recordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequest__cASI_CRM_CN_Payment_Request')));
            ccs.add(new ASI_CRM_Contract_Cost__c(
                Name='TEST',
                ASI_CRM_CN_Cost_Type__c='Variable',
                ASI_CRM_CN_Contract_Amount__c=1,
                ASI_CRM_CN_Estimate_Amount__c=1,
                ASI_CRM_CN_Contract__c=ct.Id));
            ccs.add(new ASI_CRM_Contract_Cost__c(
                Name='TEST',
                ASI_CRM_CN_Cost_Type__c='Fixed',
                ASI_CRM_CN_Contract_Amount__c=1,
                ASI_CRM_CN_Estimate_Amount__c=1,
                ASI_CRM_CN_Contract__c=ct.Id));
            cos.add(new ASI_CRM_CN_Covered_Outlet__c(ASI_CRM_CN_Contract__c=ct.Id,
                recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Covered_Outlet__cASI_CRM_CN_Covered_Outlet')));
            atts.add(new Attachment(Name='TEST',Body=Blob.valueOf(''),Parentid=ct.Id));
            //feedItems.add(new FeedItem(Body='TEST',ParentId=ct.Id,ContentData=Blob.valueOf('TEST'),ContentFileName='TEST.txt'));
        }

        test.startTest();
        insert ctis;
        insert prs;
        insert ccs;
        insert cos;
        insert atts;
        //insert feedItems;
        //20160920
        List<ASI_CRM_SpecialPromotionTypeSetting__c> tmpSPList1 = new List<ASI_CRM_SpecialPromotionTypeSetting__c>();

        ASI_CRM_SpecialPromotionTypeSetting__c tmpSPList = new ASI_CRM_SpecialPromotionTypeSetting__c(ASI_CRM_Validate_TotalSuggestedAmount__c = TRUE
            , ASI_CRM_Bypass_Contract_Upload_Checking__c = TRUE
            , ASI_CRM_Override_BC_Rate__c = 1
            , ASI_CRM_SuggestedAmount_And_TargetVolume__c = TRUE
            , ASI_CRM_Promotion_Type__c = 'Heavy Contract On'
            , ASI_CRM_New_FY_Promotion_Type__c = TRUE
            , recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_SpecialPromotionTypeSetting__cASI_CRM_CN_SpecialPromotionTypeSetting')//20160920 Ben @ Elufa
        );

        ASI_CRM_SpecialPromotionTypeSetting__c tmpSPList2 = new ASI_CRM_SpecialPromotionTypeSetting__c(ASI_CRM_Validate_TotalSuggestedAmount__c = TRUE
            , ASI_CRM_Bypass_Contract_Upload_Checking__c = TRUE
            , ASI_CRM_Override_BC_Rate__c = 1
            , ASI_CRM_SuggestedAmount_And_TargetVolume__c = TRUE
            , ASI_CRM_Promotion_Type__c = 'New Contract On'
            , ASI_CRM_New_FY_Promotion_Type__c = FALSE
            , recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_SpecialPromotionTypeSetting__cASI_CRM_CN_SpecialPromotionTypeSetting')//20160920 Ben @ Elufa
        );

        tmpSPList1.add(tmpSPList);
        tmpSPList1.add(tmpSPList2);

        insert tmpSPList1;

        list<ApexPages.StandardController> scons = new list<ApexPages.StandardController>();
        for(ASI_TH_CRM_Contract__c ct: cts)
            scons.add(new ApexPages.StandardController(ct));
        
        

        ASI_CRM_CN_Contract_Controller con;

        //con = new ASI_CRM_CN_Contract_Controller(new ApexPages.StandardController(new ASI_TH_CRM_Contract__c()));

        ApexPages.currentPage().getParameters().put('ASI_CRM_CN_Outlet_WS__c',a2s[1].Id);
        ApexPages.currentPage().getParameters().put('ASI_TH_CRM_Promotion_Type__c','Heavy Contract On');
        //con = new ASI_CRM_CN_Contract_Controller(new ApexPages.StandardController(new ASI_TH_CRM_Contract__c()));

        ApexPages.currentPage().getParameters().put('RecordType', Global_RecordTypeCache.getRtId('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract'));
        //con = new ASI_CRM_CN_Contract_Controller(new ApexPages.StandardController(new ASI_TH_CRM_Contract__c()));
        //test.startTest();
        con = new ASI_CRM_CN_Contract_Controller(scons[1]);

        con.ContractOutletListCopy = NULL;
        con.showReturn = FALSE;
        con.Selected = FALSE;
        con.BRSF_Item = NULL;
        con.recordtypeSelected = NULL;
        con.CoveredOutlet_Item = NULL;
        con.SelectOption = NULL;
        con.num = NULL;
        con.SChildCustomersIds = NULL;
        con.isNewFY = TRUE;
        con.DefaultBCRate = NULL;
        con.showSuggestedAmountAndTargetVolume = TRUE;
        con.showCN = TRUE;

        
        con.saveRedirect();
        con.submitApproval();
        con.AddNew_BRSF();
        con.rowidCoveredOutlet = 0;
        con.Clone_CoveredOutlet();
        for(integer j :con.BRSF_Item_Map.keySet()) {
            con.rowidBRSF = j;
            break;
        }
        con.RemoveRow_BRSF();
        con.RemoveRow_CoveredOutlet();
        con.AddNew_CoveredOutlet();
        con.ContractShuttle();
        con.getTotalAmount();
        ASI_CRM_CN_Contract_Controller.findCitySObjects('ASI_CRM_City__c');
        
        test.stopTest();
    }

    static testMethod void ASI_CRM_CN_Contract_Controller_TEST_3() {

        Id rtContract = Global_RecordTypeCache.getRtId('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract');
        Id rtWS = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_CN_WS');
        ASI_CRM_Region__c region = new ASI_CRM_Region__c (Name='Central Region',recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Region__cASI_CRM_CN_Region'),ASI_CRM_Create_Heavy_Contract_On__c=true,ASI_CRM_CN_Is_2nd_KPI_PO__c=true,ASI_CRM_CN_Create_TOT_MOT_Contract__c=true);
        insert region;
        
        ASI_CRM_Division__c division = new ASI_CRM_Division__c(Name='TEST', ASI_CRM_Region__c=region.Id);
        insert division;
        
        ASI_CRM_CN_Area__c area = new ASI_CRM_CN_Area__c(Name='TEST', ASI_CRM_English_Name__c='TEST', ASI_CRM_Division__c=division.Id);
        insert area;
        
        ASI_CRM_City__c city = new ASI_CRM_City__c(Name='TEST', ASI_CRM_CN_Area__c=area.Id,ASI_CRM_CN_City_Tier__c='2');
        insert city;

        ASI_CRM_CN_Channel__c channel = new ASI_CRM_CN_Channel__c(ASI_CRM_CN_On_Off__c='ON');
        insert channel;

        ASI_MFM_Sub_Channel__c subChannel = new ASI_MFM_Sub_Channel__c(ASI_CRM_CN_Channel__c=channel.Id);
        insert subChannel;
        
        ASI_CRM_CN_Channel__c newChannel = new ASI_CRM_CN_Channel__c(ASI_CRM_For_Outlet__c = true, Name='Restaurant',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CN_Channel__cASI_CRM_CN_New_Channel'),ASI_CRM_CN_On_Off__c='OFF');
        insert newChannel;
        Id rtOutlet = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN');
        list<ASI_CRM_AccountsAdditionalField__c> a2s = new list<ASI_CRM_AccountsAdditionalField__c>();
        a2s.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Commercial_Team__c = 'Premium',
            RecordTypeId=rtWS,
            Name='TEST', 
            ASI_CRM_CN_Image__c='Iconic',
            ASI_CRM_CN_CCity__c=city.Id,
            ASI_CRM_CN_Sub_Channel__c=subChannel.Id,ASI_CRM_CN_NewChannel__c=newChannel.Id));
        a2s.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Commercial_Team__c = 'Premium',
            RecordTypeId=rtOutlet,
            Name='TEST', 
            ASI_CRM_CN_Image__c='Iconic',
            ASI_CRM_CN_CCity__c=city.Id,
            ASI_CRM_CN_Sub_Channel__c=subChannel.Id,ASI_CRM_CN_NewChannel__c=newChannel.Id));
        insert a2s;

        a2s = [SELECT Id, ASI_CRM_Account__c FROM ASI_CRM_AccountsAdditionalField__c WHERE Id=:a2s[0].Id OR Id=:a2s[1].Id];

        User currentUser = [SELECT id, name, Managerid, ASI_CRM_CN_Prefix__c FROM USER WHERE id =:UserInfo.getUserId()];

        list<ASI_HK_CRM_Running_Number__c> rns = new list<ASI_HK_CRM_Running_Number__c>();
        rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_TH_CRM_Contract__c', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        if(!String.isBlank(currentUser.ASI_CRM_CN_Prefix__c))
            rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_'+currentUser.ASI_CRM_CN_Prefix__c, recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        else{
            rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_NULL', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
            rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        }
        rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_TH_CRM_PaymentRequest__c', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        insert rns;

        ASI_MFM_Brand__c brand = new ASI_MFM_Brand__c (
            ASI_CRM_CN_Competitor__c=false);
        insert brand;

        list<ASI_MFM_Sub_brand__c> subBrands = new list<ASI_MFM_Sub_brand__c>();
        subBrands.add(new ASI_MFM_Sub_brand__c (ASI_MFM_Brand__c=brand.Id, ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1, ASI_MFM_Active_for_CRM__c=true, ASI_MFM_Sub_brand_Code__c='999',
            RecordTypeId=Global_RecordTypeCache.getRTid('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand')));
        subBrands.add(new ASI_MFM_Sub_brand__c (ASI_MFM_Brand__c=brand.Id, ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1));
        insert subBrands;

        list<ASI_TH_CRM_Contract__c> cts = new list<ASI_TH_CRM_Contract__c>();
        cts.add(new ASI_TH_CRM_Contract__c(
            RecordTypeId=rtContract,
            ASI_TH_CRM_Outlet__c=a2s[1].ASI_CRM_Account__c,
            ASI_CRM_CN_PO_Start_Date__c=system.today().addMonths(-4),
            ASI_CRM_CN_PO_End_Date__c=system.today().addMonths(-3),
            ASI_CRM_CN_Outlet_WS__c=a2s[0].Id,
            ASI_TH_CRM_Promotion_Type__c='New Contract ON',
            ASI_CRM_CN_PO_Version__c = '0.0',
            Name = 'Contract1',
            ASI_CRM_CN_PO_Modification__c=false,
            ASI_CRM_CN_Status__c='Final'));
        insert cts[0];
        cts.add(new ASI_TH_CRM_Contract__c(
            RecordTypeId=rtContract,
            ASI_TH_CRM_Outlet__c=a2s[1].ASI_CRM_Account__c,
            ASI_CRM_CN_PO_Start_Date__c=system.today().addMonths(-2),
            ASI_CRM_CN_PO_End_Date__c=system.today().addMonths(-1),
            ASI_CRM_CN_Outlet_WS__c=a2s[0].Id,
            ASI_TH_CRM_Promotion_Type__c='New Contract ON',
            ASI_CRM_CN_PO_Version__c = '0.1',
            Name = 'Contract2',
            ASI_CRM_CN_PO_Modification__c=true,
            ASI_CRM_CN_V0_0_PO_version__c=cts[0].Id,
            ASI_CRM_CN_Status__c='Draft'
        ));
        insert cts[1];

        // list<FeedItem> feedItems = new list<FeedItem>();
        list<Attachment> atts = new list<Attachment>();
        list<ASI_CRM_CN_Covered_Outlet__c> cos = new list<ASI_CRM_CN_Covered_Outlet__c>();
        list<ASI_CRM_CN_Contract_BRSF_Line_Item__c> ctis = new list<ASI_CRM_CN_Contract_BRSF_Line_Item__c>();
        list<ASI_TH_CRM_PaymentRequest__c> prs = new list<ASI_TH_CRM_PaymentRequest__c>();
        list<ASI_CRM_Contract_Cost__c> ccs = new list<ASI_CRM_Contract_Cost__c>();
        for(ASI_TH_CRM_Contract__c ct :cts) {
            ctis.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(
                ASI_CRM_CN_Contract__c=ct.Id,
                ASI_CRM_CN_Est_Monthly_Qty__c=1,
                ASI_CRM_CN_Est_BRSF_Per_Bottle__c=1,
                ASI_CRM_CN_Contract_Monthly_Qty__c=1,
                ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=1,
                ASI_CRM_CN_Est_Total_Dummy__c=1,
                ASI_CRM_CN_Contract_Total_Dummy__c=1,
                ASI_CRM_CN_Sub_Brand__c=subBrands[1].Id,
                recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CN_Contract_BRSF_Line_Item')
            ));
            prs.add(new ASI_TH_CRM_PaymentRequest__c(ASI_TH_CRM_Contract__c=ct.Id, ASI_TH_CRM_Status__c='Draft',ASI_CRM_CN_Paid_In_Progress__c=1, recordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequest__cASI_CRM_CN_Payment_Request')));
            prs.add(new ASI_TH_CRM_PaymentRequest__c(ASI_TH_CRM_Contract__c=ct.Id, ASI_TH_CRM_Status__c='Approved', ASI_CRM_CN_Last_Payment__c=true,ASI_CRM_CN_Paid_In_Progress__c=1, recordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequest__cASI_CRM_CN_Payment_Request')));
            ccs.add(new ASI_CRM_Contract_Cost__c(
                Name='TEST',
                ASI_CRM_CN_Cost_Type__c='Variable',
                ASI_CRM_CN_Contract_Amount__c=1,
                ASI_CRM_CN_Estimate_Amount__c=1,
                ASI_CRM_CN_Contract__c=ct.Id));
            ccs.add(new ASI_CRM_Contract_Cost__c(
                Name='TEST',
                ASI_CRM_CN_Cost_Type__c='Fixed',
                ASI_CRM_CN_Contract_Amount__c=1,
                ASI_CRM_CN_Estimate_Amount__c=1,
                ASI_CRM_CN_Contract__c=ct.Id));
            cos.add(new ASI_CRM_CN_Covered_Outlet__c(ASI_CRM_CN_Contract__c=ct.Id,
                recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Covered_Outlet__cASI_CRM_CN_Covered_Outlet')
                , ASI_CRM_CN_Outlet__c = a2s[1].id
                , ASI_CRM_CN_Selected_Covered_Outlet__c = TRUE
            ));
            atts.add(new Attachment(Name='TEST',Body=Blob.valueOf(''),Parentid=ct.Id));
            //feedItems.add(new FeedItem(Body='TEST',ParentId=ct.Id,ContentData=Blob.valueOf('TEST'),ContentFileName='TEST.txt'));
        }
        test.startTest();
        insert ctis;
        insert prs;
        insert ccs;
        insert cos;
        insert atts;
        //insert feedItems;

        list<ApexPages.StandardController> scons = new list<ApexPages.StandardController>();
        for(ASI_TH_CRM_Contract__c ct: cts)
            scons.add(new ApexPages.StandardController(ct));

        //test.startTest();

        ASI_CRM_CN_Contract_Controller con;

        con = new ASI_CRM_CN_Contract_Controller(new ApexPages.StandardController(new ASI_TH_CRM_Contract__c()));

        ApexPages.currentPage().getParameters().put('ASI_CRM_CN_Outlet_WS__c',a2s[1].Id);
        ApexPages.currentPage().getParameters().put('ASI_TH_CRM_Promotion_Type__c','New Contract ON');
        con = new ASI_CRM_CN_Contract_Controller(new ApexPages.StandardController(new ASI_TH_CRM_Contract__c()));

        ApexPages.currentPage().getParameters().put('RecordType', Global_RecordTypeCache.getRtId('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract'));
        con = new ASI_CRM_CN_Contract_Controller(new ApexPages.StandardController(new ASI_TH_CRM_Contract__c()));

        con = new ASI_CRM_CN_Contract_Controller(scons[1]);

        /*con.POModification();
        con.UpdateContractRecord();
        con.changeContractUpload();
        con.changeBusinessLicense();
        con.UpdateContractDetailRecord();
        con.GoURL();
        con.checkLaterThenThisFY(date.newInstance(system.today().year(),1,1), system.today());       
        con.GoPayment();
        con.GoEdit();
        con.GoEditDetails();
        con.GoEditOutlet();
        con.saveRedirect();
        con.submitApproval();
//        con.restorePO();
        con.AddNew_BRSF();
        con.rowidCoveredOutlet = 0;
        con.Clone_CoveredOutlet();
        for(integer j :con.BRSF_Item_Map.keySet()) {
            con.rowidBRSF = j;
            break;
        }
        con.RemoveRow_BRSF();
        con.RemoveRow_CoveredOutlet();
        con.AddNew_CoveredOutlet();
        con.ContractShuttle();
        
        */
        insert new ASI_TH_CRM_PaymentRequest__c(ASI_TH_CRM_Contract__c=cts[1].Id, ASI_TH_CRM_Status__c='Submitted',ASI_CRM_CN_Paid_In_Progress__c=1, recordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequest__cASI_CRM_CN_Payment_Request'));

        con.POModification();

        con.Total_Payments_Amount=100000000;
        con.POModification();

        con.PageId = null;
        con.UpdateContractRecord();
        con.changeContractUpload();

        for(integer j :con.BRSF_Item_Map.keySet()) {
            con.rowidBRSF = j;
            break;
        }
        con.Clone_BRSF();

        ASI_CRM_CN_Contract_Controller.findSObjects('Account',' NOT ISNULL(Id)','');

        test.stopTest();
    }

    static testMethod void ASI_CRM_CN_Contract_Controller_TEST_4() {

        Id rtContract = Global_RecordTypeCache.getRtId('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract');
        Id rtWS = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_CN_WS');
        Id rtOutlet = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN');
        list<ASI_CRM_AccountsAdditionalField__c> a2s = new list<ASI_CRM_AccountsAdditionalField__c>();
        ASI_CRM_Region__c region = new ASI_CRM_Region__c (Name='Central Region',recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Region__cASI_CRM_CN_Region'),ASI_CRM_Create_Heavy_Contract_On__c=true,ASI_CRM_CN_Is_2nd_KPI_PO__c=true,ASI_CRM_CN_Create_TOT_MOT_Contract__c=true);
        insert region;
        
        ASI_CRM_Division__c division = new ASI_CRM_Division__c(Name='TEST', ASI_CRM_Region__c=region.Id);
        insert division;
        
        ASI_CRM_CN_Area__c area = new ASI_CRM_CN_Area__c(Name='TEST', ASI_CRM_English_Name__c='TEST', ASI_CRM_Division__c=division.Id);
        insert area;
        
        ASI_CRM_City__c city = new ASI_CRM_City__c(Name='TEST', ASI_CRM_CN_Area__c=area.Id,ASI_CRM_CN_City_Tier__c='2');
        insert city;

        ASI_CRM_CN_Channel__c channel = new ASI_CRM_CN_Channel__c(ASI_CRM_CN_On_Off__c='ON');
        insert channel;

        ASI_MFM_Sub_Channel__c subChannel = new ASI_MFM_Sub_Channel__c(ASI_CRM_CN_Channel__c=channel.Id);
        insert subChannel;
        
        ASI_CRM_CN_Channel__c newChannel = new ASI_CRM_CN_Channel__c(ASI_CRM_For_Outlet__c = true, Name='Restaurant',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CN_Channel__cASI_CRM_CN_New_Channel'),ASI_CRM_CN_On_Off__c='OFF');
        insert newChannel;
        a2s.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Commercial_Team__c = 'Premium',
            RecordTypeId=rtWS,
            Name='TEST', 
            ASI_CRM_CN_Image__c='Iconic',
            ASI_CRM_CN_CCity__c=city.Id,
            ASI_CRM_CN_Sub_Channel__c=subChannel.Id,ASI_CRM_CN_NewChannel__c=newChannel.Id));
        a2s.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Commercial_Team__c = 'Premium',
            RecordTypeId=rtOutlet,
            Name='TEST', 
            ASI_CRM_CN_Image__c='Iconic',
            ASI_CRM_CN_CCity__c=city.Id,
            ASI_CRM_CN_Sub_Channel__c=subChannel.Id,ASI_CRM_CN_NewChannel__c=newChannel.Id));
        insert a2s;

        a2s = [SELECT Id, ASI_CRM_Account__c FROM ASI_CRM_AccountsAdditionalField__c WHERE Id=:a2s[0].Id OR Id=:a2s[1].Id];

        list<ASI_CRM_AccountsAdditionalField__c> childs = new list<ASI_CRM_AccountsAdditionalField__c>();
        childs.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Commercial_Team__c = 'Premium',
            RecordTypeId=rtWS,
            Name='TEST', 
            ASI_CRM_CN_Image__c='Iconic',
            ASI_CRM_CN_CCity__c=city.Id,
            ASI_CRM_CN_Parent_Outlet__c = a2s[0].id,
            ASI_CRM_CN_Sub_Channel__c=subChannel.Id,ASI_CRM_CN_NewChannel__c=newChannel.Id));
        childs.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Commercial_Team__c = 'Premium',
            RecordTypeId=rtOutlet,
            Name='TEST', 
            ASI_CRM_CN_Image__c='Iconic',
            ASI_CRM_CN_CCity__c=city.Id,
            ASI_CRM_CN_Parent_Outlet__c = a2s[1].id,
            ASI_CRM_CN_Sub_Channel__c=subChannel.Id,ASI_CRM_CN_NewChannel__c=newChannel.Id));
        insert childs;


        User currentUser = [SELECT id, name, Managerid, ASI_CRM_CN_Prefix__c FROM USER WHERE id =:UserInfo.getUserId()];

        list<ASI_HK_CRM_Running_Number__c> rns = new list<ASI_HK_CRM_Running_Number__c>();
        rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_TH_CRM_Contract__c', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        if(!String.isBlank(currentUser.ASI_CRM_CN_Prefix__c))
            rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_'+currentUser.ASI_CRM_CN_Prefix__c, recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        else{
            rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_NULL', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
            rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        }
        rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_TH_CRM_PaymentRequest__c', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        insert rns;

        ASI_MFM_Brand__c brand = new ASI_MFM_Brand__c (
            ASI_CRM_CN_Competitor__c=false);
        insert brand;

        list<ASI_MFM_Sub_brand__c> subBrands = new list<ASI_MFM_Sub_brand__c>();
        subBrands.add(new ASI_MFM_Sub_brand__c (ASI_MFM_Brand__c=brand.Id, ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1, ASI_MFM_Active_for_CRM__c=true, ASI_MFM_Sub_brand_Code__c='999',
            RecordTypeId=Global_RecordTypeCache.getRTid('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand')));
        subBrands.add(new ASI_MFM_Sub_brand__c (ASI_MFM_Brand__c=brand.Id, ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1));
        insert subBrands;

        list<ASI_TH_CRM_Contract__c> cts = new list<ASI_TH_CRM_Contract__c>();
        cts.add(new ASI_TH_CRM_Contract__c(
            RecordTypeId=rtContract,
            ASI_TH_CRM_Outlet__c=a2s[1].ASI_CRM_Account__c,
            ASI_CRM_CN_PO_Start_Date__c=system.today().addMonths(-4),
            ASI_CRM_CN_PO_End_Date__c=system.today().addMonths(-3),
            ASI_CRM_CN_Outlet_WS__c=a2s[0].Id,
            ASI_TH_CRM_Promotion_Type__c='New Contract ON',
            ASI_CRM_CN_PO_Version__c = '0.0',
            Name = 'Contract1',ASI_CRM_CN_Return_Comments__c='Test',
            ASI_CRM_CN_PO_Modification__c=false,
            ASI_CRM_CN_Status__c='Draft'));
        insert cts[0];
        cts.add(new ASI_TH_CRM_Contract__c(
            RecordTypeId=rtContract,
            ASI_TH_CRM_Outlet__c=a2s[1].ASI_CRM_Account__c,
            ASI_CRM_CN_PO_Start_Date__c=system.today().addMonths(-2),
            ASI_CRM_CN_PO_End_Date__c=system.today().addMonths(-1),
            ASI_CRM_CN_Outlet_WS__c=a2s[0].Id,
            ASI_TH_CRM_Promotion_Type__c='New Contract ON',
            ASI_CRM_CN_PO_Version__c = '0.1',
            Name = 'Contract2',ASI_CRM_CN_Return_Comments__c='Test',
            ASI_CRM_CN_PO_Modification__c=true,
            ASI_CRM_CN_V0_0_PO_version__c=cts[0].Id,
            ASI_CRM_CN_Last_PO_version__c=cts[0].Id,
            ASI_CRM_CN_Status__c='Draft'
        ));
        insert cts[1];

        //list<FeedItem> feedItems = new list<FeedItem>();
        list<Attachment> atts = new list<Attachment>();
        list<ASI_CRM_CN_Covered_Outlet__c> cos = new list<ASI_CRM_CN_Covered_Outlet__c>();
        list<ASI_CRM_CN_Contract_BRSF_Line_Item__c> ctis = new list<ASI_CRM_CN_Contract_BRSF_Line_Item__c>();
        list<ASI_TH_CRM_PaymentRequest__c> prs = new list<ASI_TH_CRM_PaymentRequest__c>();
        list<ASI_CRM_Contract_Cost__c> ccs = new list<ASI_CRM_Contract_Cost__c>();
        for(ASI_TH_CRM_Contract__c ct :cts) {
            ctis.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(
                ASI_CRM_CN_Contract__c=ct.Id,
                ASI_CRM_CN_Est_Monthly_Qty__c=1,
                ASI_CRM_CN_Est_BRSF_Per_Bottle__c=1,
                ASI_CRM_CN_Contract_Monthly_Qty__c=1,
                ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=1,
                ASI_CRM_CN_Est_Total_Dummy__c=1,
                ASI_CRM_CN_Contract_Total_Dummy__c=1,
                ASI_CRM_CN_Sub_Brand__c=subBrands[1].Id,
                recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CN_Contract_BRSF_Line_Item')
            ));
            prs.add(new ASI_TH_CRM_PaymentRequest__c(ASI_TH_CRM_Contract__c=ct.Id, ASI_TH_CRM_Status__c='Draft',ASI_CRM_CN_Paid_In_Progress__c=1, recordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequest__cASI_CRM_CN_Payment_Request')));
            prs.add(new ASI_TH_CRM_PaymentRequest__c(ASI_TH_CRM_Contract__c=ct.Id, ASI_TH_CRM_Status__c='Approved', ASI_CRM_CN_Last_Payment__c=true,ASI_CRM_CN_Paid_In_Progress__c=1, recordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequest__cASI_CRM_CN_Payment_Request')));
            ccs.add(new ASI_CRM_Contract_Cost__c(
                Name='TEST',
                ASI_CRM_CN_Cost_Type__c='Variable',
                ASI_CRM_CN_Contract_Amount__c=1,
                ASI_CRM_CN_Estimate_Amount__c=1,
                ASI_CRM_CN_Contract__c=ct.Id));
            ccs.add(new ASI_CRM_Contract_Cost__c(
                Name='TEST',
                ASI_CRM_CN_Cost_Type__c='Fixed',
                ASI_CRM_CN_Contract_Amount__c=1,
                ASI_CRM_CN_Estimate_Amount__c=1,
                ASI_CRM_CN_Contract__c=ct.Id));
            cos.add(new ASI_CRM_CN_Covered_Outlet__c(ASI_CRM_CN_Contract__c=ct.Id,
                recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Covered_Outlet__cASI_CRM_CN_Covered_Outlet')));
            atts.add(new Attachment(Name='TEST',Body=Blob.valueOf(''),Parentid=ct.Id));
            //feedItems.add(new FeedItem(Body='TEST',ParentId=ct.Id,ContentData=Blob.valueOf('TEST'),ContentFileName='TEST.txt'));
        }
        //insert ctis;
        insert prs;
        //insert ccs;
        insert cos;
        insert atts;
        //insert feedItems;

        list<ApexPages.StandardController> scons = new list<ApexPages.StandardController>();
        for(ASI_TH_CRM_Contract__c ct: cts)
            scons.add(new ApexPages.StandardController(ct));

        test.startTest();

        ApexPages.currentPage().getParameters().put('ASI_CRM_CN_Outlet_WS__c',a2s[1].Id);
        ApexPages.currentPage().getParameters().put('ASI_TH_CRM_Promotion_Type__c','New Contract ON');
        ApexPages.currentPage().getParameters().put('RecordType', Global_RecordTypeCache.getRtId('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract'));

        ASI_CRM_CN_Contract_Controller con = new ASI_CRM_CN_Contract_Controller(scons[1]);
        con.restorePO();
        con.CheckSpecialPromotionType();
        con.GoReturn();
        con.calcBRSF_EstTotal();
        con.calcBRSF_ContractTotal();
        con.Addall_CoveredOutlet();

        con.ContractSelected.ASI_CRM_CN_Status__c='Submitted';
        con.GoReturn();
        con.genPromotionGroupContractPicklist();
        con.genGroupContractPicklist();
        con.GoPayment();
        con.checkLaterThenThisFY(Date.today().addYears(-2), Date.newInstance(2020, 5, 31));
        test.stopTest();
    }
    //-----------------------------------------------------------------------------
    static testMethod void ASI_CRM_CN_Contract_Controller_TEST_5() {

        Id rtContract = Global_RecordTypeCache.getRtId('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract');
        Id rtOutlet = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN');
        Id rtWS = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_CN_WS');
        list<ASI_CRM_AccountsAdditionalField__c> a2s = new list<ASI_CRM_AccountsAdditionalField__c>();
        ASI_CRM_Region__c region = new ASI_CRM_Region__c (Name='Central Region',recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Region__cASI_CRM_CN_Region'),ASI_CRM_Create_Heavy_Contract_On__c=true,ASI_CRM_CN_Is_2nd_KPI_PO__c=true,ASI_CRM_CN_Create_TOT_MOT_Contract__c=true);
        insert region;
        
        ASI_CRM_Division__c division = new ASI_CRM_Division__c(Name='TEST', ASI_CRM_Region__c=region.Id);
        insert division;
        
        ASI_CRM_CN_Area__c area = new ASI_CRM_CN_Area__c(Name='TEST', ASI_CRM_English_Name__c='TEST', ASI_CRM_Division__c=division.Id);
        insert area;
        
        ASI_CRM_City__c city = new ASI_CRM_City__c(Name='TEST', ASI_CRM_CN_Area__c=area.Id,ASI_CRM_CN_City_Tier__c='2');
        insert city;

        ASI_CRM_CN_Channel__c channel = new ASI_CRM_CN_Channel__c(ASI_CRM_CN_On_Off__c='ON');
        insert channel;

        ASI_MFM_Sub_Channel__c subChannel = new ASI_MFM_Sub_Channel__c(ASI_CRM_CN_Channel__c=channel.Id);
        insert subChannel;
        
        ASI_CRM_CN_Channel__c newChannel = new ASI_CRM_CN_Channel__c(ASI_CRM_For_Outlet__c = true, Name='Restaurant',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CN_Channel__cASI_CRM_CN_New_Channel'),ASI_CRM_CN_On_Off__c='OFF');
        insert newChannel;
        a2s.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Commercial_Team__c = 'Premium',
            RecordTypeId=rtWS,
            Name='TEST', 
            ASI_CRM_CN_Image__c='Iconic',
            ASI_CRM_CN_CCity__c=city.Id,
            ASI_CRM_CN_Sub_Channel__c=subChannel.Id,ASI_CRM_CN_NewChannel__c=newChannel.Id));
        a2s.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Commercial_Team__c = 'Premium',
            RecordTypeId=rtOutlet,
            Name='TEST1', 
            ASI_CRM_CN_Image__c='Iconic',
            ASI_CRM_CN_CCity__c=city.Id,
            ASI_CRM_CN_Sub_Channel__c=subChannel.Id,ASI_CRM_CN_NewChannel__c=newChannel.Id));
        a2s.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Commercial_Team__c = 'Premium',
            RecordTypeId=rtOutlet,
            Name='TEST2',
            ASI_CRM_CN_Chi_Name__c = 'c',//20170220 Elufa
            ASI_CRM_CN_Eng_Name__c = 'g',
            ASI_CRM_CN_Image__c='Iconic',
            ASI_CRM_CN_CCity__c=city.Id,
            ASI_CRM_CN_Sub_Channel__c=subChannel.Id,ASI_CRM_CN_NewChannel__c=newChannel.Id));
        insert a2s;

        Set<Id> a2sIds = new Set<Id>();
        for (ASI_CRM_AccountsAdditionalField__c asObj : a2s) {
            a2sIds.add(asObj.Id);
        }

        a2s = [SELECT Id, ASI_CRM_Account__c FROM ASI_CRM_AccountsAdditionalField__c WHERE Id IN: a2sIds];

        User currentUser = [SELECT id, name, Managerid, ASI_CRM_CN_Prefix__c FROM USER WHERE id =:UserInfo.getUserId()];

        list<ASI_HK_CRM_Running_Number__c> rns = new list<ASI_HK_CRM_Running_Number__c>();
        rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_TH_CRM_Contract__c', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        if(!String.isBlank(currentUser.ASI_CRM_CN_Prefix__c))
            rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_'+currentUser.ASI_CRM_CN_Prefix__c, recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        else{
            rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_NULL', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
            rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        }
        rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_TH_CRM_PaymentRequest__c', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        insert rns;

        ASI_MFM_Brand__c brand = new ASI_MFM_Brand__c (
            ASI_CRM_CN_Competitor__c=false);
        insert brand;

        list<ASI_MFM_Sub_brand__c> subBrands = new list<ASI_MFM_Sub_brand__c>();
        subBrands.add(new ASI_MFM_Sub_brand__c (ASI_MFM_Brand__c=brand.Id, ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1, ASI_MFM_Active_for_CRM__c=true, ASI_MFM_Sub_brand_Code__c='999',
            RecordTypeId=Global_RecordTypeCache.getRTid('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand')));
        subBrands.add(new ASI_MFM_Sub_brand__c (ASI_MFM_Brand__c=brand.Id, ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1));
        insert subBrands;

        list<ASI_TH_CRM_Contract__c> cts = new list<ASI_TH_CRM_Contract__c>();
        cts.add(new ASI_TH_CRM_Contract__c(
            RecordTypeId=rtContract,
            ASI_TH_CRM_Outlet__c=a2s[1].ASI_CRM_Account__c,
            ASI_CRM_CN_PO_Start_Date__c=system.today().addMonths(-4),
            ASI_CRM_CN_PO_End_Date__c=system.today().addMonths(-3),
            ASI_CRM_CN_Outlet_WS__c=a2s[0].Id,
            ASI_TH_CRM_Promotion_Type__c='New Contract ON',
            ASI_CRM_CN_PO_Version__c = '0.0',
            Name = 'Contract1',
            ASI_CRM_CN_PO_Modification__c=false,
            ASI_CRM_CN_Status__c='Final'));
        insert cts[0];
        cts.add(new ASI_TH_CRM_Contract__c(
            RecordTypeId=rtContract,
            ASI_TH_CRM_Outlet__c=a2s[1].ASI_CRM_Account__c,
            ASI_CRM_CN_PO_Start_Date__c=system.today().addMonths(-2),
            ASI_CRM_CN_PO_End_Date__c=system.today().addMonths(-1),
            ASI_CRM_CN_Outlet_WS__c=a2s[0].Id,
            ASI_TH_CRM_Promotion_Type__c='New Contract ON',
            ASI_CRM_CN_PO_Version__c = '0.1',
            Name = 'Contract2',
            ASI_CRM_CN_PO_Modification__c=true,
            ASI_CRM_CN_V0_0_PO_version__c=cts[0].Id,
            ASI_CRM_CN_Status__c='Final'
        ));
        insert cts[1];

        //list<FeedItem> feedItems = new list<FeedItem>();
        list<Attachment> atts = new list<Attachment>();
        list<ASI_CRM_CN_Covered_Outlet__c> cos = new list<ASI_CRM_CN_Covered_Outlet__c>();
        list<ASI_CRM_CN_Contract_BRSF_Line_Item__c> ctis = new list<ASI_CRM_CN_Contract_BRSF_Line_Item__c>();
        list<ASI_TH_CRM_PaymentRequest__c> prs = new list<ASI_TH_CRM_PaymentRequest__c>();
        list<ASI_CRM_Contract_Cost__c> ccs = new list<ASI_CRM_Contract_Cost__c>();
        for(ASI_TH_CRM_Contract__c ct :cts) {
            ctis.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(
                ASI_CRM_CN_Contract__c=ct.Id,
                ASI_CRM_CN_Est_Monthly_Qty__c=1,
                ASI_CRM_CN_Est_BRSF_Per_Bottle__c=1,
                ASI_CRM_CN_Contract_Monthly_Qty__c=1,
                ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=1,
                ASI_CRM_CN_Est_Total_Dummy__c=1,
                ASI_CRM_CN_Contract_Total_Dummy__c=1,
                ASI_CRM_CN_Sub_Brand__c=subBrands[1].Id,
                recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CN_Contract_BRSF_Line_Item')
            ));
            prs.add(new ASI_TH_CRM_PaymentRequest__c(ASI_TH_CRM_Contract__c=ct.Id, ASI_TH_CRM_Status__c='Draft',ASI_CRM_CN_Paid_In_Progress__c=1, recordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequest__cASI_CRM_CN_Payment_Request')));
            prs.add(new ASI_TH_CRM_PaymentRequest__c(ASI_TH_CRM_Contract__c=ct.Id, ASI_TH_CRM_Status__c='Approved', ASI_CRM_CN_Last_Payment__c=true,ASI_CRM_CN_Paid_In_Progress__c=1, recordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequest__cASI_CRM_CN_Payment_Request')));
            ccs.add(new ASI_CRM_Contract_Cost__c(
                Name='TEST',
                ASI_CRM_CN_Cost_Type__c='Variable',
                ASI_CRM_CN_Contract_Amount__c=1,
                ASI_CRM_CN_Estimate_Amount__c=1,
                ASI_CRM_CN_Contract__c=ct.Id));
            ccs.add(new ASI_CRM_Contract_Cost__c(
                Name='TEST',
                ASI_CRM_CN_Cost_Type__c='Fixed',
                ASI_CRM_CN_Contract_Amount__c=1,
                ASI_CRM_CN_Estimate_Amount__c=1,
                ASI_CRM_CN_Contract__c=ct.Id));
            cos.add(new ASI_CRM_CN_Covered_Outlet__c(ASI_CRM_CN_Contract__c=ct.Id,
                recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Covered_Outlet__cASI_CRM_CN_Covered_Outlet')));
            atts.add(new Attachment(Name='TEST',Body=Blob.valueOf(''),Parentid=ct.Id));
            //feedItems.add(new FeedItem(Body='TEST',ParentId=ct.Id,ContentData=Blob.valueOf('TEST'),ContentFileName='TEST.txt'));
        }

        cos.add(new ASI_CRM_CN_Covered_Outlet__c(ASI_CRM_CN_Contract__c=cts[1].Id,
            recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Covered_Outlet__cASI_CRM_CN_Covered_Outlet')
            , ASI_CRM_CN_Outlet__c = a2s[2].id
            , ASI_CRM_CN_Selected_Covered_Outlet__c = TRUE
        ));

        insert ctis;
        insert prs;
        insert ccs;
        insert cos;
        insert atts;
        //insert feedItems;

        ASI_CRM_SpecialPromotionTypeSetting__c tmpSPList = new ASI_CRM_SpecialPromotionTypeSetting__c(ASI_CRM_Validate_TotalSuggestedAmount__c = TRUE
            , ASI_CRM_Bypass_Contract_Upload_Checking__c = TRUE
            , ASI_CRM_Override_BC_Rate__c = 1
            , ASI_CRM_SuggestedAmount_And_TargetVolume__c = TRUE
            , ASI_CRM_Promotion_Type__c = 'New Contract ON'
        );

        insert tmpSPList;

        list<ApexPages.StandardController> scons = new list<ApexPages.StandardController>();
        for(ASI_TH_CRM_Contract__c ct: cts)
            scons.add(new ApexPages.StandardController(ct));

        //test.startTest();

        ASI_CRM_CN_Contract_Controller con;

        //con = new ASI_CRM_CN_Contract_Controller(new ApexPages.StandardController(new ASI_TH_CRM_Contract__c()));

        ApexPages.currentPage().getParameters().put('ASI_CRM_CN_Outlet_WS__c',a2s[1].Id);
        ApexPages.currentPage().getParameters().put('ASI_TH_CRM_Promotion_Type__c','New Contract ON');
        //con = new ASI_CRM_CN_Contract_Controller(new ApexPages.StandardController(new ASI_TH_CRM_Contract__c()));

        ApexPages.currentPage().getParameters().put('RecordType', Global_RecordTypeCache.getRtId('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract'));
        //con = new ASI_CRM_CN_Contract_Controller(new ApexPages.StandardController(new ASI_TH_CRM_Contract__c()));
        test.startTest();
        con = new ASI_CRM_CN_Contract_Controller(scons[1]);

        /*con.POModification();
        con.UpdateContractRecord();
        con.changeContractUpload();
        con.changeBusinessLicense();*/
        con.UpdateContractDetailRecord();
        con.GoURL();
        con.checkLaterThenThisFY(date.newInstance(system.today().year(),1,1), system.today());
        con.GoPayment();
        con.GoEdit();
        con.GoEditDetails();
        con.GoEditOutlet();
        con.saveRedirect();
        //        con.submitApproval();
        //        con.restorePO();
        con.AddNew_BRSF();
        con.rowidCoveredOutlet = 0;
        con.Clone_CoveredOutlet();
        for(integer j :con.BRSF_Item_Map.keySet()) {
            con.rowidBRSF = j;
            break;
        }
        con.RemoveRow_BRSF();
        con.RemoveRow_CoveredOutlet();
        con.AddNew_CoveredOutlet();
        con.ContractShuttle();
        con.getTotalAmount();
        con.CheckSpecialPromotionType();
        cos[2].ASI_CRM_CN_Selected_Covered_Outlet__c = FALSE;
        con.UpdateContractDetailRecord();
        /* 
              
        insert new ASI_TH_CRM_PaymentRequest__c(ASI_TH_CRM_Contract__c=cts[1].Id, ASI_TH_CRM_Status__c='Submitted',ASI_CRM_CN_Paid_In_Progress__c=1);
        
        con.POModification();

        con.Total_Payments_Amount=100000000;
        con.POModification();

        con.PageId = null;
        con.UpdateContractRecord();
        
        for(integer j :con.BRSF_Item_Map.keySet()) {
            con.rowidBRSF = j;
            break;
        }
        con.Clone_BRSF();
        
        ASI_CRM_CN_Contract_Controller.findSObjects('Account',' NOT ISNULL(Id)','');
        */
        test.stopTest();
    }
    //-----------------------------------------------------------------------------

    static testMethod void ASI_CRM_CN_Contract_Controller_TEST_6() {

        Id rtContract = Global_RecordTypeCache.getRtId('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract');


        ASI_CRM_Region__c region = new ASI_CRM_Region__c (Name='TEST',ASI_CRM_Create_Heavy_Contract_On__c=true,ASI_CRM_CN_Is_2nd_KPI_PO__c=true,ASI_CRM_CN_Create_TOT_MOT_Contract__c=true);
        insert region;

        ASI_CRM_Division__c division = new ASI_CRM_Division__c(Name='TEST', ASI_CRM_Region__c=region.Id);
        insert division;

        ASI_CRM_CN_Area__c area = new ASI_CRM_CN_Area__c(Name='TEST', ASI_CRM_English_Name__c='TEST', ASI_CRM_Division__c=division.Id);
        insert area;

        ASI_CRM_City__c city = new ASI_CRM_City__c(Name='TEST', ASI_CRM_CN_Area__c=area.Id);
        insert city;

        ASI_CRM_CN_Channel__c channel = new ASI_CRM_CN_Channel__c(ASI_CRM_CN_On_Off__c='ON');
        insert channel;

        ASI_MFM_Sub_Channel__c subChannel = new ASI_MFM_Sub_Channel__c(ASI_CRM_CN_Channel__c=channel.Id);
        insert subChannel;

        Id rtWS = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_CN_WS');
        Id rtOutlet = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN');

        list<ASI_CRM_AccountsAdditionalField__c> a2s = new list<ASI_CRM_AccountsAdditionalField__c>();
        a2s.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Commercial_Team__c = 'Premium',
            RecordTypeId=rtOutlet,
            Name='TEST',
            ASI_CRM_CN_Image__c='Iconic',
            ASI_CRM_CN_Chi_Name__c = 'c',//20170220 Elufa
            ASI_CRM_CN_Eng_Name__c = 'g',
            ASI_CRM_CN_CCity__c=city.Id,
            ASI_CRM_CN_Sub_Channel__c=subChannel.Id));
        a2s.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Commercial_Team__c = 'Premium',
            RecordTypeId=rtOutlet,
            Name='TEST',
            ASI_CRM_CN_Chi_Name__c = 'd',//20170220 Elufa
            ASI_CRM_CN_Eng_Name__c = 'h',
            ASI_CRM_CN_Image__c='Iconic',
            ASI_CRM_CN_CCity__c=city.Id,
            ASI_CRM_CN_Sub_Channel__c=subChannel.Id));
        insert a2s;

        a2s = [SELECT Id, ASI_CRM_Account__c FROM ASI_CRM_AccountsAdditionalField__c WHERE Id=:a2s[0].Id OR Id=:a2s[1].Id];

        User currentUser = [SELECT id, name, Managerid, ASI_CRM_CN_Prefix__c FROM USER WHERE id =:UserInfo.getUserId()];

        list<ASI_HK_CRM_Running_Number__c> rns = new list<ASI_HK_CRM_Running_Number__c>();
        rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_TH_CRM_Contract__c', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        if(!String.isBlank(currentUser.ASI_CRM_CN_Prefix__c))
            rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_'+currentUser.ASI_CRM_CN_Prefix__c, recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        else{
            rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_NULL', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
            rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        }
        rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_TH_CRM_PaymentRequest__c', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        insert rns;

        ASI_MFM_Brand__c brand = new ASI_MFM_Brand__c (
            ASI_CRM_CN_Competitor__c=false);
        insert brand;

        list<ASI_MFM_Sub_brand__c> subBrands = new list<ASI_MFM_Sub_brand__c>();
        subBrands.add(new ASI_MFM_Sub_brand__c (ASI_MFM_Brand__c=brand.Id, ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1, ASI_MFM_Active_for_CRM__c=true, ASI_MFM_Sub_brand_Code__c='999',
            RecordTypeId=Global_RecordTypeCache.getRTid('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand')));
        subBrands.add(new ASI_MFM_Sub_brand__c (ASI_MFM_Brand__c=brand.Id, ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1));
        insert subBrands;

        list<ASI_TH_CRM_Contract__c> cts = new list<ASI_TH_CRM_Contract__c>();
        cts.add(new ASI_TH_CRM_Contract__c(
            RecordTypeId=rtContract,
            ASI_TH_CRM_Outlet__c=a2s[1].ASI_CRM_Account__c,
            ASI_CRM_CN_PO_Start_Date__c=system.today().addMonths(-4),
            ASI_CRM_CN_PO_End_Date__c=system.today().addMonths(-3),
            ASI_CRM_CN_Outlet_WS__c=a2s[0].Id,
            ASI_TH_CRM_Promotion_Type__c='New Contract ON',
            ASI_CRM_CN_PO_Version__c = '0.0',
            Name = 'Contract1',
            ASI_CRM_CN_PO_Modification__c=false,
            ASI_CRM_CN_Status__c='Archived'));
        insert cts[0];
        cts.add(new ASI_TH_CRM_Contract__c(
            RecordTypeId=rtContract,
            ASI_TH_CRM_Outlet__c=a2s[1].ASI_CRM_Account__c,
            ASI_CRM_CN_PO_Start_Date__c=system.today().addMonths(-2),
            ASI_CRM_CN_PO_End_Date__c=system.today().addMonths(-1),
            ASI_CRM_CN_Outlet_WS__c=a2s[0].Id,
            ASI_TH_CRM_Promotion_Type__c='New Contract ON',
            ASI_CRM_CN_PO_Version__c = '0.1',
            Name = 'Contract2',
            ASI_CRM_CN_PO_Modification__c=true,
            ASI_CRM_CN_V0_0_PO_version__c=cts[0].Id,
            ASI_CRM_CN_Status__c='Archived'
        ));
        insert cts[1];

        //list<FeedItem> feedItems = new list<FeedItem>();
        list<Attachment> atts = new list<Attachment>();
        list<ASI_CRM_CN_Covered_Outlet__c> cos = new list<ASI_CRM_CN_Covered_Outlet__c>();
        list<ASI_CRM_CN_Contract_BRSF_Line_Item__c> ctis = new list<ASI_CRM_CN_Contract_BRSF_Line_Item__c>();
        list<ASI_TH_CRM_PaymentRequest__c> prs = new list<ASI_TH_CRM_PaymentRequest__c>();
        list<ASI_CRM_Contract_Cost__c> ccs = new list<ASI_CRM_Contract_Cost__c>();
        for(ASI_TH_CRM_Contract__c ct :cts) {
            ctis.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(
                ASI_CRM_CN_Contract__c=ct.Id,
                ASI_CRM_CN_Est_Monthly_Qty__c=1,
                ASI_CRM_CN_Est_BRSF_Per_Bottle__c=1,
                ASI_CRM_CN_Contract_Monthly_Qty__c=1,
                ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=1,
                ASI_CRM_CN_Est_Total_Dummy__c=1,
                ASI_CRM_CN_Contract_Total_Dummy__c=1,
                ASI_CRM_CN_Sub_Brand__c=subBrands[1].Id,
                recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CN_Contract_BRSF_Line_Item')
            ));
            prs.add(new ASI_TH_CRM_PaymentRequest__c(ASI_TH_CRM_Contract__c=ct.Id, ASI_TH_CRM_Status__c='Draft',ASI_CRM_CN_Paid_In_Progress__c=1, recordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequest__cASI_CRM_CN_Payment_Request')));
            prs.add(new ASI_TH_CRM_PaymentRequest__c(ASI_TH_CRM_Contract__c=ct.Id, ASI_TH_CRM_Status__c='Approved', ASI_CRM_CN_Last_Payment__c=true,ASI_CRM_CN_Paid_In_Progress__c=1, recordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequest__cASI_CRM_CN_Payment_Request')));
            ccs.add(new ASI_CRM_Contract_Cost__c(
                Name='TEST',
                ASI_CRM_CN_Cost_Type__c='Variable',
                ASI_CRM_CN_Contract_Amount__c=1,
                ASI_CRM_CN_Estimate_Amount__c=1,
                ASI_CRM_CN_Contract__c=ct.Id));
            ccs.add(new ASI_CRM_Contract_Cost__c(
                Name='TEST',
                ASI_CRM_CN_Cost_Type__c='Fixed',
                ASI_CRM_CN_Contract_Amount__c=1,
                ASI_CRM_CN_Estimate_Amount__c=1,
                ASI_CRM_CN_Contract__c=ct.Id));
            cos.add(new ASI_CRM_CN_Covered_Outlet__c(ASI_CRM_CN_Contract__c=ct.Id,
                recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Covered_Outlet__cASI_CRM_CN_Covered_Outlet')));
            atts.add(new Attachment(Name='TEST',Body=Blob.valueOf(''),Parentid=ct.Id));
            //feedItems.add(new FeedItem(Body='TEST',ParentId=ct.Id,ContentData=Blob.valueOf('TEST'),ContentFileName='TEST.txt'));
        }
        insert ctis;
        insert prs;
        insert ccs;
        insert cos;
        insert atts;
        //insert feedItems;

        ASI_CRM_SpecialPromotionTypeSetting__c tmpSPList = new ASI_CRM_SpecialPromotionTypeSetting__c(ASI_CRM_Validate_TotalSuggestedAmount__c = TRUE
            , ASI_CRM_Bypass_Contract_Upload_Checking__c = TRUE
            , ASI_CRM_Override_BC_Rate__c = 1
            , ASI_CRM_SuggestedAmount_And_TargetVolume__c = TRUE
            , ASI_CRM_Promotion_Type__c = 'New Contract ON'
        );

        insert tmpSPList;

        list<ApexPages.StandardController> scons = new list<ApexPages.StandardController>();
        for(ASI_TH_CRM_Contract__c ct: cts)
            scons.add(new ApexPages.StandardController(ct));

        //test.startTest();

        ASI_CRM_CN_Contract_Controller con;

        //con = new ASI_CRM_CN_Contract_Controller(new ApexPages.StandardController(new ASI_TH_CRM_Contract__c()));

        ApexPages.currentPage().getParameters().put('ASI_CRM_CN_Outlet_WS__c',a2s[1].Id);
        ApexPages.currentPage().getParameters().put('ASI_TH_CRM_Promotion_Type__c','New Contract ON');
        //con = new ASI_CRM_CN_Contract_Controller(new ApexPages.StandardController(new ASI_TH_CRM_Contract__c()));

        ApexPages.currentPage().getParameters().put('RecordType', Global_RecordTypeCache.getRtId('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract'));
        //con = new ASI_CRM_CN_Contract_Controller(new ApexPages.StandardController(new ASI_TH_CRM_Contract__c()));
        test.startTest();
        con = new ASI_CRM_CN_Contract_Controller(scons[1]);

        /*con.POModification();
        con.UpdateContractRecord();
        con.changeContractUpload();
        con.changeBusinessLicense();*/
        con.UpdateContractDetailRecord();
        con.GoURL();
        con.checkLaterThenThisFY(date.newInstance(system.today().year(),1,1), system.today());
        con.GoPayment();
        con.GoEdit();
        con.GoEditDetails();
        con.GoEditOutlet();
        con.saveRedirect();
        //        con.submitApproval();
        //        con.restorePO();
        con.AddNew_BRSF();
        con.rowidCoveredOutlet = 0;
        con.Clone_CoveredOutlet();
        for(integer j :con.BRSF_Item_Map.keySet()) {
            con.rowidBRSF = j;
            break;
        }
        con.RemoveRow_BRSF();
        con.RemoveRow_CoveredOutlet();
        con.AddNew_CoveredOutlet();
        con.ContractShuttle();
        con.getTotalAmount();
        con.CheckSpecialPromotionType();
        /* 
              
        insert new ASI_TH_CRM_PaymentRequest__c(ASI_TH_CRM_Contract__c=cts[1].Id, ASI_TH_CRM_Status__c='Submitted',ASI_CRM_CN_Paid_In_Progress__c=1);
        
        con.POModification();

        con.Total_Payments_Amount=100000000;
        con.POModification();

        con.PageId = null;
        con.UpdateContractRecord();
        
        for(integer j :con.BRSF_Item_Map.keySet()) {
            con.rowidBRSF = j;
            break;
        }
        con.Clone_BRSF();
        
        ASI_CRM_CN_Contract_Controller.findSObjects('Account',' NOT ISNULL(Id)','');
        */
        test.stopTest();
    }

    static testMethod void ASI_CRM_CN_Contract_Controller_TEST_7() {

        Id rtContract = Global_RecordTypeCache.getRtId('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract');


        ASI_CRM_Region__c region = new ASI_CRM_Region__c (Name='TEST',ASI_CRM_Create_Heavy_Contract_On__c=true,ASI_CRM_CN_Is_2nd_KPI_PO__c=true,ASI_CRM_CN_Create_TOT_MOT_Contract__c=true);
        insert region;

        ASI_CRM_Division__c division = new ASI_CRM_Division__c(Name='TEST', ASI_CRM_Region__c=region.Id);
        insert division;

        ASI_CRM_CN_Area__c area = new ASI_CRM_CN_Area__c(Name='TEST', ASI_CRM_English_Name__c='TEST', ASI_CRM_Division__c=division.Id);
        insert area;

        ASI_CRM_City__c city = new ASI_CRM_City__c(Name='TEST', ASI_CRM_CN_Area__c=area.Id);
        insert city;

        ASI_CRM_CN_Channel__c channel = new ASI_CRM_CN_Channel__c(ASI_CRM_CN_On_Off__c='ON', ASI_CRM_For_Outlet__c = TRUE, recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_CN_Channel__cASI_CRM_CN_New_Channel'));
        insert channel;

        ASI_MFM_Sub_Channel__c subChannel = new ASI_MFM_Sub_Channel__c(ASI_CRM_CN_Channel__c=channel.Id);
        insert subChannel;

        Id rtWS = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_CN_WS');
        Id rtOutlet = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN');

        list<ASI_CRM_AccountsAdditionalField__c> a2s = new list<ASI_CRM_AccountsAdditionalField__c>();
        a2s.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Commercial_Team__c = 'Premium',
            RecordTypeId=rtOutlet,
            Name='TEST',
            ASI_CRM_CN_Chi_Name__c = 'c',//20170220 Elufa
            ASI_CRM_CN_Eng_Name__c = 'g',
            ASI_CRM_CN_Image__c='Iconic',
            ASI_CRM_CN_CCity__c=city.Id,
            ASI_CRM_CN_NewChannel__c = channel.id,
            ASI_CRM_CN_Sub_Channel__c=subChannel.Id));
        a2s.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Commercial_Team__c = 'Premium',
            RecordTypeId=rtOutlet,
            Name='TEST',
            ASI_CRM_CN_Chi_Name__c = 'e',//20170220 Elufa
            ASI_CRM_CN_Eng_Name__c = 'h',
            ASI_CRM_CN_Image__c='Iconic',
            ASI_CRM_CN_CCity__c=city.Id,
            ASI_CRM_CN_Sub_Channel__c=subChannel.Id));
        insert a2s;

        a2s = [SELECT Id, ASI_CRM_Account__c FROM ASI_CRM_AccountsAdditionalField__c WHERE Id=:a2s[0].Id OR Id=:a2s[1].Id];

        User currentUser = [SELECT id, name, Managerid, ASI_CRM_CN_Prefix__c FROM USER WHERE id =:UserInfo.getUserId()];

        list<ASI_HK_CRM_Running_Number__c> rns = new list<ASI_HK_CRM_Running_Number__c>();
        rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_TH_CRM_Contract__c', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        if(!String.isBlank(currentUser.ASI_CRM_CN_Prefix__c))
            rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_'+currentUser.ASI_CRM_CN_Prefix__c, recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        else{
            rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_NULL', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
            rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        }
        rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_TH_CRM_PaymentRequest__c', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        insert rns;

        ASI_MFM_Brand__c brand = new ASI_MFM_Brand__c (
            ASI_CRM_CN_Competitor__c=false);
        insert brand;

        list<ASI_MFM_Sub_brand__c> subBrands = new list<ASI_MFM_Sub_brand__c>();
        subBrands.add(new ASI_MFM_Sub_brand__c (ASI_MFM_Brand__c=brand.Id, ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1, ASI_MFM_Active_for_CRM__c=true, ASI_MFM_Sub_brand_Code__c='999',
            RecordTypeId=Global_RecordTypeCache.getRTid('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand')));
        subBrands.add(new ASI_MFM_Sub_brand__c (ASI_MFM_Brand__c=brand.Id, ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1));
        insert subBrands;

        list<ASI_TH_CRM_Contract__c> cts = new list<ASI_TH_CRM_Contract__c>();
        cts.add(new ASI_TH_CRM_Contract__c(
            RecordTypeId=rtContract,
            ASI_TH_CRM_Outlet__c=a2s[1].ASI_CRM_Account__c,
            ASI_CRM_CN_PO_Start_Date__c=system.today().addMonths(-4),
            ASI_CRM_CN_PO_End_Date__c=system.today().addMonths(-3),
            ASI_CRM_CN_Outlet_WS__c=a2s[1].Id,
            ASI_TH_CRM_Promotion_Type__c='Contract ON',
            ASI_CRM_CN_PO_Version__c = '0.0',
            Name = 'Contract1',
            ASI_CRM_CN_PO_Modification__c=false,
            ASI_CRM_CN_Status__c='Submitted'));
        insert cts[0];
        cts.add(new ASI_TH_CRM_Contract__c(
            RecordTypeId=rtContract,
            ASI_TH_CRM_Outlet__c=a2s[1].ASI_CRM_Account__c,
            ASI_CRM_CN_PO_Start_Date__c=system.today().addMonths(-2),
            ASI_CRM_CN_PO_End_Date__c=system.today().addMonths(-1),
            ASI_CRM_CN_Outlet_WS__c=a2s[1].Id,
            ASI_TH_CRM_Promotion_Type__c='Contract ON',
            ASI_CRM_CN_PO_Version__c = '0.1',
            Name = 'Contract2',
            ASI_CRM_CN_PO_Modification__c=true,
            ASI_CRM_CN_V0_0_PO_version__c=cts[0].Id,
            ASI_CRM_CN_Status__c='Submitted'
        ));
        insert cts[1];

        //list<FeedItem> feedItems = new list<FeedItem>();
        list<Attachment> atts = new list<Attachment>();
        list<ASI_CRM_CN_Covered_Outlet__c> cos = new list<ASI_CRM_CN_Covered_Outlet__c>();
        list<ASI_CRM_CN_Contract_BRSF_Line_Item__c> ctis = new list<ASI_CRM_CN_Contract_BRSF_Line_Item__c>();
        list<ASI_TH_CRM_PaymentRequest__c> prs = new list<ASI_TH_CRM_PaymentRequest__c>();
        list<ASI_CRM_Contract_Cost__c> ccs = new list<ASI_CRM_Contract_Cost__c>();
        for(ASI_TH_CRM_Contract__c ct :cts) {
            ctis.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(
                ASI_CRM_CN_Contract__c=ct.Id,
                ASI_CRM_CN_Est_Monthly_Qty__c=1,
                ASI_CRM_CN_Est_BRSF_Per_Bottle__c=1,
                ASI_CRM_CN_Contract_Monthly_Qty__c=1,
                ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=1,
                ASI_CRM_CN_Est_Total_Dummy__c=1,
                ASI_CRM_CN_Contract_Total_Dummy__c=1,
                ASI_CRM_CN_Sub_Brand__c=subBrands[1].Id,
                recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CN_Contract_BRSF_Line_Item')
            ));
            prs.add(new ASI_TH_CRM_PaymentRequest__c(ASI_TH_CRM_Contract__c=ct.Id, ASI_TH_CRM_Status__c='Draft',ASI_CRM_CN_Paid_In_Progress__c=1, recordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequest__cASI_CRM_CN_Payment_Request')));
            prs.add(new ASI_TH_CRM_PaymentRequest__c(ASI_TH_CRM_Contract__c=ct.Id, ASI_TH_CRM_Status__c='Approved', ASI_CRM_CN_Last_Payment__c=true,ASI_CRM_CN_Paid_In_Progress__c=1, recordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequest__cASI_CRM_CN_Payment_Request')));
            ccs.add(new ASI_CRM_Contract_Cost__c(
                Name='TEST',
                ASI_CRM_CN_Cost_Type__c='Variable',
                ASI_CRM_CN_Contract_Amount__c=1,
                ASI_CRM_CN_Estimate_Amount__c=1,
                ASI_CRM_CN_Contract__c=ct.Id));
            ccs.add(new ASI_CRM_Contract_Cost__c(
                Name='TEST',
                ASI_CRM_CN_Cost_Type__c='Fixed',
                ASI_CRM_CN_Contract_Amount__c=1,
                ASI_CRM_CN_Estimate_Amount__c=1,
                ASI_CRM_CN_Contract__c=ct.Id));
            cos.add(new ASI_CRM_CN_Covered_Outlet__c(ASI_CRM_CN_Contract__c=ct.Id,
                recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Covered_Outlet__cASI_CRM_CN_Covered_Outlet')));
            atts.add(new Attachment(Name='TEST',Body=Blob.valueOf(''),Parentid=ct.Id));
            //feedItems.add(new FeedItem(Body='TEST',ParentId=ct.Id,ContentData=Blob.valueOf('TEST'),ContentFileName='TEST.txt'));
        }
        test.startTest();
        insert ctis;
        insert prs;
        insert ccs;
        insert cos;
        insert atts;
        //insert feedItems;

        //20160920
        List<ASI_CRM_SpecialPromotionTypeSetting__c> tmpSPList1 = new List<ASI_CRM_SpecialPromotionTypeSetting__c>();

        ASI_CRM_SpecialPromotionTypeSetting__c tmpSPList = new ASI_CRM_SpecialPromotionTypeSetting__c(ASI_CRM_Validate_TotalSuggestedAmount__c = TRUE
            , ASI_CRM_Bypass_Contract_Upload_Checking__c = TRUE
            , ASI_CRM_Override_BC_Rate__c = 1
            , ASI_CRM_SuggestedAmount_And_TargetVolume__c = TRUE
            , ASI_CRM_Promotion_Type__c = 'Contract ON'
            , ASI_CRM_New_FY_Promotion_Type__c = TRUE
            , recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_SpecialPromotionTypeSetting__cASI_CRM_CN_SpecialPromotionTypeSetting')//20160920 Ben @ Elufa
        );

        ASI_CRM_SpecialPromotionTypeSetting__c tmpSPList2 = new ASI_CRM_SpecialPromotionTypeSetting__c(ASI_CRM_Validate_TotalSuggestedAmount__c = TRUE
            , ASI_CRM_Bypass_Contract_Upload_Checking__c = TRUE
            , ASI_CRM_Override_BC_Rate__c = 1
            , ASI_CRM_SuggestedAmount_And_TargetVolume__c = TRUE
            , ASI_CRM_Promotion_Type__c = 'New Contract ON'
            , ASI_CRM_New_FY_Promotion_Type__c = FALSE
            , recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_SpecialPromotionTypeSetting__cASI_CRM_CN_SpecialPromotionTypeSetting')//20160920 Ben @ Elufa
        );

        tmpSPList1.add(tmpSPList);
        tmpSPList1.add(tmpSPList2);

        insert tmpSPList1;

        list<ApexPages.StandardController> scons = new list<ApexPages.StandardController>();
        for(ASI_TH_CRM_Contract__c ct: cts)
            scons.add(new ApexPages.StandardController(ct));

        //test.startTest();

        ASI_CRM_CN_Contract_Controller con;

        //con = new ASI_CRM_CN_Contract_Controller(new ApexPages.StandardController(new ASI_TH_CRM_Contract__c()));

        ApexPages.currentPage().getParameters().put('ASI_CRM_CN_Outlet_WS__c',a2s[1].Id);
        ApexPages.currentPage().getParameters().put('ASI_TH_CRM_Promotion_Type__c','New Contract ON');
        //con = new ASI_CRM_CN_Contract_Controller(new ApexPages.StandardController(new ASI_TH_CRM_Contract__c()));

        ApexPages.currentPage().getParameters().put('RecordType', Global_RecordTypeCache.getRtId('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract'));
        //con = new ASI_CRM_CN_Contract_Controller(new ApexPages.StandardController(new ASI_TH_CRM_Contract__c()));
        //test.startTest();
        con = new ASI_CRM_CN_Contract_Controller(scons[1]);

        /*con.POModification();
        con.UpdateContractRecord();
        con.changeContractUpload();
        con.changeBusinessLicense();*/

        //20160920 Ben @ Elufa
        con.ContractOutletListCopy = NULL;
        con.showReturn = FALSE;
        con.Selected = FALSE;
        con.BRSF_Item = NULL;
        con.recordtypeSelected = NULL;
        con.CoveredOutlet_Item = NULL;
        con.SelectOption = NULL;
        con.num = NULL;
        con.SChildCustomersIds = NULL;
        con.isNewFY = TRUE;
        con.DefaultBCRate = NULL;
        con.showSuggestedAmountAndTargetVolume = TRUE;
        con.showCN = TRUE;

        con.UpdateContractDetailRecord();
        con.GoURL();
        con.checkLaterThenThisFY(date.newInstance(system.today().year(),1,1), system.today());
        con.GoPayment();
        con.GoEdit();
        con.GoEditDetails();
        con.GoEditOutlet();
        con.saveRedirect();
        con.submitApproval();
        //        con.restorePO();
        con.AddNew_BRSF();
        con.rowidCoveredOutlet = 0;
        con.Clone_CoveredOutlet();
        for(integer j :con.BRSF_Item_Map.keySet()) {
            con.rowidBRSF = j;
            break;
        }
        con.RemoveRow_BRSF();
        con.RemoveRow_CoveredOutlet();
        con.AddNew_CoveredOutlet();
        con.ContractShuttle();
        con.getTotalAmount();
        con.CheckSpecialPromotionType();
        //20160920
        con.isNewFY = FALSE;
        con.CheckSpecialPromotionType();
        ASI_CRM_CN_Contract_Controller.findCitySObjects('ASI_CRM_City__c');
        con.ContractSelected.ASI_CRM_CN_Outlet_WS__c = a2s[0].id;
        con.setCustomerChannel();
        con.ContractSelected.ASI_CRM_CN_Outlet_WS__c = a2s[1].id;
        con.setCustomerChannel();
        List<ASI_CRM_Customer_Group__c> nationGroupList = con.nationGroupList;
        List<String> nationGroup = con.nationGroup;
        con.getAllNationalGroup();
        /* 
              
        insert new ASI_TH_CRM_PaymentRequest__c(ASI_TH_CRM_Contract__c=cts[1].Id, ASI_TH_CRM_Status__c='Submitted',ASI_CRM_CN_Paid_In_Progress__c=1);
        
        con.POModification();

        con.Total_Payments_Amount=100000000;
        con.POModification();

        con.PageId = null;
        con.UpdateContractRecord();
        
        for(integer j :con.BRSF_Item_Map.keySet()) {
            con.rowidBRSF = j;
            break;
        }
        con.Clone_BRSF();
        
        ASI_CRM_CN_Contract_Controller.findSObjects('Account',' NOT ISNULL(Id)','');
        */
        test.stopTest();
    }

    static testMethod void ASI_CRM_CN_Contract_Controller_TEST_8() {
        Account acc = new Account(Name='TEST', RecordTypeId = Global_RecordTypeCache.getRtId('AccountASI_MFM_CN_Outlet'));
        insert acc;

        ASI_CRM_Region__c region = new ASI_CRM_Region__c (Name='TEST',ASI_CRM_Create_Heavy_Contract_On__c=true,ASI_CRM_CN_Is_2nd_KPI_PO__c=true,ASI_CRM_CN_Create_TOT_MOT_Contract__c=true);
        insert region;
        
        ASI_CRM_Division__c division = new ASI_CRM_Division__c(Name='TEST', ASI_CRM_Region__c=region.Id);
        insert division;
        
        ASI_CRM_CN_Area__c area = new ASI_CRM_CN_Area__c(Name='TEST', ASI_CRM_English_Name__c='TEST', ASI_CRM_Division__c=division.Id);
        insert area;
        
        ASI_CRM_Province__c province = new ASI_CRM_Province__c(Name='TEST');
        insert province;

        ASI_CRM_City__c city = new ASI_CRM_City__c(Name='TEST', ASI_CRM_CN_Area__c=area.Id, ASI_CRM_CN_Province__c=province.id);
        insert city;

        ASI_CRM_CN_Channel_Group__c groupChannel = new ASI_CRM_CN_Channel_Group__c(Name='OFF MOT',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CN_Channel_Group__cASI_CRM_CN_Channel_Group'));
        insert groupChannel;
        
        ASI_CRM_CN_Channel__c channel = new ASI_CRM_CN_Channel__c(Name='KTV',ASI_CRM_BC_Rate__c=98,ASI_CRM_CN_On_Off__c='ON',ASI_CRM_For_Outlet__c=true,RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CN_Channel__cASI_CRM_CN_New_Channel'),ASI_CRM_For_Contract__c=TRUE);
        insert channel;
        
        ASI_MFM_Sub_Channel__c subChannel = new ASI_MFM_Sub_Channel__c(ASI_CRM_CN_Channel__c=channel.Id);
        insert subChannel;

        ASI_CRM_CN_Channel__c newChannel = new ASI_CRM_CN_Channel__c(ASI_CRM_For_Outlet__c = true, Name='Restaurant',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CN_Channel__cASI_CRM_CN_New_Channel'),ASI_CRM_CN_On_Off__c='OFF');
        insert newChannel;

        Id rtWS = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_CN_WS');
        Id rtOutlet = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN');
    
        list<ASI_CRM_AccountsAdditionalField__c> Customers = new list<ASI_CRM_AccountsAdditionalField__c>();
        Customers.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Commercial_Team__c = 'Premium',ASI_CRM_CN_New_Image__c='Iconic',RecordTypeId=rtWS,Name='TEST', ASI_CRM_CN_Image__c='Iconic',ASI_CRM_CN_CCity__c=city.Id,ASI_CRM_CN_NewChannel__c=channel.Id));
        Customers.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Commercial_Team__c = 'Premium',ASI_CRM_CN_New_Image__c='Iconic',RecordTypeId=rtOutlet,Name='TEST', ASI_CRM_CN_Image__c='Iconic',ASI_CRM_CN_CCity__c=city.Id,ASI_CRM_CN_NewChannel__c=channel.Id));
        insert Customers;

        ASI_CRM_KA_Account__c KAAccount = NEW ASI_CRM_KA_Account__c(Name='诺亚 Noah',recordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_KA_Account__cASI_CRM_CN_Group'),ASI_CRM_National_Group__c=true);
        insert KAAccount;

        list<ASI_CRM_AccountsAdditionalField__c> a2s = new list<ASI_CRM_AccountsAdditionalField__c>();
        a2s.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Commercial_Team__c = 'Premium',
            RecordTypeId=rtWS,ASI_CRM_Channel_Group__c = groupChannel.id,
            Name='TEST', ASI_CRM_CN_KA_Account_Chain__c=KAAccount.id,
            ASI_CRM_CN_Image__c='Iconic',
            ASI_CRM_CN_CCity__c=city.Id,
            ASI_CRM_CN_Sub_Channel__c=subChannel.Id,ASI_CRM_CN_NewChannel__c=newChannel.Id));
        a2s.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Commercial_Team__c = 'Premium',
            RecordTypeId=rtOutlet,ASI_CRM_Channel_Group__c = groupChannel.id,
            Name='TEST', ASI_CRM_CN_KA_Account_Chain__c=KAAccount.id,
            ASI_CRM_CN_Image__c='Iconic',
            ASI_CRM_CN_CCity__c=city.Id,
            ASI_CRM_CN_Sub_Channel__c=subChannel.Id,ASI_CRM_CN_NewChannel__c=newChannel.Id));
        insert a2s;
        
        a2s = [SELECT Id, ASI_CRM_Account__c FROM ASI_CRM_AccountsAdditionalField__c WHERE Id=:a2s[0].Id OR Id=:a2s[1].Id];
        
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

        ASI_MFM_Brand__c brand = new ASI_MFM_Brand__c (
            ASI_CRM_CN_Competitor__c=false);
        insert brand;
        
        list<ASI_CRM_Sub_Brand_Grade__c> grades = new list<ASI_CRM_Sub_Brand_Grade__c>();
        grades.add(new ASI_CRM_Sub_Brand_Grade__c (Name='TEST1'));
        grades.add(new ASI_CRM_Sub_Brand_Grade__c (Name='TEST2'));
        grades.add(new ASI_CRM_Sub_Brand_Grade__c (Name='TEST3'));
        insert grades;

        list<ASI_CRM_Sub_Brand_Group__c> groups = new list<ASI_CRM_Sub_Brand_Group__c>();
        groups.add(new ASI_CRM_Sub_Brand_Group__c(Name='TEST'));
        groups.add(new ASI_CRM_Sub_Brand_Group__c(Name='Chivas 12'));
        insert groups;
            
        list<ASI_MFM_Sub_brand__c> subBrands = new list<ASI_MFM_Sub_brand__c>();
        for(ASI_CRM_Sub_Brand_Grade__c grade :grades) {
            for(ASI_CRM_Sub_Brand_Group__c gp: groups) {
                subBrands.add(new ASI_MFM_Sub_brand__c (
                    Name='TEST1',
                    ASI_MFM_Brand__c=brand.Id,
                    ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,
                    ASI_CRM_CN_Sub_brand_Grade__c=grade.Id,
                    ASI_CRM_CN_SubBrand_Group_c__c=gp.Id));
                subBrands.add(new ASI_MFM_Sub_brand__c (
                    Name='TEST2',
                    ASI_MFM_Brand__c=brand.Id,
                    ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,
                    ASI_CRM_CN_Sub_brand_Grade__c=grade.Id,
                    ASI_CRM_CN_SubBrand_Group_c__c=gp.Id));
                subBrands.add(new ASI_MFM_Sub_brand__c (
                    Name='TEST3',
                    ASI_MFM_Brand__c=brand.Id,
                    ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,
                    ASI_CRM_CN_Sub_brand_Grade__c=grade.Id,
                    ASI_CRM_CN_SubBrand_Group_c__c=gp.Id));
            }
            subBrands.add(new ASI_MFM_Sub_brand__c (
                Name='TEST3',
                ASI_MFM_Brand__c=brand.Id,
                ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,
                ASI_CRM_CN_Sub_brand_Grade__c=grade.Id,
                ASI_CRM_CN_SubBrand_Group_c__c=null));
        }
        insert subBrands;

        ASI_TH_CRM_Contract__c GroupContract = new ASI_TH_CRM_Contract__c(recordtypeid = Global_RecordTypeCache.getRTID('ASI_TH_CRM_Contract__cASI_CRM_CN_Group_Contract'),
                                                                          ASI_CRM_CN_PO_Start_Date__c = system.today().addDays(-180),ASI_CRM_NationalGroup__c=KAAccount.Id,
                                                                          ASI_CRM_CN_PO_End_Date__c =system.today().addDays(180),
                                                                          Name = 'Noah C4',ASI_CRM_CN_Bottle_Collection_Rate__c=0.97,
                                                                          ASI_CRM_CN_Outlet_WS__c=Customers[1].Id);
        insert GroupContract;

        Date poStartDate =  Date.today().toStartOfMonth().addMonths(-3);
        Date poEndDate = poStartDate.addMonths(6).addDays(-1);
        ASI_TH_CRM_Contract__c ct = new ASI_TH_CRM_Contract__c(
            recordtypeid = Global_RecordTypeCache.getRTID('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract'),
            ASI_CRM_CN_Status__c = 'Final',
            ASI_CRM_CN_PO_Start_Date__c = poStartDate,
            ASI_CRM_CN_PO_End_Date__c = poEndDate,
            ASI_TH_CRM_Outlet__c=a2s[0].ASI_CRM_Account__c, ASI_CRM_CN_Group_Contract__c=GroupContract.Id,
            ASI_CRM_CN_PO_Version__c = '0.0', ASI_TH_CRM_Promotion_Type__c = 'Heavy Contract On',
            Name = 'Contract1',
            ASI_CRM_CN_Outlet_WS__c=a2s[0].Id,ASI_CRM_Volume_Option__c = 'Normal'
            );
        insert ct;
        
        ASI_CRM_Contract_Cost__c contractCost = new ASI_CRM_Contract_Cost__c(
            ASI_CRM_CN_Contract__c = ct.id,
            ASI_CRM_CN_Estimate_Amount__c = 100000,
            ASI_CRM_CN_Cost_Type__c = 'Variable',
            ASI_CRM_CN_Other_Cost_Payment_Request__c = true,
            recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_Contract_Cost__cASI_CRM_CN_Contract_Cost')
        );
        insert contractCost;

        list<ASI_CRM_CN_Contract_BRSF_Line_Item__c> ctis = new list<ASI_CRM_CN_Contract_BRSF_Line_Item__c>();
        list<ASI_CRM_CN_Covered_Outlet__c> cos = new list<ASI_CRM_CN_Covered_Outlet__c>();
        for(ASI_MFM_Sub_brand__c subBrand :subBrands) {
            ctis.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(
                ASI_CRM_CN_Contract__c=ct.Id,
                ASI_CRM_CN_Est_Monthly_Qty__c=1,
                ASI_CRM_CN_Contract_Monthly_Qty__c=1,
                ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,
                ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,
                ASI_CRM_CN_Sub_Brand__c=subBrand.Id,
                recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CN_Contract_BRSF_Line_Item')
            ));
        }
        ctis.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(
                ASI_CRM_CN_Contract__c=ct.Id,
                ASI_CRM_CN_Est_Monthly_Qty__c=1,
                ASI_CRM_CN_Contract_Monthly_Qty__c=1,
                ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,
                ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,
                ASI_CRM_CN_Sub_Brand__c=null,
                recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CN_Contract_BRSF_Line_Item')
            ));
        cos.add(new ASI_CRM_CN_Covered_Outlet__c(
            ASI_CRM_CN_Contract__c=ct.Id,
            ASI_CRM_CN_Outlet__c=a2s[0].Id,
                recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Covered_Outlet__cASI_CRM_CN_Covered_Outlet')));
        
        insert ctis;
        insert cos;
        currentUser.LanguageLocaleKey='zh_CN';
        currentUser.BypassTriggers__c='ASI_CRM_CN_Contract_TriggerClass,CN_POEndDate_ContractValidation';
        update currentUser;
        ASI_CRM_CN_Contract_Controller con;
        ApexPages.currentPage().getParameters().put('ASI_CRM_CN_Outlet_WS__c',a2s[0].Id);
        ApexPages.currentPage().getParameters().put('outletId',a2s[0].Id);
        ApexPages.currentPage().getParameters().put('ASI_TH_CRM_Promotion_Type__c','Heavy Contract On');
        ApexPages.currentPage().getParameters().put('RecordType', Global_RecordTypeCache.getRtId('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract'));
        ApexPages.Standardcontroller stdController = new ApexPages.Standardcontroller(ct);  
        con = new ASI_CRM_CN_Contract_Controller(stdController);

     
        test.startTest();
        
        con.changeBusinessLicense();
        con.CheckSpecialPromotionType();
        con.SetSpecialPromotionType_BCRate();
        con.pendingPR = true;
        con.POModification();

        con.pendingPR = false;
        con.Total_Payments_Amount=100000000;
        con.POModification();

        con.restorePO();
        con.UpdateContractRecord();

        //insert new ASI_TH_CRM_PaymentRequest__c(ASI_TH_CRM_Contract__c=cts[1].Id, ASI_TH_CRM_Status__c='Submitted',ASI_CRM_CN_Paid_In_Progress__c=1);
    
        con.changeBusinessLicense();
        con.contractSelected.ASI_CRM_CN_Business_License__c = 'Unqualified';
        con.changeBusinessLicense();
        
        con.BypassCheckContractUpload = false;
        con.GoPayment();

        con.BypassCheckContractUpload = true;
        con.GoPayment();

        con.ContractSelected.ASI_CRM_CN_Contract_Upload__c = true;
        con.GoPayment();

        con.GroupContractChange();
        con.Addall_CoveredOutlet();
        con.retrieveOutletPicklist();
        con.setCustomerChannel();
        con.UpdateContractDetailRecord();

        ASI_CRM_CN_Contract_Controller.findSObjects('Account',' NOT ISNULL(Id)','');

        test.stopTest();   
    }
    //dolphin contract
    static testMethod void ASI_CRM_CN_Contract_Controller_TEST_9() {
        Account acc = new Account(Name='TEST', RecordTypeId = Global_RecordTypeCache.getRtId('AccountASI_MFM_CN_Outlet'));
        insert acc;

        ASI_CRM_Region__c region = new ASI_CRM_Region__c (Name='TEST',ASI_CRM_Create_Heavy_Contract_On__c=true,ASI_CRM_CN_Is_2nd_KPI_PO__c=true,ASI_CRM_CN_Create_TOT_MOT_Contract__c=true);
        insert region;
        
        ASI_CRM_Division__c division = new ASI_CRM_Division__c(Name='TEST', ASI_CRM_Region__c=region.Id);
        insert division;
        
        ASI_CRM_CN_Area__c area = new ASI_CRM_CN_Area__c(Name='TEST', ASI_CRM_English_Name__c='TEST', ASI_CRM_Division__c=division.Id);
        insert area;
        
        ASI_CRM_Province__c province = new ASI_CRM_Province__c(Name='TEST');
        insert province;

        ASI_CRM_City__c city = new ASI_CRM_City__c(Name='TEST', ASI_CRM_CN_Area__c=area.Id, ASI_CRM_CN_Province__c=province.id);
        insert city;

        ASI_CRM_CN_Channel_Group__c groupChannel = new ASI_CRM_CN_Channel_Group__c(Name='OFF TOT',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CN_Channel_Group__cASI_CRM_CN_Channel_Group'));
        insert groupChannel;
        
        ASI_CRM_CN_Channel__c channel = new ASI_CRM_CN_Channel__c(Name='KTV',ASI_CRM_BC_Rate__c=98,ASI_CRM_CN_On_Off__c='ON',ASI_CRM_For_Outlet__c=true,RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CN_Channel__cASI_CRM_CN_New_Channel'),ASI_CRM_For_Contract__c=TRUE);
        insert channel;
        
        ASI_MFM_Sub_Channel__c subChannel = new ASI_MFM_Sub_Channel__c(ASI_CRM_CN_Channel__c=channel.Id);
        insert subChannel;

        ASI_CRM_CN_Channel__c newChannel = new ASI_CRM_CN_Channel__c(ASI_CRM_For_Outlet__c = true, Name='Restaurant',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CN_Channel__cASI_CRM_CN_New_Channel'),ASI_CRM_CN_On_Off__c='OFF');
        insert newChannel;

        Id rtWS = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_CN_WS');
        Id rtOutlet = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN');
    
        list<ASI_CRM_AccountsAdditionalField__c> Customers = new list<ASI_CRM_AccountsAdditionalField__c>();
        Customers.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Commercial_Team__c = 'Premium',ASI_CRM_CN_New_Image__c='Iconic',RecordTypeId=rtWS,Name='TEST', ASI_CRM_CN_Image__c='Iconic',ASI_CRM_CN_CCity__c=city.Id,ASI_CRM_CN_NewChannel__c=channel.Id));
        Customers.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Commercial_Team__c = 'Premium',ASI_CRM_CN_New_Image__c='Iconic',RecordTypeId=rtOutlet,Name='TEST', ASI_CRM_CN_Image__c='Iconic',ASI_CRM_CN_CCity__c=city.Id,ASI_CRM_CN_NewChannel__c=channel.Id));
        insert Customers;

        ASI_CRM_KA_Account__c KAAccount = NEW ASI_CRM_KA_Account__c(Name='诺亚 Noah',recordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_KA_Account__cASI_CRM_CN_Group'),ASI_CRM_National_Group__c=true);
        insert KAAccount;

        list<ASI_CRM_AccountsAdditionalField__c> a2s = new list<ASI_CRM_AccountsAdditionalField__c>();
        a2s.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Commercial_Team__c = 'Premium',
            RecordTypeId=rtWS,ASI_CRM_Channel_Group__c = groupChannel.id,
            Name='TEST', ASI_CRM_CN_KA_Account_Chain__c=KAAccount.id,
            ASI_CRM_CN_Image__c='Iconic',
            ASI_CRM_CN_CCity__c=city.Id,
            ASI_CRM_CN_Dummy_Outlet_Flag__c=true,
            ASI_CRM_CN_DolphinFalcon_Flag__c = 'Dolphin Division',
            ASI_CRM_CN_Sub_Channel__c=subChannel.Id,ASI_CRM_CN_NewChannel__c=newChannel.Id));
        a2s.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Commercial_Team__c = 'Premium',
            RecordTypeId=rtOutlet,ASI_CRM_Channel_Group__c = groupChannel.id,
            Name='TEST', ASI_CRM_CN_KA_Account_Chain__c=KAAccount.id,
            ASI_CRM_CN_Image__c='Iconic',
            ASI_CRM_CN_CCity__c=city.Id,
            ASI_CRM_CN_Dummy_Outlet_Flag__c=false,
            ASI_CRM_CN_DolphinFalcon_Flag__c = 'Dolphin A',
            ASI_CRM_CN_Sub_Channel__c=subChannel.Id,ASI_CRM_CN_NewChannel__c=newChannel.Id));
        insert a2s;
        
        a2s = [SELECT Id, ASI_CRM_Account__c FROM ASI_CRM_AccountsAdditionalField__c WHERE Id=:a2s[0].Id OR Id=:a2s[1].Id];
        
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

        ASI_MFM_Brand__c brand = new ASI_MFM_Brand__c (
            ASI_CRM_CN_Competitor__c=false);
        insert brand;
        
        list<ASI_CRM_Sub_Brand_Grade__c> grades = new list<ASI_CRM_Sub_Brand_Grade__c>();
        grades.add(new ASI_CRM_Sub_Brand_Grade__c (Name='TEST1'));
        grades.add(new ASI_CRM_Sub_Brand_Grade__c (Name='TEST2'));
        grades.add(new ASI_CRM_Sub_Brand_Grade__c (Name='TEST3'));
        insert grades;

        list<ASI_CRM_Sub_Brand_Group__c> groups = new list<ASI_CRM_Sub_Brand_Group__c>();
        groups.add(new ASI_CRM_Sub_Brand_Group__c(Name='TEST'));
        groups.add(new ASI_CRM_Sub_Brand_Group__c(Name='Chivas 12'));
        insert groups;
            
        list<ASI_MFM_Sub_brand__c> subBrands = new list<ASI_MFM_Sub_brand__c>();
        for(ASI_CRM_Sub_Brand_Grade__c grade :grades) {
            for(ASI_CRM_Sub_Brand_Group__c gp: groups) {
                subBrands.add(new ASI_MFM_Sub_brand__c (
                    Name='TEST1',
                    ASI_MFM_Brand__c=brand.Id,
                    ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,
                    ASI_CRM_CN_Sub_brand_Grade__c=grade.Id,
                    ASI_CRM_CN_SubBrand_Group_c__c=gp.Id));
                subBrands.add(new ASI_MFM_Sub_brand__c (
                    Name='TEST2',
                    ASI_MFM_Brand__c=brand.Id,
                    ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,
                    ASI_CRM_CN_Sub_brand_Grade__c=grade.Id,
                    ASI_CRM_CN_SubBrand_Group_c__c=gp.Id));
                subBrands.add(new ASI_MFM_Sub_brand__c (
                    Name='TEST3',
                    ASI_MFM_Brand__c=brand.Id,
                    ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,
                    ASI_CRM_CN_Sub_brand_Grade__c=grade.Id,
                    ASI_CRM_CN_SubBrand_Group_c__c=gp.Id));
            }
            subBrands.add(new ASI_MFM_Sub_brand__c (
                Name='TEST3',
                ASI_MFM_Brand__c=brand.Id,
                ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,
                ASI_CRM_CN_Sub_brand_Grade__c=grade.Id,
                ASI_CRM_CN_SubBrand_Group_c__c=null));
        }
        insert subBrands;

        ASI_TH_CRM_Contract__c GroupContract = new ASI_TH_CRM_Contract__c(recordtypeid = Global_RecordTypeCache.getRTID('ASI_TH_CRM_Contract__cASI_CRM_CN_Group_Contract'),
                                                                          ASI_CRM_CN_PO_Start_Date__c = system.today().addDays(-180),ASI_CRM_NationalGroup__c=KAAccount.Id,
                                                                          ASI_CRM_CN_PO_End_Date__c =system.today().addDays(180),
                                                                          Name = 'Noah C4',ASI_CRM_CN_Bottle_Collection_Rate__c=0.97,
                                                                          ASI_CRM_CN_Outlet_WS__c=Customers[1].Id);
        insert GroupContract;

        Date poStartDate =  Date.today().toStartOfMonth().addMonths(-3);
        Date poEndDate = poStartDate.addMonths(6).addDays(-1);
        ASI_TH_CRM_Contract__c ct = new ASI_TH_CRM_Contract__c(
            recordtypeid = Global_RecordTypeCache.getRTID('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract'),
            ASI_CRM_CN_Status__c = 'Final',
            ASI_CRM_CN_PO_Start_Date__c = poStartDate,
            ASI_CRM_CN_PO_End_Date__c = poEndDate,
            ASI_TH_CRM_Outlet__c=a2s[0].ASI_CRM_Account__c, ASI_CRM_CN_Group_Contract__c=GroupContract.Id,
            ASI_CRM_CN_PO_Version__c = '0.0', ASI_TH_CRM_Promotion_Type__c = 'Heavy Contract On',
            Name = 'Contract1',
            ASI_CRM_CN_Outlet_WS__c=a2s[1].Id,ASI_CRM_Volume_Option__c = 'Normal'
            );
        insert ct;
        
        ASI_CRM_Contract_Cost__c contractCost = new ASI_CRM_Contract_Cost__c(
            ASI_CRM_CN_Contract__c = ct.id,
            ASI_CRM_CN_Estimate_Amount__c = 100000,
            ASI_CRM_CN_Cost_Type__c = 'Variable',
            ASI_CRM_CN_Other_Cost_Payment_Request__c = true,
            recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_Contract_Cost__cASI_CRM_CN_Contract_Cost')
        );
        insert contractCost;

        list<ASI_CRM_CN_Contract_BRSF_Line_Item__c> ctis = new list<ASI_CRM_CN_Contract_BRSF_Line_Item__c>();
        list<ASI_CRM_CN_Covered_Outlet__c> cos = new list<ASI_CRM_CN_Covered_Outlet__c>();
        for(ASI_MFM_Sub_brand__c subBrand :subBrands) {
            ctis.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(
                ASI_CRM_CN_Contract__c=ct.Id,
                ASI_CRM_CN_Est_Monthly_Qty__c=1,
                ASI_CRM_CN_Contract_Monthly_Qty__c=1,
                ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,
                ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,
                ASI_CRM_CN_Sub_Brand__c=subBrand.Id,
                recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CN_Contract_BRSF_Line_Item')
            ));
        }
        ctis.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(
                ASI_CRM_CN_Contract__c=ct.Id,
                ASI_CRM_CN_Est_Monthly_Qty__c=1,
                ASI_CRM_CN_Contract_Monthly_Qty__c=1,
                ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,
                ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,
                ASI_CRM_CN_Sub_Brand__c=null,
                recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CN_Contract_BRSF_Line_Item')
            ));
        cos.add(new ASI_CRM_CN_Covered_Outlet__c(
            ASI_CRM_CN_Contract__c=ct.Id,
            ASI_CRM_CN_Outlet__c=a2s[0].Id,
                recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Covered_Outlet__cASI_CRM_CN_Covered_Outlet')));
        
        insert ctis;
        insert cos;
        currentUser.LanguageLocaleKey='zh_CN';
        currentUser.BypassTriggers__c='ASI_CRM_CN_Contract_TriggerClass,CN_POEndDate_ContractValidation';
        update currentUser;
        
        test.startTest();
        ASI_CRM_CN_Contract_Controller con;
        ASI_TH_CRM_Contract__c testContract = new ASI_TH_CRM_Contract__c();
        ApexPages.Standardcontroller stdController = new ApexPages.Standardcontroller(testContract);
        ApexPages.currentPage().getParameters().put('RecordType', Global_RecordTypeCache.getRtId('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract'));  
        con = new ASI_CRM_CN_Contract_Controller(stdController);

     
        //con.init();

        test.stopTest();   
    }
}