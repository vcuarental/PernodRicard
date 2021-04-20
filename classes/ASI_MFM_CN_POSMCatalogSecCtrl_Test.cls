@isTest
public class ASI_MFM_CN_POSMCatalogSecCtrl_Test {

    public class TestObj {

        public List<User> lstUsr;
        public User user1;
        public User user2;
        
        public ASI_MFM_Brand__c brand;
        public list<ASI_MFM_Sub_brand__c> subBrands;
        public List<ASI_HK_CRM_Product_Category__c> ProductCategoryList;
        public List<ASI_TH_CRM_Sub_category__c> SubCategoryList;
        public List<ASI_MFM_Item_Group__c> tmpLTItemGroup;
        public List<ASI_MFM_POSMCatalogSecCtrl__c> tmpLTSec;
        
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
                createSec();
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
        
        private void createSec() {
            tmpLTSec = new LisT<ASI_MFM_POSMCatalogSecCtrl__c>();
            
            string strRTId = Global_RecordTypeCache.getRtId('ASI_MFM_POSMCatalogSecCtrl__cASI_MFM_CN_POSM');
            
            tmpLTSec.add(new ASI_MFM_POSMCatalogSecCtrl__c(
                ASI_MFM_ItemGroup__c = tmpLTItemGroup[0].id
                ,ASI_MFM_MappingType__c = 'Item Group - User'
                ,ASI_MFM_Open_to_all_user__c = false
                ,ASI_MFM_CanOrderinCatalog__c = 'No'
                ,ASI_MFM_User__c = user1.id
                ,RecordTypeId = strRTId
            ));
            
            tmpLTSec.add(new ASI_MFM_POSMCatalogSecCtrl__c(
                ASI_MFM_ItemGroup__c = tmpLTItemGroup[0].id
                ,ASI_MFM_MappingType__c = 'Item Group - User'
                ,ASI_MFM_Open_to_all_user__c = false
                ,ASI_MFM_CanOrderinCatalog__c = 'No'
                ,ASI_MFM_User__c = user2.id
                ,RecordTypeId = strRTId
            ));
            
			insert tmpLTSec;            
        }
        
	}
    
    static testmethod void ASI_MFM_CheckCatalogSecurityPage_TEST() {
        TestObj testObj = new TestObj();
        
        User User1 = testObj.user1;
        System.runAs(user1){
            Test.startTest();
            
            List<ASI_MFM_Item_Group__c> ltItemGroupDup = testObj.tmpLTItemGroup;
            List<ASI_MFM_POSMCatalogSecCtrl__c> ltItemGroupSec = testObj.tmpLTSec;
            ASI_MFM_Item_Group__c oHeader = ltItemGroupDup[0];
            
            PageReference oTestPage = Page.ASI_MFM_CN_ReturnItemsDetailEditPage;
            Map<String, String> mapParams = oTestPage.getParameters();
            mapParams.put('id', oHeader.Id);
            Test.setCurrentPageReference(oTestPage);
            
            ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(ltItemGroupDup);
            
            ASI_MFM_CN_POSMCatalogSecCtrl_EditCON testCon = new ASI_MFM_CN_POSMCatalogSecCtrl_EditCON(stdSetController);
            ASI_MFM_CN_POSM_Security_MACUController mcauCon = new ASI_MFM_CN_POSM_Security_MACUController();
            ASI_MFM_POSM_SFObjSelectTableController sobjstCon = new ASI_MFM_POSM_SFObjSelectTableController();
            
            string sDefaultRecordType = 'ASI_MFM_CN_POSM';
            
            // Assign component attributes
            mcauCon.isFastModeBool = false;
            mcauCon.sObjTypeStr = 'ASI_MFM_POSMCatalogSecCtrl__c';
            mcauCon.displayFieldsStr = 'ASI_MFM_User__c&req=T, ASI_MFM_CanOrderinCatalog__c&req=T';
            mcauCon.fieldToURLParamStr = 'ASI_MFM_ItemGroup__c=>id';
            mcauCon.whereStatm = 'ASI_MFM_ItemGroup__c=\'[@RELATED_ID]\' AND ASI_MFM_MappingType__c=\'Item Group - User\' AND ASI_MFM_Open_to_all_user__c=FALSE';
            mcauCon.orderByStr = 'ASI_MFM_User__r.Name ASC';
            mcauCon.pageBlockTitleStr = 'Selected Users';
            mcauCon.successLinkStr = '/' + oHeader.Id;
            mcauCon.cancelLinkStr = '/' + oHeader.Id;
            mcauCon.modeStr = 'BOTH';
            mcauCon.isDefaultEditVal = true;
            mcauCon.isShowAllRT = true;
            mcauCon.isUseFirstRowForNew = false;
            mcauCon.myComponentKey = 'massCreateAndUpdate';
            mcauCon.myPageController = testCon.thisController;
            mcauCon.includeRecordTypesStr  = sDefaultRecordType;
            
            sobjstCon.sObjTypeStr = 'ASI_MFM_Item_Group__c';
            sobjstCon.displayFieldsStr = 'Name,ASI_MFM_Item_Group_Code__c,ASI_CRM_CN_Eng_Name__c,ASI_CRM_CN_Chinese_Name__c,ASI_MFM_Sub_brand__c,ASI_MFM_Category_Level_1_Piclklist__c,ASI_MFM_Category_Level_2_Piclklist__c,ASI_MFM_Category_Level_3_Piclklist__c';
            sobjstCon.defWhereStatmStr = testCon.baseWhereStatm;
            sobjstCon.orderByStr = 'Name';
            sobjstCon.numOfRowInTable = 8;
            sobjstCon.myComponentKey = 'selectTable';
            sobjstCon.myPageController = testCon.thisController;
            
            Boolean initPageBool = mcauCon.dummyVar;
            initPageBool = mcauCon.init(oHeader.Id);
            initPageBool = sobjstCon.initDummyVar;
            
            ASI_MFM_CN_POSM_Security_MACUController mcauConI = new ASI_MFM_CN_POSM_Security_MACUController();
            ASI_MFM_CN_POSM_Security_MACUController mcauConS = new ASI_MFM_CN_POSM_Security_MACUController();
            
            mcauConI.isFastModeBool = false;
            mcauConI.sObjTypeStr = 'ASI_MFM_Item_Group__c';
            mcauConI.displayFieldsStr = 'Name&read=A,ASI_MFM_Item_Group_Code__c&read=A';
            mcauConI.fieldToURLParamStr = '';
            mcauConI.whereStatm = '';
            mcauConI.orderByStr = '';
            mcauConI.pageBlockTitleStr = 'Selected Item Group';
            mcauConI.successLinkStr = '';
            mcauConI.cancelLinkStr = '';
            mcauConI.modeStr = 'SELECT';
            mcauConI.isDefaultEditVal = true;
            mcauConI.isShowAllRT = true;
            mcauConI.isUseFirstRowForNew = false;
            mcauConI.myComponentKey = 'massCreateMultiItem';
            mcauConI.myPageController = testCon.thisController;
            mcauConI.includeRecordTypesStr  = 'ASI_MFM_CN_POSM_Item_Group';
            
            mcauConS.isFastModeBool = false;
            mcauConS.sObjTypeStr = 'ASI_MFM_POSMCatalogSecCtrl__c';
            mcauConS.displayFieldsStr = 'ASI_MFM_User__c&req=T, ASI_MFM_CanOrderinCatalog__c&req=T';
            mcauConS.fieldToURLParamStr = 'ASI_MFM_ItemGroup__c=>id';
            mcauConS.whereStatm = 'ASI_MFM_ItemGroup__c=\'[@RELATED_ID]\' AND ASI_MFM_MappingType__c=\'Item Group - User\' AND ASI_MFM_Open_to_all_user__c=FALSE';
            mcauConS.orderByStr = 'ASI_MFM_User__r.Name ASC';
            mcauConS.pageBlockTitleStr = 'Selected Users';
            mcauConS.successLinkStr = '';
            mcauConS.cancelLinkStr = '';
            mcauConS.modeStr = 'NEW';
            mcauConS.isDefaultEditVal = true;
            mcauConS.isShowAllRT = true;
            mcauConS.isUseFirstRowForNew = false;
            mcauConS.myComponentKey = 'massCreateMultiSec';
            mcauConS.myPageController = testCon.thisController;
            mcauConS.includeRecordTypesStr  = sDefaultRecordType;
            
            initPageBool = mcauConI.dummyVar;
            initPageBool = mcauConS.dummyVar;
            
            // Start testing user actions
            
            // Change page number
            sobjstCon.nextPage();
            sobjstCon.lastPage();
            sobjstCon.prevPage();
            sobjstCon.firstPage();
            
            // Clone product
            mapParams.put(mcauCon.PARAM_RTID, sDefaultRecordType);
            mapParams.put(mcauCon.PARAM_TRID, mcauCon.theRecordTypeElementList.get(0).myRecordList.get(0).id);
            mcauCon.cloneRow();
            
            // Dummy test of enableForEdit
            mapParams.put(mcauCon.PARAM_RTID, sDefaultRecordType);
            List<ASI_MFM_CN_POSM_Security_MACUController.TableRow> recordList = mcauCon.theRecordTypeElementList.get(0).myRecordList;
            mapParams.put(mcauCon.PARAM_TRID, recordList.get(recordList.size() - 1).id);
            mcauCon.enableForEdit();
            
            // Remove cloned product
            mapParams.put(mcauCon.PARAM_RTID, sDefaultRecordType);
            recordList = mcauCon.theRecordTypeElementList.get(0).myRecordList;
            mapParams.put(mcauCon.PARAM_TRID, recordList.get(recordList.size() - 1).id);
            mcauCon.removeNew();
            
            // Filter products
            testCon.filterName = ltItemGroupDup[2].ASI_CRM_CN_Eng_Name__c;
            testCon.filterItemGroup();
            //System.assertEquals(1, sobjstCon.tableEleList.size());
            
            // Add product
            mapParams.put('PARAM_BTN_ID', 'add');
            mapParams.put('PARAM_SOBJ_ID', sobjstCon.tableEleList.get(0).sObj.Id);
            sobjstCon.triggerRowAction();
            
            // Remove old product
            mapParams.put(mcauCon.PARAM_RTID, sDefaultRecordType);
            mapParams.put(mcauCon.PARAM_TRID, mcauCon.theRecordTypeElementList.get(0).myRecordList.get(0).id);
            mcauCon.deleteOld();
            
            // Remove new product
            mapParams.put(mcauCon.PARAM_RTID, sDefaultRecordType);
            recordList = mcauCon.theRecordTypeElementList.get(0).myRecordList;
            mapParams.put(mcauCon.PARAM_TRID, recordList.get(recordList.size() - 1).id);
            mcauCon.removeNew();
            
            // Dummy test of addMoreBlankRows
            mcauCon.addMoreBlankRows();
            
            // Add product
            mapParams.put('PARAM_BTN_ID', 'add');
            mapParams.put('PARAM_SOBJ_ID', sobjstCon.tableEleList.get(0).sObj.Id);
            sobjstCon.triggerRowAction();
            
            // Set values
            //mcauCon.theRecordTypeElementList.get(0).myRecordList.get(0).mySObj.put('ASI_MFM_QTY_Issued__c', 5);
            
            // Save
            mcauCon.commitAll();
            mcauCon.cancelPage();
            
            //for ASI_MFM_POSM_SFObjSelectTableController
            Map<String, Integer> oBtnKeyToStageMap = new Map<String, Integer>();
            sobjstCon.setBtnStagesForAll(oBtnKeyToStageMap);
            sobjstCon.setBtnStageBySObjId(ltItemGroupDup[0].id, oBtnKeyToStageMap);
            sobjstCon.setBtnStageBySObjId(ltItemGroupDup[0].id, 'Click', 99);
            
            //for ASI_MFM_CN_POSMCatalogSecCtrl_EditCON
            testCon.sobjst_triggerActionForSObject(sobjstCon, ASI_MFM_POSM_SFObjSelectTableController.DEF_BTN_KEY_ADD, ltItemGroupDup[0]);
            testCon.mcau_triggerActionForSObject(mcauCon, ASI_MFM_CN_POSM_Security_MACUController.ACTION_REMOVE_NEW, ltItemGroupSec[0]);
            PageReference oTmpPageRef = testCon.mcau_triggerPageBlockAction(mcauCon, null);
            
            //for ASI_MFM_CN_POSM_Security_MACUController
            string sTmpAction = ASI_MFM_CN_POSM_Security_MACUController.ACTION_EDIT;
            sTmpAction = ASI_MFM_CN_POSM_Security_MACUController.ACTION_CLONE;
            sTmpAction = ASI_MFM_CN_POSM_Security_MACUController.ACTION_ADD_NEW;
            sTmpAction = ASI_MFM_CN_POSM_Security_MACUController.ACTION_REMOVE_NEW;
            sTmpAction = ASI_MFM_CN_POSM_Security_MACUController.ACTION_DELETE_OLD;
            sTmpAction = ASI_MFM_CN_POSM_Security_MACUController.RTNAME_MASTER;
    		sTmpAction = ASI_MFM_CN_POSM_Security_MACUController.RTDEVNAME_MASTER;
            sTmpAction = mcauCon.MODE_NEW;

            List<ASI_MFM_CN_POSM_Security_MACUController.TableRow> oLTRow = mcauCon.theRecordTypeElementList.get(0).myDisplayRecordList;
            
            mcauCon.refresh();
            oTmpPageRef = mcauCon.triggerPageBlockAction();
            oTmpPageRef = mcauCon.addNewRow();
            mcauCon.addNewRowByInfo(sDefaultRecordType, ltItemGroupSec[0]);
            
            ASI_MFM_CN_POSM_Security_MACUController.PageBlockActionBtn oBtn = new ASI_MFM_CN_POSM_Security_MACUController.PageBlockActionBtn('test_id','test_label');
            ASI_MFM_CN_POSM_Security_MACUController.DisplayField oDisField = new ASI_MFM_CN_POSM_Security_MACUController.DisplayField('test_label','test_name');
            oDisField.colKey = 'id';
            
            mcauCon.PARAM_OPEN_TO_ALL = TRUE;
            mcauCon.commitAll();
            
            mcauCon.clearAll();
            mcauCon.refreshPage();
            oTmpPageRef = mcauCon.checkOpenToAll();
            
            //for ASI_MFM_CN_POSMCatalogSecCtrl_EditCON
            testCon.selectAllMC();
            testCon.refreshPageMC();
            oTmpPageRef = testCon.commitAllMC();
            
            testCon = new ASI_MFM_CN_POSMCatalogSecCtrl_EditCON();
            testCon.filterUserName = '';
            testCon.ItemGroupId = ltItemGroupDup[0].id;
            testCon.requestNumber = '';
            testCon.OpenInCatalog = TRUE;
            testCon.CanOrder = TRUE;
            testCon.AllOpenInCatalog = TRUE;
            testCon.AllCanOrder = TRUE;
            testCon.size = 10;
            testCon.noOfRecords = 10;
            testCon.objId = ltItemGroupDup[0].id;
            testCon.filterReqItemInput = ltItemGroupDup[0];
            testCon.filterItemGroup();
            
            testCon.Back();
            
			ASI_MFM_CN_CatalogSecGenerator oItemGen = new ASI_MFM_CN_CatalogSecGenerator();
            ASI_MFM_POSMCatalogSecCtrl__c oTmpSecCtrl = oItemGen.generateReturnRequestDetail(oHeader,User1);
            
            Test.stopTest();
        }
    }
    
}