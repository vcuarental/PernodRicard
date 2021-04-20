public with sharing class Milestone2_Charts_GanttController {

    public String myTarget {get; 
        set{
            this.mytarget = value;
            init();
        }
    }
    public String mySize {get;
        set{
            this.mySize = value;
        }
    }
    public String myOptions {get;
        set{
            this.myOptions = value;
        }
    }
    public String drawDepend {get;
        set{
            this.drawDepend = value;
        }
    }
    
    public List<List<String>> taskItems {get;set;}
    public List<List<String>> childTaskItems {get;set;}
    
    public Map<String, String> localeMap = new Map<String, String>();
    public String userDateFormat {get; set;}
    
  
    public String objectType {get;set;}
    public String startDateFieldName {get;set;}
    public String endDateFieldName {get;set;}
    public String idFieldName {get;set;}
    public String fullViewURL {get;set;}
 
    private String nameFieldName;
    private String completedFieldName;
    private String filterFieldName;
    private String predecessor;

    public String childObjectType {get;set;}
    public String childStartDateFieldName {get;set;}
    public String childEndDateFieldName {get;set;}
    public String childIdFieldName {get;set;}
    public String childFullViewURL {get;set;}
 
    private String childNameFieldName;
    private String childCompletedFieldName;
    private String childFilterFieldName;
    private String childPredecessor;
  
    public List<Sobject> sObjectList {get; set;}
    public List<Sobject> childsObjectList {get; set;}
    
    public static final String COLOR_COMPLETE = '009933'; //Dark Grey
    public static final String COLOR_LATE = 'ee3322'; //Red
    public static final String COLOR_FUTURE = '666666'; //Light Grey
    public static final String COLOR_CURRENT = '2299bb'; //Blue
    
    private static Milestone1_Settings__c setting = Milestone1_Settings__c.getOrgDefaults();
    
    public void init()
    {
        
        localeMap = createLocaleMap();
        
        if(localeMap.get(UserInfo.getLocale()) != null){
            userDateFormat = localeMap.get(UserInfo.getLocale()).toLowerCase();
        }
        else{
            userDateFormat = 'yyyy-mm-dd';
        }
        
        childTaskItems = new List<List<String>>();
        if (myTarget != null)
        {
            initFieldNames();
            retrieveData();
            toJSon();
        }
    }
    
    /*
    *   Initialize the variables depending on the object type possible values: 
    *   Milestone1_Milestone__c and Milestone1_Task__c
    */
    private void initFieldNames(){
        if(mytarget != null){
            if(mytarget.startsWith(Schema.SObjectType.Milestone1_Project__c.getKeyPrefix())){

                startDateFieldName = Milestone1_Milestone__c.Kickoff__c.getDescribe().getName();
                endDateFieldName = Milestone1_Milestone__c.Deadline__c.getDescribe().getName();
                nameFieldName = Milestone1_Milestone__c.NameClean__c.getDescribe().getName();
                filterFieldName = Milestone1_Milestone__c.Project__c.getDescribe().getName();
                predecessor = Milestone1_Milestone__c.Predecessor_Milestone__c.getDescribe().getName();
                
                objectType = Schema.SObjectType.Milestone1_Milestone__c.getName();
                completedFieldName = 'Complete__c';

                childstartDateFieldName = Milestone1_Task__c.Start_Date__c.getDescribe().getName();
                childendDateFieldName = Milestone1_Task__c.Due_Date__c.getDescribe().getName();
                childnameFieldName = Milestone1_Task__c.Name.getDescribe().getName();
                childfilterFieldName = Milestone1_Task__c.Project_Milestone__c.getDescribe().getName();
                childpredecessor = Milestone1_Task__c.Predecessor_Task__c.getDescribe().getName();             
                
                childobjectType = Schema.SObjectType.Milestone1_Task__c.getName();
                childcompletedFieldName = 'Complete__c';

            }else if(mytarget.startsWith(Schema.SObjectType.Milestone1_Milestone__c.getKeyPrefix())){

                startDateFieldName = Milestone1_Task__c.Start_Date__c.getDescribe().getName();
                endDateFieldName = Milestone1_Task__c.Due_Date__c.getDescribe().getName();
                nameFieldName = Milestone1_Task__c.Name.getDescribe().getName();
                filterFieldName = Milestone1_Task__c.Project_Milestone__c.getDescribe().getName();
                predecessor = Milestone1_Task__c.Predecessor_Task__c.getDescribe().getName();              
                
                objectType = Schema.SObjectType.Milestone1_Task__c.getName();
                completedFieldName = 'Complete__c';
                
            }
             else {
                throw new Milestone1_Exception('[initFieldNames] Unable to generate JSON for ' + mytarget);
            }
            idFieldName = 'Id';
            childIdFieldName = 'Id';

             
        }
    }
    
    /*
    *   Retrieve the data doing a dynamic query by object type.
    */
    private void retrieveData(){
        string predecessorEnd;
        string definedSortOrder;
        List<Id> parentRecords = new List<Id>();
        String query;
        String childQuery;
        //get namespace prefix for one of our packaged objects to prefix to hardcoded api names without namespace prefix (required for runtime execution in packaging or production orgs)
        String sfdcPrefix = SObjectType.Milestone1_Milestone__c.Name.substringBefore('Milestone1_Milestone__c');
        
        //build sort order for parent items.
        if(predecessor.contains('Predecessor_Task__c')){ // if parent item is a task
        
            predecessorEnd = 'Predecessor_Task__r.Due_Date__c';
           
        }
        else if (predecessor.contains('Predecessor_Milestone__c')){
            predecessorEnd ='Predecessor_Milestone__r.Deadline__c';
            
        }
        else if (predecessor.contains('Predecessor_Project__c')){
            predecessorEnd = 'Predecessor_Project__r.Deadline__c';
        }
        
        if(definedSortOrder == null){
            query = 'Select ' + idFieldName + ',' + startDateFieldName + ',' + endDateFieldName + ',' + nameFieldName + ',' + completedFieldName + ',' + predecessor +
                    ' from ' + objectType + ' where ' + filterFieldName +'=\'' + mytarget + '\' order by ' + endDateFieldName + ',' + startDateFieldName  + ',' + predecessorEnd + ',' + nameFieldName;
        }
        else{
            query = 'Select ' + idFieldName + ',' + startDateFieldName + ',' + endDateFieldName + ',' + nameFieldName + ',' + completedFieldName + ',' + predecessor +
                    ' from ' + objectType + ' where ' + filterFieldName +'=\'' + mytarget + '\' order by ' + definedSortOrder;
        }
        
        try{
            sobjectList = Database.query(query);
        }catch(exception e){ 
            //if the custom sort order was not define properly use default sort order.
            sobjectList = Database.query(
            'Select ' + idFieldName + ',' + startDateFieldName + ',' + endDateFieldName + ',' + nameFieldName + ',' + completedFieldName + ',' + predecessor +
            ' from ' + objectType + ' where ' + filterFieldName +'=\'' + mytarget + '\' order by ' + endDateFieldName + ',' + startDateFieldName  + ',' + predecessorEnd + ',' + nameFieldName
            );
        }


        for(sObject obj : sObjectList){
            parentRecords.add(obj.Id);

        }
        
        definedSortOrder = null;
        
        if(childpredecessor != null){
            //build sort order for child items.
            if(childpredecessor.contains('Predecessor_Task__c')){ //if child item is a task
                predecessorEnd = 'Predecessor_Task__r.Due_Date__c';
                
            }
            else{
                predecessorEnd = 'Predecessor_Milestone__r.Deadline__c';
                
            }
    
            if(objectType != Schema.SObjectType.Milestone1_Task__c.getName()){
            //add child records for multi level gantt
            if(definedSortOrder == null){
                childQuery = 'Select ' + childidFieldName + ',' + childstartDateFieldName + ',' + childendDateFieldName + ',' + childnameFieldName + ',' + childcompletedFieldName + ',' + childpredecessor + ',' + childfilterFieldName + 
                         ' from ' + childobjectType + ' where ' + childfilterFieldName +' IN :parentRecords '+  'order by ' + childendDateFieldName  + ',' + childstartDateFieldName + ',' + predecessorEnd + ',' + childnameFieldName;
            }
            else{
                childQuery = 'Select ' + childidFieldName + ',' + childstartDateFieldName + ',' + childendDateFieldName + ',' + childnameFieldName + ',' + childcompletedFieldName + ',' + childpredecessor + ',' + childfilterFieldName + 
                         ' from ' + childobjectType + ' where ' + childfilterFieldName +' IN :parentRecords '+  'order by ' + definedSortOrder;
            }
                
                
                try{
                    childsObjectList = Database.query(childQuery);
                }
                catch(exception ex){ 
                    //if the custom sort order was not define properly use default sort order.
                    childsObjectList = Database.query(
                        'Select ' + childidFieldName + ',' + childstartDateFieldName + ',' + childendDateFieldName + ',' + childnameFieldName + ',' + childcompletedFieldName + ',' + childpredecessor + ',' + childfilterFieldName + 
                        ' from ' + childobjectType + ' where ' + childfilterFieldName +' IN :parentRecords '+  'order by ' + childendDateFieldName  + ',' + childstartDateFieldName + ',' + predecessorEnd + ',' + childnameFieldName
                    );
                }
            }
        

            if(childsObjectList.size() > 0){
                buildChildTaskObjects();
            }
            
        }

    }
    
    /**
    *   Generate the output in json format to be rendered in the jquery gantt.
    */
    private void toJSon(){

        Date startDate,endDate;
        String name, id, color, sDateString, eDateString, urlString, hasChildren, dependencies = '';
        Integer i, completed;
        
        taskItems = new List<List<String>>();
        
        i = 0;
        for (Sobject current : sobjectList){ 
            if(current.get(startDateFieldName) == null){
                startDate = Date.today();
            }else{
                startDate = Date.valueOf(current.get(startDateFieldName));
            }

            sDateString = startDate.month() + '/' + startDate.day() + '/' + startDate.year();
            
            if(current.get(endDateFieldName) == null){
                endDate = startDate;
            }else{
                endDate = Date.valueOf(current.get(endDateFieldName));
            }

            eDateString = endDate.month() + '/' + endDate.day() + '/' + endDate.year();
            
            if(current.get(completedFieldName) == true)
                completed = 1;
            else{
                completed = 0;
                if(current.get(completedFieldName) == 'Completed'){
                completed = 1;
                }
                
            }

            hasChildren = checkIfParent((Id)current.get(idFieldName));
            
            name = String.valueOf(current.get(nameFieldName));
            id = String.valueOf(current.get(idFieldName));
            urlString = URL.getSalesforceBaseUrl().toExternalForm() + '/' + id;
            dependencies = String.valueOf(current.get(predecessor));

            color=COLOR_CURRENT;
            if (completed == 1) {
                color=COLOR_COMPLETE;
            } else if (endDate < Date.today()) {
                color=COLOR_LATE;
            } else if (startDate > Date.today()) {
                color=COLOR_FUTURE;
            }
            
/***************************************************************
pID: (required) is a unique ID used to identify each row for parent functions and for setting dom id for hiding/showing
pName: (required) is the task Label
pStart: (required) the task start date, can enter empty date ('') for groups. You can also enter specific time (2/10/2008 12:00) for additional percision or half days.
pEnd: (required) the task end date, can enter empty date ('') for groups
pColor: (required) the html color for this task; e.g. '00ff00'
pLink: (optional) any http link navigated to when task bar is clicked.
pMile:(optional) represent a milestone
pRes: (optional) resource name
pComp: (required) completion percent
pGroup: (optional) indicates whether this is a group(parent) - 0=NOT Parent; 1=IS Parent
pParent: (required) identifies a parent pID, this causes this task to be a child of identified task
pOpen: can be initially set to close folder when chart is first drawn
pDepend: optional list of id's this task is dependent on ... line drawn from dependent to this item
pCaption: optional caption that will be added after task bar if CaptionType set to "Caption"
*/

            //last argument isn't used but should be kept to avoid page error   
            taskItems.add(new String[]{id, name, sDateString, 
                                       eDateString, color, urlString, '0','Brent',
                                       String.valueOf(completed), hasChildren,'0','1', dependencies, '', objectType});

        }
    }

    private string checkIfParent(Id parentId){
    
        if(childsObjectList != null){
            for(sObject child : childsObjectList){
                if(child.get(childfilterFieldName) == parentId){
                    return '1';
                }
            }
        }
        return '0';
    }

    private void buildChildTaskObjects(){

                Date startDate,endDate;
        String name, id, color, sDateString, eDateString, urlString, hasChildren, parentRec, dependencies = '';
        Integer i, completed;
        
        taskItems = new List<List<String>>();
        
        i = 0;
        for (Sobject current : childsObjectList){ 
            if(current.get(childstartDateFieldName) == null){
                startDate = Date.today();
            }else{
                startDate = Date.valueOf(current.get(childstartDateFieldName));
            }

            sDateString = startDate.month() + '/' + startDate.day() + '/' + startDate.year();
            
            if(current.get(childendDateFieldName) == null){
                endDate = startDate;
            }else{
                endDate = Date.valueOf(current.get(childendDateFieldName));
            }

            eDateString = endDate.month() + '/' + endDate.day() + '/' + endDate.year();
            
            if(current.get(childcompletedFieldName) == true)
                completed = 1;
            else{
                completed = 0;
                if(current.get(childcompletedFieldName) == 'Completed'){
                completed = 1;
                }
                
            }
            
            name = String.valueOf(current.get(childnameFieldName));
            id = String.valueOf(current.get(childidFieldName));
            urlString = URL.getSalesforceBaseUrl().toExternalForm() + '/' + id;
            parentRec = String.ValueOf(current.get(childFilterFieldName));
            
            if(String.valueOf(current.get(childpredecessor)) != null){
                dependencies = String.valueOf(current.get(childpredecessor));
            }
            else{
                dependencies = '';
            }
            

            color=COLOR_CURRENT;
            if (completed == 1) {
                color=COLOR_COMPLETE;
            } else if (endDate < Date.today()) {
                color=COLOR_LATE;
            } else if (startDate > Date.today()) {
                color=COLOR_FUTURE;
            }
                                    
            childTaskItems.add(new String[]{id, name, sDateString, 
                                       eDateString, color, urlString, '0','Brent',
                                       String.valueOf(completed), '0','0','1', dependencies, '', parentRec});

        }

    }
    
    private Map<String, String> createLocaleMap() 
    {
        Map<String, String> locale_map = new Map<String, String>(); //holds the locale to timedate formats
        locale_map.put('ar', 'dd/mm/yyyy');
        locale_map.put('ar_AE', 'dd/mm/yyyy');
        locale_map.put('ar_BH', 'dd/mm/yyyy');
        locale_map.put('ar_JO', 'dd/mm/yyyy');
        locale_map.put('ar_KW', 'dd/mm/yyyy');
        locale_map.put('ar_LB', 'dd/mm/yyyy');
        locale_map.put('ar_SA', 'dd/mm/yyyy');
        locale_map.put('bg_BG', 'yyyy-mm-dd');
        locale_map.put('ca', 'dd/mm/yyyy');
        locale_map.put('ca_ES', 'dd/mm/yyyy');
        locale_map.put('ca_ES_EURO', 'dd/mm/yyyy');
        locale_map.put('cs', 'dd/mm/yyyy');
        locale_map.put('cs_CZ', 'dd/mm/yyyy');
        locale_map.put('da', 'dd/mm/yyyy');
        locale_map.put('da_DK', 'dd/mm/yyyy');
        locale_map.put('de', 'dd/mm/yyyy');
        locale_map.put('de_AT', 'dd/mm/yyyy');
        locale_map.put('de_AT_EURO', 'dd/mm/yyyy');
        locale_map.put('de_CH', 'dd/mm/yyyy');
        locale_map.put('de_DE', 'dd/mm/yyyy');
        locale_map.put('de_DE_EURO', 'dd/mm/yyyy');
        locale_map.put('de_LU', 'dd/mm/yyyy');
        locale_map.put('de_LU_EURO', 'dd/mm/yyyy');
        locale_map.put('el_GR', 'dd/mm/yyyy');
        locale_map.put('en_AU', 'dd/mm/yyyy');
        locale_map.put('en_B', 'mm/dd/yyyy');
        locale_map.put('en_BM', 'mm/dd/yyyy');
        locale_map.put('en_CA', 'dd/mm/yyyy');
        locale_map.put('en_GB', 'dd/mm/yyyy');
        locale_map.put('en_GH', 'mm/dd/yyyy');
        locale_map.put('en_ID', 'mm/dd/yyyy');
        locale_map.put('en_IE', 'dd/mm/yyyy');
        locale_map.put('en_IE_EURO', 'dd/mm/yyyy');
        locale_map.put('en_NZ', 'dd/mm/yyyy');
        locale_map.put('en_SG', 'mm/dd/yyyy');
        locale_map.put('en_US', 'mm/dd/yyyy');
        locale_map.put('en_ZA', 'yyyy-mm-dd');
        locale_map.put('es', 'dd/mm/yyyy');
        locale_map.put('es_AR', 'dd/mm/yyyy');
        locale_map.put('es_BO', 'dd/mm/yyyy');
        locale_map.put('es_CL', 'dd/mm/yyyy');
        locale_map.put('es_CO', 'dd/mm/yyyy');
        locale_map.put('es_CR', 'dd/mm/yyyy');
        locale_map.put('es_EC', 'dd/mm/yyyy');
        locale_map.put('es_ES', 'dd/mm/yyyy');
        locale_map.put('es_ES_EURO', 'dd/mm/yyyy');
        locale_map.put('es_GT', 'dd/mm/yyyy');
        locale_map.put('es_HN', 'mm/dd/yyyy');
        locale_map.put('es_MX', 'dd/mm/yyyy');
        locale_map.put('es_PE', 'dd/mm/yyyy');
        locale_map.put('es_PR', 'mm/dd/yyyy');
        locale_map.put('es_PY', 'dd/mm/yyyy');
        locale_map.put('es_SV', 'mm/dd/yyyy');
        locale_map.put('es_UY', 'dd/mm/yyyy');
        locale_map.put('es_VE', 'dd/mm/yyyy');
        locale_map.put('et_EE', 'dd/mm/yyyy');
        locale_map.put('fi', 'dd/mm/yyyy');
        locale_map.put('fi_FI', 'dd/mm/yyyy');
        locale_map.put('fi_FI_EURO', 'dd/mm/yyyy');
        locale_map.put('fr', 'dd/mm/yyyy');
        locale_map.put('fr_BE', 'dd/mm/yyyy');
        locale_map.put('fr_CA', 'yyyy-mm-dd');
        locale_map.put('fr_CH', 'dd/mm/yyyy');
        locale_map.put('fr_FR', 'dd/mm/yyyy');
        locale_map.put('fr_FR_EURO', 'dd/mm/yyyy');
        locale_map.put('fr_LU', 'dd/mm/yyyy');
        locale_map.put('fr_MC', 'dd/mm/yyyy');
        locale_map.put('hr_HR', 'yyyy-mm-dd');
        locale_map.put('hu', 'yyyy-mm-dd');
        locale_map.put('hy_AM', 'mm/dd/yyyy');
        locale_map.put('is_IS', 'dd/mm/yyyy');
        locale_map.put('it', 'dd/mm/yyyy');
        locale_map.put('it_CH', 'dd/mm/yyyy');
        locale_map.put('it_IT', 'dd/mm/yyyy');
        locale_map.put('iw', 'dd/mm/yyyy');
        locale_map.put('iw_IL', 'dd/mm/yyyy');
        locale_map.put('ja', 'yyyy-mm-dd');
        locale_map.put('ja_JP', 'yyyy-mm-dd');
        locale_map.put('kk_KZ', 'mm/dd/yyyy');
        locale_map.put('km_KH', 'mm/dd/yyyy');
        locale_map.put('ko', 'yyyy-mm-dd');
        locale_map.put('ko_KR', 'yyyy-mm-dd');
        locale_map.put('lt_LT', 'yyyy-mm-dd');
        locale_map.put('lv_LV', 'yyyy-mm-dd');
        locale_map.put('ms_MY', 'dd/mm/yyyy');
        locale_map.put('nl', 'dd/mm/yyyy');
        locale_map.put('nl_BE', 'dd/mm/yyyy');
        locale_map.put('nl_NL', 'dd/mm/yyyy');
        locale_map.put('nl_SR', 'dd/mm/yyyy');
        locale_map.put('no', 'dd/mm/yyyy');
        locale_map.put('no_NO', 'dd/mm/yyyy');
        locale_map.put('pl', 'yyyy-mm-dd');
        locale_map.put('pt', 'dd/mm/yyyy');
        locale_map.put('pt_AO', 'dd/mm/yyyy');
        locale_map.put('pt_BR', 'dd/mm/yyyy');
        locale_map.put('pt_PT', 'dd/mm/yyyy');
        locale_map.put('ro_RO', 'dd/mm/yyyy');
        locale_map.put('ru', 'dd/mm/yyyy');
        locale_map.put('sk_SK', 'dd/mm/yyyy');
        locale_map.put('sl_SI', 'dd/mm/yyyy');
        locale_map.put('sv', 'yyyy-mm-dd');
        locale_map.put('sv_SE', 'yyyy-mm-dd');
        locale_map.put('th', 'mm/dd/yyyy');
        locale_map.put('th_TH', 'dd/mm/yyyy');
        locale_map.put('tr', 'dd/mm/yyyy');
        locale_map.put('ur_PK', 'mm/dd/yyyy');
        locale_map.put('vi_VN', 'dd/mm/yyyy');
        locale_map.put('zh', 'yyyy-mm-dd');
        locale_map.put('zh_CN', 'yyyy-mm-dd');
        locale_map.put('zh_HK', 'yyyy-mm-dd');
        locale_map.put('zh_TW', 'yyyy-mm-dd');
        return locale_map; //return the map
    }

}