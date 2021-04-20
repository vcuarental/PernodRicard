/******************************************************************************
Developed by Kevani Chow@introv
Developed Date: 05-04-2016
Description: For create/update Actual Offtakes of Subbands of Actual Offtake Header 
             with WS copy and Outlet copy(Form 1)
******************************************************************************/

public without sharing class ASI_CRM_TH_ActualOfftake_Ctrl {
    public List<SubBrand> SubBrandList {get; set;}
    public List<SubBrand> SubBrandList1 {get; set;}
    public List<SubBrand> SubBrandList2 {get; set;}
    public List<SubBrand> SubBrandList3 {get; set;}
    public ASI_CRM_ActualOfftakeHeader__c ActualOfftakeHeader {get; set;}
    public Set<String> setSubBrandKey {get; set;}
    
    //For Search result
    Public List<ASI_CRM_ActualOfftakeHeader__c> OfftakeHeader= new List<ASI_CRM_ActualOfftakeHeader__c>();
    Public List<ASI_TH_CRM_Actual_Offtake__c> listQueryOffTake = new List<ASI_TH_CRM_Actual_Offtake__c>();
    
    //For SaveAction to check whether actual offtake header exists
    Public List<ASI_CRM_ActualOfftakeHeader__c> ExistingOfftakeHeader= new List<ASI_CRM_ActualOfftakeHeader__c>();

    Public boolean editable {get; set;}
    Public Map<String, ASI_TH_CRM_Actual_Offtake__c> mapSubBrandKey = new Map<String, ASI_TH_CRM_Actual_Offtake__c>();
    public ASI_CRM_TH_ActualOfftake_Ctrl (ApexPages.StandardController controller) {    
        ActualOfftakeHeader = new ASI_CRM_ActualOfftakeHeader__c();         
        editable=true;   
    }
    
    public void search(){
        SubBrandList = new List<SubBrand>();
        mapSubBrandKey = new Map<String, ASI_TH_CRM_Actual_Offtake__c>();
        
        Id RecordTypeId = Global_RecordTypeCache.getRTId('ASI_CRM_ActualOfftakeHeader__cASI_CRM_TH_ActualOfftakeHeader');
        String querySoql = 'SELECT ASI_CRM_Book_ID__c,  ASI_CRM_Branch__c, ASI_CRM_Document_ID__c, ASI_CRM_Invoice_Month__c, ASI_CRM_OfftakeDate__c, ASI_CRM_Outlet__r.Id, ASI_CRM_Status__c, ASI_CRM_ToOutlet__r.Id, ASI_CRM_MY_Unlock_Trail__c, ASI_CRM_Wholesaler__r.Id, ASI_CRM_Verified__c, Name, OwnerId, Id, RecordTypeId FROM ASI_CRM_ActualOfftakeHeader__c WHERE RecordTypeId ='+ '\'' +RecordTypeId+ '\'';
         
        If (!String.IsEmpty(ActualOfftakeHeader.ASI_CRM_Document_ID__c) && !String.IsEmpty(ActualOfftakeHeader.ASI_CRM_Book_ID__c)){        
            querySoql= querySoql+ 'AND ASI_CRM_Document_ID__c =' +'\''+ActualOfftakeHeader.ASI_CRM_Document_ID__c+'\'' +'AND ASI_CRM_Book_ID__c=' + '\''+ActualOfftakeHeader.ASI_CRM_Book_ID__c+'\'';          
            OfftakeHeader = Database.query(querySoql);  
        }
        system.debug('OfftakeHeader: '+OfftakeHeader);
        
        If (OfftakeHeader.size()>0){
            //As BookId and DocumentId must be unique, first record of the list will be shown
            ActualOfftakeHeader.ASI_CRM_OfftakeDate__c=OfftakeHeader[0].ASI_CRM_OfftakeDate__c;
            ActualOfftakeHeader.ASI_CRM_Outlet__c=OfftakeHeader[0].ASI_CRM_Outlet__r.Id;
            ActualOfftakeHeader.ASI_CRM_Wholesaler__c=OfftakeHeader[0].ASI_CRM_Wholesaler__r.Id;
            
          if(OfftakeHeader[0].ASI_CRM_Verified__c==true){  
                editable=false;
            }else{
                System.debug('editable should be true');
                editable =true;
            }
            
        }else{
            editable =true;
            ActualOfftakeHeader.ASI_CRM_OfftakeDate__c=null;
            ActualOfftakeHeader.ASI_CRM_Outlet__c=null;
            ActualOfftakeHeader.ASI_CRM_Wholesaler__c=null;
        }
          
          
        //Map Subbrand with Actual Offtake
        Id SubbrandRecordTypeId = Global_RecordTypeCache.getRTId('ASI_MFM_Sub_brand__cASI_TH_CRM_Sub_brand'); 
        String subBrandquerySoql = 'SELECT Id, Name, ASI_HK_CRM_English_Name__c, ASI_CRM_TW_Company__c,ASI_CRM_TW_Sequence_Company__c,ASI_CRM_TW_Sequence_Sub_brand__c FROM ASI_MFM_Sub_brand__c WHERE ASI_CRM_Form_1_Input__c = True ';
        subBrandquerySoql = subBrandquerySoql + 'AND RecordTypeId ='+ '\'' +SubbrandRecordTypeId+ '\''+'ORDER BY ASI_CRM_TW_Sequence_Sub_brand__c, ASI_HK_CRM_English_Name__c';
        List<ASI_MFM_Sub_brand__c> subBrands = Database.query(subBrandquerySoql);
        
        setSubBrandKey = new set<String>();
        for(ASI_MFM_Sub_brand__c subBrand : subBrands){
            setSubBrandKey.add(subBrand.Id);
        }
        
        String offtakequerySoql = '';
        if(OfftakeHeader.size()>0){
            Id OfftakeRecordTypeId = Global_RecordTypeCache.getRTId('ASI_TH_CRM_Actual_Offtake__cASI_CRM_TH_ActualOfftakeTemp');
            Id OfftakeVerifiedRecordTypeId = Global_RecordTypeCache.getRTId('ASI_TH_CRM_Actual_Offtake__cASI_TH_CRM_Actual_Offtake');

            offtakequerySoql = 'SELECT id, ASI_TH_CRM_Sub_brand__c,ASI_CRM_Outlet_Copy__c, ASI_CRM_WS_Copy__c, ASI_TH_CRM_Quantity__c, ASI_CRM_ActualOfftakeHeader__c, ASI_CRM_ActualOfftakeHeader__r.ASI_CRM_Verified__c, recordtype.name FROM ASI_TH_CRM_Actual_Offtake__c WHERE ASI_TH_CRM_Sub_brand__c IN: setSubBrandKey AND (RecordTypeId ='+ '\'' +OfftakeRecordTypeId+ '\' OR RecordTypeId =' + '\'' +OfftakeVerifiedRecordTypeId+ '\')';
            offtakequerySoql = offtakequerySoql + ' AND ASI_CRM_ActualOfftakeHeader__r.Id=' +'\''+OfftakeHeader[0].Id+'\'';
        }
        
        if(setSubBrandKey.size()>0){
            if(!String.IsEmpty(offtakequerySoql))
                listQueryOffTake = Database.query(offtakequerySoql);
            for (ASI_TH_CRM_Actual_Offtake__c offtake: listQueryOffTake){     
                mapSubBrandKey.put(offtake.ASI_TH_CRM_Sub_brand__c, offtake);
            }
        }

        Integer index = 0;
        for(ASI_MFM_Sub_brand__c subBrandrecord : subBrands){
            SubBrand subBrand = new SubBrand(); 
            subBrand.objActualOfftake = new ASI_TH_CRM_Actual_Offtake__c();       

            subBrand.subBrand = subBrandrecord.ASI_HK_CRM_English_Name__c;
            subBrand.index = ++index; 
            subBrand.subBrandId = subBrandrecord.Id;
            subBrand.objActualOfftake.ASI_CRM_WS_Copy__c=null;
            subBrand.objActualOfftake.ASI_CRM_Outlet_Copy__c=null;
            
            if (mapSubBrandKey.get(subBrandrecord.Id)!=null && OfftakeHeader.size()>0){
                //subBrand.outletcopyno = mapSubBrandKey.get(subBrandrecord.Id).ASI_CRM_Outlet_Copy__c;
                //subBrand.wscopyno = mapSubBrandKey.get(subBrandrecord.Id).ASI_CRM_WS_Copy__c;
                    
                subBrand.objActualOfftake.ASI_CRM_Outlet_Copy__c = mapSubBrandKey.get(subBrandrecord.Id).ASI_CRM_Outlet_Copy__c;
                subBrand.objActualOfftake.ASI_CRM_WS_Copy__c = mapSubBrandKey.get(subBrandrecord.Id).ASI_CRM_WS_Copy__c;
                subBrand.offtakeId = mapSubBrandKey.get(subBrandrecord.Id).id;

                if(mapSubBrandKey.get(subBrandrecord.Id).ASI_TH_CRM_Quantity__c==null && editable==true){
                    subBrand.editable=true;
                }else{
                    subBrand.editable=false;
                }
            }
            else if(editable==true){
                //subBrand.wscopyno = null;
                //subBrand.outletcopyno=null;
                //subBrand.objActualOfftake.ASI_CRM_WS_Copy__c=null;
                //subBrand.objActualOfftake.ASI_CRM_Outlet_Copy__c=null;
                subBrand.editable=true;
            }
                        
            SubBrandList.add(subBrand);
            system.debug(SubBrandList);
        } 
        
        /*Added by Twinkle @20160519*/
        SubBrandList1 = new List<SubBrand>();
        SubBrandList2 = new List<SubBrand>();
        SubBrandList3 = new List<SubBrand>();
        
        integer recordIndex = 1;
        integer set1Index = SubBrandList.size()/3;
        integer set2Index = set1Index + SubBrandList.size()/3;
        
        if(math.mod(SubBrandList.size(), 3) != 0){
            set1Index = SubBrandList.size()/3 +1;
            if(math.mod(SubBrandList.size(), 3) == 2)
                set2Index = set1Index + SubBrandList.size()/3 +1;
        }
        
        for(SubBrand sb: SubBrandList){
            if(recordIndex <= set1Index)
                SubBrandList1.add(sb);
            else if(recordIndex > set1Index && recordIndex <= set2Index)
                SubBrandList2.add(sb);
            else
                SubBrandList3.add(sb);
            recordIndex++;
        }
        system.debug('Sub-Brand List 1 size: '+SubBrandList1.size());
        system.debug('Sub-Brand List 2 size: '+SubBrandList2.size());
        system.debug('Sub-Brand List 3 size: '+SubBrandList3.size());
        /*Added by Twinkle @20160519*/
 
    }
    
    public void saveAction(){
        Boolean blnIsErr = false;
        /*Map<Id, Decimal> mapWScopy = new Map<Id, Decimal>();
        Map<Id, Decimal> mapOutletCopy = new Map<Id, Decimal>();*/
             
        /*SubBrandList = new List<SubBrand>();
        SubBrandList = SubBrandList1;
        for(SubBrand sb : SubBrandList2){
            SubBrandList.add(sb);
        }
        for(SubBrand sb : SubBrandList3){
            SubBrandList.add(sb);
        }*/
        
        system.debug('SubBrandList: '+SubBrandList);
        system.debug('ActualOfftakeHeader: '+ActualOfftakeHeader);
        
        ASI_CRM_ActualOfftakeHeader__c insertOffTakeHeader = new ASI_CRM_ActualOfftakeHeader__c();
       
       //if no header exist, create a new one
        Id RecordTypeId = Global_RecordTypeCache.getRTId('ASI_CRM_ActualOfftakeHeader__cASI_CRM_TH_ActualOfftakeHeader');
        String querySoql = 'SELECT ASI_CRM_Book_ID__c,  ASI_CRM_Branch__c, ASI_CRM_Document_ID__c, ASI_CRM_Invoice_Month__c, ASI_CRM_OfftakeDate__c, ASI_CRM_Outlet__r.Id, ASI_CRM_Status__c, ASI_CRM_ToOutlet__r.Id, ASI_CRM_MY_Unlock_Trail__c, ASI_CRM_Wholesaler__r.Id, ASI_CRM_Verified__c, Name, OwnerId, Id, RecordTypeId FROM ASI_CRM_ActualOfftakeHeader__c WHERE RecordTypeId ='+ '\'' +RecordTypeId+ '\'' ;
         
        If (!String.IsEmpty(ActualOfftakeHeader.ASI_CRM_Document_ID__c) && !String.IsEmpty(ActualOfftakeHeader.ASI_CRM_Book_ID__c)){
            querySoql= querySoql+ 'AND ASI_CRM_Document_ID__c =' +'\''+ActualOfftakeHeader.ASI_CRM_Document_ID__c+'\'' +'AND ASI_CRM_Book_ID__c=' + '\''+ActualOfftakeHeader.ASI_CRM_Book_ID__c+'\'';   
            ExistingOfftakeHeader = Database.query(querySoql);
        }
        system.debug('ExistingOfftakeHeader: '+ExistingOfftakeHeader);
        
        insertOffTakeHeader.RecordTypeId = Global_RecordTypeCache.getRTId('ASI_CRM_ActualOfftakeHeader__cASI_CRM_TH_ActualOfftakeHeader');
          
        //check if the record is editable
        if (ExistingOfftakeHeader.size()>0){
            //Added by Twinkle @20160614 - to get updated offtake data
            /*Id OfftakeRecordTypeId = Global_RecordTypeCache.getRTId('ASI_TH_CRM_Actual_Offtake__cASI_CRM_TH_ActualOfftakeTemp');
            Id OfftakeVerifiedRecordTypeId = Global_RecordTypeCache.getRTId('ASI_TH_CRM_Actual_Offtake__cASI_TH_CRM_Actual_Offtake');
            String newofftakequerySoql = 'SELECT id, ASI_TH_CRM_Sub_brand__c,ASI_CRM_Outlet_Copy__c, ASI_CRM_WS_Copy__c, ASI_TH_CRM_Quantity__c, ASI_CRM_ActualOfftakeHeader__c, ASI_CRM_ActualOfftakeHeader__r.ASI_CRM_Verified__c FROM ASI_TH_CRM_Actual_Offtake__c WHERE ASI_TH_CRM_Sub_brand__c IN: setSubBrandKey AND (RecordTypeId ='+ '\'' +OfftakeRecordTypeId+ '\' OR RecordTypeId =' + '\'' +OfftakeVerifiedRecordTypeId+ '\')';
            newofftakequerySoql = newofftakequerySoql + ' AND ASI_CRM_ActualOfftakeHeader__r.Id=' +'\''+ExistingOfftakeHeader[0].Id+'\'';
            List<ASI_TH_CRM_Actual_Offtake__c> listQueryNewOffTake = Database.query(newofftakequerySoql);
             
            for (ASI_TH_CRM_Actual_Offtake__c offtake: listQueryNewOffTake){                       
                mapWScopy.put(offtake.ASI_TH_CRM_Sub_brand__c, offtake.ASI_CRM_WS_Copy__c);
                mapOutletCopy.put(offtake.ASI_TH_CRM_Sub_brand__c, offtake.ASI_CRM_Outlet_Copy__c);
            }*/
            //End by Twinkle @20160614
            
			Id OfftakeVerifiedRecordTypeId = Global_RecordTypeCache.getRTId('ASI_TH_CRM_Actual_Offtake__cASI_TH_CRM_Actual_Offtake');
			String newofftakequerySoql = 'SELECT id, name FROM ASI_TH_CRM_Actual_Offtake__c WHERE ASI_TH_CRM_Sub_brand__c IN: setSubBrandKey AND (RecordTypeId ='+ '\'' +OfftakeVerifiedRecordTypeId+ '\')';
            newofftakequerySoql = newofftakequerySoql + ' AND ASI_CRM_ActualOfftakeHeader__r.Id=' +'\''+ExistingOfftakeHeader[0].Id+'\'';
            List<ASI_TH_CRM_Actual_Offtake__c> listQueryNewOffTake = Database.query(newofftakequerySoql);
			
            if(ExistingOfftakeHeader[0].ASI_CRM_Verified__c==true){
                editable = false;
            }else{
                editable = true;
            } 
			
			if (listQueryNewOffTake.size() > 0 && ExistingOfftakeHeader[0].ASI_CRM_Outlet__r.Id != ActualOfftakeHeader.ASI_CRM_Outlet__c) {
				editable = false;
				ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'There is at least one verified actual offtake record for current Book Id and Document Id combination. Cannot modify Outlet'));
			}
			if (listQueryNewOffTake.size() > 0 && ExistingOfftakeHeader[0].ASI_CRM_Wholesaler__r.Id != ActualOfftakeHeader.ASI_CRM_Wholesaler__c) {
				editable = false;
				ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'There is at least one verified actual offtake record for current Book Id and Document Id combination. Cannot modify Wholesaler'));
			}
			
          }else{
              editable = true;
          }
        if(apexpages.currentpage().geturl().contains('ASI_CRM_TH_ActualOfftake_WSCopy_Page') && (String.IsEmpty(ActualOfftakeHeader.ASI_CRM_Wholesaler__c) || ActualOfftakeHeader.ASI_CRM_OfftakeDate__c==null)) {
	        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'"Offtake Date", and "Wholesaler" are required to save the record.'));
        }else if (apexpages.currentpage().geturl().contains('ASI_CRM_TH_ActualOfftake_OutletCopy_Page') && (String.IsEmpty(ActualOfftakeHeader.ASI_CRM_Outlet__c) || ActualOfftakeHeader.ASI_CRM_OfftakeDate__c==null)) {
	        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'"Offtake Date", and "Outlet" are required to save the record.'));
        }else if(ActualOfftakeHeader.ASI_CRM_OfftakeDate__c!=null && (!String.IsEmpty(ActualOfftakeHeader.ASI_CRM_Outlet__c) || !String.IsEmpty(ActualOfftakeHeader.ASI_CRM_Wholesaler__c))){
               if(ExistingOfftakeHeader.size()>0){
                   system.debug('Header size>0: '+ExistingOfftakeHeader.size());
                   if(editable == true){
                       //Update Existing Record
                       insertOffTakeHeader.id=ExistingOfftakeHeader[0].id;
                       insertOffTakeHeader.ASI_CRM_Book_ID__c = ActualOfftakeHeader.ASI_CRM_Book_ID__c;
                       insertOffTakeHeader.ASI_CRM_Document_ID__c = ActualOfftakeHeader.ASI_CRM_Document_ID__c;
                       insertOffTakeHeader.ASI_CRM_OfftakeDate__c = ActualOfftakeHeader.ASI_CRM_OfftakeDate__c;
                       insertOffTakeHeader.ASI_CRM_Outlet__c = ActualOfftakeHeader.ASI_CRM_Outlet__c;
                       insertOffTakeHeader.ASI_CRM_Wholesaler__c = ActualOfftakeHeader.ASI_CRM_Wholesaler__c;
                   
                       update insertOffTakeHeader;
                       
                       system.debug('updated: '+insertOffTakeHeader);
                       
                    }else{
                           ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'The Actual Offtake Header cannot be edited.'));
                    }
                }else{
                      //Insert New Record
                       
                       insertOffTakeHeader.ASI_CRM_Book_ID__c = ActualOfftakeHeader.ASI_CRM_Book_ID__c;
                       insertOffTakeHeader.ASI_CRM_Document_ID__c = ActualOfftakeHeader.ASI_CRM_Document_ID__c;
                       insertOffTakeHeader.ASI_CRM_OfftakeDate__c = ActualOfftakeHeader.ASI_CRM_OfftakeDate__c;
                       insertOffTakeHeader.ASI_CRM_Outlet__c = ActualOfftakeHeader.ASI_CRM_Outlet__c;
                       insertOffTakeHeader.ASI_CRM_Wholesaler__c = ActualOfftakeHeader.ASI_CRM_Wholesaler__c;
                   
                       Insert insertOffTakeHeader;
                       
                       system.debug('Inserted: '+insertOffTakeHeader);
                    }
                }else if(ExistingOfftakeHeader.size()==0){
                    blnIsErr = true;
                    //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'"Offtake Date", and "Outlet" or "Wholesaler" are required to save the record.'));
					ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Mandatory Fields are missing.'));
                }

       //Upsert Actual Offtake of Subbrand
       List<ASI_TH_CRM_Actual_Offtake__c> upsertOffTake = new  List<ASI_TH_CRM_Actual_Offtake__c>();
       
      system.debug('SubBrandList: '+SubBrandList);
      if(SubBrandList != NULL){
          for (SubBrand subBrandinput : SubBrandList){
               //if (subBrandinput.offtakeId!=null || (subBrandinput.offtakeId==null && ((subBrandinput.wscopyno!=null && subBrandinput.wscopyno!=0)||(subBrandinput.outletcopyno!=null && subBrandinput.outletcopyno!=0)))){
            if (subBrandinput.offtakeId!=null || (subBrandinput.offtakeId==null && ((subBrandinput.objActualOfftake.ASI_CRM_WS_Copy__c!=null && subBrandinput.objActualOfftake.ASI_CRM_WS_Copy__c!=0)||(subBrandinput.objActualOfftake.ASI_CRM_Outlet_Copy__c!=null && subBrandinput.objActualOfftake.ASI_CRM_Outlet_Copy__c!=0)))){
                ASI_TH_CRM_Actual_Offtake__c actualOffTake = new ASI_TH_CRM_Actual_Offtake__c();
                
                system.debug('insertOffTakeHeader.id: '+insertOffTakeHeader.id);
                
                actualOffTake.id = subBrandinput.offtakeId;
                actualOffTake.RecordTypeId = Global_RecordTypeCache.getRTId('ASI_TH_CRM_Actual_Offtake__cASI_CRM_TH_ActualOfftakeTemp');
                
                if(OfftakeHeader.size()>0){
                    actualOffTake.ASI_CRM_ActualOfftakeHeader__c=OfftakeHeader[0].id;  
                }else{
                    if(insertOffTakeHeader!=null)
                        actualOffTake.ASI_CRM_ActualOfftakeHeader__c=insertOffTakeHeader.id;
                }
    
                //system.debug('OfftakeHeader: '+OfftakeHeader[0].id);
                actualOffTake.ASI_TH_CRM_Outlet__c=insertOffTakeHeader.ASI_CRM_Outlet__c;
                actualOffTake.ASI_TH_CRM_From_Wholesaler__c=insertOffTakeHeader.ASI_CRM_Wholesaler__c;
                
                
                //actualOffTake.ASI_CRM_Outlet_Copy__c = subBrandinput.outletcopyno;
                //actualOffTake.ASI_CRM_WS_Copy__c = subBrandinput.wscopyno;
                if (apexpages.currentpage().geturl().contains('ASI_CRM_TH_ActualOfftake_OutletCopy_Page')){
                    actualOffTake.ASI_CRM_Outlet_Copy__c = subBrandinput.objActualOfftake.ASI_CRM_Outlet_Copy__c;
                    //if(mapWScopy != null)
                    //   actualOffTake.ASI_CRM_WS_Copy__c = mapWScopy.get(subBrandinput.subBrandId);
                }
                if (apexpages.currentpage().geturl().contains('ASI_CRM_TH_ActualOfftake_WSCopy_Page')){
                    actualOffTake.ASI_CRM_WS_Copy__c = subBrandinput.objActualOfftake.ASI_CRM_WS_Copy__c;
                    //if(mapOutletcopy != null)
                    //    actualOffTake.ASI_CRM_Outlet_Copy__c = mapOutletcopy.get(subBrandinput.subBrandId);
                }
                actualOffTake.ASI_TH_CRM_Sub_brand__c = subBrandinput.subBrandId;
                actualOffTake.ASI_TH_CRM_Offtake_G_L_Date__c = ActualOfftakeHeader.ASI_CRM_OfftakeDate__c;
                
                //Added by Twinkle @20160614
                actualOffTake.ASI_TH_CRM_Actual_Offtake_External_ID__c = insertOffTakeHeader.ASI_CRM_Book_ID__c+'_'+
                                                                         insertOffTakeHeader.ASI_CRM_Document_ID__c+'_'+
                                                                         subBrandinput.subBrandId;
               
                if (subBrandinput.editable == true)
                    upsertOffTake.add(actualOffTake);
                }//else{
                    //Added By Kevani Chow@Introv to solve display 0 problem
                    //subBrandinput.outletcopyno=null;
                    //subBrandinput.wscopyno=null;
                    //subBrandinput.objActualOfftake.ASI_CRM_Outlet_Copy__c=null;
                    //subBrandinput.objActualOfftake.ASI_CRM_WS_Copy__c=null;
                //}
            }
            //upsert upsertOffTake;
            //Added by Twinkle @20160614 - To upsert offtake by external Id (Book Id + Document Id + SubBrand)
            Schema.SObjectField extfield = ASI_TH_CRM_Actual_Offtake__c.Fields.ASI_TH_CRM_Actual_Offtake_External_ID__c ;
            Database.UpsertResult [] listUpsertResults = Database.upsert(upsertOffTake, extfield, false);
            
            if(!blnIsErr){
                search();
            }
            system.debug(listUpsertResults);
            system.debug('upsertOffTake: '+upsertOffTake);
        }
    }
    
    public class SubBrand{
        public String subBrand {get; set;}
        public String subBrandId {get; set;}
        public String offtakeId {get; set;}
        public Integer index {get; set;}
        //public Decimal outletcopyno {get; set;}
        //public Decimal wscopyno {get; set;}
        public Boolean editable {get;set;}
        
        public ASI_TH_CRM_Actual_Offtake__c objActualOfftake{get;set;}
    }
}