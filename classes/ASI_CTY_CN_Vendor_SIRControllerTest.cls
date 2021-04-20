@isTest
private class ASI_CTY_CN_Vendor_SIRControllerTest {
    @testSetup
    static void testDataPre() {
        UserRole r = new UserRole(DeveloperName = 'MyCustomRole', Name = 'My Role');
        insert r;
        Profile admin_p = [SELECT Id FROM Profile WHERE Name='System Administrator'];//System Administrator
        User adminUser = new User(Alias = 'admin', Email='adminuser@testorg.com', UserRoleId= r.Id,
                            EmailEncodingKey='UTF-8', LastName='admin', LanguageLocaleKey='zh_CN', Autofollow__c = false,
                            LocaleSidKey='zh_CN', ProfileId = admin_p.Id,IsActive = true,
                            TimeZoneSidKey='Asia/Shanghai', UserName='test2@wholesaler.com',
                            CompanyName = 'Pernod Ricard China');
        insert adminUser;       
    }

    static testMethod void testSIRUpload() {
        User adminUser = [select Id from User where UserName='test2@wholesaler.com' limit 1];
        UserRole adminRole = [select Id, DeveloperName from UserRole where Name='My Role' limit 1];
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
            ASI_MFM_Stock_In_Request__c sir = new ASI_MFM_Stock_In_Request__c(ASI_MFM_PO_POSM_Line_Number__c = ppl.Id);
            String sirStr = JSON.serialize(sir);

            List<String> contentDocumentIds = new List<String>();
            contentDocumentIds.add(contentDocumentId);

            Test.startTest();
            ASI_CTY_CN_Vendor_SIRUploadController.insertSIR(sirStr, String.valueOf(pwp.Id), String.valueOf(ig.Id));
            Test.stopTest();
        }
    }

    static testMethod void testInsertSIR() {
        User adminUser = [select Id from User where UserName='test2@wholesaler.com' limit 1];
        UserRole adminRole = [select Id, DeveloperName from UserRole where Name='My Role' limit 1];
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
            ASI_MFM_Stock_In_Request__c sir = new ASI_MFM_Stock_In_Request__c(ASI_MFM_PO_POSM_Line_Number__c = ppl.Id);
            String sirStr = JSON.serialize(sir);

            List<String> contentDocumentIds = new List<String>();
            contentDocumentIds.add(contentDocumentId);

            Test.startTest();
            String resultStr = ASI_CTY_CN_Vendor_SIRUploadController.insertDocument(String.valueOf(adminUser.Id), String.valueOf(ig.Id), 'test', 'test.png', 20, 'png');
            ASI_CTY_CN_Vendor_SIRUploadController.CustomSIRInfo csInfo = ASI_CTY_CN_Vendor_SIRUploadController.getSIRImage(String.valueOf(ig.Id));
            String contentStr = ASI_CTY_CN_Vendor_SIRUploadController.getDocumentContent(String.valueOf(pwp.Id));
            ASI_CTY_CN_Vendor_SIRUploadController.ResultWrapper rw = ASI_CTY_CN_Vendor_SIRUploadController.deleteDocument(String.valueOf(pwp.Id));
            ASI_CTY_CN_Vendor_SIRUploadController.ResultWrapper rw1 = ASI_CTY_CN_Vendor_SIRUploadController.recallSIR(String.valueOf(sir.Id));
            ASI_CTY_CN_Vendor_SIRUploadController.CustomPO poResult = ASI_CTY_CN_Vendor_SIRUploadController.getPoInfo(po.Id);
            Test.stopTest();
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
}