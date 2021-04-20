@isTest
private class ASI_FOC_FreeGoodRequestDetailEditTest {
    
    static testMethod void FOCDetailEditTest() {
        final Integer numOfSKU = 5;
        final Integer numOfFGReqDetail = 2;
        
        ASI_FOC_SKUGenerator skuGen = new ASI_FOC_SKUGenerator();
        ASI_FOC_FreeGoodRequestGenerator fgReqGen = new ASI_FOC_FreeGoodRequestGenerator();
        ASI_FOC_FreeGoodRequestDetailGenerator fgReqDetailGen = new ASI_FOC_FreeGoodRequestDetailGenerator();
        
        List<ASI_MFM_SKU_Code__c> skuList = new List<ASI_MFM_SKU_Code__c>();
        ASI_FOC_Free_Goods_Request__c fgReq;
        List<ASI_FOC_Request_Item__c> fgReqDetailList = new List<ASI_FOC_Request_Item__c>();
        
        for (Integer i = 0; i < numOfSKU; i++) {
            skuList.add(skuGen.generateSKU(null));
        }
        insert skuList;

        String recordTypeID = Global_RecordTypeCache.getRTId('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract');
        ASI_TH_CRM_Contract__c contr = new ASI_TH_CRM_Contract__c(Name='Contract1', recordTypeId=recordTypeID,ASI_CRM_CN_Status__c = 'Final' );
        insert contr;
        
        fgReq = fgReqGen.generateTradeFreeGoodRequest();
        fgReq.ASI_CRM_CN_FG_Not_Applicable_ForCustomer__c = true;
        fgReq.ASI_FOC_Event_PO_Remarks__c = 'test';
        fgReq.ASI_CRM_CN_FG_Not_Applicable_ForEventPO__c = true;
        fgReq.ASI_CRM_CN_FG_Outlet_Remarks__c = 'test';
        fgReq.ASI_CRM_CN_FG_Trade_A_P_PO__c = contr.Id;
        insert fgReq;
        
        for (Integer i = 0; i < numOfFGReqDetail; i++) {
            fgReqDetailList.add(fgReqDetailGen.generateFreeGoodRequestDetail(fgReq, skuList[i]));
        }
        insert fgReqDetailList;
        
        ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(fgReqDetailList);
        
        Test.startTest();
        
        // Initialize the page
        PageReference testPage = Page.ASI_FOC_FreeGoodRequestDetailEditPage;
        Map<String, String> pageParams = testPage.getParameters();
        pageParams.put('id', fgReq.Id);
        Test.setCurrentPageReference(testPage);
        ASI_FOC_FreeGoodRequestDetailEditCON testCon = new ASI_FOC_FreeGoodRequestDetailEditCON(stdSetController);
        ASI_FOC_MassCreateAndUpdateController mcauCon = new ASI_FOC_MassCreateAndUpdateController();
        ASI_FOC_SFObjSelectTableController sobjstCon = new ASI_FOC_SFObjSelectTableController();
        
        // Assign component attributes
        mcauCon.isFastModeBool = false;
        mcauCon.sObjTypeStr = 'ASI_FOC_Request_Item__c';
        mcauCon.displayFieldsStr = 'ASI_FOC_SKU__c&read=A, ASI_FOC_Brand_Director_Approval_Status__c&read=A, ASI_FOC_Request_Quantity_Bottle__c&req=T';
        mcauCon.fieldToURLParamStr = 'ASI_FOC_Request_Order__c=>id';
        mcauCon.whereStatm = 'ASI_FOC_Brand_Director_Approval_Status__c != \'Rejected\' and ASI_FOC_Brand_Director_Approval_Status__c != \'Cancelled\' and ASI_FOC_Request_Order__c = \'' + fgReq.Id + '\'';
        mcauCon.orderByStr = 'Name';
        mcauCon.pageBlockTitleStr = 'Free Goods Request Items';
        mcauCon.successLinkStr = '/' + fgReq.Id;
        mcauCon.cancelLinkStr = '/' + fgReq.Id;
        mcauCon.modeStr = 'BOTH';
        mcauCon.isDefaultEditVal = true;
        mcauCon.isShowAllRT = true;
        mcauCon.isUseFirstRowForNew = false;
        mcauCon.myComponentKey = 'massCreateAndUpdate';
        mcauCon.myPageController = testCon.thisController;
        mcauCon.includeRecordTypesStr  = 'ASI_FOC_CN_Request_Item';
        
        sobjstCon.sObjTypeStr = 'ASI_MFM_SKU_Code__c';
        sobjstCon.displayFieldsStr = 'Name, ASI_MFM_SKU_Description__c, ASI_MFM_Sub_brand__c, ASI_FOC_SKU_Chinese_Description__c,ASI_FOC_Packing_Description__c';
        sobjstCon.defWhereStatmStr = testCon.baseWhereStatm;
        sobjstCon.orderByStr = 'ASI_MFM_SKU_Description__c';
        sobjstCon.numOfRowInTable = 8;
        sobjstCon.myComponentKey = 'selectTable';
        sobjstCon.myPageController = testCon.thisController;
        
        Boolean initPageBool = mcauCon.dummyVar;
        initPageBool = sobjstCon.initDummyVar;
        
        // Start testing user actions
        
        // Change page number
        sobjstCon.nextPage();
        sobjstCon.lastPage();
        sobjstCon.prevPage();
        sobjstCon.firstPage();
        
        // Clone product
        pageParams.put(mcauCon.PARAM_RTID, ASI_FOC_FreeGoodRequestDetailGenerator.RT_Default);
        pageParams.put(mcauCon.PARAM_TRID, mcauCon.theRecordTypeElementList.get(0).myRecordList.get(0).id);
        mcauCon.cloneRow();
        
        // Dummy test of enableForEdit
        pageParams.put(mcauCon.PARAM_RTID, ASI_FOC_FreeGoodRequestDetailGenerator.RT_Default);
        List<ASI_FOC_MassCreateAndUpdateController.TableRow> recordList = mcauCon.theRecordTypeElementList.get(0).myRecordList;
        pageParams.put(mcauCon.PARAM_TRID, recordList.get(recordList.size() - 1).id);
        mcauCon.enableForEdit();
        
        // Remove cloned product
        pageParams.put(mcauCon.PARAM_RTID, ASI_FOC_FreeGoodRequestDetailGenerator.RT_Default);
        recordList = mcauCon.theRecordTypeElementList.get(0).myRecordList;
        pageParams.put(mcauCon.PARAM_TRID, recordList.get(recordList.size() - 1).id);
        mcauCon.removeNew();
        
        // Filter products
        testCon.filterName = skuList[2].Name;
        testCon.filterSKU();
        System.assertEquals(1, sobjstCon.tableEleList.size());
        
        // Add product
        pageParams.put('PARAM_BTN_ID', 'add');
        pageParams.put('PARAM_SOBJ_ID', sobjstCon.tableEleList.get(0).sObj.Id);
        sobjstCon.triggerRowAction();
        
        // Remove old product
        pageParams.put(mcauCon.PARAM_RTID, ASI_FOC_FreeGoodRequestDetailGenerator.RT_Default);
        pageParams.put(mcauCon.PARAM_TRID, mcauCon.theRecordTypeElementList.get(0).myRecordList.get(0).id);
        mcauCon.deleteOld();
        
        // Remove new product
        pageParams.put(mcauCon.PARAM_RTID, ASI_FOC_FreeGoodRequestDetailGenerator.RT_Default);
        recordList = mcauCon.theRecordTypeElementList.get(0).myRecordList;
        pageParams.put(mcauCon.PARAM_TRID, recordList.get(recordList.size() - 1).id);
        mcauCon.removeNew();
        
        // Dummy test of addMoreBlankRows
        mcauCon.addMoreBlankRows();
        
        // Add product
        pageParams.put('PARAM_BTN_ID', 'add');
        pageParams.put('PARAM_SOBJ_ID', sobjstCon.tableEleList.get(0).sObj.Id);
        sobjstCon.triggerRowAction();
        
        // Set values
        mcauCon.theRecordTypeElementList.get(0).myRecordList.get(0).mySObj.put('ASI_FOC_Request_Quantity_Bottle__c', 5);
        
        // Save
        mcauCon.commitAll();
        mcauCon.cancelPage();
        
        fgReqDetailList = [
            SELECT Id FROM ASI_FOC_Request_Item__c WHERE ASI_FOC_Request_Order__c = :fgReq.Id
        ];
        System.assertEquals(numOfFGReqDetail, fgReqDetailList.size());
        
        Test.stopTest();
    }
    
    static testMethod void POSMDetailEditTest() {
        final Integer numOfSKU = 5;
        final Integer numOfFGReqDetail = 2;
        
        ASI_FOC_SKUGenerator skuGen = new ASI_FOC_SKUGenerator();
        ASI_FOC_FreeGoodRequestGenerator fgReqGen = new ASI_FOC_FreeGoodRequestGenerator();
        ASI_FOC_FreeGoodRequestDetailGenerator fgReqDetailGen = new ASI_FOC_FreeGoodRequestDetailGenerator();
        
        List<ASI_MFM_SKU_Code__c> skuList = new List<ASI_MFM_SKU_Code__c>();
        ASI_FOC_Free_Goods_Request__c fgReq;
        List<ASI_FOC_Request_Item__c> fgReqDetailList = new List<ASI_FOC_Request_Item__c>();
        
        for (Integer i = 0; i < numOfSKU; i++) {
            skuList.add(skuGen.generatePOSMSKU(null));
        }
        insert skuList;
        
        fgReq = fgReqGen.generatePOSMRequest();
        fgReq.ASI_MFM_ForPOSMCart__c = true;
        insert fgReq;
        
        for (Integer i = 0; i < numOfFGReqDetail; i++) {
            fgReqDetailList.add(fgReqDetailGen.generatePOSMDetail(fgReq, skuList[i]));
        }
        insert fgReqDetailList;
        
        ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(fgReqDetailList);
        
        Test.startTest();
        
        // Initialize the page
        PageReference testPage = Page.ASI_FOC_CN_POSMRequestDetailEditPage;
        Map<String, String> pageParams = testPage.getParameters();
        pageParams.put('id', fgReq.Id);
        Test.setCurrentPageReference(testPage);
        ASI_FOC_CN_POSMRequestDetailEditCON testCon = new ASI_FOC_CN_POSMRequestDetailEditCON(stdSetController);
        ASI_FOC_MassCreateAndUpdateController mcauCon = new ASI_FOC_MassCreateAndUpdateController();
        ASI_FOC_SFObjSelectTableController sobjstCon = new ASI_FOC_SFObjSelectTableController();
        
        // Assign component attributes
        mcauCon.isFastModeBool = false;
        mcauCon.sObjTypeStr = 'ASI_FOC_Request_Item__c';
        mcauCon.displayFieldsStr = 'ASI_FOC_SKU__c&read=A, ASI_FOC_CN_SKU_Description__c&read=A, ASI_FOC_CN_SKU_Chinese_Description__c&read=A,ASI_FOC_CN_Packing_Description__c&read=A,ASI_FOC_Unit_Cost_PC_BT__c&read=A, ASI_FOC_Original_Request_Quantity_PC_BT__c&req=T';
        mcauCon.fieldToURLParamStr = 'ASI_FOC_Request_Order__c=>id';
        mcauCon.whereStatm = 'ASI_FOC_Brand_Director_Approval_Status__c != \'Rejected\' and ASI_FOC_Brand_Director_Approval_Status__c != \'Cancelled\' and ASI_FOC_Request_Order__c = \'' + fgReq.Id + '\'';
        mcauCon.orderByStr = 'Name';
        mcauCon.pageBlockTitleStr = 'Free Goods Request Items';
        mcauCon.successLinkStr = '/' + fgReq.Id;
        mcauCon.cancelLinkStr = '/' + fgReq.Id;
        mcauCon.modeStr = 'BOTH';
        mcauCon.isDefaultEditVal = true;
        mcauCon.isShowAllRT = true;
        mcauCon.isUseFirstRowForNew = false;
        mcauCon.myComponentKey = 'massCreateAndUpdate';
        mcauCon.myPageController = testCon.thisController;
        mcauCon.includeRecordTypesStr  = 'ASI_FOC_CN_POSM_Request_Item'; 
        
        sobjstCon.sObjTypeStr = 'ASI_MFM_SKU_Code__c';
        sobjstCon.displayFieldsStr = 'ASI_MFM_Sub_brand__c, Name, ASI_MFM_SKU_Description__c,ASI_FOC_SKU_Chinese_Description__c, ASI_FOC_Packing_Description__c,ASI_FOC_Unit_Cost__c,ASI_HK_CRM_Available_Quantity__c';
        sobjstCon.defWhereStatmStr = testCon.baseWhereStatm;
        sobjstCon.orderByStr = 'ASI_MFM_SKU_Description__c';
        sobjstCon.numOfRowInTable = 8;
        sobjstCon.myComponentKey = 'selectTable';
        sobjstCon.myPageController = testCon.thisController;
        
        Boolean initPageBool = mcauCon.dummyVar;
        initPageBool = sobjstCon.initDummyVar;
        
        // Start testing user actions
        
        // Change page number
        sobjstCon.nextPage();
        sobjstCon.lastPage();
        sobjstCon.prevPage();
        sobjstCon.firstPage();
        
        // Clone product
        pageParams.put(mcauCon.PARAM_RTID, ASI_FOC_FreeGoodRequestDetailGenerator.RT_CN_POSM);
        pageParams.put(mcauCon.PARAM_TRID, mcauCon.theRecordTypeElementList.get(0).myRecordList.get(0).id);
        mcauCon.cloneRow();
        
        // Dummy test of enableForEdit
        pageParams.put(mcauCon.PARAM_RTID, ASI_FOC_FreeGoodRequestDetailGenerator.RT_CN_POSM);
        List<ASI_FOC_MassCreateAndUpdateController.TableRow> recordList = mcauCon.theRecordTypeElementList.get(0).myRecordList;
        pageParams.put(mcauCon.PARAM_TRID, recordList.get(recordList.size() - 1).id);
        mcauCon.enableForEdit();
        
        // Remove cloned product
        pageParams.put(mcauCon.PARAM_RTID, ASI_FOC_FreeGoodRequestDetailGenerator.RT_CN_POSM);
        recordList = mcauCon.theRecordTypeElementList.get(0).myRecordList;
        pageParams.put(mcauCon.PARAM_TRID, recordList.get(recordList.size() - 1).id);
        mcauCon.removeNew();
        
        // Filter products
        testCon.filterName = skuList[2].Name;
        testCon.filterSKU();
        //System.assertEquals(1, sobjstCon.tableEleList.size());
        
        // Add product
        pageParams.put('PARAM_BTN_ID', 'add');
        //pageParams.put('PARAM_SOBJ_ID', sobjstCon.tableEleList.get(0).sObj.Id);
        sobjstCon.triggerRowAction();
        
        // Remove old product
        pageParams.put(mcauCon.PARAM_RTID, ASI_FOC_FreeGoodRequestDetailGenerator.RT_CN_POSM);
        pageParams.put(mcauCon.PARAM_TRID, mcauCon.theRecordTypeElementList.get(0).myRecordList.get(0).id);
        mcauCon.deleteOld();
        
        // Remove new product
        pageParams.put(mcauCon.PARAM_RTID, ASI_FOC_FreeGoodRequestDetailGenerator.RT_CN_POSM);
        recordList = mcauCon.theRecordTypeElementList.get(0).myRecordList;
        pageParams.put(mcauCon.PARAM_TRID, recordList.get(recordList.size() - 1).id);
        mcauCon.removeNew();
        
        // Dummy test of addMoreBlankRows
        mcauCon.addMoreBlankRows();
        
        // Add product
        pageParams.put('PARAM_BTN_ID', 'add');
        //pageParams.put('PARAM_SOBJ_ID', sobjstCon.tableEleList.get(0).sObj.Id);
        sobjstCon.triggerRowAction();
        
        // Set values
        mcauCon.theRecordTypeElementList.get(0).myRecordList.get(0).mySObj.put('ASI_FOC_Original_Request_Quantity_PC_BT__c', 5);
        
        // Save
        mcauCon.commitAll();
        mcauCon.cancelPage();
        
        fgReqDetailList = [
            SELECT Id FROM ASI_FOC_Request_Item__c WHERE ASI_FOC_Request_Order__c = :fgReq.Id
        ];
        //System.assertEquals(numOfFGReqDetail, fgReqDetailList.size());
        
        Test.stopTest();
    }
}