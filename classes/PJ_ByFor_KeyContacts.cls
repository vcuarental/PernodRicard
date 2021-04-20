public with sharing class PJ_ByFor_KeyContacts {
	private final PJ_ByFor_Administration__c Brochure;

	/*	
	public List<FeedItem> getPosts()
	{
		return [Select Body,CreatedDate From FeedItem where ParentId='0F92600000005VO' and Type ='TextPost' order by CreatedDate desc LIMIT 10];
	}
	
	public List<FeedItem> getDocuments()
	{
		return [select Title, RelatedRecordId,Body from FeedItem where ParentId='0F92600000005Se' and Type ='ContentPost' order by CreatedDate desc];
	}	
	*/
    
    
	public List<documentClass> getBrochure()
    {                  
        List<documentClass> docs = new List<documentClass>(); 
                 
        Map<Id,PJ_ByFor_Administration__c> adms = new Map<Id,PJ_ByFor_Administration__c>([select Id, Name, PJ_ByFor_Title__c,PJ_ByFor_Media__c, CreatedDate from PJ_ByFor_Administration__c where recordType.DeveloperName='PJ_ByFor_Brochure']);
        for(Attachment a:[select Id, Name, Body, ContentType, ParentId  from Attachment where parentId IN :adms.KeySet()])
        {
        	docs.add(new documentClass(adms.get(a.ParentId).PJ_ByFor_Title__c,a));
        }
        
        return docs;
        
    }	
	
	
	class documentClass{
		public String title{get;set;}
		public Attachment doc{get;set;}
		public documentClass(String title, Attachment doc)
		{
			this.title = title;
			this.doc = doc;
		}
	}
	
   
}