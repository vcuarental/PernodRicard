@isTest
private class ASI_CTY_CN_Vendor_PR_AssignSpCtrTest {
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
        System.debug(LoggingLevel.INFO, '*** user1: ' + user1);
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
            ASI_MFM_Prefix__c prefix3 = new ASI_MFM_Prefix__c(Name='22YY', ASI_MFM_Module__c='CN Vendor Pr', recordTypeId=strRTID,ASI_MFM_Fiscal_year__c='FY1314', ASI_MFM_Next_Number__c=86);
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
            Account supplier1 = new Account(Name='TestAcc1', recordTypeId=strRTId , ASI_MFM_Customer_Supplier_Number__c='123',ASI_MFM_Customer_Supplier_Name__c='SupplierName1');
            LAcct.add(supplier);
            LAcct.add(supplier1);
            insert LAcct;

            strRTId = ASI_MFM_Function.checkRecordType('Contact','ASI_CRM_CN_Wholesaler_Contact'); 
            Contact con = new Contact(LastName = 'TestContact', 
                                    RecordtypeId = strRTId,
                                    AccountId = LAcct[0].Id);
            insert con;

            Profile p2 = [SELECT Id FROM Profile WHERE Name='ASI_CTY_PRCVendor_CN_User'];//ASI_CTY_Wholesaler_CN_User
            User usr2 = new User(Alias = '经销商', Email='standarduser@testorg.com', 
                                EmailEncodingKey='UTF-8', LastName='经销商', LanguageLocaleKey='zh_CN', Autofollow__c = false,
                                LocaleSidKey='zh_CN', ProfileId = p2.Id, ContactId = con.Id,IsActive = true,
                                TimeZoneSidKey='Asia/Shanghai', UserName='test1@wholesaler.com',
                                CompanyName = 'Pernod Ricard China');
            insert usr2;
            
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

            ASI_MFM_Buyer_Master__c buyer = new ASI_MFM_Buyer_Master__c(Name ='test', ASI_MFM_Buyer__c = user1.Id);
            insert buyer;
            
            ASI_MFM_Purchase_Request__c PR_Header = new ASI_MFM_Purchase_Request__c (ASI_MFM_Raised_Date__c = date.today(),
                                                                                     ASI_MFM_Comment__c = 'comment',
                                                                                     ASI_MFM_PR_Name__c='PR Name',
                                                                                     ASI_MFM_Company_Code__c = 'PRK',
                                                                                     ASI_MFM_PR_Date__c = date.today(),
                                                                                     ASI_CTY_CN_Vendor_Plan__c = Plan1.id,
                                                                                     ASI_MFM_Service_Item_POSM__c = 'POSM',
                                                                                     ASI_MFM_Status__c = 'Approved',
                                                                                     ASI_MFM_Prefix__c = prefix1.id,
                                                                                     ASI_CTY_CN_Vendor_AC_Code__c = ppcac1.ASI_MFM_A_C_Code__c,
                                                                                     ASI_CTY_CN_Vendor_PP_Category__c = ppcac1.ASI_MFM_PP_Category__c,
                                                                                     Recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Purchase_Request__cASI_CN_Vendor_Purchase_Request'));
            
            insert PR_Header;

            ASI_MFM_Purchase_Request_Line__c PR_Line = new ASI_MFM_Purchase_Request_Line__c (recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Purchase_Request_Line__cASI_CN_Vendor_Purchase_Request_Line'),
                                                                                             ASI_MFM_Purchase_Request__c = PR_Header.Id,
                                                                                             ASI_MFM_Quantity__c = 10,
                                                                                             ASI_CTY_CN_Vendor_Total_Quantity__c = 100,
                                                                                             ASI_MFM_UOM__c = 'EA',
                                                                                             ASI_CTY_CN_Vendor_Item_Group_Code__c = itemGroupList[0].Id,
                                                                                             ASI_MFM_Estimated_PR_budget__c = 100,
                                                                                             ASI_MFM_Delivery_Date__c= date.today(),
                                                                                             ASI_MFM_Description__c = 'Description',
                                                                                             ASI_MFM_Unit_Cost__c = 100,
                                                                                             ASI_CTY_CN_Vendor_All_Price__c = 10000,
                                                                                             ASI_CTY_CN_Vendor_IsBuyerApprove__c = false, 
                                                                                             ASI_CTY_CN_Vendor_Approval_Buyer__c = adminUser1.Id,
                                                                                             ASI_CTY_CN_Vendor_Buyer__c = buyer.Id);
            insert PR_Line;

            ASI_MFM_Purchase_Request_Line__c PR_Line1 = new ASI_MFM_Purchase_Request_Line__c (recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Purchase_Request_Line__cASI_CN_Vendor_Purchase_Request_Line'),
                                                                                             ASI_MFM_Purchase_Request__c = PR_Header.Id,
                                                                                             ASI_MFM_Quantity__c = 10,
                                                                                             ASI_CTY_CN_Vendor_Total_Quantity__c = 100,
                                                                                             ASI_MFM_UOM__c = 'EA',
                                                                                             ASI_CTY_CN_Vendor_Item_Group_Code__c = itemGroupList[0].Id,
                                                                                             ASI_MFM_Estimated_PR_budget__c = 100,
                                                                                             ASI_MFM_Delivery_Date__c= date.today(),
                                                                                             ASI_MFM_Description__c = 'Description',
                                                                                             ASI_MFM_Unit_Cost__c = 100,
                                                                                             ASI_CTY_CN_Vendor_All_Price__c = 10000,
                                                                                             ASI_CTY_CN_Vendor_IsBuyerApprove__c = false, 
                                                                                             ASI_CTY_CN_Vendor_Approval_Buyer__c = adminUser1.Id,
                                                                                             ASI_CTY_CN_Vendor_Buyer__c = buyer.Id);
            insert PR_Line1;

            Id strRTId1 = Global_RecordTypeCache.getRtId('ASI_FOC_Warehouse__cASI_FOC_CN_Warehouse');
            ASI_FOC_Warehouse__c ware = new ASI_FOC_Warehouse__c(Name ='test',ASI_FOC_Warehouse_Code__c='XXX999SH', ASI_MFM_Location_Code__c='SH', Recordtypeid=strRTId1);
            insert ware;

            strRTId1 = Global_RecordTypeCache.getRtId('ASI_CRM_Address__cASI_CTY_CN_Purchase_Request_Delivery_Address');
            List<ASI_CRM_Address__c> addressList = new List<ASI_CRM_Address__c>();
            ASI_CRM_Address__c address = new ASI_CRM_Address__c();
            address.RecordTypeId = strRTId1;
            address.ASI_CTY_CN_Vendor_PurLine__c = PR_Line.Id;
            address.ASI_CTY_CN_Vendor_Quantity_Required__c = PR_Line.ASI_MFM_Quantity__c;
            address.ASI_CTY_CN_Vendor_ReceiptOwner__c = usr2.Id;
            address.ASI_CTY_CN_Vendor_Warehouse__c = ware.Id;
            address.ASI_CTY_CN_Vendor_Receipt_Phone__c = '123456';
            address.ASI_CTY_CN_Vendor_ContactName__c = 'test';
            address.ASI_CTY_CN_Vendor_Delivery_Address__c = '南京市江宁区谷里工业园兴谷路2号九州焊接门面房';
            addressList.add(address);
            insert addressList;

            List<ASI_CRM_Quotation__c> mergeQuotations = new List<ASI_CRM_Quotation__c>();
            ASI_CRM_Quotation__c mergeQ1 = new ASI_CRM_Quotation__c();
            mergeQ1.ASI_CTY_CN_Vendor_Item_Group__c = itemGroupList[0].Id;
            mergeQ1.ASI_CTY_CN_Vendor_Sample__c = 200;
            mergeQ1.ASI_CTY_CN_Vendor_Model__c = 100;
            mergeQ1.ASI_CTY_CN_Vendor_Unitl_Price__c = 10;
            mergeQ1.ASI_CTY_CN_Vendor_Supplier__c = supplier.Id;
            mergeQ1.RecordTypeId = Global_recordTypeCache.getRtId('ASI_CRM_Quotation__cASI_CTY_CN_Vendor_Merge_Quotation');
            mergeQ1.ASI_CTY_CN_Vendor_Old_Unitl_Price__c = 0;
            mergeQ1.ASI_CTY_CN_Vendor_Deadline_Date__c = date.today();
            mergeQ1.ASI_CTY_CN_Vendor_Status__c = 'Pending';
            mergeQ1.ASI_CTY_CN_Vendor_Result_Status__c = 'Pending Confirm';
            mergeQ1.ASI_CTY_CN_Vendor_Notification_User__c = usr2.Id;
            mergeQ1.ASI_CTY_CN_Vendor_Is_Need_Sample__c = true;
            mergeQ1.ASI_CTY_CN_Vendor_Is_Need_Model__c = true;
            mergeQ1.ASI_CTY_CN_Vendor_Total_Quantity__c = PR_Line.ASI_MFM_Quantity__c;
            mergeQ1.ASI_CTY_CN_Vendor_Merge_Total_Freight__c = 0;
            mergeQ1.ASI_CTY_CN_Vendor_IsVisible__c = true;
            mergeQuotations.add(mergeQ1);
            insert mergeQuotations;

            List<ASI_CRM_Quotation__c> quotations = new List<ASI_CRM_Quotation__c>();
            ASI_CRM_Quotation__c q1 = new ASI_CRM_Quotation__c();
            q1.ASI_CTY_CN_Vendor_Item_Group__c = itemGroupList[0].Id;
            q1.ASI_CTY_CN_Vendor_Old_Unitl_Price__c = 0;
            q1.ASI_CTY_CN_Vendor_Deadline_Date__c = date.today();
            q1.ASI_CTY_CN_Vendor_Status__c = 'Pending';
            q1.ASI_CTY_CN_Vendor_Result_Status__c = 'Pending Confirm';
            q1.ASI_CTY_CN_Vendor_Supplier__c = supplier.Id;
            q1.ASI_CTY_CN_Vendor_Notification_User__c = usr2.Id;
            q1.ASI_CTY_CN_Vendor_Is_Need_Sample__c = true;
            q1.ASI_CTY_CN_Vendor_Is_Need_Model__c = true;
            q1.ASI_CTY_CN_Purchase_Request_Line__c = PR_Line.Id;
            q1.RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Quotation__cASI_CTY_CN_Vendor_Quotation');
            q1.ASI_CTY_CN_Vendor_Quotation__c = mergeQuotations[0].Id;
            quotations.add(q1);
            insert quotations;

            List<ASI_CRM_Quotation_Line_Item__c> quoteLineItemList = new List<ASI_CRM_Quotation_Line_Item__c>();
            ASI_CRM_Quotation_Line_Item__c quoteLineItem = new ASI_CRM_Quotation_Line_Item__c();
            quoteLineItem = new ASI_CRM_Quotation_Line_Item__c();
            quoteLineItem.ASI_CTY_CN_Vendor_Quotation__c = quotations[0].Id;
            quoteLineItem.ASI_CTY_CN_Vendor_Address__c = addressList[0].Id;
            quoteLineItem.ASI_CTY_CN_Vendor_Freight__c = 200;
            quoteLineItem.RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Quotation_Line_Item__cASI_CTY_CN_Vendor_Quotation_Line_Item');
            quoteLineItemList.add(quoteLineItem);
            insert quoteLineItemList;

            //create Warehouse Photo
            String reocrdTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Product_Warehouse_Photo__cASI_MFM_CN_POSM_Final_Artwork_Photo');
            ASI_CRM_Product_Warehouse_Photo__c pwp = new ASI_CRM_Product_Warehouse_Photo__c(ASI_CRM_Item_Group__c = itemGroupList[0].Id, ASI_File_Name__c = 'test.png',
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

            Set<String> quotaIds = new Set<String>();
            quotaIds.add(String.valueOf(quotations[0].Id));
            List<ASI_CRM_Quotation_Line_Item__c> newQuoteLineItemList = [SELECT Id, Name, ASI_CTY_CN_Vendor_Freight__c, ASI_CTY_CN_Vendor_Quotation__r.Id, ASI_CTY_CN_Vendor_Quotation__r.ASI_CTY_CN_Purchase_Request_Line__c, 
            ASI_CTY_CN_Vendor_Quotation__r.ASI_CTY_CN_Purchase_Request_Line__r.ASI_CTY_CN_Vendor_Total_Quantity__c,
            ASI_CTY_CN_Vendor_Address__r.ASI_CTY_CN_Vendor_Receipt_Owner__c, ASI_CTY_CN_Vendor_Address__r.ASI_CTY_CN_Vendor_Receipt_Phone__c,
            ASI_CTY_CN_Vendor_Address__r.ASI_CTY_CN_Vendor_Note__c, ASI_CTY_CN_Vendor_Address__r.ASI_CTY_CN_Vendor_Quantity_Required__c,
            ASI_CTY_CN_Vendor_Address__r.ASI_CTY_CN_Vendor_Actual_Quantity__c, ASI_CTY_CN_Vendor_Address__r.ASI_CTY_CN_Vendor_Delivery_Address__c,
            ASI_CTY_CN_Vendor_Address__r.ASI_CTY_CN_Vendor_ContactName__c
            FROM ASI_CRM_Quotation_Line_Item__c WHERE ASI_CTY_CN_Vendor_Quotation__r.Id IN :quotaIds AND RecordTypeId =: ASI_CTY_CN_Vendor_Util.quotationLineItemRecordId ORDER BY ASI_CTY_CN_Vendor_Quotation__c DESC];
            String addressJson = JSON.serialize(newQuoteLineItemList);

            Test.startTest();
            ApexPages.currentPage().getParameters().put('id',PR_Line.Id);
            ApexPages.StandardController con0 = new ApexPages.StandardController(PR_Line);
            ASI_CTY_CN_Vendor_PR_AssignSpController prLineCtl = new ASI_CTY_CN_Vendor_PR_AssignSpController(con0);
            ASI_CTY_CN_Vendor_PR_MerPRLineController prLineCtl1 = new ASI_CTY_CN_Vendor_PR_MerPRLineController(con0);
            Set<String> selectSupplierIds = new Set<String>();
            selectSupplierIds.add(String.valueOf(LAcct[0].Id));
            ASI_CTY_CN_Vendor_PR_AssignSpController.initSupplierList(String.valueOf(itemGroupList[0].Id), JSON.serialize(selectSupplierIds));
            Set<String> prlList = new Set<String>();
            prlList.add(String.valueOf(PR_Line.Id));

            Set<String> supplierIds = new Set<String>();
            supplierIds.add(String.valueOf(LAcct[0].Id));
            Map<String, String> supplierDeadLineDateMap = new Map<String, String>();
            supplierDeadLineDateMap.put(String.valueOf(LAcct[0].Id), String.valueOf(date.valueof('2020-11-30')));
            Map<String, Boolean> sampleRequiredMap = new Map<String, Boolean>();
            sampleRequiredMap.put(String.valueOf(LAcct[0].Id), true);
            Map<String, Boolean> modelRequiredMap = new Map<String, Boolean>();
            modelRequiredMap.put(String.valueOf(LAcct[0].Id), true);

            
            ASI_CTY_CN_Vendor_PR_AssignSpController.assignSupplier(JSON.serialize(prlList), JSON.serialize(supplierIds), JSON.serialize(supplierDeadLineDateMap), JSON.serialize(sampleRequiredMap), JSON.serialize(modelRequiredMap));
        	
            String quotationJson = JSON.serialize(mergeQuotations[0]);
        	ASI_CTY_CN_Vendor_PR_AssignSpController.updateQuotation(quotationJson, String.valueOf(PR_Line.Id), '2020-11-24', 'UpdateDeadLineDate');
        	ASI_CTY_CN_Vendor_PR_AssignSpController.updateQuotation(quotationJson, String.valueOf(PR_Line.Id), '2020-11-24', 'Confirm');
        	ASI_CTY_CN_Vendor_PR_AssignSpController.updateQuotation(quotationJson, String.valueOf(PR_Line.Id), '2020-11-24', 'NoConfirm');
        	ASI_CTY_CN_Vendor_PR_AssignSpController.winOrNotWinQuotation(quotationJson, String.valueOf(PR_Line.Id), 'Win');
        	ASI_CTY_CN_Vendor_PR_AssignSpController.winOrNotWinQuotation(quotationJson, String.valueOf(PR_Line.Id), 'NoWin');

        	List<ASI_CRM_quotation__c> quoteList = new List<ASI_CRM_quotation__c>();
        	quoteList.add(mergeQuotations[0]);
        	ASI_CTY_CN_Vendor_PR_AssignSpController.deleteSupplier(String.valueOf(PR_Line.Id), JSON.serialize(quoteList));
        	Test.stopTest();
        }
    }
}