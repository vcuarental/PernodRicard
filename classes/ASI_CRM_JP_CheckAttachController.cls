public with sharing class ASI_CRM_JP_CheckAttachController{
    public String currentHeaderId{get;set;}
    public List<Attachment> attchList{get;set;}
    public Decimal noOfAttach;
    public ASI_CRM_JP_CheckAttachController(){
    } 
    public Decimal getNoOfAttach(){
        attchList = [Select Id From Attachment Where ParentId = :currentHeaderId];
        noOfAttach = attchList.size();
        return noOfAttach;
    }
}