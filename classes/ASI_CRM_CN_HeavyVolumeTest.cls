@isTest

public class ASI_CRM_CN_HeavyVolumeTest {
    
    //ASI_CRM_CN_HeavyPSFFormController
    //
    //ASI_CRM_CN_HeavyBRSFFormCtrl
    
    
    static testMethod void ASI_CRM_CN_VolumeReportTest() {
        //Test Class for  ASI_CRM_CN_HeavyCTDVolumeReportCtrl       ASI_CRM_CN_HeavyVolumeReportPDFCtrl ASI_CRM_CN_HeavyVolumeReportCtrl   ASI_CRM_CN_HeavyContractVolumeReportCtrl
       
        
        ASI_CRM_Region__c region = new ASI_CRM_Region__c (Name='TEST');
        insert region;
        
        ASI_CRM_Division__c division = new ASI_CRM_Division__c(Name='TEST', ASI_CRM_Region__c=region.Id);
        insert division;
        
        ASI_CRM_CN_Area__c area = new ASI_CRM_CN_Area__c(Name='TEST', ASI_CRM_English_Name__c='TEST', ASI_CRM_Division__c=division.Id);
        insert area;
        
        ASI_CRM_City__c city = new ASI_CRM_City__c(Name='TEST', ASI_CRM_CN_Area__c=area.Id);
        insert city;
        
        ASI_CRM_CN_Channel__c channel = new ASI_CRM_CN_Channel__c(Name='KTV',ASI_CRM_BC_Rate__c=98,ASI_CRM_CN_On_Off__c='ON',ASI_CRM_For_Outlet__c=true,RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CN_Channel__cASI_CRM_CN_New_Channel'),ASI_CRM_For_Contract__c=TRUE);
        insert channel;
        
        Id rtWS = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_CN_WS');
        Id rtOutlet = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN');
        
        list<ASI_CRM_AccountsAdditionalField__c> Customers = new list<ASI_CRM_AccountsAdditionalField__c>();
        Customers.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Commercial_Team__c = 'Premium',RecordTypeId=rtWS,Name='TEST', ASI_CRM_CN_Image__c='Iconic',ASI_CRM_CN_CCity__c=city.Id,ASI_CRM_CN_NewChannel__c=channel.Id));
        Customers.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Commercial_Team__c = 'Premium',RecordTypeId=rtOutlet,Name='TEST', ASI_CRM_CN_Image__c='Iconic',ASI_CRM_CN_CCity__c=city.Id,ASI_CRM_CN_NewChannel__c=channel.Id));
        insert Customers;
        
        //Covered_Outlet
        list<ASI_CRM_AccountsAdditionalField__c> ChildCustomers = new list<ASI_CRM_AccountsAdditionalField__c>();
        ChildCustomers.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Parent_Outlet__c=Customers[1].Id,ASI_CRM_CN_Commercial_Team__c = 'Premium',RecordTypeId=rtOutlet,Name='TEST', ASI_CRM_CN_Image__c='Iconic',ASI_CRM_CN_CCity__c=city.Id,ASI_CRM_CN_NewChannel__c=channel.Id));
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
        
        List<ASI_CRM_Subbrand_Volume__c> SubBrandVolumeList= new  List<ASI_CRM_Subbrand_Volume__c>();
        Date TodayDateBefore3= system.today().addMonths(-5);
        
        ASI_CRM_Subbrand_Volume__c TempVolume = new ASI_CRM_Subbrand_Volume__c(ASI_CRM_Account__c=Customers[1].Id,ASI_CRM_Subbrand__c=subBrands[0].Id,
                                                                               ASI_CRM_End_Date__c=system.today().addMonths(-3),
                                                                               ASI_CRM_Month__c=string.valueOf(system.today().addMonths(-3).month()),
                                                                               ASI_CRM_Year__c=string.valueOf(system.today().addMonths(-3).year()));
        SubBrandVolumeList.add(ASI_CRM_CN_HeavyContractTestClassHelper.VolumeFieldAssignment(TempVolume));
        
        insert SubBrandVolumeList;
        system.debug('debug SubBrandVolumeList :'+SubBrandVolumeList);
        system.debug('debug TodayDateBefore3 :'+TodayDateBefore3);
        
        Date PO_Start_Date = date.newinstance(TodayDateBefore3.year(), TodayDateBefore3.month(), 1);
        Date PO_End_Date = PO_Start_Date.addMonths(12)-1;
        
            ASI_TH_CRM_Contract__c Contract = new ASI_TH_CRM_Contract__c(recordtypeid = Global_RecordTypeCache.getRTID('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract'),
                                                                         ASI_CRM_CN_Status__c = 'Final',
                                                                         ASI_CRM_CN_PO_Start_Date__c = PO_Start_Date,
                                                                         ASI_CRM_CN_PO_End_Date__c =PO_End_Date,
                                                                         ASI_CRM_CN_PO_Version__c = '0.0',ASI_TH_CRM_Promotion_Type__c='Heavy Contract On',
                                                                         Name = 'Contract1',
                                                                         ASI_CRM_CN_Outlet_WS__c=Customers[1].Id,ASI_CRM_Volume_Option__c = 'Normal');
            insert Contract;
            
            List<ASI_CRM_Module__c> ModuleList = new List<ASI_CRM_Module__c>();
            ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='Std. Btl.',ASI_CRM_Volume_Base__c='By Sub-Brand',ASI_CRM_Line_Type__c='BRSF'));
            ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='Std. Btl.',ASI_CRM_Volume_Base__c='By Sub-Brand',ASI_CRM_Line_Type__c='PSF'));
            ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='CR12 Extra Eqv.',ASI_CRM_Volume_Base__c='By Grade',ASI_CRM_Line_Type__c='PSF'));
            ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='CR12 Extra Eqv.',ASI_CRM_Volume_Base__c='By Total',ASI_CRM_Line_Type__c='PSF'));
            ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_Unit__c='CR12 Extra Eqv.',ASI_CRM_Volume_Base__c='By Total',ASI_CRM_Line_Type__c='Variable Event Cost'));
            
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
        
        
        
        
        test.startTest();        
        //PageReference EnterPage = Page.ASI_CRM_CN_HeavyVolumeReportPDF;
        //Test.setCurrentPage(EnterPage);
        ApexPages.currentPage().getParameters().put('id', Contract.id);
        
        ApexPages.Standardcontroller stdController = new ApexPages.Standardcontroller(Contract);  
        ASI_CRM_CN_HeavyVolumeReportPDFCtrl con = new ASI_CRM_CN_HeavyVolumeReportPDFCtrl(stdController);
        con.StartDateStr=ASI_CRM_CN_HeavyContractUtilitiesClass.DateToString(PO_Start_Date,'yyyy-MM-dd' );
        con.EndDateStr=ASI_CRM_CN_HeavyContractUtilitiesClass.DateToString(PO_End_Date,'yyyy-MM-dd' );
        ApexPages.currentPage().getParameters().put('id', Contract.id);
        con.currentHeaderId= Contract.id;
        con.init();
        
        
        
        ASI_CRM_CN_HeavyCTDVolumeReportCtrl con2 = new ASI_CRM_CN_HeavyCTDVolumeReportCtrl();
        con2.currentHeaderId= Contract.id;
        con2.init();
        
        
        
        ASI_CRM_CN_HeavyContractVolumeReportCtrl con3= new ASI_CRM_CN_HeavyContractVolumeReportCtrl();
        ApexPages.currentPage().getParameters().put('id', Contract.id);
        con3.init();
        con3.CTDproceed();
        con3.proceed();
        
        
        
        
        ASI_CRM_CN_HeavyVolumeReportCtrl  con4 = new ASI_CRM_CN_HeavyVolumeReportCtrl();
   
      
        test.stopTest(); 
    }
}