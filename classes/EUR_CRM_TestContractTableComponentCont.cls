/*
  @Company:     IP-Converge Data Services, Inc.
  @Description: Test Class for EUR_CRM_ContractTableComponentController Class.
  @Author:      IPC
  @History:     JUN.03.2014 - Created
*/
@isTest
private with sharing class EUR_CRM_TestContractTableComponentCont{
    private static EUR_CRM_Account__c accountEU;    
    static testMethod void testContractTable(){
        EUR_CRM_DE_TestClassUtilityHelper.initUsersOntrade();
        test.StartTest();
        system.runAs(EUR_CRM_DE_TestClassUtilityHelper.regionalUser){
            //Create account
            EUR_CRM_DE_TestClassUtilityHelper.initData();
            accountEU = EUR_CRM_DE_TestClassUtilityHelper.euAccount;
                
            SObject sobj = (SObject) accountEU;

            EUR_CRM_GenericTable gtable = new EUR_CRM_GenericTable();
            List<EUR_CRM_GenericTable.EUR_CRM_GenericColumn> gtableList = new List<EUR_CRM_GenericTable.EUR_CRM_GenericColumn>();
            EUR_CRM_GenericTable.EUR_CRM_GenericColumn  gColumn = new EUR_CRM_GenericTable.EUR_CRM_GenericColumn();
            gColumn.columnKey = '1';
            gColumn.columnName = 'Test Col1';
            gColumn.sortingOptions = new List<String>{'asc','desc'};
            gColumn.classNames = new List<String>{'C1','C2'};
            gColumn.isEditable = true;
            gtableList.add(gColumn);
            

            gColumn.columnKey = '2';
            gColumn.columnName = 'Test Col2';
            gColumn.sortingOptions = new List<String>{'asc','desc'};
            gColumn.classNames = new List<String>{'C3','C4'};
            gColumn.isEditable = false;
            gtableList.add(gColumn);
            gtable.tableData= new List<SObject>();
            gtable.tableData.add(sobj);
            gtable.columnDetails.add(gColumn);
            List<String> names = gtable.columnNames;
            ApexPages.currentPage().getParameters().put('PARAM_ROWID','0');

            EUR_CRM_ContractTableComponentController ctrl = new EUR_CRM_ContractTableComponentController();
            ctrl.setDataTableProperties(gtable);
            String columns = ctrl.columns;
            List<EUR_CRM_ContractTableComponentController.rowWrapper> r = ctrl.dataContent;
            ctrl.setKey('key');
            ctrl.getKey();
            ctrl.getDataTableProperties();
            ctrl.initContent();
            ctrl.addToTableContent(gtable.tableData);
            ctrl.retrieveTableContent();
            ctrl.findsObjectOnOriginalList(null);
            ctrl.addContent();
            ctrl.removeContent();
            try{
                ctrl.removeContent();
            }
            catch(Exception e){

            }
            String var = EUR_CRM_ContractTableComponentController.CONTRACT_MECHANIC_TABLE_PREFIX;
            var = EUR_CRM_ContractTableComponentController.CONTRACT_LINE_ITEM_TABLE_PREFIX;
            var = ctrl.rerenderComponentList;
            EUR_CRM_ContractBuilderCntAbstract pageController =  ctrl.pageController;
            var = ctrl.mechanicName;
            var = ctrl.rerenderComponent;
           
        }
        test.stopTest();
    }
}