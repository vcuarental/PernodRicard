@isTest
public class ASI_MFM_CN_AutoReceiptAdmin_Test {
    
    Private Static Final String BRAND_RECORDTYPE_ID = Global_RecordTypeCache.getRtId('ASI_MFM_Brand__cASI_FOC_CN_Brand');
    Private Static Final String SUB_BRAND_RECORDTYPE_ID = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand');
    Private Static Final String CATEGORY_RECORDTYPE_ID = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Product_Category__cASI_MFM_CN_Category_Master');
    Private Static Final String ITEMGROUP_RECORDTYPE_ID = Global_RecordTypeCache.getRtId('ASI_MFM_Item_Group__cASI_MFM_CN_POSM_Item_Group');
    Private Static Final String POSM_IETMGROUP_PHOTO_RECORDTYPE_ID = Global_RecordTypeCache.getRtId('ASI_CRM_Product_Warehouse_Photo__cASI_MFM_CN_POSM_Photo'); 
    Private Static Final String CHANNEL_RECORDTYPE_ID = Global_RecordTypeCache.getRtId('ASI_CRM_CN_Channel__cASI_MFM_CN_POSM_Channel');
    
    public class TestData{
        public List<ASI_MFM_Brand__c> brands;
        public list<ASI_MFM_Sub_brand__c> subBrands;
        public List<ASI_HK_CRM_Product_Category__c> ProductCategoryList;
        public List<ASI_TH_CRM_Sub_category__c> SubCategoryList;
        public List<ASI_MFM_Item_Group__c> itemgroupList;
        public List<ASI_CRM_CN_Channel__c> channelList;
        public List<ASI_MFM_SKU_Code__c> skuList;
        public List<ASI_FOC_Warehouse__c> warehouseList;
        public List<ASI_CRM_City__c> cityList;
        public List<ASI_CRM_CN_Area__c> areaList;
        public List<ASI_CRM_Province__c> provinceList;
        public List<ASI_CRM_Division__c> divisionList;
		public List<ASI_CRM_Region__c> regionList;
        public List<ASI_MFM_Inventory_Balance__c> ibList;
        public List<ASI_MFM_InventoryBalanceDetail__c> ibdList;
        public List<ASI_FOC_Delivery_Zone__c> dzoneList;
        public List<ASI_MFM_POSMCatalogSecCtrl__c> secCtrlList;
             
        public TestData(){
            initFirst();
		}
		
        public void initFirst(){
            String strRTId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Product_Category__cASI_MFM_CN_Category_Master');
            ProductCategoryList= new List<ASI_HK_CRM_Product_Category__c> ();                                                                                            
            ProductCategoryList.add(new ASI_HK_CRM_Product_Category__c(RecordTypeId=strRTId,ASI_MFM_Level__c='Level 1',Name='Display 陈列',ASI_MFM_Running_Number__c=1,ASI_HK_CRM_Category_Code__c='11',ASI_CRM_CN_Chinese_Name__c='Category',ASI_HK_CRM_English_Name__c='Category',ASI_HK_CRM_Sequence__c=1));
            ProductCategoryList.add(new ASI_HK_CRM_Product_Category__c(RecordTypeId=strRTId,ASI_MFM_Level__c='Level 2',Name='BAG 包',ASI_MFM_Running_Number__c=2,ASI_HK_CRM_Category_Code__c='22',ASI_CRM_CN_Chinese_Name__c='Category2',ASI_HK_CRM_English_Name__c='Category',ASI_HK_CRM_Sequence__c=2));
            ProductCategoryList.add(new ASI_HK_CRM_Product_Category__c(RecordTypeId=strRTId,ASI_MFM_Level__c='Level 3',Name='LEATHER 皮质',ASI_MFM_Running_Number__c=3,ASI_HK_CRM_Category_Code__c='33',ASI_CRM_CN_Chinese_Name__c='Category1',ASI_HK_CRM_English_Name__c='Category',ASI_HK_CRM_Sequence__c=3));
            ProductCategoryList.add(new ASI_HK_CRM_Product_Category__c(RecordTypeId=strRTId,ASI_MFM_Level__c='Level 3',Name='LEATHER 皮质',ASI_MFM_Running_Number__c=4,ASI_HK_CRM_Category_Code__c='44',ASI_HK_CRM_English_Name__c='Category',ASI_HK_CRM_Sequence__c=3));
            
            insert ProductCategoryList;
             
            SubCategoryList = new List<ASI_TH_CRM_Sub_category__c>(); 
            strRTId = Global_recordTypeCache.getRtId('ASI_TH_CRM_Sub_category__cASI_MFM_CN_POSM_Sub_Cetagory_Master');
            SubCategoryList.add(new ASI_TH_CRM_Sub_category__c(RecordTypeId=strRTId,ASI_MFM_Category_Level_2_3__c=ProductCategoryList[1].id,ASI_CRM_CN_Product_Category__c=ProductCategoryList[0].id));
            SubCategoryList.add(new ASI_TH_CRM_Sub_category__c(RecordTypeId=strRTId,ASI_MFM_Category_Level_2_3__c=ProductCategoryList[2].id,ASI_CRM_CN_Product_Category__c=ProductCategoryList[0].id));
            insert SubCategoryList;
            
            strRTId = Global_RecordTypeCache.getRtId('ASI_MFM_Brand__cASI_FOC_CN_Brand');
            brands = new List<ASI_MFM_Brand__c>();
            brands.add(new ASI_MFM_Brand__c(Recordtypeid=strRTId,name='brandname',ASI_CRM_CN_Chinese_Name__c='chi',ASI_HK_CRM_English_Name__c='eng',ASI_CRM_CN_Competitor__c=false,ASI_MFM_Active_for_POSM__c=true));
            brands.add(new ASI_MFM_Brand__c(Recordtypeid=strRTId,name='brandname',ASI_CRM_CN_Chinese_Name__c='chi',ASI_CRM_CN_Competitor__c=false,ASI_MFM_Active_for_POSM__c=true));
            brands.add(new ASI_MFM_Brand__c(Recordtypeid=strRTId,name='brandname',ASI_HK_CRM_English_Name__c='eng',ASI_CRM_CN_Competitor__c=false,ASI_MFM_Active_for_POSM__c=true));
            brands.add(new ASI_MFM_Brand__c(Recordtypeid=strRTId,name='brandname',ASI_CRM_CN_Competitor__c=false,ASI_MFM_Active_for_POSM__c=true));
            insert brands;
            
            subBrands = new list<ASI_MFM_Sub_brand__c>();
            //create sub brand
            strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_Sub_brand__c','ASI_FOC_CN_Sub_brand');
            subBrands.add(new ASI_MFM_Sub_brand__c(Name='subBrand1',ASI_HK_CRM_English_Name__c='eng',ASI_CRM_CN_CHI_NAME_C__c='chi',recordTypeId=strRTId,ASI_MFM_Active_for_POSM__c=true));
            subBrands.add(new ASI_MFM_Sub_brand__c(Name='subBrand2',ASI_HK_CRM_English_Name__c='eng',recordTypeId=strRTId,ASI_MFM_Active_for_POSM__c=true));
            subBrands.add(new ASI_MFM_Sub_brand__c(Name='subBrand3',ASI_CRM_CN_CHI_NAME_C__c='chi',recordTypeId=strRTId,ASI_MFM_Active_for_POSM__c=true));
            subBrands.add(new ASI_MFM_Sub_brand__c(Name='testSb',recordtypeid=strRTId,ASI_MFM_Brand__c=brands[0].id,ASI_MFM_Active_for_POSM__c=true));
            insert subBrands;
            
            channelList = new List<ASI_CRM_CN_Channel__c>();
            strRTId = Global_RecordTypeCache.getRtId('ASI_CRM_CN_Channel__cASI_MFM_CN_POSM_Channel');
            channelList.add(new ASI_CRM_CN_Channel__c(recordTypeId=strRTId,name='testa',ASI_CRM_CN_Channel_Eng_Name__c='test1',ASI_CRM_CN_Channel_Chi_Name__c='test2'));
            channelList.add(new ASI_CRM_CN_Channel__c(recordTypeId=strRTId,name='testb',ASI_CRM_CN_Channel_Eng_Name__c='test1'));
            channelList.add(new ASI_CRM_CN_Channel__c(recordTypeId=strRTId,name='testc',ASI_CRM_CN_Channel_Chi_Name__c='test2'));
            channelList.add(new ASI_CRM_CN_Channel__c(recordTypeId=strRTId,name='testd'));
            insert channelList;
            
            itemgroupList = new List<ASI_MFM_Item_Group__c>();
            strRTId = Global_RecordTypeCache.getRtId('ASI_MFM_Item_Group__cASI_MFM_CN_POSM_Item_Group');
			itemgroupList.add(new ASI_MFM_Item_Group__c(RecordTypeId=strRTId,name='test',ASI_MFM_CN_OneTimeItem__c='Yes',ASI_CRM_CN_Chinese_Name__c='test2', ASI_MFM_Item_Group_Code__c='11',ASI_MFM_Utilization_Status__c='Active',ASI_CRM_CN_Hidden__c=FALSE));
            itemgroupList.add(new ASI_MFM_Item_Group__c(RecordTypeId=strRTId,name='test',ASI_MFM_CN_OneTimeItem__c='Yes',ASI_CRM_CN_Eng_Name__c='test2', ASI_MFM_Item_Group_Code__c='11',ASI_MFM_Utilization_Status__c='Active',ASI_CRM_CN_Hidden__c=FALSE));
            insert itemgroupList;
        }
        
        public void initSecond(){
            provinceList = new List<ASI_CRM_Province__c>();
            String strRTId = Global_RecordTypeCache.getRtId('ASI_CRM_Province__cASI_CRM_CN_Province');
            provinceList.add(new ASI_CRM_Province__c(RecordTypeId=strRTId,Name='1',ASI_CRM_Province_Code__c='code1',ASI_CRM_Chinese_Name__c='chi1',ASI_CRM_English_Name__c ='eng1',ASI_CRM_External_ID__c='chi1'));
            provinceList.add(new ASI_CRM_Province__c(RecordTypeId=strRTId,Name='2',ASI_CRM_Province_Code__c='code2',ASI_CRM_Chinese_Name__c='chi2',ASI_CRM_English_Name__c ='eng2',ASI_CRM_External_ID__c='chi2'));
            insert provinceList;
			
            strRTId = Global_RecordTypeCache.getRtId('ASI_CRM_Region__cASI_CRM_CN_Region');            
			regionList = new List<ASI_CRM_Region__c>();
            regionList.add(new ASI_CRM_Region__c(RecordTypeId=strRTId,Name='1',ASI_CRM_Chinese_Name__c='chi1',ASI_CRM_English_Name__c='eng1',ASI_CRM_Region_Code__c='1',ASI_CRM_Billing_Group__c='Other',ASI_CRM_CN_Region_Type__c='1',ASI_CRM_Display_Payable_Vol_Amt_BRSF__c=true));
            regionList.add(new ASI_CRM_Region__c(RecordTypeId=strRTId,Name='2',ASI_CRM_Chinese_Name__c='chi2',ASI_CRM_English_Name__c='eng2',ASI_CRM_Region_Code__c='2',ASI_CRM_Billing_Group__c='Other',ASI_CRM_CN_Region_Type__c='1',ASI_CRM_Display_Payable_Vol_Amt_BRSF__c=true));
            insert regionList;
            
            strRTId = Global_RecordTypeCache.getRtId('ASI_CRM_Division__cASI_CRM_CN_Region');            
            divisionList = new List<ASI_CRM_Division__c>();
            divisionList.add(new ASI_CRM_Division__c(RecordTypeId=strRTId,Name='1',ASI_CRM_CN_Chinese_Name__c='chi1',ASI_CRM_English_Name__c='eng1',ASI_CRM_Division_Code__c='1000',ASI_CRM_Sequence__c =11,ASI_CRM_Region__c=regionList[0].id));
            divisionList.add(new ASI_CRM_Division__c(RecordTypeId=strRTId,Name='2',ASI_CRM_CN_Chinese_Name__c='chi2',ASI_CRM_English_Name__c='eng2',ASI_CRM_Division_Code__c='1000',ASI_CRM_Sequence__c =12,ASI_CRM_Region__c=regionList[1].id));
            insert divisionList;
            
            strRTId = Global_RecordTypeCache.getRtId('ASI_CRM_CN_Area__cASI_CRM_CN_Area');
            areaList = new List<ASI_CRM_CN_Area__c>();
            areaList.add(new ASI_CRM_CN_Area__c(RecordTypeId=strRTId,Name='1',ASI_CRM_CN_Area_Code__c='101',ASI_CRM_CN_Sequence__c=101,ASI_CRM_English_Name__c='eng1',ASI_CRM_CN_Chinese_Name__c='chi1',ASI_CRM_Division__c=divisionList[0].id, ASI_CRM_External_ID__c='1',ASI_CRM_CN_Greater_Region_Code_Text__c='GS'));
            areaList.add(new ASI_CRM_CN_Area__c(RecordTypeId=strRTId,Name='2',ASI_CRM_CN_Area_Code__c='201',ASI_CRM_CN_Sequence__c=201,ASI_CRM_English_Name__c='eng2',ASI_CRM_CN_Chinese_Name__c='chi2',ASI_CRM_Division__c=divisionList[1].id, ASI_CRM_External_ID__c='2',ASI_CRM_CN_Greater_Region_Code_Text__c='GS'));
            insert areaList;
            
            strRTId = Global_RecordTypeCache.getRtId('ASI_CRM_City__cASI_CRM_CN_City');
            cityList = new List<ASI_CRM_City__c>();
            cityList.add(new ASI_CRM_City__c(RecordTypeId=strRTId,Name='1',ASI_CRM_CN_Area__c=areaList[0].id,ASI_CRM_CN_Province__c=provinceList[0].id));
            cityList.add(new ASI_CRM_City__c(RecordTypeId=strRTId,Name='2',ASI_CRM_CN_Area__c=areaList[1].id,ASI_CRM_CN_Province__c=provinceList[1].id));
            insert cityList;
            
            strRTId = Global_RecordTypeCache.getRtId('ASI_FOC_Warehouse__cASI_FOC_CN_Warehouse');
            warehouseList = new List<ASI_FOC_Warehouse__c>();
            warehouseList.add(new ASI_FOC_Warehouse__c(RecordTypeId=strRTId,Name='1',ASI_FOC_Warehouse_Code__c='001',ASI_FOC_Warehouse_Type__c='Region Warehouse',ASI_FOC_Warehouse_Description__c='desc1'
                                                       ,ASI_FOC_Warehouse_Address__c='11111',ASI_FOC_Contact__c='111', ASI_FOC_SIR_Email_Address_1__c ='aaa@aa.com'
                                                       ,ASI_FOC_City__c=cityList[0].id,ASI_FOC_Region__c=regionList[0].id));

            warehouseList.add(new ASI_FOC_Warehouse__c(RecordTypeId=strRTId,Name='2',ASI_FOC_Warehouse_Code__c='002',ASI_FOC_Warehouse_Type__c='Region Warehouse',ASI_FOC_Warehouse_Description__c='desc2'
                                                       ,ASI_FOC_Warehouse_Address__c='22222',ASI_FOC_Contact__c='222', ASI_FOC_SIR_Email_Address_1__c ='aaa@cv.com'
                                                       ,ASI_FOC_City__c=cityList[1].id,ASI_FOC_Region__c=regionList[1].id));
            insert warehouseList;
            
            strRTId = Global_RecordTypeCache.getRtId('ASI_MFM_SKU_Code__cASI_FOC_CN_POSM_SKU');
            skuList = new List<ASI_MFM_SKU_Code__c>();
            skuList.add(new ASI_MFM_SKU_Code__c(RecordTypeId=strRTId,ASI_HK_CRM_Available_Quantity__c=null,ASI_MFM_Item_Group__c=itemgroupList[0].id,Name='1',ASI_MFM_SKU_Description__c='desc',ASI_MFM_SKU_Code__c='123AA',ASI_MFM_Minimum_Packing_Qty__c=1,ASI_MFM_Minimum_Box_Qty__c=2));
            skuList.add(new ASI_MFM_SKU_Code__c(RecordTypeId=strRTId,ASI_HK_CRM_Available_Quantity__c=null,ASI_MFM_Item_Group__c=itemgroupList[1].id,Name='2',ASI_MFM_SKU_Description__c='desc',ASI_MFM_SKU_Code__c='123BB',ASI_MFM_Minimum_Packing_Qty__c=1,ASI_MFM_Minimum_Box_Qty__c=2));
            insert skuList;
            
            strRTId = Global_RecordTypeCache.getRtId('ASI_MFM_Inventory_Balance__cASI_MFM_CN_Inventory_Balance');
            ibList = new List<ASI_MFM_Inventory_Balance__c>();
            ibList.add(new ASI_MFM_Inventory_Balance__c(RecordTypeId=strRTId,ASI_MFM_SKU__c=skuList[0].id,ASI_MFM_Warehouse__c=warehouseList[0].id));
            ibList.add(new ASI_MFM_Inventory_Balance__c(RecordTypeId=strRTId,ASI_MFM_SKU__c=skuList[1].id,ASI_MFM_Warehouse__c=warehouseList[1].id));
            insert ibList;
            
            strRTId = Global_RecordTypeCache.getRtId('ASI_MFM_InventoryBalanceDetail__cASI_MFM_CN_InventoryBalanceDetailRcrdTpy');
            ibdList = new List<ASI_MFM_InventoryBalanceDetail__c>();
            ibdList.add(new ASI_MFM_InventoryBalanceDetail__c(RecordTypeId=strRTId,Name='20180101',ASI_MFM_InventoryBalance__c=ibList[0].id,ASI_MFM_ItemGroup__c=itemgroupList[0].id,ASI_MFM_SKU__c=skuList[0].id, ASI_MFM_JDEAvailableQuantity__c =10000));
            ibdList.add(new ASI_MFM_InventoryBalanceDetail__c(RecordTypeId=strRTId,Name='20180102',ASI_MFM_InventoryBalance__c=ibList[1].id,ASI_MFM_ItemGroup__c=itemgroupList[1].id,ASI_MFM_SKU__c=skuList[1].id, ASI_MFM_JDEAvailableQuantity__c =10000));
			insert ibdList;
            
            strRTId = Global_RecordTypeCache.getRtId('ASI_FOC_Delivery_Zone__cASI_MFM_CN_POSM');
            dzoneList = new List<ASI_FOC_Delivery_Zone__c>();
            dzoneList.add(new ASI_FOC_Delivery_Zone__c(recordTypeId=strRTId,Name='test1',ASI_FOC_City_From__c=cityList[0].id,ASI_FOC_City_To__c=cityList[1].id,ASI_MFM_OutStorageTime__c=1,ASI_MFM_TransportTime__c=2));
            dzoneList.add(new ASI_FOC_Delivery_Zone__c(recordTypeId=strRTId,Name='test2',ASI_FOC_City_From__c=cityList[1].id,ASI_FOC_City_To__c=cityList[0].id,ASI_MFM_OutStorageTime__c=2,ASI_MFM_TransportTime__c=3));
            insert dzoneList;
        }
        public void initThird(id userid){
			String strRTId = Global_RecordTypeCache.getRtId('ASI_MFM_POSMCatalogSecCtrl__cASI_MFM_CN_POSM');
            secCtrlList = new List<ASI_MFM_POSMCatalogSecCtrl__c>();
            //Warehouse - User	
			secCtrlList.add(new ASI_MFM_POSMCatalogSecCtrl__c(recordTypeId=strRTId,ASI_MFM_CanOrderinCatalog__c='Yes',ASI_MFM_MappingType__c='Item Group - User',ASI_MFM_ItemGroup__c=itemgroupList[0].id,ASI_MFM_User__c=userid));
            secCtrlList.add(new ASI_MFM_POSMCatalogSecCtrl__c(recordTypeId=strRTId,ASI_MFM_CanOrderinCatalog__c='Yes',ASI_MFM_MappingType__c='Item Group - User',ASI_MFM_ItemGroup__c=itemgroupList[1].id,ASI_MFM_User__c=userid));
            secCtrlList.add(new ASI_MFM_POSMCatalogSecCtrl__c(recordTypeId=strRTId,ASI_MFM_CanOrderinCatalog__c='Yes',ASI_MFM_MappingType__c='Warehouse - User',ASI_MFM_Warehouse__c =warehouseList[0].id,ASI_MFM_User__c=userid));
            secCtrlList.add(new ASI_MFM_POSMCatalogSecCtrl__c(recordTypeId=strRTId,ASI_MFM_CanOrderinCatalog__c='Yes',ASI_MFM_MappingType__c='Warehouse - User',ASI_MFM_Warehouse__c =warehouseList[1].id,ASI_MFM_User__c=userid));
            insert secCtrlList;            
        }
    }
    
    public class TestObj {

        public List<User> lstUsr;
        public User user1;
        public User user2;

        //public string G_FISCAL_YEAR;
        public List<ASI_MFM_PO__c> tmpLTPO;
        public Date tmpStartDate;
        public Date tmpEndDate;
        
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
                //G_FISCAL_YEAR = getFiscalYear();
                createTestingData();
            }
        }
        
        private string getFiscalYear(){
            Integer orgFiscalMonth = [SELECT FiscalYearStartMonth FROM Organization].FiscalYearStartMonth;  //i.e. 7
            Date orgFiscalYear = Date.newinstance(system.today().year(), orgFiscalMonth, 1);    
            Datetime GMTdate = Datetime.now();
            String yearA1 = GMTdate.format('YY');
            Integer yearA0 = Integer.valueOf(yearA1) -1;
            Integer yearA2 = Integer.valueOf(yearA1) +1;
            String Current_Fiscal_year;
            
            if(system.today()< orgFiscalYear){
                Current_Fiscal_year = 'FY' + yearA0 + yearA1 ;
            }else{
                Current_Fiscal_year = 'FY' + yearA1 + yearA2 ;
            }
            
            return Current_Fiscal_year;
        }
        
        // copy from ASI_MFM_CN_InputPOReceiptPhasingTest
        private void createTestingData() {
            string fyear = 'FY' + (date.today().month() < 7 ? String.valueOf(date.today().addYears(-1).year() - 2000) + String.valueOf(date.today().year() - 2000) : String.valueOf(date.today().year() - 2000) + String.valueOf(date.today().addYears(1).year() - 2000));
            system.debug('fyear:' + fyear);
            
            //ASI_MFM_Market_Strategy__c ms = new ASI_MFM_Market_Strategy__c(Name='99999 Malibu', ASI_MFM_Active__c=true, ASI_MFM_Fiscal_Year__c=fyear);
            
            String strRTID;
        
        	list<ASI_MFM_Prefix__c> prefixs = new list<ASI_MFM_Prefix__c>();
            prefixs.add(new ASI_MFM_Prefix__c(Name='CN',ASI_MFM_Module__c='Plan',Plan_Type__c='Allowance & Discount Spending Form'
                                              ,ASI_MFM_Fiscal_year__c=fyear,ownerId = user1.id));

            //create prefix po
            strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_Prefix__c','ASI_MFM_CN_Prefix');
            prefixs.add(new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO', recordTypeId=strRTID,
                                              ASI_MFM_Fiscal_year__c=fyear, ASI_MFM_Next_Number__c=86));
            system.debug('recordTypeId: ' + strRTID);
            prefixs.add(new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO', recordTypeId=strRTID,
                                              ASI_MFM_Fiscal_year__c=fyear, ASI_MFM_Next_Number__c=86));
            
            insert prefixs;
            
            list<ASI_MFM_Role_Prefix_Relationship__c> prefixChilds = new list<ASI_MFM_Role_Prefix_Relationship__c>();
            prefixChilds.Add(new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c = prefixs[0].Id,
                                                                     ASI_MFM_Role_Name__c =user1.userRole.developerName));            
            prefixChilds.Add(new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c = prefixs[1].Id,
                                                                     ASI_MFM_Role_Name__c =user1.userRole.developerName));            
            
            insert prefixChilds;
            
            
            
            
            strRTId =ASI_MFM_Function.checkRecordType('ASI_MFM_A_C_Code__c','ASI_MFM_CN_A_C_Code');
            list<ASI_MFM_A_C_Code__c> acs = new list<ASI_MFM_A_C_Code__c>();
            acs.add(new ASI_MFM_A_C_Code__c(recordtypeid=strRTId, name='testAC1', ASI_MFM_A_C_Code__c = '5600.000'));
            acs.add(new ASI_MFM_A_C_Code__c(recordtypeid=strRTId, name='testAC2', ASI_MFM_A_C_Code__c = '5600.300'));
            acs.add(new ASI_MFM_A_C_Code__c(name='testAC', recordtypeid=strRTId ));
            insert acs;
            
            strRTId =ASI_MFM_Function.checkRecordType('ASI_MFM_PP_Category__c','ASI_MFM_CN_PP_Category');   
            ASI_MFM_PP_Category__c ppc = new ASI_MFM_PP_Category__c(recordtypeid=strRTId , Name='NTMCD - KTV Promotion', ASI_MFM_External_ID__c='NTMCD - KTV Promotion (CN)1');
            insert ppc;
            
            strRTId =ASI_MFM_Function.checkRecordType('ASI_MFM_PP_Category_A_C__c','ASI_MFM_CN_PP_Category_A_C'); 
            list<ASI_MFM_PP_Category_A_C__c> ppcacs = new list<ASI_MFM_PP_Category_A_C__c>();
            ppcacs.add(new ASI_MFM_PP_Category_A_C__c(ASI_MFM_External_ID__c='test', recordtypeid=strRTId , ASI_MFM_A_C_Code__c=acs[0].id, ASI_MFM_PP_Category__c=ppc.id));
            ppcacs.add(new ASI_MFM_PP_Category_A_C__c(ASI_MFM_External_ID__c='test2', recordtypeid=strRTId , ASI_MFM_A_C_Code__c=acs[1].id,ASI_MFM_PP_Category__c=ppc.id));
            insert ppcacs; 
            
            ASI_MFM_Market_Strategy__c mms = new ASI_MFM_Market_Strategy__c(name='12004 Chivas', ASI_MFM_External_ID__c='120041',ASI_MFM_Fiscal_Year__c=fyear, ASI_MFM_Sub_brand__c='CH2,CH3,CHF,CHU',ASI_MFM_Active__c=true);
            insert mms;
            
            strRTId =ASI_MFM_Function.checkRecordType('ASI_MFM_Plan__c','ASI_MFM_CN_Plan'); 
            ASI_MFM_Plan__c Plan1 = new ASI_MFM_Plan__c(Name='CNM131',ASI_MFM_Prefix__c=prefixs[0].Id
                                                        ,recordTypeId=strRTId ,
                                                        ASI_MFM_End_Date__c = Date.today().addMonths(1), ASI_MFM_Plan_Description__c='testDescription', 
                                                        ASI_MFM_Plan_Name__c='plannameTest', ASI_MFM_Start_Date__c=Date.today(), ASI_MFM_Budget_Owner__c=user1.id, 
                                                        ASI_MFM_PP_Category__c = ppc.id, ASI_MFM_Market_Strategy__c=mms.id, ASI_MFM_Status__c='Final', OwnerId =user1.id);
            insert Plan1;
            
            //create brand
            strRTId =ASI_MFM_Function.checkRecordType('ASI_MFM_Brand__c','ASI_MFM_CN_Brand');
            ASI_MFM_Brand__c brand = new ASI_MFM_Brand__c(name='brandname',Recordtypeid=strRTId);
            insert brand; 
            
            list<ASI_MFM_Sub_brand__c> subBrands = new list<ASI_MFM_Sub_brand__c>();
            //create sub brand
            strRTId =ASI_MFM_Function.checkRecordType('ASI_MFM_Sub_brand__c','ASI_MFM_CN_Sub_Brand');
            subBrands.add(new ASI_MFM_Sub_brand__c(Name='subBrand1' ,recordTypeId=strRTId));
            subBrands.add(new ASI_MFM_Sub_brand__c(Name='subBrand2' ,recordTypeId=strRTId));
            subBrands.add(new ASI_MFM_Sub_brand__c(Name='testSb',recordtypeid=strRTId,ASI_MFM_Brand__c=brand.id));
            insert subBrands;
            
            list<Account> accs = new list<Account>();
            
            strRTId =ASI_MFM_Function.checkRecordType('Account','ASI_MFM_CN_Outlet'); 
            accs.add(new Account(recordTypeId=strRTId ,Name='Name3'));
            
            //ASI_MFM_CN_Supplier 
            strRTId =ASI_MFM_Function.checkRecordType('Account','ASI_MFM_CN_Supplier'); 
            accs.add(new Account(Name='TestAcc', recordTypeId=strRTId , ASI_MFM_Customer_Supplier_Number__c='123',
                                 ASI_MFM_Customer_Supplier_Name__c='SupplierName'));
            insert accs;
            
            strRTId =ASI_MFM_Function.checkRecordType('ASI_MFM_Plan_Line_Item__c','ASI_MFM_CN_Plan_Line_Item');
            ASI_MFM_Plan_Line_Item__c planLineItem1 = new ASI_MFM_Plan_Line_Item__c(ASI_MFM_Plan__c = Plan1.id
                                                                                    ,ASI_MFM_Sub_brand_Code__c = subBrands[2].id,ASI_MFM_List_Item_Description__c='hello1'
                                                                                    ,recordTypeId=strRTId , ASI_MFM_Total_Cost__c =120000,
                                                                                    ASI_MFM_A_C_Code__c=acs[2].id
                                                                                   );
            insert planLineItem1; 
            
            //create BU Code
            strRTId =ASI_MFM_Function.checkRecordType('ASI_MFM_BU__c','ASI_MFM_CN_BU');
            ASI_MFM_BU__c bu = new ASI_MFM_BU__c(Name='PRCN', ASI_MFM_BU_Code__c='PRCN', RecordTypeId=strRTId , ASI_MFM_CN_Country__c='CN',
                                                 ASI_MFM_Base_Currency__c='RMB',ASI_MFM_Auto_Receipt__c=TRUE);
            insert bu;
            
            
            
            //create exchange rate reference
            ASI_MFM_Exchange_Rate__c ex = new ASI_MFM_Exchange_Rate__c(ASI_MFM_Country__c='CN',ASI_MFM_Effective_Date__c=Date.valueof('2014-01-01'),
                                                                       ASI_MFM_Exchange_Rate__c=7.77500, ASI_MFM_Counter_Currency__c='USD', ASI_MFM_Base_Currency__c='RMB',
                                                                       ASI_MFM_Application__c='MFM' );
            insert ex;
            
            //create po
            Date today = Date.today();
            Date startDate;
            if(today.month() >=7) {
                startDate = Date.newInstance(today.year(), 7, 1);
            } else  {
                startDate = Date.newInstance(today.addYears(-1).year(), 7, 1);
            }
            Date endDate;
            if(today.month() >=7) {
                endDate = Date.newInstance(today.addYears(1).year(), 6, 30);
            } else  {
                endDate = Date.newInstance(today.year(), 6, 30);
            }
            
            strRTId =ASI_MFM_Function.checkRecordType('ASI_MFM_PO__c','ASI_MFM_CN_PO');
            List<ASI_MFM_PO__c> ltPO = new List<ASI_MFM_PO__c>();
            /*
            ASI_MFM_PO__c po = new ASI_MFM_PO__c(Name='PO11111', RecordTypeId=strRTId , ASI_MFM_Prefix__c=prefixs[1].id, ASI_MFM_Remarks__c='Remarks',
                                                 ASI_MFM_BU_Code__c=bu.id, ASI_MFM_CN_BU_Picklist__c='PRCN', ASI_MFM_Supplier_Name__c=accs[1].id, ASI_MFM_Currency__c='USD',
                                                 ASI_MFM_PO_Start_Date__c=startDate,ASI_MFM_PO_End_Date__c=endDate,
                                                 ASI_MFM_Budget_Owner__c =user1.id, ASI_MFM_Plan__c=Plan1.id,
                                                 ASI_MFM_PO_Type__c='Other',ASI_MFM_Status__c='Final',ASI_MFM_From_eMarket__c=TRUE);
            */
            ltPO.add(new ASI_MFM_PO__c(Name='PO11111', RecordTypeId=strRTId , ASI_MFM_Prefix__c=prefixs[1].id, ASI_MFM_Remarks__c='Remarks',
                                                 ASI_MFM_BU_Code__c=bu.id, ASI_MFM_CN_BU_Picklist__c='PRCN', ASI_MFM_Supplier_Name__c=accs[1].id, ASI_MFM_Currency__c='USD',
                                                 ASI_MFM_PO_Start_Date__c=startDate,ASI_MFM_PO_End_Date__c=endDate,
                                                 ASI_MFM_Budget_Owner__c =user1.id, ASI_MFM_Plan__c=Plan1.id,
                                                 ASI_MFM_PO_Type__c='Other',ASI_MFM_Status__c='Final',ASI_MFM_From_eMarket__c=TRUE));
            ltPO.add(new ASI_MFM_PO__c(Name='PO11112', RecordTypeId=strRTId , ASI_MFM_Prefix__c=prefixs[1].id, ASI_MFM_Remarks__c='Remarks',
                                                 ASI_MFM_BU_Code__c=bu.id, ASI_MFM_CN_BU_Picklist__c='PRCN', ASI_MFM_Supplier_Name__c=accs[1].id, ASI_MFM_Currency__c='USD',
                                                 ASI_MFM_PO_Start_Date__c=startDate,ASI_MFM_PO_End_Date__c=endDate,
                                                 ASI_MFM_Budget_Owner__c =user1.id, ASI_MFM_Plan__c=Plan1.id,
                                                 ASI_MFM_PO_Type__c='Other',ASI_MFM_Status__c='Final',ASI_MFM_From_eMarket__c=TRUE)
            );
            insert ltPO;
            
            
            //create po line item
            strRTId =ASI_MFM_Function.checkRecordType('ASI_MFM_PO_Line_Item__c','ASI_MFM_CN_PO_Line_Item');
            List<ASI_MFM_PO_Line_Item__c> ltPOL = new List<ASI_MFM_PO_Line_Item__c>();
            /*
            ASI_MFM_PO_Line_Item__c poli = new ASI_MFM_PO_Line_Item__c(RecordTypeId=strRTId, ASI_MFM_PO__c=ltPO[0].id, ASI_MFM_G_L_Date__c=date.valueof('2014-04-03'),ASI_MFM_Sub_brand_Code__c=subBrands[2].id,
                                                                       ASI_MFM_A_C_Code__c = acs[2].id, ASI_MFM_Customer_Name__c=accs[0].id, ASI_MFM_Amount__c =510000,ASI_MFM_From_eMarket__c=TRUE);
			*/            
			ltPOL.add(new ASI_MFM_PO_Line_Item__c(RecordTypeId=strRTId, ASI_MFM_PO__c=ltPO[0].id, ASI_MFM_G_L_Date__c=date.valueof('2014-04-03'),ASI_MFM_Sub_brand_Code__c=subBrands[2].id,
                                                                       ASI_MFM_A_C_Code__c = acs[2].id, ASI_MFM_Customer_Name__c=accs[0].id, ASI_MFM_Amount__c =510000,ASI_MFM_From_eMarket__c=TRUE));
            ltPOL.add(new ASI_MFM_PO_Line_Item__c(RecordTypeId=strRTId, ASI_MFM_PO__c=ltPO[1].id, ASI_MFM_G_L_Date__c=date.valueof('2014-04-03'),ASI_MFM_Sub_brand_Code__c=subBrands[2].id,
                                                                       ASI_MFM_A_C_Code__c = acs[2].id, ASI_MFM_Customer_Name__c=accs[0].id, ASI_MFM_Amount__c =220000,ASI_MFM_From_eMarket__c=TRUE)
            );
            insert ltPOL;
            
            //Test.startTest();
            
            /*
            ApexPages.currentPage().getParameters().put('id',po.Id);
            ApexPages.Standardcontroller stdController = new ApexPages.Standardcontroller(po);
            ASI_MFM_CN_InputPOReceiptPhasingCtl controller = new ASI_MFM_CN_InputPOReceiptPhasingCtl(stdController); 
            
            startDate.format();
            endDate.format();
            String submitStr = '{"submitedList":[{"amount1":43315.07,"amount2":39123.29,"amount3":43315.07,"amount4":41917.81,"amount5":43315.07,"amount6":28547.93,"amount7":0,"amount8":100000,"amount9":41917.81,"amount10":43315.07,"amount11":41917.81,"amount12":43315.07,"comment":"","total":510000,"version":1,"modify":"SYSTEM","postart":"'+startDate.format()+'","poend":"'+endDate.format()+'","id":"","poid":"'+po.id+'","rowcontrol":0,"approved":false},{"amount1":43315.07,"amount2":39123.29,"amount3":43315.07,"amount4":41917.81,"amount5":43315.07,"amount6":28547.93,"amount7":0,"amount8":100000,"amount9":41917.81,"amount10":43315.07,"amount11":41917.81,"amount12":43315.07,"comment":"","total":510000,"version":2,"modify":"Admin Introv 2","postart":"'+startDate.format()+'","poend":"'+endDate.format()+'","id":"","poid":"'+po.id+'","rowcontrol":0,"approved":false}],"deleteIdList":[],"poid":"'+po.id+'"}';
            ASI_MFM_CN_InputPOReceiptPhasingCtl.ResultObj resultObj = ASI_MFM_CN_InputPOReceiptPhasingCtl.validate(submitStr);
            system.debug('result : ' + JSON.serialize(resultObj));
            */
            
            tmpLTPO = ltPO;
            tmpStartDate = startDate;
            tmpEndDate = endDate;
            
            /*
            Id phasingRTID = Global_recordTypeCache.getRtId('ASI_MFM_PO_Receipt_Phasing__cASI_MFM_CN_PO_Receipt_Phasing');
            ASI_MFM_PO_Receipt_Phasing__c porp1 = new ASI_MFM_PO_Receipt_Phasing__c(
                ASI_MFM_Latest_Phasing__c = false,
                ASI_MFM_Version__c = '1',
                ASI_MFM_Comments__c = '',
                ASI_MFM_PO__c = ltPO[0].id,
                ASI_MFM_Modify_BY__c = 'SYSTEM',
                ASI_MFM_PO_Approved__c = false,
                ASI_MFM_Allocated_Amount_1__c = 10000,
                ASI_MFM_Allocated_Amount_2__c = 10000,
                ASI_MFM_Allocated_Amount_3__c = 10000,
                ASI_MFM_Allocated_Amount_4__c = 10000,
                ASI_MFM_Allocated_Amount_5__c = 10000,
                ASI_MFM_Allocated_Amount_6__c = 10000,
                ASI_MFM_Allocated_Amount_7__c = 10000,
                ASI_MFM_Allocated_Amount_8__c = 10000,
                ASI_MFM_Allocated_Amount_9__c = 10000,
                ASI_MFM_Allocated_Amount_10__c = 10000,
                ASI_MFM_Allocated_Amount_11__c = 10000,
                ASI_MFM_Allocated_Amount_12__c = 10000,
                ASI_MFM_PO_Start_Date__c = startDate,
                ASI_MFM_PO_End_Date__c = endDate,
                ASI_MFM_Create_Date__c = System.now(),
                RecordTypeId = phasingRTID);
            ASI_MFM_PO_Receipt_Phasing__c porp2 = new ASI_MFM_PO_Receipt_Phasing__c(
                ASI_MFM_Latest_Phasing__c = TRUE,
                ASI_MFM_Version__c = '2',
                ASI_MFM_Comments__c = 'ttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttt ttt t t',
                ASI_MFM_PO__c = ltPO[0].id,
                ASI_MFM_Modify_BY__c = 'testUser',
                ASI_MFM_PO_Approved__c = false,
                ASI_MFM_Allocated_Amount_1__c = 10000,
                ASI_MFM_Allocated_Amount_2__c = 10000,
                ASI_MFM_Allocated_Amount_3__c = 10000,
                ASI_MFM_Allocated_Amount_4__c = 10000,
                ASI_MFM_Allocated_Amount_5__c = 10000,
                ASI_MFM_Allocated_Amount_6__c = 10000,
                ASI_MFM_Allocated_Amount_7__c = 10000,
                ASI_MFM_Allocated_Amount_8__c = 10000,
                ASI_MFM_Allocated_Amount_9__c = 10000,
                ASI_MFM_Allocated_Amount_10__c = 10000,
                ASI_MFM_Allocated_Amount_11__c = 10000,
                ASI_MFM_Allocated_Amount_12__c = 10000,
                ASI_MFM_PO_Start_Date__c = startDate,
                ASI_MFM_PO_End_Date__c = endDate,
                ASI_MFM_Create_Date__c = System.now(),
                RecordTypeId = phasingRTID);
            
            List<ASI_MFM_PO_Receipt_Phasing__c> receiptPhasingList = new List<ASI_MFM_PO_Receipt_Phasing__c>{porp1,porp2};
            
            receiptPhasingList.add(new ASI_MFM_PO_Receipt_Phasing__c(
                ASI_MFM_Latest_Phasing__c = FALSE,
                ASI_MFM_Version__c = '1',
                ASI_MFM_Comments__c = 'ttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttt ttt t t',
                ASI_MFM_PO__c = ltPO[1].id,
                ASI_MFM_Modify_BY__c = 'testUser',
                ASI_MFM_PO_Approved__c = false,
                ASI_MFM_Allocated_Amount_1__c = 10000,
                ASI_MFM_Allocated_Amount_2__c = 10000,
                ASI_MFM_Allocated_Amount_3__c = 10000,
                ASI_MFM_Allocated_Amount_4__c = 10000,
                ASI_MFM_Allocated_Amount_5__c = 10000,
                ASI_MFM_Allocated_Amount_6__c = 10000,
                ASI_MFM_Allocated_Amount_7__c = 10000,
                ASI_MFM_Allocated_Amount_8__c = 10000,
                ASI_MFM_Allocated_Amount_9__c = 10000,
                ASI_MFM_Allocated_Amount_10__c = 10000,
                ASI_MFM_Allocated_Amount_11__c = 10000,
                ASI_MFM_Allocated_Amount_12__c = 10000,
                ASI_MFM_PO_Start_Date__c = startDate,
                ASI_MFM_PO_End_Date__c = endDate,
                ASI_MFM_Create_Date__c = System.now(),
                RecordTypeId = phasingRTID));
            receiptPhasingList.add(new ASI_MFM_PO_Receipt_Phasing__c(
                ASI_MFM_Latest_Phasing__c = TRUE,
                ASI_MFM_Version__c = '2',
                ASI_MFM_Comments__c = 'ttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttt ttt t t',
                ASI_MFM_PO__c = ltPO[1].id,
                ASI_MFM_Modify_BY__c = 'testUser',
                ASI_MFM_PO_Approved__c = false,
                ASI_MFM_Allocated_Amount_1__c = 10000,
                ASI_MFM_Allocated_Amount_2__c = 10000,
                ASI_MFM_Allocated_Amount_3__c = 10000,
                ASI_MFM_Allocated_Amount_4__c = 10000,
                ASI_MFM_Allocated_Amount_5__c = 10000,
                ASI_MFM_Allocated_Amount_6__c = 10000,
                ASI_MFM_Allocated_Amount_7__c = 10000,
                ASI_MFM_Allocated_Amount_8__c = 10000,
                ASI_MFM_Allocated_Amount_9__c = 10000,
                ASI_MFM_Allocated_Amount_10__c = 10000,
                ASI_MFM_Allocated_Amount_11__c = 10000,
                ASI_MFM_Allocated_Amount_12__c = 10000,
                ASI_MFM_PO_Start_Date__c = startDate,
                ASI_MFM_PO_End_Date__c = endDate,
                ASI_MFM_Create_Date__c = System.now(),
                RecordTypeId = phasingRTID));
            receiptPhasingList.add(new ASI_MFM_PO_Receipt_Phasing__c(
                ASI_MFM_Latest_Phasing__c = FALSE,
                ASI_MFM_Version__c = '3',
                ASI_MFM_Comments__c = 'ttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttt ttt t t',
                ASI_MFM_PO__c = ltPO[1].id,
                ASI_MFM_Modify_BY__c = 'testUser',
                ASI_MFM_PO_Approved__c = false,
                ASI_MFM_Allocated_Amount_1__c = 10000,
                ASI_MFM_Allocated_Amount_2__c = 10000,
                ASI_MFM_Allocated_Amount_3__c = 10000,
                ASI_MFM_Allocated_Amount_4__c = 10000,
                ASI_MFM_Allocated_Amount_5__c = 10000,
                ASI_MFM_Allocated_Amount_6__c = 10000,
                ASI_MFM_Allocated_Amount_7__c = 10000,
                ASI_MFM_Allocated_Amount_8__c = 10000,
                ASI_MFM_Allocated_Amount_9__c = 10000,
                ASI_MFM_Allocated_Amount_10__c = 10000,
                ASI_MFM_Allocated_Amount_11__c = 10000,
                ASI_MFM_Allocated_Amount_12__c = 10000,
                ASI_MFM_PO_Start_Date__c = startDate,
                ASI_MFM_PO_End_Date__c = endDate,
                ASI_MFM_Create_Date__c = System.now(),
                RecordTypeId = phasingRTID));
            receiptPhasingList.add(new ASI_MFM_PO_Receipt_Phasing__c(
                ASI_MFM_Latest_Phasing__c = TRUE,
                ASI_MFM_Version__c = '4',
                ASI_MFM_Comments__c = 'ttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttt ttt t t',
                ASI_MFM_PO__c = ltPO[1].id,
                ASI_MFM_Modify_BY__c = 'testUser',
                ASI_MFM_PO_Approved__c = false,
                ASI_MFM_Allocated_Amount_1__c = 10000,
                ASI_MFM_Allocated_Amount_2__c = 10000,
                ASI_MFM_Allocated_Amount_3__c = 10000,
                ASI_MFM_Allocated_Amount_4__c = 10000,
                ASI_MFM_Allocated_Amount_5__c = 10000,
                ASI_MFM_Allocated_Amount_6__c = 10000,
                ASI_MFM_Allocated_Amount_7__c = 10000,
                ASI_MFM_Allocated_Amount_8__c = 10000,
                ASI_MFM_Allocated_Amount_9__c = 10000,
                ASI_MFM_Allocated_Amount_10__c = 10000,
                ASI_MFM_Allocated_Amount_11__c = 10000,
                ASI_MFM_Allocated_Amount_12__c = 10000,
                ASI_MFM_PO_Start_Date__c = startDate,
                ASI_MFM_PO_End_Date__c = endDate,
                ASI_MFM_Create_Date__c = System.now(),
                RecordTypeId = phasingRTID));
            
            insert receiptPhasingList;
			*/
            //Test.stopTest();
            
            //ASI_MFM_CN_InputPOReceiptPhasingCtl.ReceiptPhasing rp1 = new ASI_MFM_CN_InputPOReceiptPhasingCtl.ReceiptPhasing(porp1);
            //ASI_MFM_CN_InputPOReceiptPhasingCtl.ReceiptPhasing rp2 = new ASI_MFM_CN_InputPOReceiptPhasingCtl.ReceiptPhasing(porp2);
            /*
            String fy = 'FY' + (date.today().month() < 7 ? String.valueOf(date.today().addYears(-1).year() - 2000) + String.valueOf(date.today().year() - 2000) : String.valueOf(date.today().year() - 2000) + String.valueOf(date.today().addYears(1).year() - 2000));
            Date thisMonth = date.newInstance(date.today().year(), date.today().month(), 1);
            List<ASI_MFM_PO_Receipt_Phasing__c> phasingList= [SELECT id, name, ASI_MFM_Last_Receipt_Date__c, ASI_MFM_Amount_Total__c, ASI_MFM_PO__c,ASI_MFM_PO__r.ASI_MFM_PO_Amount__c
                                                          ,ASI_MFM_Allocated_Amount_8__c,ASI_MFM_Allocated_Amount_9__c
                                                          ,ASI_MFM_Allocated_Amount_10__c,ASI_MFM_Allocated_Amount_11__c
                                                          ,ASI_MFM_Allocated_Amount_12__c, ASI_MFM_Allocated_Amount_1__c
                                                          ,ASI_MFM_Allocated_Amount_2__c,ASI_MFM_Allocated_Amount_3__c
                                                          ,ASI_MFM_Allocated_Amount_4__c,ASI_MFM_Allocated_Amount_5__c
                                                          ,ASI_MFM_Allocated_Amount_6__c,ASI_MFM_Allocated_Amount_7__c
                                                          FROM ASI_MFM_PO_Receipt_Phasing__c
                                                          WHERE ASI_MFM_Latest_Phasing__c = True 
                                                          AND (ASI_MFM_Last_Receipt_Date__c < :thisMonth OR ASI_MFM_Last_Receipt_Date__c = Null)
                                                          AND ASI_MFM_PO__r.ASI_MFM_Prefix__r.ASI_MFM_Fiscal_year__c Like :fy 
                                                          AND ASI_MFM_PO__r.ASI_MFM_Supplier_Name__r.ASI_MFM_Customer_Supplier_Number__c != '61202305' 
                                                          AND (NOT ASI_MFM_PO__r.ASI_MFM_PO_Type__c IN ('EMARKET','IT CAPEX HARDWARE HQ','IT CAPEX HARDWARE REGION','IT CAPEX RENOVATION','IT CAPEX SOFTWARE','IT OPEX'))  
                                                          AND ASI_MFM_PO__r.ASI_MFM_BU_Code__r.ASI_MFM_Auto_Receipt__c = True 
                                                          AND ASI_MFM_PO__r.ASI_MFM_Fully_Receipted__c = False 
                                                          AND ASI_MFM_PO__r.ASI_MFM_Status__c Like 'Final'
                                                          ORDER BY ASI_MFM_Last_Receipt_Date__c desc];
            system.debug('phasingList-FY:'+fy);
            system.debug('phasingList:'+phasingList.size());
            */
            /*
            ASI_MFM_PO_Receipt_Phasing__c checkphasing= [SELECT id, name 
                                                                   , ASI_MFM_Latest_Phasing__c, ASI_MFM_Last_Receipt_Date__c, ASI_MFM_PO__r.ASI_MFM_Prefix__r.ASI_MFM_Fiscal_year__c, ASI_MFM_PO__r.ASI_MFM_Supplier_Name__r.ASI_MFM_Customer_Supplier_Number__c
                                                                   , ASI_MFM_PO__r.ASI_MFM_PO_Type__c, ASI_MFM_PO__r.ASI_MFM_BU_Code__r.ASI_MFM_Auto_Receipt__c, ASI_MFM_PO__r.ASI_MFM_Fully_Receipted__c, ASI_MFM_PO__r.ASI_MFM_Status__c
                                                          FROM ASI_MFM_PO_Receipt_Phasing__c
                                                          WHERE ID = :receiptPhasingList[1].id];
            system.debug('phasingList-checkphasing:'+checkphasing.ASI_MFM_Latest_Phasing__c);
            system.debug('phasingList-checkphasing:'+checkphasing.ASI_MFM_Last_Receipt_Date__c);
            system.debug('phasingList-checkphasing:'+checkphasing.ASI_MFM_PO__r.ASI_MFM_Prefix__r.ASI_MFM_Fiscal_year__c);
            system.debug('phasingList-checkphasing:'+checkphasing.ASI_MFM_PO__r.ASI_MFM_Supplier_Name__r.ASI_MFM_Customer_Supplier_Number__c);
            system.debug('phasingList-checkphasing:'+checkphasing.ASI_MFM_PO__r.ASI_MFM_PO_Type__c);
            system.debug('phasingList-checkphasing:'+checkphasing.ASI_MFM_PO__r.ASI_MFM_BU_Code__r.ASI_MFM_Auto_Receipt__c);
            system.debug('phasingList-checkphasing:'+checkphasing.ASI_MFM_PO__r.ASI_MFM_Fully_Receipted__c);
            system.debug('phasingList-checkphasing:'+checkphasing.ASI_MFM_PO__r.ASI_MFM_Status__c);
			*/
        }
        
        public void createPhasingList() {
            Id phasingRTID = Global_recordTypeCache.getRtId('ASI_MFM_PO_Receipt_Phasing__cASI_MFM_CN_PO_Receipt_Phasing');
            ASI_MFM_PO_Receipt_Phasing__c porp1 = new ASI_MFM_PO_Receipt_Phasing__c(
                ASI_MFM_Latest_Phasing__c = false,
                ASI_MFM_Version__c = '1',
                ASI_MFM_Comments__c = '',
                ASI_MFM_PO__c = tmpLTPO[0].id,
                ASI_MFM_Modify_BY__c = 'SYSTEM',
                ASI_MFM_PO_Approved__c = false,
                ASI_MFM_Allocated_Amount_1__c = 10000,
                ASI_MFM_Allocated_Amount_2__c = 10000,
                ASI_MFM_Allocated_Amount_3__c = 10000,
                ASI_MFM_Allocated_Amount_4__c = 10000,
                ASI_MFM_Allocated_Amount_5__c = 10000,
                ASI_MFM_Allocated_Amount_6__c = 10000,
                ASI_MFM_Allocated_Amount_7__c = 10000,
                ASI_MFM_Allocated_Amount_8__c = 10000,
                ASI_MFM_Allocated_Amount_9__c = 10000,
                ASI_MFM_Allocated_Amount_10__c = 10000,
                ASI_MFM_Allocated_Amount_11__c = 10000,
                ASI_MFM_Allocated_Amount_12__c = 10000,
                ASI_MFM_PO_Start_Date__c = tmpStartDate,
                ASI_MFM_PO_End_Date__c = tmpEndDate,
                ASI_MFM_Create_Date__c = System.now(),
                RecordTypeId = phasingRTID);
            ASI_MFM_PO_Receipt_Phasing__c porp2 = new ASI_MFM_PO_Receipt_Phasing__c(
                ASI_MFM_Latest_Phasing__c = TRUE,
                ASI_MFM_Version__c = '2',
                ASI_MFM_Comments__c = 'ttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttt ttt t t',
                ASI_MFM_PO__c = tmpLTPO[0].id,
                ASI_MFM_Modify_BY__c = 'testUser',
                ASI_MFM_PO_Approved__c = false,
                ASI_MFM_Allocated_Amount_1__c = 10000,
                ASI_MFM_Allocated_Amount_2__c = 10000,
                ASI_MFM_Allocated_Amount_3__c = 10000,
                ASI_MFM_Allocated_Amount_4__c = 10000,
                ASI_MFM_Allocated_Amount_5__c = 10000,
                ASI_MFM_Allocated_Amount_6__c = 10000,
                ASI_MFM_Allocated_Amount_7__c = 10000,
                ASI_MFM_Allocated_Amount_8__c = 10000,
                ASI_MFM_Allocated_Amount_9__c = 10000,
                ASI_MFM_Allocated_Amount_10__c = 10000,
                ASI_MFM_Allocated_Amount_11__c = 10000,
                ASI_MFM_Allocated_Amount_12__c = 10000,
                ASI_MFM_PO_Start_Date__c = tmpStartDate,
                ASI_MFM_PO_End_Date__c = tmpEndDate,
                ASI_MFM_Create_Date__c = System.now(),
                RecordTypeId = phasingRTID);
            
            List<ASI_MFM_PO_Receipt_Phasing__c> receiptPhasingList = new List<ASI_MFM_PO_Receipt_Phasing__c>{porp1,porp2};
            
            receiptPhasingList.add(new ASI_MFM_PO_Receipt_Phasing__c(
                ASI_MFM_Latest_Phasing__c = FALSE,
                ASI_MFM_Version__c = '1',
                ASI_MFM_Comments__c = 'ttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttt ttt t t',
                ASI_MFM_PO__c = tmpLTPO[1].id,
                ASI_MFM_Modify_BY__c = 'testUser',
                ASI_MFM_PO_Approved__c = false,
                ASI_MFM_Allocated_Amount_1__c = 10000,
                ASI_MFM_Allocated_Amount_2__c = 10000,
                ASI_MFM_Allocated_Amount_3__c = 10000,
                ASI_MFM_Allocated_Amount_4__c = 10000,
                ASI_MFM_Allocated_Amount_5__c = 10000,
                ASI_MFM_Allocated_Amount_6__c = 10000,
                ASI_MFM_Allocated_Amount_7__c = 10000,
                ASI_MFM_Allocated_Amount_8__c = 10000,
                ASI_MFM_Allocated_Amount_9__c = 10000,
                ASI_MFM_Allocated_Amount_10__c = 10000,
                ASI_MFM_Allocated_Amount_11__c = 10000,
                ASI_MFM_Allocated_Amount_12__c = 10000,
                ASI_MFM_PO_Start_Date__c = tmpStartDate,
                ASI_MFM_PO_End_Date__c = tmpEndDate,
                ASI_MFM_Create_Date__c = System.now(),
                RecordTypeId = phasingRTID));
            receiptPhasingList.add(new ASI_MFM_PO_Receipt_Phasing__c(
                ASI_MFM_Latest_Phasing__c = TRUE,
                ASI_MFM_Version__c = '2',
                ASI_MFM_Comments__c = 'ttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttt ttt t t',
                ASI_MFM_PO__c = tmpLTPO[1].id,
                ASI_MFM_Modify_BY__c = 'testUser',
                ASI_MFM_PO_Approved__c = false,
                ASI_MFM_Allocated_Amount_1__c = 10000,
                ASI_MFM_Allocated_Amount_2__c = 10000,
                ASI_MFM_Allocated_Amount_3__c = 10000,
                ASI_MFM_Allocated_Amount_4__c = 10000,
                ASI_MFM_Allocated_Amount_5__c = 10000,
                ASI_MFM_Allocated_Amount_6__c = 10000,
                ASI_MFM_Allocated_Amount_7__c = 10000,
                ASI_MFM_Allocated_Amount_8__c = 10000,
                ASI_MFM_Allocated_Amount_9__c = 10000,
                ASI_MFM_Allocated_Amount_10__c = 10000,
                ASI_MFM_Allocated_Amount_11__c = 10000,
                ASI_MFM_Allocated_Amount_12__c = 10000,
                ASI_MFM_PO_Start_Date__c = tmpStartDate,
                ASI_MFM_PO_End_Date__c = tmpEndDate,
                ASI_MFM_Create_Date__c = System.now(),
                RecordTypeId = phasingRTID));
            receiptPhasingList.add(new ASI_MFM_PO_Receipt_Phasing__c(
                ASI_MFM_Latest_Phasing__c = FALSE,
                ASI_MFM_Version__c = '3',
                ASI_MFM_Comments__c = 'ttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttt ttt t t',
                ASI_MFM_PO__c = tmpLTPO[1].id,
                ASI_MFM_Modify_BY__c = 'testUser',
                ASI_MFM_PO_Approved__c = false,
                ASI_MFM_Allocated_Amount_1__c = 10000,
                ASI_MFM_Allocated_Amount_2__c = 10000,
                ASI_MFM_Allocated_Amount_3__c = 10000,
                ASI_MFM_Allocated_Amount_4__c = 10000,
                ASI_MFM_Allocated_Amount_5__c = 10000,
                ASI_MFM_Allocated_Amount_6__c = 10000,
                ASI_MFM_Allocated_Amount_7__c = 10000,
                ASI_MFM_Allocated_Amount_8__c = 10000,
                ASI_MFM_Allocated_Amount_9__c = 10000,
                ASI_MFM_Allocated_Amount_10__c = 10000,
                ASI_MFM_Allocated_Amount_11__c = 10000,
                ASI_MFM_Allocated_Amount_12__c = 10000,
                ASI_MFM_PO_Start_Date__c = tmpStartDate,
                ASI_MFM_PO_End_Date__c = tmpEndDate,
                ASI_MFM_Create_Date__c = System.now(),
                RecordTypeId = phasingRTID));
            receiptPhasingList.add(new ASI_MFM_PO_Receipt_Phasing__c(
                ASI_MFM_Latest_Phasing__c = TRUE,
                ASI_MFM_Version__c = '4',
                ASI_MFM_Comments__c = 'ttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttt ttt t t',
                ASI_MFM_PO__c = tmpLTPO[1].id,
                ASI_MFM_Modify_BY__c = 'testUser',
                ASI_MFM_PO_Approved__c = false,
                ASI_MFM_Allocated_Amount_1__c = 10000,
                ASI_MFM_Allocated_Amount_2__c = 10000,
                ASI_MFM_Allocated_Amount_3__c = 10000,
                ASI_MFM_Allocated_Amount_4__c = 10000,
                ASI_MFM_Allocated_Amount_5__c = 10000,
                ASI_MFM_Allocated_Amount_6__c = 10000,
                ASI_MFM_Allocated_Amount_7__c = 10000,
                ASI_MFM_Allocated_Amount_8__c = 10000,
                ASI_MFM_Allocated_Amount_9__c = 10000,
                ASI_MFM_Allocated_Amount_10__c = 10000,
                ASI_MFM_Allocated_Amount_11__c = 10000,
                ASI_MFM_Allocated_Amount_12__c = 10000,
                ASI_MFM_PO_Start_Date__c = tmpStartDate,
                ASI_MFM_PO_End_Date__c = tmpEndDate,
                ASI_MFM_Create_Date__c = System.now(),
                RecordTypeId = phasingRTID));
            
            insert receiptPhasingList;
        }
	}
    
	Static Testmethod Void testCtrl(){
        ASI_MFM_CN_PO_SetPlan_TriggerClass.passTrigger = true;
        ASI_MFM_CN_POLine_SetPlan_TriggerClass.passTrigger = true;
        ASI_MFM_CN_PlanLine_TriggerClass.passTrigger = true;
        
        TestObj testObj = new TestObj();
        
        User User1 = testObj.user1;
        System.runAs(user1){
            Test.startTest();
            
            testObj.createPhasingList();
            ASI_MFM_CN_AutoReceipt_AdminCtrl oCtrl = new ASI_MFM_CN_AutoReceipt_AdminCtrl();
            oCtrl.startReceiptJob();
            String[] ltStatusMsg = oCtrl.StatusMsgs;
            string sErrorMsg = oCtrl.CheckAutoReceiptDebug();
            Test.stopTest();
        }
    }
    
    Static Testmethod Void testCtrl2(){
        ASI_MFM_CN_PO_SetPlan_TriggerClass.passTrigger = true;
        ASI_MFM_CN_POLine_SetPlan_TriggerClass.passTrigger = true;
        ASI_MFM_CN_PlanLine_TriggerClass.passTrigger = true;
        
        TestObj testObj = new TestObj();
        
        User User1 = testObj.user1;
        System.runAs(user1){
            Test.startTest();

            ASI_MFM_CN_AutoReceipt_AdminCtrl oCtrl = new ASI_MFM_CN_AutoReceipt_AdminCtrl();
            oCtrl.startEmarketJob();
			oCtrl.startIVJunctionJob();
            oCtrl.startIVJunctionValueJob();
            oCtrl.startIVClearSummaryJob();
            oCtrl.startIVClearDetailsJob();
            
            oCtrl.startIVJunctionDJob();
            oCtrl.startIVJunctionDValueJob();
            oCtrl.startIVClearSummaryDJob();
            oCtrl.startIVClearDetailsDJob();
            oCtrl.startIVJClearLineJob();
            oCtrl.startIVJDClearLineDJob();

            Test.stopTest();
        }
    }
    
    Static Testmethod Void testCtrl_FOC_CheckAutoReject(){
        ASI_MFM_CN_PO_SetPlan_TriggerClass.passTrigger = true;
        ASI_MFM_CN_POLine_SetPlan_TriggerClass.passTrigger = true;
        ASI_MFM_CN_PlanLine_TriggerClass.passTrigger = true;
        
        TestObj testObj = new TestObj();
        
        User User1 = testObj.user1;
        System.runAs(user1){
            Test.startTest();

            ASI_MFM_CN_AutoReceipt_AdminCtrl oCtrl = new ASI_MFM_CN_AutoReceipt_AdminCtrl();
            oCtrl.startFOCAutoRejectJob();
			
            database.executebatch(new ASI_FOC_CN_CheckAutoReject_Batch());
            
            Test.stopTest();
        }
    }
    
    Static Testmethod Void testCtrl_FOC_CheckAutoReject_TEST(){
        ASI_MFM_CN_PO_SetPlan_TriggerClass.passTrigger = true;
        ASI_MFM_CN_POLine_SetPlan_TriggerClass.passTrigger = true;
        ASI_MFM_CN_PlanLine_TriggerClass.passTrigger = true;
        
        TestObj testObj = new TestObj();
        
        User User1 = testObj.user1;
        System.runAs(user1){
            TestData testdata = new TestData();
            testdata.initSecond();
            Test.startTest();
            testdata.initThird(user1.id);
            ASI_MFM_CN_POSMCatalog_CTRL cls = new ASI_MFM_CN_POSMCatalog_CTRL();
			
            Map<String, Object> resultCart = ASI_MFM_CN_POSMCatalog_CTRL.retrieveShoppingCart();
            ASI_FOC_Free_Goods_Request__c cart = (ASI_FOC_Free_Goods_Request__c)resultCart.get('cart');
            ASI_MFM_CN_POSMCatalog_CTRL.removeAllItemFromCart(cart.id);
            
            ASI_MFM_CN_POSMCatalog_CTRL.LotObject lotreq1 = new ASI_MFM_CN_POSMCatalog_CTRL.LotObject();
            lotreq1.qty = 1;
            ASI_MFM_CN_POSMCatalog_CTRL.LotObject lotreq2 = new ASI_MFM_CN_POSMCatalog_CTRL.LotObject();
            lotreq2.qty = 1;
            Map<String,ASI_MFM_CN_POSMCatalog_CTRL.LotObject> mapItem = new Map<String,ASI_MFM_CN_POSMCatalog_CTRL.LotObject>{testdata.ibdList[0].id=>lotreq1,testdata.ibdList[1].id=>lotreq2};
			ASI_MFM_CN_POSMCatalog_CTRL.ResultObj resultAddItem = ASI_MFM_CN_POSMCatalog_CTRL.addItemToCart(cart.id, mapItem);
            List<ASI_FOC_Request_Item__c> updatedItemList = (List<ASI_FOC_Request_Item__c>)resultAddItem.updatedItemList;
            
            ASI_MFM_CN_POSMCatalog_CTRL.saveCart(cart.id, testdata.warehouseList[0].id, testdata.warehouseList[1].id, '', '', testdata.dzoneList[0].id, testdata.regionList[0].id, testdata.cityList[0].id
                                       , 'add123', 'add456', 'chan', '987654323', 'Gift', ''
                                       , '01/01/4000', '9:00-12:00', 'reason', 'di', 4, 'abc@aa.com','','');
            ASI_MFM_CN_POSMCatalog_CTRL.submitCart(cart.id, testdata.warehouseList[0].id, testdata.warehouseList[1].id,false, '', '', testdata.dzoneList[0].id, testdata.regionList[0].id, testdata.cityList[0].id
                                       , 'add123', 'add456', 'chan', '987654323', 'Gift', ''
                                       , '01/01/4000', '9:00-12:00', 'reason', 'di', 4, 'abc@aa.com','','','');
            
            List<ASI_FOC_Free_Goods_Request__c> ltTmpHeader = new List<ASI_FOC_Free_Goods_Request__c>();
            ltTmpHeader.add(cart);
            
			ASI_FOC_CN_CheckAutoReject_Batch oBatch = new ASI_FOC_CN_CheckAutoReject_Batch();
            oBatch.execute(null, ltTmpHeader);
            
            
            Test.stopTest();
        }
    }
    
}