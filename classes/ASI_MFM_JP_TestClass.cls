@isTest(SeeAllData=true)
private class ASI_MFM_JP_TestClass {
    static testMethod void testGenPOItemsController() {
        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', Plan_Type__c='test', ASI_MFM_Fiscal_year__c='FY1819');
        insert px; 
        
        user u = [select userRole.developerName from user where id = :userInfo.getUserId()];  
        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pr;
        
        ASI_MFM_Plan__c p = new ASI_MFM_Plan__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_JP_Plan'), name='test',
            ASI_MFM_End_Date__c=Date.today().addMonths(1), ASI_MFM_Plan_Description__c='testPlanDescription', 
                ASI_MFM_Plan_Name__c='testPlan', ASI_MFM_Start_Date__c=Date.today(), ASI_MFM_Prefix__c=px.id, ASI_MFM_Status__c = 'Final');
        insert p;
        
        ASI_MFM_Brand__c brand1 = new ASI_MFM_Brand__c(Name='Brand1', recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Brand__cASI_JP_Brand'));
        insert brand1;
        ASI_MFM_Sub_brand__c subBrand1 = new ASI_MFM_Sub_brand__c(Name='subBrand1', recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_JP_Sub_brand'), ASI_MFM_Brand__c=brand1.id);
        insert subBrand1;
        
        ASI_MFM_A_C_Code__c ac = new ASI_MFM_A_C_Code__c(name='testAC', recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_JP_A_C_Code'));
        insert ac;
        ASI_MFM_AP_Code__c ap = new ASI_MFM_AP_Code__c(name='testAP', recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_AP_Code__cASI_JP_AP_Code'));
        insert ap;
        
        List<Account> accToInsert = new List<Account>();
        Account acc2 = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_JP_Customer'), Name='Name3');           
        accToInsert.add(acc2);
        Account acc1 = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_JP_Supplier'),Name='Name2');           
        accToInsert.add(acc1);
        
        insert accToInsert;
           
        ASI_MFM_BU__c bu = new ASI_MFM_BU__c(name='testBU', recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_BU__cASI_MFM_JP_BU'));
        insert bu;                
                
        system.debug('Linus: start plan line');
        ASI_MFM_Plan_Line_Item__c pi = new ASI_MFM_Plan_Line_Item__c(recordTypeId= Global_RecordTypeCache.getRtId('ASI_MFM_Plan_Line_Item__cASI_MFM_JP_Plan_Line_Item'), ASI_MFM_Plan__c=p.id,ASI_MFM_Customer_Name__c=acc2.id,ASI_MFM_BU_Code__c=bu.id
            ,ASI_MFM_Sub_brand_Code__c = subBrand1.id,ASI_MFM_A_C_Code__c=ac.id,ASI_MFM_AP_Code__c=ap.id, ASI_MFM_List_Item_Description__c='testDescription');   
        insert pi;  

        ASI_MFM_Prefix__c pxo = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO');
        insert pxo;
         
        ASI_MFM_Route_Type__c rt = new ASI_MFM_Route_Type__c(name='testRT',ASI_MFM_Module__c='PO');
        insert rt;
        
        ASI_MFM_Brand_Route_Type_Map__c rtm = new ASI_MFM_Brand_Route_Type_Map__c(ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Responsible_By__c=u.id,ASI_MFM_Prefix__c=pxo.id );
        insert rtm;
        
        ASI_MFM_Role_Prefix_Relationship__c pro = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pro;                   
        
        ASI_MFM_Route_Type_Brands_Relationship__c rtbr= new ASI_MFM_Route_Type_Brands_Relationship__c(ASI_MFM_Route_Type__c=rt.id,Brand_MFM__c=brand1.id);
        insert rtbr;
        date startDate = date.newInstance(Date.Today().Year(), Date.Today().Month(), 1);
        ASI_MFM_PO_Date_Range__c podr = new ASI_MFM_PO_Date_Range__c(Name='testPODR',ASI_MFM_PO_Start_Date__c=startDate,ASI_MFM_PO_End_Date__c=startDate.addDays(30),ASI_MFM_GL_Date__c=Date.today(),asi_mfm_next_number__c=1,ASI_MFM_Fiscal_Period__c='201404');
        insert podr;
        
        test.startTest();
        ASI_MFM_PO__c po = new ASI_MFM_PO__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_JP_PO'), name='test', ASI_MFM_Prefix__c=pxo.id, ASI_MFM_BU_Code__c=bu.id,
            ASI_MFM_Plan__c = p.id,ASI_MFM_Supplier_Name__c = acc1.id, ASI_MFM_Responsible_By__c=u.id,ASI_MFM_PO_Raised_Date__c=Date.today(),ASI_MFM_PO_Start_Date__c=Date.today(),ASI_MFM_PO_End_Date__c=Date.today()); 
        insert po;
        
        apexpages.standardController sc = new apexpages.standardController(po);
        ASI_MFM_JP_GenPOItemsController cx= new ASI_MFM_JP_GenPOItemsController(sc);
        pageReference pg = page.ASI_MFM_JP_GenPOItemsPage;
        test.setCurrentPage(pg);  
        apexpages.currentPage().getParameters().put('mode', 'Full'); 
        cx.genPOItems();
        test.stopTest();
    }
    
    static testMethod void testInputPlanItemsController() {
         ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', Plan_Type__c='test', ASI_MFM_Fiscal_year__c='FY1819');
        insert px; 
        
        user u = [select userRole.developerName from user where id = :userInfo.getUserId()];  
        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pr;
        
       
        
        ASI_MFM_Brand__c brand1 = new ASI_MFM_Brand__c(Name='Brand1', recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Brand__cASI_JP_Brand'));
        insert brand1;
        ASI_MFM_Sub_brand__c subBrand1 = new ASI_MFM_Sub_brand__c(Name='subBrand1', recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_JP_Sub_brand'), ASI_MFM_Brand__c=brand1.id);
        insert subBrand1;
        
        ASI_MFM_A_C_Code__c ac = new ASI_MFM_A_C_Code__c(name='testAC', recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_JP_A_C_Code'));
        insert ac;
        ASI_MFM_AP_Code__c ap = new ASI_MFM_AP_Code__c(name='testAP', recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_AP_Code__cASI_JP_AP_Code'));
        insert ap;
        
        List<Account> accToInsert = new List<Account>();
        Account acc2 = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_JP_Customer'), Name='Name3');           
        accToInsert.add(acc2);
        Account acc1 = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_JP_Supplier'),Name='Name2');           
        accToInsert.add(acc1);
        
        insert accToInsert;

        ASI_MFM_BU__c bu = new ASI_MFM_BU__c(name='testBU', recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_BU__cASI_MFM_JP_BU'));
        insert bu;
                
        ASI_MFM_Plan__c p = new ASI_MFM_Plan__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_JP_Plan'), name='test',
            ASI_MFM_End_Date__c=Date.today().addMonths(1), ASI_MFM_Plan_Description__c='testPlanDescription', 
                ASI_MFM_Plan_Name__c='testPlan', ASI_MFM_Start_Date__c=Date.today(), ASI_MFM_Prefix__c=px.id, ASI_MFM_Status__c = 'Final');
        insert p;
         
        ASI_MFM_Plan_Line_Item__c pi = new ASI_MFM_Plan_Line_Item__c(recordTypeId= Global_RecordTypeCache.getRtId('ASI_MFM_Plan_Line_Item__cASI_MFM_JP_Plan_Line_Item'), ASI_MFM_Plan__c=p.id,ASI_MFM_Customer_Name__c=acc2.id,ASI_MFM_BU_Code__c=bu.id
            ,ASI_MFM_Sub_brand_Code__c = subBrand1.id,ASI_MFM_A_C_Code__c=ac.id,ASI_MFM_AP_Code__c=ap.id, ASI_MFM_List_Item_Description__c='testDescription');   
        insert pi;  
        
        list<ASI_MFM_Plan__c> p_list = new list<ASI_MFM_Plan__c>();
        p_list.add(p);
        
        test.startTest();
        ApexPages.StandardSetController sc = new ApexPages.StandardSetController(p_list );  
        
        PageReference InputPlanItem = Page.ASI_MFM_JP_InputPlanItemsPage;
        Map<String, String> pageParams = InputPlanItem.getParameters();
        pageParams.put('id', p.id);
        Test.setCurrentPageReference(InputPlanItem);
        ASI_MFM_InputPlanItemsController testCon = new ASI_MFM_InputPlanItemsController(sc);
        
        
        ASI_MFM_JP_MassCreateAndUpdateController mcauCon = new ASI_MFM_JP_MassCreateAndUpdateController();
        
        // Assign component attributes
        mcauCon.isFastModeBool = false;
        mcauCon.sObjTypeStr = 'ASI_MFM_Plan_Line_Item__c';
        mcauCon.displayFieldsStr = 'ASI_MFM_Sub_brand_Code__c&req=T&width=160px,  ASI_MFM_AP_Code__c&req=T&width=160px,  ASI_MFM_A_C_Code__c&req=T&width=160px&key=AC Code,   ASI_MFM_List_Item_Description__c&req=T&width=240px,ASI_MFM_Quantity__c&req=F&width=50px, ASI_MFM_Unit_Cost__c&req=F&width=65px,  ASI_MFM_Total_Cost__c&req=T&width=105px';
        mcauCon.fieldToURLParamStr = 'ASI_MFM_Plan__c=>id';
        mcauCon.whereStatm = 'ASI_MFM_Plan__c  = \'' + p.Id + '\'';
        mcauCon.orderByStr = 'Name';
        mcauCon.pageBlockTitleStr = 'Plan  Line Items';
        mcauCon.successLink = '/' + p.Id;
        mcauCon.cancelLink = '/' + p.Id;
        mcauCon.mode = 'BOTH';
        mcauCon.isDefaultEditVal = true;
        mcauCon.ShowAllRT = true;
        //mcauCon.disableClone= false;
        //mcauCon.disableAddNew=false;
        mcauCon.isUseFirstRowForNew = true;
        mcauCon.ComponentKey = 'massCreateAndUpdate';
        //mcauCon.PageController = testCon.thisController ;
        mcauCon.languageSupportedStr ='';
        mcauCon.lookupToPicklist = 'ASI_MFM_Sub_brand_Code__c,ASI_MFM_AP_Code__c,ASI_MFM_A_C_Code__c.ASI_MFM_AP_Code__c<=>ASI_MFM_AP_Code__c<=>ASI_MFM_AP_AC_Code_Map__r';
        mcauCon.dummyMethod();
        mcauCon.defaultFieldValuesStr = 'ASI_MFM_List_Item_Description__c=testremark';
        String[] ints2 = new String[]{'1/1/2001', '1/1/2002', '1/1/2003'};
        mcauCon.checkDateTimeFieldSet = new Set<String>();
        mcauCon.initDateFields(ints2);
        
        ASI_MFM_JP_MassCreateAndUpdateController.DisplayField displayfieldTest = new ASI_MFM_JP_MassCreateAndUpdateController.DisplayField('dummyLabel', 'dummyName');
        ASI_MFM_JP_MassCreateAndUpdateController.DisplayField displayfieldTest2 = new ASI_MFM_JP_MassCreateAndUpdateController.DisplayField('dummyLabel', 'dummyName', false);
      
        Boolean initPageBool = mcauCon.dummyVar;
        
        
        // Start testing user actions
        pageParams.put(mcauCon.PARAM_RTID, 'ASI_MFM_JP_Plan_Line_Item');
        Integer recordIndex = 0;
        //pageParams.put(mcauCon.PARAM_TRID, mcauCon.theRecordTypeElementList.get(recordIndex).myRecordList.get(0).id);    
        mcauCon.commitAll();
        
        mcauCon.enableForEdit();
        mcauCon.cloneRow();
        mcauCon.addNewRow();
        
        List<ASI_MFM_JP_MassCreateAndUpdateController.TableRow> recordList = mcauCon.theRecordTypeElementList.get(recordIndex).myRecordList;
        //pageParams.put(mcauCon.PARAM_TRID, recordList.get(recordList.size() - 1).id);
        mcauCon.removeNew();        
        mcauCon.addMoreBlankRows();
        
        //pageParams.put(mcauCon.PARAM_TRID, mcauCon.theRecordTypeElementList.get(recordIndex).myRecordList.get(0).id);
        mcauCon.deleteOld();
        
        mcauCon.clearAll();
        mcauCon.triggerPageBlockAction();
        
        // Test MassCreateAndUpdate 2 ********Added by 2017-05-24 Linus@Introv
        
        ASI_MFM_JP_MassCreateAndUpdateController mcauCon2 = new ASI_MFM_JP_MassCreateAndUpdateController();
        
        // Assign component attributes
        mcauCon2.isFastModeBool = false;
        mcauCon2.sObjTypeStr = 'ASI_MFM_Plan_Line_Item__c';
        mcauCon2.displayFieldsStr = 'ASI_MFM_Sub_brand_Code__c&req=T&width=160px,  ASI_MFM_AP_Code__c&req=T&width=160px,  ASI_MFM_A_C_Code__c&req=T&width=160px&key=AC Code,   ASI_MFM_List_Item_Description__c&req=T&width=240px,ASI_MFM_Quantity__c&req=F&width=50px, ASI_MFM_Unit_Cost__c&req=F&width=65px,  ASI_MFM_Total_Cost__c&req=T&width=105px';
        mcauCon2.fieldToURLParamStr = 'ASI_MFM_Plan__c=>id';
        mcauCon2.whereStatm = 'ASI_MFM_Plan__c  = \'' + p.Id + '\'';
        mcauCon2.orderByStr = 'Name';
        mcauCon2.pageBlockTitleStr = 'Plan  Line Items';
        mcauCon2.successLink = '/' + p.Id;
        mcauCon2.cancelLink = '/' + p.Id;
        mcauCon2.mode = 'BOTH';
        mcauCon2.isDefaultEditVal = true;
        mcauCon2.ShowAllRT = true;
        //mcauCon.disableClone= false;
        //mcauCon.disableAddNew=false;
        mcauCon2.isUseFirstRowForNew = true;
        mcauCon2.ComponentKey = 'massCreateAndUpdate';
        //mcauCon.PageController = testCon.thisController ;
        mcauCon2.languageSupportedStr ='';
        mcauCon2.lookupToPicklist = 'ASI_MFM_Sub_brand_Code__c,ASI_MFM_AP_Code__c,ASI_MFM_A_C_Code__c.ASI_MFM_A_C_Code__c=>ASI_MFM_AP_Code__c';
        mcauCon2.dummyMethod();
        mcauCon2.defaultFieldValuesStr = 'ASI_MFM_List_Item_Description__c=testremark';
        String[] ints3 = new String[]{'1/1/2001', '1/1/2002', '1/1/2003'};
        mcauCon2.checkDateTimeFieldSet = new Set<String>();
        mcauCon2.initDateFields(ints3);
        
        ASI_MFM_JP_MassCreateAndUpdateController.DisplayField displayfieldTest3 = new ASI_MFM_JP_MassCreateAndUpdateController.DisplayField('dummyLabel', 'dummyName');
        ASI_MFM_JP_MassCreateAndUpdateController.DisplayField displayfieldTest4 = new ASI_MFM_JP_MassCreateAndUpdateController.DisplayField('dummyLabel', 'dummyName', false);
      
        Boolean initPageBool2 = mcauCon2.dummyVar;
        
        
        // Start testing user actions
        pageParams.put(mcauCon2.PARAM_RTID, 'ASI_MFM_JP_Plan_Line_Item');
        Integer recordIndex2 = 0;
        //pageParams.put(mcauCon.PARAM_TRID, mcauCon.theRecordTypeElementList.get(recordIndex).myRecordList.get(0).id);    
        mcauCon2.commitAll();
        
        mcauCon2.enableForEdit();
        mcauCon2.cloneRow();
        mcauCon2.addNewRow();
        
        List<ASI_MFM_JP_MassCreateAndUpdateController.TableRow> recordList2 = mcauCon2.theRecordTypeElementList.get(recordIndex2).myRecordList;
        //pageParams.put(mcauCon.PARAM_TRID, recordList.get(recordList.size() - 1).id);
        mcauCon2.removeNew();        
        mcauCon2.addMoreBlankRows();
        
        //pageParams.put(mcauCon.PARAM_TRID, mcauCon.theRecordTypeElementList.get(recordIndex).myRecordList.get(0).id);
        mcauCon2.deleteOld();
        
        mcauCon2.clearAll();
        mcauCon2.triggerPageBlockAction();
        List<String> inputStrList = new List<String>();
        inputStrList.add('test');
        mcauCon2.strListToStr(inputStrList);
        mcauCon2.strListToStr(inputStrList, 'test');        
        
        test.stopTest();
        
    }
    static testMethod void testInputPOItemsController() {
        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', Plan_Type__c='test', ASI_MFM_Fiscal_year__c='FY1819');
        insert px; 
        
        user u = [select userRole.developerName from user where id = :userInfo.getUserId()];  
        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pr;
        
        ASI_MFM_Plan__c p = new ASI_MFM_Plan__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_JP_Plan'), name='test',
            ASI_MFM_End_Date__c=Date.today().addMonths(1), ASI_MFM_Plan_Description__c='testPlanDescription', 
                ASI_MFM_Plan_Name__c='testPlan', ASI_MFM_Start_Date__c=Date.today(), ASI_MFM_Prefix__c=px.id, ASI_MFM_Status__c = 'Final');
        insert p;
        
        ASI_MFM_Brand__c brand1 = new ASI_MFM_Brand__c(Name='Brand1', recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Brand__cASI_JP_Brand'));
        insert brand1;
        ASI_MFM_Sub_brand__c subBrand1 = new ASI_MFM_Sub_brand__c(Name='subBrand1', recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_JP_Sub_brand'), ASI_MFM_Brand__c=brand1.id);
        insert subBrand1;
        
        ASI_MFM_A_C_Code__c ac = new ASI_MFM_A_C_Code__c(name='testAC', recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_JP_A_C_Code'));
        insert ac;
        ASI_MFM_AP_Code__c ap = new ASI_MFM_AP_Code__c(name='testAP', recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_AP_Code__cASI_JP_AP_Code'));
        insert ap;
        
        List<Account> accToInsert = new List<Account>();
        Account acc2 = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_JP_Customer'), Name='Name3');           
        accToInsert.add(acc2);
        Account acc1 = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_JP_Supplier'),Name='Name2');           
        accToInsert.add(acc1);
        
        insert accToInsert;
        
        ASI_MFM_BU__c bu = new ASI_MFM_BU__c(name='testBU', recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_BU__cASI_MFM_JP_BU'));
        insert bu;
        
        ASI_MFM_Plan_Line_Item__c pi = new ASI_MFM_Plan_Line_Item__c(recordTypeId= Global_RecordTypeCache.getRtId('ASI_MFM_Plan_Line_Item__cASI_MFM_JP_Plan_Line_Item'), ASI_MFM_Plan__c=p.id,ASI_MFM_Customer_Name__c=acc2.id,ASI_MFM_BU_Code__c=bu.id
            ,ASI_MFM_Sub_brand_Code__c = subBrand1.id,ASI_MFM_A_C_Code__c=ac.id,ASI_MFM_AP_Code__c=ap.id, ASI_MFM_List_Item_Description__c='testDescription');   
        insert pi;  

        ASI_MFM_Prefix__c pxo = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO');
        insert pxo;
         
        ASI_MFM_Route_Type__c rt = new ASI_MFM_Route_Type__c(name='testRT',ASI_MFM_Module__c='PO');
        insert rt;
        
        ASI_MFM_Brand_Route_Type_Map__c rtm = new ASI_MFM_Brand_Route_Type_Map__c(ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Responsible_By__c=u.id,ASI_MFM_Prefix__c=pxo.id );
        insert rtm;
        
        ASI_MFM_Role_Prefix_Relationship__c pro = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pro;                   
        
        ASI_MFM_Route_Type_Brands_Relationship__c rtbr= new ASI_MFM_Route_Type_Brands_Relationship__c(ASI_MFM_Route_Type__c=rt.id,Brand_MFM__c=brand1.id);
        insert rtbr;
          date startDate = date.newInstance(Date.Today().Year(), Date.Today().Month(), 1);
        ASI_MFM_PO_Date_Range__c podr = new ASI_MFM_PO_Date_Range__c(Name='testPODR',ASI_MFM_PO_Start_Date__c=startDate,ASI_MFM_PO_End_Date__c=startDate.addDays(30),ASI_MFM_GL_Date__c=Date.today(),asi_mfm_next_number__c=1,ASI_MFM_Fiscal_Period__c='201404');
        insert podr;
        
        test.startTest();
        
        ASI_MFM_PO__c po = new ASI_MFM_PO__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_JP_PO'), name='test', ASI_MFM_Prefix__c=pxo.id, ASI_MFM_BU_Code__c=bu.id,
            ASI_MFM_Plan__c = p.id,ASI_MFM_Supplier_Name__c = acc1.id, ASI_MFM_Responsible_By__c=u.id,ASI_MFM_PO_Raised_Date__c=Date.today(),ASI_MFM_PO_Start_Date__c=Date.today(),ASI_MFM_PO_End_Date__c=Date.today()); 
        insert po;
          
        test.setCurrentPage(page.ASI_MFM_JP_InputPOItemsPage);
        apexpages.currentPage().getParameters().put('id', po.id); 
        list<ASI_MFM_PO__c> po_list = new list<ASI_MFM_PO__c>();
        apexpages.standardSetController sc = new apexpages.standardSetController(po_list);  
        ASI_MFM_InputPOItemsController cx = new ASI_MFM_InputPOItemsController(sc);  
        
        test.stopTest();
    }
    
    
     static testMethod void ASI_MFM_PDFTestPO() {
        Test.setCurrentPage(Page.ASI_MFM_JP_PO_PDF_Page);
        
        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', Plan_Type__c='test', ASI_MFM_Fiscal_year__c='FY1819');
        insert px; 
        
        user u = [select userRole.developerName from user where id = :userInfo.getUserId()];  
        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pr;
        
        ASI_MFM_Plan__c p = new ASI_MFM_Plan__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_JP_Plan'), name='test',
            ASI_MFM_End_Date__c=Date.today().addMonths(1), ASI_MFM_Plan_Description__c='testPlanDescription', 
                ASI_MFM_Plan_Name__c='testPlan', ASI_MFM_Start_Date__c=Date.today(), ASI_MFM_Prefix__c=px.id, ASI_MFM_Status__c = 'Final');
        insert p;
        
        ASI_MFM_Brand__c brand1 = new ASI_MFM_Brand__c(Name='Brand1', recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Brand__cASI_JP_Brand'));
        insert brand1;
        ASI_MFM_Sub_brand__c subBrand1 = new ASI_MFM_Sub_brand__c(Name='subBrand1', recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_JP_Sub_brand'), ASI_MFM_Brand__c=brand1.id);
        insert subBrand1;
        
        ASI_MFM_A_C_Code__c ac = new ASI_MFM_A_C_Code__c(name='testAC', recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_JP_A_C_Code'));
        insert ac;
        ASI_MFM_AP_Code__c ap = new ASI_MFM_AP_Code__c(name='testAP', recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_AP_Code__cASI_JP_AP_Code'));
        insert ap;
        
        List<Account> accToInsert = new List<Account>();
        Account acc2 = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_JP_Customer'), Name='Name3');           
        accToInsert.add(acc2);
        Account acc1 = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_JP_Supplier'),Name='Name2');           
        accToInsert.add(acc1);
        
        insert accToInsert;
         
        ASI_MFM_BU__c bu = new ASI_MFM_BU__c(name='testBU', recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_BU__cASI_MFM_JP_BU'));
        insert bu;
         
        ASI_MFM_Plan_Line_Item__c pi = new ASI_MFM_Plan_Line_Item__c(recordTypeId= Global_RecordTypeCache.getRtId('ASI_MFM_Plan_Line_Item__cASI_MFM_JP_Plan_Line_Item'), ASI_MFM_Plan__c=p.id,ASI_MFM_Customer_Name__c=acc2.id,ASI_MFM_BU_Code__c=bu.id
            ,ASI_MFM_Sub_brand_Code__c = subBrand1.id,ASI_MFM_A_C_Code__c=ac.id,ASI_MFM_AP_Code__c=ap.id, ASI_MFM_List_Item_Description__c='testDescription');   
        insert pi;  

        ASI_MFM_Prefix__c pxo = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO');
        insert pxo;
         
        ASI_MFM_Route_Type__c rt = new ASI_MFM_Route_Type__c(name='testRT',ASI_MFM_Module__c='PO');
        insert rt;
        
        //20170206 Wilken: Include 10 levels of approval for code coverage
        List<ASI_MFM_Route_Rule_Detail__c> rrdList = new List<ASI_MFM_Route_Rule_Detail__c>();
        for (Integer i=0;i<10;i++){
            ASI_MFM_Route_Rule_Detail__c rrd = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt.id);
            rrdList.add(rrd);
        }
        insert rrdList;
         
        ASI_MFM_Brand_Route_Type_Map__c rtm = new ASI_MFM_Brand_Route_Type_Map__c(ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Responsible_By__c=u.id,ASI_MFM_Prefix__c=pxo.id );
        insert rtm;
        
        ASI_MFM_Role_Prefix_Relationship__c pro = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pro;                   
        
        ASI_MFM_Route_Type_Brands_Relationship__c rtbr= new ASI_MFM_Route_Type_Brands_Relationship__c(ASI_MFM_Route_Type__c=rt.id,Brand_MFM__c=brand1.id);
        insert rtbr;
          date startDate = date.newInstance(Date.Today().Year(), Date.Today().Month(), 1);
        ASI_MFM_PO_Date_Range__c podr = new ASI_MFM_PO_Date_Range__c(Name='testPODR',ASI_MFM_PO_Start_Date__c=startDate,ASI_MFM_PO_End_Date__c=startDate.addDays(30),ASI_MFM_GL_Date__c=Date.today(),asi_mfm_next_number__c=1,ASI_MFM_Fiscal_Period__c='201404');
        insert podr;
        
        
        ASI_MFM_PO__c po = new ASI_MFM_PO__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_JP_PO'), name='test', ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Status__c='Draft',ASI_MFM_BU_Code__c=bu.id,
            ASI_MFM_Plan__c = p.id,ASI_MFM_Supplier_Name__c = acc1.id, ASI_MFM_Responsible_By__c=u.id,ASI_MFM_PO_Raised_Date__c=Date.today(),ASI_MFM_PO_Start_Date__c=Date.today(),ASI_MFM_PO_End_Date__c=Date.today()); 
        insert po;
        ASI_MFM_PO__c po1 = new ASI_MFM_PO__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_JP_PO'), name='test', ASI_MFM_Prefix__c=pxo.id, ASI_MFM_CLoned_PO_ID__c=po.id,ASI_MFM_Exchange_Rate__c=1,ASI_MFM_BU_Code__c=bu.id,
            ASI_MFM_Plan__c = p.id,ASI_MFM_Supplier_Name__c = acc1.id, ASI_MFM_Responsible_By__c=u.id,ASI_MFM_PO_Raised_Date__c=Date.today(),ASI_MFM_PO_Start_Date__c=Date.today(),ASI_MFM_PO_End_Date__c=Date.today()); 
        insert po1;  
        
         System.debug('Before start test: Total Number of SOQL Queries allowed in this apex code context: ' + Limits.getLimitQueries() + ' Now Used: ' + Limits.getQueries() ); 
        test.startTest();  
         System.debug('After start test 1: Total Number of SOQL Queries allowed in this apex code context: ' + Limits.getLimitQueries() + ' Now Used: ' + Limits.getQueries() );
        ASI_MFM_PO_Line_Item__c poi = new ASI_MFM_PO_Line_Item__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_JP_PO_Line_Item'), ASI_MFM_PO__c=po.id,ASI_MFM_BU_Code__c=bu.id,
            ASI_MFM_Spread_by_Months__c=true,ASI_MFM_A_C_Code__c=ac.id,ASI_MFM_AP_Code__c=ap.id, ASI_MFM_Customer_Name__c=acc2.id, ASI_MFM_List_Item_Description__c='testDescription', ASI_MFM_Sub_brand_Code__c=subBrand1.id, 
                ASI_MFM_G_L_Date__c = Date.today());
        insert poi;
        ASI_MFM_PO_Line_Item__c poi1 = new ASI_MFM_PO_Line_Item__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_JP_PO_Line_Item'), ASI_MFM_PO__c=po1.id,ASI_MFM_BU_Code__c=bu.id,
            ASI_MFM_Spread_by_Months__c=true,ASI_MFM_A_C_Code__c=ac.id,ASI_MFM_AP_Code__c=ap.id, ASI_MFM_Customer_Name__c=acc2.id, ASI_MFM_List_Item_Description__c='testDescription', ASI_MFM_Sub_brand_Code__c=subBrand1.id, 
                ASI_MFM_G_L_Date__c = Date.today());
        insert poi1;
         System.debug('After start test 2: Total Number of SOQL Queries allowed in this apex code context: ' + Limits.getLimitQueries() + ' Now Used: ' + Limits.getQueries() );
        Attachment attach=new Attachment();      
        attach.Name='Unit Test Attachment';
        Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
        attach.body=bodyBlob;
        attach.parentId=po.id;
        insert attach;
        List<Attachment> attachments=[select id, name from Attachment where parent.id=:po.id];
        System.assertEquals(1, attachments.size());
        System.debug('After start test 3: Total Number of SOQL Queries allowed in this apex code context: ' + Limits.getLimitQueries() + ' Now Used: ' + Limits.getQueries() );
        // Create an approval request for the account
        Approval.ProcessSubmitRequest req1 = 
            new Approval.ProcessSubmitRequest();
        req1.setComments('Submitting request for approval.');
        req1.setObjectId(po.id);
        
        // Submit the approval request for the account
        Approval.ProcessResult result = Approval.process(req1);
        System.debug('After start test 4: Total Number of SOQL Queries allowed in this apex code context: ' + Limits.getLimitQueries() + ' Now Used: ' + Limits.getQueries() );
        po.ASI_MFM_Status__c = 'Final';
        po.ASI_MFM_Exchange_Rate__c=0.5;
        //update po;
        System.debug('After start test 5: Total Number of SOQL Queries allowed in this apex code context: ' + Limits.getLimitQueries() + ' Now Used: ' + Limits.getQueries() );
        ASI_MFM_JP_PO_PDF_PageController ext = new ASI_MFM_JP_PO_PDF_PageController(new ApexPages.StandardController(po));
        ext.POID = po.id;
        ext.dummyVar = false;
        ext.dummyVar = true;
        ext.init();
         
         System.debug('After start test 6: Total Number of SOQL Queries allowed in this apex code context: ' + Limits.getLimitQueries() + ' Now Used: ' + Limits.getQueries() );
        test.stopTest(); 
    }
}