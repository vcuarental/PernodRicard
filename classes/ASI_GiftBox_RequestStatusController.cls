public class ASI_GiftBox_RequestStatusController {
    public ID headerid { get; private set;}
    public ASI_GiftBox_Request_Header__c header { get; private set;}
    public Boolean ButtonVisible {get; set;}
    private Boolean isHRUser {get;set;}
    
    public ASI_GiftBox_RequestStatusController (ApexPages.StandardController stdController){
        headerid = (Id)stdController.getId();
        header = [select ASI_GiftBox_Status__c, OwnerId from ASI_GiftBox_Request_Header__c where id = :headerid];
        isHRUser = checkIsInUserGroup(UserInfo.getUserId(),'ASI_Gift_Box_HR_Review_User');
        ButtonVisible = getButtonVisible();
    }
       
    public boolean getButtonVisible()
    {
      if(header.ASI_GiftBox_Status__c=='Waiting for HR Review' && isHRUser)
          return true;
      else
          return false;
    }
    
    private Boolean checkIsInUserGroup(Id userId,String groupName ){        
        Group userGroup = [Select Id From Group Where DeveloperName = :groupName];
        List<GroupMember> hrGroupMember = [Select UserOrGroupId From GroupMember Where GroupId = :userGroup.Id and UserOrGroupId=:userId ];
        Boolean result = false;
        
        if(hrGroupMember.size()>0 ){
            result = true;
        }
        return result;
    }
    
    public PageReference approve(){
        if (isHRUser){
            header.ASI_GiftBox_Status__c = 'Waiting for Delivery';
            apexpages.addMessage(new apexpages.Message(apexpages.severity.info, 'The Gift Box request status has been updated. Users will be notified by email.'));           
            update header;
            calRequestedQuantity();
        }
        else {
            apexpages.addMessage(new apexpages.Message(apexpages.severity.info, 'You are not allowed to update status.'));           
        }
        ButtonVisible =false;
        return null;//new PageReference('/' + headerid );
    }
    
    
    public PageReference reject(){
        if (isHRUser){
            header.ASI_GiftBox_Status__c = 'Reject';
            apexpages.addMessage(new apexpages.Message(apexpages.severity.info, 'The Gift Box request status has been updated. User will be notified by email.'));           
            update header;     
            calRequestedQuantity();    
        }
        else {
            apexpages.addMessage(new apexpages.Message(apexpages.severity.info, 'You are not allowed to update status.'));           
        }
        ButtonVisible =false;
        return null;//new PageReference('/' + headerid );
    }
    
    public PageReference submit(){
        //Boolean isHRUser = checkIsInUserGroup(UserInfo.getUserId(),'ASI_Gift_Box_HR_Review_User');
        Boolean result = false;
        
         if (header.ASI_GiftBox_Status__c == 'Open'){
            //Obsolete validation, allow sales rep to submit even if Gift Box is out of stock
            /*string r=checkAvaliable();
            if(r.length()>1){
                apexpages.addMessage(new apexpages.Message(apexpages.severity.info,'Not enough stock for the gift box selected '+r.substring(2)));           
                return null;
            }*/
         
            ASI_GiftBox_Notification_User__c emailRece= getNotificationList();
            if(emailRece!=null){ //HR_User__c,Finance_User__c,MKT_User__c
                header.ASI_GiftBox_HR_User__c=emailRece.HR_User__c;
                header.ASI_GiftBox_Finance_User__c=emailRece.Finance_User__c;
                header.ASI_GiftBox_Marketing_User__c=emailRece.MKT_User__c;
            }
             
            header.ASI_GiftBox_Status__c = 'Waiting for HR Review';
            apexpages.addMessage(new apexpages.Message(apexpages.severity.info, 'The Gift Box request has been submitted. HR handler will be notified by email.'));           
            result = true;
         }
   /*      else if (header.ASI_GiftBox_Status__c == 'Waiting for HR Review'){
            if (isHRUser){
                header.ASI_GiftBox_Status__c = 'Waiting for Delivery';
                apexpages.addMessage(new apexpages.Message(apexpages.severity.info, 'The Gift Box request status has been updated. Marketing user will be notified by email.'));           
                result = true;
            }
            else {
                apexpages.addMessage(new apexpages.Message(apexpages.severity.info, 'You are not allowed to update status.'));           
                result = false;
            }
         }*/
         else if (header.ASI_GiftBox_Status__c == 'Waiting for Delivery'){
            if (isHRUser){
                header.ASI_GiftBox_Status__c = 'Complete';
                apexpages.addMessage(new apexpages.Message(apexpages.severity.info, 'The Gift Box request status has been updated. Requester will be notified by email.'));           
                result = true;
            }
            else {
                apexpages.addMessage(new apexpages.Message(apexpages.severity.info, 'You are not allowed to update status.'));           
                result = false;
            }
         }
         else if (header.ASI_GiftBox_Status__c == 'Complete'){
            apexpages.addMessage(new apexpages.Message(apexpages.severity.info, 'The request has already been completed.'));           
            result = false;
         }else if (header.ASI_GiftBox_Status__c == 'Reject'){
            apexpages.addMessage(new apexpages.Message(apexpages.severity.info, 'The request has already been rejected.'));           
            result = false;
         }
         
         if (result){
            update header;
         }
         
         return null;
         
        /*
            String status='Open';
            String newStatus='Requested';
            
            if(checkIsInUserGroup(UserInfo.getUserId(),'ASI_Gift_Box_HR_Review_User')){
                status='Requested';
                newStatus='Waiting for delivery';
            }
                    
            List<ASI_GiftBox_Request_Item__c> itemDetails=[select ASI_GiftBox_Request_Item_Status__c,ASI_GiftBox_Request_Item_Status_Time__c,ASI_GiftBox_Request_Item_Date__c from ASI_GiftBox_Request_Item__c 
                    where ASI_GiftBox_Request_Id__c = :headerid 
                    and ASI_GiftBox_Request_Item_Status__c = :status];
                    
             for (ASI_GiftBox_Request_Item__c r : itemDetails){
                 r.ASI_GiftBox_Request_Item_Status__c = newStatus;
                 r.ASI_GiftBox_Request_Item_Status_Time__c=System.Now();
                 if(newStatus=='Requested')
                     r.ASI_GiftBox_Request_Item_Date__c=Date.today();
             }        
            
            if(itemDetails.size()>0){
                update itemDetails;
                ASI_GiftBox_Request_Header__c requestHeader=[select ASI_GiftBox_Request_LastStatus_Time__c from ASI_GiftBox_Request_Header__c where Id  = :headerid];
                requestHeader.ASI_GiftBox_Request_LastStatus_Time__c=System.now();
                update requestHeader;
                apexpages.addMessage(new apexpages.Message(apexpages.severity.info, 'The Gift Box request has been submitted. HR handler will be notified by email.'));           
            }
            return null;
        */
    }
    
    public PageReference back(){
        
        return new PageReference('/' + headerid );
    }
      
    public void calRequestedQuantity(){
        String [] status = new String[]{'Open','Reject'};
        
        List<ASI_GiftBox_Request_Item__c> requestDetails= [select ASI_GiftBox_Request_Item__c from ASI_GiftBox_Request_Item__c where ASI_GiftBox_Request_Id__c = :headerid ];
        List <Id> requestProd=new List <Id>();

        for(ASI_GiftBox_Request_Item__c i : requestDetails){
            requestProd.Add(i.ASI_GiftBox_Request_Item__c);
        }
        
        List<ASI_GiftBox_Request_Item__c> requestItemList = [select ASI_GiftBox_Request_Item__c, ASI_GiftBox_Request_Quantity__c, ASI_GiftBox_Request_Item_Warehouse__c from ASI_GiftBox_Request_Item__c
            where ASI_GiftBox_Request_Item__c in :requestProd and ASI_GiftBox_Request_Id__r.ASI_GiftBox_Status__c not in :status ];
        
        List<ASI_GiftBox_Inventory_Detail__c> inventoryWarehouseList = [select ASI_GiftBox_Item_Id__c, ASI_GiftBox_Item_Warehouse__c, ASI_GiftBox_Item_Requested_Quantity__c from ASI_GiftBox_Inventory_Detail__c 
            where ASI_GiftBox_Item_Id__c in :requestProd];
            
        for (ASI_GiftBox_Inventory_Detail__c inv :inventoryWarehouseList){
            decimal requestQty = 0;
            
            for (ASI_GiftBox_Request_Item__c i :requestItemList){
                if (i.ASI_GiftBox_Request_Item_Warehouse__c == inv.ASI_GiftBox_Item_Warehouse__c && i.ASI_GiftBox_Request_Item__c==inv.ASI_GiftBox_Item_Id__c){
                    //if (i.ASI_GiftBox_Request_Id__r.ASI_GiftBox_Status__c != 'Open' && i.ASI_GiftBox_Request_Id__r.ASI_GiftBox_Status__c != 'Reject'){
                        requestQty += i.ASI_GiftBox_Request_Quantity__c;
                    //}
                }             
            }
            inv.ASI_GiftBox_Item_Requested_Quantity__c = requestQty;
        }
        update inventoryWarehouseList;
    }
    
    /*public String checkAvaliable(){
        string r='';
        List<ASI_GiftBox_Request_Item__c> requestDetails= [select ASI_GiftBox_Request_Item__c,ASI_GiftBox_Request_Quantity__c from ASI_GiftBox_Request_Item__c where ASI_GiftBox_Request_Id__c =:headerid ];
        List <Id> requestProd=new List <Id>();
        for(ASI_GiftBox_Request_Item__c i : requestDetails){
            requestProd.Add(i.ASI_GiftBox_Request_Item__c);
        }
        
        List<ASI_GiftBox_Inventory_Master__c> requestProdInMaster=[select Id, Name,ASI_GiftBox_Item_Available_Quantity__c from ASI_GiftBox_Inventory_Master__c where Id= :requestProd];
        
        for(ASI_GiftBox_Request_Item__c i : requestDetails){
            for(ASI_GiftBox_Inventory_Master__c j :requestProdInMaster){
                if(i.ASI_GiftBox_Request_Item__c==j.Id){
                    if(i.ASI_GiftBox_Request_Quantity__c>j.ASI_GiftBox_Item_Available_Quantity__c)
                        r+=', '+j.Name;
                    break;
                }
            }
        }    
        return r;
    }*/
    
    private ASI_GiftBox_Notification_User__c getNotificationList(){
        User u=[select userroleid from user where id=:header.OwnerId limit 1][0];
        UserRole role=[select DeveloperName from UserRole where Id = :u.userroleid limit 1][0];
        ASI_GiftBox_Notification_User__c emailRecep
        = [select HR_User__c,Finance_User__c,MKT_User__c from ASI_GiftBox_Notification_User__c 
            where Id in (select Notification_Id__c from ASI_GiftBox_Notification_Mapping__c where ASI_GiftBox_Sales_Representative__c = :UserInfo.getUserId())
            limit 1][0];
         
        return emailRecep;
    }
    
}