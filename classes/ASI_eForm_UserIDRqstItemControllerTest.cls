@isTest
private class ASI_eForm_UserIDRqstItemControllerTest
{
  @isTest
  public static void testUserIDRequestItem()
  {
    User currentUser = ASI_eForm_TestClassHelper.createUser();
    Map<String,User> userMap = new Map<String,User>();
    userMap.put('owner',currentUser);  
    
     Map<String,ASI_eForm_PR_System__c> systemMap = ASI_eForm_TestClassHelper.createSystem(userMap);
    Map<String,ASI_eForm_Permission_Type__c> permissionTypeMap = ASI_eForm_TestClassHelper.createSystemPermissionType(systemMap);
    ASI_eForm_User_ID_Request__c  userIDRequest = ASI_eForm_TestClassHelper.createUserIDRequest(userMap);  
    List<ASI_eForm_User_ID_Request_Item__c>  userIDRequestItems = 
    ASI_eForm_TestClassHelper.createUserIDRequestItem(userIDRequest,userMap,permissionTypeMap);    
    
    Map<String, ASI_eForm_User_Profile__c> userProfileMap = ASI_eForm_TestClassHelper.createUserProfile();
    ASI_eForm_TestClassHelper.createSystemPermission(userMap,permissionTypeMap, userProfileMap.get('userProfile'));
  
    ApexPages.StandardSetController standardSetController =
      new ApexPages.StandardSetController(userIDRequestItems);
  
    PageReference inputUserIDRequestItemPage = Page.ASI_eForm_InputUserIDRequestItemPage;
    Map<String, String> pageParams = inputUserIDRequestItemPage.getParameters();
    pageParams.put('id', userIDRequest.Id);
  
    Test.setCurrentPageReference(inputUserIDRequestItemPage);
  
     ASI_eForm_UserIDRequestItemController userIDRequestItemController = new
        ASI_eForm_UserIDRequestItemController(standardSetController);
             
     userIdRequestItemController.getComponentController();   
    
   ASI_eForm_MassCreateAndUpdateController mcauCon = new  ASI_eForm_MassCreateAndUpdateController();  
        mcauCon.isFastModeBool = false;
        mcauCon.sObjTypeStr = 'ASI_eForm_User_ID_Request_Item__c';
        mcauCon.displayFieldsStr = 'ASI_eForm_PR_System__c&read=A&width=150px,ASI_eForm_Permission_TypeN__c&req=T&width=150px,ASI_eForm_BO_Additional_Remarks__c&req=F&width=150px,ASI_eForm_Permission_Action__c&read=A&width=150px,ASI_eForm_Remarks__c&req=F';
        mcauCon.fieldToURLParamStr = 'ASI_eForm_User_ID_Request__c=>id';
        mcauCon.whereStatm = 'ASI_eForm_User_ID_Request__c= \'' + userIDRequest.Id + '\'';
        mcauCon.orderByStr = 'Name';
        mcauCon.pageBlockTitleStr = 'User ID Request Items';
        mcauCon.successLink = '/' + userIDRequest.Id;
        mcauCon.cancelLink = '/' + userIDRequest.Id;
        mcauCon.mode = 'BOTH';
        mcauCon.isDefaultEditVal = true;
        mcauCon.showAllRT = false;
        mcauCon.isUseFirstRowForNew = true;
        mcauCon.includeRecordTypes='ASI_eForm_User_ID_Request_Item';
        mcauCon.componentKey = 'massCreateAndUpdate';
        mcauCon.PageController = userIDRequestItemController.thisController;
        mcauCon.lookupToPicklist='ASI_eForm_PR_System__c,ASI_eForm_Permission_TypeN__c.ASI_eForm_PR_System__c=>ASI_eForm_PR_System__c';
        mcauCon.isReadOnlyDeleteFilter='ASI_eForm_Permission_Action__c=Delete';
        
        Boolean initPageBool = mcauCon.dummyVar; 
        pageParams.put(mcauCon.PARAM_RTID, 'ASI_eForm_User_ID_Request_Item');        
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
        
        
        ASI_eForm_UserIDRequestItemController.Section3Controller section3Controller =
         new ASI_eForm_UserIDRequestItemController.Section3Controller(userIDRequestItemController);
        
        ASI_eForm_SFObjSelectTableController sobjstCon3 = new ASI_eForm_SFObjSelectTableController();
        sobjstCon3.sObjTypeStr = 'ASI_eForm_PR_System__c';
        sobjstCon3.displayFieldsStr = 'ASI_eForm_System_Key__c,name,ASI_eForm_System_Description__c';
        sobjstCon3.defWhereStatmStr = ' Name != null ';
        sobjstCon3.orderByStr = 'Name';
        sobjstCon3.numOfRowInTable = 8;
        sobjstCon3.ComponentKey = 'selectTable';
        sobjstCon3.PageController = section3Controller;
        
        initPageBool = sobjstCon3.initDummyVar;

        // Add Object
        pageParams.put('PARAM_BTN_ID', 'add');
        pageParams.put('PARAM_SOBJ_ID', sobjstCon3.tableEleList.get(0).sObj.Id);
        sobjstCon3.triggerRowAction();
        
        section3Controller.getComponentController();
        section3Controller.getComponentController('test');
        
        ASI_eForm_UserIDRequestItemController.Section4Controller section4Controller =
         new ASI_eForm_UserIDRequestItemController.Section4Controller(userIDRequestItemController);
        
        ASI_eForm_SFObjSelectTableController sobjstCon4 = new ASI_eForm_SFObjSelectTableController();
        sobjstCon4.sObjTypeStr = 'ASI_eForm_User_System_Permission__c';
        sobjstCon4.displayFieldsStr = 'ASI_eForm_PR_System__c, ASI_eForm_Permission_TypeN__c, ASI_eForm_BO_Additional_Remarks__c';
        sobjstCon4.defWhereStatmStr = ' Name != null ';
        sobjstCon4.orderByStr = 'Name';
        sobjstCon4.numOfRowInTable = 8;
        sobjstCon4.ComponentKey = 'selectTable4';
        sobjstCon4.PageController = section4Controller;
        
        initPageBool = sobjstCon4.initDummyVar;

        // Add Object
        pageParams.put('PARAM_BTN_ID', 'add');
        pageParams.put('PARAM_SOBJ_ID', sobjstCon4.tableEleList.get(0).sObj.Id);
        sobjstCon4.triggerRowAction();
        
        section4Controller.getComponentController();
        section4Controller.getComponentController('test');
        
        userIdRequestItemController.setComponentController(null);  
  }
}