<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>ASI_CRM_KR_SIT_Update_External_ID</fullName>
        <field>ASI_CRM_External_ID__c</field>
        <formula>CASESAFEID(ASI_KOR_Item_Group_Code__c) &amp; &apos;&amp;&apos; &amp;CASESAFEID(Stock_In_Trade__c)</formula>
        <name>ASI CRM KR SIT Update External ID</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>ASI_CRM_KR_SITDCheckDuplicateRecord</fullName>
        <actions>
            <name>ASI_CRM_KR_SIT_Update_External_ID</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>ISNEW() || ISCHANGED( ASI_KOR_Item_Group_Code__c) || ISCHANGED( Stock_In_Trade__c)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
