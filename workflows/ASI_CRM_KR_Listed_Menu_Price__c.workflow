<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>ASI_CRM_KR_LMPH_Update_Unique_ID</fullName>
        <field>ASI_CRM_KR_Unique_ID__c</field>
        <formula>TEXT(ASI_CRM_KR_Fiscal_Year__c) &amp; &apos;_&apos; &amp; TEXT( ASI_CRM_KR_Quarter__c) &amp; &apos;_&apos; &amp; CASESAFEID(ASI_CRM_KR_Venue__c)</formula>
        <name>ASI CRM KR LMPH Update Unique ID</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>ASI_CRM_KR_LMPHCheckDuplicateRecord</fullName>
        <actions>
            <name>ASI_CRM_KR_LMPH_Update_Unique_ID</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>ASI_CRM_KR_LMPHCheckDuplicateRecord</description>
        <formula>ISNEW() || ISCHANGED( ASI_CRM_KR_Fiscal_Year__c) || ISCHANGED( ASI_CRM_KR_Quarter__c) || ISCHANGED( ASI_CRM_KR_Venue__c)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
