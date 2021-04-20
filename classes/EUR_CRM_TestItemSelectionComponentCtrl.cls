/*------------------------------------------------------------
Author/Company:   IP Converge Data Services,Inc.
Description:      test class for EUR_CRM_ItemSelectionComponentController
History 
01/08/2014        IPC     Created
------------------------------------------------------------*/
@isTest
public class EUR_CRM_TestItemSelectionComponentCtrl{

    static testmethod void test(){
    
        EUR_CRM_DE_TestClassUtilityHelper.createSIZE('Absolut', 'EUR DE Size'); 
        EUR_CRM_ItemSelectionComponentController con = new EUR_CRM_ItemSelectionComponentController();
        
        SelectionItem selectionItem = new SelectionItem();
        
        con.con = selectionItem;
        con.searchString = 'Abs';
        con.sObjectTypeStr='EUR_CRM_Size__c' ;
        con.fieldsStr='name';
        con.searchFieldsStr='name';
        con.recordTypesStr='EUR_DE_Size';
        con.init();
        con.search();
        con.addItem();
        con.search();
        con.getTableElements();         
        con.Beginning();         
        con.Previous();         
        con.Next();         
        con.End(); 
        con.getDisablePrevious(); 
        con.getDisableNext();  
        con.getTotal_size();  
        con.getPageNumber();  
        con.getTotalPages();  
        con.getRange();
    }

    class SelectionItem extends EUR_CRM_AbstractSelectionItem{
        public SelectionItem(){
            this.sCon = this;
            itemMap = new  Map<Id,SObject>();
        }
        public override  void add(){
        
        }
    }
}