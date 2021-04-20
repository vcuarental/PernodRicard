@isTest
public class ASI_KOR_POSMOrderRequestDtEdit_Test{

public static testMethod void test_main() {
    ASI_KOR_AccountGenerator acctGen = new ASI_KOR_AccountGenerator();
    ASI_KOR_POSMProductGenerator posmPdGen = new ASI_KOR_POSMProductGenerator();
    ASI_KOR_POSMOrderRequestGenerator posmReqGen = new ASI_KOR_POSMOrderRequestGenerator();
    
    Account venue = acctGen.generateAccount(ASI_KOR_AccountGenerator.RT_Venue);
    insert venue;
    
    ASI_KOR_POSM_Product_Brand__c brand = posmPdGen.generateBasicBrand();
    insert brand;
    ASI_KOR_POSM_Product_Sub_Brand__c sb = posmPdGen.generateBasicSubBrand(brand);
    insert sb;
    List<ASI_KOR_POSM_Product__c> posmPds = new List<ASI_KOR_POSM_Product__c>();
    for (Integer i = 0; i < 3; i++) {
      ASI_KOR_POSM_Product__c tempPosmPd = posmPdGen.generateProduct(sb);
      posmPds.add(tempPosmPd);
    }
    insert posmPds;
    
    ASI_KOR_POSM_Order_Request__c posmReq = posmReqGen.generateRequest(venue);
    insert posmReq;
    ASI_KOR_POSM_Order_Detail__c posmReqDetail = posmReqGen.generateDetail(posmReq, posmPds.get(0));
    insert posmReqDetail;
    
    List<ASI_KOR_POSM_Order_Detail__c> posmReqDetails = [
      SELECT Id, Name, ASI_KOR_POSM_Order_Request__c, ASI_KOR_Item_Name__c, ASI_KOR_Quantity__c 
      FROM ASI_KOR_POSM_Order_Detail__c
      WHERE ASI_KOR_POSM_Order_Request__c = :posmReq.Id
    ];
    
    ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(posmReqDetails);
    
    Test.startTest();
    
    // Initialize the page
    PageReference testPage = Page.ASI_KOR_POSMOrderRequestDtEditPage;
    Map<String, String> pageParams = testPage.getParameters();
    pageParams.put('id', posmReq.Id);
    Test.setCurrentPageReference(testPage);
    ASI_KOR_POSMOrderRequestDtEditController testCon = new ASI_KOR_POSMOrderRequestDtEditController(stdSetController);
    ASI_KOR_MassCreateAndUpdateController mcauCon = new ASI_KOR_MassCreateAndUpdateController();
    ASI_KOR_SFObjSelectTableController sobjstCon = new ASI_KOR_SFObjSelectTableController();
    
    // Assign component attributes
    mcauCon.sObjTypeStr = 'ASI_KOR_POSM_Order_Detail__c';
    mcauCon.displayFieldsStr = 'ASI_KOR_Item_Name__c&req=T&read=A, ASI_KOR_Quantity__c&req=T';
    mcauCon.whereStatm = 'ASI_KOR_POSM_Order_Request__c = \'' + testCon.posmReqHeader.Id + '\'';
    mcauCon.pageBlockTitleStr = Schema.SObjectType.ASI_KOR_POSM_Order_Detail__c.getLabel();
    mcauCon.successLink = '/' + testCon.posmReqHeader.Id;
    mcauCon.cancelLink = '/' + testCon.posmReqHeader.Id;
    mcauCon.mode = 'NEW';
    mcauCon.showAllRT = true;
    mcauCon.isUseFirstRowForNew = false;
    mcauCon.componentKey = 'massCreateAndUpdate';
    mcauCon.pageController = testCon.thisController;
    
    sobjstCon.sObjTypeStr = 'ASI_KOR_POSM_Product__c';
    sobjstCon.displayFieldsStr = 'Name, ASI_KOR_Item_Name_Kor__c, ASI_KOR_Item_Code__c, ASI_KOR_Type__c, ASI_KOR_Unit_Case__c, ASI_KOR_UOM__c';
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
    testCon.filterNameOrCode = posmPds.get(1).Name;
    testCon.filterPOSMProduct();
    System.assertEquals(1, sobjstCon.tableEleList.size());
    
    // Add product
    pageParams.put('PARAM_BTN_ID', 'add');
    pageParams.put('PARAM_SOBJ_ID', sobjstCon.tableEleList.get(0).sObj.Id);
    sobjstCon.triggerRowAction();
    
    // Remove product
   // pageParams.put(mcauCon.PARAM_RTID, ASI_KOR_MassCreateAndUpdateController.RTDEVNAME_MASTER);
  //  pageParams.put(mcauCon.PARAM_TRID, mcauCon.theRecordTypeElementList.get(0).myRecordList.get(0).id);
  	//  mcauCon.removeNew();
  //  
    
    // Add product
    pageParams.put('PARAM_BTN_ID', 'add');
    pageParams.put('PARAM_SOBJ_ID', sobjstCon.tableEleList.get(0).sObj.Id);
    sobjstCon.triggerRowAction();
    
    // Set values
//    mcauCon.theRecordTypeElementList.get(0).myRecordList.get(0).mySObj.put('ASI_KOR_Quantity__c', 2);
    
    // Save
    mcauCon.commitAll();
    
    posmReqDetails = [
      SELECT Id FROM ASI_KOR_POSM_Order_Detail__c WHERE ASI_KOR_POSM_Order_Request__c = :posmReq.Id
    ];
    //System.assertEquals(2, posmReqDetails.size());
    
    Test.stopTest();
  }
}