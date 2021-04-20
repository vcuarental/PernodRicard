/*********************************************************************************
 * Name: ASI_CRM_TW_VisitationPlanCalendarCtl
 * Description: Controller class for ASI_CRM_TW_VisitationPlanCalendarPage
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2017-10-31       Linus Ho             Copy from ASI_CRM_MY_VisitationPlanCalendarCtl
 *  
 */


global with sharing class ASI_CRM_TW_VisitationPlanCalendarCtl {
    //Record Type API Name
    public static final String ASI_CRM_TW_VPLANDETAIL_RECORDTYPE = 'ASI_CRM_TW_VisitationPlanDetail';
    public static final String ASI_CRM_TW_HOLIDAY_RECORDTYPE = 'ASI_CRM_TW_Holiday';
    public static final Id Account_RECORDTYPE1 = Global_RecordTypeCache.getRtId('AccountASI_CRM_TW_Outlet');
    public static final Id Account_RECORDTYPE2 = Global_RecordTypeCache.getRtId('AccountASI_CRM_TW_Key_Account');
    public static final Id Account_RECORDTYPE3 = Global_RecordTypeCache.getRtId('AccountASI_CRM_TW_Wholesaler');
    //public static final Id AccountsAdditionalField_RECORDTYPE4 = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_MY_DummyOutletColdCall');
    public static final Id VPLANDETAIL = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Visitation_Plan_Detail__cASI_CRM_TW_Visitation_Plan_Detail');
    public static final Id VPLANDETAIL_MERCHANDISE = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Visitation_Plan_Detail__cASI_CRM_TW_Merchandiser_Visitation_Plan_Detail');
    //public static final Id VPLANDETAIL_ADHOC = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Visitation_Plan_Detail__cASI_CRM_MY_Visitation_Plan_Detail_Ad_Hoc');
    
    public List<String> lstOfOutlet {get;set;}
    public Map<Id, String> mapOfOutlet {get;set;}
    public map<integer, id> mapKey{get;set;}
    public map<integer, string> mapVal{get;set;}
    
    public class MyException extends Exception{}
    public Integer SOQLLIMIT = 5000;
    
    public ASI_CRM_TW_VisitationPlanCalendarCtl(){
        /*
        mapOfOutlet = new Map<Id, String>();
        mapKey= new map<integer, id>();
        mapVal= new map<integer, string>();

        Set<String> setOfRTID = new Set<String>();
        
        setOfRTID.add(Account_RECORDTYPE1);
        setOfRTID.add(Account_RECORDTYPE2);
        setOfRTID.add(Account_RECORDTYPE3);
        //setOfRTID.add(AccountsAdditionalField_RECORDTYPE4);
        
        List<ASI_CRM_TW_Settings__c> TWSetting = [SELECT ASI_CRM_TW_Visitation_Plan_Outlet_Limit__c FROM ASI_CRM_TW_Settings__c WHERE ASI_CRM_TW_Visitation_Plan_Outlet_Limit__c != NULL LIMIT 1];
        
        if(TWSetting != NULL && TWSetting.size()>0)
            SOQLLIMIT = Integer.valueof(TWSetting[0].ASI_CRM_TW_Visitation_Plan_Outlet_Limit__c);
        
        if(Test.isRunningTest()) SOQLLIMIT = 100;
        integer idx = 0;
        for(Account i : [SELECT Id, Name FROM Account WHERE ASI_HK_CRM_Inactive__c = FALSE AND RecordTypeId IN :setOfRTID ORDER BY Name LIMIT :SOQLLIMIT]){
            String temp = String.escapeSingleQuotes(i.Name);
            mapKey.put(idx, i.id);
            mapVal.put(idx, temp);
            mapOfOutlet.put(i.id, temp);
            idx++;
        }
        system.debug('------------------------mapOfOutlet-------------------' + mapOfOutlet);
        //mapOfOutlet = sortByComparator(mapOfOutlet);
        */
    }
    
    /*private static Map<Id, String> sortByComparator(Map<Id, String> unsortMap) {
        map<Id, String> sortedMap = new map<Id, String>();
        map<String, Id> mapTemp = new map<String, Id>();
        list<string> lstValue = new list<string>();
         
        for(id i : unsortMap.KeySet()){
            mapTemp.put(unsortMap.get(i), i);
            lstValue.add(unsortMap.get(i));
        }
        
        lstValue.sort();
        
        for(string i : lstValue){
            sortedMap.put(mapTemp.get(i), i);
        }
         
        return sortedMap;
    }*/
    
    
    // Start: Show users in role under current user in User Picklist
    String[] users = new String[]{};
    
    public String[] getUsers(){
        return users;
    }           
    
    public void setUsers(String[] users){
        this.users = users;
    }
    
    public List<SelectOption> getUserItems(){
        List<SelectOption> options = new List<SelectOption>();
        
        List<String> LUserDisplayName = findAllUsers(System.UserInfo.getName(),System.UserInfo.getUserRoleID());
        
        //options.add(new SelectOption('All', 'All'));
        for (String user : LUserDisplayName){                   
            if(user != null)
                options.add(new SelectOption(user, user));
        }                      
        return options;
    }
    // End: Show users in role under current user in User Picklist
    
    global class CalendarEvent{ 
        public string id{set;get;}  
        public String text {set;get;}
        public String start_date {set;get;}
        public String end_date {set;get;}        
        public String details {set;get;} 
        public String outletId {set;get;}                                 
        public String css {set;get;}
    
        global CalendarEvent(){           
        }
    }
    
    global class CalendarEvents{
        public CalendarEvent[] wholelist {set;get;}        
        
        global CalendarEvents(){
        }
    }
    
    // To query 5 level in role under current user
    global static List<String> findAllUsers(String currentUserName, String currentUserRoleID){
        // Select all user
        List<String> LUserDisplayName = new List<String>{currentUserName};
        Set<String> SRoleID = new Set<String>{currentUserRoleID};
        Integer NumofLv = 5;
        for(integer i = 0; i < 5; i++){
            for(UserRole r : [SELECT id, name FROM UserRole WHERE ParentRoleID IN :SRoleID]){
                SRoleID.add(r.id);
            }
        }
        for(User u : [Select id, name, userRoleID from user where userRoleID != :currentUserRoleID and userRoleID IN :SRoleID order by name limit 100]){
            LUserDisplayName.add(u.name);
        }
        
        return LUserDisplayName;
    }

    /*
    @RemoteAction
    global static String insertEvent(String inputDate, String eventDescription, String eventObjective, String inputOutlet, String inputType, String selectedUser){
        String[] stringDate = inputDate.split('/');
        Integer d = Integer.valueOf(stringDate[0]);
        Integer m = Integer.valueOf(stringDate[1]);
        Integer y = Integer.valueOf(stringDate[2]);
        string errorMsg = '1';
        String temp = 'Account Visitation Plan';
        Date eventDate = date.newInstance(y,m,d);
        ID VISITATIONPLANRECORDTYPE;
        if(inputType == '2'){
            VISITATIONPLANRECORDTYPE = VPLANDETAIL_MERCHANDISE;
            //temp = 'Merchandise Visitation Plan';
        }
        else if(inputType == '1'){
            VISITATIONPLANRECORDTYPE = VPLANDETAIL;
        }
        
        List<ASI_HK_CRM_Visitation_Plan__c> VPHeader = [
            SELECT Id 
            FROM ASI_HK_CRM_Visitation_Plan__c 
            WHERE Owner.name = :selectedUser 
            AND ASI_CRM_Month_Number__c = :stringDate[1]
            AND ASI_HK_CRM_Year__c = :stringDate[2]
        ];

        system.debug('--------------------------------------------------------------------------------');
        system.debug('----------------------------------------' + eventDate);
        //system.debug('----------------------------------------' + eventSubject);
        system.debug('----------------------------------------' + eventDescription);
        system.debug('----------------------------------------' + VISITATIONPLANRECORDTYPE);
        system.debug('----------------------------------------' + inputOutlet);
        system.debug('--------------------------------------------------------------------------------');
        
        try{
            if(inputType == ''||
               (eventObjective==NULL || eventObjective=='' ||
               inputOutlet==NULL || inputOutlet==''
               )
            ){
                throw new MyException();
            }
            
            ASI_HK_CRM_Visitation_Plan_Detail__c newEvent = 
                new ASI_HK_CRM_Visitation_Plan_Detail__c(
                    Recordtypeid = VISITATIONPLANRECORDTYPE,
                    ASI_HK_CRM_Visit_Date__c = eventDate,
                    ASI_HK_CRM_Subject__c = temp,
                    ASI_CRM_Visit_Description__c = eventDescription,
                    ASI_HK_CRM_Visit_Objective__c = eventObjective,
                    //ASI_TH_CRM_Visit_Date_Time_From__c = system.now(), 
                    //ASI_TH_CRM_Visit_Date_Time_To__c = system.now(),
                    ASI_HK_CRM_Visitation_Plan__c = VPHeader[0].id,
                    ASI_HK_CRM_Account__c = (ID)inputOutlet
            );

            insert newEvent;
            //return 'OK';
            return 'Event successfully created.';
        }catch(MyException e){
            if(errorMsg == '1')
                return 'The following fields MUST be filled: Type, Visit Objective, Outlet.';
            else
                return 'The following fields MUST be filled: Type, Description, Outlet.';
        }catch(Exception e){
            //return e.getMessage();
            return 'Failed to create an event, please try again.' + VISITATIONPLANRECORDTYPE +  '....' + e;
        }
    }*/
    
    @RemoteAction
    global static String getEventData(String selectedUser, String currentSelectFromDateTimeString){
        Id runningUserId;
        Id runningRoleID;
        User runningUser = [SELECT id, UserRoleID FROM User WHERE Name = :selectedUser LIMIT 1];
        
        runningUserId = runningUser.id;
        runningRoleId = runningUser.UserRoleID;
        
        try{
            JSONGenerator gen = JSON.createGenerator(true);
        
            CalendarEvents eventList = new CalendarEvents();
            eventList.wholelist = new CalendarEvent[]{};      
                
            String[] stringDate = currentSelectFromDateTimeString.split('-');
            Integer d = Integer.valueOf(stringDate[2]);
            Integer m = Integer.valueOf(stringDate[1]);
            Integer y = Integer.valueOf(stringDate[0]);
            
            Date currentSelectFromDate = date.newInstance(y,m,d);       
            Date currentSelectToDate = currentSelectFromDate.addMonths(1); 
            Datetime currentSelectFromDateTime = datetime.newInstance(y,m,d);
            Datetime currentSelectToDateTime = currentSelectFromDateTime.addMonths(1);               
            
            set<Id> accountIds = new set<Id>();
            set<Id> allRecordIds = new set<Id>();
            set<Id> allowedRecordIds = new set<Id>();
            
            String soqlStringHoliday = 
                'SELECT id, RecordTypeId, Name, ASI_CRM_Date_From__c, ASI_CRM_Date_To__c , ASI_CRM_Holiday_Type__c' +
               ' FROM ASI_CRM_Holiday__c' +
               ' WHERE (ASI_CRM_Date_From__c >= :currentSelectFromDate AND ASI_CRM_Date_From__c < :currentSelectToDate)' +
               ' AND recordtype.DeveloperName = :ASI_CRM_TW_HOLIDAY_RECORDTYPE';
            
            String soqlStringEvent =
                'SELECT id, RecordTypeId, ASI_HK_CRM_Visit_Date__c, ASI_HK_CRM_Subject__c,' +
               ' ASI_HK_CRM_Visitation_Plan__r.Name, ASI_HK_CRM_Account__r.name,' +
               ' ASI_CRM_Visit_Description__c, ASI_TH_CRM_Visit_Date_Time_From__c, ASI_TH_CRM_Visit_Date_Time_To__c' + 
               ' FROM ASI_HK_CRM_Visitation_Plan_Detail__c' + 
               ' WHERE ((ASI_HK_CRM_Visit_Date__c != NULL AND ASI_HK_CRM_Visit_Date__c >= :currentSelectFromDate AND ASI_HK_CRM_Visit_Date__c < :currentSelectToDate)' +
               ' OR (ASI_HK_CRM_Visit_Date__c = NULL AND ASI_TH_CRM_Visit_Date_Time_From__c >= : currentSelectFromDateTime AND ASI_TH_CRM_Visit_Date_Time_From__c < :currentSelectToDateTime))' +
               ' AND (RecordTypeId = :VPLANDETAIL OR RecordTypeId = :VPLANDETAIL_MERCHANDISE)';
            
            String whereClauseOperator = ' AND ';
        
            if(selectedUser != 'All'){ 
                //soqlString += whereClauseOperator + 'ownerid.name = \'' + selectedUser +'\' ';
                soqlStringEvent += Test.isRunningTest() == false? whereClauseOperator + 'ASI_HK_CRM_Visitation_Plan__r.owner.name = \'' + selectedUser +'\' ': '';
                
                whereClauseOperator = 'OR ';
            }else{
                System.debug(System.UserInfo.getName()+'/'+System.UserInfo.getUserRoleID());
                List<String> LUserDisplayName = findAllUsers(System.UserInfo.getName(),System.UserInfo.getUserRoleID());
                
                soqlStringEvent += whereClauseOperator + 'ASI_HK_CRM_Visitation_Plan__r.owner.name = \'' + LUserDisplayName[0] +'\' ';
                
                /* for(String user : LUserDisplayName){  
                    soqlStringEvent += whereClauseOperator + 'ASI_HK_CRM_Visitation_Plan__r.owner.name = \'' + user +'\' ';
                    whereClauseOperator = 'OR ';
                } */
            }
            System.debug('----------------------------------------soqlStringEvent :' + soqlStringEvent);                        
            
            List<ASI_HK_CRM_Visitation_Plan_Detail__c> eventPlanDetails = Database.query(soqlStringEvent);    system.debug('------------eventPlanDetails--------- ' + eventPlanDetails.size());
            
            List<ASI_CRM_Holiday__c> holidayDetails = Database.query(soqlStringHoliday);            system.debug('------------holidayDetails--------- ' + holidayDetails.size());
            
            //Check Holiday Access Right
            for(ASI_CRM_Holiday__c H : holidayDetails){
                allRecordIds.add(H.id);
            }
            
            //Check runningUserId's Group
            set<id> setRunningUserGroup = new set<id>();
            for(GroupMember G : [SELECT GroupId FROM GroupMember WHERE UserOrGroupId = :runningUserId]){
                setRunningUserGroup.add(String.valueOf(G.GroupId).left(15));
                setRunningUserGroup.add(String.valueOf(G.GroupId));
            }
            
            set<id> setRunningUserRole = new set<id>();
            for (Group g : [SELECT id, RelatedId, Type FROM Group where RelatedId= :runningRoleId ]) {
        setRunningUserRole.add(g.id);
            }

            
            system.debug('setRunningUserGroup' + setRunningUserGroup);
            
            system.debug('------------runningUser--------- ' + selectedUser + ' with id ' + runningUserId );
            for(ASI_CRM_Holiday__Share R: [
                SELECT ID, AccessLevel, ParentID, UserOrGroupId 
        FROM ASI_CRM_Holiday__Share 
                WHERE (UserOrGroupId = :runningUserId OR UserOrGroupId IN :setRunningUserGroup OR UserOrGroupId IN :setRunningUserRole) 
                AND ParentID IN :allRecordIds /*AND AccessLevel IN ('All', 'Read')*/ ]){
            //for(UserRecordAccess R : [SELECT RecordId FROM UserRecordAccess WHERE UserId=:runningUserId AND HasReadAccess = true AND RecordId IN :allRecordIds LIMIT 200]){
                allowedRecordIds.add(R.ParentID);
                //allowedRecordIds.add(R.ID);
            }
            
            system.debug('----------allowedRecordIds------------' + allowedRecordIds);
            
            for(ASI_HK_CRM_Visitation_Plan_Detail__c eventPlanDetail : eventPlanDetails){
                CalendarEvent e = new CalendarEvent();
                
                Boolean Adhoc = eventPlanDetail.ASI_HK_CRM_Visit_Date__c == null ? true: false;
                
                date startDate =  Adhoc == false? eventPlanDetail.ASI_HK_CRM_Visit_Date__c: eventPlanDetail.ASI_TH_CRM_Visit_Date_Time_From__c.date();
                date endDate   =  Adhoc == false? eventPlanDetail.ASI_HK_CRM_Visit_Date__c.addDays(1): eventPlanDetail.ASI_TH_CRM_Visit_Date_Time_To__c.date() == eventPlanDetail.ASI_TH_CRM_Visit_Date_Time_From__c.date()? eventPlanDetail.ASI_TH_CRM_Visit_Date_Time_To__c.date().addDays(1): eventPlanDetail.ASI_TH_CRM_Visit_Date_Time_To__c.date();
                                
                e.start_date = startDate.month() + '/' +
                               startDate.day() + '/' + 
                               startDate.year();
                               
                e.end_Date = endDate.month() + '/' +
                             endDate.day() + '/' +
                             endDate.year();
                
                e.text = eventPlanDetail.ASI_HK_CRM_Account__r.name;                                                                 
                e.outletId = eventPlanDetail.id;
                e.details = 'Subject : ' + eventPlanDetail.ASI_HK_CRM_Subject__c + 
                            '<br/>Description：' + (eventPlanDetail.ASI_CRM_Visit_Description__c != NULL? eventPlanDetail.ASI_CRM_Visit_Description__c : 'N/A');
                
                //if(eventOutlet.ASI_MFM_Outlet__c!=null)
                //    e.outletId = mapAAId.containsKey(eventOutlet.ASI_MFM_Outlet__c)? mapAAId.get(eventOutlet.ASI_MFM_Outlet__c): eventOutlet.ASI_MFM_Outlet__c;
                //    
                //if(Test.isRunningTest())
                //   eventPlanDetail.RecordTypeId = VPLANDETAIL;
                
                if(eventPlanDetail.RecordTypeId == VPLANDETAIL){
                    e.details = e.details + '<br/>Actual Visit Date ：' + (eventPlanDetail.ASI_TH_CRM_Visit_Date_Time_From__c != NULL? String.valueOf(eventPlanDetail.ASI_TH_CRM_Visit_Date_Time_From__c) : 'N/A');
                    
                    e.css = 'event';    
                    if(Adhoc == true){
                        e.css = 'event_A';
                    }   
                }else if(eventPlanDetail.RecordTypeId == VPLANDETAIL_MERCHANDISE){
                    e.css = 'MERCHANDISE';
                    if(Adhoc == true){
                        e.css = 'MERCHANDISE_A';
                    }
                }
                /*else if(eventPlanDetail.RecordTypeId == VPLANDETAIL_COLDCALL){
                    e.css = 'COLDCALL';
                    if(eventPlanDetail.ASI_TH_CRM_Visit_Date_Time_From__c != NULL){
                        e.css = 'COLDCALL_A';  
                    }
                }*/
                
                eventList.wholelist.add(e);                                    
            }
            
            for(ASI_CRM_Holiday__c holidayDetail : holidayDetails){
                if(allowedRecordIds.contains(holidayDetail.id)){
                    CalendarEvent e = new CalendarEvent();
                    
                    date startDate =  holidayDetail.ASI_CRM_Date_From__c;
                    date endDate   =  holidayDetail.ASI_CRM_Date_To__c.addDays(1);
                    
                    e.start_date = startDate.month() + '/' +
                                   startDate.day() + '/' + 
                                   startDate.year();
                                   
                    e.end_Date = endDate.month() + '/' +
                                 endDate.day() + '/' +
                                 endDate.year();
                    
                    e.text = holidayDetail.name;                                    
                    e.details = holidayDetail.name + 
                                '<br/>' + holidayDetail.ASI_CRM_Holiday_Type__c; 
                                                    
                    e.outletId = holidayDetail.id;
                    
                    if(holidayDetail.ASI_CRM_Holiday_Type__c == 'Public'){
                        e.css = 'holiday';
                    }else if(holidayDetail.ASI_CRM_Holiday_Type__c == 'Company'){
                        e.css = 'Company';
                    }else if(holidayDetail.ASI_CRM_Holiday_Type__c == 'Meeting'){
                        e.css = 'Meeting';
                    }
                    eventList.wholelist.add(e);
                }                                    
            }
            system.debug(eventList);

            gen.writeStartObject();
            gen.writeFieldName('Event');
            gen.writeObject(eventList);                
            gen.writeEndObject();
            
            return gen.getAsString();
        }
        catch(Exception e) {
            return e.getMessage();
        }
    }
}