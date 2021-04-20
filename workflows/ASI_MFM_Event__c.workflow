<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>ASI_MFM_CN_Update_On_Off</fullName>
        <field>ASI_MFM_ON_OFF__c</field>
        <formula>TEXT(ASI_MFM_Key_Channel__r.ASI_CRM_CN_On_Off__c)</formula>
        <name>Update On/Off</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>ASI_MFM_CN_Update_On_Off_To_Event</fullName>
        <actions>
            <name>ASI_MFM_CN_Update_On_Off</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>ASI_MFM_Event__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>CN Event</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
