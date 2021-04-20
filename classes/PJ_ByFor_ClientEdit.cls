public with sharing class PJ_ByFor_ClientEdit {
	private final PJ_ByFor_Client__c client;
    public String contactDate{get;set;}
    //public String image_right{get;set;}
    public String lastsituationupdateDate{get;set;} 
    public String birthDate{get;set;}
    public Id xpDateFromCalendar;
    public String selectedCountry{get;set;}
    



    public PJ_ByFor_ClientEdit(ApexPages.StandardController stdController)
    {
        if(!Test.isRunningTest()){
            System.debug('Not running test !');
    		stdController.addFields(new List<String>{'Id','PJ_ByFor_Country_residence__c','Name','PJ_ByFor_First_Contact_Date__c', 'PJ_ByFor_Image_Right__c','PJ_ByFor_Latest_Situation_Update_Date__c','PJ_ByFor_Latest_Situation_Update__c','PJ_ByFor_Client_Date_of_birth__c','PJ_ByFor_Latest_Situation_Update_Date__c'});
        }else{
            System.debug('Running test !');
        }
        
        this.client = (PJ_ByFor_Client__c)stdController.getRecord();
        
  		if(client.Id == null)
  			client.RecordTypeId = System.label.PJ_ByFor_Client_Prospect_RecordTypeId;
        
        if(client.PJ_ByFor_First_Contact_Date__c == null)
             client.PJ_ByFor_First_Contact_Date__c = Date.today();

        
        
        if(client.PJ_ByFor_Latest_Situation_Update_Date__c == null)
             client.PJ_ByFor_Latest_Situation_Update_Date__c = Date.today();


		contactDate = '';
        lastsituationupdateDate = '';       
        
        
        
        if(client.PJ_ByFor_First_Contact_Date__c != null)
    	{
    		List<String> contDate = String.valueOf(client.PJ_ByFor_First_Contact_Date__c).split('-');
    		contactDate = contDate[2] + '/' + contDate[1] + '/' + contDate[0];
    		
    		System.Debug('##### Client Edit init()' + contactDate);
    	}
    	
        if(client.PJ_ByFor_Latest_Situation_Update_Date__c != null)
    	{
    		List<String> contDate = String.valueOf(client.PJ_ByFor_Latest_Situation_Update_Date__c).split('-');
    		lastsituationupdateDate = contDate[2] + '/' + contDate[1] + '/' + contDate[0];
    		
    		
    	}    	


        if(client.PJ_ByFor_Client_Date_of_birth__c != null)
    	{
    		List<String> contDate = String.valueOf(client.PJ_ByFor_Client_Date_of_birth__c).split('-');
    		birthDate = contDate[2] + '/' + contDate[1] + '/' + contDate[0];
    	}    	
 	
        
        if(client.Id == null)
             client.ownerId = userInfo.getUserid();
             
             
        if(client.PJ_ByFor_Status__c == null)   	
    		client.PJ_ByFor_Status__c='Prospect';            
             
       xpDateFromCalendar = ApexPages.currentPage().getParameters().get('xpDate');     

       System.debug('##### country = ' + client.PJ_ByFor_Country_residence__c);
       if(client.PJ_ByFor_Country_residence__c != null)
            selectedCountry = client.PJ_ByFor_Country_residence__c;
        else
            selectedCountry = '';
             
    }
    
        

    // Default init method
    public void init()
    {
    	System.Debug('##### init()' + client.PJ_ByFor_First_Contact_Date__c);
    	

      

    	if(client.PJ_ByFor_First_Contact_Date__c != null)
    	{
    		List<String> contDate = String.valueOf(client.PJ_ByFor_First_Contact_Date__c).split('-');
    		contactDate = contDate[2] + '/' + contDate[1] + '/' + contDate[0];
    		
    		System.Debug('##### Client Edit init()' + contactDate);
    	}
    	

    	if(client.PJ_ByFor_Latest_Situation_Update_Date__c != null)
    	{
    		List<String> contDate = String.valueOf(client.PJ_ByFor_Latest_Situation_Update_Date__c).split('-');
    		lastsituationupdateDate = contDate[2] + '/' + contDate[1] + '/' + contDate[0];
    		
    		
    	}


    	if(client.PJ_ByFor_Client_Date_of_birth__c != null)
    	{
    		List<String> contDate = String.valueOf(client.PJ_ByFor_Client_Date_of_birth__c).split('-');
    		birthDate = contDate[2] + '/' + contDate[1] + '/' + contDate[0];
    	}
    }
    
    

    public List<SelectOption> getCountries()
    {
      List<SelectOption> options = new List<SelectOption>();
      Schema.DescribeFieldResult fieldResult = PJ_ByFor_Experience__c.PJ_ByFor_Countries__c.getDescribe();
      List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
      options.add(new SelectOption('', '--None--'));
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
    
    //contactDate datePickfirstcontact
	// Clients set methods (load all the clients and the related  fields)  
    
       
   public PageReference save()
   {
   		System.Debug('##### saveclients');
        System.debug('##### new country ='+ selectedCountry);
        client.PJ_ByFor_Country_residence__c = selectedCountry;

        try {	
        		System.Debug('##### clientGet');
        		// the specific format wanted (31/5/2013)
			    if(contactDate != null && contactDate != '') {
			    		//Date parsedDate = Date.parse('31/5/2013');
			    		Date parsedDate = Date.parse(String.valueOf(contactDate));
			    		
			    		client.PJ_ByFor_First_Contact_Date__c = parsedDate;
			    		//
			    		//List<String> contDate = String.valueOf(client.PJ_ByFor_First_Contact_Date__c).split('-');
			    		//contactDate = contDate[2] + '/' + contDate[1] + '/' + contDate[0];
			    }
			    


			    if(lastsituationupdateDate != null && lastsituationupdateDate != '') {
			    		
			    		Date parsedDate = Date.parse(String.valueOf(lastsituationupdateDate));
			    		
			    		client.PJ_ByFor_Latest_Situation_Update_Date__c = parsedDate;
			    		
			    }


			    if(birthDate != null && birthDate != '') {
			    		
			    		Date parsedDate = Date.parse(String.valueOf(birthDate));
			    		
			    		client.PJ_ByFor_Client_Date_of_birth__c = parsedDate;
			    		System.Debug('date of birth' + birthDate);
			    		
			    }
			    

	
				System.Debug('##### upsert');
		    	upsert client;
    			
				if(xpDateFromCalendar != null)
				{
					PageReference ref = new PageReference('/apex/PJ_ByFor_ProjectEdit?cId='+ client.Id + '&xpDate=' + xpDateFromCalendar);
		    		ref.setRedirect(true);
		    		return ref;
				} else {
					PageReference ref = new PageReference('/apex/PJ_ByFor_ClientDetail?Id='+client.id);
		    		ref.setRedirect(true);
		    		return ref;
				}
    
			} catch (Exception ex) {
			    System.debug('A DML exception has occurred: ' +
			                ex.getMessage());
			    ApexPages.addMessages(ex);
			    
			    return null;
			}
   		
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