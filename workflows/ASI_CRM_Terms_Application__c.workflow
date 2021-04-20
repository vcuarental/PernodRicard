<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>ASI_CRM_TW_Copy_Term_Detail</fullName>
        <field>ASI_CRM_Terms_Details__c</field>
        <formula>ASI_CRM_Terms__r.ASI_CRM_Terms_Details__c</formula>
        <name>ASI CRM TW Copy Term Detail</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>ASI CRM TW Copy Term Detail</fullName>
        <actions>
            <name>ASI_CRM_TW_Copy_Term_Detail</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>NOT(ISBLANK(ASI_CRM_Terms__r.ASI_CRM_Terms_Details__c ))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
