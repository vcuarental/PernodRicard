@isTest
public class ASI_MFM_MassCreateAndUpdateCtrl_P_Test {

    
    static testMethod void POMassCreateAndUpdateTestLA(){
        //Set User
        user u = [select userRole.developerName, ASI_MFM_Country__c from user where id = :userInfo.getUserId()];
        u.ASI_MFM_Country__c = 'SG';
        update u;
        ASI_MFM_Exchange_Rate__c xr = new ASI_MFM_Exchange_Rate__c(ASI_MFM_Application__c='MFM', ASI_MFM_Base_Currency__c='SGD',
                                                                   ASI_MFM_Counter_Currency__c='USD', ASI_MFM_Country__c='SG', ASI_MFM_Effective_Date__c=date.today(), ASI_MFM_Exchange_Rate__c=1.23);
        insert xr;         
        //Set Plan prefix
        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', Plan_Type__c='test');
        insert px;
        
        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pr;
        
        
        ASI_MFM_Plan__c p1 = new ASI_MFM_Plan__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_SG_Plan'), ASI_MFM_Prefix__c=px.id, ASI_MFM_Start_Date__c=date.today(), ASI_MFM_End_Date__c=date.today(),
                                                 ASI_MFM_Plan_Description__c='planDescription', ASI_MFM_Plan_Name__c='testplanName', ASI_MFM_Status__c = 'Final');
        insert p1;
        //Set PO
        px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO',ASI_MFM_Location__c='Laos');
        insert px;
        
        pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pr;
        //Set   Route Type
        ASI_MFM_Route_Type__c rt = new ASI_MFM_Route_Type__c(name='test', ASI_MFM_Module__c='PO');
        insert rt;
        
        ASI_MFM_Brand_Route_Type_Map__c rtm = new ASI_MFM_Brand_Route_Type_Map__c(ASI_MFM_Route_Type__c=rt.id, ASI_MFM_Prefix__c=px.id);
        insert rtm;
        
        ASI_MFM_Route_Rule_Detail__c rrd = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt.id);
        insert rrd;
        
        
        System.debug(Limits.getDMLRows());
        
        
        map<string, id> rt_map2 = ASI_MFM_Function.getRecordTypeId('ASI_MFM_PO__c');  //ASI_MFM_Plan__c
        rt_map2 = ASI_MFM_Function.getRecordTypeId('Account');   
        Account acc2 = new Account(recordTypeId=rt_map2.get('ASI_MFM_SG_Customer'),Name='Name3');           
        insert acc2;
        
        map<string, id> rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_PO__c'); 
        rt_map = ASI_MFM_Function.getRecordTypeId('Account');
        Account acc1 = new Account(recordTypeId=rt_map.get('ASI_CRM_SG_Supplier'),Name='Name2');          
        insert acc1;
        
        // Set PO 
        ASI_MFM_PO__c po = new ASI_MFM_PO__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_SG_PO'), ASI_MFM_Prefix__c=px.id, ASI_MFM_Plan__c=p1.id, ASI_MFM_PO_Raised_Date__c=date.today(),
                                             ASI_MFM_Currency__c='SGD', ASI_MFM_PO_Start_Date__c=date.today(), ASI_MFM_PO_End_Date__c=date.today(), ASI_MFM_Supplier_Name__c = acc1.id);
        insert po;
        Map<string, id> acCode_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_A_C_Code__c');
        ASI_MFM_A_C_Code__c ac = new ASI_MFM_A_C_Code__c(name='testAC', recordtypeid=acCode_map.get('ASI_MFM_SG_A_C_Code'), ASI_MFM_Market__c = 'Singapore');
        insert ac;
        
        ASI_MFM_Sub_brand__c sub = new ASI_MFM_Sub_brand__c(name='testSubBrand');
        insert sub;
        
        list<ASI_MFM_PO_Line_Item__c> poLineItems = new list<ASI_MFM_PO_Line_Item__c>();
        ASI_MFM_PO_Line_Item__c poi = new ASI_MFM_PO_Line_Item__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_SG_PO_Line_Item'), ASI_MFM_PO__c=po.id, ASI_MFM_Amount__c=10, 
                                                                  ASI_MFM_A_C_Code__c=ac.id, ASI_MFM_Customer_Name__c=acc2.id, ASI_MFM_List_Item_Description__c='testDescription', ASI_MFM_Sub_brand_Code__c=sub.id, ASI_MFM_G_L_Date__c = Date.today());
        poLineItems.add(poi);
        insert poLineItems;
        
        
        ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(poLineItems);
        
        test.startTest();
        // Initialize the page
        PageReference testPage = Page.ASI_MFM_SG_InputPOItemsPage;
        Map<String, String> pageParams = testPage.getParameters();
        pageParams.put('id', po.Id);
        Test.setCurrentPageReference(testPage);
        ASI_MFM_MassCreateAndUpdateController_P mcauCon = new ASI_MFM_MassCreateAndUpdateController_P();
        String mode = mcauCon.MODE_NEW;
        String row_show = mcauCon.PARAM_NUM_OF_SHOW_ROW;
        
        // Assign component attributes
        mcauCon.isFastModeBool = false;
        mcauCon.sObjTypeStr = 'ASI_MFM_PO_Line_Item__c';
        mcauCon.displayFieldsStr = 'ASI_MFM_Sub_brand_Code__c&req=T&width=240px,ASI_MFM_A_C_Code__c&req=T&width=160px,ASI_MFM_Customer_Name__c&req=T&width=160px,ASI_MFM_List_Item_Description__c&req=T&width=120px,ASI_MFM_SG_Unit__c&req=F&width=60px,ASI_MFM_Quantity__c&req=F&width=60px,ASI_MFM_Unit_Price__c&req=F&width=60px,ASI_MFM_Amount__c&req=T&width=80px,ASI_MFM_G_L_Date__c&req=T&width=75px';
        mcauCon.fieldToURLParamStr = 'ASI_MFM_PO__c=>id';
        mcauCon.whereStatm = 'ASI_MFM_PO__c = \'' + po.Id + '\'';
        mcauCon.pageBlockTitleStr = 'Plan Line Items';
        mcauCon.successLinkValue = '/' + po.Id;
        mcauCon.cancelLinkValue = '/' + po.Id;
        mcauCon.modeValue = 'BOTH';
        mcauCon.isDefaultEditVal = true;
        mcauCon.showAllRTValue = true;
        mcauCon.lookupToPicklist = 'ASI_MFM_Sub_brand_Code__c,ASI_MFM_A_C_Code__c,ASI_MFM_Customer_Name__c';
        
        
        // Start testing user actions
        pageParams.put(mcauCon.PARAM_RTID, 'ASI_MFM_SG_PO_Line_Item');
        pageParams.put(mcauCon.PARAM_NUM_OF_SHOW_ROW, '1');
        mcauCon.init();
        mcauCon.Previous();
        /*mcauCon.changePage();
        mcauCon.Last();
        mcauCon.Previous();
        mcauCon.Next();*/
        
        mcauCon.getcheckPicklistSet();
        //mcauCon.clearAll();
        
        mcauCon.cloneRow();
        mcauCon.enableForEdit();
        mcauCon.removeNew();
        mcauCon.deleteOld();
        
        mcauCon.commitAll();
        mcauCon.triggerPageBlockAction();
        mcauCon.addNewRowByInfo('', null);
        mcauCon.refresh();
        //mcauCon.addNewRow();
        //mcauCon.addMoreBlankRows();
        
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
        
            
        pageParams.put(mcauCon.PARAM_TRID, mcauCon.theRecordTypeElementList.get(recordIndex).myRecordList.get(0).id);  
        pageParams.put(mcauCon.PARAM_RTID, 'ASI_MFM_TW_Plan_Line_Item');
        List<ASI_MFM_MassCreateAndUpdateController_P.TableRow> recordList = mcauCon.theRecordTypeElementList.get(recordIndex).myRecordList;
        pageParams.put(mcauCon.PARAM_TRID, recordList.get(recordList.size() - 1).id);
        mcauCon.setPageController(mcauCon.pageControllerValue);
		try{mcauCon.addNewRow();}catch(Exception e){}
        try{mcauCon.addMoreBlankRows();}catch(Exception e){}        
		
        Test.stopTest();
    }
    
    static testMethod void testHKInputPOItemsController() {
        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', Plan_Type__c='test', ASI_MFM_Fiscal_year__c='FY1314');
        insert px;   
        
        user u = [select userRole.developerName from user where id = :userInfo.getUserId()];  
        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pr;
        
        ASI_MFM_Plan__c p = new ASI_MFM_Plan__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_HK_Plan'), name='test',
            ASI_MFM_End_Date__c = Date.today().addMonths(1), ASI_MFM_Plan_Description__c = 'testDescription', 
                ASI_MFM_Plan_Name__c = 'planName test', ASI_MFM_Start_Date__c = Date.today(),  ASI_MFM_Prefix__c=px.id, ASI_MFM_Status__c = 'Final');
        insert p; 
        
        List<Account> accList = new List<Account>();
        
        Account acc1 = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_MFM_HK_Supplier'),Name='Name2');           
        accList.add(acc1);
        Account acc2 = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_HK_CRM_Outlet'),Name='Name3');           
        accList.add(acc2);
        insert accList;
        
        ASI_MFM_Prefix__c pxo = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO');
        insert pxo; 
        
        ASI_MFM_Role_Prefix_Relationship__c pro = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pro;
        ASI_MFM_PO__c po = new ASI_MFM_PO__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_HK_PO'), name='test', ASI_MFM_Plan__c=p.id, ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Supplier_Name__c = acc1.id);
        insert po;  
        
        ASI_MFM_A_C_Code__c ac = new ASI_MFM_A_C_Code__c(name='testAC', recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_HK_A_C_Code'));
        insert ac;
        
        ASI_MFM_Sub_brand__c sub = new ASI_MFM_Sub_brand__c(name='testSubBrand', ASI_MFM_Inactive__c = false, recordtypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_HK_CRM_Sub_brand'));
        insert sub;
        
        ASI_MFM_PO_Line_Item__c poi = new ASI_MFM_PO_Line_Item__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_HK_PO_Line_Item'), ASI_MFM_PO__c=po.id, ASI_MFM_Quantity__c=10, ASI_MFM_Unit_Price__c=10, 
            ASI_MFM_Spread_by_Months__c=true,ASI_MFM_A_C_Code__c=ac.id, ASI_MFM_Customer_Name__c=acc2.id, ASI_MFM_List_Item_Description__c='testDescription', ASI_MFM_Sub_brand_Code__c=sub.id, ASI_MFM_G_L_Date__c = Date.today());
        insert poi;    
        
        
		ASI_MFM_MassCreateAndUpdateController_P.DisplayField df;
        df = new ASI_MFM_MassCreateAndUpdateController_P.DisplayField('', '');
        
		ASI_MFM_MassCreateAndUpdateController_P.PageBlockActionBtn btn = new ASI_MFM_MassCreateAndUpdateController_P.PageBlockActionBtn('','');
		
        /*
        list<ASI_MFM_PO__c> po_list = new list<ASI_MFM_PO__c>();
        apexpages.standardSetController sc = new apexpages.standardSetController(po_list);  
        ASI_MFM_HK_InputPOItemsController cx = new ASI_MFM_HK_InputPOItemsController(sc);  
        cx.save();
        cx.quickSave();         
        cx.onCommitted();
        cx.APPLY();
        cx.DELETESELECTED();
        cx.CLONESELECTED();
        cx.ADDNEW();
        cx.cacnel();
        cx.Beginning();
        cx.Previous();
        cx.Next();
        cx.End();
        List<String> results = new List<String>();
        results = ASI_MFM_HK_InputPOItemsController.findSObjects('ASI_MFM_PO_Line_Item__c', ' where ASI_MFM_PO__c != null');
        */
        test.startTest();
        test.setCurrentPage(page.ASI_MFM_TW_InputPlanItemsPage_P);
        apexpages.currentPage().getParameters().put('id', po.id); 
        ASI_MFM_MassCreateAndUpdateController_P mcauCon = new ASI_MFM_MassCreateAndUpdateController_P();
        
        // Assign component attributes
        mcauCon.isFastModeBool = false;
        mcauCon.sObjTypeStr = 'ASI_MFM_PO_Line_Item__c';
        mcauCon.displayFieldsStr = 'ASI_MFM_Spread_by_Months__c&req=F&width=40px, ASI_MFM_Sub_brand_Code__c&req=T&width=240px, ASI_MFM_A_C_Code__c&req=T&width=160px,  ASI_MFM_Customer_Name__c&req=T&width=320px, ASI_MFM_List_Item_Description__c&req=T&width=120px, ASI_MFM_Amount__c&req=F&width=80px, ASI_MFM_PO_Percentage__c&req=F&width=35px, ASI_MFM_G_L_Date__c&req=T&width=75px, ASI_MFM_Invoice_Number__c&req=F&width=120px';        
        mcauCon.fieldToURLParamStr = 'ASI_MFM_PO__c=>id';
        mcauCon.whereStatm = 'ASI_MFM_PO__c = \'' + po.Id + '\'';
        mcauCon.pageBlockTitleStr = 'POLine Items';
        mcauCon.successLinkValue = '/' + po.Id;
        mcauCon.cancelLinkValue = '/' + po.Id;
        mcauCon.modeValue = 'BOTH';
        mcauCon.isDefaultEditVal = true;
        mcauCon.ShowAllRTValue = true;
        mcauCon.ComponentKeyValue = 'massCreateAndUpdate';
        mcauCon.lookupToPicklist = 'ASI_MFM_Sub_brand_Code__c,ASI_MFM_A_C_Code__c,ASI_MFM_Customer_Name__c';
        
        mcauCon.init();
        /*
        Integer recordIndex = 0;        
        apexpages.currentPage().getParameters().put(mcauCon.PARAM_TRID, mcauCon.theRecordTypeElementList.get(recordIndex).myRecordList.get(0).id);            
        mcauCon.enableForEdit();
        mcauCon.cloneRow();
        mcauCon.addNewRow();   
        List<ASI_MFM_MassCreateAndUpdateController_P.TableRow> recordList = mcauCon.theRecordTypeElementList.get(recordIndex).myRecordList;
        apexpages.currentPage().getParameters().put(mcauCon.PARAM_TRID, recordList.get(recordList.size() - 1).id);
        mcauCon.removeNew();        
        mcauCon.addMoreBlankRows();        
        apexpages.currentPage().getParameters().put(mcauCon.PARAM_TRID, mcauCon.theRecordTypeElementList.get(recordIndex).myRecordList.get(0).id);
        mcauCon.deleteOld();        
        mcauCon.clearAll();
        mcauCon.triggerPageBlockAction();
        */
        mcauCon.setPageController(mcauCon.pageControllerValue);
        mcauCon.commitAllByQuickSave();
        mcauCon.clearAll();
        test.stopTest();
    }   
    
     static testMethod void testCNInputPOItemsController() {
         ASI_MFM_Market_Strategy__c ms = new ASI_MFM_Market_Strategy__c(Name='99999 Malibu', ASI_MFM_Active__c=true, ASI_MFM_Fiscal_Year__c='FY1213');
        
         list<User> users = new list<User>();
         
         User user2 = [select id from user where id = : userInfo.getUserId()];
         user2.ASI_MFM_Team__c = 'NTMK';
         System.debug(user2.ASI_MFM_Country__c);
         system.debug(user2.userRole.developerName);
         user2.ASI_MFM_Country__c ='CN';
         users.add(user2);
         
         User user1 = [SELECT Id, Name, Managerid, ASI_MFM_Bypass_Callouts__c, ASI_MFM_Country__c, UserRole.DeveloperName 
                       FROM User 
                       WHERE Profile.Name LIKE '%ASI System Admin%' AND IsActive = TRUE order by id asc
                       LIMIT 1];//ASI_MFM_Function.getSystemAdminUser();
         user1.ASI_MFM_Team__c = 'NTMK';
         System.debug(user1.ASI_MFM_Country__c);
         system.debug(user1.userRole.developerName);
         user1.ASI_MFM_Country__c ='CN';
         user1.managerid = user2.id;
         users.add(user1);
         
         update users;
         
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
         
         /*
         strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_Plan_Line_Item__c','ASI_MFM_CN_Plan_Line_Item');
         ASI_MFM_Plan_Line_Item__c planLineItem1 = new ASI_MFM_Plan_Line_Item__c(
             ASI_MFM_Plan__c = Plan1.id
             ,ASI_MFM_Sub_brand_Code__c = subBrands[2].id,ASI_MFM_List_Item_Description__c='hello1'
             ,recordTypeId=strRTId , ASI_MFM_Total_Cost__c =120000,
             ASI_MFM_A_C_Code__c=acs[2].id
         );
         insert planLineItem1; 
		*/
         
         //create po
         strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_PO__c','ASI_MFM_CN_PO');
         
         System.debug('BUID: ' + string.valueOf(bu.id));
         

         list<ASI_MFM_PO__c> pos = new list<ASI_MFM_PO__c>();
         pos.add(new ASI_MFM_PO__c(Name='PO11111', RecordTypeId=strRTId , ASI_MFM_Prefix__c=prefixs[1].id, ASI_MFM_Remarks__c='Remarks', ASI_MFM_BU_Code__c=bu.id, ASI_MFM_Sys_Local_Currency__c='RMB', ASI_MFM_CN_BU_Picklist__c = 'BUCode',
                                   ASI_MFM_Supplier_Name__c=accs[1].id, ASI_MFM_Currency__c='RMB', ASI_MFM_Status__c='Draft', ASI_MFM_Exchange_Rate__c=1, ASI_MFM_CN_PO_Max_Approved_Amount__c=1,
                                   ASI_MFM_PO_Start_Date__c=Date.valueof('2014-04-01'),ASI_MFM_PO_End_Date__c=Date.valueof('2014-04-30'),
                                   ASI_MFM_Budget_Owner__c =user2.id, ASI_MFM_Plan__c=Plan1.id ));
         insert pos;
         
         
         
         
         strRTId = ASI_MFM_Function.checkRecordType('ASI_MFM_PO_Line_Item__c','ASI_MFM_CN_PO_Line_Item');
         list<ASI_MFM_PO_Line_Item__c> polis = new list<ASI_MFM_PO_Line_Item__c>();
         polis.add(new ASI_MFM_PO_Line_Item__c(RecordTypeId=strRTId, ASI_MFM_PO__c=pos[0].id, ASI_MFM_G_L_Date__c=date.valueof('2014-04-03'),ASI_MFM_Sub_brand_Code__c=subBrands[2].id,
                                               ASI_MFM_A_C_Code__c = acs[2].id, ASI_MFM_Customer_Name__c=accs[0].id,
                                               ASI_MFM_Spread_by_Months__c=true,ASI_MFM_Amount__c=1,ASI_MFM_PO_Remark__c='Remarks'));
         
        /*
        list<ASI_MFM_PO__c> po_list = new list<ASI_MFM_PO__c>();
        apexpages.standardSetController sc = new apexpages.standardSetController(po_list);  
        ASI_MFM_HK_InputPOItemsController cx = new ASI_MFM_HK_InputPOItemsController(sc);  
        cx.save();
        cx.quickSave();         
        cx.onCommitted();
        cx.APPLY();
        cx.DELETESELECTED();
        cx.CLONESELECTED();
        cx.ADDNEW();
        cx.cacnel();
        cx.Beginning();
        cx.Previous();
        cx.Next();
        cx.End();
        List<String> results = new List<String>();
        results = ASI_MFM_HK_InputPOItemsController.findSObjects('ASI_MFM_PO_Line_Item__c', ' where ASI_MFM_PO__c != null');
        */
        test.startTest();
        test.setCurrentPage(page.ASI_MFM_TW_InputPlanItemsPage_P);
        apexpages.currentPage().getParameters().put('id', pos[0].id); 
        ASI_MFM_MassCreateAndUpdateController_P mcauCon = new ASI_MFM_MassCreateAndUpdateController_P();
        
        // Assign component attributes
        mcauCon.isFastModeBool = false;
        mcauCon.sObjTypeStr = 'ASI_MFM_PO_Line_Item__c';
        mcauCon.displayFieldsStr = 'ASI_MFM_Spread_by_Months__c&req=F&width=40px, ASI_MFM_Sub_brand_Code__c&req=T&width=240px, ASI_MFM_A_C_Code__c&req=T&width=160px,  ASI_MFM_Customer_Name__c&req=T&width=320px, ASI_MFM_List_Item_Description__c&req=T&width=120px, ASI_MFM_Amount__c&req=F&width=80px, ASI_MFM_PO_Percentage__c&req=F&width=35px, ASI_MFM_G_L_Date__c&req=T&width=75px, ASI_MFM_Invoice_Number__c&req=F&width=120px';        
        mcauCon.fieldToURLParamStr = 'ASI_MFM_PO__c=>id';
        mcauCon.whereStatm = 'ASI_MFM_PO__c = \'' + pos[0].Id + '\'';
        mcauCon.pageBlockTitleStr = 'POLine Items';
        mcauCon.successLinkValue = '/' + pos[0].Id;
        mcauCon.cancelLinkValue = '/' + pos[0].Id;
        mcauCon.modeValue = 'BOTH';
        mcauCon.isDefaultEditVal = true;
        mcauCon.ShowAllRTValue = true;
        mcauCon.ComponentKeyValue = 'massCreateAndUpdate';
        mcauCon.lookupToPicklist = 'ASI_MFM_Sub_brand_Code__c,ASI_MFM_A_C_Code__c,ASI_MFM_Customer_Name__c';
        
        mcauCon.init();
        mcauCon.getOffset();
           mcauCon.setPageController(mcauCon.pageControllerValue);  
        mcauCon.commitAllByQuickSave();
        mcauCon.clearAll();
        test.stopTest();
        }
    }   
    
    
    
    static testMethod void ASI_CRM_CN_MassCreateAndUpdateController_TEST() {
        
        list<RecordType> rts = Global_RecordTypeCache.getRtList('Contact');
        if(rts.size()<=0) return;
        
        
        list<string> rtNames = new list<string>();
        list<ASI_TnE_MassCreateAndUpdateSetting__c> settings = new list<ASI_TnE_MassCreateAndUpdateSetting__c>();
        for(RecordType rt: rts) {
            rtNames.add(rt.DeveloperName);
            settings.add(new ASI_TnE_MassCreateAndUpdateSetting__c(
                Name='Contact:' + rt.DeveloperName
            ));
        }
        string strRtNames = string.join(rtNames, ',');
        insert settings;
        
        list<Contact> contacts = new list<Contact>();
        contacts.add(new Contact(LastName='TEST'));
        
        Map<String, String> fieldNameToValueMap = new Map<String, String>();
        fieldNameToValueMap.put('LastName', 'TEST');
        Map<String, String> defaultFieldValues = new Map<String, String>();
        defaultFieldValues.put('LastName', 'TEST');
        
        test.startTest();
        
        ASI_MFM_MassCreateAndUpdateController_P.RecordTypeElement rte = new ASI_MFM_MassCreateAndUpdateController_P.RecordTypeElement(
            Schema.getGlobalDescribe().get('Contact'), rts[0], contacts, new List<ASI_MFM_MassCreateAndUpdateController_P.DisplayCol>(), fieldNameToValueMap, false, false, false, 10);
        
        rte.cloneNewSObject(contacts[0]);
        rte.cloneNewSObject(contacts[0], true);
        rte.cloneNewSObject(contacts[0], 0);
        rte.createNewSObject();
        rte.createNewSObject(true);
        rte.createNewSObject(new Contact());
        rte.createNewSObject(0, new Contact());
        rte.myDisplayRecordList = rte.myDisplayRecordList;
       
        
        
        ASI_MFM_MassCreateAndUpdateController_P.DisplayField df;
        df = new ASI_MFM_MassCreateAndUpdateController_P.DisplayField('', '');
        df = new ASI_MFM_MassCreateAndUpdateController_P.DisplayField('', '',true);
        //df = new ASI_MFM_MassCreateAndUpdateController_P.DisplayField('', '',true,'');
        String conKey = df.colKey;
        Boolean skipClone = df.skipClone;
        
        ASI_MFM_MassCreateAndUpdateController_P.DisplayCol dc = new ASI_MFM_MassCreateAndUpdateController_P.DisplayCol('','');
        dc.addDisplayField(df);           
        
        ASI_MFM_MassCreateAndUpdateController_P.PageBlockActionBtn btn = new ASI_MFM_MassCreateAndUpdateController_P.PageBlockActionBtn('','');
        
        ASI_MFM_MassCreateAndUpdateController_P con = new ASI_MFM_MassCreateAndUpdateController_P();
        ApexPages.currentPage().getParameters().put('id', contacts[0].id); 
        //con.pageController = new PageController();
        con.sObjTypeStr = 'Contact';
        con.isFastModeBool = false;
        con.isUseFirstRowForNew = true;
        con.successLinkValue = '';
        //con.includeRecordTypes = strRtNames;
        //con.defaultFieldValuesStr = 'LastName,TEST';
        con.displayFieldsStr = 'LastName&AccountId';
        con.lookupToPicklist = 'AccountId,AccountId.AccountNumber=>AccountId';
        //con.lookupDateFields = 'Birthdate';
        con.fieldToURLParamStr = 'fieldToURLParamStr';
        //con.init();
        con.getcheckPicklistSet();
        con.setPageController(con.pageControllerValue);
        //con.dummyMethod();
       // con.initPickList(new string[]{'LeadSource'});
        //con.initDateFields(new string[]{'Birthdate'});
        //con.clearAll();
        //con.addNewRow();
        //con.cloneRow();
        //con.enableForEdit();
        //con.removeNew();
        //con.deleteOld();
        //con.deleteRow('','');
        //con.addMoreBlankRows();

        //con.commitAll();
        //con.triggerPageBlockAction();
        //con.addNewRowByInfo('', null);
        //con.refresh();
        
        //ASI_CRM_CN_MassCreateAndUpdateController.RecordTypeElement e = new ASI_CRM_CN_MassCreateAndUpdateController.RecordTypeElement();
        
        //con.sba_addRow();
        con.rowSelected_index = 0;
        //con.sba_cloneRow();
        //con.sba_deleteRow();
        //
        try{integer offset = con.offset;}catch(Exception e){}
        try{boolean AllowMoveNext = con.AllowMoveNext;}catch(Exception e){}
        try{boolean AllowMovePrev = con.AllowMovePrev;}catch(Exception e){}
        try{con.Next();}catch(Exception e){}
        try{con.Last();}catch(Exception e){}
        
        try{
            con.level = 'INFO';
            con.message = '';
            con.showPageMessage();
        }catch(Exception e){
            
        }
        
        try{
            con.level = 'WARNING';
            con.message = '';
            con.showPageMessage();
        }catch(Exception e){
            
        }
        
        try{
            con.level = 'ERROR';
            con.message = '';
            con.showPageMessage();
        }catch(Exception e){
            
        }
        
        list<ASI_MFM_MassCreateAndUpdateController_P.interimData> tmplist = new list<ASI_MFM_MassCreateAndUpdateController_P.interimData>();
        ASI_MFM_MassCreateAndUpdateController_P.interimData tmp = new ASI_MFM_MassCreateAndUpdateController_P.interimData(); 
        String id = tmp.id;
        tmp.rowindex = 0;
        tmplist.add(tmp);
        con.results = tmplist;
        
        
        test.stopTest();
        
        
        
    }
    
    
}