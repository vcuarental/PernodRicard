public without sharing class ASI_CRM_CN_AttachAttachment {
    
    Public String headerID {get; set;}
    Public Map<ID, String> createdBy{get; set;}
    
    Public List<Attachment> getAttachment(){
        if(headerID != NULL && headerID != ''){
            List<Attachment> attachmentList = new List<Attachment>([SELECT Id, Name, ContentType, OwnerID FROM Attachment WHERE ParentId = : headerID ORDER BY CreatedDate DESC]);
            
            Set<String> ownerIdSet= new Set<String>();
            
            for(Attachment obj : attachmentList)
            	ownerIdSet.add(obj.OwnerID);
            
            List<User> userList = new List<User>([SELECT id, Name FROM user WHERE id IN : ownerIdSet]);
            
            if(createdBy == NULL)
            	createdBy = new Map<ID, String>();
            
            if(userList.size() > 0){
                for(user obj : userList)
                    createdBy.put(obj.id, obj.Name);
            }
            
            RETURN attachmentList;
        }
        RETURN NULL;
    }
    
    Public List<Note> getNote(){
        if(headerID != NULL && headerID != ''){
            List<Note> noteList = new List<Note>([SELECT Id, Body, Title, OwnerId FROM Note WHERE IsPrivate = FALSE AND ParentId = : headerID ORDER BY CreatedDate DESC]);

			Set<String> ownerIdSet= new Set<String>();
            
            for(Note obj : noteList)
            	ownerIdSet.add(obj.OwnerId);
            
            List<User> userList = new List<User>([SELECT id, Name FROM user WHERE id IN : ownerIdSet]);
            
            if(createdBy == NULL)
            	createdBy = new Map<ID, String>();
            
            if(userList.size() > 0){
                for(user obj : userList)
                    createdBy.put(obj.id, obj.Name);
            }
            
            RETURN noteList;
        }
        RETURN NULL;
    }
}