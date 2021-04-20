@isTest
/*********************************************************************************
* Name:ASI_CRM_Price_And_Approval_Ctrl_Test 
* Description: 

* Version History
* Date             Developer               Comments
* ---------------  --------------------    --------------------------------------------------------------------------------
* 2020-12-03       Wilken Lee               [WL 1.0] Add validation to allow delete for Draft/Rejected price only
*********************************************************************************/
public class ASI_CRM_Price_And_Approval_Ctrl_Test {
    public static testMethod void test1(){
          Profile admin_p = [SELECT Id FROM Profile WHERE Name='ASI System Administrator'];//System Administrator
        User adminUser = new User(Alias = 'admin', Email='adminuser@testorg.com', 
                            EmailEncodingKey='UTF-8', LastName='admin', LanguageLocaleKey='zh_CN', Autofollow__c = false,
                            LocaleSidKey='zh_CN', ProfileId = admin_p.Id,IsActive = true,
                            TimeZoneSidKey='Asia/Shanghai', UserName='test2@wholesaler.com',
                            CompanyName = 'Pernod Ricard China');
        insert adminUser;
        System.runAs(adminUser) {
            

            ASI_CRM_Region__c region = new ASI_CRM_Region__c (Name='TEST');
            insert region;
            
            ASI_CRM_Division__c division = new ASI_CRM_Division__c(Name='TEST', ASI_CRM_Region__c=region.Id);
            insert division;
            
            ASI_CRM_CN_Area__c area = new ASI_CRM_CN_Area__c(Name='TEST', ASI_CRM_English_Name__c='TEST', ASI_CRM_Division__c=division.Id);
            insert area;
            
            ASI_CRM_City__c city = new ASI_CRM_City__c(ASI_CRM_CN_City_Code__c='TEST', ASI_CRM_CN_Area__c=area.Id);
            insert city;

            ASI_CRM_CN_Channel__c channel = new ASI_CRM_CN_Channel__c(ASI_CRM_CN_On_Off__c='ON', ASI_CRM_For_Outlet__c=true, RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CN_Channel__cASI_CRM_CN_New_Channel'));
            insert channel;
         List<ASI_MFM_Sub_Channel__c> tmpSubChannel = new List<ASI_MFM_Sub_Channel__c>();   
            tmpSubChannel.add(new ASI_MFM_Sub_Channel__c(ASI_CRM_CN_Channel__c=channel.Id));
            tmpSubChannel.add(new ASI_MFM_Sub_Channel__c(Name = 'VIP', ASI_CRM_CN_Channel__c=channel.Id));
            
            insert tmpSubChannel;
          ASI_CRM_AccountsAdditionalField__c  tmpCustomer = new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Chi_Name__c = 'testing3', ASI_CRM_CN_NewChannel__c=channel.Id, ASI_CRM_CN_CRM_Code__c='test003', ASI_CRM_CN_Eng_Name__c = 'Testing3', ASI_CRM_CN_Estimated_annual_order_amount__c = 1,ASI_CRM_CN_Is_IHBR_Outlet__c = True, ASI_CRM_CN_Commercial_Team__c='Premium', ASI_CRM_CN_Sub_Channel__c=tmpSubChannel[0].Id, ASI_CRM_CN_CCity__c=city.Id, ASI_CRM_CN_JDE_Code__c = 'asd', ASI_CRM_CN_JDE_Code_RTD__c = 'asd', ASI_CRM_Latest_Call_Plan_Date__c=system.today(), RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN'));
            insert tmpCustomer;
                        
           ASI_MFM_Item_Group__c tmpItemGroup = new ASI_MFM_Item_Group__c(RecordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Item_Group__cASI_CRM_CN_CRM_Item_Group')
                                                       , Name = 'TestItemGroup'
                                                       , ASI_MFM_Item_Group_Code__c = 'TestItemGroupCode'
                                                       , ASI_CRM_CN_Eng_Name__c = 'TestItemGroup'
                                                       , ASI_CRM_CN_Not_In_Use__c = FALSE
                                                       , ASI_CRM_CN_Gift_Set_C__c = FALSE
                                                       , ASI_CRM_CN_EMPTY_BOX_C__c = FALSE
                                                       , OwnerID = UserInfo.getUserId()
                                                      );
            insert tmpItemGroup;
            
                ASI_CRM_Price_And_Discount__c tmpPnD = new ASI_CRM_Price_And_Discount__c(OwnerId =  UserInfo.getUserId()
                                                         , RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Price_And_Discount__cASI_CRM_CN_Customer_Price_and_Discount_Request')
                                                         , ASI_CRM_Customer__c = tmpCustomer.id
                                                         , ASI_CRM_Status__c = 'Open'
                                                        );
        insert tmpPnD;
              ASI_CRM_Price_And_Discount_Detail__c detail = new ASI_CRM_Price_And_Discount_Detail__c(ASI_CRM_Price_And_Discount__c = tmpPnD.id 
                                                                  , RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Price_And_Discount_Detail__cASI_CRM_CN_Price_And_Discount_Detail')
                                                                  , ASI_CRM_Item_Group_Description__c = tmpItemGroup.Id
                                                                  , ASI_CRM_Total_Estimated_Vol_BT__c = 1
                                                                  , ASI_CRM_New_Price_BT_with_VAT__c = 1
                                                                  , ASI_CRM_Current_T1_Price_BT_with_VAT__c = 3
                                                                 );
        insert detail;
        test.startTest();
        ASI_CRM_Price_And_Approval_Ctrl ctr = new ASI_CRM_Price_And_Approval_Ctrl();
        ctr.recordId = tmpPnD.Id;
       ctr.priceAndDiscount =  ctr.getpriceAndDiscount();
       ctr.priceAndDiscountDetails =     ctr.getpriceAndDiscountDetails();
            ctr.actionName = 'Submit';
           
              ASI_CRM_Price_And_Discount__c tmpPnD1 = new ASI_CRM_Price_And_Discount__c(OwnerId =  UserInfo.getUserId()
                                                         , RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Price_And_Discount__cASI_CRM_SG_Rebate_Period')
                                                         , ASI_CRM_Customer__c = tmpCustomer.id
                                                         , ASI_CRM_Status__c = 'Open'
                                                         ,ASI_CRM_SG_Effective_Date__c = Date.valueOf('2020-07-01')                           
                                                        );
        insert tmpPnD1;
        
            /*[WL 1.0] BEGIN*/
            try {
                delete tmpPnD1;
            }
            catch (Exception e){}
            /*[WL 1.0] END*/
            test.stopTest();
        }
    }
}