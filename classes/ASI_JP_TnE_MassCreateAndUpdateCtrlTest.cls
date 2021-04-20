@isTest
private class ASI_JP_TnE_MassCreateAndUpdateCtrlTest {

    @isTest
    public static void testTnEMassUpdateController()
    {
        ASI_HK_CRM_Running_Number__c runnNumber = new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c = 'ASI_JP_TnE_Document_Number', 
                                                                                   ASI_HK_CRM_Format__c = '{YY}{MM}{000}', 
                                                                                   ASI_HK_CRM_Running_Number__c = 0);
        insert runnNumber;
        
        ASI_JP_TnE_TestClassHelper.createDueDateMapping();   
        ASI_TnE_ClaimHeader__c  claimHeader = ASI_JP_TnE_TestClassHelper.createClaimHeaderPaperRecordType();
    
        List<ASI_TnE_ClaimDetail__c> claimDetails = ASI_JP_TnE_TestClassHelper.createClaimDetails(claimHeader);
        
        ApexPages.StandardController standardController = new ApexPages.StandardController(claimHeader);
        
        PageReference claimDetailPage = Page.ASI_JP_TnE_MassUpdateClaimDetailPage;
        Map<String, String> pageParams = claimDetailPage.getParameters();
        pageParams.put('id', claimHeader.Id);
        Test.setCurrentPageReference(claimDetailPage);
        
        ASI_JP_TnE_ClaimHeaderController claimHeaderController = new ASI_JP_TnE_ClaimHeaderController(standardController);
        
        ASI_TnE_ComponentInterface cController;
        claimHeaderController.dummyMethod();
        claimHeaderController.getUserLanguage();
        claimHeaderController.setComponentController(cController);
        claimHeaderController.getComponentController();
        claimHeaderController.getComponentController('testKey');
        
        ASI_JP_TnE_MassCreateAndUpdateController mcauCon = new  ASI_JP_TnE_MassCreateAndUpdateController();  
        
        mcauCon.isFastModeBool = false;
        mcauCon.sObjTypeStr = 'ASI_TnE_ClaimDetail__c';
        mcauCon.displayFieldsStr = 'ASI_TnE_Receipt_Date__c&req=T&width=80px, ' +
        ' ASI_TnE_Expense_Category__c&req=T&width=120px, ' +
        ' ASI_TnE_Expense_Classification__c&req=T&width=150px, ' +                     
        ' ASI_TnE_Currency__c&req=T&width=60px, ' +
        ' ASI_TnE_Receipt_Amount__c&req=T&width=120px, ' +
        ' ASI_TnE_FX_Rate__c&width=60px, ' +
        ' ASI_TnE_Receipt_Number__c&width=30px, ' +                                
        ' ASI_TnE_Total_Number_Pax__c&req=T&width=30px, ' +
        ' ASI_TnE_Attendee_Name__c&req=T&width=150px, ' +
        ' ASI_TnE_Details_of_Expense__c&width=150px';
        mcauCon.fieldToURLParamStr = 'ASI_TnE_ClaimHeader__c=>id';
        mcauCon.whereStatm = 'ASI_TnE_ClaimHeader__c= \'' + claimHeader.Id + '\'';
        mcauCon.orderByStr = 'Name';
        mcauCon.pageBlockTitleStr = 'Claim Header Items';
        mcauCon.successLink = '/' + claimHeader.Id;
        mcauCon.cancelLink = '/' + claimHeader.Id;
        mcauCon.mode = 'BOTH';
        mcauCon.isDefaultEditVal = true;
        mcauCon.showAllRT = false;
        mcauCon.isUseFirstRowForNew = true;
        mcauCon.includeRecordTypes='ASI_JP_TnE_Claim_Detail';
        mcauCon.componentKey = 'massCreateAndUpdate';
        mcauCon.PageController = claimHeaderController.thisController;
        mcauCon.languageSupportedStr ='en_US';
        mcauCon.lookupToPicklist = 'ASI_TnE_Expense_Category__c,ASI_TnE_Expense_Classification__c.ASI_JP_TnE_Expense_Category__c=>ASI_TnE_Expense_Category__c';
        
        mcauCon.dummyMethod();
        mcauCon.defaultFieldValuesStr = 'ASI_TnE_Currency__c=JPY,ASI_TnE_Total_Number_Pax__c=1';
        String[] ints2 = new String[]{'1/1/2001', '1/1/2002', '1/1/2003'};
        mcauCon.checkDateTimeFieldSet = new Set<String>();
        mcauCon.initDateFields(ints2);
        //mcauCon.theRecordTypeElementList = 
        //mcauCon.addNewRowByInfo('ASI_JP_TnE_eApproval_Claim_Header', claimHeader);
        //mcauCon.getTableRowBySObjId(claimHeader.Id);
        ASI_JP_TnE_MassCreateAndUpdateController.DisplayField displayfieldTest = new ASI_JP_TnE_MassCreateAndUpdateController.DisplayField('dummyLabel', 'dummyName');
        ASI_JP_TnE_MassCreateAndUpdateController.DisplayField displayfieldTest2 = new ASI_JP_TnE_MassCreateAndUpdateController.DisplayField('dummyLabel', 'dummyName', false);
        //PageBlockActionBtn testblock = new PageBlockActionBtn('dummyLabel', 'dummyName');  
         
        Boolean initPageBool = mcauCon.dummyVar;
        
        pageParams.put(mcauCon.PARAM_RTID, 'ASI_JP_TnE_Claim_Detail');
        
        Integer recordIndex = 0;
        
        pageParams.put(mcauCon.PARAM_TRID, mcauCon.theRecordTypeElementList.get(recordIndex).myRecordList.get(0).id);    
        
        mcauCon.commitAll();
        
        mcauCon.enableForEdit();
        mcauCon.cloneRow();
        mcauCon.addNewRow();
        
        List<ASI_JP_TnE_MassCreateAndUpdateController.TableRow> recordList = mcauCon.theRecordTypeElementList.get(recordIndex).myRecordList;
        pageParams.put(mcauCon.PARAM_TRID, recordList.get(recordList.size() - 1).id);
        mcauCon.removeNew();        
        mcauCon.addMoreBlankRows();
        
        pageParams.put(mcauCon.PARAM_TRID, mcauCon.theRecordTypeElementList.get(recordIndex).myRecordList.get(0).id);
        mcauCon.deleteOld();
        
        mcauCon.clearAll();
        mcauCon.triggerPageBlockAction();
    
    }    

}