/**
 * @File Name          : ASI_CRM_RedirectContractView_CtrTest.cls
 * @Description        : 
 * @Author             : pengchen@bluelinksys.com
 * @Group              : 
 * @Last Modified By   : pengchen@bluelinksys.com
 * @Last Modified On   : 5/18/2020, 9:39:24 AM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    5/18/2020   pengchen@bluelinksys.com     Initial Version
**/
@isTest
public class ASI_CRM_RedirectContractView_CtrTest {
    static testMethod void ASI_CRM_RedirectContract_Test() {
        //---- covered classes: ----
        //---- 1. ASI_CRM_RedirectContractEdit_Ctr ----
        //---- 2. ASI_CRM_RedirectContractNew_Ctr ----
        //---- 3. ASI_CRM_RedirectContractView_Ctr ----
        
        User currentUser = [SELECT id, name, Managerid, ASI_CRM_CN_Prefix__c FROM USER WHERE id =:UserInfo.getUserId()];
        
        ASI_CRM_Dynamic_Approval_Route__c dar = new ASI_CRM_Dynamic_Approval_Route__c(ASI_CRM_Type__c='Contract');
        insert dar;
        
        list<ASI_CRM_Fix_Approval_Route__c> fars = new list<ASI_CRM_Fix_Approval_Route__c>();
        fars.add(new ASI_CRM_Fix_Approval_Route__c(ASI_CRM_CN_Type__c = 'Contract 1st Part',ASI_CRM_CN_Region_Area_Channel__c='TEST'));
        fars.add(new ASI_CRM_Fix_Approval_Route__c(ASI_CRM_CN_Type__c = 'Contract 2nd Part',ASI_CRM_CN_Region_Area_Channel__c='TEST'));
        insert fars;
        
        Id rtContract = Global_RecordTypeCache.getRtId('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract');
        Id rtContractTH = Global_RecordTypeCache.getRtId('ASI_TH_CRM_Contract__cASI_TH_CRM_Contract');
        
        ASI_CRM_Region__c region = new ASI_CRM_Region__c (Name='TEST');
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
        a2s.add(new ASI_CRM_AccountsAdditionalField__c(
            RecordTypeId=rtWS,
            Name='TEST', 
            ASI_CRM_CN_Image__c='Iconic',
            ASI_CRM_CN_CCity__c=city.Id,
            ASI_CRM_CN_Sub_Channel__c=subChannel.Id));
        a2s.add(new ASI_CRM_AccountsAdditionalField__c(
            RecordTypeId=rtOutlet,
            Name='TEST', 
            ASI_CRM_CN_Image__c='Iconic',
            ASI_CRM_CN_CCity__c=city.Id,
            ASI_CRM_CN_Sub_Channel__c=subChannel.Id,
          ASI_CRM_CN_Commercial_Team__c = 'Premium'));
        insert a2s;
        
        a2s = [SELECT Id, ASI_CRM_Account__c FROM ASI_CRM_AccountsAdditionalField__c WHERE Id=:a2s[0].Id OR Id=:a2s[1].Id];
        
        list<ASI_HK_CRM_Running_Number__c> rns = new list<ASI_HK_CRM_Running_Number__c>();
        rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_TH_CRM_Contract__c'));
        if(!String.isBlank(currentUser.ASI_CRM_CN_Prefix__c))
            rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_'+currentUser.ASI_CRM_CN_Prefix__c));
        else{
            rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_NULL'));
            rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_'));
        }
        rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_TH_CRM_PaymentRequest__c'));
        insert rns;
        
        insert new ASI_MFM_Exchange_Rate__c(
            ASI_MFM_Application__c='CRM',
            ASI_MFM_Country__c='CN',
            ASI_MFM_Base_Currency__c='RMB',
            ASI_MFM_Counter_Currency__c='USD',
            ASI_MFM_Effective_Date__c=system.today().addYears(-10),
            ASI_MFM_Exchange_Rate__c=1);
        
        ASI_MFM_Brand__c brand = new ASI_MFM_Brand__c (
        ASI_CRM_CN_Competitor__c=false);
        insert brand;
        
        ASI_MFM_Sub_brand__c subBrand = new ASI_MFM_Sub_brand__c (
            ASI_MFM_Brand__c=brand.Id,
            ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1);
        insert subBrand;
        
        ASI_CRM_Contract_Cost_Setting__c ccs = new ASI_CRM_Contract_Cost_Setting__c(
            ASI_CRM_CN_Promotion_Type__c='New Contract ON',
            ASI_CRM_CN_Fixed_Cost_Contract__c=true,
            ASI_CRM_CN_Variable_Cost_Contract__c=true);
        insert ccs;
        
        list<ASI_TH_CRM_Contract__c> cts = new list<ASI_TH_CRM_Contract__c>();

        ASI_TH_CRM_Contract__c ct0 = new ASI_TH_CRM_Contract__c(
            RecordTypeId=rtContract,
            name = 'contract0',
            ASI_TH_CRM_Outlet__c=a2s[1].ASI_CRM_Account__c, 
            ASI_CRM_CN_PO_Start_Date__c=system.today().addMonths(-2), 
            ASI_CRM_CN_PO_End_Date__c=system.today().addMonths(-1),
            ASI_CRM_CN_Outlet_WS__c=a2s[0].Id,
            ASI_TH_CRM_Promotion_Type__c='New Contract ON',
            ASI_CRM_CN_Status__c='Draft',
            ASI_CRM_CN_PO_Version__c='1.0',
            ASI_CRM_CN_Currency__c='USD',
            ASI_CRM_CN_Sys_Local_Currency__c='RMB');

        ASI_TH_CRM_Contract__c ct1 = new ASI_TH_CRM_Contract__c(
            RecordTypeId=rtContract,
            name = 'contract1',
            ASI_TH_CRM_Outlet__c=a2s[1].ASI_CRM_Account__c, 
            ASI_CRM_CN_PO_Start_Date__c=system.today().addMonths(-4), 
            ASI_CRM_CN_PO_End_Date__c=system.today().addMonths(-3),
            ASI_CRM_CN_Outlet_WS__c=a2s[0].Id,
            ASI_TH_CRM_Promotion_Type__c='New Contract ON',
            ASI_CRM_CN_Status__c='Draft',
            ASI_CRM_CN_PO_Modification__c=false,
            ASI_CRM_CN_PO_Version__c='1.1',
            ASI_CRM_CN_Currency__c='USD',
            ASI_CRM_CN_Sys_Local_Currency__c='RMB');
        ASI_TH_CRM_Contract__c ct2 = new ASI_TH_CRM_Contract__c(
            RecordTypeId=rtContractTH,
            name = 'contract2',
            ASI_TH_CRM_Outlet__c=a2s[1].ASI_CRM_Account__c, 
            ASI_CRM_CN_PO_Start_Date__c=system.today().addMonths(-6), 
            ASI_CRM_CN_PO_End_Date__c=system.today().addMonths(-5),
            ASI_CRM_CN_Outlet_WS__c=a2s[0].Id,
            ASI_TH_CRM_Promotion_Type__c='New Contract ON',
            ASI_CRM_CN_Status__c='Final',
            ASI_CRM_CN_PO_Modification__c=false,
            ASI_CRM_CN_PO_Version__c='1.0',
            ASI_CRM_CN_Currency__c='USD',
            ASI_CRM_CN_Sys_Local_Currency__c='RMB');
        ASI_TH_CRM_Contract__c ct3 = new ASI_TH_CRM_Contract__c(
            name = 'contract3',
            ASI_TH_CRM_Outlet__c=a2s[1].ASI_CRM_Account__c,
            ASI_CRM_CN_PO_Start_Date__c=system.today().addMonths(-6), 
            ASI_CRM_CN_PO_End_Date__c=system.today().addMonths(-5),
            ASI_CRM_CN_Outlet_WS__c=a2s[0].Id,
            ASI_TH_CRM_Promotion_Type__c='New Contract ON',
            ASI_CRM_CN_Status__c='Final',
            ASI_CRM_CN_PO_Modification__c=false,
            ASI_CRM_CN_PO_Version__c='1.0',
            ASI_CRM_CN_Currency__c='USD',
            ASI_CRM_CN_Sys_Local_Currency__c='RMB');

        ASI_TH_CRM_Contract__c ct4 = new ASI_TH_CRM_Contract__c(
            RecordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_Contract__cASI_CRM_CN_Group_Contract'),
            name = 'contract4',
            ASI_TH_CRM_Outlet__c=a2s[1].ASI_CRM_Account__c,
            ASI_CRM_CN_PO_Start_Date__c=system.today().addMonths(-6),
            ASI_CRM_CN_PO_End_Date__c=system.today().addMonths(-5),
            ASI_CRM_CN_Outlet_WS__c=a2s[0].Id,
            ASI_TH_CRM_Promotion_Type__c='New Contract ON',
            ASI_CRM_CN_Status__c='Final',
            ASI_CRM_CN_PO_Modification__c=false,
            ASI_CRM_CN_PO_Version__c='1.0',
            ASI_CRM_CN_Currency__c='USD',
            ASI_CRM_CN_Sys_Local_Currency__c='RMB');

        ASI_TH_CRM_Contract__c ct5 = new ASI_TH_CRM_Contract__c(
            RecordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_Contract__cASI_CRM_CN_Local_Group_Contract'),
            name = 'contract5',
            ASI_TH_CRM_Outlet__c=a2s[1].ASI_CRM_Account__c,
            ASI_CRM_CN_PO_Start_Date__c=system.today().addMonths(-6),
            ASI_CRM_CN_PO_End_Date__c=system.today().addMonths(-5),
            ASI_CRM_CN_Outlet_WS__c=a2s[0].Id,
            ASI_TH_CRM_Promotion_Type__c='New Contract ON',
            ASI_CRM_CN_Status__c='Final',
            ASI_CRM_CN_PO_Modification__c=false,
            ASI_CRM_CN_PO_Version__c='1.0',
            ASI_CRM_CN_Currency__c='USD',
            ASI_CRM_CN_Sys_Local_Currency__c='RMB');

        ASI_TH_CRM_Contract__c ct6 = new ASI_TH_CRM_Contract__c(
            RecordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_Contract__cASI_CRM_SG_Contract'),
            ASI_CRM_Type__c = 'Partner',
            name = 'contract6');

        ASI_TH_CRM_Contract__c ct7 = new ASI_TH_CRM_Contract__c(
            RecordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_Contract__cASI_CRM_SG_Proposal'),
            ASI_CRM_Type__c = 'Partner',
            name = 'contract7');

        ASI_TH_CRM_Contract__c ct8 = new ASI_TH_CRM_Contract__c(
            RecordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_Contract__cASI_CRM_SG_Proposal_Read_Only'),
            ASI_CRM_Type__c = 'Partner',
            name = 'contract8');

        ASI_TH_CRM_Contract__c ct9 = new ASI_TH_CRM_Contract__c(
            RecordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_Contract__cASI_CRM_MY_Contract'),
            name = 'contract9');

        ASI_TH_CRM_Contract__c ct10 = new ASI_TH_CRM_Contract__c(
            RecordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract'),
            name = 'contract10',
            ASI_TH_CRM_Outlet__c=a2s[1].ASI_CRM_Account__c,
            ASI_CRM_CN_PO_Start_Date__c=System.today().addMonths(-6).toStartOfMonth(),
            ASI_CRM_CN_PO_End_Date__c=System.today().addMonths(-5).toStartOfMonth().addDays(-1),
            ASI_CRM_CN_Outlet_WS__c=a2s[0].Id,
            ASI_TH_CRM_Promotion_Type__c='Heavy Contract On',
            ASI_CRM_CN_Status__c='Final',
            ASI_CRM_CN_PO_Modification__c=false,
            ASI_CRM_CN_PO_Version__c='1.0',
            ASI_CRM_CN_Currency__c='USD',
            ASI_CRM_CN_Sys_Local_Currency__c='RMB');

        ASI_TH_CRM_Contract__c ct11 = new ASI_TH_CRM_Contract__c(
            RecordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract'),
            name = 'contract11',
            ASI_TH_CRM_Outlet__c=a2s[1].ASI_CRM_Account__c,
            ASI_CRM_CN_PO_Start_Date__c=System.today().addMonths(-6).toStartOfMonth(),
            ASI_CRM_CN_PO_End_Date__c=System.today().addMonths(-5).toStartOfMonth().addDays(-1),
            ASI_CRM_CN_Outlet_WS__c=a2s[0].Id,
            ASI_TH_CRM_Promotion_Type__c='TOT/MOT Contract',
            ASI_CRM_CN_Status__c='Final',
            ASI_CRM_CN_PO_Modification__c=false,
            ASI_CRM_CN_PO_Version__c='1.0',
            ASI_CRM_CN_Currency__c='USD',
            ASI_CRM_CN_Sys_Local_Currency__c='RMB');

        cts.add(ct1);
        cts.add(ct2);
        cts.add(ct3);
        cts.add(ct4);
        cts.add(ct5);
        cts.add(ct6);
        cts.add(ct7);
        cts.add(ct8);
        cts.add(ct9);
        cts.add(ct10);
        cts.add(ct11);
        insert cts;
        
        test.startTest();

        ApexPages.currentPage().getParameters().put('a', '1');    
        ApexPages.currentPage().getParameters().put('b', null);

        for (ASI_TH_CRM_Contract__c contract : cts) {
            ApexPages.StandardController stdController = new ApexPages.StandardController(contract);

            //View Controller
            ASI_CRM_RedirectContractView_Ctr controllerView = new ASI_CRM_RedirectContractView_Ctr(stdController);
            controllerView.redirect();

            //Edit Controller
            ASI_CRM_RedirectContractEdit_Ctr controllerEdit = new ASI_CRM_RedirectContractEdit_Ctr(stdController);
            controllerEdit.redirect();

            //New Controller
            ASI_CRM_RedirectContractNew_Ctr controllerNew = new ASI_CRM_RedirectContractNew_Ctr(stdController);
            controllerNew.redirect();
        }

        ASI_CRM_RedirectContractView_Ctr controllerViewSG = new ASI_CRM_RedirectContractView_Ctr(
            new ApexPages.StandardController(
                new ASI_TH_CRM_Contract__c(RecordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_Contract__cASI_SG_CRM_Contract')
                )
            )
        );
        controllerViewSG.redirect();

        ASI_CRM_RedirectContractView_Ctr controllerViewMY = new ASI_CRM_RedirectContractView_Ctr(
            new ApexPages.StandardController(
                new ASI_TH_CRM_Contract__c(RecordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_Contract__ASI_CRM_MY_Contract')
                )
            )
        );
        controllerViewMY.redirect();
        
         /* PH Contract */
        ASI_CRM_RedirectContractView_Ctr controllerViewPH = new ASI_CRM_RedirectContractView_Ctr(
            new ApexPages.StandardController(
                new ASI_TH_CRM_Contract__c(RecordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_Contract__cASI_CRM_PH_Contract')
                )
            )
        );
        controllerViewPH.redirect();
        ASI_CRM_RedirectContractNew_Ctr controllerNewPH = new ASI_CRM_RedirectContractNew_Ctr(
            new ApexPages.StandardController(
                new ASI_TH_CRM_Contract__c(RecordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_Contract__cASI_CRM_PH_Contract')
                )
            )
        );
        controllerNewPH.redirect();
        ASI_CRM_RedirectContractEdit_Ctr controllerEditPH = new ASI_CRM_RedirectContractEdit_Ctr(
            new ApexPages.StandardController(
                new ASI_TH_CRM_Contract__c(RecordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_Contract__cASI_CRM_PH_Contract')
                )
            )
        );
        controllerEditPH.redirect();

        test.stopTest();       
    }
}