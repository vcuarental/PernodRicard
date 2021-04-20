/*********************************************************************************
 * Name:ASI_CRM_JP_PaymentInvoice_Test3
 * Description: Test Class for ASI CRM Payment Invoice CRM JP
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 5/1/2015         Laputa: Hank            Created
*********************************************************************************/
@isTest
private class ASI_CRM_JP_PaymentInvoice_Test3 {
    @testSetup
    static void setupTestData(){
        ASI_CRM_JP_TestClassHelper.createRunningNumbers();
    }
    
    //Test for Class ASI_CRM_JP_InputPaymentItemsController
    static testMethod void ASI_CRM_JP_InputPaymentItemsController_Test(){
        User u1 = ASI_CRM_JP_TestClassHelper.createUser();
        test.startTest();
        system.runAs(u1){
            
            List<ASI_CRM_Payment_Invoice__c> invoiceList = new List<ASI_CRM_Payment_Invoice__c>();
            ASI_CRM_Payment_Invoice__c invoice1 = new ASI_CRM_Payment_Invoice__c(ASI_CRM_Delivery_Time__c = '0000-1200',ASI_CRM_Status__c = 'Submitted', ownerId = u1.Id, RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Payment_Invoice__cASI_CRM_JP_SPTD_FOC_Invoice'));
            ASI_CRM_Payment_Invoice__c invoice2 = new ASI_CRM_Payment_Invoice__c(ASI_CRM_Delivery_Time__c = '0000-1200',ownerId = u1.Id, RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Payment_Invoice__cASI_CRM_JP_Indirect_Rebate_Invoice'));
            ASI_CRM_Payment_Invoice__c invoice3 = new ASI_CRM_Payment_Invoice__c(ASI_CRM_Delivery_Time__c = '0000-1200',ownerId = u1.Id, RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Payment_Invoice__cASI_CRM_JP_SPTD_Cash_Invoice'));
            ASI_CRM_Payment_Invoice__c invoice4 = new ASI_CRM_Payment_Invoice__c(ASI_CRM_Delivery_Time__c = '0000-1200',ownerId = u1.Id, RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Payment_Invoice__cASI_CRM_JP_Indirect_Rebate_Invoice_Read_Only'));
            ASI_CRM_Payment_Invoice__c invoice5 = new ASI_CRM_Payment_Invoice__c(ASI_CRM_Delivery_Time__c = '0000-1200',ownerId = u1.Id, RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Payment_Invoice__cASI_CRM_JP_SPTD_FOC_Invoice'));
            ASI_CRM_Payment_Invoice__c invoice6 = new ASI_CRM_Payment_Invoice__c(ASI_CRM_Delivery_Time__c = '0000-1200',ownerId = u1.Id, RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Payment_Invoice__cASI_CRM_JP_Cash_Invoice'));
            invoiceList.add(invoice1);
            invoiceList.add(invoice2);
            invoiceList.add(invoice3);
            invoiceList.add(invoice4);
            invoiceList.add(invoice5);
            invoiceList.add(invoice6);
            insert invoiceList;
            
            PageReference pageRef = Page.ASI_CRM_JP_InputPaymentItemsSPTDFOC_Page;
            pageRef.getParameters().put('Id', invoice1.Id);
            Test.setCurrentPage(pageRef);
            List<ASI_CRM_Payment_Invoice_Line_Item__c> invoiceItemsList = new List<ASI_CRM_Payment_Invoice_Line_Item__c>();
            ApexPages.StandardSetController ssc = new ApexPages.StandardSetController(invoiceItemsList);
            ASI_CRM_JP_InputPaymentItemsController controller = new ASI_CRM_JP_InputPaymentItemsController(ssc);
            
            pageRef = Page.ASI_CRM_JP_InputPaymentItemsRebate_Page;
            pageRef.getParameters().put('Id', invoice5.Id);
            Test.setCurrentPage(pageRef);
            controller = new ASI_CRM_JP_InputPaymentItemsController(ssc);
            
            pageRef = Page.ASI_CRM_JP_InputPaymentItemsRebate_Page;
            pageRef.getParameters().put('Id', invoice6.Id);
            Test.setCurrentPage(pageRef);
            controller = new ASI_CRM_JP_InputPaymentItemsController(ssc);
            
            pageRef = Page.ASI_CRM_JP_InputPaymentItemsRebate_Page;
            pageRef.getParameters().put('Id', invoice2.Id);
            Test.setCurrentPage(pageRef);
            controller = new ASI_CRM_JP_InputPaymentItemsController(ssc);
            
            pageRef = Page.ASI_CRM_JP_InputPaymentItemsSPTDCashPage ;
            pageRef.getParameters().put('Id', invoice3.Id);
            Test.setCurrentPage(pageRef);
            controller = new ASI_CRM_JP_InputPaymentItemsController(ssc);
            
            pageRef = Page.ASI_CRM_JP_InputPaymentItemsRebate_Page  ;
            pageRef.getParameters().put('Id', invoice4.Id);
            Test.setCurrentPage(pageRef);
            controller = new ASI_CRM_JP_InputPaymentItemsController(ssc);
            ASI_CRM_JP_MassCreateAndUpdateController mass = new ASI_CRM_JP_MassCreateAndUpdateController();
            mass.lookupToPicklist='hello,world';
            //mass.init();
            controller.recordtypeOpt = 'AP';
            controller.priceOption_Filter = 'Range';
            controller.PriceNumber_Filter1 = '5';
            controller.PriceNumber_Filter2 = '10';
            controller.FilterContractItems();
            controller.sobjst_initActionButtonList();
            controller.sobjst_initActionButtonStageMap();
            controller.mcau_initPageBlockActionButtonList();
            controller.selectAllContractItems();
            controller.checkPriceOption();
            controller.getIsCashRebate();
            controller.orderByAsc();
            controller.orderByDesc();
            controller.setComponentController(null);
            controller.getComponentController();
            
            controller.recordtypeOpt = 'Rebate';
            controller.getIsCashRebate();
            controller.priceOption_Filter = '=';
            controller.checkPriceOption();
            controller.FilterContractItems();
            
            controller.priceOption_Filter = '>';
            controller.FilterContractItems();
            
            controller.orderByOpt_Filter = 'Name';
            controller.orderByDirection = 'ASC';
            controller.priceOption_Filter = '<';
            controller.FilterContractItems();
            
            //controller.filterContractDates();
        }
        test.stopTest();
    }
    
    static testMethod void ASI_CRM_JP_InputPaymentItemsController_Test2(){
        date testDate = ASI_CRM_JP_TestClassHelper.createTestDate();       
        ASI_CRM_Purchase_Contract__c contract1 = new ASI_CRM_Purchase_Contract__c(ASI_CRM_Status__c='Activated', RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Purchase_Contract__cASI_CRM_JP_SPTD_Contract'), ASI_CRM_Start_Date__c = testDate, ASI_CRM_End_Date__c = testDate.addMonths(3));
        insert contract1;
        
        ASI_MFM_AP_Code__c ap = new ASI_MFM_AP_Code__c(Name='testAP', RecordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_AP_Code__cASI_CRM_JP_AP_Code'), ASI_CRM_FOC_Invoice__c = true);
       	insert ap;
        
        ASI_MFM_Item_Group__c item = ASI_CRM_JP_TestClassHelper.createItemGroup();
        insert item;
        List<ASI_CRM_Purchase_Contract_Line_Item__c> contractLineList = new List<ASI_CRM_Purchase_Contract_Line_Item__c>();
        
        ASI_CRM_Purchase_Contract_Line_Item__c line1 = new ASI_CRM_Purchase_Contract_Line_Item__c(ASI_CRM_Item_Group__c = item.id,recordtypeid = Global_RecordTypeCache.getRtId('ASI_CRM_Purchase_Contract_Line_Item__cASI_CRM_JP_SPTD_Contract_Line_Item'), ASI_CRM_Purchase_Contract__c = contract1.Id, ASI_CRM_Unit_Price__c  = 100, ASI_CRM_Quantity__c = 100, ASI_CRM_Target_Volume__c = 10000, ASI_CRM_Payment_Method__c='FOC w/o condition', ASI_CRM_AP_Code__c = ap.Id);
        contractLineList.add(line1);
        
        ASI_CRM_Purchase_Contract_Line_Item__c line2 = new ASI_CRM_Purchase_Contract_Line_Item__c(ASI_CRM_Item_Group__c = item.id,recordtypeid = Global_RecordTypeCache.getRtId('ASI_CRM_Purchase_Contract_Line_Item__cASI_CRM_JP_SPTD_Contract_Line_Item'), ASI_CRM_Purchase_Contract__c = contract1.Id, ASI_CRM_Unit_Price__c  = 100, ASI_CRM_Quantity__c = 100, ASI_CRM_Target_Volume__c = 10000, ASI_CRM_Payment_Method__c='FOC w/o condition', ASI_CRM_AP_Code__c = ap.Id);
        contractLineList.add(line2);
        
        ASI_CRM_Purchase_Contract_Line_Item__c line3 = new ASI_CRM_Purchase_Contract_Line_Item__c(ASI_CRM_Item_Group__c = item.id,recordtypeid = Global_RecordTypeCache.getRtId('ASI_CRM_Purchase_Contract_Line_Item__cASI_CRM_JP_SPTD_Contract_Line_Item'), ASI_CRM_Purchase_Contract__c = contract1.Id, ASI_CRM_Unit_Price__c  = 100, ASI_CRM_Quantity__c = 100, ASI_CRM_Target_Volume__c = 10000, ASI_CRM_Payment_Method__c='FOC w/o condition', ASI_CRM_AP_Code__c = ap.Id);
        contractLineList.add(line3);
        
        insert contractLineList;
        
        
        ASI_CRM_Payment_Invoice__c invoice1 = new ASI_CRM_Payment_Invoice__c(ASI_CRM_Delivery_Time__c = '0000-1200',ASI_CRM_Status__c = 'Submitted', RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Payment_Invoice__cASI_CRM_JP_SPTD_FOC_Invoice'));
        insert invoice1;
        Test.startTest(); 
        ASI_CRM_Payment_Invoice_Line_Item__c pyInvoiceLine = new ASI_CRM_Payment_Invoice_Line_Item__c(  
                                                                                                        RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Payment_Invoice_Line_Item__cASI_CRM_JP_SPTD_Cash_Invoice_Line_Item'),
                                                                                                        ASI_CRM_Purchase_Contract_Line_Item__c = line1.id,
                                                                                                        ASI_CRM_Payment_Invoice__c = invoice1.id,
                                                                                                        ASI_CRM_Actual_Quantity__c = 10,
                                                                                                        ASI_CRM_Actual_Unit_Cost__c = 20,
                                                                                                        ASI_CRM_Adjustment_Amount__c = 30
                                                                                                    );
        insert pyInvoiceLine;
        List<ASI_CRM_Payment_Invoice_Line_Item__c> pyInvoiceItemList = new List<ASI_CRM_Payment_Invoice_Line_Item__c>();
        pyInvoiceItemList.add(pyInvoiceLine);
        
        ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(pyInvoiceItemList);
        
        
        // Initialize the page
        PageReference testPage = Page.ASI_CRM_JP_InputPaymentItems_Page;
        Map<String, String> pageParams = testPage.getParameters();
        pageParams.put('id', invoice1.Id);
        Test.setCurrentPageReference(testPage);
        ASI_CRM_JP_InputPaymentItemsController testCon = new ASI_CRM_JP_InputPaymentItemsController(stdSetController);
        ASI_CRM_JP_MassCreateAndUpdateController mcauCon = new ASI_CRM_JP_MassCreateAndUpdateController();
        ASI_CRM_JP_SFObjSelectTableController sobjstCon = new ASI_CRM_JP_SFObjSelectTableController();
        
        // Assign component attributes
        mcauCon.isFastModeBool = false;
        mcauCon.sObjTypeStr = 'ASI_CRM_Payment_Invoice_Line_Item__c';
        mcauCon.displayFieldsStr = 'ASI_CRM_Purchase_Contract_Line_Item__c&read=A, ASI_CRM_AP_Code__c&read=A,ASI_CRM_Sys_BS_Retailer_Ship_To__c&read=A, ASI_CRM_SYS_Outlet__c&read=A, ASI_CRM_Item_Group__c&read=A,ASI_CRM_Sales_Result__c&req=F,' +
                                'ASI_CRM_Actual_Unit_Cost__c&read=A,ASI_CRM_Actual_Quantity__c&req=F,'+ 
                                'ASI_CRM_Actual_Amount__c&read=A,' +
                                'ASI_CRM_Remarks__c&req=F,ASI_CRM_A_P_Entertainment_F_D_Code__c&req=F';
        mcauCon.fieldToURLParamStr = 'ASI_CRM_Payment_Invoice__c=>id';
        mcauCon.whereStatm = 'ASI_CRM_Payment_Invoice__c = \'' + invoice1.Id + '\'';
        mcauCon.orderByStr = 'Name';
        mcauCon.pageBlockTitleStr = 'Payment Line Items';
        mcauCon.successLink = '/' + invoice1.Id;
        mcauCon.cancelLink = '/' + invoice1.Id;
        mcauCon.mode = 'BOTH';
        mcauCon.isDefaultEditVal = true;
        mcauCon.ShowAllRT = true;
        mcauCon.isUseFirstRowForNew = true;
        mcauCon.ComponentKey = 'massCreateAndUpdate';
        mcauCon.PageController = testCon.thisController;
        
        sobjstCon.sObjTypeStr = 'ASI_CRM_Purchase_Contract_Line_Item__c';
        sobjstCon.displayFieldsStr = 'Name, ASI_CRM_Purchase_Contract__c, ASI_CRM_Owner__c, ASI_CRM_BS_Retailer_Ship_To__c,ASI_CRM_Outlet__c,'+
                                  'ASI_CRM_Sys_AP_Code__c,' +
                                'ASI_CRM_Item_Group__c, ASI_CRM_Target_Volume__c, ASI_CRM_Condition__c, ASI_CRM_Quantity__c,' +
                                'ASI_CRM_Unit_Price__c, ASI_CRM_Promotion_Amount__c, ASI_CRM_Amount_Paid__c, ASI_CRM_Item_Group__r.name';
        sobjstCon.defWhereStatmStr = null;
        sobjstCon.orderByStr = 'ASI_CRM_Purchase_Contract__c';
        sobjstCon.numOfRowInTable = 8;
        sobjstCon.ComponentKey = 'selectTable';
        sobjstCon.PageController = testCon.thisController;
        mcauCon.lookupToPicklist='hello,world';
        Boolean initPageBool = mcauCon.dummyVar;
        
        
        initPageBool = sobjstCon.initDummyVar;
        
        // Start testing user actions
        pageParams.put(mcauCon.PARAM_RTID, 'ASI_CRM_JP_SPTD_FOC_Invoice_Line_Item');
       
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
   
        //mcauCon.enableForEdit();

        //mcauCon.cloneRow();
        
        //mcauCon.addNewRow();
        pageParams.put(mcauCon.PARAM_RTID, 'ASI_CRM_JP_SPTD_FOC_Invoice_Line_Item');
        List<ASI_CRM_JP_MassCreateAndUpdateController.TableRow> recordList = mcauCon.theRecordTypeElementList.get(recordIndex).myRecordList;
        pageParams.put(mcauCon.PARAM_TRID, recordList.get(recordList.size() - 1).id);
        //mcauCon.removeNew();        
        //mcauCon.addMoreBlankRows();

        // Change page number
        sobjstCon.nextPage();
        sobjstCon.lastPage();
        sobjstCon.prevPage();
        sobjstCon.firstPage();
          
        // Add product
        pageParams.put('PARAM_BTN_ID', 'add');
        pageParams.put('PARAM_SOBJ_ID', sobjstCon.tableEleList.get(0).sObj.Id);
        sobjstCon.triggerRowAction();
        
        // Remove old product
        pageParams.put(mcauCon.PARAM_RTID, 'ASI_CRM_JP_SPTD_FOC_Invoice_Line_Item');
        pageParams.put(mcauCon.PARAM_TRID, mcauCon.theRecordTypeElementList.get(recordIndex).myRecordList.get(0).id);
        //mcauCon.deleteOld();
        
        // Add product
        pageParams.put('PARAM_BTN_ID', 'add');
        pageParams.put('PARAM_SOBJ_ID', sobjstCon.tableEleList.get(0).sObj.Id);
        sobjstCon.triggerRowAction();
        
        sobjstCon.changePage();
        
        testCon.FilterContractItems();
        
        testCon.selectAllContractItems();
        
        testCon.mcau_triggerPageBlockAction(mcauCon, 'test');
        testCon.mcau_triggerActionForSObject(mcauCon, 'test', pyInvoiceLine);
        
        sobjstCon.setDataFilter('test');
        sobjstCon.setDataFilter('test', 'test');
        //sobjstCon.triggerRowAction('test', 'test');
        mcauCon.commitAll();
        mcauCon.commitAllQuickSave();
        Test.stopTest();
    }
    
}