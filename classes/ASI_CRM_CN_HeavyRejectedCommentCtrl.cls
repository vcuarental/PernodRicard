/* Filename:    ASI_CRM_CN_HeavyRejectedCommentCtrl.cls
* Author:       Laputa
* Purpose:      Controller PDF for getting Rejected Comment 
* Copyright 2017 Laputa Limited. All rights reserved.
* Customer confidential. Do not distribute.
* History     
* -----------------------------------------------------------------------------
* 2017-09-24    Laputa      Created

*/


public class ASI_CRM_CN_HeavyRejectedCommentCtrl {
    public id currentHeaderId {set;get;}
    public Boolean dummyVar { get { if (dummyVar != true) {dummyVar = init();} return dummyVar; } set; }
    
    public String RejectedComments {set;get;}{RejectedComments='';}
 
    public String ActorName {set;get;}{ActorName='';}
    public String CreatedDate {set;get;}{CreatedDate='';}
	public Boolean AllowDisplay{set;get;}{AllowDisplay=false;}
    public ASI_CRM_CN_HeavyRejectedCommentCtrl(){ }
    public boolean init(){
        AllowDisplay=false;
        List<ProcessInstance> processIn = new List<ProcessInstance>([SELECT Id, TargetObjectId, Status, (SELECT Comments,ActorId,Actor.Name,CreatedDate FROM Steps WHERE StepStatus = 'Rejected') 
                                                                     FROM ProcessInstance where TargetObjectId =: currentHeaderId AND Status = 'Rejected' ORDER BY CompletedDate DESC]);
        
        if(processIn.size() > 0){
            for(ProcessInstance obj : processIn){
                for(ProcessInstanceStep obj2 : obj.Steps){
                    if(obj2.Actor.Name != NULL && obj2.Actor.Name !='' && ActorName==''){
                        ActorName=obj2.Actor.Name;
                        DateTime CreatedDateTime =obj2.CreatedDate;
                        CreatedDate=CreatedDateTime.format('dd/MM/yyyy');
                        AllowDisplay=true;
                        if(obj2.Comments != NULL && obj2.Comments != ''){
                            RejectedComments=obj2.Comments;
                            AllowDisplay=true;
                        }
                    }
                    
                }
            }
        }
        return true;
    }
}