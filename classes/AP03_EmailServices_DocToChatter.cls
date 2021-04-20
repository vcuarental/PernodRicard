/**
* Email services are automated processes that use Apex classes
* to process the contents, headers, and attachments of inbound
* email.
*/
/********************************************************************************
*                       
* MIGRACION LICENCIAS 
* AUTHOR: ZIMMIC                     DATE: 07/11/2016
*
********************************************************************************/
global class AP03_EmailServices_DocToChatter implements Messaging.InboundEmailHandler {
    /* Message : User email not known */
    private String buildMsg_UserNotKnown() {
    	String result = '';
    	result += 'We cannot access to your demand. Your email address hasn’t been found in Pernod Ricard Chatter®. Please retry with your corporate email address.\n'; 
		result += '\n';
		result += 'If the same message appears again, please contact: chatter@pernod-ricard.com';		
		return result;
    }
    
    /* Message : No hashtag on the Email subject */
    private String buildMsg_notMember(String groupN, String listUserGroups) {
    	String result = '';
    	result += 'We cannot access to your demand. You’re not a member of the group: ' + groupN + '.\n'; 
    	result += 'Please join or ask to join this group in Pernod Ricard Chatter®.'+'\n'; 
		result += '\n';
    	result += 'For now, you are a member of the following groups: ';    	 
    	result += listUserGroups+'\n';    	
		result += '\n';
		result += 'If the same message appears again, please contact: chatter@pernod-ricard.com';		
		return result;
    }
    
    /* Message : Group Name not found */
    private String buildMsg_GroupNotFound(String groupN, String listUserGroups) {
    	String result = '';
    	result += 'We cannot access to your demand. The group name ' + groupN + ' you indicated has not been found in Pernod Ricard Chatter®.'+'\n'; 
		result += '\n';
    	result += 'Please find below the name(s) of the group(s) you are member of and in which you can post or share a file:';    	 
    	result += listUserGroups+'\n';    	
		result += '\n';
		result += 'If the same message appears again, please contact: chatter@pernod-ricard.com';		
		return result;
    }
    
    /* Message : Success */
    private String buildMsg_Success(String groupN, String postLink) {
    	String result = '';
    	result += 'Your post has been successfully added to the group: ' + groupN +'.\n'; 
		result += '\n';
    	result += 'You can see it in Pernod Ricard Chatter® by following this link: ' + postLink +'\n'; 	
		return result;
    }
    
    /* Message : No hashtag on the Email subject */
    private String buildMsg_needHashtag() {
    	String result = '';
    	result += 'We cannot access to your demand. Indeed, a hashtag in the email subject is needed.'+'\n'; 
    	result += 'Please try again with one of the following hashtags:'+'\n'; 
    	result += '\t'+'#help: to get help about this service (e.g.: #help).'+'\n'; 
    	result += '\t'+'#group: to post your message into specific group (e.g.: #group Competitive Intelligence).'+'\n'; 
    	result += '\t'+'\t'+'Be careful: do not forget to leave a space between “#group” and the group name and do not write anything after.'+'\n';     	
		result += '\n';
		result += 'If the same message appears again, please contact: chatter@pernod-ricard.com';		
		return result;
    }
        
    /* Message : Help Message */
    private String buildMsg_HelpMessage(String listUserGroups) {
    	String result = '';
    	result += 'What does this service allow you to do in Pernod Ricard Chatter®?'+'\n'; 
    	result += '\t'+'To post or share a file in a Chatter® groupyou belong to.'+'\n'; 
    	result += '\n';
    	result += 'How to use it?'+'\n'; 
    	result += '\t'+'Type at the end of your email subject “#group” one space and the “name of the group” (e.g.: #group competitive intelligence).'+'\n'; 
    	result += '\t'+'Write in the email body the content of your post.'+'\n';   
    	result += '\t'+'Attach a file to your email.'+'\n';     	
    	result += '\t'+'Send your email. You will receive an email confirmation.'+'\n';
    	result += '\n';	
    	result += 'Where can you post with this service?'+'\n'; 
    	result += '\t'+'In the groups you belong to. For now, you are a member of the following groups:'; 
    	result += listUserGroups+'\n';	
    	result += '\t'+'If you are not part of a group where you want to post or share a file, please join or ask to join this group in Pernod Ricard Chatter®.'+'\n';     	
    	result += '\n';
    	result += 'How to get support? '+'\n'; 
    	result += '\t'+'Type #help at the end of your email subject to get help about this service (ie: #help)'+'\n';
    	result += '\t'+'Contact: chatter@pernod-ricard.com'+'\n';
		return result;
    }
    
    /* Method which handle the inbound email */
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {
        Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();       
        User currUser = new User();
        FeedItem myFeedItem = new FeedItem();   
        
        // Map between Chatter Group Id and Name 
        Map<String,String> mapGroupID2Name = new Map<String,String>();  
        Map<String,String> mapGroupUserId2Name = new Map<String,String>();  
        
        // List of Chatter groups      
        List<String> listGroupsUserName = new List<String>();
        List<String> listHashtags = new String[]{
            '#help [none] : Get help about using of this service;',
            '#group [group_name] : Post your message into the selected group;' /*,
            '#account [account_name] : Post your message related to the selected account;',
            '#contact [contact_name] : Post your message related to the selected contact;',
            '#opportunity [opportunity_name] : Post your message related to the selected opportunity;',
            '#case [case_number] : Post your message related to the selected case;'*/
        };
        
        // Display of lists 
        String displayAllGroup = '';
        String displayGroupsUser = '';
        String displayHashtags = displayListItems(listHashtags, '\n\t - ');
        
        // Variables : Dest Objects  
        CollaborationGroup destGroup;
        Account destAccount;
        Contact destContact;
        //Case destCase;
        //Opportunity destOpp;
        String destObject;
        String fullRecordURL;
                
        // Variables : Email received  
        String emailBodyPlainText = ''+email.plainTextBody;
        String emailSubjectFULL = ''+email.subject;
        String emailAdressSender = ''+email.fromAddress;
        String currEmailSubject = ''+emailSubjectFULL;

        // Variables : Analyse of Subject  
        String hashtagContent;
        String query;
        String errMessage;
            
        try{                    
            /** Check the presence of a Hashtag in the email subject. if not, return an error email **/
            if(emailSubjectFULL.lastindexof('#') == -1) {  
                result.message = buildMsg_needHashtag();
                result.success = false;                    
                return result;
            }else{              
                /* Save the Email Subject without Hashtag */
                currEmailSubject = emailSubjectFULL.substring(0,emailSubjectFULL.lastindexof('#'));
                    
                /* Get all Chatter group and save into the map */
                mapGroupID2Name = getMapGroupIDtoName('CollaborationGroup','',null);
                displayAllGroup = displayListItems(mapGroupID2Name.values(), '\n\t\t#group ');
                
                /* Find user who sent the email. If the email address is unknown, an error message is sended. */
                List<User> listUsers = [SELECT Id FROM User WHERE Email = :emailAdressSender and isActive = true];
                if(listUsers.size() == 0){
                    result.message = buildMsg_UserNotKnown();
                    result.success = false;                    
                    return result;
                }
                
                /* Save details about the current User */
                currUser = listUsers[0];        
                mapGroupUserId2Name = getMapGroupIDtoName('CollaborationGroupMember', currUser.Id, mapGroupID2Name);
                //listGroupsUserName = mapGroupUserId2Name.values();
                displayGroupsUser = displayListItems(mapGroupUserId2Name.values(), '\n\t\t#group ');   
                                    
                
                /* create a Post related to Help */
                if (emailSubjectFULL.lastindexof('#help') != -1) { 
                    result.message = buildMsg_HelpMessage(displayGroupsUser);
                    result.success = true;                    
                    return result;
                } 
                
                /* create a Post related to a Group */      
                if (emailSubjectFULL.lastindexof('#group') != -1) { 
                    hashtagContent = getHashtagContent('#group', emailSubjectFULL);
                    query = 'select Id, Name from CollaborationGroup where name = \'' + hashtagContent + '\' limit 1'; 
                    
                    destGroup = new CollaborationGroup();
                    try {
                        destGroup = Database.query(query);
                        
                        /* Check if the user is a member of the group */
                        if(mapGroupUserId2Name.containsKey(destGroup.Id)){
                            /* Define values of the future post */
                            myFeedItem.ParentId = destGroup.Id;
                            myFeedItem.createdById = currUser.id;
                            myFeedItem.Type = 'TextPost';
                            destObject = 'Group';                           
                        } else {
                            result.message = buildMsg_notMember(destGroup.Name, displayGroupsUser);
                            result.success = false;                 
                            return result;
                        }                       
                    } catch (Exception e) {
                        result.message = buildMsg_GroupNotFound(hashtagContent, displayGroupsUser);
                        result.success = false;              
                        return result;
                    } 
                }    
                            
                /* Add new documents in Content Post with email attachments. */
                Integer compt = 0;
                if(email.BinaryAttachments != null || email.TextAttachments != null) {// Attachment
	                if(email.BinaryAttachments != null) { // Binary Attachments
	                    for (integer i = 0 ; i < email.BinaryAttachments.size() ; i++) {
	                        if(!email.BinaryAttachments[i].filename.startsWith('image') && !email.BinaryAttachments[i].filename.startsWith('Attachment') && !email.BinaryAttachments[i].filename.startsWith('ATT000')){
	                            if(compt == 0){
	                                myFeedItem.Type = 'ContentPost';
	                                myFeedItem.ContentFileName = email.BinaryAttachments[i].filename;
	                                myFeedItem.ContentData = email.BinaryAttachments[i].body;
	                                myFeedItem.body = currEmailSubject;
	                                
	                                if (emailBodyPlainText.length() > 1000) {
	                                    myFeedItem.ContentDescription = emailBodyPlainText.substring (0,1000);
	                                } else {
	                                    myFeedItem.ContentDescription = emailBodyPlainText;
	                                }
	                                insert myFeedItem;
	                                fullRecordURL = URL.getSalesforceBaseUrl().toExternalForm() + '/' + myFeedItem.Id;
	                                compt ++;
	                            }else{                      
	                                ContentVersion newContent = new ContentVersion();         
	                                newContent.PathOnClient = email.BinaryAttachments[i].filename;          
	                                newContent.VersionData = email.BinaryAttachments[i].body;
	                                newContent.Title = email.BinaryAttachments[i].filename;
	                                newContent.Origin = 'H';
	                                insert newContent;
	                                
	                                FeedComment newComm = new FeedComment();
	                                newComm.FeedItemId = myFeedItem.Id;
	                                newComm.RelatedRecordId = newContent.Id;
	                                newComm.CommentBody = '';
	                                newComm.CreatedById = currUser.Id;
	                                insert newComm;
	                            }
	                        }  
	                    } 
	                } 
	                if(email.TextAttachments != null) { // Text Attachments
	                    for (integer i = 0 ; i < email.TextAttachments.size() ; i++) {
	                        if(!email.TextAttachments[i].filename.startsWith('image') && !email.TextAttachments[i].filename.startsWith('Attachment')){
	                            if(compt == 0){
	                                myFeedItem.Type = 'ContentPost';
	                                myFeedItem.ContentFileName = email.TextAttachments[i].filename;
	                                myFeedItem.ContentData = Blob.valueof(email.TextAttachments[i].body);
	                                myFeedItem.body = currEmailSubject;
	                                
	                                if (emailBodyPlainText.length() > 1000) {
	                                    myFeedItem.ContentDescription = emailBodyPlainText.substring (0,1000);
	                                } else {
	                                    myFeedItem.ContentDescription = emailBodyPlainText;
	                                }
	                                insert myFeedItem;
	                                fullRecordURL = URL.getSalesforceBaseUrl().toExternalForm() + '/' + myFeedItem.Id;
	                                compt ++;
	                            }else{                      
	                                ContentVersion newContent = new ContentVersion();         
	                                newContent.PathOnClient = email.TextAttachments[i].filename;            
	                                newContent.VersionData = Blob.valueof(email.TextAttachments[i].body);
	                                newContent.Title = email.TextAttachments[i].filename;
	                                newContent.Origin = 'H';
	                                insert newContent;
	                                
	                                FeedComment newComm = new FeedComment();
	                                newComm.FeedItemId = myFeedItem.Id;
	                                newComm.RelatedRecordId = newContent.Id;
	                                newComm.CommentBody = '';
	                                newComm.CreatedById = currUser.Id;
	                                insert newComm;
	                            }
	                        }
	                    }
	                }  
                } else {    // No Attachment : The email subject and body are inserted as a post into the group
                    myFeedItem.Type = 'TextPost';
                    String feedBody;
                    if(emailBodyPlainText == null || emailBodyPlainText == 'null') {
                        feedBody = currEmailSubject;
                    }else{
                        feedBody = currEmailSubject +'\n\n'+emailBodyPlainText;
                    }
                        
                    if (feedBody.length() > 1000) {
                        myFeedItem.body = feedBody.substring (0,1000);
                    } else {
                        myFeedItem.body = feedBody;
                    }
                    insert myFeedItem;
                    // Build the URL linking to the new post
                    fullRecordURL = URL.getSalesforceBaseUrl().toExternalForm() + '/' + myFeedItem.Id;
                }
            }
            
            /* There is no error : return a success message. */
           	result.message='Your post has been successfully added to the '+ destObject + ': ' + hashtagContent + '.';
            if(fullRecordURL != null)
                result.message = buildMsg_Success(destGroup.Name, fullRecordURL);
            else
           		result.message = 'Your post has been successfully added to the '+ destObject + ': ' + destGroup.Name + '.';
            
            result.success = true;                    
            return result;    
        } catch (Exception e) { // Catch all unhandled errors, like storage_limit.
            result.message='Sorry, your post could not be set. Please contact your administrator.\nError Message : '+e.getTypeName()+ ', ' + e.getMessage() + ', ' + e.getCause();
            result.success = true;
            return result;
        }
    }
    
    /* Extract the hashtag content from the email subject and the hashtag used. */
    public String getHashtagContent(String hashtag, String emailSubjectFULL){
        // Variables
        Integer hashLength; 
        Integer hashContentLength;
        Integer cursor;
        String hashContent;
        
        // Size of Hashtag 
        hashLength = hashtag.length()+1;
        
        // Position and size of the Hashtag content 
        cursor = emailSubjectFULL.lastindexof(hashtag);
        cursor += hashLength;
        hashContentLength = emailSubjectFULL.length();
        
        // Get Hashtag Content then return it 
        hashContent = emailSubjectFULL.substring(cursor,hashContentLength);
        hashContent = hashContent.trim();
        return hashContent;
    }
      
    /* Create a map between a group ID and a group name for all the groups queried */  
    public Map<String,String> getMapGroupIDtoName(String queryObject, String queryOptions, Map<String,String> mapGroupFULL){
        Map<String,String> newMap = new Map<String,String>();
        
        if(queryObject == 'CollaborationGroupMember'){	// groups of the current user
            String query = 'SELECT CollaborationGroupId, MemberId FROM CollaborationGroupMember WHERE MemberId = \'' + queryOptions + '\'';
            List<CollaborationGroupMember> listGroupMembers = Database.query(query);
                    
            for (integer i = 0 ; i < listGroupMembers.size() ; i++) {
                newMap.put(listGroupMembers.get(i).CollaborationGroupId, mapGroupFULL.get(listGroupMembers.get(i).CollaborationGroupId));
            }           
        } else if(queryObject == 'CollaborationGroup'){ // all groups
            String query = 'SELECT Id, Name FROM CollaborationGroup';
            List<CollaborationGroup> listGroups = Database.query(query);    
            
            for (integer i = 0 ; i < listGroups.size() ; i++) {
                newMap.put(listGroups.get(i).Id, listGroups.get(i).Name);
            }           
        }       
        return newMap;
    }
    
    /* Build a string from a list of string and a separator */
    public String displayListItems (List<String> listToDisplay, String separator){      
        String display = '';
        for (integer i = 0 ; i < listToDisplay.size() ; i++) {
            display += separator+listToDisplay.get(i);
        }   
        return display;
    }
}