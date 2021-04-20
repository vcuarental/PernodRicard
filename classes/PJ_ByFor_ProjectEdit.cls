public with sharing class PJ_ByFor_ProjectEdit {
    private final PJ_ByFor_Experience__c experience;
    public String experienceDate{get;set;}
    public String birthDate{get;set;}
    public String deliveryDate{get;set;}
    
    public String invoiceDate{get;set;}
    public String shippingDate{get;set;}
    public String dispatchDate{get;set;}
    //public String receptionDate{get;set;}
    public String effectivereceptionDate{get;set;}    
    public String arrivaltimeDate{get;set;} 
    public String departuretimeDate{get;set;}                         
    private PJ_ByFor_Client__c client;
    public String SelectedWine{get;set;}
    private Map<String,String> winesMap;
    public Integer stepNumber{get;set;}
    public String selectedCountry{get;set;}
    public String companyName{get; set;}
    public Id xpDateFromCalendar{get; set;}
    private DateTime xpDateTimeFromCalendar;
    public transient Blob blobValue { get; set; }
	public transient String contentType { get; set; }
	public transient String filename { get; set; }
	private Event theEventBooked{get;set;}
	 public ObjectPermissions userPermissionXp{get;set;}
     public String selectedShippingCountry{get;set;}
     public String selectedBillingCountry{get;set;}
	//public Attachment attachment {get;set;}


    
        
        
        
    public PJ_ByFor_ProjectEdit(ApexPages.StandardController stdController)
    {
        if(!Test.isRunningTest()){
            
    		stdController.addFields(new List<String>{'OwnerID','PJ_ByFor_Shipping_Country__c','PJ_ByFor_Billing_Country__c','Owner.Email','PJ_ByFor_Step_Number__c','Name','PJ_ByFor_Experience_Owner_Email__c','PJ_ByFor_Client__c','PJ_ByFor_Wishedexperiencedate__c','PJ_ByFor_Preference__c','PJ_ByFor_Estimated_timing_delivery__c','PJ_ByFor_InvoiceSendDate__c','PJ_ByFor_Shipping_date__c','PJ_ByFor_Dispatch_date__c','PJ_ByFor_Client_reception_date__c','PJ_ByFor_Effectiveclientreception__c','PJ_ByFor_Arrival_time__c','PJ_ByFor_Arrival_time__c','PJ_ByFor_Departure_time__c','PJ_ByFor_Departure_time__c','PJ_ByFor_Countries__c','PJ_ByFor_Subsidiary__c','PJ_ByFor_Copy_Billing_Address__c'});
      	}else{
            System.debug('Running test !');
                    
    	}
    	
        this.experience = (PJ_ByFor_Experience__c)stdController.getRecord();
              
        if(experience.Id == null)
  			experience.RecordTypeId = System.label.PJ_ByFor_Experience_Open_RecordTypeId;
        
        System.debug('this.experience:'+this.experience);
        
        experienceDate = '';
        birthDate = '';
        
        String contactId = ApexPages.currentPage().getParameters().get('cId');
        if(contactId != null)
        {
        	experience.PJ_ByFor_Client__c = contactId;
        }
        
        xpDateFromCalendar = ApexPages.currentPage().getParameters().get('xpDate');
        if(xpDateFromCalendar != null)
        {
        	System.Debug('### ok calendar');
        	theEventBooked = [select Id,StartDateTime,PJ_ByFor_Country__c,PJ_ByFor_Place_of_the_experience__c from Event where Id=:xpDateFromCalendar];
        	experience.PJ_ByFor_Wishedexperiencedate__c = theEventBooked.StartDateTime.date();
        	experience.PJ_ByFor_Countries__c = theEventBooked.PJ_ByFor_Country__c;
			experience.PJ_ByFor_PlaceoftheExperience__c = theEventBooked.PJ_ByFor_Place_of_the_experience__c;
        }
        
        Id owID = null;
        System.debug('_____ Experience: ' + experience);
        if(experience.Id == null) {
        	experience.ownerId = userInfo.getUserid();
        	owID = userInfo.getUserid();
        	stepNumber = 11;
        }else{
        	owID = experience.OwnerId;
        	stepNumber = Integer.valueOf(experience.PJ_ByFor_Step_Number__c);
        }
        
        
        List<User> userList = [Select Id, CompanyName from User where Id =: owID];
        
        if (userList != null && userList.size() > 0){
        	User u = userList.get(0);
	        companyName = u.CompanyName;
	    }  
	    

		client = [select id, Name,PJ_ByFor_First_name__c from PJ_ByFor_Client__c where Id=:experience.PJ_ByFor_Client__c];
        
        if(experience.Name == null) {
        	experience.Name = client.Name + ' '  + client.PJ_ByFor_First_name__c + ' ' + '-'+ ' ' + CompanyName;
        	
        }	    
	    
          
        /*userPermissionXp = [SELECT Id, SObjectType, PermissionsRead, permissionsCreate, permissionsEdit,Parent.label, Parent.IsOwnedByProfile
							FROM ObjectPermissions
							WHERE (ParentId
							IN (SELECT PermissionSetId
							FROM PermissionSetAssignment
							WHERE Assignee.Id =:UserInfo.getUserId()))
							AND
							(SobjectType = 'PJ_ByFor_Experience__c')];*/
							
							
							
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
        
          
             
    }
    
    public void init()
    {

        if(experience.PJ_ByFor_Billing_Country__c != null)
            selectedBillingCountry = experience.PJ_ByFor_Billing_Country__c;
        else
            selectedBillingCountry = '';

        if(experience.PJ_ByFor_Shipping_Country__c != null)
            selectedShippingCountry = experience.PJ_ByFor_Shipping_Country__c;
        else
            selectedShippingCountry = '';

    	if(experience.PJ_ByFor_Wishedexperiencedate__c != null)
    	{
    		List<String> expDate = String.valueOf(experience.PJ_ByFor_Wishedexperiencedate__c).split('-');
    		experienceDate = expDate[2] + '/' + expDate[1] + '/' + expDate[0];
    	}
    	
  	  	client = [select id, PJ_ByFor_Client_Date_of_birth__c from PJ_ByFor_Client__c where Id=:experience.PJ_ByFor_Client__c];
    	System.debug('--- + ' + client.PJ_ByFor_Client_Date_of_birth__c);
    	if(client.PJ_ByFor_Client_Date_of_birth__c != null)
    	{
    		List<String> expDate = String.valueOf(client.PJ_ByFor_Client_Date_of_birth__c).split('-');
    		System.debug('-_-_-_-_-_-_-_- + ' + client.PJ_ByFor_Client_Date_of_birth__c);
            birthDate = expDate[2] + '/' + expDate[1] + '/' + expDate[0];
    	}
    	
    	if(experience.PJ_ByFor_Preference__c != null)
    		selectedWine = experience.PJ_ByFor_Preference__c;
    		
    		
    	if(experience.PJ_ByFor_Estimated_timing_delivery__c != null)
    	{
    		List<String> expDate = String.valueOf(experience.PJ_ByFor_Estimated_timing_delivery__c).split('-');
    		deliveryDate = expDate[2] + '/' + expDate[1] + '/' + expDate[0];
    	}
        
        if(experience.PJ_ByFor_Arrival_time__c != null)
    	{
    		List<String> expDate = String.valueOf(experience.PJ_ByFor_Arrival_time__c).split('-');
    		arrivaltimeDate = expDate[2] + '/' + expDate[1] + '/' + expDate[0];
    	}
        
        if(experience.PJ_ByFor_Departure_time__c != null)
    	{
    		List<String> expDate = String.valueOf(experience.PJ_ByFor_Departure_time__c).split('-');
    		departuretimeDate = expDate[2] + '/' + expDate[1] + '/' + expDate[0];
    	}
    		


    	if(experience.PJ_ByFor_InvoiceSendDate__c != null)
    	{
    		List<String> expDate = String.valueOf(experience.PJ_ByFor_InvoiceSendDate__c).split('-');
    		invoiceDate = expDate[2] + '/' + expDate[1] + '/' + expDate[0];
    	}




    	if(experience.PJ_ByFor_Shipping_date__c != null)
    	{
    		List<String> expDate = String.valueOf(experience.PJ_ByFor_Shipping_date__c).split('-');
    		shippingDate = expDate[2] + '/' + expDate[1] + '/' + expDate[0];
    	}





    	if(experience.PJ_ByFor_Dispatch_date__c != null)
    	{
    		List<String> expDate = String.valueOf(experience.PJ_ByFor_Dispatch_date__c).split('-');
    		dispatchDate = expDate[2] + '/' + expDate[1] + '/' + expDate[0];
    	}



    	/*if(experience.PJ_ByFor_Client_reception_date__c != null)
    	{
    		List<String> expDate = String.valueOf(experience.PJ_ByFor_Client_reception_date__c).split('-');
    		receptionDate = expDate[2] + '/' + expDate[1] + '/' + expDate[0];
    	}
*/


    	if(experience.PJ_ByFor_Effectiveclientreception__c != null)
    	{
    		List<String> expDate = String.valueOf(experience.PJ_ByFor_Effectiveclientreception__c).split('-');
    		effectivereceptionDate = expDate[2] + '/' + expDate[1] + '/' + expDate[0];
    	}




    		    	if(experience.PJ_ByFor_Arrival_time__c != null)
    	{
    		List<String> expDate = String.valueOf(experience.PJ_ByFor_Arrival_time__c).split('-');
    		arrivaltimeDate = expDate[2] + '/' + expDate[1] + '/' + expDate[0];
    	}



 
     		    if(experience.PJ_ByFor_Departure_time__c != null)
    	{
    		List<String> expDate = String.valueOf(experience.PJ_ByFor_Departure_time__c).split('-');
    		departuretimeDate = expDate[2] + '/' + expDate[1] + '/' + expDate[0];
    	} 	
    		
    }
    
    
    

    
    
    
    // Get the Estimate file 
    public ID getEstimate(){ 
			
			ID myFileId = [select id, Name, Folder.id, Folder.Name from Document where Folder.Developername='PJ_ByFor_Template' and Developername='PJ_ByFor_Conditions_Generales_de_Vente' limit 1].id;
			//System.Debug('Id myFileId' + myFileId);	
		
			return myFileId;
    }
    
    
   public ID getEstimateTemplate()
    {     
        String expId = experience.Id;
        
        System.Debug('really call the function');
		List<Attachment> att = new  List<Attachment>(); 

		
		att  = [select Id, Name, Body, ContentType, ParentId, CreatedDate  from Attachment where ParentId=:expId order by CreatedDate desc limit 1];
		
		
		// If there is attachement
		if (att.size() > 0){
			return  att.get(0).Id;
		
		}
        	
        	
        else 
        	return null;
        
        
		
        
    }	
	
	
    
    // Upload estimate 
    public PageReference upload() {
    	
    	
    	System.Debug('really call the function blabla');
    	
    		String expId = experience.Id;
    	if (filename != null){
	    	
	    	//Créer un attachment lié à l’Experience. Regarder les champs à renseigner.
			
			Attachment attachment = new Attachment();
			
			System.debug('********** experience.Id' + experience.Id); 
			attachment.parentId = expId;
			System.debug('********** attachment.parentId' + attachment.parentId); 
			
			
			
			
			attachment.name = filename;
			attachment.body = blobValue ;
			attachment.ContentType = contentType ;
	        
	        insert attachment;
    	
    	}
		
        
        //return ApexPages.StandardControlle.upload();
        
        
        PageReference pageRef = new PageReference(ApexPages.currentPage().getUrl());
		pageRef.setRedirect(true);
		return pageRef;  // Leave the user on the current page*/
   }
   
   
   
   
   
   
   
   
   
   
    
    public PageReference save()
    {
    	System.debug('##### selectedShippingCountry = ' + selectedShippingCountry);
    	system.debug('**** ' + experienceDate);
    	Date parsedDate;

    	if(experienceDate != '' && experienceDate != null) {
    		parsedDate = Date.parse(String.valueOf(experienceDate));
    		experience.PJ_ByFor_Wishedexperiencedate__c = parsedDate;
    	}
    		
    	/*	
		if(birthDate != '' && birthDate != null)
    	{
    		PJ_ByFor_Client__c friend = new PJ_ByFor_Client__c(Id=experience.PJ_ByFor_Client__c);
    		
    		parsedDate = Date.parse(String.valueOf(birthDate));
			friend.PJ_ByFor_Client_Date_of_birth__c = parsedDate;
			update friend;
    	}
    	*/
    	//if(SelectedWine != null && SelectedWine != '')
    	//	experience.PJ_ByFor_Preference__c = winesMap.get(SelectedWine);
    	
    	
    	if(deliveryDate != '' && deliveryDate != null){
    		parsedDate = Date.parse(String.valueOf(deliveryDate));
    		experience.PJ_ByFor_Estimated_timing_delivery__c = parsedDate;
    	}
       
        

    	if(invoiceDate != '' && invoiceDate != null){
    		parsedDate = Date.parse(String.valueOf(invoiceDate));
    		experience.PJ_ByFor_InvoiceSendDate__c = parsedDate;
    	}
    		
    	    	

    	if(shippingDate != '' && shippingDate != null){
			parsedDate = Date.parse(String.valueOf(shippingDate));
    		experience.PJ_ByFor_Shipping_date__c = parsedDate;
    		
    	}	
    		
     	if(dispatchDate != '' && dispatchDate != null) {
     		parsedDate = Date.parse(String.valueOf(dispatchDate));
    		experience.PJ_ByFor_Dispatch_date__c = parsedDate;   		
     	}

     /*	if(receptionDate != '' && receptionDate != null) {
     		parsedDate = Date.parse(String.valueOf(receptionDate));
    		experience.PJ_ByFor_Client_reception_date__c = parsedDate; 
     	}*/


     	if(effectivereceptionDate != '' && effectivereceptionDate != null){
     		parsedDate = Date.parse(String.valueOf(effectivereceptionDate));
     		experience.PJ_ByFor_Effectiveclientreception__c = parsedDate;
     	}
    		
	
		if(arrivaltimeDate != '' && arrivaltimeDate != null){	
     		parsedDate = Date.parse(String.valueOf(arrivaltimeDate));
     		experience.PJ_ByFor_Arrival_time__c = parsedDate;
     	}
        
        if(departuretimeDate != '' && departuretimeDate != null){
     		parsedDate = Date.parse(String.valueOf(departuretimeDate));
     		experience.PJ_ByFor_Departure_time__c = parsedDate;
     	}


     	/*if(arrivaltimeDate != '' && arrivaltimeDate != null){
     		System.Debug('#### ArrivalTime = ' + arrivaltimeDate);
     		List<String> dateElements = arrivaltimeDate.split('/');
            System.Debug('#### dateElements = ' + dateElements);
     		DateTime theDate = Datetime.newInstance(Integer.valueOf(dateElements[2]),Integer.valueOf(dateElements[1]),Integer.valueOf(dateElements[0]),Integer.valueOf(dateElements[3]),Integer.valueOf(dateElements[4]),0);

            experience.PJ_ByFor_Arrival_time_bis__c = theDate;
     	} else {
     		experience.PJ_ByFor_Arrival_time_bis__c = null;
     	}*/
    	
        /*System.debug('--- : ' + departuretimeDate);
       	if(departuretimeDate != '' && departuretimeDate != null){
      		List<String> dateElements = departuretimeDate.split('/');
     		DateTime theDate = Datetime.newInstance(Integer.valueOf(dateElements[2]),Integer.valueOf(dateElements[1]),Integer.valueOf(dateElements[0]),Integer.valueOf(dateElements[3]),Integer.valueOf(dateElements[4]),0);
    		experience.PJ_ByFor_Departure_time__c = theDate;   		
    		
      	} else {
      		experience.PJ_ByFor_Departure_time__c = null;
      	}*/	
      	
      	
      	
      	if (experience.PJ_ByFor_PlaceoftheExperience__c == 'Epernay') {
      		experience.PJ_ByFor_Countries__c = 'FR';
      	
      	}

        experience.PJ_ByFor_Billing_Country__c = selectedBillingCountry;
      	experience.PJ_ByFor_Shipping_Country__c = selectedShippingCountry;
    	   	
    	try{
    		System.debug('**********' + experience.PJ_ByFor_Countries__c); 
    		if(experience.Id == null){
	    		String contactstatus = [select PJ_ByFor_Status__c from PJ_ByFor_Client__c where id=:experience.PJ_ByFor_Client__c].PJ_ByFor_Status__c;
	    		if(contactstatus == 'Prospect') {
	    			PJ_ByFor_Client__c theFriend = new PJ_ByFor_Client__c(id=experience.PJ_ByFor_Client__c,PJ_ByFor_Status__c='Friend');
	    			
    			update theFriend;
    		}
    		
    		insert experience;
    		
    		
    		if(theEventBooked != null)
    		{
    			System.Debug('OK calendar save');
    			PJ_ByFor_Experience__c xpTmp = [select Owner.Email from PJ_ByFor_Experience__c where Id=:experience.id];
				theEventBooked.whatId=experience.Id;
				theEventBooked.PJ_ByFor_Status__c = 'Pending Validation';
				theEventBooked.PJ_ByFor_Experience_Owner_Email__c = xpTmp.Owner.Email;
				theEventBooked.PJ_ByFor_Experience_Owner__c = experience.ownerId;
	    		update theEventBooked;
    		}
    		
    	}else
			update experience;
			
    	} catch(DMLException e){
    		System.debug('*** ' + e);
    	}

    	
    	PageReference ref = new PageReference('/apex/PJ_ByFor_ProjectDetail?Id='+experience.id);
    	ref.setRedirect(true);
    
    	return ref;
    }



    
    public List<String> getWineList()
    {
    	List<String> wines = new List<String>();
    	winesMap = new Map<String,String>();
    	Schema.DescribeFieldResult fieldResult = PJ_ByFor_Experience__c.PJ_ByFor_Preference__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry f : ple)
        {
            winesMap.put(f.getValue(),f.getLabel());
            wines.add(f.getLabel());
        }
    	return wines;
    }
    /*
    public List<SelectOption> getCountries()
	{
	  List<SelectOption> options = new List<SelectOption>();
	  Schema.DescribeFieldResult fieldResult = PJ_ByFor_Experience__c.PJ_ByFor_Countries__c.getDescribe();
	   List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
	   options.add(new SelectOption('', '--None--'));
	        
	   for( Schema.PicklistEntry f : ple)
	   {
	      options.add(new SelectOption(f.getValue(), f.getLabel()));
	   }       
	   return options;
	}
    */
    public List<SelectOption> getCountries()
    {
      List<SelectOption> options = new List<SelectOption>();
      Schema.DescribeFieldResult fieldResult = PJ_ByFor_Experience__c.PJ_ByFor_Countries__c.getDescribe();
      List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
      options.add(new SelectOption('', ''));

        /*    
       for( Schema.PicklistEntry f : ple)
       {
          options.add(new SelectOption(f.getValue(), f.getLabel()));
       }
       */
       Map<String,String> tmpCountries = new Map<String,String>();
       List<String> countriesSorted = new List<String>();
       for( Schema.PicklistEntry f : ple)
       {
            tmpCountries.put(f.getLabel(),f.getValue());
            countriesSorted.add(f.getLabel());
       }

       countriesSorted.sort();
       for(String c:countriesSorted)
         options.add(new SelectOption(tmpCountries.get(c), c));

       return options;
    }

    public List<optionClass> getCountriesList()
    {
      List<optionClass> options = new List<optionClass>();
      Schema.DescribeFieldResult fieldResult = PJ_ByFor_Experience__c.PJ_ByFor_Countries__c.getDescribe();
      List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
      options.add(new optionClass('', '--None--'));

        /*    
       for( Schema.PicklistEntry f : ple)
       {
          options.add(new SelectOption(f.getValue(), f.getLabel()));
       }
       */
       Map<String,String> tmpCountries = new Map<String,String>();
       List<String> countriesSorted = new List<String>();
       for( Schema.PicklistEntry f : ple)
       {
            tmpCountries.put(f.getLabel(),f.getValue());
            countriesSorted.add(f.getLabel());
       }

       countriesSorted.sort();
       for(String c:countriesSorted)
         options.add(new optionClass(tmpCountries.get(c), c));

       return options;
    }
    
    public List<PJ_ByFor_Experience__History> getExperienceHistory()
    {
        return [select Field, CreatedDate, CreatedBy.FirstName, CreatedBy.LastName, NewValue from PJ_ByFor_Experience__History where ParentId=:experience.Id and Field='PJ_ByFor_Status__c' order by CreatedDate desc];
    }
    
    public Boolean getIsAdmin() 
    {
    	//List<GroupMember> AdminUsers = new List<GroupMember>();
    	String CurrentUserId = userInfo.getUserid();
    	
    	
    	Map<Id, Group> groupMap = new Map<Id, Group>([Select Id, Name From Group Where DeveloperName='PJ_ByFor_System_Administrator']);
    	
    	List<GroupMember> groupMembers = [ Select GroupId, UserOrGroupId From GroupMember Where GroupId In :groupMap.keySet()];
    	
    	Boolean isAdmin = false;
    	
    	//System.Debug('isAdmin value before search ' + isAdmin + ' CurrentUserId' + CurrentUserId );
    	
    	for (GroupMember m : groupMembers) {
    		if (CurrentUserId == m.UserOrGroupId) {
    			isAdmin = true;
    		}
    	}
    	
    	//System.Debug(' isAdmin value after search' + isAdmin);
    	
    	
	    return isAdmin;
	    
    }
	       
    
    
    public class optionClass
    {
        public String value{get;set;}
        public String label{get;set;}
        public optionClass(String value,String label)
        {
            this.value = value;
            this.label = label;
        }
    }

    
        
}