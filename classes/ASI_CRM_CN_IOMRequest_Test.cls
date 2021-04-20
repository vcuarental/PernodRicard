@isTest (SeeAllData=false)
public class ASI_CRM_CN_IOMRequest_Test{
    
    static testMethod void ASI_CRM_CN_IOMRequest_TriggerClass_TEST() {
        
        ASI_CRM_Region__c region = new ASI_CRM_Region__c(Name='TEST');
        insert region;
        
        ASI_CRM_Division__c division = new ASI_CRM_Division__c(ASI_CRM_Region__c=region.Id);
        insert division;
        
        ASI_CRM_CN_Area__c area = new ASI_CRM_CN_Area__c(ASI_CRM_Division__c=division.Id);
        insert area;
        
        ASI_CRM_City__c city = new ASI_CRM_City__c(ASI_CRM_CN_Area__c=area.Id);
        insert city;
        
        ASI_CRM_CN_Channel__c channel = new ASI_CRM_CN_Channel__c(ASI_CRM_CN_On_Off__c='ON');
        insert channel;
        
        ASI_MFM_Sub_Channel__c subChannel = new ASI_MFM_Sub_Channel__c(ASI_MFM_Channel__c = 'aaa', ASI_CRM_CN_Channel__c=channel.Id);
        insert subChannel;
        
        ASI_CRM_AccountsAdditionalField__c outlet = new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_CCity__c=city.Id, ASI_CRM_CN_Sub_Channel__c =subChannel.Id, RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN'));
        insert outlet;
        
        ASI_CRM_Image_Outlet_Plan__c plan = new ASI_CRM_Image_Outlet_Plan__c(
            ASI_CRM_Fiscal_Year__c='FY13/14',
            ASI_CRM_Region__c=region.Id,
            ASI_CRM_Sub_Channel__c=subChannel.Id
            );
        insert plan;
     
        ASI_CRM_Fix_Approval_Route__c fapp = new ASI_CRM_Fix_Approval_Route__c(ASI_CRM_CN_Approver_1__c=UserInfo.getUserId(), ASI_CRM_CN_Type__c='IOM', ASI_CRM_CN_Region_Area_Channel__c='TEST', ownerid=UserInfo.getUserId());
        //ASI_CRM_Fix_Approval_Route__c fapp = new ASI_CRM_Fix_Approval_Route__c(ASI_CRM_CN_Approver_1__c=user2.id, ASI_CRM_CN_Type__c='IOM', ASI_CRM_CN_Region_Area_Channel__c='TEST', ownerid=user2.id);
        insert fapp;
                    
        list<ASI_CRM_Image_Outlet_Request__c> iomRequests = new list<ASI_CRM_Image_Outlet_Request__c>();
        iomRequests.add(new ASI_CRM_Image_Outlet_Request__c(
            ASI_CRM_Application_Date__c=date.newInstance(2013,7,1),
            ASI_CRM_Outlet__c=outlet.Id
        	, recordTypeID = Global_RecordTypeCache.getRtId('ASI_CRM_Image_Outlet_Request__cASI_CRM_OFF')
        ));
        insert iomRequests;
        test.startTest();
        
        ASI_CRM_CN_IOMRequest_TriggerClass.routineBeforeInsert(iomRequests);
        ASI_CRM_CN_IOMRequest_TriggerClass.routineBeforeDelete(iomRequests);
        update iomRequests;
        test.stopTest();
    }
    
    static testMethod void ASI_CRM_CN_InputImageOutletRequestCon_TEST() {
        ASI_CRM_Region__c region = new ASI_CRM_Region__c(Name='TEST');
        insert region;
        
        ASI_CRM_Division__c division = new ASI_CRM_Division__c(ASI_CRM_Region__c=region.Id);
        insert division;
        
        ASI_CRM_CN_Area__c area = new ASI_CRM_CN_Area__c(ASI_CRM_Division__c=division.Id);
        insert area;
        
        ASI_CRM_City__c city = new ASI_CRM_City__c(ASI_CRM_CN_Area__c=area.Id);
        insert city;
        
        ASI_CRM_CN_Channel__c channel = new ASI_CRM_CN_Channel__c(ASI_CRM_CN_On_Off__c='ON');
        insert channel;
        
        ASI_MFM_Sub_Channel__c  subChannel = new ASI_MFM_Sub_Channel__c (ASI_MFM_Channel__c = 'aaa', ASI_CRM_CN_Channel__c=channel.Id, Name='TEST');
        insert subChannel;
        
        ASI_CRM_AccountsAdditionalField__c outlet = new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_CCity__c=city.Id, ASI_CRM_CN_Sub_Channel__c =subChannel.Id, RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN'), ASI_CRM_CN_Image__c='Premium');
        insert outlet;
        //ASI_CRM_AccountsAdditionalField__c outlet2 = new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_CCity__c=city.Id, ASI_CRM_CN_Sub_Channel__c =subChannel.Id, RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN'), ASI_CRM_CN_Image__c='Premium');
        //insert outlet2;
        
        ASI_CRM_Image_Outlet_Plan__c plan = new ASI_CRM_Image_Outlet_Plan__c(
            ASI_CRM_Fiscal_Year__c='FY13/14',
            ASI_CRM_Region__c=region.Id,
            ASI_CRM_Sub_Channel__c=subChannel.Id
            );
        insert plan;
        
        //User user2 = ASI_MFM_Function.getManagerCN();        

        //ASI_CRM_Fix_Approval_Route__c fapp = new ASI_CRM_Fix_Approval_Route__c(ASI_CRM_CN_Approver_1__c=user2.id, ASI_CRM_CN_Type__c='IOM', ASI_CRM_CN_Region_Area_Channel__c='TEST', ownerid=user2.id);
        //insert fapp;
                    
        //***** non-saved IOM obj *****        
        list<ASI_CRM_Image_Outlet_Request__c> iomRequests = new list<ASI_CRM_Image_Outlet_Request__c>();
        iomRequests.add(new ASI_CRM_Image_Outlet_Request__c(
            RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_Image_Outlet_Request__cASI_CRM_ON'),
            ASI_CRM_Application_Date__c=date.newInstance(2013,7,1),
            ASI_CRM_Outlet__c=outlet.Id));
        
        
        //***** saved IOM obj *****
        list<ASI_CRM_Image_Outlet_Request__c> iomRequests2 = new list<ASI_CRM_Image_Outlet_Request__c>();
        iomRequests2.add(new ASI_CRM_Image_Outlet_Request__c(
            RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_Image_Outlet_Request__cASI_CRM_ON'),
            ASI_CRM_Application_Date__c=date.newInstance(2013,7,1),
            ASI_CRM_Outlet__c=outlet.Id));
        iomRequests2.add(new ASI_CRM_Image_Outlet_Request__c(
            RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_Image_Outlet_Request__cASI_CRM_OFF'),
            ASI_CRM_Application_Date__c=date.newInstance(2013,7,1),
            ASI_CRM_Status__c = 'Approved by AD',
            ASI_CRM_Outlet__c=outlet.Id));
        insert iomRequests2;

        ASI_MFM_Brand__c brand = new ASI_MFM_Brand__c (
        ASI_CRM_CN_Competitor__c=false);
        insert brand;

        ASI_MFM_Sub_brand__c subBrand = new ASI_MFM_Sub_brand__c (
            ASI_MFM_Brand__c=brand.Id,
            ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,
            RecordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand'),
            ASI_MFM_Active_for_CRM__c=true
            );
        insert subBrand;

        ASI_CRM_Image_Outlet_Request_SubBrand__c iomSubBrand = new ASI_CRM_Image_Outlet_Request_SubBrand__c(Name='TEST', ASI_CRM_Image_Production__c='TEST', ASI_CRM_IOM__c=iomRequests2[0].id, ASI_CRM_Sub_Brand__c=subBrand.id);
        insert iomSubBrand;

        ASI_CRM_Image_Outlet_Site__c iomSite = new ASI_CRM_Image_Outlet_Site__c(Name='TEST', ASI_CRM_Image_Outlet_Request__c=iomRequests2[0].id, ASI_CRM_Expected__c=subBrand.id);
        ASI_CRM_Image_Outlet_Site__c iomSite2 = new ASI_CRM_Image_Outlet_Site__c(Name='TEST', ASI_CRM_Image_Outlet_Request__c=iomRequests2[0].id, ASI_CRM_Expected__c=subBrand.id);
        insert iomSite;

        //***** create contract (start) *****
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

        list<ASI_TH_CRM_Contract__c> cts = new list<ASI_TH_CRM_Contract__c>();
        cts.add(new ASI_TH_CRM_Contract__c(
            recordtypeid = Global_RecordTypeCache.getRTID('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract'),
            ASI_TH_CRM_Outlet__c=outlet.ASI_CRM_Account__c, 
            ASI_CRM_CN_PO_Start_Date__c=system.today(), 
            ASI_CRM_CN_PO_End_Date__c=system.today().addMonths(1),
            ASI_CRM_CN_Outlet_WS__c=outlet.Id,
            ASI_TH_CRM_Promotion_Type__c='New Contract ON',
            ASI_CRM_CN_PO_Version__c = '0.0',
            Name = 'Contract1',
            ASI_CRM_CN_Status__c='Final'));
        insert cts[0];
        cts.add(new ASI_TH_CRM_Contract__c(
            recordtypeid = Global_RecordTypeCache.getRTID('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract'),
            ASI_TH_CRM_Outlet__c=outlet.ASI_CRM_Account__c, 
            ASI_CRM_CN_PO_Start_Date__c=system.today().addMonths(-2), 
            ASI_CRM_CN_PO_End_Date__c=system.today().addMonths(-1), 
            ASI_CRM_CN_Outlet_WS__c=outlet.Id,
            ASI_TH_CRM_Promotion_Type__c='New Contract ON',
			ASI_CRM_CN_PO_Version__c = '0.1',
            Name = 'Contract2',
            ASI_CRM_CN_PO_Modification__c=true,
          ASI_CRM_CN_V0_0_PO_version__c=cts[0].Id));
        insert cts[1];
        //***** create contract (end) *****

        list<ASI_CRM_CN_Contract_BRSF_Line_Item__c> ctis = new list<ASI_CRM_CN_Contract_BRSF_Line_Item__c>();
        ctis.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(
            ASI_CRM_CN_Contract__c=cts[0].Id,
            ASI_CRM_CN_Est_Monthly_Qty__c=1,
            ASI_CRM_CN_Est_BRSF_Per_Bottle__c=1,
            ASI_CRM_CN_Contract_Monthly_Qty__c=1,
            RecordTypeId=Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CN_Contract_BRSF_Line_Item'),
            ASI_CRM_CN_Sub_Brand__c=subBrand.Id
        ));
        insert ctis;

        list<ASI_CRM_CN_Channel_Strategy__c> css = new list<ASI_CRM_CN_Channel_Strategy__c>();
        css.add(new ASI_CRM_CN_Channel_Strategy__c(
            ASI_CRM_CN_Area__c=area.Id,
            ASI_CRM_CN_Image__c='Premium',
            ASI_CRM_CN_Fiscal_Year__c=ASI_CRM_CN_Function.getFiscalYear(system.today()),
            ASI_CRM_CN_Sub_Channel__c=subChannel.Id));
        insert css;
        
        list<ASI_CRM_CN_Channel_Strategy_Line_Item__c> csis = new list<ASI_CRM_CN_Channel_Strategy_Line_Item__c>();
        for(ASI_CRM_CN_Channel_Strategy__c cs :css) {
          csis.add(new ASI_CRM_CN_Channel_Strategy_Line_Item__c(ASI_CRM_CN_Channel_Strategy__c=cs.Id, ASI_CRM_CN_Brand__c='Priority 1'));
          csis.add(new ASI_CRM_CN_Channel_Strategy_Line_Item__c(ASI_CRM_CN_Channel_Strategy__c=cs.Id, ASI_CRM_CN_Brand__c='Priority 2'));
        }
        insert csis;

        list<ASI_CRM_Subbrand_Volume__c> svs = new list<ASI_CRM_Subbrand_Volume__c>();
        for(integer i=0; i<=24; i++) {
            svs.add(new ASI_CRM_Subbrand_Volume__c(
                ASI_CRM_Account__c=outlet.Id,
                ASI_CRM_Subbrand__c=subBrand.Id,
                ASI_CRM_Month__c='01',
                ASI_CRM_Year__c='2014',
                ASI_CRM_End_Date__c=system.today().addMonths(-i+3)
            ));
        }
        insert svs;
        
        ASI_CRM_CN_Covered_Outlet__c co0 = new ASI_CRM_CN_Covered_Outlet__c(
            ASI_CRM_CN_Contract__c=cts[0].Id,
            RecordTypeId=Global_RecordTypeCache.getRTID('ASI_CRM_CN_Covered_Outlet__cASI_CRM_CN_Covered_Outlet'),
            ASI_CRM_CN_Outlet__c=outlet.Id);
        insert co0;
        ASI_CRM_CN_Covered_Outlet__c co1 = new ASI_CRM_CN_Covered_Outlet__c(
            ASI_CRM_CN_Contract__c=cts[0].Id,
            RecordTypeId=Global_RecordTypeCache.getRTID('ASI_CRM_CN_Covered_Outlet__cASI_CRM_CN_Covered_Outlet'),
            ASI_CRM_CN_Outlet__c=outlet.Id);
        list<ASI_CRM_CN_Covered_Outlet__c> newList = new list<ASI_CRM_CN_Covered_Outlet__c>();
        newList.add(co1);

        ApexPages.StandardController scon = new ApexPages.StandardController(iomRequests[0]);
        ApexPages.StandardController scon2 = new ApexPages.StandardController(iomRequests2[0]);
        ApexPages.StandardController scon3 = new ApexPages.StandardController(iomRequests2[1]);
        
        test.startTest();
        {
            ASI_CRM_CN_InputImageOutletRequestCon con = new ASI_CRM_CN_InputImageOutletRequestCon(scon);
            ApexPages.currentPage().getParameters().put('Id', iomRequests2[0].id);
            ApexPages.currentPage().getParameters().put('RecordType', iomRequests2[0].RecordTypeId);
            ASI_CRM_CN_InputImageOutletRequestCon con2 = new ASI_CRM_CN_InputImageOutletRequestCon(scon2);
            
            ASI_CRM_CN_InputImageOutletRequestCon.findSObjects('ASI_CRM_Image_Outlet_Request__c','','');
            con2.LImageSite.add(iomSite2);
            con2.LImageSite_del.add(iomSite2);
            con2.addRow();
            con2.addIOMATRow();
            con2.rowid = 'a1';
            con2.removeSBRow();
            con2.rowid = 'a0';
            con2.removeRow();
            con2.OutletSelected();
            con2.selectRT();
            con2.EditIOM();
            con2.BackIOM();
            con2.createPO();
            con2.saveAll();
            con2.MATOutletTotal();
            con2.checkPeriod('1', '2014');
            con2.checkPeriod('0', '2014');
            con2.searchOutlet();
            con2.getContractInfo();
            ASI_CRM_CN_InputImageOutletRequestCon.IOMG_Data data = new ASI_CRM_CN_InputImageOutletRequestCon.IOMG_Data();
            con2.requestHQ();

            ApexPages.currentPage().getParameters().put('Id', iomRequests2[1].id);
            ApexPages.currentPage().getParameters().put('RecordType', iomRequests2[1].RecordTypeId);
            ASI_CRM_CN_InputImageOutletRequestCon con3 = new ASI_CRM_CN_InputImageOutletRequestCon(scon3);
            con3.OutletSelected();
            
            delete iomRequests2;
        }
        test.stopTest();
    }
}