global with sharing class ASI_CRM_CN_EventCalendar {
    // Start: Added by Michael Yip (Introv) 17Sep2014 to query 5 level in role under current user
    
    String[] users = new String[]{};
    
     public String[] getUsers() {
        return users;
    }           
    
    public void setUsers(String[] users) {
        this.users = users;
    }
    
    Public static String selectedRegion { set; get; }
    Public static String selectedDivision { set; get; }
    Public static String selectedBrand { set; get; }
    Public static String selectedSubBrand { set; get; }
    Public static String selectedChannel { set; get; }
    Public static String selectedEventType { set; get; }
    
    /*public List<SelectOption> getUserItems() {
        List<SelectOption> options = new List<SelectOption>();
        
        List<String> LUserDisplayName = findAllUsers(System.UserInfo.getName(),System.UserInfo.getUserRoleID());
        
        options.add(new SelectOption('All', 'All'));
        for (String user : LUserDisplayName)
        {                   
            if (user != null)
                options.add(new SelectOption(user, user));
        }                      
        return options;
    }*/
    // End: Added by Michael Yip (Introv) 17Sep2014 to query 5 level in role under current user
    
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
    
    //----------------------------------------getFullRegion
    Public List<SelectOption> getFullRegion(){
        //List<ASI_MFM_Event__c> allEvents = new List<ASI_MFM_Event__c>([SELECT id  FROM ASI_MFM_Event__c WHERE ASI_MFM_Start_Date__c >= : date.newInstance(date.today().year(),date.today().month(),1) AND ASI_MFM_End_Date__c < : date.newInstance(date.today().year(),date.today().month()+1,1)]);
        
        List<SelectOption> allRegion = new List<SelectOption>();
        List<ASI_CRM_Region__c> allRegionList = new List<ASI_CRM_Region__c>([SELECT id, Name FROM ASI_CRM_Region__c]);
        
        selectedRegion = 'All';
        
        allRegion.add(new SelectOption('All','All'));
        
        for(ASI_CRM_Region__c obj : allRegionList)
            allRegion.add(new SelectOption(obj.id,obj.Name));
            
        return allRegion;
    }
    
    //----------------------------------------getfullDivision
    Public List<SelectOption> getfullDivision(){
        List<SelectOption> allDivision = new List<SelectOption>();
        List<ASI_CRM_Division__c> allDivisionList = new List<ASI_CRM_Division__c>();
        
        allDivision.add(new SelectOption('All','All'));

        if(SelectedRegion != 'All')
        	allDivisionList = [SELECT id, Name FROM ASI_CRM_Division__c WHERE ASI_CRM_Region__c =: SelectedRegion];
        else{
            selectedDivision = 'All';
            allDivisionList = [SELECT id, Name FROM ASI_CRM_Division__c];
        }
        
        
        for(ASI_CRM_Division__c obj : allDivisionList)
            allDivision.add(new SelectOption(obj.id,obj.Name));
        
        return allDivision;
    }
    
    //----------------------------------------getfullBrand
    Public List<SelectOption> getfullBrand(){
        List<SelectOption> allBrand = new List<SelectOption>();
        List<ASI_CRM_CN_Brand_Group__c> allBrandList = new List<ASI_CRM_CN_Brand_Group__c>([SELECT id, Name FROM ASI_CRM_CN_Brand_Group__c]);
        
        allBrand.add(new SelectOption('All','All'));
        
        for(ASI_CRM_CN_Brand_Group__c obj : allBrandList)
            allBrand.add(new SelectOption(obj.id,obj.Name));
        
        return allBrand;
    }
    
    //----------------------------------------getSubBrandItems
    public List<SelectOption> getSubBrandItems() {
        List<SelectOption> options = new List<SelectOption>();
        List<ASI_MFM_Sub_brand__c> eventSubBrand = new List<ASI_MFM_Sub_brand__c>([SELECT id, Name FROM ASI_MFM_Sub_brand__c WHERE 	ASI_MFM_Brand__r.ASI_CRM_CN_Competitor__c = False AND recordType.DeveloperName = 'ASI_FOC_CN_Sub_brand' AND ASI_MFM_Active_for_CRM__c = true Order By ASI_HK_CRM_English_Name__c]);
        
        options.add(new SelectOption('All', 'All'));
        for (ASI_MFM_Sub_brand__c Obj : eventSubBrand)
        {
                options.add(new SelectOption(Obj.id, obj.Name));
        }
        return options;
    }
    
    //----------------------------------------getFullchannel
    public List<SelectOption> getFullchannel(){
        List<SelectOption> allChannel = new List<SelectOption>();
        List<ASI_CRM_CN_Channel__c> allChannelList = new List<ASI_CRM_CN_Channel__c>([SELECT id, Name FROM ASI_CRM_CN_Channel__c WHERE recordType.DeveloperName = 'ASI_CRM_CN_Channel' Order By Name]);
        
        allChannel.add(new SelectOption('All', 'All'));
        
        for(ASI_CRM_CN_Channel__c obj : allChannelList)
            allChannel.add(new SelectOption(obj.id, obj.Name));
        
        return allChannel;
    }
    
    //----------------------------------------getFullEventType
    public List<SelectOption> getFullEventType(){
        List<SelectOption> allEventType = new List<SelectOption>();
        
        Schema.DescribeFieldResult fieldResult = ASI_MFM_Event_Outlet__c.ASI_MFM_Event_Type__c.getDescribe();
        List<Schema.PicklistEntry> pickListValue = fieldResult.getPicklistValues();
        
        allEventType.add(new SelectOption('All', 'All'));
        
        for(Schema.PicklistEntry plv : pickListValue){
            
            allEventType.add(new SelectOption(plv.getValue(), plv.getValue()));
        }
        
        /*allEventType.add(new SelectOption('Image/Brand Driven Event', 'Image/Brand Driven Event'));
        allEventType.add(new SelectOption('Thematic Promotion', 'Thematic Promotion'));
        allEventType.add(new SelectOption('Vol. Promotion', 'Vol. Promotion'));
        allEventType.add(new SelectOption('Mentoring', 'Mentoring'));
        allEventType.add(new SelectOption('Consumer Trail', 'Consumer Trail'));
        allEventType.add(new SelectOption('CRM', 'CRM'));
        allEventType.add(new SelectOption('Trade Fair', 'Trade Fair'));
        allEventType.add(new SelectOption('Commando', 'Commando'));
        allEventType.add(new SelectOption('Image Event', 'Image Event'));
        allEventType.add(new SelectOption('Luxe Event', 'Luxe Event'));
        allEventType.add(new SelectOption('NPL Event', 'NPL Event'));*/
        
        return allEventType;
    }
    // Added by Michael Yip (Introv) 17Sep2014 to query 5 level in role under current user
    /*global static List<String> findAllUsers(String currentUserName, String currentUserRoleID){
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
    }*/
    
    @RemoteAction
    global static String getEventData(String brandID, String subBrandID, String channelID, String divisionID, String eventType, String regionID, String selectedUser, String currentSelectFromDateTimeString) {
        
        system.debug('brandID ' + brandID + ' subBrandID ' + subBrandID + ' channelID ' + channelID + ' divisionID ' + divisionID + ' eventType ' + eventType + ' regionID ' + regionID);
        
        try {
            
            JSONGenerator gen = JSON.createGenerator(true);
            
            CalendarEvents eventList = new CalendarEvents();
            eventList.wholelist = new CalendarEvent[]{};      
                
            String[] stringDate = currentSelectFromDateTimeString.split('-');
            Integer d =  Integer.valueOf(stringDate[2]);
            Integer m = Integer.valueOf(stringDate[1]);
            Integer y = Integer.valueOf(stringDate[0]);
            
            Date currentSelectFromDate = date.newInstance(y,m,d);       
            Date currentSelectToDate = currentSelectFromDate.addMonths(1);                
            
            set<Id> accountIds = new set<Id>();
            
            String soqlString = 'SELECT id, ASI_MFM_Beginning_Date__c, ASI_MFM_End_Date__c, ASI_MFM_Event__r.Name,  ' +
                'ASI_MFM_Outlet__c, ASI_MFM_Outlet__r.Name, ASI_MFM_Outlet__r.ownerid FROM ASI_MFM_Event_Outlet__c ' + 
                'WHERE ((ASI_MFM_Beginning_Date__c >= :currentSelectFromDate AND ASI_MFM_Beginning_Date__c < :currentSelectToDate) ' + 
                'OR (ASI_MFM_End_Date__c >= :currentSelectFromDate AND ASI_MFM_End_Date__c < :currentSelectToDate) ' + 
                'OR (ASI_MFM_End_Date__c > :currentSelectToDate AND ASI_MFM_Beginning_Date__c < :currentSelectFromDate)) ';
            
            // +
            //'AND ASI_MFM_Outlet__r.ownerid = \'' + UserInfo.getUserId() + '\' ';               
            
            /*String soqlStringEvent = 'SELECT Subject, StartDateTime, EndDateTime, AccountId, Account.Name, IsAllDayEvent, WhatId FROM Event ' + 
                'WHERE ((StartDateTime>= :currentSelectFromDate AND StartDateTime< :currentSelectToDate) ' + 
                'OR (EndDateTime >= :currentSelectFromDate AND EndDateTime < :currentSelectToDate) ' + 
                'OR (EndDateTime > :currentSelectToDate AND StartDateTime< :currentSelectFromDate)) ';
            
            
            
            //List<ASI_MFM_Event__c> allEvents = new List<ASI_MFM_Event__c>();
            
            /*if(currentSelectFromDateTimeString == '' || currentSelectFromDateTimeString == null)
            	allEvents =new List<ASI_MFM_Event__c>([SELECT id  FROM ASI_MFM_Event__c WHERE ASI_MFM_Start_Date__c >= : date.newInstance(date.today().year(),date.today().month(),1) AND ASI_MFM_End_Date__c < : date.newInstance(date.today().year(),date.today().month()+1,1)]);
            else
                allEvents =new List<ASI_MFM_Event__c>([SELECT id  FROM ASI_MFM_Event__c WHERE ASI_MFM_Start_Date__c >= : currentSelectFromDate AND ASI_MFM_End_Date__c < : currentSelectToDate]);*/
            
            //fullRegion(allEvents);
            
            /*if (selectedUser != 'All') { 
                soqlString += whereClauseOperator + 'ASI_MFM_Outlet__r.owner.name = \'' + selectedUser +'\' ';
                //Added by Wilson to support TMKT use 3/3/2015
                soqlString += ' OR ASI_MFM_Event__r.Owner.Name = \'' + selectedUser +'\' ';                
                soqlStringEvent += whereClauseOperator + 'owner.name = \'' + selectedUser +'\' ';
                whereClauseOperator = 'OR ';
            }
            else{
                System.debug(System.UserInfo.getName()+'/'+System.UserInfo.getUserRoleID());
                List<String> LUserDisplayName = findAllUsers(System.UserInfo.getName(),System.UserInfo.getUserRoleID());
                for (String user : LUserDisplayName){
                    soqlStringEvent += whereClauseOperator + 'owner.name = \'' + user +'\' ';
                    soqlString += whereClauseOperator + 'ASI_MFM_Outlet__r.owner.name = \'' + user +'\' ';
                    //Added by Wilson to support TMKT use 3/3/2015
                    soqlString += ' OR ASI_MFM_Event__r.Owner.Name = \'' + user +'\' ';
                    whereClauseOperator = 'OR ';
                }
            }*/
            String whereClauseOperator = 'AND ';
            
            if(eventType != 'All'){
                soqlString += whereClauseOperator + 'ASI_MFM_Event_Type__c =: eventType ';
            }
            if(brandID != 'All'){
                soqlString += whereClauseOperator + 'ASI_MFM_Event__c in (SELECT ASI_MFM_Event__c FROM ASI_MFM_Event_Sub_Brand__c WHERE ASI_MFM_Sub_brand__r.ASI_MFM_Brand__c = :brandID) ';
            }
            if(subBrandID != 'All'){
                soqlString += whereClauseOperator + 'ASI_MFM_Event__c in (SELECT ASI_MFM_Event__c FROM ASI_MFM_Event_Sub_Brand__c WHERE ASI_MFM_Sub_brand__c = :subBrandID) ';
            }
            if(channelID != 'All'){
                soqlString += whereClauseOperator + 'ASI_MFM_CN_Customer__r.ASI_CRM_CN_Sub_Channel__r.ASI_CRM_CN_Channel__c =: channelID '; 
            }
            if(regionID != 'All'){
                soqlString += whereClauseOperator + 'ASI_MFM_CN_Customer__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c = :regionID ';
            }
            if(divisionID != 'All'){
                soqlString += whereClauseOperator + 'ASI_MFM_CN_Customer__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__c = :divisionID ';
            }            
            //soqlString += ')';
            //soqlStringEvent += ')';
            System.debug(soqlString);
            
            List<ASI_MFM_Event_Outlet__c> eventOutlets = Database.query(soqlString);
            
            //for(ASI_MFM_Event_Outlet__c eventOutlet : eventOutlets)
                //accountIds.add(eventOutlet.ASI_MFM_Outlet__c);
            
            /*String soalStringEvent = 'SELECT Subject, StartDateTime, EndDateTime, AccountId, Account.Name, IsAllDayEvent, WhatId FROM Event ' + 
                'WHERE ((StartDateTime>= :currentSelectFromDate AND StartDateTime< :currentSelectToDate) ' + 
                'OR (EndDateTime >= :currentSelectFromDate AND EndDateTime < :currentSelectToDate) ' + 
                'OR (EndDateTime > :currentSelectToDate AND StartDateTime< :currentSelectFromDate)) '; //+
                //'AND ownerid = \'' + UserInfo.getUserId() + '\' ';               
            
            /*whereClauseOperator = 'AND (';
        
            if (selectedUser != 'All') { 
                soalString += whereClauseOperator + 'owner.name = \'' + selectedUser +'\' ';
                whereClauseOperator = 'OR ';
            }
            else{
                System.debug(System.UserInfo.getName()+'/'+System.UserInfo.getUserRoleID());
                List<String> LUserDisplayName = findAllUsers(System.UserInfo.getName(),System.UserInfo.getUserRoleID());
                for (String user : LUserDisplayName){
                    soalString += whereClauseOperator + 'owner.name = \'' + user +'\' ';
                    whereClauseOperator = 'OR ';
                }
            }*/
            
            //System.debug(soqlStringEvent);
            //List<Event> events = Database.query(soqlStringEvent);
            
            /*for(Event e : events) {
                if(e.AccountId!=null)
                    accountIds.add(e.AccountId);
            }
            
            map<Id, Id> mapAAId = new map<Id, Id>();
            if(accountIds.size()>0) {
                for(ASI_CRM_AccountsAdditionalField__c aa :[SELECT Id, ASI_CRM_Account__c FROM ASI_CRM_AccountsAdditionalField__c WHERE ASI_CRM_Account__c in :accountIds])
                    mapAAId.put(aa.ASI_CRM_Account__c, aa.Id);
            }*/

            for(ASI_MFM_Event_Outlet__c eventOutlet : eventOutlets){
                CalendarEvent e = new CalendarEvent();
                
                date startDate =  eventOutlet.ASI_MFM_Beginning_Date__c;
                date endDate =  eventOutlet.ASI_MFM_End_Date__c;
                
                e.start_date =  startDate.month() + '/' +
                    startDate.day() + '/' + 
                    startDate.year();
                e.end_Date =  endDate.month() + '/' +
                    endDate.addDays(1).day() + '/' +
                    endDate.year();
                
                e.text = eventOutlet.ASI_MFM_Outlet__r.Name + ' - ' + eventOutlet.ASI_MFM_Event__r.Name;                                    
                e.details = eventOutlet.ASI_MFM_Outlet__r.Name + ' - ' + eventOutlet.ASI_MFM_Event__r.Name + '<br/>Start Date：' + e.start_date + '<br/>End Date：' + endDate.month() + '/' +
                    endDate.day() + '/' +
                    endDate.year() ; 
                
                
                    e.outletId = eventOutlet.ASI_MFM_Event__c;
                
                e.css = 'event';
                
                eventList.wholelist.add(e);                                    
            }

            /*for(Event e: events){
                CalendarEvent addEvent = new CalendarEvent();
                
                dateTime startDate =  e.StartDateTime;
                dateTime endDate =  e.EndDateTime;
                string detail = '';
                
                if(e.IsAllDayEvent) {
                //throw new ASI_CRM_CN_Function.CRMException('hyuiu');
                    addEvent.start_date = startDate.format('MM/dd/yyyy');
                    addEvent.end_Date = endDate.addDays(1).format('MM/dd/yyyy');
                    detail = 'Start Date：' + startDate.format('MM/dd/yyyy') + '<br/>End Date：' + endDate.format('MM/dd/yyyy');
                }
                else {
                    addEvent.start_date =  startDate.format('MM/dd/yyyy HH:mm:ss');
                    addEvent.end_Date =  endDate.format('MM/dd/yyyy HH:mm:ss');
                    detail = 'Start Date：' + startDate.format('MM/dd/yyyy') + '<br/>End Date：' + endDate.format('MM/dd/yyyy');
                }
                
                if (e.Accountid == null){
                    string subject = e.Subject == null ? '' : e.Subject;
                    addEvent.text = subject.replace(' ','&nbsp').replace('(','&#40;').replace(')','&#41;'); 
                    //addEvent.text = e.Subject.replace(' ','&nbsp'); 
                    //addEvent.text = '<script>document.write(escape("' + e.Subject.replace(' ','&nbsp;')+'-' + '"))</script>';  
                    addEvent.details = subject + '<br/>' + detail;
                    //addEvent.details = '<br/>' + detail;
                }else{
                    addEvent.text = e.Account.Name + ' - ' + e.Subject;                                    
                    addEvent.details = e.Account.Name + ' - ' + e.Subject + '<br/>' + detail;
                }
                 
                addEvent.outletId = e.AccountId!=null? ( mapAAId.containsKey(e.AccountId)? (string)mapAAId.get(e.AccountId): (string)e.AccountId) : (e.WhatId!=null ? (string)e.WhatId : '');
                     
                addEvent.css = 'callplan';
                                                        
                eventList.wholelist.add(addEvent);
                
            }*/

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