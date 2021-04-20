@isTest
public with sharing class EUR_DOC_Factory {
    public static EUR_CRM_Menu_Feature__c newMenu(Id accId) {
        return new EUR_CRM_Menu_Feature__c(
            EUR_CRM_Account__c = accId
        );
    }
    public static EUR_CRM_Menu_Feature_Items__c newMenuItem(Id menuId, Id productId) {
        return new EUR_CRM_Menu_Feature_Items__c(
            EUR_CRM_Menu_Feature__c = menuId,
            EUR_CRM_Brand_Quality__c = productId
        );
    }
    public static EUR_CRM_Visit_Action__c newVisitAction(Id accId, Id productId, Id visitId) {
        EUR_CRM_Visit_Action__c va = new EUR_CRM_Visit_Action__c(
            RecordTypeId = Schema.SObjectType.EUR_CRM_Visit_Action__c.getRecordTypeInfosByName().get('EUR DE Visit Action Off Trade Ad Hoc Promo').getRecordTypeId(),
            EUR_CRM_Account__c = accId,
            EUR_CRM_Visit_ID__c = visitId
        );
        if(productId.getsobjecttype() == new EUR_CRM_Product_Toolkit__c().getsobjecttype()) {
            va.EUR_CRM_Product_Toolkit__c = productId;
        } else if(productId.getsobjecttype() == new EUR_CRM_SKU__c().getsobjecttype()) {
            va.EUR_CRM_SKU__c = productId;
        } else if(productId.getsobjecttype() == new EUR_CRM_Size__c().getsobjecttype()) {
            va.EUR_CRM_Brand_Quality_Size__c = productId;
        } else if(productId.getsobjecttype() == new EUR_CRM_Quality__c().getsobjecttype()) {
            va.EUR_CRM_Brand_Quality__c = productId;
        } else if(productId.getsobjecttype() == new EUR_CRM_Brand__c().getsobjecttype()) {
            va.EUR_CRM_Brand__c = productId;
        }
        return va;
    }
    public static EUR_CRM_Visit_Sub_Action__c newVisitSubAction(Id vaId, Id productId) {
        EUR_CRM_Visit_Sub_Action__c vsa = new EUR_CRM_Visit_Sub_Action__c(
            RecordTypeId = Schema.SObjectType.EUR_CRM_Visit_Sub_Action__c.getRecordTypeInfosByName().get('EUR DE Visit Sub-Action Off Trade Ad Hoc Promo').getRecordTypeId(),
            EUR_CRM_Visit_Action__c = vaId
        );

        if(productId.getsobjecttype() == new EUR_CRM_SKU__c().getsobjecttype()) {
            vsa.EUR_CRM_SKU__c = productId;
        } else if(productId.getsobjecttype() == new EUR_CRM_Size__c().getsobjecttype()) {
            vsa.EUR_CRM_Brand_Quality_Size__c = productId;
        } else if(productId.getsobjecttype() == new EUR_CRM_Quality__c().getsobjecttype()) {
            vsa.EUR_CRM_Brand_Quality__c = productId;
        } else if(productId.getsobjecttype() == new EUR_CRM_Brand__c().getsobjecttype()) {
            vsa.EUR_CRM_Brand__c = productId;
        }
        return vsa;
    }

    
    public static EUR_CRM_Account__c newAccountOnTrade(String name, Id visitFrequency, Id territory, Id customerTaxonomy) 
    {
        return new EUR_CRM_Account__c (
            Name = name,
            RecordTypeId = Schema.SObjectType.EUR_CRM_Account__c.getRecordTypeInfosByName().get('EUR DE On Trade System Gastronomy').getRecordTypeId(),
            EUR_CRM_Channel__c = 'ON TRADE',
            EUR_CRM_Status__c = 'Active',
            EUR_CRM_Street__c = 'Avenue Nina Simone',
            EUR_CRM_Postal_Code__c = '34000',
            EUR_CRM_City__c = 'Montpellier',
            EUR_CRM_Visit_Frequency__c = visitFrequency
        );
    }
    
    public static EUR_CRM_Account__c newAccountOffTrade(String name, Id visitFrequency, Id territory, Id customerTaxonomy) 
    {
        return new EUR_CRM_Account__c (
            Name = name,
            RecordTypeId = Schema.SObjectType.EUR_CRM_Account__c.getRecordTypeInfosByName().get('EUR DE Off Trade New Business').getRecordTypeId(),
            EUR_CRM_Channel__c = 'OFF TRADE',
            EUR_CRM_Status__c = 'Active',
            EUR_CRM_Street__c = 'Avenue Nina Simone',
            EUR_CRM_Postal_Code__c = '34000',
            EUR_CRM_City__c = 'Montpellier',
            EUR_CRM_Visit_Frequency__c = visitFrequency
        );
    }
    
    public static EUR_CRM_Visit_Frequency__c newVisitFrequency() 
    {
        return new EUR_CRM_Visit_Frequency__c(
            Name = 'EUR DE One a week',
            EUR_CRM_No_of_Visits_Within_Interval__c = 1,
            EUR_CRM_Frequency_Span_Days__c = 14,
            EUR_CRM_Channel__c = 'ON TRADE',
            RecordTypeId = Schema.SObjectType.EUR_CRM_Visit_Frequency__c.getRecordTypeInfosByName().get('EUR DE Visit Frequency').getRecordTypeId()
        );
    }

    
    public static Attachment newAttachment(Id parentId) 
    {
        return new Attachment(
            Name = 'fake_image.png',
            Body = Blob.valueOf('fake-image-content'),
            parentId = parentId
        );
    }

    public static Attachment newAttachmentpdf(Id parentId) 
    {
        return new Attachment(
            Name = 'fake_image.pdf',
            Body = Blob.valueOf('fake-pdf-content'),
            parentId = parentId
        );
    }

    //Uniquement pour les SOSL ==> Petite bidouille pour récupérer facilement tous les ID pour les recherches
    
    public static Attachment newAttachmentSOSL(Id parentId) 
    {
        return new Attachment(
            Name = 'fake_attachment.txt',
            Body = Blob.valueOf('fake-attachment-content'),
            parentId = parentId
        );
    }


    
    public static EUR_CRM_Territory__c newTerritory(String name, Id region) 
    {
        return new EUR_CRM_Territory__c(
            Name = name,
            RecordTypeId = Schema.SObjectType.EUR_CRM_Territory__c.getRecordTypeInfosByName().get('EUR DE Territory').getRecordTypeId(),
            EUR_CRM_Region__c = region
        );
    }
    
    public static EUR_CRM_Region__c newRegion(String name) 
    {
        return new EUR_CRM_Region__c(
            Name = name,
            EUR_CRM_Channel__c = 'ON TRADE'
        );
    }
    
    public static EUR_CRM_Customer_Taxonomy__c newTaxonomy(String name)
    {
        return new EUR_CRM_Customer_Taxonomy__c(
            Name = name,
            EUR_CRM_Chain__c = 'Chain',
            EUR_CRM_Level_1__c = 'Level 1',
            EUR_CRM_Level_2__c = 'Level 2',
            RecordTypeId = Schema.SObjectType.EUR_CRM_Customer_Taxonomy__c.getRecordTypeInfosByName().get('EUR DE Customer Taxonomy').getRecordTypeId()
        );
    }



    /*
    * FOR PERSONAL OBJECTIVE ==> OP
    */
    
    public static EUR_CRM_GB_Objective__c newObjective(String name, Id accountId)
    {
        return new EUR_CRM_GB_Objective__c(
            Name = name,
            EUR_CRM_Objective_Type__c = 'Personal',
            EUR_CRM_Start_Date__c = Date.today(),
            EUR_CRM_End_Date__c = Date.today().addMonths(3),
            EUR_CRM_Account__c = accountId
        );
    }

    /*
    * FOR PROMOTION OBJECTIVE ==> PO
    */
    
    public static EUR_CRM_Account_in_Promo__c newPromoAccount(Id accId, Id objPromoId, Id visit)
    {
        return new EUR_CRM_Account_in_Promo__c(
            EUR_CRM_Account__c = accId,
            EUR_CRM_Visit__c = visit,
            EUR_CRM_Objectives_Promotions__c = objPromoId
        );
    }

   
    public static EUR_CRM_Objectives_Promotions__c newObjectivePromotion(String name)
    {
        return new EUR_CRM_Objectives_Promotions__c(
            Name = name
        );
    }

   
    public static EUR_CRM_OP_Visit_Action__c newOPVisit(Id promoAcc, Id visitId) 
    {
        return new EUR_CRM_OP_Visit_Action__c(
            EUR_CRM_OP_Account_in_Promo__c = promoAcc,
            EUR_CRM_Visit__c = visitId
        );
    }

  
    public static EUR_CRM_Visit__c newVisit(Id accId) 
    {
        return new EUR_CRM_Visit__c(
            EUR_CRM_Account__c = accId,
            EUR_CRM_Start_Datetime__c = DateTime.now(),
            EUR_CRM_End_Datetime__c = DateTime.now().addDays(3),
            EUR_CRM_Visit_Data_Capture_StartDateTime__c = DateTime.now(),
            EUR_CRM_Visit_Data_Capture_EndDateTime__c = DateTime.now().addDays(3),
            EUR_CRM_Status__c = 'Finished',
            EUR_CRM_Category__c = 'Standard Visit'
        );
    }


    /*
    * FOR POSM & CPT
    */
   
    public static EUR_CRM_Wine_Spirits__c newWineAndSpirit(String name) 
    {
        return new EUR_CRM_Wine_Spirits__c(
            Name = name,
            EUR_CRM_External_ID__c = name
        );
    }

    
    public static EUR_CRM_Category__c newCategorie(String name, Id wineAndSpirit)
    {
        return new EUR_CRM_Category__c(
            Name = name,
            EUR_CRM_Wine_Spirits__c = wineAndSpirit,
            EUR_CRM_Active__c = true
        );
    }

   
    public static EUR_CRM_Brand__c newBrand(String name, Id categId) 
    {
        return new EUR_CRM_Brand__c(
            Name = name,
            EUR_CRM_Category__c = categId,
            EUR_CRM_Active__c = true,
            EUR_CRM_Is_Competitor__c = true
        );
    }

  
    public static EUR_CRM_Quality__c newQuality(String name, Id brandId) 
    {
        return new EUR_CRM_Quality__c(
            Name = name,
            EUR_CRM_Brand__c = brandId,
            EUR_CRM_Active__c = true
        );
    }

   
    public static EUR_CRM_Size__c newSize(String name, Id qualityId)
    {
        return new EUR_CRM_Size__c(
            Name = name,
            EUR_CRM_Brand_Quality__c = qualityId,
            EUR_CRM_Active__c = true
        );
    }

    public static EUR_CRM_SKU__c newSKU(String name, Id bqsId) {
        return new EUR_CRM_SKU__c(
            Name = name,
            EUR_CRM_Brand_Quality_Size__c = bqsId
        );
    }

    public static EUR_CRM_Product_Toolkit__c newToolkit(String name) {
        return new EUR_CRM_Product_Toolkit__c(
            Name = name
        );
    }


    /*
    * DATA FOR CPT
    */
    
    public static EUR_CRM_Competitor_Promo_Tracking__c newPromoTracking(String name, Id accId)
    {
        return new EUR_CRM_Competitor_Promo_Tracking__c(
            EUR_CRM_Promotion_Name__c = name,
            EUR_CRM_Promotion_Type__c = 'Introduction',
            EUR_CRM_Account_Name__c = accId,
            RecordTypeId = Schema.SObjectType.EUR_CRM_Competitor_Promo_Tracking__c.getRecordTypeInfosByDeveloperName().get('EUR_NG_On_Trade_CPT').getRecordTypeId()
        );
    }
    


    public static EUR_CRM_Competitor_Promo_Tracking_Item__c newPromoTrackingItem(Id promoTracking, Id quality, Id size) 
    {
        return new EUR_CRM_Competitor_Promo_Tracking_Item__c(
            EUR_CRM_Competitor_Promo_Tracking__c = promoTracking,
            EUR_CRM_Brand_Quality__c = quality,
            EUR_CRM_Brand_Quality_Size__c = size
        );
    }

    
    /*
    * DATA FOR SA
    */

    public static EUR_CRM_Store_Audit__c newStoreAudit(Id accId, Id visitId)
    {
        return new EUR_CRM_Store_Audit__c(
            EUR_CRM_Account__c = accId,
            EUR_CRM_Visit__c = visitId
        );
    }
  
    public static EUR_CRM_Store_Audit_Item__c newStoreAuditItem(Id storeAudit, Id accId, Id size, Id material)
    {
        return new EUR_CRM_Store_Audit_Item__c(
            EUR_CRM_Store_Audit__c = storeAudit,
            EUR_CRM_Account__c = accId,
            EUR_CRM_Brand_Quality_Size__c = size,
            EUR_CRM_POS_Material__c = material
        );
    }

    /*
    * DATA FOR POSM
    */

    public static EUR_CRM_POSM_Audit__c newPOSMAudit(Id accId, Id visitId)
    {
        return new EUR_CRM_POSM_Audit__c(
            EUR_CRM_Account__c = accId,
            EUR_CRM_Visit__c = visitId
        );
    }
  
    public static EUR_CRM_POSM_Audit_Item__c newPOSMAuditItem(Id storeAudit, Id material)
    {
        return new EUR_CRM_POSM_Audit_Item__c(
            EUR_CRM_POSM_Audit__c = storeAudit,
            EUR_CRM_POS_Material__c = material
        );
    }




   
    public static EUR_CRM_POS_Material__c newMaterial(String name)
    {
        return new EUR_CRM_POS_Material__c(
            Name = name
        );
    }

    /*
    * FOR BS
    */
    public static EUR_CRM_Brand_Security_Infringement__c newBS(String visitId)
    {
        return new EUR_CRM_Brand_Security_Infringement__c(
            EUR_CRM_Date_when_sighted__c = Date.today(),
            EUR_CRM_Outlet_type__c = 'DUTY FREE',
            EUR_CRM_Country_where_sighted__c = 'NG',
            EUR_CRM_Brand_Quality__c = '100 PIPERS',
            EUR_CRM_Bottle_size_cl__c = '50',
            EUR_CRM_Alcohol_volume__c = '10.5%',
            EUR_CRM_Quantity_sighted_in_bottles__c = 10,
            EUR_CRM_Visit_ID__c = visitId,
            RecordTypeId = Schema.SObjectType.EUR_CRM_Brand_Security_Infringement__c.getRecordTypeInfosByName().get('EUR Brand Security Infringement GMA').getRecordTypeId()
        );
    }

    /*
    * FOR SO
    */
    public static EUR_CRM_Sales_Order__c newSO(String accountId)
    {
        return new EUR_CRM_Sales_Order__c(
            RecordTypeId = Schema.SObjectType.EUR_CRM_Sales_Order__c.getRecordTypeInfosByName().get('Free Goods from Stock').getRecordTypeId(),
            EUR_CRM_Account__c = accountId
        );
    }

    public static Group newPublicGroup(String groupName)
    {
        List<Group> groups = [Select Id from group where developername = :groupName];
        if(groups.size() == 1)
        {
            return groups[0];
        }
        return new Group(
            name = groupName,
            DeveloperName = groupName,
            Type = 'Regular'
        );
    }

    public static GroupMember newGroupMember(String groupId, String userId)
    {
        List<GroupMember> members = [Select Id from GroupMember where GroupId = :groupId and UserOrGroupId = :userId];
        if(members.size()==1)
        {
            return members[0];
        }
        return new GroupMember(
            GroupId = groupId,
            UserOrGroupId = userId
        );
    }
    
    public static User newUser(String userName, Id profileId, String countryCode) {
        return new User(
            email = userName,
            username = userName,
            lastname = userName.left(5),
            alias = userName.left(5),
            isActive = true,
            EUR_CRM_Affiliate_Code_Picklist__c = countryCode,
            profileId = profileId,
            TimeZoneSidKey = 'Europe/Paris', 
            LocaleSidKey = 'en_US', 
            EmailEncodingKey = 'UTF-8', 
            LanguageLocaleKey = 'en_US'
        );
    }
    
}