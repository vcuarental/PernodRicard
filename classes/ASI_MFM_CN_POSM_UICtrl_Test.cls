@isTest
public class ASI_MFM_CN_POSM_UICtrl_Test {
    
    Private static User tempU = [select id from user where CompanyName = 'Pernod Ricard China' limit 1];
    Private Static List<ASI_MFM_Item_Group__c> tmpItemGroup = new List<ASI_MFM_Item_Group__c>();
    
    static testmethod void testTriggerClass(){
        
        Profile tempP = [SELECT Id FROM Profile WHERE Name='Standard User'];
        
        User tempU2 = new User(Alias = '666', Email='standarduser666@testorg.com', EmailEncodingKey='UTF-8', FirstName='Testing', LastName='666', LanguageLocaleKey='en_US', 
                                          		LocaleSidKey='en_US', ProfileId = tempP.Id, TimeZoneSidKey='Asia/Hong_Kong', UserName='standarduser666@testorg.com', ASI_KOR_Commission_Code__c='1234567', 
                                              CompanyName = 'testUserCompanyName', Country = 'Korea');
        
        insert tempU2;
                
        tmpItemGroup.add(new ASI_MFM_Item_Group__c(RecordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Item_Group__cASI_CRM_CN_CRM_Item_Group')
                                                   , Name = 'TestItemGroup'
                                                   , ASI_MFM_Item_Group_Code__c = 'TestItemGroupCode'
                                                   , ASI_CRM_CN_Eng_Name__c = 'TestItemGroup'
                                                   , ASI_MFM_CN_OneTimeItem__c='Yes'
                                                   , OwnerID = tempU.id
                                                  ));
        tmpItemGroup.add(new ASI_MFM_Item_Group__c(RecordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Item_Group__cASI_CRM_CN_CRM_Item_Group')
                                                   , Name = 'TestItemGroup2'
                                                   , ASI_MFM_Item_Group_Code__c = 'TestItemGroupCode2'
                                                   , ASI_CRM_CN_Eng_Name__c = 'TestItemGroup'
                                                   , ASI_MFM_CN_OneTimeItem__c='Yes'
                                                   , OwnerID = tempU.id
                                                  ));
        
        insert tmpItemGroup;
        
        List<ASI_MFM_POSMCatalogSecCtrl__c> tmpSecCtrl = new List<ASI_MFM_POSMCatalogSecCtrl__c>();
        tmpSecCtrl.add(new ASI_MFM_POSMCatalogSecCtrl__c(
            				RecordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_POSMCatalogSecCtrl__cASI_MFM_CN_POSM'),
                            ASI_MFM_ItemGroup__c = tmpItemGroup[1].id,
            				ASI_MFM_MappingType__c = 'Item Group - User',
                            ASI_MFM_CanOrderinCatalog__c = 'Yes', 
                            ASI_MFM_User__c = tempU2.id
                        ));
        insert tmpSecCtrl;
        
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
        
        List<ASI_MFM_SKU_Code__c> tmpSKUList = new List<ASI_MFM_SKU_Code__c>();
        
        ASI_MFM_SKU_Code__c tmpSku = new ASI_MFM_SKU_Code__c(ASI_MFM_Item_Group__c = tmpItemGroup[0].id 
                                                             , name = 'testSkue', ASI_MFM_SKU_Code__c = ''
                                                             , recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_SKU_Code__cASI_FOC_CN_SKU')
                                                             , ASI_CRM_Location_Owner_JDE__c = 'Testing 666');
        
        ASI_MFM_SKU_Code__c tmpSku2 = new ASI_MFM_SKU_Code__c(ASI_MFM_Item_Group__c = tmpItemGroup[0].id 
                                                              , name = 'testSkue', ASI_MFM_SKU_Code__c = 'aa'
                                                              , recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_SKU_Code__cASI_FOC_CN_POSM_SKU')
                                                              , ASI_CRM_Location_Owner_JDE__c = 'Testing 666');
        
		tmpSKUList.add(tmpSku);
        tmpSKUList.add(tmpSku2);
        
        test.startTest();
        
        insert tmpSKUList[0];
        Insert tmpSKUList[1];
        
        Test.setCurrentPage(Page.ASI_CRM_CN_ProductWarehouse_ListPage);
        Apexpages.currentPage().getParameters().put('id', tmpItemGroup[0].id);
        Apexpages.StandardController sc = new apexpages.StandardController(tmpItemGroup[0]);
        ASI_CRM_CN_ProductWarehouse_ListCTRL tmpC = new ASI_CRM_CN_ProductWarehouse_ListCTRL(sc);
        
        Test.setCurrentPage(Page.ASI_CRM_CN_ProductWareHouse_SKUListPage);
        Apexpages.currentPage().getParameters().put('id', tmpSKUList[0].id);
        Apexpages.StandardController sc2 = new apexpages.StandardController(tmpSKUList[0]);
        ASI_CRM_CN_ProductWarehouse_ListCTRL tmpC2 = new ASI_CRM_CN_ProductWarehouse_ListCTRL(sc2);
        
        ASI_MFM_SKU_Code__c tmpSku3 = new ASI_MFM_SKU_Code__c(ASI_MFM_Item_Group__c = tmpItemGroup[0].id 
                                                             , name = 'testSkue', ASI_MFM_SKU_Code__c = ''
                                                             , recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_SKU_Code__cASI_FOC_CN_POSM_SKU')
                                                             , ASI_CRM_Location_Owner_JDE__c = 'Testing 666');
        insert tmpSku3;
        ASI_MFM_CN_SKU_TriggerClass.beforeUpdateMethod(new List<ASI_MFM_SKU_Code__c>{tmpSku3},new Map<Id,ASI_MFM_SKU_Code__c>{tmpSku3.id=>tmpSku3});
        
        ASI_MFM_CN_SKU_TriggerClass.resetRunningNumber(1,0,1);
        ASI_MFM_CN_SKU_TriggerClass.runningNumber(10,1);
        
        tmpItemGroup[0].ASI_MFM_Status__c = 'Final';
        tmpItemGroup[0].ASI_MFM_CloneSecurityFrom__c = tmpItemGroup[1].id;
        update tmpItemGroup[0];
        
        test.stopTest();
        
    }
    
    static testmethod void testPOSMTriggerClass(){
        
        Profile tempP = [SELECT Id FROM Profile WHERE Name='Standard User'];
        
        User tempU2 = new User(Alias = '666', Email='standarduser666@testorg.com', EmailEncodingKey='UTF-8', FirstName='Testing', LastName='666', LanguageLocaleKey='en_US', 
                                          		LocaleSidKey='en_US', ProfileId = tempP.Id, TimeZoneSidKey='Asia/Hong_Kong', UserName='standarduser666@testorg.com', ASI_KOR_Commission_Code__c='1234567', 
                                              CompanyName = 'testUserCompanyName', Country = 'Korea');
        
        insert tempU2;
                
        tmpItemGroup.add(new ASI_MFM_Item_Group__c(RecordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Item_Group__cASI_MFM_CN_POSM_Item_Group')
                                                   , Name = 'TestItemGroup'
                                                   , ASI_MFM_Item_Group_Code__c = 'TestItemGroupCode'
                                                   , ASI_CRM_CN_Eng_Name__c = 'TestItemGroup'
                                                   , ASI_MFM_CN_OneTimeItem__c='Yes'
                                                   , OwnerID = tempU.id
                                                  ));
        tmpItemGroup.add(new ASI_MFM_Item_Group__c(RecordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Item_Group__cASI_MFM_CN_POSM_Item_Group')
                                                   , Name = 'TestItemGroup2'
                                                   , ASI_MFM_Item_Group_Code__c = 'TestItemGroupCode2'
                                                   , ASI_CRM_CN_Eng_Name__c = 'TestItemGroup'
                                                   , ASI_MFM_CN_OneTimeItem__c='Yes'
                                                   , OwnerID = tempU.id
                                                  ));
        
        insert tmpItemGroup;
        
        List<ASI_MFM_POSMCatalogSecCtrl__c> tmpSecCtrl = new List<ASI_MFM_POSMCatalogSecCtrl__c>();
        tmpSecCtrl.add(new ASI_MFM_POSMCatalogSecCtrl__c(
            				RecordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_POSMCatalogSecCtrl__cASI_MFM_CN_POSM'),
                            ASI_MFM_ItemGroup__c = tmpItemGroup[1].id,
            				ASI_MFM_MappingType__c = 'Item Group - User',
                            ASI_MFM_CanOrderinCatalog__c = 'Yes', 
                            ASI_MFM_User__c = tempU2.id
                        ));
        insert tmpSecCtrl;
        
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
        
        List<ASI_MFM_SKU_Code__c> tmpSKUList = new List<ASI_MFM_SKU_Code__c>();
        
        ASI_MFM_SKU_Code__c tmpSku = new ASI_MFM_SKU_Code__c(ASI_MFM_Item_Group__c = tmpItemGroup[0].id 
                                                             , name = 'testSkue', ASI_MFM_SKU_Code__c = ''
                                                             , recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_SKU_Code__cASI_FOC_CN_SKU')
                                                             , ASI_CRM_Location_Owner_JDE__c = 'Testing 666');
        
        ASI_MFM_SKU_Code__c tmpSku2 = new ASI_MFM_SKU_Code__c(ASI_MFM_Item_Group__c = tmpItemGroup[0].id 
                                                              , name = 'testSkue', ASI_MFM_SKU_Code__c = 'aa'
                                                              , recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_SKU_Code__cASI_FOC_CN_POSM_SKU')
                                                              , ASI_CRM_Location_Owner_JDE__c = 'Testing 666');
        
		tmpSKUList.add(tmpSku);
        tmpSKUList.add(tmpSku2);
        
        test.startTest();
        
        insert tmpSKUList[0];
        Insert tmpSKUList[1];
        
        Test.setCurrentPage(Page.ASI_CRM_CN_ProductWarehouse_ListPage);
        Apexpages.currentPage().getParameters().put('id', tmpItemGroup[0].id);
        Apexpages.StandardController sc = new apexpages.StandardController(tmpItemGroup[0]);
        ASI_CRM_CN_ProductWarehouse_ListCTRL tmpC = new ASI_CRM_CN_ProductWarehouse_ListCTRL(sc);
        
        Test.setCurrentPage(Page.ASI_CRM_CN_ProductWareHouse_SKUListPage);
        Apexpages.currentPage().getParameters().put('id', tmpSKUList[0].id);
        Apexpages.StandardController sc2 = new apexpages.StandardController(tmpSKUList[0]);
        ASI_CRM_CN_ProductWarehouse_ListCTRL tmpC2 = new ASI_CRM_CN_ProductWarehouse_ListCTRL(sc2);
        
        ASI_MFM_SKU_Code__c tmpSku3 = new ASI_MFM_SKU_Code__c(ASI_MFM_Item_Group__c = tmpItemGroup[0].id 
                                                             , name = 'testSkue', ASI_MFM_SKU_Code__c = ''
                                                             , recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_SKU_Code__cASI_FOC_CN_POSM_SKU')
                                                             , ASI_CRM_Location_Owner_JDE__c = 'Testing 666');
        insert tmpSku3;
        ASI_MFM_CN_SKU_TriggerClass.beforeUpdateMethod(new List<ASI_MFM_SKU_Code__c>{tmpSku3},new Map<Id,ASI_MFM_SKU_Code__c>{tmpSku3.id=>tmpSku3});
        
        ASI_MFM_CN_SKU_TriggerClass.resetRunningNumber(1,0,1);
        ASI_MFM_CN_SKU_TriggerClass.runningNumber(10,1);
        
        tmpItemGroup[0].ASI_MFM_Status__c = 'Final';
        tmpItemGroup[0].ASI_MFM_CloneSecurityFrom__c = tmpItemGroup[1].id;
        update tmpItemGroup[0];
        
        test.stopTest();
        
    }
    
	private static string getFiscalYear(){
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

    private static ASI_MFM_PO__c createPO(){
        String strRTID;
        
        List<ASI_MFM_Prefix__c> pList = new List<ASI_MFM_Prefix__c>();
        ASI_MFM_Prefix__c px1 = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO', Plan_Type__c='test', ASI_MFM_Fiscal_year__c = getFiscalYear());
		pList.add(px1);
		ASI_MFM_Prefix__c px2= new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', Plan_Type__c='test', ASI_MFM_Fiscal_year__c = getFiscalYear());
		pList.add(px2);
        insert pList; 
        
        user u = [select userRole.developerName from user where id = :userInfo.getUserId()];  
		List<ASI_MFM_Role_Prefix_Relationship__c> prList = new List<ASI_MFM_Role_Prefix_Relationship__c>();
        ASI_MFM_Role_Prefix_Relationship__c pr1 = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px1.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
		prList.add(pr1);
		ASI_MFM_Role_Prefix_Relationship__c pr2 = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px2.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
		prList.add(pr2);
        insert prList;
        
		ASI_MFM_Plan__c plan = new ASI_MFM_Plan__c(Name='CNM131',ASI_MFM_Prefix__c=px2.Id, recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_CN_Plan'),
            ASI_MFM_End_Date__c = Date.today().addMonths(1), ASI_MFM_Plan_Description__c='testDescription', 
				ASI_MFM_Plan_Name__c='plannameTest', ASI_MFM_Start_Date__c=Date.today(), ASI_MFM_Budget_Owner__c=userInfo.getUserId(),ASI_MFM_Status__c='Final');
		insert plan;
        
        list<Account> accs = new list<Account>();
        strRTId =ASI_MFM_Function.checkRecordType('Account','ASI_MFM_CN_Outlet'); 
    	accs.add(new Account(recordTypeId=strRTId ,Name='Name3'));
        //ASI_MFM_CN_Supplier 
        strRTId =ASI_MFM_Function.checkRecordType('Account','ASI_MFM_CN_Supplier'); 
        accs.add(new Account(Name='TestAcc', recordTypeId=strRTId , ASI_MFM_Customer_Supplier_Number__c='123',
                             ASI_MFM_Customer_Supplier_Name__c='SupplierName'));
        insert accs;
			
		ASI_MFM_PO__c po = new ASI_MFM_PO__c(ASI_MFM_Plan__c = plan.Id, recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_CN_PO')
                                             , name='test', ASI_MFM_PO_End_Date__c=Date.today(), ASI_MFM_PO_Start_Date__c=Date.today(), ASI_MFM_Status__c = 'Draft'
                                             , ASI_MFM_Prefix__c=px1.id, ASI_MFM_Supplier_Name__c=accs[1].id);
		insert po;
        return po;
    }
    
    private static List<ASI_MFM_Item_Group__c> createItemGroup() {
        List<ASI_MFM_Item_Group__c> itemGroupList = new List<ASI_MFM_Item_Group__c>();
		Id posmitemRTID = Global_recordTypeCache.getRtId('ASI_MFM_Item_Group__cASI_MFM_CN_POSM_Item_Group');
        Id posmItemLineRTID = Global_recordTypeCache.getRtId('ASI_MFM_Item_Group_Line__cASI_MFM_CN_Bundle_Item_Group_Line');
        ASI_MFM_Item_Group__c newItemGroup = new ASI_MFM_Item_Group__c(name='System autoupdate, do not change.',ASI_MFM_CN_OneTimeItem__c='Yes',RecordTypeId=posmitemRTID, ASI_MFM_Bundle_Item_Group__c=false);
        newItemGroup.ASI_MFM_Utilization_Status__c ='Active';
        itemGroupList.add(newItemGroup);
        insert itemGroupList;
        return itemGroupList;
    }
    
    private static List<ASI_MFM_Item_Group__c> createBundleItemGroup(ASI_MFM_Item_Group__c itemGroup) {
        List<ASI_MFM_Item_Group__c> itemGroupList = new List<ASI_MFM_Item_Group__c>();
        Id posmitemRTID = Global_recordTypeCache.getRtId('ASI_MFM_Item_Group__cASI_MFM_CN_POSM_Item_Group');
        Id posmItemLineRTID = Global_recordTypeCache.getRtId('ASI_MFM_Item_Group_Line__cASI_MFM_CN_Bundle_Item_Group_Line');
        ASI_MFM_Item_Group__c newItemGroup = new ASI_MFM_Item_Group__c(name='System autoupdate, do not change.',ASI_MFM_CN_OneTimeItem__c='Yes',RecordTypeId=posmitemRTID, ASI_MFM_Bundle_Item_Group__c=true);
        itemGroupList.add(newItemGroup);
        insert itemGroupList;
        ASI_MFM_Item_Group_Line__c itemGroupLine = new ASI_MFM_Item_Group_Line__c(
            ASI_MFM_Item_Group__c = newItemGroup.id,
            ASI_MFM_Item_Group_Component__c = itemGroup.id,
            ASI_MFM_Unit_Quantity_in_Bundle__c = 111,
            RecordTypeId=posmItemLineRTID
        );
        insert itemGroupLine;
        return itemGroupList;
    }
    
    public testMethod static void testBundleItemCtl() {
        Profile adminP = [select id from Profile where name = 'System Administrator'];
        List<User> listUser = new List<User>();
        User u = new User(Alias = 'standt', Email='dev1.pra@introv.com', EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                             LocaleSidKey='en_US', ProfileId = adminP.Id, TimeZoneSidKey='Asia/Hong_Kong', UserName='dev1.pra@introv.com');
        listUser.add(u);
        insert listUser;
        
        List<ASI_MFM_Item_Group__c> igList= createItemGroup();
        List<ASI_MFM_Item_Group__c> bIgList = createBundleItemGroup(igList[0]);
        test.startTest();
        System.runAs(u) {
            PageReference pageRef = Page.ASI_MFM_CN_POSM_BundleItemSearchPage;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('bDelete','true');
            ApexPages.currentPage().getParameters().put('Id',igList[0].id+'');
			ASI_MFM_CN_POSM_BundleItemSearchCls cls = new ASI_MFM_CN_POSM_BundleItemSearchCls();
            
            String searchJson = '{"itemList":[{"qty":11,"editable":true,"id":"'+igList[0].id+'"}]}';
            ASI_MFM_CN_POSM_BundleItemSearchCls.searchBundleItem(searchJson);
            ASI_MFM_CN_POSM_BundleItemSearchCls.createBundleItem(searchJson);
            ASI_MFM_CN_POSM_BundleItemSearchCls.deleteBundle(igList[0].id+'');
            ASI_MFM_CN_POSM_BundleItemSearchCls.searchItemByName(igList[0].name);
        }
        test.stopTest();
    }
    
    public testMethod static void testGetItemCtl() {
        Profile adminP = [select id from Profile where name = 'System Administrator'];
        List<User> listUser = new List<User>();
        User u = new User(Alias = 'standt', Email='dev1.pra@introv.com', EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                             LocaleSidKey='en_US', ProfileId = adminP.Id, TimeZoneSidKey='Asia/Hong_Kong', UserName='dev1.pra@introv.com');
        listUser.add(u);
        insert listUser;
        
        List<ASI_MFM_Item_Group__c> igList= createItemGroup();
        List<ASI_MFM_Item_Group__c> bIgList = createBundleItemGroup(igList[0]);
        test.startTest();
        System.runAs(u) {
            ASI_MFM_CN_POSM_PoLineManageAllCls cls = new ASI_MFM_CN_POSM_PoLineManageAllCls();
            ASI_MFM_CN_POSM_PoLineManageAllCls.getItemGroup(igList[0].id+'');
            ASI_MFM_SKU_Code__c tmp = cls.sku;
        }
        test.stopTest();
    }
    
    public testMethod static void testPOConfirmPDF() {
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
            TestingRecord testrecord = new TestingRecord(user1, user2);
            testrecord.posmlineList[0].ASI_MFM_Confirm_PO_Notice__c = true;
            update testrecord.posmlineList;
            test.startTest();
            ASI_MFM_CN_POSM_PO_Confirm_PDF_Ctl cls = new ASI_MFM_CN_POSM_PO_Confirm_PDF_Ctl();
            cls.POID=testrecord.po.id;
            Boolean tmp = cls.init();
	        test.stopTest();
        }

	}
    
    public testMethod static void testVFPage() {
        list<User> users = new list<User>();
        User User1 = new User(managerid = UserInfo.getUserId(), ASI_MFM_Team__c = 'ABCD', ASI_MFM_Country__c ='CN', alias = 'test99',ASI_MFM_Bypass_Callouts__c = true, email='test99' + '@dev.com', emailencodingkey='UTF-8', firstname='test99', lastname='Testing', languagelocalekey='en_US', localesidkey='en_US', timezonesidkey='Europe/London', username='test99' + '@pernod-ricard.com',ProfileId = UserInfo.getProfileId(), UserRoleId = UserInfo.getUserRoleId(), isActive=true);
        User User2 = new User(managerid = UserInfo.getUserId(), ASI_MFM_Team__c = 'ABCD', ASI_MFM_Country__c ='CN', alias = 'tes99',ASI_MFM_Bypass_Callouts__c = true, email='tes99' + '@dev.com', emailencodingkey='UTF-8', firstname='tes99', lastname='Testing', languagelocalekey='en_US', localesidkey='en_US', timezonesidkey='Europe/London', username='tes99' + '@pernod-ricard.com',ProfileId = UserInfo.getProfileId(), UserRoleId = UserInfo.getUserRoleId(), isActive=true);
        Profile adminP = [select id from Profile where name = 'System Administrator'];
        User u = new User(Alias = 'standt', Email='dev1.pra@introv.com', EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                             LocaleSidKey='en_US', ProfileId = adminP.Id, TimeZoneSidKey='Asia/Hong_Kong', UserName='dev1.pra@introv.com');
        users.add(u);
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
        
        System.runAs(u) {
	        TestingRecord testrecord = new TestingRecord(user1, user2);
            test.startTest();
            PageReference pageRef = Page.ASI_MFM_CN_POSM_SirCSVexport;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('ponum',testrecord.po.name);
            ASI_MFM_CN_POSM_SirCSVexportCls cls = new ASI_MFM_CN_POSM_SirCSVexportCls();
            cls.ponum = testrecord.po.name;
            boolean b = cls.dummyVar;
			
            ASI_MFM_CN_POSM_SirCSVexportCls.ItemCsvWrapper weapper = new ASI_MFM_CN_POSM_SirCSVexportCls.ItemCsvWrapper(testrecord.posmlineList[0]);
            
            ASI_MFM_CN_POSM_PDF_Component_Ctl cls2 = new ASI_MFM_CN_POSM_PDF_Component_Ctl();
            cls2.LINEID = testrecord.posmlineList[0].id;
            b = cls2.dummyVar;

            ASI_CTY_CN_Vendor_PosmPdf_Ctl cls22 = new ASI_CTY_CN_Vendor_PosmPdf_Ctl();
            cls22.LINEID = testrecord.posmlineList[0].id;
            b = cls22.dummyVar;
            cls22.initDate();
            
            ASI_MFM_CN_POSM_SearchPosmLineCls cls3 = new ASI_MFM_CN_POSM_SearchPosmLineCls();
            ASI_MFM_CN_POSM_SearchPosmLineCls.searchPosm('{"ponum":"'+testrecord.po.Name+'"}');
            ASI_MFM_CN_POSM_SearchPosmLineCls.searchPosm('{"ponum":""}');
            ASI_MFM_CN_POSM_SearchPosmLineCls.searchPosm('{"ponum":"123123123aaaaa"}');
            
            ASI_MFM_CN_POSM_SIR_PDF_Component_Ctl cls4 = new ASI_MFM_CN_POSM_SIR_PDF_Component_Ctl();
            cls4.LINEID = testrecord.posmlineList[0].id;
            cls4.requestTimestamp = '';
            integer i = cls4.sirCount;
            b = cls4.dummyVar;
            
            pageRef = Page.ASI_MFM_CN_POSM_PoLineManageAll;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('id',testrecord.po.id);
            ASI_MFM_CN_POSM_PoLineManageAllCls cls5 = new ASI_MFM_CN_POSM_PoLineManageAllCls();
            ApexPages.Standardcontroller stdController = new ApexPages.Standardcontroller(testrecord.po); 
            cls5 = new ASI_MFM_CN_POSM_PoLineManageAllCls(stdController);
            ASI_MFM_CN_POSM_PoLineManageAllCls.searchConfig('');
            ASI_MFM_CN_POSM_PoLineManageAllCls.searchPosmLineList('{"poid":"'+testrecord.po.id+'"}');
            ASI_MFM_CN_POSM_PoLineManageAllCls.sendTIV('{"poid":"'+testrecord.po.id+'","posmLineId":"'+testrecord.posmlineList[0].id+'","sirList":[]}');
            
            ASI_MFM_CN_POSM_StockinRequestListCls cls6 = new ASI_MFM_CN_POSM_StockinRequestListCls();
            // ASI_MFM_CN_POSM_StockinRequestListCls.searchRequest('{"ponum":"'+testrecord.po.Name+'"}');
            // ASI_MFM_CN_POSM_StockinRequestListCls.searchRequest('{"ponum":""}');
            ASI_MFM_CN_POSM_StockinRequestListCls.confirmRequest('{"requestList":[{"id":"'+testrecord.sirList[0].id+'"}]}', false);
            ASI_MFM_CN_POSM_StockinRequestListCls.confirmRequest('{"requestList":[]}', false);
            ASI_MFM_CN_POSM_StockinRequestListCls.confirmRequest('{"requestList":[{"id":"'+testrecord.sirList[0].id+'"}]}', true);
           
            pageRef = Page.ASI_MFM_CN_POSM_VendorMailSelectPage;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('id',testrecord.po.id);
            ASI_MFM_CN_POSM_VendorMailSelectCtrl cls7 = new ASI_MFM_CN_POSM_VendorMailSelectCtrl();
            cls7 = new ASI_MFM_CN_POSM_VendorMailSelectCtrl();
            ASI_MFM_CN_POSM_VendorMailSelectCtrl.sendMail('{"po":"'+testrecord.po.id+'","posmLineList":[]}');
            ASI_MFM_CN_POSM_VendorMailSelectCtrl.sendMail('{"po":"'+testrecord.po.id+'","posmLineList":[{"select":true,"id":"'+testrecord.posmlineList[0].id+'"}]}');
        	test.stopTest();    
        }
        
	}

   public testMethod static void testconfirmNewRequest() {

        UserRole adminRole = new UserRole(DeveloperName = 'MyCustomRole', Name = 'My Role');
        insert adminRole;
        Profile admin_p = [SELECT Id FROM Profile WHERE Name='System Administrator'];//System Administrator
        User adminUser = new User(Alias = 'admin', Email='adminuser@testorg.com', UserRoleId= adminRole.Id,
                            EmailEncodingKey='UTF-8', LastName='admin', LanguageLocaleKey='zh_CN', Autofollow__c = false,
                            LocaleSidKey='zh_CN', ProfileId = admin_p.Id,IsActive = true,
                            TimeZoneSidKey='Asia/Shanghai', UserName='test2@wholesaler.com',
                            CompanyName = 'Pernod Ricard China');
        insert adminUser;  
        System.runAs(adminUser) {
          String strRTID;
            
            list<ASI_MFM_Prefix__c> prefixs = new list<ASI_MFM_Prefix__c>();
            prefixs.add(new ASI_MFM_Prefix__c(Name='CN',ASI_MFM_Module__c='Plan',Plan_Type__c='Marketing A&P Plan'
            ,ASI_MFM_Fiscal_year__c='FY1920',ownerId = adminUser.id));
            
            //create prefix po
            strRTId = checkRecordType('ASI_MFM_Prefix__c','ASI_MFM_CN_Prefix');
            prefixs.add(new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO', recordTypeId=strRTID,
                                                        ASI_MFM_Fiscal_year__c='FY1920', ASI_MFM_Next_Number__c=86));
            insert prefixs;
            
            list<ASI_MFM_Role_Prefix_Relationship__c> prefixChilds = new list<ASI_MFM_Role_Prefix_Relationship__c>();
            prefixChilds.Add(new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c = prefixs[0].Id,
            ASI_MFM_Role_Name__c =adminRole.developerName));            
            prefixChilds.Add(new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c = prefixs[1].Id,
            ASI_MFM_Role_Name__c =adminRole.developerName));            
            
            insert prefixChilds;

            strRTId = checkRecordType('ASI_MFM_A_C_Code__c','ASI_MFM_CN_A_C_Code');
            list<ASI_MFM_A_C_Code__c> acs = new list<ASI_MFM_A_C_Code__c>();
            acs.add(new ASI_MFM_A_C_Code__c(recordtypeid=strRTId, name='testAC1', ASI_MFM_A_C_Code__c = '5600.000'));
            acs.add(new ASI_MFM_A_C_Code__c(recordtypeid=strRTId, name='testAC2', ASI_MFM_A_C_Code__c = '5600.300'));
            acs.add(new ASI_MFM_A_C_Code__c(name='testAC', recordtypeid=strRTId ));
            insert acs;
            
            strRTId = checkRecordType('ASI_MFM_PP_Category__c','ASI_MFM_CN_PP_Category');   
            ASI_MFM_PP_Category__c ppc = new ASI_MFM_PP_Category__c(recordtypeid=strRTId , Name='NTMCD - KTV Promotion', ASI_MFM_External_ID__c='NTMCD - KTV Promotion (CN)1');
            insert ppc;
            
            strRTId = checkRecordType('ASI_MFM_PP_Category_A_C__c','ASI_MFM_CN_PP_Category_A_C'); 
            list<ASI_MFM_PP_Category_A_C__c> ppcacs = new list<ASI_MFM_PP_Category_A_C__c>();
            ppcacs.add(new ASI_MFM_PP_Category_A_C__c(ASI_MFM_External_ID__c='test', recordtypeid=strRTId , ASI_MFM_A_C_Code__c=acs[0].id, ASI_MFM_PP_Category__c=ppc.id));
            ppcacs.add(new ASI_MFM_PP_Category_A_C__c(ASI_MFM_External_ID__c='test2', recordtypeid=strRTId , ASI_MFM_A_C_Code__c=acs[1].id,ASI_MFM_PP_Category__c=ppc.id));
            insert ppcacs; 
            
            ASI_MFM_Market_Strategy__c mms = new ASI_MFM_Market_Strategy__c(name='12004 Chivas', ASI_MFM_External_ID__c='120041',ASI_MFM_Fiscal_Year__c='FY1213', ASI_MFM_Sub_brand__c='CH2,CH3,CHF,CHU');
            insert mms;
            
            strRTId = checkRecordType('ASI_MFM_Plan__c','ASI_MFM_CN_Plan'); 
            
            List<ASI_MFM_Plan__c> planList = new List<ASI_MFM_Plan__c>();
            
            ASI_MFM_Plan__c Plan1 = new ASI_MFM_Plan__c(Name='CNM131',ASI_MFM_Prefix__c=prefixs[0].Id
            ,recordTypeId=strRTId ,
            ASI_MFM_End_Date__c = Date.today().addMonths(1), ASI_MFM_Plan_Description__c='testDescription', 
            ASI_MFM_Plan_Name__c='plannameTest', ASI_MFM_Start_Date__c=Date.today(), ASI_MFM_Budget_Owner__c=adminUser.id, 
            ASI_MFM_PP_Category__c = ppc.id, ASI_MFM_Market_Strategy__c=mms.id, ASI_MFM_Status__c='Final', OwnerId =adminUser.id);
            
            ASI_MFM_Plan__c Plan2 = new ASI_MFM_Plan__c(Name='CNM131',ASI_MFM_Prefix__c=prefixs[0].Id
                                                        ,recordTypeId=strRTId ,
                                                        ASI_MFM_End_Date__c = Date.today().addMonths(1), ASI_MFM_Plan_Description__c='testDescription', 
                                                        ASI_MFM_Plan_Name__c='plannameTest', ASI_MFM_Start_Date__c=Date.today(), ASI_MFM_Budget_Owner__c=adminUser.id, 
                                                        ASI_MFM_PP_Category__c = ppc.id, ASI_MFM_Market_Strategy__c=mms.id, ASI_MFM_Status__c='Final', OwnerId =adminUser.id);
            
            planList.add(plan1);
            planList.add(plan2);
            
            insert planList;
            
            
            //create brand
            strRTId = checkRecordType('ASI_MFM_Brand__c','ASI_MFM_CN_Brand');
            ASI_MFM_Brand__c brand = new ASI_MFM_Brand__c(name='brandname',Recordtypeid=strRTId);
            insert brand; 
     
            list<ASI_MFM_Sub_brand__c> subBrands = new list<ASI_MFM_Sub_brand__c>();
            //create sub brand
            strRTId = checkRecordType('ASI_MFM_Sub_brand__c','ASI_MFM_CN_Sub_Brand');
            subBrands.add(new ASI_MFM_Sub_brand__c(Name='subBrand1' ,recordTypeId=strRTId));
            subBrands.add(new ASI_MFM_Sub_brand__c(Name='subBrand2' ,recordTypeId=strRTId));
            subBrands.add(new ASI_MFM_Sub_brand__c(Name='testSb',recordtypeid=strRTId,ASI_MFM_Brand__c=brand.id));
            insert subBrands;
                       
            list<Account> accs = new list<Account>();
            
            strRTId = checkRecordType('Account','ASI_MFM_CN_Outlet'); 
            accs.add(new Account(recordTypeId=strRTId ,Name='Name3'));
            
             //ASI_MFM_CN_Supplier 
            strRTId = checkRecordType('Account','ASI_MFM_CN_Supplier'); 
            accs.add(new Account(Name='TestAcc', recordTypeId=strRTId , ASI_MFM_Customer_Supplier_Number__c='123',
                                    ASI_MFM_Customer_Supplier_Name__c='SupplierName'));
            insert accs;

            strRTId = checkRecordType('Contact','ASI_CRM_CN_Wholesaler_Contact'); 
            Contact con = new Contact(LastName = 'TestContact', 
                                    RecordtypeId = strRTId,
                                    AccountId = accs[1].Id);
            insert con;

            Profile p2 = [SELECT Id FROM Profile WHERE Name='ASI_CTY_Wholesaler_CN_User'];//ASI_CTY_Wholesaler_CN_User
            User usr2 = new User(Alias = '经销商', Email='standarduser@testorg.com', 
                                EmailEncodingKey='UTF-8', LastName='经销商', LanguageLocaleKey='zh_CN', Autofollow__c = false,
                                LocaleSidKey='zh_CN', ProfileId = p2.Id, ContactId = con.Id,IsActive = true,
                                TimeZoneSidKey='Asia/Shanghai', UserName='test1@wholesaler.com',
                                CompanyName = 'Pernod Ricard China');
            insert usr2;
            
            strRTId = checkRecordType('ASI_MFM_Plan_Line_Item__c','ASI_MFM_CN_Plan_Line_Item');
            ASI_MFM_Plan_Line_Item__c planLineItem1 = new ASI_MFM_Plan_Line_Item__c(ASI_MFM_Plan__c = Plan1.id
            ,ASI_MFM_Sub_brand_Code__c = subBrands[2].id,ASI_MFM_List_Item_Description__c='hello1'
            ,recordTypeId=strRTId , ASI_MFM_Total_Cost__c =120000,
            ASI_MFM_A_C_Code__c=acs[2].id
            );
            insert planLineItem1; 
            
            //create BU Code
            strRTId = checkRecordType('ASI_MFM_BU__c','ASI_MFM_CN_BU');
            ASI_MFM_BU__c bu = new ASI_MFM_BU__c(Name='BUCode', ASI_MFM_BU_Code__c=strRTId , ASI_MFM_CN_Country__c='CN',
                                                ASI_MFM_Base_Currency__c='RMB');
            insert bu;
            
            
            
            //create exchange rate reference
            ASI_MFM_Exchange_Rate__c ex = new ASI_MFM_Exchange_Rate__c(ASI_MFM_Country__c='CN',ASI_MFM_Effective_Date__c=Date.valueof('2019-07-01'),
                                                                       ASI_MFM_Exchange_Rate__c=7.77500, ASI_MFM_Counter_Currency__c='USD', ASI_MFM_Base_Currency__c='RMB',
                                                                       ASI_MFM_Application__c='MFM' );
            insert ex;
            
            //create po
            strRTId = checkRecordType('ASI_MFM_PO__c','ASI_MFM_CN_PO');
            ASI_MFM_PO__c po = new ASI_MFM_PO__c(Name='PO11111', RecordTypeId=strRTId , ASI_MFM_Prefix__c=prefixs[1].id, ASI_MFM_Remarks__c='Remarks',
                                                ASI_MFM_BU_Code__c=bu.id, ASI_MFM_Supplier_Name__c=accs[1].id, ASI_MFM_Currency__c='USD',
                                                ASI_MFM_PO_Start_Date__c=Date.valueof('2019-07-01'),ASI_MFM_PO_End_Date__c=Date.valueof('2020-06-30'),
                                                ASI_MFM_PO_Type__c='eMarket',ASI_MFM_Budget_Owner__c =adminUser.id, ASI_MFM_Plan__c=Plan2.id );
            insert po;

            //create itemgroup
            ASI_MFM_Item_Group__c ig = new ASI_MFM_Item_Group__c(Name = 'testItemGroup', ASI_MFM_Sub_brand__c = subBrands[2].id);
            insert ig;

            //create Warehouse Photo
            String reocrdTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Product_Warehouse_Photo__cASI_MFM_CN_POSM_Photo');
            ASI_CRM_Product_Warehouse_Photo__c pwp = new ASI_CRM_Product_Warehouse_Photo__c(ASI_CRM_Item_Group__c = ig.Id, ASI_File_Name__c = 'test.png',
                ASI_File_Size__c = 20, ASI_File_Extension__c = 'png', ASI_CRM_Photo_Version__c = 1.0, ASI_CRM_Comments__c = 'SIR Item Group Image', RecordTypeId = reocrdTypeId);
            insert pwp;


            //create ContentVersion
            ContentVersion cv = new ContentVersion(ContentLocation = 'S', VersionData = EncodingUtil.base64Decode('test'),
                Title = pwp.ASI_File_Name__c, PathOnClient = pwp.ASI_File_Name__c);
            insert cv;

            //create ContentDocumentLink
            Id contentDocumentId;
            Id contentVersionId;
            for (ContentVersion contentVir : [select Id, ContentDocumentId from ContentVersion where Id=:cv.Id]) {
                contentDocumentId = contentVir.ContentDocumentId;
                contentVersionId = contentVir.Id;
            }
            ContentDocumentLink cdl = new ContentDocumentLink(ContentDocumentId = contentDocumentId, LinkedEntityId = pwp.Id,
                ShareType = 'V');
            insert cdl;

            //create FeedItem
            FeedItem attachment = new FeedItem(ParentId = pwp.Id, Visibility = 'AllUsers', RelatedRecordId = contentVersionId);
            insert attachment;

            FeedItem insertedAttachment = [SELECT RelatedRecordId FROM FeedItem WHERE Id=:attachment.Id];
            pwp.ASI_FileID__c = insertedAttachment.RelatedRecordId;
            pwp.ASI_FeedItemID__c = insertedAttachment.Id;
            update pwp;

            //create PO POSM line
            ASI_MFM_PO_POSM_Line__c ppl = new ASI_MFM_PO_POSM_Line__c(ASI_MFM_PO__c = po.Id, ASI_MFM_Item_Group__c = ig.Id);
            insert ppl;

            //create SIR
            Id sirRTID = Global_recordTypeCache.getRtId('ASI_MFM_Stock_In_Request__cASI_MFM_CN_Stock_In_Request');
            ASI_MFM_Stock_In_Request__c sir = new ASI_MFM_Stock_In_Request__c(ASI_MFM_PO_Number__c=po.Id,ASI_MFM_PO_POSM_Line_Number__c = ppl.Id,RecordTypeId=sirRTID,ASI_MFM_Status__c = 'Pending Confirm');
            insert sir;
             ASI_MFM_Stock_In_Request__c cc = [SELECT Id,name,ASI_MFM_PO_Number__r.Name,ASI_CTY_CN_Vendor_SIR_Approval_Status__c,ASI_MFM_Status__c from ASI_MFM_Stock_In_Request__c where Id=:sir.id];
            ASI_MFM_CN_POSM_StockinRequestListCls cls6 = new ASI_MFM_CN_POSM_StockinRequestListCls();
            ASI_MFM_CN_POSM_StockinRequestListCls.searchRequest('{"ponum":"'+cc.ASI_MFM_PO_Number__r.Name+'"}');
            ASI_MFM_CN_POSM_StockinRequestListCls.searchRequest('{"ponum":""}');
            // ASI_MFM_CN_POSM_StockinRequestListCls.confirmRequest('{"requestList":[{"id":"'+sir.id+'"}]}', false);
            // ASI_MFM_CN_POSM_StockinRequestListCls.confirmRequest('{"requestList":[]}', false);
            // ASI_MFM_CN_POSM_StockinRequestListCls.confirmRequest('{"requestList":[{"id":"'+sir.id+'"}]}', true);
            List<Object> sirIds = new List<Object>();
            sirIds.add(sir.id);
           
            System.debug(LoggingLevel.INFO, '*** cc: ' + cc);
            System.debug(LoggingLevel.INFO, '*** po.Name: ' + po.Name);
            ASI_MFM_CN_POSM_StockinRequestListCls.confirmNewRequest(JSON.serialize(sirIds), '1');
            ASI_MFM_CN_POSM_StockinRequestListCls.confirmNewRequest(JSON.serialize(sirIds), '2');
          }


   }

      static Id checkRecordType(string strsobject, string rt_name){
        id RT_id;
        List<recordType> sobjectlist = Global_RecordTypeCache.getRtList(strsobject);
            for (recordtype pl : sobjectlist ){
                if (pl.developername == rt_name)
                RT_id = pl.id;
            }
            system.debug('RT_id: ' + RT_id);
            return RT_id;
    }
    /*
    public testMethod static void debugTest() {
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
            test.startTest();
            test.stopTest();
        }
    }
*/
    public testMethod static void testManageAll() {
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
	        TestingRecord testrecord = new TestingRecord(user1, user2);
            test.startTest();
            PageReference pageRef = Page.ASI_MFM_CN_POSM_PoLineManageAll;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('id',testrecord.po.id);
            ASI_MFM_CN_POSM_PoLineManageAllCls cls5 = new ASI_MFM_CN_POSM_PoLineManageAllCls();
            ApexPages.Standardcontroller stdController = new ApexPages.Standardcontroller(testrecord.po); 
            cls5 = new ASI_MFM_CN_POSM_PoLineManageAllCls(stdController);
            ASI_MFM_CN_POSM_PoLineManageAllCls.searchConfig('');
            ASI_MFM_CN_POSM_PoLineManageAllCls.searchPosmLineList('{"poid":"'+testrecord.po.id+'"}');
            ASI_MFM_CN_POSM_PoLineManageAllCls.sendTIV('{"poid":"'+testrecord.po.id+'","posmLineId":"'+testrecord.posmlineList[0].id+'","sirList":[]}');   
            ASI_MFM_CN_POSM_PoLineManageAllCls.sendTIV('{"poid":"'+testrecord.po.id+'","posmLineId":"'+testrecord.posmlineList[0].id+'","sirList":[{"id":"'+testrecord.sirList[1].id+'","tivnum":"112","tivnotesent":false,"isSendEmail":true}]}');   
            ASI_MFM_CN_POSM_PoLineManageAllCls.sendSir('{"poid":"'+testrecord.po.id+'","posmLineId":"'+testrecord.posmlineList[0].id+'","sirList":[{"id":"'+testrecord.sirList[1].id+'","tivnum":"112","tivnotesent":false,"isSendEmail":true}]}');            
            test.stopTest();
        }
    }
    
    public testMethod static void testManageAll2() {
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
	        TestingRecord testrecord = new TestingRecord(user1, user2);
	        test.startTest();
            ASI_MFM_CN_POSM_PoLineManageAllCls.submit('{"poid":"'+testrecord.po.id+'","deleteIdList":[],"submitedList":[{"address":"asdfghjklouyrsa","bundleFlag":false,"bundleQty":0,"city":"上海 Shanghai","contactPerson":"CC","directDelivery":true,"editable":true,"email":"patrick.yan@pernod-ricard.com","id":"","itemgroup":"'+testrecord.itemGroupList[0].id+'","itemgroupCode":"qqq","itemgroupDesc":"","minOrderQty":20000,"opEmail_1":"ben.fong@introv.com","opEmail_2":"","opEmail_3":"","opEmail_4":"","opEmail_5":"","opEmail_6":"","opEmail_7":"","opEmail_8":"","outletid":"","outletName":"好德虹井店(ONSHA5129)","phoneNumber":"1111111","province":"上海","qty":1200,"rowcontrol":0,"sentMail":"","sirEmail_1":"patrick.yan@pernod-ricard.com","sirEmail_2":"","sirEmail_3":"","sirEmail_4":"","sirEmail_5":"","sirEmail_6":"","sirEmail_7":"","sirEmail_8":"","sirLink":"link","sirList":[],"tivNum":"","totalPrice":2330.097087,"unitPrice":2,"vat":"3%","vatId":"","vatRate":3,"warehouseid":"'+testrecord.warehouseList[0].id+'","warehouseName":"直接发货 - DUMMY"}]}');
            ASI_MFM_CN_POSM_PoLineManageAllCls.submit('{"poid":"'+testrecord.po.id+'","deleteIdList":[],"submitedList":[{"address":"asdfghjklouyrsa","bundleFlag":false,"bundleQty":0,"city":"上海 Shanghai","contactPerson":"CC","directDelivery":true,"editable":true,"email":"patrick.yan@pernod-ricard.com","id":"","itemgroup":"","itemgroupCode":"qqq","itemgroupDesc":"","minOrderQty":20000,"opEmail_1":"ben.fong@introv.com","opEmail_2":"","opEmail_3":"","opEmail_4":"","opEmail_5":"","opEmail_6":"","opEmail_7":"","opEmail_8":"","outletid":"","outletName":"好德虹井店(ONSHA5129)","phoneNumber":"1111111","province":"上海","qty":1200,"rowcontrol":0,"sentMail":"","sirEmail_1":"patrick.yan@pernod-ricard.com","sirEmail_2":"","sirEmail_3":"","sirEmail_4":"","sirEmail_5":"","sirEmail_6":"","sirEmail_7":"","sirEmail_8":"","sirLink":"link","sirList":[],"tivNum":"","totalPrice":2330.097087,"unitPrice":2,"vat":"3%","vatId":"","vatRate":3,"warehouseid":"'+testrecord.warehouseList[0].id+'","warehouseName":"直接发货 - DUMMY"}]}');
            ASI_MFM_CN_POSM_PoLineManageAllCls.submit('{"poid":"'+testrecord.po.id+'","deleteIdList":[],"submitedList":[{"address":"asdfghjklouyrsa","bundleFlag":false,"bundleQty":0,"city":"上海 Shanghai","contactPerson":"CC","directDelivery":true,"editable":true,"email":"patrick.yan@pernod-ricard.com","id":"","itemgroup":"'+testrecord.itemGroupList[0].id+'","itemgroupCode":"qqq","itemgroupDesc":"","minOrderQty":20000,"opEmail_1":"ben.fong@introv.com","opEmail_2":"","opEmail_3":"","opEmail_4":"","opEmail_5":"","opEmail_6":"","opEmail_7":"","opEmail_8":"","outletid":"","outletName":"好德虹井店(ONSHA5129)","phoneNumber":"1111111","province":"上海","qty":-1,"rowcontrol":0,"sentMail":"","sirEmail_1":"patrick.yan@pernod-ricard.com","sirEmail_2":"","sirEmail_3":"","sirEmail_4":"","sirEmail_5":"","sirEmail_6":"","sirEmail_7":"","sirEmail_8":"","sirLink":"link","sirList":[],"tivNum":"","totalPrice":2330.097087,"unitPrice":2,"vat":"3%","vatId":"","vatRate":3,"warehouseid":"'+testrecord.warehouseList[0].id+'","warehouseName":"直接发货 - DUMMY"}]}');
            ASI_MFM_CN_POSM_PoLineManageAllCls.submit('{"poid":"'+testrecord.po.id+'","deleteIdList":[],"submitedList":[{"address":"asdfghjklouyrsa","bundleFlag":false,"bundleQty":0,"city":"上海 Shanghai","contactPerson":"CC","directDelivery":true,"editable":true,"email":"patrick.yan@pernod-ricard.com","id":"","itemgroup":"'+testrecord.itemGroupList[0].id+'","itemgroupCode":"qqq","itemgroupDesc":"","minOrderQty":20000,"opEmail_1":"ben.fong@introv.com","opEmail_2":"","opEmail_3":"","opEmail_4":"","opEmail_5":"","opEmail_6":"","opEmail_7":"","opEmail_8":"","outletid":"","outletName":"好德虹井店(ONSHA5129)","phoneNumber":"1111111","province":"上海","qty":1200,"rowcontrol":0,"sentMail":"","sirEmail_1":"patrick.yan@pernod-ricard.com","sirEmail_2":"","sirEmail_3":"","sirEmail_4":"","sirEmail_5":"","sirEmail_6":"","sirEmail_7":"","sirEmail_8":"","sirLink":"link","sirList":[],"tivNum":"","totalPrice":2330.097087,"unitPrice":2,"vat":"3%","vatId":"","vatRate":3,"warehouseid":"","warehouseName":"直接发货 - DUMMY"}]}');
            ASI_MFM_CN_POSM_PoLineManageAllCls.submit('{"poid":"'+testrecord.po.id+'","deleteIdList":[],"submitedList":[{"address":"asdfghjklouyrsa","bundleFlag":false,"bundleQty":0,"city":"上海 Shanghai","contactPerson":"CC","directDelivery":true,"editable":true,"email":"patrick.yan@pernod-ricard.com","id":"","itemgroup":"'+testrecord.itemGroupList[0].id+'","itemgroupCode":"qqq","itemgroupDesc":"","minOrderQty":20000,"opEmail_1":"ben.fong@introv.com","opEmail_2":"","opEmail_3":"","opEmail_4":"","opEmail_5":"","opEmail_6":"","opEmail_7":"","opEmail_8":"","outletid":"","outletName":"好德虹井店(ONSHA5129)","phoneNumber":"1111111","province":"上海","qty":1200,"rowcontrol":0,"sentMail":"","sirEmail_1":"patrick.yan@pernod-ricard.com","sirEmail_2":"","sirEmail_3":"","sirEmail_4":"","sirEmail_5":"","sirEmail_6":"","sirEmail_7":"","sirEmail_8":"","sirLink":"link","sirList":[],"tivNum":"","totalPrice":2330.097087,"unitPrice":2,"vat":"3%","vatId":"","vatRate":3,"warehouseid":"'+testrecord.warehouseList[0].id+'","warehouseName":"直接发货 - DUMMY"}]}');
            ASI_MFM_CN_POSM_PoLineManageAllCls.submit('{"poid":"'+testrecord.po.id+'","deleteIdList":[],"submitedList":[{"address":"asdfghjklouyrsa","bundleFlag":false,"bundleQty":0,"city":"上海 Shanghai","contactPerson":"CC","directDelivery":true,"editable":true,"email":"patrick.yan@pernod-ricard.com","id":"","itemgroup":"'+testrecord.itemGroupList[0].id+'","itemgroupCode":"qqq","itemgroupDesc":"","minOrderQty":20000,"opEmail_1":"ben.fong@introv.com","opEmail_2":"","opEmail_3":"","opEmail_4":"","opEmail_5":"","opEmail_6":"","opEmail_7":"","opEmail_8":"","outletid":"","outletName":"好德虹井店(ONSHA5129)","phoneNumber":"1111111","province":"","qty":1200,"rowcontrol":0,"sentMail":"","sirEmail_1":"patrick.yan@pernod-ricard.com","sirEmail_2":"","sirEmail_3":"","sirEmail_4":"","sirEmail_5":"","sirEmail_6":"","sirEmail_7":"","sirEmail_8":"","sirLink":"link","sirList":[],"tivNum":"","totalPrice":2330.097087,"unitPrice":2,"vat":"3%","vatId":"","vatRate":3,"warehouseid":"'+testrecord.warehouseList[0].id+'","warehouseName":"直接发货 - DUMMY"}]}');
            ASI_MFM_CN_POSM_PoLineManageAllCls.submit('{"poid":"'+testrecord.po.id+'","deleteIdList":[],"submitedList":[{"address":"asdfghjklouyrsa","bundleFlag":false,"bundleQty":0,"city":"","contactPerson":"CC","directDelivery":true,"editable":true,"email":"patrick.yan@pernod-ricard.com","id":"","itemgroup":"'+testrecord.itemGroupList[0].id+'","itemgroupCode":"qqq","itemgroupDesc":"","minOrderQty":20000,"opEmail_1":"ben.fong@introv.com","opEmail_2":"","opEmail_3":"","opEmail_4":"","opEmail_5":"","opEmail_6":"","opEmail_7":"","opEmail_8":"","outletid":"","outletName":"好德虹井店(ONSHA5129)","phoneNumber":"1111111","province":"上海","qty":1200,"rowcontrol":0,"sentMail":"","sirEmail_1":"patrick.yan@pernod-ricard.com","sirEmail_2":"","sirEmail_3":"","sirEmail_4":"","sirEmail_5":"","sirEmail_6":"","sirEmail_7":"","sirEmail_8":"","sirLink":"link","sirList":[],"tivNum":"","totalPrice":2330.097087,"unitPrice":2,"vat":"3%","vatId":"","vatRate":3,"warehouseid":"'+testrecord.warehouseList[0].id+'","warehouseName":"直接发货 - DUMMY"}]}');
            ASI_MFM_CN_POSM_PoLineManageAllCls.submit('{"poid":"'+testrecord.po.id+'","deleteIdList":[],"submitedList":[{"address":"","bundleFlag":false,"bundleQty":0,"city":"上海 Shanghai","contactPerson":"CC","directDelivery":true,"editable":true,"email":"patrick.yan@pernod-ricard.com","id":"","itemgroup":"'+testrecord.itemGroupList[0].id+'","itemgroupCode":"qqq","itemgroupDesc":"","minOrderQty":20000,"opEmail_1":"ben.fong@introv.com","opEmail_2":"","opEmail_3":"","opEmail_4":"","opEmail_5":"","opEmail_6":"","opEmail_7":"","opEmail_8":"","outletid":"","outletName":"好德虹井店(ONSHA5129)","phoneNumber":"1111111","province":"上海","qty":1200,"rowcontrol":0,"sentMail":"","sirEmail_1":"patrick.yan@pernod-ricard.com","sirEmail_2":"","sirEmail_3":"","sirEmail_4":"","sirEmail_5":"","sirEmail_6":"","sirEmail_7":"","sirEmail_8":"","sirLink":"link","sirList":[],"tivNum":"","totalPrice":2330.097087,"unitPrice":2,"vat":"3%","vatId":"","vatRate":3,"warehouseid":"'+testrecord.warehouseList[0].id+'","warehouseName":"直接发货 - DUMMY"}]}');
            ASI_MFM_CN_POSM_PoLineManageAllCls.submit('{"poid":"'+testrecord.po.id+'","deleteIdList":[],"submitedList":[{"address":"asdfghjklouyrsa","bundleFlag":false,"bundleQty":0,"city":"上海 Shanghai","contactPerson":"","directDelivery":true,"editable":true,"email":"patrick.yan@pernod-ricard.com","id":"","itemgroup":"'+testrecord.itemGroupList[0].id+'","itemgroupCode":"qqq","itemgroupDesc":"","minOrderQty":20000,"opEmail_1":"ben.fong@introv.com","opEmail_2":"","opEmail_3":"","opEmail_4":"","opEmail_5":"","opEmail_6":"","opEmail_7":"","opEmail_8":"","outletid":"","outletName":"好德虹井店(ONSHA5129)","phoneNumber":"1111111","province":"上海","qty":1200,"rowcontrol":0,"sentMail":"","sirEmail_1":"patrick.yan@pernod-ricard.com","sirEmail_2":"","sirEmail_3":"","sirEmail_4":"","sirEmail_5":"","sirEmail_6":"","sirEmail_7":"","sirEmail_8":"","sirLink":"link","sirList":[],"tivNum":"","totalPrice":2330.097087,"unitPrice":2,"vat":"3%","vatId":"","vatRate":3,"warehouseid":"'+testrecord.warehouseList[0].id+'","warehouseName":"直接发货 - DUMMY"}]}');
            ASI_MFM_CN_POSM_PoLineManageAllCls.submit('{"poid":"'+testrecord.po.id+'","deleteIdList":[],"submitedList":[{"address":"asdfghjklouyrsa","bundleFlag":false,"bundleQty":0,"city":"上海 Shanghai","contactPerson":"CC","directDelivery":true,"editable":true,"email":"patrick.yan@pernod-ricard.com","id":"","itemgroup":"'+testrecord.itemGroupList[0].id+'","itemgroupCode":"qqq","itemgroupDesc":"","minOrderQty":20000,"opEmail_1":"ben.fong@introv.com","opEmail_2":"","opEmail_3":"","opEmail_4":"","opEmail_5":"","opEmail_6":"","opEmail_7":"","opEmail_8":"","outletid":"","outletName":"好德虹井店(ONSHA5129)","phoneNumber":"","province":"上海","qty":1200,"rowcontrol":0,"sentMail":"","sirEmail_1":"patrick.yan@pernod-ricard.com","sirEmail_2":"","sirEmail_3":"","sirEmail_4":"","sirEmail_5":"","sirEmail_6":"","sirEmail_7":"","sirEmail_8":"","sirLink":"link","sirList":[],"tivNum":"","totalPrice":2330.097087,"unitPrice":2,"vat":"3%","vatId":"","vatRate":3,"warehouseid":"'+testrecord.warehouseList[0].id+'","warehouseName":"直接发货 - DUMMY"}]}');
            ASI_MFM_CN_POSM_PoLineManageAllCls.submit('{"poid":"'+testrecord.po.id+'","deleteIdList":[],"submitedList":[{"address":"asdfghjklouyrsa","bundleFlag":false,"bundleQty":0,"city":"上海 Shanghai","contactPerson":"CC","directDelivery":true,"editable":true,"email":"","id":"","itemgroup":"'+testrecord.itemGroupList[0].id+'","itemgroupCode":"qqq","itemgroupDesc":"","minOrderQty":20000,"opEmail_1":"ben.fong@introv.com","opEmail_2":"","opEmail_3":"","opEmail_4":"","opEmail_5":"","opEmail_6":"","opEmail_7":"","opEmail_8":"","outletid":"","outletName":"好德虹井店(ONSHA5129)","phoneNumber":"1111111","province":"上海","qty":1200,"rowcontrol":0,"sentMail":"","sirEmail_1":"patrick.yan@pernod-ricard.com","sirEmail_2":"","sirEmail_3":"","sirEmail_4":"","sirEmail_5":"","sirEmail_6":"","sirEmail_7":"","sirEmail_8":"","sirLink":"link","sirList":[],"tivNum":"","totalPrice":2330.097087,"unitPrice":2,"vat":"3%","vatId":"","vatRate":3,"warehouseid":"'+testrecord.warehouseList[0].id+'","warehouseName":"直接发货 - DUMMY"}]}');
			ASI_MFM_CN_POSM_PoLineManageAllCls.submit('{"poid":"'+testrecord.po.id+'","deleteIdList":[],"submitedList":[{"address":"asdfghjklouyrsa","bundleFlag":false,"bundleQty":0,"city":"上海 Shanghai","contactPerson":"CC","directDelivery":true,"editable":true,"email":"patrick.yan@pernod-ricard.com","id":"","itemgroup":"'+testrecord.itemGroupList[0].id+'","itemgroupCode":"qqq","itemgroupDesc":"","minOrderQty":20000,"opEmail_1":"ben.fong@introv.com","opEmail_2":"","opEmail_3":"","opEmail_4":"","opEmail_5":"","opEmail_6":"","opEmail_7":"","opEmail_8":"","outletid":"","outletName":"好德虹井店(ONSHA5129)","phoneNumber":"1111111","province":"上海","qty":1200,"rowcontrol":0,"sentMail":"","sirEmail_1":"patrick.yan@pernod-ricard.com","sirEmail_2":"","sirEmail_3":"","sirEmail_4":"","sirEmail_5":"","sirEmail_6":"","sirEmail_7":"","sirEmail_8":"","sirLink":"link","sirList":[],"tivNum":"","totalPrice":2330.097087,"unitPrice":2,"vat":"3%","vatId":"'+testrecord.taxcodeList[0].id+'","vatRate":3,"warehouseid":"'+testrecord.warehouseList[0].id+'","warehouseName":"直接发货 - DUMMY"}]}');
            ASI_MFM_CN_POSM_PoLineManageAllCls.submit('{"poid":"'+testrecord.po.id+'","deleteIdList":["'+testrecord.posmlineList[0].id+'"],"submitedList":[]}');
	        test.stopTest();
        }

    }
    
    public testMethod static void testTrigger() {
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
        
        /*-------MT@Introv 20190605 start
        --------Change category_map from global to local,
        --------Functions inside the ASI_MFM_CN_ItemGroup_TriggerClass add one parameter
        ----generateItemGroupCode
        ----category_2_3_Map
        ----setApprover
        */
        String strRTId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Product_Category__cASI_MFM_CN_Category_Master');
        Map<Id, ASI_HK_CRM_Product_Category__c> category_map = new Map<Id, ASI_HK_CRM_Product_Category__c>([SELECT Id, ASI_MFM_Level__c
                                                                                                                             , ASI_MFM_Buyer__c
                                                                                                                             , ASI_MFM_Buyer__r.ASI_MFM_Buyer__c
                                                                                                                             , Name
                                                                                                                             , ASI_HK_CRM_Category_Code__c
                                                                                                                             , ASI_MFM_Running_Number__c
                                                                                                                             , (SELECT Id
                                                                                                                                , ASI_MFM_Category_Level_2_3__c
                                                                                                                                , ASI_MFM_Category_Level_2_3__r.ASI_MFM_Level__c
                                                                                                                                , ASI_CRM_CN_Product_Category__c
                                                                                                                                , ASI_MFM_Category_Level_2_3__r.Name
                                                                                                                                FROM Sub_categories__r)
                                                                                                                             FROM ASI_HK_CRM_Product_Category__c 
                                                                                                                             WHERE recordTypeId = : strRTId]);
        
       //-------MT@Introv 20190605 end       
        
        System.runAs(user1) {
	        TestingRecord testrecord = new TestingRecord(user1, user2);
            
            ASI_CRM_Fix_Approval_Route__c far = new ASI_CRM_Fix_Approval_Route__c();
            
            test.startTest();
			ASI_MFM_Item_Group__c itemgroup = testrecord.itemGroupList[0];
            ASI_MFM_Stock_In_Request__c sir = testrecord.sirList[0];
            ASI_MFM_Stock_In_Request__c sir2 = testrecord.sirList[0];
            sir.ASI_MFM_Status__c = 'Confirmed';
            sir2.ASI_MFM_Status__c = 'Confirmed';
            update testrecord.sirList;
            

            ASI_MFM_CN_ItemGroup_TriggerClass.resetRunningNumber(10,0,1);
            ASI_MFM_CN_ItemGroup_TriggerClass.runningNumber(10,1);
            ASI_MFM_CN_ItemGroup_TriggerClass.channelMap();
            //ASI_MFM_CN_ItemGroup_TriggerClass.category_2_3_Map();
            ASI_MFM_CN_ItemGroup_TriggerClass.fixApprovalMap();
            //ASI_MFM_CN_ItemGroup_TriggerClass.setApprover(itemgroup,far);
            ASI_MFM_CN_ItemGroup_TriggerClass.setApproverToNull(itemgroup);
            //ASI_MFM_CN_ItemGroup_TriggerClass.generateItemGroupCode(itemgroup);


            //-------MT@Introv 20190605 start
            ASI_MFM_CN_ItemGroup_TriggerClass.category_2_3_Map(category_map);
            ASI_MFM_CN_ItemGroup_TriggerClass.setApprover(itemgroup,far,category_map);
            ASI_MFM_CN_ItemGroup_TriggerClass.generateItemGroupCode(itemgroup,category_map);
            //-------MT@Introv 20190605 end


            itemgroup.ASI_MFM_Status__c = 'Final';
            update itemgroup;
            itemgroup.ASI_MFM_Status__c = 'Draft';
            update itemgroup;
            itemgroup.ASI_MFM_Utilization_Status__c  = 'Inactive';
            update itemgroup;
            delete itemgroup;
            
            //sir2.ASI_MFM_ActualReceipt__c = 100;
            //update sir2;
            
            test.stopTest();
        }
    }
    
    public testMethod static void testPDF() {
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
            
	        TestingRecord testrecord = new TestingRecord(user1, user2);
            testrecord.createPayment(user1, user2);
            
            ASI_CRM_Fix_Approval_Route__c far = new ASI_CRM_Fix_Approval_Route__c();
            test.startTest();
            ASI_MFM_CN_POSM_TIV_PDF_Ctrller cls = new ASI_MFM_CN_POSM_TIV_PDF_Ctrller();
            cls.currentHeaderID = testrecord.posmlineList[0].id;
            Boolean b = cls.dummyVar;

            ASI_MFM_CN_POSM_ItemGroup_PDF_CTRL cls2 = new ASI_MFM_CN_POSM_ItemGroup_PDF_CTRL();
            cls2.recordId = testrecord.itemGroupList[0].id;
            b = cls2.dummyVar;
            cls2.getApprovalHisotry(testrecord.payment[0].id);
            ApexPages.Standardcontroller stdController = new ApexPages.Standardcontroller(testrecord.itemGroupList[0]); 
            cls2 = new ASI_MFM_CN_POSM_ItemGroup_PDF_CTRL(stdController);
            ASI_MFM_CN_POSM_ItemGroup_PDF_CTRL.apprivalHistoryClass cls3 = new ASI_MFM_CN_POSM_ItemGroup_PDF_CTRL.apprivalHistoryClass();
            cls3.approver = '1';
            cls3.approvedDate = '1';
            cls3.approvalStatus = '1';
            test.stopTest();
        }
    }
    /*
    //20190906:AM - copy from testMethod2 of ASI_CRM_CN_SalesOrder_Test
    public testMethod static void testCNTOVPDF() {
        system.debug('testMethod2 start');

        ASI_CRM_Region__c region_1 = new ASI_CRM_Region__c (Name='TEST');
        insert region_1;

        ASI_CRM_Division__c division_1 = new ASI_CRM_Division__c(Name='TEST', ASI_CRM_Region__c= region_1.Id);
        insert division_1;

        ASI_CRM_CN_Area__c area_1 = new ASI_CRM_CN_Area__c(Name='TEST', ASI_CRM_English_Name__c='TEST', ASI_CRM_Division__c= division_1.Id);
        insert area_1;

        ASI_CRM_City__c city_1 = new ASI_CRM_City__c(ASI_CRM_CN_City_Code__c='TEST', ASI_CRM_CN_Area__c= area_1.Id);
        insert city_1;

        ASI_CRM_CN_Channel__c channel_1 = new ASI_CRM_CN_Channel__c(ASI_CRM_CN_On_Off__c='ON');
        insert channel_1;

        List<ASI_MFM_Sub_Channel__c> tmpSubChannelList = new List<ASI_MFM_Sub_Channel__c>();
        tmpSubChannelList.add(new ASI_MFM_Sub_Channel__c(ASI_CRM_CN_Channel__c= channel_1.Id));
        tmpSubChannelList.add(new ASI_MFM_Sub_Channel__c(Name = 'VIP', ASI_CRM_CN_Channel__c= channel_1.Id));

        insert tmpSubChannelList;

        ASI_CRM_CN_Channel_Group__c ChannelGroup_1 = new ASI_CRM_CN_Channel_Group__c(
                Name = 'OFF MOT',
                ASI_CRM_Channel_Group_Chi_Name__c = 'OFF MOT',
                ASI_CRM_Channel_Group_Eng_Name__c = 'OFF MOT',
                ASI_CRM_Channel_Group_Code__c = 'CN_WS Channel',
                ASI_CRM_External_ID__c = 'CN_OFF MOT',
                ASI_CRM_Sequence__c = 8
        );
        insert ChannelGroup_1;

        ASI_CRM_CN_Channel__c newChannel_1 = new ASI_CRM_CN_Channel__c(ASI_CRM_For_Outlet__c = true, Name='Restaurant',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CN_Channel__cASI_CRM_CN_New_Channel'),ASI_CRM_CN_On_Off__c='OFF', ASI_CRM_CN_Channel_Group__c= ChannelGroup_1.Id);
        insert newChannel_1;

        List<ASI_MFM_Item_Group__c> tmpItemGroupList = new List<ASI_MFM_Item_Group__c>();

        tmpItemGroupList.add(new ASI_MFM_Item_Group__c(RecordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Item_Group__cASI_CRM_CN_CRM_Item_Group')
                , Name = 'TestItemGroup'
                , ASI_MFM_Item_Group_Code__c = 'TestItemGroupCode'
                , ASI_CRM_CN_Eng_Name__c = 'TestItemGroup'
                , OwnerID = tempU.id
                , ASI_CRM_Allocation_Information__c = true//20170217 Elufa
        ));
        insert tmpItemGroupList;

        List<ASI_CRM_Promotion_Master__c> tmpPromotionMasterList = new List<ASI_CRM_Promotion_Master__c>();
        tmpPromotionMasterList.add(new ASI_CRM_Promotion_Master__c(	OwnerId = tempU.id
                , recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Promotion_Master__cASI_CRM_CN_Promotion_Master')
        ));
        insert tmpPromotionMasterList;

        List<ASI_CRM_AccountsAdditionalField__c> tmpCustomerList = new List<ASI_CRM_AccountsAdditionalField__c>();
        //ASI_CRM_AccountsAdditionalField__c cust = new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Eng_Name__c = 'test0', ASI_CRM_CN_Chi_Name__c = 'test0', ASI_CRM_CN_Commercial_Team__c = 'Premium', ASI_CRM_CN_JDE_Code_RTD__c = '000', ASI_CRM_CN_JDE_Code__c = '000', ASI_CRM_CN_JDE_Code_Premium__c = '000', ASI_CRM_CN_Sub_Channel__c= tmpSubChannelList[0].Id, ASI_CRM_CN_CCity__c= city_1.Id, ASI_CRM_Latest_Call_Plan_Date__c=system.today(), RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN'));
        //insert cust;
        //tmpCustomerList.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Eng_Name__c = 'test1', ASI_CRM_CN_Chi_Name__c = 'test1', ASI_CRM_CN_Commercial_Team__c = 'Premium', ASI_CRM_CN_Premium_T1_WS__c  = cust.Id, ASI_CRM_CN_JDE_Code_RTD__c = '555', ASI_CRM_CN_JDE_Code__c = '111', ASI_CRM_CN_JDE_Code_Premium__c = '456', ASI_CRM_CN_Is_IHBR_Outlet__c = TRUE, ASI_CRM_CN_Sub_Channel__c= tmpSubChannelList[0].Id, ASI_CRM_CN_CCity__c= city_1.Id, RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_CN_WS'), ASI_CRM_CN_NewChannel__c = newChannel_1.Id));
        //tmpCustomerList.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Eng_Name__c = 'test2', ASI_CRM_CN_Chi_Name__c = 'test2', ASI_CRM_CN_Commercial_Team__c = 'Premium', ASI_CRM_CN_Premium_T1_WS__c  = cust.Id, ASI_CRM_CN_JDE_Code_RTD__c = '666', ASI_CRM_CN_JDE_Code__c = '222', ASI_CRM_CN_JDE_Code_Premium__c = '789', ASI_CRM_CN_Sub_Channel__c= tmpSubChannelList[1].Id, ASI_CRM_CN_CCity__c= city_1.Id, ASI_CRM_Latest_Call_Plan_Date__c=system.today(), RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_CN_WS'), ASI_CRM_CN_NewChannel__c = newChannel_1.Id));
        //
       	tmpCustomerList.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Eng_Name__c = 'test1', ASI_CRM_CN_Chi_Name__c = 'test1', ASI_CRM_CN_Commercial_Team__c = 'Premium', ASI_CRM_CN_JDE_Code_RTD__c = '555', ASI_CRM_CN_JDE_Code__c = '111', ASI_CRM_CN_JDE_Code_Premium__c = '456', ASI_CRM_CN_Is_IHBR_Outlet__c = TRUE, ASI_CRM_CN_Sub_Channel__c= tmpSubChannelList[0].Id, ASI_CRM_CN_CCity__c= city_1.Id, RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_CN_WS'), ASI_CRM_CN_NewChannel__c = newChannel_1.Id));
        tmpCustomerList.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Eng_Name__c = 'test2', ASI_CRM_CN_Chi_Name__c = 'test2', ASI_CRM_CN_Commercial_Team__c = 'Premium', ASI_CRM_CN_JDE_Code_RTD__c = '666', ASI_CRM_CN_JDE_Code__c = '222', ASI_CRM_CN_JDE_Code_Premium__c = '789', ASI_CRM_CN_Sub_Channel__c= tmpSubChannelList[1].Id, ASI_CRM_CN_CCity__c= city_1.Id, ASI_CRM_Latest_Call_Plan_Date__c=system.today(), RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_CN_WS'), ASI_CRM_CN_NewChannel__c = newChannel_1.Id));
        
        tmpCustomerList.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Eng_Name__c = 'test3', ASI_CRM_CN_Chi_Name__c = 'test3', ASI_CRM_CN_Commercial_Team__c = 'Premium', ASI_CRM_CN_JDE_Code_RTD__c = '777', ASI_CRM_CN_JDE_Code__c = '333', ASI_CRM_CN_JDE_Code_Premium__c = '123', ASI_CRM_CN_Sub_Channel__c= tmpSubChannelList[0].Id, ASI_CRM_CN_CCity__c= city_1.Id, ASI_CRM_Latest_Call_Plan_Date__c=system.today(), RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN')));
        insert tmpCustomerList;

        List<ASI_KOR_Sales_Order_Request__c> tmpSalesOrderList = new List<ASI_KOR_Sales_Order_Request__c>();

        tmpSalesOrderList.add(new ASI_KOR_Sales_Order_Request__c(OwnerId = tempU.id
                , ASI_KOR_Order_Status__c = 'Open'
                , ASI_CRM_CN_Customer__c = tmpCustomerList[0].id
                , ASI_CRM_CN_RTD__c = FALSE
                , recordTypeId = Global_RecordTypeCache.getRtId('ASI_KOR_Sales_Order_Request__cASI_CRM_CN_SalesOrder')
        ));
        tmpSalesOrderList.add(new ASI_KOR_Sales_Order_Request__c(OwnerId = tempU.id
                , ASI_KOR_Order_Status__c = 'Open'
                , ASI_CRM_CN_Customer__c = tmpCustomerList[2].id
                , ASI_CRM_CN_RTD__c = False
                , recordTypeId = Global_RecordTypeCache.getRtId('ASI_KOR_Sales_Order_Request__cASI_CRM_CN_SalesOrder')
        ));
        tmpSalesOrderList.add(new ASI_KOR_Sales_Order_Request__c(OwnerId = tempU.id
                , ASI_KOR_Order_Status__c = 'Open'
                , ASI_CRM_CN_Customer__c = tmpCustomerList[1].id
                , ASI_CRM_CN_RTD__c = FALSE
                , recordTypeId = Global_RecordTypeCache.getRtId('ASI_KOR_Sales_Order_Request__cASI_CRM_CN_SalesOrder')
        ));
        tmpSalesOrderList.add(new ASI_KOR_Sales_Order_Request__c(OwnerId = tempU.id
                , ASI_KOR_Order_Status__c = 'Open'
                , ASI_CRM_CN_Customer__c = tmpCustomerList[1].id
                , ASI_CRM_CN_RTD__c = False
                , recordTypeId = Global_RecordTypeCache.getRtId('ASI_KOR_Sales_Order_Request__cASI_CRM_CN_SalesOrder')
        ));
        insert tmpSalesOrderList;

        List<ASI_KOR_Sales_Order_Transaction__c> tmpSalesOrderLineItemList = new List<ASI_KOR_Sales_Order_Transaction__c>();

        tmpSalesOrderLineItemList.add(new ASI_KOR_Sales_Order_Transaction__c(ASI_CRM_CN_Product_Name__c = tmpItemGroupList[0].id
                , ASI_KOR_Order_Qty__c = 1
                , ASI_CRM_CN_Unit_Price_BT_with_VAT__c = 1
                , ASI_CRM_CN_Promotion_Code__c = tmpPromotionMasterList[0].id
                , recordTypeId = Global_RecordTypeCache.getRtId('ASI_KOR_Sales_Order_Transaction__cASI_CRM_CN_SalesOrder_Item')
                , ASI_KOR_Sales_Order_Request__c = tmpSalesOrderList[0].id
                , ASI_CRM_Allocation_Information__c = true
        ));
        tmpSalesOrderLineItemList.add(new ASI_KOR_Sales_Order_Transaction__c(ASI_CRM_CN_Product_Name__c = tmpItemGroupList[0].id
                , ASI_KOR_Order_Qty__c = 1
                , ASI_CRM_CN_Unit_Price_BT_with_VAT__c = 1
                , ASI_CRM_CN_Promotion_Code__c = tmpPromotionMasterList[0].id
                , recordTypeId = Global_RecordTypeCache.getRtId('ASI_KOR_Sales_Order_Transaction__cASI_CRM_CN_SalesOrder_Item')
                , ASI_KOR_Sales_Order_Request__c = tmpSalesOrderList[1].id
                , ASI_CRM_Allocation_Information__c = true
        ));
        tmpSalesOrderLineItemList.add(new ASI_KOR_Sales_Order_Transaction__c(ASI_CRM_CN_Product_Name__c = tmpItemGroupList[0].id
                , ASI_KOR_Order_Qty__c = 1
                , ASI_CRM_CN_Unit_Price_BT_with_VAT__c = 1
                , ASI_CRM_CN_Promotion_Code__c = tmpPromotionMasterList[0].id
                , recordTypeId = Global_RecordTypeCache.getRtId('ASI_KOR_Sales_Order_Transaction__cASI_CRM_CN_SalesOrder_Item')
                , ASI_KOR_Sales_Order_Request__c = tmpSalesOrderList[2].id
                , ASI_CRM_Allocation_Information__c = true
        ));
        tmpSalesOrderLineItemList.add(new ASI_KOR_Sales_Order_Transaction__c(ASI_CRM_CN_Product_Name__c = tmpItemGroupList[0].id
                , ASI_KOR_Order_Qty__c = 1
                , ASI_CRM_CN_Unit_Price_BT_with_VAT__c = 1
                , ASI_CRM_CN_Promotion_Code__c = tmpPromotionMasterList[0].id
                , recordTypeId = Global_RecordTypeCache.getRtId('ASI_KOR_Sales_Order_Transaction__cASI_CRM_CN_SalesOrder_Item')
                , ASI_KOR_Sales_Order_Request__c = tmpSalesOrderList[3].id
                , ASI_CRM_Allocation_Information__c = true
        ));
        insert tmpSalesOrderLineItemList;

        List<ASI_CRM_Order_Form__c> tmpOrderFormList = new List<ASI_CRM_Order_Form__c>();

        tmpOrderFormList.add(new ASI_CRM_Order_Form__c(RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Order_Form__cASI_CRM_CN_Order_Form')
                , ASI_CRM_Order_Form_Name__c = 'TestOrderForm'
                , ASI_CRM_Order_Form_Type__c = 'Normal Item'
                , ASI_CRM_T1_Master__c = TRUE
                , OwnerID = tempU.id
        ));
        tmpOrderFormList.add(new ASI_CRM_Order_Form__c(RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Order_Form__cASI_CRM_CN_Order_Form')
                , ASI_CRM_Order_Form_Name__c = 'TestOrderForm'
                , ASI_CRM_Order_Form_Type__c = 'RTD'
                , ASI_CRM_T1_Master__c = TRUE
                , OwnerID = tempU.id
        ));
        tmpOrderFormList.add(new ASI_CRM_Order_Form__c(RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Order_Form__cASI_CRM_CN_Order_Form')
                , ASI_CRM_Order_Form_Name__c = 'TestOrderForm'
                , ASI_CRM_Order_Form_Type__c = 'Premium'
                , ASI_CRM_T1_Master__c = TRUE
                , OwnerID = tempU.id
        ));
        insert tmpOrderFormList;

        List<ASI_CRM_Order_Form_Detail__c> tmpOrderFormLineItemList = new List<ASI_CRM_Order_Form_Detail__c>();

        tmpOrderFormLineItemList.add(new ASI_CRM_Order_Form_Detail__c(RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Order_Form_Detail__cASI_CRM_CN_Order_Form_Detail')
                , ASI_CRM_Available__c = TRUE
                , ASI_CRM_Order_Form__c = tmpOrderFormList[0].id
                , ASI_CRM_Product_Name__c = tmpItemGroupList[0].id
                , ASI_CRM_Remark__c = 'TestRemark'
                , ASI_CRM_Sequence__c = 1//20170217 Elufa
        ));
        tmpOrderFormLineItemList.add(new ASI_CRM_Order_Form_Detail__c(RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Order_Form_Detail__cASI_CRM_CN_Order_Form_Detail')
                , ASI_CRM_Available__c = TRUE
                , ASI_CRM_Order_Form__c = tmpOrderFormList[1].id
                , ASI_CRM_Product_Name__c = tmpItemGroupList[0].id
                , ASI_CRM_Remark__c = 'TestRemark'
                , ASI_CRM_Sequence__c = 1//20170217 Elufa
        ));
        tmpOrderFormLineItemList.add(new ASI_CRM_Order_Form_Detail__c(RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Order_Form_Detail__cASI_CRM_CN_Order_Form_Detail')
                , ASI_CRM_Available__c = TRUE
                , ASI_CRM_Order_Form__c = tmpOrderFormList[2].id
                , ASI_CRM_Product_Name__c = tmpItemGroupList[0].id
                , ASI_CRM_Remark__c = 'TestRemark'
                , ASI_CRM_Sequence__c = 1//20170217 Elufa
        ));
        insert tmpOrderFormLineItemList;

        List<ASI_CRM_Order_Form_Customer_Relationship__c> tmpOFCRList = new List<ASI_CRM_Order_Form_Customer_Relationship__c>();
        tmpOFCRList.add(new ASI_CRM_Order_Form_Customer_Relationship__c(RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Order_Form_Customer_Relationship__cASI_CRM_CN_Order_Form_Customer_Relationship'), ASI_CRM_Customer__c = tmpCustomerList[1].id, ASI_CRM_Order_Form__c = tmpOrderFormList[0].id));
        tmpOFCRList.add(new ASI_CRM_Order_Form_Customer_Relationship__c(RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Order_Form_Customer_Relationship__cASI_CRM_CN_Order_Form_Customer_Relationship'), ASI_CRM_Customer__c = tmpCustomerList[1].id, ASI_CRM_Order_Form__c = tmpOrderFormList[1].id));
        tmpOFCRList.add(new ASI_CRM_Order_Form_Customer_Relationship__c(RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Order_Form_Customer_Relationship__cASI_CRM_CN_Order_Form_Customer_Relationship'), ASI_CRM_Customer__c = tmpCustomerList[1].id, ASI_CRM_Order_Form__c = tmpOrderFormList[2].id));
        tmpOFCRList.add(new ASI_CRM_Order_Form_Customer_Relationship__c(RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Order_Form_Customer_Relationship__cASI_CRM_CN_Order_Form_Customer_Relationship'), ASI_CRM_Customer__c = tmpCustomerList[1].id, ASI_CRM_Order_Form__c = tmpOrderFormList[2].id));

        insert tmpOFCRList;

        ASI_CRM_TOV__c tmpTOV = new ASI_CRM_TOV__c(ASI_CRM_Status__c = 'Draft'
                , recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_TOV__cASI_CRM_CN_TOV')
                , ASI_CRM_SF_SO_Request_Number__c = tmpSalesOrderList[0].id
        );
        insert tmpTOV;
        update tmpTOV;

        ASI_CRM_CN_Field_ID_Mapping__c tmpCustomeObject = new ASI_CRM_CN_Field_ID_Mapping__c(Name = 'SalesOrder Field Id');
        insert tmpCustomeObject;

        //20190906:AM - add TOV line
        ASI_CRM_TOV_Detail__c tmpTOVLine = new ASI_CRM_TOV_Detail__c(
            	ASI_CRM_TOV__c = tmpTOV.id
                , recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_TOV_Detail__cASI_CRM_CN_CN_TOV_Detail')
                , ASI_CRM_Order_QTY__c = 10.0
        );
        insert tmpTOVLine;
        
        //21080718 Introv
        Test.setCurrentPage(Page.ASI_CRM_CN_TOV_PDF);
        Apexpages.currentPage().getParameters().put('id', tmpTOV.id);
        ASI_CRM_CN_TOV_PDF_Controller tovPDFCTRL = new ASI_CRM_CN_TOV_PDF_Controller();
        tovPDFCTRL.currentHeaderID = tmpTOV.id;
        tovPDFCTRL.dummyVar = false;
        tovPDFCTRL.lineItemFGR = null;
        tovPDFCTRL.lineItem = null;
        tovPDFCTRL.totalQty = 0;
        tovPDFCTRL.init();

        system.debug('testMethod2 end');
    }
    */
    public class TestingRecord {
        public list<User> users;
        public ASI_MFM_Fix_Approval_Route__c fapp;
        public ASI_MFM_Dynamic_Approval_Route__c dapp;
        public list<ASI_MFM_Prefix__c> prefixs;
        public list<ASI_MFM_Role_Prefix_Relationship__c> prefixChilds;
        public list<ASI_MFM_A_C_Code__c> acs;
        public ASI_MFM_PP_Category__c ppc;
        public list<ASI_MFM_PP_Category_A_C__c> ppcacs;
        public ASI_MFM_Market_Strategy__c mms;
		public List<ASI_MFM_Plan__c> planList;
        public ASI_MFM_Brand__c brand;
        public list<ASI_MFM_Sub_brand__c> subBrands;
		public list<Account> accs;
		public ASI_MFM_Plan_Line_Item__c planLineItem1;
        public ASI_MFM_BU__c bu;
        public ASI_MFM_Exchange_Rate__c ex;
        public ASI_MFM_PO__c po;
        public ASI_MFM_PO_Line_Item__c poli;
        public List<ASI_HK_CRM_Product_Category__c> ProductCategoryList;
        public List<ASI_TH_CRM_Sub_category__c> SubCategoryList;
        public List<ASI_MFM_Item_Group__c> itemGroupList;
        List<ASI_CRM_Product_Warehouse_Photo__c> whPhotoList;
        public List<ASI_MFM_PO_POSM_Line__c> posmlineList;
        public List<ASI_FOC_Warehouse__c> warehouseList;
        public List<ASI_MFM_Tax_Code__c> taxcodeList;
        
        public List<ASI_MFM_Stock_In_Request__c> sirList;
        
        public List<ASI_MFM_Expense_Control_Form__c> expenseControlForm;
        public List<ASI_MFM_Rental_Request__c> rentalRequest;
        public List<ASI_MFM_Payment__c> payment;
        public List<ASI_MFM_Payment_Detail__c> paymentline;
        public List<ASI_MFM_Rental_Request_Line__c> rentalDetail;
        
        List<ASI_CRM_Fix_Approval_Route__c> tmpFixRoute;
        public List<ASI_CRM_Dynamic_Approval_Route__c> LDynApproval;
        
        public TestingRecord(User user1, User user2){
            
            String strRTID;
            //create fix approval route
            strRTId = Global_RecordTypeCache.getRtId('ASI_MFM_Fix_Approval_Route__cASI_MFM_CN_Fix_Approval_Route');
            fapp = new ASI_MFM_Fix_Approval_Route__c(ASI_MFM_Module__c='PO', ASI_MFM_Team__c ='ABCD', ownerid = user2.id, ASI_MFM_Finance__c = user2.id);
            insert fapp;
            
            //create dynamic approval route
            strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_Dynamic_Approval_Route__c','ASI_MFM_CN_Dynamic_Approval_Route');
            dapp = new ASI_MFM_Dynamic_Approval_Route__c(recordtypeid=strRTId, ASI_MFM_Type__c='PO', ASI_MFM_User__c=user2.id, ASI_MFM_Approval_Limit__c=30000, ASI_MFM_End_of_1st_Route__c=true);
            insert dapp;
            
            prefixs = new list<ASI_MFM_Prefix__c>();
            prefixs.add(new ASI_MFM_Prefix__c(Name='CN',ASI_MFM_Module__c='Plan',Plan_Type__c='Allowance & Discount Spending Form'
                                              ,ASI_MFM_Fiscal_year__c=getFiscalYear(),ownerId = user1.id));
            
            //create prefix po
            strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_Prefix__c','ASI_MFM_CN_Prefix');
            prefixs.add(new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO', recordTypeId=strRTID,
                                              ASI_MFM_Fiscal_year__c=getFiscalYear(), ASI_MFM_Next_Number__c=86));
            
            prefixs.add(new ASI_MFM_Prefix__c(Name='CNSCP'
                                              , recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_CN_Prefix')
                                              , ASI_MFM_Module__c='Payment'
                                              , ASI_MFM_Fiscal_year__c = getFiscalYear()
                                              , ASI_MFM_Next_Number__c = 0
                                              , ownerId = user1.id));
            prefixs.add(new ASI_MFM_Prefix__c(Name='CNSCB'
                                              , recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_CN_Prefix')
                                              , ASI_MFM_Module__c='Structure Cost Budget'
                                              , ASI_MFM_Fiscal_year__c = getFiscalYear()
                                              , ASI_MFM_Next_Number__c = 0
                                              , ownerId = user1.id));
            insert prefixs;
            List<ASI_MFM_Role_Prefix_Relationship__c> prlist = new List<ASI_MFM_Role_Prefix_Relationship__c>();
            prlist.add(new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=prefixs[2].id, ASI_MFM_Role_Name__c=user1.userRole.developerName));
            prlist.add(new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=prefixs[3].id, ASI_MFM_Role_Name__c=user1.userRole.developerName));
        	insert prlist;
            
            prefixChilds = new list<ASI_MFM_Role_Prefix_Relationship__c>();
            prefixChilds.Add(new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c = prefixs[0].Id,
                                                                     ASI_MFM_Role_Name__c =user1.userRole.developerName));            
            prefixChilds.Add(new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c = prefixs[1].Id,
                                                                     ASI_MFM_Role_Name__c =user1.userRole.developerName));            
            
            insert prefixChilds;
            
            strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_A_C_Code__c','ASI_MFM_CN_A_C_Code');
            acs = new list<ASI_MFM_A_C_Code__c>();
            acs.add(new ASI_MFM_A_C_Code__c(recordtypeid=strRTId, name='testAC1', ASI_MFM_A_C_Code__c = '5600.000'));
            acs.add(new ASI_MFM_A_C_Code__c(recordtypeid=strRTId, name='testAC2', ASI_MFM_A_C_Code__c = '5600.300'));
            acs.add(new ASI_MFM_A_C_Code__c(name='testAC', recordtypeid=strRTId ));
            insert acs;
            
            strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_PP_Category__c','ASI_MFM_CN_PP_Category');   
            ppc = new ASI_MFM_PP_Category__c(recordtypeid=strRTId , Name='NTMCD - KTV Promotion', ASI_MFM_External_ID__c='NTMCD - KTV Promotion (CN)1');
            insert ppc;
            
            strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_PP_Category_A_C__c','ASI_MFM_CN_PP_Category_A_C'); 
            ppcacs = new list<ASI_MFM_PP_Category_A_C__c>();
            ppcacs.add(new ASI_MFM_PP_Category_A_C__c(ASI_MFM_External_ID__c='test', recordtypeid=strRTId , ASI_MFM_A_C_Code__c=acs[0].id, ASI_MFM_PP_Category__c=ppc.id));
            ppcacs.add(new ASI_MFM_PP_Category_A_C__c(ASI_MFM_External_ID__c='test2', recordtypeid=strRTId , ASI_MFM_A_C_Code__c=acs[1].id,ASI_MFM_PP_Category__c=ppc.id));
            insert ppcacs; 
            
            mms = new ASI_MFM_Market_Strategy__c(name='12004 Chivas', ASI_MFM_External_ID__c='120041',ASI_MFM_Fiscal_Year__c=getFiscalYear(), ASI_MFM_Sub_brand__c='CH2,CH3,CHF,CHU');
            insert mms;
            
            strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_Plan__c','ASI_MFM_CN_Plan'); 
            
            planList = new List<ASI_MFM_Plan__c>();
            
            ASI_MFM_Plan__c Plan1 = new ASI_MFM_Plan__c(Name='CNM131',ASI_MFM_Prefix__c=prefixs[0].Id
                                                        ,recordTypeId=strRTId ,
                                                        ASI_MFM_End_Date__c = Date.today().addMonths(1), ASI_MFM_Plan_Description__c='testDescription', 
                                                        ASI_MFM_Plan_Name__c='plannameTest', ASI_MFM_Start_Date__c=Date.today(), ASI_MFM_Budget_Owner__c=user1.id, 
                                                        ASI_MFM_PP_Category__c = ppc.id, ASI_MFM_Market_Strategy__c=mms.id, ASI_MFM_Status__c='Final', OwnerId =user1.id);
            
            ASI_MFM_Plan__c Plan2 = new ASI_MFM_Plan__c(Name='CNM131',ASI_MFM_Prefix__c=prefixs[0].Id
                                                        ,recordTypeId=strRTId ,
                                                        ASI_MFM_End_Date__c = Date.today().addMonths(1), ASI_MFM_Plan_Description__c='testDescription', 
                                                        ASI_MFM_Plan_Name__c='plannameTest', ASI_MFM_Start_Date__c=Date.today(), ASI_MFM_Budget_Owner__c=user1.id, 
                                                        ASI_MFM_PP_Category__c = ppc.id, ASI_MFM_Market_Strategy__c=mms.id, ASI_MFM_Status__c='Final', OwnerId =user1.id);
            
            planList.add(plan1);
            planList.add(plan2);
            
            
            
            insert planList;
            

            
            
            //create brand
            strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_Brand__c','ASI_MFM_CN_Brand');
            brand = new ASI_MFM_Brand__c(name='brandname',Recordtypeid=strRTId);
            insert brand; 
            
            subBrands = new list<ASI_MFM_Sub_brand__c>();
            //create sub brand
            strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_Sub_brand__c','ASI_FOC_CN_Sub_brand');
            subBrands.add(new ASI_MFM_Sub_brand__c(Name='subBrand1' ,recordTypeId=strRTId,ASI_MFM_Active_for_POSM__c=true));
            subBrands.add(new ASI_MFM_Sub_brand__c(Name='subBrand2' ,recordTypeId=strRTId,ASI_MFM_Active_for_POSM__c=true));
            subBrands.add(new ASI_MFM_Sub_brand__c(Name='testSb',recordtypeid=strRTId,ASI_MFM_Brand__c=brand.id,ASI_MFM_Active_for_POSM__c=true));
            insert subBrands;
            
            accs = new list<Account>();
            
            strRTId = ASI_MFM_Function.checkRecordType('Account','ASI_MFM_CN_Outlet'); 
            accs.add(new Account(recordTypeId=strRTId ,Name='Name3'));
            
            //ASI_MFM_CN_Supplier 
            strRTId = ASI_MFM_Function.checkRecordType('Account','ASI_MFM_CN_Supplier');
            Account supplier = new Account(Name='TestAcc', recordTypeId=strRTId , ASI_MFM_Customer_Supplier_Number__c='123',
                                 ASI_MFM_Customer_Supplier_Name__c='SupplierName');
            accs.add(supplier);
            accs.add(new Account(Name='TestAcc', recordTypeId=Global_RecordTypeCache.getRtId('AccountASI_MFM_CN_Structure_Cost_Supplier') , ASI_MFM_Customer_Supplier_Number__c='123',
                                 ASI_MFM_Customer_Supplier_Name__c='SupplierName'));
            insert accs;
            
            strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_Plan_Line_Item__c','ASI_MFM_CN_Plan_Line_Item');
            planLineItem1 = new ASI_MFM_Plan_Line_Item__c(ASI_MFM_Plan__c = Plan1.id
                                                                                    ,ASI_MFM_Sub_brand_Code__c = subBrands[2].id,ASI_MFM_List_Item_Description__c='hello1'
                                                                                    ,recordTypeId=strRTId , ASI_MFM_Total_Cost__c =120000,
                                                                                    ASI_MFM_A_C_Code__c=acs[2].id
                                                                                   );
            insert planLineItem1; 
            
            //create BU Code
            strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_BU__c','ASI_MFM_CN_BU');
            //bu = new ASI_MFM_BU__c(Name='BUCode', ASI_MFM_BU_Code__c=strRTId , ASI_MFM_CN_Country__c='CN',ASI_MFM_Base_Currency__c='RMB');
            bu = new ASI_MFM_BU__c(Name='BUCode', ASI_MFM_BU_Code__c = 'Test' , ASI_MFM_CN_Country__c='CN', ASI_MFM_Base_Currency__c='RMB', recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_BU__cASI_MFM_CN_BU'));
            
            insert bu;
            
            
            
            //create exchange rate reference
            ex = new ASI_MFM_Exchange_Rate__c(ASI_MFM_Country__c='CN',ASI_MFM_Effective_Date__c=Date.today(),
                                                                       ASI_MFM_Exchange_Rate__c=7.77500, ASI_MFM_Counter_Currency__c='USD', ASI_MFM_Base_Currency__c='RMB',
                                                                       ASI_MFM_Application__c='MFM' );
            insert ex;
            
            //create po
            //strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_PO__c','ASI_MFM_CN_PO');
            strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_PO__c','ASI_MFM_CAP_CN_Structure_Cost');
            po = new ASI_MFM_PO__c(Name='PO11111', RecordTypeId=strRTId , ASI_MFM_Prefix__c=prefixs[3].id, ASI_MFM_Remarks__c='Remarks',
                                   ASI_MFM_BU_Code__c=bu.id, ASI_MFM_Supplier_Name__c=accs[1].id, ASI_MFM_Currency__c='USD',ASI_MFM_Exchange_Rate__c=7.77500,
                                   ASI_MFM_PO_Start_Date__c=Date.today(),ASI_MFM_PO_End_Date__c=Date.today(),
                                   ASI_MFM_Budget_Owner__c =user1.id, ASI_MFM_Plan__c=Plan1.id );
            insert po;
            ASI_MFM_PO__c newpo = [SELECT id,Name FROM ASI_MFM_PO__c WHERE id=:po.id Limit 1];
            po.name = newpo.name;
            
            //create po line item
            strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_PO_Line_Item__c','ASI_MFM_CN_PO_Line_Item');
            poli = new ASI_MFM_PO_Line_Item__c(RecordTypeId=strRTId, ASI_MFM_PO__c=po.id, ASI_MFM_G_L_Date__c=Date.today(),ASI_MFM_Sub_brand_Code__c=subBrands[2].id,
                                               ASI_MFM_A_C_Code__c = acs[2].id, ASI_MFM_Customer_Name__c=accs[0].id, ASI_MFM_Amount__c=1000,ASI_MFM_Exchange_Rate__c=7.77500  );
            insert poli;
            
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
            
            itemGroupList = new List<ASI_MFM_Item_Group__c>();
            strRTId = Global_recordTypeCache.getRtId('ASI_MFM_Item_Group__cASI_MFM_CN_New_POSM_Item_Group');
            ASI_MFM_Item_Group__c newItemGroup = new ASI_MFM_Item_Group__c(name='System autoupdate, do not change.',ASI_MFM_Bundle_Item_Group__c=false,
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
                                                                            ,RecordTypeId=strRTId);
            itemGroupList.add(newItemGroup);
            insert itemGroupList;
            
            whPhotoList = new List<ASI_CRM_Product_Warehouse_Photo__c>();
            strRTId = Global_RecordTypeCache.getRtId('ASI_CRM_Product_Warehouse_Photo__cASI_MFM_CN_POSM_Final_Artwork_Photo');
			whPhotoList.add(new ASI_CRM_Product_Warehouse_Photo__c(RecordTypeId=strRTId,ASI_CRM_Item_Group__c=newItemGroup.id));
            strRTId = Global_RecordTypeCache.getRtId('ASI_CRM_Product_Warehouse_Photo__cASI_MFM_CN_POSM_Photo');
			whPhotoList.add(new ASI_CRM_Product_Warehouse_Photo__c(RecordTypeId=strRTId,ASI_CRM_Item_Group__c=newItemGroup.id));
            insert whPhotoList;
            
            ASI_CRM_Region__c region = new ASI_CRM_Region__c (Name='TEST');
	        insert region;
            ASI_CRM_Division__c division = new ASI_CRM_Division__c(Name='TEST', ASI_CRM_Region__c=region.Id);
            insert division;
            
            ASI_CRM_CN_Area__c area = new ASI_CRM_CN_Area__c(Name='TEST', ASI_CRM_English_Name__c='TEST', ASI_CRM_Division__c=division.Id);
            insert area;
            
            ASI_CRM_City__c city = new ASI_CRM_City__c(Name='TEST', ASI_CRM_CN_Area__c=area.Id);
            insert city;
            
            warehouseList = new List<ASI_FOC_Warehouse__c>();
            strRTId = Global_recordTypeCache.getRtId('ASI_FOC_Warehouse__cASI_FOC_CN_Warehouse');
            ASI_FOC_Warehouse__c warehouse = new ASI_FOC_Warehouse__c(RecordTypeId=strRTId,ASI_FOC_Warehouse_Code__c='1111',Name='test',ASI_FOC_Warehouse_Type__c='11122'
                                                                     ,ASI_FOC_Warehouse_Description__c='zxc',ASI_MFM_Direct_Delivery__c=false,ASI_FOC_Warehouse_Address__c='addr'
                                                                     ,ASI_FOC_Contact__c='nnn',ASI_FOC_SIR_Email_Address_1__c='abc@aaaa.com',ASI_MFM_Operation_Team_Email_1__c='bbb@ddd.com'
                                                                     ,ASI_FOC_Phone_Number__c='123123123',ASI_FOC_Region__c=region.id,ASI_FOC_City__c=city.id);
            warehouseList.add(warehouse);
            insert warehouseList;
            
            posmlineList = new List<ASI_MFM_PO_POSM_Line__c>();
            strRTId = Global_recordTypeCache.getRtId('ASI_MFM_PO_POSM_Line__cASI_MFM_CN_PO_POSM_Line');
            ASI_MFM_PO_POSM_Line__c posmline1 = new ASI_MFM_PO_POSM_Line__c(RecordTypeId=strRTId,ASI_MFM_PO__c=po.id,ASI_MFM_Item_Group__c=newItemGroup.id,ASI_MFM_Unit_Price__c=11,ASI_MFM_Quantity__c=100
                                                                           ,ASI_MFM_Contact_Person__c='11',ASI_MFM_Detail_Address__c='1222',ASI_MFM_Phone_Number__c='123',ASI_MFM_City__c='33aa'
                                                                           ,ASI_MFM_Province__c='xxxx',ASI_MFM_Delivery_Address_Warehouse__c=warehouse.id);
            posmlineList.add(posmline1);
            insert posmlineList;
            
			sirList = new List<ASI_MFM_Stock_In_Request__c>();
            strRTId = Global_recordTypeCache.getRtId('ASI_MFM_Stock_In_Request__cASI_MFM_CN_Stock_In_Request');
            ASI_MFM_Stock_In_Request__c sir1 = new ASI_MFM_Stock_In_Request__c(RecordTypeId=strRTId,ASI_MFM_PO_POSM_Line_Number__c=posmline1.id,ASI_MFM_Height__c=1,ASI_MFM_Length__c=1,ASI_MFM_PO_Number__c=po.id
                                                                               ,ASI_MFM_Status__c='Pending Confirm',ASI_MFM_Timestamp__c=DateTime.now().getTime()+'', ASI_MFM_Width__c=1,ASI_MFM_TIV_Note_Sent__c=false
                                                                               ,ASI_Delivery_Date__c=Date.today());
            ASI_MFM_Stock_In_Request__c sir2 = new ASI_MFM_Stock_In_Request__c(RecordTypeId=strRTId,ASI_MFM_PO_POSM_Line_Number__c=posmline1.id,ASI_MFM_Height__c=1,ASI_MFM_Length__c=1,ASI_MFM_PO_Number__c=po.id, ASI_MFM_TIV_Number__c='123123'
                                                                               ,ASI_MFM_Status__c='Confirmed',ASI_MFM_Timestamp__c=DateTime.now().getTime()+'', ASI_MFM_Width__c=1,ASI_MFM_TIV_Note_Sent__c=false
                                                                               ,ASI_Delivery_Date__c=Date.today());
            sirList.add(sir1);
            sirList.add(sir2);
            insert sirList;
            
            taxcodeList = new List<ASI_MFM_Tax_Code__c>();
            strRTId = Global_recordTypeCache.getRtId('ASI_MFM_Tax_Code__cASI_MFM_CN_Tax_Code');
            ASI_MFM_Tax_Code__c taxcode = new ASI_MFM_Tax_Code__c(RecordTypeId=strRTId,name='11',ASI_MFM_VAT_Rate__c=10);
            taxcodeList.add(taxcode);
            insert taxcodeList;
            
            for(ASI_MFM_PO_POSM_Line__c objPPL : posmlineList){
                objPPL.ASI_MFM_Operation_Team_Email_1__c = 'test@test.com';
            }
            update posmlineList;
        }
        
        public void createPayment(User user1, User user2){
            expenseControlForm = new List<ASI_MFM_Expense_Control_Form__c>();
            expenseControlForm.add(new ASI_MFM_Expense_Control_Form__c(Name = 'Test'
                                                                   , ASI_MFM_BU__c = bu.id
                                                                   , ASI_MFM_Allocation__c = True
                                                                   , ASI_MFM_AllocationMethod__c = 'Sales/Non-Sales'
                                                                   , ASI_MFM_BudgetControlLevel__c = 'By Department'
                                                                   , ASI_MFM_BudgetControlMethod__c = True
                                                                   , ASI_MFM_BudgetOwner__c = userInfo.getUserId()
                                                                   , ASI_MFM_Department__c = 'Admin'
                                                                   , ASI_MFM_ExpenseType__c = 'Testing Fee'
                                                                   , ASI_MFM_PercentageAmount__c = 'Amount'
                                                                   , ASI_MFM_PP_Category__c = ppc.id
                                                                   , ASI_MFM_Reclassification__c = 'test'
                                                                   , ASI_MFM_Sub_Brand__c = subBrands[0].id
                                                                   , ASI_MFM_Subledger_Options__c = 'test'
                                                                   , ASI_MFM_Subledger__c = True
                                                                   , recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Expense_Control_Form__cASI_MFM_CN_Expense_Control_Form')
                                                                  ));
        
	        Insert expenseControlForm;
            
            User tempU = [select id from user where CompanyName = 'Pernod Ricard China' AND ManagerId != null AND isActive = true limit 1];
            tmpFixRoute = new List<ASI_CRM_Fix_Approval_Route__c>();
            tmpFixRoute.add(new ASI_CRM_Fix_Approval_Route__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Fix_Approval_Route__cASI_CRM_CN_Fix_Approval_Route'), ASI_CRM_CN_Approver_1__c = tempU.id, ASI_CRM_CN_Approver_2__c = tempU.id, ASI_CRM_Sys_Approver_1__c = tempU.id, ASI_CRM_CN_Type__c = 'Rental Renovation Form', ASI_MFM_Expense_Control_Form__c = expenseControlForm[0].id, ASI_MFM_BU__c = bu.id, ASI_MFM_Department__c = 'Admin'));
            tmpFixRoute.add(new ASI_CRM_Fix_Approval_Route__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Fix_Approval_Route__cASI_CRM_CN_Fix_Approval_Route'), ASI_CRM_CN_Approver_1__c = tempU.id, ASI_CRM_CN_Approver_2__c = tempU.id, ASI_CRM_Sys_Approver_1__c = tempU.id, ASI_CRM_CN_Type__c = 'Structure Cost Payment', ASI_MFM_Expense_Control_Form__c = expenseControlForm[0].id, ASI_MFM_BU__c = bu.id, ASI_MFM_Department__c = 'Admin'));
            tmpFixRoute.add(new ASI_CRM_Fix_Approval_Route__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Fix_Approval_Route__cASI_CRM_CN_Fix_Approval_Route'), ASI_CRM_CN_Approver_1__c = tempU.id, ASI_CRM_CN_Approver_2__c = tempU.id, ASI_CRM_Sys_Approver_1__c = tempU.id, ASI_CRM_CN_Type__c = 'Rental Approval Form', ASI_MFM_Expense_Control_Form__c = expenseControlForm[0].id, ASI_MFM_BU__c = bu.id, ASI_MFM_Department__c = 'Admin'));
            tmpFixRoute.add(new ASI_CRM_Fix_Approval_Route__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Fix_Approval_Route__cASI_CRM_CN_Fix_Approval_Route'), ASI_CRM_CN_Approver_1__c = tempU.id, ASI_CRM_CN_Approver_2__c = tempU.id, ASI_CRM_Sys_Approver_1__c = tempU.id, ASI_CRM_CN_Type__c = 'Rental Request Form', ASI_MFM_Expense_Control_Form__c = expenseControlForm[0].id, ASI_MFM_BU__c = bu.id, ASI_MFM_Department__c = 'Admin'));
            
            insert tmpFixRoute;
            
            LDynApproval = new List<ASI_CRM_Dynamic_Approval_Route__c>();
            LDynApproval.add(new ASI_CRM_Dynamic_Approval_Route__c(ASI_CRM_Type__c='Payment',ASI_CRM_Approval_Limit__c=0,ASI_CRM_End_of_Dynamic_Route__c=true));
            LDynApproval.add(new ASI_CRM_Dynamic_Approval_Route__c(ASI_CRM_Type__c='Last Payment',ASI_CRM_Approval_Limit__c=0,ASI_CRM_End_of_Dynamic_Route__c=true));
            insert LDynApproval ;
            
            list<ASI_CRM_Fix_Approval_Route__c> fars = new list<ASI_CRM_Fix_Approval_Route__c>();
            fars.add(new ASI_CRM_Fix_Approval_Route__c(ASI_CRM_CN_Type__c = 'Payment 1st Part',ASI_CRM_CN_Region_Area_Channel__c='TEST',ASI_CRM_CN_Entry_Limit__c=0,
                                                       ASI_CRM_CN_Approver_1__c = user2.id,ASI_CRM_CN_Approval_Limit_1__c=0,
                                                       ASI_CRM_CN_Approver_2__c = user2.id,ASI_CRM_CN_Approval_Limit_2__c=0,
                                                       ASI_CRM_CN_Approver_3__c = user2.id,ASI_CRM_CN_Approval_Limit_3__c=0,
                                                       ASI_CRM_CN_Approver_4__c = user2.id,ASI_CRM_CN_Approval_Limit_4__c=0,
                                                       ASI_CRM_CN_Approver_5__c = user2.id,ASI_CRM_CN_Approval_Limit_5__c=0,
                                                       ASI_CRM_CN_Approver_6__c = user2.id, ASI_CRM_Sales_Team__c = 'a'));
            fars.add(new ASI_CRM_Fix_Approval_Route__c(ASI_CRM_CN_Type__c = 'Last Payment 1st Part',ASI_CRM_CN_Region_Area_Channel__c='TEST',ASI_CRM_CN_Entry_Limit__c=0,
                                                       ASI_CRM_CN_Approver_1__c = user2.id,ASI_CRM_CN_Approval_Limit_1__c=0,
                                                       ASI_CRM_CN_Approver_2__c = user2.id,ASI_CRM_CN_Approval_Limit_2__c=0,
                                                       ASI_CRM_CN_Approver_3__c = user2.id,ASI_CRM_CN_Approval_Limit_3__c=0,
                                                       ASI_CRM_CN_Approver_4__c = user2.id,ASI_CRM_CN_Approval_Limit_4__c=0,
                                                       ASI_CRM_CN_Approver_5__c = user2.id,ASI_CRM_CN_Approval_Limit_5__c=0,
                                                       ASI_CRM_CN_Approver_6__c = user2.id, ASI_CRM_Sales_Team__c = 'a'));
            fars.add(new ASI_CRM_Fix_Approval_Route__c(ASI_CRM_CN_Type__c = 'Payment 2nd Part',ASI_CRM_CN_Region_Area_Channel__c='TEST',ASI_CRM_CN_Entry_Limit__c=0,
                                                       ASI_CRM_CN_Approver_1__c = user2.id,ASI_CRM_CN_Approval_Limit_1__c=0,
                                                       ASI_CRM_CN_Approver_2__c = user2.id,ASI_CRM_CN_Approval_Limit_2__c=0,
                                                       ASI_CRM_CN_Approver_3__c = user2.id,ASI_CRM_CN_Approval_Limit_3__c=0,
                                                       ASI_CRM_CN_Approver_4__c = user2.id,ASI_CRM_CN_Approval_Limit_4__c=0,
                                                       ASI_CRM_CN_Approver_5__c = user2.id,ASI_CRM_CN_Approval_Limit_5__c=0,
                                                       ASI_CRM_CN_Approver_6__c = user2.id, ASI_CRM_Sales_Team__c = 'a'));
            fars.add(new ASI_CRM_Fix_Approval_Route__c(ASI_CRM_CN_Type__c = 'Last Payment 2nd Part',ASI_CRM_CN_Region_Area_Channel__c='TEST',ASI_CRM_CN_Entry_Limit__c=0,
                                                       ASI_CRM_CN_Approver_1__c = user2.id,ASI_CRM_CN_Approval_Limit_1__c=0,
                                                       ASI_CRM_CN_Approver_2__c = user2.id,ASI_CRM_CN_Approval_Limit_2__c=0,
                                                       ASI_CRM_CN_Approver_3__c = user2.id,ASI_CRM_CN_Approval_Limit_3__c=0,
                                                       ASI_CRM_CN_Approver_4__c = user2.id,ASI_CRM_CN_Approval_Limit_4__c=0,
                                                       ASI_CRM_CN_Approver_5__c = user2.id,ASI_CRM_CN_Approval_Limit_5__c=0,
                                                       ASI_CRM_CN_Approver_6__c = user2.id, ASI_CRM_Sales_Team__c = 'a'));
            
            insert fars;
            
            
            rentalRequest = new List<ASI_MFM_Rental_Request__c>();
            rentalRequest.add(new ASI_MFM_Rental_Request__c(ASI_MFM_BU__c = bu.id
                                                        , ASI_MFM_Department__c = 'Admin'
                                                        //MT@Introv 20190605 new controls on these fields start
                                                        , ASI_MFM_Proposed_New_Space__c = 15
                                                        , ASI_MFM_Headcount_Forecast_in_3_years__c = 1
                                                        //, ASI_MFM_Comment__c = ''	//AM@Introv 20190620 leave empty=null and this CR is not deployed yet
                                                        , ASI_MFM_Renovation_New__c = 'No Renovation'
                                                        //MT@Introv 20190605 new controls on these fields end
                                                       ));
        
	        Insert rentalRequest;
            rentalDetail = new List<ASI_MFM_Rental_Request_Line__c>();
            rentalDetail.add(new ASI_MFM_Rental_Request_Line__c(ASI_MFM_Rental_Request__c = rentalRequest[0].id
                                                                , ASI_MFM_Total_Amount__c = 10000
                                                                , ASI_MFM_ExpenseType__c = expenseControlForm[0].id
                                                                , recordTypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Rental_Request_Line__cASI_MFM_CN_Rental_Contract_Line')
                                                               ));
            
            Insert rentalDetail;
            
            payment = new List<ASI_MFM_Payment__c>();
            payment.add(new ASI_MFM_Payment__c(ASI_MFM_Invoice_Amount__c = 1000
                                               , ASI_MFM_No_Invoice_Amount__c = 1000
                                               , ASI_MFM_Normal_Invoice_Amount__c = 1000
                                               , ASI_MFM_Tax_Code__c = taxcodeList[0].id
                                               , ASI_MFM_Supplier_Name__c = accs[1].id
                                               , ASI_MFM_BU__c = bu.id
                                               , ASI_MFM_Prefix__c = prefixs[2].id
                                               , ASI_MFM_Status__c = 'Final'
                                               , ASI_MFM_Pre_payment__c = True
                                               , ASI_MFM_Expense_Date_From__c = date.today()
                                               , ASI_MFM_G_L_Date__c = date.today()
                                               , ASI_MFM_Invoice_Number__c = '1111'
                                               , ASI_MFM_Expense_Date_To__c = date.today().addMonths(10)
                                               , recordTypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Payment__cASI_MFM_CN_Payment')
                                               , ASI_MFM_Currency__c = 'RMB'
                                               , ASI_MFM_Expense_Type__c = expenseControlForm[0].id
                                               , ASI_MFM_PO__c = po.id
                                               , ASI_MFM_Department_Text__c = 'Admin'
                                               , ASI_MFM_Contract__c = rentalDetail[0].id
                                              ));
            insert payment;
            
            paymentline = new List<ASI_MFM_Payment_Detail__c>();
             
            paymentline.add(new ASI_MFM_Payment_Detail__c(recordtypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Payment_Detail__cASI_MFM_CAP_CN_Payment_Allocation')
                                                      , ASI_MFM_Non_Sales_Allocated_Amount__c = 1500
                                                      , ASI_MFM_Sales_Allocated_Amount__c = 1500
                                                      , ASI_MFM_Payment__c = payment[0].id
                                                     ));
            paymentline.add(new ASI_MFM_Payment_Detail__c(recordtypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Payment_Detail__cASI_MFM_CN_Classification_Line')
                                                          , ASI_MFM_Reclassification__c = 'test'
                                                          , ASI_MFM_Headcount__c = 1
                                                          , ASI_MFM_Amount__c = 3000
                                                          , ASI_MFM_Payment__c = payment[0].id
                                                         ));
            paymentline.add(new ASI_MFM_Payment_Detail__c(recordtypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Payment_Detail__cASI_MFM_CAP_CN_Accrual_Detail')
                                                          , ASI_MFM_Accrual_Reverse_Amount__c = 1500
                                                          , ASI_MFM_GL_date__c = date.newInstance(2017, 03, 31)
                                                          , ASI_MFM_Payment__c = payment[0].id
                                                          , ASI_MFM_Reverse_ETL__c = True
                                                          , ASI_MFM_Accrual_Reverse_Budget__c = False
                                                         ));
            paymentline.add(new ASI_MFM_Payment_Detail__c(recordtypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Payment_Detail__cASI_MFM_CAP_CN_Accrual_Detail')
                                                          , ASI_MFM_Accrual_Reverse_Amount__c = 1500
                                                          , ASI_MFM_GL_date__c = date.today()
                                                          , ASI_MFM_Payment__c = payment[0].id
                                                          , ASI_MFM_Reverse_ETL__c = false
                                                          , ASI_MFM_Accrual_Reverse_Budget__c = False
                                                         ));

            insert paymentline;
            

        }
    }
}