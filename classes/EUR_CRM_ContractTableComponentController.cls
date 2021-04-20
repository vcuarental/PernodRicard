public with sharing class EUR_CRM_ContractTableComponentController extends EUR_CRM_ContractComponentControllerBase {
    
    private static final String COLUMN_KEY = 'mData';
    private static final String COLUMN_TITLE = 'sTitle';
    private static final String COLUMN_CLASS = 'sClass';
    private static final String COLUMN_SORTING = 'asSorting';
    
    public static String CONTRACT_MECHANIC_TABLE_PREFIX {get{return 'ContractMechanicTable_';}}
    public static String CONTRACT_LINE_ITEM_TABLE_PREFIX {get{ return 'ContractLineItemTable_';}}
    
    //VF Component Variables
    public String key;//has custom setter and getter
    public String mechanicName{get;set;}
    public EUR_CRM_GenericTable dataTableProperties; //has custom setter and getter
    public String rerenderComponentList {get;set;}
    public EUR_CRM_ContractBuilderCntAbstract pageController {get;set;}
    public String rerenderComponent{get;set;}
    
    //Local Variables
    public String PARAM_ROWID {get;set;}{PARAM_ROWID = 'PARAM_ROWID';}
    public List<sObject> addedsObjectList {get;set;} {addedsObjectList=new List<sObject>();}
    public List<sObject> removedsObjectList {get;set;} {removedsObjectList=new List<sObject>();}
    public List<sObject> tableContent{get;set;}{tableContent = new List<sObject>();}
    
    private String privateKey{get;set;}
    private List<sObject> originalDataList {get;set;}{originalDataList = new List<sObject>();}
    
    private List<sObject> contentList{get{
        return dataTableProperties.tableData;
    }}
    
    public String columns{get{
        //System.debug('Flag - Test Table Properties:' + dataTableProperties);
        //JSON
        JSONGenerator g = JSON.createGenerator(true);
        g.writeStartArray();
        
        for (EUR_CRM_GenericTable.EUR_CRM_GenericColumn column: dataTableProperties.columnDetails){
             g.writeStartObject();
             g.writeStringField(COLUMN_KEY, column.columnKey);
             g.writeStringField(COLUMN_TITLE, column.columnName);
             if (column.classNames!=null && column.classNames.size()>0){
                g.writeStringField(COLUMN_CLASS, String.join(column.classNames, ' '));
             }
             //if(column.sortingOptions.size()>0){
                //g.write(COLUMN_SORTING, g.writeStartArray()+String.join(column.sortingOptions, ',')+g.writeEndArray());
             //}
             //else{
             // g.writeStringField(COLUMN_SORTING, 'null');
             //}
             g.writeEndObject();
        }
        
        g.writeEndArray();
        
        System.debug('Flag - Columns:' + g.getAsString());
        return g.getAsString();
    }}
    
    /*public List<sObject> dataList{get{
        List<sObject> contentList = new List<sObject>();
        for (String key: dataTableProperties.tableDataMap.keySet()){
            contentList.add(dataTableProperties.tableDataMap.get(key));
        }
        
        return contentList;
    }}*/
    
    
    public List<rowWrapper> dataContent{
        get{
            List<rowWrapper> rowList = new List<rowWrapper>();
            Integer rowId = 0;
            for (sObject dataObj: tableContent){
                rowList.add(new rowWrapper(rowId, dataObj));
                rowId ++;
            }
            
            return rowList;
        }
        /*get{
        //JSON
        JSONGenerator g = JSON.createGenerator(true);
        g.writeStartArray();
        for (Map<String,String> content: dataTableProperties.tableDataMap){
            g.writeStartObject();
            for (String key: content.keySet()){
                g.writeStringField(key, content.get(key));
            }
            g.writeEndObject();
        }
        g.writeEndArray();
        
        System.debug('Flag - Data Content:' + g.getAsString());
        return g.getAsString();
    }*/
    }
    
    
    public EUR_CRM_ContractTableComponentController(){
        //tableContent = new List<sObject>();
    }
    
    public void setKey(String key){
        this.key = key;
        privateKey = key;
    }
    public String getKey(){return key;}
    
    
    public void setDataTableProperties (EUR_CRM_GenericTable genericTable){
        this.dataTableProperties = genericTable;
        
        tableContent = this.dataTableProperties.tableData;
        originalDataList = this.dataTableProperties.tableData;
    }
    
    public EUR_CRM_GenericTable getDataTableProperties(){
        return this.dataTableProperties;
    }
    
    /*public void setTableContent (List<sObject> dataList){
        tableContent = dataLis
    }*/
    
    public void initContent(){
        if (tableContent == null || tableContent.size()<=0){
            tableContent = dataTableProperties.tableData;
        }
    }
    
    public List<sObject> addToTableContent(List<sObject> additionalContent){
        tableContent.addAll(additionalContent);
        
        return tableContent;
    }
    
    public List<sObject> retrieveTableContent(){
        return tableContent;
    }
    
    public sObject findsObjectOnOriginalList(Id id){
        for (sObject obj: originalDataList){
            if (obj.get('Id') == id){
                return obj;
            }
        }
        return null;
    }
    
    public PageReference addContent(){
        //Init list container
        addedsObjectList = new List<sObject>();
        
        //Get Row Id
        Map<String, String> params = ApexPages.currentPage().getParameters();   
        Integer rowId = Integer.valueOf(params.get('PARAM_ROWID'));
        
        //Get Object
        sObject obj = tableContent.get(rowId);
        
        //Update list container
        addedsObjectList.add(obj);
        //Remove row on main content container
        tableContent.remove(rowId);
        
        System.debug('Flag - Component Controller - Add Content:' + pageController + '-' + key);
        //Call main controller handler
        if (pageController!= null){
            ((EUR_CRM_ContractBuilderCntAbstract)pageController).processComponentCallbackAdd(key, mechanicName, addedsObjectList); // addedContent
        }

        return null;
    }
    
    public PageReference removeContent(){
        //Init list container
        removedsObjectList = new List<sObject>();
        
        //Get Row Id
        Map<String, String> params = ApexPages.currentPage().getParameters();   
        Integer rowId = Integer.valueOf(params.get('PARAM_ROWID'));
        
        //Get Object 
        sObject obj = tableContent.get(rowId);
        
        //Update list container
        removedsObjectList.add(obj);
        //Remove row on main content container
        tableContent.remove(rowId);
        
        System.debug('Flag - Component Controller - Remove Content:' + pageController + '-' + key);
        //Call main controller handler
        if (pageController!= null){
            ((EUR_CRM_ContractBuilderCntAbstract)pageController).processComponentCallbackRemove(key, mechanicName, removedsObjectList); // addedContent
        }

        return null;
    }

    public class rowWrapper{
        public Integer rowId {get;set;}
        public sObject sObj {get;set;} // row sObject content
        
        public rowWrapper(Integer id, sObject obj){
            rowId = id;
            sObj = obj;
        }
    }
}