@isTest /*(seealldata=true)*/
//Wilken 20170210 Add test method testCNInputPOItemsController for ASI_MFM_MassCreateAndUpdateController for CN MFM apex code
private class ASI_MFM_CN_PO_Test{
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
	
    //20190808:AM@Introv - copy from ASI_MFM_CN_PO_TriggerClass_TEST
    static testmethod void ASI_MFM_CN_PlanLine_TriggerClass_TEST(){
        ASI_MFM_CN_PO_SetPlan_TriggerClass.passTrigger = true;
        ASI_MFM_CN_POLine_SetPlan_TriggerClass.passTrigger = true;
        
        ASI_MFM_Market_Strategy__c ms = new ASI_MFM_Market_Strategy__c(Name='99999 Malibu', ASI_MFM_Active__c=true, ASI_MFM_Fiscal_Year__c='FY1213');        
        list<User> users = new list<User>();
       //  List<User> lstUsr = new List<User>();
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
  /*      User user2 = ASI_MFM_Function.getManagerCN();
        user2.ASI_MFM_Team__c = 'ABCD';
        System.debug(user2.ASI_MFM_Country__c);
        system.debug(user2.userRole.developerName);
        user2.ASI_MFM_Country__c ='CN';
        users.add(user2);
        
        User user1 = ASI_MFM_Function.getSystemAdminUser();
        user1.ASI_MFM_Team__c = 'ABCD';
        System.debug(user1.ASI_MFM_Country__c);
        system.debug(user1.userRole.developerName);
        user1.ASI_MFM_Country__c ='CN';
        user1.managerid = user2.id;
        users.add(user1);
        
        update users;*/
    
        System.runAs(user1){       
            String strRTID;
            
            //create fix approval route
            strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_Fix_Approval_Route__c ','ASI_MFM_CN_Fix_Approval_Route');
            ASI_MFM_Fix_Approval_Route__c fapp = new ASI_MFM_Fix_Approval_Route__c(ASI_MFM_Module__c='PO', ASI_MFM_Team__c ='ABCD', ownerid = user2.id, ASI_MFM_Finance__c = user2.id);
            insert fapp;
            
            //create dynamic approval route
            strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_Dynamic_Approval_Route__c','ASI_MFM_CN_Dynamic_Approval_Route');
            ASI_MFM_Dynamic_Approval_Route__c dapp = new ASI_MFM_Dynamic_Approval_Route__c(recordtypeid=strRTId, ASI_MFM_Type__c='PO', ASI_MFM_User__c=user2.id, ASI_MFM_Approval_Limit__c=30000, 
            ASI_MFM_End_of_1st_Route__c=true);
            insert dapp;
            
            list<ASI_MFM_Prefix__c> prefixs = new list<ASI_MFM_Prefix__c>();
            prefixs.add(new ASI_MFM_Prefix__c(Name='CN',ASI_MFM_Module__c='Plan',Plan_Type__c='Allowance & Discount Spending Form'
            ,ASI_MFM_Fiscal_year__c='FY1314',ownerId = user1.id));
            
            //create prefix po
            strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_Prefix__c','ASI_MFM_CN_Prefix');
            prefixs.add(new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO', recordTypeId=strRTID,
                                                        ASI_MFM_Fiscal_year__c='FY1314', ASI_MFM_Next_Number__c=86));
            insert prefixs;
            
            list<ASI_MFM_Role_Prefix_Relationship__c> prefixChilds = new list<ASI_MFM_Role_Prefix_Relationship__c>();
            prefixChilds.Add(new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c = prefixs[0].Id,
            ASI_MFM_Role_Name__c =user1.userRole.developerName));            
            prefixChilds.Add(new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c = prefixs[1].Id,
            ASI_MFM_Role_Name__c =user1.userRole.developerName));            
            
            insert prefixChilds;

            strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_A_C_Code__c','ASI_MFM_CN_A_C_Code');
            list<ASI_MFM_A_C_Code__c> acs = new list<ASI_MFM_A_C_Code__c>();
            acs.add(new ASI_MFM_A_C_Code__c(recordtypeid=strRTId, name='testAC1', ASI_MFM_A_C_Code__c = '5600.000'));
            acs.add(new ASI_MFM_A_C_Code__c(recordtypeid=strRTId, name='testAC2', ASI_MFM_A_C_Code__c = '5600.300'));
            acs.add(new ASI_MFM_A_C_Code__c(name='testAC', recordtypeid=strRTId ));
            insert acs;
            
            strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_PP_Category__c','ASI_MFM_CN_PP_Category');   
            ASI_MFM_PP_Category__c ppc = new ASI_MFM_PP_Category__c(recordtypeid=strRTId , Name='NTMCD - KTV Promotion', ASI_MFM_External_ID__c='NTMCD - KTV Promotion (CN)1');
            insert ppc;
            
            strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_PP_Category_A_C__c','ASI_MFM_CN_PP_Category_A_C'); 
            list<ASI_MFM_PP_Category_A_C__c> ppcacs = new list<ASI_MFM_PP_Category_A_C__c>();
            ppcacs.add(new ASI_MFM_PP_Category_A_C__c(ASI_MFM_External_ID__c='test', recordtypeid=strRTId , ASI_MFM_A_C_Code__c=acs[0].id, ASI_MFM_PP_Category__c=ppc.id));
            ppcacs.add(new ASI_MFM_PP_Category_A_C__c(ASI_MFM_External_ID__c='test2', recordtypeid=strRTId , ASI_MFM_A_C_Code__c=acs[1].id,ASI_MFM_PP_Category__c=ppc.id));
            insert ppcacs; 
            
            ASI_MFM_Market_Strategy__c mms = new ASI_MFM_Market_Strategy__c(name='12004 Chivas', ASI_MFM_External_ID__c='120041',ASI_MFM_Fiscal_Year__c='FY1213', ASI_MFM_Sub_brand__c='CH2,CH3,CHF,CHU');
            insert mms;
            
            strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_Plan__c','ASI_MFM_CN_Plan'); 
            
            List<ASI_MFM_Plan__c> planList = new List<ASI_MFM_Plan__c>();
            
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
            ASI_MFM_Brand__c brand = new ASI_MFM_Brand__c(name='brandname',Recordtypeid=strRTId);
            insert brand; 
     
            list<ASI_MFM_Sub_brand__c> subBrands = new list<ASI_MFM_Sub_brand__c>();
            //create sub brand
            strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_Sub_brand__c','ASI_MFM_CN_Sub_Brand');
            subBrands.add(new ASI_MFM_Sub_brand__c(Name='subBrand1' ,recordTypeId=strRTId));
            subBrands.add(new ASI_MFM_Sub_brand__c(Name='subBrand2' ,recordTypeId=strRTId));
            subBrands.add(new ASI_MFM_Sub_brand__c(Name='testSb',recordtypeid=strRTId,ASI_MFM_Brand__c=brand.id));
            insert subBrands;
                       
            list<Account> accs = new list<Account>();
            
            strRTId = ASI_MFM_Function.checkRecordType('Account','ASI_MFM_CN_Outlet'); 
            accs.add(new Account(recordTypeId=strRTId ,Name='Name3'));
            
             //ASI_MFM_CN_Supplier 
            strRTId = ASI_MFM_Function.checkRecordType('Account','ASI_MFM_CN_Supplier'); 
            accs.add(new Account(Name='TestAcc', recordTypeId=strRTId , ASI_MFM_Customer_Supplier_Number__c='123',
                                    ASI_MFM_Customer_Supplier_Name__c='SupplierName'));
            insert accs;
            
            strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_Plan_Line_Item__c','ASI_MFM_CN_Plan_Line_Item');
            ASI_MFM_Plan_Line_Item__c planLineItem1 = new ASI_MFM_Plan_Line_Item__c(ASI_MFM_Plan__c = Plan1.id
            ,ASI_MFM_Sub_brand_Code__c = subBrands[2].id,ASI_MFM_List_Item_Description__c='hello1'
            ,recordTypeId=strRTId , ASI_MFM_Total_Cost__c =120000,
            ASI_MFM_A_C_Code__c=acs[2].id
            );
            insert planLineItem1; 
            
            //create BU Code
            strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_BU__c','ASI_MFM_CN_BU');
            ASI_MFM_BU__c bu = new ASI_MFM_BU__c(Name='BUCode', ASI_MFM_BU_Code__c=strRTId , ASI_MFM_CN_Country__c='CN',
                                                ASI_MFM_Base_Currency__c='RMB');
            insert bu;
            
            
            
            //create exchange rate reference
            ASI_MFM_Exchange_Rate__c ex = new ASI_MFM_Exchange_Rate__c(ASI_MFM_Country__c='CN',ASI_MFM_Effective_Date__c=Date.valueof('2014-01-01'),
                                                                       ASI_MFM_Exchange_Rate__c=7.77500, ASI_MFM_Counter_Currency__c='USD', ASI_MFM_Base_Currency__c='RMB',
                                                                       ASI_MFM_Application__c='MFM' );
            insert ex;
            
            //create po
            strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_PO__c','ASI_MFM_CN_PO');
            ASI_MFM_PO__c po = new ASI_MFM_PO__c(Name='PO11111', RecordTypeId=strRTId , ASI_MFM_Prefix__c=prefixs[1].id, ASI_MFM_Remarks__c='Remarks',
                                                ASI_MFM_BU_Code__c=bu.id, ASI_MFM_Supplier_Name__c=accs[1].id, ASI_MFM_Currency__c='USD',
                                                ASI_MFM_PO_Start_Date__c=Date.valueof('2014-04-01'),ASI_MFM_PO_End_Date__c=Date.valueof('2014-04-30'),
                                                ASI_MFM_Budget_Owner__c =user1.id, ASI_MFM_Plan__c=Plan1.id );
            insert po;
            
            
            //create po line item
            strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_PO_Line_Item__c','ASI_MFM_CN_PO_Line_Item');
            ASI_MFM_PO_Line_Item__c poli = new ASI_MFM_PO_Line_Item__c(RecordTypeId=strRTId, ASI_MFM_PO__c=po.id, ASI_MFM_G_L_Date__c=date.valueof('2014-04-03'),ASI_MFM_Sub_brand_Code__c=subBrands[2].id,
                                                                       ASI_MFM_A_C_Code__c = acs[2].id, ASI_MFM_Customer_Name__c=accs[0].id, ASI_MFM_Plan_Line_Item__c=planLineItem1.id, ASI_MFM_Amount__c=100 );
  
            insert poli;
            
            Map<id,User> mapUser = new Map<id, User>();
            mapUser.put(users[0].id, users[0]);
            
            Test.startTest();
            
            List<ASI_MFM_Plan_Line_Item__c> ltPlanLine = new List<ASI_MFM_Plan_Line_Item__c>();
            ltPlanLine.add(planLineItem1);
            
            ltPlanLine[0].ASI_MFM_CN_ReCalculate__c = true;
            ltPlanLine[0].ASI_MFM_Total_Cost__c = 1;
            
            Map<Id, ASI_MFM_Plan_Line_Item__c> mapOldPlanLine = new Map<Id, ASI_MFM_Plan_Line_Item__c>([
                SELECT id,ASI_MFM_CN_ReCalculate__c,ASI_MFM_Total_Cost__c 
                FROM ASI_MFM_Plan_Line_Item__c 
                WHERE ID=:planLineItem1.id]);
            
            ASI_MFM_CN_PlanLine_TriggerClass.routineBeforeInsert(ltPlanLine);
            ASI_MFM_CN_PlanLine_TriggerClass.routineBeforeUpdate(ltPlanLine, mapOldPlanLine);
            
            Test.stopTest();
        }
    }
    
    static testMethod void testCNInputPOItemsController() {
        user u = [select userRole.developerName from user where id = :userInfo.getUserId()];  
		List<ASI_MFM_Prefix__c> pList = new List<ASI_MFM_Prefix__c>();
		ASI_MFM_Prefix__c px1;
        ASI_MFM_Prefix__c px2;
        
        ASI_MFM_CN_PO_SetPlan_TriggerClass.passTrigger = true;
        ASI_MFM_CN_POLine_SetPlan_TriggerClass.passTrigger = true;
        ASI_MFM_CN_PlanLine_TriggerClass.passTrigger = true;
        
        Profile p;
        User userA;
        Id currentUID;
        ASI_MFM_Plan__c plan;
        ASI_MFM_PO__c po;
        ASI_MFM_Role_Prefix_Relationship__c pr1;
        ASI_MFM_Role_Prefix_Relationship__c pr2;
        
        System.runAs(u) {
            px1 = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO', Plan_Type__c='test', ASI_MFM_Fiscal_year__c = getFiscalYear());
            pList.add(px1);
            px2= new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', Plan_Type__c='test', ASI_MFM_Fiscal_year__c = getFiscalYear());
            pList.add(px2);
            insert pList; 
           
            List<ASI_MFM_Role_Prefix_Relationship__c> prList = new List<ASI_MFM_Role_Prefix_Relationship__c>();
            pr1 = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px1.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
            prList.add(pr1);
            pr2 = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px2.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
            prList.add(pr2);
            insert prList;
            
            plan = new ASI_MFM_Plan__c(Name='CNM131',ASI_MFM_Prefix__c=px2.Id, recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_CN_Plan'),
                ASI_MFM_End_Date__c = Date.today().addMonths(1), ASI_MFM_Plan_Description__c='testDescription', 
                    ASI_MFM_Plan_Name__c='plannameTest', ASI_MFM_Start_Date__c=Date.today(), ASI_MFM_Budget_Owner__c=userInfo.getUserId(),ASI_MFM_Status__c='Final');
            insert plan;
                
            po = new ASI_MFM_PO__c(ASI_MFM_Plan__c = plan.Id, recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_CN_PO'), name='test', ASI_MFM_PO_End_Date__c=Date.today(), ASI_MFM_PO_Start_Date__c=Date.today(), ASI_MFM_Status__c = 'Draft', ASI_MFM_Prefix__c=px1.id);
            insert po;
            
            p = [select Id from Profile where Name='System Administrator']; 
            userA = new User(	Alias = 'test', 
                                    Email='test@test.com', 
                                    EmailEncodingKey='UTF-8', 
                                    LastName='test', 
                                    LanguageLocaleKey='en_US', 
                                    LocaleSidKey='en_US', 
                                    ProfileId = p.Id, 
                                    TimeZoneSidKey='America/Los_Angeles', 
                                    UserName='test@cnMFMTestUser.com');
    
            currentUID = UserInfo.getUserId();
        }
        System.runAs(userA) {	
			Group objPGp = [SELECT id FROM group WHERE name = 'ASI MFM CN Regional User'];
			
			GroupMember gmember = new GroupMember(UserOrGroupId=currentUID, GroupId=objPGp.Id);
			insert gmember;
        }
        
        System.runAs(u) {
				
            ASI_MFM_Sub_brand__c sb = new ASI_MFM_Sub_brand__c(recordtypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand'), ASI_MFM_Active_for_MFM__c=true, Name='Test Sub-brand');
            insert sb;
            
            ASI_MFM_Sub_brand_Allocation__c sbAllocation = new ASI_MFM_Sub_brand_Allocation__c(Name='Test', ASI_MFM_PO__c=po.id, ASI_MFM_Sub_brand_Code__c=sb.id, recordtypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand_Allocation__cASI_MFM_CN_Sub_Brand_Allocation'));
            insert sbAllocation;
            
            test.setCurrentPage(page.ASI_MFM_CN_InputPOItemsPage);
            apexpages.currentPage().getParameters().put('id', po.id); 
            list<ASI_MFM_PO__c> p_list = new list<ASI_MFM_PO__c>();
            apexpages.standardSetController sc = new apexpages.standardSetController(p_list);  
            ASI_MFM_HK_InputPOItemsController cx = new ASI_MFM_HK_InputPOItemsController(sc); 
            ASI_MFM_MassCreateAndUpdateController mcauCon = new ASI_MFM_MassCreateAndUpdateController();
            
            // Assign component attributes
            mcauCon.isFastModeBool = false;
            mcauCon.sObjTypeStr = 'ASI_MFM_PO_Line_Item__c';
            mcauCon.displayFieldsStr = 'ASI_MFM_Sub_brand_Code__c&req=T, ASI_MFM_A_C_Code__c&req=T, ASI_MFM_List_Item_Description__c&req=F&width=120px, ASI_MFM_Amount__c&req=T&width=80px';
            mcauCon.fieldToURLParamStr = 'ASI_MFM_PO__c=>id';
            mcauCon.whereStatm = 'ASI_MFM_PO__c = \'' + po.Id + '\'';
            mcauCon.pageBlockTitleStr = 'PO Line Items';
            mcauCon.successLink = '/' + po.Id;
            mcauCon.cancelLink = '/' + po.Id;
            mcauCon.mode = 'BOTH';
            mcauCon.isDefaultEditVal = true;
            mcauCon.ShowAllRT = true;
            mcauCon.ComponentKey = 'massCreateAndUpdate';
            mcauCon.lookupToPicklist = 'ASI_MFM_Sub_brand_Code__c,ASI_MFM_A_C_Code__c';
            //Boolean initPageBool = mcauCon.dummyVar;
    
            mcauCon.init();
            
            List<ASI_MFM_Sub_brand_Allocation__c> tmp = new List<ASI_MFM_Sub_brand_Allocation__c>();
            tmp.add(sbAllocation);
            
            mcauCon.delItemList = tmp;
            
            mcauCon.commitAll();
            mcauCon.sba_addRow();
            
            mcauCon.results[0].rowindex = 0;
            mcauCon.rowSelected_index = 0;
            
            mcauCon.sba_cloneRow();
            mcauCon.sba_deleteRow();
            ASI_MFM_MassCreateAndUpdateController.interimData interim = new ASI_MFM_MassCreateAndUpdateController.interimData();
        
            ASI_MFM_MassCreateAndUpdateController.PageBlockActionBtn a = new ASI_MFM_MassCreateAndUpdateController.PageBlockActionBtn(po.Id,'Test');
            ASI_MFM_MassCreateAndUpdateController.DisplayField d = new ASI_MFM_MassCreateAndUpdateController.DisplayField('label','name');		
            
            ASI_MFM_MassCreateAndUpdateController.interimData tempInClass = new ASI_MFM_MassCreateAndUpdateController.interimData();
            tempInClass.Id = null;
            String abbc = tempInClass.Id;
            tempInClass.Id = 'abc';
            abbc = tempInClass.Id;
            d.colKey = 'abbd';
            
            string ccc = mcauCon.MODE_NEW;
            mcauCon.theRecordTypeElementList[0].myRecordList = null;
            mcauCon.theRecordTypeElementList[0].myDisplayRecordList = null;
            
            mcauCon.results = null;
            mcauCon.sba_addRow();
            
            String bbb = ASI_MFM_MassCreateAndUpdateController.ACTION_EDIT;
            bbb = ASI_MFM_MassCreateAndUpdateController.ACTION_CLONE;
            bbb = ASI_MFM_MassCreateAndUpdateController.ACTION_ADD_NEW;
            bbb = ASI_MFM_MassCreateAndUpdateController.ACTION_REMOVE_NEW;
            bbb = ASI_MFM_MassCreateAndUpdateController.RTNAME_MASTER;
            bbb = ASI_MFM_MassCreateAndUpdateController.RTDEVNAME_MASTER;
        }
    }
	
    static testmethod void ASI_MFM_SelectPOPrefixController_TEST(){
        ASI_MFM_Market_Strategy__c ms = new ASI_MFM_Market_Strategy__c(Name='99999 Malibu', ASI_MFM_Active__c=true, ASI_MFM_Fiscal_Year__c='FY1213');
        List<User> lstUsr = new List<User>();
        User User1 = new User(managerid = UserInfo.getUserId(), ASI_MFM_Team__c = 'ABCD', ASI_MFM_Country__c ='CN', alias = 'test99',ASI_MFM_Bypass_Callouts__c = true, email='test99' + '@dev.com', emailencodingkey='UTF-8', firstname='test99', lastname='Testing', languagelocalekey='en_US', localesidkey='en_US', timezonesidkey='Europe/London', username='test99' + '@pernod-ricard.com',ProfileId = UserInfo.getProfileId(), UserRoleId = UserInfo.getUserRoleId(), isActive=true);
        User User2 = new User(managerid = UserInfo.getUserId(), ASI_MFM_Team__c = 'ABCD', ASI_MFM_Country__c ='CN', alias = 'tes99',ASI_MFM_Bypass_Callouts__c = true, email='tes99' + '@dev.com', emailencodingkey='UTF-8', firstname='tes99', lastname='Testing', languagelocalekey='en_US', localesidkey='en_US', timezonesidkey='Europe/London', username='tes99' + '@pernod-ricard.com',ProfileId = UserInfo.getProfileId(), UserRoleId = UserInfo.getUserRoleId(), isActive=true);
        lstUsr.add(user2);
        lstUsr.add(user1);
        insert lstUsr;
        user1 = [SELECT Id, Name, ManagerId, ASI_MFM_Bypass_Callouts__c, ASI_MFM_Country__c, UserRole.DeveloperName 
                            FROM User
                            WHERE id =: user1.id 
                            LIMIT 1];
        user2 = [SELECT Id, Name, ManagerId, ASI_MFM_Bypass_Callouts__c, ASI_MFM_Country__c, UserRole.DeveloperName 
                            FROM User
                            WHERE id =: user2.id 
                            LIMIT 1]; 
 /*       list<User> users = new list<User>();
        
        User user2 = ASI_MFM_Function.getManagerCN();
        System.debug(user2.ASI_MFM_Country__c);
        system.debug(user2.userRole.developerName);
        user2.ASI_MFM_Country__c ='CN';
        users.add(user2);
        
        User user1 = ASI_MFM_Function.getSystemAdminUser();
        user1.ASI_MFM_Team__c = 'ABCD';
        System.debug(user1.ASI_MFM_Country__c);
        system.debug(user1.userRole.developerName);
        user1.ASI_MFM_Country__c ='CN';
        user1.managerid = user2.id;
        users.add(user1);
        
        update users;*/
        
        String strRTID;

        list<ASI_MFM_Prefix__c> prefixs = new list<ASI_MFM_Prefix__c>();
            
        system.runAs(user1) {

            prefixs.add(new ASI_MFM_Prefix__c(Name='CN',ASI_MFM_Module__c='Plan',Plan_Type__c='Allowance & Discount Spending Form'
            ,ASI_MFM_Fiscal_year__c='FY1314',ownerId = user1.id));
            
            //create prefix po
            strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_Prefix__c','ASI_MFM_CN_Prefix');
            prefixs.add(new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO', recordTypeId=strRTID,
                                              ASI_MFM_Fiscal_year__c='FY1314', ASI_MFM_Next_Number__c=86));
            system.debug('recordTypeId: ' + strRTID);
            prefixs.add(new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO', recordTypeId=strRTID,
                                                ASI_MFM_Fiscal_year__c='FY1314', ASI_MFM_Next_Number__c=86));
            
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
            
            ASI_MFM_Market_Strategy__c mms = new ASI_MFM_Market_Strategy__c(name='12004 Chivas', ASI_MFM_External_ID__c='120041',ASI_MFM_Fiscal_Year__c='FY1213', ASI_MFM_Sub_brand__c='CH2,CH3,CHF,CHU');
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
            ASI_MFM_BU__c bu = new ASI_MFM_BU__c(Name='BUCode', ASI_MFM_BU_Code__c=strRTId , ASI_MFM_CN_Country__c='CN',
                                                ASI_MFM_Base_Currency__c='RMB');
            insert bu;
            
            
            
            //create exchange rate reference
            ASI_MFM_Exchange_Rate__c ex = new ASI_MFM_Exchange_Rate__c(ASI_MFM_Country__c='CN',ASI_MFM_Effective_Date__c=Date.valueof('2014-01-01'),
                                                                       ASI_MFM_Exchange_Rate__c=7.77500, ASI_MFM_Counter_Currency__c='USD', ASI_MFM_Base_Currency__c='RMB',
                                                                       ASI_MFM_Application__c='MFM' );
            insert ex;
            
            //create po
            strRTId =ASI_MFM_Function.checkRecordType('ASI_MFM_PO__c','ASI_MFM_CN_PO');
            ASI_MFM_PO__c po = new ASI_MFM_PO__c(Name='PO11111', RecordTypeId=strRTId , ASI_MFM_Prefix__c=prefixs[1].id, ASI_MFM_Remarks__c='Remarks',
                                                ASI_MFM_BU_Code__c=bu.id, ASI_MFM_Supplier_Name__c=accs[1].id, ASI_MFM_Currency__c='USD',
                                                ASI_MFM_PO_Start_Date__c=Date.valueof('2014-04-01'),ASI_MFM_PO_End_Date__c=Date.valueof('2014-04-30'),
                                                ASI_MFM_Budget_Owner__c =user1.id, ASI_MFM_Plan__c=Plan1.id );
            //insert po;
            
            
            //create po line item
            strRTId =ASI_MFM_Function.checkRecordType('ASI_MFM_PO_Line_Item__c','ASI_MFM_CN_PO_Line_Item');
            ASI_MFM_PO_Line_Item__c poli = new ASI_MFM_PO_Line_Item__c(RecordTypeId=strRTId, ASI_MFM_PO__c=po.id, ASI_MFM_G_L_Date__c=date.valueof('2014-04-03'),ASI_MFM_Sub_brand_Code__c=subBrands[2].id,
                                                                       ASI_MFM_A_C_Code__c = acs[2].id, ASI_MFM_Customer_Name__c=accs[0].id  );
            
        Test.startTest();

        System.runAs(user1){
            // 2019-04-10 Introv update record id from TEXT to id
            ApexPages.currentPage().getParameters().put('pid',Plan1.Id);
            ApexPages.currentPage().getParameters().put('POType','TEST');
            ApexPages.currentPage().getParameters().put('BudgetOwnerId',user1.id);
            ApexPages.currentPage().getParameters().put('supplierId',accs[1].id);
            ApexPages.currentPage().getParameters().put('RecordType',ASI_MFM_Function.checkRecordType('ASI_MFM_PO__c','ASI_MFM_CN_PO'));
            ApexPages.Standardcontroller stdController = new ApexPages.Standardcontroller(po);        
            ASI_MFM_SelectPOPrefixController ASI_MFM_SelectPOPrefixController = new ASI_MFM_SelectPOPrefixController(stdController);
            ASI_MFM_SelectPOPrefixController.getPrefixes();
            ASI_MFM_SelectPOPrefixController.proceed();
        }
        
        user1.ASI_MFM_Country__c = null;
        update user1;
        System.runAs(user1){
            ApexPages.currentPage().getParameters().put('pid',Plan1.Id);
            ApexPages.currentPage().getParameters().put('POType','TEST');
            ApexPages.currentPage().getParameters().put('BudgetOwnerId',user1.id);
            ApexPages.currentPage().getParameters().put('supplierId',accs[1].id);
            ApexPages.currentPage().getParameters().put('RecordType',ASI_MFM_Function.checkRecordType('ASI_MFM_PO__c','ASI_MFM_CN_PO'));
            
            ApexPages.Standardcontroller stdController = new ApexPages.Standardcontroller(po);        
            ASI_MFM_SelectPOPrefixController ASI_MFM_SelectPOPrefixController = new ASI_MFM_SelectPOPrefixController(stdController);
            ASI_MFM_SelectPOPrefixController.getPrefixes();
            ASI_MFM_SelectPOPrefixController.proceed();
        }
        
        Id roleId;
        System.runAs(new User(id = UserInfo.getUserId())){
            user1.UserRoleId = null;
            update user1;
        }
        System.runAs(user1){
            ApexPages.currentPage().getParameters().put('pid',Plan1.Id);
            ApexPages.currentPage().getParameters().put('POType','TEST');
            ApexPages.currentPage().getParameters().put('BudgetOwnerId',user1.id);
            ApexPages.currentPage().getParameters().put('supplierId',accs[1].id);
            ApexPages.currentPage().getParameters().put('RecordType',ASI_MFM_Function.checkRecordType('ASI_MFM_PO__c','ASI_MFM_CN_PO'));
            ApexPages.Standardcontroller stdController = new ApexPages.Standardcontroller(po);        
            ASI_MFM_SelectPOPrefixController ASI_MFM_SelectPOPrefixController = new ASI_MFM_SelectPOPrefixController(stdController);
            ASI_MFM_SelectPOPrefixController.getPrefixes();
            ASI_MFM_SelectPOPrefixController.proceed();
        }
        
        
        Test.stopTest();
       } 
    }

    static testmethod void ASI_MFM_CN_PO_TriggerClass_TEST(){
        ASI_MFM_Market_Strategy__c ms = new ASI_MFM_Market_Strategy__c(Name='99999 Malibu', ASI_MFM_Active__c=true, ASI_MFM_Fiscal_Year__c='FY1213');        
        list<User> users = new list<User>();
       //  List<User> lstUsr = new List<User>();
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
  /*      User user2 = ASI_MFM_Function.getManagerCN();
        user2.ASI_MFM_Team__c = 'ABCD';
        System.debug(user2.ASI_MFM_Country__c);
        system.debug(user2.userRole.developerName);
        user2.ASI_MFM_Country__c ='CN';
        users.add(user2);
        
        User user1 = ASI_MFM_Function.getSystemAdminUser();
        user1.ASI_MFM_Team__c = 'ABCD';
        System.debug(user1.ASI_MFM_Country__c);
        system.debug(user1.userRole.developerName);
        user1.ASI_MFM_Country__c ='CN';
        user1.managerid = user2.id;
        users.add(user1);
        
        update users;*/
    
        System.runAs(user1){       
            String strRTID;
            
            //create fix approval route
            strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_Fix_Approval_Route__c ','ASI_MFM_CN_Fix_Approval_Route');
            ASI_MFM_Fix_Approval_Route__c fapp = new ASI_MFM_Fix_Approval_Route__c(ASI_MFM_Module__c='PO', ASI_MFM_Team__c ='ABCD', ownerid = user2.id, ASI_MFM_Finance__c = user2.id);
            insert fapp;
            
            //create dynamic approval route
            strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_Dynamic_Approval_Route__c','ASI_MFM_CN_Dynamic_Approval_Route');
            ASI_MFM_Dynamic_Approval_Route__c dapp = new ASI_MFM_Dynamic_Approval_Route__c(recordtypeid=strRTId, ASI_MFM_Type__c='PO', ASI_MFM_User__c=user2.id, ASI_MFM_Approval_Limit__c=30000, 
            ASI_MFM_End_of_1st_Route__c=true);
            insert dapp;
            
            list<ASI_MFM_Prefix__c> prefixs = new list<ASI_MFM_Prefix__c>();
            prefixs.add(new ASI_MFM_Prefix__c(Name='CN',ASI_MFM_Module__c='Plan',Plan_Type__c='Allowance & Discount Spending Form'
            ,ASI_MFM_Fiscal_year__c='FY1314',ownerId = user1.id));
            
            //create prefix po
            strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_Prefix__c','ASI_MFM_CN_Prefix');
            prefixs.add(new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO', recordTypeId=strRTID,
                                                        ASI_MFM_Fiscal_year__c='FY1314', ASI_MFM_Next_Number__c=86));
            insert prefixs;
            
            list<ASI_MFM_Role_Prefix_Relationship__c> prefixChilds = new list<ASI_MFM_Role_Prefix_Relationship__c>();
            prefixChilds.Add(new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c = prefixs[0].Id,
            ASI_MFM_Role_Name__c =user1.userRole.developerName));            
            prefixChilds.Add(new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c = prefixs[1].Id,
            ASI_MFM_Role_Name__c =user1.userRole.developerName));            
            
            insert prefixChilds;

            strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_A_C_Code__c','ASI_MFM_CN_A_C_Code');
            list<ASI_MFM_A_C_Code__c> acs = new list<ASI_MFM_A_C_Code__c>();
            acs.add(new ASI_MFM_A_C_Code__c(recordtypeid=strRTId, name='testAC1', ASI_MFM_A_C_Code__c = '5600.000'));
            acs.add(new ASI_MFM_A_C_Code__c(recordtypeid=strRTId, name='testAC2', ASI_MFM_A_C_Code__c = '5600.300'));
            acs.add(new ASI_MFM_A_C_Code__c(name='testAC', recordtypeid=strRTId ));
            insert acs;
            
            strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_PP_Category__c','ASI_MFM_CN_PP_Category');   
            ASI_MFM_PP_Category__c ppc = new ASI_MFM_PP_Category__c(recordtypeid=strRTId , Name='NTMCD - KTV Promotion', ASI_MFM_External_ID__c='NTMCD - KTV Promotion (CN)1');
            insert ppc;
            
            strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_PP_Category_A_C__c','ASI_MFM_CN_PP_Category_A_C'); 
            list<ASI_MFM_PP_Category_A_C__c> ppcacs = new list<ASI_MFM_PP_Category_A_C__c>();
            ppcacs.add(new ASI_MFM_PP_Category_A_C__c(ASI_MFM_External_ID__c='test', recordtypeid=strRTId , ASI_MFM_A_C_Code__c=acs[0].id, ASI_MFM_PP_Category__c=ppc.id));
            ppcacs.add(new ASI_MFM_PP_Category_A_C__c(ASI_MFM_External_ID__c='test2', recordtypeid=strRTId , ASI_MFM_A_C_Code__c=acs[1].id,ASI_MFM_PP_Category__c=ppc.id));
            insert ppcacs; 
            
            ASI_MFM_Market_Strategy__c mms = new ASI_MFM_Market_Strategy__c(name='12004 Chivas', ASI_MFM_External_ID__c='120041',ASI_MFM_Fiscal_Year__c='FY1213', ASI_MFM_Sub_brand__c='CH2,CH3,CHF,CHU');
            insert mms;
            
            strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_Plan__c','ASI_MFM_CN_Plan'); 
            
            List<ASI_MFM_Plan__c> planList = new List<ASI_MFM_Plan__c>();
            
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
            ASI_MFM_Brand__c brand = new ASI_MFM_Brand__c(name='brandname',Recordtypeid=strRTId);
            insert brand; 
     
            list<ASI_MFM_Sub_brand__c> subBrands = new list<ASI_MFM_Sub_brand__c>();
            //create sub brand
            strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_Sub_brand__c','ASI_MFM_CN_Sub_Brand');
            subBrands.add(new ASI_MFM_Sub_brand__c(Name='subBrand1' ,recordTypeId=strRTId));
            subBrands.add(new ASI_MFM_Sub_brand__c(Name='subBrand2' ,recordTypeId=strRTId));
            subBrands.add(new ASI_MFM_Sub_brand__c(Name='testSb',recordtypeid=strRTId,ASI_MFM_Brand__c=brand.id));
            insert subBrands;
                       
            list<Account> accs = new list<Account>();
            
            strRTId = ASI_MFM_Function.checkRecordType('Account','ASI_MFM_CN_Outlet'); 
            accs.add(new Account(recordTypeId=strRTId ,Name='Name3'));
            
             //ASI_MFM_CN_Supplier 
            strRTId = ASI_MFM_Function.checkRecordType('Account','ASI_MFM_CN_Supplier'); 
            accs.add(new Account(Name='TestAcc', recordTypeId=strRTId , ASI_MFM_Customer_Supplier_Number__c='123',
                                    ASI_MFM_Customer_Supplier_Name__c='SupplierName'));
            insert accs;
            
            strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_Plan_Line_Item__c','ASI_MFM_CN_Plan_Line_Item');
            ASI_MFM_Plan_Line_Item__c planLineItem1 = new ASI_MFM_Plan_Line_Item__c(ASI_MFM_Plan__c = Plan1.id
            ,ASI_MFM_Sub_brand_Code__c = subBrands[2].id,ASI_MFM_List_Item_Description__c='hello1'
            ,recordTypeId=strRTId , ASI_MFM_Total_Cost__c =120000,
            ASI_MFM_A_C_Code__c=acs[2].id
            );
            insert planLineItem1; 
            
            //create BU Code
            strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_BU__c','ASI_MFM_CN_BU');
            ASI_MFM_BU__c bu = new ASI_MFM_BU__c(Name='BUCode', ASI_MFM_BU_Code__c=strRTId , ASI_MFM_CN_Country__c='CN',
                                                ASI_MFM_Base_Currency__c='RMB');
            insert bu;
            
            
            
            //create exchange rate reference
            ASI_MFM_Exchange_Rate__c ex = new ASI_MFM_Exchange_Rate__c(ASI_MFM_Country__c='CN',ASI_MFM_Effective_Date__c=Date.valueof('2014-01-01'),
                                                                       ASI_MFM_Exchange_Rate__c=7.77500, ASI_MFM_Counter_Currency__c='USD', ASI_MFM_Base_Currency__c='RMB',
                                                                       ASI_MFM_Application__c='MFM' );
            insert ex;
            
            //create po
            strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_PO__c','ASI_MFM_CN_PO');
            ASI_MFM_PO__c po = new ASI_MFM_PO__c(Name='PO11111', RecordTypeId=strRTId , ASI_MFM_Prefix__c=prefixs[1].id, ASI_MFM_Remarks__c='Remarks',
                                                ASI_MFM_BU_Code__c=bu.id, ASI_MFM_Supplier_Name__c=accs[1].id, ASI_MFM_Currency__c='USD',
                                                ASI_MFM_PO_Start_Date__c=Date.valueof('2014-04-01'),ASI_MFM_PO_End_Date__c=Date.valueof('2014-04-30'),
                                                ASI_MFM_Budget_Owner__c =user1.id, ASI_MFM_Plan__c=Plan1.id );
            insert po;
            
            
            //create po line item
            strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_PO_Line_Item__c','ASI_MFM_CN_PO_Line_Item');
            ASI_MFM_PO_Line_Item__c poli = new ASI_MFM_PO_Line_Item__c(RecordTypeId=strRTId, ASI_MFM_PO__c=po.id, ASI_MFM_G_L_Date__c=date.valueof('2014-04-03'),ASI_MFM_Sub_brand_Code__c=subBrands[2].id,
                                                                       ASI_MFM_A_C_Code__c = acs[2].id, ASI_MFM_Customer_Name__c=accs[0].id  );
  
            Map<id,User> mapUser = new Map<id, User>();
            mapUser.put(users[0].id, users[0]);
            
            Test.startTest();
            
            list<ASI_MFM_PO__c> pos = new list<ASI_MFM_PO__c>();
            pos.add(po);
            map<Id,ASI_MFM_PO__c> mapPos = new map<Id,ASI_MFM_PO__c>();
            mapPos.put(po.Id, po);
            ASI_MFM_CN_PO_TriggerClass.routineBeforeInsert(pos);
            ASI_MFM_CN_PO_TriggerClass.routineBeforeUpdate(pos, mapPos);
            ASI_MFM_CN_PO_TriggerClass.UpdateExRate(pos, mapPos);
            
            map<Id, ASI_MFM_Dynamic_Approval_Route__c> MAppRoute = new map<Id,ASI_MFM_Dynamic_Approval_Route__c>();
            MAppRoute.put(user1.Id, new ASI_MFM_Dynamic_Approval_Route__c(ASI_MFM_User__c=user1.Id));
            MAppRoute.put(user2.Id, new ASI_MFM_Dynamic_Approval_Route__c(ASI_MFM_User__c=user2.Id));
            map<string, ASI_MFM_Fix_Approval_Route__c> MAppRouteFix = new map<string,ASI_MFM_Fix_Approval_Route__c>();
            MAppRouteFix.put('TEST',new ASI_MFM_Fix_Approval_Route__c());
            set<string> STeam = new set<string>();
            STeam.add('TEST');
            //20160808
            Map<Id, ASI_MFM_PO_Line_Item__c> mapPOLine = new Map<Id, ASI_MFM_PO_Line_Item__c>();
            mapPOLine.put(po.Id,poli);
            //20160808
            ASI_MFM_CN_PO_TriggerClass.setApprovers(po, STeam, MAppRoute, MAppRouteFix, mapUser, mapPOLine);
            ASI_MFM_CN_PO_TriggerClass.setApproverToNull(po);
            for(integer i=0; i<9; i++)
                ASI_MFM_CN_PO_TriggerClass.setApproverByCount(po, i, user1.Id);
            
            po.ASI_MFM_Plan__c = plan2.id;
            update po;
            
            delete po;
            
            Test.stopTest();
        }       
    }

    static testmethod void ASI_MFM_CN_PO_Component_Controller_TEST(){
        ASI_MFM_Market_Strategy__c ms = new ASI_MFM_Market_Strategy__c(Name='99999 Malibu', ASI_MFM_Active__c=true, ASI_MFM_Fiscal_Year__c='FY1213');
        List<User> lstUsr = new List<User>();
        User User1 = new User(managerid = UserInfo.getUserId(), ASI_MFM_Team__c = 'ABCD', ASI_MFM_Country__c ='CN', alias = 'test99',ASI_MFM_Bypass_Callouts__c = true, email='test99' + '@dev.com', emailencodingkey='UTF-8', firstname='test99', lastname='Testing', languagelocalekey='en_US', localesidkey='en_US', timezonesidkey='Europe/London', username='test99' + '@pernod-ricard.com',ProfileId = UserInfo.getProfileId(), UserRoleId = UserInfo.getUserRoleId(), isActive=true);
        User User2 = new User(managerid = UserInfo.getUserId(), ASI_MFM_Team__c = 'ABCD', ASI_MFM_Country__c ='CN', alias = 'tes99',ASI_MFM_Bypass_Callouts__c = true, email='tes99' + '@dev.com', emailencodingkey='UTF-8', firstname='tes99', lastname='Testing', languagelocalekey='en_US', localesidkey='en_US', timezonesidkey='Europe/London', username='tes99' + '@pernod-ricard.com',ProfileId = UserInfo.getProfileId(), UserRoleId = UserInfo.getUserRoleId(), isActive=true);
        lstUsr.add(user2);
        lstUsr.add(user1);
        insert lstUsr;
        user1 = [SELECT Id, Name, ManagerId, ASI_MFM_Bypass_Callouts__c, ASI_MFM_Country__c, UserRole.DeveloperName, ASI_MFM_Team__c
                            FROM User
                            WHERE id =: user1.id 
                            LIMIT 1];
        user2 = [SELECT Id, Name, ManagerId, ASI_MFM_Bypass_Callouts__c, ASI_MFM_Country__c, UserRole.DeveloperName, ASI_MFM_Team__c
                            FROM User
                            WHERE id =: user2.id 
                            LIMIT 1];
        
   /*     list<User> users = new list<User>();
        
        User user2 = ASI_MFM_Function.getManagerCN();
        user2.ASI_MFM_Team__c = 'ABCD';
        System.debug(user2.ASI_MFM_Country__c);
        system.debug(user2.userRole.developerName);
        user2.ASI_MFM_Country__c ='CN';
        users.add(user2);
        
        User user1 = ASI_MFM_Function.getSystemAdminUser();
        user1.ASI_MFM_Team__c = 'ABCD';
        System.debug(user1.ASI_MFM_Country__c);
        system.debug(user1.userRole.developerName);
        user1.ASI_MFM_Country__c ='CN';
        user1.managerid = user2.id;
        users.add(user1);
        
        update users;*/
    
        System.runAs(user1){
        
            ASI_MFM_Fix_Approval_Route__c fixRoute = new ASI_MFM_Fix_Approval_Route__c(ASI_MFM_BA__c = user1.id, ASI_MFM_Corporate_Approver_1__c = user1.id, ASI_MFM_Corporate_Approver_2__c = user1.id,
                                                                                       ASI_MFM_Corporate_Approver_3__c = user1.id, ASI_MFM_Corporate_Approver_4__c = user1.id, ASI_MFM_Finance__c = user1.id, ASI_MFM_Module__c = 'PO', ASI_MFM_Team__c = 'ABCD',
                                                                                       ASI_MFM_Approval_Limit_BA__c = 0, ASI_MFM_Approval_Limit_CA1__c = 0, ASI_MFM_Approval_Limit_CA2__c = 0, ASI_MFM_Approval_Limit_CA3__c = 0,
                                                                                       ASI_MFM_Approval_Limit_CA4__c = 0, ASI_MFM_Approval_Limit_Finance__c = 0, ASI_MFM_Approval_Limit_BD__c = 0, recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Fix_Approval_Route__cASI_MFM_CN_Fix_Approval_Route')
                                                                                       , ASI_MFM_CN_PO_Type__c = 'RTMK Event'
                                                                                      );
            Insert fixRoute;
            
            String strRTID;
            
            list<ASI_MFM_Prefix__c> prefixs = new list<ASI_MFM_Prefix__c>();
            prefixs.add(new ASI_MFM_Prefix__c(Name='CN',ASI_MFM_Module__c='Plan',Plan_Type__c='Allowance & Discount Spending Form'
            ,ASI_MFM_Fiscal_year__c='FY1314',ownerId = user1.id));
            
            //create prefix po
            strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_Prefix__c','ASI_MFM_CN_Prefix');
            prefixs.add(new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO', recordTypeId=strRTID,
                                                        ASI_MFM_Fiscal_year__c='FY1314', ASI_MFM_Next_Number__c=86));
            insert prefixs;
            
            list<ASI_MFM_Role_Prefix_Relationship__c> prefixChilds = new list<ASI_MFM_Role_Prefix_Relationship__c>();
            prefixChilds.Add(new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c = prefixs[0].Id,
            ASI_MFM_Role_Name__c =user1.userRole.developerName));            
            prefixChilds.Add(new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c = prefixs[1].Id,
            ASI_MFM_Role_Name__c =user1.userRole.developerName));            
            
            insert prefixChilds;

            
            strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_A_C_Code__c','ASI_MFM_CN_A_C_Code');
            list<ASI_MFM_A_C_Code__c> acs = new list<ASI_MFM_A_C_Code__c>();
            acs.add(new ASI_MFM_A_C_Code__c(recordtypeid=strRTId, name='testAC1', ASI_MFM_A_C_Code__c = '5600.000'));
            acs.add(new ASI_MFM_A_C_Code__c(recordtypeid=strRTId, name='testAC2', ASI_MFM_A_C_Code__c = '5600.300'));
            acs.add(new ASI_MFM_A_C_Code__c(name='testAC', recordtypeid=strRTId ));
            insert acs;
            
            strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_PP_Category__c','ASI_MFM_CN_PP_Category');   
            ASI_MFM_PP_Category__c ppc = new ASI_MFM_PP_Category__c(recordtypeid=strRTId , Name='NTMCD - KTV Promotion', ASI_MFM_External_ID__c='NTMCD - KTV Promotion (CN)1');
            insert ppc;
            
            strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_PP_Category_A_C__c','ASI_MFM_CN_PP_Category_A_C'); 
            list<ASI_MFM_PP_Category_A_C__c> ppcacs = new list<ASI_MFM_PP_Category_A_C__c>();
            ppcacs.add(new ASI_MFM_PP_Category_A_C__c(ASI_MFM_External_ID__c='test', recordtypeid=strRTId , ASI_MFM_A_C_Code__c=acs[0].id, ASI_MFM_PP_Category__c=ppc.id));
            ppcacs.add(new ASI_MFM_PP_Category_A_C__c(ASI_MFM_External_ID__c='test2', recordtypeid=strRTId , ASI_MFM_A_C_Code__c=acs[1].id,ASI_MFM_PP_Category__c=ppc.id));
            insert ppcacs; 
            
            ASI_MFM_Market_Strategy__c mms = new ASI_MFM_Market_Strategy__c(name='12004 Chivas', ASI_MFM_External_ID__c='120041',ASI_MFM_Fiscal_Year__c='FY1213', ASI_MFM_Sub_brand__c='CH2,CH3,CHF,CHU');
            insert mms;
            
            strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_Plan__c','ASI_MFM_CN_Plan'); 
            ASI_MFM_Plan__c Plan1 = new ASI_MFM_Plan__c(Name='CNM131',ASI_MFM_Prefix__c=prefixs[0].Id
            ,recordTypeId=strRTId ,
            ASI_MFM_End_Date__c = Date.today().addMonths(1), ASI_MFM_Plan_Description__c='testDescription', 
            ASI_MFM_Plan_Name__c='plannameTest', ASI_MFM_Start_Date__c=Date.today(), ASI_MFM_Budget_Owner__c=user1.id, 
            ASI_MFM_PP_Category__c = ppc.id, ASI_MFM_Market_Strategy__c=mms.id, ASI_MFM_Status__c='Final', OwnerId =user1.id);
            insert Plan1;
            
            //create brand
            strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_Brand__c','ASI_MFM_CN_Brand');
            ASI_MFM_Brand__c brand = new ASI_MFM_Brand__c(name='brandname',Recordtypeid=strRTId);
            insert brand; 
     
            list<ASI_MFM_Sub_brand__c> subBrands = new list<ASI_MFM_Sub_brand__c>();
            strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_Sub_brand__c','ASI_MFM_CN_Sub_Brand');
            subBrands.add(new ASI_MFM_Sub_brand__c(Name='subBrand1' ,recordTypeId=strRTId));
            subBrands.add(new ASI_MFM_Sub_brand__c(Name='subBrand2' ,recordTypeId=strRTId));
            subBrands.add(new ASI_MFM_Sub_brand__c(Name='testSb',recordtypeid=strRTId,ASI_MFM_Brand__c=brand.id));
            insert subBrands;
            
            ASI_MFM_BU__c bu = new ASI_MFM_BU__c(
                Name='BUCode', ASI_MFM_BU_Code__c= ASI_MFM_Function.checkRecordType('ASI_MFM_BU__c','ASI_MFM_CN_BU'), ASI_MFM_CN_Country__c='CN',
                ASI_MFM_Base_Currency__c='RMB');
            insert bu;
            
            insert new ASI_MFM_Exchange_Rate__c(
                ASI_MFM_Country__c='CN',ASI_MFM_Effective_Date__c=Date.valueof('2000-01-01'),
                ASI_MFM_Exchange_Rate__c=1, ASI_MFM_Counter_Currency__c='RMB', ASI_MFM_Base_Currency__c='RMB',
                ASI_MFM_Application__c='MFM'
            );
            
            list<Account> accs = new list<Account>();
            
            strRTId = ASI_MFM_Function.checkRecordType('Account','ASI_MFM_CN_Outlet'); 
            accs.add(new Account(recordTypeId=strRTId ,Name='Name3'));
            
             //ASI_MFM_CN_Supplier 
            strRTId = ASI_MFM_Function.checkRecordType('Account','ASI_MFM_CN_Supplier'); 
            accs.add(new Account(Name='TestAcc', recordTypeId=strRTId , ASI_MFM_Customer_Supplier_Number__c='123',
                                    ASI_MFM_Customer_Supplier_Name__c='SupplierName'));
            insert accs;
            
            strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_Plan_Line_Item__c','ASI_MFM_CN_Plan_Line_Item');
            ASI_MFM_Plan_Line_Item__c planLineItem1 = new ASI_MFM_Plan_Line_Item__c(
                ASI_MFM_Plan__c = Plan1.id
                ,ASI_MFM_Sub_brand_Code__c = subBrands[2].id,ASI_MFM_List_Item_Description__c='hello1'
                ,recordTypeId=strRTId , ASI_MFM_Total_Cost__c =120000,
                ASI_MFM_A_C_Code__c=acs[2].id
            );
            insert planLineItem1; 
                        
            //create po
            strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_PO__c','ASI_MFM_CN_PO');
            
            System.debug('BUID: ' + string.valueOf(bu.id));
            
            list<ASI_MFM_PO__c> pos = new list<ASI_MFM_PO__c>();
            pos.add(new ASI_MFM_PO__c(Name='PO11111', RecordTypeId=strRTId , ASI_MFM_Prefix__c=prefixs[1].id, ASI_MFM_Remarks__c='Remarks', ASI_MFM_BU_Code__c=bu.id, ASI_MFM_Sys_Local_Currency__c='RMB', ASI_MFM_CN_BU_Picklist__c = 'BUCode',
                                                ASI_MFM_Supplier_Name__c=accs[1].id, ASI_MFM_Currency__c='RMB', ASI_MFM_Status__c='Draft', ASI_MFM_Exchange_Rate__c=1, ASI_MFM_CN_PO_Max_Approved_Amount__c=0,
                                                ASI_MFM_PO_Start_Date__c=Date.valueof('2014-04-01'),ASI_MFM_PO_End_Date__c=Date.valueof('2014-04-30'),
                                                ASI_MFM_Budget_Owner__c =user2.id, ASI_MFM_Plan__c=Plan1.id, ASI_MFM_PO_Type__c = 'RTMK Event' ));
            insert pos;
      

            
            strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_PO_Line_Item__c','ASI_MFM_CN_PO_Line_Item');
            list<ASI_MFM_PO_Line_Item__c> polis = new list<ASI_MFM_PO_Line_Item__c>();
            polis.add(new ASI_MFM_PO_Line_Item__c(RecordTypeId=strRTId, ASI_MFM_PO__c=pos[0].id, ASI_MFM_G_L_Date__c=date.valueof('2014-04-03'),ASI_MFM_Sub_brand_Code__c=subBrands[2].id,
                                                                       ASI_MFM_A_C_Code__c = acs[2].id, ASI_MFM_Customer_Name__c=accs[0].id,
                                                                      ASI_MFM_Spread_by_Months__c=true,ASI_MFM_Amount__c=100,ASI_MFM_PO_Remark__c='Remarks'));
            
            ASI_MFM_PO_Receipt_Phasing__c phasing = new ASI_MFM_PO_Receipt_Phasing__c(
            	ASI_MFM_PO__c = pos[0].id,
                ASI_MFM_Comments__c = 'asdfsdfsadfasdfasdfasdfasdf asdfsdfsadfasdfasdfasdfasdf a'
            );
            insert phasing;
            
            Test.startTest();
            insert polis;
            
            System.DEBUG('Exchange rate.....: ' + String.valueOf(pos[0].ASI_MFM_Exchange_Rate__c));
            System.DEBUG('Status.....: ' + String.valueOf(pos[0].ASI_MFM_Status__c));
            System.DEBUG('ASI_MFM_CN_Approved_Amount_PO_Amount__c.....: ' + String.valueOf(pos[0].ASI_MFM_CN_Approved_Amount_PO_Amount__c));
            System.DEBUG('ASI_MFM_Exchange_Rate__c.....: ' + String.valueOf(pos[0].ASI_MFM_Exchange_Rate__c));
            System.DEBUG('ASI_MFM_PO_Amount__c.....: ' + String.valueOf(pos[0].ASI_MFM_PO_Amount__c));
            System.DEBUG('ASI_MFM_CN_PO_Amount_RMB__c.....: ' + String.valueOf(pos[0].ASI_MFM_CN_PO_Amount_RMB__c));
            System.DEBUG('ASI_MFM_PO_Type__c.....: ' + String.valueOf(pos[0].ASI_MFM_PO_Type__c));
                        
            ASI_MFM_PO__c po = [SELECT Name, RecordTypeId, ASI_MFM_Prefix__c
                                , ASI_MFM_Sys_Approver_1__c
                                , Id, ASI_MFM_CN_PO_Amount_RMB__c
                                , ASI_MFM_PO_Type__c
                                , RecordType.DeveloperName
                                , ASI_MFM_CN_Approved_Amount_PO_Amount__c
                                , ASI_MFM_Remarks__c
                                , ASI_MFM_BU_Code__c
                                , ASI_MFM_Sys_Local_Currency__c
                                , ASI_MFM_CN_BU_Picklist__c
                                , ASI_MFM_Supplier_Name__c
                                , ASI_MFM_Currency__c
                                , ASI_MFM_Status__c
                                , ASI_MFM_Exchange_Rate__c
                                , ASI_MFM_CN_PO_Max_Approved_Amount__c
                                , ASI_MFM_PO_Start_Date__c
                                , ASI_MFM_PO_End_Date__c
                                , ASI_MFM_Budget_Owner__c
                                , ASI_MFM_Plan__c
                                FROM ASI_MFM_PO__c WHERE Id =:pos[0].Id];

            /*Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
            req1.setComments('Submitting request for approval.');
            req1.setObjectId(po.Id);
            Approval.ProcessResult appResult = Approval.process(req1);*/
            
            //20170911 Introv
            Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
            req1.setComments('Submitting request for approval.');
            req1.setObjectId(po.Id);
            //req1.setSubmitterID(user2.id);
            req1.setSkipEntryCriteria(true);
            req1.setProcessDefinitionNameOrId('ASI_MFM_CN_PO_Approval_Process_V2');
            Approval.ProcessResult appResult = Approval.process(req1);
            
            Approval.ProcessWorkitemRequest req2 = new Approval.ProcessWorkitemRequest();
            req2.setComments('Approving request.');
            req2.setAction('Approve');
            
            while(appResult.getNewWorkitemIds().size()>0){
                req2.setWorkitemId(appResult.getNewWorkitemIds().get(0));
                appResult = Approval.process(req2);
            }
            
            ProcessInstanceHistory tmp = new ProcessInstanceHistory();
            
            ASI_MFM_CN_PO_Component_Controller con = new ASI_MFM_CN_PO_Component_Controller();
            con.POID = po.Id;
            con.init();
            con.init(po, polis);
            con.getLongDate();
            con.appHistList = new List<ASI_MFM_CN_PO_Component_Controller.ASI_ApprHist_LineItem>();
            con.addToApprHistList(tmp);
            con.addToSubmitter(tmp);
            map<string, User> m =  con.getApprDetailInfo(new set<string>{user1.Id, user2.Id});
            
            ASI_MFM_CN_PO_Component_Controller.getApprDetailInfo(UserInfo.getUserId());
            
            ASI_MFM_CN_PO_Component_Controller.ASI_ApprHist_LineItem hli = new ASI_MFM_CN_PO_Component_Controller.ASI_ApprHist_LineItem();
            hli.id = hli.id;
            hli.StepStatus = hli.StepStatus;
            hli.Comments = hli.Comments;
            hli.CreatedDate = hli.CreatedDate;
            hli.CreatedDateString = hli.CreatedDateString;
            hli.oriActorId = hli.oriActorId;
            hli.oriActorName = hli.oriActorName;
            hli.oriActorTitle = hli.oriActorTitle;
            hli.oriActorDepartment = hli.oriActorDepartment;
            hli.actActorId = hli.actActorId;
            hli.actActorName = hli.actActorName;
            hli.actActorTitle = hli.actActorTitle;
            hli.actActorDepartment = hli.actActorDepartment;

            ASI_MFM_ApprovalHistoryHelper histHelper = new ASI_MFM_ApprovalHistoryHelper ('ASI_MFM_PO__c', pos[0].Id);
            
            Test.stopTest();

        }   
    }
    
    static testmethod void ASI_MFM_CN_POtoSupplier_Component_Ctr_TEST(){
    ASI_MFM_Market_Strategy__c ms = new ASI_MFM_Market_Strategy__c(Name='99999 Malibu', ASI_MFM_Active__c=true, ASI_MFM_Fiscal_Year__c='FY1213');
       List<User> lstUsr = new List<User>();
        User User1 = new User(managerid = UserInfo.getUserId(), ASI_MFM_Team__c = 'ABCD', ASI_MFM_Country__c ='CN', alias = 'test99',ASI_MFM_Bypass_Callouts__c = true, email='test99' + '@dev.com', emailencodingkey='UTF-8', firstname='test99', lastname='Testing', languagelocalekey='en_US', localesidkey='en_US', timezonesidkey='Europe/London', username='test99' + '@pernod-ricard.com',ProfileId = UserInfo.getProfileId(), UserRoleId = UserInfo.getUserRoleId(), isActive=true);
        User User2 = new User(managerid = UserInfo.getUserId(), ASI_MFM_Team__c = 'ABCD', ASI_MFM_Country__c ='CN', alias = 'tes99',ASI_MFM_Bypass_Callouts__c = true, email='tes99' + '@dev.com', emailencodingkey='UTF-8', firstname='tes99', lastname='Testing', languagelocalekey='en_US', localesidkey='en_US', timezonesidkey='Europe/London', username='tes99' + '@pernod-ricard.com',ProfileId = UserInfo.getProfileId(), UserRoleId = UserInfo.getUserRoleId(), isActive=true);
        lstUsr.add(user2);
        lstUsr.add(user1);
        insert lstUsr;
        user1 = [SELECT Id, Name, ManagerId, ASI_MFM_Bypass_Callouts__c, ASI_MFM_Country__c, UserRole.DeveloperName 
                            FROM User
                            WHERE id =: user1.id 
                            LIMIT 1];
        user2 = [SELECT Id, Name, ManagerId, ASI_MFM_Bypass_Callouts__c, ASI_MFM_Country__c, UserRole.DeveloperName 
                            FROM User
                            WHERE id =: user2.id 
                            LIMIT 1]; 
     /*   list<User> users = new list<User>();
        
        User user2 = ASI_MFM_Function.getManagerCN();
        user2.ASI_MFM_Team__c = 'ABCD';
        System.debug(user2.ASI_MFM_Country__c);
        system.debug(user2.userRole.developerName);
        user2.ASI_MFM_Country__c ='CN';
        users.add(user2);
        
        User user1 = ASI_MFM_Function.getSystemAdminUser();
        user1.ASI_MFM_Team__c = 'ABCD';
        System.debug(user1.ASI_MFM_Country__c);
        system.debug(user1.userRole.developerName);
        user1.ASI_MFM_Country__c ='CN';
        user1.managerid = user2.id;
        users.add(user1);
        
        update users;*/
    
        System.runAs(user1){
        
            String strRTID;
            
            list<ASI_MFM_Prefix__c> prefixs = new list<ASI_MFM_Prefix__c>();
            prefixs.add(new ASI_MFM_Prefix__c(Name='CN',ASI_MFM_Module__c='Plan',Plan_Type__c='Allowance & Discount Spending Form'
            ,ASI_MFM_Fiscal_year__c='FY1314',ownerId = user1.id));
            
            //create prefix po
            strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_Prefix__c','ASI_MFM_CN_Prefix');
            prefixs.add(new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO', recordTypeId=strRTID,
                                                        ASI_MFM_Fiscal_year__c='FY1314', ASI_MFM_Next_Number__c=86));
            insert prefixs;
            
            list<ASI_MFM_Role_Prefix_Relationship__c> prefixChilds = new list<ASI_MFM_Role_Prefix_Relationship__c>();
            prefixChilds.Add(new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c = prefixs[0].Id,
            ASI_MFM_Role_Name__c =user1.userRole.developerName));            
            prefixChilds.Add(new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c = prefixs[1].Id,
            ASI_MFM_Role_Name__c =user1.userRole.developerName));            
            
            insert prefixChilds;

            
            strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_A_C_Code__c','ASI_MFM_CN_A_C_Code');
            list<ASI_MFM_A_C_Code__c> acs = new list<ASI_MFM_A_C_Code__c>();
            acs.add(new ASI_MFM_A_C_Code__c(recordtypeid=strRTId, name='testAC1', ASI_MFM_A_C_Code__c = '5600.000'));
            acs.add(new ASI_MFM_A_C_Code__c(recordtypeid=strRTId, name='testAC2', ASI_MFM_A_C_Code__c = '5600.300'));
            acs.add(new ASI_MFM_A_C_Code__c(name='testAC', recordtypeid=strRTId ));
            insert acs;
            
            strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_PP_Category__c','ASI_MFM_CN_PP_Category');   
            ASI_MFM_PP_Category__c ppc = new ASI_MFM_PP_Category__c(recordtypeid=strRTId , Name='NTMCD - KTV Promotion', ASI_MFM_External_ID__c='NTMCD - KTV Promotion (CN)1');
            insert ppc;
            
            strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_PP_Category_A_C__c','ASI_MFM_CN_PP_Category_A_C'); 
            list<ASI_MFM_PP_Category_A_C__c> ppcacs = new list<ASI_MFM_PP_Category_A_C__c>();
            ppcacs.add(new ASI_MFM_PP_Category_A_C__c(ASI_MFM_External_ID__c='test', recordtypeid=strRTId , ASI_MFM_A_C_Code__c=acs[0].id, ASI_MFM_PP_Category__c=ppc.id));
            ppcacs.add(new ASI_MFM_PP_Category_A_C__c(ASI_MFM_External_ID__c='test2', recordtypeid=strRTId , ASI_MFM_A_C_Code__c=acs[1].id,ASI_MFM_PP_Category__c=ppc.id));
            insert ppcacs; 
            
            ASI_MFM_Market_Strategy__c mms = new ASI_MFM_Market_Strategy__c(name='12004 Chivas', ASI_MFM_External_ID__c='120041',ASI_MFM_Fiscal_Year__c='FY1213', ASI_MFM_Sub_brand__c='CH2,CH3,CHF,CHU');
            insert mms;
            
            strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_Plan__c','ASI_MFM_CN_Plan'); 
            ASI_MFM_Plan__c Plan1 = new ASI_MFM_Plan__c(Name='CNM131',ASI_MFM_Prefix__c=prefixs[0].Id
            ,recordTypeId=strRTId ,
            ASI_MFM_End_Date__c = Date.today().addMonths(1), ASI_MFM_Plan_Description__c='testDescription', 
            ASI_MFM_Plan_Name__c='plannameTest', ASI_MFM_Start_Date__c=Date.today(), ASI_MFM_Budget_Owner__c=user1.id, 
            ASI_MFM_PP_Category__c = ppc.id, ASI_MFM_Market_Strategy__c=mms.id, ASI_MFM_Status__c='Final', OwnerId =user1.id);
            insert Plan1;
            
            //create brand
            strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_Brand__c','ASI_MFM_CN_Brand');
            ASI_MFM_Brand__c brand = new ASI_MFM_Brand__c(name='brandname',Recordtypeid=strRTId);
            insert brand; 
     
            list<ASI_MFM_Sub_brand__c> subBrands = new list<ASI_MFM_Sub_brand__c>();
            //create sub brand
            strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_Sub_brand__c','ASI_MFM_CN_Sub_Brand');
            subBrands.add(new ASI_MFM_Sub_brand__c(Name='subBrand1' ,recordTypeId=strRTId));
            subBrands.add(new ASI_MFM_Sub_brand__c(Name='subBrand2' ,recordTypeId=strRTId));
            subBrands.add(new ASI_MFM_Sub_brand__c(Name='testSb',recordtypeid=strRTId,ASI_MFM_Brand__c=brand.id));
            insert subBrands;
                       
            list<Account> accs = new list<Account>();
            
            strRTId = ASI_MFM_Function.checkRecordType('Account','ASI_MFM_CN_Outlet'); 
            accs.add(new Account(recordTypeId=strRTId ,Name='Name3'));
            
             //ASI_MFM_CN_Supplier 
            strRTId = ASI_MFM_Function.checkRecordType('Account','ASI_MFM_CN_Supplier'); 
            accs.add(new Account(Name='TestAcc', recordTypeId=strRTId , ASI_MFM_Customer_Supplier_Number__c='123',
                                    ASI_MFM_Customer_Supplier_Name__c='SupplierName'));
            insert accs;
            
            strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_Plan_Line_Item__c','ASI_MFM_CN_Plan_Line_Item');
            ASI_MFM_Plan_Line_Item__c planLineItem1 = new ASI_MFM_Plan_Line_Item__c(ASI_MFM_Plan__c = Plan1.id
            ,ASI_MFM_Sub_brand_Code__c = subBrands[2].id,ASI_MFM_List_Item_Description__c='hello1'
            ,recordTypeId=strRTId , ASI_MFM_Total_Cost__c =120000,
            ASI_MFM_A_C_Code__c=acs[2].id
            );
            insert planLineItem1; 
                        
            //create po
            strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_PO__c','ASI_MFM_CN_PO');
            
            list<ASI_MFM_PO__c> pos = new list<ASI_MFM_PO__c>();
            pos.add(new ASI_MFM_PO__c(Name='PO11111', RecordTypeId=strRTId , ASI_MFM_Prefix__c=prefixs[1].id, ASI_MFM_Remarks__c='Remarks',
                                                ASI_MFM_Supplier_Name__c=accs[1].id, ASI_MFM_Currency__c='USD',
                                                ASI_MFM_PO_Start_Date__c=Date.valueof('2014-04-01'),ASI_MFM_PO_End_Date__c=Date.valueof('2014-04-30'),
                                                ASI_MFM_Budget_Owner__c =user1.id, ASI_MFM_Plan__c=Plan1.id ));
            
            list<ASI_MFM_PO_Line_Item__c> polis = new list<ASI_MFM_PO_Line_Item__c>();
            polis.add(new ASI_MFM_PO_Line_Item__c(RecordTypeId=strRTId, ASI_MFM_PO__c=pos[0].id, ASI_MFM_G_L_Date__c=date.valueof('2014-04-03'),ASI_MFM_Sub_brand_Code__c=subBrands[2].id,
                                                                       ASI_MFM_A_C_Code__c = acs[2].id, ASI_MFM_Customer_Name__c=accs[0].id,
                                                                      ASI_MFM_Spread_by_Months__c=true,ASI_MFM_Amount__c=1,ASI_MFM_PO_Remark__c='Remarks'));
            
            Test.startTest();

            ApexPages.currentPage().getParameters().put('RecordType','TEST');
            ApexPages.Standardcontroller stdController = new ApexPages.Standardcontroller(pos[0]);        
            ASI_MFM_CN_POtoSupplier_Component_Ctr ASI_MFM_CN_POtoSupplier_Component_Ctr = new ASI_MFM_CN_POtoSupplier_Component_Ctr(stdController);
            ASI_MFM_CN_POtoSupplier_Component_Ctr.POID = pos[0].Id;
            ASI_MFM_CN_POtoSupplier_Component_Ctr.init();
            ASI_MFM_CN_POtoSupplier_Component_Ctr.init(pos[0], polis);
            ASI_MFM_CN_POtoSupplier_Component_Ctr.getLongDate();

            Test.stopTest();

        }   
    }
    
    static testmethod void ASI_MFM_PO_TriggerClass_TEST1(){
    ASI_MFM_Market_Strategy__c ms = new ASI_MFM_Market_Strategy__c(Name='99999 Malibu', ASI_MFM_Active__c=true, ASI_MFM_Fiscal_Year__c='FY1213');
       List<User> lstUsr = new List<User>();
        User User1 = new User(managerid = UserInfo.getUserId(), ASI_MFM_Team__c = 'ABCD', ASI_MFM_Country__c ='CN', alias = 'test99',ASI_MFM_Bypass_Callouts__c = true, email='test99' + '@dev.com', emailencodingkey='UTF-8', firstname='test99', lastname='Testing', languagelocalekey='en_US', localesidkey='en_US', timezonesidkey='Europe/London', username='test99' + '@pernod-ricard.com',ProfileId = UserInfo.getProfileId(), UserRoleId = UserInfo.getUserRoleId(), isActive=true);
        User User2 = new User(managerid = UserInfo.getUserId(), ASI_MFM_Team__c = 'ABCD', ASI_MFM_Country__c ='CN', alias = 'tes99',ASI_MFM_Bypass_Callouts__c = true, email='tes99' + '@dev.com', emailencodingkey='UTF-8', firstname='tes99', lastname='Testing', languagelocalekey='en_US', localesidkey='en_US', timezonesidkey='Europe/London', username='tes99' + '@pernod-ricard.com',ProfileId = UserInfo.getProfileId(), UserRoleId = UserInfo.getUserRoleId(), isActive=true);
        lstUsr.add(user2);
        lstUsr.add(user1);
        insert lstUsr;
        user1 = [SELECT Id, Name, ManagerId, ASI_MFM_Bypass_Callouts__c, ASI_MFM_Country__c, UserRole.DeveloperName 
                            FROM User
                            WHERE id =: user1.id 
                            LIMIT 1];
        user2 = [SELECT Id, Name, ManagerId, ASI_MFM_Bypass_Callouts__c, ASI_MFM_Country__c, UserRole.DeveloperName 
                            FROM User
                            WHERE id =: user2.id 
                            LIMIT 1];  
/*        list<User> users = new list<User>();
        
        User user2 = ASI_MFM_Function.getManagerCN();
        user2.ASI_MFM_Team__c = 'ABCD';
        System.debug(user2.ASI_MFM_Country__c);
        system.debug(user2.userRole.developerName);
        user2.ASI_MFM_Country__c ='CN';
        users.add(user2);
        
        User user1 = ASI_MFM_Function.getSystemAdminUser();
        user1.ASI_MFM_Team__c = 'ABCD';
        System.debug(user1.ASI_MFM_Country__c);
        system.debug(user1.userRole.developerName);
        user1.ASI_MFM_Country__c ='CN';
        user1.managerid = user2.id;
        users.add(user1);
        
        update users;*/
    
        System.runAs(user1){
        
            String strRTID;
            
            list<ASI_MFM_Prefix__c> prefixs = new list<ASI_MFM_Prefix__c>();
            prefixs.add(new ASI_MFM_Prefix__c(Name='CN',ASI_MFM_Module__c='Plan',Plan_Type__c='Allowance & Discount Spending Form'
            ,ASI_MFM_Fiscal_year__c='FY1314',ownerId = user1.id));
            
            //create prefix po
            strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_Prefix__c','ASI_MFM_CN_Prefix');
            prefixs.add(new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO', recordTypeId=strRTID,
                                                        ASI_MFM_Fiscal_year__c='FY1314', ASI_MFM_Next_Number__c=86));
            insert prefixs;
            
            list<ASI_MFM_Role_Prefix_Relationship__c> prefixChilds = new list<ASI_MFM_Role_Prefix_Relationship__c>();
            prefixChilds.Add(new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c = prefixs[0].Id,
            ASI_MFM_Role_Name__c =user1.userRole.developerName));            
            prefixChilds.Add(new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c = prefixs[1].Id,
            ASI_MFM_Role_Name__c =user1.userRole.developerName));            
            
            insert prefixChilds;

            
            strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_A_C_Code__c','ASI_MFM_CN_A_C_Code');
            list<ASI_MFM_A_C_Code__c> acs = new list<ASI_MFM_A_C_Code__c>();
            acs.add(new ASI_MFM_A_C_Code__c(recordtypeid=strRTId, name='testAC1', ASI_MFM_A_C_Code__c = '5600.000'));
            acs.add(new ASI_MFM_A_C_Code__c(recordtypeid=strRTId, name='testAC2', ASI_MFM_A_C_Code__c = '5600.300'));
            acs.add(new ASI_MFM_A_C_Code__c(name='testAC', recordtypeid=strRTId ));
            insert acs;
            
            strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_PP_Category__c','ASI_MFM_CN_PP_Category');   
            ASI_MFM_PP_Category__c ppc = new ASI_MFM_PP_Category__c(recordtypeid=strRTId , Name='NTMCD - KTV Promotion', ASI_MFM_External_ID__c='NTMCD - KTV Promotion (CN)1');
            insert ppc;
            
            strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_PP_Category_A_C__c','ASI_MFM_CN_PP_Category_A_C'); 
            list<ASI_MFM_PP_Category_A_C__c> ppcacs = new list<ASI_MFM_PP_Category_A_C__c>();
            ppcacs.add(new ASI_MFM_PP_Category_A_C__c(ASI_MFM_External_ID__c='test', recordtypeid=strRTId , ASI_MFM_A_C_Code__c=acs[0].id, ASI_MFM_PP_Category__c=ppc.id));
            ppcacs.add(new ASI_MFM_PP_Category_A_C__c(ASI_MFM_External_ID__c='test2', recordtypeid=strRTId , ASI_MFM_A_C_Code__c=acs[1].id,ASI_MFM_PP_Category__c=ppc.id));
            insert ppcacs; 
            
            ASI_MFM_Market_Strategy__c mms = new ASI_MFM_Market_Strategy__c(name='12004 Chivas', ASI_MFM_External_ID__c='120041',ASI_MFM_Fiscal_Year__c='FY1213', ASI_MFM_Sub_brand__c='CH2,CH3,CHF,CHU');
            insert mms;
            
            strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_Plan__c','ASI_MFM_CN_Plan'); 
            ASI_MFM_Plan__c Plan1 = new ASI_MFM_Plan__c(Name='CNM131',ASI_MFM_Prefix__c=prefixs[0].Id
            ,recordTypeId=strRTId ,
            ASI_MFM_End_Date__c = Date.today().addMonths(1), ASI_MFM_Plan_Description__c='testDescription', 
            ASI_MFM_Plan_Name__c='plannameTest', ASI_MFM_Start_Date__c=Date.today(), ASI_MFM_Budget_Owner__c=user1.id, 
            ASI_MFM_PP_Category__c = ppc.id, ASI_MFM_Market_Strategy__c=mms.id, ASI_MFM_Status__c='Final', OwnerId =user1.id);
            insert Plan1;
            
            //create brand
            strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_Brand__c','ASI_MFM_CN_Brand');
            ASI_MFM_Brand__c brand = new ASI_MFM_Brand__c(name='brandname',Recordtypeid=strRTId);
            insert brand; 
     
            list<ASI_MFM_Sub_brand__c> subBrands = new list<ASI_MFM_Sub_brand__c>();
            //create sub brand
            strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_Sub_brand__c','ASI_MFM_CN_Sub_Brand');
            subBrands.add(new ASI_MFM_Sub_brand__c(Name='subBrand1' ,recordTypeId=strRTId));
            subBrands.add(new ASI_MFM_Sub_brand__c(Name='subBrand2' ,recordTypeId=strRTId));
            subBrands.add(new ASI_MFM_Sub_brand__c(Name='testSb',recordtypeid=strRTId,ASI_MFM_Brand__c=brand.id));
            insert subBrands;
                       
            list<Account> accs = new list<Account>();
            
            strRTId = ASI_MFM_Function.checkRecordType('Account','ASI_MFM_CN_Outlet'); 
            accs.add(new Account(recordTypeId=strRTId ,Name='Name3'));
            
             //ASI_MFM_CN_Supplier 
            strRTId = ASI_MFM_Function.checkRecordType('Account','ASI_MFM_CN_Supplier'); 
            accs.add(new Account(Name='TestAcc', recordTypeId=strRTId , ASI_MFM_Customer_Supplier_Number__c='123',
                                    ASI_MFM_Customer_Supplier_Name__c='SupplierName'));
            insert accs;
            
            strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_Plan_Line_Item__c','ASI_MFM_CN_Plan_Line_Item');
            ASI_MFM_Plan_Line_Item__c planLineItem1 = new ASI_MFM_Plan_Line_Item__c(ASI_MFM_Plan__c = Plan1.id
            ,ASI_MFM_Sub_brand_Code__c = subBrands[2].id,ASI_MFM_List_Item_Description__c='hello1'
            ,recordTypeId=strRTId , ASI_MFM_Total_Cost__c =120000,
            ASI_MFM_A_C_Code__c=acs[2].id
            );
            insert planLineItem1; 
            
            //create BU Code
            strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_BU__c','ASI_MFM_CN_BU');
            ASI_MFM_BU__c bu = new ASI_MFM_BU__c(Name='BUCode', ASI_MFM_BU_Code__c=strRTId , ASI_MFM_CN_Country__c='CN',
                                                ASI_MFM_Base_Currency__c='RMB',recordTypeId=strRTId);
            insert bu;
            
            
            
            //create exchange rate reference
            ASI_MFM_Exchange_Rate__c ex = new ASI_MFM_Exchange_Rate__c(ASI_MFM_Country__c='CN',ASI_MFM_Effective_Date__c=Date.valueof('2014-01-01'),
                                                                       ASI_MFM_Exchange_Rate__c=7.77500, ASI_MFM_Counter_Currency__c='USD', ASI_MFM_Base_Currency__c='RMB',
                                                                       ASI_MFM_Application__c='MFM' );
            insert ex;
            
            //create po
            strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_PO__c','ASI_MFM_CN_PO');
            list<ASI_MFM_PO__c> pos = new list<ASI_MFM_PO__c>();
            pos.add(new ASI_MFM_PO__c(Name='PO11111', RecordTypeId=strRTId , ASI_MFM_Prefix__c=prefixs[1].id, ASI_MFM_Remarks__c='Remarks',
                                                ASI_MFM_BU_Code__c=bu.id, ASI_MFM_Supplier_Name__c=accs[1].id, ASI_MFM_Currency__c='USD',
                                                ASI_MFM_PO_Start_Date__c=Date.valueof('2014-04-01'),ASI_MFM_PO_End_Date__c=Date.valueof('2014-04-30'),
                                                ASI_MFM_Budget_Owner__c =user1.id, ASI_MFM_Plan__c=Plan1.id, ASI_MFM_Status__c='Draft'));
            pos.add(new ASI_MFM_PO__c(Name='PO11111', RecordTypeId=strRTId , ASI_MFM_Prefix__c=prefixs[1].id, ASI_MFM_Remarks__c='Remarks',
                                                ASI_MFM_BU_Code__c=bu.id, ASI_MFM_Supplier_Name__c=accs[1].id, ASI_MFM_Currency__c='USD',
                                                ASI_MFM_PO_Start_Date__c=Date.valueof('2014-04-01'),ASI_MFM_PO_End_Date__c=Date.valueof('2014-04-30'),
                                                ASI_MFM_Budget_Owner__c =user1.id, ASI_MFM_Plan__c=Plan1.id, ASI_MFM_Status__c='Draft'));
            insert pos;
            
            test.startTest();
            
            //create po line item
            strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_PO_Line_Item__c','ASI_MFM_CN_PO_Line_Item');
            list<ASI_MFM_PO_Line_Item__c> polis = new list<ASI_MFM_PO_Line_Item__c>(); 
            polis.add(new ASI_MFM_PO_Line_Item__c(RecordTypeId=strRTId, ASI_MFM_PO__c=pos[0].id, ASI_MFM_G_L_Date__c=date.valueof('2014-04-03'),ASI_MFM_Sub_brand_Code__c=subBrands[2].id,
                                                                       ASI_MFM_A_C_Code__c = acs[2].id, ASI_MFM_Customer_Name__c=accs[0].id,ASI_MFM_PO_Remark__c='Remarks'
					                                                 ,ASI_MFM_Amount__c=1));
            polis.add(new ASI_MFM_PO_Line_Item__c(RecordTypeId=strRTId, ASI_MFM_PO__c=pos[1].id, ASI_MFM_G_L_Date__c=date.valueof('2014-04-03'),ASI_MFM_Sub_brand_Code__c=subBrands[2].id,
                                                                       ASI_MFM_A_C_Code__c = acs[2].id, ASI_MFM_Customer_Name__c=accs[0].id,ASI_MFM_PO_Remark__c='Remarks'
                                                 						,ASI_MFM_Amount__c=1));
            
            insert polis;
                                    
            pos = [SELECT Id, Name, RecordTypeId, ASI_MFM_Prefix__c, ASI_MFM_Remarks__c, ASI_MFM_BU_Code__c, ASI_MFM_Supplier_Name__c, ASI_MFM_Currency__c,
                                        ASI_MFM_PO_Start_Date__c,ASI_MFM_PO_End_Date__c, ASI_MFM_Budget_Owner__c, ASI_MFM_Plan__c, ASI_MFM_Status__c,ASI_MFM_PO_Amount__c,ASI_MFM_Exchange_Rate__c,ASI_MFM_Cloned_PO_ID__c,
                                        ASI_MFM_Sys_Sync_Time__c
                                        FROM ASI_MFM_PO__c WHERE Id=:pos[0].Id OR Id=:pos[1].Id];

            pos[0].ASI_MFM_Cloned_PO_ID__c = pos[1].Id;
            pos[1].ASI_MFM_Status__c = 'Complete';
            list<ASI_MFM_PO__c> poOlds = [SELECT Id, Name, RecordTypeId, ASI_MFM_Prefix__c, ASI_MFM_Remarks__c, ASI_MFM_BU_Code__c, ASI_MFM_Supplier_Name__c, ASI_MFM_Currency__c,
                                        ASI_MFM_PO_Start_Date__c,ASI_MFM_PO_End_Date__c, ASI_MFM_Budget_Owner__c, ASI_MFM_Plan__c, ASI_MFM_Status__c,ASI_MFM_PO_Amount__c,ASI_MFM_Exchange_Rate__c,ASI_MFM_Cloned_PO_ID__c,
                                        ASI_MFM_Sys_Sync_Time__c
                                        FROM ASI_MFM_PO__c WHERE Id=:pos[0].Id OR Id=:pos[1].Id];
            poOlds[0].ASI_MFM_Status__c = 'Submitted';
            poOlds[0].ASI_MFM_Exchange_Rate__c = 99;
            poOlds[0].ASI_MFM_Currency__c = 'HKD';
            poOlds[1].ASI_MFM_Status__c = 'Submitted';
            poOlds[1].ASI_MFM_Exchange_Rate__c = 99;
            poOlds[1].ASI_MFM_Currency__c = 'HKD';

            map<Id,ASI_MFM_PO__c> mapPos = new map<Id,ASI_MFM_PO__c>();
            if(pos[0].Id==poOlds[0].Id)
            {
                mapPos.put(poOlds[0].Id, poOlds[0]);
                mapPos.put(poOlds[1].Id, poOlds[1]);
            }
            else
            {
                mapPos.put(poOlds[1].Id, poOlds[1]);
                mapPos.put(poOlds[0].Id, poOlds[0]);
            }
            
            ASI_MFM_PO_TriggerClass.routineAfterAll(null, mapPos);
            ASI_MFM_PO_TriggerClass.routineAfterAll(pos, mapPos);
            /*ASI_MFM_PO_TriggerClass.routineAfterDelete(pos);
            ASI_MFM_PO_TriggerClass.routineAfterInsert(pos);
            ASI_MFM_PO_TriggerClass.routineAfterUpsert(pos, null);
            ASI_MFM_PO_TriggerClass.routineAfterUpdate(pos, mapPos);
            ASI_MFM_PO_TriggerClass.routineBeforeDelete(pos);
            ASI_MFM_PO_TriggerClass.routineBeforeInsert(pos);
            ASI_MFM_PO_TriggerClass.routineBeforeUpdate(pos, mapPos);
            ASI_MFM_PO_TriggerClass.routineBeforeUpsert(pos, mapPos);
            ASI_MFM_PO_TriggerClass.getCreatableFieldsSOQL('User', 'Id!=null');
            */
            Test.stopTest();
        }        
    }
    
    static testmethod void ASI_MFM_PO_TriggerClass_TEST2(){
    ASI_MFM_Market_Strategy__c ms = new ASI_MFM_Market_Strategy__c(Name='99999 Malibu', ASI_MFM_Active__c=true, ASI_MFM_Fiscal_Year__c='FY1213');
        
  //      list<User> users = new list<User>();
      List<User> lstUsr = new List<User>();
        User User1 = new User(managerid = UserInfo.getUserId(), ASI_MFM_Team__c = 'ABCD', ASI_MFM_Country__c ='CN', alias = 'test99',ASI_MFM_Bypass_Callouts__c = true, email='test99' + '@dev.com', emailencodingkey='UTF-8', firstname='test99', lastname='Testing', languagelocalekey='en_US', localesidkey='en_US', timezonesidkey='Europe/London', username='test99' + '@pernod-ricard.com',ProfileId = UserInfo.getProfileId(), UserRoleId = UserInfo.getUserRoleId(), isActive=true);
        User User2 = new User(managerid = UserInfo.getUserId(), ASI_MFM_Team__c = 'ABCD', ASI_MFM_Country__c ='CN', alias = 'tes99',ASI_MFM_Bypass_Callouts__c = true, email='tes99' + '@dev.com', emailencodingkey='UTF-8', firstname='tes99', lastname='Testing', languagelocalekey='en_US', localesidkey='en_US', timezonesidkey='Europe/London', username='tes99' + '@pernod-ricard.com',ProfileId = UserInfo.getProfileId(), UserRoleId = UserInfo.getUserRoleId(), isActive=true);
        lstUsr.add(user2);
        lstUsr.add(user1);
        insert lstUsr;
        
        for(user u : [SELECT Id, Name, ManagerId, ASI_MFM_Bypass_Callouts__c, ASI_MFM_Country__c, UserRole.DeveloperName 
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
        
        /*user1 = [SELECT Id, Name, ManagerId, ASI_MFM_Bypass_Callouts__c, ASI_MFM_Country__c, UserRole.DeveloperName 
                            FROM User
                            WHERE id =: user1.id 
                            LIMIT 1];
        user2 = [SELECT Id, Name, ManagerId, ASI_MFM_Bypass_Callouts__c, ASI_MFM_Country__c, UserRole.DeveloperName 
                            FROM User
                            WHERE id =: user2.id 
                            LIMIT 1];*/
        
     /*   User user2 = ASI_MFM_Function.getManagerCN();
        user2.ASI_MFM_Team__c = 'ABCD';
        System.debug(user2.ASI_MFM_Country__c);
        system.debug(user2.userRole.developerName);
        user2.ASI_MFM_Country__c ='CN';
        users.add(user2);
        
        User user1 = ASI_MFM_Function.getSystemAdminUser();
        user1.ASI_MFM_Team__c = 'ABCD';
        System.debug(user1.ASI_MFM_Country__c);
        system.debug(user1.userRole.developerName);
        user1.ASI_MFM_Country__c ='CN';
        user1.managerid = user2.id;
        users.add(user1);
        
        update users;*/
    
        System.runAs(user1){
        
            String strRTID;
            
            list<ASI_MFM_Prefix__c> prefixs = new list<ASI_MFM_Prefix__c>();
            prefixs.add(new ASI_MFM_Prefix__c(Name='CN',ASI_MFM_Module__c='Plan',Plan_Type__c='Allowance & Discount Spending Form'
            ,ASI_MFM_Fiscal_year__c='FY1314',ownerId = user1.id));
            
            //create prefix po
            strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_Prefix__c','ASI_MFM_CN_Prefix');
            prefixs.add(new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO', recordTypeId=strRTID,
                                                        ASI_MFM_Fiscal_year__c='FY1314', ASI_MFM_Next_Number__c=86));
            insert prefixs;
            
            list<ASI_MFM_Role_Prefix_Relationship__c> prefixChilds = new list<ASI_MFM_Role_Prefix_Relationship__c>();
            prefixChilds.Add(new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c = prefixs[0].Id,
            ASI_MFM_Role_Name__c =user1.userRole.developerName));            
            prefixChilds.Add(new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c = prefixs[1].Id,
            ASI_MFM_Role_Name__c =user1.userRole.developerName));            
            
            insert prefixChilds;

            
            strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_A_C_Code__c','ASI_MFM_CN_A_C_Code');
            list<ASI_MFM_A_C_Code__c> acs = new list<ASI_MFM_A_C_Code__c>();
            acs.add(new ASI_MFM_A_C_Code__c(recordtypeid=strRTId, name='testAC1', ASI_MFM_A_C_Code__c = '5600.000'));
            acs.add(new ASI_MFM_A_C_Code__c(recordtypeid=strRTId, name='testAC2', ASI_MFM_A_C_Code__c = '5600.300'));
            acs.add(new ASI_MFM_A_C_Code__c(name='testAC', recordtypeid=strRTId ));
            insert acs;
            
            strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_PP_Category__c','ASI_MFM_CN_PP_Category');   
            ASI_MFM_PP_Category__c ppc = new ASI_MFM_PP_Category__c(recordtypeid=strRTId , Name='NTMCD - KTV Promotion', ASI_MFM_External_ID__c='NTMCD - KTV Promotion (CN)1');
            insert ppc;
            
            strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_PP_Category_A_C__c','ASI_MFM_CN_PP_Category_A_C'); 
            list<ASI_MFM_PP_Category_A_C__c> ppcacs = new list<ASI_MFM_PP_Category_A_C__c>();
            ppcacs.add(new ASI_MFM_PP_Category_A_C__c(ASI_MFM_External_ID__c='test', recordtypeid=strRTId , ASI_MFM_A_C_Code__c=acs[0].id, ASI_MFM_PP_Category__c=ppc.id));
            ppcacs.add(new ASI_MFM_PP_Category_A_C__c(ASI_MFM_External_ID__c='test2', recordtypeid=strRTId , ASI_MFM_A_C_Code__c=acs[1].id,ASI_MFM_PP_Category__c=ppc.id));
            insert ppcacs; 
            
            ASI_MFM_Market_Strategy__c mms = new ASI_MFM_Market_Strategy__c(name='12004 Chivas', ASI_MFM_External_ID__c='120041',ASI_MFM_Fiscal_Year__c='FY1213', ASI_MFM_Sub_brand__c='CH2,CH3,CHF,CHU');
            insert mms;
            
            strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_Plan__c','ASI_MFM_CN_Plan'); 
            ASI_MFM_Plan__c Plan1 = new ASI_MFM_Plan__c(Name='CNM131',ASI_MFM_Prefix__c=prefixs[0].Id
            ,recordTypeId=strRTId ,
            ASI_MFM_End_Date__c = Date.today().addMonths(1), ASI_MFM_Plan_Description__c='testDescription', 
            ASI_MFM_Plan_Name__c='plannameTest', ASI_MFM_Start_Date__c=Date.today(), ASI_MFM_Budget_Owner__c=user1.id, 
            ASI_MFM_PP_Category__c = ppc.id, ASI_MFM_Market_Strategy__c=mms.id, ASI_MFM_Status__c='Final', OwnerId =user1.id);
            insert Plan1;
            
            //create brand
            strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_Brand__c','ASI_MFM_CN_Brand');
            ASI_MFM_Brand__c brand = new ASI_MFM_Brand__c(name='brandname',Recordtypeid=strRTId);
            insert brand; 
     
            list<ASI_MFM_Sub_brand__c> subBrands = new list<ASI_MFM_Sub_brand__c>();
            //create sub brand
            strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_Sub_brand__c','ASI_MFM_CN_Sub_Brand');
            subBrands.add(new ASI_MFM_Sub_brand__c(Name='subBrand1' ,recordTypeId=strRTId));
            subBrands.add(new ASI_MFM_Sub_brand__c(Name='subBrand2' ,recordTypeId=strRTId));
            subBrands.add(new ASI_MFM_Sub_brand__c(Name='testSb',recordtypeid=strRTId,ASI_MFM_Brand__c=brand.id));
            insert subBrands;
                       
            list<Account> accs = new list<Account>();
            
            strRTId = ASI_MFM_Function.checkRecordType('Account','ASI_MFM_CN_Outlet'); 
            accs.add(new Account(recordTypeId=strRTId ,Name='Name3'));
            
             //ASI_MFM_CN_Supplier 
            strRTId = ASI_MFM_Function.checkRecordType('Account','ASI_MFM_CN_Supplier'); 
            accs.add(new Account(Name='TestAcc', recordTypeId=strRTId , ASI_MFM_Customer_Supplier_Number__c='123',
                                    ASI_MFM_Customer_Supplier_Name__c='SupplierName'));
            insert accs;
            
            strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_Plan_Line_Item__c','ASI_MFM_CN_Plan_Line_Item');
            ASI_MFM_Plan_Line_Item__c planLineItem1 = new ASI_MFM_Plan_Line_Item__c(ASI_MFM_Plan__c = Plan1.id
            ,ASI_MFM_Sub_brand_Code__c = subBrands[2].id,ASI_MFM_List_Item_Description__c='hello1'
            ,recordTypeId=strRTId , ASI_MFM_Total_Cost__c =120000,
            ASI_MFM_A_C_Code__c=acs[2].id
            );
            insert planLineItem1; 
            
            //create BU Code
            strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_BU__c','ASI_MFM_CN_BU');
            ASI_MFM_BU__c bu = new ASI_MFM_BU__c(Name='BUCode', ASI_MFM_BU_Code__c=strRTId , ASI_MFM_CN_Country__c='CN',
                                                ASI_MFM_Base_Currency__c='RMB',recordTypeId=strRTId);
            insert bu;
            
            
            
            //create exchange rate reference
            ASI_MFM_Exchange_Rate__c ex = new ASI_MFM_Exchange_Rate__c(ASI_MFM_Country__c='CN',ASI_MFM_Effective_Date__c=Date.valueof('2014-01-01'),
                                                                       ASI_MFM_Exchange_Rate__c=7.77500, ASI_MFM_Counter_Currency__c='USD', ASI_MFM_Base_Currency__c='RMB',
                                                                       ASI_MFM_Application__c='MFM' );
            insert ex;
            
            //create po
            strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_PO__c','ASI_MFM_CN_PO');
            list<ASI_MFM_PO__c> pos = new list<ASI_MFM_PO__c>();
            pos.add(new ASI_MFM_PO__c(Name='PO11111', RecordTypeId=strRTId , ASI_MFM_Prefix__c=prefixs[1].id, ASI_MFM_Remarks__c='Remarks',
                                                ASI_MFM_BU_Code__c=bu.id, ASI_MFM_Supplier_Name__c=accs[1].id, ASI_MFM_Currency__c='USD',
                                                ASI_MFM_PO_Start_Date__c=Date.valueof('2014-04-01'),ASI_MFM_PO_End_Date__c=Date.valueof('2014-04-30'),
                                                ASI_MFM_Budget_Owner__c =user1.id, ASI_MFM_Plan__c=Plan1.id, ASI_MFM_Status__c='Draft'));
            pos.add(new ASI_MFM_PO__c(Name='PO11111', RecordTypeId=strRTId , ASI_MFM_Prefix__c=prefixs[1].id, ASI_MFM_Remarks__c='Remarks',
                                                ASI_MFM_BU_Code__c=bu.id, ASI_MFM_Supplier_Name__c=accs[1].id, ASI_MFM_Currency__c='USD',
                                                ASI_MFM_PO_Start_Date__c=Date.valueof('2014-04-01'),ASI_MFM_PO_End_Date__c=Date.valueof('2014-04-30'),
                                                ASI_MFM_Budget_Owner__c =user1.id, ASI_MFM_Plan__c=Plan1.id, ASI_MFM_Status__c='Draft'));
            insert pos;
            
            test.startTest();
            
            //create po line item
            strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_PO_Line_Item__c','ASI_MFM_CN_PO_Line_Item');
            list<ASI_MFM_PO_Line_Item__c> polis = new list<ASI_MFM_PO_Line_Item__c>(); 
            polis.add(new ASI_MFM_PO_Line_Item__c(RecordTypeId=strRTId, ASI_MFM_PO__c=pos[0].id, ASI_MFM_G_L_Date__c=date.valueof('2014-04-03'),ASI_MFM_Sub_brand_Code__c=subBrands[2].id,
                                                                       ASI_MFM_A_C_Code__c = acs[2].id, ASI_MFM_Customer_Name__c=accs[0].id,ASI_MFM_PO_Remark__c='Remarks'
					                                                 ,ASI_MFM_Amount__c=1));
            polis.add(new ASI_MFM_PO_Line_Item__c(RecordTypeId=strRTId, ASI_MFM_PO__c=pos[1].id, ASI_MFM_G_L_Date__c=date.valueof('2014-04-03'),ASI_MFM_Sub_brand_Code__c=subBrands[2].id,
                                                                       ASI_MFM_A_C_Code__c = acs[2].id, ASI_MFM_Customer_Name__c=accs[0].id,ASI_MFM_PO_Remark__c='Remarks'
					                                                 ,ASI_MFM_Amount__c=1));
            
            insert polis;
                                    
            pos = [SELECT Id, Name, RecordTypeId, ASI_MFM_Prefix__c, ASI_MFM_Remarks__c, ASI_MFM_BU_Code__c, ASI_MFM_Supplier_Name__c, ASI_MFM_Currency__c,
                                        ASI_MFM_PO_Start_Date__c,ASI_MFM_PO_End_Date__c, ASI_MFM_Budget_Owner__c, ASI_MFM_Plan__c, ASI_MFM_Status__c,ASI_MFM_PO_Amount__c,ASI_MFM_Exchange_Rate__c,ASI_MFM_Cloned_PO_ID__c,
                                        ASI_MFM_Sys_Sync_Time__c
                                        FROM ASI_MFM_PO__c WHERE Id=:pos[0].Id OR Id=:pos[1].Id];

            pos[0].ASI_MFM_Cloned_PO_ID__c = pos[1].Id;
            pos[1].ASI_MFM_Status__c = 'Complete';
            list<ASI_MFM_PO__c> poOlds = [SELECT Id, Name, RecordTypeId, ASI_MFM_Prefix__c, ASI_MFM_Remarks__c, ASI_MFM_BU_Code__c, ASI_MFM_Supplier_Name__c, ASI_MFM_Currency__c,
                                        ASI_MFM_PO_Start_Date__c,ASI_MFM_PO_End_Date__c, ASI_MFM_Budget_Owner__c, ASI_MFM_Plan__c, ASI_MFM_Status__c,ASI_MFM_PO_Amount__c,ASI_MFM_Exchange_Rate__c,ASI_MFM_Cloned_PO_ID__c,
                                        ASI_MFM_Sys_Sync_Time__c
                                        FROM ASI_MFM_PO__c WHERE Id=:pos[0].Id OR Id=:pos[1].Id];
            poOlds[0].ASI_MFM_Status__c = 'Submitted';
            poOlds[0].ASI_MFM_Exchange_Rate__c = 99;
            poOlds[0].ASI_MFM_Currency__c = 'HKD';
            poOlds[1].ASI_MFM_Status__c = 'Submitted';
            poOlds[1].ASI_MFM_Exchange_Rate__c = 99;
            poOlds[1].ASI_MFM_Currency__c = 'HKD';

            map<Id,ASI_MFM_PO__c> mapPos = new map<Id,ASI_MFM_PO__c>();
            if(pos[0].Id==poOlds[0].Id)
            {
                mapPos.put(poOlds[0].Id, poOlds[0]);
                mapPos.put(poOlds[1].Id, poOlds[1]);
            }
            else
            {
                mapPos.put(poOlds[1].Id, poOlds[1]);
                mapPos.put(poOlds[0].Id, poOlds[0]);
            }
            
            /*ASI_MFM_PO_TriggerClass.routineAfterAll(null, mapPos);
            ASI_MFM_PO_TriggerClass.routineAfterAll(pos, mapPos);*/
            ASI_MFM_PO_TriggerClass.routineAfterDelete(pos);
            ASI_MFM_PO_TriggerClass.routineAfterInsert(pos);
            //ASI_MFM_PO_TriggerClass.routineAfterUpsert(pos, null);
            //ASI_MFM_PO_TriggerClass.routineAfterUpdate(pos, mapPos);
            ASI_MFM_PO_TriggerClass.routineBeforeDelete(pos);
            /*ASI_MFM_PO_TriggerClass.routineBeforeInsert(pos);
            ASI_MFM_PO_TriggerClass.routineBeforeUpdate(pos, mapPos);
            ASI_MFM_PO_TriggerClass.routineBeforeUpsert(pos, mapPos);
            ASI_MFM_PO_TriggerClass.getCreatableFieldsSOQL('User', 'Id!=null');*/
            
            Test.stopTest();
        }        
    }
    
    static testmethod void ASI_MFM_PO_TriggerClass_TEST4(){
    ASI_MFM_Market_Strategy__c ms = new ASI_MFM_Market_Strategy__c(Name='99999 Malibu', ASI_MFM_Active__c=true, ASI_MFM_Fiscal_Year__c='FY1213');
        
  //      list<User> users = new list<User>();
      List<User> lstUsr = new List<User>();
        User User1 = new User(managerid = UserInfo.getUserId(), ASI_MFM_Team__c = 'ABCD', ASI_MFM_Country__c ='CN', alias = 'test99',ASI_MFM_Bypass_Callouts__c = true, email='test99' + '@dev.com', emailencodingkey='UTF-8', firstname='test99', lastname='Testing', languagelocalekey='en_US', localesidkey='en_US', timezonesidkey='Europe/London', username='test99' + '@pernod-ricard.com',ProfileId = UserInfo.getProfileId(), UserRoleId = UserInfo.getUserRoleId(), isActive=true);
        User User2 = new User(managerid = UserInfo.getUserId(), ASI_MFM_Team__c = 'ABCD', ASI_MFM_Country__c ='CN', alias = 'tes99',ASI_MFM_Bypass_Callouts__c = true, email='tes99' + '@dev.com', emailencodingkey='UTF-8', firstname='tes99', lastname='Testing', languagelocalekey='en_US', localesidkey='en_US', timezonesidkey='Europe/London', username='tes99' + '@pernod-ricard.com',ProfileId = UserInfo.getProfileId(), UserRoleId = UserInfo.getUserRoleId(), isActive=true);
        lstUsr.add(user2);
        lstUsr.add(user1);
        insert lstUsr;
        
        for(user u : [SELECT Id, Name, ManagerId, ASI_MFM_Bypass_Callouts__c, ASI_MFM_Country__c, UserRole.DeveloperName 
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
        
        /*user1 = [SELECT Id, Name, ManagerId, ASI_MFM_Bypass_Callouts__c, ASI_MFM_Country__c, UserRole.DeveloperName 
                            FROM User
                            WHERE id =: user1.id 
                            LIMIT 1];
        user2 = [SELECT Id, Name, ManagerId, ASI_MFM_Bypass_Callouts__c, ASI_MFM_Country__c, UserRole.DeveloperName 
                            FROM User
                            WHERE id =: user2.id 
                            LIMIT 1];*/
        
     /*   User user2 = ASI_MFM_Function.getManagerCN();
        user2.ASI_MFM_Team__c = 'ABCD';
        System.debug(user2.ASI_MFM_Country__c);
        system.debug(user2.userRole.developerName);
        user2.ASI_MFM_Country__c ='CN';
        users.add(user2);
        
        User user1 = ASI_MFM_Function.getSystemAdminUser();
        user1.ASI_MFM_Team__c = 'ABCD';
        System.debug(user1.ASI_MFM_Country__c);
        system.debug(user1.userRole.developerName);
        user1.ASI_MFM_Country__c ='CN';
        user1.managerid = user2.id;
        users.add(user1);
        
        update users;*/
    
        System.runAs(user1){
        
            String strRTID;
            
            list<ASI_MFM_Prefix__c> prefixs = new list<ASI_MFM_Prefix__c>();
            prefixs.add(new ASI_MFM_Prefix__c(Name='CN',ASI_MFM_Module__c='Plan',Plan_Type__c='Allowance & Discount Spending Form'
            ,ASI_MFM_Fiscal_year__c='FY1314',ownerId = user1.id));
            
            //create prefix po
            strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_Prefix__c','ASI_MFM_CN_Prefix');
            prefixs.add(new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO', recordTypeId=strRTID,
                                                        ASI_MFM_Fiscal_year__c='FY1314', ASI_MFM_Next_Number__c=86));
            insert prefixs;
            
            list<ASI_MFM_Role_Prefix_Relationship__c> prefixChilds = new list<ASI_MFM_Role_Prefix_Relationship__c>();
            prefixChilds.Add(new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c = prefixs[0].Id,
            ASI_MFM_Role_Name__c =user1.userRole.developerName));            
            prefixChilds.Add(new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c = prefixs[1].Id,
            ASI_MFM_Role_Name__c =user1.userRole.developerName));            
            
            insert prefixChilds;

            
            strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_A_C_Code__c','ASI_MFM_CN_A_C_Code');
            list<ASI_MFM_A_C_Code__c> acs = new list<ASI_MFM_A_C_Code__c>();
            acs.add(new ASI_MFM_A_C_Code__c(recordtypeid=strRTId, name='testAC1', ASI_MFM_A_C_Code__c = '5600.000'));
            acs.add(new ASI_MFM_A_C_Code__c(recordtypeid=strRTId, name='testAC2', ASI_MFM_A_C_Code__c = '5600.300'));
            acs.add(new ASI_MFM_A_C_Code__c(name='testAC', recordtypeid=strRTId ));
            insert acs;
            
            strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_PP_Category__c','ASI_MFM_CN_PP_Category');   
            ASI_MFM_PP_Category__c ppc = new ASI_MFM_PP_Category__c(recordtypeid=strRTId , Name='NTMCD - KTV Promotion', ASI_MFM_External_ID__c='NTMCD - KTV Promotion (CN)1');
            insert ppc;
            
            strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_PP_Category_A_C__c','ASI_MFM_CN_PP_Category_A_C'); 
            list<ASI_MFM_PP_Category_A_C__c> ppcacs = new list<ASI_MFM_PP_Category_A_C__c>();
            ppcacs.add(new ASI_MFM_PP_Category_A_C__c(ASI_MFM_External_ID__c='test', recordtypeid=strRTId , ASI_MFM_A_C_Code__c=acs[0].id, ASI_MFM_PP_Category__c=ppc.id));
            ppcacs.add(new ASI_MFM_PP_Category_A_C__c(ASI_MFM_External_ID__c='test2', recordtypeid=strRTId , ASI_MFM_A_C_Code__c=acs[1].id,ASI_MFM_PP_Category__c=ppc.id));
            insert ppcacs; 
            
            ASI_MFM_Market_Strategy__c mms = new ASI_MFM_Market_Strategy__c(name='12004 Chivas', ASI_MFM_External_ID__c='120041',ASI_MFM_Fiscal_Year__c='FY1213', ASI_MFM_Sub_brand__c='CH2,CH3,CHF,CHU');
            insert mms;
            
            strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_Plan__c','ASI_MFM_CN_Plan'); 
            ASI_MFM_Plan__c Plan1 = new ASI_MFM_Plan__c(Name='CNM131',ASI_MFM_Prefix__c=prefixs[0].Id
            ,recordTypeId=strRTId ,
            ASI_MFM_End_Date__c = Date.today().addMonths(1), ASI_MFM_Plan_Description__c='testDescription', 
            ASI_MFM_Plan_Name__c='plannameTest', ASI_MFM_Start_Date__c=Date.today(), ASI_MFM_Budget_Owner__c=user1.id, 
            ASI_MFM_PP_Category__c = ppc.id, ASI_MFM_Market_Strategy__c=mms.id, ASI_MFM_Status__c='Final', OwnerId =user1.id);
            insert Plan1;
            
            //create brand
            strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_Brand__c','ASI_MFM_CN_Brand');
            ASI_MFM_Brand__c brand = new ASI_MFM_Brand__c(name='brandname',Recordtypeid=strRTId);
            insert brand; 
     
            list<ASI_MFM_Sub_brand__c> subBrands = new list<ASI_MFM_Sub_brand__c>();
            //create sub brand
            strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_Sub_brand__c','ASI_MFM_CN_Sub_Brand');
            subBrands.add(new ASI_MFM_Sub_brand__c(Name='subBrand1' ,recordTypeId=strRTId));
            subBrands.add(new ASI_MFM_Sub_brand__c(Name='subBrand2' ,recordTypeId=strRTId));
            subBrands.add(new ASI_MFM_Sub_brand__c(Name='testSb',recordtypeid=strRTId,ASI_MFM_Brand__c=brand.id));
            insert subBrands;
                       
            list<Account> accs = new list<Account>();
            
            strRTId = ASI_MFM_Function.checkRecordType('Account','ASI_MFM_CN_Outlet'); 
            accs.add(new Account(recordTypeId=strRTId ,Name='Name3'));
            
             //ASI_MFM_CN_Supplier 
            strRTId = ASI_MFM_Function.checkRecordType('Account','ASI_MFM_CN_Supplier'); 
            accs.add(new Account(Name='TestAcc', recordTypeId=strRTId , ASI_MFM_Customer_Supplier_Number__c='123',
                                    ASI_MFM_Customer_Supplier_Name__c='SupplierName'));
            accs.add(new Account(Name='TEST',ASI_MFM_Customer_Supplier_Number__c='61202305', 
                                 RecordTypeId=Global_RecordTypeCache.getRtId('AccountASI_MFM_CN_Supplier')));
            insert accs;
            
            strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_Plan_Line_Item__c','ASI_MFM_CN_Plan_Line_Item');
            ASI_MFM_Plan_Line_Item__c planLineItem1 = new ASI_MFM_Plan_Line_Item__c(ASI_MFM_Plan__c = Plan1.id
            ,ASI_MFM_Sub_brand_Code__c = subBrands[2].id,ASI_MFM_List_Item_Description__c='hello1'
            ,recordTypeId=strRTId , ASI_MFM_Total_Cost__c =120000,
            ASI_MFM_A_C_Code__c=acs[2].id
            );
            insert planLineItem1; 
            
            //create BU Code
            strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_BU__c','ASI_MFM_CN_BU');
            ASI_MFM_BU__c bu = new ASI_MFM_BU__c(Name='BUCode', ASI_MFM_BU_Code__c=strRTId , ASI_MFM_CN_Country__c='CN',
                                                ASI_MFM_Base_Currency__c='RMB',recordTypeId=strRTId);
            insert bu;
            
            
            
            //create exchange rate reference
            ASI_MFM_Exchange_Rate__c ex = new ASI_MFM_Exchange_Rate__c(ASI_MFM_Country__c='CN',ASI_MFM_Effective_Date__c=Date.valueof('2014-01-01'),
                                                                       ASI_MFM_Exchange_Rate__c=7.77500, ASI_MFM_Counter_Currency__c='USD', ASI_MFM_Base_Currency__c='RMB',
                                                                       ASI_MFM_Application__c='MFM' );
            insert ex;
            
            //create po
            strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_PO__c','ASI_MFM_CN_PO');
            list<ASI_MFM_PO__c> pos = new list<ASI_MFM_PO__c>();
            pos.add(new ASI_MFM_PO__c(Name='PO11111', RecordTypeId=strRTId , ASI_MFM_Prefix__c=prefixs[1].id, ASI_MFM_Remarks__c='Remarks',
                                      ASI_MFM_BU_Code__c=bu.id, ASI_MFM_Supplier_Name__c=accs[1].id, ASI_MFM_Currency__c='USD',
                                      ASI_MFM_PO_Start_Date__c=Date.valueof('2014-04-01'),ASI_MFM_PO_End_Date__c=Date.valueof('2014-04-30'),
                                      ASI_MFM_Budget_Owner__c =user1.id, ASI_MFM_Plan__c=Plan1.id, ASI_MFM_Status__c='Draft'));
            pos.add(new ASI_MFM_PO__c(Name='PO11111', RecordTypeId=strRTId , ASI_MFM_Prefix__c=prefixs[1].id, ASI_MFM_Remarks__c='Remarks',
                                      ASI_MFM_BU_Code__c=bu.id, ASI_MFM_Supplier_Name__c=accs[1].id, ASI_MFM_Currency__c='USD',
                                      ASI_MFM_PO_Start_Date__c=Date.valueof('2014-04-01'),ASI_MFM_PO_End_Date__c=Date.valueof('2014-04-30'),
                                      ASI_MFM_Budget_Owner__c =user1.id, ASI_MFM_Plan__c=Plan1.id, ASI_MFM_Status__c='Draft'));
            pos.add(new ASI_MFM_PO__c(Name='PO33333', RecordTypeId=strRTId , ASI_MFM_Prefix__c=prefixs[1].id, ASI_MFM_Remarks__c='Remarks',
                                      ASI_MFM_BU_Code__c=bu.id, ASI_MFM_Supplier_Name__c=accs[1].id, ASI_MFM_Currency__c='RMB',
                                      ASI_MFM_PO_Start_Date__c=Date.valueof('2014-04-01'),ASI_MFM_PO_End_Date__c=Date.valueof('2014-04-30'),
                                      ASI_MFM_Budget_Owner__c =user2.id, ASI_MFM_Plan__c=Plan1.id, ASI_MFM_Status__c='Draft'));
            pos.add(new ASI_MFM_PO__c(Name='PO44444', RecordTypeId=strRTId , ASI_MFM_Prefix__c=prefixs[1].id, ASI_MFM_Remarks__c='Remarks',
                                      ASI_MFM_BU_Code__c=bu.id, ASI_MFM_Supplier_Name__c=accs[2].id, ASI_MFM_Currency__c='RMB',
                                      ASI_MFM_PO_Start_Date__c=Date.valueof('2014-04-01'),ASI_MFM_PO_End_Date__c=Date.valueof('2014-04-30'),
                                      ASI_MFM_Budget_Owner__c =user2.id, ASI_MFM_Plan__c=Plan1.id, ASI_MFM_Status__c='Final',
                                      ASI_MFM_CN_BU_Picklist__c='PRCN'
                                     ));
            pos.add(new ASI_MFM_PO__c(Name='PO55555', RecordTypeId=strRTId , ASI_MFM_Prefix__c=prefixs[1].id, ASI_MFM_Remarks__c='Remarks',
                                      ASI_MFM_BU_Code__c=bu.id, ASI_MFM_Supplier_Name__c=accs[2].id, ASI_MFM_Currency__c='RMB',
                                      ASI_MFM_PO_Start_Date__c=Date.valueof('2014-04-01'),ASI_MFM_PO_End_Date__c=Date.valueof('2014-04-30'),
                                      ASI_MFM_Budget_Owner__c =user2.id, ASI_MFM_Plan__c=Plan1.id, ASI_MFM_Status__c='Submitted',
                                      ASI_MFM_CN_BU_Picklist__c='PRCN'
                                     ));
            pos.add(new ASI_MFM_PO__c(Name='PO66666', RecordTypeId=strRTId , ASI_MFM_Prefix__c=prefixs[1].id, ASI_MFM_Remarks__c='Remarks',
                                      ASI_MFM_BU_Code__c=bu.id, ASI_MFM_Supplier_Name__c=accs[2].id, ASI_MFM_Currency__c='RMB',
                                      ASI_MFM_PO_Start_Date__c=Date.valueof('2014-04-01'),ASI_MFM_PO_End_Date__c=Date.valueof('2014-04-30'),
                                      ASI_MFM_Budget_Owner__c =user2.id, ASI_MFM_Plan__c=Plan1.id, ASI_MFM_Status__c='Draft',
                                      ASI_MFM_CN_BU_Picklist__c='PRCN'
                                     ));
            insert pos;
            
            pos[0].ASI_MFM_Status__c = 'Final';
            pos[5].ASI_MFM_Status__c = 'Final';
            pos[3].ASI_MFM_PO_Start_Date__c = Date.valueof('2014-04-03');
            update pos;
            
            test.startTest();
            
            //create po line item
            strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_PO_Line_Item__c','ASI_MFM_CN_PO_Line_Item');
            list<ASI_MFM_PO_Line_Item__c> polis = new list<ASI_MFM_PO_Line_Item__c>(); 
            polis.add(new ASI_MFM_PO_Line_Item__c(RecordTypeId=strRTId, ASI_MFM_PO__c=pos[0].id, ASI_MFM_G_L_Date__c=date.valueof('2014-04-03'),ASI_MFM_Sub_brand_Code__c=subBrands[2].id,
                                                                       ASI_MFM_A_C_Code__c = acs[2].id, ASI_MFM_Customer_Name__c=accs[0].id,ASI_MFM_PO_Remark__c='Remarks'
					                                                 ,ASI_MFM_Amount__c=1));
            polis.add(new ASI_MFM_PO_Line_Item__c(RecordTypeId=strRTId, ASI_MFM_PO__c=pos[1].id, ASI_MFM_G_L_Date__c=date.valueof('2014-04-03'),ASI_MFM_Sub_brand_Code__c=subBrands[2].id,
                                                                       ASI_MFM_A_C_Code__c = acs[2].id, ASI_MFM_Customer_Name__c=accs[0].id,ASI_MFM_PO_Remark__c='Remarks'
					                                                 ,ASI_MFM_Amount__c=1));
            
            insert polis;
                                    
            pos = [SELECT Id, Name, RecordTypeId, ASI_MFM_Prefix__c, ASI_MFM_Remarks__c, ASI_MFM_BU_Code__c, ASI_MFM_Supplier_Name__c, ASI_MFM_Currency__c,
                                        ASI_MFM_PO_Start_Date__c,ASI_MFM_PO_End_Date__c, ASI_MFM_Budget_Owner__c, ASI_MFM_Plan__c, ASI_MFM_Status__c,ASI_MFM_PO_Amount__c,ASI_MFM_Exchange_Rate__c,ASI_MFM_Cloned_PO_ID__c,
                                        ASI_MFM_Sys_Sync_Time__c
                                        FROM ASI_MFM_PO__c WHERE Id=:pos[0].Id OR Id=:pos[1].Id];

            pos[0].ASI_MFM_Cloned_PO_ID__c = pos[1].Id;
            pos[1].ASI_MFM_Status__c = 'Complete';
            list<ASI_MFM_PO__c> poOlds = [SELECT Id, Name, RecordTypeId, ASI_MFM_Prefix__c, ASI_MFM_Remarks__c, ASI_MFM_BU_Code__c, ASI_MFM_Supplier_Name__c, ASI_MFM_Currency__c,
                                        ASI_MFM_PO_Start_Date__c,ASI_MFM_PO_End_Date__c, ASI_MFM_Budget_Owner__c, ASI_MFM_Plan__c, ASI_MFM_Status__c,ASI_MFM_PO_Amount__c,ASI_MFM_Exchange_Rate__c,ASI_MFM_Cloned_PO_ID__c,
                                        ASI_MFM_Sys_Sync_Time__c
                                        FROM ASI_MFM_PO__c WHERE Id=:pos[0].Id OR Id=:pos[1].Id];
            poOlds[0].ASI_MFM_Status__c = 'Submitted';
            poOlds[0].ASI_MFM_Exchange_Rate__c = 99;
            poOlds[0].ASI_MFM_Currency__c = 'HKD';
            poOlds[1].ASI_MFM_Status__c = 'Submitted';
            poOlds[1].ASI_MFM_Exchange_Rate__c = 99;
            poOlds[1].ASI_MFM_Currency__c = 'HKD';

            map<Id,ASI_MFM_PO__c> mapPos = new map<Id,ASI_MFM_PO__c>();
            if(pos[0].Id==poOlds[0].Id)
            {
                mapPos.put(poOlds[0].Id, poOlds[0]);
                mapPos.put(poOlds[1].Id, poOlds[1]);
            }
            else
            {
                mapPos.put(poOlds[1].Id, poOlds[1]);
                mapPos.put(poOlds[0].Id, poOlds[0]);
            }
            
            /*ASI_MFM_PO_TriggerClass.routineAfterAll(null, mapPos);
            ASI_MFM_PO_TriggerClass.routineAfterAll(pos, mapPos);*/
            //ASI_MFM_PO_TriggerClass.routineAfterDelete(pos);
            //ASI_MFM_PO_TriggerClass.routineAfterInsert(pos);
            ASI_MFM_PO_TriggerClass.routineAfterUpsert(pos, null);
            ASI_MFM_PO_TriggerClass.routineAfterUpdate(pos, mapPos);
            //ASI_MFM_PO_TriggerClass.routineBeforeDelete(pos);
            /*ASI_MFM_PO_TriggerClass.routineBeforeInsert(pos);
            ASI_MFM_PO_TriggerClass.routineBeforeUpdate(pos, mapPos);
            ASI_MFM_PO_TriggerClass.routineBeforeUpsert(pos, mapPos);
            ASI_MFM_PO_TriggerClass.getCreatableFieldsSOQL('User', 'Id!=null');*/
            
            Test.stopTest();
        }        
    }
    
    static testmethod void ASI_MFM_PO_TriggerClass_TEST3(){
    ASI_MFM_Market_Strategy__c ms = new ASI_MFM_Market_Strategy__c(Name='99999 Malibu', ASI_MFM_Active__c=true, ASI_MFM_Fiscal_Year__c='FY1213');
         List<User> lstUsr = new List<User>();
        User User1 = new User(managerid = UserInfo.getUserId(), ASI_MFM_Team__c = 'ABCD', ASI_MFM_Country__c ='CN', alias = 'test99',ASI_MFM_Bypass_Callouts__c = true, email='test99' + '@dev.com', emailencodingkey='UTF-8', firstname='test99', lastname='Testing', languagelocalekey='en_US', localesidkey='en_US', timezonesidkey='Europe/London', username='test99' + '@pernod-ricard.com',ProfileId = UserInfo.getProfileId(), UserRoleId = UserInfo.getUserRoleId(), isActive=true);
        User User2 = new User(managerid = UserInfo.getUserId(), ASI_MFM_Team__c = 'ABCD', ASI_MFM_Country__c ='CN', alias = 'tes99',ASI_MFM_Bypass_Callouts__c = true, email='tes99' + '@dev.com', emailencodingkey='UTF-8', firstname='tes99', lastname='Testing', languagelocalekey='en_US', localesidkey='en_US', timezonesidkey='Europe/London', username='tes99' + '@pernod-ricard.com',ProfileId = UserInfo.getProfileId(), UserRoleId = UserInfo.getUserRoleId(), isActive=true);
        lstUsr.add(user2);
        lstUsr.add(user1);
        insert lstUsr;
        user1 = [SELECT Id, Name, ManagerId, ASI_MFM_Bypass_Callouts__c, ASI_MFM_Country__c, UserRole.DeveloperName 
                            FROM User
                            WHERE id =: user1.id 
                            LIMIT 1];
        user2 = [SELECT Id, Name, ManagerId, ASI_MFM_Bypass_Callouts__c, ASI_MFM_Country__c, UserRole.DeveloperName 
                            FROM User
                            WHERE id =: user2.id 
                            LIMIT 1];
     /*   list<User> users = new list<User>();
        
        User user2 = ASI_MFM_Function.getManagerCN();
        user2.ASI_MFM_Team__c = 'ABCD';
        System.debug(user2.ASI_MFM_Country__c);
        system.debug(user2.userRole.developerName);
        user2.ASI_MFM_Country__c ='CN';
        users.add(user2);
        
        User user1 = ASI_MFM_Function.getSystemAdminUser();
        user1.ASI_MFM_Team__c = 'ABCD';
        System.debug(user1.ASI_MFM_Country__c);
        system.debug(user1.userRole.developerName);
        user1.ASI_MFM_Country__c ='CN';
        user1.managerid = user2.id;
        users.add(user1);
        
        update users;*/
    
        System.runAs(user1){
        
            String strRTID;
            
            list<ASI_MFM_Prefix__c> prefixs = new list<ASI_MFM_Prefix__c>();
            prefixs.add(new ASI_MFM_Prefix__c(Name='CN',ASI_MFM_Module__c='Plan',Plan_Type__c='Allowance & Discount Spending Form'
            ,ASI_MFM_Fiscal_year__c='FY1314',ownerId = user1.id));
            
            //create prefix po
            strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_Prefix__c','ASI_MFM_CN_Prefix');
            prefixs.add(new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO', recordTypeId=strRTID,
                                                        ASI_MFM_Fiscal_year__c='FY1314', ASI_MFM_Next_Number__c=86));
            insert prefixs;
            
            list<ASI_MFM_Role_Prefix_Relationship__c> prefixChilds = new list<ASI_MFM_Role_Prefix_Relationship__c>();
            prefixChilds.Add(new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c = prefixs[0].Id,
            ASI_MFM_Role_Name__c =user1.userRole.developerName));            
            prefixChilds.Add(new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c = prefixs[1].Id,
            ASI_MFM_Role_Name__c =user1.userRole.developerName));            
            
            insert prefixChilds;

            
            strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_A_C_Code__c','ASI_MFM_CN_A_C_Code');
            list<ASI_MFM_A_C_Code__c> acs = new list<ASI_MFM_A_C_Code__c>();
            acs.add(new ASI_MFM_A_C_Code__c(recordtypeid=strRTId, name='testAC1', ASI_MFM_A_C_Code__c = '5600.000'));
            acs.add(new ASI_MFM_A_C_Code__c(recordtypeid=strRTId, name='testAC2', ASI_MFM_A_C_Code__c = '5600.300'));
            acs.add(new ASI_MFM_A_C_Code__c(name='testAC', recordtypeid=strRTId ));
            insert acs;
            
            strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_PP_Category__c','ASI_MFM_CN_PP_Category');   
            ASI_MFM_PP_Category__c ppc = new ASI_MFM_PP_Category__c(recordtypeid=strRTId , Name='NTMCD - KTV Promotion', ASI_MFM_External_ID__c='NTMCD - KTV Promotion (CN)1');
            insert ppc;
            
            strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_PP_Category_A_C__c','ASI_MFM_CN_PP_Category_A_C'); 
            list<ASI_MFM_PP_Category_A_C__c> ppcacs = new list<ASI_MFM_PP_Category_A_C__c>();
            ppcacs.add(new ASI_MFM_PP_Category_A_C__c(ASI_MFM_External_ID__c='test', recordtypeid=strRTId , ASI_MFM_A_C_Code__c=acs[0].id, ASI_MFM_PP_Category__c=ppc.id));
            ppcacs.add(new ASI_MFM_PP_Category_A_C__c(ASI_MFM_External_ID__c='test2', recordtypeid=strRTId , ASI_MFM_A_C_Code__c=acs[1].id,ASI_MFM_PP_Category__c=ppc.id));
            insert ppcacs; 
            
            ASI_MFM_Market_Strategy__c mms = new ASI_MFM_Market_Strategy__c(name='12004 Chivas', ASI_MFM_External_ID__c='120041',ASI_MFM_Fiscal_Year__c='FY1213', ASI_MFM_Sub_brand__c='CH2,CH3,CHF,CHU');
            insert mms;
            
            strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_Plan__c','ASI_MFM_CN_Plan'); 
            ASI_MFM_Plan__c Plan1 = new ASI_MFM_Plan__c(Name='CNM131',ASI_MFM_Prefix__c=prefixs[0].Id
            ,recordTypeId=strRTId ,
            ASI_MFM_End_Date__c = Date.today().addMonths(1), ASI_MFM_Plan_Description__c='testDescription', 
            ASI_MFM_Plan_Name__c='plannameTest', ASI_MFM_Start_Date__c=Date.today(), ASI_MFM_Budget_Owner__c=user1.id, 
            ASI_MFM_PP_Category__c = ppc.id, ASI_MFM_Market_Strategy__c=mms.id, ASI_MFM_Status__c='Final', OwnerId =user1.id);
            insert Plan1;

             ASI_MFM_Plan__c Plan2 = new ASI_MFM_Plan__c(Name='CNM131',ASI_MFM_Prefix__c=prefixs[0].Id
            ,recordTypeId=strRTId ,
            ASI_MFM_End_Date__c = Date.today().addMonths(1), ASI_MFM_Plan_Description__c='testDescription', 
            ASI_MFM_Plan_Name__c='plannameTest', ASI_MFM_Start_Date__c=Date.today(), ASI_MFM_Budget_Owner__c=user1.id, 
            ASI_MFM_PP_Category__c = ppc.id, ASI_MFM_Market_Strategy__c=mms.id, ASI_MFM_Status__c='Final', OwnerId =user1.id);
            insert Plan2;
            
            //create brand
            strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_Brand__c','ASI_MFM_CN_Brand');
            ASI_MFM_Brand__c brand = new ASI_MFM_Brand__c(name='brandname',Recordtypeid=strRTId);
            insert brand; 
     
            list<ASI_MFM_Sub_brand__c> subBrands = new list<ASI_MFM_Sub_brand__c>();
            //create sub brand
            strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_Sub_brand__c','ASI_MFM_CN_Sub_Brand');
            subBrands.add(new ASI_MFM_Sub_brand__c(Name='subBrand1' ,recordTypeId=strRTId));
            subBrands.add(new ASI_MFM_Sub_brand__c(Name='subBrand2' ,recordTypeId=strRTId));
            subBrands.add(new ASI_MFM_Sub_brand__c(Name='testSb',recordtypeid=strRTId,ASI_MFM_Brand__c=brand.id));
            insert subBrands;
                       
            list<Account> accs = new list<Account>();
            
            strRTId = ASI_MFM_Function.checkRecordType('Account','ASI_MFM_CN_Outlet'); 
            accs.add(new Account(recordTypeId=strRTId ,Name='Name3'));
            
             //ASI_MFM_CN_Supplier 
            strRTId = ASI_MFM_Function.checkRecordType('Account','ASI_MFM_CN_Supplier'); 
            accs.add(new Account(Name='TestAcc', recordTypeId=strRTId , ASI_MFM_Customer_Supplier_Number__c='123',
                                    ASI_MFM_Customer_Supplier_Name__c='SupplierName'));
            insert accs;
            
            strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_Plan_Line_Item__c','ASI_MFM_CN_Plan_Line_Item');
            ASI_MFM_Plan_Line_Item__c planLineItem1 = new ASI_MFM_Plan_Line_Item__c(ASI_MFM_Plan__c = Plan1.id
            ,ASI_MFM_Sub_brand_Code__c = subBrands[2].id,ASI_MFM_List_Item_Description__c='hello1'
            ,recordTypeId=strRTId , ASI_MFM_Total_Cost__c =120000,
            ASI_MFM_A_C_Code__c=acs[2].id
            );
            insert planLineItem1; 
            
            //create BU Code
            strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_BU__c','ASI_MFM_CN_BU');
            ASI_MFM_BU__c bu = new ASI_MFM_BU__c(Name='BUCode', ASI_MFM_BU_Code__c=strRTId , ASI_MFM_CN_Country__c='CN',
                                                ASI_MFM_Base_Currency__c='RMB',recordTypeId=strRTId);
            insert bu;
            
            
            
            //create exchange rate reference
            ASI_MFM_Exchange_Rate__c ex = new ASI_MFM_Exchange_Rate__c(ASI_MFM_Country__c='CN',ASI_MFM_Effective_Date__c=Date.valueof('2014-01-01'),
                                                                       ASI_MFM_Exchange_Rate__c=7.77500, ASI_MFM_Counter_Currency__c='USD', ASI_MFM_Base_Currency__c='RMB',
                                                                       ASI_MFM_Application__c='MFM' );
            insert ex;
            // Map<string, id> event_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Event__c');
            // ASI_MFM_Event__c event = new ASI_MFM_Event__c(ASI_MFM_Key_Event_Type_Budget_Share__c = 100,ASI_MFM_Event_Type__c = 'Image/Brand Driven Event', ASI_MFM_Sub_Event_Type__c = 'Thematic Promotion',recordtypeid = event_map.get('ASI_MFM_CN_Event'));
            // insert event;
            // ASI_MFM_Event_PP__c evetPP = new ASI_MFM_Event_PP__c();
            // evetPP.ASI_MFM_Event__c = event.Id;
            // evetPP.ASI_MFM_Plan__c = Plan1.Id;
            // insert evetPP;

            //create po
            strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_PO__c','ASI_MFM_CN_PO');
            list<ASI_MFM_PO__c> pos = new list<ASI_MFM_PO__c>();
            pos.add(new ASI_MFM_PO__c(Name='PO11111', RecordTypeId=strRTId , ASI_MFM_Prefix__c=prefixs[1].id, ASI_MFM_Remarks__c='Remarks',
                                                ASI_MFM_BU_Code__c=bu.id, ASI_MFM_Supplier_Name__c=accs[1].id, ASI_MFM_Currency__c='USD',
                                                ASI_MFM_PO_Start_Date__c=Date.valueof('2014-04-01'),ASI_MFM_PO_End_Date__c=Date.valueof('2014-04-30'),
                                                ASI_MFM_Budget_Owner__c =user1.id, ASI_MFM_Plan__c=Plan1.id, ASI_MFM_Status__c='Draft'));
            pos.add(new ASI_MFM_PO__c(Name='PO11111', RecordTypeId=strRTId , ASI_MFM_Prefix__c=prefixs[1].id, ASI_MFM_Remarks__c='Remarks',
                                                ASI_MFM_BU_Code__c=bu.id, ASI_MFM_Supplier_Name__c=accs[1].id, ASI_MFM_Currency__c='USD',
                                                ASI_MFM_PO_Start_Date__c=Date.valueof('2014-04-01'),ASI_MFM_PO_End_Date__c=Date.valueof('2014-04-30'),
                                                ASI_MFM_Budget_Owner__c =user1.id, ASI_MFM_Plan__c=Plan1.id, ASI_MFM_Status__c='Draft'));
            insert pos;
           
            
            test.startTest();
            
            //create po line item
            strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_PO_Line_Item__c','ASI_MFM_CN_PO_Line_Item');
            list<ASI_MFM_PO_Line_Item__c> polis = new list<ASI_MFM_PO_Line_Item__c>(); 
            polis.add(new ASI_MFM_PO_Line_Item__c(RecordTypeId=strRTId, ASI_MFM_PO__c=pos[0].id, ASI_MFM_G_L_Date__c=date.valueof('2014-04-03'),ASI_MFM_Sub_brand_Code__c=subBrands[2].id,
                                                                       ASI_MFM_A_C_Code__c = acs[2].id, ASI_MFM_Customer_Name__c=accs[0].id,ASI_MFM_PO_Remark__c='Remarks'
					                                                 ,ASI_MFM_Amount__c=1));
            polis.add(new ASI_MFM_PO_Line_Item__c(RecordTypeId=strRTId, ASI_MFM_PO__c=pos[1].id, ASI_MFM_G_L_Date__c=date.valueof('2014-04-03'),ASI_MFM_Sub_brand_Code__c=subBrands[2].id,
                                                                       ASI_MFM_A_C_Code__c = acs[2].id, ASI_MFM_Customer_Name__c=accs[0].id,ASI_MFM_PO_Remark__c='Remarks'
					                                                 ,ASI_MFM_Amount__c=1));
            
            insert polis;
                                    
            pos = [SELECT Id, Name, RecordTypeId, ASI_MFM_Prefix__c, ASI_MFM_Remarks__c, ASI_MFM_BU_Code__c, ASI_MFM_Supplier_Name__c, ASI_MFM_Currency__c,
                                        ASI_MFM_PO_Start_Date__c,ASI_MFM_PO_End_Date__c, ASI_MFM_Budget_Owner__c, ASI_MFM_Plan__c, ASI_MFM_Status__c,ASI_MFM_PO_Amount__c,ASI_MFM_Exchange_Rate__c,ASI_MFM_Cloned_PO_ID__c,
                                        ASI_MFM_Sys_Sync_Time__c
                                        FROM ASI_MFM_PO__c WHERE Id=:pos[0].Id OR Id=:pos[1].Id];

            pos[0].ASI_MFM_Cloned_PO_ID__c = pos[1].Id;
            pos[1].ASI_MFM_Status__c = 'Complete';
            list<ASI_MFM_PO__c> poOlds = [SELECT Id, Name, RecordTypeId, ASI_MFM_Prefix__c, ASI_MFM_Remarks__c, ASI_MFM_BU_Code__c, ASI_MFM_Supplier_Name__c, ASI_MFM_Currency__c,
                                        ASI_MFM_PO_Start_Date__c,ASI_MFM_PO_End_Date__c, ASI_MFM_Budget_Owner__c, ASI_MFM_Plan__c, ASI_MFM_Status__c,ASI_MFM_PO_Amount__c,ASI_MFM_Exchange_Rate__c,ASI_MFM_Cloned_PO_ID__c,
                                        ASI_MFM_Sys_Sync_Time__c
                                        FROM ASI_MFM_PO__c WHERE Id=:pos[0].Id OR Id=:pos[1].Id];
            poOlds[0].ASI_MFM_Status__c = 'Submitted';
            poOlds[0].ASI_MFM_Plan__c = Plan2.Id;
            poOlds[0].ASI_MFM_Exchange_Rate__c = 99;
            poOlds[0].ASI_MFM_Currency__c = 'HKD';
            poOlds[1].ASI_MFM_Status__c = 'Submitted';
            poOlds[1].ASI_MFM_Exchange_Rate__c = 99;
            poOlds[1].ASI_MFM_Currency__c = 'HKD';

            map<Id,ASI_MFM_PO__c> mapPos = new map<Id,ASI_MFM_PO__c>();
            if(pos[0].Id==poOlds[0].Id)
            {
                mapPos.put(poOlds[0].Id, poOlds[0]);
                mapPos.put(poOlds[1].Id, poOlds[1]);
            }
            else
            {
                mapPos.put(poOlds[1].Id, poOlds[1]);
                mapPos.put(poOlds[0].Id, poOlds[0]);
            }
            
            /*ASI_MFM_PO_TriggerClass.routineAfterAll(null, mapPos);
            ASI_MFM_PO_TriggerClass.routineAfterAll(pos, mapPos);
            ASI_MFM_PO_TriggerClass.routineAfterDelete(pos);
            ASI_MFM_PO_TriggerClass.routineAfterInsert(pos);
            ASI_MFM_PO_TriggerClass.routineAfterUpsert(pos, null);
            ASI_MFM_PO_TriggerClass.routineAfterUpdate(pos, mapPos);
            ASI_MFM_PO_TriggerClass.routineBeforeDelete(pos);*/
            ASI_MFM_PO_TriggerClass.routineBeforeInsert(pos);
            ASI_MFM_PO_TriggerClass.routineBeforeUpdate(pos, mapPos);
            ASI_MFM_PO_TriggerClass.routineBeforeUpsert(pos, mapPos);
            ASI_MFM_PO_TriggerClass.getCreatableFieldsSOQL('User', 'Id!=null');
            Test.stopTest();
        }        
    }
    
    static testmethod void ASI_MFM_POLineItem_TriggerClass_TEST(){
    ASI_MFM_Market_Strategy__c ms = new ASI_MFM_Market_Strategy__c(Name='99999 Malibu', ASI_MFM_Active__c=true, ASI_MFM_Fiscal_Year__c='FY1213');
         List<User> lstUsr = new List<User>();
        User User1 = new User(managerid = UserInfo.getUserId(), ASI_MFM_Team__c = 'ABCD', ASI_MFM_Country__c ='CN', alias = 'test99',ASI_MFM_Bypass_Callouts__c = true, email='test99' + '@dev.com', emailencodingkey='UTF-8', firstname='test99', lastname='Testing', languagelocalekey='en_US', localesidkey='en_US', timezonesidkey='Europe/London', username='test99' + '@pernod-ricard.com',ProfileId = UserInfo.getProfileId(), UserRoleId = UserInfo.getUserRoleId(), isActive=true);
        User User2 = new User(managerid = UserInfo.getUserId(), ASI_MFM_Team__c = 'ABCD', ASI_MFM_Country__c ='CN', alias = 'tes99',ASI_MFM_Bypass_Callouts__c = true, email='tes99' + '@dev.com', emailencodingkey='UTF-8', firstname='tes99', lastname='Testing', languagelocalekey='en_US', localesidkey='en_US', timezonesidkey='Europe/London', username='tes99' + '@pernod-ricard.com',ProfileId = UserInfo.getProfileId(), UserRoleId = UserInfo.getUserRoleId(), isActive=true);
        lstUsr.add(user2);
        lstUsr.add(user1);
        insert lstUsr;
        user1 = [SELECT Id, Name, ManagerId, ASI_MFM_Bypass_Callouts__c, ASI_MFM_Country__c, UserRole.DeveloperName 
                            FROM User
                            WHERE id =: user1.id 
                            LIMIT 1];
        user2 = [SELECT Id, Name, ManagerId, ASI_MFM_Bypass_Callouts__c, ASI_MFM_Country__c, UserRole.DeveloperName 
                            FROM User
                            WHERE id =: user2.id 
                            LIMIT 1];
       /* list<User> users = new list<User>();
        
        User user2 = ASI_MFM_Function.getManagerCN();
        user2.ASI_MFM_Team__c = 'ABCD';
        System.debug(user2.ASI_MFM_Country__c);
        system.debug(user2.userRole.developerName);
        user2.ASI_MFM_Country__c ='CN';
        users.add(user2);
        
        User user1 = ASI_MFM_Function.getSystemAdminUser();
        user1.ASI_MFM_Team__c = 'ABCD';
        System.debug(user1.ASI_MFM_Country__c);
        system.debug(user1.userRole.developerName);
        user1.ASI_MFM_Country__c ='CN';
        user1.managerid = user2.id;
        users.add(user1);
        
        update users;*/
    
        System.runAs(user1){
        
            String strRTID;            
            
            list<ASI_MFM_Prefix__c> prefixs = new list<ASI_MFM_Prefix__c>();
            prefixs.add(new ASI_MFM_Prefix__c(Name='CN',ASI_MFM_Module__c='Plan',Plan_Type__c='Allowance & Discount Spending Form'
            ,ASI_MFM_Fiscal_year__c='FY1314',ownerId = user1.id));
            
            //create prefix po
            strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_Prefix__c','ASI_MFM_CN_Prefix');
            prefixs.add(new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO', recordTypeId=strRTID,
                                                        ASI_MFM_Fiscal_year__c='FY1314', ASI_MFM_Next_Number__c=86));
            insert prefixs;
            
            list<ASI_MFM_Role_Prefix_Relationship__c> prefixChilds = new list<ASI_MFM_Role_Prefix_Relationship__c>();
            prefixChilds.Add(new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c = prefixs[0].Id,
            ASI_MFM_Role_Name__c =user1.userRole.developerName));            
            prefixChilds.Add(new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c = prefixs[1].Id,
            ASI_MFM_Role_Name__c =user1.userRole.developerName));            
            
            insert prefixChilds;
            
            strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_A_C_Code__c','ASI_MFM_CN_A_C_Code');
            list<ASI_MFM_A_C_Code__c> acs = new list<ASI_MFM_A_C_Code__c>();
            acs.add(new ASI_MFM_A_C_Code__c(recordtypeid=strRTId, name='testAC1', ASI_MFM_A_C_Code__c = '5600.000'));
            acs.add(new ASI_MFM_A_C_Code__c(recordtypeid=strRTId, name='testAC2', ASI_MFM_A_C_Code__c = '5600.300'));
            acs.add(new ASI_MFM_A_C_Code__c(name='testAC', recordtypeid=strRTId ));
            insert acs;
            
            strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_PP_Category__c','ASI_MFM_CN_PP_Category');   
            ASI_MFM_PP_Category__c ppc = new ASI_MFM_PP_Category__c(recordtypeid=strRTId , Name='NTMCD - KTV Promotion', ASI_MFM_External_ID__c='NTMCD - KTV Promotion (CN)1');
            insert ppc;
            
            strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_PP_Category_A_C__c','ASI_MFM_CN_PP_Category_A_C'); 
            list<ASI_MFM_PP_Category_A_C__c> ppcacs = new list<ASI_MFM_PP_Category_A_C__c>();
            ppcacs.add(new ASI_MFM_PP_Category_A_C__c(ASI_MFM_External_ID__c='test', recordtypeid=strRTId , ASI_MFM_A_C_Code__c=acs[0].id, ASI_MFM_PP_Category__c=ppc.id));
            ppcacs.add(new ASI_MFM_PP_Category_A_C__c(ASI_MFM_External_ID__c='test2', recordtypeid=strRTId , ASI_MFM_A_C_Code__c=acs[1].id,ASI_MFM_PP_Category__c=ppc.id));
            insert ppcacs; 
            
            ASI_MFM_Market_Strategy__c mms = new ASI_MFM_Market_Strategy__c(name='12004 Chivas', ASI_MFM_External_ID__c='120041',ASI_MFM_Fiscal_Year__c='FY1213', ASI_MFM_Sub_brand__c='CH2,CH3,CHF,CHU');
            insert mms;
            
            strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_Plan__c','ASI_MFM_CN_Plan'); 
            ASI_MFM_Plan__c Plan1 = new ASI_MFM_Plan__c(Name='CNM131',ASI_MFM_Prefix__c=prefixs[0].Id
            ,recordTypeId=strRTId ,
            ASI_MFM_End_Date__c = Date.today().addMonths(1), ASI_MFM_Plan_Description__c='testDescription', 
            ASI_MFM_Plan_Name__c='plannameTest', ASI_MFM_Start_Date__c=Date.today(), ASI_MFM_Budget_Owner__c=user1.id, 
            ASI_MFM_PP_Category__c = ppc.id, ASI_MFM_Market_Strategy__c=mms.id, ASI_MFM_Status__c='Final', OwnerId =user1.id);
            insert Plan1;
            
            //create brand
            strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_Brand__c','ASI_MFM_CN_Brand');
            ASI_MFM_Brand__c brand = new ASI_MFM_Brand__c(name='brandname',Recordtypeid=strRTId);
            insert brand; 
     
            list<ASI_MFM_Sub_brand__c> subBrands = new list<ASI_MFM_Sub_brand__c>();
            strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_Sub_brand__c','ASI_MFM_CN_Sub_Brand');
            subBrands.add(new ASI_MFM_Sub_brand__c(Name='subBrand1' ,recordTypeId=strRTId));
            subBrands.add(new ASI_MFM_Sub_brand__c(Name='subBrand2' ,recordTypeId=strRTId));
            subBrands.add(new ASI_MFM_Sub_brand__c(Name='testSb',recordtypeid=strRTId,ASI_MFM_Brand__c=brand.id));
            insert subBrands;
                       
            list<Account> accs = new list<Account>();
            
            strRTId = ASI_MFM_Function.checkRecordType('Account','ASI_MFM_CN_Outlet'); 
            accs.add(new Account(recordTypeId=strRTId ,Name='Name3'));
            
             //ASI_MFM_CN_Supplier 
            strRTId = ASI_MFM_Function.checkRecordType('Account','ASI_MFM_CN_Supplier'); 
            accs.add(new Account(Name='TestAcc', recordTypeId=strRTId , ASI_MFM_Customer_Supplier_Number__c='123',
                                    ASI_MFM_Customer_Supplier_Name__c='SupplierName'));
            insert accs;
            
            strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_Plan_Line_Item__c','ASI_MFM_CN_Plan_Line_Item');
            ASI_MFM_Plan_Line_Item__c planLineItem1 = new ASI_MFM_Plan_Line_Item__c(ASI_MFM_Plan__c = Plan1.id
            ,ASI_MFM_Sub_brand_Code__c = subBrands[2].id,ASI_MFM_List_Item_Description__c='hello1'
            ,recordTypeId=strRTId , ASI_MFM_Total_Cost__c =120000,
            ASI_MFM_A_C_Code__c=acs[2].id
            );
            insert planLineItem1; 
            
            //create BU Code
            strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_BU__c','ASI_MFM_CN_BU');
            ASI_MFM_BU__c bu = new ASI_MFM_BU__c(Name='BUCode', ASI_MFM_BU_Code__c=strRTId , ASI_MFM_CN_Country__c='CN',
                                                ASI_MFM_Base_Currency__c='RMB');
            insert bu;
            
            
            
            //create exchange rate reference
            ASI_MFM_Exchange_Rate__c ex = new ASI_MFM_Exchange_Rate__c(ASI_MFM_Country__c='CN',ASI_MFM_Effective_Date__c=Date.valueof('2014-01-01'),
                                                                       ASI_MFM_Exchange_Rate__c=7.77500, ASI_MFM_Counter_Currency__c='USD', ASI_MFM_Base_Currency__c='RMB',
                                                                       ASI_MFM_Application__c='MFM' );
            insert ex;
            
            strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_PO__c','ASI_MFM_CN_PO');
            ASI_MFM_PO__c po = new ASI_MFM_PO__c(Name='PO11111', RecordTypeId=strRTId , ASI_MFM_Prefix__c=prefixs[1].id, ASI_MFM_Remarks__c='Remarks',
                                                ASI_MFM_BU_Code__c=bu.id, ASI_MFM_Supplier_Name__c=accs[1].id, ASI_MFM_Currency__c='USD',
                                                ASI_MFM_PO_Start_Date__c=Date.valueof('2014-04-01'),ASI_MFM_PO_End_Date__c=Date.valueof('2014-04-30'),
                                                ASI_MFM_Budget_Owner__c =user1.id, ASI_MFM_Plan__c=Plan1.id );
            insert po;
            
            
            //create po line item
            strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_PO_Line_Item__c','ASI_MFM_CN_PO_Line_Item');
            ASI_MFM_PO_Line_Item__c poli = new ASI_MFM_PO_Line_Item__c(RecordTypeId=strRTId, ASI_MFM_PO__c=po.id, ASI_MFM_G_L_Date__c=date.valueof('2014-04-03'),ASI_MFM_Sub_brand_Code__c=subBrands[2].id,
                                                                       ASI_MFM_A_C_Code__c = acs[2].id, ASI_MFM_Customer_Name__c=accs[0].id,
                                                                      ASI_MFM_Spread_by_Months__c=true,ASI_MFM_Amount__c=1,ASI_MFM_PO_Remark__c='Remarks');

            Test.startTest();

            list<ASI_MFM_PO_Line_Item__c> lineItems = new list<ASI_MFM_PO_Line_Item__c>();
            lineItems.add(poli);
            map<Id, ASI_MFM_PO_Line_Item__c> mapLineItems = new map<Id, ASI_MFM_PO_Line_Item__c>();
            mapLineItems.put(poli.Id, poli);
            ASI_MFM_POLineItem_TriggerClass.routineBeforeDelete(lineItems);
            ASI_MFM_POLineItem_TriggerClass.routineBeforeInsert(lineItems);
            ASI_MFM_POLineItem_TriggerClass.routineBeforeUpsert(lineItems, mapLineItems);
            ASI_MFM_POLineItem_TriggerClass.routineAfterUpsert(lineItems, mapLineItems);
            ASI_MFM_POLineItem_TriggerClass.routineAfterAll(lineItems, mapLineItems);
            ASI_MFM_POLineItem_TriggerClass.routineAfterAll(null, mapLineItems);
            
            list<ASI_MFM_BU__c> bu_list =new list<ASI_MFM_BU__c> ();
            bu_list.add(new ASI_MFM_BU__c());
            ASI_MFM_POLineItem_TriggerClass.setDefaultBUCode(lineItems, bu_list);
            Test.stopTest();

        }
    }    
    
}