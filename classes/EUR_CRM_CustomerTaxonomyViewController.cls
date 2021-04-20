public class EUR_CRM_CustomerTaxonomyViewController{
    public String chainValue {get;set;}
    public String level1Value {get;set;}
    public String level2Value {get;set;}
    public String level3Value {get;set;}
    public String level4Value {get;set;}
    public String level5Value {get;set;}
    public String level6Value {get;set;}
    public String level7Value {get;set;}
    public String level8Value {get;set;}     
    public List<EUR_CRM_Customer_Taxonomy__c> customerTaxonomyList {get; set;}  
    public List<EUR_CRM_Account__c> euAccountList {get; set;}
    private final String ALL = 'All *';  
    public EUR_CRM_CustomerTaxonomyViewController(){ 
    }
    public List<SelectOption> retrieveListValues(String controllingField, String field, String controllingFieldValue ){ 
    
        String query = 'select ' + field +' from EUR_CRM_Customer_Taxonomy__c where recordtype.developername = \'EUR_DE_Customer_Taxonomy\'';
        if(controllingField != null)
            query += ' AND ' + controllingField + ' =: controllingFieldValue';
        query += ' group by ' + field;
         system.debug('@@ ' + query);
        AggregateResult[] groupedResults = Database.query(query);
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption(ALL, ALL));
        for (AggregateResult ar : groupedResults)  {
        String x = (String) ar.get(field);
        if(x==null)
            x = '';
        system.debug('@@' + x);
             options.add(new SelectOption(x, x)); 
        }       
        return options;    
    }
    public void filter(){
        String query1 = 'select id,name from EUR_CRM_Customer_Taxonomy__c  where recordtype.name = \'DE Customer Taxonomy\'';
        if(chainValue !=null && chainValue != ALL)
            query1 += ' AND EUR_CRM_Chain__c = \''+ chainValue +'\'';
            
        if(level1Value !=null && level1Value != ALL)
            query1 += ' AND EUR_CRM_Level_1__c = \''+ level1Value  +'\'';
        
        if(level2value !=null && level2Value != ALL)
            query1 += ' AND EUR_CRM_Level_2__c = \''+ level2Value +'\'';
        
        if(level3value !=null && level3Value != ALL)
            query1 += ' AND EUR_CRM_Level_3__c = \''+ level3Value +'\'';
        
        if(level4value !=null && level4Value != ALL)
            query1 += ' AND EUR_CRM_Level_4__c = \''+ level4Value +'\'';
        
        if(level5value !=null && level5Value != ALL)
            query1 += ' AND EUR_CRM_Level_5__c = \''+ level5Value +'\'';
        
        if(level6value !=null && level6Value != ALL)
            query1 += ' AND EUR_CRM_Level_6__c = \''+ level6Value +'\''; 
        
        if(level7value !=null && level7Value != ALL)
            query1 += ' AND EUR_CRM_Level_7__c = \''+ level7Value +'\'';  
        
        if(level8value !=null && level8Value != ALL)
            query1 += ' AND EUR_CRM_Level_8__c = \''+ level8Value +'\'';        
        
        system.debug('$$$ ' +  query1);
        
        customerTaxonomyList = (List<EUR_CRM_Customer_Taxonomy__c>)Database.query(query1);
        
        Set<Id> custIdSet = new Set<Id>();
        
        for(EUR_CRM_Customer_Taxonomy__c cust: customerTaxonomyList ){
            custIdSet.add(cust.id);
        }
        euAccountList = [select id,name,EUR_JB_Customer_Taxonomy__c,EUR_JB_Customer_Taxonomy__r.name from eur_crm_account__c where EUR_JB_Customer_Taxonomy__c in: custIdSet];
    
       // con = new ApexPages.StandardSetController(euAccountList);
 
            // sets the number of records in each page set
       //     con.setPageSize(5);
    }
    
    public List<SelectOption> getChainOptions(){
       return retrieveListValues(null, 'EUR_CRM_Chain__c', '');
    } 
    public List<SelectOption> getLevel1Options (){
        level1Value = null;
        if(chainValue == null || chainValue  == ALL)
        return null;
       return retrieveListValues('EUR_CRM_Chain__c', 'EUR_CRM_Level_1__c', chainValue);
    }
    public List<SelectOption> getLevel2Options (){
        level2Value = null;
        if(level1Value== null || level1Value == ALL)
        return null;
       return retrieveListValues('EUR_CRM_Level_1__c', 'EUR_CRM_Level_2__c', level1Value);
    } 
    
    public List<SelectOption> getLevel3Options (){
        level3Value = null;
        if(level2Value== null || level2Value == ALL)
        return null;
       return retrieveListValues('EUR_CRM_Level_2__c', 'EUR_CRM_Level_3__c', level2Value);
    } 
    public List<SelectOption> getLevel4Options (){
        level4Value = null;
        if(level3Value== null || level3Value == ALL)
        return null;
       return retrieveListValues('EUR_CRM_Level_3__c', 'EUR_CRM_Level_4__c', level3Value);
    } 
    public List<SelectOption> getLevel5Options (){
        level5Value = null;
        if(level4Value== null || level4Value == ALL)
        return null;
       return retrieveListValues('EUR_CRM_Level_4__c', 'EUR_CRM_Level_5__c', level4Value);
    } 
    public List<SelectOption> getLevel6Options (){
        level6Value = null;
        if(level5Value== null || level5Value == ALL)
        return null;
       return retrieveListValues('EUR_CRM_Level_5__c', 'EUR_CRM_Level_6__c', level5Value);
    } 
    public List<SelectOption> getLevel7Options (){
        level7Value = null;
        if(level6Value== null || level6Value == ALL)
        return null;
       return retrieveListValues('EUR_CRM_Level_6__c', 'EUR_CRM_Level_7__c', level6Value);
    } 
    public List<SelectOption> getLevel8Options (){
        level8Value = null;
        if(level7Value== null || level7Value == ALL)
        return null;
       return retrieveListValues('EUR_CRM_Level_7__c', 'EUR_CRM_Level_8__c', level7Value);
    } 
    public class Node{
        private String value{get;set;}
        public List<Node> children {get;set;}
        
        public Node(String value, List<Node> children){
            this.value = value;
            this.children= children;
        }
         public List<Node> getChildren(){
             return children;
         }
    }
    
    public Node returnNode(String value, List<Node> nodes){
        for(Node node: nodes){
            if(node.value == value){
                return node;
                break;
            }
        }
        
        return null;
    }
    
     //Instantiate the StandardSetController
    public ApexPages.StandardSetController con{get; set;}
    
    //Boolean to check if there are more records after the present displaying records
    public Boolean hasNext
    {
        get
        {
            return con.getHasNext();
        }
        set;
    }
 
    //Boolean to check if there are more records before the present displaying records
    public Boolean hasPrevious
    {
        get
        {
            return con.getHasPrevious();
        }
        set;
    }
 
    //Page number of the current displaying records
    public Integer pageNumber
    {
        get
        {
            return con.getPageNumber();
        }
        set;
    }

    //Returns the previous page of records
    public void previous()
    {
        con.previous();
    }
 
    //Returns the next page of records
    public void next()
    {
        con.next();
    }
}