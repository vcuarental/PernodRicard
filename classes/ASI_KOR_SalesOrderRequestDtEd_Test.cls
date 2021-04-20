@isTest
public class ASI_KOR_SalesOrderRequestDtEd_Test{
public static testMethod void test_main() {
    ASI_KOR_AccountGenerator acctGen = new ASI_KOR_AccountGenerator();
    ASI_KOR_BrandGenerator brandGen = new ASI_KOR_BrandGenerator();
      ASI_KOR_SubBrandGenerator sbGen = new ASI_KOR_SubBrandGenerator();
      ASI_KOR_ItemGroupGenerator igGen = new ASI_KOR_ItemGroupGenerator();
      ASI_KOR_SalesOrderRequestGenerator soReqGen = new ASI_KOR_SalesOrderRequestGenerator();
    
    Account ws = acctGen.generateAccount(ASI_KOR_AccountGenerator.RT_WS);
    insert ws;
    
    ASI_KOR_Brand__c brand = brandGen.generateBrand();
    insert brand;
    ASI_KOR_Sub_Brand__c sb = sbGen.generateSubBrand(brand);
    insert sb;
    List<ASI_KOR_Item_Group__c> itemGroups = new List<ASI_KOR_Item_Group__c>();
    for (Integer i = 0; i < 3; i++) {
      ASI_KOR_Item_Group__c tempIG = igGen.generateItemGroup(sb);
      itemGroups.add(tempIG);
    }
    insert itemGroups;
    
    ASI_KOR_Sales_Order_Request__c soReq = soReqGen.generateRequest(ws);
    soReq.recordtypeid = Global_RecordTypeCache.getRTId('ASI_KOR_Sales_Order_Request__cASI_KOR_New_Sales_Order');
    insert soReq;
    ASI_KOR_Sales_Order_Transaction__c soReqDetail = soReqGen.generateDetail(soReq, itemGroups.get(0));
    soReqDetail.recordtypeid = Global_RecordTypeCache.getRTId('ASI_KOR_Sales_Order_Transaction__cASI_CRM_SG_CA');
    insert soReqDetail;
    
    List<ASI_KOR_Sales_Order_Transaction__c> soReqDetails = [
      SELECT Id, Name, ASI_KOR_Sales_Order_Request__c, ASI_KOR_Item_Group_Code__c, ASI_KOR_Order_Qty__c
        , ASI_KOR_Product_Usage__c, ASI_KOR_SOT_UOM__c 
      FROM ASI_KOR_Sales_Order_Transaction__c
      WHERE ASI_KOR_Sales_Order_Request__c = :soReq.Id
    ];
    
    ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(soReqDetails);
    
    Test.startTest();
    
    // Initialize the page
    PageReference testPage = Page.ASI_KOR_SalesOrderRequestDtEdPage;
    Map<String, String> pageParams = testPage.getParameters();
    pageParams.put('id', soReq.Id);
    Test.setCurrentPageReference(testPage);
    ASI_KOR_SalesOrderRequestDtEdController testCon = new ASI_KOR_SalesOrderRequestDtEdController(stdSetController);
    ASI_KOR_MassCreateAndUpdateController mcauCon = new ASI_KOR_MassCreateAndUpdateController();
    ASI_KOR_SFObjSelectTableController sobjstCon = new ASI_KOR_SFObjSelectTableController();
    
    // Assign component attributes
    mcauCon.sObjTypeStr = 'ASI_KOR_Sales_Order_Transaction__c';
    mcauCon.displayFieldsStr = 'ASI_KOR_Item_Group_Code__c&req=T&read=A, ASI_KOR_Product_Usage__c&req=T, ASI_KOR_Order_Qty__c&req=T, ASI_KOR_SOT_UOM__c&req=T';
    mcauCon.whereStatm = 'ASI_KOR_Sales_Order_Request__c = \'' + testCon.soReqHeader.Id + '\'';
    mcauCon.pageBlockTitleStr = Schema.SObjectType.ASI_KOR_POSM_Order_Detail__c.getLabel();
    mcauCon.successLink = '/' + testCon.soReqHeader.Id;
    mcauCon.cancelLink = '/' + testCon.soReqHeader.Id;
    mcauCon.mode = 'NEW';
    mcauCon.showAllRT = true;
    mcauCon.isUseFirstRowForNew = false;
    mcauCon.componentKey = 'massCreateAndUpdate';
    mcauCon.pageController = testCon.thisController;
    
    sobjstCon.sObjTypeStr = 'ASI_KOR_Item_Group__c';
    sobjstCon.displayFieldsStr = 'Name, ASI_KOR_Name_Kor__c, ASI_KOR_Sub_Brand__c, ASI_KOR_KPI_Point_Value__c, ASI_KOR_Standard_Bottle_Size__c';
    sobjstCon.defWhereStatmStr = testCon.baseWhereStatm;
    sobjstCon.orderByStr = 'Name';
    sobjstCon.numOfRowInTable = 8;
    sobjstCon.componentKey = 'selectTable';
    sobjstCon.pageController = testCon.thisController;
    
    Boolean initPageBool = mcauCon.dummyVar;
    initPageBool = sobjstCon.initDummyVar;
    
    // Start testing user actions
    
    // Change page number
    sobjstCon.nextPage();
    sobjstCon.lastPage();
    sobjstCon.prevPage();
    sobjstCon.firstPage();
    
    // Filter products
    testCon.filterIGNameOrCode = itemGroups.get(1).Name;
    testCon.filterItemGroup();
    System.assertEquals(1, sobjstCon.tableEleList.size());
    
    // Add product
    pageParams.put('PARAM_BTN_ID', 'add');
    pageParams.put('PARAM_SOBJ_ID', sobjstCon.tableEleList.get(0).sObj.Id);
    sobjstCon.triggerRowAction();
    
    // Remove product
    pageParams.put(mcauCon.PARAM_RTID, ASI_KOR_MassCreateAndUpdateController.RTDEVNAME_MASTER);
    ASI_KOR_MassCreateAndUpdateController.TableRow tbRow = new ASI_KOR_MassCreateAndUpdateController.TableRow(mcauCon.theRecordTypeElementList.get(0), soReqDetail, false);
    mcauCon.theRecordTypeElementList.get(0).myRecordList.add(tbRow);
    pageParams.put(mcauCon.PARAM_TRID, mcauCon.theRecordTypeElementList.get(0).myRecordList.get(0).id);
    //mcauCon.removeNew();
    
    // Add product
    pageParams.put('PARAM_BTN_ID', 'add');
    pageParams.put('PARAM_SOBJ_ID', sobjstCon.tableEleList.get(0).sObj.Id);
    sobjstCon.triggerRowAction();
    
    // Set values
    mcauCon.theRecordTypeElementList.get(0).myRecordList.get(0).mySObj.put('ASI_KOR_Order_Qty__c', 2);
    
    // Save
    mcauCon.commitAll();
    
    soReqDetails = [
      SELECT Id FROM ASI_KOR_Sales_Order_Transaction__c WHERE ASI_KOR_Sales_Order_Request__c = :soReq.Id
    ];
    //System.assertEquals(2, soReqDetails.size());
    
    Test.stopTest();
  }
}