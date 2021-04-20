@isTest
public class EUR_CRM_Test_GenericTable{
    
    static testMethod void test1(){
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
        
        gtable.columnDetails.add(gColumn);
        List<String> names = gtable.columnNames;

    }

}