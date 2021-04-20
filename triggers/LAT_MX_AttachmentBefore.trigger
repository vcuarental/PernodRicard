/*******************************************************************************************
*        Company:Valuenet      Developers:Elena Schwarzböck        Date:01/10/2013         *
********************************************************************************************/

trigger LAT_MX_AttachmentBefore on Attachment (before delete, before insert, before update) {
    
    List<Profile> lst_Profile = [SELECT Id, Name FROM Profile WHERE Name LIKE 'LAT_MX%'];  // you can add more prefix
         
    Boolean isMexicoProfile = false;

    for(Profile p : lst_Profile){
      if(p.get('Id') == UserInfo.getProfileId()){
        isMexicoProfile = true;
      }
    }
    if(isMexicoProfile){
      if(trigger.isInsert){
          LAT_MX_AP01_Attachment.UpdatesFieldMissingInformation(trigger.new,'insert');    
      } else if(trigger.isUpdate){
          LAT_MX_AP01_Attachment.UpdatesFieldMissingInformation(trigger.new, 'update');
      } else if(trigger.isDelete){
          LAT_MX_AP01_Attachment.UpdatesFieldMissingInformation(trigger.old,'delete');        
      }
  }

}