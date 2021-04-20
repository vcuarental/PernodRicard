public class ASI_MFM_KR_POSM_UploadAttachController {
    
    public Set<String>  POSMLineID                                              {set;get;}
    public List<String> POSMLineNames                                           {set;get;}
    public String POSMLineNameID                                                {set;get;}
    public string posmline                                                      {get;set;} 
    public ASI_KOR_POSM_Order_Request__c header                                 {get;set;} 
    public ASI_KOR_POSM_Order_Request__c headerInfo                             {get;set;} 
    public id headerId                                                          {set;get;}
    public Map<string, ASI_KOR_POSM_Order_Detail__c> posmlineMap                {set;get;} {posmlineMap= NEW Map<string, ASI_KOR_POSM_Order_Detail__c>();}
    public Map<string, ASI_KOR_POSM_Order_Detail__c> nameID                     {set;get;} {nameID= NEW Map<string, ASI_KOR_POSM_Order_Detail__c>();}
    public Map<string, Attachment> attachmentMap                                {set;get;} {attachmentMap= NEW Map<string, Attachment>();}
    public Map<String, List<attachments>>  POSMLinesAttchment                   {get;set;} {POSMLinesAttchment= NEW Map<String, List<attachments>>();}
   
    
    public ASI_MFM_KR_POSM_UploadAttachController (ApexPages.StandardController controller) {
        this.header = (ASI_KOR_POSM_Order_Request__c)controller.getRecord();                    //Get POSM Header Id 
        this.headerId = this.header.Id; 
        this.headerInfo = [SELECT Id,Name, ASI_KOR_Status__c FROM ASI_KOR_POSM_Order_Request__c WHERE Id = :headerId];
        this.posmlineMap  = new Map<string, ASI_KOR_POSM_Order_Detail__c>();
        this.nameID  = new Map<string, ASI_KOR_POSM_Order_Detail__c>();
        POSMLineID  = new Set<String>();
	    POSMLineNames = new List<String>(); 
        init();
    }
    
     public class attachments{
        public Attachment relatedFile {set;get;}
        public Id relatedPOLine {set;get;}
        public String relatedPOLineName {set;get;}

    }
    
    public void init(){
        //For POSM Line:
        for(ASI_KOR_POSM_Order_Detail__c posmline : [Select id, Name, ASI_KOR_POSM_Order_Request__R.NAME, ASI_KOR_SubBrand__r.name, ASI_KOR_SubBrand__c,ASI_KOR_POSM_Order_Request__R.ASI_MFM_Sales_Branch__C, ASI_KOR_UnitCost__c,
                                                    ASI_KOR_Item_Name__r.name, ASI_KOR_Quantity__c, ASI_KOR_TotalAmount__c, ASI_KOR_UOM__c, ASI_KOR_Remarks__c
                                                    from ASI_KOR_POSM_Order_Detail__c where ASI_KOR_POSM_Order_Request__c =: headerId  order by Name]){   
            
            String POSMLineNameID = posmline.Name ;   
           
            POSMLineID.add(POSMLineNameID);        //PUT INTO SET  
           
            posmlineMap.put(posmline.id, posmline);
            nameID.put(posmline.NAME, posmline);
           
            
        }
        
        POSMLineNames = new List<String>(POSMLineID);
        POSMLineNameID     = (POSMLineNames !=null && POSMLineNames.size()>0) ? POSMLineNames[0]: '';
        
        //For attachment:
        for(Attachment att : [Select id , Name, CreatedById, Description, LastModifiedDate, CreatedBy.Name, ParentId  from Attachment where ParentId in: posmlineMap.keyset()]){
            
            string posmline = posmlineMap.containsKey(att.ParentId)?   posmlineMap.get(att.ParentId).Name :'';  
            List<attachments> attachmentList = POSMLinesAttchment.get(posmlineMap.get(att.ParentId).Name);
            
            if(attachmentList  == null ) attachmentList = new List<attachments>();
            attachments lineitem = new attachments();      //call inner class
            lineitem.relatedFile = att;
            lineItem.relatedPOLine = att.ParentId;
            lineItem.relatedPOLineName  = posmlineMap.containsKey(att.ParentId)?   posmlineMap.get(att.ParentId).Name :'';
            attachmentList.add(lineItem);
            POSMLinesAttchment.put(posmline,attachmentList );
           //stem.assertEquals(POSMLinesAttchment,null);
            //attachmentMap.put(STRING.valueOf(att.ParentId),att);
        }
        
        
        
        for(String Lines : POSMLineID){
                
            if(!POSMLinesAttchment.containsKey(Lines)){
            List<attachments> attachmentList = new List<attachments>();
            POSMLinesAttchment.put(Lines,attachmentList );
            }
        }
        /*  
            if(!LineNameMap.containsKey(Lines)){
            List<ASI_KOR_POSM_Order_Detail__c> relatedPOLine =  new List<ASI_KOR_POSM_Order_Detail__c>();
            LineNameMap.put(Lines,  relatedPOLine );
            }
        }  */ 
    }
      
    public PageReference deleteAtt(){  
          
          if(headerInfo.ASI_KOR_Status__c == 'Draft'){
              Map<String, String> params = ApexPages.currentPage().getParameters();      
              String param_Id = params.get('PARAM_Line_ID');   
              
           
              List<Attachment> att = [select id from attachment where id = :param_Id];  
                  if(att.size() > 0){
                     delete att;     
                  }
                  else
                  {
                      PageReference pageRef = new PageReference(ApexPages.currentPage().getUrl());
              pageRef.setRedirect(true);
              return pageRef;
                  }
              
              //Refresh Current Page
              PageReference pageRef = new PageReference(ApexPages.currentPage().getUrl());
              pageRef.setRedirect(true);
              return pageRef;
              }
              
          else{
             // apexpages.addMessage(new apexpages.Message(apexpages.severity.error, 'Cannot delete attachment because status is not Draft.'));
              return null;
          }
          
    }
}