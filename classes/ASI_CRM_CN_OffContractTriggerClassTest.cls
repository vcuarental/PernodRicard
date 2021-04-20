/***************************************************************************************************************************
 * Name:        ASI_CRM_CN_OffContractTriggerClassTest 
 * Description: Test class for ASI_CRM_CN_OffContractTriggerClass
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2018-12-28       Keith Yip               Created
 ****************************************************************************************************************************/
 @isTest
public class ASI_CRM_CN_OffContractTriggerClassTest {
    
    @testSetup static void setup() {

    }
    
    static testMethod void ASI_CRM_CN_OffContractTriggerClassTest() {	
    	
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
        
        ASI_CRM_CN_Channel__c channel = new ASI_CRM_CN_Channel__c(Name='KTV',ASI_CRM_BC_Rate__c=98,ASI_CRM_CN_On_Off__c='ON',ASI_CRM_For_Outlet__c=true,RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CN_Channel__cASI_CRM_CN_New_Channel'),ASI_CRM_For_Contract__c=TRUE);
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
                                                                     ASI_CRM_CN_Status__c = 'Final',
                                                                     ownerId = userList[0].id,
                                                                     ASI_CRM_System_Debug__c=true,
                                                                     ASI_CRM_CN_PO_Start_Date__c = PO_Start_Date,
                                                                     ASI_CRM_CN_PO_End_Date__c =PO_End_Date,
                                                                     ASI_CRM_Active_Dummy_PO__c = true,
                                                                     ASI_CRM_CN_PO_Version__c = '0.0',
                                                                     ASI_TH_CRM_Promotion_Type__c='TOT/MOT Group PO',
                                                                     Name = 'Contract1',
                                                                     ASI_CRM_CN_Outlet_WS__c=Customers[0].Id,
                                                                     ASI_CRM_Volume_Option__c = 'Normal');
                 
        
        Date PO_Start_Date2 = date.newinstance(system.today().year(), system.today().month(), 1).addMonths(2);
        Date PO_End_Date2 = PO_Start_Date2.addMonths(1)-1;
        
        ASI_TH_CRM_Contract__c Contract2 = new ASI_TH_CRM_Contract__c(recordtypeid = Global_RecordTypeCache.getRTID('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract'),
                                                               ASI_CRM_CN_Status__c = 'Archived',
                                                               ASI_CRM_CN_PO_Version__c = '0.0',ASI_TH_CRM_Promotion_Type__c='Heavy Contract On',
                                                               Name = 'Contract2',
                                                               ASI_CRM_CN_Outlet_WS__c=Customers[0].Id,ASI_CRM_Volume_Option__c = 'Normal');
        
        ASI_TH_CRM_Contract__c Contract3 = new ASI_TH_CRM_Contract__c(recordtypeid = Global_RecordTypeCache.getRTID('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract'),
                                                               ASI_CRM_CN_Status__c = 'Draft',
                                                               ASI_CRM_CN_V0_0_PO_version__c=Contract2.Id,ASI_CRM_CN_Last_PO_version__c=Contract2.Id,
                                                               ASI_CRM_CN_PO_Version__c = '0.1',ASI_TH_CRM_Promotion_Type__c='Heavy Contract On',
                                                               Name = 'Contract3',
                                                               ASI_CRM_CN_Outlet_WS__c=Customers[0].Id,ASI_CRM_Volume_Option__c = 'Normal');
        
        ASI_TH_CRM_Contract__c Contract4 = new ASI_TH_CRM_Contract__c(recordtypeid = Global_RecordTypeCache.getRTID('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract'),
                                                               ASI_CRM_CN_Status__c = 'Final',
                                                               ASI_CRM_CN_V0_0_PO_version__c=Contract2.Id,ASI_CRM_CN_Last_PO_version__c=Contract2.Id,
                                                               ASI_CRM_CN_PO_Version__c = '0.1',ASI_TH_CRM_Promotion_Type__c='Heavy Contract On',
                                                               Name = 'Contract4',
                                                               ASI_CRM_Last_RBA_Approver__c = UserInfo.getUserId(),
                                                               ASI_CRM_CN_Outlet_WS__c=Customers[0].Id,ASI_CRM_Volume_Option__c = 'Normal');
        

        List<ASI_TH_CRM_Contract__c> ContractList = new List<ASI_TH_CRM_Contract__c>();
        ContractList.add(Contract);
        ContractList.add(Contract2);
        ContractList.add(Contract3);
        ContractList.add(Contract4);
               
    	ASI_CRM_CN_OffContractTriggerClass.routineBeforeInsert(ContractList);
    	ASI_CRM_CN_OffContractTriggerClass.assignGroupPO(ContractList);
        Map<Id, List<ASI_TH_CRM_Contract__c>> mapvValue = ASI_CRM_CN_OffContractTriggerClass.getAvailableGroupPO(ContractList);
        List<ASI_TH_CRM_Contract__c> listValue = ASI_CRM_CN_OffContractTriggerClass.getAvailableGroupPO(ContractList[0]);
    	
    	test.stopTest();
    }
}