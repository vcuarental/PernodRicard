<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>ASI_CRM_KR_PVAGuideline_Update_Unique_ID</fullName>
        <field>ASI_CRM_KR_External_ID_Upload__c</field>
        <formula>LOWER(ASI_CRM_KR_Account_Code__r.ASI_KOR_Customer_Code__c &amp; &apos;_&apos; &amp; text(ASI_CRM_KR_Activity_Type__c) &amp; &apos;_&apos; &amp; ASI_KOR_Brand_Code__r.ASI_KOR_Brand_Code__c &amp; &apos;_fy&apos; &amp; 
 RIGHT(text(ASI_CRM_KR_Fiscal_Year__c)
, 4))</formula>
        <name>ASI CRM KR PVAGuideline Update Unique ID</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>ASI_CRM_KR_PVAGuidelineCheckDuplicateRecord</fullName>
        <actions>
            <name>ASI_CRM_KR_PVAGuideline_Update_Unique_ID</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>ASI_CRM_KR_PVAGuidelineCheckDuplicateRecord</description>
        <formula>ISNEW() || ISCHANGED( ASI_CRM_KR_Account_Code__c) || ISCHANGED( ASI_CRM_KR_Activity_Type__c) || ISCHANGED( ASI_KOR_Brand_Code__c) || ISCHANGED(ASI_CRM_KR_Fiscal_Year__c)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
