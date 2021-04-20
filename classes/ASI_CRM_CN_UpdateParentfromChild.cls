/* 2014-02-13
Created by: Stella Sing
Goal 1: Copy Child(Event Sub-Brand) Sub-Brand Name to Parent (Event)
Goal 2: Copy Child(Event Sub-Channel) Sub-Channel Name to Parent (Event)

 */
public with sharing class ASI_CRM_CN_UpdateParentfromChild{

    string strSubBrandName;
    string strSubChannelName;
    ID strEventID;
    set<id> strSBID = new set <id>();
    set<id> strSCID = new set <id>();

    public ASI_CRM_CN_UpdateParentfromChild(){
    }

    public void UpdateEventSubBrandName(ASI_MFM_Event_Sub_Brand__c[] arrSB){
        system.debug('UpdateEventSubBrandName Started');
        for (ASI_MFM_Event_Sub_Brand__c childObj1 : arrSB){
            strEventID = childObj1.ASI_MFM_Event__c;
            system.debug('Event ID: ' + childObj1.ASI_MFM_Event__c);
        }
        list <ASI_MFM_Event_Sub_Brand__c> childobj = [SELECT ASI_MFM_Sub_brand__c from ASI_MFM_Event_Sub_Brand__c Where ASI_MFM_Event__c = :strEventID];
        
        for (ASI_MFM_Event_Sub_Brand__c a : childobj){
            strSBID.add(a.ASI_MFM_Sub_brand__c);
        }
        list <ASI_MFM_Sub_brand__c> objSB = [SELECT Name from ASI_MFM_Sub_brand__c Where id = :strSBID];
        for (ASI_MFM_Sub_brand__c b :objSB) {
            strSubBrandName += b.Name + ', ';
        }
        
        if (objSB.size() >0){
            ASI_MFM_Event__c parentobj = new ASI_MFM_Event__c();
            parentObj.id = strEventID;
            parentObj.ASI_CRM_CN_Event_Sub_Brand_Copy__c = strSubBrandName.substring(4, strSubBrandName.length()-2);
            parentObj.recordtypeid=Global_RecordTypeCache.getRtId('ASI_MFM_Event__cASI_MFM_CN_Event');
            update parentObj;
            system.debug('Updated!');
        }else{
            ASI_MFM_Event__c parentobj = new ASI_MFM_Event__c();
            parentObj.id = strEventID;
            parentObj.ASI_CRM_CN_Event_Sub_Brand_Copy__c = '';
            update parentObj;
            system.debug('Empty!');
        }   
    }
    public void UpdateEventSubChannelName(ASI_MFM_Event_Sub_Channel__c[] arrSC){
    system.debug('UpdateEventSubChannelName Started');
        for (ASI_MFM_Event_Sub_Channel__c childObj1 : arrSC){
            strEventID = childObj1.ASI_MFM_Event__c;
            system.debug('Event ID: ' + childObj1.ASI_MFM_Event__c);
        }
        list <ASI_MFM_Event_Sub_Channel__c> childobj = [SELECT ASI_MFM_Sub_Channel__c from ASI_MFM_Event_Sub_Channel__c Where ASI_MFM_Event__c = :strEventID];
        
        for (ASI_MFM_Event_Sub_Channel__c a : childobj){
            strSCID.add(a.ASI_MFM_Sub_Channel__c);
        }
        list <ASI_MFM_Sub_Channel__c  > objSC = [SELECT Name from ASI_MFM_Sub_Channel__c Where id = :strSCID];
        for (ASI_MFM_Sub_Channel__c  b :objSC) {
            strSubChannelName += b.Name + ', ';
        }
        
        if (objSC.size() >0){
            ASI_MFM_Event__c parentobj = new ASI_MFM_Event__c();
            parentObj.id = strEventID;
            parentObj.ASI_CRM_CN_Event_Sub_Channel_Copy__c = strSubChannelName.substring(4, strSubChannelName.length()-2);
            update parentObj;
            system.debug('Updated!');
        }else{
            ASI_MFM_Event__c parentobj = new ASI_MFM_Event__c();
            parentObj.id = strEventID;
            parentObj.ASI_CRM_CN_Event_Sub_Channel_Copy__c = '';
            update parentObj;
            system.debug('Empty!');
        }   
    }   
}