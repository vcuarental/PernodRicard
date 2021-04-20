public with sharing class PJ_ByFor_Projects {
	public String showParam{get;set;}
	public Integer thePageParam{get;set;}
	public String experienceNameParam{get;set;}
	public String selectedCountry{get;set;}
	
	
	
	// Controller code goes here
    private String sortOrder = 'CreatedDate';
    private Boolean isAsc = false;
    
    
    
    
	public void init()
	{
		System.Debug('##### init() : ' + 'showParam =' + showParam + 'experienceNameParam =' +  experienceNameParam);
		showParam = '10';  
		experienceNameParam = '';  
	}
	
	public pageReference doSearch()
	{
		System.Debug('##### DoSearch : ' + experienceNameParam);
		
		if(experienceNameParam == '' || experienceNameParam == null) {
			experienceNameParam = 'All';
		}
			
			
		projectsSet = null;
		return null;
	}
	 
	public ApexPages.StandardSetController projectsSet {
        get {
            if(projectsSet == null || experienceNameParam != '') {
            	System.Debug('##### projectSet');
                String queryString = 'select Id, Name, PJ_ByFor_Countries__c, PJ_ByFor_Status__c, CreatedDate, PJ_ByFor_Wishedexperiencedate__c, PJ_ByFor_PlaceoftheExperience__c from PJ_ByFor_Experience__c';
                
                if(experienceNameParam != '' && experienceNameParam != 'All')
                {
                	System.Debug('##### experienceNameParam');
                	queryString += ' where Name like \'%' + experienceNameParam + '%\'';
                	System.Debug('projectsSet.setPageSize(Integer.valueOf(showParam));' + showParam);
            	}
            	
            	 if(selectedCountry != '' && selectedCountry != null)
                {
                	if(selectedCountry=='Epernay')
                		queryString += ' where PJ_ByFor_PlaceoftheExperience__c  = \'' + selectedCountry + '\'';
                	else
                	queryString += ' where PJ_ByFor_Countries__c  = \'' + selectedCountry + '\'';
            	}
            	

				if (isAsc) {
            		queryString += ' order by ' + sortOrder + ' asc ';
            	
            	}
            	
            	else {
            		queryString += ' order by ' + sortOrder + ' desc ';
            	}
            	
            	
                projectsSet = new ApexPages.StandardSetController(Database.getQueryLocator(queryString));
                
                
                // sets the number of records in each page set
                if(showParam != '' && showParam != null) {
                	projectsSet.setPageSize(Integer.valueOf(showParam));
                	System.Debug('projectsSet.setPageSize(Integer.valueOf(showParam));' + showParam);
                }
                experienceNameParam = '';
            }
            System.Debug('##### projectSet 2' + showParam);
            return projectsSet;
        }
        set;
    }



	public pageReference sortByExperiences() {
    	this.sortOrder = 'Name';
    	this.isAsc = !this.isAsc;
    	
    	projectsSet = null;
		return null;
    }
    
    
        public pageReference sortByPlace() {
    	this.sortOrder = 'PJ_ByFor_Countries__c';
    	this.isAsc = !this.isAsc;
    	
    	projectsSet = null;
		return null;
    }
    
    
    
        public pageReference sortByStatus() {
    	this.sortOrder = 'PJ_ByFor_Status__c';
    	this.isAsc = !this.isAsc;
    	
    	projectsSet = null;
		return null;
    }
    
    
    
        public pageReference sortByCreationdate() {
    	this.sortOrder = 'CreatedDate';
    	this.isAsc = !this.isAsc;
    	
    	projectsSet = null;
		return null;
    }
    
    
    
        public pageReference sortByDeadline() {
    	this.sortOrder = 'PJ_ByFor_Wishedexperiencedate__c';
    	this.isAsc = !this.isAsc;
    	
    	projectsSet = null;
		return null;
    }
    
    
    public List<PJ_ByFor_Experience__c> getProjects()
    {
        return (List<PJ_ByFor_Experience__c>)projectsSet.getRecords();
    }
    
    
    

    public Boolean hasNext {
        get {
            return projectsSet.getHasNext();
        }
        set;
    }

    // indicates whether there are more records before the current page set.
    public Boolean hasPrevious {
        get {
            return projectsSet.getHasPrevious();
        }
        set;
    }




    // returns the page number of the current page set
    public Integer pageNumber {
        get {
            return projectsSet.getPageNumber();
        }
        set;
    }

/*
    // returns the first page of records
     public void first() {
         projectsSet.first();
     }

     // returns the last page of records
     public void last() {
         projectsSet.last();
     }

*/
     // returns the previous page of records
     public void previous() {
         projectsSet.previous();
     }

     // returns the next page of records
     public void next() {
         projectsSet.next();
     }

     public Integer getSize() {
         return projectsSet.getResultSize();
     }

     public List<Integer> getPaginateNav()
     {
        List<Integer> pageList = new List<Integer>();
        Integer pageloop = 0;
        Double resultSize = projectsSet.getResultSize();
        Double pageSize = projectsSet.getPageSize();
        Double nbPages = resultSize / pageSize;
        if(nbPages > nbPages.intValue())
            pageloop = nbPages.intValue() + 1;
        else
            pageloop = nbPages.intValue();

        for(Integer i=0; i<pageloop;i++)
            pageList.add(i+1);

        return pageList;

     }
     
    public List<SelectOption> getCountries()
	{
	  List<SelectOption> options = new List<SelectOption>();
	  Schema.DescribeFieldResult fieldResult = PJ_ByFor_Experience__c.PJ_ByFor_Countries__c.getDescribe();
	  List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
	  options.add(new SelectOption('', '--None--'));
	  options.add(new SelectOption('Epernay', 'Epernay'));
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
     
     

     /*
     public List<SelectOption> getOrderList()
     {
        List<SelectOption> options = new List<SelectOption>();

        options.add(new SelectOption('caseNumber',''));
        options.add(new SelectOption('CreatedDate','Trier par date'));
        options.add(new SelectOption('Num_ro_de_Contrat__c','Trier par contrat'));
        options.add(new SelectOption('Status','Trier par statut'));

        return options;
     }
    */
    public List<SelectOption> getShowList()
    {
        List<SelectOption> showList = new List<SelectOption>();
        showList.add(new SelectOption('10','10'));
        showList.add(new SelectOption('25','25'));
        showList.add(new SelectOption('50','50'));
        showList.add(new SelectOption('','All'));
        
        
        

        return showList;
    }

    public PageReference navigate()
    {
        System.Debug('##### thePageParam=' + thePageParam);
        projectsSet.setpageNumber(thePageParam);
        return null;
    }
    
    /*
    public class picklistClass
    {
        public String pId{get;set;}
        public String pValue{get;set;}
        public picklistClass(String pId, String pValue)
        {
            this.pId = pId;
            this.pValue = pValue;
        }
    }
*/
}