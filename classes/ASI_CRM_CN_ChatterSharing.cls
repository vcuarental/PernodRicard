/*     2014-02-11    Stella Sing        Created
       Goal 1: Add followers & Sharings to newly created record
       Goal 2: Share with @Mention user when create chatter feed
  ********************************* HISTORY ****************************************  
    2014-03-28  Stella Sing     Updated     Change Issue Zone Status, when chatter feed with "Attachment" is inserted.
    2014-04-14  Stella Sing     Updated     Auto add requestor to follower
                                            If Admin add feed to record, status auto change to "Investigatin"
    2014-04-16  Stella Sing     Updated     Close status when Admin user type "Close" or "Closed" in chatter feed
    2014-04-30  Stella Sing     Updated     'Close status change' Extends to Feed Comments.
    2014-06-03    Stella Sing    Updated    Region criteria (Formula Field ASI_CRM_CN_Region__c)
*/

public with sharing class ASI_CRM_CN_ChatterSharing{
    Set <id> IdSharedAdmin = new set <id>(); //According to different recordtype, assign different user
    Set <id> IdAdminCheck = new set<id>();
    String strAccessLevel = 'Edit'; //Read or Edit or All
    String subjectId;  
    List <ASI_CRM_CN_Issue_Sharing_Admin__c> SharingAList = [SELECT id, ASI_CRM_CN_Region_Code__c, ASI_CRM_CN_Issue_Type__c, ASI_CRM_QR_code_sticker_issue_category__c
                                                             FROM ASI_CRM_CN_Issue_Sharing_Admin__c 
                                                             WHERE ASI_CRM_CN_Inactive__c = false];
    List<RecordType> RTList = [SELECT Name FROM RecordType WHERE SOBjectType = 'ASI_CRM_Issue_Zone__c'];
    map<string, string> RT_Map = new map<string, string>();//20160303 Ben @ Elufa Changed map<id, String> to map<String, Sting>
    map<string, map<string, id>> Sharing_Map = new map<string, map<string, id>>();
    
    public ASI_CRM_CN_ChatterSharing(){
        init();
    }
    
    
    public void init(){
        if (RTList.size() > 0){
            for (RecordType a : RTList){
                RT_Map.put(a.id, a.Name);
            }
        }
        if (SharingAList.size() > 0){
            string strIZType;
            string strIZRegion;
            
            for (ASI_CRM_CN_Issue_Sharing_Admin__c b : SharingAList){
                strIZType = b.ASI_CRM_CN_Issue_Type__c;
                if (b.ASI_CRM_CN_Region_Code__c != null && b.ASI_CRM_CN_Region_Code__c != '')
                    strIZRegion = b.ASI_CRM_CN_Region_Code__c;
                else if (b.ASI_CRM_QR_code_sticker_issue_category__c != null && b.ASI_CRM_QR_code_sticker_issue_category__c != '')
                    strIZRegion = 'NoRegion' + b.ASI_CRM_QR_code_sticker_issue_category__c;
				else
                	strIZRegion = 'NoRegion';
                    
                if (Sharing_Map.containskey(strIZType)){
                    if (!Sharing_Map.get(strIZType).containskey(strIZRegion)){
                         Sharing_Map.get(strIZType).put(strIZRegion, b.id);
                    }
                }else{
                    map<string, id> RegionID_map = new map<string, id>();
                    RegionID_map.put(strIZRegion, b.id);
                    Sharing_Map.put(strIZType, RegionID_map );
                }
            }
        }        
        
    }
    
    public void ASI_CRM_CN_SharingUserList(String strRecordType, String strCity, String strRegion){
        
        if (strRecordType !=null){
            //String RTName = [SELECT Name FROM RecordType WHERE SObjectType = 'ASI_CRM_Issue_Zone__c' AND id = :strRecordType].Name;
            //system.debug('RTName: ' + RTName);
            /*SharingAList = [SELECT id FROM ASI_CRM_CN_Issue_Sharing_Admin__c 
                                                                     WHERE ASI_CRM_CN_Issue_Type__c = :RTName 
                                                                     AND ASI_CRM_CN_Region__r.ASI_CRM_Region_Code__c = :strRegion
                                                                     AND ASI_CRM_CN_Inactive__c = false];
            */
            string RTName;
            if(!RT_Map.containskey(strRecordType) && strRecordType != '' && trigger.isUpdate){//20160224 Ben @ Elufa
                RTName = strRecordType;
            }//20160224 End
            else if (RT_Map.containskey(strRecordType)){
                RTName = RT_Map.get(strRecordType);
            }
             id SharingAdminTypeId;
             string strRegionCode;
             if (strRegion != null && strRegion != ''){
                 strRegionCode = strRegion;
             }else{
                 strRegionCode = 'NoRegion';
             }
             system.debug('strRegionCode : ' + strRegionCode );
             system.debug('Sharing_Map: ' + Sharing_Map);
             if (Sharing_Map.containskey(RTName)){
                 if (Sharing_Map.get(RTName).containskey(strRegionCode)){
                     SharingAdminTypeId = Sharing_Map.get(RTName).get(strRegion);
                 }else{
                     if (Sharing_Map.get(RTName).containskey('NoRegion'))
                         SharingAdminTypeId = Sharing_Map.get(RTName).get('NoRegion');
                 }
             }
            system.debug('SharingAdminTypeId: ' + SharingAdminTypeId);                         
            //system.debug('SharingAList.size(): ' + SharingAList.size());
            //for (ASI_CRM_CN_Issue_Sharing_Admin__c a : SharingAList){
            List <ASI_CRM_CN_Issue_Sharing_Admin_User_List__c> SharingUserList = [SELECT ASI_CRM_CN_User__c FROM ASI_CRM_CN_Issue_Sharing_Admin_User_List__c
                                                                              WHERE ASI_CRM_CN_Issue_Sharing_Group__c = :SharingAdminTypeId ];
            for (ASI_CRM_CN_Issue_Sharing_Admin_User_List__c b : SharingUserList){
                IdSharedAdmin.add(b.ASI_CRM_CN_User__c);
                IdAdminCheck.add(b.ASI_CRM_CN_User__c);
            }
            //}
            //2014-04-14 Add requestor auto follow
            //IdSharedAdmin.add(UserInfo.getUserId());
            system.debug('IdSharedAdmin: ' + IdSharedAdmin);
        }
    }
    
    
    public void ASI_CRM_CN_AddMentionToChatter(ASI_CRM_Issue_Zone__c[] arrIZMC){
        for (ASI_CRM_Issue_Zone__c f : arrIZMC){
            subjectId = f.id;  
            //if (f.ASI_CRM_City__c != null)
            //  ASI_CRM_CN_SharingUserList(f.recordtypeid, null, f.ASI_CRM_City__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c);
            //else
            //20160224 Ben @ Elufa
            if(trigger.isUpdate && f.ASI_CRM_CN_Reclassification__c != NULL && f.ASI_CRM_CN_Reclassification__c != ''){
                ASI_CRM_CN_SharingUserList(f.ASI_CRM_CN_Reclassification__c, null, f.ASI_CRM_CN_Region__c);
            }else{
                ASI_CRM_CN_SharingUserList(f.recordtypeid, null, f.ASI_CRM_CN_Region__c);
            }
            //20160224 End
        }
        String communityId = null;
        //Add @Mention only if the ShareAdmin List not null
        if (IdSharedAdmin.size() > 0){
            //Add a @Mention UserId to Feeditem
            ConnectApi.FeedType feedType = ConnectApi.FeedType.Record;
            ConnectApi.MessageBodyInput messageInput = new ConnectApi.MessageBodyInput();
            messageInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();
            ConnectApi.TextSegmentInput textSegment = new ConnectApi.TextSegmentInput();
            textSegment.text = 'Hi ';
            messageInput.messageSegments.add(textSegment);
            for (id a : IdSharedAdmin){
                ConnectApi.MentionSegmentInput mentionSegment = new ConnectApi.MentionSegmentInput();
                mentionSegment.id = a;
                messageInput.messageSegments.add(mentionSegment);
            }
            textSegment = new ConnectApi.TextSegmentInput();
            textSegment.text = trigger.isInsert ? '. I have added a new Issue' : '. I have modified the issue type';//20160224 Ben @ Elufa
            messageInput.messageSegments.add(textSegment);
            ConnectApi.FeedItemInput input = new ConnectApi.FeedItemInput();
            input.body = messageInput;
            ConnectApi.FeedItem feedItemRep = ConnectApi.ChatterFeeds.postFeedItem(communityId, feedType, subjectId, input, null);
        }
        
    }
    public void ASI_CRM_CN_ChatterFollow(ASI_CRM_Issue_Zone__c[]  arrIZ){
        //List <EntitySubscription> EntitySubsList = new List<EntitySubscription>();
        system.debug('ASI_CRM_CN_ChatterFollow Started');
        /*
        if (IdSharedAdmin.size() != null){
            try{
                for (ASI_CRM_Issue_Zone__c  objIZ : arrIZ){ 
                    //if (f.ASI_CRM_City__c != null)
                    //  ASI_CRM_CN_SharingUserList(objIZ.recordtypeid, null, objIZ.ASI_CRM_City__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c);
                    //else
                        ASI_CRM_CN_SharingUserList(objIZ.recordtypeid, null, objIZ.ASI_CRM_CN_Region__c);           
                    for (id a : IdSharedAdmin){
                        //Add follower to record
                        EntitySubscription objFollowed = new EntitySubscription();
                        objFollowed.parentID = objIZ.id;
                        objFollowed.subscriberId = a;
                        //insert objFollowed;
                        EntitySubsList.add(objFollowed);
                    }
                }
                insert EntitySubsList;
            }catch(Exception e){
                //Those who do not have the right to Add followers would Tag user in chatter feed.
                system.debug(e);
                ASI_CRM_CN_AddMentionToChatter(trigger.new);
            }
        }*/
        ASI_CRM_CN_AddMentionToChatter(arrIZ);
    }
    public void ASI_CRM_CN_AddShare(ASI_CRM_Issue_Zone__c[]  arrIZS){
        system.debug('ASI_CRM_CN_ChatterShare Started');
        for (ASI_CRM_Issue_Zone__c  objIZS : arrIZS){
				String strIZRegion = '';
				if (objIZS.ASI_CRM_Region__c != null && objIZS.ASI_CRM_Region__c != '')
                    strIZRegion = objIZS.ASI_CRM_Region__c;
                else if (objIZS.ASI_CRM_QR_Code_Sticker_Issue_Category__c != null && objIZS.ASI_CRM_QR_Code_Sticker_Issue_Category__c != '')
                    strIZRegion = 'NoRegion' + objIZS.ASI_CRM_QR_Code_Sticker_Issue_Category__c;
				else
                	strIZRegion = 'NoRegion';
            	ASI_CRM_CN_SharingUserList(objIZS.recordtypeid, null, strIZRegion );
                //ASI_CRM_CN_SharingUserList(objIZS.recordtypeid, null, objIZS.ASI_CRM_CN_Region__c );
            if (IdSharedAdmin.size()>0){
                List<ASI_CRM_Issue_Zone__Share> objIZShareList = new List<ASI_CRM_Issue_Zone__Share>();
                system.debug('Exit ASI_CRM_CN_SharingUserList, back to loop');
                for (id a : IdSharedAdmin){
                    system.debug('IdSharedAdmin loop start');
                    //Share record
                    ASI_CRM_Issue_Zone__Share objIZShare = new ASI_CRM_Issue_Zone__Share();
                    objIZShare.ParentId = objIZS.Id;
                    objIZShare.UserOrGroupId = a;
                    objIZShare.AccessLevel = strAccessLevel;
                    objIZShareList.add(objIZShare);
                    //Database.SaveResult sr = Database.insert(objIZShare,false);
                }
                Database.SaveResult[] sr = Database.insert(objIZShareList,false);
            }
        }
        ASI_CRM_CN_ChatterFollow(arrIZS);
    }
    public void ASI_CRM_CN_ChatterShareMentioned(FeedItem[] arrIZSM){
        system.debug('ASI_CRM_CN_ChatterShareMentioned Started');
        for (FeedItem objFI : arrIZSM){
            String FeedItemId = objFI.id; //0D5M000000Cnsz0KAB
            String communityId = null;
            //get user IDs of @mention user by using Chatter API
            ConnectApi.FeedItem feedItem = ConnectApi.ChatterFeeds.getFeedItem(communityId, feedItemId);
            List<ConnectApi.MessageSegment> messageSegments = feedItem.body.messageSegments;
            set <id> MentionUsers = new set <id>();
            for (ConnectApi.MessageSegment messageSegment : messageSegments) {
                //Downcast messageSegment to MentionSegment
                if (messageSegment instanceof ConnectApi.MentionSegment) {
                    system.debug('Message contains @Mention');
                    ConnectApi.MentionSegment mentionSegment = (ConnectApi.MentionSegment) messageSegment;
                    System.debug('Mentioned user name: ' + mentionSegment.name);
                    System.debug('Mentioned user id: ' + mentionSegment.record.id);
                    MentionUsers.add(mentionSegment.record.id);
                    system.debug(MentionUsers.size());
                }
            }
            //Share Record
            if (MentionUsers.size() > 0){
                List<ASI_CRM_Issue_Zone__Share> objIZShareList = new List<ASI_CRM_Issue_Zone__Share>();
                for(id userid : MentionUsers ){
                    ASI_CRM_Issue_Zone__Share objIZShare = new ASI_CRM_Issue_Zone__Share();
                    objIZShare.parentId = objFI.parentId;
                    objIZShare.UserOrGroupId = userid; // '005D00000023lPW';
                    objIZShare.AccessLevel = strAccessLevel;
                    objIZShareList.add(objIZShare);
                    //Database.SaveResult sr = Database.insert(objIZShare ,false); 
                }
                Database.SaveResult[] sr = Database.insert(objIZShareList ,false);
            }else{
                system.debug('No Mentioned User to share');    
            }
        }
    }
    /*
    2014-03-28    Stella Sing    Change Status after upload attachment in chatter
    */
    public void ASI_CRM_CN_ChatterChangeStatus(FeedItem[] arrIZCS){
        system.debug('ASI_CRM_CN_ChatterChangeStatus Started');
        String strYStatus = 'Open-Picture Uploaded'; //When attachment is existed.
        String strNStatus = 'Open'; //When NO attachment is existed.
        
        Id RecordId;
        //String FeedItemId;
        //String communityId;
        for (FeedItem objFI : arrIZCS){
            //FeedItemId = objFI.id;
            //communityId = null;
            RecordId = objFI.parentId;
        }
        
        //get attachment from chatter feeditem
        //String sObjName = RecordId.getSObjectType().getDescribe().getName();
        //system.debug('sObjName: ' + sObjName );
        //if (sObjName == 'ASI_CRM_Issue_Zone__c'){
        
            List <ContentDocumentLink> DocLinkList = [SELECT id FROM ContentDocumentLink WHERE LinkedEntityId = :RecordId];
            if (DocLinkList.size() > 0){
                system.debug('DocLinkList.size() > 0');
                ASI_CRM_Issue_Zone__c a = new ASI_CRM_Issue_Zone__c();
                a.id = RecordId;
                a.ASI_CRM_Status__c = strYStatus;
                update a;
                system.debug('Status updated!');
            }/*else{ //Reverse status if no attachment?
                ASI_CRM_Issue_Zone__c a = new ASI_CRM_Issue_Zone__c();
                a.id = RecordId;
                a.ASI_CRM_Status__c = strNStatus;
                update a;
            }*/
        //}
    }
    //2014-04-14 Admin Users add Feeditem, Issue Status change to "Investigating"
    public void ASI_CRM_CN_ChatterAdminChangeStatus(FeedItem[] arrIZCS){
        system.debug('ASI_CRM_CN_ChatterAdminChangeStatusStarted');
        String strStatus = 'Investigating'; //When Users (@ Issue Admin User table) add feeditem
        String strClose = 'Closed'; //Change status to close
        Id RecordId;
        String FeedItemId;
        String communityId = null;
        Boolean blclose = false;
        Id UserId = UserInfo.getUserId();
        for (FeedItem objFI : arrIZCS){
            RecordId = objFI.parentId;
            FeedItemId = objFi.id;
            system.debug('Feeditem body: ' + objFI.body);
            
            //check if body message contain 'close' or 'closed' (2014-04-16)
            if (objFI.body != null)
                if (objFI.body.left(5) == 'close' || objFI.body.left(6) == 'closed' || objFI.body.left(9) == '<p>closed' || objFI.body.left(8) == '<p>close')
                    blclose = true;
            system.debug('blclose: ' + blclose);
        }
        //ASI_CRM_CN_SharingUserList(IssueZone , null, null);        
        //String sObjName = RecordId.getSObjectType().getDescribe().getName();
        //system.debug('sObjName: ' + sObjName );
        //if (sObjName == 'ASI_CRM_Issue_Zone__c'){
            list <ASI_CRM_Issue_Zone__c > IssueZone = [SELECT RecordTypeId, ASI_CRM_CN_Region__c, ASI_CRM_City__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c, ASI_CRM_City__c from ASI_CRM_Issue_Zone__c WHERE id = :RecordId Limit 1];
            if (IssueZone.size()>0)
            for (ASI_CRM_Issue_Zone__c b : IssueZone){
                //if (b.ASI_CRM_City__c != null)
                //  ASI_CRM_CN_SharingUserList(b.RecordtypeId, null, b.ASI_CRM_City__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c); 
                //else
                    ASI_CRM_CN_SharingUserList(b.RecordtypeId, null, b.ASI_CRM_CN_Region__c); 
            } 
            if (IdAdminCheck.size() > 0){
                List<ASI_CRM_Issue_Zone__c> objIZUpdateList = new List<ASI_CRM_Issue_Zone__c>();
                for (Id a : IdAdminCheck){
                    if (UserId == a){
                        ASI_CRM_Issue_Zone__c ab = new ASI_CRM_Issue_Zone__c();
                        ab.id = RecordId;
                        if (blclose == true)
                            ab.ASI_CRM_Status__c = strClose;
                        else
                            ab.ASI_CRM_Status__c = strStatus; 
                        objIZUpdateList.add(ab);
                        //update ab;
                    }
                }
                update objIZUpdateList;
            }
        //}
    }
    //2014-4-30 Admin close Issue by commenting on a Chatter FeedItem 
    public void ASI_CRM_CN_ChatterAdminChangeStatusComment(FeedComment[] arrIZComment){
        system.debug('ASI_CRM_CN_ChatterAdminChangeStatusComment() Started');
        String strStatus = 'Investigating'; 
        String strClose = 'Closed'; //Change status to close
        Id RecordId;
        Boolean blclose = false;
        String communityId = null;
        Id UserId = UserInfo.getUserId();
        for (FeedComment objFI : arrIZComment){
            RecordId = objFI.parentId;
            system.debug('FeedComment CommentBody: ' + objFI.Commentbody);
            if (objFI.CommentBody != null)
                if (objFI.CommentBody.left(5) == 'close' || objFI.CommentBody.left(6) == 'closed' || objFI.CommentBody.left(9) == '<p>closed' || objFI.CommentBody.left(8) == '<p>close')
                    blclose = true;
            system.debug('blclose: ' + blclose);
            
            //Comment @Mention sharing
            //get user IDs of @mention user by using Chatter API
            ConnectApi.Comment feedComment = ConnectApi.ChatterFeeds.getComment(communityId, objFI.id);
            List<ConnectApi.MessageSegment> messageSegments = feedComment.body.messageSegments;
            set <id> MentionUsers = new set <id>();
            for (ConnectApi.MessageSegment messageSegment : messageSegments) {
                //Downcast messageSegment to MentionSegment
                if (messageSegment instanceof ConnectApi.MentionSegment) {
                    system.debug('Message contains @Mention');
                    ConnectApi.MentionSegment mentionSegment = (ConnectApi.MentionSegment) messageSegment;
                    System.debug('Mentioned user name: ' + mentionSegment.name);
                    System.debug('Mentioned user id: ' + mentionSegment.record.id);
                    MentionUsers.add(mentionSegment.record.id);
                    system.debug(MentionUsers.size());
                }
            }
            //Share Record
            if (MentionUsers.size() > 0){
                List<ASI_CRM_Issue_Zone__Share> objIZShareList = new List<ASI_CRM_Issue_Zone__Share>();
                for(id mentionuser : MentionUsers ){
                    ASI_CRM_Issue_Zone__Share objIZShare = new ASI_CRM_Issue_Zone__Share();
                    objIZShare.parentId = objFI.parentId;
                    objIZShare.UserOrGroupId = mentionuser; // '005D00000023lPW';
                    objIZShare.AccessLevel = strAccessLevel;
                    objIZShareList.add(objIZShare);
                    //Database.SaveResult sr = Database.insert(objIZShare ,false); 
                }
                Database.SaveResult[] sr = Database.insert(objIZShareList ,false);
            }else{
                system.debug('No Mentioned User to share');    
            }
        }     
        //String sObjName = (RecordId).getSObjectType().getDescribe().getName();
        //system.debug('sObjName: ' + sObjName );
        //if (sObjName == 'ASI_CRM_Issue_Zone__c'){
            list <ASI_CRM_Issue_Zone__c > IssueZone = [SELECT RecordTypeId, ASI_CRM_CN_Region__c, ASI_CRM_City__c, ASI_CRM_City__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c from ASI_CRM_Issue_Zone__c WHERE id = :RecordId Limit 1];
            if (IssueZone.size()>0)
            for (ASI_CRM_Issue_Zone__c b : IssueZone){
                //if (b.ASI_CRM_City__c != null)
                //  ASI_CRM_CN_SharingUserList(b.RecordtypeId, null, b.ASI_CRM_City__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c);
                //else
                    ASI_CRM_CN_SharingUserList(b.RecordtypeId, null, b.ASI_CRM_CN_Region__c); 
            } 
            if (IdAdminCheck.size() > 0){
                List<ASI_CRM_Issue_Zone__c> objIZUpdateList = new List<ASI_CRM_Issue_Zone__c>();
                for (Id a : IdAdminCheck){
                    if (UserId == a){
                        ASI_CRM_Issue_Zone__c ab = new ASI_CRM_Issue_Zone__c();
                        ab.id = RecordId;
                        if (blclose == true)
                            ab.ASI_CRM_Status__c = strClose;
                        else
                            ab.ASI_CRM_Status__c = strStatus; 
                        objIZUpdateList.add(ab);
                        //update ab;
                    }
                }
                update objIZUpdateList;
            }
        //}
        
    }
}