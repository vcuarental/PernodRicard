public without sharing class EUR_CRM_FI_SelectOPPROSSegmentCtrl{ 

    public Boolean initialized {get;set;}

    public Id obProId {get;set;}

    public Boolean initDummyVar { get { if (initDummyVar != true) initDummyVar = init(); return initDummyVar; } set; }

    public List<String> outletImages {get;set;}
    public List<String> outletTypes {get;set;}

    public List<ObjectPromWrapper> opWrapList {get;set;}

    public Id recTypeId;

    public Boolean init(){
        if(obProId != null){
            recTypeId = [Select Id FROM RecordType WHERE SObjectType = 'EUR_CRM_ObjPromo_to_PROS_Segment_Mapping__c' AND DeveloperName = 'EUR_FI_OP_PROS_Segment_Mapping'].Id;

            outletImages = new List<String>();
            outletTypes = new List<String>();
            getOutletImages();
            getOutletTypes();
            createTable();
        }
        return true;
    }

    /*public EUR_CRM_FI_SelectOPPROSSegmentCtrl(){

        recTypeId = [Select Id FROM RecordType WHERE SObjectType = 'EUR_CRM_ObjPromo_to_PROS_Segment_Mapping__c' AND DeveloperName = 'EUR_FI_O_P_Promo_Activity'].Id;

        outletImages = new List<String>();
        outletTypes = new List<String>();
        getOutletImages();
        getOutletTypes();
        createTable();
    }*/

    public void getOutletImages(){

        Schema.DescribeFieldResult fieldResult = EUR_CRM_ObjPromo_to_PROS_Segment_Mapping__c.EUR_CRM_Image_Level__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry f : ple){
            outletImages.add(f.getLabel());
        }     
    }

    public void getOutletTypes(){

        Schema.DescribeFieldResult fieldResult = EUR_CRM_ObjPromo_to_PROS_Segment_Mapping__c.EUR_CRM_Group_Outlet_Type__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry f : ple){
            outletTypes.add(f.getLabel());
        }     
    }

    public void createTable(){

        System.debug('^^EXISTOBPR: '+obProId);

        Set<String> existingProsKey = new Set<String>();
        for(EUR_CRM_ObjPromo_to_PROS_Segment_Mapping__c existingOPPros : [SELECT Id, Name, EUR_CRM_Group_Outlet_Type__c, EUR_CRM_Image_Level__c, EUR_CRM_ObjPromo__c FROM EUR_CRM_ObjPromo_to_PROS_Segment_Mapping__c WHERE EUR_CRM_ObjPromo__c = :obProId]){
            existingProsKey.add(existingOPPros.EUR_CRM_Image_Level__c+':'+existingOPPros.EUR_CRM_Group_Outlet_Type__c);
        }

        System.debug('&&EXISTING: '+existingProsKey);

        opWrapList = new List<ObjectPromWrapper>();
        Integer opCtr = 1;
        for(String oImage : outletImages){
            for(String otype : outletTypes){
                String opWrapUnique = oImage+':'+otype;
                System.debug('&&EXISTING2: '+existingProsKey+' ----- '+opWrapUnique);
                if(existingProsKey.contains(opWrapUnique)){
                    opWrapList.add(new ObjectPromWrapper(true, opCtr, oImage, otype));
                } else{
                    opWrapList.add(new ObjectPromWrapper(false, opCtr, oImage, otype));
                }
                
                opCtr++;
            }   
        }
    }

    public PageReference saveOPPros(){

        deleteExistingOPPros();

        List<EUR_CRM_ObjPromo_to_PROS_Segment_Mapping__c> opProsToInsert = new List<EUR_CRM_ObjPromo_to_PROS_Segment_Mapping__c>();
        
        for(ObjectPromWrapper opWrap : opWrapList){
            if(opWrap.isSelected == true){
                EUR_CRM_ObjPromo_to_PROS_Segment_Mapping__c opProsSegment = new EUR_CRM_ObjPromo_to_PROS_Segment_Mapping__c();
                opProsSegment.EUR_CRM_ObjPromo__c = obProId;
                opProsSegment.EUR_CRM_Image_Level__c = opWrap.opOutletImage;
                opProsSegment.EUR_CRM_Group_Outlet_Type__c = opWrap.opOutletType;
                opProsSegment.RecordTypeId = recTypeId;

                opProsToInsert.add(opProsSegment);              
            }
        }

        if(opProsToInsert.size() > 0){
            insert opProsToInsert;
        }
        PageReference pageRef = new PageReference('/apex/EUR_CRM_FI_OPTargetMgmtPage?f=step2&id=' + obProId); 
        pageRef.setRedirect(true); 
        return pageRef;  
    }
    public PageReference saveOPProsContinue(){

        saveOPPros();
        PageReference pageRef = new PageReference('/apex/EUR_CRM_FI_OPTargetMgmtPage?f=step3&id=' + obProId); 
        pageRef.setRedirect(true); 
        return pageRef;  
    }

    public void deleteExistingOPPros(){
        List<EUR_CRM_ObjPromo_to_PROS_Segment_Mapping__c> toDeleteOPProsList = new List<EUR_CRM_ObjPromo_to_PROS_Segment_Mapping__c>();
        toDeleteOPProsList = [
                                SELECT 
                                    Id
                                FROM 
                                    EUR_CRM_ObjPromo_to_PROS_Segment_Mapping__c
                                WHERE
                                    EUR_CRM_ObjPromo__c
                                =
                                    :obProId
                                ];
        if(toDeleteOPProsList.size() > 0){
            delete toDeleteOPProsList;
        }
        delete [select id from EUR_CRM_ObjPromo_Target__c where EUR_CRM_ObjPromo__c =:  obProId];
    }

    public PageReference save(){
        saveOPPros(); 
        return cancel();  
    }  
    public PageReference cancel(){            
        PageReference pageRef = new PageReference('/' + obProId); 
        pageRef.setRedirect(true); 
        return pageRef;    
    }

    public class ObjectPromWrapper{

        public Boolean isSelected {get;set;}
        public Integer indexNumber {get;set;}
        public String opOutletImage {get;set;}
        public String opOutletType {get;set;}
        public String uniquekey {get;set;}

        public ObjectPromWrapper(Boolean isSelected, Integer indexNumber, String opOutletImage, String opOutletType){

            this.isSelected = isSelected;
            this.indexNumber = indexNumber;
            this.opOutletImage = opOutletImage;
            this.opOutletType = opOutletType;
            this.uniquekey = opOutletImage+':'+opOutletType;

        }
    }
}