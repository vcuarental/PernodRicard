@isTest
private class ASI_MFM_CN_POSM_ReturnRequest_Test {

    public class TestObj {

        public List<User> lstUsr;
        public User user1;
        public User user2;
        
        public ASI_MFM_Brand__c brand;
        public list<ASI_MFM_Sub_brand__c> subBrands;
        public List<ASI_HK_CRM_Product_Category__c> ProductCategoryList;
        public List<ASI_TH_CRM_Sub_category__c> SubCategoryList;
        public List<ASI_MFM_Item_Group__c> tmpLTItemGroup;
        
        public ASI_MFM_POSM_Return_Request__c tmpReturnRequest;
        public List<ASI_MFM_POSM_Return_Request_Item__c> tmpLtRequestItem;
        public List<ASI_MFM_SKU_Code__c> tmpLTSKU;
        
        public ASI_MFM_POSM_Return_Request__c tmpReturnRequestNoLine;
        public ASI_MFM_POSM_Return_Request__c tmpReturnRequestWLine;
        
        public TestObj(){
			lstUsr = new List<User>();
            User1 = new User(managerid = UserInfo.getUserId(), ASI_MFM_Team__c = 'ABCD', ASI_MFM_Country__c ='CN', alias = 'test99',BypassVR__c = true, BypassWF__c  = true, BypassTriggers__c  = 'Autofollow_User_InsertUpdate; AutoJoin_User_InsertUpdate; ChatterEmailSettings; ESNProjectTrigger; AP01; ASI_HK_CRM_SalesOrderAssignApprover; ASI_MFM_ValidateSubBrandCode; ASI_MFM_GF_LockPOLine; ASI_CRM_CN_AccountsCRMCodeAutoNumber; ASI_CRM_TW_AccountMovement_TgrHdlr; ASI_CRM_CN_AccountsAdditional_TriggerCls; ASI_CRM_CN_ContractPONoAutoNumber; ASI_CRM_CN_GenPhPayeeLnItmNo_TgrHdlr; ASI_CRM_CN_Contract_TriggerClass; ASI_MFM_TR_ByPassTrigger; ASI_MFM_KR_Cross_Fiscal_Year_Checking; Autofollow_User_InsertUpdate,AutoJoin_Us', ASI_MFM_Bypass_Callouts__c = true, email='test99' + '@dev.com', emailencodingkey='UTF-8', firstname='test99', lastname='Testing', languagelocalekey='en_US', localesidkey='en_US', timezonesidkey='Europe/London', username='test99' + '@pernod-ricard.com',ProfileId = UserInfo.getProfileId(), UserRoleId = UserInfo.getUserRoleId(), isActive=true);
            User2 = new User(managerid = UserInfo.getUserId(), ASI_MFM_Team__c = 'ABCD', ASI_MFM_Country__c ='CN', alias = 'tes99',BypassVR__c = true, BypassWF__c  = true, BypassTriggers__c  = 'Autofollow_User_InsertUpdate; AutoJoin_User_InsertUpdate; ChatterEmailSettings; ESNProjectTrigger; AP01; ASI_HK_CRM_SalesOrderAssignApprover; ASI_MFM_ValidateSubBrandCode; ASI_MFM_GF_LockPOLine; ASI_CRM_CN_AccountsCRMCodeAutoNumber; ASI_CRM_TW_AccountMovement_TgrHdlr; ASI_CRM_CN_AccountsAdditional_TriggerCls; ASI_CRM_CN_ContractPONoAutoNumber; ASI_CRM_CN_GenPhPayeeLnItmNo_TgrHdlr; ASI_CRM_CN_Contract_TriggerClass; ASI_MFM_TR_ByPassTrigger; ASI_MFM_KR_Cross_Fiscal_Year_Checking; Autofollow_User_InsertUpdate,AutoJoin_Us',ASI_MFM_Bypass_Callouts__c = true, email='tes99' + '@dev.com', emailencodingkey='UTF-8', firstname='tes99', lastname='Testing', languagelocalekey='en_US', localesidkey='en_US', timezonesidkey='Europe/London', username='tes99' + '@pernod-ricard.com',ProfileId = UserInfo.getProfileId(), UserRoleId = UserInfo.getUserRoleId(), isActive=true);
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
            System.runAs(user1){
                tmpLTItemGroup = createItemGroup();
                createPOSMReturnRequest();
            }
        }
        
        private List<ASI_MFM_Item_Group__c> createItemGroup() {
            List<ASI_MFM_Item_Group__c> itemGroupList = new List<ASI_MFM_Item_Group__c>();
            
            //create brand
            Id strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_Brand__c','ASI_MFM_CN_Brand');
            brand = new ASI_MFM_Brand__c(name='brandname',Recordtypeid=strRTId);
            insert brand; 
            
            subBrands = new list<ASI_MFM_Sub_brand__c>();
            //create sub brand
            strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_Sub_brand__c','ASI_FOC_CN_Sub_brand');
            subBrands.add(new ASI_MFM_Sub_brand__c(Name='subBrand1' ,recordTypeId=strRTId,ASI_MFM_Active_for_POSM__c=true));
            subBrands.add(new ASI_MFM_Sub_brand__c(Name='subBrand2' ,recordTypeId=strRTId,ASI_MFM_Active_for_POSM__c=true));
            subBrands.add(new ASI_MFM_Sub_brand__c(Name='testSb',recordtypeid=strRTId,ASI_MFM_Brand__c=brand.id,ASI_MFM_Active_for_POSM__c=true));
            insert subBrands;
            
            strRTId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Product_Category__cASI_MFM_CN_Category_Master');
            ProductCategoryList= new List<ASI_HK_CRM_Product_Category__c> ();                                                                                            
            ProductCategoryList.add(new ASI_HK_CRM_Product_Category__c(RecordTypeId=strRTId,ASI_MFM_Level__c='Level 1',Name='Display 陈列',ASI_MFM_Running_Number__c=1,ASI_HK_CRM_Category_Code__c='11',ASI_CRM_CN_Chinese_Name__c='Category',ASI_HK_CRM_English_Name__c='Category',ASI_HK_CRM_Sequence__c=1));
            ProductCategoryList.add(new ASI_HK_CRM_Product_Category__c(RecordTypeId=strRTId,ASI_MFM_Level__c='Level 2',Name='BAG 包',ASI_MFM_Running_Number__c=2,ASI_HK_CRM_Category_Code__c='22',ASI_CRM_CN_Chinese_Name__c='Category2',ASI_HK_CRM_English_Name__c='Category',ASI_HK_CRM_Sequence__c=2));
            ProductCategoryList.add(new ASI_HK_CRM_Product_Category__c(RecordTypeId=strRTId,ASI_MFM_Level__c='Level 3',Name='LEATHER 皮质',ASI_MFM_Running_Number__c=3,ASI_HK_CRM_Category_Code__c='33',ASI_CRM_CN_Chinese_Name__c='Category1',ASI_HK_CRM_English_Name__c='Category',ASI_HK_CRM_Sequence__c=3));
            insert ProductCategoryList;
            
            SubCategoryList = new List<ASI_TH_CRM_Sub_category__c>(); 
            strRTId = Global_recordTypeCache.getRtId('ASI_TH_CRM_Sub_category__cASI_MFM_CN_POSM_Sub_Cetagory_Master');
            SubCategoryList.add(new ASI_TH_CRM_Sub_category__c(RecordTypeId=strRTId,ASI_MFM_Category_Level_2_3__c=ProductCategoryList[1].id,ASI_CRM_CN_Product_Category__c=ProductCategoryList[0].id));
            SubCategoryList.add(new ASI_TH_CRM_Sub_category__c(RecordTypeId=strRTId,ASI_MFM_Category_Level_2_3__c=ProductCategoryList[2].id,ASI_CRM_CN_Product_Category__c=ProductCategoryList[0].id));
            insert SubCategoryList;
            
            strRTId = Global_recordTypeCache.getRtId('ASI_MFM_Item_Group__cASI_MFM_CN_POSM_Item_Group');
            //[0]
            itemGroupList.add(
                				new ASI_MFM_Item_Group__c(name='System autoupdate, do not change.',ASI_MFM_Bundle_Item_Group__c=false,
                                                          ASI_MFM_Utilization_Status__c ='Active'
                                                          ,ASI_MFM_Sub_brand__c=subBrands[0].id,ASI_MFM_Inspection__c='抽查',ASI_MFM_Unit__c='ml'
                                                          ,ASI_MFM_Safety_Instruction__c='易碎',ASI_MFM_Period_of_Validity__c='2 - 4 Months'
                                                          ,ASI_CRM_CN_Eng_Name__c='eng',ASI_CRM_CN_Chinese_Name__c='chi',ASI_MFM_Campaign_Name__c=''
                                                          ,ASI_CRM_CN_Pack_Value__c=24,ASI_MFM_Importation__c='import '
                                                          ,ASI_MFM_Category_Level_1__c=ProductCategoryList[0].id
                                                          ,ASI_MFM_Category_Level_2__c=ProductCategoryList[1].id
                                                          ,ASI_MFM_Category_Level_3__c=ProductCategoryList[2].id
                                                          ,ASI_MFM_Category_Level_1_Piclklist__c='Display 陈列'
                                                          ,ASI_MFM_Category_Level_2_Piclklist__c='BAG 包' 
                                                          ,ASI_MFM_Category_Level_3_Piclklist__c='LEATHER 皮质'
                                                          ,ASI_MFM_CN_OneTimeItem__c='Yes'
                                                          ,RecordTypeId=strRTId)
                             );
            //[1]
            itemGroupList.add(
                				new ASI_MFM_Item_Group__c(name='System autoupdate, do not change.',ASI_MFM_Bundle_Item_Group__c=false,
                                                          ASI_MFM_Utilization_Status__c ='Active'
                                                          ,ASI_MFM_Sub_brand__c=subBrands[0].id,ASI_MFM_Inspection__c='抽查',ASI_MFM_Unit__c='ml'
                                                          ,ASI_MFM_Safety_Instruction__c='易碎',ASI_MFM_Period_of_Validity__c='2 - 4 Months'
                                                          ,ASI_CRM_CN_Eng_Name__c='eng',ASI_CRM_CN_Chinese_Name__c='chi',ASI_MFM_Campaign_Name__c=''
                                                          ,ASI_CRM_CN_Pack_Value__c=24,ASI_MFM_Importation__c='import '
                                                          ,ASI_MFM_Category_Level_1__c=ProductCategoryList[0].id
                                                          ,ASI_MFM_Category_Level_2__c=ProductCategoryList[1].id
                                                          ,ASI_MFM_Category_Level_3__c=ProductCategoryList[2].id
                                                          ,ASI_MFM_Category_Level_1_Piclklist__c='Display 陈列'
                                                          ,ASI_MFM_Category_Level_2_Piclklist__c='BAG 包' 
                                                          ,ASI_MFM_Category_Level_3_Piclklist__c='LEATHER 皮质'
                                                          ,ASI_MFM_CN_OneTimeItem__c='Yes'
                                                          ,RecordTypeId=strRTId)
                             );
            //[2]
            itemGroupList.add(
                				new ASI_MFM_Item_Group__c(name='System autoupdate, do not change.',ASI_MFM_Bundle_Item_Group__c=false,
                                                          ASI_MFM_Utilization_Status__c ='Active'
                                                          ,ASI_MFM_Sub_brand__c=subBrands[0].id,ASI_MFM_Inspection__c='抽查',ASI_MFM_Unit__c='ml'
                                                          ,ASI_MFM_Safety_Instruction__c='易碎',ASI_MFM_Period_of_Validity__c='2 - 4 Months'
                                                          ,ASI_CRM_CN_Eng_Name__c='eng',ASI_CRM_CN_Chinese_Name__c='chi',ASI_MFM_Campaign_Name__c=''
                                                          ,ASI_CRM_CN_Pack_Value__c=24,ASI_MFM_Importation__c='import '
                                                          ,ASI_MFM_Category_Level_1__c=ProductCategoryList[0].id
                                                          ,ASI_MFM_Category_Level_2__c=ProductCategoryList[1].id
                                                          ,ASI_MFM_Category_Level_3__c=ProductCategoryList[2].id
                                                          ,ASI_MFM_Category_Level_1_Piclklist__c='Display 陈列'
                                                          ,ASI_MFM_Category_Level_2_Piclklist__c='BAG 包' 
                                                          ,ASI_MFM_Category_Level_3_Piclklist__c='LEATHER 皮质'
                                                          ,ASI_MFM_CN_OneTimeItem__c='Yes'
                                                          ,RecordTypeId=strRTId)
                             );
            //[3]
            itemGroupList.add(
                				new ASI_MFM_Item_Group__c(name='System autoupdate, do not change.',ASI_MFM_Bundle_Item_Group__c=false,
                                                          ASI_MFM_Utilization_Status__c ='Active'
                                                          ,ASI_MFM_Sub_brand__c=subBrands[0].id,ASI_MFM_Inspection__c='抽查',ASI_MFM_Unit__c='ml'
                                                          ,ASI_MFM_Safety_Instruction__c='易碎',ASI_MFM_Period_of_Validity__c='2 - 4 Months'
                                                          ,ASI_CRM_CN_Eng_Name__c='eng',ASI_CRM_CN_Chinese_Name__c='chi',ASI_MFM_Campaign_Name__c=''
                                                          ,ASI_CRM_CN_Pack_Value__c=24,ASI_MFM_Importation__c='import '
                                                          ,ASI_MFM_Category_Level_1__c=ProductCategoryList[0].id
                                                          ,ASI_MFM_Category_Level_2__c=ProductCategoryList[1].id
                                                          ,ASI_MFM_Category_Level_3__c=ProductCategoryList[2].id
                                                          ,ASI_MFM_Category_Level_1_Piclklist__c='Display 陈列'
                                                          ,ASI_MFM_Category_Level_2_Piclklist__c='BAG 包' 
                                                          ,ASI_MFM_Category_Level_3_Piclklist__c='LEATHER 皮质'
                                                          ,ASI_MFM_CN_OneTimeItem__c='Yes'
                                                          ,RecordTypeId=strRTId)
                             );
            //[4]
            itemGroupList.add(
                				new ASI_MFM_Item_Group__c(name='System autoupdate, do not change.',ASI_MFM_Bundle_Item_Group__c=false,
                                                          ASI_MFM_Utilization_Status__c ='Active'
                                                          ,ASI_MFM_Sub_brand__c=subBrands[0].id,ASI_MFM_Inspection__c='抽查',ASI_MFM_Unit__c='ml'
                                                          ,ASI_MFM_Safety_Instruction__c='易碎',ASI_MFM_Period_of_Validity__c='2 - 4 Months'
                                                          ,ASI_CRM_CN_Eng_Name__c='eng',ASI_CRM_CN_Chinese_Name__c='chi',ASI_MFM_Campaign_Name__c=''
                                                          ,ASI_CRM_CN_Pack_Value__c=24,ASI_MFM_Importation__c='import '
                                                          ,ASI_MFM_Category_Level_1__c=ProductCategoryList[0].id
                                                          ,ASI_MFM_Category_Level_2__c=ProductCategoryList[1].id
                                                          ,ASI_MFM_Category_Level_3__c=ProductCategoryList[2].id
                                                          ,ASI_MFM_Category_Level_1_Piclklist__c='Display 陈列'
                                                          ,ASI_MFM_Category_Level_2_Piclklist__c='BAG 包' 
                                                          ,ASI_MFM_Category_Level_3_Piclklist__c='LEATHER 皮质'
                                                          ,ASI_MFM_CN_OneTimeItem__c='Yes'
                                                          ,RecordTypeId=strRTId)
                             );
            //[5]
            itemGroupList.add(
                				new ASI_MFM_Item_Group__c(name='System autoupdate, do not change.',ASI_MFM_Bundle_Item_Group__c=false,
                                                          ASI_MFM_Utilization_Status__c ='Active'
                                                          ,ASI_MFM_Sub_brand__c=subBrands[0].id,ASI_MFM_Inspection__c='抽查',ASI_MFM_Unit__c='ml'
                                                          ,ASI_MFM_Safety_Instruction__c='易碎',ASI_MFM_Period_of_Validity__c='2 - 4 Months'
                                                          ,ASI_CRM_CN_Eng_Name__c='eng',ASI_CRM_CN_Chinese_Name__c='chi',ASI_MFM_Campaign_Name__c=''
                                                          ,ASI_CRM_CN_Pack_Value__c=24,ASI_MFM_Importation__c='import '
                                                          ,ASI_MFM_Category_Level_1__c=ProductCategoryList[0].id
                                                          ,ASI_MFM_Category_Level_2__c=ProductCategoryList[1].id
                                                          ,ASI_MFM_Category_Level_3__c=ProductCategoryList[2].id
                                                          ,ASI_MFM_Category_Level_1_Piclklist__c='Display 陈列'
                                                          ,ASI_MFM_Category_Level_2_Piclklist__c='BAG 包' 
                                                          ,ASI_MFM_Category_Level_3_Piclklist__c='LEATHER 皮质'
                                                          ,ASI_MFM_CN_OneTimeItem__c='Yes'
                                                          ,RecordTypeId=strRTId)
                             );
            
            insert itemGroupList;
            
            itemGroupList[0].ASI_MFM_Status__c = 'Final';
            itemGroupList[1].ASI_MFM_Status__c = 'Final';
            itemGroupList[2].ASI_MFM_Status__c = 'Final';
            itemGroupList[3].ASI_MFM_Status__c = 'Final';
            itemGroupList[4].ASI_MFM_Status__c = 'Final';
            itemGroupList[5].ASI_MFM_Status__c = 'Final';
            update itemGroupList;
            
            itemGroupList[0].ASI_MFM_Item_Group_Code__c = 'TEST_CODE1';
            itemGroupList[1].ASI_MFM_Item_Group_Code__c = 'TEST_CODE1';
            itemGroupList[2].ASI_MFM_Item_Group_Code__c = 'TEST_CODE1';
            itemGroupList[3].ASI_MFM_Item_Group_Code__c = 'TEST_CODE2';
            itemGroupList[4].ASI_MFM_Item_Group_Code__c = 'TEST_CODE2';
            itemGroupList[5].ASI_MFM_Item_Group_Code__c = 'TEST_CODE3';
            update itemGroupList;

            return itemGroupList;
        }
        
        private void createPOSMReturnRequest() {
            List<ASI_CRM_Region__c> tmpRegion = new List<ASI_CRM_Region__c>();
            tmpRegion.add(new ASI_CRM_Region__c(RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Region__cASI_CRM_CN_Region')
                                                    , Name = 'TestRegion'
                                                    , OwnerID = userinfo.getUserId()
                                                ));
            
            insert tmpRegion;
            
            List<ASI_FOC_Warehouse__c> tmpWarehouse = new List<ASI_FOC_Warehouse__c>();
            tmpWarehouse.add(new ASI_FOC_Warehouse__c(RecordTypeId = Global_RecordTypeCache.getRtId('ASI_FOC_Warehouse__cASI_FOC_CN_Warehouse')
                                                      , Name = 'TestWarehouse退货'
                                                      , ASI_FOC_Warehouse_Code__c = 'TestWarehouseCodeRT'
                                                      , ASI_FOC_JDE_Customer_Number__c = 'TestWarehouse'
                                                      , ASI_FOC_Warehouse_Type__c = 'Region Warehouse'
                                                      , ASI_FOC_Region__c = tmpRegion[0].id
                                                      , OwnerID = userinfo.getUserId()
                                                      , ASI_MFM_Return_Request_Email_1__c = 'test@test.com', ASI_MFM_Return_Request_Email_2__c = 'test@test.com', ASI_MFM_Return_Request_Email_3__c = 'test@test.com', ASI_MFM_Return_Request_Email_4__c = 'test@test.com', ASI_MFM_Return_Request_Email_5__c = 'test@test.com'
                                                      , ASI_MFM_Return_Request_Email_6__c = 'test@test.com', ASI_MFM_Return_Request_Email_7__c = 'test@test.com', ASI_MFM_Return_Request_Email_8__c = 'test@test.com', ASI_MFM_Return_Request_Email_9__c = 'test@test.com', ASI_MFM_Return_Request_Email_10__c = 'test@test.com'
                                                      ));
            
            insert tmpWarehouse;
            
            //header
            Id strRTId = Global_RecordTypeCache.getRtId('ASI_MFM_POSM_Return_Request__cASI_MFM_CN_POSM');
            tmpReturnRequest = new ASI_MFM_POSM_Return_Request__c(
                recordtypeid = strRTId,
                ASI_MFM_Request_Status__c = 'Open',
                ASI_MFM_Return_Request_Date__c = Date.today(),
                ASI_MFM_Return_Request_Contact__c = 'Testing'
                , ASI_MFM_To_Warehouse__c = tmpWarehouse[0].id
            );
            insert tmpReturnRequest;
            
            tmpReturnRequestNoLine = new ASI_MFM_POSM_Return_Request__c(
                recordtypeid = strRTId,
                ASI_MFM_Request_Status__c = 'Open',
                ASI_MFM_Return_Request_Date__c = Date.today(),
                ASI_MFM_Return_Request_Contact__c = 'Testing'
                , ASI_MFM_To_Warehouse__c = tmpWarehouse[0].id
            );
            insert tmpReturnRequestNoLine;
            
            tmpReturnRequestWLine = new ASI_MFM_POSM_Return_Request__c(
                recordtypeid = strRTId,
                ASI_MFM_Request_Status__c = 'Open',
                ASI_MFM_Return_Request_Date__c = Date.today(),
                ASI_MFM_Return_Request_Contact__c = 'Testing'
                , ASI_MFM_To_Warehouse__c = tmpWarehouse[0].id
            );
            insert tmpReturnRequestWLine;
            
            //detail
            Integer iSKUNum = 10;
            Integer iItemNum = 3;
            
            ASI_FOC_SKUGenerator oSKUGen = new ASI_FOC_SKUGenerator();
            ASI_MFM_CN_ReturnRequestDetailGenerator oItemGen = new ASI_MFM_CN_ReturnRequestDetailGenerator();
            tmpLTSKU = new List<ASI_MFM_SKU_Code__c>();        
            for (Integer i = 0; i < iSKUNum; i++) {
                tmpLTSKU.add(oSKUGen.generatePOSMSKU(tmpLTItemGroup[0]));
            }
            insert tmpLTSKU;
            
            tmpLtRequestItem = new List<ASI_MFM_POSM_Return_Request_Item__c>();
            strRTId = Global_RecordTypeCache.getRtId('ASI_MFM_POSM_Return_Request_Item__cASI_MFM_CN_POSM_Request_Item');
            tmpLtRequestItem = new List<ASI_MFM_POSM_Return_Request_Item__c>();
            ASI_MFM_POSM_Return_Request_Item__c oItem1 = new ASI_MFM_POSM_Return_Request_Item__c(
                recordtypeid = strRTId,
                ASI_MFM_Request_Order__c = tmpReturnRequest.id
                ,ASI_MFM_Owner__c = user1.id
            );
            tmpLtRequestItem.add(oItem1);
            
            ASI_MFM_POSM_Return_Request_Item__c oItem2 = new ASI_MFM_POSM_Return_Request_Item__c(
                recordtypeid = strRTId,
                ASI_MFM_Request_Order__c = tmpReturnRequest.id
                ,ASI_MFM_Owner__c = user1.id
            );
            tmpLtRequestItem.add(oItem2);
            
            for (Integer i = 0; i < iItemNum; i++) {
                tmpLtRequestItem.add(oItemGen.generateReturnRequestDetail(tmpReturnRequest, tmpLTSKU[i]));
            }
            
            tmpLtRequestItem.add(new ASI_MFM_POSM_Return_Request_Item__c(
                recordtypeid = strRTId,
                ASI_MFM_Request_Order__c = tmpReturnRequestWLine.id
                ,ASI_MFM_Approval_Status__c = ''
            ));
            tmpLtRequestItem.add(new ASI_MFM_POSM_Return_Request_Item__c(
                recordtypeid = strRTId,
                ASI_MFM_Request_Order__c = tmpReturnRequestWLine.id
                ,ASI_MFM_Owner__c = user2.id
                ,ASI_MFM_Approval_Status__c = ''
            ));
            
            insert tmpLtRequestItem;
            
            tmpLtRequestItem[0].ASI_MFM_QTY_Issued__c = 10;
            update tmpLtRequestItem[0];
            
            delete tmpLtRequestItem[1];
        }
        
	}
    
    static testMethod void Test_Trigger(){
        TestObj testObj = new TestObj();
        
        User User1 = testObj.user1;
        User user2 = testObj.user2;
        
        System.runAs(user1){
            Test.startTest();

            //auto-approve
            //auto-reject
            //auto-cancel
            
            List<ASI_MFM_POSM_Return_Request__c> oLTHeader = new List<ASI_MFM_POSM_Return_Request__c>();
            Id strRTId = Global_RecordTypeCache.getRtId('ASI_MFM_POSM_Return_Request__cASI_MFM_CN_POSM');
            Id ORDER_APPROVAL_ID = Global_recordTypeCache.getRtId('ASI_MFM_POSM_Return_Request__cASI_MFM_CN_POSM_Return_Batch_Approval');
            Id ITEM_APPROVAL_ID = Global_recordTypeCache.getRtId('ASI_MFM_POSM_Return_Request_Item__cASI_MFM_CN_POSM_Return_Request_Item_Batch_Approval');

            ASI_MFM_POSM_Return_Request__c prrHeader = new ASI_MFM_POSM_Return_Request__c(
                recordtypeid =  ORDER_APPROVAL_ID,
                ASI_MFM_Return_Request_Date__c = Date.today(),
                ASI_MFM_Return_Request_Contact__c = 'Testing 0 Cancel',
                ASI_MFM_Request_Status__c = 'Open'
            ); 
            insert prrHeader;

            oLTHeader.add(new ASI_MFM_POSM_Return_Request__c(
                recordtypeid = strRTId,
                ASI_MFM_Request_Status__c = 'Open',
                ASI_MFM_Return_Request_Date__c = Date.today(),
                ASI_MFM_Return_Request_Contact__c = 'Testing 1 Approve'
            ));
            oLTHeader.add(new ASI_MFM_POSM_Return_Request__c(
                recordtypeid = strRTId,
                ASI_MFM_Request_Status__c = 'Open',
                ASI_MFM_Return_Request_Date__c = Date.today(),
                ASI_MFM_Return_Request_Contact__c = 'Testing 2 Reject'
            ));

            oLTHeader.add(new ASI_MFM_POSM_Return_Request__c(
                recordtypeid = strRTId,
                ASI_MFM_Request_Status__c = 'Open',
                ASI_MFM_Return_Request_Date__c = Date.today(),
                ASI_MFM_Return_Request_Contact__c = 'Testing 3 Reject'
            ));
            ASI_MFM_POSM_Return_Request__c prr = new ASI_MFM_POSM_Return_Request__c(
                recordtypeid =  strRTId,
                ASI_MFM_Return_Request_Date__c = Date.today(),
                ASI_MFM_Return_Request_Contact__c = 'Testing 4 Cancel',
                ASI_MFM_Request_Status__c = 'Open'
            ); 
            oLTHeader.add(prr);

            insert oLTHeader;
            
            
            ASI_MFM_POSM_Return_Request_Item__c prrItemHeader = new ASI_MFM_POSM_Return_Request_Item__c(
                recordtypeid =  ITEM_APPROVAL_ID,
                ASI_MFM_Request_Order__c = prrHeader.Id,
                ASI_MFM_Owner__c = user2.id,
                ASI_MFM_Approval_Status__c = 'Open',
                ASI_POSM_Return_Request_Approval_Header__c = prrHeader.Id
            );
            insert prrItemHeader;

            strRTId = Global_RecordTypeCache.getRtId('ASI_MFM_POSM_Return_Request_Item__cASI_MFM_CN_POSM_Request_Item');
            List<ASI_MFM_POSM_Return_Request_Item__c> oLTLItem = new List<ASI_MFM_POSM_Return_Request_Item__c>();
            oLTLItem.add(new ASI_MFM_POSM_Return_Request_Item__c(
                recordtypeid = strRTId,
                ASI_MFM_Request_Order__c = oLTHeader[0].id
                ,ASI_MFM_Owner__c = user2.id
            ));
            oLTLItem.add(new ASI_MFM_POSM_Return_Request_Item__c(
                recordtypeid = strRTId,
                ASI_MFM_Request_Order__c = oLTHeader[1].id
                ,ASI_MFM_Owner__c = user2.id
            ));
            oLTLItem.add(new ASI_MFM_POSM_Return_Request_Item__c(
                recordtypeid = strRTId,
                ASI_MFM_Request_Order__c = oLTHeader[2].id
                ,ASI_MFM_Owner__c = user2.id
                
            ));

            ASI_MFM_POSM_Return_Request_Item__c item = new ASI_MFM_POSM_Return_Request_Item__c(
                recordtypeid =  strRTId,
                ASI_MFM_Request_Order__c = prr.Id,
                ASI_MFM_Owner__c = user2.id,
                ASI_MFM_Approval_Status__c = 'Open',
                ASI_MFM_POSM_Return_Reques_Approval_Item__c = prrItemHeader.Id
            );
            oLTLItem.add(item);
            insert oLTLItem;

            prrItemHeader.ASI_MFM_Approval_Status__c = 'Approved';
            update prrItemHeader;
            prrItemHeader.ASI_MFM_Approval_Status__c = 'Rejected';
            update prrItemHeader;

            prrHeader.ASI_MFM_Request_Status__c = 'In Progress';
            update prrHeader;
            prrHeader.ASI_MFM_Request_Status__c = 'Approved';
            update prrHeader;
            prrHeader.ASI_MFM_Request_Status__c = 'Rejected';
            update prrHeader;

                        
            oLTLItem[0].ASI_MFM_Approval_Status__c = 'Approved';
            oLTLItem[1].ASI_MFM_Approval_Status__c = 'Rejected';
            oLTLItem[2].ASI_MFM_Approval_Status__c = 'Canceled';
            update oLTLItem;
            
            oLTHeader[0].ASI_MFM_Request_Status__c = 'In Progress';
            oLTHeader[1].ASI_MFM_Request_Status__c = 'In Progress';
            oLTHeader[2].ASI_MFM_Request_Status__c = 'In Progress';
            try{update oLTHeader;}catch(Exception e){}
            
            
        	Test.stopTest();
        }
    }
    
    static testMethod void Test_SubmitCON(){
        TestObj testObj = new TestObj();
        
        User User1 = testObj.user1;
        System.runAs(user1){
            Test.startTest();
            
            //header approval
            ASI_MFM_POSM_Return_Request__c oHeader = testObj.tmpReturnRequest;
            apexpages.Standardcontroller sc = new apexpages.Standardcontroller(oHeader);
            ASI_MFM_CN_SubmitReturnRequestController cx = new ASI_MFM_CN_SubmitReturnRequestController(sc);
            cx.goBack();
            cx.submitRequest();
            
            ASI_MFM_POSM_Return_Request__c oHeaderNoLine = testObj.tmpReturnRequestNoLine;
            sc = new apexpages.Standardcontroller(oHeaderNoLine);
            cx = new ASI_MFM_CN_SubmitReturnRequestController(sc);
            cx.goBack();
            PageReference oPage = cx.confirm();
            
            oHeaderNoLine.ASI_MFM_Request_Status__c = 'Approved';
            try{update oHeaderNoLine;}catch(Exception e){}
            cx.submitRequest();
            
            //line approval
            //auto line approval
            ASI_MFM_POSM_Return_Request__c oHeaderWLine = testObj.tmpReturnRequestWLine;
            sc = new apexpages.Standardcontroller(oHeaderWLine);
            cx = new ASI_MFM_CN_SubmitReturnRequestController(sc);
            cx.goBack();
            cx.submitRequest();
            
            
            
            Test.stopTest();
        }
    }    
    
    static testMethod void Test_Redirect(){
        TestObj testObj = new TestObj();
        
        User User1 = testObj.user1;
        System.runAs(user1){
            Test.startTest();
            
            ASI_MFM_POSM_Return_Request__c oHeader = testObj.tmpReturnRequest;

            apexpages.Standardcontroller sc = new apexpages.Standardcontroller(oHeader);
            ASI_MFM_CN_POSM_ReturnRequest_NewPageCls cx = new ASI_MFM_CN_POSM_ReturnRequest_NewPageCls(sc);
            PageReference oPage = cx.redirect();
            
            Test.stopTest();
        }
    }
    
    static testMethod void Test_ApprovalEmailPDFCON(){
        TestObj testObj = new TestObj();
        
        User User1 = testObj.user1;
        System.runAs(user1){
            Test.startTest();
            
            ASI_MFM_POSM_Return_Request__c oHeader = testObj.tmpReturnRequest;
            
            ASI_MFM_CN_POSM_ApprovalEmailPDFCON ApprovalEmailPDFCON = new ASI_MFM_CN_POSM_ApprovalEmailPDFCON();
            ApprovalEmailPDFCON.currentHeaderID = oHeader.ID;
            
            Boolean initTest = ApprovalEmailPDFCON.init();
            
            Test.stopTest();
        }
    }
    
    static testMethod void Test_ItemDetailEditCON()
    {
        TestObj testObj = new TestObj();
        
        User User1 = testObj.user1;
        System.runAs(user1){
            ASI_MFM_POSM_Return_Request__c oHeader = testObj.tmpReturnRequest;
            List<ASI_MFM_POSM_Return_Request_Item__c> oLTItem = testObj.tmpLtRequestItem;
            List<ASI_MFM_SKU_Code__c> oLTSKU = testObj.tmpLTSKU;
            
            ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(oLTItem);
            
            Test.startTest();
            
            PageReference testPage = Page.ASI_MFM_CN_ReturnItemsDetailEditPage;
            Map<String, String> pageParams = testPage.getParameters();
            pageParams.put('id', oHeader.Id);
            Test.setCurrentPageReference(testPage);
            ASI_MFM_CN_ReturnItemsDetailEditCON testCon = new ASI_MFM_CN_ReturnItemsDetailEditCON(stdSetController);
            ASI_FOC_MassCreateAndUpdateController mcauCon = new ASI_FOC_MassCreateAndUpdateController();
            ASI_FOC_SFObjSelectTableController sobjstCon = new ASI_FOC_SFObjSelectTableController();
            
            // Assign component attributes
            mcauCon.isFastModeBool = false;
            mcauCon.sObjTypeStr = 'ASI_MFM_POSM_Return_Request_Item__c';
            mcauCon.displayFieldsStr = 'ASI_MFM_SKU__c&read=A, ASI_MFM_SKU_Description_Text__c&read=A, ASI_MFM_SKU_Chinese_Description_Text__c&read=A,ASI_MFM_Packing_Description_Text__c&read=A, ASI_MFM_QTY_Issued__c&req=T';
            mcauCon.fieldToURLParamStr = 'ASI_MFM_Request_Order__c=>id';
            mcauCon.whereStatm = 'ASI_MFM_Approval_Status__c != \'Rejected\' and ASI_MFM_Approval_Status__c != \'Cancelled\' and ASI_MFM_Request_Order__c = \'' + oHeader.Id + '\'';
            mcauCon.orderByStr = 'Name';
            mcauCon.pageBlockTitleStr = 'POSM Return Request Items';
            mcauCon.successLinkStr = '/' + oHeader.Id;
            mcauCon.cancelLinkStr = '/' + oHeader.Id;
            mcauCon.modeStr = 'BOTH';
            mcauCon.isDefaultEditVal = true;
            mcauCon.isShowAllRT = true;
            mcauCon.isUseFirstRowForNew = false;
            mcauCon.myComponentKey = 'massCreateAndUpdate';
            mcauCon.myPageController = testCon.thisController;
            mcauCon.includeRecordTypesStr  = 'ASI_MFM_CN_POSM_Request_Item';
            
            sobjstCon.sObjTypeStr = 'ASI_MFM_SKU_Code__c';
            sobjstCon.displayFieldsStr = 'Name, ASI_MFM_SKU_Description__c, ASI_MFM_Sub_brand__c, ASI_FOC_SKU_Chinese_Description__c,ASI_FOC_Packing_Description__c, ASI_FOC_Location_Item_Owner__c';
            sobjstCon.defWhereStatmStr = testCon.baseWhereStatm;
            sobjstCon.orderByStr = 'ASI_MFM_SKU_Description__c';
            sobjstCon.numOfRowInTable = 8;
            sobjstCon.myComponentKey = 'selectTable';
            sobjstCon.myPageController = testCon.thisController;
            
            Boolean initPageBool = mcauCon.dummyVar;
            initPageBool = sobjstCon.initDummyVar;
            
            // Start testing user actions
            
            // Change page number
            sobjstCon.nextPage();
            sobjstCon.lastPage();
            sobjstCon.prevPage();
            sobjstCon.firstPage();
            
            // Clone product
            pageParams.put(mcauCon.PARAM_RTID, ASI_MFM_CN_ReturnRequestDetailGenerator.RT_Default);
            pageParams.put(mcauCon.PARAM_TRID, mcauCon.theRecordTypeElementList.get(0).myRecordList.get(0).id);
            mcauCon.cloneRow();
            
            // Dummy test of enableForEdit
            pageParams.put(mcauCon.PARAM_RTID, ASI_MFM_CN_ReturnRequestDetailGenerator.RT_Default);
            List<ASI_FOC_MassCreateAndUpdateController.TableRow> recordList = mcauCon.theRecordTypeElementList.get(0).myRecordList;
            pageParams.put(mcauCon.PARAM_TRID, recordList.get(recordList.size() - 1).id);
            mcauCon.enableForEdit();
            
            // Remove cloned product
            pageParams.put(mcauCon.PARAM_RTID, ASI_MFM_CN_ReturnRequestDetailGenerator.RT_Default);
            recordList = mcauCon.theRecordTypeElementList.get(0).myRecordList;
            pageParams.put(mcauCon.PARAM_TRID, recordList.get(recordList.size() - 1).id);
            mcauCon.removeNew();
            
            // Filter products
            testCon.filterName = oLTSKU[2].Name;
            testCon.filterSKU();
            //System.assertEquals(1, sobjstCon.tableEleList.size());
            
            // Add product
            pageParams.put('PARAM_BTN_ID', 'add');
            pageParams.put('PARAM_SOBJ_ID', sobjstCon.tableEleList.get(0).sObj.Id);
            sobjstCon.triggerRowAction();
            
            // Remove old product
            pageParams.put(mcauCon.PARAM_RTID, ASI_MFM_CN_ReturnRequestDetailGenerator.RT_Default);
            pageParams.put(mcauCon.PARAM_TRID, mcauCon.theRecordTypeElementList.get(0).myRecordList.get(0).id);
            mcauCon.deleteOld();
            
            // Remove new product
            pageParams.put(mcauCon.PARAM_RTID, ASI_MFM_CN_ReturnRequestDetailGenerator.RT_Default);
            recordList = mcauCon.theRecordTypeElementList.get(0).myRecordList;
            pageParams.put(mcauCon.PARAM_TRID, recordList.get(recordList.size() - 1).id);
            mcauCon.removeNew();
            
            // Dummy test of addMoreBlankRows
            mcauCon.addMoreBlankRows();
            
            // Add product
            pageParams.put('PARAM_BTN_ID', 'add');
            pageParams.put('PARAM_SOBJ_ID', sobjstCon.tableEleList.get(0).sObj.Id);
            sobjstCon.triggerRowAction();
            
            // Set values
            mcauCon.theRecordTypeElementList.get(0).myRecordList.get(0).mySObj.put('ASI_MFM_QTY_Issued__c', 5);
            
            // Save
            mcauCon.commitAll();
            mcauCon.cancelPage();
            
            //for ASI_MFM_CN_ReturnItemsDetailEditCON
            testCon.sobjst_triggerActionForSObject(sobjstCon, ASI_FOC_SFObjSelectTableController.DEF_BTN_KEY_ADD, oLTSKU[0]);
            testCon.mcau_triggerActionForSObject(mcauCon, ASI_FOC_MassCreateAndUpdateController.ACTION_REMOVE_NEW, oLTItem[0]);
            PageReference oTmpPageRef = testCon.mcau_triggerPageBlockAction(mcauCon, null);
            
            //for ASI_FOC_MassCreateAndUpdateController
            string sTmpAction = ASI_FOC_MassCreateAndUpdateController.ACTION_EDIT;
            sTmpAction = ASI_FOC_MassCreateAndUpdateController.ACTION_CLONE;
            sTmpAction = ASI_FOC_MassCreateAndUpdateController.ACTION_ADD_NEW;
            sTmpAction = ASI_FOC_MassCreateAndUpdateController.ACTION_REMOVE_NEW;
            sTmpAction = ASI_FOC_MassCreateAndUpdateController.ACTION_DELETE_OLD;
            sTmpAction = ASI_FOC_MassCreateAndUpdateController.RTNAME_MASTER;
    		sTmpAction = ASI_FOC_MassCreateAndUpdateController.RTDEVNAME_MASTER;
            sTmpAction = mcauCon.MODE_NEW;

            List<ASI_FOC_MassCreateAndUpdateController.TableRow> oLTRow = mcauCon.theRecordTypeElementList.get(0).myDisplayRecordList;
            
            mcauCon.refresh();
            oTmpPageRef = mcauCon.triggerPageBlockAction();
            oTmpPageRef = mcauCon.addNewRow();
            
            ASI_FOC_MassCreateAndUpdateController.PageBlockActionBtn oBtn = new ASI_FOC_MassCreateAndUpdateController.PageBlockActionBtn('test_id','test_label');
            ASI_FOC_MassCreateAndUpdateController.DisplayField oDisField = new ASI_FOC_MassCreateAndUpdateController.DisplayField('test_label','test_name');
            oDisField.colKey = 'id';
            
            mcauCon.clearAll();            
            
			Test.stopTest();
        }
    }
    
    static testMethod void Test_MassCreateUpdateCON()
    {
        TestObj testObj = new TestObj();
        
        User User1 = testObj.user1;
        System.runAs(user1){
            ASI_MFM_POSM_Return_Request__c oHeader = testObj.tmpReturnRequest;
            List<ASI_MFM_POSM_Return_Request_Item__c> oLTItem = testObj.tmpLtRequestItem;
            List<ASI_MFM_SKU_Code__c> oLTSKU = testObj.tmpLTSKU;
            
            ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(oLTItem);
            
            Test.startTest();
            
            PageReference testPage = Page.ASI_MFM_CN_ReturnItemsDetailEditPage;
            Map<String, String> pageParams = testPage.getParameters();
            pageParams.put('id', oHeader.Id);
            pageParams.put('clone', '1');
            Test.setCurrentPageReference(testPage);
            ASI_MFM_CN_ReturnItemsDetailEditCON testCon = new ASI_MFM_CN_ReturnItemsDetailEditCON(stdSetController);
            ASI_FOC_MassCreateAndUpdateController mcauCon = new ASI_FOC_MassCreateAndUpdateController();
            ASI_FOC_SFObjSelectTableController sobjstCon = new ASI_FOC_SFObjSelectTableController();
            
            // Assign component attributes
            mcauCon.isFastModeBool = false;
            mcauCon.sObjTypeStr = 'ASI_MFM_POSM_Return_Request_Item__c';
            //mcauCon.displayFieldsStr = 'ASI_MFM_SKU__c&read=A, ASI_MFM_SKU_Description_Text__c&read=A, ASI_MFM_SKU_Chinese_Description_Text__c&read=A,ASI_MFM_Packing_Description_Text__c&read=A, ASI_MFM_QTY_Issued__c&req=T';
            mcauCon.fieldToURLParamStr = 'ASI_MFM_Request_Order__c=>id';
            mcauCon.whereStatm = 'ASI_MFM_Approval_Status__c != \'Rejected\' and ASI_MFM_Approval_Status__c != \'Cancelled\' and ASI_MFM_Request_Order__c = \'' + oHeader.Id + '\'';
            mcauCon.orderByStr = 'Name';
            mcauCon.pageBlockTitleStr = 'POSM Return Request Items';
            mcauCon.successLinkStr = '/' + oHeader.Id;
            mcauCon.cancelLinkStr = '/' + oHeader.Id;
            mcauCon.modeStr = 'BOTH';
            mcauCon.isDefaultEditVal = true;
            mcauCon.isShowAllRT = true;
            mcauCon.isUseFirstRowForNew = false;
            mcauCon.myComponentKey = 'massCreateAndUpdate';
            mcauCon.myPageController = testCon.thisController;
            mcauCon.includeRecordTypesStr  = 'ASI_MFM_CN_POSM_Request_Item';
            
            mcauCon.displayFieldsStr = NULL;
            Boolean bTmpInit = mcauCon.dummyVar;
            mcauCon.cancelPage();
            
            /*
            sobjstCon.sObjTypeStr = 'ASI_MFM_SKU_Code__c';
            sobjstCon.displayFieldsStr = 'Name, ASI_MFM_SKU_Description__c, ASI_MFM_Sub_brand__c, ASI_FOC_SKU_Chinese_Description__c,ASI_FOC_Packing_Description__c';
            sobjstCon.defWhereStatmStr = testCon.baseWhereStatm;
            sobjstCon.orderByStr = 'ASI_MFM_SKU_Description__c';
            sobjstCon.numOfRowInTable = 8;
            sobjstCon.myComponentKey = 'selectTable';
            sobjstCon.myPageController = testCon.thisController;
            
            Boolean initPageBool = mcauCon.dummyVar;
            initPageBool = sobjstCon.initDummyVar;
            
            // Start testing user actions
            
            // Change page number
            sobjstCon.nextPage();
            sobjstCon.lastPage();
            sobjstCon.prevPage();
            sobjstCon.firstPage();
            
            // Clone product
            pageParams.put(mcauCon.PARAM_RTID, ASI_MFM_CN_ReturnRequestDetailGenerator.RT_Default);
            pageParams.put(mcauCon.PARAM_TRID, mcauCon.theRecordTypeElementList.get(0).myRecordList.get(0).id);
            mcauCon.cloneRow();
            
            // Dummy test of enableForEdit
            pageParams.put(mcauCon.PARAM_RTID, ASI_MFM_CN_ReturnRequestDetailGenerator.RT_Default);
            List<ASI_FOC_MassCreateAndUpdateController.TableRow> recordList = mcauCon.theRecordTypeElementList.get(0).myRecordList;
            pageParams.put(mcauCon.PARAM_TRID, recordList.get(recordList.size() - 1).id);
            mcauCon.enableForEdit();
            
            // Remove cloned product
            pageParams.put(mcauCon.PARAM_RTID, ASI_MFM_CN_ReturnRequestDetailGenerator.RT_Default);
            recordList = mcauCon.theRecordTypeElementList.get(0).myRecordList;
            pageParams.put(mcauCon.PARAM_TRID, recordList.get(recordList.size() - 1).id);
            mcauCon.removeNew();
            
            // Filter products
            testCon.filterName = oLTSKU[2].Name;
            testCon.filterSKU();
            //System.assertEquals(1, sobjstCon.tableEleList.size());
            
            // Add product
            pageParams.put('PARAM_BTN_ID', 'add');
            pageParams.put('PARAM_SOBJ_ID', sobjstCon.tableEleList.get(0).sObj.Id);
            sobjstCon.triggerRowAction();
            
            // Remove old product
            pageParams.put(mcauCon.PARAM_RTID, ASI_MFM_CN_ReturnRequestDetailGenerator.RT_Default);
            pageParams.put(mcauCon.PARAM_TRID, mcauCon.theRecordTypeElementList.get(0).myRecordList.get(0).id);
            mcauCon.deleteOld();
            
            // Remove new product
            pageParams.put(mcauCon.PARAM_RTID, ASI_MFM_CN_ReturnRequestDetailGenerator.RT_Default);
            recordList = mcauCon.theRecordTypeElementList.get(0).myRecordList;
            pageParams.put(mcauCon.PARAM_TRID, recordList.get(recordList.size() - 1).id);
            mcauCon.removeNew();
            
            // Dummy test of addMoreBlankRows
            mcauCon.addMoreBlankRows();
            
            // Add product
            pageParams.put('PARAM_BTN_ID', 'add');
            pageParams.put('PARAM_SOBJ_ID', sobjstCon.tableEleList.get(0).sObj.Id);
            sobjstCon.triggerRowAction();
            
            // Set values
            mcauCon.theRecordTypeElementList.get(0).myRecordList.get(0).mySObj.put('ASI_MFM_QTY_Issued__c', 5);
            
            // Save
            mcauCon.commitAll();
            mcauCon.cancelPage();
            
            
            //for ASI_MFM_CN_ReturnItemsDetailEditCON
            testCon.sobjst_triggerActionForSObject(sobjstCon, ASI_FOC_SFObjSelectTableController.DEF_BTN_KEY_ADD, oLTSKU[0]);
            testCon.mcau_triggerActionForSObject(mcauCon, ASI_FOC_MassCreateAndUpdateController.ACTION_REMOVE_NEW, oLTItem[0]);
            PageReference oTmpPageRef = testCon.mcau_triggerPageBlockAction(mcauCon, null);
            
            //for ASI_FOC_MassCreateAndUpdateController
            string sTmpAction = ASI_FOC_MassCreateAndUpdateController.ACTION_EDIT;
            sTmpAction = ASI_FOC_MassCreateAndUpdateController.ACTION_CLONE;
            sTmpAction = ASI_FOC_MassCreateAndUpdateController.ACTION_ADD_NEW;
            sTmpAction = ASI_FOC_MassCreateAndUpdateController.ACTION_REMOVE_NEW;
            sTmpAction = ASI_FOC_MassCreateAndUpdateController.ACTION_DELETE_OLD;
            sTmpAction = ASI_FOC_MassCreateAndUpdateController.RTNAME_MASTER;
    		sTmpAction = ASI_FOC_MassCreateAndUpdateController.RTDEVNAME_MASTER;
            sTmpAction = mcauCon.MODE_NEW;

            List<ASI_FOC_MassCreateAndUpdateController.TableRow> oLTRow = mcauCon.theRecordTypeElementList.get(0).myDisplayRecordList;
            
            mcauCon.refresh();
            oTmpPageRef = mcauCon.triggerPageBlockAction();
            oTmpPageRef = mcauCon.addNewRow();
            
            ASI_FOC_MassCreateAndUpdateController.PageBlockActionBtn oBtn = new ASI_FOC_MassCreateAndUpdateController.PageBlockActionBtn('test_id','test_label');
            ASI_FOC_MassCreateAndUpdateController.DisplayField oDisField = new ASI_FOC_MassCreateAndUpdateController.DisplayField('test_label','test_name');
            oDisField.colKey = 'id';
            
            mcauCon.clearAll();            
            */
            
			Test.stopTest();
        }
    }

}