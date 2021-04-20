@isTest
public class ASI_MFM_CN_MassCreateAndUpdateExt_Test {

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
    
    public class PoTestObj {
        public Date thisMonth;
        public Date midThisMonth;
        public Date nextMonth;
        public String fy;
        public ASI_MFM_Market_Strategy__c ms;
        public User User1;
        public User User2;
        public  List<User> lstUsr;
        public list<ASI_MFM_Prefix__c> prefixs;
        public list<ASI_MFM_Role_Prefix_Relationship__c> prefixChilds;
        public list<ASI_MFM_A_C_Code__c> acs;
        public ASI_MFM_PP_Category__c ppc;
        public list<ASI_MFM_PP_Category_A_C__c> ppcacs;
        public ASI_MFM_Market_Strategy__c mms;
        public List<ASI_MFM_Plan__c> plans;
        public ASI_MFM_Plan__c Plan1;
        public ASI_MFM_Brand__c brand;
        public list<ASI_MFM_Sub_brand__c> subBrands;
        public list<Account> accs;
        public ASI_MFM_Plan_Line_Item__c planLineItem1;
        public ASI_MFM_BU__c bu;
        public ASI_MFM_Exchange_Rate__c ex;
        public list<ASI_MFM_PO__c> pos;
        public list<ASI_MFM_PO_Line_Item__c> polis;
        public ASI_MFM_PO_Receipt__c pOReceipt;
        public ASI_MFM_PO_Receipt_Item__c poreceiptItem;
        

        
        public PoTestObj() {
            ms = new ASI_MFM_Market_Strategy__c(Name='99999 Malibu', ASI_MFM_Active__c=true, ASI_MFM_Fiscal_Year__c='FY1213');
            lstUsr = new List<User>();
            User1 = new User(managerid = UserInfo.getUserId(), ASI_MFM_Team__c = 'ABCD', ASI_MFM_Country__c ='CN', alias = 'test99',ASI_MFM_Bypass_Callouts__c = true, email='test99' + '@dev.com', emailencodingkey='UTF-8', firstname='test99', lastname='Testing', languagelocalekey='en_US', localesidkey='en_US', timezonesidkey='Europe/London', username='test99' + '@pernod-ricard.com',ProfileId = UserInfo.getProfileId(), UserRoleId = UserInfo.getUserRoleId(), isActive=true);
            User2 = new User(managerid = UserInfo.getUserId(), ASI_MFM_Team__c = 'ABCD', ASI_MFM_Country__c ='CN', alias = 'tes99',ASI_MFM_Bypass_Callouts__c = true, email='tes99' + '@dev.com', emailencodingkey='UTF-8', firstname='tes99', lastname='Testing', languagelocalekey='en_US', localesidkey='en_US', timezonesidkey='Europe/London', username='tes99' + '@pernod-ricard.com',ProfileId = UserInfo.getProfileId(), UserRoleId = UserInfo.getUserRoleId(), isActive=true);
            lstUsr.add(user1);
            lstUsr.add(user2);
            insert lstUsr;
            
			for(user u : [SELECT Id, Name, ManagerId, ASI_MFM_Bypass_Callouts__c, ASI_MFM_Country__c, UserRole.DeveloperName 
                          FROM User
                          WHERE id =: user1.id OR id =: user2.id 
                          LIMIT 2]
           	){
                if(user1.id == u.id){
                    user1 = u;
                }else{
                    user2 = u;
               	}
           	}
            
            System.runAs(user1){
                thisMonth = Date.today().toStartOfMonth();
                midThisMonth = thisMonth.addDays(10);
                nextMonth = thisMonth.addMonths(1).addDays(-1);
                fy = ASI_MFM_CN_MassCreateAndUpdateExt_Test.getFiscalYear();
                
                String strRTID;
                
                prefixs = new list<ASI_MFM_Prefix__c>();
                prefixs.add(new ASI_MFM_Prefix__c(Name='CN',ASI_MFM_Module__c='Plan',Plan_Type__c='Allowance & Discount Spending Form'
                                                  ,ASI_MFM_Fiscal_year__c=fy,ownerId = user1.id));
                
                //create prefix po
                strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_Prefix__c','ASI_MFM_CN_Prefix');
                prefixs.add(new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO', recordTypeId=strRTID,
                                                  ASI_MFM_Fiscal_year__c=fy, ASI_MFM_Next_Number__c=86));
                insert prefixs;
                
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
                
                mms = new ASI_MFM_Market_Strategy__c(name='12004 Chivas', ASI_MFM_External_ID__c='120041',ASI_MFM_Fiscal_Year__c='FY1213', ASI_MFM_Sub_brand__c='CH2,CH3,CHF,CHU');
                insert mms;
                
                plans = new List<ASI_MFM_Plan__c>();
                strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_Plan__c','ASI_MFM_CN_Plan');
                Plan1 = new ASI_MFM_Plan__c(Name='CNM131',ASI_MFM_Prefix__c=prefixs[0].Id
                                                            ,recordTypeId=strRTId ,
                                                            ASI_MFM_End_Date__c = nextMonth, ASI_MFM_Plan_Description__c='testDescription', 
                                                            ASI_MFM_Plan_Name__c='plannameTest', ASI_MFM_Start_Date__c=thisMonth, ASI_MFM_Budget_Owner__c=user1.id, 
                                                            ASI_MFM_PP_Category__c = ppc.id, ASI_MFM_Market_Strategy__c=mms.id, ASI_MFM_Status__c='Final', OwnerId =user1.id);
                plans.add(Plan1);
                insert plans;
                
                
                //create brand
                strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_Brand__c','ASI_MFM_CN_Brand');
                brand = new ASI_MFM_Brand__c(name='brandname',Recordtypeid=strRTId);
                insert brand; 
                
                subBrands = new list<ASI_MFM_Sub_brand__c>();
                //create sub brand
                strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_Sub_brand__c','ASI_MFM_CN_Sub_brand');
                subBrands.add(new ASI_MFM_Sub_brand__c(Name='subBrand1' ,recordTypeId=strRTId, ASI_MFM_Active_for_MFM__c=true));
                subBrands.add(new ASI_MFM_Sub_brand__c(Name='subBrand2' ,recordTypeId=strRTId, ASI_MFM_Active_for_MFM__c=true));
                subBrands.add(new ASI_MFM_Sub_brand__c(Name='testSb',recordtypeid=strRTId,ASI_MFM_Brand__c=brand.id));
                
                insert subBrands;
                

                accs = new list<Account>();
                
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
                planLineItem1 = new ASI_MFM_Plan_Line_Item__c(ASI_MFM_Plan__c = Plan1.id
                                                                                        ,ASI_MFM_Sub_brand_Code__c = subBrands[2].id,ASI_MFM_List_Item_Description__c='hello1'
                                                                                        ,recordTypeId=strRTId , ASI_MFM_Total_Cost__c =10,ASI_MFM_Remaining_Balance__c=-1,
                                                                                        ASI_MFM_A_C_Code__c=acs[2].id
                                                                                       );
                insert planLineItem1; 
                
                //create BU Code
                strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_BU__c','ASI_MFM_CN_BU');
                bu = new ASI_MFM_BU__c(Name='BUCode', ASI_MFM_BU_Code__c=strRTId , ASI_MFM_CN_Country__c='CN',
                                                     ASI_MFM_Base_Currency__c='RMB',recordTypeId=strRTId);
                insert bu;
                
                
                
                //create exchange rate reference
                ex = new ASI_MFM_Exchange_Rate__c(ASI_MFM_Country__c='CN',ASI_MFM_Effective_Date__c=thisMonth,
                                                                           ASI_MFM_Exchange_Rate__c=7.77500, ASI_MFM_Counter_Currency__c='USD', ASI_MFM_Base_Currency__c='RMB',
                                                                           ASI_MFM_Application__c='MFM' );
                insert ex;
                
                //create po
                strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_PO__c','ASI_MFM_CN_PO');
                pos = new list<ASI_MFM_PO__c>();
                
                pos.add(new ASI_MFM_PO__c(Name='PO66666', RecordTypeId=strRTId , ASI_MFM_Prefix__c=prefixs[1].id, ASI_MFM_Remarks__c='Remarks',
                                          ASI_MFM_BU_Code__c=bu.id, ASI_MFM_Supplier_Name__c=accs[2].id, ASI_MFM_Currency__c='RMB',
                                          ASI_MFM_PO_Start_Date__c=thisMonth,ASI_MFM_PO_End_Date__c=nextMonth,
                                          ASI_MFM_Budget_Owner__c =user2.id, ASI_MFM_Plan__c=Plan1.id, ASI_MFM_Status__c='Draft',
                                          ASI_MFM_CN_BU_Picklist__c='PRCN'
                                         ));
                insert pos;
                
                
                
                
                //create po line item
                strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_PO_Line_Item__c','ASI_MFM_CN_PO_Line_Item');
                polis = new list<ASI_MFM_PO_Line_Item__c>(); 
                polis.add(new ASI_MFM_PO_Line_Item__c(RecordTypeId=strRTId, ASI_MFM_PO__c=pos[0].id, ASI_MFM_G_L_Date__c=midThisMonth,ASI_MFM_Sub_brand_Code__c=subBrands[2].id,
                                                      ASI_MFM_Amount__c  = 20,ASI_MFM_Plan_Line_Item__c = planLineItem1.id,
                                                      ASI_MFM_A_C_Code__c = acs[2].id, ASI_MFM_Customer_Name__c=accs[0].id,ASI_MFM_PO_Remark__c='Remarks'  ));
                
                insert polis;
                
                //create receipt header
                strRTId = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Receipt__cASI_MFM_CN_PO_Receipt');
                
                pOReceipt = new ASI_MFM_PO_Receipt__c(ASI_MFM_Receipt_Date__c = date.today()
                                                                            , recordTypeId = strRTId
                                                                            , ASI_MFM_Auto_Receipt__c = True
                                                                           );
                insert pOReceipt;
                
                strRTId = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Receipt_Item__cASI_MFM_CN_PO_Receipt_item');
                poreceiptItem = new ASI_MFM_PO_Receipt_Item__c(ASI_MFM_Amount__c = 5
                                                                                          , recordTypeId = strRTId
                                                                                          , ASI_MFM_PO_Line_Item__c = polis[0].id
                                                                                          , ASI_MFM_Sub_brand_temp__c = polis[0].ASI_MFM_Sub_brand_Code__c
                                                                                          , ASI_MFM_A_C_Code_temp__c = polis[0].ASI_MFM_A_C_Code__c
                                                                                          , ASI_MFM_PO_Receipt__c = pOReceipt.id
                                                                                          , ASI_MFM_Auto_Receipt__c = True
                                                                                          , ASI_MFM_Receipt_Date__c = date.today()
                                                                                          , ASI_MFM_Currency_Temp__c = polis[0].ASI_MFM_Currency__c
                                                                                         );
                }
            
        }
    }
    
    static testMethod void testExtCommitAll(){
        ASI_MFM_CN_PO_SetPlan_TriggerClass.passTrigger = true;
		PoTestObj testObj = new PoTestObj();
        
        Date thisMonth = testObj.thisMonth;
        Date midThisMonth = testObj.midThisMonth;
        Date nextMonth = testObj.nextMonth;
        String fy = getFiscalYear();
        
        String strRTID;
        User User1 = testObj.lstUsr[0];
        User User2 = testObj.lstUsr[1];
        list<ASI_MFM_PO__c> pos = testObj.pos;
        ASI_MFM_PO_Receipt__c pOReceipt = testObj.pOReceipt;
        
        Id currentUID = UserInfo.getUserId();
        System.runAs(user1){
            Test.startTest();

            List<ASI_MFM_PO_Line_Item__c> polineItemList = testObj.polis;
            
            ASI_MFM_PO__c po = pos[0];
            
            Group objPGp = [SELECT id FROM group WHERE type='Regular' AND name = 'ASI MFM CN Regional User' Limit 1];            
            GroupMember gmember = new GroupMember(UserOrGroupId=user1.id, GroupId=objPGp.Id);
            insert gmember;
            
            list<ASI_MFM_Sub_brand__c> subBrands = testObj.subBrands;
            ASI_MFM_Sub_brand__c sb = subBrands[0];
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
            
            ASI_MFM_CN_MassCreateAndUpdateExtCtrl extCon = new ASI_MFM_CN_MassCreateAndUpdateExtCtrl(mcauCon);
            extCon.commitAll();
            extCon.last_plan_balance = -10;
            extCon.commitAll();
            extCon.last_plan_balance = -11;
            extCon.commitAll();
            extCon.last_planline_balanceMap.put(testObj.planLineItem1.id,-11);
            extCon.commitAll();
                     
            extCon.formatMsg('duplicate value found: ASI_MFM_Sys_Deduplication_Key__c');
            for(ASI_MFM_MassCreateAndUpdateController.RecordTypeElement rtEle :mcauCon.theRecordTypeElementList){
                for (ASI_MFM_MassCreateAndUpdateController.TableRow tr : rtEle.myRecordList) {
                    tr.isNew = true;
                }
            }
            extCon.commitAll();   
            
            for(ASI_MFM_MassCreateAndUpdateController.RecordTypeElement rtEle :mcauCon.theRecordTypeElementList){
                for (ASI_MFM_MassCreateAndUpdateController.TableRow tr : rtEle.myRecordList) {
                    tr.isEdit = true;
                    ((ASI_MFM_PO_Line_Item__c)tr.mySObj).ASI_MFM_Amount__c = 11;
                }
            }
            extCon.commitAll();  
/*
            for(ASI_MFM_MassCreateAndUpdateController.RecordTypeElement rtEle :mcauCon.theRecordTypeElementList){
                for (ASI_MFM_MassCreateAndUpdateController.TableRow tr : rtEle.myRecordList) {
                    tr.isDelete = true;
                }
            }
            extCon.commitAll();
            Test.stopTest();
*/
        }
    }

    static testMethod void testExtCommitAll2(){
        ASI_MFM_CN_PO_SetPlan_TriggerClass.passTrigger = true;
		PoTestObj testObj = new PoTestObj();

        Date thisMonth = testObj.thisMonth;
        Date midThisMonth = testObj.midThisMonth;
        Date nextMonth = testObj.nextMonth;
        String fy = getFiscalYear();
        
        String strRTID;
        User User1 = testObj.lstUsr[0];
        User User2 = testObj.lstUsr[1];
        list<ASI_MFM_PO__c> pos = testObj.pos;
        ASI_MFM_PO_Receipt__c pOReceipt = testObj.pOReceipt;
        
        Id currentUID = UserInfo.getUserId();
        System.runAs(user1){
            testObj.subBrands[0].recordTypeId = ASI_MFM_Function.checkRecordType('ASI_MFM_Sub_brand__c','ASI_FOC_CN_Sub_brand');
            testObj.subBrands[1].recordTypeId = ASI_MFM_Function.checkRecordType('ASI_MFM_Sub_brand__c','ASI_FOC_CN_Sub_brand');
            testObj.subBrands[2].recordTypeId = ASI_MFM_Function.checkRecordType('ASI_MFM_Sub_brand__c','ASI_FOC_CN_Sub_brand');
            update testObj.subBrands;
            Test.startTest();


            List<ASI_MFM_PO_Line_Item__c> polineItemList = testObj.polis;
            
            ASI_MFM_PO__c po = pos[0];
            
            Group objPGp = [SELECT id FROM group WHERE type='Regular' AND name = 'ASI MFM CN Regional User' Limit 1];            
            GroupMember gmember = new GroupMember(UserOrGroupId=user1.id, GroupId=objPGp.Id);
            insert gmember;
            
            list<ASI_MFM_Sub_brand__c> subBrands = testObj.subBrands;
            ASI_MFM_Sub_brand__c sb = subBrands[0];
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
                        
            ASI_MFM_CN_MassCreateAndUpdateExtCtrl extCon = new ASI_MFM_CN_MassCreateAndUpdateExtCtrl(mcauCon);
            //extCon.commitAll();

            for(ASI_MFM_MassCreateAndUpdateController.RecordTypeElement rtEle :mcauCon.theRecordTypeElementList){
                for (ASI_MFM_MassCreateAndUpdateController.TableRow tr : rtEle.myRecordList) {
                    tr.isDelete = true;
                }
            }
            extCon.commitAll();
            //mcauCon.clearAll();
            //extCon.commitAll();
            Test.stopTest();
        }
    }
    
    static testMethod void testExtCommitAll3(){
        ASI_MFM_CN_PO_SetPlan_TriggerClass.passTrigger = true;
		PoTestObj testObj = new PoTestObj();

        Date thisMonth = testObj.thisMonth;
        Date midThisMonth = testObj.midThisMonth;
        Date nextMonth = testObj.nextMonth;
        String fy = getFiscalYear();
        
        String strRTID;
        User User1 = testObj.lstUsr[0];
        User User2 = testObj.lstUsr[1];
        list<ASI_MFM_PO__c> pos = testObj.pos;
        ASI_MFM_PO_Receipt__c pOReceipt = testObj.pOReceipt;
        
        Id currentUID = UserInfo.getUserId();
        System.runAs(user1){
            testObj.subBrands[0].recordTypeId = ASI_MFM_Function.checkRecordType('ASI_MFM_Sub_brand__c','ASI_FOC_CN_Sub_brand');
            testObj.subBrands[1].recordTypeId = ASI_MFM_Function.checkRecordType('ASI_MFM_Sub_brand__c','ASI_FOC_CN_Sub_brand');
            testObj.subBrands[2].recordTypeId = ASI_MFM_Function.checkRecordType('ASI_MFM_Sub_brand__c','ASI_FOC_CN_Sub_brand');
            update testObj.subBrands;
            Test.startTest();


            List<ASI_MFM_PO_Line_Item__c> polineItemList = testObj.polis;
            
            ASI_MFM_PO__c po = pos[0];
            
            Group objPGp = [SELECT id FROM group WHERE type='Regular' AND name = 'ASI MFM CN Regional User' Limit 1];            
            GroupMember gmember = new GroupMember(UserOrGroupId=user1.id, GroupId=objPGp.Id);
            insert gmember;
            
            list<ASI_MFM_Sub_brand__c> subBrands = testObj.subBrands;
            ASI_MFM_Sub_brand__c sb = subBrands[0];
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
                        
            ASI_MFM_CN_MassCreateAndUpdateExtCtrl extCon = new ASI_MFM_CN_MassCreateAndUpdateExtCtrl(mcauCon);
            extCon.commitAll();

            for(ASI_MFM_MassCreateAndUpdateController.RecordTypeElement rtEle :mcauCon.theRecordTypeElementList){
                for (ASI_MFM_MassCreateAndUpdateController.TableRow tr : rtEle.myRecordList) {
                    tr.isDelete = true;
                }
            }
            extCon.commitAll();
            mcauCon.clearAll();
            extCon.commitAll();
            Test.stopTest();
        }
    }
    
    static testMethod void testExtCommitAll4(){
        ASI_MFM_CN_PO_SetPlan_TriggerClass.passTrigger = true;
		PoTestObj testObj = new PoTestObj();

        Date thisMonth = testObj.thisMonth;
        Date midThisMonth = testObj.midThisMonth;
        Date nextMonth = testObj.nextMonth;
        String fy = getFiscalYear();
        
        String strRTID;
        User User1 = testObj.lstUsr[0];
        User User2 = testObj.lstUsr[1];
        list<ASI_MFM_PO__c> pos = testObj.pos;
        ASI_MFM_PO_Receipt__c pOReceipt = testObj.pOReceipt;
        
        Id currentUID = UserInfo.getUserId();
        System.runAs(user1){
            testObj.subBrands[0].recordTypeId = ASI_MFM_Function.checkRecordType('ASI_MFM_Sub_brand__c','ASI_FOC_CN_Sub_brand');
            testObj.subBrands[1].recordTypeId = ASI_MFM_Function.checkRecordType('ASI_MFM_Sub_brand__c','ASI_FOC_CN_Sub_brand');
            testObj.subBrands[2].recordTypeId = ASI_MFM_Function.checkRecordType('ASI_MFM_Sub_brand__c','ASI_FOC_CN_Sub_brand');
            update testObj.subBrands;
            Test.startTest();


            List<ASI_MFM_PO_Line_Item__c> polineItemList = testObj.polis;
            
            ASI_MFM_PO__c po = pos[0];
            
            Group objPGp = [SELECT id FROM group WHERE type='Regular' AND name = 'ASI MFM CN Regional User' Limit 1];            
            GroupMember gmember = new GroupMember(UserOrGroupId=user1.id, GroupId=objPGp.Id);
            insert gmember;
            
            list<ASI_MFM_Sub_brand__c> subBrands = testObj.subBrands;
            ASI_MFM_Sub_brand__c sb = subBrands[0];
            ASI_MFM_Sub_brand_Allocation__c sbAllocation = new ASI_MFM_Sub_brand_Allocation__c(Name='Test',ASI_MFM_Sub_brand_percentage__c=1, ASI_MFM_PO__c=po.id, ASI_MFM_Sub_brand_Code__c=sb.id, recordtypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand_Allocation__cASI_MFM_CN_Sub_Brand_Allocation'));
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
            
            ASI_MFM_CN_MassCreateAndUpdateExtCtrl extCon = new ASI_MFM_CN_MassCreateAndUpdateExtCtrl(mcauCon);
            extCon.commitAll();

            Test.stopTest();
        }
    }
    
    static testMethod void testExtCommitAllPayment(){
        ASI_MFM_CN_PO_SetPlan_TriggerClass.passTrigger = true;
        PoTestObj testObj = new PoTestObj();
        
        Date thisMonth = testObj.thisMonth;
        Date midThisMonth = testObj.midThisMonth;
        Date nextMonth = testObj.nextMonth;
        String fy = getFiscalYear();
        
        String strRTID;
        User User1 = testObj.lstUsr[0];
        User User2 = testObj.lstUsr[1];
        list<ASI_MFM_PO__c> pos = testObj.pos;
        ASI_MFM_PO_Receipt__c pOReceipt = testObj.pOReceipt;
        
        Id currentUID = UserInfo.getUserId();
        System.runAs(user1){
            Test.startTest();
            
            List<ASI_MFM_PO_Line_Item__c> polineItemList = testObj.polis;
            
            ASI_MFM_PO__c po = pos[0];
            
            user u = testObj.User1;
            
            Group objPGp = [SELECT id FROM group WHERE type='Regular' AND name = 'ASI MFM CN Regional User' Limit 1];            
            GroupMember gmember = new GroupMember(UserOrGroupId=user1.id, GroupId=objPGp.Id);
            insert gmember;
            
            list<ASI_MFM_Sub_brand__c> subBrands = testObj.subBrands;
            ASI_MFM_Sub_brand__c sb = subBrands[0];
            ASI_MFM_Sub_brand_Allocation__c sbAllocation = new ASI_MFM_Sub_brand_Allocation__c(Name='Test', ASI_MFM_PO__c=po.id, ASI_MFM_Sub_brand_Code__c=sb.id, recordtypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand_Allocation__cASI_MFM_CN_Sub_Brand_Allocation'));
            insert sbAllocation;
            
            map<string, id> rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Payment__c');
            
            strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_Prefix__c','ASI_MFM_CN_Prefix');
			ASI_MFM_Prefix__c pxa = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Payment', recordTypeId=strRTID,
                                                  ASI_MFM_Fiscal_year__c=fy, ASI_MFM_Next_Number__c=88,ownerId=u.id);
            insert pxa;
            
            ASI_MFM_Role_Prefix_Relationship__c pra = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxa.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
            
            insert pra;  
            
            List<ASI_MFM_Payment__c> pyList = new List<ASI_MFM_Payment__c>();
            
            strRTId = Global_RecordTypeCache.getRtId('ASI_MFM_Payment__cASI_MFM_CN_Payment');
            ASI_MFM_Payment__c py = new ASI_MFM_Payment__c(ASI_MFM_Payment_Amount__c =10000,OwnerID = user2.id, ASI_MFM_CN_Tax_Code_Picklist__c = '6%', ASI_MFM_Payment_Date__c = date.today(), ASI_MFM_Status__c = 'Final', ASI_MFM_Prefix__c=pxa.id, recordtypeid = strRTId,ASI_MFM_Budget_Owner__c=testObj.user1.id, ASI_MFM_Supplier_Name__c=testObj.accs[1].id, ASI_MFM_BU__c=testObj.bu.id, ASI_MFM_Currency__c='RMB', ASI_MFM_Sys_Local_Currency__c = 'RMB');
            pyList.add(py);
            pyList.add(new ASI_MFM_Payment__c(recordTypeId=rt_map.get('ASI_MFM_CN_Payment'), ASI_MFM_Prefix__c=pxa.id, name='test', ASI_MFM_Supplier_Name__c = testObj.accs[2].id,ownerId=u.id,ASI_MFM_Status__c='Final'));
            insert pyList;
            
            
            
            
			strRTId = Global_RecordTypeCache.getRtId('ASI_MFM_Payment_Line_Item__cASI_MFM_CN_Payment_Line_Item');
            List<ASI_MFM_Payment_Line_Item__c> palList = new List<ASI_MFM_Payment_Line_Item__c>();
            ASI_MFM_Payment_Line_Item__c payli1 = new ASI_MFM_Payment_Line_Item__c(ASI_MFM_Sub_brand__c = testObj.subBrands[0].id, ASI_MFM_Payment_Amount__c = 150, ASI_MFM_Paid_Amount_in_PO_Currency__c = 150, ASI_MFM_Tax_Amount__c = 1, RecordTypeId=strRTId, ASI_MFM_PO_Line_Item__c=testObj.polis[0].id, ASI_MFM_Payment__c = py.id);
            ASI_MFM_Payment_Line_Item__c payli2 = new ASI_MFM_Payment_Line_Item__c(ASI_MFM_Sub_brand__c = testObj.subBrands[0].id, ASI_MFM_Payment_Amount__c = 150, ASI_MFM_Paid_Amount_in_PO_Currency__c = 150, ASI_MFM_Tax_Amount__c = 1, RecordTypeId=strRTId, ASI_MFM_PO_Line_Item__c=testObj.polis[0].id, ASI_MFM_Payment__c = pyList[1].id);
            palList.add(payli1);
            palList.add(payli2);
            insert palList;

            
			system.debug('@@@@'+[SELECT id,ASI_MFM_Remaining_Balance__c FROM  ASI_MFM_PO_Line_Item__c WHERE id = :testObj.polis[0].id]);
            
            list<ASI_MFM_Payment_Line_Item__c> pyi_list = new list<ASI_MFM_Payment_Line_Item__c>();
            pyi_list.add(payli1);
            pyi_list.add(payli2);
            ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(pyi_list);
            
            // Initialize the page
            PageReference testPage = Page.ASI_MFM_HK_InputPaymentItemsPage;
            Map<String, String> pageParams = testPage.getParameters();
            pageParams.put('id', py.Id);
            Test.setCurrentPageReference(testPage);
            ASI_MFM_HK_InputPaymentItemsController testCon = new ASI_MFM_HK_InputPaymentItemsController(stdSetController);
            ASI_MFM_MassCreateAndUpdateController mcauCon = new ASI_MFM_MassCreateAndUpdateController();
            ASI_MFM_SFObjSelectTableController sobjstCon = new ASI_MFM_SFObjSelectTableController();
            
            // Assign component attributes
            mcauCon.isFastModeBool = false;
            mcauCon.sObjTypeStr = 'ASI_MFM_Payment_Line_Item__c';
            mcauCon.displayFieldsStr = 'ASI_MFM_PO_Line_Item__c&req=T&read=O, ASI_MFM_Payee__c&req=F&width=150px, ASI_MFM_Payment_Amount__c&req=F, ASI_MFM_Invoice_Number__c&req=F, ASI_MFM_Invoice_Date__c&req=F';
            mcauCon.fieldToURLParamStr = 'ASI_MFM_Payment__c=>id';
            mcauCon.whereStatm = 'ASI_MFM_Payment__c = \'' + py.Id + '\'';
            mcauCon.orderByStr = 'Name';
            mcauCon.pageBlockTitleStr = 'Payment Line Items';
            mcauCon.successLink = '/' + py.Id;
            mcauCon.cancelLink = '/' + py.Id;
            mcauCon.mode = 'BOTH';
            mcauCon.isDefaultEditVal = true;
            mcauCon.ShowAllRT = true;
            mcauCon.isUseFirstRowForNew = true;
            mcauCon.ComponentKey = 'massCreateAndUpdate';
            mcauCon.PageController = testCon.thisController;
            mcauCon.lookupToPicklist = 'hello,world';
            
            sobjstCon.sObjTypeStr = 'ASI_MFM_PO_Line_Item__c';
            sobjstCon.displayFieldsStr = 'Name, ASI_MFM_PO__c, ASI_MFM_Sub_brand_Code__c, ASI_MFM_A_C_Code__c, ASI_MFM_List_Item_Description__c, ASI_MFM_Currency__c, ASI_MFM_PO_Original_Amount__c, ASI_MFM_Remaining_Balance__c';
            
            
            sobjstCon.defWhereStatmStr = null;
            sobjstCon.orderByStr = 'ASI_MFM_PO__c';
            sobjstCon.numOfRowInTable = 8;
            sobjstCon.ComponentKey = 'selectTable';
            sobjstCon.PageController = testCon.thisController;
            
            Boolean initPageBool = mcauCon.dummyVar;
            initPageBool = sobjstCon.initDummyVar;
            
            System.debug('********18.Number of Queries used in this apex code so far: ' + Limits.getQueries() + '**********');
            
            // Start testing user actions
            pageParams.put(mcauCon.PARAM_RTID, 'ASI_MFM_CN_Payment_Line_Item');
            
            integer recordIndex= 0;
            for (integer i = 0; i< mcauCon.theRecordTypeElementList.size(); i++)
            {
                system.debug('mcauCon.theRecordTypeElementList IS ' +  mcauCon.theRecordTypeElementList.get(i));
                if (mcauCon.theRecordTypeElementList.get(i).myRecordList.size() > 0)
                {
                    system.debug('ID IS ' +  mcauCon.theRecordTypeElementList.get(i).myRecordList.get(0).id);
                    system.debug(' mcauCon.theRecordTypeElementList.get(i).myRecordList.get(0) IS ' +  mcauCon.theRecordTypeElementList.get(i).myRecordList.get(0));
                    
                    recordIndex = i;
                    break;
                    
                }
            }
            
            
            System.debug('********19.Number of Queries used in this apex code so far: ' + Limits.getQueries() + '**********');
            
            pageParams.put(mcauCon.PARAM_TRID, mcauCon.theRecordTypeElementList.get(recordIndex).myRecordList.get(0).id);     
            
            ASI_MFM_CN_MassCreateAndUpdateExtCtrl extCon = new ASI_MFM_CN_MassCreateAndUpdateExtCtrl(mcauCon);
            extCon.commitAll();

            Test.stopTest();
        }
    }
    
    
}