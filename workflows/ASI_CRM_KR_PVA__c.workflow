<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>ASI_CRM_KR_PVA_Update_Unique_ID</fullName>
        <description>ASI CRM KR PVA Update Unique ID</description>
        <field>ASI_CRM_KR_External_ID_Upload__c</field>
        <formula>ASI_CRM_KR_Channel__c &amp; &apos;_&apos; &amp; TEXT(ASI_CRM_KR_Outlet_Image__c) &amp; &apos;_&apos; &amp; CASESAFEID(ASI_CRM_KR_Brand__r.ASI_KOR_Brand_Code__c) &amp;&apos;_&apos; &amp; CASESAFEID(RecordTypeId)</formula>
        <name>ASI CRM KR PVA Update Unique ID</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>ASI_CRM_KR_PVACheckDuplicateRecord</fullName>
        <actions>
            <name>ASI_CRM_KR_PVA_Update_Unique_ID</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>ISNEW() || ISCHANGED( ASI_CRM_KR_Channel__c) || ISCHANGED( ASI_CRM_KR_Outlet_Image__c) || ISCHANGED( ASI_CRM_KR_Brand__c)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
