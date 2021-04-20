@isTest(SeeAllData=false)
private class ASI_CRM_TW_TestClass{  
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
    
    /*
    Covered Class: 
    ASI_CRM_TW_AccountEdit_Controller 
    ASI_CRM_TW_AdditionalFieldToAccount 
    */
    static testMethod void CreateAccountTest(){
        Test.setMock(HttpCalloutMock.class, new HTTPMockCallout());
        user u = [SELECT id, ASI_CN_NPL_Receive_Approval_Request__c, DelegatedApproverId, Managerid, userroleid, ASI_KOR_User_Region_Code__c
        from user where (profile.Name = 'System Administrator' or profile.Name = 'ASI System Administrator') and isactive = true and userroleid <> null limit 1];                                                                          
        
        System.runAs(u) {
            String recordTypeid = checkRecordType('ASI_TH_CRM_OutletType__c','ASI_CRM_TW_Outlet_Type');
            ASI_TH_CRM_OutletType__c outletType = new ASI_TH_CRM_OutletType__c(Name = 'LS (零售菸專)', ASI_TH_CRM_Code__c = 'TW_LS', RecordTypeid = recordTypeid);
            insert outletType;
        
            List<Account> insertAccountList = new List<Account>();
            List<ASI_CRM_AccountsAdditionalField__c> insertAccountAdditionalFieldList = new List<ASI_CRM_AccountsAdditionalField__c>();
            
            recordTypeid = checkRecordType('Account','ASI_CRM_TW_Outlet');    
            Account outlet = new Account(Name='Test Outlet', RecordTypeid = recordTypeid, ownerid = u.id);
            insertAccountList.add(outlet);

            Account outlet2 = new Account(Name='Test Outlet 2', RecordTypeid = recordTypeid, ownerid = u.id  );
            insertAccountList.add(outlet2);
            
            Account outlet3 = new Account(Name='Test Outlet 3', ownerid = u.id );
            insertAccountList.add(outlet3);
            
            Account outlet4 = new Account(Name='Test Outlet 3', ownerid = u.id, RecordTypeid = recordTypeid );
            insertAccountList.add(outlet4);
            
            insert insertAccountList;
            
            recordTypeid = checkRecordType('ASI_CRM_AccountsAdditionalField__c','ASI_CRM_TW_Outlet');
            ASI_CRM_AccountsAdditionalField__c accountAdditionalField = new ASI_CRM_AccountsAdditionalField__c(
                Name = 'Test Outlet', ASI_CRM_Account__c = outlet.id, ASI_TH_CRM_OutletType__c = outletType.id, ASI_CRM_Region__c = 'North',RecordTypeid = recordTypeid,
                ASI_CRM_City__c = 'Test City', ASI_CRM_Town__c = 'Test Town', ASI_CRM_TW_Street__c = 'Test Street', ASI_CRM_TW_Number__c = '1', ASI_CRM_TW_Floor__c = '12'
            );
            insertAccountAdditionalFieldList.add(accountAdditionalField);
            
            insert insertAccountAdditionalFieldList;
            
            Test.starttest();
            ApexPages.Standardcontroller stdController = new ApexPages.Standardcontroller(outlet);
            ASI_CRM_TW_AccountEdit_Controller controller = new ASI_CRM_TW_AccountEdit_Controller(stdController); 
            controller.save();

            stdController = new ApexPages.Standardcontroller(outlet3);
            controller = new ASI_CRM_TW_AccountEdit_Controller(stdController); 
            controller.save();
            
            stdController = new ApexPages.Standardcontroller(outlet4);
            controller = new ASI_CRM_TW_AccountEdit_Controller(stdController); 
            controller.save();
            
            stdController = new ApexPages.Standardcontroller(outlet);          
            controller = new ASI_CRM_TW_AccountEdit_Controller(stdController);
            controller.accountAdditionalField.ASI_CRM_Account__c = null; 
            controller.save();
            
            List<SelectOption> OutletTypeList = controller.OutletTypeList;
            
            insertAccountAdditionalFieldList[0].ASI_CRM_TW_Parent_Account__c = outlet4.id;
            insertAccountAdditionalFieldList[0].ASI_CRM_IsParentAccount__c = true;
            
            update insertAccountAdditionalFieldList[0];
            
            Test.stoptest();
            
        }
    }

    static testMethod void CreateAccountTest2(){
        Test.setMock(HttpCalloutMock.class, new HTTPMockCallout());
        user u = [SELECT id, ASI_CN_NPL_Receive_Approval_Request__c, DelegatedApproverId, Managerid, userroleid, ASI_KOR_User_Region_Code__c
        from user where (profile.Name = 'System Administrator' or profile.Name = 'ASI System Administrator') and isactive = true and userroleid <> null limit 1];                                                                          
        
        System.runAs(u) {
            String recordTypeid = checkRecordType('ASI_TH_CRM_OutletType__c','ASI_CRM_TW_Outlet_Type');
            ASI_TH_CRM_OutletType__c outletType = new ASI_TH_CRM_OutletType__c(Name = 'LS (零售菸專)', ASI_TH_CRM_Code__c = 'TW_LS', RecordTypeid = recordTypeid);
            insert outletType;
        
            List<Account> insertAccountList = new List<Account>();
            List<ASI_CRM_AccountsAdditionalField__c> insertAccountAdditionalFieldList = new List<ASI_CRM_AccountsAdditionalField__c>();
            
            recordTypeid = checkRecordType('Account','ASI_CRM_TW_Outlet');    
            Account outlet = new Account(Name='Test Outlet', RecordTypeid = recordTypeid, ownerid = u.id);
            insertAccountList.add(outlet);

            Account outlet2 = new Account(Name='Test Outlet 2', RecordTypeid = recordTypeid, ownerid = u.id  );
            insertAccountList.add(outlet2);
            
            Account outlet3 = new Account(Name='Test Outlet 3', ownerid = u.id );
            insertAccountList.add(outlet3);
            
            Account outlet4 = new Account(Name='Test Outlet 3', ownerid = u.id, RecordTypeid = recordTypeid );
            insertAccountList.add(outlet4);
            
            insert insertAccountList;
            
            recordTypeid = checkRecordType('ASI_CRM_AccountsAdditionalField__c','ASI_CRM_TW_Outlet');
            ASI_CRM_AccountsAdditionalField__c accountAdditionalField = new ASI_CRM_AccountsAdditionalField__c(
                Name = 'Test Outlet', ASI_CRM_Account__c = outlet.id, ASI_TH_CRM_OutletType__c = outletType.id, ASI_CRM_Region__c = 'North',RecordTypeid = recordTypeid,
                ASI_CRM_City__c = 'Test City', ASI_CRM_Town__c = 'Test Town', ASI_CRM_TW_Street__c = 'Test Street', ASI_CRM_TW_Number__c = '1', ASI_CRM_TW_Floor__c = '12'
            );
            insertAccountAdditionalFieldList.add(accountAdditionalField);
            
            insert insertAccountAdditionalFieldList;
            
            Test.starttest();
            ApexPages.Standardcontroller stdController = new ApexPages.Standardcontroller(outlet);
            ASI_CRM_TW_AccountEdit_Controller controller = new ASI_CRM_TW_AccountEdit_Controller(stdController); 
            controller.save();

            stdController = new ApexPages.Standardcontroller(outlet3);
            controller = new ASI_CRM_TW_AccountEdit_Controller(stdController); 
            controller.save();
            
            stdController = new ApexPages.Standardcontroller(outlet4);
            controller = new ASI_CRM_TW_AccountEdit_Controller(stdController); 
            controller.save();
            
            stdController = new ApexPages.Standardcontroller(outlet);          
            controller = new ASI_CRM_TW_AccountEdit_Controller(stdController);
            controller.accountAdditionalField.ASI_CRM_Account__c = null; 
            controller.save();

            stdController = new ApexPages.Standardcontroller(outlet);          
            controller = new ASI_CRM_TW_AccountEdit_Controller(stdController);
            controller.whAddrSamesAs = true;
            controller.updateWarehouseAddress();
            controller.whAddrSamesAs = false;
            controller.updateWarehouseAddress();

            controller.invAddrSamesAs = true;
            controller.updateInvoiceAddress();
            controller.invAddrSamesAs = false;
            controller.updateInvoiceAddress();
            
            List<SelectOption> OutletTypeList = controller.OutletTypeList;
            
            insertAccountAdditionalFieldList[0].ASI_CRM_TW_Parent_Account__c = outlet4.id;
            insertAccountAdditionalFieldList[0].ASI_CRM_IsParentAccount__c = true;
            
            update insertAccountAdditionalFieldList[0];
            
            Test.stoptest();
            
        }
    }
    
    /*
    ASI_CRM_TW_AccountsAdditional_TriggerCls
    */
    static testMethod void AccountMovementTest(){
        Test.setMock(HttpCalloutMock.class, new HTTPMockCallout());
        user u = [SELECT id, ASI_CN_NPL_Receive_Approval_Request__c, DelegatedApproverId, Managerid, userroleid
        from user where (profile.Name = 'System Administrator' or profile.Name = 'ASI System Administrator') and isactive = true and userroleid <> null limit 1];                                                
        
        System.runAs(u) {
            //Added by Twinkle LI @20150615
            List<ASI_CRM_CN_Channel__c> ch = new List<ASI_CRM_CN_Channel__c>();
            ch.add(new ASI_CRM_CN_Channel__c(ASI_CRM_CN_Channel_Chi_Name__c = 'Channel1'));
            ch.add(new ASI_CRM_CN_Channel__c(ASI_CRM_CN_Channel_Chi_Name__c = 'Channel2'));
            insert ch;
            
            List<ASI_MFM_Sub_Channel__c> sc = new List<ASI_MFM_Sub_Channel__c>();
            sc.add(new ASI_MFM_Sub_Channel__c(ASI_CRM_CN_Channel__c = ch[0].id));   
            sc.add(new ASI_MFM_Sub_Channel__c(ASI_CRM_CN_Channel__c = ch[1].id));       
            insert sc;
            //End by Twinkle LI @20150615
            
            String recordTypeid = checkRecordType('ASI_TH_CRM_OutletType__c','ASI_CRM_TW_Outlet_Type');
            List<ASI_TH_CRM_OutletType__c> outletType = new List<ASI_TH_CRM_OutletType__c>();
            outletType.add(new ASI_TH_CRM_OutletType__c(Name = 'LS (零售菸專)', ASI_TH_CRM_Code__c = 'TW_LS', RecordTypeid = recordTypeid, ASI_CRM_Sub_Channel__c = sc[0].id));
            outletType.add(new ASI_TH_CRM_OutletType__c(Name = 'CR (中餐廳, 日式料理, 快炒)', ASI_TH_CRM_Code__c = 'TW_CR', RecordTypeid = recordTypeid, ASI_CRM_Sub_Channel__c = sc[1].id));
            insert outletType;
        
            List<Account> insertAccountList = new List<Account>();
            
            recordTypeid = checkRecordType('Account','ASI_CRM_TW_Outlet');    
            Account outlet = new Account(Name='Test Outlet', RecordTypeid = recordTypeid, ownerid = u.id);
            insertAccountList.add(outlet);            
            
            insert insertAccountList;

            ASI_CRM_CN_Channel__c channel = new ASI_CRM_CN_Channel__c(Name = 'HBR', ASI_CRM_CN_Channel_Code__c = 'HBR');
            insert channel ; 

            ASI_CRM_CN_Channel__c channel2 = new ASI_CRM_CN_Channel__c(Name = 'HBR2', ASI_CRM_CN_Channel_Code__c = 'HBR2');
            insert channel2; 

            ASI_MFM_Sub_Channel__c subChannel = new ASI_MFM_Sub_Channel__c(Name = 'Sub-Channel', ASI_CRM_CN_Channel__c = channel.id);
            insert subChannel;

            ASI_MFM_Sub_Channel__c subChannel2 = new ASI_MFM_Sub_Channel__c(Name = 'Sub-Channel2', ASI_CRM_CN_Channel__c = channel2.id);
            insert subChannel2;
            
            recordTypeid = checkRecordType('ASI_CRM_AccountsAdditionalField__c','ASI_CRM_TW_Outlet');
            ASI_CRM_AccountsAdditionalField__c accountAdditionalField = new ASI_CRM_AccountsAdditionalField__c(
                Name = 'Test Outlet', ASI_CRM_Account__c = outlet.id, ASI_TH_CRM_OutletType__c = outletType[0].id, ASI_CRM_Region__c = 'North',RecordTypeid = recordTypeid,
                ASI_CRM_City__c = 'Test City', ASI_CRM_Town__c = 'Test Town', ASI_CRM_TW_Street__c = 'Test Street', ASI_CRM_TW_Number__c = '1', ASI_CRM_TW_Floor__c = '12', ASI_CRM_CN_Sub_Channel__c = subChannel.id
            );
            insert accountAdditionalField;
            
            //Added by Twinkle LI @20150615
            recordtypeId = checkRecordType('ASI_CRM_Pros_Segmentation__c', 'ASI_CRM_TW_PROS_Segmentation');
            ASI_CRM_Pros_Segmentation__c prosSegmentation = new ASI_CRM_Pros_Segmentation__c();
            prosSegmentation.RecordTypeId = recordtypeId;
            prosSegmentation.CurrencyIsoCode = 'TWD';
            prosSegmentation.ASI_CRM_SG_Customer__c = accountAdditionalField.id;
            insert prosSegmentation;
            //End by Twinkle LI @20150615
            
            accountAdditionalField.Name = 'Test Outlet Updated';
            accountAdditionalField.ASI_TH_CRM_OutletType__c = outletType[1].id;//Added by Twinkle LI @20150615
            accountAdditionalField.ASI_CRM_CN_Sub_Channel__c = subChannel2.id;
            update accountAdditionalField;

            test.startTest();
            accountAdditionalField.ASI_CRM_CN_Sub_Channel__c = subChannel.id;
            update accountAdditionalField;
            
            ApexPages.StandardController stdController = new ApexPages.StandardController(outlet);
            ASI_CRM_TW_AccountMovementCtrl controller = new ASI_CRM_TW_AccountMovementCtrl(stdController);                          
            controller.reset();
            
            Set <String> idSet = controller.AccountMovementPage.accountMovementMap.keySet();
            
            for (String key : idSet){
                ASI_CRM_TW_AccountMovementCtrl.AccountMovement am = controller.AccountMovementPage.accountMovementMap.get(key);
                am.isApproved = true;
                am.isDeleted = false;
                String strName = am.name;
                String strLegalName = am.legalName;
                String strAddress = am.address;
                String strActivation = am.activation;
                String strIsParentAccount = am.isParentAccount;
                String strOwner = am.owner;
                String strOutletType = am.outletType;
            }            
            update accountAdditionalField;//Added by Twinkle LI @20150615
            controller.Save();
            
            List<SelectOption> listRegion = controller.AccountMovementPage.regions;
            List<SelectOption> listChannels = controller.AccountMovementPage.channels;
            List<SelectOption> listSubChannels = controller.AccountMovementPage.subChanels;
            test.stopTest();
        }
    }
    
    public static testMethod void SalesVolumeCalculationBatchTest() {
        Test.setMock(HttpCalloutMock.class, new HTTPMockCallout());
        user u = [SELECT id, ASI_CN_NPL_Receive_Approval_Request__c, DelegatedApproverId, Managerid, userroleid
        from user where (profile.Name = 'System Administrator' or profile.Name = 'ASI System Administrator') and isactive = true and userroleid <> null limit 1];                                                
        system.debug('user: '+u);
        
        System.runAs(u) {
            ASI_CRM_CN_Channel__c channel = new ASI_CRM_CN_Channel__c(Name = 'HBR', ASI_CRM_CN_Channel_Code__c = 'HBR');
            insert channel ; 
        
            ASI_MFM_Sub_Channel__c subChannel = new ASI_MFM_Sub_Channel__c(Name = 'Sub-Channel', ASI_CRM_CN_Channel__c = channel.id);
            insert subChannel;                    
        
            String recordTypeid = checkRecordType('ASI_TH_CRM_OutletType__c','ASI_CRM_TW_Outlet_Type');
            ASI_TH_CRM_OutletType__c outletType = new ASI_TH_CRM_OutletType__c(Name = 'LS (零售菸專)', ASI_TH_CRM_Code__c = 'TW_LS', 
            RecordTypeid = recordTypeid, ASI_CRM_Sub_Channel__c = subChannel.id);
            insert outletType;
        
            List<Account> insertAccountList = new List<Account>();
            List<ASI_CRM_AccountsAdditionalField__c> insertAccountAdditionalFieldList = new List<ASI_CRM_AccountsAdditionalField__c>();
            
            recordTypeid = checkRecordType('Account','ASI_CRM_TW_Outlet');    
            Account outlet = new Account(Name='Test Outlet', RecordTypeid = recordTypeid, ownerid = u.id);
            insertAccountList.add(outlet);            
            
            insert insertAccountList;                                   
            
            recordTypeid = checkRecordType('ASI_CRM_AccountsAdditionalField__c','ASI_CRM_TW_Outlet');
            ASI_CRM_AccountsAdditionalField__c accountAdditionalField = new ASI_CRM_AccountsAdditionalField__c(
                Name = 'Test Outlet', ASI_CRM_Account__c = outlet.id, ASI_TH_CRM_OutletType__c = outletType.id, ASI_CRM_Region__c = 'North',RecordTypeid = recordTypeid,
                ASI_CRM_City__c = 'Test City', ASI_CRM_Town__c = 'Test Town', ASI_CRM_TW_Street__c = 'Test Street', ASI_CRM_TW_Number__c = '1', ASI_CRM_TW_Floor__c = '12'
            );
            insertAccountAdditionalFieldList.add(accountAdditionalField);
            
            insert insertAccountAdditionalFieldList;
            
            recordTypeid = checkRecordType('ASI_HK_CRM_Product_Category__c','ASI_CRM_TW_Product_Category');
            ASI_HK_CRM_Product_Category__c productCategory = new ASI_HK_CRM_Product_Category__c(Name = 'Whisky', ASI_HK_CRM_Category_Code__c = 'WHY');
            insert productCategory;
                        
            recordTypeid = checkRecordType('ASI_MFM_Sub_brand__c','ASI_MFM_TW_Sub_brand');
            ASI_MFM_Sub_brand__c subBrand = new ASI_MFM_Sub_brand__c(Name = 'Chivas18y', ASI_CRM_TW_TOT__c = true, ASI_HK_CRM_Product_Category__c = productCategory.id, 
            ASI_CRM_TW_Company__c = 'PRT', RecordTypeid = recordTypeid);
            insert subBrand;
            
            ASI_CRM_OutletDepletion__c outletDepletion = new ASI_CRM_OutletDepletion__c(
                ASI_CRM_Outlet__c = outlet.id, ASI_CRM_SubBrand__c = subBrand.id, ASI_CRM_Date__c = System.today().addMonths(-2), ASI_CRM_Depletion__c = 100 );
            insert outletDepletion;
            
            ASI_CRM_OutletDepletion__c outletDepletion2 = new ASI_CRM_OutletDepletion__c(
                ASI_CRM_Outlet__c = outlet.id, ASI_CRM_SubBrand__c = subBrand.id, ASI_CRM_Date__c = System.today().addMonths(-1), ASI_CRM_Depletion__c = 100 );
            insert outletDepletion2;
            
            ASI_CRM_OutletDepletion__c outletDepletion3 = new ASI_CRM_OutletDepletion__c(
                ASI_CRM_Outlet__c = outlet.id, ASI_CRM_SubBrand__c = subBrand.id, ASI_CRM_Date__c = System.today().addMonths(-3), ASI_CRM_Depletion__c = 100 );
            insert outletDepletion3;
            
            ASI_CRM_OutletDepletion__c outletDepletion4 = new ASI_CRM_OutletDepletion__c(
                ASI_CRM_Outlet__c = outlet.id, ASI_CRM_SubBrand__c = subBrand.id, ASI_CRM_Date__c = System.today().addMonths(-4), ASI_CRM_Depletion__c = 100 );
            insert outletDepletion4;
            
            ASI_CRM_TW_Settings__c customSetting = new ASI_CRM_TW_Settings__c(
            ASI_CRM_TW_CalSaleVolumeFrom__c = -2, ASI_CRM_TW_CalSaleVolumeTo__c = -1);
            insert customSetting;
            
            Test.StartTest();
            string CORN_EXP = '0 0 0 1 4 ?';
            
            system.schedule('Sales Volume Calculation batch job', CORN_EXP, new ASI_CRM_TW_SalesVolumeCalculation_Schd());
            Test.StopTest();
        }
    }
    
    static testMethod void VPDTodayTest(){    
        Test.setMock(HttpCalloutMock.class, new HTTPMockCallout());
        user u = [SELECT id, ASI_CN_NPL_Receive_Approval_Request__c, DelegatedApproverId, Managerid, userroleid
        from user where (profile.Name = 'System Administrator' or profile.Name = 'ASI System Administrator') and isactive = true and userroleid <> null limit 1];                                                
        
        System.runAs(u) {
            String recordTypeid = checkRecordType('ASI_TH_CRM_OutletType__c','ASI_CRM_TW_Outlet_Type');
            ASI_TH_CRM_OutletType__c outletType = new ASI_TH_CRM_OutletType__c(Name = 'LS (零售菸專)', ASI_TH_CRM_Code__c = 'TW_LS', RecordTypeid = recordTypeid);
            insert outletType;
        
            List<Account> insertAccountList = new List<Account>();
            List<ASI_CRM_AccountsAdditionalField__c> insertAccountAdditionalFieldList = new List<ASI_CRM_AccountsAdditionalField__c>();
            
            recordTypeid = checkRecordType('Account','ASI_CRM_TW_Outlet');    
            Account outlet = new Account(Name='Test Outlet', RecordTypeid = recordTypeid, ownerid = u.id);
            insertAccountList.add(outlet);            
            
            insert insertAccountList;
            
            recordTypeid = checkRecordType('ASI_CRM_AccountsAdditionalField__c','ASI_CRM_TW_Outlet');
            ASI_CRM_AccountsAdditionalField__c accountAdditionalField = new ASI_CRM_AccountsAdditionalField__c(
                Name = 'Test Outlet', ASI_CRM_Account__c = outlet.id, ASI_TH_CRM_OutletType__c = outletType.id, ASI_CRM_Region__c = 'North',RecordTypeid = recordTypeid,
                ASI_CRM_City__c = 'Test City', ASI_CRM_Town__c = 'Test Town', ASI_CRM_TW_Street__c = 'Test Street', ASI_CRM_TW_Number__c = '1', ASI_CRM_TW_Floor__c = '12'
            );
            insertAccountAdditionalFieldList.add(accountAdditionalField);
            
            insert insertAccountAdditionalFieldList;
            
            /*Assign Month*/
            Map<Integer, String> m1 = new Map<Integer, String>();
               m1.put(01,'January');
               m1.put(02, 'February');
               m1.put(03, 'March');
               m1.put(04, 'April');
               m1.put(05, 'May');
               m1.put(06, 'June');
               m1.put(07, 'July');
               m1.put(08, 'August');
               m1.put(09, 'September');
               m1.put(10, 'October');
               m1.put(11, 'November');
               m1.put(12, 'December');
            Integer month = Date.today().month();
            string thismonth = m1.get(month);
            string  VPmonth = thismonth.left(3) ;
            /*Assign Year*/
            Integer year = Date.today().year();
            string VPyear = string.valueof(year); 
            recordTypeid = checkRecordType('ASI_HK_CRM_Visitation_Plan__c','ASI_CRM_TW_Visitation_Plan');
            ASI_HK_CRM_Visitation_Plan__c visitationPlan = new ASI_HK_CRM_Visitation_Plan__c(Name ='Test', RecordTypeid = recordTypeid,
                ASI_HK_CRM_Year__c =VPyear, ASI_HK_CRM_Month__c = thismonth, ownerid = u.id);
                
            insert visitationPlan;
            
             
            ASI_CRM_TW_Settings__c TWsettings = new ASI_CRM_TW_Settings__c(ASI_CRM_TW_HomepageToVPDId__c='CF00NM0000000qKti');
            insert TWsettings; 
            
            ASI_HK_CRM_Visitation_Plan_Detail__c vpDetail = new ASI_HK_CRM_Visitation_Plan_Detail__c( 
                ASI_HK_CRM_Account__c = outlet.id, ASI_HK_CRM_Visit_Date__c = Date.Today(), ASI_HK_CRM_Visitation_Plan__c = visitationPlan.id,
                ASI_TH_CRM_Visit_Date_Time_From__c = datetime.Now(), ASI_TH_CRM_Visit_Date_Time_To__c = datetime.Now()
            );
           insert vpDetail;
            vpDetail = [Select id from ASI_HK_CRM_Visitation_Plan_Detail__c limit 1];
    
            ApexPages.StandardController controller = new ApexPages.StandardController (vpDetail); 
            ASI_CRM_TW_VPDTodayCtrl controller1 = new ASI_CRM_TW_VPDTodayCtrl (controller);
            ApexPages.StandardController controller2 = new ApexPages.StandardController (visitationPlan); 
            ASI_CRM_TW_VPDTodayCtrl controller3 = new ASI_CRM_TW_VPDTodayCtrl (controller);
       }            
    }
    
    /*Testclass for: ASI_CRM_TW_PlanAttachDownload_Ctrl*/
    /*By Twinkle Li @20150611*/
    static testMethod void ASI_CRM_TW_PlanAttachDownload_Test(){
        user u = [select userRole.developerName, ASI_MFM_Country__c from user where id = :userInfo.getUserId()];  
        u.ASI_MFM_Country__c = 'TW';
        
        ASI_MFM_Prefix__c pxp = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', Plan_Type__c='rade A&P Plan', ASI_MFM_Fiscal_year__c = getFiscalYear());
        insert pxp;
        
        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxp.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pr;
            
        List<ASI_MFM_Plan__c> listPlan = new List<ASI_MFM_Plan__c>();
        listPlan.add(new ASI_MFM_Plan__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_TW_Plan'), name='test', ASI_MFM_End_Date__c=Date.today().addMonths(1), ASI_MFM_Prefix__c=pxp.id,
                                                ASI_MFM_Plan_Description__c='testPlanDescription', ASI_MFM_Plan_Name__c='testPlan', ASI_MFM_Start_Date__c=Date.today(), ASI_MFM_Status__c = 'Draft'));
        listPlan.add(new ASI_MFM_Plan__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_TW_Plan'), name='test', ASI_MFM_End_Date__c=Date.today().addMonths(1), ASI_MFM_Prefix__c=pxp.id,
                                                ASI_MFM_Plan_Description__c='testPlanDescription', ASI_MFM_Plan_Name__c='testPlan', ASI_MFM_Start_Date__c=Date.today(), ASI_MFM_Status__c = 'Final'));
        insert listPlan; 
        
        Test.StartTest();
        
        ApexPages.Standardcontroller stdController = new ApexPages.Standardcontroller(listPlan[0]);
        ApexPages.currentPage().getParameters().put('id', listPlan[0].Id);
        ASI_CRM_TW_PlanAttachDownload_Ctrl controller = new ASI_CRM_TW_PlanAttachDownload_Ctrl(stdController); 
        
        stdController = new ApexPages.Standardcontroller(listPlan[1]);
        ApexPages.currentPage().getParameters().put('id', listPlan[1].Id);
        controller = new ASI_CRM_TW_PlanAttachDownload_Ctrl(stdController);
        
        Test.StopTest();
    }
    
    /*Testclass for: ASI_MFM_MassCreateAndUpdateController TW parts*/
    /*Added by Introv (Twinkle Li) @20170323*/
    static testMethod void ASI_MFM_MassCreateAndUpdateController_Test(){
        Test.setMock(HttpCalloutMock.class, new HTTPMockCallout());
        ASI_MFM_Sub_brand__c sub = new ASI_MFM_Sub_brand__c(
            name = 'testSubBrand',
            ASI_CRM_TW_Company__c = 'PRT', 
            ASI_CRM_Active__c = TRUE, 
            ASI_TH_CRM_Active__c = TRUE,
            recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_MFM_TW_Sub_brand')
        );
        insert sub;
        
        ASI_CRM_CN_Channel__c channel = new ASI_CRM_CN_Channel__c(
            recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_CN_Channel__cASI_CRM_TW_Channel'), 
            Name = 'TOT (酒店)',
            ASI_CRM_CN_Channel_Code__c = 'TOT');
        insert channel;
        
        ASI_MFM_Sub_Channel__c subChannel = new ASI_MFM_Sub_Channel__c(
            Name = 'Piano Bar (PB)', 
            ASI_CRM_CN_Sub_Channel_Code__c = 'PB',
            ASI_CRM_CN_Channel__c = channel.id, 
            RecordTypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_Channel__cASI_CRM_TW_SubChannel'));
        insert subChannel;   
        
        ASI_TH_CRM_OutletType__c outletType = new ASI_TH_CRM_OutletType__c(
            RecordTypeid = Global_RecordTypeCache.getRtId('ASI_TH_CRM_OutletType__cASI_CRM_TW_Outlet_Type'),
            Name = 'PB (鋼琴酒吧)', 
            ASI_TH_CRM_Code__c = 'TW_PB',
            ASI_CRM_Sub_Channel__c = subChannel.id
        );
        insert outletType;
            
        List<Account> listAcc = new List<Account>();
        listAcc.add(new Account(
            RecordTypeid = Global_RecordTypeCache.getRtId('AccountASI_CRM_TW_Outlet'), 
            Name='Test Outlet', 
            ASI_TH_CRM_Region__c ='North',
            ASI_KOR_Customer_Code__c = 'EXID_123')
        );   
        insert listAcc;
        
        List<ASI_CRM_AccountsAdditionalField__c> listAccountAdditionalField = new List<ASI_CRM_AccountsAdditionalField__c>();
        listAccountAdditionalField.add(new ASI_CRM_AccountsAdditionalField__c(
            RecordTypeid = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_TW_Outlet'),
            Name = 'Test Outlet', 
            ASI_CRM_Account__c = listAcc[0].id, 
            ASI_TH_CRM_OutletType__c = outletType.id, 
            ASI_CRM_Region__c = 'North',
            ASI_CRM_Channel__c = channel.id,
            ASI_CRM_CN_Sub_Channel__c = subChannel.id,
            ASI_CRM_City__c = 'Test City', 
            ASI_CRM_Town__c = 'Test Town', 
            ASI_CRM_TW_Street__c = 'Test Street', 
            ASI_CRM_TW_Number__c = '1', 
            ASI_CRM_TW_Floor__c = '12')
        );
        insert listAccountAdditionalField;
        
        List<ASI_MFM_SKU_Code__c> listSKU = new List<ASI_MFM_SKU_Code__c>();
        listSKU.add(new ASI_MFM_SKU_Code__c(
            name = 'POSM SKU',
            ASI_HK_CRM_Active__c = TRUE,
            ASI_MFM_Sub_brand__c = sub.id,
            //ASI_MFM_Item_Group__c = listItemGp[0].id,
            ASI_HK_CRM_IsPOSProduct__c = TRUE,
            recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_SKU_Code__cASI_MFM_TW_SKU_Code'))
        );
        insert listSKU;
            
        
        List<ASI_FOC_Free_Goods_Request__c> listFGR = new List<ASI_FOC_Free_Goods_Request__c>();
        //POSM
        listFGR.add(new ASI_FOC_Free_Goods_Request__c(
            recordTypeId = Global_RecordTypeCache.getRTId('ASI_FOC_Free_Goods_Request__cASI_CRM_TW_POSM_Request'),
            ASI_CRM_Target_Outlet__c = listAcc[0].Id,
            ASI_CRM_Receiver__c = 'Mary',
            ASI_CRM_SG_Order_Date__c = date.today(),
            ASI_CRM_Purpose__c = 'purpose')
        );
        insert listFGR;
        
        List<ASI_FOC_Request_Item__c> listItems = new List<ASI_FOC_Request_Item__c>();
        //POSM
        listItems.add(new ASI_FOC_Request_Item__c(
            recordTypeId = Global_RecordTypeCache.getRTId('ASI_FOC_Request_Item__cASI_CRM_TW_POSM_Request_Item'),
            ASI_FOC_Request_Order__c = listFGR[0].Id,
            ASI_FOC_SKU__c = listSKU[0].id,
            ASI_FOC_Request_Quantity_Bottle__c = 10)
        );
        insert listItems;
        
        ApexPages.Standardcontroller stdController = new ApexPages.Standardcontroller(listFGR[0]);
        ApexPages.currentPage().getParameters().put('id', listFGR[0].id);  
        ASI_CRM_TW_FOCRequestPDF_Ctrl controller = new ASI_CRM_TW_FOCRequestPDF_Ctrl(stdController); 
        
        ASI_MFM_MassCreateAndUpdateController mcauCon = new ASI_MFM_MassCreateAndUpdateController();
        
        // Assign component attributes
        mcauCon.isFastModeBool = false;
        mcauCon.sObjTypeStr = 'ASI_FOC_Request_Item__c';
        mcauCon.displayFieldsStr = 'ASI_FOC_SKU__c&req=T&width=250px,ASI_FOC_Request_Quantity_Bottle__c&req=T&width=100px,ASI_CRM_Target_Outlet__c&req=F&width=100px,ASI_CRM_Delivery_To__c&req=F&width=100px,ASI_CRM_Delivery_Address__c&req=F&width=150px,ASI_CRM_Delivery_Tel__c&req=F&width=100px,ASI_CRM_Receiver__c&req=F&width=100px,ASI_FOC_Remark__c&req=F&width=100px&,recordTypeId&width=100px';        
        mcauCon.fieldToURLParamStr = 'ASI_FOC_Request_Order__c=>id';
        mcauCon.whereStatm = 'ASI_FOC_Request_Order__c = \'' + listFGR[0].Id + '\'';
        mcauCon.pageBlockTitleStr = 'POSM Line Items';
        mcauCon.successLink = '/' + listFGR[0].Id;
        mcauCon.cancelLink = '/' + listFGR[0].Id;
        mcauCon.mode = 'BOTH';
        mcauCon.isDefaultEditVal = true;
        mcauCon.ShowAllRT = true;
        mcauCon.ComponentKey = 'massCreateAndUpdate';
        mcauCon.lookupToPicklist = 'ASI_FOC_SKU__c';
        
        mcauCon.init();
    }
    
    public class HTTPMockCallout implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(200);
            string jsonResBody = '{"results":[{"address_components":[{"long_name":"Muir Lane","short_name":"Muir Ln","types":["route"]},{"long_name":"Torrey Pines","short_name":"Torrey Pines","types":["neighborhood","political"]},{"long_name":"San Diego","short_name":"San Diego","types":["locality","political"]},{"long_name":"San Diego County","short_name":"San Diego County","types":["administrative_area_level_2","political"]},{"long_name":"California","short_name":"CA","types":["administrative_area_level_1","political"]},{"long_name":"United States","short_name":"US","types":["country","political"]},{"long_name":"92161","short_name":"92161","types":["postal_code"]}],"formatted_address":"Muir Ln, San Diego, CA 92161, USA","geometry":{"location":{"lat":32.8790299,"lng":-117.2413533},"location_type":"GEOMETRIC_CENTER","viewport":{"northeast":{"lat":32.8803788802915,"lng":-117.2400043197085},"southwest":{"lat":32.8776809197085,"lng":-117.2427022802915}}},"place_id":"ChIJV1aG1sAG3IAR6EsgRezpoa0","plus_code":{"compound_code":"VQH5+JF San Diego, California, United States","global_code":"8544VQH5+JF"},"types":["establishment","point_of_interest","school"]}],"status":"OK"}';
            res.setBody(jsonResBody);
            return res;
        }
    }
}