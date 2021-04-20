@isTest
private class ASI_eForm_ITChangeRequestControllerTest
{
  
  @isTest
  public static void testITChangeRequestControllerCN()
  {
      User currentUser = ASI_eForm_TestClassHelper.createUser();
      Map<String,User> mapUser = new Map<String,User>();
      mapUser.put('owner',currentUser);
      
      ASI_eForm_TestClassHelper.createRunningNumbers();
      
      ASI_eForm_IT_Change_Request__c  itChangeRequest = ASI_eForm_TestClassHelper.createITChangeRequestCN(mapUser);  
      List<ASI_eForm_IT_Change_Request_Item__c>  itChangeRequestItems = 
        ASI_eForm_TestClassHelper.createITChangeRequestItems(itChangeRequest,mapUser);    
      
      ApexPages.StandardSetController standardSetController = new ApexPages.StandardSetController(itChangeRequestItems);
      
      PageReference itChangeRequestItemPage = Page.ASI_eForm_InputITChangeRequestPage;
      Map<String, String> pageParams = itChangeRequestItemPage.getParameters();
        pageParams.put('id', itChangeRequest.Id);
      
      Test.setCurrentPageReference(itChangeRequestItemPage);
      
      ASI_eForm_CN_ITChangeRequestController itChangeRequestController = new
         ASI_eForm_CN_ITChangeRequestController(standardSetController);
         
     ASI_eForm_MassCreateAndUpdateController mcauCon = new  ASI_eForm_MassCreateAndUpdateController();  
        mcauCon.isFastModeBool = false;
        mcauCon.sObjTypeStr = 'ASI_eForm_IT_Change_Request_Item__c';
        mcauCon.displayFieldsStr = 'ASI_eForm_Context__c&req=T&width=100, ASI_eForm_IT_Handle_By__c&req=F&width=120,ASI_eForm_IT_Remarks__c&req=F&width=120';
        mcauCon.fieldToURLParamStr = 'ASI_eForm_IT_Change_Request__c=>id';
        mcauCon.whereStatm = 'ASI_eForm_IT_Change_Request__c= \'' + itChangeRequest.Id + '\'';
        mcauCon.orderByStr = 'Name';
        mcauCon.pageBlockTitleStr = 'IT Change Request';
        mcauCon.successLink = '/' + itChangeRequest.Id;
        mcauCon.cancelLink = '/' + itChangeRequest.Id;
        mcauCon.mode = 'BOTH';
        mcauCon.isDefaultEditVal = true;
        mcauCon.showAllRT = false;
        mcauCon.isUseFirstRowForNew = true;
        mcauCon.includeRecordTypes='ASI_eForm_IT_Change_Request_Item';
        mcauCon.componentKey = 'massCreateAndUpdate';
        mcauCon.PageController = itChangeRequestController.thisController;
        mcauCon.lookupToPicklist = '';        
        mcauCon.defaultFieldValuesStr = 'ASI_eForm_IT_Remarks__c=Test,ASI_eForm_Sys_Count__c=0';
        Boolean initPageBool = mcauCon.dummyVar; 
        pageParams.put(mcauCon.PARAM_RTID, 'ASI_eForm_IT_Change_Request_Item');        
        Integer recordIndex = 0;        
        pageParams.put(mcauCon.PARAM_TRID, mcauCon.theRecordTypeElementList.get(recordIndex).myRecordList.get(0).id);    
        mcauCon.commitAll();        
        mcauCon.enableForEdit();
        mcauCon.cloneRow();
        mcauCon.addNewRow();        
        List<ASI_eForm_MassCreateAndUpdateController.TableRow> recordList = mcauCon.theRecordTypeElementList.get(recordIndex).myRecordList;
        pageParams.put(mcauCon.PARAM_TRID, recordList.get(recordList.size() - 1).id);
        mcauCon.removeNew();        
        mcauCon.addMoreBlankRows();        
        pageParams.put(mcauCon.PARAM_TRID, mcauCon.theRecordTypeElementList.get(recordIndex).myRecordList.get(0).id);
        mcauCon.deleteOld();        
        mcauCon.clearAll();
        mcauCon.triggerPageBlockAction();
        
        ASI_eForm_SFObjSelectTableController sobjstCon = new ASI_eForm_SFObjSelectTableController();
        sobjstCon.sObjTypeStr = 'ASI_eForm_Context__c';
        sobjstCon.displayFieldsStr = 'ASI_eForm_Context_Key__c,Name,ASI_eForm_Context_Description__c';
        sobjstCon.defWhereStatmStr = ' Name != null ';
        sobjstCon.orderByStr = 'Name';
        sobjstCon.numOfRowInTable = 8;
        sobjstCon.ComponentKey = 'selectTable';
        sobjstCon.PageController = itChangeRequestController.thisController;
        
        initPageBool = sobjstCon.initDummyVar;
                  
         // Change page number
        sobjstCon.nextPage();
        sobjstCon.lastPage();
        sobjstCon.prevPage();
        sobjstCon.firstPage();
        
        // Add product
        pageParams.put('PARAM_BTN_ID', 'add');
        pageParams.put('PARAM_SOBJ_ID', sobjstCon.tableEleList.get(0).sObj.Id);
        sobjstCon.triggerRowAction();
        
        sobjstCon.setDataFilter(' name = \'Email\' ');
        sobjstCon.reloadData();
  
  }
  
  @isTest
  public static void testITChangeRequestController()
  {
      User currentUser = ASI_eForm_TestClassHelper.createUser();
      Map<String,User> mapUser = new Map<String,User>();
      mapUser.put('owner',currentUser);
      
      ASI_eForm_TestClassHelper.createRunningNumbers();
      
      ASI_eForm_IT_Change_Request__c  itChangeRequest = ASI_eForm_TestClassHelper.createITChangeRequest(mapUser);  
      List<ASI_eForm_IT_Change_Request_Item__c>  itChangeRequestItems = 
        ASI_eForm_TestClassHelper.createITChangeRequestItems(itChangeRequest,mapUser);    
      
      ApexPages.StandardSetController standardSetController = new ApexPages.StandardSetController(itChangeRequestItems);
      
      PageReference itChangeRequestItemPage = Page.ASI_eForm_InputITChangeRequestPage;
      Map<String, String> pageParams = itChangeRequestItemPage.getParameters();
        pageParams.put('id', itChangeRequest.Id);
      
      Test.setCurrentPageReference(itChangeRequestItemPage);
      
      ASI_eForm_ITChangeRequestController itChangeRequestController = new
         ASI_eForm_ITChangeRequestController(standardSetController);
         
     ASI_eForm_MassCreateAndUpdateController mcauCon = new  ASI_eForm_MassCreateAndUpdateController();  
        mcauCon.isFastModeBool = false;
        mcauCon.sObjTypeStr = 'ASI_eForm_IT_Change_Request_Item__c';
        mcauCon.displayFieldsStr = 'ASI_eForm_Context__c&req=T&width=100, ASI_eForm_IT_Handle_By__c&req=F&width=120,ASI_eForm_IT_Remarks__c&req=F&width=120';
        mcauCon.fieldToURLParamStr = 'ASI_eForm_IT_Change_Request__c=>id';
        mcauCon.whereStatm = 'ASI_eForm_IT_Change_Request__c= \'' + itChangeRequest.Id + '\'';
        mcauCon.orderByStr = 'Name';
        mcauCon.pageBlockTitleStr = 'IT Change Request';
        mcauCon.successLink = '/' + itChangeRequest.Id;
        mcauCon.cancelLink = '/' + itChangeRequest.Id;
        mcauCon.mode = 'BOTH';
        mcauCon.isDefaultEditVal = true;
        mcauCon.showAllRT = false;
        mcauCon.isUseFirstRowForNew = true;
        mcauCon.includeRecordTypes='ASI_eForm_IT_Change_Request_Item';
        mcauCon.componentKey = 'massCreateAndUpdate';
        mcauCon.PageController = itChangeRequestController.thisController;
        mcauCon.lookupToPicklist = '';        
        mcauCon.defaultFieldValuesStr = 'ASI_eForm_IT_Remarks__c=Test,ASI_eForm_Sys_Count__c=0';
        Boolean initPageBool = mcauCon.dummyVar; 
        pageParams.put(mcauCon.PARAM_RTID, 'ASI_eForm_IT_Change_Request_Item');        
        Integer recordIndex = 0;        
        pageParams.put(mcauCon.PARAM_TRID, mcauCon.theRecordTypeElementList.get(recordIndex).myRecordList.get(0).id);    
        mcauCon.commitAll();        
        mcauCon.enableForEdit();
        mcauCon.cloneRow();
        mcauCon.addNewRow();        
        List<ASI_eForm_MassCreateAndUpdateController.TableRow> recordList = mcauCon.theRecordTypeElementList.get(recordIndex).myRecordList;
        pageParams.put(mcauCon.PARAM_TRID, recordList.get(recordList.size() - 1).id);
        mcauCon.removeNew();        
        mcauCon.addMoreBlankRows();        
        pageParams.put(mcauCon.PARAM_TRID, mcauCon.theRecordTypeElementList.get(recordIndex).myRecordList.get(0).id);
        mcauCon.deleteOld();        
        mcauCon.clearAll();
        mcauCon.triggerPageBlockAction();
        
        ASI_eForm_SFObjSelectTableController sobjstCon = new ASI_eForm_SFObjSelectTableController();
        sobjstCon.sObjTypeStr = 'ASI_eForm_Context__c';
        sobjstCon.displayFieldsStr = 'ASI_eForm_Context_Key__c,Name,ASI_eForm_Context_Description__c';
        sobjstCon.defWhereStatmStr = ' Name != null ';
        sobjstCon.orderByStr = 'Name';
        sobjstCon.numOfRowInTable = 8;
        sobjstCon.ComponentKey = 'selectTable';
        sobjstCon.PageController = itChangeRequestController.thisController;
        
        initPageBool = sobjstCon.initDummyVar;
                  
         // Change page number
        sobjstCon.nextPage();
        sobjstCon.lastPage();
        sobjstCon.prevPage();
        sobjstCon.firstPage();
        
        // Add product
        pageParams.put('PARAM_BTN_ID', 'add');
        pageParams.put('PARAM_SOBJ_ID', sobjstCon.tableEleList.get(0).sObj.Id);
        sobjstCon.triggerRowAction();
        
        sobjstCon.setDataFilter(' name = \'Email\' ');
        sobjstCon.reloadData();
  
  }

}