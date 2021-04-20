/*
+-----------------------+------------------------------------------------------------------------------------+
| Author                |Elufa                                                                
+-----------------------+------------------------------------------------------------------------------------+
| Description           | For ASI cn user                                                                              
|                       |                                                                                    
|     - Object(s)       | Test class : ASI_CRM_CN_ContractFinanceLanding                                                                       
|     - Description     |              ASI_CRM_CN_ContractFinanceLandingBatch             
+-----------------------+------------------------------------------------------------------------------------+
| Creation Date         | 27/3/2017 11:09 AM                                                                    
+-----------------------+------------------------------------------------------------------------------------+
| Modifications         |                                                                                    
+-----------------------+------------------------------------------------------------------------------------+
| Governor informations |                                                                                    
+-----------------------+------------------------------------------------------------------------------------+
*/
@istest
public class ASI_CRM_CN_ContractFinanceLandingTest {
    
    
    static testMethod void CN_ContractFinanceLandingTest() {
        
        List<User> lstUsr = new List<User>();
        User User1 = new User(managerid = UserInfo.getUserId(),ASI_CRM_CN_Prefix__c='27', ASI_MFM_Team__c = 'NTMK', ASI_MFM_Country__c ='CN', alias = 'test99',ASI_MFM_Bypass_Callouts__c = true, email='test99' + '@dev.com', emailencodingkey='UTF-8', firstname='test99', lastname='Testing', languagelocalekey='en_US', localesidkey='en_US', timezonesidkey='Europe/London', username='test99' + '@pernod-ricard.com',ProfileId = UserInfo.getProfileId(), UserRoleId = UserInfo.getUserRoleId(), isActive=true);
        User User2 = new User(managerid = UserInfo.getUserId(),ASI_CRM_CN_Prefix__c='27', ASI_MFM_Team__c = 'Procurement', ASI_MFM_Country__c ='CN', alias = 'tes99',ASI_MFM_Bypass_Callouts__c = true, email='tes99' + '@dev.com', emailencodingkey='UTF-8', firstname='tes99', lastname='Testing', languagelocalekey='en_US', localesidkey='en_US', timezonesidkey='Europe/London', username='tes99' + '@pernod-ricard.com',ProfileId = UserInfo.getProfileId(), UserRoleId = UserInfo.getUserRoleId(), isActive=true);
        lstUsr.add(user2);
        lstUsr.add(user1);
        insert lstUsr;
        
        user1 = [SELECT Id, Name, ManagerId, ASI_MFM_Bypass_Callouts__c, ASI_MFM_Country__c, UserRole.DeveloperName FROM User WHERE id =: user1.id LIMIT 1];
        user2 = [SELECT Id, Name, ManagerId, ASI_MFM_Bypass_Callouts__c, ASI_MFM_Country__c, UserRole.DeveloperName  FROM User WHERE id =: user2.id LIMIT 1];
        
        Date cutOffDate= date.today();
        
        System.runas(user2){
            
            ASI_CRM_Region__c region = new ASI_CRM_Region__c (Name='TEST');
            insert region;
            
            ASI_CRM_Division__c division = new ASI_CRM_Division__c(Name='TEST', ASI_CRM_Region__c=region.Id);
            insert division;
            
            ASI_CRM_CN_Area__c area = new ASI_CRM_CN_Area__c(Name='TEST', ASI_CRM_English_Name__c='TEST', ASI_CRM_Division__c=division.Id);
            insert area;
            
            ASI_CRM_Province__c province = new ASI_CRM_Province__c(Name='A');
            insert province;
            
            ASI_CRM_City__c city = new ASI_CRM_City__c(Name='TEST', ASI_CRM_CN_Area__c=area.Id, ASI_CRM_CN_Province__c=province.Id);
            insert city;
            
            ASI_CRM_CN_Channel__c channel = new ASI_CRM_CN_Channel__c(ASI_CRM_CN_On_Off__c='ON');
            insert channel;
            
            ASI_MFM_Sub_Channel__c subChannel = new ASI_MFM_Sub_Channel__c(ASI_CRM_CN_Channel__c=channel.Id);
            insert subChannel;
            
            ASI_CRM_CN_Channel__c newChannel1 = new ASI_CRM_CN_Channel__c(ASI_CRM_For_Outlet__c = true, ASI_CRM_For_Contract__c = true, Name='Test1',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CN_Channel__cASI_CRM_CN_New_Channel'),ASI_CRM_CN_On_Off__c='OFF');
            insert newChannel1;
            
            ASI_CRM_CN_Channel__c newChannel2 = new ASI_CRM_CN_Channel__c(ASI_CRM_For_Outlet__c = true, ASI_CRM_For_Contract__c = true, Name='Test2',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CN_Channel__cASI_CRM_CN_New_Channel'),ASI_CRM_CN_On_Off__c='ON');
            insert newChannel2;
            
            Id rtWS = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_CN_WS');
            Id rtOutlet = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN');
            
            list<ASI_CRM_AccountsAdditionalField__c> a2s = new list<ASI_CRM_AccountsAdditionalField__c>();
            a2s.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Commercial_Team__c = 'Premium',ASI_CRM_CN_NewChannel__c=newChannel1.Id,RecordTypeId=rtWS,Name='TEST', ASI_CRM_CN_Image__c='Iconic',ASI_CRM_CN_CCity__c=city.Id,ASI_CRM_CN_Sub_Channel__c=subChannel.Id));
            a2s.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Commercial_Team__c = 'Premium',ASI_CRM_CN_NewChannel__c=newChannel1.Id,RecordTypeId=rtOutlet,Name='TEST', ASI_CRM_CN_Image__c='Iconic',ASI_CRM_CN_CCity__c=city.Id,ASI_CRM_CN_Sub_Channel__c=subChannel.Id));
            insert a2s;
            
            a2s = [SELECT Id, ASI_CRM_Account__c,ASI_CRM_CN_NewChannel__c FROM ASI_CRM_AccountsAdditionalField__c WHERE Id=:a2s[0].Id OR Id=:a2s[1].Id];
  
            list<ASI_HK_CRM_Running_Number__c> rns = new list<ASI_HK_CRM_Running_Number__c>();
            rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_TH_CRM_Contract__c', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
            rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_TH_CRM_PaymentRequest__c', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
            rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo__c', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
            rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_27', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
            
            insert rns;
            
            
            Date d = date.newInstance(cutOffDate.addYears(-1).Year(), 7, 1);
            
            
            list<ASI_TH_CRM_Contract__c> cts = new list<ASI_TH_CRM_Contract__c>();
            cts.add(new ASI_TH_CRM_Contract__c(ASI_TH_CRM_Outlet__c=a2s[1].ASI_CRM_Account__c,ASI_CRM_CN_PO_Start_Date__c=system.today().addMonths(-4), ASI_CRM_CN_PO_End_Date__c=system.today().addMonths(-3),ASI_CRM_CN_Outlet_WS__c=a2s[1].Id,ASI_TH_CRM_Promotion_Type__c='New Contract ON',ASI_CRM_CN_Effective_Date__c=d,ASI_CRM_CN_Status__c='Submitted',ASI_CRM_CN_Last_Submitted_Date__c=cutOffDate,ASI_CRM_CN_PO_Version__c = '0.0',Name = 'Contract1',ASI_CRM_CN_Description__c='Description',ASI_CRM_CN_Bottle_Collection_Rate__c=10,ASI_CRM_CN_Vol_Budget_LE__c=10,RecordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract')));
            insert cts[0];
            
            
            ASI_MFM_Brand__c brand = new ASI_MFM_Brand__c (Name='Test1',ASI_CRM_CN_Competitor__c=false);
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
                    subBrands.add(new ASI_MFM_Sub_brand__c (Name='TEST1',ASI_MFM_Brand__c=brand.Id,ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,ASI_CRM_CN_Sub_brand_Grade__c=grade.Id,ASI_CRM_CN_SubBrand_Group_c__c=gp.Id));
                    subBrands.add(new ASI_MFM_Sub_brand__c (Name='TEST2',ASI_MFM_Brand__c=brand.Id,ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,ASI_CRM_CN_Sub_brand_Grade__c=grade.Id,ASI_CRM_CN_SubBrand_Group_c__c=gp.Id));
                    subBrands.add(new ASI_MFM_Sub_brand__c (Name='TEST3',ASI_MFM_Brand__c=brand.Id,ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,ASI_CRM_CN_Sub_brand_Grade__c=grade.Id,ASI_CRM_CN_SubBrand_Group_c__c=gp.Id));
                }
                subBrands.add(new ASI_MFM_Sub_brand__c (Name='TEST3',ASI_MFM_Brand__c=brand.Id,ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,ASI_CRM_CN_Sub_brand_Grade__c=grade.Id,ASI_CRM_CN_SubBrand_Group_c__c=null));
            }
            insert subBrands;
            
            
            list<ASI_CRM_CN_Contract_BRSF_Line_Item__c> ctis = new list<ASI_CRM_CN_Contract_BRSF_Line_Item__c>();
            list<ASI_CRM_CN_Covered_Outlet__c> cos = new list<ASI_CRM_CN_Covered_Outlet__c>();
            for(ASI_MFM_Sub_brand__c subBrand :subBrands) {
                ctis.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=cts[0].Id,ASI_CRM_CN_Est_Monthly_Qty__c=1,ASI_CRM_CN_Contract_Monthly_Qty__c=1,ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,ASI_CRM_CN_Sub_Brand__c=subBrand.Id,recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CN_Contract_BRSF_Line_Item')));
            }
            ctis.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Contract__c=cts[0].Id,ASI_CRM_CN_Est_Monthly_Qty__c=1,ASI_CRM_CN_Contract_Monthly_Qty__c=1,ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,ASI_CRM_CN_Sub_Brand__c=null,recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CN_Contract_BRSF_Line_Item')));
            cos.add(new ASI_CRM_CN_Covered_Outlet__c(ASI_CRM_CN_Contract__c=cts[0].Id,ASI_CRM_CN_Outlet__c=a2s[0].Id,recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Covered_Outlet__cASI_CRM_CN_Covered_Outlet')));
            
            insert ctis;
            insert cos;
            
            
            
            
            
            test.startTest();
            List<ASI_TH_CRM_Contract__Share> ContractSharingList= new List<ASI_TH_CRM_Contract__Share>();
            ContractSharingList.add(new ASI_TH_CRM_Contract__Share(RowCause =  Schema.ASI_TH_CRM_Contract__Share.RowCause.ASI_CRM_CN_Share_To_BA__c, AccessLevel = 'Read', ParentID = cts[0].Id, UserOrGroupId = user2.Id));
            insert ContractSharingList;
            
            List<ASI_CRM_Approval_Comment__c> ApprovalCommentList= new List<ASI_CRM_Approval_Comment__c>();
            ApprovalCommentList.add(new ASI_CRM_Approval_Comment__c(ASI_CRM_Contract__c=cts[0].Id,ASI_CRM_BA_comments__c='Test1',ASI_CRM_Background_Objective__c='Test2',ASI_CRM_Historical_Contract_Performance__c='Test3',ASI_CRM_New_contract_Analsysis__c='Test4'));
            insert ApprovalCommentList;
            
            
            database.executebatch(new ASI_CRM_CN_ContractFinanceLandingBatch(cutOffDate), 50);
            
            test.stopTest();
            
        }
    }
    
    
    static testMethod void CN_ContractFinanceLandingTest2() {
        
        
        test.startTest();
        
        ASI_CRM_CN_ContractFinanceLanding ext = new ASI_CRM_CN_ContractFinanceLanding();
        ext.executeLanding();
        Date LED = ext.lastExecutionDate;
        String[] testGetter = ext.StatusMsgs;
        
        test.stopTest();
    }
}