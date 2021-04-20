@isTest
private class ASI_CTY_CN_Vendor_PR_PurchaseCtlTest {
    @testSetup
    static void testDataPre() {
        UserRole r = new UserRole(DeveloperName = 'MyCustomRole', Name = 'My Role');
        insert r;
        Profile admin_p = [SELECT Id FROM Profile WHERE Name='System Administrator'];//System Administrator
        User adminUser = new User(Alias = 'admin', Email='adminuser@testorg.com', UserRoleId= r.Id,
                            EmailEncodingKey='UTF-8', LastName='admin', LanguageLocaleKey='zh_CN', Autofollow__c = false,
                            LocaleSidKey='zh_CN', ProfileId = admin_p.Id,IsActive = true,
                            TimeZoneSidKey='Asia/Shanghai', UserName='test2@wholesaler.com',
                            CompanyName = 'Pernod Ricard China',ASI_MFM_Team__c = 'PR');
        insert adminUser;

        User adminUser1 = new User(Alias = 'admin', Email='adminuser@testorg.com', UserRoleId= r.Id,
                            EmailEncodingKey='UTF-8', LastName='admin', LanguageLocaleKey='zh_CN', Autofollow__c = false,
                            LocaleSidKey='zh_CN', ProfileId = admin_p.Id,IsActive = true,
                            TimeZoneSidKey='Asia/Shanghai', UserName='test3@wholesaler.com',
                            CompanyName = 'Pernod Ricard China');
        insert adminUser1;

    }

    static testMethod void testMethod1() {
        User user1 = [select Id from User where UserName='test2@wholesaler.com' limit 1];
        User adminUser1 = [select Id from User where UserName='test3@wholesaler.com' limit 1];
        UserRole Role_Test = [select Id, DeveloperName from UserRole where Name='My Role' limit 1];
         System.runAs(user1){ 
        	Map<string, id> planlineItem_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Plan_Line_Item__c');
            String strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_Prefix__c','ASI_MFM_CN_Prefix');
            List<ASI_MFM_Prefix__c> LPrefix = new list<ASI_MFM_Prefix__c>();
            ASI_MFM_Prefix__c prefix1 = new ASI_MFM_Prefix__c(Name='CNB20',ASI_MFM_Module__c='Plan',recordTypeId=strRTID,Plan_Type__c='Marketing A&P Plan',ASI_MFM_Fiscal_year__c='FY1314',ownerId = user1.id);
            LPrefix.add(prefix1);            
            ASI_MFM_Prefix__c prefix2 = new ASI_MFM_Prefix__c(Name='22YY', ASI_MFM_Module__c='PO', recordTypeId=strRTID,ASI_MFM_Fiscal_year__c='FY1314', ASI_MFM_Next_Number__c=86);
            LPrefix.add(prefix2);
            ASI_MFM_Prefix__c prefix3 = new ASI_MFM_Prefix__c(Name='22YY', ASI_MFM_Module__c='CN Vendor PR', recordTypeId=strRTID,ASI_MFM_Fiscal_year__c='FY1314', ASI_MFM_Next_Number__c=86);
            LPrefix.add(prefix3);
            insert LPrefix;
                                  
            List<ASI_MFM_Role_Prefix_Relationship__c> LPrefixRel = new List<ASI_MFM_Role_Prefix_Relationship__c>();
            ASI_MFM_Role_Prefix_Relationship__c prefixChild1 = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c = LPrefix[0].Id,ASI_MFM_Role_Name__c =Role_Test.DeveloperName);            
            LPrefixRel.add(prefixChild1);
            ASI_MFM_Role_Prefix_Relationship__c prefixChild2 = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c = LPrefix[1].Id,ASI_MFM_Role_Name__c =Role_Test.DeveloperName);            
            LPrefixRel.add(prefixChild2);
            
            //AM@Introv 20190620 - fix prefix issue
            List<ASI_MFM_Prefix__c> prefix = [SELECT Id FROM ASI_MFM_Prefix__c WHERE recordtype.developername = 'ASI_MFM_CN_Prefix' and ASI_MFM_Module__c = 'PO' and Name like '22%' and ASI_MFM_Fiscal_year__c = 'FY1314' limit 1];
            if(prefix.size() > 0){
                ASI_MFM_Role_Prefix_Relationship__c prefixChild3 = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c = prefix[0].Id,ASI_MFM_Role_Name__c =Role_Test.DeveloperName);            
                LPrefixRel.add(prefixChild3);
            }
            
            insert LPrefixRel;
                                      
            List<ASI_MFM_A_C_Code__c> LAC = new List<ASI_MFM_A_C_Code__c>();
            strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_A_C_Code__c','ASI_MFM_CN_A_C_Code');                       
            ASI_MFM_A_C_Code__c ac1 = new ASI_MFM_A_C_Code__c(recordtypeid=strRTId, name='testAC1', ASI_MFM_A_C_Code__c = '5600.000');
            LAC.add(ac1);
            insert LAC;
            
            strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_PP_Category__c','ASI_MFM_CN_PP_Category');   
            ASI_MFM_PP_Category__c ppc = new ASI_MFM_PP_Category__c(recordtypeid=strRTId , Name='NTMCD - KTV Promotion', ASI_MFM_External_ID__c='NTMCD - KTV Promotion (CN)1');
            insert ppc;
            
            strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_PP_Category_A_C__c','ASI_MFM_CN_PP_Category_A_C');
            List<ASI_MFM_PP_Category_A_C__c> LPPAC = new List<ASI_MFM_PP_Category_A_C__c>(); 
            ASI_MFM_PP_Category_A_C__c ppcac1 = new ASI_MFM_PP_Category_A_C__c(ASI_MFM_External_ID__c='test', recordtypeid=strRTId , ASI_MFM_A_C_Code__c=ac1.id, ASI_MFM_PP_Category__c=ppc.id);
            LPPAC.add(ppcac1); 
            ASI_MFM_PP_Category_A_C__c ppcac2 = new ASI_MFM_PP_Category_A_C__c(ASI_MFM_External_ID__c='test2', recordtypeid=strRTId , ASI_MFM_A_C_Code__c=ac1.id,ASI_MFM_PP_Category__c=ppc.id);
            LPPAC.add(ppcac2);
            insert LPPAC;
            
            ASI_MFM_Market_Strategy__c mms = new ASI_MFM_Market_Strategy__c(name='12004 Chivas', ASI_MFM_External_ID__c='120041',ASI_MFM_Fiscal_Year__c='FY1213', ASI_MFM_Sub_brand__c='CH2,CH3,CHF,CHU');
            insert mms;

            strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_Plan__c','ASI_MFM_CN_Plan'); 
            System.debug(LoggingLevel.INFO, '*** JSON.serialize(LPrefix): ' + JSON.serialize(LPrefix));
            System.debug(LoggingLevel.INFO, '*** JSON.serialize(LPrefixRel): ' + JSON.serialize(LPrefixRel));
            ASI_MFM_Plan__c Plan1 = new ASI_MFM_Plan__c(Name='CNB1332',ASI_MFM_Prefix__c=prefix1.Id,recordTypeId=strRTId ,
                                                        ASI_MFM_End_Date__c = date.valueof('2015-06-30'), ASI_MFM_Plan_Description__c='testDescription', 
                                                        ASI_MFM_Plan_Name__c='plannameTest', ASI_MFM_Start_Date__c=date.valueof('2014-07-01'), ASI_MFM_Budget_Owner__c=user1.id, 
                                                        ASI_MFM_PP_Category__c = ppc.id, ASI_MFM_Market_Strategy__c=mms.id, ASI_MFM_Status__c='Final', OwnerId =user1.id);
            insert Plan1;
            Plan1 = [SELECT Id,name, ASI_MFM_Fiscal_year__c FROM ASI_MFM_Plan__c WHERE id = :Plan1.id]; 
            system.debug('d001: ' + Plan1.name);
            strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_Sub_brand__c','ASI_MFM_CN_Sub_Brand');
            List<ASI_MFM_Sub_brand__c> LSB = new List<ASI_MFM_Sub_brand__c>(); 
            strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_Brand__c','ASI_MFM_CN_Brand');
            ASI_MFM_Brand__c brand = new ASI_MFM_Brand__c(name='brandname',Recordtypeid=strRTId);
            insert brand; 
            
            List<ASI_MFM_Sub_brand__c> subBrands = new List<ASI_MFM_Sub_brand__c>();
            //create sub brand
            strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_Sub_brand__c','ASI_FOC_CN_Sub_brand');
            subBrands.add(new ASI_MFM_Sub_brand__c(Name='subBrand1' ,recordTypeId=strRTId,ASI_MFM_Active_for_POSM__c=true));
            subBrands.add(new ASI_MFM_Sub_brand__c(Name='subBrand2' ,recordTypeId=strRTId,ASI_MFM_Active_for_POSM__c=true));
            subBrands.add(new ASI_MFM_Sub_brand__c(Name='testSb',recordtypeid=strRTId,ASI_MFM_Brand__c=brand.id,ASI_MFM_Active_for_POSM__c=true));
            insert subBrands;
            
            List<Account> LAcct = new List<Account>();
            strRTId = ASI_MFM_Function.checkRecordType('Account','ASI_MFM_CN_Supplier'); 
            Account supplier = new Account(Name='TestAcc', recordTypeId=strRTId , ASI_MFM_Customer_Supplier_Number__c='123',ASI_MFM_Customer_Supplier_Name__c='SupplierName');
            LAcct.add(supplier);
            insert LAcct;
            
            ASI_MFM_Plan_Line_Item__c planLineItem1 = new ASI_MFM_Plan_Line_Item__c(ASI_MFM_Plan__c = Plan1.id
            ,ASI_MFM_Sub_brand_Code__c = subBrands[0].id,ASI_MFM_List_Item_Description__c='hello1'
            ,recordTypeId=planLineItem_map.get('ASI_MFM_CN_Plan_Line_Item'),ASI_MFM_Month_1_Cost__c = 10000, ASI_MFM_Total_Cost__c =120000,ASI_MFM_Month_2_Cost__c = 10000,
            ASI_MFM_Month_3_Cost__c = 10000,ASI_MFM_Month_4_Cost__c = 10000,ASI_MFM_Month_5_Cost__c = 10000,ASI_MFM_Month_6_Cost__c = 10000,ASI_MFM_Month_7_Cost__c = 10000,
            ASI_MFM_Month_8_Cost__c = 10000,ASI_MFM_Month_9_Cost__c = 10000,ASI_MFM_Month_10_Cost__c = 10000,ASI_MFM_Month_11_Cost__c = 10000,ASI_MFM_Month_12_Cost__c = 10000,
            ASI_MFM_A_C_Code__c=LAC[0].id
            );
            insert planLineItem1;                   
            
           
            strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_BU__c','ASI_MFM_CN_BU');
            ASI_MFM_BU__c bu = new ASI_MFM_BU__c(Name='BUCode', ASI_MFM_BU_Code__c=strRTId , ASI_MFM_CN_Country__c='CN', ASI_MFM_Base_Currency__c='RMB');
            insert bu;

            strRTId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Product_Category__cASI_MFM_CN_Category_Master');
            List<ASI_HK_CRM_Product_Category__c> ProductCategoryList= new List<ASI_HK_CRM_Product_Category__c> ();                                                                                            
            ProductCategoryList.add(new ASI_HK_CRM_Product_Category__c(RecordTypeId=strRTId,ASI_MFM_Level__c='Level 1',Name='Display 陈列',ASI_MFM_Running_Number__c=1,ASI_HK_CRM_Category_Code__c='11',ASI_CRM_CN_Chinese_Name__c='Category',ASI_HK_CRM_English_Name__c='Category',ASI_HK_CRM_Sequence__c=1));
            ProductCategoryList.add(new ASI_HK_CRM_Product_Category__c(RecordTypeId=strRTId,ASI_MFM_Level__c='Level 2',Name='BAG 包',ASI_MFM_Running_Number__c=2,ASI_HK_CRM_Category_Code__c='22',ASI_CRM_CN_Chinese_Name__c='Category2',ASI_HK_CRM_English_Name__c='Category',ASI_HK_CRM_Sequence__c=2));
            ProductCategoryList.add(new ASI_HK_CRM_Product_Category__c(RecordTypeId=strRTId,ASI_MFM_Level__c='Level 3',Name='LEATHER 皮质',ASI_MFM_Running_Number__c=3,ASI_HK_CRM_Category_Code__c='33',ASI_CRM_CN_Chinese_Name__c='Category1',ASI_HK_CRM_English_Name__c='Category',ASI_HK_CRM_Sequence__c=3));
            insert ProductCategoryList;
            
            List<ASI_TH_CRM_Sub_category__c> SubCategoryList = new List<ASI_TH_CRM_Sub_category__c>(); 
            strRTId = Global_recordTypeCache.getRtId('ASI_TH_CRM_Sub_category__cASI_MFM_CN_POSM_Sub_Cetagory_Master');
            SubCategoryList.add(new ASI_TH_CRM_Sub_category__c(RecordTypeId=strRTId,ASI_MFM_Category_Level_2_3__c=ProductCategoryList[1].id,ASI_CRM_CN_Product_Category__c=ProductCategoryList[0].id));
            SubCategoryList.add(new ASI_TH_CRM_Sub_category__c(RecordTypeId=strRTId,ASI_MFM_Category_Level_2_3__c=ProductCategoryList[2].id,ASI_CRM_CN_Product_Category__c=ProductCategoryList[0].id));
            insert SubCategoryList;
            
            strRTId = Global_recordTypeCache.getRtId('ASI_MFM_Item_Group__cASI_MFM_CN_POSM_Item_Group');
            List<ASI_MFM_Item_Group__c> itemGroupList = new List<ASI_MFM_Item_Group__c>();
            itemGroupList.add(new ASI_MFM_Item_Group__c(name='System autoupdate, do not change.',ASI_MFM_Bundle_Item_Group__c=false,
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
                                                          ,RecordTypeId=strRTId));
            insert itemGroupList;
            
            ASI_MFM_Purchase_Request__c PR_Header = new ASI_MFM_Purchase_Request__c (ASI_MFM_Raised_Date__c = date.today(),
                                                                                     ASI_MFM_Comment__c = 'comment',
                                                                                     ASI_MFM_PR_Name__c='PR Name',
                                                                                     ASI_MFM_Company_Code__c = 'PRK',
                                                                                     ASI_MFM_PR_Date__c = date.today(),
                                                                                     ASI_CTY_CN_Vendor_Plan__c = Plan1.id,
                                                                                     ASI_MFM_Service_Item_POSM__c = 'POSM',
                                                                                     ASI_MFM_Status__c = 'Approved',
                                                                                     ASI_MFM_Prefix__c = prefix3.id,
                                                                                     ASI_CTY_CN_Vendor_AC_Code__c = ppcac1.ASI_MFM_A_C_Code__c,
                                                                                     ASI_CTY_CN_Vendor_PP_Category__c = ppcac1.ASI_MFM_PP_Category__c,
                                                                                     Recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Purchase_Request__cASI_CN_Vendor_Purchase_Request'));
            
            insert PR_Header;
            Test.startTest();
            PR_Header.ASI_MFM_Comment__c = '111';
            PR_Header.ASI_CTY_CN_Vendor_Responsible_by__c = adminUser1.id;
            update PR_Header;
            List<ASI_CRM_Quotation__c> mergeQuotations = new List<ASI_CRM_Quotation__c>();
            ASI_CRM_Quotation__c mergeQ1 = new ASI_CRM_Quotation__c();
            mergeQ1.ASI_CTY_CN_Vendor_Item_Group__c = itemGroupList[0].Id;
            mergeQ1.ASI_CTY_CN_Vendor_Supplier__c = supplier.Id;
            mergeQ1.ASI_CTY_CN_Vendor_Status__c = 'Completed';
            mergeQ1.ASI_CTY_CN_Vendor_Result_Status__c = 'Win-Bid';
            mergeQ1.RecordTypeId = Global_recordTypeCache.getRtId('ASI_CRM_Quotation__cASI_CTY_CN_Vendor_Merge_Quotation');
            mergeQuotations.add(mergeQ1);
            ASI_CRM_Quotation__c mergeQ2 = new ASI_CRM_Quotation__c();
            mergeQ2.ASI_CTY_CN_Vendor_Item_Group__c = itemGroupList[0].Id;
            mergeQ2.ASI_CTY_CN_Vendor_Supplier__c = supplier.Id;
            mergeQ2.ASI_CTY_CN_Vendor_Status__c = 'Completed';
            mergeQ2.ASI_CTY_CN_Vendor_Result_Status__c = 'Fail-Bid';
            mergeQ2.RecordTypeId = Global_recordTypeCache.getRtId('ASI_CRM_Quotation__cASI_CTY_CN_Vendor_Merge_Quotation');
            mergeQuotations.add(mergeQ2);
            insert mergeQuotations;

            ASI_MFM_Purchase_Request_Line__c PR_Line = new ASI_MFM_Purchase_Request_Line__c (recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Purchase_Request_Line__cASI_CN_Vendor_Purchase_Request_Line'),
                                                                                             ASI_MFM_Purchase_Request__c = PR_Header.id,
                                                                                             ASI_MFM_Quantity__c = 10,
                                                                                             ASI_CTY_CN_Vendor_Total_Quantity__c = 100,
                                                                                             ASI_MFM_UOM__c = 'EA',
                                                                                             ASI_CTY_CN_Vendor_Item_Group_Code__c = itemGroupList[0].Id,
                                                                                             ASI_MFM_Estimated_PR_budget__c = 100,
                                                                                             ASI_MFM_Delivery_Date__c= date.today(),
                                                                                             ASI_MFM_Description__c = 'Description',
                                                                                             ASI_MFM_Unit_Cost__c = 100,
                                                                                             ASI_CTY_CN_Vendor_All_Price__c = 10000,
                                                                                             ASI_CTY_CN_Vendor_IsBuyerApprove__c = false);
            insert PR_Line;
            ApexPages.currentPage().getParameters().put('id',PR_Header.Id);
	        ApexPages.StandardController con = new ApexPages.StandardController(PR_Header);
	        ASI_CTY_CN_Vendor_PR_PurchaseController accResLostApply = new ASI_CTY_CN_Vendor_PR_PurchaseController(con);

	        String purchaseHeadJson = PR_Header.Id;
	        String periodInfosJson = '[{"status":"In Distribution","totalQty":1,"sampleRequired":true,"itembuyName":"Yang Lara","itemProductName":"芝华士瓶身篮网队小衣服/CR NBA nets mini tshirt - XCRPBP19126ADN","isEdit":true,"deadlineTime":"2020-11-23","categoryName":"VAP 礼盒","isAllowEdit":false,"isMerged":false}]';
	        String proAddressMapJson = '[{"address":"新疆乌鲁木齐市中山路86号中泉雅苑2503室 邮编830002","quantity":1,"note":"","receiptOwner":"Bansal1 Nitin","receiptOwnerPhone":"Tel: (86-991) 233 9225","wareHouseName":"乌鲁木齐办公室 Wulumuqi Office","isEdit":true,"addressTampd":1606100017479,"contactName":"wzq"}]';
            String delProsJson = '[]';
            String delProAddressJson = '[]';
            ASI_CTY_CN_Vendor_PR_PurchaseController.savePurchase(purchaseHeadJson,periodInfosJson,proAddressMapJson,delProsJson,delProAddressJson);
            ASI_CTY_CN_Vendor_PR_PurchaseController.ajaxSearchProduct('chi/eng');
            ASI_CTY_CN_Vendor_PR_PurchaseController.ajaxSearchProduct('test');

            Id strRTId1 = Global_RecordTypeCache.getRtId('ASI_FOC_Warehouse__cASI_FOC_CN_Warehouse');
            ASI_FOC_Warehouse__c ware = new ASI_FOC_Warehouse__c(Name ='test',ASI_FOC_Warehouse_Code__c='XXX999SH', ASI_MFM_Is_Active__c= true,ASI_MFM_Location_Code__c='SH', Recordtypeid=strRTId1);
            insert ware;

            ASI_CRM_Region__c region = new ASI_CRM_Region__c (Name='TEST');
	        insert region;
	        
	        ASI_CRM_Division__c division = new ASI_CRM_Division__c(Name='TEST', ASI_CRM_Region__c=region.Id);
	        insert division;
	        
	        ASI_CRM_CN_Area__c area = new ASI_CRM_CN_Area__c(Name='TEST', ASI_CRM_English_Name__c='TEST', ASI_CRM_Division__c=division.Id);
	        insert area;
	        
	        ASI_CRM_City__c city = new ASI_CRM_City__c(ASI_CRM_CN_City_Code__c='TEST', ASI_CRM_CN_Area__c=area.Id);
	        insert city;

	        ASI_CRM_CN_Channel__c channel = new ASI_CRM_CN_Channel__c(ASI_CRM_CN_On_Off__c='ON');
	        insert channel;
	        
	        ASI_MFM_Sub_Channel__c subChannel = new ASI_MFM_Sub_Channel__c(ASI_CRM_CN_Channel__c=channel.Id);
	        insert subChannel;
	        
	        ASI_CRM_CN_Channel__c newChannel = new ASI_CRM_CN_Channel__c(ASI_CRM_For_Outlet__c = true, Name='Restaurant',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CN_Channel__cASI_CRM_CN_New_Channel'),ASI_CRM_CN_On_Off__c='OFF');
	        insert newChannel;
           
            Id customerRecTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN');
            ASI_CRM_AccountsAdditionalField__c testCustomer1 = new ASI_CRM_AccountsAdditionalField__c(
            	ASI_CRM_CN_Eng_Name__c = 'c', ASI_CRM_CN_Chi_Name__c = 'c', ASI_CRM_CN_Commercial_Team__c = 'Premium', 
            	ASI_CRM_CN_Sub_Channel__c=subChannel.Id, ASI_CRM_CN_CCity__c=city.Id, 
            	ASI_CRM_Latest_Call_Plan_Date__c=system.today(), 
            	RecordTypeId=customerRecTypeId, 
                ASI_CRM_Active__c = true,
            	ASI_CRM_CN_NewChannel__c = newChannel.Id, ASI_CRM_CN_Type_of_Restaurant__c = 'International',
            	ASI_CRM_CN_Spending_per_head__c=1,ASI_CRM_CN_CRM_Code__c = 'c(OFTEST0001)');

            insert testCustomer1;
            
            ASI_CRM_AccountsAdditionalField__c cc = [SELECT Id,Name,ASI_CRM_CN_CRM_Code__c from ASI_CRM_AccountsAdditionalField__c WHERE Id =:testCustomer1.Id];
            System.debug(LoggingLevel.INFO, '*** cc: ' + cc);
            ASI_CTY_CN_Vendor_PR_PurchaseController.ajaxSearchWarehouse('test','WareHouse');
            ASI_CTY_CN_Vendor_PR_PurchaseController.ajaxSearchWarehouse('','WareHouse1');
            ASI_CTY_CN_Vendor_PR_PurchaseController.ajaxSearchUser('test');
            ASI_CTY_CN_Vendor_PR_PurchaseController.ajaxSearchUser('11111');
            String addressJson ='[{"lineNo":"1","warehousecode":"XXX999SH","qutlet":"","quantity":"1","receiptOwner":"","contactName":"1","receiptOwnerPhone":""}]';
            ASI_CTY_CN_Vendor_PR_PurchaseController.getAddressInfos(addressJson);
            String addressJson1 ='[{"lineNo":"1","warehousecode":"","qutlet":"c(OFTEST0001)","quantity":"1","receiptOwner":"","contactName":"1","receiptOwnerPhone":""}]';
            ASI_CTY_CN_Vendor_PR_PurchaseController.getAddressInfos(addressJson1);
            Test.stopTest();
        }
    }
}