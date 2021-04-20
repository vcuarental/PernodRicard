/*Created by Twinkle Li @introv 04/21/2015
*
* Testclass for Promotion related Controller:
* ASI_CRM_TW_PromotionCalendarCommonClass
* ASI_CRM_TW_PromotionCalendarMonthCON, ASI_CRM_TW_PromotionCalendarYearCON
* ASI_CRM_TW_PromotionSetup_Ctrl, ASI_CRM_TW_PromotionStatus_Ctrl 
* ASI_CRM_TW_PromotionPOSM_Query_Ctrl, ASI_CRM_TW_PromoStatus_TriggerCls
* ASI_CRM_PromoStatus_BeforeInsert, ASI_CRM_PromoStatus_BeforeUpdate
*
*/

@isTest
public class ASI_CRM_TW_Promotion_Test {
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
    
    /*For ASI_CRM_TW_PromotionCalendarMonthCON & ASI_CRM_TW_PromotionCalendarCommonClass*/
    public static testMethod void PromotionCalendarMonthTest() {
        ASI_HK_CRM_PromotionGenerator pmtGen = new ASI_HK_CRM_PromotionGenerator();
        Date todayDate = System.today();
        final Integer numOfPmt = 4;
        final List<Date> startAndEndDateList = new List<Date>{
            todayDate.addDays(3), todayDate.addDays(4)
            , todayDate.addDays(14), todayDate.addDays(20)
            , todayDate.addDays(13), todayDate.addDays(18)
            , todayDate.addDays(35), todayDate.addDays(41)
        };
        List<ASI_HK_CRM_Promotion__c> pmtList = new List<ASI_HK_CRM_Promotion__c>();
        for (Integer i = 0; i < startAndEndDateList.size(); i += 2) {
          ASI_HK_CRM_Promotion__c pmt = pmtGen.generateGlobalPromotion(startAndEndDateList.get(i), startAndEndDateList.get(i + 1));
          pmt.recordtypeid = checkRecordType('ASI_HK_CRM_Promotion__c','ASI_CRM_TW_ChannelPromotion');
          pmtList.add(pmt);
        }
        insert pmtList;
        
        Test.startTest();
        
        // Initialize page and controller
        PageReference testPage = Page.ASI_CRM_TW_PromotionCalendarMonthPage;
        Map<String, String> pageParams = testPage.getParameters();
        pageParams.put(ASI_CRM_TW_PromotionCalendarMonthCON.URL_PARAM_YEAR, String.valueOf(todayDate.year()));
        pageParams.put(ASI_CRM_TW_PromotionCalendarMonthCON.URL_PARAM_MONTH, String.valueOf(todayDate.month()));
        Test.setCurrentPageReference(testPage);
        ASI_CRM_TW_PromotionCalendarMonthCON testController = new ASI_CRM_TW_PromotionCalendarMonthCON();
        PageReference initRedirectPage = testController.initPage();
        System.assertEquals(null, initRedirectPage);

        testController.selectclick();
        testController.unselectclick();
        testController.selectclick2();
        testController.unselectclick2();
        testController.getunSelectedValues();
        testController.getSelectedValues();
        testController.getunSelectedValues2();
        testController.getSelectedValues2();

        List<ASI_CRM_TW_PromotionCalendarMonthCON.ASI_HK_CRM_PromotionMonthEvent> monthEventList2 = 
        ASI_CRM_TW_PromotionCalendarMonthCON.retrievefilterPromotionsByTimeRange(
            ASI_CRM_TW_PromotionCalendarMonthCON.convertToRetrivalDateFormat(todayDate)
            , ASI_CRM_TW_PromotionCalendarMonthCON.convertToRetrivalDateFormat(todayDate.addDays(42))
            , 'Channel'
            , 'subBrand'
            , 'ItemGroup'
            , 'BgColor');
        
        List<ASI_CRM_TW_PromotionCalendarMonthCON.ASI_HK_CRM_PromotionMonthEvent> monthEventList = 
          ASI_CRM_TW_PromotionCalendarMonthCON.retrievePromotionsByTimeRange(
            ASI_CRM_TW_PromotionCalendarMonthCON.convertToRetrivalDateFormat(todayDate)
            , ASI_CRM_TW_PromotionCalendarMonthCON.convertToRetrivalDateFormat(todayDate.addDays(42))
        );

        set<string> itemgroupvalue = 
        ASI_CRM_TW_PromotionCalendarMonthCON.getitemgrouplvalue(
            ASI_CRM_TW_PromotionCalendarMonthCON.convertToRetrivalDateFormat(todayDate)
            , ASI_CRM_TW_PromotionCalendarMonthCON.convertToRetrivalDateFormat(todayDate.addDays(42))
        );
        System.assertEquals(numOfPmt, monthEventList.size());
          
        // Redirect to promotion detail page
        testPage.getParameters().put('pmtId', pmtList.get(0).Id);
        testPage.getParameters().put('retURL', Page.ASI_CRM_TW_PromotionCalendarMonthPage.getUrl());
        PageReference pmtViewPage = testController.redirectToViewPage();
        System.assert(pmtViewPage != null);
          
        // Redirect to year view calendar
        testController.selectedCalendarType = ASI_CRM_TW_PromotionCalendarCommonClass.CALENDAR_TYPE_YEAR;
        PageReference anotherCalendarPage = testController.redirectToAnotherCalendarType();
        System.assertEquals(Page.ASI_CRM_TW_PromotionCalendarYearPage.getUrl(), anotherCalendarPage.getUrl());
        
        Test.stopTest();
    }
    
    /*For ASI_CRM_TW_PromotionCalendarYearCON & ASI_CRM_TW_PromotionCalendarCommonClass*/
    public static testMethod void PromotionCalendarYearTest() {
        ASI_HK_CRM_PromotionGenerator pmtGen = new ASI_HK_CRM_PromotionGenerator();
        ASI_HK_CRM_BrandGenerator brandGen = new ASI_HK_CRM_BrandGenerator();
        ASI_HK_CRM_SubBrandGenerator sbGen = new ASI_HK_CRM_SubBrandGenerator();
        ASI_HK_CRM_AccountGenerator acctGen = new ASI_HK_CRM_AccountGenerator();
        Date todayDate = System.today();
        final Integer numOfPmt = 4;
        final List<Date> startAndEndDateList = new List<Date>{
             todayDate.addDays(3), todayDate.addDays(4)
             , todayDate.addDays(14), todayDate.addDays(20)
             , todayDate.addDays(13), todayDate.addDays(18)
             , todayDate.addDays(35), todayDate.addDays(41)
        };
        List<ASI_HK_CRM_Promotion__c> pmtList = new List<ASI_HK_CRM_Promotion__c>();
        for (Integer i = 0; i < startAndEndDateList.size(); i += 2) {
            //pmtList.add(pmtGen.generateTeamPromotion(startAndEndDateList.get(i), startAndEndDateList.get(i + 1)));
            ASI_HK_CRM_Promotion__c pmt = pmtGen.generateTeamPromotion(startAndEndDateList.get(i), startAndEndDateList.get(i + 1));
            pmt.recordtypeid = checkRecordType('ASI_HK_CRM_Promotion__c','ASI_CRM_TW_ChannelPromotion');
            pmtList.add(pmt);
        }
        insert pmtList;
        
        ASI_MFM_Brand__c brand = brandGen.generateBrand();
        insert brand;
        List<ASI_MFM_Sub_brand__c> sbList = new List<ASI_MFM_Sub_brand__c>();
        for (Integer i = 0; i < 2; i++) {
            sbList.add(sbGen.generateSubBrand(brand));
        }
        insert sbList;
        Account ws = acctGen.generateAccount(ASI_HK_CRM_AccountGenerator.RT_JDE_CREDIT);
        insert ws;
        List<ASI_HK_CRM_Promotion_Detail__c> pmtDetailList = pmtGen.generatePromotionDetails(pmtList.get(0), sbList, new List<Account>{ws});
        insert pmtDetailList;
        
        Test.startTest();
        
        // Initialize page and controller
        PageReference testPage = Page.ASI_CRM_TW_PromotionCalendarYearPage;
        Map<String, String> pageParams = testPage.getParameters();
        pageParams.put(ASI_CRM_TW_PromotionCalendarYearCON.URL_PARAM_YEAR, String.valueOf(todayDate.year()));
        pageParams.put(ASI_CRM_TW_PromotionCalendarYearCON.URL_PARAM_MONTH, String.valueOf(todayDate.month() - 1));
        Test.setCurrentPageReference(testPage);
        ASI_CRM_TW_PromotionCalendarYearCON testController = new ASI_CRM_TW_PromotionCalendarYearCON();
        PageReference initRedirectPage = testController.initPage();
        System.assertEquals(null, initRedirectPage);

        testController.selectclick();
        testController.unselectclick();
        testController.selectclick2();
        testController.unselectclick2();
        testController.getunSelectedValues();
        testController.getSelectedValues();
        testController.getunSelectedValues2();
        testController.FilterData();
        
        // Validate display promotions
        System.assertEquals(sbList.size() + (pmtList.size() > 1 ? 1 : 0), testController.eventGroups.size());
        System.assertEquals(pmtList.size() + sbList.size() - 1, testController.eventList.size());
      
        // Redirect to month view calendar
        testController.selectedCalendarType = ASI_CRM_TW_PromotionCalendarCommonClass.CALENDAR_TYPE_MONTH;
        PageReference anotherCalendarPage = testController.redirectToAnotherCalendarType();
        System.assertEquals(Page.ASI_CRM_TW_PromotionCalendarMonthPage.getUrl(), anotherCalendarPage.getUrl());
        
        Test.stopTest();
    }
    
    /* For ASI_CRM_TW_PromotionSetup_Ctrl*/
    public static testMethod void ASI_CRM_TW_PromotionSetup_Ctrl_Test() {
            user u = [select userRole.developerName from user where id = :userInfo.getUserId()];
            PermissionSet ps = [SELECT Id, Name FROM PermissionSet WHERE Name='ASI_CRM_TW_System_Admin'];
            
            //Assign permission set 'ASI_CRM_TW_System_Admin' to user u 
            PermissionSetAssignment psa = new PermissionSetAssignment(PermissionSetId = ps.id, AssigneeId = u.id);
            
            ASI_CRM_TW_Settings__c customSetting = new ASI_CRM_TW_Settings__c(ASI_CRM_TW_POSM_Image_Account_Id__c = '-2');
            insert customSetting;
            
            //Insert promotion
            String recordTypeid = Global_RecordTypeCache.getRTId('ASI_HK_CRM_Promotion__cASI_CRM_TW_ChannelPromotion');
            ASI_HK_CRM_Promotion__c promotion = new ASI_HK_CRM_Promotion__c(Name = 'Promotion', RecordTypeid = recordTypeid, ASI_CRM_PurchaseDueDate__c = date.today(), ASI_HK_CRM_Promotion_Start_Date__c = date.today()-1, ASI_HK_CRM_Promotion_End_Date__c = date.today()+1,ASI_CRM_Region__c='North');
            insert promotion;
            
            //Insert Sub-brand
            recordTypeid = Global_RecordTypeCache.getRTId('ASI_MFM_Sub_brand__cASI_MFM_TW_Sub_brand');
            ASI_MFM_Sub_brand__c subBrand = new ASI_MFM_Sub_brand__c(Name = 'Chivas18y', RecordTypeid = recordTypeid, ASI_CRM_TW_Company__c = 'PRT');
            insert subBrand;
            
            //Insert SKU
            recordTypeid = Global_RecordTypeCache.getRTId('ASI_MFM_SKU_Code__cASI_MFM_TW_SKU_Code');
            List<ASI_MFM_SKU_Code__c> listSKU = new List<ASI_MFM_SKU_Code__c>();
            listSKU.add(new ASI_MFM_SKU_Code__c(RecordTypeid = recordTypeid, Name = 'SKU1', ASI_HK_CRM_IsPOSProduct__c = TRUE, ASI_CRM_TW_Current_Stock__c = 10));
            listSKU.add(new ASI_MFM_SKU_Code__c(RecordTypeid = recordTypeid, Name = 'SKU2', ASI_HK_CRM_IsPOSProduct__c = TRUE, ASI_CRM_TW_Current_Stock__c = 10));
            insert listSKU;
            
            //Insert Promotion Unit 
            recordTypeid = Global_RecordTypeCache.getRTId('ASI_CRM_Promotion_Unit__cASI_CRM_TW_PromotionUnit');
            ASI_CRM_Promotion_Unit__c promoUnit = new ASI_CRM_Promotion_Unit__c(RecordTypeid = recordTypeid, ASI_CRM_Promotion__c = promotion.id, ASI_CRM_Sub_brand__c = subBrand.id, ASI_CRM_Qty__c = 100);
            insert promoUnit;
            
            //Insert Promotion Target
            recordTypeid = Global_RecordTypeCache.getRTId('ASI_CRM_Promotion_Target__cASI_CRM_TW_PromotionTarget');
            ASI_CRM_Promotion_Target__c promoTarget = new ASI_CRM_Promotion_Target__c(RecordTypeid = recordTypeid, ASI_CRM_Promotion__c = promotion.id, ASI_CRM_Region__c = 'North', ASI_CRM_Target_Unit__c = 100);
            insert promoTarget;
            
            //Insert Promotion POSM
            recordTypeid = Global_RecordTypeCache.getRTId('ASI_CRM_Promotion_POSM__cASI_CRM_TW_PromotionPOSM');
            ASI_CRM_Promotion_POSM__c promoPOSM = new ASI_CRM_Promotion_POSM__c(RecordTypeid = recordTypeid, ASI_CRM_Promotion__c = promotion.id, ASI_CRM_SKU__c = listSKU[0].id, ASI_CRM_Qty__c = 100);
            insert promoPOSM; 
            
            ApexPages.StandardController stdController = new ApexPages.StandardController(promotion);
            ApexPages.currentPage().getParameters().put('id', promotion.Id);
            ASI_CRM_TW_PromotionSetup_Ctrl controller = new ASI_CRM_TW_PromotionSetup_Ctrl(stdController); 
            
            system.runAs(u){
                Test.StartTest();
                
                controller.intRowid = 0;
                
                controller.addPromoUnit();
                controller.clonePromoUnit();
                controller.deletePromoUnit();
                
                controller.addPromoTarget();
                controller.clonePromoTarget();
                controller.deletePromoTarget();
                
                controller.searchSKU = 'sku';
                controller.searchSKU();
                
                controller.addPromoPOSM();
                controller.deletePromoPOSM();
                
                controller.quickSave();
                controller.saveAction();            
                controller.reset();
                
                Test.StopTest();
            }            
    }
    
    /*For ASI_CRM_TW_PromotionStatus_Ctrl, ASI_CRM_TW_PromoStatus_TriggerCls, ASI_CRM_PromoStatus_BeforeInsert, ASI_CRM_PromoStatus_BeforeUpdate*/
    public static testMethod void ASI_CRM_TW_PromotionStatus_Ctrl_Test() {
        user u = [select userRole.developerName from user where id = :userInfo.getUserId()];
        PermissionSet ps = [SELECT Id, Name FROM PermissionSet WHERE Name='ASI_CRM_TW_System_Admin'];
        
        //Assign permission set 'ASI_CRM_TW_System_Admin' to user u 
        PermissionSetAssignment psa = new PermissionSetAssignment(PermissionSetId = ps.id, AssigneeId = u.id);              
            
        //Insert Outlet type
        String recordTypeid = Global_RecordTypeCache.getRTId('ASI_TH_CRM_OutletType__cASI_CRM_TW_Outlet_Type');
        ASI_TH_CRM_OutletType__c outletType = new ASI_TH_CRM_OutletType__c(Name = 'LS (零售菸專)', ASI_TH_CRM_Code__c = 'TW_LS', RecordTypeid = recordTypeid);
        insert outletType;
         
        List<Account> listAccount = new List<Account>();
        List<ASI_CRM_AccountsAdditionalField__c> listCustomer = new List<ASI_CRM_AccountsAdditionalField__c>();
        
        //Insert Account
        recordTypeid = Global_RecordTypeCache.getRTId('AccountASI_CRM_TW_Outlet');   
        listAccount.add(new Account(Name='Outlet1', RecordTypeid = recordTypeid, ownerid = u.id, ASI_TH_CRM_Region__c = 'North'));
        listAccount.add(new Account(Name='Outlet2', RecordTypeid = recordTypeid, ownerid = u.id, ASI_TH_CRM_Region__c = 'South'));
        recordTypeid = Global_RecordTypeCache.getRTId('AccountASI_CRM_TW_Wholesaler');   
        listAccount.add(new Account(Name='WS', RecordTypeid = recordTypeid, ownerid = u.id));                
        insert listAccount;
        
        //Insert Customer
        recordTypeid = Global_RecordTypeCache.getRTId('ASI_CRM_AccountsAdditionalField__cASI_CRM_TW_Outlet');
        listCustomer.add(new ASI_CRM_AccountsAdditionalField__c(Name = 'Customer1', ASI_CRM_Account__c = listAccount[0].id, ASI_TH_CRM_OutletType__c = outletType.id, ASI_CRM_Region__c = 'North',
                                                                RecordTypeid = recordTypeid, ASI_CRM_City__c = 'Test City', ASI_CRM_Town__c = 'Test Town', ASI_CRM_TW_Street__c = 'Test Street', 
                                                                ASI_CRM_TW_Number__c = '1', ASI_CRM_TW_Floor__c = '12', ASI_CRM_MY_GeoConverStatus__c = 'Completed'));      
        listCustomer.add(new ASI_CRM_AccountsAdditionalField__c(Name = 'Customer2', ASI_CRM_Account__c = listAccount[1].id, ASI_TH_CRM_OutletType__c = outletType.id, ASI_CRM_Region__c = 'North',
                                                                RecordTypeid = recordTypeid, ASI_CRM_City__c = 'Test City', ASI_CRM_Town__c = 'Test Town', ASI_CRM_TW_Street__c = 'Test Street', 
                                                                ASI_CRM_TW_Number__c = '1', ASI_CRM_TW_Floor__c = '12', ASI_CRM_MY_GeoConverStatus__c = 'Completed'));
        listCustomer.add(new ASI_CRM_AccountsAdditionalField__c(Name = 'Customer3', ASI_CRM_Account__c = listAccount[2].id, ASI_TH_CRM_OutletType__c = outletType.id, ASI_CRM_Region__c = 'North',
                                                                RecordTypeid = recordTypeid, ASI_CRM_City__c = 'Test City', ASI_CRM_Town__c = 'Test Town', ASI_CRM_TW_Street__c = 'Test Street', 
                                                                ASI_CRM_TW_Number__c = '1', ASI_CRM_TW_Floor__c = '12', ASI_CRM_MY_GeoConverStatus__c = 'Completed'));                                                           
        insert listCustomer;
         
        //Insert promotion
        recordTypeid = Global_RecordTypeCache.getRTId('ASI_HK_CRM_Promotion__cASI_CRM_TW_ChannelPromotion');
        ASI_HK_CRM_Promotion__c promotion = new ASI_HK_CRM_Promotion__c(Name = 'Promotion', RecordTypeid = recordTypeid, ASI_CRM_PurchaseDueDate__c = date.today(), 
                                                                        ASI_HK_CRM_Promotion_Start_Date__c = date.today()-1, ASI_HK_CRM_Promotion_End_Date__c = date.today()+1,
                                                                        ASI_CRM_Display_Check__c = TRUE, ASI_CRM_Display_Setup__c = TRUE, ASI_CRM_POSM__c = TRUE);
        insert promotion;
        
        //Insert Promotion Target
        recordTypeid = Global_RecordTypeCache.getRTId('ASI_CRM_Promotion_Target__cASI_CRM_TW_PromotionTarget');
        ASI_CRM_Promotion_Target__c promoTarget = new ASI_CRM_Promotion_Target__c(RecordTypeid = recordTypeid, ASI_CRM_Promotion__c = promotion.id, ASI_CRM_Region__c = 'North', ASI_CRM_Target_Unit__c = 100, ASI_CRM_Confirmed__c = TRUE);
        insert promoTarget;
            
        //Insert Promotion Status
        recordTypeid = Global_RecordTypeCache.getRTId('ASI_CRM_Promotion_Status__cASI_CRM_TW_PromotionStatus');
        List<ASI_CRM_Promotion_Status__c> listPromoStatus = new List<ASI_CRM_Promotion_Status__c>();
        listPromoStatus.add(new ASI_CRM_Promotion_Status__c(RecordTypeid = recordTypeid, ASI_CRM_Promotion__c = promotion.id, ASI_CRM_Account__c = listAccount[0].id, ASI_CRM_Supplier__c = listAccount[2].id, ASI_CRM_Unit__c = 100));
        listPromoStatus.add(new ASI_CRM_Promotion_Status__c(RecordTypeid = recordTypeid, ASI_CRM_Promotion__c = promotion.id, ASI_CRM_Account__c = listAccount[1].id, ASI_CRM_Supplier__c = listAccount[2].id, ASI_CRM_Confirmed__c = TRUE, ASI_CRM_Unit__c = 100));
        listPromoStatus.add(new ASI_CRM_Promotion_Status__c(RecordTypeid = recordTypeid, ASI_CRM_Promotion__c = promotion.id, ASI_CRM_Account__c = listAccount[1].id, ASI_CRM_Supplier__c = listAccount[2].id, ASI_CRM_Confirmed__c = TRUE, ASI_CRM_Unit__c = 100));
        insert listPromoStatus;
        
        Blob bodyBlob = Blob.valueOf('Unit Test Attachment Body');
        ASI_CRM_TW_PromotionStatus_Ctrl.insertAttachment(listPromoStatus[0].id, EncodingUtil.base64Encode(bodyBlob), 'PromoStatus_Test', '1', null);
        
        ApexPages.StandardController stdController = new ApexPages.StandardController(promotion);
        ApexPages.currentPage().getParameters().put('id', promotion.Id);
        ASI_CRM_TW_PromotionStatus_Ctrl controller = new ASI_CRM_TW_PromotionStatus_Ctrl(stdController); 
        
        system.runAs(u){
            Test.StartTest();
            update promoTarget;
            
            controller.intRowid = 0;
            controller.checkOutlet();
            controller.selectView = 'My Outlets';
            controller.checkViewSelection();
            
            ASI_CRM_TW_PromotionStatus_Ctrl.findSObjects('ASI_CRM_AccountsAdditionalField__c', '', null);
            
            controller.quickSave();
            controller.saveAction();
            
            controller.intRowid = 0;
            controller.addPromoStatus();
            controller.clonePromoStatus();
            controller.deletePromoStatus();
            
            controller.quickSave();
            controller.saveAction();
            Test.StopTest();
        } 
    }
    
    /* For ASI_CRM_TW_PromotionPOSM_Query_Ctrl*/
    public static testMethod void ASI_CRM_TW_PromotionPOSM_Query_Ctrl_Test() {
        user u = [select userRole.developerName from user where id = :userInfo.getUserId()];
        PermissionSet ps = [SELECT Id, Name FROM PermissionSet WHERE Name='ASI_CRM_TW_System_Admin'];
        
        //Assign permission set 'ASI_CRM_TW_System_Admin' to user u 
        PermissionSetAssignment psa = new PermissionSetAssignment(PermissionSetId = ps.id, AssigneeId = u.id);
        
        ASI_CRM_TW_Settings__c customSetting = new ASI_CRM_TW_Settings__c(ASI_CRM_TW_POSM_Image_Account_Id__c = '-2');
        insert customSetting;
            
        //Insert promotion
        String recordTypeid = Global_RecordTypeCache.getRTId('ASI_HK_CRM_Promotion__cASI_CRM_TW_ChannelPromotion');
        ASI_HK_CRM_Promotion__c promotion = new ASI_HK_CRM_Promotion__c(Name = 'Promotion', RecordTypeid = recordTypeid, ASI_CRM_PurchaseDueDate__c = date.today(), ASI_HK_CRM_Promotion_Start_Date__c = date.today()-1, ASI_HK_CRM_Promotion_End_Date__c = date.today()+1);
        insert promotion;
        
        //Insert Sub-brand
        recordTypeid = Global_RecordTypeCache.getRTId('ASI_MFM_Sub_brand__cASI_MFM_TW_Sub_brand');
        ASI_MFM_Sub_brand__c subBrand = new ASI_MFM_Sub_brand__c(Name = 'subBrand', RecordTypeid = recordTypeid, ASI_CRM_TW_Company__c = 'PRT');
        insert subBrand;
        
        //Insert SKU
        recordTypeid = Global_RecordTypeCache.getRTId('ASI_MFM_SKU_Code__cASI_MFM_TW_SKU_Code');
        List<ASI_MFM_SKU_Code__c> listSKU = new List<ASI_MFM_SKU_Code__c>();
        listSKU.add(new ASI_MFM_SKU_Code__c(RecordTypeid = recordTypeid, Name = 'SKU1', ASI_HK_CRM_IsPOSProduct__c = TRUE, ASI_CRM_Category__c = 'category', ASI_CRM_Region__c = 'region', ASI_CRM_TW_Current_Stock__c = 10));
        listSKU.add(new ASI_MFM_SKU_Code__c(RecordTypeid = recordTypeid, Name = 'SKU2', ASI_HK_CRM_IsPOSProduct__c = TRUE));
        insert listSKU;
        
        //Insert Promotion POSM
        recordTypeid = Global_RecordTypeCache.getRTId('ASI_CRM_Promotion_POSM__cASI_CRM_TW_PromotionPOSM');
        ASI_CRM_Promotion_POSM__c promoPOSM = new ASI_CRM_Promotion_POSM__c(RecordTypeid = recordTypeid, ASI_CRM_Promotion__c = promotion.id, ASI_CRM_SKU__c = listSKU[0].id, ASI_CRM_Qty__c = 100);
        insert promoPOSM; 
        
        ASI_CRM_TW_PromotionPOSM_Query_Ctrl controller = new ASI_CRM_TW_PromotionPOSM_Query_Ctrl(); 
        
        Test.StartTest();
        
        system.runAs(u){
            controller.getSearchCategoryOptions();
            controller.getSearchSubBrandOptions();
            controller.getSearchRegionOptions();
            
            controller.searchSKU = 'SKU';
            controller.searchCategory = 'category';
            controller.searchSubBrand = 'subBrand';
            controller.searchRegion = 'region';
            
            controller.Beginning();
            controller.Previous();
            controller.Next();
            controller.End();           
            
            controller.search();
            controller.pageRedirect();
            controller.reset();
        }  
        
        Test.StopTest();  
    }
    
    /*For ASI_CRM_TW_PromoStatusByPromotion_Ctrl*/
    public static testMethod void ASI_CRM_TW_PromoStatusByPromotion_Ctrl_Test() {
        user u = [select userRole.developerName from user where id = :userInfo.getUserId()];
        PermissionSet ps = [SELECT Id, Name FROM PermissionSet WHERE Name='ASI_CRM_TW_System_Admin'];
        
        //Assign permission set 'ASI_CRM_TW_System_Admin' to user u 
        PermissionSetAssignment psa = new PermissionSetAssignment(PermissionSetId = ps.id, AssigneeId = u.id);              
            
        //Insert Outlet type
        String recordTypeid = Global_RecordTypeCache.getRTId('ASI_TH_CRM_OutletType__cASI_CRM_TW_Outlet_Type');
        ASI_TH_CRM_OutletType__c outletType = new ASI_TH_CRM_OutletType__c(Name = 'LS (零售菸專)', ASI_TH_CRM_Code__c = 'TW_LS', RecordTypeid = recordTypeid);
        insert outletType;
         
        List<Account> listAccount = new List<Account>();
        List<ASI_CRM_AccountsAdditionalField__c> listCustomer = new List<ASI_CRM_AccountsAdditionalField__c>();
        
        //Insert Account
        recordTypeid = Global_RecordTypeCache.getRTId('AccountASI_CRM_TW_Outlet');   
        listAccount.add(new Account(Name='Outlet1', RecordTypeid = recordTypeid, ownerid = u.id, ASI_TH_CRM_Region__c = 'North'));
        listAccount.add(new Account(Name='Outlet2', RecordTypeid = recordTypeid, ownerid = u.id, ASI_TH_CRM_Region__c = 'South'));
        recordTypeid = Global_RecordTypeCache.getRTId('AccountASI_CRM_TW_Wholesaler');   
        listAccount.add(new Account(Name='WS', RecordTypeid = recordTypeid, ownerid = u.id));                
        insert listAccount;
        
        //Insert Customer
        recordTypeid = Global_RecordTypeCache.getRTId('ASI_CRM_AccountsAdditionalField__cASI_CRM_TW_Outlet');
        listCustomer.add(new ASI_CRM_AccountsAdditionalField__c(Name = 'Customer1', ASI_CRM_Account__c = listAccount[0].id, ASI_TH_CRM_OutletType__c = outletType.id, ASI_CRM_Region__c = 'North',
                                                                RecordTypeid = recordTypeid, ASI_CRM_City__c = 'Test City', ASI_CRM_Town__c = 'Test Town', ASI_CRM_TW_Street__c = 'Test Street', 
                                                                ASI_CRM_TW_Number__c = '1', ASI_CRM_TW_Floor__c = '12', ASI_CRM_MY_GeoConverStatus__c = 'Completed'));      
        listCustomer.add(new ASI_CRM_AccountsAdditionalField__c(Name = 'Customer2', ASI_CRM_Account__c = listAccount[1].id, ASI_TH_CRM_OutletType__c = outletType.id, ASI_CRM_Region__c = 'North',
                                                                RecordTypeid = recordTypeid, ASI_CRM_City__c = 'Test City', ASI_CRM_Town__c = 'Test Town', ASI_CRM_TW_Street__c = 'Test Street', 
                                                                ASI_CRM_TW_Number__c = '1', ASI_CRM_TW_Floor__c = '12', ASI_CRM_MY_GeoConverStatus__c = 'Completed'));
        listCustomer.add(new ASI_CRM_AccountsAdditionalField__c(Name = 'Customer3', ASI_CRM_Account__c = listAccount[2].id, ASI_TH_CRM_OutletType__c = outletType.id, ASI_CRM_Region__c = 'North',
                                                                RecordTypeid = recordTypeid, ASI_CRM_City__c = 'Test City', ASI_CRM_Town__c = 'Test Town', ASI_CRM_TW_Street__c = 'Test Street', 
                                                                ASI_CRM_TW_Number__c = '1', ASI_CRM_TW_Floor__c = '12', ASI_CRM_MY_GeoConverStatus__c = 'Completed'));                                                           
        insert listCustomer;
         
        //Insert promotion
        recordTypeid = Global_RecordTypeCache.getRTId('ASI_HK_CRM_Promotion__cASI_CRM_TW_ChannelPromotion');
        ASI_HK_CRM_Promotion__c promotion = new ASI_HK_CRM_Promotion__c(Name = 'Promotion', RecordTypeid = recordTypeid, ASI_CRM_PurchaseDueDate__c = date.today(), 
                                                                        ASI_HK_CRM_Promotion_Start_Date__c = date.today()-1, ASI_HK_CRM_Promotion_End_Date__c = date.today()+1,
                                                                        ASI_CRM_Display_Check__c = TRUE, ASI_CRM_Display_Setup__c = TRUE, ASI_CRM_POSM__c = TRUE);
        insert promotion;
        
        //Insert Promotion Target
        recordTypeid = Global_RecordTypeCache.getRTId('ASI_CRM_Promotion_Target__cASI_CRM_TW_PromotionTarget');
        ASI_CRM_Promotion_Target__c promoTarget = new ASI_CRM_Promotion_Target__c(RecordTypeid = recordTypeid, ASI_CRM_Promotion__c = promotion.id, ASI_CRM_Region__c = 'North', ASI_CRM_Target_Unit__c = 100, ASI_CRM_Confirmed__c = TRUE);
        insert promoTarget;
            
        //Insert Promotion Status
        recordTypeid = Global_RecordTypeCache.getRTId('ASI_CRM_Promotion_Status__cASI_CRM_TW_PromotionStatus');
        List<ASI_CRM_Promotion_Status__c> listPromoStatus = new List<ASI_CRM_Promotion_Status__c>();
        listPromoStatus.add(new ASI_CRM_Promotion_Status__c(RecordTypeid = recordTypeid, ASI_CRM_Promotion__c = promotion.id, ASI_CRM_Account__c = listAccount[0].id, ASI_CRM_Supplier__c = listAccount[2].id, ASI_CRM_Unit__c = 100));
        listPromoStatus.add(new ASI_CRM_Promotion_Status__c(RecordTypeid = recordTypeid, ASI_CRM_Promotion__c = promotion.id, ASI_CRM_Account__c = listAccount[1].id, ASI_CRM_Supplier__c = listAccount[2].id, ASI_CRM_Confirmed__c = TRUE, ASI_CRM_Unit__c = 100));
        listPromoStatus.add(new ASI_CRM_Promotion_Status__c(RecordTypeid = recordTypeid, ASI_CRM_Promotion__c = promotion.id, ASI_CRM_Account__c = listAccount[1].id, ASI_CRM_Supplier__c = listAccount[2].id, ASI_CRM_Confirmed__c = TRUE, ASI_CRM_Unit__c = 100));
        insert listPromoStatus;

        List<Attachment> listAttch = new List<Attachment>();
        listAttch.add(new Attachment(ParentId = listPromoStatus[0].id, Name = 'PromoStatus_0001', Body = EncodingUtil.base64Decode('Test Data')));
        listAttch.add(new Attachment(ParentId = listPromoStatus[0].id, Name = 'PromoStatus_0002', Body = EncodingUtil.base64Decode('Test Data')));
        insert listAttch;
        
         
        
        Test.StartTest();
        
        system.runAs(u) {
            ApexPages.StandardController stdController = new ApexPages.StandardController(promotion);
            ApexPages.currentPage().getParameters().put('id', promotion.Id);
            ASI_CRM_TW_PromoStatusByPromotion_Ctrl controller = new ASI_CRM_TW_PromoStatusByPromotion_Ctrl(stdController);
            
            List<String> listDone = new List<String>();
            listDone.add('true');
            List<String> listChannel = new List<String>();
            listChannel.add('channel');
            List<String> listRegion = new List<String>();
            listRegion.add('North');
            List<String> listType = new List<String>();
            listType.add('Display Setup');
            
            controller.getChannelList();
            controller.getRegionList();
            controller.getDoneList();
            controller.getTaskList();
            
            controller.searchDone = listDone;
            controller.searchTaskType = listType;
            controller.searchChannel = listChannel;
            controller.searchRegion = listRegion;
            
            controller.getSearchDoneSOQL(listDone);
            controller.getSeacrhTaskTypeSOQL(listType);
            controller.getSeacrhChannelTypeSOQL(listChannel);
            controller.getSearchRegionSOQL(listRegion);
            controller.ViewSearch();
            
            
            controller.searchCurrentPage();
            controller.pageRedirect();
            controller.Beginning();
            controller.Previous();
            controller.Next();
            controller.End();         
        }    
        
        Test.StopTest();
    }
}