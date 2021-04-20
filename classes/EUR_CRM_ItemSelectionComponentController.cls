public class EUR_CRM_ItemSelectionComponentController {
    //Component Attributes
    public String sObjectTypeStr {get;set;}
    public String soqlfilterStr {get;set;}
    public String fieldsStr {get;set;}
    public String searchFieldsStr {get;set;}
    public String recordTypesStr {get;set;}
    public String pageSizeStr{get;set;} 
    public Boolean bHide{get;set;}{bHide = false;}
    public Boolean initDummyVar { get { if (initDummyVar != true) initDummyVar = init(); return initDummyVar; } set; }
    //Sobject
    private Schema.SObjectType sObjType;
    public List<SFObjSelectTableDisplayField> displayFieldList { get; private set; }
    //
    public String searchString {get;set;} 
    public EUR_CRM_AbstractSelectionItem con {get;set;}
    
    public void addItem(){
        con.add();
    }
    public Boolean init(){ 
        this.sObjType = Schema.getGlobalDescribe().get(sObjectTypeStr);
        setFields(fieldsStr);
        
        if(!String.isEmpty(pageSizeStr))
            list_size = Integer.valueOf(pageSizeStr);
        system.debug('!! done initializing');
        return true;
    }
    public void search(){
        System.debug(searchString);
        if(!String.isEmpty(searchString)){
            String query = 'select id ' + (sObjectTypeStr.equalsIgnoreCase('EUR_CRM_SKU__c') ? ', EUR_CRM_Bottles_per_Case__c ' : '')
            +' from '+sObjectTypeStr
            +' where '
            +' recordType.developername =\'' +recordTypesStr+'\''
            +' AND EUR_CRM_Active__c = true ';
            if(!String.isEmpty(searchString))
                query  += ' AND ' + searchFieldsStr + ' like \'%' + searchString + '%\'';
            if(!String.isEmpty(soqlfilterStr))
                 query +=soqlfilterStr;
            
            System.debug(query);
            List<SObject> objectList = (List<SObject>) Database.query(query); 
            System.debug(objectList);
            total_size = objectList.size();
            counter = 0;
            for(SObject so: objectList){
                con.itemMap.put(so.id,so);
            }
        }
    }
    
    private void setFields(String fieldsStr) {
        List<String> displayFieldNameList = strToStrList(fieldsStr);
        this.displayFieldList = new List<SFObjSelectTableDisplayField>();
        Map<String, Schema.SObjectField> fieldMap = this.sObjType.getDescribe().fields.getMap();
        for (String fieldName : displayFieldNameList) {
            SFObjSelectTableDisplayField df = new SFObjSelectTableDisplayField();
            Schema.SObjectField sObjField = fieldMap.get(fieldName);
            if (sObjField == null) {
                System.debug('Unknown field: ' + fieldName);
                continue;
            }
            Schema.DescribeFieldResult sObjFieldDescribe = sObjField.getDescribe();
            df.label = sObjFieldDescribe.getLabel();
            df.name = sObjFieldDescribe.getName();
            displayFieldList.add(df);
        }
        //this.queryFieldList = displayFieldNameList;
    }
    
    private List<String> strToStrList(String inputStr) { 
        return inputStr.split('\\,');
    } 
    public with sharing class SFObjSelectTableDisplayField {
        public String label { get; set; }
        public String name { get; set; }
    }
    public List<SObjectTableElement> getTableElements(){ 
        List<SObjectTableElement> eles = new List<SObjectTableElement>();
        if(!String.isEmpty(searchString)){             
            String query = 'select id, ' + fieldsStr + (sObjectTypeStr.equalsIgnoreCase('EUR_CRM_SKU__c') ? ', EUR_CRM_Bottles_per_Case__c ' : '')
            +' from '+sObjectTypeStr
            +' where '
            +' recordType.developername =\'' +recordTypesStr+'\''            
            +' AND EUR_CRM_Active__c = true '
            +' AND '+searchFieldsStr+' like \'%' + searchString + '%\'';            
           
            if(!String.isEmpty(soqlfilterStr))
                 query +=soqlfilterStr;
            
            query +=' limit:list_size offset :counter';
            system.debug('!! query: ' +query); 
            for(sObject so: Database.query(query)){ 
                SObjectTableElement s = new SObjectTableElement();
                s.sobj = so;
                s.iCon = con;
                eles.add(s); 
                con.itemMap.put(so.id,so); 
            }
        } 
        return eles;
    }
    public class SObjectTableElement{
        public sObject sObj { get; set; }
        public EUR_CRM_AbstractSelectionItem iCon {get;set;}
        public Boolean getIsAdded(){
            return iCon.existingIds.contains(sObj.id);
        }
    }
    
    private integer counter=0;  //keeps track of the offset
    private integer list_size=5; //sets the page size or number of rows
    public integer total_size = 0; //used to show user the total size of the list
 
  
   public PageReference Beginning() { //user clicked beginning
      counter = 0;
      return null;
   }
 
   public PageReference Previous() { //user clicked previous button
      counter -= list_size;
      return null;
   }
 
   public PageReference Next() { //user clicked next button
      counter += list_size;
      return null;
   }
 
   public PageReference End() { //user clicked end
      counter = total_size - math.mod(total_size, list_size);
      return null;
   }
 
   public Boolean getDisablePrevious() { 
      //this will disable the previous and beginning buttons
      if (counter>0) return false; else return true;
   }
 
   public Boolean getDisableNext() { //this will disable the next and end buttons
      if (counter + list_size < total_size) return false; else return true;
   }
 
   public Integer getTotal_size() {
      return total_size;
   }
 
   public Integer getPageNumber() { 
       if(getTotalPages() == 0)
       return 0;
       else
      return counter/list_size + 1; 
   }
 
   public Integer getTotalPages() {
      if (math.mod(total_size, list_size) > 0) {
         return total_size/list_size + 1;
      } else {
         return (total_size/list_size);
      }
   }
   public String getRange() {
      String x = ''+(counter+1);
      if(total_size < list_size || (list_size + counter) > total_size)
          x += '-' +total_size;
      else
          x += '-' +(list_size + counter);
      x += ' of ' + total_size;
      return x;
   } 
}