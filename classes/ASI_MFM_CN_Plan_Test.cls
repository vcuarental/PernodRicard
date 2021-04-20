@isTest
//(seealldata=true)
//Wilken 20170210 Add test method testCNInputPlanItemsController for ASI_MFM_MassCreateAndUpdateController for CN MFM apex code
private class ASI_MFM_CN_Plan_Test {
    
    private static User getSystemAdminUser(){      
        list<User> usersAdmin = [SELECT Id, Name, Managerid, ASI_MFM_Bypass_Callouts__c, ASI_MFM_Country__c, UserRole.DeveloperName 
                            FROM User 
                            WHERE Profile.Name = 'ASI System Administrator' AND IsActive = TRUE order by id asc
                            LIMIT 1];      
        return usersAdmin.size()>0 ? usersAdmin[0] : null;
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
	
    static testMethod void testCNInputPlanItemsController() {
        Map<string, id> ppc_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_PP_Category__c');
		ASI_MFM_PP_Category__c ppc = new ASI_MFM_PP_Category__c(recordtypeid=ppc_map.get('ASI_MFM_CN_PP_Category'), Name='Content (D)', ASI_MFM_External_ID__c='Content (D) (CN)1');
        insert ppc;
        
        ASI_MFM_Prefix__c px= new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', Plan_Type__c='test', ASI_MFM_Fiscal_year__c = getFiscalYear());
		insert px;
        
        user u = [select userRole.developerName from user where id = :userInfo.getUserId()];  

        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
		insert pr;
        
		ASI_MFM_Plan__c plan = new ASI_MFM_Plan__c(Name='CNM131',ASI_MFM_Prefix__c=px.Id, recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_CN_Plan'),
            ASI_MFM_End_Date__c = Date.today().addMonths(1), ASI_MFM_Plan_Description__c='testDescription', 
				ASI_MFM_Plan_Name__c='plannameTest', ASI_MFM_Start_Date__c=Date.today(), ASI_MFM_Budget_Owner__c=userInfo.getUserId(),ASI_MFM_Status__c='Final');
		insert plan;
		
		ASI_MFM_Sub_brand__c subBrand = new ASI_MFM_Sub_brand__c(Name='subBrand1',recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_MFM_CN_Sub_Brand'));
		insert subBrand;
            
            
		ASI_MFM_A_C_Code__c ac = new ASI_MFM_A_C_Code__c(name='testAC', recordtypeid=Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_CN_A_C_Code'));
		insert ac;
            
		Account acc2 = new Account(recordTypeId=Global_RecordTypeCache.getRtId('AccountASI_MFM_CN_Outlet'),Name='Name3');           
		insert acc2;
            
		ASI_MFM_Plan_Line_Item__c planLineItem1 = new ASI_MFM_Plan_Line_Item__c(ASI_MFM_Plan__c = plan.id,ASI_MFM_Sub_brand_Code__c = subBrand.id, ASI_MFM_List_Item_Description__c='hello1',
			recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Plan_Line_Item__cASI_MFM_CN_Plan_Line_Item'),ASI_MFM_Month_1_Cost__c = 10000, ASI_MFM_Total_Cost__c =120000,ASI_MFM_Month_2_Cost__c = 10000,
		ASI_MFM_Month_3_Cost__c = 10000,ASI_MFM_Month_4_Cost__c = 10000,ASI_MFM_Month_5_Cost__c = 10000,ASI_MFM_Month_6_Cost__c = 10000,ASI_MFM_Month_7_Cost__c = 10000,
		ASI_MFM_Month_8_Cost__c = 10000,ASI_MFM_Month_9_Cost__c = 10000,ASI_MFM_Month_10_Cost__c = 10000,ASI_MFM_Month_11_Cost__c = 10000,ASI_MFM_Month_12_Cost__c = 10000,
		ASI_MFM_A_C_Code__c=ac.id
		);
		//insert planLineItem1;    			//INSUFFICIENT_ACCESS_ON_CROSS_REFERENCE_ENTITY   
			
		
        test.setCurrentPage(page.ASI_MFM_CN_ReadPlanItemsPage);
        apexpages.currentPage().getParameters().put('id', plan.id); 
        list<ASI_MFM_Plan__c> p_list = new list<ASI_MFM_Plan__c>();
        apexpages.standardSetController sc = new apexpages.standardSetController(p_list);  
        ASI_MFM_InputPlanItemsController cx = new ASI_MFM_InputPlanItemsController(sc); 
        ASI_MFM_MassCreateAndUpdateController mcauCon = new ASI_MFM_MassCreateAndUpdateController();
        
        // Assign component attributes
        mcauCon.isFastModeBool = false;
        mcauCon.sObjTypeStr = 'ASI_MFM_Plan_Line_Item__c';
        mcauCon.displayFieldsStr = 'ASI_MFM_Sub_brand_Code__c&req=T&width=240px&read=A, ASI_MFM_Total_Cost__c&req=F&width=105px&read=A, ASI_MFM_Month_1_Cost__c&req=F&width=80px&skipClone=T&read=A, ASI_MFM_Month_2_Cost__c&req=F&width=80px&skipClone=T&read=A, ASI_MFM_Month_3_Cost__c&req=F&width=80px&skipClone=T&read=A, ASI_MFM_Month_4_Cost__c&req=F&width=80px&skipClone=T&read=A, ASI_MFM_Month_5_Cost__c&req=F&width=80px&skipClone=T&read=A, ASI_MFM_Month_6_Cost__c&req=F&width=80px&skipClone=T&read=A, ASI_MFM_Month_7_Cost__c&req=F&width=80px&skipClone=T&read=A, ASI_MFM_Month_8_Cost__c&req=F&width=80px&skipClone=T&read=A, ASI_MFM_Month_9_Cost__c&req=F&width=80px&skipClone=T&read=A, ASI_MFM_Month_10_Cost__c&req=F&width=80px&skipClone=T&read=A, ASI_MFM_Month_11_Cost__c&req=F&width=80px&skipClone=T&read=A, ASI_MFM_Month_12_Cost__c&req=F&width=80px&skipClone=T&read=A"';        mcauCon.fieldToURLParamStr = 'ASI_MFM_Plan__c=>id';
        mcauCon.whereStatm = 'ASI_MFM_Plan__c = \'' + plan.Id + '\'';
        mcauCon.pageBlockTitleStr = 'Plan Line Items';
        mcauCon.successLink = '/' + plan.Id;
        mcauCon.cancelLink = '/' + plan.Id;
        mcauCon.mode = 'BOTH';
        mcauCon.isDefaultEditVal = true;
        mcauCon.ShowAllRT = true;
        mcauCon.ComponentKey = 'massCreateAndUpdate';
        mcauCon.lookupToPicklist = 'ASI_MFM_Sub_brand_Code__c,ASI_MFM_A_C_Code__c';

		mcauCon.init();
		mcauCon.commitAll();
    }
	
    static testMethod void ASI_MFM_CN_Plan_PDF_PageController_TEST() {
        
        User user1 = getSystemAdminUser(); 		//ASI_MFM_Function.getSystemAdminUser();		//20190411-ASI_MFM_Function not deployed
        user1.ASI_MFM_Bypass_Callouts__c = true;
        user1.ASI_MFM_Team__c = 'NTMK';
        System.debug(user1.ASI_MFM_Country__c);
        system.debug(user1.userRole.developerName);
        user1.ASI_MFM_Country__c ='CN';
        update user1;
        
        UserRole ur = [Select id from userrole where developername='ASI_FOC_NTMK_Merchandizing_On_Applier'];
        Profile p = [select id from profile where name='ASI CN Standard User'];
         User u = new User(alias = 'standt', email='admin_introv@testorg.com',
            emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
            localesidkey='en_US', profileid = p.Id,ASI_MFM_Country__c ='CN',
            ASI_MFM_Bypass_Callouts__c = true, ASI_MFM_Team__c = 'NTMK', UserRoleid=ur.id,
            timezonesidkey='America/Los_Angeles', username='admin_introv@testorg.com');
           // insert u;
            
        //user qiulei = [SELECT id from user where id = '005D000000251hg'];
        
        Test.startTest();
        
        System.runAs(user1){
            
        Map<string, id> plan_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Plan__c');
        Map<string, id> payment_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Payment__c');
        Map<string, id> po_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_PO__c');
        Map<string, id> polineItem_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_PO_Line_Item__c');
        Map<string, id> planlineItem_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Plan_Line_Item__c');   
        Map<string, id> acCode_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_A_C_Code__c');
        Map<string, id> subBrandCode_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Sub_brand__c');     
        Map<string, id> ppc_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_PP_Category__c');
        Map<string, id> ppcac_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_PP_Category_A_C__c');
        Map<string, id> mms_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Market_Strategy__c');
             
             ASI_MFM_Prefix__c prefix1 = new ASI_MFM_Prefix__c(Name='CN',ASI_MFM_Module__c='Plan',Plan_Type__c='Allowance & Discount Spending Form'
            ,ASI_MFM_Fiscal_year__c='FY1314',ownerId = user1.id);
            insert prefix1 ;
             
            //ASI_MFM_Prefix__c prefixTemp = new ASI_MFM_Prefix__c(Name='CN',ASI_MFM_Module__c='Plan',Plan_Type__c='Allowance & Discount Spending Form'
            //,ASI_MFM_Fiscal_year__c='FY1314',ownerId = user1.id);
            //insert prefixTemp;
            //
            //           
            //ASI_MFM_Prefix__c prefix1 = [select id,Name,Plan_Type__c,ASI_MFM_country_name__c from ASI_MFM_Prefix__c where id =: prefixTemp.id];
            //System.debug('lab id ' + prefix1.id);
            //System.debug('lab name ' + prefix1.Name);
            //System.debug('lab PlanType ' + prefix1.Plan_Type__c);
            //System.debug('lab ASI_MFM_country_name__c ' + prefix1.ASI_MFM_country_name__c);
            
            ASI_MFM_Role_Prefix_Relationship__c prefixChild1 = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c = prefix1.Id,
            ASI_MFM_Role_Name__c =u.userRole.developerName);            
            insert prefixChild1;
            ASI_MFM_Role_Prefix_Relationship__c prefixChild2 = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c = prefix1.Id,
            ASI_MFM_Role_Name__c =user1.userRole.developerName);            
            insert prefixChild2;
                                    
            ASI_MFM_A_C_Code__c ac1 = new ASI_MFM_A_C_Code__c(recordtypeid=acCode_map.get('ASI_MFM_CN_A_C_Code'), name='testAC1', ASI_MFM_A_C_Code__c = '5600.000');
            insert ac1;
            ASI_MFM_A_C_Code__c ac2 = new ASI_MFM_A_C_Code__c(recordtypeid=acCode_map.get('ASI_MFM_CN_A_C_Code'), name='testAC2', ASI_MFM_A_C_Code__c = '5600.300');
            insert ac2;
            
            ASI_MFM_PP_Category__c ppc = new ASI_MFM_PP_Category__c(recordtypeid=ppc_map.get('ASI_MFM_CN_PP_Category'), Name='NTMCD - KTV Promotion', ASI_MFM_External_ID__c='NTMCD - KTV Promotion (CN)1');
            insert ppc;
            
            ASI_MFM_PP_Category_A_C__c ppcac1 = new ASI_MFM_PP_Category_A_C__c(ASI_MFM_External_ID__c='test', recordtypeid=ppcac_map.get('ASI_MFM_CN_PP_Category_A_C'), ASI_MFM_A_C_Code__c=ac1.id, ASI_MFM_PP_Category__c=ppc.id);
            insert ppcac1; 
            ASI_MFM_PP_Category_A_C__c ppcac2 = new ASI_MFM_PP_Category_A_C__c(ASI_MFM_External_ID__c='test2', recordtypeid=ppcac_map.get('ASI_MFM_CN_PP_Category_A_C'), ASI_MFM_A_C_Code__c=ac2.id,ASI_MFM_PP_Category__c=ppc.id);
            insert ppcac2; 
            
            ASI_MFM_Market_Strategy__c mms = new ASI_MFM_Market_Strategy__c(name='12004 Chivas', ASI_MFM_External_ID__c='120041',ASI_MFM_Fiscal_Year__c='FY1213', ASI_MFM_Sub_brand__c='CH2,CH3,CHF,CHU');
            insert mms;

            ASI_MFM_Plan__c Plan1 = new ASI_MFM_Plan__c(Name='CNM131',ASI_MFM_Prefix__c=prefix1.Id
            ,recordTypeId=plan_map.get('ASI_MFM_CN_Plan'),
            ASI_MFM_End_Date__c = Date.today().addMonths(1), ASI_MFM_Plan_Description__c='testDescription', 
            ASI_MFM_Plan_Name__c='plannameTest', ASI_MFM_Start_Date__c=Date.today(), ASI_MFM_Budget_Owner__c=user1.id, 
            ASI_MFM_PP_Category__c = ppc.id, ASI_MFM_Market_Strategy__c=mms.id, ASI_MFM_Status__c='Final', OwnerId =user1.id);
            insert Plan1;
            
            ASI_MFM_Sub_brand__c subBrand1 = new ASI_MFM_Sub_brand__c(Name='subBrand1'
            ,recordTypeId=subBrandCode_map.get('ASI_MFM_CN_Sub_Brand'));
            insert subBrand1;
            
            ASI_MFM_Sub_brand__c subBrand2 = new ASI_MFM_Sub_brand__c(Name='subBrand2'
            ,recordTypeId=subBrandCode_map.get('ASI_MFM_CN_Sub_Brand'));
            insert subBrand2;
            
            map<string, id> rt_map = ASI_MFM_Function.getRecordTypeId('Account');
            ASI_MFM_A_C_Code__c ac = new ASI_MFM_A_C_Code__c(name='testAC', recordtypeid=acCode_map.get('ASI_MFM_CN_A_C_Code'));
            insert ac;
            
            Account acc2 = new Account(recordTypeId=rt_map.get('ASI_MFM_CN_Outlet'),Name='Name3');           
            insert acc2;
            
            ASI_MFM_Plan_Line_Item__c planLineItem1 = new ASI_MFM_Plan_Line_Item__c(ASI_MFM_Plan__c = Plan1.id
            ,ASI_MFM_Sub_brand_Code__c = subBrand1.id,ASI_MFM_List_Item_Description__c='hello1'
            ,recordTypeId=planLineItem_map.get('ASI_MFM_CN_Plan_Line_Item'),ASI_MFM_Month_1_Cost__c = 10000, ASI_MFM_Total_Cost__c =120000,ASI_MFM_Month_2_Cost__c = 10000,
            ASI_MFM_Month_3_Cost__c = 10000,ASI_MFM_Month_4_Cost__c = 10000,ASI_MFM_Month_5_Cost__c = 10000,ASI_MFM_Month_6_Cost__c = 10000,ASI_MFM_Month_7_Cost__c = 10000,
            ASI_MFM_Month_8_Cost__c = 10000,ASI_MFM_Month_9_Cost__c = 10000,ASI_MFM_Month_10_Cost__c = 10000,ASI_MFM_Month_11_Cost__c = 10000,ASI_MFM_Month_12_Cost__c = 10000,
            ASI_MFM_A_C_Code__c=ac.id
            );
            //insert planLineItem1;       	//INSUFFICIENT_ACCESS_ON_CROSS_REFERENCE_ENTITY

            ASI_MFM_Plan_Line_Item__c planLineItem2 = new ASI_MFM_Plan_Line_Item__c(ASI_MFM_Plan__c = Plan1.id
            ,ASI_MFM_Sub_brand_Code__c = subBrand1.id,ASI_MFM_List_Item_Description__c='hello2'
            ,recordTypeId=planLineItem_map.get('ASI_MFM_CN_Plan_Line_Item'), ASI_MFM_Total_Cost__c =1500000,
            ASI_MFM_A_C_Code__c=ac.id
            );
            //insert planLineItem2; 		//INSUFFICIENT_ACCESS_ON_CROSS_REFERENCE_ENTITY
            
             ASI_MFM_Plan_Line_Item__c planLineItem3 = new ASI_MFM_Plan_Line_Item__c(ASI_MFM_Plan__c = Plan1.id
            ,ASI_MFM_Sub_brand_Code__c = subBrand1.id,ASI_MFM_List_Item_Description__c='hello2'
            ,recordTypeId=planLineItem_map.get('ASI_MFM_CN_Plan_Line_Item'),ASI_MFM_Month_1_Cost__c = 10000,ASI_MFM_Month_2_Cost__c = 10000,
            ASI_MFM_Month_3_Cost__c = 10000,ASI_MFM_Month_4_Cost__c = 10000,ASI_MFM_Month_5_Cost__c = 10000,ASI_MFM_Month_6_Cost__c = 10000,ASI_MFM_Month_7_Cost__c = 10000,
            ASI_MFM_Month_8_Cost__c = 10000,ASI_MFM_Month_9_Cost__c = 10000,ASI_MFM_Month_10_Cost__c = 10000,ASI_MFM_Month_11_Cost__c = 10000,ASI_MFM_Month_12_Cost__c = 10000,
            ASI_MFM_A_C_Code__c=ac.id
            );
            //insert planLineItem3; 		//INSUFFICIENT_ACCESS_ON_CROSS_REFERENCE_ENTITY
            
            
            ApexPages.Standardcontroller stdController = new ApexPages.Standardcontroller(Plan1);
            ASI_MFM_CN_Plan_PDF_PageController controller = new ASI_MFM_CN_Plan_PDF_PageController(stdController);
            
        }   
        Test.stopTest();
    }
    
    static testMethod void ASI_MFM_SelectPlanPrefixController_TEST() {
        
        User user1 = getSystemAdminUser();	//ASI_MFM_Function.getSystemAdminUser();		//20190411-ASI_MFM_Function not deployed
        user1.ASI_MFM_Bypass_Callouts__c = true;
        user1.ASI_MFM_Team__c = 'NTMK';
        System.debug(user1.ASI_MFM_Country__c);
        system.debug(user1.userRole.developerName);
        user1.ASI_MFM_Country__c ='CN';
        update user1;
                
        UserRole ur = [Select id from userrole where developername='ASI_FOC_NTMK_Merchandizing_On_Applier'];
        Profile p = [select id from profile where name='ASI CN Standard User'];
         User u = new User(alias = 'standt', email='admin_introv@testorg.com',
            emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
            localesidkey='en_US', profileid = p.Id,ASI_MFM_Country__c ='CN',
            ASI_MFM_Bypass_Callouts__c = true, ASI_MFM_Team__c = 'NTMK', UserRoleid=ur.id,
            timezonesidkey='America/Los_Angeles', username='admin_introv@testorg.com');
           // insert u;
            
        //user qiulei = [SELECT id from user where id = '005D000000251hg'];
            
        Map<string, id> plan_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Plan__c');
        Map<string, id> payment_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Payment__c');
        Map<string, id> po_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_PO__c');
        Map<string, id> polineItem_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_PO_Line_Item__c');
        Map<string, id> planlineItem_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Plan_Line_Item__c');   
        Map<string, id> acCode_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_A_C_Code__c');
        Map<string, id> subBrandCode_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Sub_brand__c');     
        Map<string, id> ppc_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_PP_Category__c');
        Map<string, id> ppcac_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_PP_Category_A_C__c');
        Map<string, id> mms_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Market_Strategy__c');
             
             ASI_MFM_Prefix__c prefix1 = new ASI_MFM_Prefix__c(Name='CN',ASI_MFM_Module__c='Plan',Plan_Type__c='Allowance & Discount Spending Form'
            ,ASI_MFM_Fiscal_year__c='FY1314',ownerId = user1.id);
            insert prefix1 ;
             
            ASI_MFM_Role_Prefix_Relationship__c prefixChild1 = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c = prefix1.Id,
            ASI_MFM_Role_Name__c =u.userRole.developerName);            
            insert prefixChild1;
            ASI_MFM_Role_Prefix_Relationship__c prefixChild2 = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c = prefix1.Id,
            ASI_MFM_Role_Name__c =user1.userRole.developerName);            
            insert prefixChild2;
                                    
            ASI_MFM_A_C_Code__c ac1 = new ASI_MFM_A_C_Code__c(recordtypeid=acCode_map.get('ASI_MFM_CN_A_C_Code'), name='testAC1', ASI_MFM_A_C_Code__c = '5600.000');
            insert ac1;
            ASI_MFM_A_C_Code__c ac2 = new ASI_MFM_A_C_Code__c(recordtypeid=acCode_map.get('ASI_MFM_CN_A_C_Code'), name='testAC2', ASI_MFM_A_C_Code__c = '5600.300');
            insert ac2;
            
            ASI_MFM_PP_Category__c ppc = new ASI_MFM_PP_Category__c(recordtypeid=ppc_map.get('ASI_MFM_CN_PP_Category'), Name='NTMCD - KTV Promotion', ASI_MFM_External_ID__c='NTMCD - KTV Promotion (CN)1');
            insert ppc;
            
            ASI_MFM_PP_Category_A_C__c ppcac1 = new ASI_MFM_PP_Category_A_C__c(ASI_MFM_External_ID__c='test', recordtypeid=ppcac_map.get('ASI_MFM_CN_PP_Category_A_C'), ASI_MFM_A_C_Code__c=ac1.id, ASI_MFM_PP_Category__c=ppc.id);
            insert ppcac1; 
            ASI_MFM_PP_Category_A_C__c ppcac2 = new ASI_MFM_PP_Category_A_C__c(ASI_MFM_External_ID__c='test2', recordtypeid=ppcac_map.get('ASI_MFM_CN_PP_Category_A_C'), ASI_MFM_A_C_Code__c=ac2.id,ASI_MFM_PP_Category__c=ppc.id);
            insert ppcac2; 
            
            ASI_MFM_Market_Strategy__c mms = new ASI_MFM_Market_Strategy__c(name='12004 Chivas', ASI_MFM_External_ID__c='120041',ASI_MFM_Fiscal_Year__c='FY1213', ASI_MFM_Sub_brand__c='CH2,CH3,CHF,CHU');
            insert mms;

            ASI_MFM_Plan__c Plan1 = new ASI_MFM_Plan__c(Name='CNM131',ASI_MFM_Prefix__c=prefix1.Id
            ,recordTypeId=plan_map.get('ASI_MFM_CN_Plan'),
            ASI_MFM_End_Date__c = Date.today().addMonths(1), ASI_MFM_Plan_Description__c='testDescription', 
            ASI_MFM_Plan_Name__c='plannameTest', ASI_MFM_Start_Date__c=Date.today(), ASI_MFM_Budget_Owner__c=user1.id, 
            ASI_MFM_PP_Category__c = ppc.id, ASI_MFM_Market_Strategy__c=mms.id, ASI_MFM_Status__c='Final', OwnerId =user1.id);
            insert Plan1;
            
            ASI_MFM_Sub_brand__c subBrand1 = new ASI_MFM_Sub_brand__c(Name='subBrand1'
            ,recordTypeId=subBrandCode_map.get('ASI_MFM_CN_Sub_Brand'));
            insert subBrand1;
            
            ASI_MFM_Sub_brand__c subBrand2 = new ASI_MFM_Sub_brand__c(Name='subBrand2'
            ,recordTypeId=subBrandCode_map.get('ASI_MFM_CN_Sub_Brand'));
            insert subBrand2;
            
            map<string, id> rt_map = ASI_MFM_Function.getRecordTypeId('Account');
            ASI_MFM_A_C_Code__c ac = new ASI_MFM_A_C_Code__c(name='testAC', recordtypeid=acCode_map.get('ASI_MFM_CN_A_C_Code'));
            insert ac;
            
            Account acc2 = new Account(recordTypeId=rt_map.get('ASI_MFM_CN_Outlet'),Name='Name3');           
            insert acc2;
            
            ASI_MFM_Plan_Line_Item__c planLineItem1 = new ASI_MFM_Plan_Line_Item__c(ASI_MFM_Plan__c = Plan1.id
            ,ASI_MFM_Sub_brand_Code__c = subBrand1.id,ASI_MFM_List_Item_Description__c='hello1'
            ,recordTypeId=planLineItem_map.get('ASI_MFM_CN_Plan_Line_Item'),ASI_MFM_Month_1_Cost__c = 10000, ASI_MFM_Total_Cost__c =120000,ASI_MFM_Month_2_Cost__c = 10000,
            ASI_MFM_Month_3_Cost__c = 10000,ASI_MFM_Month_4_Cost__c = 10000,ASI_MFM_Month_5_Cost__c = 10000,ASI_MFM_Month_6_Cost__c = 10000,ASI_MFM_Month_7_Cost__c = 10000,
            ASI_MFM_Month_8_Cost__c = 10000,ASI_MFM_Month_9_Cost__c = 10000,ASI_MFM_Month_10_Cost__c = 10000,ASI_MFM_Month_11_Cost__c = 10000,ASI_MFM_Month_12_Cost__c = 10000,
            ASI_MFM_A_C_Code__c=ac.id
            );
            //insert planLineItem1;       	//INSUFFICIENT_ACCESS_ON_CROSS_REFERENCE_ENTITY

            ASI_MFM_Plan_Line_Item__c planLineItem2 = new ASI_MFM_Plan_Line_Item__c(ASI_MFM_Plan__c = Plan1.id
            ,ASI_MFM_Sub_brand_Code__c = subBrand1.id,ASI_MFM_List_Item_Description__c='hello2'
            ,recordTypeId=planLineItem_map.get('ASI_MFM_CN_Plan_Line_Item'), ASI_MFM_Total_Cost__c =1500000,
            ASI_MFM_A_C_Code__c=ac.id
            );
            //insert planLineItem2; 		//INSUFFICIENT_ACCESS_ON_CROSS_REFERENCE_ENTITY
            
             ASI_MFM_Plan_Line_Item__c planLineItem3 = new ASI_MFM_Plan_Line_Item__c(ASI_MFM_Plan__c = Plan1.id
            ,ASI_MFM_Sub_brand_Code__c = subBrand1.id,ASI_MFM_List_Item_Description__c='hello2'
            ,recordTypeId=planLineItem_map.get('ASI_MFM_CN_Plan_Line_Item'),ASI_MFM_Month_1_Cost__c = 10000,ASI_MFM_Month_2_Cost__c = 10000,
            ASI_MFM_Month_3_Cost__c = 10000,ASI_MFM_Month_4_Cost__c = 10000,ASI_MFM_Month_5_Cost__c = 10000,ASI_MFM_Month_6_Cost__c = 10000,ASI_MFM_Month_7_Cost__c = 10000,
            ASI_MFM_Month_8_Cost__c = 10000,ASI_MFM_Month_9_Cost__c = 10000,ASI_MFM_Month_10_Cost__c = 10000,ASI_MFM_Month_11_Cost__c = 10000,ASI_MFM_Month_12_Cost__c = 10000,
            ASI_MFM_A_C_Code__c=ac.id
            );
            //insert planLineItem3; 		//INSUFFICIENT_ACCESS_ON_CROSS_REFERENCE_ENTITY
            
        Test.startTest();
    
        System.runAs(user1){
            ApexPages.Standardcontroller stdController = new ApexPages.Standardcontroller(Plan1);        
            ASI_MFM_SelectPlanPrefixController ASI_MFM_SelectPlanPrefixController = new ASI_MFM_SelectPlanPrefixController(stdController);
            ASI_MFM_SelectPlanPrefixController.getPrefixes();
            ASI_MFM_SelectPlanPrefixController.proceed();
        }
            
        user1.ASI_MFM_Country__c = null;
	    update user1;
        System.runAs(user1){
            ApexPages.Standardcontroller stdController = new ApexPages.Standardcontroller(Plan1);
            ASI_MFM_SelectPlanPrefixController ASI_MFM_SelectPlanPrefixController = new ASI_MFM_SelectPlanPrefixController(stdController);
            ASI_MFM_SelectPlanPrefixController.getPrefixes();
            ASI_MFM_SelectPlanPrefixController.proceed();
        }
        
        Id roleId;
        System.runAs(new User(id = UserInfo.getUserId())){
            user1.UserRoleId = null;
            update user1;
        }
        
        system.debug(user1.UserRoleId);
        
        System.runAs(user1){
            ApexPages.Standardcontroller stdController = new ApexPages.Standardcontroller(Plan1);
                
            ASI_MFM_SelectPlanPrefixController ASI_MFM_SelectPlanPrefixController = new ASI_MFM_SelectPlanPrefixController(stdController);
            ASI_MFM_SelectPlanPrefixController.getPrefixes();
            ASI_MFM_SelectPlanPrefixController.proceed();
        }
            
        Test.stopTest();
            
    }
    
    static testMethod void ASI_MFM_Plan_TriggerClass_TEST() {
        
        User user1 = getSystemAdminUser();		//ASI_MFM_Function.getSystemAdminUser();		//20190411-ASI_MFM_Function not deployed
        user1.ASI_MFM_Bypass_Callouts__c = true;
        user1.ASI_MFM_Team__c = 'NTMK';
        System.debug(user1.ASI_MFM_Country__c);
        system.debug(user1.userRole.developerName);
        user1.ASI_MFM_Country__c ='CN';
        update user1;
                
        UserRole ur = [Select id from userrole where developername='ASI_FOC_NTMK_Merchandizing_On_Applier'];
        Profile p = [select id from profile where name='ASI CN Standard User'];
         User u = new User(alias = 'standt', email='admin_introv@testorg.com',
            emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
            localesidkey='en_US', profileid = p.Id,ASI_MFM_Country__c ='CN',
            ASI_MFM_Bypass_Callouts__c = true, ASI_MFM_Team__c = 'NTMK', UserRoleid=ur.id,
            timezonesidkey='America/Los_Angeles', username='admin_introv@testorg.com');
           // insert u;
            
        //user qiulei = [SELECT id from user where id = '005D000000251hg'];
            
        Map<string, id> plan_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Plan__c');
        Map<string, id> payment_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Payment__c');
        Map<string, id> po_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_PO__c');
        Map<string, id> polineItem_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_PO_Line_Item__c');
        Map<string, id> planlineItem_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Plan_Line_Item__c');   
        Map<string, id> acCode_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_A_C_Code__c');
        Map<string, id> subBrandCode_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Sub_brand__c');     
        Map<string, id> ppc_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_PP_Category__c');
        Map<string, id> ppcac_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_PP_Category_A_C__c');
        Map<string, id> mms_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Market_Strategy__c');
             
             ASI_MFM_Prefix__c prefix1 = new ASI_MFM_Prefix__c(Name='CN',ASI_MFM_Module__c='Plan',Plan_Type__c='Allowance & Discount Spending Form'
            ,ASI_MFM_Fiscal_year__c='FY1314',ownerId = user1.id);
            insert prefix1 ;
             
            ASI_MFM_Role_Prefix_Relationship__c prefixChild1 = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c = prefix1.Id,
            ASI_MFM_Role_Name__c =u.userRole.developerName);            
            insert prefixChild1;
            ASI_MFM_Role_Prefix_Relationship__c prefixChild2 = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c = prefix1.Id,
            ASI_MFM_Role_Name__c =user1.userRole.developerName);            
            insert prefixChild2;
                                    
            ASI_MFM_A_C_Code__c ac1 = new ASI_MFM_A_C_Code__c(recordtypeid=acCode_map.get('ASI_MFM_CN_A_C_Code'), name='testAC1', ASI_MFM_A_C_Code__c = '5600.000');
            insert ac1;
            ASI_MFM_A_C_Code__c ac2 = new ASI_MFM_A_C_Code__c(recordtypeid=acCode_map.get('ASI_MFM_CN_A_C_Code'), name='testAC2', ASI_MFM_A_C_Code__c = '5600.300');
            insert ac2;
            
            ASI_MFM_PP_Category__c ppc = new ASI_MFM_PP_Category__c(recordtypeid=ppc_map.get('ASI_MFM_CN_PP_Category'), Name='NTMCD - KTV Promotion', ASI_MFM_External_ID__c='NTMCD - KTV Promotion (CN)1');
            insert ppc;
            
            ASI_MFM_PP_Category_A_C__c ppcac1 = new ASI_MFM_PP_Category_A_C__c(ASI_MFM_External_ID__c='test', recordtypeid=ppcac_map.get('ASI_MFM_CN_PP_Category_A_C'), ASI_MFM_A_C_Code__c=ac1.id, ASI_MFM_PP_Category__c=ppc.id);
            insert ppcac1; 
            ASI_MFM_PP_Category_A_C__c ppcac2 = new ASI_MFM_PP_Category_A_C__c(ASI_MFM_External_ID__c='test2', recordtypeid=ppcac_map.get('ASI_MFM_CN_PP_Category_A_C'), ASI_MFM_A_C_Code__c=ac2.id,ASI_MFM_PP_Category__c=ppc.id);
            insert ppcac2; 
            
            ASI_MFM_Market_Strategy__c mms = new ASI_MFM_Market_Strategy__c(name='12004 Chivas', ASI_MFM_External_ID__c='120041',ASI_MFM_Fiscal_Year__c='FY1213', ASI_MFM_Sub_brand__c='CH2,CH3,CHF,CHU');
            insert mms;

            ASI_MFM_Plan__c Plan1 = new ASI_MFM_Plan__c(Name='CNM131',ASI_MFM_Prefix__c=prefix1.Id
            ,recordTypeId=plan_map.get('ASI_MFM_CN_Plan'),
            ASI_MFM_End_Date__c = Date.today().addMonths(1), ASI_MFM_Plan_Description__c='testDescription', 
            ASI_MFM_Plan_Name__c='plannameTest', ASI_MFM_Start_Date__c=Date.today(), ASI_MFM_Budget_Owner__c=user1.id, 
            ASI_MFM_PP_Category__c = ppc.id, ASI_MFM_Market_Strategy__c=mms.id, ASI_MFM_Status__c='Draft', OwnerId =user1.id);
            insert Plan1;
        
        	ASI_MFM_Plan__c Plan2 = new ASI_MFM_Plan__c(Name='CNM131',ASI_MFM_Prefix__c=prefix1.Id
            ,recordTypeId=plan_map.get('ASI_MFM_CN_Plan'),
            ASI_MFM_End_Date__c = Date.today().addMonths(1), ASI_MFM_Plan_Description__c='testDescription', 
            ASI_MFM_Plan_Name__c='plannameTest', ASI_MFM_Start_Date__c=Date.today(), ASI_MFM_Budget_Owner__c=user1.id, 
            ASI_MFM_PP_Category__c = ppc.id, ASI_MFM_Market_Strategy__c=mms.id, ASI_MFM_Status__c='Submitted', OwnerId =user1.id);
            insert Plan2;

            
            ASI_MFM_Sub_brand__c subBrand1 = new ASI_MFM_Sub_brand__c(Name='subBrand1'
            ,recordTypeId=subBrandCode_map.get('ASI_MFM_CN_Sub_Brand'));
            insert subBrand1;
            
            ASI_MFM_Sub_brand__c subBrand2 = new ASI_MFM_Sub_brand__c(Name='subBrand2'
            ,recordTypeId=subBrandCode_map.get('ASI_MFM_CN_Sub_Brand'));
            insert subBrand2;
            
            map<string, id> rt_map = ASI_MFM_Function.getRecordTypeId('Account');
            ASI_MFM_A_C_Code__c ac = new ASI_MFM_A_C_Code__c(name='testAC', recordtypeid=acCode_map.get('ASI_MFM_CN_A_C_Code'));
            insert ac;
            
            Account acc2 = new Account(recordTypeId=rt_map.get('ASI_MFM_CN_Outlet'),Name='Name3');           
            insert acc2;
            
        	list<ASI_MFM_Plan_Line_Item__c> planLineItems = new list<ASI_MFM_Plan_Line_Item__c>();
        
            planLineItems.add( new ASI_MFM_Plan_Line_Item__c(ASI_MFM_Plan__c = Plan1.id
            ,ASI_MFM_Sub_brand_Code__c = subBrand1.id,ASI_MFM_List_Item_Description__c='hello1'
            ,recordTypeId=planLineItem_map.get('ASI_MFM_CN_Plan_Line_Item'),ASI_MFM_Month_1_Cost__c = 10000, ASI_MFM_Total_Cost__c =120000,ASI_MFM_Month_2_Cost__c = 10000,
            ASI_MFM_Month_3_Cost__c = 10000,ASI_MFM_Month_4_Cost__c = 10000,ASI_MFM_Month_5_Cost__c = 10000,ASI_MFM_Month_6_Cost__c = 10000,ASI_MFM_Month_7_Cost__c = 10000,
            ASI_MFM_Month_8_Cost__c = 10000,ASI_MFM_Month_9_Cost__c = 10000,ASI_MFM_Month_10_Cost__c = 10000,ASI_MFM_Month_11_Cost__c = 10000,ASI_MFM_Month_12_Cost__c = 10000,
            ASI_MFM_A_C_Code__c=ac.id
            ));

            planLineItems.add( new ASI_MFM_Plan_Line_Item__c(ASI_MFM_Plan__c = Plan1.id
            ,ASI_MFM_Sub_brand_Code__c = subBrand1.id,ASI_MFM_List_Item_Description__c='hello2'
            ,recordTypeId=planLineItem_map.get('ASI_MFM_CN_Plan_Line_Item'), ASI_MFM_Total_Cost__c =1500000,
            ASI_MFM_A_C_Code__c=ac.id
            ));
            
            planLineItems.add( new ASI_MFM_Plan_Line_Item__c(ASI_MFM_Plan__c = Plan1.id
            ,ASI_MFM_Sub_brand_Code__c = subBrand1.id,ASI_MFM_List_Item_Description__c='hello2'
            ,recordTypeId=planLineItem_map.get('ASI_MFM_CN_Plan_Line_Item'),ASI_MFM_Month_1_Cost__c = 10000,ASI_MFM_Month_2_Cost__c = 10000,
            ASI_MFM_Month_3_Cost__c = 10000,ASI_MFM_Month_4_Cost__c = 10000,ASI_MFM_Month_5_Cost__c = 10000,ASI_MFM_Month_6_Cost__c = 10000,ASI_MFM_Month_7_Cost__c = 10000,
            ASI_MFM_Month_8_Cost__c = 10000,ASI_MFM_Month_9_Cost__c = 10000,ASI_MFM_Month_10_Cost__c = 10000,ASI_MFM_Month_11_Cost__c = 10000,ASI_MFM_Month_12_Cost__c = 10000,
            ASI_MFM_A_C_Code__c=ac.id
            ));
        
        planLineItems.add( new ASI_MFM_Plan_Line_Item__c(ASI_MFM_Plan__c = Plan2.id
            ,ASI_MFM_Sub_brand_Code__c = subBrand1.id,ASI_MFM_List_Item_Description__c='hello1'
            ,recordTypeId=planLineItem_map.get('ASI_MFM_CN_Plan_Line_Item'),ASI_MFM_Month_1_Cost__c = 10000, ASI_MFM_Total_Cost__c =120000,ASI_MFM_Month_2_Cost__c = 10000,
            ASI_MFM_Month_3_Cost__c = 10000,ASI_MFM_Month_4_Cost__c = 10000,ASI_MFM_Month_5_Cost__c = 10000,ASI_MFM_Month_6_Cost__c = 10000,ASI_MFM_Month_7_Cost__c = 10000,
            ASI_MFM_Month_8_Cost__c = 10000,ASI_MFM_Month_9_Cost__c = 10000,ASI_MFM_Month_10_Cost__c = 10000,ASI_MFM_Month_11_Cost__c = 10000,ASI_MFM_Month_12_Cost__c = 10000,
            ASI_MFM_A_C_Code__c=ac.id
            ));
        
        //insert planLineItems; 		//INSUFFICIENT_ACCESS_ON_CROSS_REFERENCE_ENTITY
        
      	list<ASI_MFM_Plan__c> plans = new list<ASI_MFM_Plan__c>();
        plans.add(Plan1);
        Plan1.ASI_MFM_Cloned_Plan_ID__c = Plan2.Id;
		Plan2.Id = Plan1.Id;
        map<Id, ASI_MFM_Plan__c> mapPlans = new map<Id, ASI_MFM_Plan__c>();
        mapPlans.put(Plan2.Id, Plan2);
            
        Test.startTest();
    
        System.runAs(user1){
            ASI_MFM_Plan_TriggerClass.routineAfterDelete(plans);
            ASI_MFM_Plan_TriggerClass.routineBeforeDelete(plans);
            ASI_MFM_Plan_TriggerClass.routineAfterInsert(plans);
            ASI_MFM_Plan_TriggerClass.routineAfterUpsert(plans, mapPlans);
            ASI_MFM_Plan_TriggerClass.routineBeforeInsert(plans);
            ASI_MFM_Plan_TriggerClass.routineBeforeUpdate(plans, mapPlans);
            ASI_MFM_Plan_TriggerClass.routineBeforeUpsert(plans, mapPlans);
        }

        Test.stopTest();
            
    }

}