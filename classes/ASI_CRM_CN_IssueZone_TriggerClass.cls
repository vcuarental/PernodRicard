public without sharing class ASI_CRM_CN_IssueZone_TriggerClass {
    
    public static void routineBeforeInsert(list<ASI_CRM_Issue_Zone__c> trigger_new,map<id, ASI_MFM_Plan__c> trigger_oldMap) {
        List<RecordType> RTList = [SELECT Name FROM RecordType WHERE SOBjectType = 'ASI_CRM_Issue_Zone__c'];
        map<id, string> RT_Map = new map<id, string>();
        if (RTList.size() > 0){
            for (RecordType a : RTList){
                RT_Map.put(a.id, a.Name);
            }
        }
        List <ASI_CRM_CN_Issue_Sharing_Admin__c> SharingAList = [SELECT id, ASI_CRM_CN_Region_Code__c, ASI_CRM_CN_Issue_Type__c, ASI_CRM_QR_code_sticker_issue_category__c
                                                                 FROM ASI_CRM_CN_Issue_Sharing_Admin__c 
                                                                 WHERE ASI_CRM_CN_Inactive__c = false];
        map<string, map<string, id>> Sharing_Map = new map<string, map<string, id>>();
        
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
                    Sharing_Map.put(strIZType, RegionID_map);
                }
            }
            
        }
        Set<Id> Rids=new set<Id>();
        for (ASI_CRM_Issue_Zone__c p : trigger_new){
            if(!Rids.contains(p.RecordTypeId)){
                Rids.add(p.RecordTypeId);
            }
        }
        
        string RTName;
        Set<string> RTNames=new set<string>();
        /*if (RT_Map.containskey(trigger_new[0].recordtypeid)){
RTName = RT_Map.get(trigger_new[0].recordtypeid);
}*/
        for(id ids:Rids){
            if (RT_Map.containskey(ids)){
                RTNames.add(RT_Map.get(ids));
            }
        }
        // System.debug(RTName+'bugTestPRC'+RTNames);
        //id SharingAdminTypeId;ASI_CRM_QR_Code_Sticker_Issue_Category__c
        string strRegionCode;
        if (trigger_new[0].ASI_CRM_Region__c != null && trigger_new[0].ASI_CRM_Region__c != ''){
            strRegionCode = trigger_new[0].ASI_CRM_Region__c;
        }else if(trigger_new[0].ASI_CRM_QR_Code_Sticker_Issue_Category__c != null && trigger_new[0].ASI_CRM_QR_Code_Sticker_Issue_Category__c != ''){
            strRegionCode = 'NoRegion' + trigger_new[0].ASI_CRM_QR_Code_Sticker_Issue_Category__c;
        }else{
            strRegionCode = 'NoRegion';
        }
        /*
if (Sharing_Map.containskey(RTName)){
if (Sharing_Map.get(RTName).containskey(strRegionCode)){                     
SharingAdminTypeId = Sharing_Map.get(RTName).get(strRegionCode);
}else{
if (Sharing_Map.get(RTName).containskey('NoRegion'))
SharingAdminTypeId = Sharing_Map.get(RTName).get('NoRegion');
}
}
*/ 
        Set<Id> SharingAdminId=new set<Id>();
        for(string str:RTNames){
            if (Sharing_Map.containskey(str)){
                if (Sharing_Map.get(str).containskey(strRegionCode)){                     
                    //SharingAdminTypeId = Sharing_Map.get(str).get(strRegionCode);
                    SharingAdminId.add(Sharing_Map.get(str).get(strRegionCode));
                }else{
                    if (Sharing_Map.get(str).containskey('NoRegion'))
                        SharingAdminId.add(Sharing_Map.get(str).get('NoRegion'));
                    //SharingAdminTypeId = Sharing_Map.get(str).get('NoRegion');
                }
            }
        }
        
        System.debug(SharingAdminId+'RegionTest'+strRegionCode);
        List <ASI_CRM_CN_Issue_Sharing_Admin_User_List__c> SharingUserList = [SELECT ASI_CRM_CN_User__c,ASI_CRM_CN_Issue_Sharing_Group__c FROM ASI_CRM_CN_Issue_Sharing_Admin_User_List__c
                                                                              WHERE ASI_CRM_CN_Issue_Sharing_Group__c in:SharingAdminId ];
        
        System.debug('IssueSharingAdminTest'+SharingUserList);
        //Get Approver 
        //  List<ASI_CRM_Issue_Zone__Share> objIZShareList = new List<ASI_CRM_Issue_Zone__Share>();
        // Set<Id> OIds=new set<Id>();
        //  for (ASI_CRM_Issue_Zone__c p : trigger_new){
        //ownerIds.add(p.OwnerId);
        //    System.debug('ownerIdsTest'+p.OwnerId);
        //   OIds.add(p.OwnerId);
        //}
        //objIZShareList=[select UserOrGroupId from ASI_CRM_Issue_Zone__Share where ParentId in: trigger_new and UserOrGroupId not in:OIds];
        //
        // Get Approver  
        for (ASI_CRM_Issue_Zone__c p : trigger_new){
            p.ASI_CRM_Approver_1__c=null;
            p.ASI_CRM_Approver_2__c=null;
            p.ASI_CRM_Approver_3__c=null;
            p.ASI_CRM_Approver_4__c=null;
            p.ASI_CRM_Approver_5__c=null;
            
            if(SharingUserList.size()>0){
                integer countn=1;
                integer usersize=SharingUserList.size();
                boolean IsFound=false;
                for(ASI_CRM_CN_Issue_Sharing_Admin_User_List__c al:SharingUserList){
                    if(p.ASI_CRM_Approver_1__c==null && al.ASI_CRM_CN_User__c!=p.OwnerId){
                        p.ASI_CRM_Approver_1__c=al.ASI_CRM_CN_User__c;
                        IsFound=true;
                    }
                    if(countn>1 && usersize>1 && p.ASI_CRM_Approver_2__c==null && al.ASI_CRM_CN_User__c!=p.OwnerId){
                        p.ASI_CRM_Approver_2__c=al.ASI_CRM_CN_User__c;
                        IsFound=true;
                    }
                    if(countn>2 && usersize>2 && p.ASI_CRM_Approver_3__c==null && al.ASI_CRM_CN_User__c!=p.OwnerId){
                        p.ASI_CRM_Approver_3__c=al.ASI_CRM_CN_User__c;
                        IsFound=true;
                    }
                    if(countn>3  && usersize>3 && p.ASI_CRM_Approver_4__c==null && al.ASI_CRM_CN_User__c!=p.OwnerId){
                        p.ASI_CRM_Approver_4__c=al.ASI_CRM_CN_User__c;
                        IsFound=true;
                    }
                    if(countn>4  && usersize>4 && p.ASI_CRM_Approver_5__c==null && al.ASI_CRM_CN_User__c!=p.OwnerId){
                        p.ASI_CRM_Approver_5__c=al.ASI_CRM_CN_User__c;
                        IsFound=true;
                    }
                    if(IsFound){
                        countn++;
                        IsFound=false;
                    }
                }
            }
        }
    }
    public static void routineBeforeUpdate(list<ASI_CRM_Issue_Zone__c> trigger_new,map<id, ASI_MFM_Plan__c> trigger_oldMap){
        List<ASI_CRM_CN_Issue_Sharing_Admin_User_List__c> UserList = [SELECT id,ASI_CRM_CN_User__c,ASI_CRM_CN_Issue_Sharing_Group__r.name,ASI_CRM_CN_Issue_Sharing_Group__c
                                                                      FROM ASI_CRM_CN_Issue_Sharing_Admin_User_List__c];
        List<ASI_CRM_Issue_Zone__c> ToUpdate=new List<ASI_CRM_Issue_Zone__c>{};
            set<id> AdminId = new set<id>();
        set<id> RCID=new set<id>();
        for(ASI_CRM_Issue_Zone__c a:trigger_new){
            for(ASI_CRM_CN_Issue_Sharing_Admin_User_List__c b:UserList){
                if(b.ASI_CRM_CN_Issue_Sharing_Group__r.name==a.ASI_CRM_CN_Reclassification__c){
                    RCID.add(b.ASI_CRM_CN_Issue_Sharing_Group__c);
                    AdminID.add(b.ASI_CRM_CN_User__c);
                }
            }
        }
        List<ASI_CRM_CN_Issue_Sharing_Admin_User_List__c> SharingUserList = [SELECT id,ASI_CRM_CN_User__c,ASI_CRM_CN_Issue_Sharing_Group__r.name,ASI_CRM_CN_Issue_Sharing_Group__c
                                                                             FROM ASI_CRM_CN_Issue_Sharing_Admin_User_List__c
                                                                             where ASI_CRM_CN_Issue_Sharing_Group__c in:RCID];  
        for (ASI_CRM_Issue_Zone__c p : trigger_new){
            if(p.ASI_CRM_CN_Reclassification__c!=Null){
                p.ASI_CRM_Approver_1__c=null;
                p.ASI_CRM_Approver_2__c=null;
                p.ASI_CRM_Approver_3__c=null;
                p.ASI_CRM_Approver_4__c=null;
                p.ASI_CRM_Approver_5__c=null;
                if(SharingUserList.size()>0){
                    integer countn=1;
                    integer usersize=SharingUserList.size();
                    boolean IsFound=false;
                    for(ASI_CRM_CN_Issue_Sharing_Admin_User_List__c al:SharingUserList){
                        if(p.ASI_CRM_Approver_1__c==null && al.ASI_CRM_CN_User__c!=p.OwnerId){
                            p.ASI_CRM_Approver_1__c=al.ASI_CRM_CN_User__c;
                            IsFound=true;
                        }
                        if(countn>1 && usersize>1 && p.ASI_CRM_Approver_2__c==null && al.ASI_CRM_CN_User__c!=p.OwnerId){
                            p.ASI_CRM_Approver_2__c=al.ASI_CRM_CN_User__c;
                            IsFound=true;
                        }
                        if(countn>2 && usersize>2 && p.ASI_CRM_Approver_3__c==null && al.ASI_CRM_CN_User__c!=p.OwnerId){
                            p.ASI_CRM_Approver_3__c=al.ASI_CRM_CN_User__c;
                            IsFound=true;
                        }
                        if(countn>3  && usersize>3 && p.ASI_CRM_Approver_4__c==null && al.ASI_CRM_CN_User__c!=p.OwnerId){
                            p.ASI_CRM_Approver_4__c=al.ASI_CRM_CN_User__c;
                            IsFound=true;
                        }
                        
                        if(IsFound){
                            countn++;
                            IsFound=false;
                        }
                    }
                }
            }
        }
        
        List<ASI_CRM_Issue_Zone__Share> objIZShareList = new List<ASI_CRM_Issue_Zone__Share>();
        for (ASI_CRM_Issue_Zone__c p : trigger_new){
            for (id a : AdminId){
                system.debug('IdSharedAdmin loop start');
                //Share record
                ASI_CRM_Issue_Zone__Share objIZShare = new ASI_CRM_Issue_Zone__Share();
                objIZShare.ParentId = p.Id;
                objIZShare.UserOrGroupId = a;
                objIZShare.AccessLevel = 'Edit';
                objIZShareList.add(objIZShare);
                //Database.SaveResult sr = Database.insert(objIZShare,false);
            }       
        }
        database.SaveResult[] sr = Database.insert(objIZShareList,false);
    }
}