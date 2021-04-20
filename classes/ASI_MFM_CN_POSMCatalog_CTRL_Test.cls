@IsTest
public class ASI_MFM_CN_POSMCatalog_CTRL_Test {
    
    Private Static Final String BRAND_RECORDTYPE_ID = Global_RecordTypeCache.getRtId('ASI_MFM_Brand__cASI_FOC_CN_Brand');
    Private Static Final String SUB_BRAND_RECORDTYPE_ID = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand');
    Private Static Final String CATEGORY_RECORDTYPE_ID = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Product_Category__cASI_MFM_CN_Category_Master');
    Private Static Final String ITEMGROUP_RECORDTYPE_ID = Global_RecordTypeCache.getRtId('ASI_MFM_Item_Group__cASI_MFM_CN_POSM_Item_Group');
    Private Static Final String POSM_IETMGROUP_PHOTO_RECORDTYPE_ID = Global_RecordTypeCache.getRtId('ASI_CRM_Product_Warehouse_Photo__cASI_MFM_CN_POSM_Photo'); 
    Private Static Final String CHANNEL_RECORDTYPE_ID = Global_RecordTypeCache.getRtId('ASI_CRM_CN_Channel__cASI_MFM_CN_POSM_Channel');
    
    static testMethod void testCatalogCtrlFirst() {
        list<User> users = new list<User>();
        User User1 = new User(managerid = UserInfo.getUserId(), ASI_MFM_Team__c = 'ABCD', ASI_MFM_Country__c ='CN', alias = 'test99',ASI_MFM_Bypass_Callouts__c = true, email='test99' + '@dev.com', emailencodingkey='UTF-8', firstname='test99', lastname='Testing', languagelocalekey='en_US', localesidkey='en_US', timezonesidkey='Europe/London', username='test99' + '@pernod-ricard.com',ProfileId = UserInfo.getProfileId(), UserRoleId = UserInfo.getUserRoleId(), isActive=true);
        User User2 = new User(managerid = UserInfo.getUserId(), ASI_MFM_Team__c = 'ABCD', ASI_MFM_Country__c ='CN', alias = 'tes99',ASI_MFM_Bypass_Callouts__c = true, email='tes99' + '@dev.com', emailencodingkey='UTF-8', firstname='tes99', lastname='Testing', languagelocalekey='en_US', localesidkey='en_US', timezonesidkey='Europe/London', username='tes99' + '@pernod-ricard.com',ProfileId = UserInfo.getProfileId(), UserRoleId = UserInfo.getUserRoleId(), isActive=true);
        users.add(user2);
        users.add(user1);
        insert users;
        user1 = [SELECT Id, Name, ManagerId, ASI_MFM_Bypass_Callouts__c, ASI_MFM_Country__c, UserRole.DeveloperName 
                            FROM User
                            WHERE id =: user1.id 
                            LIMIT 1];
        user2 = [SELECT Id, Name, ManagerId, ASI_MFM_Bypass_Callouts__c, ASI_MFM_Country__c, UserRole.DeveloperName 
                            FROM User
                            WHERE id =: user2.id 
                            LIMIT 1];
        
        System.runAs(user1) {
            
            Test.startTest();
            TestData testdata = new TestData();
            
            ASI_MFM_CN_POSMCatalog_CTRL cls = new ASI_MFM_CN_POSMCatalog_CTRL();
            ASI_MFM_CN_POSMCatalog_CTRL.retrieveAllItemLabel();
            ASI_MFM_CN_POSMCatalog_CTRL.retrieveAllChannels();
            ASI_MFM_CN_POSMCatalog_CTRL.retrieveAllBrands();
            ASI_MFM_CN_POSMCatalog_CTRL.retrieveAllSubBrands();
            ASI_MFM_CN_POSMCatalog_CTRL.retrieveAllCategories();
            ASI_MFM_CN_POSMCatalog_CTRL.retrieveAllPOSMItemGroup(1);
            ASI_MFM_CN_POSMCatalog_CTRL.searchPOSMItemGroup(null,new List<String>(),new List<String>(),new List<String>(),new List<String>(),new List<String>(),new List<String>(),new List<String>(),'',1);
            ASI_MFM_CN_POSMCatalog_CTRL.searchPOSMItemGroup(testdata.itemgroupList[0].id,new List<String>(),new List<String>(),new List<String>(),new List<String>(),new List<String>(),new List<String>(),new List<String>(),'',1);
            ASI_MFM_CN_POSMCatalog_CTRL.searchPOSMItemGroup(testdata.itemgroupList[1].id,new List<String>(),new List<String>(),new List<String>(),new List<String>(),new List<String>(),new List<String>(),new List<String>(),'',1);
            ASI_MFM_CN_POSMCatalog_CTRL.searchPOSMItemGroup(null,new List<String>(),new List<String>{testdata.subBrands[0].id},new List<String>{testdata.ProductCategoryList[0].id},new List<String>{testdata.ProductCategoryList[1].id},new List<String>{testdata.ProductCategoryList[2].id},new List<String>{testdata.channelList[0].id},new List<String>{testdata.brands[2].id},'111',1);
            ASI_MFM_CN_POSMCatalog_CTRL.searchPOSMItemGroup(null,new List<String>{testdata.brands[0].id},new List<String>(),new List<String>{testdata.ProductCategoryList[0].id},new List<String>{testdata.ProductCategoryList[1].id},new List<String>{testdata.ProductCategoryList[2].id},new List<String>{testdata.channelList[0].id},new List<String>{testdata.brands[1].id},'111',1);
            
            ASI_MFM_CN_POSMCatalog_CTRL.pageCount(null,new List<String>(),new List<String>(),new List<String>(),new List<String>(),new List<String>(),new List<String>(),new List<String>(),'');
            ASI_MFM_CN_POSMCatalog_CTRL.pageCount(testdata.itemgroupList[0].id,new List<String>(),new List<String>(),new List<String>(),new List<String>(),new List<String>(),new List<String>(),new List<String>(),'');
            ASI_MFM_CN_POSMCatalog_CTRL.pageCount(testdata.itemgroupList[1].id,new List<String>(),new List<String>(),new List<String>(),new List<String>(),new List<String>(),new List<String>(),new List<String>(),'');
            ASI_MFM_CN_POSMCatalog_CTRL.pageCount(null,new List<String>(),new List<String>{testdata.subBrands[0].id},new List<String>{testdata.ProductCategoryList[0].id},new List<String>{testdata.ProductCategoryList[1].id},new List<String>{testdata.ProductCategoryList[2].id},new List<String>{testdata.channelList[0].id},new List<String>{testdata.brands[2].id},'111');
            ASI_MFM_CN_POSMCatalog_CTRL.pageCount(null,new List<String>{testdata.brands[0].id},new List<String>(),new List<String>{testdata.ProductCategoryList[0].id},new List<String>{testdata.ProductCategoryList[1].id},new List<String>{testdata.ProductCategoryList[2].id},new List<String>{testdata.channelList[0].id},new List<String>{testdata.brands[1].id},'111');

            Test.stopTest();
        }
    }
    
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
    
    
    
    
    
}