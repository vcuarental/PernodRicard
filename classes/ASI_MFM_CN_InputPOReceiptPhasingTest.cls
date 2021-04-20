@isTest
public class ASI_MFM_CN_InputPOReceiptPhasingTest {
    
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
    
    static testmethod void ASI_MFM_InputPhasing_TEST(){
        String fyear = getFiscalYear();
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
        
        String strRTID;
        
        list<ASI_MFM_Prefix__c> prefixs = new list<ASI_MFM_Prefix__c>();
        
        system.runAs(user1) {
            //AM@Introv 20190626 - set bypass
            //ASI_MFM_CN_PO_SetPlan_TriggerClass.passTrigger = true; 
            
            prefixs.add(new ASI_MFM_Prefix__c(Name='CN',ASI_MFM_Module__c='Plan',Plan_Type__c='Allowance & Discount Spending Form'
                                              ,ASI_MFM_Fiscal_year__c=fyear,ownerId = user1.id));
            
            //create prefix po
            strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_Prefix__c','ASI_MFM_CN_Prefix');
            prefixs.add(new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO', recordTypeId=strRTID,
                                              ASI_MFM_Fiscal_year__c=fyear, ASI_MFM_Next_Number__c=86));
            system.debug('recordTypeId: ' + strRTID);
            prefixs.add(new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO', recordTypeId=strRTID,
                                              ASI_MFM_Fiscal_year__c=fyear, ASI_MFM_Next_Number__c=86));
            
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
            Date today = Date.today();
            Date startDate;
            if(today.month() >=7) {
                startDate = Date.newInstance(today.year(), 7, 1);
            } else  {
                startDate = Date.newInstance(today.addYears(-1).year(), 7, 1);
            }
            Date endDate;
            if(today.month() >=7) {
                endDate = Date.newInstance(today.addYears(1).year(), 6, 30);
            } else  {
                endDate = Date.newInstance(today.year(), 6, 30);
            }
            
            strRTId =ASI_MFM_Function.checkRecordType('ASI_MFM_PO__c','ASI_MFM_CN_PO');
            ASI_MFM_PO__c po = new ASI_MFM_PO__c(Name='PO11111', RecordTypeId=strRTId , ASI_MFM_Prefix__c=prefixs[1].id, ASI_MFM_Remarks__c='Remarks',
                                                 ASI_MFM_BU_Code__c=bu.id, ASI_MFM_Supplier_Name__c=accs[1].id, ASI_MFM_Currency__c='USD',
                                                 ASI_MFM_PO_Start_Date__c=startDate,ASI_MFM_PO_End_Date__c=endDate,
                                                 ASI_MFM_Budget_Owner__c =user1.id, ASI_MFM_Plan__c=Plan1.id,
                                                 ASI_MFM_PO_Type__c='eMarket',ASI_MFM_Status__c='Final');
            insert po;
            
            
            //create po line item
            strRTId =ASI_MFM_Function.checkRecordType('ASI_MFM_PO_Line_Item__c','ASI_MFM_CN_PO_Line_Item');
            ASI_MFM_PO_Line_Item__c poli = new ASI_MFM_PO_Line_Item__c(RecordTypeId=strRTId, ASI_MFM_PO__c=po.id, ASI_MFM_G_L_Date__c=date.valueof('2014-04-03'),ASI_MFM_Sub_brand_Code__c=subBrands[2].id,
                                                                       ASI_MFM_A_C_Code__c = acs[2].id, ASI_MFM_Customer_Name__c=accs[0].id, ASI_MFM_Amount__c =510000  );
            insert poli;
            Test.startTest();
            
            ApexPages.currentPage().getParameters().put('id',po.Id);
            ApexPages.Standardcontroller stdController = new ApexPages.Standardcontroller(po);
            ASI_MFM_CN_InputPOReceiptPhasingCtl controller = new ASI_MFM_CN_InputPOReceiptPhasingCtl(stdController); 
            
            startDate.format();
            endDate.format();
            String submitStr = '{"submitedList":[{"amount1":43315.07,"amount2":39123.29,"amount3":43315.07,"amount4":41917.81,"amount5":43315.07,"amount6":28547.93,"amount7":0,"amount8":100000,"amount9":41917.81,"amount10":43315.07,"amount11":41917.81,"amount12":43315.07,"comment":"","total":510000,"version":1,"modify":"SYSTEM","postart":"'+startDate.format()+'","poend":"'+endDate.format()+'","id":"","poid":"'+po.id+'","rowcontrol":0,"approved":false},{"amount1":43315.07,"amount2":39123.29,"amount3":43315.07,"amount4":41917.81,"amount5":43315.07,"amount6":28547.93,"amount7":0,"amount8":100000,"amount9":41917.81,"amount10":43315.07,"amount11":41917.81,"amount12":43315.07,"comment":"","total":510000,"version":2,"modify":"Admin Introv 2","postart":"'+startDate.format()+'","poend":"'+endDate.format()+'","id":"","poid":"'+po.id+'","rowcontrol":0,"approved":false}],"deleteIdList":[],"poid":"'+po.id+'"}';
            ASI_MFM_CN_InputPOReceiptPhasingCtl.ResultObj resultObj = ASI_MFM_CN_InputPOReceiptPhasingCtl.validate(submitStr);
            system.debug('result : ' + JSON.serialize(resultObj));
            
            Id phasingRTID = Global_recordTypeCache.getRtId('ASI_MFM_PO_Receipt_Phasing__cASI_MFM_CN_PO_Receipt_Phasing');
            ASI_MFM_PO_Receipt_Phasing__c porp1 = new ASI_MFM_PO_Receipt_Phasing__c(
                ASI_MFM_Latest_Phasing__c = false,
                ASI_MFM_Version__c = '1',
                ASI_MFM_Comments__c = '',
                ASI_MFM_PO__c = po.id,
                ASI_MFM_Modify_BY__c = 'SYSTEM',
                ASI_MFM_PO_Approved__c = false,
                ASI_MFM_Allocated_Amount_1__c = 10000,
                ASI_MFM_Allocated_Amount_2__c = 10000,
                ASI_MFM_Allocated_Amount_3__c = 10000,
                ASI_MFM_Allocated_Amount_4__c = 10000,
                ASI_MFM_Allocated_Amount_5__c = 10000,
                ASI_MFM_Allocated_Amount_6__c = 10000,
                ASI_MFM_Allocated_Amount_7__c = 10000,
                ASI_MFM_Allocated_Amount_8__c = 10000,
                ASI_MFM_Allocated_Amount_9__c = 10000,
                ASI_MFM_Allocated_Amount_10__c = 10000,
                ASI_MFM_Allocated_Amount_11__c = 10000,
                ASI_MFM_Allocated_Amount_12__c = 10000,
                ASI_MFM_PO_Start_Date__c = startDate,
                ASI_MFM_PO_End_Date__c = endDate,
                ASI_MFM_Create_Date__c = System.now(),
                RecordTypeId = phasingRTID);
            ASI_MFM_PO_Receipt_Phasing__c porp2 = new ASI_MFM_PO_Receipt_Phasing__c(
                ASI_MFM_Latest_Phasing__c = false,
                ASI_MFM_Version__c = '2',
                ASI_MFM_Comments__c = 'ttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttt ttt t t',
                ASI_MFM_PO__c = po.id,
                ASI_MFM_Modify_BY__c = 'testUser',
                ASI_MFM_PO_Approved__c = false,
                ASI_MFM_Allocated_Amount_1__c = 10000,
                ASI_MFM_Allocated_Amount_2__c = 10000,
                ASI_MFM_Allocated_Amount_3__c = 10000,
                ASI_MFM_Allocated_Amount_4__c = 10000,
                ASI_MFM_Allocated_Amount_5__c = 10000,
                ASI_MFM_Allocated_Amount_6__c = 10000,
                ASI_MFM_Allocated_Amount_7__c = 10000,
                ASI_MFM_Allocated_Amount_8__c = 10000,
                ASI_MFM_Allocated_Amount_9__c = 10000,
                ASI_MFM_Allocated_Amount_10__c = 10000,
                ASI_MFM_Allocated_Amount_11__c = 10000,
                ASI_MFM_Allocated_Amount_12__c = 10000,
                ASI_MFM_PO_Start_Date__c = startDate,
                ASI_MFM_PO_End_Date__c = endDate,
                ASI_MFM_Create_Date__c = System.now(),
                RecordTypeId = phasingRTID);
            
            List<ASI_MFM_PO_Receipt_Phasing__c> receiptPhasingList = new List<ASI_MFM_PO_Receipt_Phasing__c>{porp1,porp2};
            insert receiptPhasingList;
                
                ASI_MFM_CN_InputPOReceiptPhasingCtl.ReceiptPhasing rp1 = new ASI_MFM_CN_InputPOReceiptPhasingCtl.ReceiptPhasing(porp1);
            ASI_MFM_CN_InputPOReceiptPhasingCtl.ReceiptPhasing rp2 = new ASI_MFM_CN_InputPOReceiptPhasingCtl.ReceiptPhasing(porp2);
            
            rp1.getAmount('amount1');rp1.getAmount('amount2');rp1.getAmount('amount3');rp1.getAmount('amount4');
            rp1.getAmount('amount5');rp1.getAmount('amount6');rp1.getAmount('amount7');rp1.getAmount('amount8');
            rp1.getAmount('amount9');rp1.getAmount('amount10');rp1.getAmount('amount11');rp1.getAmount('amount12');
            rp1.getAmount('');
            rp2.checkEqual(rp1);
            
            
            ProcessInstanceHistory tmp = new ProcessInstanceHistory();
            
            ASI_MFM_CN_PO_Component_Controller con = new ASI_MFM_CN_PO_Component_Controller();
            con.POID = po.Id;
            con.init();
            con.init(po, new List<ASI_MFM_PO_Line_Item__c>{poli});
            con.getLongDate();
            con.appHistList = new List<ASI_MFM_CN_PO_Component_Controller.ASI_ApprHist_LineItem>();
            con.addToApprHistList(tmp);
            con.addToSubmitter(tmp);
            boolean testb = con.dummyVar;
            List<ProcessInstanceHistory> listHist = con.processInstList;
            
            ASI_MFM_CN_PO_Component_Controller.getApprDetailInfo(UserInfo.getUserId());
            
			Set<String> useridSet = new Set<String>();
            useridSet.add(UserInfo.getUserId());
            con.getApprDetailInfo(useridSet);
            
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
            
            system.schedule('testschedule', '0 0 0 15 3 ? 2022', new ASI_MFM_CN_ReceiptGeneration_Schd());
            
            Id batchInstanceId = Database.executeBatch(new ASI_MFM_CN_ReceiptGeneration_Batch(), 1);
            
            ASI_MFM_CN_ReceiptGeneration_Batch tmpBatch = new ASI_MFM_CN_ReceiptGeneration_Batch();
            tmpBatch.execute(null, receiptPhasingList);
            
            Test.stopTest();
        } 
    }
}