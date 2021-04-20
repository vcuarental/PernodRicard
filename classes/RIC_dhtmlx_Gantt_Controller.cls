public class RIC_dhtmlx_Gantt_Controller {
    
    public static String mytarget {get; set{ mytarget = value; init(); } }
    public static String objectType {get;set;}
    public static String startDateFieldName {get;set;}
    public static String endDateFieldName {get;set;}
    public static String idFieldName {get;set;}
    public static String projectGanttJson{get;set;}
    private static String nameFieldName;
    private static String completedFieldName;
    private static String filterFieldName;
    private static String assignedToFieldName;
    
    private static List<Sobject> sobjectList;
    private static final String REGEXP_QUOTES    = '(?<!\\\\)"';
    public static final String COLOR_COMPLETE = '#009933';
    public static final String COLOR_LATE = '#ee3322';
    public static final String COLOR_FUTURE = '#666666';
    public static final String COLOR_CURRENT = '#2299bb';
    
    public static Date latestEndDate {get; set;}
    public static Date earliestStartDate {get; set;}
    public static Date projectEndDate {get; set;}
    public static Map<String, String> mapUserIdName = new Map<String, String>();
    public static Map<String, String> mapUserNameAndId = new Map<String, String>();
    public static String ricActionKeyPrefix {get; set;}
    public static Date phaseStartDate, phaseEndDate;
    
    public static Map<String, Integer> months = new Map <String, Integer> {'Jan'=>1, 'Feb'=>2
        , 'Mar'=>3, 'Apr'=>4, 'May'=>5, 'Jun'=>6, 'Jul'=>7, 'Aug'=>8, 'Sep'=>9
        , 'Oct'=>10, 'Nov'=>11, 'Dec'=>12};
            
    public RIC_dhtmlx_Gantt_Controller() {
        init();
    }
    
    private static void init() {
        if (myTarget != null) {
            initFieldNames();
            retrieveData();
            getLatestAndFirstEndDates();
            projectGanttJson = toJSon();
        }
    }
    
    public static String projectGanttJson() {
        init();
        return projectGanttJson;
    }
    
    /*
    *   Initialize the variables depending on the object type possible values: 
    *   Milestone1_Milestone__c and Milestone1_Task__c
    */
    private static void initFieldNames(){
        if(mytarget != null){
            ricActionKeyPrefix = Schema.SObjectType.Milestone1_Task__c.getKeyPrefix();
            if(mytarget.startsWith(Schema.SObjectType.Milestone1_Project__c.getKeyPrefix())){
                
                startDateFieldName = Milestone1_Milestone__c.Kickoff__c.getDescribe().getName();
                endDateFieldName = Milestone1_Milestone__c.Deadline__c.getDescribe().getName();
                nameFieldName = Milestone1_Milestone__c.NameClean__c.getDescribe().getName();
                filterFieldName = Milestone1_Milestone__c.Project__c.getDescribe().getName();
                assignedToFieldName = Milestone1_Milestone__c.Predecessor_Milestone_Import_Id__c.getDescribe().getName();
                
                objectType = Schema.SObjectType.Milestone1_Milestone__c.getName();
            }
            else if(mytarget.startsWith(Schema.SObjectType.Milestone1_Milestone__c.getKeyPrefix())){
                startDateFieldName = Milestone1_Task__c.Start_Date__c.getDescribe().getName();
                endDateFieldName = Milestone1_Task__c.Due_Date__c.getDescribe().getName();
                nameFieldName = Milestone1_Task__c.Name.getDescribe().getName();
                filterFieldName = Milestone1_Task__c.Project_Milestone__c.getDescribe().getName();
                assignedToFieldName = Milestone1_Task__c.Assigned_To__c.getDEscribe().getName();
                
                Milestone1_Milestone__c ricPhase = [SELECT Id, Kickoff__c, Deadline__c 
                                                    FROM Milestone1_Milestone__c 
                                                    WHERE Id = :mytarget];
                phaseStartDate = ricPhase.Kickoff__c;
                phaseEndDate = ricPhase.Deadline__c;
                
                objectType = Schema.SObjectType.Milestone1_Task__c.getName();
            } 
            else {
                throw new Milestone1_Exception('[initFieldNames] Unable to generate JSON for ' + mytarget);
            }
            idFieldName = 'Id';
            completedFieldName = 'Complete__c'; 
        }
    }
    
    /*
    *   Retrieve the data doing a dynamic query by object type.
    */
    private static void retrieveData(){
        
        String query = 'Select '+idFieldName+','+startDateFieldName+','+endDateFieldName+','+nameFieldName+','+completedFieldName+','+assignedToFieldName+
            ' from '+objectType+ ' where '+filterFieldName+'=\''+mytarget+'\' order by Name';
        System.debug('### Query: ' + query);
        sobjectList = Database.query(query);
    }
    
    public static void getUsersByName(Map<String, List<Milestone1_Task__c>> mapParentAndChilds) {
        
        List<String> usersIds = new List<String>();
        for (integer i = 0; i < sobjectList.size(); i++){
            Sobject current = sobjectList.get(i);
            String currentId = current.Id;
            if(currentId.startsWith(Schema.SObjectType.Milestone1_Task__c.getKeyPrefix())) {
                if(current.get(assignedToFieldName) != null){
                    usersIds.add((String) current.get(assignedToFieldName));
                }
            }
            else if(currentId.startsWith(Schema.SObjectType.Milestone1_Milestone__c.getKeyPrefix())){
                if(mapParentAndChilds.containsKey(currentId)) {
                    for(Milestone1_Task__c childTask : mapParentAndChilds.get(currentId)){
                        usersIds.add(childTask.Assigned_To__c);
                    }
                }
            }
        }
        
        List<User> users = [SELECT Id, Name FROM User WHERE Id IN :usersIds];
        if(users != null && usersIds.size() > 0) {
            for(User us : users) {
                mapUserIdName.put(us.Id, us.Name);
            }
        }
    }
    
    public static Map<String, List<Milestone1_Task__c>> fillParentsTasks() {
        
        Map<String, List<Milestone1_Task__c>> mapParentAndChilds = new Map<String, List<Milestone1_Task__c>>();
        if(!String.isBlank(mytarget)){
            if(mytarget.startsWith(Schema.SObjectType.Milestone1_Project__c.getKeyPrefix())){
                List<String> parentTasksIds = new List<String>();
                if(sobjectList.size() > 0) {
                    for(Sobject sObj : sobjectList) {
                        parentTasksIds.add(sObj.Id);
                    }
                    
                    List<Milestone1_Task__c> listChildTasks = [SELECT Id, Project__c, Start_Date__c, Project_Milestone__c, Name, Assigned_To__c, Due_Date__c, Complete__c
                                                               FROM Milestone1_Task__c 
                                                               WHERE Project_Milestone__c in :parentTasksIds];
                    if(listChildTasks != null && listChildTasks.size() > 0) {
                        for(Milestone1_Task__c childTask : listChildTasks) {
                            if(mapParentAndChilds.containsKey(childTask.Project_Milestone__c))
                                mapParentAndChilds.get(childTask.Project_Milestone__c).add(childTask);
                            else
                                mapParentAndChilds.put(childTask.Project_Milestone__c, new List<Milestone1_Task__c> {childTask});
                        }
                    }
                }
            }
        }
        
        return mapParentAndChilds;
    }   
    
    /**
    *   Generate the output in json format to be rendered in the gantt.
    */
    private static String toJSon(){
        String ret = '';
        if(sobjectList.size() > 0) {
            ret = '{data:[';
            Boolean addComma=false,completed;
            Date startDate,endDate;
            String name,id;
            
            Map<String, List<Milestone1_Task__c>> mapChildAndParentTask = fillParentsTasks();
            getUsersByName(mapChildAndParentTask);
            
            for (integer i = 0; i < sobjectList.size(); i++){ 
                
                Sobject current = sobjectList.get(i);
                if(current.get(startDateFieldName) == null){
                    startDate = Date.today();
                }
                else{
                    startDate = Date.valueOf(current.get(startDateFieldName));
                }
                if(current.get(endDateFieldName) == null){
                    endDate = startDate;
                }
                else{
                    endDate = Date.valueOf(current.get(endDateFieldName));
                }
                completed = Boolean.valueOf(current.get(completedFieldName)); 
               // name = escapeDoubleQuotes(String.valueOf(current.get(nameFieldName)));
                id = String.valueOf(current.get(idFieldName));
                
                String color = COLOR_CURRENT;
                
                if (completed) {
                    color = COLOR_COMPLETE;
                } 
                else if (endDate < Date.today()) {
                    color = COLOR_LATE;
                } 
                else if (startDate > Date.today()) {
                    color = COLOR_FUTURE;
                }
                
                ret += '{' +
                    'id:"'+id+'",'+
                    'text:"'+(String.valueOf(current.get(nameFieldName))).replaceAll(REGEXP_QUOTES,'\\\\"').replaceAll('\\\\','')+'",'+
                    'start_date:"' + startDate.day() + '-' + (startDate.month()) + '-' + startDate.year()+'",' +
                    'end_date:"' + endDate.day() + '-' + (endDate.month()) + '-' + endDate.year()+'",';
                
                String userName = '';
                String currentId = current.Id;
                if(currentId.startsWith(Schema.SObjectType.Milestone1_Task__c.getKeyPrefix())) {
                    if(current.get(assignedToFieldName) != null){
                        userName = mapUserIdName.get((String) current.get(assignedToFieldName));
                        ret += 'assigned_to:"' + userName + '",';
                        ret += 'assigned_toId:"' + (String) current.get(assignedToFieldName) + '",';
                    }
                }
                
                if(completed){
                    ret += 'progress:"1",';
                }
                ret += 'color:"'+color+'"}';
                
                //If the task has children, add the children to the JSON
                if(mytarget.startsWith(Schema.SObjectType.Milestone1_Project__c.getKeyPrefix())) {
                    if(mapChildAndParentTask.containsKey(currentId)) {
                        for(Milestone1_Task__c childTask : mapChildAndParentTask.get(currentId)) {
                            String childColor = COLOR_CURRENT;
                            
                            if (childTask.Complete__c) {
                                childColor = COLOR_COMPLETE;
                            } 
                            else if (childTask.Due_Date__c < Date.today()) {
                                childColor = COLOR_LATE;
                            }
                            else if (childTask.Start_Date__c > Date.today()) {
                                childColor = COLOR_FUTURE;
                            } 
                            //TMA JSA 175
                            ret += ',{' +
                                'id:"'+childTask.id+'",'+
                                'text:"'+childTask.Name.replaceAll(REGEXP_QUOTES,'\\\\"')+'",'+
                                'start_date:"' + childTask.Start_Date__c.day() + '-' + (childTask.Start_Date__c.month()) + '-' + childTask.Start_Date__c.year()+'",' +
                                'end_date:"' + childTask.Due_Date__c.day() + '-' + (childTask.Due_Date__c.month()) + '-' + childTask.Due_Date__c.year()+'",' +
                                'color:"'+childColor+'",'+
                                'parent:"'+id+'"';
                            
                            if(childTask.Assigned_To__c != null){
                                userName = mapUserIdName.get(childTask.Assigned_To__c);
                                ret += ',assigned_to:"' + userName + '",';
                                ret += 'assigned_toId:"' + childTask.Assigned_To__c + '"';
                            }
                            ret += '}';
                        } 
                    }
                }
                
                if(i != sobjectList.size() - 1) {
                    ret += ',';
                }
            }
            
            ret+=']};';
            System.debug('### ret: ' + ret);
        }
        else {
            ret = '{data:[]};';
        }
        return ret;     
    }
    
    private static String escapeDoubleQuotes(String word){
        return word.replaceAll(REGEXP_QUOTES,'\\\\"');
         
         
        
        
    }
    
    @RemoteAction
    public static void saveAllTasksToSalesforce(String tasks) {
        System.Debug('#### The tasks value is : ' + tasks);
        List<Milestone1_Milestone__c> tasksToUpdate = new List<Milestone1_Milestone__c>();
        List<Milestone1_Task__c> actionsToUpdate = new List<Milestone1_Task__c>();
        
        //Update tasks in Salesforce
        if(!String.isBlank(tasks)) {
            String[] listTasks = tasks.split(';');
            if(listTasks != null) {
                for(String task : listTasks) {
                    String[] taskElements = task.split('>');
                    if(taskElements != null) {
                        String taskId = taskElements[0];
                        String taskName = taskElements[3];
                        String taskAssignedToId = taskElements[4];
                        
                        Integer startYear = Integer.valueOf(taskElements[1].split(' ')[3]);
                        Integer startMonth = months.get(taskElements[1].split(' ')[1]);
                        Integer startDay = Integer.valueOf(taskElements[1].split(' ')[2]);
                        
                        Integer endYear = Integer.valueOf(taskElements[2].split(' ')[3]);
                        Integer endMonth = months.get(taskElements[2].split(' ')[1]);
                        Integer endDay = Integer.valueOf(taskElements[2].split(' ')[2]);
                        
                        Date taskStartDate = Date.newInstance(startYear, startMonth, startDay);
                        Date taskEndDate = Date.newInstance(endYear, endMonth, endDay);
                        
                        if(taskId.startsWith(Schema.SObjectType.Milestone1_Milestone__c.getKeyPrefix())){
                            Milestone1_Milestone__c phase = new Milestone1_Milestone__c();
                            phase.Id = taskId;
                            phase.Name = taskName;
                            phase.Kickoff__c = taskStartDate;
                            phase.Deadline__c = taskEndDate;
                            tasksToUpdate.add(phase);
                        }
                        else if(taskId.startsWith(Schema.SObjectType.Milestone1_Task__c.getKeyPrefix())) {
                            Milestone1_Task__c action = new Milestone1_Task__c();
                            action.Id = taskId;
                            action.Name = taskName;
                            action.Start_Date__c = taskStartDate;
                            action.Due_Date__c = taskEndDate;
                            action.RIC_Type_Action__c = 'Avec Notification';
                            if(!String.isBlank(taskAssignedToId)) {
                                action.Assigned_To__c = taskAssignedToId;
                            }
                            
                            actionsToUpdate.add(action);
                        }
                    }
                }    
            }
        }
        
        if(tasksToUpdate.size() > 0)
            update tasksToUpdate;
        if(actionsToUpdate.size() > 0)
            update actionsToUpdate;
    }
    
    public static PageReference retour() {
        return new PageReference('/' + mytarget);
    }
    
    public static void getLatestAndFirstEndDates() {
        
        Date currentLatestDate = null;
        Date currentEarliestDate = null;
        /*
        for (integer i = 0; i < sobjectList.size(); i++){
            
            Date startDate = null;
            Date endDate = null;
            Sobject current = sobjectList.get(i);
            
            if(current.get(startDateFieldName) == null){
                startDate = Date.today();
            }
            else{
                startDate = Date.valueOf(current.get(startDateFieldName));
            }
            if(current.get(endDateFieldName) == null){
                endDate = startDate;
            }
            else{
                endDate = Date.valueOf(current.get(endDateFieldName));
            }
            
            if(currentLatestDate == null)
                currentLatestDate = endDate;
            else if(endDate > currentLatestDate)
                currentLatestDate = endDate;
            
            if(currentEarliestDate == null)
                currentEarliestDate = startDate;
            else if(startDate < currentEarliestDate)
                currentEarliestDate = startDate;
        }
        
        //Start the Gantt with 15 days earlier than the earliest start date and 15 days more than the latest end date
        if(currentLatestDate != null)
            currentLatestDate = currentLatestDate.addDays(15);
        else
            currentLatestDate = Date.today().addDays(15);
        
        if(currentEarliestDate != null)
            currentEarliestDate = currentEarliestDate.addDays(-15);
        else 
            currentEarliestDate = Date.today();
        */
        if(mytarget.startsWith(Schema.SObjectType.Milestone1_Project__c.getKeyPrefix())){
            Milestone1_Project__c ricProject = [SELECT RIC_MAD_Date__c, RIC_MAD_Date_Approved__c, RIC_Request_Date__c FROM Milestone1_Project__c WHERE Id = :mytarget];
            if(ricProject != null) {
                earliestStartDate = ricProject.RIC_Request_Date__c;
                latestEndDate = ricProject.RIC_MAD_Date__c != null ? ricProject.RIC_MAD_Date__c.addYears(1) : ricProject.RIC_Request_Date__c.addYears(1);
                projectEndDate = ricProject.RIC_MAD_Date_Approved__c != null ? ricProject.RIC_MAD_Date_Approved__c : ricProject.RIC_MAD_Date__c;
            }
        }
        if(mytarget.startsWith(Schema.SObjectType.Milestone1_Milestone__c.getKeyPrefix()) && phaseStartDate != null && phaseEndDate != null) {
            latestEndDate = phaseEndDate;
            earliestStartDate = phaseStartDate;
        }
        System.debug(latestEndDate + ',  ' + earliestStartDate);
    }
}