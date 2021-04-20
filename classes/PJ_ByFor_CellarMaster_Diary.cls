public with sharing class PJ_ByFor_CellarMaster_Diary {
    public String jsonCalendar{get;set;}
    public Integer thePageParam{get;set;}
    public List<EventClass> events{get;set;}
    public List<PJ_ByFor_Client__c> clients{get;set;}
    public String contactId{get;set;}
    public String choosenContactId{get;set;}
    public String eventIdToSave{get;set;}
    public Event eventPopup{get;set;}
    public String startDateString{get;set;}
    public List<Date> nonClickDays{get;set;}
    public String currentYear{get;set;}
    private Set<Integer> yearsNonClick;
    public String noExp{get;set;}
    public ObjectPermissions userPermissionClient{get;set;}
    public ObjectPermissions userPermissionXp{get;set;}
    public void init()
    {
        /****
        Variable recevant soit une experienceId dans le cas où l'on vient d'une experience
        Soit un id de friends dans le cas où l'on vient d'un contact.
        ****/
        contactId = ApexPages.currentPage().getParameters().get('cId');
        /****
            Si paramètre rempli, on vient d'un contact et il n'y a pas d'expérience existante
        ****/
        noExp = ApexPages.currentPage().getParameters().get('noExp');
        
        if(currentYear == '' || currentYear == null)
            currentYear = String.valueOf(Date.today().year());

        startDateString = '';
        makeJsonCalendar();
        initclients();
        
        userPermissionClient = new ObjectPermissions(PermissionsRead=false,permissionsCreate=false,permissionsEdit=false);
        for(ObjectPermissions p:[SELECT Id, SObjectType, PermissionsRead, permissionsCreate, permissionsEdit,Parent.label, Parent.IsOwnedByProfile
                      FROM ObjectPermissions
                      WHERE (ParentId
                      IN (SELECT PermissionSetId
                      FROM PermissionSetAssignment
                      WHERE Assignee.Id =:UserInfo.getUserId()))
                      AND
                      (SobjectType = 'PJ_ByFor_Client__c')])
        {
            if(p.PermissionsRead)
            
                userPermissionClient.PermissionsRead = true;
            if(p.permissionsCreate)
            
                userPermissionClient.permissionsCreate = true;
                
            if(p.permissionsEdit)
                userPermissionClient.permissionsEdit = true;
        }
    
        userPermissionXp = new ObjectPermissions(PermissionsRead=false,permissionsCreate=false,permissionsEdit=false);
        for(ObjectPermissions p:[SELECT Id, SObjectType, PermissionsRead, permissionsCreate, permissionsEdit,Parent.label, Parent.IsOwnedByProfile
                      FROM ObjectPermissions
                      WHERE (ParentId
                      IN (SELECT PermissionSetId
                      FROM PermissionSetAssignment
                      WHERE Assignee.Id =:UserInfo.getUserId()))
                      AND
                      (SobjectType = 'PJ_ByFor_Experience__c')])
        {
            if(p.PermissionsRead)
            
                userPermissionXp.PermissionsRead = true;
            if(p.permissionsCreate)
            
                userPermissionXp.permissionsCreate = true;
                
            if(p.permissionsEdit)
                userPermissionXp.permissionsEdit = true;
        }


        /*userPermissionClient = [SELECT Id, SObjectType, PermissionsRead, permissionsCreate, permissionsEdit,Parent.label, Parent.IsOwnedByProfile
                  FROM ObjectPermissions
                  WHERE (ParentId
                  IN (SELECT PermissionSetId
                  FROM PermissionSetAssignment
                  WHERE Assignee.Id =:UserInfo.getUserId()))
                  AND
                  (SobjectType = 'PJ_ByFor_Client__c')];
                  
        userPermissionXp = [SELECT Id, SObjectType, PermissionsRead, permissionsCreate, permissionsEdit,Parent.label, Parent.IsOwnedByProfile
                  FROM ObjectPermissions
                  WHERE (ParentId
                  IN (SELECT PermissionSetId
                  FROM PermissionSetAssignment
                  WHERE Assignee.Id =:UserInfo.getUserId()))
                  AND
                  (SobjectType = 'PJ_ByFor_Experience__c')];*/
    }
    
    public void makeJsonCalendar()
    {
        jsonCalendar= '';
        events = new List<EventClass>();
        yearsNonClick = new Set<Integer>();
        //for(Event ev:[select Id, StartDateTime, EndDateTime, PJ_ByFor_Country__c, PJ_ByFor_Place_of_the_experience__c, Subject, whatId, PJ_ByFor_Status__c from Event where OwnerId='02326000000fqer'])
        //  jsonCalendar+= '{Id: \'' + ev.Id + '\', Name:\'' + ev.PJ_ByFor_Status__c + '\',startDate: \'' + ev.StartDateTime.year() + '-' + ((ev.StartDateTime.month().format().length() == 1)? '0' + ev.StartDateTime.month() : '' + ev.StartDateTime.month()) + '-' + ((ev.StartDateTime.day().format().length() == 1)? '0' + ev.StartDateTime.day() : '' + ev.StartDateTime.day())  + '\',endDate: \'' + ev.EndDateTime.year() + '-' + ((ev.EndDateTime.month().format().length() == 1)? '0' + ev.EndDateTime.month() : '' + ev.EndDateTime.month()) + '-' + ((ev.EndDateTime.day().format().length() == 1)? '0' + ev.EndDateTime.day() : '' + ev.EndDateTime.day()) + '\'},';
        
        //jsonCalendar = jsonCalendar.left(jsonCalendar.length() - 1);
        //Event ev = new Event(OwnerId='02326000000fqer', Subject='Test',StartDateTime = System.now(), EndDateTime  = System.now().addHours(2));
        //insert ev;
        Set<Date> datesFree = new Set<Date>();
        for(Event ev:[select Id, StartDateTime, EndDateTime, tolabel(PJ_ByFor_Country__c), PJ_ByFor_Place_of_the_experience__c, Subject, whatId, PJ_ByFor_Status__c from Event where OwnerId=:System.Label.PJ_ByFor_CellarMasterCalendar_Id])
        {
            if(!yearsNonClick.contains(ev.StartDateTIme.year()))
                yearsNonClick.add(ev.StartDateTIme.year());
            events.add(new EventClass(ev.Id,ev.StartDateTime.date(),ev.EndDateTime.date(),ev.Subject,ev.PJ_ByFor_Status__c,ev.PJ_ByFor_Country__c, ev.PJ_ByFor_Place_of_the_experience__c));
            if(ev.PJ_ByFor_Status__c == 'Free')
                datesFree.add(ev.StartDateTime.date());
        }
        
        nonClickableDays(datesFree);
        
    }
    
    private void nonClickableDays(Set<Date> datesFree)
    {
        nonClickDays = new List<Date>();
        for(Integer theYear:yearsNonClick)
            for(Integer theMonth=1; theMonth<=12;theMonth++)
                for(Integer theDay=1;theDay<=Date.daysInMonth(theYear,theMonth);theDay++)
                    if(!datesFree.contains(Date.newInstance(theYear, theMonth, theDay)))
                        nonClickDays.add(Date.newInstance(theYear, theMonth, theDay));
    }

    public PageReference saveEventToSalesforce()
    {
        Date parsedDate = Date.parse(String.valueOf(startDateString));
        DateTime parsedDateTime = Datetime.newInstance(parsedDate.year(), parsedDate.month(), parsedDate.day(), 0, 0, 0);
        DateTime endTime = parsedDateTime + 1;
        System.Debug('________-----_____ parsedDate= ' + parsedDateTime);
        System.Debug('choosenContactId=' + choosenContactId);
        List<Event> evs = [select Id,PJ_ByFor_Country__c,PJ_ByFor_Place_of_the_experience__c from Event where StartDateTime>:parsedDateTime and StartDateTime<:endTime and OwnerId=:System.Label.PJ_ByFor_CellarMasterCalendar_Id and recordTypeId=:System.Label.PJ_ByFor_recordType_Id];
        System.Debug('-_-_-_-_-_-_-_-_-_--_- events size = ' + evs.size());
        if(evs.size() == 1 && contactId != null && contactId != '' && (noExp == null || noExp == ''))
        {
            /*** Cas 1 : On vient d'une experience, le contact est déjà passé en paramètre, la date est choisi sur le calendrie ***/
            PJ_ByFor_Experience__c experience = [select OwnerId, Owner.Email from PJ_ByFor_Experience__c where Id =:contactId];
            System.Debug('## event id = ' + evs[0].Id);
            System.Debug('## contact id = ' + contactId);
            evs[0].whatId=contactId;
            evs[0].PJ_ByFor_Status__c = 'Pending Validation';
            evs[0].PJ_ByFor_Experience_Owner__c = experience.OwnerId;
            evs[0].PJ_ByFor_Experience_Owner_Email__c = experience.Owner.Email;
            update evs[0];
            
            //PJ_ByFor_Experience__c experience = new PJ_ByFor_Experience__c(Id=contactId);
            experience.PJ_ByFor_Wishedexperiencedate__c = parsedDate;
            experience.PJ_ByFor_PlaceoftheExperience__c = evs[0].PJ_ByFor_Place_of_the_experience__c;
            experience.PJ_ByFor_Countries__c = evs[0].PJ_ByFor_Country__c;
            update experience;
            
            PageReference ref = new PageReference('/apex/PJ_ByFor_ProjectDetail?Id='+experience.id);
            ref.setRedirect(true);
            return ref;
        } else if(contactId != null && contactId != '' && noExp != null && noExp != '')
        {
            /*** Cas 2 : On vient d'un contact après avoir cliqué sur New Experience ***/
            PageReference ref;
            if(evs.size() == 1)
                ref = new PageReference('/apex/PJ_ByFor_ProjectEdit?cId='+contactId + '&xpDate=' + evs[0].Id);
            else
                ref = new PageReference('/apex/PJ_ByFor_ProjectEdit?cId='+contactId);
            ref.setRedirect(true);
            return ref;
        } else if(evs.size() == 1 && choosenContactId != '' && choosenContactId != null){
            /*** Cas 3 : On est directement sur le calendrier, on a cliqué sur un event puis sur un contact de la liste ***/
                    
            PageReference ref = new PageReference('/apex/PJ_ByFor_ProjectEdit?cId='+choosenContactId + '&xpDate=' + evs[0].Id);
            ref.setRedirect(true);
            return ref;
        } else if(evs.size() == 1)
        { 
            /*** Cas 4 : On est directement sur le calendrier, on a cliqué sur un event puis le bouton nouveau contact ***/
            PageReference ref = new PageReference('/apex/PJ_ByFor_ClientEdit?xpDate=' + evs[0].Id);
            ref.setRedirect(true);
            return ref;
        } else {
            events = new List<EventClass>();
            makeJsonCalendar();
            return null;
        }
    }
    
    public Integer getEventsListSize()
    {
        return events.size();
    }
    
    class EventClass
    {
        public String theId{get;set;}
        public Date startDate{get;set;}
        public Date EndDate{get;set;}
        public String Subject{get;set;}
        public String Status{get;set;}
        public String Country{get;set;}
        public String place{get;set;}
        public String location{get;set;}
        public EventClass(Id theId,Date startDate, Date EndDate, String Subject, String Status, String Country, String place)
        {
            this.theId = theId;
            this.startDate = startDate;
            this.EndDate = EndDate;
            this.Subject = Subject;
            this.Country = Country;
            this.place = place;
            this.Status = Status;
            
            if(place == 'Epernay')
                location = 'Epernay, France';
            else
                location = country;
        }
    }
    
    // Clients set methods (load all the clients and the related  fields)  
    public void initclients() {
        clients = [select Id, PJ_ByFor_Salutation__c, PJ_ByFor_First_name__c, Name, PJ_ByFor_Status__c, PJ_ByFor_Subsidiary__c,  PJ_ByFor_Latest_Situation_Update__c, PJ_ByFor_Latest_Situation_Update_Date__c, PJ_ByFor_Email__c, CreatedDate from PJ_ByFor_Client__c order by Name asc];
    }
}