@isTest
private class ASI_MFM_CN_RepackRequest_Test{
    
    public class TestObj {
        
        public List<User> lstUsr;
        public User user1;
        public User user2;
        
        public List<ASI_MFM_Item_Group__c> tmpItemGroup;
        public List<ASI_MFM_SKU_Code__c> tmpSKUList;
        public List<ASI_CRM_Fix_Approval_Route__c> listFixRoute;
        
        public TestObj(){
            lstUsr = new List<User>();
            Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator GDT'];
            User1 = new User(managerid = UserInfo.getUserId(), ASI_MFM_Team__c = 'ABCD', ASI_MFM_Country__c ='CN', alias = 'test99',BypassVR__c = true, BypassWF__c  = true, BypassTriggers__c  = 'Autofollow_User_InsertUpdate; AutoJoin_User_InsertUpdate; ChatterEmailSettings; ESNProjectTrigger; AP01; ASI_HK_CRM_SalesOrderAssignApprover; ASI_MFM_ValidateSubBrandCode; ASI_MFM_GF_LockPOLine; ASI_CRM_CN_AccountsCRMCodeAutoNumber; ASI_CRM_TW_AccountMovement_TgrHdlr; ASI_CRM_CN_AccountsAdditional_TriggerCls; ASI_CRM_CN_ContractPONoAutoNumber; ASI_CRM_CN_GenPhPayeeLnItmNo_TgrHdlr; ASI_CRM_CN_Contract_TriggerClass; ASI_MFM_TR_ByPassTrigger; ASI_MFM_KR_Cross_Fiscal_Year_Checking; Autofollow_User_InsertUpdate,AutoJoin_Us', ASI_MFM_Bypass_Callouts__c = true, email='test99' + '@dev.com', emailencodingkey='UTF-8', firstname='test99', lastname='Testing', languagelocalekey='en_US', localesidkey='en_US', timezonesidkey='Europe/London', username='test99' + '@pernod-ricard.com',ProfileId =p.Id, UserRoleId = UserInfo.getUserRoleId(), isActive=true);
            User2 = new User(managerid = UserInfo.getUserId(), ASI_MFM_Team__c = 'ABCD', ASI_MFM_Country__c ='CN', alias = 'tes99',BypassVR__c = true, BypassWF__c  = true, BypassTriggers__c  = 'Autofollow_User_InsertUpdate; AutoJoin_User_InsertUpdate; ChatterEmailSettings; ESNProjectTrigger; AP01; ASI_HK_CRM_SalesOrderAssignApprover; ASI_MFM_ValidateSubBrandCode; ASI_MFM_GF_LockPOLine; ASI_CRM_CN_AccountsCRMCodeAutoNumber; ASI_CRM_TW_AccountMovement_TgrHdlr; ASI_CRM_CN_AccountsAdditional_TriggerCls; ASI_CRM_CN_ContractPONoAutoNumber; ASI_CRM_CN_GenPhPayeeLnItmNo_TgrHdlr; ASI_CRM_CN_Contract_TriggerClass; ASI_MFM_TR_ByPassTrigger; ASI_MFM_KR_Cross_Fiscal_Year_Checking; Autofollow_User_InsertUpdate,AutoJoin_Us',ASI_MFM_Bypass_Callouts__c = true, email='tes99' + '@dev.com', emailencodingkey='UTF-8', firstname='tes99', lastname='Testing', languagelocalekey='en_US', localesidkey='en_US', timezonesidkey='Europe/London', username='tes99' + '@pernod-ricard.com',ProfileId =p.Id, UserRoleId = UserInfo.getUserRoleId(), isActive=true);
            lstUsr.add(user1);
            lstUsr.add(user2);
            insert lstUsr;
            
            for(user u : [SELECT Id, Name, ManagerId,BypassVR__c,BypassWF__c,BypassTriggers__c, ASI_MFM_Bypass_Callouts__c, ASI_MFM_Country__c, UserRole.DeveloperName 
                          FROM User
                          WHERE id =: user1.id 
                          OR id =: user2.id
                          LIMIT 2]){
                              if(user1.id == u.id){
                                  user1 = u;
                              }else{
                                  user2 = u;
                              }
                          }
            tmpItemGroup = new List<ASI_MFM_Item_Group__c>();
            tmpSKUList = new List<ASI_MFM_SKU_Code__c>();
            listFixRoute = new List<ASI_CRM_Fix_Approval_Route__c>();
            System.runAs(user1){
                createSKUs();
                createApprovalRoute();
            }
        }
        
        private void createSKUs() {
            tmpItemGroup.add(new ASI_MFM_Item_Group__c(RecordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Item_Group__cASI_CRM_CN_CRM_Item_Group')
                                                       , Name = 'TestItemGroup'
                                                       , ASI_MFM_Item_Group_Code__c = 'TestItemGroupCode'
                                                       , ASI_CRM_CN_Eng_Name__c = 'TestItemGroup'
                                                      ));
            insert tmpItemGroup;
            
            List<ASI_CRM_Product_Warehouse_Photo__c> tmpPhotoList = new List<ASI_CRM_Product_Warehouse_Photo__c>();
            
            ASI_CRM_Product_Warehouse_Photo__c tmpPhoto = new ASI_CRM_Product_Warehouse_Photo__c(ASI_CRM_Photo_Category__c = 'Testing'
                                                                                                 , ASI_CRM_Item_Group__c = tmpItemGroup[0].ID
                                                                                                 , ASI_CRM_Photo_Version__c = 0.1
                                                                                                 , RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Product_Warehouse_Photo__cASI_CRM_CN_Product_Warehouse_Photo')
                                                                                                );
            ASI_CRM_Product_Warehouse_Photo__c tmpPhoto2 = new ASI_CRM_Product_Warehouse_Photo__c(ASI_CRM_Photo_Category__c = 'Testing'
                                                                                                  , ASI_CRM_Item_Group__c = tmpItemGroup[0].ID
                                                                                                  , ASI_CRM_Photo_Version__c = 0.2
                                                                                                  , RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Product_Warehouse_Photo__cASI_CRM_CN_Product_Warehouse_Photo')
                                                                                                 );
            tmpPhotoList.add(tmpPhoto);
            tmpPhotoList.add(tmpPhoto2);
            
            Insert tmpPhotoList;
            
            
            ASI_MFM_SKU_Code__c tmpSku = new ASI_MFM_SKU_Code__c(ASI_MFM_Item_Group__c = tmpItemGroup[0].id 
                                                                 , name = 'testSkue', ASI_MFM_SKU_Code__c = 'aa'
                                                                 , recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_SKU_Code__cASI_FOC_CN_SKU')
                                                                 , ASI_CRM_Location_Owner_JDE__c = 'Testing 721');
            
            ASI_MFM_SKU_Code__c tmpSku1 = new ASI_MFM_SKU_Code__c(ASI_MFM_Item_Group__c = tmpItemGroup[0].id 
                                                                  , name = 'testSkue', ASI_MFM_SKU_Code__c = 'aa'
                                                                  , recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_SKU_Code__cASI_FOC_CN_SKU')
                                                                  , ASI_CRM_Location_Owner_JDE__c = 'Testing 721');
            
            ASI_MFM_SKU_Code__c tmpSku2 = new ASI_MFM_SKU_Code__c(ASI_MFM_Item_Group__c = tmpItemGroup[0].id 
                                                                  , name = 'testSkue', ASI_MFM_SKU_Code__c = 'aa'
                                                                  , recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_SKU_Code__cASI_FOC_CN_POSM_SKU')
                                                                  , ASI_CRM_Location_Owner_JDE__c = 'Testing 721');
            
            tmpSKUList.add(tmpSku);
            tmpSKUList.add(tmpSku1);
            tmpSKUList.add(tmpSku2);
            
            insert tmpSKUList;
        }
        
        private void createApprovalRoute() {
            Id currentUserId = UserInfo.getUserId();
            listFixRoute.add(new ASI_CRM_Fix_Approval_Route__c(RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Fix_Approval_Route__cASI_CRM_CN_Fix_Approval_Route'), ASI_CRM_CN_Approver_1__c=user2.Id, ASI_CRM_CN_Approver_2__c=currentUserId, ASI_CRM_CN_Approver_3__c=currentUserId, ASI_CRM_CN_Approver_4__c=currentUserId, ASI_CRM_CN_Approver_5__c=currentUserId, ASI_CRM_CN_Approver_6__c=currentUserId, ASI_CRM_CN_Type__c='Repack Request Form'));
            
            insert listFixRoute;
        }
        
    }
    
    static testMethod void Test_Trigger(){
        TestObj testObj = new TestObj();
        
        User User1 = testObj.user1;
        User user2 = testObj.user2;
        
        ASI_MFM_SKU_Code__c beforeSKU = testObj.tmpSKUList[0];
        ASI_MFM_SKU_Code__c afterSKU = testObj.tmpSKUList[1];
        ASI_MFM_SKU_Code__c materialSKU = testObj.tmpSKUList[2];
        
        
        System.runAs(user1){
            Test.startTest();
            
            //auto-approve
            //auto-reject
            //auto-cancel
            
            List<ASI_MFM_POSM_Return_Request__c> oLTHeader = new List<ASI_MFM_POSM_Return_Request__c>();
            Id strRTId = Global_RecordTypeCache.getRtId('ASI_MFM_POSM_Return_Request__cASI_MFM_CN_Repack_Request_Form');
            
            oLTHeader.add(new ASI_MFM_POSM_Return_Request__c(
                recordtypeid = strRTId
                , ASI_MFM_Request_Status__c = 'Open'
                //, ASI_MFM_Sales_Channel__c = ''
                , ASI_MFM_Is_Vintage_Changed__c = 'Yes'
                , ASI_MFM_Is_Carton_Spec_Changed__c = 'Yes'
                //, ASI_MFM_New_Code_After_Vintage_Change__c = 
                //, ASI_MFM_Repack_Deadline__c = 
                //, ASI_MFM_Repack_Material_Source__c = 
                // , ASI_MFM_Repack_Manpower_Fee_Charge_To__c = 
                // , ASI_MFM_Repack_Charge_Other_Remark__c = 
                // , ASI_MFM_Repack_Type_and_Frequency__c = 
                // , ASI_MFM_Repack_BT_Set_Quantity__c = 
                // , ASI_MFM_Repack_Carton_Quantity__c = 
                , ASI_MFM_Item_Code_Before_Repack__c = beforeSKU.Id
                , ASI_MFM_Item_Code_After_Repack__c = afterSKU.Id
                //, ASI_MFM_Repack_Material_Item_Code__c = materialSKU.Id
            ));
            
            oLTHeader.add(new ASI_MFM_POSM_Return_Request__c(
                recordtypeid = strRTId
                , ASI_MFM_Request_Status__c = 'Open'
                //, ASI_MFM_Sales_Channel__c = ''
                , ASI_MFM_Is_Vintage_Changed__c = 'Yes'
                , ASI_MFM_Is_Carton_Spec_Changed__c = 'Yes'
                //, ASI_MFM_New_Code_After_Vintage_Change__c = 
                //, ASI_MFM_Repack_Deadline__c = 
                //, ASI_MFM_Repack_Material_Source__c = 
                // , ASI_MFM_Repack_Manpower_Fee_Charge_To__c = 
                // , ASI_MFM_Repack_Charge_Other_Remark__c = 
                // , ASI_MFM_Repack_Type_and_Frequency__c = 
                // , ASI_MFM_Repack_BT_Set_Quantity__c = 
                // , ASI_MFM_Repack_Carton_Quantity__c = 
                , ASI_MFM_Item_Code_Before_Repack__c = beforeSKU.Id
                , ASI_MFM_Item_Code_After_Repack__c = afterSKU.Id
                //, ASI_MFM_Repack_Material_Item_Code__c = materialSKU.Id
            ));
            
            insert oLTHeader;
            
            oLTHeader[0].ASI_MFM_Is_Vintage_Changed__c = 'No';
            update oLTHeader;
            
            Test.stopTest();
        }
    }
}