public with sharing class PJ_ByFor_OfferPresentation {
	private final PJ_ByFor_Administration__c medium;
	private List<PJ_ByFor_Administration__c> medias = new List<PJ_ByFor_Administration__c>();

	public PJ_ByFor_OfferPresentation(ApexPages.StandardController stdController)
    {
    	//stdController.addFields(new List<String>{'Owner.CompanyName'});
        this.medium = (PJ_ByFor_Administration__c)stdController.getRecord();
        medias = [select Id, Name, PJ_ByFor_Title__c, PJ_ByFor_Description__c, PJ_ByFor_URL_video__c, PJ_ByFor_URL_image__c, PJ_ByFor_Media__c, CreatedDate from PJ_ByFor_Administration__c where recordType.DeveloperName!='PJ_ByFor_Brochure'];
    }
    
    

	public List<PJ_ByFor_Administration__c> getmedia()
    {                  
         /*List<mediaClass> media = new List<mediaClass>();
         
         Map<Id,PJ_ByFor_Administration__c> adms = new Map<Id,PJ_ByFor_Administration__c>([select Id, Name, PJ_ByFor_Title__c,PJ_ByFor_Media__c, CreatedDate from PJ_ByFor_Administration__c where recordType.DeveloperName!='PJ_ByFor_Brochure']);
         List<Attachment> att = [select Id, Name, Body, ContentType, ParentId  from Attachment where parentId IN :adms.KeySet()];
         */
                   
        return medias;
        
        
    }
    
    
    /*
    // Document class
    class mediaClass{
    	public PJ_ByFor_Administration__c medium{get;set;}
    	public List<Attachment> doc{get;set;}
    	
		//public String title{get;set;}
		
		
		public mediaClass(PJ_ByFor_Administration__c medium, List<Attachment> doc)
		{
			this.medium = medium;
			this.doc = doc;
		}
	}
	*/
	
	
    
    
    // Request all the related attachements
    public List<Attachment> getAttachments()
    {
    	List<Attachment> attach = new List<Attachment>();
    	
    	
    	
    	System.Debug('##### getAttachments : ');
    	attach = [select Id, Name, Body, ContentType, ParentId  from Attachment where ParentId IN:medias];
    	// where ParentId=:medium.Id order by CreatedDate desc];
    	
    	
    	/*for (Attachment a : attach)
    	System.Debug('##### getAttachments count : ' + a.Name);*/
    	
    	
    	
        return attach;
    }

    
	
	
	
    
/*
 	public String[] getCountries() {
  	 	return countries;
 	}

 	public void setCountries(String[] countries) {
 	 	this.countries = countries;
 	}
 */  
}