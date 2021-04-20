/*********************************************************************************
     * Name:ASI_CRM_VN_AccountPlanClass
     * Description: Component Controller for displaying service pack and service pack item details
     *
     * Version History
     * Date             Developer               Comments
     * ---------------  --------------------    -------------------------------------------------------
     * 19/10/2015       Laputa: Neha             Created
*********************************************************************************/



public with sharing class ASI_CRM_VN_AccountPlanClass {
     
        private ApexPages.StandardController standardController{get;set;}
        public ASI_CRM_ServicePack__c serPackObj{get;set;}
        public ASI_CRM_AccountsAdditionalField__c customer{get;set;}
        
        public String presenceValues{get;set;}
        public String visibilityValues{get;set;}
        public String activationValues{get;set;}
        
        public ASI_CRM_VN_AccountPlanClass(ApexPages.StandardController standardController){

            this.standardController = standardController;
            presenceValues = '';
            visibilityValues = '';
            activationValues = '';
            customer = (ASI_CRM_AccountsAdditionalField__c)standardController.getRecord();
            //Get current Customer Id
            customer = [select Id, ASI_CRM_Service_Pack__c, ASI_CRM_SG_Image_Level__c from ASI_CRM_AccountsAdditionalField__c where Id = : customer.Id];
            serPackObj = new ASI_CRM_ServicePack__c();
            
            //Get service pack related to Customer Id
            serPackObj = [select Id,
                                ASI_CRM_SG_Outlet_Type__c,
                                ASI_CRM_SG_Sub_Outlet_Type__c,
                                ASI_CRM_SG_DAMD_Action__c,
                                ASI_CRM_No_of_PG_in_one_outlet__c,
                                ASI_CRM_No_of_Signage_per_outlet__c,
                                ASI_CRM_No_of_VIP_room__c,
                                ASI_CRM_No_of_Podium_stand__c,
                                ASI_CRM_No_of_Glorifier__c,
                                ASI_CRM_No_of_Dummy_Bots__c,
                                ASI_CRM_No_of_PG_uniform__c,
                                ASI_CRM_No_of_Glassware__c,
                                ASI_CRM_No_of_Dice_Dice_Cup__c,
                                ASI_CRM_No_of_Drink_menus__c,
                                ASI_CRM_No_of_Promotion_activiti_per_yr__c,
                                ASI_CRM_Incentives_US_year__c,
                                ASI_CRM_SG_Segmentation__c,
                                ASI_CRM_CallFrequency__c,
                                ASI_CRM_CallLength__c
                                from ASI_CRM_ServicePack__c where Id =: customer.ASI_CRM_Service_Pack__c
                        ];
            
            system.debug('=======customer===='+customer.Id);
           
            //Get service pack items
            getServicePackItems();
           

        }
        
        public void getServicePackItems(){
            list<ASI_CRM_ServicePackItem__c> lstSerPackItem = new list<ASI_CRM_ServicePackItem__c>();
            lstSerPackItem = [select Id,
                            ASI_CRM_SG_Act_Vis__c,
                            ASI_CRM_Sub_brand_Code__c,
                            ASI_CRM_ServicePack__c
                            from ASI_CRM_ServicePackItem__c
                            WHERE ASI_CRM_ServicePack__c =:serPackObj.Id];
            system.debug('************SerPackItems ********'+lstSerPackItem );                
            for(ASI_CRM_ServicePackItem__c objSerPackItem : lstSerPackItem){
                if(!String.isBlank(objSerPackItem.ASI_CRM_Sub_brand_Code__c)){
                    if(objSerPackItem.ASI_CRM_SG_Act_Vis__c.equals('Presence')){
                        presenceValues += objSerPackItem.ASI_CRM_Sub_brand_Code__c + ',';
                        
                    }
                    if(objSerPackItem.ASI_CRM_SG_Act_Vis__c.equals('Visibility')){
                        visibilityValues += objSerPackItem.ASI_CRM_Sub_brand_Code__c + ',';
                        
                    }
                    if(objSerPackItem.ASI_CRM_SG_Act_Vis__c.equals('Activation')){
                        activationValues += objSerPackItem.ASI_CRM_Sub_brand_Code__c + ',';
                        
                    }
                }
            }
            presenceValues = presenceValues.removeEnd(',');
            visibilityValues = visibilityValues.removeEnd(',');
            activationValues = activationValues.removeEnd(',');

        }
        
        public PageReference gotoProsSegmentation(){
            PageReference pageRef = new PageReference('/'+ ApexPages.currentPage().getParameters().get('id'));
            pageRef.setRedirect(true);
            
            return pageRef;
        }
        
}