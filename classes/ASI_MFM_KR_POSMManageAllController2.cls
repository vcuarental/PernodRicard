/*
+-----------------------+------------------------------------------------------------------------------------+
| Author                | Tony Ren                                                                  
+-----------------------+------------------------------------------------------------------------------------+
| Description           | For ASI Korea Brand Team user                                                                              
|                       |                                                                                    
|     - Object(s)       | POSM Order request                                                                             
|     - Description     | POSM manage all page                        
+-----------------------+------------------------------------------------------------------------------------+
| Creation Date         | 18/01/2017                                                                        
+-----------------------+------------------------------------------------------------------------------------+
| Modifications         |                                                                                    
+-----------------------+------------------------------------------------------------------------------------+
| Governor informations |                                                                                    
+-----------------------+------------------------------------------------------------------------------------+
*/
public class ASI_MFM_KR_POSMManageAllController2 {
    public transient String POSMDetailJSON {set;get;}{POSMDetailJSON=null;}
    public string RecordTypeID {get;set;}
    Public String Branch {get;set;}{Branch='';}
    
    public ASI_MFM_KR_POSMManageAllController2(ApexPages.StandardSetController stdSetController) {
        String posmReqHeaderId = ApexPages.currentPage().getParameters().get('id');
        //ASI_KOR_User_Branch_Code__c  ASI_KOR_User_Branch_Name__c  ,owner.ASI_KOR_User_Branch_Code__c 
        this.posmReqHeader = [SELECT Id,Name, ownerid, ASI_KOR_Request_Date__c, ASI_KOR_Status__c,ASI_MFM_Item_Category__c,ASI_KOR_Comment__c,
                              ASI_MFM_KR_Email_Sent__c,ASI_MFM_KR_EmailSentTime__c, ASI_KOR_POSM_TO_Venue__c,ASI_KOR_Requested_Date__c ,
                              ASI_KOR_POSM_TO_Venue__r.name,ASI_MFM_Sales_Branch__c 
                              FROM ASI_KOR_POSM_Order_Request__c WHERE Id = :posmReqHeaderId];
        User u=[select id,ASI_KOR_User_Branch_Code__c,ASI_KOR_User_Branch_Name__c from user where id=:posmReqHeader.ownerid];
        if(u.ASI_KOR_User_Branch_Code__c!=null){
            Branch=u.ASI_KOR_User_Branch_Code__c;
        }
    }
    public ASI_KOR_POSM_Order_Request__c posmReqHeader { get; set; }
    
    public pageReference init(){  
        RecordTypeID=Global_RecordTypeCache.getRtId('ASI_KOR_POSM_Order_Detail__cASI_MFM_KR_HV_POSM_Order_Detail');
        if(this.posmReqHeader !=null && this.posmReqHeader.Id !=null){
            List<ASI_KOR_POSM_Order_Detail__c>  POSMLines = [select id, name,ASI_MFM_Competitor_Brand__c,ASI_KOR_Supplier__c,ASI_MFM_Venue__r.name,ASI_MFM_KR_C_S__c,ASI_KOR_UOM__c,ASI_KOR_Ship_To_Address__c,
                                                             ASI_MFM_Venue__c,ASI_KOR_Remarks__c,ASI_KOR_Item_Name__r.ASI_MFM_Product_Owner__r.Name,
                                                             ASI_MFM_Venue__r.Owner.ASI_KOR_User_Branch_Name__c,ASI_MFM_Venue__r.Owner.ASI_KOR_User_Branch_Code__c,
                                                             ASI_KOR_POSM_Order_Request__c,ASI_KOR_Item_Name__r.ASI_MFM_Available_Qty__c,ASI_MFM_Venue__r.Owner.Name,
                                                             ASI_KOR_Item_Name__r.Name,ASI_KOR_SubBrand__r.Name,ASI_KOR_Item_Name__c,
                                                             ASI_MFM_Venue__r.ASI_KOR_Venue_Capacity__c,ASI_MFM_Total_PRK_Capa__c,
                                                             ASI_KOR_SubBrand__c,ASI_KOR_Quantity__c,ASI_MFM_Venue__r.ASI_KOR_Customer_Code__c,
                                                             ASI_KOR_Item_Name__r.ASI_MFM_Competitor_Brand__c,ASI_KOR_Item_Name__r.ASI_MFM_Sub_Brand__c,
                                                             ASI_KOR_Item_Name__r.ASI_MFM_Sub_Brand__r.Name  ,	ASI_KOR_Item_Name__r.ASI_MFM_UnitCost__c,
                                                             ASI_KOR_UnitCost__c
                                                             FROM ASI_KOR_POSM_Order_Detail__c  where ASI_KOR_POSM_Order_Request__c=:posmReqHeader.Id];
         
            set<String> VenueIDSet=new set<String>();
            for(ASI_KOR_POSM_Order_Detail__c posml: POSMLines){
                VenueIDSet.add(posml.ASI_MFM_Venue__c);
            }
            
            
            
            Map<ID, ASI_CRM_AccountsAdditionalField__c> mapCustomer = new Map<ID,ASI_CRM_AccountsAdditionalField__c>();
            List<ASI_CRM_AccountsAdditionalField__c> CustomerList = [select Id,Name,ASI_CRM_Account__c,ASI_CRM_Outlet_Image__c from ASI_CRM_AccountsAdditionalField__c
                                                                   where ASI_CRM_Account__c in : VenueIDSet and RecordType.DeveloperName like 'ASI_CRM_KR%' ];
            for(ASI_CRM_AccountsAdditionalField__c cus:CustomerList){
                if(!mapCustomer.containsKey(cus.ASI_CRM_Account__c)){
                    mapCustomer.put(cus.ASI_CRM_Account__c, cus);
                }
            }
             
            
            //system.assertEquals(null, VenueIDSet); // aBpL00000008QQ7KAM
            for(ASI_KOR_POSM_Order_Detail__c posml:POSMLines){
                if(posml.ASI_KOR_Item_Name__r.ASI_MFM_UnitCost__c!=null && posml.ASI_KOR_UnitCost__c==null){
                    posml.ASI_KOR_UnitCost__c = posml.ASI_KOR_Item_Name__r.ASI_MFM_UnitCost__c;
                }
                
                if(posml.ASI_MFM_Venue__c!=null && mapCustomer.containsKey(posml.ASI_MFM_Venue__c)){
                    posml.ASI_KOR_UOM__c=mapCustomer.get(posml.ASI_MFM_Venue__c).ASI_CRM_Outlet_Image__c;
                }else{
                    posml.ASI_KOR_UOM__c='';
                }
            }
            
            POSMDetailJSON=JSON.serialize(POSMLines);
        }
        
        return null;
    }
    
    public PageReference BackHeader() {
        return  new PageReference('/' + posmReqHeader.Id); 
    }
    
    
    
    @RemoteAction
    public static string UpdateLineItem(List<ASI_KOR_POSM_Order_Detail__c> Linelist,List<string> deletelist){
        //Linelist for upsert 
        string Mesg='';
        set<string> lineIdSet =new set<string>();
        for(string pid:deletelist){
            lineIdSet.add(pid);
        }
        
        Set<id> ItemIDSet= new Set<id>();
        //Change unit price 
        for(ASI_KOR_POSM_Order_Detail__c posmdetail:Linelist){
            if(posmdetail.ASI_KOR_Item_Name__c!=null){
                ItemIDSet.add(posmdetail.ASI_KOR_Item_Name__c);
            }
        }
        
        Map<ID, ASI_KOR_POSM_Product__c> ItemMap = new Map<ID,ASI_KOR_POSM_Product__c>([SELECT ID, Name,ASI_MFM_UnitCost__c FROM ASI_KOR_POSM_Product__c WHERE Id in :ItemIDSet ]);
        
        for(ASI_KOR_POSM_Order_Detail__c posmdetail:Linelist){
            if(posmdetail.ASI_KOR_Item_Name__c!=null && ItemMap.containsKey(posmdetail.ASI_KOR_Item_Name__c)){
                posmdetail.ASI_KOR_UnitCost__c=ItemMap.get(posmdetail.ASI_KOR_Item_Name__c).ASI_MFM_UnitCost__c;
                try{
                    posmdetail.ASI_KOR_TotalAmount__c=posmdetail.ASI_KOR_UnitCost__c*posmdetail.ASI_KOR_Quantity__c;
                }catch(Exception e){
                    Mesg+=e.getMessage() ;
                }
            }
        }
        
        try{
            List<ASI_KOR_POSM_Order_Detail__c> DeleteLines=[select Id,Name from ASI_KOR_POSM_Order_Detail__c where id in : lineIdSet];
            if(DeleteLines.size()>0){
                delete DeleteLines;
            }
            
            upsert Linelist;
            
            Mesg+='Save Success !';
        }catch(Exception e){
            Mesg+=e.getMessage() ;
            ASI_MFM_ByPass_Setting.ErrorHandling(Mesg,'ASI_MFM_KR_POSMManageAllPage2','Sending Email');
        }
        
        return Mesg;
    }
    
    @RemoteAction
    public static List<sObject> findList(string obj,string statement, string qry)
    {
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
        Schema.SObjectType sot = gd.get(obj);
        if (sot == null)
        {
            // Object name not valid
            return null;
        }//end if
        
        // create the filter text
        String filter = qry;
        
        //begin building the dynamic soql query
        String soql;
        if(filter != '' || filter != null)
            soql = 'select '+statement+' from ' + obj + filter +' order by Name';
        else
            soql = 'select '+statement+' from ' + obj +' order by Name';
        
        List<sObject> sobjs = new List<sObject>();
        
        List<String> results = new List<String>();
        
        System.debug('soql:' + soql);
        
        try
        {
            SYSTEM.debug('tEST SQL ANTO COMPLETE: '+soql);
            sobjs = Database.query(soql);
            return sobjs; 
        }//end try
        catch (QueryException e)
        {
            return null;
        }//end catch
        return sobjs;
    }
    
    
    
    
    
}