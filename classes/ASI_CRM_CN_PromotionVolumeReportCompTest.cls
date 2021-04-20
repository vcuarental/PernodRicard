/*
    Author:Bowen/Canter
    Date : 2019-08-08
    Function :
        测试类 ASI_CRM_CN_PromotionVolumeReportCompCtrl  82%
*/
@isTest
private class ASI_CRM_CN_PromotionVolumeReportCompTest 
{
    @testSetup static void setup() {
    	test.startTest();
        ASI_CRM_Region__c region = new ASI_CRM_Region__c (Name='Central Region',recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Region__cASI_CRM_CN_Region'));
        insert region;
        
        ASI_CRM_Division__c division = new ASI_CRM_Division__c(Name='TEST', ASI_CRM_Region__c=region.Id);
        insert division;
        
        ASI_CRM_CN_Area__c area = new ASI_CRM_CN_Area__c(Name='TEST', ASI_CRM_English_Name__c='TEST', ASI_CRM_Division__c=division.Id);
        insert area;
        
        ASI_CRM_City__c city = new ASI_CRM_City__c(Name='TEST', ASI_CRM_CN_Area__c=area.Id);
        insert city;
        
        ASI_CRM_CN_Channel_Group__c ChannelGroup = new ASI_CRM_CN_Channel_Group__c(Name='Test',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CN_Channel_Group__cASI_CRM_CN_Channel_Group'));
        insert ChannelGroup;
        
        ASI_CRM_CN_Channel__c channel = new ASI_CRM_CN_Channel__c(Name='KTV',ASI_CRM_BC_Rate__c=98,ASI_CRM_CN_On_Off__c='ON',ASI_CRM_For_Outlet__c=true,RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CN_Channel__cASI_CRM_CN_New_Channel'),ASI_CRM_For_Contract__c=TRUE,ASI_CRM_CN_Channel_Group__c=ChannelGroup.Id);
        insert channel;
        
        //Id rtWS = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_CN_WS');
        Id rtOutlet = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN');
        
    	list<ASI_CRM_AccountsAdditionalField__c> Customers = new list<ASI_CRM_AccountsAdditionalField__c>();
        //Customers.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Commercial_Team__c = 'Premium',RecordTypeId=rtWS,Name='TEST', ASI_CRM_CN_Image__c='Iconic',ASI_CRM_CN_CCity__c=city.Id,ASI_CRM_CN_NewChannel__c=channel.Id));
        Customers.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Commercial_Team__c = 'Premium',RecordTypeId=rtOutlet,Name='TEST', ASI_CRM_CN_Image__c='Iconic',ASI_CRM_CN_CCity__c=city.Id,ASI_CRM_CN_NewChannel__c=channel.Id,ASI_CRM_Channel_Group__c=ChannelGroup.Id));
        insert Customers;
        
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
        
        Profile p = [SELECT Id FROM Profile where name = '系统管理员' or name = 'System Administrator']; 
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
        
    	//Date PO_Start_Date = date.newinstance(system.today().year(), system.today().month(), 1);
    	Date PO_Start_Date = date.newinstance(system.today().addMonths(-1).year(), system.today().addMonths(-1).month(), 1);
        Date PO_End_Date = PO_Start_Date.addMonths(1)-1;
    	ASI_TH_CRM_Contract__c Contract = new ASI_TH_CRM_Contract__c(recordtypeid = Global_RecordTypeCache.getRTID('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract'),
                                                                     ASI_CRM_CN_Status__c = 'Draft',
                                                                     ownerId = userList[0].id,
                                                                     ASI_CRM_System_Debug__c=true,
                                                                     ASI_CRM_CN_PO_Start_Date__c = PO_Start_Date,
                                                                     ASI_CRM_CN_PO_End_Date__c =PO_End_Date,
                                                                     ASI_CRM_CN_PO_Version__c = '0.0',
                                                                     ASI_TH_CRM_Promotion_Type__c='TOT/MOT Group PO',
                                                                     Name = 'Contract1',
                                                                     ASI_CRM_CN_Outlet_WS__c=Customers[0].Id,
                                                                     ASI_CRM_Volume_Option__c = 'Normal');
        insert Contract;
		        
        List<ASI_CRM_Module__c> ModuleList = new List<ASI_CRM_Module__c>();
        ModuleList.add(new ASI_CRM_Module__c(ASI_CRM_Contract__c=Contract.Id,ASI_CRM_CN_Contract_Volume_Base__c='POS',
                                             ASI_CRM_Unit__c='Std. Btl.',ASI_CRM_Volume_Base__c='By Sub-Brand',ASI_CRM_Line_Type__c='BRSF'));
        
        list<ASI_CRM_Sub_Brand_Grade__c> grades = new list<ASI_CRM_Sub_Brand_Grade__c>();
        grades.add(new ASI_CRM_Sub_Brand_Grade__c (Name='TEST1'));
        insert grades;
        
        ASI_MFM_Sub_brand__c subBrand=new ASI_MFM_Sub_brand__c(Name='subBrand1',ASI_MFM_Active_for_MFM__c=TRUE,
                                                               ASI_CRM_CN_Sub_brand_Grade__c = grades[0].Id, 
                                                               recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand'));
        insert subBrand;
        
        ASI_CRM_CN_Contract_BRSF_Line_Item__c contractItem = new ASI_CRM_CN_Contract_BRSF_Line_Item__c(recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF'),
                                                                                                            ASI_CRM_CN_Contract__c = Contract.Id,
                                                                                                       		ASI_CRM_CN_Sub_Brand__c = subBrand.Id,
                                                                                                            ASI_CRM_Type__c = 'BRSF');
        insert contractItem;
        
        list<ASI_MFM_Item_Group__c> itemGroupList = new list<ASI_MFM_Item_Group__c>();        
        itemGroupList.add(new ASI_MFM_Item_Group__c(ASI_MFM_Sub_brand__c = subBrand.Id,
                                                               ASI_CRM_CN_Drop_In__c=true,
                                                               ASI_CRM_CN_Exclusion__c = true,
                                                               ASI_CRM_CN_BT_Size_C__c = '70.0000'                                                        		
                                                              ));         
        insert itemGroupList;
        
        Map<Id ,Id> itemGroupMap = new Map<Id ,Id>();
        itemGroupMap.put(subBrand.Id ,itemGroupList[0].Id);
        
        List<ASI_CRM_Exclude_Item_Group_Volume__c> excludeItemList = new List<ASI_CRM_Exclude_Item_Group_Volume__c>();
        
        excludeItemList.add(new ASI_CRM_Exclude_Item_Group_Volume__c(ASI_CRM_Account__c = Customers[0].Id ,ASI_CRM_Outlet__c = Customers[0].Id ,ASI_CRM_Sub_Brand__c = subBrand.Id ,
                                                                     ASI_CRM_End_Date__c = Date.today().toStartOfMonth().addDays(-2),
                                                                     ASI_CRM_CN_Intake_GS_T1_price__c = 20,
                                                                     ASI_CRM_POS_9L__c = 20 ,ASI_CRM_POS_GS__c = 20,
                                                                     ASI_CRM_CN_Item_Group__c = itemGroupMap.get(subBrand.Id),
                                                                     ASI_CRM_Depletion__c = 20 ,ASI_CRM_Depletion_GS_T1_Price__c = 20
                                                                    ));
            
        
        insert excludeItemList;
        
        list<ASI_CRM_Subbrand_Volume__c> svols = new list<ASI_CRM_Subbrand_Volume__c>();
        svols.add(new ASI_CRM_Subbrand_Volume__c(
            ASI_CRM_Subbrand__c = subBrand.Id,
            ASI_CRM_CN_Region__c = 'testss',
            ASI_CRM_End_Date__c = system.today().addMonths(-1),
            ASI_CRM_PR_Direct__c = 1, ASI_CRM_T1_Depletion_GS__c = 1, ASI_CRM_PR_SHIPMENT__c = 1, ASI_CRM_Offtake__c = 1));
        insert svols;

        
        test.stopTest();
    }
    
    static testMethod void ASI_CRM_CN_OffContractVolumeRptCtrlTest() {
    	ASI_TH_CRM_Contract__c Contract = [Select Id from ASI_TH_CRM_Contract__c where Name = 'Contract1'];             
        ApexPages.currentPage().getParameters().put('id',Contract.Id); 

        ASI_CRM_CN_PromotionVolumeReportCtrl PromotionVolumeReport = new ASI_CRM_CN_PromotionVolumeReportCtrl();
        ASI_CRM_CN_PromotionVolumeReportCompCtrl PromotionVolumeReportCompCtrl = new ASI_CRM_CN_PromotionVolumeReportCompCtrl(); 

        // PromotionVolumeReportCompCtrl.DataClass dataclass = new ASI_CRM_CN_PromotionVolumeReportCompCtrl.DataClass();

        PromotionVolumeReportCompCtrl.CopyDataClass(PromotionVolumeReportCompCtrl.testMethod1());
        PromotionVolumeReportCompCtrl.AddIntakeDataClass(PromotionVolumeReportCompCtrl.testMethod1(), PromotionVolumeReportCompCtrl.testMethod1());
        PromotionVolumeReportCompCtrl.AddOfftakeDataClass(PromotionVolumeReportCompCtrl.testMethod1(), PromotionVolumeReportCompCtrl.testMethod1());
        PromotionVolumeReportCompCtrl.AlignDataClassSBInfo(PromotionVolumeReportCompCtrl.testMethod1(), PromotionVolumeReportCompCtrl.testMethod1());

        // ASI_CRM_Subbrand_Volume__c volume = new ASI_CRM_Subbrand_Volume__c();
        // insert volume;
        // PromotionVolumeReportCompCtrl.CalculatingVolume(true, volume);
        PromotionVolumeReportCompCtrl.DataRounding(1);
        PromotionVolumeReportCompCtrl.DataRounding(1, 2);
        PromotionVolumeReportCompCtrl.init();
        PromotionVolumeReportCompCtrl.init_Contractdata();
        PromotionVolumeReportCompCtrl.init_SubBrandVolumeData();
        
        ASI_CRM_Subbrand_Volume__c AsiVolum = [Select id,ASI_CRM_Subbrand__r.Name,ASI_CRM_Subbrand__c,
                                               ASI_CRM_POS_Std_Billing__c,
                                               ASI_CRM_POS_CR12__c,
                                               ASI_CRM_POS_GS__c,
                                               ASI_CRM_Offtake_Std_Billing__c,
                                               ASI_CRM_Offtake_CR12__c,
                                               ASI_CRM_Offtake_GS__c,
                                               ASI_CRM_Actual_Vol_STD__c,
                                               ASI_CRM_Actual_Vol_CR12__c,
                                               ASI_CRM_Intake_GS__c,
                                               ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__c,
                                               ASI_CRM_Subbrand__r.ASI_CRM_Sub_Brand_Grade_Sequence__c,
                                               ASI_CRM_Subbrand__r.ASI_CRM_CN_COnvfactor_Ltocr12_C__c,
                                               ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name
                                               from ASI_CRM_Subbrand_Volume__c ];
        List<ASI_CRM_Exclude_Item_Group_Volume__c> excludeList = new List<ASI_CRM_Exclude_Item_Group_Volume__c>();
        excludeList = [select Id,
            ASI_CRM_POS_GS__c,
            ASI_CRM_POS_9L__c,
            ASI_CRM_Depletion__c,
            ASI_CRM_Actual_Vol_9L__c,
            ASI_CRM_CN_Intake_GS_T1_price__c,
            ASI_CRM_Outlet__c,
            ASI_CRM_Outlet__r.ASI_CRM_CN_CRM_Code__c,
            ASI_CRM_Account__r.ASI_CRM_CN_CRM_Code__c ,
            ASI_CRM_Account__c,
            ASI_CRM_Sub_Brand__c,
            ASI_CRM_CN_Item_Group__r.ASI_CRM_CN_Drop_In__c,
            ASI_CRM_CN_Item_Group__r.ASI_CRM_CN_BT_Size_C__c from  ASI_CRM_Exclude_Item_Group_Volume__c];
        PromotionVolumeReportCompCtrl.isFlag('70' , true , excludeList[0]);
        
        PromotionVolumeReportCompCtrl.CalculatingVolume(true,AsiVolum);
        PromotionVolumeReportCompCtrl.CalculatingVolume(false,AsiVolum);
        // PromotionVolumeReportCompCtrl.GeneratingURL();
                
    }
}