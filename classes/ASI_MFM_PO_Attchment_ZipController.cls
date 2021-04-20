public class ASI_MFM_PO_Attchment_ZipController {

    public String zipFileName {get; set;}
    public String zipContent {get; set;}
    public String poName {get; set;}
    public String soName {get; set;}
    public boolean checkAll{get; set;}
    
    public List<Attachment>poFileList , soFileList;
    

    public List<Attachment> getPoFileList() {
        return poFileList ;
    }
    
    public List<Attachment> getSoFileList() {
        return soFileList ;
    }
    
    public void searchRecord() {
        poFileList =null;
        soFileList =null;
        checkAll=false;
        
        if(poName.trim()!=''){
            poName='%'+poName+'%';
            poFileList =[select Id, ParentId, Name, ContentType, BodyLength,LastModifiedDate,CreatedBy.Name from Attachment 
                where parentid in (select id from ASI_OCR_Archived_Document__c where recordtype.developername='ASI_OCR_HK_Archived_Document' and ASI_OCR_PO_Number__c like :poName) 
                 limit 50];
                 
            poName=poName.replace('%','');  
        }
               
        if(soName.trim()!=''){
            soName='%'+soName+'%';         
            soFileList =[select Id, ParentId, Name, ContentType, BodyLength,LastModifiedDate,CreatedBy.Name from Attachment 
            where parentid in (select id from ASI_OCR_Archived_Document__c where recordtype.developername='ASI_OCR_HK_Archived_Document' and ASI_OCR_SO_Number__c like :soName) 
                 limit 50];  
                 
            soName=soName.replace('%','');     
        }       
    }
    
    @RemoteAction
    public static AttachmentWrapper getAttachment(String attId) {
        
        Attachment att = [select Id, Name, ContentType, Body
                          from Attachment
                          where Id = :attId];
        
        AttachmentWrapper attWrapper = new AttachmentWrapper();
        attWrapper.attEncodedBody = EncodingUtil.base64Encode(att.body);
        attWrapper.attName = att.Name;
                          
        return attWrapper;
    }
    
    public class AttachmentWrapper {
        public String attEncodedBody {get; set;}
        public String attName {get; set;}
    }
}