/**
title:community home page controller - image & link
author:Alex 2019.11.18
modified:
Joey 2020.1.6 added function "getHomeAnnouncement" for announcement soql.
**/
public without sharing class ASI_CTY_CN_WS_HomePageController {
    public static final String SETUP_RECORDTYPE_BANNER = 'ASI_CTY_CN_WS_Banner';
    public static final String SETUP_RECORDTYPE_FOOTER = 'ASI_CTY_CN_WS_Footer';
    public static final String SETUP_RECORDTYPE_ANNOUNCE = 'ASI_CTY_CN_WS_Announcement';

    @AuraEnabled
    public static List<SObject> getHomeImageList() {
        return [SELECT ASI_CTY_CN_WS_Sequence__c, ASI_CTY_CN_WS_Image_Url__c, ASI_CTY_CN_WS_Href__c, Name, (
                      SELECT Id FROM Attachments order by CreatedDate desc limit 1)
                  FROM ASI_CTY_CN_WS_Setup__c
                  WHERE RecordType.DeveloperName = :SETUP_RECORDTYPE_BANNER
                  Order by ASI_CTY_CN_WS_Sequence__c ];
    }

    @AuraEnabled
    public static Map<String, List<SObject>> getHomeLinkMap() {
        Map<String, List<SObject>> result = new Map<String, List<SObject>>();
        for (ASI_CTY_CN_WS_Setup__c link : [SELECT ASI_CTY_CN_WS_Sequence__c, Name, ASI_CTY_CN_WS_Href__c, ASI_CTY_CN_WS_Title__c 
                                                              FROM ASI_CTY_CN_WS_Setup__c
                                                             WHERE RecordType.DeveloperName = :SETUP_RECORDTYPE_FOOTER
                                                              Order by ASI_CTY_CN_WS_Title__c, ASI_CTY_CN_WS_Sequence__c ]) {
            if (!result.containsKey(link.ASI_CTY_CN_WS_Title__c)) {
                result.put(link.ASI_CTY_CN_WS_Title__c, new List<SObject>());
            }
            result.get(link.ASI_CTY_CN_WS_Title__c).add(link);
        }

        return result;
    }
    
    @AuraEnabled
    public static List<ASI_CTY_CN_WS_Setup__c> getHomeAnnouncement() {
        return [SELECT ASI_CTY_CN_WS_Sequence__c, ASI_CTY_CN_WS_Image_Url__c, ASI_CTY_CN_WS_Href__c, Name, ASI_CTY_CN_WS_Subheadline__c  
                  FROM ASI_CTY_CN_WS_Setup__c
                  WHERE RecordType.DeveloperName = :SETUP_RECORDTYPE_ANNOUNCE
                  Order by ASI_CTY_CN_WS_Sequence__c];
    }
}